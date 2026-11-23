## One room of a region, built in the editor and drawn at runtime with the full Cinderheart
## art pipeline (the art-style test room's: far city, ruins, close rock and plant bands, the
## cave's close rear wall, foreground loops, the porous rock rim and wall fill, silhouettes,
## the mood pass).
##
## In the editor: paint rock on the "Layout" TileMapLayer (tile 0,0 rock; tile 1,0 a fake
## wall: drawn, walk-through); [PaintedTerrain] previews it. Place [RoomExit]s at the edges
## and [RoomSpawn] markers for enemies, pickups, gate signs, rest spots and relics.
## [member cave_from_col]: columns from there on get the cave look (close rock wall behind)
## instead of the open cavern (the distant city).
##
## At runtime: the layout becomes the art pipeline's grid (floating rock one cell thick
## becomes the painted floating platforms), the Seeker arrives at the exit it came through
## (else the "Start" marker), and death returns it to the last rest spot it used.
class_name RegionRoom
extends "res://src/test_rooms/art_style_test_room.gd"

const ENEMY_SCENE := preload("res://src/enemies/enemy.tscn")
const HUD_FONT := 22
const BAR_SIZE := Vector2(300, 16)
const METER_SIZE := Vector2(300, 8)
const HEALTH_COLOR := Color(0.85, 0.25, 0.25)
const METER_COLOR := Color(0.95, 0.85, 0.45)
const METER_FILLING_COLOR := Color(0.55, 0.5, 0.35)
const BAR_BACK := Color(0.08, 0.06, 0.06, 0.85)
const REST_RADIUS := 14.0
## Max health an Ember Heart relic adds.
const RELIC_HEALTH := 10.0
## Walkable surface of a floor whose top cell is row r: r * CELL + this (the top tile's
## trim plus the surface sink).
const FLOOR_OFFSET := 7.5
## Cells of wall fill drawn into solid rock from open air (deeper rock stays black).
const ROOM_FILL_DEPTH := 6
## Terrain-anchored foreground (replaces the art room's screen-height loops, which assume
## a room one screen tall with one ceiling and one floor). Every ceiling gets the rock
## overhang hanging from it, every stretch of solid ground the near rocks over the rock
## below it, and cavern floors the black foliage: fixed to the terrain up and down, with
## the art room's sideways parallax (FOREGROUND_SCALE.x) around their own centre.
## Each band's depth is a share of the space it sits in, so tunnels get a smaller one.
const CEILING_SHARE := 0.3
const GROUND_SHARE := 0.35
const BAND_MIN_SIZE := 0.3
## The segments' opaque part, in source px of their 1920x1080 canvas: the ceiling's from
## the top down to this, the ground's from this down to the bottom.
const CEILING_OPAQUE_PX := 435.0
const GROUND_OPAQUE_TOP_PX := 645.0
## How far the ground band's canvas bottom sits below the floor line, world px at full size
## (so its hills rise only a little above the floor, as in the art room).
const GROUND_SINK := 66.0
## Foliage: canvas bottom below the floor line (world px at full size), the least headroom
## (cells) a floor needs for it, and the narrowest run (cells).
const FOLIAGE_SINK := 64.0
const FOLIAGE_MIN_HEADROOM := 5
const BAND_MIN_RUN := 4
## Sideways drift allowed either side of a band's rest place (world px).
const BAND_DRIFT := 24.0
## Draw order of the ground and ceiling bands (the art room's foreground loops sit at 10).
const FOREGROUND_Z_BOTTOM := 10
const FOREGROUND_Z_TOP := 11
## Bands need this much open space (cells) beside them, and ground bands and foliage this
## many rows of rock under the floor, or they'd paint black over thin rock and tunnels.
const BAND_MIN_HEADROOM := 4
const GROUND_MIN_ROCK := 4
## A band's canvas edges that fall inside the rock fade out over this share of its height,
## so no hard black edge shows on the textured rock (the art room hides them at the
## screen's edges).
const CEILING_TOP_FADE := 0.06
const GROUND_BOTTOM_FADE := 0.15
const FOLIAGE_BOTTOM_FADE := 0.4
const BAND_SHADER := """
shader_type canvas_item;
uniform vec2 ends = vec2(0.0);
uniform vec2 vfade = vec2(0.0, 1.0);
void fragment() {
	COLOR = texture(TEXTURE, UV);
	float a = 1.0;
	if (ends.x > 0.0) { a *= smoothstep(0.0, ends.x, UV.x); }
	if (ends.y > 0.0) { a *= smoothstep(0.0, ends.y, 1.0 - UV.x); }
	if (vfade.x > 0.0) { a *= smoothstep(0.0, vfade.x, UV.y); }
	if (vfade.y < 1.0) { a *= 1.0 - smoothstep(vfade.y, 1.0, UV.y); }
	COLOR.a *= a;
}
"""
static var _band_shader: Shader
## Floating islands (rock not joined to the room's walls) get no textured wall fill: their
## painted edge around a black interior. Foliage on their tops is drawn at this size.
const ISLAND_FOLIAGE_SIZE := 0.55
## Secret rooms are covered by painted rock (z above everything in the room) until the
## Seeker steps into the fake wall or the room behind it; then the cover fades out.
const COVER_Z := 26
const COVER_FADE_TIME := 0.35
## The warm light at each exit, so the way on reads from across the room.
const EXIT_LIGHT := Color(1.0, 0.62, 0.3, 0.55)
const EXIT_LIGHT_DEPTH := 3.0

