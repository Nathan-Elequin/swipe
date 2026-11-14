class_name TrophyBoard
extends Control
## Carousel trophy board hosted in the hall. Package B shared node API.


signal face_changed(index: int)
signal lever_pulled(face_index: int)
signal slot_clicked(card_id: String)
signal wants_pan_left()
signal hover_tip(text: String, anchor: Control)
signal hover_clear()
signal inspect_wanted(card_id: String)
signal slide_done()

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const FACE_SCR := preload("res://scripts/cabin/trophy_board_face.gd")
const COPY := preload("res://scripts/player_copy.gd")

var reduce_motion := false
var invert_scroll := false

var _rules: Dictionary = {}
var _items_by_id: Dictionary = {}
var _campaign_state: Dictionary = {}
var _cabin_seen: Dictionary = {}
var _hold: Array = []
var _tex_by_id: Dictionary = {}
var _board_viewed: Dictionary = {}  # claimed ids already viewed

var _faces_data: Array = []
var _face_nodes: Array = []  # TrophyBoardFace
var _current: int = 0
var _sliding: bool = false
var _queued_dir: int = 0
var _viewport: Control
var _frame: Control
var _plaque: Control
var _plaque_lab: Label
var _trim: Control
var _dots: Array = []
var _pips: Array = []
var _arrow_l: Control
var _arrow_r: Control
var _rail_l: Control
var _rail_r: Control
var _cog_l: Control
var _cog_r: Control
var _wheel_debounce: float = 0.0
var _view_timer: float = 0.0
var _sfx = null
## Click parchment tag (name + one-line ability). No combat-card fly tip.
var _item_tag: Control = null
var _item_tag_title: Label = null
var _item_tag_body: Label = null
var _item_tag_open: bool = false


func setup(rules, items_by_id, campaign_state, cabin_seen, hold: Array) -> void:
	_rules = rules if typeof(rules) == TYPE_DICTIONARY else {}
	_items_by_id = items_by_id if typeof(items_by_id) == TYPE_DICTIONARY else {}
	_campaign_state = campaign_state if typeof(campaign_state) == TYPE_DICTIONARY else {}
	_cabin_seen = cabin_seen if typeof(cabin_seen) == TYPE_DICTIONARY else {}
	_hold = hold.duplicate() if hold is Array else []
	name = "TrophyBoard"
	position = MODEL.BOARD_OUTER.position
	size = MODEL.BOARD_OUTER.size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _viewport == null:
		_build_shell()
	refresh()


func set_item_textures(tex_by_id: Dictionary) -> void:
	_tex_by_id = tex_by_id


func set_sfx(sfx) -> void:
	_sfx = sfx


func set_board_viewed(viewed: Dictionary) -> void:
	_board_viewed = viewed.duplicate() if typeof(viewed) == TYPE_DICTIONARY else {}


func board_viewed() -> Dictionary:
	return _board_viewed.duplicate()


## Homecoming drains bank_pending one id at a time; keep hold in sync for lights/pips.
func set_hold(hold: Array) -> void:
	_hold = hold.duplicate() if hold is Array else []
	_update_chrome()


func refresh() -> void:
	_faces_data = MODEL.faces(_rules, _items_by_id)
	_rebuild_faces()
	_update_chrome()
	slide_to(_current, true)


func current_face() -> int:
	return _current


