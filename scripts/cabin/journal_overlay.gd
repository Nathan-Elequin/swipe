extends Control
## Bestiary / Curiosities / Will. Never prints the word Tier.

signal closed
signal replay_intro

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0

var cabin
var extra: Dictionary = {}
var lore: Dictionary = {}
var catalog: Dictionary = {}
var art
var tab: String = "bestiary"
var page: int = 0
var _book: TextureRect
var _left_name
var _left_grade
var _left_ability
var _portrait: TextureRect
var _right: RichTextLabel
var _footer
var _replay: Button
var _scribble: TextureRect
var _cover: TextureRect
var _wells: Array = []
var _item_grid: Control
var _turn_l: ColorRect
var _turn_r: ColorRect


func setup(p_cabin, p_extra: Dictionary, p_lore: Dictionary, p_catalog: Dictionary, p_art) -> void:
	cabin = p_cabin
	extra = p_extra
	lore = p_lore
	catalog = p_catalog
	art = p_art
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var v := KIT.veil()
	v.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			close()
	)
	add_child(v)
	var origin: Array = extra.get("overlay_origins", {}).get("overlays/journal_spread.png", [20, 10])
	_book = KIT.tex_rect("overlays/journal_spread.png", Vector2(float(origin[0]), float(origin[1])), Vector2(380, 240), 0)
	_book.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_book)
	_cover = KIT.tex_rect("overlays/journal_cover.png", Vector2(float(origin[0]), float(origin[1])), Vector2(380, 240), 1)
	_cover.visible = KIT.load_tex("overlays/journal_cover.png") != null
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cover)
	var tabs: Dictionary = extra.get("journal_tabs", {})
	var tab_ids := ["bestiary", "items", "will"]
	var tab_keys := ["bestiary", "items", "memories"]
	for i in tab_ids.size():
		var t: String = str(tab_ids[i])
		var pos: Array = tabs.get(t, [366, 30 + i * 32])
		var b := TextureButton.new()
		b.texture_normal = KIT.load_tex("overlays/journal_tab_%s.png" % t)
		b.texture_hover = KIT.load_tex("overlays/journal_tab_%s_hover.png" % t)
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP
		b.position = _book.position + Vector2(float(pos[0]) - 8.0, float(pos[1])) * PX
		b.size = Vector2(40, 40) * PX
		b.z_index = 3
		var tt: String = str(tab_keys[i])
		b.pressed.connect(func() -> void:
			tab = tt
			page = 0
			_refresh()
		)
		b.mouse_entered.connect(func() -> void:
			if cabin:
				cabin.show_hover_tag("journal.tab.%s" % tt, b, {})
		)
		b.mouse_exited.connect(func() -> void:
			if cabin:
				cabin.hide_hover_tag()
		)
		add_child(b)
	var lp: Array = extra.get("journal_pages", {}).get("left", [22, 18, 166, 204])
	var rp: Array = extra.get("journal_pages", {}).get("right", [196, 18, 166, 204])
	var port: Array = extra.get("journal_portrait", [62, 34, 64, 64])
	_portrait = TextureRect.new()
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.position = _book.position + Vector2(float(port[0]), float(port[1])) * PX
	_portrait.size = Vector2(float(port[2]), float(port[3])) * PX
	add_child(_portrait)
	_left_name = KIT.raw_label("", 26, KIT.INK)
	_left_name.position = Vector2(_portrait.position.x - 48.0, _portrait.position.y + _portrait.size.y + 8.0)
	_left_name.size = Vector2(float(lp[2]), 22) * PX
	_left_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_left_name)
	_left_grade = KIT.raw_label("", 18, KIT.MUTED_INK)
	_left_grade.position = _left_name.position + Vector2(0, 28)
	_left_grade.size = _left_name.size
	_left_grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_left_grade)
	_left_ability = KIT.raw_label("", 16, KIT.MUTED_INK)
	_left_ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_left_ability.position = _left_grade.position + Vector2(0, 24)
	_left_ability.size = Vector2(float(lp[2]), 40) * PX
	add_child(_left_ability)
	_right = RichTextLabel.new()
	_right.fit_content = false
	_right.scroll_active = true
	_right.position = _book.position + Vector2(float(rp[0]), float(rp[1])) * PX
	_right.size = Vector2(float(rp[2]), float(rp[3])) * PX
	_right.add_theme_font_size_override("normal_font_size", 20)
	_right.add_theme_color_override("default_color", KIT.INK)
	add_child(_right)
	_scribble = TextureRect.new()
	_scribble.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_scribble.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_scribble.stretch_mode = TextureRect.STRETCH_KEEP
	_scribble.texture = KIT.load_tex("overlays/journal_scribble.png")
	_scribble.position = _right.position
	_scribble.size = Vector2(166, 80) * PX
	_scribble.visible = false
	_scribble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_scribble)
	_item_grid = Control.new()
	_item_grid.position = _book.position + Vector2(22, 18) * PX
	_item_grid.size = Vector2(340, 204) * PX
	_item_grid.visible = false
	_item_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_item_grid)
	for w in 2:
		var well := TextureRect.new()
		well.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		well.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		well.texture = KIT.load_tex("overlays/journal_photo_tape_%s.png" % ("a" if w == 0 else "b"))
		well.position = _book.position + Vector2(48.0 + float(w) * 130.0, 48.0) * PX
		well.size = Vector2(120, 72) * PX
		well.visible = false
		well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(well)
		_wells.append(well)
	_turn_l = ColorRect.new()
	_turn_l.color = Color("e8c36a33")
	_turn_l.position = _book.position
	_turn_l.size = Vector2(_book.size.x * 0.22, _book.size.y)
	_turn_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn_l.z_index = 1
	add_child(_turn_l)
	_turn_r = ColorRect.new()
	_turn_r.color = Color("e8c36a33")
	_turn_r.position = Vector2(_book.position.x + _book.size.x * 0.55, _book.position.y)
	_turn_r.size = Vector2(_book.size.x * 0.45, _book.size.y)
	_turn_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn_r.z_index = 1
	add_child(_turn_r)
	_footer = KIT.raw_label("", 16, KIT.MUTED)
	_footer.position = Vector2(80, 232 * PX)
	_footer.size = Vector2(1520, 28)
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_footer)
	_replay = KIT.choice_tag("journal.will.replay", Vector2(120, 16))
	_replay.position = _book.position + Vector2(48, 140) * PX
	_replay.z_index = 2
	_replay.visible = false
	_replay.pressed.connect(func() -> void:
		close()
		replay_intro.emit()
	)
	add_child(_replay)
	var close_b: Button = KIT.choice_tag("journal.close", Vector2(80, 16))
	close_b.position = KIT.pt(170, 232)
	close_b.z_index = 2
	close_b.pressed.connect(close)
	add_child(close_b)
	_book.gui_input.connect(_on_book)


