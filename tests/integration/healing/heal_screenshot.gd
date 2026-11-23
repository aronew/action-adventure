## Captures the heal mid-channel in the boss arena, for production/qa/evidence/.
## Run (needs a display): xvfb-run godot --path . -s res://tests/integration/healing/heal_screenshot.gd
extends SceneTree

const ARENA := preload("res://src/enemies/boss/boss_arena.tscn")
const OUT := "res://production/qa/evidence/healing-channel.png"


func _initialize() -> void:
	var arena := ARENA.instantiate()
	root.add_child(arena)
	for i in 20:
		await physics_frame
	var player: Player = arena.get("_player")
	player.take_hit(40.0, player.global_position + Vector2(20, 0))
	for i in 90:
		await physics_frame
	player.heal_meter.add(player.heal_meter.capacity)
	Input.action_press(&"heal")
	for i in 45:
		await physics_frame
	await process_frame
	var image := root.get_texture().get_image()
	image.save_png(OUT)
	print("state=%d health=%.0f meter=%.0f saved %s" % [player.state, player.health.current, player.heal_meter.amount, OUT])
	Input.action_release(&"heal")
	quit()