func slide_to(index: int, instant := false) -> void:
	hide_item_tag()
	if _faces_data.is_empty():
		slide_done.emit()
		return
	var dest := clampi(index, 0, _faces_data.size() - 1)
	if dest == _current and not instant and not _sliding:
		_update_chrome()
		slide_done.emit()
		return
	var from := _current
	_current = dest
	if instant:
		_snap_faces()
		_update_chrome()
		face_changed.emit(_current)
		_arm_view_timer()
		slide_done.emit()
		return
	## Package E / SCREEN §11: reduce motion → 0.15 s cross-fade, no travel, no cog.
	if reduce_motion:
		_sliding = true
		_view_timer = -1.0
		var fade_dur := 0.15 / maxf(Engine.time_scale, 0.001)
		var outgoing: Control = null
		var incoming: Control = null
		if from >= 0 and from < _face_nodes.size():
			outgoing = _face_nodes[from]
		if dest >= 0 and dest < _face_nodes.size():
			incoming = _face_nodes[dest]
		_snap_faces()
		if outgoing != null:
			outgoing.modulate.a = 1.0
		if incoming != null:
			incoming.modulate.a = 0.0
		var ftw := create_tween()
		ftw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		ftw.set_parallel(true)
		if outgoing != null:
			ftw.tween_property(outgoing, "modulate:a", 0.0, fade_dur)
		if incoming != null:
			ftw.tween_property(incoming, "modulate:a", 1.0, fade_dur)
		await ftw.finished
		for n in _face_nodes:
			(n as Control).modulate.a = 1.0
		_update_chrome()
		face_changed.emit(_current)
		_sliding = false
		_arm_view_timer()
		slide_done.emit()
		if _queued_dir != 0:
			var q0 := _queued_dir
			_queued_dir = 0
			handle_nav(q0)
		return
	_sliding = true
	_view_timer = -1.0
	var span := MODEL.FACE_VIEWPORT.size.x
	var dir := signi(dest - from)
	if dir == 0:
		dir = 1
	## Extra faces: duration 0.36 + 0.04 per extra, cap 0.5
	var steps := maxi(1, absi(dest - from))
	var dur := minf(0.5, 0.36 + 0.04 * float(steps - 1)) / maxf(Engine.time_scale, 0.001)
	for i in _face_nodes.size():
		var node: Control = _face_nodes[i]
		var target_x := float(i - dest) * span
		var start_x := float(i - from) * span
		node.position.x = start_x
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(node, "position:x", target_x, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_spin_cogs(dir)
	## Cabin keeps SceneTree.paused; ignore_pause so the slide always finishes.
	await get_tree().create_timer(dur * 0.5, true, false, true).timeout
	_update_chrome()
	face_changed.emit(_current)
	await get_tree().create_timer(dur * 0.5, true, false, true).timeout
	_sliding = false
	_snap_faces()
	_arm_view_timer()
	slide_done.emit()
	if _queued_dir != 0:
		var q := _queued_dir
		_queued_dir = 0
		handle_nav(q)


func slot_global_center(card_id: String) -> Vector2:
	var slot = slot_node(card_id)
	if slot != null:
		return slot.get_global_rect().get_center()
	return get_global_rect().get_center()


## Live slot Control for a card id (any face). Null if missing.
func slot_node(card_id: String):
	for face_n in _face_nodes:
		var slot = (face_n as TrophyBoardFace).slot_node(card_id)
		if slot != null:
			return slot
	return null


func place_claimed(card_id: String, fx := true) -> void:
	for face_n in _face_nodes:
		var slot = (face_n as TrophyBoardFace).slot_node(card_id)
		if slot == null:
			continue
		if fx:
			slot.play_claim_pop()
		else:
			slot.apply_state(&"claimed")
		return


func flash_light(face_index: int, light_index: int) -> void:
	if face_index < 0 or face_index >= _face_nodes.size():
		return
	(_face_nodes[face_index] as TrophyBoardFace).flash_light(light_index)


func set_lever_ready_fx(on: bool) -> void:
	if _current < 0 or _current >= _face_nodes.size():
		return
	(_face_nodes[_current] as TrophyBoardFace).set_lever_ready_fx(on)


func set_lever_faint_glow(on: bool) -> void:
	for face_n in _face_nodes:
		(face_n as TrophyBoardFace).set_meta("faint_glow", on)
		(face_n as TrophyBoardFace).set_lever_faint_glow(on)


func lever_node() -> Control:
	if _current < 0 or _current >= _face_nodes.size():
		return null
	return (_face_nodes[_current] as TrophyBoardFace).lever_control()


## Gentle pulse on one claimed slot until the player hovers it (first return).
func set_pulse_id(card_id: String) -> void:
	for face_n in _face_nodes:
		var face: TrophyBoardFace = face_n
		## Clear pulse on every slot; enable only the matching id.
		if face.has_method("clear_all_pulses"):
			face.clear_all_pulses()
		var slot = face.slot_node(str(card_id)) if card_id != "" else null
		if slot != null and slot.has_method("set_gentle_pulse"):
			slot.set_gentle_pulse(true)


func play_gild(face_index: int, instant := false) -> void:
	if face_index < 0 or face_index >= _face_nodes.size():
		return
	(_face_nodes[face_index] as TrophyBoardFace).play_gild(instant)
	if _trim:
		_trim.visible = true
		_trim.modulate.a = 1.0 if instant else 0.0
		if not instant:
			var tw := create_tween()
			tw.tween_property(_trim, "modulate:a", 1.0, 0.3 / maxf(Engine.time_scale, 0.001))


func handle_nav(dir: int) -> bool:
	if dir == 0:
		return false
	if _sliding:
		_queued_dir = dir
		return true
	if dir < 0:
		if _current <= 0:
			wants_pan_left.emit()
			return true
		slide_to(_current - 1)
		_cue("board.slide")
		return true
	if _current >= _faces_data.size() - 1:
		_bump()
		return true
	slide_to(_current + 1)
	_cue("board.slide")
	return true


func _build_shell() -> void:
	_item_tag = null
	_item_tag_title = null
	_item_tag_body = null
	_item_tag_open = false
	for c in get_children():
		c.queue_free()
	_face_nodes.clear()
	_dots.clear()
	_pips.clear()
	## Frame
	_frame = _tex_or_box("Frame", Rect2(Vector2.ZERO, size), "trophy_board/board_frame", Color("4a2f1f"))
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	## Face viewport (clip), local to board: absolute face - board origin
	var vp_local := Rect2(
		MODEL.FACE_VIEWPORT.position - MODEL.BOARD_OUTER.position,
		MODEL.FACE_VIEWPORT.size
	)
	_viewport = Control.new()
	_viewport.name = "FaceViewport"
	_viewport.position = vp_local.position
	## Tall enough that the floor lever (HALL_FLOOR_Y) stays inside this clip host,
	## while neighbour faces never paint outside the board frame (whole-room slide bug).
	var vp_h: float = maxf(vp_local.size.y, MODEL.HALL_FLOOR_Y - MODEL.FACE_VIEWPORT.position.y)
	_viewport.size = Vector2(vp_local.size.x, vp_h)
	_viewport.clip_contents = true
	_viewport.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_viewport)
	## Painted placard (Nearest, 1:1). New signs are 120 tall; widths even so centre is whole pixels.
	## Screen top at y 0, centred on x 840 → board-local.
	_plaque = TextureRect.new()
	_plaque.name = "Plaque"
	_plaque.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_plaque.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_plaque.stretch_mode = TextureRect.STRETCH_KEEP
	_plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque)
	## Live name label retired — painted art carries the title. Keep for a11y hook only.
	_plaque_lab = Label.new()
	_plaque_lab.name = "PlaqueLabel"
	_plaque_lab.visible = false
	_plaque_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque_lab)
	_apply_placard_tex("b1", "Verdant Hollow")
	## Arrows / rails
	_rail_l = _make_rail(true)
	_rail_r = _make_rail(false)
	add_child(_rail_l)
	add_child(_rail_r)
	var arrow_y: float = 396.0 - MODEL.BOARD_RAISE_PX
	_arrow_l = _tex_or_box(
		"ArrowL",
		Rect2(Vector2(176, arrow_y) - MODEL.BOARD_OUTER.position, Vector2(48, 80)),
		"trophy_board/arrow_l_idle",
		Color("c4a574")
	)
	_arrow_r = _tex_or_box(
		"ArrowR",
		Rect2(Vector2(1456, arrow_y) - MODEL.BOARD_OUTER.position, Vector2(48, 80)),
		"trophy_board/arrow_r_idle",
		Color("c4a574")
	)
	_arrow_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_arrow_l)
	add_child(_arrow_r)
	## Cogs
	_cog_l = _tex_or_box("CogL", Rect2(Vector2(24, 232), Vector2(48, 48)), "trophy_board/rail_cog", Color("c4a574"))
	_cog_r = _tex_or_box("CogR", Rect2(Vector2(size.x - 72, 232), Vector2(48, 48)), "trophy_board/rail_cog", Color("c4a574"))
	_cog_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cog_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cog_l)
	add_child(_cog_r)
	## Dots on bottom band: absolute x 712+k*56, y 764 − raise
	var dot_y: float = 764.0 - MODEL.BOARD_RAISE_PX
	for k in 5:
		var dr := Rect2(
			Vector2(712 + k * 56, dot_y) - MODEL.BOARD_OUTER.position,
			Vector2(32, 32)
		)
		var hit := Control.new()
		hit.name = "Dot%d" % k
		hit.position = dr.position - Vector2(8, 8)
		hit.size = Vector2(48, 48)
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		var art := _tex_or_box("Art", Rect2(8, 8, 32, 32), "trophy_board/dot_idle", Color("c4a574"))
		hit.add_child(art)
		## Package E / SCREEN §2 + ASSETS B10n: blinking new-pip on biome dots.
		var pip := _make_new_pip(Rect2(8 + 20, 8 - 6, 16, 16))
		hit.add_child(pip)
		var idx := k
		hit.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				slide_to(idx)
				_cue("board.slide")
		)
		hit.mouse_entered.connect(func() -> void:
			_on_dot_hover(idx, hit)
		)
		hit.mouse_exited.connect(func() -> void: hover_clear.emit())
		add_child(hit)
		_dots.append(hit)
		_pips.append(pip)
	_trim = _tex_or_box("GoldTrim", Rect2(Vector2.ZERO, size), "trophy_board/board_trim_gold", Color(1, 0.85, 0.3, 0.0))
	_trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trim.visible = false
	add_child(_trim)
	_build_item_tag()
	_viewport.gui_input.connect(_on_viewport_gui)


