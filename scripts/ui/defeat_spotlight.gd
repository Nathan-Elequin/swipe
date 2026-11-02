extends CanvasLayer
## Defeat spotlight sequence: hard blackout → soft warm cone → existing Sprout defeat
## anim (mirrored) → journal quote + wax seal (intact→broken by B.S.) → Limp home /
## Quick start. No Undo.
## Copy keys: defeat.journal.01–50 + defeat.journal.attrib + defeat.home / defeat.quick.

signal home_pressed
signal quick_pressed
signal sequence_ready

const PLAYER_COPY := preload("res://scripts/player_copy.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const QUOTE_FADE_S := 2.0
const QUOTE_DRIFT_PX := 12.0
const BUTTON_FADE_S := 0.45
const SPOT_DROP_S := 0.30
const SEAL_BREAK_S := 0.40
const SEAL_SIZE := Vector2(56.0, 52.0)
const SPROUT_DRAW := Vector2(140.0, 140.0)
const WAX_SEAL_INTACT := "res://assets/dungeon/home/overlays/wax_seal.png"
const WAX_SEAL_BROKEN := "res://assets/dungeon/home/overlays/wax_seal_broken.png"

var _root: Control
var _black: ColorRect
var _spot: ColorRect
var _shadow: ColorRect
var _sprout: TextureRect
var _quote_box: Control
var _quote: RichTextLabel
var _rule: ColorRect
var _attrib_row: HBoxContainer
var _seal: Control
var _seal_intact: TextureRect
var _seal_broken: TextureRect
var _attrib: Label
var _btn_row: HBoxContainer
var _btn_home: Button
var _btn_quick: Button
var _input_lock: Control
var _built: bool = false
var _buttons_live: bool = false
var _quote_tweening: bool = false
var _seq: int = 0
var _wheel: Node = null
var _art = null
var _quote_y: float = 0.0


func _ready() -> void:
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "DefeatSpotlight"
	visible = false


func is_active() -> bool:
	return visible and _built


func buttons_ready() -> bool:
	return _buttons_live


func dismiss() -> void:
	_seq += 1
	_buttons_live = false
	_quote_tweening = false
	visible = false
	_wheel = null
	if _sprout:
		_sprout.texture = null
	if _quote_box:
		_quote_box.modulate.a = 0.0
	_reset_seal(false)
	if _btn_row:
		_btn_row.modulate.a = 0.0
		_btn_row.visible = false
	if _btn_home:
		_btn_home.disabled = true
	if _btn_quick:
		_btn_quick.disabled = true
	if _input_lock:
		_input_lock.mouse_filter = Control.MOUSE_FILTER_STOP


## Audit / shot harness: skip anim waits and show the settled D3 state.
func debug_show_settled(wheel: Node = null, art = null) -> void:
	_seq += 1
	_wheel = wheel
	_art = art
	_build()
	_pick_quote()
	_quote_y = _quote_home_y()
	_quote_tweening = false
	_layout()
	visible = true
	_black.modulate.a = 1.0
	_spot.modulate.a = 1.0
	_quote_box.modulate.a = 1.0
	_reset_seal(true)
	_btn_row.visible = true
	_btn_row.modulate.a = 1.0
	_btn_home.disabled = false
	_btn_quick.disabled = false
	_buttons_live = true
	_input_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sync_sprout_frame()
	# Hold last defeat frame.
	if _art != null and _art.has_method("sprout_anim"):
		var frames: Array = _art.sprout_anim("defeat")
		if not frames.is_empty():
			_sprout.texture = frames[frames.size() - 1]


## Hard blackout immediately. Soft spotlight drops in. Mirrors existing hub defeat
## frames from `wheel` while they play. After anim ends: quote, then buttons.
func play_sequence(wheel: Node, art) -> void:
	_seq += 1
	var token: int = _seq
	_wheel = wheel
	_art = art
	_buttons_live = false
	_build()
	_pick_quote()
	_quote_y = _quote_home_y() + QUOTE_DRIFT_PX
	_quote_tweening = false
	_layout()
	visible = true
	_black.modulate.a = 1.0
	_spot.modulate.a = 0.0
	_quote_box.modulate.a = 0.0
	_reset_seal(false)
	_btn_row.visible = false
	_btn_row.modulate.a = 0.0
	_btn_home.disabled = true
	_btn_quick.disabled = true
	_input_lock.mouse_filter = Control.MOUSE_FILTER_STOP
	_sync_sprout_frame()
	# Soft cone drops onto Sprout (~0.3s).
	var spot_tw := create_tween()
	spot_tw.set_trans(Tween.TRANS_SINE)
	spot_tw.set_ease(Tween.EASE_OUT)
	spot_tw.tween_property(_spot, "modulate:a", 1.0, SPOT_DROP_S)
	# Wait for the existing hub death anim to finish (music already started by caller).
	if _wheel != null and _wheel.has_method("wait_hero_done"):
		await _wheel.wait_hero_done()
	else:
		await get_tree().create_timer(0.85).timeout
	if token != _seq:
		return
	_sync_sprout_frame()
	# Quote + intact seal fade in together; quote drifts up ~12px over ~2s.
	_quote_y = _quote_home_y() + QUOTE_DRIFT_PX
	_quote_box.modulate.a = 0.0
	_reset_seal(false)
	_quote_tweening = true
	var q_tw := create_tween()
	q_tw.set_parallel(true)
	q_tw.set_trans(Tween.TRANS_SINE)
	q_tw.set_ease(Tween.EASE_OUT)
	q_tw.tween_property(_quote_box, "modulate:a", 1.0, QUOTE_FADE_S)
	q_tw.tween_method(_set_quote_y, _quote_y, _quote_home_y(), QUOTE_FADE_S)
	await q_tw.finished
	_quote_tweening = false
	_quote_y = _quote_home_y()
	if token != _seq:
		return
	# Intact → broken seal crossfade (~0.4s) with a small scale punch.
	await _play_seal_break()
	if token != _seq:
		return
	# Buttons after seal settles. Broken seal stays visible. Input ignored until now.
	_btn_row.visible = true
	_btn_row.modulate.a = 0.0
	var b_tw := create_tween()
	b_tw.set_trans(Tween.TRANS_SINE)
	b_tw.set_ease(Tween.EASE_OUT)
	b_tw.tween_property(_btn_row, "modulate:a", 1.0, BUTTON_FADE_S)
	await b_tw.finished
	if token != _seq:
		return
	_btn_home.disabled = false
	_btn_quick.disabled = false
	_buttons_live = true
	_input_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sequence_ready.emit()


func _process(_delta: float) -> void:
	if not visible or not _built:
		return
	_sync_sprout_frame()
	_layout()


func _build() -> void:
	if _built:
		return
	_built = true
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_black = ColorRect.new()
	_black.name = "Blackout"
	_black.color = Color(0, 0, 0, 1)
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_black)

	_spot = ColorRect.new()
	_spot.name = "Spotlight"
	_spot.color = Color(1, 1, 1, 1)
	_spot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/defeat_spotlight.gdshader")
	mat.set_shader_parameter("warm", Color(1.0, 0.925, 0.745, 1.0))
	mat.set_shader_parameter("cone_strength", 0.20)
	mat.set_shader_parameter("pool_strength", 0.32)
	mat.set_shader_parameter("soft", 0.14)
	_spot.material = mat
	_root.add_child(_spot)

	_shadow = ColorRect.new()
	_shadow.name = "SproutShadow"
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow.color = Color(0, 0, 0, 0)
	_root.add_child(_shadow)
	_apply_shadow_tex()

	_sprout = TextureRect.new()
	_sprout.name = "Sprout"
	_sprout.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprout.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprout.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprout.custom_minimum_size = SPROUT_DRAW
	_root.add_child(_sprout)

	_quote_box = Control.new()
	_quote_box.name = "QuoteBox"
	_quote_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quote_box.custom_minimum_size = Vector2(640, 160)
	_root.add_child(_quote_box)

	_quote = RichTextLabel.new()
	_quote.name = "Quote"
	_quote.bbcode_enabled = true
	_quote.fit_content = true
	_quote.scroll_active = false
	_quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quote.add_theme_font_override("normal_font", ThemeDB.fallback_font)
	_quote.add_theme_font_override("italics_font", ThemeDB.fallback_font)
	_quote.add_theme_font_size_override("normal_font_size", 26)
	_quote.add_theme_font_size_override("italics_font_size", 26)
	_quote.add_theme_color_override("default_color", Color("e8d6b0"))
	if _quote.has_method("set_horizontal_alignment"):
		_quote.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	else:
		_quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quote.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quote_box.add_child(_quote)

	_rule = ColorRect.new()
	_rule.name = "Rule"
	_rule.color = Color("8a6a3a")
	_rule.custom_minimum_size = Vector2(60, 1)
	_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quote_box.add_child(_rule)

	_attrib_row = HBoxContainer.new()
	_attrib_row.name = "AttribRow"
	_attrib_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_attrib_row.add_theme_constant_override("separation", 10)
	_attrib_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quote_box.add_child(_attrib_row)

	_seal = Control.new()
	_seal.name = "Seal"
	_seal.custom_minimum_size = SEAL_SIZE
	_seal.size = SEAL_SIZE
	_seal.pivot_offset = SEAL_SIZE * 0.5
	_seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_attrib_row.add_child(_seal)

	_seal_intact = TextureRect.new()
	_seal_intact.name = "SealIntact"
	_seal_intact.texture = load(WAX_SEAL_INTACT) as Texture2D
	_seal_intact.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_seal_intact.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_seal_intact.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_seal_intact.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_seal_intact.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_seal.add_child(_seal_intact)

	_seal_broken = TextureRect.new()
	_seal_broken.name = "SealBroken"
	_seal_broken.texture = load(WAX_SEAL_BROKEN) as Texture2D
	_seal_broken.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_seal_broken.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_seal_broken.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_seal_broken.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_seal_broken.modulate.a = 0.0
	_seal_broken.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_seal.add_child(_seal_broken)

	_attrib = Label.new()
	_attrib.name = "Attrib"
	_attrib.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_attrib.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_attrib.add_theme_font_override("font", ThemeDB.fallback_font)
	_attrib.add_theme_font_size_override("font_size", 18)
	_attrib.add_theme_color_override("font_color", Color("c9a46a"))
	_attrib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_attrib_row.add_child(_attrib)

	_btn_row = HBoxContainer.new()
	_btn_row.name = "Buttons"
	_btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_btn_row.add_theme_constant_override("separation", 28)
	_btn_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_btn_row)

	_btn_home = _make_btn(
		PLAYER_COPY.text("defeat.home", "Limp home"),
		false,
		func() -> void:
			if _buttons_live:
				home_pressed.emit()
	)
	_btn_quick = _make_btn(
		PLAYER_COPY.text("defeat.quick", "Quick start"),
		true,
		func() -> void:
			if _buttons_live:
				quick_pressed.emit()
	)
	_btn_row.add_child(_btn_home)
	_btn_row.add_child(_btn_quick)

	_input_lock = Control.new()
	_input_lock.name = "InputLock"
	_input_lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_input_lock.mouse_filter = Control.MOUSE_FILTER_STOP
	_input_lock.z_index = 20
	_root.add_child(_input_lock)


