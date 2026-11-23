"""Cinderheart room layouts as text grids -> JSON for the Godot room builder.

'#' solid rock, '.' open. Each room lists exits (an edge opening and where it leads)
and markers (start, rest spots, enemies, ability pickups, gate signs), in cells.
Run: python3 tools/level/cinderheart_layout.py  (writes tools/level/cinderheart_rooms.json)
Then: godot --headless --path . -s res://tools/level/build_cinderheart_rooms.gd
"""
import json, os

ROOMS_DIR = "res://src/world/cinderheart/rooms/"


class Room:
    def __init__(self, key, name, w, h):
        self.key, self.name, self.w, self.h = key, name, w, h
        self.g = [["#"] * w for _ in range(h)]
        self.exits, self.markers = [], []

    def open(self, x0, y0, x1, y1):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.g[y][x] = "."
        return self

    def solid(self, x0, y0, x1, y1):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.g[y][x] = "#"
        return self

    def stairs(self, x0, surface0, step_w, steps, down=True, fill_to=None):
        """Solid stair steps from column x0, first surface row surface0, each step_w wide,
        going one row down (or up) per step; solid below each surface to fill_to."""
        bottom = fill_to if fill_to is not None else self.h - 1
        for i in range(steps):
            s = surface0 + (i if down else -i)
            self.solid(x0 + i * step_w, s, x0 + (i + 1) * step_w - 1, bottom)
        return self

    def exit(self, exit_id, side, a, b, target_room, target_exit):
        """side: left/right (a..b rows) or top/bottom (a..b columns)."""
        self.exits.append(dict(id=exit_id, side=side, a=a, b=b,
                               target=ROOMS_DIR + target_room + ".tscn" if not target_room.startswith("res://") else target_room,
                               target_exit=target_exit))
        return self

    def mark(self, kind, col, surface_row, **extra):
        self.markers.append(dict(kind=kind, col=col, row=surface_row, **extra))
        return self

    def check(self):
        for e in self.exits:
            for i in range(e["a"], e["b"] + 1):
                x, y = {"left": (0, i), "right": (self.w - 1, i), "top": (i, 0), "bottom": (i, self.h - 1)}[e["side"]]
                assert self.g[y][x] == ".", (self.key, e["id"], x, y)
        for m in self.markers:
            c, r = m["col"], m["row"]
            assert self.g[r][c] == "#" and self.g[r - 1][c] == ".", (self.key, m, "marker must stand on a surface")

    def dump(self):
        return dict(key=self.key, name=self.name, w=self.w, h=self.h,
                    rows=["".join(r) for r in self.g], exits=self.exits, markers=self.markers)


rooms = []

# C1 Waking Niche: the start. A quiet walk with a rest spot, small steps, a shallow dip.
r = Room("c01_waking_niche", "Waking Niche", 34, 12)
r.open(1, 2, 32, 8)
r.solid(12, 8, 15, 8).solid(16, 7, 20, 8)
r.open(25, 9, 27, 9)
r.open(33, 5, 33, 8)
r.exit("right", "right", 5, 8, "c02_ash_steps", "left")
r.mark("start", 4, 9).mark("rest", 6, 9)
rooms.append(r)

# C2 Ash Steps: a long stair descent; the first enemies, met one at a time on landings.
r = Room("c02_ash_steps", "Ash Steps", 36, 20)
r.open(0, 2, 34, 17)
r.solid(0, 6, 5, 19)
r.stairs(6, 7, 2, 10)
r.solid(26, 16, 35, 19)
r.open(35, 12, 35, 15)
r.solid(10, 2, 35, 3).solid(18, 4, 35, 6).solid(28, 7, 35, 9)
r.exit("left", "left", 2, 5, "c01_waking_niche", "right")
r.exit("right", "right", 12, 15, "c03_kiln_hall", "high_left")
r.mark("enemy", 14, 11, config="grunt").mark("enemy", 30, 16, config="grunt")
rooms.append(r)

# C3 Kiln Hall: the hub and its rest spot. You drop in from a high shelf you can't climb
# back to; a hole in the floor leads down to the Cinder Run; the right exit is the dash
# bridge (seen early, crossed late); the low left exit is the far end of the shortcut.
r = Room("c03_kiln_hall", "Kiln Hall", 48, 16)
r.open(0, 2, 47, 12)
r.solid(0, 6, 9, 6)
r.solid(0, 2, 0, 2)
r.solid(18, 12, 29, 12).solid(20, 11, 27, 11).solid(22, 10, 25, 10)
r.solid(47, 2, 47, 9)
r.open(14, 13, 16, 15)
r.solid(0, 7, 0, 9)
r.exit("high_left", "left", 3, 5, "c02_ash_steps", "right")
r.exit("low_left", "left", 10, 12, "c07_bellows_climb", "high_right")
r.exit("down", "bottom", 14, 16, "c04_cinder_run", "up")
r.exit("right", "right", 10, 12, "c05_glaze_bridge", "left")
r.mark("rest", 34, 13).mark("start", 4, 6)
rooms.append(r)

