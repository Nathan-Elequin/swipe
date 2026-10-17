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
var force_id: String = ""
var then_focus: String = ""
var choice: String = ""
var nib_close: float = 0.0
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
var _beats: Array = []
var _tiny: bool = false
var world_open: bool = false
var _spots: Array = []
var _arrows: Array = []
var _dimmer: ColorRect
var _ink
var _pin_key: String = ""
var _pin_pos: Vector2 = Vector2.ZERO
var sfx


func setup(art, p_sfx = null) -> void:
	sfx = p_sfx
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 70
	top_level = true
	visible = false
	if art != null:
		if art.has_method("nib_frames"):
			_frames = art.nib_frames()
		if _frames.is_empty():
			_frames = art.frames("goblin")
		if _frames.is_empty():
			_frames = art.frames("dwarf_f")
	for _i in range(4):
		var d := ColorRect.new()
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		d.visible = false
		add_child(d)
		_dim.append(d)
	_dimmer = ColorRect.new()
	_dimmer.set_anchors_preset(PRESET_FULL_RECT)
	_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dimmer.color = Color(0, 0, 0, 0)
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
uniform vec4 h0;
uniform vec4 h1;
uniform vec4 h2;
uniform vec4 h3;
uniform vec4 h4;
uniform vec4 h5;
uniform vec4 h6;
uniform vec4 h7;
uniform int hole_n = 0;
uniform float dim_a = 0.78;
uniform vec2 view_size = vec2(1280.0, 720.0);
bool _in(vec2 p, vec4 h) {
	return h.z > 4.0 && h.w > 4.0 && p.x >= h.x && p.y >= h.y && p.x <= h.x + h.z && p.y <= h.y + h.w;
}
void fragment() {
	vec2 p = UV * view_size;
	float a = dim_a;
	if (hole_n > 0 && _in(p, h0)) a = 0.0;
	if (hole_n > 1 && _in(p, h1)) a = 0.0;
	if (hole_n > 2 && _in(p, h2)) a = 0.0;
	if (hole_n > 3 && _in(p, h3)) a = 0.0;
	if (hole_n > 4 && _in(p, h4)) a = 0.0;
	if (hole_n > 5 && _in(p, h5)) a = 0.0;
	if (hole_n > 6 && _in(p, h6)) a = 0.0;
	if (hole_n > 7 && _in(p, h7)) a = 0.0;
	COLOR = vec4(0.04, 0.03, 0.02, a);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	_dimmer.material = mat
	add_child(_dimmer)
	_ink = SpotInk.new()
	_ink.host = self
	_ink.set_anchors_preset(PRESET_FULL_RECT)
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ink)
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
	_skip.visible = false
	_skip.pressed.connect(func() -> void: skipped.emit())
	_go = Button.new()
	_go.text = "Next"
	_go.custom_minimum_size = Vector2(210, 58)
	_go.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_go.add_theme_font_size_override("font_size", 26)
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
	choice = ""
	force_id = ""
	then_focus = ""
	world_open = false
	_spots = []
	_arrows = []
	nib_close = 0.0
	_beats = _load_beats()
	visible = true
	advance()


func close() -> void:
	visible = false
	wait = ""
	focus_tag = ""
	force_id = ""
	then_focus = ""
	world_open = false
	_spots = []
	_arrows = []
	_target = null
	step = -1
	nib_close = 0.0


func advance() -> void:
	step += 1
	while step < _beats.size():
		var skip: Dictionary = _beats[step]
		var br: String = str(skip.get("branch", ""))
		if br == "" or br == "join" or br == choice:
			break
		step += 1
	if step >= _beats.size():
		wait = ""
		finished.emit()
		return
	var b: Dictionary = _beats[step]
	wait = str(b.get("wait", "continue"))
	focus_tag = str(b.get("focus", ""))
	force_id = str(b.get("force", ""))
	then_focus = str(b.get("then_focus", ""))
	nib_close = float(b.get("nib", 0.0))
	_tiny = bool(b.get("tiny", false))
	_body.text = str(b.get("text", ""))
	if sfx and sfx.has_method("speak"):
		sfx.speak(&"nib", str(b.get("text", "")))
	_hint.text = str(b.get("hint", ""))
	_go.text = str(b.get("go", "Next"))
	_name.text = COPY.text("tutorial.speaker", "Nib")
	_skip.visible = false
	_go.visible = wait == "continue"
	_go.custom_minimum_size = Vector2(210, 58)
	var said: String = str(b.get("text", "")).to_lower()
	if said.find("survived all") >= 0 or said.find("venture deeper") >= 0:
		world_open = true
	_body.add_theme_font_size_override("font_size", 12 if _tiny else 15)
	_arm = 0.35
	_talk.reset_size()


