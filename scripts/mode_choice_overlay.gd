extends Control
class_name ModeChoiceOverlay
## Look H — cream mode panel above the starter hotbar seat (Knife / Net / Magnet).
## Theme/StyleBox + Labels + TextureRect + Tweens only. Not ItemCard clones.

signal option_picked(opt: Dictionary)
signal cancelled

const COL_CHOICE := Color("7CC8F0")
const COL_INK := Color("100e0c")
const COL_CREAM := Color("FDF6E3")
const COL_CREAM_HOT := Color("FFF8EA")
const COL_CREAM_PRESS := Color("EFE3C4")
const COL_PANEL_RIM := Color("2A2118")
const COL_TILE := Color("2C261C")
const COL_BADGE_THROW := Color("C41E1E")
const COL_BADGE_KEEP := Color("2F9E5B")
const COL_SCRIM := Color(0.06, 0.05, 0.04, 0.55)
const COL_KEY_BG := Color("FFFFFF")
const COL_PIP_ON := Color("100e0c")
const COL_PIP_OFF := Color("100e0c", 0.22)

const PANEL_W_KNIFE := 352.0
const PANEL_W_ROWS := 348.0
const TARGET_KNIFE := Vector2(158.0, 190.0)
const TARGET_ROW := Vector2(322.0, 62.0)
const GAP := 8.0
const PAD := 12.0
const CARET_H := 12.0
const ICON_TILE := 72.0
const ICON_ROW := 40.0

var _scrim: ColorRect
var _panel_host: Control
var _panel: PanelContainer
var _caret: TextureRect
var _body: VBoxContainer
var _title: Label
var _prompt: Label
var _targets_host: Control
var _options: Array = []
var _layout: String = "rows" ## "knife" | "rows"
var _icon_tex: Texture2D
var _anchor_global: Rect2 = Rect2()
var _appear_tw: Tween
var _badge_throw: Texture2D
var _badge_keep: Texture2D
var _caret_tex: Texture2D
var _pip_on_tex: Texture2D
var _pip_off_tex: Texture2D


func _ready() -> void:
	## Absolute z so this beats TakeArc (MoveBox is z 20 on Main). A relative
	## z loses that fight, and the click falls through onto Take.
	z_as_relative = false
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process_unhandled_input(true)
	gui_input.connect(_on_scrim_input)
	visible = false
	_badge_throw = _make_badge_tex(COL_BADGE_THROW, "throw")
	_badge_keep = _make_badge_tex(COL_BADGE_KEEP, "keep")
	_caret_tex = _make_caret_tex()
	_pip_on_tex = _make_pip_tex(true)
	_pip_off_tex = _make_pip_tex(false)
	_build_chrome()


func clear() -> void:
	visible = false
	_options.clear()
	if _appear_tw != null:
		_appear_tw.kill()
		_appear_tw = null
	if _targets_host != null:
		for c in _targets_host.get_children():
			_targets_host.remove_child(c)
			c.queue_free()
	if _panel_host != null:
		_panel_host.modulate = Color.WHITE
		_panel_host.scale = Vector2.ONE


## `layout`: "knife" (2 side-by-side) or "rows" (stacked Net / Magnet).
## `rows`: [{ "label": String, "opt": Dictionary, "badge": "throw"|"keep"|"", "pips": int }, ...]
func show_choice(title: String, prompt: String, layout: String, rows: Array, icon: Texture2D, starter_global: Rect2) -> void:
	if not is_inside_tree():
		return
	_layout = layout if layout == "knife" else "rows"
	_icon_tex = icon
	_anchor_global = starter_global
	_options.clear()
	for row_v in rows:
		if typeof(row_v) == TYPE_DICTIONARY:
			_options.append(row_v)
	if _options.is_empty():
		clear()
		return
	_ensure_built()
	_title.text = title
	_prompt.text = prompt
	_prompt.visible = prompt.strip_edges() != ""
	_rebuild_targets()
	_fill_viewport()
	_place_over_starter()
	visible = true
	_pulse_in()


