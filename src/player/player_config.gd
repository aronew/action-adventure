## Tuning values for the Seeker controller. Every gameplay number the player uses
## lives here and is set in player_config.tres; player.gd holds no such literals.
##
## Usage: [codeblock]
## var player: Player = preload("res://src/player/player.tscn").instantiate()
## player.config = preload("res://src/player/player_config.tres")  # optional, this is the default
## [/codeblock]
## Units: pixels and seconds at the 1x base resolution (480 x 270).
class_name PlayerConfig
extends Resource

@export_group("Run")
## Horizontal speed on the ground and in the air.
@export var run_speed: float
## Speed at which the run animation plays at 1x (the guide says about 140 px/s).
## The run animation's playback speed is run_speed / this.
@export var run_animation_reference_speed: float

@export_group("Jump")
## Downward acceleration.
@export var gravity: float
## Terminal fall speed.
@export var max_fall_speed: float
## Upward speed of a ground jump, as a positive number.
@export var jump_speed: float
## Upward speed of the double jump, as a positive number.
@export var double_jump_speed: float
## How many jumps are allowed in the air after leaving the ground (1 = double jump).
@export var air_jumps: int
## Upward speed is multiplied by this when jump is released while rising (variable jump height).
@export var jump_cut_multiplier: float
## Time after walking off a ledge during which a ground jump is still allowed.
@export var coyote_time: float
## Time a jump press is remembered before landing.
@export var jump_buffer_time: float
## How long the takeoff frame (jump frame 0) is shown after a ground jump.
@export var jump_takeoff_time: float
## While |vertical speed| is below this, the apex frames (13-14) are shown.
@export var apex_speed: float
## Landing frames and land dust only play when the fall speed on impact is at least this.
@export var land_min_fall_speed: float

@export_group("Dash")
## Duration of a dash (the guide says 0.2 to 0.3 s reads well).
@export var dash_time: float
## Horizontal speed during a dash.
@export var dash_speed: float
## Time after a dash ends before the next one may start.
@export var dash_cooldown: float
## Dashes allowed in the air before touching the ground again.
@export var air_dashes: int

@export_group("Wall slide")
## Maximum fall speed while sliding down a wall.
@export var wall_slide_speed: float

@export_group("Climb")
## Vertical speed on a ladder or vine.
@export var climb_speed: float
## Upward speed given when climbing off the top of a ladder, so the player clears the ledge.
@export var climb_top_hop_speed: float
## After jumping off a ladder, how long before the ladder can be grabbed again.
@export var climb_jump_lockout_time: float

@export_group("Body")
## Standing hitbox (the pack's README suggests 10 x 22), standing on the feet point.
@export var hitbox_size: Vector2
## Hitbox height while crouched; the width stays hitbox_size.x.
@export var crouch_hitbox_height: float
## Horizontal speed while crouched.
@export var crouch_speed: float

@export_group("Grapple")
## Furthest distance to an anchor point the player can grapple to.
@export var grapple_range: float
## Speed of the pull toward the anchor.
@export var grapple_speed: float
## The pull ends when the hand is this close to the anchor.
@export var grapple_arrive_distance: float
## Angle the throwing arm points above horizontal in the sprite (the guide says about 45).
@export var grapple_arm_angle_deg: float
## Where the hand (rope start) is, relative to the feet point, with the character facing right.
@export var grapple_hand_offset: Vector2
