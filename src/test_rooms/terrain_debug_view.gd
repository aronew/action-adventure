## Draws a [TerrainGrid] for the terrain test room (throwaway): solid cells as dark blocks,
## one-way cells as a thin top plate, every exposed face as a bright line (green where its
## material is no_cling), and, when switched on, the collision strips [TerrainBuilder]
## makes as magenta outlines. It draws only; the collision is the [Terrain] node's.
class_name TerrainDebugView
extends Node2D

const SOLID_COLOR := Color(0.2, 0.21, 0.28)
const ONE_WAY_COLOR := Color(0.35, 0.55, 0.85)
const FACE_COLOR := Color(0.85, 0.88, 0.95)
const NO_CLING_COLOR := Color(0.35, 0.9, 0.5)
const STRIP_COLOR := Color(1.0, 0.3, 0.8, 0.9)
const FACE_WIDTH := 1.0

var show_strips := false
var _grid: TerrainGrid
var _data: RoomTerrainData


## Shows [param grid] with the materials in [param data].
func setup(grid: TerrainGrid, data: RoomTerrainData) -> void:
	_grid = grid
	_data = data
	queue_redraw()


## Switches the strip outlines on or off.
func set_show_strips(on: bool) -> void:
	show_strips = on
	queue_redraw()


func _draw() -> void:
	if _grid == null:
		return
	var tile := float(TerrainBuilder.TILE)
	for y in _grid.height:
		for x in _grid.width:
			var kind := _grid.cells[y * _grid.width + x]
			var origin := Vector2(x, y) * tile
			if kind == TerrainGrid.SOLID:
				draw_rect(Rect2(origin, Vector2(tile, tile)), SOLID_COLOR)
			elif kind == TerrainGrid.ONE_WAY:
				draw_rect(Rect2(origin, Vector2(tile, 2.0)), ONE_WAY_COLOR)
	for face in TerrainBuilder.faces(_grid, _data):
		var color := NO_CLING_COLOR if face.material == RoomTerrainData.NO_CLING else FACE_COLOR
		var from := Vector2.ZERO
		var to := Vector2.ZERO
		match face.side:
			TerrainBuilder.Side.TOP:
				from = Vector2(face.start, face.line) * tile
				to = Vector2(face.end + 1, face.line) * tile
			TerrainBuilder.Side.BOTTOM:
				from = Vector2(face.start, face.line + 1) * tile
				to = Vector2(face.end + 1, face.line + 1) * tile
			TerrainBuilder.Side.LEFT:
				from = Vector2(face.line, face.start) * tile
				to = Vector2(face.line, face.end + 1) * tile
			_:
				from = Vector2(face.line + 1, face.start) * tile
				to = Vector2(face.line + 1, face.end + 1) * tile
		draw_line(from, to, color, FACE_WIDTH)
	if show_strips:
		for rect in TerrainBuilder.strips(_grid, _data):
			draw_rect(Rect2(Vector2(rect.position) * tile, Vector2(rect.size) * tile), STRIP_COLOR, false, 1.0)
