# Story 004: Two or three enemy types with telegraphed attacks

> **Epic**: Guardbreak
> **Status**: In Progress
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

- `src/enemies/enemy_base.gd`, `src/enemies/enemy_*.gd`, `src/enemies/enemy_*.tres`
- `src/player/player_health.gd`

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
