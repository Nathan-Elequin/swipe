extends Node2D
## One-shot adjacency beam. Same paint as Straight Shot: wide halo, colored
## body, light core, a bright head, and rings at both ends. The body color is
## the ability's call-name color.


func play(from: Vector2, to: Vector2, col: Color, travel_s: float = 0.227) -> void:
	top_level = true
	z_as_relative = false
	z_index = 30
	set_meta("from", from)
	set_meta("to", to)
	var body := Color(col.r, col.g, col.b, 0.95)
	var core := col.lerp(Color("fff8e8"), 0.75)
	core.a = 1.0
	var glow := col.darkened(0.28)
	glow.a = 0.9
	set_meta("body", body)
	set_meta("core", core)
	set_meta("glow", glow)
	set_meta("u", 0.0)
	visible = true
	var travel: float = maxf(travel_s, 0.05)
	var tw := create_tween()
	tw.tween_method(func(u: float) -> void:
		set_meta("u", u)
		queue_redraw()
	, 0.0, 1.0, travel)
	await tw.finished
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, maxf(travel * 0.4, 0.04))
	await fade.finished


func _draw() -> void:
	var u: float = float(get_meta("u", 0.0))
	var from: Vector2 = get_meta("from", Vector2.ZERO)
	var to: Vector2 = get_meta("to", Vector2.ZERO)
	var body: Color = get_meta("body", Color.WHITE)
	var core: Color = get_meta("core", Color.WHITE)
	var glow: Color = get_meta("glow", Color.WHITE)
	var tip: Vector2 = from.lerp(to, u)
	var glow_a: float = 0.5 + 0.22 * sin(u * TAU)
	draw_line(from, tip, Color(glow.r, glow.g, glow.b, glow_a), 22.0, false)
	draw_line(from, tip, body, 8.0, false)
	draw_line(from, tip, core, 2.5, false)
	var head_from: Vector2 = from.lerp(to, maxf(u - 0.18, 0.0))
	draw_line(head_from, tip, core, 11.0, false)
	draw_line(head_from, tip, body, 5.0, false)
	var dir: Vector2 = tip - head_from
	if dir.length() > 0.5:
		var tan: Vector2 = Vector2(-dir.y, dir.x).normalized()
		draw_line(tip - tan * 16.0, tip + tan * 16.0, Color(core.r, core.g, core.b, 0.9), 2.5, false)
	draw_arc(from, 12.0 + 16.0 * u, 0.0, TAU, 18, Color(body.r, body.g, body.b, 0.62), 3.0, false)
	draw_arc(from, 6.0 + 8.0 * u, 0.0, TAU, 14, Color(core.r, core.g, core.b, 0.45), 2.0, false)
	if u > 0.62:
		var k: float = (u - 0.62) / 0.38
		draw_arc(tip, 8.0 + 22.0 * k, 0.0, TAU, 20, Color(body.r, body.g, body.b, 0.75 * (1.0 - 0.25 * k)), 3.2, false)
		draw_arc(tip, 4.0 + 12.0 * k, 0.0, TAU, 16, Color(core.r, core.g, core.b, 0.55), 2.0, false)
