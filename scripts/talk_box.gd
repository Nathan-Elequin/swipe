extends VBoxContainer
## How to Play plate: Nib talks from the column. Driven by tutorial_guide.

signal go_pressed
signal skip_pressed
signal talk_clicked
signal play_pressed

const COPY := preload("res://scripts/player_copy.gd")

const IMP := Color("7BC950")
const VOID := Color("0B0706")
const PARCHMENT := Color("E9D3A1")
const EDGE := Color("7A4E2B")
const SOOT := Color("1A120E")
const GOLD := Color("FFD84A")
const DIM := Color("A88C66")
const TYPE_RATE := 60.0

var btn_skip: Button
var btn_go: Button
var _face: TextureRect
var _speaker: Label
var _body: RichTextLabel
var _talk: PanelContainer
var _nudge: Label
var _ticks: HBoxContainer
var _head: Label
var _frames: Array = []
var _fi: float = 0.0
var _typed: float = 0.0
var _full_len: int = 0
var _talking: bool = false
var _font_px: Font
var _font_vt: Font
var _end_mode: bool = false


func setup(art) -> void:
	theme = load("res://themes/swipe_theme.tres")
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	add_theme_constant_override("separation", 16)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(480, 520)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	_frames.clear()
	if art != null:
		if art.has_method("nib_frames"):
			_frames = art.nib_frames("talk")
			if _frames.is_empty():
				_frames = art.nib_frames("idle")
		if _frames.is_empty() and art.has_method("nib_portrait"):
			var port: Texture2D = art.nib_portrait()
			if port != null:
				_frames = [port]
	_build()
	set_process(true)


func _build() -> void:
	_head = Label.new()
	_head.text = COPY.need("title.how_to_play")
	_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if _font_vt != null:
		_head.add_theme_font_override("font", _font_vt)
	_head.add_theme_font_size_override("font_size", 26)
	_head.add_theme_color_override("font_color", DIM)
	_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_head)

	var hero := HBoxContainer.new()
	hero.add_theme_constant_override("separation", 16)
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hero)
	var well := PanelContainer.new()
	well.custom_minimum_size = Vector2(150, 150)
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wsb := StyleBoxFlat.new()
	wsb.bg_color = VOID
	wsb.border_color = IMP
	wsb.set_border_width_all(6)
	well.add_theme_stylebox_override("panel", wsb)
	hero.add_child(well)
	_face = TextureRect.new()
	_face.custom_minimum_size = Vector2(128, 128)
	_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_face.texture_filter = TEXTURE_FILTER_NEAREST
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _frames.is_empty():
		_face.texture = _frames[0]
	well.add_child(_face)
	_speaker = Label.new()
	_speaker.text = COPY.need("tutorial.speaker")
	_speaker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_px != null:
		_speaker.add_theme_font_override("font", _font_px)
	_speaker.add_theme_font_size_override("font_size", 42)
	_speaker.add_theme_color_override("font_color", IMP)
	_speaker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_speaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(_speaker)

	var talk_wrap := Control.new()
	talk_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	talk_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	talk_wrap.custom_minimum_size = Vector2(0, 220)
	talk_wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	talk_wrap.gui_input.connect(_on_talk_input)
	add_child(talk_wrap)
	_talk = PanelContainer.new()
	_talk.set_anchors_preset(PRESET_FULL_RECT)
	_talk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tsb := StyleBoxTexture.new()
	tsb.texture = load("res://assets/ui/ui_talkbox.png")
	tsb.texture_margin_left = 96
	tsb.texture_margin_top = 22
	tsb.texture_margin_right = 12
	tsb.texture_margin_bottom = 12
	tsb.content_margin_left = 28
	tsb.content_margin_top = 44
	tsb.content_margin_right = 28
	tsb.content_margin_bottom = 28
	_talk.add_theme_stylebox_override("panel", tsb)
	talk_wrap.add_child(_talk)
	var tcol := VBoxContainer.new()
	tcol.add_theme_constant_override("separation", 8)
	tcol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_talk.add_child(tcol)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.fit_content = true
	_body.scroll_active = false
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if _font_vt != null:
		_body.add_theme_font_override("normal_font", _font_vt)
		_body.add_theme_font_override("bold_font", _font_vt)
		_body.add_theme_font_override("italics_font", _font_vt)
	_body.add_theme_font_size_override("normal_font_size", 32)
	_body.add_theme_font_size_override("bold_font_size", 32)
	_body.add_theme_font_size_override("italics_font_size", 32)
	_body.add_theme_color_override("default_color", SOOT)
	_body.add_theme_constant_override("line_separation", 4)
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tcol.add_child(_body)
	_nudge = Label.new()
	_nudge.visible = false
	_nudge.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_vt != null:
		_nudge.add_theme_font_override("font", _font_vt)
	_nudge.add_theme_font_size_override("font_size", 26)
	_nudge.add_theme_color_override("font_color", DIM)
	_nudge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tcol.add_child(_nudge)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spacer)

	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 14)
	add_child(btns)
	btn_skip = Button.new()
	btn_skip.text = COPY.need("tutorial.skip")
	btn_skip.custom_minimum_size = Vector2(150, 64)
	btn_skip.theme_type_variation = "ButtonOak"
	btn_skip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_vt != null:
		btn_skip.add_theme_font_override("font", _font_vt)
	btn_skip.add_theme_font_size_override("font_size", 30)
	btn_skip.add_theme_color_override("font_color", PARCHMENT)
	btn_skip.pressed.connect(func() -> void: skip_pressed.emit())
	btns.add_child(btn_skip)
	btn_go = Button.new()
	btn_go.text = COPY.need("tutorial.beat.01.go")
	btn_go.custom_minimum_size = Vector2(0, 76)
	btn_go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_go.theme_type_variation = "ButtonGold"
	btn_go.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		btn_go.add_theme_font_override("font", _font_px)
	btn_go.add_theme_font_size_override("font_size", 40)
	btn_go.add_theme_color_override("font_color", SOOT)
	btn_go.pressed.connect(_on_go)
	btns.add_child(btn_go)

	_ticks = HBoxContainer.new()
	_ticks.alignment = BoxContainer.ALIGNMENT_CENTER
	_ticks.add_theme_constant_override("separation", 8)
	_ticks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ticks)


