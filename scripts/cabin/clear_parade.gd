extends Node
## Dungeon-clear parade on the hub. Rope exit opens after this returns.
## run_victory and run_walkoff face right and are never mirrored. No wax seal.

const PARADE_SEC := 2.7
const HERO_TL := Vector2(-48, -50)
const CHEER_MARKS := [0.10, 0.24, 0.40, 0.52, 0.62, 0.76, 0.92, 1.04]
const HOP_START := 1.04
const HOP_END := 1.60
const WIPE_END := 2.10
const ARRIVE_END := 2.58
## hero_arrive f2 onset ≈ midpoint of arrive span (landing contact).
const DUST_START := WIPE_END + 0.5 * (ARRIVE_END - WIPE_END)
const DUST_PLAY := 0.24

## When >= 0, run() advances to that t and holds (deterministic Repot shots).
var freeze_at: float = -1.0

var _layer: CanvasLayer
var _hero: Sprite2D
var _gear: Array = []


func run(wheel, art) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var t0 := Time.get_ticks_msec()
	_layer = CanvasLayer.new()
	_layer.layer = 40
	add_child(_layer)
	var hub := Vector2(548, 300)
	if wheel != null and wheel.has_method("rim_global"):
		hub = wheel.rim_global()
	if wheel != null:
		wheel.hub_flip = false
		wheel.queue_redraw()
	var feet := hub + HERO_TL
	var victory: Array = _run_frames(art, "victory")
	var walkoff: Array = _run_frames(art, "walkoff")
	var gear_victory: Array = _gear_sets(art, wheel, "victory")
	var gear_walk: Array = _gear_sets(art, wheel, "walkoff")
	var burst: Array = _load_seq("res://assets/dungeon/vfx/clear/clear_burst_f%d.png", 8)
	var embers: Array = _load_seq("res://assets/dungeon/vfx/clear/clear_embers_f%d.png", 4)
	var mouth: Array = _load_seq("res://assets/dungeon/vfx/clear/burrow_mouth_f%d.png", 3)
	var arrive: Array = _load_seq("res://assets/dungeon/home/hero/hero_arrive_f%d.png", 4)
	var dust: Array = _load_seq("res://assets/dungeon/home/overlays/land_dust_f%d.png", 3)
	var curtain := _load_one("res://assets/dungeon/vfx/clear/burrow_curtain.png")
	var mound := _load_one("res://assets/dungeon/home/overlays/burrow_mound.png")
	var burst_sp := _make(_first(burst), feet + Vector2(-16, -24), 6)
	var ember_sp := _make(_first(embers), feet + Vector2(8, -8), 5)
	var mound_sp := _make(mound, feet + Vector2(132, 36), 2)
	mound_sp.visible = false
	var mouth_sp := _make(_first(mouth), feet + Vector2(128, 8), 3)
	mouth_sp.visible = false
	var curtain_sp := _make(curtain, feet, 8)
	curtain_sp.visible = false
	var curtain_w := 0.0
	if curtain != null:
		curtain_w = float(curtain.get_width()) * curtain_sp.scale.x
	# Dust above the hero (z 7 > hero 4); brighten so it reads on the dark wheel.
	var dust_sp := _make(_first(dust), feet, 7)
	dust_sp.visible = false
	dust_sp.modulate = Color(1.15, 1.1, 1.0, 1.0)
	_hero = _make(_first(victory), feet, 4)
	_pin_gear(feet, gear_victory)
	var hop := 140.0
	var t := 0.0
	var hold_at := freeze_at
	var end_t := PARADE_SEC - 0.001
	if hold_at >= 0.0:
		end_t = hold_at
	while t < end_t:
		t = float(Time.get_ticks_msec() - t0) / 1000.0
		if t >= end_t:
			break
		_hero.flip_h = false
		if t < HOP_START:
			_frame_at(_hero, victory, CHEER_MARKS, t, gear_victory)
			_frame_span(burst_sp, burst, 0.0, 0.40, t)
			burst_sp.visible = t < 0.40 and not burst.is_empty()
			mound_sp.visible = false
			dust_sp.visible = false
		elif t < HOP_END:
			burst_sp.visible = false
			var u := (t - HOP_START) / (HOP_END - HOP_START)
			var x := feet.x + hop * u
			_hero.position.x = x
			_frame_span(_hero, walkoff, HOP_START, HOP_END, t)
			_sync_gear(gear_walk, _walk_index(t), _hero.position, _hero.scale)
			mouth_sp.visible = not mouth.is_empty()
			_frame_span(mouth_sp, mouth, HOP_START + 0.28, HOP_END, t)
			mound_sp.visible = mound != null
			dust_sp.visible = false
		elif t < WIPE_END:
			_hero.visible = false
			for g in _gear:
				g.visible = false
			mouth_sp.visible = false
			mound_sp.visible = mound != null
			dust_sp.visible = false
			if curtain != null and curtain_w > 1.0:
				var u2 := (t - HOP_END) / (WIPE_END - HOP_END)
				curtain_sp.visible = true
				curtain_sp.flip_h = false
				curtain_sp.position = Vector2(mouth_sp.position.x - curtain_w + (curtain_w * 1.35) * u2, mouth_sp.position.y - 16.0)
			else:
				curtain_sp.visible = false
		else:
			curtain_sp.visible = false
			mouth_sp.visible = false
			mound_sp.visible = false
			var land := feet + Vector2(hop + 36.0, 0.0)
			var u3 := clampf((t - WIPE_END) / (ARRIVE_END - WIPE_END), 0.0, 1.0)
			_hero.visible = not arrive.is_empty()
			_hero.position = land + Vector2(56.0 * u3, 0.0)
			_frame_span(_hero, arrive, WIPE_END, ARRIVE_END, t)
			for g in _gear:
				g.visible = false
			_update_land_dust(dust_sp, dust, t)
		if not embers.is_empty():
			ember_sp.visible = t < WIPE_END
			var ei := int(t / 0.09) % embers.size()
			ember_sp.texture = embers[ei]
			ember_sp.flip_h = false
		if hold_at >= 0.0 and t + 0.02 >= hold_at:
			t = hold_at
			# Exact-beat re-paint, then hold for Repot.
			_hero.flip_h = false
			if t < HOP_START:
				_frame_at(_hero, victory, CHEER_MARKS, t, gear_victory)
				_frame_span(burst_sp, burst, 0.0, 0.40, t)
				burst_sp.visible = t < 0.40 and not burst.is_empty()
				mound_sp.visible = false
				dust_sp.visible = false
			elif t < HOP_END:
				burst_sp.visible = false
				var uf := (t - HOP_START) / (HOP_END - HOP_START)
				_hero.position.x = feet.x + hop * uf
				_frame_span(_hero, walkoff, HOP_START, HOP_END, t)
				_sync_gear(gear_walk, _walk_index(t), _hero.position, _hero.scale)
				mouth_sp.visible = not mouth.is_empty()
				_frame_span(mouth_sp, mouth, HOP_START + 0.28, HOP_END, t)
				mound_sp.visible = mound != null
				dust_sp.visible = false
			elif t < WIPE_END:
				_hero.visible = false
				for g in _gear:
					g.visible = false
				mouth_sp.visible = false
				mound_sp.visible = mound != null
				dust_sp.visible = false
				if curtain != null and curtain_w > 1.0:
					var u2f := (t - HOP_END) / (WIPE_END - HOP_END)
					curtain_sp.visible = true
					curtain_sp.flip_h = false
					curtain_sp.position = Vector2(mouth_sp.position.x - curtain_w + (curtain_w * 1.35) * u2f, mouth_sp.position.y - 16.0)
				else:
					curtain_sp.visible = false
			else:
				curtain_sp.visible = false
				mouth_sp.visible = false
				mound_sp.visible = false
				var land_f := feet + Vector2(hop + 36.0, 0.0)
				var u3f := clampf((t - WIPE_END) / (ARRIVE_END - WIPE_END), 0.0, 1.0)
				_hero.visible = not arrive.is_empty()
				_hero.position = land_f + Vector2(56.0 * u3f, 0.0)
				_frame_span(_hero, arrive, WIPE_END, ARRIVE_END, t)
				for g in _gear:
					g.visible = false
				_update_land_dust(dust_sp, dust, t)
			if not embers.is_empty():
				ember_sp.visible = t < WIPE_END
				var eif := int(t / 0.09) % embers.size()
				ember_sp.texture = embers[eif]
				ember_sp.flip_h = false
			await _wait(3600.0)
			break
		await _wait(0.02)
	if hold_at < 0.0:
		var left := PARADE_SEC - float(Time.get_ticks_msec() - t0) / 1000.0
		if left > 0.02:
			await _wait(left)
		if is_instance_valid(_layer):
			_layer.queue_free()


