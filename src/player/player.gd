## The Seeker player controller: run, jump, double jump, dash, wall slide, climb,
## crouch, grapple, enter door and melee attacks, animated from the pack's sheets. It
## takes hits from enemies ([method take_hit]): Hurt or HurtKnockback, a blinking
## invulnerability window, and Death at zero health (story 004).
##
## The double jump and the grapple are gated by [member player_state] (story 006):
## without the double jump an air jump does nothing (the air-jump count stays at zero,
## so neither a plain air jump nor a dash-jump in the air starts); without the grapple
## the grapple input does nothing. Every other move is always available.
##
## Every gameplay value comes from [member config]. Animation timings and feet
## points come from seeker_animations.json; SpriteFrames are built at runtime from
## the sheets of [member palette]. The node origin is the feet point.
##
## The scene it lives in provides:
## - solid geometry on physics layer 1 (LAYER_WORLD),
## - Area2D nodes on layer 2 (LAYER_INTERACTABLE) in group "climbable" (ladders,
##   vines) or "door" (doors, entered with interact),
## - Node2D nodes in group "grapple_anchor",
## - Area2D nodes on layer [constant PlayerCombat.LAYER_HITTABLE] in group "hittable"
##   (things the melee attacks hit).
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
## Emitted when the player lands from the air, with the fall speed at impact (px/s).
signal landed(impact_speed: float)
## Emitted on every hit that lands, with the damage taken and the health left.
signal damaged(amount: float, health_left: float)
## Emitted when a heal completes, with the health restored and the new health.
signal healed(amount: float, health_now: float)
## Emitted once the Death animation has played; the player holds its last frame until
## [method revive] is called. The save system (story 007) respawns from this.
signal died

## Controller states.
## ATTACK is a ground swing or the heavy charge; air attacks play in AIR. HURT is the
## short loss of control after a hit, DEAD lasts until [method revive]. HEAL is the
## planted heal: hold heal with a full meter on the ground (design/gdd/healing.md).
enum State { GROUND, AIR, DASH, WALL_SLIDE, CLIMB, CROUCH, GRAPPLE, ENTER_DOOR, ATTACK, HURT, DEAD, LEDGE, HEAL }
## Steps of a grapple: throw (frames 0-2), pull (3-6 looped), release (7).
enum GrapplePhase { THROW, PULL, RELEASE }
## The ledge grab: catching the edge, hanging, pulling up.
enum LedgePhase { GRAB, HANG, PULL }

## Physics layer bit of level geometry.
const LAYER_WORLD := 1
## Physics layer bit of ladders, vines and doors.
const LAYER_INTERACTABLE := 2
## Physics layer bit of the player body.
const LAYER_PLAYER := 4
const GROUP_CLIMBABLE := &"climbable"
const GROUP_DOOR := &"door"
## Colour the Seeker glows toward while a heal channels.
const HEAL_TINT := Color(1.0, 0.92, 0.6)
const GROUP_GRAPPLE_ANCHOR := &"grapple_anchor"
const ANIMATION_DATA_PATH := "res://src/player/seeker_animations.json"
const PAINTED_SCALE := 8.0
## The painted idle aura's strength (it is added light; see _ready).
const PAINTED_AURA_STRENGTH := 0.3
const PIXEL_ART_ROOT := "res://assets/characters/seeker/"
const PAINTED_ART_ROOT := "res://assets/characters/seeker/Painted/"
const ROPE_WIDTH := 1.0
const ROPE_COLOR := Color(0.85, 0.75, 0.55)

## Movement tuning. Replace before adding the player to the tree to inject other values.
@export var config: PlayerConfig = preload("res://src/player/player_config.tres")
## Melee tuning. Replace before adding the player to the tree to inject other values.
@export var attack_config: AttackConfig = preload("res://src/player/attack_data.tres")
## Palette folder and file-name part of the sheets (Void, Ember, Frost, Bone, Dream).
## Read once in _ready.
@export var palette: StringName = &"Bone"
## Which art set draws the Seeker: the owner's painted redraw (true) or the original
## pixel art (false). The painted sheets are the same animations, frame order, timing
## and pivots at PAINTED_SCALE times the size (assets/characters/seeker/Painted/); they
## are drawn at 1/PAINTED_SCALE with smooth filtering, so the Seeker keeps his world size
## and every gameplay value stays as it was.
@export var painted := true
## Abilities owned (double jump, grapple), read live. Set it before adding the player to
## the tree to gate them; left empty, the player makes one that owns both (the movement,
## enemy and boss rooms rely on this).
@export var player_state: PlayerState

