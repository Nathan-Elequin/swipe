extends Control
## Stone wheel. Tight seats, inward name capsules, smaller hub the knight fills.

signal slice_clicked(index: int)
signal slice_hovered(index: int)
signal slice_right_clicked(index: int)

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")

const SIX := PI / 2.0
const OUTER_R := 300.0
## Was 96. Nathan: about 40% too large.
const HUB_R := 58.0
const SEAT_R := 188.0
const SEAT := 64.0
const SPRITE := 56.0
const ICON_GAP := 28.0
const EMPTY_FILL := Color("120C09")
const STONE := Color("2a231e")
const STONE_DEEP := Color("1c1814")
const RING := Color("7A4E2B")
const HUB := Color("140D0A")
const HUB_FRAC := HUB_R / OUTER_R
const DISC := Color("3B2618")
const SEAT_WOOD := Color("5A3A22")
const HOVER_FILL := Color("4A3416")
const CHIP_ATK := Color("2A1C14")
const FACE_RIM := Color("FFD84A")
const PLACE_RIM := Color("8dcb8d")
const BRIBE_RIM := Color("d19a66")
const ATK_COL := Color("FFD84A")
const ATK_FILL := Color("6a1c14")
const ATK_EDGE := Color("e07040")
const HP_COL := Color("f0e6d8")
const HP_FILL := Color("C43B34")
const DOWN_COL := Color("c45c5c")
const UP_COL := Color("7dba7d")
const SPIN_COL := Color("FFD84A")
const BLK_BLUE := Color("4FA3D9")
const DIM := Color("A88C66")

var slices: Array = []
var facing_index: int = -1
var hover_index: int = -1
var spinning: bool = false
var highlight: String = "none"
var preview: Dictionary = {}
var rot: float = 0.0:
	set(v):
		rot = v
		queue_redraw()

var tex_heart: Texture2D
var tex_sword: Texture2D
var tex_plus: Texture2D
var tex_shield: Texture2D
var tex_heart_full: Texture2D
var tex_heart_empty: Texture2D
var tex_by_id: Dictionary = {}
var tex_special: Dictionary = {}
var tex_portraits: Dictionary = {}

var _spin_tween: Tween
var _lift: Dictionary = {}
var _floaters: Array = []
var _flash: Dictionary = {}
var slay_index: int = -1
var slay_kind: String = "slay"
var slay_t: float = 0.0:
	set(v):
		slay_t = v
		queue_redraw()
var collapse: float = 0.0:
	set(v):
		collapse = v
		queue_redraw()
var busy: bool = false
var nest_empty: bool = false
var hub_blk: int = -1
var hub_ghost: int = -1
var hub_on: bool = false
var hub_flash: float = 0.0:
	set(v):
		hub_flash = v
		queue_redraw()
var hub_hp_flash: float = 0.0:
	set(v):
		hub_hp_flash = v
		queue_redraw()
var _hub_old: String = ""
var _hub_old_t: float = 0.0:
	set(v):
		_hub_old_t = v
		queue_redraw()
var _hub_hp_old: String = ""
var _hub_hp_old_t: float = 0.0:
	set(v):
		_hub_hp_old_t = v
		queue_redraw()
var _pt_ghosts: Array = []
var tex_player: Array = []
var hub_hp: int = 6
var hub_hp_max: int = 6
var hub_hp_ghost: int = -1
var threat_t: float = 0.0:
	set(v):
		threat_t = v
		queue_redraw()
var _threat_tween: Tween
var draft_glow: bool = false
var _glow_t: float = 0.0
var seat_fx: Dictionary = {}
var seat_hover_on: bool = true
var streak_a: float = 0.0:
	set(v):
		streak_a = v
		queue_redraw()
var _seat_nudge: Vector2 = Vector2.ZERO
var _refuse_nudge: Dictionary = {}
var _font_px: Font
var _font_sk: Font
var _font_nu: Font
var _font_nx: Font
var _font_nb: Font
var _font_ns: Font
var _alcove_root: Node2D
var _alcoves: Array[TextureRect] = []
var _tex_alcove_empty: Texture2D
var _tex_alcove_full: Texture2D
var _tex_alcove_facing: Texture2D
var _tex_alcove_hover: Texture2D
var _tex_alcove_valid: Texture2D
var _tex_alcove_full_weak: Texture2D
var _tex_alcove_full_tough: Texture2D
var _tex_alcove_full_deadly: Texture2D
var _use_alcove_tex: bool = true
var dim_nonfacing: bool = false
var tut_wedges: Array = []:
	set(v):
		tut_wedges = v
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)
	mouse_exited.connect(_on_mouse_out)
	set_process(true)
	_font_px = UI.font_pixel()
	_font_sk = UI.font_silk()
	_font_nu = UI.font_regular()
	_font_nx = UI.font_extrabold()
	_font_nb = UI.font_bold()
	_font_ns = UI.font_semibold()
	_build_alcoves()


func set_atlas(heart: Texture2D, sword: Texture2D, plus: Texture2D, by_id: Dictionary, specials: Dictionary, shield: Texture2D = null) -> void:
	tex_heart = heart
	tex_sword = sword
	if ResourceLoader.exists("res://assets/dungeon/ui/cursorSword_gold.png"):
		var gold_sw: Texture2D = load("res://assets/dungeon/ui/cursorSword_gold.png") as Texture2D
		if gold_sw != null:
			tex_sword = gold_sw
	tex_plus = plus
	tex_by_id = by_id
	tex_special = specials
	tex_shield = shield
	queue_redraw()


func set_portraits(d: Dictionary) -> void:
	tex_portraits = d
	queue_redraw()


func set_player(frames: Array) -> void:
	tex_player = frames
	queue_redraw()


func set_hub_hearts(full: Texture2D, empty: Texture2D) -> void:
	tex_heart_full = full
	tex_heart_empty = empty
	queue_redraw()


func set_vitals(hp_n: int, hp_max: int, hp_ghost: int, blk_n: int, blk_ghost: int) -> void:
	if hub_on and hub_hp != hp_n and hub_hp >= 0:
		_hub_hp_old = "%s/%s" % [hub_hp, hub_hp_max]
		_hub_hp_old_t = 1.0
		hub_hp_flash = 1.0
		var htw := create_tween()
		htw.tween_property(self, "_hub_hp_old_t", 0.0, 0.28)
		var htw2 := create_tween()
		htw2.tween_property(self, "hub_hp_flash", 0.0, 0.34)
	hub_hp = hp_n
	hub_hp_max = maxi(1, hp_max)
	hub_hp_ghost = hp_ghost
	if hub_on and hub_blk != blk_n and hub_blk >= 0:
		_hub_old = str(hub_blk)
		_hub_old_t = 1.0
		var tw := create_tween()
		tw.tween_property(self, "_hub_old_t", 0.0, 0.22)
	hub_blk = blk_n
	hub_ghost = blk_ghost
	hub_on = true
	queue_redraw()


func set_nest_empty(on: bool) -> void:
	nest_empty = on
	queue_redraw()
	_sync_alcoves()


func set_slices(next: Array, face: int, mode: String = "none") -> void:
	var prev := {}
	for s in slices:
		prev[str(s.get("slot", ""))] = s
	slices = next
	facing_index = face
	highlight = mode
	for i in slices.size():
		var s: Dictionary = slices[i]
		var old: Dictionary = prev.get(str(s.get("slot", "")), {})
		if old.is_empty() or str(old.get("kind", "")) != "monster":
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		var pos: Vector2 = _atk_pos(i)
		if int(old.get("atk", 0)) != int(s.get("atk", 0)):
			_pt_ghosts.append({"pos": pos, "text": str(old.get("atk", 0)), "col": ATK_COL, "t": 0.0, "life": 0.28, "fs": 18})
		if int(old.get("hp", 0)) != int(s.get("hp", 0)):
			_pt_ghosts.append({"pos": _hp_pos(i), "text": str(old.get("hp", 0)), "col": HP_COL, "t": 0.0, "life": 0.28, "fs": 18})
	queue_redraw()


func set_preview(next: Dictionary) -> void:
	preview = next
	queue_redraw()


func set_seat_fx(next: Dictionary) -> void:
	seat_fx = next
	queue_redraw()


func set_hub(blk_n: int, ghost: int, on: bool) -> void:
	if on and hub_on and hub_blk != blk_n and hub_blk >= 0:
		_hub_old = str(hub_blk)
		_hub_old_t = 1.0
		var tw := create_tween()
		tw.tween_property(self, "_hub_old_t", 0.0, 0.22)
	hub_blk = blk_n
	hub_ghost = ghost
	hub_on = on
	queue_redraw()


func punch_hub() -> void:
	hub_flash = 1.0
	var tw := create_tween()
	tw.tween_property(self, "hub_flash", 0.0, 0.28)


func play_slay(index: int) -> void:
	busy = true
	slay_kind = "slay"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.55)
	await tw.finished


func play_block(index: int) -> void:
	busy = true
	slay_kind = "block"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.5)
	await tw.finished


func collapse_slice(index: int, pin: int = -1) -> void:
	busy = true
	slay_index = index
	collapse = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_IN)
	if pin >= 0 and pin != index:
		tw.tween_method(
			func(v: float) -> void:
				collapse = v
				rot = rot_to_center(pin)
				queue_redraw(),
			0.0,
			1.0,
			0.48
		)
	else:
		tw.tween_property(self, "collapse", 1.0, 0.48)
	await tw.finished
	if pin >= 0 and pin != index:
		rot = rot_to_center(pin)
	else:
		var base: float = rot
		var jostle := create_tween()
		jostle.tween_property(self, "rot", base + 0.055, 0.07)
		jostle.tween_property(self, "rot", base - 0.035, 0.08)
		jostle.tween_property(self, "rot", base, 0.08)
		await jostle.finished
	busy = false
	slay_index = -1
	slay_kind = "slay"
	collapse = 0.0
	slay_t = 0.0
	queue_redraw()


