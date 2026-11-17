# Story 016: Deepen Dream Seeker state

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Build step**: deepen — Dream Seeker empowered state
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: Dream Seeker empowered state`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Start with `/design-system dream-seeker`: it writes `design/gdd/dream-seeker.md`, which this story's criteria come from.*

- [ ] The Dream Seeker state is built out as `design/gdd/dream-seeker.md` describes.

---

## Implementation Notes

- Builds on the timed swap from story 011. Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Anything the design doc does not describe.

---

## Files

- [to be listed from `design/gdd/dream-seeker.md`]

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot of the state in `production/qa/evidence/`, plus sign-off in `production/qa/evidence/dream-seeker-deepen-evidence.md`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-011-dream-seeker-thin.md`
- Unlocks: None
