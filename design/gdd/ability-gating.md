# Ability gating

> **Status**: In Design
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-18
> **Last Verified**: 2026-11-18
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room"; loop: fight, gain a verb, open the world, fight again)

## Summary

Ability gating holds the one record of which movement keys the Seeker owns (dash, wall cling, double jump, grapple), the pickup that grants each once, and the seven gate types that each key opens: measured gaps, walls, ledges, bisque panes and ordered grapple-anchor chains, with formulas F1-F3, F6 and F8-F11 and one visual signature per key. It makes the world's locks honest: what looks too far is too far, and a gate seen early is recognised when its key arrives. Level design places the gates; this system defines what they are.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Player controller, World state`

## Overview

Ability gating decides what it means to *own* a movement key and what a route that needs one looks like. It holds the one record of which keys the Seeker owns (`PlayerState`: dash, wall cling, double jump, grapple), the pickup that grants a key once, and the catalogue of **gate types**: for each key, the shape of geometry the start kit (or an earlier kit) cannot cross and that key can, with its measured dimensions (formulas F1-F3, F6, F8, F9) and the one visual signature nothing else in the world uses. It also defines the one surface that refuses a key, the `no_cling` face. Level design decides where gates sit and in what order keys arrive; this system decides what a gate *is*. The player never operates it directly: they feel it as a world that is honest about its locks. A gap that looks too far is too far, a wall that looks climbable is climbable once the wall cling is owned, and a gate seen early is recognised on sight when the key that opens it arrives. Without it, a key is a flag with no promise attached, and the loop (fight, gain a verb, open the world) has nothing to open.

## Detailed Design

### Core Rules

Tags: **[Owner]** = the owner's stated rule; **[Code]** = how the code works today; **[Rec]** = recommendation, change freely; **[Calc]** = computed from `player_config.tres`, re-measure in `movement_test_room`.

**Ownership**

1. **One record.** `PlayerState` is the only place key ownership lives. It holds four movement keys: **dash**, **wall cling** (wall slide, wall jump and climb, gated together), **double jump** and **grapple**. Each is a flag that goes from unowned to owned and never back. Pickups and the mentor pact grant into it; the player controller, gates and signs read it; World state saves it. **[Code for double jump and grapple; dash and wall cling flags to add, Owner]** The bow and the spell casts are not movement keys and gate nothing in the core build.
2. **Start kit.** A new `PlayerState` owns nothing. Run, jump, the whole sword set (including the pogo and the charged heavy), crouch and doors never need a key. **[Owner]** Today the dash, wall slide, wall jump and climb are always available in `player.gd`. Gating them is a controller story (Open Question 1).
3. **An unowned key does nothing.** Without the dash, the dash input is ignored. Without the wall cling, touching a wall gives no slide and no wall jump (the Seeker falls as in the air), and a `climbable` surface does not snap. Without the double jump, an air jump press does nothing. Without the grapple, the grapple input does nothing. There is no partial effect, no animation and no "locked" sound on the press. **[Code for double jump and grapple; Rec for the rest]**
4. **Owned, never ordered.** Every gate, sign and controller check reads only "owned". Nothing reads the order keys arrived in, so a key reached early through a leak still works everywhere. **[Owner]** (level design rule 12)
5. **Pickup.** An `AbilityPickup` grants one key when the Seeker touches it, once. If that key is already owned when the pickup enters the tree, it frees itself and never shows. The grant is immediate, and World state records it at the moment of pickup, so dying before a save never takes a key away. **[Code; World state write: requirement on World state]** Each pickup carries a `channel` (boss, shrine or mentor) for the level design check that every key names exactly one channel. **[Rec]**
6. **Mentor pact.** A key granted by a mentor (the double jump, Pell) uses the same grant call with no pickup node. The pact's confirm prompt belongs to Lore delivery. **[Rec]**

**Gate types**

7. **A gate is geometry, judged on collision.** A gate is a shape of collision that the kit before its key cannot cross and its key can, measured against the Seeker's figures in `player_config.tres` at 60 Hz. It is never measured on art, and never on constants copied into a document: the [Auto] checks read the config. **[Owner]**

| Key | Gate type | Formula | Opens when |
|-----|-----------|---------|------------|
| 1 Dash | Dash gap | F1 | Gap too wide for any run-jump, crossable by the dash-jump |
| 1 Dash | Bisque pane | F10 | A thin pane breaks when the Seeker touches it while dashing |
| 2 Wall cling | Cling wall | F6a | A plain face too tall to jump, climbed by wall kicks |
| 2 Wall cling | Climb wall | F6b | A `climbable` surface with no other way up |
| 3 Double jump | Double-jump ledge | F2 | A ledge above a plain jump, with no plain face to kick from (F8) |
| 4 Grapple | Grapple ledge | F3a | A ledge above the double jump, reached from an anchor |
| 4 Grapple | Grapple gap | F3b | A chasm wider than any non-grapple crossing, crossed by a chain of gate anchors (F11) |

8. **Few locks per key.** Only these seven gate types exist. A new type needs its own formula and a row here before level design may place it. **[Owner, Sourced: Metroid Dread]**
9. **A later key leaking into an earlier gate is intended** (the double jump over a dash gap). A gate only has to hold against the kit *before* its key. **[Owner]**
10. **One signature per key.** Each key's gates carry one shape, material and colour that nothing else in the world uses, readable from across a room. Lore candidates (Kiln City): the dash is bisque (pale unfired clay) on panes and gap lips; the wall cling is copper-green finger-drag grooves; the double jump is the kiln shelf on stilts; the grapple is the iron ring and violet cord. The art bible makes the final choice. **[Rec; art bible decides]**
11. **Which walls carry the grooves.** The copper-green grooves mark every cling wall level design places as a gate (the walls counted for "seen twice", level design rule 8) and every `climbable` surface. Other plain walls stay unmarked but can still be climbed once the wall cling is owned. **[Owner, 2026-11-18]**

**Surfaces**

