extends ColorRect
## Developer writing desk. Save writes player-copy, lore, names, and card wording.

signal saved(items: Array, monsters: Array)
signal closed

const COPY := preload("res://scripts/player_copy.gd")
const LEGEND := "Every player-facing line. Header buttons jump the outline. Gold words are shared names — change them under Names. Save locks what you change. {item} {n} {k} stay as braces. Arrows move between boxes. Space types. Enter saves. Esc closes without saving. Ctrl+F filter."

const SECTIONS: Array = [
	{"id": "intro", "label": "Intro"},
	{"id": "ending", "label": "Ending"},
	{"id": "nib", "label": "Nib"},
	{"id": "cabin", "label": "Cabin"},
	{"id": "journal", "label": "Journal"},
	{"id": "will", "label": "Will"},
	{"id": "titles", "label": "Titles"},
	{"id": "tutorial", "label": "Tutorial"},
	{"id": "combat", "label": "Combat"},
	{"id": "taunts", "label": "Taunts"},
	{"id": "cards", "label": "Cards"},
	{"id": "map", "label": "Map"},
	{"id": "radio", "label": "Radio"},
	{"id": "drawer", "label": "Drawer"},
]

var sfx
var _rows: Array = []
var _names: Array = []
var _fields: Dictionary = {}
var _name_fields: Dictionary = {}
var _dirty: bool = false
var _section: String = "intro"
var _outline: String = ""
var _filter: String = ""
var _was_paused: bool = false
var _esc_armed: bool = false
var _collapsed: Dictionary = {}
var _status: Label
var _search: LineEdit
var _list: VBoxContainer
var _scroll: ScrollContainer
var _outline_box: VBoxContainer
var _chips: HFlowContainer
var _focus_edit: TextEdit
var _hl: NameHL
var _names_mode: bool = false
var _fitting: bool = false
var _nav: Array = []


func setup(p_sfx) -> void:
	sfx = p_sfx
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("authoring_overlay")
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	color = Color("1a1410")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var vp_node := get_viewport()
	if vp_node != null and not vp_node.size_changed.is_connected(_fit):
		vp_node.size_changed.connect(_fit)
	_hl = NameHL.new()
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
	col.add_theme_constant_override("separation", 6)
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
	_search.placeholder_text = "Ctrl+F · filter section, key, or line"
	_search.custom_minimum_size = Vector2(280, 36)
	_skin_edit(_search)
	_search.text_changed.connect(func(t: String) -> void:
		_flush()
		_filter = t
		_rebuild()
	)
	head.add_child(_search)
	head.add_child(_insert_menu())
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(_btn("Names", Color("3a3220"), Color("c4a574"), _open_names, 90))
	head.add_child(_btn("Save all", Color("3a2820"), Color("c4a574"), _on_save, 110))
	head.add_child(_btn("Close", Color("3a3220"), Color("9a8b78"), close_editor, 90))

	var legend := Label.new()
	legend.text = LEGEND
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.add_theme_font_size_override("font_size", 12)
	legend.add_theme_color_override("font_color", Color("6b4a10"))
	col.add_child(legend)

	_chips = HFlowContainer.new()
	_chips.add_theme_constant_override("h_separation", 6)
	_chips.add_theme_constant_override("v_separation", 6)
	col.add_child(_chips)
	for spec in SECTIONS:
		var id: String = str(spec["id"])
		var chip := _chip(str(spec["label"]), id == "intro")
		chip.pressed.connect(_set_section.bind(id))
		chip.set_meta("sec", id)
		_chips.add_child(chip)

	_status = Label.new()
	_status.text = "…"
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	col.add_child(_status)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	col.add_child(body)

	var nav_wrap := PanelContainer.new()
	nav_wrap.custom_minimum_size = Vector2(188, 0)
	nav_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var nsb := StyleBoxFlat.new()
	nsb.bg_color = Color("efe4d4")
	nsb.border_color = Color("c4a574")
	nsb.set_border_width_all(1)
	nsb.set_corner_radius_all(8)
	nsb.content_margin_left = 6
	nsb.content_margin_right = 6
	nsb.content_margin_top = 6
	nsb.content_margin_bottom = 6
	nav_wrap.add_theme_stylebox_override("panel", nsb)
	body.add_child(nav_wrap)
	var nav_scroll := ScrollContainer.new()
	nav_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	nav_wrap.add_child(nav_scroll)
	_outline_box = VBoxContainer.new()
	_outline_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_outline_box.add_theme_constant_override("separation", 3)
	nav_scroll.add_child(_outline_box)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	body.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	_scroll.add_child(_list)


