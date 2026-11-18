# Level design and world layout

> **Status**: In Review (fourth `/design-review` 2026-11-18: 3 blockers revised (one wall is a ladder: F6 cling wall and F8 wall launch reach; head height and own faces in F2/F3a; chasm far face and floor in F3b; `no_cling` surface added); awaiting re-review)
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
| 1 | Dash | Gaps inside the F1 window (about 145-162 px at margin 8, edge to edge), too wide for any run-jump. Dash-through barriers are cut until the Ability gating GDD defines a barrier type (Open Question 14) | Keeper: region 1's mini-boss, mid-region (after the funnel's fork) | Horizontal key first in every benchmark; seen as an uncrossable gap in the first minutes |
| 2 | Wall cling (wall slide, wall jump, climb) | Cling walls (F6a: any plain face at least `ledge_min` tall with no standing spot on it) and climb walls (F6b, marked surfaces) | Shrine in region 1, behind a dash gate; found by exploring | Opens the vertical world; walls are ladders once it exists, so it is earned before the double jump |
| 3 | Double jump | Ledges 72-108 px up that pass the F2 cling test (no plain underside below the head, no launch face) | Region 2: mentor / hub pact (or a second shrine, if the lore has no mentor) | The mid-game hinge: where the map opens to three or four valid directions |
| 4 | Grapple | Authored anchors only: F3a ledges above double-jump reach, F3b gaps wider than any non-grapple crossing, crossed by a chain of anchors | Keeper: region 3's boss | Opens only the locks you place, so it is the safe late key; later grows into grapple-to-enemy |

**Cling surface [Owner, 2026-11-18].** Any solid wall face lets the Seeker slide and wall-jump once the wall cling is owned (the code today); only surfaces marked `climbable` can be climbed. The F2, F3, F6 and F8 tests use this definition.

**One wall is a ladder [Owner, fourth review 2026-11-18].** A wall jump needs only a wall within 3 px (`_wall_jump_direction`), so the Seeker can kick off one wall, steer back and kick again: about 77 px per kick, every 0.4 s, with no limit (**[Calc]**, 60 Hz sim). Once the wall cling is owned, every **plain** face (a solid face not marked `no_cling`) can be climbed to its top. A wall that must stay shut after the wall cling either meets the ceiling or room bound with no opening, or is `no_cling`.

**No-cling surface [Owner, fourth review 2026-11-18].** A face marked `no_cling` cannot be slid on or kicked off. It carries one visual signature that no other surface uses (candidate: the thorn vines of the Mossy Cavern pack; chosen with the art bible). It is how a gate ledge, a chasm or a nearby wall keeps the wall cling from becoming a ladder (F2, F3, F8) without being a thin slab. It needs a controller change (Open Question 16) and is provisional until the Ability gating GDD adopts it.

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

**Gate integrity**

