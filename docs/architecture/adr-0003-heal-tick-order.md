# ADR-0003: Heal completion runs after every hit on the same physics tick

## Status
Proposed (owner chose the helper-node approach on 2026-11-23; `technical-director` to confirm before the first Healing story)

## Date
2026-11-23

## Last Verified
2026-11-23. Read against `src/player/player.gd`, `player_combat.gd`, `enemy_base.gd` and `boss.gd` by the `gameplay-programmer` and `godot-specialist` lenses of the fifth Healing design review. Every Godot engine behaviour below is from memory of 4.x source: `docs/engine-reference/godot/` has no scripting, Input, `time_scale` or CanvasItem pages, and the installed editor version is NOT DETERMINED. Each is marked **verify in story 1**.

## Decision Makers
Project owner (approach, 2026-11-23); Claude (author); `gameplay-programmer` and `godot-specialist` (review findings folded in).

## Summary
`design/gdd/healing.md` rule 15 requires that a hit which lands on the physics tick a heal would complete always wins. Hits reach the Seeker by polling inside the hitter's own `_physics_process` (priority 0), so the Seeker must not decide completion before every hitter has acted. The first draft set the whole Seeker to `process_physics_priority = 10`. That moves `health.tick` and `PlayerCombat.update` after the hitters and changes Combat and Enemies behaviour. **Decision:** the Seeker stays at priority 0 and a small helper node at priority 10 runs only the heal's completion test.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core (scene-tree processing order), Input, Physics |
| **Layer** | Foundation (gameplay) |
| **Knowledge Risk** | HIGH for 4.5 to 4.7; the APIs used here predate 4.3 but the reference does not cover them |
| **Post-Cutoff APIs Used** | None known |
| **Verification Required** | Everything under "Engine behaviour to verify in story 1" below |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | Healing stories (the `HEAL` state, AC-18) |
| **Blocks** | The first Healing story that implements completion |
| **Ordering Note** | Independent of ADR-0001 and ADR-0002 |

## Context

### Problem
A heal completes on the tick its timer reaches `channel_time`. A hit that lands on that tick must cancel it first, deterministically, whatever the scene-tree order is. Hits are polled by the callers of `Player.take_hit`: `EnemyBase._state_attack` (`enemy_base.gd`), the boss melee, and the boss's `Shockwave` `Area2D`, all in their own `_physics_process` at priority 0. A hit is therefore already applied when a later-running node looks at the Seeker. An earlier-running node cannot see it.

### What the first draft got wrong
Setting the Seeker itself to priority 10 does not change what a hitter sees of the invulnerability window (a hitter on tick k+1 sees the same remaining time either way). It changes two other things, neither of which the draft listed:
1. `take_hit` now lands before the Seeker's tick, so `_state_hurt` decrements the hurt lock on the hit tick itself: **the lock is one tick shorter** than today.
2. `PlayerCombat.update` runs after the foes, so a **Seeker swing and a foe strike on the same tick now resolve in the foe's favour**. Today a swing that lands first can flinch a winding foe and turn off its hitbox (`enemy_base.gd` lines near 234 and 312). Foes also read the Seeker's position one tick staler.
Those would force re-deriving `combat.md` and `enemies.md` acceptance criteria for a feature that only needs one ordering guarantee.

### Constraints
- Combat and Enemies behaviour must not change.
- The result must be deterministic and provable by a real-SceneTree test (AC-18), not a hand-called `_physics_process`.
- Pause, hit-stop and the unit-test seam (`HealChannel`, see `docs/architecture/healing-implementation-notes.md`) must keep working.

## Decision

1. **Split the per-tick heal logic in two.**
   - `_state_heal` in the Seeker (priority 0) does everything except the completion: movement and the planting skid, cancel presses, release and toggle handling, the stick cancel, and the timer advance (rule 15, steps a to c). When the advanced timer reaches `channel_time - 0.0001`, it sets `completion_pending = true`. It does not heal.
   - A child node `HealCompletion` of the Player, `process_physics_priority = 10`, runs after every priority-0 node. In its `_physics_process` it completes the heal **only if the Player is still in `HEAL` and `completion_pending` is true**, then clears the flag. If a hitter landed a hit after the Seeker's own tick, the Player is already in `HURT` or `DEAD`, the flag was cleared by `_set_state`, and nothing is healed.
