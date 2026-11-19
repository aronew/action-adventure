# Level design and world layout

> **Status**: In Review (seventh `/design-review` 2026-11-18: 2 blockers revised (key 3 window 72-106 to match the registry; gate state stored as Seen and Passed, Passable derived); owner decisions: save spacing counts new ground only, spikes can be pogoed; awaiting re-review). 2026-11-18: gate-fit formulas F1-F3, F6, F8, F9 and their criteria moved to `design/gdd/ability-gating.md`
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-18
> **Last Verified**: 2026-11-18
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room"; loop: fight, gain a verb, open the world, fight again)

## Summary

Level design and world layout decides how rooms form regions and loops, which key opens which route, where each key is found, and where saves, shortcuts, bosses and secrets sit. It turns the Seeker's earned abilities (dash, wall cling, double jump, grapple) into a world worth exploring and returning to, with gates seen first and keys found elsewhere. Without it the finished systems would be a movement and combat test with no reason to travel.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rooms and transitions, Terrain pipeline, Ability gating, World state, Bosses`

## Overview

Level design and world layout decides the shape of the Seeker's world: how rooms group into regions, how regions connect, which route each earned ability opens, where each ability is found, and where saves, shortcuts, bosses and secrets sit. It is the design layer over four systems that supply the pieces (rooms and transitions, the terrain pipeline, ability gating, world state): they say what a room, a wall or a gate *is*; this system says what the player meets, in what order, and why they come back. The player never operates it directly. They feel it as a world that rewards curiosity: they read a room, notice a ledge, a wall or a gap they cannot yet cross, remember it, and return later with the verb that opens it.

The core loop (fight, gain a verb, open the world, fight again) only works if the world is built to carry it. The Seeker starts with only run, jump and attack; dash, double jump, wall cling and grapple, then the bow and spell casts, are earned in the world, so every early room is also a promise about a later one. Exploration and curiosity come first: the world is large masses of floor and a few floating islands on several levels, not rows of platforms, and every ability is found through a boss, a place worth finding, or a mentor, never in front of its own gate. There is no "region cleared" screen; the world just continues. The full game is 5 regions; the brief's core build is region 1, built so the other four can attach.

## Detailed Design

### Core Rules

Tags: **[Owner]** = your stated rule; **[Sourced]** = backed by the research (`design/research/metroidvania-world-design.md`); **[Rec]** = recommendation, change freely; **[Calc]** = computed from `player_config.tres`, re-measure in `movement_test_room`.

**World model**