## Current controller state (read only).
var state: State = State.GROUND
## 1 when facing right, -1 when facing left (read only).
var facing: int = 1
## Melee combat node: its signals report hits and camera shake (read only).
var combat: PlayerCombat
## Health and invulnerability (read only). Its values come from [member config].
var health: PlayerHealth
## The heal meter, filled by hits on foes (read only).
var heal_meter: HealMeter
## Seconds into the current heal, 0 outside HEAL (read only).
var heal_time := 0.0

var _sprite: AnimatedSprite2D
var _aura: AnimatedSprite2D
var _trail_material: CanvasItemMaterial
var _idle_time := 0.0
var _trail_timer := 0.0
var _body_shape: RectangleShape2D
var _body_collision: CollisionShape2D
var _sensor: Area2D
var _rope: Line2D
var _frames: SpriteFrames
var _vfx_frames: SpriteFrames
var _pivots := {}
var _vfx_pivots := {}
var _combat_fx_frames: SpriteFrames
var _combat_fx_pivots := {}

var _move_x := 0.0
var _vertical := 0.0
var _jump_buffer_timer := 0.0
var _coyote_timer := 0.0
var _takeoff_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _climb_lockout_timer := 0.0
var _wall_jump_lock_timer := 0.0
var _wall_coyote_timer := 0.0
var _wall_coyote_away := 0.0
var _down_hold_time := 0.0
var _air_jumps_left := 0
var _air_dashes_left := 0
var _landing := false
var _flipping := false
var _standing_up := false
var _grapple_phase := GrapplePhase.THROW
var _anchor: Node2D
var _grapple_direction := Vector2.ZERO
var _door: Area2D
var _ledge_phase := LedgePhase.GRAB
## The ledge corner being held (world px) and the side its wall is on (1 right, -1 left).
var _ledge_corner := Vector2.ZERO
var _ledge_side := 1
var _ledge_lockout_timer := 0.0
var _hurt_timer := 0.0
var _blink_time := 0.0


func _ready() -> void:
	if player_state == null:
		player_state = PlayerState.new()
		player_state.has_double_jump = true
		player_state.has_grapple = true
		player_state.has_dash = true
	PlayerInputBindings.register()
	health = PlayerHealth.new()
	health.configure(config.max_health, config.invulnerability_time)
	health.damaged.connect(func(amount: float, left: float) -> void: damaged.emit(amount, left))
	health.healed.connect(func(amount: float, now: float) -> void: healed.emit(amount, now))
	heal_meter = HealMeter.new()
	heal_meter.configure(config.heal_meter_capacity)
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

	_frames = _cached_frames("character", _pivots)
	_vfx_frames = _cached_frames("vfx", _vfx_pivots)
	_combat_fx_frames = _cached_frames("combat_fx", _combat_fx_pivots)

	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = _frames
	_sprite.centered = false
	_sprite.texture_filter = art_filter()
	_sprite.scale = Vector2.ONE * art_scale()
	_sprite.animation_finished.connect(_on_animation_finished)
	add_child(_sprite)

	_aura = AnimatedSprite2D.new()
	_aura.sprite_frames = _vfx_frames
	_aura.centered = false
	_aura.offset = -_vfx_pivots[&"aura_loop"]
	_aura.texture_filter = art_filter()
	_aura.scale = Vector2.ONE * art_scale()
	_aura.visible = false
	if painted:
		# The painted aura is a dense dark-red cloud (the pixel one is sparse specks);
		# drawn normally it hides the Seeker. Added light, it reads as a faint red glow
		# with bright sparks.
		var glow := CanvasItemMaterial.new()
		glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_aura.material = glow
		_aura.self_modulate = Color(1.0, 1.0, 1.0, PAINTED_AURA_STRENGTH)
	add_child(_aura)

	_trail_material = CanvasItemMaterial.new()
	_trail_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	combat = PlayerCombat.new()
	combat.setup(self, attack_config, _sprite, _pivots, _combat_fx_frames, _combat_fx_pivots)
	combat.hit_landed.connect(_on_combat_hit_landed)
	combat.lunge_requested.connect(_on_combat_lunge_requested)
	combat.heavy_ready.connect(_on_combat_heavy_ready)
	add_child(combat)

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
	_down_hold_time = _down_hold_time + delta if _vertical > 0.0 else 0.0
	_wall_jump_lock_timer = maxf(_wall_jump_lock_timer - delta, 0.0)
	_wall_coyote_timer = maxf(_wall_coyote_timer - delta, 0.0)
	_ledge_lockout_timer = maxf(_ledge_lockout_timer - delta, 0.0)
	health.tick(delta)

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
			_state_grapple(delta)
		State.ENTER_DOOR:
			velocity = Vector2.ZERO
		State.ATTACK:
			_state_attack(delta)
		State.HURT:
			_state_hurt(delta)
		State.DEAD:
			_state_dead(delta)
		State.LEDGE:
			_state_ledge()
		State.HEAL:
			_state_heal(delta)

	combat.update(delta)
	_sprite.scale = Vector2(float(facing), 1.0) * art_scale()
	_update_effects(delta)


