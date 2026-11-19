# Terrain pipeline

> **Status**: Designed 2026-11-19, pending `/design-review` in a fresh session (CD-GDD-ALIGN skipped: lean mode)
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-19
> **Last Verified**: 2026-11-19
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room")

## Summary

The terrain pipeline is how the ground of every room is made. Rooms are blocked out in 6 px black collision tiles and played at once, as Team Cherry built Hollow Knight. Once approved, a room gets rock trim baked from its collision and hand-placed dressing, and its edges never move to fit the art. It exists so that every gate level design and ability gating place is measured on true collision, every wall carries its material (`plain` or `no_cling`), and large painted rooms stay cheap to build and draw.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None (reads Ability gating and Level design for definitions)`

## Overview

The terrain pipeline decides how the solid ground of a room is made and how it reads: the collision the Seeker runs, jumps, clings to and falls against, the painted look laid over it, and the path from an approved grey-box (collision only) to a finished painted room without moving a single collision edge. The player never operates it. They feel it as ground that is exactly what it looks like (a ledge that reads as reachable with a double jump is one, and a gap that reads as too wide for a run-jump is) and as a world with a painted identity per region. Level design and ability gating measure every gate on the collision this system produces, to the pixel (the dash gap window is about 145-162 px, the double-jump ledge window 72-106 px), so its first job is fidelity: collision is authored precisely, approved on a grey-box, and never moved to suit the art. Its second job is the surface materials the world needs, each with a signature that nothing else uses: plain terrain, `no_cling` faces, `climbable` surfaces and the bisque pane that only a dash breaks. Its third is cost: large rooms of several screens, left by open edges, must build and draw within the memory and node budgets of the painted biome packs. It is the foundation under rooms and transitions and under the parallax and atmosphere layers; without it no room can be built, no gate can be trusted, and the painted art has nowhere to land.

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Sourced]** = from Team Cherry's account of building Hollow Knight (PC Gamer, "How to design a great Metroidvania map", 2017 interview); **[Rec]** = recommendation, change freely; **[Calc]** = computed. Engine-API details are not covered by `docs/engine-reference/godot/` and belong to the ADR (Open Questions).

`systems-designer`, `gameplay-programmer` and `engine-programmer` not consulted: Lean mode. Review manually before production.

**Units and the collision grid**

1. **Units.** Every figure in this and every other GDD is in game px: a screen is 480 x 270, the Seeker 10 x 22. The game draws the world 4x larger, at 1920 x 1080; art is scaled to the game, never the game to the art. **[Owner, 2026-11-19; settles the units half of level design Open Question 17]**
2. **The grid.** Solid terrain is a grid of square black collision tiles, `collision_tile` = 6 px, anchored at the room's top-left corner. A screen is 80 x 45 tiles, so every room bound, collision edge and gate edge lies on a grid line. **[Owner, 2026-11-19]** **[Sourced]** (Hollow Knight: "the whole world is just built from black tiles that are 64x64 pixels. They're very quick to paint in, and from there we can just hit play") Why 6: it divides the screen both ways, it nests 6 x 6 into the painted art's 36 px cell, and it leaves two legal dash gaps inside ability gating's F1 window (150 and 156 px; Formulas). **[Calc]**
3. **Tile kinds.** A tile is empty, solid, or one-way (solid from above only: the Seeker rises through it and lands on it). There are no slopes and no part tiles: every collision face is horizontal or vertical, which is what the gate formulas assume (level lips, plain vertical faces). **[Rec]**
4. **Terrain never changes at runtime.** Anything that opens, breaks, moves, hurts or is climbed is an object placed on the grid and owned by its system: doors and shortcut gates, breakable walls, bisque panes (ability gating F10), hazards and kill planes, `climbable` markers, gate anchors, moving platforms. Their collision edges also lie on grid lines. World state therefore never stores terrain. **[Rec]**
5. **What looks solid is solid.** On the play layer, anything that reads as ground, wall or ledge has solid tiles under it whose edge is its walkable or clingable line, and nothing solid is left unpainted or hidden. Dressing never carries collision. No invisible walls, no painted floors that drop the Seeker through. Background and foreground layers (parallax, lighting and atmosphere) are not the play layer and never imitate it (level design, Visual/Audio: Readability). **[Rec]**

**Faces and materials**

6. **Face segments.** A face is a straight run of collision edge between a solid (or one-way) tile and an empty one, on one side of a mass, from corner to corner. It is split at grid lines into **segments**, and each segment has one material: `plain` (the default) or `no_cling`. Material belongs to the segment, not the mass: a one-tile-thick wall may be `no_cling` on its left and plain on its right, and one wall may turn `no_cling` partway up (ability gating Edge Cases: a slide stops where the plain part ends). **[Owner, 2026-11-19: per face]** What `no_cling` does is ability gating's (rule 14).
7. **Signatures painted from data.** The bake (rule 11) paints each `no_cling` segment with its material over its whole length, and paints the wall-cling grooves on every face segment level design marks as a cling-wall gate and behind every `climbable` marker (ability gating rule 11). A segment never carries both. The look of each comes from the art bible.
8. **Checks read data, never art.** Every layout check (ability gating F1-F11, level design F7 and rules 25-27) reads tiles, face materials and objects from the room data. A gate figure is a whole number of tiles: a 156 px gap is 26 tiles, a 90 px ledge 15. **[Calc]**

**From block-out to dressed room**

9. **Block-out.** A room starts as black tiles only, painted on the grid and played at once: "can you roughly reach every platform, does it make sense". No trim, no props. This is level design rule 3's grey-box. **[Sourced]** (Team Cherry call it "blocking out or tiling out a room")
10. **Approval.** A block-out is approved when its automated layout checks pass and a play review signs it off. Approval stores a fingerprint of the room's collision and face materials, so any later change to either is detected.
11. **Trim bake.** The rock or moss trim on every exposed face is generated from the collision, never drawn by hand: the biome's edge art is placed along each face so that its painted rock line lies on the collision line, and solid interiors stay black. At every gate edge and every `no_cling` segment the trim overhangs the collision by at most `trim_overhang_max` (4 px, level design rule 25); elsewhere the bake follows the art. The same collision and biome always bake the same trim, so moving a platform "down one tile" re-bakes instead of re-painting. **[Owner, 2026-11-19: auto trim]**
12. **Dressing.** Props, ruins, scenery, hanging decoration and play-layer framing are placed by hand over the baked trim. **[Owner, 2026-11-19]** **[Sourced]** (Team Cherry: "Ari will go through and 'dress' the room, put all the scenery and stuff in", before enemies and switches) Dressing obeys rule 5, and at gate edges and `no_cling` segments it may cover the collision edge by no more than `trim_overhang_max`, the same bound as the trim.
13. **A change after approval.** Editing the collision or a face material of an approved room returns it to block-out: the layout checks re-run, the trim re-bakes, and any dressing that now overlaps solid tiles, floats over empty ones, or covers a gate edge past the bound is flagged for the artist, never moved silently. Collision is never moved to fit the art (level design rule 25).
14. **One biome per room.** A room names one biome pack for its trim and dressing and never loads a second biome's terrain art; a loaded biome costs about 97 MB of texture memory (level design Open Question 22). A region border is crossed between rooms, never inside one. **[Rec]**

**Cost**

15. **Collision cost follows the edge, not the area.** Solid interiors add no collision of their own: a 10-screen room's collision grows with the length of its exposed faces, not with its 36,000 tiles. Drawing is batched per layer, never one node per tile (the code-built art-style long room grew to 524 nodes). How this is built is an ADR (Open Questions). **[Rec; level design Open Question 22]**

**Gate figures on the grid (follow-up for level design)**

16. Gate figures are chosen from the on-grid values inside each window (Formulas). The dash workshop's gap (level design rule 11) is the narrowest on-grid width inside the F1 window, 150 px today, instead of "at most `gap_min` + 4 px", which no grid width meets. **[Owner, 2026-11-19; level design rule 11 and its criterion to be reworded]**

### States and Transitions

Terrain has no runtime states (rule 4). Each room's terrain has a **production state**, stored in the room data and read by the build tools, the checks and the grey-box review; it is not world state.

| State | Meaning | Enter when | Leave when |
|-------|---------|-----------|-----------|
| Block-out | Black tiles, face materials and objects only; playable | A room is created, or an approved room's collision or a face material changes (rule 13) | Its layout checks pass and a play review approves it |
| Approved | The layout is final; the fingerprint of collision and materials is stored | Checks pass and the review signs off | The trim is baked and dressing placed (to Dressed); or the fingerprint no longer matches, or a re-run layout check fails after a tuning change (to Block-out) |
| Dressed | Trim baked, dressing placed, overhang check passed | The bake and the dressing pass finish with no flag open | The fingerprint no longer matches, or a re-run layout check fails after a tuning change (to Block-out). A re-bake with the same fingerprint stays Dressed |

Only these transitions exist. A room in Block-out never ships: the build refuses it.

### Interactions with Other Systems

Only level design and ability gating have GDDs; the other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Level design | Both | Out: the grid, tile kinds, face segments and materials, the block-out to dressed path, the overhang check (rules 2-13). In: room layouts, which faces are cling-wall gates, gate placements whose figures snap to the grid (rule 16) | Level design owns where things go; terrain owns what they are built from |
| Ability gating | Both | Out: `no_cling` segments, the bisque pane's material, the grooves, collision edges at gates. In: the gate windows whose on-grid values this GDD lists (Formulas), `pane_thickness` (12 px, on grid) | Ability gating owns what a gate is |
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

**Output Range:** a set of whole-tile figures. The narrowest window, the F1 dash gap (17 px wide at margin 8), holds 2 values at 6 px away from its edges, and still 2 at `gap_margin` 12 (149 to 158: 150, 156), the top of its range; at margin 4 (141 to 166) it holds 4. An empty set means that gate type cannot be built at the current tuning: the layout check fails loudly ("gate type unbuildable"); it never passes a room with no gates of that type.

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

### T2. A band on the grid

The band_on_grid formula is defined as:

`band_on_grid = collision_tile x ceil(band / collision_tile)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| band | float (px) | 0 or more | data file (level design F7) | A clearance a placement check enforces: `pogo_clearance_px`, `pogo_clearance_f3a_px`, `pogo_far_ext` |
| collision_tile | int (px) | 6 | constant | As T1 |

