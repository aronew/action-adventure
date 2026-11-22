## Terrain test room (throwaway): a room whose collision comes from the terrain builder
## (ADR-0001) instead of hand-placed rectangles, with the Seeker and the follow camera.
## It is a code-built grid of 6 px tiles: a pillar flush on a block, a staircase, a pit,
## a thin ledge, one-way platforms, a ceiling block and a tall wall whose lower right
## face is no_cling, so every kind of corner and face the builder makes can be walked.
##
## F2 shows the collision strips; the HUD names the material under a wall contact, read
## through [method Terrain.face_materials]. The controller's no_cling skip is not built
## (ability gating Open Question 2), so the wall still holds either way.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const TILE := 6
const COLUMNS := 160
const ROWS := 45
const ROOM_SIZE := Vector2(COLUMNS * TILE, ROWS * TILE)
## Feet point of the spawn: the floor's top is row 36 (y 216).
const SPAWN_POINT := Vector2(60, 216)
const FLOOR_TOP := 36
const BACKGROUND_COLOR := Color(0.1, 0.1, 0.15)
const HELP_TEXT := "Arrows/WASD move  Space/Z jump x2  Shift/C dash  F2 collision strips\nGreen faces are no_cling (tall wall, right face, lower half)."
const WALL_COLUMN := 130
const NO_CLING_FROM_ROW := 24

var _terrain: Terrain
var _view: TerrainDebugView
var _player: Player
var _contact_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	var grid := _build_grid()
	var data := _build_data()

	_view = TerrainDebugView.new()
	_view.setup(grid, data)
	add_child(_view)
	_terrain = Terrain.new()
	add_child(_terrain)
	_terrain.build(grid, data)

	_player = PLAYER_SCENE.instantiate()
	_player.position = SPAWN_POINT
	add_child(_player)
	var camera := PlayerCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	_player.add_child(camera)
	camera.setup(_player)
	_build_hud()


func _physics_process(_delta: float) -> void:
	if _player.is_on_wall():
		var rect := Rect2(_player.global_position + Vector2(-_player.config.hitbox_size.x * 0.5, -_player.config.hitbox_size.y),
				_player.config.hitbox_size)
		var materials := _terrain.face_materials(rect, _player.get_wall_normal())
		var counts := {}
		for material in materials:
			counts[material] = int(counts.get(material, 0)) + 1
		_contact_label.text = "wall contact: " + (str(counts) if not counts.is_empty() else "not terrain")
	else:
		_contact_label.text = "wall contact: none"


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		_view.set_show_strips(not _view.show_strips)


func _build_grid() -> TerrainGrid:
	var grid := TerrainGrid.new()
	grid.width = COLUMNS
	grid.height = ROWS
	grid.cells.resize(COLUMNS * ROWS)
	_fill(grid, 0, 0, COLUMNS, 3)                      # ceiling
	_fill(grid, 0, 0, 6, ROWS)                         # left wall
	_fill(grid, COLUMNS - 6, 0, 6, ROWS)               # right wall
	_fill(grid, 0, FLOOR_TOP, COLUMNS, ROWS - FLOOR_TOP)   # floor, 9 deep
	_fill(grid, 20, 30, 12, 6)                         # block on the floor
	_fill(grid, 20, 23, 6, 7)                          # pillar flush on its left face
	_fill(grid, 40, 34, 4, 2)                          # staircase
	_fill(grid, 44, 32, 4, 4)
	_fill(grid, 48, 30, 4, 6)
	_fill(grid, 60, FLOOR_TOP, 10, 6, TerrainGrid.EMPTY)   # a pit, 10 wide and 6 deep
	_fill(grid, 80, 28, 16, 2)                         # a thin ledge in the air
	_fill(grid, 100, 30, 11, 1, TerrainGrid.ONE_WAY)   # one-way platforms
	_fill(grid, 113, 24, 8, 1, TerrainGrid.ONE_WAY)
	_fill(grid, WALL_COLUMN - 5, 12, 6, FLOOR_TOP - 12)  # a tall wall, 6 wide, its top 144 px above the floor
	_fill(grid, 135, 3, 12, 7)                         # a block hanging from the ceiling
	return grid


func _build_data() -> RoomTerrainData:
	var data := RoomTerrainData.new()
	for row in range(NO_CLING_FROM_ROW, FLOOR_TOP):
		data.set_face_material(Vector2i(WALL_COLUMN, row), TerrainBuilder.Side.RIGHT, RoomTerrainData.NO_CLING)
	return data


func _fill(grid: TerrainGrid, x: int, y: int, width: int, height: int, kind := TerrainGrid.SOLID) -> void:
	for cy in range(y, y + height):
		for cx in range(x, x + width):
			grid.cells[cy * grid.width + cx] = kind


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	var help := Label.new()
	help.position = Vector2(4, 2) * DebugHud.SCALE
	help.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	help.text = HELP_TEXT
	hud.add_child(help)
	_contact_label = Label.new()
	_contact_label.position = Vector2(4, 24) * DebugHud.SCALE
	_contact_label.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	hud.add_child(_contact_label)
	add_child(hud)