1. The world is a graph of **rooms**. A room is a whole number of 480x270 screens, written width x height in screens (1x1 connector, 1x3-4 shaft, 3-4x1 hall, rare set piece up to about 8 screens). Rooms group into **regions**; a region has one identity (palette, enemies, architecture, music), one boss at its apex and at least one save point. **[Rec]**
2. The full game is **5 regions** **[Owner, 2026-11-18]**. The core build is **one region**, region 1, the Cooling Yards (brief scope; lore in `design/narrative/`), built so the other four can attach at its edges. Its gates for keys region 1 does not give (double jump, grapple) are real and visible. In the core build each leads to a **sealed alcove**: a nook on the gate's far side (on the ledge top or the far floor) holding a reward the player can see but not reach (a pickup or a lore item). The alcove is part of the gate's own room, on screen from the gate's near side; it is not a separate room, has no door and is not a node of the room graph. It counts as that dead end's secret (rule 19), and it is filled when its key exists. An alcove beyond a gap gate has a way back to the near side with the start kit (a drop, or a door that opens only from inside), so a player who leaks in is never stuck (rule 12). **[Owner, 2026-11-18; in the gate room: Owner, sixth review 2026-11-18]**
3. Rooms are authored on a grey-box first: collision only, no art, played and approved before any tile or painting is added. **[Sourced]** (Ori's "design approved" gate)

**Start state and key order**

4. The Seeker starts with: run, jump, the whole sword set (3-hit combo, up and down attacks, pogo, charged heavy), crouch, doors. **[Owner]**
5. Keys are earned in this order. Nothing in the start kit may open any gate in the table. **[Owner for order; the gate and source columns are Rec]**

| # | Key | Opens (gate signature) | Found by | Why here |
|---|-----|------------------------|----------|----------|
| 1 | Dash | Gaps inside the F1 window (about 145-162 px at margin 8, edge to edge), too wide for any run-jump. Bisque panes, broken only by a dash (F10, ability gating) | Keeper Tavik, the Hot-Carrier: region 1's mini-boss, mid-region (after the funnel's fork) | Horizontal key first in every benchmark; seen as an uncrossable gap in the first minutes |
| 2 | Wall cling (wall slide, wall jump, climb) | Cling walls (F6a: any plain face at least `ledge_min` tall with no standing spot on it) and climb walls (F6b, marked surfaces) | Shrine in region 1 (Dorrit's jar), behind a dash gate; found by exploring | Opens the vertical world; walls are ladders once it exists, so it is earned before the double jump |
| 3 | Double jump | Ledges 72-106 px up that pass the F2 cling test (no plain underside below the head, no launch face) | Region 2: mentor / hub pact (Pell, the Stacking Loft) | The mid-game hinge: where the map opens to three or four valid directions |
| 4 | Grapple | Authored anchors only: F3a ledges above double-jump reach, F3b gaps wider than any non-grapple crossing, crossed by a chain of gate anchors hooked in order (F11, ability gating) | Keeper: region 3's boss | Opens only the locks you place, so it is the safe late key; later grows into grapple-to-enemy |

**Cling surface, one wall is a ladder, no-cling face.** Defined in `design/gdd/ability-gating.md` (rules 12-14, adopted 2026-11-18): any plain face lets the Seeker slide and wall-jump once the wall cling is owned, one plain wall can be climbed by repeated kicks, only `climbable` surfaces climb, and a `no_cling` face refuses the wall cling. A wall that must stay shut after the wall cling meets the ceiling or room bound with no opening, or is `no_cling`. **[Owner, 2026-11-18]**

**Key-to-region mapping [Owner, confirmed 2026-11-18].** The full game is **5 regions**; the core build is region 1 only (brief). Region 1 gives the dash (its mini-boss, a Keeper, mid-region) and the wall cling (a shrine behind a dash gate); region 2 gives the double jump; region 3's boss (a Keeper) gives the grapple; regions 4 and 5 add no movement key (they remix the four; the bow, spells and grapple-to-enemy come later). Region 1's apex boss sits beyond at least one dash gate and one wall-cling gate, so the core build runs the whole loop (fight, gain a verb, open the world, fight again) twice before its goal. The double-jump and grapple gates are *seen* in region 1 and pay off in later regions (rule 2).

6. The bow and the spell casts are not movement keys and gate nothing in the core build; they are earned later (Alpha). **[Owner]**
7. Every key opens few locks, has one visual signature that nothing else in the world uses, and changes combat as well as movement (dash: dodge and gap-close; wall cling: wall-based attack angles; double jump: second air window; grapple: pull and fling). **[Sourced]** (Metroid Dread: few locks per key; one material per key)

**Showing the lock, placing the key**

8. A gate is **seen before its key is found**, at least twice, the first time within the first 10 minutes of play for the dash gate. **[Owner for the principle; counts Rec]**
9. A key is never found in the same room as its first gate, nor fewer than 3 rooms from it (shortest path through the room graph, ignoring locks, counted in room-to-room steps: the path A, B, C, D is 3), and never in a room that can be reached only by the key itself. **[Owner for "never in front of the gate"; numbers Rec]**
10. Every key is found by exactly one of the three channels, named by the pickup: boss or mini-boss (a Keeper), shrine / relic pedestal (exploration), or mentor / hub pact (narrative). A pickup does not care which; gating only reads "owned". **[Owner]**
11. After each key, the next room is a **learning workshop**: a one-room exit that uses the new key on a smaller instance of a lock the player has already seen. The player can always leave again; the workshop is a short test, not a trap. **[Sourced]** (Lost Crown, sandbox escape) "Smaller" is measured per key: the wall-cling workshop is a cling wall shorter than the ones already seen; the dash workshop is a gap at the `gap_min` end of the F1 window with a safe floor below and a way back that needs no dash (the window is only about 17 px wide, so a smaller gap could not be seen). **[Owner, fifth review 2026-11-18]**
12. Soft gates are allowed and not hunted down: a skilled player who gets past a gate early with the current kit is rewarded, as long as the world stays coherent (no soft-lock, no missed boss trigger). **[Sourced]**

**Topology**

13. The first region is a **funnel**: one objective at a time for the first 5-10 rooms, then a fork to two or three directions. Late in the game, openness rises to three or four valid directions. **[Sourced]** (Silksong acts; Team Cherry)
14. Rooms form **loops**, not trees: every region has at least one shortcut that folds back to a save point (one-way door, breakable wall, lever, lift or drop). Shortcut gates open from the far side first. **[Sourced]** (shortcut folding; Blasphemous found one-use levers overused, so mix breakable walls and doors)
15. A save point is placed before every boss and mini-boss, in the room just before its arena (or in an antechamber), so the walk from that save to the arena is one room at most and never exceeds `save_spacing_max` screens (F4, starts at 7). Each arena also has a **loop home**: a shortcut in the arena, or within two rooms past it (rule 11's workshop may sit between), that returns to some save on the main route. It need not return to the pre-arena save. **[Sourced]** (Blasphemous, Ender Lilies) **[Owner, fifth review 2026-11-18: save near, loop returns]**
16. No more than `save_spacing_max` screens (F4, starts at 7) of forward movement between two adjacent save points on the main route: only new ground counts, so backtracking and the walk back out of a dead end never call for a save. Saves sit before every boss and mini-boss (rule 15) and wherever forward movement would pass the limit. **[Sourced]** (Blasphemous) **[Owner, seventh review 2026-11-18: forward movement only]**

**Room composition**

17. A room is a place first ("a flooded cavern, a ruined tower stair"), then a layout. Floors and mass terrain carry the room; floating islands are allowed; free-standing platforms are rare and only where a gate needs them. No room has more than 3 free-standing platforms unless it is a designated platforming room. **[Owner for the principle; limit Rec]**
18. Every room has a job: connector, shaft, combat room, platforming challenge, hub, save, secret or boss antechamber. A room that does none of them is cut. **[Rec]**
19. A secret follows a pattern the game has already shown (a cracked wall, an off-screen ledge, a dead end with something just out of sight), and a dead end without a secret is cut. **[Sourced]** (Animal Well: break from the pattern; Dread: hidden blocks on the main path always have a hint)
20. Only bosses and mini-bosses carry a guard. Region 1 has one boss (Brun, the Stacker) and one mini-boss (Keeper Tavik); each later region has one boss. In the lore a guard is glaze. Normal enemies have health only. **[Owner]** One exception: a single scripted **tutorial foe** in the first minute carries a weak guard to teach guard-break (brief: First minute); it appears once and never respawns. **[Owner, 2026-11-18]** Region 1's mini-boss is the brief's "tougher guarded enemy": it guards the dash and is a Keeper (key table). **[Owner, 2026-11-18]**
21. There is no "region cleared" screen, banner or lock-out. A beaten boss opens doors and changes the world quietly. **[Owner]**

**Backtracking and flow**

22. Each key changes at least two old rooms in a new way, and at least one of them is a room the player skipped or could not finish before. A changed room is either a **faster route** (it was passable before; F5 `speedup >= speedup_min`) or a **newly opened route** (impassable before, so F5 does not apply; it counts when the key makes a seen gate or dead end passable). **[Sourced]** (re-contextualized geometry)
23. The grid map shows rooms as boxes and exits as lines; an unexplored exit shows as a marker, and the map does not mark item locations. A key that makes exploration trivial is never taxed; it is moved later. **[Sourced]** (Ender Lilies, Dread)

**Gate integrity**

24. **Pogo clearance.** The start kit's pogo (a down attack that hits a `hittable`: launch 260 px/s, about 38 px of rise, air moves refreshed, repeatable) is a free extra jump over anything it hits. Spikes and other floor hazards can be pogoed too **[Owner, seventh review 2026-11-18]** (as in Hollow Knight), so they are pogo targets alongside the `hittable` group. No pogo target (enemy spawn point or patrol or flight bounds, breakable, target, boss add, hazard) may lie inside the **gate volume** of any gate: the gap and the air above it (F1, F3b), the column under the ledge (F2, F3a) or the cling wall (F6a), from the floor up to the earlier kit's reach height plus `pogo_rise` (F7). A column gate's volume is widened by `pogo_clearance_px` on each side; a gap gate's volume ends `hitbox_width` past each lip (F7). A room that breaks this is rebuilt, not logged as a soft gate. One exception: a hazard on the floor of a dash pit (F1) is allowed when both lips stand at least `hazard_pit_depth_min` (F7, about 84 px) above its top, which is deeper than `pit_depth_min`; the start kit can then bounce in the pit but cannot reach a lip, and the pit's way out still leads back to the near side. A grapple gap (F3b) uses a kill plane, not a hazard, until ability gating sets a depth for it: a pogo refreshes the air jump and air dash, so the earlier kit could bounce across a hazard floor (Open Question 20). The current code pogoes only the `hittable` group; making hazards pogoable is a Combat story. **[Owner decision 2026-11-18: clearance rule; distance Rec and Calc]**
25. **Collision and trim.** Terrain is black collision masses with rock or moss trim painted on their edges **[Owner, 2026-11-18]** (the look of the Maaot Brown Cave and Mossy Cavern packs; see Visual/Audio). The collision edge is the line between the black mass and its trim. At every gate (F1-F3, F6) and at every `no_cling` face, the trim may overhang the collision by at most `trim_overhang_max` (starts at 4 px at game scale, **[Rec]**), so a gap or ledge reads at its real size; elsewhere trim is free. All gate figures are measured on collision, never on art. **[Owner for the look; overhang Rec]**
26. **Gate room footprint.** A room that holds a double-jump or grapple gate is wide enough that no plain wall is a launch face (F8): `room_width` meets F9, unless every plain face within reach is `no_cling`. (A low room ceiling is not an exemption: a ceiling over a gate is always above `target_top - launch_rise`; it helps only by lowering `dh` in F8.) In practice, at one screen high: a double-jump ledge needs a room 2 or more screens wide, a grapple ledge 2 to 3, and a grapple gap 3. A narrow shaft cannot hold these gates. **[Calc; Owner decision, fifth review 2026-11-18: meet it by widening rooms; `no_cling` stays a tool for particular faces, not the default]**


### States and Transitions

World state is held by the **world state** system; this system defines what the states mean and what changes them.

| Thing | States | Transition and trigger |
|-------|--------|------------------------|
| Key | Unobtained, Obtained | Unobtained to Obtained when the pickup is collected (boss reward, shrine or mentor). Never reverts. |
| Gate | Two stored flags, Seen and Passed; Passable is derived | Seen is set the first time the gate is on screen. Passed is set the first time the player crosses it, with or without its key: a leak (rule 12) or a later key used out of order sets Passed while the key is unowned. Passable is never stored: a gate is Passable whenever its key is owned (ability gating rule 4, owned never ordered), so a key owned before its gate is seen needs no transition. Neither flag clears. |
| Shortcut | Closed, Open | Closed to Open when the player triggers it from the far side. Never closes again. |
| Boss | Undefeated, Defeated | Undefeated to Defeated on boss death; the flag persists (existing `boss_defeated`). Opens any doors and rewards tied to it. |
| Region | Unvisited, Entered | Unvisited to Entered on first room entry. No "cleared" state is shown to the player. |
| Secret | Hidden, Found | Hidden to Found when revealed; recorded for the map and for any count. |
| Sealed alcove (core build, rule 2) | Sealed, Found | Visible from the start, so it is never Hidden. Sealed to Found when the player reaches the reward (with its key, or by a leak, rule 12). It is part of its gate's room, not a room of its own; it satisfies rule 19 (the dead end's secret) from the start and is not counted as a found secret until it is Found. |
| Room | Unvisited, Visited | Visited on first entry; drives the grid map. |

No state in this table can move backward.


### Interactions with Other Systems

None of the upstream systems has a GDD yet; the interfaces below are the contract this system expects and are **provisional** until each is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Rooms and transitions | In | Room units, exits, doors, per-room camera limits, room graph | Rooms and transitions |
| Terrain pipeline | In | Collision and tile rules a room is built from; the grey-box to painted path | Terrain pipeline |
| Ability gating | Both | In: gate types, formulas F1-F3, F6, F8-F11, visual signatures, `no_cling`, gate anchors. Out: which gate sits where and what key it needs | Gating owns what a gate is (GDD: `design/gdd/ability-gating.md`, In Design); this system owns placement and order |
| Bosses | In | Boss rooms, defeat flag, what the boss grants | Bosses |
| Enemies | In | Enemy types and rosters placed in rooms, with spawn points and patrol or flight bounds for the pogo clearance check (rule 24, F7) | Enemies |
| Combat | In | The pogo (`pogo_speed`, the down attack's hitbox, repeatable, air moves refreshed), the `hittable` group and pogoable hazards that rule 24 and F7 read | Combat |
| World state | Both | Out: keys obtained, bosses defeated, shortcuts opened, secrets found. In: reads for gate state | World state |
| Save points | Out | Save locations and the 7-screen spacing rule | Save points |
| Grid map | Out | Room graph, exits, unexplored markers | Grid map |
| Fast travel (later) | Out | Which rooms may be travel points | Fast travel |
| Collectible upgrades (later) | Out | Where reward rooms sit and how many | Collectible upgrades |
| Lore and mentor (later) | Out | Where the mentor hub and lore sit | Lore delivery |


## Formulas

**Gate-fit formulas live in `design/gdd/ability-gating.md`** (moved 2026-11-18, owner decision): F1 dash gap, F2 double-jump ledge, F3 grapple ledge and gap, F6 cling and climb wall, F8 wall launch reach, F9 gate room footprint, F10 bisque pane, F11 gate anchor chain. This GDD cites them by number and keeps no copy. It keeps the placement formulas F4 (save spacing), F5 (flow speed-up) and F7 (pogo clearance). All movement figures are read from `player_config.tres`, never from constants in a document.

### F4. Save spacing

The save_spacing rule is defined as:

`route_screens(save_a, save_b) <= save_spacing_max` for adjacent saves on the main route. The **main route** is the shortest walk through the room graph that collects each key and beats each boss and mini-boss in key order; it revisits rooms (after the dash it goes back to the Yard Gate), so it is a sequence of rooms, not a set. Two saves are **adjacent** when the walk passes one and then the other with no save between; a save passed again on old ground starts a new count. `route_screens` counts **new ground only** **[Owner, seventh review 2026-11-18]**: a screen counts the first time the main route enters it, and a screen already walked counts 0 (backtracking, the walk back out of a dead end, a shortcut or return through old rooms). The way into a dead end is new ground and counts; the way back out does not. New screens are counted **by screen position**: in a room of `n` screens a save's screen has index `save_screen` (1 to `n`) along the walk through it; count the new screens among the `n - save_screen` after `save_a` in its room, every new screen of each room between the two saves (a room of more than one screen counts all of its new screens), and the new screens among the `save_screen - 1` before `save_b` in its room. A save's own screen is never counted, and a boss or mini-boss arena is not counted. A save at the far end of a multi-screen room therefore counts that whole room when it is new ground. (The fifth review found the earlier rule, which dropped both save rooms, understated the walk by up to 4 screens.) The walk from a save to the arena it serves is a separate check (rule 15).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| route_screens | int | 0 to save_spacing_max | calculated from the room graph | New screens (first entry on the main route) walked between two saves, by screen position; old ground counts 0 |
| save_screen | int | 1 to `n`, the room's screen count | data file (room data) | Index of the save's own screen along the walk through its room; `n - save_screen` screens follow it and `save_screen - 1` precede it |
| save_spacing_max | int | 5-10 | data file | Upper bound; starts at 7 (Blasphemous), tuned in playtest |

**Output Range:** at most 7 screens. A 480 px screen crosses in about 3.4 s at 140 px/s, so 7 screens is about 24 s of pure running and roughly 2-4 minutes with fights and platforming.
**Example:** a save in a 1-screen room (0 after it), a 2-screen hall (2), a 1x3 shaft (3), a 1-screen combat room (1), then the next save on screen 2 of a 2-screen antechamber (1 before it): 7 screens, valid. The arena beyond is not counted.
**Region 1 (sixth review, 2026-11-18).** Rule 26 widens Saggar Rows from 1x2 to 2x2 (4 screens), which pushes N2 to N3 to 2 + 4 + 2 = 8, over the limit. The owner's fix: a new save, **N2b**, on screen 2 of the walk through the widened Saggar Rows (the narrative side names and numbers it in the integration draft). With each save at the room end the draft names, the first legs of the walk are: N1 to N2 = 3 (Yard Steps; N2 is on the Yard Gate's first screen); N2 to N2b = 2 (rest of the Yard Gate) + 1 = 3; N2b to N3 = 2 (rest of Saggar Rows) + 2 (Cinder Stair below its top save screen) = 4; N3 to N4 = 2; N4 to N5 = 3 + 4 = 7 (no spare screen); N5 to N2 by shortcut S1 = 1 (Warm Flue) + 2 (Flue Run) = 3, if S1 lands on N2's screen. The legs after the dash count new ground only (seventh review): N2 to the shrine and its workshop is at most 2 (the Yard Gate beyond its gap, if not walked before) + 1 (Dorrit's Bench) + 2 (Sweep Flue) = 5; the walk back through the Yard Gate, Saggar Rows, Cinder Stair and Hot Lane is old ground (0) and passes N2, N2b, N3 and N4 again, each starting a new count; N4 to N7 = 2 (the Saggar Climb below its top save screen). Every leg is within 7. Only an exit from Sweep Flue into rooms not yet walked would add to these; the draft names it (Open Question 18).
**Edge:** 0 is valid (saves on adjacent screens, or a stretch of old ground only); oversized rooms count by screen, not as one; a save at the far end of a room counts the whole room when it is new; backtracking and the walk back out of a dead end count 0; a revisited save starts a new count.

