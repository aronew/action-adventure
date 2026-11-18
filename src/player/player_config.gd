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
## How fast the player speeds up to run_speed on the ground (px/s per second).
@export var ground_acceleration: float
## How fast the player stops on the ground with no input.
@export var ground_deceleration: float
## How fast the player reverses on the ground when pushing against the current motion.
@export var ground_turn_acceleration: float
## How fast speed above run_speed (from a dash or a fling) bleeds off on the ground.
@export var ground_overspeed_deceleration: float
## Air steering toward run_speed.
@export var air_acceleration: float
## Air slowdown with no input.
@export var air_deceleration: float
## Air reversal when pushing against the current motion. Keep it high so wall-jump
## climbs can turn back to the wall quickly.
@export var air_turn_acceleration: float
## How slowly speed above run_speed (a dash-jump or a grapple fling) bleeds off in the air.
@export var air_overspeed_deceleration: float

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
## Gravity is multiplied by this while falling, so falls are snappier than rises.
@export var fall_gravity_multiplier: float
## While jump is held and |vertical speed| is below this, gravity is reduced (apex hang).
@export var apex_hang_speed: float
## Gravity multiplier during the apex hang.
@export var apex_hang_gravity_multiplier: float
## Extra gravity multiplier while falling and holding down (fast fall).
@export var fast_fall_gravity_multiplier: float
## Terminal fall speed while fast falling.
@export var fast_fall_speed: float
## Down must be held this long in the air before the fast fall starts, so a quick
## down + attack (the pogo) does not speed up the fall.
@export var fast_fall_hold_time: float

@export_group("Dash")
## Duration of a dash (the guide says 0.2 to 0.3 s reads well).
@export var dash_time: float
## Horizontal speed during a dash.
@export var dash_speed: float
## Time after a dash ends before the next one may start.
@export var dash_cooldown: float
## Dashes allowed in the air before touching the ground again.
@export var air_dashes: int
## Fraction of dash_speed kept when a dash ends on its own, then bled off by the overspeed values.
@export var dash_end_speed_keep: float
## Fraction of dash_speed carried into a jump pressed during a dash (dash-jump).
@export var dash_jump_speed_keep: float

@export_group("Wall slide")
## Maximum fall speed while sliding down a wall.
@export var wall_slide_speed: float
## Upward speed of a jump off a wall.
@export var wall_jump_speed: float
## Horizontal speed away from the wall at the start of a wall jump.
@export var wall_jump_push_speed: float
## Time after a wall jump during which left and right do not steer, so holding
## toward the wall does not cancel the push away from it.
@export var wall_jump_control_lock_time: float

@export_group("Assists")
## A wall jump is allowed when a wall is within this many pixels, sliding or not, so a
## jump pressed just before touching the wall still wall-jumps.
@export var wall_jump_reach: float
## Time after leaving a wall slide during which a wall jump is still allowed.
@export var wall_coyote_time: float
## When the head clips a ceiling edge while rising, the player is slid sideways up to
## this many pixels to keep the jump going.
@export var corner_correction: int
## When the feet just miss a ledge while moving into it, the player is lifted up to
## this many pixels onto it.
@export var ledge_nudge: int

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
## Fraction of the pull velocity kept when the grapple lets go, so the player is flung past the anchor.
@export var grapple_fling_keep: float
## On reaching the anchor, the fling lifts the feet to this height above the anchor
## (about one body height; the pack's README puts him at about 24 px tall).
@export var grapple_fling_height: float
## Upward speed added when jumping out of a grapple.
@export var grapple_jump_speed: float
## Fraction of the pull velocity carried into a jump out of a grapple.
@export var grapple_jump_keep: float

@export_group("Effects")
## Seconds of standing still before the idle aura (the pack's Aura_Loop) appears.
@export var idle_aura_delay: float
## Seconds between afterimages left behind during a dash.
@export var dash_trail_interval: float
## Seconds an afterimage takes to fade out.
@export var dash_trail_lifetime: float
## Tint and starting opacity of the afterimages (drawn with additive blending).
@export var dash_trail_color: Color

@export_group("Camera")
## Camera2D position smoothing speed (higher follows tighter).
@export var camera_smoothing_speed: float
## How far ahead of the player, in the facing direction, the camera looks.
@export var camera_look_ahead: float
## How quickly the look-ahead and fall lead move to their targets (per second).
@export var camera_offset_speed: float
## How far below the player the camera leads while falling fast.
@export var camera_fall_lead: float
## Fall speed at which the camera starts leading downward.
@export var camera_fall_lead_min_speed: float
## How far the camera dips on a hard landing.
@export var camera_landing_dip: float
## Landing speed at which the dip happens.
@export var camera_landing_dip_min_speed: float
## How fast the dip recovers (px/s).
@export var camera_landing_dip_recover_speed: float

@export_group("Health")
## Health the Seeker starts and respawns with (story 004).
@export var max_health: float
## Seconds after a landed hit during which further hits are ignored.
@export var invulnerability_time: float
## Seconds of one blink of the sprite while invulnerable (half visible, half faded).
@export var invulnerability_blink_period: float
## Opacity of the sprite during the faded half of a blink.
@export var invulnerability_blink_alpha: float
## Seconds the player has no control after a hit (the Hurt clip may keep playing after).
@export var hurt_lock_time: float
## A hit of at least this much damage plays HurtKnockback instead of Hurt.
@export var hurt_knockback_damage: float
## How fast leftover horizontal speed bleeds off while hurt (px/s per second).
@export var hurt_deceleration: float
