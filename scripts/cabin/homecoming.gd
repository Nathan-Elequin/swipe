class_name Homecoming
extends Node
## Package C — post-run satchel → slot timeline on the TrophyBoard.
## Owns the SCREEN §6 beats. Thin cabin call-site only.


const HOMECOMING_STEP := 2.0
## First-return unpack pace (Nathan lock 2026-11-14). Normal returns stay at 2.0s.
const FIRST_RETURN_STEP := 1.2
## Satchel / skip chrome from SCREEN §2. Slot fly targets come from TrophyBoard at runtime.
const SATCHEL_RECT := Rect2(744, 872, 192, 160)
const SATCHEL_OFF_Y := 1040.0
## Mouth at native (24,5) on the 48×40 satchel → ×4 px within the satchel rect.
const SATCHEL_MOUTH_LOCAL := Vector2(96, 20)
const RISE_LIFT := 132.0
const SKIP_RECT := Rect2(1504, 984, 152, 40)
const FLY_LIFT := 220.0
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

signal finished
signal item_placed(card_id: String)
signal light_flashed(face_index: int, light_index: int)
signal skipped
signal first_light_paused
signal first_light_resumed

## Observability for selftests (filled during run).
var placed_order: Array = []
var face_change_count: int = 0
var light_flash_count: int = 0
var skipped_mid: bool = false
var first_return_branch: String = ""  ## "" | "empty" | "unpack"
var first_light_did_pause: bool = false

var board = null
var cabin = null
var sfx = null
var reduce_motion: bool = false
var is_first_return: bool = false

var _ceremony_gen: int = -1
var _skip_requested: bool = false
var _skip_btn: Button = null
var _satchel: Control = null
var _host: Control = null
var _active_tweens: Array = []
var _fx_nodes: Array = []
var _running: bool = false
var _step_s: float = HOMECOMING_STEP
var _lever_ring: Control = null


## Entry. Adds self under cabin (or board), runs the timeline, then frees.
static func run(p_board, p_cabin, p_sfx = null) -> Homecoming:
	var h := Homecoming.new()
	h.board = p_board
	h.cabin = p_cabin
	h.sfx = p_sfx
	h.reduce_motion = _read_reduce_motion(p_cabin, p_board)
	var parent: Node = p_cabin if p_cabin is Node else p_board
	parent.add_child(h)
	await h._run()
	return h


static func _read_reduce_motion(p_cabin, p_board) -> bool:
	## Package E owns the setting. Read defensively until then.
	if p_cabin != null and "reduce_motion" in p_cabin:
		return bool(p_cabin.reduce_motion)
	if p_board != null and "reduce_motion" in p_board:
		return bool(p_board.reduce_motion)
	return false


func request_skip() -> void:
	_skip_requested = true
	skipped_mid = true
	_kill_active()
	skipped.emit()


func _run() -> void:
	_running = true
	placed_order.clear()
	face_change_count = 0
	light_flash_count = 0
	_skip_requested = false
	skipped_mid = false
	first_return_branch = ""
	first_light_did_pause = false
	if board == null or cabin == null:
		_finish()
		return
	if reduce_motion and "reduce_motion" in board:
		board.reduce_motion = true
	_host = cabin
	_ceremony_gen = -1
	if cabin.has_method("_begin_bank_ceremony"):
		_ceremony_gen = int(cabin.call("_begin_bank_ceremony"))
	is_first_return = _detect_first_return()
	_step_s = FIRST_RETURN_STEP if is_first_return else HOMECOMING_STEP
	var pending: Array = _ordered_pending()
	## Open on first pending face (instant — satchel rise is the first motion).
	if not pending.is_empty():
		var first_face: int = int(_meta_for(str(pending[0])).get("face_index", 0))
		await _slide_board(first_face, true)
	elif board.has_method("current_face"):
		## Nothing pending — leave board on saved face (board already snapped).
		pass
	## First return: Nib intro, then empty vs unpack branch. Never during key tour.
	if is_first_return:
		await _say_keys(["nib.board.first_look"], {})
		if pending.is_empty():
			first_return_branch = "empty"
			await _say_keys(["nib.board.first_empty"], {})
			_mark_first_return_done()
			_finish()
			return
		first_return_branch = "unpack"
		await _say_keys(["nib.board.first_unpack"], {})
	## Empty pending (later returns) → Nib line, no satchel.
	elif pending.is_empty():
		await _say_empty_or_loss()
		_finish()
		return
	_build_skip_button()
	await _raise_satchel()
	if _stale():
		_finish()
		return
	var i := 0
	while i < pending.size():
		if _skip_requested or _stale():
			break
		var id: String = str(pending[i])
		await _play_one_item(id)
		if _stale():
			break
		## First return: short Nib comment after the first item lands.
		if is_first_return and i == 0 and not _skip_requested:
			await _say_keys(["nib.board.first_placed"], {})
		i += 1
	if _skip_requested and not _stale():
		await _skip_rest(pending)
	if not _stale():
		await _drop_satchel()
	if not _stale() and is_first_return and not placed_order.is_empty():
		await _say_keys(["nib.board.first_hover_hint"], {})
		_start_first_pulse(str(placed_order[0]))
		_mark_first_return_done()
	elif not _stale() and is_first_return:
		_mark_first_return_done()
	if not _stale():
		await _after_items()
	_finish()


