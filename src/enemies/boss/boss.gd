## The first-region boss (story 005, design/game-brief.md "Goal & fail state" and "Hooks":
## beat the region's final boss; the guard-break is the central hook). It is an [EnemyBase],
## so it reuses the state machine, the guard path (guard break -> STAGGER, which interrupts
## whatever it is doing), the telegraph art and the death impact. It adds three telegraphed
## patterns and a way to choose between them:
## - SLAM: a slow overhead slam with a long wind-up and a short reach (melee).
## - LUNGE: a shorter wind-up, then a dash that hurts everything along its path (melee).
## - RANGED: a low shockwave that travels along the ground and must be jumped (ranged).
##
## The next pattern is chosen when the cooldown is over: only patterns whose distance range
## (see [method BossConfig.distance_range]) holds the player's distance, never the one just
## used. With none to choose the boss walks closer. Every pattern ends with a recovery, the
## punish window. Hits during a wind-up or a strike do not stagger the boss, only breaking
## the guard does. Every number comes from the [BossConfig] set as [member config].
##
## The boss stands still until [method begin_fight] is called. Every damaging hit goes
## through [method Player.take_hit].
##
## Usage: [codeblock]
## var boss := Boss.new()
## boss.config = preload("res://src/enemies/boss/boss_config.tres")
## boss.target = player
## boss.position = Vector2(820, 224)  # the feet point
## add_child(boss)
## boss.begin_fight()
## [/codeblock]
class_name Boss
extends EnemyBase

## Group of the shockwaves in flight; they vanish when the boss dies.
const GROUP_SHOCKWAVE := &"boss_shockwave"
const SHOCKWAVE_COLOR := Color(1.0, 0.45, 0.1, 0.85)
const NO_PATTERN := -1

var _boss_config: BossConfig
var _engaged := false
var _pattern: int = BossConfig.Pattern.SLAM
var _last_pattern := NO_PATTERN
var _hit_shape: RectangleShape2D


func _ready() -> void:
	_boss_config = config as BossConfig
	assert(_boss_config != null, "Boss needs a BossConfig before entering the tree")
	# The base reads the current pattern's numbers from its config, so the boss works on its
	# own copy and writes the chosen pattern into it (see BossConfig.apply_pattern).
	config = _boss_config.duplicate() as BossConfig
	_boss_config.apply_pattern(BossConfig.Pattern.SLAM, config)
	guard_config = _boss_config.make_guard_config()
	super()
	_hit_shape = (_hitbox.get_child(0) as CollisionShape2D).shape as RectangleShape2D


## Wakes the boss: from now on it hunts the player. Before this it stands still.
func begin_fight() -> void:
	_engaged = true


## Waits for [method begin_fight], then hunts.
func _state_patrol(delta: float) -> void:
	_steer_to(0.0, delta)
	if _engaged:
		_fire(EnemyBase.Event.PLAYER_SEEN)


## Faces the player, starts the next pattern when the cooldown is over, otherwise walks up
## to [member EnemyConfig.attack_range].
func _state_chase(delta: float) -> void:
	if not _target_alive():
		_steer_to(0.0, delta)
		return
	var dx := target.global_position.x - global_position.x
	if dx != 0.0:
		facing = int(signf(dx))
	var distance := absf(dx)
	if _cooldown_left <= 0.0:
		var pattern := _pick_pattern(distance)
		if pattern != NO_PATTERN:
			_begin_pattern(pattern)
			_steer_to(0.0, delta)
			_fire(EnemyBase.Event.IN_RANGE)
			return
	if distance > config.attack_range and _floor_ahead():
		_steer_to(float(facing) * config.chase_speed, delta)
	else:
		_steer_to(0.0, delta)


## The melee patterns use the base's live window (hitbox, lunge) and recovery. The shockwave
## has no melee hitbox: it only stands through its release and recovery.
func _state_attack(delta: float) -> void:
	if _pattern != BossConfig.Pattern.RANGED:
		super(delta)
		return
	velocity.x = move_toward(velocity.x, 0.0, config.hurt_deceleration * delta)
	if _state_time >= config.attack_active_time + config.attack_recovery_time:
		_fire(EnemyBase.Event.ATTACK_ENDED)


