## Saves a zoomed-out picture of each whole region room (mood pass off) to
## production/qa/evidence/<biome>/overview-<room>.png.
## Run (needs a display): xvfb-run -a godot --path . -s res://tools/level/overview_rooms.gd
## Only some rooms: add -- and parts of their names (e.g. -- hm01 c07).
extends SceneTree

const CINDERHEART := "res://src/world/cinderheart/rooms/%s.tscn"
## [scene, evidence folder]
const ROOMS := [
	[CINDERHEART % "c01_waking_niche", "cinderheart"], [CINDERHEART % "c02_ash_steps", "cinderheart"],
	[CINDERHEART % "c03_kiln_hall", "cinderheart"], [CINDERHEART % "c04_cinder_run", "cinderheart"],
	[CINDERHEART % "c05_glaze_bridge", "cinderheart"], [CINDERHEART % "c06_keepers_forge", "cinderheart"],
	[CINDERHEART % "c07_bellows_climb", "cinderheart"], [CINDERHEART % "c08_brun_antechamber", "cinderheart"],
	[CINDERHEART % "c09_ember_hoard", "cinderheart"],
	["res://src/world/hollow_molt/rooms/hm01_molt_test.tscn", "hollow-molt"],
]


func _initialize() -> void:
	RegionRoom.mood_on = false
	var only := Array(OS.get_cmdline_user_args())
	for entry in ROOMS:
		var key: String = (entry[0] as String).get_file().get_basename()
		if not only.is_empty() and not only.any(func(part: String) -> bool: return key.contains(part)):
			continue
		RegionTravel.reset()
		change_scene_to_file(entry[0])
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
		root.get_texture().get_image().save_png("res://production/qa/evidence/%s/overview-%s.png" % [entry[1], key])
		print("overview ", key)
	quit()
