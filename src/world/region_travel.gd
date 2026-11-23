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
static var respawn_exit: StringName = &""


## Starts a fresh run with no abilities.
static func reset() -> void:
	player_state = PlayerState.new()
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
	arrival_exit = exit_id
	tree.change_scene_to_file.call_deferred(room)
