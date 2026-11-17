## The Seeker player controller: run, jump, double jump, dash, wall slide, climb,
## crouch, grapple and enter door, animated from the pack's sheets.
##
## Every gameplay value comes from [member config]. Animation timings and feet
## points come from seeker_animations.json; SpriteFrames are built at runtime from
## the sheets of [member palette]. The node origin is the feet point.
##
## The scene it lives in provides:
## - solid geometry on physics layer 1 (LAYER_WORLD),
## - Area2D nodes on layer 2 (LAYER_INTERACTABLE) in group "climbable" (ladders,
##   vines) or "door" (doors, entered with interact),
## - Node2D nodes in group "grapple_anchor".
##
## Usage: [codeblock]
## var player: Player = preload("res://src/player/player.tscn").instantiate()
## player.position = Vector2(64, 224)
## player.door_entered.connect(func(door: Area2D) -> void: player.resume_from_door())
## add_child(player)
## [/codeblock]
class_name Player
extends CharacterBody2D

## Emitted once the enter-door animation has finished playing. The player stays in
## the door until [method resume_from_door] is called (room change is story 007).
signal door_entered(door: Area2D)

## Controller states.
enum State { GROUND, AIR, DASH, WALL_SLIDE, CLIMB, CROUCH, GRAPPLE, ENTER_DOOR }
## Steps of a grapple: throw (frames 0-2), pull (3-6 looped), release (7).
enum GrapplePhase { THROW, PULL, RELEASE }

## Physics layer bit of level geometry.
const LAYER_WORLD := 1
## Physics layer bit of ladders, vines and doors.
const LAYER_INTERACTABLE := 2
## Physics layer bit of the player body.
const LAYER_PLAYER := 4
const GROUP_CLIMBABLE := &"climbable"
const GROUP_DOOR := &"door"
const GROUP_GRAPPLE_ANCHOR := &"grapple_anchor"
const ANIMATION_DATA_PATH := "res://src/player/seeker_animations.json"
const ROPE_WIDTH := 1.0
const ROPE_COLOR := Color(0.85, 0.75, 0.55)

## Movement tuning. Replace before adding the player to the tree to inject other values.
@export var config: PlayerConfig = preload("res://src/player/player_config.tres")
## Palette folder and file-name part of the sheets (Void, Ember, Frost, Bone, Dream).
## Read once in _ready.
@export var palette: StringName = &"Void"

## Current controller state (read only).
var state: State = State.GROUND
## 1 when facing right, -1 when facing left (read only).
var facing: int = 1

var _sprite: AnimatedSprite2D
var _body_shape: RectangleShape2D
var _body_collision: CollisionShape2D
var _sensor: Area2D
var _rope: Line2D
var _frames: SpriteFrames
var _vfx_frames: SpriteFrames
var _pivots := {}
var _vfx_pivots := {}

var _move_x := 0.0
var _vertical := 0.0
var _jump_buffer_timer := 0.0
var _coyote_timer := 0.0
var _takeoff_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _climb_lockout_timer := 0.0
var _wall_jump_lock_timer := 0.0
var _air_jumps_left := 0
var _air_dashes_left := 0
var _landing := false
var _flipping := false
var _standing_up := false
var _grapple_phase := GrapplePhase.THROW
var _anchor: Node2D
var _door: Area2D


