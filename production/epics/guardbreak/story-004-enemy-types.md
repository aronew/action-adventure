# Story 004: Two or three enemy types with telegraphed attacks

> **Epic**: Guardbreak
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-18

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 4` (2-3 enemy types with readable, telegraphed attacks); also the fail state in Goal & fail state (health reaches zero)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features item 4, Challenge, Goal & fail state); updated 2026-11-18 to the user's rule "only bosses and mini-bosses have a guard" and the chosen mix: 3 normal enemies, no mini-boss.*

- [ ] A shared enemy base has health and a state machine: idle or patrol, chase, telegraph, attack, hurt, stagger, dead. Normal enemies have **no guard**: only bosses and mini-bosses do (design/game-brief.md); the base can still take a guard component for story 005.
- [ ] Three normal enemy types exist, differing in speed, health and attack pattern *(guessed: one plain, one fast, one heavy-hitting)*, all values in config resources. Each dies to the combo; hits stagger it briefly.
- [ ] Every damaging attack shows a visible wind-up (telegraph) before it can hurt the player; wind-up length is data-driven.
- [ ] An enemy hit on the player removes player health, plays the pack's Hurt or HurtKnockback animation and gives a short invulnerability window.
- [ ] Player health reaching zero plays Death once, holds its last frame, and emits a signal the save system uses to respawn (story 007).
- ~~The first tougher enemy appears about a minute in~~ — moved to story 012 (level design) on 2026-11-18 at the user's request: the enemy room is a test room, and pacing belongs to the real interconnected world.
- [ ] Enemies use placeholder art: the Seeker pack has no enemy sprites.

---

## Implementation Notes

- Player hurt, knockback and death animations are in the pack; the step back is drawn into HurtKnockback, so the player is not moved by code.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.
- Enemy art does not exist yet. Decide placeholder (coloured shapes) versus commissioned art before the boss story.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 005: the boss. Story 007: the respawn itself.

---

## Files

- `src/enemies/enemy_base.gd`, `src/enemies/enemy_config.gd`, `src/enemies/enemy.tscn`
- `src/enemies/enemy_grunt.tres`, `src/enemies/enemy_skitter.tres`, `src/enemies/enemy_brute.tres`
- `src/player/player_health.gd`, `src/player/player.gd`, `src/player/player_config.gd`, `src/player/player_config.tres`, `src/player/seeker_animations.json`
- `src/test_rooms/enemy_test_room.gd`, `src/test_rooms/enemy_test_room.tscn`
- No test file: waived at qa.level minimal

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Logic
**Test**: waived at qa.level minimal. Launch and observe each enemy type before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-003-guard-break.md`
- Unlocks: `production/epics/guardbreak/story-005-region-boss.md`, `production/epics/guardbreak/story-008-bow-thin.md`, `production/epics/guardbreak/story-009-spells-thin.md`

## Completion Notes
**Completed**: 2026-11-18
**Criteria**: 6/6 passing (the pacing criterion moved to story 012 at the user's request). Criteria 1-2 failed the first check (weak flinch, too few hits to kill, no death impact) and passed after commits 41d42ca and f288eb6, by the user's playtest.
**Deviations**: Built in another session (branch claude/blissful-knuth-5lpg95, fast-forwarded here): the enemies live in a separate `src/test_rooms/enemy_test_room.tscn` rather than the movement test room, and the types are named Grunt and Skitter rather than walker and runner. The evidence stamp shows `src/player/player.gd` and the enemy files changed after the screenshots were taken (later fixes); the screenshots were not re-captured.
**Test Evidence**: tests waived at qa.level minimal; 8 screenshots retained in `production/qa/evidence/story-004-enemy-types/`
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE and LP-CODE-REVIEW skipped — Solo mode)

## Calls beyond the design
- Enemy values in `src/enemies/enemy_*.tres`: Grunt health 85, chase 70, telegraph 0.5 s, damage 15; Skitter health 50, chase 150, telegraph 0.35 s, lunge 280, damage 10; Brute health 220, chase 45, telegraph 0.9 s, damage 30, can't be interrupted mid-swing · kept 2026-11-18
- Getting hit: knockback grunt 150, skitter 190, brute 65 px/s; hop 70 / 90 / 0; 3 px recoil snap; hurt time 0.35 / 0.3 / 0.2 s · kept 2026-11-18
- Death impact: hit-pause at 0.05 speed for 0.08 / 0.07 / 0.14 s, camera shake 3 / 2 / 5 px, fragment burst in the enemy's colour, body launched and toppled, then faded · kept 2026-11-18
- Player health in `src/player/player_config.tres`: 100 health, 1.0 s invulnerability with blinking, 0.35 s hurt lock, hits of 20 or more play the knockback hurt; no dash invulnerability · kept 2026-11-18
- Test room `src/test_rooms/enemy_test_room.gd`: 3400 px long, three Grunts, three Skitters, then the Brute; the room reloads 1 s after death as the stand-in for story 007 · kept 2026-11-18
