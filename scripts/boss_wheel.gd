extends Control
## Stone wheel. Upright portraits. Attack and HP sit as a triangle outside the sprite. Name plus ability title sit on the rim, screen-upright.

signal slice_clicked(index: int)
signal slice_hovered(index: int)
signal slice_right_clicked(index: int)

var show_shift: bool = false

const COPY := preload("res://scripts/player_copy.gd")
const FX_RAYS := preload("res://scripts/fx_rays.gd")

const SIX := PI / 2.0
const EMPTY_FILL := Color("14110e")
const STONE := Color("2a231e")
const STONE_DEEP := Color("1c1814")
const RING := Color("c4a574")
const HUB := Color("100e0c")
const HUB_FRAC := 0.34
const FACE_RIM := Color("e8c36a")
const PLACE_RIM := Color("8dcb8d")
const BRIBE_RIM := Color("d19a66")
const ATK_COL := Color("e8dcc8")
const ATK_FILL := Color("c45a14")
const ATK_EDGE := Color("f0a040")
const HP_COL := Color("f0e6d8")
const HP_FILL := Color("c4282a")
const DOWN_COL := Color("c45c5c")
const UP_COL := Color("7dba7d")
const SPIN_COL := Color("e8c36a")

var slices: Array = []
var facing_index: int = -1
var hover_index: int = -1
var spinning: bool = false
var highlight: String = "none"
var preview: Dictionary = {}
var log_focus: Dictionary = {}
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
var _hp_disp: Dictionary = {}
var _hp_punch: Dictionary = {}
var _atk_disp: Dictionary = {}
var _atk_punch: Dictionary = {}
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
var hub_blk: int = -1
var hub_ghost: int = -1
var portrait_away: int = -1:
	set(v):
		portrait_away = v
		queue_redraw()
var aura_index: int = -1:
	set(v):
		aura_index = v
		queue_redraw()
var hub_on: bool = false
var hub_flash: float = 0.0:
	set(v):
		hub_flash = v
		queue_redraw()
var hub_hp_flash: float = 0.0:
	set(v):
		hub_hp_flash = v
		queue_redraw()
var hub_sting: float = 0.0:
	set(v):
		hub_sting = v
		queue_redraw()
var hub_sting_kind: String = "hurt"
var hub_nudge: Vector2 = Vector2.ZERO:
	set(v):
		hub_nudge = v
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
var hub_pierce: bool = false


func set_hub_pierce(on: bool) -> void:
	if hub_pierce == on:
		return
	hub_pierce = on
	queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)
	mouse_exited.connect(_on_mouse_out)
	set_process(true)


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


func set_log_focus(next: Dictionary) -> void:
	log_focus = next
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


## Small player-hub hit / block tell. Not the faced-slice BLOCKED stamp.
func play_hub_sting(kind: String, amount: int = 0) -> void:
	hub_sting_kind = kind
	hub_sting = 1.0
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	if kind == "hurt" and amount > 0:
		_floaters.append({
			"pos": c + Vector2(-22.0, hub_r * 0.42),
			"text": "-%s" % amount,
			"col": DOWN_COL,
			"t": 0.0,
			"life": 0.7,
		})
		hub_hp_flash = 1.0
		var htw := create_tween()
		htw.tween_property(self, "hub_hp_flash", 0.0, 0.26)
	elif kind == "block":
		punch_hub()
	var knock := Vector2(5.0, 3.0) if kind == "hurt" else Vector2(-2.5, 0.0)
	var dur: float = 0.30 if kind == "hurt" else 0.34
	var tw := create_tween()
	tw.tween_property(self, "hub_nudge", knock, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hub_nudge", Vector2.ZERO, dur - 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fade := create_tween()
	fade.tween_property(self, "hub_sting", 0.0, dur)
	await tw.finished


func play_slay(index: int) -> void:
	busy = true
	slay_kind = "slay"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.55)
	await tw.finished
	busy = false


func play_block(index: int) -> void:
	busy = true
	slay_kind = "block"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.5)
	await tw.finished
	busy = false


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


