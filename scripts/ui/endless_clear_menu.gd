extends CanvasLayer
## Endless clear: gold ring + heart pop → +1 stamp → fly into HUD counter → title + Continue.
## ~2.0s. Any click/key skips to the settled end state. Tweens run while the tree is paused.

signal continue_pressed
signal tally_finished

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const FX_ONESHOT := preload("res://scripts/fx_oneshot.gd")
const GOLD := Color("e8c36a")
const CREAM := Color("f0e6d8")
const INK := Color("100e0c")

const PLUS_SIZE := 96
const COUNTER_SIZE := 64
const FLY_S := 0.55
const SEQ_TOTAL_S := 2.0

var _lock: Control
var _dim: ColorRect
var _title: Label
var _btn: Button
var _plus: Label
var _ring_fallback: Line2D
var _shake_host: Control
var _live: bool = false
var _seq: int = 0
var _playing: bool = false
var _settled: bool = false
var _sfx = null
var _hud = null
var _wheel = null
var _reduce_motion: bool = false
var _from_n: int = 1
var _to_n: int = 2
var _best: int = 0
var _new_best: bool = false
var _counter_applied: bool = false
var _title_rest_y: float = 0.0
var _btn_rest_y: float = 0.0
var _shake_tw: Tween
var _fly_tw: Tween
var _fly_start: Vector2 = Vector2.ZERO
var _fly_ctrl: Vector2 = Vector2.ZERO
var _fly_end: Vector2 = Vector2.ZERO
var _fly_start_scale: Vector2 = Vector2.ONE
var _fly_end_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	layer = 68
	name = "EndlessClearMenu"
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_process_input(true)
	_lock = Control.new()
	_lock.name = "Lock"
	_lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lock.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_lock)
	_shake_host = Control.new()
	_shake_host.name = "ShakeHost"
	_shake_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shake_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock.add_child(_shake_host)
	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.color = Color("100e0c", 0.35)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shake_host.add_child(_dim)
	_ring_fallback = Line2D.new()
	_ring_fallback.name = "RingFallback"
	_ring_fallback.width = 4.0
	_ring_fallback.default_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.0)
	_ring_fallback.visible = false
	_ring_fallback.z_index = 2
	_shake_host.add_child(_ring_fallback)
	_plus = Label.new()
	_plus.name = "PlusOne"
	_plus.text = "+1"
	_plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_plus.add_theme_font_override("font", ThemeDB.fallback_font)
	_plus.add_theme_font_size_override("font_size", PLUS_SIZE)
	_plus.add_theme_color_override("font_color", GOLD)
	_plus.add_theme_color_override("font_outline_color", INK)
	_plus.add_theme_constant_override("outline_size", 10)
	_plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plus.visible = false
	_plus.z_index = 8
	_shake_host.add_child(_plus)
	_title = Label.new()
	_title.name = "Title"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_override("font", ThemeDB.fallback_font)
	_title.add_theme_font_size_override("font_size", 36)
	_title.add_theme_color_override("font_color", CREAM)
	_title.add_theme_color_override("font_outline_color", INK)
	_title.add_theme_constant_override("outline_size", 6)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shake_host.add_child(_title)
	_btn = KIT.choice_tag("endless.clear.continue", Vector2(120, 18))
	_btn.name = "Continue"
	_btn.pressed.connect(_on_continue)
	_shake_host.add_child(_btn)
	_title.modulate.a = 0.0
	_btn.modulate.a = 0.0
	_btn.disabled = true


func bind_host(sfx, hud, wheel) -> void:
	_sfx = sfx
	_hud = hud
	_wheel = wheel


