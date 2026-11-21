# Collectible upgrades — Review Log

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode; the `qa-lead` and `systems-designer` lenses applied in-session)
Blocking items: 2 | Recommended: 9
Summary: The design is coherent and every number checks against the code (damage, guard drain, enemy hits, max health, registry entries `fragment_sets` and `max_health_derived`). Two blockers: rule 8's exact catalogue totals cannot hold in the region-1-only core build, and F4's guard-break floor ignored the uncharged heavy, which drains 30 and would break a full guard in 2 hits at the x1.75 cap. Both were revised the same session on the owner's decisions; the rest was applied or logged.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design rules 3, 8, 12; Acceptance Criteria: exact totals 16/9/9/9 cannot hold before all 8 regions exist, and region 1 may hold only 1-3 health fragments (REVISED: exact total is a full-release gate, earlier builds check "no kind over its total", owner)
- [BLOCKING] Formulas F4; Acceptance Criteria: an uncharged heavy drains 30, so the "at least 5 hits" floor and "shorten only the light-combo route" were false (REVISED: bound `steps_max x guard_step <= 0.60`, x1.6 max, 0.001 tolerance, both routes covered, owner)
- [RECOMMENDED] Dependencies; Cross-References; Acceptance Criteria; Open Questions: four stale statements said Save points must adopt the derived max health, which its rule 4 already does (REVISED)
- [RECOMMENDED] Detailed Design rule 3; Acceptance Criteria: the room check rejected retired entries, which are placed in no room (REVISED)
- [RECOMMENDED] Detailed Design rule 9; Dependencies: configure vs `reset()` entry points, and a step's refill must not clear invulnerability (REVISED, marked Rec)
- [RECOMMENDED] Detailed Design rule 4; Acceptance Criteria: "gone on frame N" conflicted with the collect flash (REVISED)
- [RECOMMENDED] Acceptance Criteria: no tests for edge and guard persistence, mid-combo steps, invulnerability, the Visual/Audio [Shot] requirements or the 2 s note (REVISED: added)
- [RECOMMENDED] Detailed Design rule 10; Open Questions 2: a placed magic fragment would show a progress note for a stat that does not exist (REVISED: none placed until spells, owner)
- [RECOMMENDED] Game Feel; Open Questions 9: no breakpoint evidence for "the upgrade is felt"; the first guard step at 0.10 changes no hit count (REVISED: table added; the tuning question is open, owner)
- [RECOMMENDED] Open Questions 6: registry gaps (`edge_step`, `guard_step`, `edge_mult`, `guard_mult` unregistered; stale `max_health_derived` note; `health_steps` naming) (OPEN, owed to the registry)
- [RECOMMENDED] Dependencies: Level design rates the dependency Soft, this GDD Hard; Level design still owes rules 8, 12, 13 and the no-arena rule; Save points' Dependencies table lacks this system (OPEN, owed to those GDDs)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: `step_size` may only fall after release but must still satisfy rule 12 (applied to Edge Cases); `held()` cost is negligible (one line optional); note text when two kinds complete steps on one frame has no format.
Receipt note: the GDD hash below is the reviewed version (HEAD blob, before this revision), so the revised document reads CHANGED and gets a full re-review.
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md c290920e1dbf2b0822aebda1e3e1ff8487760dee
Reviewed-Content-Hash: design/registry/entities.yaml 2665318f1279c56a2886409ff839ebb6552fd477
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md c1f178e2bd2b1cfe4fcdbc8964c2083d0e981c94

## Review — 2026-11-21 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode; the `systems-designer` and `qa-lead` lenses applied in-session)
Blocking items: 0 | Recommended: 8
Summary: Both first-review blockers held on re-derivation: rule 8's exact totals are a full-release gate only, and F4's 0.60 cap holds against the code (light-only breaks 8, 8, 7, 6 and uncharged-heavy breaks 4, 4, 3, 3 at 0-3 steps; 6 and 3 at the cap; two heavies drain 96). Every Game Feel hit count, the enemy and boss figures, `configure()` and `reset()`, and the registry's `fragment_sets` and `max_health_derived` match, and the rules cited in World state, Save points, Level design and the art bible say what this GDD claims. No contradiction and nothing a programmer would have to guess to build the core system; the open items are data-integrity and wording gaps plus housekeeping owed to other documents.
Prior verdict resolved: Yes (NEEDS REVISION, 2 blockers, revised 2026-11-21)
Findings:
- [RECOMMENDED] Detailed Design rules 2, 3: a fragment's `kind` is stored on the placed object and in the catalogue and the room check never compares them, so the note and art can disagree with `held` (add a "kinds agree" check or read the kind from the catalogue only)
- [RECOMMENDED] Detailed Design rule 11; Acceptance Criteria: "Health fragment 2 of 4" is defined only for the first set; the 5th fragment and a retired entry past the cap have no text or test (`held mod step_size` of `step_size`?)
- [RECOMMENDED] UI Requirements; Edge Cases: "stacks with nothing else" does not say what a second note within the ~2 s window does (replace, queue, overlap); the same-frame two-stat note text is still undefined
- [RECOMMENDED] Game Feel; rule 11: "can say the stat a set would raise from the notes alone" fails for edge and guard, because the progress note names the kind and count, not the stat
- [RECOMMENDED] Detailed Design rule 13; Edge Cases; Acceptance Criteria: the no-arena rule lives only in an Edge Case and level design must adopt it (move it into rule 13); "never on the critical path in plain sight" has no criterion (add a [Play] one)
- [RECOMMENDED] Formulas F3: edge has no total bound like guard's 0.60; in range (6 steps x 0.20) it reaches x2.2 and a charged heavy deals 132 (add a bound or state that only the starting values are balanced)
- [RECOMMENDED] Open Questions 6: registry gaps (`edge_step`, `guard_step`, `edge_mult`, `guard_mult` unregistered; stale `max_health_derived` note; `health_steps` vs `steps(health)`) (OPEN, owed to the registry; carried)
- [RECOMMENDED] Dependencies: Level design rates the link Soft and still owes rules 8, 12, 13 and the no-arena rule; Rooms and transitions does not mention this system; Save points' Dependencies table lacks it (OPEN, owed to those GDDs; carried)
Advisory (not counted): Player Fantasy and Tuning Knobs absent (advisory at standard). Nice-to-have: name the note duration as a data value with a range; state a float tolerance for the edge and health ACs; F3's "about 23% fewer hits" vs the Game Feel table's 25%; Rooms and transitions is cited as In Review but the systems index says Approved; index row 19 omits Rooms, Health and Combat as dependencies; after release `step_size` and `steps_max` can only change together, since rule 8 pins their product to the catalogue size.
Receipt note: the GDD hash below is the document as reviewed (byte-identical to the working copy); its own header still reads In Review.
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md f2fdefbae75b634eed2663f9d76f83fe691fb436
Reviewed-Content-Hash: design/registry/entities.yaml 2665318f1279c56a2886409ff839ebb6552fd477
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 192efae4990edb88dff67911cb8ae45a00834c92
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/art/art-bible.md 85683b615330f35961f3bc72493ac4b3911431e8
Reviewed-Content-Hash: design/game-brief.md 56883b7b1e312ae6e2a9404665adf58563994694
Reviewed-Content-Hash: design/narrative/kiln-city-level-integration.md c1f178e2bd2b1cfe4fcdbc8964c2083d0e981c94
