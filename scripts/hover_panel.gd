extends PanelContainer
## Punchy inspect plate. Item equations and monster copy share this language.

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")

signal edit_pressed(kind: String, card_id: String)

var _skinned: bool = false
var _skin_tex: Texture2D
var _on_dark: bool = false
var edit_kind: String = ""
var edit_id: String = ""
## Face plaque accepts right-click. Fly tips stay click-through so hover does not trap the mouse.
var accept_clicks: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(268, 0)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	gui_input.connect(_on_gui)
	if not _skinned:
		_plain_skin()


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
	_on_dark = true
	add_theme_stylebox_override("panel", UX.plate())


func show_placeholder() -> void:
	var body: String = COPY.text("inspect.idle", "Hover a monster on the ring, or loot in your hand.")
	if OS.has_feature("editor"):
		body = COPY.text("inspect.placeholder", "—")
	show_rule(
		COPY.text("inspect.title", "Inspect"),
		"",
		"",
		body,
		"",
		null,
		"",
		"",
		{"idle": true, "fill": Color("1a1410"), "metal": Color("c4a574"), "tier": 1}
	)


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
	look: Dictionary = {}
) -> void:
	edit_kind = p_kind
	edit_id = p_id
	_apply_look(look)
	_wipe()
	mouse_filter = Control.MOUSE_FILTER_STOP if accept_clicks and p_id != "" else Control.MOUSE_FILTER_IGNORE
	var ink: Color = Color("f0e6d8") if _on_dark else Color("1c120c")
	var body_col: Color = Color("e8dcc8") if _on_dark else Color("2a1c14")
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 7)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	if portrait != null:
		var well := PanelContainer.new()
		well.add_theme_stylebox_override("panel", UX.well())
		well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		well.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var pic := TextureRect.new()
		pic.texture = portrait
		pic.custom_minimum_size = Vector2(72, 80)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture_filter = TEXTURE_FILTER_NEAREST
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		well.add_child(pic)
		col.add_child(well)
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_sz: int = maxi(UI.SIZE_MIN, int(look.get("title_size", UI.SIZE_NAME)))
	UI.apply_name(t, ink, title_sz)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(t)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Color("e8c36a") if _on_dark else Color("c4a574")
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(rule)
	if look.has("hp"):
		var vitals := VitalsIcons.new(int(look.get("hp", 0)), int(look.get("atk", 0)))
		col.add_child(vitals)
	elif str(look.get("stat_kind", "")) != "" or str(look.get("stat_bb", "")) != "":
		if str(look.get("stat_bb", "")) != "" and str(look.get("stat_kind", "")) == "":
			var st := RichTextLabel.new()
			st.bbcode_enabled = true
			st.fit_content = true
			st.scroll_active = false
			st.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			UI.apply_rich(st, "number", ink)
			st.text = "[center]%s[/center]" % str(look.get("stat_bb", ""))
			st.custom_minimum_size = Vector2(236, 0)
			st.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(st)
		else:
			col.add_child(StatBadge.new(look))
	if bool(look.get("idle", false)):
		var legend := RichTextLabel.new()
		legend.bbcode_enabled = true
		legend.fit_content = true
		legend.scroll_active = false
		legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI.apply_rich(legend, "body", ink)
		legend.text = "[center]%s[/center]" % UX.legend_bb()
		legend.custom_minimum_size = Vector2(236, 28)
		legend.size_flags_horizontal = Control.SIZE_FILL
		legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(legend)
	if value_line != "" and not look.has("hp"):
		var e := RichTextLabel.new()
		e.bbcode_enabled = true
		e.fit_content = true
		e.scroll_active = false
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI.apply_rich(e, "number", ink)
		e.text = "[center]%s[/center]" % value_line
		e.custom_minimum_size = Vector2(236, 0)
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(e)
	if equation != "":
		var eq := RichTextLabel.new()
		eq.bbcode_enabled = true
		eq.fit_content = true
		eq.scroll_active = false
		eq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		eq.add_theme_constant_override("line_separation", 3)
		var eq_ink: Color = ink
		if str(look.get("equation_kind", "")) == "call":
			var hx: String = str(look.get("call_hex", "")).strip_edges()
			if hx != "":
				eq_ink = Color(hx)
		UI.apply_rich(eq, "body", eq_ink)
		eq.text = "[center]%s[/center]" % equation
		eq.custom_minimum_size = Vector2(236, 0)
		eq.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(eq)
	if body != "":
		var b := RichTextLabel.new()
		b.bbcode_enabled = true
		b.fit_content = true
		b.scroll_active = false
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_constant_override("line_separation", 3)
		UI.apply_rich(b, "body", body_col)
		b.text = body
		b.custom_minimum_size = Vector2(236, 0)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(b)
	if warn != "":
		var w := Label.new()
		w.text = warn
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI.apply_body(w, Color("f0a0a0") if _on_dark else Color("8b1e1e"), UI.SIZE_BODY)
		w.custom_minimum_size = Vector2(236, 0)
		w.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(w)
	var hint: String = str(look.get("hint", ""))
	if hint != "":
		var h := RichTextLabel.new()
		h.bbcode_enabled = true
		h.fit_content = true
		h.scroll_active = false
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI.apply_rich(h, "body", Color("B89A70"))
		h.text = "[i]%s[/i]" % hint
		h.custom_minimum_size = Vector2(236, 0)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(h)
	visible = true
	modulate.a = 1.0
	reset_size()


