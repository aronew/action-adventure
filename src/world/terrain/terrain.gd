## A built room's terrain (ADR-0001): holds the grid and its data, owns the collision
## bodies [TerrainBuilder] makes from them, and answers which material a face has at a
## contact. Put it at the room's top-left corner; positions it takes are in its own px.
##
## Usage: [codeblock]
## var terrain := Terrain.new()
## add_child(terrain)
## terrain.build(TerrainGrid.from_rows(rows), data)
## # after a wall contact, with the body's rect in the terrain's px:
## var materials := terrain.face_materials(body_rect, collision.get_normal())
## [/codeblock]
class_name Terrain
extends Node2D

## How far past the contact face a lookup probes into the solid (game px); covers the
## physics engine's contact margin (0.08 px) with room to spare.
const PROBE := 0.5

var grid: TerrainGrid
var data: RoomTerrainData
var _bodies: Array[StaticBody2D] = []


## Builds the collision from [param new_grid] and adds it. Call once, before the room shows.
func build(new_grid: TerrainGrid, new_data: RoomTerrainData = null) -> void:
	grid = new_grid
	data = new_data
	_bodies = TerrainBuilder.build(grid, data)
	for body in _bodies:
		add_child(body)


## True when [param collider] is one of this terrain's bodies. Check it before reading a
## material: a door, a breakable wall or a moving platform is its own body (terrain rule 4)
## and has no terrain face.
func is_terrain_collider(collider: Object) -> bool:
	return collider is StaticBody2D and _bodies.has(collider)


## The materials of the face cells [param body_rect] overlaps along a contact whose normal
## is [param normal] (pointing from the terrain towards the body), ordered along the face.
## [param body_rect] is in this node's px. The span, not a single point, is read, because
## a contact point is the body's lowest corner, not the middle of the contact. Which
## material wins where they differ is the caller's rule (ability gating).
func face_materials(body_rect: Rect2, normal: Vector2) -> PackedStringArray:
	var out := PackedStringArray()
	if grid == null:
		return out
	var tile := float(TerrainBuilder.TILE)
	var origin := Vector2(grid.origin)
	if absf(normal.x) >= absf(normal.y):
		# A wall: the solid is on the side the normal points away from.
		var side := TerrainBuilder.Side.RIGHT if normal.x > 0.0 else TerrainBuilder.Side.LEFT
		var edge := body_rect.position.x if normal.x > 0.0 else body_rect.end.x
		var column := floori((edge - PROBE * signf(normal.x)) / tile) - int(origin.x)
		var first := floori(body_rect.position.y / tile) - int(origin.y)
		var last := floori((body_rect.end.y - 0.001) / tile) - int(origin.y)
		for row in range(first, last + 1):
			if _has_face(column, row, side):
				out.append(data.material_at(Vector2i(column, row) + grid.origin, side) if data != null
						else RoomTerrainData.PLAIN)
	else:
		var side := TerrainBuilder.Side.TOP if normal.y < 0.0 else TerrainBuilder.Side.BOTTOM
		var edge := body_rect.end.y if normal.y < 0.0 else body_rect.position.y
		var row := floori((edge - PROBE * signf(normal.y)) / tile) - int(origin.y)
		var first := floori(body_rect.position.x / tile) - int(origin.x)
		var last := floori((body_rect.end.x - 0.001) / tile) - int(origin.x)
		for column in range(first, last + 1):
			if _has_face(column, row, side):
				out.append(data.material_at(Vector2i(column, row) + grid.origin, side) if data != null
						else RoomTerrainData.PLAIN)
	return out


## True when cell ([param x], [param y]) has an exposed face on [param side].
func _has_face(x: int, y: int, side: int) -> bool:
	if x < 0 or y < 0 or x >= grid.width or y >= grid.height:
		return false
	var kind := grid.kind_at(x, y)
	if kind == TerrainGrid.EMPTY:
		return false
	var neighbour := Vector2i(x, y)
	match side:
		TerrainBuilder.Side.TOP:
			neighbour.y -= 1
		TerrainBuilder.Side.BOTTOM:
			neighbour.y += 1
		TerrainBuilder.Side.LEFT:
			neighbour.x -= 1
		_:
			neighbour.x += 1
	var other := grid.kind_at(neighbour.x, neighbour.y)
	if kind == TerrainGrid.ONE_WAY:
		return side == TerrainBuilder.Side.TOP and other == TerrainGrid.EMPTY
	return other != TerrainGrid.SOLID
