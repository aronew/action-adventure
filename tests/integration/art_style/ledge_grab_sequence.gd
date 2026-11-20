extends SceneTree
## Drops the Seeker beside the high ledge's wall holding right, checks he catches the
## ledge, hangs, pulls up on jump and ends standing on top; saves frames along the way.

var _frame := 0
var _room: Node
var _player: Player
var _shots := {12: "a-falling", 40: "b-grab", 70: "c-hang", 92: "d-pull-early", 104: "e-pull-mid", 118: "f-pull-late", 150: "g-standing"}

func _initialize() -> void:
	var scene: PackedScene = load("res://src/test_rooms/art_style_test_room.tscn")
	_room = scene.instantiate()
	root.add_child(_room)

func _process(_delta: float) -> bool:
	_frame += 1
	if _player == null:
		for child in _room.get_children():
			if child is Player:
				_player = child
		return false
	if _frame == 3:
		_room._mood.set_enabled(false)
		_player.global_position = Vector2(1100, 150)
		_player.velocity = Vector2.ZERO
		_player.reset_physics_interpolation()
		Input.action_press(&"move_right")
	if _frame == 30:
		Input.action_release(&"move_right")
	if _frame == 75:
		Input.action_press(&"jump")
	if _frame == 78:
		Input.action_release(&"jump")
	if _frame % 6 == 0 or _shots.has(_frame):
		print(_frame, " state=", Player.State.keys()[_player.state], " pos=", _player.global_position, " anim=", _player._sprite.animation, ":", _player._sprite.frame)
	if _shots.has(_frame):
		root.get_viewport().get_texture().get_image().save_png("res://shots/ledge-%s.png" % _shots[_frame])
	return _frame >= 160
