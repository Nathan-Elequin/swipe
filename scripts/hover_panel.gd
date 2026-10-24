extends PanelContainer
## Punchy inspect plate. Item equations and monster copy share this language.
## Keyword sub-tooltips (Always, Flee, …) are small capsules docked to this callout.

const COPY := preload("res://scripts/player_copy.gd")
const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")

signal edit_pressed(kind: String, card_id: String)

var _skinned: bool = false
var _skin_tex: Texture2D
var _on_dark: bool = false
var edit_kind: String = ""
var edit_id: String = ""
## Last inspect payload. Logic QA reads this; the player never sees it.
var last_shown: Dictionary = {}
## Face plaque accepts right-click. Fly tips stay click-through so hover does not trap the mouse.
var accept_clicks: bool = false
var _kw_tip: PanelContainer
var _pin_always: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(252, 0)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	gui_input.connect(_on_gui)
	if not _skinned:
		_plain_skin()
	_kw_tip = KEYWORD_TIP.new()
	add_child(_kw_tip)
	_kw_tip.setup()


func apply_skin(tex: Texture2D) -> void:
	_skinned = true
	_skin_tex = tex
	if tex == null:
		_plain_skin()
		return
	if _on_dark:
		return
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 14
	sb.texture_margin_right = 14
	sb.texture_margin_top = 12
	sb.texture_margin_bottom = 14
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	add_theme_stylebox_override("panel", sb)


func _plain_skin() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410f5")
	sb.border_color = Color("e8c36a")
	sb.border_width_left = 4
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	add_theme_stylebox_override("panel", sb)


## Same drawing as the wheel seat, at 1×, 2×, 3×, or 4× so pixels stay even.
## The 56×62 row stays put when the sprite fits. A taller sprite may grow that row.
func _crisp_monster_portrait(portrait: Texture2D) -> Control:
	var tw: int = maxi(1, portrait.get_width())
	var th: int = maxi(1, portrait.get_height())
	var box := Vector2i(56, 62)
	var scale := 1
	for step in [4, 3, 2, 1]:
		if tw * step <= box.x and th * step <= box.y:
			scale = step
			break
	var disp := Vector2(tw * scale, th * scale)
	var slot := CenterContainer.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.custom_minimum_size = Vector2(maxf(float(box.x), disp.x), maxf(float(box.y), disp.y))
	var pic := TextureRect.new()
	pic.texture = portrait
	pic.texture_filter = TEXTURE_FILTER_NEAREST
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = disp
	pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	pic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(pic)
	return slot


func show_placeholder() -> void:
	if OS.has_feature("editor"):
		show_text(COPY.text("inspect.title", "Inspect"), COPY.text("inspect.placeholder", "Hover an owner on the ring, or loot in your hand. Right-click to edit."))
	elif PLAYTEST_FLAG.on():
		show_text(COPY.text("inspect.title", "Inspect"), COPY.text("playtest.right_click_hint", "Right-click any item or monster to leave a comment."))
	else:
		show_text(COPY.text("inspect.title", "Inspect"), COPY.text("inspect.idle", "Hover an owner on the ring, or loot in your hand."))


func show_text(title: String, body: String, extra: String = "") -> void:
	show_rule(title, extra, "", body)


