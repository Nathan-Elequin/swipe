extends Control
## Vignette, hole, and Nib's talk box. Driven by the locked How to Play script.

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")

signal continued
signal skipped
signal finished
signal auto_spin
signal play_adventure
signal mill_demo(kind: String)

const PAD := 16.0
const TALK_W := 380.0
const DIM_A := 0.22
const DIM_END := 0.70

var step: int = -1
var wait: String = ""
var focus_tag: String = ""
var spin_id: String = ""
var branch_pick: String = ""
var _arm: float = 0.0
var _frames: Array = []
var _fi: float = 0.0
var _dim: Array = []
var _ring: Panel
var _rings: Array = []
var _cone: bool = false
var _talk: Control
var _face: TextureRect
var _name: Label
var _body: RichTextLabel
var _hint: Label
var _go: Button
var _end_row: HBoxContainer
var _end_main: Button
var _end_play: Button
var _target: Control
var _targets: Array = []
var _big: TextureRect
var _pages: Array = []
var _page_i: int = -1
var _nib: String = "normal"
var _walk_off: bool = false
var _walking: bool = false
var box
var _beat_n: int = 0
var _spot_wheel: TextureRect
var _spot_seats: Array = []


func setup(art, p_box = null) -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 4
	top_level = false
	visible = false
	box = p_box
	if art != null and art.has_method("nib_frames"):
		_frames = art.nib_frames("talk")
		if _frames.is_empty():
			_frames = art.nib_frames("idle")
		var port: Texture2D = art.nib_portrait() if art.has_method("nib_portrait") else null
		if _frames.is_empty() and port != null:
			_frames = [port]
	_spot_wheel = TextureRect.new()
	_spot_wheel.texture = load("res://assets/ui/ui_spotlight_ring.png")
	_spot_wheel.position = Vector2(215, 17)
	_spot_wheel.size = Vector2(666, 666)
	_spot_wheel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_spot_wheel.stretch_mode = TextureRect.STRETCH_KEEP
	_spot_wheel.texture_filter = TEXTURE_FILTER_NEAREST
	_spot_wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spot_wheel.visible = false
	add_child(_spot_wheel)
	if box != null:
		if box.has_method("setup") and box.get_child_count() == 0:
			box.setup(art)
		if box.has_signal("go_pressed"):
			box.go_pressed.connect(func() -> void: continued.emit())
		if box.has_signal("skip_pressed"):
			box.skip_pressed.connect(func() -> void: skipped.emit())
		if box.has_signal("talk_clicked"):
			box.talk_clicked.connect(_on_box_click)
		if box.has_signal("play_pressed"):
			box.play_pressed.connect(func() -> void: play_adventure.emit())
		_talk = box
		if "btn_go" in box:
			_go = box.btn_go
	set_process(true)


func _build_talk(art) -> void:
	_talk = PanelContainer.new()
	_talk.mouse_filter = Control.MOUSE_FILTER_STOP
	_talk.custom_minimum_size = Vector2(TALK_W, 0)
	var skin: Texture2D = art.ui.get("panel_beige", null) if art else null
	if skin != null:
		var tb := StyleBoxTexture.new()
		tb.texture = skin
		tb.texture_margin_left = 14
		tb.texture_margin_right = 14
		tb.texture_margin_top = 12
		tb.texture_margin_bottom = 14
		tb.content_margin_left = 16
		tb.content_margin_right = 16
		tb.content_margin_top = 12
		tb.content_margin_bottom = 12
		_talk.add_theme_stylebox_override("panel", tb)
	else:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("1a1410f5")
		sb.border_color = Color("e8c36a")
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		sb.content_margin_top = 12
		sb.content_margin_bottom = 12
		_talk.add_theme_stylebox_override("panel", sb)
	add_child(_talk)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_talk.add_child(row)
	_face = TextureRect.new()
	_face.custom_minimum_size = Vector2(128, 128)
	_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_face.texture_filter = TEXTURE_FILTER_NEAREST
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _frames.is_empty():
		_face.texture = _frames[0]
	row.add_child(_face)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)
	_name = Label.new()
	_name.text = COPY.text("tutorial.speaker", "Nib")
	_name.add_theme_font_size_override("font_size", 18)
	_name.add_theme_color_override("font_color", Color("6b4a10"))
	UX.ink_on_paper(_name, 1)
	col.add_child(_name)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.fit_content = true
	_body.scroll_active = false
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("normal_font_size", 15)
	_body.add_theme_font_size_override("bold_font_size", 15)
	_body.add_theme_constant_override("line_separation", 3)
	_body.add_theme_color_override("default_color", Color("1c120c"))
	_body.custom_minimum_size = Vector2(260, 0)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UX.ink_on_paper(_body, 1)
	col.add_child(_body)
	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color("6b4a10"))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UX.ink_on_paper(_hint, 1)
	col.add_child(_hint)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_END
	btns.add_theme_constant_override("separation", 8)
	col.add_child(btns)
	_go = Button.new()
	_go.text = "Next  ›"
	_go.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_go.custom_minimum_size = Vector2(96, 40)
	_go.clip_text = false
	_go.autowrap_mode = TextServer.AUTOWRAP_OFF
	_go.add_theme_font_size_override("font_size", 18)
	_style_btn(_go, Color("3a2820"), Color("e8c36a"))
	_go.pressed.connect(func() -> void: continued.emit())
	btns.add_child(_go)


