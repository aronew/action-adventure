## Art-style test room (throwaway): the painted Cinderheart Caldera art at full
## resolution around the pixel-art Seeker drawn at 4x. Built in code so the .tscn only
## attaches this script. It changes nothing outside itself: the window's content scale
## is switched to 1920x1080 here, at runtime, and the project settings stay as they are.
##
## How the two styles meet: gameplay keeps its pixel units (the Seeker is 22 px tall, a
## screen is 480x270 world px), the camera zooms 4x, and the window renders 1920x1080.
## The Seeker keeps the project's nearest filter, so each of its pixels is a crisp 4x4
## block. The painted art sits under a node with linear, mipmapped filtering and is
## scaled so one source pixel lands on about one screen pixel.
##
## Terrain is a grid of solid cells, like an autotile: each solid cell picks its rock
## edge from which neighbours are empty (top, sides, bottom, corners) and an interior
## cell is plain black. Collision follows the painted rock faces, using each edge
## tile's measured inset (from its alpha). Props stand on their solid edge, not their
## soft glow. Values here are test-room constants, not tuned gameplay data.
##
## Parallax follows the GameMaker article the owner pointed to ("Creating depth and
## immersion: parallax"): every layer is the camera position times a weight. Far layers
## move slower than the world; the foreground lives in the world and moves faster than
## it (about 2x sideways, 1.1x up and down), built from strips that repeat sideways.
extends Node2D

const PLAYER_SCENE := preload("res://src/player/player.tscn")
const BIOME := "res://assets/environment/cinderheart-caldera/"
const RENDER_SIZE := Vector2i(1920, 1080)
const ZOOM := 4.0
const VIEW_SIZE := Vector2(480, 270)
const SPAWN_POINT := Vector2(96, 260)
const TERRAIN_COLOR := Color(0, 0, 0)
const BACKGROUND_COLOR := Color(0.08, 0.05, 0.06)

## One terrain cell in world px; the source cells are 512 px.
const CELL := 36.0
const TILE_SOURCE := 512.0
## The atlas is a 3584 px export of 1254 px native art; props are at native size.
const ATLAS_PER_NATIVE := 3584.0 / 1254.0
## Edge tiles in the 7x7 sheet (row * 7 + column) and where each one's painted rock face
## sits inside its 512 px cell: [top, bottom, left, right] insets in source px.
const TILE_TL := 0
const TILE_T := 1
const TILE_TR := 2
const TILE_L := 7
const TILE_R := 9
const TILE_BL := 14
const TILE_B := 15
const TILE_BR := 16
const TILE_INSETS := {
	0: [69, 0, 82, 0], 1: [78, 0, 0, 0], 2: [79, 0, 0, 90],
	7: [0, 0, 73, 0], 9: [0, 0, 0, 90],
	14: [0, 62, 76, 0], 15: [0, 64, 0, 0], 16: [0, 69, 0, 102],
}
## The room in cells ('#' solid). Cells outside the grid count as solid, so the room's
## own border shows no rock face. Columns 0-39 are the open cave; from column 40 a tight
## corridor runs on from the high ledge: a low ceiling (82 px of headroom), a hanging
## dip at columns 52-56, a step up at column 60 and a rock wall closing it at column 66.
const GRID := [
	"######################################################################",
	"........................................##############################",
	"....................................................#####.........####",
	"............................................................##########",
	"...............................#######################################",
	"...............................#######################################",
	"...............................#######################################",
	"......................################################################",
	"################......################################################",
	"######################################################################",
]
## Where the corridor begins (its first column) and how wide, in world px, the soft
## blend between the open cave's layers and the corridor's is at its mouth.
const CORRIDOR_START_COL := 40
const LAYER_BLEND := 72.0
## The corridor's close rear wall (corridor/layers.json "close-wall"): a loop that sits
## just behind the play layer instead of the distant background.
const CORRIDOR_WALL_SCALE := 0.85

