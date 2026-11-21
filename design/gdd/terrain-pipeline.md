# Terrain pipeline

> **Status**: Restructured 2026-11-19 after the sixth `/design-review` (full: MAJOR REVISION NEEDED, 6 blockers addressed). Player-facing rules, bounds and guarantees stay here; how the checks, bake, flags and fingerprints are built moved to `docs/architecture/terrain-tools-spec.md` and the collision ADR (Open Question 1). **Frozen** until the prototype room (Open Question 1) has run its fixtures; awaiting re-review after that
> **Author**: project owner + Claude
> **Last Updated**: 2026-11-19
> **Last Verified**: 2026-11-19
> **Implements Pillar**: none defined (brief: "one move set feels good in a fight and in a room")

## Summary

The terrain pipeline is how the ground of every room is made. Rooms are blocked out in 6 px black collision tiles and played at once, as Team Cherry built Hollow Knight. Once approved, a room gets rock trim baked from its collision and hand-placed dressing, and its edges never move to fit the art. It exists so that every gate level design and ability gating place is measured on true collision, every wall carries its material (`plain` or `no_cling`), and large painted rooms stay cheap to build and draw.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None (reads Ability gating and Level design for definitions)`

## Overview

The terrain pipeline decides how the solid ground of a room is made and how it reads: the collision the Seeker runs, jumps, clings to and falls against, the painted look laid over it, and the path from an approved grey-box (collision only) to a finished painted room without moving a single collision edge. The player never operates it. They feel it as ground that is exactly what it looks like (a ledge that reads as reachable with a double jump is one, and a gap that reads as too wide for a run-jump is) and as a world with a painted identity per region. Level design and ability gating measure every gate on the collision this system produces, to the pixel (the dash gap window is about 145-162 px, the double-jump ledge window 72-106 px), so its first job is fidelity: collision is authored precisely, approved on a grey-box, and never moved to suit the art. Its second job is the face materials the world needs and the signatures nothing else uses: `plain` and `no_cling` faces, the wall-cling grooves on cling-wall faces and `climbable` surfaces, and the bisque pane that only a dash breaks (an object on the grid, not a face material). Its third is cost: large rooms of several screens, left by open edges, must build and draw within the memory and node budgets of the painted biome packs. It is the foundation under rooms and transitions and under the parallax and atmosphere layers; without it no room can be built, no gate can be trusted, and the painted art has nowhere to land.

**What this document holds.** The rules, bounds and guarantees a designer, artist or player can observe. How the tools meet them (the room-check command, the save hook, fingerprints and caches, T3's pixel method, T5's matching) is in `docs/architecture/terrain-tools-spec.md`; how collision and trim are built in the engine is the ADR (Open Question 1). Where this document says a check "detects" something, the tools spec says how. **[Owner, 2026-11-19, sixth design review]**

## Detailed Design

### Core Rules

Tags: **[Owner]** = your decision; **[Sourced]** = from Team Cherry's account of building Hollow Knight (PC Gamer, "How to design a great Metroidvania map", 2017 interview); **[Rec]** = recommendation, change freely; **[Calc]** = computed.

**Units and the collision grid**

1. **Units.** Every figure in this and every other GDD is in game px: a screen is 480 x 270, the Seeker 10 x 22. A game px is one world unit at 1x, never a pixel of the 4x draw. The game draws the world 4x larger, at 1920 x 1080; art is scaled to the game, never the game to the art. The project settings still hold the 480 x 270 viewport stretch; the migration is Open Question 9. **[Owner, 2026-11-19; settles the units half of level design Open Question 17]**
2. **The grid.** Solid terrain is a grid of square black collision tiles, `collision_tile` = 6 px, anchored at the room's top-left corner. A screen is 80 x 45 tiles, so every room bound, collision edge and gate edge lies on a grid line. **[Owner, 2026-11-19]** **[Sourced]** (Hollow Knight: "the whole world is just built from black tiles that are 64x64 pixels. They're very quick to paint in, and from there we can just hit play") Why 6: it divides the screen both ways, it nests 6 x 6 into the painted art's 36 px cell, and it leaves two legal dash gaps inside ability gating's F1 window (150 and 156 px; Formulas). **[Calc]**
3. **Tile kinds.** A tile is empty, solid, or one-way (solid from above only: the Seeker rises through it and lands on it). There are no slopes and no part tiles: every collision face is horizontal or vertical, which is what the gate formulas assume. **[Rec]**
4. **Terrain never changes at runtime.** Anything that opens, breaks, moves, hurts or is climbed is an object placed on the grid and owned by its system: doors and shortcut gates, breakable walls, bisque panes (ability gating F10), hazards and kill planes, `climbable` markers, gate anchors, moving platforms. Their collision edges also lie on grid lines, and so does each room exit's opening in the room's solid border (rooms and transitions owns the exits). World state therefore never stores terrain. **[Rec]**
5. **What looks solid is solid.** On the play layer, anything that reads as ground, wall or ledge has solid tiles under it whose edge is its walkable or clingable line, and nothing solid is left unpainted or hidden. Dressing never carries collision. No invisible walls, no painted floors that drop the Seeker through. Background and foreground layers (parallax, lighting and atmosphere) are not the play layer and never imitate it (level design, Visual/Audio: Readability). **[Rec]**

**Faces and materials**

6. **Face segments.** A face is a straight run of collision edge between a solid (or one-way) tile and an empty one, on one side of a mass, from corner to corner. It is split at grid lines into **segments**: a segment is a maximal run of one material and one tile kind along one face, so a row where solid tiles meet one-way tiles is two segments. Each segment has one material: `plain` (the default) or `no_cling`. Material belongs to the segment, not the mass: a one-tile-thick wall may be `no_cling` on its left and plain on its right, and one wall may turn `no_cling` partway up (ability gating Edge Cases: a slide stops where the plain part ends). **[Owner, 2026-11-19: per face]** What `no_cling` does is ability gating's (rule 14).
   **Gate placement records.** Each gate in the room data is a **placement record**: an id, its type (table below), and the tile ranges of every terrain surface its formula reads, each listed as an **edge** or a **reference**. An edge is a surface the player judges the gate by (a lip, a ledge top, a gate face), so T3 bounds the art over it. A reference is a surface the formula measures from that the player does not judge the gate by (a pit floor, the standing floor a height is taken from), and it is not bounded. A range starts and ends on grid lines anywhere along a face and does not split its segment. Level design authors the records. Any number of records may list the same stretch of face (a ledge top that is also a dash gap's far lip carries both); a stretch any record lists as an edge is bounded. A gate check that reads a surface of a kind its type lists (edge or reference) outside its own record's ranges fails the room and names the placement. Surfaces in the last column are scanned across the room and never need a record. Only these six types need records: F8 and F9 scan every plain face in reach, and F10 and F11 read objects. A record's ranges move with a moved block (rule 13). **[Owner, 2026-11-19, third and fourth design reviews]**

| Type (formula) | Edge ranges (T3 bounds them) | Reference ranges (not bounded) | Scanned, never listed |
|---|---|---|---|
| `dash_gap` (F1) | Both lip tops, from the gap's edge back at least 2 tiles (the Seeker's width); both gap faces, from the lip down to the pit floor or the kill plane's height | The pit floor under the span (a safe or a hazard floor) | Standing spots in the span and on the far face; kill planes and spikes (objects) |
| `double_jump_ledge` (F2) | The ledge top and the ledge's own faces, underside included | The standing floor the ledge height is measured from | Launch faces (F8) |
| `grapple_ledge` (F3a) | The ledge top and the ledge's own faces, underside included | The standing floor at the standing point | Launch faces (F8); anchors (objects, F11) |
| `grapple_gap` (F3b) | Both lip tops (as F1); both gap faces, down to the kill plane's height | None | Standing spots, plain faces and `climbable` surfaces in the span; anchors |
| `cling_wall` (F6a) | The wall face, from the standing floor to its top or exit | The standing floor at its foot | Standing spots on or beside the wall |
| `climb_wall` (F6b) | The wall face behind the `climbable` marker | The standing floor at its foot | Other ways up; the marker (an object) |

   **One-way tiles.** A one-way tile has one collision face, its top edge. Its sides and underside are not collision edges: they carry no material and no record covers them, the bake may still trim them for looks, and T3 ignores them. **[Rec]**
7. **Signatures painted from data.** The bake (rule 11) paints each `no_cling` segment with its material over its whole length, the wall-cling grooves on every edge range of a `cling_wall` record and behind every `climbable` marker (ability gating rule 11), and each bisque pane's look over the pane's footprint from the object's data (a pane is an object, rule 4, and its faces are plain, ability gating rule 12). A segment never carries both `no_cling` and grooves: the room check rejects a `no_cling` segment listed as an edge by a `cling_wall` or `climb_wall` record or lying behind a `climbable` marker. The look of each comes from the art bible.
8. **Checks read data, never art.** Every layout check (ability gating F1-F11, level design F7 and rules 25-27) reads tiles, face materials and objects from the room data. A gate figure is a whole number of tiles: a 156 px gap is 26 tiles, a 90 px ledge 15. **[Calc]**

**From block-out to dressed room**

9. **Block-out.** A room starts as black tiles only, painted on the grid and played at once: "can you roughly reach every platform, does it make sense". No trim, no props. This is level design rule 3's grey-box. **[Sourced]** (Team Cherry call it "blocking out or tiling out a room")
10. **Approval.** A block-out is approved when its automated layout checks pass. A room's first approval also needs a play review that signs it off, and records `play_reviewed` in the room data. Approval records the room's **layout**: the room bounds and its exits, the collision, the face materials, the gate placement records (rule 6), the `crack` marks (Edge Cases), and every object on the grid that a layout check reads (hazards, kill planes, `hittable` targets, gate anchors, panes, `climbable` markers, doors and shortcut gates). Any later change to the layout is detected. **Encounter data is not layout:** enemy spawn points and patrol ranges are not part of it, so moving a spawn point never sends a room to Block-out by itself. **[Owner, 2026-11-19, sixth design review]** Each check declares the values it reads (room data, encounter data, tuning files). When any of them changes, that check re-runs on every Approved and Dressed room before the next build; a pass keeps the room's state, and a failure returns the room to Block-out and names the check. A tuning change and a spawn point move are handled the same way. **[Owner, 2026-11-19, second design review; per-check inputs: sixth design review]**
11. **Trim bake.** The rock or moss trim on every exposed face is generated from the collision, never drawn by hand: the biome's edge art is placed along each face so that its painted rock line lies on the collision line, and solid interiors stay black. **Every baked pixel belongs to the face it was baked for**, so one face's trim is never measured against another face (T3). On every edge range a gate record lists (rule 6) and every `no_cling` segment, the bake bounds that face's trim to `trim_overhang_max` (4 px, level design rule 25), so baked trim always passes T3; elsewhere the bake follows the art. A T3 failure on baked trim is a tools defect, reported to the tools owner, never an artist flag. **[Rec, fifth and sixth design reviews]** The same collision and biome always bake the same trim, so moving a platform "down one tile" re-bakes instead of re-painting. **[Owner, 2026-11-19: auto trim]** Trim is never older than the collision it was baked from: the bake runs on every save of a room in the editor and before any build for a room whose layout or biome changed since its last bake (tools spec). **[Owner, 2026-11-19, second design review]**
12. **Dressing.** Props, ruins, scenery, hanging decoration and play-layer framing are placed by hand over the baked trim. **[Owner, 2026-11-19]** **[Sourced]** (Team Cherry: "Ari will go through and 'dress' the room, put all the scenery and stuff in", before enemies and switches) Dressing obeys rule 5. Each prop in a biome's catalogue is marked **"reads solid"** or **"decoration"** once, at import. A "reads solid" prop may cover the collision edge of an edge range (rule 6) or a `no_cling` segment by no more than `trim_overhang_max`, the same bound as the trim; a "decoration" prop is not bounded there, so scenery may stand on a ledge top or hang over a lip. **[Owner, 2026-11-19, fourth design review]** When the artist has finished a room's dressing, they set the `dressed` sign-off in the room data. Only the artist sets it, and nothing sets it automatically: a baked room with no dressing is not Dressed. **[Owner, 2026-11-19, second design review]**
   **The ground check** reads only "reads solid" props: one fails when its walkable line lies more than `trim_overhang_max` from the top edge of a solid or one-way tile, or when its body lies more than `trim_overhang_max` inside solid tiles. **Decoration is never checked and never flagged**, whatever it overlaps or hangs over. **[Owner, 2026-11-19, fifth design review]**
   **Flags.** The dressing checks run on the saved room on every save in the editor, and on every Approved and Dressed room before every build. A failure raises a **flag** for the artist that names the prop or the face. There are three kinds: **overhang** (T3: a "reads solid" prop over an edge range or a `no_cling` segment past the bound), **off-ground** (the ground check), and **undressed new ground** (T5: new face since `dressed` exceeds `undressed_face_max`, rule 13). **Every flag is recomputed from the room data on every run**: it is open while its cause is in the data and closes when the cause is gone, so reverting an edit closes the flag it raised. Nobody can dismiss a flag. `dressed` cannot be set while any flag is open; a newly opened flag clears it (the room returns to Approved). Setting `dressed` records a new dressed baseline (rule 13), so new face counts from 0 again. **[Owner, 2026-11-19, sixth design review: all flags recomputed]** A release build ships only Dressed rooms; dev and playtest builds accept an Approved room with its flags open (States). **[Rec, fifth design review]**
13. **A change after approval.** Editing the layout (rule 10) of an Approved or Dressed room returns it to Block-out. The layout checks re-run at once, and a pass re-approves a room that already has `play_reviewed` with no further review (a designer can demand another by clearing the flag). The trim re-bakes from the new collision (rule 11). Collision is never moved to fit the art (level design rule 25). **[Owner, 2026-11-19, first design review]**
   **Small fixes stay small.** A **moved block** is a block of solid or one-way tiles removed and the same shape added, shifted by at most `move_max` tiles (6 **[Rec]**) along each axis, whether it is free-standing or attached to a wall, floor or the room border, and whether it was moved with a move tool or repainted tile by tile: the pipeline detects it from the data (T5). Everything anchored to a moved block moves with it by the same shift: its props of both kinds, the ranges of every gate record that lie wholly on its faces, and the objects on the grid that rest on it. The editor lists every carried item in a change report. A moved block counts no new face and raises no flag of its own; the layout checks then judge the room as it now is (a ledge moved out of a gate window fails its gate check, as any edit would). A record range that lies only partly on a moved block is not carried: the gate check fails and names the record, which level design fixes. **[Owner, 2026-11-19, sixth design review: any edit, detected]**
   **Other edits.** Ground added or reshaped (not a moved block) re-bakes; any "reads solid" prop it leaves off its ground or over an edge range past the bound raises a flag (rule 12), and is never moved silently. Setting `dressed` records the room's **dressed baseline**: its solid and one-way tiles, and the position and side of every exposed face tile (each tile-length of every segment). **New face** (T5) is the face tiles not in the baseline once moved blocks are shifted back; when it exceeds `undressed_face_max` (12 tiles **[Rec]**) it flags undressed new ground. Removing ground earns no credit. A new 6 x 1 ledge adds 14 tiles of new face (6 on top, 6 below, 2 ends) and flags; widening a 6 x 1 ledge by 2 tiles adds 5 (2 on top, 2 below, the new end). If no flag is open once the room is re-approved, the `dressed` sign-off survives and the room is Dressed again. **[Owner, 2026-11-19, second and third design reviews; counted by position: Rec, fourth design review]**
14. **One biome per room.** A room names one biome pack for its trim and dressing and never loads a second biome's terrain art; a loaded biome costs about 97 MB of texture memory (level design Open Question 22). A region border is crossed between rooms, never inside one. **[Rec]**

**Cost**

15. **Collision cost follows the faces, not the area.** Solid interiors add no collision of their own: a 10-screen room's collision grows with the number of its face segments (T4), not with its 36,000 tiles. Each face segment lies within a single collision shape, so a straight face has no seam. Drawing is batched per layer, never one node per tile (the code-built art-style long room grew to 524 nodes). How this is built is the ADR (Open Question 1). **[Rec; level design Open Question 22]**

**Gate figures on the grid (follow-up for level design)**

16. Gate figures are chosen from the on-grid values inside each window (Formulas). The dash workshop's gap (level design rule 11) is the narrowest on-grid width inside the F1 window, 150 px today, instead of "at most `gap_min` + 4 px", which no grid width meets. **[Owner, 2026-11-19; level design rule 11 and its criterion reworded the same day]**

### States and Transitions

Terrain has no runtime states (rule 4). Each room's terrain has a **production state**, stored in the room data and read by the build tools, the checks and the grey-box review; it is not world state.

| State | Meaning | Enter when | Leave when |
|-------|---------|-----------|-----------|
| Block-out | Layout only (rule 10); playable. A room sent back by an edit keeps its previous trim and dressing (rule 13) | A room is created; or an Approved or Dressed room's layout changes; or a re-run check fails (rule 10) | Its layout checks pass: a room already `play_reviewed` is Approved at once; a new room also needs the play review (rule 10) |
| Approved | The layout is final | Checks pass (and, for a new room, the review signs off) | `dressed` is set with the trim baked and no flag open (to Dressed); or the layout changes or a re-run check fails (to Block-out) |
| Dressed | Trim baked, dressing placed and signed off (`dressed` set, rule 12), no flag open | `dressed` is set while the room is Approved, its trim is baked and no flag is open; or a room re-approved after an edit still holds `dressed` and no flag is open (rule 13) | The layout changes or a re-run check fails (to Block-out); a flag opens, which clears `dressed` (to Approved) |

Only these transitions exist; every flag in this table is a recomputed flag (rule 12). The bake runs in any state. A **build** is an exported or packed game. Playing a room from the editor is not a build and accepts a room in any state, so a block-out is played, and gets its first play review, in the editor. No build ships a Block-out room, and a release build ships only Dressed rooms: the build refuses any other and names it. Dev and playtest builds accept Approved rooms too, so a reviewed block-out can be playtested before it is dressed. **[Owner, 2026-11-19, first design review]**

### Interactions with Other Systems

Only level design and ability gating have GDDs; the other interfaces are **provisional** until their owners are designed.

| System | Direction | Data flowing | Owner of the interface |
|--------|-----------|--------------|------------------------|
| Level design | Both | Out: the grid, tile kinds, face segments and materials, the block-out to dressed path, the overhang bound (rules 2-13). In: room layouts, a placement record per gate listing every surface its formula reads as an edge or a reference range (rule 6), `crack` marks (Edge Cases), gate placements whose figures snap to the grid (rule 16) | Level design owns where things go; terrain owns what they are built from |
| Ability gating | Both | Out: `no_cling` segments, the grooves, the pane's look painted from its object data, collision edges at gates. In: the gate windows whose on-grid values this GDD lists (Formulas), `pane_thickness` (12 px, on grid) | Ability gating owns what a gate is |
| Player controller | Out | The collision the Seeker moves on, one-way tiles, and the material of the face segment it touches (the `no_cling` skip, ability gating rule 14) | Terrain owns the data; the controller owns the reaction |
| Enemies | Both | Out: collision, one-way tiles counted as floor (`_floor_ahead`). In: spawn points, encounter data read by checks but not part of the layout (rule 10) | Enemies |
| Rooms and transitions | Both | Out: the tile grid inside each room's bounds (a whole number of 80 x 45-tile screens). In: room bounds and the exits; outside its bounds a room is solid except at exits | Rooms and transitions |
| Parallax, lighting and atmosphere | Out | Which layer is the play layer and its draw order (0 in the art packs); the rule that other layers never imitate it (rule 5) | Parallax, lighting and atmosphere |
| Art bible (not a system) | In | Each material's look (`no_cling`, grooves, the bisque pane), the painted art's scale and filtering at 4x, and the edge art's undershoot bound (Open Question 2) | Art bible |
| Objects on the grid (doors, breakables, panes, hazards, kill planes, `climbable`, gate anchors) | Out | Grid snap for their collision edges (rule 4); carried with a moved block (rule 13) | Each object's own system |
| Terrain tools (not a system) | Out | Every rule, bound and guarantee here; the tools spec says how each is met | `docs/architecture/terrain-tools-spec.md` |

## Formulas

The gate windows themselves are ability gating's (F1-F11) and level design's (F7); this section only says which of their values the grid allows, and states the bounds the tools must meet. No memory budget is checked here: the project's memory ceiling is `[TO BE CONFIGURED]` (Open Question 4).

### T1. On-grid figure

`on_grid(lo, hi) = { k x collision_tile : ceil(lo / collision_tile) <= k <= floor(hi / collision_tile), k >= 0 }`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| collision_tile | int (px) | 1, 2, 3 or 6; is 6 | constant (project setting) | Side of a black collision tile (rule 2). It must divide 30 (so a 480 x 270 screen is whole tiles) and the art cell (36 px in the art-style test room); 6 is the largest value that does both |
| lo, hi | float (px) | per window | calculated (ability gating F1-F11, level design F7) | The exact bounds of a gate window, computed from the owner's formula at the current `player_config.tres`, never copied and never from a rounded figure. An open-ended window ("or more") takes `hi` = the room's size |
| k | int (tiles) | 0 or more | calculated | A gate figure in whole tiles; 0 means "none" (a far face with no plain part) |

**Output Range:** a set of whole-tile figures. Before `ceil` and `floor`, `lo` and `hi` are rounded to the nearest 0.001 px, so a bound that is a tile multiple in the owner's figures (72, 84) is not lost to float error. **[Rec]** The narrowest window, the F1 dash gap, is 145 to 161.4 at margin 8 (`dash_jump_distance` 164.4 from the sim; ability gating rounds it to "about 165" for prose only), giving 150 and 156; 149 to 157.4 at `gap_margin` 12 (150, 156); 141 to 165.4 at margin 4 (144, 150, 156, 162). **[Calc, sixth design review: unrounded inputs]** An empty set means that gate type cannot be built at the current tuning: the layout check fails loudly ("gate type unbuildable") for every room holding that type; it never passes a room with no gates of that type.

**Example:** the values the grid allows today, from the owners' current figures:

| Window (owner) | Exact | On the 6 px grid |
|---|---|---|
| Dash gap width (ability gating F1, margin 8) | 145 to 161.4 (ability gating's prose and the registry say 145 to 162, from the rounded 165) | 150, 156 (162 enters only if a measured `dash_jump_distance` reaches 165, Open Question 3) |
| Double-jump ledge top (F2) | 72 to 106 | 72, 78, 84, 90, 96, 102 |
| Plain slab underside under an F2 ledge (`head_clear`; reference only, not a gate condition: F2 has no cling test since the 2026-11-20 key order) | 88 or more | 90 or more |
| Safe pit floor below the far lip (F1, `pit_depth_min`) | 72 or more | 72 or more |
| Hazard floor below both lips (level design F7, `hazard_pit_depth_min`) | 84 or more | 84 or more |
| Grapple ledge top, `no_cling` faces (F3a, margin 6) | 126 or more | 126 or more |
| Plain slab underside under a grapple ledge (F3a) | 143 or more | 144 or more |
| Grapple gap width (F3b) | 420 or more | 420 or more |
| Plain far face below a grapple gap's far lip (F3b, `far_face_max`) | 16 or less | 0, 6 or 12 |
| Cling or climb wall height (F6, `cling_wall_min`) | 165 or more | 168 or more |
| Bisque pane thickness (F10) | 8 to 16 | 12 |

**Visible gap.** Trim may cover each lip by up to `trim_overhang_max`, so a gap of width W can read as narrow as `W - 2 x trim_overhang_max`: 142 px for a 150 px gap at today's values, still wider than a run-jump's 137 px. At `gap_margin` 4 with `trim_overhang_max` 6 it would read 129 px, below 137, so a gap that needs the dash would look run-jumpable. Keep `2 x trim_overhang_max <= gap_margin`. **[Rec, sixth design review; level design owns both knobs]**

**Edge:** `collision_tile` = 0 is a division by zero and is not allowed. A tile wider than a window can leave it empty. A window with `lo > hi` is its owner's tuning error, reported as unbuildable. Before a tuning change is committed, its owner can run the checks as a dry run that lists the rooms the change would fail (tools spec).

### T2. (Withdrawn at the first design review, 2026-11-19)

A band-rounding formula was drafted here and removed: a distance between on-grid edges is already whole tiles, and rounding a distance to an off-grid hit-area edge (`pogo_far_ext`) would tighten a band level design owns. Level design's bands (`pogo_clearance_px` 250, `pogo_clearance_f3a_px` 320, `pogo_far_ext` 14) are used as written; the `band_on_grid` registry entry is deprecated. T3 to T5 keep their numbers. **[Owner, 2026-11-19]**

### T3. Trim overhang

`overhang(stretch) = max over the pixels the stretch owns, with alpha >= alpha_solid, of the distance along the face's outward normal from the collision line to the pixel's far edge`

A stretch passes when `overhang(stretch) <= trim_overhang_max`. The **stretches** are the edge ranges of every gate placement record (rule 6) and every `no_cling` segment, each measured on its own; nothing else is measured. **Which pixels a stretch owns:**
- **Baked trim:** only the pixels baked for the stretch's own face (rule 11) whose position along the face falls within the stretch. The floor's trim never counts against a wall and a wall's trim never counts against a ledge top, however they touch at a concave corner. At a convex corner where a stretch ends, the trim wrapping the corner counts against both faces that meet there.
- **"Reads solid" props:** a prop is measured when its body touches or crosses the collision line within the stretch; its pixels count against the nearest collision face, and at a concave corner against the face on their side of the corner's 45-degree bisector. A "reads solid" prop clear of the line is the ground check's (rule 12), not T3's.
- **Never measured:** "decoration" props, whatever their size or opacity, and the background and foreground layers.

**[Rec; measured pixels and the stretch domain: Owner, fourth design review; ownership by face: Owner, sixth design review, replacing the fifth review's attached region, which let floor trim at a concave corner count against a wall]** How the pixels are produced at game scale (source art, resampling, the per-asset profile computed at import) is the tools spec's; it must be deterministic and must not depend on the GPU.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| alpha_solid | float | 0.25-0.75, starts at 0.5 | data file (terrain knobs) | The opacity at which a painted pixel counts as reading solid. Compared in 8-bit alpha as `a8 >= round(alpha_solid x 255)`: 128 at 0.5 **[Rec]** |
| trim_overhang_max | int (px) | 2-6, starts at 4 | data file (level design rule 25) | How far art may cover the collision edge at gates; owned by level design. Whole game px, so a partly covered pixel cannot sit across the bound |
| art_scale | float (px per source px) | about 0.07 | calculated | `art_cell / source_cell` = 36 / 512 in the art-style test room; set by the art bible (Open Question 2) |

**Output Range:** 0 px (the art stops at the line) upward, in whole game px. At `alpha_solid` 0 every faint glow pixel counts and every gate fails; at 1 only fully opaque pixels count and antialiased rock slips past. Hence 0.25-0.75. At `trim_overhang_max` 0 the art is clipped exactly at gate edges.

**Example:** a rock nub 40 source px proud of the painted line overhangs 40 x 0.07 = 2.8 px, 3 whole px, and passes at a gate; a glow halo at alpha 0.3 does not count; a "reads solid" rock-shelf prop at alpha 0.9 reaching 6 px past a dash gap's lip fails and is flagged (rule 12); a "decoration" crate on an F2 ledge top is not measured. **A 150 px dash gap over a pit floor 72 px down**, with 6 px floor trim running from one gap face to the other: each gap face owns only its own trim, which the bake bounds to 4 px, so both faces pass; the floor's trim belongs to the floor, a reference range, and is not measured. A cling wall's foot and an F2 ledge attached to a wall behave the same way.

### T4. Collision cost

`collision_shapes(room) <= face_segments(room)`, and every face segment lies within exactly one shape.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| collision_shapes | int | 0 or more | calculated (the built room) | Collision shapes the built room holds for its terrain |
| face_segments | int | 0 or more | calculated (room data) | Face segments in the room (rule 6: maximal runs of one material and one tile kind along one face) |
| edge_tiles | int | 0 or more | calculated (room data) | Solid or one-way tiles with at least one empty neighbour; shown for comparison, not bounded |

**Output Range:** 0 up to `face_segments`; interior tiles and the length of a face add nothing (rule 15). An all-empty or all-solid room gives 0. Gate placement records do not split segments, so they add no shapes. The coverage rule stops a build with too few shapes passing: a room with faces and 0 shapes fails it.

**Example:** a one-screen room (80 x 45 tiles) with a 6-tile floor, walls and ceiling has 1,356 solid tiles around a 68 x 33 open space: 202 edge tiles (2 x (68 + 33)), 1,154 interior ones, and 4 plain face segments. One shape per tile would be 1,356 and one per edge tile 202; T4 allows at most 4, each face inside one of them. **[Rec; coverage: sixth design review]**

### T5. New face

`new_face(room) = | F_now' \ F_base |`  ·  `undressed_ground = new_face(room) > undressed_face_max`