func set_speech(bb: String, tiny: bool = false) -> void:
	_end_mode = false
	visible = true
	if _head:
		_head.visible = true
	if btn_skip:
		btn_skip.visible = true
		btn_skip.text = COPY.need("tutorial.skip")
	_body.text = bb
	_body.visible_characters = 0
	_typed = 0.0
	_talking = true
	call_deferred("_begin_type")
	if tiny:
		_body.add_theme_font_size_override("normal_font_size", 22)
	else:
		_body.add_theme_font_size_override("normal_font_size", 32)
	if _speaker:
		_speaker.text = COPY.need("tutorial.speaker")
	play_pop()


func _begin_type() -> void:
	_full_len = _body.get_total_character_count()
	if _full_len <= 0:
		finish_speech()


func finish_speech() -> void:
	_typed = float(_full_len)
	_body.visible_characters = -1
	_talking = false


func is_typing() -> bool:
	return _talking


func set_go(text: String, show: bool = true) -> void:
	if btn_go == null:
		return
	btn_go.visible = show
	if text.strip_edges() != "":
		btn_go.text = text
	btn_go.disabled = false


func set_nudge(text: String) -> void:
	if _nudge == null:
		return
	_nudge.text = text
	_nudge.visible = text.strip_edges() != ""


func set_progress(done: int, total: int) -> void:
	if _ticks == null:
		return
	for c in _ticks.get_children():
		_ticks.remove_child(c)
		c.queue_free()
	var n: int = mini(maxi(total, 1), 12)
	for i in n:
		var t := ColorRect.new()
		t.custom_minimum_size = Vector2(22, 8)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.color = GOLD if i < done else EDGE
		_ticks.add_child(t)


func show_end() -> void:
	_end_mode = true
	visible = true
	finish_speech()
	if _body:
		_body.text = ""
	if _nudge:
		_nudge.visible = false
	if btn_go:
		btn_go.visible = true
		btn_go.text = COPY.need("title.begin")
		btn_go.disabled = false
	if btn_skip:
		btn_skip.visible = true
		btn_skip.text = COPY.need("tutorial.skip")


func play_pop() -> void:
	if _talk == null:
		return
	_talk.pivot_offset = _talk.size * 0.5
	_talk.scale = Vector2(0.85, 0.85)
	_talk.modulate.a = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_talk, "scale", Vector2.ONE, 0.18)
	tw.parallel().tween_property(_talk, "modulate:a", 1.0, 0.12)


func _on_go() -> void:
	if _end_mode:
		play_pressed.emit()
		return
	if _talking:
		finish_speech()
		return
	go_pressed.emit()


func _on_talk_input(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT):
		return
	if _talking:
		finish_speech()
		accept_event()
		return
	talk_clicked.emit()


func _process(delta: float) -> void:
	if not visible:
		return
	if _talking:
		_typed += delta * TYPE_RATE
		var shown: int = mini(int(_typed), _full_len)
		_body.visible_characters = shown
		if shown >= _full_len:
			finish_speech()
	if _frames.is_empty() or _face == null:
		return
	if _talking:
		_fi += delta * 8.0
		_face.texture = _frames[int(_fi) % _frames.size()]
	elif _face.texture != _frames[0]:
		_face.texture = _frames[0]