## The room's name, shown on entry.
@export var room_name := "Room"
## Columns from this one on get the cave look; -1 for none (all open cavern), 0 for all.
@export var cave_from_col := -1
## Seconds from death to respawn.
@export var respawn_delay := 1.2

## Whether the mood pass shows; V toggles it, and the choice carries across rooms.
static var mood_on := true

var player: Player
var _health_fill: ColorRect
var _meter_fill: ColorRect
var _status: Label
var _title: Label
var _rest_spots: Array[Node2D] = []
## Island cells and their depth in cells from the island's edge (1 = the edge).
var _islands := {}
## Fake-wall and secret-room cells, hidden under the cover until found.
var _cover_cells := {}
var _cover: Node2D


func _ready() -> void:
	if RegionTravel.player_state == null:
		RegionTravel.reset()
	_read_layout()
	player_state = RegionTravel.player_state
	ledge_grab = false
	fill_depth = ROOM_FILL_DEPTH
	close_band_overlap_at_steps = false
	help_text = ""
	spawn_point = _arrival_point()
	super._ready()
	player = seeker
	if RegionTravel.bonus_health > 0.0:
		player.health.max_health += RegionTravel.bonus_health
		player.health.current = player.health.max_health
	if RegionTravel.health > 0.0:
		player.health.current = minf(RegionTravel.health, player.health.max_health)
	player.heal_meter.add(RegionTravel.heal_meter)
	player.died.connect(_on_player_died)
	for exit in _exits():
		exit.player = player
	_camera.reset_smoothing.call_deferred()
	if _mood != null:
		_mood.set_enabled(mood_on)
	_spawn_markers()
	_build_cover()
	_build_hud()
	for exit in _exits():
		RegionTravel.preload_room(exit.target_room)
	RegionTravel.fade(get_tree(), 0.0, 0.25)