## Leaves the enter-door state and gives control back to the player. Call it after
## handling [signal door_entered].
func resume_from_door() -> void:
	_set_state(State.GROUND)
	_play_loop(&"idle")


## Takes a hit of [param damage] from something at [param source] (global position).
## Ignored while invulnerable or dead. A landed hit cancels whatever the player was
## doing, turns him to face the source and plays Hurt (HurtKnockback for a hit of at
## least hurt_knockback_damage, whose step back is drawn into the frames); at zero
## health it plays Death instead. Returns true when the hit landed.
func take_hit(damage: float, source: Vector2) -> bool:
	if state == State.DEAD or not health.take_damage(damage):
		return false
	if state == State.HEAL:
		heal_meter.spend()
	var toward := signf(source.x - global_position.x)
	if toward != 0.0:
		facing = int(toward)
	if health.is_depleted():
		_start_death()
	else:
		_start_hurt(damage >= config.hurt_knockback_damage)
	return true


## Brings the player back at [param at] (global position) with full health, standing.
## The respawn itself, and where, is the save system's (story 007).
func revive(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	health.reset()
	heal_meter.reset()
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
	if Input.is_action_just_pressed(&"heal") and _can_start_heal():
		_start_heal()
		return
	if _move_x != 0.0:
		facing = int(_move_x)
	if combat.poll(delta, true, _vertical, _find_overlap(GROUP_DOOR) != null):
		_set_state(State.ATTACK)
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
	_steer(delta, config.ground_acceleration, config.ground_deceleration,
			config.ground_turn_acceleration, config.ground_overspeed_deceleration)
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
	if not combat.is_locked():
		if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
			return
		if Input.is_action_just_pressed(&"dash") and _try_start_dash():
			return
		if _try_start_climb():
			return
		if _jump_buffer_timer > 0.0:
			var wall_away := _wall_jump_direction()
			if _coyote_timer > 0.0:
				_start_ground_jump()
			elif wall_away != 0.0:
				_start_wall_jump(wall_away)
			elif _air_jumps_left > 0:
				_start_air_jump()
	if Input.is_action_just_released(&"jump") and velocity.y < 0.0:
		velocity.y *= config.jump_cut_multiplier

	if _wall_jump_lock_timer <= 0.0:
		if _move_x != 0.0 and not combat.is_attacking():
			facing = int(_move_x)
		_steer(delta, config.air_acceleration, config.air_deceleration,
				config.air_turn_acceleration, config.air_overspeed_deceleration)
	if combat.poll(delta, false, _vertical, false):
		_flipping = false
		velocity.y = minf(velocity.y, config.max_fall_speed)
	_apply_air_gravity(delta)
	var pre_move_vertical := velocity.y
	move_and_slide()
	if is_on_ceiling() and pre_move_vertical < 0.0:
		_correct_corner(pre_move_vertical)

	var pushing_into_wall := is_on_wall() and _move_x != 0.0 and _move_x == -signf(get_wall_normal().x)
	if is_on_floor():
		_land(pre_move_vertical)
	elif pushing_into_wall and pre_move_vertical >= -config.apex_speed and _nudge_onto_ledge():
		_air_animation()
	elif pushing_into_wall and velocity.y >= 0.0 and _try_grab_ledge():
		pass
	elif pushing_into_wall and velocity.y > 0.0:
		_set_state(State.WALL_SLIDE)
		facing = -int(_move_x)
		_play_loop(&"wall_slide")
	else:
		_air_animation()


func _state_dash(delta: float) -> void:
	var grounded := _has_floor_below()
	if _jump_buffer_timer > 0.0 and (grounded or _air_jumps_left > 0):
		_dash_cooldown_timer = config.dash_cooldown
		var carried := float(facing) * config.dash_speed * config.dash_jump_speed_keep
		if grounded:
			_start_ground_jump()
		else:
			_start_air_jump()
		velocity.x = carried
		return

	_dash_timer -= delta
	velocity = Vector2(float(facing) * config.dash_speed, 0.0)
	move_and_slide()
	if _dash_timer <= 0.0 or is_on_wall():
		_dash_cooldown_timer = config.dash_cooldown
		velocity.x = 0.0 if is_on_wall() else float(facing) * config.dash_speed * config.dash_end_speed_keep
		_set_state(State.GROUND if _has_floor_below() else State.AIR)


## Ground swings and the heavy charge. The player keeps running while swinging (input
## steers as on the ground) but facing is locked for the swing (the combo may turn it
## when chaining). While the heavy winds up and charges he is planted: he skids to a
## stop at charge_deceleration and ignores left/right until the release. With no input, the swing's forward step glides out at
## swing_glide_deceleration. Dash, jump and grapple cancel once the attack allows it
## ([method PlayerCombat.is_locked]); walking off an edge ends the attack.
func _state_attack(delta: float) -> void:
	if not combat.is_attacking():
		_set_state(State.GROUND)
		_state_ground(delta)
		return
	if not combat.is_locked():
		if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
			return
		if Input.is_action_just_pressed(&"dash") and _try_start_dash():
			return
		if _jump_buffer_timer > 0.0:
			_start_ground_jump()
			return
	if combat.phase == PlayerCombat.Phase.CHARGE:
		velocity.x = move_toward(velocity.x, 0.0, attack_config.charge_deceleration * delta)
	else:
		_steer(delta, config.ground_acceleration, attack_config.swing_glide_deceleration,
				config.ground_turn_acceleration, config.ground_overspeed_deceleration)
	velocity.y = config.gravity * delta
	move_and_slide()
	if not is_on_floor():
		_set_state(State.AIR)


## The planted heal. Holding heal for heal_channel_time restores heal_amount and empties
## the meter. Letting go, jumping, dashing, attacking or grappling ends it early for free
## (the meter is kept); a hit that lands ends it and empties the meter (take_hit).
func _state_heal(delta: float) -> void:
	if not Input.is_action_pressed(&"heal"):
		_end_heal()
		return
	if Input.is_action_just_pressed(&"grapple") or Input.is_action_just_pressed(&"dash") \
			or Input.is_action_just_pressed(&"attack") or _jump_buffer_timer > 0.0:
		_end_heal()
		_state_ground(delta)
		return
	velocity.x = move_toward(velocity.x, 0.0, config.heal_deceleration * delta)
	velocity.y = config.gravity * delta
	move_and_slide()
	if not is_on_floor():
		_set_state(State.AIR)
		return
	heal_time += delta
	_sprite.modulate = Color.WHITE.lerp(HEAL_TINT, clampf(heal_time / config.heal_channel_time, 0.0, 1.0))
	if heal_time >= config.heal_channel_time:
		health.heal(config.heal_amount)
		heal_meter.spend()
		_end_heal()


func _can_start_heal() -> bool:
	return heal_meter.is_full() and health.is_hurt()


func _start_heal() -> void:
	_set_state(State.HEAL)
	heal_time = 0.0
	_jump_buffer_timer = 0.0
	_play_loop(&"idle")


func _end_heal() -> void:
	_set_state(State.GROUND)
	_play_loop(&"idle")


## No control for hurt_lock_time; leftover speed bleeds off and gravity still pulls.
func _state_hurt(delta: float) -> void:
	_hurt_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, config.hurt_deceleration * delta)
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)
	move_and_slide()
	if _hurt_timer <= 0.0:
		_set_state(State.GROUND if is_on_floor() else State.AIR)