## Play the tally sequence, then leave Continue armed. Awaits until settled (or skip).
func open_menu(opts: Dictionary = {}) -> void:
	_seq += 1
	var my: int = _seq
	_from_n = int(opts.get("from_n", 1))
	_to_n = int(opts.get("to_n", _from_n + 1))
	_best = int(opts.get("best", 0))
	_new_best = bool(opts.get("new_best", _to_n > _best))
	_reduce_motion = bool(opts.get("reduce_motion", false))
	if opts.has("sfx"):
		_sfx = opts.get("sfx")
	if opts.has("hud"):
		_hud = opts.get("hud")
	if opts.has("wheel"):
		_wheel = opts.get("wheel")
	_counter_applied = false
	_settled = false
	_playing = true
	_live = false
	_title.text = COPY.text("endless.clear.title", "You cleared this dungeon.")
	if _btn:
		_btn.text = COPY.text("endless.clear.continue", "Continue")
		_btn.disabled = true
		_btn.modulate.a = 0.0
	_title.modulate.a = 0.0
	_plus.visible = false
	_plus.modulate.a = 1.0
	_plus.scale = Vector2.ONE
	_plus.add_theme_font_size_override("font_size", PLUS_SIZE)
	visible = true
	await _wait_frames(2)
	if my != _seq:
		return
	_layout_center_sync()
	if _hud != null and _hud.has_method("hold_floor"):
		_hud.hold_floor(_from_n, _best)
	await _run_sequence(my)
	if my != _seq:
		return
	_finish_settle()


func hide_menu() -> void:
	_seq += 1
	_live = false
	_playing = false
	_settled = false
	visible = false
	if _btn:
		_btn.disabled = true
	if _fly_tw:
		_fly_tw.kill()
		_fly_tw = null
	if _shake_tw:
		_shake_tw.kill()
		_shake_tw = null
	_plus.visible = false
	_ring_fallback.visible = false


func is_settled() -> bool:
	return _settled and visible


func title_center_x() -> float:
	if _title == null:
		return 0.0
	return _title.get_global_rect().get_center().x


func continue_center_x() -> float:
	if _btn == null:
		return 0.0
	return _btn.get_global_rect().get_center().x


func viewport_center_x() -> float:
	var vr: Rect2 = get_viewport().get_visible_rect()
	return vr.position.x + vr.size.x * 0.5


func counter_applied_once() -> bool:
	return _counter_applied


func _input(event: InputEvent) -> void:
	if not visible or not _playing or _settled:
		return
	var skip := false
	if event is InputEventMouseButton and event.pressed:
		skip = true
	elif event is InputEventKey and event.pressed and not event.echo:
		skip = true
	elif event is InputEventScreenTouch and event.pressed:
		skip = true
	if skip:
		_seq += 1
		_finish_settle()
		get_viewport().set_input_as_handled()


func _on_continue() -> void:
	if not _live:
		return
	_live = false
	continue_pressed.emit()


func _layout_center_sync() -> void:
	var vr: Rect2 = get_viewport().get_visible_rect()
	var w: float = maxf(vr.size.x, 1.0)
	var h: float = maxf(vr.size.y, 1.0)
	var title_w: float = minf(1000.0, w * 0.7)
	_title.size = Vector2(title_w, 56.0)
	if _btn:
		_btn.reset_size()
	var btn_w: float = _btn.size.x if _btn else 480.0
	_title_rest_y = h * 0.42
	_btn_rest_y = _title_rest_y + 56.0 + 24.0
	_title.position = Vector2((w - title_w) * 0.5, _title_rest_y)
	_btn.position = Vector2((w - btn_w) * 0.5, _btn_rest_y)


func _run_sequence(my: int) -> void:
	## t=0 ring + hearts
	_play_sfx(&"endless.clear_ring")
	_pulse_ring_and_hearts()
	if _reduce_motion:
		await _wait_s(0.08)
		if my != _seq:
			return
		_stamp_plus(false)
		await _wait_s(0.12)
		if my != _seq:
			return
		await _fly_or_fade(my)
		if my != _seq:
			return
		await _reveal_chrome(my)
		return
	await _wait_s(0.25)
	if my != _seq:
		return
	## t=0.25 stamp
	_stamp_plus(true)
	await _wait_s(0.45)
	if my != _seq:
		return
	## t=0.7 fly
	await _fly_or_fade(my)
	if my != _seq:
		return
	## land ~1.25; chrome at 1.4 → wait remaining
	await _wait_s(0.15)
	if my != _seq:
		return
	await _reveal_chrome(my)
	## pad to ~2.0s total feel (chrome fade ~0.35)
	await _wait_s(0.25)


