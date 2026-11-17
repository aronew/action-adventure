# Story 009: Spell casts, thin

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Build step**: thin — spells (PRO)
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: spells (PRO)` (three pre-made spell casts; built here as one cast at its simplest and wired in)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*This builds what Out of scope put off; drop it if the core is not ready. From `Animation_Guide.txt`:*

- [ ] A cast input plays CastBasic (14 frames, 50 ms each) once.
- [ ] On frame 7 a Shot_Basic_Projectile spawns 16 px in front of the feet point and 12 px up (flipped when facing left), with the Basic Muzzle and Impact effects from `assets/characters/seeker/VFX/<palette>/Shots/`.
- [ ] The projectile damages enemies from story 004 using a value in config, and the cast has a data-driven cooldown.
- [ ] The cast input works on gamepad and keyboard.

---

## Implementation Notes

- The CastRapid and CastBig casts (start, loop and end parts) are added by story 014, not here.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 014: the full spell system, the other two casts and its design doc.

---

## Files

- `src/player/player_spells.gd`, `src/player/spell_projectile.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Logic
**Test**: waived at qa.level minimal. Cast at an enemy before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-004-enemy-types.md`
- Unlocks: `production/epics/guardbreak/story-014-deepen-spells.md`
