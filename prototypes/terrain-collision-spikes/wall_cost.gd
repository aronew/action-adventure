extends SceneTree
const TILE := 6.0

func _initialize() -> void:
	# 1. Wall seams: slide down a wall made of per-tile shapes vs one shape; and a ceiling dash.
	for variant in ["merged", "per_tile"]:
		print("RESULT wall_slide_", variant, " ", await _wall(variant, 60.0), " | fall480 ", await _wall(variant, 480.0))
		print("RESULT ceiling_", variant, " ", await _ceiling(variant, 370.0))
	# 2. Cost: a 10-screen room (800 x 45 tiles).
	await _cost()
	quit()

func _wall_body(variant: String, tiles_high: int) -> StaticBody2D:
	var body := StaticBody2D.new()
	if variant == "merged":
		var s := RectangleShape2D.new(); s.size = Vector2(TILE * 4, tiles_high * TILE)
		var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(TILE * 2, tiles_high * TILE / 2.0); body.add_child(c)
	else:
		for j in tiles_high:
			for i in 4:
				var s := RectangleShape2D.new(); s.size = Vector2(TILE, TILE)
				var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(i * TILE + 3, j * TILE + 3); body.add_child(c)
	return body

func _wall(variant: String, fall_speed: float) -> String:
	var world := Node2D.new(); root.add_child(world)
	world.add_child(_wall_body(variant, 120))
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cb.add_child(cs)
	cb.position = Vector2(-5.5, 30)
	world.add_child(cb)
	await physics_frame
	var y_prev := cb.position.y
	var min_step := 1e9
	var max_step := 0.0
	var steps := 0
	for f in 120:
		cb.velocity = Vector2(60, fall_speed)   # pressing into the wall while falling
		cb.move_and_slide()
		await physics_frame
		if f > 5:
			var d := cb.position.y - y_prev
			min_step = minf(min_step, d); max_step = maxf(max_step, d); steps += 1
		y_prev = cb.position.y
	var expect := fall_speed / 60.0
	world.queue_free(); await physics_frame
	return "step_min=%.3f step_max=%.3f expect=%.3f" % [min_step, max_step, expect]

func _ceiling(variant: String, speed: float) -> String:
	var world := Node2D.new(); root.add_child(world)
	var body := StaticBody2D.new(); world.add_child(body)
	if variant == "merged":
		var s := RectangleShape2D.new(); s.size = Vector2(960, TILE)
		var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(480, -TILE / 2.0); body.add_child(c)
	else:
		for i in 160:
			var s := RectangleShape2D.new(); s.size = Vector2(TILE, TILE)
			var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(i * TILE + 3, -3); body.add_child(c)
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cs.position = Vector2(0, 11); cb.add_child(cs)
	cb.position = Vector2(10, 0.5)
	world.add_child(cb)
	await physics_frame
	var min_vx := 1e9; var max_dy := 0.0; var y0 := NAN
	for f in 120:
		cb.velocity = Vector2(speed, -50)  # pressed up into the ceiling
		cb.move_and_slide()
		await physics_frame
		if f > 10 and cb.position.x < 900:
			min_vx = minf(min_vx, cb.get_real_velocity().x)
			if is_nan(y0): y0 = cb.position.y
			max_dy = maxf(max_dy, absf(cb.position.y - y0))
	world.queue_free(); await physics_frame
	return "min_real_vx=%.2f max_dy=%.3f" % [min_vx, max_dy]

func _tileset() -> TileSet:
	var ts := TileSet.new(); ts.tile_size = Vector2i(6, 6); ts.add_physics_layer()
	var src := TileSetAtlasSource.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8); img.fill(Color.BLACK)
	src.texture = ImageTexture.create_from_image(img); src.texture_region_size = Vector2i(6, 6)
	src.create_tile(Vector2i(0, 0)); ts.add_source(src, 0)
	var d := src.get_tile_data(Vector2i(0, 0), 0)
	d.add_collision_polygon(0)
	d.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-3,-3), Vector2(3,-3), Vector2(3,3), Vector2(-3,3)]))
	return ts

func _cost() -> void:
	var w := 800; var h := 45
	# a) every solid tile of a room with 3-tile walls and floor: edge-heavy; here fill 50% as a pessimistic solid mass
	var ts := _tileset()
	var t0 := Time.get_ticks_usec()
	var layer := TileMapLayer.new(); layer.tile_set = ts
	var count := 0
	for x in w:
		for y in h:
			if y >= h - 6 or x < 3 or x >= w - 3 or y < 3:
				layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0)); count += 1
	root.add_child(layer)
	await physics_frame
	var t1 := Time.get_ticks_usec()
	print("RESULT cost_tilemap_all_solid_tiles cells=%d build_ms=%.1f" % [count, (t1 - t0) / 1000.0])
	# per-frame physics step with a body moving
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cb.add_child(cs); cb.position = Vector2(60, 200); root.add_child(cb)
	var tt0 := Time.get_ticks_usec()
	for f in 120:
		cb.velocity = Vector2(140, 100); cb.move_and_slide(); await physics_frame
	print("RESULT cost_tilemap_frame_ms=%.2f" % [((Time.get_ticks_usec() - tt0) / 1000.0) / 120.0])
	layer.queue_free(); cb.queue_free(); await physics_frame
	# b) merged: one body, one rect per face segment (floor, ceiling, two walls)
	var t2 := Time.get_ticks_usec()
	var body := StaticBody2D.new()
	for r in [Rect2(0, (h - 6) * TILE, w * TILE, 6 * TILE), Rect2(0, 0, w * TILE, 3 * TILE), Rect2(0, 0, 3 * TILE, h * TILE), Rect2((w - 3) * TILE, 0, 3 * TILE, h * TILE)]:
		var s := RectangleShape2D.new(); s.size = r.size
		var c := CollisionShape2D.new(); c.shape = s; c.position = r.position + r.size / 2.0; body.add_child(c)
	root.add_child(body); await physics_frame
	print("RESULT cost_merged_shapes=4 build_ms=%.2f" % [(Time.get_ticks_usec() - t2) / 1000.0])
