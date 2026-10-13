extends ColorRect
## Full-roster sheet. One grid for every item and monster. Tab through fields. Save writes the board.

signal committed(items: Array, monsters: Array)
signal closed
signal open_card(kind: String, card_id: String)
signal unlocks_reset

const BOARD_PATH := "res://data/content-board.json"
const RUNTIME_PATH := "res://data/runtime.json"
const CATALOG_PATH := "res://data/catalog.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")
const RECENT_EDITS := preload("res://scripts/recent_edits.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")

const LEGEND := "Attack and HP sit next to the name (orange / red). Copies and Priority are further right, grey, and are pool size / draw order — not combat stats. Headers stay lined up with the cells; scroll sideways if you need the later columns. Ctrl+F filter · Ctrl+S save · Ctrl+D duplicate · Esc discard."
const COL_SEP := 4
const STRIPE_W := 8.0
const ROW_H := 64.0
const HEAD_H := 44.0
const JUNK_TEXT := [
	"ATK", "HP", "blank = use ATK", "blank = use HP", "blank = us", "blank = use",
	"Type what to change. Save, then tell Cursor.", "Type what to change. Save, then",
	"copies in pool", "lower = sooner", "sentence the player reads", "hover / Shift math",
	"what the code should do", "chat only", "blank = use ATK", "1–3",
]

const GROUP_LABEL := {
	"identity": "",
	"combat": "ATTACK + HP  (the printed fight numbers)",
	"copy": "WHAT THE PLAYER READS",
	"review": "REVIEW",
	"meta": "",
	"pool": "POOL  (how many exist / draw order — not Attack, not HP)",
	"code": "FOR CODE",
}

const COL_ITEM := [
	{"key": "art", "label": "", "sub": "", "help": "Portrait. Click to select the row. Double-click opens the deep card sheet.", "w": 52.0, "kind": "art", "group": "identity"},
	{"key": "name", "label": "Name", "sub": "on the card", "help": "The name printed on the card.", "w": 140.0, "kind": "line", "group": "identity"},
	{"key": "ability", "label": "Player text", "sub": "sentence on the card", "help": "The sentence the player reads.", "w": 240.0, "kind": "area", "group": "copy"},
	{"key": "explainer", "label": "Hover math", "sub": "Shift / inspect", "help": "The short equation on hover and Shift.", "w": 180.0, "kind": "area", "group": "copy"},
	{"key": "card_color", "label": "Card color", "sub": "hand tint", "help": "atk / blk / heal / defeat / utility / chaos / smoke / egg, or blank for auto.", "w": 100.0, "kind": "line", "group": "copy"},
	{"key": "review", "label": "Review", "sub": "rough → finished", "help": "rough = first pass. refined = mechanics changed after your notes. polish = art, copy, dialogue. finished = done.", "w": 108.0, "kind": "pick", "opts": ["rough", "refined", "polish", "finished"], "group": "review"},
	{"key": "review_note", "label": "Your notes", "sub": "for Cursor", "help": "Type what to change. Save, then tell Cursor to read this box.", "w": 200.0, "kind": "area", "group": "review"},
	{"key": "status", "label": "Status", "sub": "live / todo / hold", "help": "live = in the dungeon. todo = needs a code pass. hold = skip. retired = hidden.", "w": 92.0, "kind": "pick", "opts": ["live", "todo", "hold", "retired"], "group": "meta"},
	{"key": "rarity", "label": "Rarity", "sub": "starter or mill", "help": "Left over from the old night-watch flag. The bucket decides which dungeon can deal this card.", "w": 100.0, "kind": "pick", "opts": ["starter", "uncommon"], "group": "meta"},
	{"key": "bucket", "label": "Bucket", "sub": "when it unlocks", "help": "0 is in the first dungeon. 1 opens after the first Adventure ending, 2 after the second, and so on. A clear or a death counts. Bucket 0 should be 9 items and 9 monsters. Each later bucket should be 3 and 3. Token is never drafted and never shown in an unlock.", "w": 108.0, "kind": "pick", "opts": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "Token"], "group": "meta"},
	{"key": "id", "label": "Id", "sub": "internal code", "help": "Internal code id. Change this only when adding a brand-new card.", "w": 118.0, "kind": "line", "group": "meta"},
	{"key": "tier", "label": "Tier", "sub": "1 bronze · 3 gold", "help": "1 bronze, 2 silver, 3 gold. A mill pack's relic and monster share this metal.", "w": 56.0, "kind": "line", "group": "pool"},
	{"key": "count", "label": "Copies", "sub": "× in the pool", "help": "How many of this card exist in the dungeon pool. Not attack.", "w": 80.0, "kind": "line", "group": "pool"},
	{"key": "priority", "label": "Draw order", "sub": "lower = sooner", "help": "Lower number is offered sooner. 1 first, 4 last. Not HP, not attack.", "w": 88.0, "kind": "line", "group": "pool"},
	{"key": "flow", "label": "How it works", "sub": "for the code", "help": "Implementer notes: what the code should do when this is used.", "w": 170.0, "kind": "area", "group": "code"},
	{"key": "notes", "label": "Dev notes", "sub": "chat only", "help": "Exceptions and reminders for chat. Not shown to the player.", "w": 140.0, "kind": "area", "group": "code"},
	{"key": "ops_text", "label": "Engine JSON", "sub": "n lives here", "help": "The rules the game actually runs.", "w": 170.0, "kind": "area", "group": "code"},
]