func show_rule(
	title: String,
	value_line: String,
	equation: String,
	body: String,
	warn: String = "",
	portrait: Texture2D = null,
	p_kind: String = "",
	p_id: String = "",
	look: Dictionary = {},
	journal: Dictionary = {}
) -> void:
	edit_kind = p_kind
	edit_id = p_id
	title = COPY.apply_names(title)
	value_line = COPY.apply_names(value_line)
	equation = COPY.apply_names(equation)
	body = COPY.apply_names(body)
	warn = COPY.apply_names(warn)
	# Shift puts the explainer on the item card. Hover shows the ability sentence only.
	if p_kind == "item":
		equation = ""
	last_shown = {
		"title": title,
		"value": value_line,
		"equation": equation,
		"call_chip": str(look.get("call_chip", "")),
		"body": body,
		"warn": warn,
		"kind": p_kind,
		"id": p_id,
	}
	_apply_look(look)
	_wipe()
	mouse_filter = Control.MOUSE_FILTER_STOP if accept_clicks and p_id != "" else Control.MOUSE_FILTER_IGNORE
	var ink: Color = Color("f0e6d8") if _on_dark else Color("1c120c")
	var ink_out: Color = Color("1c120c") if _on_dark else Color("f3e6d0")
	var body_col: Color = Color("e8dcc8") if _on_dark else Color("2a1c14")
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(col)
	if bool(look.get("stage_card", false)):
		_fill_stage_card(col, title, body, ink, look)
		visible = true
		custom_minimum_size = Vector2(340, 0)
		reset_size()
		size.x = 340
		return
	var center_copy: bool = p_kind == "monster"
	var drop: float = float(look.get("title_drop", 0.0))
	if drop > 1.0:
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, drop)
		gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(gap)
	if portrait != null:
		if p_kind == "monster":
			col.add_child(_crisp_monster_portrait(portrait))
		else:
			var pic := TextureRect.new()
			pic.texture = portrait
			pic.custom_minimum_size = Vector2(56, 62)
			pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			pic.texture_filter = TEXTURE_FILTER_NEAREST
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(pic)
	var t: FitLabelBox = FitLabelBox.make()
	t.show_frame = false
	t.padding = 0
	t.max_font_size = 22
	t.min_font_size = 16
	t.set_plain(title)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.font_color = ink
	t.set_outline(ink_out, 3 if _on_dark else 2)
	t.custom_minimum_size = Vector2(216, 28)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(t)
	var rank: String = str(look.get("rank", "")).strip_edges()
	if rank != "":
		var rk := Label.new()
		rk.text = rank
		rk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rk.add_theme_font_size_override("font_size", 12)
		rk.add_theme_color_override("font_color", Color("c4a574") if _on_dark else Color("6a5a48"))
		rk.add_theme_color_override("font_outline_color", Color("100e0c"))
		rk.add_theme_constant_override("outline_size", 3)
		rk.custom_minimum_size = Vector2(216, 0)
		rk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(rk)
	var badge_hp: String = str(look.get("hp_n", "")).strip_edges()
	var badge_atk: String = str(look.get("atk_n", "")).strip_edges()
	if center_copy and badge_hp != "" and badge_atk != "":
		col.add_child(_wheel_stat_row(badge_hp, badge_atk, int(look.get("stat_style", 0))))
	elif value_line != "":
		var e := RichTextLabel.new()
		e.bbcode_enabled = true
		e.fit_content = true
		e.scroll_active = false
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center_copy else HORIZONTAL_ALIGNMENT_LEFT
		e.add_theme_font_size_override("normal_font_size", 22)
		e.add_theme_font_size_override("bold_font_size", 24)
		e.add_theme_color_override("default_color", ink)
		e.text = value_line
		e.custom_minimum_size = Vector2(216, 0)
		e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_wire_kw(e)
		col.add_child(e)
	var call_chip: String = str(look.get("call_chip", "")).strip_edges()
	if call_chip != "":
		var call_col := Color("e8c36a")
		var raw_col: Variant = look.get("call_color", call_col)
		if raw_col is Color:
			call_col = raw_col
		var medal: Texture2D = null
		var raw_medal: Variant = look.get("medal", null)
		if raw_medal is Texture2D:
			medal = raw_medal
		col.add_child(_call_chip(call_chip, call_col, medal))
	if equation != "":
		var eq := RichTextLabel.new()
		eq.bbcode_enabled = true
		eq.fit_content = true
		eq.scroll_active = false
		eq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		eq.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center_copy else HORIZONTAL_ALIGNMENT_LEFT
		eq.add_theme_font_size_override("normal_font_size", 18)
		eq.add_theme_color_override("default_color", ink)
		eq.text = equation
		eq.custom_minimum_size = Vector2(216, 0)
		eq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_wire_kw(eq)
		col.add_child(eq)
	if bool(look.get("unplayable", false)):
		col.add_child(_unplayable_chip())
	if body != "":
		var b := RichTextLabel.new()
		b.bbcode_enabled = true
		b.fit_content = true
		b.scroll_active = false
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.meta_underlined = false
		var body_size: int = 13 if not journal.is_empty() else 15
		b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center_copy else HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("normal_font_size", body_size)
		b.add_theme_font_size_override("bold_font_size", body_size)
		b.add_theme_color_override("default_color", Color("6e5434") if not journal.is_empty() else body_col)
		b.text = body
		b.custom_minimum_size = Vector2(216, 0)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_wire_kw(b)
		col.add_child(b)
	_pin_always = false
	if _kw_tip != null and _kw_tip.has_method("hide_def"):
		_kw_tip.hide_def()
	if warn != "":
		var w := Label.new()
		w.text = warn
		w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center_copy else HORIZONTAL_ALIGNMENT_LEFT
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		w.add_theme_font_size_override("font_size", 15)
		var flee_def: bool = warn.strip_edges().to_lower().begins_with("flee")
		if flee_def:
			w.add_theme_color_override("font_color", Color("e8c36a"))
		else:
			w.add_theme_color_override("font_color", Color("f0a0a0") if _on_dark else Color("8b1e1e"))
		w.custom_minimum_size = Vector2(216, 0)
		w.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(w)
	var hint: String = str(look.get("hint", ""))
	if hint != "":
		var h := RichTextLabel.new()
		h.bbcode_enabled = true
		h.fit_content = true
		h.scroll_active = false
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_theme_font_size_override("normal_font_size", 12)
		h.add_theme_font_size_override("italics_font_size", 12)
		h.add_theme_color_override("default_color", Color("8a8278"))
		h.text = "[i]%s[/i]" % hint
		h.custom_minimum_size = Vector2(216, 0)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(h)
	var journal_body: String = COPY.apply_names(str(journal.get("body", "")).strip_edges())
	if journal_body != "":
		var rule := ColorRect.new()
		rule.custom_minimum_size = Vector2(216, 1)
		rule.color = Color("a8946c")
		rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(rule)
		var jh := Label.new()
		jh.text = COPY.text("cabin.tip.journal", "")
		jh.add_theme_font_size_override("font_size", 12)
		jh.add_theme_color_override("font_color", Color("6e5434"))
		jh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(jh)
		var jb := Label.new()
		jb.text = journal_body
		jb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		jb.add_theme_font_size_override("font_size", 15)
		jb.add_theme_color_override("font_color", ink)
		jb.custom_minimum_size = Vector2(216, 0)
		jb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(jb)
		for fn in journal.get("footnotes", []):
			var fl := Label.new()
			fl.text = COPY.apply_names(str(fn))
			fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			fl.add_theme_font_size_override("font_size", 12)
			fl.add_theme_color_override("font_color", Color("7a6a48"))
			fl.custom_minimum_size = Vector2(216, 0)
			fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(fl)
	if bool(journal.get("is_new", false)):
		var nw := Label.new()
		nw.text = COPY.text("cabin.tip.new", "")
		nw.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		nw.add_theme_font_size_override("font_size", 14)
		nw.add_theme_color_override("font_color", Color("c45c5c"))
		nw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(nw)
	visible = true
	reset_size()


