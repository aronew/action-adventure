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

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L (producer to verify; the system is built, the remaining work is tests, the planned dash attack and the cross-GDD seams with Healing and Collectible upgrades)
Specialists: none (lean)
Blocking items: 1 (revised the same day) | Recommended: 6 open
Summary: The GDD is faithful to the code: all seven hitbox rects, damages, chain and cancel frames, lunges and the attack3 shake match `attack_data.tres`, and the first review's three blockers hold (fall cap reaches 220 in 12 ticks; the jump is buffered during the lock; charged lands on tick 33, 0.55 s after the press tick). One acceptance criterion would fail against correct code: AC-21 said a first swing from a fresh press does not turn, but the controller sets `facing` from the held direction before `combat.poll`. Revised in AC-21 and Detailed Design item 4. Recommended items are open.
Prior verdict resolved: Yes (the first review's 3 blockers held against the code; its open items, the F3 overlap measurement and the advisory Player Fantasy and Tuning Knobs, remain)
Owner decisions recorded: tap-to-swing latency marked INTENT UNKNOWN for a playtest (not yet written into the GDD); `hit_landed` damage excludes the edge multiplier (recommended answer, not yet written into the GDD, which Healing's Dependencies seam already assumes).
Findings:
- [BLOCKING] Acceptance Criteria AC-21 and Detailed Design item 4: "a first swing from a fresh press does not turn" fails against `_state_ground` and `_state_air`, which set facing before the poll. Revised.
- [RECOMMENDED] Dependencies: Level design (rule 24, pogo) and Collectible upgrades ("Hard (edge and guard only)") name Combat and are missing from its table; state that `hit_landed` damage is before the edge multiplier (Healing Open Question 4)
- [RECOMMENDED] Detailed Design: no timings in seconds; frames last 40 to 140 ms in `seeker_animations.json`. By that data attack1 hits at 140 to 240 ms (total 420), attack2 at 60 to 160 (200 chain, 280 total), attack3 at 240 to 340 (580 total); a looping light combo is about 41 damage per second, against 49 assumed in Healing F3
- [RECOMMENDED] Input resolution: a tap swing starts on button release, so press-to-swing latency equals the hold time (up to 0.133 s); intent not stated and no feel target
- [RECOMMENDED] Acceptance Criteria: all tagged Logic, but `PlayerCombat` needs `Player`, the `Input` singleton, `AnimatedSprite2D` and a physics step; retag Integration or add an injection seam; gdUnit4 is not installed
- [RECOMMENDED] Edge Cases: a press queued during an air swing starts a fresh air swing (a pogo if down is held); the GDD says only a fresh ground attack
- [RECOMMENDED] Contract with targets, AC-16: "layer bit 8" is collision value 8 (editor layer 4); state the bitmask convention shared with `enemies.md` and `healing.md`
Reviewed-Content-Hash: design/gdd/combat.md 504cb4c4a7b721d2b21fd518e8d4796f82e709c9
Reviewed-Content-Hash: design/registry/entities.yaml e5dde6408bcb54311a80f136adf0b0fea54ee0be
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/guard-break.md db88a0e1247115e424f3dd3b528fbfc437151c88
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
