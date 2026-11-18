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

`systems-designer` not consulted: Lean mode. Review manually before production.

- **If a player passes a gate early with the current kit** (a perfect jump over a dash gap, a wall-jump over a shaft): allow it. The room beyond must still make sense with any kit the player owns, and no rule may assume a key order the player was never forced into (rule 12).
- **If a player reaches a key's location before its intended order** (the wall cling shrine reached without the dash): the key is granted normally. Later gates stay valid because gates read only "owned", never "owned in order".
- **If the player is in a one-way drop, a pit or a secret room**: there is always a return path to the previous room with the kit they had when they entered. A drop that returns only with a later key is cut.
- **If the player dies after collecting a key but before reaching a save point**: the key is saved at pickup and stays owned. Dying cannot take a key away. (World state and save points own the write; this is the requirement on them.)
- **If the player dies in a boss room**: respawn at the save point before it (rule 15). The boss is undefeated until its flag is set; its reward pickup stays in the room until collected.
- **If a boss is defeated but its reward is not collected before the player leaves**: the pickup stays in the room, visible and collectible on return, and the boss stays defeated.
- **If a shortcut is approached from its near side**: it shows as blocked and does not open; it opens only from the far side, then stays open (states table).
- **If a dash gap sits near the top of its window and the player misses**: they fall to a safe floor with no fall damage and an unbroken way back. A gap whose floor below is a hazard needs a return ledge.
- **If a room has no job (rule 18) or a dead end has no secret (rule 19)**: it is cut at the grey-box review, not shipped.
- **If a double-jump ledge has a wall within wall-jump reach** (wall cling is owned by then): the wall is a ladder and the gate leaks. The room is rebuilt in open air or the wall gets a non-cling surface.
- **If the player owns all four keys and a route's speedup is below the minimum** (F5): the route is redesigned or marked as not part of the key's two-route promise; it is not left as a tiresome back-track.
- **If save spacing would exceed 7 screens on the main route** (F4): add a save or a shortcut. The rule never counts rooms of more than one screen as one.
- **If a mini-boss or boss room locks behind the player**: the player always has a way out by winning or dying; a locked arena never traps without a respawn.


## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Rooms and transitions | Hard | Room units, exits, doors, per-room camera limits, the room graph | No (provisional) |
| Terrain pipeline | Hard | The collision and tile rules every room is built from; the grey-box path | No (provisional) |
| Ability gating | Hard | Gate types, dimensions and visual signatures; the "owned" read | No (code exists: `PlayerState`, `AbilityGate`, `AbilityPickup`; needs dash and wall cling flags) |
| World state | Hard | Records of keys, boss defeats, shortcuts and secrets | No (provisional) |
| Bosses | Hard | Boss rooms, the defeat flag, the reward source | No (code exists: `Boss`, `boss_arena`) |
| Enemies | Soft | Enemy types to place in rooms | No (code exists: three types) |
| Player controller | Soft | Movement values behind F1-F3 and F5 (`player_config.tres`) | No (code exists) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Save points and save/load | Hard | Save locations and the spacing rule (F4) |
| Grid map | Hard | Room graph, exits, unexplored markers |
| Collectible upgrades | Soft | Where reward rooms sit |
| Fast travel | Soft | Which rooms may be travel points |
| Lore delivery and mentor/hub pact | Soft | Where the mentor hub and lore sit |
| Elemental palette power-ups | Soft | Gate materials per element |

**Bidirectional check:** none of the other GDDs exists, so each needs a matching entry when it is designed. Ability gating and level design are circular by design (see the systems index); the contract is: gating owns gate types and sizes, level design owns placement and order.


## Visual/Audio Requirements

[To be designed]

## Game Feel

[To be designed]

## UI Requirements

[To be designed]

## Cross-References

[To be designed]

## Acceptance Criteria

Types: **[Auto]** automated test on room data or the room graph; **[Play]** playtest record; **[Shot]** retained screenshot in `production/qa/evidence/`. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. `qa-lead` not consulted: Lean mode; the checks in `references/lens-qa-lead.md` were applied by the author.

**Start state and keys**
- **GIVEN** a new game, **WHEN** the Seeker loads in the first room, **THEN** the player owns run, jump, the full sword set, crouch and doors, and owns none of dash, wall cling, double jump, grapple, bow or spells. **[Auto]** (rule 4, 6)
- **GIVEN** the start kit only, **WHEN** a tester tries every dash gap, wall-cling shaft, double-jump ledge and grapple target in the region by any means in the kit, **THEN** each one is blocked, except those logged as deliberate soft gates. **[Play]** (rule 5, 12)
- **GIVEN** each key in turn, **WHEN** it is collected, **THEN** the gate matching its signature becomes passable, and no gate of another key's signature changes. **[Auto]** (rule 7)
- **GIVEN** the key table, **WHEN** the map is read, **THEN** each key's pickup names exactly one channel (boss, shrine or mentor). **[Auto]** (rule 10)

