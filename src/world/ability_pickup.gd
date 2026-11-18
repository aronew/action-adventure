## An ability found in the world (story 006): touching it grants [member ability] into
## [member player_state] once, flashes, then frees itself. Built in code.
##
## Placeholder look: a glowing, pulsing diamond in [member color] with the ability's name
## above it. When [member player_state] already owns the ability on entering the tree,
## the pickup frees itself at once, so it never shows twice.
##
## Usage: [codeblock]
## var pickup := AbilityPickup.new()
## pickup.ability = PlayerState.GRAPPLE
## pickup.color = Color(0.6, 1.0, 0.5)
## pickup.player_state = player.player_state
## pickup.position = Vector2(520, 268)
## add_child(pickup)
## [/codeblock]
class_name AbilityPickup
extends Area2D

const CORE_RADIUS := 6.0
const GLOW_RADIUS := 13.0
const GLOW_ALPHA := 0.45
const TOUCH_RADIUS := 10.0
const PULSE_SCALE := 1.3
const PULSE_TIME := 0.45
const FLASH_SCALE := 3.0
const FLASH_BRIGHTNESS := 2.5
const FLASH_TIME := 0.35
const LABEL_WIDTH := 80.0
const LABEL_HEIGHT := 12.0
const LABEL_GAP := 4.0
const FONT_SIZE := 8

## Ability granted on touch ([constant PlayerState.DOUBLE_JUMP] or
## [constant PlayerState.GRAPPLE]).
@export var ability: StringName
## Placeholder colour of the diamond and its glow.
@export var color := Color.WHITE
## The player's ability state, granted into on touch. Set before adding to the tree.
var player_state: PlayerState

var _pulse: Tween


func _ready() -> void:
	if player_state.owns(ability):
		queue_free()
		return
	collision_layer = 0
	collision_mask = Player.LAYER_PLAYER
	monitorable = false
	var shape := CircleShape2D.new()
	shape.radius = TOUCH_RADIUS
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	var glow_material := CanvasItemMaterial.new()
	glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var glow := _make_diamond(GLOW_RADIUS, Color(color, GLOW_ALPHA))
	glow.material = glow_material
	add_child(glow)
	add_child(_make_diamond(CORE_RADIUS, color))

	var label := Label.new()
	label.size = Vector2(LABEL_WIDTH, LABEL_HEIGHT)
	label.position = Vector2(-LABEL_WIDTH * 0.5, -GLOW_RADIUS - LABEL_GAP - LABEL_HEIGHT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	label.text = String(ability).replace("_", " ").to_upper()
	add_child(label)

	_pulse = create_tween().set_loops()
	_pulse.set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(glow, "scale", Vector2.ONE * PULSE_SCALE, PULSE_TIME)
	_pulse.tween_property(glow, "scale", Vector2.ONE, PULSE_TIME)
	body_entered.connect(_on_body_entered)


# Only the player's body is on Player.LAYER_PLAYER, the one layer in the mask.
func _on_body_entered(_body: Node2D) -> void:
	set_deferred(&"monitoring", false)
	player_state.grant(ability)
	_pulse.kill()
	modulate = Color(FLASH_BRIGHTNESS, FLASH_BRIGHTNESS, FLASH_BRIGHTNESS)
	var flash := create_tween().set_parallel()
	flash.tween_property(self, "scale", Vector2.ONE * FLASH_SCALE, FLASH_TIME)
	flash.tween_property(self, "modulate:a", 0.0, FLASH_TIME)
	flash.chain().tween_callback(queue_free)


func _make_diamond(radius: float, fill: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([Vector2(0, -radius), Vector2(radius, 0),
			Vector2(0, radius), Vector2(-radius, 0)])
	polygon.color = fill
	return polygon
