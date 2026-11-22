## Unit tests for TerrainBuilder and Terrain.face_materials (ADR-0001, terrain pipeline
## T4, rules 2-6). Pure: grids come from text rows ('#' solid, '-' one-way, '.' empty).
## Run: godot --headless --path . -s res://tests/unit/terrain/terrain_builder_test.gd
extends MiniTest

const SIDE_TOP := TerrainBuilder.Side.TOP
const SIDE_LEFT := TerrainBuilder.Side.LEFT
const SIDE_RIGHT := TerrainBuilder.Side.RIGHT


## The GDD's one-screen room: 80 x 45 tiles, a 6-tile floor, walls and ceiling around a
## 68 x 33 open space.
func _one_screen_room() -> TerrainGrid:
	var rows := PackedStringArray()
	for y in 45:
		if y < 6 or y >= 39:
			rows.append("#".repeat(80))
		else:
			rows.append("#".repeat(6) + ".".repeat(68) + "#".repeat(6))
	return TerrainGrid.from_rows(rows)


func _edge_tiles(grid: TerrainGrid) -> int:
	var count := 0
	for y in grid.height:
		for x in grid.width:
			if grid.kind_at(x, y) != TerrainGrid.SOLID:
				continue
			for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
				if grid.kind_at(x + d.x, y + d.y) == TerrainGrid.EMPTY:
					count += 1
					break
	return count


func test_one_screen_room_gives_four_shapes_and_202_edge_tiles() -> void:
	var grid := _one_screen_room()
	var faces := TerrainBuilder.faces(grid)
	assert_eq(_edge_tiles(grid), 202, "edge tiles")
	assert_eq(faces.size(), 4, "face segments")
	assert_eq(TerrainBuilder.strips(grid).size(), 4, "shapes")


func test_pillar_flush_on_wider_block_keeps_one_shape_per_segment() -> void:
	# The case a merged partition splits: the left face of pillar and block is one segment.
	var grid := TerrainGrid.from_rows(PackedStringArray([
		"..........",
		".##.......",
		".##.......",
		".#####....",
		".#####....",
		"##########",
		"##########"]))
	var faces := TerrainBuilder.faces(grid)
	var strips := TerrainBuilder.strips(grid)
	assert_eq(strips.size(), faces.size(), "shapes equal segments")
	var left_faces := faces.filter(func(f: TerrainBuilder.Face) -> bool: return f.side == SIDE_LEFT and f.line == 1)
	assert_eq(left_faces.size(), 1, "the flush left face is one segment")
	assert_eq(left_faces[0].length(), 4, "and four cells long")
	# Every face lies inside the shape made for it.
	for face in faces:
		var rect := TerrainBuilder.strip(grid, face)
		var cells_inside := true
		for a in range(face.start, face.end + 1):
			var cell := Vector2i(a, face.line) if face.side < 2 else Vector2i(face.line, a)
			cells_inside = cells_inside and rect.has_point(cell)
		assert_true(cells_inside, "face side %d line %d fits its strip" % [face.side, face.line])


func test_strip_depth_is_capped_and_follows_thin_masses() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray([
		"..........",
		".#####....",
		".#####....",
		"..........",
		"..........",
		"##########",
		"##########",
		"##########",
		"##########",
		"##########",
		"##########"]))
	var strips := TerrainBuilder.strips(grid)
	var thin_top := strips.filter(func(r: Rect2i) -> bool: return r.position == Vector2i(1, 1) and r.size.x == 5)
	# A two-deep ledge's top and bottom strips are the same rectangle: each runs the whole mass.
	assert_eq(thin_top.size(), 2, "the thin ledge's top and bottom strips")
	assert_eq(thin_top[0].size.y, 2, "are its own two cells deep")
	var floor_top := strips.filter(func(r: Rect2i) -> bool: return r.position == Vector2i(0, 5) and r.size.x == 10)
	assert_eq(floor_top.size(), 1, "the floor's top strip")
	assert_eq(floor_top[0].size.y, TerrainBuilder.SKIN_TILES, "is capped at the skin depth")


func test_one_way_faces_only_where_the_cell_above_is_empty() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray([
		"......",
		"-.-.#.",
		"-.#.--",
		"-.#.#-",
		"-#.#..",
		"######"]))
	var faces := TerrainBuilder.faces(grid)
	var one_way_tops := faces.filter(func(f: TerrainBuilder.Face) -> bool: return f.kind == TerrainGrid.ONE_WAY)
	# col 0, a stack of four: only the top has a face. col 2, a one-way over a solid: a face
	# (its underside is flush with the solid). col 4, one-ways under a solid: none. col 5,
	# a one-way with a one-way below it: only the upper has a face.
	var lines := []
	for f in one_way_tops:
		lines.append(Vector3i(f.line, f.start, f.end))
	lines.sort()
	assert_eq(lines.size(), 3, "three one-way segments")
	assert_true(lines.has(Vector3i(1, 0, 0)), "the top of the stack of four")
	assert_true(lines.has(Vector3i(1, 2, 2)), "the one-way over solid")
	assert_true(lines.has(Vector3i(2, 5, 5)), "the upper of two stacked one-ways")
	for f in one_way_tops:
		assert_eq(f.side, SIDE_TOP, "a one-way cell has only a top face")