### F5. Flow speed-up

The flow_speedup formula is defined as:

`speedup = 1 - t_with_key / t_without_key`, defined only for a route that was passable before the key. Rule 22 requires each key to change at least two old rooms: a faster route must reach `speedup >= speedup_min`; a newly opened route (impassable before) has no `t_without_key`, so F5 does not apply and it counts by being passable only with the key.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_without_key | float (s) | greater than 0 | calculated from route length and player_config | Crossing time before the key |
| t_with_key | float (s) | greater than 0 | calculated from route length and player_config | Crossing time after the key |
| speedup_min | float | 0.2-0.5 | data file | Required improvement; starts at 0.3 |

**Output Range:** 0 to under 1; negative means the key slows the route and fails the rule.
**Example:** dash on a 3-screen hall (1440 px): 10.3 s at 140 px/s; a dash cycle (0.25 s dash, 0.3 s cooldown) averages about 245 px/s, 5.9 s; speedup 0.43. Approximate: ignores dash_end_speed_keep.
**Edge:** a route of length 0 is excluded; a route impassable without the key is excluded from F5 and counted as newly opened (rule 22).

### F7. Pogo clearance

The pogo_clearance rule (rule 24) is defined as:

`no pogo target lies inside gate_volume(gate)`, except a hazard on a dash pit's floor with both lips at least `hazard_pit_depth_min` above its top (rule 24). A pogo target is a member of the `hittable` group or a floor hazard such as spikes. The gate volume runs from the floor up to `max(reach_height + pogo_rise, gate height)`, where `reach_height` is the feet height the gate's earlier kit reaches (`jump_apex` for F1, F2 and F6; `double_jump_total` for F3). Its width depends on the gate:
- **Column gates** (F2, F3a, F6a): the column under the ledge or along the wall, widened by `pogo_clearance_px` on each side.
- **Gap gates** (F1, F3b): the gap's span, ending `hitbox_width` past each lip. A pogo carries the Seeker only about 96-105 px from the hittable (fourth review sim), less than any gap gate (145 px or more), so a hittable on solid ground beside a gap cannot carry it across; only a hittable over the gap can. `pogo_carry` assumes a take-off from ground level with the lips: carry grows with the height of the pogo contact (roughly 0.3 px per px of extra height, an estimate from the fall time), so a gap gate that can be approached by a drop from higher ground is re-measured in `movement_test_room` before it is accepted.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| pogo_speed | float (px/s) | 260 | data file (`attack_data.tres`) | Launch speed of a pogo |
| pogo_rise | float (px) | about 38 | calculated | `pogo_speed^2 / (2 x gravity)` = 37.6 px at gravity 900; about 38.7 with jump held (apex hang below 50 px/s) |
| pogo_carry | float (px) | about 96-105 | calculated from player_config | Horizontal travel from a pogo contact (24-55 px above the floor) back down to floor level at run speed (60 Hz sim) |
| pogo_clearance_px | float (px) | 100-160, starts at 120 | data file | Column gates only: `pogo_carry` plus `hitbox_width`, rounded up. A hittable this near a ledge or wall can be pogoed and carried onto it. Re-measure |
| pogo target | node group and hazards | n/a | code (`hittable`; hazards not yet, a Combat story) | Enemy spawn point or its patrol or flight bounds, breakable, target, boss add, and floor hazards such as spikes (rule 24) |
| hazard_pogo_reach | float (px) | about 76 | calculated from `attack_data.tres` and player_config | Highest the feet get above a floor hazard's top by pogoing it again and again: the down attack's reach below the feet (its hitbox bottom, 32 px) + `pogo_rise` with jump held (about 39) + `ledge_nudge` (5). Re-measure |
| hazard_pit_depth_min | float (px) | about 84 | calculated | `hazard_pogo_reach + gap_margin` (8): least height of a dash pit's lips above a hazard floor (rule 24's exception). Deeper than `pit_depth_min` (about 72), which a spike floor would leak through |

