extends ColorRect
## In-game content sheet. Same fields as the HTML board. Save writes the repo JSON.

signal saved(kind: String, card_id: String, card: Dictionary)
signal closed

const BOARD_PATH := "res://data/content-board.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")
const LINES := preload("res://scripts/monster_lines.gd")
const UX := preload("res://scripts/ux_style.gd")
var _kind: String = ""
var _id: String = ""
var _board: Dictionary = {}
var _original: Dictionary = {}
var _fields: Dictionary = {}
var _status: Label
var _scroll: ScrollContainer
var _sheet: VBoxContainer
var _was_paused: bool = false


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_preset(PRESET_FULL_RECT)
	color = Color("100e0ce8")
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 130

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f3e6d0")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size = Vector2(720, 820)
	center.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	panel.add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	root.add_child(head)
	var title := Label.new()
	title.text = "Edit card"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("1c120c"))
	head.add_child(title)
	head.add_child(_btn("Cancel", Color("3a3220"), Color("9a8b78"), close_editor, 110))
	head.add_child(_btn("Save", Color("3a2820"), Color("c4a574"), _on_save, 110))

	var hint := Label.new()
	hint.text = "Enter saves and closes. Esc closes without saving. Shift+Enter makes a new line. Save writes the board and catalog, and locks this card. Chat will not rewrite locked fields unless you clearly override in chat, and even then it should stop and ask. Ctrl+S also saves."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("6b4a10"))
	root.add_child(hint)

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	root.add_child(_status)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size = Vector2(0, 560)
	root.add_child(_scroll)
	_sheet = VBoxContainer.new()
	_sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sheet.add_theme_constant_override("separation", 4)
	_scroll.add_child(_sheet)


func open_card(kind: String, card_id: String, catalog_card: Dictionary = {}) -> void:
	_kind = kind
	_id = card_id
	_load_board()
	var card: Dictionary = _find_card(kind, card_id)
	if card.is_empty():
		card = _from_catalog(kind, card_id, catalog_card)
	else:
		card = card.duplicate(true)
		_fill_bases_from_catalog(card, catalog_card)
	_original = card.duplicate(true)
	_rebuild(card)
	_status.text = "Editing %s · %s" % [kind, card_id]
	_was_paused = get_tree().paused
	visible = true
	get_tree().paused = true


func close_editor() -> void:
	visible = false
	get_tree().paused = _was_paused
	closed.emit()


func _load_board() -> void:
	var f := FileAccess.open(BOARD_PATH, FileAccess.READ)
	if f == null:
		_board = {"id": "boss-rush-content-board", "updated": "", "monsters": [], "items": []}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		_board = parsed
	else:
		_board = {"id": "boss-rush-content-board", "updated": "", "monsters": [], "items": []}


func _find_card(kind: String, card_id: String) -> Dictionary:
	var arr: Array = _board.get("monsters" if kind == "monster" else "items", [])
	for c in arr:
		if str(c.get("id", "")) == card_id:
			return c
	return {}


func _from_catalog(kind: String, card_id: String, cat: Dictionary) -> Dictionary:
	var atk: Variant = cat.get("atk", {})
	var hp: Variant = cat.get("hp", {})
	var atk_d: Dictionary = atk if typeof(atk) == TYPE_DICTIONARY else {}
	var hp_d: Dictionary = hp if typeof(hp) == TYPE_DICTIONARY else {}
	return {
		"id": card_id,
		"name": str(cat.get("name", card_id)),
		"kind": kind,
		"status": "live",
		"rarity": str(cat.get("rarity", "starter")),
		"tier": int(cat.get("tier", 1)),
		"count": int(cat.get("count", 1)),
		"priority": int(cat.get("priority", 3)),
		"atk_base": atk_d.get("base", null),
		"hp_base": hp_d.get("base", null),
		"atk_formula": str(atk_d.get("formula", "")),
		"hp_formula": str(hp_d.get("formula", "")),
		"ability": str(cat.get("ability", "")),
		"explainer": str(cat.get("explainer", "")),
		"call_name": LINES.call_of(card_id, cat),
		"reminder": LINES.reminder_of(card_id, cat),
		"flow": str(cat.get("defined", "")),
		"notes": str(cat.get("exceptions", cat.get("notes", ""))),
		"ops": cat.get("ops", {}),
		"card_color": str(cat.get("card_color", "")),
		"face_text": str(cat.get("face_text", "")),
		"contradiction_ids": [],
		"review": REVIEW_STAGE.of_card(cat),
		"review_note": str(cat.get("review_note", "")),
	}