func nudge(msg: String) -> void:
	_hint.text = msg


func armed() -> bool:
	return _arm <= 0.0


func spoken() -> String:
	if _body == null:
		return ""
	return _body.text


func follow(target: Control) -> void:
	_target = target


func set_spots(spots: Array, arrows: Array) -> void:
	_spots = spots
	_arrows = arrows
	if _ink:
		_ink.queue_redraw()


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
	if _ink:
		_ink.queue_redraw()


func _layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if _dimmer:
		_dimmer.position = Vector2.ZERO
		_dimmer.size = vp
	if _ink:
		_ink.position = Vector2.ZERO
		_ink.size = vp
	_push_dim(vp)
	_ring.visible = false
	_place_dims(Rect2(), vp)
	var face_s: float = 1.0 + 1.125 * nib_close
	if _face != null:
		_face.custom_minimum_size = Vector2(64.0 * face_s, 112.0 * face_s)
	_talk.reset_size()
	var ts: Vector2 = _talk.get_combined_minimum_size()
	ts.x = maxf(ts.x, TALK_W + 80.0 * nib_close)
	_talk.size = ts
	if ts.y < 8.0:
		return
	var key: String = "%s|%s|%s" % [step, wait, focus_tag]
	if key == _pin_key and _pin_pos != Vector2.ZERO:
		_talk.global_position = _pin_pos
		return
	var pos := Vector2(vp.x - ts.x - 16.0, 16.0) if world_open else Vector2((vp.x - ts.x) * 0.5, vp.y - ts.y - 28.0)
	var box := Rect2(pos, ts)
	if _hits_spot(box):
		pos = Vector2(vp.x - ts.x - 16.0, 16.0)
		box = Rect2(pos, ts)
	if _hits_spot(box):
		pos = Vector2(16.0, 16.0)
	pos.x = clampf(pos.x, 12.0, maxf(12.0, vp.x - ts.x - 12.0))
	pos.y = clampf(pos.y, 12.0, maxf(12.0, vp.y - ts.y - 12.0))
	_pin_key = key
	_pin_pos = pos
	_talk.global_position = pos


func _hits_spot(box: Rect2) -> bool:
	for s in _spots:
		if s is Rect2 and box.intersects(s):
			return true
	return false


func _push_dim(_vp: Vector2) -> void:
	if _dimmer == null or _dimmer.material == null:
		return
	var mat: ShaderMaterial = _dimmer.material as ShaderMaterial
	var origin: Vector2 = _dimmer.global_position
	var packed: Array[Vector4] = []
	for i in 8:
		if i < _spots.size() and _spots[i] is Rect2:
			var r: Rect2 = _spots[i]
			packed.append(Vector4(r.position.x - origin.x, r.position.y - origin.y, r.size.x, r.size.y))
		else:
			packed.append(Vector4.ZERO)
	for i in 8:
		mat.set_shader_parameter("h%d" % i, packed[i])
	mat.set_shader_parameter("hole_n", mini(_spots.size(), 8))
	mat.set_shader_parameter("view_size", _dimmer.size)
	mat.set_shader_parameter("dim_a", 0.14 if world_open else 0.72)


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


func _load_beats() -> Array:
	var raw: String = COPY.text("tutorial.beat.01.body", "")
	if raw.find("(Click") >= 0 or raw.find("(Highlight") >= 0:
		var scripted: Array = _parse_nib_script(raw)
		if scripted.size() >= 8:
			return scripted
	return _legacy_beats()


func _legacy_beats() -> Array:
	var out: Array = []
	for i in BEATS.size():
		var b: Dictionary = BEATS[i].duplicate(true)
		var n: String = "%02d" % (i + 1)
		b["text"] = COPY.text("tutorial.beat.%s.body" % n, str(b.get("text", "")))
		b["hint"] = COPY.text("tutorial.beat.%s.hint" % n, str(b.get("hint", "")))
		b["go"] = COPY.text("tutorial.beat.%s.go" % n, str(b.get("go", "Alright")))
		out.append(b)
	return out


func _fix_mojibake(s: String) -> String:
	return s.replace("â€”", "—").replace("â€“", "–").replace("â€™", "'").replace("â€˜", "'").replace("â€œ", "\"").replace("â€\u009d", "\"").replace("Â·", "·")


func _new_beat() -> Dictionary:
	return {
		"text": "",
		"hint": "",
		"focus": "",
		"wait": "continue",
		"go": "Next",
		"force": "",
		"then_focus": "",
		"branch": "",
		"nib": 0.0,
		"tiny": false,
	}


