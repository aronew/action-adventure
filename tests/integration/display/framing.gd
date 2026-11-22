extends SceneTree
## ADR-0002 display criterion: with the project's 1920 x 1080 base, a window of any size
## (letterboxed when it is not 16:9) shows exactly one 480 x 270 screen of world, and the
## Seeker's camera is at zoom 4. Run under a window (a virtual display is fine) at the size to check:
##   xvfb-run -a godot --path . --resolution 1440x810 --rendering-method gl_compatibility \
##       --rendering-driver opengl3 -s res://tests/integration/display/framing.gd
## Optional user arg: a room scene path (default: the movement test room).
## Exits 0 and prints PASS, or exits 1 and prints FAIL with the measured values.

const DEFAULT_ROOM := "res://src/test_rooms/movement_test_room.tscn"
const EXPECTED_WORLD := Vector2(480, 270)
const TOLERANCE := 0.01
var _frame := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var path: String = args[0] if args.size() > 0 else DEFAULT_ROOM
	root.add_child((load(path) as PackedScene).instantiate())


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame < 30:
		return false
	var viewport := root.get_viewport()
	var camera := viewport.get_camera_2d()
	var scale_xy := (viewport.get_final_transform() * viewport.get_canvas_transform()).get_scale()
	var window := Vector2(root.get_window().size)
	# The base canvas (visible rect) over the zoom is the world the camera shows; a window
	# that is not 16:9 is letterboxed, so the view is still one screen.
	var world := viewport.get_visible_rect().size / (camera.zoom if camera != null else Vector2.ONE)
	var ok := camera != null and camera.zoom.is_equal_approx(Vector2(4, 4)) \
			and (world - EXPECTED_WORLD).length() < TOLERANCE
	print("%s window=%s zoom=%s total_scale=%s world_px_shown=%s" % ["PASS" if ok else "FAIL",
			window, camera.zoom if camera != null else "no camera", scale_xy, world])
	quit(0 if ok else 1)
	return true