func _pulse_ring_and_hearts() -> void:
	var drove := false
	if _wheel != null and _wheel.has_method("pulse_endless_clear_tally"):
		_wheel.pulse_endless_clear_tally(_reduce_motion)
		drove = true
	if not drove:
		_pulse_fallback_ring()
	_play_gold_ring_pulse()


func _play_gold_ring_pulse() -> void:
	## One-shot gold ring behind +1; keeps Label `_plus` and timings intact.
	var frames: Array = []
	for i in 7:
		var path := "res://assets/ui/endless/gold_ring_pulse_f%d.png" % i
		if not ResourceLoader.exists(path):
			break
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			frames.append(tex)
	if frames.is_empty() or _shake_host == null:
		return
	var center: Vector2 = _hero_global()
	var spr: AnimatedSprite2D = FX_ONESHOT.play(_shake_host, frames, center, 3.0, 12.0, false, 6)
	if spr:
		spr.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _pulse_fallback_ring() -> void:
	var center := _hero_global()
	var local: Vector2 = _shake_host.get_global_transform_with_canvas().affine_inverse() * center
	_ring_fallback.clear_points()
	var r0: float = 78.0
	for i in 48:
		var a: float = TAU * float(i) / 48.0
		_ring_fallback.add_point(local + Vector2.from_angle(a) * r0)
	_ring_fallback.visible = true
	_ring_fallback.default_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.85)
	_ring_fallback.width = 5.0
	_ring_fallback.scale = Vector2.ONE
	_ring_fallback.position = Vector2.ZERO
	## Line2D scale from first point — move via modulate/width tween instead.
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(_set_fallback_ring_radius.bind(local), r0, r0 * 1.06, 0.12)
	tw.tween_method(_set_fallback_ring_radius.bind(local), r0 * 1.06, r0, 0.14)
	tw.parallel().tween_property(_ring_fallback, "default_color:a", 0.0, 0.28).set_delay(0.12)
	tw.tween_callback(_hide_fallback_ring)


func _hide_fallback_ring() -> void:
	_ring_fallback.visible = false


func _set_fallback_ring_radius(radius: float, local: Vector2) -> void:
	_ring_fallback.clear_points()
	for i in 48:
		var a: float = TAU * float(i) / 48.0
		_ring_fallback.add_point(local + Vector2.from_angle(a) * radius)


func _stamp_plus(do_shake: bool) -> void:
	_play_sfx(&"endless.plus_stamp")
	var vr: Rect2 = get_viewport().get_visible_rect()
	var sz := Vector2(220, 120)
	_plus.size = sz
	_plus.pivot_offset = sz * 0.5
	_plus.position = Vector2(vr.size.x * 0.5 - sz.x * 0.5, vr.size.y * 0.5 - sz.y * 0.5)
	_plus.visible = true
	_plus.modulate.a = 1.0
	_plus.scale = Vector2(1.6, 1.6)
	_plus.add_theme_font_size_override("font_size", PLUS_SIZE)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_plus, "scale", Vector2.ONE, 0.22)
	if do_shake and not _reduce_motion:
		_shake_screen(4.0, 0.12)


func _fly_or_fade(my: int) -> void:
	if _reduce_motion:
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(_plus, "modulate:a", 0.0, 0.18)
		await tw.finished
		if my != _seq:
			return
		_plus.visible = false
		_apply_counter_tick()
		return
	_play_sfx(&"endless.plus_fly")
	_fly_start = _plus.position + _plus.pivot_offset
	_fly_end = _counter_target_local()
	_fly_ctrl = Vector2((_fly_start.x + _fly_end.x) * 0.5, minf(_fly_start.y, _fly_end.y) - 160.0)
	_fly_start_scale = Vector2.ONE
	_fly_end_scale = Vector2(float(COUNTER_SIZE) / float(PLUS_SIZE), float(COUNTER_SIZE) / float(PLUS_SIZE))
	if _fly_tw:
		_fly_tw.kill()
	_fly_tw = create_tween()
	_fly_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fly_tw.set_trans(Tween.TRANS_QUAD)
	_fly_tw.set_ease(Tween.EASE_IN_OUT)
	_fly_tw.tween_method(_update_plus_fly, 0.0, 1.0, FLY_S)
	await _fly_tw.finished
	if my != _seq:
		return
	_plus.visible = false
	_apply_counter_tick()