func _rebuild_faces() -> void:
	for c in _viewport.get_children():
		c.queue_free()
	_face_nodes.clear()
	var span := MODEL.FACE_VIEWPORT.size.x
	for i in _faces_data.size():
		var data: Dictionary = _faces_data[i]
		var face_n: TrophyBoardFace = FACE_SCR.new()
		face_n.reduce_motion = reduce_motion
		face_n.setup(data)
		face_n.position = Vector2(float(i - _current) * span, 0)
		var lay: Dictionary = MODEL.layout(data)
		face_n.rebuild_slots(lay, _tex_by_id)
		face_n.apply_states(_rules, _campaign_state, _cabin_seen, _hold)
		face_n.slot_hovered.connect(_on_slot_hover)
		face_n.slot_unhovered.connect(func(_cid: String) -> void: hover_clear.emit())
		face_n.slot_clicked.connect(_on_slot_click)
		face_n.lever_clicked.connect(_on_lever)
		face_n.padlock_hovered.connect(_on_padlock_hover)
		face_n.lights_hovered.connect(_on_lights_hover)
		face_n.lever_hovered.connect(_on_lever_hover)
		_viewport.add_child(face_n)
		_face_nodes.append(face_n)


func _snap_faces() -> void:
	var span := MODEL.FACE_VIEWPORT.size.x
	for i in _face_nodes.size():
		(_face_nodes[i] as Control).position = Vector2(float(i - _current) * span, 0)


