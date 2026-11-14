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

## Final brass floor lever (2026-11-13 art drop). Native 48×56 → shipped ×4.
const LEVER_ART := Vector2(192, 224)
const LEVER_HIT := Vector2(192, 224)
const LEVER_PIVOT := Vector2(62, 196) ## (15.5, 49) native ×4
const LEVER_GLOW_SIZE := Vector2(288, 320)
const LEVER_GLOW_OFFSET := Vector2(-32, -56) ## relative to lever art origin
## Lever feet share HALL_FLOOR_Y with Nib. Local = floor − face viewport top.
const LEVER_FEET_LOCAL_Y := MODEL.HALL_FLOOR_Y - MODEL.FACE_VIEWPORT.position.y
const LEVER_PULL_FPS := 12.0

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
	## Lights absolute y 164 → local 36; x 672+k*72 → local 448+k*72
	## (+24 face-local vs old y 140 so painted placards clear the row.)
	for k in 5:
		var lr := Rect2(448 + k * 72, 36, 48, 64)
		var light := _tex_or_box("Light%d" % k, lr, "trophy_board/light_off", Color("2b1a12"))
		light.mouse_filter = Control.MOUSE_FILTER_STOP
		light.gui_input.connect(_on_light_gui.bind(k))
		light.mouse_entered.connect(func() -> void: lights_hovered.emit())
		add_child(light)
		_lights.append(light)
	## Brass floor lever (final art): 48×56 native → 192×224 shipped.
	## Pivot (15.5, 49) native / (62, 196) shipped. Stands on the hall floor to the
	## right of the board, bottom-aligned with Nib's feet (screen y 816 → face-local 688).
	## Away from wall sconces / the light strip. clip_contents is false so it may sit
	## slightly past the face right edge.
	var lever_art := LEVER_ART
	var lever_hit := LEVER_HIT
	var lever_pos := Vector2(size.x - lever_hit.x + 16.0, LEVER_FEET_LOCAL_Y - lever_hit.y)
	_lever = _tex_or_box("Lever", Rect2(lever_pos, lever_hit), "trophy_board/lever_locked", Color("8a6a2e"))
	_lever.mouse_filter = Control.MOUSE_FILTER_STOP
	_lever.position = lever_pos
	_lever.size = lever_hit
	_lever.z_index = 6
	_lever.gui_input.connect(_on_lever_gui)
	_lever.mouse_entered.connect(func() -> void:
		lever_hovered.emit(_lever.get_meta("lever_state", &"locked"))
	)
	add_child(_lever)
	## Glow at lever origin − (32, 56) shipped; halo centres on the ready grip.
	_lever_glow = _tex_or_box(
		"LeverGlow",
		Rect2(lever_pos + LEVER_GLOW_OFFSET, LEVER_GLOW_SIZE),
		"trophy_board/lever_glow",
		Color(1, 0.85, 0.3, 0.0)
	)
	_lever_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lever_glow.visible = false
	_lever_glow.z_index = 5
	add_child(_lever_glow)
	_lever.set_meta("art_size", lever_art)
	_lever.set_meta("pivot_shipped", LEVER_PIVOT)
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
	## Re-apply faint glow after state refresh (locked + at least one light).
	if bool(get_meta("faint_glow", false)) and not locked and ls == &"locked" and lit > 0:
		set_lever_faint_glow(true)


func set_plaque_host(plaque: Control, lab: Label) -> void:
	## Plaque lives on the shared frame (above face). Face only tracks modulate.
	_plaque = plaque
	_plaque_lab = lab


func slot_node(card_id: String) -> TrophyBoardSlot:
	return _slots.get(str(card_id), null)


func clear_all_pulses() -> void:
	for id in _slots.keys():
		var slot = _slots[id]
		if slot != null and slot.has_method("set_gentle_pulse"):
			slot.set_gentle_pulse(false)


func flash_light(light_index: int) -> void:
	if light_index < 0 or light_index >= _lights.size():
		return
	if reduce_motion:
		_set_light(light_index, true)
		return
	## Fire-and-forget flash frames (4 @ 16 fps). Caller does not await.
	_play_light_flash(light_index)


func _play_light_flash(light_index: int) -> void:
	for fi in 4:
		if light_index < 0 or light_index >= _lights.size():
			return
		var tex: Texture2D = KIT.ui_tex("trophy_board/light_flash_f%d" % fi)
		var node: Control = _lights[light_index]
		if node is TextureRect and tex != null:
			(node as TextureRect).texture = tex
		await get_tree().create_timer((1.0 / 16.0) / maxf(Engine.time_scale, 0.001)).timeout
	_set_light(light_index, true)


