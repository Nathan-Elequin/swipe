extends SceneTree
## Return-flow v2 (Nathan 2026-11-14): first cabin → limp-home → trophy → unlock → map.
## Uses a temp user:// so live saves stay untouched. Mixes source contracts + runtime
## cabin/board probes + real InputEventKey/Button against the parchment tag.
##
## Run: godot --headless --path . --script res://scripts/dev/return_flow_v2_selftest.gd


const OK_MARK := "RETURN_FLOW_V2_OK"
const FAIL_MARK := "RETURN_FLOW_V2_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const SLOT := preload("res://scripts/cabin/trophy_board_slot.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const OUT_DIR := "res://design/audit-shots/cursor/return-flow-v2"
const OUT_BOARD := OUT_DIR + "/board-after.png"
const OUT_DUMP := OUT_DIR + "/slot-texture-dump.txt"
const ARTIFACT_BOARD := "/opt/cursor/artifacts/return-flow-v2-board-after.png"
const ARTIFACT_DUMP := "/opt/cursor/artifacts/return-flow-v2-slot-dump.txt"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	Engine.time_scale = 8.0

	var tmp_user := _make_temp_user()
	failed = _check(rows, failed, "temp.user_dir", tmp_user != "" and DirAccess.dir_exists_absolute(tmp_user), "user=%s" % tmp_user) or failed

	## --- Source contracts ---
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	var board_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board.gd")
	var slot_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board_slot.gd")
	var seq_src := FileAccess.get_file_as_string("res://scripts/cabin/board_sequences.gd")
	var model_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board_model.gd")
	var hall_src := FileAccess.get_file_as_string("res://scripts/cabin/room_hall.gd")
	var branch_src := FileAccess.get_file_as_string("res://scripts/dev/branch_tag.gd")
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")

	failed = _check(rows, failed, "src.rooms_main_hall",
		cabin_src.find('rooms_unlocked: Array = ["main", "hall"]') >= 0, "") or failed
	failed = _check(rows, failed, "src.interior_arrive_hall",
		cabin_src.find("func _interior_arrive_room") >= 0
		and _func_contains(cabin_src, "_interior_arrive_room", "hall"), "") or failed
	failed = _check(rows, failed, "src.trophy_before_key",
		cabin_src.find("_stage_homecoming_bank") >= 0
		and cabin_src.find("await play_key_ring()") >= 0
		and cabin_src.find("_stage_homecoming_bank") < cabin_src.find("await play_key_ring()"), "") or failed
	failed = _check(rows, failed, "src.loss_key_due",
		_func_contains(cabin_src, "_credit_homecoming_counters", 'k == "loss"')
		or _func_contains(cabin_src, "_credit_homecoming_counters", '_homecoming_kind == "loss"'), "") or failed
	failed = _check(rows, failed, "src.map_pointer_helpers",
		cabin_src.find("_point_map_after_first_speech") >= 0
		and cabin_src.find("_point_map_continue_mission") >= 0, "") or failed
	failed = _check(rows, failed, "src.clear_stuck_fades",
		cabin_src.find("func _clear_stuck_cabin_fades") >= 0, "") or failed
	failed = _check(rows, failed, "src.play_station_delve_guard",
		_func_contains(cabin_src, "_play_station", "not visible or not _menu_on"), "") or failed
	failed = _check(rows, failed, "src.claim_after_poof",
		home_src.find("await _poof_at") >= 0
		and home_src.find("_claim_item(card_id)") > home_src.find("await _poof_at"), "") or failed
	failed = _check(rows, failed, "src.first_return_win_or_loss",
		_func_contains(home_src, "_detect_first_return", 'kind == "win" or kind == "loss"'), "") or failed
	failed = _check(rows, failed, "src.held_stays_unclaimed",
		model_src.find("Still in the satchel ceremony queue") >= 0
		or model_src.find("bank_pending / held ids stay visually unclaimed") >= 0, "") or failed
	failed = _check(rows, failed, "src.plinth_not_recess",
		slot_src.find("plinth_claimed") >= 0
		and slot_src.find("slot_recess_lit") < 0
		and slot_src.find("PLINTH_RECT") >= 0, "") or failed
	failed = _check(rows, failed, "src.viewport_clip",
		board_src.find("clip_contents = true") >= 0
		and board_src.find("FaceViewport") >= 0, "") or failed
	failed = _check(rows, failed, "src.parchment_nearest",
		board_src.find("parchment_tag") >= 0
		and board_src.find("patch_margin_left = 24") >= 0
		and board_src.find('Color("4a2f1f")') >= 0, "") or failed
	failed = _check(rows, failed, "src.placard_nearest",
		board_src.find("TEXTURE_FILTER_NEAREST") >= 0
		and board_src.find("TEXTURE_FILTER_LINEAR") < 0, "") or failed
	failed = _check(rows, failed, "src.board_dais",
		hall_src.find("board_dais.png") >= 0
		and hall_src.find("Rect2(152, 812") >= 0, "") or failed
	failed = _check(rows, failed, "src.pause_safe_timers",
		seq_src.find("ignore_pause") >= 0
		or seq_src.find("create_timer(t, true, false, true)") >= 0, "") or failed
	failed = _check(rows, failed, "src.music_cabin_restore",
		_func_contains(seq_src, "_restore_cabin_music", "music_cabin"), "") or failed
	failed = _check(rows, failed, "src.branch_tag_playtest_hide",
		branch_src.find("playtest_flag") >= 0
		and branch_src.find("DevChrome") >= 0, "") or failed
	failed = _check(rows, failed, "src.main_f11_devchrome",
		main_src.find("KEY_F11") >= 0 and main_src.find("DevChrome") >= 0, "") or failed
	var f11_block_ok: bool = main_src.find("Works in playtest F5") >= 0 \
		and main_src.find("ctrl_pressed") >= 0 \
		and main_src.find("shift_pressed") >= 0 \
		and main_src.find("KEY_D") >= 0 \
		and main_src.find("KEY_F11") >= 0 \
		and main_src.find("DevChrome.toggle") >= 0
	## Old authoring-gated F11 line must be gone.
	var f11_not_authoring_gated: bool = main_src.find(
		"if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11"
	) < 0
	failed = _check(rows, failed, "src.main_ctrl_shift_d_devchrome",
		f11_block_ok and f11_not_authoring_gated,
		"playtest Ctrl+Shift+D / F11 must toggle DevChrome") or failed
	failed = _check(rows, failed, "src.release_cabin_tree_pause",
		cabin_src.find("func _release_cabin_tree_pause") >= 0
		and cabin_src.find("get_tree().paused = false") >= 0, "") or failed
	failed = _check(rows, failed, "src.continue_mission_no_relocate",
		_func_contains(cabin_src, "_point_map_continue_mission", "nib.return.continue_mission")
		and not _func_contains(cabin_src, "_point_map_continue_mission", "_relocate_nib_to_hall"),
		"entryway Nib + pointer must stay; relocate is deferred to map open") or failed
	failed = _check(rows, failed, "src.clear_trophy_popups",
		cabin_src.find("func _clear_trophy_popups") >= 0
		and cabin_src.find("hide_item_tag") >= 0, "") or failed
	failed = _check(rows, failed, "src.plinth_z_not_negative",
		slot_src.find("z_index = -1") < 0
		and slot_src.find("z_index = 0") >= 0, "") or failed
	failed = _check(rows, failed, "src.parchment_fixed_width",
		board_src.find("ITEM_TAG_WIDTH") >= 0
		and board_src.find("_measure_label_height") >= 0, "") or failed

	## --- Runtime: fresh cabin defaults ---
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set("_save_path_override", tmp_user.path_join("home_cabin.json"))
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.call("_apply_defaults")

	failed = _check(rows, failed, "fresh.rooms_main_hall",
		_rooms_has(cabin, ["main", "hall"]) and not _rooms_has(cabin, ["study"]),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))) or failed
	failed = _check(rows, failed, "fresh.interior_arrive_hall",
		str(cabin.call("_interior_arrive_room")) == "hall",
		"room=%s" % str(cabin.call("_interior_arrive_room"))) or failed

	## First-speech map pointer helpers exist and find the Map hotspot safely when rooms empty.
	failed = _check(rows, failed, "fresh.map_hotspot_null_ok",
		cabin.has_method("_map_hotspot") and cabin.call("_map_hotspot") == null, "") or failed

	## --- Limp-home first return: key due, hall first, tree not stuck paused ---
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "loss")
	cabin.set("first_return_homecoming_done", false)
	cabin.set("key_ring_seen", false)
	cabin.set("bank_pending", ["boot", "net"])
	var want_loss: bool = bool(cabin.call("_credit_homecoming_counters"))
	failed = _check(rows, failed, "loss.key_due",
		want_loss == true and int(cabin.get("counters").get("losses", 0)) == 1,
		"want=%s counters=%s" % [want_loss, str(cabin.get("counters"))]) or failed
	failed = _check(rows, failed, "loss.arrive_hall",
		str(cabin.call("_interior_arrive_room")) == "hall", "") or failed
	failed = _check(rows, failed, "loss.is_first_run_return",
		bool(cabin.call("is_first_run_return")) == true, "") or failed

	## Simulate a stuck wipe + tree pause, then clear — limp-home must not leave cabin dead.
	paused = true
	cabin.call("_ensure_fade")
	var wipe: ColorRect = cabin.get_node_or_null("BoardFadeWipe")
	if wipe != null:
		wipe.visible = true
		wipe.modulate.a = 1.0
		wipe.mouse_filter = Control.MOUSE_FILTER_STOP
	cabin.call("_clear_stuck_cabin_fades")
	## _clear_stuck_cabin_fades / _release_cabin_tree_pause must unpause — do not set false by hand.
	failed = _check(rows, failed, "pause.tree_unpaused",
		paused == false, "paused=%s" % paused) or failed
	if wipe != null:
		failed = _check(rows, failed, "pause.wipe_cleared",
			wipe.visible == false and wipe.modulate.a < 0.05
			and wipe.mouse_filter == Control.MOUSE_FILTER_IGNORE,
			"a=%s vis=%s mf=%s" % [wipe.modulate.a, wipe.visible, wipe.mouse_filter]) or failed
	## Explicit release helper (player-has-control assert).
	paused = true
	cabin.call("_release_cabin_tree_pause")
	failed = _check(rows, failed, "pause.release_helper",
		paused == false, "paused=%s after _release_cabin_tree_pause" % paused) or failed

	## Homecoming detects first return on loss.
	var hc = HOMECOMING.new()
	hc.cabin = cabin
	failed = _check(rows, failed, "hc.first_return_on_loss",
		bool(hc.call("_detect_first_return")) == true, "") or failed
	cabin.set("first_return_homecoming_done", true)
	failed = _check(rows, failed, "hc.first_return_once",
		bool(hc.call("_detect_first_return")) == false, "") or failed
	hc.free()

	## Slot state: pending/held stays unclaimed even if already banked on disk.
	failed = _check(rows, failed, "model.held_unclaimed",
		MODEL.slot_state({}, {"banked": {"boot": "b1"}}, "boot", ["boot"]) == &"unclaimed", "") or failed
	failed = _check(rows, failed, "model.banked_claimed",
		MODEL.slot_state({}, {"banked": {"boot": "b1"}}, "boot", []) == &"claimed", "") or failed

	## --- Live board: plinths, pulse ring, parchment, clip, texture dump + render ---
	var board: TrophyBoard = BOARD.new()
	board.name = "TrophyBoardProbe"
	root.add_child(board)
	board.size = MODEL.BOARD_OUTER.size
	board.position = MODEL.BOARD_OUTER.position
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
	## Bank ids that actually sit on face b1 (mill names, not legacy boot/longbow).
	var banked := {"shield": "b1", "net": "b1", "bracers": "b1"}
	board.setup(rules, items_by_id, {"banked": banked, "map_pieces": ["b1"]}, {}, ["crossbow"])
	## Let deferred builds settle.
	await process_frame
	await process_frame

	var vp: Control = board.get_node_or_null("FaceViewport")
	failed = _check(rows, failed, "board.viewport_clips",
		vp != null and vp.clip_contents == true,
		"vp=%s clip=%s" % [vp != null, vp.clip_contents if vp else false]) or failed

	var dump := _dump_slot_textures(board)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_write_text(OUT_DUMP, dump)
	_write_text_abs(ARTIFACT_DUMP, dump)
	failed = _check(rows, failed, "board.dump_has_plinth",
		dump.find("plinth_claimed") >= 0 or dump.find("plinth_empty") >= 0,
		"dump_len=%d" % dump.length()) or failed
	failed = _check(rows, failed, "board.dump_no_recess",
		dump.find("slot_recess") < 0, "") or failed
	failed = _check(rows, failed, "board.dump_pulse_or_aura",
		dump.find("pulse_ring") >= 0 or dump.find("aura_claimed") >= 0, "") or failed

	## Claimed slot must show plinth_claimed + pulse; held crossbow stays on plinth_empty.
	var claimed_ok := false
	var empty_ok := false
	var recess_bad := false
	var aura_checked := false
	var plinth_z_ok := true
	var plinth_mod_ok := true
	for slot in _iter_slots(board):
		var plinth = slot.get_node_or_null("Plinth")
		var path := ""
		if plinth != null:
			if int(plinth.z_index) < 0:
				plinth_z_ok = false
			if plinth.modulate != Color.WHITE and plinth.modulate.a < 0.9:
				plinth_mod_ok = false
		if plinth is TextureRect and (plinth as TextureRect).texture != null:
			path = str((plinth as TextureRect).texture.resource_path)
		if path.find("slot_recess") >= 0:
			recess_bad = true
		if slot.slot_state == &"claimed" and path.find("plinth_claimed") >= 0:
			claimed_ok = true
			if not aura_checked:
				aura_checked = true
				var aura = slot.get_node_or_null("Aura")
				failed = _check(rows, failed, "board.claimed_aura_visible",
					aura != null and aura.visible, "id=%s" % slot.card_id) or failed
		if slot.slot_state == &"unclaimed" and path.find("plinth_empty") >= 0:
			if not empty_ok and plinth != null:
				## WIRING rect under the cell (once).
				failed = _check(rows, failed, "board.empty_plinth_rect",
					plinth.position == Vector2(0, 116) and plinth.size == Vector2(128, 32),
					"pos=%s size=%s" % [plinth.position, plinth.size]) or failed
			empty_ok = true
	failed = _check(rows, failed, "board.claimed_plinth", claimed_ok, "") or failed
	failed = _check(rows, failed, "board.held_empty_plinth", empty_ok, "unclaimed sits on plinth_empty") or failed
	failed = _check(rows, failed, "board.no_recess_tex", not recess_bad, "") or failed
	failed = _check(rows, failed, "board.plinth_z_nonneg", plinth_z_ok, "z=-1 hid slabs behind face bg") or failed
	failed = _check(rows, failed, "board.plinth_modulate_white", plinth_mod_ok, "") or failed

	## Parchment: fixed width, height fits text, beside item, Nearest ninepatch.
	if board.get("_item_tag") == null and board.has_method("_build_item_tag"):
		board.call("_build_item_tag")
	## Use a long ability card so wrap height is exercised (Fangs-like).
	var parch_id := "fangs" if items_by_id.has("fangs") else "boot"
	board.show_item_tag(parch_id, Vector2(500, 400))
	await process_frame
	var tag: Control = board.get("_item_tag")
	var title: Label = board.get("_item_tag_title")
	failed = _check(rows, failed, "parchment.open",
		tag != null and tag.visible and bool(board.get("_item_tag_open")), "") or failed
	if title != null:
		var fs: int = int(title.get_theme_font_size("font_size"))
		failed = _check(rows, failed, "parchment.readable_size", fs >= 18, "fs=%d" % fs) or failed
		failed = _check(rows, failed, "parchment.dark_brown",
			title.get_theme_color("font_color") == Color("4a2f1f"), "") or failed
	if tag != null:
		## Fixed sensible width — never a tall 1-col strip.
		failed = _check(rows, failed, "parchment.width_band",
			tag.size.x >= 280.0 and tag.size.x <= 340.0,
			"w=%.1f" % tag.size.x) or failed
		failed = _check(rows, failed, "parchment.height_fits",
			tag.size.y >= 64.0 and tag.size.y <= 420.0,
			"h=%.1f (was giant strip)" % tag.size.y) or failed
		## Beside, not centered on the anchor (offset ≥ 40px in x).
		var dx: float = absf(tag.global_position.x - 500.0)
		failed = _check(rows, failed, "parchment.beside_item", dx >= 40.0, "dx=%.1f" % dx) or failed
		var nine = tag.get_node_or_null("Frame")
		failed = _check(rows, failed, "parchment.ninepatch",
			nine is NinePatchRect
			and (nine as NinePatchRect).patch_margin_left == 24
			and (nine as NinePatchRect).texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,
			"frame=%s" % str(nine)) or failed
		failed = _check(rows, failed, "parchment.process_always",
			tag.process_mode == Node.PROCESS_MODE_ALWAYS, "") or failed
	## Real Esc input closes the tag.
	var esc := InputEventKey.new()
	esc.pressed = true
	esc.keycode = KEY_ESCAPE
	board._unhandled_input(esc)
	failed = _check(rows, failed, "parchment.esc_closes",
		bool(board.get("_item_tag_open")) == false, "") or failed
	## Real mouse click-away (global_position) closes while "paused".
	board.show_item_tag(parch_id, Vector2(500, 400))
	await process_frame
	paused = true
	var click := InputEventMouseButton.new()
	click.pressed = true
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = Vector2(50, 50)
	click.global_position = Vector2(50, 50)
	board._input(click)
	failed = _check(rows, failed, "parchment.click_away_while_paused",
		bool(board.get("_item_tag_open")) == false, "vis stayed true was the QA bug") or failed
	paused = false
	## Mouse-exit hide path.
	board.show_item_tag(parch_id, Vector2(500, 400))
	await process_frame
	board.call("_on_item_tag_mouse_exited")
	await process_frame
	failed = _check(rows, failed, "parchment.mouse_exit_hides",
		bool(board.get("_item_tag_open")) == false, "") or failed

	## Placard Nearest.
	var plaque: TextureRect = board.get_node_or_null("Plaque")
	failed = _check(rows, failed, "placard.nearest",
		plaque != null and plaque.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "") or failed

	## --- With-loot extract path: swipe_ids (real credit) → Homecoming.run unpack ---
	var loot_id := "shield" if items_by_id.has("shield") else parch_id
	cabin.call("_apply_defaults")
	cabin.set("_persist_writes", false)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "win")
	cabin.set("first_return_homecoming_done", false)
	cabin.set("key_ring_seen", false)
	cabin.set("bank_pending", [])
	cabin.set("reduce_motion", true) ## keep timeline short under time_scale
	## Block swipe_ids' deferred _offer_bank_sequence — we drive Homecoming ourselves
	## (same credit helper main.gd calls before _go_home on extract).
	cabin.set("_arriving", true)
	var news: Array = cabin.swipe_ids([loot_id])
	failed = _check(rows, failed, "extract.swipe_ids_queues",
		news.has(loot_id) and (cabin.bank_pending as Array).has(loot_id),
		"news=%s pending=%s" % [str(news), str(cabin.bank_pending)]) or failed
	cabin.set("_arriving", false)
	## Mount board under cabin for Homecoming FX host.
	if board.get_parent() != cabin:
		if board.get_parent() != null:
			board.get_parent().remove_child(board)
		cabin.add_child(board)
	cabin.set("_trophy_board", board)
	board.setup(rules, items_by_id, {"banked": {loot_id: "b1"}, "map_pieces": ["b1"]}, {}, cabin.bank_pending.duplicate())
	board.set_hold(cabin.bank_pending.duplicate())
	await process_frame
	await process_frame
	var hc_loot = await HOMECOMING.run(board, cabin, null)
	failed = _check(rows, failed, "extract.unpack_branch",
		hc_loot != null and str(hc_loot.first_return_branch) == "unpack",
		"branch=%s" % (str(hc_loot.first_return_branch) if hc_loot else "?")) or failed
	failed = _check(rows, failed, "extract.placed_after_poof",
		hc_loot != null and (hc_loot.placed_order as Array).has(loot_id),
		"placed=%s" % (str(hc_loot.placed_order) if hc_loot else "?")) or failed
	failed = _check(rows, failed, "extract.pending_drained",
		(cabin.bank_pending as Array).is_empty(),
		"pending=%s" % str(cabin.bank_pending)) or failed
	## Claimed plinth lit after unpack (not early silhouette-only).
	var loot_slot = board.slot_node(loot_id) if board.has_method("slot_node") else null
	if loot_slot == null:
		for s2 in _iter_slots(board):
			if str(s2.card_id) == loot_id:
				loot_slot = s2
				break
	var loot_plinth_path := ""
	if loot_slot != null:
		var lp = loot_slot.get_node_or_null("Plinth")
		if lp is TextureRect and (lp as TextureRect).texture != null:
			loot_plinth_path = str((lp as TextureRect).texture.resource_path)
	failed = _check(rows, failed, "extract.claimed_plinth_lit",
		loot_slot != null and loot_slot.slot_state == &"claimed"
		and loot_plinth_path.find("plinth_claimed") >= 0,
		"state=%s path=%s" % [loot_slot.slot_state if loot_slot else "?", loot_plinth_path]) or failed
	if hc_loot != null and is_instance_valid(hc_loot):
		hc_loot.queue_free()

	## Empty-handed first return still skips unpack (no fake haul).
	cabin.call("_apply_defaults")
	cabin.set("_persist_writes", false)
	cabin.items_by_id = items_by_id
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "loss")
	cabin.set("first_return_homecoming_done", false)
	cabin.set("bank_pending", [])
	cabin.set("reduce_motion", true)
	board.setup(rules, items_by_id, {"banked": {}, "map_pieces": ["b1"]}, {}, [])
	board.set_hold([])
	await process_frame
	var hc_empty = await HOMECOMING.run(board, cabin, null)
	failed = _check(rows, failed, "empty.skip_unpack",
		hc_empty != null and str(hc_empty.first_return_branch) == "empty",
		"branch=%s" % (str(hc_empty.first_return_branch) if hc_empty else "?")) or failed
	failed = _check(rows, failed, "empty.no_places",
		hc_empty != null and (hc_empty.placed_order as Array).is_empty(),
		"placed=%s" % (str(hc_empty.placed_order) if hc_empty else "?")) or failed
	if hc_empty != null and is_instance_valid(hc_empty):
		hc_empty.queue_free()

	## Player-has-control: release helper leaves tree unpaused (arrive end contract).
	paused = true
	cabin.call("_release_cabin_tree_pause")
	failed = _check(rows, failed, "pause.player_has_control",
		paused == false, "paused=%s" % paused) or failed

	## Headless Image composite (dummy renderer has no ViewportTexture).
	var shot_ok := _composite_board_after(OUT_BOARD, ARTIFACT_BOARD)
	failed = _check(rows, failed, "render.board_after", shot_ok, OUT_BOARD) or failed

	board.queue_free()
	cabin.queue_free()
	_finish(failed, rows)


