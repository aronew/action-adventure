# Story 008: Bow, thin

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Build step**: thin — bow
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: bow` (a bow that loops into endless multi-shots; built here at its simplest and wired in)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*This builds what Out of scope put off; drop it if the core is not ready. From `Animation_Guide.txt`:*

- [ ] A bow input plays the Bow animation (frames 0-21) once, then loops frames 16-21 for every extra shot while the button is held.
- [ ] An arrow leaves on frames 9, 15 and 21, spawned 8 px in front of the feet point and 13 px up (flipped when facing left), with the Shot_Arrow Release, Projectile and Impact effects from `assets/characters/seeker/VFX/<palette>/Shots/`.
- [ ] Arrows damage enemies from story 004 using a damage value in config.
- [ ] The bow input works on gamepad and keyboard.

---

## Implementation Notes

- Wired into the existing enemy damage path; no ammo, upgrades or aiming yet (story 013).
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 013: the full bow system and its design doc.

---

## Files

- `src/player/player_bow.gd`, `src/player/arrow.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Logic
**Test**: waived at qa.level minimal. Fire at an enemy before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-004-enemy-types.md`
- Unlocks: `production/epics/guardbreak/story-013-deepen-bow.md`
