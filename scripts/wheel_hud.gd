extends Control
## Direction A in-run chrome: hearts, pointer, Spin, hand, column.

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")

const GOLD := Color("FFD84A")
const SOOT := Color("1A120E")
const DIM := Color("A88C66")
const PARCHMENT := Color("E9D3A1")
const EDGE := Color("7A4E2B")

var hearts_box: HBoxContainer
var btn_spin: Button
var btn_done: Button
var btn_start: Button
var btn_place: Button
var btn_bribe: Button
var hotbar_box: Container
var choice_box: HBoxContainer
var cue_label: Label
var column: Control
var idle_box: Control
var idle_title: Label
var idle_body: Label
var plate_slot: VBoxContainer
var tools_slot: VBoxContainer
var pointer: Control
var torch_line: Control
var column_panel: Panel
var loot_layer: Control
var ghost_hand: Control
var _loot_glow: TextureRect
var _spin_ring: ColorRect
var _torch_from: Vector2 = Vector2.ZERO
var _torch_to: Vector2 = Vector2.ZERO
var _torch_on: bool = false
var _torch_t: float = 0.0
var _spin_live: bool = false
var _cue_dim: bool = false
var _font_px: Font
var _font_sk: Font
var _font_vt: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if theme == null:
		theme = load("res://themes/swipe_theme.tres")
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_sk = load("res://assets/ui/fonts/Silkscreen-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	_build()
	set_process(true)
	resized.connect(_layout)


func _build() -> void:
	hearts_box = HBoxContainer.new()
	hearts_box.position = Vector2(32, 28)
	hearts_box.add_theme_constant_override("separation", 6)
	hearts_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hearts_box.z_index = 6
	add_child(hearts_box)
	for _i in 6:
		var h := TextureRect.new()
		h.custom_minimum_size = Vector2(35, 30)
		h.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		h.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.pivot_offset = Vector2(17, 15)
		hearts_box.add_child(h)

	pointer = Control.new()
	pointer.position = Vector2(530, 664)
	pointer.size = Vector2(36, 26)
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointer.z_index = 4
	pointer.draw.connect(_draw_pointer)
	add_child(pointer)

	_spin_ring = ColorRect.new()
	_spin_ring.color = GOLD
	_spin_ring.position = Vector2(414, 696)
	_spin_ring.size = Vector2(268, 76)
	_spin_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spin_ring.z_index = 6
	add_child(_spin_ring)

	btn_spin = Button.new()
	btn_spin.theme_type_variation = "ButtonGold"
	btn_spin.text = COPY.need("combat.spin")
	btn_spin.position = Vector2(418, 700)
	btn_spin.custom_minimum_size = Vector2(260, 68)
	btn_spin.size = Vector2(260, 68)
	btn_spin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_spin.z_index = 7
	if _font_px != null:
		btn_spin.add_theme_font_override("font", _font_px)
	btn_spin.add_theme_font_size_override("font_size", 40)
	add_child(btn_spin)

	btn_done = Button.new()
	btn_done.theme_type_variation = "ButtonGold"
	btn_done.position = Vector2(418, 700)
	btn_done.custom_minimum_size = Vector2(260, 68)
	btn_done.size = Vector2(260, 68)
	btn_done.visible = false
	btn_done.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_done.z_index = 7
	add_child(btn_done)

	btn_start = Button.new()
	btn_start.visible = false
	add_child(btn_start)
	btn_place = Button.new()
	btn_place.visible = false
	add_child(btn_place)
	btn_bribe = Button.new()
	btn_bribe.visible = false
	add_child(btn_bribe)

	choice_box = HBoxContainer.new()
	choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_box.add_theme_constant_override("separation", 10)
	choice_box.position = Vector2(32, 748)
	choice_box.size = Vector2(1030, 40)
	choice_box.z_index = 8
	add_child(choice_box)

	hotbar_box = HFlowContainer.new()
	hotbar_box.alignment = FlowContainer.ALIGNMENT_CENTER
	hotbar_box.add_theme_constant_override("h_separation", 14)
	hotbar_box.add_theme_constant_override("v_separation", 10)
	hotbar_box.position = Vector2(32, 790)
	hotbar_box.size = Vector2(1600, 210)
	hotbar_box.z_index = 8
	hotbar_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hotbar_box)

	column = Control.new()
	column.position = Vector2(1086, 28)
	column.size = Vector2(560, 952)
	column.clip_contents = true
	column.z_index = 5
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(column)
	column_panel = Panel.new()
	column_panel.set_anchors_preset(PRESET_FULL_RECT)
	column_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column_panel.add_theme_stylebox_override("panel", UX.oak_panel())
	column.add_child(column_panel)
	var col := VBoxContainer.new()
	col.set_anchors_preset(PRESET_FULL_RECT)
	col.offset_left = 26
	col.offset_top = 26
	col.offset_right = -26
	col.offset_bottom = -26
	col.add_theme_constant_override("separation", 18)
	column.add_child(col)

	cue_label = Label.new()
	cue_label.theme_type_variation = "CueLabel"
	cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _font_px != null:
		cue_label.add_theme_font_override("font", _font_px)
	cue_label.add_theme_font_size_override("font_size", 40)
	cue_label.add_theme_color_override("font_color", PARCHMENT)
	col.add_child(cue_label)

	idle_box = Control.new()
	idle_box.custom_minimum_size = Vector2(0, 220)
	idle_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idle_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	idle_box.draw.connect(_draw_idle)
	col.add_child(idle_box)
	var idle_v := VBoxContainer.new()
	idle_v.set_anchors_preset(PRESET_FULL_RECT)
	idle_v.offset_left = 26
	idle_v.offset_top = 26
	idle_v.offset_right = -26
	idle_v.offset_bottom = -26
	idle_v.add_theme_constant_override("separation", 12)
	idle_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	idle_box.add_child(idle_v)
	idle_title = Label.new()
	idle_title.text = COPY.need("inspect.title")
	idle_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	idle_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_px != null:
		idle_title.add_theme_font_override("font", _font_px)
	idle_title.add_theme_font_size_override("font_size", 34)
	idle_title.add_theme_color_override("font_color", PARCHMENT)
	idle_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	idle_v.add_child(idle_title)
	idle_body = Label.new()
	idle_body.text = COPY.need("inspect.idle")
	idle_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	idle_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.apply_body(idle_body, UI.DIM, UI.SIZE_BODY)
	idle_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	idle_v.add_child(idle_body)

	plate_slot = VBoxContainer.new()
	plate_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plate_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plate_slot.custom_minimum_size = Vector2(0, 420)
	plate_slot.add_theme_constant_override("separation", 8)
	col.add_child(plate_slot)

	tools_slot = VBoxContainer.new()
	tools_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools_slot.size_flags_vertical = Control.SIZE_SHRINK_END
	tools_slot.add_theme_constant_override("separation", 8)
	col.add_child(tools_slot)

	torch_line = Control.new()
	torch_line.set_anchors_preset(PRESET_FULL_RECT)
	torch_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	torch_line.z_index = 3
	torch_line.draw.connect(_draw_torch)
	add_child(torch_line)

	loot_layer = Control.new()
	loot_layer.position = Vector2(128, 90)
	loot_layer.size = Vector2(840, 600)
	loot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot_layer.z_index = 4
	loot_layer.visible = false
	add_child(loot_layer)
	_loot_glow = TextureRect.new()
	_loot_glow.texture = load("res://assets/vfx/vfx_glow_gold.png")
	_loot_glow.position = Vector2.ZERO
	_loot_glow.size = Vector2(840, 600)
	_loot_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_loot_glow.stretch_mode = TextureRect.STRETCH_KEEP
	_loot_glow.texture_filter = TEXTURE_FILTER_NEAREST
	_loot_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot_layer.add_child(_loot_glow)

	ghost_hand = Control.new()
	ghost_hand.position = Vector2(32, 790)
	ghost_hand.size = Vector2(1030, 210)
	ghost_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_hand.z_index = 8
	ghost_hand.visible = false
	ghost_hand.modulate = Color(1, 1, 1, 0.5)
	ghost_hand.draw.connect(_draw_ghost_hand)
	add_child(ghost_hand)

	_layout()


