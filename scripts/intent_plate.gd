extends Control
## Capsule of claw badges above the facing monster. One badge per raw hit.

const INTENT_BADGE := preload("res://scripts/intent_badge.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")

const BADGE_GAP := 20.0
const PAD := 16.0
const MAX_ROW := 5
const MAX_SHOW := 8
const DROP_IN := 0.140

var main
var _capsule: Panel
var _tail_a: Line2D
var _tail_b: Line2D
var _row: HBoxContainer
var _row2: HBoxContainer
var _col: VBoxContainer
var _loop: Control
var _badges: Array = []
var _hits: Array = []
var _ghost: bool = false
var _next_i: int = 0
var _in_tw: Tween
var _sig: String = ""


func setup(p_main) -> void:
	main = p_main
	name = "IntentPlate"
	top_level = true
	z_index = 13
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	visible = false
	_capsule = Panel.new()
	_capsule.name = "Capsule"
	_capsule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.078, 0.063, 0.047, 0.92) # #14100c
	sb.border_color = Color("e8c36a")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = PAD
	sb.content_margin_right = PAD
	sb.content_margin_top = PAD
	sb.content_margin_bottom = PAD
	_capsule.add_theme_stylebox_override("panel", sb)
	add_child(_capsule)
	_col = VBoxContainer.new()
	_col.name = "Col"
	_col.add_theme_constant_override("separation", 8)
	_capsule.add_child(_col)
	_row = HBoxContainer.new()
	_row.name = "Row"
	_row.add_theme_constant_override("separation", int(BADGE_GAP))
	_col.add_child(_row)
	_row2 = HBoxContainer.new()
	_row2.name = "Row2"
	_row2.add_theme_constant_override("separation", int(BADGE_GAP))
	_row2.visible = false
	_col.add_child(_row2)
	_loop = Control.new()
	_loop.name = "LoopChip"
	_loop.custom_minimum_size = Vector2(32, 16)
	_loop.size = Vector2(32, 16)
	_loop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loop.visible = false
	_loop.draw.connect(_draw_loop)
	_row.add_child(_loop)
	_tail_a = Line2D.new()
	_tail_a.name = "TailA"
	_tail_a.width = 3.0
	_tail_a.default_color = Color("e8c36a")
	_tail_a.z_index = -1
	add_child(_tail_a)
	_tail_b = Line2D.new()
	_tail_b.name = "TailB"
	_tail_b.width = 3.0
	_tail_b.default_color = Color("e8c36a")
	_tail_b.z_index = -1
	add_child(_tail_b)


func sync(hits: Array) -> void:
	_ghost = false
	var sig := _hits_sig(hits)
	if sig == _sig and visible and not _hits.is_empty():
		_place()
		return
	var was_visible := visible and not _badges.is_empty()
	_sig = sig
	_hits = hits.duplicate(true)
	if _hits.is_empty():
		clear()
		return
	_rebuild()
	_place()
	if was_visible:
		visible = true
		_mark_next()
	else:
		_play_in()


func ghost(hits: Array) -> void:
	_ghost = true
	_hits = hits.duplicate(true)
	_rebuild()
	_place()
	if _hits.is_empty():
		clear()
		return
	modulate.a = 0.55
	visible = true


func fire(i: int, blocked: bool = false, pierce: bool = false) -> void:
	if i < 0 or i >= _badges.size():
		return
	var b = _badges[i]
	if b == null or not is_instance_valid(b):
		return
	await b.fire(blocked, pierce)
	_next_i = i + 1
	_mark_next()


func clear() -> void:
	if _in_tw != null and is_instance_valid(_in_tw):
		_in_tw.kill()
		_in_tw = null
	visible = false
	_hits.clear()
	_badges.clear()
	_next_i = 0
	_ghost = false
	_sig = ""
	modulate = Color.WHITE
	for c in _row.get_children():
		if c != _loop:
			c.queue_free()
	for c in _row2.get_children():
		c.queue_free()
	_loop.visible = false
	_tail_a.clear_points()
	_tail_b.clear_points()


func _rebuild() -> void:
	for c in _row.get_children():
		if c != _loop:
			c.queue_free()
	for c in _row2.get_children():
		c.queue_free()
	_badges.clear()
	_loop.visible = false
	_row2.visible = false
	if _hits.is_empty():
		return
	var show: Array = []
	var has_loop := false
	for h in _hits:
		if bool(h.get("loop", false)):
			has_loop = true
			continue
		show.append(h)
	var overflow_n := 0
	if show.size() > MAX_SHOW:
		overflow_n = show.size() - (MAX_SHOW - 1)
		show = show.slice(0, MAX_SHOW - 1)
		show.append({"n_raw": overflow_n, "overflow": true, "soaked": false, "pierce": false})
	var i := 0
	for h in show:
		var badge = INTENT_BADGE.new()
		badge.name = "IntentBadge_%s" % i
		badge.setup(h)
		if i < MAX_ROW:
			_row.add_child(badge)
		else:
			_row2.visible = true
			_row2.add_child(badge)
		_badges.append(badge)
		i += 1
	if has_loop:
		_row.move_child(_loop, _row.get_child_count() - 1)
		_loop.visible = true
		_loop.queue_redraw()
	_next_i = 0
	_mark_next()
	_fit_capsule()