func _update_plus_fly(t: float) -> void:
	var p: Vector2 = _quad_bezier(_fly_start, _fly_ctrl, _fly_end, t)
	_plus.position = p - _plus.pivot_offset
	_plus.scale = _fly_start_scale.lerp(_fly_end_scale, t)


func _apply_counter_tick() -> void:
	if _counter_applied:
		return
	_counter_applied = true
	_play_sfx(&"endless.counter_tick")
	if _new_best:
		_play_sfx(&"endless.new_best")
	if _hud != null and _hud.has_method("receive_tally"):
		_hud.receive_tally(_to_n, maxi(_best, _to_n), _new_best, _reduce_motion)


func _reveal_chrome(my: int) -> void:
	_play_sfx(&"ui.continue_appear")
	_layout_center_sync()
	_title.modulate.a = 0.0
	_title.position.y = _title_rest_y + 12.0
	_btn.modulate.a = 0.0
	_btn.position.y = _btn_rest_y
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_title, "modulate:a", 1.0, 0.22)
	tw.parallel().tween_property(_title, "position:y", _title_rest_y, 0.22)
	tw.tween_property(_btn, "modulate:a", 1.0, 0.2)
	await tw.finished
	if my != _seq:
		return


func _finish_settle() -> void:
	if _fly_tw:
		_fly_tw.kill()
		_fly_tw = null
	if _shake_tw:
		_shake_tw.kill()
		_shake_tw = null
		_shake_host.position = Vector2.ZERO
	_ring_fallback.visible = false
	_plus.visible = false
	if not _counter_applied:
		_apply_counter_tick()
	_layout_center_sync()
	_title.modulate.a = 1.0
	_title.position.y = _title_rest_y
	_btn.modulate.a = 1.0
	_btn.position.y = _btn_rest_y
	_btn.disabled = false
	_playing = false
	_settled = true
	_live = true
	tally_finished.emit()


func _hero_global() -> Vector2:
	if _wheel != null:
		if _wheel.has_method("hub_center_global"):
			return _wheel.hub_center_global()
		if _wheel.has_method("hub_hearts_global"):
			return _wheel.hub_hearts_global() + Vector2(0, 40)
	var vr: Rect2 = get_viewport().get_visible_rect()
	return vr.get_center()


func _counter_target_local() -> Vector2:
	var target := Vector2.ZERO
	if _hud != null and _hud.has_method("counter_global_center"):
		target = _hud.counter_global_center()
	else:
		var vr: Rect2 = get_viewport().get_visible_rect()
		target = Vector2(vr.size.x - 160.0, 68.0)
	return _shake_host.get_global_transform_with_canvas().affine_inverse() * target


func _quad_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return u * u * a + 2.0 * u * t * b + t * t * c


func _shake_screen(px: float, dur: float) -> void:
	if _shake_tw:
		_shake_tw.kill()
	_shake_host.position = Vector2.ZERO
	_shake_tw = create_tween()
	_shake_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var steps: int = maxi(2, int(dur / 0.03))
	for i in steps:
		var amp: float = px * (1.0 - float(i) / float(steps))
		var off := Vector2(amp if i % 2 == 0 else -amp, amp * 0.35 if i % 2 == 0 else -amp * 0.35)
		_shake_tw.tween_property(_shake_host, "position", off, dur / float(steps))
	_shake_tw.tween_property(_shake_host, "position", Vector2.ZERO, 0.02)


func _play_sfx(cue: StringName) -> void:
	if _sfx == null:
		return
	if _sfx.has_method("play_event"):
		_sfx.play_event(cue)
	elif _sfx.has_method("play"):
		_sfx.play(String(cue), -8.0)


func _wait_s(sec: float) -> void:
	if sec <= 0.0:
		return
	await get_tree().create_timer(sec, true, true, true).timeout


func _wait_frames(n: int) -> void:
	for _i in n:
		await get_tree().process_frame