func setup_hearts(full: Texture2D) -> void:
	if hearts_box == null:
		return
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr != null:
			tr.texture = full


func set_cue(text: String) -> void:
	if cue_label == null:
		return
	cue_label.text = text
	cue_label.visible = text != ""


func set_cue_dim(on: bool) -> void:
	_cue_dim = on
	if cue_label != null:
		cue_label.modulate = Color(1, 1, 1, 0.42) if on else Color.WHITE


func set_idle_visible(on: bool) -> void:
	if idle_box != null:
		idle_box.visible = on


func set_spin_live(on: bool) -> void:
	_spin_live = on
	if not on and _spin_ring != null:
		_spin_ring.modulate.a = 0.0


func set_chrome_visible(on: bool) -> void:
	visible = on


func set_column_kind(kind: String) -> void:
	if column_panel == null:
		return
	column_panel.add_theme_stylebox_override("panel", UX.oak_panel(kind == "victory"))


func set_pointer_dim(kind: String) -> void:
	if pointer == null:
		return
	if kind == "defeat":
		pointer.modulate = Color(Color("5A5048"), 0.22)
	else:
		pointer.modulate = Color.WHITE
	pointer.queue_redraw()


func set_ghost_hand(on: bool) -> void:
	if ghost_hand != null:
		ghost_hand.visible = on
		if on:
			ghost_hand.queue_redraw()
	if hotbar_box != null and on:
		hotbar_box.visible = false