const COL_MONSTER := [
	{"key": "art", "label": "", "sub": "", "help": "Portrait. Click to select the row. Double-click opens the deep card sheet.", "w": 52.0, "kind": "art", "group": "identity"},
	{"key": "name", "label": "Name", "sub": "on the wheel", "help": "The name printed on the wheel.", "w": 140.0, "kind": "line", "group": "identity"},
	{"key": "atk_base", "label": "Attack", "sub": "printed ATK", "help": "The Attack number in play, unless Attack formula is filled.", "w": 78.0, "kind": "line", "group": "combat"},
	{"key": "hp_base", "label": "HP", "sub": "printed hits", "help": "The HP number in play, unless HP formula is filled.", "w": 78.0, "kind": "line", "group": "combat"},
	{"key": "atk_formula", "label": "Attack formula", "sub": "leave empty if fixed", "help": "If this has text, play uses it instead of the Attack number.", "w": 150.0, "kind": "line", "group": "combat"},
	{"key": "hp_formula", "label": "HP formula", "sub": "leave empty if fixed", "help": "If this has text, play uses it instead of the HP number.", "w": 150.0, "kind": "line", "group": "combat"},
	{"key": "ability", "label": "Player text", "sub": "what they say", "help": "First-person line the monster says.", "w": 220.0, "kind": "area", "group": "copy"},
	{"key": "explainer", "label": "Hover math", "sub": "inspect plate", "help": "The short reminder on the inspect plate.", "w": 160.0, "kind": "area", "group": "copy"},
	{"key": "call_name", "label": "Call name", "sub": "under the title", "help": "Short name under the monster title.", "w": 140.0, "kind": "line", "group": "copy"},
	{"key": "reminder", "label": "Shift line", "sub": "hold Shift", "help": "Replaces the call name while you hold Shift.", "w": 160.0, "kind": "area", "group": "copy"},
	{"key": "review", "label": "Review", "sub": "rough → finished", "help": "rough = first pass. refined = mechanics changed after your notes. polish = art, copy, dialogue. finished = done.", "w": 108.0, "kind": "pick", "opts": ["rough", "refined", "polish", "finished"], "group": "review"},
	{"key": "review_note", "label": "Your notes", "sub": "for Cursor", "help": "Type what to change. Save, then tell Cursor to read this box.", "w": 200.0, "kind": "area", "group": "review"},
	{"key": "status", "label": "Status", "sub": "live / todo / hold", "help": "live = in the dungeon. todo = needs a code pass. hold = skip. retired = hidden.", "w": 92.0, "kind": "pick", "opts": ["live", "todo", "hold", "retired"], "group": "meta"},
	{"key": "rarity", "label": "Rarity", "sub": "starter or mill", "help": "Left over from the old night-watch flag. The bucket decides which dungeon can deal this card.", "w": 100.0, "kind": "pick", "opts": ["starter", "uncommon"], "group": "meta"},
	{"key": "bucket", "label": "Bucket", "sub": "when it unlocks", "help": "0 is in the first dungeon. 1 opens after the first Adventure ending, 2 after the second, and so on. A clear or a death counts. Bucket 0 should be 9 items and 9 monsters. Each later bucket should be 3 and 3. Token is never drafted and never shown in an unlock.", "w": 108.0, "kind": "pick", "opts": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "Token"], "group": "meta"},
	{"key": "id", "label": "Id", "sub": "internal code", "help": "Internal code id. Change this only when adding a brand-new card.", "w": 118.0, "kind": "line", "group": "meta"},
	{"key": "tier", "label": "Tier", "sub": "1 bronze · 3 gold", "help": "1 bronze, 2 silver, 3 gold. Matches the relic in its mill pack.", "w": 56.0, "kind": "line", "group": "pool"},
	{"key": "count", "label": "Copies", "sub": "× in the pool", "help": "How many of this monster exist in the pool. Not Attack.", "w": 80.0, "kind": "line", "group": "pool"},
	{"key": "priority", "label": "Draw order", "sub": "lower = sooner", "help": "Lower number is drawn sooner. Not HP, not Attack.", "w": 88.0, "kind": "line", "group": "pool"},
	{"key": "flow", "label": "How it works", "sub": "for the code", "help": "Implementer notes for the special rule.", "w": 170.0, "kind": "area", "group": "code"},
	{"key": "notes", "label": "Dev notes", "sub": "chat only", "help": "Exceptions for chat. Not shown to the player.", "w": 140.0, "kind": "area", "group": "code"},
]

var art
var sfx
var _kind: String = "item"
var _board: Dictionary = {}
var _runtime: Dictionary = {}
var _catalog: Dictionary = {}
var _rows: Array = []
var _focusables: Array = []
var _dirty: bool = false
var _hide_retired: bool = true
var _filter: String = ""
var _review_filter: String = ""
var _review_chips: Dictionary = {}
var _was_paused: bool = false
var _status: Label
var _bucket_warn: Label
var _bucket_panel: Control
var _bucket_body: VBoxContainer
var _search: LineEdit
var _tab_items: Button
var _tab_mons: Button
var _hide_btn: Button
var _header: HBoxContainer
var _groups: HBoxContainer
var _list: VBoxContainer
var _scroll: ScrollContainer
var _header_scroll: ScrollContainer
var _sheet: VBoxContainer
var _hint: Label
var _esc_armed: bool = false
var _focused_row: HBoxContainer = null
var _dup_btn: Button
var _shown_n: int = 0
var _total_n: int = 0


func setup(p_art, p_sfx) -> void:
	art = p_art
	sfx = p_sfx
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	color = Color("1a1410")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	resized.connect(_fit_to_viewport)
	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	title.text = "Roster"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("1c120c"))
	head.add_child(title)
	_tab_items = _chip("Items", true)
	_tab_mons = _chip("Monsters", false)
	_tab_items.pressed.connect(func() -> void: _set_kind("item"))
	_tab_mons.pressed.connect(func() -> void: _set_kind("monster"))
	head.add_child(_tab_items)
	head.add_child(_tab_mons)
	_search = LineEdit.new()
	_search.placeholder_text = "Ctrl+F · filter name, id, or text"
	_search.custom_minimum_size = Vector2(260, 36)
	_skin_edit(_search)
	_search.text_changed.connect(_on_filter)
	head.add_child(_search)
	_hide_btn = _chip("Hide retired", true)
	_hide_btn.pressed.connect(_toggle_retired)
	head.add_child(_hide_btn)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(_btn("Add row", Color("2a3a22"), Color("8dcb8d"), _on_add, 110))
	_dup_btn = _btn("Duplicate", Color("3a3220"), Color("c4a574"), _on_duplicate, 120)
	head.add_child(_dup_btn)
	head.add_child(_btn("Reset unlocks", Color("3a2420"), Color("c47a5c"), _on_reset_unlocks, 140))
	head.add_child(_btn("Buckets", Color("2a3340"), Color("8eb4d4"), _toggle_buckets, 110))
	head.add_child(_btn("Save all", Color("3a2820"), Color("c4a574"), _on_save, 110))
	head.add_child(_btn("Close", Color("3a3220"), Color("9a8b78"), close_editor, 90))
	col.add_child(_build_review_bar())

	_hint = Label.new()
	_hint.text = LEGEND
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color("6b4a10"))
	col.add_child(_hint)

	_status = Label.new()
	_status.text = "…"
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	col.add_child(_status)
	_bucket_warn = Label.new()
	_bucket_warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bucket_warn.add_theme_font_size_override("font_size", 14)
	_bucket_warn.add_theme_color_override("font_color", Color("8b1e1e"))
	col.add_child(_bucket_warn)

	_header_scroll = ScrollContainer.new()
	_header_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_scroll.custom_minimum_size = Vector2(0, 70)
	_header_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_header_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_header_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	col.add_child(_header_scroll)
	var header_block := VBoxContainer.new()
	header_block.add_theme_constant_override("separation", 2)
	_header_scroll.add_child(header_block)
	_groups = HBoxContainer.new()
	_groups.add_theme_constant_override("separation", COL_SEP)
	header_block.add_child(_groups)
	_header = HBoxContainer.new()
	_header.add_theme_constant_override("separation", COL_SEP)
	header_block.add_child(_header)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size = Vector2(0, 420)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_skin_scroll(_scroll)
	col.add_child(_scroll)
	_sheet = VBoxContainer.new()
	_sheet.add_theme_constant_override("separation", 4)
	_scroll.add_child(_sheet)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 3)
	_sheet.add_child(_list)


func _fit_to_viewport() -> void:
	if not is_inside_tree():
		return
	var vp: Vector2 = get_viewport_rect().size
	if vp.x < 8.0 or vp.y < 8.0:
		return
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if size != vp:
		size = vp
	if global_position != Vector2.ZERO:
		global_position = Vector2.ZERO
	if visible and _header != null:
		_wire_h_scroll()


func open_roster() -> void:
	_fit_to_viewport()
	_load_board()
	_load_runtime()
	_load_catalog()
	_kind = "item"
	_filter = ""
	_review_filter = ""
	if _search:
		_search.text = ""
	_dirty = false
	_esc_armed = false
	if _bucket_panel:
		_bucket_panel.visible = false
	_rebuild()
	_was_paused = get_tree().paused
	visible = true
	get_tree().paused = true
	if sfx:
		sfx.play("book", -10.0)
		sfx.play("open", -14.0)
	_status.text = _chrome_text()
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	call_deferred("_fit_to_viewport")
	call_deferred("_focus_first")


