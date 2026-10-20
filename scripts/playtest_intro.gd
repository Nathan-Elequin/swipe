extends ColorRect
## First-open playtest talk. Nib's face, Nathan's name. Skip, Back, click anywhere.

signal finished
signal skipped
signal wants_f2(on: bool)
signal wants_fab(on: bool)

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")

const TALK_W := 520.0
const EDGE := 16.0
const GAP := 16.0

var step: int = -1
var sfx
var _arm: float = 0.0
var _frames: Array = []
var _fi: float = 0.0
var _talk: PanelContainer
var _face: TextureRect
var _name
var _body
var _go: Button
var _skip: Button
var _back: Button
var _ring: Panel
var _mock: VBoxContainer
var _btn_new: Button
var _btn_mid: Button
var _btn_cont: Button
var _btn_feed: Button
var _beats: Array = []
var _pin_fab: Control
var _pin_send: Control
var _pin_panel: Control
var _bold_re: RegEx


func setup(art, p_sfx = null, fab: Control = null, send_btn: Control = null) -> void:
	sfx = p_sfx
	_pin_fab = fab
	_pin_send = send_btn
	_bold_re = RegEx.new()
	_bold_re.compile("\\*\\*(.+?)\\*\\*")
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color("100e0c")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 135
	visible = false
	name = "playtest_intro"
	gui_input.connect(_on_catch)
	if art != null:
		var bust: Texture2D = art.home_tex("nib/nib_bust_f0") if art.has_method("home_tex") else null
		if bust != null:
			_frames = [bust]
			var blink: Texture2D = art.home_tex("nib/nib_bust_blink")
			if blink != null:
				_frames.append(blink)
		if _frames.is_empty() and art.has_method("nib_frames"):
			_frames = art.nib_frames()
	_build_mock()
	_build_ring()
	_build_talk()
	set_process(true)


func pin_send(btn: Control) -> void:
	_pin_send = btn


func pin_panel(panel: Control) -> void:
	_pin_panel = panel


func open_intro() -> void:
	_beats = _beats_of()
	step = -1
	visible = true
	move_to_front()
	_advance()


func close_intro() -> void:
	visible = false
	step = -1
	wants_f2.emit(false)
	wants_fab.emit(false)


func showing_fab() -> bool:
	return visible and _tag() == "fab"


func _beats_of() -> Array:
	return [
		{"key": "playtest.intro.01", "fallback": "Hey friends — thanks for playtesting my game, Swipe.\nJust a few notes before you jump in."},
		{"key": "playtest.intro.02", "fallback": "First. This game is in early prototype mode. The things I most want to hear from your feedback are about what is fun, what is boring, what is confusing, and what things you think I should add to the game."},
		{"key": "playtest.intro.03", "fallback": "Second. Be honest and picky! You don't need to consider anyone else's perspective. I just want to hear yours."},
		{"key": "playtest.intro.04", "fallback": "And finally, have fun! Break the game, find cool combos, test the limits. And don't be afraid to dream big with your requests."},
		{"key": "playtest.intro.05", "fallback": "This is the menu you'll land on.", "focus": "hub"},
		{"key": "playtest.intro.06", "fallback": "**Brand New** starts from the beginning, as if you had never played.", "focus": "new"},
		{"key": "playtest.intro.07", "fallback": "**Middle Progress** puts you a few dungeons in, with some items already unlocked.", "focus": "mid"},
		{"key": "playtest.intro.08", "fallback": "**Continue** picks up your last playtest save.", "focus": "cont"},
		{"key": "playtest.intro.09", "fallback": "**Feedback** opens a note to me. Use it for anything that is not tied to one card.", "focus": "feed"},
		{"key": "playtest.intro.10", "fallback": "You can right-click any item or monster in the game and leave feedback. That is useful for bugs, confusion, or balance issues.", "focus": "hub"},
		{"key": "playtest.intro.11", "fallback": "For general comments while you play, click **Feedback** in the bottom right, or press **F2**.", "focus": "fab"},
		{"key": "playtest.intro.12", "fallback": "This is the F2 screen. Type a note, click Send, and it goes to my game development console. Next time I sit down to work, I will see it and can make the fix or the change.", "focus": "send"},
		{"key": "playtest.intro.13", "fallback": "However — for those who want to give the best kind of feedback, I would love to actually HEAR your experience."},
		{"key": "playtest.intro.14", "fallback": "Consider taking your phone, setting it to a voice memo or recorder, and just letting it run while you play. Talk out loud about your thought process, your first impressions, your feedback, anything at all."},
		{"key": "playtest.intro.15", "fallback": "Then send me the entire file when you are done, because I can turn that into a much more detailed look at your player experience. If you are interested in doing that, you can email the files to me at nathan.elequin@gmail.com."},
		{"key": "playtest.intro.16", "fallback": "So thank you again for playtesting. If you have any questions, you can always reach out to me. Now enjoy!", "go": "done"},
	]