func _fill_bases_from_catalog(card: Dictionary, cat: Dictionary) -> void:
	if cat.is_empty():
		return
	var atk: Variant = cat.get("atk", {})
	var hp: Variant = cat.get("hp", {})
	var atk_d: Dictionary = atk if typeof(atk) == TYPE_DICTIONARY else {}
	var hp_d: Dictionary = hp if typeof(hp) == TYPE_DICTIONARY else {}
	if card.get("atk_base") == null and atk_d.has("base"):
		card["atk_base"] = atk_d.get("base")
	if card.get("hp_base") == null and hp_d.has("base"):
		card["hp_base"] = hp_d.get("base")
	if str(card.get("atk_formula", "")).strip_edges() == "" and str(atk_d.get("formula", "")) != "":
		card["atk_formula"] = str(atk_d.get("formula", ""))
	if str(card.get("hp_formula", "")).strip_edges() == "" and str(hp_d.get("formula", "")) != "":
		card["hp_formula"] = str(hp_d.get("formula", ""))
	if not card.has("call_name"):
		card["call_name"] = LINES.call_of(str(card.get("id", "")), cat)
	if not card.has("reminder"):
		card["reminder"] = LINES.reminder_of(str(card.get("id", "")), cat)
	if _kind != "monster" and not card.has("face_text"):
		card["face_text"] = str(cat.get("face_text", ""))


func _explainer_shown(card: Dictionary) -> String:
	var ex: String = str(card.get("explainer", "")).strip_edges()
	if ex == "---":
		return ""
	return ex


func _call_shown(card: Dictionary) -> String:
	return LINES.call_of(str(card.get("id", "")), card)


func _reminder_shown(card: Dictionary) -> String:
	return LINES.reminder_of(str(card.get("id", "")), card)


