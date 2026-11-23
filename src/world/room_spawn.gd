@tool
## A marker the room turns into a live object when it loads: an enemy, an ability
## pickup, an ability gate sign or a rest spot. Placed in the editor; drawn there as a
## labelled marker. Its position is the object's foot on the floor.
class_name RoomSpawn
extends Node2D

enum Kind { ENEMY, ABILITY, GATE_SIGN, REST, RELIC }

## What this marker becomes.
@export var kind := Kind.ENEMY:
	set(value):
		kind = value
		queue_redraw()
## For an enemy: its config (grunt, skitter, brute).
@export var enemy_config: EnemyConfig
## For an ability pickup or gate sign: the ability id (dash, double_jump, grapple).
@export var ability: StringName = &"dash"
## Placeholder colour of a pickup or sign.
@export var color := Color(1.0, 0.6, 0.3)

const COLORS := [Color(1, 0.3, 0.3), Color(1, 0.8, 0.2), Color(0.4, 0.8, 1), Color(0.5, 1, 0.5), Color(1, 0.5, 0.9)]
const NAMES := ["enemy", "ability", "gate", "rest", "relic"]


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var c: Color = COLORS[kind]
	draw_rect(Rect2(-6, -20, 12, 20), Color(c, 0.5))
	var label: String = NAMES[kind]
	if kind == Kind.ENEMY and enemy_config != null:
		label = enemy_config.resource_path.get_file().get_basename().trim_prefix("enemy_")
	elif kind in [Kind.ABILITY, Kind.GATE_SIGN]:
		label += " " + String(ability)
	draw_string(ThemeDB.fallback_font, Vector2(-6, -24), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, c)