func _parse_nib_script(raw: String) -> Array:
	var lines: PackedStringArray = _fix_mojibake(raw).split("\n")
	var out: Array = []
	var cur: Dictionary = _new_beat()
	var branch := ""
	var nib: float = 0.0
	for line in lines:
		var t: String = line.strip_edges()
		if t == "":
			continue
		if t.begins_with("---"):
			_flush_beat(out, cur)
			cur = _new_beat()
			var low: String = t.to_lower()
			if low.find("da boot") >= 0:
				branch = "boot"
			elif low.find("take 3") >= 0:
				branch = "take"
			elif low.find("join") >= 0:
				branch = "join"
			continue
		if t.begins_with("(") and _is_direction_line(t):
			if t.to_lower().find("y'know") >= 0 or t.to_lower().find("tiny text") >= 0:
				_flush_beat(out, cur)
				cur = _new_beat()
				cur["text"] = _tiny_aside(t)
				cur["tiny"] = true
				cur["nib"] = nib
				cur["branch"] = branch
				_apply_direction(cur, t)
				continue
			_apply_direction(cur, t)
			nib = float(cur.get("nib", nib))
			if _direction_ends_beat(t):
				cur["nib"] = nib
				cur["branch"] = branch
				_flush_beat(out, cur)
				cur = _new_beat()
				cur["nib"] = nib
				cur["branch"] = branch
			continue
		if str(cur.get("text", "")) != "" and str(cur.get("wait", "continue")) != "continue":
			cur["nib"] = nib
			cur["branch"] = branch
			_flush_beat(out, cur)
			cur = _new_beat()
		if str(cur.get("text", "")) != "":
			cur["text"] = str(cur["text"]) + "\n" + t
		else:
			cur["text"] = t
		cur["nib"] = nib
		cur["branch"] = branch
	cur["nib"] = nib
	cur["branch"] = branch
	_flush_beat(out, cur)
	return out


func _is_direction_line(t: String) -> bool:
	var low: String = t.to_lower()
	if low.begins_with("(click") or low.begins_with("(highlight") or low.begins_with("(sprite") or low.begins_with("(comes") or low.begins_with("(returns") or low.begins_with("(nib") or low.begins_with("(only now") or low.begins_with("(when the") or low.begins_with("(the player") or low.begins_with("(animates") or low.begins_with("(vignette") or low.begins_with("(in very tiny"):
		return true
	return t.begins_with("(") and t.ends_with(")") and t.length() < 120 and low.find("highlight") >= 0


func _direction_ends_beat(t: String) -> bool:
	var low: String = t.to_lower()
	if low.begins_with("(click") or low.begins_with("(the player") or low.begins_with("(when the user hovers and holds"):
		return true
	if low.begins_with("(only now") or low.begins_with("(vignette") or low.begins_with("(animates"):
		return true
	return false


func _tiny_aside(t: String) -> String:
	var inner: String = t
	if inner.begins_with("(") and inner.ends_with(")"):
		inner = inner.substr(1, inner.length() - 2)
	var cut: int = inner.find("y'know")
	if cut >= 0:
		return "(" + inner.substr(cut).strip_edges().trim_suffix(")") + ")"
	return "(y'know, cause of the round dungeon...)"


