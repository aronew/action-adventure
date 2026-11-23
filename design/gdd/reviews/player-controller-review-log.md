# Player Controller and Input — Review Log

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; no agents spawned)
Blocking items: 3 | Recommended: 5
Summary: The reverse-documented GDD is faithful to the code: every Values-table group matches `player_config.tres` and the F1-F4 arithmetic checks out. Its gaps are about what approved neighbours demand of the controller: Save points, Rooms, Healing and Grid map need states, actions and an API the GDD did not list, the damage-block rule was left open, and AC-16 pinned behaviour that contradicts approved ability gating rule 3. All 3 blockers and the 5 recommended items were revised the same day (owner decisions 2026-11-23: heal on keyboard A; door entry blocks damage; a bench is safe by placement); a re-review is owed.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design / Dependencies: Save points, Rooms, Healing and Grid map require states (RESTING, ARRIVING, HEAL), actions (heal, pause, map, cancel) and an API the GDD omitted; `CHANNEL` vs `HEAL`; heal key A conflicted with `move_left`; the bidirectional check was stale
- [BLOCKING] Edge Cases / AC-20: damage block during door entry and the Rooms transition left as "fix or change the rooms requirement"; two approved GDDs depend on it
- [BLOCKING] Ability ownership / AC-16: AC-16 pinned "dash and wall slide still work (current behaviour)", contradicting `ability-gating.md` rule 3; the climb's missing ownership check was not in the gap list
- [RECOMMENDED] Formulas F2: the fast-fall multipliers compound (900 x 1.5 x 1.8 = 2430), which the text did not say
- [RECOMMENDED] Acceptance Criteria: AC-2, AC-9, AC-12 and AC-21 not independently testable; timing ACs in seconds not whole ticks (AC-1, AC-3)
- [RECOMMENDED] Formulas / registry: no variable ranges; no jump-arc formula; controller-owned values read elsewhere (`dash_speed`, `fast_fall_speed`, `grapple_range`, base `max_health`) not registered; `grapple_release_time` absent from the config
- [RECOMMENDED] Edge Cases: up pressed over a door, ladder and rest area; grapple equal-distance tie; same-tick press priority; "unlocked ATTACK" undefined; hit from CROUCH restores the hitbox with no headroom check
- [RECOMMENDED] Open Questions: the dash hit and the grapple hit (concept pillar 4) not recorded
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/player-controller.md c08d4b121bb91d5c413ba9b97ee7b5f66b82c5c2
Reviewed-Content-Hash: design/registry/entities.yaml e5dde6408bcb54311a80f136adf0b0fea54ee0be
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/healing.md e999a7ef97a08ddf4b2f9c7cea9a96b8bd87c311
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/gdd/combat.md 0afd74178f6fa44180760a752dcf3a8456d62061
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f

## Review — 2026-11-23 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; no agents spawned)
Blocking items: 0 | Recommended: 7
Summary: Third review of the reverse-documented GDD. The values, formulas (F1-F5) and tick boundaries re-derive correctly and match the registry (dash_speed, fast_fall_speed, grapple_range, base_max_health). The earlier blockers hold: states, actions, API and the two-source damage block match what Rooms, Save points, Healing, Grid map and Ability gating need. What is left is wording, testability and work in neighbouring GDDs. Note: the GDD header and commit 923dc4a record a second NEEDS REVISION the same day (2 blockers) that was never appended to this log.
Prior verdict resolved: Yes (first review's 3 blockers and the unlogged second review's 2 blockers are revised)
Findings:
- [RECOMMENDED] Detailed Design / Open Questions: States table omits `heal` from GROUND's exits and HEAL from the entered-from cells of ENTER_DOOR and RESTING; Open Question 4 is stale (healing.md rule 9 already settles it, and rule 6 limits starting a heal to GROUND)
- [RECOMMENDED] Detailed Design rule 13: hurt knockback unspecified (no velocity impulse; leftover vx bleeds at 1200; gravity still acts); add the rule and an AC
- [RECOMMENDED] Damage block / AC-20: start tick stated four ways (from the press, from the tick after, Rooms from the up press); pin one and test it
- [RECOMMENDED] Acceptance Criteria: split AC-13 and AC-20 (5-7 assertions each); AC-21's "feels good" is a lead sign-off, keep it out of pass/fail
- [RECOMMENDED] States: RESTING and ARRIVING do not name the state they return to (GROUND)
- [RECOMMENDED] Cross-GDD: save-points-and-save-load.md still says a rest and an arrival "cannot be hurt" (AC at L266), contradicting the owner's bench-safe-by-placement decision; Save points owns the fix
- [RECOMMENDED] Dependencies: rooms-and-transitions.md and world-state.md still say the controller has "no GDD yet"
- [ADVISORY] Player Fantasy and Tuning Knobs absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/player-controller.md fb10bc6b71d00494a5b4d4c56d15ed4ae9980629
Reviewed-Content-Hash: design/registry/entities.yaml 6973ce3317cea2b607472cc1b224a83515918536
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/rooms-and-transitions.md efab1cbedfc71daa37a1dc861584b53b12fae74e
Reviewed-Content-Hash: design/gdd/save-points-and-save-load.md 4627eb28f2dad36dc8b24e898cea2a8ab78033c8
Reviewed-Content-Hash: design/gdd/healing.md e999a7ef97a08ddf4b2f9c7cea9a96b8bd87c311
Reviewed-Content-Hash: design/gdd/pause-and-menus.md f78479e94533dbc3a4e0ee426abe4dd6f724620a
Reviewed-Content-Hash: design/gdd/grid-map.md ad69268541bb3f991a284f924b6fbf04dddda268
Reviewed-Content-Hash: design/gdd/world-state.md 6cd27bb29d87325eafada99f059a83bbeae7b513
Reviewed-Content-Hash: design/gdd/ability-gating.md 3f8d018daed6b507b9fa79d4f26f5b387e51d897
Reviewed-Content-Hash: design/gdd/combat.md 0afd74178f6fa44180760a752dcf3a8456d62061
Reviewed-Content-Hash: design/gdd/level-design.md d4ad8527049c331a3cc88d44f7b99ab9d6dd333e
Reviewed-Content-Hash: design/gdd/collectible-upgrades.md 93f8c4f08602c58aa46b1696ff19ae11490cf2e1
Reviewed-Content-Hash: design/gdd/enemies.md f43acef9bc8cb4f63cac9fa8c8607c21ee525c3a
Reviewed-Content-Hash: design/gdd/bosses.md 025d6e45c55d02b0ffe748d22de9466fde7db4e4
Reviewed-Content-Hash: design/gdd/game-concept.md c63468587aa8bd1ec34d8aaea42a37d41bdfee6f

## Change note — 2026-11-23 — not a review
Edited during the Pause and menus fourth review, with the owner's go-ahead (coordination rule 5): `heal` moves from gamepad Y to gamepad B (B is `cancel` only in menus and the map, `pause-and-menus.md` rule 19), and `rapid_fire` stays on Y instead of moving to R3. Input table, Design intent, AC-17 and the Keyboard layout Open Question updated. Status unchanged (Approved); the next review reads this file as CHANGED.