## Falls to the floor and stays; the Death clip holds its last frame.
func _state_dead(delta: float) -> void:
	velocity.x = 0.0
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)
	move_and_slide()


func _state_wall_slide(delta: float) -> void:
	if Input.is_action_just_pressed(&"grapple") and _try_start_grapple():
		return
	var away := signf(get_wall_normal().x)
	if _jump_buffer_timer > 0.0:
		_start_wall_jump(away)
		return
	velocity.x = _move_x * config.run_speed
	velocity.y = minf(velocity.y + config.gravity * delta, config.wall_slide_speed)
	move_and_slide()
	if is_on_floor():
		_set_state(State.GROUND)
	elif not is_on_wall() or _move_x == 0.0 or _move_x != -signf(get_wall_normal().x):
		_wall_coyote_timer = config.wall_coyote_time
		_wall_coyote_away = away
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


func _state_grapple(delta: float) -> void:
	if _grapple_phase != GrapplePhase.THROW and _jump_buffer_timer > 0.0:
		_grapple_jump_out()
		return
	match _grapple_phase:
		GrapplePhase.THROW:
			_aim_at_anchor()
		GrapplePhase.PULL:
			_aim_at_anchor()
			var to_anchor := _anchor.global_position - _hand_position()
			if to_anchor.length() <= config.grapple_arrive_distance:
				_begin_grapple_release(true)
			else:
				_grapple_direction = to_anchor.normalized()
				velocity = _grapple_direction * config.grapple_speed
				move_and_slide()
				if is_on_wall() or is_on_ceiling() or (is_on_floor() and to_anchor.y > 0.0):
					_begin_grapple_release(false)
		GrapplePhase.RELEASE:
			velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)
			var impact := velocity.y
			move_and_slide()
			if is_on_floor():
				_land(impact)
				return

	var rope_shown := _grapple_phase == GrapplePhase.PULL \
			or (_grapple_phase == GrapplePhase.THROW and _sprite.frame >= 1)
	_rope.visible = rope_shown
	if rope_shown:
		_rope.set_point_position(0, _hand_position())
		_rope.set_point_position(1, _anchor.global_position)