## Same heart and sword the wheel draws, with the number on the icon. Centered as a pair.
func _wheel_stat_row(hp: String, atk: String, style: int) -> Control:
	var slot := CenterContainer.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 28)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var heart := WheelStatBadge.new()
	heart.is_heart = true
	heart.num_text = hp
	heart.style = style
	var sword := WheelStatBadge.new()
	sword.is_heart = false
	sword.num_text = atk
	sword.style = style
	row.add_child(heart)
	row.add_child(sword)
	slot.add_child(row)
	return slot


func _call_chip(text: String, col: Color, medal: Texture2D) -> Control:
	var slot := CenterContainer.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var chip := Control.new()
	chip.name = "CallChip"
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var font: Font = ThemeDB.fallback_font
	var fs := 16
	var medal_span := 50.0
	var right_pad := 16.0
	var max_w := 216.0
	var text_limit := max_w - medal_span - right_pad
	if font != null:
		while fs > 11 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > text_limit:
			fs -= 1
	var text_w := text_limit
	if font != null:
		text_w = minf(text_limit, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	chip.custom_minimum_size = Vector2(medal_span + text_w + right_pad, 48.0)
	chip.set_meta("call_text", text)
	chip.set_meta("call_color", col)
	chip.set_meta("call_fs", fs)
	if medal != null:
		chip.set_meta("medal", medal)
	chip.draw.connect(_paint_call_chip.bind(chip))
	slot.add_child(chip)
	return slot


func _paint_call_chip(chip: Control) -> void:
	var rect := Rect2(Vector2.ZERO, chip.size)
	if rect.size.x < 8.0 or rect.size.y < 8.0:
		return
	_paint_pill(chip, rect, Color(0.08, 0.06, 0.05, 0.94), Color("e8c36a"))
	var medal_px := 28.0
	var center := Vector2(26.0, rect.size.y * 0.5)
	var ring: float = medal_px * 0.62
	chip.draw_circle(center, ring + 1.5, Color("1a120e"))
	chip.draw_arc(center, ring + 1.5, 0.0, TAU, 28, Color("c4a574"), 3.0, true)
	var medal: Variant = chip.get_meta("medal", null)
	if medal is Texture2D:
		var mdest := Rect2(center - Vector2(medal_px, medal_px) * 0.5, Vector2(medal_px, medal_px))
		chip.draw_texture_rect(medal, mdest, false)
	var text: String = str(chip.get_meta("call_text", ""))
	var col: Color = chip.get_meta("call_color", Color("e8c36a"))
	var fs: int = int(chip.get_meta("call_fs", 16))
	var font: Font = chip.get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	if font == null or text == "":
		return
	var baseline: float = (rect.size.y - font.get_height(fs)) * 0.5 + font.get_ascent(fs)
	var origin := Vector2(50.0, baseline)
	var ink := Color("100e0c")
	for ox in range(-2, 3):
		for oy in range(-2, 3):
			if ox == 0 and oy == 0:
				continue
			chip.draw_string(font, origin + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	chip.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _paint_pill(chip: Control, rect: Rect2, fill: Color, edge: Color) -> void:
	var rr: float = rect.size.y * 0.5
	var y: float = rect.position.y + rr
	var x0: float = rect.position.x + rr
	var x1: float = rect.position.x + rect.size.x - rr
	if x1 < x0:
		var c := Vector2(rect.get_center().x, y)
		chip.draw_circle(c, rr, fill)
		chip.draw_arc(c, rr, 0.0, TAU, 24, edge, 1.6, true)
		return
	chip.draw_circle(Vector2(x0, y), rr, fill)
	chip.draw_circle(Vector2(x1, y), rr, fill)
	chip.draw_rect(Rect2(x0, rect.position.y, x1 - x0, rect.size.y), fill, true)
	chip.draw_arc(Vector2(x0, y), rr, PI * 0.5, PI * 1.5, 16, edge, 1.6, true)
	chip.draw_arc(Vector2(x1, y), rr, -PI * 0.5, PI * 0.5, 16, edge, 1.6, true)
	chip.draw_line(Vector2(x0, rect.position.y), Vector2(x1, rect.position.y), edge, 1.6, true)
	chip.draw_line(Vector2(x0, rect.position.y + rect.size.y), Vector2(x1, rect.position.y + rect.size.y), edge, 1.6, true)


func _unplayable_chip() -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(216, 28)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	box.clip_contents = true
	box.draw.connect(func() -> void:
		var w: float = box.size.x
		var h: float = box.size.y
		if w < 2.0 or h < 2.0:
			return
		box.draw_rect(Rect2(0, 0, w, h), Color("3d3a38"))
		var ink := Color(0.22, 0.20, 0.19, 0.55)
		var x: float = -h
		while x < w + h:
			box.draw_line(Vector2(x, h), Vector2(x + h * 0.62, 0.0), ink, 1.0)
			x += 5.0
		box.draw_rect(Rect2(0.5, 0.5, w - 1.0, h - 1.0), Color("6a6560"), false, 1.0)
	)
	box.resized.connect(box.queue_redraw)
	var lab := Label.new()
	lab.text = "Unplayable"
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lab.add_theme_font_size_override("font_size", 15)
	lab.add_theme_color_override("font_color", Color("cfc8c0"))
	lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	lab.add_theme_constant_override("outline_size", 3)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(lab)
	box.mouse_entered.connect(func() -> void:
		if _kw_tip != null and _kw_tip.has_method("show_def"):
			_kw_tip.show_def(UxStyle.def_of("unplayable"), self, "unplayable")
	)
	box.mouse_exited.connect(func() -> void:
		if _kw_tip != null and _kw_tip.has_method("hide_def"):
			_kw_tip.hide_def()
	)
	return box


func _wire_kw(rtl: RichTextLabel) -> void:
	if rtl == null:
		return
	rtl.focus_mode = Control.FOCUS_NONE
	if str(rtl.text).find("[url=") >= 0:
		rtl.mouse_filter = Control.MOUSE_FILTER_STOP
		UxStyle.wire_def_hover(rtl, _kw_tip, self)
	else:
		rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE


func pin_always_def() -> void:
	if not _pin_always or _kw_tip == null or not _kw_tip.has_method("show_def"):
		return
	_kw_tip.show_def(UxStyle.def_of("always"), self, "always")


func hide_plate() -> void:
	visible = false
	edit_kind = ""
	edit_id = ""
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin_always = false
	if _kw_tip != null and _kw_tip.has_method("hide_def"):
		_kw_tip.hide_def()
	_apply_look({})


func _on_gui(event: InputEvent) -> void:
	if not accept_clicks or edit_id == "":
		return
	if not OS.has_feature("editor") and not PLAYTEST_FLAG.on():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		edit_pressed.emit(edit_kind, edit_id)
		accept_event()


func _apply_look(look: Dictionary) -> void:
	var metal: Color = look.get("metal", Color(0, 0, 0, 0))
	if metal.a < 0.08:
		_on_dark = false
		if _skin_tex != null:
			apply_skin(_skin_tex)
		else:
			_plain_skin()
		return
	_on_dark = true
	_skinned = true
	var fill: Color = look.get("fill", Color("5c2626"))
	var tier: int = int(look.get("tier", 1))
	var scary: bool = bool(look.get("scary", false))
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = metal
	var bw: int = 3
	if tier == 2:
		bw = 4
	elif tier >= 3:
		bw = 5
	sb.set_border_width_all(bw)
	if scary:
		if tier >= 3:
			sb.set_corner_radius_all(2)
			sb.border_width_left = bw + 4
			sb.shadow_color = Color(0.72, 0.08, 0.06, 0.62)
			sb.shadow_size = 16
		elif tier == 2:
			sb.set_corner_radius_all(6)
			sb.border_width_left = bw + 2
			sb.shadow_color = Color(0.42, 0.12, 0.28, 0.5)
			sb.shadow_size = 10
		else:
			sb.set_corner_radius_all(10)
			sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.42)
			sb.shadow_size = 5
	else:
		sb.set_corner_radius_all(10)
		sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.5)
		sb.shadow_size = 8 if tier >= 3 else (5 if tier == 2 else 3)
	sb.shadow_offset = Vector2.ZERO
	var stage: bool = bool(look.get("stage_card", false))
	var pad: int = int(look.get("stage_pad", 0))
	sb.content_margin_left = 16 if stage else 18
	sb.content_margin_right = 16 if stage else 18
	sb.content_margin_top = (8 + pad) if stage else 14
	sb.content_margin_bottom = 12 if stage else 14
	add_theme_stylebox_override("panel", sb)


