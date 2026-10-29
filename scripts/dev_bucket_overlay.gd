extends ColorRect
## Pool editor. Drag cards between pyramids. Click a header to set this save’s unlock.

signal revealed_changed(n: int)
signal card_hovered(kind: String, card_id: String, slot: Control)
signal card_unhovered
signal card_edit(kind: String, card_id: String)
signal assignments_saved(items: Array, monsters: Array)
signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")
const BOARD_PATH := "res://data/content-board.json"
const PX := 4.0
const SPRITE := 56.0
const COL_W := 268.0
const COL_GAP := 16.0

var art
var items_by_id: Dictionary = {}
var monsters_by_id: Dictionary = {}
var revealed: int = 0

var _board: Dictionary = {}
var _pending: Dictionary = {}
var _show_token: bool = false
var _scroll: ScrollContainer
var _row: HBoxContainer
var _title
var _hint
var _status
var _back: Button
var _save: Button
var _revert: Button
var _token_btn: Button
var _tabs: HBoxContainer
var _confirm: PanelContainer
var _hover_slot: Control
var _columns: Dictionary = {}
var _sfx


func setup(p_sfx = null) -> void:
	_sfx = p_sfx
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	color = Color("100e0cf2")
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 128
	_build_chrome()


func open_overlay(p_art, p_items: Dictionary, p_monsters: Dictionary, p_revealed: int, p_board: Dictionary = {}) -> void:
	art = p_art
	items_by_id = p_items
	monsters_by_id = p_monsters
	revealed = clampi(p_revealed, 1, BucketRules.MAX_BUCKET)
	_pending.clear()
	_show_token = false
	if _token_btn:
		_token_btn.text = "Show Token"
	if p_board.is_empty():
		_load_board()
	else:
		_board = p_board.duplicate(true)
	visible = true
	move_to_front()
	set_process(true)
	rebuild()
	_sync_bar()


func close_overlay() -> void:
	if not visible:
		return
	if not _pending.is_empty():
		_show_confirm(true)
		return
	_hide_confirm()
	_clear_hover()
	set_process(false)
	visible = false
	closed.emit()


func force_close() -> void:
	_pending.clear()
	_hide_confirm()
	_clear_hover()
	set_process(false)
	visible = false
	closed.emit()


func rebuild() -> void:
	if _row == null:
		return
	var keep_h: int = _scroll.scroll_horizontal if _scroll else 0
	var keep_v: int = _scroll.scroll_vertical if _scroll else 0
	for child in _row.get_children():
		_row.remove_child(child)
		child.queue_free()
	_columns.clear()
	var groups: Dictionary = _group_cards()
	for b in range(1, BucketRules.MAX_BUCKET + 1):
		var col := _make_column(b, groups.get(b, {"item": [], "monster": []}))
		_row.add_child(col)
		_columns[b] = col
	var aside := _make_column(0, groups.get(0, {"item": [], "monster": []}))
	_row.add_child(aside)
	_columns[0] = aside
	if _show_token:
		var tok := _make_column(-1, groups.get(-1, {"item": [], "monster": []}))
		_row.add_child(tok)
		_columns[-1] = tok
	var n: int = _row.get_child_count()
	_row.custom_minimum_size = Vector2(maxi(0, n) * (COL_W + COL_GAP) - COL_GAP, 420.0)
	_paint_tabs()
	if _scroll:
		_scroll.scroll_horizontal = keep_h
		_scroll.scroll_vertical = keep_v


func reload_board_keep_pending() -> void:
	_load_board()
	rebuild()
	_sync_bar()


