# Level design and world layout

> **Status**: In Review (second `/design-review` 2026-11-18: 4 blockers revised, key-to-region mapping confirmed by the owner; awaiting re-review)
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

1. The world is a graph of **rooms**. A room is a whole number of 480x270 screens (1x1 connector, 1x3-4 shaft, 3-4x1 hall, rare set piece up to about 8 screens). Rooms group into **regions**; a region has one identity (palette, enemies, architecture, music), one boss at its apex and at least one save point. **[Rec]**
2. The full game is **5 regions** **[Owner, 2026-11-18]**. The core build is **one region**, region 1 (brief scope), built so the other four can attach at its edges. Its gates for keys region 1 does not give (double jump, grapple) are real and visible. In the core build each leads to a **sealed alcove**: one screen with a reward the player can see but not reach (a pickup or a lore item). The alcove counts as that dead end's secret (rule 19) and as a room with a job (rule 18, secret), and it is filled when its key exists. **[Owner, 2026-11-18]**
3. Rooms are authored on a grey-box first: collision only, no art, played and approved before any tile or painting is added. **[Sourced]** (Ori's "design approved" gate)

**Start state and key order**

4. The Seeker starts with: run, jump, the whole sword set (3-hit combo, up and down attacks, pogo, charged heavy), crouch, doors. **[Owner]**
5. Keys are earned in this order. Nothing in the start kit may open any gate in the table. **[Owner for order; the gate and source columns are Rec]**

| # | Key | Opens (gate signature) | Found by | Why here |
|---|-----|------------------------|----------|----------|
| 1 | Dash | Gaps inside the F1 window (about 137-150 px at margin 15), too wide for any run-jump; dash-through barriers | Keeper: region 1's mini-boss, mid-region (after the funnel's fork) | Horizontal key first in every benchmark; seen as an uncrossable gap in the first minutes |
| 2 | Wall cling (wall slide, wall jump, climb) | Tall shafts and walls with a cling surface | Shrine in region 1, behind a dash gate; found by exploring | Opens the vertical world; walls are ladders once it exists, so it is earned before the double jump |
| 3 | Double jump | Ledges 72-108 px up in open air | Region 2: mentor / hub pact (or a second shrine, if the lore has no mentor) | The mid-game hinge: where the map opens to three or four valid directions |
| 4 | Grapple | Authored anchors only: F3a ledges above double-jump reach, F3b gaps wider than any non-grapple crossing, crossed by a chain of anchors | Keeper: region 3's boss | Opens only the locks you place, so it is the safe late key; later grows into grapple-to-enemy |

**Key-to-region mapping [Owner, confirmed 2026-11-18].** The full game is **5 regions**; the core build is region 1 only (brief). Region 1 gives the dash (its mini-boss, a Keeper, mid-region) and the wall cling (a shrine behind a dash gate); region 2 gives the double jump; region 3's boss (a Keeper) gives the grapple; regions 4 and 5 add no movement key (they remix the four; the bow, spells and grapple-to-enemy come later). Region 1's apex boss sits beyond at least one dash gate and one wall-cling gate, so the core build runs the whole loop (fight, gain a verb, open the world, fight again) twice before its goal. The double-jump and grapple gates are *seen* in region 1 and pay off in later regions (rule 2).

6. The bow and the spell casts are not movement keys and gate nothing in the core build; they are earned later (Alpha). **[Owner]**
7. Every key opens few locks, has one visual signature that nothing else in the world uses, and changes combat as well as movement (dash: dodge and gap-close; wall cling: wall-based attack angles; double jump: second air window; grapple: pull and fling). **[Sourced]** (Metroid Dread: few locks per key; one material per key)

**Showing the lock, placing the key**

