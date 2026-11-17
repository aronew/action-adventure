# Story 007: Rooms, doors, save points and the grid map

> **Epic**: Guardbreak
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 7` (rooms with doors, save points and a grid map that fills in); the fail state in Goal & fail state (respawn at the last save point)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features item 7, Goal & fail state, First minute):*

- [ ] Rooms are separate scenes; entering a door plays the pack's EnterDoor animation once, then loads the connected room and places the player at the paired door.
- [ ] The camera follows the player and stays inside each room's bounds.
- [ ] A save point saves the room, the owned abilities (story 006), the boss-defeated flag (story 005) and the map's discovered rooms to a versioned save file.
- [ ] Launching the game can continue from that save.
- [ ] Player death (story 004) respawns at the last save point with full health.
- [ ] A grid map screen opens from a button and shows visited rooms, filling in as the player explores; its state is saved.
- [ ] The test region has at least 4 connected rooms including the ability gates (story 006) and the boss arena (story 005), with one loop or shortcut *(guessed)*.
- [ ] Retained screenshots of the map screen are kept as evidence.

---

## Implementation Notes

- Design the save file as data (a versioned dictionary or resource), so later systems (palette, bow) add fields without breaking old saves.
- First minute (brief): wake in a quiet room, learn move, jump and dash across a gap, then meet the first guarded enemy.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 012: deepening level design beyond the thin stand-in. More than one region is out of scope.

---

## Files

- `src/world/room.gd`, `src/world/door.gd`, `src/world/save_point.gd`, `src/world/save_game.gd`
- `src/ui/map_screen.tscn`, `src/world/rooms/*.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived (advisory).*

**Story Type**: Integration
**Test**: waived at qa.level minimal. The map screen is UI, so its retained screenshot in `production/qa/evidence/` is required. Also play save, quit, continue before the story closes.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/guardbreak/story-005-region-boss.md`, `production/epics/guardbreak/story-006-ability-gates.md`
- Unlocks: `production/epics/guardbreak/story-010-palette-swap-thin.md`, `production/epics/guardbreak/story-012-deepen-level-design.md`
