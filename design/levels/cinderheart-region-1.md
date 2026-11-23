# Cinderheart (region 1)

Status: third layout (ant farm), 2026-11-23. Layouts live in `tools/level/cinderheart_layout.py` and
are checked by `tools/level/reach.py`; the built rooms are
`src/world/cinderheart/rooms/*.tscn` and can be edited in Godot (paint the Layout layer:
the rock brush, or the purple fake-wall brush for secret passages).

## How metroidvanias build levels (what we took, from research)

- **No pass-through platforms; the terrain is the puzzle.** Hollow Knight's platforms are
  all solid, so a room's route has to be read and climbed, and heights you can't reach
  yet are gates. ([Ludonauta](https://ludonauta.itch.io/platformer-essentials/devlog/1084669/the-hidden-genius-behind-hollow-knights-terrain-design))
- **Spatial memory: show it before you can get it.** A room has a path open on the first
  visit and gated paths you can see; you come back with the ability.
  ([Game Dev Bootcamp](https://seanking11.github.io/gamebootcamp/modules/14-metroidvania))
- **Two or three ways forward after the start**, not a corridor; backtracking needs a
  reason. ([Bycer](https://www.gamedeveloper.com/design/making-sense-of-metroidvania-game-design))
- **Secrets of two kinds:** hard-to-reach spots that need no ability, and areas behind a
  gate you return to. ([Bycer](https://www.gamedeveloper.com/design/the-foundation-of-metroidvania-design))
- **Shortcuts that open from one side, bosses near a shortcut home, checkpoints never
  more than about seven screens apart.** ([Blasphemous, Game Developer](https://gamedeveloper.com/design/how-i-blasphemous-i-level-design-iterates-on-classic-metroidvanias))
- **Halls and shafts that compound into loops** (Super Metroid, Symphony of the Night).
- **World first, by intuition, then iterate on play** (Team Cherry, via
  [Game Developer](https://gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-)).

## Ant farm, beehive, switchbacks (third layout, 2026-11-23)

The second layout was big open boxes with islands floating in them: rooms with no
structure. The third is built the other way round, like an ant farm seen in cross
section: **every room starts as solid rock and is carved**:

- **Chambers** (open caverns, the far city behind) and **tunnels** (cave sections, the
  close rock wall behind: `cave_from_col`) at different depths.
- **Beehive connections:** each chamber joins two or three others, so there's more than
  one way through a room (Waking Niche's window into its switchback, Cinder Run's high and
  low tunnels joined by the Middle Chamber, Ash Steps' high road and low road).
- **The big islands are the rock left between passages**, not boxes floating in air.
  Small floating platforms sit between them where a climb needs a step.
- **Switchbacks:** stacked tunnels climbed in a zig-zag. Run to the end, hop up through a
  gap in the slab (a 2-cell step, then a ledge), run back the other way a level higher
  (Waking Niche, Bellows Climb).

Every room renders through the art-style test room's full pipeline (`RegionRoom` extends
it): far city and ruins, close rock and plant bands, the cave's close rear wall, the porous
rock rim and textured wall fill, and the mood pass.

**Foreground in carved rooms.** The art room's foreground is two screen-height loops (the
rock ceiling across the top of the screen, the near rocks across the bottom) and a foliage
band locked to the screen's bottom. That fits a room one screen tall with one ceiling and
one floor; in a tall carved room it floats with the camera. Here the same art is anchored
to the terrain instead: every ceiling over a space at least 4 cells tall gets the rock
overhang hanging from it, every cavern floor on deep rock gets the near rocks over the rock
under it and the black foliage standing on it. All of it is fixed to the terrain up and
down, scrolls sideways at the art room's 1.2, is sized to the space it sits in, and fades
on every edge that lands inside rock.

**Doors keep your direction.** Leave a room moving left and you arrive on the next room's
right side, still moving left (up through a ceiling hole, you arrive in the next room's
floor hole). `cinderheart_layout.py` checks every door pair and fails on one that flips.

**Secrets are hidden until found.** A fake wall and the room behind it (the green brush in
the editor) are covered in the game by painted rock that matches the walls around it: the
rock's edge, the textured fill, nothing behind it showing. Step into the fake wall and the
cover fades out for the rest of the run.

**Floating islands** get no textured wall fill. Their own edge is drawn again just inside
them, twice, darker each time (where the island is thick enough), so each reads as a
slightly smaller island inside itself; foliage grows on their tops.

**Bottom foreground**: the near rocks and plants sit along each whole stretch of floor
(not broken up where islands change the ceiling height above it), rising a little in front
of the floor line as in the art room.

**Exits are lit**: a warm light in each exit's opening, so the way on reads from across the
room. Waking Niche's exit is at the end of its third level, reached two ways: climb the
cavern's islands to the window, or take the low tunnel up the switchback.

## Movement the layout is built on (measured in game, `tools/level/measure_jump.gd`)

A cell is 36 px. `jump_speed` is 420: a jump rises 96 px, so **2-cell climbs** are possible.
A run jump crosses a 3-cell gap; the dash jump crosses 4. Dash gates are 4-cell gaps whose
far side is a cell higher, over a pit you can climb back out of on the near side only.

## The map

Room layouts as pictures: `production/qa/evidence/cinderheart/layout-*.png` (tan open
cavern, grey cave section, purple fake wall, blue exits, green rest, red enemies, pink
relics, yellow ability, green secret rooms).

```
 [C1 Waking Niche] ─► [C2 Ash Steps] ───(one-way drop onto an island)───┐
  cavern + 5-level      the Ash Well (deep cavern),                      ▼
  switchback, secret    high road / low road, relic    [C3 KILN HALL] ─► [C9 Ember Hoard]
                                                        HUB, rest        hidden, relic
 [C7 Bellows Climb] ──(dash gap)──────────────────────► low left tunnel   (island climb)
  6-level switchback, shortcut home                        │ floor hole      │ right
        ▲                                                  ▼                 ▼
 [C6 Keeper's Forge] ◄──────────────────────── [C4 Cinder Run]    [C5 Glaze Bridge] ─► [C8 Antechamber] ─► Boss
  arena, DASH on the middle island               landing chamber,       DASH GATE, relic    rest
                                                 high + low tunnels,    seen from the near side
                                                 Middle Chamber, secret
```

Relics (Ember Hearts, +10 max health each): C1 behind the fake wall off the cavern's high
ledge, C2 at the far end of the high road, C4 behind the fake wall in the Middle Chamber,
C5 on the island over the bridge (after the dash), C9 in the hidden room.

## Not built yet

Keeper Tavik is a brute and two skitters; the boss door leads to the old test arena. No
map screen, no saving, no breakable walls or levers, no deadly pits.
