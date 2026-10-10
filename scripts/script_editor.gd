extends ColorRect
## Every player-facing line except card stats. Save writes data/player-copy.json and .csv.

signal saved
signal closed

const COPY := preload("res://scripts/player_copy.gd")
const CATS := ["All", "Title", "Pause", "Tutorial", "Door", "Cues", "Combat", "Inspect", "Warns", "Taunts", "Cards"]
const LEGEND := "This is the game's script. Tutorial, title, door taunts, cues, warns. Card names and abilities at the bottom are Roster — edit those there. Save locks every line you change so chat cannot rewrite it unless you override. {item} {n} {k} stay as braces. Ctrl+F filter · Ctrl+S save · Esc discard."

var sfx
var _rows: Array = []
var _fields: Dictionary = {}
var _dirty: bool = false
var _cat: String = "All"
var _filter: String = ""
var _was_paused: bool = false
var _esc_armed: bool = false
var _status: Label
var _search: LineEdit
var _list: VBoxContainer
var _scroll: ScrollContainer
var _chips: HBoxContainer


func setup(p_sfx) -> void:
	sfx = p_sfx
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	color = Color("1a1410")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	resized.connect(_fit)
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 8)
	root.add_theme_constant_override("margin_right", 8)
	root.add_theme_constant_override("margin_top", 8)
	root.add_theme_constant_override("margin_bottom", 8)
	add_child(root)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f3e6d0")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	root.add_child(panel)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	col.add_child(head)
	var title := Label.new()
	title.text = "Script"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("1c120c"))
	head.add_child(title)
	_search = LineEdit.new()
	_search.placeholder_text = "Ctrl+F · filter category, key, or line"
	_search.custom_minimum_size = Vector2(320, 36)
	_skin_edit(_search)
	_search.text_changed.connect(func(t: String) -> void:
		_flush()
		_filter = t
		_rebuild()
	)
	head.add_child(_search)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(_btn("Save all", Color("3a2820"), Color("c4a574"), _on_save, 110))
	head.add_child(_btn("Close", Color("3a3220"), Color("9a8b78"), close_editor, 90))

	var legend := Label.new()
	legend.text = LEGEND
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.add_theme_font_size_override("font_size", 13)
	legend.add_theme_color_override("font_color", Color("6b4a10"))
	col.add_child(legend)

	_chips = HBoxContainer.new()
	_chips.add_theme_constant_override("separation", 6)
	col.add_child(_chips)
	for c in CATS:
		var chip := _chip(str(c), c == "All")
		chip.pressed.connect(_set_cat.bind(str(c)))
		chip.set_meta("cat", str(c))
		_chips.add_child(chip)

	_status = Label.new()
	_status.text = "…"
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	col.add_child(_status)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	col.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	_scroll.add_child(_list)


func _fit() -> void:
	if not is_inside_tree():
		return
	var vp: Vector2 = get_viewport_rect().size
	if vp.x < 8.0:
		return
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	size = vp
	global_position = Vector2.ZERO


func open_script() -> void:
	COPY.reload()
	_rows = COPY.script_rows()
	_rows.append_array(COPY.card_snapshot())
	_filter = ""
	_cat = "All"
	if _search:
		_search.text = ""
	_dirty = false
	_esc_armed = false
	_rebuild()
	_was_paused = get_tree().paused
	visible = true
	get_tree().paused = true
	if sfx:
		sfx.play("book", -10.0)
	_status.text = "%s lines · Save writes data/player-copy.json + .csv" % _rows.size()
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	call_deferred("_fit")


func close_editor() -> void:
	if _dirty and not _esc_armed:
		_esc_armed = true
		_status.text = "Unsaved edits. Esc again to discard, or Ctrl+S to save."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return
	visible = false
	_dirty = false
	get_tree().paused = _was_paused
	closed.emit()


func _set_cat(cat: String) -> void:
	_flush()
	_cat = cat
	for chip in _chips.get_children():
		if chip is Button:
			_paint_chip(chip as Button, str(chip.get_meta("cat", "")) == cat)
	_rebuild()