## Turns the Layout layer into the pipeline's grid ('#' rock, '.' air) and its free-floating
## one-cell-thick rock into painted floating platforms. Fake walls (tile 1,0) and secret-room
## air (tile 2,0) are air to the pipeline and go under the cover (see _build_cover).
func _read_layout() -> void:
	var terrain := _terrain()
	var layout := get_node_or_null(^"Layout") as TileMapLayer
	var cells := terrain.room_cells if terrain != null else Vector2i(14, 8)
	var rows: Array[PackedStringArray] = []
	for y in cells.y:
		var row := PackedStringArray()
		row.resize(cells.x)
		for x in cells.x:
			row[x] = "."
			if layout != null and layout.get_cell_source_id(Vector2i(x, y)) >= 0:
				var brush := layout.get_cell_atlas_coords(Vector2i(x, y)).x
				row[x] = "#" if brush == 0 else "."
				if brush == 1 or brush == 2:
					_cover_cells[Vector2i(x, y)] = true
		rows.append(row)
	if layout != null:
		layout.visible = false
	# Floating platforms: runs of rock one cell thick with air above and below.
	var platforms := []
	for y in range(1, cells.y - 1):
		var x := 0
		while x < cells.x:
			if not _is_slab(rows, x, y, cells):
				x += 1
				continue
			var start := x
			while x < cells.x and _is_slab(rows, x, y, cells):
				x += 1
			# Only free-floating runs: a ledge joined to rock (a switchback's step) stays rock.
			if rows[y][start - 1] != "." or (x < cells.x and rows[y][x] != "."):
				continue
			for c in range(start, x):
				rows[y][c] = "."
			platforms.append_array(_platform_props(start, x - start, y))
	grid = []
	for row in rows:
		grid.append("".join(row))
	islands = platforms
	ground_props = []
	hanging_props = []
	corridor_ground_props = []
	corridor_hanging_props = []
	corridor_start_col = cave_from_col
	borders = []
	_find_islands()


## Finds the floating islands: groups of rock cells (side by side) that don't reach the
## room's edge; records each cell's depth from the island's edge (8-neighbour steps).
func _find_islands() -> void:
	_islands.clear()
	var w: int = grid[0].length()
	var h := grid.size()
	var seen := {}
	for y in h:
		for x in w:
			var start := Vector2i(x, y)
			if seen.has(start) or grid[y][x] != "#":
				continue
			var group: Array[Vector2i] = [start]
			seen[start] = true
			var floating := true
			var i := 0
			while i < group.size():
				var c := group[i]
				i += 1
				if c.x == 0 or c.y == 0 or c.x == w - 1 or c.y == h - 1:
					floating = false
				for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var n: Vector2i = c + d
					if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h or seen.has(n) or grid[n.y][n.x] != "#":
						continue
					seen[n] = true
					group.append(n)
			if not floating:
				continue
			var members := {}
			for c in group:
				members[c] = true
			for c in group:
				var depth := 1
				var found := false
				while not found and depth < 8:
					for dy in range(-depth, depth + 1):
						for dx in range(-depth, depth + 1):
							if not members.has(c + Vector2i(dx, dy)):
								found = true
					if not found:
						depth += 1
				_islands[c] = depth


## No textured wall fill inside floating islands: their edge around a black interior.
func _wants_fill(col: int, row: int) -> bool:
	return not _islands.has(Vector2i(col, row))


## True when the floor run stands on a floating island.
func _on_island(run: Array) -> bool:
	return _islands.has(Vector2i((run[1] + run[2]) / 2, run[0] + 1))


# --- Secret rooms ------------------------------------------------------------------

