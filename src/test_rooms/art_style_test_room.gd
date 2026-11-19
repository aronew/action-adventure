## Art-style test room (throwaway): the painted Cinderheart Caldera art at full
## resolution around the pixel-art Seeker drawn at 4x. Built in code so the .tscn only
## attaches this script. It changes nothing outside itself: the window's content scale
## is switched to 1920x1080 here, at runtime, and the project settings stay as they are.
##
## How the two styles meet: gameplay keeps its pixel units (the Seeker is 22 px tall, a
## screen is 480x270 world px), the camera zooms 4x, and the window renders 1920x1080.
## The Seeker keeps the project's nearest filter, so each of its pixels is a crisp 4x4
## block. The painted art sits under a node with linear, mipmapped filtering and is
## scaled so one source pixel lands on about one screen pixel.
##
## Terrain is a grid of solid cells, like an autotile: each solid cell picks its rock
## edge from which neighbours are empty (top, sides, bottom, corners) and an interior
## cell is plain black. Collision follows the painted rock faces, using each edge
## tile's measured inset (from its alpha). Props stand on their solid edge, not their
## soft glow. Values here are test-room constants, not tuned gameplay data.
##
## Parallax follows the GameMaker article the owner pointed to ("Creating depth and
## immersion: parallax"): every layer is the camera position times a weight. Far layers
## move slower than the world; the foreground lives in the world and moves faster than
## it (about 2x sideways, 1.1x up and down), built from strips that repeat sideways.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const BIOME := "res://assets/environment/cinderheart-caldera/"
const RENDER_SIZE := Vector2i(1920, 1080)
const ZOOM := 4.0
const VIEW_SIZE := Vector2(480, 270)
const SPAWN_POINT := Vector2(96, 260)
const TERRAIN_COLOR := Color(0, 0, 0)
const BACKGROUND_COLOR := Color(0.08, 0.05, 0.06)

## One terrain cell in world px; the source cells are 512 px.
const CELL := 36.0
const TILE_SOURCE := 512.0
## The atlas is a 3584 px export of 1254 px native art; props are at native size.
const ATLAS_PER_NATIVE := 3584.0 / 1254.0
## Edge tiles in the 7x7 sheet (row * 7 + column) and where each one's painted rock face
## sits inside its 512 px cell: [top, bottom, left, right] insets in source px.
const TILE_TL := 0
const TILE_T := 1
const TILE_TR := 2
const TILE_L := 7
const TILE_R := 9
const TILE_BL := 14
const TILE_B := 15
const TILE_BR := 16
const TILE_INSETS := {
	0: [69, 0, 82, 0], 1: [78, 0, 0, 0], 2: [79, 0, 0, 90],
	7: [0, 0, 73, 0], 9: [0, 0, 0, 90],
	14: [0, 62, 76, 0], 15: [0, 64, 0, 0], 16: [0, 69, 0, 102],
}
## The room in cells ('#' solid). Cells outside the grid count as solid, so the room's
## own border shows no rock face. Columns 0-39 are the open cave; from column 40 a tight
## corridor runs on from the high ledge: a low ceiling (82 px of headroom), a hanging
## dip at columns 52-56, a step up at column 60 and a rock wall closing it at column 66.
const GRID := [
	"######################################################################",
	"........................................##############################",
	"....................................................#####.........####",
	"............................................................##########",
	"...............................#######################################",
	"...............................#######################################",
	"...............................#######################################",
	"......................################################################",
	"################......################################################",
	"######################################################################",
]
## Where the corridor begins (its first column) and how wide, in world px, the soft
## blend between the open cave's layers and the corridor's is at its mouth.
const CORRIDOR_START_COL := 40
const LAYER_BLEND := 72.0
## The corridor's close rear wall (corridor/layers.json "close-wall"): a loop that sits
## just behind the play layer instead of the distant background.
const CORRIDOR_WALL_SCALE := 0.85

