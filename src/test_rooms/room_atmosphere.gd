## Mood pass for a painted room: the far layers slightly blurred, a fog bank between the
## distant city and the play layer plus a thin ground fog in front, floating embers and
## dust, warm glows on lit props, and a final grade (a soft bloom on the player,
## contrast, split tone, a soft light around the player, vignette). Every look value is a constant below so it can be tuned
## in one place; [method set_enabled] switches the whole pass for side-by-side looks.
##
## Usage (from a room's _ready, after its layers are built): [codeblock]
## var mood := RoomAtmosphere.new()
## add_child(mood)
## mood.setup(world, camera, player, VIEW_SIZE)
## mood.add_glow(Vector2(820, 240), 40.0)
## [/codeblock]
## Then call [method follow] once per frame with the camera's screen centre, right before
## drawing (the room's layer placement does this).
class_name RoomAtmosphere
extends Node

## Draw order inside the room's world (its back layers sit at -30 and -20, the corridor
## wall at -10, the close rocks at -9, terrain and props at 0, the middle rim at 4-6, the
## foreground at 10+).
const FAR_BLUR_Z := -25
const MID_BLUR_Z := -15
const DEEP_FOG_Z := -22
const FAR_FOG_Z := -14
const NEAR_BACK_FOG_Z := -6
const DUST_Z := -13
const GLOW_Z := 1
const GROUND_FOG_Z := 7
const EMBER_Z := 8

## Blur radius in screen px: the far city a little, the midground less.
const FAR_BLUR := 5.0
const MID_BLUR := 2.0

## Fog: [colour, density, noise scale (per world px), drift speed, parallax factor,
## screen height where it starts and where it is full (0 top, 1 bottom)].
## A fog bank between every pair of back layers, as between the foreground layers:
## deep (far city | midground ruins), far (midground | close rocks), near-back (close
## rocks | playable terrain, thin so the rocks sit back without hiding them).
const DEEP_FOG := [Color(0.8, 0.5, 0.48, 0.38), 1.0, 0.008, 0.012, 0.2, 0.0, 0.75]
const FAR_FOG := [Color(0.78, 0.47, 0.44, 0.5), 1.0, 0.012, 0.018, 0.4, 0.2, 0.9]
const NEAR_BACK_FOG := [Color(0.7, 0.42, 0.4, 0.22), 1.0, 0.016, 0.022, 0.8, 0.35, 0.95]
const GROUND_FOG := [Color(0.66, 0.4, 0.4, 0.3), 1.0, 0.02, 0.03, 1.15, 0.55, 1.0]

## Embers rising from the lava: count, lifetime (s), rise speed range (world px/s), size
## range (world px), colour.
const EMBERS := [90, 7.0, Vector2(4.0, 12.0), Vector2(1.4, 2.8), Color(1.0, 0.58, 0.24, 1.0)]
## Dust and ash drifting in the air, behind the play layer.
const DUST := [90, 9.0, Vector2(0.8, 3.0), Vector2(1.0, 2.0), Color(0.95, 0.84, 0.82, 0.4)]

## Prop glow: colour and flicker (fraction of strength, speed).
const GLOW_COLOR := Color(1.0, 0.5, 0.18, 0.42)
const GLOW_FLICKER := Vector2(0.12, 2.3)