func _wipe() -> void:
	for c in get_children():
		if c == _kw_tip:
			continue
		remove_child(c)
		c.queue_free()


func _fill_stage_card(col: VBoxContainer, title: String, body: String, ink: Color, look: Dictionary) -> void:
	col.add_theme_constant_override("separation", 8)
	var slice: Dictionary = look.get("slice", {})
	if typeof(slice) != TYPE_DICTIONARY:
		slice = {}
	col.add_child(_stage_top_row(title, str(look.get("rank", "")), slice, ink))
	var call_chip: String = str(look.get("call_chip", "")).strip_edges()
	if call_chip == "":
		return
	var call_col := Color("e8c36a")
	var raw_col: Variant = look.get("call_color", call_col)
	if raw_col is Color:
		call_col = raw_col
	var medal: Texture2D = null
	var raw_medal: Variant = look.get("medal", null)
	if raw_medal is Texture2D:
		medal = raw_medal
	col.add_child(_stage_ability(call_chip, call_col, medal))
	if body == "":
		return
	var b := RichTextLabel.new()
	b.bbcode_enabled = true
	b.fit_content = true
	b.scroll_active = false
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.meta_underlined = false
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_font_size_override("normal_font_size", 22)
	b.add_theme_font_size_override("bold_font_size", 22)
	b.add_theme_color_override("default_color", Color("e8dcc8") if _on_dark else Color("2a1c14"))
	b.text = body
	b.custom_minimum_size = Vector2(308, 0)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wire_kw(b)
	col.add_child(b)


