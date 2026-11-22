## The first-region boss arena (story 005, design/game-brief.md "Goal & fail state": reach
## and beat the region's final boss). Built in code so the .tscn only attaches this script.
##
## A flat arena between two walls. The Seeker spawns at the left; the [Boss] stands at the
## right and is idle until the player crosses the trigger line at [constant FIGHT_TRIGGER_X].
## The HUD shows the player's health and, once the fight begins, the boss's health and guard
## (GUARDED, BROKEN or RECOVERING; a broken guard is the damage window).
##
## The player dying reloads the arena after [constant RELOAD_DELAY], which resets the boss
## and restarts the fight. That reload stands in for the real respawn at a save point
## (story 007), the same stand-in the enemy test room uses.
##
## Beating the boss sets [member is_boss_defeated] and emits [signal boss_defeated]; play
## simply goes on (no completion screen: the user's call, it is a metroidvania). Saves and
## gates in story 007 read the flag. More regions are out of scope for the project.
class_name BossArena
extends Node2D

## Emitted once, when the boss dies.
signal boss_defeated

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const BOSS_CONFIG := preload("res://src/enemies/boss/boss_config.tres")
## Feet point of the player's spawn and of the boss.
const SPAWN_POINT := Vector2(48, 224)
const BOSS_SPAWN := Vector2(820, 224)
## The fight begins when the player's x reaches this line, near the entrance.
const FIGHT_TRIGGER_X := 160.0
const ARENA_SIZE := Vector2(960, 270)
const RELOAD_DELAY := 1.0
const BACKGROUND_COLOR := Color(0.1, 0.09, 0.14)
const SOLID_COLOR := Color(0.32, 0.3, 0.4)
const HELP_POSITION := Vector2(4, 256) * DebugHud.SCALE
const HELP_TEXT := "Move arrows/WASD  Jump Space/Z  Dash Shift/C  Attack X (hold: heavy)\nGuarded, the boss shrugs hits off.\nBreak its guard (a charged heavy does it at once), then hit hard."
const FONT_SIZE := DebugHud.FONT_SIZE

const PLAYER_BAR_POSITION := Vector2(4, 4) * DebugHud.SCALE
const PLAYER_BAR_SIZE := Vector2(100, 6) * DebugHud.SCALE
const PLAYER_HEALTH_COLOR := Color(0.85, 0.25, 0.25)
const BAR_BACK_COLOR := Color(0.1, 0.1, 0.1)
const BOSS_BAR_POSITION := Vector2(200, 11) * DebugHud.SCALE
const BOSS_BAR_SIZE := Vector2(200, 7) * DebugHud.SCALE
const BOSS_HEALTH_COLOR := Color(0.75, 0.2, 0.3)
const GUARD_BAR_POSITION := Vector2(200, 20) * DebugHud.SCALE
const GUARD_BAR_SIZE := Vector2(200, 5) * DebugHud.SCALE
const BOSS_NAME_POSITION := Vector2(200, 0) * DebugHud.SCALE
const BOSS_HEALTH_TEXT_POSITION := Vector2(404, 8) * DebugHud.SCALE
const GUARD_TEXT_POSITION := Vector2(404, 17) * DebugHud.SCALE
## Indexed by [enum GuardComponent.State]: GUARDED, BROKEN, RECOVERING.
const GUARD_STATE_TEXT: Array[String] = ["GUARDED", "BROKEN", "RECOVERING"]
const GUARD_STATE_COLORS: Array[Color] = [Color(0.4, 0.65, 1.0), Color(1.0, 0.85, 0.2),
		Color(0.75, 0.75, 0.85)]
const GUARD_BACK_COLORS: Array[Color] = [Color(0.1, 0.1, 0.1), Color(0.6, 0.45, 0.05),
		Color(0.1, 0.1, 0.1)]
const DIED_TEXT := "defeated: restarting the fight"

## Solid blocks of the layout, as rectangles.
const SOLIDS: Array[Rect2] = [
	Rect2(-16, 0, 16, 270),        # left wall
	Rect2(0, 224, 960, 46),        # floor
	Rect2(960, 0, 16, 270),        # right wall
]

## True once the boss is beaten (read only).
var is_boss_defeated := false