func _update_land_dust(dust_sp: Sprite2D, dust: Array, t: float) -> void:
	if dust_sp == null or dust.is_empty() or _hero == null:
		return
	if t < DUST_START:
		dust_sp.visible = false
		return
	dust_sp.visible = true
	# Arrive art is 128×128 at scale 1; feet near y≈115–128. Dust is 32×16 ×4 = 128×64.
	var dust_h := 64.0
	if dust_sp.texture != null:
		dust_h = float(dust_sp.texture.get_height()) * dust_sp.scale.y
	dust_sp.position = _hero.position + Vector2(0.0, 128.0 - dust_h)
	var play_end := DUST_START + DUST_PLAY
	if t < play_end:
		_frame_span(dust_sp, dust, DUST_START, play_end, t)
		dust_sp.modulate = Color(1.15, 1.1, 1.0, 1.0)
	else:
		dust_sp.texture = dust[dust.size() - 1]
		var fade_u := 0.0
		if PARADE_SEC > play_end:
			fade_u = clampf((t - play_end) / (PARADE_SEC - play_end), 0.0, 1.0)
		dust_sp.modulate = Color(1.15, 1.1, 1.0, 1.0 - fade_u)


func _run_frames(art, anim: String) -> Array:
	if art != null and art.has_method("hero_run_anim"):
		return art.hero_run_anim(anim)
	return []


