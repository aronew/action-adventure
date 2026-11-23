"""Cinderheart room layouts -> JSON for the Godot room builder, checked for reachability.

'#' rock, '.' air, 'F' fake wall (drawn as rock, walk-through), 's' a secret room's air
(open, but covered in the game by painted rock until the Seeker steps in).
Cells are 36 px. The Seeker (jump_speed 420) climbs 2 cells, run-jumps a 3-cell gap and
dash-jumps a 4-cell gap (tools/level/reach.py has the exact model).

Methods used (design/levels/cinderheart-region-1.md): the "ant farm": every room starts
as solid rock and is carved into chambers and tunnels at different depths, each chamber
joined to two or three others, so the rock left between them is the big islands.
Switchback climbs (stacked tunnels joined at alternating ends). Open caverns (the far city
behind) alternate with cave tunnels (the close rock wall): cave_from_col. Visible-but-
gated rewards, secrets behind fake walls, terrain gates, a hub, a loop home, rests by role.

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
        self.cave_from_col = -1
        self.biome = "cinderheart"
        self.out_dir = "res://src/world/cinderheart/rooms/"

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

    def secret(self, x0, y0, x1, y1):
        """A secret room's air: open, but hidden under painted rock until found."""
        return self._fill(x0, y0, x1, y1, "s")

    def island(self, x, s, w, h):
        """A large floating rock island: top (surface) row s, w columns, h rows thick. Drawn
        with the big painted rock frame (edges around a dark middle)."""
        return self.solid(x, s, x + w - 1, s + h - 1)

    def tunnel(self, x0, x1, floor, h=3):
        """A carved horizontal tunnel: open rows floor-h .. floor-1, rock floor at `floor`."""
        return self.open(x0, floor - h, x1, floor - 1)

    def switchback(self, x0, x1, bottom_floor, levels, first_turn="right"):
        """A switchback climb carved in rock: `levels` stacked tunnels (3 rows tall, 2-row
        rock slabs between, so each level is 5 rows above the last), joined at alternating
        ends by a hole through the slab with two steps: a 2-row block at the tunnel's end
        and a one-cell ledge on the slab's edge. Run to the end, hop up twice, run back."""
        floors = [bottom_floor - 5 * k for k in range(levels)]
        for f in floors:
            self.tunnel(x0, x1, f)
        side = first_turn
        for f in floors[:-1]:
            if side == "right":
                self.open(x1 - 2, f - 5, x1, f - 4).solid(x1, f - 2, x1, f - 1).solid(x1 - 2, f - 4, x1 - 2, f - 4)
            else:
                self.open(x0, f - 5, x0 + 2, f - 4).solid(x0, f - 2, x0, f - 1).solid(x0 + 2, f - 4, x0 + 2, f - 4)
            side = "left" if side == "right" else "right"
        return self

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
            # the trigger covers the top 4 rows: a jump from a spot near the hole at row 6
            # or higher reaches it
            return any(x in range(e["a"] - 1, e["b"] + 2) and y <= 6 for (x, y) in seen)
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

    def cave(self, col):
        """Columns from `col` on get the cave look (close rock wall); -1 none, 0 all."""
        self.cave_from_col = col
        return self

    def dump(self):
        return dict(key=self.key, name=self.name, w=self.w, h=self.h, cave_from_col=self.cave_from_col,
                    biome=self.biome, out_dir=self.out_dir,
                    rows=["".join(r) for r in self.g], exits=self.exits, markers=self.markers)


rooms = []

# ---------------------------------------------------------------------------
# C1 Waking Niche. You wake on the floor of a tall open cavern (rest spot). Two ways to
# the exit, which is lit, at the end of the cave's third level: climb the cavern's big
# islands to the window on the right and walk out, or take the low tunnel into the cave
# and climb its switchback. The islands also reach a ledge on the left wall with a fake
# wall behind it (a relic).
def waking_niche_shapes(r):
    """Waking Niche's carving (also the Hollow Molt test room's)."""
    r.open(3, 14, 29, 29)                                   # the cavern
    r.solid(3, 14, 3, 17).fake(3, 18, 3, 19).secret(1, 18, 2, 19).solid(3, 20, 11, 21)
    r.plat(5, 28, 3).island(9, 26, 7, 3).island(18, 24, 8, 4).plat(14, 22, 3).plat(27, 22, 2)
    r.solid(10, 14, 22, 15).solid(13, 16, 19, 16)           # rock hanging from the roof
    r.tunnel(30, 40, 20)                                    # the window into the cave
    r.tunnel(30, 40, 30)                                    # low tunnel to the switchback
    r.switchback(41, 56, 30, 3)
    r.tunnel(41, 59, 20)                                    # third level runs out to the exit
    return r


