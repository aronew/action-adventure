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
	W = 800; H = 45
	g.resize(W * H)
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	fill(0, H - 6, W, 6); fill(0, 0, W, 3); fill(0, 0, 3, H); fill(W - 3, 0, 3, H)
	for i in 60:
		fill(rng.randi_range(10, W - 30), rng.randi_range(8, H - 12), rng.randi_range(3, 20), rng.randi_range(1, 4))
	var t0 := Time.get_ticks_usec()
	var fs := faces()
	var t1 := Time.get_ticks_usec()
	var rects: Array[Rect2i] = []
	for f in fs: rects.append(strip(f))
	var t2 := Time.get_ticks_usec()
	var body := StaticBody2D.new()
	for r in rects:
		var s := RectangleShape2D.new(); s.size = Vector2(r.size) * T
		var c := CollisionShape2D.new(); c.shape = s; c.position = (Vector2(r.position) + Vector2(r.size) / 2.0) * T; body.add_child(c)
	root.add_child(body)
	await physics_frame
	var t3 := Time.get_ticks_usec()
	print("RESULT cost 800x45 segments=%d shapes=%d faces_ms=%.1f strips_ms=%.1f shapes_ms=%.1f" % [fs.size(), rects.size(), (t1 - t0) / 1000.0, (t2 - t1) / 1000.0, (t3 - t2) / 1000.0])
	quit()

func _body(pos: Vector2) -> CharacterBody2D:
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cs.position = Vector2(0, -11); cb.add_child(cs)
	cb.position = pos; root.add_child(cb)
	return cb