## Covers the fake wall and the secret room behind it with painted rock: black, the
## textured wall fill (faded with depth like the walls around it), and the rock's edge
## where it faces the open room. Fades out for good once the Seeker steps in.
func _build_cover() -> void:
	if _cover_cells.is_empty():
		return
	var key := scene_file_path
	if RegionTravel.revealed.has(key):
		return
	_cover = Node2D.new()
	_cover.z_index = COVER_Z
	_cover.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(_cover)
	var visible_open := func(c: Vector2i) -> bool:
		return not _solid(c.x, c.y) and not _cover_cells.has(c)
	# Depth of each covered cell from the open room (8-neighbour steps).
	var depth := {}
	var frontier: Array[Vector2i] = []
	for c: Vector2i in _cover_cells:
		for dy in [-1, 0, 1]:
			for dx in [-1, 0, 1]:
				if visible_open.call(c + Vector2i(dx, dy)):
					depth[c] = 1
		if depth.has(c):
			frontier.append(c)
	var d := 1
	while not frontier.is_empty():
		d += 1
		var next: Array[Vector2i] = []
		for c in frontier:
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					var n: Vector2i = c + Vector2i(dx, dy)
					if _cover_cells.has(n) and not depth.has(n):
						depth[n] = d
						next.append(n)
		frontier = next
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = Player.LAYER_PLAYER
	add_child(area)
	for c: Vector2i in _cover_cells:
		var p := Vector2(c) * CELL
		var cell_depth: int = depth.get(c, 99)
		var alpha := clampf(float(fill_depth + 1 - cell_depth) / float(FILL_FADE_CELLS + 1), 0.0, 1.0)
		var up: bool = visible_open.call(c + Vector2i.UP)
		var down: bool = visible_open.call(c + Vector2i.DOWN)
		var left: bool = visible_open.call(c + Vector2i.LEFT)
		var right: bool = visible_open.call(c + Vector2i.RIGHT)
		var tile := -1
		if up:
			tile = TILE_TL if left and not right else (TILE_TR if right and not left else TILE_T)
		elif down:
			tile = TILE_BL if left and not right else (TILE_BR if right and not left else TILE_B)
		elif left:
			tile = TILE_L
		elif right:
			tile = TILE_R
		# Drawn like the real walls: the edge's rock face, the wall fill cut to its solid
		# part, then the rim on top; an inner cell is black under its fill.
		if tile >= 0:
			_add_tile(_cover, tile, c.x, c.y)
			_add_middle_fill(_cover, c.x, c.y, [tile]).modulate.a = alpha
			_add_middle_tile(_cover, tile, c.x, c.y)
		else:
			var black := Polygon2D.new()
			black.polygon = PackedVector2Array([p, p + Vector2(CELL, 0), p + Vector2(CELL, CELL), p + Vector2(0, CELL)])
			black.color = TERRAIN_COLOR
			_cover.add_child(black)
			_add_middle_fill(_cover, c.x, c.y).modulate.a = alpha
		var shape := CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		(shape.shape as RectangleShape2D).size = Vector2.ONE * CELL
		shape.position = p + Vector2.ONE * CELL * 0.5
		area.add_child(shape)
	area.body_entered.connect(func(body: Node2D) -> void:
		if body != player or _cover == null:
			return
		RegionTravel.revealed[key] = true
		var tween := create_tween()
		tween.tween_property(_cover, "modulate:a", 0.0, COVER_FADE_TIME)
		tween.tween_callback(_cover.queue_free)
		_cover = null)


# --- Terrain-anchored foreground ------------------------------------------------

## Replaces the art room's foreground: the rim (unchanged), then ceiling, ground and
## foliage bands anchored to the terrain (see CEILING_SHARE).
func _add_foreground(parent: Node2D) -> void:
	_add_middle_rim(parent)
	for run in _ceiling_runs():
		if run[3] >= BAND_MIN_HEADROOM:
			_add_ceiling_band(parent, run)
	var next_foliage := 0
	for run in _ground_runs():
		if run[2] - run[1] + 1 < BAND_MIN_RUN or run[3] < BAND_MIN_HEADROOM:
			continue
		if _on_island(run):
			next_foliage = _add_foliage(parent, run, next_foliage, ISLAND_FOLIAGE_SIZE)
			continue
		if not _solid_below(run, GROUND_MIN_ROCK):
			continue
		_add_ground_band(parent, run)
		if run[3] >= FOLIAGE_MIN_HEADROOM:
			next_foliage = _add_foliage(parent, run, next_foliage)
	_add_exit_lights(parent)


## Runs of open cells with rock right above: [row, first col, last col, headroom in cells
## (open cells below, the least along the run)].
func _ceiling_runs() -> Array:
	var runs := []
	for row in range(1, grid.size()):
		var start := -1
		var start_room := 0
		for col in grid[0].length() + 1:
			var cell: bool = col < grid[0].length() and not _solid(col, row) and _solid(col, row - 1)
			var room := 0
			if cell:
				while row + room < grid.size() and not _solid(col, row + room):
					room += 1
			if start >= 0 and (not cell or col == grid[0].length()):
				if col - start >= BAND_MIN_RUN:
					runs.append([row, start, col - 1, start_room])
				start = -1
			if cell and start < 0:
				start = col
				start_room = room
			elif cell:
				start_room = mini(start_room, room)
	return runs


