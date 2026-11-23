@tool
## Draws the painted biome terrain over a layout [TileMapLayer] and builds its collision.
## Paint rock cells into the layout layer in the Godot editor (any tile counts as solid);
## this node redraws the painted edge tiles (top, sides, bottom, outer and inner corners)
## live in the editor and at runtime, the same way the art-style test room does.
## Cells outside [member room_cells] count as solid, so a room's border needs no paint.
## Cells painted with the layout's second tile (atlas x 1) are fake walls: drawn as rock
## but with no collision, so a secret passage hides behind them.
##
## Usage: a room scene holds a TileMapLayer named "Layout" and this node beside it with
## [member layout] pointing at it. Collision is one box per run of cells in a row that
## share the same top and bottom trim, trimmed to the painted rock faces.
class_name PaintedTerrain
extends Node2D

## One terrain cell in world px (the layout tileset's tile size).
const CELL := 36.0
## Size of one painted tile in the source art, px.
const TILE_SOURCE := 512.0
const TILE_TL := 0
const TILE_T := 1
const TILE_TR := 2
const TILE_L := 7
const TILE_R := 9
const TILE_BL := 14
const TILE_B := 15
const TILE_BR := 16
## Where each edge tile's painted rock face sits in its 512 px cell: [top, bottom, left,
## right] insets in source px (measured from the art's alpha).
const TILE_INSETS := {
	0: [69, 0, 82, 0], 1: [78, 0, 0, 0], 2: [79, 0, 0, 90],
	7: [0, 0, 73, 0], 9: [0, 0, 0, 90],
	14: [0, 62, 76, 0], 15: [0, 64, 0, 0], 16: [0, 69, 0, 102],
}
## A walkable top's collision sits this far (world px) below the stones' top outline.
const SURFACE_SINK := 2.0
## Inside corners: the wall face fades out across the floor's lip band, [opaque, clear]
## in source px.
const CORNER_FADES := {"floor": [64.0, 112.0], "ceiling": [448.0, 400.0]}
const FADE_SHADER := """
shader_type canvas_item;
uniform vec3 fade = vec3(0.0, 0.0, 1.0);
void fragment() {
	float t = fade.x > 0.5 ? UV.x : UV.y;
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= clamp((t - fade.z) / (fade.y - fade.z), 0.0, 1.0);
}
"""

## Floating islands one cell thick are drawn with the biome's painted platform prop
## (assets/platform-long.png) instead of edge tiles; [walkable surface in the prop's
## own px, its solid left and right in px]. Several overlap to cover a long island.
const SLAB_PROP := "platform-long"
const SLAB_SURFACE := 103.0
const SLAB_BOUNDS := Vector2(12.0, 373.0)
## The props are native-size art: world px per prop px.
const PROP_SCALE := CELL / TILE_SOURCE * (3584.0 / 1254.0)

## The layout layer whose painted cells are solid rock.
@export var layout: TileMapLayer:
	set(value):
		if layout != null and layout.changed.is_connected(_queue_rebuild):
			layout.changed.disconnect(_queue_rebuild)
		layout = value
		if layout != null and is_inside_tree():
			layout.changed.connect(_queue_rebuild)
		_queue_rebuild()
## The room's size in cells; anything outside it is solid.
@export var room_cells := Vector2i(40, 15):
	set(value):
		room_cells = value
		_queue_rebuild()
## Folder of the biome's terrain tiles (tile-00.png ... tile-48.png).
@export_dir var tiles_dir := "res://assets/environment/cinderheart-caldera/terrain/tiles"
## Colour of the solid interior.
@export var interior_color := Color(0, 0, 0)

var _solid_cells := {}
var _fake_cells := {}
## Loaded tile textures, shared by every room so a room change doesn't reload them.
static var _textures := {}
var _fade_shader: Shader
var _pending := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if layout != null and not layout.changed.is_connected(_queue_rebuild):
		layout.changed.connect(_queue_rebuild)
	rebuild()


## True when the cell at [param col], [param row] is solid rock.
func is_solid(col: int, row: int) -> bool:
	if row < 0 or row >= room_cells.y or col < 0 or col >= room_cells.x:
		return true
	return _solid_cells.has(Vector2i(col, row))


