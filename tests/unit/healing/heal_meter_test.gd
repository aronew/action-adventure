## Unit tests for HealMeter and PlayerHealth.heal (design/gdd/healing.md, simplified).
## Run: godot --headless --path . -s res://tests/unit/healing/heal_meter_test.gd
extends MiniTest

const CAPACITY := 100.0


func _meter() -> HealMeter:
	var meter := HealMeter.new()
	meter.configure(CAPACITY)
	return meter


func test_new_meter_is_empty_and_not_full() -> void:
	var meter := _meter()
	assert_eq(meter.amount, 0.0, "amount")
	assert_eq(meter.is_full(), false, "full")


func test_hits_fill_until_full() -> void:
	var meter := _meter()
	for i in 9:
		meter.add(10.0)
	assert_eq(meter.is_full(), false, "9 hits of 10")
	meter.add(10.0)
	assert_eq(meter.is_full(), true, "10 hits of 10")


func test_overfill_is_capped() -> void:
	var meter := _meter()
	meter.add(250.0)
	assert_eq(meter.amount, CAPACITY, "capped")


func test_spend_empties_the_meter() -> void:
	var meter := _meter()
	meter.add(CAPACITY)
	meter.spend()
	assert_eq(meter.amount, 0.0, "after spend")


func test_heal_restores_up_to_max() -> void:
	var health := PlayerHealth.new()
	health.configure(100.0, 1.0)
	health.take_damage(50.0)
	assert_eq(health.heal(30.0), 30.0, "first heal")
	assert_eq(health.current, 80.0, "health after first heal")
	assert_eq(health.heal(30.0), 20.0, "second heal capped")
	assert_eq(health.current, 100.0, "full")
	assert_eq(health.is_hurt(), false, "not hurt at max")


func test_heal_does_nothing_at_zero_health() -> void:
	var health := PlayerHealth.new()
	health.configure(100.0, 0.0)
	health.take_damage(100.0)
	assert_eq(health.heal(30.0), 0.0, "dead")
