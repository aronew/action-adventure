# Terrain tools spec

> **Status**: Draft, 2026-11-19. Created by the sixth `/design-review` of `design/gdd/terrain-pipeline.md` (full: MAJOR REVISION NEEDED; the owner chose to move the mechanics here)
> **Implements**: terrain pipeline rules 10-13, T3 and T5, and the build gate in its States section
> **Owner**: tools (tools-programmer, engine-programmer); the GDD owns every rule and bound this spec meets
> **Engine**: Godot 4.7.2. Every engine claim marked *(unverified)* comes from the reviewers' knowledge of Godot 4.3 and is not covered by `docs/engine-reference/godot/`; the collision ADR (GDD Open Question 1) confirms or replaces it

## Purpose and limits

The terrain pipeline GDD says what must be true: the layout is approved and detected when it changes, trim is never older than its collision, art over a gate edge stays within `trim_overhang_max`, a block moved with the editor's move tool carries its dressing, flags are recomputed, and release builds ship only Dressed rooms. This spec says how the tools make that true. If the two disagree, the GDD wins and this spec is fixed. Nothing here is a design rule: a change to a value or behaviour the player or designer can observe goes to the GDD first.

This spec is a draft. Its algorithms are proven by the fixture tests below in the prototype room (GDD Open Question 1), not by review.

## 1. The room-check command and who writes

- **Room-check command.** A headless command (`godot --headless --script <room_check>` *(unverified flags)*) runs the layout checks, the dressing checks and the bake for every room that needs them, and writes room data. It runs on demand in the editor and as the step before every export.
- **Export.** The export reads room data and writes none. An export plugin (`EditorExportPlugin` *(unverified)*) only verifies: every room's stored layout hash and bake record match its data, and the room's state is allowed for this build (release: Dressed only; dev and playtest: Approved or Dressed). A mismatch or a disallowed state fails the export and names the room. If the plugin cannot abort an export, the build script runs the verify as its own step and the export only follows a pass.
- **Editor save.** Saving a room in the editor runs the bake and the dressing checks for that room only, and the layout checks when the layout changed. The save hook guards re-entry: a write the hook makes does not trigger the hook again.
- **Writes.** Only the save hook and the room-check command write room data. When either opens a flag it writes the cleared `dressed` back, so the editor and the build agree. A CI run that writes room data fails, because committed data must already be current. A dirty tree after the room-check command means someone committed stale data.
- **Baked output.** Baked trim is derived data, keyed by the room's layout hash and biome. Whether it is committed or cached outside git is the ADR's call. If it is not committed, CI keeps a cache keyed by that hash, so a clean checkout does not rebake every room.

## 2. Layout hash, encounter data and check inputs