## Rebuilds the painted tiles and the collision from the layout layer.
func rebuild() -> void:
	_pending = false
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_solid_cells.clear()
	_fake_cells.clear()
	if layout == null:
		return
	for cell in layout.get_used_cells():
		_solid_cells[cell] = true
		if layout.get_cell_atlas_coords(cell).x == 1:
			_fake_cells[cell] = true
	_build()


func _queue_rebuild() -> void:
	if _pending or not is_inside_tree():
		return
	_pending = true
	rebuild.call_deferred()


func _build() -> void:
	var k := CELL / TILE_SOURCE
	var body := StaticBody2D.new()
	body.name = "Collision"
	add_child(body)
	var fill := Node2D.new()
	fill.name = "Interior"
	add_child(fill)
	var tiles := Node2D.new()
	tiles.name = "Tiles"
	add_child(tiles)
	for row in room_cells.y:
		var run_start := -1
		var run_insets: Array = []
		var run_left := 0.0
		for col in room_cells.x + 1:
			var solid: bool = col < room_cells.x and is_solid(col, row)
			var collides: bool = solid and not _fake_cells.has(Vector2i(col, row))
			var tile := _edge_tile(col, row) if solid else -1
			var corner: Array = _inside_corner_tiles(col, row) if solid and tile < 0 else []
			var insets: Array = _collision_insets(tile)
			if not corner.is_empty():
				insets = [TILE_INSETS[TILE_T][0], 0, 0, 0] if corner[0] == TILE_T \
						else [0, TILE_INSETS[TILE_B][1], 0, 0]
			var same: bool = collides and run_start >= 0 and insets[0] == run_insets[0] \
					and insets[1] == run_insets[1]
			if run_start >= 0 and not same:
				var prev_insets: Array = _collision_insets(_edge_tile(col - 1, row)) \
						if col - 1 < room_cells.x else [0, 0, 0, 0]
				var x1: float = col * CELL - prev_insets[3] * k
				var sink: float = SURFACE_SINK if run_insets[0] > 0 else 0.0
				_add_box(body, Rect2(run_left, row * CELL + run_insets[0] * k + sink,
						x1 - run_left, CELL - (run_insets[0] + run_insets[1]) * k - sink))
				run_start = -1
			if collides and run_start < 0:
				run_start = col
				run_insets = insets
				run_left = col * CELL + insets[2] * k
			if not solid:
				continue
			if tile >= 0:
				if not _is_slab(col, row):
					_add_tile(tiles, tile, col, row)
			elif not corner.is_empty():
				_add_tile(tiles, corner[0], col, row)
				var face := _add_tile(tiles, corner[1], col, row)
				var fade: Array = CORNER_FADES["floor" if corner[0] == TILE_T else "ceiling"]
				_fade(face, fade[0], fade[1])
			else:
				var rect := Polygon2D.new()
				var p := Vector2(col * CELL, row * CELL)
				rect.polygon = PackedVector2Array([p, p + Vector2(CELL, 0),
						p + Vector2(CELL, CELL), p + Vector2(0, CELL)])
				rect.color = interior_color
				fill.add_child(rect)
	_add_slabs(tiles)
	# A border of plain rock around the room, so the camera never shows past its edge.
	var margin := 8.0 * CELL
	var size := Vector2(room_cells) * CELL
	for r in [Rect2(-margin, -margin, size.x + 2 * margin, margin),
			Rect2(-margin, size.y, size.x + 2 * margin, margin),
			Rect2(-margin, 0, margin, size.y), Rect2(size.x, 0, margin, size.y)]:
		var border := Polygon2D.new()
		border.polygon = PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0),
				r.end, r.position + Vector2(0, r.size.y)])
		border.color = interior_color
		fill.add_child(border)


## True for a cell of a floating island one cell thick: rock with air above and below.
func _is_slab(col: int, row: int) -> bool:
	return is_solid(col, row) and not _fake_cells.has(Vector2i(col, row)) \
			and not is_solid(col, row - 1) and not is_solid(col, row + 1)


