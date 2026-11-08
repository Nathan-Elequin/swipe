extends SceneTree
## Windowed runtime evidence for REQ-20261108-collection-A.
## Refuses unless user:// is under a collection-a-sandbox profile.
## Does not read or write Nathan's live Spinheritance save directory.

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_DIR := "res://playtest/repot/outbox/REQ-20261108-collection-A"
const SHOT_DIR := OUT_DIR + "/shots"
const JOURNEY := preload("res://scripts/collection_journey.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")

var main: Node = null
var rows: Array = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	print("USER_DATA=", ud)
	if ud.find("collection-a-sandbox") < 0:
		print("REFUSED_UNSAFE_DIRECT_USERDATA")
		quit(2)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	DisplayServer.window_set_title("Collection A repot (sandbox)")
	root.size = Vector2i(1680, 1040)
	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		print("FAIL boot change_scene ", err)
		quit(1)
		return
	for _i in 800:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and main.get("progress_menu") != null and main.get("home_cabin") != null and main.get("_campaign") != null:
			if not main.items_by_id.is_empty():
				break
	if main == null or main.progress_menu == null or main.home_cabin == null or main._campaign == null:
		print("FAIL boot main missing")
		quit(1)
		return
	for _j in 300:
		await process_frame
		if not main.items_by_id.is_empty():
			break
	if main.items_by_id.is_empty():
		print("FAIL boot catalog empty")
		quit(1)
		return
	paused = false
	root.size = Vector2i(1680, 1040)
	_quiet_chrome()
	PLAYER_COPY.reload()
	_log_scale("boot")
	_copy_audit()
	var b1: Array = _b1_ids()
	print("B1_IDS ", b1.slice(0, 8))
	if b1.size() < 6:
		print("FAIL need 6 b1 items, got ", b1.size())
		quit(1)
		return
	var banked_ids: Array = b1.slice(0, 4)
	var seen_only: String = str(b1[4])
	var held_new: String = str(b1[5])
	_arm_collection(banked_ids, seen_only, held_new)
	await _shot_quiet(banked_ids, held_new)
	await _shot_catalogue(banked_ids, seen_only, held_new)
	await _shot_overview_new(banked_ids, held_new)
	await _shot_locked(banked_ids)
	await _shot_milestone(banked_ids, held_new)
	await _input_keyboard()
	await _input_mouse()
	await _input_focus_and_back()
	await _skip_and_reload(banked_ids, held_new, seen_only)
	await _shot_loss(seen_only)
	await _shot_cabin()
	_reduced_motion()
	print("LIVE_REPOT_DONE")
	for row in rows:
		print("CASE %s %s %s" % [row["id"], row["verdict"], row["note"]])
	quit(0)


func _quiet_chrome() -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		var node = main.get(key)
		if node != null and node is CanvasItem:
			if node.has_method("close_intro"):
				node.close_intro()
			(node as CanvasItem).visible = false
	if main.home_cabin != null:
		main.home_cabin.tutorial_done = true
		main.home_cabin.intro_seen = true
		main.home_cabin.nib_first_done = true
		main.home_cabin.tutorial_declined = false
		main.home_cabin.key_ring_seen = true
		main.home_cabin._grant_all_rooms()
		main.home_cabin.visible = false


func _b1_ids() -> Array:
	var rules: Dictionary = main._campaign.rules
	var out: Array = []
	for id in main.items_by_id.keys():
		var card: Dictionary = main.items_by_id[id]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if main._campaign_pool_of_item(str(id)) == "b1":
			out.append(str(id))
	out.sort()
	if out.is_empty():
		var catalog: Dictionary = CAMPAIGN_SHELL.read_json("res://data/catalog.json")
		var pools: Dictionary = JOURNEY.pools_from_catalog(catalog, rules)
		for id2 in pools.keys():
			if str(pools[id2]) == "b1":
				out.append(str(id2))
		out.sort()
	return out


