extends PanelContainer
## Punchy inspect plate. Item equations and monster copy share this language.
## Keyword sub-tooltips (Always, Flee, …) dock here, not on the speech balloon.

const COPY := preload("res://scripts/player_copy.gd")
const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")

signal edit_pressed(kind: String, card_id: String)

var _skinned: bool = false
var _skin_tex: Texture2D
var _on_dark: bool = false
var edit_kind: String = ""
var edit_id: String = ""
## Face plaque accepts right-click. Fly tips stay click-through so hover does not trap the mouse.
var accept_clicks: bool = false
var _kw_tip: PanelContainer
var _pin_always: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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


func show_placeholder() -> void:
	if OS.has_feature("editor"):
		show_text(COPY.text("inspect.title", "Inspect"), COPY.text("inspect.placeholder", "Hover an owner on the ring, or loot in your hand. Right-click to edit."))
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
	_apply_look(look)
	_wipe()
	mouse_filter = Control.MOUSE_FILTER_STOP if accept_clicks and p_id != "" else Control.MOUSE_FILTER_IGNORE
	var ink: Color = Color("f0e6d8") if _on_dark else Color("1c120c")
	var ink_out: Color = Color("1c120c") if _on_dark else Color("f3e6d0")
	var body_col: Color = Color("e8dcc8") if _on_dark else Color("2a1c14")
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	if portrait != null:
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
	if value_line != "":
		var e := RichTextLabel.new()
		e.bbcode_enabled = true
		e.fit_content = true
		e.scroll_active = false
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		e.add_theme_font_size_override("normal_font_size", 22)
		e.add_theme_font_size_override("bold_font_size", 24)
		e.add_theme_color_override("default_color", ink)
		e.text = value_line
		e.custom_minimum_size = Vector2(216, 0)
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(e)
	if equation != "":
		var eq := RichTextLabel.new()
		eq.bbcode_enabled = true
		eq.fit_content = true
		eq.scroll_active = false
		eq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		eq.add_theme_font_size_override("normal_font_size", 18)
		eq.add_theme_color_override("default_color", ink)
		eq.text = equation
		eq.custom_minimum_size = Vector2(216, 0)
		eq.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(eq)
	var rank: String = str(look.get("rank", "")).strip_edges()
	if rank != "":
		var rk: FitLabelBox = FitLabelBox.make()
		rk.show_frame = false
		rk.padding = 0
		rk.max_font_size = 12
		rk.min_font_size = 12
		rk.set_plain(rank)
		rk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rk.font_color = Color("c4a574") if _on_dark else Color("6a5a48")
		rk.custom_minimum_size = Vector2(216, 18)
		rk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(rk)
	if body != "":
		var b := RichTextLabel.new()
		b.bbcode_enabled = true
		b.fit_content = true
		b.scroll_active = false
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.meta_underlined = false
		var body_size: int = 13 if not journal.is_empty() else 15
		b.add_theme_font_size_override("normal_font_size", body_size)
		b.add_theme_font_size_override("bold_font_size", body_size)
		b.add_theme_color_override("default_color", Color("6e5434") if not journal.is_empty() else body_col)
		b.text = body
		b.custom_minimum_size = Vector2(216, 0)
		if body.find("[url=") >= 0:
			b.mouse_filter = Control.MOUSE_FILTER_STOP
			UxStyle.wire_def_hover(b, _kw_tip, self)
		else:
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(b)
	_pin_always = body.find("[url=kw:always]") >= 0
	if _pin_always:
		pin_always_def()
	elif _kw_tip != null and _kw_tip.has_method("hide_def"):
		_kw_tip.hide_def()
	if warn != "":
		var w := Label.new()
		w.text = warn
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
	if _pin_always:
		pin_always_def()


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
	if not OS.has_feature("editor"):
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
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	add_theme_stylebox_override("panel", sb)


func _wipe() -> void:
	for c in get_children():
		if c == _kw_tip:
			continue
		remove_child(c)
		c.queue_free()