func _update_chrome() -> void:
	if _faces_data.is_empty():
		return
	var face: Dictionary = _faces_data[_current]
	var pool_id := str(face.get("pool_id", "b1"))
	var face_name := str(face.get("name", ""))
	_apply_placard_tex(pool_id, face_name)
	if _current < _face_nodes.size():
		(_face_nodes[_current] as TrophyBoardFace).set_plaque_host(_plaque, _plaque_lab)
	var complete: bool = MODEL.is_complete(_campaign_state, face)
	_trim.visible = complete
	for i in _dots.size():
		var locked_face := false
		if i < _faces_data.size():
			locked_face = MODEL.is_face_locked(_rules, _campaign_state, _faces_data[i])
		var stem := "trophy_board/dot_locked" if locked_face else "trophy_board/dot_idle"
		if i == _current:
			stem = "trophy_board/dot_current"
		var art = (_dots[i] as Control).get_node_or_null("Art")
		var tex: Texture2D = KIT.ui_tex(stem)
		if art is TextureRect and tex != null:
			(art as TextureRect).texture = tex
		## New pip: claimed on face not yet in board_viewed
		var show_pip := false
		if i < _faces_data.size() and not locked_face:
			for id in MODEL.face_ids_flat(_faces_data[i]):
				var st: StringName = MODEL.slot_state(_cabin_seen, _campaign_state, str(id), _hold)
				if st == &"claimed" and not _board_viewed.has(str(id)):
					show_pip = true
					break
		if i < _pips.size():
			var pip_n: Control = _pips[i] as Control
			pip_n.visible = show_pip
			_set_pip_playing(pip_n, show_pip and not reduce_motion)
	## Refresh current face states (lights / lever)
	if _current < _face_nodes.size():
		(_face_nodes[_current] as TrophyBoardFace).apply_states(
			_rules, _campaign_state, _cabin_seen, _hold
		)