func close_editor() -> void:
	if _dirty and not _esc_armed:
		_esc_armed = true
		_status.text = "Unsaved edits. Esc again to discard, or Ctrl+S to save."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		if sfx:
			sfx.play("question", -10.0)
		return
	_esc_armed = false
	visible = false
	get_tree().paused = false
	if sfx:
		sfx.play("door_close", -12.0)
	closed.emit()


func _cols() -> Array:
	return COL_MONSTER if _kind == "monster" else COL_ITEM


func _flush_visible(strict: bool = true) -> bool:
	if _rows.is_empty():
		return true
	var gathered: Array = []
	for row in _rows:
		var card: Dictionary = _gather_row(row, strict)
		if card.is_empty():
			return false
		gathered.append(card)
	var key: String = "monsters" if _kind == "monster" else "items"
	var by_id := {}
	for c in _board.get(key, []):
		by_id[str(c.get("id", ""))] = c
	for card2 in gathered:
		by_id[str(card2["id"])] = card2
	var merged: Array = []
	var seen := {}
	for id in _order_ids():
		var sid := str(id)
		if by_id.has(sid):
			merged.append(by_id[sid])
			seen[sid] = true
	for k in by_id.keys():
		if seen.has(str(k)):
			continue
		merged.append(by_id[k])
		seen[str(k)] = true
	_board[key] = merged
	return true


func _set_kind(kind: String) -> void:
	if _kind == kind:
		return
	if not _flush_visible(false):
		return
	if sfx:
		sfx.play("switch", -12.0)
	_kind = kind
	_rebuild()
	_status.text = _chrome_text()
	_status.add_theme_color_override("font_color", Color("3d6b3d"))


func _toggle_retired() -> void:
	if not _flush_visible(false):
		return
	_hide_retired = not _hide_retired
	_hide_btn.modulate = Color.WHITE if _hide_retired else Color(1, 1, 1, 0.45)
	if sfx:
		sfx.play("click2", -12.0)
	_rebuild()


func _on_filter(text: String) -> void:
	if not _flush_visible(false):
		return
	_filter = text.strip_edges().to_lower()
	_rebuild()


func _load_board() -> void:
	var f := FileAccess.open(BOARD_PATH, FileAccess.READ)
	if f == null:
		_board = {"id": "boss-rush-content-board", "updated": "", "monsters": [], "items": []}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	_board = parsed if typeof(parsed) == TYPE_DICTIONARY else {"id": "boss-rush-content-board", "monsters": [], "items": []}


func _load_runtime() -> void:
	var f := FileAccess.open(RUNTIME_PATH, FileAccess.READ)
	if f == null:
		_runtime = {"monsters": [], "items": []}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	_runtime = parsed if typeof(parsed) == TYPE_DICTIONARY else {"monsters": [], "items": []}


func _load_catalog() -> void:
	var f := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if f == null:
		_catalog = {"monsters": [], "items": []}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	_catalog = parsed if typeof(parsed) == TYPE_DICTIONARY else {"monsters": [], "items": []}


func _catalog_card(kind: String, card_id: String) -> Dictionary:
	var arr: Array = _catalog.get("monsters" if kind == "monster" else "items", [])
	for c in arr:
		if str(c.get("id", "")) == card_id:
			return c
	return {}


func _hydrate_bases(card: Dictionary) -> Dictionary:
	var out: Dictionary = card.duplicate(true)
	if str(out.get("kind", _kind)) != "monster" and _kind != "monster":
		return out
	var cat: Dictionary = _catalog_card("monster", str(out.get("id", "")))
	if cat.is_empty():
		return out
	var atk: Variant = cat.get("atk", {})
	var hp: Variant = cat.get("hp", {})
	var atk_d: Dictionary = atk if typeof(atk) == TYPE_DICTIONARY else {}
	var hp_d: Dictionary = hp if typeof(hp) == TYPE_DICTIONARY else {}
	if out.get("atk_base") == null and atk_d.has("base"):
		out["atk_base"] = atk_d.get("base")
	if out.get("hp_base") == null and hp_d.has("base"):
		out["hp_base"] = hp_d.get("base")
	if str(out.get("atk_formula", "")).strip_edges() == "" and str(atk_d.get("formula", "")) != "":
		out["atk_formula"] = str(atk_d.get("formula", ""))
	if str(out.get("hp_formula", "")).strip_edges() == "" and str(hp_d.get("formula", "")) != "":
		out["hp_formula"] = str(hp_d.get("formula", ""))
	return out


func _order_ids() -> Array:
	return _runtime.get("monsters" if _kind == "monster" else "items", [])


func _cards() -> Array:
	var raw: Array = _board.get("monsters" if _kind == "monster" else "items", [])
	var out: Array = []
	for c in raw:
		out.append(_hydrate_bases(c))
	out.sort_custom(_sort_card)
	return out


func _sort_card(a: Dictionary, b: Dictionary) -> bool:
	var ra: int = REVIEW_STAGE.rank(REVIEW_STAGE.of_card(a))
	var rb: int = REVIEW_STAGE.rank(REVIEW_STAGE.of_card(b))
	if ra != rb:
		return ra < rb
	if _kind == "monster":
		var ta: int = int(a.get("tier", 1))
		var tb: int = int(b.get("tier", 1))
		if ta != tb:
			return ta < tb
	else:
		var ia: String = REVIEW_STAGE.item_type(a)
		var ib: String = REVIEW_STAGE.item_type(b)
		if ia != ib:
			return ia < ib
	return str(a.get("name", "")).to_lower() < str(b.get("name", "")).to_lower()


func _live_cols() -> Array:
	var out: Array = []
	for spec in _cols():
		out.append((spec as Dictionary).duplicate(true))
	return out


func _grid_width(cols: Array) -> float:
	var w: float = STRIPE_W + float(COL_SEP) + STRIPE_W
	for spec in cols:
		w += float(COL_SEP) + float(spec["w"])
	return w


func _chrome_text() -> String:
	var kind_s: String = "Items" if _kind == "item" else "Monsters"
	var dirty_s: String = " · unsaved" if _dirty else ""
	return "%s · %s of %s shown%s. Orange Attack / red HP sit beside the name. Grey Copies is pool size." % [kind_s, _shown_n, _total_n, dirty_s]