## Solid bounds of each prop (alpha over half), in source px: left, top, right, bottom.
const PROP_BOUNDS := {
	"platform-short": [11, 11, 181, 179], "platform-medium": [13, 17, 257, 219],
	"platform-long": [12, 33, 373, 218], "rocks-small": [16, 133, 213, 263],
	"rocks-large": [11, 65, 329, 263], "ruin-prop": [11, 17, 321, 262],
	"decoration-low": [12, 107, 260, 264], "decoration-tall": [83, 16, 287, 292],
	"wall-left": [47, 17, 251, 318], "wall-right": [29, 14, 243, 315],
	"ceiling-overhang": [12, 81, 312, 270], "hanging-decoration": [57, 11, 144, 255],
}
## How far a ground prop sinks into the surface it stands on, in world px.
const PROP_SINK := 2.0
## Floating islands: prop, centre x, surface y (world), surface y in the source image.
const ISLANDS := [
	["platform-short", 420.0, 232.0, 67.0],
	["platform-medium", 690.0, 266.0, 78.0],
	["platform-long", 990.0, 192.0, 96.0],
]
## Ground props: prop, left x, the surface they stand on (world y). No collision.
const GROUND_PROPS := [
	["wall-left", 4.0, 293.5],
	["rocks-small", 150.0, 293.5],
	["ruin-prop", 200.0, 293.5],
	["rocks-large", 820.0, 257.5],
	["decoration-low", 1010.0, 257.5],
	["decoration-tall", 1180.0, 149.5],
	["wall-right", 1300.0, 149.5],
]
## Hanging props: prop, left x (their top tucks into the ceiling).
const HANGING_PROPS := [
	["ceiling-overhang", 280.0],
	["hanging-decoration", 560.0],
	["ceiling-overhang", 860.0],
	["hanging-decoration", 1240.0],
]
## Corridor props: prop, left x, the surface they stand on (world y), or for hanging
## props the ceiling line they hang from. No collision.
const CORRIDOR_GROUND_PROPS := [
	["rocks-small", 1640.0, 149.5],
	["decoration-low", 2010.0, 149.5],
]
const CORRIDOR_HANGING_PROPS := [
	["hanging-decoration", 1780.0],
]
## Background layers: file, scroll scale (how fast it moves on screen against the
## camera; 1 = the play layer), whether it repeats (mirrored, so the seams meet) instead
## of stretching to cover the room.
const BACK_LAYERS := [["background", 0.15, false], ["midground", 0.5, true]]
## The owner's close rock band (close-rocks/): boulders, lava-rock mounds and obsidian
## slabs (pieces A, B, C) as scenery just behind the floors. Every straight run of floor
## gets its own stretch of rock, fixed to that floor: a whole number of pieces, stretched
## a little to fit the run. Every piece starts and ends in low rubble, so each stretch
## tapers down to the floor at its ends on its own, with no fade. Ends at a drop are
## pulled in CLOSE_ROCKS_EDGE_INSET from the edge. Where the headroom is low (the
## corridor), the rocks scale down to fill CLOSE_ROCKS_HEADROOM of it. Sideways each
## stretch scrolls at CLOSE_ROCKS_SCALE around its own centre (slower than the terrain,
## for depth); up and down it stays on its floor. Drawn after the far layers and fog,
## unblurred, in front of the corridor's rear wall, behind the terrain. Empty: none.
const CLOSE_ROCKS := "close-rocks/"
const CLOSE_ROCK_PIECES := ["Close-Background-A", "Close-Background-B", "Close-Background-C"]
const CLOSE_ROCKS_SCALE := 0.85
const CLOSE_ROCKS_Z := -9
## How far below the floor line each stretch's bottom sits, world px at full size.
const CLOSE_ROCKS_SINK := 12.0
const CLOSE_ROCKS_EDGE_INSET := 54.0
## How far a stretch may drift towards a drop (it always stays a full cell from the edge,
## where the ledge's rounded corner would show the rock's flat bottom).
const CLOSE_ROCKS_DROP_DRIFT := 18.0
## How far (world px) each stretch's ends fade out, so the pieces' low end rubble trails
## off instead of stopping square.
const CLOSE_ROCKS_END_FADE := 40.0
const END_FADE_SHADER := """
shader_type canvas_item;
uniform vec2 ends = vec2(0.0);
void fragment() {
	COLOR = texture(TEXTURE, UV);
	float a = 1.0;
	if (ends.x > 0.0) {
		a *= smoothstep(0.0, ends.x, UV.x);
	}
	if (ends.y > 0.0) {
		a *= smoothstep(0.0, ends.y, 1.0 - UV.x);
	}
	COLOR.a *= a;
}
"""
const CLOSE_ROCKS_HEADROOM := 0.55
## The tallest rock in the pieces, source px above the canvas bottom (for headroom).
const CLOSE_ROCKS_TALLEST := 440.0
## Floor runs narrower than this (world px) get no rock.
const CLOSE_ROCKS_MIN_RUN := 3.0 * 36.0
## Whether the low-ceiling corridor gets rock too.
const CLOSE_ROCKS_IN_CAVES := true
## The owner's close plants (close-plants/): wiry ember-tip stalks, curling fronds and
## tendrils (pieces A, B, C), laid out per floor run the same way as the close rocks but
## in front of them, nearest the play layer: drawn after them and scrolling a little
## faster (CLOSE_PLANTS_SCALE). CLOSE_PLANTS_RISE lifts them (world px; past the sink,
## their bases would show above the floor). Empty: none.
const CLOSE_PLANTS := "close-plants/"
const CLOSE_PLANT_PIECES := ["Close-Plants-A", "Close-Plants-B", "Close-Plants-C"]
const CLOSE_PLANTS_SCALE := 0.92
const CLOSE_PLANTS_RISE := 0.0
const CLOSE_PLANTS_TALLEST := 480.0
## Foreground strips (the owner's v5 loops): on screen they move faster than the play
## layer. Sideways 1.2, the loops' own camera_motion_factor (foreground-layers.json);
## up and down 1.1, the GameMaker article's vertical weight of -0.1.
const FOREGROUND_SCALE := Vector2(1.2, 1.1)
## Each loop is a full screen-height canvas (3840x1080) that repeats every 3840 px.
const FOREGROUND_STRIPS := ["foreground-top", "foreground-bottom"]
## Room-end pieces: file, at the room's left (else its right), scaled to the room's full
## height (else to one screen, top-aligned, for a corridor that is less than a screen
## tall). The open cave's left border at the room's left end; the corridor's right border
## over the rock wall that closes the corridor.
## Then the z order, and how far it slides past the room's edge (world px): the middle
## layer's left border is a solid column 100 px wide at room height, so it is pushed
## 62 px past the room's left edge to frame the wall without covering the spawn point.
const BORDERS := [
	["middle-strips/border-left.png", true, true, MIDDLE_Z, 62.0],
	["corridor/brighter/border-right.png", false, false, 12, 0.0],
]
## Middle layer (the owner's corner kit in middle-foreground/): a nearer rock rim that
## traces the terrain's outline. Every exposed terrain edge cell gets the kit's matching
## nine-slice piece (top edge, outer corners, walls, underside), set MIDDLE_INSET px
## inside the solid so it reads as a closer lip just within the outline and never covers
## the path. Pieces sit edge to edge, one per cell (MIDDLE_PIECE_SCALE 1), because the
## kit's core edges are made to mate exactly; overlapping them showed seams. The rim moves
## with the terrain (scroll scale 1, not the kit's 1.06): a layer at another speed cannot
## stay on the terrain's outline across a room, and pieces with separate references
## drifted 2 px apart into black cracks. It still reads nearer, drawn in front of the
## playable edge and the player.
const MIDDLE_Z := 5
const MIDDLE_INSET := 5.0
const MIDDLE_PIECE_SCALE := 1.0
## The owner's modular foreground tileset (modular-foreground/): the terrain atlas redrawn
## as nearer scoria rock on the same 7x7 grid with the same tile IDs. When set, the rim
## draws each edge cell's own terrain tile ID from it (inside corners too, base then
## face, as the terrain does), so it traces the outline with the terrain's exact shapes.
## When empty, the rim uses the older corner kit below.
## rim-loop/ holds its straight edges made to repeat seamlessly along a run (their ends
## cross-faded with the corner tiles', tools/asset-pipeline/loop_rim_edges.py), so a long
## floor or wall no longer breaks every cell. rim-cut/ is rim-loop/ with the black core
## cut out to a soft contact shadow (tools/asset-pipeline/cut_rim_core.py), so the wall
## fill drawn under every solid cell shows through: one continuous fill, no seam between
## an edge tile's core and the fill beside it. MIDDLE_MASKS (the uncut set) masks the
## fill to the solid.
const MIDDLE_TILESET := "modular-foreground/rim-cut/"
const MIDDLE_MASKS := "modular-foreground/rim-loop/"
## Inside corners of the rim, in source px of the 512 px tile, [opaque, clear]: the wall
## face fades out across the floor's lip band (or up across the ceiling's), and the lip
## fades out sideways behind the wall face. Fill covers the corner's solid part.
const MIDDLE_CORNER_FADES := {
	"face_floor": [130.0, 240.0], "face_ceiling": [382.0, 272.0],
	"lip_left_wall": [120.0, 280.0], "lip_right_wall": [392.0, 232.0],
}
## The terrain's own inside corners, the same way: the wall face fades out across the
## floor's lip band (up across the ceiling's), [opaque, clear] in source px.
const TERRAIN_CORNER_FADES := {"floor": [64.0, 112.0], "ceiling": [448.0, 400.0]}
const FADE_SHADER := """
shader_type canvas_item;
// x: 1 fades along UV.x, 0 along UV.y; y: UV where opaque; z: UV where clear.
uniform vec3 fade = vec3(0.0, 0.0, 1.0);
void fragment() {
	float t = fade.x > 0.5 ? UV.x : UV.y;
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= clamp((t - fade.z) / (fade.y - fade.z), 0.0, 1.0);
}
"""
## Fill masked to an edge cell's solid part: the uncut rim tile's alpha (a second one
## for inside corners), each sampled where its tile sits after the rim's inset.
const MASK_SHADER := """
shader_type canvas_item;
uniform sampler2D mask_a : filter_linear_mipmap;
uniform sampler2D mask_b : filter_linear_mipmap;
uniform vec2 shift_a = vec2(0.0);
uniform vec2 shift_b = vec2(0.0);
uniform float use_b = 0.0;
float cover(sampler2D mask, vec2 uv) {
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		return 0.0;
	}
	return texture(mask, uv).a;
}
void fragment() {
	COLOR = texture(TEXTURE, UV);
	float a = cover(mask_a, UV - shift_a);
	if (use_b > 0.5) {
		a = max(a, cover(mask_b, UV - shift_b));
	}
	COLOR.a *= a;
}
"""
## The fill tiles all share the same rocks along their edges (that is what lets any two
## join), so a wall of them shows a grid. Round patches of fill, each a fill tile's middle
## faded out to a soft circle, are laid over every grid line's corners and midpoints
## inside the solid to hide it. MIDDLE_PATCH_SOLID / MIDDLE_PATCH_CLEAR: the patch's
## radius (fraction of its half-width) where it is opaque and where it is clear.
const MIDDLE_PATCHES := true
const MIDDLE_PATCH_SOLID := 0.55
const MIDDLE_PATCH_CLEAR := 1.0
const PATCH_SHADER := """
shader_type canvas_item;
uniform vec2 radii = vec2(0.55, 1.0);
void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 1.0 - smoothstep(radii.x, radii.y, length(UV - vec2(0.5)) * 2.0);
}
"""
## The owner's wall fill (modular-foreground/fill-large/, which carries the first pack's
## sixteen variants unchanged plus twelve new ones): opaque rock tiles that join any
## other on all four sides. Every solid cell of the rim layer gets one (edge cells masked
## to their solid part), picked by a fixed hash of the cell so the room looks the same
## every run. Empty: no fill; the rim tiles' cores then show the terrain's black.
const MIDDLE_FILL := "modular-foreground/fill-large/tiles/"
const MIDDLE_FILL_VARIANTS := 28
## The pack's three large 2x2 rock features, whose outside edges match every fill tile.
## Where four interior cells make a free 2x2 block, about one block start in
## MIDDLE_FEATURE_CHANCE gets a feature instead of fill, as an accent that breaks up the
## small stones' repetition. Empty list: fill only.
const MIDDLE_FEATURES := [
	"modular-foreground/fill-large/features/Lava-Rock-Cluster/Feature-1024.png",
	"modular-foreground/fill-large/features/Massive-Basalt-Boulders/Feature-1024.png",
	"modular-foreground/fill-large/features/Fractured-Obsidian-Mass/Feature-1024.png",
]
const MIDDLE_FEATURE_CHANCE := 7
## Terrain edge tile -> the kit's nine-slice piece for the same edge.
const MIDDLE_PIECES := {
	0: "00-outer-top-left", 1: "01-top-edge", 2: "02-outer-top-right",
	7: "04-left-wall", 9: "06-right-wall",
	14: "08-outer-bottom-left", 15: "09-underside", 16: "10-outer-bottom-right",
}
## Camera dead zone in this room (fractions of half the screen): a jump stays inside it,
## so the view only scrolls up near the top and follows real falls. The bottom margin
## (0.3 = 40 px) is a little larger than the camera's fall lead (36 px), so a normal
## jump's descent does not pull the view down. The old one-screen rooms never scrolled
## vertically, so this only matters for rooms taller than a screen.
const CAMERA_DRAG_TOP := 0.5
const CAMERA_DRAG_BOTTOM := 0.3
const HELP_TEXT := "Art-style test: Cinderheart Caldera painted art at 1920x1080, Seeker at 4x. Corridor: right, past the high ledge.\nArrows/WASD move  Space/Z jump x2  Shift/C dash  E grapple  X attack  V mood on/off"
## The owner's black silhouette foliage (shared, any biome): the nearest layer, pieces
## A, D, B, E, C, F repeating in that order (each tall piece D-F between two lower ones,
## as the pack suggests) along the bottom of the screen. It scrolls sideways with the
## foreground loops (FOREGROUND_SCALE.x) and stays on the screen's bottom edge as the
## camera rises and falls, so it shows in every part of a room, tall ones included (as
## in the owner's reference). Empty: none.
const SILHOUETTES := "res://assets/environment/foreground-silhouettes/"
const SILHOUETTE_PIECES := ["Foreground-Bottom-A", "Foreground-Bottom-D", "Foreground-Bottom-B",
		"Foreground-Bottom-E", "Foreground-Bottom-C", "Foreground-Bottom-F"]
