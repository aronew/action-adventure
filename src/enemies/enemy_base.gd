## Shared base of every enemy (story 004, design/game-brief.md Features item 4): health,
## a state machine, a telegraphed melee attack and placeholder art. The three normal
## types are this script with three [EnemyConfig] files; the boss (story 005) builds on it.
##
## States (see [constant TRANSITIONS]): PATROL (walks between two points, or stands guard
## when patrol_speed is 0) -> CHASE when the player comes in sight -> TELEGRAPH (the
## wind-up: the attack cannot hurt yet) -> ATTACK (hitbox live, then recovery) -> CHASE.
## A hit sends any of these to HURT (a short stagger) unless the config says the attack
## goes through. GUARD_BROKEN leads to STAGGER and only happens with a guard. Health at
## zero leads to DEAD from anywhere.
##
## Normal enemies have no guard: only bosses and mini-bosses do. Set [member guard_config]
## before adding the enemy to the tree to give it a [GuardComponent] (story 005).
##
## Dependencies are injected: set [member config] and [member target] before adding the
## enemy to the tree. The enemy listens to the target's [signal PlayerCombat.hit_landed]
## for hits on its own hurtbox, and hurts the target through [method Player.take_hit].
##
## Usage: [codeblock]
## var enemy: EnemyBase = preload("res://src/enemies/enemy.tscn").instantiate()
## enemy.config = preload("res://src/enemies/enemy_grunt.tres")
## enemy.target = player
## enemy.position = Vector2(400, 224)  # the feet point
## enemy.died.connect(func(who: EnemyBase) -> void: print(who.config.display_name))
## add_child(enemy)
## [/codeblock]
class_name EnemyBase
extends CharacterBody2D

## Emitted on every hit that deals damage, with the damage and the health left.
signal damaged(amount: float, health_left: float)
## Emitted whenever the state changes.
signal state_changed(from: State, to: State)
## Emitted once when health reaches zero, before the body fades out.
signal died(enemy: EnemyBase)

## What the enemy is doing.
enum State { PATROL, CHASE, TELEGRAPH, ATTACK, HURT, STAGGER, DEAD }
## What can change the state.
enum Event { PLAYER_SEEN, PLAYER_LOST, IN_RANGE, TELEGRAPH_ENDED, ATTACK_ENDED, HIT,
		HURT_ENDED, GUARD_BROKEN, STAGGER_ENDED, KILLED }

## The whole transition table: state -> event -> next state. An event not listed for a
## state changes nothing. DEAD has no way out.
const TRANSITIONS := {
	State.PATROL: {Event.PLAYER_SEEN: State.CHASE, Event.HIT: State.HURT,
			Event.GUARD_BROKEN: State.STAGGER, Event.KILLED: State.DEAD},
	State.CHASE: {Event.PLAYER_LOST: State.PATROL, Event.IN_RANGE: State.TELEGRAPH,
			Event.HIT: State.HURT, Event.GUARD_BROKEN: State.STAGGER, Event.KILLED: State.DEAD},
	State.TELEGRAPH: {Event.TELEGRAPH_ENDED: State.ATTACK, Event.HIT: State.HURT,
			Event.GUARD_BROKEN: State.STAGGER, Event.KILLED: State.DEAD},
	State.ATTACK: {Event.ATTACK_ENDED: State.CHASE, Event.HIT: State.HURT,
			Event.GUARD_BROKEN: State.STAGGER, Event.KILLED: State.DEAD},
	State.HURT: {Event.HURT_ENDED: State.CHASE, Event.HIT: State.HURT,
			Event.GUARD_BROKEN: State.STAGGER, Event.KILLED: State.DEAD},
	State.STAGGER: {Event.STAGGER_ENDED: State.CHASE, Event.KILLED: State.DEAD},
	State.DEAD: {},
}
## Physics layer bit of enemy bodies. They collide with the world only, so the player
## and enemies pass through each other: touching an enemy never hurts (every damaging
## attack is telegraphed).
const LAYER_ENEMY := 16
const STATE_NAMES := ["PATROL", "CHASE", "TELEGRAPH", "ATTACK", "HURT", "STAGGER", "DEAD"]

