extends ScrollContainer
## Fight log. Capsules with nested knock-ons. Hover a row to light up what it named.

signal hover_changed(highlight: Dictionary)

const UX := preload("res://scripts/ux_style.gd")

const TAG := {
	"on_click": {"hex": "#E8C36A", "tag": "You"},
	"on_spin": {"hex": "#6EC8E8", "tag": "Spin"},
	"on_item_use": {"hex": "#E07A3D", "tag": "Used"},
	"on_resolve": {"hex": "#F0E6D8", "tag": "Fight"},
	"on_remove_slice": {"hex": "#D19A66", "tag": "Defeated"},
	"on_draft": {"hex": "#8DCB8D", "tag": "Draft"},
	"on_place": {"hex": "#A3BE8C", "tag": "Placed"},
	"on_bribe": {"hex": "#D19A66", "tag": "Bribe"},
	"var": {"hex": "#C9A0FF", "tag": ""},
	"atk": {"hex": "#E06C75", "tag": "ATK"},
	"blk": {"hex": "#6BB3D9", "tag": "BLK"},
	"hp": {"hex": "#E8A0A0", "tag": "HP"},
	"discard": {"hex": "#8A8178", "tag": "Gone"},
	"keep": {"hex": "#A3BE8C", "tag": "Kept"},
	"end": {"hex": "#BF616A", "tag": "End"},
}

var _col: VBoxContainer
var _stack: Array = []
var _hint_tip: PanelContainer
var _hint_lab: Label
var _fitting: bool = false
var _plain: PackedStringArray = PackedStringArray()


func setup() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	follow_focus = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_exited.connect(_on_leave)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("120f0cb8")
	sb.border_color = Color("3a322b")
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)
	_col = VBoxContainer.new()
	_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_col.add_theme_constant_override("separation", 6)
	add_child(_col)
	resized.connect(_fit_width, CONNECT_DEFERRED)
	_hint_tip = PanelContainer.new()
	_hint_tip.visible = false
	_hint_tip.z_index = 130
	_hint_tip.top_level = true
	_hint_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("100e0cf5")
	hsb.border_color = Color("e8c36a")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(14)
	hsb.content_margin_left = 14
	hsb.content_margin_right = 14
	hsb.content_margin_top = 8
	hsb.content_margin_bottom = 8
	hsb.shadow_color = Color(0.06, 0.04, 0.03, 0.55)
	hsb.shadow_size = 8
	_hint_tip.add_theme_stylebox_override("panel", hsb)
	_hint_lab = Label.new()
	_hint_lab.add_theme_font_size_override("font_size", 15)
	_hint_lab.add_theme_color_override("font_color", Color("f0e6d8"))
	_hint_lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	_hint_lab.add_theme_constant_override("outline_size", 3)
	_hint_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_tip.add_child(_hint_lab)
	add_child(_hint_tip)
	set_process(false)


func clear_all() -> void:
	_stack.clear()
	_plain.clear()
	_hide_hint()
	for c in _col.get_children():
		_col.remove_child(c)
		c.queue_free()
	hover_changed.emit({})


func flush() -> void:
	_stack.clear()


func begin_proc(data: Dictionary) -> void:
	var cap := _proc_capsule(data)
	_host().add_child(cap)
	var kids: VBoxContainer = cap.get_meta("kids")
	_stack.append(kids)
	var head: String = str(data.get("title", "")).strip_edges()
	var sub: String = str(data.get("subtitle", "")).strip_edges()
	if sub != "" and head != "":
		_plain.append(_web_safe("%s - %s" % [sub, head]))
	elif head != "":
		_plain.append(_web_safe(head))
	_scroll_end()


func push_line(kind: String, msg: String, highlight: Dictionary = {}) -> void:
	msg = _web_safe(msg)
	if kind == "on_item_use" and not _stack.is_empty():
		var host: VBoxContainer = _host()
		var titled: String = str(host.get_meta("title", "")).strip_edges().to_lower()
		if titled != "" and titled == _strip_bb(msg).strip_edges().to_lower():
			return
	var row := _leaf_row(kind, msg, highlight)
	_host().add_child(row)
	var info: Dictionary = TAG.get(kind, TAG["var"])
	var tag: String = str(info.get("tag", ""))
	var line: String = ("%s %s" % [tag, _strip_bb(msg)]).strip_edges()
	if line != "":
		_plain.append(line)
	_scroll_end()


func dump_plain() -> String:
	return "\n".join(_plain)


func _strip_bb(raw: String) -> String:
	var rx := RegEx.new()
	if rx.compile("\\[/?[^\\]]+\\]") != OK:
		return raw
	return rx.sub(raw, "", true)


func _host() -> VBoxContainer:
	if _stack.is_empty():
		return _col
	var top: Variant = _stack.back()
	if top is VBoxContainer and is_instance_valid(top):
		return top
	_stack.pop_back()
	return _host()


