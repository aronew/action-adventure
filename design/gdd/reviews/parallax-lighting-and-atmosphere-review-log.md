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

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 11
Summary: The three first-review blockers hold (Seeker at 0 and lip at 4-6 with rule 13's list; the ground fog cap; section A and T from a travel range, with the 5 x 1 example re-derived exactly). P1-P6 and every worked example check out; registry 0 conflicts. Two new holes: the close band named four parameters with no values and had no placement formula, and its drop AC contradicted the drift Edge Case; the section room check carried two thresholds (overlap = 72 px vs "2 x layer_blend" = 144 px) that read literally rejected the GDD's own adjacent-section example, with 2D layouts undefined. Both revised in the same session; the 11 recommended items were not applied.
Prior verdict resolved: Yes (all 3 first-review blockers verified)
Findings:
- [BLOCKING] Detailed Design rule 6; Edge Cases; Acceptance Criteria: `close_sink`, `close_edge_inset`, `close_end_fade`, `close_drop_drift` had no values, the stretch's sideways placement and clamp no formula, and the AC "at least close_edge_inset from the drop" failed a correct build (54 - 18 = 36). Revised: reference values (12, 54, 40, 18, wall 36), new P7 with example, AC tests inset at rest and 36 px anywhere
- [BLOCKING] Detailed Design rule 8; Edge Cases; Acceptance Criteria: "blend zones overlap" vs "2 x layer_blend apart", adjacent sections 0 apart, 2D weights undefined. Revised: sections are strips along one axis (owner: keep sections simple, larger blurred art or blended backgrounds do the rest); distinct edges at least `layer_blend` apart; shared edges allowed; AC cases 60/72 px, shared edge, narrow section, mixed axes; Dependencies and Open Question 2 updated
- [RECOMMENDED] Detailed Design rule 7; Formulas P6: the 0.53 cap is at rest only; a fall lifts the band's top to about 103 px (83 px at `max_drift` 60), black foliage drawn in front of the Seeker; cap the drifted top or add an AC
- [RECOMMENDED] Formulas P6; Acceptance Criteria: update order of `lag_y` vs drift unstated; lag-first gives 34.7 px at 60 fps, not the AC's 36 (±0.5)
- [RECOMMENDED] Acceptance Criteria (motion): "close band 85" sideways; plants move 92
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps; move it to a project-wide config
- [RECOMMENDED] Detailed Design rule 1; Open Question 1: row 0's "baked trim" and the lip as "the terrain's trim" read as two trims
- [RECOMMENDED] Detailed Design rule 16: the reference fog drifts on shader `TIME`; say how it moves to the world clock (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" clashes with level design rule 18 and grid-map secret sections (carried)
- [RECOMMENDED] Detailed Design rule 15: band build and particle pre-warm vs `build_time` (R3) (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: grid map does not list this system and the bidirectional check skips it; P4 corridor example omits the Seeker; frame-time AC has no pass line; leading playtest wording; fog factors not registered.
Receipt note: the GDD hash below is the reviewed version (HEAD cea0cd1, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md b3d7e34f6e7ced29babcb49dd6e4616246e95e4e
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 12
Summary: The two second-review blockers hold (P7 example re-derived: shift 18, 0, -36; sections example re-derived: A 738 and 1662, T 996, scale 1.32, edge 1479.0); P1-P3, P5 and P6 check out and registry shows 0 conflicts. One new hole, found by reading the reference scene: the GDD applied `close_min_run` (108 px) to the floor run before the 54 px drop pull-in, but the reference tests the stretch after it, so a 108 px platform between two drops got a 0 px stretch and P7 went degenerate. Revised in the same session along with three cheap items; 10 recommended items were not applied.
Prior verdict resolved: Yes (both second-review blockers verified)
Findings:
- [BLOCKING] Detailed Design rule 6; Edge Cases; Acceptance Criteria; P7: `close_min_run` tested on the run, not the stretch after the pull-in; a run needs 216 px with two drops, 162 with one, 108 between walls. Revised: minimum applies to the stretch (as the reference does), P7 `x0`/`x1` range, AC with boundary runs 100/108/161/162/215/216 px
- [RECOMMENDED] Detailed Design rule 8: the room's own set's travel range with sections mid-room was unstated. Revised: hull of the uncovered area widened by `layer_blend / 2`
- [RECOMMENDED] Acceptance Criteria (setting): Reduced "every band's position equals Full" contradicted the silhouette band at rest. Revised: silhouette band excluded
- [RECOMMENDED] Acceptance Criteria (readability): P4 "masked" read as excluding the lip and Seeker pixels it reads. Revised: "identified by mask"
- [RECOMMENDED] Detailed Design rule 7; Formulas P6: the 0.53 cap is at rest only; a fall lifts the band's top to about 103 px (carried)
- [RECOMMENDED] Formulas P6; Acceptance Criteria: update order of `lag_y` vs drift unstated; lag-first gives 34.7 px at 60 fps, not 36 (carried)
- [RECOMMENDED] Acceptance Criteria (motion): "close band 85" has no preconditions; plants move 92 and the slide is clamped (120 px from ref at a drop, 240 at a wall, for rocks), so "rocks slide past" holds only near ref (carried, extended)
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps; move to a project-wide config (carried)
- [RECOMMENDED] Detailed Design rule 1; Open Question 1: "baked trim" vs the lip as the terrain's trim (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader `TIME`; say how it moves to the world clock (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" clashes with level design rule 18 and grid-map secret sections (carried)
- [RECOMMENDED] Detailed Design rule 15: band build and particle pre-warm vs `build_time` (R3) (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: P4 corridor example omits the Seeker; frame-time AC has no pass line; compound close band AC; leading playtest wording; grid map does not list this system; fog factors not registered.
Receipt note: the GDD hash below is the reviewed version (HEAD 1bbb59f, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 8b30ebd6f0d6b91cf9929f4217e3e6b7d9b8b8d5
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 10
Summary: The third-review blocker holds (close band 108 / 162 / 216 px thresholds match the reference, which tests the stretch after the pull-in) and the P1, P2, P7 and sections examples re-derive; registry shows 0 conflicts. Two new blockers on the silhouette band, both found by reading the reference code: the 36 px AC does not hold because the reference advances `lag_y` before reading the drift (34.7 px at 60 fps), and the band's top rises to about 103 px in any sustained fall, over the Seeker's level, which the 0.53 "at rest" cap did not cover. Both revised in the same session; the owner accepted foreground showing over the play space in a fall (Hollow Knight does it), so rules 7 and 13 now say so, with a fall AC and a playtest check.
Prior verdict resolved: Yes (third-review blocker verified)
Findings:
- [BLOCKING] Formulas P6; Acceptance Criteria (silhouette): update order unstated and the 36 px AC fails against the reference (34.7 at 60 fps, 35.4 at 144). Revised: order stated (lag first, then drift), example and AC re-derived, frame-rate claim narrowed to the settle curve
- [BLOCKING] Detailed Design rules 7, 13; Formulas P6: the 0.53 cap holds at rest only; a sustained fall puts the band's top at about 103 px over the Seeker's level. Revised (owner decision: keep the reference lift): rules 7 and 13 state it, fall AC (drift -40, top 103), playtest AC and Game Feel question on hiding the Seeker or landing floor
- [RECOMMENDED] Acceptance Criteria (motion): close band 85 had no preconditions. Revised: rocks 85, plants 92, clamp not binding
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps; move to a project-wide config (carried)
- [RECOMMENDED] Detailed Design rule 1; Open Question 1: "baked trim" vs the lip as the terrain's trim (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader TIME; say how it moves to the world clock (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced; blur off makes back bands sharper (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit; the reference's speed 2.3 is rad/s (about 0.37 Hz) (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" clashes with level design rule 18 and grid-map secret sections (carried)
- [RECOMMENDED] Detailed Design rule 15: band build and particle pre-warm vs `build_time` (R3; 0.10 s budget, 0.33 s measured) (carried)
- [RECOMMENDED] Detailed Design rules 1, 8: in a near-wall section (order -10) the deep fog, far fog and dust sit behind it; say which banks show (new)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: rule 1 far/mid orders (-30, -20) differ from the reference blur nodes (-25, -15), relative order kept; a section under half a screen at a room edge fails as "empty range", name the reason; P5 Output Range omits density and setting_scale; P4 corridor example omits the Seeker; frame-time AC has no pass line; grid map does not list this system; fog factors not registered.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 16d11d2d9fe020696c38bf5420d51acf5ae38ab4
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 11
Summary: The fourth-review blockers are resolved, and P1, P2, P3, P5 and P7 re-derive; registry shows 0 conflicts. One new blocker, found by simulating the reference's silhouette update: the reference clamps the drift but not `lag_y`, so after a 1 s fall at 640 px/s the lag winds up to about 256 px, the foliage stays at its cap about 0.9 s after the fall and takes about 2.3 s to get under 2 px. The fall AC (1.35 s to within 2 px) and rule 13 (0.45 s) were wrong. Revised in the same session; the owner chose to bound `lag_y` to `max_drift / sway` (33.3 px), so the foliage eases back as soon as the camera stops (14.7 px after 0.45 s, about 2 px after 1.35 s).
Prior verdict resolved: Yes (fourth-review blockers verified)
Findings:
- [BLOCKING] Formulas P6; Acceptance Criteria (silhouette fall); rules 7, 13: reference lag unbounded, so the settle time after a long fall was 2.3 s, not 0.45 / 1.35 s. Revised (owner decision: bound the lag): P6 formula, update order, output range, example, rules 7 and 13, fall AC re-derived and simulated at 30, 60 and 144 fps
- [RECOMMENDED] Acceptance Criteria (close band): boundary fixtures 100, 161 and 215 px are off the 6 px collision grid. Revised: 102, 156 and 210 px
- [RECOMMENDED] Interactions; Open Question 2: grid map (Approved) states the freeze only and does not say the map draws above the grade or list this system. Revised: obligation added to Open Question 2 and the bidirectional check
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps; move to a project-wide config (carried)
- [RECOMMENDED] Detailed Design rule 1: "baked trim" vs the lip as the terrain's trim (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader TIME; say how it moves to the world clock (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced; blur off makes back bands sharper (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit; the reference's speed 2.3 is rad/s (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" clashes with level design rule 18 and grid-map secret sections (carried)
- [RECOMMENDED] Detailed Design rule 15: band build and particle pre-warm vs `build_time` (0.10 s budget, 0.33 s measured) (carried)
- [RECOMMENDED] Detailed Design rules 1, 8: in a near-wall section (order -10) which banks show (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: P2 section scale 1.32 vs exact 1.324 (applied); `close_min_height` is in Edge Cases and the AC but not rule 6; P5 Output Range omits density and setting_scale; P4 corridor example omits the Seeker; frame-time AC has no pass line; fog factors and `layer_blend` not registered. Dependencies with no GDD: Camera, Player controller, Pause and menus, Combat, Enemies, art bible.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md df14109489658717d3c4a8b16b127d5bcc00b3e0
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 14
Summary: The fifth-review blocker is resolved: the bounded `lag_y` simulates as written (lag never past 33.3 px, 14.7 px at 0.45 s, about 2 px at 1.35 s, 34.7 px first frame at 60 fps), and P1, P2, P3, P4 and P7 re-derive; registry shows 0 conflicts. One blocker: the fall AC and P6 Example said the drift is −40 for the whole fall, but the lag winds up first (−12.3, −24.2, −35.7, −40 at 60 fps; cap at 0.067 s), so a test written from the AC fails its first frames. Revised in the same session. New recommended: the cap binds at 74 px/s of camera speed, and a simulated plain full jump (player_config values, camera smoothing 7) lifts the foliage about 23 px, so the lift is not only a long-fall effect; the playtest AC covers only falls of two screens.
Prior verdict resolved: Yes (fifth-review blocker verified)
Findings:
- [BLOCKING] Formulas P6 Example; Acceptance Criteria (silhouette fall): "−40 for the whole fall" fails for the first ~0.07 s. Revised: cap reached by 0.1 s, first frame −12.3 px at 60 fps, −40 until the fall stops
- [RECOMMENDED] Detailed Design rules 7, 13; Game Feel; Acceptance Criteria (playtest): cap binds at 74 px/s camera speed; an ordinary full jump lifts the foliage ~23 px (top ~120 px); add a plain-jump and a one-screen-drop case; the art is 4-14% opaque in its top three quarters, so say the "top" is sparse blade tips (new)
- [RECOMMENDED] Formulas P1, P2 tables: A and T for the room's own set say room centre and room size; rule 8 says the hull of the uncovered area; no AC for partial coverage (new)
- [RECOMMENDED] Dependencies: Pause and menus and Grid map are freeze sources (Interactions "In") but missing from the upstream table; Grid map downstream says "Nothing" (new)
- [RECOMMENDED] Detailed Design rule 8: how a section's fog scales blend with the neighbour's (new)
- [RECOMMENDED] Acceptance Criteria: rule 17 (same shake offset on every band) and rule 16 for the transition freeze and the map untested (new)
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps (carried)
- [RECOMMENDED] Detailed Design rule 1: "baked trim" vs the lip as the terrain's trim (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader TIME (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" naming clash (carried)
- [RECOMMENDED] Detailed Design rule 15: band build and pre-warm vs `build_time` (carried)
- [RECOMMENDED] Detailed Design rules 1, 8: which banks show in a near-wall section (carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: UI string "no particles or glow blur" misleads (glows stay; bloom goes); room-end piece "in a section less than a screen tall" unclear with stacked sections; define "fast" in rule 13; plus the carried list from entry 5. Dependencies with no GDD: Camera, Player controller, Pause and menus, Combat, Enemies, art bible.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md c3e8bf471bb2244e7004ba64f11ba3ded2de0863
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 14
Summary: The sixth-review blocker is resolved: P6 simulates as the AC now says (−12.3, −24.2, −35.7, −40 at 60 fps; lag never past 33.3 px; 14.7 px at 0.45 s and about 2 px at 1.35 s after the fall), and P1, P2 and P7 re-derive; registry shows 0 conflicts. One blocker: room-end pieces draw at 10+ in front of the Seeker but rule 13's closed list and AC 1 omit them, and nothing limits how far in they reach (the 512 x 1080 border art scales with the room's height; the reference slides its 100 px solid left border 62 px past the bound "without covering the spawn point", which the GDD did not say). Revised in the same session: owner chose an inset cap, `room_end_inset_max` 38 px.
Prior verdict resolved: Yes (sixth-review blocker verified)
Findings:
- [BLOCKING] Detailed Design rules 1, 5, 13; Acceptance Criteria (layer stack): room-end pieces in front of the Seeker, missing from rule 13's list, no width limit. Revised: slide past the bound so the opaque reach (alpha 0.5 or more) is at most 38 px; factor 1.0 in rule 1; added to rule 13 and AC 1; new AC and Edge Case. Open from the fix: the cap is from the bound, so an end wall thinner than 38 px leaves a clinging Seeker covered (level design keeps the wall thick enough; not a room-check item yet)
- [RECOMMENDED] Detailed Design rule 8: the blend curve's shape (linear or smoothstep) is unspecified; the AC samples only 0, 0.5 and 1 (new)
- [RECOMMENDED] Detailed Design rules 7, 13; Game Feel; Acceptance Criteria (playtest): cap binds at 74 px/s camera speed; a plain full jump lifts the foliage ~23 px (carried)
- [RECOMMENDED] Formulas P1, P2 tables: room's own set A and T vs rule 8's hull (carried)
- [RECOMMENDED] Dependencies: Pause and menus and Grid map missing from the upstream table (carried)
- [RECOMMENDED] Detailed Design rule 8: section fog scale blend (carried)
- [RECOMMENDED] Acceptance Criteria: rule 17 and rule 16 (transition freeze, map) untested (carried)
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps (carried)
- [RECOMMENDED] Detailed Design rule 1: "baked trim" vs the lip (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader TIME (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" naming clash (carried)
- [RECOMMENDED] Detailed Design rule 15 and rules 1, 8: `build_time`; which banks show in a near-wall section (carried, merged)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: UI string "no particles or glow blur"; define "fast" in rule 13 (74 px/s); a room's own set with an empty range is rejected though never visible; room-end piece "in a section less than a screen tall" unclear with stacked sections. Dependencies with no GDD: Camera, Player controller, Pause and menus, Combat, Enemies, art bible.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 4c8c16bd057edd157fc55c534dfccbf9bd946c64
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 15
Summary: The seventh-review blocker held: rules 1, 5, 13, the AC and the Edge Cases agree on the room-end inset cap (38 px, slide 62 for the reference border), and P1, P2, P6 and P7 re-derive; registry shows 0 conflicts over 12 lines. One blocker: the foreground strips draw at 10+ in front of the Seeker and rule 13 says everything in front has "its limit", but the strips had only "stay near the screen's top and bottom", with no number, no preset check and no AC. Measured over all 36 shipped strip files: top strips reach 0.402-0.403 of the screen height (about 109 px), bottom strips 0.33-0.40. Revised in the same session: owner chose a cap; `foreground_reach_max` set at 0.41 (the owner picked 0.40, but the shipped top strips measure 0.403 and would fail it by about 0.8 px).
Prior verdict resolved: Yes (seventh-review blocker verified)
Findings:
- [BLOCKING] Detailed Design rules 1, 5, 13; Formulas P3; Edge Cases; Acceptance Criteria: foreground strips in front of the Seeker with no limit on their art's reach. Revised: `foreground_reach_max` 0.41 (data file, range 0.2-0.45), measured at alpha 0.5 from the screen's edge; preset check rejects strip art past it; new AC over the 36 shipped files plus fixtures; new Edge Case
- [RECOMMENDED] Detailed Design rule 12; Edge Cases: the grade has almost no numbers in the GDD (`bloom_area`, contrast, split tone, saturation, ambient gradient; vignette 0.5 only in Edge Cases); the reference scene is the source and the AC checks only the HUD and the P4 margin (new)
- [RECOMMENDED] Detailed Design rule 8: the blend curve's shape (linear or smoothstep) is unspecified; the AC samples only 0, 0.5 and 1 (carried)
- [RECOMMENDED] Detailed Design rules 7, 13; Game Feel; Acceptance Criteria (playtest): cap binds at 74 px/s camera speed; a plain full jump lifts the foliage ~23 px; "fast" undefined (carried)
- [RECOMMENDED] Formulas P1, P2 tables: room's own set A and T vs rule 8's hull (carried)
- [RECOMMENDED] Dependencies: Pause and menus and Grid map missing from the upstream table (carried)
- [RECOMMENDED] Detailed Design rule 8: section fog scale blend (carried)
- [RECOMMENDED] Acceptance Criteria: rule 17 and rule 16 (transition freeze, map) untested (carried)
- [RECOMMENDED] Formulas P5: `ground_fog_alpha_max` lives in the preset it caps (carried)
- [RECOMMENDED] Detailed Design rule 1: "baked trim" vs the lip (carried)
- [RECOMMENDED] Detailed Design rule 16: reference fog drifts on shader TIME (carried)
- [RECOMMENDED] Detailed Design rule 14; Acceptance Criteria: P4 never run in Reduced (carried)
- [RECOMMENDED] Edge Cases (preset check): most preset fields have no range (carried)
- [RECOMMENDED] Edge Cases (photosensitivity): flicker "3 per second" has no unit (carried)
- [RECOMMENDED] Detailed Design rule 8: "section" naming clash (carried)
- [RECOMMENDED] Detailed Design rule 15 and rules 1, 8: `build_time`; which banks show in a near-wall section (carried, merged)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: the bottom strip (reach at most 0.40) sits mostly behind the silhouette band at rest (its top 0.53), so the top strip is the one the cap matters for; a room-end piece's own top and bottom edge can show in a 3 px shake at a room corner (rule 4); UI string "no particles or glow blur"; a room's own set with an empty range is rejected though never visible; room-end piece "in a section less than a screen tall" unclear with stacked sections. Dependencies with no GDD: Camera, Player controller, Pause and menus, Combat, Enemies, art bible.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 90693f587319e1cd251e62f631811395f216b4c4
Reviewed-Content-Hash: design/registry/entities.yaml 6258731ee3fa52f40f199f479fd69279b82d09c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/ability-gating.md c7ec3641c20bfb3b8399421831283377ebf9d927
Reviewed-Content-Hash: design/gdd/grid-map.md c353dac247f2dd86e7600d282e3d26a3306460e8
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b

## Review — 2026-11-22 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 8
Summary: The design intent is sound; both blockers are the reference scene having moved after owner decisions while the GDD did not. The registry shows 0 conflicts and every named GDD exists. Art-room bench (long room, 600 frames, 1920x1080, mood on): draw calls max 287, p95 273, mean 131, under the 500 budget; frame time (about 222 ms) is software GL and only comparable Full against Reduced, which this run did not measure.
Prior verdict resolved: Partly (eighth-review blocker, `foreground_reach_max`, verified)
Findings:
- [BLOCKING] Detailed Design rules 12 and 14; Game Feel; Acceptance Criteria (bloom): describe screen bloom and radiance around the Seeker; the reference draws a backlight behind his sprite instead (owner decision: the bloom washed out the painted art) and its player light lift is 0.03, not 0.1. Rule, Game Feel and AC need the backlight and its numbers, and the AC must test it
- [BLOCKING] Detailed Design rule 6; Formulas P7; Edge Cases; Acceptance Criteria (close band): every band end fades over 40 px; the owner decided rocks run into walls at full height and fade only at ledge drops. The reference extends 72 px behind a wall and its `close_min_run` test runs after that extension. Rule, P7, Edge Cases and AC need walls extend, only drops fade, and where the min-run check runs
- [RECOMMENDED] Formulas; Detailed Design rule 12: stale numbers against the reference: blur 5 to 7 and 2 to 3.2, new close blur 1.2, fog alphas, ramps and tints; P4 margins follow
- [RECOMMENDED] Detailed Design rule 12: the blur passes compound; state the combined blur, not each pass alone
- [RECOMMENDED] Detailed Design (embers): size is ambiguous (drawn width 5.6 px against a stated 2.8)
- [RECOMMENDED] Dependencies; Detailed Design rule 12: the art bible exists (Draft, sections 1-4) but the GDD says it does not; the grade state inputs it owes this GDD are missing
- [RECOMMENDED] Formulas P6: the reference does not implement the lag bound
- [RECOMMENDED] Dependencies: Terrain pipeline status text is stale (Needs Revision after its seventh review)
- [RECOMMENDED] Acceptance Criteria (performance): name the mood state measured and the bench output field read; Full against Reduced frame-time cost was not run
- [RECOMMENDED] Carried from the eighth review (15 items): blend curve shape, P1 and P2 set against rule 8's hull, Pause and Grid map rows in the upstream table, section fog scale, transition freeze and map rules untested, P5 cap lives in the preset it caps, "baked trim" against the lip, fog drift on shader `TIME`, P4 never run in Reduced, preset field ranges, flicker unit, "section" naming clash, `build_time`
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: a short Player Fantasy and a Tuning Knobs index, since the numbers are scattered across rules.
Receipt note: hashes are of the working-tree files reviewed.
Reviewed-Content-Hash: design/gdd/parallax-lighting-and-atmosphere.md 38c89c37c445fb0a6f50acd627ce31811ebe0568
Reviewed-Content-Hash: design/registry/entities.yaml 54ae8bf7a7c531a21947aefc5034f4a369ef81bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md cc8a514f6192d296c7df733d70c67d328bbd77d8
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md ab42152eac4cb7fee23eac9eb8635f12c8f4c021
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8
Reviewed-Content-Hash: design/gdd/pause-and-menus.md 8789f9cfab9ccec5b5d3b8aec845e061793ed77b
