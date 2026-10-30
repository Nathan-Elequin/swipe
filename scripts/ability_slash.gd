extends Control
## Monster cut-in (full-screen diagonal band) + item gutter banner. Queued: play → _drain → _show.

const FX_RAYS := preload("res://scripts/fx_rays.gd")
const SLASH_SHADER := preload("res://shaders/slash_lines.gdshader")
const CIRCLE_TEX := preload("res://assets/dungeon/vfx/circle.png")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")
const FRAME_METRICS := preload("res://scripts/frame_metrics.gd")

const VIEW_W := 1680.0
const VIEW_H := 1040.0
const SNAP_MS := 120.0
const FRAME_MS := 70.0
const HOLD_MS := 120.0
const FIRST_HOLD_BONUS_MS := 250.0
const OUT_MS := 160.0
const PORTRAIT_TRAIL_MS := 40.0
## Item gutter banner (seconds). Shorter than the old 0.12/0.38/0.16 chain so
## use→resolve does not sit on a padded hold before numbers change.
const ITEM_IN_S := 0.09
const ITEM_HOLD_S := 0.22
const ITEM_OUT_S := 0.11
const ITEM_FAST_IN_S := 0.05
const ITEM_FAST_HOLD_S := 0.14
const ITEM_FAST_OUT_S := 0.07
const ITEM_CANT_FLEE_HOLD_S := 0.45
## Extra cut-in line (Plague Doctor freeze tell): white on black, 1s dissolve.
const LINE_DISSOLVE_MS := 1000.0
## Native canvases are 32/48/64/80. Show at 4x unless that exceeds 64px@4x (band fit).
const PORTRAIT_SCALE := 4.0
const PORTRAIT_MAX_DISPLAY := 256.0

var art
var cascade_ticker
var _q: Array = []
var _draining: bool = false
var _aborted: bool = false
var _tw: Tween
var _life: float = 0.0:
	set(v):
		if is_equal_approx(_life, v):
			return
		_life = v
		# Item gutter: mark dirty; paced `_process` redraws (avoid every-tween
		# + every-process double churn during attack_x5 slash banners).
		_slash_dirty = true
var _clock: float = 0.0
var _tex: Texture2D
var _title: String = ""
var _call: String = ""
var _line: String = ""
var _is_item: bool = false
var log_glow: bool = false
var card_id: String = ""
var _slash_seen: Dictionary = {}
var _gutter_size: Vector2 = Vector2(252, 200)
var _gutter_pos: Vector2 = Vector2.ZERO
var _cutin_active: bool = false
var _frame_texs: Array = []
var _frame_i: int = 0
var _shake: Vector2 = Vector2.ZERO
var _ff_holds: bool = false
var _slash_dirty: bool = false
var _slash_wait: float = 0.0

var _dim: ColorRect
var _band_host: Node2D
var _half_a: Polygon2D
var _half_b: Polygon2D
var _edge_top: Line2D
var _edge_bot: Line2D
var _flash: Sprite2D
var _portrait: Sprite2D
var _name_lbl: Label
var _call_lbl: Label
var _line_host: Control
var _line_bg: ColorRect
var _line_lbl: Label
var _cut: Line2D
var _band_mat: ShaderMaterial
## Portrait+band cluster used to sit at (750, 610). Shift so that point lands on the wheel.
var wheel_center: Vector2 = Vector2(750, 480)


func setup(p_art) -> void:
	art = p_art
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 14
	top_level = true
	visible = false
	texture_filter = TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(252, 200)
	size = Vector2(252, 200)
	set_process(true)
	_build_cutin_nodes()
	_set_cutin_visible(false)


func reset_slash_seen() -> void:
	_slash_seen.clear()


func mark_slash_seen(id: String) -> void:
	var key := str(id).strip_edges()
	if key != "":
		_slash_seen[key] = true


func is_busy() -> bool:
	return _draining


