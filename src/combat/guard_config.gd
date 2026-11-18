## Tuning values for the guard-break (story 003, design/game-brief.md "Hooks" and
## "Core loop": wear down a guard, break it, land a finisher). Every number the
## [GuardComponent] uses lives here and is set in guard_config.tres; guard_component.gd
## holds no such literals.
##
## Usage: [codeblock]
## var guard := GuardComponent.new()
## guard.config = preload("res://src/combat/guard_config.tres")  # optional, this is the default
## enemy.add_child(guard)
## [/codeblock]
## Units: seconds, and guard / health points. All values must be positive except
## where a group says 0 is allowed.
class_name GuardConfig
extends Resource

@export_group("Guard")
## Size of the guard meter. A guarded enemy starts, and a recovered one ends, full.
@export var max_guard: float
## Guard meter lost per hit while guarded, keyed by attack id ("attack1", "attack2",
## "attack3", "jump_attack", "up_attack", "down_attack", "heavy"). An id that is
## missing costs no guard. A fully charged heavy ignores this: it breaks the guard
## whatever the meter holds.
@export var guard_damage: Dictionary
## Multiplier on the health damage of a hit that lands on a guarded enemy and does not
## break the guard (0 = no damage, 1 = full damage).
@export var guarded_damage_multiplier: float

@export_group("Break")
## Seconds a broken enemy stays staggered. It takes full damage meanwhile.
@export var stagger_time: float
## Multiplier on the damage of a finisher hit landed during the stagger.
@export var finisher_bonus_multiplier: float
## Attack ids that count as a finisher when they hit a staggered enemy.
@export var finisher_attacks: PackedStringArray
## Seconds of the recovering state after the stagger: the guard meter refills from
## empty to full over this time, then the enemy is guarded again.
@export var recovery_time: float

@export_group("Regeneration")
## Seconds without a hit before a guarded enemy's guard meter starts to regenerate.
@export var regen_delay: float
## Guard meter regained per second once regeneration has started.
@export var regen_rate: float

@export_group("Health")
## Health of an enemy carrying the component. The [signal GuardComponent.damaged] signal
## reports how much is left.
@export var max_health: float