12. **Plain face.** Any solid face not marked `no_cling` lets the Seeker slide and wall-jump once the wall cling is owned. Only `climbable` surfaces can be climbed (snap and climb at `climb_speed`). **[Owner, Code]**
13. **One wall is a ladder.** A wall jump needs only a wall within `wall_jump_reach` (3 px), so the Seeker can kick off one plain face, steer back and kick again, about `kick_rise` (78 px) every `kick_cycle` (0.4 s) with no limit. **[Calc]** Once the wall cling is owned, every plain face can be climbed to its top. A wall that must stay shut after the wall cling meets the ceiling or room bound with no opening, or is `no_cling`. **[Owner]**
14. **No-cling face.** A face marked `no_cling` cannot be slid on or kicked off, even with the wall cling: the controller skips the wall slide and the wall-jump check for it. It carries one visual signature no other surface uses: never copper-green; candidates are a slick glaze for the kiln city or the thorn vines of the Mossy Cavern pack; the art bible decides. It is how a ledge, a chasm or a nearby wall keeps the wall cling from turning into a ladder (F2, F3, F8). It is a tool for particular faces, not a way to fit a gate into a narrow room (F9). **[Owner]** How it is marked (physics layer or group) becomes an ADR.

**Bisque pane (dash)**

15. **What it is.** A thin, pale wall (`pane_thickness`) filling a passage from floor to ceiling with no opening around it. It is solid to everything until broken. **[Owner, 2026-11-18; dimensions Rec]**
16. **What breaks it.** Only the Seeker touching it in the **dash state** (a ground dash or an air dash), from either side. The Seeker passes through without losing dash speed. A dash-jump (air state carrying dash speed), a run, an attack, the charged heavy, the pogo, enemies and projectiles do not break it. It is not in the `hittable` group, so it is never a pogo target. **[Owner for the dash-only break; Rec for the rest]**
17. **It stays broken.** World state records each broken pane by id and the pane never reforms, so it doubles as a one-way-then-open route. **[Rec]**

**Grapple gate anchors**

18. **Gate anchors.** Every anchor in a grapple gate (F3a, F3b) is marked `gate_anchor`. A jump-out from a pull or a release on a gate anchor still jumps, but it does **not** restore the air jump or the air dash (today `_grapple_jump_out` restores both). All other anchors keep the full jump-out. **[Owner, 2026-11-18]** This needs a controller change (Open Question 2).
19. **Every anchor is needed.** A grapple gate's gate anchors are hooked in chain order: the first freely, each later one only from the one before it (F11). Their spacing stops a release from the second-to-last anchor reaching the far floor, and no earlier kit crosses the gate (F3). The chain is the only way across, not just one of several. No plain anchor may sit where it could stand in for a gate anchor. **[Owner, 2026-11-18: every anchor needed, by ordered targeting]** Ordered targeting needs a controller change (Open Question 2).

**Signs**

20. **Gate sign.** A gate may carry a diegetic sign (`AbilityGate`): dim while its key is unowned, lit once owned. It only shows the gate; the geometry is the gate. Signs are optional, never the only way a gate reads, and never name the key in text in the shipped look (the placeholder label is a test-room aid). **[Code; Rec for shipped use]**

### States and Transitions

| Thing | States | Transition and trigger |
|-------|--------|------------------------|
| Key (each of four) | Unowned, Owned | Unowned to Owned on `grant` (pickup touched or mentor pact). Never reverts; a load sets it from World state. |
| Ability pickup | Present, Collected | Present to Collected on first touch by the Seeker; it frees itself. A pickup whose key is already owned is never Present. |
| Bisque pane | Intact, Broken | Intact to Broken when the Seeker touches it in the dash state. Never reforms. |
| Gate sign | Dim, Lit | Follows its key: Dim while Unowned, Lit once Owned (on `abilities_changed`). |

No state in this table can move backward. A gate itself has no state here: whether it is Seen, Passable or Passed is level design's table, read from these.

### Interactions with Other Systems

No GDD exists yet for any of these systems except Level design; each interface is **provisional** until its owner is designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Player controller | Both | In: movement figures (`player_config.tres`) that every formula reads; the dash state for panes. Out: the owned flags it must check before the dash, wall slide and jump, climb, air jump and grapple; the `no_cling` skip; the `gate_anchor` no-refresh rule | Controller owns movement; this system owns which moves need which key |
| World state | Both | Out: keys owned, panes broken (by id). In: both restored on load | World state owns storage; this system owns what is stored |
| Level design | Both | Out: gate types, formulas F1-F3, F6, F8-F11, signatures, `no_cling`, `gate_anchor`. In: where each gate, pickup and pane sits, and the key order | Level design owns placement and order; this system owns what a gate is |
| Combat | In | The `hittable` group and the pogo (`pogo_speed`), which gate volumes must keep clear (level design rule 24); panes are kept out of `hittable` | Combat |
| Terrain pipeline | Out | A `no_cling` material and a bisque pane material that it can build and paint; collision edges at gates | Terrain pipeline owns building them |
| HUD and UI | Out | `abilities_changed` and the first-pickup event, for the debug HUD and the first-pickup note | HUD |
| Lore delivery and mentor pact | In | The mentor pact calls `grant` | Lore delivery |
| Save points | Out (via World state) | `PlayerState` is saved with World state | Save points |
| Elemental palette power-ups (later) | Out | Gate materials per element | Elemental palettes |

## Formulas

All gate formulas read the Seeker's figures from `player_config.tres`; the movement values a gate depends on are **[Calc]** until measured (Open Question 3).

**Moved from level design (2026-11-18).** F1-F3, F6, F8 and F9 were drafted in `design/gdd/level-design.md` through six design reviews and moved here unchanged when this GDD was written (owner decision); level design links to them and keeps no copy. F10 (bisque pane) and F11 (gate anchors) are new. F4 (save spacing), F5 (flow speed-up) and F7 (pogo clearance) are placement rules and stay in level design.

