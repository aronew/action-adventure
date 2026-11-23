## Health and invulnerability of the Seeker (story 004, design/game-brief.md "Goal &
## fail state": the run fails when health reaches zero).
##
## Pure logic: it holds no nodes and reads no input. [Player] creates it, feeds it hits
## with [method take_damage] and advances it with [method tick] once per physics tick.
## After a hit that lands, further hits are ignored for the invulnerability time.
## Every value comes from [method configure]; for tests, call configure, take_damage and
## tick directly: no randomness, time only enters through the delta.
##
## Usage: [codeblock]
## var health := PlayerHealth.new()
## health.configure(config.max_health, config.invulnerability_time)
## health.depleted.connect(func() -> void: print("dead"))
## if health.take_damage(10.0):
##         print(health.current)
## health.tick(delta)
## [/codeblock]
class_name PlayerHealth
extends RefCounted

## Emitted on every hit that lands, with the damage taken and the health left.
signal damaged(amount: float, health_left: float)
## Emitted once, on the hit that brings health to zero.
signal depleted
## Emitted when [method heal] restores health, with the amount restored and the new health.
signal healed(amount: float, health_now: float)

## Health the player starts and respawns with (read only; set through configure).
var max_health := 0.0
## Current health, 0 to [member max_health] (read only).
var current := 0.0

var _invulnerability_time := 0.0
var _invulnerable_left := 0.0


## Sets the limits and refills health. [param invulnerability_time] is the seconds after
## a landed hit during which further hits are ignored.
func configure(health_max: float, invulnerability_time: float) -> void:
	max_health = health_max
	_invulnerability_time = invulnerability_time
	reset()


## Refills health and clears the invulnerability (respawn).
func reset() -> void:
	current = max_health
	_invulnerable_left = 0.0


## Applies [param amount] damage unless the player is invulnerable or already at zero.
## Returns true when the hit landed.
func take_damage(amount: float) -> bool:
	if not can_be_hit():
		return false
	current = maxf(current - amount, 0.0)
	_invulnerable_left = _invulnerability_time
	damaged.emit(amount, current)
	if current <= 0.0:
		depleted.emit()
	return true


## Restores up to [param amount] health, never above [member max_health] and never at
## zero health. Leaves the invulnerability window alone. Returns the amount restored.
func heal(amount: float) -> float:
	if amount <= 0.0 or current <= 0.0:
		return 0.0
	var restored := minf(amount, max_health - current)
	if restored <= 0.0:
		return 0.0
	current += restored
	healed.emit(restored, current)
	return restored


## True when health is below max and above zero.
func is_hurt() -> bool:
	return current > 0.0 and current < max_health


## Advances the invulnerability window by [param delta] seconds.
func tick(delta: float) -> void:
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)


## True while a hit would land: health above zero and no invulnerability left.
func can_be_hit() -> bool:
	return current > 0.0 and _invulnerable_left <= 0.0


## True during the invulnerability window after a landed hit.
func is_invulnerable() -> bool:
	return _invulnerable_left > 0.0


## True once health has reached zero.
func is_depleted() -> bool:
	return current <= 0.0