func pulse_arrive(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_lift[index] = 1.25
	queue_redraw()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_method(
		func(v: float) -> void:
			_lift[index] = v
			queue_redraw(),
		1.25,
		0.0,
		0.42
	)


func flash_slice(index: int) -> void:
	if index < 0:
		return
	_flash[index] = 1.0
	queue_redraw()


func hit_feedback(index: int, hp_lost: int, atk_delta: int = 0) -> void:
	if index < 0 or index >= slices.size():
		return
	_flash[index] = 0.5
	var pos: Vector2 = _hp_pos(index)
	if hp_lost > 0:
		_floaters.append({"pos": pos, "text": "-%s" % hp_lost, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	if atk_delta < 0:
		_floaters.append({"pos": _atk_pos(index), "text": "%s" % atk_delta, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	elif atk_delta > 0:
		_floaters.append({"pos": _atk_pos(index), "text": "+%s" % atk_delta, "col": UP_COL, "t": 0.0, "life": 0.9})
	queue_redraw()


func rotation_for_index(index: int) -> float:
	var n: int = _n()
	var ang: float = TAU / float(n)
	return PI - float(index) * ang


func rot_to_center(index: int) -> float:
	if index < 0 or index >= slices.size():
		return rot
	var acc: float = _span(index) * 0.5
	for i in index:
		acc += _span(i)
	return PI + _span(0) * 0.5 - acc


func recenter_on(index: int, dur: float = 0.28) -> void:
	if index < 0 or index >= slices.size():
		return
	var target: float = rotation_for_index(index)
	var delta: float = fposmod(target - rot + PI, TAU) - PI
	if absf(delta) < 0.01:
		rot = fposmod(target, TAU)
		return
	busy = true
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rot", rot + delta, dur)
	await tw.finished
	rot = fposmod(rot, TAU)
	busy = false
	queue_redraw()


func spin_to(index: int) -> void:
	if _spin_tween != null:
		_spin_tween.kill()
	spinning = true
	facing_index = -1
	hover_index = -1
	preview.clear()
	queue_redraw()
	var target: float = rotation_for_index(index)
	var delta: float = fposmod(target - rot, TAU)
	if delta < 0.45:
		delta += TAU
	delta += TAU
	var dur: float = clampf(1.6 + absf(delta) / TAU * 0.4, 1.6, 2.4)
	streak_a = 0.70
	_spin_tween = create_tween()
	_spin_tween.set_trans(Tween.TRANS_QUART)
	_spin_tween.set_ease(Tween.EASE_OUT)
	_spin_tween.tween_property(self, "rot", rot + delta, dur)
	_spin_tween.parallel().tween_property(self, "streak_a", 0.0, 0.40).set_delay(maxf(0.0, dur - 0.40))
	await _spin_tween.finished
	rot = fposmod(rot, TAU)
	spinning = false
	facing_index = index
	_land_shake()
	_play_threat()
	queue_redraw()


func kill_spin() -> void:
	if _spin_tween != null:
		_spin_tween.kill()
		_spin_tween = null
	spinning = false


func _n() -> int:
	return maxi(slices.size(), 1)


func _center() -> Vector2:
	return size * 0.5


func _play_threat() -> void:
	if _threat_tween != null:
		_threat_tween.kill()
	threat_t = 0.0
	_threat_tween = create_tween()
	_threat_tween.tween_property(self, "threat_t", 1.0, 0.72).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _radius() -> float:
	return OUTER_R


func shake_seat(index: int) -> void:
	if index < 0:
		return
	_refuse_nudge[index] = Vector2(6, 0)
	queue_redraw()
	var tw := create_tween()
	tw.tween_method(
		func(v: Vector2) -> void:
			_refuse_nudge[index] = v
			queue_redraw(),
		Vector2(6, 0),
		Vector2.ZERO,
		0.12
	)
	tw.finished.connect(func() -> void:
		_refuse_nudge.erase(index)
		queue_redraw()
	)


func _land_shake() -> void:
	_seat_nudge = Vector2(6, 0)
	var tw := create_tween()
	tw.tween_property(self, "_seat_nudge", Vector2(-6, 0), 0.04)
	tw.tween_property(self, "_seat_nudge", Vector2(6, 0), 0.04)
	tw.tween_property(self, "_seat_nudge", Vector2.ZERO, 0.04)
	tw.finished.connect(func() -> void: queue_redraw())


func _build_alcoves() -> void:
	_tex_alcove_empty = load("res://assets/ui/wheel/ui_wheel_alcove_empty.png") as Texture2D
	_tex_alcove_full = load("res://assets/ui/wheel/ui_wheel_alcove_full.png") as Texture2D
	_tex_alcove_facing = load("res://assets/ui/wheel/ui_wheel_alcove_facing.png") as Texture2D
	_tex_alcove_hover = load("res://assets/ui/wheel/ui_wheel_alcove_hover.png") as Texture2D
	_tex_alcove_valid = load("res://assets/ui/wheel/ui_wheel_alcove_valid.png") as Texture2D
	_tex_alcove_full_weak = load("res://assets/ui/wheel/ui_wheel_alcove_full_weak.png") as Texture2D
	_tex_alcove_full_tough = load("res://assets/ui/wheel/ui_wheel_alcove_full_tough.png") as Texture2D
	_tex_alcove_full_deadly = load("res://assets/ui/wheel/ui_wheel_alcove_full_deadly.png") as Texture2D
	if _tex_alcove_empty == null or _tex_alcove_full == null:
		_use_alcove_tex = false
		return
	_alcove_root = Node2D.new()
	_alcove_root.name = "AlcoveRoot"
	_alcove_root.show_behind_parent = true
	_alcove_root.z_index = -1
	add_child(_alcove_root)
	_alcoves.clear()
	for i in 8:
		var tr := TextureRect.new()
		tr.name = "Alcove%s" % i
		tr.texture_filter = TEXTURE_FILTER_NEAREST
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.position = Vector2(-116, -300)
		tr.pivot_offset = Vector2(116, 300)
		tr.size = Vector2(232, 248)
		tr.custom_minimum_size = Vector2(232, 248)
		tr.rotation_degrees = 45.0 * float(i)
		tr.show_behind_parent = true
		tr.texture = _tex_alcove_empty
		_alcove_root.add_child(tr)
		_alcoves.append(tr)
	_sync_alcoves()


func _alcove_tex_for(i: int) -> Texture2D:
	if i < 0 or i >= slices.size():
		return _tex_alcove_empty
	var s: Dictionary = slices[i]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = seat_hover_on and i == hover_index and not spinning
	if highlight == "place" and str(s.get("kind", "")) != "monster":
		if is_hover:
			return _tex_alcove_hover
		return _tex_alcove_valid
	if str(s.get("kind", "")) == "monster":
		var t: int = _plate_tier(s)
		if t >= 3 and _tex_alcove_full_deadly != null:
			return _tex_alcove_full_deadly
		if t == 2 and _tex_alcove_full_tough != null:
			return _tex_alcove_full_tough
		if _tex_alcove_full_weak != null:
			return _tex_alcove_full_weak
		return _tex_alcove_full
	if is_hover:
		return _tex_alcove_hover
	return _tex_alcove_empty


func _sync_alcoves() -> void:
	if _alcove_root == null:
		return
	_use_alcove_tex = _tex_alcove_empty != null and slices.size() == 8
	_alcove_root.visible = _use_alcove_tex and not nest_empty
	_alcove_root.position = _center()
	_alcove_root.rotation = rot
	var pulse: float = 0.72 + 0.28 * sin(_glow_t * TAU / 0.9)
	for i in _alcoves.size():
		var tr: TextureRect = _alcoves[i]
		tr.texture = _alcove_tex_for(i)
		tr.visible = _use_alcove_tex and not nest_empty
		var a := 1.0
		if dim_nonfacing and facing_index >= 0 and i != facing_index and not spinning:
			a = 0.45
		if highlight == "place" and i < slices.size() and str(slices[i].get("kind", "")) != "monster":
			a *= pulse
		var tint := Color.WHITE
		if i < slices.size() and str(slices[i].get("kind", "")) == "monster":
			if (not spinning) and i == facing_index:
				tint = tint.lightened(0.10)
		tr.modulate = Color(tint.r, tint.g, tint.b, a)


func _process(delta: float) -> void:
	_glow_t += delta
	_sync_alcoves()
	for i in slices.size():
		var want: float = 0.0
		if not spinning:
			if i == hover_index:
				want = 0.7
			elif i == facing_index:
				want = 0.12
		var cur: float = float(_lift.get(i, 0.0))
		var nxt: float = lerpf(cur, want, clampf(delta * 10.0, 0.0, 1.0))
		if absf(nxt - cur) > 0.002:
			_lift[i] = nxt
		else:
			_lift[i] = want
	var keep: Array = []
	for f in _floaters:
		f["t"] = float(f["t"]) + delta
		if float(f["t"]) < float(f["life"]):
			keep.append(f)
	_floaters = keep
	var gkeep: Array = []
	for g in _pt_ghosts:
		g["t"] = float(g["t"]) + delta
		if float(g["t"]) < float(g["life"]):
			gkeep.append(g)
	_pt_ghosts = gkeep
	var flash_keep := {}
	for k in _flash.keys():
		var t: float = float(_flash[k]) - delta
		if t > 0.0:
			flash_keep[k] = t
	_flash = flash_keep
	queue_redraw()


func slice_at(local: Vector2) -> int:
	if slices.is_empty() or spinning or busy:
		return -1
	var c: Vector2 = _center()
	var v: Vector2 = local - c
	var radius: float = _radius()
	var d: float = v.length()
	if d < HUB_R or d > radius + 12.0:
		return -1
	var a: float = fposmod(v.angle() - rot, TAU)
	var starts: PackedFloat32Array = _starts()
	var n: int = slices.size()
	for i in n:
		var a0: float = fposmod(starts[i] - rot, TAU)
		var a1: float = a0 + _span(i)
		if a >= a0 and a < a1:
			return i
		if a1 > TAU and a < a1 - TAU:
			return i
	return clampi(int(a / (TAU / float(n))), 0, n - 1)


func _gui_input(event: InputEvent) -> void:
	if spinning or busy:
		return
	if event is InputEventMouseMotion:
		var i: int = slice_at(event.position)
		if i != hover_index:
			hover_index = i
			slice_hovered.emit(i)
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		var i2: int = slice_at(event.position)
		if i2 < 0:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			slice_clicked.emit(i2)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slice_right_clicked.emit(i2)


func _on_mouse_out() -> void:
	if hover_index != -1:
		hover_index = -1
		slice_hovered.emit(-1)
		queue_redraw()


func _lift_of(i: int) -> float:
	return float(_lift.get(i, 0.0))


func _weight(i: int) -> float:
	if i == slay_index:
		return maxf(1.0 - collapse, 0.02)
	return 1.0


func _span(i: int) -> float:
	var tot: float = 0.0
	for j in slices.size():
		tot += _weight(j)
	if tot <= 0.0:
		return TAU / float(_n())
	return TAU * _weight(i) / tot


func _starts() -> PackedFloat32Array:
	var n: int = slices.size()
	var s := PackedFloat32Array()
	s.resize(n)
	var a: float = rot - PI / 2.0
	if n > 0:
		a -= _span(0) * 0.5
	for i in n:
		s[i] = a
		a += _span(i)
	return s


func _dir_of(i: int) -> Vector2:
	var starts: PackedFloat32Array = _starts()
	if i < 0 or i >= starts.size():
		return Vector2.DOWN
	var mid: float = starts[i] + _span(i) * 0.5
	return Vector2.from_angle(mid)


func _bezel_pos(i: int) -> Vector2:
	return _hp_pos(i)


func _spoke(i: int) -> Dictionary:
	var c: Vector2 = _center()
	var dir: Vector2 = _dir_of(i)
	var tan: Vector2 = Vector2(-dir.y, dir.x)
	var lift: float = _lift_of(i)
	var is_face: bool = (not spinning) and i == facing_index
	var origin: Vector2 = c + dir * (lift * 8.0) + _slay_push(i)
	if is_face:
		origin += _seat_nudge
	if _refuse_nudge.has(i):
		origin += _refuse_nudge[i]
	var r: float = _radius() + lift * 12.0
	var n: int = maxi(slices.size(), 1)
	var crowded: bool = n >= 9
	var win: float = SPRITE
	var plate_r: float = SPRITE * 0.5
	var seat: Vector2 = origin + dir * SEAT_R
	var s: Dictionary = slices[i] if i >= 0 and i < slices.size() else {}
	var cap: Dictionary = _capsule_metrics(s, crowded)
	var cap_h: float = float(cap.get("h", 22.0))
	var cap_w: float = float(cap.get("w", 64.0))
	var occupied: bool = str(s.get("kind", "")) == "monster"
	var stack_h: float = SPRITE if not occupied else (SPRITE + 6.0 + cap_h)
	var sprite_top: float = seat.y - stack_h * 0.5
	var heart_hw := 12.0
	var sword_hw := 15.0
	var sprite_left: float = seat.x - SPRITE * 0.5
	var sprite_right: float = seat.x + SPRITE * 0.5
	var hp: Vector2 = Vector2(sprite_left - 2.0 - heart_hw, sprite_top + 30.0)
	var atk: Vector2 = Vector2(sprite_right + 2.0 + sword_hw, sprite_top + 30.0)
	var port: Vector2 = Vector2(seat.x, sprite_top + SPRITE * 0.5)
	var nam: Vector2 = Vector2(seat.x, sprite_top + SPRITE + 6.0 + cap_h * 0.5)
	if occupied:
		var left: float = minf(hp.x - heart_hw, minf(sprite_left, nam.x - cap_w * 0.5))
		var right: float = maxf(atk.x + sword_hw, maxf(sprite_right, nam.x + cap_w * 0.5))
		var top: float = sprite_top
		var bot: float = sprite_top + stack_h
		var mid := Vector2((left + right) * 0.5, (top + bot) * 0.5)
		var fitted: Vector2 = _fit_stack_mid(mid, right - left, bot - top, dir)
		var delta: Vector2 = fitted - mid
		hp += delta
		atk += delta
		port += delta
		nam += delta
		seat += delta
	return {
		"c": c,
		"dir": dir,
		"tan": tan,
		"origin": origin,
		"r": r,
		"win": win,
		"plate_r": plate_r,
		"port": port,
		"seat": seat,
		"name": nam,
		"atk": atk,
		"hp": hp,
		"span": _span(i),
		"cap_w": cap_w,
		"cap_h": cap_h,
		"crowded": crowded,
	}


func slice_portrait_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	var local: Vector2 = _spoke(i)["port"]
	return get_global_transform() * local


func slice_focus_proxy(i: int, slot: String = "A") -> Control:
	var node_name: String = "SliceFocus%s" % slot
	if get_node_or_null(node_name) == null:
		var hole := Control.new()
		hole.name = node_name
		hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hole)
	var proxy: Control = get_node(node_name) as Control
	if i < 0 or i >= slices.size():
		proxy.size = Vector2.ZERO
		return proxy
	var port: Vector2 = slice_portrait_global(i)
	proxy.size = Vector2(88, 88)
	proxy.global_position = port - proxy.size * 0.5
	return proxy


func slice_stat_proxy(i: int, kind: String) -> Control:
	var node_name: String = "SliceStat%s" % kind
	if get_node_or_null(node_name) == null:
		var hole := Control.new()
		hole.name = node_name
		hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hole)
	var proxy: Control = get_node(node_name) as Control
	if i < 0 or i >= slices.size():
		proxy.size = Vector2.ZERO
		return proxy
	var local: Vector2 = _atk_pos(i) if kind == "atk" else _hp_pos(i)
	var port: Vector2 = get_global_transform() * local
	proxy.size = Vector2(52, 52)
	proxy.global_position = port - proxy.size * 0.5
	return proxy


func hub_stat_proxy(kind: String) -> Control:
	var node_name: String = "HubFocus%s" % kind
	if get_node_or_null(node_name) == null:
		var hole := Control.new()
		hole.name = node_name
		hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(hole)
	var proxy: Control = get_node(node_name) as Control
	var c: Vector2 = _center()
	var local: Vector2 = c + Vector2(0.0, -HUB_R * 0.72)
	if kind == "blk":
		local = c + Vector2(0.0, HUB_R * 0.50)
	var port: Vector2 = get_global_transform() * local
	proxy.size = Vector2(56, 56)
	proxy.global_position = port - proxy.size * 0.5
	return proxy


func _atk_pos(i: int) -> Vector2:
	return _spoke(i)["atk"]


func _hp_pos(i: int) -> Vector2:
	return _spoke(i)["hp"]


func _clamp_to_rim(pos: Vector2, icon_r: float) -> Vector2:
	var c: Vector2 = _center()
	var maxd: float = _radius() - icon_r - 8.0
	var d: Vector2 = pos - c
	if d.length() <= maxd or d.length() < 1.0:
		return pos
	return c + d.normalized() * maxd


func _slay_push(i: int) -> Vector2:
	if i != slay_index or collapse <= 0.0:
		return Vector2.ZERO
	return _dir_of(i) * collapse * _radius() * 0.42


func _draw() -> void:
	var c: Vector2 = _center()
	var radius: float = _radius()
	if not _use_alcove_tex:
		draw_circle(c, radius, DISC)
	draw_arc(c, 306.0, 0.0, TAU, 80, RING, 8.0, true)
	if slices.is_empty():
		draw_circle(c, HUB_R, HUB)
		draw_arc(c, HUB_R, 0.0, TAU, 48, RING, 5.0, true)
		_sync_alcoves()
		return
	var n: int = slices.size()
	var starts: PackedFloat32Array = _starts()
	if nest_empty:
		draw_circle(c, radius, DISC)
		for i in 8:
			var ang: float = deg_to_rad(-90.0 + 45.0 * float(i))
			draw_line(c + Vector2.from_angle(ang) * HUB_R, c + Vector2.from_angle(ang) * radius, RING, 4.0, true)
		draw_circle(c, HUB_R, HUB)
		draw_arc(c, HUB_R, 0.0, TAU, 48, RING, 5.0, true)
		_sync_alcoves()
		return
	var font: Font = _font_nx if _font_nx != null else get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	for i in n:
		_draw_slice(c, radius, starts[i], starts[i] + _span(i), i)
	draw_circle(c, HUB_R, HUB)
	draw_arc(c, HUB_R, 0.0, TAU, 48, RING, 5.0, true)
	for i2 in n:
		_draw_slice_contents(font, c, radius, starts[i2], _span(i2), i2)
	_draw_bonds(c, radius)
	_draw_seat_fx(font)
	_draw_hub_block(c, radius)
	_draw_streaks(c)
	_draw_threat(c, radius)
	_draw_tut_wedges(c, radius)
	_draw_floaters(font)
	if slay_index >= 0 and slay_t > 0.0:
		_draw_slay(font, c, radius)


func _draw_tut_wedges(c: Vector2, radius: float) -> void:
	if tut_wedges.is_empty() or slices.is_empty():
		return
	var starts: PackedFloat32Array = _starts()
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 5.5)
	var inner: float = HUB_R
	for idx in tut_wedges:
		var i: int = int(idx)
		if i < 0 or i >= starts.size():
			continue
		var a0: float = starts[i]
		var a1: float = a0 + _span(i)
		var fill := PackedVector2Array()
		var steps: int = 12
		for s in range(steps + 1):
			var a: float = lerpf(a0, a1, float(s) / float(steps))
			fill.append(c + Vector2.from_angle(a) * radius)
		for s in range(steps, -1, -1):
			var a2: float = lerpf(a0, a1, float(s) / float(steps))
			fill.append(c + Vector2.from_angle(a2) * inner)
		draw_colored_polygon(fill, Color(0.91, 0.76, 0.42, 0.12 + 0.16 * pulse))
		var rim := PackedVector2Array()
		rim.append(c + Vector2.from_angle(a0) * inner)
		rim.append(c + Vector2.from_angle(a0) * radius)
		for s2 in range(steps + 1):
			var a3: float = lerpf(a0, a1, float(s2) / float(steps))
			rim.append(c + Vector2.from_angle(a3) * radius)
		rim.append(c + Vector2.from_angle(a1) * inner)
		for s3 in range(steps, -1, -1):
			var a4: float = lerpf(a0, a1, float(s3) / float(steps))
			rim.append(c + Vector2.from_angle(a4) * inner)
		draw_polyline(rim, Color(1.0, 0.86, 0.38, 0.5 + 0.5 * pulse), 4.0 + 2.0 * pulse, true)


func _draw_pointer(_c: Vector2, _radius: float) -> void:
	pass


func _draw_alcove_poly(i: int) -> void:
	var s: Dictionary = slices[i]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = seat_hover_on and i == hover_index and not spinning
	var fill: Color = EMPTY_FILL
	var rim: Color = RING
	var dashed := true
	if highlight == "place" and str(s.get("kind", "")) != "monster":
		fill = Color("2A1C10")
		dashed = true
		if is_hover:
			fill = HOVER_FILL
			rim = FACE_RIM
			dashed = false
	elif str(s.get("kind", "")) == "monster":
		fill = SEAT_WOOD
		dashed = false
		if is_face:
			fill = RING
			rim = FACE_RIM
		elif is_hover:
			fill = HOVER_FILL
			rim = FACE_RIM
	elif is_hover:
		fill = HOVER_FILL
		rim = FACE_RIM
		dashed = false
	if _flash.has(i):
		fill = fill.lerp(DOWN_COL, clampf(float(_flash[i]) * 1.4, 0.0, 0.55))
	var starts: PackedFloat32Array = _starts()
	if i < 0 or i >= starts.size():
		return
	var a0: float = starts[i]
	var a1: float = a0 + _span(i)
	var c: Vector2 = _center()
	var pts := PackedVector2Array()
	var steps := 10
	for k in range(steps + 1):
		var a: float = lerpf(a0, a1, float(k) / float(steps))
		pts.append(c + Vector2.from_angle(a) * OUTER_R)
	for k in range(steps, -1, -1):
		var a2: float = lerpf(a0, a1, float(k) / float(steps))
		pts.append(c + Vector2.from_angle(a2) * HUB_R)
	if pts.size() >= 3:
		draw_colored_polygon(pts, fill)
	if dashed:
		_draw_dashed_arc(c, OUTER_R - 2.0, a0, a1, rim, 4.0)
	else:
		draw_arc(c, OUTER_R - 2.0, a0, a1, 16, rim, 4.0, false)
		draw_line(c + Vector2.from_angle(a0) * HUB_R, c + Vector2.from_angle(a0) * OUTER_R, rim, 3.0, false)
		draw_line(c + Vector2.from_angle(a1) * HUB_R, c + Vector2.from_angle(a1) * OUTER_R, rim, 3.0, false)


func _draw_streaks(c: Vector2) -> void:
	if streak_a <= 0.02:
		return
	var col := Color(1.0, 0.847, 0.29, streak_a)
	for k in 4:
		var a0: float = rot + float(k) * TAU * 0.25
		_draw_dashed_arc(c, 324.0, a0, a0 + 0.72, col, 6.0)


func _draw_dashed_arc(c: Vector2, r: float, a0: float, a1: float, col: Color, width: float) -> void:
	var steps := 18
	var dash := true
	for k in steps:
		var t0: float = lerpf(a0, a1, float(k) / float(steps))
		var t1: float = lerpf(a0, a1, float(k + 1) / float(steps))
		if dash:
			draw_line(c + Vector2.from_angle(t0) * r, c + Vector2.from_angle(t1) * r, col, width, false)
		dash = not dash


func _fill_for(s: Dictionary, is_face: bool, is_hover: bool) -> Color:
	if str(s.get("kind", "")) != "monster":
		if highlight == "place":
			return Color("1a2a1a")
		if highlight == "bribe":
			return Color("2a1c14")
		return EMPTY_FILL
	var fill: Color = UX.metal_wedge(_plate_tier(s))
	if is_face:
		fill = fill.lightened(0.14)
	elif is_hover:
		fill = fill.lightened(0.08)
	elif facing_index >= 0 and (not spinning) and str(s.get("kind", "")) == "monster":
		fill = fill.darkened(0.16)
	if bool(s.get("poisoned", false)):
		fill = fill.lerp(Color("2e4a32"), 0.55)
	if bool(s.get("crossbowed", false)):
		fill = fill.lerp(Color("5a4a18"), 0.45)
	if bool(s.get("rage_fire", false)):
		fill = fill.lerp(Color("c44a18"), 0.55)
	if bool(s.get("fled_once", false)):
		fill = fill.lerp(Color("8a7a4a"), 0.35)
	if highlight == "mark" and bool(s.get("markable", false)):
		fill = fill.lightened(0.16)
	return fill


func _draw_wedge(origin: Vector2, r: float, a0: float, a1: float, fill: Color) -> void:
	var span: float = a1 - a0
	if r < 1.0 or fill.a <= 0.001 or absf(span) < 0.001:
		return
	if absf(span) >= TAU - 0.02:
		draw_circle(origin, r, fill)
		return
	var steps: int = clampi(int(ceili(absf(span) / 0.14)), 8, 48)
	var prev: Vector2 = origin + Vector2.from_angle(a0) * r
	for k in range(1, steps + 1):
		var nxt: Vector2 = origin + Vector2.from_angle(lerpf(a0, a1, float(k) / float(steps))) * r
		if absf((prev - origin).cross(nxt - origin)) < 0.5:
			prev = nxt
			continue
		draw_colored_polygon(PackedVector2Array([origin, prev, nxt]), fill)
		prev = nxt


func _draw_slice(c: Vector2, radius: float, a0: float, a1: float, i: int) -> void:
	var s: Dictionary = slices[i]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = i == hover_index
	var lift: float = _lift_of(i)
	var dir: Vector2 = Vector2.from_angle((a0 + a1) * 0.5)
	var origin: Vector2 = c + dir * (lift * 8.0) + _slay_push(i)
	var r: float = radius + lift * 12.0
	var fill: Color = _fill_for(s, is_face, is_hover)
	if _flash.has(i):
		fill = fill.lerp(DOWN_COL, clampf(float(_flash[i]) * 1.4, 0.0, 0.55))
	if i == slay_index and collapse > 0.0:
		fill.a *= 1.0 - collapse * 0.85
	if _use_alcove_tex:
		var wash: Color = fill
		wash.a = 0.32
		_draw_wedge(origin, r, a0, a1, wash)
	else:
		_draw_wedge(origin, r, a0, a1, fill)
	var rim: Color = Color("2a241e")
	var rw: float = 1.4
	if highlight == "place" and str(s.get("kind", "")) == "empty":
		if int(seat_fx.get("from", -1)) == i:
			rim = FACE_RIM
			rw = 5.5
		else:
			rim = PLACE_RIM
			rw = 2.5
	elif highlight == "bribe" and is_hover:
		rim = BRIBE_RIM
		rw = 3.0
	elif highlight == "mark" and bool(s.get("markable", false)):
		rim = Color("8dcb8d")
		rw = 3.2
	elif str(s.get("kind", "")) == "monster":
		var t: int = _plate_tier(s)
		rim = UX.metal(t)
		rw = 3.2 if t <= 1 else (4.0 if t == 2 else 4.8)
		var lip := Color(rim.r, rim.g, rim.b, 0.42 if is_face else 0.32)
		draw_arc(origin, r * 0.978, a0, a1, 28, lip, 10.0 if t >= 3 else 8.0, true)
		if is_face:
			rim = rim.lightened(0.22)
			rw += 1.6
		elif is_hover:
			rim = rim.lightened(0.14)
			rw += 0.8
	elif is_face:
		rim = FACE_RIM
		rw = 5.2
	elif is_hover:
		rim = Color("f0e6d8")
		rw = 2.4
	draw_arc(origin, r, a0, a1, 26, rim, rw, true)


func _draw_slice_contents(font: Font, c: Vector2, radius: float, a0: float, ang: float, i: int) -> void:
	var s: Dictionary = slices[i]
	var sp: Dictionary = _spoke(i)
	var dir: Vector2 = sp["dir"]
	var origin: Vector2 = sp["origin"]
	var r: float = sp["r"]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = i == hover_index
	var dim: float = 1.0
	if facing_index >= 0 and not spinning and not is_face and not is_hover:
		dim = 0.70
	if str(s.get("kind", "")) != "monster":
		_draw_empty_seat(font, sp, i)
		return
	var pv: Dictionary = preview.get(i, preview.get(str(i), {}))
	if typeof(pv) != TYPE_DICTIONARY:
		pv = {}
	var crowded: bool = slices.size() >= 9
	var pid: String = str(s.get("card_id", ""))
	var port_pos: Vector2 = sp["port"]
	var plate_r: float = float(sp.get("plate_r", 36.0))
	var sprite_r := Rect2(port_pos - Vector2(SPRITE, SPRITE) * 0.5, Vector2(SPRITE, SPRITE))
	if tex_portraits.has(pid):
		var face_c: bool = port_pos.x >= _center().x
		if face_c:
			draw_set_transform(port_pos, 0.0, Vector2(-1, 1))
			draw_texture_rect(tex_portraits[pid], Rect2(Vector2(-SPRITE, -SPRITE) * 0.5, Vector2(SPRITE, SPRITE)), false, Color(dim, dim, dim, dim))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture_rect(tex_portraits[pid], sprite_r, false, Color(dim, dim, dim, dim))
	_draw_slice_title(font, sp, s, is_face, crowded, dim, is_hover)
	_draw_tier_num(font, port_pos - dir * (plate_r + 12.0), s, is_face, crowded)
	var sid: String = str(s.get("special_id", ""))
	if sid != "" and tex_special.has(sid) and not tex_portraits.has(pid):
		var st: Texture2D = tex_special[sid]
		draw_texture_rect(st, Rect2(port_pos - Vector2(9, 9), Vector2(18, 18)), false, Color(dim, dim, dim, dim))
	var big: bool = is_face or _lift_of(i) > 0.45 or is_hover
	_draw_heart_stat(font, sp["hp"], s, pv, big, i)
	_draw_atk_stat(font, sp["atk"], s, pv, big, i)
	if bool(s.get("poisoned", false)):
		draw_circle(sp["hp"] + Vector2(12, -10), 4.0, Color("7dba7d"))
	var would_die: bool = int(s.get("hp", 0)) + int(pv.get("hp", 0)) <= 0 and int(pv.get("hp", 0)) < 0
	if would_die or bool(pv.get("kill", false)):
		var xa: float = 0.55 + 0.25 * sin(float(Time.get_ticks_msec()) * 0.012)
		var xc := Color(DOWN_COL.r, DOWN_COL.g, DOWN_COL.b, xa)
		var arm: float = 22.0
		draw_line(port_pos + Vector2(-arm, -arm), port_pos + Vector2(arm, arm), xc, 4.0, true)
		draw_line(port_pos + Vector2(arm, -arm), port_pos + Vector2(-arm, arm), xc, 4.0, true)


func _plate_tier(s: Dictionary) -> int:
	var t: int = int(s.get("pack_tier", 0))
	if t < 1:
		t = int(s.get("tier", 1))
	return t


func _plate_pts(center: Vector2, rad: float, _tier: int = 1) -> PackedVector2Array:
	return UX.round_plate(center, rad)


func _draw_tier_plate(center: Vector2, rad: float, s: Dictionary) -> void:
	var t: int = _plate_tier(s)
	draw_colored_polygon(_plate_pts(center, rad, t), UX.metal_well(t))


func _draw_tier_num(_font: Font, _pos: Vector2, _s: Dictionary, _is_face: bool, _crowded: bool) -> void:
	pass


func _draw_tier_rim(center: Vector2, rad: float, s: Dictionary) -> void:
	var t: int = _plate_tier(s)
	var col: Color = UX.metal(t)
	var w: float = 2.8 if t <= 1 else (3.2 if t == 2 else 3.6)
	var pts: PackedVector2Array = _plate_pts(center, rad, t)
	pts.append(pts[0])
	draw_polyline(pts, col, w, true)


func _draw_portrait_window(center: Vector2, rad: float, s: Dictionary, tex: Texture2D, face_ang: float, dim: float = 1.0) -> void:
	var pts: PackedVector2Array = _plate_pts(center, rad, _plate_tier(s))
	if pts.size() < 3:
		return
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var zoom: float = rad * 2.1
	for p in pts:
		var local: Vector2 = (p - center) / zoom
		uvs.append(Vector2(0.5, 0.5) + local.rotated(-face_ang))
		cols.append(Color(dim, dim, dim, 1.0))
	draw_polygon(pts, cols, uvs, tex)


func _draw_outlined_string(font: Font, pos: Vector2, text: String, fs: int, col: Color, outline: Color) -> void:
	var tsz: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = pos + Vector2(-tsz.x * 0.5, 0.0)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _edge_angle_between(i: int, j: int) -> float:
	var n: int = slices.size()
	var starts: PackedFloat32Array = _starts()
	if n == 0 or i < 0 or j < 0:
		return 0.0
	if j == (i + 1) % n:
		return starts[j]
	return starts[i]


func _seat_delta(index: int, stat: String) -> int:
	if seat_fx.is_empty() or index < 0:
		return 0
	if int(seat_fx.get("from", -1)) == index:
		return int(seat_fx.get("self", {}).get(stat + "_d", 0))
	var links: Variant = seat_fx.get("links", [])
	if typeof(links) != TYPE_ARRAY:
		return 0
	for link in links:
		if typeof(link) != TYPE_DICTIONARY:
			continue
		if int(link.get("to", -1)) == index and str(link.get("stat", "")) == stat:
			return int(link.get("delta", 0))
	return 0


func _seat_tag(index: int, stat: String) -> String:
	if seat_fx.is_empty() or index < 0:
		return ""
	var links: Variant = seat_fx.get("links", [])
	if typeof(links) != TYPE_ARRAY:
		return ""
	for link in links:
		if typeof(link) != TYPE_DICTIONARY:
			continue
		if int(link.get("to", -1)) == index and str(link.get("stat", "")) == stat:
			return str(link.get("tag", ""))
	return ""


func _draw_empty_seat(font: Font, sp: Dictionary, i: int) -> void:
	var origin: Vector2 = sp["origin"]
	var dir: Vector2 = sp["dir"]
	var r: float = sp["r"]
	var ghosting: bool = int(seat_fx.get("from", -1)) == i and not seat_fx.is_empty()
	if highlight == "place" and not ghosting:
		var p: Vector2 = origin + dir * SEAT_R
		var plus_font: Font = _font_sk if _font_sk != null else font
		_draw_outlined_string(plus_font, p + Vector2(0, 10), "+", 30, FACE_RIM, Color("1A120E"))
	if not ghosting:
		return
	var sl: Dictionary = seat_fx.get("self", {})
	if typeof(sl) != TYPE_DICTIONARY:
		sl = {}
	var pid: String = str(sl.get("id", ""))
	var port_pos: Vector2 = sp["port"]
	var plate_r: float = float(sp.get("plate_r", 36.0))
	var pulse: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.008)
	var ghost := {
		"kind": "monster",
		"card_id": pid,
		"name": str(sl.get("name", "")),
		"hp": int(sl.get("hp", 0)),
		"atk": int(sl.get("atk", 0)),
		"pack_tier": int(sl.get("pack_tier", 1)),
		"lich_buff": int(sl.get("hp_d", 0)) > 0,
		"cmd_buff": int(sl.get("atk_d", 0)) > 0,
		"copy_from": int(sl.get("copy_from", -1)),
	}
	var dim: float = 0.62 + 0.28 * pulse
	_draw_tier_plate(port_pos, plate_r, ghost)
	var tex: Texture2D = tex_portraits.get(pid, tex_by_id.get(pid, null)) as Texture2D
	if tex != null:
		_draw_portrait_window(port_pos, plate_r, ghost, tex, 0.0, dim)
	_draw_tier_rim(port_pos, plate_r, ghost)
	draw_arc(port_pos, plate_r + 8.0 + 4.0 * pulse, 0.0, TAU, 32, Color(1.0, 0.92, 0.45, 0.35 + 0.45 * pulse), 3.4, true)
	var pv := {"hp": int(sl.get("hp_d", 0)), "atk": int(sl.get("atk_d", 0))}
	_draw_heart_stat(font, sp["hp"], ghost, pv, true, i)
	_draw_atk_stat(font, sp["atk"], ghost, pv, true, i)


func _draw_seat_fx(_font: Font) -> void:
	if seat_fx.is_empty():
		return
	var from_i: int = int(seat_fx.get("from", -1))
	if from_i < 0 or from_i >= slices.size():
		return
	var links: Variant = seat_fx.get("links", [])
	if typeof(links) != TYPE_ARRAY or links.is_empty():
		return
	var origin: Vector2 = _spoke(from_i)["port"]
	var pulse: float = 0.50 + 0.50 * sin(float(Time.get_ticks_msec()) * 0.009)
	var t: float = fmod(float(Time.get_ticks_msec()) * 0.0016, 1.0)
	for link in links:
		if typeof(link) != TYPE_DICTIONARY:
			continue
		var to_i: int = int(link.get("to", -1))
		if to_i < 0 or to_i >= slices.size():
			continue
		var stat: String = str(link.get("stat", "hp"))
		var dest: Vector2 = _spoke(to_i)["hp"] if stat == "hp" else _spoke(to_i)["atk"]
		var col: Color = Color(1.0, 0.92, 0.42, 0.92) if stat == "hp" else Color(1.0, 0.42, 0.22, 0.92)
		var start: Vector2 = origin
		var src_i: int = int(link.get("src", -1))
		if str(link.get("tag", "")) == "copy":
			col = Color(0.82, 0.48, 1.0, 0.95)
			if src_i >= 0 and src_i < slices.size():
				start = _spoke(src_i)["atk"]
		elif str(link.get("tag", "")) == "x2":
			col = Color(1.0, 0.84, 0.28, 0.95)
			if src_i >= 0 and src_i < slices.size():
				start = _spoke(src_i)["port"]
		if start.distance_to(dest) < 8.0:
			continue
		_draw_sight_beam(start, dest, col, pulse, t, 1.0)


func _draw_sight_beam(a: Vector2, b: Vector2, col: Color, pulse: float, t: float, strength: float = 1.0) -> void:
	var s: float = clampf(strength, 0.12, 1.0)
	var glow := Color(col.r, col.g, col.b, (0.10 + 0.16 * pulse) * s)
	var mid := Color(col.r, col.g, col.b, (0.28 + 0.32 * pulse) * s)
	var core := Color(1.0, 0.98, 0.88, (0.45 + 0.40 * pulse) * s)
	draw_line(a, b, glow, (6.0 + 10.0 * s) + 3.0 * pulse * s, true)
	draw_line(a, b, mid, 2.2 + 4.8 * s, true)
	draw_line(a, b, core, 1.0 + 1.4 * s, true)
	var dir: Vector2 = b - a
	var len: float = dir.length()
	if len < 4.0:
		return
	var nrm: Vector2 = dir / len
	var perp := Vector2(-nrm.y, nrm.x)
	if s > 0.55:
		for k in 3:
			var u: float = fmod(t + float(k) / 3.0, 1.0)
			var p: Vector2 = a.lerp(b, u)
			var spark_r: float = (3.0 + 5.0 * s) + 2.0 * pulse * s
			draw_circle(p, spark_r + 3.0, Color(col.r, col.g, col.b, 0.16 * s))
			draw_circle(p, spark_r, Color(1.0, 0.98, 0.86, 0.75 * s))
	var ah: float = 8.0 + 8.0 * s
	var aw: float = 5.0 + 4.0 * s
	var tip: Vector2 = b
	var left: Vector2 = b - nrm * ah + perp * aw
	var right: Vector2 = b - nrm * ah - perp * aw
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(col.r, col.g, col.b, 0.45 + 0.50 * s))
	if s > 0.4:
		draw_arc(b, 8.0 + 12.0 * s * pulse, 0.0, TAU, 24, Color(col.r, col.g, col.b, 0.22 + 0.38 * s), 2.0 + 1.6 * s, true)


