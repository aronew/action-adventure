## The marker at the start of a gated route (story 006): a signpost naming the ability
## the route needs, dim while [member player_state] lacks it and lit once it is owned.
## It only shows the gate: the gate itself is the level geometry (a ledge out of reach
## without the ability). Built in code; the origin is the foot of the post.
##
## Usage: [codeblock]
## var gate := AbilityGate.new()
## gate.ability = PlayerState.DOUBLE_JUMP
## gate.color = Color(0.45, 0.8, 1.0)
## gate.player_state = player.player_state
## gate.position = Vector2(300, 380)
## add_child(gate)
## [/codeblock]
class_name AbilityGate
extends Node2D

const POST_SIZE := Vector2(2, 18)
const PLATE_SIZE := Vector2(64, 14)
const PLATE_BORDER := 1.0
const PLATE_DARKEN := 0.65
const GLOW_GROW := 6.0
const GLOW_ALPHA := 0.4
const DIM_BRIGHTNESS := 0.35
const FONT_SIZE := 8

## Ability the gated route needs ([constant PlayerState.DOUBLE_JUMP] or
## [constant PlayerState.GRAPPLE]).
@export var ability: StringName
## Placeholder colour of the sign when lit.
@export var color := Color.WHITE
## The player's ability state, read and listened to. Set before adding to the tree.
var player_state: PlayerState

var _glow: Polygon2D


func _ready() -> void:
	var plate_center := Vector2(0.0, -POST_SIZE.y - PLATE_SIZE.y * 0.5)
	add_child(_make_rect(Vector2(0.0, -POST_SIZE.y * 0.5), POST_SIZE, color.darkened(PLATE_DARKEN)))

	var glow_material := CanvasItemMaterial.new()
	glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow = _make_rect(plate_center, PLATE_SIZE + Vector2.ONE * GLOW_GROW * 2.0, Color(color, GLOW_ALPHA))
	_glow.material = glow_material
	add_child(_glow)
	add_child(_make_rect(plate_center, PLATE_SIZE, color))
	add_child(_make_rect(plate_center, PLATE_SIZE - Vector2.ONE * PLATE_BORDER * 2.0, color.darkened(PLATE_DARKEN)))

	var label := Label.new()
	label.size = PLATE_SIZE
	label.position = plate_center - PLATE_SIZE * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	label.text = String(ability).replace("_", " ").to_upper()
	add_child(label)

	player_state.abilities_changed.connect(_on_abilities_changed)
	_on_abilities_changed()


func _on_abilities_changed() -> void:
	var owned := player_state.owns(ability)
	modulate = Color.WHITE if owned else Color(DIM_BRIGHTNESS, DIM_BRIGHTNESS, DIM_BRIGHTNESS)
	_glow.visible = owned


func _make_rect(center: Vector2, size: Vector2, fill: Color) -> Polygon2D:
	var half := size * 0.5
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([center - half, center + Vector2(half.x, -half.y),
			center + half, center + Vector2(-half.x, half.y)])
	polygon.color = fill
	return polygon
