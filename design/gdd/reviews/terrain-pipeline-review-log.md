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
