## Dummy target for trying the Seeker's melee attacks (story 002). It has no health and
## no guard: each hit flashes it white and bumps a counter shown above it, so a person
## can see every hit and that one swing hits once.
##
## Usage: [codeblock]
## var target := HitTarget.new()
## target.size = Vector2(24, 32)
## target.position = Vector2(200, 208)
## add_child(target)
## player.combat.hit_landed.connect(func(hit, attack, damage): if hit is HitTarget: hit.register_hit(attack, damage))
## [/codeblock]
class_name HitTarget
extends Area2D

const BASE_COLOR := Color(0.75, 0.3, 0.3)
const FLASH_COLOR := Color(1.0, 1.0, 1.0)
const FLASH_TIME := 0.15
const LABEL_WIDTH := 80.0
const LABEL_FONT_SIZE := 8

## Size of the target box in pixels. Set before adding to the tree.
var size := Vector2(24.0, 32.0)
## Number of hits received so far (read only).
var hit_count := 0

var _flash_left := 0.0
var _body: Polygon2D
var _label: Label


func _ready() -> void:
	collision_layer = PlayerCombat.LAYER_HITTABLE
	collision_mask = 0
	monitoring = false
	add_to_group(PlayerCombat.GROUP_HITTABLE)

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	var half := size * 0.5
	_body = Polygon2D.new()
	_body.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
	_body.color = BASE_COLOR
	add_child(_body)

	_label = Label.new()
	_label.size = Vector2(LABEL_WIDTH, 12.0)
	_label.position = Vector2(-LABEL_WIDTH * 0.5, -half.y - 12.0)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", LABEL_FONT_SIZE)
	_label.text = "hits: 0"
	add_child(_label)


func _process(delta: float) -> void:
	_flash_left = maxf(_flash_left - delta, 0.0)
	_body.color = BASE_COLOR.lerp(FLASH_COLOR, _flash_left / FLASH_TIME)


## Counts one hit and flashes. [param attack] and [param damage] are shown on the label.
func register_hit(attack: String, damage: float) -> void:
	hit_count += 1
	_flash_left = FLASH_TIME
	_label.text = "hits: %d (%s %d)" % [hit_count, attack, int(damage)]
