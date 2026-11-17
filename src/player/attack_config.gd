## Tuning values for the Seeker's melee attacks (story 002, design/game-brief.md
## "Melee"). Every damage, timing, frame number and hitbox the combat code uses
## lives here and is set in attack_data.tres; player_combat.gd holds no such literals.
##
## Frame numbers are sheet frame indices from Animation_Guide.txt (the frame the
## animation is showing), so they read the same as the guide.
##
## Usage: [codeblock]
## var player: Player = preload("res://src/player/player.tscn").instantiate()
## player.attack_config = preload("res://src/player/attack_data.tres")  # optional, this is the default
## [/codeblock]
## Units: pixels and seconds at the 1x base resolution (480 x 270).
class_name AttackConfig
extends Resource

@export_group("Input")
## A press of attack on the ground released before this time is a normal attack
## (Attack1, or the up attack with up held); held for this long it starts the heavy.
@export var hold_threshold: float

@export_group("Heavy")
## Playback speed of the heavy's wind-up (frames before the charge frame); above 1
## shortens the pause before the charge starts. The strike plays at normal speed.
@export var windup_speed_scale: float
## Wind-up frame the heavy holds on while charging (guide: frame 4).
@export var charge_hold_frame: int
## Frame the strike starts on when the button is released (guide: frame 5).
@export var heavy_release_frame: int
## Seconds from pressing attack until the heavy is ready (charged). The charge counts
## from the press (the hold threshold included) and runs through the wind-up.
@export var charge_time: float
## Damage multiplier of a heavy released when charged.
@export var charged_damage_multiplier: float
## BladeGlow states (0-3) shown in turn while charging (guide: 3, 1, 3, 1, 0, 1).
@export var glow_cycle: PackedInt32Array
## Seconds per BladeGlow state when the charge starts.
@export var glow_step_time_slow: float
## Seconds per BladeGlow state when the charge is nearly full; the cycle speeds up
## from the slow value to this one as the charge fills.
@export var glow_step_time_fast: float
## BladeGlow states flickered once the charge is ready (guide: 0 and 2).
@export var glow_ready_cycle: PackedInt32Array
## Seconds per BladeGlow state while ready.
@export var glow_ready_step_time: float
## Where the full-charge burst (the pack's Charge_Release effect) plays, from the feet
## point with the player facing right: on the blade of the charge frame.
@export var heavy_ready_fx_offset: Vector2
## Seconds the Seeker flashes bright when the heavy becomes fully charged.
@export var heavy_ready_flash_time: float
## Colour the Seeker is multiplied by at the start of that flash (above 1 brightens).
@export var heavy_ready_flash_color: Color

@export_group("Pogo")
## Upward speed given to the player when a down attack hits, as a positive number.
@export var pogo_speed: float
## Fastest the player falls while a down attack plays, so its hit frames meet what is
## below instead of the player dropping past it.
@export var down_attack_max_fall_speed: float

@export_group("Moving while attacking")
## Ground slowdown with no input during a swing (lower than the run's braking, so the
## swing's forward step glides a little). With input the player runs as normal.
@export var swing_glide_deceleration: float

@export_group("Attacks")
## One entry per attack, keyed "attack1", "attack2", "attack3", "jump_attack",
## "up_attack", "down_attack" and "heavy". Each entry is a Dictionary with:
## - "damage" (float): damage dealt per hit (heavy: before the charged multiplier).
## - "hit_from", "hit_to" (int): first and last frame the hitbox is active.
## - "hitbox" (Rect2): the hit area measured from the feet point, y up negative,
##   written for a player facing right (it is mirrored when facing left).
## - "move_cancel_from" (int): first frame from which dash, jump and grapple may cancel
##   the swing (its recovery).
## - "next" (String, optional): the attack chained into; with "chain_from" (int), the
##   first frame from which a press cancels into it.
## - "shake_size" (float, px) and "shake_time" (float, s): screen shake sent on the
##   hit frames; a size of 0 sends none.
## - "lunge" (float, px/s, optional): forward speed given when the swing starts (the
##   heavy: when it is released) on the ground; 0 or absent gives none.
@export var attacks: Dictionary
