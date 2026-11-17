# Story 003: Guard-break

> **Epic**: Guardbreak
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-17

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 3` (enemies have a guard meter; the charged heavy shatters it and opens a finisher)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Hooks, Core loop, Question):*

- [ ] A guard component gives any enemy a guard meter with a data-driven maximum.
- [ ] Guard states are guarded, broken and recovering, and transitions between them are explicit and testable.
- [ ] While guarded, normal hits reduce the guard meter and deal reduced health damage (both values in config).
- [ ] A fully charged heavy attack (story 002) breaks the guard outright, whatever the meter holds.
- [ ] A broken enemy is staggered for a data-driven time, takes full damage, and a finisher hit during stagger deals bonus damage.
- [ ] The guard meter regenerates after a data-driven delay with no hits, and resets when a broken enemy recovers.
- [ ] Guarded, broken and recovering states look different and readable on the enemy (placeholder visuals are fine).
- [ ] Verified on a training dummy in the movement test room, not yet a full enemy.

---

## Implementation Notes

- This is the game's central hook; keep it a small component any enemy or the boss can attach.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: real enemy types and their attacks. Story 005: the boss's guard behaviour.

---

## Files

- `src/combat/guard_component.gd` (new): guard states, transitions, meter, stagger, finisher, regen, health
- `src/combat/guard_config.gd`, `src/combat/guard_config.tres` (new): every guard value
- `src/test_rooms/training_dummy.gd`, `src/test_rooms/training_dummy.tscn` (new): dummy with guard and health bars and state colours
- `src/test_rooms/movement_test_room.gd`: places the dummy and routes hits to it
- No test file: waived at qa.level minimal

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Logic
**Test**: waived at qa.level minimal. The guard states still need a launch-and-observe check before the story closes (CLAUDE.md coding standards).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-002-melee-combat.md`
- Unlocks: `production/epics/guardbreak/story-004-enemy-types.md`, `production/epics/guardbreak/story-005-region-boss.md`

## Completion Notes
**Completed**: 2026-11-17
**Criteria**: 8/8 passing, by the user's own playtest on their machine. Criterion 4 (a fully charged heavy breaks the guard outright) failed on the first check, then passed after the full-charge moment was made visible (commit 286e731).
**Deviations**: Closed with no on-screen check retained (no Godot binary in the cloud container; run only on the user's machine); the user chose to close anyway. Test evidence waived at qa.level minimal. Later rule from the user: only bosses and mini-bosses have a guard (design/game-brief.md); this story's component and dummy are unaffected.
**Test Evidence**: waived at qa.level minimal
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE and LP-CODE-REVIEW skipped — Solo mode)

## Calls beyond the design
- Guard values in `src/combat/guard_config.tres`: max guard 100; guard cost attack1 10, attack2 10, attack3 20, jump 10, up 10, down 8, uncharged heavy 30; guarded damage x0.25; stagger 2.5 s; recovery 1.0 s; regen after 2.0 s at 20/s; dummy health 200 · kept 2026-11-17
- Rules in `src/combat/guard_component.gd`: finishers are attack3 and the heavy at x2; the breaking hit deals full damage without the finisher bonus; hits while recovering deal full damage and do not touch the meter; hits during the stagger do not extend it · kept 2026-11-17
- Training dummy in `src/test_rooms/training_dummy.gd`: health refills at 0; colours blue guarded, yellow broken, green recovering; placed at x 358..386 on the first floor · kept 2026-11-17
- Full-charge cue in `src/player/player.gd` and `attack_data.tres`: the Charge_Release burst on the blade and a 0.15 s bright flash on the Seeker the moment the heavy is fully charged · kept 2026-11-17
