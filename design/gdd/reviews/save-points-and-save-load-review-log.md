# Save points and save/load — Review Log

The first and second reviews of this GDD (both 2026-11-20, lean, standard: NEEDS REVISION, 2 blockers each, revised the same session) were never written here; their outcomes are recorded in the GDD's status line and in the Core Rules tags. This log starts at the third review.

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; systems-designer and qa-lead lenses applied in session)
Blocking items: 1 | Recommended: 5
Summary: A coherent design (an invulnerable full-heal rest, a death that costs only the walk back, no manual save) whose geometry, timing arithmetic and code facts check out against `src/`, and whose four earlier blockers hold. One blocker: the snap-to-seat bound ignores that a press is accepted on sensor overlap, so the Seeker's centre can sit up to 5 px (half the hitbox) outside the rest area and the stated "at most `rest_area_max_width` tiles" cannot be met in the worst case. Recommended items are cross-document: stays-dead enemies, the new Grid map GDD, region 1's layout against rule 3's placement rules, the `interact` bindings, and the registry.
Prior verdict resolved: Yes (second review's two blockers: rest area room-checked; no overlap with a ladder or other up-bound object)
Findings:
- [BLOCKING] Rule 3 / Edge Cases / Tuning Knobs / Acceptance Criteria: the snap to the seat is bounded as "at most `rest_area_max_width` tiles", but the press is accepted on sensor overlap (the sensor is the 10 px hitbox), so the snap is up to the area's width plus half the hitbox width (under 23 px at the 3-tile cap); AC "moves by at most `rest_area_max_width` tiles" cannot pass in the worst case (owner: restate the bound, no behaviour change)
- [RECOMMENDED] Rule 7 / Edge Cases / Acceptance Criteria: "its enemies are back" contradicts rooms and transitions rule 12's stays-dead exception (region 1's tutorial Waster never returns)
- [RECOMMENDED] Interactions / Dependencies: Grid map now has a GDD and depends on this system (save point positions, the respawn point, and the Playing state: the map opens only in it); this GDD still says Grid map has no GDD and lists no state interface
- [RECOMMENDED] Open Questions 3: region 1's saves N3 (moths), N4 (combat room), N6 (Wasters) and N5 (beside the Keeper door) are not checked against rule 3's placement rules and rule 2's door overlap
- [RECOMMENDED] Rule 2 / Acceptance Criteria: the GDD says "up" throughout, but `interact` is bound to W, Up, D-pad up and gamepad B (`player_input_bindings.gd`); B starts a rest and has no criterion
- [RECOMMENDED] Registry: `rest_area_max_width` is read by the Rooms room check and Level design once they adopt Open Questions 1 and 2, so it crosses system boundaries and is not registered
Registry values: 7 lines searched (all `transition_time`), 0 conflicts.
Advisory (not counted): Player Fantasy absent (advisory at standard). Nice-to-have: AC for rule 8 holds three assertions in one bullet; Dependencies cites Open Questions 1 and 2 for four changes that are all in Open Question 1; the container measures `build_time` about 0.33 s against the 0.10 s budget, so death to control is about 3.2 s here, not 2.96 s.
Receipt note: stamped at the bytes reviewed, before this session's revisions, so a re-review of the revised GDD reads CHANGED and runs in full.
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 8915dd37ee32fcf72523bcdfebc3463ea513ade8
Reviewed-Content-Hash: design/registry/entities.yaml 3e3709009f0cf1571cdbf24f3c6c38c9b25f577c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/gdd/grid-map.md 8ec5995785450e3ade07c3c1de9c2cd3882a6f21

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; systems-designer, qa-lead and game-designer lenses applied in session)
Blocking items: 1 | Recommended: 4
Summary: The design holds up against `src/` (bindings, `_find_overlap`, `_try_start_climb`, `on_door`, `PlayerHealth.reset()`, the 22 by 10 px hitbox, the 2.41 s death clip, the crouch clips) and the third review's snap-bound fix is arithmetically right. One blocker: the seat was specified as a point while the Seeker is a 10 by 22 px body, and the knob allowed a 1-tile (6 px) rest area that cannot hold it; the room check never required a clear seat box, rule 3 set only x, and a press from a step beside the niche was accepted on sensor overlap. Revised the same session with owner choices (set y to the seat; standing hitbox while seated; pause freezes every timer).
Prior verdict resolved: Yes (third review's snap-bound blocker)
Findings:
- [BLOCKING] Rules 1-3 / Tuning Knobs / Edge Cases / Acceptance Criteria: `rest_area_max_width` range 1-4 includes a rest area narrower than the hitbox; the room check had no seat-box clearance, the seated hitbox was unnamed, and a rest set x only, so a press from a step beside the niche left the Seeker at the wrong height (revised: area at least as wide as the hitbox, clear seat box, standing hitbox kept, x and y set, press only within one tile of the seat's floor, knob range 2-4)
- [RECOMMENDED] Rule 2 / Acceptance Criteria: `interact` has no axis binding, so left-stick up does not start a rest (applied: stated, AC, glyph note)
- [RECOMMENDED] Open Questions: Grid map cites "Save points Open Question 7", which did not exist (applied: added)
- [RECOMMENDED] Rule 8 / Edge Cases / Acceptance Criteria: pause during death and arrival was unspecified (applied: freezes every timer; the transition follows rooms and transitions)
- [RECOMMENDED] Rule 3(b) / Open Question 2: reward saves (level design rule 15) versus the no-hazard-on-its-screens rule (applied: guarding hazards go on neighbouring screens)
Registry values: 22 entry names searched; hits on `transition_time`, `rest_area_max_width` and `collision_tile`, 0 conflicts.
Advisory (not counted): Player Fantasy absent (advisory at standard). Nice-to-have applied: stick and step criteria split out, measured `build_time` figure (about 3.2 s) added to F2.
Receipt note: stamped at the bytes reviewed, before this session's revisions, so a re-review of the revised GDD reads CHANGED and runs in full.
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md dde47a831874867add98cd9a7c5082a8ef550ed6
Reviewed-Content-Hash: design/registry/entities.yaml 86cdd8a38b8c3d4f0934fb8e61f7a41f9e8c3cbb
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/lore/region-1-cooling-yards.md ffc1e13897b5b6d25bcd2bf9dcbceea39c50cdbd
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
Reviewed-Content-Hash: design/gdd/grid-map.md 8ec5995785450e3ade07c3c1de9c2cd3882a6f21