func _iter_slots(board: TrophyBoard) -> Array:
	var out: Array = []
	var faces = board.get("_face_nodes")
	if typeof(faces) != TYPE_ARRAY:
		return out
	for face in faces:
		if face == null:
			continue
		var slots = face.get("_slots")
		if typeof(slots) == TYPE_DICTIONARY:
			for id in slots.keys():
				var s = slots[id]
				if s is TrophyBoardSlot:
					out.append(s)
			continue
		## Fallback: walk pyramid children.
		for n in _walk(face):
			if n is TrophyBoardSlot:
				out.append(n)
	return out


func _walk(n: Node) -> Array:
	var out: Array = [n]
	for c in n.get_children():
		out.append_array(_walk(c))
	return out


func _dump_slot_textures(board: TrophyBoard) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("## TrophyBoard slot child texture paths")
	var faces = board.get("_face_nodes")
	if typeof(faces) != TYPE_ARRAY:
		return "no faces"
	for fi in faces.size():
		var face = faces[fi]
		if face == null:
			continue
		lines.append("face[%d]=%s" % [fi, face.name])
		var face_slots: Array = []
		var slots = face.get("_slots") if face.get("_slots") != null else {}
		if typeof(slots) == TYPE_DICTIONARY:
			for id in slots.keys():
				face_slots.append(slots[id])
		else:
			for n in _walk(face):
				if n is TrophyBoardSlot:
					face_slots.append(n)
		for slot in face_slots:
			if not (slot is TrophyBoardSlot):
				continue
			lines.append("  slot id=%s state=%s" % [slot.card_id, slot.slot_state])
			for n in slot.get_children():
				var path := _tex_path(n)
				if path != "":
					lines.append("    %s → %s" % [n.name, path])
				else:
					lines.append("    %s (no tex)" % n.name)
	return "\n".join(lines)