## Solid bounds of each prop (alpha over half), in source px: left, top, right, bottom.
const PROP_BOUNDS := {
	"platform-short": [11, 11, 181, 179], "platform-medium": [13, 17, 257, 219],
	"platform-long": [12, 33, 373, 218], "rocks-small": [16, 133, 213, 263],
	"rocks-large": [11, 65, 329, 263], "ruin-prop": [11, 17, 321, 262],
	"decoration-low": [12, 107, 260, 264], "decoration-tall": [83, 16, 287, 292],
	"wall-left": [47, 17, 251, 318], "wall-right": [29, 14, 243, 315],
	"ceiling-overhang": [12, 81, 312, 270], "hanging-decoration": [57, 11, 144, 255],
}
## How far a ground prop sinks into the surface it stands on, in world px.
const PROP_SINK := 2.0
## Floating islands: prop, centre x, surface y (world), surface y in the source image.
const ISLANDS := [
	["platform-short", 420.0, 232.0, 67.0],
	["platform-medium", 690.0, 266.0, 78.0],
	["platform-long", 990.0, 192.0, 96.0],
]
## Ground props: prop, left x, the surface they stand on (world y). No collision.
const GROUND_PROPS := [
	["wall-left", 4.0, 293.5],
	["rocks-small", 150.0, 293.5],
	["ruin-prop", 200.0, 293.5],
	["rocks-large", 820.0, 257.5],
	["decoration-low", 1010.0, 257.5],
	["decoration-tall", 1180.0, 149.5],
	["wall-right", 1300.0, 149.5],
]
## Hanging props: prop, left x (their top tucks into the ceiling).
const HANGING_PROPS := [
	["ceiling-overhang", 280.0],
	["hanging-decoration", 560.0],
	["ceiling-overhang", 860.0],
	["hanging-decoration", 1240.0],
]
## Corridor props: prop, left x, the surface they stand on (world y), or for hanging
## props the ceiling line they hang from. No collision.
const CORRIDOR_GROUND_PROPS := [
	["rocks-small", 1640.0, 149.5],
	["decoration-low", 2010.0, 149.5],
]
const CORRIDOR_HANGING_PROPS := [
	["hanging-decoration", 1780.0],
]
## Background layers: file, scroll scale (how fast it moves on screen against the
## camera; 1 = the play layer), whether it repeats (mirrored, so the seams meet) instead
## of stretching to cover the room.
const BACK_LAYERS := [["background", 0.15, false], ["midground", 0.5, true]]
## Foreground strips (the owner's v5 loops): on screen they move faster than the play
## layer. Sideways 1.2, the loops' own camera_motion_factor (foreground-layers.json);
## up and down 1.1, the GameMaker article's vertical weight of -0.1.
const FOREGROUND_SCALE := Vector2(1.2, 1.1)
## Each loop is a full screen-height canvas (3840x1080) that repeats every 3840 px.
const FOREGROUND_STRIPS := ["foreground-top", "foreground-bottom"]
## Room-end pieces: file, at the room's left (else its right), scaled to the room's full
## height (else to one screen, top-aligned, for a corridor that is less than a screen
## tall). The open cave's left border at the room's left end; the corridor's right border
## over the rock wall that closes the corridor.
const BORDERS := [
	["parallax/border-left.png", true, true],
	["corridor/brighter/border-right.png", false, false],
]
## Camera dead zone in this room (fractions of half the screen): a jump stays inside it,
## so the view only scrolls up near the top and follows real falls. The bottom margin
## (0.3 = 40 px) is a little larger than the camera's fall lead (36 px), so a normal
## jump's descent does not pull the view down. The old one-screen rooms never scrolled
## vertically, so this only matters for rooms taller than a screen.
const CAMERA_DRAG_TOP := 0.5
const CAMERA_DRAG_BOTTOM := 0.3
const HELP_TEXT := "Art-style test: Cinderheart Caldera painted art at 1920x1080, Seeker at 4x. Corridor: right, past the high ledge.\nArrows/WASD move  Space/Z jump x2  Shift/C dash  E grapple  X attack"

## The room's layout. These start as the constants above; a longer test room
## (art_style_long_room.gd) swaps in its own in _init, before _ready builds the room.
var grid: Array = GRID
var islands: Array = ISLANDS
var ground_props: Array = GROUND_PROPS
var hanging_props: Array = HANGING_PROPS
var spawn_point := SPAWN_POINT
var help_text := HELP_TEXT