func _make_rail(left: bool) -> Control:
	var rail_y: float = 128.0 - MODEL.BOARD_RAISE_PX
	var abs_r := Rect2(176, rail_y, 48, 616) if left else Rect2(1456, rail_y, 48, 616)
	var hit := Control.new()
	hit.name = "RailL" if left else "RailR"
	hit.position = abs_r.position - MODEL.BOARD_OUTER.position
	hit.size = abs_r.size
	hit.mouse_filter = Control.MOUSE_FILTER_STOP
	var dir := -1 if left else 1
	hit.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			handle_nav(dir)
	)
	hit.mouse_entered.connect(func() -> void:
		_set_arrow_hover(left, true)
	)
	hit.mouse_exited.connect(func() -> void:
		_set_arrow_hover(left, false)
	)
	return hit


func _set_arrow_hover(left: bool, on: bool) -> void:
	var node: Control = _arrow_l if left else _arrow_r
	var side := "l" if left else "r"
	var stem := "trophy_board/arrow_%s_%s" % [side, "hover" if on else "idle"]
	var tex: Texture2D = KIT.ui_tex(stem)
	if node is TextureRect and tex != null:
		(node as TextureRect).texture = tex


func _spin_cogs(dir: int) -> void:
	if reduce_motion:
		return
	for cog in [_cog_l, _cog_r]:
		if cog == null:
			continue
		var tw := create_tween()
		var start: float = cog.rotation_degrees
		tw.tween_property(cog, "rotation_degrees", start + 90.0 * float(dir), 0.36 / maxf(Engine.time_scale, 0.001))


