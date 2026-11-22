## A room's tile kinds on the 6 px collision grid (terrain pipeline rules 2 and 3): each
## cell is empty, solid or one-way. Cells outside the grid count as solid, so no face is
## made at the grid's edge (ADR-0001); a room paints its border cells solid.
##
## Usage: [codeblock]
## var grid := TerrainGrid.from_rows(PackedStringArray([
##         "....",
##         ".##.",     # '#' solid, '-' one-way, '.' empty
##         "####"]))
## var kind := grid.kind_at(1, 1)   # TerrainGrid.SOLID
## [/codeblock]
class_name TerrainGrid
extends RefCounted

const EMPTY := 0
const SOLID := 1
const ONE_WAY := 2
## The tile's atlas coordinates in the terrain TileSet (two tiles, no physics layer).
const ATLAS_SOLID := Vector2i(0, 0)
const ATLAS_ONE_WAY := Vector2i(1, 0)

var width := 0
var height := 0
## Row-major tile kinds, [member width] x [member height].
var cells := PackedByteArray()
## The grid's top-left cell on the room's grid, so shapes sit in room px.
var origin := Vector2i.ZERO


## Builds a grid from text rows: '#' solid, '-' one-way, anything else empty.
static func from_rows(rows: PackedStringArray) -> TerrainGrid:
	var grid := TerrainGrid.new()
	grid.height = rows.size()
	grid.width = rows[0].length() if rows.size() > 0 else 0
	grid.cells.resize(grid.width * grid.height)
	for y in grid.height:
		for x in grid.width:
			var ch := rows[y][x]
			grid.cells[y * grid.width + x] = SOLID if ch == "#" else (ONE_WAY if ch == "-" else EMPTY)
	return grid


## Reads the painted [TileMapLayer]: the atlas tile at each used cell gives its kind.
static func from_layer(layer: TileMapLayer) -> TerrainGrid:
	var used := layer.get_used_rect()
	var grid := TerrainGrid.new()
	grid.origin = used.position
	grid.width = used.size.x
	grid.height = used.size.y
	grid.cells.resize(grid.width * grid.height)
	for cell in layer.get_used_cells():
		var atlas := layer.get_cell_atlas_coords(cell)
		var kind := ONE_WAY if atlas == ATLAS_ONE_WAY else SOLID
		grid.cells[(cell.y - used.position.y) * grid.width + (cell.x - used.position.x)] = kind
	return grid


## The kind of cell ([param x], [param y]); cells outside the grid are solid.
func kind_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return SOLID
	return cells[y * width + x]
