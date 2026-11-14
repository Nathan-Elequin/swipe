class_name TrophyBoardFace
extends Control
## One biome face: backdrop, crest, lights, lever placeholder, pyramid slots.


signal slot_hovered(card_id: String, state: StringName)
signal slot_unhovered(card_id: String)
signal slot_clicked(card_id: String, state: StringName)
signal lever_clicked(face_index: int)
signal padlock_hovered()
signal lights_hovered()
signal lever_hovered(state: StringName)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const SLOT_SCR := preload("res://scripts/cabin/trophy_board_slot.gd")
const COPY := preload("res://scripts/player_copy.gd")

var face: Dictionary = {}
var face_index: int = 0
var reduce_motion: bool = false

var _bg: Control
var _crest: Control
var _plaque: Control
var _plaque_lab: Label
var _padlock: Control
var _lights: Array = []
var _lever: Control
var _lever_glow: Control
var _slots: Dictionary = {}  # id -> TrophyBoardSlot
var _pyramid: Control


func setup(p_face: Dictionary) -> void:
	face = p_face
	face_index = int(p_face.get("index", 0))
	name = "Face_%s" % str(p_face.get("pool_id", face_index))
	size = MODEL.FACE_VIEWPORT.size
	custom_minimum_size = size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	_build_chrome()


func _build_chrome() -> void:
	for c in get_children():
		c.queue_free()
	_slots.clear()
	_lights.clear()
	var slug := str(face.get("slug", "verdant"))
	_bg = _tex_or_box(
		"Bg",
		Rect2(Vector2.ZERO, size),
		"trophy_board/face_bg_%s" % slug,
		Color(str(_biome_fill(slug)))
	)
	add_child(_bg)
	_pyramid = Control.new()
	_pyramid.name = "Pyramid"
	_pyramid.position = Vector2.ZERO
	_pyramid.size = size
	_pyramid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_pyramid)
	## Crest face-local: absolute (240,144) - viewport (224,128) = (16,16)
	_crest = _tex_or_box(
		"Crest",
		Rect2(16, 16, 96, 96),
		"trophy_board/crest_%s" % slug,
		Color("c4a574")
	)
	add_child(_crest)
	## Lights absolute y 140 → local 12; x 672+k*72 → local 448+k*72
	for k in 5:
		var lr := Rect2(448 + k * 72, 12, 48, 64)
		var light := _tex_or_box("Light%d" % k, lr, "trophy_board/light_off", Color("2b1a12"))
		light.mouse_filter = Control.MOUSE_FILTER_STOP
		light.gui_input.connect(_on_light_gui.bind(k))
		light.mouse_entered.connect(func() -> void: lights_hovered.emit())
		add_child(light)
		_lights.append(light)
	## Lever absolute (1344,136) → local (1120, 8)
	_lever = _tex_or_box("Lever", Rect2(1120, 8, 64, 128), "trophy_board/lever_locked", Color("8a6a2e"))
	_lever.mouse_filter = Control.MOUSE_FILTER_STOP
	## Hit rect 96×160 centred on lever
	_lever.position = Vector2(1120 - 16, 8 - 16)
	_lever.size = Vector2(96, 160)
	_lever.gui_input.connect(_on_lever_gui)
	_lever.mouse_entered.connect(func() -> void:
		lever_hovered.emit(_lever.get_meta("lever_state", &"locked"))
	)
	add_child(_lever)
	_lever_glow = _tex_or_box("LeverGlow", Rect2(1088, -24, 128, 192), "trophy_board/lever_glow", Color(1, 0.85, 0.3, 0.0))
	_lever_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lever_glow.visible = false
	add_child(_lever_glow)
	_padlock = _tex_or_box("Padlock", Rect2((size.x - 160) * 0.5, 144 + (464 - 192) * 0.5, 160, 192), "trophy_board/padlock", Color("3a3a3e"))
	_padlock.mouse_filter = Control.MOUSE_FILTER_STOP
	_padlock.visible = false
	_padlock.mouse_entered.connect(func() -> void: padlock_hovered.emit())
	add_child(_padlock)


func rebuild_slots(lay: Dictionary, tex_by_id: Dictionary) -> void:
	for c in _pyramid.get_children():
		c.queue_free()
	_slots.clear()
	var compact: bool = str(lay.get("mode", "normal")) == "compact"
	var rects: Dictionary = lay.get("rects", {})
	for id in rects.keys():
		var abs_r: Rect2 = rects[id]
		## Convert absolute screen rect → face-local
		var local := Rect2(abs_r.position - MODEL.FACE_VIEWPORT.position, abs_r.size)
		var slot: TrophyBoardSlot = SLOT_SCR.new()
		slot.setup(str(id), local, compact)
		var tex: Texture2D = tex_by_id.get(str(id), null)
		slot.set_item_texture(tex)
		slot.reduce_motion = reduce_motion
		slot.hovered.connect(func(cid: String, st: StringName) -> void: slot_hovered.emit(cid, st))
		slot.unhovered.connect(func(cid: String) -> void: slot_unhovered.emit(cid))
		slot.clicked.connect(func(cid: String, st: StringName) -> void: slot_clicked.emit(cid, st))
		_pyramid.add_child(slot)
		_slots[str(id)] = slot