`F_now'` is the room's exposed face tiles with every **moved block** (rule 13) shifted back by its shift. A moved block is a 4-connected group of tiles removed since the baseline matched to a 4-connected group of added tiles of the same tile kinds and shape, shifted by `(dx, dy)` with `|dx| <= move_max` and `|dy| <= move_max`. Each removed group is matched at most once, the smallest shift first, with a fixed tie-break (tools spec). A block need not be a whole mass: a ledge attached to a wall is a moved block when the ledge's own tiles move. **[Rec, sixth design review: replaces matching whole masses, which left attached ledges unexempt]**

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| F_now', F_base | set of (tile position, side) | n/a | room data; the dressed baseline (rule 13) | Exposed face tiles now (moved blocks shifted back) and when `dressed` was last set |
| move_max | int (tiles) | 0-12, starts at 6 | data file (terrain knobs) | Largest shift along each axis that still counts as a moved block. At 0 even "down one tile" counts as new; above 12 (72 px) a relocation passes as a fix |
| undressed_face_max | int (tiles) | 6-24, starts at 12 | data file (terrain knobs) | New face allowed before the room needs dressing again. At 6 a 2 x 1 nub (6) passes and a 3 x 1 ledge (8) flags; at 24 a new 10 x 1 ledge (22) passes unflagged |