func _detect_first_return() -> bool:
	if cabin == null:
		return false
	if _cabin_flag("first_return_homecoming_done"):
		return false
	var kind := _cabin_str("_homecoming_kind", "win")
	## First successful dungeon return only (after key-ring / Nib relocate).
	return kind == "win" and _cabin_flag("key_ring_seen")


func _cabin_flag(prop: String) -> bool:
	if cabin == null:
		return false
	if prop in cabin:
		return bool(cabin.get(prop))
	return false


func _cabin_str(prop: String, fallback: String) -> String:
	if cabin == null:
		return fallback
	if prop in cabin:
		return str(cabin.get(prop))
	return fallback


func _mark_first_return_done() -> void:
	if cabin == null:
		return
	if "first_return_homecoming_done" in cabin:
		cabin.first_return_homecoming_done = true
	if cabin.has_method("_save"):
		cabin.call("_save")


func _start_first_pulse(card_id: String) -> void:
	if cabin == null or card_id == "":
		return
	if _cabin_flag("first_board_hover_done"):
		return
	if "board_pulse_id" in cabin:
		cabin.board_pulse_id = card_id
	if board != null and board.has_method("set_pulse_id"):
		board.set_pulse_id(card_id)
	if cabin.has_method("_save"):
		cabin.call("_save")


func _ordered_pending() -> Array:
	var raw: Array = []
	if "bank_pending" in cabin:
		raw = (cabin.bank_pending as Array).duplicate()
	var rules: Dictionary = _rules()
	var items: Dictionary = _items()
	var faces: Array = MODEL.faces(rules, items)
	## Filter to board members only.
	var filtered: Array = []
	for rid in raw:
		var id := str(rid)
		if id == "":
			continue
		var meta: Dictionary = _meta_for(id, faces)
		if int(meta.get("face_index", -1)) < 0:
			continue
		filtered.append(id)
	filtered.sort_custom(func(a, b) -> bool:
		var ma: Dictionary = _meta_for(str(a), faces)
		var mb: Dictionary = _meta_for(str(b), faces)
		var fa: int = int(ma.get("face_index", 99))
		var fb: int = int(mb.get("face_index", 99))
		if fa != fb:
			return fa < fb
		var ta: int = int(ma.get("tier", 1))
		var tb: int = int(mb.get("tier", 1))
		if ta != tb:
			return ta < tb
		return int(ma.get("slot", 0)) < int(mb.get("slot", 0))
	)
	return filtered


func _meta_for(id: String, faces: Array = []) -> Dictionary:
	if faces.is_empty():
		faces = MODEL.faces(_rules(), _items())
	for face in faces:
		if typeof(face) != TYPE_DICTIONARY:
			continue
		var f: Dictionary = face
		var rows: Dictionary = f.get("rows", {})
		for tier in [1, 2, 3]:
			var line: Array = rows.get(tier, [])
			if not (line is Array):
				continue
			var idx: int = (line as Array).find(id)
			if idx >= 0:
				return {
					"face_index": int(f.get("index", 0)),
					"tier": tier,
					"slot": idx,
					"pool_id": str(f.get("pool_id", "")),
					"name": str(f.get("name", "")),
				}
	return {"face_index": -1, "tier": 1, "slot": 0}


