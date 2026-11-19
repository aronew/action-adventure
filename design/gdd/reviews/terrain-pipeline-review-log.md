# Review Log: Terrain pipeline

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 3 | Recommended: 7
Summary: The grid choice, the T1 on-grid tables, T3 and T4 arithmetic and every registry value reproduce, and the code claims (air-only `_nudge_onto_ledge`, 10 x 22 hitbox, `_floor_ahead`) hold. The weak spots are in the process spec: the production-state machine contradicts rule 13 (re-bake and dressing flags in a Block-out room that has no trim), the approval fingerprint omits the objects and gate marks the layout checks read, and level design's workshop criterion ("at most gap_min + 4 px", 149) cannot pass on the 6 px grid.
Prior verdict resolved: First review
Findings:
- [BLOCKING] States / rule 13 / Edge Cases / AC: an edited Dressed room "returns to Block-out" yet its trim re-bakes and dressing is flagged, while Block-out is defined as black tiles only and the bake runs only from Approved; whether a one-tile edit needs a fresh play review is undefined (Game Feel: small fixes stay small)
- [BLOCKING] Rule 10 / rules 6, 7, 11 / T3: the fingerprint covers collision and face materials only, not the objects (hazards, hittables, anchors, panes, kill planes) the layout checks read; "gate edge" and "cling-wall gate" marks are not in rule 6's data model
- [BLOCKING] Dependencies / rule 16: level design's workshop AC (line 336, "at most gap_min + 4 px" = 149) has no on-grid width (144 or 150); reword level design rule 11 and its AC
- [RECOMMENDED] T2: vacuous for on-grid measurements, a silent tuning change (pogo_far_ext 14 to 18) for off-grid hit-area edges; state raw or rounded, or drop T2 and the `band_on_grid` registry entry
- [RECOMMENDED] Rule 6: one-way tiles have only a top face; sides and underside are not collision edges
- [RECOMMENDED] Overview / Dependencies: four "materials" named, rule 6 defines two; the bisque pane is an object with plain faces, so "the pane's material" is undefined
- [RECOMMENDED] Rule 1 / AC 1: project.godot is still 480 x 270 viewport stretch; only the art-style test room switches at runtime; the display migration has no owner or ADR scope
- [RECOMMENDED] Edge Cases: no minimum passage size for the 10 x 22 Seeker (crouch 14)
- [RECOMMENDED] Acceptance Criteria: "terrain node counts equal" undefined, "every speed it can reach" and "full camera sweep" unenumerated, config-change trigger unnamed, rule 7 AC compound; ADR scope omits trim storage and drawing
- [RECOMMENDED] States / build gate: only Block-out is refused, so whether an Approved but undressed room may ship is unspecified
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); T1 Output Range wording; foreground layer (1.20) missing from the draw order; systems index says Core in row 4 and Foundation in the design-order table; kiln-city-visual-direction.md says "Target 480x270 pixel art"; T4 bound is met by one shape per edge tile; Team Cherry quotes not verifiable offline
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 4d560273cf24ea7fd7a13cebd4517a5e593a02fe
Reviewed-Content-Hash: design/registry/entities.yaml bd4b8492df91083d66e725407b357f94e01b1aa8
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md 1256d45ea24e8db16c22e17785aa6e2a51343676
Reviewed-Content-Hash: design/gdd/level-design.md dd6e3796d01b2ca99ab988bd041fdc28d5d2c6e9
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b
Reviewed-Content-Hash: assets/environment/PACK-README.md 86f99965520d3b65a0a60c4555d0b5d4786b1af8
Reviewed-Content-Hash: src/test_rooms/art_style_test_room.gd 00440efe8619fd71f2a9914de7891dcce312feae

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 6
Summary: All three first-review blockers are resolved. Rule 13, the States table and the Edge Cases now agree, the fingerprint covers gate marks and objects, and level design rule 11 and its criterion say 150 px. Every registry value, T1-T4 output and code claim reproduces. Two process gaps remained: the Dressed state had no deliberate entry (a baked room with no dressing counted as Dressed and could ship), and the gate-mark and segment duties rule 6 gives level design and ability gating were absent from both Approved GDDs. Both were revised the same day (owner: a `dressed` artist sign-off that survives a flag-free re-bake; the bake runs on every editor save and at every build), along with 4 of the 6 recommendations; the GDD awaits re-review in a fresh session.
Prior verdict resolved: Yes (all 3 prior blockers)
Findings:
- [BLOCKING] States / rules 12-13 / AC: Dressed entered when "the dressing pass finishes", which nothing marks; an undressed baked room is Dressed and ships; bake trigger undefined
- [BLOCKING] Dependencies / rule 6: level design (authors gate marks) and ability gating (F1-F11 fail on a missing mark) not told; level design row said "No (provisional)", ability gating said "bisque pane material"
- [RECOMMENDED] Rule 10 / Edge Cases: config hash names three file types; the gate-margin and band "data file" does not exist
- [RECOMMENDED] States: "build" vs editor play undefined; a new room cannot be play-reviewed if every build refuses Block-out
- [RECOMMENDED] Rules 6-7: only cling_wall + no_cling rejected; climb_wall and climbable on no_cling unchecked
- [RECOMMENDED] T3 / rule 5: trim undershoot unbounded (Seeker could stand on air); open, Open Question 11
- [RECOMMENDED] AC (node count): compares two particular rooms and depends on the ADR; open, Open Question 11
- [RECOMMENDED] Rule 10: fingerprint omits room bounds and exits; enemy spawn points not in rule 4's object list
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); T4 met by one shape per edge tile; systems index Core vs Foundation; only two legal dash widths (150, 156); route minimum covers the Seeker only; a tuning change can demote every Dressed room at once
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md e2c56f00842b47ecfd78f6458e6ba471780410ad
Reviewed-Content-Hash: design/registry/entities.yaml 81257fdc2577f75fec1f661554d6561892157fff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md 1256d45ea24e8db16c22e17785aa6e2a51343676
Reviewed-Content-Hash: design/gdd/level-design.md 6475e5be03118c5c5201575f2aad1dffe58fba03
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b
Reviewed-Content-Hash: assets/environment/PACK-README.md 86f99965520d3b65a0a60c4555d0b5d4786b1af8
Reviewed-Content-Hash: src/test_rooms/art_style_test_room.gd 00440efe8619fd71f2a9914de7891dcce312feae

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 7
Summary: Both second-review blockers are resolved, and every registry value, T1-T4 output and code claim reproduces. Two process gaps remained: nothing ran the overhang (T3) and rule 5 prop checks on a first dressing pass or a dressing-only edit, so a prop could cover a gate lip and ship as Dressed; and the single-valued `gate` mark could not serve a segment two gates measure, with the mark's extent along a face undefined. Both were revised the same day (owner: dressing checks on every editor save and every build, with flags that block or clear `dressed`; a placement record per gate listing face tile ranges), along with 5 of the 7 recommendations; the GDD awaits re-review in a fresh session.
Prior verdict resolved: Yes (both prior blockers)
Findings:
- [BLOCKING] Rules 12-13 / States / T3: no trigger for the dressing checks; Dressed requires "overhang check passed" but only a post-edit re-bake raises flags
- [BLOCKING] Rule 6 / T3: one `gate` mark per segment; two gates sharing a segment fail a legal room; mark extent and segment granularity undefined
- [RECOMMENDED] Rule 13: a flag-free re-bake keeps `dressed` however much ground is added (owner: `undressed_face_max` on total exposed face length)
- [RECOMMENDED] T4: `<= edge_tiles` is met by one shape per edge tile (now `<= face_segments`)
- [RECOMMENDED] Dependencies (also ability gating row 95): "F1-F11" need marks, but marks exist only for F1, F2, F3a, F3b, F6
- [RECOMMENDED] Edge Cases: "route" for the minimum passage has no computation (owner: check all empty space, `sealed` marks)
- [RECOMMENDED] T3: trim undershoot unbounded (still open, Open Question 11)
- [RECOMMENDED] AC (node count): compares two rooms, depends on the ADR (still open, Open Question 11)
- [RECOMMENDED] Rules 4, 11 / States: no bake stamp for never-approved rooms; Dressed Enter omits config re-check; exits not in rule 4's grid list
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); T1 float boundary tolerance; T3 convex corners; T1 margin-12 sentence garbled; systems index Core vs Foundation; only two dash widths legal; kiln-city "480x270 pixel art" awaits the art bible
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 00da8081b82132ff3a63dc2c4e41a8846638f930
Reviewed-Content-Hash: design/registry/entities.yaml 81257fdc2577f75fec1f661554d6561892157fff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md f1f696c36b337422707cb9a6e7dba122339a2972
Reviewed-Content-Hash: design/gdd/level-design.md 52842735dbde4856a4a76d0626c73a900f441d8f
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b
Reviewed-Content-Hash: assets/environment/PACK-README.md 86f99965520d3b65a0a60c4555d0b5d4786b1af8
Reviewed-Content-Hash: src/test_rooms/art_style_test_room.gd 00440efe8619fd71f2a9914de7891dcce312feae

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 7
Summary: Both third-review blockers are resolved (dressing checks on every save and build; a placement record per gate), every registry value, T1 and T4 output and code claim reproduces, and no registry conflict was found. Two new gaps sat in the revised area: T3 measured every opaque pixel at any height, so any prop standing on a gate ledge failed and blocked `dressed`, and its segment domain disagreed with the stretch-scoped bound; and records listed faces only by example while the check failed the room for any measured surface outside them (pit floors, standing floors). Both were revised the same day (owner: T3 measures trim and "reads solid" props over edge ranges only; a per-type table of edge, reference and scanned surfaces), with 5 of the 7 recommendations; the GDD awaits re-review in a fresh session.
Prior verdict resolved: Yes (both prior blockers)
Findings:
- [BLOCKING] T3 / rules 11-12: measure counts every opaque pixel at any height (no trim / reads-solid / decoration split); `overhang(segment)` vs stretch-scoped bound
- [BLOCKING] Rule 6: record faces only illustrated; F1 pit floor, F2 standing floor, F3a underside, F6a foot read but unlisted, yet the check fails the room
- [RECOMMENDED] Edge Cases (passage): one-way tile counted as a top bound, contradicting the one-way AC; `sealed` mark extent undefined
- [RECOMMENDED] Edge Cases (passage): `sealed` mark collides with level design's sealed alcove (renamed `crack`)
- [RECOMMENDED] Edge Cases (passage): 2 and 4 tile thresholds hardcoded from the hitbox, not read from `player_config.tres`
- [RECOMMENDED] Rules 12-13: flag lifecycle undefined (recomputed vs stored, who clears, build writes)
- [RECOMMENDED] Rule 13: net-total `undressed_face_max` lets removed ground offset new ground (now positional; moved masses count none)
- [RECOMMENDED] Acceptance Criteria: seam and passage ACs not measurable; ACs 285 and 289 compound
- [RECOMMENDED] T3 / AC (node count): trim undershoot and node-count ceiling still open (Open Question 11)
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); systems index Core vs Foundation; moving-platform grid wording; no forced play review after large edits
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 81aa9a21c05459b0dcd7c7cf2918bd62c4f1fe78
Reviewed-Content-Hash: design/registry/entities.yaml 81257fdc2577f75fec1f661554d6561892157fff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md b941616585bfbb663e3fe3d69ef07bef9bf4aa77
Reviewed-Content-Hash: design/gdd/systems-index.md 454aaf21891e63448f55d6411092b2c1988a9554
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b
Reviewed-Content-Hash: assets/environment/PACK-README.md 86f99965520d3b65a0a60c4555d0b5d4786b1af8
Reviewed-Content-Hash: src/test_rooms/art_style_test_room.gd 00440efe8619fd71f2a9914de7891dcce312feae

