## Integration tests for a built terrain room (ADR-0001): a 10 x 22 CharacterBody2D moves
## along the strips TerrainBuilder makes, at the speeds the GDD's seam criterion lists, and
## the face lookup is read at a real wall contact. Corners, ledge lips and a body spanning
## a material change are NOT covered here (ADR-0001, Open verification items).
## Run: godot --headless --path . -s res://tests/integration/terrain/built_room_test.gd
extends MiniTest

const TILE := 6.0
const STEP := 1.0 / 60.0
const RUN_SPEED := 140.0
const DASH_SPEED := 370.0
const WALL_SLIDE_SPEED := 60.0
const MAX_FALL_SPEED := 480.0
const FAST_FALL_SPEED := 640.0
const BODY_SIZE := Vector2(10, 22)


## 60 x 40 tiles: a 10-deep floor, a block on it with a pillar flush on its left face, a
## ceiling, and walls. The pillar and block's left face (x = 60, y 60 to 180) is one segment.
func _room_rows() -> PackedStringArray:
	var rows := PackedStringArray()
	for y in 40:
		var row := ""
		for x in 60:
			var solid := y < 3 or y >= 30 or x < 3 or x >= 57
			solid = solid or (x >= 10 and x < 22 and y >= 18)          # the block
			solid = solid or (x >= 10 and x < 16 and y >= 10 and y < 18)  # the pillar
			row += "#" if solid else "."
		rows.append(row)
	return PackedStringArray(rows)


func _terrain(rows: PackedStringArray, data: RoomTerrainData = null) -> Terrain:
	var terrain := Terrain.new()
	root.add_child(terrain)
	terrain.build(TerrainGrid.from_rows(rows), data)
	return terrain


func _body(terrain: Terrain, feet: Vector2, hanging := false) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = BODY_SIZE
	var node := CollisionShape2D.new()
	node.shape = shape
	node.position = Vector2(0, 11 if hanging else -11)
	body.add_child(node)
	body.position = feet
	terrain.add_child(body)
	return body


func _rect(body: CharacterBody2D) -> Rect2:
	return Rect2(body.position + Vector2(-5, -22), BODY_SIZE)


func _axis_aligned(body: CharacterBody2D) -> bool:
	for i in body.get_slide_collision_count():
		var n := body.get_slide_collision(i).get_normal()
		if minf(absf(n.x), absf(n.y)) > 0.0001:
			return false
	return true


func _run_along_floor(speed: float) -> void:
	var terrain := _terrain(_room_rows())
	var body := _body(terrain, Vector2(150, 179.5))
	await physics_frame
	var min_vx := 1e9
	var max_dy := 0.0
	var y0 := NAN
	var aligned := true
	var frames := int(150.0 / speed * 60.0)
	for f in frames:
		body.velocity = Vector2(speed, 50)
		body.move_and_slide()
		await physics_frame
		if f > 3:
			min_vx = minf(min_vx, body.get_real_velocity().x)
			if is_nan(y0):
				y0 = body.position.y
			max_dy = maxf(max_dy, absf(body.position.y - y0))
			aligned = aligned and _axis_aligned(body)
	assert_near(min_vx, speed, 0.01, "real velocity along the floor at %d" % int(speed))
	assert_near(max_dy, 0.0, 0.01, "no vertical drift at %d" % int(speed))
	assert_true(aligned, "contact normals are axis-aligned at %d" % int(speed))
	assert_near(body.position.y, 180.0, 0.2, "feet rest on the floor's top line at %d" % int(speed))
	terrain.free()


func test_running_along_a_floor_does_not_catch_at_run_speed() -> void:
	await _run_along_floor(RUN_SPEED)


func test_dashing_along_a_floor_does_not_catch_at_dash_speed() -> void:
	await _run_along_floor(DASH_SPEED)


func _slide_down_long_face(fall_speed: float) -> void:
	var terrain := _terrain(_room_rows())
	var body := _body(terrain, Vector2(60 - 5.5, 62))
	await physics_frame
	var y_prev := body.position.y
	var min_step := 1e9
	var max_step := 0.0
	for f in 90:
		body.velocity = Vector2(60, fall_speed)
		body.move_and_slide()
		await physics_frame
		if f > 4 and body.position.y < 170:
			min_step = minf(min_step, body.position.y - y_prev)
			max_step = maxf(max_step, body.position.y - y_prev)
		y_prev = body.position.y
	var expected := fall_speed * STEP
	assert_near(min_step, expected, 0.01, "slowest step down the flush face at %d" % int(fall_speed))
	assert_near(max_step, expected, 0.01, "fastest step down the flush face at %d" % int(fall_speed))
	terrain.free()