# Placeholder art only; gameplay values live in EnemyConfig.
const FLASH_COLOR := Color(1.0, 1.0, 1.0)
const FLASH_TIME := 0.12
const TELEGRAPH_COLOR := Color(1.0, 0.55, 0.1)
const TELEGRAPH_PREVIEW_ALPHA := Vector2(0.12, 0.4)
const ATTACK_COLOR := Color(1.0, 0.2, 0.15, 0.65)
const HURT_COLOR := Color(0.95, 0.95, 0.95)
const DEAD_COLOR := Color(0.35, 0.35, 0.38)
const EYE_COLOR := Color(1.0, 0.95, 0.6)
const EYE_SIZE := Vector2(3.0, 3.0)
const BAR_BACK_COLOR := Color(0.1, 0.1, 0.1)
const HEALTH_COLOR := Color(0.85, 0.25, 0.25)
const BAR_HEIGHT := 2.0
const BAR_GAP := 3.0
const LABEL_WIDTH := 80.0
const LABEL_FONT_SIZE := 8
const LEDGE_PROBE := 4.0
## Pixels the body snaps back from a hit, and how fast it returns (px/s).
const HIT_RECOIL := 3.0
const RECOIL_RETURN := 40.0
## Seconds the dead body takes to fall over.
const DEATH_TOPPLE_TIME := 0.25
## Death fragments: seconds they live, and their min and max size multiplier.
const BURST_LIFETIME := 0.6
const BURST_PIECE_SIZE := Vector2(1.5, 3.0)

## Tuning of this enemy type. Set before adding to the tree.
@export var config: EnemyConfig
## Optional guard, for bosses and mini-bosses only (story 005). Leave empty for normal
## enemies. Set before adding to the tree.
@export var guard_config: GuardConfig
## The player this enemy hunts and hurts. Set before adding to the tree.
var target: Player

## Current state (read only).
var state := State.PATROL
## Current health (read only).
var health := 0.0
## 1 when facing right, -1 when facing left (read only).
var facing := -1
## The guard, when [member guard_config] is set; null otherwise (read only).
var guard: GuardComponent

var _state_time := 0.0
var _cooldown_left := 0.0
var _home_x := 0.0
var _patrol_direction := -1.0
var _patrol_pause_left := 0.0
var _attack_landed := false
var _flash_left := 0.0
var _recoil := 0.0
var _guard_damage := 0.0

var _visual: Node2D
var _body: Polygon2D
var _eye: Polygon2D
var _preview: Polygon2D
var _hurtbox: Area2D
var _hitbox: Area2D
var _health_fill: ColorRect
var _alert: Label


## The state [param from] moves to on [param event]; [param from] itself when the table
## has no such transition. Pure: it reads only [constant TRANSITIONS].
static func transition(from: State, event: Event) -> State:
	return TRANSITIONS[from].get(event, from)


func _ready() -> void:
	assert(config != null, "EnemyBase needs a config before entering the tree")
	assert(target != null, "EnemyBase needs a target before entering the tree")
	health = config.max_health
	_home_x = global_position.x
	collision_layer = LAYER_ENEMY
	collision_mask = Player.LAYER_WORLD
	add_child(_make_box_collision(config.body_size))

	_hurtbox = Area2D.new()
	_hurtbox.collision_layer = PlayerCombat.LAYER_HITTABLE
	_hurtbox.collision_mask = 0
	_hurtbox.monitoring = false
	_hurtbox.add_to_group(PlayerCombat.GROUP_HITTABLE)
	_hurtbox.add_child(_make_box_collision(config.body_size))
	add_child(_hurtbox)

	_hitbox = Area2D.new()
	_hitbox.collision_layer = 0
	_hitbox.collision_mask = Player.LAYER_PLAYER
	_hitbox.monitorable = false
	_hitbox.monitoring = false
	var hit_shape := RectangleShape2D.new()
	hit_shape.size = config.attack_hitbox.size
	var hit_collision := CollisionShape2D.new()
	hit_collision.shape = hit_shape
	_hitbox.add_child(hit_collision)
	add_child(_hitbox)

	_build_visuals()

	if guard_config != null:
		guard = GuardComponent.new()
		guard.config = guard_config
		add_child(guard)
		guard.damaged.connect(func(amount: float, _left: float) -> void: _guard_damage = amount)
		guard.guard_broken.connect(func() -> void: _fire(Event.GUARD_BROKEN))

	target.combat.hit_landed.connect(_on_player_hit_landed)