**Output Range:** 0 upward; removing ground never lowers it. The flag is raised only above the knob, so exactly 12 does not flag. Before `dressed` is first set there is no baseline and no undressed-ground flag.

**Example:** at the starting values, a new free-standing 6 x 1 ledge gives 14 and flags; a new 3 x 1 ledge 8, no flag; widening a 6 x 1 ledge by 2 tiles 5; a 6 x 1 ledge attached to a wall, moved down one tile, 0; the same ledge moved 6 tiles right 0 and 7 tiles right 14 (flags); removing a 10 x 1 ledge and adding a 6 x 1 one elsewhere 14 (flags); raising a whole 68-tile floor by one tile 68 (flags: that is a repaint-sized change, not a moved block).

**Feedback loops:** none. The grid narrows choices; nothing in this system grows with play.

## Edge Cases

- **If a gate window holds no on-grid value** (T1, after a tuning change narrows it): the layout check fails with "gate type unbuildable" for every room that holds that gate type, and those rooms return to Block-out. The window is retuned by its owner; the grid is not changed to fit one window.
- **If a value a check reads changes** (`player_config.tres`, `attack_data.tres`, an enemy `.tres`, the gate-knob data file, Open Question 10, or a spawn point): that check re-runs on every Approved and Dressed room before the next build; a pass keeps the room's state and a failure returns it to Block-out (rule 10).
- **If the layout of an Approved or Dressed room is edited:** the room returns to Block-out and its checks re-run at once; a pass re-approves it with no further play review. A moved block carries its props, records and objects (rule 13); any other edit leaves "reads solid" props where they were and flags those now off their ground or over an edge range. Decoration is never flagged. With no flag open, `dressed` survives.
- **If only the dressing is edited** (a prop moved, added or removed after `dressed` is set): the layout is unchanged, so the room stays Approved or Dressed, but the dressing checks run on the save (rule 12). A "reads solid" prop that now covers an edge range past `trim_overhang_max`, or has no tiles under it, raises a flag, which clears `dressed`. A decoration prop raises no flag.
- **If an edit adds new ground** (a new ledge, a widened room): the re-bake trims it, and if new face since the sign-off exceeds `undressed_face_max` it flags undressed new ground (T5). Removing ground never offsets new ground. **If the edit is then reverted**, the flag closes (it is recomputed, rule 12).
- **If two gates measure the same stretch of face** (a ledge top that is also a dash gap's far lip): both records list it, and each check reads its own record (rule 6). It is bounded by T3 if either record lists it as an edge. Nothing is rejected.
- **If a moved block carries only part of a record's range** (the range runs from the moved ledge onto a wall that did not move): the range is not carried and the gate check fails and names the record (rule 13).
- **If a `no_cling` segment is listed as an edge by a `cling_wall` or `climb_wall` record, or lies behind a `climbable` marker**: the room check rejects it (rule 7).
- **If a floor steps up by one tile (6 px)**: the Seeker's run stops at it and the step needs a hop. The controller has no step-up on the ground (`_nudge_onto_ledge` runs only in the air, and lifts at most `ledge_nudge`, 5 px, less than a tile). A route meant to be run is level or steps by 2 tiles or more, so a step reads as deliberate. A one-tile step is legal and is not flagged.
- **If a single solid tile juts out of a cling wall** (a 6 px nub): it is a standing spot, so the wall is no longer a cling wall (ability gating F6a) and the gate check rejects it.
- **If a space is too small for the Seeker** (10 x 22 standing, 14 high crouched): the room check needs no route search. It flags every empty tile whose horizontal run of empty tiles, bounded by solid tiles at both ends, is under `pass_w` tiles, or whose vertical run is under `pass_h` tiles, unless a `crack` mark covers it. A vertical run starts at the top of the solid or one-way tile below it and is measured upward, through any one-way tile, to the first solid tile, and each one-way tile it passes through counts toward its length: the Seeker rises through a one-way tile, so a space under one is not a dead end, while a space above one is measured from the one-way tile's top, where the Seeker stands. A horizontal run also passes through one-way tiles and counts them, because their sides are not collision (rule 6); it ends only at solid tiles. `pass_w = floor(hitbox_width / collision_tile) + 1` and `pass_h = floor(hitbox_height / collision_tile) + 1`, 2 and 4 tiles (12 and 24 px) at today's `hitbox_size` 10 x 22; the `+ 1` keeps a space at least one px wider than the hitbox, so a hitbox that is an exact tile multiple is never jammed by the physics margin. **[Rec, sixth design review: was `ceil`, same values today]** The check reads `hitbox_size` from `player_config.tres`, so a hitbox change re-runs it (rule 10). A `crack` mark is a rectangle of whole tiles in the room data. Level design marks a space `crack` when it is a crack for looks, not a way through, and the Seeker never needs to enter it. A sealed alcove (level design rule 2) is never marked `crack`: a leak (level design rule 12) can take the Seeker into it, so it must pass this check. A 3-tile-high space that forces a crouch is flagged: no crawl space is specified, and level design decides whether the game has any. **[Owner, 2026-11-19, third and fourth design reviews]**
- **If a one-way tile lies on a gate's measured surfaces or inside a gate volume** (a ledge top, a lip, a face, level design F7's volume): the layout check rejects it. The gate formulas model only solid tiles. **[Rec]**
- **If two solid tiles meet only at a corner**: movement treats the corner as closed (the Seeker never squeezes through a 0 px diagonal), and the bake paints both faces and the inner corner.
- **If the Seeker slides along a long floor, wall or ceiling made of many tiles**: it never catches, stops or bumps on a seam between tiles; each face segment lies within one collision shape (rule 15, T4).
- **If a face is shorter than the biome's edge art** (a one-tile nub, a 2-tile step): the bake still trims it, and T3 governs it at gates. No face is left untrimmed.
- **If the biome's edge art pokes out further than `trim_overhang_max`** (a rock nub 6 px proud at game scale): on edge ranges and `no_cling` segments the bake bounds it to 4 px (rule 11), and elsewhere it keeps its full 6 px, with no visible step where a range ends (tools spec). If baked trim ever fails T3, the bake has a defect: it fails and is reported to the tools owner, and no artist flag is raised.
- **If a wall one tile thick needs different materials on its two sides**: allowed (rule 6). The data holds each side's segment separately.
- **If a face changes material or tile kind partway along**: allowed at a grid line; each part is its own segment, painted with its own look, and the controller reads the segment it touches (ability gating Edge Cases).
- **If an object (door, pane, breakable, hazard, kill plane, `climbable`, gate anchor) is placed off the grid, or overlaps solid tiles**: the room check flags it; it is never snapped or moved silently. A pane must also measure 12 px (T1 table).
- **If a play-layer prop that reads as solid has no solid tiles under its walkable line**: the ground check flags it (rule 12). Each prop is marked "reads solid" or "decoration" once, at import; an unmarked prop cannot be placed (tools spec).
- **If a room's bounds are not a whole number of screens**: the build refuses it (80 x 45 tiles per screen); rooms and transitions owns the room bounds.
- **If a room sits at a region border**: it uses one biome (rule 14); the next biome loads at the exit, where its first load (0.75-1.07 s measured, level design Open Question 22) needs a longer fade or a background load. Owned by rooms and transitions.

