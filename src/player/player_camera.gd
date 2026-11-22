## Follow camera for the Seeker: smooth follow, look-ahead in the facing direction, a
## downward lead while falling fast, a small dip on hard landings, and a short shake
## when the player's combat asks for one. Every follow value comes from the player's
## [PlayerConfig] (group "Camera"); each shake's size and time come from the attack.
##
## Usage: [codeblock]
## var camera := PlayerCamera.new()
## player.add_child(camera)
## camera.setup(player)
## [/codeblock]
class_name PlayerCamera
extends Camera2D

## One screen of the world is this tall in game px; the zoom is the base canvas height
## divided by it (4 at the 1080 base), so every length in the GDDs stays game px
## (docs/architecture/adr-0002-display-base-and-camera-zoom.md).
const GAME_SCREEN_HEIGHT := 270.0

var _player: Player
var _lead := Vector2.ZERO
var _dip := 0.0
var _shake_size := 0.0
var _shake_duration := 0.0
var _shake_left := 0.0


## Starts following [param target] and listens to its combat for shakes. Call after the
## camera is a child of the player and the player is in the tree.
func setup(target: Player) -> void:
	_player = target
	var base_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	zoom = Vector2.ONE * (base_height / GAME_SCREEN_HEIGHT)
	position_smoothing_enabled = true
	position_smoothing_speed = target.config.camera_smoothing_speed
	limit_smoothed = true
	target.landed.connect(_on_player_landed)
	target.combat.camera_shake_requested.connect(request_shake)


## Shakes the view by up to [param size] pixels, fading out over [param duration] seconds.
func request_shake(size: float, duration: float) -> void:
	_shake_size = size
	_shake_duration = duration
	_shake_left = duration


func _process(delta: float) -> void:
	if _player == null:
		return
	var config := _player.config
	var target := Vector2(float(_player.facing) * config.camera_look_ahead, 0.0)
	if _player.velocity.y >= config.camera_fall_lead_min_speed:
		target.y = config.camera_fall_lead
	_lead = _lead.lerp(target, 1.0 - exp(-config.camera_offset_speed * delta))
	_dip = move_toward(_dip, 0.0, config.camera_landing_dip_recover_speed * delta)
	_shake_left = maxf(_shake_left - delta, 0.0)
	var shake_offset := Vector2.ZERO
	if _shake_left > 0.0:
		shake_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) \
				* _shake_size * (_shake_left / _shake_duration)
	# Look-ahead, fall lead and landing dip move the camera's position, so the room's
	# limits (and any drag margins) still apply: a Camera2D offset may go past its limits,
	# which showed the void below a room's floor on landing. Only the brief shake stays an
	# offset, so it still reads inside a drag window.
	position = _lead + Vector2(0.0, _dip)
	offset = shake_offset


func _on_player_landed(impact_speed: float) -> void:
	if impact_speed >= _player.config.camera_landing_dip_min_speed:
		_dip = _player.config.camera_landing_dip