func _gear_sets(art, wheel, anim: String) -> Array:
	var out: Array = []
	if art == null or wheel == null or not art.has_method("hero_run_gear"):
		return out
	var worn: Dictionary = wheel.hub_gear
	var head := str(worn.get("head", ""))
	var pieces: Array = []
	if str(worn.get("belt", "")) == "rope":
		pieces.append("rope")
	if str(worn.get("eyes", "")) == "goggles":
		pieces.append("goggles")
	if head == "cap" or head == "helm":
		pieces.append(head)
	for piece in pieces:
		var frames: Array = art.hero_run_gear(str(piece), anim)
		if not frames.is_empty():
			out.append(frames)
	return out


func _pin_gear(pos: Vector2, sets: Array) -> void:
	for frames in sets:
		if typeof(frames) != TYPE_ARRAY or frames.is_empty():
			continue
		_gear.append(_make(frames[0], pos, 5))


func _sync_gear(sets: Array, frame_i: int, pos: Vector2, sc: Vector2) -> void:
	var n: int = mini(_gear.size(), sets.size())
	for i in n:
		var frames: Array = sets[i]
		var sp: Sprite2D = _gear[i]
		if frames.is_empty():
			continue
		sp.visible = true
		sp.flip_h = false
		sp.position = pos
		sp.scale = sc
		sp.texture = frames[clampi(frame_i, 0, frames.size() - 1)]


func _walk_index(t: float) -> int:
	var steps := int((t - HOP_START) / 0.07)
	return maxi(0, steps)


func _frame_at(sp: Sprite2D, frames: Array, marks: Array, t: float, gear_sets: Array) -> void:
	if sp == null or frames.is_empty():
		return
	sp.visible = true
	sp.flip_h = false
	var fi := 0
	for i in marks.size():
		fi = i % frames.size()
		if t < float(marks[i]):
			break
	sp.texture = frames[fi]
	_sync_gear(gear_sets, fi, sp.position, sp.scale)


func _frame_span(sp: Sprite2D, frames: Array, t0: float, t1: float, t: float) -> void:
	if sp == null or frames.is_empty() or t1 <= t0:
		return
	sp.visible = true
	sp.flip_h = false
	var u := clampf((t - t0) / (t1 - t0), 0.0, 0.999)
	var fi := mini(int(u * float(frames.size())), frames.size() - 1)
	sp.texture = frames[fi]


func _first(frames: Array) -> Texture2D:
	if frames.is_empty():
		return null
	return frames[0]


func _load_seq(pattern: String, n: int) -> Array:
	var out: Array = []
	for i in n:
		var tex := _load_one(pattern % i)
		if tex == null:
			break
		out.append(tex)
	return out


func _load_one(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _make(tex: Texture2D, pos: Vector2, z: int) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.centered = false
	sp.flip_h = false
	sp.z_index = z
	sp.position = pos
	sp.texture = tex
	sp.visible = tex != null
	sp.scale = _pixel_scale(tex)
	_layer.add_child(sp)
	return sp


func _pixel_scale(tex: Texture2D) -> Vector2:
	if tex != null and tex.get_width() > 0 and tex.get_width() <= 48:
		return Vector2(4, 4)
	return Vector2.ONE


func _wait(seconds: float) -> void:
	if seconds <= 0.0:
		return
	var tree := get_tree()
	if tree == null:
		return
	# Idle frames, not physics. HTML5 physics timers can stall and never fire,
	# which left the dungeon clear waiting forever on an empty wheel.
	var left := seconds
	while left > 0.0:
		await tree.process_frame
		var dt := get_process_delta_time()
		if dt <= 0.0:
			dt = 0.016
		left -= dt