## Review — 2026-11-19 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean mode, single-session analysis)
Blocking items: 2 | Recommended: 5
Summary: Both fourth-review blockers are resolved (T3 scoped to edge ranges and "reads solid" props; a per-type record table), every registry value, T1 and T4 output and code claim reproduces, and no registry conflict was found. Two new gaps sat in the revised area: T3 never tied a measured pixel to its stretch, so read literally the far face's trim across every dash gap counted as overhang; and the stale-dressing flag covered all dressing, so hanging decoration would hold a recomputed flag open and `dressed` could never be set. Both were revised the same day (owner: T3 counts only the region attached to the collision line within the stretch; a ground check for "reads solid" props only, decoration never flagged), with 4 of the 5 recommendations; the GDD awaits re-review in a fresh session.
Prior verdict resolved: Yes (both prior blockers)
Findings:
- [BLOCKING] T3: measured pixels not attributed to a stretch; the farthest pixel on the normal is the far gap face's trim, so every dash gap fails
- [BLOCKING] Rules 12-13 / Edge Cases: stale-dressing flag (overlaps or floats) applied to decoration, contradicting "decoration never needs tiles"; no overlap threshold; not among the checks that run on save and build
- [RECOMMENDED] Rule 13 / Formulas: new-face count and `undressed_face_max` had no formula entry or safe range; moved-mass exemption unbounded (now T5, `move_max` 6)
- [RECOMMENDED] Rule 11 / T3: no route when baked trim exceeds the bound (bake now clips; a failure is a bake defect)
- [RECOMMENDED] Rule 12 / States: dev-build handling of open flags unstated; the build wrote to authored room data (now the room-check step writes, the export never does)
- [RECOMMENDED] Edge Cases (passage): one-way tiles' share of vertical and horizontal run length unstated
- [RECOMMENDED] T3 / AC (node count): trim undershoot and node-count ceiling still open (Open Question 11)
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard); systems index Core vs Foundation; game brief and narrative not re-read this pass (unchanged since review 4)
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md b2bebfc3863042ebec86ab87a4da53269bce1477
Reviewed-Content-Hash: design/registry/entities.yaml 81257fdc2577f75fec1f661554d6561892157fff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md 9f98ef91610c9e8d88782a20ea7f81d24bc4b289
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb

## Review — 2026-11-19 — Verdict: MAJOR REVISION NEEDED
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: game-designer, systems-designer, qa-lead, level-designer, godot-specialist, performance-analyst, technical-artist; creative-director (senior)
Blocking items: 6 | Recommended: 13
Summary: The player-facing design holds (grid, gate windows, T1, T4, registry values all reproduce; no registry conflict). All seven specialists found that T3's attached region fails at every concave corner (pit-floor trim measures the gap width), that T5's undefined "mass" leaves almost every real ledge unexempt, and that rule 12 and States deadlock `dressed` on the stored undressed-ground flag; the "small fixes stay small" promise is contradicted by prop flags and stale placement records. The creative director judged the revision approach non-converging (six rounds of prose algorithms, 74 KB) and recommended restructuring: keep player-facing guarantees in the GDD, move check and bake mechanics to a tools spec and the collision ADR, and freeze the GDD until the prototype room runs.
Prior verdict resolved: Partly (decoration-flag blocker resolved; the T3 attached-region fix covers the mid-air gap but fails at concave corners)
Findings:
- [BLOCKING] T3: attached region connects floor trim at concave corners (pit floor, cling-wall foot, wall-attached ledge) to the wall's stretch; Example l.155 and AC l.340 false once a pit floor exists
- [BLOCKING] T5 / rule 13: "mass" undefined; attached ledges never count as moved, so a one-tile move of a wall-attached 6 x 1 ledge flags (14 tiles)
- [BLOCKING] Game Feel / rule 13 / AC l.332: a one-tile platform move flags every "reads solid" prop on it and leaves gate placement records on the old tiles
- [BLOCKING] Rule 12 / States: "any flag" and "no flag open" deadlock against the stored undressed-ground flag closed only by `dressed`
- [BLOCKING] T3: "game px" scale and the 8-bit alpha threshold undefined
- [BLOCKING] Rules 10 / 13 / Edge Cases: spawn points and exits fingerprinted by rule 10 but absent from rule 13's edit list
- [RECOMMENDED] Structure: move T3 pixel method, T5 matching, fingerprints, config hash, flag lifecycle, save hooks and pre-export command to a tools spec and the collision ADR
- [RECOMMENDED] Rules 11-12: room check and bake as a headless pre-export command; per-key config hash; save-hook re-entrancy; check-time budget
- [RECOMMENDED] T3: resampling kernel, pixel-centre convention, source PNGs, per-asset profiles (flood fill estimated 1-40 s per 10-screen room)
- [RECOMMENDED] AC l.346: draw calls and fps to [Play]; fixed node ceiling (OQ 11)
- [RECOMMENDED] OQ 11: trim undershoot unbounded; move to an art-bible import bound
- [RECOMMENDED] Rule 11: hard 4 px clip leaves a visible step at range ends mid-face
- [RECOMMENDED] T1: read unrounded 164.4; k = 0 and open-ended windows; visible gap W - 2 x trim_overhang_max can read run-jumpable
- [RECOMMENDED] Edge Cases (passage): floor(h/ct)+1; headroom restarts at a one-way top; optional crouch_h; flood fill from exits and spawns
- [RECOMMENDED] T4: collinear solid and one-way tiles need two shapes; each segment inside one shape; coverage criterion
- [RECOMMENDED] AC: split bundled criteria (l.322, l.327, l.328, l.340); label tooling-dependent criteria; [Shot] pass tests; missing criteria listed by qa-lead
- [RECOMMENDED] Rule 6 / tuning: dry-run report before tuning changes; derive record ranges from a gate marker
- [RECOMMENDED] Prop catalogue and signatures: hash source texture beside the mark; corner-trim spec; groove phase; relief clipped
- [RECOMMENDED] Memory: no ceiling (two biomes about 194 MB); 1-bit baseline mask; constant-node trim build
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at standard)
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md c9926228b75b22697b58e21156dd851865ecef5b
Reviewed-Content-Hash: design/registry/entities.yaml 81257fdc2577f75fec1f661554d6561892157fff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/systems-index.md a58f0b60b6813efb5c73000584307ebaef4a904b
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: src/player/player.gd d8b0b5307f1f80312dde45244c12f2d06d80b2cb
Reviewed-Content-Hash: src/player/player_config.tres 45f182e75e1df309ceb493b626262c10baf58162
Reviewed-Content-Hash: src/enemies/enemy_base.gd 5fcf5cee27afd58084b73e8cff82ca673a3dac51
Reviewed-Content-Hash: project.godot 04b86ddcde7969009cb0b855698a7a6271ff874b
Reviewed-Content-Hash: assets/environment/PACK-README.md 86f99965520d3b65a0a60c4555d0b5d4786b1af8
Reviewed-Content-Hash: src/test_rooms/art_style_test_room.gd 00440efe8619fd71f2a9914de7891dcce312feae