8. A gate is **seen before its key is found**, at least twice, the first time within the first 10 minutes of play for the dash gate. **[Owner for the principle; counts Rec]**
9. A key is never found in the same room as its first gate, nor fewer than 3 rooms from it (shortest path through the room graph, ignoring locks), and never in a room that can be reached only by the key itself. **[Owner for "never in front of the gate"; numbers Rec]**
10. Every key is found by exactly one of the three channels, named by the pickup: boss (a Keeper), shrine / relic pedestal (exploration), or mentor / hub pact (narrative). A pickup does not care which; gating only reads "owned". **[Owner]**
11. After each key, the next room is a **learning workshop**: a one-room exit that uses the new key on a smaller instance of a lock the player has already seen. The player can always leave again; the workshop is a short test, not a trap. **[Sourced]** (Lost Crown, sandbox escape)
12. Soft gates are allowed and not hunted down: a skilled player who gets past a gate early with the current kit is rewarded, as long as the world stays coherent (no soft-lock, no missed boss trigger). **[Sourced]**

**Topology**

13. The first region is a **funnel**: one objective at a time for the first 5-10 rooms, then a fork to two or three directions. Late in the game, openness rises to three or four valid directions. **[Sourced]** (Silksong acts; Team Cherry)
14. Rooms form **loops**, not trees: every region has at least one shortcut that folds back to a save point (one-way door, breakable wall, lever, lift or drop). Shortcut gates open from the far side first. **[Sourced]** (shortcut folding; Blasphemous found one-use levers overused, so mix breakable walls and doors)
15. A save point is placed before every boss and mini-boss, and the route from that save to the arena never exceeds `save_spacing_max` screens (F4, starts at 7). The arena is always within one room of a shortcut back to that save. **[Sourced]** (Blasphemous, Ender Lilies)
16. No more than `save_spacing_max` screens (F4, starts at 7) of travel between two adjacent save points on the main route. **[Sourced]** (Blasphemous)

**Room composition**

17. A room is a place first ("a flooded cavern, a ruined tower stair"), then a layout. Floors and mass terrain carry the room; floating islands are allowed; free-standing platforms are rare and only where a gate needs them. No room has more than 3 free-standing platforms unless it is a designated platforming room. **[Owner for the principle; limit Rec]**
18. Every room has a job: connector, shaft, combat room, platforming challenge, hub, save, secret or boss antechamber. A room that does none of them is cut. **[Rec]**
19. A secret follows a pattern the game has already shown (a cracked wall, an off-screen ledge, a dead end with something just out of sight), and a dead end without a secret is cut. **[Sourced]** (Animal Well: break from the pattern; Dread: hidden blocks on the main path always have a hint)
20. Only bosses and mini-bosses carry a guard. Region 1 has one boss and one mini-boss; each later region has one boss. Normal enemies have health only. **[Owner]** One exception: a single scripted **tutorial foe** in the first minute carries a weak guard to teach guard-break (brief: First minute); it appears once and never respawns. **[Owner, 2026-11-18]** Region 1's mini-boss is the brief's "tougher guarded enemy": it guards the dash and is a Keeper (key table). **[Owner, 2026-11-18]**
21. There is no "region cleared" screen, banner or lock-out. A beaten boss opens doors and changes the world quietly. **[Owner]**

**Backtracking and flow**

22. Each key changes at least two old rooms in a new way, and at least one of them is a room the player skipped or could not finish before. A changed room is either a **faster route** (it was passable before; F5 `speedup >= speedup_min`) or a **newly opened route** (impassable before, so F5 does not apply; it counts when the key makes a seen gate or dead end passable). **[Sourced]** (re-contextualized geometry)
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
| Ability gating | Both | In: gate types, dimensions and visual signatures. Out: which gate sits where and what key it needs | Gating owns types and visuals; this system owns placement and order and, provisionally, the gate-fit formulas F1-F3 |
| Bosses | In | Boss rooms, defeat flag, what the boss grants | Bosses |
| Enemies | In | Enemy types and rosters placed in rooms | Enemies |
| World state | Both | Out: keys obtained, bosses defeated, shortcuts opened, secrets found. In: reads for gate state | World state |
| Save points | Out | Save locations and the 7-screen spacing rule | Save points |
| Grid map | Out | Room graph, exits, unexplored markers | Grid map |
| Fast travel (later) | Out | Which rooms may be travel points | Fast travel |
| Collectible upgrades (later) | Out | Where reward rooms sit and how many | Collectible upgrades |
| Lore and mentor (later) | Out | Where the mentor hub and lore sit | Lore delivery |


