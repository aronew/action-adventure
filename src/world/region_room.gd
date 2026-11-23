## One room of a region, built in the editor: a "Layout" TileMapLayer you paint rock
## into, a [PaintedTerrain] that draws the biome's painted tiles over it, [RoomExit]s at
## its edges and [RoomSpawn] markers for enemies, pickups, gate signs and rest spots.
## At runtime this script adds the Seeker (at the exit it arrived through, else at the
## "Start" marker), the camera, the biome's parallax backdrop, the mood pass and a HUD.
##
## Death returns the Seeker to the last rest spot it used (else this room's start) with
## full health and an empty heal meter, after [member respawn_delay] seconds.
class_name RegionRoom
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const ENEMY_SCENE := preload("res://src/enemies/enemy.tscn")
## The game's view in world px (one screen).
const VIEW_SIZE := Vector2(480, 270)
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

## The room's name, shown on entry.
@export var room_name := "Room"
## Biome art folder (parallax/background.png, parallax/midground.png).
@export_dir var biome := "res://assets/environment/cinderheart-caldera"
## Clear colour behind everything.
@export var background_color := Color(0.08, 0.05, 0.06)
## Tint over the far layers so the play layer reads first.
@export var back_tint := Color(0.74, 0.66, 0.66)
## Whether the warm fog, embers and grade pass runs (RoomAtmosphere).
@export var mood := true
## Seconds from death to respawn.
@export var respawn_delay := 1.2

## Whether the mood pass shows; V toggles it, and the choice carries across rooms.
static var mood_on := true
## Backdrop images kept loaded across rooms, so a room change doesn't reload them.
static var _backdrops := {}

var player: Player
var _camera: PlayerCamera
var _room_size := Vector2.ZERO
var _layers: Array = []
var _mood_pass: RoomAtmosphere
var _health_fill: ColorRect
var _meter_fill: ColorRect
var _status: Label
var _title: Label
var _rest_spots: Array[Node2D] = []


func _ready() -> void:
	RenderingServer.set_default_clear_color(background_color)
	if RegionTravel.player_state == null:
		RegionTravel.reset()
	var terrain := _terrain()
	_room_size = Vector2(terrain.room_cells) * PaintedTerrain.CELL if terrain != null \
			else VIEW_SIZE
	var layout := get_node_or_null(^"Layout") as TileMapLayer
	if layout != null:
		layout.visible = false
	var world := Node2D.new()
	world.name = "Backdrop"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	world.z_index = -1
	add_child(world)
	move_child(world, 0)
	_add_back_layers(world)

	player = PLAYER_SCENE.instantiate()
	player.player_state = RegionTravel.player_state
	player.position = _arrival_point()
	add_child(player)
	if RegionTravel.bonus_health > 0.0:
		player.health.max_health += RegionTravel.bonus_health
		player.health.current = player.health.max_health
	if RegionTravel.health > 0.0:
		player.health.current = minf(RegionTravel.health, player.health.max_health)
	player.heal_meter.add(RegionTravel.heal_meter)
	player.died.connect(_on_player_died)
	for exit in _exits():
		exit.player = player

	_camera = PlayerCamera.new()
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(_room_size.x)
	_camera.limit_bottom = int(_room_size.y)
	_camera.drag_vertical_enabled = true
	_camera.drag_top_margin = 0.5
	_camera.drag_bottom_margin = 0.3
	player.add_child(_camera)
	_camera.setup(player)
	_camera.reset_smoothing.call_deferred()

	_spawn_markers()
	if mood:
		_mood_pass = RoomAtmosphere.new()
		add_child(_mood_pass)
		_mood_pass.setup(world, _camera, player, VIEW_SIZE)
		_mood_pass.set_enabled(mood_on)
	_build_hud()
	for exit in _exits():
		RegionTravel.preload_room(exit.target_room)
	RegionTravel.fade(get_tree(), 0.0, 0.25)


func _enter_tree() -> void:
	RenderingServer.frame_pre_draw.connect(_place_layers)


func _exit_tree() -> void:
	RenderingServer.frame_pre_draw.disconnect(_place_layers)


## V turns the mood pass (fog, blur, embers, colour grade) on or off, for slower machines.
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != KEY_V:
		return
	mood_on = not mood_on
	if _mood_pass != null:
		_mood_pass.set_enabled(mood_on)
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
				return exit.global_position + exit.arrive_offset
		for spot in find_children("*", "RoomSpawn", true, false):
			if spot.kind == RoomSpawn.Kind.REST and spot.name == String(wanted):
				return spot.global_position
	var start := get_node_or_null(^"Start") as Node2D
	return start.global_position if start != null else VIEW_SIZE * 0.5


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
				spot.add_child(glow)
				var label := Label.new()
				label.text = "rest (Up)"
				label.add_theme_font_size_override(&"font_size", 8)
				label.position = Vector2(-18, -REST_RADIUS * 2 - 12)
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


# --- Backdrop --------------------------------------------------------------

func _add_back_layers(parent: Node2D) -> void:
	var travel := (_room_size - VIEW_SIZE).max(Vector2.ZERO)
	var index := -30
	for entry in [["background", 0.15, false], ["midground", 0.5, true]]:
		var path: String = biome + "/parallax/%s.png" % entry[0]
		if not _backdrops.has(path):
			_backdrops[path] = load(path)
		var texture := _backdrops[path] as Texture2D
		if texture == null:
			continue
		var factor: float = entry[1]
		var repeats: bool = entry[2]
		var needed: Vector2 = VIEW_SIZE + travel * factor
		var image_scale: float = needed.y / texture.get_height() if repeats \
				else maxf(needed.x / texture.get_width(), needed.y / texture.get_height())
		var tile := texture.get_size() * image_scale
		var copies := int(ceil(needed.x / tile.x)) if repeats else 1
		var layer := Node2D.new()
		layer.z_index = index
		layer.modulate = back_tint
		for i in copies:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.scale = Vector2.ONE * image_scale
			sprite.position = Vector2(i * tile.x, 0)
			sprite.flip_h = i % 2 == 1
			layer.add_child(sprite)
		parent.add_child(layer)
		index += 10
		var size := Vector2(tile.x * copies, tile.y)
		_layers.append([layer, factor, _room_size * 0.5 * factor - size * 0.5])


func _place_layers() -> void:
	if _camera == null or not _camera.is_inside_tree():
		return
	var center := _camera.get_screen_center_position()
	for entry in _layers:
		var factor: float = entry[1]
		entry[0].position = center * (1.0 - factor) + entry[2]
	if _mood_pass != null:
		_mood_pass.follow(center)


# --- HUD -------------------------------------------------------------------

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 2
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