r = waking_niche_shapes(Room("c01_waking_niche", "Waking Niche", 60, 34).cave(30))
r.exit("right", "right", 17, 19, "c02_ash_steps", "left")
r.mark("start", 26, 30).mark("rest", 29, 30).mark("relic", 1, 20)
r.mark("enemy", 48, 20, config="grunt").mark("enemy", 46, 25, config="skitter")
rooms.append(r)

# C2 Ash Steps. A tunnel from the left opens high in the Ash Well, a deep open cavern;
# drop down its big islands. A high road leaves the middle island into the cave (a
# grunt, a relic at its far end) and a shaft drops from it to the low road, which runs
# along the cavern floor and out at the bottom right.
r = Room("c02_ash_steps", "Ash Steps", 70, 36).cave(41)
r.tunnel(0, 12, 10)
r.open(13, 4, 40, 31)                                   # the Ash Well
r.solid(13, 4, 24, 6).solid(30, 4, 40, 8).solid(34, 9, 40, 10)   # its rough roof
r.island(15, 14, 8, 3).island(27, 19, 9, 4).island(16, 24, 8, 3).plat(30, 27, 3)
r.tunnel(36, 66, 19).solid(36, 19, 40, 20)              # high road and its ledge
r.open(56, 19, 58, 28)                                  # shaft down to the low road
r.tunnel(41, 69, 32)                                    # low road
r.exit("left", "left", 7, 9, "c01_waking_niche", "right")
r.exit("right", "right", 29, 31, "c03_kiln_hall", "high_left")
r.mark("enemy", 31, 19, config="grunt").mark("enemy", 25, 32, config="skitter") \
 .mark("enemy", 47, 19, config="grunt").mark("enemy", 50, 32, config="grunt") \
 .mark("enemy", 63, 32, config="skitter")
r.mark("relic", 65, 19)
rooms.append(r)

# C3 Kiln Hall, the hub: a great open hall. You drop in from a high tunnel on the left onto
# a big island, then to the floor; you can't climb back. Five ways on: the low left tunnel
# (the end of the shortcut), a hole in the floor (Cinder Run), the right tunnel (Glaze
# Bridge), and high on the right, past a climb of big islands, the tunnel to a hidden room.
r = Room("c03_kiln_hall", "Kiln Hall", 72, 34).cave(64)
r.open(8, 6, 63, 28)                                    # the hall
r.tunnel(0, 7, 9)                                       # high left (arrival, one-way)
r.tunnel(0, 7, 29)                                      # low left
r.open(22, 29, 24, 33)                                  # floor hole
r.solid(26, 6, 44, 9).solid(30, 10, 40, 11).solid(33, 12, 37, 12)   # rock hanging from the roof
r.island(10, 14, 9, 3)                                  # landing island under the high tunnel
r.solid(30, 27, 42, 28).solid(33, 25, 39, 26)           # kiln mound
r.plat(10, 27, 2).island(13, 25, 7, 3)
r.island(42, 23, 6, 3).plat(50, 21, 2).island(53, 19, 7, 4).plat(61, 17, 2).plat(57, 15, 2).plat(61, 13, 2)
r.tunnel(64, 71, 11)                                    # upper right, to the hidden room
r.tunnel(64, 71, 29)                                    # right, to the bridge
r.exit("high_left", "left", 6, 8, "c02_ash_steps", "right")
r.exit("low_left", "left", 26, 28, "c07_bellows_climb", "high_right")
r.exit("down", "bottom", 22, 24, "c04_cinder_run", "up")
r.exit("right", "right", 26, 28, "c05_glaze_bridge", "left")
r.exit("upper_right", "right", 8, 10, "c09_ember_hoard", "left")
r.mark("rest", 56, 29).mark("start", 4, 9)
r.mark("enemy", 16, 25, config="skitter").mark("enemy", 48, 29, config="grunt")
rooms.append(r)