# --- Transitions -----------------------------------------------------------

func _set_state(new_state: State) -> void:
	if new_state != State.ATTACK:
		combat.cancel()
	if state == State.CROUCH and new_state != State.CROUCH:
		_apply_hitbox(config.hitbox_size.y)
	if state == State.GRAPPLE and new_state != State.GRAPPLE:
		_sprite.rotation = 0.0
		_rope.visible = false
	if state == State.LEDGE and new_state != State.LEDGE:
		_sprite.position = Vector2.ZERO
	if state == State.HEAL and new_state != State.HEAL:
		heal_time = 0.0
		_sprite.modulate = Color.WHITE
	_landing = false
	_flipping = false
	_standing_up = false
	state = new_state


func _start_hurt(knockback: bool) -> void:
	_set_state(State.HURT)
	_hurt_timer = config.hurt_lock_time
	velocity.x = 0.0
	velocity.y = maxf(velocity.y, 0.0)
	_start_clip(&"hurt_knockback" if knockback else &"hurt")


func _start_death() -> void:
	heal_meter.reset()
	_set_state(State.DEAD)
	velocity.x = 0.0
	_start_clip(&"death")


func _start_ground_jump() -> void:
	_set_state(State.AIR)
	velocity.y = -config.jump_speed
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_takeoff_timer = config.jump_takeoff_time
	_spawn_effect(&"dust_jump")


func _start_wall_jump(away: float) -> void:
	_set_state(State.AIR)
	facing = int(away)
	velocity = Vector2(away * config.wall_jump_push_speed, -config.wall_jump_speed)
	_wall_jump_lock_timer = config.wall_jump_control_lock_time
	_wall_coyote_timer = 0.0
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
	landed.emit(impact)
	if impact >= config.land_min_fall_speed:
		_landing = true
		_start_clip(&"jump_land")
		_spawn_effect(&"dust_land")


func _try_start_dash() -> bool:
	if not player_state.has_dash or _dash_cooldown_timer > 0.0:
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
	if not player_state.has_grapple:
		return false
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
	_grapple_direction = (_anchor.global_position - global_position).normalized()
	facing = 1 if _anchor.global_position.x >= global_position.x else -1
	velocity = Vector2.ZERO
	_set_state(State.GRAPPLE)
	_grapple_phase = GrapplePhase.THROW
	_start_clip(&"grapple_throw")
	return true


## Lets go of the anchor, keeping part of the pull velocity so the player is flung on.
## When the pull reached the anchor ([param arrived]), the upward speed is set so the
## feet peak grapple_fling_height above the anchor; a pull stopped by a wall keeps
## only its slid velocity.
func _begin_grapple_release(arrived: bool) -> void:
	_grapple_phase = GrapplePhase.RELEASE
	velocity *= config.grapple_fling_keep
	if arrived:
		var rise := global_position.y - (_anchor.global_position.y - config.grapple_fling_height)
		velocity.y = -sqrt(2.0 * config.gravity * rise) if rise > 0.0 else 0.0
	_sprite.rotation = 0.0
	_start_clip(&"grapple_release")


## Jumps out of a grapple pull or release: carries part of the pull velocity, adds an
## upward kick, and restores the air dash (and the air jump, when the double jump is
## owned) so moves can be chained.
func _grapple_jump_out() -> void:
	var carried := _grapple_direction * config.grapple_speed * config.grapple_jump_keep
	_set_state(State.AIR)
	_refresh_air_moves()
	velocity = Vector2(carried.x, carried.y - config.grapple_jump_speed)
	if velocity.x != 0.0:
		facing = int(signf(velocity.x))
	_jump_buffer_timer = 0.0
	_flipping = true
	_start_clip(&"double_jump")
	_spawn_effect(&"air_jump_ring")


## A down attack that hits launches the player back up and refreshes the air moves.
## Full charge: a burst on the blade and a short bright flash on the Seeker, so the
## moment the heavy will break a guard is unmistakable.
func _on_combat_heavy_ready() -> void:
	_spawn_effect(&"charge_release", attack_config.heavy_ready_fx_offset)
	_sprite.modulate = attack_config.heavy_ready_flash_color
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color.WHITE, attack_config.heavy_ready_flash_time)


## A ground swing steps forward: forward speed is raised to at least [param speed].
func _on_combat_lunge_requested(speed: float) -> void:
	if not _has_floor_below():
		return
	velocity.x = float(facing) * maxf(velocity.x * float(facing), speed)