func _apply_direction(cur: Dictionary, t: String) -> void:
	var low: String = t.to_lower()
	if low.find("closer") >= 0 or low.find("close to") >= 0 or low.find("leaning") >= 0 or low.find("80%") >= 0:
		cur["nib"] = 0.85 if low.find("80%") >= 0 else 0.55
	if low.find("returns") >= 0 or low.find("original position") >= 0 or low.find("returns to his") >= 0:
		cur["nib"] = 0.0
	if low.find("center screen") >= 0:
		cur["nib"] = 0.4
	if low.find("got it") >= 0:
		cur["go"] = "Got It"
		cur["wait"] = "continue"
	elif low.find("click 'next'") >= 0 or low.find("click to continue") >= 0 or low.find("click 'got") >= 0:
		cur["wait"] = "continue"
		if str(cur.get("go", "")) == "":
			cur["go"] = "Next"
	if low.find("click 'spin'") >= 0 or low.find("click spin") >= 0:
		cur["wait"] = "spin"
		cur["focus"] = "spin"
		cur["hint"] = "(click Spin)"
		if low.find("wizard") >= 0:
			cur["force"] = "wizard"
		elif low.find("golem") >= 0:
			cur["force"] = "golem"
		elif low.find("goblin") >= 0:
			cur["force"] = "goblin"
	if low.find("only now") >= 0:
		cur["wait"] = "auto_spin"
		cur["focus"] = "spin"
		cur["force"] = "golem"
		cur["hint"] = ""
	if low.find("sai") >= 0 and (low.find("click") >= 0 or low.find("highlight") >= 0 or low.find("use") >= 0):
		cur["focus"] = "item:sai"
		if low.find("click") >= 0 or low.find("use it") >= 0:
			cur["wait"] = "item:sai"
			cur["hint"] = "(click the Sai)"
	if low.find("helmet") >= 0 and (low.find("click") >= 0 or low.find("highlight") >= 0):
		cur["focus"] = "item:helmet"
		if low.find("click the helmet") >= 0:
			cur["wait"] = "item:helmet"
			cur["hint"] = "(click Helmet)"
	if low.find("da boot") >= 0 and low.find("take 3") >= 0:
		cur["wait"] = "choice"
		cur["focus"] = "item:da_boot"
		cur["hint"] = "(click Da Boot, or Take 3)"
	elif low.find("da boot") >= 0:
		cur["focus"] = "item:da_boot"
	if low.find("safe") >= 0 and (low.find("click") >= 0 or low.find("highlight") >= 0):
		cur["focus"] = "done"
		if low.find("click 'safe'") >= 0 or low.find("click safe") >= 0:
			cur["wait"] = "done"
			cur["hint"] = "(click Safe)"
	if low.find("hovers and holds") >= 0:
		cur["wait"] = "hover_shift"
		cur["focus"] = "wheel"
		cur["hint"] = "(hover a monster and hold Shift)"
	if low.find("empty slice") >= 0 or low.find("corridor") >= 0:
		cur["focus"] = "empty"
	elif low.find("dungeon wheel") >= 0 or low.find("monster card") >= 0 or low.find("2 random") >= 0:
		cur["focus"] = "wheel"
	if (low.find("hotbar") >= 0 or low.find("your loot") >= 0) and not str(cur.get("focus", "")).begins_with("item:"):
		cur["focus"] = "hotbar"
	if low.find("healthbar") >= 0 or low.find("6 health") >= 0 or (low.find("player hp") >= 0 and low.find("golem") < 0):
		cur["focus"] = "hearts"
	if low.find("attack icon") >= 0:
		cur["focus"] = "atk"
	if low.find("hp icon") >= 0 or low.find("golem's hp") >= 0 or low.find("both player hp") >= 0:
		cur["focus"] = "hp"
	if low.find("both player hp") >= 0:
		cur["focus"] = "hp_math"
	if low.find("block icon") >= 0:
		cur["focus"] = "block"
	if low.find("detail view") >= 0 or low.find("the details") >= 0:
		cur["focus"] = "inspect"
	# Hover-and-hold has to land on the monster. "Highlight the details" is the panel they should see after that, not the hole that blocks the wheel.
	if str(cur.get("wait", "")) == "hover_shift":
		cur["focus"] = "wheel"
		if low.find("the details") >= 0 or low.find("detail view") >= 0:
			cur["then_focus"] = "inspect"


func _flush_beat(out: Array, cur: Dictionary) -> void:
	var text: String = str(cur.get("text", "")).strip_edges()
	var wait_s: String = str(cur.get("wait", "continue"))
	if text == "" and wait_s == "continue":
		return
	if text == "" and wait_s == "auto_spin":
		cur["text"] = ""
	if str(cur.get("go", "")) == "":
		cur["go"] = "Next"
	if wait_s == "continue" and str(cur.get("hint", "")) == "":
		cur["hint"] = ""
	out.append(cur.duplicate(true))


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


class SpotInk extends Control:
	var host

	func _draw() -> void:
		if host == null:
			return
		var origin: Vector2 = global_position
		var gold := Color("e8c36a")
		for s in host._spots:
			if not (s is Rect2):
				continue
			var r: Rect2 = s
			if r.size.x < 8.0 or r.size.y < 8.0:
				continue
			draw_rect(Rect2(r.position - origin, r.size).grow(4.0), gold, false, 4.0)
		for pair in host._arrows:
			if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
				continue
			var a: Vector2 = pair[0] - origin
			var b: Vector2 = pair[1] - origin
			if a.distance_to(b) < 12.0:
				continue
			draw_line(a, b, gold, 5.0, true)
			var dir: Vector2 = (b - a).normalized()
			var side: Vector2 = Vector2(-dir.y, dir.x)
			draw_colored_polygon(PackedVector2Array([
				b,
				b - dir * 18.0 + side * 9.0,
				b - dir * 18.0 - side * 9.0,
			]), gold)