func _build_chrome() -> void:
	_back = _chrome_btn("Back", Vector2(72, 16), _on_back)
	_back.position = Vector2(16, 10) * PX
	add_child(_back)

	_title = KIT.raw_label("Pools", 32, KIT.CREAM)
	_title.position = Vector2(96, 10) * PX
	_title.size = Vector2(140, 16) * PX
	add_child(_title)

	_save = _chrome_btn("Save", Vector2(72, 16), _on_save)
	_save.position = Vector2(240, 10) * PX
	add_child(_save)
	_revert = _chrome_btn("Revert", Vector2(80, 16), _on_revert)
	_revert.position = Vector2(316, 10) * PX
	add_child(_revert)
	_token_btn = _chrome_btn("Show Token", Vector2(100, 16), _toggle_token)
	_token_btn.position = Vector2(400, 10) * PX
	add_child(_token_btn)

	_hint = KIT.raw_label(
		"Gold on top, then silver, then bronze. Hover a card: 1–5 moves it, 0 puts it Aside (hold), T is Token. Drag works too. Smoke, pair extras, and mode-only sit in Aside. Finished is green, Change is red. Click a Pool header to set this save’s unlock. Save writes the card files.",
		18,
		KIT.MUTED,
		true
	)
	_hint.position = Vector2(16, 28) * PX
	_hint.size = Vector2(380, 14) * PX
	add_child(_hint)

	_status = KIT.raw_label("", 18, KIT.MUTED)
	_status.position = Vector2(16, 40) * PX
	_status.size = Vector2(280, 12) * PX
	add_child(_status)

	_tabs = HBoxContainer.new()
	_tabs.position = Vector2(300, 38) * PX
	_tabs.size = Vector2(200, 14) * PX
	_tabs.add_theme_constant_override("separation", 8)
	add_child(_tabs)

	_scroll = WheelBoard.new()
	_scroll.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_scroll.offset_left = 16.0 * PX
	_scroll.offset_top = 56.0 * PX
	_scroll.offset_right = -16.0 * PX
	_scroll.offset_bottom = -16.0 * PX
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	add_child(_scroll)

	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", int(COL_GAP))
	_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_row)

	_confirm = PanelContainer.new()
	_confirm.visible = false
	_confirm.z_index = 6
	_confirm.position = Vector2(140, 80) * PX
	_confirm.size = Vector2(140, 70) * PX
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color("1c1814")
	csb.border_color = Color("c4a574")
	csb.set_border_width_all(2)
	csb.set_corner_radius_all(8)
	csb.content_margin_left = 16
	csb.content_margin_right = 16
	csb.content_margin_top = 12
	csb.content_margin_bottom = 12
	_confirm.add_theme_stylebox_override("panel", csb)
	add_child(_confirm)
	var ask := VBoxContainer.new()
	ask.add_theme_constant_override("separation", 10)
	_confirm.add_child(ask)
	var ask_l := KIT.raw_label("Leave without saving these pool moves?", 18, KIT.CREAM, true)
	ask.add_child(ask_l)
	var yes := _chrome_btn("Leave", Vector2(100, 16), _leave_unsaved)
	ask.add_child(yes)
	var no := _chrome_btn("Stay", Vector2(100, 16), func() -> void: _show_confirm(false))
	ask.add_child(no)


func _chrome_btn(text: String, size_native: Vector2, cb: Callable) -> Button:
	var b := KIT.choice_tag("pause.resume", size_native)
	b.text = text
	b.pressed.connect(cb)
	return b


func _load_board() -> void:
	var f := FileAccess.open(BOARD_PATH, FileAccess.READ)
	if f == null:
		_board = {}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		_board = {}
		return
	_board = (parsed as Dictionary).duplicate(true)


func _group_cards() -> Dictionary:
	var out := {}
	for b in range(0, BucketRules.MAX_BUCKET + 1):
		out[b] = {"item": [], "monster": []}
	out[-1] = {"item": [], "monster": []}
	_collect(out, "item")
	_collect(out, "monster")
	for b in out.keys():
		for kind in ["item", "monster"]:
			var arr: Array = out[b][kind]
			arr.sort_custom(func(a, c) -> bool:
				var ra: int = _readiness(a)
				var rc: int = _readiness(c)
				if ra != rc:
					return ra < rc
				var ta: int = BucketRules.tier_of(a)
				var tc: int = BucketRules.tier_of(c)
				if ta != tc:
					return ta > tc
				return str(a.get("name", "")).to_lower() < str(c.get("name", "")).to_lower()
			)
	return out


