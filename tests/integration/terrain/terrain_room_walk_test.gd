## Walks the real Seeker through the terrain test room (ADR-0001's open corner criteria):
## off a ledge's lip, down a long flush face, into an inside corner, under a ceiling block,
## up through a one-way platform, and down a face whose material changes. Every run asserts
## the Seeker is never held by an invisible step and the face lookup agrees with the room.
## Run: xvfb-run -a godot --path . --rendering-method gl_compatibility \
##          --rendering-driver opengl3 -s res://tests/integration/terrain/terrain_room_walk_test.gd
## (it also runs headless; the camera is not needed.)
extends MiniTest

const ROOM_SCENE := "res://src/test_rooms/terrain_test_room.tscn"
const RUN_STEP := 140.0 / 60.0
const WALL_SLIDE_STEP := 60.0 / 60.0

var _room: Node
var _player: Player


func _load_room() -> void:
	_room = (load(ROOM_SCENE) as PackedScene).instantiate()
	root.add_child(_room)
	await physics_frame
	for child in _room.get_children():
		if child is Player:
			_player = child
	_player.config.ledge_grab_enabled = false


func _place(feet: Vector2, state: Player.State = Player.State.AIR) -> void:
	_player.global_position = feet
	_player.velocity = Vector2.ZERO
	_player._set_state(state)


func _release_all() -> void:
	for action in [&"move_left", &"move_right", &"jump"]:
		Input.action_release(action)


func _unload_room() -> void:
	_release_all()
	_room.free()
	_player = null
	await physics_frame


func test_walking_off_a_ledge_top_is_not_held_before_the_lip() -> void:
	await _load_room()
	_place(Vector2(490, 168), Player.State.GROUND)   # the thin ledge's top, x 480 to 576
	await physics_frame
	Input.action_press(&"move_right")
	var x_prev := _player.global_position.x
	var worst := 0.0
	var on_edge_frames := 0
	var left_the_block := false
	for f in 60:
		await physics_frame
		var x := _player.global_position.x
		if absf(_player.global_position.y - 168.0) < 0.5 and x < 572.0 and f > 12:
			worst = maxf(worst, absf((x - x_prev) - RUN_STEP))
			on_edge_frames += 1
		left_the_block = left_the_block or _player.global_position.y > 175.0
		x_prev = x
	assert_true(on_edge_frames > 10, "walked at full speed on the ledge for several frames (%d)" % on_edge_frames)
	assert_near(worst, 0.0, 0.1, "no frame deviates from the run step before the lip")
	assert_true(left_the_block, "and the Seeker walks off the lip and falls")
	await _unload_room()


func test_sliding_down_the_flush_pillar_and_block_face_is_steady() -> void:
	await _load_room()
	_place(Vector2(120 - 5.5, 150))   # beside the left face (x = 120), y 138 to 216
	Input.action_press(&"move_right")
	var y_prev := _player.global_position.y
	var min_step := 1e9
	var max_step := 0.0
	var slid := 0
	for f in 100:
		await physics_frame
		var y := _player.global_position.y
		if _player.state == Player.State.WALL_SLIDE and y > 152.0 and y < 205.0:
			min_step = minf(min_step, y - y_prev)
			max_step = maxf(max_step, y - y_prev)
			slid += 1
		y_prev = y
	assert_true(slid > 20, "slid for many frames (%d)" % slid)
	assert_near(min_step, WALL_SLIDE_STEP, 0.05, "the slowest slide step across the pillar and block join")
	assert_near(max_step, WALL_SLIDE_STEP, 0.05, "the fastest slide step")
	await _unload_room()


func test_pressing_into_an_inside_corner_leaves_the_seeker_still() -> void:
	await _load_room()
	_place(Vector2(200, 216), Player.State.GROUND)   # the floor beside the block's right face (x = 192)
	await physics_frame
	Input.action_press(&"move_left")
	for f in 40:
		await physics_frame
	var x := _player.global_position.x
	var y := _player.global_position.y
	for f in 20:
		await physics_frame
	assert_near(_player.global_position.x, x, 0.01, "no jitter along the wall")
	assert_near(_player.global_position.y, y, 0.01, "no jitter down the floor")
	assert_near(y, 216.0, 0.2, "feet on the floor's top")
	assert_near(x, 197.0, 0.3, "the body's side rests on the face")
	await _unload_room()


func test_a_ceiling_block_stops_the_head_and_the_seeker_comes_back_down() -> void:
	await _load_room()
	_place(Vector2(846, 216), Player.State.GROUND)   # under the ceiling block, its underside at y 60
	await physics_frame
	var highest := 1e9
	Input.action_press(&"jump")
	for f in 8:
		await physics_frame
		highest = minf(highest, _player.global_position.y)
	Input.action_release(&"jump")
	for f in 120:
		await physics_frame
		highest = minf(highest, _player.global_position.y)
	assert_true(highest > 60.0 + 22.0 - 0.3, "the head never passes the underside (feet y %.2f)" % highest)
	assert_near(_player.global_position.y, 216.0, 0.2, "back on the floor")
	await _unload_room()


func test_a_one_way_platform_is_passed_from_below_and_stood_on() -> void:
	await _load_room()
	_place(Vector2(630, 216), Player.State.GROUND)   # under the platform whose top is y 180
	await physics_frame
	Input.action_press(&"jump")
	for f in 12:
		await physics_frame
	Input.action_release(&"jump")
	for f in 120:
		await physics_frame
	assert_near(_player.global_position.y, 180.0, 0.2, "standing on the platform's top")
	assert_eq(_player.state, Player.State.GROUND, "grounded")
	await _unload_room()


func test_the_face_lookup_follows_the_seeker_down_the_tall_wall() -> void:
	await _load_room()
	var terrain: Terrain = _room._terrain
	_place(Vector2(786 + 5.5, 80))   # beside the tall wall's right face (x = 786), y 72 to 216
	Input.action_press(&"move_left")
	var checked_plain := false
	var checked_no_cling := false
	for f in 180:
		await physics_frame
		if _player.state != Player.State.WALL_SLIDE:
			continue
		var feet := _player.global_position.y
		var rect := Rect2(_player.global_position + Vector2(-5, -22), Vector2(10, 22))
		var span := terrain.face_materials(rect, _player.get_wall_normal())
		if not checked_plain and feet > 110.0 and feet < 130.0:
			assert_eq(span.count("no_cling"), 0, "plain above row 24 at feet y %.1f" % feet)
			assert_true(span.size() > 0, "a face is found there")
			checked_plain = true
		if not checked_no_cling and feet > 185.0 and feet < 200.0:
			assert_eq(span.count("no_cling"), span.size(), "no_cling below row 24 at feet y %.1f" % feet)
			assert_true(span.size() > 0, "a face is found there")
			checked_no_cling = true
	assert_true(checked_plain, "the plain stretch was read")
	assert_true(checked_no_cling, "the no_cling stretch was read")
	await _unload_room()