func _on_combat_hit_landed(target: Node2D, attack: String, damage: float) -> void:
	if not target is HitTarget:
		heal_meter.add(damage)
	if attack == PlayerCombat.ATTACK_DOWN:
		velocity.y = -attack_config.pogo_speed
		_refresh_air_moves()


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
		&"death":
			if state == State.DEAD:
				died.emit()
		&"ledge_grab":
			if state == State.LEDGE and _ledge_phase == LedgePhase.GRAB:
				_ledge_phase = LedgePhase.HANG
				_play_loop(&"ledge_hang")
		&"ledge_pull_up":
			if state == State.LEDGE:
				_finish_pull_up()


# --- Helpers ---------------------------------------------------------------

## Every grant of air jumps goes through here (ground, climb, grapple jump-out, pogo), so
## without the double jump the count stays 0 and no air jump or air dash-jump can start.
func _refresh_air_moves() -> void:
	_air_jumps_left = config.air_jumps if player_state.has_double_jump else 0
	_air_dashes_left = config.air_dashes


## Moves velocity.x toward the input's run speed. Speed above run_speed (dash, fling)
## bleeds off at [param overspeed] while the input agrees with it or is neutral.
func _steer(delta: float, acceleration: float, deceleration: float, turn: float, overspeed: float) -> void:
	var rate := acceleration
	if absf(velocity.x) > config.run_speed and (_move_x == 0.0 or _move_x == signf(velocity.x)):
		rate = overspeed
	elif _move_x == 0.0:
		rate = deceleration
	elif velocity.x != 0.0 and _move_x != signf(velocity.x):
		rate = turn
	velocity.x = move_toward(velocity.x, _move_x * config.run_speed, rate * delta)


## Air gravity: lighter at the apex while jump is held, heavier when falling, heavier
## still when down has been held for fast_fall_hold_time (fast fall). No fast fall
## during an attack, and a down attack caps the fall so its hit frames meet the target.
func _apply_air_gravity(delta: float) -> void:
	var acceleration := config.gravity
	var max_fall := config.max_fall_speed
	if absf(velocity.y) < config.apex_hang_speed and Input.is_action_pressed(&"jump"):
		acceleration *= config.apex_hang_gravity_multiplier
	elif velocity.y > 0.0:
		acceleration *= config.fall_gravity_multiplier
		if combat.is_attacking():
			if combat.current_attack == PlayerCombat.ATTACK_DOWN:
				max_fall = attack_config.down_attack_max_fall_speed
		elif _down_hold_time >= config.fast_fall_hold_time:
			acceleration *= config.fast_fall_gravity_multiplier
			max_fall = config.fast_fall_speed
	if velocity.y > max_fall:
		velocity.y = move_toward(velocity.y, max_fall, acceleration * delta)
	else:
		velocity.y = minf(velocity.y + acceleration * delta, max_fall)


## Away direction (+1 or -1) for a wall jump, or 0 when none is allowed: a wall within
## wall_jump_reach, else a wall left less than wall_coyote_time ago.
func _wall_jump_direction() -> float:
	if test_move(global_transform, Vector2(-config.wall_jump_reach, 0.0)):
		return 1.0
	if test_move(global_transform, Vector2(config.wall_jump_reach, 0.0)):
		return -1.0
	if _wall_coyote_timer > 0.0:
		return _wall_coyote_away
	return 0.0


## The head hit a ceiling while rising: slide sideways up to corner_correction pixels
## to clear its edge, keeping the upward speed.
func _correct_corner(rising_speed: float) -> void:
	for distance in range(1, config.corner_correction + 1):
		for direction in [-1.0, 1.0]:
			var shift := Vector2(float(distance) * float(direction), 0.0)
			if not test_move(global_transform, shift) \
					and not test_move(global_transform.translated(shift), Vector2(0.0, -1.0)):
				global_position += shift
				velocity.y = rising_speed
				return