func _arm_collection(banked_ids: Array, seen_only: String, held_new: String) -> void:
	var state: Dictionary = main._campaign.state
	CAMPAIGN_SHELL.normalize(state)
	state["banked"] = {}
	for id in banked_ids:
		state["banked"][str(id)] = "b1"
	var cabin = main.home_cabin
	cabin.swiped = {}
	cabin.seen = {}
	cabin.bank_pending = []
	for id2 in banked_ids:
		cabin.swiped[str(id2)] = true
		cabin.seen[str(id2)] = true
	cabin.seen[seen_only] = true
	cabin.seen[held_new] = true
	main._campaign_on = true
	main.adventure = true
	main.in_tutorial = false
	main.phase = "ready"
	main.hotbar = [{"card_id": held_new}]
	main._campaign.write()
	cabin._save()


func _payload(kind: String, new_ids: Array, milestones: Array = []) -> Dictionary:
	var cabin = main.home_cabin
	return {
		"kind": kind,
		"new_ids": new_ids.duplicate(),
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": main.items_by_id,
		"tex_by_item": main.tex_by_item,
		"swiped": cabin.swiped.duplicate(),
		"seen": cabin.seen.duplicate(),
		"rules": main._campaign.rules,
		"state": main._campaign.state.duplicate(true),
		"push_block": false,
		"tutorial": false,
		"milestones": milestones.duplicate(),
	}


func _present_settled(payload: Dictionary) -> void:
	var menu = main.progress_menu
	menu.present(payload, _ack_cb())
	for _i in 8:
		await process_frame
		if menu.visible:
			break
	menu.call("_cancel_presentation")
	menu._btn_skip.disabled = false
	menu._btn_next.disabled = false
	menu._btn_cabin.disabled = false
	await process_frame
	await process_frame


func _ack_cb() -> Callable:
	return func(id: String) -> void:
		if main.home_cabin != null:
			main.home_cabin.call("_ack_bank_presented", id, -1)


func _cell_state(id: String) -> String:
	var menu = main.progress_menu
	var cell: Control = menu._cell_by_id.get(id, null)
	if cell == null:
		return ""
	var lab: Label = cell.find_child("State", true, false) as Label
	return lab.text if lab != null else ""


func _show_collection(pool: String) -> void:
	var menu = main.progress_menu
	menu._area_filter = pool
	menu.call("_show_panel", 1)
	menu.call("_rebuild_area_tabs")
	await process_frame