## Dependencies

The systems index places this system in the Foundation layer (Category: Core) with no upstream system. It reads two GDDs for definitions only: what a gate window is and what `no_cling` does. Nothing in it waits on them to work.

**Upstream (this system reads them):**

| System | Hard / soft | What this system needs | GDD exists |
|--------|-------------|------------------------|------------|
| Ability gating | Soft (definitions) | The gate windows T1 lists (F1-F3, F6, F10) and the meaning of `no_cling` (rule 14) and the grooves (rule 11). A retune changes the on-grid table, not this system's rules | Yes, Approved (`design/gdd/ability-gating.md`) |
| Level design | Soft (definitions) | `trim_overhang_max` and rule 25, the F7 bands (used as written), the grey-box gate (rule 3), and the gate placement records and `crack` marks it authors (rule 6) | Yes, Approved (`design/gdd/level-design.md`) |
| Art bible (not a system) | Soft | The look of each material and signature, the painted art's scale and filtering (`art_cell`, T3), and the undershoot bound (Open Question 2) | No (`/art-bible` not run) |

**Downstream (these need this system):**

| System | Hard / soft | What it needs from here |
|--------|-------------|--------------------------|
| Rooms and transitions | Hard | The tile grid inside a room's bounds, whole screens of 80 x 45 tiles, solid outside the bounds except at exits |
| Level design and world layout | Hard | The grid, tile kinds, face materials, the block-out to dressed path and the overhang bound; on-grid gate figures (rule 16, T1) |
| Ability gating | Hard | `no_cling` segments, the grooves, the bisque pane's look (painted from the object's data), and collision edges at gates measured on data |
| Player controller | Hard | The collision it moves on, one-way tiles, and the face material at a wall contact |
| Enemies | Hard | Collision and one-way tiles as floor (`_floor_ahead`) |
| Parallax, lighting and atmosphere | Hard | The play layer and its draw order, and rule 5 (other layers never imitate it) |
| Objects on the grid (doors, shortcuts, breakables, panes, hazards, kill planes, `climbable`, gate anchors) | Soft | The grid their collision edges snap to (rule 4); carried with a moved block (rule 13) |