24. **Pogo clearance.** The start kit's pogo (a down attack that hits a `hittable`: launch 260 px/s, about 38 px of rise, air moves refreshed, repeatable) is a free extra jump over anything hittable. No hittable (enemy spawn point or patrol or flight bounds, breakable, target, boss add) may lie inside the **gate volume** of any gate: the gap and the air above it (F1, F3b), the column under the ledge (F2, F3a) or the cling wall (F6a), from the floor up to the earlier kit's reach height plus `pogo_rise` (F7). A column gate's volume is widened by `pogo_clearance_px` on each side; a gap gate's volume ends `hitbox_width` past each lip (F7). A room that breaks this is rebuilt, not logged as a soft gate. Hazards are not pogo targets in the current code (only the `hittable` group is). **[Owner decision 2026-11-18: clearance rule; distance Rec and Calc]**
25. **Collision and trim.** Terrain is black collision masses with rock or moss trim painted on their edges **[Owner, 2026-11-18]** (the look of the Maaot Brown Cave and Mossy Cavern packs; see Visual/Audio). The collision edge is the line between the black mass and its trim. At every gate (F1-F3, F6) and at every `no_cling` face, the trim may overhang the collision by at most `trim_overhang_max` (starts at 4 px at game scale, **[Rec]**), so a gap or ledge reads at its real size; elsewhere trim is free. All gate figures are measured on collision, never on art. **[Owner for the look; overhang Rec]**


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
| Sealed alcove (core build, rule 2) | Sealed, Found | Visible from the start, so it is never Hidden. Sealed to Found when its key exists and the player reaches the reward. It satisfies rule 18 (a room with a job) and rule 19 (the dead end's secret) from the start; it is not counted as a found secret until it is Found. |
| Room | Unvisited, Visited | Visited on first entry; drives the grid map. |

No state in this table can move backward.


### Interactions with Other Systems

None of the upstream systems has a GDD yet; the interfaces below are the contract this system expects and are **provisional** until each is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Rooms and transitions | In | Room units, exits, doors, per-room camera limits, room graph | Rooms and transitions |
| Terrain pipeline | In | Collision and tile rules a room is built from; the grey-box to painted path | Terrain pipeline |
| Ability gating | Both | In: gate types, dimensions and visual signatures. Out: which gate sits where and what key it needs | Gating owns types and visuals; this system owns placement and order and, provisionally, the gate-fit formulas F1-F3, F6 and F8 |
| Bosses | In | Boss rooms, defeat flag, what the boss grants | Bosses |
| Enemies | In | Enemy types and rosters placed in rooms, with spawn points and patrol or flight bounds for the pogo clearance check (rule 24, F7) | Enemies |
| World state | Both | Out: keys obtained, bosses defeated, shortcuts opened, secrets found. In: reads for gate state | World state |
| Save points | Out | Save locations and the 7-screen spacing rule | Save points |
| Grid map | Out | Room graph, exits, unexplored markers | Grid map |
| Fast travel (later) | Out | Which rooms may be travel points | Fast travel |
| Collectible upgrades (later) | Out | Where reward rooms sit and how many | Collectible upgrades |
| Lore and mentor (later) | Out | Where the mentor hub and lore sit | Lore delivery |


## Formulas

All Seeker figures are **[Calc]** from `src/player/player_config.tres` at 60 Hz (the research report, re-simulated in the 2026-11-18 design review). `run_jump_distance` includes coyote time. Every horizontal figure is **centre travel** (how far the Seeker's centre moves), not a gap width: a gap `W` is measured edge to edge, and the 10 px hitbox plus `ledge_nudge` (5 px) let a landing succeed up to `landing_slack` (15 px) beyond the centre travel (F1, F3b). `corner_correction` (6 px) only acts under a low ceiling and is not in any figure. The Seeker's box is 10 x 22 px with its bottom on the feet point (`_apply_hitbox`), and a wall jump starts when any part of the box is within 3 px of a face, so every vertical test uses the **head height** (feet + `hitbox_height`, 22 px), not the feet: at the top of a plain jump the head is at about 81 px. The fourth review (2026-11-18) re-simulated the controller at 60 Hz and reproduced the run-jump (107 + 14 coyote), apex (58.7), dash-jump (164.4), double jump (113.5) and kick (77.6); it found 392.5 for `max_non_grapple_crossing`, so the 399 used below is on the safe side. Re-measure in `movement_test_room` before any gate is built. Margins and spacing values are `data file` knobs, not constants; the Auto checks read the movement figures from `player_config.tres`, not from the constants in this document.

**F1-F3, F6 and F8 are provisional here.** The systems index gives gate dimensions to Ability gating, but that GDD does not exist, so these formulas live in this document until it does. When it is written it adopts them (or amends them with a recorded reason) and this document links to it; neither GDD keeps a second copy.

### F1. Dash gap window

The dash_gap formula is defined as:

`landing_slack = hitbox_width + ledge_nudge`; `run_jump_reach = run_jump_distance + landing_slack`; `dash_jump_reach = dash_jump_distance + hitbox_width / 2`; `gap_min = run_jump_reach + gap_margin`; `gap_max = dash_jump_reach - gap_margin`; a dash gap of edge-to-edge width W is valid when `gap_min <= W <= gap_max`.

Why the slack differs at the two ends. The leak side takes the most favourable case for the player: the Seeker can stand with its centre up to half the hitbox (5 px) past the edge, lands when its leading edge (another 5 px) touches the far lip, and `ledge_nudge` lifts the feet up to 5 px onto a lip they just missed. The nudge is a vertical lift: it lets the Seeker land slightly later in its fall, which adds only about 2 px of horizontal reach (fourth review sim), so counting it as 5 px is a safe upper bound. A run-jump therefore crosses a gap up to `run_jump_distance + 15` wide at most. The crossable side takes the least favourable case: take-off with the centre at the edge, so the dash-jump is only credited the 5 px of the leading edge.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| run_jump_distance | float (px) | about 122 | calculated from player_config | Farthest centre travel of a running jump without dash, coyote time included: about 108 flat (60 Hz sim of `player_config.tres`) plus 14 (coyote_time 0.1 s x run_speed 140) |
| hitbox_width | float (px) | 10 | player_config (`hitbox_size.x`) | Width of the Seeker's collision box |
| ledge_nudge | float (px) | 5 | player_config | Lip-catch allowance in `player.gd` |
| landing_slack | float (px) | 15 | calculated | `hitbox_width + ledge_nudge`: how far an edge-to-edge gap can exceed the centre travel and still be crossed |
| dash_jump_distance | float (px) | about 165 | calculated from player_config | Farthest centre travel of a ground dash-jump (dash, then jump, carrying `dash_jump_speed_keep`; sim 164.4). The window is built on this, the weakest dash technique: a run-jump then air dash reaches about 215 px (sim, coyote excluded), so any gap in the window is crossable both ways |
| gap_margin | float (px) | 4-12, starts at 8 | data file | Keeps a perfect jump from leaking through and the dash from missing |
| W | float (px) | gap_min to gap_max | data file (room data) | Edge-to-edge width of the gap |

**Output Range:** `gap_min` is `137 + margin` and `gap_max` is `170 - margin`: 145 to 162 px at margin 8, 149 to 158 px at margin 12, 141 to 166 px at margin 4. At margin 0 a perfect run-jump with coyote, full hitbox overlap and the nudge leaks through at 137 px. The window closes above a margin of about 16 px (width = 33 - 2 x margin). The 2026-11-18 third review found the previous version compared W with centre travel alone: it put `gap_min` at 122 + margin, so any margin under 15 let a perfect run-jump through.
**Example:** a 150 px gap (margin 8) needs the dash: a run-jump crosses at most 137 px edge to edge and the dash-jump clears up to 170 px; a 140 px gap is rejected at margin 8 (below `gap_min` 145, too close to what a coyote run-jump can reach).

### F2. Double-jump ledge window

The double_jump_ledge formula is defined as:

`ledge_min = jump_apex + ledge_nudge + ledge_margin_low`; `ledge_max = double_jump_total - ledge_margin_high`; `head_clear = jump_apex + hitbox_height + cling_margin`. A ledge whose top is h above the standing floor is valid when `ledge_min <= h <= ledge_max` and it passes the **cling test**: (a) each of the ledge's own faces is `no_cling`, or has its lowest point at or above `head_clear`; and (b) no plain face is a launch face for it (F8, earlier kit: dash and wall cling).

Why the cling test. The wall cling is owned before the double jump, and one plain wall is a ladder (Core Rules). A slab whose underside is lower than the head at the top of a plain jump (about 81 px) gets touched, kicked off and climbed; a plain wall near the ledge gets climbed and kicked off toward it (F8). The "open air" test of earlier versions (no cling surface within 122 px, measured up to the feet) missed both.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| jump_apex | float (px) | about 60 (59-62) | calculated from player_config | Single jump height, feet (sim 58.7) |
| double_jump_total | float (px) | about 115 | calculated from player_config | Jump plus double jump height, feet (sim 113.5) |
| ledge_nudge | float (px) | 5 | player_config | Lip-catch lift: a plain jump's feet catch a lip up to about `jump_apex + 5` |
| ledge_margin_low | float (px) | 4-12, starts at 7 | data file | Stops a plain jump with the nudge clipping the edge |
| ledge_margin_high | float (px) | 5-12, starts at 7 | data file | Lets the double jump clear the edge reliably |
| hitbox_height | float (px) | 22 | player_config (`hitbox_size.y`) | Height of the Seeker's box above the feet |
| cling_margin | float (px) | 4-10, starts at 6 | data file | Keeps the head clear of a plain underside |
| head_clear | float (px) | about 88 | calculated | `jump_apex + hitbox_height + cling_margin`: the lowest point any plain face of the ledge may have |

**Output Range:** ledge tops of 72 to 108 px at margins 7 and 7. A ledge with plain faces needs its underside at 88 px or more, so a plain slab t px thick fits only from `88 + t` to 108 (an 8 px slab: 96 to 108). A ledge with `no_cling` faces (for example a thick moss island) uses the whole 72-108 window. Ledges between `ledge_max` and the F3a minimum fit no gate and are not used as gates; they may appear only where nothing depends on reaching them.
**Example:** a ledge 100 px up on an 8 px plain slab (underside 92) with no launch face needs the double jump. A ledge 90 px up on a 16 px plain slab (underside 74) is rejected: the head touches it at the top of a plain jump and the kick climbs it. The same 90 px ledge built as a thick moss island with `no_cling` faces passes.

### F3. Grapple gate

Two gate shapes; both are valid only if no earlier key can cross them.

**F3a. Grapple ledge.** `target_height >= double_jump_total + grapple_margin`, with an anchor within `grapple_range` of a standing point, and the F2 cling test with the earlier kit of keys 1-3: (a) each of the ledge's own faces is `no_cling`, or has its lowest point at or above `head_clear_dj = double_jump_total + hitbox_height + cling_margin` (about 143 px); and (b) no plain face is a launch face for it (F8, kit 1-3).

**F3b. Grapple gap.** `gap_width >= max_non_grapple_crossing + far_face_extra + landing_slack + grapple_margin` (edge to edge, `landing_slack` from F1), with an intended crossing by a chain of anchors where the take-off point, each anchor and the far floor are each within `grapple_range` of the previous one. The chasm itself must hold three conditions, because the wall cling is owned and one plain wall is a ladder:
- **Far face.** The far side's face below the lip is `no_cling` (`far_face_extra` = 0), or is plain for at most `far_face_max` (16 px) below the lip (`far_face_extra` = 7 px: falling 16 px further adds about 7 px of reach, 60 Hz sim). A deep plain far face is caught on the way down and kicked up: at 70 px below the lip the best non-grapple chain has travelled about 28 px further.
- **Below the gap.** A hazard or kill plane, with no standing spot and no plain face inside the gap's span above it. A walkable pit floor is never used: the player walks across and climbs the far wall.
- **Launch faces.** No plain face on either side is a launch face for the far lip (F8, kit 1-3).

The chain proves a crossing exists with the grapple; it does not make every anchor necessary (see the grapple jump-out note below).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| target_height | float (px) | 121 or more | data file (room data) | Height of the ledge above the standing floor (F3a) |
| head_clear_dj | float (px) | about 143 | calculated | `double_jump_total + hitbox_height + cling_margin`: lowest point a plain face of a grapple ledge may have (F3a) |
| gap_width | float (px) | about 420 or more | data file (room data) | Edge-to-edge width of the gap (F3b) |
| far_face_max | float (px) | 16 | data file | Deepest plain face allowed below the far lip of a grapple gap (F3b) |
| far_face_extra | float (px) | 0 or about 7 | calculated | Extra reach from falling to the bottom of a plain far face: 0 for a `no_cling` face, about 7 at 16 px (60 Hz sim). Re-measure |
| max_non_grapple_crossing | float (px) | about 399 | calculated from player_config | Farthest centre travel without the grapple: ground dash-jump, double jump, then air dash, each timed late (60 Hz sim, third review, 398.7 px; the second review's 396 was a slightly earlier timing). Re-measure |
| grapple_range | float (px) | 200 | data file (player_config) | Farthest anchor the grapple reaches |
| grapple_margin | float (px) | 6-20 | data file | Keeps the double jump (F3a) or the best combined crossing (F3b) from reaching the target |

**Output Range:** F3a: targets 121+ px up with an anchor within 200 px when the ledge's faces are `no_cling`; a plain slab t px thick needs its underside at 143 px or more, so its top sits at `143 + t` or more (an 8 px slab: 151+). F3b: gaps of about 420-434 px or more with a `no_cling` far face, 427-441 px or more with a plain far face of at most 16 px (margin 6-20; 399 + far_face_extra + 15 + margin), always over a hazard or kill plane. The intended chain over such a gap has at least two anchors, since three hops of at most 200 px each are needed to span more than 400 px.
**Grapple jump-out (Open Question 13).** `_grapple_jump_out` in `player.gd` restores the air dash, and the air jump when the double jump is owned, so a player who grapples to the first anchor and jumps out can cover far more than one hop. A player with the grapple may therefore need fewer anchors than the intended chain, and the new reach is not measured yet. F3b still guarantees that the grapple is needed (no earlier key crosses the gap); it does not guarantee that every anchor is.
**Example:** F3a: a ledge 160 px up on an 8 px plain slab (underside 152), no launch face, with an anchor 24 px beyond its edge. F3b: a 440 px chasm over a kill plane, the far side a 12 px plain slab, with anchors at about 147 px and 293 px from the take-off edge, each hop about 147 px. A 430 px chasm with a 60 px plain far face is rejected (a deep far face lets the wall cling catch and climb it).

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

### F6. Cling wall

Two gate shapes for the wall cling (key 2), valid only if the start kit cannot cross them and the wall cling can. One plain face is enough (Core Rules, one wall is a ladder); only `climbable`-marked surfaces climb.

**F6a. Cling wall.** A plain face with `wall_height >= ledge_min` (F2: `jump_apex + ledge_nudge + ledge_margin_low`) and no standing spot on or beside it within `ledge_min` of the one below it (otherwise the start kit climbs it in hops). A shaft of two facing walls is two cling walls; its width does not matter for the key, which climbs either face alone.

**F6b. Climb wall.** A `climbable`-marked surface of height `>= ledge_min` with no other way up. In the code a `climbable` is an `Area2D` the Seeker snaps to and climbs at `climb_speed` (70 px/s). Kicking up a plain face is faster (about 190 px/s), so a climb wall is a slow, safe ascent, not a separate skill test; it is gated with the wall cling (Open Question 4).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| wall_height | float (px) | `ledge_min` (about 72) or more | data file (room data) | Height from the standing floor to the top of the face or the exit. Above `ledge_max` (about 108) a later key's double jump cannot take it either; at or below it the double jump leaks in, which is intended for a later key |
| kick_rise | float (px) | about 78 | calculated from player_config | Height gained by one wall kick (`wall_jump_speed` 380, 60 Hz sim 77.6) |
| kick_cycle | float (s) | about 0.4 | calculated from player_config | Time from one kick to the next off the same wall: 0.1 s of control lock (`wall_jump_control_lock_time`), drift of about 25 px, steer back (60 Hz sim) |
| shaft_width | float (px) | 24 or more | data file (room data) | Clear width of a shaft between two faces; 24 is a readability floor, not measured. No upper bound |

**Output Range:** a cling wall is any plain face 72 px or more tall with no standing spot on it; a climb wall is 72 px or more tall.
**Example:** a 200 px plain wall with nothing on its face is valid, alone or as one side of a shaft. A 60 px wall is rejected: a single jump with `ledge_nudge` reaches about 64.
**Edge:** a wall with a standing spot 50 px up is rejected (it is two 50 px hops). A wall that must stay shut after key 2 is not a cling wall: it meets the ceiling or room bound, or is `no_cling` (Core Rules).

### F7. Pogo clearance

The pogo_clearance rule (rule 24) is defined as:

`no hittable lies inside gate_volume(gate)`. The gate volume runs from the floor up to `max(reach_height + pogo_rise, gate height)`, where `reach_height` is the feet height the gate's earlier kit reaches (`jump_apex` for F1, F2 and F6; `double_jump_total` for F3). Its width depends on the gate:
- **Column gates** (F2, F3a, F6a): the column under the ledge or along the wall, widened by `pogo_clearance_px` on each side.
- **Gap gates** (F1, F3b): the gap's span, ending `hitbox_width` past each lip. A pogo carries the Seeker only about 96-105 px from the hittable (fourth review sim), less than any gap gate (145 px or more), so a hittable on solid ground beside a gap cannot carry it across; only a hittable over the gap can.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| pogo_speed | float (px/s) | 260 | data file (`attack_data.tres`) | Launch speed of a pogo |
| pogo_rise | float (px) | about 38 | calculated | `pogo_speed^2 / (2 x gravity)` = 37.6 px at gravity 900 |
| pogo_carry | float (px) | about 96-105 | calculated from player_config | Horizontal travel from a pogo contact (24-55 px above the floor) back down to floor level at run speed (60 Hz sim) |
| pogo_clearance_px | float (px) | 100-160, starts at 120 | data file | Column gates only: `pogo_carry` plus `hitbox_width`, rounded up. A hittable this near a ledge or wall can be pogoed and carried onto it. Re-measure |
| hittable | node group | n/a | code (`hittable`) | Enemy spawn point or its patrol or flight bounds, breakable, target, boss add |

**Output Range:** 0 hittables in every gate volume of every room.
**Example:** a double-jump ledge with a breakable 100 px from its column is rejected at 120; moving the breakable 130 px away passes. A dash gap 150 px wide with a patrol bound 20 px behind its near edge passes (outside the gap's span plus 10 px); a bat whose flight bounds cross the air above the gap is rejected.
**Edge:** the rule does not apply to a room with no gate; a boss arena has none.

### F8. Wall launch reach

Once the wall cling is owned, every plain face can be climbed to its top (Core Rules) and kicked off from any height on it. A plain face is a **launch face** for a gate target (a ledge top or a far lip) when it faces the target, its top is no lower than `target_top - launch_rise(kit)`, and its horizontal distance to the target's nearest edge is at most `wall_reach(kit, dh)`, where `dh = max(0, face_top - target_top)`. A gate (F2, F3a, F3b) is valid only if it has no launch face. Faces that face away from the target count too, at the same reach: a conservative rule, since a kick can be turned in the air.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| kit | set | keys 1-2 (F2) or keys 1-3 (F3) | key table | The earlier kit the gate must hold against |
| launch_rise | float (px) | about 78 (keys 1-2), about 132 (keys 1-3) | calculated from player_config | Rise of a kick, or a kick plus the double jump (60 Hz sim 77.6 and 132.4) |
| dh | float (px) | 0 or more | data file (room data) | How far the face's top (or the ceiling, for a face that meets it) is above the target top |
| wall_reach | float (px) | see table | calculated from player_config | Farthest centre travel from a kick off the face to the target's height, with the kit's air moves at best timing (60 Hz sim). Re-measure |

| dh (px) | wall_reach, keys 1-2 (kick, air dash) | wall_reach, keys 1-3 (kick, double jump, air dash) |
|---------|--------------------------------------|----------------------------------------------------|
| 0 | about 231 | about 333 |
| 50 | about 245 | about 347 |
| 100 | about 259 | about 361 |
| 200 | about 289 | about 392 |
| 300 | about 317 | about 420 |

**Output Range:** with keys 1-2 a plain face rising to a double-jump ledge's height must stand more than about 230 px from it (plus `landing_slack` 15); with keys 1-3 a face rising to a grapple target must stand more than about 335 px away, more for taller faces. Inside that range the face is `no_cling`, or it meets the ceiling lower than `target_top - launch_rise`.
**Example:** a 100 px double-jump ledge with a plain cave wall 180 px away that rises to the ceiling is rejected; the same wall with `no_cling` thorn vines, or 260 px away under a ceiling 40 px above the ledge, passes.
**Edge:** the start kit has no wall cling, so F8 never applies to F1 or F6. A face that cannot be reached at all with the kit is still counted (conservative); the Auto check may drop it only with a reachability test.

**Feedback loops:** keys make old rooms faster, which makes revisiting cheaper and encourages exploring; intended, bounded by shortcuts (enemy respawn rules belong to the Enemies GDD, not yet written). A later key leaking into an earlier gate (double jump over a dash gap) is also intended.

**Registry candidates (not owned here):** run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, hitbox_height, kick_rise, wall_reach belong in the movement GDD when it exists.


## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

- **If a player passes a gate early with the current kit** (a perfect jump over a dash gap, a wall-jump over a shaft): allow it. The room beyond must still make sense with any kit the player owns, and no rule may assume a key order the player was never forced into (rule 12).
- **If a player reaches a key's location before its intended order** (the wall cling shrine reached without the dash): the key is granted normally. Later gates stay valid because gates read only "owned", never "owned in order".
- **If the player is in a one-way drop, a pit or a secret room**: there is always a return path to the previous room with the kit they had when they entered. A drop that returns only with a later key is cut.
- **If the player dies after collecting a key but before reaching a save point**: the key is saved at pickup and stays owned. Dying cannot take a key away. (World state and save points own the write; this is the requirement on them.)
- **If the player dies in a boss room**: respawn at the save point before it (rule 15). The boss is undefeated until its flag is set; its reward pickup stays in the room until collected.
- **If a boss is defeated but its reward is not collected before the player leaves**: the pickup stays in the room, visible and collectible on return, and the boss stays defeated.
- **If a shortcut is approached from its near side**: it shows as blocked and does not open; it opens only from the far side, then stays open (states table).
- **If an enemy or breakable would sit near a gate** (inside the F7 gate volume): the placement is moved or the gate is rebuilt; it is not logged as a soft gate, because the pogo would let the start kit cross (rule 24). A patrol's whole route counts, not only its spawn point.
- **If a cling wall has a standing spot on it** (F6a): the wall is rebuilt; with a standing spot the start kit climbs it in hops.
- **If a plain wall that should hold after the wall cling is open at the top** (Core Rules, one wall is a ladder): the player climbs it by repeated kicks. It is raised to the ceiling or room bound, or made `no_cling`; it is not logged as a soft gate.
- **If a dash gap sits near the top of its window and the player misses**: they fall to a safe floor with no fall damage and an unbroken way back. A gap whose floor below is a hazard needs a return ledge.
- **If a room has no job (rule 18) or a dead end has no secret (rule 19)**: it is cut at the grey-box review, not shipped.
- **If a double-jump or grapple ledge fails the cling test** (F2, F3a: a plain underside below the head height, or a launch face within `wall_reach`, F8): the wall cling is owned by then, so the gate leaks. The faces involved become `no_cling`, the slab is thinned, or the wall is moved or capped by the ceiling.
- **If a grapple chasm has a deep plain far face or a floor** (F3b): the player catches the far face on the way down, or walks the floor, and kicks up. The far face becomes `no_cling` or at most `far_face_max` deep, and the floor becomes a hazard or kill plane.
- **If painted trim hides a gate's real edge** (rule 25): the trim is cut back to `trim_overhang_max` at the gate; the collision is never moved to fit the art.
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
| Terrain pipeline | Hard | The collision and tile rules every room is built from; the grey-box path; black collision masses with painted trim and the `trim_overhang_max` rule (rule 25); a `no_cling` material | No (provisional) |
| Ability gating | Hard | Gate types, dimensions and visual signatures; the "owned" read; the `no_cling` surface's signature | No (code exists: `PlayerState`, `AbilityGate`, `AbilityPickup`; needs dash and wall cling flags) |
| World state | Hard | Records of keys, boss defeats, shortcuts and secrets | No (provisional) |
| Bosses | Hard | Boss rooms, the defeat flag, the reward source | No (code exists: `Boss`, `boss_arena`) |
| Enemies | Soft | Enemy types to place in rooms | No (code exists: three types) |
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

**Bidirectional check:** none of the other GDDs exists, so each needs a matching entry when it is designed. Ability gating and level design are circular by design (see the systems index); the contract is: gating owns gate types and visuals, level design owns placement and order, and F1-F3, F6 and F8 (gate-fit formulas) sit in this GDD as provisional until the gating GDD adopts them (see the note under Formulas).


## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The look itself is owned by the terrain pipeline and the parallax, lighting and atmosphere systems; this section lists only what level design needs from them.

- **Gate language:** each key has one signature (shape, material and colour) that nothing else in the world uses, so a gate is readable from across a room. The palette is chosen with the art bible (not yet written) and replaces the placeholder colours of the gate test room.
- **Region identity:** each region reads as a distinct place by palette, architecture, enemies and music, so the player always knows where they are. **[Sourced]** (Silksong: architecture tells you where you are)
- **Readability:** play-layer collision edges are the brightest values in a room and the room reads in greyscale; backgrounds and foreground framing never imitate a platform or a gate. **[Sourced]** (Saltsman)
- **Terrain look [Owner, 2026-11-18]:** solid terrain is black collision masses with rock or moss trim painted on their edges, over fogged, softer parallax layers (the example scenes of the Maaot Brown Cave and Mossy Cavern packs, kept locally in `assets/third_party/`, not in git). The black mass is the grey-box (rule 3), so an approved grey-box keeps its shape when it is painted. Trim obeys rule 25 at gates. The packs are painted at 512-1024 px per tile and the game renders at 480 x 270 with nearest filtering, so the art bible must settle the scale and filtering, and how the pixel-art Seeker sits on painted terrain, before any room is painted.
- **No-cling signature:** a `no_cling` face shows its material (candidate: thorn vines) over its whole height, so the player can tell from across a room which walls will not hold them.
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
| run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, max_non_grapple_crossing, landing_slack, kick_rise, kick_cycle, launch_rise, wall_reach, far_face_extra, pogo_carry (F1-F3, F6-F8) | Player controller / movement | Calculated from `player_config.tres`; to be registered |
| hitbox_width, hitbox_height, ledge_nudge (F1, F2, F3a) | Player controller / movement | In `player_config.tres` (`hitbox_size` 10x22, `ledge_nudge` 5) |
| The `no_cling` surface: no wall slide or wall jump on it (Core Rules, F2, F3, F8) | Player controller / movement; Ability gating (signature) | Not in code (Open Question 16) |
| Collision masses with painted trim, `trim_overhang_max` (rule 25) | Terrain pipeline | Not designed; look chosen by the owner 2026-11-18 |
| pogo_speed, the `hittable` group (rule 24, F7) | Combat | In `attack_data.tres` (260 px/s); code exists, no GDD |
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
- **GIVEN** the start kit only, **WHEN** a tester tries every dash gap, cling wall, climb wall, double-jump ledge and grapple target in the region by any means in the kit (pogo off any hittable included), **THEN** each one is blocked, except those logged as deliberate soft gates. **[Play]** (rule 5, 12)
- **GIVEN** each key in turn, **WHEN** it is collected, **THEN** the gate matching its signature becomes passable, and no gate of another key's signature changes. **[Auto]** (rule 7)
- **GIVEN** the key table, **WHEN** the map is read, **THEN** each key's pickup names exactly one channel (boss, shrine or mentor). **[Auto]** (rule 10)

**Showing the lock, placing the key**
- **GIVEN** a new game, **WHEN** a tester plays the first 10 minutes without a guide, **THEN** at least one dash gap has been on screen and the tester can say where it is. **[Play]** (rule 8)
- **GIVEN** the room graph, **WHEN** each gate type whose key is found in the built region (core build: dash and wall cling) is counted along the main route before its key's pickup room, **THEN** at least two rooms show that gate type, and the first dash gate lies within the funnel's rooms. **[Auto]** (rule 8)
- **GIVEN** the room graph, **WHEN** the shortest path from each key's first gate room to its pickup room is measured ignoring locks (core build: dash and wall cling), **THEN** it is 3 rooms or more, and at least one path to the pickup room crosses no gate of that key. **[Auto]** (rule 9)
- **GIVEN** a key was just collected (core build: dash and wall cling), **WHEN** the player leaves the pickup room, **THEN** the next room is a workshop of 1-2 screens that contains one lock of that key's type, and the player can walk back out of it without the key. **[Play]** (rule 11)

**Topology**
- **GIVEN** the first region, **WHEN** its room graph is built, **THEN** it contains at least one loop and at least one shortcut that returns to a save point, and no room is reachable only by a path that cannot be left again. **[Auto]** (rules 14, edge case "return path")
- **GIVEN** the main route, **WHEN** screens between each pair of adjacent saves are counted, **THEN** none exceeds `save_spacing_max` (7), and a save exists before every boss and mini-boss. **[Auto]** (F4, rules 15, 16)
- **GIVEN** each boss and mini-boss arena, **WHEN** the room graph is read, **THEN** a shortcut back to the save before it exists within one room of the arena. **[Auto]** (rule 15)
- **GIVEN** region 1 in the core build, **WHEN** every double-jump and grapple gate is followed, **THEN** each leads to a one-screen sealed alcove with a visible reward, and no such gate leads anywhere else. **[Auto + Shot]** (rule 2)
- **GIVEN** region 1, **WHEN** the main route is read, **THEN** the dash pickup lies before the apex boss, and the apex boss arena lies beyond at least one dash gate and one wall-cling gate. **[Auto]** (key mapping)
- **GIVEN** a region at its first visit, **WHEN** the player is in the first 5-10 rooms, **THEN** only one objective is open; afterwards at least two directions are open. **[Play]** (rule 13)

**Formulas**
- **GIVEN** a dash gap of edge-to-edge width W, **WHEN** the room data is checked, **THEN** `gap_min <= W <= gap_max` with the reaches computed from `player_config.tres` (at margin 8: 145 to 162); a gap at `gap_min - 1` is rejected, a gap at `gap_max + 1` is rejected, and a 137 px gap (the widest a coyote run-jump can land) is rejected. **[Auto]** (F1, boundary)
- **GIVEN** a double-jump ledge with top height h, **WHEN** checked, **THEN** `ledge_min <= h <= ledge_max`, each of its own faces is `no_cling` or has its lowest point at `head_clear` (about 88) or higher, and no plain face is a launch face (F8, keys 1-2); a 100 px ledge on an 8 px plain slab passes, a 90 px ledge on a 16 px plain slab (underside 74) is rejected, the same ledge with `no_cling` faces passes, and a plain wall rising to the ledge's height 180 px away is rejected. **[Auto]** (F2, F8, boundary)
- **GIVEN** a grapple ledge (F3a), **WHEN** checked, **THEN** `target_height >= double_jump_total + grapple_margin`, an anchor lies within 200 px of a standing spot, its own faces are `no_cling` or have their lowest point at `head_clear_dj` (about 143) or higher, and no plain face is a launch face (F8, keys 1-3); a ledge 120 px up is rejected, a 140 px ledge on a plain slab (underside below 143) is rejected, and a 160 px ledge with a plain wall rising above it 300 px away is rejected. **[Auto]** (F3a, F8, boundary)
- **GIVEN** a grapple gap (F3b), **WHEN** checked, **THEN** `gap_width >= max_non_grapple_crossing + far_face_extra + landing_slack + grapple_margin`, every hop (take-off, anchors, far floor) is at most `grapple_range`, the far face is `no_cling` or plain for at most `far_face_max` (16 px), the gap has a hazard or kill plane below with no standing spot or plain face in its span, and no plain face is a launch face for the far lip; a 414 px gap is rejected, a chain with one 210 px hop is rejected, a 430 px gap with a 60 px plain far face is rejected, and a gap with a walkable floor below is rejected. **[Auto]** (F3b, F8, boundary)
- **GIVEN** a cling wall (F6a) or climb wall (F6b), **WHEN** checked, **THEN** `wall_height >= ledge_min`, the face has no standing spot on it, and a climb wall is `climbable`-marked; a 60 px wall and a wall with a standing spot 50 px up are each rejected, and a single 200 px plain face passes. **[Auto]** (F6, boundary)
- **GIVEN** every gate in a room, **WHEN** the room data is checked, **THEN** no hittable (enemy spawn, patrol or flight bounds, breakable, target) lies inside its gate volume (F7); a breakable 100 px from a double-jump ledge's column is rejected at `pogo_clearance_px` 120 and one 130 px away passes; a patrol bound 20 px behind a dash gap's near edge passes, and flight bounds over the gap are rejected. **[Auto]** (rule 24, F7, boundary)
- **GIVEN** a wall that must stay shut after the wall cling (Core Rules), **WHEN** the room data is checked, **THEN** it meets the ceiling or room bound with no opening, or it is `no_cling`. **[Auto]** (Core Rules, one wall is a ladder)
- **GIVEN** the wall cling owned and a `no_cling` face, **WHEN** the Seeker presses into it and presses jump, **THEN** no wall slide and no wall jump starts; against a plain face both do. **[Auto]** (controller unit test; Core Rules, no-cling surface; needs the story in Open Question 16)
- **GIVEN** the movement values in `player_config.tres`, **WHEN** the Seeker attempts F1-F3 and F6 gates in `movement_test_room`, **THEN** a perfect run-jump (centre at the edge, full hitbox overlap, nudge) never crosses a dash gap, a plain jump never touches a double-jump ledge, its plain underside or the top of a cling wall, the double jump never reaches a grapple ledge, dash, double jump and air dash together never cross a grapple gap, and a kick off a plain wall farther than `wall_reach` never reaches its target; and with the wall cling a single plain wall can be climbed by repeated kicks. **[Play]** (re-measure the [Calc] figures: `landing_slack`, `max_non_grapple_crossing`, `kick_rise`, `wall_reach`, `far_face_extra`, `pogo_carry`)
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
13. **Grapple and air moves.** Answered by the code (third review): `_grapple_jump_out` restores the air dash and, with the double jump, the air jump. F3b still guarantees the grapple is needed, but a player may skip anchors of the intended chain. Still open: measure the new reach and decide whether anchors must hold (for example anchors that deny the jump-out). Target: the gating GDD.
14. **Dash-through barriers.** Cut from the key table (third review, owner 2026-11-18): no barrier type exists in code, the player config or any GDD. Decide in the Ability gating GDD whether the dash opens a barrier type (for example a wall a dash breaks); if so, add it to the key table and give it an F-formula.
15. **Measure the simulated figures.** `landing_slack` (15), `max_non_grapple_crossing` (399; the fourth review's sim found 392.5), `kick_rise` (78) and `kick_cycle` (0.4 s), `wall_reach` (F8 table), `launch_rise` (78 and 132), `far_face_extra` (7), `pogo_rise` (38), `pogo_carry` (96-105) and `pogo_clearance_px` (120) are simulated or recommended, not measured in the engine. Target: `movement_test_room`, before the first gate is built.
16. **The `no_cling` surface.** Decided by the owner (fourth review, 2026-11-18): a face marked `no_cling` cannot be slid on or kicked off. Needs a controller change (skip the wall slide and `_wall_jump_direction` when the touched face is `no_cling`, for example by a physics layer or group), a unit test, and its visual signature from the art bible (candidate: thorn vines). Target: the story that adds the dash and wall cling flags (Open Question 12), before any double-jump or grapple gate is built.
17. **Art scale and filtering.** The chosen look (black masses with painted trim, rule 25) comes from packs painted at 512-1024 px per tile; the game renders at 480 x 270 with nearest filtering and integer scaling. Decide the tile size at game scale, the filtering for painted textures, and whether the pixel-art Seeker fits on painted terrain, with one test room. Target: `/art-bible`, before any room is painted.