## Formulas

All Seeker figures are **[Calc]** from `src/player/player_config.tres` at 60 Hz (the research report, re-simulated in the 2026-11-18 design review). `run_jump_distance` includes coyote time; none of them include `corner_correction` (6 px) or `ledge_nudge` (5 px), which can extend a landing by a few pixels, so re-measure in `movement_test_room` before any gate is built. Margins and spacing values are `data file` knobs, not constants.

**F1-F3 are provisional here.** The systems index gives gate dimensions to Ability gating, but that GDD does not exist, so these formulas live in this document until it does. When it is written it adopts F1-F3 (or amends them with a recorded reason) and this document links to it; neither GDD keeps a second copy.

### F1. Dash gap window

The dash_gap formula is defined as:

`gap_min = run_jump_distance + gap_margin`; `gap_max = dash_jump_distance - gap_margin`; a dash gap of width W is valid when `gap_min <= W <= gap_max`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| run_jump_distance | float (px) | about 122 | calculated from player_config | Farthest a running jump crosses without dash, coyote time included: about 108 flat (60 Hz sim of `player_config.tres`) plus 14 (coyote_time 0.1 s x run_speed 140) |
| dash_jump_distance | float (px) | about 165 | calculated from player_config | Farthest a ground dash-jump crosses (dash, then jump, carrying `dash_jump_speed_keep`). The window is built on this, the weakest dash technique: a run-jump then air dash reaches about 180 px, so any gap in the window is crossable both ways |
| gap_margin | float (px) | 8-15 | data file | Keeps a perfect jump from leaking through and the dash from missing |
| W | float (px) | gap_min to gap_max | data file (room data) | Width of the gap |

**Output Range:** 137 to 150 px at margin 15 and 130 to 157 px at margin 8; at margin 0 a perfect run-jump with coyote leaks through at about 122 px; the window closes above a margin of about 21 px (width = 43 - 2 x margin). `dash_jump_distance` re-simulated at about 164 px (2026-11-18 review). Because `ledge_nudge` can add up to about 5 px to a run-jump landing, keep `gap_margin` at 12 or more until `movement_test_room` measures it.
**Example:** a 140 px gap (margin 15) needs the dash and the dash clears it; a 135 px gap is rejected at margin 15 (below `gap_min` 137, too close to what a coyote run-jump can reach).

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
| cling_exclusion_px | float (px) | 100-160, starts at 122 | data file | Open-air test distance: no cling surface within this horizontal distance of any standing point below the ledge, at any height from the floor up to `jump_apex`. Set to `run_jump_distance`: a wall one jump away can be kicked (about 80 px per kick), and 61 + 80 = about 141 px exceeds `ledge_max`. Not the 3 px `wall_jump_reach` in `player_config.tres`, which is only the wall contact tolerance (`player.gd`) |

**Output Range:** 72 to 108 px at margins 12 and 7. Valid only in open air (the open-air test above): wall cling is owned by then, so a cling surface within `cling_exclusion_px` makes the ledge a ladder. Ledges between `ledge_max` and the F3a minimum (about 109-120 px) fit no gate and are not used as gates; they may appear only where nothing depends on reaching them.
**Example:** a ledge 90 px above the floor in open air needs the double jump.

### F3. Grapple gate

Two gate shapes; both are valid only if no earlier key can cross them.