func _tex_path(n: Node) -> String:
	if n is TextureRect:
		var tr := n as TextureRect
		if tr.texture != null:
			return str(tr.texture.resource_path)
	if n is Sprite2D:
		var sp := n as Sprite2D
		if sp.texture != null:
			return str(sp.texture.resource_path)
	return ""


func _composite_board_after(res_path: String, abs_path: String) -> bool:
	## Pixel blit of wired art (same approach as trophy_art_wire_composite.gd).
	var img := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a100c"))
	_blit_scaled(img, "res://assets/dungeon/home/rooms/room_trophy.png", 0, 0, 1680, 1040)
	_blit(img, "res://assets/ui/trophy/board_dais.png", 152, 812)
	var outer: Rect2 = MODEL.BOARD_OUTER
	_blit_scaled(img, "res://assets/ui/trophy_board/board_frame.png", int(outer.position.x), int(outer.position.y), int(outer.size.x), int(outer.size.y))
	var face: Rect2 = MODEL.FACE_VIEWPORT
	_blit_scaled(img, "res://assets/ui/trophy_board/face_bg_verdant.png", int(face.position.x), int(face.position.y), int(face.size.x), int(face.size.y))
	_blit(img, "res://assets/ui/trophy_board/placard_b1.png", int(floor(840.0 - 400.0 * 0.5)), int(outer.position.y))
	var ids := ["shield", "crossbow", "net", "bracers", "sai"]
	var claimed := [true, false, true, true, false]
	var slot := 128
	var gap := 24
	var n := ids.size()
	var row_w := n * slot + (n - 1) * gap
	var x0 := int(840.0 - row_w * 0.5)
	var y0 := int(MODEL.PYRAMID_AREA.position.y + slot + MODEL.VGAP_NORMAL)
	for i in n:
		var cx := x0 + i * (slot + gap)
		var plinth := "res://assets/ui/trophy/plinth_claimed.png" if claimed[i] else "res://assets/ui/trophy/plinth_empty.png"
		_blit(img, plinth, cx, y0 + 116)
		if claimed[i]:
			_blit(img, "res://assets/ui/trophy/pulse_ring.png", cx + 64 - 80, y0 + 64 - 80)
		_blit_item(img, ids[i], cx, y0, claimed[i])
	_blit_scaled(img, "res://assets/ui/trophy/parchment_tag.png", 1100, y0 + 20, 200, 96)
	var abs_res := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs_res.get_base_dir())
	var ok := img.save_png(abs_res) == OK
	if abs_path != "":
		DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
		img.save_png(abs_path)
	return ok


