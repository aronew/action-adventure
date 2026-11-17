# Story 002: Melee: 3-hit combo, air/up/down attacks, charged heavy

> **Epic**: Guardbreak
> **Status**: In Progress
> **Layer**: Core
> **Type**: Visual/Feel
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-17

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2` (melee: 3-hit combo, jump, up and down attacks, heavy attack)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features item 2, Hooks) and `Animation_Guide.txt`:*

- [ ] Attack1 chains into Attack2 and Attack2 into Attack3. The hit lands on Attack1 frames 3-4, Attack2 frames 1-2 and Attack3 frames 5-6; cancelling into the next swing is allowed from Attack1 frame 5 and Attack2 frame 4.
- [ ] On a cancel, the rest of that swing's FX layer (from `FX Split/`) keeps playing where the swing was, so the slash always finishes.
- [ ] Attack3 adds a small screen shake on its hit frames.
- [ ] Jump attack (hit on frames 3-4, air movement continues), up attack (hit on frames 3-4) and down attack in the air (hit on frames 3-4) work. A down attack that hits bounces the player back up (pogo).
- [ ] Heavy attack: holding the button plays wind-up frames 0-4 and holds frame 4 while charging; releasing plays frames 5-10 with the hit on frames 5-6.
- [ ] While charging, the BladeGlow states cycle 3, 1, 3, 1, 0, 1, speeding up as the charge fills; once ready they flicker 0 and 2 fast.
- [ ] Each attack has a hitbox that is active only on its hit frames, and one swing hits an enemy once.
- [ ] Body and FX layers are separate sprites per attack, so the FX layer can be recoloured or detached.
- [ ] Damage, charge time and cancel windows are in a config resource, not code constants.

---

## Implementation Notes

*From `Animation_Guide.txt` (frame timings are listed per animation) and the brief:*

- Use the per-frame durations from the guide. Hit frames and cancel windows above are the guide's.
- The charged heavy is the guard-breaker (story 003); here it only needs to deal damage and expose its charged state.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: guard meters and the guard-break. Story 004: enemies and the player getting hurt. Story 008-009: bow and spells.

---

## Files

- `src/player/player_combat.gd`, `src/player/attack_data.tres`
- `src/player/player.tscn` (adds attack hitboxes and FX layers)

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots of the 3-hit combo and the charged heavy in `production/qa/evidence/`, plus sign-off in `production/qa/evidence/melee-combat-evidence.md`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-001-seeker-controller-movement.md`
- Unlocks: `production/epics/guardbreak/story-003-guard-break.md`