## Whole stretches of floor: [row of the open cells, first col, last col, the most open
## cells above any of them]. Unlike the art room's floor runs these don't break where the
## ceiling changes height, so a floor under islands keeps one band of foreground.
func _ground_runs() -> Array:
	var runs := []
	for row in grid.size() - 1:
		var start := -1
		var most := 0
		for col in grid[0].length() + 1:
			var cell: bool = col < grid[0].length() and not _solid(col, row) and _solid(col, row + 1) \
					and not _cover_cells.has(Vector2i(col, row))
			if cell:
				var room := 0
				while row - room >= 0 and not _solid(col, row - room):
					room += 1
				most = maxi(most, room) if start >= 0 else room
				if start < 0:
					start = col
			elif start >= 0:
				runs.append([row, start, col - 1, most])
				start = -1
	return runs


## True when the floor run stands on at least [param depth] rows of rock all along it
## (sampled at its ends, quarters and middle), not a ledge or an island.
func _solid_below(run: Array, depth: int) -> bool:
	for i in 5:
		var col: int = run[1] + (run[2] - run[1]) * i / 4
		for d in range(1, depth + 1):
			if not _solid(col, run[0] + d):
				return false
	return true


func _segments(folder: String, side: String) -> Array[Texture2D]:
	return [_texture(BIOME + folder + "segments/foreground-%s-A.png" % side),
			_texture(BIOME + folder + "segments/foreground-%s-B.png" % side)]


## The cave look's segments for runs in the cave columns, else the open cavern's.
func _folder_for(run: Array) -> String:
	var mid: float = (run[1] + run[2]) * 0.5
	return "corridor/" if corridor_start_col >= 0 and mid >= corridor_start_col else "parallax/"


func _add_ceiling_band(parent: Node2D, run: Array) -> void:
	var pieces := _segments(_folder_for(run), "top")
	var full := VIEW_SIZE.y / 1080.0
	var size := clampf(run[3] * CELL * CEILING_SHARE / (CEILING_OPAQUE_PX * full), BAND_MIN_SIZE, 1.0)
	# The canvas's top is solid rock: tuck it into the ceiling, its edge faded out.
	var top: float = run[0] * CELL - 30.0 * size
	# Fixed to its ceiling (sideways too): it is the ceiling's own rock.
	_add_band(parent, run, pieces, full * size, top, FOREGROUND_Z_TOP, 0,
			Vector2(CEILING_TOP_FADE, 1.0), 1.0)


func _add_ground_band(parent: Node2D, run: Array) -> void:
	var pieces := _segments(_folder_for(run), "bottom")
	var full := VIEW_SIZE.y / 1080.0
	var size := clampf(run[3] * CELL * GROUND_SHARE / ((1080.0 - GROUND_OPAQUE_TOP_PX) * full),
			0.6, 1.0)
	var floor_line: float = (run[0] + 1) * CELL
	var top := floor_line + GROUND_SINK * size - VIEW_SIZE.y * size
	_add_band(parent, run, pieces, full * size, top, FOREGROUND_Z_BOTTOM, 0,
			Vector2(0.0, 1.0 - GROUND_BOTTOM_FADE))


## Black foliage standing on a cavern floor, in front of the player. Returns the next piece
## index (the pieces cycle across runs, like the art room's band).
func _add_foliage(parent: Node2D, run: Array, first: int, size := 1.0) -> int:
	var pieces: Array[Texture2D] = []
	for name in SILHOUETTE_PIECES:
		pieces.append(_texture(SILHOUETTES + "%s.png" % name))
	var full := VIEW_SIZE.y / 1080.0 * size
	var floor_line: float = (run[0] + 1) * CELL
	var top := floor_line + FOLIAGE_SINK * size - pieces[0].get_height() * full
	return _add_band(parent, run, pieces, full, top, SILHOUETTE_Z, first,
			Vector2(0.0, 1.0 - FOLIAGE_BOTTOM_FADE))


