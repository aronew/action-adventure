## Tuning values for one normal enemy type (story 004, design/game-brief.md Features
## item 4: 2-3 enemy types with readable, telegraphed attacks). [EnemyBase] reads every
## number it uses from here; the three types are three .tres files of this resource:
## enemy_grunt.tres (plain), enemy_skitter.tres (fast) and enemy_brute.tres (heavy hitter).
##
## Units: pixels, px/s, seconds and health points. Sizes and offsets are written facing
## right and mirrored with the enemy's facing.
##
## Usage: [codeblock]
## var enemy: EnemyBase = preload("res://src/enemies/enemy.tscn").instantiate()
## enemy.config = preload("res://src/enemies/enemy_brute.tres")
## enemy.target = player
## add_child(enemy)
## [/codeblock]
class_name EnemyConfig
extends Resource

@export_group("Body")
## Name shown on the placeholder art (the Seeker pack has no enemy sprites).
@export var display_name: String
## Size of the body box, standing on the feet point.
@export var body_size: Vector2
## Placeholder body colour.
@export var body_color: Color
## Health. Normal enemies have no guard: only bosses and mini-bosses do (story 005).
@export var max_health: float
## Downward acceleration while not on the floor.
@export var gravity: float
## Fastest fall.
@export var max_fall_speed: float

@export_group("Movement")
## Walking speed while patrolling. 0 makes the enemy stand guard instead.
@export var patrol_speed: float
## How far either side of its spawn point the enemy patrols.
@export var patrol_distance: float
## Seconds the enemy waits at each end of its patrol.
@export var patrol_pause_time: float
## Running speed while chasing the player.
@export var chase_speed: float
## How fast the enemy reaches its walking or chasing speed (px/s per second).
@export var acceleration: float

@export_group("Awareness")
## Horizontal distance at which the enemy notices the player.
@export var sight_range: float
## Largest height difference at which the enemy notices the player.
@export var sight_height: float
## Horizontal distance at which a chasing enemy gives up and goes back to patrolling.
@export var lose_range: float

@export_group("Attack")
## Horizontal distance (feet to feet) from which the enemy starts its wind-up.
@export var attack_range: float
## Seconds of the wind-up (telegraph): the attack cannot hurt before it ends.
@export var telegraph_time: float
## Seconds the attack's hitbox is live, starting when the wind-up ends.
@export var attack_active_time: float
## Seconds after the live window before the enemy can move again.
@export var attack_recovery_time: float
## Seconds after an attack before the next wind-up may start.
@export var attack_cooldown: float
## Damage of one attack on the player.
@export var attack_damage: float
## Attack hitbox: size and centre offset from the feet point, written facing right.
@export var attack_hitbox: Rect2
## Forward speed during the live window (0 = the attack does not move the enemy).
@export var attack_lunge_speed: float
## How backward the enemy leans while winding up, as a fraction of its height (0 = none).
@export var telegraph_squash: float

@export_group("Getting hit")
## Seconds a hit staggers the enemy (no moving, no attacking).
@export var hurt_time: float
## Speed the enemy is pushed away from the player by a hit.
@export var hurt_knockback_speed: float
## Upward speed a hit gives the enemy when it is on the ground (a small hop); 0 for none.
@export var hurt_knockback_lift: float
## How fast the knockback bleeds off (px/s per second).
@export var hurt_deceleration: float
## When false, hits during the wind-up and the attack deal damage but do not stagger:
## the attack goes through (the heavy hitter), so it must be dodged, not interrupted.
@export var flinch_during_attack: bool
## Seconds the body fades out after death before the enemy is removed.
@export var death_time: float

@export_group("Death impact")
## Speed the killing blow launches the body away from the player.
@export var death_knockback_speed: float
## Upward speed the killing blow launches the body with.
@export var death_lift_speed: float
## Seconds the game slows down on the killing blow (hit-pause); 0 for none.
@export var death_hitstop_time: float
## Game speed during that hit-pause (0.05 = nearly frozen).
@export var death_hitstop_scale: float
## Camera shake on the killing blow, in pixels, and its length in seconds.
@export var death_shake_size: float
@export var death_shake_time: float
## Fragments that burst out of the body on death, and how fast they fly.
@export var death_burst_amount: int
@export var death_burst_speed: float
