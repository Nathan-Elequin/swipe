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
	if instant or reduce_motion:
		_snap_faces()
		_update_chrome()
		face_changed.emit(_current)
		_arm_view_timer()
		slide_done.emit()
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
		tw.tween_property(node, "position:x", target_x, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_spin_cogs(dir)
	await get_tree().create_timer(dur * 0.5).timeout
	_update_chrome()
	face_changed.emit(_current)
	await get_tree().create_timer(dur * 0.5).timeout
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
	_viewport.size = vp_local.size
	_viewport.clip_contents = true
	_viewport.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_viewport)
	## Plaque sticks above frame: absolute (600,16) → board-local
	var plaque_r := Rect2(
		Vector2(600, 16) - MODEL.BOARD_OUTER.position,
		Vector2(480, 96)
	)
	_plaque = _tex_or_box("Plaque", plaque_r, "trophy_board/plaque_verdant", Color("c4a574"))
	_plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque)
	_plaque_lab = Label.new()
	_plaque_lab.name = "PlaqueLabel"
	_plaque_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plaque_lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_plaque_lab.add_theme_font_size_override("font_size", 40)
	_plaque_lab.add_theme_color_override("font_color", Color("1c120c"))
	_plaque_lab.position = plaque_r.position + Vector2(40, 24)
	_plaque_lab.size = Vector2(400, 48)
	_plaque_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque_lab)
	## Arrows / rails
	_rail_l = _make_rail(true)
	_rail_r = _make_rail(false)
	add_child(_rail_l)
	add_child(_rail_r)
	_arrow_l = _tex_or_box(
		"ArrowL",
		Rect2(Vector2(176, 396) - MODEL.BOARD_OUTER.position, Vector2(48, 80)),
		"trophy_board/arrow_l_idle",
		Color("c4a574")
	)
	_arrow_r = _tex_or_box(
		"ArrowR",
		Rect2(Vector2(1456, 396) - MODEL.BOARD_OUTER.position, Vector2(48, 80)),
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
	## Dots on bottom band: absolute x 712+k*56, y 764
	for k in 5:
		var dr := Rect2(
			Vector2(712 + k * 56, 764) - MODEL.BOARD_OUTER.position,
			Vector2(32, 32)
		)
		var hit := Control.new()
		hit.name = "Dot%d" % k
		hit.position = dr.position - Vector2(8, 8)
		hit.size = Vector2(48, 48)
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		var art := _tex_or_box("Art", Rect2(8, 8, 32, 32), "trophy_board/dot_idle", Color("c4a574"))
		hit.add_child(art)
		var pip := _tex_or_box("Pip", Rect2(8 + 20, 8 - 6, 16, 16), "trophy_board/dot_new_pip_f0", Color("a8322a"))
		pip.visible = false
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
	var slug := str(face.get("slug", "verdant"))
	_plaque_lab.text = str(face.get("name", ""))
	var ptex: Texture2D = KIT.ui_tex("trophy_board/plaque_%s" % slug)
	if _plaque is TextureRect and ptex != null:
		(_plaque as TextureRect).texture = ptex
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
			(_pips[i] as Control).visible = show_pip
	## Refresh current face states (lights / lever)
	if _current < _face_nodes.size():
		(_face_nodes[_current] as TrophyBoardFace).apply_states(
			_rules, _campaign_state, _cabin_seen, _hold
		)


func _make_rail(left: bool) -> Control:
	var abs_r := Rect2(176, 128, 48, 616) if left else Rect2(1456, 128, 48, 616)
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
	var tw := create_tween()
	var ox := position.x
	tw.tween_property(self, "position:x", ox + 6.0, 0.04 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(self, "position:x", ox - 6.0, 0.06 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(self, "position:x", ox, 0.05 / maxf(Engine.time_scale, 0.001))


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
	var face: Dictionary = _faces_data[_current] if _current < _faces_data.size() else {}
	var slot = (_face_nodes[_current] as TrophyBoardFace).slot_node(card_id) if _current < _face_nodes.size() else null
	var tip := ""
	if st == &"unseen" or MODEL.is_face_locked(_rules, _campaign_state, face):
		tip = COPY.text("board.tip.unseen", "Yet to be seen.")
	elif st == &"seen":
		var card: Dictionary = _items_by_id.get(card_id, {})
		tip = str(card.get("name", card_id))
	else:
		var card2: Dictionary = _items_by_id.get(card_id, {})
		var name := str(card2.get("name", card_id))
		var journal := _journal_for(card_id)
		if journal == "":
			tip = "%s\n%s" % [name, COPY.text("board.tip.claimed_nolore", "Home where it belongs.")]
		else:
			tip = "%s\n%s\n%s" % [
				name,
				COPY.text("cabin.tip.journal", "From Grandpa's journal:"),
				journal,
			]
	if tip != "" and slot != null:
		hover_tip.emit(tip, slot)


func _on_slot_click(card_id: String, st: StringName) -> void:
	if st == &"unseen":
		_cue("cabin.locked")
		_bump()
		return
	slot_clicked.emit(card_id)
	inspect_wanted.emit(card_id)


func _on_lever(face_index: int) -> void:
	if face_index < 0 or face_index >= _faces_data.size():
		return
	var face: Dictionary = _faces_data[face_index]
	if MODEL.is_face_locked(_rules, _campaign_state, face):
		return
	var ls: StringName = MODEL.lever_state(_rules, _campaign_state, face)
	if ls == &"ready":
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