func _build_end_row() -> void:
	_end_row = HBoxContainer.new()
	_end_row.visible = false
	_end_row.mouse_filter = Control.MOUSE_FILTER_STOP
	_end_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_end_row.add_theme_constant_override("separation", 16)
	add_child(_end_row)
	_end_main = Button.new()
	_end_main.text = COPY.text("tutorial.end_menu", "Main Menu")
	_end_main.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_btn(_end_main, Color("2a2622"), Color("c4a574"))
	_end_main.pressed.connect(func() -> void: skipped.emit())
	_end_row.add_child(_end_main)
	_end_play = Button.new()
	_end_play.text = COPY.text("tutorial.end_play", "Play")
	_end_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_btn(_end_play, Color("3a2820"), Color("e8c36a"))
	_end_play.pressed.connect(func() -> void: play_adventure.emit())
	_end_row.add_child(_end_play)


func _style_btn(b: Button, fill: Color, rim: Color) -> void:
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	b.add_theme_color_override("font_hover_color", Color("fff6e8"))
	b.add_theme_color_override("font_pressed_color", Color("e8c36a"))
	b.add_theme_color_override("font_focus_color", Color("f0e6d8"))
	b.add_theme_color_override("font_disabled_color", Color("f0e6d8"))
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = rim
	s.set_border_width_all(2)
	s.set_corner_radius_all(999)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", s)
	var h := s.duplicate() as StyleBoxFlat
	h.bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)


func open() -> void:
	step = -1
	_page_i = -1
	_beat_n = 0
	branch_pick = ""
	spin_id = ""
	_nib = "normal"
	_walk_off = false
	_walking = false
	_pages = _parse_script(COPY.text("tutorial.beat.01.body", ""))
	visible = true
	if box:
		box.visible = true
	advance()


func close() -> void:
	visible = false
	wait = ""
	focus_tag = ""
	spin_id = ""
	_target = null
	_targets.clear()
	step = -1
	_nib = "normal"
	_walk_off = false
	_walking = false
	if box:
		box.visible = false


func set_choice(which: String) -> void:
	branch_pick = which


func advance() -> void:
	if _walking:
		return
	while true:
		_page_i += 1
		if _page_i >= _pages.size():
			wait = "end"
			_show_end()
			return
		var p: Dictionary = _pages[_page_i]
		var br: String = str(p.get("branch", ""))
		if br != "" and branch_pick != "" and br != branch_pick:
			continue
		_show_page(p)
		return


func _on_box_click() -> void:
	if wait == "continue" and (box == null or not box.is_typing()):
		continued.emit()


func _go_copy(go: String) -> String:
	_beat_n += 1
	var key := "tutorial.beat.%02d.go" % _beat_n
	var t: String = COPY.text(key, "")
	if t.strip_edges() != "":
		return t
	if go.strip_edges() != "" and go != "Next" and go != "Got It":
		return go
	return COPY.need("tutorial.beat.01.go")