func _add_slabs(parent: Node2D) -> void:
	var path := "%s/assets/%s.png" % [tiles_dir.get_base_dir().get_base_dir(), SLAB_PROP]
	if not _textures.has(path):
		_textures[path] = load(path)
	var texture: Texture2D = _textures[path]
	if texture == null:
		return
	var piece := (SLAB_BOUNDS.y - SLAB_BOUNDS.x) * PROP_SCALE
	var k := CELL / TILE_SOURCE
	for row in room_cells.y:
		var col := 0
		while col < room_cells.x:
			if not _is_slab(col, row):
				col += 1
				continue
			var start := col
			while col < room_cells.x and _is_slab(col, row):
				col += 1
			var x0 := start * CELL
			var width := (col - start) * CELL
			var count := maxi(1, ceili(width / piece))
			var surface := row * CELL + TILE_INSETS[TILE_T][0] * k + SURFACE_SINK
			for i in count:
				var center := x0 + (i + 0.5) * width / count
				var sprite := Sprite2D.new()
				sprite.texture = texture
				sprite.centered = false
				sprite.scale = Vector2.ONE * PROP_SCALE
				sprite.position = Vector2(center - (SLAB_BOUNDS.x + SLAB_BOUNDS.y) * 0.5 * PROP_SCALE,
						surface - SLAB_SURFACE * PROP_SCALE - SURFACE_SINK)
				parent.add_child(sprite)


func _edge_tile(col: int, row: int) -> int:
	var up := not is_solid(col, row - 1)
	var down := not is_solid(col, row + 1)
	var left := not is_solid(col - 1, row)
	var right := not is_solid(col + 1, row)
	if up:
		return TILE_TL if left and not right else (TILE_TR if right and not left else TILE_T)
	if down:
		return TILE_BL if left and not right else (TILE_BR if right and not left else TILE_B)
	if left:
		return TILE_L
	if right:
		return TILE_R
	return -1


func _inside_corner_tiles(col: int, row: int) -> Array:
	if is_solid(col, row - 1):
		if not is_solid(col - 1, row - 1) and is_solid(col - 1, row):
			return [TILE_T, TILE_L]
		if not is_solid(col + 1, row - 1) and is_solid(col + 1, row):
			return [TILE_T, TILE_R]
	if is_solid(col, row + 1):
		if not is_solid(col - 1, row + 1) and is_solid(col - 1, row):
			return [TILE_B, TILE_L]
		if not is_solid(col + 1, row + 1) and is_solid(col + 1, row):
			return [TILE_B, TILE_R]
	return []


func _collision_insets(tile: int) -> Array:
	if tile < 0:
		return [0, 0, 0, 0]
	var insets: Array = TILE_INSETS[tile].duplicate()
	if tile in [TILE_TL, TILE_TR]:
		insets[0] = TILE_INSETS[TILE_T][0]
	if tile in [TILE_BL, TILE_BR]:
		insets[1] = TILE_INSETS[TILE_B][1]
	if tile in [TILE_TL, TILE_BL]:
		insets[2] = TILE_INSETS[TILE_L][2]
	if tile in [TILE_TR, TILE_BR]:
		insets[3] = TILE_INSETS[TILE_R][3]
	return insets


func _add_tile(parent: Node2D, tile: int, col: int, row: int) -> Sprite2D:
	var path := "%s/tile-%02d.png" % [tiles_dir, tile]
	if not _textures.has(path):
		_textures[path] = load(path)
	var sprite := Sprite2D.new()
	sprite.texture = _textures[path]
	sprite.centered = false
	sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
	sprite.position = Vector2(col * CELL, row * CELL)
	parent.add_child(sprite)
	return sprite


func _add_box(body: StaticBody2D, rect: Rect2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = rect.get_center()
	body.add_child(collision)


func _fade(sprite: Sprite2D, solid: float, clear: float) -> void:
	if _fade_shader == null:
		_fade_shader = Shader.new()
		_fade_shader.code = FADE_SHADER
	var material := ShaderMaterial.new()
	material.shader = _fade_shader
	material.set_shader_parameter("fade", Vector3(0.0, solid / TILE_SOURCE, clear / TILE_SOURCE))
	sprite.material = material
