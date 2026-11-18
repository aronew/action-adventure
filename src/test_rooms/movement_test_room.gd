## Blank room for trying every Seeker movement move (story 001) and melee attack
## (story 002). Built in code so the .tscn only attaches this script.
##
## Left to right: floor, a 128 px gap (needs the double jump), a tall wall to
## wall-slide on and wall-jump over, a ladder up to a ledge, a grapple anchor, a block with a 16 px
## gap under it (crouch), and a door that emits door_entered. Three [HitTarget]
## dummies for the attacks: one on the floor, one high above it (up attack) and one in
## the air over the second floor (jump and pogo off it with down + X). A [TrainingDummy]
## with a guard sits on the first floor right of the floor target, for the guard-break
## (story 003): wear its guard down, or hold X for a charged heavy to break it.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const DUMMY_SCENE := preload("res://src/test_rooms/training_dummy.tscn")
const SPAWN_POINT := Vector2(64, 224)
const RESPAWN_BELOW_Y := 420.0
const ROOM_SIZE := Vector2(1516, 270)
const BACKGROUND_COLOR := Color(0.13, 0.14, 0.2)
const SOLID_COLOR := Color(0.32, 0.34, 0.42)
const LADDER_COLOR := Color(0.3, 0.55, 0.3, 0.6)
const DOOR_COLOR := Color(0.55, 0.4, 0.25)
const ANCHOR_COLOR := Color(0.95, 0.85, 0.3)
const HELP_TEXT := "Arrows/WASD move  Space/Z jump x2 (wall: wall jump)  Shift/C dash  Down crouch  Up door  E grapple (jump to launch out)\nX attack x3 (tap)  hold X heavy  Up+X up attack  air: X jump attack, Down+X pogo"
const HIT_LABEL_POSITION := Vector2(4, 36)
const FLOOR_TARGET := Rect2(188, 192, 24, 32)
const HIGH_TARGET := Rect2(288, 162, 24, 20)
const POGO_TARGET := Rect2(586, 160, 28, 16)
const DUMMY_TARGET := Rect2(358, 184, 28, 40)

var _player: Player
var _label: Label
var _hit_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)

	_add_solid(Rect2(-16, 0, 16, 270))       # left wall
	_add_solid(Rect2(0, 224, 400, 46))       # floor before the gap
	_add_solid(Rect2(528, 224, 988, 46))     # floor after the gap
	_add_solid(Rect2(700, 64, 16, 160))      # wall-slide wall
	_add_solid(Rect2(896, 96, 204, 16))      # ledge at the top of the ladder
	_add_solid(Rect2(1180, 96, 80, 112))     # low block, 16 px clearance under it
	_add_solid(Rect2(1500, 0, 16, 224))      # right wall
	_add_area(Rect2(872, 96, 16, 128), Player.GROUP_CLIMBABLE, LADDER_COLOR)
	_add_area(Rect2(1328, 192, 24, 32), Player.GROUP_DOOR, DOOR_COLOR)

	var anchor := Node2D.new()
	anchor.position = Vector2(1160, 80)
	anchor.add_to_group(Player.GROUP_GRAPPLE_ANCHOR)
	var anchor_shape := Polygon2D.new()
	anchor_shape.polygon = PackedVector2Array([Vector2(0, -4), Vector2(4, 0), Vector2(0, 4), Vector2(-4, 0)])
	anchor_shape.color = ANCHOR_COLOR
	anchor.add_child(anchor_shape)
	add_child(anchor)

	_player = PLAYER_SCENE.instantiate()
	_player.position = SPAWN_POINT
	_player.door_entered.connect(_on_player_door_entered)
	add_child(_player)

	var camera := PlayerCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	_player.add_child(camera)
	camera.setup(_player)

	for rect in [FLOOR_TARGET, HIGH_TARGET, POGO_TARGET]:
		var target := HitTarget.new()
		target.size = rect.size
		target.position = rect.get_center()
		add_child(target)
	var dummy: TrainingDummy = DUMMY_SCENE.instantiate()
	dummy.size = DUMMY_TARGET.size
	dummy.position = DUMMY_TARGET.get_center()
	add_child(dummy)
	_player.combat.hit_landed.connect(_on_player_hit)

	var hud := CanvasLayer.new()
	_label = Label.new()
	_label.position = Vector2(4, 2)
	_label.add_theme_font_size_override(&"font_size", 8)
	_label.text = HELP_TEXT
	hud.add_child(_label)
	_hit_label = Label.new()
	_hit_label.position = HIT_LABEL_POSITION
	_hit_label.add_theme_font_size_override(&"font_size", 8)
	hud.add_child(_hit_label)
	add_child(hud)


func _physics_process(_delta: float) -> void:
	if _player.global_position.y > RESPAWN_BELOW_Y:
		_player.global_position = SPAWN_POINT
		_player.velocity = Vector2.ZERO


func _on_player_door_entered(door: Area2D) -> void:
	_label.text = HELP_TEXT + "\ndoor_entered: " + str(door.name)
	_player.resume_from_door()


func _on_player_hit(target: Node2D, attack: String, damage: float) -> void:
	if target is HitTarget:
		(target as HitTarget).register_hit(attack, damage)
	elif target is TrainingDummy:
		(target as TrainingDummy).register_hit(attack, damage, _player.combat.heavy_charged)
	_hit_label.text = "hit_landed: %s %d" % [attack, int(damage)]


func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.add_child(_make_collision(rect.size))
	body.add_child(_make_polygon(rect.size, SOLID_COLOR))
	add_child(body)


func _add_area(rect: Rect2, group: StringName, color: Color) -> void:
	var area := Area2D.new()
	area.position = rect.get_center()
	area.collision_layer = Player.LAYER_INTERACTABLE
	area.collision_mask = 0
	area.add_to_group(group)
	area.add_child(_make_collision(rect.size))
	area.add_child(_make_polygon(rect.size, color))
	add_child(area)


func _make_collision(size: Vector2) -> CollisionShape2D:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	return collision


func _make_polygon(size: Vector2, color: Color) -> Polygon2D:
	var half := size * 0.5
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
	polygon.color = color
	return polygon