func park_gutter(sz: Vector2, pos: Vector2) -> void:
	_gutter_size = sz
	_gutter_pos = pos


func set_log_glow(on: bool) -> void:
	log_glow = on
	_slash_dirty = true


func set_fast_holds(on: bool) -> void:
	## Holds stay on Engine.time_scale; flag is for callers that want a shorter hold
	## without stacking another /3 on top of time_scale=3.
	_ff_holds = on


func abort_all() -> void:
	_aborted = true
	_q.clear()
	_draining = false
	if _tw != null and is_instance_valid(_tw):
		_tw.kill()
	_tw = null
	visible = false


func play(payload: Dictionary) -> void:
	_aborted = false
	var ticket := {"payload": payload, "done": false}
	_q.append(ticket)
	# Always wait on this ticket. Item banners may mark done after snap-in
	# (release_early) so resolve can overlap hold/fade. Monster cut-ins may
	# also release_early after the portrait tell (punch/frames) so passive
	# damage overlaps hold/slash-out.
	if not _draining:
		_drain()
	while is_instance_valid(self) and not bool(ticket.get("done", false)) and not _aborted:
		await get_tree().process_frame


func _drain() -> void:
	_draining = true
	FX_BUDGET.begin_heavy()
	while not _q.is_empty() and not _aborted:
		var t: Dictionary = _q.pop_front()
		await _show(t.get("payload", {}), t)
		t["done"] = true
	FX_BUDGET.end_heavy()
	_draining = false
	if _aborted:
		_q.clear()


func _dur(ms: float, fast: bool) -> float:
	var sec: float = ms / 1000.0
	if fast:
		return sec / 3.0
	return sec


func _show(payload: Dictionary, ticket: Dictionary = {}) -> void:
	if OS.has_feature("editor"):
		print("[resolve] slash.show ", payload.get("card_id", ""), " tex=", payload.get("tex", null) != null)
	_tex = payload.get("tex", null)
	_title = str(payload.get("title", "")).strip_edges()
	_call = str(payload.get("call", "")).strip_edges()
	_line = str(payload.get("line", "")).strip_edges()
	_is_item = bool(payload.get("is_item", false))
	card_id = str(payload.get("card_id", ""))
	var ticket_i: int = int(payload.get("ticket", -1))
	if card_id == "triclops" and _call == "":
		_call = "Cut And Run"
	if _title == "" and _call == "" and _tex == null:
		_ticker_stamp(ticket_i)
		return
	if ticket_i >= 0 and cascade_ticker != null and cascade_ticker.has_method("light"):
		cascade_ticker.light(ticket_i)
	if _tw != null and is_instance_valid(_tw):
		_tw.kill()
	visible = true
	_life = 0.0
	_slash_dirty = true
	_slash_wait = 0.0
	_clock = 0.0
	log_glow = false
	_shake = Vector2.ZERO
	# time_scale already speeds the cascade; do not also divide holds by 3 while FF.
	var fast: bool = bool(payload.get("fast", false)) and not _ff_holds
	var release_early: bool = bool(payload.get("release_early", false))
	if _is_item:
		await _show_item(fast, release_early, ticket)
	else:
		await _show_cutin(fast, release_early, ticket)
	visible = false
	_cutin_active = false
	_set_cutin_visible(false)
	_ticker_stamp(ticket_i)
	card_id = ""
	_tex = null
	_title = ""
	_call = ""
	_line = ""
	_frame_texs.clear()
	_slash_dirty = false
	_slash_wait = 0.0
	queue_redraw()


func _ticker_stamp(ticket_i: int) -> void:
	if ticket_i < 0 or cascade_ticker == null:
		return
	if cascade_ticker.has_method("stamp"):
		cascade_ticker.stamp(ticket_i)