## Grade: contrast, saturation, shadow tint, highlight tint, split-tone strength.
const CONTRAST := 1.1
const SATURATION := 1.0
const SHADOW_TINT := Color(0.84, 0.8, 1.0)
const HIGHLIGHT_TINT := Color(1.08, 0.97, 0.88)
const SPLIT_TONE := 0.7
## Light around the player: radius (fraction of screen height), how much the rest of the
## screen dims, how much the light lifts.
const PLAYER_LIGHT := Vector3(0.5, 0.16, 0.03)
## Vignette: where it starts and ends (distance from centre, screen heights) and strength.
const VIGNETTE := Vector3(0.5, 1.1, 0.5)
const VIGNETTE_COLOR := Color(0.07, 0.02, 0.05)
## Screen bloom on the player (bright parts near the player glow): [threshold, intensity,
## blur step in screen px], inside a soft circle (BLOOM_AREA, screen heights). Off (0):
## drawn over the Seeker it washed out his painted art; the backlight below glows from
## behind him instead.
const BLOOM := Vector3(0.5, 0.0, 8.0)
const BLOOM_AREA := Vector2(0.06, 0.28)
## Screen radiance around the player (added warm light, squared falloff): [strength,
## radius in screen heights]. Off for the same reason; see BACKLIGHT.
const RADIANCE_COLOR := Color(1.0, 0.86, 0.76)
const RADIANCE := Vector2(0.0, 0.2)
## The Seeker's backlight, drawn behind his sprite so his painted art stays untouched:
## a blurred, warm copy of his current frame (a glow that hugs his silhouette and rims
## his edges) and a soft round radiance. [silhouette glow strength, blur radius in world
## px], radiance [strength, radius in world px], and their colour.
const BACKLIGHT := Vector2(0.85, 3.5)
const BACKLIGHT_RADIANCE := Vector2(0.22, 34.0)
const BACKLIGHT_COLOR := Color(1.0, 0.78, 0.62)
## Ambient light gradient over the screen: the top a little cooler and darker, the bottom
## warmer (the lava is below), multiplied in.
const AMBIENT_TOP := Color(0.84, 0.82, 0.97)
const AMBIENT_BOTTOM := Color(1.06, 0.95, 0.86)
## The player's origin is at its feet; light and bloom centre on its body, this far up
## (world px).
const PLAYER_CENTRE := Vector2(0.0, -13.0)

const BACKLIGHT_SHADER := """
shader_type canvas_item;
render_mode blend_add;
uniform vec4 tint : source_color = vec4(1.0, 0.78, 0.62, 1.0);
uniform float strength = 0.85;
uniform float radius_px = 28.0;
void fragment() {
	float total = 1.0;
	float a = texture(TEXTURE, UV).a;
	for (int ring = 1; ring <= 4; ring++) {
		float w = 1.0 / float(ring);
		for (int k = 0; k < 12; k++) {
			float ang = (float(k) + 0.5 * float(ring)) * 0.523599;
			vec2 o = vec2(cos(ang), sin(ang)) * radius_px * float(ring) / 4.0;
			a += texture(TEXTURE, UV + o * TEXTURE_PIXEL_SIZE).a * w;
			total += w;
		}
	}
	COLOR = vec4(tint.rgb * strength, a / total);
}
"""

const BLUR_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float radius = 2.0;
const vec2 TAPS[12] = vec2[](
	vec2(-0.326, -0.406), vec2(-0.840, -0.074), vec2(-0.696, 0.457), vec2(-0.203, 0.621),
	vec2(0.962, -0.195), vec2(0.473, -0.480), vec2(0.519, 0.767), vec2(0.185, -0.893),
	vec2(0.507, 0.064), vec2(0.896, 0.412), vec2(-0.322, -0.933), vec2(-0.792, -0.598));
