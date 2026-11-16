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
const SLOT_SCR := preload("res://scripts/cabin/trophy_board_slot.gd")
const BucketRules = preload("res://scripts/bucket_rules.gd")

const FLY_SEC_BRONZE := 0.35
const FLY_SEC_SILVER := 0.45
const FLY_SEC_GOLD := 0.55
const SWELL_BRONZE := 1.08
const SWELL_SILVER := 1.15
const SWELL_GOLD := 1.30
const LAND_FX_FPS := 12.0

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
var land_events: Array = []
var cues_played: Array = []
var any_lit_before_land: bool = false
## Single haul model for this return (dialogue, routing, lights, lever-ready).
var haul: Dictionary = {}
var lever_ready_face: int = -1
var lever_ready_keys: Array = []
var empty_or_loss_key: String = ""

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
## Snapshot of face readiness before this haul's claims (banked minus haul ids).
var _ready_before: Dictionary = {}


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
	land_events.clear()
	cues_played.clear()
	any_lit_before_land = false
	_skip_requested = false
	skipped_mid = false
	first_return_branch = ""
	first_light_did_pause = false
	lever_ready_face = -1
	lever_ready_keys.clear()
	empty_or_loss_key = ""
	_ready_before.clear()
	if board == null or cabin == null:
		_finish()
		return
	if reduce_motion and "reduce_motion" in board:
		board.reduce_motion = true
	_host = cabin
	_ceremony_gen = -1
	if cabin.has_method("_begin_bank_ceremony"):
		_ceremony_gen = int(cabin.call("_begin_bank_ceremony"))
	## ONE haul model for this return — dialogue, routing, lights, and lever-ready
	## all read this (or the post-claim live state derived from it).
	haul = build_haul(cabin)
	if cabin != null and cabin.has_method("apply_homecoming_haul"):
		cabin.call("apply_homecoming_haul", haul)
	elif cabin != null:
		_apply_haul_to_cabin(haul)
	is_first_return = _detect_first_return()
	_step_s = FIRST_RETURN_STEP if is_first_return else HOMECOMING_STEP
	var pending: Array = _ordered_pending()
	_snapshot_ready_before(pending)
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
		await _play_one_item(id, i + 1)
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
		## Pointer lives on this line only — show before say so close/advance clears it
		## before the keys / unveil sequence starts.
		_start_first_pulse(str(placed_order[0]))
		await _say_keys(["nib.board.first_hover_hint"], {})
		if cabin != null and cabin.has_method("clear_nib_pointer"):
			cabin.clear_nib_pointer()
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
	## Nathan lock 2026-11-14: first return is win OR limp-home, and it runs in the
	## trophy room BEFORE the key-ring unlocks the other rooms.
	return kind == "win" or kind == "loss"


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
	## Hover-to-learn: pointer from talk bar to the pulsed slot.
	if cabin != null and cabin.has_method("show_nib_pointer_at") and board != null and board.has_method("slot_node"):
		var slot = board.slot_node(card_id)
		if slot is Control:
			cabin.show_nib_pointer_at(slot as Control)
	if cabin.has_method("_save"):
		cabin.call("_save")


