# ADR-0001: Terrain collision is built from the room grid, one shape per face segment

## Status
Accepted

## Date
2026-11-22

## Last Verified
2026-11-22 (spikes and an engine-specialist review run in this container on Godot 4.7.2, headless; the owner's local editor version was not checked)

## Decision Makers
Project owner (chose the T4 approach, 2026-11-22); Claude (author); `godot-specialist` (validation, 2026-11-22: two blocking findings, both addressed below).

## Summary
The terrain pipeline needs room collision that follows the 6 px grid, keeps shapes at or below the face-segment count with each segment inside one shape (T4), tells the controller a face's material and never changes at runtime. Decision: the painted grid is the only authority; collision is built from it when a room is built, as one overlapping rectangle per exposed face segment in a `StaticBody2D`, and is never stored; a face's material is looked up from the grid over the body's span of the face, not carried by a shape.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Physics (2D collision), Core (scene and resource layout) |
| **Layer** | Foundation |
| **Knowledge Risk** | HIGH (post-cutoff version; `docs/engine-reference/godot/` covers none of 2D collision beyond one 4.7 signature change) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/physics.md`, `breaking-changes.md`, `deprecated-apis.md` |
| **Post-Cutoff APIs Used** | None called. `TileMapLayer` (4.3) is a painting surface only. 4.7.2 has `CollisionShape2D.one_way_collision_direction` and a `direction` argument on `PhysicsServer2D.body_set_shape_as_one_way_collision()` (4.7 reference); shapes here keep the default direction and none is rotated |
| **Verification Required** | The engine behaviour claimed here rests on the spikes and the specialist's runs below (NOT SOURCEABLE from the reference); re-run them after any engine upgrade. The corner and seam criteria in the GDD run on a built room before this ADR is Accepted |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | A later ADR for how baked trim is stored and drawn and the per-room node ceiling (terrain GDD Open Question 1, second half; each collision shape is a node and counts toward it); the controller's `no_cling` skip (ability gating Open Question 2) |
| **Blocks** | The first terrain story and story 007 (rooms, saves, map): they cannot start until this ADR is Accepted |
| **Ordering Note** | ADR-0002 (display migration) is independent; the first terrain story needs both. Collision stays 6 px and unscaled whatever the display ADR does: the camera zoom scales the view, never a shape |

## Context

### Problem Statement
The terrain GDD fixes what must be true of room collision: a 6 px grid of solid, one-way and empty tiles (rules 2, 3); no change at runtime (rule 4); a material per face segment, two sides of a wall may differ (rule 6); collision shapes at most the face-segment count with each segment inside one shape (T4, rule 15); checks that read room data, never art (rule 8). It leaves open how collision is stored and built. The first terrain story cannot start without that answer.

### Constraints
- Godot 4.7.2, GDScript, 2D physics (Godot Physics 2D; Jolt is 3D only).
- The Seeker and enemies are `CharacterBody2D` on physics layer 1 (`LAYER_WORLD`), swept bodies.
- A room build has a 0.10 s budget for everything (rooms and transitions R3).
- The tools spec's layout hash, checks and bake read room data, not physics nodes.

### Requirements
- Every collision face lies on a grid line; shapes are axis-aligned rectangles.
- Shapes at most face segments; each face segment inside one shape (T4).
- A face's material is readable at a contact; a one-tile wall may differ on its two sides.
- One-way tiles collide from above only.
- No catch at `run_speed` 140, `dash_speed` 370, `max_fall_speed` 480, `fast_fall_speed` 640 and `wall_slide_speed` 60 (GDD seam criterion).

## Decision

The grid is the only authority; collision is derived from it every time a room is built and is never saved.

1. **The painted grid.** Rooms are painted in a `TileMapLayer` with a 6 x 6 `TileSet` of two tiles, solid and one-way, and **no physics layer**. The layer must also set `collision_enabled = false` (it defaults to true), so a physics layer added to the `TileSet` later cannot silently create per-tile shapes. Everything else the GDD calls room data (face material overrides, placement records, `crack` marks, the dressed baseline, move records, the production state) lives in one `RoomTerrainData` resource on the room root, because a tile's custom data is per tile and a face material is per face. Cells outside the grid count as solid for exposure (no face is made at the grid edge); the author paints the room's border cells solid, and an exit is a gap of empty cells in that border.
2. **Faces.** One pass over the grid finds every exposed face segment: a maximal run of one material and one tile kind along one face. A solid cell's side is exposed when its neighbour is empty; a one-way cell has only its top face, and it is exposed only when the cell above it is empty. A one-way cell with a solid or one-way cell above it has no face and no shape; one resting on a solid cell keeps its top face.
3. **Collision is built at room build.** `TerrainBuilder.build()` makes one `RectangleShape2D` per face segment, as an **overlapping strip** running inward from the segment: its length is the segment's, its depth is the smaller of `skin_tiles` (4) and the thinnest solid depth beneath the segment (at least one tile). Strips may overlap each other at corners; overlap is harmless to collision. So shapes equal face segments by construction and every segment lies inside exactly one shape (T4, rule 15). The interior is not built.
   - Solid strips go in one `StaticBody2D` (physics layer 1).
   - One-way strips (one tile deep, `one_way_collision = true`) go in a **second** `StaticBody2D`, so a drop-through can disable one body or one layer without dropping the player through solid ground (specialist run: a collision exception on a shared body drops the body through the solid part too).
   - Output order is sorted by (side, line, start) so two builds compare equal.
4. **Materials are looked up over the body's span, not at one point.** A shape holds no material. A `KinematicCollision2D` position is the body's lowest corner of the contact, not the middle of it (specialist run: 24 px wall, 10 x 22 body, two contacts at the feet and 0.92 px above), so a single-point lookup would read the cell at the feet, and on a tile boundary the cell below the body. Instead `Terrain.face_materials(body_rect, normal)` returns the material of every face cell the body overlaps along the contact, ordered along the face; which material wins at a boundary (for example `no_cling` over `plain`) is ability gating's rule for the controller's `no_cling` skip (its Open Question 2), not this ADR's. The caller must first check that the collider is the terrain body (`get_collider_rid()`): a door, breakable wall or moving platform is its own body (rule 4) and has no terrain face.
5. **Never stored.** The built bodies are not saved in a room scene and have no bake record, so a stale collision cannot exist. The room check and the trim bake read the grid, never the physics nodes (GDD rule 8).
6. **Static for the life of the room.** The bodies are built before the room is shown and not touched while it is live (rule 4). Because the interior is not built, any entity that can end up inside the 4-tile skin must be a swept `CharacterBody2D`, and spawn, respawn and arrival points must lie in empty cells (the room check already rejects an object that overlaps solid tiles, terrain Edge Cases). A zero-gap placement flush against a face is also unsafe: a body placed exactly flush against a ledge end and then falling stops dead when its feet reach the ledge top (specialist run, a zero-separation cast artefact, one rectangle or many), so placement keeps at least 0.1 px of gap.

### Architecture Diagram
```
TileMapLayer (solid, one-way; no physics, collision_enabled off)  +  RoomTerrainData (face map, records, marks, baseline)
        |                                                              |
        +--------------------- TerrainBuilder.build -------------------+
                                  |
        faces: one pass -> exposed segments (side, line, start, end, material)
                                  |
          +-- StaticBody2D "TerrainSolid"   (layer 1)  RectangleShape2D strip per solid segment
          '-- StaticBody2D "TerrainOneWay"  (layer 1)  RectangleShape2D strip per one-way top, one_way_collision
Seeker (CharacterBody2D) -- contact --> Terrain.face_materials(body_rect, normal) --> RoomTerrainData
```

### Key Interfaces
```gdscript
class_name TerrainBuilder
## Builds a room's collision from its painted grid. Pure and deterministic.
static func build(layer: TileMapLayer, data: RoomTerrainData) -> Array[StaticBody2D]
## Exposed face segments of a padded solid/one-way grid: [side, line, start, end, material].
static func faces(cells: PackedByteArray, width: int, height: int) -> Array

class_name Terrain  # a node on the room root, in group "terrain"
## The materials of the face cells [param body_rect] overlaps along a contact with [param normal],
## ordered along the face. Empty when the contact is not with terrain.
func face_materials(body_rect: Rect2, normal: Vector2) -> PackedStringArray
```

### Implementation Guidelines
- Collision shapes **must** be axis-aligned `RectangleShape2D` on the 6 px grid, in `StaticBody2D`s on physics layer 1; **must never** be rotated or scaled (collision stays 6 px whatever the camera zoom).
- The `TileSet` **must not** have a physics layer and the layer **must** set `collision_enabled = false`; per-tile shapes **must never** be created.
- Collision **must never** be saved in a room scene and **must never** be edited at runtime.
- A shape **must never** carry a face material; read it through `Terrain.face_materials`, after checking the collider is the terrain body.
- One-way strips **must** live in their own body, and **must** keep the default one-way direction.
- The builder **must** be deterministic (sorted output) and the room check **must** assert T4 on it (shapes equal segments, each segment inside one shape), failing the room by name if it does not hold.
- The face pass **must** read a padded `PackedByteArray` with inlined neighbour tests, not a function call per neighbour (about 5 times slower in the spike).
- Checks and the trim bake **must** read the grid and `RoomTerrainData`, never the built bodies.
- The controller **must** run the seam criteria with `floor_snap_length` 1.0 and `safe_margin` 0.08 (the project defaults the specialist measured); raising `floor_snap_length` changes ledge-fall behaviour on one-tile drops.

## Alternatives Considered

### Alternative 1: Per-tile physics shapes from a `TileMapLayer` physics layer
- **Description**: paint tiles with a physics polygon on each and let the engine build shapes.
- **Pros**: no builder code; collision and paint are one thing; editor-native. It does not catch on flat faces (spike).
- **Cons**: one shape per solid tile (7,416 for the borders of one 10-screen room, built in about 35 ms against about 14 ms for 4 merged shapes in the spike, each figure including one physics-frame wait), which breaks T4 by construction; a face material cannot sit on a tile because custom data is per tile, not per face.
- **Rejection Reason**: fails T4 and rule 6. It is not rejected on cost: 7.4k static shapes is not a runtime problem in Godot Physics 2D.

### Alternative 2: Merged rectangle partition of the solid mass
- **Description**: maximal horizontal runs per row, merged vertically when both ends match.
- **Pros**: fewest shapes; simple; about 5 ms.
- **Cons**: splits a vertical face across two rectangles wherever adjacent rows share one end (a pillar flush on a wider block); a strict partition cannot keep every face of an L whole. Found by the engine specialist.
- **Rejection Reason**: breaks T4 for ordinary shapes. A relaxed T4 ("no catch on a straight face") was the other way out; the owner chose to keep T4 and use overlapping strips.

### Alternative 3: Bake collision and save it in the room scene
- **Description**: the same shapes, stored as `CollisionShape2D` nodes in the scene.
- **Pros**: nothing to compute at load.
- **Cons**: a second copy of the room that can go stale; a bake record, a verify step and merge conflicts in scene files, to save about 20 ms.
- **Rejection Reason**: the saved time is small and the staleness risk is real.

### Alternative 4: Hand-placed collision shapes, no grid
- **Description**: designers place rectangles and polygons directly.
- **Pros**: no tooling; arbitrary shapes.
- **Cons**: no grid guarantee, no face map, checks cannot read tiles (rule 8), edges drift off grid lines.
- **Rejection Reason**: contradicts rules 2, 6, 8 and level design's on-grid gate figures.

## Consequences

### Positive
- One source of truth: collision cannot be stale, and the layout hash covers it.
- Shape count equals face-segment count (230 for a 10-screen test room), so T4 holds by construction and is checkable on the output.
- The room check, the trim bake and the builder share one face pass.
- The editor stays fast: no physics in the tileset.

### Negative
- A `TerrainBuilder` and a `Terrain` node must be written and tested.
- More shapes than a partition (equal to the segment count), and strips overlap.
- The controller must call `face_materials` at a wall contact; ability gating decides the precedence.
- Face materials need their own editor overlay since they are not on the tiles.
- The interior of every mass has no collision (see Implementation point 6).

## Risks
- **Seam or corner catches in a case the spikes missed.** The spikes cover flat floors, ceilings, long flush faces and one pillar-on-block shape. Concave and convex corners, ledge lips and undersides, a body whose 22 px height spans a material change and run speed against a wall are not covered. Mitigation: the GDD's corner and seam criteria run on a built room before this ADR is Accepted; they decide it.
- **An entity inside the skin.** A teleported, crushed or non-swept body (a `RigidBody2D`, an `Area2D`-sensed projectile without continuous cast, a noclip debug mode) that ends up past the 4-tile skin finds nothing behind it. Mitigation: only swept bodies interact with terrain; spawn and arrival points in empty cells; skin depth is a knob (`skin_tiles`).
- **Contact point semantics.** The contact position can be a vertex of the moving shape, within `safe_margin` (0.08 px) of the face (specialist run). Mitigation: the lookup uses the body's span, not a point, and probes 0.5 px into the face.
- **Build cost grows with grid area** (about 12 ms for the face pass on 800 x 45 tiles with inlined reads; strips 4 ms; shape build 3 ms; the cost of reading 36,000 cells from the `TileMapLayer` is not measured). Mitigation: end-to-end measurement from the layer is a validation criterion; a checkerboard room is the worst case.
- **Engine upgrade changes behaviour.** The claims rest on tests in 4.7.2, not the reference. Mitigation: the spikes are kept in `prototypes/terrain-collision-spikes/` and re-run on every engine upgrade.
- **Non-axis-aligned normals.** Rectangle-against-rectangle should only give axis-aligned normals (none seen). Mitigation: one assertion in the corner test.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| terrain-pipeline.md | Rules 2, 3: a 6 px grid of solid, one-way, empty tiles | The `TileMapLayer` holds exactly those kinds on a 6 px grid |
| terrain-pipeline.md | Rule 4: terrain never changes at runtime | The bodies are built once before the room shows and never touched |
| terrain-pipeline.md | Rule 6: a material per face segment, two sides may differ | Materials live in a face map and are read over the body's span of the face |
| terrain-pipeline.md | T4, rule 15: shapes at most face segments, each segment in one shape | One overlapping strip per segment; the room check asserts it on the output (spike: 11 segments, 11 shapes on a pillar-on-block room) |
| terrain-pipeline.md | Rule 8: checks read data, never art | Checks read the grid and `RoomTerrainData`, never the built bodies |
| terrain-pipeline.md | Seam criterion: no catch at the listed speeds | Spikes: none on floor, ceiling and a long flush face at 60, 140, 370, 480 and 640; corners decided by the GDD criteria |
| terrain-pipeline.md | Open Question 1: how collision is built | This decision (trim storage and the node ceiling go to a later ADR) |
| terrain-tools-spec.md | Sections 1 and 2: layout hash, writes, baked output | Collision is not a baked output: nothing to hash, verify or commit |
| ability-gating.md | Rule 14: the controller reads the face material at a wall contact | `Terrain.face_materials(body_rect, normal)`; precedence stays ability gating's |
| rooms-and-transitions.md | R3 `build_time` 0.10 s | About 20 ms for faces, strips and shapes on a 10-screen room, excluding the layer read |

## Performance Implications
- **CPU**: about 12 ms face pass, 4 ms strips and 3 ms shapes on an 800 x 45 tile grid in GDScript, headless (spike, 230 segments); one span lookup per wall contact per frame. End-to-end from the `TileMapLayer` not yet measured.
- **Memory**: one shape per face segment (hundreds per large room) instead of thousands of per-tile shapes.
- **Load Time**: tens of ms inside the 0.10 s `build_time`, with the trim build and everything else still to fit.
- **Network**: not applicable.

## Migration Plan
No terrain code exists yet. The existing test rooms build their own rectangle shapes in code (`art_style_test_room.gd`, `_add_box`) and stay test rooms (terrain Open Question 5); the first region room is built with this pipeline. `faces` and the strip rule can be lifted from `prototypes/terrain-collision-spikes/`.

## Validation Criteria
- T4 unit test on the builder: the GDD's one-screen room gives 4 shapes and 202 edge tiles; a pillar flush on a wider block gives equal segment and shape counts and the long face inside one shape.
- The seam criterion on a built room at the five listed speeds (displacement within 0.5 px per frame, distance from the face within 1 px), plus the corner cases listed under Risks, one assertion for axis-aligned normals, and a zero-gap placement case.
- A builder run from a real `TileMapLayer` of 36,000 cells within 20 ms on the owner's machine, and a checkerboard worst case recorded.
- The spikes re-run on every engine upgrade.

## Open verification items at acceptance
Accepted 2026-11-22 by the project owner, before these ran; each must be closed by the first terrain story that builds a room, and a failure reopens this decision:
- The GDD's corner and seam criteria on a built room (concave and convex corners, ledge lips and undersides, run speed against a wall, a body spanning a material change), with one assertion that normals are axis-aligned and a zero-gap placement case.
- ~~The builder measured end to end from a real `TileMapLayer`~~ Measured 2026-11-22 (`tests/performance/terrain_build_bench.gd`, software container): a typical 800 x 45 room, 8,878 solid cells, 230 shapes, builds in about 27 ms (layer read 2, the rest faces, strips and bodies), over the 20 ms aim and well inside the 100 ms budget; the checkerboard worst case (21,708 cells, 57,168 shapes) takes about 680 ms. The owner's machine decides the aim. The face pass is the place to optimise if it matters.
- `Terrain.face_materials` agreed with ability gating's precedence rule for the `no_cling` skip (its Open Question 2).

## Related
- `design/gdd/terrain-pipeline.md` (Open Question 1, rules 2-8, 15, T4)
- `docs/architecture/terrain-tools-spec.md`
- `design/gdd/ability-gating.md` (rule 14, the `no_cling` skip, Open Question 2)
- ADR-0002 (display migration), to be written
- Spike results (Godot 4.7.2, headless, this container, 2026-11-22), scripts in `prototypes/terrain-collision-spikes/`:
  - `seam.gd`: floor, 160 tiles, a 10 x 22 body at 140 and 370 px/s: real velocity exact and no vertical drift for one merged rectangle, per-tile rectangles, per-tile convex polygons, a `TileMapLayer` physics layer and a segment shape.
  - `wall_cost.gd`: wall slide at 60 and fall at 480 along a 4-tile-wide wall: step per frame exact for merged and per-tile; ceiling dash at 370 exact; 7,416 border cells as tile physics shapes built in 35 ms against 14 ms for 4 merged shapes.
  - `contact.gd`: a contact position lies on the face line along the normal (x 24 for a wall at 24, y 600 for a floor at 600). It does not show where along the face the point is (specialist runs: the lowest corner of the body).
  - `strips.gd`: overlapping strips on a pillar flush on a wider block: 11 face segments, 11 shapes; slide down the long flush left face exact at 60, 480 and 640 px/s; run along the block top at 140 exact; fall onto the floor and run.
  - `strips_cost.gd` and `faces_fast.gd`: 800 x 45 tiles, 230 segments: face pass 61.6 ms naive, 12.3 ms inlined; strips 3.7 ms; shapes 2.7 ms.
  - Specialist runs (`scratchpad/val/`, not kept): 640 px/s fall exact; a 6 px one-way shape lands a 640 px/s fall and passes a 480 px/s rise; a zero-gap flush placement catches; a shared body drops the body through solid when excepted for one-way.
