## Follow camera for the Seeker: smooth follow, look-ahead in the facing direction, a
## downward lead while falling fast, and a small dip on hard landings. Every value
## comes from the player's [PlayerConfig] (group "Camera").
##
## Usage: [codeblock]
## var camera := PlayerCamera.new()
## player.add_child(camera)
## camera.setup(player)
## [/codeblock]
class_name PlayerCamera
extends Camera2D

var _player: Player
var _lead := Vector2.ZERO
var _dip := 0.0


## Starts following [param target]. Call after the camera is a child of the player.
func setup(target: Player) -> void:
	_player = target
	position_smoothing_enabled = true
	position_smoothing_speed = target.config.camera_smoothing_speed
	limit_smoothed = true
	target.landed.connect(_on_player_landed)


func _process(delta: float) -> void:
	if _player == null:
		return
	var config := _player.config
	var target := Vector2(float(_player.facing) * config.camera_look_ahead, 0.0)
	if _player.velocity.y >= config.camera_fall_lead_min_speed:
		target.y = config.camera_fall_lead
	_lead = _lead.lerp(target, 1.0 - exp(-config.camera_offset_speed * delta))
	_dip = move_toward(_dip, 0.0, config.camera_landing_dip_recover_speed * delta)
	offset = _lead + Vector2(0.0, _dip)


func _on_player_landed(impact_speed: float) -> void:
	if impact_speed >= _player.config.camera_landing_dip_min_speed:
		_dip = _player.config.camera_landing_dip