func hit_feedback(index: int, hp_lost: int, atk_delta: int = 0) -> void:
	if index < 0 or index >= slices.size():
		return
	_flash[index] = 0.5
	var pos: Vector2 = _hp_pos(index)
	if hp_lost > 0:
		_floaters.append({"pos": pos, "text": "-%s" % hp_lost, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	elif hp_lost < 0:
		_floaters.append({"pos": pos, "text": "+%s" % -hp_lost, "col": UP_COL, "t": 0.0, "life": 0.9})
	if atk_delta < 0:
		_floaters.append({"pos": _atk_pos(index), "text": "%s" % atk_delta, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	elif atk_delta > 0:
		_floaters.append({"pos": _atk_pos(index), "text": "+%s" % atk_delta, "col": UP_COL, "t": 0.0, "life": 0.9})
	queue_redraw()


func rotation_for_index(index: int) -> float:
	var n: int = _n()
	var ang: float = TAU / float(n)
	var center_at_zero: float = float(index) * ang + ang * 0.5
	return SIX - center_at_zero


func rot_to_center(index: int) -> float:
	if index < 0 or index >= slices.size():
		return rot
	var mid: float = _span(index) * 0.5
	for i in index:
		mid += _span(i)
	return SIX - mid


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
	_spin_tween = create_tween()
	_spin_tween.set_ignore_time_scale(true)
	_spin_tween.set_trans(Tween.TRANS_CUBIC)
	_spin_tween.set_ease(Tween.EASE_IN_OUT)
	_spin_tween.tween_property(self, "rot", rot + delta, 1.2)
	await _spin_tween.finished
	rot = fposmod(rot, TAU)
	spinning = false
	facing_index = index
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
	return minf(size.x, size.y) * 0.46


func _process(delta: float) -> void:
	_glow_t += delta
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
	var punch_keep := {}
	for pk in _hp_punch.keys():
		var pv: float = float(_hp_punch[pk]) - delta * 3.4
		if pv > 0.02:
			punch_keep[pk] = pv
	_hp_punch = punch_keep
	var atk_punch_keep := {}
	for ak in _atk_punch.keys():
		var av: float = float(_atk_punch[ak]) - delta * 3.4
		if av > 0.02:
			atk_punch_keep[ak] = av
	_atk_punch = atk_punch_keep
	queue_redraw()


func slice_at(local: Vector2) -> int:
	if slices.is_empty() or spinning or busy:
		return -1
	var c: Vector2 = _center()
	var v: Vector2 = local - c
	var radius: float = _radius()
	var d: float = v.length()
	if d < radius * 0.22 or d > radius * 1.22:
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
	var a: float = rot
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
	var origin: Vector2 = c + dir * (lift * 8.0) + _slay_push(i)
	var r: float = _radius() + lift * 12.0
	var n: int = maxi(slices.size(), 1)
	var is_face: bool = (not spinning) and i == facing_index
	var crowded: bool = n >= 9
	var win: float = 70.0 if is_face else 64.0
	if crowded:
		win -= 6.0
	var max_win: float = r * maxf(absf(_span(i)), 0.28) * 0.70
	win = minf(win, maxf(48.0, max_win))
	var plate_r: float = win * 0.52
	var port: Vector2 = origin + dir * r * 0.58
	var spread: float = plate_r + (18.0 if is_face else 16.0)
	if crowded:
		spread -= 2.0
	var hp: Vector2 = _clamp_to_rim(port + tan * spread, 18.0)
	var atk: Vector2 = _clamp_to_rim(port - tan * spread, 18.0)
	var nam: Vector2 = origin + dir * (r * 0.58 + plate_r + 22.0)
	return {
		"c": c,
		"dir": dir,
		"tan": tan,
		"origin": origin,
		"r": r,
		"win": win,
		"plate_r": plate_r,
		"port": port,
		"name": nam,
		"atk": atk,
		"hp": hp,
		"span": _span(i),
	}


func slice_portrait_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	var local: Vector2 = _spoke(i)["port"]
	return get_global_transform() * local


func hp_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	return get_global_transform() * _hp_pos(i)


func atk_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	return get_global_transform() * _atk_pos(i)


func hub_hearts_global() -> Vector2:
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	return get_global_transform() * (c + Vector2(-22.0, hub_r * 0.42))


func hub_blk_global() -> Vector2:
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	return get_global_transform() * (c + Vector2(24.0, hub_r * 0.42))


func punch_hp(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_hp_punch[index] = 1.0
	_flash[index] = 0.55
	queue_redraw()


func punch_atk(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_atk_punch[index] = 1.0
	_flash[index] = 0.55
	queue_redraw()


func play_atk_ticks(index: int, from_n: int, to_n: int) -> void:
	if index < 0 or index >= slices.size() or from_n == to_n:
		punch_atk(index)
		return
	var step: int = -1 if to_n < from_n else 1
	var n: int = from_n
	_atk_disp[index] = n
	punch_atk(index)
	while n != to_n:
		n += step
		_atk_disp[index] = n
		punch_atk(index)
		if get_tree():
			await get_tree().create_timer(0.035).timeout
	_atk_disp.erase(index)
	queue_redraw()


func play_hp_ticks(index: int, from_n: int, to_n: int) -> void:
	if index < 0 or index >= slices.size() or from_n == to_n:
		punch_hp(index)
		return
	var step: int = -1 if to_n < from_n else 1
	var n: int = from_n
	_hp_disp[index] = n
	punch_hp(index)
	while n != to_n:
		n += step
		_hp_disp[index] = n
		punch_hp(index)
		if get_tree():
			await get_tree().create_timer(0.035).timeout
	_hp_disp.erase(index)
	queue_redraw()


func _atk_pos(i: int) -> Vector2:
	return _spoke(i)["atk"]


func _hp_pos(i: int) -> Vector2:
	return _spoke(i)["hp"]


func focus_rect(kind: String) -> Rect2:
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	if kind == "hub_hp":
		return _global_badge(c + Vector2(-22.0, hub_r * 0.42), 36.0)
	if kind == "hub_blk":
		return _global_badge(c + Vector2(24.0, hub_r * 0.42), 36.0)
	if kind == "atk" and facing_index >= 0:
		return _global_badge(_atk_pos(facing_index), 34.0)
	if kind == "hp" and facing_index >= 0:
		return _global_badge(_hp_pos(facing_index), 34.0)
	if kind == "empty":
		return _slice_global_rect(_first_empty_slice())
	if kind == "face" and facing_index >= 0:
		return _slice_global_rect(facing_index)
	return Rect2()


func _global_badge(local: Vector2, rad: float) -> Rect2:
	var g: Vector2 = get_global_transform() * local
	return Rect2(g - Vector2(rad, rad), Vector2(rad * 2.0, rad * 2.0))


func _first_empty_slice() -> int:
	for i in slices.size():
		if str(slices[i].get("kind", "")) != "monster":
			return i
	return -1


func slice_rect(i: int) -> Rect2:
	return _slice_global_rect(i)


func _slice_global_rect(i: int) -> Rect2:
	if i < 0 or i >= slices.size():
		return Rect2()
	var starts: PackedFloat32Array = _starts()
	var a0: float = starts[i]
	var a1: float = a0 + _span(i)
	var c: Vector2 = _center()
	var radius: float = _radius()
	var mn := Vector2(1.0e9, 1.0e9)
	var mx := Vector2(-1.0e9, -1.0e9)
	var pts: Array[Vector2] = [c]
	for k in 9:
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(k) / 8.0)) * radius)
	for p in pts:
		var g: Vector2 = get_global_transform() * p
		mn.x = minf(mn.x, g.x)
		mn.y = minf(mn.y, g.y)
		mx.x = maxf(mx.x, g.x)
		mx.y = maxf(mx.y, g.y)
	return Rect2(mn, mx - mn).grow(10.0)


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
	if slices.is_empty():
		draw_arc(c, radius, 0.0, TAU, 72, Color("3a322b"), 2.0, true)
		_draw_pointer(c, radius)
		return
	var n: int = slices.size()
	var starts: PackedFloat32Array = _starts()
	var top: Array[int] = []
	for i in n:
		if i == hover_index or i == facing_index:
			top.append(i)
		else:
			_draw_slice(c, radius, starts[i], starts[i] + _span(i), i)
	draw_circle(c, radius * HUB_FRAC, HUB)
	draw_arc(c, radius * HUB_FRAC, 0.0, TAU, 48, RING, 2.6, true)
	draw_arc(c, radius, 0.0, TAU, 80, RING, 3.0, true)
	for i in top:
		_draw_slice(c, radius, starts[i], starts[i] + _span(i), i)
	_draw_pointer(c, radius)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	for i in n:
		_draw_slice_contents(font, c, radius, starts[i], _span(i), i)
	_draw_bonds(c, radius)
	_draw_hub_block(c, radius)
	_draw_threat(c, radius)
	_draw_floaters(font)
	if slay_index >= 0 and slay_t > 0.0:
		_draw_slay(font, c, radius)


func _draw_pointer(c: Vector2, radius: float) -> void:
	var bob: float = 2.0 + absf(sin(_glow_t * 8.0)) * 4.0
	var tip := Vector2(c.x, c.y + radius + 2.0)
	var left := Vector2(c.x - 14.0, c.y + radius + 20.0 + bob)
	var right := Vector2(c.x + 14.0, c.y + radius + 20.0 + bob)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), FACE_RIM)
	draw_colored_polygon(PackedVector2Array([
		tip + Vector2(0.0, 3.0),
		left + Vector2(3.0, -2.0),
		right + Vector2(-3.0, -2.0),
	]), Color("f0e6d8"))


func _fill_for(s: Dictionary, is_face: bool, is_hover: bool) -> Color:
	if str(s.get("kind", "")) != "monster":
		if highlight == "place":
			return Color("1a2a1a")
		if highlight == "bribe":
			return Color("2a1c14")
		return EMPTY_FILL
	var fill: Color = STONE
	var pt: int = int(s.get("pack_tier", 0))
	if pt <= 0:
		pt = int(s.get("tier", 0))
	if pt == 3:
		fill = Color(0.58, 0.16, 0.08)
	elif pt == 2:
		fill = Color(0.14, 0.30, 0.48)
	elif pt == 1:
		fill = Color(0.52, 0.28, 0.10)
	elif str(s.get("rarity", "")) == "uncommon":
		fill = Color("24262a")
	if is_face:
		fill = fill.lightened(0.16)
	elif is_hover:
		fill = fill.lightened(0.10)
	elif facing_index >= 0 and (not spinning) and str(s.get("kind", "")) == "monster":
		fill = fill.darkened(0.18)
	if bool(s.get("poisoned", false)):
		fill = fill.lerp(Color("2e4a32"), 0.55)
	if bool(s.get("crossbowed", false)):
		fill = fill.lerp(Color("5a4a18"), 0.45)
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
	if i < 0 or i >= slices.size():
		return
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
	_draw_wedge(origin, r, a0, a1, fill)
	if str(s.get("kind", "")) == "monster":
		var wash: Color = fill.lightened(0.22)
		wash.a = 0.42
		_draw_wedge(origin, r * 0.86, a0 + 0.03, a1 - 0.03, wash)
		var glow: Color = fill.lightened(0.38)
		glow.a = 0.22
		_draw_wedge(origin, r * 0.70, a0 + 0.05, a1 - 0.05, glow)
	var rim: Color = Color("2a241e")
	var rw: float = 1.4
	if is_face:
		rim = FACE_RIM
		rw = 5.2
	elif highlight == "place" and str(s.get("kind", "")) == "empty":
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
		rim = Color("c08050")
		rw = 2.6
		if t == 2:
			rim = Color("c5cdd8")
			rw = 3.2
		elif t >= 3:
			rim = Color("e8c36a")
			rw = 3.8
		if is_hover:
			rim = rim.lightened(0.18)
			rw += 0.8
	elif is_hover:
		rim = Color("f0e6d8")
		rw = 2.4
	if int(log_focus.get("wheel", -1)) == i:
		rim = Color("fff0c0")
		rw += 2.4
		var pulse: float = 0.55 + 0.45 * sin(_glow_t * 8.0)
		draw_arc(origin, r + 6.0, a0, a1, 26, Color(1.0, 0.94, 0.75, 0.35 + 0.4 * pulse), 4.0, true)
	draw_arc(origin, r, a0, a1, 26, rim, rw, true)


func _draw_slice_contents(font: Font, c: Vector2, radius: float, a0: float, ang: float, i: int) -> void:
	if i < 0 or i >= slices.size():
		return
	var s: Dictionary = slices[i]
	var sp: Dictionary = _spoke(i)
	var dir: Vector2 = sp["dir"]
	var origin: Vector2 = sp["origin"]
	var r: float = sp["r"]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = i == hover_index
	var dim: float = 1.0
	if facing_index >= 0 and not spinning and not is_face and not is_hover:
		dim = 0.84
	if str(s.get("kind", "")) != "monster":
		if highlight == "place" and tex_plus != null:
			var p: Vector2 = origin + dir * r * 0.58
			draw_texture_rect(tex_plus, Rect2(p - Vector2(16, 16), Vector2(32, 32)), false)
		return
	var pv: Dictionary = preview.get(i, preview.get(str(i), {}))
	if typeof(pv) != TYPE_DICTIONARY:
		pv = {}
	var crowded: bool = slices.size() >= 9
	var pid: String = str(s.get("card_id", ""))
	var port_pos: Vector2 = sp["port"]
	var plate_r: float = float(sp.get("plate_r", 36.0))
	_draw_tier_plate(port_pos, plate_r, s)
	if i == aura_index:
		var glow := Color("e8c36a")
		glow.a = 0.42 + 0.18 * absf(sin(_glow_t * 8.0))
		draw_circle(port_pos, plate_r + 14.0, glow)
	if tex_portraits.has(pid) and i != portrait_away:
		_draw_portrait_window(port_pos, plate_r, s, tex_portraits[pid], 0.0, dim)
	_draw_tier_rim(port_pos, plate_r, s)
	_draw_tier_num(font, port_pos - dir * (plate_r + 12.0), s, is_face, crowded)
	var sid: String = str(s.get("special_id", ""))
	if sid != "" and tex_special.has(sid) and not tex_portraits.has(pid):
		var st: Texture2D = tex_special[sid]
		draw_texture_rect(st, Rect2(port_pos - Vector2(9, 9), Vector2(18, 18)), false, Color(dim, dim, dim, dim))
	var big: bool = is_face or _lift_of(i) > 0.45 or is_hover
	_draw_slice_title(font, sp, s, is_face, crowded, dim, is_hover)
	_draw_heart_stat(font, sp["hp"], s, pv, big, i)
	_draw_atk_stat(font, sp["atk"], s, pv, big, i)
	if bool(s.get("poisoned", false)):
		draw_circle(sp["hp"] + Vector2(12, -10), 4.0, Color("7dba7d"))
	var would_die: bool = int(s.get("hp", 0)) + int(pv.get("hp", 0)) <= 0 and int(pv.get("hp", 0)) < 0
	if would_die or bool(pv.get("kill", false)):
		var xa: float = 0.55 + 0.25 * sin(_glow_t * 12.0)
		var xc := Color(DOWN_COL.r, DOWN_COL.g, DOWN_COL.b, xa)
		var arm: float = 22.0
		draw_line(port_pos + Vector2(-arm, -arm), port_pos + Vector2(arm, arm), xc, 4.0, true)
		draw_line(port_pos + Vector2(arm, -arm), port_pos + Vector2(-arm, arm), xc, 4.0, true)


func _plate_tier(s: Dictionary) -> int:
	var t: int = int(s.get("pack_tier", 0))
	if t < 1:
		t = int(s.get("tier", 1))
	return t


func _plate_pts(center: Vector2, rad: float, tier: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	if tier >= 3:
		for k in 10:
			var a: float = -PI * 0.5 + float(k) * TAU / 10.0
			var rr: float = rad * (1.12 if k % 2 == 0 else 0.72)
			pts.append(center + Vector2.from_angle(a) * rr)
	elif tier == 2:
		for k2 in 6:
			var a2: float = -PI * 0.5 + float(k2) * TAU / 6.0
			pts.append(center + Vector2.from_angle(a2) * rad)
	else:
		for k3 in 24:
			var a3: float = -PI * 0.5 + float(k3) * TAU / 24.0
			pts.append(center + Vector2.from_angle(a3) * rad)
	return pts


func _draw_tier_plate(center: Vector2, rad: float, s: Dictionary) -> void:
	var t: int = _plate_tier(s)
	var fill := Color("241610")
	if t == 2:
		fill = Color("161018")
	elif t >= 3:
		fill = Color("100308")
	_fill_poly(_plate_pts(center, rad, t), fill)


func _fill_poly(pts: PackedVector2Array, col: Color) -> void:
	var count: int = pts.size()
	if count < 3:
		return
	var mid: Vector2 = Vector2.ZERO
	for p in pts:
		mid += p
	mid /= float(count)
	for i in count:
		draw_colored_polygon(PackedVector2Array([mid, pts[i], pts[(i + 1) % count]]), col)


func _draw_tier_num(_font: Font, _pos: Vector2, _s: Dictionary, _is_face: bool, _crowded: bool) -> void:
	pass


func _draw_tier_rim(center: Vector2, rad: float, s: Dictionary) -> void:
	var t: int = _plate_tier(s)
	var col := Color("c08050")
	var w: float = 2.2
	if t == 2:
		col = Color("c5cdd8")
		w = 2.6
	elif t >= 3:
		col = Color("e8c36a")
		w = 3.0
	if draft_glow:
		var pulse: float = 0.50 + 0.50 * absf(sin(_glow_t * 3.0 + float(t) * 0.7))
		col = col.lerp(col.lightened(0.55), pulse * 0.75)
		w += pulse * (2.4 if t >= 3 else 1.6)
	if t >= 2:
		var pts: PackedVector2Array = _plate_pts(center, rad, t)
		pts.append(pts[0])
		draw_polyline(pts, col, w, true)
	else:
		draw_arc(center, rad, 0.0, TAU, 28, col, w, true)


func _draw_portrait_window(center: Vector2, rad: float, s: Dictionary, tex: Texture2D, face_ang: float, dim: float = 1.0) -> void:
	if tex == null:
		return
	var side: float = rad * 1.55
	var dest := Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side))
	var mod := Color(dim, dim, dim, 1.0)
	if absf(face_ang) > 0.01:
		draw_set_transform(center, face_ang, Vector2.ONE)
		draw_texture_rect(tex, Rect2(Vector2(-side, -side) * 0.5, Vector2(side, side)), false, mod)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(tex, dest, false, mod)


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