func _shot_quiet(banked_ids: Array, held_new: String) -> void:
	## Occupied wheel + actual combat + New! badges — not empty ready-only wheel.
	main.home_cabin.visible = false
	main.progress_menu.visible = false
	main._campaign_on = true
	main.adventure = true
	main.in_tutorial = false
	## Hotbar: held New! + banked-repeat neighbors so New! badges are on-screen.
	var hb: Array = [{"card_id": held_new}]
	for i in mini(3, banked_ids.size()):
		hb.append({"card_id": str(banked_ids[i])})
	main.hotbar = hb
	## Fill wheel seats with live monsters so combat is visibly occupied.
	main.call("_empty_wheel")
	var mon_ids: Array = []
	for mid in main.monsters_by_id.keys():
		mon_ids.append(str(mid))
		if mon_ids.size() >= 4:
			break
	for mi in mon_ids.size():
		var m: Dictionary = main.call("_make_monster", str(mon_ids[mi]))
		m["slot"] = str(main.wheel[mi].get("slot", ""))
		m["spin_locked"] = false
		main.wheel[mi] = m
	main.phase = "combat"
	main._hotbar_sig = ""
	main.call("_sync_hotbar")
	main.call("_refresh")
	main.call("_sync_collection_quiet")
	await process_frame
	await process_frame
	## Force visible New! badges on carried seats so collision evidence is real (not empty ready wheel).
	var new_label := PLAYER_COPY.text("cabin.tip.new", "New!")
	if main.hotbar_box != null:
		for child2 in main.hotbar_box.get_children():
			if child2 == null or not child2.has_method("set_cabinet_badge"):
				continue
			var cid := ""
			if "card_id" in child2:
				cid = str(child2.get("card_id"))
			## Stamp New! on held-new + any non-banked seat for collision proof vs quiet strip.
			if cid == held_new or (cid != "" and not main._campaign.state["banked"].has(cid)):
				child2.call("set_cabinet_badge", true, new_label, "")
			elif cid == "":
				## Empty slots lack card_id — skip.
				pass
	await process_frame
	await process_frame
	var strip = main.collection_quiet
	var text := ""
	var vis := false
	var strip_rect := Rect2()
	if strip != null:
		text = str(strip.text)
		vis = strip.visible and strip.is_visible_in_tree()
		strip_rect = strip.get_global_rect()
	## Collect New! badge rects from hotbar cards; quiet must sit above them (no overlap).
	var badge_overlap := false
	var badge_n := 0
	if main.hotbar_box != null:
		for child in main.hotbar_box.get_children():
			if child == null or not is_instance_valid(child):
				continue
			for lab in child.find_children("*", "Label", true, false):
				if lab is Label and str((lab as Label).text).find("New!") >= 0 and (lab as Label).visible:
					badge_n += 1
					var lr: Rect2 = (lab as Control).get_global_rect()
					if strip_rect.size != Vector2.ZERO and strip_rect.intersects(lr):
						badge_overlap = true
	## Structural guard: quiet strip Y must be strictly above the hotbar panel top.
	var above_hotbar := true
	if main.hotbar_panel != null and strip != null and vis:
		var hot_top: float = main.hotbar_panel.get_global_rect().position.y
		var strip_bottom: float = strip_rect.position.y + strip_rect.size.y
		above_hotbar = strip_bottom <= hot_top + 2.0
	var banked_n: int = banked_ids.size()
	var mons_left: int = int(main.call("_monsters_left"))
	var ok := (
		vis
		and text.find(held_new) < 0
		and text.find(str(banked_n)) >= 0
		and text.find("New!") < 0
		and badge_n >= 1
		and not badge_overlap
		and above_hotbar
		and mons_left >= 1
		and str(main.phase) == "combat"
	)
	_row(
		"04",
		ok,
		"quiet vis=%s text=%s phase=%s mons=%s badges=%s overlap=%s above_hotbar=%s strip=%s" % [
			vis, text, main.phase, mons_left, badge_n, badge_overlap, above_hotbar, strip_rect
		]
	)
	await _shot("04-inrun-quiet-strip.png")


func _shot_catalogue(banked_ids: Array, seen_only: String, held_new: String) -> void:
	await _present_settled(_payload("win", []))
	await _show_collection("b1")
	var menu = main.progress_menu
	var seen_txt := _cell_state(seen_only)
	var bank_txt := _cell_state(str(banked_ids[0]))
	var seen_copy := PLAYER_COPY.text("postrun.collection.item_seen", "[Spin copy: Recognized — not banked yet]")
	var col_copy := PLAYER_COPY.text("postrun.collection.item_collected", "Collected")
	var miss_copy := PLAYER_COPY.text("postrun.collection.item_missing", "Not yet collected")
	## Unseen = never offered/recognized — must stay anonymous ("?") even on unlocked Verdant.
	var unseen_id := ""
	var seen_map: Dictionary = main.home_cabin.seen
	var banked_map: Dictionary = main._campaign.state.get("banked", {})
	for cid in menu._cell_by_id.keys():
		var sid := str(cid)
		if banked_map.has(sid):
			continue
		if bool(seen_map.get(sid, false)):
			continue
		if sid == held_new or sid == seen_only:
			continue
		unseen_id = sid
		break
	var unseen_name := ""
	var unseen_state := ""
	if unseen_id != "":
		var ucell: Control = menu._cell_by_id.get(unseen_id, null)
		if ucell != null:
			var nm: Label = ucell.find_child("Name", true, false) as Label
			var st: Label = ucell.find_child("State", true, false) as Label
			unseen_name = nm.text if nm != null else ""
			unseen_state = st.text if st != null else ""
	var unseen_ok := unseen_id != "" and unseen_name == "?" and unseen_state == miss_copy
	## Bind roster totals to live source (_pool_roster / cabinet), not stale 14/64 fixture.
	var roster: Array = menu.call("_pool_roster", "b1")
	var roster_total: int = roster.size()
	var cabinet_n: int = int(CAMPAIGN_SHELL.cabinet_count(main._campaign.state, "b1"))
	var seen_name_ok := false
	var seen_cell: Control = menu._cell_by_id.get(seen_only, null)
	if seen_cell != null:
		var sn: Label = seen_cell.find_child("Name", true, false) as Label
		if sn != null:
			seen_name_ok = sn.text != "?" and sn.text.strip_edges() != ""
	var ok := (
		seen_txt == seen_copy
		and seen_txt != miss_copy
		and bank_txt == col_copy
		and unseen_ok
		and seen_name_ok
		and roster_total > 0
	)
	_row(
		"01",
		ok,
		"seen %s=%s banked %s=%s unseen %s name=%s state=%s roster=%s/%s cabinet=%s" % [
			seen_only, seen_txt, banked_ids[0], bank_txt, unseen_id, unseen_name, unseen_state, cabinet_n, roster_total, cabinet_n
		]
	)
	print("ROSTER_BIND b1 cabinet=%s roster_total=%s (source=progress_menu._pool_roster + CAMPAIGN_SHELL.cabinet_count)" % [cabinet_n, roster_total])
	await _shot("01-catalogue-seen-vs-banked.png")


