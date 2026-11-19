# Terrain pipeline

> **Status**: Revised 2026-11-19 after the second `/design-review` (lean: NEEDS REVISION, 2 blockers addressed, 4 of 6 recommended addressed; first review's 3 blockers and 7 recommended addressed earlier the same day); awaiting re-review in a fresh session (CD-GDD-ALIGN skipped: lean mode)
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-19
> **Last Verified**: 2026-11-19
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room")

## Summary

The terrain pipeline is how the ground of every room is made. Rooms are blocked out in 6 px black collision tiles and played at once, as Team Cherry built Hollow Knight. Once approved, a room gets rock trim baked from its collision and hand-placed dressing, and its edges never move to fit the art. It exists so that every gate level design and ability gating place is measured on true collision, every wall carries its material (`plain` or `no_cling`), and large painted rooms stay cheap to build and draw.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None (reads Ability gating and Level design for definitions)`

## Overview

The terrain pipeline decides how the solid ground of a room is made and how it reads: the collision the Seeker runs, jumps, clings to and falls against, the painted look laid over it, and the path from an approved grey-box (collision only) to a finished painted room without moving a single collision edge. The player never operates it. They feel it as ground that is exactly what it looks like (a ledge that reads as reachable with a double jump is one, and a gap that reads as too wide for a run-jump is) and as a world with a painted identity per region. Level design and ability gating measure every gate on the collision this system produces, to the pixel (the dash gap window is about 145-162 px, the double-jump ledge window 72-106 px), so its first job is fidelity: collision is authored precisely, approved on a grey-box, and never moved to suit the art. Its second job is the face materials the world needs and the signatures nothing else uses: `plain` and `no_cling` faces, the wall-cling grooves on cling-wall faces and `climbable` surfaces, and the bisque pane that only a dash breaks (an object on the grid, not a face material). Its third is cost: large rooms of several screens, left by open edges, must build and draw within the memory and node budgets of the painted biome packs. It is the foundation under rooms and transitions and under the parallax and atmosphere layers; without it no room can be built, no gate can be trusted, and the painted art has nowhere to land.

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Sourced]** = from Team Cherry's account of building Hollow Knight (PC Gamer, "How to design a great Metroidvania map", 2017 interview); **[Rec]** = recommendation, change freely; **[Calc]** = computed. Engine-API details are not covered by `docs/engine-reference/godot/` and belong to the ADR (Open Questions).

`systems-designer`, `gameplay-programmer` and `engine-programmer` not consulted: Lean mode. Review manually before production.

**Units and the collision grid**

1. **Units.** Every figure in this and every other GDD is in game px: a screen is 480 x 270, the Seeker 10 x 22. The game draws the world 4x larger, at 1920 x 1080; art is scaled to the game, never the game to the art. The project settings still hold the 480 x 270 viewport stretch and only the art-style test room switches to 1920 x 1080 at runtime; the migration is Open Question 9. **[Owner, 2026-11-19; settles the units half of level design Open Question 17]**
2. **The grid.** Solid terrain is a grid of square black collision tiles, `collision_tile` = 6 px, anchored at the room's top-left corner. A screen is 80 x 45 tiles, so every room bound, collision edge and gate edge lies on a grid line. **[Owner, 2026-11-19]** **[Sourced]** (Hollow Knight: "the whole world is just built from black tiles that are 64x64 pixels. They're very quick to paint in, and from there we can just hit play") Why 6: it divides the screen both ways, it nests 6 x 6 into the painted art's 36 px cell, and it leaves two legal dash gaps inside ability gating's F1 window (150 and 156 px; Formulas). **[Calc]**
3. **Tile kinds.** A tile is empty, solid, or one-way (solid from above only: the Seeker rises through it and lands on it). There are no slopes and no part tiles: every collision face is horizontal or vertical, which is what the gate formulas assume (level lips, plain vertical faces). **[Rec]**
4. **Terrain never changes at runtime.** Anything that opens, breaks, moves, hurts or is climbed is an object placed on the grid and owned by its system: doors and shortcut gates, breakable walls, bisque panes (ability gating F10), hazards and kill planes, `climbable` markers, gate anchors, moving platforms. Their collision edges also lie on grid lines. World state therefore never stores terrain. **[Rec]**
5. **What looks solid is solid.** On the play layer, anything that reads as ground, wall or ledge has solid tiles under it whose edge is its walkable or clingable line, and nothing solid is left unpainted or hidden. Dressing never carries collision. No invisible walls, no painted floors that drop the Seeker through. Background and foreground layers (parallax, lighting and atmosphere) are not the play layer and never imitate it (level design, Visual/Audio: Readability). **[Rec]**

**Faces and materials**

6. **Face segments.** A face is a straight run of collision edge between a solid (or one-way) tile and an empty one, on one side of a mass, from corner to corner. It is split at grid lines into **segments**, and each segment has one material: `plain` (the default) or `no_cling`. Material belongs to the segment, not the mass: a one-tile-thick wall may be `no_cling` on its left and plain on its right, and one wall may turn `no_cling` partway up (ability gating Edge Cases: a slide stops where the plain part ends). **[Owner, 2026-11-19: per face]** What `no_cling` does is ability gating's (rule 14). **Gate marks.** Each segment also carries a `gate` mark, `none` by default or the gate type it belongs to: `dash_gap` (F1), `double_jump_ledge` (F2), `grapple_ledge` (F3a), `grapple_gap` (F3b), `cling_wall` (F6a) or `climb_wall` (F6b). Level design authors the marks in the room data, on every segment its gate formulas measure (the lips and faces of a gap, the top and faces of a ledge, the face of a wall). A gate check that finds a segment it measures without its mark fails the room and names the placement. A `cling_wall` segment is never `no_cling` (rule 7). **One-way tiles.** A one-way tile has one collision face, its top edge. Its sides and underside are not collision edges: they carry no material and no gate mark, the bake may still trim them for looks, and T3 ignores them. **[Rec]**
7. **Signatures painted from data.** The bake (rule 11) paints each `no_cling` segment with its material over its whole length, and paints the wall-cling grooves on every `cling_wall` segment and behind every `climbable` marker (ability gating rule 11), and each bisque pane's look over the pane's footprint from the object's data (a pane is an object, rule 4, and its faces are plain, ability gating rule 12). A segment never carries both `no_cling` and grooves: a `no_cling` segment never carries a `cling_wall` or `climb_wall` mark and never lies behind a `climbable` marker, and the room check rejects any of the three. The look of each comes from the art bible.
8. **Checks read data, never art.** Every layout check (ability gating F1-F11, level design F7 and rules 25-27) reads tiles, face materials and objects from the room data. A gate figure is a whole number of tiles: a 156 px gap is 26 tiles, a 90 px ledge 15. **[Calc]**

**From block-out to dressed room**

9. **Block-out.** A room starts as black tiles only, painted on the grid and played at once: "can you roughly reach every platform, does it make sense". No trim, no props. This is level design rule 3's grey-box. **[Sourced]** (Team Cherry call it "blocking out or tiling out a room")
10. **Approval.** A block-out is approved when its automated layout checks pass. A room's first approval also needs a play review that signs it off, and records `play_reviewed` in the room data. Approval stores a fingerprint of everything the layout checks read: the room bounds and its exits, the collision, the face materials, the gate marks (rule 6), every object on the grid that a check reads (hazards, kill planes, `hittable` targets, gate anchors, panes, `climbable` markers, doors and shortcut gates) and the enemy spawn points. A spawn point is a position, not collision, so it is not snapped to the grid (rule 4). Any later change to any of them is detected. Approval also stores a hash of every file the checks read: each check declares the files it reads, and the hash covers exactly that set (Edge Cases). A tuning change is therefore detected the same way.
11. **Trim bake.** The rock or moss trim on every exposed face is generated from the collision, never drawn by hand: the biome's edge art is placed along each face so that its painted rock line lies on the collision line, and solid interiors stay black. At every gate edge and every `no_cling` segment the trim overhangs the collision by at most `trim_overhang_max` (4 px, level design rule 25); elsewhere the bake follows the art. The same collision and biome always bake the same trim, so moving a platform "down one tile" re-bakes instead of re-painting. **[Owner, 2026-11-19: auto trim]** The bake runs automatically: on every save of a room's data in the editor, and at every build for any room whose fingerprint or biome changed since its last bake. Trim is therefore never older than the collision it was baked from. **[Owner, 2026-11-19, second design review]**
12. **Dressing.** Props, ruins, scenery, hanging decoration and play-layer framing are placed by hand over the baked trim. **[Owner, 2026-11-19]** **[Sourced]** (Team Cherry: "Ari will go through and 'dress' the room, put all the scenery and stuff in", before enemies and switches) Dressing obeys rule 5, and at gate edges and `no_cling` segments it may cover the collision edge by no more than `trim_overhang_max`, the same bound as the trim. When the artist has finished a room's dressing, they set the `dressed` sign-off in the room data. Only the artist sets it, and nothing sets it automatically: a baked room with no dressing is not Dressed. **[Owner, 2026-11-19, second design review]**
13. **A change after approval.** Editing the collision, a face material, a gate mark or an object a check reads, in an Approved or Dressed room, returns it to Block-out. The layout checks re-run at once, and a pass re-approves a room that already has `play_reviewed` with no further review (a designer can demand another by clearing the flag). The room keeps its trim and dressing as stale data. The trim re-bakes from the new collision in any state (rule 11 is deterministic), and any dressing that now overlaps solid tiles, floats over empty ones, or covers a gate edge past the bound is flagged for the artist, never moved silently. If the re-bake raises no flag, the `dressed` sign-off (rule 12) survives and the room is Dressed again as soon as it is re-approved. If any flag is raised, the sign-off is cleared: the artist clears the flags and sets it again. **[Owner, 2026-11-19, second design review]** Collision is never moved to fit the art (level design rule 25). **[Owner, 2026-11-19, first design review]**
14. **One biome per room.** A room names one biome pack for its trim and dressing and never loads a second biome's terrain art; a loaded biome costs about 97 MB of texture memory (level design Open Question 22). A region border is crossed between rooms, never inside one. **[Rec]**

**Cost**

15. **Collision cost follows the edge, not the area.** Solid interiors add no collision of their own: a 10-screen room's collision grows with the length of its exposed faces, not with its 36,000 tiles. Drawing is batched per layer, never one node per tile (the code-built art-style long room grew to 524 nodes). How this is built is an ADR (Open Questions). **[Rec; level design Open Question 22]**

**Gate figures on the grid (follow-up for level design)**

16. Gate figures are chosen from the on-grid values inside each window (Formulas). The dash workshop's gap (level design rule 11) is the narrowest on-grid width inside the F1 window, 150 px today, instead of "at most `gap_min` + 4 px", which no grid width meets. **[Owner, 2026-11-19; level design rule 11 and its criterion reworded the same day]**

### States and Transitions

Terrain has no runtime states (rule 4). Each room's terrain has a **production state**, stored in the room data and read by the build tools, the checks and the grey-box review; it is not world state.

| State | Meaning | Enter when | Leave when |
|-------|---------|-----------|-----------|
| Block-out | Collision, face materials, gate marks and objects only; playable. A room sent back by an edit also holds its previous trim and dressing as stale data, flagged for the artist (rule 13) | A room is created, or an Approved or Dressed room's fingerprint or config hash no longer matches, or a re-run layout check fails after a tuning change | Its layout checks pass: a room already `play_reviewed` is Approved at once; a new room also needs the play review (rule 10) |
| Approved | The layout is final; the fingerprint and config hash are stored | Checks pass (and, for a new room, the review signs off) | `dressed` is set with the trim baked and no flag open (to Dressed); or the fingerprint or config hash no longer matches, or a re-run layout check fails (to Block-out) |
| Dressed | Trim baked, dressing placed and signed off (`dressed` set, rule 12), overhang check passed, no flag open | `dressed` is set while the room is Approved, its trim is baked and no flag is open; or a room re-approved after an edit still holds `dressed` (rule 13) | The fingerprint or config hash no longer matches, or a re-run layout check fails (to Block-out); a re-bake that raises a flag clears `dressed` (to Approved). A re-bake with no flag stays Dressed |

Only these transitions exist. The bake runs in any state (rule 11 says when); the state changes only through the transitions above. A **build** is an exported or packed game. Playing a room from the editor is not a build and accepts a room in any state, so a block-out is played, and gets its first play review, in the editor (rule 10). No build ships a Block-out room, and a release build ships only Dressed rooms: the build refuses any other and names it. Dev and playtest builds accept Approved rooms too, so a reviewed block-out can be playtested before it is dressed. **[Owner, 2026-11-19, first design review]**

### Interactions with Other Systems

Only level design and ability gating have GDDs; the other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Level design | Both | Out: the grid, tile kinds, face segments and materials, the block-out to dressed path, the overhang check (rules 2-13). In: room layouts, the gate marks on every face its gates measure (rule 6), gate placements whose figures snap to the grid (rule 16) | Level design owns where things go; terrain owns what they are built from |
| Ability gating | Both | Out: `no_cling` segments, the grooves, the pane's look painted from its object data, collision edges at gates. In: the gate windows whose on-grid values this GDD lists (Formulas), `pane_thickness` (12 px, on grid) | Ability gating owns what a gate is |
| Player controller | Out | The collision the Seeker moves on, one-way tiles, and the material of the face segment it touches (the `no_cling` skip, ability gating rule 14) | Terrain owns the data; the controller owns the reaction |
| Enemies | Out | Collision, one-way tiles counted as floor (`_floor_ahead`) | Enemies |
| Rooms and transitions | Both | Out: the tile grid inside each room's bounds (a whole number of 80 x 45-tile screens). In: room bounds and the exits; outside its bounds a room is solid except at exits | Rooms and transitions |
| Parallax, lighting and atmosphere | Out | Which layer is the play layer and its draw order (0 in the art packs); the rule that other layers never imitate it (rule 5) | Parallax, lighting and atmosphere |
| Art bible (not a system) | In | Each material's look (`no_cling`, grooves, the bisque pane), and the painted art's scale and filtering at 4x | Art bible |
| Objects on the grid (doors, breakables, panes, hazards, kill planes, `climbable`, gate anchors) | Out | Grid snap for their collision edges (rule 4) | Each object's own system |

## Formulas

`systems-designer` lens applied in this session (lean mode spawns no agent): every formula was run at its variables' minimum, maximum and 0. The gate windows themselves are ability gating's (F1-F11) and level design's (F7); this section only says which of their values the grid allows. No memory budget is checked here: the project's memory ceiling is `[TO BE CONFIGURED]` (Open Questions).

### T1. On-grid figure

The on_grid formula is defined as:

`on_grid(lo, hi) = { k x collision_tile : ceil(lo / collision_tile) <= k <= floor(hi / collision_tile) }`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| collision_tile | int (px) | 1, 2, 3 or 6; is 6 | constant (project setting) | Side of a black collision tile (rule 2). It must divide 30 (so a 480 x 270 screen is whole tiles) and the art cell (36 px in the art-style test room); 6 is the largest value that does both |
| lo, hi | float (px) | per window | calculated (ability gating F1-F11, level design F7) | The exact bounds of a gate window, read from its owner, never copied |
| k | int (tiles) | 1 or more | calculated | A gate figure in whole tiles |

**Output Range:** a set of whole-tile figures. The narrowest window, the F1 dash gap (17 px wide at margin 8), holds 3 values at margin 8 (150, 156 and 162, which lies exactly on `gap_max` and is left unused until measured, Open Question 3), still 2 at `gap_margin` 12 (149 to 158: 150, 156), the top of its range, and 4 at margin 4 (141 to 166). An empty set means that gate type cannot be built at the current tuning: the layout check fails loudly ("gate type unbuildable"); it never passes a room with no gates of that type.

**Example:** the values the grid allows today, from the owners' current figures:

| Window (owner) | Exact | On the 6 px grid |
|---|---|---|
| Dash gap width (ability gating F1, margin 8) | 145 to 162 | 150, 156; 162 lies exactly on `gap_max`, with no slack, and the sim's `dash_jump_distance` 164.4 (ability gating rounds to 165) puts `gap_max` at 161.4, so 162 is not used until it is measured (Open Questions) |
| Double-jump ledge top (F2) | 72 to 106 | 72, 78, 84, 90, 96, 102 |
| Plain slab underside under an F2 ledge (`head_clear`) | 88 or more | 90 or more |
| Safe pit floor below the far lip (F1, `pit_depth_min`) | 72 or more | 72 or more |
| Hazard floor below both lips (level design F7, `hazard_pit_depth_min`) | 84 or more | 84 or more |
| Grapple ledge top, `no_cling` faces (F3a, margin 6) | 126 or more | 126 or more |
| Plain slab underside under a grapple ledge (F3a) | 143 or more | 144 or more |
| Grapple gap width (F3b) | 420 or more | 420 or more |
| Plain far face below a grapple gap's far lip (F3b, `far_face_max`) | 16 or less | 12 or less |
| Cling or climb wall height (F6) | 72 or more | 72 or more |
| Bisque pane thickness (F10) | 8 to 16 | 12 |

**Edge:** `collision_tile` = 0 is a division by zero and is not allowed. A tile wider than a window can leave it empty (T1 Output Range). A window with `lo > hi` is ability gating's tuning error, reported as unbuildable.

### T2. (Withdrawn at the first design review, 2026-11-19)

A band-rounding formula was drafted here and removed. Every collision edge lies on a grid line (rule 2), so a distance measured between edges is a whole number of tiles, and `distance >= band` gives the same answer for the raw band and for the band rounded up to a tile. For a distance measured to something off the grid, such as an enemy's hit-area edge (`pogo_far_ext`), rounding would tighten a band that level design owns, which is not this system's call. Level design's bands (`pogo_clearance_px` 250, `pogo_clearance_f3a_px` 320, `pogo_far_ext` 14) are used as written, and the `band_on_grid` registry entry is deprecated. T3 and T4 keep their numbers so existing references hold. **[Owner, 2026-11-19]**

### T3. Trim overhang

The trim_overhang formula is defined as:

`overhang(segment) = max over the segment of the distance, along the face's outward normal, from the collision line to the farthest play-layer pixel with alpha >= alpha_solid`

A segment passes when `overhang <= trim_overhang_max` on every segment whose `gate` mark is not `none` (rule 6) and every `no_cling` segment (rule 11, level design rule 25); elsewhere it is not bounded.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| alpha_solid | float | 0.25-0.75, starts at 0.5 | data file | The opacity at which a painted pixel counts as reading solid **[Rec]** |
| trim_overhang_max | float (px) | 2-6, starts at 4 | data file (level design rule 25) | How far art may cover the collision edge at gates; owned by level design |
| art_scale | float (px per source px) | about 0.07 | calculated | `art_cell / source_cell` = 36 / 512 in the art-style test room; set by the art bible (Open Questions) |
| painted pixels | image | n/a | the baked trim plus the dressing, at game scale | What the check measures; background and foreground layers are excluded |

**Output Range:** 0 px (the art stops at the line) upward. At `alpha_solid` 0 every faint glow pixel counts and every gate fails; at 1 only fully opaque pixels count and antialiased rock slips past. Hence the range 0.25-0.75. At `trim_overhang_max` 0 the art is clipped exactly at gate edges.

**Example:** a rock nub 40 source px proud of the painted line overhangs 40 x 0.07 = 2.8 px and passes at a gate; a glow halo at alpha 0.3 reaching 90 source px (6.3 px) does not count; a hanging root prop at alpha 0.9 reaching 6 px past a dash gap's lip fails and is flagged (rule 13).

### T4. Collision cost

The collision_cost formula is defined as:

`collision_shapes(room) <= edge_tiles(room)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| collision_shapes | int | 0 or more | calculated (the built room) | Collision shapes the built room holds for its terrain |
| edge_tiles | int | 0 or more | calculated (room data) | Solid or one-way tiles with at least one empty neighbour above, below, left or right |

**Output Range:** 0 up to `edge_tiles`; interior tiles add nothing (rule 15). An all-empty or all-solid room gives 0, which is legal here (an all-empty room is a rooms-and-transitions problem).

**Example:** a one-screen room (80 x 45 tiles) with a 6-tile floor, walls and ceiling has 1,356 solid tiles around a 68 x 33 open space: 202 edge tiles (2 x (68 + 33)) and 1,154 interior ones. One shape per tile would be 1,356; T4 allows at most 202.

**Feedback loops:** none. The grid narrows choices; nothing in this system grows with play.

## Edge Cases

`systems-designer` not consulted: Lean mode. Review manually before production.

- **If a gate window holds no on-grid value** (T1, after a tuning change narrows it): the layout check fails with "gate type unbuildable" for every room that holds that gate type, and those rooms return to Block-out. The window is retuned by its owner (ability gating); the grid is not changed to fit one window.
- **If a file a check reads changes** (`player_config.tres`, `attack_data.tres`, an enemy `.tres`, or the data file that will hold ability gating's margins and level design's bands, Open Question 10): every gate and placement check re-runs on every Approved and Dressed room, because the windows and bands they read have moved; a room that now fails returns to Block-out (States table). A room's own fingerprint is unchanged, so this re-run is triggered by the config change, not by the room: the room-check step compares the stored config hash (rule 10) on every build and on demand in the editor, and re-runs a room's checks whenever it differs.
- **If the collision, a face material, a gate mark or an object a check reads is edited in an Approved or Dressed room**: the room returns to Block-out (rule 13) and its checks re-run at once; a pass re-approves it with no further play review. The trim re-bakes from the new collision in any state, and dressing that now overlaps solid tiles, floats over empty ones or covers a gate edge past `trim_overhang_max` is listed for the artist, the stale dressing left where it was. Nothing is moved automatically. With no flag, the `dressed` sign-off survives; with any flag, it is cleared (rule 13).
- **If a `no_cling` segment carries a `cling_wall` or `climb_wall` mark, or lies behind a `climbable` marker**: the room check rejects it (rule 7). No wall shows both the `no_cling` look and the grooves.
- **If a floor steps up by one tile (6 px)**: the Seeker's run stops at it and the step needs a hop. The controller has no step-up on the ground (`_nudge_onto_ledge` runs only in the air, and lifts at most `ledge_nudge`, 5 px, less than a tile). A route meant to be run is level or steps by 2 tiles or more, so a step reads as deliberate. A one-tile step is legal and is not flagged.
- **If a single solid tile juts out of a cling wall** (a 6 px nub): it is a standing spot (the Seeker's 10 px feet rest on any support), so the wall is no longer a cling wall (ability gating F6a) and the gate check rejects it.
- **If a route passes through a space too small for the Seeker** (10 x 22 standing, 14 high crouched): a route (the walkable way between two exits, or from a gate's near side to its far side) is at least 2 tiles (12 px) wide and 4 tiles (24 px) high, and the room check flags a narrower or lower one. A 3-tile-high space that forces a crouch is not a legal route: no crawl space is specified, and level design decides whether the game has any. **[Rec]**
- **If a one-way tile lies on a gate's measured surfaces or inside a gate volume** (a ledge top, a lip, a face, level design F7's volume): the layout check rejects it. The gate formulas model only solid tiles: a one-way ledge has no underside face and lets the Seeker rise through it, which no formula accounts for. **[Rec]**
- **If two solid tiles meet only at a corner**: movement treats the corner as closed (the Seeker never squeezes through a 0 px diagonal), and the bake paints both faces and the inner corner.
- **If the Seeker slides along a long floor, wall or ceiling made of many tiles**: it never catches, stops or bumps on a seam between tiles; the built collision has no seams along a straight face (rule 15, Acceptance Criteria).
- **If a face is shorter than the biome's edge art** (a one-tile nub, a 2-tile step): the bake still trims it, cropping the edge art at the grid line, and the overhang check (T3) governs it at gates. No face is left untrimmed.
- **If a wall one tile thick needs different materials on its two sides**: allowed (rule 6). The data holds each side's segment separately.
- **If a face changes material partway along** (plain below, `no_cling` above): allowed at a grid line; each part is its own segment, painted with its own look, and the controller reads the segment it touches (ability gating Edge Cases).
- **If an object (door, pane, breakable, hazard, kill plane, `climbable`, gate anchor) is placed off the grid, or overlaps solid tiles**: the room check flags it; it is never snapped or moved silently. A pane must also measure 12 px (T1 table).
- **If a play-layer prop that reads as solid** (the packs' platforms, wall pieces, terrain blocks, overhangs) **has no solid tiles under its walkable line**: the room check flags it (rule 5). Each prop in a biome's catalogue is marked "reads solid" or "decoration" once, when the pack is imported; decoration never needs tiles.
- **If a room's bounds are not a whole number of screens**: the build refuses it (80 x 45 tiles per screen); rooms and transitions owns the room bounds.
- **If a room sits at a region border**: it uses one biome (rule 14); the next biome loads at the exit, where its first load (0.75-1.07 s measured, level design Open Question 22) needs a longer fade or a background load. Owned by rooms and transitions.

## Dependencies

The systems index places this system in the Foundation layer with no upstream system. It reads two GDDs for definitions only: what a gate window is and what `no_cling` does. Nothing in it waits on them to work.

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Ability gating | Soft (definitions) | The gate windows T1 lists (F1-F3, F6, F10) and the meaning of `no_cling` (rule 14) and the grooves (rule 11). A retune changes the on-grid table, not this system's rules | Yes, Approved (`design/gdd/ability-gating.md`) |
| Level design | Soft (definitions) | `trim_overhang_max` and rule 25, the F7 bands (used as written), the grey-box gate (rule 3), and the gate marks it authors (rule 6) | Yes, Approved (`design/gdd/level-design.md`) |
| Art bible (not a system) | Soft | The look of each material and signature, and the painted art's scale and filtering (`art_cell`, T3) | No (`/art-bible` not run) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Rooms and transitions | Hard | The tile grid inside a room's bounds, whole screens of 80 x 45 tiles, solid outside the bounds except at exits |
| Level design and world layout | Hard | The grid, tile kinds, face materials, the block-out to dressed path and the overhang check; on-grid gate figures (rule 16, T1) |
| Ability gating | Hard | `no_cling` segments, the grooves, the bisque pane's look (painted from the object's data), and collision edges at gates measured on data |
| Player controller | Hard | The collision it moves on, one-way tiles, and the face material at a wall contact |
| Enemies | Hard | Collision and one-way tiles as floor (`_floor_ahead`) |
| Parallax, lighting and atmosphere | Hard | The play layer and its draw order, and rule 5 (other layers never imitate it) |
| Objects on the grid (doors, shortcuts, breakables, panes, hazards, kill planes, `climbable`, gate anchors) | Soft | The grid their collision edges snap to (rule 4) |

**Bidirectional check:**

- Level design lists this system as a hard upstream dependency (Dependencies, Terrain pipeline row), and so does ability gating (Dependencies). Both match.
- The systems index lists Rooms and transitions, Level design and Parallax as depending on this system. Its Ability gating row says that system supplies terrain its `no_cling` and pane materials. That is the definitions half of the "Both" row in Interactions.
- Player controller and Enemies have no GDD yet. Each needs a matching entry when it is designed.
- Level design's rule 11, its workshop criterion and its Open Question 17 were reworded in this GDD's first design review (2026-11-19) to "the narrowest on-grid width in the F1 window" (rule 16) and to units in game px (rule 1).
- Second design review (2026-11-19): level design's Interactions, Dependencies and Cross-References rows now say that it authors a `gate` mark on every face segment its gates measure (rule 6) and that this GDD exists. Ability gating's rows now say that its F1-F11 checks fail a room whose measured segment lacks its mark, and that the bisque pane is an object with plain faces, not a face material.

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The art bible (not yet written) owns every look named here; this section lists what the pipeline must be able to produce.

- **Black masses.** Solid interiors are flat black, so an approved block-out keeps its shape and silhouette when it is painted (level design rule 3 and Visual/Audio, Terrain look).
- **Trim on every face.** Each exposed face carries the biome's rock or moss edge art, baked from the collision (rule 11). Play-layer collision edges are the brightest values in a room and the room reads in greyscale (level design, Readability).
- **Signatures.** The `no_cling` material, the wall-cling grooves (copper-green) and the bisque pane each have one look that nothing else in the world uses (ability gating rules 11, 14, 15). The bake paints them from face and object data (the pane is an object), never by hand.
- **Draw order.** Distant background, midground, then the play layer (black fill, trim, dressing), then foreground, as in the biome packs (`assets/environment/PACK-README.md`: camera factors 0.15, 0.50, 1.00, and 1.20 for the foreground). The parallax system owns every layer but the play layer.
- **Filtering.** The Seeker keeps nearest filtering at 4x; painted terrain uses smooth, mipmapped filtering, as in the art-style test room. The scale of painted terrain against the grid (`art_cell`) waits on the art bible (Open Questions).
- **Audio.** Terrain plays no sound of its own. **[Rec]** Each biome names a surface type per face material, so the audio system can pick footstep, landing and wall-slide sounds (Vertical Slice).

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:terrain-pipeline` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

These are design targets, not acceptance criteria; the player-side ones are checked by the seam criterion.

- **Ground you can trust.** The Seeker never catches on a seam, never stands on air, and never bumps into art that has no collision. A player learns the world's edges once and they hold.
- **Block-out speed.** A room's block-out is quick enough to iterate on by playing. **[Sourced]** Team Cherry: "a world was two days to do the tiles, based on the sketches, and then another four days to do the art pass". **[Rec]** Targets: from saving a tile edit to playing the room within about 5 s; a 10-screen room bakes its trim within about 2 s.
- **Small fixes stay small.** Moving a platform "down one tile" (Team Cherry) costs a tile edit and a re-bake, never a repaint and never a new play review (rule 13).

## UI Requirements

None player-facing: the player never sees the pipeline. The editor needs a collision overlay that shows tiles, face materials, objects and every flag raised by the room check; that is a tools story, not a UX spec.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| Gate windows F1, F2, F3a, F3b, F6, F10 (`gap_min`, `gap_max`, `ledge_min`, `ledge_max`, `head_clear`, `pit_depth_min`, `far_face_max`, `pane_thickness`) | Ability gating | `design/gdd/ability-gating.md`, Approved |
| `no_cling` (rule 14), the grooves (rule 11), the bisque pane (rules 15-17) | Ability gating | Approved; controller `no_cling` skip not built |
| `trim_overhang_max` and rule 25, grey-box first (rule 3), dash workshop (rule 11) | Level design | `design/gdd/level-design.md`, Approved; rule 11 and its criterion reworded 2026-11-19 (rule 16 here) |
| `hazard_pit_depth_min`, `pogo_clearance_px`, `pogo_clearance_f3a_px`, `pogo_far_ext`, gate volumes (F7) | Level design | Approved; registered in `design/registry/entities.yaml` |
| Texture memory per biome (about 97 MB), biome first load 0.75-1.07 s, node growth (level design Open Question 22) | Level design / rooms and transitions | Measured 2026-11-19 in the container (no GPU) |
| `hitbox_size` 10 x 22, `ledge_nudge` 5, `_nudge_onto_ledge` in the air only | Player controller | `player_config.tres`, `player.gd`; no GDD |
| `_floor_ahead` | Enemies | `enemy_base.gd`; no GDD |
| Frame budget 16.6 ms, 500 draw calls; memory ceiling not set | Project | `.claude/docs/technical-preferences.md` |
| Biome pack format (7 x 7 cells of 512 px, props, parallax layers) | Art assets | `assets/environment/PACK-README.md` |

## Acceptance Criteria

Types: **[Auto]** automated test on room data, the built room or the engine; **[Shot]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest or hardware record. `qa-lead` lens applied in this session (lean mode spawns no agent).

**Units and grid**
- **GIVEN** any room, **WHEN** it is shown in play, **THEN** the window renders at 1920 x 1080 with the camera at zoom 4, so 480 x 270 game px fill the screen, and the Seeker's collision box measures 10 x 22 game px. **[Auto]** (rule 1; needs Open Question 9)
- **GIVEN** every room's data, **WHEN** it is checked, **THEN** the room's width and height are whole multiples of 80 and 45 tiles, and every collision edge and every object's collision edge lies on a multiple of 6 px from the room's top-left corner; an object 1 px off the grid is flagged and left where it was. **[Auto]** (rules 2, 4)
- **GIVEN** a room's data, **WHEN** it is checked, **THEN** every tile is empty, solid or one-way, and every collision face is horizontal or vertical. **[Auto]** (rule 3)
- **GIVEN** a one-way tile 2 tiles above a floor, **WHEN** the Seeker jumps up into it from below and later stands on it, **THEN** it passes up through without stopping and then lands and stands on its top edge. Enemies walk on it as floor, and its sides and underside carry no material or gate mark. **[Auto]** (rules 3, 6)

**Static terrain and what looks solid**
- **GIVEN** a room with a door, a pane and a breakable wall, **WHEN** all three are opened or broken in play, **THEN** the room's tile data hashes the same as at load. **[Auto]** (rule 4)
- **GIVEN** a Dressed room, **WHEN** the room check runs, **THEN** every play-layer prop marked "reads solid" has solid tiles under its walkable line (to within `trim_overhang_max`), every exposed face has trim, and no dressing node carries collision. **[Auto]** Each Dressed room gets a screenshot with the collision overlay on. **[Shot]** (rules 5, 12)

**Faces and materials**
- **GIVEN** the wall cling owned and a wall one tile thick, `no_cling` on its left side and plain on its right, **WHEN** the Seeker presses into each side in the air, **THEN** it slides and wall-jumps on the right side and falls past the left side. **[Auto]** (rule 6; needs the controller's `no_cling` skip, ability gating Open Question 2)
- **GIVEN** a `no_cling` segment that carries a `cling_wall` mark, one that carries a `climb_wall` mark, and one that lies behind a `climbable` marker, **WHEN** the room check runs, **THEN** each of the three is rejected. **GIVEN** a gate placement of any type, **WHEN** the room check runs, **THEN** every face segment its formula measures carries that placement's `gate` mark, and a missing mark fails the room and names the placement. **[Auto]** (rules 6, 7)
- **GIVEN** a Dressed room, **WHEN** it is captured, **THEN** each `no_cling` segment shows its material over its whole length, each `cling_wall` segment and `climbable` shows the grooves, and each bisque pane shows its look over its footprint. **[Shot]** (rule 7)
- **GIVEN** an Approved room, **WHEN** the layout checks run once with its trim and dressing and once with both removed, **THEN** the results are identical. **[Auto]** (rule 8)

**Block-out to dressed**
- **GIVEN** a room of black tiles only (no trim, no dressing), **WHEN** it is loaded in play, **THEN** it loads with no errors and the Seeker spawns standing. **[Auto]** (rule 9)
- **GIVEN** an Approved room, **WHEN** one tile, one face material, one gate mark, one exit, or the position of a spike, a `hittable` target, a gate anchor, a pane or an enemy spawn point is changed by one tile, **THEN** its stored fingerprint no longer matches, the room is in Block-out and its checks re-run at once; a room with `play_reviewed` that passes is Approved again, and a new room stays in Block-out until the review. **GIVEN** a room in Block-out, **WHEN** any build is made, **THEN** the build refuses it and names the room. **GIVEN** a room that is Approved but not Dressed, **WHEN** a release build is made, **THEN** it is refused and named, and a dev build accepts it. **GIVEN** an Approved room with its trim baked, no dressing, no flag open and `dressed` unset, **WHEN** its state is read, **THEN** it is Approved, not Dressed; **WHEN** the artist sets `dressed`, **THEN** it is Dressed. **GIVEN** a room in Block-out with no `play_reviewed`, **WHEN** it is played from the editor, **THEN** it loads and plays. **[Auto]** (rules 10, 12, 13, States)
- **GIVEN** a room open in the editor, **WHEN** one tile is changed and the room is saved, **THEN** its trim is re-baked from the new collision before the room is next played. **GIVEN** a room whose fingerprint changed since its last bake, **WHEN** any build is made, **THEN** the build re-bakes it first; a room whose fingerprint and biome did not change is not re-baked. **[Auto]** (rule 11)
- **GIVEN** the same collision and biome, **WHEN** the trim is baked twice, **THEN** both bakes are identical (same hash). **GIVEN** a face one tile long, **WHEN** it is baked, **THEN** it has trim. **[Auto]** (rule 11, Edge Cases)
- **GIVEN** a Dressed room with `play_reviewed`, **WHEN** a platform's collision moves down one tile, **THEN** the room is in Block-out, its checks run at once and pass, and it is Approved again with no play review; the bake moves the platform's trim with it; every dressing prop that now overlaps solid tiles or floats is listed for the artist at its old position, unmoved; `dressed` is cleared; and the room is Dressed again only after that list is cleared and `dressed` is set again. **GIVEN** the same room, **WHEN** instead a tile with no dressing near it moves and the re-bake raises no flag, **THEN** `dressed` survives and the room is Dressed again as soon as it is re-approved. **[Auto]** (rule 13)
- **GIVEN** a room, **WHEN** it is loaded, **THEN** its data names exactly one biome and only that biome's terrain art is loaded for it. **[Auto]** (rule 14)
- **GIVEN** `player_config.tres` is changed, and separately a file that only one check declares it reads, **WHEN** the room-check step next runs (every build, and on demand in the editor), **THEN** the stored config hash of every Approved and Dressed room differs, its layout checks re-run, and a room that now fails is in Block-out. **GIVEN** a file that no check declares, **WHEN** it changes, **THEN** no config hash changes. **[Auto]** (rule 10, Edge Cases)

**Formulas**
- **GIVEN** T1 with `collision_tile` 6, **WHEN** it is evaluated, **THEN** `on_grid(145, 161.4)` = {150, 156}, `on_grid(145, 162)` = {150, 156, 162}, `on_grid(149, 158)` = {150, 156}, `on_grid(72, 106)` = {72, 78, 84, 90, 96, 102}, `on_grid(84, 84)` = {84}, and `on_grid(151, 155)` is empty and the layout check reports "gate type unbuildable" for a room holding that gate type. **GIVEN** `collision_tile` 0, **WHEN** the project settings load, **THEN** they are rejected. **[Auto]** unit test (T1)
- **GIVEN** a test face with painted pixels 3 px past the collision line at alpha 1, **WHEN** T3 runs at a gate with `alpha_solid` 0.5 and `trim_overhang_max` 4, **THEN** it passes; at 5 px it fails; 6 px at alpha 0.3 does not count; exactly alpha 0.5 counts. **[Auto]** unit test (T3)
- **GIVEN** a one-screen room with a 6-tile floor, walls and ceiling, **WHEN** it is built, **THEN** `edge_tiles` is 202 and its terrain holds at most 202 collision shapes; an all-empty room holds 0. **[Auto]** (T4, rule 15)

**Cost and feel of the collision**
- **GIVEN** a 10-screen floor, wall and ceiling each made of one straight face, **WHEN** the Seeker moves along each at `run_speed` (140), `dash_speed` (370), `wall_slide_speed` (60), `max_fall_speed` (480) and `fast_fall_speed` (640), each on the faces it applies to (running and dashing along a floor or, in the air, a ceiling; falling and sliding along a wall), **THEN** its position along the face never stops or jumps and its distance from the face never changes by 1 px or more (no seam catches). **[Auto]** (rule 15, Edge Cases)
- **GIVEN** the 3-screen and the 10-screen art-style rooms built by this pipeline, **WHEN** they are compared, **THEN** the 10-screen room's terrain node count (nodes that hold collision or baked trim; dressing, background and foreground layers excluded) is no more than the 3-screen room's, both rooms draw within 500 draw calls, and on the owner's machine both hold 60 fps (16.6 ms) through the bench's camera sweep (`tests/performance/art_room_bench.tscn`, evidence in `production/qa/evidence/art-style-long-room/`). **[Auto]** for the counts; **[Play]** for frame time on real hardware (the container has no GPU) (rule 15)

**Edge cases that could ship broken**
- **GIVEN** a one-way tile on a ledge top, a lip, a gate face or inside a level design F7 gate volume, **WHEN** the room check runs, **THEN** it is rejected. **[Auto]** (Edge Cases)
- **GIVEN** a route that passes through a space under 2 tiles wide or under 4 tiles high, **WHEN** the room check runs, **THEN** it is flagged; **GIVEN** a space 2 tiles wide and 4 tiles high on a route, **WHEN** the Seeker walks through it standing at `run_speed`, **THEN** it passes without catching. **[Auto]** (Edge Cases)
- **GIVEN** two solid tiles meeting only at a corner, **WHEN** the Seeker pushes into the corner from either open side at `run_speed`, `dash_speed` and `fast_fall_speed`, **THEN** it never passes through. **[Auto]** (Edge Cases)

**Cross-system**
- **GIVEN** level design's dash workshop, **WHEN** its gap is measured on the collision, **THEN** it is the narrowest on-grid width in the F1 window (150 px at today's figures). **[Auto]** (rule 16; level design rule 11)

**Gaps found by the QA checks:**
- The `no_cling` criterion cannot pass until the controller has the `no_cling` skip (ability gating Open Question 2).
- The display criterion (rule 1) cannot pass until the display migration is decided and built (Open Question 9).
- The seam and collision-shape criteria test behaviour that rests on engine features this repo's engine reference does not cover (Open Questions). They stay as written and decide the ADR, not the other way round.
- Frame time can only be recorded on the owner's machine.
- Whether a prop "reads solid" is set by hand once per prop at import, so its criterion checks the data, not the art.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **How collision is built (ADR).** Whether rooms are painted in a `TileMapLayer` with a physics layer or as tile data from which merged collision is generated at build time; how a face segment's material is stored per side (rule 6); and how the build meets T4 and the seam criterion. **NOT SOURCEABLE**: `TileMapLayer` physics layers, terrain sets, custom data layers and collision merging in Godot 4.7 are not covered by `docs/engine-reference/godot/`. There is no `core.md`, and `physics.md` and `rendering.md` have no 2D tile content, so no engine claim is made here. It also covers how the baked trim is stored and drawn (a layer, a baked texture or one node per segment), because rule 15's node bound and the node-count criterion depend on it. Owner: technical director via `/architecture-decision`. Target: before the first terrain story; prototype one painted room first (systems index, High-Risk Systems).
2. **Art scale against the grid.** The art-style test room maps a 512 px source cell to 36 game px, which is 144 screen px, a 3.6x downscale. Decide `art_cell`, the filtering for painted terrain, and whether the pixel-art Seeker sits well on it. `collision_tile` must divide whatever `art_cell` becomes (T1). Owner: `/art-bible`. Target: before any room is painted (level design Open Question 17).
3. **The 162 px dash gap.** It lies exactly on `gap_max` at ability gating's rounded `dash_jump_distance` (165), but the sim's 164.4 puts `gap_max` at 161.4. Measure in `movement_test_room`. Until then only 150 and 156 are used. Owner: ability gating Open Question 3.
4. **Memory ceiling.** The project's memory ceiling is `[TO BE CONFIGURED]` (`.claude/docs/technical-preferences.md`), and a loaded biome costs about 97 MB, two at a region border. Set the ceiling, then add a criterion. Owner: technical director. Target: before region 1's grey-box.
5. **Level design and ability gating follow-ups.** Done in the first design review (2026-11-19): level design rule 11, its workshop criterion and its Open Question 17 now say the narrowest on-grid width (rule 16) and game px (rule 1). Done in the second design review (2026-11-19): both GDDs' Dependencies rows now name the gate marks (rule 6), and ability gating's rows now treat the pane as an object. Still open: the existing test rooms (`movement_test_room`, `gate_test_rooms`, the art-style rooms) are built off the 6 px grid in code. They stay test rooms; region rooms use this pipeline.
6. **Prop catalogue.** Each biome prop is marked "reads solid" or "decoration" once at import (Edge Cases). The format belongs with the ADR (question 1). Target: the pack import story.
7. **Starting values to check in a painted room.** `alpha_solid` 0.5 (T3) and the block-out speed targets (Game Feel) are recommendations. Target: the prototype room in question 1.
8. **Surface sounds.** A surface type per face material for footsteps and landings (Visual/Audio). Owner: audio. Target: Vertical Slice.
9. **Display migration to 1920 x 1080.** Rule 1 and the first acceptance criterion need the world drawn at 1920 x 1080 with the camera at zoom 4. `project.godot` still holds a 480 x 270 base with viewport stretch and integer scale (window override 1440 x 810), and only `art_style_test_room.gd` switches to 1920 x 1080 at runtime. Decide the project settings, who owns the camera zoom, and what happens to the existing rooms, the Seeker's nearest filtering and parallax placement (the test room found `Parallax2D` misplaces layers under zoom 4). The brief records the owner's decision (2026-11-18); the how is open. Owner: technical director via `/architecture-decision`, with the camera. Target: before the first terrain story.
10. **Gate-knob data file.** Ability gating's margins (`gap_margin`, `ledge_margin_low`, `ledge_margin_high`, `cling_margin`, `grapple_margin`) and level design's bands are listed as "data file" knobs, but no such file exists in `src/`, `assets/` or `tests/` yet. The config hash (rule 10) covers it once each check declares it. Owner: the first gate-check story.
11. **Open from the second design review (recommended, not blocking).** Trim undershoot: T3 bounds only overhang, so trim that stops short of the collision line is not bounded (rule 5, Game Feel "never stands on air"). The node-count criterion (Cost and feel) compares two particular rooms and depends on the ADR; a fixed per-room ceiling would test rule 15 better. Both need a design choice. Target: the ADR in question 1.
