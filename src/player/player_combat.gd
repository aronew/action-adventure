## Melee combat of the Seeker (story 002, design/game-brief.md "Melee"): the 3-hit
## ground combo, jump, up and down attacks and the charged heavy.
##
## Created by [Player]. The player decides when an attack may start and what the
## body may do meanwhile; this node runs the attack itself: it plays the Body layer
## on the player's sprite and the FX layer on its own sprite in sync, switches each
## attack's hitbox (an Area2D) on only during its hit frames, and reports hits.
## Every value comes from an [AttackConfig]. Origin of this node is the feet point.
##
## Attack ids (keys of [member AttackConfig.attacks]): attack1 -> attack2 -> attack3
## on the ground, up_attack (ground, up held), jump_attack and down_attack (air),
## heavy (ground, attack held).
##
## Hittable things must be an Area2D on layer [constant LAYER_HITTABLE] in group
## [constant GROUP_HITTABLE].
class_name PlayerCombat
extends Node2D

## Emitted once per target per swing when a hitbox touches a hittable. [param damage]
## already includes the charged multiplier of a charged heavy.
signal hit_landed(target: Node2D, attack: String, damage: float)
## Emitted once when an attack with a screen shake enters its hit frames.
signal camera_shake_requested(size: float, duration: float)
## Emitted when a swing with a forward step starts (and when the heavy is released),
## with the forward speed the player should get, in px/s.
signal lunge_requested(speed: float)
## Emitted once, the moment the heavy becomes fully charged (heavy_charged turns true).
signal heavy_ready

## Steps of an attack: nothing, a swing playing, or the heavy winding up and charging.
enum Phase { IDLE, SWING, CHARGE }

## Physics layer bit of things the hitboxes can hit.
const LAYER_HITTABLE := 8
const GROUP_HITTABLE := &"hittable"
const ATTACK_1 := "attack1"
const ATTACK_UP := "up_attack"
const ATTACK_JUMP := "jump_attack"
const ATTACK_DOWN := "down_attack"
const ATTACK_HEAVY := "heavy"
const GLOW_CLIP := "heavy_glow"

## Current step (read only).
var phase: Phase = Phase.IDLE
## Id of the attack being played, "" when idle (read only).
var current_attack := ""
## True while the heavy is fully charged, and through its strike when released
## charged (read only). The guard-break (story 003) reads this.
var heavy_charged := false

var _player: Player
var _config: AttackConfig
var _body: AnimatedSprite2D
var _body_pivots: Dictionary
var _fx: AnimatedSprite2D
var _fx_pivots: Dictionary
var _glow: AnimatedSprite2D
var _hitboxes := {}
var _hit_targets: Array[Area2D] = []
var _pending := false
var _hold_time := 0.0
var _chain_buffer := 0.0
var _start_frame := -1
var _shake_sent := false
var _fx_finished := true
var _holding := false
var _release_requested := false
var _charge_time := 0.0
var _glow_index := 0
var _glow_timer := 0.0


## Wires the combat to its player. [param body] is the player's sprite, which plays the
## Body layer of every attack; [param fx_frames] holds the FX layer clips (and the
## BladeGlow) with their pivots. Call before adding this node to the player.
func setup(player: Player, config: AttackConfig, body: AnimatedSprite2D, body_pivots: Dictionary,
		fx_frames: SpriteFrames, fx_pivots: Dictionary) -> void:
	_player = player
	_config = config
	_body = body
	_body_pivots = body_pivots
	_fx_pivots = fx_pivots
	_body.animation_finished.connect(_on_body_finished)

	_fx = _make_layer(fx_frames)
	_fx.animation_finished.connect(_on_fx_finished)
	add_child(_fx)
	_glow = _make_layer(fx_frames)
	_glow.animation = GLOW_CLIP
	_glow.offset = -fx_pivots[StringName(GLOW_CLIP)]
	add_child(_glow)

	for id in config.attacks:
		var shape := RectangleShape2D.new()
		shape.size = config.attacks[id]["hitbox"].size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		var box := Area2D.new()
		box.collision_layer = 0
		box.collision_mask = LAYER_HITTABLE
		box.monitorable = false
		box.monitoring = false
		box.add_child(collision)
		add_child(box)
		_hitboxes[id] = box


## True while a swing or the heavy charge is playing.
func is_attacking() -> bool:
	return phase != Phase.IDLE