func _physics_process(delta: float) -> void:
	_state_time += delta
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	match state:
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.TELEGRAPH:
			_steer_to(0.0, delta)
			if _state_time >= config.telegraph_time:
				_fire(Event.TELEGRAPH_ENDED)
		State.ATTACK:
			_state_attack(delta)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, config.hurt_deceleration * delta)
			if _state_time >= config.hurt_time:
				_fire(Event.HURT_ENDED)
		State.STAGGER:
			_steer_to(0.0, delta)
			if guard == null or _state_time >= guard.config.stagger_time:
				_fire(Event.STAGGER_ENDED)
		State.DEAD:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0.0, config.hurt_deceleration * delta)
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)
	move_and_slide()
	_update_visuals(delta)


## Takes one hit from the player. [param attack] is the attack id (see [PlayerCombat]),
## [param damage] its damage, [param charged] whether it was a fully charged heavy, and
## [param from_x] the attacker's global x (the knockback pushes away from it). With a
## guard, the guard decides the damage. Called by the enemy itself for hits on its
## hurtbox; public so tests and other damage sources can use it.
func take_hit(attack: String, damage: float, charged: bool, from_x: float) -> void:
	if state == State.DEAD:
		return
	var amount := damage
	if guard != null:
		_guard_damage = 0.0
		guard.take_hit(attack, damage, charged)
		amount = _guard_damage
	health = maxf(health - amount, 0.0)
	_flash_left = FLASH_TIME
	damaged.emit(amount, health)
	var away := signf(global_position.x - from_x)
	if away == 0.0:
		away = float(-facing)
	_recoil = away * HIT_RECOIL
	if health <= 0.0:
		velocity = Vector2(away * config.death_knockback_speed, -config.death_lift_speed)
		_fire(Event.KILLED)
		return
	if state == State.STAGGER:
		return
	var winding := state == State.TELEGRAPH or state == State.ATTACK
	if winding and not config.flinch_during_attack:
		return
	_fire(Event.HIT)
	velocity.x = away * config.hurt_knockback_speed
	if is_on_floor() and config.hurt_knockback_lift > 0.0:
		velocity.y = -config.hurt_knockback_lift


# --- States ----------------------------------------------------------------

func _state_patrol(delta: float) -> void:
	if _sees_target():
		_fire(Event.PLAYER_SEEN)
		return
	if config.patrol_speed <= 0.0:
		_steer_to(0.0, delta)
		return
	if _patrol_pause_left > 0.0:
		_patrol_pause_left -= delta
		_steer_to(0.0, delta)
		if _patrol_pause_left <= 0.0:
			_patrol_direction = -_patrol_direction
		return
	facing = int(_patrol_direction)
	var offset := global_position.x - _home_x
	var past_end := offset * _patrol_direction >= config.patrol_distance
	if past_end or is_on_wall() or not _floor_ahead():
		_patrol_pause_left = config.patrol_pause_time
		_steer_to(0.0, delta)
		return
	_steer_to(_patrol_direction * config.patrol_speed, delta)


func _state_chase(delta: float) -> void:
	if not _target_alive() or absf(target.global_position.x - global_position.x) > config.lose_range:
		_fire(Event.PLAYER_LOST)
		return
	var dx := target.global_position.x - global_position.x
	if dx != 0.0:
		facing = int(signf(dx))
	var level := absf(target.global_position.y - global_position.y) <= config.sight_height
	if absf(dx) <= config.attack_range and level:
		_steer_to(0.0, delta)
		if _cooldown_left <= 0.0:
			_fire(Event.IN_RANGE)
		return
	if not _floor_ahead():
		_steer_to(0.0, delta)
		return
	_steer_to(float(facing) * config.chase_speed, delta)


