## Integration test: a secret room stays hidden under painted rock until the Seeker steps
## into it, then the cover fades and stays off for the run (Waking Niche's nook behind the
## fake wall off the cavern's high ledge). Real room.
## Run: godot --headless --path . -s res://tests/integration/cinderheart/secret_cover_test.gd
extends MiniTest

const ROOM := "res://src/world/cinderheart/rooms/c01_waking_niche.tscn"
const CELL := 36.0


func _room() -> RegionRoom:
	change_scene_to_file(ROOM)
	for i in 30:
		await physics_frame
	return current_scene as RegionRoom


func test_secret_is_covered_until_entered_then_stays_found() -> void:
	RegionTravel.reset()
	var room: RegionRoom = await _room()
	assert_true(room._cover != null and room._cover.modulate.a > 0.99, "covered before it is found")
	assert_true(room._cover.z_index > room.player.z_index, "the cover is drawn over the Seeker")
	# Walk in: stand in the nook behind the fake wall.
	room.player.global_position = Vector2(1.5 * CELL, 20 * CELL - 2)
	for i in 40:
		await physics_frame
	assert_true(room._cover == null, "the cover fades out once the Seeker steps in")
	assert_true(RegionTravel.revealed.has(ROOM), "remembered for the run")
	var again: RegionRoom = await _room()
	assert_true(again._cover == null, "still found when the room is entered again")
