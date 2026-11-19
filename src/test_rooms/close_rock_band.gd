## The close rock scenery band (boulders, lava-rock mounds, slabs) laid just behind
## whatever floor is on screen. The band is cut into narrow vertical slices; every frame
## each slice drops behind the floor in front of it, so the rocks rise from behind low
## floors, high ledges and tall sections alike. Sideways the art still scrolls slower
## than the room ([member factor]) for depth. A slice spanning a drop takes the lower
## floor, so rock never hangs over open air, and where neighbouring slices sit at
## different heights each fades out across its width, so no straight cut shows.
##
## Usage: [codeblock]
## var band := CloseRockBand.new()
## band.z_index = -12
## world.add_child(band)
## band.setup(textures, CELL / 512.0 * ..., 0.75, 12.0, floor_query)
## [/codeblock]
## Then call [method place] once per frame with the camera's screen centre.
class_name CloseRockBand
extends Node2D

## World px each slice covers. Must divide a piece's world width.
const SLICE_WIDTH := 16.0

const FADE_SHADER := """
shader_type canvas_item;
// UV x range of this slice's region, and whether to fade its left and right sides.
uniform vec2 span = vec2(0.0, 1.0);
uniform vec2 fade = vec2(0.0);
void fragment() {
	COLOR = texture(TEXTURE, UV);
	float t = clamp((UV.x - span.x) / (span.y - span.x), 0.0, 1.0);
	if (fade.x > 0.5) {
		COLOR.a *= smoothstep(0.0, 1.0, t);
	}
	if (fade.y > 0.5) {
		COLOR.a *= smoothstep(0.0, 1.0, 1.0 - t);
	}
}
"""

## How fast the art scrolls sideways relative to the room (1 = with the terrain).
var factor := 0.75
## How far below the floor line each slice's bottom sits, world px (hidden by the floor).
var sink := 12.0

var _pieces: Array[Texture2D] = []
var _image_scale := 1.0
var _piece_width := 512.0
var _height := 128.0
var _view_size := Vector2(480, 270)
var _floor_query: Callable
var _slices: Array[Sprite2D] = []
var _materials: Array[ShaderMaterial] = []


## [param pieces]: the band's strips, repeating in order. [param image_scale]: world px per
## source px. [param floor_query]: (x_from, x_to, view_top, view_bottom) -> the lowest
## floor line under that span within the view, or INF when none (open below).
func setup(pieces: Array[Texture2D], image_scale: float, scroll_factor: float,
		sink_px: float, view_size: Vector2, floor_query: Callable) -> void:
	_pieces = pieces
	_image_scale = image_scale
	factor = scroll_factor
	sink = sink_px
	_view_size = view_size
	_floor_query = floor_query
	_piece_width = pieces[0].get_width() * image_scale
	_height = pieces[0].get_height() * image_scale
	var shader := Shader.new()
	shader.code = FADE_SHADER
	var count := int(ceil(view_size.x / SLICE_WIDTH)) + 2
	for i in count:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.region_enabled = true
		sprite.scale = Vector2.ONE * image_scale
		var material := ShaderMaterial.new()
		material.shader = shader
		sprite.material = material
		add_child(sprite)
		_slices.append(sprite)
		_materials.append(material)


## Lays the slices out for the view centred on [param center] (world px).
func place(center: Vector2) -> void:
	if _slices.is_empty():
		return
	var view_left := center.x - _view_size.x * 0.5
	var view_top := center.y - _view_size.y * 0.5
	var view_bottom := view_top + _view_size.y
	var scroll := center.x * factor
	var first := int(floor(scroll / SLICE_WIDTH))
	var floors: Array[float] = []
	floors.resize(_slices.size())
	for k in _slices.size():
		var j := first + k
		var x0 := view_left + j * SLICE_WIDTH - scroll
		floors[k] = _floor_query.call(x0, x0 + SLICE_WIDTH, view_top, view_bottom)
	for k in _slices.size():
		var sprite := _slices[k]
		var floor_y := floors[k]
		if is_inf(floor_y):
			sprite.visible = false
			continue
		sprite.visible = true
		var j := first + k
		var band_x := j * SLICE_WIDTH
		var piece := posmod(int(floor(band_x / _piece_width)), _pieces.size())
		var within := fposmod(band_x, _piece_width) / _image_scale
		var texture := _pieces[piece]
		sprite.texture = texture
		var region := Rect2(within, 0.0, SLICE_WIDTH / _image_scale, texture.get_height())
		sprite.region_rect = region
		sprite.position = Vector2(view_left + band_x - scroll, floor_y + sink - _height)
		var width := float(texture.get_width())
		var material := _materials[k]
		material.set_shader_parameter("span", Vector2(region.position.x / width, region.end.x / width))
		var left_differs := k == 0 or floors[k - 1] != floor_y
		var right_differs := k == _slices.size() - 1 or floors[k + 1] != floor_y
		material.set_shader_parameter("fade", Vector2(
				1.0 if left_differs and k > 0 else 0.0,
				1.0 if right_differs and k < _slices.size() - 1 else 0.0))