func _draw_edge_ticks(i: int, j: int, col: Color) -> void:
	var c: Vector2 = _center()
	var radius: float = _radius()
	var ang: float = _edge_angle_between(i, j)
	var a: Vector2 = Vector2.from_angle(ang)
	draw_line(c + a * radius * HUB_FRAC, c + a * radius * 0.76, col, 3.2, true)


func _bond_strength(a: int, b: int) -> float:
	if hover_index == a or hover_index == b:
		return 0.86
	return 0.28


func _draw_bond_beam(from_i: int, to_i: int, from_slot: String, to_slot: String, col: Color, pulse: float, t: float) -> void:
	if from_i < 0 or to_i < 0 or from_i >= slices.size() or to_i >= slices.size():
		return
	var a: Vector2 = _spoke(from_i)[from_slot]
	var b: Vector2 = _spoke(to_i)[to_slot]
	if a.distance_to(b) < 8.0:
		return
	_draw_sight_beam(a, b, col, pulse, t, _bond_strength(from_i, to_i))


func _draw_bonds(_c: Vector2, _radius: float) -> void:
	var n: int = slices.size()
	if n == 0:
		return
	var pulse: float = 0.50 + 0.50 * sin(float(Time.get_ticks_msec()) * 0.006)
	var trav: float = fmod(float(Time.get_ticks_msec()) * 0.0016, 1.0)
	for i in n:
		var s: Dictionary = slices[i]
		if str(s.get("kind", "")) != "monster":
			continue
		var cid: String = str(s.get("card_id", ""))
		var sp: Dictionary = _spoke(i)
		if cid == "commander":
			var rc := Color(1.0, 0.42, 0.22, 1.0)
			for off in [n - 1, 1]:
				var j: int = (i + off) % n
				if str(slices[j].get("kind", "")) != "monster":
					continue
				if not bool(slices[j].get("cmd_buff", false)):
					continue
				_draw_bond_beam(i, j, "port", "atk", rc, pulse, trav)
		elif cid == "lich":
			var cream := Color(1.0, 0.92, 0.42, 1.0)
			for off2 in [n - 1, 1]:
				var j2: int = (i + off2) % n
				if str(slices[j2].get("kind", "")) != "monster":
					continue
				if not bool(slices[j2].get("lich_buff", false)):
					continue
				_draw_bond_beam(i, j2, "port", "hp", cream, pulse, trav)
		elif cid == "wraith":
			var src: int = int(s.get("copy_from", -1))
			if src >= 0 and src < n and str(slices[src].get("kind", "")) == "monster":
				var pur := Color(0.82, 0.48, 1.0, 1.0)
				_draw_bond_beam(src, i, "atk", "atk", pur, pulse, trav)
		elif cid == "slime_boss":
			var slime := Color(0.45, 0.82, 0.42, 0.85)
			var midp: Vector2 = (sp["atk"] + sp["hp"]) * 0.5
			var font: Font = get_theme_default_font()
			if font == null:
				font = ThemeDB.fallback_font
			_draw_outlined_string(font, midp + Vector2(0, 5), "=", UI.SIZE_MIN, slime, Color("1c120c"))