func _stage_top_row(title: String, rank: String, slice: Dictionary, ink: Color) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_stage_badge(true, slice))
	var mid := VBoxContainer.new()
	mid.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.add_theme_constant_override("separation", 0)
	var name := Label.new()
	name.text = title
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_OFF
	name.clip_text = true
	name.custom_minimum_size = Vector2(140, 34)
	name.add_theme_font_size_override("font_size", 28)
	name.add_theme_color_override("font_color", Color("f0e6d8") if _on_dark else Color("1c120c"))
	name.add_theme_color_override("font_outline_color", Color("1c120c") if _on_dark else Color("f3e6d0"))
	name.add_theme_constant_override("outline_size", 3 if _on_dark else 2)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_child(name)
	if rank.strip_edges() != "":
		var rk := Label.new()
		rk.text = rank
		rk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rk.add_theme_font_size_override("font_size", 14)
		rk.add_theme_color_override("font_color", Color("c4a574") if _on_dark else Color("6a5a48"))
		rk.add_theme_color_override("font_outline_color", Color("100e0c"))
		rk.add_theme_constant_override("outline_size", 3)
		rk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mid.add_child(rk)
	row.add_child(mid)
	row.add_child(_stage_badge(false, slice))
	return row


func _stage_badge(heart: bool, slice: Dictionary) -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(84, 96)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var badge := StageWheelBadge.new()
	badge.heart = heart
	badge.slice = slice
	badge.scale = Vector2(2, 2)
	wrap.add_child(badge)
	return wrap


