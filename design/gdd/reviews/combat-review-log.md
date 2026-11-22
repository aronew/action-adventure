# Review Log: Combat

## Review — 2026-11-22 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L (producer to verify; the system is built, the remaining work is tests and the planned dash attack)
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: A reverse-documented GDD that is faithful to the code and honest about what is unbuilt (dash attack) and unknown. Its pogo figures agree with the registry and the ability-gating and level-design GDDs. Three acceptance criteria would have failed against correct code; all three were revised the same day, along with the mechanical recommended items. The stamped hash below is of the text that was reviewed, so the revised file reads CHANGED and needs a full re-review to be approved.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas F5, Acceptance Criteria AC-10: "fall speed never exceeds 220" contradicts the code, which moves a faster fall toward the cap at 1350 px/s² (480 to 220 in about 12 ticks). Revised.
- [BLOCKING] Acceptance Criteria AC-11: said dash, jump and grapple are "refused" during the lock; the Edge Cases and code say a jump press is buffered and dash and grapple are dropped. Revised.
- [BLOCKING] Formulas F2, AC-5: charge defined as 0.55 s from the press; the timer starts at `hold_threshold` when the heavy begins, so it is 0.41 s after the CHARGE phase starts (and longer from the press for a queued press). Revised.
- [RECOMMENDED] The pogo: derived reaches (27 forward, 21 back, 32 below the feet, about 37.6 px rise) that ability gating, level design and the registry rely on were not stated; added with a `/propagate-design-change` rule. Revised.
- [RECOMMENDED] Dependencies, Edge Cases, Open Questions: stale statements (guard-break, enemies and bosses have no GDD; "AC-1 to AC-17"; "tests holds only terrain tests"). Revised.
- [RECOMMENDED] AC-2, AC-3: boundary at 0.14 s not a whole number of ticks; "after frame 5" ambiguous because earlier presses are queued. Rewritten in ticks and in terms of the queue. Revised.
- [RECOMMENDED] AC-18: vague "changes the behaviour". Rewritten as a concrete value change. Revised.
- [RECOMMENDED] Acceptance Criteria: no criteria for glide and charge deceleration, the heavy's lunge, or turning on a chain. AC-19 to AC-21 added. Revised.
- [RECOMMENDED] Formulas F3-F7: no ranges or worked examples. Added. Revised.
- [RECOMMENDED] F3, AC-7: Godot may report overlaps for a newly enabled Area2D one physics tick late; tolerance of one tick added, measurement still open. Open.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard). Open.
Reviewed-Content-Hash: design/gdd/combat.md 9a8071c534a66db00e4159a278f0be8fb3ef6940
Reviewed-Content-Hash: design/registry/entities.yaml 54ae8bf7a7c531a21947aefc5034f4a369ef81bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md 4709af3861c39f34ad0f7bc76fa173e105d31c88
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