## Build the single haul model for a return. Pure + cabin reads; does not mutate.
## new_uniques = board members awaiting presentation (not tokens; duplicates excluded).
static func build_haul(p_cabin) -> Dictionary:
	var kind := "win"
	if p_cabin != null and "_homecoming_kind" in p_cabin:
		kind = str(p_cabin.get("_homecoming_kind"))
	if kind == "":
		kind = "win"
	var rules: Dictionary = {}
	if p_cabin != null and p_cabin.has_method("_biome_rules"):
		rules = p_cabin.call("_biome_rules")
	else:
		rules = CAMPAIGN_SHELL.read_json(CAMPAIGN_SHELL.DATA_PATH)
	var items: Dictionary = {}
	if p_cabin != null and "items_by_id" in p_cabin:
		items = p_cabin.items_by_id
	var faces: Array = MODEL.faces(rules, items)
	var candidates: Array = _haul_candidate_ids(p_cabin)
	var new_uniques: Array = []
	var duplicates: Array = []
	var tokens_excluded: Array = []
	var non_board: Array = []
	var seen_ids := {}
	var by_board := {}
	for raw in candidates:
		var id := str(raw)
		if id == "" or seen_ids.has(id):
			continue
		seen_ids[id] = true
		var card: Dictionary = items.get(id, {})
		if id == "spider_egg" or BucketRules.is_token(card):
			tokens_excluded.append(id)
			continue
		var meta: Dictionary = _meta_for_static(id, faces, items)
		if int(meta.get("face_index", -1)) < 0:
			non_board.append(id)
			continue
		## Already presentation-claimed and not in this return's hold/pending → duplicate
		## of a prior find (or already drained). Keep out of the satchel list.
		if _haul_already_presented(p_cabin, id):
			duplicates.append(id)
			continue
		var entry := {
			"id": id,
			"board": str(meta.get("pool_id", "")),
			"pool_id": str(meta.get("pool_id", "")),
			"face_index": int(meta.get("face_index", 0)),
			"tier": int(meta.get("tier", 1)),
			"slot": int(meta.get("slot", 0)),
			"name": str(meta.get("name", "")),
		}
		new_uniques.append(entry)
		var board_id := str(entry["pool_id"])
		if not by_board.has(board_id):
			by_board[board_id] = []
		(by_board[board_id] as Array).append(id)
	new_uniques.sort_custom(func(a, b) -> bool:
		var fa: int = int(a.get("face_index", 99))
		var fb: int = int(b.get("face_index", 99))
		if fa != fb:
			return fa < fb
		var ta: int = int(a.get("tier", 1))
		var tb: int = int(b.get("tier", 1))
		if ta != tb:
			return ta < tb
		return int(a.get("slot", 0)) < int(b.get("slot", 0))
	)
	var ordered: Array = []
	for row in new_uniques:
		ordered.append(str(row.get("id", "")))
	return {
		"kind": kind,
		"new_uniques": new_uniques,
		"ordered_ids": ordered,
		"count": ordered.size(),
		"by_board": by_board,
		"duplicates": duplicates,
		"tokens_excluded": tokens_excluded,
		"non_board": non_board,
		"faces": faces,
		"rules": rules,
	}


static func _haul_candidate_ids(p_cabin) -> Array:
	var out: Array = []
	var seen := {}
	if p_cabin == null:
		return out
	## Prefer presentation queue + hold. Before the first ceremony this return
	## (`_bank_played` false), also absorb `_new_ids` so a pending/hold desync
	## cannot make Nib say "nothing new" while news still lists board uniques.
	var sources: Array = []
	if "bank_pending" in p_cabin and p_cabin.bank_pending is Array:
		sources.append_array(p_cabin.bank_pending)
	if "_bank_hold" in p_cabin and typeof(p_cabin._bank_hold) == TYPE_DICTIONARY:
		for hid in (p_cabin._bank_hold as Dictionary).keys():
			sources.append(str(hid))
	var bank_played := false
	if "_bank_played" in p_cabin:
		bank_played = bool(p_cabin.get("_bank_played"))
	if not bank_played and "_new_ids" in p_cabin and p_cabin._new_ids is Array:
		sources.append_array(p_cabin._new_ids)
	for raw in sources:
		var id := str(raw)
		if id == "" or seen.has(id):
			continue
		seen[id] = true
		out.append(id)
	return out


static func _haul_already_presented(p_cabin, id: String) -> bool:
	if p_cabin == null or id == "":
		return false
	## Still queued for this ceremony → not presented yet.
	if "bank_pending" in p_cabin and p_cabin.bank_pending is Array:
		if (p_cabin.bank_pending as Array).has(id):
			return false
	if "_bank_hold" in p_cabin and typeof(p_cabin._bank_hold) == TYPE_DICTIONARY:
		if (p_cabin._bank_hold as Dictionary).has(id):
			return false
	var bank_played := false
	if "_bank_played" in p_cabin:
		bank_played = bool(p_cabin.get("_bank_played"))
	## Repair path: news from this return, ceremony not yet played.
	if not bank_played and "_new_ids" in p_cabin and p_cabin._new_ids is Array:
		if (p_cabin._new_ids as Array).has(id):
			return false
	return true


