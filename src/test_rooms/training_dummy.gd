## Training dummy for the guard-break (story 003). It is not an enemy: it only carries a
## [GuardComponent], never attacks, and refills its health when it reaches 0 so it can be
## hit forever. It shows what the guard is doing: body and guard bar are blue while
## guarded, yellow while broken (staggered) and green while recovering, a bar shows the
## guard meter and another the health, and a label shows the state and the last hit.
## Each hit also flashes the body white.
##
## Usage: [codeblock]
## var dummy: TrainingDummy = preload("res://src/test_rooms/training_dummy.tscn").instantiate()
## dummy.position = Vector2(372, 204)
## add_child(dummy)
## player.combat.hit_landed.connect(func(hit, attack, damage):
##         if hit is TrainingDummy: hit.register_hit(attack, damage, player.combat.heavy_charged))
## [/codeblock]
class_name TrainingDummy
extends Area2D

const STATE_COLORS := {
	GuardComponent.State.GUARDED: Color(0.3, 0.5, 0.85),
	GuardComponent.State.BROKEN: Color(1.0, 0.8, 0.15),
	GuardComponent.State.RECOVERING: Color(0.3, 0.8, 0.5),
}
const STATE_NAMES := {
	GuardComponent.State.GUARDED: "GUARDED",
	GuardComponent.State.BROKEN: "BROKEN",
	GuardComponent.State.RECOVERING: "RECOVERING",
}
const FLASH_COLOR := Color(1.0, 1.0, 1.0)
const FLASH_TIME := 0.15
const BAR_BACK_COLOR := Color(0.1, 0.1, 0.1)
const HEALTH_COLOR := Color(0.8, 0.25, 0.25)
const BAR_HEIGHT := 4.0
const BAR_GAP := 2.0
const LABEL_WIDTH := 120.0
const LABEL_HEIGHT := 22.0
const LABEL_FONT_SIZE := 8

## Size of the dummy box in pixels. Set before adding to the tree.
var size := Vector2(28.0, 40.0)
## The guard of this dummy, created in _ready (read only).
var guard: GuardComponent

var _flash_left := 0.0
var _last_hit := "last: none"
var _last_attack := ""
var _body: Polygon2D
var _guard_fill: ColorRect
var _health_fill: ColorRect
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
	add_child(_body)

	var guard_y := -half.y - BAR_GAP - BAR_HEIGHT
	var health_y := guard_y - BAR_GAP - BAR_HEIGHT
	_guard_fill = _make_bar(Vector2(-half.x, guard_y))
	_health_fill = _make_bar(Vector2(-half.x, health_y))
	_health_fill.color = HEALTH_COLOR

	_label = Label.new()
	_label.size = Vector2(LABEL_WIDTH, LABEL_HEIGHT)
	_label.position = Vector2(-LABEL_WIDTH * 0.5, health_y - BAR_GAP - LABEL_HEIGHT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override(&"font_size", LABEL_FONT_SIZE)
	add_child(_label)

	guard = GuardComponent.new()
	add_child(guard)
	guard.damaged.connect(_on_damaged)


func _process(delta: float) -> void:
	_flash_left = maxf(_flash_left - delta, 0.0)
	var color: Color = STATE_COLORS[guard.state]
	_body.color = color.lerp(FLASH_COLOR, _flash_left / FLASH_TIME)
	_guard_fill.color = color
	_guard_fill.size.x = size.x * guard.meter / guard.config.max_guard
	_health_fill.size.x = size.x * guard.health / guard.config.max_health
	_label.text = "%s\n%s" % [STATE_NAMES[guard.state], _last_hit]


## Passes one hit to the guard and flashes. [param attack], [param damage] and
## [param charged] are the arguments of [method GuardComponent.take_hit].
func register_hit(attack: String, damage: float, charged: bool) -> void:
	_flash_left = FLASH_TIME
	_last_attack = attack + (" (charged)" if charged else "")
	guard.take_hit(attack, damage, charged)


## Draws a bar: a dark back of the dummy's width and, on top of it, the fill that
## [method _process] resizes. Returns the fill.
func _make_bar(top_left: Vector2) -> ColorRect:
	var back := ColorRect.new()
	back.color = BAR_BACK_COLOR
	back.position = top_left
	back.size = Vector2(size.x, BAR_HEIGHT)
	add_child(back)
	var fill := ColorRect.new()
	fill.position = top_left
	fill.size = Vector2(size.x, BAR_HEIGHT)
	add_child(fill)
	return fill


func _on_damaged(amount: float, health_left: float) -> void:
	_last_hit = "%s %d -> hp %d" % [_last_attack, int(amount), int(health_left)]
	if health_left <= 0.0:
		guard.health = guard.config.max_health
