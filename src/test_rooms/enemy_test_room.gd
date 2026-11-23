## Test run for the three normal enemy types (story 004). Built in code so the .tscn only
## attaches this script.
##
## One long room walked left to right: two Grunts (plain) on the first floor, a step up
## to a Grunt and a Skitter (fast), a raised platform with two Skitters, then a wide
## arena where a Brute (heavy hitter) stands guard. The Brute is the first tougher enemy,
## about a minute in, per the brief's Challenge. Every enemy telegraphs its attack: the
## body heats to orange, a "!" shows and its reach fills in before it can hurt.
##
## The HUD shows the player's health. At zero the Seeker plays Death; once it has played,
## the room reloads (the real respawn at a save point is story 007).
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const ENEMY_SCENE := preload("res://src/enemies/enemy.tscn")
const GRUNT := preload("res://src/enemies/enemy_grunt.tres")
const SKITTER := preload("res://src/enemies/enemy_skitter.tres")
const BRUTE := preload("res://src/enemies/enemy_brute.tres")
const SPAWN_POINT := Vector2(48, 224)
const ROOM_SIZE := Vector2(3400, 270)
const RELOAD_DELAY := 1.0
const BACKGROUND_COLOR := Color(0.12, 0.12, 0.17)
const SOLID_COLOR := Color(0.32, 0.34, 0.42)
const HEALTH_BAR_SIZE := Vector2(100, 6) * DebugHud.SCALE
const HEALTH_BAR_POSITION := Vector2(4, 30) * DebugHud.SCALE
const HEALTH_BACK_COLOR := Color(0.1, 0.1, 0.1)
const HEALTH_COLOR := Color(0.85, 0.25, 0.25)
## The heal meter bar, under the health bar.
const METER_BAR_SIZE := Vector2(100, 3) * DebugHud.SCALE
const METER_BAR_POSITION := HEALTH_BAR_POSITION + Vector2(0, 8) * DebugHud.SCALE
const METER_COLOR := Color(0.95, 0.85, 0.45)
const METER_FILLING_COLOR := Color(0.55, 0.5, 0.35)
const HELP_TEXT := "Arrows/WASD move  Space/Z jump  Shift/C dash  X attack (hold: heavy)  E grapple  hold R heal (meter full)\nEnemies wind up (orange, \"!\") before they hit. The Brute's swing can't be interrupted: dodge it."

## Solid blocks of the layout, as rectangles.
const SOLIDS: Array[Rect2] = [
	Rect2(-16, 0, 16, 270),        # left wall
	Rect2(0, 224, 900, 46),        # first floor
	Rect2(900, 192, 700, 78),      # step up
	Rect2(1600, 224, 300, 46),     # dip
	Rect2(1900, 160, 500, 110),    # raised platform
	Rect2(1820, 192, 80, 16),      # ledge up to the platform
	Rect2(2400, 224, 1000, 46),    # arena floor
	Rect2(3384, 0, 16, 224),       # right wall
]
## Enemies: type and feet point.
const ENEMIES := [
	[GRUNT, Vector2(420, 224)],
	[GRUNT, Vector2(720, 224)],
	[GRUNT, Vector2(1120, 192)],
	[SKITTER, Vector2(1420, 192)],
	[SKITTER, Vector2(2080, 160)],
	[SKITTER, Vector2(2300, 160)],
	[BRUTE, Vector2(2950, 224)],
]

var _player: Player
var _health_fill: ColorRect
var _status: Label
var _meter_fill: ColorRect


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	for rect in SOLIDS:
		_add_solid(rect)

	_player = PLAYER_SCENE.instantiate()
	_player.position = SPAWN_POINT
	_player.door_entered.connect(func(_door: Area2D) -> void: _player.resume_from_door())
	_player.damaged.connect(_on_player_damaged)
	_player.healed.connect(func(_amount: float, now: float) -> void: _on_player_damaged(0.0, now))
	_player.died.connect(_on_player_died)
	add_child(_player)

	var camera := PlayerCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	_player.add_child(camera)
	camera.setup(_player)

	for entry in ENEMIES:
		var enemy: EnemyBase = ENEMY_SCENE.instantiate()
		enemy.config = entry[0]
		enemy.target = _player
		enemy.position = entry[1]
		add_child(enemy)

	_build_hud()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	var help := Label.new()
	help.position = Vector2(4, 2) * DebugHud.SCALE
	help.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	help.text = HELP_TEXT
	hud.add_child(help)

	var back := ColorRect.new()
	back.color = HEALTH_BACK_COLOR
	back.position = HEALTH_BAR_POSITION
	back.size = HEALTH_BAR_SIZE
	hud.add_child(back)
	_health_fill = ColorRect.new()
	_health_fill.color = HEALTH_COLOR
	_health_fill.position = HEALTH_BAR_POSITION
	_health_fill.size = HEALTH_BAR_SIZE
	hud.add_child(_health_fill)

	_status = Label.new()
	_status.position = HEALTH_BAR_POSITION + Vector2(HEALTH_BAR_SIZE.x + 6, -4) * DebugHud.SCALE
	_status.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	hud.add_child(_status)
	var meter_back := ColorRect.new()
	meter_back.color = HEALTH_BACK_COLOR
	meter_back.position = METER_BAR_POSITION
	meter_back.size = METER_BAR_SIZE
	hud.add_child(meter_back)
	_meter_fill = ColorRect.new()
	_meter_fill.position = METER_BAR_POSITION
	_meter_fill.size = Vector2(0, METER_BAR_SIZE.y)
	hud.add_child(_meter_fill)
	_player.heal_meter.changed.connect(_on_meter_changed)
	_on_meter_changed(_player.heal_meter.amount, _player.heal_meter.capacity)

	_on_player_damaged(0.0, _player.health.current)
	add_child(hud)


func _on_meter_changed(amount: float, capacity: float) -> void:
	_meter_fill.size.x = METER_BAR_SIZE.x * (amount / capacity if capacity > 0.0 else 0.0)
	_meter_fill.color = METER_COLOR if _player.heal_meter.is_full() else METER_FILLING_COLOR


func _on_player_damaged(_amount: float, health_left: float) -> void:
	_health_fill.size.x = HEALTH_BAR_SIZE.x * health_left / _player.health.max_health
	_status.text = "HP %d / %d" % [int(health_left), int(_player.health.max_health)]


func _on_player_died() -> void:
	_status.text = "died: died signal emitted, reloading"
	await get_tree().create_timer(RELOAD_DELAY).timeout
	get_tree().reload_current_scene()


func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	var half := rect.size * 0.5
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
	polygon.color = SOLID_COLOR
	body.add_child(polygon)
	add_child(body)
