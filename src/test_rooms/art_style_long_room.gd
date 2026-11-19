## Art-style long room (throwaway): the art-style test room stretched to about 10
## screens (5 wide x 2 tall, 2412 x 540 world px), to measure what a large painted room
## costs in memory, load time and frame time (level design rule 1 and Open Question 22:
## rooms of 6-20 screens, left by open edges). Same biome, art, scale and camera as
## [code]art_style_test_room.gd[/code]; only the layout differs. The layout reads like a
## real room: a start hall, a pit, a raised mass, an overhang, a stepped climb, a tall
## chamber with floating islands and a high ledge at the end. Every rise is at most 72 px,
## inside the double jump, so the whole room can be walked. Test-room constants only.
extends "res://src/test_rooms/art_style_test_room.gd"

## The room in cells (36 px, '#' solid): 67 x 15.
const LONG_GRID := [
	"###################################################################",
	".................................######............................",
	".................................######............................",
	".................................######............................",
	".................................######............................",
	"...........................................................########",
	"...............................................####........########",
	"...............................................####........########",
	"............................................#######........########",
	"............................................#######........########",
	".........................######..........##########........########",
	"......................#########..........##########........########",
	"################......#############################........########",
	"###################################################################",
	"###################################################################",
]
## Floating islands: prop, centre x, surface y (world), surface y in the source image.
const LONG_ISLANDS := [
	["platform-short", 420.0, 380.0, 67.0],
	["platform-medium", 690.0, 400.0, 78.0],
	["platform-medium", 1900.0, 405.0, 78.0],
	["platform-short", 2000.0, 330.0, 67.0],
	["platform-long", 2080.0, 250.0, 96.0],
]
## Ground props: prop, left x, the surface they stand on (world y).
## Surface of a floor whose top cell is row r: r * 36 + 5.5 (the top tile's inset).
const LONG_GROUND_PROPS := [
	["wall-left", 4.0, 437.5],
	["rocks-small", 150.0, 437.5],
	["ruin-prop", 230.0, 437.5],
	["rocks-large", 920.0, 365.5],
	["decoration-low", 1250.0, 437.5],
	["decoration-tall", 1700.0, 221.5],
	["rocks-small", 1950.0, 473.5],
	["wall-right", 2330.0, 185.5],
]
## Hanging props: prop, left x, only where the ceiling is the room's top row.
const LONG_HANGING_PROPS := [
	["ceiling-overhang", 280.0],
	["hanging-decoration", 560.0],
	["ceiling-overhang", 1500.0],
	["hanging-decoration", 1980.0],
]
const LONG_SPAWN_POINT := Vector2(96, 404)
const LONG_HELP_TEXT := "Art-style long room: about 10 screens of Cinderheart Caldera, Seeker at 4x.\nArrows/WASD move  Space/Z jump x2  Shift/C dash  E grapple  X attack"


func _init() -> void:
	grid = LONG_GRID
	islands = LONG_ISLANDS
	ground_props = LONG_GROUND_PROPS
	hanging_props = LONG_HANGING_PROPS
	spawn_point = LONG_SPAWN_POINT
	help_text = LONG_HELP_TEXT
	# This room has no corridor: the open cave's layers cover all of it, and it keeps the
	# open cave's right border at its far end.
	corridor_start_col = -1
	corridor_ground_props = []
	corridor_hanging_props = []
	borders = [
		["middle-strips/border-left.png", true, true, MIDDLE_Z, 62.0],
		["parallax/border-right.png", false, true, 12, 0.0],
	]