void fragment() {
	vec2 step = SCREEN_PIXEL_SIZE * radius;
	vec4 sum = texture(screen_tex, SCREEN_UV);
	for (int i = 0; i < 12; i++) {
		sum += texture(screen_tex, SCREEN_UV + TAPS[i] * step);
	}
	COLOR = vec4(sum.rgb / 13.0, 1.0);
}
"""

const FOG_SHADER := """
shader_type canvas_item;
uniform vec4 fog_color : source_color = vec4(0.6, 0.35, 0.35, 0.4);
uniform float density = 1.0;
uniform float noise_scale = 0.012;
uniform float speed = 0.02;
uniform float parallax = 0.5;
uniform vec2 band = vec2(0.2, 0.9);
uniform vec2 view_origin = vec2(0.0);
uniform vec2 view_size = vec2(480.0, 270.0);
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}
void fragment() {
	vec2 world = view_origin * parallax + UV * view_size;
	vec2 p = world * noise_scale * vec2(1.0, 2.2);
	float n = fbm(p + vec2(TIME * speed * 6.0, TIME * speed));
	float m = fbm(p * 0.45 + vec2(17.0 - TIME * speed * 3.0, 4.0));
	float d = smoothstep(0.25, 0.72, n * 0.55 + m * 0.45) * density;
	float mask = smoothstep(band.x, band.y, UV.y);
	COLOR = vec4(fog_color.rgb, fog_color.a * d * mask);
}
"""

const GRADE_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float contrast = 1.08;
uniform float saturation = 0.92;
uniform vec3 shadow_tint = vec3(0.82, 0.78, 1.0);
uniform vec3 highlight_tint = vec3(1.08, 0.97, 0.88);
uniform float split = 0.6;
uniform vec2 player_uv = vec2(0.5);
uniform vec3 player_light = vec3(0.42, 0.14, 0.06);
uniform vec3 vignette = vec3(0.48, 1.05, 0.55);
uniform vec3 vignette_color = vec3(0.07, 0.02, 0.05);
uniform float aspect = 1.7778;
uniform vec3 bloom = vec3(0.5, 1.9, 8.0);
uniform vec2 bloom_area = vec2(0.06, 0.28);
uniform vec3 radiance_color = vec3(1.0, 0.86, 0.76);
uniform vec2 radiance = vec2(0.2, 0.2);
uniform vec3 ambient_top = vec3(0.84, 0.82, 0.97);
uniform vec3 ambient_bottom = vec3(1.06, 0.95, 0.86);
vec3 bright(vec2 uv, float threshold) {
	vec3 s = texture(screen_tex, uv).rgb;
	float l = dot(s, vec3(0.299, 0.587, 0.114));
	// Soft knee: pixels just over the threshold glow a little, bright ones fully.
	return s * smoothstep(threshold, threshold + 0.25, l);
}
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	vec2 to_player = (SCREEN_UV - player_uv) * vec2(aspect, 1.0);
	float near = 1.0 - smoothstep(bloom_area.x, bloom_area.y, length(to_player));
	if (near > 0.001 && (bloom.y > 0.0 || radiance.x > 0.0)) {
		vec3 glow = bright(SCREEN_UV, bloom.x);
		float total = 1.0;
		for (int ring = 1; ring <= 5; ring++) {
			float w = exp(-float(ring * ring) / 10.0);
			for (int k = 0; k < 12; k++) {
				float a = (float(k) + 0.37 * float(ring)) * 0.523599;
				vec2 offset = vec2(cos(a), sin(a)) * float(ring) * bloom.z * SCREEN_PIXEL_SIZE;
				glow += bright(SCREEN_UV + offset, bloom.x) * w;
				total += w;
			}
		}
		c += glow / total * bloom.y * near;
		float r = 1.0 - smoothstep(0.0, radiance.y, length(to_player));
		c += radiance_color * radiance.x * r * r;
	}
	c = (c - 0.5) * contrast + 0.5;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, c * shadow_tint, (1.0 - smoothstep(0.0, 0.45, l)) * split);
	c = mix(c, c * highlight_tint, smoothstep(0.35, 1.0, l) * split);
	l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(l), c, saturation);
	c *= mix(ambient_top, ambient_bottom, SCREEN_UV.y);
	float lit = 1.0 - smoothstep(0.0, player_light.x, length(to_player));
	c *= mix(1.0 - player_light.y, 1.0 + player_light.z, lit);
	vec2 v = (SCREEN_UV - 0.5) * vec2(aspect, 1.0);
	float vig = smoothstep(vignette.x, vignette.y, length(v)) * vignette.z;
	c = mix(c, vignette_color, vig);
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
"""

var _camera: Camera2D
var _player: Node2D
var _backlight: Sprite2D
var _view_size := Vector2.ZERO
var _followers: Array[CanvasItem] = []
var _fogs: Array[ShaderMaterial] = []
var _emitters: Array[CPUParticles2D] = []
var _glows: Array[Sprite2D] = []
var _world_nodes: Array[CanvasItem] = []
var _grade: ColorRect
var _post: CanvasLayer
var _dot: Texture2D
var _time := 0.0


## Builds the pass into [param world] (the room's painted world) and a screen layer.
func setup(world: Node2D, camera: Camera2D, player: Node2D, view_size: Vector2) -> void:
	_camera = camera
	_player = player
	_view_size = view_size
	_dot = _radial_texture(32)
	_add_blur(world, FAR_BLUR_Z, FAR_BLUR)
	_add_blur(world, MID_BLUR_Z, MID_BLUR)
	_add_fog(world, DEEP_FOG_Z, DEEP_FOG)
	_add_fog(world, FAR_FOG_Z, FAR_FOG)
	_add_fog(world, NEAR_BACK_FOG_Z, NEAR_BACK_FOG)
	_add_fog(world, GROUND_FOG_Z, GROUND_FOG)
	_add_particles(world, DUST_Z, DUST, false)
	_add_particles(world, EMBER_Z, EMBERS, true)
	_add_grade()
	_add_backlight()