func _show_page(p: Dictionary) -> void:
	wait = str(p.get("wait", "continue"))
	focus_tag = str(p.get("focus", ""))
	spin_id = str(p.get("spin_id", ""))
	_nib = str(p.get("nib", "normal"))
	_walk_off = false
	var hide_talk: bool = wait == "walk" or (wait == "spin" and bool(p.get("auto", false)))
	if box:
		box.visible = not hide_talk and wait != "end"
	_set_body(str(p.get("body", "")), bool(p.get("tiny", false)))
	var hint: String = _hint_for(wait)
	if box and box.has_method("set_nudge"):
		box.set_nudge(hint)
	var go: String = _go_copy(str(p.get("go", "Next")))
	if box and box.has_method("set_go"):
		box.set_go(go, true)
	if box and box.has_method("set_progress"):
		box.set_progress(_page_i + 1, _pages.size())
	_arm = 0.35
	var mill: String = str(p.get("mill", ""))
	_cone = focus_tag == "empty_slice" or focus_tag == "monster" or focus_tag == "two_slices" or wait == "seat" or wait == "mill_done"
	if mill == "seat":
		_arm = 1.6
	elif mill == "upgrade":
		_arm = 2.4
	elif mill == "fill":
		_arm = 0.4
	if mill != "":
		call_deferred("_emit_mill", mill)
	if wait == "spin" and bool(p.get("auto", false)):
		call_deferred("_emit_auto_spin")
	elif wait == "walk":
		_start_walk()
	elif wait == "end":
		_show_end()


func _hint_for(w: String) -> String:
	match w:
		"spin":
			return "(click Spin)"
		"item:sai":
			return "(click the Sai)"
		"item:helmet":
			return "(click the Helmet)"
		"done":
			return "(click Safe)"
		"choice":
			return "(Da Boot, or Take 3)"
		"hover_shift":
			return "(hover the monster, hold Shift)"
		"hover_item":
			return "(hover Da Boot, or hold Shift)"
		"gate_take":
			return "(click the relic to Take it)"
		"seat":
			return "(click an empty Corridor)"
		"mill_done":
			return "(fill every Corridor)"
		_:
			return ""


func _emit_auto_spin() -> void:
	if wait == "spin":
		auto_spin.emit()


func _emit_mill(kind: String) -> void:
	mill_demo.emit(kind)


func _start_walk() -> void:
	_walking = true
	_walk_off = true
	if box:
		box.visible = false
	_walking = false
	call_deferred("advance")


func _show_end() -> void:
	wait = "end"
	focus_tag = ""
	_nib = "normal"
	if box and box.has_method("show_end"):
		box.visible = true
		box.show_end()


func _sync_dim_clicks() -> void:
	pass


func _set_body(raw: String, tiny: bool = false) -> void:
	if box and box.has_method("set_speech"):
		box.set_speech(_markup_body(raw), tiny)


func _markup_body(raw: String) -> String:
	var s: String = raw
	s = s.replace("(colored purple like the item)", "")
	s = s.replace("(bolded/colored)", "")
	s = s.replace("(colored/bolded)", "")
	s = s.replace("(color/bold)", "")
	s = s.replace("(colored)", "")
	s = UX.paint(s, true)
	s = _paint_named(s, "Da Boot", UX.VAR)
	s = _paint_named(s, "Shift", "#E8C36A")
	s = _paint_named(s, "Corridor", "#E8C36A")
	return s


func _paint_named(s: String, name: String, hex: String) -> String:
	if s.find(name) < 0:
		return s
	return s.replace(name, UX.chip(name, hex))


