## Measures the Seeker's jump in the real game: max rise standing, and the longest gap a
## run jump and a dash jump cross at the same height. Prints world px.
## Run: godot --headless --path . -s res://tools/level/measure_jump.gd -- [jump_speed]
extends SceneTree

const ROOM := preload("res://src/test_rooms/movement_test_room.tscn")


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for speed in ([float(args[0])] if args.size() > 0 else [330.0, 380.0, 400.0, 420.0]):
		var rise := await _measure(speed, false, false)
		var run := await _measure(speed, true, false)
		var dash := await _measure(speed, true, true)
		print("jump_speed %d: rise %.0f px, run-jump %.0f px, dash-jump %.0f px" % [speed, rise.y, run.x, dash.x])
	quit()


## Jumps on flat ground; returns (horizontal distance until back at take-off height, max rise).
func _measure(speed: float, run: bool, dash: bool) -> Vector2:
	var room := ROOM.instantiate()
	root.add_child(room)
	await physics_frame
	var player: Player = room.get("_player") if room.get("_player") != null else _find_player(room)
	player.config = player.config.duplicate()
	player.config.jump_speed = speed
	player.player_state.has_dash = true
	for i in 30:
		await physics_frame
	if run:
		Input.action_press(&"move_right")
		for i in 40:
			await physics_frame
	var y0 := player.global_position.y
	var x0 := player.global_position.x
	Input.action_press(&"jump")
	var top := 0.0
	var started := false
	for i in 240:
		await physics_frame
		if dash and i == 8:
			Input.action_press(&"dash")
		if i == 10:
			Input.action_release(&"dash")
		top = maxf(top, y0 - player.global_position.y)
		if player.global_position.y < y0 - 2.0:
			started = true
		if started and player.global_position.y >= y0:
			break
	var dx := player.global_position.x - x0
	for a in [&"move_right", &"jump", &"dash"]:
		Input.action_release(a)
	room.queue_free()
	await process_frame
	return Vector2(dx, top)


func _find_player(node: Node) -> Player:
	for c in node.get_children():
		if c is Player:
			return c
	return null