func _insert_menu() -> MenuButton:
	var b := MenuButton.new()
	b.text = "Insert name"
	b.custom_minimum_size = Vector2(130, 36)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("1c120c"))
	b.about_to_popup.connect(_fill_insert_popup.bind(b))
	return b


func _fill_insert_popup(b: MenuButton) -> void:
	var pop: PopupMenu = b.get_popup()
	pop.clear()
	if not pop.id_pressed.is_connected(_insert_name):
		pop.id_pressed.connect(_insert_name)
	var i := 0
	for row in _names:
		pop.add_item("%s  ·  %s" % [str(row.get("display", "")), str(row.get("id", ""))], i)
		i += 1


func _insert_name(idx: int) -> void:
	if idx < 0 or idx >= _names.size():
		return
	if _focus_edit == null or not is_instance_valid(_focus_edit):
		_status.text = "Click a line first, then Insert name."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return
	var display: String = str(_names[idx].get("display", ""))
	_focus_edit.insert_text_at_caret(display)
	_dirty = true
	_esc_armed = false


func _fit() -> void:
	if _fitting or not is_inside_tree():
		return
	var vp: Vector2 = get_viewport_rect().size
	if vp.x < 8.0:
		return
	_fitting = true
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if size != vp:
		size = vp
	if global_position != Vector2.ZERO:
		global_position = Vector2.ZERO
	_fitting = false


func open_script() -> void:
	COPY.reload()
	_rows = COPY.script_rows()
	_rows.append_array(COPY.lore_rows())
	_rows.append_array(COPY.card_snapshot())
	_names = COPY.name_rows()
	_hl.needles = COPY.displays_for_highlight()
	_filter = ""
	_section = "intro"
	_outline = ""
	_names_mode = false
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
	_status.text = "%s lines · Save writes copy, lore, names, and card wording" % _rows.size()
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	call_deferred("_fit")
	call_deferred("_focus_nav", 1 if _nav.size() > 1 else 0)


func close_editor() -> void:
	visible = false
	_dirty = false
	_esc_armed = false
	get_tree().paused = _was_paused
	closed.emit()


func _open_names() -> void:
	_flush()
	_names_mode = true
	_section = "names"
	_paint_chips()
	_rebuild()


func _set_section(sec: String) -> void:
	_flush()
	_names_mode = false
	_section = sec
	_outline = ""
	_paint_chips()
	_rebuild()


func _paint_chips() -> void:
	for chip in _chips.get_children():
		if chip is Button:
			_paint_chip(chip as Button, str(chip.get_meta("sec", "")) == _section)


func _set_outline(oid: String) -> void:
	_flush()
	_outline = oid
	_rebuild()


