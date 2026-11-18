## Which movement abilities the Seeker owns (story 006). This is the one place ability
## ownership lives: pickups grant into it, gates and the [Player] read it, and the save
## system (story 007) stores it. A new PlayerState owns nothing.
##
## Usage: [codeblock]
## var abilities := PlayerState.new()
## abilities.abilities_changed.connect(_on_abilities_changed)
## player.player_state = abilities  # before the player enters the tree
## abilities.grant(PlayerState.DOUBLE_JUMP)
## [/codeblock]
class_name PlayerState
extends Resource

## Emitted whenever an ability flag changes, whether granted by a pickup or set directly
## (by a load, for example).
signal abilities_changed

## Ability id of the double jump.
const DOUBLE_JUMP := &"double_jump"
## Ability id of the grapple.
const GRAPPLE := &"grapple"

## True once the double jump is owned. Without it an air jump does nothing.
@export var has_double_jump := false:
	set(value):
		if value == has_double_jump:
			return
		has_double_jump = value
		abilities_changed.emit()

## True once the grapple is owned. Without it the grapple input does nothing.
@export var has_grapple := false:
	set(value):
		if value == has_grapple:
			return
		has_grapple = value
		abilities_changed.emit()


## Gives the player [param ability] ([constant DOUBLE_JUMP] or [constant GRAPPLE]).
## Emits [signal abilities_changed] only when it was not owned yet.
func grant(ability: StringName) -> void:
	match ability:
		DOUBLE_JUMP:
			has_double_jump = true
		GRAPPLE:
			has_grapple = true


## Returns true when [param ability] ([constant DOUBLE_JUMP] or [constant GRAPPLE]) is owned.
func owns(ability: StringName) -> bool:
	match ability:
		DOUBLE_JUMP:
			return has_double_jump
		GRAPPLE:
			return has_grapple
	return false