## One band of [param pieces] across the run's width (whole pieces, stretched a little to
## fit, the ends faded), its canvas top at world y [param top], fixed up and down and
## scrolling sideways at FOREGROUND_SCALE.x around the run's centre. Returns the index of
## the piece after the last one used.
func _add_band(parent: Node2D, run: Array, pieces: Array[Texture2D], image_scale: float,
		top: float, z: int, first := 0, vfade := Vector2(0.0, 1.0),
		scroll := FOREGROUND_SCALE.x) -> int:
	var x0: float = run[1] * CELL
	var x1: float = (run[2] + 1) * CELL
	var width := x1 - x0
	var piece_w := pieces[0].get_width() * image_scale
	var count := maxi(1, roundi(width / piece_w))
	var stretch := width / (count * piece_w)
	var layer := Node2D.new()
	layer.z_index = z
	parent.add_child(layer)
	var index := first
	for i in count:
		var sprite := Sprite2D.new()
		sprite.texture = pieces[index % pieces.size()]
		sprite.centered = false
		sprite.scale = Vector2(image_scale * stretch, image_scale)
		sprite.position = Vector2(i * piece_w * stretch, 0.0)
		layer.add_child(sprite)
		var fade_uv := CLOSE_ROCKS_END_FADE / (piece_w * stretch)
		var ends := Vector2(fade_uv if i == 0 else 0.0, fade_uv if i == count - 1 else 0.0)
		if _band_shader == null:
			_band_shader = Shader.new()
			_band_shader.code = BAND_SHADER
		var material := ShaderMaterial.new()
		material.shader = _band_shader
		material.set_shader_parameter("ends", ends)
		material.set_shader_parameter("vfade", vfade)
		sprite.material = material
		index += 1
	var spot := Vector2(x0, top)
	var reference := clampf((x0 + x1) * 0.5, VIEW_SIZE.x * 0.5, _room_size.x - VIEW_SIZE.x * 0.5)
	var factor := Vector2(scroll, 1.0)
	_layers.append([layer, factor, spot - Vector2(reference * (1.0 - factor.x), 0.0),
			Vector2(spot.x - BAND_DRIFT, spot.x + BAND_DRIFT)])
	return index


## A warm light in each exit's opening, fading into the room, so the way on is easy to see.
func _add_exit_lights(parent: Node2D) -> void:
	for exit in _exits():
		var at: Vector2 = exit.position + (exit.get_parent() as Node2D).position
		var half: Vector2 = exit.size * 0.5
		var depth := EXIT_LIGHT_DEPTH * CELL
		var clear := Color(EXIT_LIGHT, 0.0)
		var light := Polygon2D.new()
		light.z_index = -5
		var inward := Vector2.ZERO
		if at.x < CELL:
			inward = Vector2.RIGHT
		elif at.x > _room_size.x - CELL:
			inward = Vector2.LEFT
		elif at.y < CELL * 4.0:
			inward = Vector2.DOWN
		else:
			inward = Vector2.UP
		var a: Vector2
		var b: Vector2
		if inward.x != 0.0:
			var x: float = 0.0 if inward.x > 0.0 else _room_size.x
			a = Vector2(x, at.y - half.y)
			b = Vector2(x, at.y + half.y)
		else:
			var y: float = 0.0 if inward.y > 0.0 else _room_size.y
			a = Vector2(at.x - half.x, y)
			b = Vector2(at.x + half.x, y)
		light.polygon = PackedVector2Array([a, b, b + inward * depth, a + inward * depth])
		light.vertex_colors = PackedColorArray([EXIT_LIGHT, EXIT_LIGHT, clear, clear])
		parent.add_child(light)


func _is_slab(rows: Array[PackedStringArray], x: int, y: int, cells: Vector2i) -> bool:
	return rows[y][x] == "#" and rows[y - 1][x] == "." and rows[y + 1][x] == "." \
			and x > 0 and x < cells.x - 1


