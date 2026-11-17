# Story 001: Seeker controller and movement set

> **Epic**: Guardbreak
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Visual/Feel
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-17

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1` (movement from the pack: run, dash, double jump, wall slide, climb, crouch, grapple, enter door)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features item 1; Goal & fail state) and the pack's `Animation_Guide.txt`:*

- [ ] A player scene runs in a blank test room, using the Seeker sheets from `assets/characters/seeker/Spritesheets/Void/` (Void is the default palette), imported with nearest filtering and no compression.
- [ ] Every animation's origin is its feet point from `Animation_Guide.txt`, so changing animation or facing never shifts the character.
- [ ] Idle and run loop with the guide's timings; run playback speed scales with run speed.
- [ ] Jump and fall pick their frame from vertical speed: 0 takeoff, 1-12 rising, 13-14 apex, 15-25 falling (looped for long falls), 26-27 landing.
- [ ] Double jump plays its flip once, then returns to fall frames 15-25. Dash loops its animation for 0.2-0.3 s.
- [ ] Wall slide faces the wall with the back to it; climb shows frame 0 when still; crouch goes down on frames 0-3, holds 3, stands on 4; enter door plays once, then emits a signal for the room change (story 007).
- [ ] Grapple: throw at an anchor point (frames 0-2), pulled along (frames 3-6 looped), release (frame 7), with the sprite rotated toward the anchor and a rope drawn as a line from hand to anchor (the pack has no rope).
- [ ] Jump, land and dash dust and the double-jump ring spawn at the feet from `assets/characters/seeker/VFX/Void/Dust/`.
- [ ] The body collides as a 10 x 22 px box standing on the feet point; all movement values (run speed, jump, gravity, dash time and speed) come from one config resource, not code constants.
- [ ] Every action is bound for both gamepad and keyboard through the Input Map.

---

## Implementation Notes

*From `design/game-brief.md`, the pack's README and `Animation_Guide.txt`:*

- Slice sheets by the frame size and count in each file name (`Run_30x30_10f` = 10 frames of 30 x 30). Use per-frame durations from the guide.
- The pack suits 16 x 16 tiles and a 320x180, 384x216 or 480x270 base resolution scaled by a whole number; set the base resolution and the default texture filter (nearest) in `project.godot` here.
- Run speed about 140 px/s at 1x matches the run animation timing.
- Godot 4.7.2 is HIGH risk: check `docs/engine-reference/godot/` before using any engine API.
- Attacks and abilities arrive in later stories; this story only reserves their input actions.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: attacks. Story 004: hurt and death. Story 006: locking double jump and grapple behind pickups (here all moves work). Story 007: rooms, doors and saves.

---

## Files

- `src/player/player.gd`, `src/player/player.tscn`
- `src/player/player_config.gd`, `src/player/player_config.tres`
- `src/player/seeker_animations.json`
- `src/player/player_input_bindings.gd`, `src/player/dust_effect.gd`
- `src/test_rooms/movement_test_room.gd`, `src/test_rooms/movement_test_room.tscn`
- `project.godot` (main scene, 480x270 viewport, integer scaling, nearest filtering)
- No test file: waived at qa.level minimal

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*Governed by `qa.level`: at `qa.level: minimal` tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot of the player in the test room (running, wall sliding and grappling) in `production/qa/evidence/`, plus sign-off in `production/qa/evidence/seeker-controller-evidence.md`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/guardbreak/story-002-melee-combat.md`, `production/epics/guardbreak/story-006-ability-gates.md`