func _rebuild() -> void:
	_fields.clear()
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	var q: String = _filter.strip_edges().to_lower()
	var last_cat := ""
	var shown := 0
	for row in _rows:
		var cat: String = str(row.get("cat", ""))
		if _cat != "All" and cat != _cat:
			continue
		var blob: String = ("%s %s %s %s" % [cat, row.get("key", ""), row.get("where", ""), row.get("text", "")]).to_lower()
		if q != "" and not blob.contains(q):
			continue
		if cat != last_cat:
			var h := Label.new()
			h.text = cat
			h.add_theme_font_size_override("font_size", 20)
			h.add_theme_color_override("font_color", Color("6b4a10"))
			_list.add_child(h)
			last_cat = cat
		_list.add_child(_make_row(row, cat == "Cards"))
		shown += 1
	_status.text = "%s shown · %s total" % [shown, _rows.size()]


func _make_row(row: Dictionary, roster_only: bool) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var author: bool = bool(row.get("author_lock", false))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fff6e8") if not roster_only else Color("efe4d4")
	if author:
		sb.bg_color = Color("f7ead4")
	sb.border_color = Color("6b1008") if author else Color("c4a574")
	sb.set_border_width_all(2 if author else 1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	p.add_child(col)
	var cap := Label.new()
	var where_s: String = str(row.get("where", row.get("key", "")))
	if author:
		where_s = "Locked · %s" % where_s
	elif roster_only:
		where_s = "Roster · %s" % where_s
	cap.text = where_s
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_size_override("font_size", 12)
	cap.add_theme_color_override("font_color", Color("6b1008") if author else Color("6b4a10"))
	col.add_child(cap)
	var e := TextEdit.new()
	e.text = str(row.get("text", ""))
	e.custom_minimum_size = Vector2(0, 56)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = true
	e.editable = not roster_only
	_skin_edit(e)
	if roster_only:
		e.focus_mode = Control.FOCUS_NONE
	else:
		e.text_changed.connect(func() -> void:
			_dirty = true
			_esc_armed = false
		)
	col.add_child(e)
	_fields[str(row.get("key", ""))] = e
	return p


func _flush() -> void:
	for row in _rows:
		var k: String = str(row.get("key", ""))
		if str(row.get("cat", "")) == "Cards":
			continue
		var e: Variant = _fields.get(k, null)
		if e is TextEdit:
			row["text"] = (e as TextEdit).text


func _on_save() -> void:
	_flush()
	var path: String = COPY.save_script(_rows)
	if path == "":
		_status.text = "Could not write data/player-copy.json."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		if sfx:
			sfx.play("error_big", -8.0)
		return
	_dirty = false
	_esc_armed = false
	_status.text = "Saved and locked · %s · also data/player-copy.csv" % path
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	if sfx:
		sfx.play("book", -8.0)
		sfx.play("confirm_big", -12.0)
	saved.emit()


func _skin_edit(e: Control) -> void:
	e.add_theme_color_override("font_color", Color("1c120c"))
	e.add_theme_color_override("caret_color", Color("6b1008"))
	e.add_theme_constant_override("caret_width", 3)
	e.add_theme_color_override("selection_color", Color("e8c36a"))
	e.add_theme_color_override("font_placeholder_color", Color("8a6a3a"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fffaf2")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(5)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	var focus := sb.duplicate() as StyleBoxFlat
	focus.border_color = Color("6b1008")
	focus.set_border_width_all(3)
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("focus", focus)
	e.add_theme_stylebox_override("read_only", sb)


func _chip(label: String, on: bool) -> Button:
	var b := Button.new()
	b.text = label
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_paint_chip(b, on)
	return b


func _paint_chip(b: Button, on: bool) -> void:
	b.add_theme_color_override("font_color", Color("f0e6d8") if on else Color("1c120c"))
	var s := StyleBoxFlat.new()
	s.bg_color = Color("3a2820") if on else Color("efe4d4")
	s.border_color = Color("e8c36a") if on else Color("c4a574")
	s.set_border_width_all(2)
	s.set_corner_radius_all(999)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_stylebox_override("hover", s)


func _btn(label: String, fill: Color, rim: Color, cb: Callable, width: float) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(width, 36)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = rim
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	n.content_margin_left = 12
	n.content_margin_right = 12
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_editor()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed:
		match event.keycode:
			KEY_S:
				_on_save()
				get_viewport().set_input_as_handled()
			KEY_F:
				if _search:
					_search.grab_focus()
					_search.select_all()
				get_viewport().set_input_as_handled()
