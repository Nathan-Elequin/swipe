extends ColorRect
## Items | Monsters tabs. Weak / Tough / Deadly one at a time. S–F rows. Drag to rank.

signal send_wanted(ranks: Dictionary)
signal closed
signal card_hovered(kind: String, card_id: String, slot: Control)
signal card_unhovered

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const ROWS: PackedStringArray = ["S", "A", "B", "C", "D", "F"]
const TIERS: PackedInt32Array = [1, 2, 3]

var items_by_id: Dictionary = {}
var monsters_by_id: Dictionary = {}
var art
var buckets_open: int = 0
var _kind: String = "item"
var _tier: int = 1
var _bucket_on: Dictionary = {}
var _ranks: Dictionary = {}
var _pool: VBoxContainer
var _row_hosts: Dictionary = {}
var _bucket_row: HFlowContainer
var _tab_items: Button
var _tab_mons: Button
var _tier_btns: Dictionary = {}
var _status: Label


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color("0c0a08f4")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 132
	visible = false
	name = "playtest_tier_list"
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var col := VBoxContainer.new()
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	margin.add_child(col)
	var head := Label.new()
	head.text = COPY.text("playtest.tier_list", "Tier List")
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_size_override("font_size", 28)
	head.add_theme_color_override("font_color", Color("e8c36a"))
	head.add_theme_color_override("font_outline_color", Color("100e0c"))
	head.add_theme_constant_override("outline_size", 3)
	col.add_child(head)
	var blurb := Label.new()
	blurb.text = COPY.text("playtest.tier_blurb", "Rank cards of the same strength against each other. Drag a card onto a row.")
	blurb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.add_theme_font_size_override("font_size", 15)
	blurb.add_theme_color_override("font_color", Color("d8cbb8"))
	col.add_child(blurb)
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 12)
	col.add_child(tabs)
	_tab_items = _toggle(COPY.text("playtest.items", "Items"), func() -> void: _set_kind("item"))
	_tab_mons = _toggle(COPY.text("playtest.monsters", "Monsters"), func() -> void: _set_kind("monster"))
	tabs.add_child(_tab_items)
	tabs.add_child(_tab_mons)
	var tiers := HBoxContainer.new()
	tiers.alignment = BoxContainer.ALIGNMENT_CENTER
	tiers.add_theme_constant_override("separation", 10)
	col.add_child(tiers)
	for t in TIERS:
		var lab: String = "Tier %s" % t
		var b := _toggle(lab, func() -> void: _set_tier(t))
		_tier_btns[t] = b
		tiers.add_child(b)
	_bucket_row = HFlowContainer.new()
	_bucket_row.alignment = FlowContainer.ALIGNMENT_CENTER
	_bucket_row.add_theme_constant_override("h_separation", 8)
	_bucket_row.add_theme_constant_override("v_separation", 6)
	col.add_child(_bucket_row)
	var board := HBoxContainer.new()
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.add_theme_constant_override("separation", 8)
	col.add_child(board)
	board.add_child(_kanban_col(COPY.text("playtest.unranked", "Unranked"), "_pool", true))
	_pool = _row_hosts["_pool"]
	for row_id in ROWS:
		board.add_child(_kanban_col(row_id, row_id, false))
	var foot := Label.new()
	foot.text = COPY.text("playtest.screenshot", "You can screenshot this screen and send it.")
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foot.add_theme_font_size_override("font_size", 14)
	foot.add_theme_color_override("font_color", Color("c4a574"))
	col.add_child(foot)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("8dcb8d"))
	col.add_child(_status)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 14)
	col.add_child(actions)
	actions.add_child(_btn(COPY.text("playtest.send", "Send"), func() -> void: send_wanted.emit(export_ranks())))
	actions.add_child(_btn(COPY.text("playtest.close", "Close"), func() -> void: close_list()))


func open_list(p_items: Dictionary, p_mons: Dictionary, p_art, revealed: int) -> void:
	items_by_id = p_items
	monsters_by_id = p_mons
	art = p_art
	buckets_open = clampi(revealed, 1, BucketRules.MAX_BUCKET)
	_kind = "item"
	_tier = 1
	_bucket_on.clear()
	_bucket_on[buckets_open] = true
	_status.text = ""
	_rebuild_bucket_toggles()
	_paint_tabs()
	_rebuild()
	visible = true
	move_to_front()


