extends Control
## Own screen after a dungeon ends, before the next one is seated.
## The wheel, hand, and inspect panel stay hidden while this is up.
## Hover opens the same fight callout as the wheel and the hotbar.

signal finished
signal card_hovered(kind: String, card_id: String, slot: Control)
signal card_unhovered

const COPY := preload("res://scripts/player_copy.gd")

var sfx = null
var _go: bool = false
var _playing: bool = false
var _t: float = 0.0
var _fitted: Vector2 = Vector2(-1, -1)
var _title
var _sub
var _loot_head
var _foe_head
var _loot_grids: Array = []
var _foe_grids: Array = []
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
	if size != _fitted:
		_fit_cards()
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

	_title = FitLabelBox.make()
	_title.show_frame = false
	_title.padding = 0
	_title.max_font_size = 40
	_title.min_font_size = 16
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.custom_minimum_size = Vector2(640, 52)
	_title.font_color = Color("f0d78a")
	col.add_child(_title)

	_sub = FitLabelBox.make()
	_sub.show_frame = false
	_sub.padding = 0
	_sub.max_font_size = 20
	_sub.min_font_size = 16
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.custom_minimum_size = Vector2(640, 32)
	_sub.font_color = Color("e6d7c4")
	col.add_child(_sub)

	var halves := HBoxContainer.new()
	halves.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	halves.size_flags_vertical = Control.SIZE_EXPAND_FILL
	halves.add_theme_constant_override("separation", 28)
	col.add_child(halves)
	var loot_side := _half()
	halves.add_child(loot_side["side"])
	_loot_head = loot_side["head"]
	_loot_head.set_plain(COPY.text("bucket.loot", "Loot"))
	_loot_grids = loot_side["grids"]
	var split := ColorRect.new()
	split.custom_minimum_size = Vector2(2, 0)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.color = Color(0.91, 0.72, 0.32, 0.22)
	split.mouse_filter = Control.MOUSE_FILTER_IGNORE
	halves.add_child(split)
	var foe_side := _half()
	halves.add_child(foe_side["side"])
	_foe_head = foe_side["head"]
	_foe_head.set_plain(COPY.text("bucket.foes", "Foes"))
	_foe_grids = foe_side["grids"]

	var bar := CenterContainer.new()
	col.add_child(bar)
	_next = FitButton.new()
	_next.max_font_size = 26
	_next.min_font_size = 16
	_next.text = COPY.text("bucket.onward", "Onward")
	_next.custom_minimum_size = Vector2(240, 64)
	_next.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_next.add_theme_font_size_override("font_size", 26)
	_next.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_paint_button(_next)
	_next.pressed.connect(_on_next)
	bar.add_child(_next)


func _section(text: String) -> Control:
	var l: FitLabelBox = FitLabelBox.make()
	l.show_frame = false
	l.padding = 0
	l.max_font_size = 18
	l.min_font_size = 12
	l.set_plain(text)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.font_color = Color("c4a574")
	l.custom_minimum_size = Vector2(240, 24)
	return l


func _half() -> Dictionary:
	var side := VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var head := _section("")
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.add_child(head)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.alignment = BoxContainer.ALIGNMENT_BEGIN
	stack.add_theme_constant_override("separation", 16)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side.add_child(stack)
	var grids: Array = []
	for _t in range(3):
		var band := VBoxContainer.new()
		band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		band.add_theme_constant_override("separation", 0)
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var grid := _row()
		band.add_child(_center(grid))
		stack.add_child(band)
		grids.append(grid)
	return {"side": side, "head": head, "grids": grids}


func _row() -> GridContainer:
	var row := GridContainer.new()
	row.columns = 1
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 8)
	return row


func _center(row: GridContainer) -> CenterContainer:
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
	_title.text = COPY.text("bucket.title", "As you venture deeper, new Loot and Foes reveal themselves.")
	_sub.text = COPY.text("bucket.sub", "Hover a shadow to see what it is. From now on, these can show up in every dungeon.")
	_title.modulate.a = 0.0
	_sub.modulate.a = 0.0
	_next.disabled = true
	_next.modulate.a = 0.0
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
	cards.append_array(_fill_tiers(_loot_grids, loot, bucket_n))
	cards.append_array(_fill_tiers(_foe_grids, foes, bucket_n))
	_fitted = Vector2(-1, -1)
	_fit_cards()
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
	card_unhovered.emit()
	finished.emit()


func _fit() -> void:
	var vp: Vector2 = get_viewport_rect().size
	global_position = Vector2.ZERO
	size = vp


func card_controls() -> Array:
	var out: Array = []
	for grids in [_loot_grids, _foe_grids]:
		for grid in grids:
			if not (grid is GridContainer):
				continue
			for child in (grid as GridContainer).get_children():
				if child is Control:
					out.append(child)
	return out


func _fill_tiers(grids: Array, entries: Array, bucket_n: int) -> Array:
	var by_tier := {1: [], 2: [], 3: []}
	for entry in entries:
		var tier_n: int = clampi(int(entry.get("tier", 1)), 1, 3)
		(by_tier[tier_n] as Array).append(entry)
	var cards: Array = []
	for tier_n in [1, 2, 3]:
		var grid: GridContainer = grids[tier_n - 1]
		_clear_row(grid)
		var list: Array = by_tier[tier_n]
		var band: Node = grid.get_parent().get_parent()
		if band is CanvasItem:
			(band as CanvasItem).visible = not list.is_empty()
		for entry2 in list:
			cards.append(_make_card(grid, entry2, bucket_n))
	return cards


func _clear_row(row: GridContainer) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.free()