func _rebuild() -> void:
	_rows.clear()
	_focusables.clear()
	_focused_row = null
	_shown_n = 0
	_total_n = 0
	for c in _header.get_children():
		_header.remove_child(c)
		c.queue_free()
	if _groups:
		for g in _groups.get_children():
			_groups.remove_child(g)
			g.queue_free()
	for c2 in _list.get_children():
		_list.remove_child(c2)
		c2.queue_free()
	var cols: Array = _live_cols()
	var grid_w: float = _grid_width(cols)
	_fill_group_row(cols)
	_header.custom_minimum_size = Vector2(grid_w, HEAD_H)
	_header.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_header.add_child(_stripe_spacer(HEAD_H))
	var lock_h := _stripe_spacer(HEAD_H)
	lock_h.tooltip_text = "Wine stripe = locked by your Save."
	_header.add_child(lock_h)
	for spec in cols:
		_header.add_child(_header_cell(spec))
	var q: String = _filter
	var zebra := 0
	for card in _cards():
		_total_n += 1
		if _hide_retired and str(card.get("status", "live")) == "retired":
			continue
		if _review_filter != "" and REVIEW_STAGE.of_card(card) != _review_filter:
			continue
		if q != "":
			var blob: String = ("%s %s %s %s" % [card.get("name", ""), card.get("id", ""), card.get("ability", ""), card.get("review_note", "")]).to_lower()
			if blob.find(q) < 0:
				continue
		_list.add_child(_make_row(card, cols, zebra, grid_w))
		zebra += 1
		_shown_n += 1
	_list.custom_minimum_size.x = grid_w
	_sheet.custom_minimum_size.x = grid_w
	var header_block: Node = _header.get_parent()
	if header_block is Control:
		(header_block as Control).custom_minimum_size.x = grid_w
	_wire_tabs()
	_wire_h_scroll()
	_tab_items.modulate = Color.WHITE if _kind == "item" else Color(1, 1, 1, 0.55)
	_tab_mons.modulate = Color.WHITE if _kind == "monster" else Color(1, 1, 1, 0.55)
	_hide_btn.modulate = Color.WHITE if _hide_retired else Color(1, 1, 1, 0.45)
	_sync_review_chips()
	_refresh_bucket_warn()
	if not _dirty:
		_status.text = _chrome_text()
		_status.add_theme_color_override("font_color", Color("3d6b3d"))
	_hint.text = LEGEND


func _stripe_spacer(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(STRIPE_W, h)
	c.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	c.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return c


func _lock_cell(inner: Control, w: float, h: float, key: String) -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(w, h)
	wrap.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	wrap.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	wrap.clip_contents = true
	wrap.set_meta("col_key", key)
	wrap.add_child(inner)
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return wrap


func _fill_group_row(cols: Array) -> void:
	if _groups == null:
		return
	_groups.custom_minimum_size = Vector2(_grid_width(cols), 22.0)
	_groups.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_groups.add_child(_stripe_spacer(22.0))
	_groups.add_child(_stripe_spacer(22.0))
	var i := 0
	while i < cols.size():
		var g: String = str((cols[i] as Dictionary).get("group", ""))
		var span_w: float = float((cols[i] as Dictionary)["w"])
		var j := i + 1
		while j < cols.size() and str((cols[j] as Dictionary).get("group", "")) == g:
			span_w += float(COL_SEP) + float((cols[j] as Dictionary)["w"])
			j += 1
		var lab := Label.new()
		lab.text = str(GROUP_LABEL.get(g, ""))
		lab.custom_minimum_size = Vector2(span_w, 22.0)
		lab.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		lab.add_theme_font_size_override("font_size", 11)
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		lab.clip_text = true
		match g:
			"combat":
				lab.add_theme_color_override("font_color", Color("6a1c14"))
				lab.add_theme_color_override("font_shadow_color", Color("f8e4d8"))
			"pool":
				lab.add_theme_color_override("font_color", Color("3a3834"))
			_:
				lab.add_theme_color_override("font_color", Color("6b4a10"))
		_groups.add_child(lab)
		i = j


func _header_cell(spec: Dictionary) -> Control:
	var key: String = str(spec["key"])
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(5)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	match key:
		"atk_base":
			sb.bg_color = Color("f8e4d8")
			sb.border_color = Color("e07040")
			sb.set_border_width_all(2)
		"hp_base":
			sb.bg_color = Color("f8e0e0")
			sb.border_color = Color("c4282a")
			sb.set_border_width_all(2)
		"count", "priority":
			sb.bg_color = Color("e8e4dc")
			sb.border_color = Color("a09888")
			sb.set_border_width_all(1)
		_:
			sb.bg_color = Color("efe6d4")
			sb.border_color = Color("c4a574")
			sb.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", sb)
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	wrap.tooltip_text = str(spec.get("help", ""))
	var title := Label.new()
	title.text = str(spec["label"])
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("6a1c14") if key == "atk_base" or key == "hp_base" else Color("1c120c"))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(title)
	var sub_s: String = str(spec.get("sub", ""))
	if sub_s != "" and str(spec["label"]) != "":
		var sub := Label.new()
		sub.text = sub_s
		sub.autowrap_mode = TextServer.AUTOWRAP_OFF
		sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		sub.add_theme_font_size_override("font_size", 10)
		sub.add_theme_color_override("font_color", Color("8a6a3a"))
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(sub)
	panel.add_child(wrap)
	return _lock_cell(panel, float(spec["w"]), HEAD_H, key)


func _wire_h_scroll() -> void:
	if _scroll == null or _header_scroll == null:
		return
	var bar: HScrollBar = _scroll.get_h_scroll_bar()
	if bar and not bar.value_changed.is_connected(_sync_header_h):
		bar.value_changed.connect(_sync_header_h)


func _sync_header_h(v: float) -> void:
	if _header_scroll:
		_header_scroll.scroll_horizontal = int(v)


func _make_row(card: Dictionary, cols: Array, zebra: int, grid_w: float) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", COL_SEP)
	row.custom_minimum_size = Vector2(grid_w, ROW_H)
	row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var fields := {}
	var tier_n: int = int(card.get("tier", 1))
	var stripe := ColorRect.new()
	stripe.custom_minimum_size = Vector2(STRIPE_W, ROW_H)
	stripe.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	stripe.color = Color("c08050") if tier_n <= 1 else (Color("8a96a8") if tier_n == 2 else Color("e8c36a"))
	row.add_child(stripe)
	var lock_mark := ColorRect.new()
	lock_mark.custom_minimum_size = Vector2(STRIPE_W, ROW_H)
	lock_mark.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	if bool(card.get("author_lock", false)):
		lock_mark.color = Color("6b1008")
		lock_mark.tooltip_text = "Locked by your last Save. Chat will not rewrite this card unless you override."
	else:
		lock_mark.color = Color(0, 0, 0, 0)
	row.add_child(lock_mark)
	row.set_meta("stripe", stripe)
	row.set_meta("zebra", zebra)
	row.set_meta("row_dirty", false)
	for spec in cols:
		var key: String = str(spec["key"])
		var w: float = float(spec["w"])
		var kind: String = str(spec["kind"])
		var help: String = str(spec.get("help", ""))
		if kind == "art":
			row.add_child(_lock_cell(_art_cell(card, w, row, help), w, ROW_H, key))
			continue
		if kind == "pick":
			var pick_v: String = str(card.get(key, ""))
			if key == "review":
				pick_v = REVIEW_STAGE.of_card(card)
			if key == "bucket":
				pick_v = BucketRules.label_of(card.get("bucket", 0))
			var pick := _pick_cell(pick_v, spec.get("opts", []), w, help, row)
			fields[key] = pick
			_focusables.append(pick)
			if key == "bucket":
				if pick_v == "":
					pick.select(0)
				BucketRules.paint(pick)
				pick.item_selected.connect(func(_i: int) -> void:
					BucketRules.paint(pick)
					_refresh_bucket_warn()
				)
			row.add_child(_lock_cell(pick, w, ROW_H, key))
			continue
		if kind == "area":
			var area := _area_cell(_field_value(card, key), w, help, row, key)
			fields[key] = area
			_focusables.append(area)
			row.add_child(_lock_cell(area, w, ROW_H, key))
			continue
		var line := _line_cell(_field_value(card, key), w, key, help, row)
		fields[key] = line
		_focusables.append(line)
		row.add_child(_lock_cell(line, w, ROW_H, key))
	row.set_meta("fields", fields)
	row.set_meta("kind", _kind)
	row.set_meta("orig_id", str(card.get("id", "")))
	row.set_meta("orig", card.duplicate(true))
	_style_review_row(row)
	if fields.has("review") and fields["review"] is OptionButton:
		(fields["review"] as OptionButton).item_selected.connect(func(_i: int) -> void: _style_review_row(row))
	row.mouse_entered.connect(func() -> void:
		if sfx:
			sfx.hover()
		if row != _focused_row:
			row.modulate = Color(1.04, 1.02, 0.96)
	)
	row.mouse_exited.connect(func() -> void: _refresh_row_look(row))
	_refresh_row_look(row)
	_rows.append(row)
	return row


