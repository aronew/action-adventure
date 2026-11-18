# Story 006: Double jump and grapple found in the world

> **Epic**: Guardbreak
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-18

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 6` (double jump and grapple found in the world, each opening routes and new attack angles)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features item 6, Core loop, Hooks):*

- [ ] In the gate test rooms the player starts without double jump and grapple; owning each is a flag in a player-state resource, not a scene-local variable. The movement room, enemy room and boss arena keep both unlocked for testing (user's choice, 2026-11-18); story 007 sets the real starting state.
- [ ] A pickup in the world grants each ability once and the flag persists (the save system stores it in story 007).
- [ ] Without double jump, the input does nothing (no animation, no dust); with it, story 001's double jump works.
- [ ] A gate for each ability blocks a route until the ability is owned: a gap too wide for a single jump, and a ledge reachable only by grapple.
- [ ] No soft-lock: each gate area can be left again whatever the player owns.
- ~~Each ability adds one combat option~~ — left out for now at the user's choice (2026-11-18): the abilities only open routes.
- [ ] Verified in two or three connected test rooms.

---

## Implementation Notes

- Movement already exists from story 001; this story only gates it and places pickups.
- Gate checks read the player-state resource, so any gate or pickup can use them.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 007: persisting the flags across saves and the full room layout.

---

## Files

- `src/player/player_state.gd`, `src/world/ability_pickup.gd`, `src/world/ability_gate.gd`
- `src/test_rooms/gate_test_rooms.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Integration
**Test**: waived at qa.level minimal. Play each gate with and without its ability before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-001-seeker-controller-movement.md`
- Unlocks: `production/epics/guardbreak/story-007-rooms-saves-map.md`
