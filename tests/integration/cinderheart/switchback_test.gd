## Integration test: a switchback turn in Bellows Climb is climbable with real jumps (the
## layout checker's model is only a model). The turn at the right end of the bottom level:
## floor -> the 2-cell step -> the ledge -> the next level up. Real room, real physics.
## Run: godot --headless --path . -s res://tests/integration/cinderheart/switchback_test.gd
extends MiniTest

const ROOM := "res://src/world/cinderheart/rooms/c07_bellows_climb.tscn"
const CELL := 36.0
## Walkable surface of a floor whose top cell is row r: r * CELL + this.
const FLOOR_OFFSET := 7.5


func _room() -> RegionRoom:
	RegionTravel.reset()
	change_scene_to_file(ROOM)
	for i in 30:
		await physics_frame
	var room := current_scene as RegionRoom
	for enemy in room.find_children("*", "EnemyBase", true, false):
		enemy.queue_free()
	return room


## Jumps toward [param direction] (holding it until landed) and returns the landing spot.
func _hop(player: Player, direction: StringName) -> Vector2:
	Input.action_press(direction)
	Input.action_press(&"jump")
	for i in 18:
		await physics_frame
	Input.action_release(&"jump")
	for i in 120:
		await physics_frame
		if i > 6 and player.is_on_floor():
			break
	Input.action_release(direction)
	for i in 10:
		await physics_frame
	return player.global_position


func test_turn_climbs_floor_step_ledge_next_level() -> void:
	var room: RegionRoom = await _room()
	var player := room.player
	player.global_position = Vector2(22.5 * CELL, 36 * CELL - 2)
	for i in 20:
		await physics_frame
	var a: Vector2 = await _hop(player, &"move_right")
	assert_near(a.y, 34 * CELL + FLOOR_OFFSET, 3.0, "on the step (x %.0f)" % a.x)
	var b: Vector2 = await _hop(player, &"move_left")
	assert_near(b.y, 32 * CELL + FLOOR_OFFSET, 3.0, "on the ledge (x %.0f)" % b.x)
	var c: Vector2 = await _hop(player, &"move_left")
	assert_near(c.y, 31 * CELL + FLOOR_OFFSET, 3.0, "on the next level (x %.0f)" % c.x)
