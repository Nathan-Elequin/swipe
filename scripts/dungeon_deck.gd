extends Control
## Face-down Challenge deck. Sits off the top-right of the wheel.

signal draw_finished
signal hovered
signal unhovered
signal edit_wanted

const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const BACK := Color("1a1410")
const RIM := Color("c4a574")
const GOLD := Color("e8c36a")
const INK := Color("f0e6d8")
const WARN := Color("e07040")
const EMPTY := Color("8b1e1e")

var count: int = 0
var art_tex: Texture2D
var peek_tex: Texture2D
var peek_name: String = ""
var _shake: float = 0.0
var _draw_t: float = 0.0
var _busy: bool = false
var _sack: Texture2D
var _card: Texture2D
var _warn_t: float = 0.0


func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(148, 168)
	z_index = 8
	mouse_entered.connect(_on_in)
	mouse_exited.connect(_on_out)
	gui_input.connect(_on_gui)
	if ResourceLoader.exists("res://assets/dungeon/home/loot_sack_dropped.png"):
		_sack = load("res://assets/dungeon/home/loot_sack_dropped.png")
	if ResourceLoader.exists("res://assets/ui/deck/playing_card.png"):
		_card = load("res://assets/ui/deck/playing_card.png")
	texture_filter = TEXTURE_FILTER_NEAREST


func set_count(n: int) -> void:
	count = maxi(0, n)
	_sync_mouse()
	set_process(true)
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
		if (OS.has_feature("editor") or PLAYTEST_FLAG.on()) and peek_name != "":
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
	var warn: bool = count <= 2
	if _shake > 0.02 or _draw_t > 0.0 or warn:
		queue_redraw()
	_shake = maxf(0.0, _shake - delta * 0.15)
	if warn:
		_warn_t += delta * 5.0
	else:
		_warn_t = 0.0
		if _shake <= 0.02 and _draw_t <= 0.0:
			set_process(false)


func _draw() -> void:
	var n: int = mini(count, 6)
	var card_w := 110.0
	var jitter: float = _shake * 4.0
	if n > 0 or _draw_t > 0.0:
		for i in n:
			var off := Vector2(float(i) * 2.2 + sin(_shake * 12.0 + float(i)) * jitter, -float(i) * 2.4)
			_draw_back(Rect2(Vector2(6, 18) + off, Vector2(card_w - 18, size.y - 36)), Color.WHITE, i == n - 1)
		if _draw_t > 0.0:
			var fly := Vector2(-40.0 * _draw_t, -80.0 * _draw_t)
			var a: float = 1.0 - _draw_t
			var col := Color(1, 1, 1, a)
			draw_set_transform(fly, -0.4 * _draw_t, Vector2.ONE)
			_draw_back(Rect2(Vector2(6, 18), Vector2(card_w - 18, size.y - 36)), col, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_loot_bags()
	var font: Font = ThemeDB.fallback_font
	if peek_name != "" and count > 0:
		var who: String = peek_name
		var cap_h := 24.0
		var cap := Rect2(6.0, size.y - cap_h - 4.0, card_w - 18.0, cap_h)
		draw_rect(cap, Color("1a1410"), true)
		draw_rect(cap, GOLD, false, 1.4)
		var wfs := 14
		var wsz: Vector2 = font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs)
		while wsz.x > cap.size.x - 8.0 and wfs > 10:
			wfs -= 1
			wsz = font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs)
		var wp := Vector2(cap.position.x + (cap.size.x - wsz.x) * 0.5, cap.position.y + cap.size.y - 6.0)
		draw_string(font, wp + Vector2(1, 1), who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, Color("100e0c"))
		draw_string(font, wp, who, HORIZONTAL_ALIGNMENT_LEFT, -1, wfs, INK)
	var lab := str(count)
	var fs := 22
	var tsz: Vector2 = font.get_string_size(lab, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	var ink: Color = GOLD
	if count <= 0:
		ink = EMPTY
	elif count <= 2:
		ink = WARN
	var p := Vector2((card_w - tsz.x) * 0.5, size.y - 2.0)
	draw_string(font, p + Vector2(1, 1), lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("100e0c"))
	draw_string(font, p, lab, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)


func _draw_loot_bags() -> void:
	var bags: int = mini(count, 12)
	if bags <= 0:
		return
	var pulse: float = 1.0
	var tint := Color.WHITE
	if count <= 2:
		tint = WARN if count > 0 else EMPTY
		pulse = 0.78 + 0.22 * (0.5 + 0.5 * sin(_warn_t))
	tint.a = pulse
	var x := 112.0
	var step := 22.0
	var top := 18.0
	for i in bags:
		var r := Rect2(x, top + float(i) * step, 32, 32)
		if _sack != null:
			draw_texture_rect(_sack, r, false, tint)
		else:
			draw_rect(r.grow(-4.0), tint, true)
			draw_rect(r.grow(-4.0), GOLD, false, 1.2)


func _draw_back(r: Rect2, tint: Color = Color.WHITE, face: bool = false) -> void:
	if _card != null:
		# Pixel's card back (32x44 native, shipped 4x). Drawn at 3x native so Nearest stays pixel-exact.
		var csz := Vector2(_card.get_width(), _card.get_height()) * 0.75
		var cr := Rect2(r.get_center() - csz * 0.5, csz)
		draw_texture_rect(_card, cr, false, tint)
		if face and peek_tex != null:
			var pad := 12.0
			var box := Rect2(cr.position + Vector2(pad, pad), Vector2(cr.size.x - pad * 2.0, cr.size.y * 0.62 - pad))
			draw_texture_rect(peek_tex, box, false, tint)
		return
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
