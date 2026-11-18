# Story 002: Melee: 3-hit combo, air/up/down attacks, charged heavy

> **Epic**: Guardbreak
> **Status**: Complete
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
- [ ] The player keeps running while swinging (facing locked for the swing), and each ground swing and the heavy release step forward a little; the pogo is easy to land: no fast fall during an attack, fast fall needs down held a moment, and the down attack caps the fall speed. *(added after playtest)*

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

- `src/player/player_combat.gd` (new): attack chain, air/up/down attacks, charged heavy, hit frames, cancel windows, FX layer
- `src/player/attack_config.gd`, `src/player/attack_data.tres` (new): every attack value
- `src/player/player.gd`: combat wiring, ATTACK state, pogo
- `src/player/seeker_animations.json`: attack Body clips and a combat_fx group (FX layers, BladeGlow)
- `src/player/player_camera.gd`: request_shake for Attack3
- `src/player/player_input_bindings.gd`: doc comment only
- `src/test_rooms/hit_target.gd` (new), `src/test_rooms/movement_test_room.gd`: three hit targets
- No test file: waived at qa.level minimal

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

## Completion Notes
**Completed**: 2026-11-17
**Criteria**: 10/10 passing, by the user's own playtest on their machine; none observed in a retained image
**Deviations**: Closed without the required Visual/Feel evidence: no retained screenshot in `production/qa/evidence/story-002-melee-combat/` and no sign-off file. The user chose "Close anyway, accepting it". Run result here was NOT VERIFIED (no Godot binary in the cloud container); the build was run only on the user's machine.
**Test Evidence**: none retained (tests waived at qa.level minimal; the screenshot gap was accepted by the user)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE and LP-CODE-REVIEW skipped — Solo mode)

## Calls beyond the design
- Damage placeholders in `src/player/attack_data.tres`: attack1 10, attack2 12, attack3 20, jump 10, up 10, down 8, heavy 30, charged x2 · kept 2026-11-17
- Input in `src/player/player_combat.gd`: a ground tap swings on release; held 0.18 s it starts the heavy; chain buffer 0.25 s; up attack ground-only (up + X in the air is the jump attack); door wins over up attack · kept 2026-11-17
- Heavy in `attack_data.tres`: charge 0.9 s from frame 4, glow step 0.22 s to 0.05 s, ready flicker 0.04 s; release before frame 4 finishes the wind-up and strikes uncharged · kept 2026-11-17
- Movement during attacks in `src/player/player.gd`: running while swinging with facing locked; lunge attack1 60, attack2 70, attack3 100, heavy 140 px/s; glide deceleration 500; dash, jump and grapple cancel from each attack's recovery frame; only the Attack1-3 combo chains · kept 2026-11-17
- Pogo: bounce 260 px/s refreshing double jump and dash; fast fall needs down held 0.2 s and never during an attack; down attack caps the fall at 220 px/s · kept 2026-11-17
- Attack3 camera shake 3 px for 0.15 s; hitbox rectangles from the FX frame bounds; hit layer 8, group "hittable"; three test targets in `src/test_rooms/movement_test_room.gd` · kept 2026-11-17
- Later tuning after close, from playtest (2026-11-17/18): hold threshold 0.18 -> 0.14 s; heavy wind-up plays at 2.5x; charge counts from the press with the glow blinking from the pull-back, full at 0.55 s; full-charge burst and flash; every X pressed during a swing is queued until used (the 0.25 s chain buffer is gone); press and hold X mid-swing goes into the heavy · kept by the user