func _ready() -> void:
	PlayerInputBindings.register()
	collision_layer = LAYER_PLAYER
	collision_mask = LAYER_WORLD

	_body_shape = RectangleShape2D.new()
	_body_collision = CollisionShape2D.new()
	_body_collision.shape = _body_shape
	add_child(_body_collision)
	_apply_hitbox(config.hitbox_size.y)

	var sensor_shape := RectangleShape2D.new()
	sensor_shape.size = config.hitbox_size
	var sensor_collision := CollisionShape2D.new()
	sensor_collision.shape = sensor_shape
	sensor_collision.position = Vector2(0.0, -config.hitbox_size.y * 0.5)
	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = LAYER_INTERACTABLE
	_sensor.monitorable = false
	_sensor.add_child(sensor_collision)
	add_child(_sensor)

	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ANIMATION_DATA_PATH))
	_frames = _build_frames(data["character"], _pivots)
	_vfx_frames = _build_frames(data["vfx"], _vfx_pivots)

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = _frames
	_sprite.centered = false
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.animation_finished.connect(_on_animation_finished)
	add_child(_sprite)

	_rope = Line2D.new()
	_rope.width = ROPE_WIDTH
	_rope.default_color = ROPE_COLOR
	_rope.add_point(Vector2.ZERO)
	_rope.add_point(Vector2.ZERO)
	_rope.visible = false
	add_child(_rope)
	_rope.top_level = true

	_refresh_air_moves()
	_play_loop(&"idle")


func _physics_process(delta: float) -> void:
	_move_x = signf(Input.get_axis(&"move_left", &"move_right"))
	_vertical = signf(Input.get_axis(&"move_up", &"move_down"))
	_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_timer = config.jump_buffer_time
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_takeoff_timer = maxf(_takeoff_timer - delta, 0.0)
	_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)
	_climb_lockout_timer = maxf(_climb_lockout_timer - delta, 0.0)
	_wall_jump_lock_timer = maxf(_wall_jump_lock_timer - delta, 0.0)

	match state:
		State.GROUND:
			_state_ground(delta)
		State.AIR:
			_state_air(delta)
		State.DASH:
			_state_dash(delta)
		State.WALL_SLIDE:
			_state_wall_slide(delta)
		State.CLIMB:
			_state_climb()
		State.CROUCH:
			_state_crouch(delta)
		State.GRAPPLE:
			_state_grapple()
		State.ENTER_DOOR:
			velocity = Vector2.ZERO

	_sprite.scale.x = float(facing)


## Leaves the enter-door state and gives control back to the player. Call it after
## handling [signal door_entered].
func resume_from_door() -> void:
	_set_state(State.GROUND)
	_play_loop(&"idle")


# --- States ----------------------------------------------------------------

func _state_ground(delta: float) -> void:
	_coyote_timer = config.coyote_time
	_refresh_air_moves()
	if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
		return
	if Input.is_action_just_pressed(&"dash") and _try_start_dash():
		return
	if Input.is_action_just_pressed(&"interact"):
		var door := _find_overlap(GROUP_DOOR)
		if door != null:
			_start_enter_door(door)
			return
	if _try_start_climb():
		return
	if _jump_buffer_timer > 0.0:
		_start_ground_jump()
		return
	if Input.is_action_pressed(&"crouch"):
		_start_crouch()
		return

	var moving := _move_x != 0.0
	if moving:
		facing = int(_move_x)
	velocity.x = _move_x * config.run_speed
	velocity.y = config.gravity * delta
	move_and_slide()
	if not is_on_floor():
		_set_state(State.AIR)
		return

	if _landing and not moving:
		return
	_landing = false
	if moving:
		_play_loop(&"run", config.run_speed / config.run_animation_reference_speed)
	else:
		_play_loop(&"idle")


func _state_air(delta: float) -> void:
	if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
		return
	if Input.is_action_just_pressed(&"dash") and _try_start_dash():
		return
	if _try_start_climb():
		return
	if _jump_buffer_timer > 0.0:
		if _coyote_timer > 0.0:
			_start_ground_jump()
		elif _air_jumps_left > 0:
			_start_air_jump()
	if Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		velocity.y *= config.jump_cut_multiplier

	if _wall_jump_lock_timer <= 0.0:
		if _move_x != 0.0:
			facing = int(_move_x)
		velocity.x = _move_x * config.run_speed
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)
	var impact := velocity.y
	move_and_slide()

	if is_on_floor():
		_land(impact)
	elif is_on_wall() and velocity.y > 0.0 and _move_x != 0.0 and _move_x == -signf(get_wall_normal().x):
		_set_state(State.WALL_SLIDE)
		facing = -int(_move_x)
		_play_loop(&"wall_slide")
	else:
		_air_animation()