2. **The rule for callers.** Any node that calls `Player.take_hit` must run at priority 0 or lower and must call it inside its own `_physics_process`. A deferred call (`call_deferred`) or a signal queued to the next flush runs after the physics pass and breaks the guarantee. AC-18d is a static test over `src/` that fails on a `take_hit(` caller outside the allowlist (`EnemyBase`, the boss, its `Shockwave`) and on any `call_deferred("take_hit"` or deferred connection to it.
3. **Hit-stop.** `Engine.time_scale` must be restored from a static or autoload counter, not from a coroutine owned by a foe that can be freed (a scene reload on death can free it mid-wait and leave the scale stuck at the hit-stop value). Overlapping hit-stops are counted, so the shorter one does not restore early. A requirement, not a paragraph of analysis: at the hit-stop scale of 0.05 and 0.25 s real, one hit-stop stretches a channel by less than a physics tick of game time.
4. **Pause and unpause.** The Seeker's `_physics_process` does not run while paused, so it cannot see the resume itself. It stores `Engine.get_physics_frames()` at the end of each tick; a gap greater than 1 on the next tick means a resume, and a `heal` press on that tick is not a heal press (rule 14). **Verify in story 1:** whether `NOTIFICATION_UNPAUSED` is simpler, and whether `is_action_just_pressed` is already false for a press made during the pause (it is frame-stamped, as recalled).
5. **Sub-tick taps.** `Input.is_action_just_pressed` in `_physics_process` can miss a press and release that fall between two physics ticks. The Seeker also sets a latch from `_unhandled_input` (`event.is_action_pressed(&"heal")`) that `_physics_process` consumes on the next tick. **Verify in story 1:** that the latch fires once per press and respects the pause rule above.

## Alternatives Considered

### Seeker-wide `process_physics_priority = 10`
Rejected: see "What the first draft got wrong". It is the simplest to write and changes Combat and Enemies.

### Rely on scene-tree order
Rejected: the Seeker, enemies and the boss arena are instanced at run time, the order is an accident of the scene, and the boss's `Shockwave` is added by code.

### Re-test completion after the foes inside the Seeker's own tick
Rejected: a later-running hitter cannot be seen by a test that runs earlier. Only an ordering fix works.

## Consequences

### Positive
- Combat, Enemies and the hurt-lock and invulnerability boundary cases are unchanged.
- The guarantee is local to one 10-line node and provable by AC-18.

### Negative
- The heal's timer and its completion live in two nodes; a stale `completion_pending` flag would be a bug. `_set_state` clears it on every exit from `HEAL`, and AC-18 and AC-14 guard it.
- The rule for `take_hit` callers is a convention enforced by a grep test.

### Risks
- **Godot ordering semantics.** Mitigation: AC-18 steps the real physics server with a probe node that records call order, one test per caller.
- **A future hazard using `body_entered`** calls `take_hit` from the physics flush, probably before the tree's `_physics_process` pass and so safe at any priority (unverified). The grep test would still flag it; the fix is to review it on that day, not to loosen the rule now.

## GDD Requirements Addressed

| GDD | Requirement | How |
|-----|-------------|-----|
| `design/gdd/healing.md` | Rule 15: a hit that lands on the completion tick wins | Decision 1 |
| `design/gdd/healing.md` | Rule 14: a press on the first tick after a pause is not a heal press; sub-tick taps | Decisions 4 and 5 |
| `design/gdd/healing.md` | Edge Cases: pause and hit-stop | Decisions 3 and 4 |

## Validation Criteria
1. AC-18 (a to e) passes against the real SceneTree for the three callers, with the hitter before and after the Seeker in the tree.
2. AC-18d: priorities and the caller allowlist, and no deferred `take_hit`.
3. `combat.md` and `enemies.md` acceptance criteria still pass unchanged.
4. Each "verify in story 1" item is confirmed or this ADR is amended with what the engine does.