func _draw_edge_ticks(i: int, j: int, col: Color) -> void:
	var c: Vector2 = _center()
	var radius: float = _radius()
	var ang: float = _edge_angle_between(i, j)
	var a: Vector2 = Vector2.from_angle(ang)
	draw_line(c + a * radius * HUB_FRAC, c + a * radius * 0.76, col, 3.2, true)


func _draw_bonds(_c: Vector2, _radius: float) -> void:
	var n: int = slices.size()
	if n == 0:
		return
	var pulse: float = 0.50 + 0.50 * sin(_glow_t * 6.0)
	for i in n:
		var s: Dictionary = slices[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		var cid: String = str(s.get("card_id", ""))
		var sp: Dictionary = _spoke(i)
		var hot: bool = i == hover_index
		if cid == "commander" and str(s.get("special_id", "")) != "":
			var a: float = (0.82 + 0.18 * pulse) if hot else (0.30 + 0.10 * pulse)
			var rc := Color(0.92, 0.22, 0.16, a)
			for off in [n - 1, 1]:
				var j: int = (i + off) % n
				if not _living_neighbor(j):
					continue
				FX_RAYS.draw(self, sp["port"], _spoke(j)["port"], rc, _glow_t, hot)
				FX_RAYS.draw(self, sp["port"], _spoke(j)["atk"], Color(rc.r, rc.g, rc.b, rc.a * 0.7), _glow_t, hot)
		elif cid == "lich" and str(s.get("special_id", "")) != "":
			var a2: float = (0.82 + 0.18 * pulse) if hot else (0.30 + 0.10 * pulse)
			var cream := Color(0.95, 0.88, 0.72, a2)
			for off2 in [n - 1, 1]:
				var j2: int = (i + off2) % n
				if not _living_neighbor(j2):
					continue
				FX_RAYS.draw(self, sp["port"], _spoke(j2)["port"], cream, _glow_t, hot)
				FX_RAYS.draw(self, sp["port"], _spoke(j2)["hp"], Color(cream.r, cream.g, cream.b, cream.a * 0.7), _glow_t, hot)
		elif cid == "wraith":
			var src: int = int(s.get("copy_from", -1))
			if src >= 0 and src < n and _living_neighbor(src):
				var a3: float = (0.82 + 0.18 * pulse) if hot else (0.30 + 0.10 * pulse)
				var pur := Color(0.72, 0.42, 0.92, a3)
				FX_RAYS.draw(self, _spoke(src)["atk"], sp["atk"], pur, _glow_t, hot)
		elif cid == "slime_boss":
			var slime := Color(0.45, 0.82, 0.42, 0.85)
			var midp: Vector2 = (sp["atk"] + sp["hp"]) * 0.5
			var font: Font = get_theme_default_font()
			if font == null:
				font = ThemeDB.fallback_font
			_draw_outlined_string(font, midp + Vector2(0, 5), "=", 15, slime, Color("1c120c"))


func _living_neighbor(j: int) -> bool:
	if j < 0 or j >= slices.size():
		return false
	if str(slices[j].get("kind", "")) != "monster":
		return false
	return int(slices[j].get("hp", 0)) > 0


func _draw_bold_name(font: Font, pos: Vector2, text: String, fs: int, col: Color, wrap: float = 108.0) -> void:
	_draw_outlined_string(font, pos, text, fs, col, Color("100e0c"))


func _draw_slice_title(font: Font, sp: Dictionary, s: Dictionary, is_face: bool, crowded: bool, dim: float = 1.0, is_hover: bool = false) -> void:
	var name_s: String = str(s.get("name", "")).strip_edges()
	var call_s: String = str(s.get("call_name", "")).strip_edges()
	if show_shift:
		var shift_s: String = str(s.get("reminder", "")).strip_edges()
		if shift_s == "" or shift_s == "---":
			shift_s = str(s.get("ability", "")).strip_edges()
		if shift_s != "":
			call_s = shift_s
	if name_s == "":
		return
	if call_s.to_lower() == name_s.to_lower() or name_s.to_lower().find(call_s.to_lower()) >= 0:
		call_s = ""
	var name_fs: int = 18 if is_face else (15 if is_hover else 13)
	var call_fs: int = 12 if is_face else 11
	if crowded:
		name_fs = maxi(12, name_fs - 2)
		call_fs = maxi(10, call_fs - 1)
	var span: float = absf(float(sp.get("span", 0.6)))
	var max_w: float = clampf(_radius() * maxf(span, 0.18) * 0.92, 88.0, 168.0)
	var name_txt: String = _wrap_call_label(font, name_s, name_fs, max_w)
	var call_txt: String = _wrap_call_label(font, call_s, call_fs, max_w) if call_s != "" else ""
	var name_sz: Vector2 = font.get_multiline_string_size(name_txt, HORIZONTAL_ALIGNMENT_CENTER, max_w, name_fs)
	var call_sz: Vector2 = font.get_multiline_string_size(call_txt, HORIZONTAL_ALIGNMENT_CENTER, max_w, call_fs) if call_txt != "" else Vector2.ZERO
	var pad_x := 8.0
	var pad_y := 4.0
	var gap := 2.0
	var inner_w: float = minf(maxf(name_sz.x, call_sz.x), max_w)
	var w: float = inner_w + pad_x * 2.0
	var h: float = pad_y * 2.0 + name_sz.y
	if call_txt != "":
		h += gap + call_sz.y
	var dir: Vector2 = sp["dir"]
	var port: Vector2 = sp["port"]
	var plate_r: float = float(sp.get("plate_r", 36.0))
	var rim: Vector2 = Vector2(sp["origin"]) + dir * float(sp["r"])
	var band_a: Vector2 = port + dir * (plate_r + 10.0)
	var band_b: Vector2 = rim - dir * (h * 0.5 + 6.0)
	var pos: Vector2 = band_a.lerp(band_b, 0.42) if band_a.distance_to(band_b) > 4.0 else Vector2(sp["name"])
	var top_left := Vector2(pos.x - w * 0.5, pos.y - h * 0.5)
	var fill := Color(0.08, 0.06, 0.05, 0.90 * dim)
	var edge: Color = Color("e8c36a") if is_face else Color("c4a574")
	edge.a = dim
	_draw_capsule(Rect2(top_left, Vector2(w, h)), fill, edge)
	var ink := Color(0.06, 0.05, 0.04, dim)
	var name_col: Color = Color("e8c36a") if is_face else Color("f0e6d8")
	name_col.a = dim
	var y: float = top_left.y + pad_y + font.get_ascent(name_fs)
	var np := Vector2(top_left.x + pad_x, y)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_multiline_string(font, np + Vector2(ox, oy), name_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, name_fs, 2, ink)
	draw_multiline_string(font, np, name_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, name_fs, 2, name_col)
	if call_txt != "":
		var col: Color = _ability_icon_color(str(s.get("special_id", "")))
		col.a = dim
		var cp := Vector2(top_left.x + pad_x, y + name_sz.y + gap)
		for ox2 in [-1, 0, 1]:
			for oy2 in [-1, 0, 1]:
				if ox2 == 0 and oy2 == 0:
					continue
				draw_multiline_string(font, cp + Vector2(ox2, oy2), call_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, call_fs, 2, ink)
		draw_multiline_string(font, cp, call_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, call_fs, 2, col)


func _ability_icon_color(sid: String) -> Color:
	match sid:
		"item_atk", "two_items", "gift", "eat_item", "petrify", "no_keep", "item_swings", "fair_trade", "gift_shield", "insure":
			return Color("e8c36a")
		"no_atk_dmg", "double_hit", "atk_spin", "copy_atk", "buff_atk", "pierce", "thorns", "queen_hits", "interrupt", "even_twice", "left_atk", "pass_right", "coward":
			return Color("e07040")
		"last_hp", "buff_hp", "hp_spin", "pack_hp", "leech_lowest", "one_chip", "take_instead":
			return Color("e8a0a0")
		"kill_scale", "atk_eq_hp":
			return Color("c9a0ff")
		"wickrise":
			return Color("e8c36a")
		"split_t2":
			return Color("c5cdd8")
		_:
			return Color("f0e6d8")


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


func _draw_capsule(rect: Rect2, fill: Color, edge: Color) -> void:
	var rr: float = rect.size.y * 0.5
	var y: float = rect.position.y + rr
	var x0: float = rect.position.x + rr
	var x1: float = rect.position.x + rect.size.x - rr
	draw_circle(Vector2(x0, y), rr, fill)
	draw_circle(Vector2(x1, y), rr, fill)
	draw_rect(Rect2(x0, rect.position.y, maxf(0.0, x1 - x0), rect.size.y), fill, true)
	draw_arc(Vector2(x0, y), rr, PI * 0.5, PI * 1.5, 12, edge, 1.6, true)
	draw_arc(Vector2(x1, y), rr, -PI * 0.5, PI * 0.5, 12, edge, 1.6, true)
	draw_line(Vector2(x0, rect.position.y), Vector2(x1, rect.position.y), edge, 1.6, true)
	draw_line(Vector2(x0, rect.position.y + rect.size.y), Vector2(x1, rect.position.y + rect.size.y), edge, 1.6, true)


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
		var rad: float = outer if i % 2 == 0 else inner
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
	if i >= 0 and _atk_disp.has(i):
		atk = int(_atk_disp[i])
	var atk_d: int = int(pv.get("atk", 0))
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
	var fill: Color = ATK_FILL
	if bool(s.get("atk_variable", false)) or str(pv.get("mark", "")) == "spin" or (int(log_focus.get("wheel", -1)) == i and bool(log_focus.get("atk", false))):
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if atk_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif atk_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var punch: float = float(_atk_punch.get(i, 0.0)) if i >= 0 else 0.0
	if punch > 0.02:
		fill = fill.lerp(Color("ffd0a0"), punch * 0.55)
	var rad: float = 21.0 if big else 18.0
	if slices.size() >= 9:
		rad -= 1.0
	rad += punch * 4.0
	_draw_atk_badge(pos, rad, fill)
	if bool(s.get("cmd_buff", false)):
		draw_arc(pos, rad + 3.0, 0.0, TAU, 24, Color(0.95, 0.22, 0.16, 0.45 + 0.5 * pulse), 2.6, true)
	if int(s.get("copy_from", -1)) >= 0:
		draw_arc(pos, rad + 2.5, 0.0, TAU, 24, Color(0.72, 0.42, 0.92, 0.4 + 0.45 * pulse), 2.4, true)
	_draw_bold_num(font, pos + Vector2(0.0, 1.0), str(atk), 21 if big else 18, Color("f0e6d8"))
	if atk_d != 0:
		var dc: Color = UP_COL if atk_d > 0 else DOWN_COL
		draw_string(font, pos + Vector2(rad * 0.55, -rad * 0.7), _delta_text(atk_d), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, dc)
	if str(s.get("card_id", "")) == "hornet_swarm" or _queen_double(i):
		var inward: Vector2 = (_center() - pos)
		if inward.length() < 1.0:
			inward = Vector2(0, 1)
		var mark: Vector2 = pos + inward.normalized() * (rad + 10.0)
		var badge := Rect2(mark - Vector2(16.0, 8.0), Vector2(32.0, 16.0))
		draw_rect(badge, Color("1c120ce8"), true)
		draw_rect(badge, Color("e8c36a"), false, 1.5)
		_draw_outlined_string(font, mark + Vector2(0.0, 4.0), "×2", 12, Color("e8c36a"), Color("1c120c"))


func _draw_atk_badge(pos: Vector2, rad: float, fill: Color) -> void:
	var ink := Color("100e0c")
	var edge: Color = ATK_EDGE
	_fill_star(pos, rad * 1.22, rad * 0.46, ink)
	_fill_star(pos, rad * 1.08, rad * 0.40, fill)
	draw_arc(pos, rad * 0.52, 0.0, TAU, 22, edge, 2.2, true)
	draw_circle(pos, rad * 0.46, Color(fill.r, fill.g, fill.b, 0.96))
	draw_arc(pos, rad * 0.46, 0.0, TAU, 22, ink, 1.2, true)


func _fill_star(c: Vector2, outer: float, inner: float, col: Color, n: int = 8) -> void:
	var pts: PackedVector2Array = _star_pts(c, outer, inner, n)
	var count: int = pts.size()
	if count < 3:
		return
	for i in count:
		draw_colored_polygon(PackedVector2Array([c, pts[i], pts[(i + 1) % count]]), col)


func _draw_heart_stat(font: Font, pos: Vector2, s: Dictionary, pv: Dictionary, big: bool, i: int = -1) -> void:
	var hp: int = int(s.get("hp", 0)) + int(pv.get("hp", 0))
	if i >= 0 and _hp_disp.has(i):
		hp = int(_hp_disp[i])
	var hp_d: int = int(pv.get("hp", 0))
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
	var fill: Color = HP_FILL
	if bool(s.get("hp_variable", false)) or str(pv.get("mark", "")) == "spin" or (int(log_focus.get("wheel", -1)) == i and bool(log_focus.get("hp", false))):
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if hp_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif hp_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var punch: float = float(_hp_punch.get(i, 0.0)) if i >= 0 else 0.0
	if punch > 0.02:
		fill = fill.lerp(Color("ffd0a0"), punch * 0.55)
	var hs: float = 38.0 if big else 34.0
	if slices.size() >= 9:
		hs -= 2.0
	hs += punch * 10.0
	_draw_heart_shape(pos, hs, fill, Color("1c120c"))
	draw_circle(pos + Vector2(0.0, 4.0), hs * 0.28, Color("6a1818"))
	if punch > 0.35:
		var slash := Color("f0e6d8", punch * 0.85)
		var arm: float = hs * 0.42
		draw_line(pos + Vector2(-arm, -arm * 0.2), pos + Vector2(arm, arm * 0.55), Color("1c120c", punch), 4.2, true)
		draw_line(pos + Vector2(-arm, -arm * 0.2), pos + Vector2(arm, arm * 0.55), slash, 2.4, true)
	if bool(s.get("lich_buff", false)):
		var pulse2: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
		draw_arc(pos, hs * 0.52, 0.0, TAU, 20, Color(0.95, 0.88, 0.72, 0.4 + 0.5 * pulse2), 2.6, true)
	_draw_bold_num(font, pos + Vector2(0.0, 2.0), str(hp), 21 if big else 18, Color("f0e6d8"))
	if hp_d != 0:
		var dc: Color = UP_COL if hp_d > 0 else DOWN_COL
		draw_string(font, pos + Vector2(hs * 0.28, -hs * 0.38), _delta_text(hp_d), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, dc)



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
	var hub_r: float = radius * HUB_FRAC
	var bob: float = sin(_glow_t * 4.0) * 2.0
	var ppos: Vector2 = c + Vector2(0.0, -6.0 + bob) + hub_nudge
	var sting_tint := Color.WHITE
	if hub_sting > 0.02:
		if hub_sting_kind == "hurt":
			sting_tint = Color.WHITE.lerp(Color("e07a7a"), hub_sting * 0.85)
		else:
			sting_tint = Color.WHITE.lerp(Color("8ec8f0"), hub_sting * 0.7)
	if not tex_player.is_empty():
		var fi: int = int(_glow_t / 0.18) % tex_player.size()
		var tex: Texture2D = tex_player[fi]
		var psz := Vector2(56, 80)
		draw_texture_rect(tex, Rect2(ppos - psz * 0.5, psz), false, sting_tint)
	else:
		draw_circle(ppos, 16.0, Color("c4a574") * sting_tint)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var hp_pos: Vector2 = c + Vector2(-22.0, hub_r * 0.42)
	var hs: float = 32.0 + hub_hp_flash * 6.0
	var hp_fill: Color = HP_FILL
	if hub_hp_ghost >= 0 and hub_hp_ghost < hub_hp:
		hp_fill = hp_fill.lerp(Color("f0e6d8"), 0.35 + 0.25 * absf(sin(_glow_t * 12.0)))
	if bool(log_focus.get("hub_hp", false)):
		hp_fill = hp_fill.lerp(Color("fff0c0"), 0.4 + 0.3 * absf(sin(_glow_t * 8.0)))
		hs += 4.0
	_draw_heart_shape(hp_pos, hs, hp_fill, Color("1c120c"))
	_draw_bold_num(font, hp_pos + Vector2(0.0, 2.0), str(maxi(hub_hp, 0)), 18, Color("f0e6d8"))
	_draw_outlined_string(font, hp_pos + Vector2(0.0, 22.0), "HP", 11, Color("e8a0a0"), Color("100e0c"))
	var shown: int = hub_ghost if hub_ghost >= 0 else hub_blk
	var fill := Color("2a6aa8")
	var rim := Color("6bb3d9")
	if shown <= 0:
		fill = Color("1a3348")
		rim = Color("4a6a80")
	if hub_ghost >= 0 and hub_ghost > hub_blk:
		fill = Color("2a7a58")
		rim = Color("7dba7d")
	if bool(log_focus.get("hub_blk", false)):
		fill = fill.lerp(Color("fff0c0"), 0.35 + 0.25 * absf(sin(_glow_t * 8.0)))
		rim = Color("fff0c0")
	var scale: float = 1.0 + hub_flash * 0.28
	var shield_c: Vector2 = c + Vector2(24.0, hub_r * 0.42)
	var sw: float = 28.0 * scale
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
	_draw_outlined_string(font, shield_c + Vector2(0.0, sw * 0.92 + 8.0), "BLK", 11, Color("8ec8e8"), Color("100e0c"))
	if hub_pierce:
		var slash_a: float = 0.55 + 0.35 * absf(sin(_glow_t * 6.0))
		var slash := Color("e07a3d", slash_a)
		var a := shield_c + Vector2(-sw * 0.62, -sw * 0.55)
		var b := shield_c + Vector2(sw * 0.62, sw * 0.62)
		draw_line(a, b, Color("100e0c", slash_a), 5.0, true)
		draw_line(a, b, slash, 3.0, true)
		_draw_outlined_string(font, shield_c + Vector2(0.0, sw * 0.92 + 22.0), "IGNORED", 10, Color("e8c36a"), Color("100e0c"))
	if _hub_old_t > 0.0 and _hub_old != txt:
		var oc := Color(0.94, 0.90, 0.85, _hub_old_t)
		var osz: Vector2 = font.get_string_size(_hub_old, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
		draw_string(font, shield_c + Vector2(-osz.x * 0.5, 8.0 - (1.0 - _hub_old_t) * 16.0), _hub_old, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, oc)
	if hub_sting > 0.02:
		var ink: Color = Color("e07a7a") if hub_sting_kind == "hurt" else Color("5aa8e8")
		ink.a = hub_sting * 0.9
		var origin: Vector2 = ppos if hub_sting_kind == "hurt" else shield_c
		var burst: float = lerpf(22.0, 10.0, hub_sting)
		draw_arc(origin, burst * 0.55, 0.0, TAU, 18, Color(ink.r, ink.g, ink.b, hub_sting * 0.45), 2.0, true)
		for i in 6:
			var ang: float = float(i) * TAU / 6.0
			var inner: Vector2 = origin + Vector2.from_angle(ang) * burst * 0.22
			var outer: Vector2 = origin + Vector2.from_angle(ang) * burst
			draw_line(inner, outer, ink, 2.4, true)


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
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 14.0)
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
		var word: String = COPY.text("combat.blocked", "BLOCKED") if blocked else COPY.text("combat.slain", "SLAIN")
		var ta: float = clampf((slay_t - 0.18) / 0.45, 0.0, 1.0)
		var fs: int = 32
		var sz: Vector2 = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var banner := Rect2(pos + Vector2(-sz.x * 0.5 - 12.0, 28.0), Vector2(sz.x + 24.0, 38.0))
		var bg := Color("100e0ce8")
		bg.a *= ta
		var rim: Color = ink if blocked else FACE_RIM
		draw_rect(banner, bg, true)
		draw_rect(banner, Color(rim.r, rim.g, rim.b, ta), false, 2.0)
		draw_string(font, pos + Vector2(-sz.x * 0.5, 56.0), word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(rim.r, rim.g, rim.b, ta))
