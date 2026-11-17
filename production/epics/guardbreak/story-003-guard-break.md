# Story 003: Guard-break

> **Epic**: Guardbreak
> **Status**: In Progress
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