func _rebuild() -> void:
	_fields.clear()
	_name_fields.clear()
	_nav.clear()
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	for c2 in _outline_box.get_children():
		_outline_box.remove_child(c2)
		c2.queue_free()
	if _names_mode:
		_rebuild_names()
		return
	var q: String = _filter.strip_edges().to_lower()
	var grouped: Dictionary = {}
	var order: Array = []
	for row in _rows:
		var sec: String = _section_of(row)
		if q == "" and sec != _section:
			continue
		var blob: String = ("%s %s %s %s" % [sec, row.get("key", ""), row.get("where", ""), row.get("text", "")]).to_lower()
		if q != "" and not blob.contains(q):
			continue
		var room: String = _outline_id(row)
		if q == "" and _outline != "" and room != _outline:
			continue
		var gid: String = "%s/%s/%s" % [sec, room, _group_of(row)]
		if not grouped.has(gid):
			grouped[gid] = []
			order.append(gid)
		grouped[gid].append(row)
	_fill_outline(q)
	var shown := 0
	for gid in order:
		var bits: PackedStringArray = str(gid).split("/")
		var gname: String = bits[bits.size() - 1] if bits.size() > 0 else gid
		var room: String = bits[1] if bits.size() > 2 else ""
		var collapsed: bool = bool(_collapsed.get(gid, _default_collapsed(str(bits[0] if bits.size() > 0 else ""))))
		var head := Button.new()
		var title: String = gname if room == "" or room == gname else "%s · %s" % [room, gname]
		head.text = ("%s  %s" % ["▸" if collapsed else "▾", title])
		head.alignment = HORIZONTAL_ALIGNMENT_LEFT
		head.focus_mode = Control.FOCUS_NONE
		head.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_skin_group(head)
		var sec_id: String = str(bits[0]) if bits.size() > 0 else ""
		head.pressed.connect(_toggle_group.bind(gid, sec_id))
		_list.add_child(head)
		if collapsed:
			continue
		for row2 in grouped[gid]:
			_list.add_child(_make_row(row2))
			shown += 1
	_status.text = "%s shown · %s total" % [shown, _rows.size()]
	_wire_nav()


func _rebuild_names() -> void:
	var cap := Label.new()
	cap.text = "Shared names. Changing a display updates every marked line after Save (reload the game to see it in play)."
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_size_override("font_size", 13)
	cap.add_theme_color_override("font_color", Color("6b4a10"))
	_list.add_child(cap)
	for row in _names:
		_list.add_child(_make_name_row(row))
	_status.text = "%s names · stored as {id} and {id|poss}" % _names.size()
	_wire_nav()
	var nav := Label.new()
	nav.text = "Names"
	nav.add_theme_font_size_override("font_size", 16)
	nav.add_theme_color_override("font_color", Color("6b4a10"))
	_outline_box.add_child(nav)


func _fill_outline(q: String) -> void:
	var rooms: Array = []
	var seen := {}
	for row in _rows:
		var sec: String = _section_of(row)
		if q == "" and sec != _section:
			continue
		var blob: String = ("%s %s %s %s" % [sec, row.get("key", ""), row.get("where", ""), row.get("text", "")]).to_lower()
		if q != "" and not blob.contains(q):
			continue
		var oid: String = _outline_id(row)
		if seen.has(oid):
			continue
		seen[oid] = true
		rooms.append(oid)
	if rooms.size() <= 1:
		var one := Label.new()
		one.text = _section_label(_section)
		one.add_theme_font_size_override("font_size", 16)
		one.add_theme_color_override("font_color", Color("6b4a10"))
		_outline_box.add_child(one)
		return
	for oid in rooms:
		var b := Button.new()
		b.text = oid
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_paint_chip(b, oid == _outline or (_outline == "" and oid == rooms[0]))
		b.pressed.connect(_set_outline.bind(oid))
		_outline_box.add_child(b)


func _section_label(sec: String) -> String:
	for spec in SECTIONS:
		if str(spec["id"]) == sec:
			return str(spec["label"])
	return sec.capitalize()


func _default_collapsed(sec: String) -> bool:
	return sec == "taunts"


func _section_of(row: Dictionary) -> String:
	var cat: String = str(row.get("cat", ""))
	var key: String = str(row.get("key", ""))
	if key.begins_with("lore.drawer") or cat == "Drawer":
		return "drawer"
	if key.begins_with("lore.") or cat == "Journal":
		return "journal"
	match cat:
		"Intro":
			return "intro"
		"Ending", "Defeat":
			return "ending"
		"Nib":
			return "nib"
		"Cabin", "Keyring", "Rope", "Sack":
			return "cabin"
		"Will":
			return "will"
		"Title", "Pause":
			return "titles"
		"Tutorial":
			return "tutorial"
		"Cues", "Combat", "Inspect", "Warns", "Door":
			return "combat"
		"Taunts":
			return "taunts"
		"Cards":
			return "cards"
		"Map":
			return "map"
		"Radio":
			return "radio"
		_:
			return cat.to_lower()