func _state_dash(delta: float) -> void:
	_dash_timer -= delta
	velocity = Vector2(float(facing) * config.dash_speed, 0.0)
	move_and_slide()
	if _dash_timer <= 0.0 or is_on_wall():
		_dash_cooldown_timer = config.dash_cooldown
		_set_state(State.GROUND if is_on_floor() else State.AIR)


func _state_wall_slide(delta: float) -> void:
	if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
		return
	if _jump_buffer_timer > 0.0:
		_start_wall_jump()
		return
	velocity.x = _move_x * config.run_speed
	velocity.y = minf(velocity.y + config.gravity * delta, config.wall_slide_speed)
	move_and_slide()
	if is_on_floor():
		_set_state(State.GROUND)
	elif not is_on_wall() or _move_x == 0.0 or _move_x != -signf(get_wall_normal().x):
		_set_state(State.AIR)
	else:
		facing = -int(_move_x)
		_play_loop(&"wall_slide")


func _state_climb() -> void:
	_refresh_air_moves()
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer = 0.0
		velocity = Vector2(_move_x * config.run_speed, -config.jump_speed)
		_climb_lockout_timer = config.climb_jump_lockout_time
		_set_state(State.AIR)
		return
	if _find_overlap(GROUP_CLIMBABLE) == null:
		velocity.y = -config.climb_top_hop_speed if _vertical < 0.0 else 0.0
		_set_state(State.AIR)
		return

	velocity = Vector2(0.0, _vertical * config.climb_speed)
	move_and_slide()
	if is_on_floor() and _vertical > 0.0:
		_set_state(State.GROUND)
	elif _vertical == 0.0:
		_show_frame(&"climb", 0)
	else:
		_play_loop(&"climb")


func _state_crouch(delta: float) -> void:
	if not _standing_up and not Input.is_action_pressed(&"crouch") and _can_stand():
		_standing_up = true
		_apply_hitbox(config.hitbox_size.y)
		_start_clip(&"crouch_stand")
	if _move_x != 0.0 and not _standing_up:
		facing = int(_move_x)
	velocity.x = 0.0 if _standing_up else _move_x * config.crouch_speed
	velocity.y = config.gravity * delta
	move_and_slide()
	if not is_on_floor():
		_set_state(State.AIR)


func _state_grapple() -> void:
	match _grapple_phase:
		GrapplePhase.THROW:
			_aim_at_anchor()
		GrapplePhase.PULL:
			_aim_at_anchor()
			var to_anchor := _anchor.global_position - _hand_position()
			if to_anchor.length() <= config.grapple_arrive_distance:
				_begin_grapple_release()
			else:
				velocity = to_anchor.normalized() * config.grapple_speed
				move_and_slide()
				if is_on_wall() or is_on_ceiling() or (is_on_floor() and to_anchor.y > 0.0):
					_begin_grapple_release()

	var rope_shown := _grapple_phase == GrapplePhase.PULL \
			or (_grapple_phase == GrapplePhase.THROW and _sprite.frame >= 1)
	_rope.visible = rope_shown
	if rope_shown:
		_rope.set_point_position(0, _hand_position())
		_rope.set_point_position(1, _anchor.global_position)


# --- Transitions -----------------------------------------------------------

func _set_state(new_state: State) -> void:
	if state == State.CROUCH and new_state != State.CROUCH:
		_apply_hitbox(config.hitbox_size.y)
	if state == State.GRAPPLE and new_state != State.GRAPPLE:
		_sprite.rotation = 0.0
		_rope.visible = false
	_landing = false
	_flipping = false
	_standing_up = false
	state = new_state


func _start_ground_jump() -> void:
	_set_state(State.AIR)
	velocity.y = -config.jump_speed
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_takeoff_timer = config.jump_takeoff_time
	_spawn_effect(&"dust_jump")


func _start_wall_jump() -> void:
	var away := signf(get_wall_normal().x)
	_set_state(State.AIR)
	facing = int(away)
	velocity = Vector2(away * config.wall_jump_push_speed, -config.wall_jump_speed)
	_wall_jump_lock_timer = config.wall_jump_control_lock_time
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_takeoff_timer = config.jump_takeoff_time