## The live window (hitbox on, lunge), then the recovery.
func _state_attack(delta: float) -> void:
	var live := _state_time < config.attack_active_time
	_hitbox.monitoring = live
	if live:
		velocity.x = float(facing) * config.attack_lunge_speed
		if not _floor_ahead():
			velocity.x = 0.0
		if not _attack_landed:
			for body in _hitbox.get_overlapping_bodies():
				if body == target and target.take_hit(config.attack_damage, global_position):
					_attack_landed = true
		return
	velocity.x = move_toward(velocity.x, 0.0, config.hurt_deceleration * delta)
	if _state_time >= config.attack_active_time + config.attack_recovery_time:
		_fire(Event.ATTACK_ENDED)


# --- Transitions -----------------------------------------------------------

func _fire(event: Event) -> void:
	var next := transition(state, event)
	# A hit while hurt restarts the hurt; any other non-transition changes nothing.
	if next == state and not (state == State.HURT and event == Event.HIT):
		return
	var previous := state
	state = next
	_state_time = 0.0
	_hitbox.monitoring = false
	match state:
		State.ATTACK:
			_attack_landed = false
			_hitbox.position = Vector2(config.attack_hitbox.get_center().x * float(facing),
					config.attack_hitbox.get_center().y)
		State.CHASE:
			if previous == State.ATTACK:
				_cooldown_left = config.attack_cooldown
		State.PATROL:
			_home_x = global_position.x
			_patrol_pause_left = 0.0
		State.DEAD:
			_die()
	state_changed.emit(previous, state)


## The killing blow: a hit-pause, a camera shake, a burst of fragments, and the body
## launched away (velocity set by [method take_hit]) falling over before it fades.
func _die() -> void:
	_hurtbox.set_deferred(&"monitorable", false)
	_hurtbox.remove_from_group(PlayerCombat.GROUP_HITTABLE)
	died.emit(self)
	_hit_stop()
	var camera := get_viewport().get_camera_2d()
	if camera is PlayerCamera:
		(camera as PlayerCamera).request_shake(config.death_shake_size, config.death_shake_time)
	_burst()
	var fall_side := signf(velocity.x) if velocity.x != 0.0 else float(-facing)
	var tween := create_tween()
	tween.tween_property(_visual, "rotation", fall_side * PI * 0.5, DEATH_TOPPLE_TIME)
	tween.tween_property(self, "modulate:a", 0.0, config.death_time)
	tween.tween_callback(queue_free)


## Slows the whole game for death_hitstop_time (real seconds), then restores it.
func _hit_stop() -> void:
	if config.death_hitstop_time <= 0.0:
		return
	Engine.time_scale = config.death_hitstop_scale
	await get_tree().create_timer(config.death_hitstop_time, true, false, true).timeout
	Engine.time_scale = 1.0


## Fragments in the body's colour flying out of its middle; they outlive the enemy.
func _burst() -> void:
	var particles := CPUParticles2D.new()
	particles.amount = config.death_burst_amount
	particles.lifetime = BURST_LIFETIME
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0.0, config.gravity)
	particles.initial_velocity_min = config.death_burst_speed * 0.5
	particles.initial_velocity_max = config.death_burst_speed
	particles.scale_amount_min = BURST_PIECE_SIZE.x
	particles.scale_amount_max = BURST_PIECE_SIZE.y
	particles.color = config.body_color
	get_parent().add_child(particles)
	particles.global_position = global_position + Vector2(0.0, -config.body_size.y * 0.5)
	particles.emitting = true
	get_tree().create_timer(BURST_LIFETIME + 0.2).timeout.connect(particles.queue_free)


# --- Helpers ---------------------------------------------------------------

func _steer_to(speed: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, speed, config.acceleration * delta)


func _target_alive() -> bool:
	return is_instance_valid(target) and target.state != Player.State.DEAD


func _sees_target() -> bool:
	if not _target_alive():
		return false
	var to_target := target.global_position - global_position
	return absf(to_target.x) <= config.sight_range and absf(to_target.y) <= config.sight_height


## True when there is floor just past the front edge of the body, so walking on does
## not step off a ledge. Always true in the air (the enemy is falling anyway).
func _floor_ahead() -> bool:
	if not is_on_floor():
		return true
	var front := Vector2(float(facing) * (config.body_size.x * 0.5 + 1.0), 0.0)
	return test_move(global_transform.translated(front), Vector2(0.0, LEDGE_PROBE))


func _on_player_hit_landed(area: Node2D, attack: String, damage: float) -> void:
	if area == _hurtbox:
		take_hit(attack, damage, target.combat.heavy_charged, target.global_position.x)


