extends SceneTree
# Spike: one overlapping rectangle per exposed face segment, skin depth D tiles.
const T := 6.0
const D := 4
var W := 60
var H := 40
var g := PackedByteArray()

func solid(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= W or y >= H: return true   # outside the grid counts as solid (no face)
	return g[y * W + x] == 1

func fill(x0: int, y0: int, w: int, h: int) -> void:
	for x in range(x0, x0 + w):
		for y in range(y0, y0 + h): g[y * W + x] = 1

# sides: 0 top(-y) 1 bottom(+y) 2 left(-x) 3 right(+x)
func faces() -> Array:
	var out := []
	var dirs := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for side in 4:
		var d: Vector2i = dirs[side]
		var horizontal := side < 2
		var lines := H if horizontal else W
		var along := W if horizontal else H
		for line in lines:
			var a := 0
			while a < along:
				var cx := a if horizontal else line
				var cy := line if horizontal else a
				if solid(cx, cy) and not solid(cx + d.x, cy + d.y) and cx >= 0 and cy >= 0 and cx < W and cy < H and g[cy * W + cx] == 1:
					var a0 := a
					while a < along:
						var x := a if horizontal else line
						var y := line if horizontal else a
						if not (g[y * W + x] == 1 and not solid(x + d.x, y + d.y)): break
						a += 1
					out.append([side, line, a0, a - 1])
				else:
					a += 1
	return out

func strip(f: Array) -> Rect2i:
	var side: int = f[0]; var line: int = f[1]; var a0: int = f[2]; var a1: int = f[3]
	var depth := D
	for a in range(a0, a1 + 1):
		var n := 0
		var x := (a if side < 2 else line); var y := (line if side < 2 else a)
		var steps: Array[Vector2i] = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
		var step: Vector2i = steps[side]
		while n < depth and x >= 0 and y >= 0 and x < W and y < H and g[y * W + x] == 1:
			n += 1; x += step.x; y += step.y
		depth = n
	match side:
		0: return Rect2i(a0, line, a1 - a0 + 1, depth)
		1: return Rect2i(a0, line - depth + 1, a1 - a0 + 1, depth)
		2: return Rect2i(line, a0, depth, a1 - a0 + 1)
		_: return Rect2i(line - depth + 1, a0, depth, a1 - a0 + 1)

func _initialize() -> void:
	g.resize(W * H)
	fill(0, 30, W, 10)           # floor 10 deep
	fill(10, 18, 12, 12)         # wide block on the floor
	fill(10, 10, 6, 8)           # pillar, flush with the block's left face
	fill(40, 24, 8, 2)           # a thin ledge (2 deep) in the air
	var fs := faces()
	var rects: Array[Rect2i] = []
	for f in fs: rects.append(strip(f))
	print("RESULT segments=%d shapes=%d (T4: shapes <= segments, each segment in one shape)" % [fs.size(), rects.size()])
	var body := StaticBody2D.new()
	for r in rects:
		var s := RectangleShape2D.new(); s.size = Vector2(r.size) * T
		var c := CollisionShape2D.new(); c.shape = s; c.position = (Vector2(r.position) + Vector2(r.size) / 2.0) * T; body.add_child(c)
	root.add_child(body)
	await physics_frame
	# 1) slide down the pillar+block left face (x = 10 tiles = 60 px), rows 10..30 -> y 60..180
	for spd in [60.0, 480.0, 640.0]:
		var cb := _body(Vector2(60 - 5.5, 62))
		var yprev := cb.position.y; var mn := 1e9; var mx := 0.0
		for f in 90:
			cb.velocity = Vector2(60, spd); cb.move_and_slide(); await physics_frame
			if f > 4 and cb.position.y < 170: mn = minf(mn, cb.position.y - yprev); mx = maxf(mx, cb.position.y - yprev)
			yprev = cb.position.y
		print("RESULT left_face_slide@%d step_min=%.3f step_max=%.3f expect=%.3f" % [spd, mn, mx, spd / 60.0])
		cb.queue_free()
	# 2) run across the block top (y=18 tiles -> 108) and the floor at 140 / 370 / dash
	for spd in [140.0, 370.0]:
		var cb := _body(Vector2(100, 107.5))  # on the block top, right of the pillar
		var mn := 1e9; var dy := 0.0; var y0 := NAN
		for f in 14:
			cb.velocity = Vector2(spd, 50); cb.move_and_slide(); await physics_frame
			if f > 3 and cb.position.x < 125: 
				mn = minf(mn, cb.get_real_velocity().x)
				if is_nan(y0): y0 = cb.position.y
				dy = maxf(dy, absf(cb.position.y - y0))
		print("RESULT block_top_run@%d min_vx=%.2f max_dy=%.3f" % [spd, mn, dy])
		cb.queue_free()
	# 3) fall past the pillar/block step and land on the floor, then run along floor under the ledge
	var cb2 := _body(Vector2(150, 100))
	for f in 70:
		cb2.velocity = Vector2(140, cb2.velocity.y + 15); cb2.move_and_slide(); await physics_frame
	print("RESULT fall_and_run on_floor=%s y=%.2f x=%.1f" % [str(cb2.is_on_floor()), cb2.position.y, cb2.position.x])
	quit()

func _body(pos: Vector2) -> CharacterBody2D:
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cs.position = Vector2(0, -11); cb.add_child(cs)
	cb.position = pos; root.add_child(cb)
	return cb