func _make_btn(label: String, primary: bool, cb: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(230, 56)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", ThemeDB.fallback_font)
	b.add_theme_font_size_override("font_size", 24)
	b.add_theme_constant_override("outline_size", 0)
	var up := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var down := StyleBoxFlat.new()
	for s in [up, hover, down]:
		s.set_border_width_all(4)
		s.set_corner_radius_all(12)
		s.content_margin_left = 28
		s.content_margin_right = 28
		s.content_margin_top = 12
		s.content_margin_bottom = 12
		s.border_color = Color("1d1107")
	if primary:
		# Quick start — warm cream (mock D3).
		up.bg_color = Color("e7c27a")
		hover.bg_color = Color("f0d090")
		down.bg_color = Color("d4b06a")
		up.shadow_color = Color("fff2c8")
		up.shadow_size = 0
		# Inner rim via expand margin trick: second border feel.
		up.set_border_width_all(4)
		b.add_theme_color_override("font_color", Color("2c1a0d"))
		b.add_theme_color_override("font_hover_color", Color("1c1008"))
		b.add_theme_color_override("font_pressed_color", Color("1c1008"))
		b.add_theme_color_override("font_disabled_color", Color(0.2, 0.12, 0.06, 0.45))
		# Soft inner highlight.
		up.border_color = Color("1d1107")
		hover.border_color = Color("1d1107")
		down.border_color = Color("1d1107")
	else:
		# Limp home — dark brown with warm rim.
		up.bg_color = Color("3a2414")
		hover.bg_color = Color("4a3020")
		down.bg_color = Color("2a180c")
		up.border_color = Color("8a5d34")
		hover.border_color = Color("a07040")
		down.border_color = Color("6a4528")
		up.set_border_width_all(3)
		hover.set_border_width_all(3)
		down.set_border_width_all(3)
		b.add_theme_color_override("font_color", Color("f3e3c3"))
		b.add_theme_color_override("font_hover_color", Color("ffffff"))
		b.add_theme_color_override("font_pressed_color", Color("e8c36a"))
		b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	b.add_theme_stylebox_override("normal", up)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("pressed", down)
	b.add_theme_stylebox_override("disabled", up)
	b.pressed.connect(cb)
	b.disabled = true
	return b


func _apply_shadow_tex() -> void:
	var img := Image.create(128, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 48:
		for x in 128:
			var nx: float = (float(x) + 0.5) / 128.0 * 2.0 - 1.0
			var ny: float = (float(y) + 0.5) / 48.0 * 2.0 - 1.0
			var d: float = sqrt(nx * nx + ny * ny * 1.15)
			var a: float = 1.0 - smoothstep(0.35, 1.0, d)
			img.set_pixel(x, y, Color(0, 0, 0, a * 0.92))
	var tex := ImageTexture.create_from_image(img)
	# ColorRect has no texture — swap to TextureRect-like via child.
	# Replace _shadow ColorRect usage: parent a TextureRect.
	var tr := TextureRect.new()
	tr.name = "ShadowTex"
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shadow.color = Color(0, 0, 0, 0)
	_shadow.add_child(tr)


func _pick_quote() -> void:
	var picks: Array = []
	for i in range(1, 51):
		var key := "defeat.journal.%02d" % i
		if PLAYER_COPY.has_key(key):
			picks.append(key)
	var key_pick := "defeat.journal.01"
	if not picks.is_empty():
		key_pick = str(picks[randi() % picks.size()])
	var body: String = PLAYER_COPY.text(key_pick, "A setback is just a setback with better lighting.")
	var mono: String = PLAYER_COPY.text("defeat.journal.attrib", "B.S.")
	_quote.clear()
	_quote.append_text("[center][i]“%s”[/i][/center]" % body.replace("[", "").replace("]", ""))
	_attrib.text = "— %s" % mono
	if _btn_home:
		_btn_home.text = PLAYER_COPY.text("defeat.home", "Limp home")
	if _btn_quick:
		_btn_quick.text = PLAYER_COPY.text("defeat.quick", "Quick start")


func _quote_home_y() -> float:
	var h: float = maxf(1.0, _root.size.y if _root else DESIGN.y)
	return h * 0.22


func _set_quote_y(y: float) -> void:
	_quote_y = y
	if _quote_box:
		_quote_box.position.y = y


## Intact for quote fade-in; broken for the settled / post-break beat.
func _reset_seal(broken: bool) -> void:
	if _seal == null:
		return
	_seal.scale = Vector2.ONE
	_seal.pivot_offset = SEAL_SIZE * 0.5
	if _seal_intact:
		_seal_intact.modulate.a = 0.0 if broken else 1.0
	if _seal_broken:
		_seal_broken.modulate.a = 1.0 if broken else 0.0


func _play_seal_break() -> void:
	if _seal == null or _seal_intact == null or _seal_broken == null:
		return
	_seal.pivot_offset = SEAL_SIZE * 0.5
	_seal.scale = Vector2.ONE
	_seal_intact.modulate.a = 1.0
	_seal_broken.modulate.a = 0.0
	var seal_tw := create_tween()
	seal_tw.set_parallel(true)
	seal_tw.set_trans(Tween.TRANS_SINE)
	seal_tw.set_ease(Tween.EASE_IN_OUT)
	seal_tw.tween_property(_seal_intact, "modulate:a", 0.0, SEAL_BREAK_S)
	seal_tw.tween_property(_seal_broken, "modulate:a", 1.0, SEAL_BREAK_S)
	var punch := create_tween()
	punch.set_trans(Tween.TRANS_SINE)
	punch.set_ease(Tween.EASE_OUT)
	punch.tween_property(_seal, "scale", Vector2(1.08, 1.08), SEAL_BREAK_S * 0.5)
	punch.tween_property(_seal, "scale", Vector2.ONE, SEAL_BREAK_S * 0.5)
	await seal_tw.finished


func _layout() -> void:
	if not _built or _root == null:
		return
	var sz: Vector2 = _root.size
	if sz.x < 8.0 or sz.y < 8.0:
		sz = DESIGN
	# Sprout sits in the warm pool (mock: lower center).
	var sprout_sz := SPROUT_DRAW
	var sprout_pos := Vector2((sz.x - sprout_sz.x) * 0.5, sz.y * 0.68)
	_sprout.position = sprout_pos
	_sprout.size = sprout_sz
	var shadow_sz := Vector2(170, 34)
	_shadow.position = Vector2((sz.x - shadow_sz.x) * 0.5, sprout_pos.y + sprout_sz.y - 18.0)
	_shadow.size = shadow_sz
	# Quote block upper cone.
	var q_w := 640.0
	_quote_box.size = Vector2(q_w, 180.0)
	if not _quote_tweening:
		_quote_box.position = Vector2((sz.x - q_w) * 0.5, _quote_y)
	else:
		_quote_box.position.x = (sz.x - q_w) * 0.5
		_quote_box.position.y = _quote_y
	_quote.position = Vector2(0, 0)
	_quote.size = Vector2(q_w, 110.0)
	_rule.size = Vector2(60, 1)
	_rule.position = Vector2((q_w - 60.0) * 0.5, 118.0)
	# Wax seal left of B.S., centered under the quote.
	_attrib_row.position = Vector2(0, 124.0)
	_attrib_row.size = Vector2(q_w, SEAL_SIZE.y)
	_seal.custom_minimum_size = SEAL_SIZE
	_seal.size = SEAL_SIZE
	_seal.pivot_offset = SEAL_SIZE * 0.5
	# Buttons near floor of the cone.
	_btn_row.size = Vector2(520, 64)
	_btn_row.position = Vector2((sz.x - 520.0) * 0.5, sz.y * 0.86)


func _sync_sprout_frame() -> void:
	if _sprout == null:
		return
	var tex: Texture2D = null
	var frames: Array = []
	if _art != null and _art.has_method("sprout_anim"):
		frames = _art.sprout_anim("defeat")
	var fi: int = 0
	if _wheel != null and is_instance_valid(_wheel) and _wheel.get("hero_frame") != null:
		fi = int(_wheel.hero_frame)
	if typeof(frames) == TYPE_ARRAY and not frames.is_empty():
		fi = clampi(fi, 0, frames.size() - 1)
		tex = frames[fi]
	_sprout.texture = tex