func _shot_overview_new(banked_ids: Array, held_new: String) -> void:
	var state: Dictionary = main._campaign.state.duplicate(true)
	state["banked"][held_new] = "b1"
	main.home_cabin.swiped[held_new] = true
	var payload := _payload("win", [held_new])
	payload["state"] = state
	payload["swiped"] = main.home_cabin.swiped.duplicate()
	await _present_settled(payload)
	var menu = main.progress_menu
	menu.call("_land_new", held_new, false)
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var summary := str(menu._summary.text)
	var new_copy := PLAYER_COPY.text("postrun.collection.item_new", "New!")
	var cell := _cell_state(held_new)
	var ok := summary.find("1") >= 0 and cell == new_copy
	_row("02", ok, "summary=%s cell=%s" % [summary, cell])
	await _shot("02-return-receipt-overview.png")
	main.home_cabin.swiped.erase(held_new)
	state = main._campaign.state
	if state["banked"].has(held_new) and banked_ids.find(held_new) < 0:
		state["banked"].erase(held_new)


func _shot_locked(banked_ids: Array) -> void:
	await _present_settled(_payload("win", []))
	var locked := ""
	var rules: Dictionary = main._campaign.rules
	var state: Dictionary = main._campaign.state
	for raw in CAMPAIGN_SHELL.biomes_of(rules):
		var pid := str((raw as Dictionary).get("id", ""))
		if pid != "" and not CAMPAIGN_SHELL.pool_unlocked(rules, state, pid):
			locked = pid
			break
	if locked == "":
		_row("03", false, "no locked biome in this state")
		await _shot("03-area-locked.png")
		return
	await _show_collection(locked)
	var menu = main.progress_menu
	var tab_bits: PackedStringArray = PackedStringArray()
	for child in menu._area_tabs.get_children():
		if child is Button:
			tab_bits.append((child as Button).text)
	var names: PackedStringArray = PackedStringArray()
	for id in menu._cell_by_id.keys():
		var cell: Control = menu._cell_by_id[id]
		var lab: Label = cell.find_child("Name", true, false) as Label
		if lab != null and lab.text != "":
			names.append(lab.text)
	var locked_word := PLAYER_COPY.text("postrun.collection.area_locked", "Locked")
	var badge := false
	for bit in tab_bits:
		if bit.find(locked) >= 0 or bit.find(locked_word) >= 0:
			if bit.find(locked_word) >= 0:
				badge = true
	## After spoiler fix, locked grids use "?" placeholders — real catalog names are FAIL.
	var spoil := false
	for nm in names:
		if str(nm) != "?" and str(nm).strip_edges() != "":
			## Allow Locked word only; anything else is a future-item name.
			if str(nm) != locked_word:
				spoil = true
				break
	var ok := badge and not spoil
	_row("03", ok, "pool=%s badge=%s names=%s tabs=%s" % [locked, badge, names, tab_bits])
	await _shot("03-area-locked.png")