func _collect(out: Dictionary, kind: String) -> void:
	var key: String = "items" if kind == "item" else "monsters"
	for card in _board.get(key, []):
		if typeof(card) != TYPE_DICTIONARY:
			continue
		var id: String = str(card.get("id", ""))
		if id == "":
			continue
		var b: int = _eff_bucket(kind, id, card)
		if b < 0 and not _show_token:
			continue
		if not out.has(b):
			out[b] = {"item": [], "monster": []}
		var copy: Dictionary = card.duplicate(true)
		copy["id"] = id
		(out[b][kind] as Array).append(copy)


func _eff_bucket(kind: String, id: String, card: Dictionary) -> int:
	var k: String = _pkey(kind, id)
	if _pending.has(k):
		return int(_pending[k])
	return BucketRules.display_pool(card)


func _pkey(kind: String, id: String) -> String:
	return "%s:%s" % [kind, id]


func _readiness(card: Dictionary) -> int:
	match ReviewStage.of_card(card):
		"finished":
			return 0
		"polish":
			return 1
		"refined":
			return 2
		"change":
			return 4
		_:
			return 3


func _make_column(bucket: int, group: Dictionary) -> BucketColumn:
	var open: bool = bucket < 1 or (bucket >= 1 and bucket <= revealed)
	var accent: Color = BucketRules.TOKEN_COLOR if bucket < 1 else BucketRules.color_of(bucket)
	var col := BucketColumn.new()
	col.bucket = bucket
	col.drop_cb = _on_drop
	col.custom_minimum_size = Vector2(COL_W, 0)
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c1814") if open or bucket < 0 else Color("141210")
	sb.border_color = accent if (open or bucket < 0) else accent.darkened(0.45)
	sb.set_border_width_all(3 if bucket == revealed else 2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	col.add_theme_stylebox_override("panel", sb)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(stack)

	var head := Button.new()
	head.text = _header_text(bucket, group)
	head.custom_minimum_size = Vector2(0, 52)
	head.clip_text = false
	head.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	head.add_theme_font_size_override("font_size", 15)
	head.add_theme_color_override("font_color", BucketRules.ink_for(accent) if open or bucket < 0 else KIT.MUTED)
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = accent if open or bucket < 0 else accent.darkened(0.4)
	hsb.set_corner_radius_all(6)
	hsb.content_margin_left = 8
	hsb.content_margin_right = 8
	hsb.content_margin_top = 6
	hsb.content_margin_bottom = 6
	head.add_theme_stylebox_override("normal", hsb)
	var hov := hsb.duplicate()
	(hov as StyleBoxFlat).bg_color = accent.lightened(0.12)
	head.add_theme_stylebox_override("hover", hov)
	head.add_theme_stylebox_override("pressed", hov)
	head.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	head.focus_mode = Control.FOCUS_NONE
	if bucket >= 1:
		head.pressed.connect(func() -> void:
			_pick_unlock(bucket)
		)
	else:
		head.disabled = true
	stack.add_child(head)

	var items: Array = group.get("item", [])
	var mons: Array = group.get("monster", [])
	stack.add_child(_kind_block("item", items, bucket))
	stack.add_child(_kind_block("monster", mons, bucket))
	return col


func _header_text(bucket: int, group: Dictionary) -> String:
	if bucket < 0:
		return "Token"
	if bucket == 0:
		return "Aside"
	var lock_word := "Unlocked" if bucket <= revealed else "Locked"
	if bucket == revealed:
		lock_word = "Highest unlocked"
	var mix: String = BucketRules.mix_line(group.get("item", []), group.get("monster", []))
	return "Pool %s  ·  %s\n%s" % [bucket, lock_word, mix]


func _kind_block(kind: String, cards: Array, bucket: int) -> VBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 6)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lab := Label.new()
	lab.text = "Items" if kind == "item" else "Monsters"
	lab.add_theme_font_size_override("font_size", 14)
	lab.add_theme_color_override("font_color", KIT.CREAM)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(lab)
	var by_tier := {1: [], 2: [], 3: []}
	for card2 in cards:
		if typeof(card2) != TYPE_DICTIONARY:
			continue
		(by_tier[BucketRules.tier_of(card2)] as Array).append(card2)
	for t in [3, 2, 1]:
		var row_cards: Array = by_tier[t]
		if row_cards.is_empty() and bucket != 0 and bucket >= 1:
			continue
		if row_cards.is_empty():
			continue
		wrap.add_child(_tier_row(t, row_cards, kind, bucket, false))
	return wrap