func _field_value(card: Dictionary, key: String) -> String:
	if key == "ops_text":
		var ops_s: String = JSON.stringify(card.get("ops", {}), "")
		if ops_s == "null" or ops_s == "":
			return "{}"
		return ops_s
	var v: Variant = card.get(key, "")
	if v == null:
		return ""
	var s: String = str(int(v)) if typeof(v) == TYPE_FLOAT else str(v)
	return _sanitize_text(s, key)


func _art_cell(card: Dictionary, w: float, row: HBoxContainer, help: String) -> TextureRect:
	var pic := TextureRect.new()
	pic.custom_minimum_size = Vector2(w, 64)
	pic.texture_filter = TEXTURE_FILTER_NEAREST
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_STOP
	pic.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pic.tooltip_text = help
	var id: String = str(card.get("id", ""))
	if art != null:
		if _kind == "monster":
			pic.texture = art.monster_still(id)
		else:
			pic.texture = art.item_tex(id)
	pic.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_focus_row(row)
			_set_field_hint(help)
			if event.double_click:
				if sfx:
					sfx.play("book", -12.0)
				open_card.emit(_kind, id)
	)
	return pic


func _placeholder_for(key: String) -> String:
	match key:
		"count":
			return "× pool"
		"priority":
			return "draw #"
		"tier":
			return "1 / 2 / 3"
		"atk_base":
			return "—"
		"hp_base":
			return "—"
		"atk_formula":
			return "optional"
		"hp_formula":
			return "optional"
		"id":
			return "internal_id"
		"name":
			return "card name"
		"ability":
			return ""
		"explainer":
			return ""
		"flow":
			return ""
		"notes":
			return ""
		"review_note":
			return "notes for Cursor"
		"ops_text":
			return "{}"
		_:
			return ""


func _line_cell(value: String, w: float, key: String, help: String, row: HBoxContainer) -> LineEdit:
	var e := LineEdit.new()
	e.text = _sanitize_text(value, key)
	e.placeholder_text = _placeholder_for(key)
	e.custom_minimum_size = Vector2(0, 36)
	e.focus_mode = Control.FOCUS_ALL
	e.tooltip_text = help
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skin_edit(e)
	_tint_stat_cell(e, key)
	if key == "atk_base" or key == "hp_base":
		e.alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.add_theme_font_size_override("font_size", 20)
	elif key == "count" or key == "priority":
		e.alignment = HORIZONTAL_ALIGNMENT_CENTER
		e.add_theme_font_size_override("font_size", 13)
	e.text_changed.connect(_on_line_changed.bind(row))
	e.text_submitted.connect(func(_t: String) -> void: _focus_after(e))
	e.focus_entered.connect(_on_line_focus.bind(e, row, help))
	e.focus_exited.connect(_on_cell_blur)
	return e


func _area_cell(value: String, w: float, help: String, row: HBoxContainer, key: String = "") -> TextEdit:
	var e := TextEdit.new()
	e.text = _sanitize_text(value, key)
	e.placeholder_text = _placeholder_for(key)
	e.custom_minimum_size = Vector2(0, 36)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	e.focus_mode = Control.FOCUS_ALL
	e.tooltip_text = help
	_skin_edit(e)
	e.text_changed.connect(_mark_dirty.bind(row))
	e.focus_entered.connect(_on_cell_focus.bind(row, help))
	e.focus_exited.connect(_on_cell_blur)
	e.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
			if event.shift_pressed:
				_focus_before(e)
			else:
				_focus_after(e)
			e.accept_event()
	)
	return e


func _pick_cell(value: String, opts: Array, w: float, help: String, row: HBoxContainer) -> OptionButton:
	var e := OptionButton.new()
	e.custom_minimum_size = Vector2(0, 36)
	e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	e.focus_mode = Control.FOCUS_ALL
	e.tooltip_text = help
	_skin_pick(e)
	var sel := 0
	for i in opts.size():
		e.add_item(str(opts[i]), i)
		if str(opts[i]) == value:
			sel = i
	e.select(sel)
	e.item_selected.connect(func(_i: int) -> void: _mark_dirty(row))
	e.focus_entered.connect(_on_cell_focus.bind(row, help))
	e.focus_exited.connect(_on_cell_blur)
	return e


func _tint_stat_cell(e: LineEdit, key: String) -> void:
	var src: StyleBox = e.get_theme_stylebox("normal")
	var src_f: StyleBox = e.get_theme_stylebox("focus")
	if src == null or src_f == null:
		return
	var sb: StyleBoxFlat = src.duplicate() as StyleBoxFlat
	var focus: StyleBoxFlat = src_f.duplicate() as StyleBoxFlat
	if sb == null or focus == null:
		return
	match key:
		"atk_base":
			sb.bg_color = Color("f8e4d8")
			sb.border_color = Color("e07040")
			e.add_theme_color_override("font_color", Color("6a1c14"))
		"hp_base":
			sb.bg_color = Color("f8e0e0")
			sb.border_color = Color("c4282a")
			e.add_theme_color_override("font_color", Color("6b1008"))
		"count", "priority":
			sb.bg_color = Color("efe8dc")
			e.add_theme_color_override("font_color", Color("5a5048"))
		_:
			return
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("read_only", sb)
	e.add_theme_stylebox_override("focus", focus)


func _skin_edit(e: Control) -> void:
	e.add_theme_color_override("font_color", Color("1c120c"))
	e.add_theme_color_override("caret_color", Color("6b1008"))
	e.add_theme_color_override("selection_color", Color("e8c36a"))
	e.add_theme_color_override("font_selected_color", Color("1c120c"))
	e.add_theme_constant_override("caret_width", 3)
	if e is LineEdit or e is TextEdit:
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
	if e is LineEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("focus", focus)
		e.add_theme_stylebox_override("read_only", sb)
	elif e is TextEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("focus", focus)
		e.add_theme_stylebox_override("read_only", sb)


