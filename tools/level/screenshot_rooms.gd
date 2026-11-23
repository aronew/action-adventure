## Loads each Cinderheart room in the real game and saves a screenshot at its start (or
## first exit) to production/qa/evidence/cinderheart/.
## Run (needs a display): xvfb-run -a godot --path . -s res://tools/level/screenshot_rooms.gd
extends SceneTree

const ROOMS := ["c01_waking_niche", "c02_ash_steps", "c03_kiln_hall", "c04_cinder_run",
		"c05_glaze_bridge", "c06_keepers_forge", "c07_bellows_climb", "c08_brun_antechamber", "c09_ember_hoard"]
const ARRIVE := ["", "left", "high_left", "up", "left", "right", "low_left", "left", "left"]


func _initialize() -> void:
	for i in ROOMS.size():
		RegionTravel.reset()
		RegionTravel.arrival_exit = StringName(ARRIVE[i])
		change_scene_to_file("res://src/world/cinderheart/rooms/%s.tscn" % ROOMS[i])
		for f in 90:
			await process_frame
		var image := root.get_texture().get_image()
		image.save_png("res://production/qa/evidence/cinderheart/%s.png" % ROOMS[i])
		var room := current_scene as RegionRoom
		print("%s player at %s state %d" % [ROOMS[i], room.player.global_position, room.player.state])
	quit()
