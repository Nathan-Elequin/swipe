extends Control
class_name Dumbwaiter
## Left-wall dumbwaiter: 5 stops gate the biome pools. Session-only car park.


signal stop_chosen(pool: String)
signal tour_started
signal tour_finished
signal stop_hovered(pool: String, lit: bool)
signal stop_unhovered
signal lever_hovered
signal map_focus_wanted(pool: String)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0
## Room native placement.
const ORIGIN_N := Vector2(45, 38)
const SIZE_N := Vector2(28, 161)
const STOP_H_N := 25.0
const WELL_TOP_N := 20.0  ## local y of well start inside shaft
const CAR_SIZE_N := Vector2(16, 14)
const LAMP_SIZE_N := Vector2(6, 6)

var cabin = null
var input_enabled: bool = true
var busy: bool = false

var _lit: Array = [true, false, false, false, false]
var _park: int = 1  ## 1..5
var _car: TextureRect
var _tray: TextureRect
var _rope_l: ColorRect
var _rope_r: ColorRect
var _lever: AnimatedSprite2D
var _lever_hit: Control
var _stops: Array = []
var _lamps: Array = []
var _locks: Array = []
var _tabs: Array = []
var _sign: Label
var _tour_skip: bool = false
var _accents: Array = []


func setup(p_cabin, accents: Array = []) -> void:
	cabin = p_cabin
	_accents = accents
	name = "Dumbwaiter"
	position = ORIGIN_N * PX
	size = SIZE_N * PX
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 4
	_build()


func refresh(lit: Array, park: int) -> void:
	_lit = [false, false, false, false, false]
	for i in mini(5, lit.size()):
		_lit[i] = bool(lit[i])
	_park = clampi(park, 1, 5)
	_apply_lamps()
	_set_car_y(_car_y_for_stop(_park), false)


func light_stop(k: int, flare := true) -> void:
	k = clampi(k, 1, 5)
	_lit[k - 1] = true
	_apply_lamps()
	if flare and k - 1 < _lamps.size() and _lamps[k - 1] is CanvasItem:
		var lamp: CanvasItem = _lamps[k - 1]
		lamp.modulate = Color(1.6, 1.6, 1.6)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(lamp, "modulate", Color.WHITE, 0.3)


func ride_to(k: int) -> void:
	k = clampi(k, 1, 5)
	if busy:
		return
	busy = true
	await _lift_to(k)
	busy = false


func deepest_lit() -> int:
	var d := 1
	for i in 5:
		if _lit[i]:
			d = i + 1
	return d


func set_tray_tex(tex: Texture2D, silhouette := true) -> void:
	if _tray == null:
		return
	_tray.texture = tex
	_tray.visible = tex != null
	_tray.modulate = Color(0.09, 0.07, 0.06) if silhouette else Color.WHITE


func set_input_enabled(on: bool) -> void:
	input_enabled = on


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_stops.clear()
	_lamps.clear()
	_locks.clear()
	_tabs.clear()
	var shaft := TextureRect.new()
	shaft.name = "Shaft"
	shaft.texture = KIT.load_tex("hall/dumbwaiter_shaft")
	shaft.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shaft.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shaft.stretch_mode = TextureRect.STRETCH_SCALE
	shaft.position = Vector2.ZERO
	shaft.size = size
	shaft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if shaft.texture == null:
		var fb := ColorRect.new()
		fb.color = Color("4a2f1f")
		fb.size = size
		fb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fb)
		push_warning("Dumbwaiter missing hall/dumbwaiter_shaft.png")
	add_child(shaft)
	## Sign
	_sign = Label.new()
	_sign.name = "Sign"
	_sign.text = "LIFT"
	_sign.add_theme_font_size_override("font_size", 10)
	_sign.add_theme_color_override("font_color", Color("1e120c"))
	_sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sign.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sign.position = Vector2(2, 3) * PX
	_sign.size = Vector2(24, 8) * PX
	_sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sign)
	## Ropes
	_rope_l = ColorRect.new()
	_rope_l.name = "RopeL"
	_rope_l.color = Color("4a3020")
	_rope_l.size = Vector2(PX, 40)
	_rope_l.position = Vector2(13, 14) * PX  ## pulley x≈58-45=13 room-local
	_rope_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rope_l)
	_rope_r = ColorRect.new()
	_rope_r.name = "RopeR"
	_rope_r.color = Color("4a3020")
	_rope_r.size = Vector2(PX, 40)
	_rope_r.position = Vector2(20, 14) * PX
	_rope_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rope_r)
	## Car
	_car = TextureRect.new()
	_car.name = "Car"
	_car.texture = KIT.load_tex("hall/dumbwaiter_car")
	_car.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_car.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_car.stretch_mode = TextureRect.STRETCH_SCALE
	_car.size = CAR_SIZE_N * PX
	_car.position = Vector2(9, 0) * PX  ## x 54-45 = 9
	_car.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_car.z_index = 2
	add_child(_car)
	_tray = TextureRect.new()
	_tray.name = "Tray"
	_tray.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tray.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tray.stretch_mode = TextureRect.STRETCH_SCALE
	_tray.position = Vector2(3, 3) * PX
	_tray.size = Vector2(32, 32)  ## screen px silhouette
	_tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tray.visible = false
	_car.add_child(_tray)
	## Stops 1..5
	for k in range(1, 6):
		var stop := Control.new()
		stop.name = "Stop%d" % k
		## hit 112×100 px
		stop.size = Vector2(112, 100)
		var band_y := WELL_TOP_N + STOP_H_N * float(k - 1)
		stop.position = Vector2(0, band_y * PX + (STOP_H_N * PX - 100.0) * 0.5)
		stop.mouse_filter = Control.MOUSE_FILTER_STOP
		stop.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		stop.gui_input.connect(_on_stop_input.bind(k))
		stop.mouse_entered.connect(_on_stop_enter.bind(k))
		stop.mouse_exited.connect(func() -> void: stop_unhovered.emit())
		add_child(stop)
		_stops.append(stop)
		var lamp := TextureRect.new()
		lamp.name = "Lamp"
		lamp.texture = KIT.load_tex("hall/dumbwaiter_lamp_off")
		lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lamp.stretch_mode = TextureRect.STRETCH_SCALE
		lamp.size = LAMP_SIZE_N * PX
		## Lamp at room (46, 58+25(k-1)+9) → local (1, 20+25(k-1)+9)
		lamp.position = Vector2(1, WELL_TOP_N + STOP_H_N * float(k - 1) + 9.0) * PX - Vector2(0, 0)
		## Reparent under self at absolute local coords, not under stop.
		lamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lamp.z_index = 3
		add_child(lamp)
		_lamps.append(lamp)
		var lock := TextureRect.new()
		lock.name = "Lock"
		lock.texture = KIT.load_tex("cabinets/case_padlock")
		lock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_SCALE
		lock.size = Vector2(10, 12) * PX * 0.5
		lock.position = lamp.position + Vector2(2, 2)
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock.z_index = 4
		lock.visible = false
		add_child(lock)
		_locks.append(lock)
		var tab := TextureRect.new()
		tab.name = "Tab"
		tab.texture = KIT.load_tex("hall/dumbwaiter_tab")
		tab.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tab.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tab.stretch_mode = TextureRect.STRETCH_SCALE
		tab.size = Vector2(3, 4) * PX
		## Tab at room (70, 58+25(k-1)+19) → local (25, ...)
		tab.position = Vector2(25, WELL_TOP_N + STOP_H_N * float(k - 1) + 19.0) * PX
		tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tab.z_index = 3
		var accent := Color("7dae62")
		if k - 1 < _accents.size():
			accent = Color(str(_accents[k - 1]))
		elif k - 1 < BiomeCabinets.CASES.size():
			accent = Color(str((BiomeCabinets.CASES[k - 1] as Dictionary).get("accent", "7dae62")))
		tab.modulate = accent
		add_child(tab)
		_tabs.append(tab)
	## Lever
	_lever = AnimatedSprite2D.new()
	_lever.name = "Lever"
	_lever.centered = false
	_lever.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lever.position = Vector2(17, 143) * PX  ## local: room (62,181) - origin (45,38)
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", false)
	sf.add_animation("pull")
	sf.set_animation_loop("pull", false)
	sf.set_animation_speed("pull", 1000.0 / 80.0)
	for fi in 3:
		var t: Texture2D = KIT.load_tex("hall/dumbwaiter_lever_f%d" % fi)
		if t == null:
			continue
		if fi == 0:
			sf.add_frame("idle", t)
		sf.add_frame("pull", t)
	_lever.sprite_frames = sf
	_lever.play("idle")
	_lever.z_index = 4
	add_child(_lever)
	_lever_hit = Control.new()
	_lever_hit.name = "LeverHit"
	_lever_hit.position = Vector2(13, 141) * PX  ## hit native (58,179) - origin
	_lever_hit.size = Vector2(14, 20) * PX
	_lever_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	_lever_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_lever_hit.gui_input.connect(_on_lever_input)
	_lever_hit.mouse_entered.connect(func() -> void: lever_hovered.emit())
	_lever_hit.mouse_exited.connect(func() -> void: stop_unhovered.emit())
	_lever_hit.z_index = 5
	add_child(_lever_hit)
	_apply_lamps()
	_set_car_y(_car_y_for_stop(_park), false)


func _apply_lamps() -> void:
	for i in 5:
		var on: bool = bool(_lit[i]) if i < _lit.size() else false
		if i < _lamps.size() and _lamps[i] is TextureRect:
			(_lamps[i] as TextureRect).texture = KIT.load_tex("hall/dumbwaiter_lamp_on" if on else "hall/dumbwaiter_lamp_off")
		if i < _locks.size() and _locks[i] is CanvasItem:
			(_locks[i] as CanvasItem).visible = not on