func set_lever_ready_fx(on: bool) -> void:
	if _lever_glow == null:
		return
	_kill_lever_glow_tw()
	_lever_glow.visible = on
	if on and not reduce_motion:
		_lever_glow.modulate = Color(1, 1, 1, 0.85)
		var tw := create_tween().set_loops(24)
		tw.tween_property(_lever_glow, "modulate:a", 0.35, 0.6 / maxf(Engine.time_scale, 0.001))
		tw.tween_property(_lever_glow, "modulate:a", 0.85, 0.6 / maxf(Engine.time_scale, 0.001))
		_lever_glow.set_meta("pulse_tw", tw)
	elif on and reduce_motion:
		## Static highlight — no pulse.
		_lever_glow.modulate = Color(1, 1, 1, 0.7)


func _kill_lever_glow_tw() -> void:
	if _lever_glow == null:
		return
	if _lever_glow.has_meta("pulse_tw"):
		var old = _lever_glow.get_meta("pulse_tw")
		if old is Tween and (old as Tween).is_valid():
			(old as Tween).kill()
		_lever_glow.remove_meta("pulse_tw")


## Faint glow after the first light turns on, until the board hits READY (5).
func set_lever_faint_glow(on: bool) -> void:
	if _lever_glow == null:
		return
	var st: StringName = &"locked"
	if _lever != null and _lever.has_meta("lever_state"):
		st = _lever.get_meta("lever_state")
	if st == &"ready" or st == &"spent":
		return
	_kill_lever_glow_tw()
	_lever_glow.visible = on
	_lever_glow.modulate = Color(1, 1, 1, 0.28 if on else 0.0)
	if on and not reduce_motion:
		## Very soft breathe — not the bright ready chase.
		var tw := create_tween().set_loops(24)
		tw.tween_property(_lever_glow, "modulate:a", 0.12, 1.0 / maxf(Engine.time_scale, 0.001))
		tw.tween_property(_lever_glow, "modulate:a", 0.32, 1.0 / maxf(Engine.time_scale, 0.001))
		_lever_glow.set_meta("pulse_tw", tw)


func lever_control() -> Control:
	return _lever


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


func play_pull_anim() -> void:
	## lever_pull_f0..f4 @ 12 fps, then hold pulled. Reduce-motion skips to pulled.
	if _lever == null:
		return
	_kill_lever_glow_tw()
	if _lever_glow != null:
		_lever_glow.visible = false
	if reduce_motion:
		_apply_lever_tex("trophy_board/lever_pulled")
		_lever.set_meta("lever_state", &"spent")
		return
	for fi in 5:
		_apply_lever_tex("trophy_board/lever_pull_f%d" % fi)
		await get_tree().create_timer((1.0 / LEVER_PULL_FPS) / maxf(Engine.time_scale, 0.001)).timeout
	_apply_lever_tex("trophy_board/lever_pulled")
	_lever.set_meta("lever_state", &"spent")


func _apply_lever_tex(stem: String) -> void:
	var tex: Texture2D = KIT.ui_tex(stem)
	var art_sz: Vector2 = _lever.get_meta("art_size", LEVER_ART) if _lever != null else LEVER_ART
	var pad := (_lever.size - art_sz) * 0.5 if _lever != null else Vector2.ZERO
	if _lever.get_node_or_null("Art") == null:
		var art := TextureRect.new()
		art.name = "Art"
		art.position = pad
		art.size = art_sz
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_SCALE
		art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lever.add_child(art)
	var art_n = _lever.get_node_or_null("Art")
	if art_n is TextureRect:
		(art_n as TextureRect).position = pad
		(art_n as TextureRect).size = art_sz
		if tex != null:
			(art_n as TextureRect).texture = tex
		(art_n as TextureRect).visible = true
	elif _lever is TextureRect and tex != null:
		(_lever as TextureRect).texture = tex


func _set_lever(st: StringName, hidden: bool) -> void:
	_lever.visible = not hidden
	_lever_glow.visible = false
	_lever.set_meta("lever_state", st)
	## Keep glow plate parked at lever origin − (32, 56) even if hit rect moves.
	if _lever_glow != null:
		_lever_glow.position = _lever.position + LEVER_GLOW_OFFSET
		_lever_glow.size = LEVER_GLOW_SIZE
	var stem := "trophy_board/lever_locked"
	if st == &"ready":
		stem = "trophy_board/lever_ready"
		set_lever_ready_fx(true)
	elif st == &"spent":
		stem = "trophy_board/lever_pulled"
	_apply_lever_tex(stem)
	## Faint glow after first light (locked only) — bright READY glow handled above.
	if st == &"locked" and not hidden and bool(get_meta("faint_glow", false)):
		set_lever_faint_glow(true)


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