static func _meta_for_static(id: String, faces: Array, items: Dictionary = {}) -> Dictionary:
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
	## Fallback tier from catalog when faces missing (tests).
	var tier_fb := 1
	if items.has(id) and typeof(items[id]) == TYPE_DICTIONARY:
		tier_fb = clampi(BucketRules.tier_of(items[id]), 1, 3)
	return {"face_index": -1, "tier": tier_fb, "slot": 0, "pool_id": "", "name": ""}


func _apply_haul_to_cabin(h: Dictionary) -> void:
	if cabin == null:
		return
	var ordered: Array = h.get("ordered_ids", [])
	if "bank_pending" in cabin:
		cabin.bank_pending = ordered.duplicate()
	if "_bank_hold" in cabin:
		var hold := {}
		for id in ordered:
			hold[str(id)] = true
		cabin._bank_hold = hold
	if board != null and board.has_method("set_hold"):
		board.set_hold(ordered)


func _ordered_pending() -> Array:
	## Prefer the haul model computed at ceremony start.
	if not haul.is_empty() and haul.has("ordered_ids"):
		return (haul.get("ordered_ids", []) as Array).duplicate()
	haul = build_haul(cabin)
	_apply_haul_to_cabin(haul)
	return (haul.get("ordered_ids", []) as Array).duplicate()


func _snapshot_ready_before(pending: Array) -> void:
	## Lever-ready must detect boards that THIS haul pushed over quota.
	## Bank credit already includes pending ids, so strip them for the before-shot.
	_ready_before.clear()
	var rules: Dictionary = _rules()
	var before: Dictionary = _state_without_ids(pending)
	var faces: Array = MODEL.faces(rules, _items())
	for face in faces:
		if typeof(face) != TYPE_DICTIONARY:
			continue
		var f: Dictionary = face
		var fi: int = int(f.get("index", 0))
		_ready_before[fi] = MODEL.lever_state(rules, before, f) == &"ready"


func _state_without_ids(ids: Array) -> Dictionary:
	var st: Dictionary = _live_state().duplicate(true)
	var banked: Variant = st.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
	else:
		banked = (banked as Dictionary).duplicate()
	for raw in ids:
		(banked as Dictionary).erase(str(raw))
	st["banked"] = banked
	return st


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


func _metal_for(card_id: String, meta: Dictionary) -> String:
	var rank: int = int(meta.get("tier", 0))
	if rank >= 1 and rank <= 3:
		return SLOT_SCR.metal_for_rank(rank)
	var card: Dictionary = _items().get(card_id, {})
	if typeof(card) == TYPE_DICTIONARY and not card.is_empty():
		return SLOT_SCR.metal_for_rank(BucketRules.tier_of(card))
	return "bronze"


func _fly_sec(metal: String) -> float:
	match metal:
		"gold":
			return FLY_SEC_GOLD
		"silver":
			return FLY_SEC_SILVER
		_:
			return FLY_SEC_BRONZE


func _swell_peak(metal: String) -> float:
	match metal:
		"gold":
			return SWELL_GOLD
		"silver":
			return SWELL_SILVER
		_:
			return SWELL_BRONZE


func _slot_lit_before(card_id: String) -> bool:
	if board == null or not board.has_method("slot_node"):
		return false
	var slot = board.slot_node(card_id)
	if slot == null:
		return false
	return str(slot.slot_state) == "claimed"


func _record_land(card_id: String, metal: String) -> void:
	var lit := _slot_lit_before(card_id)
	if lit:
		any_lit_before_land = true
	land_events.append({"id": card_id, "lit_before": lit, "metal": metal})