All Seeker figures are **[Calc]** from `src/player/player_config.tres` at 60 Hz (the research report, re-simulated in the 2026-11-18 design review). `run_jump_distance` includes coyote time. Every horizontal figure is **centre travel** (how far the Seeker's centre moves), not a gap width: a gap `W` is measured edge to edge, and the 10 px hitbox plus `ledge_nudge` (5 px) let a landing succeed up to `landing_slack` (15 px) beyond the centre travel (F1, F3b). `corner_correction` (6 px) only acts under a low ceiling and is not in any figure. The Seeker's box is 10 x 22 px with its bottom on the feet point (`_apply_hitbox`), and a wall jump starts when any part of the box is within 3 px of a face, so every vertical test uses the **head height** (feet + `hitbox_height`, 22 px), not the feet: at the top of a plain jump the head is at about 81 px. The fourth review (2026-11-18) re-simulated the controller at 60 Hz and reproduced the run-jump (107 + 14 coyote), apex (58.7), dash-jump (164.4), double jump (113.5) and kick (77.6); it found 392.5 for `max_non_grapple_crossing`, so the 399 used below is on the safe side. Re-measure in `movement_test_room` before any gate is built. Margins and spacing values are `data file` knobs, not constants; the Auto checks read the movement figures from `player_config.tres`, not from the constants in this document.

### F1. Dash gap window

The dash_gap formula is defined as:

`landing_slack = hitbox_width + ledge_nudge`; `run_jump_reach = run_jump_distance + landing_slack`; `dash_jump_reach = dash_jump_distance + hitbox_width / 2`; `gap_min = run_jump_reach + gap_margin`; `gap_max = dash_jump_reach - gap_margin`; a dash gap of edge-to-edge width W is valid when `gap_min <= W <= gap_max`.

Why the slack differs at the two ends. The leak side takes the most favourable case for the player: the Seeker can stand with its centre up to half the hitbox (5 px) past the edge, lands when its leading edge (another 5 px) touches the far lip, and `ledge_nudge` lifts the feet up to 5 px onto a lip they just missed. The nudge is a vertical lift: it lets the Seeker land slightly later in its fall, which adds only about 2 px of horizontal reach (fourth review sim), so counting it as 5 px is a safe upper bound. A run-jump therefore crosses a gap up to `run_jump_distance + 15` wide at most. The crossable side takes the least favourable case: take-off with the centre at the edge, so the dash-jump is only credited the 5 px of the leading edge.

**The pit (sixth review, 2026-11-18).** W alone does not make a gate: a shallow pit is walked through. A dash gap is valid only if it also holds:
- **Level lips.** Both lips are at the same collision height (level design rule 25). A gap whose far lip is lower or higher is not an F1 gate until its reaches are re-measured in `movement_test_room`.
- **Below the gap.** Either a hazard or kill plane (with a return ledge, level design Edge Cases), or a safe floor at least `pit_depth_min` below the far lip. The far face, from that floor to the lip, has no standing spot on it (as F6a), so the start kit cannot hop out on the far side. The way out of the pit leads back to the near side only and needs no dash.
- **Inside the span.** No standing spot inside the gap's span other than the pit floor (a pillar or ledge in mid-gap splits it into two run-jumps).

The far face may be plain: the wall cling (key 2) comes after the dash, so a later key climbing out of the pit is an intended leak (level design, Feedback loops).

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
| pit_depth_min | float (px) | `ledge_min` (about 72) | calculated (F2) | Least drop from the far lip to a safe pit floor: `ledge_min` = `jump_apex + ledge_nudge + ledge_margin_low`, so a plain jump from the pit floor cannot reach the far lip |

**Output Range:** `gap_min` is `137 + margin` and `gap_max` is `170 - margin`: 145 to 162 px at margin 8, 149 to 158 px at margin 12, 141 to 166 px at margin 4. At margin 0 a perfect run-jump with coyote, full hitbox overlap and the nudge leaks through at 137 px. The window closes above a margin of about 16 px (width = 33 - 2 x margin). The 2026-11-18 third review found the previous version compared W with centre travel alone: it put `gap_min` at 122 + margin, so any margin under 15 let a perfect run-jump through.
**Example:** a 150 px gap (margin 8) needs the dash: a run-jump crosses at most 137 px edge to edge and the dash-jump clears up to 170 px; a 140 px gap is rejected at margin 8 (below `gap_min` 145, too close to what a coyote run-jump can reach). A 150 px gap over a safe floor 80 px below its lips, with a bare far face and a ramp back to the near side, passes; the same gap over a floor 40 px down is rejected (the start kit drops in and jumps out on the far side), and so is one with a crate in mid-gap.

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

The chain proves a crossing exists with the grapple; it does not make every anchor necessary (with gate anchors, F11, every anchor of it is also needed).

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
**Gate anchors (rules 18-19, F11).** `_grapple_jump_out` in `player.gd` restores the air dash and the air jump, so on a plain anchor a player can cover far more than one hop. Every anchor of a grapple gate is therefore a `gate_anchor`: the jump-out there restores nothing, and the anchors are targeted in chain order, so the intended chain is the only way across (F11).
**Example:** F3a: a ledge 160 px up on an 8 px plain slab (underside 152), no launch face, with an anchor 24 px beyond its edge. F3b: a 440 px chasm over a kill plane, the far side a 12 px plain slab, with anchors at about 147 px and 293 px from the take-off edge, each hop about 147 px. A 430 px chasm with a 60 px plain far face is rejected (a deep far face lets the wall cling catch and climb it).

### F6. Cling wall

Two gate shapes for the wall cling (key 2), valid only if the start kit cannot cross them and the wall cling can. One plain face is enough (Core Rules, one wall is a ladder); only `climbable`-marked surfaces climb.

**F6a. Cling wall.** A plain face with `wall_height >= ledge_min` (F2: `jump_apex + ledge_nudge + ledge_margin_low`) and no standing spot on or beside it within `ledge_min` of the one below it (otherwise the start kit climbs it in hops). A shaft of two facing walls is two cling walls; its width does not matter for the key, which climbs either face alone.

**F6b. Climb wall.** A `climbable`-marked surface of height `>= ledge_min` with no other way up. In the code a `climbable` is an `Area2D` the Seeker snaps to and climbs at `climb_speed` (70 px/s). Kicking up a plain face is faster (about 190 px/s), so a climb wall is a slow, safe ascent, not a separate skill test; it is gated with the wall cling (rule 1).

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

**Output Range:** with keys 1-2 a plain face rising to a double-jump ledge's height must stand more than about 230 px from it (plus `landing_slack` 15); with keys 1-3 a face rising to a grapple target must stand more than about 335 px away, more for taller faces. Inside that range the face is `no_cling`, or its top is lower than `target_top - launch_rise` (a short wall, or a face under a local low ceiling away from the gate). A room ceiling over the gate is never that low, so it lowers `dh` but never exempts a face.
**Example:** a 100 px double-jump ledge with a plain cave wall 180 px away that rises to the ceiling is rejected; the same wall with `no_cling` thorn vines, or 260 px away under a ceiling 40 px above the ledge, passes.
**Edge:** the start kit has no wall cling, so F8 never applies to F1 or F6. A face that cannot be reached at all with the kit is still counted (conservative); the Auto check may drop it only with a reachability test.

### F9. Gate room footprint

The gate_room_width rule (level design rule 26) is defined as:

`room_width >= span + 2 x (wall_reach(kit, dh_wall) + landing_slack)`, unless every plain face within that reach is `no_cling` (then F8 finds no launch face). F9 assumes a **free-standing** gate: an island ledge or a gap, with open floor between it and each room wall. A ledge that juts from a wall has that wall as a launch face at distance 0 (F8) unless the wall is `no_cling` above the ledge. A sealed alcove (level design rule 2) sits on the ledge top or the far floor, inside this footprint, and needs no extra width. It puts a plain wall, which rises to the ceiling, far enough from the gate on both sides that F8 finds no launch face. `dh_wall = room_height - target_top` is the F8 `dh` of such a wall; `wall_reach` is read from the F8 table and extrapolated beyond `dh` 300 at about 0.3 px per px (re-measure). The take-off side of a grapple gap needs less than this, but the rule keeps both sides equal and conservative.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| span | float (px) | data file (room data) | the ledge's width (F2, F3a) or the gap's width (F3b) | Width of the gate between its two edges |
| room_height | float (px) | 270 or more, whole screens | data file (room data) | Height to the ceiling |
| dh_wall | float (px) | 0 or more | calculated | `room_height - target_top` for a wall that rises to the ceiling; F3b's target is the far lip at floor level (`target_top` 0) |
| wall_reach | float (px) | see F8 | calculated from player_config | F8 table value for the kit (keys 1-2 for F2, keys 1-3 for F3) at `dh_wall` |
| landing_slack | float (px) | 15 | calculated | From F1 |
| room_width | float (px) | whole screens | data file (room data) | Width of the room |

**Output Range (plain walls to the ceiling, 1 screen high, 270 px):**
- F2 double-jump ledge, top 72-108: `dh_wall` 162-198, `wall_reach` about 278-288, so each side needs about 293-303 px: `room_width >= span + about 606`. A room 2 screens wide (960) holds a ledge up to about 350 px wide. In a room 2 screens high (540) `dh_wall` is up to about 470 and each side needs about 375 px: 2 screens wide holds a ledge up to about 210 px wide.
- F3a grapple ledge, top 160: `dh_wall` 110, `wall_reach` about 364, so each side needs about 379 px: `room_width >= span + about 758`. 2 screens wide holds a ledge up to about 200 px wide; wider or taller rooms need 3.
- F3b grapple gap, 440 px: `dh_wall` 270, `wall_reach` about 411, so each side needs about 426 px: `room_width >= 440 + about 852`, about 1,290: 3 screens wide (1,440).
**Example:** Saggar Rows (1x2, 480 px wide) with a double-jump gate and plain saggar columns to the ceiling needs `room_width >= span + about 750`; it is rejected, and at 2x2 (960) it holds a ledge up to about 210 px wide. Ropewalk Stair (1x3, 480 px wide) with a 440 px grapple gap is rejected (needs about 1,290); at 3x3 it passes.
**Edge:** a room that holds no double-jump or grapple gate is exempt. A room whose near walls are all `no_cling` is exempt for those walls only, not for the others. The wall cling is not owned before key 2, so F1 and F6 gate rooms never need F9.

### F10. Bisque pane

The bisque_pane rule is defined as:

`pane_detect_px = ceil(dash_speed / sim_hz) + detect_margin`; a pane is valid when it spans its passage from floor to ceiling with no opening, `pane_thickness_min <= pane_thickness <= pane_thickness_max`, and it is not in the `hittable` group. It breaks when the Seeker is in the dash state, inside the pane's detect band (`pane_detect_px` out from each face), and dashing toward the pane.

Why the detect band. A dash moves about 6.2 px per physics frame. If the break waited for body contact, `move_and_slide` would stop the Seeker against the face first and the dash speed would be lost on the frame the pane breaks. A band at least one frame of dash travel deep breaks the pane before the body reaches it, so the Seeker passes through at full speed (rule 16).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| dash_speed | float (px/s) | 370 | player_config | Speed during a dash |
| sim_hz | int | 60 | constant (physics tick) | Physics frames per second |
| detect_margin | float (px) | 1-4, starts at 2 | data file | Slack beyond one frame of dash travel |
| pane_detect_px | float (px) | about 9 | calculated | Depth of the detect band on each face |
| pane_thickness | float (px) | 8-16, starts at 12 | data file (room data) | Thickness of the pane's collision; thin enough to read as a pane, at least one tile edge thick |
| pane_thickness_min, pane_thickness_max | float (px) | 8, 16 | data file | Bounds on `pane_thickness` |

**Output Range:** `pane_detect_px` = ceil(370 / 60) + 2 = 7 + 2 = 9 px. It grows with the dash: at a `dash_speed` of 600 it is 12, at 900 it is 17. It never limits `pane_thickness`, because the band lies outside the faces. At `dash_speed` 0 the band is `detect_margin` deep, but there is no dash to break the pane with, so the pane cannot break (expected: the dash defines the gate).
**Example:** a 12 px pane filling a 64 px tall passage breaks when the Seeker ground-dashes into it from 40 px away; it does not break from a run, an attack, the charged heavy, a pogo attempt or a dash-jump at the same spot, and a dash pointing away from the pane inside the band does not break it. A pane with a 30 px opening above it is rejected (the start kit jumps over it).
**Edge:** a dash that ends (dash time over) before reaching the band does not break the pane. Two panes in a row break one after the other in the same dash, if the dash lasts.

### F11. Gate anchor chain

The gate_anchor_chain rule is defined as:

A grapple gate's anchors `a_1 ... a_n` are `gate_anchor`s with an order. Targeting: the grapple may hook `a_1` freely, and may hook `a_k` or `a_(k+1)` only while the **chain step** is `k`; the chain step is the last gate anchor hooked, and it resets to 0 when the Seeker touches the ground or after `chain_window` seconds in the air since the last release. Spacing: every hop (take-off to `a_1`, `a_k` to `a_(k+1)`, `a_n` to the far floor) is at most `grapple_range`, and `far_x(a_(n-1)) > release_reach + landing_slack + anchor_margin`, where `far_x(a)` is the horizontal distance from anchor `a` to the far lip. For a one-anchor chain (n = 1), use the take-off lip for `a_0` (F3b already holds it).

Why both parts. Ordered targeting means no later anchor can be hooked before the one before it, so no anchor can be skipped by grappling past it (the first anchor in particular: spacing alone cannot force it, because an air-kit arc from the lip reaches anchor 2). The spacing check covers the one skip ordering cannot stop: flying from `a_(n-1)` to the far floor without hooking `a_n`. Gate anchors restore no air moves on the jump-out (rule 18), so that flight is a single release.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| grapple_range | float (px) | 200 | data file (player_config) | Farthest anchor the grapple reaches |
| chain_window | float (s) | 0.3-1.0, starts at 0.6 | data file | Air time after a release during which the next anchor may still be hooked |
| release_reach | float (px) | about 150-250 (estimate, not simulated) | calculated from player_config | Farthest horizontal centre travel from a release or a no-refresh jump-out on a gate anchor down to the far lip's height (`grapple_fling_keep` 0.8 of `grapple_speed` 360, or `grapple_jump_keep` 0.5 plus `grapple_jump_speed` 260). Re-measure (Open Question 3) |
| landing_slack | float (px) | 15 | calculated (F1) | Hitbox and nudge allowance for the landing |
| anchor_margin | float (px) | 8-24, starts at 16 | data file | Keeps a perfect release from landing on the far floor |
| far_x(a) | float (px) | 0 or more | data file (room data) | Horizontal distance from anchor `a` to the far lip |

**Output Range:** with the estimate, `far_x(a_(n-1))` must exceed about 181-281 px; the chain needs at least two anchors (F3b). Ordered targeting has no numeric output. At `chain_window` 0 the next anchor must be hooked during the release itself, which is unforgiving; above 1 s a falling player can still hook the next anchor from far below the chain, which is harmless but reads oddly.
**Example:** the F3b chasm (440 px, anchors at 147 and 293 px from the take-off lip): the hops are 147, 146 and 147 px, all within 200; `far_x(a_1)` is 293 px, which passes if the measured `release_reach` is under 262 px (293 - 15 - 16). A chain with anchors at 200 and 400 px over a 440 px chasm fails if `release_reach` is over 209 px (`far_x(a_1)` 240), so a player could release from `a_1` and land without hooking `a_2`.
**Edge:** hooking `a_1` again after a fall restarts the chain. A chain whose anchors are out of order in the room data (a later anchor nearer the take-off) is rejected. A plain anchor placed near a gate chain is a skip route: no plain anchor may lie within `grapple_range` of any point of a gate chain's flight path (rule 18).

**Feedback loops:** none inside this system. Owning more keys makes every earlier gate easier (intended, rule 9).

**Registry candidates (owned by the player controller once its GDD exists):** run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, hitbox_height, kick_rise, wall_reach, release_reach. Owned here: the gate windows (`gap_min`, `gap_max`, `ledge_min`, `ledge_max`, `head_clear`, `head_clear_dj`), `pit_depth_min`, `pane_detect_px`.


## Edge Cases

`systems-designer` not consulted for this section: Lean mode. Review manually before production. Placement edge cases (a gate that fails its cling test, a narrow gate room, a shallow pit) are level design's and stay in its Edge Cases.

- **If the Seeker touches a pickup whose key is already owned** (granted elsewhere, or by a load): the pickup is never shown; if it was shown and the key arrives another way first, it frees itself on `abilities_changed` without a flash or the first-pickup note.
- **If two pickups of the same key exist in the world** (a level data error): the first touched grants; the second frees itself as above. The level design [Auto] check rejects the layout (one pickup per key).
- **If the player dies or quits on the frame of a pickup**: the grant and its World state record happen together on touch, so a reload shows the key owned and the pickup gone, or neither. There is no half-granted state.
- **If a key is granted mid-move** (touching a pickup during a dash or a jump): it takes effect on the next press. The current move finishes unchanged.
- **If the wall cling is lost from a save** (an old save, or a load error): the controller drops any wall slide or climb in progress at once and the Seeker falls; the save system owns the repair.
- **If the Seeker dashes into a bisque pane at the moment the dash ends**: it breaks only if the Seeker is still in the dash state inside the detect band (F10). A dash that ends 1 px short does not break it, and the Seeker stops at the pane as at any wall.
- **If a pane breaks while an enemy stands behind it**: the enemy is not hurt and the Seeker's dash continues into it as into any enemy (combat rules apply).
- **If a pane is the only way out of a room and the player does not own the dash**: they came in through another route, which must still be open (level design return-path rule). A pane never closes a room behind the player.
- **If the player hooks a gate anchor out of order** (a later anchor while the chain step is lower): the grapple does not hook it. The press falls through to the nearest targetable anchor in range if one exists, otherwise nothing happens, the same as when no anchor is in range.
- **If the player lands back on the take-off floor mid-chain**: the chain step resets to 0, and only the first anchor can be hooked.
- **If a plain anchor lies within reach of a gate chain's flight path**: the layout is rejected (F11 edge). A plain anchor would let the player jump out with refreshed air moves and skip.
- **If the wall cling is owned and the Seeker touches a `no_cling` face while sliding down a plain face below it**: the slide stops where the plain face ends and the Seeker falls along the `no_cling` part. A wall jump pressed against the `no_cling` part does nothing.
- **If a `climbable` surface overlaps a `no_cling` face**: `climbable` wins (the Seeker can climb it), and the layout check flags the overlap. A gate must not rely on either.
- **If the dash is owned but the player never uses it near a pane**: nothing happens. Panes have no timer, and no sign or hint fires on its own.

## Dependencies

**Upstream (this system needs them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Player controller and input | Hard | The movement figures every formula reads (`player_config.tres`); the dash state (F10); and the controller changes this system requires: dash and wall cling gating, the `no_cling` skip, gate anchor no-refresh and ordered targeting | No (code exists) |
| World state | Hard | Storage of keys owned and panes broken, written at the moment of change and restored on load | No (provisional) |
| Combat | Soft | The `hittable` group, so panes stay out of it and the pogo cannot use them | No (code exists) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Level design and world layout | Hard | Gate types, F1-F3, F6, F8-F11, signatures, `no_cling`, gate anchors; it places them (`design/gdd/level-design.md`, which lists this GDD) |
| Terrain pipeline | Hard | A `no_cling` material and a bisque pane material to build and paint |
| HUD | Soft | `abilities_changed` and the first-pickup event |
| Save points and save/load | Hard (via World state) | `PlayerState` saved with World state |
| Lore delivery and mentor pact | Soft | The `grant` call for the mentor's key |
| Elemental palette power-ups (later) | Soft | Gate materials per element |

**Bidirectional check:** Level design lists this system as a hard upstream dependency and names this GDD (updated 2026-11-18). The systems index lists Ability gating as depending on Player controller and World state; Combat (soft) and Terrain pipeline (downstream) are new here and need adding to the index (Phase 5). No other GDD exists to check.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The art bible (not yet written) owns the final look.

- **One signature per key** (rule 10): shape, material and colour, readable at 480 x 270 from across a room and in greyscale (level design: collision edges are the brightest values). Lore candidates: dash, bisque (pale unfired clay) on pane faces and gap lips; wall cling, copper-green finger-drag grooves; double jump, the kiln shelf on stilts; grapple, the iron ring and violet cord. Copper-green is reserved for the wall cling.
- **`no_cling` signature** (rule 14): a material over the whole face (candidates: slick glaze for the kiln city, thorn vines for a cavern region), never copper-green, so a player can tell from across a room which walls will not hold them.
- **Bisque pane:** reads as thin and brittle (cracks, light through it). On break: a shatter of pale shards along the dash direction, a short bright crack sound, no hit-stop (the dash must not stall), and shards that settle and fade within about 1 s. It never respawns.
- **Gate anchor:** reads as part of a chain (a cord or groove linking anchors in order) so the order is seen before it is tried; a hookable anchor in the current chain step brightens slightly when in range. A plain anchor looks different from a gate anchor.
- **Pickup:** the placeholder is a pulsing diamond in the key's colour; the shipped pickup carries the key's signature. On touch: flash, a clear short cue distinct for each key, then the first-pickup note (UI).
- **Sign** (`AbilityGate`): dim (brightness 0.35) until owned, lit with a glow after. The placeholder plate and text are test-room aids.
- **Audio:** a gate whose key is unowned gives a small audio tell the first time it is approached (level design); an unowned key's input gives no sound (rule 3).

## Game Feel

Targets are checked in a playtest; movement feel itself belongs to the player controller.

- **Key moment:** the pickup flash and cue land on the touch frame; the key works on the next press (edge case), and the workshop room follows (level design rule 11).
- **Pane break:** dashing through a pane costs no speed (F10 criterion) and the shatter reads within the dash (0.25 s). A playtester asked afterwards describes the pane as "broken by dashing", not "broken by attacking".
- **Gate anchors:** a player who knows the grapple crosses a 3-anchor chain within 3 attempts; the no-refresh rule is noticed as "these anchors are different", not as a bug (playtest question).
- **Honest locks:** after the first 10 minutes a playtester can say which key a seen gate needs, by its signature, for at least the dash gap and the cling wall.

## UI Requirements

- A short on-screen note on the first pickup of each key names it (text from Lore delivery); shown once per key.
- The debug HUD lists owned keys from `abilities_changed` (development only).
- No HUD lock icon, no key counter and no map marker for gates or pickups (level design rule 23).

📌 **UX Flag — Ability gating**: the first-pickup note is a UI element. In Pre-Production, run `/ux-design` for it before writing epics; stories cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD uses | Owner (system) | Status |
|---------------|----------------|--------|
| run_jump_distance, dash_jump_distance, double_jump_total, jump_apex, max_non_grapple_crossing, kick_rise, kick_cycle, launch_rise, wall_reach, far_face_extra, release_reach (F1-F3, F6, F8, F11) | Player controller / movement | Calculated from `player_config.tres`; to be registered |
| hitbox_size (10 x 22), ledge_nudge (5), wall_jump_reach (3), dash_speed (370), climb_speed (70), grapple_range (200), grapple_speed, grapple_fling_keep, grapple_jump_keep, grapple_jump_speed | Player controller | In `player_config.tres` |
| `_grapple_jump_out`, `_try_start_grapple` (rules 18-19) | Player controller | In `player.gd`; changes needed (Open Question 2) |
| The `hittable` group, pogo (rule 16) | Combat | In code; no GDD |
| Sealed alcove, gate room footprint use (F9), pit return path (F1), "seen twice" (rule 11), workshop (Game Feel) | Level design | `design/gdd/level-design.md` rules 2, 8, 11, 26 |
| Key storage and pane records | World state | Not designed |
| Signatures, `no_cling` and pane materials | Art bible, Terrain pipeline | Not written |

## Acceptance Criteria

Types: **[Auto]** automated test (unit test on `PlayerState`, the pickup or the controller, or a check on room data); **[Play]** playtest record; **[Shot]** retained screenshot in `production/qa/evidence/`. At standard rigor, Logic and Integration need a test or a playtest record; Visual and UI need a screenshot. The qa-lead lens was applied by the author (lean mode); the gaps it found are listed at the end.

**Ownership (rules 1-6)**
- **GIVEN** a new `PlayerState`, **WHEN** it is created, **THEN** `owns` returns false for dash, wall cling, double jump and grapple. **[Auto]** (rules 1, 2)
- **GIVEN** a `PlayerState`, **WHEN** each of the four keys is granted once and then granted again, **THEN** `owns` is true for that key, `abilities_changed` fired exactly once per key, and no call sets a key back to unowned. **[Auto]** (rule 1, States)
- **GIVEN** a Seeker with none of the four keys, **WHEN** the dash input is pressed, the Seeker jumps into a plain wall and presses jump, touches a `climbable` surface, presses jump in the air and presses grapple beside an anchor, **THEN** no dash, wall slide, wall jump, climb, air jump or grapple starts, and the Seeker's state and velocity match a run with those inputs absent. **[Auto]** (rule 3; needs Open Question 1)
- **GIVEN** a Seeker with no keys, **WHEN** it runs, jumps, uses the full sword set (3-hit combo, up and down attacks, pogo off a `hittable`, charged heavy), crouches and enters a door, **THEN** each works. **[Auto]** (rule 2)
- **GIVEN** a `PlayerState` with only the grapple granted, **WHEN** the Seeker presses grapple beside an anchor in range, **THEN** the grapple starts, with no other key owned. **[Auto]** (rule 4)
- **GIVEN** an `AbilityPickup` for a key not yet owned, **WHEN** the Seeker touches it, **THEN** the key is owned on that frame, World state holds the record, the pickup flashes and frees itself, and the first-pickup event fires once. **GIVEN** the key already owned, **WHEN** the pickup enters the tree, **THEN** it frees itself at once and is never drawn. **[Auto]** (rule 5)
- **GIVEN** every pickup in the world, **WHEN** the room data is checked, **THEN** each names exactly one `channel` (boss, shrine or mentor) and no two pickups grant the same key. **[Auto]** (rule 5, edge case)
- **GIVEN** the mentor pact, **WHEN** the player accepts it, **THEN** the double jump is owned through the same `grant` call, with no pickup node. **[Auto]** (rule 6)
- **GIVEN** a key collected and the game quit on that frame, **WHEN** it reloads, **THEN** either the key is owned and the pickup gone, or the key is unowned and the pickup present; never one without the other. **[Auto]** (edge case; depends on World state)

**Gate types and signatures (rules 7-11)**
- **GIVEN** the room data of every region, **WHEN** it is checked, **THEN** every gate is one of the seven types in rule 7's table and carries its key's signature material; a gate of any other type is rejected. **[Auto]** (rules 7, 8)
- **GIVEN** each key's gate signature in a painted room, **WHEN** the room is captured, **THEN** the signature reads at 480 x 270 from the far side of the room, and no non-gate surface in the region uses that key's material. **[Shot]** plus an asset tag check **[Auto]** (rule 10)
- **GIVEN** region 1, **WHEN** its walls are checked, **THEN** every cling wall placed as a gate and every `climbable` surface carries the groove signature, and no other surface does. **[Auto]** (rule 11)

**Gate fit (F1-F3, F6, F8, F9, rules 12-14)**
- **GIVEN** a dash gap of edge-to-edge width W, **WHEN** the room data is checked, **THEN** `gap_min <= W <= gap_max` with the reaches computed from `player_config.tres` (at margin 8: 145 to 162); a gap at `gap_min - 1` is rejected, a gap at `gap_max + 1` is rejected, and a 137 px gap (the widest a coyote run-jump can land) is rejected; the lips are at the same collision height; the floor below is a hazard or kill plane, or a safe floor at least `pit_depth_min` (about 72) below the far lip with no standing spot on the far face; and nothing stands in the span but the pit floor. A pit 72 px deep passes, one 71 px deep is rejected, and a gap with a standing spot in mid-gap is rejected. **[Auto]** (F1, boundary)
- **GIVEN** a double-jump ledge with top height h, **WHEN** checked, **THEN** `ledge_min <= h <= ledge_max`, each of its own faces is `no_cling` or has its lowest point at `head_clear` (about 88) or higher, and no plain face is a launch face (F8, keys 1-2); a 100 px ledge on an 8 px plain slab passes, a 90 px ledge on a 16 px plain slab (underside 74) is rejected, the same ledge with `no_cling` faces passes, and a plain wall rising to the ledge's height 180 px away is rejected. **[Auto]** (F2, F8, boundary)
- **GIVEN** a grapple ledge (F3a), **WHEN** checked, **THEN** `target_height >= double_jump_total + grapple_margin`, an anchor lies within 200 px of a standing spot, its own faces are `no_cling` or have their lowest point at `head_clear_dj` (about 143) or higher, and no plain face is a launch face (F8, keys 1-3); a ledge 120 px up is rejected, a 140 px ledge on a plain slab (underside below 143) is rejected, and a 160 px ledge with a plain wall rising above it 300 px away is rejected. **[Auto]** (F3a, F8, boundary)
- **GIVEN** a grapple gap (F3b), **WHEN** checked, **THEN** `gap_width >= max_non_grapple_crossing + far_face_extra + landing_slack + grapple_margin`, every hop (take-off, anchors, far floor) is at most `grapple_range`, the far face is `no_cling` or plain for at most `far_face_max` (16 px), the gap has a hazard or kill plane below with no standing spot or plain face in its span, and no plain face is a launch face for the far lip; a 414 px gap is rejected, a chain with one 210 px hop is rejected, a 430 px gap with a 60 px plain far face is rejected, and a gap with a walkable floor below is rejected. **[Auto]** (F3b, F8, boundary)
- **GIVEN** a cling wall (F6a) or climb wall (F6b), **WHEN** checked, **THEN** `wall_height >= ledge_min`, the face has no standing spot on it, and a climb wall is `climbable`-marked; a 60 px wall and a wall with a standing spot 50 px up are each rejected, and a single 200 px plain face passes. **[Auto]** (F6, boundary)
- **GIVEN** each room that holds a double-jump or grapple gate with plain walls, **WHEN** the room data is checked, **THEN** `room_width >= span + 2 x (wall_reach + landing_slack)` (F9, with `wall_reach` read from the F8 table for the kit and `dh_wall`); a 480 px wide room with a double-jump ledge 100 px wide is rejected, a 960 px wide room 1 screen high with a ledge up to about 350 px wide passes, and a 440 px grapple gap in a room under about 1,290 px wide is rejected. **[Auto]** (F9, level design rule 26, boundary)
- **GIVEN** the wall cling owned and a `no_cling` face, **WHEN** the Seeker presses into it and presses jump, **THEN** no wall slide and no wall jump starts; against a plain face both do. **[Auto]** (controller unit test; rule 14; needs the story in Open Question 2)
- **GIVEN** the movement values in `player_config.tres`, **WHEN** the Seeker attempts F1-F3 and F6 gates in `movement_test_room`, **THEN** a perfect run-jump (centre at the edge, full hitbox overlap, nudge) never crosses a dash gap, a plain jump never touches a double-jump ledge, its plain underside or the top of a cling wall, the double jump never reaches a grapple ledge, dash, double jump and air dash together never cross a grapple gap, and a kick off a plain wall farther than `wall_reach` never reaches its target; and with the wall cling a single plain wall can be climbed by repeated kicks. **[Auto]** as a scripted input sweep in `movement_test_room` (the same sweep as the start-kit criterion, over every move the gate's earlier kit owns; 0 crossings), plus a 20-minute **[Play]** pass for what the sweep does not try (re-measure the [Calc] figures: `landing_slack`, `max_non_grapple_crossing`, `kick_rise`, `wall_reach`, `far_face_extra`, `pogo_carry`)

**Bisque pane (rules 15-17, F10)**
- **GIVEN** a bisque pane 12 px thick filling a passage, **WHEN** the Seeker ground-dashes and, separately, air-dashes into it from each side, **THEN** it breaks each time, and the Seeker's horizontal speed on the frame after it passes the pane's position is the dash speed (370 px/s, within one frame's deceleration). **[Auto]** (rules 15-16, F10)
- **GIVEN** an intact pane, **WHEN** the Seeker runs into it, attacks it with every attack including the charged heavy, tries a pogo on it, dash-jumps into it, dashes away from it inside its detect band, and an enemy and a projectile hit it, **THEN** it stays intact, and it is not in the `hittable` group. **[Auto]** (rule 16, F10)
- **GIVEN** `dash_speed` 370 and `detect_margin` 2, **WHEN** `pane_detect_px` is computed, **THEN** it is 9; at `dash_speed` 600 it is 12. A pane with any opening around it (30 px above, for example) is rejected, and so are panes 7 px and 17 px thick. **[Auto]** (F10, boundary)
- **GIVEN** a broken pane, **WHEN** the room is left and re-entered, and the game is saved and reloaded, **THEN** the pane is still broken. **[Auto]** (rule 17, States; depends on World state)

**Gate anchors (rules 18-19, F11)**
- **GIVEN** the grapple and the double jump owned, the air jump and air dash spent, and the Seeker on a pull to a `gate_anchor`, **WHEN** jump is pressed, **THEN** the Seeker jumps out and the air jump and air dash stay spent. The same test on a plain anchor restores both. **[Auto]** (rule 18; needs Open Question 2)
- **GIVEN** a gate chain `a_1, a_2, a_3` with the chain step 0, **WHEN** the Seeker presses grapple within range of `a_2` only, **THEN** nothing hooks. With the chain step 1 (just released from `a_1`), `a_2` hooks; with the chain step 1, `a_3` in range and `a_2` out of range, nothing hooks. The chain step resets to 0 on landing and `chain_window` (0.6 s) after the last release. **[Auto]** (rule 19, F11)
- **GIVEN** a grapple gap's room data, **WHEN** checked, **THEN** every hop is at most `grapple_range`, the anchors are in order from the take-off lip, `far_x(a_(n-1)) > release_reach + landing_slack + anchor_margin`, and no plain anchor lies within `grapple_range` of the chain's flight path; the 440 px chasm with anchors at 147 and 293 px passes if `release_reach` is under 262, and anchors at 200 and 400 px are rejected if it is over 209. **[Auto]** (F11, boundary)
- **GIVEN** each grapple gate in `movement_test_room`, **WHEN** the input sweep tries every way across with all four keys, **THEN** every crossing hooks every anchor of the chain in order (0 crossings that skip one). **[Auto]** plus a 20-minute **[Play]** pass (rule 19)

**Signs (rule 20)**
- **GIVEN** an `AbilityGate` sign whose key is unowned, **WHEN** the key is granted, **THEN** the sign goes from dim (brightness 0.35) to lit with its glow shown on the same frame as `abilities_changed`. **[Auto]**, and one **[Shot]** of each state (rule 20, States)

**Gaps found by the QA lens:**
- Rule 3 and the anchor criteria need controller changes before they can run (Open Questions 1-2).
- `release_reach` and the [Calc] figures are unmeasured (Open Question 3), so F11's spacing check and the F1-F3 boundaries are provisional until measured.
- Rule 10's "reads from the far side of the room" is a screenshot judgement, not a number. It stays a [Shot] check reviewed by the art lead.

## Open Questions

Owner is the project owner unless stated. Each has a target step instead of a date.

1. **Gate the dash and the wall cling in code.** Add `DASH` and `WALL_CLING` to `PlayerState` (flags, `grant`, `owns`) and check them in `player.gd` before the dash, wall slide, wall jump and climb (rule 3). Today they are always available. Target: the story that sets the real starting state (story 007, level design Open Question 12).
2. **Controller changes for gates.** (a) The `no_cling` skip for the wall slide and `_wall_jump_direction` (rule 14; physics layer or group, becomes an ADR); (b) the `gate_anchor` no-refresh in `_grapple_jump_out` (rule 18); (c) ordered targeting and the chain step in `_try_start_grapple` (rule 19, F11); (d) the bisque pane node and its detect band (F10). Target: before any double-jump, grapple or pane gate is built.
3. **Measure the [Calc] figures** in `movement_test_room`: `landing_slack`, `max_non_grapple_crossing`, `kick_rise`, `kick_cycle`, `wall_reach` (F8 table), `launch_rise`, `far_face_extra`, `pogo_rise`, `pogo_carry`, and the new `release_reach` (F11). Target: before the first gate is built.
4. **Signatures and materials.** The four key signatures, the `no_cling` material and the pane's look are chosen with the art bible. Target: `/art-bible`.
5. **Bisque pane placement in region 1.** The integration draft held the pane back; level design and the narrative side decide where panes go now that they exist (each needs a seen-twice count like any gate). Target: the integration draft revision (level design Open Question 18).
