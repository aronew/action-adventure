## Tuning values of the first-region boss (story 005, design/game-brief.md "Hooks": the
## guard-break is the central hook; "Kill condition": if the guard-break fight is not fun
## in one arena after two tuning rounds, drop or rethink it, so every number lives here and
## is tuned in boss_config.tres).
##
## It is an [EnemyConfig] (body, movement, getting hit, death impact) plus the boss's guard
## numbers and one block per attack pattern. [Boss] writes the numbers of the pattern it
## starts into its own copy of the shared attack fields ([member EnemyConfig.telegraph_time],
## [member EnemyConfig.attack_active_time], [member EnemyConfig.attack_recovery_time],
## [member EnemyConfig.attack_damage], [member EnemyConfig.attack_hitbox],
## [member EnemyConfig.attack_lunge_speed]) so [EnemyBase] telegraphs and strikes with them.
## Those six fields are therefore left out of boss_config.tres, as are the patrol and
## awareness fields (the boss stands still until the fight starts, then always hunts).
## [member EnemyConfig.attack_range] is the distance the boss walks up to between attacks.
## [member EnemyConfig.attack_cooldown] is the pause after every pattern, on top of its recovery.
##
## Units: pixels, px/s, seconds and health points. Distances are horizontal, feet to feet.
##
## Usage: [codeblock]
## var boss := Boss.new()
## boss.config = preload("res://src/enemies/boss/boss_config.tres")
## boss.target = player
## add_child(boss)
## [/codeblock]
class_name BossConfig
extends EnemyConfig

## The boss's attack patterns. Ints, so a pattern can be stored and compared as one.
enum Pattern { SLAM, LUNGE, RANGED }

@export_group("Guard")
## Size of the guard meter ([member GuardConfig.max_guard]).
@export var guard_max: float
## Guard lost per hit while guarded, keyed by attack id ([member GuardConfig.guard_damage]).
## A fully charged heavy breaks the guard whatever the meter holds.
@export var guard_costs: Dictionary
## Multiplier on the health damage of a hit that does not break the guard.
@export var guarded_damage_multiplier: float
## Seconds the broken boss stays staggered, taking full damage: the damage window.
@export var stagger_time: float
## Multiplier on the damage of a finisher hit landed during the stagger.
@export var finisher_bonus_multiplier: float
## Attack ids that count as a finisher.
@export var finisher_attacks: PackedStringArray
## Seconds after the stagger in which the meter refills and hits still deal full damage.
@export var guard_recovery_time: float
## Seconds without a hit before the guard meter starts to regenerate.
@export var guard_regen_delay: float
## Guard meter regained per second once regeneration has started.
@export var guard_regen_rate: float

@export_group("Flow")
## Seconds after a stagger ends before the boss may start its next wind-up.
@export var post_stagger_cooldown: float

@export_group("Overhead slam")
## Closest and farthest distance to the player at which the slam may be chosen.
@export var slam_min_distance: float
@export var slam_max_distance: float
## Seconds of the long wind-up.
@export var slam_telegraph_time: float
## Seconds the hitbox is live.
@export var slam_active_time: float
## Seconds the boss is open after the live window.
@export var slam_recovery_time: float
## Damage on the player.
@export var slam_damage: float
## Hitbox: size and centre offset from the feet point, written facing right.
@export var slam_hitbox: Rect2

@export_group("Sweeping lunge")
## Closest and farthest distance to the player at which the lunge may be chosen.
@export var lunge_min_distance: float
@export var lunge_max_distance: float
## Seconds of the wind-up.
@export var lunge_telegraph_time: float
## Seconds the boss dashes with its hitbox live.
@export var lunge_active_time: float
## Seconds the boss is open after the dash.
@export var lunge_recovery_time: float
## Damage on the player.
@export var lunge_damage: float
## Hitbox: size and centre offset from the feet point, written facing right. It moves with the boss.
@export var lunge_hitbox: Rect2
## Dash speed; the dash covers this times [member lunge_active_time].
@export var lunge_speed: float

@export_group("Ranged shockwave")
## Closest and farthest distance to the player at which the shockwave may be chosen.
@export var ranged_min_distance: float
@export var ranged_max_distance: float
## Seconds of the wind-up.
@export var ranged_telegraph_time: float
## Seconds from the release (the shockwave leaves) until the recovery starts.
@export var ranged_active_time: float
## Seconds the boss is open after the release.
@export var ranged_recovery_time: float
## Damage on the player.
@export var ranged_damage: float
## Travel speed of the shockwave along the ground.
@export var ranged_speed: float
## Size of the shockwave, standing on the ground. Low enough to be jumped.
@export var ranged_size: Vector2
## Seconds the shockwave travels before it vanishes.
@export var ranged_lifetime: float


## Builds the boss's [GuardConfig] from the guard fields above.
func make_guard_config() -> GuardConfig:
	var guard := GuardConfig.new()
	guard.max_guard = guard_max
	guard.guard_damage = guard_costs
	guard.guarded_damage_multiplier = guarded_damage_multiplier
	guard.stagger_time = stagger_time
	guard.finisher_bonus_multiplier = finisher_bonus_multiplier
	guard.finisher_attacks = finisher_attacks
	guard.recovery_time = guard_recovery_time
	guard.regen_delay = guard_regen_delay
	guard.regen_rate = guard_regen_rate
	guard.max_health = max_health
	return guard


## The closest (x) and farthest (y) distance at which [param pattern] may be chosen.
func distance_range(pattern: int) -> Vector2:
	match pattern:
		Pattern.SLAM:
			return Vector2(slam_min_distance, slam_max_distance)
		Pattern.LUNGE:
			return Vector2(lunge_min_distance, lunge_max_distance)
	return Vector2(ranged_min_distance, ranged_max_distance)


## Writes the numbers of [param pattern] into the shared attack fields of [param working]
## (the boss's own copy of this config). For the shockwave the "hitbox" is only the lane
## the wave will travel, drawn as the wind-up preview.
func apply_pattern(pattern: int, working: EnemyConfig) -> void:
	working.attack_lunge_speed = 0.0
	match pattern:
		Pattern.SLAM:
			working.telegraph_time = slam_telegraph_time
			working.attack_active_time = slam_active_time
			working.attack_recovery_time = slam_recovery_time
			working.attack_damage = slam_damage
			working.attack_hitbox = slam_hitbox
		Pattern.LUNGE:
			working.telegraph_time = lunge_telegraph_time
			working.attack_active_time = lunge_active_time
			working.attack_recovery_time = lunge_recovery_time
			working.attack_damage = lunge_damage
			working.attack_hitbox = lunge_hitbox
			working.attack_lunge_speed = lunge_speed
		Pattern.RANGED:
			working.telegraph_time = ranged_telegraph_time
			working.attack_active_time = ranged_active_time
			working.attack_recovery_time = ranged_recovery_time
			working.attack_damage = ranged_damage
			working.attack_hitbox = Rect2(Vector2(body_size.x * 0.5, -ranged_size.y),
					Vector2(ranged_speed * ranged_lifetime, ranged_size.y))
