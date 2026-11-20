# Review Log — Parallax, lighting and atmosphere (`design/gdd/parallax-lighting-and-atmosphere.md`)

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 7
Summary: The design is faithful to the owner's reference scene, its P1-P3 and P5 arithmetic checks out, readability is a first-class rule and its owed work is flagged honestly; the registry shows 0 conflicts. The blockers were specification holes, not the look: the draw-order table omitted the Seeker and put the lip at 0 while rule 13 forbade the glows, ground fog and embers it draws in front of the Seeker; the ground fog's "never hides a floor edge" had no enforceable cap; and a section's A and T were inconsistent with rule 8, so an edge could show in a section that touches a room edge. All three revised in the same session; the 7 recommended items were not applied.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design rules 1, 13; AC 1: no Seeker row; lip at 0 though drawn in front of the Seeker (reference `MIDDLE_Z` 5); glows, ground fog and embers in front of the Seeker contradicted rule 13. Revised: Seeker at 0, lip at 4-6, rule 13 lists everything drawn in front of the Seeker with its limit, AC 1 updated
- [BLOCKING] Detailed Design rules 9, 13; Formulas P5: only the room scale was capped, so a preset with ground fog `a` = 1 passed. Revised: `ground_fog_alpha_max` 0.3 on `a x density`, preset check and AC added
- [BLOCKING] Detailed Design rule 8; Formulas P1, P2; Edge Cases: A was the section's centre while P2 assumed travel symmetric about A (about 21 px uncovered in a 5 x 1 example); the Edge Case's half-screen widening double-counted V; the blend's side was unstated. Revised: blend centred on the edge (as the reference), A and T from each set's travel range, worked example, sectioned-room ACs
- [RECOMMENDED] Detailed Design rule 6; Formulas P1: the close band's drift clamp (18 px at a drop, one 36 px cell elsewhere in the reference) is only in Edge Cases and has no AC
- [RECOMMENDED] Detailed Design rule 16: the reference fog drifts on shader `TIME`, which pausing does not stop; needs a world-clock uniform; hit-pause behaviour unstated
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: Reduced's "keeps the brightness order" is never checked; run P4 in Reduced
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range; a Tuning Knobs table (advisory at standard) would give the check its source
- [RECOMMENDED] Edge Cases (photosensitivity): flicker limit "3 per second" vs the reference's 2.3 rad/s speed; define the unit
- [RECOMMENDED] Detailed Design rule 8: "section" collides with level design rule 18 and save sections; rename (e.g. backdrop section)
- [RECOMMENDED] Detailed Design rule 15: say whether the band build, particle pre-warm and first shader use fit rooms' `build_time` (R3)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: P4 corridor example omits the Seeker's value; reference rooms are not whole-screen sizes; leading playtest wording; frame-time AC has no pass line; transition fade vs grade order unstated; grid-map does not list this system.
Receipt note: the GDD hash below is the reviewed version (HEAD before revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 53688549b6ae60c9b25409ba946e7c6ffe0b50dd
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
