## What carries over when the Seeker moves between rooms of a region: abilities, health,
## the heal meter, the exit to arrive at, and the rest spot to respawn at. Static, so a
## room scene change keeps it; [method reset] starts a new run.
##
## Usage: [codeblock]
## RegionTravel.go(get_tree(), player, "res://src/world/cinderheart/rooms/c03_kiln_hub.tscn", &"left")
## [/codeblock]
class_name RegionTravel
extends RefCounted

## The Seeker's abilities for this run.
static var player_state: PlayerState
## Health to arrive with, or a negative value for full health.
static var health := -1.0
## Heal meter fill to arrive with.
static var heal_meter := 0.0
## The exit id to arrive at in the next room, or empty to use the room's start marker.
static var arrival_exit: StringName = &""
## The room and exit id the Seeker respawns at after a death (the last rest spot used).
static var respawn_room := ""
## Relics picked up this run ("room path:marker name"), and the max health they add.
static var relics := {}
static var bonus_health := 0.0
static var respawn_exit: StringName = &""


## Starts a fresh run with no abilities.
static func reset() -> void:
	player_state = PlayerState.new()
	relics = {}
	bonus_health = 0.0
	health = -1.0
	heal_meter = 0.0
	arrival_exit = &""
	respawn_room = ""
	respawn_exit = &""


## Saves [param player]'s state and changes to [param room] (scene path), arriving at the
## exit whose id is [param exit_id].
static func go(tree: SceneTree, player: Player, room: String, exit_id: StringName) -> void:
	if player != null:
		player_state = player.player_state
		health = player.health.current
		heal_meter = player.heal_meter.amount
		player.set_physics_process(false)
	arrival_exit = exit_id
	await fade(tree, 1.0)
	var packed: PackedScene
	if ResourceLoader.load_threaded_get_status(room) == ResourceLoader.THREAD_LOAD_LOADED:
		packed = ResourceLoader.load_threaded_get(room)
	else:
		packed = load(room)
	tree.change_scene_to_packed(packed)


## Starts loading [param room] in the background so going there later doesn't stall.
static func preload_room(room: String) -> void:
	if room.is_empty() or ResourceLoader.has_cached(room):
		return
	if ResourceLoader.load_threaded_get_status(room) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(room)


## Fades the screen to [param alpha] (1 black, 0 clear) over [param time] seconds.
static func fade(tree: SceneTree, alpha: float, time := 0.18) -> void:
	if _fader == null or not is_instance_valid(_fader):
		var layer := CanvasLayer.new()
		layer.layer = 100
		_fader = ColorRect.new()
		_fader.color = Color(0, 0, 0, 1.0 - alpha)
		_fader.set_anchors_preset(Control.PRESET_FULL_RECT)
		_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_fader)
		tree.root.add_child(layer)
	var tween := tree.create_tween()
	tween.tween_property(_fader, "color:a", alpha, time)
	await tween.finished


static var _fader: ColorRect
