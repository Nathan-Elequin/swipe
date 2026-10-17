extends Control
## Own screen after a dungeon ends, before the next one is seated.
## The wheel, hand, and inspect panel stay hidden while this is up.

signal finished

var sfx = null
var _go: bool = false
var _playing: bool = false
var _t: float = 0.0
var _title: Label
var _sub: Label
var _loot_head: Label
var _foe_head: Label
var _loot_row: HBoxContainer
var _foe_row: HBoxContainer
var _kind: Label
var _dname: Label
var _stats: Label
var _body: Label
var _next: Button


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 200
	top_level = true
	visible = false
	set_process(false)
	_build()


func _process(delta: float) -> void:
	_t += delta
	var vp: Vector2 = get_viewport_rect().size
	if global_position != Vector2.ZERO or size != vp:
		global_position = Vector2.ZERO
		size = vp
	queue_redraw()


func _draw() -> void:
	var s: Vector2 = size
	if s.x < 2.0 or s.y < 2.0:
		return
	draw_rect(Rect2(Vector2.ZERO, s), Color("07060b"), true)
	var c: Vector2 = s * 0.5
	var pulse: float = 0.5 + 0.5 * sin(_t * 1.3)
	var reach: float = minf(s.x, s.y)
	draw_circle(c + Vector2(0, -40), reach * 0.55, Color(0.16, 0.10, 0.05, 0.22 + 0.06 * pulse))
	draw_arc(c + Vector2(0, -20), reach * 0.46, 0, TAU, 128, Color(0.91, 0.72, 0.32, 0.16 + 0.1 * pulse), 3.0, true)
	draw_arc(c + Vector2(0, -20), reach * 0.34, 0, TAU, 96, Color(0.91, 0.76, 0.4, 0.07), 1.5, true)
	var shaft := Color(0.95, 0.82, 0.45, 0.035 + 0.02 * pulse)
	draw_rect(Rect2(s.x * 0.5 - 90.0, 0, 180, s.y * 0.42), shaft, true)
	for i in range(18):
		var p: float = fmod(_t * 0.08 + float(i) * 0.137, 1.0)
		var x: float = fmod(float(i) * 97.0 + _t * 18.0, s.x)
		var y: float = s.y * (1.0 - p)
		var a: float = sin(p * PI) * 0.45
		draw_circle(Vector2(x, y), 1.6, Color(0.95, 0.84, 0.5, a))


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	margin.add_child(col)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 40)
	_title.add_theme_color_override("font_color", Color("f0d78a"))
	col.add_child(_title)

	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_font_size_override("font_size", 20)
	_sub.add_theme_color_override("font_color", Color("e6d7c4"))
	col.add_child(_sub)

	_loot_head = _section("Loot")
	col.add_child(_loot_head)
	_loot_row = _row()
	col.add_child(_center(_loot_row))
	_foe_head = _section("Foes")
	col.add_child(_foe_head)
	_foe_row = _row()
	col.add_child(_center(_foe_row))

	var plate := PanelContainer.new()
	plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plate.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plate.custom_minimum_size = Vector2(0, 168)
	var psb := StyleBoxFlat.new()
	psb.bg_color = Color(0.08, 0.06, 0.05, 0.92)
	psb.border_color = Color("c4a574")
	psb.set_border_width_all(2)
	psb.set_corner_radius_all(12)
	psb.content_margin_left = 28
	psb.content_margin_right = 28
	psb.content_margin_top = 18
	psb.content_margin_bottom = 18
	plate.add_theme_stylebox_override("panel", psb)
	col.add_child(plate)
	var pcol := VBoxContainer.new()
	pcol.add_theme_constant_override("separation", 6)
	plate.add_child(pcol)
	_kind = Label.new()
	_kind.add_theme_font_size_override("font_size", 16)
	_kind.add_theme_color_override("font_color", Color("e8c36a"))
	pcol.add_child(_kind)
	_dname = Label.new()
	_dname.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dname.add_theme_font_size_override("font_size", 32)
	_dname.add_theme_color_override("font_color", Color("f4ede3"))
	pcol.add_child(_dname)
	_stats = Label.new()
	_stats.add_theme_font_size_override("font_size", 20)
	_stats.add_theme_color_override("font_color", Color("e7b1a8"))
	pcol.add_child(_stats)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("font_size", 22)
	_body.add_theme_color_override("font_color", Color("f0e6d8"))
	pcol.add_child(_body)

	var bar := CenterContainer.new()
	col.add_child(bar)
	_next = Button.new()
	_next.text = "Onward"
	_next.custom_minimum_size = Vector2(240, 64)
	_next.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_next.add_theme_font_size_override("font_size", 26)
	_next.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_paint_button(_next)
	_next.pressed.connect(_on_next)
	bar.add_child(_next)


