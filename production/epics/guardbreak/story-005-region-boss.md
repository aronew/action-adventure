# Story 005: First-region boss fight

> **Epic**: Guardbreak
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-18

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 5` (one boss fight); the goal in Goal & fail state (reach and beat the final boss of the first region)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Goal & fail state, Hooks, Kill condition):*

- [ ] A boss arena holds one boss with a health bar and a guard meter (story 003), both values in config.
- [ ] The boss has three distinct, telegraphed attack patterns (user's choice, 2026-11-18): a slow overhead slam and a fast sweeping lunge (melee), and a ranged attack (a projectile or shockwave the player must jump or dash), and its guard-break opens a damage window.
- [ ] The boss is beatable using only the player's combat set from stories 001-003.
- [ ] Defeating the boss sets a "region complete" flag and shows a simple completion screen; that is the game's goal.
- [ ] The player dying in the arena resets the boss and restarts the fight (the respawn point itself comes from story 007).
- [ ] The boss uses placeholder art: the Seeker pack has no boss sprites.

---

## Implementation Notes

- Reuse the enemy base (story 004) and guard component (story 003); the boss adds phases and patterns only.
- The brief's Kill condition: if the guard-break fight isn't fun in one arena after two tuning rounds, drop or rethink it. Tune values in config.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 007: save points and the region's rooms. More than one region is out of scope for the project.

---

## Files

- `src/enemies/boss/boss.gd`, `src/enemies/boss/boss_config.tres`, `src/enemies/boss/boss_arena.tscn`
- `src/ui/region_complete.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Logic
**Test**: waived at qa.level minimal. Launch and play the fight to the end before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-003-guard-break.md`, `production/epics/guardbreak/story-004-enemy-types.md`
- Unlocks: `production/epics/guardbreak/story-007-rooms-saves-map.md`