func _bump() -> void:
	_cue("board.bump")
	if reduce_motion:
		return
	var tw := create_tween()
	var ox := position.x
	tw.tween_property(self, "position:x", ox + 6.0, 0.04 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(self, "position:x", ox - 6.0, 0.06 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(self, "position:x", ox, 0.05 / maxf(Engine.time_scale, 0.001))


## ASSETS B10n — red-gold gem, 2 fps blink. Reduce motion holds f0.
func _make_new_pip(rect: Rect2) -> Control:
	var wrap := Control.new()
	wrap.name = "Pip"
	wrap.position = rect.position
	wrap.size = rect.size
	wrap.visible = false
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var anim := AnimatedSprite2D.new()
	anim.name = "Anim"
	anim.centered = false
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.position = Vector2.ZERO
	anim.scale = Vector2(4, 4) if rect.size.x >= 16 else Vector2.ONE
	var sf := SpriteFrames.new()
	sf.add_animation("blink")
	sf.set_animation_speed("blink", 2.0)
	sf.set_animation_loop("blink", true)
	for fi in 2:
		var tex: Texture2D = KIT.ui_tex("trophy_board/dot_new_pip_f%d" % fi)
		if tex != null:
			sf.add_frame("blink", tex)
	if sf.get_frame_count("blink") == 0:
		## Placeholder box when art is missing.
		var box := _tex_or_box("Art", Rect2(Vector2.ZERO, rect.size), "trophy_board/dot_new_pip_f0", Color("a8322a"))
		wrap.add_child(box)
		return wrap
	anim.sprite_frames = sf
	wrap.add_child(anim)
	## Native 4×4 → display 16×16; AnimatedSprite2D draws at texture size × scale.
	## If ui_tex already returns ×4 baked pixels, keep scale 1.
	var f0: Texture2D = sf.get_frame_texture("blink", 0)
	if f0 != null and f0.get_width() >= 12:
		anim.scale = Vector2.ONE
	return wrap


func _set_pip_playing(pip: Control, playing: bool) -> void:
	if pip == null:
		return
	var anim = pip.get_node_or_null("Anim")
	if anim is AnimatedSprite2D and (anim as AnimatedSprite2D).sprite_frames:
		var a := anim as AnimatedSprite2D
		if playing:
			a.play("blink")
		else:
			a.stop()
			a.frame = 0


func _arm_view_timer() -> void:
	_view_timer = 0.6


func _process(delta: float) -> void:
	if _wheel_debounce > 0.0:
		_wheel_debounce = maxf(0.0, _wheel_debounce - delta)
	if _view_timer > 0.0 and not _sliding:
		_view_timer -= delta * Engine.time_scale
		if _view_timer <= 0.0:
			_mark_face_viewed()


func _mark_face_viewed() -> void:
	if _current < 0 or _current >= _faces_data.size():
		return
	for id in MODEL.face_ids_flat(_faces_data[_current]):
		var st: StringName = MODEL.slot_state(_cabin_seen, _campaign_state, str(id), _hold)
		if st == &"claimed":
			_board_viewed[str(id)] = true
	_update_chrome()


func _on_viewport_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var btn := (event as InputEventMouseButton).button_index
		if btn == MOUSE_BUTTON_WHEEL_UP or btn == MOUSE_BUTTON_WHEEL_DOWN:
			if _wheel_debounce > 0.0:
				return
			_wheel_debounce = 0.25
			var dir := -1 if btn == MOUSE_BUTTON_WHEEL_UP else 1
			if invert_scroll:
				dir = -dir
			handle_nav(dir)


func _on_slot_hover(card_id: String, st: StringName) -> void:
	## No nameplates on slots. Hover stays quiet while a click-tag is open.
	if _item_tag_open:
		return
	var face: Dictionary = _faces_data[_current] if _current < _faces_data.size() else {}
	var slot = (_face_nodes[_current] as TrophyBoardFace).slot_node(card_id) if _current < _face_nodes.size() else null
	if slot == null:
		return
	if MODEL.is_face_locked(_rules, _campaign_state, face) or st == &"unseen":
		hover_tip.emit(COPY.text("board.tip.unseen", "Yet to be seen."), slot)
		return
	## Unclaimed / claimed: name only on hover (full parchment is click).
	var card: Dictionary = _items_by_id.get(card_id, {})
	var tip := str(card.get("name", card_id))
	if tip != "":
		hover_tip.emit(tip, slot)


func _on_slot_click(card_id: String, st: StringName) -> void:
	var face: Dictionary = _faces_data[_current] if _current < _faces_data.size() else {}
	if MODEL.is_face_locked(_rules, _campaign_state, face) or st == &"unseen":
		_cue("cabin.locked")
		_bump()
		hide_item_tag()
		return
	slot_clicked.emit(card_id)
	## Parchment tag replaces the lingering combat-card inspect fly tip.
	var slot = (_face_nodes[_current] as TrophyBoardFace).slot_node(card_id) if _current < _face_nodes.size() else null
	var anchor: Vector2 = get_global_mouse_position()
	if slot != null:
		var gr: Rect2 = slot.get_global_rect()
		anchor = gr.position + Vector2(gr.size.x * 0.5, gr.size.y * 0.35)
	show_item_tag(card_id, anchor)
	if st == &"claimed" and slot != null and slot.has_method("play_click_shine"):
		slot.play_click_shine()


func _build_item_tag() -> void:
	_item_tag = Control.new()
	_item_tag.name = "ItemParchmentTag"
	_item_tag.visible = false
	_item_tag.z_index = 40
	_item_tag.mouse_filter = Control.MOUSE_FILTER_STOP
	_item_tag.custom_minimum_size = Vector2(160, 48)
	add_child(_item_tag)
	var frame: Control = null
	var parch: Texture2D = KIT.ui_tex("trophy/parchment_tag")
	if parch != null:
		var nine := NinePatchRect.new()
		nine.name = "Frame"
		nine.texture = parch
		nine.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		## Display margins 24 (6 native ×4). Centre/edges are flat and safe to stretch.
		nine.patch_margin_left = 24
		nine.patch_margin_top = 24
		nine.patch_margin_right = 24
		nine.patch_margin_bottom = 24
		nine.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		nine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_item_tag.add_child(nine)
		frame = nine
	else:
		var panel := Panel.new()
		panel.name = "Frame"
		panel.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("e8d5a8")
		sb.border_color = Color("6b4a2b")
		sb.set_border_width_all(2)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		panel.add_theme_stylebox_override("panel", sb)
		_item_tag.add_child(panel)
		frame = panel
	## NinePatch margins are 24 — keep text inside the flat centre with matching pad.
	var col := VBoxContainer.new()
	col.name = "Cols"
	col.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	col.offset_left = 24
	col.offset_top = 24
	col.offset_right = -24
	col.offset_bottom = -24
	col.add_theme_constant_override("separation", 6)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_tag.add_child(col)
	_item_tag_title = Label.new()
	_item_tag_title.name = "Title"
	## Readable size: at least hover-panel body (16–22). Dark brown #4a2f1f.
	_item_tag_title.add_theme_font_size_override("font_size", 22)
	_item_tag_title.add_theme_color_override("font_color", Color("4a2f1f"))
	_item_tag_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_tag_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_item_tag_title)
	_item_tag_body = Label.new()
	_item_tag_body.name = "Body"
	_item_tag_body.add_theme_font_size_override("font_size", 18)
	_item_tag_body.add_theme_color_override("font_color", Color("4a2f1f"))
	_item_tag_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_tag_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_item_tag_body)
	_item_tag.mouse_exited.connect(_on_item_tag_mouse_exited)
	set_process_unhandled_input(true)