func _tier_row(tier: int, cards: Array, kind: String, bucket: int, hole: bool) -> VBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 4)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var metal: Color = BucketRules.tier_color(tier)
	var cap := Label.new()
	cap.text = BucketRules.tier_label(tier)
	cap.add_theme_font_size_override("font_size", 12)
	cap.add_theme_color_override("font_color", metal)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(cap)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(flow)
	for card in cards:
		flow.add_child(_make_tile(card, kind, bucket))
	if hole:
		flow.add_child(_empty_well(tier))
	return wrap


func _extra_holes(n: int) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for _i in n:
		flow.add_child(_empty_well(0))
	return flow


func _empty_well(tier: int) -> EmptyWell:
	var well := EmptyWell.new()
	well.custom_minimum_size = Vector2(88, 86)
	well.mouse_filter = Control.MOUSE_FILTER_STOP
	var metal: Color = BucketRules.tier_color(tier) if tier >= 1 else Color("6a6258")
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("12100e")
	sb.border_color = metal
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	well.add_theme_stylebox_override("panel", sb)
	var stripe := ColorRect.new()
	stripe.color = metal
	stripe.custom_minimum_size = Vector2(0, 10)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well.add_child(stripe)
	return well


func _make_tile(card: Dictionary, kind: String, bucket: int) -> BucketTile:
	var id: String = str(card.get("id", ""))
	var tile := BucketTile.new()
	tile.payload = {
		"type": "bucket_card",
		"kind": kind,
		"id": id,
		"bucket": bucket,
		"name": str(card.get("name", id)),
		"tier": BucketRules.tier_of(card),
	}
	tile.custom_minimum_size = Vector2(88, 90)
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.mouse_default_cursor_shape = Control.CURSOR_MOVE
	var moved: bool = _pending.has(_pkey(kind, id))
	var tier_n: int = BucketRules.tier_of(card)
	var metal: Color = BucketRules.tier_color(tier_n)
	var tsb := StyleBoxFlat.new()
	if kind == "item":
		tsb.bg_color = BucketRules.family_fill(card)
	else:
		tsb.bg_color = BucketRules.tier_fill(tier_n)
	tsb.border_color = Color("f4d36a") if moved else metal
	tsb.set_border_width_all(4)
	tsb.set_corner_radius_all(6)
	tsb.content_margin_left = 3
	tsb.content_margin_right = 3
	tsb.content_margin_top = 0
	tsb.content_margin_bottom = 3
	tile.add_theme_stylebox_override("panel", tsb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(col)
	var stripe := ColorRect.new()
	stripe.color = metal
	stripe.custom_minimum_size = Vector2(0, 10)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(stripe)
	var badge := Label.new()
	badge.text = BucketRules.review_letter(card)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_color_override("font_color", BucketRules.review_color(card))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(badge)
	var pic := TextureRect.new()
	pic.custom_minimum_size = Vector2(SPRITE, SPRITE)
	pic.texture_filter = TEXTURE_FILTER_NEAREST
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if art != null:
		if kind == "monster" and art.has_method("monster_still"):
			pic.texture = art.monster_still(id)
		elif art.has_method("item_tex"):
			pic.texture = art.item_tex(id)
	col.add_child(pic)
	var name_l := Label.new()
	name_l.text = str(card.get("name", id))
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 11)
	if kind == "item":
		name_l.add_theme_color_override("font_color", Color("f4ede3"))
	else:
		name_l.add_theme_color_override("font_color", Color("1c120c"))
	name_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(name_l)
	tile.mouse_entered.connect(func() -> void:
		_hover_slot = tile
		card_hovered.emit(kind, id, tile)
	)
	tile.mouse_exited.connect(func() -> void:
		if _hover_slot == tile:
			_hover_slot = null
		card_unhovered.emit()
	)
	tile.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			card_edit.emit(kind, id)
			tile.accept_event()
	)
	return tile


