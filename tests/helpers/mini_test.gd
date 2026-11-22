## A tiny stand-in for gdUnit4 (not installed yet; run /test-setup): a SceneTree that runs
## every method named `test_<scenario>_<expected>` in the subclass and exits 0 or 1.
## Assertions record a failure and carry on, so one run lists every failure.
##
## Usage: [codeblock]
## extends MiniTest
## func test_floor_has_one_face() -> void:
##     assert_eq(faces.size(), 1, "faces")
## # godot --headless --path . -s res://tests/unit/terrain/terrain_builder_test.gd
## [/codeblock]
class_name MiniTest
extends SceneTree

var _failures := 0
var _checks := 0
var _current := ""


func _initialize() -> void:
	var names: Array[String] = []
	for method in get_script().get_script_method_list():
		if String(method.name).begins_with("test_"):
			names.append(method.name)
	names.sort()
	var failed_tests := 0
	for test_name in names:
		_current = test_name
		var before := _failures
		await call(test_name)
		print("%s %s" % ["PASS" if _failures == before else "FAIL", test_name])
		if _failures != before:
			failed_tests += 1
	print("%d tests, %d failed, %d checks, %d check failures" % [names.size(), failed_tests, _checks, _failures])
	quit(1 if _failures > 0 else 0)


func assert_true(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		print("  FAIL [%s] %s" % [_current, label])


func assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	_checks += 1
	if actual != expected:
		_failures += 1
		print("  FAIL [%s] %s: expected %s, got %s" % [_current, label, str(expected), str(actual)])


func assert_near(actual: float, expected: float, tolerance: float, label: String) -> void:
	_checks += 1
	if absf(actual - expected) > tolerance:
		_failures += 1
		print("  FAIL [%s] %s: expected %s +- %s, got %s" % [_current, label, str(expected), str(tolerance), str(actual)])
