extends SceneTree
# Spike: does a 10x22 CharacterBody2D catch on seams between 6 px collision tiles?
const TILE := 6.0
const N := 160

func _initialize() -> void:
	var results := {}
	for variant in ["merged_rect", "per_tile_rects", "tilemap_layer", "per_tile_polygons", "segment_top"]:
		for speed in [140.0, 370.0]:
			results["%s@%d" % [variant, speed]] = await _run(variant, speed)
	for k in results:
		print("RESULT ", k, " ", results[k])
	quit()

func _floor(variant: String) -> Node2D:
	var root := Node2D.new()
	var body := StaticBody2D.new()
	root.add_child(body)
	match variant:
		"merged_rect":
			var s := RectangleShape2D.new(); s.size = Vector2(N * TILE, TILE)
			var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(N * TILE / 2.0, TILE / 2.0); body.add_child(c)
		"per_tile_rects":
			for i in N:
				var s := RectangleShape2D.new(); s.size = Vector2(TILE, TILE)
				var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(i * TILE + TILE / 2.0, TILE / 2.0); body.add_child(c)
		"per_tile_polygons":
			for i in N:
				var s := ConvexPolygonShape2D.new(); s.points = PackedVector2Array([Vector2(0,0), Vector2(TILE,0), Vector2(TILE,TILE), Vector2(0,TILE)])
				var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(i * TILE, 0); body.add_child(c)
		"segment_top":
			var s := SegmentShape2D.new(); s.a = Vector2(0, 0); s.b = Vector2(N * TILE, 0)
			var c := CollisionShape2D.new(); c.shape = s; body.add_child(c)
		"tilemap_layer":
			var ts := TileSet.new()
			ts.tile_size = Vector2i(6, 6)
			ts.add_physics_layer()
			var src := TileSetAtlasSource.new()
			var img := Image.create(6, 6, false, Image.FORMAT_RGBA8); img.fill(Color.BLACK)
			src.texture = ImageTexture.create_from_image(img)
			src.texture_region_size = Vector2i(6, 6)
			src.create_tile(Vector2i(0, 0))
			ts.add_source(src, 0)
			var data := src.get_tile_data(Vector2i(0, 0), 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-3,-3), Vector2(3,-3), Vector2(3,3), Vector2(-3,3)]))
			var layer := TileMapLayer.new()
			layer.tile_set = ts
			for i in N:
				layer.set_cell(Vector2i(i, 0), 0, Vector2i(0, 0))
			root.add_child(layer)
	return root

func _run(variant: String, speed: float) -> String:
	var world := _floor(variant)
	root.add_child(world)
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cs.position = Vector2(0, -11)
	cb.add_child(cs)
	cb.position = Vector2(10, -0.5)
	world.add_child(cb)
	await physics_frame
	await physics_frame
	var min_vx := 1e9
	var max_dy := 0.0
	var y0 := NAN
	var frames := 0
	for f in 130:
		cb.velocity.x = speed
		cb.velocity.y += 900.0 / 60.0
		cb.move_and_slide()
		await physics_frame
		if f > 10 and cb.position.x < N * TILE - 40:
			frames += 1
			min_vx = minf(min_vx, cb.get_real_velocity().x)
			if is_nan(y0): y0 = cb.position.y
			max_dy = maxf(max_dy, absf(cb.position.y - y0))
	var shape_count := 0
	for ch in world.get_children():
		if ch is StaticBody2D: shape_count += ch.get_child_count()
		if ch is TileMapLayer: shape_count = N
	var out := "frames=%d min_real_vx=%.2f max_dy=%.3f floor=%s x_end=%.1f" % [frames, min_vx, max_dy, str(cb.is_on_floor()), cb.position.x]
	world.queue_free()
	await physics_frame
	return out