func _on_drop(data: Variant, dest: int) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var kind: String = str(data.get("kind", ""))
	var id: String = str(data.get("id", ""))
	if kind == "" or id == "":
		return
	var card := _find_card(kind, id)
	if card.is_empty():
		return
	var orig: int = BucketRules.display_pool(card)
	var key: String = _pkey(kind, id)
	if dest == orig:
		_pending.erase(key)
	else:
		_pending[key] = dest
	if _sfx and _sfx.has_method("play"):
		_sfx.play("click2", -12.0)
	rebuild()
	_sync_bar()


func _find_card(kind: String, id: String) -> Dictionary:
	var key: String = "items" if kind == "item" else "monsters"
	for card in _board.get(key, []):
		if typeof(card) == TYPE_DICTIONARY and str(card.get("id", "")) == id:
			return card
	return {}


func _pick_unlock(bucket: int) -> void:
	revealed = clampi(bucket, 1, BucketRules.MAX_BUCKET)
	revealed_changed.emit(revealed)
	rebuild()


func _toggle_token() -> void:
	_show_token = not _show_token
	_token_btn.text = "Hide Token" if _show_token else "Show Token"
	rebuild()


func _paint_tabs() -> void:
	if _tabs == null:
		return
	for child in _tabs.get_children():
		_tabs.remove_child(child)
		child.queue_free()
	var pages: Array = [
		{"label": "1–2", "at": 1},
		{"label": "3–4", "at": 3},
		{"label": "5", "at": 5},
		{"label": "Aside", "at": 0},
	]
	if _show_token:
		pages.append({"label": "Token", "at": -1})
	for page in pages:
		var b := Button.new()
		b.text = str(page["label"])
		b.custom_minimum_size = Vector2(56, 28)
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_font_size_override("font_size", 13)
		b.add_theme_color_override("font_color", KIT.CREAM)
		var nsb := StyleBoxFlat.new()
		nsb.bg_color = Color("3a3220")
		nsb.border_color = Color("c4a574")
		nsb.set_border_width_all(1)
		nsb.set_corner_radius_all(6)
		b.add_theme_stylebox_override("normal", nsb)
		var at: int = int(page["at"])
		b.pressed.connect(_jump_to.bind(at))
		_tabs.add_child(b)


func _jump_to(bucket: int) -> void:
	call_deferred("_jump_to_now", bucket)


func _jump_to_now(bucket: int) -> void:
	if _scroll == null or _row == null:
		return
	var idx: int = -1
	for i in _row.get_child_count():
		var child: Node = _row.get_child(i)
		if child is BucketColumn and (child as BucketColumn).bucket == bucket:
			idx = i
			break
	if idx < 0:
		return
	var col: Control = _row.get_child(idx)
	var x: float = col.position.x
	if x < 1.0:
		x = float(idx) * (COL_W + COL_GAP)
	_scroll.scroll_horizontal = maxi(0, int(x) - 8)


func _sync_bar() -> void:
	var n: int = _pending.size()
	_save.disabled = n == 0
	_revert.disabled = n == 0
	if n == 0:
		_status.text = "No unsaved moves."
		_status.add_theme_color_override("font_color", KIT.MUTED)
	else:
		_status.text = "%s unsaved move%s. Save keeps them on the board." % [n, "" if n == 1 else "s"]
		_status.add_theme_color_override("font_color", Color("e8c36a"))