## Painted floating platforms covering [param count] cells from column [param col] whose
## walkable surface is row [param row]'s top: [prop, centre x, surface y, surface px].
func _platform_props(col: int, count: int, row: int) -> Array:
	var surface := row * CELL + FLOOR_OFFSET
	var x0 := col * CELL
	var width := count * CELL
	if count == 1:
		return [["platform-short", x0 + width * 0.5, surface, 83.0]]
	var pieces := maxi(1, ceili(count / 2.0))
	var props := []
	for i in pieces:
		props.append(["platform-long", x0 + (i + 0.5) * width / pieces, surface, 103.0])
	return props


## V turns the mood pass (fog, blur, embers, colour grade) on or off, for slower machines;
## the choice carries across rooms.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != KEY_V:
		return
	mood_on = not mood_on
	if _mood != null:
		_mood.set_enabled(mood_on)
	_show_title("Mood on" if mood_on else "Mood off")


func _physics_process(_delta: float) -> void:
	if player == null or player.state != Player.State.GROUND:
		return
	if not Input.is_action_just_pressed(&"interact"):
		return
	for spot in _rest_spots:
		if spot.global_position.distance_to(player.global_position) <= REST_RADIUS + 8.0:
			_rest(spot)
			return


func _terrain() -> PaintedTerrain:
	for child in get_children():
		if child is PaintedTerrain:
			return child
	return null


func _exits() -> Array[RoomExit]:
	var found: Array[RoomExit] = []
	for node in find_children("*", "RoomExit", true, false):
		found.append(node)
	return found


func _arrival_point() -> Vector2:
	var wanted := RegionTravel.arrival_exit
	RegionTravel.arrival_exit = &""
	if wanted != &"":
		for exit in _exits():
			if exit.exit_id == wanted:
				return exit.position + (exit.get_parent() as Node2D).position + exit.arrive_offset
		for spot in find_children("*", "RoomSpawn", true, false):
			if spot.kind == RoomSpawn.Kind.REST and spot.name == String(wanted):
				return spot.position + (spot.get_parent() as Node2D).position
	var start := get_node_or_null(^"Start") as Node2D
	return start.position if start != null else VIEW_SIZE * 0.5


func _spawn_markers() -> void:
	for spot: RoomSpawn in find_children("*", "RoomSpawn", true, false):
		match spot.kind:
			RoomSpawn.Kind.ENEMY:
				if spot.enemy_config == null:
					continue
				var enemy: EnemyBase = ENEMY_SCENE.instantiate()
				enemy.config = spot.enemy_config
				enemy.target = player
				enemy.position = spot.global_position
				add_child(enemy)
			RoomSpawn.Kind.ABILITY:
				var pickup := AbilityPickup.new()
				pickup.ability = spot.ability
				pickup.color = spot.color
				pickup.player_state = player.player_state
				pickup.position = spot.global_position + Vector2(0, -10)
				add_child(pickup)
			RoomSpawn.Kind.GATE_SIGN:
				var gate := AbilityGate.new()
				gate.ability = spot.ability
				gate.color = spot.color
				gate.player_state = player.player_state
				gate.position = spot.global_position
				add_child(gate)
			RoomSpawn.Kind.RELIC:
				_add_relic(spot)
			RoomSpawn.Kind.REST:
				_rest_spots.append(spot)
				var glow := Polygon2D.new()
				var points := PackedVector2Array()
				for i in 16:
					points.append(Vector2.from_angle(TAU * i / 16.0) * REST_RADIUS + Vector2(0, -REST_RADIUS))
				glow.polygon = points
				glow.color = Color(1.0, 0.7, 0.35, 0.35)
				glow.z_index = 15
				spot.add_child(glow)
				var label := Label.new()
				label.text = "rest (Up)"
				label.add_theme_font_size_override(&"font_size", 8)
				label.position = Vector2(-18, -REST_RADIUS * 2 - 12)
				label.z_index = 15
				spot.add_child(label)