func test_solid_sides_against_one_way_cells_are_exposed() -> void:
	# A one-way cell has no side collision, so the solid beside it keeps its face.
	var grid := TerrainGrid.from_rows(PackedStringArray([
		"...",
		"#-.",
		"###"]))
	var faces := TerrainBuilder.faces(grid)
	var right := faces.filter(func(f: TerrainBuilder.Face) -> bool: return f.side == SIDE_RIGHT and f.kind == TerrainGrid.SOLID and f.line == 0)
	assert_eq(right.size(), 1, "the solid's right face beside the one-way cell")


func test_cells_outside_the_grid_count_as_solid() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray(["###", "###"]))
	assert_eq(TerrainBuilder.faces(grid).size(), 0, "a fully solid grid has no faces")
	var edge := TerrainGrid.from_rows(PackedStringArray(["#.", "##"]))
	var sides := TerrainBuilder.faces(edge).map(func(f: TerrainBuilder.Face) -> int: return f.side)
	assert_true(not sides.has(SIDE_LEFT), "no face on the grid's left edge")


func test_a_material_change_splits_a_face_into_segments() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray(["........", "########"]))
	var data := RoomTerrainData.new()
	for x in range(3, 5):
		data.set_face_material(Vector2i(x, 1), SIDE_TOP, RoomTerrainData.NO_CLING)
	var tops := TerrainBuilder.faces(grid, data).filter(func(f: TerrainBuilder.Face) -> bool: return f.side == SIDE_TOP)
	assert_eq(tops.size(), 3, "three top segments")
	assert_eq(tops[1].material, RoomTerrainData.NO_CLING, "the middle one is no_cling")
	assert_eq(tops[1].length(), 2, "two cells long")
	assert_eq(TerrainBuilder.strips(grid, data).size() > TerrainBuilder.strips(grid).size(), true, "and gets its own shape")


func test_build_is_deterministic() -> void:
	var grid := _one_screen_room()
	var first := TerrainBuilder.strips(grid)
	var second := TerrainBuilder.strips(grid)
	assert_eq(first, second, "same grid, same strips in the same order")


func test_build_makes_a_solid_body_and_a_one_way_body_on_the_world_layer() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray(["......", "..--..", "......", "######"]))
	var bodies := TerrainBuilder.build(grid)
	assert_eq(bodies.size(), 2, "a solid body and a one-way body")
	assert_eq(bodies[0].name, &"TerrainSolid", "the solid body first")
	assert_eq(bodies[1].name, &"TerrainOneWay", "then the one-way body")
	for body in bodies:
		assert_eq(body.collision_layer, 1, "world layer")
		assert_eq(body.collision_mask, 0, "static bodies collide with nothing themselves")
	var shape_node := bodies[1].get_child(0) as CollisionShape2D
	assert_true(shape_node.one_way_collision, "one-way strips are one-way")
	assert_eq(shape_node.position, Vector2(18, 9), "in px: cells 2 to 3 of row 1")
	for body in bodies:
		body.free()
	var no_one_way := TerrainBuilder.build(TerrainGrid.from_rows(PackedStringArray(["...", "###"])))
	assert_eq(no_one_way.size(), 1, "no one-way body without one-way tiles")
	no_one_way[0].free()


func test_face_materials_reads_the_span_the_body_overlaps() -> void:
	# A 3-wide wall, 10 rows tall; its right face is no_cling on rows 5-9, plain above.
	var rows := PackedStringArray()
	for y in 10:
		rows.append("###.....")
	var grid := TerrainGrid.from_rows(rows)
	var data := RoomTerrainData.new()
	for y in range(5, 10):
		data.set_face_material(Vector2i(2, y), SIDE_RIGHT, RoomTerrainData.NO_CLING)
	var terrain := Terrain.new()
	root.add_child(terrain)
	terrain.build(grid, data)
	# The Seeker's 10 x 22 body against the wall's right face (x = 18): y 14 to 36 covers rows 2 to 5.
	var span := terrain.face_materials(Rect2(18, 14, 10, 22), Vector2.RIGHT)
	assert_eq(Array(span), ["plain", "plain", "plain", "no_cling"], "materials along the face, top to bottom")
	var lower := terrain.face_materials(Rect2(18, 36, 10, 22), Vector2.RIGHT)
	assert_eq(Array(lower), ["no_cling", "no_cling", "no_cling", "no_cling"], "rows 6 to 9 are all no_cling")
	assert_eq(terrain.face_materials(Rect2(60, 8, 10, 22), Vector2.RIGHT).size(), 0, "no face away from the wall")
	assert_eq(terrain.face_materials(Rect2(18, 8, 10, 22), Vector2.UP).size(), 0, "no top face under the body here")
	terrain.free()


func test_face_materials_reads_a_floor_and_is_terrain_collider_checks_the_body() -> void:
	var grid := TerrainGrid.from_rows(PackedStringArray(["........", "########"]))
	var terrain := Terrain.new()
	root.add_child(terrain)
	terrain.build(grid)
	var standing := Rect2(10, 6 - 22, 10, 22)   # feet on the floor's top at y = 6
	assert_eq(Array(terrain.face_materials(standing, Vector2.UP)), ["plain", "plain", "plain"], "three floor cells under a 10 px body at x 10")
	var other := StaticBody2D.new()
	assert_true(terrain.is_terrain_collider(terrain.get_child(0)), "its own body")
	assert_true(not terrain.is_terrain_collider(other), "another body is not terrain")
	other.free()
	terrain.free()