**Showing the lock, placing the key**
- **GIVEN** a new game, **WHEN** a tester plays the first 10 minutes without a guide, **THEN** they pass at least one dash gap they cannot cross and can say where it is. **[Play]** (rule 8)
- **GIVEN** the room graph, **WHEN** the shortest path from each key's first gate room to its pickup room is measured ignoring locks, **THEN** it is 3 rooms or more, and the pickup room is not entered through its own gate. **[Auto]** (rule 9)
- **GIVEN** a key was just collected, **WHEN** the player leaves the pickup room, **THEN** the next room is a workshop that uses the key on one smaller lock of a type seen before, and the player can walk back out of it. **[Play]** (rule 11)

**Topology**
- **GIVEN** the first region, **WHEN** its room graph is built, **THEN** it contains at least one loop and at least one shortcut that returns to a save point, and no room is reachable only by a path that cannot be left again. **[Auto]** (rules 14, edge case "return path")
- **GIVEN** the main route, **WHEN** screens between each pair of adjacent saves are counted, **THEN** none exceeds `save_spacing_max` (7), and a save exists before every boss. **[Auto]** (F4, rules 15, 16)
- **GIVEN** each boss room, **WHEN** it is entered from the save before it, **THEN** a shortcut back is within one room of the boss room. **[Auto]** (rule 15)
- **GIVEN** a region at its first visit, **WHEN** the player is in the first 5-10 rooms, **THEN** only one objective is open; afterwards at least two directions are open. **[Play]** (rule 13)

**Formulas**
- **GIVEN** a dash gap of width W, **WHEN** the room data is checked, **THEN** `gap_min <= W <= gap_max`; a gap at `gap_min - 1` is rejected, and a gap at `gap_max + 1` is rejected. **[Auto]** (F1, boundary)
- **GIVEN** a double-jump ledge of height h in open air, **WHEN** checked, **THEN** `ledge_min <= h <= ledge_max`, and no cling surface lies within wall-jump reach. **[Auto]** (F2)
- **GIVEN** a grapple gate, **WHEN** checked, **THEN** `target_height >= double_jump_total + grapple_margin` and an anchor lies within 200 px of a standing spot; a ledge 120 px up is rejected. **[Auto]** (F3, boundary)
- **GIVEN** the movement values in `player_config.tres`, **WHEN** the Seeker attempts F1-F3 gates in `movement_test_room`, **THEN** a perfect run-jump never crosses a dash gap, a plain jump never touches a double-jump ledge, and the double jump never reaches a grapple target. **[Play]** (re-measure the [Calc] figures)
- **GIVEN** a key and its two promised routes, **WHEN** each is timed with and without the key, **THEN** `speedup >= 0.3` on both, and a route with speedup below 0 is flagged. **[Play]** (F5, rule 22)

**Room composition**
- **GIVEN** each shipped room, **WHEN** the grey-box review is run, **THEN** the room has a named job, no more than 3 free-standing platforms unless it is a platforming room, and a dead end carries a secret. **[Auto + Play]** (rules 17-19)
- **GIVEN** the region, **WHEN** it is searched, **THEN** exactly one boss and one mini-boss carry a guard meter, and no normal enemy does. **[Auto]** (rule 20)
- **GIVEN** the boss is defeated, **WHEN** the player leaves the arena, **THEN** no "cleared" banner or screen appears and play continues in the world. **[Shot]** (rule 21)

**Cross-system**
- **GIVEN** a key collected and the player dying before the next save, **WHEN** the game reloads, **THEN** the key is still owned and its pickup is gone. **[Auto + Play]** (edge case; depends on world state and save points)
- **GIVEN** the map, **WHEN** a room is visited, **THEN** it appears as a box with exits as lines, unexplored exits marked, and no item locations shown. **[Shot]** (rule 23; depends on the grid map)

**Gaps found by the QA checks:** rules 17 ("a place first") and 13 (funnel then fork) are partly subjective; their criteria are playtest questions, not pass/fail numbers. The dash, wall-cling and double-jump gates cannot be tested until `PlayerState` has dash and wall cling flags (a later story).


## Open Questions

[To be designed]