func _fill_viewport() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 8.0 or vp.y < 8.0:
		return
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = vp
	if _scrim != null:
		_scrim.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_scrim.position = Vector2.ZERO
		_scrim.size = vp


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			_emit_cancel()
			get_viewport().set_input_as_handled()
			return
		var idx := -1
		if key.keycode == KEY_1 or key.keycode == KEY_KP_1:
			idx = 0
		elif key.keycode == KEY_2 or key.keycode == KEY_KP_2:
			idx = 1
		elif key.keycode == KEY_3 or key.keycode == KEY_KP_3:
			idx = 2
		if idx >= 0 and idx < _options.size():
			_pick_index(idx)
			get_viewport().set_input_as_handled()


func _build_chrome() -> void:
	_scrim = ColorRect.new()
	_scrim.name = "Scrim"
	_scrim.color = COL_SCRIM
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scrim.gui_input.connect(_on_scrim_input)
	add_child(_scrim)

	_panel_host = Control.new()
	_panel_host.name = "PanelHost"
	_panel_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_host.pivot_offset = Vector2(PANEL_W_KNIFE * 0.5, 40.0)
	add_child(_panel_host)

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _panel_style())
	_panel_host.add_child(_panel)

	_body = VBoxContainer.new()
	_body.name = "Body"
	_body.add_theme_constant_override("separation", 8)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_body)

	var head := HBoxContainer.new()
	head.name = "Head"
	head.add_theme_constant_override("separation", 10)
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_child(head)

	_title = Label.new()
	_title.name = "Title"
	_title.add_theme_font_size_override("font_size", 18)
	_title.add_theme_color_override("font_color", COL_INK)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_title)

	_prompt = Label.new()
	_prompt.name = "Prompt"
	_prompt.add_theme_font_size_override("font_size", 13)
	_prompt.add_theme_color_override("font_color", Color("100e0c", 0.62))
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_prompt)

	_targets_host = Control.new()
	_targets_host.name = "Targets"
	_targets_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_targets_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(_targets_host)

	_caret = TextureRect.new()
	_caret.name = "Caret"
	_caret.texture = _caret_tex
	_caret.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_caret.stretch_mode = TextureRect.STRETCH_KEEP
	_caret.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_caret.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caret.custom_minimum_size = Vector2(22.0, CARET_H)
	_panel_host.add_child(_caret)


func _ensure_built() -> void:
	if _scrim == null:
		_build_chrome()


func _panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_CREAM
	sb.border_color = COL_PANEL_RIM
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = PAD
	sb.content_margin_right = PAD
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	sb.shadow_color = Color(0.05, 0.04, 0.03, 0.35)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	return sb