**F3a. Grapple ledge.** `target_height >= double_jump_total + grapple_margin`, with an anchor within `grapple_range` of a standing point, and the F2 open-air test applied (no cling surface within `cling_exclusion_px` of any standing point below the ledge, from the floor up to `target_height`): wall cling and climb are owned by then, so a nearby wall makes any height a ladder.

**F3b. Grapple gap.** `gap_width >= max_non_grapple_crossing + grapple_margin`, crossed by a chain of anchors where the take-off point, each anchor and the far floor are each within `grapple_range` of the previous one, and every anchor sits in open air (no cling surface within `cling_exclusion_px`).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| target_height | float (px) | 121 or more | data file (room data) | Height of the ledge above the standing floor (F3a) |
| gap_width | float (px) | about 410 or more | data file (room data) | Horizontal width of the gap (F3b) |
| max_non_grapple_crossing | float (px) | about 396 | calculated from player_config | Farthest gap crossed with dash, double jump and air dash: ground dash-jump, double jump, then air dash (60 Hz sim, 2026-11-18 review). Re-measure; it assumes the grapple does not refresh air moves |
| grapple_range | float (px) | 200 | data file (player_config) | Farthest anchor the grapple reaches |
| grapple_margin | float (px) | 6-20 | data file | Keeps the double jump (F3a) or the best combined crossing (F3b) from reaching the target |

**Output Range:** F3a: targets 121+ px up with an anchor within 200 px, in open air. F3b: gaps of about 402-416 px or more (margin 6-20), which need at least two anchors, since three hops of at most 200 px each are needed to span more than 400 px.
**Example:** F3a: a ledge 160 px up in open air with an anchor 24 px beyond its edge. F3b: a 420 px chasm with anchors at 140 px and 280 px from the take-off edge, each hop 140 px.

### F4. Save spacing

The save_spacing rule is defined as:

`route_screens(save_a, save_b) <= save_spacing_max` for adjacent saves on the main route. The **main route** is the shortest path through the room graph that collects each key and beats each boss and mini-boss in key order. A room of more than one screen counts as all of its screens; the two save rooms and the boss or mini-boss arena are not counted.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| route_screens | int | 1 to save_spacing_max | calculated from the room graph | Screens on the main route between two saves |
| save_spacing_max | int | 5-10 | data file | Upper bound; starts at 7 (Blasphemous), tuned in playtest |

**Output Range:** at most 7 screens. A 480 px screen crosses in about 3.4 s at 140 px/s, so 7 screens is about 24 s of pure running and roughly 2-4 minutes with fights and platforming.
**Example:** save, 2-screen hall, 1x3 shaft, 1-screen combat room, 1-screen boss antechamber, boss arena (not counted): 7 screens, valid.
**Edge:** 0 is undefined; oversized rooms count by screen, not as one.

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

**Feedback loops:** keys make old rooms faster, which makes revisiting cheaper and encourages exploring; intended, bounded by shortcuts (enemy respawn rules belong to the Enemies GDD, not yet written). A later key leaking into an earlier gate (double jump over a dash gap) is also intended.

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
- **If a double-jump ledge fails the F2 open-air test** (a cling surface within `cling_exclusion_px`; wall cling is owned by then): the wall is a ladder and the gate leaks. The room is rebuilt in open air or the wall gets a non-cling surface.
- **If the player owns all four keys and a route's speedup is below the minimum** (F5): the route is redesigned or marked as not part of the key's two-route promise; it is not left as a tiresome back-track.
- **If save spacing would exceed `save_spacing_max` screens on the main route** (F4): add a save or a shortcut. The rule never counts rooms of more than one screen as one.
- **If a mini-boss or boss room locks behind the player**: the player always has a way out by winning or dying; a locked arena never traps without a respawn.
- **If a player reaches a sealed alcove in the core build** (rule 2): the reward stays visible and unreachable; nothing breaks, and the alcove is listed as a secret, not as Found, until its key exists.
- **If the tutorial foe is skipped or the player dies to it** (rule 20): it never respawns once beaten; if the player dies before beating it, it is back on respawn, and the path past it stays open either way.


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