func _tag() -> String:
	if step < 0 or step >= _beats.size():
		return ""
	return str(_beats[step].get("focus", ""))


func _advance() -> void:
	step += 1
	if step >= _beats.size():
		finished.emit()
		return
	_show()


func _back_step() -> void:
	if step <= 0:
		return
	step -= 2
	if step < -1:
		step = -1
	_advance()


func _show() -> void:
	if _beats.is_empty():
		_beats = _beats_of()
	var b: Dictionary = _beats[step]
	var raw: String = COPY.text(str(b.get("key", "")), str(b.get("fallback", "")))
	var spoken: String = _md_bold(raw)
	_body.clear()
	_body.append_text(spoken)
	if sfx and sfx.has_method("speak"):
		sfx.speak(&"nib", raw)
	_name.set_plain(COPY.text("playtest.intro.speaker", "Nathan"))
	var go_kind: String = str(b.get("go", ""))
	_go.text = COPY.text("playtest.intro.done", "Continue") if go_kind == "done" else COPY.text("tutorial.next", "Next")
	_skip.text = COPY.text("tutorial.skip", "Skip")
	_back.text = COPY.text("playtest.intro.back", "Back")
	_skip.visible = true
	_go.visible = true
	_back.visible = step > 0
	_arm = 0.35
	var tag: String = str(b.get("focus", ""))
	var on_hub: bool = tag in ["hub", "new", "mid", "cont", "feed"]
	_mock.visible = on_hub
	wants_fab.emit(tag == "fab")
	wants_f2.emit(tag == "send")
	_talk.reset_size()


func _process(delta: float) -> void:
	if not visible:
		return
	if _arm > 0.0:
		_arm -= delta
	if not _frames.is_empty() and _face != null:
		_fi += delta * 3.0
		_face.texture = _frames[int(_fi) % _frames.size()]
	_place_talk()
	_place_ring()


func _place_talk() -> void:
	var vp: Vector2 = get_viewport_rect().size
	_talk.reset_size()
	var ts: Vector2 = _talk.get_combined_minimum_size()
	ts.x = maxf(ts.x, TALK_W)
	_talk.size = ts
	if _mock.visible:
		_mock.reset_size()
		var ms: Vector2 = _mock.get_combined_minimum_size()
		if ms.x < 8.0:
			ms = _mock.size
		_mock.size = ms
		var mx: float = (vp.x - ms.x) * 0.5
		var my: float = EDGE + ts.y + GAP
		if my + ms.y > vp.y - EDGE:
			my = maxf(EDGE, vp.y - EDGE - ms.y)
		_mock.position = Vector2(mx, my)
	var pos := Vector2((vp.x - ts.x) * 0.5, (vp.y - ts.y) * 0.5)
	var tag: String = _tag()
	var block := Rect2()
	if tag in ["hub", "new", "mid", "cont", "feed"] and _mock.visible:
		block = _mock.get_global_rect()
	elif tag == "send" and _pin_panel != null and is_instance_valid(_pin_panel) and _pin_panel.is_visible_in_tree():
		block = _pin_panel.get_global_rect()
	elif tag == "fab" and _pin_fab != null and is_instance_valid(_pin_fab) and _pin_fab.is_visible_in_tree():
		var centered := Rect2(pos, ts)
		var fab_r: Rect2 = _pin_fab.get_global_rect()
		if centered.grow(GAP).intersects(fab_r):
			block = fab_r
	if block.size.x > 4.0:
		pos = _highest_free(ts, vp, block.grow(GAP))
	pos.x = clampf(pos.x, EDGE, maxf(EDGE, vp.x - ts.x - EDGE))
	pos.y = clampf(pos.y, EDGE, maxf(EDGE, vp.y - ts.y - EDGE))
	_talk.global_position = pos


func _highest_free(ts: Vector2, vp: Vector2, block: Rect2) -> Vector2:
	var x: float = (vp.x - ts.x) * 0.5
	var y: float = EDGE
	var box := Rect2(Vector2(x, y), ts)
	if box.intersects(block):
		var above: float = block.position.y - ts.y
		if above >= EDGE:
			y = above
		else:
			y = block.end.y
	return Vector2(x, y)


func _md_bold(raw: String) -> String:
	if _bold_re == null:
		return raw
	return _bold_re.sub(raw, "[b]$1[/b]", true)


