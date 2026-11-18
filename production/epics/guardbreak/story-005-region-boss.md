# Story 005: First-region boss fight

> **Epic**: Guardbreak
> **Status**: Complete
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
- [ ] Defeating the boss sets a "boss defeated" flag (read by saves and gates in story 007); play goes on, with no completion screen (user's call on 2026-11-18: it is a metroidvania). Beating it is the game's goal.
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

- `src/enemies/boss/boss.gd` (new): Boss extends EnemyBase; three patterns, shockwave, guard
- `src/enemies/boss/boss_config.gd`, `src/enemies/boss/boss_config.tres` (new): every boss, pattern and guard value
- `src/enemies/boss/boss_arena.gd`, `src/enemies/boss/boss_arena.tscn` (new): arena, fight trigger, HUD bars, boss-defeated flag, reload on death
- `src/ui/region_complete.gd`, `.tscn`: added, then removed at the user's request (no completion screen)
- No test file: waived at qa.level minimal

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

## Completion Notes
**Completed**: 2026-11-18
**Criteria**: 6/6 passing, by the user's own playtest on their machine. Criterion 4 was changed at the user's request: no "Region cleared" screen (it is a metroidvania); beating the boss sets the `is_boss_defeated` flag and play goes on.
**Deviations**: Closed with nothing captured on screen (no Godot binary in the cloud container; run only on the user's machine), by the user's choice. The completion screen files were written, then deleted.
**Test Evidence**: waived at qa.level minimal; no screenshots retained
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE and LP-CODE-REVIEW skipped — Solo mode)

## Calls beyond the design
- Boss in `src/enemies/boss/boss_config.tres`: "Region Guardian", 56x84 purple placeholder, health 600, hits don't flinch it · kept 2026-11-18
- Guard: 100, guarded damage x0.2, stagger 4 s, finishers attack3 and heavy at x2, recovery 1.5 s, regen after 3 s at 10/s · kept 2026-11-18
- Patterns: slam (1.4 s wind-up, 40 damage, close), lunge (0.8 s wind-up, 320 px/s for 0.5 s, 25 damage), shockwave (1.0 s wind-up, 150 px/s, 20 damage, jump it: the dash has no invulnerability); random pick by distance, never the same twice · kept 2026-11-18
- Arena in `src/enemies/boss/boss_arena.gd`: 960 px, flat, walls at both ends, fight starts past x 160, reload 1 s after death (story 007 stand-in) · kept 2026-11-18