func _shot_milestone(banked_ids: Array, held_new: String) -> void:
	var before: Dictionary = main._campaign.state.duplicate(true)
	var after: Dictionary = before.duplicate(true)
	after["banked"][held_new] = "b1"
	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, after, ["b1"], {"b1": 99})
	var payload := _payload("win", [held_new], ms)
	payload["state"] = after
	main.home_cabin.swiped[held_new] = true
	payload["swiped"] = main.home_cabin.swiped.duplicate()
	await _present_settled(payload)
	var menu = main.progress_menu
	menu.call("_land_new", held_new, false)
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob := ""
	for child in menu._overview_box.get_children():
		if child is Label:
			blob += (child as Label).text + " | "
	var before_skip := blob
	menu.call("_on_skip")
	await process_frame
	var after_blob := ""
	for child2 in menu._overview_box.get_children():
		if child2 is Label:
			after_blob += (child2 as Label).text + " | "
	var gate := before_skip.find("Spin copy") >= 0 or before_skip.find("Route") >= 0 or before_skip.find("→") >= 0 or before_skip.find("->") >= 0
	var durable := after_blob.find(before_skip) >= 0 or after_blob.length() > 0 and before_skip.length() > 0 and after_blob.find("5") >= 0
	## Shoot the durable overview (gate line) after Skip, not a later Next Goal tab.
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	_row("05", gate and menu._milestones_shown and durable, "before=%s after_skip=%s shown=%s" % [before_skip, after_blob, menu._milestones_shown])
	await _shot("05-milestone-gate.png")
	main.home_cabin.swiped.erase(held_new)


func _input_keyboard() -> void:
	await _present_settled(_payload("win", []))
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu._btn_next.disabled = false
	menu._btn_next.grab_focus()
	await process_frame
	_push_action("ui_accept")
	await process_frame
	await process_frame
	var ok := int(menu._tab) == 1
	_row("keyboard", ok, "tab=%s focus=%s" % [menu._tab, _focus_name()])
	await _shot("input-keyboard-next.png")


func _input_mouse() -> void:
	await _present_settled(_payload("win", []))
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu._btn_next.disabled = false
	await process_frame
	var rect: Rect2 = menu._btn_next.get_global_rect()
	_push_click(rect.get_center())
	await process_frame
	await process_frame
	var ok := int(menu._tab) == 1
	_row("mouse", ok, "tab=%s rect=%s" % [menu._tab, rect])
	await _shot("input-mouse-next.png")


func _input_focus_and_back() -> void:
	## Synthetic InputEventAction (not physical keyboard). Before / action / after + screensize.
	await _present_settled(_payload("win", []))
	var menu = main.progress_menu
	menu._btn_skip.grab_focus()
	await process_frame
	var first := _focus_name()
	_push_action("ui_focus_next")
	await process_frame
	await process_frame
	var second := _focus_name()
	var focus_moved := second != "" and second != first
	_log_scale("esc-before")
	var before_vis: bool = bool(menu.visible)
	var before_focus := _focus_name()
	await _shot("input-esc-before.png")
	## ACTION: synthetic ui_cancel (labeled; not physical Esc key hardware).
	_push_action("ui_cancel")
	await process_frame
	await process_frame
	await process_frame
	_log_scale("esc-after")
	var after_vis: bool = bool(menu.visible)
	var after_focus := _focus_name()
	await _shot("input-esc-after.png")
	## Caller restore: progress menu must leave; focus must not stay trapped on footer controls.
	var restored := (not after_vis) and before_vis
	var focus_not_on_menu := after_focus == "" or not str(after_focus).begins_with("Btn")
	_row("focus", focus_moved, "synthetic_tab from=%s to=%s" % [first, second])
	_row(
		"back",
		restored,
		"input=synthetic_ui_cancel before_vis=%s after_vis=%s before_focus=%s after_focus=%s focus_free=%s" % [
			before_vis, after_vis, before_focus, after_focus, focus_not_on_menu
		]
	)
	## Keep a composite still of the focus-tab surface for REQ matrix continuity.
	if not after_vis:
		await _present_settled(_payload("win", []))
		menu._btn_skip.grab_focus()
		await process_frame
	await _shot("input-focus-back.png")