## Where the 512 px strips sit on the pack's 1920x1080 reference screen, and their z.
const SILHOUETTE_TOP := 568.0
const SILHOUETTE_Z := 20
## The band stays on the screen's bottom, but when the camera moves up or down it first
## drifts the way near-camera foliage would (SILHOUETTE_SWAY times the camera's move),
## then eases back to the bottom over about SILHOUETTE_LAG seconds. The drift is capped
## at SILHOUETTE_MAX_DRIFT world px; a black base under the band covers any gap.
const SILHOUETTE_SWAY := 1.2
const SILHOUETTE_LAG := 0.45
const SILHOUETTE_MAX_DRIFT := 40.0
## Props that carry lava light get a soft warm glow from the mood pass, [prop: radius in
## world px] (see RoomAtmosphere).
const GLOWING_PROPS := {
	"rocks-small": 22.0, "rocks-large": 34.0, "decoration-low": 26.0,
	"decoration-tall": 34.0, "wall-right": 40.0, "hanging-decoration": 22.0,
}

## The room's layout. These start as the constants above; a longer test room
## (art_style_long_room.gd) swaps in its own in _init, before _ready builds the room.
var grid: Array = GRID
var islands: Array = ISLANDS
var ground_props: Array = GROUND_PROPS
var hanging_props: Array = HANGING_PROPS
var spawn_point := SPAWN_POINT
var help_text := HELP_TEXT
## The corridor's first column, or -1 for a room with no corridor (then the open cave's
## layers cover the whole room); its props; and the room-end borders.
var corridor_start_col := CORRIDOR_START_COL
var corridor_ground_props: Array = CORRIDOR_GROUND_PROPS
var corridor_hanging_props: Array = CORRIDOR_HANGING_PROPS
var borders: Array = BORDERS

var _textures := {}
var _fade_shader: Shader
var _mask_shader: Shader
var _end_fade_shader: Shader
var _silhouette_layer: Node2D
var _silhouette_lag_y := NAN
var _silhouette_ticks := 0
var _patch_shader: Shader
var _camera: Camera2D
var _room_size := Vector2.ZERO
## Manual parallax: [layer node, scroll scale, base]. Each frame a layer is placed at
## camera_centre * (1 - scroll scale) + base, so on screen it moves by scroll scale times
## the camera's motion. (Parallax2D placed the layers wrongly under the 4x zoom here.)
var _layers: Array = []
var _mood: RoomAtmosphere
var _lit_props: Array[Sprite2D] = []


