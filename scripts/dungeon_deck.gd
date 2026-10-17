extends Control
## Face-down Challenge deck. Sits off the top-right of the wheel.

signal draw_finished
signal hovered
signal unhovered
signal edit_wanted

const BACK := Color("1a1410")
const RIM := Color("c4a574")
const GOLD := Color("e8c36a")
const INK := Color("f0e6d8")

var count: int = 0
var art_tex: Texture2D
var peek_tex: Texture2D
var peek_name: String = ""
var _shake: float = 0.0
var _draw_t: float = 0.0
var _busy: bool = false


func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(110, 156)
	z_index = 8
	mouse_entered.connect(_on_in)
	mouse_exited.connect(_on_out)
	gui_input.connect(_on_gui)


func set_count(n: int) -> void:
	count = maxi(0, n)
	_sync_mouse()
	queue_redraw()


func set_peek(tex: Texture2D, who: String) -> void:
	peek_tex = tex
	peek_name = who.strip_edges()
	_sync_mouse()
	queue_redraw()


func _sync_mouse() -> void:
	var on: bool = count > 0 and peek_name != ""
	mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if on else Control.CURSOR_ARROW


func _on_in() -> void:
	if count <= 0 or peek_name == "":
		return
	hovered.emit()


func _on_out() -> void:
	unhovered.emit()


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if OS.has_feature("editor") and peek_name != "":
			edit_wanted.emit()
		accept_event()


func is_busy() -> bool:
	return _busy


func play_shuffle() -> void:
	_busy = true
	_shake = 1.0
	var tw := create_tween()
	tw.tween_property(self, "_shake", 0.0, 0.55).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await tw.finished
	_busy = false
	queue_redraw()


func play_draw() -> void:
	if count <= 0:
		return
	_busy = true
	_draw_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_draw_t", 1.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tw.finished
	count = maxi(0, count - 1)
	_draw_t = 0.0
	_busy = false
	queue_redraw()
	draw_finished.emit()


func _process(delta: float) -> void:
	if _shake > 0.02 or _draw_t > 0.0:
		queue_redraw()
	_shake = maxf(0.0, _shake - delta * 0.15)


func _draw() -> void:
	var n: int = mini(count, 6)
	if n <= 0 and _draw_t <= 0.0:
		return
	var w: float = size.x
	var h: float = size.y
	var jitter: float = _shake * 4.0
	for i in n:
		var off := Vector2(float(i) * 2.2 + sin(_shake * 12.0 + float(i)) * jitter, -float(i) * 2.4)
		_draw_back(Rect2(Vector2(6, 18) + off, Vector2(w - 18, h - 36)), Color.WHITE, i == n - 1)
	if _draw_t > 0.0:
		var fly := Vector2(-40.0 * _draw_t, -80.0 * _draw_t)
		var a: float = 1.0 - _draw_t
		var col := Color(1, 1, 1, a)
		draw_set_transform(fly, -0.4 * _draw_t, Vector2.ONE)
		_draw_back(Rect2(Vector2(6, 18), Vector2(w - 18, h - 36)), col, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var font: Font = ThemeDB.fallback_font
	if peek_name != "" and count > 0:
		var who: String = peek_name
		var wfs := 12
		var wsz: Vector2 = font.get_string_size(who, HORIZONTAL_ALIGNMENT_CENTER, -1, wfs)
		var wp := Vector2((size.x - wsz.x) * 0.5, 16.0)
		draw_string(font, wp + Vector2(1, 1), who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, Color("100e0c"))
		draw_string(font, wp, who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, INK)
	var lab := str(count)
	var fs := 22
	var tsz: Vector2 = font.get_string_size(lab, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	var p := Vector2((size.x - tsz.x) * 0.5, size.y - 2.0)
	draw_string(font, p + Vector2(1, 1), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("100e0c"))
	draw_string(font, p, lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, GOLD)


func _draw_back(r: Rect2, tint: Color = Color.WHITE, face: bool = false) -> void:
	var fill: Color = BACK * tint
	var edge: Color = RIM * tint
	draw_rect(r, fill, true)
	draw_rect(r, edge, false, 2.0)
	var inner := r.grow(-8.0)
	draw_rect(inner, Color("2a2218") * tint, false, 1.2)
	if face and peek_tex != null:
		var pad := 10.0
		var ts: Vector2 = Vector2(r.size.x - pad * 2.0, r.size.y - pad * 2.0)
		draw_texture_rect(peek_tex, Rect2(r.position + Vector2(pad, pad), ts), false, tint)
	elif art_tex != null:
		var ts: Vector2 = Vector2(32, 32)
		draw_texture_rect(art_tex, Rect2(r.position + (r.size - ts) * 0.5, ts), false, tint)
	else:
		draw_arc(r.get_center(), 10.0, 0.0, TAU, 16, GOLD * tint, 1.6, true)
