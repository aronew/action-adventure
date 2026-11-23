"""Cinderheart room layouts -> JSON for the Godot room builder, checked for reachability.

'#' rock, '.' air, 'F' fake wall (drawn as rock, walk-through: secrets).
Cells are 36 px. The Seeker (jump_speed 420) climbs 2 cells, run-jumps a 3-cell gap and
dash-jumps a 4-cell gap (tools/level/reach.py has the exact model).

Methods used (design/levels/cinderheart-region-1.md): rooms several screens big with a
low and a high route; solid floating islands (no pass-through platforms) for vertical
play; visible-but-unreachable rewards that pay off later; secrets behind fake walls;
gates that are terrain (a 4-cell gap with a pit you can climb back out of); a hub with
several exits; shortcuts home; rests by role.

Run: python3 tools/level/cinderheart_layout.py
Then: godot --headless --path . -s res://tools/level/build_cinderheart_rooms.gd
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(__file__))
import reach

ROOMS_DIR = "res://src/world/cinderheart/rooms/"


class Room:
    def __init__(self, key, name, w, h):
        self.key, self.name, self.w, self.h = key, name, w, h
        self.g = [["#"] * w for _ in range(h)]
        self.exits, self.markers = [], []
        self.expect_walk, self.expect_dash_only = set(), set()
        self.entries = None

    def _fill(self, x0, y0, x1, y1, ch):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.g[y][x] = ch
        return self

    def open(self, x0, y0, x1, y1):
        return self._fill(x0, y0, x1, y1, ".")

    def solid(self, x0, y0, x1, y1):
        return self._fill(x0, y0, x1, y1, "#")

    def fake(self, x0, y0, x1, y1):
        return self._fill(x0, y0, x1, y1, "F")

    def plat(self, x, s, w):
        """A floating rock island one cell thick: top (surface) row s, columns x..x+w-1."""
        return self.solid(x, s, x + w - 1, s)

    def exit(self, exit_id, side, a, b, target_room, target_exit):
        target = target_room if target_room.startswith("res://") else ROOMS_DIR + target_room + ".tscn"
        self.exits.append(dict(id=exit_id, side=side, a=a, b=b, target=target, target_exit=target_exit))
        return self

    def mark(self, kind, col, surface_row, **extra):
        self.markers.append(dict(kind=kind, col=col, row=surface_row, **extra))
        return self

    def enter_from(self, *ids):
        """Check reachability from these exits only (the side before a gate)."""
        self.entries = set(ids)
        return self

    def expect(self, walk=(), dash_only=()):
        self.expect_walk |= set(walk)
        self.expect_dash_only |= set(dash_only)
        return self

    # --- checks ----------------------------------------------------------
    def exit_spots(self, e):
        g, w, h = self.g, self.w, self.h
        if e["side"] == "left":
            return [reach.land(g, 0, e["b"]), reach.land(g, 1, e["b"])]
        if e["side"] == "right":
            return [reach.land(g, w - 1, e["b"]), reach.land(g, w - 2, e["b"])]
        if e["side"] == "top":
            mid = (e["a"] + e["b"]) // 2
            return [reach.land(g, mid, 1)]
        # bottom: the floor beside the hole
        col = e["a"] - 1
        y = 0
        while not reach.standing(g, col, y):
            y += 1
            if y >= h:
                return []
        return [(col, y)]

    def exit_reached(self, e, seen):
        g = self.g
        if e["side"] in ("left", "right"):
            return any(s in seen for s in self.exit_spots(e))
        if e["side"] == "top":
            # a jump from a spot under the hole within 2 rows of the top reaches it
            return any(x in range(e["a"] - 1, e["b"] + 2) and y <= 3 for (x, y) in seen)
        return any(s in seen for s in self.exit_spots(e))

    def names(self, seen):
        found = set()
        for e in self.exits:
            if self.exit_reached(e, seen):
                found.add("exit:" + e["id"])
        for m in self.markers:
            if (m["col"], m["row"] - 1) in seen:
                found.add("%s@%d,%d" % (m["kind"], m["col"], m["row"]))
        return found

    def check(self):
        assert all(len(r) == self.w for r in self.g)
        for e in self.exits:
            for i in range(e["a"], e["b"] + 1):
                x, y = {"left": (0, i), "right": (self.w - 1, i), "top": (i, 0),
                        "bottom": (i, self.h - 1)}[e["side"]]
                assert self.g[y][x] == ".", (self.key, e["id"], x, y)
        for m in self.markers:
            c, r = m["col"], m["row"]
            assert self.g[r][c] == "#" and self.g[r - 1][c] != "#", (self.key, m, "marker must stand on rock")
        starts = []
        for e in self.exits:
            if self.entries is None or e["id"] in self.entries:
                starts += self.exit_spots(e)
        for m in self.markers:
            if m["kind"] == "start":
                starts.append((m["col"], m["row"] - 1))
        walk = self.names(reach.reachable(self.g, starts, False))
        dash = self.names(reach.reachable(self.g, starts, True))
        everything = set("exit:" + e["id"] for e in self.exits) | set(
            "%s@%d,%d" % (m["kind"], m["col"], m["row"]) for m in self.markers)
        problems = []
        for n in sorted(everything - dash):
            problems.append("UNREACHABLE even with dash: " + n)
        for n in sorted(self.expect_dash_only & walk):
            problems.append("GATE LEAKS (reachable without dash): " + n)
        for n in sorted((everything - self.expect_dash_only) - walk):
            if n not in self.expect_dash_only:
                problems.append("needs dash but not marked dash-only: " + n)
        return problems

    def dump(self):
        return dict(key=self.key, name=self.name, w=self.w, h=self.h,
                    rows=["".join(r) for r in self.g], exits=self.exits, markers=self.markers)


rooms = []

# ---------------------------------------------------------------------------
# C1 Waking Niche: wake at the bottom of a tall cavern. A rest spot, a secret behind the
# wall at your back, and a climb up floating islands to the exit at the top right.
r = Room("c01_waking_niche", "Waking Niche", 48, 26)
r.open(6, 2, 45, 21)
r.open(2, 18, 3, 21).fake(4, 18, 5, 21)                 # secret nook behind a fake wall
r.solid(38, 6, 47, 7).open(46, 3, 47, 5)               # top ledge and exit
r.plat(14, 20, 4).plat(19, 18, 4).plat(24, 16, 4).plat(29, 14, 4).plat(34, 12, 4)
r.plat(39, 10, 4).plat(33, 8, 4)
r.exit("right", "right", 3, 5, "c02_ash_steps", "left")
r.mark("start", 8, 22).mark("rest", 11, 22).mark("relic", 2, 22)
rooms.append(r)

# C2 Ash Steps: a wide descent split by a great rock: a high road across its top (a grunt,
# and islands climbing to a relic you see from below) and a low cave under it.
r = Room("c02_ash_steps", "Ash Steps", 64, 30)
r.open(0, 2, 61, 27)
r.solid(0, 6, 10, 7)                                    # entry ledge
r.solid(16, 12, 44, 17)                                 # the great rock
r.plat(19, 10, 2).plat(22, 8, 3).plat(27, 6, 3)         # climb to the relic
r.plat(49, 22, 4).plat(53, 25, 3)                       # steps down to the exit
r.open(62, 24, 63, 27)
r.exit("left", "left", 3, 5, "c01_waking_niche", "right")
r.exit("right", "right", 24, 27, "c03_kiln_hall", "high_left")
r.mark("enemy", 30, 12, config="grunt").mark("enemy", 25, 28, config="skitter") \
 .mark("enemy", 40, 28, config="grunt").mark("enemy", 57, 28, config="grunt")
r.mark("relic", 28, 6)
rooms.append(r)

# C3 Kiln Hall, the hub: you drop in from a high shelf you can't climb back to. The rest
# is by the kiln mound. Islands climb to a hidden room high on the right. A hole in the
# floor leads down to the Cinder Run; the right exit is the Glaze Bridge (the dash gate);
# the low left exit is the end of the shortcut from the Keeper's Forge.
r = Room("c03_kiln_hall", "Kiln Hall", 70, 32)
r.open(0, 2, 67, 27)
r.solid(0, 8, 12, 9).solid(0, 2, 0, 4)                  # high shelf (arrival, one-way)
r.solid(0, 10, 1, 23)
r.open(20, 28, 22, 31)                                  # floor hole
r.solid(28, 26, 40, 27).solid(31, 24, 37, 25)           # kiln mound
r.plat(40, 22, 3).plat(45, 20, 3).plat(50, 18, 3).plat(55, 16, 3).plat(60, 14, 3)
r.plat(64, 12, 3).plat(59, 10, 3)
r.solid(63, 8, 69, 9)                                   # upper ledge to the hidden room
r.solid(68, 10, 69, 23).open(68, 5, 69, 7).open(68, 24, 69, 27)
r.exit("high_left", "left", 5, 7, "c02_ash_steps", "right")
r.exit("low_left", "left", 24, 27, "c07_bellows_climb", "high_right")
r.exit("down", "bottom", 20, 22, "c04_cinder_run", "up")
r.exit("right", "right", 24, 27, "c05_glaze_bridge", "left")
r.exit("upper_right", "right", 5, 7, "c09_ember_hoard", "left")
r.mark("rest", 44, 28).mark("start", 5, 8)
r.mark("enemy", 12, 28, config="skitter")
rooms.append(r)

# C4 Cinder Run: the long fight. A ground road over shelves and pits, and an upper road
# of islands that ends at a fake wall with a relic behind it. You land on a ledge under
# the hub's floor hole; islands climb back up to it.
r = Room("c04_cinder_run", "Cinder Run", 84, 24)
r.open(1, 1, 81, 19)
r.open(0, 16, 0, 19)
r.open(70, 0, 72, 0)                                    # hole up to the hub
r.solid(66, 4, 76, 5)                                   # landing ledge
r.plat(62, 18, 3).plat(57, 16, 3).plat(62, 14, 3).plat(57, 12, 3).plat(62, 10, 3)
r.plat(57, 8, 3).plat(62, 6, 3)
r.solid(44, 18, 52, 19)                                 # shelf
r.open(38, 20, 40, 21)                                  # pit
r.solid(22, 19, 23, 19).solid(24, 17, 32, 19)           # step and shelf
r.open(14, 20, 16, 21)                                  # pit
r.plat(48, 16, 3).plat(42, 14, 4).plat(36, 12, 4).plat(29, 11, 4).plat(24, 9, 4)
r.solid(2, 1, 14, 8).open(4, 6, 10, 7).fake(11, 6, 14, 7).solid(15, 8, 20, 8)
r.exit("up", "top", 70, 72, "c03_kiln_hall", "down")
r.exit("left", "left", 16, 19, "c06_keepers_forge", "right")
r.mark("enemy", 48, 18, config="grunt").mark("enemy", 30, 17, config="skitter") \
 .mark("enemy", 8, 20, config="grunt").mark("enemy", 56, 20, config="skitter") \
 .mark("enemy", 37, 12, config="grunt")
r.mark("relic", 6, 8)
rooms.append(r)

# C5 Glaze Bridge: the first gate, one room from the hub. A 4-cell gap with the far side
# a cell higher; the pit has a step back to the near side and is too deep to climb out
# to the far side. A relic sits on an island over the far side: seen now, taken later.
r = Room("c05_glaze_bridge", "Glaze Bridge", 54, 22)
r.open(0, 2, 53, 13)
r.solid(24, 13, 53, 13)                                 # far side, a cell higher
r.open(20, 14, 23, 16).solid(20, 16, 20, 16)            # pit with a step
r.solid(0, 2, 0, 9).solid(53, 2, 53, 8)
r.plat(28, 11, 2).plat(31, 9, 3)
r.exit("left", "left", 10, 13, "c03_kiln_hall", "right")
r.exit("right", "right", 9, 12, "c08_brun_antechamber", "left")
r.mark("gate", 16, 14, ability="dash").mark("relic", 32, 9)
r.enter_from("left").expect(dash_only=["exit:right", "relic@32,9"])
rooms.append(r)

# C6 Keeper's Forge: the arena. A brute and two skitters on the floor, islands up to the
# dash on a high island in the middle.
r = Room("c06_keepers_forge", "Keeper's Forge", 40, 20)
r.open(1, 2, 38, 15)
r.open(0, 12, 0, 15).open(39, 12, 39, 15)
r.plat(6, 14, 3).plat(10, 12, 4).plat(16, 10, 6).plat(31, 14, 3).plat(26, 12, 4)
r.exit("right", "right", 12, 15, "c04_cinder_run", "left")
r.exit("left", "left", 12, 15, "c07_bellows_climb", "low_left")
r.mark("enemy", 20, 16, config="brute").mark("enemy", 12, 16, config="skitter") \
 .mark("enemy", 28, 16, config="skitter")
r.mark("ability", 19, 10, ability="dash")
rooms.append(r)

# C7 Bellows Climb: a tall shaft, the shortcut home. Zig-zag up the islands, then a dash
# gap at the top to the ledge that opens into the hub. From the hub side you can drop in.
r = Room("c07_bellows_climb", "Bellows Climb", 34, 36)
r.open(1, 2, 32, 32)
r.open(0, 29, 0, 32)
r.plat(4, 31, 4).plat(9, 29, 4).plat(14, 27, 4).plat(19, 25, 4).plat(24, 23, 4)
r.plat(28, 21, 4)                                       # turn
r.plat(23, 19, 4).plat(18, 17, 4).plat(13, 15, 4).plat(8, 13, 4).plat(3, 11, 4)
r.plat(9, 9, 4).plat(14, 7, 4)                          # turn, then the top
r.solid(22, 6, 33, 7).open(33, 2, 33, 5)                # far ledge past the dash gap
r.exit("low_left", "left", 29, 32, "c06_keepers_forge", "left")
r.exit("high_right", "right", 2, 5, "c03_kiln_hall", "low_left")
r.enter_from("low_left").expect(dash_only=["exit:high_right"])
rooms.append(r)

# C8 Brun's Antechamber: a rest before the boss door.
r = Room("c08_brun_antechamber", "Brun's Antechamber", 32, 14)
r.open(0, 2, 31, 9)
r.solid(0, 2, 0, 5).solid(31, 2, 31, 5)
r.exit("left", "left", 6, 9, "c05_glaze_bridge", "right")
r.exit("right", "right", 6, 9, "res://src/enemies/boss/boss_arena.tscn", "")
r.mark("rest", 12, 10)
rooms.append(r)

# C9 Ember Hoard: the hidden room at the top of the hub, a reward for climbing.
r = Room("c09_ember_hoard", "Ember Hoard", 24, 14)
r.open(0, 2, 21, 7)
r.solid(0, 2, 0, 4)
r.exit("left", "left", 5, 7, "c03_kiln_hall", "upper_right")
r.mark("relic", 16, 8).mark("enemy", 10, 8, config="skitter")
rooms.append(r)

bad = False
for r in rooms:
    problems = r.check()
    print(r.key, r.w, "x", r.h, "OK" if not problems else "")
    for p in problems:
        print("   ", p)
        bad = True
if "--show" in sys.argv:
    for r in rooms:
        print(r.key)
        for row in r.g:
            print("  " + "".join(row))
out = os.path.join(os.path.dirname(__file__), "cinderheart_rooms.json")
json.dump([r.dump() for r in rooms], open(out, "w"), indent=1)
sys.exit(1 if bad else 0)