func _car_y_for_stop(k: int) -> float:
	## Car bottom at ledge k → y = 58+25k−2−14 relative to room, local = that − 38
	## ledge room y = 58 + 25*k - 2; car top = ledge - 14
	## local y = (58 + 25*k - 2 - 14) - 38 = 4 + 25*k - 2? Let's compute:
	## well top room y = 38+20 = 58. ledge k room y = 58+25*k - 2
	## car top room y = ledge - 14 = 58+25*k - 16
	## car top local y = car_top_room - 38 = 20 + 25*k - 16 = 4 + 25*k
	## For k=1: 4+25=29 local → room 67. ledge1 = 58+25-2=81, car bottom=81, car top=67. Yes.
	return (4.0 + 25.0 * float(k)) * PX


func _set_car_y(y_px: float, resize_ropes := true) -> void:
	if _car == null:
		return
	var snapped: float = floor(y_px / PX) * PX
	_car.position.y = snapped
	if resize_ropes:
		_resize_ropes()


func _resize_ropes() -> void:
	if _rope_l == null or _car == null:
		return
	var pulley_y := 14.0 * PX
	var car_top := _car.position.y
	var h := maxf(PX, car_top - pulley_y)
	_rope_l.position.y = pulley_y
	_rope_l.size.y = h
	_rope_r.position.y = pulley_y
	_rope_r.size.y = h


func _lift_to(k: int) -> void:
	k = clampi(k, 1, 5)
	var from := _park
	var to := k
	if from == to:
		_park = to
		_set_car_y(_car_y_for_stop(_park), true)
		return
	var steps := absi(to - from)
	var from_y := _car_y_for_stop(from)
	var to_y := _car_y_for_stop(to)
	var dur := 0.14 * float(steps)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v: float) -> void:
		_set_car_y(v, true)
	, from_y, to_y, dur)
	## Pause briefly at intermediate ledges via parallel timers — approximate with total duration.
	await tw.finished
	_park = to
	_set_car_y(_car_y_for_stop(_park), true)


func _on_stop_enter(k: int) -> void:
	if not input_enabled:
		return
	var lit := k - 1 < _lit.size() and bool(_lit[k - 1])
	if lit and k - 1 < _lamps.size() and _lamps[k - 1] is CanvasItem:
		var lamp: CanvasItem = _lamps[k - 1]
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(lamp, "modulate", Color(1.3, 1.3, 1.3), 0.08)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
	stop_hovered.emit("b%d" % k, lit)


func _on_stop_input(event: InputEvent, k: int) -> void:
	if not input_enabled or busy:
		return
	if not (event is InputEventMouseButton and (event as InputEventMouseButton).pressed):
		return
	if (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
		return
	var lit := k - 1 < _lit.size() and bool(_lit[k - 1])
	if not lit:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.locked")
		_shake_lamp(k)
		accept_event()
		return
	busy = true
	await _lift_to(k)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	light_stop(k, true)
	stop_chosen.emit("b%d" % k)
	map_focus_wanted.emit("b%d" % k)
	busy = false
	accept_event()


func _shake_lamp(k: int) -> void:
	if k - 1 >= _lamps.size():
		return
	var lamp: Control = _lamps[k - 1]
	var base := lamp.position.x
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(lamp, "position:x", base + PX, 0.05)
	tw.tween_property(lamp, "position:x", base - PX, 0.05)
	tw.tween_property(lamp, "position:x", base, 0.05)


func _on_lever_input(event: InputEvent) -> void:
	if not input_enabled or busy:
		return
	if not (event is InputEventMouseButton and (event as InputEventMouseButton).pressed):
		return
	if (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	await _run_tour()


func _run_tour() -> void:
	busy = true
	_tour_skip = false
	tour_started.emit()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	if _lever and _lever.sprite_frames and _lever.sprite_frames.has_animation("pull"):
		_lever.play("pull")
	await _lift_to(1)
	var deep := deepest_lit()
	for k in range(1, deep + 1):
		if _tour_skip:
			break
		if not _lit[k - 1]:
			continue
		await _lift_to(k)
		light_stop(k, true)
		stop_chosen.emit("b%d" % k)
		if _tour_skip:
			break
		await get_tree().create_timer(0.5, true, true, true).timeout
	if _tour_skip:
		await _lift_to(deep)
	_park = deep
	map_focus_wanted.emit("b%d" % deep)
	if _lever:
		_lever.play("idle")
	busy = false
	tour_finished.emit()


func skip_tour() -> void:
	_tour_skip = true


func _gui_input(event: InputEvent) -> void:
	## Allow Esc / click to skip tour when bubbling from parent — handled by cabin.
	pass


func _unhandled_input(event: InputEvent) -> void:
	if not busy:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed):
		skip_tour()
