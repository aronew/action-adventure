extends SceneTree
func _initialize() -> void:
	var cam := Camera2D.new(); cam.zoom = Vector2(4, 4); root.add_child(cam)
	var sizes := [Vector2i(1920, 1080), Vector2i(1440, 810), Vector2i(960, 540), Vector2i(1366, 768), Vector2i(2560, 1440), Vector2i(1280, 800)]
	for s in sizes:
		get_root().size = s
		for i in 4: await process_frame
		var vp := get_root()
		var t := vp.get_final_transform() * vp.get_canvas_transform()
		print("RESULT win=", s, " csf=", vp.content_scale_factor, " visible=", vp.get_visible_rect().size, " total_scale=", t.get_scale(), " world_px_across=", Vector2(s) / t.get_scale())
	quit()