func _draw_bold_name(font: Font, pos: Vector2, text: String, fs: int, col: Color, wrap: float = 108.0) -> void:
	_draw_outlined_string(font, pos, text, fs, col, Color("100e0c"))


func _draw_slice_title(font: Font, sp: Dictionary, s: Dictionary, is_face: bool, _crowded: bool, dim: float = 1.0, _is_hover: bool = false) -> void:
	var crowded: bool = bool(sp.get("crowded", slices.size() >= 9))
	var met: Dictionary = _capsule_metrics(s, crowded)
	var name_txt: String = str(met.get("name_txt", ""))
	if name_txt == "":
		return
	var call_txt: String = str(met.get("call_txt", ""))
	var name_fs: int = int(met.get("name_fs", UI.SIZE_MIN))
	var call_fs: int = int(met.get("call_fs", UI.SIZE_MIN))
	if met.get("font") != null:
		font = met["font"]
	var name_sz: Vector2 = met.get("name_sz", Vector2.ZERO)
	var call_sz: Vector2 = met.get("call_sz", Vector2.ZERO)
	var pad_x: float = float(met.get("pad_x", 7.0))
	var pad_y: float = float(met.get("pad_y", 3.0))
	var gap: float = float(met.get("gap", 1.0))
	var w: float = float(met.get("w", 64.0))
	var h: float = float(met.get("h", 22.0))
	var inner_w: float = float(met.get("inner_w", w - pad_x * 2.0))
	var content_h: float = name_sz.y
	if call_txt != "":
		content_h += gap + call_sz.y
	var pos: Vector2 = sp["name"]
	var top_left := Vector2(pos.x - w * 0.5, pos.y - h * 0.5)
	var t: int = _plate_tier(s)
	var fill: Color = UX.metal_chip(t)
	fill.a = 0.92 * dim
	var edge: Color = UX.metal(t)
	if is_face:
		edge = edge.lightened(0.18)
	edge.a = dim
	var ew: float = 2.2 if t <= 1 else (2.6 if t == 2 else 3.0)
	if is_face:
		ew += 0.6
	_draw_capsule(Rect2(top_left, Vector2(w, h)), fill, edge, ew)
	var y: float = top_left.y + (h - content_h) * 0.5
	var ink := Color(0.06, 0.05, 0.04, dim)
	var name_col: Color = UX.metal_ink(t)
	if is_face:
		name_col = name_col.lightened(0.08)
	name_col.a = dim
	_draw_chip_line(font, Vector2(top_left.x + pad_x, y), name_txt, name_fs, inner_w, name_col, ink)
	y += name_sz.y + gap
	if call_txt != "":
		var col: Color = UX.metal_call(t)
		col.a = dim
		_draw_chip_line(font, Vector2(top_left.x + pad_x, y), call_txt, call_fs, inner_w, col, ink)