func _outline_id(row: Dictionary) -> String:
	var sec: String = _section_of(row)
	var key: String = str(row.get("key", ""))
	if sec == "cabin":
		return _cabin_room(key, str(row.get("cat", "")))
	if sec == "nib":
		if key.contains(".first"):
			return "First visit"
		if key.contains(".interrupt"):
			return "Interrupt"
		if key.contains(".prompt"):
			return "Prompt"
		return "Chatter"
	if sec == "journal":
		if key.begins_with("lore.monster"):
			return "Bestiary"
		if key.begins_with("lore.item"):
			return "Curiosities"
		if key.begins_with("lore.letter"):
			return "Letters"
		if key == "lore.engraving":
			return "Engraving"
		return "Labels"
	if sec == "cards":
		return "Items" if key.begins_with("card.item") else "Monsters"
	if sec == "taunts":
		var bits: PackedStringArray = key.split(".")
		return bits[1] if bits.size() > 1 else "Taunts"
	if sec == "combat":
		return str(row.get("cat", "Combat"))
	if sec == "intro":
		return "Buttons" if key.ends_with(".skip") or key.ends_with(".next") else "Panels"
	if sec == "titles":
		return str(row.get("cat", "Title"))
	return _section_label(sec)


func _cabin_room(key: String, cat: String) -> String:
	if cat in ["Keyring", "Rope", "Sack"]:
		return "Run"
	if key.contains("room.hall") or key.contains(".hall.") or key.contains("gear.") or key.contains(".cabinet") or key.ends_with(".gauge") and key.contains("cabin"):
		if key.contains("cabin.hot.gauge") or key.contains("cabin.hall") or key.contains("cabin.gear") or key.contains("cabinet"):
			return "Hall"
	if key.contains("room.study") or key.contains(".journal") or key.contains(".will") or key.contains(".patents") or key.contains(".brag") or key.contains(".model"):
		if not key.contains("lore."):
			return "Study"
	if key.contains("room.workshop") or key.contains("dummy"):
		return "Workshop"
	if key.contains("room.loft") or key.contains(".bed") or key.contains("telescope") or key.contains(".trunk") or key.contains(".cat") or key.contains("drawer") or key.contains("geode"):
		return "Loft"
	return "Main"


func _group_of(row: Dictionary) -> String:
	var key: String = str(row.get("key", ""))
	var where: String = str(row.get("where", "")).to_lower()
	if key.contains(".hot.") or key.contains(".room."):
		return "Hover labels"
	if key.ends_with(".yes") or key.ends_with(".no") or key.ends_with(".close") or key.ends_with(".wear") or key.ends_with(".hang") or key.ends_with(".skip") or key.ends_with(".next") or where.contains("button"):
		return "Buttons"
	if key.begins_with("card.") and key.ends_with(".name"):
		return "Names"
	if key.begins_with("card.") and (key.ends_with(".ability") or key.ends_with(".call_name")):
		return "Ability"
	if key.begins_with("card."):
		return "Shift / log"
	if key.begins_with("lore.item") and key.contains(".fn."):
		return "Footnotes"
	if key.begins_with("lore.item"):
		return "Journal"
	if key.begins_with("lore.letter") and key.ends_with(".title"):
		return "Titles"
	if key.begins_with("lore.letter"):
		return "Bodies"
	return "Flavor"


func _toggle_group(gid: String, sec_id: String) -> void:
	_flush()
	var now: bool = bool(_collapsed.get(gid, _default_collapsed(sec_id)))
	_collapsed[gid] = not now
	_rebuild()


