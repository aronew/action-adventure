## Guard meter and guard-break for any enemy or the boss (story 003,
## design/game-brief.md "Hooks" and "Core loop"). Add it as a child of the enemy, feed it
## every hit with [method take_hit], and call nothing else: it ticks itself.
##
## States: GUARDED -> BROKEN -> RECOVERING -> GUARDED, see [constant TRANSITIONS].
## - GUARDED: a hit drains the meter by its per-attack cost and deals reduced damage.
##   The hit that empties the meter, and a fully charged heavy, break the guard.
##   The meter regenerates after [member GuardConfig.regen_delay] without a hit.
## - BROKEN: the meter is empty, the enemy is staggered for [member GuardConfig.stagger_time]
##   and takes full damage; a finisher attack deals the bonus multiplier.
## - RECOVERING: for [member GuardConfig.recovery_time] the meter refills from empty to
##   full, hits deal full damage and do nothing to the guard. Then GUARDED again.
## The hit that breaks the guard deals full damage (the guard is gone as it lands).
##
## Every value comes from a [GuardConfig]. For tests, call [method take_hit] and
## [method tick] directly: no randomness, and time only enters through the delta.
##
## Usage: [codeblock]
## var guard := GuardComponent.new()
## add_child(guard)
## guard.damaged.connect(func(amount, health_left): print(health_left))
## player.combat.hit_landed.connect(func(target, attack, damage):
##         guard.take_hit(attack, damage, player.combat.heavy_charged))
## [/codeblock]
class_name GuardComponent
extends Node

## Emitted whenever the guard meter changes.
signal guard_changed(value: float, max_value: float)
## Emitted once when the guard breaks and the enemy becomes staggered.
signal guard_broken
## Emitted when the recovery ends and the enemy is guarded again with a full meter.
signal recovered
## Emitted on every hit with the health damage dealt ([param amount], after the
## multipliers) and the health left.
signal damaged(amount: float, health_left: float)

## What the guard is doing.
enum State { GUARDED, BROKEN, RECOVERING }
## What can change the state.
enum Event { GUARD_BROKEN, STAGGER_ENDED, RECOVERY_ENDED }

## The whole transition table: state -> event -> next state. An event not listed for a
## state changes nothing.
const TRANSITIONS := {
	State.GUARDED: {Event.GUARD_BROKEN: State.BROKEN},
	State.BROKEN: {Event.STAGGER_ENDED: State.RECOVERING},
	State.RECOVERING: {Event.RECOVERY_ENDED: State.GUARDED},
}

## Tuning values. The default is guard_config.tres.
@export var config: GuardConfig = preload("res://src/combat/guard_config.tres")

## Current state (read only).
var state := State.GUARDED
## Current guard meter, 0 to [member GuardConfig.max_guard] (read only).
var meter := 0.0
## Current health. Set it to refill (the training dummy does); there is no death yet.
var health := 0.0

## Seconds in the current state; while guarded, seconds since the last hit.
var _state_time := 0.0


## The state [param from] moves to on [param event]; [param from] itself when the table has
## no such transition. Pure: it reads only [constant TRANSITIONS].
static func transition(from: State, event: Event) -> State:
	return TRANSITIONS[from].get(event, from)


func _ready() -> void:
	meter = config.max_guard
	health = config.max_health


func _process(delta: float) -> void:
	tick(delta)


## Reports one hit. [param attack] is the attack id (see [PlayerCombat]), [param damage]
## the health damage the attack dealt before the guard's multipliers, and
## [param charged] whether it was a fully charged heavy (read [member PlayerCombat.heavy_charged]
## when the hit signal arrives).
func take_hit(attack: String, damage: float, charged: bool) -> void:
	var multiplier := 1.0
	if state == State.GUARDED:
		_state_time = 0.0
		var broke := charged and attack == PlayerCombat.ATTACK_HEAVY
		if not broke:
			var cost: float = config.guard_damage.get(attack, 0.0)
			_set_meter(maxf(meter - cost, 0.0))
			broke = meter <= 0.0
		if broke:
			_enter(transition(state, Event.GUARD_BROKEN))
		else:
			multiplier = config.guarded_damage_multiplier
	elif state == State.BROKEN and config.finisher_attacks.has(attack):
		multiplier = config.finisher_bonus_multiplier
	var amount := damage * multiplier
	health = maxf(health - amount, 0.0)
	damaged.emit(amount, health)


## Advances the stagger, the recovery and the regeneration by [param delta] seconds. Called
## every frame by the component itself.
func tick(delta: float) -> void:
	_state_time += delta
	match state:
		State.GUARDED:
			if _state_time >= config.regen_delay:
				_set_meter(minf(meter + config.regen_rate * delta, config.max_guard))
		State.BROKEN:
			if _state_time >= config.stagger_time:
				_enter(transition(state, Event.STAGGER_ENDED))
		State.RECOVERING:
			if _state_time >= config.recovery_time:
				_enter(transition(state, Event.RECOVERY_ENDED))
			else:
				_set_meter(config.max_guard * _state_time / config.recovery_time)


func _enter(next: State) -> void:
	if next == state:
		return
	state = next
	_state_time = 0.0
	match state:
		State.BROKEN:
			_set_meter(0.0)
			guard_broken.emit()
		State.GUARDED:
			_set_meter(config.max_guard)
			recovered.emit()


func _set_meter(value: float) -> void:
	if value == meter:
		return
	meter = value
	guard_changed.emit(meter, config.max_guard)