**Output Range:** 0 pogo targets in every gate volume of every room, apart from rule 24's dash-pit exception.
**Example:** a double-jump ledge with a breakable 100 px from its column is rejected at 120; moving the breakable 130 px away passes. A dash gap 150 px wide with a patrol bound 20 px behind its near edge passes (outside the gap's span plus 10 px); a bat whose flight bounds cross the air above the gap is rejected. A dash pit with spikes 80 px below its lips is rejected (under 84) and one 90 px down passes; spikes on the floor under a double-jump ledge are rejected (a pogo off them lifts the feet about 80-90 px above the floor, past `ledge_min`).
**Edge:** the rule does not apply to a room with no gate; a boss arena has none. A kill plane is not a pogo target.

**Feedback loops:** keys make old rooms faster, which makes revisiting cheaper and encourages exploring; intended, bounded by shortcuts (enemy respawn rules belong to the Enemies GDD, not yet written). A later key leaking into an earlier gate (double jump over a dash gap) is also intended.

**Registry candidates (not owned here):** run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, hitbox_height, kick_rise, wall_reach belong in the movement GDD when it exists.


## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

- **If a player passes a gate early with the current kit** (a leak the checks missed, such as an untested input sequence, or a later key obtained out of order, such as the double jump over a dash gap): allow it. The formulas are built so a perfect start-kit jump does not cross; rule 12 is the safety net for what they miss, not a licence to ship a gate that leaks. The room beyond must still make sense with any kit the player owns, and no rule may assume a key order the player was never forced into (rule 12).
- **If a player reaches a key's location before its intended order** (the wall cling shrine reached without the dash): the key is granted normally. Later gates stay valid because gates read only "owned", never "owned in order".
- **If the player is in a one-way drop, a pit or a secret room**: there is always a return path to the previous room with the kit they had when they entered. A drop that returns only with a later key is cut.
- **If the player dies after collecting a key but before reaching a save point**: the key is saved at pickup and stays owned. Dying cannot take a key away. (World state and save points own the write; this is the requirement on them.)
- **If the player dies in a boss room**: respawn at the save point before it (rule 15). The boss is undefeated until its flag is set; its reward pickup stays in the room until collected.
- **If a boss is defeated but its reward is not collected before the player leaves**: the pickup stays in the room, visible and collectible on return, and the boss stays defeated.
- **If a shortcut is approached from its near side**: it shows as blocked and does not open; it opens only from the far side, then stays open (states table).
- **If an enemy, breakable or hazard would sit near a gate** (inside the F7 gate volume): the placement is moved or the gate is rebuilt; it is not logged as a soft gate, because the pogo would let the start kit cross (rule 24). A patrol's whole route counts, not only its spawn point. Spikes count like an enemy; the one exception is a spike floor in a dash pit at least `hazard_pit_depth_min` below the lips, and a grapple gap uses a kill plane instead of spikes.
- **If a cling wall has a standing spot on it** (F6a): the wall is rebuilt; with a standing spot the start kit climbs it in hops.
- **If a plain wall that should hold after the wall cling is open at the top** (Core Rules, one wall is a ladder): the player climbs it by repeated kicks. It is raised to the ceiling or room bound, or made `no_cling`; it is not logged as a soft gate.
- **If a dash gap sits near the top of its window and the player misses**: they fall to a safe floor with no fall damage and an unbroken way back to the near side. A gap whose floor below is a hazard needs a return ledge.
- **If a dash gap's pit is shallow, its lips are uneven, or something stands in mid-gap** (F1, the pit): the start kit drops in and climbs out on the far side, or hops across. The pit is deepened to at least `pit_depth_min` below the far lip, the lips are levelled (or the reaches re-measured), and the mid-gap standing spot is removed.
- **If a room has no job (rule 18) or a dead end has no secret (rule 19)**: it is cut at the grey-box review, not shipped.
- **If a double-jump or grapple ledge fails the cling test** (F2, F3a: a plain underside below the head height, or a launch face within `wall_reach`, F8): the wall cling is owned by then, so the gate leaks. The faces involved become `no_cling`, the slab is thinned, or the wall is moved or capped by the ceiling.
- **If a grapple chasm has a deep plain far face or a floor** (F3b): the player catches the far face on the way down, or walks the floor, and kicks up. The far face becomes `no_cling` or at most `far_face_max` deep, and the floor becomes a hazard or kill plane.
- **If a double-jump or grapple gate sits in a room narrower than F9 requires** (a shaft 1 screen wide, for example): the plain walls are launch faces and the gate leaks. The room is widened (rule 26); a wall is made `no_cling` or capped only for a particular face, not to fit a narrow room.
- **If painted trim hides a gate's real edge** (rule 25): the trim is cut back to `trim_overhang_max` at the gate; the collision is never moved to fit the art.
- **If the player owns all four keys and a route's speedup is below the minimum** (F5): the route is redesigned or marked as not part of the key's two-route promise; it is not left as a tiresome back-track.
- **If save spacing would exceed `save_spacing_max` screens on the main route** (F4, new ground counted by screen position): add a save or move one. The rule never counts rooms of more than one screen as one, and a save at the far end of a room counts that whole room when it is new. **If a dead end's walk back out is long**: no save is needed for it, since the walk back is old ground (rule 16).
- **If a mini-boss or boss room locks behind the player**: the player always has a way out by winning or dying; a locked arena never traps without a respawn.
- **If a player sees a sealed alcove in the core build** (rule 2): the reward stays visible and unreachable, and the alcove is listed as a secret, not as Found. **If they get into it by a leak** (rule 12): they collect the reward, the alcove becomes Found, and its way back (rule 2) returns them to the near side with the start kit.
- **If the tutorial foe is skipped or the player dies to it** (rule 20): it never respawns once beaten; if the player dies before beating it, it is back on respawn, and the path past it stays open either way.


## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Rooms and transitions | Hard | Room units, exits, doors, per-room camera limits, the room graph | No (provisional) |
| Terrain pipeline | Hard | The collision and tile rules every room is built from; the grey-box path; black collision masses with painted trim and the `trim_overhang_max` rule (rule 25); a `no_cling` material | No (provisional) |
| Ability gating | Hard | Gate types, dimensions and visual signatures; the "owned" read; the `no_cling` surface's signature | Yes, In Design (`design/gdd/ability-gating.md`); code exists: `PlayerState`, `AbilityGate`, `AbilityPickup` |
| World state | Hard | Records of keys, boss defeats, shortcuts and secrets | No (provisional) |
| Bosses | Hard | Boss rooms, the defeat flag, the reward source | No (code exists: `Boss`, `boss_arena`) |
| Enemies | Hard for the F7 check, soft otherwise | Enemy types to place in rooms; spawn points and patrol or flight bounds, which the F7 [Auto] check reads | No (code exists: three types) |
| Combat | Hard | The pogo (`pogo_speed` and the down attack's hitbox in `attack_data.tres`), the `hittable` group, and pogoing off floor hazards such as spikes (owner, seventh review; not in code yet): a change to any of them changes every gate volume (rule 24, F7) | No (code exists) |
| Player controller | Hard | Movement values behind F1-F3 and F5-F8, and the pogo (`player_config.tres`, `attack_data.tres`): a change to gravity, jump, dash or wall-jump speed silently changes every gate, so the Auto checks read the figures from the config. Also the `no_cling` check (no wall slide or wall jump on a `no_cling` face) | No (code exists; `no_cling` not built) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Save points and save/load | Hard | Save locations and the spacing rule (F4) |
| Grid map | Hard | Room graph, exits, unexplored markers |
| Collectible upgrades | Soft | Where reward rooms sit |
| Fast travel | Soft | Which rooms may be travel points |
| Lore delivery and mentor/hub pact | Soft | Where the mentor hub and lore sit |
| Elemental palette power-ups | Soft | Gate materials per element |

**Bidirectional check:** Ability gating now has a GDD (`design/gdd/ability-gating.md`), which lists level design as a dependent; the other GDDs do not exist yet and each needs a matching entry when designed. The contract: gating owns gate types, formulas F1-F3, F6, F8-F11 and visuals; level design owns placement and order.


## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The look itself is owned by the terrain pipeline and the parallax, lighting and atmosphere systems; this section lists only what level design needs from them.

- **Gate language:** each key has one signature (shape, material and colour) that nothing else in the world uses, so a gate is readable from across a room. The palette is chosen with the art bible (not yet written) and replaces the placeholder colours of the gate test room.
- **Region identity:** each region reads as a distinct place by palette, architecture, enemies and music, so the player always knows where they are. **[Sourced]** (Silksong: architecture tells you where you are)
- **Readability:** play-layer collision edges are the brightest values in a room and the room reads in greyscale; backgrounds and foreground framing never imitate a platform or a gate. **[Sourced]** (Saltsman)
- **Terrain look [Owner, 2026-11-18]:** solid terrain is black collision masses with rock or moss trim painted on their edges, over fogged, softer parallax layers (the example scenes of the Maaot Brown Cave and Mossy Cavern packs, kept locally in `assets/third_party/`, not in git). The black mass is the grey-box (rule 3), so an approved grey-box keeps its shape when it is painted. Trim obeys rule 25 at gates. The packs are painted at 512-1024 px per tile and the game renders at 480 x 270 with nearest filtering, so the art bible must settle the scale and filtering, and how the pixel-art Seeker sits on painted terrain, before any room is painted.
- **No-cling signature:** a `no_cling` face shows its material (candidates: thorn vines, or slick glaze for the kiln city; not copper-green) over its whole height, so the player can tell from across a room which walls will not hold them.
- **Quiet transitions:** a beaten boss, an opened shortcut and a granted key change the world through animation, sound and light only; no banner or "cleared" screen (rule 21).
- **Audio:** each region has its own music and ambience; a gate you cannot yet open has a small audio tell when first approached; a key pickup has a clear, short cue; a shortcut opening has a distinct sound.

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:level-design` to produce per-asset descriptions and generation prompts from this section.

## Game Feel

These are **design targets**, not acceptance criteria: they guide layout and become playtest questions, and no story passes or fails on them. The checks that do gate a story are in Acceptance Criteria (rules 8, 11, 13 and 22). The Seeker's movement and combat feel is owned by the controller and combat systems.

- **Reading a room:** a first-time visitor can tell the exits and the main route within about 5 seconds; a typical room is crossed in 15-60 s (micro loop).
- **A lock remembered:** after the first 10 minutes the player can name at least one place they cannot yet reach.
- **Key moment:** the pickup is followed at once by the workshop room (rule 11): the player uses the new key within about 30 seconds of collecting it.
- **Friction to flow:** an old route that was passable before is at least `speedup_min` (starts at 0.3) faster with a new key (F5), and a playtester names one such route when asked afterwards.
- **Shortcut moment:** opening a shortcut shows where it leads, so the player sees the loop close.

## UI Requirements

- The grid map shows rooms as boxes, exits as lines and unexplored exits as markers; it does not mark item locations (rule 23). Owned by the grid map system.
- A key's gate may carry a diegetic sign (the gate test room's signs dim until owned); no HUD "region cleared" message (rule 21).
- A short on-screen note on the first pickup of each key says what it is called; its text comes with the lore.

📌 **UX Flag — Level design and world layout**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for each screen or HUD element this system contributes to **before** writing epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

None of the other GDDs exists yet; these are the values and rules this GDD relies on, each provisional until its owner is written.

| This GDD uses | Owner (system) | Status |
|---------------|----------------|--------|
| run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, max_non_grapple_crossing, landing_slack, kick_rise, kick_cycle, launch_rise, wall_reach, far_face_extra, pogo_carry (F1-F3, F6-F8) | Player controller / movement | Calculated from `player_config.tres`; to be registered |
| hitbox_width, hitbox_height, ledge_nudge (F1, F2, F3a) | Player controller / movement | In `player_config.tres` (`hitbox_size` 10x22, `ledge_nudge` 5) |
| The `no_cling` surface: no wall slide or wall jump on it | Ability gating (rule 14); Player controller (the check) | Defined in `design/gdd/ability-gating.md`; not in code |
| Collision masses with painted trim, `trim_overhang_max` (rule 25) | Terrain pipeline | Not designed; look chosen by the owner 2026-11-18 |
| pogo_speed, the down attack's hitbox, the `hittable` group, pogoable hazards (rule 24, F7) | Combat | In `attack_data.tres` (260 px/s; down hitbox reaches 32 px below the feet); hazards not yet pogoable in code; no GDD |
| grapple_range (F3) | Player controller / movement | In `player_config.tres` (200 px) |
| Gate types, formulas F1-F3, F6, F8-F11, signatures, gate anchors | Ability gating | `design/gdd/ability-gating.md` (In Design); code exists |
| Room graph, exits, camera limits | Rooms and transitions | Not designed |
| Key, boss, shortcut and secret flags | World state | Not designed |
| Boss defeat flag, boss reward | Bosses | Code exists (`boss_defeated`) |
| Save locations, spacing (F4) | Save points and save/load | Not designed |

## Acceptance Criteria

Types: **[Auto]** automated test on room data or the room graph; **[Play]** playtest record; **[Shot]** retained screenshot in `production/qa/evidence/`. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. `qa-lead` not consulted: Lean mode; the checks in `references/lens-qa-lead.md` were applied by the author.

**Start state and keys**
- **GIVEN** a new game, **WHEN** the Seeker loads in the first room, **THEN** the player owns run, jump, the full sword set, crouch and doors, and owns none of dash, wall cling, double jump, grapple, bow or spells. **[Auto]** (rule 4, 6)
- **GIVEN** the start kit only, **WHEN** a tester tries every dash gap, cling wall, climb wall, double-jump ledge and grapple target in the region by any means in the kit (pogo off any hittable or hazard included), **THEN** each one is blocked, except those logged as deliberate soft gates. **[Auto]** as a scripted input sweep in `movement_test_room` (the 60 Hz sim is deterministic, so repeats prove nothing: take-off position in 1 px steps across `hitbox_width` either side of the lip, and each jump press, release and pogo down attack on every frame of its window, against every hittable and hazard in the room; 0 crossings: a hand test cannot prove an absence), plus a 20-minute **[Play]** pass for what the sweep does not try (rule 5, 12)
- **GIVEN** each key in turn, **WHEN** it is collected, **THEN** the gate matching its signature becomes passable, and no gate of another key's signature changes. **[Auto]** (rule 7)
- **GIVEN** the key table, **WHEN** the map is read, **THEN** each key's pickup names exactly one channel (boss, shrine or mentor). **[Auto]** (rule 10)

**Showing the lock, placing the key**
- **GIVEN** a new game, **WHEN** a tester plays the first 10 minutes without a guide, **THEN** at least one dash gap has been on screen and the tester can say where it is. **[Play]** (rule 8)
- **GIVEN** the room graph, **WHEN** each gate type whose key is found in the built region (core build: dash and wall cling) is counted along the main route before its key's pickup room, **THEN** at least two rooms show that gate type, and the first dash gate lies within the funnel's rooms. **[Auto]** (rule 8)
- **GIVEN** the room graph, **WHEN** the shortest path from each key's first gate room to its pickup room is measured ignoring locks (core build: dash and wall cling), **THEN** it is 3 or more room-to-room steps (graph edges), and at least one path to the pickup room crosses no gate of that key. **[Auto]** (rule 9)
- **GIVEN** a key was just collected (core build: dash and wall cling), **WHEN** the player leaves the pickup room, **THEN** the next room is a workshop of 1-2 screens that contains one lock of that key's type, and the player can walk back out of it without the key; the dash workshop's gap is at the `gap_min` end of the F1 window with a safe floor below, and the wall-cling workshop's wall is shorter than every cling wall seen before it. **[Auto + Play]** (rule 11)

**Topology**
- **GIVEN** the first region, **WHEN** its room graph is built, **THEN** it contains at least one loop and at least one shortcut that returns to a save point, and no room is reachable only by a path that cannot be left again. **[Auto]** (rules 14, edge case "return path")
- **GIVEN** the main route, **WHEN** the new screens walked between each pair of adjacent saves are counted by screen position (F4), **THEN** none exceeds `save_spacing_max` (7); screens already walked (backtracking, the walk back out of a dead end) count 0; a save at the far end of a multi-screen room counts that whole room when it is new; and a save exists before every boss and mini-boss. **[Auto]** (F4, rules 15, 16)
- **GIVEN** each boss and mini-boss arena, **WHEN** the room graph is read, **THEN** the save before it lies in the room just before the arena or its antechamber, and a loop home exists: a shortcut in the arena or within two rooms past it that returns to some save on the main route. **[Auto]** (rule 15)
- **GIVEN** region 1 in the core build, **WHEN** every double-jump and grapple gate is followed, **THEN** each has a sealed alcove on its far side in the same room, with its reward on screen from the gate's near side; no such gate leads to another room or exit; and each alcove beyond a gap gate has a way back to the near side with the start kit. **[Auto + Shot]** (rule 2)
- **GIVEN** region 1, **WHEN** the main route is read, **THEN** the dash pickup lies before the apex boss, and the apex boss arena lies beyond at least one dash gate and one wall-cling gate. **[Auto]** (key mapping)
- **GIVEN** a region at its first visit, **WHEN** the room graph is read, ignoring secrets and gated dead ends, **THEN** each of the first 5-10 rooms has exactly one unvisited exit to a new room on the critical path, and from the fork on at least two. **[Auto]** A tester asked "where would you go next?" in rooms 1-6 names that exit. **[Play]** (rule 13)

**Formulas**
- The gate-fit criteria (F1-F3, F6, F9, the `no_cling` unit test and the movement sweep) moved with their formulas to `design/gdd/ability-gating.md` (2026-11-18). The criteria below check placement.
- **GIVEN** every gate in a room, **WHEN** the room data is checked, **THEN** no pogo target (enemy spawn, patrol or flight bounds, breakable, target, hazard) lies inside its gate volume (F7); a breakable 100 px from a double-jump ledge's column is rejected at `pogo_clearance_px` 120 and one 130 px away passes; a patrol bound 20 px behind a dash gap's near edge passes, and flight bounds over the gap are rejected; spikes 80 px below a dash pit's lips are rejected and 90 px down pass (`hazard_pit_depth_min` 84); any hazard under a grapple gap is rejected. **[Auto]** (rule 24, F7, boundary)
- **GIVEN** a wall that must stay shut after the wall cling (Core Rules), **WHEN** the room data is checked, **THEN** it meets the ceiling or room bound with no opening, or it is `no_cling`. **[Auto]** (Core Rules, one wall is a ladder)
- **GIVEN** each gate and `no_cling` face, **WHEN** the painted room is captured with the collision overlay on, **THEN** the trim overhangs the collision edge by at most `trim_overhang_max` (4 px). **[Shot]** (rule 25)
- **GIVEN** a key and its changed rooms (rule 22), **WHEN** each faster route is timed with and without the key, **THEN** `speedup >= speedup_min` (0.3), and a route with speedup below 0 is flagged; each newly opened route is passable with the key and impassable without it; and at least one changed room is one the player skipped or could not finish. **[Auto]** for the newly opened checks on the room graph, **[Play]** for the timing (F5, rule 22)

**Room composition**
- **GIVEN** each room's data, **WHEN** it is checked, **THEN** its width and height are whole multiples of 480 and 270 px. **[Auto]** (rule 1)
- **GIVEN** the world state after any sequence of play, **WHEN** a key, gate, shortcut, boss, region, secret, sealed alcove or room changes state, **THEN** it only moves forward in the States table, never back. **[Auto]** (States and Transitions)
- **GIVEN** each shipped room, **WHEN** the grey-box review is run, **THEN** the room has a named job, no more than 3 free-standing platforms unless it is a platforming room, and a dead end carries a secret. **[Auto + Play]** (rules 17-19)
- **GIVEN** region 1, **WHEN** it is searched, **THEN** exactly one boss, one mini-boss and the one tutorial foe carry a guard meter, no normal enemy does, and the tutorial foe does not respawn after it is beaten. **[Auto]** (rule 20)
- **GIVEN** the boss is defeated, **WHEN** the player leaves the arena, **THEN** no "cleared" banner or screen appears and play continues in the world. **[Shot]** (rule 21)

**Cross-system**
- **GIVEN** a key collected and the player dying before the next save, **WHEN** the game reloads, **THEN** the key is still owned and its pickup is gone. **[Auto + Play]** (edge case; depends on world state and save points)
- **GIVEN** the map, **WHEN** a room is visited, **THEN** it appears as a box with exits as lines, unexplored exits marked, and no item locations shown. **[Shot]** (rule 23; depends on the grid map)

**Gaps found by the QA checks:** rules 17 ("a place first") and 13 (funnel then fork) are partly subjective; their criteria are playtest questions, not pass/fail numbers. The dash, wall-cling and double-jump gates cannot be tested until `PlayerState` has dash and wall cling flags (a later story).


## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **Lore.** Resolved 2026-11-18: The Kiln City, in `design/narrative/`. Region 1 is the Cooling Yards; its placement of Tavik, Brun and Dorrit's jar was re-ordered to this GDD's key mapping (owner, 2026-11-18), and the re-ordered beat order awaits approval.
2. **How many keys does the core region contain?** Resolved 2026-11-18: region 1 holds the dash and the wall cling; the double-jump and grapple gates are visible there and lead to sealed alcoves (rule 2).
3. **Mentor / hub pact for the double jump.** Resolved 2026-11-18: Pell, in region 2's Stacking Loft. Still open: the pact's confirm prompt (`mentor.pact.accept`) needs an interaction design, since the Seeker never speaks.
4. **Is climb part of wall cling?** Resolved: yes, gated together (ability gating rule 1). The flags and controller gating are a story (ability gating Open Question 1).
5. **Save spacing of 7 screens** (Blasphemous) is an untested start value for 480 px screens. Target: first playable region.
6. **Gate signatures and colours.** Waiting on the art bible (`/art-bible`). Target: before the terrain pipeline's painted pass.
7. **Region size.** The 25-35 room figure in the research is a recommendation for scope, not a measured target. Target: before the first region layout.
8. **Room data format and camera zones** are owned by the rooms-and-transitions GDD. Target: that GDD.
9. **Double jump as a mid-game key** changes the brief's earlier wording (double jump found in region 1); the brief's start-kit note has been recorded. Confirm there are no leftover references in stories 006-007.
10. **How many regions does the game have?** Resolved 2026-11-18 (owner): 5 regions. The brief's core build stays at region 1 only; its "out of scope" line now says the core build is one region of five.
11. **Key-to-region mapping.** Resolved 2026-11-18 (owner): region 1 gives the dash (mini-boss Keeper) and the wall cling (shrine behind a dash gate); region 2 the double jump; region 3 the grapple (boss Keeper). Still open: what regions 4 and 5 are for (remix, bow and spells, final boss). Names and the mentor need the lore. Target: before region 4's layout.
12. **Existing code vs the mapping.** Region 1 needs dash and wall cling flags in `PlayerState` (question 4), while the built gates and test rooms cover only the double jump and grapple; those stay as test rooms and become region 1's sealed-alcove gates. The brief's Features line now matches the mapping. Target: the story that adds the dash and wall cling flags.
13. **Grapple and air moves.** Resolved 2026-11-18 (owner, ability gating rules 18-19, F11): grapple-gate anchors are `gate_anchor`s, hooked in chain order; hooking one spends the air jump and air dash, and its jump-out restores neither (the spend rule, ability gating rule 18), so every anchor is needed.
14. **Dash-through barriers.** Resolved 2026-11-18 (owner): the bisque pane, broken only by a dash (ability gating rules 15-17, F10).
15. **Measure the simulated figures.** `landing_slack` (15), `max_non_grapple_crossing` (399; the fourth review's sim found 392.5), `kick_rise` (78) and `kick_cycle` (0.4 s), `wall_reach` (F8 table), `launch_rise` (78 and 132), `far_face_extra` (7), `pogo_rise` (38), `pogo_carry` (96-105), `pogo_clearance_px` (120), `hazard_pogo_reach` (76) and `hazard_pit_depth_min` (84) are simulated or recommended, not measured in the engine. Target: `movement_test_room`, before the first gate is built. The gate-fit figures are calculated too; their measurement is tracked under ability gating Open Question 3.
16. **The `no_cling` surface.** Adopted by ability gating (rule 14); the controller change and its unit test are tracked there (Open Question 2).
17. **Art scale and filtering.** The chosen look (black masses with painted trim, rule 25) comes from packs painted at 512-1024 px per tile; the game renders at 480 x 270 with nearest filtering and integer scaling. Decide the tile size at game scale, the filtering for painted textures, and whether the pixel-art Seeker fits on painted terrain, with one test room. Target: `/art-bible`, before any room is painted.
18. **Region 1's draft layout vs the fifth-review rules.** `design/narrative/kiln-city-level-integration.md` (draft, awaiting owner approval; the narrative side owns it, this GDD does not edit it) needs: Saggar Rows (room 4) widened to at least 2 screens wide and Ropewalk Stair (room 9) to at least 3 wide (rule 26, F9; owner decision: widen); its check list extended with rules 24-26, in particular the Cinder moths in room 5, whose flight bounds must stay out of that room's two gate volumes (F7); and its saves and shortcuts read by the new rules (loop homes S1 and S3; spacing by position, F4). Sixth review (2026-11-18): widening Saggar Rows to 2x2 makes N2 to N3 8 screens, so the owner added a save, N2b, on screen 2 of Saggar Rows (legs 3, 3, 4, 2, 7 and 3 in F4); the draft still needs to add and number it, name where S1 lands and whether Sweep Flue exits into rooms not yet walked (seventh review: F4 counts new ground only, so the walk back from the shrine counts 0 and the post-dash legs are within 7 unless it does), and read its sealed alcoves A1-A4 as nooks in the gate rooms (rule 2), not as rooms. Its dash gaps in rooms 3 and 5 and the Warm Flue workshop must meet the F1 pit rules. Target: before the grey-box of rooms 3-5, 9 and 13.
19. **Which walls carry the wall-cling signature.** Resolved 2026-11-18 (owner, ability gating rule 11): the grooves mark every cling wall placed as a gate (the walls counted for rule 8) and every `climbable` surface; other plain walls are unmarked but climbable.
20. **Pogoable hazards in gate gaps.** Owner, seventh review (2026-11-18): spikes can be pogoed (rule 24). Ability gating's F1 lets a dash pit's floor be "a hazard" and F3b puts a grapple gap "over a hazard or kill plane", with no depth for the hazard. Until ability gating adds one, this GDD allows a hazard in a dash pit only at `hazard_pit_depth_min` (about 84 px) below the lips and puts kill planes, not hazards, under grapple gaps (a pogo refreshes the air jump and air dash, so with keys 1-3 a hazard floor needs a much deeper chasm, roughly 140 px or more by estimate). The registry's `dash_gap_window` note (`pit_depth_min` about 72) changes with it. Making hazards pogoable in code is a Combat story. Target: the ability gating re-review.