## An Ember Heart: a glowing pickup that raises max health by RELIC_HEALTH, once per run.
func _add_relic(spot: Node2D) -> void:
	var key := scene_file_path + ":" + String(spot.name)
	if RegionTravel.relics.has(key):
		return
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = Player.LAYER_PLAYER
	area.position = spot.global_position + Vector2(0, -12)
	area.z_index = 15
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	(shape.shape as CircleShape2D).radius = 10.0
	area.add_child(shape)
	var gem := Polygon2D.new()
	gem.polygon = PackedVector2Array([Vector2(0, -7), Vector2(5, 0), Vector2(0, 7), Vector2(-5, 0)])
	gem.color = Color(1.0, 0.45, 0.25)
	area.add_child(gem)
	var tween := gem.create_tween().set_loops()
	tween.tween_property(gem, "scale", Vector2.ONE * 1.25, 0.5)
	tween.tween_property(gem, "scale", Vector2.ONE, 0.5)
	add_child(area)
	area.body_entered.connect(func(body: Node2D) -> void:
		if body != player:
			return
		RegionTravel.relics[key] = true
		RegionTravel.bonus_health += RELIC_HEALTH
		player.health.max_health += RELIC_HEALTH
		player.health.current += RELIC_HEALTH
		player.damaged.emit(0.0, player.health.current)
		_show_title("Ember Heart: max health +%d" % int(RELIC_HEALTH))
		area.queue_free())


func _rest(spot: Node2D) -> void:
	player.health.reset()
	player.damaged.emit(0.0, player.health.current)
	RegionTravel.respawn_room = scene_file_path
	RegionTravel.respawn_exit = StringName(spot.name)
	_show_title("Rested. Health restored.")


func _on_player_died() -> void:
	await get_tree().create_timer(respawn_delay).timeout
	RegionTravel.health = -1.0
	RegionTravel.heal_meter = 0.0
	RegionTravel.player_state = player.player_state
	var room := RegionTravel.respawn_room if not RegionTravel.respawn_room.is_empty() \
			else scene_file_path
	RegionTravel.arrival_exit = RegionTravel.respawn_exit
	await RegionTravel.fade(get_tree(), 1.0)
	get_tree().change_scene_to_file.call_deferred(room)


# --- HUD -------------------------------------------------------------------

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 3
	add_child(hud)
	_health_fill = _bar(hud, Vector2(24, 24), BAR_SIZE, HEALTH_COLOR)
	_meter_fill = _bar(hud, Vector2(24, 46), METER_SIZE, METER_FILLING_COLOR)
	_status = _label(hud, Vector2(24 + BAR_SIZE.x + 12, 16))
	_title = _label(hud, Vector2(24, 1000))
	var help := _label(hud, Vector2(24, 64))
	help.text = "Move arrows  Jump Space/Z  Attack X  Heal hold R  Rest Up  Dash Shift/C (once found)  V mood on/off"
	help.add_theme_font_size_override(&"font_size", 16)
	player.damaged.connect(func(_a: float, _l: float) -> void: _update_health())
	player.healed.connect(func(_a: float, _l: float) -> void: _update_health())
	player.heal_meter.changed.connect(func(_a: float, _c: float) -> void: _update_meter())
	_update_health()
	_update_meter()
	_show_title(room_name)


func _bar(parent: Node, at: Vector2, bar_size: Vector2, color: Color) -> ColorRect:
	var back := ColorRect.new()
	back.color = BAR_BACK
	back.position = at
	back.size = bar_size
	parent.add_child(back)
	var fill := ColorRect.new()
	fill.color = color
	fill.size = bar_size
	back.add_child(fill)
	return fill


func _label(parent: Node, at: Vector2) -> Label:
	var label := Label.new()
	label.position = at
	label.add_theme_font_size_override(&"font_size", HUD_FONT)
	parent.add_child(label)
	return label


func _update_health() -> void:
	var h := player.health
	_health_fill.size.x = BAR_SIZE.x * h.current / h.max_health
	_status.text = "HP %d / %d" % [int(h.current), int(h.max_health)]


func _update_meter() -> void:
	var m := player.heal_meter
	_meter_fill.size.x = METER_SIZE.x * m.ratio()
	_meter_fill.color = METER_COLOR if m.is_full() else METER_FILLING_COLOR


func _show_title(text: String) -> void:
	_title.text = text
	_title.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.6)
	tween.tween_property(_title, "modulate:a", 0.0, 0.8)
