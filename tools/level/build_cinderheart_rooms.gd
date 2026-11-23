## Builds the Cinderheart room scenes from tools/level/cinderheart_rooms.json (written by
## cinderheart_layout.py). Each room becomes src/world/cinderheart/rooms/<key>.tscn: a
## RegionRoom with a painted "Layout" TileMapLayer, a PaintedTerrain, a Start marker,
## RoomExits and RoomSpawns. After building, edit the rooms in the Godot editor: paint
## or erase rock on the Layout layer and the painted art follows.
## Re-running overwrites the rooms, so once you edit a room by hand, stop rebuilding it.
## Run: godot --headless --path . -s res://tools/level/build_cinderheart_rooms.gd
extends SceneTree

const JSON_PATH := "res://tools/level/cinderheart_rooms.json"
const OUT_DIR := "res://src/world/cinderheart/rooms/"
const TILESET_PATH := "res://src/world/cinderheart/layout_tileset.tres"
const CELL := 36.0
const CONFIGS := {
	"grunt": "res://src/enemies/enemy_grunt.tres",
	"skitter": "res://src/enemies/enemy_skitter.tres",
	"brute": "res://src/enemies/enemy_brute.tres",
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var tileset := _layout_tileset()
	var rooms: Array = JSON.parse_string(FileAccess.get_file_as_string(JSON_PATH))
	for data in rooms:
		_build_room(data, tileset)
	quit()


## The layout brushes, 36 px each: tile (0, 0) is rock (dark red with an orange rim);
## tile (1, 0) is a fake wall (purple with a pink rim): drawn as rock, walk-through.
func _layout_tileset() -> TileSet:
	if ResourceLoader.exists(TILESET_PATH):
		var existing: TileSet = load(TILESET_PATH)
		var src := existing.get_source(0) as TileSetAtlasSource
		if src != null and src.has_tile(Vector2i(1, 0)):
			return existing
	var image := Image.create(72, 36, false, Image.FORMAT_RGBA8)
	for tile in 2:
		var fill := Color(0.35, 0.18, 0.16, 0.6) if tile == 0 else Color(0.35, 0.16, 0.4, 0.6)
		var rim := Color(0.9, 0.45, 0.3, 0.9) if tile == 0 else Color(0.95, 0.5, 0.9, 0.9)
		image.fill_rect(Rect2i(tile * 36, 0, 36, 36), fill)
		for i in 36:
			for e in [0, 35]:
				image.set_pixel(tile * 36 + i, e, rim)
				image.set_pixel(tile * 36 + e, i, rim)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(36, 36)
	source.create_tile(Vector2i(0, 0))
	source.create_tile(Vector2i(1, 0))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(36, 36)
	tileset.add_source(source, 0)
	ResourceSaver.save(tileset, TILESET_PATH)
	return load(TILESET_PATH)


func _build_room(data: Dictionary, tileset: TileSet) -> void:
	var root := RegionRoom.new()
	root.name = String(data["key"]).to_pascal_case()
	root.room_name = data["name"]
	var w: int = data["w"]
	var h: int = data["h"]
	var rows: Array = data["rows"]

	var layout := TileMapLayer.new()
	layout.name = "Layout"
	layout.tile_set = tileset
	root.add_child(layout)
	for y in h:
		for x in w:
			if rows[y][x] == "#":
				layout.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			elif rows[y][x] == "F":
				layout.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	var terrain := PaintedTerrain.new()
	terrain.name = "PaintedTerrain"
	terrain.room_cells = Vector2i(w, h)
	root.add_child(terrain)
	terrain.layout = layout

	var spawns := Node2D.new()
	spawns.name = "Spawns"
	root.add_child(spawns)
	var exits := Node2D.new()
	exits.name = "Exits"
	root.add_child(exits)

	var counts := {}
	for m in data["markers"]:
		var at := Vector2(m["col"] * CELL + CELL * 0.5, m["row"] * CELL)
		if m["kind"] == "start":
			var start := Marker2D.new()
			start.name = "Start"
			start.position = at + Vector2(0, -2)
			root.add_child(start)
			continue
		var spawn := RoomSpawn.new()
		var kind: String = m["kind"]
		counts[kind] = counts.get(kind, 0) + 1
		spawn.name = "%s%d" % [kind.to_pascal_case(), counts[kind]]
		spawn.position = at
		match kind:
			"enemy":
				spawn.kind = RoomSpawn.Kind.ENEMY
				spawn.enemy_config = load(CONFIGS[m["config"]])
			"ability":
				spawn.kind = RoomSpawn.Kind.ABILITY
				spawn.ability = StringName(m["ability"])
			"gate":
				spawn.kind = RoomSpawn.Kind.GATE_SIGN
				spawn.ability = StringName(m["ability"])
			"rest":
				spawn.kind = RoomSpawn.Kind.REST
			"relic":
				spawn.kind = RoomSpawn.Kind.RELIC
		spawns.add_child(spawn)

	for e in data["exits"]:
		var exit := RoomExit.new()
		exit.name = String(e["id"]).to_pascal_case()
		exit.exit_id = StringName(e["id"])
		exit.target_room = e["target"]
		exit.target_exit = StringName(e["target_exit"])
		var a: int = e["a"]
		var b: int = e["b"]
		var span := (b - a + 1) * CELL
		match e["side"]:
			"left", "right":
				var cy := (a + b + 1) * 0.5 * CELL
				var floor_y := (b + 1) * CELL - 2.0
				var left: bool = e["side"] == "left"
				exit.position = Vector2(6.0 if left else w * CELL - 6.0, cy)
				exit.size = Vector2(12, span)
				exit.arrive_offset = Vector2(40.0 if left else -40.0, floor_y - cy)
			"top":
				var cx := (a + b + 1) * 0.5 * CELL
				exit.position = Vector2(cx, 16)
				exit.size = Vector2(span, 32)
				exit.arrive_offset = Vector2(0, 30)
			"bottom":
				var cx2 := (a + b + 1) * 0.5 * CELL
				exit.position = Vector2(cx2, h * CELL - 12)
				exit.size = Vector2(span, 24)
				var col := a - 1
				var surface := h - 1
				while surface > 0 and rows[surface - 1][col] == "#":
					surface -= 1
				exit.arrive_offset = Vector2((col + 0.5) * CELL - cx2, surface * CELL - 2.0 - exit.position.y)
		exits.add_child(exit)

	_own(root, root)
	var packed := PackedScene.new()
	packed.pack(root)
	var path: String = OUT_DIR + data["key"] + ".tscn"
	var err := ResourceSaver.save(packed, path)
	print("%s -> %s (%s)" % [data["key"], path, error_string(err)])
	root.free()


func _own(node: Node, owner_node: Node) -> void:
	for child in node.get_children():
		child.owner = owner_node
		# PaintedTerrain rebuilds its own children; don't save them into the scene.
		if child is PaintedTerrain:
			continue
		_own(child, owner_node)