func _start_air_jump() -> void:
	_set_state(State.AIR)
	_flipping = true
	velocity.y = -config.double_jump_speed
	_air_jumps_left -= 1
	_jump_buffer_timer = 0.0
	_start_clip(&"double_jump")
	_spawn_effect(&"air_jump_ring")


func _land(impact: float) -> void:
	_set_state(State.GROUND)
	if impact >= config.land_min_fall_speed:
		_landing = true
		_start_clip(&"jump_land")
		_spawn_effect(&"dust_land")


func _try_start_dash() -> bool:
	if _dash_cooldown_timer > 0.0:
		return false
	var grounded := is_on_floor()
	if not grounded and _air_dashes_left <= 0:
		return false
	if _move_x != 0.0:
		facing = int(_move_x)
	if grounded:
		_spawn_effect(&"dust_dash")
	else:
		_air_dashes_left -= 1
	_dash_timer = config.dash_time
	_set_state(State.DASH)
	_start_clip(&"dash")
	return true


func _try_start_climb() -> bool:
	if _climb_lockout_timer > 0.0:
		return false
	if not (_vertical < 0.0 or (_vertical > 0.0 and not is_on_floor())):
		return false
	var ladder := _find_overlap(GROUP_CLIMBABLE)
	if ladder == null:
		return false
	global_position.x = ladder.global_position.x
	velocity = Vector2.ZERO
	_set_state(State.CLIMB)
	return true


func _start_crouch() -> void:
	_set_state(State.CROUCH)
	_apply_hitbox(config.crouch_hitbox_height)
	_start_clip(&"crouch_down")


func _start_enter_door(door: Area2D) -> void:
	_door = door
	global_position.x = door.global_position.x
	velocity = Vector2.ZERO
	_set_state(State.ENTER_DOOR)
	_start_clip(&"enter_door")


func _try_start_grapple() -> bool:
	var best: Node2D = null
	var best_distance := config.grapple_range
	for node in get_tree().get_nodes_in_group(GROUP_GRAPPLE_ANCHOR):
		var anchor := node as Node2D
		var distance := global_position.distance_to(anchor.global_position)
		if distance <= best_distance:
			best = anchor
			best_distance = distance
	if best == null:
		return false
	_anchor = best
	facing = 1 if _anchor.global_position.x >= global_position.x else -1
	velocity = Vector2.ZERO
	_set_state(State.GRAPPLE)
	_grapple_phase = GrapplePhase.THROW
	_start_clip(&"grapple_throw")
	return true


func _begin_grapple_release() -> void:
	_grapple_phase = GrapplePhase.RELEASE
	velocity = Vector2.ZERO
	_sprite.rotation = 0.0
	_start_clip(&"grapple_release")


func _on_animation_finished() -> void:
	match _sprite.animation:
		&"jump_land":
			_landing = false
		&"double_jump":
			_flipping = false
		&"crouch_stand":
			if state == State.CROUCH:
				_set_state(State.GROUND)
		&"enter_door":
			if state == State.ENTER_DOOR:
				door_entered.emit(_door)
		&"grapple_throw":
			if state == State.GRAPPLE:
				_grapple_phase = GrapplePhase.PULL
				_play_loop(&"grapple_pull")
		&"grapple_release":
			if state == State.GRAPPLE:
				_set_state(State.AIR)


# --- Helpers ---------------------------------------------------------------

func _refresh_air_moves() -> void:
	_air_jumps_left = config.air_jumps
	_air_dashes_left = config.air_dashes


## Resizes the body box so its bottom stays on the feet point.
func _apply_hitbox(height: float) -> void:
	_body_shape.size = Vector2(config.hitbox_size.x, height)
	_body_collision.position = Vector2(0.0, -height * 0.5)


func _can_stand() -> bool:
	return not test_move(global_transform, Vector2(0.0, -(config.hitbox_size.y - config.crouch_hitbox_height)))