func _fit_title_rect(top_left: Vector2, w: float, h: float, dir: Vector2) -> Vector2:
	var mid: Vector2 = _fit_stack_mid(top_left + Vector2(w, h) * 0.5, w, h, dir)
	return mid - Vector2(w, h) * 0.5


func _fit_stack_mid(mid: Vector2, w: float, h: float, dir: Vector2) -> Vector2:
	var c: Vector2 = _center()
	var from_c: Vector2 = mid - c
	var half: float = maxf(w, h) * 0.5
	var maxd: float = _radius() - half - 8.0
	if from_c.length() > maxd and from_c.length() > 1.0:
		mid = c + from_c.normalized() * maxd
	var mind: float = HUB_R + half + 6.0
	if (mid - c).length() < mind:
		mid = c + dir * mind
	return mid


func _capsule_metrics(s: Dictionary, crowded: bool) -> Dictionary:
	var name_s: String = str(s.get("name", "")).strip_edges()
	var call_s: String = str(s.get("call_name", "")).strip_edges()
	if crowded:
		call_s = ""
	if call_s.to_lower() == name_s.to_lower() or (call_s != "" and name_s.to_lower().find(call_s.to_lower()) >= 0):
		call_s = ""
	var font: Font = _font_ns if _font_ns != null else (_font_nx if _font_nx != null else ThemeDB.fallback_font)
	var name_fs: int = UI.SIZE_MIN
	var call_fs: int = UI.SIZE_MIN
	var max_w := 112.0
	var name_txt: String = _wrap_call_label(font, name_s, name_fs, max_w) if font != null else name_s
	var call_txt: String = _wrap_call_label(font, call_s, call_fs, max_w) if call_s != "" and font != null else ""
	var name_sz: Vector2 = font.get_multiline_string_size(name_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, name_fs) if font != null else Vector2(64, 18)
	var call_sz: Vector2 = font.get_multiline_string_size(call_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, call_fs) if call_txt != "" and font != null else Vector2.ZERO
	var pad_x := 7.0
	var pad_y := 3.0
	var gap := 1.0
	var inner_w: float = maxf(name_sz.x, call_sz.x)
	var content_h: float = name_sz.y
	if call_txt != "":
		content_h += gap + call_sz.y
	var w: float = inner_w + pad_x * 2.0
	var h: float = content_h + pad_y * 2.0
	w = maxf(w, h)
	return {
		"w": w,
		"h": h,
		"name_txt": name_txt,
		"call_txt": call_txt,
		"name_sz": name_sz,
		"call_sz": call_sz,
		"pad_x": pad_x,
		"pad_y": pad_y,
		"gap": gap,
		"inner_w": w - pad_x * 2.0,
		"name_fs": name_fs,
		"call_fs": call_fs,
		"font": font,
	}