**Bidirectional check:** none of the other GDDs exists, so each needs a matching entry when it is designed. Ability gating and level design are circular by design (see the systems index); the contract is: gating owns gate types and visuals, level design owns placement and order, and F1-F3 (gate-fit formulas) sit in this GDD as provisional until the gating GDD adopts them (see the note under Formulas).


## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The look itself is owned by the terrain pipeline and the parallax, lighting and atmosphere systems; this section lists only what level design needs from them.

- **Gate language:** each key has one signature (shape, material and colour) that nothing else in the world uses, so a gate is readable from across a room. The palette is chosen with the art bible (not yet written) and replaces the placeholder colours of the gate test room.
- **Region identity:** each region reads as a distinct place by palette, architecture, enemies and music, so the player always knows where they are. **[Sourced]** (Silksong: architecture tells you where you are)
- **Readability:** play-layer collision edges are the brightest values in a room and the room reads in greyscale; backgrounds and foreground framing never imitate a platform or a gate. **[Sourced]** (Saltsman)
- **Quiet transitions:** a beaten boss, an opened shortcut and a granted key change the world through animation, sound and light only; no banner or "cleared" screen (rule 21).
- **Audio:** each region has its own music and ambience; a gate you cannot yet open has a small audio tell when first approached; a key pickup has a clear, short cue; a shortcut opening has a distinct sound.

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:level-design` to produce per-asset descriptions and generation prompts from this section.

## Game Feel

Targets are measurable, so they can be checked in a playtest; the Seeker's movement and combat feel is owned by the controller and combat systems.

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
| run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, max_non_grapple_crossing (F1-F3) | Player controller / movement | Calculated from `player_config.tres`; to be registered |
| grapple_range (F3) | Player controller / movement | In `player_config.tres` (200 px) |
| Gate types, dimensions, signatures | Ability gating | Code exists; GDD to be written |
| Room graph, exits, camera limits | Rooms and transitions | Not designed |
| Key, boss, shortcut and secret flags | World state | Not designed |
| Boss defeat flag, boss reward | Bosses | Code exists (`boss_defeated`) |
| Save locations, spacing (F4) | Save points and save/load | Not designed |

## Acceptance Criteria

Types: **[Auto]** automated test on room data or the room graph; **[Play]** playtest record; **[Shot]** retained screenshot in `production/qa/evidence/`. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. `qa-lead` not consulted: Lean mode; the checks in `references/lens-qa-lead.md` were applied by the author.

**Start state and keys**
- **GIVEN** a new game, **WHEN** the Seeker loads in the first room, **THEN** the player owns run, jump, the full sword set, crouch and doors, and owns none of dash, wall cling, double jump, grapple, bow or spells. **[Auto]** (rule 4, 6)
- **GIVEN** the start kit only, **WHEN** a tester tries every dash gap, wall-cling shaft, double-jump ledge and grapple target in the region by any means in the kit, **THEN** each one is blocked, except those logged as deliberate soft gates. **[Play]** (rule 5, 12)
- **GIVEN** each key in turn, **WHEN** it is collected, **THEN** the gate matching its signature becomes passable, and no gate of another key's signature changes. **[Auto]** (rule 7)
- **GIVEN** the key table, **WHEN** the map is read, **THEN** each key's pickup names exactly one channel (boss, shrine or mentor). **[Auto]** (rule 10)

**Showing the lock, placing the key**
- **GIVEN** a new game, **WHEN** a tester plays the first 10 minutes without a guide, **THEN** at least one dash gap has been on screen and the tester can say where it is. **[Play]** (rule 8)
- **GIVEN** the room graph, **WHEN** each gate type is counted along the main route before its key's pickup room, **THEN** at least two rooms show that gate type, and the first dash gate lies within the funnel's rooms. **[Auto]** (rule 8)
- **GIVEN** the room graph, **WHEN** the shortest path from each key's first gate room to its pickup room is measured ignoring locks, **THEN** it is 3 rooms or more, and at least one path to the pickup room crosses no gate of that key. **[Auto]** (rule 9)
- **GIVEN** a key was just collected, **WHEN** the player leaves the pickup room, **THEN** the next room is a workshop of 1-2 screens that contains one lock of that key's type, and the player can walk back out of it without the key. **[Play]** (rule 11)

**Topology**
- **GIVEN** the first region, **WHEN** its room graph is built, **THEN** it contains at least one loop and at least one shortcut that returns to a save point, and no room is reachable only by a path that cannot be left again. **[Auto]** (rules 14, edge case "return path")
- **GIVEN** the main route, **WHEN** screens between each pair of adjacent saves are counted, **THEN** none exceeds `save_spacing_max` (7), and a save exists before every boss and mini-boss. **[Auto]** (F4, rules 15, 16)
- **GIVEN** each boss and mini-boss arena, **WHEN** the room graph is read, **THEN** a shortcut back to the save before it starts within one room of the arena. **[Auto]** (rule 15)
- **GIVEN** region 1 in the core build, **WHEN** every double-jump and grapple gate is followed, **THEN** each leads to a one-screen sealed alcove with a visible reward, and no such gate leads anywhere else. **[Auto + Shot]** (rule 2)
- **GIVEN** region 1, **WHEN** the main route is read, **THEN** the dash pickup lies before the apex boss, and the apex boss arena lies beyond at least one dash gate and one wall-cling gate. **[Auto]** (key mapping)
- **GIVEN** a region at its first visit, **WHEN** the player is in the first 5-10 rooms, **THEN** only one objective is open; afterwards at least two directions are open. **[Play]** (rule 13)

**Formulas**
- **GIVEN** a dash gap of width W, **WHEN** the room data is checked, **THEN** `gap_min <= W <= gap_max`; a gap at `gap_min - 1` is rejected, and a gap at `gap_max + 1` is rejected. **[Auto]** (F1, boundary)
- **GIVEN** a double-jump ledge of height h in open air, **WHEN** checked, **THEN** `ledge_min <= h <= ledge_max`, and the open-air test passes (no cling surface within `cling_exclusion_px` horizontally of any standing point below it, from the floor up to `jump_apex`); a ledge with a cling surface 100 px away is rejected. **[Auto]** (F2, boundary)
- **GIVEN** a grapple ledge (F3a), **WHEN** checked, **THEN** `target_height >= double_jump_total + grapple_margin`, an anchor lies within 200 px of a standing spot, and the open-air test passes; a ledge 120 px up is rejected, and a 160 px ledge with a cling surface 100 px away is rejected. **[Auto]** (F3a, boundary)
- **GIVEN** a grapple gap (F3b), **WHEN** checked, **THEN** `gap_width >= max_non_grapple_crossing + grapple_margin` and every hop (take-off, anchors, far floor) is at most `grapple_range`; a 400 px gap is rejected, and a chain with one 210 px hop is rejected. **[Auto]** (F3b, boundary)
- **GIVEN** the movement values in `player_config.tres`, **WHEN** the Seeker attempts F1-F3 gates in `movement_test_room`, **THEN** a perfect run-jump never crosses a dash gap, a plain jump never touches a double-jump ledge, the double jump never reaches a grapple ledge, and dash, double jump and air dash together never cross a grapple gap. **[Play]** (re-measure the [Calc] figures)
- **GIVEN** a key and its changed rooms (rule 22), **WHEN** each faster route is timed with and without the key, **THEN** `speedup >= speedup_min` (0.3), and a route with speedup below 0 is flagged; each newly opened route is passable with the key and impassable without it; and at least one changed room is one the player skipped or could not finish. **[Auto]** for the newly opened checks on the room graph, **[Play]** for the timing (F5, rule 22)

**Room composition**
- **GIVEN** each shipped room, **WHEN** the grey-box review is run, **THEN** the room has a named job, no more than 3 free-standing platforms unless it is a platforming room, and a dead end carries a secret. **[Auto + Play]** (rules 17-19)
- **GIVEN** region 1, **WHEN** it is searched, **THEN** exactly one boss, one mini-boss and the one tutorial foe carry a guard meter, no normal enemy does, and the tutorial foe does not respawn after it is beaten. **[Auto]** (rule 20)
- **GIVEN** the boss is defeated, **WHEN** the player leaves the arena, **THEN** no "cleared" banner or screen appears and play continues in the world. **[Shot]** (rule 21)

**Cross-system**
- **GIVEN** a key collected and the player dying before the next save, **WHEN** the game reloads, **THEN** the key is still owned and its pickup is gone. **[Auto + Play]** (edge case; depends on world state and save points)
- **GIVEN** the map, **WHEN** a room is visited, **THEN** it appears as a box with exits as lines, unexplored exits marked, and no item locations shown. **[Shot]** (rule 23; depends on the grid map)

**Gaps found by the QA checks:** rules 17 ("a place first") and 13 (funnel then fork) are partly subjective; their criteria are playtest questions, not pass/fail numbers. The dash, wall-cling and double-jump gates cannot be tested until `PlayerState` has dash and wall cling flags (a later story).


## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **Lore.** Not yet provided; region names, the mentor and the world's reason to exist wait on it. Target: before the first narrative pass and the mentor channel.
2. **How many keys does the core region contain?** Resolved 2026-11-18: region 1 holds the dash and the wall cling; the double-jump and grapple gates are visible there and lead to sealed alcoves (rule 2).
3. **Mentor / hub pact for the double jump.** Needs the lore; fallback is a second shrine (rule table). Target: with the lore.
4. **Is climb part of wall cling?** Assumed yes (slide, wall jump and climb gated together). Needs `PlayerState` flags for dash and wall cling and a gating pass in `player.gd` (a later story). Target: when story 007 sets the real starting state.
5. **Save spacing of 7 screens** (Blasphemous) is an untested start value for 480 px screens. Target: first playable region.
6. **Gate signatures and colours.** Waiting on the art bible (`/art-bible`). Target: before the terrain pipeline's painted pass.
7. **Region size.** The 25-35 room figure in the research is a recommendation for scope, not a measured target. Target: before the first region layout.
8. **Room data format and camera zones** are owned by the rooms-and-transitions GDD. Target: that GDD.
9. **Double jump as a mid-game key** changes the brief's earlier wording (double jump found in region 1); the brief's start-kit note has been recorded. Confirm there are no leftover references in stories 006-007.
10. **How many regions does the game have?** Resolved 2026-11-18 (owner): 5 regions. The brief's core build stays at region 1 only; its "out of scope" line now says the core build is one region of five.
11. **Key-to-region mapping.** Resolved 2026-11-18 (owner): region 1 gives the dash (mini-boss Keeper) and the wall cling (shrine behind a dash gate); region 2 the double jump; region 3 the grapple (boss Keeper). Still open: what regions 4 and 5 are for (remix, bow and spells, final boss). Names and the mentor need the lore. Target: before region 4's layout.
12. **Existing code vs the mapping.** Region 1 needs dash and wall cling flags in `PlayerState` (question 4), while the built gates and test rooms cover only the double jump and grapple; those stay as test rooms and become region 1's sealed-alcove gates. The brief's Features line now matches the mapping. Target: the story that adds the dash and wall cling flags.
13. **Grapple and air moves.** F3b assumes the grapple does not refresh the double jump or the air dash; if it does, chained-anchor gaps can be skipped partway. Target: the gating GDD.
