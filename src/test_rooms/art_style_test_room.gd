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
## Terrain is black-box geometry: each mass is a solid rectangle (the collision) filled
## black, with the pack's 9-slice rock cells painted along its exposed edges. Cell size
## and the rock-edge insets come from the tiles themselves (measured from their alpha).
## Props and parallax layers come from the same pack. Values here are test-room
## constants, not tuned gameplay data.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const BIOME := "res://assets/environment/cinderheart-caldera/"
const RENDER_SIZE := Vector2i(1920, 1080)
const ZOOM := 4.0
const ROOM_SIZE := Vector2(1440, 360)
const VIEW_SIZE := Vector2(480, 270)
const SPAWN_POINT := Vector2(96, 260)
const TERRAIN_COLOR := Color(0, 0, 0)
const BACKGROUND_COLOR := Color(0.08, 0.05, 0.06)

## One terrain cell in world px; the source cells are 512 px.
const CELL := 36.0
const TILE_SOURCE := 512.0
## The atlas is a 3584 px export of 1254 px native art; props are at native size.
const ATLAS_PER_NATIVE := 3584.0 / 1254.0
## Rock-edge insets inside the edge cells, in source px (from the tiles' alpha).
const TOP_INSET := 78.0
const LEFT_INSET := 33.0
const RIGHT_INSET := 51.0
const BOTTOM_INSET := 33.0
## 9-slice tile ids in the 7x7 sheet (row * 7 + column).
const T_TL := 0
const T_T := 1
const T_TR := 2
const T_L := 7
const T_R := 9
const T_BL := 14
const T_B := 15
const T_BR := 16

## Terrain masses in cells: column, row, columns, rows, then which edges are exposed
## (top, left, right, bottom). A hidden edge runs into a wall or off the room.
const MASSES := [
	[0, 0, 40, 1, false, false, false, true],     # ceiling
	[0, 8, 16, 2, true, false, true, false],      # left floor, surface y 293.5
	[16, 9, 6, 1, true, false, false, false],     # pit floor, surface y 329.5
	[22, 7, 18, 3, true, true, false, false],     # right floor, surface y 257.5
	[31, 4, 9, 3, true, true, false, false],      # high ledge, surface y 149.5
]
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
	["wall-right", 1300.0, 149.5],
	["decoration-tall", 1180.0, 149.5],
]
## Hanging props: prop, left x (their top meets the ceiling).
const HANGING_PROPS := [
	["ceiling-overhang", 280.0],
	["hanging-decoration", 560.0],
	["ceiling-overhang", 860.0],
	["hanging-decoration", 1240.0],
]
## Parallax layers from the pack's layers.json: file, scroll scale, whether the painting
## repeats (mirrored, so the seams meet) instead of stretching to cover the room.
const PARALLAX_BACK := [["background", 0.15, false], ["midground", 0.5, true]]
const FOREGROUND_SCALE := 1.2
## The foreground painting has no fully clear column, so each end keeps the painting's
## left half (mirrored at the right end) and fades out across its middle.
const FOREGROUND_FADE_SHADER := """
shader_type canvas_item;
uniform float fade_from = 0.38;
uniform float fade_to = 0.5;
void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	c.a *= 1.0 - smoothstep(fade_from, fade_to, UV.x);
	COLOR = c;
}
"""
const HELP_TEXT := "Art-style test: Cinderheart Caldera painted art at 1920x1080, Seeker at 4x.\nArrows/WASD move  Space/Z jump x2  Shift/C dash  E grapple  X attack"

var _textures := {}
var _camera: Camera2D
## Manual parallax: [layer node, scroll scale, base offset]. Parallax2D placed the
## layers wrongly under the 4x camera zoom in this test, so the layers follow the camera
## here instead: on screen each moves by scroll scale times the camera's motion.
var _layers: Array = []