**Bidirectional check:**

- Level design lists this system as a hard upstream dependency (Dependencies, Terrain pipeline row) and cites rules 1, 6, 11 and 16 and the `crack` Edge Case; ability gating lists it (Dependencies) and cites rule 6. All keep their numbers and meaning in this restructure.
- The systems index lists Rooms and transitions, Level design and Parallax as depending on this system. Its Ability gating row says that system supplies terrain its `no_cling` and pane materials (the definitions half of the "Both" row in Interactions).
- Player controller and Enemies have no GDD yet. Each needs a matching entry when it is designed; Enemies must also adopt rule 10's split between layout and encounter data.
- Earlier follow-ups, all done: first review, level design rule 11, its workshop criterion and Open Question 17 (rules 1, 16); second and third, both GDDs' rows name placement records and the pane as an object; fourth, level design's row names `crack` marks and edge or reference ranges. Sixth review: everything changed (T3 ownership, T5 blocks, recomputed flags, encounter data out of the layout) is internal, and level design rule 25 and ability gating need no change.

## Tuning Knobs

| Knob | Owner | Value | Safe range | What it changes |
|---|---|---|---|---|
| `collision_tile` | Terrain (constant) | 6 px | 1, 2, 3, 6 | Grid size; which gate figures exist (T1) |
| `alpha_solid` | Terrain | 0.5 | 0.25-0.75 | When a painted pixel reads solid (T3) |
| `move_max` | Terrain | 6 tiles | 0-12 | How far a block may move and still count as moved (rule 13, T5) |
| `undressed_face_max` | Terrain | 12 tiles | 6-24 | New face before a room needs dressing again (T5) |
| `trim_overhang_max` | Level design (rule 25) | 4 px | 2-6, and `2 x` it `<= gap_margin` | How far art may cover a gate edge (T3); with the gap margin, how wide a gap reads (T1) |

