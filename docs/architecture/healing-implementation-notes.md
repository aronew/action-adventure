# Healing: implementation notes

> Companion to `design/gdd/healing.md` and `docs/architecture/adr-0003-heal-tick-order.md`. These are **recipes for the stories, not design rules**: the GDD says what must be observable, this file says one way to build it. Split out of the GDD in the fifth design review (2026-11-23) so a change here never needs a design re-review. Engine behaviour is from memory of Godot 4.x and **unverified against 4.7.2** (`docs/engine-reference/godot/` has no scripting, Input, shader or `time_scale` pages): each such claim is marked *verify*.

## 1. Components

| Piece | Kind | Owns |
|-------|------|------|
| `HealMeter` | `RefCounted`, owned by `Player` beside `health` | `value`, `capacity`, `add(damage)`, `spend()`, `reset()`, `rescale(old, new)`; no input, no nodes. Never held in `PlayerState` (an exported Resource that may be saved) |
| `HealChannel` | `RefCounted` | The per-tick heal logic (rules 6 to 9, 14, 15): start test, press buffer, timer, cancels, completion test. Pure: no `Input`, no nodes |
| `HealingConfig` | `Resource`, e.g. `src/player/healing_config.tres` | The Values table of the GDD; `validate()` |
| `HealCompletion` | `Node`, child of `Player`, `process_physics_priority = 10` | The completion test after every hitter (ADR-0003) |
| `HealLog` | `RefCounted` | AC-26's CSV writer |

`Player` owns the `HEAL` state (`Player.State.HEAL`, appended to the enum) and its `_state_heal`.

## 2. The `HealChannel` seam

`step(input: HealStepInput) -> HealStepResult`. Pure and deterministic, so the input-driven Logic ACs call it directly with one input record per tick.