- **Layout hash.** A hash over a canonical, ordered encoding of the GDD's layout (rule 10): bounds and exits, the tile grid, face materials, placement records, `crack` marks, and the objects a layout check reads. Any reordering of equal data gives the same hash. A change to the hash returns the room to Block-out (GDD States).
- **Encounter data** (spawn points, patrol ranges) is hashed separately and never moves the room's state by itself (GDD rule 10).
- **Declared inputs.** Each check declares its inputs: room data fields, encounter data, and named keys in tuning files (`player_config.tres:hitbox_size`, the gate-knob file's `gap_margin`, and so on). The tool hashes the declared keys, not whole files, so an edit to an undeclared key changes nothing.
- **Result cache.** Each check's result is cached by (check id, check version, hash of its inputs). Before a build, only checks whose cache key changed re-run. A pass keeps the room's state, and a failure returns it to Block-out and names the check (GDD rule 10).
- **Dry run.** The room-check command accepts proposed tuning values and reports which rooms and gates would fail, without writing anything (GDD T1 Edge). It is run before a margin or controller retune is committed.

## 3. Bake

- **When.** On every editor save of the room, and in the room-check command for any room whose layout hash or biome differs from its last bake record. Each bake records the layout hash and biome it was baked from.
- **Ownership.** Every baked pixel is tagged with the face (segment side) it was emitted for. T3 reads the tags (section 4). The tags live with the baked output and are not shipped.
- **Bound at gates.** On each edge range and `no_cling` segment the bake keeps the face's trim within `trim_overhang_max`. In order of preference:
  1. Pick an edge-art variant whose profile stays within the bound.
  2. Otherwise, cut the art along the bound line, tapering from the free profile to the bound over one tile (6 px) beyond each end of the range.

  At a range end no step in the silhouette may exceed 1 px. The bound must not cut into a signature's relief: signatures on `no_cling` and groove segments are authored within the bound.
- **Corners.** At a convex corner the two faces' art is mitred, or a corner piece from the biome is used. At a concave corner each face's art stops at the bisector, so the two do not stack.
- **Short faces.** A face shorter than the edge art's minimum readable length (set with the art bible) gets the biome's short-face piece, not a crop that loses the painted line.
- **Signatures.** Grooves are phased from the start of each range, and a partial groove under half a period is dropped. The pane's look is drawn on its own layer over the pane footprint. It is not baked trim, and T3 does not measure it.
- **Determinism.** Same layout and biome, same bytes. The bake reads source art, never VRAM-compressed imports.

## 4. T3 measurement method

- **Source.** The measurement uses the source PNG alpha of each edge-art piece and prop. Imported, compressed textures are never used, and the GPU is never used. Headless CI uses the dummy renderer *(unverified)*, so nothing that renders can be part of a check.
- **Per-asset profile.** At import, each edge-art piece and each "reads solid" prop gets an overhang profile: for each game px along its edge, how far its silhouette (8-bit alpha at least `round(alpha_solid x 255)`) reaches past its painted line. The profile is resampled to game scale with one fixed kernel (box filter over the source pixels each game px covers) and rounded up to whole game px.
- **Baked trim.** Since the bake places each piece and records its owning face, T3 on baked trim is a lookup over profiles, not a pixel flood. A failure is a bake defect (GDD rule 11).
- **Placed props.** A prop is measured from its profile and its placed transform (position, flip; rotation is not supported for "reads solid" props). It is measured when its body touches or crosses the collision line within the stretch. Its silhouette counts against the nearest face, split at a concave corner's 45-degree bisector (GDD T3).
- **Distance.** It is measured to the far edge of the farthest counted game px, so a pixel touching the line counts 1.
- **Cost target.** T3 for a 10-screen room within 100 ms on the owner's machine. At 1x a 10-screen room has about 100 stretches of about 130 x 20 px. A GDScript 8-neighbour flood over that was estimated at 1-3 s at 1x and 15-40 s at the 4x draw, which is why the method is profile-based.

## 5. Flags

- Three kinds, all recomputed from room data on every run (GDD rule 12): overhang, off-ground, and undressed new ground.
- A flag's identity is (kind, prop or face id). The editor shows every open flag on the collision overlay. No dismiss action exists.
- **Setting `dressed`.** It is refused while an overhang or off-ground flag is open or while the trim is unbaked. An open undressed-new-ground flag does not block it: recording the baseline closes that flag (GDD rule 12). Otherwise it records the dressed baseline (section 6) and the room becomes Dressed.
- **Ground check geometry.** Each "reads solid" prop's catalogue entry holds its **walkable line** (a horizontal segment in prop space) and its **body** (an axis-aligned box in prop space). The check compares them with the tile grid after the placed transform.

## 6. Moved blocks and new face (T5)

- **Baseline.** When `dressed` is set the tool stores a 1-bit-per-tile mask for solid tiles and one for one-way tiles (about 4.5 KB each for a 10-screen room). From the mask it derives the face tiles. The masks are editor-only and stripped from exports.
- **Move records.** The editor's move operation writes one record per moved block into the room data: the block's baseline tiles, per tile kind, and its total shift since the baseline. A second move of the same block adds to the shift. A record whose shift passes `move_max` on either axis is dropped, and the block counts as new ground. All records are cleared when `dressed` records a baseline. There is no detection from the tile diff: a tile-by-tile repaint, or a move made outside the tool, has no record and counts as new face (GDD rule 13, T5).
- **Recompute.** The tool shifts each record's block back by its shift in a virtual copy of the grid (its current tiles are the record's baseline tiles plus the shift; any tile of the block's area added or removed since is an ordinary change), derives face tiles, and computes `new_face = |F_now' \ F_base|`.
- **Two-row case.** A 6 x 2 ledge moved down one tile has a record with shift (0, 1). Shifting it back restores the baseline, so new face is 0 and the carry is one tile.
- **Carry.** For each recorded block:
  - Props of either kind whose body or walkable line lies within `trim_overhang_max` of the block's tiles in the baseline move with it.
  - Record ranges that lie wholly on the block's faces move with it.
  - Objects whose collision rests on the block move with it.

  A range that lies partly on the block is left in place, and the gate check then fails and names it (GDD rule 13). The carry is written in the same save, and the editor's change report lists every carried item with its shift.
- **Move tool.** It is the only path to a move record, so it is part of the pipeline, not a convenience. Moving a block with it carries the items listed under Carry in the same save.

## 7. Prop catalogue

- Each prop entry holds its mark ("reads solid" or "decoration"), its walkable line and body (for "reads solid"), its overhang profile, and a hash of its source texture.
- An unmarked prop cannot be placed. A change to a prop's source texture hash clears its mark and asks again at import.
- **Advisory report, not a flag.** It lists any "decoration" prop whose alpha covers an edge range by more than `trim_overhang_max`, so a mis-mark shows up in review.

## 8. Budgets (targets, to be measured in the prototype room)

| Step | Target | From |
|---|---|---|
| Save a tile edit to play the room, checks included | about 5 s | GDD Game Feel |
| Bake a 10-screen room | about 2 s | GDD Game Feel |
| T3 on a 10-screen room | 100 ms | section 4 |
| Room-check command, 100 rooms, nothing changed | under 10 s (all cache hits) | section 2 |
| Room-check command, one tuning key changed | under 2 min | section 2 |

## 9. Tool acceptance criteria

Moved from the GDD on 2026-11-19. Each is **[Auto]** unless marked.

- **GIVEN** a room open in the editor, **WHEN** one tile is changed and the room is saved, **THEN** its trim is re-baked from the new collision before the room is next played, and the save hook runs once.
- **GIVEN** a room whose layout hash differs from its last bake record, including one never approved, **WHEN** the room-check command runs, **THEN** it re-bakes the room. **GIVEN** a room whose hash and biome match the record, **THEN** it is not re-baked.
- **GIVEN** a Dressed room whose dressing was changed outside the editor so that a "reads solid" prop covers an edge range by 5 px, **WHEN** the room-check command runs before a release build, **THEN** it raises the flag, writes the cleared `dressed`, and the release export refuses the room by name. **WHEN** the export runs, **THEN** it leaves every room data file byte-identical.
- **GIVEN** a dev build with an Approved room whose flags are open, **THEN** the room is accepted.
- **GIVEN** a Dressed room, **WHEN** a block is moved with the move tool, **THEN** a move record (baseline tiles and shift) is written in the same save and cleared when `dressed` is next set. **GIVEN** the same block moved by editing tiles directly, **THEN** no record exists and the change counts as new face.
- **GIVEN** `player_config.tres:hitbox_size` is changed, **WHEN** the room-check command runs, **THEN** the passage check re-runs on every Approved and Dressed room, and a check that does not declare `hitbox_size` is a cache hit. **GIVEN** an undeclared key changes, **THEN** no check re-runs.
- **GIVEN** a dry run with `gap_margin` 16, **THEN** it lists every room holding a dash gap as "gate type unbuildable" and writes nothing.
- **GIVEN** a prop whose source texture changed, **WHEN** the pack is re-imported, **THEN** its mark is cleared and the import asks for it.
- **GIVEN** the budgets in section 8, **WHEN** measured on the prototype room on the owner's machine, **THEN** each is met or the miss is recorded. **[Play]**

## 10. Open items

1. **The engine hooks** need checking against 4.7: the save hook, an abort from `EditorExportPlugin`, and the headless dummy renderer. Owner: godot-specialist, with the collision ADR.
2. **Baked output** needs a decision: committed, or cached outside git. Owner: the collision ADR.
3. **Minimum readable face length and corner pieces**, per biome. Owner: art bible and technical artist.
4. **Optional authoring aid** for level design: drop a gate marker (type plus one tile) and derive the record's ranges by walking the faces, stored as an overridable cache (sixth design review, recommended). Owner: tools, after the first gate-check story.
5. **Rotation of "reads solid" props** is unsupported in the profile method. Revisit if the art needs it.
