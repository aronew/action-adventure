## Gate test rooms (story 006): the double jump and the grapple found in the world, each
## opening a route. Built in code so the .tscn only attaches this script.
##
## One closed hall (walls, floor, ceiling) holding three connected areas, stacked and
## joined by open air, no doors (rooms and doors are story 007):
## 1. START, the floor: spawn and the double-jump pickup, reachable with nothing owned.
##    The DOUBLE JUMP sign stands under the left end of the mid shelf.
## 2. MID SHELF, a floating shelf 96 px up: only the double jump reaches it. The grapple
##    pickup lies on it; the GRAPPLE sign stands under the anchor.
## 3. SUMMIT, a floating shelf 270 px up: only a grapple pull to the anchor reaches it.
## The player starts with a locked [PlayerState] made here. The HUD shows what is owned.
##
## Why these sizes (values from player_config.tres, physics at 60 Hz; "h" is the feet
## height above the floor, the body is 10 x 22 px, "frame" figures are a frame-by-frame
## run of player.gd, "exact" ones the continuous formula v^2 / 2g, apex hang included):
## - A wall jump climbs any wall, so no wall is placed near a gate: both shelves float in
##   open air, 8 px thick, with nothing under them but the floor. A shelf is touched
##   (wall jump off its end, ledge nudge, corner correction past its edge) only when the
##   body overlaps its 8 px end face, i.e. feet above (shelf bottom - 22).
## - Moves: jump 330 peaks at 58.7 (frame) / 61.6 (exact); wall jump 380 at 77.6 / 81.3;
##   double jump 320 adds 54.6 / 58.0 at the apex. Air dash, coyote time and dash-jump add
##   no height (the dash holds height, the dash-jump is a 330 jump). Ledge nudge needs
##   the end-face contact above. No hittables here, so no pogo refresh.
## - Mid shelf (double-jump gate): top h 96, bottom h 88, so touching needs feet > 66.
##   Without double jump from the floor: 58.7 / 61.6, head at 80.7 / 83.6 < 88, so it is
##   never touched. With it: jump + double jump peaks at 113.3 / 119.6, 17 / 24 px over the top;
##   a run-up jump 60-140 px left of the shelf lands with the double jump pressed in a
##   window of 12-26 frames (0.2-0.43 s).
## - The side walls climb to the ceiling (h 340, feet up to 318). Wall jumps from any
##   height on them, with air dash, carry feet above h 66 at most 311 px out (frame run);
##   the mid shelf starts 347 px out of that reach's origin (360 - 5 - 8).
## - Summit (grapple gate): top h 270, bottom h 262, so touching needs feet > 240. With
##   the double jump and no grapple: from the mid shelf top 96 + 113.3 / 119.6 = 209.3 /
##   215.6; from a wall jump off a mid-shelf end then the double jump 96 + 132.2 / 139.3
##   = 228.2 / 235.3, head 257.3 < 262 at worst. From the side walls with double jump and
##   dash, feet stay above 240 at most 368 px out; the summit ends 407 px from the right
##   wall's reach origin (1540 - 5 - 1128) and is 791 px from the left one.
## - Grapple: anchor at h 278, 8 px above the summit top and 24 px left of its edge, so
##   the pull from the mid shelf rises beside the summit, not under it. grapple_range 200:
##   standing on the mid shelf it reaches from x 697 to the shelf end at 800 (182 px
##   below). Pulled from x 720-740, the feet arrive near h 257, then are flung to h 302
##   (grapple_fling_height 24 over the anchor), 32 px over the summit top, drifting right
##   at 60-90 px/s: they land on it without steering; the jump-out works too.
##   The floor is 278 px below the anchor, out of range.
## - No soft-lock: the floor runs unbroken between the side walls under both shelves,
##   and both shelves can be walked off at either end down to it (no fall damage), so
##   every area leads back to the start whatever is owned.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const ROOM_SIZE := Vector2(1540, 426)
const SPAWN_POINT := Vector2(48, 380)
const BACKGROUND_COLOR := Color(0.11, 0.12, 0.17)
const SOLID_COLOR := Color(0.32, 0.34, 0.42)
const ANCHOR_COLOR := Color(0.95, 0.85, 0.3)
const DOUBLE_JUMP_COLOR := Color(0.45, 0.8, 1.0)
const GRAPPLE_COLOR := Color(0.6, 1.0, 0.5)
const AREA_LABEL_COLOR := Color(0.7, 0.72, 0.8)
const FONT_SIZE := 8
const AREA_LABEL_SIZE := Vector2(160, 12)
const HUD_ABILITIES_POSITION := Vector2(4, 30) * DebugHud.SCALE
const HELP_TEXT := "Arrows/WASD move  Space/Z jump  Shift/C dash  E grapple (jump to launch out)\nTake the double jump, reach the shelf, take the grapple, swing to the summit."