func _ready() -> void:
	var window := get_window()
	window.content_scale_size = RENDER_SIZE
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	_room_size = Vector2(grid[0].length(), grid.size()) * CELL

	var world := Node2D.new()
	world.name = "PaintedWorld"
	world.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(world)

	_add_back_layers(world)
	_add_close_band(world, CLOSE_ROCKS, CLOSE_ROCK_PIECES, CLOSE_ROCKS_SCALE,
			CLOSE_ROCKS_SINK, CLOSE_ROCKS_TALLEST, 0)
	_add_close_band(world, CLOSE_PLANTS, CLOSE_PLANT_PIECES, CLOSE_PLANTS_SCALE,
			CLOSE_ROCKS_SINK - CLOSE_PLANTS_RISE, CLOSE_PLANTS_TALLEST, 1)
	_add_corridor_wall(world)
	_add_terrain(world)
	for island in islands:
		_add_island(world, island)
	var s := _prop_scale()
	for entry in ground_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1] - bounds[0] * s, entry[2] - bounds[3] * s + PROP_SINK)
	var ceiling_bottom := CELL - TILE_INSETS[TILE_B][1] * CELL / TILE_SOURCE
	for entry in hanging_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1], ceiling_bottom - bounds[1] * s - PROP_SINK)
	for entry in corridor_ground_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1] - bounds[0] * s, entry[2] - bounds[3] * s + PROP_SINK)
	var corridor_ceiling := 2.0 * CELL - TILE_INSETS[TILE_B][1] * CELL / TILE_SOURCE
	for entry in corridor_hanging_props:
		var bounds: Array = PROP_BOUNDS[entry[0]]
		var sprite := _prop_sprite(world, entry[0])
		sprite.position = Vector2(entry[1], corridor_ceiling - bounds[1] * s - PROP_SINK)
	_add_foreground(world)

	var player: Player = PLAYER_SCENE.instantiate()
	player.position = spawn_point
	add_child(player)
	var camera := PlayerCamera.new()
	_camera = camera
	camera.zoom = Vector2(ZOOM, ZOOM)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(_room_size.x)
	camera.limit_bottom = int(_room_size.y)
	camera.drag_vertical_enabled = true
	camera.drag_top_margin = CAMERA_DRAG_TOP
	camera.drag_bottom_margin = CAMERA_DRAG_BOTTOM
	player.add_child(camera)
	camera.setup(player)

	_mood = RoomAtmosphere.new()
	add_child(_mood)
	_mood.setup(world, camera, player, VIEW_SIZE)
	for sprite in _lit_props:
		var bounds: Array = PROP_BOUNDS[sprite.get_meta(&"prop")]
		var centre := Vector2(bounds[0] + bounds[2], bounds[1] + bounds[3]) * 0.5
		_mood.add_glow(world, sprite.position + centre * sprite.scale,
				GLOWING_PROPS[sprite.get_meta(&"prop")])

	var hud := CanvasLayer.new()
	hud.layer = 2
	var help := Label.new()
	help.position = Vector2(16, 12)
	help.add_theme_font_size_override(&"font_size", 22)
	help.text = help_text
	hud.add_child(help)
	add_child(hud)


func _enter_tree() -> void:
	# Place the parallax layers after the camera has moved this frame, right before
	# drawing, so they never trail it by a frame.
	RenderingServer.frame_pre_draw.connect(_place_layers)


func _exit_tree() -> void:
	RenderingServer.frame_pre_draw.disconnect(_place_layers)


func _place_layers() -> void:
	if _camera == null or not _camera.is_inside_tree():
		return
	var center := _camera.get_screen_center_position()
	for entry in _layers:
		var layer: Node2D = entry[0]
		var factor: Vector2 = entry[1]
		layer.position = center * (Vector2.ONE - factor) + entry[2]
		if entry.size() > 3:
			# A clamped layer: its x may only drift within [min, max].
			var limits: Vector2 = entry[3]
			layer.position.x = clampf(layer.position.x, limits.x, limits.y)
	_sway_silhouettes(center)
	if _mood != null:
		_mood.follow(center)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_V and _mood != null:
		_mood.set_enabled(not _mood.is_enabled())


## World px per source px for props (native-size art).
func _prop_scale() -> float:
	return CELL / TILE_SOURCE * ATLAS_PER_NATIVE


## Loads an imported texture. The environment art is imported with mipmaps on
## (mipmaps/generate in each .import file), so the downscaled painted art does not shimmer.
func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path]


func _prop_sprite(parent: Node2D, prop: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + "assets/%s.png" % prop)
	sprite.centered = false
	sprite.scale = Vector2.ONE * _prop_scale()
	sprite.set_meta(&"prop", prop)
	parent.add_child(sprite)
	if GLOWING_PROPS.has(prop):
		_lit_props.append(sprite)
	return sprite


func _solid(col: int, row: int) -> bool:
	if row < 0 or row >= grid.size() or col < 0 or col >= grid[0].length():
		return true
	return grid[row][col] == "#"


## The edge tile for a solid cell, or -1 for an interior cell (plain black).
func _edge_tile(col: int, row: int) -> int:
	var up := not _solid(col, row - 1)
	var down := not _solid(col, row + 1)
	var left := not _solid(col - 1, row)
	var right := not _solid(col + 1, row)
	if up:
		return TILE_TL if left and not right else (TILE_TR if right and not left else TILE_T)
	if down:
		return TILE_BL if left and not right else (TILE_BR if right and not left else TILE_B)
	if left:
		return TILE_L
	if right:
		return TILE_R
	return -1


## For an interior cell at an inside corner, the two tiles that paint it: the surface
## running on under it, then the wall face continuing into it. Floor corners (solid
## above and beside, empty diagonally above): [TILE_T, face]. Ceiling corners (solid
## below and beside, empty diagonally below): [TILE_B, face]. Otherwise [].
func _inside_corner_tiles(col: int, row: int) -> Array:
	if _solid(col, row - 1):
		if not _solid(col - 1, row - 1) and _solid(col - 1, row):
			return [TILE_T, TILE_L]
		if not _solid(col + 1, row - 1) and _solid(col + 1, row):
			return [TILE_T, TILE_R]
	if _solid(col, row + 1):
		if not _solid(col - 1, row + 1) and _solid(col - 1, row):
			return [TILE_B, TILE_L]
		if not _solid(col + 1, row + 1) and _solid(col + 1, row):
			return [TILE_B, TILE_R]
	return []


## Paints every solid cell and builds the collision: one shape per run of cells in a row
## that share the same top and bottom insets, trimmed to the painted rock faces.
func _add_terrain(parent: Node2D) -> void:
	var k := CELL / TILE_SOURCE
	var body := StaticBody2D.new()
	parent.add_child(body)
	for row in grid.size():
		var run_start := -1
		var run_insets: Array = []
		var run_left := 0.0
		for col in grid[0].length() + 1:
			var solid: bool = col < grid[0].length() and _solid(col, row)
			var tile := _edge_tile(col, row) if solid else -1
			var corner: Array = _inside_corner_tiles(col, row) if solid and tile < 0 else []
			var insets: Array = TILE_INSETS[tile] if tile >= 0 else [0, 0, 0, 0]
			if not corner.is_empty():
				# The floor (or ceiling) beside it runs on under the wall face at its
				# surface height.
				insets = [TILE_INSETS[TILE_T][0], 0, 0, 0] if corner[0] == TILE_T \
						else [0, TILE_INSETS[TILE_B][1], 0, 0]
			var same: bool = solid and run_start >= 0 and insets[0] == run_insets[0] \
					and insets[1] == run_insets[1]
			if run_start >= 0 and not same:
				var prev_tile := _edge_tile(col - 1, row)
				var prev_insets: Array = TILE_INSETS[prev_tile] if prev_tile >= 0 else [0, 0, 0, 0]
				var x1: float = col * CELL - prev_insets[3] * k
				_add_box(body, Rect2(run_left, row * CELL + run_insets[0] * k,
						x1 - run_left, CELL - (run_insets[0] + run_insets[1]) * k))
				run_start = -1
			if solid and run_start < 0:
				run_start = col
				run_insets = insets
				run_left = col * CELL + insets[2] * k
			if not solid:
				continue
			if tile >= 0:
				_add_tile(parent, tile, col, row)
			elif not corner.is_empty():
				# Inside corner: the surface runs on under the wall face.
				_add_tile(parent, corner[0], col, row)
				var face := _add_tile(parent, corner[1], col, row)
				# The face would run a whole cell past the floor's lip; fade it out
				# across the lip instead (see TERRAIN_CORNER_FADES).
				var fade: Array = TERRAIN_CORNER_FADES["floor" if corner[0] == TILE_T else "ceiling"]
				_fade(face, false, fade[0], fade[1])
			else:
				var fill := Polygon2D.new()
				var p := Vector2(col * CELL, row * CELL)
				fill.polygon = PackedVector2Array([p, p + Vector2(CELL, 0),
						p + Vector2(CELL, CELL), p + Vector2(0, CELL)])
				fill.color = TERRAIN_COLOR
				parent.add_child(fill)


