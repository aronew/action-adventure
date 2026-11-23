## The Seeker's heal meter (design/gdd/healing.md, simplified 2026-11-23): landing hits on
## foes fills it, and a full meter pays for one heal. Like Hollow Knight's soul for Focus.
##
## Pure logic: no nodes, no input. [Player] owns it, feeds it with [method add] on every
## landed hit and spends it with [method spend] when a heal completes.
##
## Usage: [codeblock]
## var meter := HealMeter.new()
## meter.configure(120.0)
## meter.add(30.0)
## if meter.is_full():
##     meter.spend()
## [/codeblock]
class_name HealMeter
extends RefCounted

## Emitted whenever the stored amount changes, with the new amount and the capacity.
signal changed(amount: float, capacity: float)

## Fill needed for one heal (read only; set through configure).
var capacity := 0.0
## Current fill, 0 to [member capacity] (read only).
var amount := 0.0


## Sets the capacity and empties the meter.
func configure(meter_capacity: float) -> void:
	capacity = meter_capacity
	reset()


## Adds [param fill]; anything above [member capacity] is lost.
func add(fill: float) -> void:
	if fill <= 0.0:
		return
	_set_amount(minf(amount + fill, capacity))


## True when the meter holds enough for a heal.
func is_full() -> bool:
	return capacity > 0.0 and amount >= capacity


## Empties the meter (a heal spent it, or a hit broke the heal).
func spend() -> void:
	_set_amount(0.0)


## Empties the meter (death, new game).
func reset() -> void:
	_set_amount(0.0)


## Fill as a share of the capacity, 0 to 1.
func ratio() -> float:
	return amount / capacity if capacity > 0.0 else 0.0


func _set_amount(value: float) -> void:
	if is_equal_approx(value, amount) and value != 0.0:
		return
	amount = value
	changed.emit(amount, capacity)