func show_item_tag(card_id: String, screen_anchor: Vector2) -> void:
	if _item_tag == null or not is_instance_valid(_item_tag):
		_build_item_tag()
	if _item_tag == null or not is_instance_valid(_item_tag):
		return
	var card: Dictionary = _items_by_id.get(card_id, {})
	var title := str(card.get("name", card_id))
	## Existing one-line ability only — never invent copy.
	var body := str(card.get("ability", "")).strip_edges()
	if body == "":
		body = str(card.get("explainer", "")).strip_edges()
	_item_tag_title.text = title
	_item_tag_body.text = body
	_item_tag_body.visible = body != ""
	## Size to content (24px pad each side from ninepatch), then clamp on screen.
	var max_w := 320.0
	var pad := 48.0 ## 24 left + 24 right
	_item_tag_title.custom_minimum_size = Vector2(max_w - pad, 0)
	_item_tag_body.custom_minimum_size = Vector2(max_w - pad, 0)
	var title_sz: Vector2 = _item_tag_title.get_minimum_size()
	var body_sz: Vector2 = _item_tag_body.get_minimum_size() if _item_tag_body.visible else Vector2.ZERO
	var w: float = clampf(maxi(title_sz.x, body_sz.x) + pad, 180.0, max_w)
	var h: float = 24.0 + title_sz.y + (6.0 + body_sz.y if _item_tag_body.visible else 0.0) + 24.0
	_item_tag.size = Vector2(w, h)
	## Sit beside the item (mock), not overlapping it. Prefer right; flip left if needed.
	var gp := screen_anchor + Vector2(56, -h * 0.35)
	var view := Rect2(0, 0, 1680, 1040)
	var vp := get_viewport()
	if vp != null:
		view = vp.get_visible_rect()
		if view.size.x < 8.0 or view.size.y < 8.0:
			view = Rect2(0, 0, 1680, 1040)
	if gp.x + w > view.position.x + view.size.x - 8.0:
		gp.x = screen_anchor.x - w - 56.0
	gp.x = clampf(gp.x, view.position.x + 8.0, view.position.x + view.size.x - w - 8.0)
	gp.y = clampf(gp.y, view.position.y + 8.0, view.position.y + view.size.y - h - 8.0)
	_item_tag.global_position = gp
	_item_tag.visible = true
	_item_tag_open = true
	hover_clear.emit()


func hide_item_tag() -> void:
	_item_tag_open = false
	if _item_tag:
		_item_tag.visible = false