var _textures := {}
var _camera: Camera2D
var _room_size := Vector2.ZERO
## Manual parallax: [layer node, scroll scale, base]. Each frame a layer is placed at
## camera_centre * (1 - scroll scale) + base, so on screen it moves by scroll scale times
## the camera's motion. (Parallax2D placed the layers wrongly under the 4x zoom here.)
var _layers: Array = []


func _ready() -> void:
	var window := get_window()
	window.content_scale_size = RENDER_SIZE
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	_room_size = Vector2(grid[0].length(), grid.size()) * CELL

	var world := Node2D.new()
	world.name = "PaintedWorld"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(world)

	_add_back_layers(world)
	_add_corridor_wall(world)
	_add_terrain(world)
	for island in islands:
		_add_island(world, island)
	var s := _prop_scale()
	for entry in ground_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1] - bounds[0] * s, entry[2] - bounds[3] * s + PROP_SINK)
	var ceiling_bottom := CELL - TILE_INSETS[TILE_B][1] * CELL / TILE_SOURCE
	for entry in hanging_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1], ceiling_bottom - bounds[1] * s - PROP_SINK)
	for entry in CORRIDOR_GROUND_PROPS:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1] - bounds[0] * s, entry[2] - bounds[3] * s + PROP_SINK)
	var corridor_ceiling := 2.0 * CELL - TILE_INSETS[TILE_B][1] * CELL / TILE_SOURCE
	for entry in CORRIDOR_HANGING_PROPS:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1], corridor_ceiling - bounds[1] * s - PROP_SINK)
	_add_foreground(world)

	var player: Player = PLAYER_SCENE.instantiate()
	player.position = spawn_point
	add_child(player)
	var camera := PlayerCamera.new()
	_camera = camera
	camera.zoom = Vector2(ZOOM, ZOOM)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(_room_size.x)
	camera.limit_bottom = int(_room_size.y)
	camera.drag_vertical_enabled = true
	camera.drag_top_margin = CAMERA_DRAG_TOP
	camera.drag_bottom_margin = CAMERA_DRAG_BOTTOM
	player.add_child(camera)
	camera.setup(player)

	var hud := CanvasLayer.new()
	var help := Label.new()
	help.position = Vector2(16, 12)
	help.add_theme_font_size_override(&"font_size", 22)
	help.text = help_text
	hud.add_child(help)
	add_child(hud)


func _enter_tree() -> void:
	# Place the parallax layers after the camera has moved this frame, right before
	# drawing, so they never trail it by a frame.
	RenderingServer.frame_pre_draw.connect(_place_layers)


func _exit_tree() -> void:
	RenderingServer.frame_pre_draw.disconnect(_place_layers)


func _place_layers() -> void:
	if _camera == null or not _camera.is_inside_tree():
		return
	var center := _camera.get_screen_center_position()
	for entry in _layers:
		var layer: Node2D = entry[0]
		var factor: Vector2 = entry[1]
		layer.position = center * (Vector2.ONE - factor) + entry[2]


## World px per source px for props (native-size art).
func _prop_scale() -> float:
	return CELL / TILE_SOURCE * ATLAS_PER_NATIVE


## Loads an imported texture. The environment art is imported with mipmaps on
## (mipmaps/generate in each .import file), so the downscaled painted art does not shimmer.
func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]


func _prop_sprite(parent: Node2D, prop: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + "assets/%s.png" % prop)
	sprite.centered = false
	sprite.scale = Vector2.ONE * _prop_scale()
	parent.add_child(sprite)
	return sprite


func _solid(col: int, row: int) -> bool:
	if row < 0 or row >= grid.size() or col < 0 or col >= grid[0].length():
		return true
	return grid[row][col] == "#"


## The edge tile for a solid cell, or -1 for an interior cell (plain black).
func _edge_tile(col: int, row: int) -> int:
	var up := not _solid(col, row - 1)
	var down := not _solid(col, row + 1)
	var left := not _solid(col - 1, row)
	var right := not _solid(col + 1, row)
	if up:
		return TILE_TL if left and not right else (TILE_TR if right and not left else TILE_T)
	if down:
		return TILE_BL if left and not right else (TILE_BR if right and not left else TILE_B)
	if left:
		return TILE_L
	if right:
		return TILE_R
	return -1