func _ready() -> void:
	var window := get_window()
	window.content_scale_size = RENDER_SIZE
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)

	var world := Node2D.new()
	world.name = "PaintedWorld"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(world)

	_add_parallax(world)
	for mass in MASSES:
		_add_mass(world, mass)
	for island in ISLANDS:
		_add_island(world, island)
	for entry in GROUND_PROPS:
		var texture := _texture(BIOME + "assets/%s.png" % entry[0])
		var used := _used_rect(entry[0])
		var sprite := _prop_sprite(world, texture)
		sprite.position = Vector2(entry[1] - used.position.x * _prop_scale(),
				entry[2] - used.end.y * _prop_scale() + 3.0)
	for entry in HANGING_PROPS:
		var texture := _texture(BIOME + "assets/%s.png" % entry[0])
		var used := _used_rect(entry[0])
		var sprite := _prop_sprite(world, texture)
		sprite.position = Vector2(entry[1], CELL - 6.0 - used.position.y * _prop_scale())
	_add_foreground(world)

	var player: Player = PLAYER_SCENE.instantiate()
	player.position = SPAWN_POINT
	add_child(player)
	var camera := PlayerCamera.new()
	_camera = camera
	camera.zoom = Vector2(ZOOM, ZOOM)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	player.add_child(camera)
	camera.setup(player)

	var hud := CanvasLayer.new()
	var help := Label.new()
	help.position = Vector2(16, 12)
	help.add_theme_font_size_override(&"font_size", 22)
	help.text = HELP_TEXT
	hud.add_child(help)
	add_child(hud)


## World px per source px for props (native-size art).
func _prop_scale() -> float:
	return CELL / TILE_SOURCE * ATLAS_PER_NATIVE


## Loads a PNG with mipmaps so the downscaled painted art does not shimmer.
## Test-room shortcut: a real pipeline sets mipmaps in the import settings instead.
func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		var image := Image.load_from_file(path)
		image.generate_mipmaps()
		_textures[path] = ImageTexture.create_from_image(image)
	return _textures[path]


func _used_rect(prop: String) -> Rect2:
	var image := _texture(BIOME + "assets/%s.png" % prop).get_image()
	return Rect2(image.get_used_rect())


func _prop_sprite(parent: Node2D, texture: Texture2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.scale = Vector2.ONE * _prop_scale()
	parent.add_child(sprite)
	return sprite


func _add_mass(parent: Node2D, mass: Array) -> void:
	var col: int = mass[0]
	var row: int = mass[1]
	var cols: int = mass[2]
	var rows: int = mass[3]
	var top: bool = mass[4]
	var left: bool = mass[5]
	var right: bool = mass[6]
	var bottom: bool = mass[7]
	var k := CELL / TILE_SOURCE
	var x0 := col * CELL + (LEFT_INSET * k if left else 0.0)
	var x1 := (col + cols) * CELL - (RIGHT_INSET * k if right else 0.0)
	var y0 := row * CELL + (TOP_INSET * k if top else 0.0)
	var y1 := (row + rows) * CELL - (BOTTOM_INSET * k if bottom else 0.0)
	var rect := Rect2(x0, y0, x1 - x0, y1 - y0)

	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)

	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y),
			rect.end, Vector2(rect.position.x, rect.end.y)])
	fill.color = TERRAIN_COLOR
	parent.add_child(fill)

	for j in rows:
		for i in cols:
			var tile := _edge_tile(i, j, cols, rows, top, left, right, bottom)
			if tile < 0:
				continue
			var sprite := Sprite2D.new()
			sprite.texture = _texture(BIOME + "terrain/tiles/tile-%02d.png" % tile)
			sprite.centered = false
			sprite.scale = Vector2.ONE * k
			sprite.position = Vector2((col + i) * CELL, (row + j) * CELL)
			parent.add_child(sprite)