func test_sliding_down_a_long_flush_face_is_exact_at_wall_slide_speed() -> void:
	await _slide_down_long_face(WALL_SLIDE_SPEED)


func test_falling_down_a_long_flush_face_is_exact_at_max_fall_speed() -> void:
	await _slide_down_long_face(MAX_FALL_SPEED)


func test_falling_down_a_long_flush_face_is_exact_at_fast_fall_speed() -> void:
	await _slide_down_long_face(FAST_FALL_SPEED)


func test_dashing_along_a_ceiling_does_not_catch() -> void:
	var terrain := _terrain(_room_rows())
	var body := _body(terrain, Vector2(70, 18.5), true)   # head at the ceiling's underside
	await physics_frame
	var min_vx := 1e9
	var max_dy := 0.0
	var y0 := NAN
	for f in 14:
		body.velocity = Vector2(DASH_SPEED, -50)
		body.move_and_slide()
		await physics_frame
		if f > 3:
			min_vx = minf(min_vx, body.get_real_velocity().x)
			if is_nan(y0):
				y0 = body.position.y
			max_dy = maxf(max_dy, absf(body.position.y - y0))
	assert_near(min_vx, DASH_SPEED, 0.01, "real velocity along the ceiling")
	assert_near(max_dy, 0.0, 0.01, "no vertical drift")
	terrain.free()


func test_the_face_lookup_follows_a_real_wall_contact_down_a_changing_face() -> void:
	# A wall 3 cells thick and 20 tall; its right face is plain above row 10, no_cling below.
	var rows := PackedStringArray()
	for y in 22:
		rows.append("###...........")
	rows[20] = "##############"
	rows[21] = "##############"
	var data := RoomTerrainData.new()
	for y in range(10, 20):
		data.set_face_material(Vector2i(2, y), TerrainBuilder.Side.RIGHT, RoomTerrainData.NO_CLING)
	var terrain := _terrain(rows, data)
	var body := _body(terrain, Vector2(18 + 5.0 + 0.5, 30))   # beside the wall's right face (x = 18)
	await physics_frame
	var checked_high := false
	var checked_low := false
	for f in 120:
		body.velocity = Vector2(-WALL_SLIDE_SPEED, WALL_SLIDE_SPEED)
		body.move_and_slide()
		await physics_frame
		var contact := body.get_last_slide_collision()
		if contact == null or not terrain.is_terrain_collider(contact.get_collider()):
			continue
		var span := terrain.face_materials(_rect(body), contact.get_normal())
		var feet := body.position.y
		if not checked_high and feet >= 36.0 and feet < 40.0:
			assert_eq(Array(span), ["plain", "plain", "plain", "plain"], "rows 3 to 6 at feet y 36 to 40 are plain")
			checked_high = true
		if not checked_low and feet >= 66.0 and feet < 70.0:
			assert_eq(Array(span), ["plain", "plain", "plain", "no_cling"], "rows 7 to 10 at feet y 66 to 70 end in no_cling")
			checked_low = true
		if not checked_low and feet >= 90.0:
			break
	assert_true(checked_high, "the upper contact was read")
	assert_true(checked_low, "the lower contact was read")
	terrain.free()


func test_a_one_way_strip_is_landed_on_from_above_and_passed_from_below() -> void:
	var rows := PackedStringArray()
	for y in 30:
		rows.append("#" + ".".repeat(18) + "#")
	rows[20] = "#" + ".".repeat(6) + "-".repeat(6) + ".".repeat(6) + "#"      # y 120 to 126
	rows[29] = "#".repeat(20)
	var terrain := _terrain(rows)
	var lander := _body(terrain, Vector2(9 * TILE + 3, 60))
	await physics_frame
	for f in 120:
		lander.velocity = Vector2(0, MAX_FALL_SPEED)
		lander.move_and_slide()
		await physics_frame
	assert_near(lander.position.y, 120.0, 0.2, "feet stop on the one-way top")
	lander.free()   # the two bodies would collide with each other
	var riser := _body(terrain, Vector2(9 * TILE + 3, 170))
	await physics_frame
	for f in 30:
		riser.velocity = Vector2(0, -MAX_FALL_SPEED)
		riser.move_and_slide()
		await physics_frame
	assert_true(riser.position.y < 100.0, "a body rising from below passes through")
	terrain.free()