func _draw_chip_line(font: Font, origin: Vector2, text: String, fs: int, width: float, col: Color, ink: Color) -> void:
	# draw_multiline_string's Y is the first-line baseline, not the top of the box.
	var pos := Vector2(origin.x, origin.y + font.get_ascent(fs))
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_multiline_string(font, pos + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_CENTER, width, fs, -1, ink)
	draw_multiline_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, fs, -1, col)


func _wrap_call_label(font: Font, label: String, fs: int, max_w: float) -> String:
	var one: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	if one.x <= max_w or label == "":
		return label
	var best := 0
	for i in label.length():
		var ch: String = label.substr(i, 1)
		if ch == " " or ch == "-":
			var left: String = label.substr(0, i + (1 if ch == "-" else 0))
			if font.get_string_size(left, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= max_w:
				best = i
	if best <= 0:
		var mid: int = maxi(1, int(label.length() / 2.0))
		return label.substr(0, mid) + "\n" + label.substr(mid)
	var cut: int = best + (1 if label.substr(best, 1) == "-" else 0)
	var a: String = label.substr(0, cut).strip_edges()
	var b: String = label.substr(cut).strip_edges()
	if b.begins_with("-"):
		b = b.substr(1).strip_edges()
	return a + "\n" + b


func _draw_capsule(rect: Rect2, fill: Color, edge: Color, width: float = 1.6) -> void:
	var rr: float = rect.size.y * 0.5
	var y: float = rect.position.y + rr
	var x0: float = rect.position.x + rr
	var x1: float = rect.position.x + rect.size.x - rr
	draw_circle(Vector2(x0, y), rr, fill)
	draw_circle(Vector2(x1, y), rr, fill)
	draw_rect(Rect2(x0, rect.position.y, maxf(0.0, x1 - x0), rect.size.y), fill, true)
	draw_arc(Vector2(x0, y), rr, PI * 0.5, PI * 1.5, 12, edge, width, true)
	draw_arc(Vector2(x1, y), rr, -PI * 0.5, PI * 0.5, 12, edge, width, true)
	draw_line(Vector2(x0, rect.position.y), Vector2(x1, rect.position.y), edge, width, true)
	draw_line(Vector2(x0, rect.position.y + rect.size.y), Vector2(x1, rect.position.y + rect.size.y), edge, width, true)


func _draw_bold_num(font: Font, pos: Vector2, txt: String, fs: int, col: Color) -> void:
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = pos + Vector2(-tsz.x * 0.5, fs * 0.36)
	var ink := Color("100e0c")
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _star_pts(c: Vector2, outer: float, inner: float, n: int = 8) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n * 2:
		var jagged: float = 0.72 if i % 4 == 1 else 1.0
		var rad: float = (outer if i % 2 == 0 else inner * jagged)
		var a: float = -PI * 0.5 + float(i) * PI / float(n)
		pts.append(c + Vector2.from_angle(a) * rad)
	return pts


func _queen_double(index: int) -> bool:
	if index < 0 or index >= slices.size():
		return false
	if str(slices[index].get("card_id", "")) != "spider_queen":
		return false
	var n: int = slices.size()
	var qhp: int = int(slices[index].get("hp", 0))
	for off in [n - 1, 1]:
		var j: int = (index + off) % n
		if str(slices[j].get("kind", "")) == "monster" and int(slices[j].get("hp", 0)) < qhp:
			return true
	return false


func _draw_atk_stat(font: Font, pos: Vector2, s: Dictionary, pv: Dictionary, big: bool, i: int = -1) -> void:
	var atk: int = int(s.get("atk", 0)) + int(pv.get("atk", 0))
	var atk_d: int = int(pv.get("atk", 0))
	var pulse: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.007)
	var fill: Color = ATK_FILL
	if bool(s.get("atk_variable", false)) or str(pv.get("mark", "")) == "spin":
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if atk_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif atk_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var rad: float = 15.0 if big else 14.0
	if slices.size() >= 9:
		rad -= 1.0
	var seat_atk: int = _seat_delta(i, "atk")
	if seat_atk != 0:
		rad *= 1.16 + 0.20 * pulse
		fill = fill.lerp(Color("ffb48a"), 0.30 + 0.22 * pulse)
	_draw_sword_badge(pos, rad, fill, _center() - pos)
	_draw_bold_num(font, pos + Vector2(0.0, 1.0), str(atk), UI.SIZE_MIN, Color("f0e6d8"))
	if bool(s.get("cmd_buff", false)) or seat_atk != 0:
		var ring_c := Color(1.0, 0.45, 0.22, 0.55 + 0.45 * pulse) if seat_atk != 0 else Color(0.95, 0.22, 0.16, 0.45 + 0.5 * pulse)
		draw_arc(pos, rad + 3.0, 0.0, TAU, 24, ring_c, 2.6 if seat_atk == 0 else 5.0, true)
		if seat_atk != 0:
			draw_arc(pos, rad + 9.0, 0.0, TAU, 24, Color(1.0, 0.82, 0.45, 0.40 + 0.45 * pulse), 3.2, true)
	if int(s.get("copy_from", -1)) >= 0:
		draw_arc(pos, rad + 2.5, 0.0, TAU, 24, Color(0.72, 0.42, 0.92, 0.4 + 0.45 * pulse), 2.4, true)
	if atk_d != 0:
		if seat_atk != 0:
			_draw_delta_badge(font, pos + Vector2(0.0, -rad * 1.35), atk_d)
		else:
			var dc: Color = UP_COL if atk_d > 0 else DOWN_COL
			draw_string(font, pos + Vector2(rad * 0.55, -rad * 0.7), _delta_text(atk_d), HORIZONTAL_ALIGNMENT_LEFT, -1, UI.SIZE_MIN, dc)
	if str(s.get("card_id", "")) == "hornet_swarm" or _seat_tag(i, "atk") == "x2" or bool(s.get("preview_x2", false)):
		var mark: Vector2 = pos + Vector2(0.0, -(rad + 16.0))
		var badge := Rect2(mark - Vector2(20.0, 12.0), Vector2(40.0, 24.0))
		draw_rect(badge, Color("1c120ce8"), true)
		draw_rect(badge, Color("e8c36a"), false, 1.5)
		_draw_outlined_string(font, mark + Vector2(0.0, 6.0), "×2", UI.SIZE_MIN, Color("e8c36a"), Color("1c120c"))