func _play_one_item(card_id: String) -> void:
	var meta: Dictionary = _meta_for(card_id)
	var face_i: int = int(meta.get("face_index", 0))
	## Pre: slide if face changes (satchel stays).
	if board.has_method("current_face") and int(board.current_face()) != face_i:
		await _slide_board(face_i, false)
		if _stale() or _skip_requested:
			return
	var lights_before: int = _lights_lit_now(face_i)
	if reduce_motion:
		await _place_reduce_motion(card_id, face_i, lights_before)
		return
	## 0.00 satchel jostle
	_play_satchel_anim("open")
	_cue("board.satchel_rustle")
	await _wait_step(0.10)
	if _stale() or _skip_requested:
		return
	## 0.10 rise — mouth / peak from the live satchel rect (not hardcoded slot coords).
	var mouth: Vector2 = _satchel_mouth()
	var rise_peak: Vector2 = Vector2(mouth.x, mouth.y - RISE_LIFT)
	var spr: Sprite2D = _make_item_sprite(card_id)
	spr.position = mouth
	spr.scale = Vector2(0.5, 0.5)
	_host.add_child(spr)
	_track_fx(spr)
	var glint: AnimatedSprite2D = _ui_anim(
		["trophy_board/rise_glint_f0", "trophy_board/rise_glint_f1", "trophy_board/rise_glint_f2",
			"trophy_board/rise_glint_f3", "trophy_board/rise_glint_f4", "trophy_board/rise_glint_f5"],
		"glint", 15.0, false
	)
	if glint != null:
		glint.centered = true
		glint.position = mouth
		glint.z_index = 20
		_host.add_child(glint)
		_track_fx(glint)
		glint.play("glint")
	_cue("board.rise_glint")
	var rise_tw := _tween()
	rise_tw.set_parallel(true)
	rise_tw.tween_property(spr, "position", rise_peak, _dur(0.40)).set_ease(Tween.EASE_OUT)
	rise_tw.tween_property(spr, "scale", Vector2.ONE, _dur(0.40)).set_ease(Tween.EASE_OUT)
	if glint != null:
		rise_tw.tween_property(glint, "position", rise_peak, _dur(0.40)).set_ease(Tween.EASE_OUT)
	await _await_tween(rise_tw)
	if is_instance_valid(glint):
		glint.queue_free()
		_untrack_fx(glint)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	## 0.50 hang 0.15s with ±2px bob
	var bob_tw := _tween()
	bob_tw.tween_property(spr, "position:y", rise_peak.y - 2.0, _dur(0.075))
	bob_tw.tween_property(spr, "position:y", rise_peak.y + 2.0, _dur(0.075))
	await _await_tween(bob_tw)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	## 0.65 fly — destination from TrophyBoard.slot_global_center (runtime layout).
	var to_global: Vector2 = board.slot_global_center(card_id)
	var to_local: Vector2 = _to_host_local(to_global)
	var mid: Vector2 = (rise_peak + to_local) * 0.5 + Vector2(0, -FLY_LIFT)
	var slot_scale: Vector2 = _slot_scale_for(card_id)
	_attach_fly_spark(spr)
	_cue("board.whoosh")
	var fly_tw := _tween()
	fly_tw.set_parallel(true)
	fly_tw.tween_method(func(t: float) -> void:
		if is_instance_valid(spr):
			spr.position = _quad_bez(rise_peak, mid, to_local, t)
	, 0.0, 1.0, _dur(0.55)).set_ease(Tween.EASE_IN_OUT)
	fly_tw.tween_property(spr, "scale", slot_scale, _dur(0.55)).set_ease(Tween.EASE_IN_OUT)
	await _await_tween(fly_tw)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	## 1.20 poof + claim
	await _poof_at(to_local)
	_free_fx(spr)
	_claim_item(card_id)
	placed_order.append(card_id)
	item_placed.emit(card_id)
	## 1.45 light if raised
	var lights_after: int = _lights_lit_now(face_i)
	if lights_after > lights_before and lights_after <= 5:
		await _flash_light(face_i, lights_after - 1, lights_after)
	## Hold until step end (2.00 normal / 1.2 first return)
	var spent: float = 1.45
	if lights_after > lights_before:
		spent = 1.70
	## Scale spent into the active step so first-return stays ~1.2s.
	var scale: float = _step_s / HOMECOMING_STEP
	var remain: float = maxf(0.0, _step_s - spent * scale)
	if remain > 0.0:
		await _wait_step(remain)