# C4 Cinder Run, an ant farm: you fall from the hub into a landing chamber on the right
# (islands climb back up to the hole). Two tunnels run left from it, a high one and a low
# one, joined by the Middle Chamber, an open cavern with islands. The low tunnel is the
# fight (and the way on, to the Keeper's Forge); a fake wall in the Middle Chamber's left
# wall hides a relic.
r = Room("c04_cinder_run", "Cinder Run", 80, 25).cave(38)
r.open(54, 5, 75, 20)                                   # landing chamber
r.open(64, 0, 66, 4)                                    # hole up to the hub
r.plat(59, 19, 2).island(62, 17, 6, 3).plat(58, 15, 3).plat(62, 13, 2).plat(66, 11, 2)
r.plat(62, 9, 2).plat(63, 7, 3)
r.solid(68, 5, 75, 8).solid(71, 9, 75, 11)             # the chamber's rough roof
r.tunnel(20, 53, 11).solid(54, 11, 57, 11)              # high tunnel and its ledge
r.tunnel(10, 53, 21)                                    # low tunnel
r.solid(44, 19, 46, 20).open(30, 21, 32, 22)            # a mound and a dip
r.open(12, 7, 30, 20)                                   # the Middle Chamber
r.solid(20, 19, 25, 20).island(12, 17, 7, 3).plat(21, 15, 3).island(25, 13, 6, 3)
r.secret(3, 13, 10, 16).fake(11, 13, 11, 16)            # the hidden nook
r.tunnel(0, 9, 21)
r.exit("up", "top", 64, 66, "c03_kiln_hall", "down")
r.exit("left", "left", 18, 20, "c06_keepers_forge", "right")
r.mark("relic", 5, 17)
r.mark("enemy", 40, 21, config="grunt").mark("enemy", 36, 21, config="skitter") \
 .mark("enemy", 22, 19, config="grunt").mark("enemy", 42, 11, config="grunt") \
 .mark("enemy", 70, 21, config="skitter")
rooms.append(r)

# C5 Glaze Bridge: the first gate, one room from the hub. A 4-cell gap with the far side
# a cell higher; the pit has a step back to the near side and is too deep to climb out
# to the far side. A relic sits on a big island over the far side: seen now, taken later.
r = Room("c05_glaze_bridge", "Glaze Bridge", 54, 22)
r.open(0, 2, 53, 13)
r.solid(24, 13, 53, 13)                                 # far side, a cell higher
r.open(20, 14, 23, 16).solid(20, 16, 20, 16)            # pit with a step
r.solid(0, 2, 0, 9).solid(53, 2, 53, 8)
r.solid(8, 2, 18, 4).solid(11, 5, 15, 5).solid(40, 2, 52, 3)   # the roof
r.plat(27, 11, 2).island(30, 9, 6, 3)
r.exit("left", "left", 10, 13, "c03_kiln_hall", "right")
r.exit("right", "right", 9, 12, "c08_brun_antechamber", "left")
r.mark("gate", 16, 14, ability="dash").mark("relic", 32, 9)
r.enter_from("left").expect(dash_only=["exit:right", "relic@32,9"])
rooms.append(r)

# C6 Keeper's Forge: the arena. A brute and two skitters on the floor, big islands up to
# the dash on the middle one.
r = Room("c06_keepers_forge", "Keeper's Forge", 40, 20)
r.open(1, 2, 38, 15)
r.open(0, 12, 0, 15).open(39, 12, 39, 15)
r.solid(1, 2, 12, 3).solid(27, 2, 38, 4)
r.plat(6, 14, 3).island(10, 12, 4, 2).island(15, 10, 8, 3).island(25, 12, 4, 2).plat(31, 14, 3)
r.exit("right", "right", 12, 15, "c04_cinder_run", "left")
r.exit("left", "left", 12, 15, "c07_bellows_climb", "low_right")
r.mark("enemy", 20, 16, config="brute").mark("enemy", 12, 16, config="skitter") \
 .mark("enemy", 28, 16, config="skitter")
