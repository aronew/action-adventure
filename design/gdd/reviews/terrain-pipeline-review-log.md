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