func _place_ring() -> void:
	var tag: String = _tag()
	var target: Control = null
	match tag:
		"hub":
			target = _mock
		"new":
			target = _btn_new
		"mid":
			target = _btn_mid
		"cont":
			target = _btn_cont
		"feed":
			target = _btn_feed
		"fab":
			target = _pin_fab
		"send":
			target = _pin_send
	if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
		_ring.visible = false
		return
	var r: Rect2 = target.get_global_rect().grow(8.0)
	_ring.visible = true
	_ring.global_position = r.position
	_ring.size = r.size


func _armed() -> bool:
	return _arm <= 0.0


func _on_catch(event: InputEvent) -> void:
	if not _is_advance_click(event):
		return
	_advance()
	accept_event()


func _on_talk_gui(event: InputEvent) -> void:
	if not _is_advance_click(event):
		return
	var hover: Control = get_viewport().gui_get_hovered_control()
	if hover == _go or hover == _skip or hover == _back:
		return
	_advance()
	accept_event()


func _is_advance_click(event: InputEvent) -> bool:
	if not visible or not _armed():
		return false
	return event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.double_click


func _build_mock() -> void:
	_mock = VBoxContainer.new()
	_mock.alignment = BoxContainer.ALIGNMENT_CENTER
	_mock.add_theme_constant_override("separation", 14)
	_mock.custom_minimum_size = Vector2(320, 0)
	_mock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mock)
	var title := Label.new()
	title.text = COPY.text("playtest.hub_title", "Playtest")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("e8c36a"))
	title.add_theme_color_override("font_outline_color", Color("100e0c"))
	title.add_theme_constant_override("outline_size", 3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mock.add_child(title)
	_btn_new = _fake_btn(COPY.text("playtest.brand_new", "Brand New"))
	_btn_mid = _fake_btn(COPY.text("playtest.middle", "Middle Progress"))
	_btn_cont = _fake_btn(COPY.text("playtest.continue", "Continue"))
	_btn_feed = _fake_btn(COPY.text("playtest.feedback", "Feedback"))
	_mock.add_child(_btn_new)
	_mock.add_child(_btn_mid)
	_mock.add_child(_btn_cont)
	_mock.add_child(_btn_feed)
	_mock.visible = false


func _fake_btn(label: String) -> Button:
	var b := Button.new()
	b.text = label
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UX.dress_title_button(b, 280)
	return b


func _build_ring() -> void:
	_ring = Panel.new()
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.top_level = true
	_ring.z_index = 149
	var rs := StyleBoxFlat.new()
	rs.bg_color = Color(0, 0, 0, 0)
	rs.border_color = Color("e8c36a")
	rs.set_border_width_all(3)
	rs.set_corner_radius_all(10)
	_ring.add_theme_stylebox_override("panel", rs)
	_ring.visible = false
	add_child(_ring)


func _build_talk() -> void:
	_talk = PanelContainer.new()
	_talk.mouse_filter = Control.MOUSE_FILTER_STOP
	_talk.custom_minimum_size = Vector2(TALK_W, 0)
	_talk.top_level = true
	_talk.z_index = 150
	_talk.gui_input.connect(_on_talk_gui)
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
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 10)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_talk.add_child(wrap)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(row)
	_face = TextureRect.new()
	_face.custom_minimum_size = Vector2(72, 120)
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
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	_name = FitLabelBox.make()
	_name.show_frame = false
	_name.padding = 0
	_name.max_font_size = 18
	_name.min_font_size = 12
	_name.font_color = Color("e8c36a")
	_name.custom_minimum_size = Vector2(320, 24)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_name)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.fit_content = true
	_body.scroll_active = false
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_color_override("default_color", Color("f4ede3"))
	_body.add_theme_font_size_override("normal_font_size", 18)
	_body.custom_minimum_size = Vector2(320, 48)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_body)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_END
	btns.add_theme_constant_override("separation", 8)
	wrap.add_child(btns)
	_skip = _talk_btn(COPY.text("tutorial.skip", "Skip"), func() -> void: skipped.emit())
	_back = _talk_btn(COPY.text("playtest.intro.back", "Back"), func() -> void: _back_step())
	_go = _talk_btn(COPY.text("tutorial.next", "Next"), func() -> void: _advance())
	_go.custom_minimum_size = Vector2(108, 44)
	btns.add_child(_skip)
	btns.add_child(_back)
	btns.add_child(_go)


func _talk_btn(label: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(108, 44)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_color_override("font_color", Color("1c120c"))
	var s := StyleBoxFlat.new()
	s.bg_color = Color("fff3d6")
	s.border_color = Color("3a2414")
	s.set_border_width_all(2)
	s.set_corner_radius_all(999)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	b.add_theme_stylebox_override("normal", s)
	var h := s.duplicate() as StyleBoxFlat
	h.bg_color = Color("fff3d6").lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b