func _rebuild(card: Dictionary) -> void:
	_fields.clear()
	for c in _sheet.get_children():
		_sheet.remove_child(c)
		c.queue_free()
	var is_m: bool = _kind == "monster"
	_label_head("%s" % str(card.get("name", _id)))
	if bool(card.get("author_lock", false)):
		var lock_n := Label.new()
		lock_n.text = "Locked by your last Save. Chat will not rewrite these fields unless you override in chat."
		lock_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lock_n.add_theme_font_size_override("font_size", 14)
		lock_n.add_theme_color_override("font_color", Color("6b1008"))
		_sheet.add_child(lock_n)
	var stage: String = REVIEW_STAGE.of_card(card)
	if stage == "rough":
		var banner := Label.new()
		banner.text = "ROUGH — type what to change in the gold box. Save, then tell Cursor."
		banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		banner.add_theme_font_size_override("font_size", 18)
		banner.add_theme_color_override("font_color", Color("8b1e1e"))
		_sheet.add_child(banner)
	var rev_row := _grid(2)
	_add_pick(rev_row, "Review", "review", stage, REVIEW_STAGE.STAGES)
	_sheet.add_child(rev_row)
	_add_review_note(_sheet, str(card.get("review_note", "")), stage)
	if _fields.has("review") and _fields["review"] is OptionButton:
		(_fields["review"] as OptionButton).item_selected.connect(_on_review_pick)
	var row1 := _grid(2)
	_add_line(row1, "Name", "name", str(card.get("name", "")))
	_add_line(row1, "Id", "id", str(card.get("id", _id)), true)
	_sheet.add_child(row1)
	if is_m:
		var copy_h := Label.new()
		copy_h.text = "What the player sees"
		copy_h.add_theme_font_size_override("font_size", 16)
		copy_h.add_theme_color_override("font_color", Color("6b1008"))
		_sheet.add_child(copy_h)
		var copy_n := Label.new()
		copy_n.text = "Save, then look at the fight HUD. Attack, Block, HP, and the other tagged words chip automatically — blocks, attacks, and hp all count."
		copy_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy_n.add_theme_font_size_override("font_size", 13)
		copy_n.add_theme_color_override("font_color", Color("6b4a10"))
		_sheet.add_child(copy_n)
		_add_painted_line(_sheet, "Call name (subtitle under the title)", "call_name", _call_shown(card))
		_add_painted_area(_sheet, "Shift line (replaces the call name while you hold Shift)", "reminder", _reminder_shown(card), 64)
		_add_painted_area(_sheet, "Speech (first-person line in the balloon)", "ability", str(card.get("ability", "")), 90)
	var row2 := _grid(3)
	_add_pick(row2, "Status", "status", str(card.get("status", "live")), ["live", "todo", "hold", "retired"])
	_add_pick(row2, "Rarity", "rarity", str(card.get("rarity", "starter")), ["starter", "uncommon"])
	_add_line(row2, "Tier", "tier", _num_s(card.get("tier", 1)))
	_sheet.add_child(row2)
	var row3 := _grid(3)
	_add_line(row3, "Count", "count", _num_s(card.get("count", 1)))
	_add_line(row3, "Priority", "priority", _num_s(card.get("priority", 3)))
	if is_m:
		_add_line(row3, "ATK base", "atk_base", _num_s(card.get("atk_base", 0)))
	else:
		_add_line(row3, "", "_pad", "")
	_sheet.add_child(row3)
	if is_m:
		var row4 := _grid(2)
		_add_line(row4, "HP base", "hp_base", _num_s(card.get("hp_base", 0)))
		_add_line(row4, "ATK formula", "atk_formula", str(card.get("atk_formula", "")))
		_sheet.add_child(row4)
		_add_area(_sheet, "HP formula", "hp_formula", str(card.get("hp_formula", "")), 48, false)
		var stat_n := Label.new()
		var af: String = str(card.get("atk_formula", "")).strip_edges()
		if af != "":
			stat_n.text = "ATK base is the printed number. This monster's live Attack uses the formula (%s), so changing ATK base will not change the number on the wheel." % af
		else:
			stat_n.text = "ATK base and HP base are the printed numbers the fight uses, unless a formula is filled in."
		stat_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stat_n.add_theme_font_size_override("font_size", 13)
		stat_n.add_theme_color_override("font_color", Color("6b4a10"))
		_sheet.add_child(stat_n)
	if not is_m:
		var color_row := _grid(2)
		_add_color_pick(color_row, "Card color", "card_color", UX.card_color_id(str(card.get("card_color", ""))))
		_add_line(color_row, "", "_pad_color", "")
		_sheet.add_child(color_row)
		var color_n := Label.new()
		color_n.text = "This is the background of the item card in your hand and at the mill. Auto follows the rule (empty rules currently look Attack-red)."
		color_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		color_n.add_theme_font_size_override("font_size", 13)
		color_n.add_theme_color_override("font_color", Color("6b4a10"))
		_sheet.add_child(color_n)
		var face_row := _grid(2)
		_add_line(face_row, "Face text", "face_text", str(card.get("face_text", "")))
		_add_line(face_row, "", "_pad", "")
		_sheet.add_child(face_row)
		var face_n := Label.new()
		face_n.text = "What shows on the hand card when Shift is not held. A number plus ATK, BLK, HEAL, or UTIL (for example 3 ATK). Leave blank to keep the auto number."
		face_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		face_n.add_theme_font_size_override("font_size", 13)
		face_n.add_theme_color_override("font_color", Color("6b4a10"))
		_sheet.add_child(face_n)
		_add_painted_area(_sheet, "Ability (player-facing, short)", "ability", str(card.get("ability", "")), 90)
		_add_painted_area(_sheet, "Callout explainer (the math line on hover)", "explainer", _explainer_shown(card), 80)
	_add_area(_sheet, "Function flow / pseudocode (long)", "flow", str(card.get("flow", "")), 160, true)
	_add_area(_sheet, "Notes for the implementer", "notes", str(card.get("notes", "")), 110, false)
	var ops_s: String = JSON.stringify(card.get("ops", {}), "\t")
	if ops_s == "null":
		ops_s = "{}"
	_add_area(_sheet, "Ops JSON", "ops_text", ops_s, 120, true)