# C4 Cinder Run: the combat corridor. Grunts and skitters across low steps and shallow
# dips. You land on a ledge from the hub's floor hole; stairs climb back to it.
r = Room("c04_cinder_run", "Cinder Run", 56, 12)
r.open(1, 1, 54, 8)
r.open(49, 0, 51, 0)
r.stairs(41, 8, 1, 6, down=False, fill_to=8)
r.solid(46, 3, 54, 8)
r.open(30, 9, 32, 9).open(18, 9, 19, 9)
r.solid(8, 8, 12, 8).solid(23, 8, 26, 8)
r.open(0, 6, 0, 8)
r.exit("up", "top", 49, 51, "c03_kiln_hall", "down")
r.exit("left", "left", 6, 8, "c06_keepers_forge", "right")
r.mark("enemy", 36, 9, config="grunt").mark("enemy", 27, 9, config="skitter") \
 .mark("enemy", 14, 9, config="grunt").mark("enemy", 5, 9, config="skitter")
rooms.append(r)

# C5 Glaze Bridge: the first gate, seen from the hub. A four-cell gap over a pit; a run
# jump falls short, the dash clears it. The pit has stairs back up to the near side.
r = Room("c05_glaze_bridge", "Glaze Bridge", 40, 14)
r.open(0, 4, 39, 10)
r.open(16, 11, 19, 11)
r.solid(20, 10, 39, 10)
r.solid(0, 4, 0, 7).solid(39, 4, 39, 6)
r.exit("left", "left", 8, 10, "c03_kiln_hall", "right")
r.exit("right", "right", 7, 9, "c08_brun_antechamber", "left")
r.mark("gate", 13, 11, ability="dash")
rooms.append(r)

# C6 Keeper's Forge: the mini-boss stand-in (a brute and two skitters) guarding the dash.
r = Room("c06_keepers_forge", "Keeper's Forge", 28, 12)
r.open(1, 2, 26, 8)
r.open(27, 6, 27, 8).open(0, 6, 0, 8)
r.exit("right", "right", 6, 8, "c04_cinder_run", "left")
r.exit("left", "left", 6, 8, "c07_bellows_climb", "low_left")
r.mark("enemy", 16, 9, config="brute").mark("enemy", 20, 9, config="skitter").mark("enemy", 11, 9, config="skitter")
r.mark("ability", 8, 9, ability="dash")
rooms.append(r)

# C7 Bellows Climb: the shortcut home. Stairs up and a dash gap: use the new ability at
# once, and come out in the hub's lower left.
r = Room("c07_bellows_climb", "Bellows Climb", 34, 14)
r.open(0, 2, 33, 11)
r.solid(4, 11, 5, 11).solid(6, 10, 7, 11).solid(8, 9, 9, 11).solid(10, 8, 11, 11)
r.solid(12, 7, 16, 11)
r.solid(17, 8, 20, 11)
r.solid(21, 6, 33, 11)
r.solid(0, 2, 0, 8).solid(33, 2, 33, 2)
r.mark("gate", 24, 6, ability="dash")
r.exit("low_left", "left", 9, 11, "c06_keepers_forge", "left")
r.exit("high_right", "right", 3, 5, "c03_kiln_hall", "low_left")
rooms.append(r)

# C8 Brun's Antechamber: a rest spot before the boss door.
r = Room("c08_brun_antechamber", "Brun's Antechamber", 24, 12)
r.open(0, 2, 23, 8)
r.solid(0, 2, 0, 5).solid(23, 2, 23, 5)
r.exit("left", "left", 6, 8, "c05_glaze_bridge", "right")
r.exit("right", "right", 6, 8, "res://src/enemies/boss/boss_arena.tscn", "")
r.mark("rest", 10, 9)
rooms.append(r)

for r in rooms:
    r.check()
out = os.path.join(os.path.dirname(__file__), "cinderheart_rooms.json")
json.dump([r.dump() for r in rooms], open(out, "w"), indent=1)
for r in rooms:
    print(r.key, r.w, "x", r.h)
    for row in r.g:
        print("  " + "".join(row))