## The 9-slice cell for one position in a mass, or -1 for an interior cell (the black fill).
func _edge_tile(i: int, j: int, cols: int, rows: int, top: bool, left: bool, right: bool,
		bottom: bool) -> int:
	var at_top := top and j == 0
	var at_bottom := bottom and j == rows - 1
	var at_left := left and i == 0
	var at_right := right and i == cols - 1
	if at_top:
		return T_TL if at_left else (T_TR if at_right else T_T)
	if at_bottom:
		return T_BL if at_left else (T_BR if at_right else T_B)
	if at_left:
		return T_L
	if at_right:
		return T_R
	return -1


func _add_island(parent: Node2D, island: Array) -> void:
	var texture := _texture(BIOME + "assets/%s.png" % island[0])
	var used := _used_rect(island[0])
	var s := _prop_scale()
	var sprite := _prop_sprite(parent, texture)
	sprite.position = Vector2(island[1] - (used.position.x + used.size.x * 0.5) * s,
			island[2] - island[3] * s)
	var body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(used.size.x * s - 8.0, 8.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.one_way_collision = true
	body.position = Vector2(island[1], island[2] + 4.0)
	body.add_child(collision)
	parent.add_child(body)


## Background and midground: the background is scaled to cover the view at both ends
## of the room for its scroll scale; the midground repeats mirrored at a near-native
## size. Both are centred on the room when the camera is centred.
func _add_parallax(parent: Node2D) -> void:
	var camera_travel := ROOM_SIZE - VIEW_SIZE
	var index := -30
	for entry in PARALLAX_BACK:
		var factor: float = entry[1]
		var repeats: bool = entry[2]
		var texture := _texture(BIOME + "parallax/%s.png" % entry[0])
		var needed := VIEW_SIZE + camera_travel * factor
		var image_scale := needed.y / texture.get_height() if repeats \
				else maxf(needed.x / texture.get_width(), needed.y / texture.get_height())
		var tile := texture.get_size() * image_scale
		var copies := int(ceil(needed.x / tile.x)) if repeats else 1
		var layer := Node2D.new()
		layer.z_index = index
		index += 10
		for i in copies:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.scale = Vector2.ONE * image_scale
			sprite.position = Vector2(i * tile.x, 0.0)
			sprite.flip_h = i % 2 == 1
			layer.add_child(sprite)
		parent.add_child(layer)
		var size := Vector2(tile.x * copies, tile.y)
		_layers.append([layer, Vector2(factor, factor), ROOM_SIZE * 0.5 * factor - size * 0.5])


## Foreground framing: one screen-sized copy framing the room's left end and a mirrored
## copy framing its right end. They slide away faster than the play layer sideways and
## stay pinned to the screen's top and bottom edges, so they never drift into play.
func _add_foreground(parent: Node2D) -> void:
	var texture := _texture(BIOME + "parallax/foreground.png")
	var image_scale := VIEW_SIZE.x / texture.get_width()
	var factor := Vector2(FOREGROUND_SCALE, 0.0)
	var start_center := Vector2(VIEW_SIZE.x * 0.5, ROOM_SIZE.y - VIEW_SIZE.y * 0.5)
	var shader := Shader.new()
	shader.code = FOREGROUND_FADE_SHADER
	var fade := ShaderMaterial.new()
	fade.shader = shader
	for at_end in [false, true]:
		var center := start_center + (Vector2(ROOM_SIZE.x - VIEW_SIZE.x, 0.0) if at_end else Vector2.ZERO)
		var layer := Node2D.new()
		layer.z_index = 10
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.scale = Vector2.ONE * image_scale
		sprite.flip_h = at_end
		sprite.material = fade
		layer.add_child(sprite)
		parent.add_child(layer)
		_layers.append([layer, factor, center * factor - VIEW_SIZE * 0.5])


func _process(_delta: float) -> void:
	if _camera == null:
		return
	var center := _camera.get_screen_center_position()
	for entry in _layers:
		var layer: Node2D = entry[0]
		var factor: Vector2 = entry[1]
		layer.position = center * (Vector2.ONE - factor) + entry[2]
