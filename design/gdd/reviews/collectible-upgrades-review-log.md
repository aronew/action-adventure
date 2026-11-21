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