func _target_style(fill: Color, rim: Color, rim_w: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = rim
	sb.set_border_width_all(rim_w)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb


func _rebuild_targets() -> void:
	for c in _targets_host.get_children():
		_targets_host.remove_child(c)
		c.queue_free()
	if _layout == "knife":
		var row := HBoxContainer.new()
		row.name = "KnifeRow"
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", int(GAP))
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_targets_host.custom_minimum_size = Vector2(PANEL_W_KNIFE - PAD * 2.0, TARGET_KNIFE.y)
		_targets_host.add_child(row)
		for i in _options.size():
			row.add_child(_make_knife_target(i, _options[i]))
	else:
		var col := VBoxContainer.new()
		col.name = "RowStack"
		col.add_theme_constant_override("separation", 6)
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var n: int = _options.size()
		_targets_host.custom_minimum_size = Vector2(PANEL_W_ROWS - PAD * 2.0, TARGET_ROW.y * float(n) + 6.0 * float(maxi(n - 1, 0)))
		_targets_host.add_child(col)
		for i2 in n:
			col.add_child(_make_row_target(i2, _options[i2]))


func _make_knife_target(index: int, row: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.name = "KnifeTarget%d" % index
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.custom_minimum_size = TARGET_KNIFE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM, COL_INK, 1))
	panel.mouse_entered.connect(func() -> void:
		panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM_HOT, COL_CHOICE, 3))
	)
	panel.mouse_exited.connect(func() -> void:
		panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM, COL_INK, 1))
	)
	panel.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			panel.accept_event()
			_pick_index(index)
	)

	## PanelContainer only lays out one child — content + key chip share this host.
	var host := Control.new()
	host.name = "TargetHost"
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(host)

	var wrap := VBoxContainer.new()
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.add_theme_constant_override("separation", 8)
	wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(wrap)

	var icon_host := Control.new()
	icon_host.custom_minimum_size = Vector2(ICON_TILE, ICON_TILE)
	icon_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wrap.add_child(icon_host)

	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tile_sb := StyleBoxFlat.new()
	tile_sb.bg_color = COL_TILE
	tile_sb.set_corner_radius_all(8)
	tile.add_theme_stylebox_override("panel", tile_sb)
	icon_host.add_child(tile)

	var icon := TextureRect.new()
	icon.texture = _icon_tex
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 8.0
	icon.offset_top = 8.0
	icon.offset_right = -8.0
	icon.offset_bottom = -8.0
	tile.add_child(icon)

	var badge_id: String = str(row.get("badge", ""))
	if badge_id != "":
		var badge := TextureRect.new()
		badge.texture = _badge_keep if badge_id == "keep" else _badge_throw
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP
		badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.custom_minimum_size = Vector2(28, 28)
		badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		badge.anchor_left = 1.0
		badge.anchor_top = 1.0
		badge.anchor_right = 1.0
		badge.anchor_bottom = 1.0
		badge.offset_left = -30.0
		badge.offset_top = -30.0
		badge.offset_right = -2.0
		badge.offset_bottom = -2.0
		icon_host.add_child(badge)

	var primary := Label.new()
	primary.text = str(row.get("primary", row.get("label", "?")))
	primary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	primary.add_theme_font_size_override("font_size", 22)
	primary.add_theme_color_override("font_color", COL_INK)
	primary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(primary)

	var secondary := Label.new()
	secondary.text = str(row.get("secondary", ""))
	secondary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	secondary.add_theme_font_size_override("font_size", 15)
	secondary.add_theme_color_override("font_color", COL_INK)
	secondary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	secondary.visible = secondary.text.strip_edges() != ""
	wrap.add_child(secondary)

	_add_key_chip(host, index + 1)
	return panel


func _make_row_target(index: int, row: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.name = "RowTarget%d" % index
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.custom_minimum_size = TARGET_ROW
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM, COL_INK, 1))
	panel.mouse_entered.connect(func() -> void:
		panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM_HOT, COL_CHOICE, 3))
	)
	panel.mouse_exited.connect(func() -> void:
		panel.add_theme_stylebox_override("panel", _target_style(COL_CREAM, COL_INK, 1))
	)
	panel.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			panel.accept_event()
			_pick_index(index)
	)

	## PanelContainer only lays out one child — content + key chip share this host.
	var host := Control.new()
	host.name = "TargetHost"
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(host)

	var row_box := HBoxContainer.new()
	row_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_box.add_theme_constant_override("separation", 10)
	row_box.alignment = BoxContainer.ALIGNMENT_CENTER
	row_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(row_box)

	var icon_host := Control.new()
	icon_host.custom_minimum_size = Vector2(ICON_ROW, ICON_ROW)
	icon_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_box.add_child(icon_host)

	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tile_sb := StyleBoxFlat.new()
	tile_sb.bg_color = COL_TILE
	tile_sb.set_corner_radius_all(6)
	tile.add_theme_stylebox_override("panel", tile_sb)
	icon_host.add_child(tile)

	var icon := TextureRect.new()
	icon.texture = _icon_tex
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 4.0
	icon.offset_top = 4.0
	icon.offset_right = -4.0
	icon.offset_bottom = -4.0
	tile.add_child(icon)

	var lab := Label.new()
	lab.text = str(row.get("label", "?"))
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 18)
	lab.add_theme_color_override("font_color", COL_INK)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row_box.add_child(lab)

	var pips_n: int = int(row.get("pips", 0))
	if pips_n > 0:
		var pips := HBoxContainer.new()
		pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pips.add_theme_constant_override("separation", 4)
		pips.alignment = BoxContainer.ALIGNMENT_CENTER
		row_box.add_child(pips)
		for p in range(3):
			var pip := TextureRect.new()
			pip.texture = _pip_on_tex if p < pips_n else _pip_off_tex
			pip.custom_minimum_size = Vector2(10, 10)
			pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pip.stretch_mode = TextureRect.STRETCH_KEEP
			pip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pips.add_child(pip)

	_add_key_chip(host, index + 1)
	return panel


