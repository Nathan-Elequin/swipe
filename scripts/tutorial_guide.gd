extends Control
## Vignette, hole, and Nib's talk box. No new screens — sits on the live board.

const COPY := preload("res://scripts/player_copy.gd")

signal continued
signal skipped
signal finished

const PAD := 10.0
const TALK_W := 340.0

var step: int = -1
var wait: String = ""
var focus_tag: String = ""
var _arm: float = 0.0
var _frames: Array = []
var _fi: float = 0.0
var _dim: Array = []
var _ring: Panel
var _talk: PanelContainer
var _face: TextureRect
var _name: Label
var _body: Label
var _hint: Label
var _go: Button
var _skip: Button
var _target: Control


func setup(art) -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 70
	top_level = true
	visible = false
	if art != null:
		_frames = art.frames("goblin")
		if _frames.is_empty():
			_frames = art.frames("dwarf_f")
	for _i in range(4):
		var d := ColorRect.new()
		d.color = Color(0.04, 0.03, 0.02, 0.78)
		d.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(d)
		_dim.append(d)
	_ring = Panel.new()
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rs := StyleBoxFlat.new()
	rs.bg_color = Color(0, 0, 0, 0)
	rs.border_color = Color("e8c36a")
	rs.set_border_width_all(3)
	rs.set_corner_radius_all(10)
	_ring.add_theme_stylebox_override("panel", rs)
	add_child(_ring)
	_build_talk(art)
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
	_face.custom_minimum_size = Vector2(64, 112)
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
	col.add_child(_name)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size", 15)
	_body.add_theme_color_override("font_color", Color("1c120c"))
	_body.custom_minimum_size = Vector2(230, 0)
	col.add_child(_body)
	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color("6b4a10"))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_hint)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_END
	btns.add_theme_constant_override("separation", 8)
	col.add_child(btns)
	_skip = Button.new()
	_skip.text = COPY.text("tutorial.skip", "Skip")
	_skip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_btn(_skip, Color("2a2622"), Color("6a5f52"))
	_skip.pressed.connect(func() -> void: skipped.emit())
	btns.add_child(_skip)
	_go = Button.new()
	_go.text = "Alright"
	_go.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_style_btn(_go, Color("3a2820"), Color("e8c36a"))
	_go.pressed.connect(func() -> void: continued.emit())
	btns.add_child(_go)


func _style_btn(b: Button, fill: Color, rim: Color) -> void:
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = rim
	s.set_border_width_all(2)
	s.set_corner_radius_all(999)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	b.add_theme_stylebox_override("normal", s)
	var h := s.duplicate() as StyleBoxFlat
	h.bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)


func open() -> void:
	step = -1
	visible = true
	advance()


func close() -> void:
	visible = false
	wait = ""
	focus_tag = ""
	_target = null
	step = -1


func advance() -> void:
	step += 1
	if step >= BEATS.size():
		wait = ""
		finished.emit()
		return
	var b: Dictionary = BEATS[step]
	wait = str(b.get("wait", "continue"))
	focus_tag = str(b.get("focus", ""))
	var n: String = "%02d" % (step + 1)
	_body.text = COPY.text("tutorial.beat.%s.body" % n, str(b.get("text", "")))
	_hint.text = COPY.text("tutorial.beat.%s.hint" % n, str(b.get("hint", "")))
	_go.text = COPY.text("tutorial.beat.%s.go" % n, str(b.get("go", "Alright")))
	_name.text = COPY.text("tutorial.speaker", "Nib")
	_skip.text = COPY.text("tutorial.skip", "Skip")
	_go.visible = wait == "continue"
	_arm = 0.35
	_talk.reset_size()


func nudge(msg: String) -> void:
	_hint.text = msg


func armed() -> bool:
	return _arm <= 0.0


func follow(target: Control) -> void:
	_target = target


func _process(delta: float) -> void:
	if not visible:
		return
	_arm = maxf(0.0, _arm - delta)
	if not _frames.is_empty() and _face != null:
		_fi += delta * 5.0
		var n: int = _frames.size()
		_face.texture = _frames[int(_fi) % n]
		_face.position.y = sin(_fi * 1.4) * 2.0
	_layout()


func _layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var hole := Rect2(vp * 0.5, Vector2.ZERO)
	if _target != null and is_instance_valid(_target) and _target.is_visible_in_tree():
		var r: Rect2 = _target.get_global_rect()
		r = r.grow(PAD)
		r.position.x = clampf(r.position.x, 0.0, vp.x)
		r.position.y = clampf(r.position.y, 0.0, vp.y)
		hole = r
	if hole.size.x < 8.0 or hole.size.y < 8.0:
		hole = Rect2(0, 0, 0, 0)
		_ring.visible = false
	else:
		_ring.visible = true
		_ring.global_position = hole.position
		_ring.size = hole.size
	_place_dims(hole, vp)
	_talk.reset_size()
	var ts: Vector2 = _talk.get_combined_minimum_size()
	ts.x = maxf(ts.x, TALK_W)
	_talk.size = ts
	var pos := Vector2((vp.x - ts.x) * 0.5, vp.y - ts.y - 24.0)
	if hole.size.x > 8.0:
		pos = Vector2(hole.end.x + 16.0, hole.position.y)
		if pos.x + ts.x > vp.x - 12.0:
			pos.x = hole.position.x - ts.x - 16.0
		if pos.x < 8.0:
			pos.x = clampf(hole.position.x, 8.0, maxf(8.0, vp.x - ts.x - 8.0))
			pos.y = hole.end.y + 12.0
			if pos.y + ts.y > vp.y - 8.0:
				pos.y = hole.position.y - ts.y - 12.0
		pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - ts.y - 8.0))
		pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - ts.x - 8.0))
	_talk.global_position = pos