func _skin_pick(e: OptionButton) -> void:
	e.add_theme_color_override("font_color", Color("1c120c"))
	e.add_theme_color_override("font_hover_color", Color("1c120c"))
	e.add_theme_color_override("font_focus_color", Color("1c120c"))
	e.add_theme_color_override("font_pressed_color", Color("1c120c"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fffaf2")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(5)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color("f0e6d8")
	var focus := sb.duplicate() as StyleBoxFlat
	focus.border_color = Color("6b1008")
	focus.set_border_width_all(3)
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("hover", hover)
	e.add_theme_stylebox_override("pressed", hover)
	e.add_theme_stylebox_override("focus", focus)


func _skin_scroll(s: ScrollContainer) -> void:
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color("8a6a3a")
	grab.set_corner_radius_all(5)
	grab.content_margin_left = 3
	grab.content_margin_right = 3
	var hi := grab.duplicate() as StyleBoxFlat
	hi.bg_color = Color("c4a574")
	var track := StyleBoxFlat.new()
	track.bg_color = Color("d4c4a8")
	track.set_corner_radius_all(5)
	var bar: VScrollBar = s.get_v_scroll_bar()
	bar.custom_minimum_size.x = 14
	bar.add_theme_stylebox_override("grabber", grab)
	bar.add_theme_stylebox_override("grabber_highlight", hi)
	bar.add_theme_stylebox_override("grabber_pressed", hi)
	bar.add_theme_stylebox_override("scroll", track)
	var hbar: HScrollBar = s.get_h_scroll_bar()
	hbar.custom_minimum_size.y = 14
	hbar.add_theme_stylebox_override("grabber", grab)
	hbar.add_theme_stylebox_override("grabber_highlight", hi)
	hbar.add_theme_stylebox_override("grabber_pressed", hi)
	hbar.add_theme_stylebox_override("scroll", track)


func _on_line_changed(_t: String, row: HBoxContainer) -> void:
	_mark_dirty(row)


func _on_line_focus(e: LineEdit, row: HBoxContainer, help: String) -> void:
	_on_cell_focus(row, help)
	e.call_deferred("select_all")


func _on_cell_focus(row: HBoxContainer, help: String) -> void:
	if sfx:
		sfx.play("click2", -18.0, 1.1)
	_focus_row(row)
	_set_field_hint(help)


func _on_cell_blur() -> void:
	_set_field_hint("")


func _set_field_hint(help: String) -> void:
	if _hint == null:
		return
	_hint.text = LEGEND if help == "" else help


func _focus_row(row: HBoxContainer) -> void:
	var prev: HBoxContainer = _focused_row
	_focused_row = row
	if prev != null and is_instance_valid(prev) and prev != row:
		_refresh_row_look(prev)
	_refresh_row_look(row)


func _refresh_row_look(row: HBoxContainer) -> void:
	if row == null or not is_instance_valid(row):
		return
	var zebra: int = int(row.get_meta("zebra", 0))
	var dirty: bool = bool(row.get_meta("row_dirty", false))
	if row == _focused_row:
		row.modulate = Color(1.08, 1.04, 0.88)
	elif dirty:
		row.modulate = Color(1.05, 0.98, 0.90)
	elif zebra % 2 == 1:
		row.modulate = Color(0.96, 0.92, 0.84)
	else:
		row.modulate = Color.WHITE


func _wire_tabs() -> void:
	var chain: Array = []
	if _search:
		chain.append(_search)
	for node in _focusables:
		chain.append(node)
	if chain.is_empty():
		return
	for i in chain.size():
		var cur: Control = chain[i]
		var nxt: Control = chain[(i + 1) % chain.size()]
		var prv: Control = chain[(i - 1 + chain.size()) % chain.size()]
		cur.focus_next = nxt.get_path()
		cur.focus_previous = prv.get_path()
		cur.focus_neighbor_right = nxt.get_path()
		cur.focus_neighbor_left = prv.get_path()


func _focus_first() -> void:
	if _search:
		_search.grab_focus()


func _focus_after(cur: Control) -> void:
	var i: int = _focusables.find(cur)
	if i < 0 or _focusables.is_empty():
		return
	var nxt: Control = _focusables[(i + 1) % _focusables.size()]
	nxt.grab_focus()


func _focus_before(cur: Control) -> void:
	var i: int = _focusables.find(cur)
	if i < 0 or _focusables.is_empty():
		return
	var prv: Control = _focusables[(i - 1 + _focusables.size()) % _focusables.size()]
	prv.grab_focus()


func _mark_dirty(row: HBoxContainer = null) -> void:
	if row != null and is_instance_valid(row):
		row.set_meta("row_dirty", true)
		_refresh_row_look(row)
	if _dirty:
		return
	_dirty = true
	_status.text = "Unsaved edits · Ctrl+S or Save all. Attack/HP are orange and red, next to the name."
	_status.add_theme_color_override("font_color", Color("6b4a10"))


func _is_junk_text(s: String) -> bool:
	var t: String = s.strip_edges()
	if t == "":
		return true
	for junk in JUNK_TEXT:
		if t == str(junk):
			return true
	if t.begins_with("Type what to change"):
		return true
	if t.begins_with("blank ="):
		return true
	return false


func _sanitize_text(s: String, _key: String = "") -> String:
	if _is_junk_text(s):
		return ""
	return s.strip_edges()


func _text_of(n: Variant) -> String:
	var raw := ""
	if n is LineEdit:
		raw = (n as LineEdit).text.strip_edges()
	elif n is TextEdit:
		raw = (n as TextEdit).text.strip_edges()
	elif n is OptionButton:
		var ob: OptionButton = n
		if ob.selected < 0:
			return ""
		return ob.get_item_text(ob.selected)
	else:
		return ""
	if _is_junk_text(raw):
		return ""
	return raw


func _int_of(s: String, fallback: int) -> int:
	var t: String = _sanitize_text(s)
	if t == "":
		return fallback
	if t.is_valid_int():
		return int(t)
	if t.is_valid_float():
		return int(float(t))
	return fallback


func _null_or_int(s: String) -> Variant:
	var t: String = _sanitize_text(s)
	if t == "":
		return null
	if not t.is_valid_int() and not t.is_valid_float():
		return null
	return _int_of(t, 0)


func _gather_row(row: HBoxContainer, strict: bool = true) -> Dictionary:
	var fields: Dictionary = row.get_meta("fields")
	var orig: Dictionary = row.get_meta("orig")
	var kind: String = str(row.get_meta("kind"))
	var ops: Variant = orig.get("ops", {})
	if fields.has("ops_text"):
		var raw: String = _text_of(fields["ops_text"])
		var parsed: Variant = JSON.parse_string(raw if raw != "" else "{}")
		if typeof(parsed) == TYPE_DICTIONARY or typeof(parsed) == TYPE_ARRAY:
			ops = parsed
		elif strict:
			_status.text = "Ops JSON did not parse on %s — fix the braces." % _text_of(fields.get("id", orig.get("id", "?")))
			_status.add_theme_color_override("font_color", Color("8b1e1e"))
			if sfx:
				sfx.play("error", -8.0)
			return {}
	var id: String = _text_of(fields.get("id", null))
	if id == "":
		id = str(orig.get("id", "new"))
	id = id.to_lower().replace(" ", "_")
	var card := {
		"id": id,
		"name": _text_of(fields["name"]),
		"kind": kind,
		"status": _text_of(fields["status"]),
		"rarity": _text_of(fields["rarity"]),
		"bucket": BucketRules.parse(_text_of(fields["bucket"])) if fields.has("bucket") else BucketRules.parse(orig.get("bucket", 0)),
		"tier": _int_of(_text_of(fields["tier"]), 1),
		"count": _int_of(_text_of(fields["count"]), 1),
		"priority": _int_of(_text_of(fields["priority"]), 3),
		"ability": _text_of(fields["ability"]),
		"explainer": _text_of(fields["explainer"]),
		"call_name": _text_of(fields["call_name"]) if fields.has("call_name") else str(orig.get("call_name", "")),
		"reminder": _text_of(fields["reminder"]) if fields.has("reminder") else str(orig.get("reminder", "")),
		"card_color": _text_of(fields["card_color"]) if fields.has("card_color") else str(orig.get("card_color", "")),
		"flow": _text_of(fields["flow"]),
		"notes": _text_of(fields["notes"]),
		"review": _text_of(fields["review"]) if fields.has("review") else REVIEW_STAGE.of_card(orig),
		"review_note": _text_of(fields["review_note"]) if fields.has("review_note") else str(orig.get("review_note", "")),
		"ops": ops if kind == "item" else orig.get("ops", {}),
		"contradiction_ids": orig.get("contradiction_ids", []),
		"atk_base": orig.get("atk_base", null),
		"hp_base": orig.get("hp_base", null),
		"atk_formula": str(orig.get("atk_formula", "")),
		"hp_formula": str(orig.get("hp_formula", "")),
	}
	if fields.has("atk_base"):
		card["atk_base"] = _null_or_int(_text_of(fields["atk_base"]))
	if fields.has("hp_base"):
		card["hp_base"] = _null_or_int(_text_of(fields["hp_base"]))
	if fields.has("atk_formula"):
		card["atk_formula"] = _text_of(fields["atk_formula"])
	if fields.has("hp_formula"):
		card["hp_formula"] = _text_of(fields["hp_formula"])
	var logic_changed: bool = str(card["flow"]) != str(orig.get("flow", "")) \
		or str(card["notes"]) != str(orig.get("notes", "")) \
		or str(card["atk_formula"]) != str(orig.get("atk_formula", "")) \
		or str(card["hp_formula"]) != str(orig.get("hp_formula", ""))
	if logic_changed and str(card["status"]) == "live":
		card["status"] = "todo"
	card["author_lock"] = bool(orig.get("author_lock", false))
	var prev_lock: Variant = orig.get("locked_fields", [])
	card["locked_fields"] = prev_lock.duplicate() if typeof(prev_lock) == TYPE_ARRAY else []
	card["locked_at"] = str(orig.get("locked_at", ""))
	if bool(row.get_meta("row_dirty", false)) or bool(orig.get("_new", false)):
		AUTHOR_LOCK.stamp_card(card, orig, not bool(orig.get("_new", false)))
		RECENT_EDITS.touch(kind, id)
	return card


func _on_duplicate() -> void:
	if not _flush_visible(false):
		return
	var src: Dictionary = {}
	if _focused_row != null and is_instance_valid(_focused_row):
		src = _gather_row(_focused_row, false)
	elif not _rows.is_empty():
		src = _gather_row(_rows[_rows.size() - 1], false)
	if src.is_empty():
		_on_add()
		return
	if sfx:
		sfx.play("confirm", -10.0)
	var key: String = "monsters" if _kind == "monster" else "items"
	var arr: Array = _board.get(key, [])
	var taken := {}
	for c in arr:
		taken[str(c.get("id", ""))] = true
	var base: String = str(src.get("id", "copy"))
	var nid: String = "%s_copy" % base
	var n: int = 2
	while taken.has(nid):
		nid = "%s_copy_%s" % [base, n]
		n += 1
	var card: Dictionary = src.duplicate(true)
	card["id"] = nid
	card["name"] = "%s copy" % str(src.get("name", "Copy"))
	card["status"] = "todo"
	card["notes"] = "Duplicated from %s." % str(src.get("id", ""))
	card["_new"] = true
	card.erase("author_lock")
	card.erase("locked_fields")
	card.erase("locked_at")
	arr.append(card)
	_board[key] = arr
	_dirty = true
	_rebuild()
	_status.text = "Duplicated %s → %s. Fill it in, then Save all." % [src.get("id", "?"), nid]
	_status.add_theme_color_override("font_color", Color("6b4a10"))
	if not _rows.is_empty():
		var last: HBoxContainer = _rows[_rows.size() - 1]
		_focus_row(last)
		var fields: Dictionary = last.get_meta("fields")
		var name_e: Variant = fields.get("name", null)
		if name_e is Control:
			(name_e as Control).grab_focus()


func _on_add() -> void:
	if not _flush_visible(false):
		return
	if sfx:
		sfx.play("confirm", -10.0)
	var key: String = "monsters" if _kind == "monster" else "items"
	var arr: Array = _board.get(key, [])
	var n: int = 1
	var nid: String = "new_%s" % _kind
	var taken := {}
	for c in arr:
		taken[str(c.get("id", ""))] = true
	while taken.has(nid if n == 1 else "%s_%s" % [nid, n]):
		n += 1
	var id: String = nid if n == 1 else "%s_%s" % [nid, n]
	var card := {
		"id": id,
		"name": "New %s" % ("monster" if _kind == "monster" else "item"),
		"kind": _kind,
		"status": "todo",
		"rarity": "uncommon",
		"bucket": 0,
		"tier": 1,
		"count": 1,
		"priority": 3,
		"ability": "I wait here." if _kind == "monster" else "(ATK 1)",
		"explainer": "",
		"call_name": "",
		"reminder": "",
		"card_color": "",
		"flow": "",
		"notes": "New row from Roster.",
		"ops": {"kind": "atk", "n": 1} if _kind == "item" else {},
		"contradiction_ids": [],
		"atk_base": 2 if _kind == "monster" else null,
		"hp_base": 6 if _kind == "monster" else null,
		"atk_formula": "",
		"hp_formula": "",
		"review": "rough",
		"review_note": "",
		"_new": true,
	}
	arr.append(card)
	_board[key] = arr
	_dirty = true
	_rebuild()
	_status.text = "Added %s. Fill it in, then Save all." % id
	_status.add_theme_color_override("font_color", Color("6b4a10"))
	if not _rows.is_empty():
		var last: HBoxContainer = _rows[_rows.size() - 1]
		var fields: Dictionary = last.get_meta("fields")
		var name_e: Variant = fields.get("name", null)
		if name_e is Control:
			(name_e as Control).grab_focus()


func _on_reset_unlocks() -> void:
	unlocks_reset.emit()
	_status.text = "Dungeon unlocks reset. Bucket 0 is all they can meet until the next Adventure ending."
	_status.add_theme_color_override("font_color", Color("6b4a10"))
	if sfx:
		sfx.play("confirm", -10.0)


func _toggle_buckets() -> void:
	if _bucket_panel == null:
		_build_bucket_panel()
	if _bucket_panel.visible:
		_bucket_panel.visible = false
		return
	_fill_buckets()
	_bucket_panel.visible = true


func _build_bucket_panel() -> void:
	_bucket_panel = ColorRect.new()
	_bucket_panel.color = Color(0.06, 0.05, 0.04, 0.55)
	_bucket_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bucket_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_bucket_panel.visible = false
	_bucket_panel.z_index = 4
	add_child(_bucket_panel)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 36)
	_bucket_panel.add_child(margin)
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f3e6d0")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	margin.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	var head := HBoxContainer.new()
	col.add_child(head)
	var title := Label.new()
	title.text = "Buckets"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("1c120c"))
	head.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(_btn("Close", Color("3a3220"), Color("9a8b78"), func() -> void: _bucket_panel.visible = false, 90))
	var note := Label.new()
	note.text = "0 is in the first dungeon. 1 opens after the first Adventure ending, 2 after the second, and so on. Token is never drafted."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Color("6b4a10"))
	col.add_child(note)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_bucket_body = VBoxContainer.new()
	_bucket_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bucket_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_bucket_body)