## For an interior cell at an inside corner, the two tiles that paint it: the surface
## running on under it, then the wall face continuing into it. Floor corners (solid
## above and beside, empty diagonally above): [TILE_T, face]. Ceiling corners (solid
## below and beside, empty diagonally below): [TILE_B, face]. Otherwise [].
func _inside_corner_tiles(col: int, row: int) -> Array:
	if _solid(col, row - 1):
		if not _solid(col - 1, row - 1) and _solid(col - 1, row):
			return [TILE_T, TILE_L]
		if not _solid(col + 1, row - 1) and _solid(col + 1, row):
			return [TILE_T, TILE_R]
	if _solid(col, row + 1):
		if not _solid(col - 1, row + 1) and _solid(col - 1, row):
			return [TILE_B, TILE_L]
		if not _solid(col + 1, row + 1) and _solid(col + 1, row):
			return [TILE_B, TILE_R]
	return []


## Paints every solid cell and builds the collision: one shape per run of cells in a row
## that share the same top and bottom insets, trimmed to the painted rock faces.
func _add_terrain(parent: Node2D) -> void:
	var k := CELL / TILE_SOURCE
	var body := StaticBody2D.new()
	parent.add_child(body)
	for row in grid.size():
		var run_start := -1
		var run_insets: Array = []
		var run_left := 0.0
		for col in grid[0].length() + 1:
			var solid: bool = col < grid[0].length() and _solid(col, row)
			var tile := _edge_tile(col, row) if solid else -1
			var corner: Array = _inside_corner_tiles(col, row) if solid and tile < 0 else []
			var insets: Array = TILE_INSETS[tile] if tile >= 0 else [0, 0, 0, 0]
			if not corner.is_empty():
				# The floor (or ceiling) beside it runs on under the wall face at its
				# surface height.
				insets = [TILE_INSETS[TILE_T][0], 0, 0, 0] if corner[0] == TILE_T \
						else [0, TILE_INSETS[TILE_B][1], 0, 0]
			var same: bool = solid and run_start >= 0 and insets[0] == run_insets[0] \
					and insets[1] == run_insets[1]
			if run_start >= 0 and not same:
				var prev_tile := _edge_tile(col - 1, row)
				var prev_insets: Array = TILE_INSETS[prev_tile] if prev_tile >= 0 else [0, 0, 0, 0]
				var x1: float = col * CELL - prev_insets[3] * k
				_add_box(body, Rect2(run_left, row * CELL + run_insets[0] * k,
						x1 - run_left, CELL - (run_insets[0] + run_insets[1]) * k))
				run_start = -1
			if solid and run_start < 0:
				run_start = col
				run_insets = insets
				run_left = col * CELL + insets[2] * k
			if not solid:
				continue
			if tile >= 0:
				_add_tile(parent, tile, col, row)
			elif not corner.is_empty():
				# Inside corner: the surface runs on under the wall face.
				_add_tile(parent, corner[0], col, row)
				_add_tile(parent, corner[1], col, row)
			else:
				var fill := Polygon2D.new()
				var p := Vector2(col * CELL, row * CELL)
				fill.polygon = PackedVector2Array([p, p + Vector2(CELL, 0),
						p + Vector2(CELL, CELL), p + Vector2(0, CELL)])
				fill.color = TERRAIN_COLOR
				parent.add_child(fill)


func _add_tile(parent: Node2D, tile: int, col: int, row: int) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + "terrain/tiles/tile-%02d.png" % tile)
	sprite.centered = false
	sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
	sprite.position = Vector2(col * CELL, row * CELL)
	parent.add_child(sprite)