func show_loot(texs: Array) -> void:
	if loot_layer == null:
		return
	var has_items := false
	for c in loot_layer.get_children():
		if c != _loot_glow:
			has_items = true
			break
	if loot_layer.visible and has_items:
		return
	for c2 in loot_layer.get_children():
		if c2 == _loot_glow:
			continue
		loot_layer.remove_child(c2)
		c2.queue_free()
	loot_layer.visible = true
	if texs.is_empty():
		return
	var n: int = texs.size()
	for i in n:
		var tex: Texture2D = texs[i]
		if tex == null:
			continue
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.texture_filter = TEXTURE_FILTER_NEAREST
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.size = Vector2(96, 96)
		var ang: float = -0.4 + float(i) * (TAU / maxf(float(n), 1.0))
		var rad: float = 70.0 + float(i % 3) * 18.0
		var dest := Vector2(420, 260) + Vector2.from_angle(ang) * rad - Vector2(48, 48)
		tr.position = dest + Vector2(0, -60)
		tr.modulate.a = 0.0
		loot_layer.add_child(tr)
		var tw := create_tween()
		tw.tween_interval(0.08 * float(i))
		tw.tween_property(tr, "modulate:a", 1.0, 0.12)
		tw.parallel().tween_property(tr, "position", dest, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(tr, "position:y", dest.y - 4.0, 0.06)
		tw.tween_property(tr, "position:y", dest.y, 0.06)


func hide_loot() -> void:
	if loot_layer == null:
		return
	loot_layer.visible = false
	for c in loot_layer.get_children():
		if c == _loot_glow:
			continue
		loot_layer.remove_child(c)
		c.queue_free()


func set_torch(from_g: Vector2, to_g: Vector2, on: bool) -> void:
	_torch_on = on
	if on:
		_torch_from = from_g - global_position
		_torch_to = to_g - global_position
	if torch_line != null:
		torch_line.queue_redraw()


func set_side_column(on: bool) -> void:
	if column_panel != null:
		column_panel.visible = on
	if idle_box != null and not on:
		idle_box.visible = false
	if column != null:
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.visible = on


func layout_hand() -> void:
	if hotbar_box == null:
		return
	var n: int = hotbar_box.get_child_count()
	var vp_w: float = size.x if size.x > 8.0 else 1680.0
	var avail: float = minf(1600.0, vp_w - 64.0)
	var full_w := 140.0
	var compact_w := 124.0
	var gap1 := 14.0
	var gap2 := 10.0
	var need_full: float = float(n) * full_w + float(maxi(n - 1, 0)) * gap1
	var need_compact: float = float(n) * compact_w + float(maxi(n - 1, 0)) * gap2
	var compact: bool = n > 0 and need_full > avail
	var wrap: bool = n > 0 and need_compact > avail
	hotbar_box.add_theme_constant_override("h_separation", gap2 if compact else gap1)
	hotbar_box.add_theme_constant_override("v_separation", 10)
	for c in hotbar_box.get_children():
		if c.has_method("set_compact"):
			c.set_compact(compact)
	var row_h := 210.0
	var box_w: float = avail if wrap else minf(need_full if not compact else need_compact, avail)
	if box_w < 8.0:
		box_w = avail
	var rows: int = 2 if wrap else 1
	var box_h: float = row_h * float(rows) + (10.0 if wrap else 0.0)
	var x: float = floor((vp_w - box_w) * 0.5)
	x = clampf(x, 32.0, 1062.0 - box_w)
	var y := 790.0
	if wrap:
		y = 1040.0 - box_h - 12.0
		if y < 772.0:
			y = 772.0
	hotbar_box.position = Vector2(x, y)
	hotbar_box.size = Vector2(maxf(box_w, 8.0), box_h)
	if ghost_hand != null:
		ghost_hand.position = Vector2(32, y)
		ghost_hand.size = Vector2(1030, box_h)
	_fit_column_above_hand()


func _layout() -> void:
	if pointer != null:
		pointer.position = Vector2(530, 664)
		pointer.size = Vector2(36, 26)
		pointer.queue_redraw()
	layout_hand()
	_fit_column_above_hand()
	if btn_spin != null:
		btn_spin.position = Vector2(418, 700)
		btn_spin.size = Vector2(260, 68)
	if btn_done != null:
		btn_done.position = Vector2(418, 700)
		btn_done.size = Vector2(maxf(btn_done.custom_minimum_size.x, 260), 68)
	if _spin_ring != null:
		_spin_ring.position = Vector2(414, 696)
		_spin_ring.size = Vector2(268, 76)
	if hearts_box != null:
		hearts_box.position = Vector2(32, 28)
	if idle_box != null:
		idle_box.queue_redraw()


func _fit_column_above_hand() -> void:
	if column == null:
		return
	var bottom: float = 980.0
	var max_h: float = 952.0
	if hotbar_box != null and hotbar_box.visible:
		bottom = minf(bottom, hotbar_box.position.y - 12.0)
		# Two-row hand (210 + 14 + 210) floors at y 566. Never sit on it.
		var two_row_top: float = 1000.0 - 210.0 * 2.0 - 14.0
		bottom = minf(bottom, two_row_top - 12.0)
		max_h = 572.0
	if ghost_hand != null and ghost_hand.visible:
		bottom = minf(bottom, ghost_hand.position.y - 12.0)
	var h: float = clampf(bottom - 28.0, 280.0, max_h)
	column.position = Vector2(1086, 28)
	column.custom_minimum_size = Vector2(560, h)
	column.size = Vector2(560, h)
	var inner: float = maxf(180.0, h - 52.0)
	if plate_slot != null:
		plate_slot.custom_minimum_size = Vector2(0, maxf(160.0, inner - 40.0))


func qa_layout() -> Dictionary:
	var col: Rect2 = column.get_global_rect() if column else Rect2()
	var hand: Rect2 = hotbar_box.get_global_rect() if hotbar_box else Rect2()
	return {
		"column": [col.position.x, col.position.y, col.size.x, col.size.y],
		"hand": [hand.position.x, hand.position.y, hand.size.x, hand.size.y],
		"overlap": col.intersects(hand),
		"hand_children": hotbar_box.get_child_count() if hotbar_box else 0,
	}


func _draw_torch() -> void:
	if torch_line == null or not _torch_on:
		return
	var a: Vector2 = _torch_from
	var b: Vector2 = _torch_to
	var mid: Vector2 = (a + b) * 0.5 + Vector2(0, -40)
	var col := Color("F09A34")
	var dash := 12.0
	var gap := 8.0
	var scroll: float = fmod(_torch_t * 40.0, dash + gap)
	var pts: PackedVector2Array = _quad_pts(a, mid, b, 24)
	var acc := 0.0
	for i in range(pts.size() - 1):
		var p0: Vector2 = pts[i]
		var p1: Vector2 = pts[i + 1]
		var seg: float = p0.distance_to(p1)
		var dir: Vector2 = (p1 - p0) / maxf(seg, 0.001)
		var t := 0.0
		while t < seg:
			var on: bool = fmod(t + scroll, dash + gap) < dash
			var t2: float = minf(t + 4.0, seg)
			if on:
				torch_line.draw_line(p0 + dir * t, p0 + dir * t2, col, 5.0, false)
			t += 4.0
		acc += seg


func _quad_pts(a: Vector2, c: Vector2, b: Vector2, n: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in range(n + 1):
		var t: float = float(k) / float(n)
		var u: float = 1.0 - t
		out.append(u * u * a + 2.0 * u * t * c + t * t * b)
	return out


func _process(_delta: float) -> void:
	_torch_t += _delta
	if _torch_on and torch_line != null:
		torch_line.queue_redraw()
	if _spin_ring == null:
		return
	if _spin_live:
		var a: float = 0.4 + 0.6 * absf(sin(float(Time.get_ticks_msec()) * 0.0035))
		_spin_ring.modulate = Color(GOLD.r, GOLD.g, GOLD.b, a)
	else:
		_spin_ring.modulate.a = 0.0


func _draw_pointer() -> void:
	if pointer == null:
		return
	var tip := Vector2(18, 0)
	var left := Vector2(0, 26)
	var right := Vector2(36, 26)
	pointer.draw_colored_polygon(PackedVector2Array([tip, left, right]), GOLD)
	pointer.draw_colored_polygon(PackedVector2Array([
		tip + Vector2(0, 4),
		left + Vector2(4, -2),
		right + Vector2(-4, -2),
	]), Color("FFE47A"))


func _draw_ghost_hand() -> void:
	if ghost_hand == null or not ghost_hand.visible:
		return
	var n := 6
	var cw := 140.0
	var ch := 210.0
	var gap := 14.0
	var total: float = float(n) * cw + float(n - 1) * gap
	var x0: float = (ghost_hand.size.x - total) * 0.5
	for i in n:
		var r := Rect2(Vector2(x0 + float(i) * (cw + gap), 0), Vector2(cw, ch))
		_dash_rect(ghost_hand, r, EDGE, 4.0, 10.0, 6.0)


func _draw_idle() -> void:
	if idle_box == null or not idle_box.visible:
		return
	var r := Rect2(Vector2.ZERO, idle_box.size)
	_dash_rect(idle_box, r, EDGE, 4.0, 10.0, 6.0)


func _dash_rect(node: Control, r: Rect2, col: Color, width: float, dash: float, gap: float) -> void:
	var pts: Array[Vector2] = [
		r.position,
		Vector2(r.end.x, r.position.y),
		r.end,
		Vector2(r.position.x, r.end.y),
		r.position,
	]
	for i in 4:
		_dash_line(node, pts[i], pts[i + 1], col, width, dash, gap)


func _dash_line(node: Control, a: Vector2, b: Vector2, col: Color, width: float, dash: float, gap: float) -> void:
	var d: Vector2 = b - a
	var len: float = d.length()
	if len < 1.0:
		return
	var dir: Vector2 = d / len
	var t := 0.0
	while t < len:
		var t2: float = minf(t + dash, len)
		node.draw_line(a + dir * t, a + dir * t2, col, width, false)
		t += dash + gap