func _place_reduce_motion(card_id: String, face_i: int, lights_before: int) -> void:
	## Fade into slot 0.25s, poof, 0.6s hold → T ≈ 0.9s. No fly.
	var to_global: Vector2 = board.slot_global_center(card_id)
	var to_local: Vector2 = _to_host_local(to_global)
	var spr: Sprite2D = _make_item_sprite(card_id)
	spr.position = to_local
	spr.modulate.a = 0.0
	spr.scale = _slot_scale_for(card_id)
	_host.add_child(spr)
	_track_fx(spr)
	var tw := _tween()
	tw.tween_property(spr, "modulate:a", 1.0, _dur(0.25))
	await _await_tween(tw)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	await _poof_at(to_local)
	_free_fx(spr)
	_claim_item(card_id)
	placed_order.append(card_id)
	item_placed.emit(card_id)
	var lights_after: int = _lights_lit_now(face_i)
	if lights_after > lights_before and lights_after <= 5:
		## Instant light, chime stays.
		if board.has_method("flash_light"):
			board.flash_light(face_i, lights_after - 1)
		_chime_light(lights_after)
		light_flash_count += 1
		light_flashed.emit(face_i, lights_after - 1)
		if lights_after == 1 and cabin != null and not _cabin_flag("first_light_seen"):
			await _play_first_light_scene(face_i)
		else:
			_maybe_light_bubble(lights_after)
	await _wait_step(0.6)


func _skip_rest(pending: Array) -> void:
	## Instant-claim remaining; jump board to last item's face; one poof + one chime if lights changed.
	var any_light := false
	var last_face := 0
	var lights_snap: Dictionary = {}
	for id_raw in pending:
		var id := str(id_raw)
		if placed_order.has(id):
			continue
		var meta: Dictionary = _meta_for(id)
		var fi: int = int(meta.get("face_index", 0))
		last_face = fi
		if not lights_snap.has(fi):
			lights_snap[fi] = _lights_lit_now(fi)
		var before: int = int(lights_snap[fi])
		_claim_item(id)
		placed_order.append(id)
		item_placed.emit(id)
		var after: int = _lights_lit_now(fi)
		lights_snap[fi] = after
		if after > before:
			any_light = true
			if board.has_method("flash_light"):
				board.flash_light(fi, after - 1)
	if board.has_method("slide_to"):
		board.slide_to(last_face, true)
	_cue("board.poof")
	if any_light:
		_cue("board.light_chime")
		light_flash_count += 1
	## Save once on skip (acks already saved per item; final sync).
	if cabin.has_method("_save"):
		cabin.call("_save")


func _claim_item(card_id: String) -> void:
	if board != null and board.has_method("place_claimed"):
		board.place_claimed(card_id, not reduce_motion)
	if cabin != null and cabin.has_method("_ack_bank_presented"):
		cabin.call("_ack_bank_presented", card_id, _ceremony_gen)
	## Keep board hold list in sync so pips / lights read claimed.
	if board != null and board.has_method("set_hold") and "bank_pending" in cabin:
		board.set_hold(cabin.bank_pending)
	elif board != null and board.has_method("refresh"):
		## Fallback: full refresh after hold drain.
		pass


func _flash_light(face_i: int, light_index: int, light_n: int) -> void:
	if board != null and board.has_method("flash_light"):
		board.flash_light(face_i, light_index)
	_chime_light(light_n)
	light_flash_count += 1
	light_flashed.emit(face_i, light_index)
	## Package E: Nib reacts on every light.
	if cabin != null and cabin.has_method("nib_react"):
		cabin.nib_react()
	## First-ever board light: pause the unpack for the discovery scene.
	if light_n == 1 and cabin != null and not _cabin_flag("first_light_seen"):
		await _play_first_light_scene(face_i)
	else:
		_maybe_light_bubble(light_n)
	## Flash frames ~0.25s; pad a bit before next item.
	await _wait_step(0.25)


## Pause unpack: Nib reacts, gestures at lever with a glowing ring, then resume.
func _play_first_light_scene(face_i: int) -> void:
	first_light_did_pause = true
	first_light_paused.emit()
	if cabin != null and "first_light_seen" in cabin:
		cabin.first_light_seen = true
		if cabin.has_method("_save"):
			cabin.call("_save")
	await _say_keys(["nib.board.first_light.1"], {})
	_show_lever_ring(true)
	await _say_keys(["nib.board.first_light.2"], {})
	## Keep a faint lever glow from now until READY (5 lights).
	if board != null and board.has_method("set_lever_faint_glow"):
		board.set_lever_faint_glow(true)
	_show_lever_ring(false)
	first_light_resumed.emit()
	## Refresh so faint glow applies on the current face.
	if board != null and board.has_method("refresh"):
		board.refresh()
	if face_i >= 0 and board != null and board.has_method("slide_to"):
		## Stay on this face.
		pass


func _show_lever_ring(on: bool) -> void:
	if not on:
		if _lever_ring != null and is_instance_valid(_lever_ring):
			_free_fx(_lever_ring)
		_lever_ring = null
		return
	var anchor: Control = null
	if board != null and board.has_method("lever_node"):
		anchor = board.lever_node()
	_lever_ring = Control.new()
	_lever_ring.name = "LeverAuraRing"
	_lever_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lever_ring.z_index = 50
	var sz := Vector2(160, 200)
	_lever_ring.size = sz
	if anchor != null and is_instance_valid(anchor):
		var g: Rect2 = anchor.get_global_rect()
		_lever_ring.global_position = g.position + g.size * 0.5 - sz * 0.5
	else:
		_lever_ring.position = Vector2(1360, 560)
	var ring := ColorRect.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.color = Color(1.0, 0.85, 0.3, 0.35)
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lever_ring.add_child(ring)
	_host.add_child(_lever_ring)
	_track_fx(_lever_ring)
	if reduce_motion:
		## Static highlight — no orbit.
		ring.color = Color(1.0, 0.85, 0.3, 0.55)
		return
	## Gentle pulse / orbit substitute: alpha breathe.
	var tw := _tween()
	tw.set_loops(12)
	tw.tween_property(ring, "modulate:a", 0.25, _dur(0.45))
	tw.tween_property(ring, "modulate:a", 0.85, _dur(0.45))


func _chime_light(light_n: int) -> void:
	## Baked pentatonic chimes (C5–D5–E5–G5–A5). Light i plays board.light_chime_i.
	var n: int = clampi(light_n, 1, 5)
	var numbered: String = "board.light_chime_%d" % n
	if sfx != null and sfx.has_method("play_event"):
		if _has_cue(numbered):
			sfx.play_event(StringName(numbered))
			return
		if _has_cue("board.light_chime"):
			sfx.play_event(&"board.light_chime")
			return
		sfx.play_event(&"cabin.shelf_chime")
		return
	_cue(numbered, "cabin.shelf_chime")


func _maybe_light_bubble(light_n: int) -> void:
	if light_n != 1 and light_n != 5:
		return
	if cabin == null or not ("_dialog" in cabin):
		return
	var dialog = cabin._dialog
	if dialog == null:
		return
	var key := "board.light.say.%d" % light_n
	var fallback := "There's a light!" if light_n == 1 else "Five! That's all five!"
	if dialog.has_method("say_bubble"):
		dialog.say_bubble(key, Vector2(216, 150), {})
	elif dialog.has_method("say"):
		dialog.say([key], [], {}, {key: fallback})


func _after_items() -> void:
	## Refresh so lights / lever_state match the just-acked claims.
	if board != null and board.has_method("refresh"):
		board.refresh()
	## (a) Any face whose lever just became READY → prompt. Nothing auto-pulls.
	## (b) Complete boards → Package D BoardSequences via cabin (shortcut / ending).
	var rules: Dictionary = _rules()
	var state: Dictionary = _state()
	var faces: Array = MODEL.faces(rules, _items())
	var ready_face := -1
	for face in faces:
		if typeof(face) != TYPE_DICTIONARY:
			continue
		var f: Dictionary = face
		var fi: int = int(f.get("index", 0))
		if MODEL.lever_state(rules, state, f) == &"ready" and ready_face < 0:
			ready_face = fi
	if ready_face >= 0:
		await _slide_board(ready_face, false)
		if board != null and board.has_method("refresh"):
			board.refresh()
		if board != null and board.has_method("set_lever_ready_fx"):
			board.set_lever_ready_fx(true)
		_cue("board.lever_ready")
		if cabin != null and cabin.has_method("nib_react"):
			cabin.nib_react()
		var biome_name := str((faces[ready_face] as Dictionary).get("name", ""))
		await _say_keys([
			"nib.board.lever_ready.1",
			"nib.board.lever_ready.2",
		], {"biome": biome_name})
		## Nothing auto-pulls — portal runs only on lever_pulled (Package D owns that).
	## Hand off 100% / shortcut / Abyss-complete to Package D. Do not reimplement.
	if cabin != null and cabin.has_method("_maybe_run_board_complete_sequences"):
		await cabin.call("_maybe_run_board_complete_sequences")


func _say_empty_or_loss() -> void:
	var kind := "win"
	if cabin != null and "_homecoming_kind" in cabin:
		kind = str(cabin._homecoming_kind)
	if kind == "loss":
		await _say_random(["nib.home.loss.1", "nib.home.loss.2", "nib.home.loss.3"])
	else:
		await _say_random(["nib.board.empty.1", "nib.board.empty.2"])


func _say_random(keys: Array) -> void:
	if keys.is_empty():
		return
	var pick: String = str(keys[randi() % keys.size()])
	await _say_keys([pick], {})


func _say_keys(keys: Array, vars: Dictionary) -> void:
	if cabin == null or not ("_dialog" in cabin):
		return
	var dialog = cabin._dialog
	if dialog == null or not dialog.has_method("say"):
		return
	var fallbacks := {}
	for k in keys:
		fallbacks[str(k)] = COPY.fill(str(k), vars, COPY.text(str(k), str(k)))
	dialog.say(keys, [], vars, fallbacks)
	if dialog.has_signal("finished"):
		await dialog.finished


# --- satchel / skip / fx ------------------------------------------------------


func _raise_satchel() -> void:
	_satchel = _make_satchel()
	_host.add_child(_satchel)
	_track_fx(_satchel)
	_satchel.position = Vector2(SATCHEL_RECT.position.x, SATCHEL_OFF_Y)
	_cue("board.satchel_in")
	if reduce_motion:
		_satchel.position = SATCHEL_RECT.position
		return
	var tw := _tween()
	tw.tween_property(_satchel, "position:y", SATCHEL_RECT.position.y, _dur(0.35)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _await_tween(tw)


func _drop_satchel() -> void:
	if _satchel == null or not is_instance_valid(_satchel):
		return
	_play_satchel_anim("close")
	_cue("board.satchel_out")
	if reduce_motion:
		_free_fx(_satchel)
		_satchel = null
		return
	var tw := _tween()
	tw.tween_property(_satchel, "position:y", SATCHEL_OFF_Y, _dur(0.30))
	await _await_tween(tw)
	_free_fx(_satchel)
	_satchel = null


func _make_satchel() -> Control:
	var wrap := Control.new()
	wrap.name = "HomecomingSatchel"
	wrap.size = SATCHEL_RECT.size
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.z_index = 30
	var idle: Texture2D = KIT.ui_tex("trophy_board/satchel_idle")
	if idle != null:
		var tr := TextureRect.new()
		tr.name = "Art"
		tr.texture = idle
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(tr)
	else:
		var box := ColorRect.new()
		box.color = Color("5c3a22")
		box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(box)
	return wrap


func _play_satchel_anim(which: String) -> void:
	if _satchel == null or not is_instance_valid(_satchel):
		return
	var art = _satchel.get_node_or_null("Art")
	if art == null or not (art is TextureRect):
		return
	var frames: Array = []
	if which == "open":
		frames = ["trophy_board/satchel_open_f0", "trophy_board/satchel_open_f1",
			"trophy_board/satchel_open_f2", "trophy_board/satchel_open_f3"]
	else:
		frames = ["trophy_board/satchel_close_f0", "trophy_board/satchel_close_f1",
			"trophy_board/satchel_close_f2"]
	## Fire-and-forget frame flip at 12 fps.
	_satchel_frame_flip(art as TextureRect, frames, 12.0)


func _satchel_frame_flip(art: TextureRect, frames: Array, fps: float) -> void:
	for stem in frames:
		if not is_instance_valid(art):
			return
		var tex: Texture2D = KIT.ui_tex(str(stem))
		if tex != null:
			art.texture = tex
		await _wait_step(1.0 / fps)


func _build_skip_button() -> void:
	_skip_btn = Button.new()
	_skip_btn.name = "HomecomingSkip"
	_skip_btn.text = COPY.text("board.skip", "Skip")
	_skip_btn.position = SKIP_RECT.position
	_skip_btn.size = SKIP_RECT.size
	_skip_btn.focus_mode = Control.FOCUS_NONE
	_skip_btn.modulate = Color(1, 1, 1, 0.40)
	_skip_btn.z_index = 40
	_skip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_skip_btn.pressed.connect(request_skip)
	_skip_btn.mouse_entered.connect(func() -> void:
		if is_instance_valid(_skip_btn):
			_skip_btn.modulate = Color(1, 1, 1, 0.85)
	)
	_skip_btn.mouse_exited.connect(func() -> void:
		if is_instance_valid(_skip_btn):
			_skip_btn.modulate = Color(1, 1, 1, 0.40)
	)
	_host.add_child(_skip_btn)
	_track_fx(_skip_btn)


func _poof_at(at_local: Vector2) -> void:
	_cue("board.poof")
	var poof: AnimatedSprite2D = _ui_anim(
		["trophy_board/poof_f0", "trophy_board/poof_f1", "trophy_board/poof_f2",
			"trophy_board/poof_f3", "trophy_board/poof_f4"],
		"poof", 20.0, false
	)
	if poof == null:
		await _wait_step(0.25)
		return
	poof.centered = true
	poof.position = at_local
	poof.z_index = 25
	_host.add_child(poof)
	_track_fx(poof)
	poof.play("poof")
	if poof.sprite_frames and poof.sprite_frames.get_frame_count("poof") > 0:
		await poof.animation_finished
	else:
		await _wait_step(0.25)
	_free_fx(poof)


func _make_item_sprite(card_id: String) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.name = "Fly_%s" % card_id
	spr.centered = true
	spr.z_index = 24
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex: Texture2D = null
	if cabin != null and "tex_by_item" in cabin:
		tex = cabin.tex_by_item.get(card_id, null)
	if tex == null and cabin != null and "art" in cabin and cabin.art != null and cabin.art.has_method("item_tex"):
		tex = cabin.art.item_tex(card_id)
	if tex != null:
		spr.texture = tex
	else:
		## Stand-in chip when texture missing.
		var chip := ColorRect.new()
		chip.color = Color("ffd84a")
		chip.size = Vector2(48, 48)
		chip.position = Vector2(-24, -24)
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spr.add_child(chip)
	return spr


func _satchel_mouth() -> Vector2:
	## Live satchel position + ASSETS mouth offset. Falls back to rect constant.
	if _satchel != null and is_instance_valid(_satchel):
		return _satchel.position + SATCHEL_MOUTH_LOCAL
	return SATCHEL_RECT.position + SATCHEL_MOUTH_LOCAL


func _slot_scale_for(card_id: String) -> Vector2:
	## Prefer the live slot node's size (layout / plaque may change). Else model rect.
	var slot_sz := MODEL.SLOT_NORMAL
	if board != null and board.has_method("slot_node"):
		var slot = board.slot_node(card_id)
		if slot != null and slot is Control and (slot as Control).size.x > 1.0:
			slot_sz = minf((slot as Control).size.x, (slot as Control).size.y)
		else:
			var faces: Array = MODEL.faces(_rules(), _items())
			var meta: Dictionary = _meta_for(card_id, faces)
			var fi: int = int(meta.get("face_index", 0))
			if fi >= 0 and fi < faces.size():
				var lay: Dictionary = MODEL.layout(faces[fi])
				var rects: Dictionary = lay.get("rects", {})
				if rects.has(card_id):
					var r: Rect2 = rects[card_id]
					slot_sz = minf(r.size.x, r.size.y)
				elif str(lay.get("mode", "")) == "compact":
					slot_sz = MODEL.SLOT_COMPACT
	var tex_w := 32.0
	if cabin != null and "tex_by_item" in cabin:
		var tex: Texture2D = cabin.tex_by_item.get(card_id, null)
		if tex != null:
			tex_w = float(tex.get_width())
	if tex_w <= 0.0:
		tex_w = 32.0
	var s: float = slot_sz / tex_w
	return Vector2(s, s)


func _attach_fly_spark(spr: Sprite2D) -> void:
	var spark: AnimatedSprite2D = null
	## Prefer dungeon home fly sparks (ASSETS reuse).
	if KIT.load_tex("fx/fly_spark_f0.png") != null:
		spark = KIT.anim_sprite(
			["fx/fly_spark_f0.png", "fx/fly_spark_f1.png", "fx/fly_spark_f2.png"],
			"spark", 12.5, true, Vector2.ZERO
		)
	if spark != null:
		spark.centered = true
		spark.z_index = 1
		spr.add_child(spark)
		if spark.sprite_frames:
			spark.play("spark")


func _ui_anim(stems: Array, anim: String, fps: float, loop: bool) -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	var any := false
	for stem in stems:
		var tex: Texture2D = KIT.ui_tex(str(stem))
		if tex != null:
			sf.add_frame(anim, tex)
			any = true
	if not any:
		return null
	var sp := AnimatedSprite2D.new()
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.sprite_frames = sf
	return sp


# --- board / cabin helpers ----------------------------------------------------


func _slide_board(index: int, instant: bool) -> void:
	if board == null or not board.has_method("slide_to"):
		return
	var cur := int(board.current_face()) if board.has_method("current_face") else -1
	if cur != index:
		face_change_count += 1
		if not instant:
			_cue("board.slide")
	## Await the coroutine itself. slide_to may emit slide_done synchronously
	## (already-on-face / instant) before a signal waiter can connect — that hung selftests.
	await board.slide_to(index, instant or reduce_motion)


func _lights_lit_now(face_i: int) -> int:
	var faces: Array = MODEL.faces(_rules(), _items())
	if face_i < 0 or face_i >= faces.size():
		return 0
	var held: Array = []
	if cabin != null and "bank_pending" in cabin:
		held = cabin.bank_pending
	return MODEL.lights_lit(_rules(), _state(), faces[face_i], held)


func _rules() -> Dictionary:
	if cabin != null and cabin.has_method("_biome_rules"):
		return cabin.call("_biome_rules")
	return CAMPAIGN_SHELL.read_json(CAMPAIGN_SHELL.DATA_PATH)


func _items() -> Dictionary:
	if cabin != null and "items_by_id" in cabin:
		return cabin.items_by_id
	return {}


func _state() -> Dictionary:
	if cabin != null and "_campaign_shell" in cabin and cabin._campaign_shell != null:
		return cabin._campaign_shell.state
	if cabin != null and cabin.has_method("_campaign_shell_state"):
		return cabin.call("_campaign_shell_state")
	return CAMPAIGN_SHELL.fresh_state()


func _to_host_local(global_pt: Vector2) -> Vector2:
	if _host == null:
		return global_pt
	return _host.get_global_transform_with_canvas().affine_inverse() * global_pt


func _quad_bez(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * (u * u) + b * (2.0 * u * t) + c * (t * t)


# --- timing / ownership / cleanup ---------------------------------------------


func _dur(sec: float) -> float:
	## Respect Engine.time_scale: higher scale → shorter wall time.
	return sec / maxf(Engine.time_scale, 0.001)


func _wait_step(sec: float) -> void:
	if sec <= 0.0:
		return
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(_dur(sec), true, false, true).timeout


func _tween() -> Tween:
	## Bind to the SceneTree so headless --script selftests still advance tweens
	## (node-bound create_tween can stall when the host cabin has process off).
	var tree := get_tree()
	var tw: Tween = tree.create_tween() if tree != null else create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_active_tweens.append(tw)
	return tw


func _await_tween(tw: Tween) -> void:
	if tw == null:
		return
	if not is_instance_valid(tw) or not tw.is_valid():
		return
	## Already finished (zero-duration / same-frame) — do not await finished (hangs).
	if not tw.is_running():
		return
	while is_instance_valid(tw) and tw.is_valid() and tw.is_running():
		if _skip_requested or _stale():
			tw.kill()
			return
		var tree := get_tree()
		if tree == null:
			return
		await tree.process_frame


func _kill_active() -> void:
	for raw in _active_tweens:
		var tw: Tween = raw as Tween
		if tw != null and is_instance_valid(tw) and tw.is_valid():
			tw.kill()
	_active_tweens.clear()


func _track_fx(node: Node) -> void:
	if node != null:
		_fx_nodes.append(node)


func _untrack_fx(node: Node) -> void:
	_fx_nodes.erase(node)


func _free_fx(node: Node) -> void:
	_untrack_fx(node)
	if node != null and is_instance_valid(node):
		node.queue_free()


func _stale() -> bool:
	if cabin == null:
		return true
	if _ceremony_gen >= 0 and cabin.has_method("_owns_bank_ceremony"):
		return not bool(cabin.call("_owns_bank_ceremony", _ceremony_gen))
	return false


func _cue(id: String, fallback: String = "") -> void:
	## Package E: prefer named board.* / sting.* ids. Fallback only if the primary
	## cue is absent from the map (Reel still delivering final files).
	if sfx == null:
		return
	if _has_cue(id):
		KIT.cue(sfx, StringName(id))
		return
	if fallback != "" and _has_cue(fallback):
		KIT.cue(sfx, StringName(fallback))


func _has_cue(id: String) -> bool:
	if sfx != null and sfx.has_method("has_cue"):
		return bool(sfx.call("has_cue", id))
	## Package E registered the board.* ids in sfx-map; treat as present.
	return id.begins_with("board.") or id.begins_with("sting.") or id.begins_with("amb.") \
		or id.begins_with("nib.") or id.begins_with("cabin.") or id.begins_with("ui.") \
		or id.begins_with("speech.")


func _finish() -> void:
	_running = false
	_kill_active()
	if is_instance_valid(_skip_btn):
		_skip_btn.queue_free()
	_skip_btn = null
	for raw in _fx_nodes:
		var n: Node = raw as Node
		if n != null and is_instance_valid(n):
			n.queue_free()
	_fx_nodes.clear()
	if _satchel != null and is_instance_valid(_satchel):
		_satchel.queue_free()
	_satchel = null
	if cabin != null and _ceremony_gen >= 0 and cabin.has_method("_release_bank_ceremony"):
		if cabin.has_method("_owns_bank_ceremony") and bool(cabin.call("_owns_bank_ceremony", _ceremony_gen)):
			cabin.call("_release_bank_ceremony", _ceremony_gen)
	## Persist board_viewed / bank_pending after sequence.
	if cabin != null and cabin.has_method("_save"):
		cabin.call("_save")
	finished.emit()
	queue_free()