## Falling into a wall with a ledge corner at the hands: catch it. The corner is the
## wall's top just past the body's edge, found within the catch window around the hang
## height; there must be room to stand on top. Returns true when the Seeker caught it.
func _try_grab_ledge() -> bool:
	if not config.ledge_grab_enabled or _ledge_lockout_timer > 0.0 \
			or not _frames.has_animation(&"ledge_hang"):
		return false
	var side := int(-signf(get_wall_normal().x))
	var face_x := global_position.x + float(side) * config.hitbox_size.x * 0.5
	var probe_x := face_x + float(side) * 2.0
	var hands_y := global_position.y - config.ledge_hang_drop
	var top := INF
	for dy in range(-int(config.ledge_grab_window_up), int(config.ledge_grab_window_down) + 1):
		var y := hands_y + float(dy)
		if not _is_solid(Vector2(probe_x, y - 1.0)) and _is_solid(Vector2(probe_x, y)):
			# Narrow the wall's top to a fraction of a pixel.
			var above := y - 1.0
			var below := y
			for i in 5:
				var middle := (above + below) * 0.5
				if _is_solid(Vector2(probe_x, middle)):
					below = middle
				else:
					above = middle
			top = below
			break
	if is_inf(top):
		return false
	var corner := Vector2(face_x, top)
	var stand := corner + Vector2(float(side) * config.ledge_stand_offset, -1.0)
	if test_move(Transform2D(0.0, stand), Vector2(0.0, -1.0)):
		return false
	_set_state(State.LEDGE)
	_ledge_corner = corner
	_ledge_side = side
	_ledge_phase = LedgePhase.GRAB
	facing = side
	velocity = Vector2.ZERO
	global_position = Vector2(face_x - float(side) * (config.hitbox_size.x * 0.5 + 0.5),
			corner.y + config.ledge_hang_drop)
	_start_clip(&"ledge_grab")
	_place_ledge_sprite()
	return true


## Catching, hanging or pulling up: the body stays put (the climb is drawn in the
## frames, around the corner) until the pull-up's last frame moves it onto the ledge.
## While hanging: jump, up or a fresh press toward the wall pulls up; jump away from
## the wall wall-jumps off; down or away lets go.
func _state_ledge() -> void:
	velocity = Vector2.ZERO
	facing = _ledge_side
	_place_ledge_sprite()
	if _ledge_phase != LedgePhase.HANG:
		return
	var away := -_ledge_side
	var jump := _jump_buffer_timer > 0.0
	# Holding toward the wall is how the ledge was caught, so only a fresh press toward
	# it pulls up (jump and up always do).
	var toward_pressed := Input.is_action_just_pressed(
			&"move_right" if _ledge_side > 0 else &"move_left")
	if jump and _move_x == float(away):
		_jump_buffer_timer = 0.0
		_start_wall_jump(float(away))
		_ledge_lockout_timer = config.ledge_regrab_lockout
	elif jump or _vertical < 0.0 or toward_pressed:
		_jump_buffer_timer = 0.0
		_ledge_phase = LedgePhase.PULL
		_start_clip(&"ledge_pull_up")
	elif _vertical > 0.0 or _move_x == float(away):
		_ledge_lockout_timer = config.ledge_regrab_lockout
		_set_state(State.AIR)


## Puts the ledge art's corner pixel (its pivot) on the held corner.
func _place_ledge_sprite() -> void:
	_sprite.position = _ledge_corner - global_position


## The pull-up's last frame is the idle pose standing on the ledge: move the body there
## and carry on standing.
func _finish_pull_up() -> void:
	global_position = _ledge_corner + Vector2(float(_ledge_side) * config.ledge_stand_offset, 0.0)
	# The corner was measured to a fraction of a pixel; settle onto the floor exactly.
	velocity = Vector2.ZERO
	apply_floor_snap()
	_set_state(State.GROUND)
	_refresh_air_moves()
	_play_loop(&"idle")


func _is_solid(point: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = LAYER_WORLD
	return not get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()


## The feet just missed a ledge while moving into it: lift up to ledge_nudge pixels
## onto it. Returns true when the player was lifted.
func _nudge_onto_ledge() -> bool:
	var into_wall := Vector2(_move_x, 0.0)
	for lift in range(1, config.ledge_nudge + 1):
		var up := Vector2(0.0, -float(lift))
		if not test_move(global_transform, up) and not test_move(global_transform.translated(up), into_wall):
			global_position += up
			return true
	return false


func _has_floor_below() -> bool:
	return test_move(global_transform, Vector2(0.0, 1.0))


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
	return _sprite.to_global(config.grapple_hand_offset / art_scale())


func _air_animation() -> void:
	if _flipping or combat.is_attacking():
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


## The idle aura (shown after idle_aura_delay of standing still), the invulnerability
## blink and the dash afterimage trail.
func _update_effects(delta: float) -> void:
	_blink_time = _blink_time + delta if health.is_invulnerable() and state != State.DEAD else 0.0
	var faded := fmod(_blink_time, config.invulnerability_blink_period) \
			> config.invulnerability_blink_period * 0.5
	_sprite.self_modulate.a = config.invulnerability_blink_alpha if faded else 1.0

	var idle := state == State.GROUND and _move_x == 0.0 and absf(velocity.x) < 1.0
	_idle_time = _idle_time + delta if idle else 0.0
	var show_aura := _idle_time >= config.idle_aura_delay
	if show_aura != _aura.visible:
		_aura.visible = show_aura
		if show_aura:
			_aura.play(&"aura_loop")
		else:
			_aura.stop()

	if state != State.DASH:
		_trail_timer = 0.0
		return
	_trail_timer -= delta
	if _trail_timer <= 0.0:
		_trail_timer = config.dash_trail_interval
		_spawn_afterimage()


## Leaves a fading, additive copy of the current frame behind the player.
func _spawn_afterimage() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)
	ghost.centered = false
	ghost.offset = _sprite.offset
	ghost.scale = _sprite.scale
	ghost.texture_filter = art_filter()
	ghost.material = _trail_material
	ghost.modulate = config.dash_trail_color
	get_parent().add_child(ghost)
	get_parent().move_child(ghost, get_index())
	ghost.global_position = global_position
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, config.dash_trail_lifetime)
	tween.tween_callback(ghost.queue_free)


