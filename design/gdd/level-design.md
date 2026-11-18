# Level design and world layout

> **Status**: In Design
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-18
> **Last Verified**: 2026-11-18
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room"; loop: fight, gain a verb, open the world, fight again)

## Summary

[To be designed]

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rooms and transitions, Terrain pipeline, Ability gating, Bosses, Enemies, World state`

## Overview

Level design and world layout decides the shape of the Seeker's world: how rooms group into regions, how regions connect, which route each earned ability opens, where each ability is found, and where saves, shortcuts, bosses and secrets sit. It is the design layer over four systems that supply the pieces (rooms and transitions, the terrain pipeline, ability gating, world state): they say what a room, a wall or a gate *is*; this system says what the player meets, in what order, and why they come back. The player never operates it directly. They feel it as a world that rewards curiosity: they read a room, notice a ledge, a wall or a gap they cannot yet cross, remember it, and return later with the verb that opens it.

The core loop (fight, gain a verb, open the world, fight again) only works if the world is built to carry it. The Seeker starts with only run, jump and attack; dash, double jump, wall cling and grapple, then the bow and spell casts, are earned in the world, so every early room is also a promise about a later one. Exploration and curiosity come first: the world is large masses of floor and a few floating islands on several levels, not rows of platforms, and every ability is found through a boss, a place worth finding, or a mentor, never in front of its own gate. There is no "region cleared" screen; the world just continues. The brief's scope is one region, built so more can follow.

## Detailed Design

### Core Rules

Tags: **[Owner]** = your stated rule; **[Sourced]** = backed by the research (`design/research/metroidvania-world-design.md`); **[Rec]** = recommendation, change freely; **[Calc]** = computed from `player_config.tres`, re-measure in `movement_test_room`.

**World model**

1. The world is a graph of **rooms**. A room is a whole number of 480x270 screens (1x1 connector, 1x3-4 shaft, 3-4x1 hall, rare set piece up to about 8 screens). Rooms group into **regions**; a region has one identity (palette, enemies, architecture, music), one boss at its apex and at least one save point. **[Rec]**
2. The core build is **one region** (brief scope), built so more regions can attach at its edges. Its gates for keys the region itself does not give are real and visible; they open when later regions exist. **[Rec, provisional]**
3. Rooms are authored on a grey-box first: collision only, no art, played and approved before any tile or painting is added. **[Sourced]** (Ori's "design approved" gate)

**Start state and key order**

4. The Seeker starts with: run, jump, the whole sword set (3-hit combo, up and down attacks, pogo, charged heavy), crouch, doors. **[Owner]**
5. Keys are earned in this order. Nothing in the start kit may open any gate in the table. **[Owner for order; the gate and source columns are Rec]**

| # | Key | Opens (gate signature) | Found by | Why here |
|---|-----|------------------------|----------|----------|
| 1 | Dash | Gaps wider than about 90 px; dash-through barriers | Keeper (the region's boss) | Horizontal key first in every benchmark; seen as an uncrossable gap in the first minutes |
| 2 | Wall cling (wall slide, wall jump, climb) | Tall shafts and walls with a cling surface | Shrine, found by exploring | Opens the vertical world; walls are ladders once it exists, so it is earned before the double jump |
| 3 | Double jump | Ledges 72-108 px up in open air | Mentor / hub pact (or a second shrine, if the lore has no mentor) | The mid-game hinge: where the map opens to three or four valid directions |
| 4 | Grapple | Authored anchors only (> 120 px up or > 200 px apart) | Keeper (a later boss) | Opens only the locks you place, so it is the safe late key; later grows into grapple-to-enemy |

6. The bow and the spell casts are not movement keys and gate nothing in the core build; they are earned later (Alpha). **[Owner]**
7. Every key opens few locks, has one visual signature that nothing else in the world uses, and changes combat as well as movement (dash: dodge and gap-close; wall cling: wall-based attack angles; double jump: second air window; grapple: pull and fling). **[Sourced]** (Metroid Dread: few locks per key; one material per key)

**Showing the lock, placing the key**

8. A gate is **seen before its key is found**, at least twice, the first time within the first 10 minutes of play for the dash gate. **[Owner for the principle; counts Rec]**
9. A key is never found in the same room as its first gate, nor within 3 rooms of it, and never in a room that can be reached only by the key itself. **[Owner for "never in front of the gate"; numbers Rec]**
10. Every key is found by exactly one of the three channels, named by the pickup: boss (a Keeper), shrine / relic pedestal (exploration), or mentor / hub pact (narrative). A pickup does not care which; gating only reads "owned". **[Owner]**
11. After each key, the next room is a **learning workshop**: a one-room exit that uses the new key on a smaller instance of a lock the player has already seen. The player can always leave again; the workshop is a short test, not a trap. **[Sourced]** (Lost Crown, sandbox escape)
12. Soft gates are allowed and not hunted down: a skilled player who gets past a gate early with the current kit is rewarded, as long as the world stays coherent (no soft-lock, no missed boss trigger). **[Sourced]**

**Topology**

13. The first region is a **funnel**: one objective at a time for the first 5-10 rooms, then a fork to two or three directions. Late in the game, openness rises to three or four valid directions. **[Sourced]** (Silksong acts; Team Cherry)
14. Rooms form **loops**, not trees: every region has at least one shortcut that folds back to a save point (one-way door, breakable wall, lever, lift or drop). Shortcut gates open from the far side first. **[Sourced]** (shortcut folding; Blasphemous found one-use levers overused, so mix breakable walls and doors)
15. A save point is placed before every boss, and a route from that save to the boss room never exceeds 7 screens. A boss room is always next to a shortcut back. **[Sourced]** (Blasphemous, Ender Lilies)
16. No more than 7 screens of travel between two save points on the main route. **[Sourced]** (Blasphemous)

**Room composition**

17. A room is a place first ("a flooded cavern, a ruined tower stair"), then a layout. Floors and mass terrain carry the room; floating islands are allowed; free-standing platforms are rare and only where a gate needs them. No room has more than 3 free-standing platforms unless it is a designated platforming room. **[Owner for the principle; limit Rec]**
18. Every room has a job: connector, shaft, combat room, platforming challenge, hub, save, secret or boss antechamber. A room that does none of them is cut. **[Rec]**
19. A secret follows a pattern the game has already shown (a cracked wall, an off-screen ledge, a dead end with something just out of sight), and a dead end without a secret is cut. **[Sourced]** (Animal Well: break from the pattern; Dread: hidden blocks on the main path always have a hint)
20. Only bosses and mini-bosses carry a guard. The core region has one boss and one mini-boss. Normal enemies have health only. **[Owner]**
21. There is no "region cleared" screen, banner or lock-out. A beaten boss opens doors and changes the world quietly. **[Owner]**

**Backtracking and flow**

22. Each key makes at least two old rooms faster to cross in a new way (friction becomes flow), and at least one of them is a room the player skipped or could not finish before. **[Sourced]** (re-contextualized geometry)
23. The grid map shows rooms as boxes and exits as lines; an unexplored exit shows as a marker, and the map does not mark item locations. A key that makes exploration trivial is never taxed; it is moved later. **[Sourced]** (Ender Lilies, Dread)


### States and Transitions

World state is held by the **world state** system; this system defines what the states mean and what changes them.

| Thing | States | Transition and trigger |
|-------|--------|------------------------|
| Key | Unobtained, Obtained | Unobtained to Obtained when the pickup is collected (boss reward, shrine or mentor). Never reverts. |
| Gate | Unseen, Seen, Passable, Passed | Unseen to Seen the first time it is on screen. Seen to Passable when its key is Obtained. Passable to Passed the first time the player crosses it. |
| Shortcut | Closed, Open | Closed to Open when the player triggers it from the far side. Never closes again. |
| Boss | Undefeated, Defeated | Undefeated to Defeated on boss death; the flag persists (existing `boss_defeated`). Opens any doors and rewards tied to it. |
| Region | Unvisited, Entered | Unvisited to Entered on first room entry. No "cleared" state is shown to the player. |
| Secret | Hidden, Found | Hidden to Found when revealed; recorded for the map and for any count. |
| Room | Unvisited, Visited | Visited on first entry; drives the grid map. |

No state in this table can move backward.


### Interactions with Other Systems

None of the upstream systems has a GDD yet; the interfaces below are the contract this system expects and are **provisional** until each is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Rooms and transitions | In | Room units, exits, doors, per-room camera limits, room graph | Rooms and transitions |
| Terrain pipeline | In | Collision and tile rules a room is built from; the grey-box to painted path | Terrain pipeline |
| Ability gating | Both | In: gate types, dimensions and visual signatures. Out: which gate sits where and what key it needs | Gating owns types and sizes; this system owns placement and order |
| Bosses | In | Boss rooms, defeat flag, what the boss grants | Bosses |
| Enemies | In | Enemy types and rosters placed in rooms | Enemies |
| World state | Both | Out: keys obtained, bosses defeated, shortcuts opened, secrets found. In: reads for gate state | World state |
| Save points | Out | Save locations and the 7-screen spacing rule | Save points |
| Grid map | Out | Room graph, exits, unexplored markers | Grid map |
| Fast travel (later) | Out | Which rooms may be travel points | Fast travel |
| Collectible upgrades (later) | Out | Where reward rooms sit and how many | Collectible upgrades |
| Lore and mentor (later) | Out | Where the mentor hub and lore sit | Lore delivery |


## Formulas

All Seeker figures are **[Calc]** from `src/player/player_config.tres` at 60 Hz, worked out in the research report. They ignore coyote time, corner correction and ledge nudge, so re-measure in `movement_test_room` before any gate is built. Margins and spacing values are `data file` knobs, not constants.

### F1. Dash gap window

The dash_gap formula is defined as:

`gap_min = run_jump_distance + gap_margin`; `gap_max = dash_jump_distance - gap_margin`; a dash gap of width W is valid when `gap_min <= W <= gap_max`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| run_jump_distance | float (px) | about 105 | calculated from player_config | Farthest a running jump crosses without dash |
| dash_jump_distance | float (px) | about 165 | calculated from player_config | Farthest a dash-jump crosses |
| gap_margin | float (px) | 8-20 | data file | Keeps a perfect jump from leaking through and the dash from missing |
| W | float (px) | gap_min to gap_max | data file (room data) | Width of the gap |

**Output Range:** 120 to 150 px at margin 15; at margin 0 a perfect jump leaks through at 105 px; above about 30 px the window closes.
**Example:** a 135 px gap needs the dash and the dash clears it.

### F2. Double-jump ledge window

The double_jump_ledge formula is defined as:

`ledge_min = jump_apex + ledge_margin_low`; `ledge_max = double_jump_total - ledge_margin_high`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| jump_apex | float (px) | about 60 (59-62) | calculated from player_config | Single jump height |
| double_jump_total | float (px) | about 115 | calculated from player_config | Jump plus double jump height |
| ledge_margin_low | float (px) | 8-16 | data file | Stops a plain jump clipping the edge |
| ledge_margin_high | float (px) | 5-12 | data file | Lets the double jump clear the edge reliably |

**Output Range:** 72 to 108 px at margins 12 and 7. Valid only in open air: wall cling is owned by then, so a wall within wall-jump reach makes the ledge a ladder.
**Example:** a ledge 90 px above the floor in open air needs the double jump.

### F3. Grapple gate

The grapple_gate rule is defined as:

`target_height >= double_jump_total + grapple_margin`, with an anchor within `grapple_range` of a standing point.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| target_height | float (px) | 121 or more | data file (room data) | Height of the ledge above the standing floor |
| grapple_range | float (px) | 200 | data file (player_config) | Farthest anchor the grapple reaches |
| grapple_margin | float (px) | 6-20 | data file | Keeps the double jump from reaching the target |

**Output Range:** targets 121+ px up with an anchor within 200 px.
**Example:** a ledge 160 px up with an anchor 24 px beyond its edge.

### F4. Save spacing

The save_spacing rule is defined as:

`route_screens(save_a, save_b) <= save_spacing_max` for adjacent saves on the main route; a room of more than one screen counts as that many screens.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| route_screens | int | 1 to save_spacing_max | calculated from the room graph | Screens on the main route between two saves |
| save_spacing_max | int | 5-10 | data file | Upper bound; starts at 7 (Blasphemous), tuned in playtest |

**Output Range:** at most 7 screens. A 480 px screen crosses in about 3.4 s at 140 px/s, so 7 screens is about 24 s of pure running and roughly 2-4 minutes with fights and platforming.
**Example:** save, 2-screen hall, 1x3 shaft, 1-screen combat room, boss antechamber: 7 screens, valid.
**Edge:** 0 is undefined; oversized rooms count by screen, not as one.

### F5. Flow speed-up

The flow_speedup formula is defined as:

`speedup = 1 - t_with_key / t_without_key`; rule 22 requires `speedup >= speedup_min` on at least two old routes per key.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_without_key | float (s) | greater than 0 | calculated from route length and player_config | Crossing time before the key |
| t_with_key | float (s) | greater than 0 | calculated from route length and player_config | Crossing time after the key |
| speedup_min | float | 0.2-0.5 | data file | Required improvement; starts at 0.3 |

**Output Range:** 0 to under 1; negative means the key slows the route and fails the rule.
**Example:** dash on a 3-screen hall (1440 px): 10.3 s at 140 px/s; a dash cycle (0.25 s dash, 0.3 s cooldown) averages about 245 px/s, 5.9 s; speedup 0.43. Approximate: ignores dash_end_speed_keep.
**Edge:** a route of length 0 is excluded.

**Feedback loops:** keys make old rooms faster, which makes revisiting cheaper and encourages exploring; intended, bounded by shortcuts and enemy respawns. A later key leaking into an earlier gate (double jump over a dash gap) is also intended.

**Registry candidates (not owned here):** run_jump_distance, dash_jump_distance, double_jump_total, jump_apex belong in the movement GDD when it exists.


## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Visual/Audio Requirements

[To be designed]

## Game Feel

[To be designed]

## UI Requirements

[To be designed]

## Cross-References

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