func _blit(dst: Image, path: String, x: int, y: int) -> void:
	if not FileAccess.file_exists(path):
		return
	var src := Image.new()
	if src.load(path) != OK:
		return
	dst.blit_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), Vector2i(x, y))


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> void:
	if not FileAccess.file_exists(path):
		return
	var src := Image.new()
	if src.load(path) != OK:
		return
	src.resize(w, h, Image.INTERPOLATE_NEAREST)
	dst.blit_rect(src, Rect2i(0, 0, w, h), Vector2i(x, y))


func _blit_item(dst: Image, item_id: String, x: int, y: int, full_color: bool) -> void:
	var paths := [
		"res://assets/dungeon/items/%s.png" % item_id,
		"res://assets/icons/%s.png" % item_id,
	]
	for p in paths:
		if not FileAccess.file_exists(p):
			continue
		var src := Image.new()
		if src.load(p) != OK:
			continue
		src.resize(128, 128, Image.INTERPOLATE_NEAREST)
		if not full_color:
			for py in src.get_height():
				for px in src.get_width():
					var c := src.get_pixel(px, py)
					if c.a > 0.05:
						var v := (c.r + c.g + c.b) / 3.0 * 0.25
						src.set_pixel(px, py, Color(v, v, v, c.a))
		## Seat on slab: bottom pad from used_rect.
		var used: Rect2i = src.get_used_rect()
		var pad := maxi(0, src.get_height() - used.end.y)
		dst.blit_rect(src, Rect2i(0, 0, 128, 128), Vector2i(x, y + pad))
		return