func _on_save() -> void:
	if _pending.is_empty():
		return
	for key in _pending.keys():
		var parts: PackedStringArray = str(key).split(":")
		if parts.size() < 2:
			continue
		var kind: String = parts[0]
		var id: String = str(key).substr(kind.length() + 1)
		var dest: int = int(_pending[key])
		var card := _find_card(kind, id)
		if card.is_empty():
			continue
		var prev: Dictionary = card.duplicate(true)
		card["pool"] = dest
		card.erase("bucket")
		if dest == 0:
			var st: String = str(card.get("status", "live"))
			if st == "live" or st == "todo":
				card["status"] = "hold"
		elif dest >= 1 or dest < 0:
			if str(card.get("status", "live")) == "hold":
				card["status"] = "live"
		AUTHOR_LOCK.stamp_card(card, prev, true)
	_board["updated"] = Time.get_date_string_from_system()
	if not AUTHOR_LOCK.write_json(BOARD_PATH, _board):
		_status.text = "Could not write the board file."
		_status.add_theme_color_override("font_color", Color("e07a7a"))
		return
	AUTHOR_LOCK.rebuild_ledger(_board, null)
	_pending.clear()
	_sync_bar()
	rebuild()
	if _sfx and _sfx.has_method("play"):
		_sfx.play("book", -8.0)
	assignments_saved.emit(_board.get("items", []), _board.get("monsters", []))
	_status.text = "Saved pool moves."
	_status.add_theme_color_override("font_color", Color("8dcb8d"))


func _on_revert() -> void:
	_pending.clear()
	rebuild()
	_sync_bar()
	if _sfx and _sfx.has_method("play"):
		_sfx.play("click", -10.0)


func _on_back() -> void:
	close_overlay()


func _show_confirm(on: bool) -> void:
	if _confirm:
		_confirm.visible = on


func _leave_unsaved() -> void:
	_pending.clear()
	_hide_confirm()
	_clear_hover()
	set_process(false)
	visible = false
	closed.emit()


func _hide_confirm() -> void:
	_show_confirm(false)


func _clear_hover() -> void:
	_hover_slot = null
	card_unhovered.emit()


func _process(_delta: float) -> void:
	if not visible or _scroll == null or _higher_overlay_open():
		return
	if not get_viewport().gui_is_dragging():
		return
	var p: Vector2 = get_global_mouse_position()
	var r: Rect2 = get_viewport().get_visible_rect()
	const EDGE := 88.0
	const SPEED := 24
	if p.x < r.position.x + EDGE:
		_scroll.scroll_horizontal -= SPEED
	elif p.x > r.position.x + r.size.x - EDGE:
		_scroll.scroll_horizontal += SPEED
	if p.y < r.position.y + EDGE:
		_scroll.scroll_vertical -= SPEED
	elif p.y > r.position.y + r.size.y - EDGE:
		_scroll.scroll_vertical += SPEED


func _higher_overlay_open() -> bool:
	var p := get_parent()
	if p == null:
		return false
	for child in p.get_children():
		if child == self or not (child is CanvasItem):
			continue
		if child.visible and int(child.z_index) > z_index:
			return true
	return false


func _hovered_payload() -> Dictionary:
	if _hover_slot == null or not is_instance_valid(_hover_slot):
		return {}
	if _hover_slot is BucketTile:
		return (_hover_slot as BucketTile).payload
	return {}


