## Builds a room's collision from its painted grid (ADR-0001, terrain pipeline rules 2-6,
## 15, T4): one overlapping rectangle strip per exposed face segment, in one body for the
## solid faces and one for the one-way tops. Pure and deterministic; nothing is stored.
##
## A face segment is a maximal run of one tile kind and one material along one face. A
## solid cell's side is exposed when its neighbour is not solid; a one-way cell has only
## its top face, exposed when the cell above is empty. Cells outside the grid count as solid.
## A strip runs inward from its segment: its depth is the smaller of [constant SKIN_TILES]
## and the thinnest solid depth beneath the segment, at least one tile.
##
## Usage: [codeblock]
## var grid := TerrainGrid.from_rows(rows)
## var bodies := TerrainBuilder.build(grid, data)   # [solid body, one-way body]
## for body in bodies:
##     add_child(body)
## [/codeblock]
class_name TerrainBuilder
extends RefCounted

## A face of a cell, as the side of the solid it belongs to.
enum Side { TOP, BOTTOM, LEFT, RIGHT }

## Collision tile size in game px (terrain pipeline rule 2).
const TILE := 6
## Most tiles a strip runs inward from its face (a tuning value, ADR-0001).
const SKIN_TILES := 4

## One exposed face segment: the cells [member start] to [member end] (inclusive) along
## row [member line] for TOP and BOTTOM, or column [member line] for LEFT and RIGHT.
class Face extends RefCounted:
	var side := 0
	var line := 0
	var start := 0
	var end := 0
	var kind := 0
	var material := RoomTerrainData.PLAIN

	func length() -> int:
		return end - start + 1


## All exposed face segments of [param grid], ordered by (side, line, start). [param data]
## may be null (every face plain).
static func faces(grid: TerrainGrid, data: RoomTerrainData = null) -> Array[Face]:
	var out: Array[Face] = []
	var width := grid.width
	var height := grid.height
	var stride := width + 2
	# A padded copy so the neighbour test needs no bounds checks; outside counts as solid.
	var padded := PackedByteArray()
	padded.resize(stride * (height + 2))
	padded.fill(TerrainGrid.SOLID)
	for y in height:
		for x in width:
			padded[(y + 1) * stride + x + 1] = grid.cells[y * width + x]
	var has_overrides := data != null and not data.face_overrides.is_empty()
	var offsets: Array[int] = [-stride, stride, -1, 1]   # the neighbour on each Side
	for side in 4:
		var offset: int = offsets[side]
		var horizontal := side < 2
		var lines := height if horizontal else width
		var along := width if horizontal else height
		for line in lines:
			var run: Face = null
			for a in along:
				var x := a if horizontal else line
				var y := line if horizontal else a
				var index := (y + 1) * stride + x + 1
				var kind := padded[index]
				var neighbour := padded[index + offset]
				var exposed := false
				if kind == TerrainGrid.SOLID:
					exposed = neighbour != TerrainGrid.SOLID
				elif kind == TerrainGrid.ONE_WAY:
					exposed = side == Side.TOP and neighbour == TerrainGrid.EMPTY
				if not exposed:
					run = null
					continue
				var material := RoomTerrainData.PLAIN
				if has_overrides:
					material = data.material_at(Vector2i(x, y) + grid.origin, side)
				if run != null and run.kind == kind and run.material == material:
					run.end = a
				else:
					run = Face.new()
					run.side = side
					run.line = line
					run.start = a
					run.end = a
					run.kind = kind
					run.material = material
					out.append(run)
	return out


## The strip of [param face]: a rectangle in cells, running inward from the face.
static func strip(grid: TerrainGrid, face: Face) -> Rect2i:
	var horizontal := face.side < 2
	var inward := Vector2i.ZERO
	match face.side:
		Side.TOP:
			inward = Vector2i(0, 1)
		Side.BOTTOM:
			inward = Vector2i(0, -1)
		Side.LEFT:
			inward = Vector2i(1, 0)
		_:
			inward = Vector2i(-1, 0)
	var depth := 1 if face.kind == TerrainGrid.ONE_WAY else SKIN_TILES
	if face.kind == TerrainGrid.SOLID:
		for a in range(face.start, face.end + 1):
			var cell := Vector2i(a, face.line) if horizontal else Vector2i(face.line, a)
			var run := 0
			while run < depth and _solid_inside(grid, cell):
				run += 1
				cell += inward
			depth = run
	var length := face.length()
	match face.side:
		Side.TOP:
			return Rect2i(face.start, face.line, length, depth)
		Side.BOTTOM:
			return Rect2i(face.start, face.line - depth + 1, length, depth)
		Side.LEFT:
			return Rect2i(face.line, face.start, depth, length)
		_:
			return Rect2i(face.line - depth + 1, face.start, depth, length)


## The collision strips of [param grid] in cells, one per face segment, solid ones first.
static func strips(grid: TerrainGrid, data: RoomTerrainData = null) -> Array[Rect2i]:
	var solid: Array[Rect2i] = []
	var one_way: Array[Rect2i] = []
	for face in faces(grid, data):
		if face.kind == TerrainGrid.ONE_WAY:
			one_way.append(strip(grid, face))
		else:
			solid.append(strip(grid, face))
	return solid + one_way


## Builds the room's collision: a solid body and, when the grid has one-way tops, a second
## body for them, so a drop-through can switch the one-way body alone. Both are on the
## world layer, in room px (the grid's origin applied). The caller adds them to the tree.
static func build(grid: TerrainGrid, data: RoomTerrainData = null) -> Array[StaticBody2D]:
	var solid := _new_body(&"TerrainSolid")
	var one_way := _new_body(&"TerrainOneWay")
	for face in faces(grid, data):
		var rect := strip(grid, face)
		var shape := RectangleShape2D.new()
		shape.size = Vector2(rect.size) * TILE
		var node := CollisionShape2D.new()
		node.shape = shape
		node.position = (Vector2(rect.position + grid.origin) + Vector2(rect.size) * 0.5) * TILE
		if face.kind == TerrainGrid.ONE_WAY:
			node.one_way_collision = true
			one_way.add_child(node)
		else:
			solid.add_child(node)
	var bodies: Array[StaticBody2D] = [solid]
	if one_way.get_child_count() > 0:
		bodies.append(one_way)
	else:
		one_way.free()
	return bodies


static func _new_body(body_name: StringName) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = body_name
	body.collision_layer = 1 << (Player.LAYER_WORLD - 1)
	body.collision_mask = 0
	return body


## True when [param cell] and the cell after it, inward, are solid grid cells: the strip
## may not run past the grid's edge or into empty or one-way cells.
static func _solid_inside(grid: TerrainGrid, cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= grid.width or cell.y >= grid.height:
		return false
	return grid.cells[cell.y * grid.width + cell.x] == TerrainGrid.SOLID