## Plays a one-shot effect with its anchor on the feet point, or on [param offset] from
## it (written facing right, mirrored with facing).
func _spawn_effect(clip: StringName, offset := Vector2.ZERO) -> void:
	var effect := DustEffect.new()
	get_parent().add_child(effect)
	var point := global_position + Vector2(offset.x * float(facing), offset.y)
	effect.start(_vfx_frames, clip, _vfx_pivots[clip], point, facing, art_scale(), art_filter())


## The body sprite (current animation frame, offset, facing and art scale), for effects
## that follow the Seeker's silhouette, such as a room's backlight.
func body_sprite() -> AnimatedSprite2D:
	return _sprite


## World px per art px: 1 for the pixel art, 1 / PAINTED_SCALE for the painted art.
## Every Seeker sprite (body, combat FX, effects, afterimages) is drawn at this scale.
func art_scale() -> float:
	return 1.0 / PAINTED_SCALE if painted else 1.0


## Texture filter for the Seeker's art: crisp for the pixel art, smooth (with mipmaps,
## since it is drawn well below its painted size) for the painted art.
func art_filter() -> CanvasItem.TextureFilter:
	return CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS if painted \
			else CanvasItem.TEXTURE_FILTER_NEAREST


## Builds SpriteFrames from one group of seeker_animations.json: one animation per
## clip, sliced from its sheet, each frame lasting its listed milliseconds. Fills
## [param pivots] with each clip's feet point or anchor.
## Built animation frames are shared by every Player with the same palette and art, so a
## room change (which makes a new Player) doesn't reload and rebuild them (about 1.4 s).
## [group, palette, painted] -> [SpriteFrames, pivots].
static var _frames_cache := {}


func _cached_frames(group: String, pivots: Dictionary) -> SpriteFrames:
	var key := "%s|%s|%s" % [group, palette, painted]
	if not _frames_cache.has(key):
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ANIMATION_DATA_PATH))
		var built_pivots := {}
		var frames := _build_frames(data[group], built_pivots)
		_frames_cache[key] = [frames, built_pivots]
	var entry: Array = _frames_cache[key]
	pivots.merge(entry[1], true)
	return entry[0]


func _build_frames(group: Dictionary, pivots: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directory := str(group["dir"]).replace("{palette}", palette)
	if painted:
		directory = directory.replace(PIXEL_ART_ROOT, PAINTED_ART_ROOT)
	var sheets: Dictionary = group["sheets"]
	var clips: Dictionary = group["clips"]
	for clip_key in clips:
		var clip_name := StringName(clip_key)
		var clip: Dictionary = clips[clip_key]
		var sheet: Dictionary = sheets[clip["sheet"]]
		if sheet.get("painted_only", false) and not painted:
			continue
		if painted:
			sheet = _painted_sheet(sheet)
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


## The painted version of a sheet entry: its own "painted" block when it has one (the
## painted wall slide is drawn on the 30x30 frame, not the 40x40 one), otherwise the
## same entry with the size in the file name, the frame size and the pivot scaled by
## PAINTED_SCALE.
func _painted_sheet(sheet: Dictionary) -> Dictionary:
	if sheet.get("painted_only", false):
		return sheet
	if sheet.has("painted"):
		var own: Dictionary = sheet.duplicate()
		own.merge(sheet["painted"], true)
		return own
	var scaled: Dictionary = sheet.duplicate()
	var k := int(PAINTED_SCALE)
	var size := Vector2i(int(sheet["frame_size"][0]), int(sheet["frame_size"][1]))
	scaled["file"] = str(sheet["file"]).replace("_%dx%d_" % [size.x, size.y],
			"_%dx%d_" % [size.x * k, size.y * k])
	scaled["frame_size"] = [size.x * k, size.y * k]
	scaled["pivot"] = [float(sheet["pivot"][0]) * k, float(sheet["pivot"][1]) * k]
	return scaled