var _player: Player
var _boss: Boss
var _player_fill: ColorRect
var _player_status: Label
var _boss_hud: Control
var _boss_health_fill: ColorRect
var _boss_health_text: Label
var _guard_fill: ColorRect
var _guard_back: ColorRect
var _guard_text: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	for rect in SOLIDS:
		_add_solid(rect)

	_player = PLAYER_SCENE.instantiate()
	_player.position = SPAWN_POINT
	_player.damaged.connect(_on_player_damaged)
	_player.died.connect(_on_player_died)
	add_child(_player)

	var camera := PlayerCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ARENA_SIZE.x)
	camera.limit_bottom = int(ARENA_SIZE.y)
	_player.add_child(camera)
	camera.setup(_player)

	_boss = Boss.new()
	_boss.config = BOSS_CONFIG
	_boss.target = _player
	_boss.position = BOSS_SPAWN
	_boss.died.connect(_on_boss_died)
	add_child(_boss)

	_build_hud()


func _physics_process(_delta: float) -> void:
	if _player.global_position.x >= FIGHT_TRIGGER_X:
		_boss.begin_fight()
		_boss_hud.visible = true
		set_physics_process(false)


func _process(_delta: float) -> void:
	if not is_instance_valid(_boss):
		return
	_boss_health_fill.size.x = BOSS_BAR_SIZE.x * _boss.health / _boss.config.max_health
	_boss_health_text.text = "%d / %d" % [ceili(_boss.health), int(_boss.config.max_health)]
	var guard := _boss.guard
	_guard_fill.size.x = GUARD_BAR_SIZE.x * guard.meter / guard.config.max_guard
	_guard_text.text = GUARD_STATE_TEXT[guard.state]
	_guard_text.add_theme_color_override(&"font_color", GUARD_STATE_COLORS[guard.state])
	_guard_back.color = GUARD_BACK_COLORS[guard.state]


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	_add_label(hud, HELP_POSITION).text = HELP_TEXT
	_player_fill = _add_bar(hud, PLAYER_BAR_POSITION, PLAYER_BAR_SIZE, PLAYER_HEALTH_COLOR)
	_player_status = _add_label(hud, PLAYER_BAR_POSITION + Vector2(PLAYER_BAR_SIZE.x + 6.0 * DebugHud.SCALE, -4.0 * DebugHud.SCALE))

	_boss_hud = Control.new()
	_boss_hud.visible = false
	hud.add_child(_boss_hud)
	var boss_name := _add_label(_boss_hud, BOSS_NAME_POSITION)
	boss_name.text = _boss.config.display_name
	_boss_health_fill = _add_bar(_boss_hud, BOSS_BAR_POSITION, BOSS_BAR_SIZE, BOSS_HEALTH_COLOR)
	_boss_health_text = _add_label(_boss_hud, BOSS_HEALTH_TEXT_POSITION)
	_guard_fill = _add_bar(_boss_hud, GUARD_BAR_POSITION, GUARD_BAR_SIZE, GUARD_STATE_COLORS[0])
	_guard_back = _guard_fill.get_parent() as ColorRect
	_guard_text = _add_label(_boss_hud, GUARD_TEXT_POSITION)
	add_child(hud)
	_on_player_damaged(0.0, _player.health.current)


## A bar on [param parent]: a dark back with a coloured fill on top. Returns the fill, whose
## width the caller sets; its parent is the back.
func _add_bar(parent: Node, bar_position: Vector2, bar_size: Vector2, color: Color) -> ColorRect:
	var back := ColorRect.new()
	back.color = BAR_BACK_COLOR
	back.position = bar_position
	back.size = bar_size
	parent.add_child(back)
	var fill := ColorRect.new()
	fill.color = color
	fill.size = bar_size
	back.add_child(fill)
	return fill


func _add_label(parent: Node, label_position: Vector2) -> Label:
	var label := Label.new()
	label.position = label_position
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	parent.add_child(label)
	return label


func _on_player_damaged(_amount: float, health_left: float) -> void:
	_player_fill.size.x = PLAYER_BAR_SIZE.x * health_left / _player.health.max_health
	_player_status.text = "HP %d / %d" % [int(health_left), int(_player.health.max_health)]


## Stand-in for the respawn (story 007): reload the arena, which resets the boss and the
## fight.
func _on_player_died() -> void:
	_player_status.text = DIED_TEXT
	await get_tree().create_timer(RELOAD_DELAY).timeout
	get_tree().reload_current_scene()


func _on_boss_died(_boss: EnemyBase) -> void:
	is_boss_defeated = true
	boss_defeated.emit()


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