func _make_temp_user() -> String:
	var base := OS.get_temp_dir().path_join("swipe-return-flow-v2-%d" % Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(base)
	## Point ProjectSettings user:// via environment when possible; tests use override path.
	return base


func _rooms_has(cabin: Node, want: Array) -> bool:
	var rooms = cabin.get("rooms_unlocked")
	if typeof(rooms) != TYPE_ARRAY:
		return false
	for r in want:
		if not rooms.has(r):
			return false
	return true


func _func_contains(src: String, func_name: String, needle: String) -> bool:
	var start := src.find("func %s" % func_name)
	if start < 0:
		start = src.find("func %s(" % func_name)
	if start < 0:
		return false
	var nxt := src.find("\nfunc ", start + 1)
	var body := src.substr(start, nxt - start if nxt >= 0 else src.length() - start)
	return body.find(needle) >= 0


func _write_text(res_path: String, text: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs.get_base_dir())
	var f := FileAccess.open(abs, FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()


func _write_text_abs(abs_path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()


func _check(rows: Array, failed: bool, id: String, ok: bool, detail: String) -> bool:
	rows.append({"id": id, "ok": ok, "detail": detail})
	print("%s %s%s" % ["PASS" if ok else "FAIL", id, (" — " + detail) if detail != "" else ""])
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	var pass_n := 0
	var fail_n := 0
	for r in rows:
		if r.get("ok", false):
			pass_n += 1
		else:
			fail_n += 1
	print("---")
	print("return_flow_v2: %d pass / %d fail" % [pass_n, fail_n])
	print(OK_MARK if not failed else FAIL_MARK)
	quit(0 if not failed else 1)