r.mark("ability", 19, 10, ability="dash")
rooms.append(r)

# C7 Bellows Climb, the shortcut home: you come in at the bottom right (from the Keeper's
# Forge, moving left) and climb a switchback of six levels up through the rock. The top
# level runs right to a dash gap, then out to the hub's low left tunnel (moving right).
# From the hub side you can drop in and walk down.
r = Room("c07_bellows_climb", "Bellows Climb", 40, 40).cave(0)
r.tunnel(25, 39, 36)
r.switchback(3, 24, 36, 6, first_turn="left")
r.tunnel(25, 39, 11)                                    # the top level runs on to the right
r.open(27, 11, 30, 13).solid(27, 13, 27, 13)            # the pit, with a step
r.solid(31, 10, 39, 10).open(31, 7, 39, 9)              # far side, a cell higher
r.mark("gate", 33, 10, ability="dash")
r.mark("enemy", 12, 26, config="skitter").mark("enemy", 14, 16, config="grunt")
r.exit("low_right", "right", 33, 35, "c06_keepers_forge", "left")
r.exit("high_right", "right", 7, 9, "c03_kiln_hall", "low_left")
r.enter_from("low_right").expect(dash_only=["exit:high_right", "gate@33,10"])
rooms.append(r)

# C8 Brun's Antechamber: a rest before the boss door.
r = Room("c08_brun_antechamber", "Brun's Antechamber", 32, 14)
r.open(0, 2, 31, 9)
r.solid(0, 2, 0, 5).solid(31, 2, 31, 5).solid(6, 2, 25, 3)
r.exit("left", "left", 6, 9, "c05_glaze_bridge", "right")
r.exit("right", "right", 6, 9, "res://src/enemies/boss/boss_arena.tscn", "")
r.mark("rest", 12, 10)
rooms.append(r)

# C9 Ember Hoard: the hidden room at the top of the hub, a reward for climbing.
r = Room("c09_ember_hoard", "Ember Hoard", 24, 14).cave(0)
r.tunnel(0, 21, 11)
r.open(10, 3, 21, 7)
r.exit("left", "left", 8, 10, "c03_kiln_hall", "upper_right")
r.mark("relic", 16, 11).mark("enemy", 10, 11, config="skitter")
rooms.append(r)

# The Hollow Molt test room: Waking Niche's shapes drawn with the Hollow Molt art, to compare
# the two biomes on the same layout. No exits.
r = waking_niche_shapes(Room("hm01_molt_test", "The Hollow Molt (test)", 60, 34))
r.biome = "hollow_molt"
r.out_dir = "res://src/world/hollow_molt/rooms/"
r.solid(59, 17, 59, 19)                                 # no exit: close the tunnel's end
r.mark("start", 26, 30).mark("rest", 29, 30).mark("relic", 1, 20)
r.mark("enemy", 48, 20, config="grunt").mark("enemy", 46, 25, config="skitter")
rooms.append(r)

# Doors keep the player's direction: leaving left, you arrive on the next room's right
# side (moving left), and the next room's door leads back to this one.
OPPOSITE = {"left": "right", "right": "left", "top": "bottom", "bottom": "top"}
by_path = {ROOMS_DIR + r.key + ".tscn": r for r in rooms}
door_problems = []
for r in rooms:
    for e in r.exits:
        t = by_path.get(e["target"])
        if t is None:
            continue
        back = [x for x in t.exits if x["id"] == e["target_exit"]]
        if not back:
            door_problems.append("%s:%s leads to missing %s:%s" % (r.key, e["id"], t.key, e["target_exit"]))
            continue
        b = back[0]
        if b["side"] != OPPOSITE[e["side"]]:
            door_problems.append("%s:%s (%s side) opens onto %s:%s (%s side): direction flips"
                                 % (r.key, e["id"], e["side"], t.key, b["id"], b["side"]))
        if b["target"] != ROOMS_DIR + r.key + ".tscn" or b["target_exit"] != e["id"]:
            door_problems.append("%s:%s is not led back to by %s:%s" % (r.key, e["id"], t.key, b["id"]))

bad = bool(door_problems)
for p in door_problems:
    print("DOOR:", p)
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