func _place_dims(hole: Rect2, vp: Vector2) -> void:
	if hole.size.x < 8.0:
		_dim[0].position = Vector2.ZERO
		_dim[0].size = vp
		_dim[1].size = Vector2.ZERO
		_dim[2].size = Vector2.ZERO
		_dim[3].size = Vector2.ZERO
		return
	_dim[0].position = Vector2.ZERO
	_dim[0].size = Vector2(vp.x, hole.position.y)
	_dim[1].position = Vector2(0.0, hole.end.y)
	_dim[1].size = Vector2(vp.x, maxf(0.0, vp.y - hole.end.y))
	_dim[2].position = Vector2(0.0, hole.position.y)
	_dim[2].size = Vector2(maxf(0.0, hole.position.x), hole.size.y)
	_dim[3].position = Vector2(hole.end.x, hole.position.y)
	_dim[3].size = Vector2(maxf(0.0, vp.x - hole.end.x), hole.size.y)


const BEATS := [
	{
		"text": "Name's Nib. You're the sticky-fingered one. You stole a pile and stuffed it in this round room. Get through three fights and I'll pretend this was always the plan.",
		"hint": "",
		"focus": "",
		"wait": "continue",
		"go": "Let's go",
	},
	{
		"text": "This circle is your nest — eight alcoves, no polite exit. It turns. You fight whoever lands. I seated a Golem, a Wizard, and a Berserker. I'm steering.",
		"hint": "",
		"focus": "wheel",
		"wait": "continue",
		"go": "Got it",
	},
	{
		"text": "Those hearts are you. Empty means the owners win. One heart left is still a win. Nobody grades on leftovers.",
		"hint": "",
		"focus": "hearts",
		"wait": "continue",
		"go": "Alright",
	},
	{
		"text": "Your loot's along the bottom. Hover a card. Hold Shift if you want the equation instead of the number.",
		"hint": "(hover any item)",
		"focus": "hotbar",
		"wait": "hover_item",
		"go": "Alright",
	},
	{
		"text": "Helmet's number is alive — it changes with health. We probably won't tap it if you listen. Shield is the pillow. Flail gets ideas later. I also slipped a boot in. Don't ask.",
		"hint": "",
		"focus": "item:helmet",
		"wait": "continue",
		"go": "Fine",
	},
	{
		"text": "Click Spin. I'll land the Golem. Big, slow, hits for three.",
		"hint": "(click Spin)",
		"focus": "spin",
		"wait": "spin",
		"go": "Alright",
	},
	{
		"text": "Golem. Three in the knuckles. Your Shield is four. Click the Shield.",
		"hint": "(click Shield)",
		"focus": "item:shield",
		"wait": "item:shield",
		"go": "Alright",
	},
	{
		"text": "That gold in the hub is Block. It's a pillow. When this fight ends, the pillow goes in the trash. Hearts stay.",
		"hint": "",
		"focus": "wheel",
		"wait": "continue",
		"go": "OK",
	},
	{
		"text": "Click Safe. You blocked it all this time. If a heart had popped, we'd keep walking. Alive is the only score.",
		"hint": "(click Safe)",
		"focus": "done",
		"wait": "done",
		"go": "Alright",
	},
	{
		"text": "Block's gone. Hearts aren't. That little plaque is your body count — the Flail is counting too. Two owners left.",
		"hint": "",
		"focus": "trophy",
		"wait": "continue",
		"go": "Spin when ready",
	},
	{
		"text": "Spin again. Wizard this time. Don't eat what they throw.",
		"hint": "(click Spin)",
		"focus": "spin",
		"wait": "spin",
		"go": "Alright",
	},
	{
		"text": "Five attack, two health. You could hide and still get nicked — or you end it. Click the Boot. If they have less health than you, the fight just stops.",
		"hint": "(click the Boot)",
		"focus": "item:da_boot",
		"wait": "item:da_boot",
		"go": "Alright",
	},
	{
		"text": "That's the other trick: finish the small ones. The Flail only grows when you bleed — you didn't, so it's still 2. Helmet's the pillow for this last one.",
		"hint": "",
		"focus": "item:helmet",
		"wait": "continue",
		"go": "Got it",
	},
	{
		"text": "Last alcove. Hover it. Owners have hobbies too — they tell you if you ask. This one gets stronger when you win. Rude.",
		"hint": "(hover the Berserker)",
		"focus": "wheel",
		"wait": "hover_slice:berserker",
		"go": "Alright",
	},
	{
		"text": "Spin. Berserker hits 3. Helmet is the lower of your HP and theirs.",
		"hint": "(click Spin)",
		"focus": "spin",
		"wait": "spin",
		"go": "Alright",
	},
	{
		"text": "Click the Helmet. Four block against three attack.",
		"hint": "(click Helmet)",
		"focus": "item:helmet",
		"wait": "item:helmet",
		"go": "Alright",
	},
	{
		"text": "Click Safe. Block dumps after this. Hearts stay. That's how you keep a pile.",
		"hint": "(click Safe)",
		"focus": "done",
		"wait": "done",
		"go": "Alright",
	},
	{
		"text": "You lived. I get a cut later. Dive In is the real heist — I don't pick the order, and there are eight of them. Try not to need me.",
		"hint": "",
		"focus": "",
		"wait": "continue",
		"go": "I'm good",
	},
]