static func stat_badge(look: Dictionary) -> Control:
	return StatBadge.new(look)


func hide_plate() -> void:
	visible = false
	edit_kind = ""
	edit_id = ""
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		remove_child(c)
		c.queue_free()


class VitalsIcons extends Control:
	var hp: int = 0
	var atk: int = 0

	func _init(p_hp: int, p_atk: int) -> void:
		hp = p_hp
		atk = p_atk
		custom_minimum_size = Vector2(236, 52)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var font: Font = get_theme_default_font()
		if font == null:
			font = ThemeDB.fallback_font
		_draw_heart(Vector2(78.0, 28.0), font)
		_draw_sword(Vector2(158.0, 28.0), font)

	func _draw_heart(pos: Vector2, font: Font) -> void:
		var hs := 36.0
		var fill := Color("c4282a")
		var ink := Color("1c120c")
		draw_colored_polygon(_heart_pts(pos, hs * 1.14), ink)
		draw_colored_polygon(_heart_pts(pos, hs), fill)
		draw_circle(pos + Vector2(0.0, 4.0), hs * 0.28, Color("6a1818"))
		_num(font, pos + Vector2(0.0, 2.0), str(hp))

	func _draw_sword(pos: Vector2, font: Font) -> void:
		var rad := 18.0
		var fill := Color("6a1c14")
		var edge := Color("e07040")
		var ink := Color("100e0c")
		var out := Vector2(0, 1)
		var tan := Vector2(-1, 0)
		var tip: Vector2 = pos + out * rad * 1.42
		var left: Vector2 = pos - out * rad * 0.22 - tan * rad * 0.62
		var right: Vector2 = pos - out * rad * 0.22 + tan * rad * 0.62
		var haft: Vector2 = pos - out * rad * 1.05
		draw_colored_polygon(PackedVector2Array([
			tip + out * 2.0, right + tan * 2.2, haft - out * 2.0, left - tan * 2.2
		]), ink)
		draw_colored_polygon(PackedVector2Array([tip, right, haft, left]), fill)
		draw_circle(pos, rad * 0.50, Color(fill.r, fill.g, fill.b, 0.96))
		draw_arc(pos, rad * 0.50, 0.0, TAU, 22, edge, 2.2, true)
		_num(font, pos + Vector2(0.0, 1.0), str(atk))

	func _heart_pts(pos: Vector2, hs: float) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for k in 28:
			var th: float = TAU * float(k) / 28.0
			var x: float = 16.0 * pow(sin(th), 3.0)
			var y: float = -(13.0 * cos(th) - 5.0 * cos(2.0 * th) - 2.0 * cos(3.0 * th) - cos(4.0 * th))
			pts.append(pos + Vector2(x, y) * (hs / 34.0))
		return pts

	func _num(font: Font, pos: Vector2, txt: String) -> void:
		var use: Font = UiPalette.font_extrabold()
		if use == null:
			use = font
		var fs := UiPalette.SIZE_CHIP
		var sz: Vector2 = use.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var p: Vector2 = pos - Vector2(sz.x * 0.5, sz.y * 0.35)
		draw_string(use, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("f0e6d8"))


