## Integration tests for the Cinderheart rooms: exits change rooms and arrive at the
## matching exit, and the Glaze Bridge gap needs the dash. Real rooms, real physics.
## Run: godot --headless --path . -s res://tests/integration/cinderheart/region_flow_test.gd
extends MiniTest

const ROOMS := "res://src/world/cinderheart/rooms/"


func _load(room: String, arrive: StringName, dash: bool) -> RegionRoom:
	RegionTravel.reset()
	RegionTravel.player_state.has_dash = dash
	RegionTravel.arrival_exit = arrive
	change_scene_to_file(ROOMS + room + ".tscn")
	for i in 30:
		await physics_frame
	return current_scene as RegionRoom


func _release_all() -> void:
	for action in [&"move_right", &"move_left", &"jump", &"dash"]:
		Input.action_release(action)


func test_walking_out_the_right_edge_arrives_in_the_next_room() -> void:
	var room: RegionRoom = await _load("c01_waking_niche", &"", false)
	room.player.global_position = Vector2(44 * 36, 6 * 36 - 4)
	Input.action_press(&"move_right")
	for i in 120:
		await physics_frame
		# During the swap there is briefly no current scene.
		if current_scene != null and current_scene.scene_file_path.ends_with("c02_ash_steps.tscn"):
			_release_all()
	_release_all()
	while current_scene == null:
		await process_frame
	assert_eq(current_scene.scene_file_path, ROOMS + "c02_ash_steps.tscn", "now in Ash Steps")
	var next := current_scene as RegionRoom
	assert_true(next.player.global_position.x < 160.0, "arrived at its left edge (x %.0f)" % next.player.global_position.x)


func _try_bridge(dash: bool) -> float:
	var room: RegionRoom = await _load("c05_glaze_bridge", &"left", dash)
	var player := room.player
	player.global_position = Vector2(10 * 36, 14 * 36 - 4)
	for i in 10:
		await physics_frame
	Input.action_press(&"move_right")
	while player.global_position.x < 19 * 36 + 20:
		await physics_frame
	Input.action_press(&"jump")
	for i in 12:
		await physics_frame
	if dash:
		Input.action_press(&"dash")
	for i in 90:
		await physics_frame
	_release_all()
	for i in 30:
		await physics_frame
	return player.global_position.y


func test_glaze_bridge_gap_stops_a_run_jump() -> void:
	var y: float = await _try_bridge(false)
	# Near floor ~511, pit floor ~619 (or its step ~547), far ledge ~475.
	assert_true(y > 14 * 36 + 20, "fell into the pit (y %.0f)" % y)


func test_glaze_bridge_gap_is_crossed_with_the_dash() -> void:
	var y: float = await _try_bridge(true)
	assert_true(y < 13 * 36 + 20, "on the far ledge (y %.0f)" % y)