func _show_item(fast: bool, release_early: bool = false, ticket: Dictionary = {}) -> void:
	_cutin_active = false
	_set_cutin_visible(false)
	size = _gutter_size if _gutter_size.x >= 32.0 else Vector2(252, 200)
	global_position = _gutter_pos
	if size.x < 32.0 or size.y < 32.0:
		size = Vector2(252, 200)
	var snap: float = ITEM_FAST_IN_S if fast else ITEM_IN_S
	var hold: float = ITEM_CANT_FLEE_HOLD_S if _call == "Can't Flee" else (ITEM_FAST_HOLD_S if fast else ITEM_HOLD_S)
	var fade: float = ITEM_FAST_OUT_S if fast else ITEM_OUT_S
	# Snap in first so callers with release_early can apply the item effect
	# while the banner still holds/fades (use→resolve wall-clock).
	_tw = create_tween()
	_tw.tween_property(self, "_life", 1.0, snap).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	while _tw != null and _tw.is_valid() and _tw.is_running() and not _aborted:
		await get_tree().process_frame
	if _aborted:
		return
	if release_early and not ticket.is_empty():
		ticket["done"] = true
	_tw = create_tween()
	_tw.tween_interval(hold)
	_tw.tween_property(self, "_life", 0.0, fade).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	while _tw != null and _tw.is_valid() and _tw.is_running() and not _aborted:
		await get_tree().process_frame