func open_journal(start_tab: String = "bestiary") -> void:
	tab = start_tab
	page = 0
	visible = true
	KIT.cue(cabin.sfx if cabin else null, &"cabin.book_open")
	_refresh()


func close() -> void:
	if not visible:
		return
	KIT.cue(cabin.sfx if cabin else null, &"cabin.book_close")
	visible = false
	closed.emit()


func _ids(kind: String) -> Array:
	if kind == "bestiary":
		return catalog.get("monsters", []) if typeof(catalog.get("monsters", [])) == TYPE_ARRAY else []
	var out: Array = []
	for it in catalog.get("items", []):
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("status", "live")) != "live":
			continue
		if int(it.get("bucket", 0)) == -1:
			continue
		out.append(it)
	return out


func _refresh() -> void:
	if _cover:
		_cover.visible = false
	if _item_grid:
		_item_grid.visible = false
		for c in _item_grid.get_children():
			c.queue_free()
	for well in _wells:
		well.visible = tab == "memories"
	if _scribble:
		_scribble.visible = false
	_replay.visible = tab == "memories"
	_portrait.visible = tab == "bestiary"
	_left_name.visible = tab != "items"
	_left_grade.visible = tab == "bestiary"
	_left_ability.visible = false
	_right.visible = tab == "bestiary"
	if tab == "memories":
		_left_name.text = ""
		_left_grade.text = ""
		_left_ability.text = ""
		_right.text = ""
		_footer.text = KIT.copy_text("journal.tab.memories")
		return
	var rows: Array = _ids("bestiary" if tab == "bestiary" else "items")
	if rows.is_empty():
		return
	if tab == "bestiary":
		page = clampi(page, 0, rows.size() - 1)
		var row: Dictionary = rows[page] if typeof(rows[page]) == TYPE_DICTIONARY else {}
		var id: String = str(row.get("id", ""))
		var met: bool = cabin != null and bool(cabin.met_monsters.get(id, false))
		if cabin:
			cabin.mark_bestiary_read(id)
		var shown: String = str(row.get("call_name", "")).strip_edges()
		if shown == "":
			shown = str(row.get("name", id))
		_left_name.text = shown if met else ""
		_left_grade.text = ""
		_left_ability.text = ""
		var entry: Dictionary = lore.get("monsters", {}).get(id, {})
		_right.bbcode_enabled = true
		_right.text = "[i]%s[/i]" % KIT.named(str(entry.get("entry", ""))) if met else ""
		_right.visible = met and _right.text != ""
		if _scribble:
			_scribble.visible = not met and _scribble.texture != null
		if art and art.has_method("monster_still"):
			_portrait.texture = art.monster_still(id)
		_portrait.modulate = Color.WHITE if met else Color("100e0c")
		var n: int = cabin.met_monsters.size() if cabin else 0
		_footer.text = KIT.fill_text("journal.met_count", {"n": n, "total": rows.size()})
		_footer.text += "  " + KIT.fill_text("journal.page", {"n": page + 1, "total": rows.size()})
		return
	var per := 6
	var pages: int = maxi(1, int(ceil(float(rows.size()) / float(per))))
	page = clampi(page, 0, pages - 1)
	_item_grid.visible = true
	var start: int = page * per
	for i in per:
		var idx: int = start + i
		if idx >= rows.size():
			break
		var it: Dictionary = rows[idx] if typeof(rows[idx]) == TYPE_DICTIONARY else {}
		var iid: String = str(it.get("id", ""))
		var seen: bool = cabin != null and (bool(cabin.seen.get(iid, false)) or cabin.is_swiped(iid))
		var cell := TextureRect.new()
		cell.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cell.size = Vector2(48, 48) * PX
		cell.position = Vector2(float(i % 3) * 56.0, float(int(i / 3)) * 64.0) * PX
		if art and art.has_method("item_tex"):
			cell.texture = art.item_tex(iid)
		cell.modulate = Color.WHITE if seen else Color("100e0c")
		_item_grid.add_child(cell)
		if seen:
			var lab = KIT.raw_label(str(it.get("name", iid)), 14, KIT.INK)
			lab.position = cell.position + Vector2(0, 50) * PX
			lab.size = Vector2(48, 12) * PX
			lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_item_grid.add_child(lab)
	if cabin:
		var p: Vector2i = cabin.cabinet_progress()
		_footer.text = KIT.fill_text("cabin.hall.gauge", {"n": p.x, "total": p.y})
	_footer.text += "  " + KIT.fill_text("journal.page", {"n": page + 1, "total": pages})


func _on_book(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			_turn(-1)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_turn(1)
		elif ev.button_index == MOUSE_BUTTON_LEFT:
			var local: Vector2 = ev.position - _book.position
			if local.x > _book.size.x * 0.55:
				_turn(1)
			elif local.x < _book.size.x * 0.2:
				_turn(-1)


func _turn(delta: int) -> void:
	if tab == "memories":
		return
	page += delta
	KIT.cue(cabin.sfx if cabin else null, &"cabin.page_flip")
	_refresh()


func handle_page(delta: int) -> bool:
	if not visible or tab == "memories":
		return false
	_turn(delta)
	return true