## True while the attack blocks dash, jump and grapple. It lets go from the
## attack's "move_cancel_from" frame, and never holds the heavy's wind-up and charge.
func is_locked() -> bool:
	if phase != Phase.SWING:
		return false
	var cancel_from: int = _config.attacks[current_attack]["move_cancel_from"]
	return _body.frame < cancel_from


## Reads the attack button and starts an attack when one is due. Call once per physics
## tick while no attack is playing. Returns true when an attack started this tick.
## [param grounded] chooses ground or air attacks, [param vertical] is -1 (up held),
## 0 or 1 (down held), [param on_door] stops up from selecting the up attack.
## On the ground a press is resolved on release (a tap) or after the hold threshold
## (the heavy); in the air it starts a swing at once.
func poll(delta: float, grounded: bool, vertical: float, on_door: bool) -> bool:
	if phase != Phase.IDLE:
		return false
	var pressed := Input.is_action_pressed(&"attack")
	if not grounded:
		_pending = false
		if Input.is_action_just_pressed(&"attack"):
			_start_swing(ATTACK_DOWN if vertical > 0.0 else ATTACK_JUMP)
			return true
		return false
	if not _pending and Input.is_action_just_pressed(&"attack"):
		_pending = true
		_hold_time = 0.0
	if not _pending:
		return false
	if not pressed:
		_start_swing(ATTACK_UP if vertical < 0.0 and not on_door else ATTACK_1)
		return true
	_hold_time += delta
	if _hold_time >= _config.hold_threshold:
		_start_heavy()
		return true
	return false


## Advances the running attack: charge, hit frames, hits and chaining. Call once per
## physics tick, after the player has moved.
func update(delta: float) -> void:
	_chain_buffer = maxf(_chain_buffer - delta, 0.0)
	if phase == Phase.CHARGE:
		_update_charge(delta)
	elif phase == Phase.SWING:
		if Input.is_action_just_pressed(&"attack") and Engine.get_physics_frames() != _start_frame:
			_chain_buffer = _config.chain_buffer_time
		_update_hits()
		_try_chain()


## Stops the attack at once (dash, jump, landing, leaving the ground...). The FX of a
## swing still playing finishes where the swing was, on a detached copy.
func cancel() -> void:
	_pending = false
	if phase == Phase.IDLE:
		return
	_detach_fx()
	_fx.visible = false
	_glow.visible = false
	_end_attack()


func _make_layer(frames: SpriteFrames) -> AnimatedSprite2D:
	var layer := AnimatedSprite2D.new()
	layer.sprite_frames = frames
	layer.centered = false
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.visible = false
	return layer


func _start_swing(id: String) -> void:
	_detach_fx()
	_stop_hitboxes()
	current_attack = id
	phase = Phase.SWING
	_pending = false
	_chain_buffer = 0.0
	_start_frame = Engine.get_physics_frames()
	_begin_swing_state()
	_play_layers(id)
	_request_lunge()


func _start_heavy() -> void:
	_detach_fx()
	_stop_hitboxes()
	current_attack = ATTACK_HEAVY
	phase = Phase.CHARGE
	_pending = false
	_holding = false
	_release_requested = false
	_charge_time = _config.hold_threshold
	_begin_swing_state()
	_play_layers(ATTACK_HEAVY)
	_body.speed_scale = _config.windup_speed_scale
	_fx.speed_scale = _config.windup_speed_scale
	_glow.visible = true
	_glow.scale.x = float(_player.facing)
	_glow_index = -1
	_glow_timer = 0.0


## Resets what one swing remembers and puts its hitbox on the feet point, mirrored
## with the player's facing.
func _begin_swing_state() -> void:
	heavy_charged = false
	_shake_sent = false
	_hit_targets.clear()
	var center: Vector2 = _config.attacks[current_attack]["hitbox"].get_center()
	_hitboxes[current_attack].position = Vector2(center.x * float(_player.facing), center.y)


func _play_layers(id: String) -> void:
	_body.offset = -_body_pivots[StringName(id)]
	_body.speed_scale = 1.0
	_body.play(id)
	_body.frame = 0
	_fx.visible = true
	_fx.speed_scale = 1.0
	_fx.offset = -_fx_pivots[StringName(id)]
	_fx.scale.x = float(_player.facing)
	_fx.play(id)
	_fx.frame = 0
	_fx_finished = false


