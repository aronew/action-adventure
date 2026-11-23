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
const ROOM_FILL_DEPTH := 5

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


func _ready() -> void:
	if RegionTravel.player_state == null:
		RegionTravel.reset()
	_read_layout()
	player_state = RegionTravel.player_state
	ledge_grab = false
	fill_depth = ROOM_FILL_DEPTH
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
	_build_hud()
	for exit in _exits():
		RegionTravel.preload_room(exit.target_room)
	RegionTravel.fade(get_tree(), 0.0, 0.25)


## Turns the Layout layer into the pipeline's grid ('#' rock, 'F' fake wall, '.' air) and
## its floating one-cell-thick rock into painted floating platforms.
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
				row[x] = "F" if layout.get_cell_atlas_coords(Vector2i(x, y)).x == 1 else "#"
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