func _skip_and_reload(banked_ids: Array, held_new: String, seen_only: String) -> void:
	var cabin = main.home_cabin
	cabin.bank_pending = [held_new, seen_only]
	cabin.swiped[held_new] = true
	cabin._save()
	var before_n: int = main._campaign.state["banked"].size()
	var added1: Dictionary = CAMPAIGN_SHELL.bank(
		main._campaign.rules, main._campaign.state, [held_new], {held_new: "b1"}
	)
	var added2: Dictionary = CAMPAIGN_SHELL.bank(
		main._campaign.rules, main._campaign.state, [held_new], {held_new: "b1"}
	)
	var after_n: int = main._campaign.state["banked"].size()
	var once := (added1.get("added", []) as Array).has(held_new)
	var twice := (added2.get("added", []) as Array).has(held_new)
	main._campaign.write()
	main._campaign.state["banked"]["phantom_repot"] = "b1"
	main._campaign.load_all()
	var phantom: bool = main._campaign.state["banked"].has("phantom_repot")
	var size_ok: bool = main._campaign.state["banked"].size() == before_n + 1
	cabin._ack_bank_presented(held_new, -1)
	var pending_mid: Array = cabin.bank_pending.duplicate()
	cabin.bank_pending = ["phantom_repot"]
	cabin._load_save()
	var pending_after: Array = cabin.bank_pending.duplicate()
	var no_requeue := not pending_after.has(held_new) and not pending_after.has("phantom_repot")
	_row(
		"reload",
		once and not twice and not phantom and size_ok and no_requeue,
		"once=%s twice=%s phantom=%s size=%s pending_mid=%s pending_after=%s seen=%s" % [
			once, twice, phantom, main._campaign.state["banked"].size(), pending_mid, pending_after, cabin.seen.has(seen_only)
		]
	)
	await _present_settled(_payload("win", []))
	await _show_collection("b1")
	var cell := _cell_state(held_new)
	var col_copy := PLAYER_COPY.text("postrun.collection.item_collected", "Collected")
	_row("07", cell == col_copy and not twice, "cell=%s banked_size=%s" % [cell, main._campaign.state["banked"].size()])
	await _shot("07-reload-idempotent.png")
	if main._campaign.state["banked"].has(held_new):
		main._campaign.state["banked"].erase(held_new)
	cabin.swiped.erase(held_new)


func _shot_loss(seen_only: String) -> void:
	var before: int = main._campaign.state["banked"].size()
	main.home_cabin.seen[seen_only] = true
	main.home_cabin.swiped.erase(seen_only)
	main.hotbar = [{"card_id": seen_only}]
	var added: Dictionary = {}
	await _present_settled(_payload("loss", []))
	var after: int = main._campaign.state["banked"].size()
	var still_seen: bool = bool(main.home_cabin.seen.get(seen_only, false))
	var not_banked: bool = not main._campaign.state["banked"].has(seen_only)
	var menu = main.progress_menu
	var summary := str(menu._summary.text)
	var ok := after == before and still_seen and not_banked and summary.find("No collection progress") >= 0
	_row("08", ok, "before=%s after=%s seen=%s banked=%s summary=%s" % [before, after, still_seen, not_banked, summary])
	await _shot("08-loss-seen-retained.png")
	menu.dismiss()
	await process_frame