func _play_one_item(card_id: String, deposit_n: int = 1) -> void:
	var meta: Dictionary = _meta_for(card_id)
	var face_i: int = int(meta.get("face_index", 0))
	var metal: String = _metal_for(card_id, meta)
	if board.has_method("current_face") and int(board.current_face()) != face_i:
		await _slide_board(face_i, false)
		if _stale() or _skip_requested:
			return
	var lights_before: int = _lights_lit_now(face_i)
	if reduce_motion:
		await _place_reduce_motion(card_id, face_i, lights_before, metal)
		return
	_play_satchel_anim("open")
	_cue("board.satchel_rustle")
	await _wait_step(0.10)
	if _stale() or _skip_requested:
		return
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
	var bob_tw := _tween()
	bob_tw.tween_property(spr, "position:y", rise_peak.y - 2.0, _dur(0.075))
	bob_tw.tween_property(spr, "position:y", rise_peak.y + 2.0, _dur(0.075))
	await _await_tween(bob_tw)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	var to_global: Vector2 = board.slot_global_center(card_id)
	var to_local: Vector2 = _to_host_local(to_global)
	var mid: Vector2 = (rise_peak + to_local) * 0.5 + Vector2(0, -FLY_LIFT)
	var slot_scale: Vector2 = _slot_scale_for(card_id)
	var fly_t: float = _fly_sec(metal)
	var peak: float = _swell_peak(metal)
	var swoosh := _make_swoosh_trail(metal, spr)
	_cue("board.whoosh.%s" % metal)
	var fly_tw := _tween()
	fly_tw.set_parallel(true)
	fly_tw.tween_method(func(t: float) -> void:
		if is_instance_valid(spr):
			var p: Vector2 = _quad_bez(rise_peak, mid, to_local, t)
			spr.position = p
			if swoosh != null and is_instance_valid(swoosh):
				swoosh.position = p
				swoosh.rotation = (to_local - rise_peak).angle()
	, 0.0, 1.0, _dur(fly_t)).set_ease(Tween.EASE_IN_OUT)
	var swell: Vector2 = slot_scale * peak
	fly_tw.tween_method(func(t: float) -> void:
		if is_instance_valid(spr):
			var s: float = lerpf(1.0, peak, sin(t * PI))
			spr.scale = slot_scale * s
	, 0.0, 1.0, _dur(fly_t)).set_ease(Tween.EASE_IN_OUT)
	await _await_tween(fly_tw)
	if swoosh != null:
		_free_fx(swoosh)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	if metal == "gold":
		var hang_tw := _tween()
		hang_tw.tween_property(spr, "scale", swell, _dur(0.12)).set_ease(Tween.EASE_OUT)
		await _await_tween(hang_tw)
		var snap_tw := _tween()
		snap_tw.tween_property(spr, "scale", slot_scale, _dur(0.10)).set_trans(Tween.TRANS_BACK)
		await _await_tween(snap_tw)
		var nudge: float = clampf(randf_range(-2.0, 2.0), -2.0, 2.0)
		if absf(nudge) > 0.01:
			var ntw := _tween()
			ntw.tween_property(spr, "position:x", spr.position.x + nudge, _dur(0.08))
			ntw.tween_property(spr, "position:x", spr.position.x, _dur(0.08))
			await _await_tween(ntw)
	else:
		var settle := _tween()
		settle.tween_property(spr, "scale", slot_scale, _dur(0.08))
		await _await_tween(settle)
	_record_land(card_id, metal)
	await _land_fx_at(to_local, metal)
	_cue("board.land.%s" % metal)
	_free_fx(spr)
	_claim_item(card_id)
	placed_order.append(card_id)
	item_placed.emit(card_id)
	var lights_after: int = _lights_lit_now(face_i)
	var quota: int = CAMPAIGN_SHELL.quota_of(_rules())
	if lights_after > lights_before and lights_after <= quota:
		await _flash_light(face_i, lights_after - 1, lights_after)
	var gap_scale: float = 0.55 if deposit_n > 6 and metal != "gold" else 1.0
	var tail: float = 0.25 * gap_scale
	if metal == "gold":
		tail = 0.35
	await _wait_step(tail)