func _show_cutin(fast: bool, release_early: bool = false, ticket: Dictionary = {}) -> void:
	_cutin_active = true
	size = Vector2(VIEW_W, VIEW_H)
	global_position = Vector2.ZERO
	_set_cutin_visible(true)
	_life = 1.0
	_prepare_band()
	_prepare_flash()
	_prepare_labels()
	_prepare_portrait()
	var first: bool = card_id != "" and not bool(_slash_seen.get(card_id, false))
	if card_id != "":
		_slash_seen[card_id] = true
	var axis: Vector2 = Vector2(1760.0, -370.0).normalized()
	var start_off: Vector2 = -axis * 1900.0
	_band_host.position = start_off
	_band_host.modulate = Color(1, 1, 1, 1)
	_half_a.position = Vector2.ZERO
	_half_b.position = Vector2.ZERO
	_half_a.modulate.a = 1.0
	_half_b.modulate.a = 1.0
	_half_b.visible = false
	_edge_top.visible = true
	_edge_bot.visible = true
	_cut.visible = false
	_cut.modulate.a = 0.0
	_dim.modulate.a = 0.0
	_flash.modulate.a = 0.0
	_portrait.modulate.a = 0.0
	_portrait.position = _portrait_center() + start_off
	_name_lbl.modulate.a = 0.0
	_call_lbl.modulate.a = 0.0
	if _line_host:
		_line_host.modulate.a = 0.0
	if _band_mat != null:
		_band_mat.set_shader_parameter("split", 0.0)
		_band_mat.set_shader_parameter("alpha", 1.0)
		_band_mat.set_shader_parameter("speed", 2.2 if not fast else 4.5)
	var use_frames: bool = not _frame_texs.is_empty()
	var target_scale: float = _portrait_scale_for(_portrait.texture)
	if use_frames:
		_portrait.scale = _portrait_scale_vec(target_scale)
	else:
		var punch_start: float = target_scale * (3.6 / PORTRAIT_SCALE)
		_portrait.scale = _portrait_scale_vec(punch_start)
	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_property(_dim, "modulate:a", 0.47, _dur(SNAP_MS, fast))
	_tw.tween_property(_band_host, "position", Vector2.ZERO, _dur(SNAP_MS, fast)).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_tw.tween_property(_flash, "modulate:a", 0.55, _dur(SNAP_MS, fast))
	_tw.tween_property(_name_lbl, "modulate:a", 1.0, _dur(SNAP_MS, fast))
	_tw.tween_property(_call_lbl, "modulate:a", 1.0, _dur(SNAP_MS, fast))
	if _line != "" and _line_host:
		_tw.tween_property(_line_host, "modulate:a", 1.0, _dur(SNAP_MS, fast))
	# Portrait trails the band by 40ms; action frames still start at SNAP_MS.
	_tw.tween_property(_portrait, "position", _portrait_center(), _dur(SNAP_MS, fast)).set_delay(_dur(PORTRAIT_TRAIL_MS, fast)).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_tw.tween_property(_portrait, "modulate:a", 1.0, _dur(SNAP_MS, fast)).set_delay(_dur(PORTRAIT_TRAIL_MS, fast))
	if not use_frames:
		_tw.tween_property(_portrait, "scale", _portrait_scale_vec(target_scale), _dur(SNAP_MS + 80.0, fast)).set_delay(_dur(PORTRAIT_TRAIL_MS, fast)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(_dur(SNAP_MS, fast), false).timeout
	# Action: frames or still shake (band is already in).
	# Copy the list first. Awaits yield, and a later slash / script reload
	# can shrink `_frame_texs` while this loop still has the old count.
	if use_frames:
		var frames: Array = _frame_texs.duplicate()
		if _portrait:
			_portrait.hframes = 1
			_portrait.vframes = 1
			_portrait.frame = 0
		for i in range(frames.size()):
			if i < 0 or i >= frames.size():
				break
			var tex: Variant = frames[i]
			if not (tex is Texture2D) or tex == null:
				continue
			_frame_i = i
			_portrait.texture = tex
			await get_tree().create_timer(_dur(FRAME_MS, fast), false).timeout
	else:
		await _punch_shake(fast)
	# Portrait tell is up — let passives apply damage during hold/slash-out
	# (same wall-clock idea as item gutter release_early after snap-in).
	if release_early and not ticket.is_empty():
		ticket["done"] = true
	var hold_ms: float = HOLD_MS + (FIRST_HOLD_BONUS_MS if first else 0.0)
	if _line != "" and _line_host:
		hold_ms = maxf(hold_ms, LINE_DISSOLVE_MS)
		var line_tw := create_tween()
		line_tw.tween_property(_line_host, "modulate:a", 0.0, _dur(LINE_DISSOLVE_MS, fast)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(_dur(hold_ms, fast), false).timeout
	# Slash out.
	_prepare_cut_line()
	_cut.visible = true
	_cut.modulate.a = 0.8
	await get_tree().process_frame
	_split_band_halves()
	var perp: Vector2 = Vector2(-axis.y, axis.x) * 60.0
	if _tw != null and is_instance_valid(_tw):
		_tw.kill()
	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_property(_half_a, "position", -perp, _dur(OUT_MS, fast)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tw.tween_property(_half_b, "position", perp, _dur(OUT_MS, fast)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tw.tween_property(_half_a, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_half_b, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_edge_top, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_edge_bot, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_dim, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_flash, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_portrait, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_name_lbl, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_call_lbl, "modulate:a", 0.0, _dur(OUT_MS, fast))
	if _line_host:
		_tw.tween_property(_line_host, "modulate:a", 0.0, _dur(OUT_MS, fast))
	_tw.tween_property(_cut, "modulate:a", 0.0, _dur(OUT_MS * 0.6, fast))
	if _band_mat != null:
		_tw.tween_method(func(v: float) -> void: _band_mat.set_shader_parameter("split", v), 0.0, 1.0, _dur(OUT_MS, fast))
	while _tw != null and _tw.is_valid() and _tw.is_running() and not _aborted:
		await get_tree().process_frame


func _punch_shake(fast: bool) -> void:
	var n: int = 6
	var step: float = _dur(FRAME_MS, fast) * 0.55
	for i in n:
		_shake = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
		_portrait.position = _portrait_center() + _shake
		await get_tree().create_timer(step, false).timeout
	_shake = Vector2.ZERO
	_portrait.position = _portrait_center()


func _portrait_faces_left() -> bool:
	return art != null and card_id != "" and art.has_method("monster_flip_h") and art.monster_flip_h(card_id, "L")


func _portrait_scale_vec(mag: float) -> Vector2:
	var x: float = -mag if _portrait_faces_left() else mag
	return Vector2(x, mag)


func _portrait_scale_for(tex: Texture2D) -> float:
	if tex == null:
		return PORTRAIT_SCALE
	var native_max: float = maxf(float(tex.get_width()), float(tex.get_height()))
	if native_max <= 0.0:
		return PORTRAIT_SCALE
	var at4: float = native_max * PORTRAIT_SCALE
	if at4 <= PORTRAIT_MAX_DISPLAY:
		return PORTRAIT_SCALE
	return PORTRAIT_MAX_DISPLAY / native_max


func _cutin_shift() -> Vector2:
	return wheel_center - Vector2(750.0, 610.0)


func _portrait_center() -> Vector2:
	var tex: Texture2D = _portrait.texture
	var native: Vector2 = Vector2(48, 48)
	if tex != null:
		native = Vector2(tex.get_width(), tex.get_height())
	var s: float = _portrait_scale_for(tex)
	var origin := Vector2(750.0, 610.0) + _cutin_shift() - native * (s * 0.5)
	if _portrait_faces_left():
		origin.x += native.x * s
	return origin


func _build_cutin_nodes() -> void:
	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.color = Color(0, 0, 0, 1)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.modulate.a = 0.0
	add_child(_dim)
	_band_host = Node2D.new()
	_band_host.name = "BandHost"
	add_child(_band_host)
	_band_mat = ShaderMaterial.new()
	_band_mat.shader = SLASH_SHADER
	_half_a = Polygon2D.new()
	_half_a.name = "Band"
	_half_a.color = Color(1, 1, 1, 1)
	_half_a.material = _band_mat
	_band_host.add_child(_half_a)
	_half_b = Polygon2D.new()
	_half_b.name = "BandB"
	_half_b.color = Color(1, 1, 1, 1)
	_half_b.material = _band_mat
	_half_b.visible = false
	_band_host.add_child(_half_b)
	_edge_top = Line2D.new()
	_edge_top.name = "EdgeTop"
	_edge_top.width = 6.0
	_edge_top.default_color = Color("e8c36a")
	_edge_top.antialiased = true
	_band_host.add_child(_edge_top)
	_edge_bot = Line2D.new()
	_edge_bot.name = "EdgeBot"
	_edge_bot.width = 4.0
	_edge_bot.default_color = Color("e8c36a")
	_edge_bot.antialiased = true
	_band_host.add_child(_edge_bot)
	_flash = Sprite2D.new()
	_flash.name = "Flash"
	_flash.texture = CIRCLE_TEX
	_flash.centered = true
	_flash.texture_filter = TEXTURE_FILTER_NEAREST
	_flash.z_index = 1
	add_child(_flash)
	_portrait = Sprite2D.new()
	_portrait.name = "Portrait"
	_portrait.centered = false
	_portrait.texture_filter = TEXTURE_FILTER_NEAREST
	_portrait.z_index = 2
	add_child(_portrait)
	_name_lbl = Label.new()
	_name_lbl.name = "Name"
	_name_lbl.add_theme_font_size_override("font_size", 34)
	_name_lbl.add_theme_color_override("font_color", Color("f0e6d8"))
	_name_lbl.add_theme_color_override("font_outline_color", Color(0.06, 0.05, 0.04, 1))
	_name_lbl.add_theme_constant_override("outline_size", 3)
	_name_lbl.position = Vector2(1000, 555)
	_name_lbl.z_index = 3
	add_child(_name_lbl)
	_call_lbl = Label.new()
	_call_lbl.name = "Call"
	_call_lbl.add_theme_font_size_override("font_size", 44)
	_call_lbl.add_theme_color_override("font_color", Color("e8c36a"))
	_call_lbl.add_theme_color_override("font_outline_color", Color(0.06, 0.05, 0.04, 1))
	_call_lbl.add_theme_constant_override("outline_size", 3)
	_call_lbl.position = Vector2(1000, 598)
	_call_lbl.z_index = 3
	add_child(_call_lbl)
	_line_host = Control.new()
	_line_host.name = "Line"
	_line_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_line_host.z_index = 3
	_line_host.visible = false
	add_child(_line_host)
	_line_bg = ColorRect.new()
	_line_bg.name = "LineBg"
	_line_bg.color = Color(0, 0, 0, 1)
	_line_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_line_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_line_host.add_child(_line_bg)
	_line_lbl = Label.new()
	_line_lbl.name = "LineText"
	_line_lbl.add_theme_font_size_override("font_size", 22)
	_line_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_line_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_line_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_line_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_line_lbl.offset_left = 10.0
	_line_lbl.offset_top = 6.0
	_line_lbl.offset_right = -10.0
	_line_lbl.offset_bottom = -6.0
	_line_host.add_child(_line_lbl)
	_cut = Line2D.new()
	_cut.name = "Cut"
	_cut.width = 8.0
	_cut.default_color = Color(1, 1, 1, 0.8)
	_cut.antialiased = true
	_cut.z_index = 4
	_cut.visible = false
	add_child(_cut)


func _set_cutin_visible(on: bool) -> void:
	if _dim:
		_dim.visible = on
	if _band_host:
		_band_host.visible = on
	if _flash:
		_flash.visible = on
	if _portrait:
		_portrait.visible = on
	if _name_lbl:
		_name_lbl.visible = on
	if _call_lbl:
		_call_lbl.visible = on
	if _line_host:
		_line_host.visible = on and _line != ""
	if _cut and not on:
		_cut.visible = false


func _band_points() -> PackedVector2Array:
	var s: Vector2 = _cutin_shift()
	return PackedVector2Array([
		Vector2(-40, 620) + s,
		Vector2(1720, 250) + s,
		Vector2(1720, 600) + s,
		Vector2(-40, 970) + s,
	])


func _prepare_band() -> void:
	var pts: PackedVector2Array = _band_points()
	_half_a.polygon = pts
	_half_a.uv = PackedVector2Array([
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	])
	_half_a.visible = true
	_half_b.visible = false
	_half_a.position = Vector2.ZERO
	_half_b.position = Vector2.ZERO
	_half_a.modulate = Color(1, 1, 1, 1)
	_half_b.modulate = Color(1, 1, 1, 1)
	_edge_top.points = PackedVector2Array([pts[0], pts[1]])
	_edge_bot.points = PackedVector2Array([pts[3], pts[2]])
	_edge_top.modulate = Color(1, 1, 1, 1)
	_edge_bot.modulate = Color(1, 1, 1, 1)
	if _band_mat != null:
		_band_mat.set_shader_parameter("fill_color", Color(0.039, 0.027, 0.024, 0.92))
		_band_mat.set_shader_parameter("line_color", Color("e8c36a", 0.55))


func _split_band_halves() -> void:
	var pts: PackedVector2Array = _band_points()
	var mid_top: Vector2 = (pts[0] + pts[1]) * 0.5
	var mid_bot: Vector2 = (pts[3] + pts[2]) * 0.5
	_half_a.polygon = PackedVector2Array([pts[0], mid_top, mid_bot, pts[3]])
	_half_a.uv = PackedVector2Array([
		Vector2(0, 0), Vector2(0.5, 0), Vector2(0.5, 1), Vector2(0, 1),
	])
	_half_b.polygon = PackedVector2Array([mid_top, pts[1], pts[2], mid_bot])
	_half_b.uv = PackedVector2Array([
		Vector2(0.5, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0.5, 1),
	])
	_half_b.visible = true
	_edge_top.points = PackedVector2Array([pts[0], pts[1]])
	_edge_bot.points = PackedVector2Array([pts[3], pts[2]])


func _prepare_cut_line() -> void:
	var pts: PackedVector2Array = _band_points()
	var mid_top: Vector2 = (pts[0] + pts[1]) * 0.5
	var mid_bot: Vector2 = (pts[3] + pts[2]) * 0.5
	var dir: Vector2 = (mid_bot - mid_top).normalized()
	_cut.points = PackedVector2Array([
		mid_top - dir * 40.0,
		mid_bot + dir * 40.0,
	])


func _prepare_flash() -> void:
	_flash.texture = CIRCLE_TEX
	_flash.position = Vector2(750, 610) + _cutin_shift()
	var native: float = 64.0
	if CIRCLE_TEX != null:
		native = float(CIRCLE_TEX.get_width())
	var target: float = 280.0
	var s: float = target / maxf(native, 1.0)
	_flash.scale = Vector2(s, s)
	_flash.modulate = _flash_color(card_id)


func _flash_color(id: String) -> Color:
	var family: String = _flash_family(id)
	match family:
		"heal":
			return Color("8dcb8d")
		"poison":
			return Color("9a6ab8")
		"stone":
			return Color("9a9a9a")
		"flee":
			return Color("a8c8e8")
		"loot":
			return Color("e8c36a")
		_:
			return Color("8b1e1e")


func _flash_family(id: String) -> String:
	match id:
		"lich", "cleric", "martyr", "fairy", "pacemaker":
			return "heal"
		"plague_doctor", "poison_frog", "eel":
			return "poison"
		"gargoyle", "basilisk", "hydra":
			return "stone"
		"triclops", "goblin", "mouse":
			return "flee"
		"bandit", "mimic", "merchant", "beggar", "gelatinous_cube", "hired_hand":
			return "loot"
		_:
			return "damage"


func _prepare_labels() -> void:
	_name_lbl.text = _title
	_call_lbl.text = _call
	_name_lbl.visible = _title != ""
	_call_lbl.visible = _call != ""
	var s: Vector2 = _cutin_shift()
	_name_lbl.position = Vector2(1000, 555) + s
	_call_lbl.position = Vector2(1000, 598) + s
	if _line_host == null or _line_lbl == null:
		return
	_line_lbl.text = _line
	_line_host.visible = _line != ""
	if _line == "":
		return
	var font: Font = _line_lbl.get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var text_sz: Vector2 = font.get_string_size(_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	_line_host.size = Vector2(ceili(text_sz.x) + 20.0, ceili(text_sz.y) + 12.0)
	_line_host.position = Vector2(1000, 654) + s


func _prepare_portrait() -> void:
	_frame_texs.clear()
	_frame_i = 0
	if art != null and art.has_method("monster_slash_frames") and card_id != "":
		var frames: Array = art.monster_slash_frames(card_id)
		for f in frames:
			if f is Texture2D and f != null:
				_frame_texs.append(f)
	var still: Texture2D = _tex
	if still == null and art != null and card_id != "" and art.has_method("monster_still"):
		still = art.monster_still(card_id)
	if _portrait:
		_portrait.hframes = 1
		_portrait.vframes = 1
		_portrait.frame = 0
	if not _frame_texs.is_empty() and _frame_texs[0] is Texture2D and _frame_texs[0] != null:
		_portrait.texture = _frame_texs[0]
	else:
		_portrait.texture = still
	var s: float = _portrait_scale_for(_portrait.texture)
	_portrait.scale = _portrait_scale_vec(s)
	_portrait.position = _portrait_center()


func _process(delta: float) -> void:
	if not visible:
		return
	_clock += delta
	# Cut-in uses Node2D/Tween children — no Control redraw path.
	if _cutin_active:
		return
	# Item gutter: life tween (banner in/out) paints immediately; hold bob /
	# rays / Can't-Flee flash share CombatFxBudget.decor_step (heavy→4fps)
	# so attack_x5 does not queue_redraw every process tick.
	var step: float = FX_BUDGET.decor_step()
	if _slash_dirty:
		_slash_dirty = false
		_slash_wait = step
		queue_redraw()
		FRAME_METRICS.note_slash()
		return
	if step > 0.0:
		_slash_wait -= delta
		if _slash_wait > 0.0:
			return
		_slash_wait = step
	queue_redraw()
	FRAME_METRICS.note_slash()


func _draw() -> void:
	if _cutin_active:
		return
	if _life <= 0.01 or size.x < 32.0 or size.y < 32.0:
		return
	var a: float = clampf(_life, 0.0, 1.0)
	var r := Rect2(Vector2.ZERO, size)
	_draw_slash(r, a)
	var port := Rect2(Vector2((size.x - 168.0) * 0.5, 8.0), Vector2(168, 128))
	var slide: float = lerpf(-90.0, 0.0, a)
	port.position.x += slide
	var fill := Color(0.08, 0.06, 0.05, 0.92 * a)
	draw_rect(port, fill, true)
	var edge := Color("e8c36a")
	edge.a = a
	if log_glow:
		edge = Color("fff0c0")
	var rim: Rect2 = port.grow(-3.0)
	if rim.size.x > 1.0 and rim.size.y > 1.0:
		draw_rect(rim, edge, false, 3.0)
	if _tex != null and is_instance_valid(_tex):
		var bob: float = sin(_clock * 8.0) * 2.0 * a
		var dest := Rect2(port.position + Vector2(28.0, 8.0 + bob), Vector2(112, 112))
		var mod := Color(1, 1, 1, a)
		var flip := _portrait_faces_left()
		if flip:
			var axis_x: float = dest.position.x + dest.size.x * 0.5
			draw_set_transform(Vector2(2.0 * axis_x, 0.0), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(_tex, dest, false, mod)
		if flip:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var ink := Color("f0e6d8")
	ink.a = a
	var gold := Color("e8c36a")
	gold.a = a
	var y: float = port.end.y + 22.0
	if _is_item:
		_draw_centered(font, _title, y, 18, ink)
		if _call != "":
			y += 26.0
			var flash_gold := gold
			if _call == "Can't Flee" and sin(_clock * 14.0) > 0.0:
				flash_gold = Color("fff0c0")
				flash_gold.a = a
			_draw_centered(font, _call, y, 26, flash_gold)
	else:
		if _title != "":
			_draw_centered(font, _title, y, 18, ink)
			y += 22.0
		if _call != "":
			_draw_centered(font, _call, y, 22, gold)


func _draw_slash(r: Rect2, a: float) -> void:
	if r.size.x < 40.0 or r.size.y < 40.0:
		return
	var band := PackedVector2Array([
		r.position + Vector2(-20.0, r.size.y * 0.12),
		r.position + Vector2(r.size.x + 24.0, r.size.y * 0.02),
		r.position + Vector2(r.size.x + 24.0, r.size.y * 0.78),
		r.position + Vector2(-20.0, r.size.y * 0.92),
	])
	var dark := Color(0.04, 0.03, 0.03, 0.72 * a)
	draw_colored_polygon(band, dark)
	var gold := Color("e8c36a", 0.85 * a)
	draw_line(band[0], band[1], gold, 3.2, true)
	draw_line(band[3], band[2], gold, 2.2, true)
	var origin: Vector2 = r.position + Vector2(-8.0, r.size.y * 0.5)
	var dest: Vector2 = r.position + Vector2(r.size.x + 8.0, r.size.y * 0.38)
	FX_RAYS.draw(self, origin, dest, Color("e8c36a", 0.7 * a), _clock, false)


func _draw_centered(font: Font, text: String, y: float, fs: int, col: Color) -> void:
	if text == "":
		return
	var sz: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p := Vector2((size.x - sz.x) * 0.5, y)
	var out := Color(0.06, 0.05, 0.04, col.a)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, out)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