func _add_tile(parent: Node2D, tile: int, col: int, row: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + "terrain/tiles/tile-%02d.png" % tile)
	sprite.centered = false
	sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
	sprite.position = Vector2(col * CELL, row * CELL)
	parent.add_child(sprite)
	return sprite


func _add_box(body: StaticBody2D, rect: Rect2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = rect.get_center()
	body.add_child(collision)


func _add_island(parent: Node2D, island: Array) -> void:
	var bounds: Array = PROP_BOUNDS[island[0]]
	var s := _prop_scale()
	var sprite := _prop_sprite(parent, island[0])
	sprite.position = Vector2(island[1] - (bounds[0] + bounds[2]) * 0.5 * s, island[2] - island[3] * s)
	var body := StaticBody2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2((bounds[2] - bounds[0]) * s - 8.0, 8.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.one_way_collision = true
	body.position = Vector2(island[1], island[2] + 4.0)
	body.add_child(collision)
	parent.add_child(body)


## Background and midground: the background is scaled to cover the view at both ends
## of the room for its scroll scale; the midground repeats mirrored at a near-native
## size. Both are centred on the room when the camera is centred.
func _add_back_layers(parent: Node2D) -> void:
	var camera_travel := _room_size - VIEW_SIZE
	var index := -30
	for entry in BACK_LAYERS:
		var factor: float = entry[1]
		var repeats: bool = entry[2]
		var texture := _texture(BIOME + "parallax/%s.png" % entry[0])
		var needed := VIEW_SIZE + camera_travel * factor
		var image_scale := needed.y / texture.get_height() if repeats \
				else maxf(needed.x / texture.get_width(), needed.y / texture.get_height())
		var tile := texture.get_size() * image_scale
		var copies := int(ceil(needed.x / tile.x)) if repeats else 1
		var layer := _strip_layer(parent, texture, Rect2(Vector2.ZERO, texture.get_size()),
				image_scale, copies, index)
		index += 10
		var size := Vector2(tile.x * copies, tile.y)
		_layers.append([layer, Vector2(factor, factor), _room_size * 0.5 * factor - size * 0.5])


## A close scenery band (the close rocks, the close plants; see CLOSE_ROCKS): one
## stretch per run of floor, from [param folder]'s [param names] repeating (starting at
## [param first_piece]), scrolling sideways at [param scroll], its bottom [param sink]
## world px below the floor at full size. [param tallest]: the art's tallest point in
## source px above the canvas bottom, for fitting low headroom.
func _add_close_band(parent: Node2D, folder: String, names: Array, scroll: float,
		sink: float, tallest_px: float, first_piece: int) -> void:
	if folder.is_empty():
		return
	var pieces: Array[Texture2D] = []
	for piece in names:
		pieces.append(_texture(BIOME + folder + "%s.png" % piece))
	var image_scale := VIEW_SIZE.y / 1080.0
	var piece_size := pieces[0].get_size() * image_scale
	var tallest := tallest_px * image_scale
	var center_min := VIEW_SIZE * 0.5
	var center_max := _room_size - VIEW_SIZE * 0.5
	var next_piece := first_piece
	for run in _floor_runs():
		var row: int = run[0]
		var x0: float = run[1] * CELL
		var x1: float = (run[2] + 1) * CELL
		# A drop at an end (open air beside the floor): pull the rock in from the edge.
		# How far the stretch may drift each way: up to that inset towards a drop, one cell
		# towards a wall (the wall hides it).
		var drop_left := not _solid(run[1] - 1, row + 1)
		var drop_right := not _solid(run[2] + 1, row + 1)
		if drop_left:
			x0 += CLOSE_ROCKS_EDGE_INSET
		if drop_right:
			x1 -= CLOSE_ROCKS_EDGE_INSET
		var drift_left := CLOSE_ROCKS_DROP_DRIFT if drop_left else CELL
		var drift_right := CLOSE_ROCKS_DROP_DRIFT if drop_right else CELL
		var width := x1 - x0
		if width < CLOSE_ROCKS_MIN_RUN:
			continue
		var headroom: float = run[3] * CELL
		var size := minf(1.0, headroom * CLOSE_ROCKS_HEADROOM / tallest)
		if size < 1.0 and not CLOSE_ROCKS_IN_CAVES:
			continue
		var count := maxi(1, roundi(width / (piece_size.x * size)))
		var stretch := width / (count * piece_size.x)
		var layer := Node2D.new()
		layer.z_index = CLOSE_ROCKS_Z
		parent.add_child(layer)
		for i in count:
			var sprite := Sprite2D.new()
			sprite.texture = pieces[next_piece % pieces.size()]
			sprite.centered = false
			sprite.scale = Vector2(image_scale * stretch, image_scale * size)
			sprite.position = Vector2(i * piece_size.x * stretch, 0.0)
			layer.add_child(sprite)
			next_piece += 1
			# The stretch's ends: the pieces end in a low block of rubble; fade its last
			# CLOSE_ROCKS_END_FADE px so it trails off instead of stopping square.
			var fade_uv := CLOSE_ROCKS_END_FADE / (piece_size.x * stretch)
			var ends := Vector2(fade_uv if i == 0 else 0.0, fade_uv if i == count - 1 else 0.0)
			if ends != Vector2.ZERO:
				_end_fade(sprite, ends)
		# Where the stretch sits with the camera centred on it; it scrolls sideways at
		# [param scroll] around that, never drifting past its ends' limits, and stays on
		# its floor up and down.
		# The sink is not scaled with small (cave) rocks: the art's flat bottom must
		# always sit under the floor's lip.
		var spot := Vector2(x0, (row + 1) * CELL + sink - piece_size.y * size)
		var reference := clampf((x0 + x1) * 0.5, center_min.x, center_max.x)
		var factor := Vector2(scroll, 1.0)
		_layers.append([layer, factor, spot - Vector2(reference * (1.0 - scroll), 0.0),
				Vector2(spot.x - drift_left, spot.x + drift_right)])


## Fades [param sprite] in over its left [param ends].x and out over its right
## [param ends].y (fractions of its width).
func _end_fade(sprite: Sprite2D, ends: Vector2) -> void:
	if _end_fade_shader == null:
		_end_fade_shader = Shader.new()
		_end_fade_shader.code = END_FADE_SHADER
	var material := ShaderMaterial.new()
	material.shader = _end_fade_shader
	material.set_shader_parameter("ends", ends)
	sprite.material = material


## The room's floor runs: [row of the open cells, first column, last column, headroom in
## cells (open cells above each cell, the least along it)]. A run is a row of open cells
## standing on solid ones, broken where either changes or where the ceiling above
## changes height (so an open ledge and the low corridor it leads into are separate
## runs, each with rock sized to its own headroom).
func _floor_runs() -> Array:
	var runs := []
	for row in grid.size() - 1:
		var start := -1
		var start_room := -1
		for col in grid[0].length() + 1:
			var floor_cell: bool = col < grid[0].length() and not _solid(col, row) \
					and _solid(col, row + 1)
			var room := 0
			if floor_cell:
				while row - room >= 0 and not _solid(col, row - room):
					room += 1
			if start >= 0 and (not floor_cell or room != start_room):
				runs.append([row, start, col - 1, start_room])
				start = -1
			if floor_cell and start < 0:
				start = col
				start_room = room
	return runs


## Foreground: the open cave's loops (parallax/) over the open cave and the corridor's
## loops (corridor/brighter/) over the corridor, each set masked to its own part of the
## room with a soft blend at the corridor's mouth. Both sets live in the world and repeat
## sideways. Then the room-end borders.
func _add_foreground(parent: Node2D) -> void:
	var has_corridor := corridor_start_col >= 0
	var mouth := corridor_start_col * CELL if has_corridor else _room_size.x + LAYER_BLEND
	var open_mask := _blend_mask(parent, 0.0, mouth + LAYER_BLEND * 0.5, false, 10)
	var corridor_mask: Node2D = _blend_mask(parent, mouth - LAYER_BLEND * 0.5, _room_size.x,
			true, 10) if has_corridor else null
	var center_min := VIEW_SIZE * 0.5
	var center_max := _room_size - VIEW_SIZE * 0.5
	# Open cave: the top loop meets the screen's top with the camera at the room's top,
	# the bottom loop with the camera at the room's floor. Corridor: the camera stays at
	# the room's top there, so both loops are set for that height.
	_add_foreground_set(open_mask, "parallax/", center_min.y, center_max.y)
	if has_corridor:
		_add_foreground_set(corridor_mask, "corridor/brighter/", center_min.y, center_min.y)
	_add_middle_rim(parent)
	_add_silhouettes(parent)
	# Borders are fixed in the world at the room's ends (see BORDERS for their scale).
	for border in borders:
		var texture := _texture(BIOME + border[0])
		var height := _room_size.y if border[2] else VIEW_SIZE.y
		var image_scale := height / texture.get_height()
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.scale = Vector2.ONE * image_scale
		sprite.z_index = border[3]
		var width := texture.get_width() * image_scale
		var slide: float = border[4]
		sprite.position = Vector2(-slide if border[1] else _room_size.x - width + slide, 0.0)
		parent.add_child(sprite)


## The middle rim: for every exposed terrain edge cell, the kit's matching piece, set
## inside the solid on each exposed side, fixed in the world like the terrain.
func _add_middle_rim(parent: Node2D) -> void:
	var size := CELL * MIDDLE_PIECE_SCALE
	var featured := _add_middle_features(parent) if not MIDDLE_FILL.is_empty() else {}
	for row in grid.size():
		for col in grid[0].length():
			if not _solid(col, row):
				continue
			var tile := _edge_tile(col, row)
			if not MIDDLE_TILESET.is_empty():
				var tiles: Array = [tile] if tile >= 0 else _inside_corner_tiles(col, row)
				if not MIDDLE_FILL.is_empty() and not featured.has(Vector2i(col, row)):
					_add_middle_fill(parent, col, row, tiles)
				if tile < 0 and not tiles.is_empty():
					_add_middle_corner(parent, tiles[0], tiles[1], col, row)
					continue
				for each in tiles:
					_add_middle_tile(parent, each, col, row)
				continue
			if not MIDDLE_PIECES.has(tile):
				continue
			var inset := Vector2.ZERO
			if not _solid(col, row - 1):
				inset.y += MIDDLE_INSET
			if not _solid(col, row + 1):
				inset.y -= MIDDLE_INSET
			if not _solid(col - 1, row):
				inset.x += MIDDLE_INSET
			if not _solid(col + 1, row):
				inset.x -= MIDDLE_INSET
			var center := Vector2(col + 0.5, row + 0.5) * CELL + inset
			var spot := center - Vector2(size, size) * 0.5
			var layer := Node2D.new()
			layer.z_index = MIDDLE_Z
			parent.add_child(layer)
			var sprite := Sprite2D.new()
			sprite.texture = _texture(BIOME + "middle-foreground/pieces/%s.png" % MIDDLE_PIECES[tile])
			sprite.centered = false
			sprite.scale = Vector2.ONE * size / 512.0
			layer.add_child(sprite)
			layer.position = spot
	if not MIDDLE_TILESET.is_empty() and not MIDDLE_FILL.is_empty() and MIDDLE_PATCHES:
		_add_middle_patches(parent, featured)


## One tile of the modular foreground tileset at a terrain cell, moved MIDDLE_INSET px
## into the solid on each side its tile faces open air (an inside corner's base and face
## each move by their own side), fixed in the world like the terrain.
## An inside corner of the rim. The terrain paints these as the whole floor (or ceiling)
## tile plus the whole wall face, which ran the wall a full cell past the floor's lip.
## Here (fill already under the solid part) the lip fades out sideways behind the wall, and
## the wall face fades out at the lip (see MIDDLE_CORNER_FADES).
func _add_middle_corner(parent: Node2D, base: int, face: int, col: int, row: int) -> void:
	var floor_corner := base == TILE_T
	var sideways: Array = MIDDLE_CORNER_FADES["lip_left_wall" if face == TILE_L else "lip_right_wall"]
	var lip_tile := _add_middle_tile(parent, base, col, row)
	_fade(lip_tile, true, sideways[0], sideways[1])
	var down: Array = MIDDLE_CORNER_FADES["face_floor" if floor_corner else "face_ceiling"]
	var face_tile := _add_middle_tile(parent, face, col, row)
	face_tile.z_index += 1
	_fade(face_tile, false, down[0], down[1])


## Fades [param sprite] out along x ([param along_x]) or y: opaque at source px
## [param solid], clear at [param clear], linear between (either order).
func _fade(sprite: Sprite2D, along_x: bool, solid: float, clear: float) -> void:
	if _fade_shader == null:
		_fade_shader = Shader.new()
		_fade_shader.code = FADE_SHADER
	var material := ShaderMaterial.new()
	material.shader = _fade_shader
	material.set_shader_parameter("fade", Vector3(1.0 if along_x else 0.0,
			solid / TILE_SOURCE, clear / TILE_SOURCE))
	sprite.material = material


func _add_middle_tile(parent: Node2D, tile: int, col: int, row: int) -> Sprite2D:
	var inset := _middle_inset(tile)
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + MIDDLE_TILESET + "tile-%02d.png" % tile)
	sprite.centered = false
	sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
	sprite.position = Vector2(col * CELL, row * CELL) + inset
	# An outer corner moves on both axes, so it overlaps its neighbours by MIDDLE_INSET.
	# Drawn on top, its rim runs on over theirs (a small shift along the band) instead of
	# being cut off square by them.
	var outer_corner := tile in [TILE_TL, TILE_TR, TILE_BL, TILE_BR]
	sprite.z_index = MIDDLE_Z + (1 if outer_corner else 0)
	parent.add_child(sprite)
	return sprite


## How far a rim tile moves into the solid: MIDDLE_INSET px away from each side it faces.
func _middle_inset(tile: int) -> Vector2:
	var inset := Vector2.ZERO
	if tile in [TILE_TL, TILE_T, TILE_TR]:
		inset.y += MIDDLE_INSET
	if tile in [TILE_BL, TILE_B, TILE_BR]:
		inset.y -= MIDDLE_INSET
	if tile in [TILE_TL, TILE_L, TILE_BL]:
		inset.x += MIDDLE_INSET
	if tile in [TILE_TR, TILE_R, TILE_BR]:
		inset.x -= MIDDLE_INSET
	return inset


## Round fill patches over the fill's grid lines (see MIDDLE_PATCHES): one on every grid
## corner and every edge midpoint whose one-cell square stays in the solid, clear of each
## touched cell's open sides (the rim band and inset cover that depth) and of the large
## features. Drawn over the fill, under the rim.
func _add_middle_patches(parent: Node2D, featured: Dictionary) -> void:
	if _patch_shader == null:
		_patch_shader = Shader.new()
		_patch_shader.code = PATCH_SHADER
	var material := ShaderMaterial.new()
	material.shader = _patch_shader
	material.set_shader_parameter("radii", Vector2(MIDDLE_PATCH_SOLID, MIDDLE_PATCH_CLEAR))
	var clear_depth := 0.32 * CELL
	for row2 in grid.size() * 2 + 1:
		for col2 in grid[0].length() * 2 + 1:
			if col2 % 2 == 1 and row2 % 2 == 1:
				continue  # a cell's centre: no grid line there
			var center := Vector2(col2, row2) * CELL * 0.5
			var square := Rect2(center - Vector2.ONE * CELL * 0.5, Vector2.ONE * CELL)
			if not _patch_fits(square, featured, clear_depth):
				continue
			var variant := posmod(hash(Vector2i(col2 * 3 + 1, row2 * 5 + 2)), MIDDLE_FILL_VARIANTS)
			var sprite := Sprite2D.new()
			sprite.texture = _texture(BIOME + MIDDLE_FILL + "fill-%02d.png" % variant)
			sprite.centered = false
			sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
			sprite.position = square.position
			sprite.z_index = MIDDLE_Z - 1
			sprite.material = material
			parent.add_child(sprite)


## True when a patch's [param square] lies on solid cells only, none featured or an inside
## corner, and within [param clear_depth] of no touched cell's open side.
func _patch_fits(square: Rect2, featured: Dictionary, clear_depth: float) -> bool:
	var first := Vector2i((square.position / CELL).floor())
	var last := Vector2i(((square.end - Vector2.ONE * 0.01) / CELL).floor())
	for row in range(first.y, last.y + 1):
		for col in range(first.x, last.x + 1):
			if col < 0 or row < 0 or col >= grid[0].length() or row >= grid.size():
				return false
			if not _solid(col, row) or featured.has(Vector2i(col, row)):
				return false
			if _edge_tile(col, row) < 0 and not _inside_corner_tiles(col, row).is_empty():
				return false
			var cell := Rect2(Vector2(col, row) * CELL, Vector2.ONE * CELL)
			if not _solid(col, row - 1) and square.position.y < cell.position.y + clear_depth:
				return false
			if not _solid(col, row + 1) and square.end.y > cell.end.y - clear_depth:
				return false
			if not _solid(col - 1, row) and square.position.x < cell.position.x + clear_depth:
				return false
			if not _solid(col + 1, row) and square.end.x > cell.end.x - clear_depth:
				return false
	return true


## True for an interior cell (solid, not an edge, not an inside corner): where the large
## features may go.
func _fill_cell(col: int, row: int) -> bool:
	return _solid(col, row) and col >= 0 and row >= 0 and col < grid[0].length() \
			and row < grid.size() and _edge_tile(col, row) < 0 \
			and _inside_corner_tiles(col, row).is_empty()


## Places the large 2x2 rock features (see MIDDLE_FEATURES) and returns the cells they
## cover, so the fill skips them. Scans top-left to bottom-right; a block is taken only
## when all four cells are free fill cells, so features never overlap or touch an edge.
func _add_middle_features(parent: Node2D) -> Dictionary:
	var covered := {}
	if MIDDLE_FEATURES.is_empty():
		return covered
	for row in grid.size() - 1:
		for col in grid[0].length() - 1:
			var block: Array[Vector2i] = [Vector2i(col, row), Vector2i(col + 1, row),
					Vector2i(col, row + 1), Vector2i(col + 1, row + 1)]
			var free := true
			for cell in block:
				if covered.has(cell) or not _fill_cell(cell.x, cell.y):
					free = false
					break
			if not free:
				continue
			var roll := hash(Vector2i(col * 31 + 7, row * 17 + 3))
			if posmod(roll, MIDDLE_FEATURE_CHANCE) != 0:
				continue
			for cell in block:
				covered[cell] = true
			var texture := _texture(BIOME + MIDDLE_FEATURES[posmod(roll / 7, MIDDLE_FEATURES.size())])
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.scale = Vector2.ONE * 2.0 * CELL / texture.get_width()
			sprite.position = Vector2(col * CELL, row * CELL)
			sprite.z_index = MIDDLE_Z - 1
			parent.add_child(sprite)
	return covered


## One wall-fill tile over a solid cell, under the rim's edge tiles. [param masks]: the
## cell's rim tiles (one for an edge, base and face for an inside corner); the fill is
## then cut to their solid part, so it never shows in the open air beside an edge.
func _add_middle_fill(parent: Node2D, col: int, row: int, masks: Array = []) -> Sprite2D:
	var variant := posmod(hash(Vector2i(col, row)), MIDDLE_FILL_VARIANTS)
	var sprite := Sprite2D.new()
	sprite.texture = _texture(BIOME + MIDDLE_FILL + "fill-%02d.png" % variant)
	sprite.centered = false
	sprite.scale = Vector2.ONE * CELL / TILE_SOURCE
	sprite.position = Vector2(col * CELL, row * CELL)
	sprite.z_index = MIDDLE_Z - 1
	if not masks.is_empty():
		if _mask_shader == null:
			_mask_shader = Shader.new()
			_mask_shader.code = MASK_SHADER
		var material := ShaderMaterial.new()
		material.shader = _mask_shader
		var keys := ["a", "b"]
		for i in mini(masks.size(), 2):
			var tile: int = masks[i]
			material.set_shader_parameter("mask_" + keys[i],
					_texture(BIOME + MIDDLE_MASKS + "tile-%02d.png" % tile))
			material.set_shader_parameter("shift_" + keys[i], _middle_inset(tile) / CELL)
		material.set_shader_parameter("use_b", 1.0 if masks.size() > 1 else 0.0)
		sprite.material = material
	parent.add_child(sprite)
	return sprite


## One set of top and bottom foreground loops from [param folder], under [param mask].
## [param top_ref] and [param bottom_ref] are the camera heights at which each loop's
## canvas meets the screen's top.
func _add_foreground_set(mask: Node2D, folder: String, top_ref: float, bottom_ref: float) -> void:
	var camera_travel := _room_size - VIEW_SIZE
	var center_min := VIEW_SIZE * 0.5
	for strip in FOREGROUND_STRIPS:
		var texture := _texture(BIOME + folder + "%s.png" % strip)
		var image_scale := VIEW_SIZE.y / texture.get_height()
		var period := texture.get_width() * image_scale
		var copies := int(ceil((VIEW_SIZE.x + camera_travel.x * FOREGROUND_SCALE.x) / period)) + 1
		var layer := _strip_layer(mask, texture, Rect2(Vector2.ZERO, texture.get_size()),
				image_scale, copies, 0, false)
		var reference_y := top_ref if strip == "foreground-top" else bottom_ref
		# On screen: top-left = base - scale * centre + VIEW_SIZE / 2. Solve for the base
		# that puts the canvas top at the screen's top at the reference height, and its
		# left edge at the screen's left at the room's left.
		var base := FOREGROUND_SCALE * Vector2(center_min.x, reference_y) - VIEW_SIZE * 0.5
		_layers.append([layer, FOREGROUND_SCALE, base])
		if strip == "foreground-bottom":
			_add_skirt(layer, texture, image_scale, copies * period)


## Moves the silhouette band by its lagging sway (see SILHOUETTE_SWAY) for the camera
## centred on [param center]; call after the band has been placed for this frame.
func _sway_silhouettes(center: Vector2) -> void:
	if _silhouette_layer == null:
		return
	var now := Time.get_ticks_usec()
	var delta := (now - _silhouette_ticks) / 1000000.0 if _silhouette_ticks > 0 else 0.0
	_silhouette_ticks = now
	if is_nan(_silhouette_lag_y):
		_silhouette_lag_y = center.y
	_silhouette_lag_y = lerpf(_silhouette_lag_y, center.y, 1.0 - exp(-delta / SILHOUETTE_LAG))
	var drift := clampf((_silhouette_lag_y - center.y) * SILHOUETTE_SWAY,
			-SILHOUETTE_MAX_DRIFT, SILHOUETTE_MAX_DRIFT)
	_silhouette_layer.position.y += drift


## The black silhouette foliage (see SILHOUETTES) as one repeating A-B-C layer.
func _add_silhouettes(parent: Node2D) -> void:
	if SILHOUETTES.is_empty():
		return
	var image_scale := VIEW_SIZE.y / 1080.0
	var layer := Node2D.new()
	layer.z_index = SILHOUETTE_Z
	parent.add_child(layer)
	var needed := VIEW_SIZE.x + (_room_size.x - VIEW_SIZE.x) * FOREGROUND_SCALE.x
	var x := 0.0
	var i := 0
	while x < needed:
		var texture := _texture(SILHOUETTES + "%s.png" % SILHOUETTE_PIECES[i % SILHOUETTE_PIECES.size()])
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.scale = Vector2.ONE * image_scale
		sprite.position = Vector2(x, SILHOUETTE_TOP * image_scale)
		layer.add_child(sprite)
		x += texture.get_width() * image_scale
		i += 1
	# Sideways: the canvas's left edge meets the screen's left at the room's left.
	# Up and down: scroll factor 0, so the canvas top stays on the screen's top.
	var factor := Vector2(FOREGROUND_SCALE.x, 0.0)
	var base := Vector2(FOREGROUND_SCALE.x * VIEW_SIZE.x * 0.5, 0.0) - VIEW_SIZE * 0.5
	_layers.append([layer, factor, base])
	_silhouette_layer = layer
	var black := Polygon2D.new()
	var top := VIEW_SIZE.y - 1.0
	black.polygon = PackedVector2Array([Vector2(0, top), Vector2(x, top),
			Vector2(x, top + SILHOUETTE_MAX_DRIFT + 8.0), Vector2(0, top + SILHOUETTE_MAX_DRIFT + 8.0)])
	black.color = Color.BLACK
	layer.add_child(black)


## A strip of the bottom loop's own bottom-row colour hanging under it, one screen tall:
## when the camera sits lower than the loop's reference height, the loop rises (it
## scrolls faster than the room) and this keeps the wall fill from showing under it.
func _add_skirt(layer: Node2D, texture: Texture2D, image_scale: float, width: float) -> void:
	var image := texture.get_image()
	if image.is_compressed():
		image.decompress()
	var total := Color(0, 0, 0, 0)
	var y := image.get_height() - 1
	var samples := 64
	for i in samples:
		total += image.get_pixel(int((i + 0.5) * image.get_width() / samples), y)
	var colour := total / samples
	colour.a = 1.0
	var top := texture.get_height() * image_scale - 1.0
	var skirt := Polygon2D.new()
	skirt.polygon = PackedVector2Array([Vector2(0, top), Vector2(width, top),
			Vector2(width, top + VIEW_SIZE.y), Vector2(0, top + VIEW_SIZE.y)])
	skirt.color = colour
	layer.add_child(skirt)


## The corridor's close rear wall: a loop just behind the play layer (scroll scale 0.85),
## masked to the corridor so the open cave keeps its distant background.
func _add_corridor_wall(parent: Node2D) -> void:
	if corridor_start_col < 0:
		return
	var mouth := corridor_start_col * CELL
	var mask := _blend_mask(parent, mouth - LAYER_BLEND * 0.5, _room_size.x, true, -10)
	var texture := _texture(BIOME + "corridor/background-loop.png")
	var image_scale := VIEW_SIZE.y / texture.get_height()
	var period := texture.get_width() * image_scale
	var factor := Vector2(CORRIDOR_WALL_SCALE, CORRIDOR_WALL_SCALE)
	var center_min := VIEW_SIZE * 0.5
	# Long enough to cover the corridor's whole width plus the screen at both ends.
	var needed := (_room_size.x - mouth) + VIEW_SIZE.x * 2.0
	var copies := int(ceil(needed / period)) + 1
	var layer := _strip_layer(mask, texture, Rect2(Vector2.ZERO, texture.get_size()),
			image_scale, copies, 0, false)
	# Its left edge sits a screen left of the mouth when the camera is at the mouth, and
	# its top meets the screen's top with the camera at the room's top.
	var mouth_center := mouth
	var base := Vector2(mouth - VIEW_SIZE.x - mouth_center * (1.0 - factor.x),
			factor.y * center_min.y - VIEW_SIZE.y * 0.5)
	_layers.append([layer, factor, base])


## A world-space mask from [param x0] to [param x1] over the room's full height whose
## children draw only inside it, fading over [constant LAYER_BLEND] at the corridor's
## mouth: in from the left when [param fade_in_left], else out to the right.
func _blend_mask(parent: Node2D, x0: float, x1: float, fade_in_left: bool, z: int) -> Node2D:
	var mask := Polygon2D.new()
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.z_index = z
	var h := _room_size.y
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	var clear := Color(1, 1, 1, 0)
	var solid := Color(1, 1, 1, 1)
	if fade_in_left:
		var xb := x0 + LAYER_BLEND
		points = PackedVector2Array([Vector2(x0, 0), Vector2(xb, 0), Vector2(x1, 0),
				Vector2(x1, h), Vector2(xb, h), Vector2(x0, h)])
		colors = PackedColorArray([clear, solid, solid, solid, solid, clear])
	else:
		var xb := x1 - LAYER_BLEND
		points = PackedVector2Array([Vector2(x0, 0), Vector2(xb, 0), Vector2(x1, 0),
				Vector2(x1, h), Vector2(xb, h), Vector2(x0, h)])
		colors = PackedColorArray([solid, solid, clear, clear, solid, solid])
	mask.polygon = points
	mask.vertex_colors = colors
	# Two quads, so the fade interpolates across the blend band only.
	mask.polygons = [PackedInt32Array([0, 1, 4, 5]), PackedInt32Array([1, 2, 3, 4])]
	parent.add_child(mask)
	return mask


## A layer of [param copies] side-by-side copies of one region of a texture. With
## [param mirror], every other copy is flipped so the seams of a non-looping painting meet.
func _strip_layer(parent: Node2D, texture: Texture2D, region: Rect2, image_scale: float,
		copies: int, z: int, mirror := true) -> Node2D:
	var layer := Node2D.new()
	layer.z_index = z
	for i in copies:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.region_enabled = true
		sprite.region_rect = region
		sprite.scale = Vector2.ONE * image_scale
		sprite.position = Vector2(i * region.size.x * image_scale, 0.0)
		sprite.flip_h = mirror and i % 2 == 1
		layer.add_child(sprite)
	parent.add_child(layer)
	return layer
