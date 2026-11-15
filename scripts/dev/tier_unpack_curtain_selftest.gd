extends SceneTree
## Tiered unpack + velvet curtain A — headless contract selftest.
## Run: godot --headless --path . --script res://scripts/dev/tier_unpack_curtain_selftest.gd


const OK_MARK := "TIER_UNPACK_CURTAIN_OK"
const FAIL_MARK := "TIER_UNPACK_CURTAIN_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SLOT := preload("res://scripts/cabin/trophy_board_slot.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 10.0

	## --- Art present ---
	for metal in ["bronze", "silver", "gold"]:
		failed = _check(
			rows, failed, "ART.plinth_%s" % metal,
			ResourceLoader.exists("res://assets/ui/trophy/plinth_claimed_%s.png" % metal)
		) or failed
		failed = _check(
			rows, failed, "ART.aura_%s_f0" % metal,
			ResourceLoader.exists("res://assets/ui/trophy_board/aura_claimed_%s_f0.png" % metal)
		) or failed
		failed = _check(
			rows, failed, "ART.land_%s_f0" % metal,
			ResourceLoader.exists("res://assets/ui/trophy_board/land_%s_f0.png" % metal)
		) or failed
		failed = _check(
			rows, failed, "ART.swoosh_%s" % metal,
			ResourceLoader.exists("res://assets/ui/trophy_board/swoosh_%s.png" % metal)
		) or failed
	failed = _check(
		rows, failed, "ART.curtain_drape",
		ResourceLoader.exists("res://assets/ui/trophy_board/curtain_drape.png")
	) or failed
	failed = _check(
		rows, failed, "ART.curtain_sway_f0",
		ResourceLoader.exists("res://assets/ui/trophy_board/curtain_sway_f0.png")
	) or failed
	failed = _check(
		rows, failed, "ART.curtain_jiggle_f0",
		ResourceLoader.exists("res://assets/ui/trophy_board/curtain_jiggle_f0.png")
	) or failed

	## --- Metal / plinth / aura resolve ---
	var metal_names: Array[String] = ["bronze", "silver", "gold"]
	for rank in [1, 2, 3]:
		var metal: String = SLOT.metal_for_rank(rank)
		var expect: String = metal_names[rank - 1]
		failed = _check(rows, failed, "metal_rank_%d" % rank, metal == expect) or failed

	var slot: TrophyBoardSlot = SLOT.new()
	root.add_child(slot)
	slot.setup("probe", Rect2(0, 0, 128, 128), false)
	for metal2 in ["bronze", "silver", "gold"]:
		slot.set_claim_metal(metal2)
		slot.apply_state(&"claimed")
		var ptex: Texture2D = slot.resolve_plinth_tex(true)
		failed = _check(
			rows, failed, "plinth_tex_%s" % metal2,
			ptex != null and str(ptex.resource_path).find(metal2) >= 0
		) or failed
		var stem: String = slot.resolve_aura_stem()
		failed = _check(
			rows, failed, "aura_stem_%s" % metal2,
			stem.find(metal2) >= 0
		) or failed
	## Missing metal falls back to untinted claimed plinth.
	slot.set_claim_metal("platinum")
	slot.apply_state(&"claimed")
	var fallback: Texture2D = slot.resolve_plinth_tex(true)
	failed = _check(rows, failed, "plinth_fallback_untinted", fallback != null) or failed
	slot.queue_free()

	## --- Board + cabin for unpack order / land-before-claim ---
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var board_data: Dictionary = SHELL.read_json("res://data/content-board.json")
	var items_by_id := {}
	for raw in board_data.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	var faces: Array = MODEL.faces(rules, items_by_id)
	failed = _check(rows, failed, "faces_loaded", faces.size() >= 2) or failed
	if faces.size() < 2:
		_finish(failed, rows)
		return

	## Pick mixed ranks across two boards: face0 gold + bronze, face1 silver.
	var pick := _pick_mixed(faces, items_by_id)
	failed = _check(rows, failed, "picked_mixed", pick.size() >= 3) or failed
	if pick.size() < 3:
		_finish(failed, rows)
		return

	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin._homecoming_kind = "win"
	cabin.reduce_motion = false
	cabin.first_return_homecoming_done = true
	cabin.first_light_seen = true
	## Deliberately reverse order so sort must reorder: gold, silver, bronze across faces.
	cabin.bank_pending = [pick["gold"], pick["silver"], pick["bronze"]]
	cabin._bank_hold = {}
	for pid in cabin.bank_pending:
		cabin._bank_hold[str(pid)] = true
	var state := SHELL.fresh_state()
	state["banked"] = {}
	for pid2 in cabin.bank_pending:
		state["banked"][str(pid2)] = true
	## Unlock b2 so face 1 is open for unpack (map_pieces is an id list).
	state["map_pieces"] = ["b1", "b2"]
	cabin._campaign_shell = {"state": state}
	cabin._campaign_rules = rules
	cabin.size = Vector2(1680, 1040)

	var board: TrophyBoard = BOARD.new()
	cabin.add_child(board)
	cabin._trophy_board = board
	board.setup(rules, items_by_id, state, {}, cabin.bank_pending.duplicate())
	board.slide_to(0, true)
	await process_frame

	## (a) Deposit order: board order, then ascending rank (bronze→silver→gold).
	var h := Homecoming.new()
	h.board = board
	h.cabin = cabin
	h.sfx = null
	h.reduce_motion = false
	cabin.add_child(h)
	var ordered: Array = h._ordered_pending()
	failed = _check(rows, failed, "order_size", ordered.size() == 3) or failed
	## Expect face0 items before face1; within a face, bronze before gold.
	var meta_b: Dictionary = h._meta_for(str(pick["bronze"]), faces)
	var meta_g: Dictionary = h._meta_for(str(pick["gold"]), faces)
	var meta_s: Dictionary = h._meta_for(str(pick["silver"]), faces)
	var expect_order: Array = []
	## Sort the three the same way _ordered_pending does, then compare.
	var tmp: Array = [pick["bronze"], pick["gold"], pick["silver"]]
	tmp.sort_custom(func(a, b) -> bool:
		var ma: Dictionary = h._meta_for(str(a), faces)
		var mb: Dictionary = h._meta_for(str(b), faces)
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
	expect_order = tmp
	failed = _check(
		rows, failed, "order_board_then_rank",
		ordered == expect_order
	) or failed
	## Bronze before gold when same face.
	if int(meta_b.get("face_index", -1)) == int(meta_g.get("face_index", -2)):
		failed = _check(
			rows, failed, "same_face_bronze_before_gold",
			ordered.find(pick["bronze"]) < ordered.find(pick["gold"])
		) or failed

	## Run full unpack at high time_scale — (b) no slot lit before land.
	## Snapshot observability on finished: Homecoming queue_frees itself at end.
	var snap := {
		"land_events": [],
		"any_lit_before_land": true,
		"placed_order": [],
		"cues_played": [],
		"done": false,
	}
	h.finished.connect(func() -> void:
		snap["land_events"] = h.land_events.duplicate(true)
		snap["any_lit_before_land"] = h.any_lit_before_land
		snap["placed_order"] = h.placed_order.duplicate()
		snap["cues_played"] = h.cues_played.duplicate()
		snap["done"] = true
	)
	await h._run()
	await process_frame
	failed = _check(rows, failed, "homecoming_finished", bool(snap["done"])) or failed
	var land_events: Array = snap["land_events"]
	failed = _check(rows, failed, "land_events_count", land_events.size() == 3) or failed
	failed = _check(rows, failed, "no_lit_before_land", not bool(snap["any_lit_before_land"])) or failed
	for ev in land_events:
		if typeof(ev) != TYPE_DICTIONARY:
			continue
		failed = _check(
			rows, failed, "land_not_lit_%s" % str(ev.get("id", "?")),
			not bool(ev.get("lit_before", true))
		) or failed
	failed = _check(
		rows, failed, "placed_matches_order",
		snap["placed_order"] == expect_order
	) or failed
	## Whoosh + land cues per metal.
	var whoosh_ok := true
	var land_ok := true
	var cues: Array = snap["cues_played"]
	for metal3 in ["bronze", "silver", "gold"]:
		if not cues.has("board.whoosh.%s" % metal3):
			whoosh_ok = false
		if not cues.has("board.land.%s" % metal3):
			land_ok = false
	failed = _check(rows, failed, "cues_whoosh_per_metal", whoosh_ok) or failed
	failed = _check(rows, failed, "cues_land_per_metal", land_ok) or failed

	## (c) Claimed slots resolve metal plinth/aura after unpack.
	for metal4 in ["bronze", "silver", "gold"]:
		var cid: String = str(pick[metal4])
		var live = board.slot_node(cid)
		failed = _check(rows, failed, "slot_exists_%s" % metal4, live != null) or failed
		if live != null:
			failed = _check(
				rows, failed, "slot_claimed_%s" % metal4,
				str(live.slot_state) == "claimed"
			) or failed
			failed = _check(
				rows, failed, "slot_metal_%s" % metal4,
				str(live.claim_metal) == metal4
			) or failed
			var pt: Texture2D = live.resolve_plinth_tex(true)
			failed = _check(
				rows, failed, "live_plinth_%s" % metal4,
				pt != null and str(pt.resource_path).find(metal4) >= 0
			) or failed

	## (d) Curtain on a locked face: above slots, below padlock; chrome stays clear.
	## Lock face 2+ by keeping only b1/b2 unlocked.
	state["map_pieces"] = ["b1", "b2"]
	board.setup(rules, items_by_id, state, {}, [])
	## Find first locked face index.
	var locked_i := -1
	for fi in faces.size():
		if MODEL.is_face_locked(rules, state, faces[fi]):
			locked_i = fi
			break
	failed = _check(rows, failed, "has_locked_face", locked_i >= 0) or failed
	if locked_i >= 0:
		await board.slide_to(locked_i, true)
		await process_frame
		var face_n = board.face_node_at(locked_i)
		failed = _check(rows, failed, "locked_face_node", face_n != null) or failed
		if face_n != null:
			face_n.apply_states(rules, state, {}, [])
			await process_frame
			await process_frame
			var curtain: Control = face_n.curtain_node()
			failed = _check(rows, failed, "curtain_present", curtain != null and curtain.visible) or failed
			failed = _check(
				rows, failed, "curtain_stack",
				face_n.curtain_above_slots_below_padlock()
			) or failed
			failed = _check(
				rows, failed, "padlock_topmost",
				face_n.padlock_is_topmost()
			) or failed
			## Title hangs over the rod on purpose (SPEC): plaque is board chrome, not
			## under the curtain. Assert draw ownership — plaque is outside the face.
			var plaque: Control = board.get("_plaque") as Control
			var title_ok := plaque != null and not face_n.is_ancestor_of(plaque) \
				and (curtain == null or not face_n.is_ancestor_of(plaque))
			## Curtain is a face child; plaque is a board sibling of FaceViewport.
			var vp: Control = board.get("_viewport") as Control
			if plaque != null and vp != null:
				title_ok = title_ok and plaque.get_parent() == vp.get_parent() \
					and plaque.get_index() > vp.get_index()
			failed = _check(rows, failed, "curtain_under_title", title_ok) or failed
			## Arrows / dots are board chrome outside the face — no AABB overlap.
			var c_rect: Rect2 = curtain.get_global_rect() if curtain != null else Rect2()
			var chrome: Dictionary = board.chrome_rects_screen()
			failed = _check(
				rows, failed, "curtain_miss_arrow_l",
				not c_rect.intersects(chrome.get("arrow_l", Rect2()), true)
			) or failed
			failed = _check(
				rows, failed, "curtain_miss_arrow_r",
				not c_rect.intersects(chrome.get("arrow_r", Rect2()), true)
			) or failed
			var dots_ok := true
			for dr in chrome.get("dots", []):
				if dr is Rect2 and c_rect.intersects(dr, true):
					dots_ok = false
					break
			failed = _check(rows, failed, "curtain_miss_dots", dots_ok) or failed

			## (e) Locked click → jiggle path + cabin.locked once per rate-limit window.
			face_n.locked_click_count = 0
			face_n.locked_cues.clear()
			face_n.last_locked_click_at = -999.0
			var board_cues := {"n": 0}
			## Spy: board._cue via locked_clicked already fires cabin.locked.
			face_n.trigger_locked_click()
			await process_frame
			failed = _check(rows, failed, "click_count_1", face_n.locked_click_count == 1) or failed
			failed = _check(
				rows, failed, "click_cue_cabin_locked",
				(face_n.locked_cues as Array).has("cabin.locked")
			) or failed
			## Spam within cooldown — must not stack.
			face_n.trigger_locked_click()
			face_n.trigger_locked_click()
			failed = _check(rows, failed, "click_rate_limit", face_n.locked_click_count == 1) or failed
			## After cooldown, one more is allowed.
			face_n.last_locked_click_at = -999.0
			face_n._curtain_busy = false
			face_n.trigger_locked_click()
			failed = _check(rows, failed, "click_after_cooldown", face_n.locked_click_count == 2) or failed

	## Source: no player-facing Tier / Weak / Tough / Deadly invented here.
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	var face_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board_face.gd")
	failed = _check(
		rows, failed, "STATIC.no_Tier_word",
		home_src.find("Tier") < 0 and face_src.find("Tier") < 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.no_Weak_Tough_Deadly_ui",
		home_src.find("Weak") < 0 and home_src.find("Tough") < 0 and home_src.find("Deadly") < 0
	) or failed

	Engine.time_scale = 1.0
	_finish(failed, rows)


func _pick_mixed(faces: Array, items_by_id: Dictionary) -> Dictionary:
	var out := {}
	## Prefer face 0 for bronze+gold, face 1 for silver.
	for want_face in [0, 1]:
		if want_face >= faces.size():
			continue
		var rows: Dictionary = faces[want_face].get("rows", {})
		for rank in [1, 2, 3]:
			var line: Array = rows.get(rank, [])
			if line.is_empty():
				continue
			var metal: String = SLOT.metal_for_rank(rank)
			if out.has(metal):
				continue
			## Prefer taking bronze+gold from face 0 and silver from face 1.
			if metal == "silver" and want_face != 1:
				continue
			if metal != "silver" and want_face != 0:
				continue
			out[metal] = str(line[0])
	## Fill any missing from anywhere.
	for want_face2 in faces.size():
		var rows2: Dictionary = faces[want_face2].get("rows", {})
		for rank2 in [1, 2, 3]:
			var metal2: String = SLOT.metal_for_rank(rank2)
			if out.has(metal2):
				continue
			var line2: Array = rows2.get(rank2, [])
			if line2.is_empty():
				continue
			out[metal2] = str(line2[0])
	return out


func _check(rows: Array, failed: bool, id: String, ok: bool) -> bool:
	var mark := "PASS" if ok else "FAIL"
	var line := "ASSERT %s %s" % [mark, id]
	rows.append(line)
	print(line)
	if not ok:
		push_error(line)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	for r in rows:
		pass
	if failed:
		print(FAIL_MARK)
		push_error(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
