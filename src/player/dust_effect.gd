## A one-shot effect (dust, air-jump ring) that plays once at a world point and
## then frees itself. Its anchor pixel is placed on that point.
##
## Usage: [codeblock]
## var effect := DustEffect.new()
## get_parent().add_child(effect)
## effect.start(vfx_frames, &"dust_land", Vector2(22, 14), global_position, 1)
## [/codeblock]
class_name DustEffect
extends AnimatedSprite2D


## Plays [param clip] from [param frames] once with its [param anchor] pixel on
## [param world_position]. [param facing] is 1 or -1 and mirrors around the anchor.
func start(frames: SpriteFrames, clip: StringName, anchor: Vector2, world_position: Vector2, facing: int) -> void:
	sprite_frames = frames
	centered = false
	offset = -anchor
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scale.x = float(facing)
	global_position = world_position
	animation_finished.connect(queue_free)
	play(clip)