func _fit_capsule() -> void:
	await get_tree().process_frame
	if not is_instance_valid(_capsule):
		return
	var need := _col.get_combined_minimum_size()
	var w: float = need.x + PAD * 2.0
	var h: float = need.y + PAD * 2.0
	_capsule.custom_minimum_size = Vector2(w, h)
	_capsule.size = Vector2(w, h)
	size = Vector2(w, h + 18.0)
	_col.position = Vector2(PAD, PAD)
	_col.size = need


func _play_in() -> void:
	visible = true
	modulate = Color(1, 1, 1, 1 if not _ghost else 0.55)
	if _in_tw != null and is_instance_valid(_in_tw):
		_in_tw.kill()
	var base_y: float = position.y
	position.y = base_y - 24.0
	_in_tw = create_tween()
	_in_tw.tween_property(self, "position:y", base_y, DROP_IN).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var delay := 0.0
	for b in _badges:
		if b != null and is_instance_valid(b) and b.has_method("pop_in"):
			b.pop_in(delay)
			delay += 0.060


func _mark_next() -> void:
	for i in range(_badges.size()):
		var b = _badges[i]
		if b != null and is_instance_valid(b) and b.has_method("set_next"):
			b.set_next(i == _next_i and not bool(b.spent))


func _place() -> void:
	if main == null:
		return
	var tip := Vector2.ZERO
	var center := Vector2.ZERO
	var use_tail := true
	if main.combat_stage != null and main.combat_stage.visible:
		var r: Rect2 = main.combat_stage.get_global_rect()
		center = Vector2(r.position.x + r.size.x * 0.5, r.position.y - 12.0)
		tip = Vector2(r.position.x + r.size.x * 0.5, r.position.y)
		use_tail = false
	elif main.wheel_view != null and int(main.facing_index) >= 0:
		var portrait: Vector2 = main.wheel_view.slice_portrait_global(int(main.facing_index))
		var hub: Vector2 = main.wheel_view.hub_hearts_global()
		var spoke: Vector2 = portrait - hub
		if spoke.length() < 1.0:
			spoke = Vector2(0, -1)
		# Prefer above the portrait so the plate stays on-screen for bottom-facing slices.
		center = portrait + Vector2(0.0, -96.0)
		var outward: Vector2 = portrait + spoke.normalized() * 120.0
		var vp: Rect2 = get_viewport().get_visible_rect()
		if vp.has_point(outward) and outward.y > vp.position.y + 80.0:
			center = outward
		tip = portrait
		use_tail = true
	else:
		return
	_fit_capsule_sync()
	global_position = center - Vector2(size.x * 0.5, size.y)
	# Clamp into the viewport with a small margin.
	var view: Rect2 = get_viewport().get_visible_rect()
	global_position.x = clampf(global_position.x, view.position.x + 8.0, view.end.x - size.x - 8.0)
	global_position.y = clampf(global_position.y, view.position.y + 8.0, view.end.y - size.y - 8.0)
	if use_tail:
		_draw_tail(tip)
	else:
		_tail_a.clear_points()
		_tail_b.clear_points()


func _fit_capsule_sync() -> void:
	var n: int = mini(_badges.size(), MAX_ROW)
	var rows: int = 1 if _badges.size() <= MAX_ROW else 2
	var loop_w: float = 32.0 + BADGE_GAP if _loop.visible else 0.0
	var w: float = PAD * 2.0 + n * 64.0 + maxf(0, n - 1) * BADGE_GAP + loop_w
	if _badges.size() > MAX_ROW:
		var n2: int = _badges.size() - MAX_ROW
		w = maxf(w, PAD * 2.0 + n2 * 64.0 + maxf(0, n2 - 1) * BADGE_GAP)
	var h: float = PAD * 2.0 + rows * 64.0 + (8.0 if rows > 1 else 0.0)
	_capsule.custom_minimum_size = Vector2(w, h)
	_capsule.size = Vector2(w, h)
	size = Vector2(w, h + 18.0)
	_col.position = Vector2(PAD, PAD)


func _draw_tail(tip_global: Vector2) -> void:
	var local_tip: Vector2 = tip_global - global_position
	var base := Vector2(size.x * 0.5, size.y - 4.0)
	_tail_a.clear_points()
	_tail_b.clear_points()
	_tail_a.add_point(base + Vector2(-10, 0))
	_tail_a.add_point(local_tip)
	_tail_b.add_point(base + Vector2(10, 0))
	_tail_b.add_point(local_tip)


func _draw_loop() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var mark := _loop.size * 0.5
	UxStyle.draw_multi_tag(_loop, mark, "↻", font)


func _hits_sig(hits: Array) -> String:
	var parts: PackedStringArray = []
	for h in hits:
		parts.append("%s:%s:%s:%s:%s" % [
			int(h.get("n_raw", 0)),
			1 if bool(h.get("soaked", false)) else 0,
			1 if bool(h.get("pierce", false)) else 0,
			1 if bool(h.get("loop", false)) else 0,
			int(h.get("src_index", -1)),
		])
	return "|".join(parts)