func _proc_capsule(data: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	var tier: int = int(data.get("tier", 1))
	var is_item: bool = str(data.get("kind", "")) == "item"
	var rim: Color = UX.metal(tier) if is_item else Color("e8c36a")
	var ink_s: String = str(data.get("ink", "")).strip_edges()
	if ink_s != "":
		rim = Color(ink_s)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410f2")
	sb.border_color = rim
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	p.add_theme_stylebox_override("panel", sb)
	var hl: Dictionary = data.get("highlight", {}) if typeof(data.get("highlight", {})) == TYPE_DICTIONARY else {}
	p.mouse_entered.connect(_on_row_in.bind(hl))
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 4)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(wrap)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(head)
	if is_item:
		var chip := _item_chip(str(data.get("title", "")), tier)
		var hint: String = str(data.get("hint", "")).strip_edges()
		if hint != "":
			chip.mouse_filter = Control.MOUSE_FILTER_STOP
			chip.mouse_entered.connect(_on_hint.bind(chip, hint, hl))
			chip.mouse_exited.connect(_hide_hint)
		head.add_child(chip)
	else:
		var titles := VBoxContainer.new()
		titles.add_theme_constant_override("separation", -2)
		titles.mouse_filter = Control.MOUSE_FILTER_IGNORE
		head.add_child(titles)
		var owner := str(data.get("subtitle", "")).strip_edges()
		if owner != "":
			var n := Label.new()
			n.text = owner
			n.add_theme_font_size_override("font_size", 11)
			n.add_theme_color_override("font_color", Color("c9b9a8"))
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
			titles.add_child(n)
		var call := Label.new()
		call.text = str(data.get("title", ""))
		call.add_theme_font_size_override("font_size", 16)
		call.add_theme_color_override("font_color", Color("e8c36a"))
		call.add_theme_color_override("font_outline_color", Color("100e0c"))
		call.add_theme_constant_override("outline_size", 2)
		call.mouse_filter = Control.MOUSE_FILTER_STOP
		var hint: String = str(data.get("hint", "")).strip_edges()
		if hint != "":
			call.mouse_entered.connect(_on_hint.bind(call, hint, hl))
			call.mouse_exited.connect(_hide_hint)
		titles.add_child(call)
	var kids := VBoxContainer.new()
	kids.add_theme_constant_override("separation", 3)
	kids.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kids.set_meta("highlight", hl)
	kids.set_meta("title", str(data.get("title", "")))
	wrap.add_child(kids)
	p.set_meta("kids", kids)
	return p


func _item_chip(name: String, tier: int) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UX.metal_chip(tier)
	sb.border_color = UX.metal(tier)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	chip.add_theme_stylebox_override("panel", sb)
	var lab := Label.new()
	lab.text = name
	lab.add_theme_font_size_override("font_size", 14)
	lab.add_theme_color_override("font_color", Color("f0e6d8"))
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(lab)
	return chip


func _leaf_row(kind: String, msg: String, highlight: Dictionary) -> HBoxContainer:
	if highlight.is_empty():
		var host: VBoxContainer = _host()
		if host.has_meta("highlight") and typeof(host.get_meta("highlight")) == TYPE_DICTIONARY:
			highlight = host.get_meta("highlight")
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.mouse_entered.connect(_on_row_in.bind(highlight))
	if not _stack.is_empty():
		var arrow := Label.new()
		arrow.text = ">"
		arrow.add_theme_font_size_override("font_size", 13)
		arrow.add_theme_color_override("font_color", Color("8a8178"))
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(arrow)
	var info: Dictionary = TAG.get(kind, TAG["var"])
	var tag: String = str(info.get("tag", ""))
	if tag != "":
		var tlab := Label.new()
		tlab.text = tag
		tlab.add_theme_font_size_override("font_size", 12)
		tlab.add_theme_color_override("font_color", Color(str(info.get("hex", "#C9A0FF"))))
		tlab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tlab)
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("normal_font_size", 13)
	body.add_theme_font_size_override("bold_font_size", 13)
	body.add_theme_color_override("default_color", Color("d8cbb8"))
	body.text = _paint(msg)
	body.meta_underlined = false
	if str(body.text).find("[url=") >= 0:
		body.mouse_filter = Control.MOUSE_FILTER_STOP
		body.meta_hover_started.connect(_on_kw_meta.bind(body))
		body.meta_hover_ended.connect(_on_kw_meta_out)
	else:
		body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(body)
	return row


func _on_kw_meta(meta: Variant, body: RichTextLabel) -> void:
	var id: String = str(meta).trim_prefix("kw:")
	_on_hint(body, UX.def_of(id), {})


func _on_kw_meta_out(_meta: Variant) -> void:
	_hide_hint()


