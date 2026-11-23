## Integration test: the Seeker heals in the enemy test room (design/gdd/healing.md,
## simplified). Real Player node, real physics; the heal input is pressed through Input.
## Run: godot --headless --path . -s res://tests/integration/healing/heal_channel_test.gd
extends MiniTest

const ROOM := preload("res://src/test_rooms/enemy_test_room.tscn")


func _room_player() -> Player:
	var room := ROOM.instantiate()
	root.add_child(room)
	await process_frame
	return room.get("_player") as Player


func _clear(player: Player) -> void:
	Input.action_release(&"heal")
	player.get_parent().queue_free()
	await process_frame


func _settle(frames: int) -> void:
	for i in frames:
		await physics_frame


func test_full_meter_held_heal_restores_health_and_empties_meter() -> void:
	var player: Player = await _room_player()
	await _settle(30)
	player.health.take_damage(50.0)
	player.health.tick(5.0)
	player.heal_meter.add(player.heal_meter.capacity)
	Input.action_press(&"heal")
	await _settle(2)
	assert_eq(player.state, Player.State.HEAL, "planted in HEAL")
	await _settle(70)
	assert_eq(player.health.current, 80.0, "50 + 30")
	assert_eq(player.heal_meter.amount, 0.0, "meter spent")
	assert_eq(player.state, Player.State.GROUND, "back on the ground")
	await _clear(player)


func test_letting_go_early_keeps_meter_and_heals_nothing() -> void:
	var player: Player = await _room_player()
	await _settle(30)
	player.health.take_damage(50.0)
	player.heal_meter.add(player.heal_meter.capacity)
	Input.action_press(&"heal")
	await _settle(20)
	Input.action_release(&"heal")
	await _settle(5)
	assert_eq(player.health.current, 50.0, "no heal")
	assert_eq(player.heal_meter.is_full(), true, "meter kept")
	await _clear(player)


func test_hit_during_heal_cancels_and_empties_meter() -> void:
	var player: Player = await _room_player()
	await _settle(30)
	player.health.take_damage(50.0)
	player.health.tick(5.0)
	player.heal_meter.add(player.heal_meter.capacity)
	Input.action_press(&"heal")
	await _settle(20)
	player.take_hit(10.0, player.global_position + Vector2(20, 0))
	assert_eq(player.state, Player.State.HURT, "hurt")
	assert_eq(player.heal_meter.amount, 0.0, "meter lost")
	await _settle(70)
	assert_eq(player.health.current, 40.0, "no heal after the hit")
	await _clear(player)


func test_heal_refused_without_full_meter_or_at_full_health() -> void:
	var player: Player = await _room_player()
	await _settle(30)
	player.heal_meter.add(player.heal_meter.capacity)
	Input.action_press(&"heal")
	await _settle(3)
	assert_eq(player.state == Player.State.HEAL, false, "full health: no heal")
	Input.action_release(&"heal")
	player.heal_meter.spend()
	player.health.take_damage(40.0)
	await _settle(2)
	Input.action_press(&"heal")
	await _settle(3)
	assert_eq(player.state == Player.State.HEAL, false, "empty meter: no heal")
	await _clear(player)
