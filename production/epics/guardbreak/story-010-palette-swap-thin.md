# Story 010: Elemental palette swap, thin

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: S
> **Build step**: thin — elemental palette power-ups
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: elemental palette power-ups` (Void, Ember, Frost and Bone, each with matching FX; built here as a plain swap and wired in)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*This builds what Out of scope put off; drop it if the core is not ready. From the pack's README:*

- [ ] The player can switch between Void, Ember, Frost and Bone from a pickup or a debug key.
- [ ] A swap changes every body animation, the FX layers and the dust and shot effects together, from the matching `Spritesheets/<Palette>/` and `VFX/<Palette>/` folders.
- [ ] The chosen palette is saved and restored with the save file (story 007).
- [ ] The swap changes no gameplay values (powers come in story 015).

---

## Implementation Notes

- File names share one pattern per palette (`Seeker_<Palette>_<Animation>_...`), so a swap is a lookup, not duplicated scenes.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 015: elemental powers and the full palette system. Story 011: the Dream palette.

---

## Files

- `src/player/palette_library.gd`, `src/player/palette_data.tres`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot of each palette in `production/qa/evidence/`, plus sign-off in `production/qa/evidence/palette-swap-evidence.md`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-007-rooms-saves-map.md`
- Unlocks: `production/epics/guardbreak/story-011-dream-seeker-thin.md`, `production/epics/guardbreak/story-015-deepen-palette-power-ups.md`
