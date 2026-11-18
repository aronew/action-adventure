## The "region complete" screen (story 005, design/game-brief.md "Goal & fail state": the
## goal is to beat the first region's final boss). A full-screen overlay with a title, a short
## line and a prompt; a key press restarts the current scene (the boss arena). Placeholder
## text: change the constants below. Built in code so the .tscn only attaches this script.
##
## Usage: [codeblock]
## add_child(preload("res://src/ui/region_complete.tscn").instantiate())
## [/codeblock]
class_name RegionComplete
extends CanvasLayer

const TITLE_TEXT := "Region cleared"
const LINE_TEXT := "The Region Guardian has fallen."
const PROMPT_TEXT := "Press any key to restart the arena"
const TITLE_FONT_SIZE := 24
const LINE_FONT_SIZE := 12
const PROMPT_FONT_SIZE := 10
const DIM_COLOR := Color(0.0, 0.0, 0.0, 0.75)
const TITLE_COLOR := Color(1.0, 0.9, 0.45)
const SPACING := 10
## Draws above the HUD.
const LAYER_INDEX := 10
## Seconds before a key press counts, so the fight's last key presses do not skip the screen.
const INPUT_DELAY := 1.0

var _age := 0.0


func _ready() -> void:
	layer = LAYER_INDEX
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", SPACING)
	center.add_child(column)
	_add_line(column, TITLE_TEXT, TITLE_FONT_SIZE).add_theme_color_override(&"font_color", TITLE_COLOR)
	_add_line(column, LINE_TEXT, LINE_FONT_SIZE)
	_add_line(column, PROMPT_TEXT, PROMPT_FONT_SIZE)


func _process(delta: float) -> void:
	_age += delta


func _unhandled_input(event: InputEvent) -> void:
	var is_key := event is InputEventKey or event is InputEventJoypadButton
	if _age >= INPUT_DELAY and is_key and event.is_pressed() and not event.is_echo():
		get_tree().reload_current_scene()


func _add_line(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", font_size)
	parent.add_child(label)
	return label