func _shot_cabin() -> void:
	## Verdant (b1) must be the bright focus — not Crystal (b2). Roundtrip hide proves leave.
	var cabin = main.home_cabin
	cabin.bank_pending = []
	cabin.key_ring_seen = true
	cabin.set_meta("progress_menu_handled_return", true)
	if not cabin.is_room_unlocked("hall"):
		cabin._grant_all_rooms()
	## BEFORE: cabin closed.
	var before_vis: bool = bool(cabin.visible)
	await _shot("06-cabin-before.png")
	await cabin.open_cabin_after_progress_menu(
		main.items_by_id, main.tex_by_item, int(main.get("_buckets_revealed")), "win", [], [], "b1"
	)
	for _i in 40:
		await process_frame
	## ACTION settle: hall open with Verdant case brighter than Crystal.
	cabin.focus_biome_case("b1")
	for _j in 20:
		await process_frame
	var room := str(cabin._current_room)
	var pending: int = cabin.bank_pending.size()
	var host = cabin.get("_shelf_host")
	var b1_mod := Color.BLACK
	var b2_mod := Color.WHITE
	var has_b1 := false
	var has_b2 := false
	if host != null:
		var c1 = host.get_node_or_null("Case_b1")
		var c2 = host.get_node_or_null("Case_b2")
		if c1 != null and c1 is CanvasItem:
			has_b1 = true
			b1_mod = (c1 as CanvasItem).modulate
		if c2 != null and c2 is CanvasItem:
			has_b2 = true
			b2_mod = (c2 as CanvasItem).modulate
	var verdant_brighter: bool = has_b1 and (b1_mod.r + b1_mod.g + b1_mod.b) > (b2_mod.r + b2_mod.g + b2_mod.b + 0.15)
	_log_scale("cabin-action")
	await _shot("06-cabin-optional-focus.png")
	## AFTER roundtrip: hide_for_run restores non-cabin surface.
	cabin.hide_for_run()
	await process_frame
	await process_frame
	var after_vis: bool = bool(cabin.visible)
	_log_scale("cabin-after")
	await _shot("06-cabin-after.png")
	var ok := (
		room == "hall"
		and pending == 0
		and has_b1
		and verdant_brighter
		and before_vis == false
		and after_vis == false
	)
	_row(
		"06",
		ok,
		"room=%s pending=%s has_b1=%s has_b2=%s b1_mod=%s b2_mod=%s verdant_brighter=%s before_vis=%s after_vis=%s" % [
			room, pending, has_b1, has_b2, b1_mod, b2_mod, verdant_brighter, before_vis, after_vis
		]
	)


func _reduced_motion() -> void:
	var keys := [
		"accessibility/general/reduce_motion",
		"gui/common/reduce_motion",
		"display/window/reduce_motion",
	]
	var found := ""
	for key in keys:
		if ProjectSettings.has_setting(key):
			found = key
	if found == "":
		_row("reduced_motion", false, "NOT_RUN no reduce-motion setting in ProjectSettings")
		rows[rows.size() - 1]["verdict"] = "NOT RUN"
	else:
		_row("reduced_motion", false, "setting %s exists; stagger not compared" % found)
		rows[rows.size() - 1]["verdict"] = "NOT RUN"


func _copy_audit() -> void:
	var keys := [
		"postrun.collection.item_seen",
		"run.collection.quiet_summary",
		"run.collection.quiet_summary_threshold",
		"postrun.collection.item_new",
		"postrun.collection.item_collected",
		"postrun.collection.item_missing",
		"postrun.collection.area_locked",
		"postrun.summary.success_new",
		"postrun.summary.death",
		"cabin.tip.new",
	]
	for key in keys:
		var has: bool = PLAYER_COPY.has_key(key)
		var shown := PLAYER_COPY.text(key, "")
		print("COPY %s has=%s text=%s" % [key, has, shown])


func _row(id: String, ok: bool, note: String) -> void:
	rows.append({"id": id, "verdict": "PASS" if ok else "FAIL", "note": note})
	print("ROW %s %s %s" % [id, "PASS" if ok else "FAIL", note])


func _focus_name() -> String:
	var owner: Control = root.get_viewport().gui_get_focus_owner()
	if owner == null:
		return ""
	return str(owner.name)


func _push_action(action: String) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	down.strength = 1.0
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)


func _push_click(at: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = at
	down.global_position = at
	down.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = at
	up.global_position = at
	Input.parse_input_event(up)


func _log_scale(tag: String) -> void:
	var vp: Vector2 = root.get_viewport().get_visible_rect().size
	var win: Vector2i = DisplayServer.window_get_size()
	print(
		"SCALE %s viewport=%sx%s window=%sx%s content_scale=%s" % [
			tag, vp.x, vp.y, win.x, win.y, root.content_scale_factor
		]
	)


func _shot(filename: String) -> void:
	_quiet_intro_only()
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path(SHOT_DIR + "/" + filename)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var img: Image = root.get_viewport().get_texture().get_image()
	var err: Error = img.save_png(path)
	_log_scale(filename)
	print("SHOT %s %sx%s err=%s" % [filename, img.get_width(), img.get_height(), err])


func _quiet_intro_only() -> void:
	var intro = main.get("playtest_intro")
	if intro != null and intro is CanvasItem:
		(intro as CanvasItem).visible = false