func _on_item_tag_mouse_exited() -> void:
	## Auto-hide as soon as the mouse leaves the tag.
	if _item_tag_open:
		hide_item_tag()


func _unhandled_input(event: InputEvent) -> void:
	if not _item_tag_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			hide_item_tag()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed:
		## Click elsewhere closes the tag.
		if _item_tag != null and not _item_tag.get_global_rect().has_point(event.position):
			hide_item_tag()


func _on_lever(face_index: int) -> void:
	if face_index < 0 or face_index >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[face_index]
	if MODEL.is_face_locked(_rules, _campaign_state, face):
		return
	var ls: StringName = MODEL.lever_state(_rules, _campaign_state, face)
	if ls == &"ready":
		## Pull frames f0..f4 @ 12 fps before the portal sequence commits.
		if face_index < _face_nodes.size():
			var face_n: TrophyBoardFace = _face_nodes[face_index]
			if face_n != null and face_n.has_method("play_pull_anim"):
				await face_n.play_pull_anim()
		lever_pulled.emit(face_index)
	elif ls == &"locked":
		_cue("cabin.locked")
		_bump()


func _on_padlock_hover() -> void:
	if _current >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[_current]
	var prev := MODEL.prev_biome_name(_rules, face)
	var tip := COPY.fill(
		"board.locked.tip",
		{"prev": prev},
		"Five different finds from %s open this one." % prev
	)
	var pad = (_face_nodes[_current] as TrophyBoardFace)._padlock if _current < _face_nodes.size() else self
	hover_tip.emit(tip, pad)


func _on_lights_hover() -> void:
	if _current >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[_current]
	var tip := COPY.fill(
		"board.lights.tip",
		{"biome": str(face.get("name", ""))},
		"One light for each different find from %s. Five lights open the way deeper." % str(face.get("name", ""))
	)
	hover_tip.emit(tip, self)


func _on_lever_hover(st: StringName) -> void:
	if _current >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[_current]
	var tip := ""
	match st:
		&"ready":
			tip = COPY.text("board.lever.ready", "Pull it.")
		&"spent":
			tip = COPY.fill(
				"board.lever.spent",
				{"next": MODEL.next_biome_id(_rules, face)},
				"The way to %s is open." % MODEL.next_biome_id(_rules, face)
			)
		_:
			tip = COPY.text("board.lever.locked", "Light all five first.")
	hover_tip.emit(tip, self)


func _on_dot_hover(idx: int, hit: Control) -> void:
	if idx >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[idx]
	var tip := COPY.fill(
		"board.dot.tip",
		{"biome": str(face.get("name", ""))},
		str(face.get("name", ""))
	)
	hover_tip.emit(tip, hit)


func _journal_for(card_id: String) -> String:
	var lore_items: Variant = COPY.lore_pack.get("items", {}) if COPY.lore_pack else {}
	if typeof(lore_items) != TYPE_DICTIONARY:
		return ""
	var entry: Variant = (lore_items as Dictionary).get(card_id, {})
	if typeof(entry) != TYPE_DICTIONARY:
		return ""
	return str((entry as Dictionary).get("journal", ""))


func _apply_placard_tex(pool_id: String, face_name: String) -> void:
	if _plaque == null:
		return
	var pid := pool_id if pool_id != "" else "b1"
	var ptex: Texture2D = KIT.ui_tex("trophy_board/placard_%s" % pid)
	if _plaque_lab != null:
		_plaque_lab.text = face_name
		_plaque_lab.visible = false
	if _plaque is TextureRect:
		var tr := _plaque as TextureRect
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		if ptex != null:
			tr.texture = ptex
			var tw := float(ptex.get_width())
			var th := float(ptex.get_height())
			tr.size = Vector2(tw, th)
			## Screen centre x 840, top y 0 → board-local. Floor so subpixel blur never creeps in.
			var cx := floorf(840.0 - tw * 0.5)
			tr.position = Vector2(cx, 0.0) - MODEL.BOARD_OUTER.position
		tr.tooltip_text = face_name


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


func _cue(id: String) -> void:
	if _sfx == null:
		return
	KIT.cue(_sfx, StringName(id))