func _stage_ability(text: String, col: Color, medal: Texture2D) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pic := TextureRect.new()
	pic.custom_minimum_size = Vector2(56, 56)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pic.texture = medal
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(pic)
	var font: Font = ThemeDB.fallback_font
	var fs := 24
	var text_w := 160.0
	if font != null:
		text_w = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		while fs > 16 and text_w > 220.0:
			fs -= 1
			text_w = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var chip := Control.new()
	chip.custom_minimum_size = Vector2(text_w + 28.0, 40.0)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.set_meta("call_text", text)
	chip.set_meta("call_color", col)
	chip.set_meta("call_fs", fs)
	chip.draw.connect(_paint_stage_capsule.bind(chip))
	row.add_child(chip)
	return row


func _paint_stage_capsule(chip: Control) -> void:
	var rect := Rect2(Vector2.ZERO, chip.size)
	if rect.size.x < 8.0:
		return
	_paint_pill(chip, rect, Color(0.08, 0.06, 0.05, 0.94), Color("e8c36a"))
	var text: String = str(chip.get_meta("call_text", ""))
	var col: Color = chip.get_meta("call_color", Color("e8c36a"))
	var fs: int = int(chip.get_meta("call_fs", 24))
	var font: Font = ThemeDB.fallback_font
	if font == null or text == "":
		return
	var tsz := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var origin := Vector2((rect.size.x - tsz.x) * 0.5, (rect.size.y - font.get_height(fs)) * 0.5 + font.get_ascent(fs))
	var ink := Color("100e0c")
	for ox in range(-2, 3):
		for oy in range(-2, 3):
			if ox == 0 and oy == 0:
				continue
			chip.draw_string(font, origin + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	chip.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _fight_wheel() -> Node:
	var n: Node = self
	while n != null:
		var wheel: Variant = n.get("wheel_view")
		if wheel != null:
			return wheel
		n = n.get_parent()
	return null


## Heart or sword at the wheel's 36px stat size, number painted the same way.
class WheelStatBadge extends Control:
	var num_text: String = ""
	var is_heart: bool = true
	var style: int = 0
	var _tex: Texture2D
	var _region := Rect2()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var path := "res://assets/ui/hub/heart_full.png" if is_heart else "res://assets/ui/icons/atk_burst.png"
		if not ResourceLoader.exists(path):
			path = "res://assets/icons/heart_full.png" if is_heart else "res://assets/icons/sword.svg"
		if ResourceLoader.exists(path):
			_tex = load(path) as Texture2D
		if _tex != null:
			_region = Rect2(Vector2.ZERO, _tex.get_size())
			var img := _tex.get_image()
			if img != null:
				var used := img.get_used_rect()
				if used.size.x >= 1.0 and used.size.y >= 1.0:
					_region = used
		custom_minimum_size = Vector2(56, 68 if style == 1 else 52)

	func _draw() -> void:
		var px := 36.0
		var pos := Vector2(size.x * 0.5, 26.0 if style == 1 else size.y * 0.5)
		if style != 0:
			var plate := Rect2(pos - Vector2(px * 0.72, px * 0.62), Vector2(px * 1.44, px * 1.35))
			draw_rect(plate, Color(0.0627, 0.0549, 0.0471, 0.82), true)
			draw_rect(plate, Color("c4a574"), false, 1.5)
		if _tex != null:
			var rect := Rect2(pos - Vector2(px, px) * 0.5, Vector2(px, px))
			for k in 8:
				var o := Vector2.from_angle(float(k) * TAU / 8.0) * 2.2
				draw_texture_rect_region(_tex, Rect2(rect.position + o, rect.size), _region, Color("100e0c"))
			draw_texture_rect_region(_tex, rect, _region, Color.WHITE)
		var font: Font = ThemeDB.fallback_font
		if font == null or num_text == "":
			return
		var fs := 14 if style == 1 else 15
		var y_k := 0.08
		if style == 0:
			y_k = -0.08 if is_heart else 0.0
		var at := pos + (Vector2(0.0, px * 0.55) if style == 1 else Vector2(0.0, px * y_k))
		var tsz := font.get_string_size(num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var p := at + Vector2(-tsz.x * 0.5, fs * 0.36)
		var ink := Color("100e0c")
		for ox in [-1, 0, 1]:
			for oy in [-1, 0, 1]:
				if ox == 0 and oy == 0:
					continue
				draw_string(font, p + Vector2(ox, oy), num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
		draw_string(font, p, num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("f0e6d8"))


## Wheel HP / ATK badge, drawn with the wheel's own painters, shown at 2×.
class StageWheelBadge extends Control:
	var heart: bool = true
	var slice: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		custom_minimum_size = Vector2(42, 48)
		size = Vector2(42, 48)
		clip_contents = false

	func _draw() -> void:
		var wheel: Node = _wheel()
		if wheel == null:
			return
		wheel._ext_ci = self
		var font: Font = ThemeDB.fallback_font
		var pos := size * 0.5
		if heart and wheel.has_method("_draw_heart_stat"):
			wheel._draw_heart_stat(font, pos, slice, {}, false, -1)
		elif wheel.has_method("_draw_atk_stat"):
			wheel._draw_atk_stat(font, pos, slice, {}, false, -1)
		wheel._ext_ci = null

	func _wheel() -> Node:
		var n: Node = self
		while n != null:
			var found: Variant = n.get("wheel_view")
			if found != null:
				return found
			n = n.get_parent()
		return null