**`HealStepInput` fields:** `delta`; `held` (the heal action is down); `just_pressed` (a fresh press this tick, from `Input` or the `_unhandled_input` latch); `heal_mode` (`hold` or `toggle`); `player_state` (the controller state: `GROUND`, `AIR`, `ATTACK`, `HURT`, `CROUCH`, and the rest); `grounded_flag_in_ground` (landing or standing-up animation, which does not block); `health`; `max_health`; `meter` and `capacity`; `cancel_action` (`none`, `grapple`, `dash`, `interact`, `attack`, `jump`: the action that **would start** this tick, resolved by the Player calling the real `_try_start_*` predicates in rule 9's order, see 3); `stick_push` (a fresh horizontal push past the deadzone, toggle mode only); `hit_landed` (a hit cancelled the channel this tick); `died`; `on_floor`; `resumed_this_tick`; `door_or_rest_overlapped`.

**`HealStepResult` fields:** `state` (`IDLE` or `CHANNEL`); `timer`; `progress` (0 to 1); `meter` and `health` after the step; `events` (an ordered list of `started`, `completed(effective)`, `cancelled(reason)`, `refused(reason)`, `meter_full`); `completion_pending`.

`HealChannel` owns the rule 6 start test and the press buffer (`press_age`, advanced by `delta`, cleared when a press is spent). The Player owns reading `Input`, the state enum and calling the `_try_start_*` predicates. Because the cancel dispatch lives in the Player, **AC-16 and AC-28e (which action wins) are Integration tests**; the Logic ACs cover everything the step decides by itself.

## 3. Cancel dispatch

- `_state_heal` runs, in order: involuntary exits (already applied by `_set_state` when a hit, death, door or rest took over), the voluntary action presses, the stick cancel, release or second press, then the timer advance (rule 15).
- **A cancel press cancels only if the action would start.** Call `_try_start_grapple()`, `_try_start_dash()` and the door or rest `interact` handler, then attack (arms Combat's tap or hold resolution) and jump, in that order, from `_state_heal` directly. `_try_start_dash` fails on cooldown and `_try_start_grapple` fails with no anchor or when the ability is not owned (`player.gd` near lines 636 and 682); a failed start leaves the channel running. Do **not** poll climb here: climb sits before jump in `_state_ground` (grapple, dash, door `interact`, `combat.poll`, climb, jump), and during a channel it must neither cancel nor pre-empt the jump.
- On a successful cancel, `_set_state(GROUND)` runs, then the winning action's handler. There is precedent for a same-tick `_set_state` then handler in `_state_attack` (`player.gd` near line 433). `combat.cancel()` in `_set_state` clears Combat's `_pending`, so Combat's arming from an attack cancel survives.
- **Cancel reason.** `_set_state(new_state)` has no reason argument and `AIR` is ambiguous (jump press or edge slide). Set `_heal_cancel_reason: StringName` before the transition (`take_hit`, `_state_heal`, the door and rest handlers), default `&"other"`, and emit `heal_cancelled(reason)` from the exit path in `_set_state`.
- **Jump buffer.** The buffer is written every tick before the state dispatch (`player.gd` about lines 229 to 231). It is zeroed on entry to `HEAL` and on every exit except a jump cancel, whose dispatched jump consumes it. (The "zero on entry" step is defence only: `_state_ground` polls jump before heal, so a live buffer already fires the jump first.)
- **Tick 0.** `_state_ground` returns after a start, so tick 0 applies no gravity and no skid. Fix this in the AC-12 bound: assert horizontal position only, and state whether tick 0 moves.
- **`heal_end` clip.** `GROUND` replays `idle` every tick, so `heal_end` is gated by a flag like `_landing` and `_standing_up`. `_set_state` clears those flags, so **set the `heal_end` flag after `_set_state(GROUND)`** on the completion path or it is wiped. Its end needs a case in `_on_animation_finished`; a looping clip never finishes.

## 4. Input

- **Detection.** Start and buffered presses use `Input.is_action_just_pressed`, plus the `_unhandled_input` latch of ADR-0003 (decision 5). A hold-mode release is `not Input.is_action_pressed`, never `just_released`, because a release during a pause loses its edge. *Verify:* `just_pressed` is frame-stamped, so a press made during a pause is not reported after it.
- **Resume.** A `heal` press on the first tick after a resume is ignored (ADR-0003, decision 4).
- **Actions.** `heal` is added to `PlayerInputBindings.BINDINGS` and `register()` skips an action that already exists, so the code is the one place its default lives and `project.godot` must not also define it. **The default keyboard key is A** (owner, 2026-11-23); it must not be registered while `move_left` still holds A (see Open Question 1 of the GDD).
- **Stick cancel (toggle mode).** A fresh horizontal push: the stick or D-pad horizontal axis crosses from inside the deadzone (`stick_cancel_deadzone`, default 0.5, the project's `DEADZONE`) to outside it after the channel starts. A direction already held at the press does not cancel until it has returned inside the deadzone. Up is never a stick cancel (`interact` shares Up).

## 5. Timer and time

The timer accumulates the `delta` of the Seeker's own `_physics_process`. Tests use `is_equal_approx`, never exact float equality (60 accumulated additions are not bit-exact). The Player has no `Timer` child and no `create_timer` or `Time.get_ticks_*` in the heal path (a static grep test). `Engine.time_scale` is never touched by unit tests, and one test asserts `Engine.physics_ticks_per_second == 60` because every "tick 60" criterion depends on it (it is the default; `project.godot` does not set it). The Player's process mode is inherited and resolves to pausable; assert behaviour (`can_process()` is false while paused), not the property value.

## 6. Meter edge cases in code

- **Full test.** `heal_meter >= capacity - 0.001`. After a capacity change the meter is `value x new / old`; snap to `capacity` when the fraction is at least 1 - 1e-6, and guard `old <= 0` (do nothing).
- **Bad damage.** `damage` must be finite: `is_finite(damage) and damage > 0`, else add nothing (a NaN would poison the meter for good).
- **Killing blow.** The fill handler guards with `is_instance_valid(target)`. `foe` is a `const GROUP_FOE` in `PlayerCombat`.
- **Signals the controller emits:** `heal_started`, `heal_completed(effective: float)`, `heal_cancelled(reason: StringName)`, `meter_full`, `heal_refused(reason: StringName)`. A read-only `heal_progress` (0 to 1, game time, frozen by a pause) lets the HUD and Audio drive the swell and the 0.5 s pip. Reasons for `heal_cancelled`: `&"release"`, `&"hit"`, `&"death"`, `&"door"`, `&"rest"`, `&"edge"`, `&"jump"`, `&"dash"`, `&"grapple"`, `&"attack"`, `&"stick"`, `&"full_health"`. Reasons for `heal_refused`: `&"meter"`, `&"health"` (a movement-state refusal emits nothing).

## 7. Config

`HealingConfig.validate()` returns a `PackedStringArray` of every value outside its range, including `capacity_floor` and `stick_cancel_deadzone`, and a `heal_share` or `meter_cost_ratio` combination that puts the capacity below `capacity_floor` at 100 max health is allowed (the floor applies). The caller takes an injected `report: Callable` (production passes one that calls `push_error`), reports a non-empty result and clamps each value on a **duplicate** of the loaded resource, never on the shared cached `.tres`. `duplicate()` is shallow: fine for a flat resource of floats; if a nested Resource is ever added, duplicate deeply. If `HealingConfig` hangs off `PlayerConfig`, assign the clamped duplicate back, or the Player keeps the cached one. `@export_range` limits the editor only and never clamps a `.tres` at run time.

## 8. The channel glow

A requirement, not a recipe, lives in the GDD (capped at Bone Pale, luma 0.64, never above the heavy-ready flash or the blink). One way to meet it:
- A `CanvasItem` shader on a material owned by this Player (not an instance uniform, which `CanvasItem` does not offer: *verify*) with a `heal_t` uniform set through `set_shader_parameter`.
- In a canvas_item shader the fragment `COLOR` already contains `texture x self_modulate x modulate`, so `mix(COLOR, target, heal_t)` would bake in the heavy-ready flash (`_sprite.modulate`, `player.gd` near 739) and the invulnerability blink (`self_modulate.a`, near 1048). Instead sample `texture(TEXTURE, UV)` directly, rebuild the colour, mix toward the capped target, and take **only alpha** from `COLOR.a` so the blink still works.
- A child overlay sprite cannot read the parent sprite's pixels, so it cannot do the mix.
- `PlayerCombat` has its own `_body`, `_fx` and `_glow` `AnimatedSprite2D`s and dash ghosts copy sprites (`player.gd` near 1077): confirm which sprite is visible during `HEAL` and put the material there. The heavy-ready flash tween is not killed by `_set_state`, so it can still be running when a heal starts.
- The idle aura is gated on `GROUND` and is hidden in `HEAL`.

## 9. Animation clips

`seeker_animations.json` has no heal clip. Add `heal_loop` (planted pose, `loop` true) and `heal_end` (not looping). A missing clip is a **hard error** (`_play_loop` and `_start_clip` index `_pivots[clip]`), so the clips and sheets ship before the state code. `_play_loop` only replays on a clip change, so `heal_loop` is safe. Frame counts are the animator's and are never tied to `channel_time`.

## 10. Test practicalities

- The Logic ACs drive `HealChannel` and `HealMeter` directly. A hand-called `_physics_process` cannot prove tick ordering: AC-18 steps the real physics server with a probe node that records call order, and a hitter's overlap is established at least one step earlier (`get_overlapping_*` report the last step).
- `Input.action_press` and `Input.action_release`, and the gdUnit4 scene runner's `simulate_action_*`, do work headless; use them for Integration tests that need real `Input`.
- AC-8's 3600 ticks run on the pure meter, not on 3600 real frames.
- AC-16d needs a Combat accessor for "an attack is pending" (`_pending` is private); add a test accessor or assert on the observable swing.
- A test that reads `heal` calls `PlayerInputBindings.register()` first. Every "no cue" assertion is paired with a positive control (the same press in a state that does emit).
- Fixture: `tests/fixtures/healing_config_test.tres` pins the defaults the ACs use, and a boss fixture pins the guard values for AC-23.
