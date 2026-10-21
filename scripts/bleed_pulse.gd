extends Node2D
## One red ring per HP-loss event, expanding from hub hearts. Listeners hop as it passes.

const HURT := Color("e07a7a")
const DANGER := Color("8b1e1e")
const RING_MS := 0.450
const STAGGER_MS := 0.150
const HOP_MS := 0.120
const MAX_R := 900.0

var main
var _rings: Array = [] # {r, a, origin, catches: Dictionary}
var _queue: Array = [] # pending n values while bleed hold
var _flushing: bool = false
var _draw_r: float = 0.0:
	set(v):
		_draw_r = v
		queue_redraw()


func setup(p_main) -> void:
	main = p_main
	name = "BleedPulse"
	top_level = true
	z_index = 11
	visible = true
	set_process(true)


func on_bled(n: int) -> void:
	if n <= 0:
		return
	if main != null and int(main._bleed_hold) > 0:
		_queue.append(n)
		return
	_spawn_ring(n)


func active_ring_count() -> int:
	return _rings.size()


func flush_queue() -> void:
	if _queue.is_empty() or _flushing:
		return
	_flushing = true
	var pending: Array = _queue.duplicate()
	_queue.clear()
	for i in range(pending.size()):
		_spawn_ring(int(pending[i]))
		if i < pending.size() - 1:
			await get_tree().create_timer(STAGGER_MS).timeout
	# Shot harness: capture while rings are mid-flight on the real HP-loss path.
	if main != null and OS.has_feature("editor") and main.has_meta("qa_anim_bleed_shot"):
		var fname: String = str(main.get_meta("qa_anim_bleed_shot"))
		main.remove_meta("qa_anim_bleed_shot")
		await get_tree().create_timer(0.225).timeout
		if main.has_meta("qa_anim_capture") and main.get_meta("qa_anim_capture") is Callable:
			await (main.get_meta("qa_anim_capture") as Callable).call(fname)
	_flushing = false


func _spawn_ring(_n: int) -> void:
	var origin := _origin()
	var ring := {
		"r": 0.0,
		"a": 0.9,
		"origin": origin,
		"catches": {},
		"t": 0.0,
	}
	_rings.append(ring)
	queue_redraw()


func _origin() -> Vector2:
	if main != null and main.wheel_view != null:
		return main.wheel_view.hub_hearts_global()
	if main != null and main.has_method("_hub_hp_pos"):
		return main._hub_hp_pos()
	return Vector2.ZERO


func _process(delta: float) -> void:
	if _rings.is_empty():
		return
	var dead: Array = []
	for i in range(_rings.size()):
		var ring: Dictionary = _rings[i]
		ring["t"] = float(ring.get("t", 0.0)) + delta
		var u: float = clampf(float(ring["t"]) / RING_MS, 0.0, 1.0)
		# TRANS_QUAD out
		var eased: float = 1.0 - (1.0 - u) * (1.0 - u)
		ring["r"] = eased * MAX_R
		ring["a"] = lerpf(0.9, 0.0, u)
		_try_catches(ring)
		if u >= 1.0:
			dead.append(i)
	dead.reverse()
	for i in dead:
		_rings.remove_at(i)
	queue_redraw()


func _try_catches(ring: Dictionary) -> void:
	if main == null:
		return
	var origin: Vector2 = ring.get("origin", Vector2.ZERO)
	var r: float = float(ring.get("r", 0.0))
	var caught: Dictionary = ring.get("catches", {})
	# Wheel slices
	if main.wheel_view != null:
		for i in range(main.wheel.size()):
			var key := "slice_%s" % i
			if caught.has(key):
				continue
			var cid: String = str(main.wheel[i].get("card_id", ""))
			if cid not in ["vampire", "ogre", "dire_wolf", "druid"]:
				continue
			if int(main.wheel[i].get("hp", 0)) <= 0:
				continue
			var pos: Vector2 = main.wheel_view.slice_portrait_global(i)
			if origin.distance_to(pos) <= r:
				caught[key] = true
				main.wheel_view.punch_hp(i)
				main.wheel_view.punch_atk(i)
				_hop_at(pos)
	# Hotbar cards
	if main.hotbar_box != null:
		for c in main.hotbar_box.get_children():
			if c == null:
				continue
			var uid: int = int(c.get("uid"))
			if uid < 0:
				continue
			var key := "card_%s" % uid
			if caught.has(key):
				continue
			var id := _card_id_for_uid(uid)
			if id not in ["spiked_flail", "breastplate", "pacemaker", "blood_chalice"]:
				continue
			var pos2: Vector2 = c.get_global_rect().get_center()
			if origin.distance_to(pos2) <= r:
				caught[key] = true
				if c.has_method("bounce"):
					c.bounce()
				_hop_control(c)
	ring["catches"] = caught


func _card_id_for_uid(uid: int) -> String:
	for it in main.hotbar:
		if int(it.get("uid", -1)) == uid:
			return str(it.get("card_id", ""))
	return ""


func _hop_at(global_pos: Vector2) -> void:
	# Visual hop marker (short red pulse ring already covers); punch handles slice.
	pass


func _hop_control(c: Control) -> void:
	if c == null:
		return
	var base: Vector2 = c.position
	var tw := c.create_tween()
	tw.tween_property(c, "position", base + Vector2(0, -6), HOP_MS * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(c, "modulate", Color(1.0, 0.55, 0.55), HOP_MS * 0.5)
	tw.tween_property(c, "position", base, HOP_MS * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(c, "modulate", Color.WHITE, HOP_MS * 0.5)


func _draw() -> void:
	for ring in _rings:
		var origin: Vector2 = ring.get("origin", Vector2.ZERO)
		var r: float = float(ring.get("r", 0.0))
		var a: float = float(ring.get("a", 0.0))
		if r < 1.0 or a <= 0.01:
			continue
		var local: Vector2 = to_local(origin)
		var w: float = lerpf(6.0, 2.0, 1.0 - a / 0.9)
		var col := HURT.lerp(DANGER, 1.0 - a / 0.9)
		col.a = a
		draw_arc(local, r, 0.0, TAU, 64, col, w, true)
