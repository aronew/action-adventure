# Review Log — Grid map (`design/gdd/grid-map.md`)

> The first `/design-review` (2026-11-20, lean, standard) was not logged. Per commit 540513d and the session state: NEEDS REVISION, 3 blockers, revised the same session (the map's freeze cited a pause that does not exist; the pan clamp's subject was undefined; a hidden exit had no link to its hiding object).

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 9
Summary: The design carries the owner's decisions (Ori-style fill-in, a found region map, nothing for secrets) consistently, and the F1 and F2 worked examples, the AC arithmetic and the cited upstream rules all check out. Three precision gaps blocked implementation: a hidden exit was defined from one side of a two-sided edge, and its "no marker" Edge Case contradicted rule 6; exits were treated as points although an opening is a run of tiles that may cross a screen's edge; and rule 11's "held" hit-pause contradicted the existing hit-stop, which sets `Engine.time_scale` and restores it from a real-time timer. All revised the same session with owner decisions (a marker once drawn; let the hit-pause end; secret cells marked in the data; shipped rooms grow only right or bottom).
Prior verdict resolved: Yes (first review's three blockers hold: freeze defined in rule 11, view-centre clamp in rule 13, hiding object named in rule 7)
Findings:
- [BLOCKING] Detailed Design rules 6-7, Edge Cases, AC: a hidden exit's mark side and "far side" undefined; "drawn with no marker" contradicted rule 6's symmetric marker
- [BLOCKING] Detailed Design rules 5-6: an exit had no anchor point, so a wide or screen-crossing opening had no defined exit cell or line position
- [BLOCKING] Detailed Design rule 11: "a hit-pause is held, not ended" cannot hold against `enemy_base.gd` `_hit_stop` (time_scale with a real-time restore)
- [RECOMMENDED] Edge Cases: growing a room at the top or left remaps its room-local revealed cells
- [RECOMMENDED] Detailed Design rules 11, 13: a reveal could run after the open press on the same frame
- [RECOMMENDED] Formulas: map pixels assume the 480 x 270 viewport; display migration (terrain OQ9) not addressed
- [RECOMMENDED] Open Questions 1: World state wording must amend rule 1's list and extend rule 10 to cells outside a room
- [RECOMMENDED] Detailed Design rule 7: secret sections of large rooms (level design rule 18) had no rule
- [RECOMMENDED] Acceptance Criteria: several Edge Cases and freeze details had no criterion
- [RECOMMENDED] Visual/Audio: the reserved-key-hue restriction on map colours had no defined check
- [RECOMMENDED] Formulas: `pan_speed` in cells a second ties screen-crossing time to `map_shrink`
- [RECOMMENDED] Formulas F2: at 0.5 the cover test mostly duplicates the centre test; say where the knob matters
Reviewed-Content-Hash: design/gdd/grid-map.md d3bdc7fd3ef80207a09bc09c522e5239b52892b4
Reviewed-Content-Hash: design/registry/entities.yaml 6a3f98fe4960723cd35c2ad75c1335b4050e63ff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 5843420ba1907718429ed03bf872b0b76b0ec10a
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848

## Review — 2026-11-20 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 7
Summary: The three prior blockers hold (checked rule 11 against `enemy_base.gd`'s real-time hit-stop timer), and the F1 and F2 arithmetic, the registry-free value checks and the cited upstream rules all agree. Two precision gaps blocked implementation: the reveal sweep covered "a position set by code", so a respawn, door trip or load would have filled in every cell on the line to the arrival, secret cells included; and an exit's exit cells were fixed by its anchor, so crossing a wide opening away from the anchor left an unexplored marker on a way just used. Both revised the same session with two owner decisions (a region map outlines a room's full rectangle, no notch at a secret section; a hollow Seeker mark so the respawn niche shows through).
Prior verdict resolved: Yes (second review's three blockers hold: hidden exit sides, anchor point, hit-pause; the anchor fix is what exposed blocker 2)
Findings:
- [BLOCKING] Edge Cases (sweep): "a position set by code" included teleports; sweep now inside one room only, a teleport reveals its arrival cell only
- [BLOCKING] Detailed Design rules 5-6: marker stayed when the Seeker crossed away from the anchor; a side is now seen when any cell the opening touches is revealed
- [RECOMMENDED] Detailed Design rules 4, 7: a region map's outline left a notch at a secret section (owner: full rectangle)
- [RECOMMENDED] Edge Cases: the legacy-save fill revealed unfound secret sections
- [RECOMMENDED] Dependencies: the map needs a room index readable for every room without building it
- [RECOMMENDED] Visual/Audio: the Seeker's mark hid the respawn niche (owner: hollow mark)
- [RECOMMENDED] Formulas F1: `pan` was an int pair while the speed scales with tilt; now a float
- [RECOMMENDED] Formulas F2 and AC: the Seeker's position was not given, so the example was not testable as written
- [RECOMMENDED] Detailed Design rule 5: the anchor tie rule applies along the border axis only
Reviewed-Content-Hash: design/gdd/grid-map.md 047a4790e379448d7def8f28222b3efc5dc1d74c
Reviewed-Content-Hash: design/registry/entities.yaml 6a3f98fe4960723cd35c2ad75c1335b4050e63ff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/level-design.md 26dcb99b5e4a552ff0208005df4bf7d64733605f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 5843420ba1907718429ed03bf872b0b76b0ec10a
Reviewed-Content-Hash: design/gdd/terrain-pipeline.md 51184bd9976cb38294e39ca78ec1be053613ca97
Reviewed-Content-Hash: design/game-brief.md 0e2256ea873548131646bbb0def54731733a812f
Reviewed-Content-Hash: design/narrative/kiln-city-visual-direction.md 72a7da16666498e90d007f209d917aa84f1c048b
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md e5929245b7bffed6811be99e22551a4e0190f848