func _make_swoosh_trail(metal: String, parent: Sprite2D) -> Sprite2D:
	var stem := "trophy_board/swoosh_%s" % metal
	var tex: Texture2D = KIT.ui_tex(stem)
	if tex == null:
		return null
	var swoosh := Sprite2D.new()
	swoosh.texture = tex
	swoosh.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	swoosh.centered = true
	swoosh.z_index = parent.z_index - 1
	parent.add_child(swoosh)
	_track_fx(swoosh)
	return swoosh


func _land_fx_at(at_local: Vector2, metal: String) -> void:
	var stems: Array = []
	for fi in 6:
		stems.append("trophy_board/land_%s_f%d" % [metal, fi])
	var land: AnimatedSprite2D = _ui_anim(stems, "land", LAND_FX_FPS, false)
	if land == null:
		await _poof_at(at_local)
		return
	land.centered = true
	land.position = at_local
	land.z_index = 25
	_host.add_child(land)
	_track_fx(land)
	land.play("land")
	if is_instance_valid(land) and land.is_playing():
		await land.animation_finished
	elif land.sprite_frames and land.sprite_frames.get_frame_count("land") > 0:
		## Already finished under high time_scale before the await connected.
		await _wait_step(0.01)
	else:
		await _wait_step(6.0 / LAND_FX_FPS)
	_free_fx(land)


func _place_reduce_motion(card_id: String, face_i: int, lights_before: int, metal: String) -> void:
	var to_global: Vector2 = board.slot_global_center(card_id)
	var to_local: Vector2 = _to_host_local(to_global)
	var spr: Sprite2D = _make_item_sprite(card_id)
	spr.position = to_local
	spr.modulate.a = 0.0
	spr.scale = _slot_scale_for(card_id)
	_host.add_child(spr)
	_track_fx(spr)
	_cue("board.whoosh.%s" % metal)
	var tw := _tween()
	tw.tween_property(spr, "modulate:a", 1.0, _dur(0.25))
	await _await_tween(tw)
	if _stale() or _skip_requested:
		_free_fx(spr)
		return
	_record_land(card_id, metal)
	await _land_fx_crossfade(to_local, metal, spr)
	_cue("board.land.%s" % metal)
	_free_fx(spr)
	_claim_item(card_id)
	placed_order.append(card_id)
	item_placed.emit(card_id)
	var lights_after: int = _lights_lit_now(face_i)
	var quota_rm: int = CAMPAIGN_SHELL.quota_of(_rules())
	if lights_after > lights_before and lights_after <= quota_rm:
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


func _land_fx_crossfade(at_local: Vector2, metal: String, spr: Sprite2D) -> void:
	var stems: Array = []
	for fi in 6:
		stems.append("trophy_board/land_%s_f%d" % [metal, fi])
	var land: AnimatedSprite2D = _ui_anim(stems, "land", LAND_FX_FPS, false)
	if land == null:
		await _poof_at(at_local)
		return
	land.centered = true
	land.position = at_local
	land.z_index = 25
	land.modulate.a = 0.0
	_host.add_child(land)
	_track_fx(land)
	var tw := _tween()
	tw.set_parallel(true)
	tw.tween_property(spr, "modulate:a", 0.0, _dur(0.20))
	tw.tween_property(land, "modulate:a", 1.0, _dur(0.20))
	land.play("land")
	await _await_tween(tw)
	## High Engine.time_scale can finish the sprite before this await — never hang
	## on a signal that already fired. Wait only while still playing.
	if is_instance_valid(land) and land.is_playing():
		await land.animation_finished
	elif is_instance_valid(land) and land.sprite_frames and land.sprite_frames.get_frame_count("land") > 0:
		await _wait_step(0.01)
	else:
		await _wait_step(6.0 / LAND_FX_FPS)
	_free_fx(land)


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
	## Gesture at the first lit arch light, then at the lever.
	var light_anchor: Control = _light_anchor(face_i, 0)
	if cabin != null and cabin.has_method("show_nib_pointer_at") and light_anchor != null:
		cabin.show_nib_pointer_at(light_anchor)
	await _say_keys(["nib.board.first_light.1"], {})
	if cabin != null and cabin.has_method("clear_nib_pointer"):
		cabin.clear_nib_pointer()
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