func close_list() -> void:
	visible = false
	card_unhovered.emit()
	closed.emit()


func show_result(ok: bool, detail: String) -> void:
	_status.add_theme_color_override("font_color", Color("8dcb8d") if ok else Color("e07a3d"))
	_status.text = detail


func export_ranks() -> Dictionary:
	var cap: int = _bucket_cap()
	var buckets: Array = []
	for b in range(1, cap + 1):
		buckets.append(b)
	return {
		"kind": _kind,
		"card_tier": _tier,
		"buckets": buckets,
		"rows": _ranks_for(_kind, _tier).duplicate(true),
	}


func _set_kind(kind: String) -> void:
	_kind = kind
	_paint_tabs()
	_rebuild()


func _set_tier(tier: int) -> void:
	_tier = tier
	_paint_tabs()
	_rebuild()


func _paint_tabs() -> void:
	_mark(_tab_items, _kind == "item")
	_mark(_tab_mons, _kind == "monster")
	for t in _tier_btns.keys():
		_mark(_tier_btns[t], int(t) == _tier)


func _rebuild_bucket_toggles() -> void:
	for c in _bucket_row.get_children():
		c.queue_free()
	for b in range(1, BucketRules.MAX_BUCKET + 1):
		var n: int = b
		var btn := Button.new()
		btn.toggle_mode = true
		btn.button_pressed = bool(_bucket_on.get(n, false))
		btn.text = str(n)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		UX.dress_title_button(btn, 52)
		btn.custom_minimum_size = Vector2(52, 40)
		btn.toggled.connect(func(on: bool) -> void:
			if not on:
				btn.set_pressed_no_signal(true)
				return
			_bucket_on.clear()
			_bucket_on[n] = true
			for sibling in _bucket_row.get_children():
				if sibling != btn and sibling is Button:
					(sibling as Button).set_pressed_no_signal(false)
			_rebuild()
		)
		_bucket_row.add_child(btn)


func _bucket_cap() -> int:
	var cap: int = 0
	for k in _bucket_on.keys():
		if bool(_bucket_on[k]):
			cap = maxi(cap, int(k))
	return cap


func _kanban_col(title: String, row_id: String, bank: bool) -> PanelContainer:
	var pan := PanelContainer.new()
	pan.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if bank:
		pan.custom_minimum_size = Vector2(168, 0)
		pan.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	else:
		pan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c1814")
	sb.border_color = Color("c4a574") if bank else Color("3a322b")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	pan.add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	pan.add_child(col)
	var lab := Label.new()
	lab.text = title
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 18)
	lab.add_theme_color_override("font_color", Color("e8c36a"))
	col.add_child(lab)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var flow := RankRow.new()
	flow.row_id = row_id
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	flow.custom_minimum_size = Vector2(90, 280)
	flow.add_theme_constant_override("separation", 8)
	flow.dropped.connect(_on_drop)
	scroll.add_child(flow)
	_row_hosts[row_id] = flow
	return pan


func _rebuild() -> void:
	card_unhovered.emit()
	for host in _row_hosts.values():
		for c in host.get_children():
			host.remove_child(c)
			c.queue_free()
	var placed: Dictionary = {}
	var ranks: Dictionary = _ranks_for(_kind, _tier)
	for row_id in ROWS:
		var ids: Array = ranks.get(row_id, [])
		if typeof(ids) != TYPE_ARRAY:
			continue
		for raw in ids:
			var id: String = str(raw)
			if not _visible_card(id):
				continue
			placed[id] = true
			_row_hosts[row_id].add_child(_chip(id))
	for id2 in _catalog_ids():
		if placed.has(id2):
			continue
		if not _visible_card(id2):
			continue
		_pool.add_child(_chip(id2))


func _ranks_for(kind: String, tier: int) -> Dictionary:
	if not _ranks.has(kind):
		_ranks[kind] = {}
	var by_tier: Dictionary = _ranks[kind]
	if not by_tier.has(tier):
		var empty := {}
		for row_id in ROWS:
			empty[row_id] = []
		by_tier[tier] = empty
	return by_tier[tier]


func _catalog_ids() -> Array:
	var src: Dictionary = items_by_id if _kind == "item" else monsters_by_id
	var ids: Array = src.keys()
	ids.sort()
	return ids


