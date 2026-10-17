extends Control
## Bestiary / Curiosities / Will. Never prints the word Tier.

signal closed
signal replay_intro

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0
const GRADE := {1: "journal.weak", 2: "journal.tough", 3: "journal.deadly"}

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
	var tabs: Dictionary = extra.get("journal_tabs", {})
	for t in ["bestiary", "items", "will"]:
		var pos: Array = tabs.get(t, [366, 30])
		var b := TextureButton.new()
		b.texture_normal = KIT.load_tex("overlays/journal_tab_%s.png" % t)
		b.texture_hover = KIT.load_tex("overlays/journal_tab_%s_hover.png" % t)
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP
		b.position = _book.position + Vector2(float(pos[0]), float(pos[1])) * PX
		b.size = Vector2(28, 28) * PX
		b.z_index = 2
		var tt: String = t
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
	_left_name.position = _book.position + Vector2(float(lp[0]), float(lp[1]) + 70.0) * PX
	_left_name.size = Vector2(float(lp[2]), 20) * PX
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
	_footer = KIT.raw_label("", 16, KIT.MUTED)
	_footer.position = Vector2(80, 232 * PX)
	_footer.size = Vector2(1520, 28)
	_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_footer)
	_replay = KIT.choice_tag("journal.will.replay", Vector2(92, 16))
	_replay.position = _book.position + Vector2(48, 110) * PX
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
	_replay.visible = tab == "will"
	if tab == "will":
		_portrait.texture = KIT.load_tex("props/portrait_big.png")
		_portrait.modulate = Color.WHITE
		_left_name.text = KIT.copy_text("will.title")
		_left_grade.text = ""
		_left_ability.text = ""
		_right.text = "\n\n".join([
			KIT.copy_text("will.p1"),
			KIT.copy_text("will.p2"),
			KIT.copy_text("will.p3"),
			KIT.copy_text("will.p4"),
			KIT.copy_text("will.p5"),
			KIT.copy_text("will.sign"),
			KIT.copy_text("will.witness"),
		])
		_footer.text = KIT.copy_text("journal.tab.will")
		return
	var rows: Array = _ids(tab)
	if rows.is_empty():
		return
	page = clampi(page, 0, rows.size() - 1)
	var row: Dictionary = rows[page] if typeof(rows[page]) == TYPE_DICTIONARY else {}
	var id: String = str(row.get("id", ""))
	if tab == "bestiary":
		var met: bool = cabin != null and bool(cabin.met_monsters.get(id, false))
		if cabin:
			cabin.mark_bestiary_read(id)
		_left_name.text = str(row.get("name", id)) if met else KIT.copy_text("journal.unmet")
		var tier: int = clampi(int(row.get("tier", 1)), 1, 3)
		_left_grade.text = KIT.copy_text(str(GRADE.get(tier, "journal.weak"))) if met else ""
		_left_ability.text = KIT.named(str(row.get("ability", ""))) if met else ""
		var entry: Dictionary = lore.get("monsters", {}).get(id, {})
		var hint: String = KIT.copy_text("journal.unmet_hint")
		_right.text = KIT.named(str(entry.get("entry", ""))) if met else hint
		_right.visible = _right.text != ""
		if art and art.has_method("monster_still"):
			_portrait.texture = art.monster_still(id)
		_portrait.modulate = Color.WHITE if met else Color("100e0c")
		var n: int = cabin.met_monsters.size() if cabin else 0
		_footer.text = KIT.fill_text("journal.met_count", {"n": n, "total": rows.size()})
		_footer.text += "  " + KIT.fill_text("journal.page", {"n": page + 1, "total": rows.size()})
	else:
		var swiped: bool = cabin != null and cabin.is_swiped(id)
		var seen: bool = cabin != null and bool(cabin.seen.get(id, false))
		_left_name.text = str(row.get("name", id)) if seen else ""
		_left_grade.text = ""
		_left_ability.text = KIT.named(str(row.get("ability", ""))) if seen else ""
		var item_lore: Dictionary = lore.get("items", {}).get(id, {})
		if swiped:
			var bits: PackedStringArray = PackedStringArray()
			bits.append(KIT.named(str(item_lore.get("journal", ""))))
			for fn in item_lore.get("footnotes", []):
				bits.append(KIT.named(str(fn)))
			_right.text = "\n".join(bits)
		elif seen:
			_right.text = KIT.copy_text("cabin.tip.seen")
		else:
			_left_name.text = ""
			_right.text = KIT.copy_text("cabin.tip.locked")
		if art and art.has_method("item_tex"):
			_portrait.texture = art.item_tex(id)
		_portrait.modulate = Color.WHITE if seen else Color("100e0c")
		if cabin:
			var p: Vector2i = cabin.cabinet_progress()
			_footer.text = KIT.fill_text("cabin.hall.gauge", {"n": p.x, "total": p.y})
		_footer.text += "  " + KIT.fill_text("journal.page", {"n": page + 1, "total": rows.size()})


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
	if tab == "will":
		return
	page += delta
	KIT.cue(cabin.sfx if cabin else null, &"cabin.page_flip")
	_refresh()


func handle_page(delta: int) -> bool:
	if not visible or tab == "will":
		return false
	_turn(delta)
	return true
