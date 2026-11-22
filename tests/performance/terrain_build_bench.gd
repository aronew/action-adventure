## Performance test for building a room's terrain end to end from a painted TileMapLayer
## (ADR-0001 validation): read the layer, find the faces, make the strips and the bodies.
## A 10-screen room (800 x 45 tiles) in a typical layout and in a worst case (a
## checkerboard of solid cells, which makes a face segment per cell). The threshold is the
## whole 0.10 s room build budget (rooms and transitions R3) for terrain alone; the ADR's
## aim is 20 ms for the typical room on the owner's machine, recorded in the output.
## Run: godot --headless --path . -s res://tests/performance/terrain_build_bench.gd
extends MiniTest

const WIDTH := 800
const HEIGHT := 45
const BUDGET_MS := 100.0
const TYPICAL_AIM_MS := 20.0


func _tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(6, 6)   # no physics layer (ADR-0001)
	var source := TileSetAtlasSource.new()
	var image := Image.create(12, 6, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(6, 6)
	source.create_tile(TerrainGrid.ATLAS_SOLID)
	source.create_tile(TerrainGrid.ATLAS_ONE_WAY)
	tile_set.add_source(source, 0)
	return tile_set


func _layer(checkerboard: bool) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = _tileset()
	layer.collision_enabled = false
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for x in WIDTH:
		for y in HEIGHT:
			var solid := y < 3 or y >= HEIGHT - 6 or x < 3 or x >= WIDTH - 3
			if checkerboard:
				solid = solid or (x + y) % 2 == 0
			layer.set_cell(Vector2i(x, y), 0, TerrainGrid.ATLAS_SOLID) if solid else null
	if not checkerboard:
		for i in 60:
			var lx := rng.randi_range(10, WIDTH - 30)
			var ly := rng.randi_range(8, HEIGHT - 12)
			var ledge_width := rng.randi_range(3, 20)
			var ledge_height := rng.randi_range(1, 4)
			for x in range(lx, lx + ledge_width):
				for y in range(ly, ly + ledge_height):
					layer.set_cell(Vector2i(x, y), 0, TerrainGrid.ATLAS_SOLID)
	return layer


func _measure(layer: TileMapLayer, label: String) -> float:
	var start := Time.get_ticks_usec()
	var grid := TerrainGrid.from_layer(layer)
	var read := Time.get_ticks_usec()
	var strips := TerrainBuilder.strips(grid)
	var found := Time.get_ticks_usec()
	var bodies := TerrainBuilder.build(grid)
	var done := Time.get_ticks_usec()
	var ms := (done - start) / 1000.0 - (found - read) / 1000.0   # strips() above only times the face pass
	var shapes := 0
	for body in bodies:
		shapes += body.get_child_count()
		body.free()
	print("  %s: %.1f ms (read the layer %.1f, faces and strips %.1f, bodies %.1f) for %d cells, %d shapes" % [
			label, ms, (read - start) / 1000.0, (found - read) / 1000.0, (done - found) / 1000.0,
			layer.get_used_cells().size(), shapes])
	return ms


func test_a_typical_ten_screen_room_builds_within_the_budget() -> void:
	var layer := _layer(false)
	var ms := _measure(layer, "typical")
	assert_true(ms < BUDGET_MS, "typical room builds in %.1f ms, over the %.0f ms budget" % [ms, BUDGET_MS])
	print("  aim %.0f ms: %s" % [TYPICAL_AIM_MS, "met" if ms <= TYPICAL_AIM_MS else "NOT met here (software container; owner's machine decides)"])
	layer.free()


func test_a_checkerboard_ten_screen_room_is_recorded() -> void:
	var layer := _layer(true)
	var ms := _measure(layer, "checkerboard worst case")
	assert_true(ms < 10.0 * BUDGET_MS, "worst case builds in %.1f ms, over ten times the budget" % ms)
	layer.free()