func _visible_card(id: String) -> bool:
	var src: Dictionary = items_by_id if _kind == "item" else monsters_by_id
	var card: Dictionary = src.get(id, {})
	if card.is_empty():
		return false
	var st: String = str(card.get("status", "live"))
	if st == "hold" or st == "retired":
		return false
	if not BucketRules.counts_for_mill(card):
		return false
	if int(card.get("tier", 1)) != _tier:
		return false
	var b: int = BucketRules.of_card(card)
	if b < 0:
		return false
	return b <= _bucket_cap()


func _chip(id: String) -> RankChip:
	var src: Dictionary = items_by_id if _kind == "item" else monsters_by_id
	var card: Dictionary = src.get(id, {})
	var chip := RankChip.new()
	var icon: Texture2D = null
	if art != null:
		if _kind == "item" and art.has_method("item_tex"):
			icon = art.item_tex(id)
		elif _kind == "monster" and art.has_method("monster_still"):
			icon = art.monster_still(id)
	chip.setup(_kind, id, str(card.get("name", id)), icon)
	chip.hovered_card.connect(func() -> void: card_hovered.emit(_kind, id, chip))
	chip.unhovered_card.connect(func() -> void: card_unhovered.emit())
	return chip


func _on_drop(row_id: String, kind: String, card_id: String, insert_at: int) -> void:
	if kind != _kind:
		return
	var ranks: Dictionary = _ranks_for(_kind, _tier)
	for r in ROWS:
		var arr: Array = ranks.get(r, [])
		arr.erase(card_id)
		ranks[r] = arr
	if row_id != "_pool":
		var dest: Array = ranks.get(row_id, [])
		var at: int = clampi(insert_at, 0, dest.size())
		dest.insert(at, card_id)
		ranks[row_id] = dest
	_rebuild()


func _toggle(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_title_button(b, 160)
	b.pressed.connect(cb)
	return b


func _mark(b: Button, on: bool) -> void:
	if b == null:
		return
	b.set_pressed_no_signal(on)
	b.modulate = Color(1.12, 1.08, 0.95) if on else Color.WHITE


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_title_button(b, 180)
	b.pressed.connect(cb)
	return b


class RankRow extends VBoxContainer:
	signal dropped(row_id: String, kind: String, card_id: String, insert_at: int)
	var row_id: String = ""

	func _can_drop_data(_at: Vector2, data: Variant) -> bool:
		return typeof(data) == TYPE_DICTIONARY and str(data.get("playtest_rank", "")) == "1"

	func _drop_data(at: Vector2, data: Variant) -> void:
		if typeof(data) != TYPE_DICTIONARY:
			return
		var insert_at := get_child_count()
		for i in range(get_child_count()):
			var c: Control = get_child(i)
			if at.y < c.position.y + c.size.y * 0.5:
				insert_at = i
				break
		dropped.emit(row_id, str(data.get("kind", "")), str(data.get("id", "")), insert_at)


class RankChip extends PanelContainer:
	signal hovered_card
	signal unhovered_card
	var kind: String = ""
	var card_id: String = ""

	func setup(p_kind: String, p_id: String, title: String, icon: Texture2D) -> void:
		kind = p_kind
		card_id = p_id
		custom_minimum_size = Vector2(104, 136)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("2a1c14")
		sb.border_color = Color("c4a574")
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		add_theme_stylebox_override("panel", sb)
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 4)
		add_child(col)
		var name_l := Label.new()
		name_l.text = title
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_l.max_lines_visible = 2
		name_l.add_theme_font_size_override("font_size", 13)
		name_l.add_theme_color_override("font_color", Color("f0e6d8"))
		name_l.add_theme_color_override("font_outline_color", Color("100e0c"))
		name_l.add_theme_constant_override("outline_size", 2)
		name_l.custom_minimum_size = Vector2(92, 32)
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(name_l)
		var tex := TextureRect.new()
		tex.texture = icon
		tex.custom_minimum_size = Vector2(64, 64)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(tex)
		mouse_entered.connect(func() -> void: hovered_card.emit())
		mouse_exited.connect(func() -> void: unhovered_card.emit())

	func _get_drag_data(_at: Vector2) -> Variant:
		var preview := duplicate()
		preview.modulate = Color(1, 1, 1, 0.85)
		set_drag_preview(preview)
		return {"playtest_rank": "1", "kind": kind, "id": card_id}