func _light_anchor(face_i: int, light_index: int) -> Control:
	if board == null:
		return null
	var faces = board.get("_face_nodes")
	if typeof(faces) != TYPE_ARRAY or face_i < 0 or face_i >= faces.size():
		return null
	var face_n = faces[face_i]
	if face_n == null:
		return null
	var lights = face_n.get("_lights")
	if typeof(lights) != TYPE_ARRAY or light_index < 0 or light_index >= lights.size():
		return null
	return lights[light_index] as Control


func _show_lever_ring(on: bool) -> void:
	if not on:
		if _lever_ring != null and is_instance_valid(_lever_ring):
			_free_fx(_lever_ring)
		_lever_ring = null
		if cabin != null and cabin.has_method("clear_nib_pointer"):
			cabin.clear_nib_pointer()
		return
	var anchor: Control = null
	if board != null and board.has_method("lever_node"):
		anchor = board.lever_node()
	## Tutorial pointer + pulse ring from Nib's talk bar to the lever.
	if cabin != null and cabin.has_method("show_nib_pointer_at") and anchor != null:
		cabin.show_nib_pointer_at(anchor)
	_lever_ring = Control.new()
	_lever_ring.name = "LeverAuraRing"
	_lever_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lever_ring.z_index = 50
	## Ring tracks the 192×224 floor lever (slightly larger than the art hit).
	var sz := Vector2(220, 260)
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
	var quota: int = CAMPAIGN_SHELL.quota_of(_rules())
	if light_n != 1 and light_n != quota:
		return
	if cabin == null or not ("_dialog" in cabin):
		return
	var dialog = cabin._dialog
	if dialog == null:
		return
	## Existing copy keys are board.light.say.1 / .5 (quota 5). Use closest key.
	var key_n: int = light_n if light_n == 1 else 5
	var key := "board.light.say.%d" % key_n
	var fallback := "There's a light!" if light_n == 1 else "Five! That's all five!"
	if dialog.has_method("say_bubble"):
		dialog.say_bubble(key, Vector2(216, 150), {})
	elif dialog.has_method("say"):
		dialog.say([key], [], {}, {key: fallback})


func _after_items() -> void:
	## Push live in-memory campaign state into the board (never a stale disk copy).
	_push_live_state_to_board()
	if board != null and board.has_method("refresh"):
		board.refresh()
	## (a) Any face b1..b5 whose lever JUST became READY from this haul → prompt.
	## Prefer newly-ready faces (this haul crossed cabinet_quota). Fall back to any
	## ready face only when none are newly ready. Nothing auto-pulls.
	## (b) Complete boards → Package D BoardSequences via cabin (shortcut / ending).
	var rules: Dictionary = _rules()
	var state: Dictionary = _live_state()
	var faces: Array = MODEL.faces(rules, _items())
	var newly_ready: Array = []
	for face in faces:
		if typeof(face) != TYPE_DICTIONARY:
			continue
		var f: Dictionary = face
		var fi: int = int(f.get("index", 0))
		if MODEL.lever_state(rules, state, f) != &"ready":
			continue
		var was_ready: bool = bool(_ready_before.get(fi, false))
		## Only faces this haul pushed across cabinet_quota (b1..b5). Do not
		## re-prompt an older face that was already READY before this return.
		if not was_ready:
			newly_ready.append(fi)
	var ready_face := -1
	if not newly_ready.is_empty():
		ready_face = int(newly_ready[0])
	lever_ready_face = ready_face
	if ready_face >= 0:
		await _slide_board(ready_face, false)
		_push_live_state_to_board()
		if board != null and board.has_method("refresh"):
			board.refresh()
		if board != null and board.has_method("set_lever_ready_fx"):
			board.set_lever_ready_fx(true)
		_cue("board.lever_ready")
		if cabin != null and cabin.has_method("nib_react"):
			cabin.nib_react()
		var biome_name := ""
		if ready_face >= 0 and ready_face < faces.size() and typeof(faces[ready_face]) == TYPE_DICTIONARY:
			biome_name = str((faces[ready_face] as Dictionary).get("name", ""))
		lever_ready_keys = ["nib.board.lever_ready.1", "nib.board.lever_ready.2"]
		await _say_keys(lever_ready_keys, {"biome": biome_name})
		## Nothing auto-pulls — portal runs only on lever_pulled (Package D owns that).
	## Hand off 100% / shortcut / Abyss-complete to Package D. Do not reimplement.
	if cabin != null and cabin.has_method("_maybe_run_board_complete_sequences"):
		await cabin.call("_maybe_run_board_complete_sequences")