func _parse_script(raw: String) -> Array:
	var pages: Array = []
	var pending_focus := ""
	var pending_nib := "normal"
	var branch := ""
	var buf: Array = []
	var lines: PackedStringArray = raw.replace("\r\n", "\n").split("\n")
	for line in lines:
		var t: String = str(line).strip_edges()
		if t == "":
			continue
		var low: String = t.to_lower()
		if low.begins_with("---joins"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			branch = ""
			pending_focus = ""
			continue
		if low.begins_with("---") and "da boot" in low:
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			branch = "boot"
			pending_focus = ""
			continue
		if low.begins_with("---") and "take 3" in low:
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			branch = "take"
			pending_focus = ""
			continue
		if low.begins_with("(only now"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pages.append(_page("", "", pending_nib, branch, "spin", "golem", true, false, "Next"))
			pending_focus = ""
			continue
		if low.begins_with("(animates nib"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pages.append(_page("", "", "walk", branch, "walk", "", false, false, "Next"))
			continue
		if low.begins_with("(vignette"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pages.append(_page("", "", "normal", branch, "end", "", false, false, "Next"))
			continue
		if low.begins_with("(when the user hovers and holds shift"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "hover_shift", "", false, false)
			pending_focus = "inspect"
			continue
		if low.begins_with("(when the user hovers or holds shift"):
			_flush(pages, buf, pending_focus, pending_nib, branch, "hover_item", "", false, false)
			continue
		if low.begins_with("(click 'spin") or low.begins_with("(click \"spin") or low.begins_with("(click spin"):
			var sid := ""
			if "wizard" in low:
				sid = "wizard"
			elif "golem" in low:
				sid = "golem"
			elif "goblin" in low:
				sid = "goblin"
			_flush(pages, buf, "spin", pending_nib, branch, "spin", sid, false, false)
			pending_focus = ""
			continue
		if "click the sai" in low:
			_flush(pages, buf, "item:sai", pending_nib, branch, "item:sai", "", false, false)
			pending_focus = ""
			continue
		if "click the helmet" in low:
			_flush(pages, buf, "item:helmet", pending_nib, branch, "item:helmet", "", false, false)
			pending_focus = ""
			continue
		if "click 'safe" in low or "click \"safe" in low:
			_flush(pages, buf, "done", pending_nib, branch, "done", "", false, false)
			pending_focus = ""
			continue
		if low.begins_with("(the player will click"):
			_flush(pages, buf, "choice", pending_nib, branch, "choice", "", false, false)
			pending_focus = ""
			continue
		if low.begins_with("(click"):
			if pending_focus == "done" and "safe" not in low and "got it" not in low:
				continue
			var go := "Got It" if "got it" in low else "Next"
			_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false, go)
			continue
		if low.begins_with("(highlight"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_focus = _highlight_tag(t)
			continue
		if low.begins_with("(sprite of nib") or low.begins_with("(nib moves close"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_nib = "close"
			continue
		if low.begins_with("(comes closer"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_nib = "closer"
			continue
		if low.begins_with("(nib gets 50%"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_nib = "lean"
			continue
		if low.begins_with("(nib moves to center"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_nib = "center"
			continue
		if low.begins_with("(returns") or low.begins_with("(nib returns"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			pending_nib = "normal"
			continue
		if low.begins_with("(in very tiny"):
			if buf.size() > 0:
				_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
			var joke: String = t
			var dash: int = t.find(") - ")
			if dash >= 0:
				joke = t.substr(dash + 4).strip_edges()
			var joke_buf: Array = ["[i]%s[/i]" % joke]
			_flush(pages, joke_buf, pending_focus, "normal", branch, "continue", "", true, false)
			continue
		buf.append(t)
	_flush(pages, buf, pending_focus, pending_nib, branch, "continue", "", false, false)
	return pages


func _flush(pages: Array, buf: Array, focus: String, nib: String, branch: String, wait_s: String, sid: String, tiny: bool, auto: bool, go: String = "Next") -> void:
	if buf.size() == 0:
		return
	var body: String = " ".join(buf)
	pages.append(_page(body, focus, nib, branch, wait_s, sid, auto, tiny, go))
	var low: String = body.to_lower()
	if "draft new" in low or "remaining items" in low:
		pages.append_array(_draft_lesson_pages())
	buf.clear()


func _draft_lesson_pages() -> Array:
	var door: Dictionary = _page("Alright, drafting. See that door? Somebody wants in, and they're dangling loot so you'll let them.", "gate", "normal", "", "continue", "", false, false, "Next")
	door["mill"] = "draft"
	var fill: Dictionary = _page("Fill every Corridor. Take or leave, then seat, until the wheel is full. I'll zip it until you're done.", "empty_slice", "normal", "", "mill_done", "", false, false, "Next")
	fill["mill"] = "fill"
	return [
		door,
		_page("Click the relic to Take it. That's how you accept a petitioner.", "gate_take", "normal", "", "gate_take", "", false, false, "Next"),
		_page("They're in. Click an empty Corridor to seat them. Where they sit matters later, so spread them out if you can.", "empty_slice", "normal", "", "seat", "", false, false, "Next"),
		_page("Whatever they were carrying is yours now. It lands in your loot next to whatever you didn't spend.", "hotbar", "normal", "", "continue", "", false, false, "Next"),
		_page("Ugly customer? Click Leave it. You only get a few of those, then the dungeon seats the rest for you.", "gate_leave", "normal", "", "continue", "", false, false, "Next"),
		fill,
	]


func _page(body: String, focus: String, nib: String, branch: String, wait_s: String, sid: String, auto: bool, tiny: bool, go: String) -> Dictionary:
	var f: String = focus
	if wait_s == "spin" and f == "":
		f = "spin"
	if wait_s.begins_with("item:") and f == "":
		f = wait_s
	if wait_s == "done" and f == "":
		f = "done"
	var mill := ""
	var low: String = body.to_lower()
	if "will be upgraded" in low or "more dangerous" in low:
		mill = "upgrade"
	elif "starting monster" in low:
		mill = "seat"
	elif "draft new" in low or "remaining items" in low:
		mill = ""
	return {
		"body": body,
		"focus": f,
		"nib": nib,
		"branch": branch,
		"wait": wait_s,
		"spin_id": sid,
		"auto": auto,
		"tiny": tiny,
		"go": go,
		"mill": mill,
	}


func _highlight_tag(t: String) -> String:
	var low: String = t.to_lower()
	if "empty" in low or "slice of dungeon" in low:
		return "empty_slice"
	if "2 random" in low or "two random" in low:
		return "two_slices"
	if "wizard" in low and "attack" in low:
		return "wizard_atk"
	if "wizard" in low and ("hp" in low or "health" in low):
		return "wizard_hp"
	if "both" in low and "hp" in low:
		return "both_hp"
	if "sai" in low:
		return "item:sai"
	if "helmet" in low:
		return "item:helmet"
	if "da boot" in low or "'da boot'" in low:
		return "item:da_boot"
	if "block icon" in low:
		return "block"
	if "healthbar" in low or "health bar" in low:
		return "hearts"
	if "detail" in low or "inspect" in low or "panel to the right" in low:
		return "inspect"
	if "safe" in low:
		return "done"
	if "monster card" in low:
		return "monster"
	if "hotbar" in low or "loot" in low:
		return "hotbar"
	if "wheel" in low:
		return "wheel"
	return ""


func nudge(msg: String) -> void:
	if box and box.has_method("set_nudge"):
		box.set_nudge(msg)


func armed() -> bool:
	return _arm <= 0.0


func follow(target: Control) -> void:
	_targets.clear()
	_target = target
	if target != null:
		_targets.append(target)


func follow_many(arr: Array) -> void:
	_targets.clear()
	for x in arr:
		if x != null and is_instance_valid(x):
			_targets.append(x)
	_target = _targets[0] if _targets.size() > 0 else null


func _process(delta: float) -> void:
	if not visible:
		_hide_spots()
		return
	_arm = maxf(0.0, _arm - delta)
	_sync_spots()


func _layout() -> void:
	pass


func _spot_rects(vp: Vector2) -> Array:
	var spots: Array = []
	for x in _targets:
		if x == null or not is_instance_valid(x) or not x.is_visible_in_tree():
			continue
		var r: Rect2 = x.get_global_rect().grow(PAD)
		r.position.x = clampf(r.position.x, 0.0, vp.x)
		r.position.y = clampf(r.position.y, 0.0, vp.y)
		if r.size.x >= 8.0 and r.size.y >= 8.0:
			spots.append(r)
	return spots


func _place_rings(spots: Array) -> void:
	var cutaway: bool = _nib == "close" or _nib == "closer"
	var hide: bool = cutaway or wait == "end" or wait == "walk" or _cone
	for i in _rings.size():
		var ring: Panel = _rings[i]
		if hide or i >= spots.size():
			ring.visible = false
			continue
		var r: Rect2 = spots[i]
		ring.visible = true
		ring.global_position = r.position
		ring.size = r.size
		var sb: StyleBoxFlat = ring.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			var pulse: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.007)
			sb.border_color = Color(1.0, 0.86, 0.38, 0.55 + 0.45 * pulse)
			sb.set_border_width_all(3)


func _pick_talk_pos(hole: Rect2, vp: Vector2, ts: Vector2) -> Vector2:
	var dock: bool = wait == "gate_take" or wait == "seat" or wait == "mill_done" or focus_tag.begins_with("gate")
	if dock:
		return _clamp_talk(Vector2(12.0, 12.0), vp, ts)
	if _nib == "close" or _nib == "closer":
		return _clamp_talk(Vector2((vp.x - ts.x) * 0.5, vp.y * 0.10), vp, ts)
	var top := Vector2((vp.x - ts.x) * 0.5, 16.0)
	var mid := Vector2((vp.x - ts.x) * 0.5, (vp.y - ts.y) * 0.34)
	if hole.size.x < 8.0:
		return _clamp_talk(mid, vp, ts)
	var opts: Array = [
		Vector2((vp.x - ts.x) * 0.5, hole.position.y - ts.y - 18.0),
		Vector2(hole.position.x - ts.x - 18.0, hole.position.y),
		Vector2(hole.end.x + 18.0, hole.position.y),
		Vector2((vp.x - ts.x) * 0.5, hole.end.y + 18.0),
		top,
	]
	for o in opts:
		var p: Vector2 = _clamp_talk(o, vp, ts)
		var r := Rect2(p, ts)
		if not r.intersects(hole.grow(8.0)):
			return p
	return _clamp_talk(top, vp, ts)


func _clamp_talk(p: Vector2, vp: Vector2, ts: Vector2) -> Vector2:
	return Vector2(
		clampf(p.x, 8.0, maxf(8.0, vp.x - ts.x - 8.0)),
		clampf(p.y, 8.0, maxf(8.0, vp.y - ts.y - 8.0))
	)


func _layout_nib(vp: Vector2, talk_rect: Rect2, hole: Rect2) -> void:
	if _big == null:
		return
	var close: bool = _nib == "close" or _nib == "closer" or _nib == "lean"
	_big.visible = close and not _frames.is_empty() and wait != "end" and wait != "walk"
	if _face:
		_face.visible = not close
	if not _big.visible:
		return
	var cutaway: bool = _nib == "close" or _nib == "closer"
	var frac: float = 0.70
	if _nib == "closer":
		frac = 0.78
	elif _nib == "lean":
		frac = 0.48
	var side: float = minf(vp.x, vp.y) * frac
	_big.size = Vector2(side, side * 1.28)
	if cutaway:
		_big.position = Vector2((vp.x - _big.size.x) * 0.5, (vp.y - _big.size.y) * 0.42)
		if talk_rect.size.y > 8.0 and _talk:
			var head: Vector2 = Vector2(
				_big.position.x + _big.size.x * 0.62,
				_big.position.y + _big.size.y * 0.08
			)
			_talk.global_position = _clamp_talk(head - Vector2(24.0, talk_rect.size.y * 0.15), vp, talk_rect.size)
		return
	var x: float = (vp.x - _big.size.x) * 0.5
	var y: float = (vp.y - _big.size.y) * 0.38
	if hole.size.x >= 8.0:
		var hole_c: float = hole.position.x + hole.size.x * 0.5
		if hole_c < vp.x * 0.5:
			x = minf(vp.x - _big.size.x - 8.0, hole.end.x + 12.0)
		else:
			x = maxf(8.0, hole.position.x - _big.size.x - 12.0)
	_big.position = Vector2(x, clampf(y, 8.0, maxf(8.0, vp.y - _big.size.y - 8.0)))


func _place_dims(_vp: Vector2) -> void:
	pass


func _hide_spots() -> void:
	if _spot_wheel:
		_spot_wheel.visible = false
	for tr in _spot_seats:
		if tr != null:
			tr.visible = false


func _seat_ring() -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/ui_spotlight_ring_seat.png")
	tr.size = Vector2(106, 106)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP
	tr.texture_filter = TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.visible = false
	add_child(tr)
	_spot_seats.append(tr)
	return tr


func _sync_spots() -> void:
	if wait == "end" or wait == "walk":
		_hide_spots()
		return
	var pulse: float = 0.4 + 0.6 * (0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.007))
	var spots: Array = _spot_rects(get_viewport_rect().size)
	var wheel_on: bool = spots.is_empty() or focus_tag == "wheel" or focus_tag == ""
	var seat_i: int = 0
	if not wheel_on:
		for r in spots:
			if minf(r.size.x, r.size.y) >= 160.0:
				wheel_on = true
				continue
			while _spot_seats.size() <= seat_i:
				_seat_ring()
			var tr: TextureRect = _spot_seats[seat_i]
			tr.visible = true
			tr.modulate.a = pulse
			tr.global_position = r.get_center() - Vector2(53, 53)
			seat_i += 1
	if _spot_wheel:
		_spot_wheel.visible = wheel_on
		_spot_wheel.modulate.a = pulse
		_spot_wheel.position = Vector2(215, 17)
	for i in _spot_seats.size():
		if i >= seat_i:
			_spot_seats[i].visible = false