## Adds two boss rules to the base's transitions: a pause after a stagger before the next
## wind-up, and the shockwave leaving as the shockwave pattern's strike begins.
func _fire(event: EnemyBase.Event) -> void:
	var previous := state
	super(event)
	if state == previous:
		return
	if previous == EnemyBase.State.STAGGER and state == EnemyBase.State.CHASE:
		_cooldown_left = _boss_config.post_stagger_cooldown
	elif state == EnemyBase.State.ATTACK and _pattern == BossConfig.Pattern.RANGED:
		_spawn_shockwave()


## The base's death, and the shockwaves still in flight vanish.
func _die() -> void:
	super()
	get_tree().call_group(GROUP_SHOCKWAVE, &"queue_free")


## The pattern to use at [param distance]: a random one of those whose range holds it,
## except the last one used. [constant NO_PATTERN] when there is none.
func _pick_pattern(distance: float) -> int:
	var candidates: Array[int] = []
	for pattern in BossConfig.Pattern.values():
		var reach := _boss_config.distance_range(pattern)
		if pattern != _last_pattern and distance >= reach.x and distance <= reach.y:
			candidates.append(pattern)
	if candidates.is_empty():
		return NO_PATTERN
	var picked: int = candidates.pick_random()
	return picked


## Loads [param pattern] into the working config and sizes the strike box and the wind-up
## preview to it.
func _begin_pattern(pattern: int) -> void:
	_pattern = pattern
	_last_pattern = pattern
	_boss_config.apply_pattern(pattern, config)
	var size := config.attack_hitbox.size
	_hit_shape.size = size
	var half := size * 0.5
	_preview.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half,
			Vector2(-half.x, half.y)])


## Sends a shockwave along the ground from the boss's front, the way it faces.
func _spawn_shockwave() -> void:
	var wave := Shockwave.new()
	wave.setup(_boss_config.ranged_size, _boss_config.ranged_speed, _boss_config.ranged_damage,
			_boss_config.ranged_lifetime, float(facing), target)
	get_parent().add_child(wave)
	wave.global_position = global_position + Vector2(
			float(facing) * (config.body_size.x + _boss_config.ranged_size.x) * 0.5, 0.0)


## The boss's ranged attack: a low box that slides along the ground and hurts the player
## it touches once, then vanishes (or when its lifetime ends). Placeholder art.
class Shockwave extends Area2D:
	var _speed := 0.0
	var _damage := 0.0
	var _direction := 1.0
	var _lifetime_left := 0.0
	var _target: Player


	## Sets the wave up before it enters the tree. [param size] stands on the origin;
	## [param direction] is 1 (right) or -1 (left); [param target] is the player it hurts.
	func setup(size: Vector2, speed: float, damage: float, lifetime: float, direction: float,
			target: Player) -> void:
		_speed = speed
		_damage = damage
		_lifetime_left = lifetime
		_direction = direction
		_target = target
		collision_layer = 0
		collision_mask = Player.LAYER_PLAYER
		monitorable = false
		add_to_group(Boss.GROUP_SHOCKWAVE)
		var shape := RectangleShape2D.new()
		shape.size = size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = Vector2(0.0, -size.y * 0.5)
		add_child(collision)
		var half := size * 0.5
		var polygon := Polygon2D.new()
		polygon.polygon = PackedVector2Array([Vector2(-half.x, -size.y), Vector2(half.x, -size.y),
				Vector2(half.x, 0.0), Vector2(-half.x, 0.0)])
		polygon.color = Boss.SHOCKWAVE_COLOR
		add_child(polygon)


	func _physics_process(delta: float) -> void:
		position.x += _direction * _speed * delta
		_lifetime_left -= delta
		if _lifetime_left <= 0.0:
			queue_free()
			return
		for body in get_overlapping_bodies():
			if body == _target and _target.take_hit(_damage, global_position):
				queue_free()
				return