func _find_overlap(group: StringName) -> Area2D:
	for area in _sensor.get_overlapping_areas():
		if area.is_in_group(group):
			return area
	return null


## Rotates the sprite around the feet so the throwing arm (drawn at
## grapple_arm_angle_deg above horizontal) points at the anchor.
func _aim_at_anchor() -> void:
	var arm_angle := deg_to_rad(config.grapple_arm_angle_deg)
	var arm_direction := Vector2(float(facing) * cos(arm_angle), -sin(arm_angle))
	_sprite.rotation = (_anchor.global_position - global_position).angle() - arm_direction.angle()


func _hand_position() -> Vector2:
	return _sprite.to_global(config.grapple_hand_offset)


func _air_animation() -> void:
	if _flipping:
		return
	if _takeoff_timer > 0.0:
		_show_frame(&"jump_takeoff", 0)
		return
	if velocity.y < -config.apex_speed:
		var last_rise_frame := _frames.get_frame_count(&"jump_rise") - 1
		var rise_progress := clampf(-velocity.y / config.jump_speed, 0.0, 1.0)
		_show_frame(&"jump_rise", roundi((1.0 - rise_progress) * float(last_rise_frame)))
	elif velocity.y <= config.apex_speed:
		_show_frame(&"jump_apex", 0 if velocity.y < 0.0 else 1)
	else:
		_play_loop(&"jump_fall")


## Plays [param clip] from its first frame.
func _start_clip(clip: StringName) -> void:
	_sprite.offset = -_pivots[clip]
	_sprite.speed_scale = 1.0
	_sprite.play(clip)
	_sprite.frame = 0


## Keeps [param clip] playing (starts it if another clip is showing or it is paused).
func _play_loop(clip: StringName, speed: float = 1.0) -> void:
	_sprite.speed_scale = speed
	if _sprite.animation != clip or not _sprite.is_playing():
		_sprite.offset = -_pivots[clip]
		_sprite.play(clip)


## Shows one frame of [param clip] without playing it.
func _show_frame(clip: StringName, index: int) -> void:
	if _sprite.animation != clip:
		_sprite.offset = -_pivots[clip]
		_sprite.animation = clip
	_sprite.speed_scale = 1.0
	_sprite.pause()
	_sprite.frame = index


func _spawn_effect(clip: StringName) -> void:
	var effect := DustEffect.new()
	get_parent().add_child(effect)
	effect.start(_vfx_frames, clip, _vfx_pivots[clip], global_position, facing)


## Builds SpriteFrames from one group of seeker_animations.json: one animation per
## clip, sliced from its sheet, each frame lasting its listed milliseconds. Fills
## [param pivots] with each clip's feet point or anchor.
func _build_frames(group: Dictionary, pivots: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directory := str(group["dir"]).replace("{palette}", palette)
	var sheets: Dictionary = group["sheets"]
	var clips: Dictionary = group["clips"]
	for clip_key in clips:
		var clip_name := StringName(clip_key)
		var clip: Dictionary = clips[clip_key]
		var sheet: Dictionary = sheets[clip["sheet"]]
		var texture: Texture2D = load(directory + str(sheet["file"]).replace("{palette}", palette))
		var frame_size := Vector2(float(sheet["frame_size"][0]), float(sheet["frame_size"][1]))
		var ms: Variant = sheet["ms"]
		frames.add_animation(clip_name)
		frames.set_animation_speed(clip_name, 1.0)
		frames.set_animation_loop(clip_name, bool(clip.get("loop", false)))
		for index in range(int(clip.get("from", 0)), int(clip.get("to", int(sheet["frames"]) - 1)) + 1):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2(frame_size.x * index, 0.0), frame_size)
			var duration_ms := float(ms[index]) if ms is Array else float(ms)
			frames.add_frame(clip_name, atlas, duration_ms / 1000.0)
		pivots[clip_name] = Vector2(float(sheet["pivot"][0]), float(sheet["pivot"][1]))
	return frames
