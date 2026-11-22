extends SceneTree
func _initialize() -> void:
	var world := Node2D.new(); root.add_child(world)
	var body := StaticBody2D.new(); world.add_child(body)
	var s := RectangleShape2D.new(); s.size = Vector2(24, 600)
	var c := CollisionShape2D.new(); c.shape = s; c.position = Vector2(12, 300); body.add_child(c)   # wall: x 0..24
	var floor_body := StaticBody2D.new(); world.add_child(floor_body)
	var fs := RectangleShape2D.new(); fs.size = Vector2(600, 24)
	var fc := CollisionShape2D.new(); fc.shape = fs; fc.position = Vector2(300 + 24, 612); floor_body.add_child(fc)  # floor top y=600
	var cb := CharacterBody2D.new()
	var rs := RectangleShape2D.new(); rs.size = Vector2(10, 22)
	var cs := CollisionShape2D.new(); cs.shape = rs; cb.add_child(cs)
	cb.position = Vector2(29, 100); world.add_child(cb)
	await physics_frame
	for f in 20:
		cb.velocity = Vector2(-60, 60); cb.move_and_slide(); await physics_frame
	for i in cb.get_slide_collision_count():
		var k := cb.get_slide_collision(i)
		print("RESULT wall contact pos=", k.get_position(), " normal=", k.get_normal(), " collider_class=", k.get_collider().get_class())
	cb.position = Vector2(100, 560)
	for f in 30:
		cb.velocity = Vector2(0, 200); cb.move_and_slide(); await physics_frame
	for i in cb.get_slide_collision_count():
		var k := cb.get_slide_collision(i)
		print("RESULT floor contact pos=", k.get_position(), " normal=", k.get_normal(), " body_y=", cb.position.y)
	quit()