## The charge runs from the first wind-up frame: the glow blinks and the charge time
## counts while he pulls the sword back, then he holds the charge frame until release.
## A release during the wind-up strikes once the charge frame is reached.
func _update_charge(delta: float) -> void:
	if not Input.is_action_pressed(&"attack"):
		_release_requested = true
	if not _holding and _body.frame >= _config.charge_hold_frame:
		_holding = true
		_body.pause()
		_body.frame = _config.charge_hold_frame
		_fx.pause()
		_fx.frame = _config.charge_hold_frame
	if _holding and _release_requested:
		_release_heavy()
		return

	_charge_time += delta
	var was_charged := heavy_charged
	heavy_charged = _charge_time >= _config.charge_time
	if heavy_charged and not was_charged:
		heavy_ready.emit()
	var cycle := _config.glow_ready_cycle if heavy_charged else _config.glow_cycle
	_glow_timer -= delta
	if _glow_timer <= 0.0:
		_glow_index = (_glow_index + 1) % cycle.size()
		_glow.frame = cycle[_glow_index]
		var fill := clampf(_charge_time / _config.charge_time, 0.0, 1.0)
		_glow_timer = _config.glow_ready_step_time if heavy_charged \
				else lerpf(_config.glow_step_time_slow, _config.glow_step_time_fast, fill)


func _release_heavy() -> void:
	phase = Phase.SWING
	_glow.visible = false
	_body.speed_scale = 1.0
	_fx.speed_scale = 1.0
	_body.frame = _config.heavy_release_frame
	_body.play()
	_fx.frame = _config.heavy_release_frame
	_fx.play()
	_request_lunge()


func _request_lunge() -> void:
	var speed: float = _config.attacks[current_attack].get("lunge", 0.0)
	if speed > 0.0:
		lunge_requested.emit(speed)


## Switches the hitbox on for the hit frames and reports each new target once.
func _update_hits() -> void:
	var data: Dictionary = _config.attacks[current_attack]
	var box: Area2D = _hitboxes[current_attack]
	var active: bool = _body.frame >= data["hit_from"] and _body.frame <= data["hit_to"]
	box.monitoring = active
	if not active:
		return
	if not _shake_sent and data["shake_size"] > 0.0:
		_shake_sent = true
		camera_shake_requested.emit(data["shake_size"], data["shake_time"])
	var damage: float = data["damage"] * (_config.charged_damage_multiplier if heavy_charged else 1.0)
	for area in box.get_overlapping_areas():
		if area.is_in_group(GROUP_HITTABLE) and not _hit_targets.has(area):
			_hit_targets.append(area)
			hit_landed.emit(area, current_attack, damage)


## Cancels into the next swing of the combo when its window is open and a press waits.
func _try_chain() -> void:
	var data: Dictionary = _config.attacks[current_attack]
	if not data.has("next") or _chain_buffer <= 0.0 or _body.frame < data["chain_from"]:
		return
	var direction := signf(Input.get_axis(&"move_left", &"move_right"))
	if direction != 0.0:
		_player.facing = int(direction)
	_start_swing(data["next"])


## Lets the FX layer finish where the swing was: a copy takes over the remaining
## frames while this layer is reused. Does nothing when the FX is finished or paused
## (the charge).
func _detach_fx() -> void:
	if not _fx.visible or _fx_finished or not _fx.is_playing():
		return
	var copy := AnimatedSprite2D.new()
	copy.sprite_frames = _fx.sprite_frames
	copy.centered = false
	copy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	copy.offset = _fx.offset
	copy.scale.x = _fx.scale.x
	copy.animation_finished.connect(copy.queue_free)
	_player.get_parent().add_child(copy)
	copy.global_position = _fx.global_position
	copy.play(_fx.animation)
	copy.set_frame_and_progress(_fx.frame, _fx.frame_progress)


func _stop_hitboxes() -> void:
	for box: Area2D in _hitboxes.values():
		box.monitoring = false


func _end_attack() -> void:
	_stop_hitboxes()
	phase = Phase.IDLE
	current_attack = ""
	heavy_charged = false


func _on_body_finished() -> void:
	if phase == Phase.SWING:
		_end_attack()


func _on_fx_finished() -> void:
	_fx_finished = true
	_fx.visible = false