func _add_key_chip(host: Control, n: int) -> void:
	## Plain Control + Label (not PanelContainer) so a free-positioned chip never
	## competes with PanelContainer's single-child layout on the target.
	var chip := Control.new()
	chip.name = "KeyChip"
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.custom_minimum_size = Vector2(18.0, 16.0)
	chip.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	chip.anchor_left = 1.0
	chip.anchor_top = 1.0
	chip.anchor_right = 1.0
	chip.anchor_bottom = 1.0
	chip.offset_left = -24.0
	chip.offset_top = -20.0
	chip.offset_right = -4.0
	chip.offset_bottom = -4.0
	var bg := Panel.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_KEY_BG
	sb.border_color = COL_INK
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	bg.add_theme_stylebox_override("panel", sb)
	chip.add_child(bg)
	var lab := Label.new()
	lab.text = str(n)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 12)
	lab.add_theme_color_override("font_color", COL_INK)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chip.add_child(lab)
	host.add_child(chip)


func _place_over_starter() -> void:
	if _panel_host == null:
		return
	var panel_w: float = PANEL_W_KNIFE if _layout == "knife" else PANEL_W_ROWS
	## Force a layout pass so size is known before anchoring.
	_panel.reset_size()
	var panel_h: float = _panel.get_combined_minimum_size().y
	if panel_h < 80.0:
		panel_h = (TARGET_KNIFE.y + 48.0) if _layout == "knife" else (_targets_host.custom_minimum_size.y + 48.0)
	var vp := get_viewport_rect().size
	var starter_mid_x: float = _anchor_global.position.x + _anchor_global.size.x * 0.5
	var x: float = starter_mid_x - panel_w * 0.5
	x = clampf(x, 12.0, maxf(12.0, vp.x - panel_w - 12.0))
	var y: float = _anchor_global.position.y - panel_h - CARET_H - 6.0
	y = maxf(8.0, y)
	_panel_host.position = Vector2(x, y)
	_panel_host.size = Vector2(panel_w, panel_h + CARET_H)
	_panel.position = Vector2.ZERO
	_panel.size = Vector2(panel_w, panel_h)
	_panel_host.pivot_offset = Vector2(panel_w * 0.5, panel_h)
	_caret.position = Vector2(panel_w * 0.5 - 11.0, panel_h - 1.0)
	_caret.size = Vector2(22.0, CARET_H)


## True when the cream panel (throw / nick / net rows) owns this click.
## Hotbar canvas hit-test must not steal these; the starter seat under the
## caret is still fair game for cancel.
func hits_choice_panel(global_pos: Vector2) -> bool:
	if not visible:
		return false
	if _panel != null and _panel.is_inside_tree() and _panel.get_global_rect().has_point(global_pos):
		return true
	if _targets_host != null and _targets_host.is_inside_tree() and _targets_host.get_global_rect().has_point(global_pos):
		return true
	return false