## A soft warm glow (additive) at [param spot] in the world, [param radius] world px.
func add_glow(world: Node2D, spot: Vector2, radius: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = _dot
	sprite.position = spot
	sprite.scale = Vector2.ONE * radius * 2.0 / _dot.get_width()
	sprite.modulate = GLOW_COLOR
	sprite.z_index = GLOW_Z
	sprite.material = _additive()
	world.add_child(sprite)
	_glows.append(sprite)
	_world_nodes.append(sprite)


## Turns the whole pass on or off.
func set_enabled(on: bool) -> void:
	for node in _world_nodes:
		node.visible = on
	_post.visible = on


## True while the pass shows.
func is_enabled() -> bool:
	return _post.visible


## Moves the screen-sized pieces onto the view centred on [param center] (world px) and
## updates the fog and the player light. Call right before drawing.
func follow(center: Vector2) -> void:
	var origin := center - _view_size * 0.5
	for item in _followers:
		if item is Control:
			(item as Control).position = origin
		else:
			(item as Node2D).position = center
	for fog in _fogs:
		fog.set_shader_parameter("view_origin", origin)
	if _player != null and _grade != null:
		var viewport := _grade.get_viewport()
		var screen := viewport.get_canvas_transform() * (_player.global_position + PLAYER_CENTRE)
		var size := viewport.get_visible_rect().size
		_grade.material.set_shader_parameter("player_uv", screen / size)
		_grade.material.set_shader_parameter("aspect", size.x / size.y)


func _process(delta: float) -> void:
	_time += delta
	_update_backlight()
	for i in _glows.size():
		var glow := _glows[i]
		var wave := sin(_time * GLOW_FLICKER.y + i * 1.7) * 0.6 + sin(_time * GLOW_FLICKER.y * 2.3 + i) * 0.4
		glow.modulate.a = GLOW_COLOR.a * (1.0 + wave * GLOW_FLICKER.x)


## The Seeker's backlight (see BACKLIGHT): children of the player, one z step below his
## sprite.
func _add_backlight() -> void:
	if _player == null or not _player.has_method(&"body_sprite"):
		return
	var shader := Shader.new()
	shader.code = BACKLIGHT_SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", BACKLIGHT_COLOR)
	material.set_shader_parameter("strength", BACKLIGHT.x)
	_backlight = Sprite2D.new()
	_backlight.centered = false
	_backlight.material = material
	_backlight.z_index = -1
	_player.add_child(_backlight)
	var radiance := Sprite2D.new()
	radiance.texture = _dot
	radiance.position = PLAYER_CENTRE
	radiance.scale = Vector2.ONE * BACKLIGHT_RADIANCE.y * 2.0 / _dot.get_width()
	radiance.modulate = Color(BACKLIGHT_COLOR, BACKLIGHT_RADIANCE.x)
	radiance.material = _additive()
	radiance.z_index = -1
	_player.add_child(radiance)
	_world_nodes.append(_backlight)
	_world_nodes.append(radiance)


## Puts the backlight on the Seeker's current frame, offset, facing and scale.
func _update_backlight() -> void:
	if _backlight == null:
		return
	var body: AnimatedSprite2D = _player.body_sprite()
	if body.sprite_frames == null:
		return
	_backlight.texture = body.sprite_frames.get_frame_texture(body.animation, body.frame)
	_backlight.offset = body.offset
	_backlight.scale = body.scale
	_backlight.rotation = body.rotation
	_backlight.position = body.position
	_backlight.texture_filter = body.texture_filter
	var art_per_world := 1.0 / absf(body.scale.y) if body.scale.y != 0.0 else 1.0
	(_backlight.material as ShaderMaterial).set_shader_parameter("radius_px",
			BACKLIGHT.y * art_per_world)


func _add_blur(world: Node2D, z: int, radius: float) -> void:
	# A back-buffer copy right here in the draw order, so the blur reads only the layers
	# drawn before it (the far city, then the midground).
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	copy.z_index = z
	world.add_child(copy)
	var rect := _view_rect(_material(BLUR_SHADER))
	rect.material.set_shader_parameter("radius", radius)
	copy.add_child(rect)
	_world_nodes.append(copy)


func _add_fog(world: Node2D, z: int, settings: Array) -> void:
	var material := _material(FOG_SHADER)
	material.set_shader_parameter("fog_color", settings[0])
	material.set_shader_parameter("density", settings[1])
	material.set_shader_parameter("noise_scale", settings[2])
	material.set_shader_parameter("speed", settings[3])
	material.set_shader_parameter("parallax", settings[4])
	material.set_shader_parameter("band", Vector2(settings[5], settings[6]))
	material.set_shader_parameter("view_size", _view_size)
	var rect := _view_rect(material)
	rect.z_index = z
	world.add_child(rect)
	_fogs.append(material)
	_world_nodes.append(rect)


func _add_particles(world: Node2D, z: int, settings: Array, rising: bool) -> void:
	var emitter := CPUParticles2D.new()
	emitter.amount = settings[0]
	emitter.lifetime = settings[1]
	emitter.preprocess = settings[1]
	emitter.local_coords = false
	emitter.texture = _dot
	emitter.z_index = z
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emitter.emission_rect_extents = _view_size * 0.5 + Vector2(40.0, 40.0)
	var speed: Vector2 = settings[2]
	emitter.initial_velocity_min = speed.x
	emitter.initial_velocity_max = speed.y
	var size: Vector2 = settings[3]
	emitter.scale_amount_min = size.x / _dot.get_width() * 2.0
	emitter.scale_amount_max = size.y / _dot.get_width() * 2.0
	if rising:
		emitter.direction = Vector2(0.0, -1.0)
		emitter.spread = 35.0
		emitter.gravity = Vector2(0.0, -1.5)
		emitter.tangential_accel_min = -2.0
		emitter.tangential_accel_max = 2.0
		emitter.material = _additive()
	else:
		emitter.direction = Vector2(1.0, 0.0)
		emitter.spread = 180.0
		emitter.gravity = Vector2(1.2, 0.4)
	var ramp := Gradient.new()
	var colour: Color = settings[4]
	var clear := Color(colour, 0.0)
	ramp.set_color(0, clear)
	ramp.set_color(1, clear)
	ramp.add_point(0.2, colour)
	ramp.add_point(0.75, Color(colour.r, colour.g * 0.7, colour.b * 0.7, colour.a * 0.6))
	emitter.color_ramp = ramp
	world.add_child(emitter)
	_followers.append(emitter)
	_emitters.append(emitter)
	_world_nodes.append(emitter)


func _add_grade() -> void:
	_post = CanvasLayer.new()
	_post.layer = 1
	add_child(_post)
	_grade = ColorRect.new()
	_grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := _material(GRADE_SHADER)
	material.set_shader_parameter("contrast", CONTRAST)
	material.set_shader_parameter("saturation", SATURATION)
	material.set_shader_parameter("shadow_tint", Vector3(SHADOW_TINT.r, SHADOW_TINT.g, SHADOW_TINT.b))
	material.set_shader_parameter("highlight_tint",
			Vector3(HIGHLIGHT_TINT.r, HIGHLIGHT_TINT.g, HIGHLIGHT_TINT.b))
	material.set_shader_parameter("split", SPLIT_TONE)
	material.set_shader_parameter("player_light", PLAYER_LIGHT)
	material.set_shader_parameter("vignette", VIGNETTE)
	material.set_shader_parameter("vignette_color",
			Vector3(VIGNETTE_COLOR.r, VIGNETTE_COLOR.g, VIGNETTE_COLOR.b))
	material.set_shader_parameter("bloom", BLOOM)
	material.set_shader_parameter("bloom_area", BLOOM_AREA)
	material.set_shader_parameter("radiance_color",
			Vector3(RADIANCE_COLOR.r, RADIANCE_COLOR.g, RADIANCE_COLOR.b))
	material.set_shader_parameter("radiance", RADIANCE)
	material.set_shader_parameter("ambient_top", Vector3(AMBIENT_TOP.r, AMBIENT_TOP.g, AMBIENT_TOP.b))
	material.set_shader_parameter("ambient_bottom",
			Vector3(AMBIENT_BOTTOM.r, AMBIENT_BOTTOM.g, AMBIENT_BOTTOM.b))
	_grade.material = material
	_post.add_child(_grade)


## A view-sized rect that follows the camera (see [method follow]).
func _view_rect(material: ShaderMaterial) -> ColorRect:
	var rect := ColorRect.new()
	rect.size = _view_size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = material
	_followers.append(rect)
	return rect


func _material(code: String) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = code
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _additive() -> CanvasItemMaterial:
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material


func _radial_texture(size: int) -> Texture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.35, Color(1, 1, 1, 0.55))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = size
	texture.height = size
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture
