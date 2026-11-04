extends Node
## Dungeon-clear resolve v2: wheel fold → victory → jump → wipe → Rope Exit.
## Burrow mouth/curtain/mound/arrive/dust/burst/embers are not used on this path.
## sprout_victory faces right and is never mirrored. No wax seal.

const TOTAL := 2.50
const HERO_TL := Vector2(-48, -50)
const HERO_SIZE := 96.0
const SCALE_HUB := 1.5
const SCALE_ROPE := 2.0

const T_CHROME_END := 0.18
const T_FOLD_END := 0.42
const T_AURA_START := 0.34
const T_AURA_END := 0.52
const T_VICTORY_START := 0.30
const T_VICTORY_END := 1.30
const T_CROUCH_START := 1.30
const T_CROUCH_END := 1.40
const T_JUMP_UP_END := 1.54
const T_FALL_OFF_END := 1.92
const T_WIPE_START := 1.66
const T_SWAP := 1.98
const T_WIPE_END := 2.30
const T_LAND := 2.38
const T_DONE := 2.50

## Victory dance: eight marks ≈0.12 s each over two loops of f0–f3.
const VICTORY_MARKS := [0.42, 0.54, 0.66, 0.78, 0.90, 1.02, 1.14, 1.26]

## When >= 0, run() advances to that t and holds (deterministic Repot shots).
var freeze_at: float = -1.0

var _layer: CanvasLayer
var _lock: Control
var _hero: Sprite2D
var _gear: Array = []
var _wipe: ColorRect
var _wipe_mat: ShaderMaterial
var _aura: Sprite2D
var _wheel
var _art
var _on_swap: Callable = Callable()
var _swapped := false
var _sfx_fired := false
var _chrome_nodes: Array = []
var _feet0 := Vector2.ZERO
var _hub_x := 0.0
var _vh := 1040.0
var _land_tl := Vector2.ZERO
var _v_exit := 0.0
var _g_fall := 0.0
var _victory: Array = []
var _gear_victory: Array = []
var _rope_exit = null


func run(wheel, art, on_swap: Callable = Callable()) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_wheel = wheel
	_art = art
	_on_swap = on_swap
	_swapped = false
	_sfx_fired = false
	var t0 := Time.get_ticks_msec()
	_layer = CanvasLayer.new()
	_layer.layer = 40
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_layer)
	## Full-rect click blocker (L4). Pattern matches NestInputLock.
	_lock = Control.new()
	_lock.name = "ResolveInputLock"
	_lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lock.mouse_filter = Control.MOUSE_FILTER_STOP
	_lock.z_index = 2
	_layer.add_child(_lock)
	_lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vp := get_viewport()
	if vp != null:
		_vh = vp.get_visible_rect().size.y
		_lock.size = vp.get_visible_rect().size
	var hub := Vector2(548, 300)
	if wheel != null and wheel.has_method("rim_global"):
		hub = wheel.rim_global()
	## Clear lingering per-kill collapse so fold does not double-draw (L9).
	if wheel != null:
		wheel.collapse = 0.0
		if wheel.has_method("clear_slay"):
			wheel.clear_slay()
		wheel.fold = 0.0
		wheel.hub_flip = false
		wheel.queue_redraw()
	_feet0 = hub + HERO_TL
	_hub_x = _feet0.x
	_victory = _sprout_victory(art)
	_gear_victory = _gear_sets(art, wheel, "victory")
	_hero = _make_hero(_first(_victory), _feet0, 4)
	_pin_gear(_feet0, _gear_victory)
	_build_wipe()
	_build_aura(hub)
	_rope_exit = _find_rope()
	_cache_chrome()
	## Precompute fall gravity so y hits vh+16 at T_FALL_OFF_END.
	var fall_dt: float = T_FALL_OFF_END - T_JUMP_UP_END
	var y_up: float = _feet0.y - 40.0
	var y_off: float = _vh + 16.0
	## y = y_up + 0.5*g*t^2  →  g = 2*(y_off - y_up) / t^2
	if fall_dt > 0.001:
		_g_fall = 2.0 * (y_off - y_up) / (fall_dt * fall_dt)
	else:
		_g_fall = 4000.0
	_v_exit = _g_fall * fall_dt
	var hold_at := freeze_at
	var end_t := TOTAL - 0.001
	if hold_at >= 0.0:
		end_t = hold_at
	var t := 0.0
	while t < end_t:
		t = float(Time.get_ticks_msec() - t0) / 1000.0
		if t >= end_t:
			t = end_t
		_pose(t)
		if hold_at >= 0.0 and t + 0.02 >= hold_at:
			## Keep re-posing while held so a caller _refresh / spin pulse cannot
			## undo fold or restore Spin during a multi-minute Repot freeze.
			var hold_left := 3600.0
			while hold_left > 0.0:
				_pose(hold_at)
				await _wait(0.05)
				hold_left -= 0.05
			break
		await _wait(0.02)
	if hold_at < 0.0:
		## Ensure final pose + swap landed.
		_pose(TOTAL)
		var left := TOTAL - float(Time.get_ticks_msec() - t0) / 1000.0
		if left > 0.02:
			await _wait(left)
		_teardown()
	## freeze_at holds leave the layer up for Repot shots (same as v1).


func _pose(t: float) -> void:
	if not is_instance_valid(_layer):
		return
	## A2 SFX at fold start.
	if t >= 0.0 and not _sfx_fired:
		_sfx_fired = true
		_play_sting_clear()
	## A2 wheel fold 0→1 over 0.42 s (linear tween; per-wedge ease in wheel).
	if _wheel != null and is_instance_valid(_wheel):
		_wheel.fold = clampf(t / T_FOLD_END, 0.0, 1.0) if t < T_FOLD_END else (0.0 if t >= T_SWAP else 1.0)
		if t >= T_SWAP:
			_wheel.fold = 0.0
	## A1 chrome fade — also force-hide so main's spin pulse / _sync_buttons
	## cannot restore Spin (phase stays ready until the swap).
	_apply_chrome_fade(t)
	## Aura bloom 0.34–0.52.
	if _aura != null and is_instance_valid(_aura):
		if t < T_AURA_START or t > T_AURA_END:
			_aura.visible = false
		else:
			_aura.visible = true
			var u: float = (t - T_AURA_START) / (T_AURA_END - T_AURA_START)
			## OUT_BACK pop then linear fade.
			var pop: float = clampf(u / 0.35, 0.0, 1.0)
			var back: float = 1.0 + 0.4 * pop * (1.0 - pop) * 4.0
			var fade: float = 1.0 - clampf((u - 0.35) / 0.65, 0.0, 1.0)
			_aura.scale = Vector2.ONE * lerpf(0.4, 1.35, pop) * back
			_aura.modulate = Color(1, 1, 1, fade)
	## Wipe: cover 1.66→1.98 ease-out (readable by 1.75), uncover 1.98→2.30 linear.
	if _wipe_mat != null:
		var wp := 0.0
		if t >= T_WIPE_START and t < T_SWAP:
			var cu: float = clampf((t - T_WIPE_START) / (T_SWAP - T_WIPE_START), 0.0, 1.0)
			## Ease-out quad: at t=1.75 (~0.28 of cover) progress ≈ 0.48 — lower half.
			wp = 1.0 - (1.0 - cu) * (1.0 - cu)
		elif t >= T_SWAP:
			var uu: float = clampf((t - T_SWAP) / (T_WIPE_END - T_SWAP), 0.0, 1.0)
			wp = 1.0 + uu
		_wipe_mat.set_shader_parameter("progress", wp)
		if _wipe != null:
			_wipe.visible = t >= T_WIPE_START and wp > 0.001 and wp < 1.999
	## D2 swap at 1.98 — same frame, once.
	if t >= T_SWAP:
		_do_swap(t)
	## Hero pose.
	if _hero == null or not is_instance_valid(_hero):
		return
	_hero.flip_h = false
	_hero.visible = true
	var pos := _feet0
	var sc := Vector2(SCALE_HUB, SCALE_HUB)
	var frame_i := 0
	if t < T_VICTORY_START:
		## A0 handoff — f0 on hub spot.
		frame_i = 0
		pos = _feet0
		sc = Vector2(SCALE_HUB, SCALE_HUB)
	elif t < T_CROUCH_START:
		## B victory dance.
		frame_i = _victory_frame(t)
		pos = _feet0
		sc = Vector2(SCALE_HUB, SCALE_HUB)
	elif t < T_CROUCH_END:
		## C1 crouch squash on f0.
		frame_i = 0
		var u: float = (t - T_CROUCH_START) / (T_CROUCH_END - T_CROUCH_START)
		u = 1.0 - (1.0 - u) * (1.0 - u)  # OUT_QUAD
		var sy: float = lerpf(1.0, 0.86, u)
		var sx: float = lerpf(1.0, 1.08, u)
		sc = Vector2(SCALE_HUB * sx, SCALE_HUB * sy)
		pos = _feet_pivot(_feet0, sc)
	elif t < T_JUMP_UP_END:
		## C2 jump up −40 px, f2 stretch.
		frame_i = mini(2, _victory.size() - 1) if not _victory.is_empty() else 0
		var u: float = (t - T_CROUCH_END) / (T_JUMP_UP_END - T_CROUCH_END)
		u = 1.0 - (1.0 - u) * (1.0 - u)
		pos = Vector2(_feet0.x, lerpf(_feet0.y, _feet0.y - 40.0, u))
		var sy: float = lerpf(1.0, 1.06, u)
		sc = Vector2(SCALE_HUB, SCALE_HUB * sy)
	elif t < T_SWAP:
		## C3 fall off bottom (f2). Under wipe.
		## Front-loaded vs pure t² so freeze_at 1.75 lands Sprout in the lower third
		## while still exiting at vh+16 by 1.92 (shot 05 / 06 continuity).
		frame_i = mini(2, _victory.size() - 1) if not _victory.is_empty() else 0
		var fall_dt: float = T_FALL_OFF_END - T_JUMP_UP_END
		var ft: float = clampf(t - T_JUMP_UP_END, 0.0, fall_dt)
		var fu: float = 0.0 if fall_dt <= 0.001 else ft / fall_dt
		## pow 0.65 ≈ lower-third by t=1.75; still off-screen at fu=1.
		var dist: float = pow(fu, 0.65)
		var y_up: float = _feet0.y - 40.0
		var y_off: float = _vh + 16.0
		var y: float = lerpf(y_up, y_off, dist)
		pos = Vector2(_feet0.x, y)
		sc = Vector2(SCALE_HUB, SCALE_HUB)
		if _hero != null:
			_hero.z_index = 4
	else:
		## E1 fall-in from top → land. Above wipe. Scale 1.5→2.0.
		frame_i = mini(2, _victory.size() - 1) if not _victory.is_empty() else 0
		if _hero != null:
			_hero.z_index = 12
		var land := _resolve_land()
		## Enter above the viewport; 64px × scale 2.0 ≈ 128 drawn height.
		var y0: float = -64.0 * SCALE_ROPE
		var fall_in_dt: float = T_LAND - T_SWAP
		var u: float = 0.0
		if fall_in_dt > 0.001:
			u = clampf((t - T_SWAP) / fall_in_dt, 0.0, 1.0)
		## OUT_QUAD catch from v_exit.
		var ease_u: float = 1.0 - (1.0 - u) * (1.0 - u)
		pos = Vector2(lerpf(_hub_x, land.x, ease_u), lerpf(y0, land.y, ease_u))
		sc = Vector2(lerpf(SCALE_HUB, SCALE_ROPE, ease_u), lerpf(SCALE_HUB, SCALE_ROPE, ease_u))
		if t >= T_LAND:
			## E2 land squash 0.06 s then rebound; handoff on squash frame (option A).
			frame_i = 0
			var lu: float = clampf((t - T_LAND) / (T_DONE - T_LAND), 0.0, 1.0)
			var squash: float = 1.0
			if lu < 0.5:
				squash = lerpf(1.0, 0.88, lu / 0.5)
			else:
				squash = lerpf(0.88, 1.0, (lu - 0.5) / 0.5)
			sc = Vector2(SCALE_ROPE * lerpf(1.0, 1.06, 1.0 - squash), SCALE_ROPE * squash)
			pos = _feet_pivot(land, sc)
			if lu >= 0.85:
				## Overlay hides; rope hero shows (A: squash hides the art pop).
				_hero.visible = false
				for g in _gear:
					if g != null and is_instance_valid(g):
						g.visible = false
				if _rope_exit != null and _rope_exit.has_method("set_hero_hidden"):
					_rope_exit.set_hero_hidden(false)
	## Apply frame + transform.
	if not _victory.is_empty():
		_hero.texture = _victory[clampi(frame_i, 0, _victory.size() - 1)]
	_hero.scale = sc
	_hero.position = pos
	## Gear is native 96×96 (matches hub 96 rect). Hold frame 2 on jump/fall.
	var gear_fi := frame_i
	if t >= T_CROUCH_END and t < T_LAND:
		gear_fi = 2
	if _hero.visible:
		## Scale gear so its drawn size tracks the hero rect (hero 64×1.5 = 96).
		var gsc := Vector2(sc.x / SCALE_HUB, sc.y / SCALE_HUB)
		_sync_gear(_gear_victory, gear_fi, pos, gsc)
	else:
		for g in _gear:
			if g != null and is_instance_valid(g):
				g.visible = false


func _feet_pivot(top_left: Vector2, sc: Vector2) -> Vector2:
	## Keep feet planted while scale changes. sprout_victory is 64×64; hub scale 1.5 → 96.
	var native := 64.0
	var base_drawn := Vector2(native * SCALE_HUB, native * SCALE_HUB)
	var new_drawn := Vector2(native * sc.x, native * sc.y)
	var feet: Vector2 = top_left + Vector2(base_drawn.x * 0.5, base_drawn.y)
	return Vector2(feet.x - new_drawn.x * 0.5, feet.y - new_drawn.y)


func _victory_frame(t: float) -> int:
	if _victory.is_empty():
		return 0
	var fi := 0
	for i in VICTORY_MARKS.size():
		fi = i % _victory.size()
		if t < float(VICTORY_MARKS[i]):
			break
	## After last mark until crouch, hold f3.
	if t >= float(VICTORY_MARKS[VICTORY_MARKS.size() - 1]):
		fi = mini(3, _victory.size() - 1)
	return fi


func _do_swap(t: float) -> void:
	if _swapped:
		return
	_swapped = true
	print("resolve swap t=%.2f" % t)
	if _rope_exit != null:
		_rope_exit.open_instant = true
		if _rope_exit.has_method("set_hero_hidden"):
			## Hide after open_exit resets pose — commit → refresh → open_exit first.
			pass
	## freeze_at holds: still open Rope Exit for shots 06/07, but skip the
	## dungeon-clear save/log so multi-shot Repot sessions don't stack
	## "end dungeon N" rows (RESULT.md note on 2.06/2.40 holds).
	var host = get_parent()
	if host != null and freeze_at >= 0.0:
		host.set("_clear_commit_visual_only", true)
	if _on_swap.is_valid():
		_on_swap.call()
	## After commit/open_exit, hide rope hero until E2 handoff (L5).
	_rope_exit = _find_rope()
	if _rope_exit != null and _rope_exit.has_method("set_hero_hidden"):
		_rope_exit.set_hero_hidden(true)
	_land_tl = _resolve_land()
	if _wheel != null and is_instance_valid(_wheel):
		_wheel.fold = 0.0


func _apply_chrome_fade(t: float) -> void:
	var chrome_a: float = 1.0 - clampf(t / T_CHROME_END, 0.0, 1.0)
	var hide := chrome_a <= 0.02
	for n in _chrome_nodes:
		if n == null or not is_instance_valid(n):
			continue
		var m: Color = n.modulate
		m.a = chrome_a
		n.modulate = m
		## Hard-hide after fade so main's per-frame spin pulse (sets a=1) and
		## _sync_buttons (phase still ready) cannot bring Spin back mid-resolve.
		if hide and n is CanvasItem:
			(n as CanvasItem).visible = false


func _resolve_land() -> Vector2:
	if _rope_exit != null and _rope_exit.has_method("hero_land_global"):
		return _rope_exit.hero_land_global()
	if _land_tl != Vector2.ZERO:
		return _land_tl
	return Vector2(_hub_x, 208.0 * 4.0 / 4.0)


func _play_sting_clear() -> void:
	var host = get_parent()
	if host == null:
		return
	var sfx = host.get("sfx")
	if sfx != null and sfx.has_method("play_event"):
		sfx.play_event(&"sting.clear")


func _find_rope():
	var host = get_parent()
	if host == null:
		return null
	return host.get("rope_exit")


func _cache_chrome() -> void:
	_chrome_nodes.clear()
	var host = get_parent()
	if host == null:
		return
	for key in ["btn_spin", "btn_move_left", "btn_move_right", "move_count", "take_arc", "hub_cue"]:
		var n = host.get(key)
		if n != null:
			_chrome_nodes.append(n)