func _pulse_in() -> void:
	if _panel_host == null:
		return
	if _appear_tw != null:
		_appear_tw.kill()
	_panel_host.modulate = Color(1, 1, 1, 0)
	_panel_host.scale = Vector2(0.94, 0.94)
	_appear_tw = create_tween()
	_appear_tw.set_parallel(true)
	_appear_tw.tween_property(_panel_host, "modulate:a", 1.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_appear_tw.tween_property(_panel_host, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _scrim != null:
		_scrim.modulate = Color(1, 1, 1, 0)
		_appear_tw.tween_property(_scrim, "modulate:a", 1.0, 0.12)


func _on_scrim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		## Clicks on the starter seat (visible through scrim) still cancel — same as X.
		_emit_cancel()
		accept_event()


func _pick_index(index: int) -> void:
	if index < 0 or index >= _options.size():
		return
	var row: Dictionary = _options[index]
	var opt: Dictionary = row.get("opt", {}) if typeof(row.get("opt", {})) == TYPE_DICTIONARY else {}
	visible = false
	option_picked.emit(opt)


func _emit_cancel() -> void:
	visible = false
	cancelled.emit()


func _make_badge_tex(fill: Color, kind: String) -> Texture2D:
	var s := 28
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := (s - 1) * 0.5
	var cy := (s - 1) * 0.5
	var r := 12.0
	for y in s:
		for x in s:
			var dx := float(x) - cx
			var dy := float(y) - cy
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(x, y, fill)
			if dx * dx + dy * dy <= (r - 1.0) * (r - 1.0):
				## keep fill
				pass
	## Glyph in white.
	if kind == "throw":
		## Three speed dashes.
		for i in 3:
			var yy := 9 + i * 4
			for xx in range(8, 20):
				if yy >= 0 and yy < s:
					img.set_pixel(xx, yy, Color.WHITE)
					if yy + 1 < s:
						img.set_pixel(xx, yy + 1, Color.WHITE)
	else:
		## Simple U-turn: left stem, top arc, right hook.
		for yy in range(8, 20):
			img.set_pixel(9, yy, Color.WHITE)
			img.set_pixel(10, yy, Color.WHITE)
		for xx in range(9, 19):
			img.set_pixel(xx, 8, Color.WHITE)
			img.set_pixel(xx, 9, Color.WHITE)
		for yy2 in range(8, 16):
			img.set_pixel(18, yy2, Color.WHITE)
			img.set_pixel(19, yy2, Color.WHITE)
		img.set_pixel(17, 15, Color.WHITE)
		img.set_pixel(16, 16, Color.WHITE)
		img.set_pixel(15, 17, Color.WHITE)
		img.set_pixel(20, 15, Color.WHITE)
		img.set_pixel(21, 16, Color.WHITE)
	var tex := ImageTexture.create_from_image(img)
	return tex


func _make_caret_tex() -> Texture2D:
	var w := 22
	var h := 12
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in h:
		var half := int(round(float(y + 1) * float(w) / float(h) * 0.5))
		var x0 := w / 2 - half
		var x1 := w / 2 + half
		for x in range(maxi(x0, 0), mini(x1 + 1, w)):
			## Cream fill with dark tip outline.
			var edge := x == x0 or x == x1 or y == h - 1
			img.set_pixel(x, y, COL_PANEL_RIM if edge else COL_CREAM)
	return ImageTexture.create_from_image(img)


func _make_pip_tex(on: bool) -> Texture2D:
	var s := 10
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var col := COL_PIP_ON if on else COL_PIP_OFF
	var cx := (s - 1) * 0.5
	var cy := (s - 1) * 0.5
	var r := 3.6
	for y in s:
		for x in s:
			var dx := float(x) - cx
			var dy := float(y) - cy
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)