class StatBadge extends Control:
	var kind: String = "ATK"
	var n: int = 0
	var shown: String = ""
	var atk_n: int = 0
	var blk_n: int = 0

	func _init(look: Dictionary) -> void:
		kind = str(look.get("stat_kind", "ATK"))
		n = int(look.get("stat_n", 0))
		shown = str(look.get("stat_shown", ""))
		atk_n = int(look.get("stat_atk", 0))
		blk_n = int(look.get("stat_blk", 0))
		custom_minimum_size = Vector2(236, 52)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _txt() -> String:
		if shown != "":
			return shown
		return str(n)

	func _draw() -> void:
		var font: Font = get_theme_default_font()
		if font == null:
			font = ThemeDB.fallback_font
		var w: float = size.x if size.x > 1.0 else custom_minimum_size.x
		var h: float = size.y if size.y > 1.0 else custom_minimum_size.y
		if kind == "BOTH":
			_draw_shield(Vector2(w * 0.33, h * 0.5), font, str(blk_n))
			_draw_sword(Vector2(w * 0.67, h * 0.5), font, str(atk_n))
			return
		var pos := Vector2(w * 0.5, h * 0.5)
		if kind == "BLK":
			_draw_shield(pos, font, _txt())
		elif kind == "HEAL":
			_draw_heart(pos, font, _txt())
		else:
			_draw_sword(pos, font, _txt())

	func _draw_sword(pos: Vector2, font: Font, txt: String) -> void:
		var rad := 18.0
		var fill := Color("6a1c14")
		var edge := Color("e07040")
		var ink := Color("100e0c")
		var out := Vector2(0, 1)
		var tan := Vector2(-1, 0)
		var tip: Vector2 = pos + out * rad * 1.42
		var left: Vector2 = pos - out * rad * 0.22 - tan * rad * 0.62
		var right: Vector2 = pos - out * rad * 0.22 + tan * rad * 0.62
		var haft: Vector2 = pos - out * rad * 1.05
		draw_colored_polygon(PackedVector2Array([
			tip + out * 2.0, right + tan * 2.2, haft - out * 2.0, left - tan * 2.2
		]), ink)
		draw_colored_polygon(PackedVector2Array([tip, right, haft, left]), fill)
		draw_circle(pos, rad * 0.50, Color(fill.r, fill.g, fill.b, 0.96))
		draw_arc(pos, rad * 0.50, 0.0, TAU, 22, edge, 2.2, true)
		_num(font, pos + Vector2(0.0, 1.0), txt)

	func _draw_heart(pos: Vector2, font: Font, txt: String) -> void:
		var hs := 36.0
		var fill := Color("c4282a")
		draw_colored_polygon(_heart_pts(pos, hs * 1.14), Color("1c120c"))
		draw_colored_polygon(_heart_pts(pos, hs), fill)
		draw_circle(pos + Vector2(0.0, 4.0), hs * 0.28, Color("6a1818"))
		_num(font, pos + Vector2(0.0, 2.0), txt)

	func _draw_shield(pos: Vector2, font: Font, txt: String) -> void:
		var sw := 22.0
		var fill := Color("2a6aa8")
		var rim := Color("6bb3d9")
		var shield := PackedVector2Array([
			pos + Vector2(0.0, -sw * 0.78),
			pos + Vector2(sw * 0.70, -sw * 0.28),
			pos + Vector2(sw * 0.55, sw * 0.48),
			pos + Vector2(0.0, sw * 0.88),
			pos + Vector2(-sw * 0.55, sw * 0.48),
			pos + Vector2(-sw * 0.70, -sw * 0.28),
		])
		draw_colored_polygon(shield, fill)
		shield.append(shield[0])
		draw_polyline(shield, rim, 2.6, true)
		_num(font, pos + Vector2(0.0, 1.0), txt)

	func _heart_pts(pos: Vector2, hs: float) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for k in 28:
			var th: float = TAU * float(k) / 28.0
			var x: float = 16.0 * pow(sin(th), 3.0)
			var y: float = -(13.0 * cos(th) - 5.0 * cos(2.0 * th) - 2.0 * cos(3.0 * th) - cos(4.0 * th))
			pts.append(pos + Vector2(x, y) * (hs / 34.0))
		return pts

	func _num(font: Font, pos: Vector2, txt: String) -> void:
		var use: Font = UiPalette.font_extrabold()
		if use == null:
			use = font
		var fs := UiPalette.SIZE_CHIP
		var sz: Vector2 = use.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var p: Vector2 = pos - Vector2(sz.x * 0.5, sz.y * 0.35)
		draw_string(use, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("f0e6d8"))