func _make_row(row: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var author: bool = bool(row.get("author_lock", false))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f7ead4") if author else Color("fff6e8")
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
	cap.text = where_s
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_size_override("font_size", 12)
	cap.add_theme_color_override("font_color", Color("6b1008") if author else Color("6b4a10"))
	col.add_child(cap)
	var e := TextEdit.new()
	e.text = COPY.apply_names(str(row.get("text", "")))
	e.custom_minimum_size = Vector2(0, 56)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = true
	_skin_edit(e)
	var hl := NameHL.new()
	hl.needles = _hl.needles
	e.syntax_highlighter = hl
	e.focus_entered.connect(func() -> void:
		_focus_edit = e
	)
	_register_nav(e)
	var stored := Label.new()
	stored.text = "Stored as  %s" % str(row.get("text", ""))
	stored.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stored.add_theme_font_size_override("font_size", 11)
	stored.add_theme_color_override("font_color", Color("8a6a3a"))
	e.text_changed.connect(func() -> void:
		_dirty = true
		_esc_armed = false
		stored.text = "Stored as  %s" % COPY.tokenize(e.text)
	)
	col.add_child(e)
	col.add_child(stored)
	_fields[str(row.get("key", ""))] = e
	return p


func _make_name_row(row: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fff6e8")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	p.add_child(col)
	var cap := Label.new()
	var nid: String = str(row.get("id", ""))
	cap.text = "{%s}   ·   possessive {%s|poss}" % [nid, nid]
	cap.add_theme_font_size_override("font_size", 12)
	cap.add_theme_color_override("font_color", Color("6b4a10"))
	col.add_child(cap)
	var display := LineEdit.new()
	display.text = str(row.get("display", ""))
	display.placeholder_text = "Display word"
	_skin_edit(display)
	display.text_changed.connect(func(_t: String) -> void:
		_dirty = true
		_esc_armed = false
	)
	col.add_child(display)
	var note := LineEdit.new()
	note.text = str(row.get("note", ""))
	note.placeholder_text = "Note (not shown to players)"
	_skin_edit(note)
	note.text_changed.connect(func(_t: String) -> void:
		_dirty = true
		_esc_armed = false
	)
	col.add_child(note)
	_register_nav(display)
	_register_nav(note)
	_name_fields[nid] = {"display": display, "note": note}
	return p


func _flush() -> void:
	for row in _rows:
		var k: String = str(row.get("key", ""))
		var e: Variant = _fields.get(k, null)
		if e is TextEdit:
			row["text"] = COPY.tokenize((e as TextEdit).text)
	for row2 in _names:
		var nid: String = str(row2.get("id", ""))
		var pair: Variant = _name_fields.get(nid, null)
		if typeof(pair) != TYPE_DICTIONARY:
			continue
		var d: Variant = pair.get("display", null)
		var n: Variant = pair.get("note", null)
		if d is LineEdit:
			row2["display"] = (d as LineEdit).text
		if n is LineEdit:
			row2["note"] = (n as LineEdit).text


func _on_save() -> void:
	_flush()
	var path: String = COPY.save_all(_rows, _names)
	if path == "":
		_status.text = "Could not write the script files."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		if sfx:
			sfx.play("error_big", -8.0)
		return
	_dirty = false
	_esc_armed = false
	COPY.reload()
	_hl.needles = COPY.displays_for_highlight()
	_status.text = "Saved and locked · copy, lore, names, cards"
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	if sfx:
		sfx.play("book", -8.0)
		sfx.play("confirm_big", -12.0)
	var items: Array = COPY.last_board.get("items", []) if typeof(COPY.last_board.get("items", [])) == TYPE_ARRAY else []
	var monsters: Array = COPY.last_board.get("monsters", []) if typeof(COPY.last_board.get("monsters", [])) == TYPE_ARRAY else []
	saved.emit(items, monsters)
	_rebuild()


func _skin_group(b: Button) -> void:
	b.add_theme_color_override("font_color", Color("6b4a10"))
	var s := StyleBoxFlat.new()
	s.bg_color = Color("efe4d4")
	s.border_color = Color("c4a574")
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_stylebox_override("hover", s)


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
	b.focus_mode = Control.FOCUS_NONE
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
	b.focus_mode = Control.FOCUS_NONE
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


func _register_nav(e: Control) -> void:
	_nav.append(e)
	if not e.has_meta("nav_hook"):
		e.set_meta("nav_hook", true)
		e.gui_input.connect(_on_edit_nav.bind(e))


func _wire_nav() -> void:
	if _search != null and _nav.find(_search) < 0:
		_nav.insert(0, _search)
		if not _search.has_meta("nav_hook"):
			_search.set_meta("nav_hook", true)
			_search.gui_input.connect(_on_edit_nav.bind(_search))
	if _nav.is_empty():
		return
	for i in _nav.size():
		var cur: Control = _nav[i]
		var nxt: Control = _nav[(i + 1) % _nav.size()]
		var prv: Control = _nav[(i - 1 + _nav.size()) % _nav.size()]
		cur.focus_next = nxt.get_path()
		cur.focus_previous = prv.get_path()
		cur.focus_neighbor_bottom = nxt.get_path()
		cur.focus_neighbor_top = prv.get_path()


func _on_edit_nav(event: InputEvent, e: Control) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.ctrl_pressed or key.alt_pressed or key.meta_pressed:
		return
	var i: int = _nav.find(e)
	if i < 0:
		return
	if key.keycode == KEY_UP:
		if e is LineEdit or (e is TextEdit and (e as TextEdit).get_caret_line() <= 0):
			_focus_nav(i - 1)
			e.accept_event()
	elif key.keycode == KEY_DOWN:
		if e is LineEdit or (e is TextEdit and (e as TextEdit).get_caret_line() >= (e as TextEdit).get_line_count() - 1):
			_focus_nav(i + 1)
			e.accept_event()


func _focus_nav(i: int) -> void:
	if _nav.is_empty():
		return
	var n: int = _nav.size()
	i = (i + n) % n
	var e: Control = _nav[i]
	e.grab_focus()
	if e is LineEdit:
		(e as LineEdit).caret_column = (e as LineEdit).text.length()
	if _scroll:
		_scroll.ensure_control_visible(e)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE:
		close_editor()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		if key.ctrl_pressed or key.alt_pressed or key.meta_pressed:
			return
		_on_save()
		get_viewport().set_input_as_handled()
		return
	if key.ctrl_pressed:
		match key.keycode:
			KEY_S:
				_on_save()
				get_viewport().set_input_as_handled()
			KEY_F:
				if _search:
					_search.grab_focus()
					_search.select_all()
				get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT or key.keycode == KEY_UP or key.keycode == KEY_DOWN or key.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()


class NameHL extends SyntaxHighlighter:
	var needles: Array = []

	func _get_line_syntax_highlighting(line: int) -> Dictionary:
		var te: TextEdit = get_text_edit()
		if te == null:
			return {}
		var text: String = te.get_line(line)
		var out := {}
		var ink := Color("1c120c")
		var gold := Color("8a5a10")
		out[0] = {"color": ink}
		if needles.is_empty() or text == "":
			return out
		var hits: Array = []
		for needle in needles:
			var n: String = str(needle)
			if n == "":
				continue
			var i := 0
			while true:
				var at: int = text.findn(n, i)
				if at < 0:
					break
				var before_ok: bool = at == 0 or not _word(text.substr(at - 1, 1))
				var after_i: int = at + n.length()
				var after_ok: bool = after_i >= text.length() or not _word(text.substr(after_i, 1))
				if before_ok and after_ok:
					hits.append([at, after_i])
				i = at + 1
		hits.sort_custom(func(a, b) -> bool: return int(a[0]) < int(b[0]))
		for hit in hits:
			out[int(hit[0])] = {"color": gold}
			out[int(hit[1])] = {"color": ink}
		return out

	func _word(ch: String) -> bool:
		if ch == "":
			return false
		var c: String = ch.to_lower()
		if c >= "a" and c <= "z":
			return true
		if c >= "0" and c <= "9":
			return true
		return c == "_"