func _make_box_collision(size: Vector2) -> CollisionShape2D:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0.0, -size.y * 0.5)
	return collision


func _make_rect(size: Vector2, center: Vector2, color: Color) -> Polygon2D:
	var half := size * 0.5
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([center - half, center + Vector2(half.x, -half.y),
			center + half, center + Vector2(-half.x, half.y)])
	polygon.color = color
	return polygon


# --- Placeholder art -------------------------------------------------------

## A box body with an eye on its facing side, the attack's reach drawn as a box that
## fills in during the wind-up, a health bar and the type name above.
func _build_visuals() -> void:
	var size := config.body_size
	_preview = _make_rect(config.attack_hitbox.size, Vector2.ZERO, ATTACK_COLOR)
	_preview.visible = false
	add_child(_preview)

	_visual = Node2D.new()
	add_child(_visual)
	_body = _make_rect(size, Vector2(0.0, -size.y * 0.5), config.body_color)
	_visual.add_child(_body)
	_eye = _make_rect(EYE_SIZE, Vector2(size.x * 0.25, -size.y * 0.75), EYE_COLOR)
	_visual.add_child(_eye)

	var bar_y := -size.y - BAR_GAP - BAR_HEIGHT
	var back := ColorRect.new()
	back.color = BAR_BACK_COLOR
	back.position = Vector2(-size.x * 0.5, bar_y)
	back.size = Vector2(size.x, BAR_HEIGHT)
	add_child(back)
	_health_fill = ColorRect.new()
	_health_fill.color = HEALTH_COLOR
	_health_fill.position = back.position
	_health_fill.size = back.size
	add_child(_health_fill)

	var name_label := Label.new()
	name_label.size = Vector2(LABEL_WIDTH, 12.0)
	name_label.position = Vector2(-LABEL_WIDTH * 0.5, bar_y - 12.0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override(&"font_size", LABEL_FONT_SIZE)
	name_label.text = config.display_name
	add_child(name_label)

	_alert = Label.new()
	_alert.size = Vector2(LABEL_WIDTH, 12.0)
	_alert.position = Vector2(-LABEL_WIDTH * 0.5, bar_y - 22.0)
	_alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_alert.add_theme_font_size_override(&"font_size", LABEL_FONT_SIZE)
	_alert.add_theme_color_override(&"font_color", TELEGRAPH_COLOR)
	_alert.text = "!"
	_alert.visible = false
	add_child(_alert)


## Wind-up: the body heats to orange and leans back, and the attack's reach fills in.
## Live attack: the reach turns red. Hurt: white. Dead: grey.
func _update_visuals(delta: float) -> void:
	_flash_left = maxf(_flash_left - delta, 0.0)
	_recoil = move_toward(_recoil, 0.0, RECOIL_RETURN * delta)
	_visual.position.x = _recoil
	_visual.scale.x = float(facing)
	_health_fill.size.x = config.body_size.x * health / config.max_health
	var color := config.body_color
	var squash := 0.0
	_preview.visible = false
	_alert.visible = false
	match state:
		State.TELEGRAPH:
			var progress := clampf(_state_time / config.telegraph_time, 0.0, 1.0)
			color = config.body_color.lerp(TELEGRAPH_COLOR, progress)
			squash = config.telegraph_squash * progress
			_preview.visible = true
			_preview.position = Vector2(config.attack_hitbox.get_center().x * float(facing),
					config.attack_hitbox.get_center().y)
			_preview.color = Color(TELEGRAPH_COLOR, lerpf(TELEGRAPH_PREVIEW_ALPHA.x,
					TELEGRAPH_PREVIEW_ALPHA.y, progress))
			_alert.visible = true
		State.ATTACK:
			color = TELEGRAPH_COLOR
			if _state_time < config.attack_active_time:
				_preview.visible = true
				_preview.position = _hitbox.position
				_preview.color = ATTACK_COLOR
		State.HURT, State.STAGGER:
			color = config.body_color.lerp(HURT_COLOR, 0.5)
		State.DEAD:
			color = DEAD_COLOR
	_visual.scale.y = 1.0 - squash
	_body.color = color.lerp(FLASH_COLOR, _flash_left / FLASH_TIME)