func _say_empty_or_loss() -> void:
	var kind := str(haul.get("kind", ""))
	if kind == "":
		kind = _cabin_str("_homecoming_kind", "win")
	if kind == "loss":
		var loss_keys := ["nib.home.loss.1", "nib.home.loss.2", "nib.home.loss.3"]
		empty_or_loss_key = str(loss_keys[randi() % loss_keys.size()])
		await _say_keys([empty_or_loss_key], {})
	else:
		## Win with 0 board uniques this return — not the "new" / unpack path.
		var empty_keys := ["nib.board.empty.1", "nib.board.empty.2"]
		empty_or_loss_key = str(empty_keys[randi() % empty_keys.size()])
		await _say_keys([empty_or_loss_key], {})


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
	if not haul.is_empty() and haul.has("ordered_ids"):
		## Mid-ceremony: held = haul ids not yet placed.
		for raw in haul.get("ordered_ids", []):
			var id := str(raw)
			if id != "" and not placed_order.has(id):
				held.append(id)
	elif cabin != null and "bank_pending" in cabin:
		held = cabin.bank_pending
	return MODEL.lights_lit(_rules(), _live_state(), faces[face_i], held)


func _rules() -> Dictionary:
	if not haul.is_empty() and typeof(haul.get("rules", null)) == TYPE_DICTIONARY and not (haul.get("rules") as Dictionary).is_empty():
		return haul.get("rules")
	if cabin != null and cabin.has_method("_biome_rules"):
		return cabin.call("_biome_rules")
	return CAMPAIGN_SHELL.read_json(CAMPAIGN_SHELL.DATA_PATH)


func _items() -> Dictionary:
	if cabin != null and "items_by_id" in cabin:
		return cabin.items_by_id
	return {}


## Live in-memory campaign state. Never a fresh disk re-read while a shell is bound.
func _live_state() -> Dictionary:
	if cabin != null and "_campaign_shell" in cabin and cabin._campaign_shell != null:
		var shell = cabin._campaign_shell
		if typeof(shell) == TYPE_DICTIONARY and shell.has("state"):
			return shell.state
		if "state" in shell:
			return shell.state
	if cabin != null and cabin.has_method("_campaign_shell_live_state"):
		return cabin.call("_campaign_shell_live_state")
	## Last resort: disk (cabin unbound). Prefer shell when present.
	if cabin != null and cabin.has_method("_campaign_shell_state"):
		return cabin.call("_campaign_shell_state")
	return CAMPAIGN_SHELL.fresh_state()


func _state() -> Dictionary:
	return _live_state()


func _push_live_state_to_board() -> void:
	if board == null:
		return
	var st: Dictionary = _live_state()
	if board.has_method("set_campaign_state"):
		board.call("set_campaign_state", st)
	elif "_campaign_state" in board:
		board._campaign_state = st


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
	cues_played.append(id)
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
