## Performance bench for the art-style rooms (level design Open Question 22: what a large
## painted room costs). Run one room per process, so the first load is a cold one:
##
##   godot --path . --resolution 1920x1080 res://tests/performance/art_room_bench.tscn \
##       -- --room=res://src/test_rooms/art_style_long_room.tscn --label=long --out=<dir>
##
## It measures, in order:
## - cold load: from load() of the room scene to the end of its first drawn frame, which
##   includes reading every texture from disk (the first entry into a biome);
## - memory and scene size once settled (texture, video and buffer memory, static memory,
##   node and object counts);
## - a camera sweep over the whole room (a top pass left to right, a bottom pass back),
##   with per-frame wall-clock time, the viewport's measured CPU and GPU render time and
##   draw calls; screenshots at five points of the sweep;
## - warm reload: the room freed and built again with its textures already cached, which
##   stands for an open-edge exit into another room of the same biome.
## Results go to <out>/<label>.json and to stdout. Observations only, no pass or fail.
extends Node

## Frames waited after the first draw before memory is read.
const SETTLE_FRAMES := 30
## Frames per sweep pass (two passes).
const PASS_FRAMES := 300
## Sweep frames at which a screenshot is saved.
const SHOT_FRAMES := [0, 150, 299, 450, 599]
## Half a screen in world px: the sweep path stays this far inside the room's edges.
const HALF_VIEW := Vector2(240, 135)

var _out_dir := ""
var _label := "room"


func _ready() -> void:
	var args := _user_args()
	var room_path: String = args.get("room", "res://src/test_rooms/art_style_test_room.tscn")
	_out_dir = args.get("out", "user://bench")
	_label = args.get("label", "room")
	DirAccess.make_dir_recursive_absolute(_out_dir)
	var viewport_rid := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(viewport_rid, true)

	var result := {"room": room_path, "label": _label}
	var start := Time.get_ticks_usec()
	var packed := load(room_path) as PackedScene
	var room := packed.instantiate()
	add_child(room)
	var built := Time.get_ticks_usec()
	await RenderingServer.frame_post_draw
	var drawn := Time.get_ticks_usec()
	result["cold_build_ms"] = (built - start) / 1000.0
	result["cold_first_frame_ms"] = (drawn - start) / 1000.0
	result["window_size"] = [get_window().size.x, get_window().size.y]

	for i in SETTLE_FRAMES:
		await get_tree().process_frame
	result["memory_settled"] = _monitors()
	result["room_size_px"] = _room_size(room)

	result["sweep"] = await _sweep(room, viewport_rid)
	result["memory_after_sweep"] = _monitors()

	room.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	start = Time.get_ticks_usec()
	room = packed.instantiate()
	add_child(room)
	built = Time.get_ticks_usec()
	await RenderingServer.frame_post_draw
	drawn = Time.get_ticks_usec()
	result["warm_build_ms"] = (built - start) / 1000.0
	result["warm_first_frame_ms"] = (drawn - start) / 1000.0
	for i in SETTLE_FRAMES:
		await get_tree().process_frame
	result["memory_after_reload"] = _monitors()

	var text := JSON.stringify(result, "  ")
	var file := FileAccess.open(_out_dir.path_join(_label + ".json"), FileAccess.WRITE)
	file.store_string(text)
	file.close()
	print("BENCH_RESULT ", JSON.stringify(result))
	get_tree().quit()


## Moves the Seeker along a path that covers the room (top band left to right, bottom
## band right to left) with its own processing off, so the camera follows a known path.
func _sweep(room: Node, viewport_rid: RID) -> Dictionary:
	var player := _find_player(room)
	var size := _room_size(room)
	player.set_physics_process(false)
	player.set_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	var top := HALF_VIEW.y
	var bottom := maxf(size.y - HALF_VIEW.y, top)
	var left := HALF_VIEW.x
	var right := maxf(size.x - HALF_VIEW.x, left)
	var wall_ms: Array[float] = []
	var cpu_ms: Array[float] = []
	var gpu_ms: Array[float] = []
	var draw_calls: Array[float] = []
	var objects: Array[float] = []
	var last := Time.get_ticks_usec()
	for frame in PASS_FRAMES * 2:
		var t := float(frame % PASS_FRAMES) / float(PASS_FRAMES - 1)
		var point := Vector2(lerpf(left, right, t), top) if frame < PASS_FRAMES \
				else Vector2(lerpf(right, left, t), bottom)
		player.global_position = point
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		wall_ms.append((now - last) / 1000.0)
		last = now
		cpu_ms.append(RenderingServer.viewport_get_measured_render_time_cpu(viewport_rid))
		gpu_ms.append(RenderingServer.viewport_get_measured_render_time_gpu(viewport_rid))
		draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		objects.append(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
		if frame in SHOT_FRAMES:
			var image := get_viewport().get_texture().get_image()
			image.save_png(_out_dir.path_join("%s-sweep-%03d.png" % [_label, frame]))
	return {
		"frames": wall_ms.size(),
		"wall_ms": _stats(wall_ms),
		"render_cpu_ms": _stats(cpu_ms),
		"render_gpu_ms": _stats(gpu_ms),
		"draw_calls": _stats(draw_calls),
		"objects_drawn": _stats(objects),
	}


func _monitors() -> Dictionary:
	return {
		"texture_mem_mb": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		"video_mem_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"buffer_mem_mb": Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0,
		"static_mem_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"objects": Performance.get_monitor(Performance.OBJECT_COUNT),
	}


## Mean, median, 95th percentile and maximum of a sample, skipping the first 5 frames.
func _stats(values: Array[float]) -> Dictionary:
	var sample := values.slice(5) if values.size() > 10 else values.duplicate()
	sample.sort()
	var total := 0.0
	for v in sample:
		total += v
	var n := sample.size()
	return {
		"mean": total / n,
		"median": sample[n / 2],
		"p95": sample[mini(int(n * 0.95), n - 1)],
		"max": sample[n - 1],
	}


func _find_player(room: Node) -> Node2D:
	for child in room.get_children():
		if child is Player:
			return child
	return null


func _room_size(room: Node) -> Vector2:
	var grid: Array = room.get("grid")
	return Vector2(grid[0].length(), grid.size()) * 36.0


func _user_args() -> Dictionary:
	var args := {}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--") and "=" in arg:
			var pair := arg.substr(2).split("=", true, 1)
			args[pair[0]] = pair[1]
	return args