func _fill_buckets() -> void:
	if _bucket_body == null:
		return
	for child in _bucket_body.get_children():
		child.free()
	var groups: Dictionary = {}
	for kind in ["item", "monster"]:
		var key_name: String = "items" if kind == "item" else "monsters"
		var arr: Array = _board.get(key_name, [])
		for card in arr:
			if typeof(card) != TYPE_DICTIONARY:
				continue
			var st: String = str(card.get("status", ""))
			if st == "retired" or st == "hold":
				continue
			var b: int = BucketRules.parse(card.get("bucket", 0))
			var label: String = "Token" if b < 0 else str(b)
			if not groups.has(label):
				groups[label] = {"item": [], "monster": []}
			(groups[label][kind] as Array).append(str(card.get("name", card.get("id", "?"))))
	var order: Array[String] = []
	for i in range(BucketRules.MAX_BUCKET + 1):
		order.append(str(i))
	order.append("Token")
	for label in order:
		if not groups.has(label):
			continue
		var block := VBoxContainer.new()
		block.add_theme_constant_override("separation", 2)
		_bucket_body.add_child(block)
		var head := Label.new()
		var items: Array = groups[label]["item"]
		var mons: Array = groups[label]["monster"]
		items.sort()
		mons.sort()
		head.text = "%s  ·  %s items, %s monsters" % [label, items.size(), mons.size()]
		head.add_theme_font_size_override("font_size", 18)
		var col: Color = BucketRules.TOKEN_COLOR if label == "Token" else BucketRules.color_of(int(label))
		head.add_theme_color_override("font_color", col.darkened(0.35))
		block.add_child(head)
		var line := Label.new()
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 15)
		line.add_theme_color_override("font_color", Color("1c120c"))
		var bits: PackedStringArray = []
		if not items.is_empty():
			bits.append("Loot: " + ", ".join(items))
		if not mons.is_empty():
			bits.append("Foes: " + ", ".join(mons))
		line.text = "\n".join(bits)
		block.add_child(line)


