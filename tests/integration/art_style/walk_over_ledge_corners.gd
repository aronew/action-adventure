extends SceneTree
## Walks the Seeker across ledge corners both ways and logs where he gets to: a stop
## short of the edge means an invisible step caught him.

const RUNS := [[Vector2(470, 285), &"move_right"], [Vector2(1220, 140), &"move_left"],
	[Vector2(840, 140), &"move_right"], [Vector2(1020, 250), &"move_left"]]
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
		return false
	var step := _frame % 150
	var run: Array = RUNS[_run]
	if step == 5:
		_player.global_position = run[0]
		_player.velocity = Vector2.ZERO
	if step == 30:
		Input.action_press(run[1])
	if step > 30 and step % 10 == 0:
		print("run ", _run, " f", step, " x=", snappedf(_player.global_position.x, 0.1), " y=", snappedf(_player.global_position.y, 0.1), " ", Player.State.keys()[_player.state], " vx=", snappedf(_player.velocity.x, 1))
	if step == 149:
		Input.action_release(run[1])
		_run += 1
		if _run >= RUNS.size():
			return true
	return false

func _process(_d: float) -> bool:
	return _run >= RUNS.size()