**Output Range:** the band as the grid makes it act. Edges lie on grid lines, so a measured distance is a whole number of tiles, and a distance under the band is the next tile down. Rounding only ever widens a band, so it cannot open a leak. A band of 0 stays 0.

**Example:** `pogo_clearance_px` 250 acts as 252 (a target edge 246 px away is rejected, 252 passes), `pogo_clearance_f3a_px` 320 as 324, and `pogo_far_ext` 14 as 18. These are consequences of the grid, not new values; level design keeps owning the bands.

### T3. Trim overhang

The trim_overhang formula is defined as:

`overhang(segment) = max over the segment of the distance, along the face's outward normal, from the collision line to the farthest play-layer pixel with alpha >= alpha_solid`

A segment passes when `overhang <= trim_overhang_max` at every gate edge and every `no_cling` segment (rule 11, level design rule 25); elsewhere it is not bounded.

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
- **If `player_config.tres`, `attack_data.tres` or an enemy `.tres` changes**: every gate and placement check re-runs on every Approved and Dressed room, because the windows and bands they read have moved; a room that now fails returns to Block-out (States table). A room's own fingerprint is unchanged, so this re-run is triggered by the config change, not by the room.
- **If the collision or a face material of a Dressed room is edited**: the room returns to Block-out (rule 13); the trim re-bakes from the new collision on the next bake, and dressing that now overlaps solid tiles, floats over empty ones or covers a gate edge past `trim_overhang_max` is listed for the artist. Nothing is moved automatically.
- **If a floor steps up by one tile (6 px)**: the Seeker's run stops at it and the step needs a hop. The controller has no step-up on the ground (`_nudge_onto_ledge` runs only in the air, and lifts at most `ledge_nudge`, 5 px, less than a tile). A route meant to be run is level or steps by 2 tiles or more, so a step reads as deliberate. A one-tile step is legal and is not flagged.
- **If a single solid tile juts out of a cling wall** (a 6 px nub): it is a standing spot (the Seeker's 10 px feet rest on any support), so the wall is no longer a cling wall (ability gating F6a) and the gate check rejects it.
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
| Level design | Soft (definitions) | `trim_overhang_max` and rule 25, the bands T2 rounds (F7), the grey-box gate (rule 3), and which faces are cling-wall gates | Yes, Approved (`design/gdd/level-design.md`) |
| Art bible (not a system) | Soft | The look of each material and signature, and the painted art's scale and filtering (`art_cell`, T3) | No (`/art-bible` not run) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Rooms and transitions | Hard | The tile grid inside a room's bounds, whole screens of 80 x 45 tiles, solid outside the bounds except at exits |
| Level design and world layout | Hard | The grid, tile kinds, face materials, the block-out to dressed path and the overhang check; on-grid gate figures (rule 16, T1) |
| Ability gating | Hard | `no_cling` segments, the bisque pane's material, the grooves, and collision edges at gates measured on data |
| Player controller | Hard | The collision it moves on, one-way tiles, and the face material at a wall contact |
| Enemies | Hard | Collision and one-way tiles as floor (`_floor_ahead`) |
| Parallax, lighting and atmosphere | Hard | The play layer and its draw order, and rule 5 (other layers never imitate it) |
| Objects on the grid (doors, shortcuts, breakables, panes, hazards, kill planes, `climbable`, gate anchors) | Soft | The grid their collision edges snap to (rule 4) |

**Bidirectional check:**

- Level design lists this system as a hard upstream dependency (Dependencies, Terrain pipeline row), and so does ability gating (Dependencies). Both match.
- The systems index lists Rooms and transitions, Level design and Parallax as depending on this system. Its Ability gating row says that system supplies terrain its `no_cling` and pane materials. That is the definitions half of the "Both" row in Interactions.
- Player controller and Enemies have no GDD yet. Each needs a matching entry when it is designed.
- Follow-up for level design: rule 11 and its workshop criterion should be reworded to "the narrowest on-grid width in the F1 window" (rule 16). Its Open Question 17 can also record that the units question is settled in game px (rule 1).

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted: Lean mode. Review manually before production. The art bible (not yet written) owns every look named here; this section lists what the pipeline must be able to produce.

- **Black masses.** Solid interiors are flat black, so an approved block-out keeps its shape and silhouette when it is painted (level design rule 3 and Visual/Audio, Terrain look).
- **Trim on every face.** Each exposed face carries the biome's rock or moss edge art, baked from the collision (rule 11). Play-layer collision edges are the brightest values in a room and the room reads in greyscale (level design, Readability).
- **Signatures.** The `no_cling` material, the wall-cling grooves (copper-green) and the bisque pane each have one look that nothing else in the world uses (ability gating rules 11, 14, 15). The bake paints them from face data, never by hand.
- **Draw order.** Distant background, midground, then the play layer (black fill, trim, dressing), then foreground, as in the biome packs (`assets/environment/PACK-README.md`: camera factors 0.15, 0.50, 1.00). The parallax system owns every layer but the play layer.
- **Filtering.** The Seeker keeps nearest filtering at 4x; painted terrain uses smooth, mipmapped filtering, as in the art-style test room. The scale of painted terrain against the grid (`art_cell`) waits on the art bible (Open Questions).
- **Audio.** Terrain plays no sound of its own. **[Rec]** Each biome names a surface type per face material, so the audio system can pick footstep, landing and wall-slide sounds (Vertical Slice).

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:terrain-pipeline` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

These are design targets, not acceptance criteria; the player-side ones are checked by the seam criterion.

- **Ground you can trust.** The Seeker never catches on a seam, never stands on air, and never bumps into art that has no collision. A player learns the world's edges once and they hold.
- **Block-out speed.** A room's block-out is quick enough to iterate on by playing. **[Sourced]** Team Cherry: "a world was two days to do the tiles, based on the sketches, and then another four days to do the art pass". **[Rec]** Targets: from saving a tile edit to playing the room within about 5 s; a 10-screen room bakes its trim within about 2 s.
- **Small fixes stay small.** Moving a platform "down one tile" (Team Cherry) costs a tile edit and a re-bake, never a repaint.

## UI Requirements

None player-facing: the player never sees the pipeline. The editor needs a collision overlay that shows tiles, face materials, objects and every flag raised by the room check; that is a tools story, not a UX spec.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| Gate windows F1, F2, F3a, F3b, F6, F10 (`gap_min`, `gap_max`, `ledge_min`, `ledge_max`, `head_clear`, `pit_depth_min`, `far_face_max`, `pane_thickness`) | Ability gating | `design/gdd/ability-gating.md`, Approved |
| `no_cling` (rule 14), the grooves (rule 11), the bisque pane (rules 15-17) | Ability gating | Approved; controller `no_cling` skip not built |
| `trim_overhang_max` and rule 25, grey-box first (rule 3), dash workshop (rule 11) | Level design | `design/gdd/level-design.md`, Approved; rule 11 rewording pending (rule 16 here) |
| `hazard_pit_depth_min`, `pogo_clearance_px`, `pogo_clearance_f3a_px`, `pogo_far_ext`, gate volumes (F7) | Level design | Approved; registered in `design/registry/entities.yaml` |
| Texture memory per biome (about 97 MB), biome first load 0.75-1.07 s, node growth (level design Open Question 22) | Level design / rooms and transitions | Measured 2026-11-19 in the container (no GPU) |
| `hitbox_size` 10 x 22, `ledge_nudge` 5, `_nudge_onto_ledge` in the air only | Player controller | `player_config.tres`, `player.gd`; no GDD |
| `_floor_ahead` | Enemies | `enemy_base.gd`; no GDD |
| Frame budget 16.6 ms, 500 draw calls; memory ceiling not set | Project | `.claude/docs/technical-preferences.md` |
| Biome pack format (7 x 7 cells of 512 px, props, parallax layers) | Art assets | `assets/environment/PACK-README.md` |

## Acceptance Criteria

Types: **[Auto]** automated test on room data, the built room or the engine; **[Shot]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest or hardware record. `qa-lead` lens applied in this session (lean mode spawns no agent).

**Units and grid**
- **GIVEN** any room, **WHEN** it is shown in play, **THEN** the window renders at 1920 x 1080 with the camera at zoom 4, so 480 x 270 game px fill the screen, and the Seeker's collision box measures 10 x 22 game px. **[Auto]** (rule 1)
- **GIVEN** every room's data, **WHEN** it is checked, **THEN** the room's width and height are whole multiples of 80 and 45 tiles, and every collision edge and every object's collision edge lies on a multiple of 6 px from the room's top-left corner; an object 1 px off the grid is flagged and left where it was. **[Auto]** (rules 2, 4)
- **GIVEN** a room's data, **WHEN** it is checked, **THEN** every tile is empty, solid or one-way, and every collision face is horizontal or vertical. **[Auto]** (rule 3)
- **GIVEN** a one-way tile 2 tiles above a floor, **WHEN** the Seeker jumps up into it from below and later stands on it, **THEN** it passes up through without stopping and then lands and stands on its top edge. Enemies walk on it as floor. **[Auto]** (rule 3)

**Static terrain and what looks solid**
- **GIVEN** a room with a door, a pane and a breakable wall, **WHEN** all three are opened or broken in play, **THEN** the room's tile data hashes the same as at load. **[Auto]** (rule 4)
- **GIVEN** a Dressed room, **WHEN** the room check runs, **THEN** every play-layer prop marked "reads solid" has solid tiles under its walkable line (to within `trim_overhang_max`), every exposed face has trim, and no dressing node carries collision. **[Auto]** Each Dressed room gets a screenshot with the collision overlay on. **[Shot]** (rules 5, 12)

**Faces and materials**
- **GIVEN** the wall cling owned and a wall one tile thick, `no_cling` on its left side and plain on its right, **WHEN** the Seeker presses into each side in the air, **THEN** it slides and wall-jumps on the right side and falls past the left side. **[Auto]** (rule 6; needs the controller's `no_cling` skip, ability gating Open Question 2)
- **GIVEN** a face segment marked both `no_cling` and grooved, **WHEN** the room check runs, **THEN** it is rejected. **GIVEN** a Dressed room, **WHEN** it is captured, **THEN** each `no_cling` segment shows its material over its whole length and each cling-wall gate face and `climbable` shows the grooves. **[Auto + Shot]** (rule 7)
- **GIVEN** an Approved room, **WHEN** the layout checks run once with its trim and dressing and once with both removed, **THEN** the results are identical. **[Auto]** (rule 8)

**Block-out to dressed**
- **GIVEN** a room of black tiles only (no trim, no dressing), **WHEN** it is loaded in play, **THEN** it loads with no errors and the Seeker spawns standing. **[Auto]** (rule 9)
- **GIVEN** an Approved room, **WHEN** one tile or one face material is changed, **THEN** its stored fingerprint no longer matches and the room is in Block-out. **GIVEN** a room in Block-out, **WHEN** a build is made, **THEN** the build refuses it and names the room. **[Auto]** (rules 10, 13, States)
- **GIVEN** the same collision and biome, **WHEN** the trim is baked twice, **THEN** both bakes are identical (same hash). **GIVEN** a face one tile long, **WHEN** it is baked, **THEN** it has trim. **[Auto]** (rule 11, Edge Cases)
- **GIVEN** a Dressed room, **WHEN** a platform's collision moves down one tile, **THEN** the room returns to Block-out, the next bake moves the platform's trim with it, and every dressing prop that now overlaps solid tiles or floats is listed for the artist at its old position, unmoved. **[Auto]** (rule 13)
- **GIVEN** a room, **WHEN** it is loaded, **THEN** its data names exactly one biome and only that biome's terrain art is loaded for it. **[Auto]** (rule 14)
- **GIVEN** `player_config.tres` is changed, **WHEN** the change is saved, **THEN** every Approved and Dressed room's layout checks re-run, and a room that now fails is in Block-out. **[Auto]** (Edge Cases)

**Formulas**
- **GIVEN** T1 with `collision_tile` 6, **WHEN** it is evaluated, **THEN** `on_grid(145, 161.4)` = {150, 156}, `on_grid(149, 158)` = {150, 156}, `on_grid(72, 106)` = {72, 78, 84, 90, 96, 102}, `on_grid(84, 84)` = {84}, and `on_grid(151, 155)` is empty and the layout check reports "gate type unbuildable" for a room holding that gate type. **GIVEN** `collision_tile` 0, **WHEN** the project settings load, **THEN** they are rejected. **[Auto]** unit test (T1)
- **GIVEN** T2, **WHEN** it is evaluated, **THEN** `band_on_grid` gives 252 for 250, 324 for 320, 18 for 14, 252 for 252 and 0 for 0; and a target edge 246 px from a double-jump ledge's column is rejected while one 252 px away passes. **[Auto]** unit test (T2)
- **GIVEN** a test face with painted pixels 3 px past the collision line at alpha 1, **WHEN** T3 runs at a gate with `alpha_solid` 0.5 and `trim_overhang_max` 4, **THEN** it passes; at 5 px it fails; 6 px at alpha 0.3 does not count; exactly alpha 0.5 counts. **[Auto]** unit test (T3)
- **GIVEN** a one-screen room with a 6-tile floor, walls and ceiling, **WHEN** it is built, **THEN** `edge_tiles` is 202 and its terrain holds at most 202 collision shapes; an all-empty room holds 0. **[Auto]** (T4, rule 15)

**Cost and feel of the collision**
- **GIVEN** a 10-screen floor, wall and ceiling each made of one straight face, **WHEN** the Seeker runs, dashes and slides along each at every speed it can reach, **THEN** its position along the face never stops or jumps and its distance from the face never changes by 1 px or more (no seam catches). **[Auto]** (rule 15, Edge Cases)
- **GIVEN** the 3-screen and the 10-screen art-style rooms built by this pipeline, **WHEN** they are compared, **THEN** their terrain node counts are equal, both rooms draw within 500 draw calls, and on the owner's machine both hold 60 fps (16.6 ms) through a full camera sweep. **[Auto]** for the counts; **[Play]** for frame time on real hardware (the container has no GPU) (rule 15)

**Edge cases that could ship broken**
- **GIVEN** a one-way tile on a ledge top, a lip, a gate face or inside a level design F7 gate volume, **WHEN** the room check runs, **THEN** it is rejected. **[Auto]** (Edge Cases)
- **GIVEN** two solid tiles meeting only at a corner, **WHEN** the Seeker pushes into the corner from either open side, at every speed it can reach, **THEN** it never passes through. **[Auto]** (Edge Cases)

**Cross-system**
- **GIVEN** level design's dash workshop, **WHEN** its gap is measured on the collision, **THEN** it is the narrowest on-grid width in the F1 window (150 px at today's figures). **[Auto]** (rule 16; level design rule 11)

**Gaps found by the QA checks:**
- The `no_cling` criterion cannot pass until the controller has the `no_cling` skip (ability gating Open Question 2).
- The seam and collision-shape criteria test behaviour that rests on engine features this repo's engine reference does not cover (Open Questions). They stay as written and decide the ADR, not the other way round.
- Frame time can only be recorded on the owner's machine.
- Whether a prop "reads solid" is set by hand once per prop at import, so its criterion checks the data, not the art.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **How collision is built (ADR).** Whether rooms are painted in a `TileMapLayer` with a physics layer or as tile data from which merged collision is generated at build time; how a face segment's material is stored per side (rule 6); and how the build meets T4 and the seam criterion. **NOT SOURCEABLE**: `TileMapLayer` physics layers, terrain sets, custom data layers and collision merging in Godot 4.7 are not covered by `docs/engine-reference/godot/`. There is no `core.md`, and `physics.md` and `rendering.md` have no 2D tile content, so no engine claim is made here. Owner: technical director via `/architecture-decision`. Target: before the first terrain story; prototype one painted room first (systems index, High-Risk Systems).
2. **Art scale against the grid.** The art-style test room maps a 512 px source cell to 36 game px, which is 144 screen px, a 3.6x downscale. Decide `art_cell`, the filtering for painted terrain, and whether the pixel-art Seeker sits well on it. `collision_tile` must divide whatever `art_cell` becomes (T1). Owner: `/art-bible`. Target: before any room is painted (level design Open Question 17).
3. **The 162 px dash gap.** It lies exactly on `gap_max` at ability gating's rounded `dash_jump_distance` (165), but the sim's 164.4 puts `gap_max` at 161.4. Measure in `movement_test_room`. Until then only 150 and 156 are used. Owner: ability gating Open Question 3.
4. **Memory ceiling.** The project's memory ceiling is `[TO BE CONFIGURED]` (`.claude/docs/technical-preferences.md`), and a loaded biome costs about 97 MB, two at a region border. Set the ceiling, then add a criterion. Owner: technical director. Target: before region 1's grey-box.
5. **Level design follow-ups.** Reword rule 11 and its workshop criterion to "the narrowest on-grid width in the F1 window" (rule 16), and record in its Open Question 17 that units are game px (rule 1). The existing test rooms (`movement_test_room`, `gate_test_rooms`, the art-style rooms) are built off the 6 px grid in code. They stay test rooms; region rooms use this pipeline. Target: the next level design revision.
6. **Prop catalogue.** Each biome prop is marked "reads solid" or "decoration" once at import (Edge Cases). The format belongs with the ADR (question 1). Target: the pack import story.
7. **Starting values to check in a painted room.** `alpha_solid` 0.5 (T3) and the block-out speed targets (Game Feel) are recommendations. Target: the prototype room in question 1.
8. **Surface sounds.** A surface type per face material for footsteps and landings (Visual/Audio). Owner: audio. Target: Vertical Slice.