Terrain's knobs live in one data file that the checks declare (rule 10).

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted. The art bible (not yet written) owns every look named here; this section lists what the pipeline must be able to produce.

- **Black masses.** Solid interiors are flat black, so an approved block-out keeps its shape and silhouette when it is painted (level design rule 3 and Visual/Audio, Terrain look).
- **Trim on every face.** Each exposed face carries the biome's rock or moss edge art, baked from the collision (rule 11), with corners resolved by the bake (tools spec). Play-layer collision edges are the brightest values in a room and the room reads in greyscale (level design, Readability).
- **Signatures.** The `no_cling` material, the wall-cling grooves (copper-green) and the bisque pane each have one look that nothing else in the world uses (ability gating rules 11, 14, 15). The bake paints them from face and object data, never by hand. Their relief stays within `trim_overhang_max` on the segments they mark, or the bound would cut them.
- **Draw order.** Distant background, midground, then the play layer (black fill, trim, dressing), then foreground, as in the biome packs (`assets/environment/PACK-README.md`: camera factors 0.15, 0.50, 1.00, and 1.20 for the foreground). The parallax system owns every layer but the play layer.
- **Filtering.** The Seeker keeps nearest filtering at 4x; painted terrain uses smooth, mipmapped filtering, as in the art-style test room. The scale of painted terrain against the grid (`art_cell`) waits on the art bible (Open Question 2).
- **Audio.** Terrain plays no sound of its own. **[Rec]** Each biome names a surface type per face material, so the audio system can pick footstep, landing and wall-slide sounds (Vertical Slice).

📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:terrain-pipeline` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

These are design targets, not acceptance criteria; the player-side ones are checked by the seam criterion.

- **Ground you can trust.** The Seeker never catches on a seam, never stands on air, and never bumps into art that has no collision. A player learns the world's edges once and they hold.
- **Block-out speed.** A room's block-out is quick enough to iterate on by playing. **[Sourced]** Team Cherry: "a world was two days to do the tiles, based on the sketches, and then another four days to do the art pass". **[Rec]** Targets: from saving a tile edit to playing the room within about 5 s, checks included; a 10-screen room bakes its trim within about 2 s.
- **Small fixes stay small.** Moving a platform "down one tile" (Team Cherry) costs a tile edit and a re-bake: its props, gate records and objects move with it, nothing is flagged, nothing is repainted and no new play review is needed (rule 13).

## UI Requirements

None player-facing: the player never sees the pipeline. The editor needs a collision overlay that shows tiles, face materials, objects and every open flag, and the change report of rule 13; that is a tools story, not a UX spec.

## Cross-References

| This GDD uses | Owner | Status |
|---------------|-------|--------|
| Gate windows F1, F2, F3a, F3b, F6, F10 (`gap_min`, `gap_max`, `ledge_min`, `ledge_max`, `head_clear`, `pit_depth_min`, `far_face_max`, `pane_thickness`) | Ability gating | `design/gdd/ability-gating.md`, Approved |
| `no_cling` (rule 14), the grooves (rule 11), the bisque pane (rules 15-17) | Ability gating | Approved; controller `no_cling` skip not built |
| `trim_overhang_max` and rule 25, grey-box first (rule 3), dash workshop (rule 11) | Level design | `design/gdd/level-design.md`, Approved |
| `hazard_pit_depth_min`, `pogo_clearance_px`, `pogo_clearance_f3a_px`, `pogo_far_ext`, gate volumes (F7) | Level design | Approved; registered in `design/registry/entities.yaml` |
| Texture memory per biome (about 97 MB), biome first load 0.75-1.07 s, node growth (level design Open Question 22) | Level design / rooms and transitions | Measured 2026-11-19 in the container (no GPU) |
| `hitbox_size` 10 x 22, `ledge_nudge` 5, `_nudge_onto_ledge` in the air only | Player controller | `player_config.tres`, `player.gd`; no GDD |
| `_floor_ahead` | Enemies | `enemy_base.gd`; no GDD |
| Frame budget 16.6 ms, 500 draw calls; memory ceiling not set | Project | `.claude/docs/technical-preferences.md` |
| Biome pack format (7 x 7 cells of 512 px, props, parallax layers) | Art assets | `assets/environment/PACK-README.md` |
| How the checks, bake, flags and fingerprints are built | Terrain tools | `docs/architecture/terrain-tools-spec.md`, Draft |

## Acceptance Criteria

Types: **[Auto]** automated test on room data, the built room or the engine; **[Shot]** retained screenshot in `production/qa/evidence/`; **[Play]** playtest or hardware record. Criteria for the tools themselves (save hook, room-check command, builds, caches) are in the tools spec. Every [Auto] check here runs as a pure function on room-data fixtures unless it says the engine.

**Units and grid**
- **GIVEN** any room, **WHEN** it is shown in play, **THEN** the window renders at 1920 x 1080 with the camera at zoom 4, so 480 x 270 game px fill the screen. **[Play]** (rule 1; needs Open Question 9) **GIVEN** the Seeker, **THEN** its collision box measures 10 x 22 game px. **[Auto]**
- **GIVEN** every room's data, **WHEN** it is checked, **THEN** the room's width and height are whole multiples of 80 and 45 tiles, and every collision edge and every object's collision edge lies on a multiple of 6 px from the room's top-left corner; an object 1 px off the grid is flagged and left where it was. **GIVEN** a room 81 tiles wide, **THEN** it is refused and named. **[Auto]** (rules 2, 4)
- **GIVEN** a room's data, **WHEN** it is checked, **THEN** every tile is empty, solid or one-way, and every collision face is horizontal or vertical. **[Auto]** (rule 3)
- **GIVEN** a one-way tile 2 tiles above a floor, **WHEN** the Seeker jumps up into it from below, **THEN** it passes up through without stopping; **WHEN** it later falls onto it, **THEN** it lands and stands on its top edge. **[Auto, engine]** **GIVEN** an enemy walking toward it, **THEN** `_floor_ahead` treats it as floor. **[Auto, engine]** (rule 3)

**Static terrain and what looks solid**
- **GIVEN** a room with a door, a pane and a breakable wall, **WHEN** all three are opened or broken in play, **THEN** the room's tile data hashes the same as at load. **[Auto, engine]** (rule 4)
- **GIVEN** a Dressed room, **WHEN** the room check runs, **THEN** every exposed face has trim and no dressing node carries collision. **[Auto]** **GIVEN** the same room captured with the collision overlay on, saved as `production/qa/evidence/terrain-<room>-overlay.png`, **THEN** the art lead signs off in `terrain-<room>-signoff.md` that every painted ground, wall and ledge line has a collision edge under it. **[Shot]** (rules 5, 12)

**Faces and materials**
- **GIVEN** the wall cling owned and a wall one tile thick, `no_cling` on its left side and plain on its right, **WHEN** the Seeker presses into each side in the air, **THEN** it slides and wall-jumps on the right side and falls past the left side. **[Auto, engine]** (rule 6; needs the controller's `no_cling` skip, ability gating Open Question 2)
- **GIVEN** a wall that is plain for its lower 5 tiles and `no_cling` above, **THEN** it holds two segments; **GIVEN** a floor row of 6 solid tiles then 4 one-way tiles, **THEN** its top face holds two segments. **[Auto]** (rule 6)
- **GIVEN** a `no_cling` segment listed as an edge by a `cling_wall` record, one listed by a `climb_wall` record, and one that lies behind a `climbable` marker, **WHEN** the room check runs, **THEN** each of the three is rejected. **[Auto]** (rule 7)
- **GIVEN** a ledge top that is both an F2 ledge's top and an F1 dash gap's far lip, with one record for each listing it as an edge, **WHEN** the room check runs, **THEN** both gate checks pass. **GIVEN** the same room with the far lip removed from the F1 record's ranges, **THEN** the room fails and the report names the F1 placement. **[Auto]** (rule 6)
- **GIVEN** a dash gap over a safe pit floor whose F1 record lists both lips and both gap faces as edges but omits the pit floor, **THEN** the room fails and names the F1 placement; **GIVEN** the pit floor added as a reference range, **THEN** it passes. **[Auto]** (rule 6, record table)
- **GIVEN** an F2 ledge whose record omits its standing floor, **THEN** the room fails and names it. **GIVEN** a standing spot inside a dash gap's span, **THEN** the F1 check rejects it whether or not any record lists it. **[Auto]** (rule 6, record table)
- **GIVEN** a Dressed room, **WHEN** it is captured as `production/qa/evidence/terrain-<room>-signatures.png`, **THEN** the art lead signs off that each `no_cling` segment shows its material over its whole length, each `cling_wall` edge range and `climbable` shows the grooves, and each bisque pane shows its look over its footprint. **[Shot]** (rule 7)
- **GIVEN** an Approved room, **WHEN** the layout checks run once with its trim and dressing and once with both removed, **THEN** the results are identical. **[Auto]** (rule 8)

**Block-out to dressed**
- **GIVEN** a room of black tiles only, **WHEN** it is loaded in play, **THEN** it loads with no errors and the Seeker spawns standing and accepts input for 60 frames. **[Auto, engine]** (rule 9)
- **GIVEN** a new room in Block-out whose checks pass, **THEN** it stays in Block-out until `play_reviewed` is set, and is then Approved. **[Auto]** (rule 10)
- **GIVEN** an Approved room with `play_reviewed`, **WHEN** any one of these is changed by one tile — a tile, a face material, a record's range, a `crack` mark, an exit, a spike, a `hittable` target, a gate anchor, a pane — **THEN** the room is in Block-out, its checks re-run, and on a pass it is Approved again with no play review. One test case per item. **[Auto]** (rules 10, 13)
- **GIVEN** a Dressed room, **WHEN** an enemy spawn point is moved by one tile and the checks that read spawn points pass, **THEN** the room is still Dressed; **WHEN** instead it is moved into a level design F7 gate volume, **THEN** that check fails, names the spawn point and the room is in Block-out. **[Auto]** (rule 10)
- **GIVEN** a room in Block-out, **THEN** no build accepts it. **GIVEN** a room that is Approved but not Dressed, **THEN** a release build refuses it and names it and a dev build accepts it. **[Auto]** (States; build harness in the tools spec)
- **GIVEN** an Approved room with its trim baked, no dressing, no flag open and `dressed` unset, **WHEN** its state is read, **THEN** it is Approved, not Dressed; **WHEN** the artist sets `dressed`, **THEN** it is Dressed. **GIVEN** the same room with its trim not yet baked, **THEN** setting `dressed` is refused. **[Auto]** (rule 12, States)
- **GIVEN** an Approved room and a "reads solid" prop at alpha 0.9 covering a dash gap's lip by 6 px, its walkable line on the lip, **WHEN** the dressing checks run, **THEN** exactly one overhang flag names the prop and the face, setting `dressed` is refused, and the flag cannot be dismissed; **WHEN** the prop is moved back to cover the lip by 3 px, **THEN** the flag closes and `dressed` can be set. **[Auto]** (rule 12, T3)
- **GIVEN** the same lip with a "decoration" crate 30 px tall standing on it, a decoration vine hanging into open air and decoration moss over the black mass, **WHEN** the dressing checks run, before and after the ledge moves down one tile, **THEN** no flag is raised for any of them. **[Auto]** (rule 12, ground check)
- **GIVEN** a Dressed room, **WHEN** a "reads solid" prop is moved so its walkable line sits 6 px above the nearest tile top, without changing any tile, **THEN** one off-ground flag is raised, `dressed` is cleared and the room is Approved. **[Auto]** (rule 12)
- **GIVEN** the same collision and biome, **WHEN** the trim is baked twice, **THEN** both bakes are identical (same hash). **GIVEN** a face one tile long, **WHEN** it is baked, **THEN** it has trim. **[Auto]** (rule 11)
- **GIVEN** a biome edge art piece with a rock nub 6 px proud at game scale, **WHEN** it is baked onto a dash gap's lip, a `no_cling` segment and a plain face no record covers, **THEN** T3 measures at most 4 px on the lip and on the `no_cling` segment, the nub keeps its full 6 px on the unmarked face, and no flag is raised. **[Auto]** (rule 11)

**Small fixes stay small**
- **GIVEN** a Dressed room with `play_reviewed` and a 6 x 1 ledge attached to a wall, carrying a "reads solid" rock prop, a decoration tuft, and the edge range of an F2 record, **WHEN** the ledge's tiles are repainted one tile lower, **THEN** the room passes its checks and is Dressed again with no play review; the prop, the tuft and the record's range have moved down one tile; the change report lists all three; and no flag is raised. **[Auto]** (rule 13, T5)
- **GIVEN** the same ledge moved with the editor's move tool 6 tiles right, **THEN** the result is the same; **WHEN** instead it is moved 7 tiles right, **THEN** it counts 14 tiles of new face, its props stay where they were and are flagged off-ground, and the undressed-ground flag is raised. **[Auto]** (rule 13, T5)
- **GIVEN** a record range running from the moved ledge onto the wall it is attached to, **WHEN** the ledge moves down one tile, **THEN** the range is not carried and the gate check fails and names the record. **[Auto]** (rule 13)
- **GIVEN** a Dressed room and `undressed_face_max` 12, **WHEN** a new 3 x 1 ledge is added, **THEN** no undressed-ground flag is raised; **WHEN** instead a new 6 x 1 ledge is added, **THEN** the flag is raised and `dressed` is cleared; **WHEN** that edit is reverted, **THEN** the flag closes; **WHEN** instead the artist sets `dressed` with the new ledge in place, **THEN** the flag closes and the next new face counts from the new baseline. **[Auto]** (rules 12, 13)
- **GIVEN** a room, **WHEN** it is loaded, **THEN** its data names exactly one biome and every loaded terrain art resource lies under that biome's directory. **[Auto, engine]** (rule 14)

**Formulas**
- **GIVEN** T1 with `collision_tile` 6, **WHEN** it is evaluated, **THEN** `on_grid(145, 161.4)` = {150, 156}, `on_grid(145, 162)` = {150, 156, 162}, `on_grid(149, 157.4)` = {150, 156}, `on_grid(72, 106)` = {72, 78, 84, 90, 96, 102}, `on_grid(84, 84)` = {84}, `on_grid(0, 16)` = {0, 6, 12}, and `on_grid(72.0000001, 106)` includes 72. **GIVEN** `on_grid(151, 155)` or a window with `lo > hi`, **THEN** it is empty and a room holding that gate type reports "gate type unbuildable". **GIVEN** `collision_tile` 0, **THEN** the project settings are rejected. **[Auto]** unit test (T1)
- **GIVEN** a test face with opaque trim pixels whose far edge is 4 px past the collision line, **WHEN** T3 runs on an edge range with `alpha_solid` 0.5 and `trim_overhang_max` 4, **THEN** it passes; at 5 px it fails. **GIVEN** pixels at 8-bit alpha 127, **THEN** they do not count; at 128 they do. **GIVEN** a "decoration" prop's pixels 30 px past the line, **THEN** they do not count. **[Auto]** unit test (T3)
- **GIVEN** a 150 px dash gap over a pit floor 72 px below, with opaque trim 3 px proud on both gap faces and 6 px proud along the whole pit floor, **WHEN** T3 runs on each gap face, **THEN** each measures 3 px and passes. **GIVEN** a cling wall whose standing floor carries 6 px trim, **THEN** the wall measures only its own trim. **GIVEN** an F2 ledge attached to a wall that rises 100 px above it, **THEN** the ledge top measures only its own trim. **[Auto]** unit test (T3)
- **GIVEN** an opaque "reads solid" prop floating 20 px above a lip with clear pixels between, **WHEN** T3 runs on the lip, **THEN** the prop is not counted (the ground check flags it). **GIVEN** a prop 6 px proud touching the line on a floor tile just outside an edge range, **THEN** it is not counted. **[Auto]** unit test (T3)
- **GIVEN** T5 with `undressed_face_max` 12 and `move_max` 6, **WHEN** it is evaluated, **THEN** a new 6 x 1 ledge gives 14 and flags, a new 3 x 1 ledge 8 and does not, exactly 12 new face tiles do not flag and 13 do, widening a 6 x 1 ledge by 2 tiles gives 5, a wall-attached 6 x 1 ledge moved down 1 tile gives 0, a free 6 x 1 platform moved 6 tiles right 0 and 7 tiles right 14, and removing a 10 x 1 ledge while adding a 6 x 1 ledge elsewhere gives 14. **GIVEN** two identical platforms 3 tiles apart both moved 1 tile down, **THEN** each matches its own baseline and new face is 0. **[Auto]** unit test (T5)
- **GIVEN** a one-screen room with a 6-tile floor, walls and ceiling, **WHEN** it is built, **THEN** `edge_tiles` is 202, `face_segments` is 4, and its terrain holds at most 4 collision shapes with each face inside exactly one of them; an all-empty room holds 0. **[Auto, engine]** (T4, rule 15)

**Cost and feel of the collision**
- **GIVEN** a pipeline-built 10-screen room with one straight floor, wall and ceiling face, **WHEN** the Seeker moves along a face at one speed — one test case for each of: running at `run_speed` (140) and dashing at `dash_speed` (370) along the floor; dashing along the ceiling in the air; falling at `max_fall_speed` (480) and `fast_fall_speed` (640) and sliding at `wall_slide_speed` (60) along the wall — **THEN**, from the 10th physics frame after it reaches that speed at 60 physics ticks per second, its displacement along the face on every frame is within 0.5 px of the speed times the frame time, and its distance from the face changes by less than 1 px. **[Auto, engine]** (rule 15, Edge Cases)
- **GIVEN** the 3-screen and the 10-screen art-style rooms built by this pipeline, **WHEN** they are built, **THEN** the terrain node count (nodes that hold collision or baked trim; dressing and the background and foreground layers excluded) of each is at most the fixed ceiling the ADR sets, and the two counts are equal. **[Auto, engine]** **WHEN** each room is played through the bench's camera sweep (`tests/performance/art_room_bench.tscn`) on the owner's machine, **THEN** each draws within 500 draw calls and its p99 frame time is at most 16.6 ms, recorded with the machine spec in `production/qa/evidence/art-style-long-room/`. **[Play]** (rule 15; the container has no GPU, so draw calls cannot be counted there)

**Edge cases that could ship broken**
- **GIVEN** a one-way tile on a ledge top, a lip, a gate face or inside a level design F7 gate volume, **WHEN** the room check runs, **THEN** it is rejected. **[Auto]** (Edge Cases)
- **GIVEN** an empty space 1 tile wide between solid tiles, and separately one 3 tiles high between a floor and a ceiling, neither covered by a `crack` mark, **THEN** each is flagged; **GIVEN** the same two spaces covered by `crack` marks, **THEN** neither is flagged. **[Auto]** (Edge Cases)
- **GIVEN** a column of floor, 1 empty tile, a one-way tile, then 3 empty tiles to a solid ceiling, **THEN** the empty tile under the one-way tile is not flagged (a run of 5, counting the one-way tile) and the 3 tiles above it are (a run of 3). **GIVEN** a row of solid, 1 empty tile, a one-way tile, solid, **THEN** the empty tile is not flagged (a run of 2). **GIVEN** `hitbox_size` changed to 10 x 24 in `player_config.tres`, **THEN** the check re-runs and a 4-tile-high space is flagged (`pass_h` 5). **[Auto]** (Edge Cases)
- **GIVEN** a space 2 tiles wide and 4 tiles high, **WHEN** the Seeker walks through it standing at `run_speed`, **THEN** its horizontal speed stays within 1 px/s of `run_speed` on every physics frame inside the space, and the room check flags nothing. **[Auto, engine]** (Edge Cases)
- **GIVEN** a floor with a one-tile step, **THEN** nothing is flagged. **GIVEN** a cling wall with a one-tile nub, **THEN** the F6a check rejects it. **GIVEN** a door overlapping one solid tile, **THEN** it is flagged and left where it was. **GIVEN** a pane 18 px thick, **THEN** it is flagged. **[Auto]** (Edge Cases)
- **GIVEN** two solid tiles meeting only at a corner, **WHEN** the Seeker pushes into the corner from either open side at `run_speed`, `dash_speed` and `fast_fall_speed` (one case each), **THEN** it never passes through. **[Auto, engine]** (Edge Cases)

**Cross-system**
- **GIVEN** level design's dash workshop, **WHEN** its gap is measured on the collision, **THEN** it is the narrowest on-grid width in the F1 window (150 px at today's figures). **[Auto]** (rule 16; level design rule 11)

**Gaps found by the QA checks:**
- The `no_cling` criterion cannot pass until the controller has the `no_cling` skip (ability gating Open Question 2).
- The display criterion (rule 1) cannot pass until the display migration is decided and built (Open Question 9).
- The seam, one-way and collision-shape criteria rest on engine features this repo's engine reference does not cover (Open Question 1). They stay as written and decide the ADR, not the other way round.
- Frame time and draw calls can only be recorded on the owner's machine.
- Whether a prop "reads solid" is set by hand once per prop at import, so its criteria check the data, not the art.

## Open Questions

Owner is the project owner unless stated. No dates are set; each has a target step instead.

1. **How collision and trim are built (ADR), and the prototype room.** Whether rooms are painted in a `TileMapLayer` or as tile data from which merged collision is generated; how a segment's material is stored per side and read at a wall contact; how T4's one-shape-per-segment rule and the seam criterion are met; how baked trim is stored and drawn, and the fixed per-room terrain node ceiling the node-count criterion needs. **NOT SOURCEABLE**: `TileMapLayer` physics, collision merging and one-way shapes in Godot 4.7 are not covered by `docs/engine-reference/godot/`, so no engine claim is made here. Owner: technical director via `/architecture-decision`. Target: before the first terrain story. **Build one painted prototype room first and run the T3, T5 and passage fixtures in it; this GDD stays frozen until then** (sixth design review).
2. **Art scale, filtering and undershoot.** The art-style test room maps a 512 px source cell to 36 game px (a 3.6x downscale at the 4x draw). Decide `art_cell`, the filtering for painted terrain, and whether the pixel-art Seeker sits well on it; `collision_tile` must divide `art_cell` (T1). Also set the edge art's **undershoot bound**: how far a piece's painted rock line may stop short of its cell edge, checked at import, so baked trim never leaves the Seeker standing on air (rule 5; was Open Question 11). Owner: `/art-bible`. Target: before any room is painted.
3. **The 162 px dash gap.** It enters the F1 window only if the measured `dash_jump_distance` reaches 165; the sim gives 164.4. Measure in `movement_test_room`. Owner: ability gating Open Question 3.
4. **Memory ceiling.** The project's memory ceiling is `[TO BE CONFIGURED]` (`.claude/docs/technical-preferences.md`); a loaded biome costs about 97 MB, two at a region border. Set the ceiling and the target platform, then add a criterion. Owner: technical director. Target: before region 1's grey-box.
5. **Test rooms off the grid.** The existing test rooms (`movement_test_room`, `gate_test_rooms`, the art-style rooms) are built off the 6 px grid in code. They stay test rooms; region rooms use this pipeline.
6. **Prop catalogue format.** Each biome prop is marked "reads solid" or "decoration" at import, with its walkable line and body (rule 12). The format belongs with the ADR (question 1) and the tools spec. Target: the pack import story.
7. **Starting values to check in the prototype room.** `alpha_solid` 0.5 (T3), `undressed_face_max` 12 and `move_max` 6 tiles (T5), and the block-out speed targets (Game Feel). Target: the prototype room in question 1.
8. **Surface sounds.** A surface type per face material for footsteps and landings (Visual/Audio). Owner: audio. Target: Vertical Slice.
9. **Display migration to 1920 x 1080.** `project.godot` still holds a 480 x 270 base with viewport stretch and integer scale (window override 1440 x 810), and only `art_style_test_room.gd` switches to 1920 x 1080 at runtime. Decide the project settings, who owns the camera zoom, and what happens to the existing rooms, the Seeker's nearest filtering and parallax placement (the test room found `Parallax2D` misplaces layers under zoom 4). Owner: technical director via `/architecture-decision`, with the camera. Target: before the first terrain story.
10. **Gate-knob data file.** Ability gating's margins and level design's bands are "data file" knobs, but no such file exists yet. Each check declares it once it exists (rule 10). Owner: the first gate-check story.
11. **Encounter data in the Enemies GDD.** Spawn points and patrol ranges are encounter data, not layout (rule 10); the Enemies GDD must say which checks read them. Owner: `/design-system enemies`.