func _add_box(body: StaticBody2D, rect: Rect2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = rect.get_center()
	body.add_child(collision)


func _add_island(parent: Node2D, island: Array) -> void:
	var bounds: Array = PROP_BOUNDS[island[0]]
	var s := _prop_scale()
	var sprite := _prop_sprite(parent, island[0])
	sprite.position = Vector2(island[1] - (bounds[0] + bounds[2]) * 0.5 * s, island[2] - island[3] * s)
	var body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2((bounds[2] - bounds[0]) * s - 8.0, 8.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.one_way_collision = true
	body.position = Vector2(island[1], island[2] + 4.0)
	body.add_child(collision)
	parent.add_child(body)


## Background and midground: the background is scaled to cover the view at both ends
## of the room for its scroll scale; the midground repeats mirrored at a near-native
## size. Both are centred on the room when the camera is centred.
func _add_back_layers(parent: Node2D) -> void:
	var camera_travel := _room_size - VIEW_SIZE
	var index := -30
	for entry in BACK_LAYERS:
		var factor: float = entry[1]
		var repeats: bool = entry[2]
		var texture := _texture(BIOME + "parallax/%s.png" % entry[0])
		var needed := VIEW_SIZE + camera_travel * factor
		var image_scale := needed.y / texture.get_height() if repeats \
				else maxf(needed.x / texture.get_width(), needed.y / texture.get_height())
		var tile := texture.get_size() * image_scale
		var copies := int(ceil(needed.x / tile.x)) if repeats else 1
		var layer := _strip_layer(parent, texture, Rect2(Vector2.ZERO, texture.get_size()),
				image_scale, copies, index)
		index += 10
		var size := Vector2(tile.x * copies, tile.y)
		_layers.append([layer, Vector2(factor, factor), _room_size * 0.5 * factor - size * 0.5])


## Foreground: the open cave's loops (parallax/) over the open cave and the corridor's
## loops (corridor/brighter/) over the corridor, each set masked to its own part of the
## room with a soft blend at the corridor's mouth. Both sets live in the world and repeat
## sideways. Then the room-end borders.
func _add_foreground(parent: Node2D) -> void:
	var mouth := CORRIDOR_START_COL * CELL
	var open_mask := _blend_mask(parent, 0.0, mouth + LAYER_BLEND * 0.5, false, 10)
	var corridor_mask := _blend_mask(parent, mouth - LAYER_BLEND * 0.5, _room_size.x, true, 10)
	var center_min := VIEW_SIZE * 0.5
	var center_max := _room_size - VIEW_SIZE * 0.5
	# Open cave: the top loop meets the screen's top with the camera at the room's top,
	# the bottom loop with the camera at the room's floor. Corridor: the camera stays at
	# the room's top there, so both loops are set for that height.
	_add_foreground_set(open_mask, "parallax/", center_min.y, center_max.y)
	_add_foreground_set(corridor_mask, "corridor/brighter/", center_min.y, center_min.y)
	# Borders are fixed in the world at the room's ends (see BORDERS for their scale).
	for border in BORDERS:
		var texture := _texture(BIOME + border[0])
		var height := _room_size.y if border[2] else VIEW_SIZE.y
		var image_scale := height / texture.get_height()
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.scale = Vector2.ONE * image_scale
		sprite.z_index = 12
		var width := texture.get_width() * image_scale
		sprite.position = Vector2(0.0 if border[1] else _room_size.x - width, 0.0)
		parent.add_child(sprite)


## One set of top and bottom foreground loops from [param folder], under [param mask].
## [param top_ref] and [param bottom_ref] are the camera heights at which each loop's
## canvas meets the screen's top.
func _add_foreground_set(mask: Node2D, folder: String, top_ref: float, bottom_ref: float) -> void:
	var camera_travel := _room_size - VIEW_SIZE
	var center_min := VIEW_SIZE * 0.5
	for strip in FOREGROUND_STRIPS:
		var texture := _texture(BIOME + folder + "%s.png" % strip)
		var image_scale := VIEW_SIZE.y / texture.get_height()
		var period := texture.get_width() * image_scale
		var copies := int(ceil((VIEW_SIZE.x + camera_travel.x * FOREGROUND_SCALE.x) / period)) + 1
		var layer := _strip_layer(mask, texture, Rect2(Vector2.ZERO, texture.get_size()),
				image_scale, copies, 0, false)
		var reference_y := top_ref if strip == "foreground-top" else bottom_ref
		# On screen: top-left = base - scale * centre + VIEW_SIZE / 2. Solve for the base
		# that puts the canvas top at the screen's top at the reference height, and its
		# left edge at the screen's left at the room's left.
		var base := FOREGROUND_SCALE * Vector2(center_min.x, reference_y) - VIEW_SIZE * 0.5
		_layers.append([layer, FOREGROUND_SCALE, base])


## The corridor's close rear wall: a loop just behind the play layer (scroll scale 0.85),
## masked to the corridor so the open cave keeps its distant background.
func _add_corridor_wall(parent: Node2D) -> void:
	var mouth := CORRIDOR_START_COL * CELL
	var mask := _blend_mask(parent, mouth - LAYER_BLEND * 0.5, _room_size.x, true, -10)
	var texture := _texture(BIOME + "corridor/background-loop.png")
	var image_scale := VIEW_SIZE.y / texture.get_height()
	var period := texture.get_width() * image_scale
	var factor := Vector2(CORRIDOR_WALL_SCALE, CORRIDOR_WALL_SCALE)
	var center_min := VIEW_SIZE * 0.5
	# Long enough to cover the corridor's whole width plus the screen at both ends.
	var needed := (_room_size.x - mouth) + VIEW_SIZE.x * 2.0
	var copies := int(ceil(needed / period)) + 1
	var layer := _strip_layer(mask, texture, Rect2(Vector2.ZERO, texture.get_size()),
			image_scale, copies, 0, false)
	# Its left edge sits a screen left of the mouth when the camera is at the mouth, and
	# its top meets the screen's top with the camera at the room's top.
	var mouth_center := mouth
	var base := Vector2(mouth - VIEW_SIZE.x - mouth_center * (1.0 - factor.x),
			factor.y * center_min.y - VIEW_SIZE.y * 0.5)
	_layers.append([layer, factor, base])


## A world-space mask from [param x0] to [param x1] over the room's full height whose
## children draw only inside it, fading over [constant LAYER_BLEND] at the corridor's
## mouth: in from the left when [param fade_in_left], else out to the right.
func _blend_mask(parent: Node2D, x0: float, x1: float, fade_in_left: bool, z: int) -> Node2D:
	var mask := Polygon2D.new()
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.z_index = z
	var h := _room_size.y
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	var clear := Color(1, 1, 1, 0)
	var solid := Color(1, 1, 1, 1)
	if fade_in_left:
		var xb := x0 + LAYER_BLEND
		points = PackedVector2Array([Vector2(x0, 0), Vector2(xb, 0), Vector2(x1, 0),
				Vector2(x1, h), Vector2(xb, h), Vector2(x0, h)])
		colors = PackedColorArray([clear, solid, solid, solid, solid, clear])
	else:
		var xb := x1 - LAYER_BLEND
		points = PackedVector2Array([Vector2(x0, 0), Vector2(xb, 0), Vector2(x1, 0),
				Vector2(x1, h), Vector2(xb, h), Vector2(x0, h)])
		colors = PackedColorArray([solid, solid, clear, clear, solid, solid])
	mask.polygon = points
	mask.vertex_colors = colors
	# Two quads, so the fade interpolates across the blend band only.
	mask.polygons = [PackedInt32Array([0, 1, 4, 5]), PackedInt32Array([1, 2, 3, 4])]
	parent.add_child(mask)
	return mask


## A layer of [param copies] side-by-side copies of one region of a texture. With
## [param mirror], every other copy is flipped so the seams of a non-looping painting meet.
func _strip_layer(parent: Node2D, texture: Texture2D, region: Rect2, image_scale: float,
		copies: int, z: int, mirror := true) -> Node2D:
	var layer := Node2D.new()
	layer.z_index = z
	for i in copies:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.region_enabled = true
		sprite.region_rect = region
		sprite.scale = Vector2.ONE * image_scale
		sprite.position = Vector2(i * region.size.x * image_scale, 0.0)
		sprite.flip_h = mirror and i % 2 == 1
		layer.add_child(sprite)
	parent.add_child(layer)
	return layer