func _web_safe(t: String) -> String:
	t = t.replace(" → ", " to ")
	t = t.replace("→", " to ")
	t = t.replace(" — ", " - ")
	t = t.replace("—", "-")
	t = t.replace("–", "-")
	t = t.replace("−", "-")
	t = t.replace("↳", ">")
	return t


func _paint(raw: String) -> String:
	var t: String = _web_safe(raw.strip_edges())
	if t == "" or t.find("[color") >= 0:
		return t
	t = _color_word(t, "ATK", "#E06C75")
	t = _color_word(t, "BLK", "#6BB3D9")
	t = _color_word(t, "HP", "#E8A0A0")
	t = _color_word(t, "Block", "#6BB3D9")
	t = _color_word(t, "Heal", "#7dba7d")
	var out := ""
	var i := 0
	while i < t.length():
		var ch: String = t.substr(i, 1)
		if ch == "+" or ch == "−" or ch == "-":
			var j := i + 1
			while j < t.length() and t.substr(j, 1).is_valid_int():
				j += 1
			if j > i + 1:
				var num: String = t.substr(i, j - i)
				var col := "#7dba7d" if ch == "+" else "#E06C75"
				out += "[color=%s][b]%s[/b][/color]" % [col, num]
				i = j
				continue
		out += ch
		i += 1
	return _link_kws(out)


func _link_kws(t: String) -> String:
	var rx := RegEx.new()
	if rx.compile("(?i)\\b(fleeing|flees|fled|flee|spinning|spins|spun|spin|always|unplayable|rust)\\b") != OK:
		return t
	var hits: Array = rx.search_all(t)
	var out := t
	for i in range(hits.size() - 1, -1, -1):
		var m: RegExMatch = hits[i]
		var piece: String = m.get_string()
		var id: String = UX.def_id_of(piece)
		if id == "":
			continue
		var shown_word: String = piece
		if id == "always":
			shown_word = "Always"
		elif id == "unplayable":
			shown_word = "Unplayable"
		var hex: String = "#A8A29A" if id == "unplayable" else "#E8C36A"
		var shown: String = "[url=kw:%s][color=%s][b]%s[/b][/color][/url]" % [id, hex, shown_word]
		out = out.substr(0, m.get_start()) + shown + out.substr(m.get_end())
	return out


func _color_word(t: String, word: String, hex: String) -> String:
	var needle: String = word
	var i: int = 0
	var out := ""
	while true:
		var at: int = t.to_lower().find(needle.to_lower(), i)
		if at < 0:
			out += t.substr(i)
			break
		out += t.substr(i, at - i)
		out += "[color=%s][b]%s[/b][/color]" % [hex, t.substr(at, needle.length())]
		i = at + needle.length()
	return out


func _on_row_in(highlight: Dictionary) -> void:
	hover_changed.emit(highlight)


func _on_hint(_ctrl: Control, hint: String, highlight: Dictionary) -> void:
	hover_changed.emit(highlight)
	if _hint_tip == null or _hint_lab == null:
		return
	_hint_lab.text = hint
	_hint_tip.visible = true
	_hint_tip.reset_size()
	set_process(true)
	_follow_hint()


func _hide_hint() -> void:
	if _hint_tip:
		_hint_tip.visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if _hint_tip == null or not _hint_tip.visible:
		set_process(false)
		return
	_follow_hint()


func _follow_hint() -> void:
	if _hint_tip == null:
		return
	_hint_tip.reset_size()
	var sz: Vector2 = _hint_tip.get_combined_minimum_size()
	var vp: Vector2 = get_viewport_rect().size
	var log_r: Rect2 = get_global_rect()
	var mouse: Vector2 = get_global_mouse_position()
	var prefer := Vector2(log_r.position.x - sz.x - 12.0, mouse.y)
	var below := Vector2(log_r.position.x - sz.x - 12.0, log_r.end.y + 12.0)
	var above := Vector2(log_r.position.x - sz.x - 12.0, log_r.position.y - sz.y - 12.0)
	var pos: Vector2 = preload("res://scripts/ui/tooltip_clamp.gd").place(vp, sz, [prefer, above, below], [log_r])
	_hint_tip.global_position = pos
	_hint_tip.size = sz


func _fit_width() -> void:
	if _fitting or _col == null or not is_instance_valid(_col):
		return
	var bar: VScrollBar = get_v_scroll_bar()
	var gutter: float = 24.0
	if bar != null:
		gutter = maxf(bar.size.x + 8.0, 24.0)
	var w: float = maxf(size.x - gutter, 200.0)
	if absf(_col.custom_minimum_size.x - w) < 2.0:
		return
	_fitting = true
	_col.custom_minimum_size.x = w
	_fitting = false


func _on_leave() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	if get_global_rect().has_point(get_global_mouse_position()):
		return
	_hide_hint()
	hover_changed.emit({})


func _scroll_end() -> void:
	await get_tree().process_frame
	var bar := get_v_scroll_bar()
	if bar:
		scroll_vertical = int(bar.max_value)
