# Story 011: Dream Seeker empowered state, thin

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Build step**: thin — Dream Seeker empowered state
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: Dream Seeker empowered state` (the fifth, holographic palette as a special empowered state; built here as a timed swap and wired in)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*This builds what Out of scope put off; drop it if the core is not ready. From the pack's README:*

- [ ] An empowered state can be triggered from a pickup or a debug key and lasts a data-driven time.
- [ ] While it lasts, the player swaps to the Dream palette (body, FX layers, dust and shots) using story 010's palette lookup.
- [ ] The Power_Burst effect plays on entry and the Aura_Loop effect plays during the state, from `assets/characters/seeker/VFX/Dream/`.
- [ ] A damage multiplier from config applies while empowered *(guessed: default 1.25)*, and the previous palette returns when it ends.

---

## Implementation Notes

- The Dream palette's slashes and effects are rainbow holographic; the dark outline keeps it readable on bright levels (pack README).
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 016: how the state is earned, its meter and its design doc.

---

## Files

- `src/player/empowered_state.gd`, `src/player/empowered_config.tres`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot of the empowered state in `production/qa/evidence/`, plus sign-off in `production/qa/evidence/dream-seeker-evidence.md`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-010-palette-swap-thin.md`
- Unlocks: `production/epics/guardbreak/story-016-deepen-dream-seeker.md`