func _build_wipe() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform float progress = 0.0;
uniform float soft = 0.08;
uniform sampler2D noise_tex : repeat_enable, filter_nearest;
void fragment() {
	float n = texture(noise_tex, UV * vec2(6.0, 4.0)).r * 0.18;
	float h = 1.0 - UV.y + n;
	float lead = progress;
	float trail = progress - 1.0;
	float a = smoothstep(lead + soft, lead - soft, h) * smoothstep(trail - soft, trail + soft, h);
	COLOR = vec4(0.0, 0.0, 0.0, a);
}
"""
	_wipe_mat = ShaderMaterial.new()
	_wipe_mat.shader = sh
	var noise := FastNoiseLite.new()
	noise.seed = 7
	noise.frequency = 0.08
	var ntex := NoiseTexture2D.new()
	ntex.width = 128
	ntex.height = 128
	ntex.seamless = true
	ntex.noise = noise
	## Nearest filter for chunky dissolve teeth (pixel art).
	_wipe_mat.set_shader_parameter("noise_tex", ntex)
	_wipe_mat.set_shader_parameter("progress", 0.0)
	_wipe_mat.set_shader_parameter("soft", 0.08)
	_wipe = ColorRect.new()
	_wipe.name = "ResolveWipe"
	_wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe.z_index = 10
	_wipe.material = _wipe_mat
	_wipe.color = Color(0, 0, 0, 1)
	_wipe.visible = false
	_layer.add_child(_wipe)
	if get_viewport() != null:
		_wipe.size = get_viewport().get_visible_rect().size


func _build_aura(hub: Vector2) -> void:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color("e8c36a", 0.85), Color("e8c36a", 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.width = 64
	gtex.height = 64
	gtex.fill = GradientTexture2D.FILL_RADIAL
	gtex.fill_from = Vector2(0.5, 0.5)
	gtex.fill_to = Vector2(1.0, 0.5)
	_aura = Sprite2D.new()
	_aura.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_aura.centered = true
	_aura.z_index = 3
	_aura.texture = gtex
	## Hinge = bottom of wheel ≈ hub + (0, radius*0.9). Approximate from hub.
	_aura.position = hub + Vector2(0, 160)
	_aura.visible = false
	_aura.modulate = Color(1, 1, 1, 0)
	_layer.add_child(_aura)


func _teardown() -> void:
	## Restore chrome alpha/visibility (rest phase hides them anyway; ready
	## paths re-show via _sync_buttons).
	for n in _chrome_nodes:
		if n != null and is_instance_valid(n):
			var m: Color = n.modulate
			m.a = 1.0
			n.modulate = m
	if is_instance_valid(_layer):
		_layer.queue_free()
		_layer = null


func _sprout_victory(art) -> Array:
	if art != null and art.has_method("sprout_anim"):
		return art.sprout_anim("victory")
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
		var sp := _make_raw(frames[0], pos, 5)
		sp.scale = Vector2.ONE
		_gear.append(sp)


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
		sp.z_index = 5 if _hero == null else _hero.z_index + 1


func _first(frames: Array) -> Texture2D:
	if frames.is_empty():
		return null
	return frames[0]


func _make_hero(tex: Texture2D, pos: Vector2, z: int) -> Sprite2D:
	var sp := _make_raw(tex, pos, z)
	## sprout_victory is 64×64; hub draws at 96 → scale 1.5 (L6).
	sp.scale = Vector2(SCALE_HUB, SCALE_HUB)
	return sp


func _make_raw(tex: Texture2D, pos: Vector2, z: int) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.centered = false
	sp.flip_h = false
	sp.z_index = z
	sp.position = pos
	sp.texture = tex
	sp.visible = tex != null
	_layer.add_child(sp)
	return sp


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
