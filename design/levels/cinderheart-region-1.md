# Cinderheart (region 1)

Status: second layout, 2026-11-23. Layouts live in `tools/level/cinderheart_layout.py` and
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

## Movement the layout is built on (measured in game, `tools/level/measure_jump.gd`)

A cell is 36 px. `jump_speed` is now 420 (was 330): a jump rises 96 px, so **2-cell
climbs** are possible and rooms can go up. A run jump crosses a 3-cell gap; the dash jump
crosses 4. Dash gates are 4-cell gaps whose far side is a cell higher, over a pit you
can climb back out of on the near side only.

## The map

```
 [C1 Waking Niche] ─► [C2 Ash Steps] ───(one-way drop onto a high shelf)──┐
  start, rest,          high road over a great rock,                       ▼
  secret wall, climb    low cave under it, relic on islands    [C3 KILN HALL] ─► [C9 Ember Hoard]
                                                                HUB, rest       hidden, relic
 [C7 Bellows Climb] ──(dash gap)──────────────────────────────► low left        (island climb)
  tall shaft, shortcut home                                         │ floor hole      │ right
        ▲                                                           ▼                 ▼
 [C6 Keeper's Forge] ◄────────────────────────────── [C4 Cinder Run]   [C5 Glaze Bridge] ─► [C8 Antechamber] ─► Boss
  arena, DASH on a high island                         low road + island     DASH GATE, relic    rest
                                                       road, secret wall     seen from the near side
```

Intended first run: wake (C1), climb out, descend Ash Steps (high or low road), drop
into the hub. Choices: try the bridge (blocked), climb the hub's islands to the hidden
room, or go down the floor hole. Cinder Run → Keeper's Forge (win the dash on its high
island) → Bellows Climb (zig-zag up, dash the gap) → the hub's lower left: the loop is
closed. Cross the bridge, take its relic, rest, boss.

Relics (Ember Hearts, +10 max health each): C1 behind the wall at the start, C2 on the
island climb over the great rock, C4 behind the fake wall at the end of the upper road,
C5 over the bridge (after the dash), C9 in the hidden room.

## Not built yet

Keeper Tavik is a brute and two skitters; the boss door leads to the old test arena. No
map screen, no saving, no breakable walls or levers, no deadly pits.