func _label_head(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("1c120c"))
	_sheet.add_child(l)


func _grid(cols: int) -> GridContainer:
	var g := GridContainer.new()
	g.columns = cols
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 4)
	return g


func _cap(host: Control, label: String) -> VBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", 3)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color("6b4a10"))
	wrap.add_child(l)
	host.add_child(wrap)
	return wrap


func _skin_edit(e: Control) -> void:
	e.add_theme_color_override("font_color", Color("1c120c"))
	if e is LineEdit:
		e.add_theme_color_override("font_uneditable_color", Color("6b4a10"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fffaf2")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	if e is LineEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("read_only", sb)
		e.add_theme_stylebox_override("focus", sb)
	elif e is TextEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("focus", sb)
		e.add_theme_stylebox_override("read_only", sb)


func _on_review_pick(_i: int) -> void:
	var stage: String = _text_of("review")
	if _fields.has("review_note") and _fields["review_note"] is TextEdit:
		_skin_review_note(_fields["review_note"] as TextEdit, stage)


func _add_review_note(host: Control, value: String, stage: String) -> void:
	var wrap := VBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.text = "Your notes for Cursor"
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color("8b1e1e") if stage == "rough" else Color("6b4a10"))
	wrap.add_child(l)
	var e := TextEdit.new()
	e.text = value
	e.placeholder_text = "Type what to change. Save, then tell Cursor."
	e.custom_minimum_size = Vector2(0, 140 if stage == "rough" else 80)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	_skin_review_note(e, stage)
	wrap.add_child(e)
	host.add_child(wrap)
	_fields["review_note"] = e


func _skin_review_note(e: TextEdit, stage: String) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if stage == "rough":
		sb.bg_color = Color("ffe08a")
		sb.border_color = Color("8b1e1e")
		sb.set_border_width_all(4)
		e.add_theme_color_override("font_color", Color("6b1008"))
		e.add_theme_color_override("font_placeholder_color", Color("8b1e1e"))
		e.add_theme_font_size_override("font_size", 16)
		e.custom_minimum_size.y = 140
	else:
		sb.bg_color = Color("fffaf2")
		sb.border_color = Color("c4a574")
		sb.set_border_width_all(2)
		e.add_theme_color_override("font_color", Color("1c120c"))
		e.add_theme_color_override("font_placeholder_color", Color("8a6a3a"))
		e.add_theme_font_size_override("font_size", 14)
		e.custom_minimum_size.y = 80
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("focus", sb)
	e.add_theme_stylebox_override("read_only", sb)


func _add_line(host: Control, label: String, key: String, value: String, readonly: bool = false) -> void:
	if key == "_pad":
		host.add_child(Control.new())
		return
	var wrap := _cap(host, label)
	var e := LineEdit.new()
	e.text = value
	e.editable = not readonly
	e.focus_mode = Control.FOCUS_ALL
	if key == "atk_base" or key == "hp_base":
		e.placeholder_text = "type a number"
	elif key == "face_text":
		e.placeholder_text = "3 ATK"
	_skin_edit(e)
	if not readonly:
		e.focus_entered.connect(func() -> void: e.call_deferred("select_all"))
	wrap.add_child(e)
	_fields[key] = e


func _add_pick(host: Control, label: String, key: String, value: String, opts: Array) -> void:
	var wrap := _cap(host, label)
	var e := OptionButton.new()
	e.add_theme_color_override("font_color", Color("1c120c"))
	var sel := 0
	for i in opts.size():
		var o: Variant = opts[i]
		var oid := ""
		var olabel := ""
		if typeof(o) == TYPE_DICTIONARY:
			oid = str((o as Dictionary).get("id", ""))
			olabel = str((o as Dictionary).get("label", oid))
		else:
			oid = str(o)
			olabel = str(o)
		e.add_item(olabel, i)
		e.set_item_metadata(i, oid)
		if oid == value or olabel == value:
			sel = i
	e.select(sel)
	wrap.add_child(e)
	_fields[key] = e


func _add_color_pick(host: Control, label: String, key: String, value: String) -> void:
	_add_pick(host, label, key, value, UX.card_color_opts())
	var e: OptionButton = _fields[key]
	UX.paint_color_pick(e)
	e.item_selected.connect(func(_i: int) -> void: UX.paint_color_pick(e))


func _add_area(host: Control, label: String, key: String, value: String, h: float, mono: bool) -> void:
	var wrap := _cap(host, label)
	var e := TextEdit.new()
	e.text = value
	e.custom_minimum_size = Vector2(0, h)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	if mono:
		e.add_theme_font_size_override("font_size", 13)
	_skin_edit(e)
	wrap.add_child(e)
	_fields[key] = e


func _add_painted_line(host: Control, label: String, key: String, value: String) -> void:
	var wrap := _cap(host, label)
	var e := LineEdit.new()
	e.text = value
	e.focus_mode = Control.FOCUS_ALL
	_skin_edit(e)
	wrap.add_child(e)
	_fields[key] = e
	var preview := _paint_preview(wrap)
	e.text_changed.connect(func(t: String) -> void: _set_paint_preview(preview, t))
	_set_paint_preview(preview, value)


func _add_painted_area(host: Control, label: String, key: String, value: String, h: float) -> void:
	var wrap := _cap(host, label)
	var e := TextEdit.new()
	e.text = value
	e.custom_minimum_size = Vector2(0, h)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	_skin_edit(e)
	wrap.add_child(e)
	_fields[key] = e
	var preview := _paint_preview(wrap)
	e.text_changed.connect(func() -> void: _set_paint_preview(preview, e.text))
	_set_paint_preview(preview, value)


func _paint_preview(host: Control) -> RichTextLabel:
	var p := RichTextLabel.new()
	p.bbcode_enabled = true
	p.fit_content = true
	p.scroll_active = false
	p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.add_theme_font_size_override("normal_font_size", 14)
	p.add_theme_font_size_override("bold_font_size", 14)
	p.add_theme_constant_override("line_separation", 3)
	p.add_theme_color_override("default_color", Color("f0e6d8"))
	p.custom_minimum_size = Vector2(0, 28)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	p.add_theme_stylebox_override("normal", sb)
	host.add_child(p)
	return p


func _set_paint_preview(p: RichTextLabel, raw: String) -> void:
	var t: String = raw.strip_edges()
	if t == "":
		p.text = "[i]blank[/i]"
		return
	p.text = UX.paint(t, true)


func _num_s(v: Variant) -> String:
	if v == null:
		return ""
	if typeof(v) == TYPE_FLOAT:
		return str(int(v))
	return str(v)


func _text_of(key: String) -> String:
	var n: Variant = _fields.get(key, null)
	if n is LineEdit:
		return (n as LineEdit).text.strip_edges()
	if n is TextEdit:
		return (n as TextEdit).text
	if n is OptionButton:
		var ob: OptionButton = n
		if ob.selected < 0:
			return ""
		var md: Variant = ob.get_item_metadata(ob.selected)
		if md != null and str(md) != "":
			return str(md)
		return ob.get_item_text(ob.selected)
	return ""


func _int_of(key: String, fallback: int) -> int:
	var s: String = _text_of(key)
	if s == "":
		return fallback
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return int(float(s))
	return fallback


func _null_or_int(key: String) -> Variant:
	var s: String = _text_of(key)
	if s == "":
		return null
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return int(float(s))
	return null


func _gather() -> Dictionary:
	var ops: Variant = _original.get("ops", {})
	var ops_raw: String = _text_of("ops_text")
	var parsed: Variant = JSON.parse_string(ops_raw if ops_raw != "" else "{}")
	if typeof(parsed) == TYPE_DICTIONARY:
		ops = parsed
	elif typeof(parsed) == TYPE_ARRAY:
		ops = parsed
	else:
		_status.text = "Ops JSON did not parse — fix the braces, then Save."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return {}
	var card := {
		"id": _id,
		"name": _text_of("name"),
		"kind": _kind,
		"status": _text_of("status"),
		"rarity": _text_of("rarity"),
		"tier": _int_of("tier", 1),
		"count": _int_of("count", 1),
		"priority": _int_of("priority", 3),
		"atk_base": _null_or_int("atk_base") if _fields.has("atk_base") else _original.get("atk_base", null),
		"hp_base": _null_or_int("hp_base") if _fields.has("hp_base") else _original.get("hp_base", null),
		"atk_formula": _text_of("atk_formula") if _fields.has("atk_formula") else str(_original.get("atk_formula", "")),
		"hp_formula": _text_of("hp_formula") if _fields.has("hp_formula") else str(_original.get("hp_formula", "")),
		"ability": _text_of("ability"),
		"explainer": _text_of("explainer") if _fields.has("explainer") else str(_original.get("explainer", "")),
		"flow": _text_of("flow"),
		"notes": _text_of("notes"),
		"review": _text_of("review") if _fields.has("review") else REVIEW_STAGE.of_card(_original),
		"review_note": _text_of("review_note") if _fields.has("review_note") else str(_original.get("review_note", "")),
		"ops": ops,
		"contradiction_ids": _original.get("contradiction_ids", []),
	}
	if _kind != "monster":
		var tint: String = _text_of("card_color") if _fields.has("card_color") else str(_original.get("card_color", ""))
		card["card_color"] = "" if UX.card_color_id(tint) == "auto" else UX.card_color_id(tint)
		card["face_text"] = _text_of("face_text") if _fields.has("face_text") else str(_original.get("face_text", ""))
	if _kind == "monster":
		card["call_name"] = _text_of("call_name") if _fields.has("call_name") else str(_original.get("call_name", ""))
		card["reminder"] = _text_of("reminder") if _fields.has("reminder") else str(_original.get("reminder", ""))
	var logic_changed: bool = str(card["flow"]) != str(_original.get("flow", "")) \
		or str(card["notes"]) != str(_original.get("notes", "")) \
		or str(card["atk_formula"]) != str(_original.get("atk_formula", "")) \
		or str(card["hp_formula"]) != str(_original.get("hp_formula", ""))
	if logic_changed and str(card["status"]) == "live":
		card["status"] = "todo"
	AUTHOR_LOCK.stamp_card(card, _original, false)
	return card


func _on_save() -> void:
	var card: Dictionary = _gather()
	if card.is_empty():
		return
	_load_board()
	var key: String = "monsters" if _kind == "monster" else "items"
	var arr: Array = _board.get(key, [])
	var found := false
	for i in arr.size():
		if str(arr[i].get("id", "")) == _id:
			arr[i] = card
			found = true
			break
	if not found:
		arr.append(card)
	_board[key] = arr
	_board["updated"] = Time.get_date_string_from_system()
	_board["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
	var path: String = ProjectSettings.globalize_path(BOARD_PATH)
	if not AUTHOR_LOCK.write_json(BOARD_PATH, _board):
		_status.text = "Could not write %s (error %s)." % [path, FileAccess.get_open_error()]
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return
	AUTHOR_LOCK.rebuild_ledger(_board, null)
	_status.text = "Saved and locked · %s" % path
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	saved.emit(_kind, _id, card)
	close_editor()


func _btn(text: String, fill: Color, rim: Color, cb: Callable, width: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 40)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = rim
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate()
	(h as StyleBoxFlat).bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var k: InputEventKey = event
	if k.keycode == KEY_ESCAPE:
		close_editor()
		get_viewport().set_input_as_handled()
		return
	if k.ctrl_pressed and k.keycode == KEY_S:
		_on_save()
		get_viewport().set_input_as_handled()
		return
	if k.shift_pressed or k.ctrl_pressed or k.alt_pressed or k.meta_pressed:
		return
	if k.keycode == KEY_ENTER or k.keycode == KEY_KP_ENTER:
		_on_save()
		get_viewport().set_input_as_handled()
