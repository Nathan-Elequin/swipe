extends Control
## Dungeon trophy plaque. Skull on a wood heater-shield. Number only — no English.

var count: int = 0
var tex_skull: Texture2D
var _pop: Tween


func setup(skull: Texture2D) -> void:
	tex_skull = skull
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(92, 104)
	pivot_offset = Vector2(46, 52)


func set_count(n: int, loud: bool = false) -> void:
	count = n
	queue_redraw()
	if loud:
		punch()


func punch() -> void:
	pivot_offset = size * 0.5
	if _pop != null:
		_pop.kill()
	scale = Vector2.ONE
	rotation = 0.0
	_pop = create_tween()
	_pop.set_trans(Tween.TRANS_BACK)
	_pop.set_ease(Tween.EASE_OUT)
	_pop.tween_property(self, "scale", Vector2(1.55, 1.55), 0.12)
	_pop.parallel().tween_property(self, "rotation", 0.12, 0.08)
	_pop.tween_property(self, "rotation", -0.08, 0.08)
	_pop.tween_property(self, "scale", Vector2.ONE, 0.22)
	_pop.parallel().tween_property(self, "rotation", 0.0, 0.22)


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var wood := Color("3a2416")
	var wood_deep := Color("24150e")
	var gold := Color("c4a574")
	var gold_hot := Color("e8c36a")
	var plaque := PackedVector2Array([
		Vector2(w * 0.16, 6.0),
		Vector2(w * 0.84, 6.0),
		Vector2(w * 0.90, h * 0.42),
		Vector2(w * 0.50, h - 4.0),
		Vector2(w * 0.10, h * 0.42),
	])
	draw_colored_polygon(plaque, wood)
	var inner := PackedVector2Array([
		Vector2(w * 0.24, 16.0),
		Vector2(w * 0.76, 16.0),
		Vector2(w * 0.80, h * 0.42),
		Vector2(w * 0.50, h - 16.0),
		Vector2(w * 0.20, h * 0.42),
	])
	draw_colored_polygon(inner, wood_deep)
	plaque.append(plaque[0])
	draw_polyline(plaque, gold, 2.6, true)
	_draw_horn(Vector2(w * 0.34, 28.0), -1.0, gold_hot)
	_draw_horn(Vector2(w * 0.66, 28.0), 1.0, gold_hot)
	if tex_skull != null:
		var sz := Vector2(36, 36)
		draw_texture_rect(tex_skull, Rect2(Vector2(w * 0.5, 38.0) - sz * 0.5, sz), false, Color("f0e6d8"))
	draw_circle(Vector2(w * 0.22, 14.0), 3.2, gold_hot)
	draw_circle(Vector2(w * 0.78, 14.0), 3.2, gold_hot)
	draw_circle(Vector2(w * 0.50, h - 10.0), 2.6, gold)
	var font: Font = ThemeDB.fallback_font
	var txt: String = str(count)
	var fs: int = 26
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = Vector2((w - tsz.x) * 0.5, h * 0.68 + fs * 0.35)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("100e0c"))
	draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("f0e6d8"))
	var cap := "Slain"
	var cfs := 11
	var csz: Vector2 = font.get_string_size(cap, HORIZONTAL_ALIGNMENT_LEFT, -1, cfs)
	var cp := Vector2((w - csz.x) * 0.5, h - 6.0)
	draw_string(font, cp + Vector2(1, 1), cap, HORIZONTAL_ALIGNMENT_LEFT, -1, cfs, Color("100e0c"))
	draw_string(font, cp, cap, HORIZONTAL_ALIGNMENT_LEFT, -1, cfs, Color("c4a574"))


func _draw_horn(root: Vector2, side: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		var t: float = float(i) / 7.0
		var x: float = root.x + side * (6.0 + t * 18.0)
		var y: float = root.y - t * 22.0 + sin(t * PI) * 4.0
		pts.append(Vector2(x, y))
	draw_polyline(pts, col, 3.2, true)
	draw_polyline(pts, Color("f0e6d8a0"), 1.2, true)