func _section(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color("c4a574"))
	return l


func _row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 22)
	return row


func _center(row: HBoxContainer) -> CenterContainer:
	var c := CenterContainer.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.add_child(row)
	return c


func _paint_button(b: Button) -> void:
	var normal := _btn_box(Color("241c14"), Color("e8c36a"))
	var hover := _btn_box(Color("3a2e1c"), Color("f0d78a"))
	var pressed := _btn_box(Color("1a140e"), Color("c4a574"))
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("disabled", _btn_box(Color("16130f"), Color("5c5144")))
	b.add_theme_color_override("font_color", Color("f4ede3"))
	b.add_theme_color_override("font_hover_color", Color("fff6e4"))
	b.add_theme_color_override("font_disabled_color", Color("8a7d6c"))


func _btn_box(bg: Color, edge: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = edge
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb


func play(bucket_n: int, entries: Array) -> void:
	if _playing:
		return
	_playing = true
	_go = false
	_fit()
	set_process(true)
	visible = true
	_title.text = "As you venture deeper, new Loot and Foes reveal themselves."
	_sub.text = "Hover a shadow to see what it is. From now on, these can show up in every dungeon."
	_title.modulate.a = 0.0
	_sub.modulate.a = 0.0
	_clear_detail()
	_next.disabled = true
	_next.modulate.a = 0.0
	_clear_row(_loot_row)
	_clear_row(_foe_row)
	var loot: Array = []
	var foes: Array = []
	for entry in entries:
		if str(entry.get("kind", "")) == "Foe":
			foes.append(entry)
		else:
			loot.append(entry)
	_loot_head.visible = not loot.is_empty()
	_foe_head.visible = not foes.is_empty()
	var cards: Array = []
	for entry2 in loot:
		cards.append(_make_card(_loot_row, entry2, bucket_n))
	for entry3 in foes:
		cards.append(_make_card(_foe_row, entry3, bucket_n))
	if sfx != null and sfx.has_method("play"):
		sfx.play("bong", -6.0, 0.72)
		sfx.play("whoosh", -8.0, 0.85)
		if sfx.has_method("play_event"):
			sfx.play_event(&"bucket.open")
			sfx.play_event(&"sting.bucket")
	var tin := create_tween()
	tin.tween_property(_title, "modulate:a", 1.0, 0.45)
	tin.parallel().tween_property(_sub, "modulate:a", 1.0, 0.55)
	await get_tree().create_timer(0.35).timeout
	for card in cards:
		if not visible:
			break
		var slot: Control = card["slot"]
		var tex_rect: TextureRect = card["tex"]
		slot.modulate.a = 0.0
		slot.scale = Vector2(0.82, 0.82)
		slot.pivot_offset = slot.custom_minimum_size * 0.5
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(slot, "modulate:a", 1.0, 0.18)
		tw.tween_property(slot, "scale", Vector2(1.06, 1.06), 0.14)
		tw.chain().tween_property(slot, "scale", Vector2.ONE, 0.1)
		tex_rect.modulate = Color(0.04, 0.03, 0.025, 1)
		if sfx != null and sfx.has_method("play_event"):
			sfx.play_event(&"bucket.card_pop")
		await get_tree().create_timer(0.11).timeout
	if sfx != null and sfx.has_method("play"):
		sfx.play("confirm_big", -8.0, 1.0)
	var bout := create_tween()
	bout.tween_property(_next, "modulate:a", 1.0, 0.25)
	_next.disabled = false
	while not _go:
		await get_tree().process_frame
	if sfx != null and sfx.has_method("play"):
		sfx.play("confirm", -8.0, 1.0)
	_playing = false
	set_process(false)
	visible = false
	finished.emit()


func _fit() -> void:
	var vp: Vector2 = get_viewport_rect().size
	global_position = Vector2.ZERO
	size = vp


func _clear_row(row: HBoxContainer) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.free()


func _make_card(row: HBoxContainer, entry: Dictionary, bucket_n: int) -> Dictionary:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(168, 196)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("100c0a")
	sb.border_color = BucketRules.color_of(bucket_n).darkened(0.35)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	slot.add_theme_stylebox_override("panel", sb)
	slot.set_meta("edge", sb)
	slot.set_meta("open", false)
	var tex_rect := TextureRect.new()
	tex_rect.texture = entry.get("tex", null)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex_rect.custom_minimum_size = Vector2(144, 144)
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_rect.modulate = Color(0, 0, 0, 1)
	slot.add_child(tex_rect)
	var name := Label.new()
	name.text = str(entry.get("name", ""))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.custom_minimum_size = Vector2(144, 36)
	name.add_theme_font_size_override("font_size", 15)
	name.add_theme_color_override("font_color", Color("f4ede3"))
	name.modulate.a = 0.0
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Name sits under the art by wrapping the panel in a column.
	var wrap := VBoxContainer.new()
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.add_theme_constant_override("separation", 6)
	wrap.add_child(slot)
	wrap.add_child(name)
	row.add_child(wrap)
	slot.mouse_entered.connect(_on_card_enter.bind(slot, tex_rect, name, entry))
	slot.mouse_exited.connect(_on_card_exit.bind(slot, bucket_n))
	return {"slot": wrap, "tex": tex_rect, "name": name}


func _on_card_enter(slot: PanelContainer, tex_rect: TextureRect, name: Label, entry: Dictionary) -> void:
	var first: bool = not bool(slot.get_meta("open", false))
	slot.set_meta("open", true)
	var edge: StyleBoxFlat = slot.get_meta("edge")
	edge.border_color = Color("f0d78a")
	edge.bg_color = Color("1c1612")
	slot.add_theme_stylebox_override("panel", edge)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(tex_rect, "modulate", Color.WHITE, 0.16)
	tw.tween_property(name, "modulate:a", 1.0, 0.16)
	slot.pivot_offset = slot.size * 0.5
	var pop := create_tween()
	pop.tween_property(slot, "scale", Vector2(1.06, 1.06), 0.08)
	pop.tween_property(slot, "scale", Vector2.ONE, 0.1)
	_show_detail(entry)
	if sfx != null and sfx.has_method("play_event"):
		sfx.play_event(&"bucket.card_hover")


func _on_card_exit(slot: PanelContainer, bucket_n: int) -> void:
	if not bool(slot.get_meta("open", false)):
		return
	var edge: StyleBoxFlat = slot.get_meta("edge")
	edge.border_color = BucketRules.color_of(bucket_n)
	slot.add_theme_stylebox_override("panel", edge)


func _show_detail(entry: Dictionary) -> void:
	_kind.text = str(entry.get("kind", "")).to_upper()
	_dname.text = str(entry.get("name", ""))
	var bits: PackedStringArray = PackedStringArray()
	var call_s: String = str(entry.get("call", ""))
	if call_s != "":
		bits.append(call_s)
	if str(entry.get("atk", "")) != "":
		bits.append("Attack %s" % entry.get("atk", ""))
	if str(entry.get("hp", "")) != "":
		bits.append("HP %s" % entry.get("hp", ""))
	_stats.text = "   ·   ".join(bits)
	_body.text = str(entry.get("ability", ""))


func _clear_detail() -> void:
	_kind.text = ""
	_dname.text = ""
	_stats.text = ""
	_body.text = "Hover a shadow."


func _on_next() -> void:
	if _next.disabled:
		return
	_go = true