func _draw_sword_badge(pos: Vector2, rad: float, fill: Color, aim: Vector2) -> void:
	var out: Vector2 = aim.normalized() if aim.length() > 0.15 else Vector2.DOWN
	var tan: Vector2 = Vector2(-out.y, out.x)
	var ink := Color("100e0c")
	var edge: Color = ATK_EDGE
	var tip: Vector2 = pos + out * rad * 1.42
	var left: Vector2 = pos - out * rad * 0.22 - tan * rad * 0.62
	var right: Vector2 = pos - out * rad * 0.22 + tan * rad * 0.62
	var haft: Vector2 = pos - out * rad * 1.05
	draw_colored_polygon(PackedVector2Array([
		tip + out * 2.0,
		right + tan * 2.2,
		haft - out * 2.0,
		left - tan * 2.2,
	]), ink)
	draw_colored_polygon(PackedVector2Array([tip, right, haft, left]), fill)
	draw_colored_polygon(PackedVector2Array([
		pos - out * rad * 0.08 - tan * rad * 0.18,
		pos - out * rad * 0.08 + tan * rad * 0.18,
		pos + out * rad * 0.55 + tan * rad * 0.10,
		pos + out * rad * 0.55 - tan * rad * 0.10,
	]), edge)
	draw_circle(pos, rad * 0.50, Color(fill.r, fill.g, fill.b, 0.96))
	draw_arc(pos, rad * 0.50, 0.0, TAU, 22, edge, 2.2, true)
	draw_arc(pos, rad * 0.50, 0.0, TAU, 22, ink, 1.1, true)


func _draw_heart_stat(font: Font, pos: Vector2, s: Dictionary, pv: Dictionary, big: bool, i: int = -1) -> void:
	var hp: int = int(s.get("hp", 0)) + int(pv.get("hp", 0))
	var hp_d: int = int(pv.get("hp", 0))
	var pulse: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.007)
	var fill: Color = HP_FILL
	if bool(s.get("hp_variable", false)) or str(pv.get("mark", "")) == "spin":
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if hp_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif hp_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var hs: float = 26.0 if big else 24.0
	if slices.size() >= 9:
		hs -= 2.0
	var seat_hp: int = _seat_delta(i, "hp")
	if seat_hp != 0:
		hs *= 1.18 + 0.22 * pulse
		fill = fill.lerp(Color("fff4c8"), 0.28 + 0.22 * pulse)
	_draw_heart_shape(pos, hs, fill, Color("1c120c"))
	draw_circle(pos + Vector2(0.0, 3.0), hs * 0.28, Color("6a1818"))
	_draw_bold_num(font, pos + Vector2(0.0, 2.0), str(hp), UI.SIZE_MIN, Color("f0e6d8"))
	if bool(s.get("lich_buff", false)) or seat_hp != 0:
		var pulse2: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.007)
		var ring: Color = Color(1.0, 0.94, 0.55, 0.55 + 0.45 * pulse2) if seat_hp != 0 else Color(0.95, 0.88, 0.72, 0.4 + 0.5 * pulse2)
		draw_arc(pos, hs * 0.52, 0.0, TAU, 20, ring, 2.6 if seat_hp == 0 else 5.2, true)
		if seat_hp != 0:
			draw_arc(pos, hs * 0.72, 0.0, TAU, 22, Color(1.0, 0.98, 0.72, 0.35 + 0.45 * pulse2), 3.4, true)
	if hp_d != 0:
		if seat_hp != 0:
			_draw_delta_badge(font, pos + Vector2(0.0, -hs * 0.95), hp_d)
		else:
			var dc: Color = UP_COL if hp_d > 0 else DOWN_COL
			draw_string(font, pos + Vector2(hs * 0.28, -hs * 0.38), _delta_text(hp_d), HORIZONTAL_ALIGNMENT_LEFT, -1, UI.SIZE_MIN, dc)



func _draw_delta_badge(font: Font, pos: Vector2, d: int) -> void:
	if d == 0:
		return
	var txt: String = _delta_text(d)
	var fs := UI.SIZE_MIN
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var w: float = tsz.x + 14.0
	var h: float = 22.0
	var r := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	var dc: Color = UP_COL if d > 0 else DOWN_COL
	draw_rect(r, Color("140c08ee"), true)
	draw_rect(r, dc, false, 2.0)
	_draw_outlined_string(font, pos + Vector2(0.0, 6.0), txt, fs, dc, Color("140c08"))


func _delta_text(d: int) -> String:
	if d > 0:
		return "+%s" % d
	return str(d)


