## Saves a zoomed-out picture of each whole Cinderheart room (mood pass off) to
## production/qa/evidence/cinderheart/overview-<room>.png.
## Run (needs a display): xvfb-run -a godot --path . -s res://tools/level/overview_rooms.gd
extends SceneTree

const ROOMS := ["c01_waking_niche", "c02_ash_steps", "c03_kiln_hall", "c04_cinder_run",
		"c05_glaze_bridge", "c06_keepers_forge", "c07_bellows_climb", "c08_brun_antechamber",
		"c09_ember_hoard"]


func _initialize() -> void:
	RegionRoom.mood_on = false
	for key in ROOMS:
		RegionTravel.reset()
		change_scene_to_file("res://src/world/cinderheart/rooms/%s.tscn" % key)
		for f in 20:
			await process_frame
		var room := current_scene as RegionRoom
		var cam := room.player.get_child(room.player.get_child_count() - 1) as Camera2D
		for c in room.player.get_children():
			if c is Camera2D:
				cam = c
		var size := Vector2(room._terrain().room_cells) * PaintedTerrain.CELL
		var view := Vector2(root.get_visible_rect().size)
		cam.set_process(false)
		cam.position_smoothing_enabled = false
		cam.limit_left = -100000
		cam.limit_top = -100000
		cam.limit_right = 100000
		cam.limit_bottom = 100000
		cam.zoom = Vector2.ONE * minf(view.x / size.x, view.y / size.y) * 0.98
		cam.offset = size * 0.5 - room.player.global_position
		room.player.set_physics_process(false)
		for f in 10:
			await process_frame
		root.get_texture().get_image().save_png("res://production/qa/evidence/cinderheart/overview-%s.png" % key)
		print("overview ", key)
	quit()