func apply_states(
	rules: Dictionary,
	state: Dictionary,
	cabin_seen: Dictionary,
	held: Array
) -> void:
	var locked: bool = MODEL.is_face_locked(rules, state, face)
	_padlock.visible = locked
	_plaque_modulate(0.7 if locked else 1.0)
	for id in _slots.keys():
		var st: StringName = MODEL.slot_state(cabin_seen, state, str(id), held)
		(_slots[id] as TrophyBoardSlot).apply_state(st, locked)
	var lit: int = 0 if locked else MODEL.lights_lit(rules, state, face, held)
	for i in _lights.size():
		_set_light(i, i < lit)
	var ls: StringName = &"locked" if locked else MODEL.lever_state(rules, state, face)
	_set_lever(ls, locked)


func set_plaque_host(plaque: Control, lab: Label) -> void:
	## Plaque lives on the shared frame (above face). Face only tracks modulate.
	_plaque = plaque
	_plaque_lab = lab


func slot_node(card_id: String) -> TrophyBoardSlot:
	return _slots.get(str(card_id), null)


func flash_light(light_index: int) -> void:
	if light_index < 0 or light_index >= _lights.size():
		return
	_set_light(light_index, true)


func set_lever_ready_fx(on: bool) -> void:
	if _lever_glow == null:
		return
	_lever_glow.visible = on
	if on and not reduce_motion:
		_lever_glow.modulate = Color(1, 1, 1, 0.85)
		var tw := create_tween().set_loops()
		tw.tween_property(_lever_glow, "modulate:a", 0.35, 0.6 / maxf(Engine.time_scale, 0.001))
		tw.tween_property(_lever_glow, "modulate:a", 0.85, 0.6 / maxf(Engine.time_scale, 0.001))
		_lever_glow.set_meta("pulse_tw", tw)
	else:
		var old = _lever_glow.get_meta("pulse_tw", null)
		if old is Tween:
			(old as Tween).kill()


func play_gild(_instant := false) -> void:
	## Placeholder — Package D/C drive the full gild. Soft gold flash for now.
	modulate = Color(1.2, 1.1, 0.8, 1.0)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.4 / maxf(Engine.time_scale, 0.001))


func _set_light(i: int, on: bool) -> void:
	var node: Control = _lights[i]
	var tex: Texture2D = KIT.ui_tex("trophy_board/light_on" if on else "trophy_board/light_off")
	if node is TextureRect and tex != null:
		(node as TextureRect).texture = tex
	elif node is Panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("ffd84a") if on else Color("2b1a12")
		sb.set_border_width_all(1)
		sb.border_color = Color("100e0c")
		(node as Panel).add_theme_stylebox_override("panel", sb)


func _set_lever(st: StringName, hidden: bool) -> void:
	_lever.visible = not hidden
	_lever_glow.visible = false
	_lever.set_meta("lever_state", st)
	var stem := "trophy_board/lever_locked"
	if st == &"ready":
		stem = "trophy_board/lever_ready"
		set_lever_ready_fx(true)
	elif st == &"spent":
		stem = "trophy_board/lever_pulled"
	var tex: Texture2D = KIT.ui_tex(stem)
	## Inner art sits centred in the larger hit rect.
	if _lever.get_child_count() == 0:
		var art := TextureRect.new()
		art.name = "Art"
		art.position = Vector2(16, 16)
		art.size = Vector2(64, 128)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_SCALE
		art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lever.add_child(art)
	var art_n = _lever.get_node_or_null("Art")
	if art_n is TextureRect:
		if tex != null:
			(art_n as TextureRect).texture = tex
		(art_n as TextureRect).visible = true
	elif _lever is TextureRect and tex != null:
		(_lever as TextureRect).texture = tex


func _plaque_modulate(a: float) -> void:
	if _plaque:
		_plaque.modulate = Color(1, 1, 1, a)
	if _plaque_lab:
		_plaque_lab.modulate = Color(1, 1, 1, a)


func _tex_or_box(p_name: String, rect: Rect2, rel: String, fill: Color) -> Control:
	var tex: Texture2D = KIT.ui_tex(rel)
	if tex != null:
		var tr := TextureRect.new()
		tr.name = p_name
		tr.position = rect.position
		tr.size = rect.size
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return tr
	var box := Panel.new()
	box.name = p_name
	box.position = rect.position
	box.size = rect.size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = Color("100e0c")
	sb.set_border_width_all(1)
	box.add_theme_stylebox_override("panel", sb)
	return box


func _biome_fill(slug: String) -> String:
	match slug:
		"verdant":
			return "2f5a2a"
		"crystal":
			return "2a4a60"
		"ashen":
			return "2e2b26"
		"cinder":
			return "3a1a10"
		"shadow":
			return "140e1e"
		_:
			return "2b1a12"


func _on_lever_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		lever_clicked.emit(face_index)


func _on_light_gui(_event: InputEvent, _k: int) -> void:
	pass