## Solid blocks of the layout, as rectangles (floor top y 380, h = 380 - y).
const SOLIDS: Array[Rect2] = [
	Rect2(-16, 0, 1572, 40),       # ceiling, underside h 340
	Rect2(-16, 380, 1572, 46),     # floor, unbroken wall to wall
	Rect2(-16, 40, 16, 340),       # left wall
	Rect2(1540, 40, 16, 340),      # right wall
	Rect2(360, 284, 440, 8),       # mid shelf: top h 96, bottom h 88, x 360-800
	Rect2(804, 110, 316, 8),       # summit: top h 270, bottom h 262, x 804-1120
]
## Grapple anchor: h 278, 24 px left of the summit, above the mid shelf's right end.
const ANCHOR_POINT := Vector2(780, 102)
const ANCHOR_SIZE := 4.0
## Each ability: id, colour, pickup centre, gate sign foot point.
const ABILITIES := [
	[PlayerState.DOUBLE_JUMP, DOUBLE_JUMP_COLOR, Vector2(200, 364), Vector2(300, 380)],
	[PlayerState.GRAPPLE, GRAPPLE_COLOR, Vector2(520, 268), Vector2(720, 284)],
]
## Area names: text, top-left corner.
const AREA_LABELS := [
	["AREA 1  START", Vector2(64, 330)],
	["AREA 2  MID SHELF", Vector2(380, 240)],
	["AREA 3  SUMMIT (end of route)", Vector2(880, 70)],
]

var _player: Player
var _abilities: PlayerState
var _abilities_label: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	for rect in SOLIDS:
		_add_solid(rect)

	var anchor := Node2D.new()
	anchor.position = ANCHOR_POINT
	anchor.add_to_group(Player.GROUP_GRAPPLE_ANCHOR)
	var anchor_shape := Polygon2D.new()
	anchor_shape.polygon = PackedVector2Array([Vector2(0, -ANCHOR_SIZE), Vector2(ANCHOR_SIZE, 0),
			Vector2(0, ANCHOR_SIZE), Vector2(-ANCHOR_SIZE, 0)])
	anchor_shape.color = ANCHOR_COLOR
	anchor.add_child(anchor_shape)
	add_child(anchor)

	_abilities = PlayerState.new()
	_player = PLAYER_SCENE.instantiate()
	_player.player_state = _abilities
	_player.position = SPAWN_POINT
	add_child(_player)

	var camera := PlayerCamera.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	_player.add_child(camera)
	camera.setup(_player)

	for entry in ABILITIES:
		var gate := AbilityGate.new()
		gate.ability = entry[0]
		gate.color = entry[1]
		gate.player_state = _abilities
		gate.position = entry[3]
		add_child(gate)
		var pickup := AbilityPickup.new()
		pickup.ability = entry[0]
		pickup.color = entry[1]
		pickup.player_state = _abilities
		pickup.position = entry[2]
		add_child(pickup)

	for entry in AREA_LABELS:
		var area_label := Label.new()
		area_label.position = entry[1]
		area_label.size = AREA_LABEL_SIZE
		area_label.add_theme_font_size_override(&"font_size", FONT_SIZE)
		area_label.add_theme_color_override(&"font_color", AREA_LABEL_COLOR)
		area_label.text = entry[0]
		add_child(area_label)

	var hud := CanvasLayer.new()
	var help := Label.new()
	help.position = Vector2(4, 2) * DebugHud.SCALE
	help.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	help.text = HELP_TEXT
	hud.add_child(help)
	_abilities_label = Label.new()
	_abilities_label.position = HUD_ABILITIES_POSITION
	_abilities_label.add_theme_font_size_override(&"font_size", DebugHud.FONT_SIZE)
	hud.add_child(_abilities_label)
	add_child(hud)
	_abilities.abilities_changed.connect(_on_abilities_changed)
	_on_abilities_changed()


func _on_abilities_changed() -> void:
	_abilities_label.text = "Double jump: %s    Grapple: %s" % [
			"OWNED" if _abilities.has_double_jump else "locked",
			"OWNED" if _abilities.has_grapple else "locked"]


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