func _make_card(row: GridContainer, entry: Dictionary, bucket_n: int) -> Dictionary:
	var extra: bool = bool(entry.get("extra", false))
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(96, 96)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if extra:
		slot.modulate = Color(0.78, 0.78, 0.78, 1)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("100c0a")
	sb.border_color = BucketRules.color_of(bucket_n).darkened(0.35)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	slot.add_theme_stylebox_override("panel", sb)
	slot.set_meta("edge", sb)
	slot.set_meta("open", false)
	var tex_rect := TextureRect.new()
	tex_rect.texture = entry.get("tex", null)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex_rect.custom_minimum_size = Vector2(72, 72)
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex_rect.modulate = Color(0, 0, 0, 1)
	slot.add_child(tex_rect)
	var name := Label.new()
	name.text = str(entry.get("name", ""))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.clip_text = true
	name.custom_minimum_size = Vector2(72, 28)
	name.add_theme_font_size_override("font_size", 14)
	name.add_theme_color_override("font_color", Color("f4ede3"))
	name.modulate.a = 0.0
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wrap := VBoxContainer.new()
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.add_theme_constant_override("separation", 4)
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	wrap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	wrap.add_child(slot)
	wrap.add_child(name)
	wrap.set_meta("panel", slot)
	wrap.set_meta("tex", tex_rect)
	wrap.set_meta("name", name)
	wrap.set_meta("extra", extra)
	row.add_child(wrap)
	wrap.mouse_entered.connect(_on_card_enter.bind(slot, tex_rect, name, entry))
	wrap.mouse_exited.connect(_on_card_exit.bind(slot, bucket_n))
	return {"slot": wrap, "tex": tex_rect, "name": name}


func _on_card_enter(slot: PanelContainer, tex_rect: TextureRect, name: Label, entry: Dictionary) -> void:
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
	card_hovered.emit(str(entry.get("kind", "")), str(entry.get("id", "")), slot)
	if sfx != null and sfx.has_method("play_event"):
		sfx.play_event(&"bucket.card_hover")


func _on_card_exit(slot: PanelContainer, bucket_n: int) -> void:
	if bool(slot.get_meta("open", false)):
		var edge: StyleBoxFlat = slot.get_meta("edge")
		edge.border_color = BucketRules.color_of(bucket_n)
		slot.add_theme_stylebox_override("panel", edge)
	card_unhovered.emit()


func _fit_cards() -> void:
	_fitted = size
	# 56px margins, a 2px divider, and the 28px gap between the halves.
	var half_w: float = maxf(220.0, (size.x - 142.0) * 0.5)
	var stack_h: float = maxf(220.0, size.y - 300.0)
	var widest: int = 1
	var row_n: int = 1
	for grids in [_loot_grids, _foe_grids]:
		var active: int = 0
		for grid in grids:
			if not (grid is GridContainer):
				continue
			var n: int = (grid as GridContainer).get_child_count()
			if n > 0:
				active += 1
				widest = maxi(widest, n)
		row_n = maxi(row_n, active)
	var tile: float = _tile_for(half_w, stack_h, widest, row_n)
	var spread: int = _row_spread(stack_h, row_n, tile)
	for grids2 in [_loot_grids, _foe_grids]:
		_apply_tile(grids2, tile)
		_spread_rows(grids2, spread)


func _tile_for(half_w: float, stack_h: float, widest: int, row_n: int) -> float:
	var sep := 14.0
	var vsep := 16.0
	var name_h := 30.0
	var cols: int = maxi(widest, 1)
	var rows: int = maxi(row_n, 1)
	var from_w: float = (half_w - sep * float(cols - 1)) / float(cols)
	var row_room: float = (stack_h - vsep * float(rows - 1)) / float(rows)
	var from_h: float = row_room - 4.0 - name_h
	return clampf(minf(from_w, from_h), 72.0, 176.0)


func _row_spread(stack_h: float, row_n: int, tile: float) -> int:
	var rows: int = maxi(row_n, 1)
	if rows < 2:
		return 18
	var name_h: float = 32.0 if tile >= 120.0 else 26.0
	var art: float = clampf(tile - 16.0, 52.0, 148.0)
	var block: float = art + 16.0 + 4.0 + name_h
	var slack: float = stack_h - block * float(rows)
	return int(clampf(slack / float(rows - 1), 18.0, 84.0))


func _spread_rows(grids: Array, spread: int) -> void:
	for grid in grids:
		if not (grid is GridContainer):
			continue
		var band: Node = (grid as GridContainer).get_parent().get_parent()
		if band == null:
			continue
		var stack: Node = band.get_parent()
		if stack is BoxContainer:
			(stack as BoxContainer).add_theme_constant_override("separation", spread)
		return


func _apply_tile(grids: Array, tile: float) -> void:
	var name_h: float = 32.0 if tile >= 120.0 else 26.0
	var art: float = clampf(tile - 16.0, 52.0, 148.0)
	var panel: float = art + 16.0
	var font_px: int = 16 if tile >= 130.0 else (14 if tile >= 100.0 else 12)
	for grid in grids:
		if not (grid is GridContainer):
			continue
		var row: GridContainer = grid
		var n: int = row.get_child_count()
		row.columns = maxi(n, 1)
		for child in row.get_children():
			if not (child is VBoxContainer):
				continue
			var wrap: VBoxContainer = child
			var panel_node: PanelContainer = wrap.get_meta("panel")
			var tex_rect: TextureRect = wrap.get_meta("tex")
			var name: Label = wrap.get_meta("name")
			panel_node.custom_minimum_size = Vector2(tile, panel)
			tex_rect.custom_minimum_size = Vector2(art, art)
			name.custom_minimum_size = Vector2(tile, name_h)
			name.add_theme_font_size_override("font_size", font_px)
			wrap.custom_minimum_size = Vector2(tile, panel + 4.0 + name_h)


func _on_next() -> void:
	if _next.disabled:
		return
	_go = true