func _handle_pool_hotkey(event: InputEventKey) -> bool:
	var code: int = event.keycode
	if code == KEY_T:
		var payload: Dictionary = _hovered_payload()
		if not payload.is_empty():
			_show_token = true
			if _token_btn:
				_token_btn.text = "Hide Token"
			_on_drop(payload, -1)
		else:
			_toggle_token()
		return true
	if code == KEY_0:
		var held: Dictionary = _hovered_payload()
		if held.is_empty():
			return false
		_on_drop(held, 0)
		return true
	if code >= KEY_1 and code <= KEY_5:
		var move: Dictionary = _hovered_payload()
		if move.is_empty():
			return false
		_on_drop(move, code - KEY_0)
		return true
	var review := ""
	match code:
		KEY_N:
			review = "rough"
		KEY_R:
			review = "refined"
		KEY_P:
			review = "polish"
		KEY_F:
			review = "finished"
		KEY_C:
			review = "change"
	if review == "":
		return false
	var rev_pay: Dictionary = _hovered_payload()
	if rev_pay.is_empty():
		return false
	var card := _find_card(str(rev_pay.get("kind", "")), str(rev_pay.get("id", "")))
	if card.is_empty():
		return false
	var prev: Dictionary = card.duplicate(true)
	card["review"] = review
	AUTHOR_LOCK.stamp_card(card, prev, true)
	_board["updated"] = Time.get_date_string_from_system()
	AUTHOR_LOCK.write_json(BOARD_PATH, _board)
	AUTHOR_LOCK.rebuild_ledger(_board, null)
	assignments_saved.emit(_board.get("items", []), _board.get("monsters", []))
	rebuild()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _higher_overlay_open():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_S:
		_on_save()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and not event.meta_pressed:
		if _handle_pool_hotkey(event):
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_cancel"):
		if _confirm and _confirm.visible:
			_show_confirm(false)
		else:
			close_overlay()
		get_viewport().set_input_as_handled()


class WheelBoard extends ScrollContainer:
	const STEP := 96

	func _ready() -> void:
		set_process_input(true)

	func _input(event: InputEvent) -> void:
		if not is_visible_in_tree():
			return
		var host := get_parent()
		if host and host.has_method("_higher_overlay_open") and host._higher_overlay_open():
			return
		if not event is InputEventMouseButton:
			return
		var e: InputEventMouseButton = event
		if not e.pressed:
			return
		if not get_global_rect().has_point(get_global_mouse_position()):
			return
		match e.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if e.shift_pressed:
					scroll_horizontal -= STEP
				else:
					scroll_vertical -= STEP
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if e.shift_pressed:
					scroll_horizontal += STEP
				else:
					scroll_vertical += STEP
				get_viewport().set_input_as_handled()


class BucketColumn extends PanelContainer:
	var bucket: int = 0
	var drop_cb: Callable

	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		if typeof(data) != TYPE_DICTIONARY or str(data.get("type", "")) != "bucket_card":
			return false
		modulate = Color(1.12, 1.08, 0.9)
		return true

	func _drop_data(_at: Vector2, data: Variant) -> void:
		modulate = Color.WHITE
		if drop_cb.is_valid():
			drop_cb.call(data, bucket)

	func _notification(what: int) -> void:
		if what == NOTIFICATION_DRAG_END:
			modulate = Color.WHITE


class BucketTile extends PanelContainer:
	var payload: Dictionary = {}

	func _get_drag_data(_at: Vector2) -> Variant:
		var preview := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("3a3220")
		sb.border_color = Color("e8c36a")
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		preview.add_theme_stylebox_override("panel", sb)
		var lab := Label.new()
		lab.text = str(payload.get("name", "card"))
		lab.add_theme_font_size_override("font_size", 14)
		lab.add_theme_color_override("font_color", Color("f0e6d8"))
		preview.add_child(lab)
		set_drag_preview(preview)
		modulate.a = 0.4
		return payload

	func _notification(what: int) -> void:
		if what == NOTIFICATION_DRAG_END:
			modulate.a = 1.0

	func _can_drop_data(at: Vector2, data: Variant) -> bool:
		var p := get_parent()
		while p:
			if p is BucketColumn:
				return p._can_drop_data(at, data)
			p = p.get_parent()
		return false

	func _drop_data(at: Vector2, data: Variant) -> void:
		var p := get_parent()
		while p:
			if p is BucketColumn:
				p._drop_data(at, data)
				return
			p = p.get_parent()


class EmptyWell extends PanelContainer:
	func _can_drop_data(at: Vector2, data: Variant) -> bool:
		var p := get_parent()
		while p:
			if p is BucketColumn:
				return p._can_drop_data(at, data)
			p = p.get_parent()
		return false

	func _drop_data(at: Vector2, data: Variant) -> void:
		var p := get_parent()
		while p:
			if p is BucketColumn:
				p._drop_data(at, data)
				return
			p = p.get_parent()
