extends SceneTree
## Slides the Seeker down wall faces from just under a ledge corner, holding into the
## wall (ledge grab off), and logs his height: stopping short of the floor means a lip
## in the wall face caught him.

const RUNS := [[Vector2(1110, 162), &"move_right", 259.0], [Vector2(1110, 172), &"move_right", 259.0]]
var _frame := 0
var _run := 0
var _room: Node
var _player: Player

func _initialize() -> void:
	var scene: PackedScene = load("res://src/test_rooms/art_style_test_room.tscn")
	_room = scene.instantiate()
	root.add_child(_room)

func _physics_process(_delta: float) -> bool:
	_frame += 1
	if _player == null:
		for child in _room.get_children():
			if child is Player:
				_player = child
				_player.config.ledge_grab_enabled = false
		return false
	var step := _frame % 120
	var run: Array = RUNS[_run]
	if step == 5:
		_player.global_position = run[0]
		_player.velocity = Vector2.ZERO
		_player._set_state(Player.State.AIR)
		Input.action_press(run[1])
	if step > 5 and step % 8 == 0:
		print("run ", _run, " f", step, " y=", snappedf(_player.global_position.y, 0.1), " x=", snappedf(_player.global_position.x, 0.01), " ", Player.State.keys()[_player.state])
	if step == 119:
		Input.action_release(run[1])
		print("run ", _run, " END y=", snappedf(_player.global_position.y, 0.1), " expected floor ~", run[2])
		_run += 1
		if _run >= RUNS.size():
			return true
	return false

func _process(_d: float) -> bool:
	return _run >= RUNS.size()
