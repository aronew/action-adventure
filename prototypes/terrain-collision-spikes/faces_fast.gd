extends SceneTree
# Time an inlined face extraction on a padded grid (800 x 45 tiles).
func _initialize() -> void:
	var W := 800; var H := 45; var S := W + 2
	var P := PackedByteArray(); P.resize((W + 2) * (H + 2)); P.fill(1)   # padding counts as solid
	for y in H:
		for x in W: P[(y + 1) * S + x + 1] = 0
	var rng := RandomNumberGenerator.new(); rng.seed = 7
	var fill := func(x0: int, y0: int, w: int, h: int) -> void:
		for y in range(y0, y0 + h):
			for x in range(x0, x0 + w): P[(y + 1) * S + x + 1] = 1
	fill.call(0, H - 6, W, 6); fill.call(0, 0, W, 3); fill.call(0, 0, 3, H); fill.call(W - 3, 0, 3, H)
	for i in 60:
		fill.call(rng.randi_range(10, W - 30), rng.randi_range(8, H - 12), rng.randi_range(3, 20), rng.randi_range(1, 4))
	var t0 := Time.get_ticks_usec()
	var segs := 0
	var d := [-S, S, -1, 1]        # neighbour offsets: up, down, left, right
	for side in 4:
		var off: int = d[side]
		if side < 2:
			for y in H:
				var base := (y + 1) * S + 1
				var inrun := false
				for x in W:
					var i := base + x
					var face := P[i] == 1 and P[i + off] == 0
					if face and not inrun: segs += 1
					inrun = face
		else:
			for x in W:
				var inrun := false
				for y in H:
					var i := (y + 1) * S + x + 1
					var face := P[i] == 1 and P[i + off] == 0
					if face and not inrun: segs += 1
					inrun = face
	print("RESULT faces_fast ms=%.1f segments=%d" % [(Time.get_ticks_usec() - t0) / 1000.0, segs])
	quit()