func _draw_floaters(font: Font) -> void:
	for f in _floaters:
		var t: float = float(f["t"])
		var life: float = float(f["life"])
		var a: float = 1.0 - t / life
		var pos: Vector2 = f["pos"] + Vector2(0.0, -36.0 * t)
		var col: Color = f["col"]
		col.a = a
		var fs: int = int(f.get("fs", 26))
		draw_string(font, pos, str(f["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	for g in _pt_ghosts:
		var t2: float = float(g["t"])
		var life2: float = float(g["life"])
		var a2: float = 1.0 - t2 / life2
		var pos2: Vector2 = g["pos"] + Vector2(0.0, -16.0 * t2)
		var col2: Color = g["col"]
		col2.a = a2
		draw_string(font, pos2, str(g["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, int(g.get("fs", 18)), col2)


func _draw_hub_block(c: Vector2, radius: float) -> void:
	var font: Font = _font_nx if _font_nx != null else get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var bob: float = sin(float(Time.get_ticks_msec()) * 0.004) * 1.4
	var ppos: Vector2 = c + Vector2(0.0, 3.0 + bob)
	if not tex_player.is_empty():
		var fi: int = int(Time.get_ticks_msec() / 180) % tex_player.size()
		var tex: Texture2D = tex_player[fi]
		var psz := Vector2(HUB_R * 1.38, HUB_R * 1.86)
		draw_texture_rect(tex, Rect2(ppos - psz * 0.5, psz), false)
	var pip_n: int = maxi(hub_hp_max, 1)
	var arc_r: float = HUB_R * 0.80
	for i in pip_n:
		var t: float = lerpf(-2.40, -0.74, float(i) / float(maxi(pip_n - 1, 1)))
		var live: bool = i < hub_hp
		var soon: bool = hub_hp_ghost >= 0 and i >= hub_hp_ghost and i < hub_hp
		_draw_hub_pip(c + Vector2(cos(t), sin(t)) * arc_r, Vector2(13, 11), live, soon)
	var shown: int = hub_ghost if hub_ghost >= 0 else hub_blk
	var fill := Color("2a6aa8")
	var rim := Color("6bb3d9")
	if shown <= 0:
		fill = Color("1a3348")
		rim = Color("4a6a80")
	if hub_ghost >= 0 and hub_ghost > hub_blk:
		fill = Color("2a7a58")
		rim = Color("7dba7d")
	var scale: float = 1.0 + hub_flash * 0.28
	var shield_c: Vector2 = c + Vector2(0.0, HUB_R * 0.50)
	var sw: float = 16.0 * scale
	var shield := PackedVector2Array([
		shield_c + Vector2(0.0, -sw * 0.78),
		shield_c + Vector2(sw * 0.70, -sw * 0.28),
		shield_c + Vector2(sw * 0.55, sw * 0.48),
		shield_c + Vector2(0.0, sw * 0.88),
		shield_c + Vector2(-sw * 0.55, sw * 0.48),
		shield_c + Vector2(-sw * 0.70, -sw * 0.28),
	])
	draw_colored_polygon(shield, fill)
	shield.append(shield[0])
	draw_polyline(shield, rim, 3.0, true)
	var txt: String = str(maxi(shown, 0))
	_draw_bold_num(font, shield_c + Vector2(0.0, 1.0), txt, 18, Color("f0e6d8"))


func _draw_stat_chip(pos: Vector2, fill: Color, ink: Color, txt: String, fs: int) -> void:
	var font: Font = _font_nx if _font_nx != null else ThemeDB.fallback_font
	fs = maxi(UI.SIZE_CHIP, fs)
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var w: float = maxf(32.0, tsz.x + 12.0)
	var h := 32.0
	var plate := Color("140D0A")
	var r := Rect2(pos - Vector2(w * 0.5, h * 0.5), Vector2(w, h))
	draw_rect(r, plate, true)
	draw_rect(r, Color("1A120E"), false, 2.0)
	var use_ink: Color = ink
	if fill == HP_FILL:
		use_ink = Color.WHITE
		draw_rect(r, UI.HP_CHIP_FILL, true)
		draw_rect(r, Color("1A120E"), false, 2.0)
	elif fill == CHIP_ATK:
		use_ink = Color("FFD84A")
	draw_string(font, Vector2(pos.x - tsz.x * 0.5, pos.y + fs * 0.35), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, use_ink)


func _draw_hub_stat(num_font: Font, tag_font: Font, pos: Vector2, num: String, tag: String, col: Color, scale: float) -> void:
	var fs: int = int(round(float(UI.SIZE_NUMBER) * scale))
	var tag_fs: int = UI.SIZE_TAG
	var nsz: Vector2 = num_font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var tsz: Vector2 = tag_font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, tag_fs)
	var gap := 8.0
	var total: float = nsz.x + gap + tsz.x
	var x0: float = pos.x - total * 0.5
	draw_string(num_font, Vector2(x0, pos.y), num, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	draw_string(tag_font, Vector2(x0 + nsz.x + gap, pos.y - 2.0), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, tag_fs, UI.DIM)


func _heart_pts(pos: Vector2, hs: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 28:
		var th: float = TAU * float(k) / 28.0
		var x: float = 16.0 * pow(sin(th), 3.0)
		var y: float = -(13.0 * cos(th) - 5.0 * cos(2.0 * th) - 2.0 * cos(3.0 * th) - cos(4.0 * th))
		pts.append(pos + Vector2(x, y) * (hs / 34.0))
	return pts


func _draw_heart_shape(pos: Vector2, hs: float, fill: Color, outline: Color) -> void:
	var outer: PackedVector2Array = _heart_pts(pos, hs * 1.14)
	draw_colored_polygon(outer, outline)
	var inner: PackedVector2Array = _heart_pts(pos, hs)
	draw_colored_polygon(inner, fill)
	draw_circle(pos + Vector2(-hs * 0.16, -hs * 0.10), hs * 0.11, fill.lightened(0.28))


func _draw_hub_pip(pos: Vector2, sz: Vector2, live: bool, soon: bool) -> void:
	var pulse: float = 0.55 + 0.45 * sin(float(Time.get_ticks_msec()) * 0.014)
	var draw_sz: Vector2 = sz
	if soon:
		draw_sz *= 1.0 + 0.16 * pulse
	var tex: Texture2D = tex_heart_full if live else tex_heart_empty
	if soon and pulse > 0.55:
		tex = tex_heart_empty
	if tex != null:
		var col := Color.WHITE
		if soon:
			col = Color.WHITE.lerp(Color("f0e6d8"), pulse)
		elif not live:
			col = Color(1, 1, 1, 0.92)
		draw_texture_rect(tex, Rect2(pos - draw_sz * 0.5, draw_sz), false, col)
		return
	var hcol := HP_FILL if live else Color(0.28, 0.18, 0.16, 0.9)
	if soon:
		hcol = hcol.lerp(Color("f0e6d8"), 0.35 + 0.35 * pulse)
	_draw_heart_shape(pos, draw_sz.x * 0.72, hcol, Color("1c120c"))


func _draw_mini_heart(pos: Vector2, hs: float, col: Color) -> void:
	_draw_heart_shape(pos, hs, col, Color("1c120c"))


func _draw_threat(c: Vector2, radius: float) -> void:
	if threat_t <= 0.02 or facing_index < 0 or facing_index >= slices.size():
		return
	if str(slices[facing_index].get("kind", "")) != "monster":
		return
	var grow: float = clampf(threat_t / 0.38, 0.0, 1.0)
	grow = grow * grow * (3.0 - 2.0 * grow)
	var fade: float = 1.0 if threat_t < 0.58 else clampf(1.0 - (threat_t - 0.58) / 0.42, 0.0, 1.0)
	var from: Vector2 = _spoke(facing_index)["port"]
	var dir: Vector2 = (c - from)
	if dir.length() < 4.0:
		return
	dir = dir.normalized()
	var to: Vector2 = from + (c - from) * (0.18 + 0.62 * grow)
	var col := Color(0.92, 0.18, 0.12, 0.88 * fade)
	var hot := Color(0.98, 0.72, 0.22, 0.75 * fade)
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var pts := PackedVector2Array()
	pts.append(from + perp * 3.0)
	var segs: int = 8
	for k in range(1, segs):
		var t: float = float(k) / float(segs)
		var wob: float = (1.0 if k % 2 == 0 else -1.0) * (7.0 + float(k % 3) * 5.0) * grow
		pts.append(from.lerp(to, t) + perp * wob)
	pts.append(to)
	draw_polyline(pts, col, 6.0 * grow, true)
	draw_polyline(pts, hot, 2.2, true)
	var head := PackedVector2Array([
		to,
		to - dir * 16.0 * grow + perp * 10.0 * grow,
		to - dir * 16.0 * grow - perp * 10.0 * grow,
	])
	draw_colored_polygon(head, col)


func _draw_slay(font: Font, c: Vector2, radius: float) -> void:
	if slay_index < 0 or slay_index >= slices.size():
		return
	var dir: Vector2 = _dir_of(slay_index)
	var pos: Vector2 = c + dir * radius * 0.52 + _slay_push(slay_index)
	var a: float = clampf(slay_t * 1.4, 0.0, 1.0)
	var blocked: bool = slay_kind == "block"
	var ink: Color = Color("5aa8e8") if blocked else DOWN_COL
	var xcol := Color(ink.r, ink.g, ink.b, a)
	var arm: float = lerpf(10.0, 54.0, a)
	if blocked:
		var burst: float = lerpf(18.0, 58.0, a)
		draw_arc(pos, burst, 0.0, TAU, 28, xcol, 7.0, true)
		draw_arc(pos, burst * 0.62, 0.2, TAU + 0.2, 22, Color(ink.r, ink.g, ink.b, a * 0.55), 4.0, true)
		for i in 8:
			var ang: float = float(i) * TAU / 8.0 + slay_t * 0.6
			var inner: Vector2 = pos + Vector2.from_angle(ang) * burst * 0.18
			var outer: Vector2 = pos + Vector2.from_angle(ang) * burst
			draw_line(inner, outer, xcol, 5.0, true)
	else:
		draw_line(pos + Vector2(-arm, -arm), pos + Vector2(arm, arm), xcol, 8.0, true)
		draw_line(pos + Vector2(arm, -arm), pos + Vector2(-arm, arm), xcol, 8.0, true)
	if slay_t > 0.18:
		var word: String = COPY.need("combat.blocked") if blocked else COPY.need("combat.slain")
		var ta: float = clampf((slay_t - 0.18) / 0.45, 0.0, 1.0)
		var banner_font: Font = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
		if banner_font == null:
			banner_font = font
		var fs: int = 44
		var sz: Vector2 = banner_font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var banner := Rect2(Vector2(548.0 - size.x * 0.5 - (sz.x + 32.0) * 0.5, 480.0 if blocked else 622.0) - global_position, Vector2(sz.x + 32.0, 56.0))
		if blocked:
			banner.position = Vector2(c.x - (sz.x + 32.0) * 0.5, pos.y + 36.0)
		else:
			banner.position = Vector2(c.x - (sz.x + 32.0) * 0.5, pos.y + 28.0)
		var bg := Color("0F2233") if blocked else Color("2A0D0A")
		bg.a *= ta
		var ink_txt := Color("E9F4FF") if blocked else Color("FFE4DE")
		ink_txt.a *= ta
		var rim: Color = Color("4FA3D9") if blocked else Color("D5443B")
		draw_rect(banner, bg, true)
		draw_rect(banner, Color(rim.r, rim.g, rim.b, ta), false, 5.0)
		draw_string(banner_font, banner.position + Vector2(16.0, 42.0), word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink_txt)