func _refresh_bucket_warn() -> void:
	if _bucket_warn == null:
		return
	var items: Array = []
	var monsters: Array = []
	for card in _board.get("items", []):
		items.append(card)
	for card2 in _board.get("monsters", []):
		monsters.append(card2)
	var live: Array = items if _kind == "item" else monsters
	var by_id := {}
	for i in live.size():
		by_id[str(live[i].get("id", ""))] = i
	for row in _rows:
		if row == null or not is_instance_valid(row):
			continue
		var orig: Dictionary = row.get_meta("orig")
		var fields: Dictionary = row.get_meta("fields")
		var id: String = str(orig.get("id", ""))
		if not by_id.has(id) or not fields.has("bucket"):
			continue
		var copy: Dictionary = (live[by_id[id]] as Dictionary).duplicate(true)
		copy["bucket"] = BucketRules.parse(_text_of(fields["bucket"]))
		live[by_id[id]] = copy
	var msg: String = BucketRules.counts_warning(items, monsters)
	_bucket_warn.text = msg
	_bucket_warn.visible = msg != ""


func _on_save() -> void:
	if not _flush_visible():
		return
	_board["updated"] = Time.get_date_string_from_system()
	_board["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
	var path: String = ProjectSettings.globalize_path(BOARD_PATH)
	if not AUTHOR_LOCK.write_json(BOARD_PATH, _board):
		_status.text = "Could not write %s." % path
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		if sfx:
			sfx.play("error_big", -8.0)
		return
	AUTHOR_LOCK.rebuild_ledger(_board, null)
	var merged: Array = _board.get("monsters" if _kind == "monster" else "items", [])
	_write_runtime_ids(merged)
	_dirty = false
	_status.text = "Saved and locked · %s · %s" % [path, _chrome_text()]
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	if sfx:
		sfx.play("book", -8.0)
		sfx.play("confirm_big", -12.0)
	committed.emit(_board.get("items", []), _board.get("monsters", []))


func _write_runtime_ids(merged: Array) -> void:
	_load_runtime()
	var rkey: String = "monsters" if _kind == "monster" else "items"
	var keep: Array = []
	var have := {}
	for id in _runtime.get(rkey, []):
		have[str(id)] = true
		keep.append(str(id))
	for card in merged:
		var sid := str(card.get("id", ""))
		var st := str(card.get("status", "live"))
		if st == "retired" or st == "hold":
			continue
		if have.has(sid):
			continue
		keep.append(sid)
		have[sid] = true
	var pruned: Array = []
	for id2 in keep:
		var still := false
		for card2 in merged:
			if str(card2.get("id", "")) == str(id2) and str(card2.get("status", "live")) != "retired" and str(card2.get("status", "live")) != "hold":
				still = true
				break
		if still:
			pruned.append(id2)
	_runtime[rkey] = pruned
	var path: String = ProjectSettings.globalize_path(RUNTIME_PATH)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		f = FileAccess.open(RUNTIME_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(_runtime, "\t"))


func _build_review_bar() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var cap := Label.new()
	cap.text = "Sort by"
	cap.add_theme_font_size_override("font_size", 16)
	cap.add_theme_color_override("font_color", Color("6b1008"))
	row.add_child(cap)
	var all_b := _chip("All", true)
	all_b.pressed.connect(func() -> void: _set_review_filter(""))
	_review_chips[""] = all_b
	row.add_child(all_b)
	for stage in REVIEW_STAGE.STAGES:
		var b := _chip(str(stage).capitalize(), false)
		b.pressed.connect(_set_review_filter.bind(str(stage)))
		_review_chips[str(stage)] = b
		row.add_child(b)
	return row


func _set_review_filter(stage: String) -> void:
	if not _flush_visible(false):
		return
	if sfx:
		sfx.play("switch", -12.0)
	_review_filter = stage
	_rebuild()


func _sync_review_chips() -> void:
	for k in _review_chips.keys():
		var b: Button = _review_chips[k]
		var on: bool = str(k) == _review_filter
		b.modulate = Color.WHITE if on else Color(1, 1, 1, 0.55)


func _style_review_row(row: HBoxContainer) -> void:
	if row == null or not is_instance_valid(row):
		return
	var fields: Dictionary = row.get_meta("fields")
	var stage: String = "polish"
	if fields.has("review"):
		stage = _text_of(fields["review"])
	var note: Variant = fields.get("review_note", null)
	if note is TextEdit:
		_skin_review_note(note as TextEdit, stage)


func _skin_review_note(e: TextEdit, stage: String) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	if stage == "rough":
		sb.bg_color = Color("ffe08a")
		sb.border_color = Color("8b1e1e")
		sb.set_border_width_all(3)
		e.add_theme_color_override("font_color", Color("6b1008"))
		e.add_theme_color_override("font_placeholder_color", Color("8b1e1e"))
		e.add_theme_font_size_override("font_size", 15)
	else:
		sb.bg_color = Color("fffaf2")
		sb.border_color = Color("c4a574")
		sb.set_border_width_all(1)
		e.add_theme_color_override("font_color", Color("1c120c"))
		e.add_theme_color_override("font_placeholder_color", Color("8a6a3a"))
		e.add_theme_font_size_override("font_size", 14)
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("focus", sb)
	e.add_theme_stylebox_override("read_only", sb)


func _chip(text: String, on: bool) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 36)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("1c120c"))
	var n := StyleBoxFlat.new()
	n.bg_color = Color("e8d7b8") if on else Color("d4c4a8")
	n.border_color = Color("c4a574")
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	n.content_margin_left = 12
	n.content_margin_right = 12
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate()
	(h as StyleBoxFlat).bg_color = Color("f0e6d8")
	b.add_theme_stylebox_override("hover", h)
	b.modulate = Color.WHITE if on else Color(1, 1, 1, 0.55)
	return b


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
			KEY_D:
				_on_duplicate()
				get_viewport().set_input_as_handled()
