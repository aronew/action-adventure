@tool
## A room edge or doorway the Seeker walks through to reach another room. Place it at
## the edge of the room in the editor; [member size] is its trigger box (world px).
## Arriving through it, the Seeker appears at [member arrive_offset] from it, inside the
## room, facing away from the edge.
class_name RoomExit
extends Area2D

## This exit's id; other rooms name it as their target.
@export var exit_id: StringName = &"left"
## The room scene this exit leads to.
@export_file("*.tscn") var target_room := ""
## The exit id to arrive at in [member target_room].
@export var target_exit: StringName = &"right"
## Trigger box size, world px.
@export var size := Vector2(16, 72):
	set(value):
		size = value
		_update_shape()
		queue_redraw()
## Where the Seeker stands when arriving through this exit, relative to it.
@export var arrive_offset := Vector2(32, 0)

## Set by the room: the Seeker, ignored until it has left the box it arrived in.
var player: Player
var _armed := false
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = Player.LAYER_PLAYER
	monitorable = false
	_update_shape()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_arm_later()


func _arm_later() -> void:
	await get_tree().create_timer(0.3).timeout
	if player != null and overlaps_body(player):
		return
	_armed = true


func _update_shape() -> void:
	if _shape == null:
		_shape = CollisionShape2D.new()
		_shape.shape = RectangleShape2D.new()
		add_child(_shape, false, Node.INTERNAL_MODE_FRONT)
	(_shape.shape as RectangleShape2D).size = size


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(-size * 0.5, size), Color(0.3, 0.8, 1.0, 0.35))
		draw_circle(arrive_offset, 3.0, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, -size * 0.5 + Vector2(0, -2), String(exit_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 8)


func _on_body_entered(body: Node2D) -> void:
	if not _armed or body != player or target_room.is_empty():
		return
	if player.state == Player.State.DEAD:
		return
	_armed = false
	RegionTravel.go(get_tree(), player, target_room, target_exit)


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		_armed = true
