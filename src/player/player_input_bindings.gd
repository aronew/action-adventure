## Registers the player's input actions in the InputMap at startup, each bound to
## keyboard keys and a gamepad button or axis. Actions already defined (for example
## later added in project.godot) are left untouched.
##
## attack, heavy, bow and cast are reserved for later stories and do nothing yet.
##
## Usage: [codeblock]
## PlayerInputBindings.register()
## if Input.is_action_just_pressed(&"jump"):
##     pass
## [/codeblock]
class_name PlayerInputBindings
extends RefCounted

## Dead zone for every registered action (stick movement below this is ignored).
const DEADZONE := 0.5

## action -> keyboard physical keys, gamepad buttons, and an optional gamepad axis
## with the direction that triggers it.
const BINDINGS := {
	"move_left": {"keys": [KEY_A, KEY_LEFT], "buttons": [JOY_BUTTON_DPAD_LEFT], "axis": JOY_AXIS_LEFT_X, "axis_value": -1.0},
	"move_right": {"keys": [KEY_D, KEY_RIGHT], "buttons": [JOY_BUTTON_DPAD_RIGHT], "axis": JOY_AXIS_LEFT_X, "axis_value": 1.0},
	"move_up": {"keys": [KEY_W, KEY_UP], "buttons": [JOY_BUTTON_DPAD_UP], "axis": JOY_AXIS_LEFT_Y, "axis_value": -1.0},
	"move_down": {"keys": [KEY_S, KEY_DOWN], "buttons": [JOY_BUTTON_DPAD_DOWN], "axis": JOY_AXIS_LEFT_Y, "axis_value": 1.0},
	"crouch": {"keys": [KEY_S, KEY_DOWN], "buttons": [JOY_BUTTON_DPAD_DOWN], "axis": JOY_AXIS_LEFT_Y, "axis_value": 1.0},
	"jump": {"keys": [KEY_SPACE], "buttons": [JOY_BUTTON_A]},
	"dash": {"keys": [KEY_SHIFT], "buttons": [JOY_BUTTON_RIGHT_SHOULDER]},
	"interact": {"keys": [KEY_E], "buttons": [JOY_BUTTON_B]},
	"grapple": {"keys": [KEY_Q], "buttons": [JOY_BUTTON_LEFT_SHOULDER]},
	"attack": {"keys": [KEY_J], "buttons": [JOY_BUTTON_X]},
	"heavy": {"keys": [KEY_K], "buttons": [JOY_BUTTON_Y]},
	"bow": {"keys": [KEY_L], "buttons": [], "axis": JOY_AXIS_TRIGGER_RIGHT, "axis_value": 1.0},
	"cast": {"keys": [KEY_I], "buttons": [], "axis": JOY_AXIS_TRIGGER_LEFT, "axis_value": 1.0},
}


## Adds every action in BINDINGS to the InputMap. Safe to call more than once.
static func register() -> void:
	for action in BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, DEADZONE)
		var binding: Dictionary = BINDINGS[action]
		for key in binding["keys"]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = key
			key_event.device = -1
			InputMap.action_add_event(action, key_event)
		for button in binding["buttons"]:
			var button_event := InputEventJoypadButton.new()
			button_event.button_index = button
			button_event.device = -1
			InputMap.action_add_event(action, button_event)
		if binding.has("axis"):
			var motion_event := InputEventJoypadMotion.new()
			motion_event.axis = binding["axis"]
			motion_event.axis_value = binding["axis_value"]
			motion_event.device = -1
			InputMap.action_add_event(action, motion_event)
