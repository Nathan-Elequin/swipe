# AUDIT appendix — raw grep hits (generated 2026-11-13 19:59 CST on playtest/latest @ f0ca1efa)

Generated with ripgrep over scripts/ scenes/ data/ tools/ tests/ .github/. Each section is one search. Docs under design/ and playtest/ are listed by file only at the end.

## Outpost / mudroom

```
data/cabin-layout.json:3:  "mudroom": [
data/cabin-layout.json:26:    "node": "OutDoor",
data/cabin-layout.json:44:    "note": "Outpost wall map — click opens held map (same path as Space). LeaveDoor on right is the physical exit."
data/cabin-layout.json:47:    "node": "RerollJar",
data/cabin-layout.json:68:    "node": "LeaveDoor",
data/cabin-layout.json:162:    "note": "painted run door — starts rightward path into Trophy Hall (does not skip to Outpost)"
data/cabin-layout.json:544:    "note": "to Outpost (mudroom). Hit matches the painted right cabinet on cabinets_wall."
data/cabin-layout.json:547:    "node": "SignOutpost",
data/cabin-layout.json:548:    "file": "doors/door_sign_outpost.png",
data/cabin-layout.json:565:    "note": "hall right door → Outpost; hover key cabin.hall.sign_outpost"
data/cabin-layout.json:1260:   "mudroom"
data/cabin-layout.json:1699:   "mudroom": {
scripts/dev/house_unlock_first_return_selftest.gd:157:			and cabin.get("rooms_unlocked").has("mudroom"),
scripts/dev/house_unlock_first_return_selftest.gd:189:			and cabin.get("rooms_unlocked").has("mudroom"),
scripts/main.gd:6150:		mud_load = CAMPAIGN_SHELL.mudroom_loadout_of(_campaign.state)
scripts/main.gd:6152:		mud_load = home_cabin.mudroom_loadout.duplicate()
scripts/main.gd:6163:		## Mudroom peg picks seat the opening hand; skip the pair offer for those.
scripts/campaign_shell.gd:55:		"mudroom_loadout": [],
scripts/campaign_shell.gd:87:	var loadout: Variant = state.get("mudroom_loadout", [])
scripts/campaign_shell.gd:94:	state["mudroom_loadout"] = load_clean
scripts/campaign_shell.gd:158:	## start_gate_uniques 0: the held map works on the first Outpost visit.
scripts/campaign_shell.gd:601:static func roll_mudroom_hooks(rules: Dictionary, rng: RandomNumberGenerator, items: Array, exclude: Array = []) -> Array:
scripts/campaign_shell.gd:623:static func set_mudroom_loadout(state: Dictionary, ids: Array) -> void:
scripts/campaign_shell.gd:630:	state["mudroom_loadout"] = clean
scripts/campaign_shell.gd:633:static func mudroom_loadout_of(state: Dictionary) -> Array:
scripts/campaign_shell.gd:635:	return state.get("mudroom_loadout", [])
scripts/campaign_shell.gd:818:	## mudroom_loadout, pencil_fresh, endless_best, …). Never hard-index a key
scripts/campaign_shell.gd:828:	if disk.has("mudroom_loadout") and typeof(disk["mudroom_loadout"]) == TYPE_ARRAY:
scripts/campaign_shell.gd:829:		state["mudroom_loadout"] = (disk["mudroom_loadout"] as Array).duplicate()
scripts/dev/shot_harness.gd:1480:	for r in ["hall", "study", "workshop", "loft", "mudroom"]:
scripts/home_cabin.gd:37:## Left of fireplace: study → workshop → loft. Right: trophy hall → Outpost (mudroom).
scripts/home_cabin.gd:38:const ROOM_ORDER: Array[String] = ["loft", "workshop", "study", "main", "hall", "mudroom"]
scripts/home_cabin.gd:58:## Hall + Outpost unlock together on the right path; start at the fireplace.
scripts/home_cabin.gd:60:var mudroom_loadout: Array = []
scripts/home_cabin.gd:855:	if _current_room == "mudroom":
scripts/home_cabin.gd:856:		_refresh_mudroom()
scripts/home_cabin.gd:1189:	## Right path first: hall (+ Outpost), then left study chain.
scripts/home_cabin.gd:4349:	mudroom_loadout = []
scripts/home_cabin.gd:4399:	## Outpost is right of hall — keep them unlocked as a pair.
scripts/home_cabin.gd:4400:	if rooms_unlocked.has("mudroom") and not rooms_unlocked.has("hall"):
scripts/home_cabin.gd:4402:	if rooms_unlocked.has("hall") and not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:4403:		rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:4404:	mudroom_loadout = []
scripts/home_cabin.gd:4405:	for raw_load in parsed.get("mudroom_loadout", []):
scripts/home_cabin.gd:4408:			mudroom_loadout.append(lid)
scripts/home_cabin.gd:4475:	data["mudroom_loadout"] = mudroom_loadout
scripts/home_cabin.gd:4667:		"mudroom":
scripts/home_cabin.gd:4668:			if not is_room_unlocked("mudroom"):
scripts/home_cabin.gd:4671:				rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:4674:			show_menu("mudroom")
scripts/home_cabin.gd:4675:			_refresh_mudroom()
scripts/home_cabin.gd:5050:		"mudroom": preload("res://scripts/cabin/room_mudroom.gd"),
scripts/home_cabin.gd:5337:	if room == "mudroom":
scripts/home_cabin.gd:5338:		_show_toast("room.mudroom.name")
scripts/home_cabin.gd:5339:		_refresh_mudroom()
scripts/home_cabin.gd:5381:	if room == "mudroom":
scripts/home_cabin.gd:5382:		_show_toast("room.mudroom.name")
scripts/home_cabin.gd:5383:		_refresh_mudroom()
scripts/home_cabin.gd:5481:	## Trophy hall and Outpost unlock as a pair on the right path.
scripts/home_cabin.gd:5482:	if unlock_room == "hall" and not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:5483:		rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:5663:		if node_name in ["RunDoor", "SideDoor", "LeftDoor", "BackDoor", "LeaveDoor", "OutDoor"]:
scripts/home_cabin.gd:5677:		"OutDoor", "LeaveDoor":
scripts/home_cabin.gd:5679:		"RerollJar":
scripts/home_cabin.gd:5763:	## Main's painted run door starts the rightward path (hall → Outpost → delve).
scripts/home_cabin.gd:5764:	## Delve itself is the Outpost right/out exit — never skip the trophy hall.
scripts/home_cabin.gd:5819:func _mudroom_item_rows() -> Array:
scripts/home_cabin.gd:5834:func _refresh_mudroom() -> void:
scripts/home_cabin.gd:5835:	var room = _rooms.get("mudroom")
scripts/home_cabin.gd:5845:func _commit_mudroom_loadout() -> void:
scripts/home_cabin.gd:5846:	var room = _rooms.get("mudroom")
scripts/home_cabin.gd:5853:		ids = mudroom_loadout.duplicate()
scripts/home_cabin.gd:5854:	mudroom_loadout = ids.duplicate()
scripts/home_cabin.gd:5857:		CAMPAIGN_SHELL.set_mudroom_loadout(camp.state, ids)
scripts/home_cabin.gd:5863:func _reroll_mudroom_hooks() -> void:
scripts/home_cabin.gd:5869:	var room = _rooms.get("mudroom")
scripts/home_cabin.gd:5872:	var ids: Array = CAMPAIGN_SHELL.roll_mudroom_hooks(rules, rng, _mudroom_item_rows(), keep)
scripts/home_cabin.gd:5873:	mudroom_loadout = ids.duplicate()
scripts/home_cabin.gd:5875:		CAMPAIGN_SHELL.set_mudroom_loadout(camp.state, ids)
scripts/home_cabin.gd:5878:	_refresh_mudroom()
scripts/home_cabin.gd:5980:			## Right door → trophy hall (then Outpost).
scripts/home_cabin.gd:5983:			## Right door → Outpost.
scripts/home_cabin.gd:5984:			_unlock_mudroom_with_hall()
scripts/home_cabin.gd:5985:			pan_to("mudroom")
scripts/home_cabin.gd:6018:func _unlock_mudroom_with_hall() -> void:
scripts/home_cabin.gd:6021:	if not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:6022:		rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:6029:		"mudroom":
scripts/cabin/room_main.gd:3:## Left door → study chain. Right door → trophy hall → Outpost.
scripts/cabin/room_main.gd:144:	## Painted run door starts the rightward hall path (does not skip to Outpost / delve).
scripts/dev/campaign_shell_selftest.gd:239:	var hooks: Array = Shell.roll_mudroom_hooks(rules, rng, [
scripts/dev/campaign_shell_selftest.gd:244:	failed = _check(failed, "mudroom hooks match mix", hooks.size() == 6) or failed
scripts/dev/campaign_shell_selftest.gd:245:	## Older campaign_save.json (no map_pieces / mudroom_loadout / …) must load.
scripts/dev/campaign_shell_selftest.gd:260:	failed = _check(failed, "old save mudroom_loadout default", (shell_old.state["mudroom_loadout"] as Array).is_empty()) or failed
scripts/dev/campaign_shell_selftest.gd:270:		"mudroom_loadout": ["smoke_bomb", "boot"],
scripts/dev/campaign_shell_selftest.gd:281:	failed = _check(failed, "new save copies mudroom_loadout", (shell_new.state["mudroom_loadout"] as Array) == ["smoke_bomb", "boot"]) or failed
scripts/cabin/room_hall.gd:48:	## SignOutpost (right door → Outpost) stays visible — do not hide it here.
scripts/cabin/room_hall.gd:61:	## Right door → Outpost (mudroom). Unlocks with the hall.
scripts/cabin/room_hall.gd:64:		side.tag_key = "cabin.hot.door_outpost" if mud_open else "cabin.hot.door_locked"
scripts/cabin/room_hall.gd:78:	for door_name in ["BackDoor", "SideDoor", "SignOutpost"]:
scripts/dev/cabin_nav_lock_probe.gd:313:	cabin.rooms_unlocked = ["main", "hall", "mudroom", "study"]
scripts/dev/cabin_nav_lock_probe.gd:419:	cabin.pan_to("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:436:		if str(cabin._current_room) == "mudroom" and not cabin._pan_busy:
scripts/dev/cabin_nav_lock_probe.gd:441:	failed = _check(failed, "pan_late_b_mudroom_intact", late_b_ok) or failed
scripts/dev/cabin_nav_lock_probe.gd:825:		not cabin.rooms_unlocked.has("hall") and not cabin.rooms_unlocked.has("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:855:	if unlock_room == "hall" and not rooms.has("mudroom"):
scripts/dev/cabin_nav_lock_probe.gd:856:		rooms.append("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:857:	return rooms.has("hall") and rooms.has("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:871:	cabin.rooms_unlocked = ["main", "hall", "mudroom"]
scripts/dev/cabin_nav_lock_probe.gd:1098:		cabin.is_room_unlocked("hall") and cabin.is_room_unlocked("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:1102:	## SideDoor from hall pans to mudroom (async flash then pan_to).
scripts/dev/cabin_nav_lock_probe.gd:1119:	## Optional InputEvent after room change (mudroom), not on hall LeftDoor.
scripts/dev/cabin_nav_lock_probe.gd:1122:	var clicked: bool = await _try_input_click_hotspot(cabin, "OutDoor", after_room)
scripts/dev/cabin_nav_lock_probe.gd:1124:		"INFO input_click_after_room_change room=%s node=OutDoor attempted=%s (not physical click proof)"
scripts/cabin/cabin_room.gd:97:	if bg.texture == null and room_id == "mudroom":
scripts/cabin/cabin_room.gd:180:		"LeaveDoor": "mudroom.exit.out",
scripts/cabin/cabin_room.gd:198:		"SignOutpost": "cabin.hall.sign_outpost",
scripts/cabin/cabin_room.gd:213:		"OutDoor": "mudroom.exit.out",
scripts/cabin/cabin_room.gd:214:		"RerollJar": "mudroom.jar",
scripts/cabin/cabin_room.gd:216:	if room_id == "mudroom" and node_name == "BackDoor":
scripts/cabin/cabin_room.gd:217:		return "mudroom.exit.cabin"
scripts/cabin/room_mudroom.gd:2:## Outpost: large labeled wall map is the only run control. Back door → trophy hall.
scripts/cabin/room_mudroom.gd:23:var _mudroom_bg_built: bool = false
scripts/cabin/room_mudroom.gd:28:	_title_lab.name = "MudroomTitle"
scripts/cabin/room_mudroom.gd:29:	_title_lab.text = KIT.copy_text("room.mudroom.name")
scripts/cabin/room_mudroom.gd:31:		_title_lab.text = "Outpost"
scripts/cabin/room_mudroom.gd:40:	_hint_lab.name = "MudroomHint"
scripts/cabin/room_mudroom.gd:47:	_hint_lab.text = KIT.copy_text("mudroom.space")
scripts/cabin/room_mudroom.gd:100:			hotspot_activated.emit("OutDoor")
scripts/cabin/room_mudroom.gd:104:		hotspot_hovered.emit("OutDoor", "mudroom.exit.out", _map_host)
scripts/cabin/room_mudroom.gd:107:		hotspot_unhovered.emit("OutDoor")
scripts/cabin/room_mudroom.gd:111:	spots["OutDoor"] = _map_host
scripts/cabin/room_mudroom.gd:126:	_build_mudroom_layers()
scripts/cabin/room_mudroom.gd:130:func _build_mudroom_layers() -> void:
scripts/cabin/room_mudroom.gd:131:	if _mudroom_bg_built:
scripts/cabin/room_mudroom.gd:133:	_mudroom_bg_built = true
scripts/cabin/room_mudroom.gd:135:	host.name = "MudroomLayers"
scripts/cabin/room_mudroom.gd:166:	for hide_name in ["LeaveDoor", "RerollJar"]:
scripts/cabin/room_mudroom.gd:174:	var laid = get_node_or_null("OutDoor")
scripts/cabin/room_mudroom.gd.uid:1:uid://bq8mudrooms8peg1
scripts/cabin/cabin_kit.gd:20:## Left of fireplace: study → workshop → loft. Right: trophy hall → Outpost (mudroom).
scripts/cabin/cabin_kit.gd:21:const ROOM_ORDER: Array[String] = ["loft", "workshop", "study", "main", "hall", "mudroom"]
tools/qa/check_campaign_save_copy.py:39:    for key in ("banked", "seen_deadly", "mudroom_loadout", "run"):
tools/qa/check_campaign_save_copy.py:64:        "mudroom_loadout": [],
tools/qa/check_campaign_save_copy.py:74:    if "mudroom_loadout" in old and isinstance(old["mudroom_loadout"], list):
tools/qa/check_campaign_save_copy.py:75:        state["mudroom_loadout"] = list(old["mudroom_loadout"])
tools/qa/check_campaign_save_copy.py:84:    assert state["mudroom_loadout"] == []
tools/qa/check_campaign_save_copy.py:91:        "mudroom_loadout": ["smoke_bomb", "boot"],
tools/qa/check_campaign_save_copy.py:99:    if "mudroom_loadout" in new and isinstance(new["mudroom_loadout"], list):
tools/qa/check_campaign_save_copy.py:100:        state2["mudroom_loadout"] = list(new["mudroom_loadout"])
tools/qa/check_campaign_save_copy.py:105:    assert state2["mudroom_loadout"] == ["smoke_bomb", "boot"]
```

## Main-room centre RunDoor

```
data/cabin-layout.json:69:    "file": "doors/run_door_closed.png",
data/cabin-layout.json:84:    "hover": "doors/run_door_hover.png",
data/cabin-layout.json:144:    "node": "RunDoor",
data/cabin-layout.json:145:    "file": "doors/run_door_closed.png",
data/cabin-layout.json:160:    "hover": "doors/run_door_hover.png",
data/cabin-layout.json:1550:    "run_door": [
scripts/cabin/room_main.gd:145:	var run = spots.get("RunDoor", null)
scripts/cabin/room_main.gd:147:		run.tag_key = "cabin.hot.run_door" if hall_open else "cabin.hot.door_locked"
scripts/cabin/room_main.gd:148:		run.set_locked(not hall_open, KIT.load_tex("doors/run_door_closed.png"))
scripts/cabin/cabin_room.gd:177:		"RunDoor": "cabin.hot.run_door",
scripts/dev/shot_harness.gd:2155:		"67_run_door_open_f2", "68_side_door_open", "69_drawer_rattle", "70_drawer_open",
scripts/dev/shot_harness.gd:3299:		_skip("67_run_door_open_f2.png", "home_cabin missing")
scripts/dev/shot_harness.gd:3318:	if cabin.has_method("debug_run_door_open"):
scripts/dev/shot_harness.gd:3319:		cabin.debug_run_door_open(2)
scripts/dev/shot_harness.gd:3321:		await _capture("67_run_door_open_f2.png", "run door open f2 (night + Grumblegut)")
scripts/dev/shot_harness.gd:3323:		_skip("67_run_door_open_f2.png", "debug_run_door_open missing")
scripts/home_cabin.gd:5663:		if node_name in ["RunDoor", "SideDoor", "LeftDoor", "BackDoor", "LeaveDoor", "OutDoor"]:
scripts/home_cabin.gd:5672:	if _busy() and node_name != "Nib" and not (node_name == "RunDoor" and _gate_on()):
scripts/home_cabin.gd:5675:		"RunDoor":
scripts/home_cabin.gd:5676:			_on_run_door()
scripts/home_cabin.gd:5762:func _on_run_door() -> void:
scripts/home_cabin.gd:5774:func _play_run_door_open() -> void:
scripts/home_cabin.gd:5778:	var hs = room.spots.get("RunDoor", null)
scripts/home_cabin.gd:5781:	var rels := ["doors/run_door_open_f0.png", "doors/run_door_open_f1.png", "doors/run_door_open_f2.png"]
scripts/home_cabin.gd:5928:	await _play_run_door_open()
scripts/home_cabin.gd:6540:func debug_run_door_open(frame: int = 2) -> void:
scripts/home_cabin.gd:6544:	var hs = room.spots.get("RunDoor", null)
scripts/home_cabin.gd:6547:	var tex: Texture2D = KIT.load_tex("doors/run_door_open_f%d.png" % clampi(frame, 0, 2))
```

## Trophy cabinets (BiomeCabinets, TrophyCase, dumbwaiter, hall zoom, case_*)

```
data/cabin-layout.json:523:    "note": "back to main (left). Hit matches the painted doorway on cabinets_wall."
data/cabin-layout.json:544:    "note": "to Outpost (mudroom). Hit matches the painted right cabinet on cabinets_wall."
data/cabin-layout.json:568:    "node": "Gauge",
data/cabin-layout.json:589:    "node": "ShelfPrev",
data/cabin-layout.json:610:    "node": "ShelfNext",
data/cabin-layout.json:649:    "note": "_shelf_host / hole aligned to Doop plate case bounds"
data/cabin-layout.json:1600:    "cases_bounds": [
data/cabin-layout.json:1606:    "case_glass": [
scripts/dev/collection_a_live_repot.gd:628:	cabin.focus_biome_case("b1")
scripts/dev/collection_a_live_repot.gd:633:	var host = cabin.get("_shelf_host")
scripts/cabin/room_hall.gd:2:## Trophy hall. Cabin reparents _hole / _shelf_host here.
scripts/cabin/room_hall.gd:7:const CABINETS_WALL := "rooms/cabinets_wall.png"
scripts/cabin/room_hall.gd:12:	if ResourceLoader.exists(KIT.HOME + CABINETS_WALL):
scripts/cabin/room_hall.gd:13:		_bg_rel = CABINETS_WALL
scripts/cabin/room_hall.gd:24:	var plate: Texture2D = KIT.load_tex(CABINETS_WALL)
scripts/cabin/room_hall.gd:27:		_bg_rel = CABINETS_WALL
scripts/cabin/room_hall.gd:42:	if g is CanvasItem and _bg_rel == CABINETS_WALL:
scripts/cabin/room_hall.gd:49:	for hide_name in ["ShelfPrev", "ShelfNext", "Gauge"]:
scripts/cabin/dumbwaiter.gd:2:class_name Dumbwaiter
scripts/cabin/dumbwaiter.gd:3:## Left-wall dumbwaiter: 5 stops gate the biome pools. Session-only car park.
scripts/cabin/dumbwaiter.gd:48:	name = "Dumbwaiter"
scripts/cabin/dumbwaiter.gd:117:	shaft.texture = KIT.load_tex("hall/dumbwaiter_shaft")
scripts/cabin/dumbwaiter.gd:130:		push_warning("Dumbwaiter missing hall/dumbwaiter_shaft.png")
scripts/cabin/dumbwaiter.gd:162:	_car.texture = KIT.load_tex("hall/dumbwaiter_car")
scripts/cabin/dumbwaiter.gd:198:		lamp.texture = KIT.load_tex("hall/dumbwaiter_lamp_off")
scripts/cabin/dumbwaiter.gd:225:		tab.texture = KIT.load_tex("hall/dumbwaiter_tab")
scripts/cabin/dumbwaiter.gd:237:		elif k - 1 < BiomeCabinets.CASES.size():
scripts/cabin/dumbwaiter.gd:238:			accent = Color(str((BiomeCabinets.CASES[k - 1] as Dictionary).get("accent", "7dae62")))
scripts/cabin/dumbwaiter.gd:255:		var t: Texture2D = KIT.load_tex("hall/dumbwaiter_lever_f%d" % fi)
scripts/cabin/dumbwaiter.gd:284:			(_lamps[i] as TextureRect).texture = KIT.load_tex("hall/dumbwaiter_lamp_on" if on else "hall/dumbwaiter_lamp_off")
scripts/cabin/trophy_case.gd:2:class_name TrophyCase
scripts/cabin/trophy_case.gd:29:var _state: int = BiomeCabinets.CaseState.LOCKED
scripts/cabin/trophy_case.gd:98:	_page_count = BiomeCabinets.page_count(_slot_ids.size())
scripts/cabin/trophy_case.gd:100:	var outer := BiomeCabinets.outer_rect(case_index)
scripts/cabin/trophy_case.gd:155:		var g: Texture2D = BiomeCabinets.trophy_grey_texture(case_spec)
scripts/cabin/trophy_case.gd:159:		var c: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
scripts/cabin/trophy_case.gd:219:	var shape := BiomeCabinets.shape_of(case_index)
scripts/cabin/trophy_case.gd:226:	var glass_n := BiomeCabinets.glass_rect(case_index)
scripts/cabin/trophy_case.gd:227:	var outer_n := BiomeCabinets.outer_rect(case_index)
scripts/cabin/trophy_case.gd:284:	var outer_n := BiomeCabinets.outer_rect(case_index)
scripts/cabin/trophy_case.gd:286:		return (BiomeCabinets.SPIRES_SHEET_ORIGIN - outer_n.position) * PX
scripts/cabin/trophy_case.gd:287:	var glass_n := BiomeCabinets.glass_rect(case_index)
scripts/cabin/trophy_case.gd:299:	var cr := BiomeCabinets.crown_rect(case_index)
scripts/cabin/trophy_case.gd:315:	var idle: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
scripts/cabin/trophy_case.gd:319:	_crest.set_meta("hover", BiomeCabinets.trophy_texture(case_spec, true))
scripts/cabin/trophy_case.gd:320:	_crest.set_meta("grey", BiomeCabinets.trophy_grey_texture(case_spec))
scripts/cabin/trophy_case.gd:362:	var lamp_at := BiomeCabinets.lamp_anchor(case_index)
scripts/cabin/trophy_case.gd:397:	var glass := BiomeCabinets.glass_rect(case_index)
scripts/cabin/trophy_case.gd:437:	var crest_tex: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
scripts/cabin/trophy_case.gd:460:	var bar_n := Rect2(glass_n.position.x, float(BiomeCabinets.PAGE_BAR_Y), glass_n.size.x, float(BiomeCabinets.PAGE_BAR_H))
scripts/cabin/trophy_case.gd:522:		if BiomeCabinets.page_state(_slot_ids, pi, banked_claim) == BiomeCabinets.PageState.PAGE_FULL:
scripts/cabin/trophy_case.gd:542:	_page_bar.mouse_filter = Control.MOUSE_FILTER_STOP if _state != BiomeCabinets.CaseState.LOCKED else Control.MOUSE_FILTER_IGNORE
scripts/cabin/trophy_case.gd:546:	var pr := BiomeCabinets.plaque_rect(case_index)
scripts/cabin/trophy_case.gd:640:	var start := page * BiomeCabinets.PAGE_SLOTS
scripts/cabin/trophy_case.gd:641:	for cell_i in BiomeCabinets.PAGE_SLOTS:
scripts/cabin/trophy_case.gd:676:	var pst := BiomeCabinets.peg_state(id, _banked, _seen)
scripts/cabin/trophy_case.gd:693:		BiomeCabinets.PegState.UNSEEN:
scripts/cabin/trophy_case.gd:695:		BiomeCabinets.PegState.SEEN:
scripts/cabin/trophy_case.gd:700:	if pst == BiomeCabinets.PegState.SEEN:
scripts/cabin/trophy_case.gd:716:	if pst == BiomeCabinets.PegState.SEEN:
scripts/cabin/trophy_case.gd:718:	elif pst == BiomeCabinets.PegState.CLAIMED:
scripts/cabin/trophy_case.gd:730:	if pst != BiomeCabinets.PegState.UNSEEN:
scripts/cabin/trophy_case.gd:731:		var ink := Color("1e120c") if pst == BiomeCabinets.PegState.CLAIMED else Color("6e6e6e")
scripts/cabin/trophy_case.gd:745:	if pst == BiomeCabinets.PegState.CLAIMED:
scripts/cabin/trophy_case.gd:830:	var locked := _state == BiomeCabinets.CaseState.LOCKED
scripts/cabin/trophy_case.gd:831:	var opened := _state == BiomeCabinets.CaseState.OPENED or _state == BiomeCabinets.CaseState.COMPLETE
scripts/cabin/trophy_case.gd:832:	var complete := _state == BiomeCabinets.CaseState.COMPLETE
scripts/cabin/trophy_case.gd:856:		elif _state == BiomeCabinets.CaseState.IN_PROGRESS:
scripts/cabin/trophy_case.gd:869:		_count_lab.text = BiomeCabinets.crown_text(_claimed, _slot_ids.size())
scripts/cabin/trophy_case.gd:879:	var lit := BiomeCabinets.pips_lit(_claimed, _quota)
scripts/cabin/trophy_case.gd:918:	if _crest and _state != BiomeCabinets.CaseState.LOCKED and _state != BiomeCabinets.CaseState.IN_PROGRESS:
scripts/cabin/trophy_case.gd:922:	elif _crest and _state == BiomeCabinets.CaseState.IN_PROGRESS:
scripts/cabin/trophy_case.gd:926:	case_hovered.emit(pool_id, _state != BiomeCabinets.CaseState.LOCKED)
scripts/cabin/trophy_case.gd:931:		if _state == BiomeCabinets.CaseState.IN_PROGRESS:
scripts/cabin/trophy_case.gd:1009:	if pst != BiomeCabinets.PegState.UNSEEN and peg.get_node_or_null("HoverFrame") == null:
scripts/cabin/trophy_case.gd:1020:	if pst != BiomeCabinets.PegState.UNSEEN:
scripts/cabin/trophy_case.gd:1041:			if pst == BiomeCabinets.PegState.UNSEEN:
scripts/cabin/trophy_case.gd:1094:	push_warning("TrophyCase missing art: %s (pool %s)" % [rel, pool_id])
scripts/ui/progress_menu.gd:10:const BIOME := preload("res://scripts/biome_cabinets.gd")
scripts/cabin/cabin_room.gd:195:		"ShelfPrev": "cabin.hot.cabinet",
scripts/cabin/cabin_room.gd:196:		"ShelfNext": "cabin.hot.cabinet",
scripts/cabin/cabin_room.gd:197:		"Gauge": "cabin.hot.gauge",
scripts/dev/biome_cabinets_selftest.gd:6:	var Cases = load("res://scripts/biome_cabinets.gd")
scripts/dev/biome_cabinets_selftest.gd:108:	var bounds: Rect2 = Cases.cases_bounds_rect()
scripts/dev/biome_cabinets_selftest.gd:110:	failed = _check(failed, "five glass", Cases.CASE_GLASS.size() == 5) or failed
scripts/dev/biome_cabinets_selftest.gd:190:	for gi2 in range(Cases.CASE_GLASS.size()):
scripts/dev/biome_cabinets_selftest.gd:245:		print("BIOME_CABINETS_FAIL")
scripts/dev/biome_cabinets_selftest.gd:248:	print("BIOME_CABINETS_OK")
tools/qa/check_trophy_pegs_fit.py:2:"""Headless assert: Trophy Hall peg columns fit inside CASE_GLASS above the case base.
tools/qa/check_trophy_pegs_fit.py:4:Mirrors scripts/biome_cabinets.gd peg_column_layout + glass height 121.
tools/qa/check_trophy_pegs_fit.py:11:CASE_GLASS = [
tools/qa/check_trophy_pegs_fit.py:64:    for i, g in enumerate(CASE_GLASS):
tools/qa/check_trophy_pegs_fit.py:70:        # Painted case accent on cabinets_wall starts ~y=764; glass bottom must be <= 756.
scripts/home_cabin.gd:161:var _shelf_host: Control
scripts/home_cabin.gd:206:var _case_page: Dictionary = {}
scripts/home_cabin.gd:208:var _trophy_cases: Dictionary = {}
scripts/home_cabin.gd:209:var _dumbwaiter = null
scripts/home_cabin.gd:210:var _hall_zoom_pool: String = ""
scripts/home_cabin.gd:211:var _hall_zoom_dim: ColorRect = null
scripts/home_cabin.gd:214:var _hall_zooming: bool = false
scripts/home_cabin.gd:215:var _hall_zoom_closing: bool = false
scripts/home_cabin.gd:216:var _hall_zoom_tw: Tween = null
scripts/home_cabin.gd:825:		_rebuild_shelves()
scripts/home_cabin.gd:853:	_rebuild_shelves()
scripts/home_cabin.gd:960:		focus_biome_case(pool)
scripts/home_cabin.gd:984:	focus_biome_case(pool_id)
scripts/home_cabin.gd:997:func focus_biome_case(pool_id: String) -> void:
scripts/home_cabin.gd:998:	if _shelf_host == null:
scripts/home_cabin.gd:1001:	for child in _shelf_host.get_children():
scripts/home_cabin.gd:1009:	var root := _shelf_host.get_node_or_null("Case_%s" % pool_id) as Control
scripts/home_cabin.gd:2157:	_rebuild_shelves()
scripts/home_cabin.gd:2476:	tw.tween_property(_shelf_host, "position:x", -off, 0.25)
scripts/home_cabin.gd:2483:	_rebuild_shelves()
scripts/home_cabin.gd:2484:	_shelf_host.position.x = off
scripts/home_cabin.gd:2488:	tw.tween_property(_shelf_host, "position:x", 0.0, 0.25)
scripts/home_cabin.gd:2494:	_shelf_host.position.x = 0.0
scripts/home_cabin.gd:2545:func _rebuild_shelves() -> void:
scripts/home_cabin.gd:2546:	if _shelf_host == null:
scripts/home_cabin.gd:2548:	for c in _shelf_host.get_children():
scripts/home_cabin.gd:2549:		_shelf_host.remove_child(c)
scripts/home_cabin.gd:2555:	_shelf_host.size = _hole.size if _hole else _pt(260, 160)
scripts/home_cabin.gd:2558:	_fill_biome_cases()
scripts/home_cabin.gd:2579:	return BiomeCabinets.pool_for_bucket(_biome_rules(), b)
scripts/home_cabin.gd:2636:	var quota := BiomeCabinets.quota_of(rules)
scripts/home_cabin.gd:2639:	for raw in BiomeCabinets.resolved_cases(rules):
scripts/home_cabin.gd:2643:		lines.append(BiomeCabinets.progress_text(_case_collected(pool), cards.size(), quota))
scripts/home_cabin.gd:2647:func _fill_biome_cases() -> void:
scripts/home_cabin.gd:2648:	_trophy_cases.clear()
scripts/home_cabin.gd:2650:	var cases: Array = BiomeCabinets.resolved_cases(rules)
scripts/home_cabin.gd:2651:	var quota := BiomeCabinets.quota_of(rules)
scripts/home_cabin.gd:2659:		var cards: Array = BiomeCabinets.fixed_slots(grouped.get(pool_id, []))
scripts/home_cabin.gd:2664:		var cst: int = BiomeCabinets.case_state(rules, state, pool_id, slot_ids, _claimed_subset(slot_ids, banked))
scripts/home_cabin.gd:2665:		var page := int(_case_page.get(pool_id, -1))
scripts/home_cabin.gd:2667:			page = BiomeCabinets.default_page(slot_ids, banked)
scripts/home_cabin.gd:2668:		_case_page[pool_id] = page
scripts/home_cabin.gd:2669:		var tc = preload("res://scripts/cabin/trophy_case.gd").new()
scripts/home_cabin.gd:2671:		tc.case_hovered.connect(_on_trophy_case_hover)
scripts/home_cabin.gd:2673:		tc.case_clicked.connect(_on_trophy_case_clicked)
scripts/home_cabin.gd:2678:			_case_page[p] = pg
scripts/home_cabin.gd:2680:		_shelf_host.add_child(tc)
scripts/home_cabin.gd:2681:		_trophy_cases[pool_id] = tc
scripts/home_cabin.gd:2685:	_refresh_dumbwaiter()
scripts/home_cabin.gd:2723:func _refresh_dumbwaiter() -> void:
scripts/home_cabin.gd:2724:	if _dumbwaiter == null:
scripts/home_cabin.gd:2736:	_dumbwaiter.refresh(lit, park)
scripts/home_cabin.gd:2739:func _on_trophy_case_hover(pool_id: String, unlocked: bool) -> void:
scripts/home_cabin.gd:2740:	var hit: Control = _trophy_cases.get(pool_id, null)
scripts/home_cabin.gd:2744:func _on_trophy_case_clicked(pool_id: String) -> void:
scripts/home_cabin.gd:2745:	if _hall_zooming or _bank_busy:
scripts/home_cabin.gd:2752:	_open_hall_zoom(pool_id)
scripts/home_cabin.gd:2768:	## Retired — hall builds TrophyCase via _fill_biome_cases.
scripts/home_cabin.gd:2778:func _ensure_dumbwaiter(hall: Node) -> void:
scripts/home_cabin.gd:2781:	if _dumbwaiter != null and is_instance_valid(_dumbwaiter):
scripts/home_cabin.gd:2784:	for raw in BiomeCabinets.CASES:
scripts/home_cabin.gd:2786:	_dumbwaiter = preload("res://scripts/cabin/dumbwaiter.gd").new()
scripts/home_cabin.gd:2787:	_dumbwaiter.setup(self, accents)
scripts/home_cabin.gd:2788:	_dumbwaiter.stop_chosen.connect(_on_dumbwaiter_stop)
scripts/home_cabin.gd:2789:	_dumbwaiter.stop_hovered.connect(_on_dumbwaiter_hover)
scripts/home_cabin.gd:2790:	_dumbwaiter.stop_unhovered.connect(hide_hover_tag)
scripts/home_cabin.gd:2791:	_dumbwaiter.lever_hovered.connect(func() -> void:
scripts/home_cabin.gd:2792:		show_hover_tag("cabin.hall.lift_lever", _dumbwaiter)
scripts/home_cabin.gd:2794:	_dumbwaiter.map_focus_wanted.connect(func(pool: String) -> void:
scripts/home_cabin.gd:2798:	if _dumbwaiter._sign:
scripts/home_cabin.gd:2799:		_dumbwaiter._sign.text = COPY.text("cabin.hall.lift_sign", "LIFT")
scripts/home_cabin.gd:2800:	hall.add_child(_dumbwaiter)
scripts/home_cabin.gd:2803:func _ensure_hall_zoom_dim(hall: Node) -> void:
scripts/home_cabin.gd:2804:	## Dim lives under `_hole` so TrophyCase z_index can sit above it.
scripts/home_cabin.gd:2805:	if _hall_zoom_dim != null or _hole == null:
scripts/home_cabin.gd:2807:	_hall_zoom_dim = ColorRect.new()
scripts/home_cabin.gd:2808:	_hall_zoom_dim.name = "ZoomDim"
scripts/home_cabin.gd:2809:	_hall_zoom_dim.color = Color("0b0706", 0.0)
scripts/home_cabin.gd:2810:	_hall_zoom_dim.position = Vector2.ZERO
scripts/home_cabin.gd:2811:	_hall_zoom_dim.size = _hole.size
scripts/home_cabin.gd:2812:	_hall_zoom_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
scripts/home_cabin.gd:2813:	_hall_zoom_dim.z_index = 10
scripts/home_cabin.gd:2814:	_hall_zoom_dim.visible = false
scripts/home_cabin.gd:2815:	_hall_zoom_dim.gui_input.connect(_on_zoom_dim_input)
scripts/home_cabin.gd:2816:	_hole.add_child(_hall_zoom_dim)
scripts/home_cabin.gd:2819:func _on_dumbwaiter_hover(pool: String, lit: bool) -> void:
scripts/home_cabin.gd:2821:		show_hover_tag("cabin.hall.locked", _dumbwaiter)
scripts/home_cabin.gd:2825:	for raw in BiomeCabinets.resolved_cases(rules):
scripts/home_cabin.gd:2837:	if _dumbwaiter:
scripts/home_cabin.gd:2838:		_hover_tag.global_position = _dumbwaiter.get_global_rect().position + Vector2(8, -36)
scripts/home_cabin.gd:2841:func _on_dumbwaiter_stop(pool: String) -> void:
scripts/home_cabin.gd:2843:	var tc = _trophy_cases.get(pool, null)
scripts/home_cabin.gd:2846:	focus_biome_case(pool)
scripts/home_cabin.gd:2849:	var slots: Array = BiomeCabinets.fixed_slots(grouped.get(pool, []))
scripts/home_cabin.gd:2857:	if _dumbwaiter == null:
scripts/home_cabin.gd:2862:		for raw2 in BiomeCabinets.resolved_cases(rules):
scripts/home_cabin.gd:2864:				var crest: Texture2D = BiomeCabinets.trophy_texture(raw2 as Dictionary, false)
scripts/home_cabin.gd:2865:				_dumbwaiter.set_tray_tex(crest, false)
scripts/home_cabin.gd:2866:				if _dumbwaiter._tray:
scripts/home_cabin.gd:2867:					_dumbwaiter._tray.modulate = Color(1, 1, 1, 0.5)
scripts/home_cabin.gd:2872:	_dumbwaiter.set_tray_tex(tex, true)
scripts/home_cabin.gd:2885:	var tc = _trophy_cases.get(resolved, null)
scripts/home_cabin.gd:2887:		tc = _trophy_cases.get(pool, null)
scripts/home_cabin.gd:2893:	## Prefer the live TrophyCase slot list (same order as fixed_slots).
scripts/home_cabin.gd:2899:		for raw in BiomeCabinets.fixed_slots(grouped.get(resolved, [])):
scripts/home_cabin.gd:2907:	var page := BiomeCabinets.slot_page(idx)
scripts/home_cabin.gd:2910:	_case_page[resolved] = page
scripts/home_cabin.gd:2919:	## dumbwaiter/rebuild/ride mutations after a cancelled await.
scripts/home_cabin.gd:2922:	var tc = _trophy_cases.get(pool_id, null)
scripts/home_cabin.gd:2925:			_rebuild_shelves()
scripts/home_cabin.gd:2963:	var bi := BiomeCabinets.case_index(pool_id)
scripts/home_cabin.gd:2965:	var next_tc = _trophy_cases.get(next_pool, null)
scripts/home_cabin.gd:2969:	if _dumbwaiter != null:
scripts/home_cabin.gd:2970:		_dumbwaiter.light_stop(bi + 2, true)
scripts/home_cabin.gd:2971:		_dumbwaiter._park = bi + 2
scripts/home_cabin.gd:2975:	_rebuild_shelves()
scripts/home_cabin.gd:2976:	if _dumbwaiter != null:
scripts/home_cabin.gd:2977:		await _dumbwaiter.ride_to(bi + 2)
scripts/home_cabin.gd:2983:	if not _hall_zooming:
scripts/home_cabin.gd:2987:		_close_hall_zoom()
scripts/home_cabin.gd:2991:func _open_hall_zoom(pool_id: String) -> void:
scripts/home_cabin.gd:2993:	var tc = _trophy_cases.get(pool_id, null)
scripts/home_cabin.gd:2994:	if hall == null or tc == null or _hall_zooming:
scripts/home_cabin.gd:2996:	_hall_zooming = true
scripts/home_cabin.gd:2997:	_hall_zoom_pool = pool_id
scripts/home_cabin.gd:3005:	var target: Vector2 = BiomeCabinets.hall_zoom_target(
scripts/home_cabin.gd:3008:	if _hall_zoom_dim:
scripts/home_cabin.gd:3009:		_hall_zoom_dim.visible = true
scripts/home_cabin.gd:3010:		_hall_zoom_dim.color.a = 0.0
scripts/home_cabin.gd:3011:		_hall_zoom_dim.z_index = 10
scripts/home_cabin.gd:3012:		_hall_zoom_dim.mouse_filter = Control.MOUSE_FILTER_STOP
scripts/home_cabin.gd:3016:	if _dumbwaiter and _dumbwaiter.has_method("set_input_enabled"):
scripts/home_cabin.gd:3017:		_dumbwaiter.set_input_enabled(false)
scripts/home_cabin.gd:3018:	if _hall_zoom_tw:
scripts/home_cabin.gd:3019:		_hall_zoom_tw.kill()
scripts/home_cabin.gd:3021:	_hall_zoom_tw = tw
scripts/home_cabin.gd:3027:	if _hall_zoom_dim:
scripts/home_cabin.gd:3028:		tw.parallel().tween_property(_hall_zoom_dim, "color:a", 0.25, 0.35)
scripts/home_cabin.gd:3030:	if _hall_zoom_tw == tw:
scripts/home_cabin.gd:3031:		_hall_zoom_tw = null
scripts/home_cabin.gd:3034:func _close_hall_zoom() -> void:
scripts/home_cabin.gd:3035:	if not _hall_zooming or _hall_zoom_closing:
scripts/home_cabin.gd:3039:		_finish_hall_zoom_closed()
scripts/home_cabin.gd:3041:	_hall_zoom_closing = true
scripts/home_cabin.gd:3043:	if _hall_zoom_tw:
scripts/home_cabin.gd:3044:		var opening := _hall_zoom_tw
scripts/home_cabin.gd:3045:		_hall_zoom_tw = null
scripts/home_cabin.gd:3047:	var tc = _trophy_cases.get(_hall_zoom_pool, null)
scripts/home_cabin.gd:3049:	_hall_zoom_tw = tw
scripts/home_cabin.gd:3055:	if _hall_zoom_dim:
scripts/home_cabin.gd:3056:		tw.parallel().tween_property(_hall_zoom_dim, "color:a", 0.0, 0.25)
scripts/home_cabin.gd:3058:	if _hall_zoom_tw != tw:
scripts/home_cabin.gd:3060:	_finish_hall_zoom_closed(tc)
scripts/home_cabin.gd:3063:func _snap_hall_zoom_closed() -> void:
scripts/home_cabin.gd:3064:	if not _hall_zooming and not _hall_zoom_closing:
scripts/home_cabin.gd:3066:	if _hall_zoom_tw:
scripts/home_cabin.gd:3067:		var tw := _hall_zoom_tw
scripts/home_cabin.gd:3068:		_hall_zoom_tw = null
scripts/home_cabin.gd:3074:	_finish_hall_zoom_closed(_trophy_cases.get(_hall_zoom_pool, null))
scripts/home_cabin.gd:3077:func _finish_hall_zoom_closed(tc = null) -> void:
scripts/home_cabin.gd:3079:		tc = _trophy_cases.get(_hall_zoom_pool, null)
scripts/home_cabin.gd:3080:	if _hall_zoom_dim:
scripts/home_cabin.gd:3081:		_hall_zoom_dim.color.a = 0.0
scripts/home_cabin.gd:3082:		_hall_zoom_dim.visible = false
scripts/home_cabin.gd:3083:		_hall_zoom_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
scripts/home_cabin.gd:3088:	if _dumbwaiter and _dumbwaiter.has_method("set_input_enabled"):
scripts/home_cabin.gd:3089:		_dumbwaiter.set_input_enabled(true)
scripts/home_cabin.gd:3090:	_hall_zoom_pool = ""
scripts/home_cabin.gd:3091:	_hall_zooming = false
scripts/home_cabin.gd:3092:	_hall_zoom_closing = false
scripts/home_cabin.gd:3093:	_hall_zoom_tw = null
scripts/home_cabin.gd:3144:	if peg_state == BiomeCabinets.PegState.UNSEEN:
scripts/home_cabin.gd:3162:		for raw in BiomeCabinets.resolved_cases(rules):
scripts/home_cabin.gd:3166:		var depth := BiomeCabinets.case_index(pool) + 1
scripts/home_cabin.gd:3175:		if peg_state == BiomeCabinets.PegState.CLAIMED:
scripts/home_cabin.gd:3194:		if peg_state == BiomeCabinets.PegState.CLAIMED:
scripts/home_cabin.gd:3227:	var tc = _trophy_cases.get(_hall_zoom_pool, null)
scripts/home_cabin.gd:3246:## Sits in the glass top (BiomeCabinets.trophy_local_rect) — not on the peg floor.
scripts/home_cabin.gd:3248:	var idle: Texture2D = BiomeCabinets.trophy_texture(spec, false)
scripts/home_cabin.gd:3251:	var hover: Texture2D = BiomeCabinets.trophy_texture(spec, true)
scripts/home_cabin.gd:3255:	var slot := BiomeCabinets.trophy_local_rect(area, case_scale)
scripts/home_cabin.gd:3385:	var quota := BiomeCabinets.quota_of(_biome_rules())
scripts/home_cabin.gd:3386:	if BiomeCabinets.past_gate(got, quota):
scripts/home_cabin.gd:3389:	var need := BiomeCabinets.next_piece_need(got, quota)
scripts/home_cabin.gd:3449:		focus_biome_case(focus_pool)
scripts/home_cabin.gd:3478:	var quota := BiomeCabinets.quota_of(_biome_rules())
scripts/home_cabin.gd:3485:	var seq: Array = BiomeCabinets.bank_sequence(pending, pools)
scripts/home_cabin.gd:3532:		_rebuild_shelves()
scripts/home_cabin.gd:3536:				and BiomeCabinets.crossed_gate(before, _shown_count(pool), quota) \
scripts/home_cabin.gd:3548:		_rebuild_shelves()
scripts/home_cabin.gd:3559:		var gate_met := BiomeCabinets.past_gate(b1_shown, quota) or crossed.has("b1")
scripts/home_cabin.gd:3596:			var bi := BiomeCabinets.case_index(str(pool_id2))
scripts/home_cabin.gd:3622:	if _shelf_host != null and is_instance_valid(_shelf_host):
scripts/home_cabin.gd:3623:		return _shelf_host
scripts/home_cabin.gd:3787:	var tc_v: Variant = _trophy_cases.get(pool_id, null)
scripts/home_cabin.gd:3801:	if _shelf_host != null:
scripts/home_cabin.gd:3802:		var case_n: Node = _shelf_host.get_node_or_null("Case_%s" % pool_id)
scripts/home_cabin.gd:3878:	if pool_adds.is_empty() or _shelf_host == null:
scripts/home_cabin.gd:3890:	var case_n: Node = _shelf_host.get_node_or_null("Case_%s" % best_pool)
scripts/home_cabin.gd:3899:	var gauge := BiomeCabinets.progress_text(shown, total, quota)
scripts/home_cabin.gd:4534:		"biome_cases": BiomeCabinets.case_names(_biome_rules()),
scripts/home_cabin.gd:4578:	_rebuild_shelves()
scripts/home_cabin.gd:4771:		if _hall_zooming or _hall_zoom_closing:
scripts/home_cabin.gd:4772:			_close_hall_zoom()
scripts/home_cabin.gd:4784:			and (_hall_zooming or _hall_zoom_closing):
scripts/home_cabin.gd:4789:		var tc = _trophy_cases.get(_hall_zoom_pool, null)
scripts/home_cabin.gd:4793:			_close_hall_zoom()
scripts/home_cabin.gd:4798:			and (_hall_zooming or _hall_zoom_closing):
scripts/home_cabin.gd:4799:		_close_hall_zoom()
scripts/home_cabin.gd:4806:	if _hall_zooming and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
scripts/home_cabin.gd:4807:		var tc = _trophy_cases.get(_hall_zoom_pool, null)
scripts/home_cabin.gd:4828:	if _hall_zooming:
scripts/home_cabin.gd:4829:		_close_hall_zoom()
scripts/home_cabin.gd:4904:	_rebuild_shelves()
scripts/home_cabin.gd:4964:	_rebuild_shelves()
scripts/home_cabin.gd:5020:	_rebuild_shelves()
scripts/home_cabin.gd:5111:	var bounds := BiomeCabinets.cases_bounds_rect()
scripts/home_cabin.gd:5121:	_ensure_dumbwaiter(hall)
scripts/home_cabin.gd:5122:	_ensure_hall_zoom_dim(hall)
scripts/home_cabin.gd:5123:	_shelf_host = Control.new()
scripts/home_cabin.gd:5124:	_shelf_host.position = Vector2.ZERO
scripts/home_cabin.gd:5125:	_shelf_host.size = _hole.size
scripts/home_cabin.gd:5126:	_shelf_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
scripts/home_cabin.gd:5127:	_hole.add_child(_shelf_host)
scripts/home_cabin.gd:5296:	if _hall_zooming or _hall_zoom_closing:
scripts/home_cabin.gd:5297:		_snap_hall_zoom_closed()
scripts/home_cabin.gd:5604:	_refresh_gauge()
scripts/home_cabin.gd:5607:func _refresh_gauge() -> void:
scripts/home_cabin.gd:5655:	if _hall_zooming or _hall_zoom_closing:
scripts/home_cabin.gd:5656:		_close_hall_zoom()
scripts/home_cabin.gd:5712:		"ShelfPrev":
scripts/home_cabin.gd:5714:		"ShelfNext":
scripts/home_cabin.gd:6607:	if hall == null or _shelf_host == null:
scripts/home_cabin.gd:6613:	_shelf_host.add_child(wrap)
scripts/dev/homecoming_live_repot.gd:716:	var tc = cabin._trophy_cases.get(pool, null)
tools/qa/ARC2_banking_contract_report.md:48:Historical `TIP_SMOKE_OK` / `CAMPAIGN_SHELL_OK` / `BIOME_CABINETS_OK` are **not** new ARC2 proof.
scripts/dev/homecoming_ceremony_selftest.gd:268:	cabin.set("_shelf_host", shelf)
scripts/dev/homecoming_ceremony_selftest.gd:365:	_uncovered(rows, "UNCOVERED.live_dialog_fx_cancel", "Full give-home dialogue + case_opened lamp/crest/dumbwaiter cancel under real CabinRoot tree not executed.")
scripts/biome_cabinets.gd:1:class_name BiomeCabinets
scripts/biome_cabinets.gd:3:## Five biome trophy cases + fixed peg pages. Hall chrome lives in TrophyCase.
scripts/biome_cabinets.gd:10:const CASES_BOUNDS: Array = [0, 0, 420, 260]
scripts/biome_cabinets.gd:14:## → CASE_GLASS[1] = (138,68,48,121).
scripts/biome_cabinets.gd:15:const CASE_GLASS: Array = [
scripts/biome_cabinets.gd:228:static func cases_bounds_rect() -> Rect2:
scripts/biome_cabinets.gd:230:		float(CASES_BOUNDS[0]),
scripts/biome_cabinets.gd:231:		float(CASES_BOUNDS[1]),
scripts/biome_cabinets.gd:232:		float(CASES_BOUNDS[2]),
scripts/biome_cabinets.gd:233:		float(CASES_BOUNDS[3])
scripts/biome_cabinets.gd:238:	if index < 0 or index >= CASE_GLASS.size():
scripts/biome_cabinets.gd:240:	var g: Array = CASE_GLASS[index]
```

## PR #447 progress menu

```
tools/qa/run_progress_menu.sh:5:#   ./tools/qa/run_progress_menu.sh
tools/qa/run_progress_menu.sh:6:#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_progress_menu.sh
tools/qa/run_progress_menu.sh:30:  echo "Source-only fallback: python3 tools/qa/check_progress_menu.py" >&2
tools/qa/run_progress_menu.sh:56:"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/progress_menu_selftest.gd >"$OUT" 2>&1
tools/qa/run_progress_menu.sh:59:echo "----- progress_menu_selftest.gd (exit $CODE) -----"
tools/qa/run_progress_menu.sh:63:if [[ -n "${PROGRESS_MENU_LOG:-}" ]]; then
tools/qa/run_progress_menu.sh:64:  cp "$OUT" "$PROGRESS_MENU_LOG"
tools/qa/run_progress_menu.sh:68:  echo "PROGRESS_MENU failed (exit $CODE)" >&2
tools/qa/run_progress_menu.sh:71:if ! grep -q 'PROGRESS_MENU_CEREMONY_OK' "$OUT"; then
tools/qa/run_progress_menu.sh:72:  echo "PROGRESS_MENU missing OK mark" >&2
tools/qa/run_progress_menu.sh:75:echo "PROGRESS_MENU local run OK (isolated user-data)"
scripts/dev/collection_a_live_repot.gd:40:		if main != null and main.get("progress_menu") != null and main.get("home_cabin") != null and main.get("_campaign") != null:
scripts/dev/collection_a_live_repot.gd:43:	if main == null or main.progress_menu == null or main.home_cabin == null or main._campaign == null:
scripts/dev/collection_a_live_repot.gd:170:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:191:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:200:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:210:	main.progress_menu.visible = false
scripts/dev/collection_a_live_repot.gd:308:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:363:	print("ROSTER_BIND b1 cabinet=%s roster_total=%s (source=progress_menu._pool_roster + CAMPAIGN_SHELL.cabinet_count)" % [cabinet_n, roster_total])
scripts/dev/collection_a_live_repot.gd:375:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:407:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:447:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:476:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:491:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:507:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:602:	var menu = main.progress_menu
scripts/dev/collection_a_live_repot.gd:616:	cabin.set_meta("progress_menu_handled_return", true)
scripts/dev/collection_a_live_repot.gd:622:	await cabin.open_cabin_after_progress_menu(
tools/qa/check_progress_menu.py:6:  ./tools/qa/run_progress_menu.sh
tools/qa/check_progress_menu.py:8:Exit 0 on pass. Prints PROGRESS_MENU_OK / FAIL.
tools/qa/check_progress_menu.py:108:    menu = read("scripts/ui/progress_menu.gd")
tools/qa/check_progress_menu.py:128:    ok("main.progress_menu_const", "PROGRESS_MENU" in main_gd)
tools/qa/check_progress_menu.py:129:    ok("main.open_helper", "func _open_progress_menu" in main_gd)
tools/qa/check_progress_menu.py:130:    ok("main.routes_win", '_open_progress_menu("win"' in main_gd)
tools/qa/check_progress_menu.py:131:    ok("main.routes_loss", '_open_progress_menu("loss"' in main_gd)
tools/qa/check_progress_menu.py:135:        and "_open_progress_menu(tut_kind" in main_gd,
tools/qa/check_progress_menu.py:153:        re.search(r'_open_progress_menu\("win".*true', main_gd, re.S) is not None
tools/qa/check_progress_menu.py:154:        or '_open_progress_menu("win", news, ids, true' in main_gd,
tools/qa/check_progress_menu.py:158:        "_open_progress_menu(tut_kind, [], [], false)" in main_gd,
tools/qa/check_progress_menu.py:163:        or main_gd.count('_open_progress_menu("win"') >= 2,
tools/qa/check_progress_menu.py:184:        "func _finalize_progress_menu_result" in main_gd
tools/qa/check_progress_menu.py:192:    ok("cabin.progress_menu_meta_gate", "progress_menu_handled_return" in cabin)
tools/qa/check_progress_menu.py:193:    ok("cabin.resume_respects_meta", "_resume_pending_bank_if_idle" in cabin and "progress_menu_handled_return" in cabin)
tools/qa/check_progress_menu.py:209:        print("PROGRESS_MENU_FAIL")
tools/qa/check_progress_menu.py:211:    print("PROGRESS_MENU_OK")
scripts/dev/house_unlock_first_return_selftest.gd:220:		rows, failed, "STATIC.progress_menu_api_credits",
scripts/dev/house_unlock_first_return_selftest.gd:221:		"open_cabin_after_progress_menu credits haul for house unlock",
scripts/dev/house_unlock_first_return_selftest.gd:222:		_func_body_contains(src, "func open_cabin_after_progress_menu", "_credit_homecoming_counters"),
scripts/dev/house_unlock_first_return_selftest.gd:236:		"finalize cabin path calls open_cabin_after_progress_menu (credits haul on win)",
scripts/dev/house_unlock_first_return_selftest.gd:239:			"func _finalize_progress_menu_result",
scripts/dev/house_unlock_first_return_selftest.gd:240:			"open_cabin_after_progress_menu"
scripts/dev/house_unlock_first_return_selftest.gd:249:			"func _finalize_progress_menu_result",
scripts/dev/house_unlock_first_return_selftest.gd:260:			"func _finalize_progress_menu_result",
scripts/dev/house_unlock_first_return_selftest.gd:266:	var menu_src := _read_source("res://scripts/ui/progress_menu.gd")
scripts/dev/house_unlock_first_return_selftest.gd:269:		"progress_menu present() stamps kind onto result for finalize",
scripts/dev/house_unlock_first_return_selftest.gd:279:	## Simulate open_cabin_after_progress_menu credit body without awaiting UI.
scripts/dev/house_unlock_first_return_selftest.gd:322:		"id": "UNCOVERED.fresh_save_gui_progress_menu",
scripts/dev/house_unlock_first_return_selftest.gd:325:	print("NOTE UNCOVERED.fresh_save_gui_progress_menu — static+helper ≠ headed Pixel progress-menu GUI")
tools/qa/run_progress_menu_main_routes.sh:38:OUT_DIR="${PROGRESS_MENU_OUT:-$ROOT/playtest/repot/outbox/REQ-20261108-progress-menu}"
tools/qa/run_progress_menu_main_routes.sh:48:RUNNER=("$GODOT_BIN" --path "$ROOT" --script res://scripts/dev/progress_menu_main_routes.gd)
tools/qa/run_progress_menu_main_routes.sh:62:  echo "===== progress_menu_main_routes SHA=$SHA exit=$CODE ====="
tools/qa/run_progress_menu_main_routes.sh:67:if grep -q 'PROGRESS_MENU_MAIN_ROUTES_FAIL' "$OUT"; then
tools/qa/run_progress_menu_main_routes.sh:68:  echo "PROGRESS_MENU_MAIN_ROUTES failed (FAIL mark; exit $CODE)" >&2
tools/qa/run_progress_menu_main_routes.sh:71:if [[ "$CODE" -ne 0 ]] || ! grep -q 'PROGRESS_MENU_MAIN_ROUTES_OK' "$OUT"; then
tools/qa/run_progress_menu_main_routes.sh:72:  echo "PROGRESS_MENU_MAIN_ROUTES failed (exit $CODE)" >&2
tools/qa/run_progress_menu_main_routes.sh:75:echo "PROGRESS_MENU_MAIN_ROUTES_OK SHA=$SHA"
scripts/ui/progress_menu.gd:82:	name = "ProgressMenu"
tools/qa/run_progress_menu_shots.sh:37:OUT_DIR="${PROGRESS_MENU_OUT:-$ROOT/playtest/repot/outbox/REQ-20261108-progress-menu}"
tools/qa/run_progress_menu_shots.sh:46:RUNNER=("$GODOT_BIN" --path "$ROOT" --script res://scripts/dev/progress_menu_shots.gd)
tools/qa/run_progress_menu_shots.sh:60:  echo "===== progress_menu_shots SHA=$SHA exit=$CODE ====="
scripts/dev/progress_menu_main_routes.gd:11:const OK_MARK := "PROGRESS_MENU_MAIN_ROUTES_OK"
scripts/dev/progress_menu_main_routes.gd:12:const FAIL_MARK := "PROGRESS_MENU_MAIN_ROUTES_FAIL"
scripts/dev/progress_menu_main_routes.gd:29:	print("PROGRESS_MENU_MAIN_ROUTES_SHA %s" % source_sha)
scripts/dev/progress_menu_main_routes.gd:71:		if main != null and main.get("progress_menu") != null and main.get("_campaign") != null:
scripts/dev/progress_menu_main_routes.gd:73:	var ok := main != null and main.progress_menu != null and main._campaign != null
scripts/dev/progress_menu_main_routes.gd:74:	_failed = _assert("BOOT.main", "Main + progress_menu + campaign", ok, "") or _failed
scripts/dev/progress_menu_main_routes.gd:120:		if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/progress_menu_main_routes.gd:130:		if main.progress_menu == null or not main.progress_menu.visible:
scripts/dev/progress_menu_main_routes.gd:136:	var menu = main.progress_menu
scripts/dev/progress_menu_main_routes.gd:142:	var menu = main.progress_menu
scripts/dev/progress_menu_main_routes.gd:292:	var menu = main.progress_menu
scripts/dev/progress_menu_main_routes.gd:372:	var sum: Label = main.progress_menu.get("_summary") if main.progress_menu and opened else null
scripts/dev/progress_menu_main_routes.gd:396:	var sum: Label = main.progress_menu.get("_summary") if main.progress_menu and opened else null
scripts/dev/progress_menu_main_routes.gd:413:	var menu = main.progress_menu
scripts/dev/progress_menu_main_routes.gd:445:	var menu = main.progress_menu
scripts/dev/progress_menu_main_routes.gd:532:	if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/progress_menu_main_routes.gd:533:		main.progress_menu.dismiss()
scripts/dev/progress_menu_selftest.gd:6:const OK_MARK := "PROGRESS_MENU_CEREMONY_OK"
scripts/dev/progress_menu_selftest.gd:7:const FAIL_MARK := "PROGRESS_MENU_CEREMONY_FAIL"
scripts/dev/progress_menu_selftest.gd:25:	var MenuScr = load("res://scripts/ui/progress_menu.gd")
scripts/dev/progress_menu_selftest.gd:26:	_failed = _assert("META.menu_script_loads", "progress_menu.gd loads", MenuScr != null, "") or _failed
scripts/dev/progress_menu_selftest.gd:284:		main_src.find("func _finalize_progress_menu_result") >= 0
scripts/dev/progress_menu_selftest.gd:285:		and main_src.find("_finalize_progress_menu_result(leave_result)") >= 0
scripts/dev/progress_menu_selftest.gd:286:		and main_src.find("_finalize_progress_menu_result(push_result, true)") >= 0
scripts/dev/progress_menu_selftest.gd:307:		FileAccess.get_file_as_string("res://scripts/ui/progress_menu.gd").find("pool_for_bucket") >= 0
scripts/dev/progress_menu_selftest.gd:308:		and FileAccess.get_file_as_string("res://scripts/ui/progress_menu.gd").find("BucketRules.of_card") >= 0,
scripts/dev/banking_contract_selftest.gd:369:		and road_body.find("_open_progress_menu(tut_kind") >= 0,
scripts/dev/banking_contract_selftest.gd:370:		"has_progress_menu=%s has_bank=%s" % [
scripts/dev/banking_contract_selftest.gd:371:			road_body.find("_open_progress_menu(tut_kind") >= 0,
scripts/dev/collection_a_notrun_cases.gd:40:		if main != null and main.get("progress_menu") != null and main.get("home_cabin") != null and main.get("_campaign") != null:
scripts/dev/collection_a_notrun_cases.gd:43:	if main == null or main.progress_menu == null or main.home_cabin == null or main._campaign == null or main.items_by_id.is_empty():
scripts/dev/collection_a_notrun_cases.gd:158:	print("ROSTER_FILTER source=progress_menu._pool_roster + harness._pool_ids status not in hold/retired")
scripts/dev/collection_a_notrun_cases.gd:180:	if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/collection_a_notrun_cases.gd:181:		main.progress_menu.dismiss()
scripts/dev/collection_a_notrun_cases.gd:270:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:325:		if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/collection_a_notrun_cases.gd:328:	var kind := str(main.progress_menu.get("_kind")) if opened else ""
scripts/dev/collection_a_notrun_cases.gd:329:	var sum := str(main.progress_menu.get("_summary").text) if opened and main.progress_menu.get("_summary") else ""
scripts/dev/collection_a_notrun_cases.gd:336:		main.progress_menu.dismiss()
scripts/dev/collection_a_notrun_cases.gd:348:	if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/collection_a_notrun_cases.gd:349:		later_kind = str(main.progress_menu.get("_kind"))
scripts/dev/collection_a_notrun_cases.gd:350:		main.progress_menu.dismiss()
scripts/dev/collection_a_notrun_cases.gd:361:		if main.progress_menu != null and main.progress_menu.visible and str(main.progress_menu.get("_kind")) == "tutorial":
scripts/dev/collection_a_notrun_cases.gd:364:	if helper_second and main.progress_menu != null and main.progress_menu.visible:
scripts/dev/collection_a_notrun_cases.gd:365:		main.progress_menu.dismiss()
scripts/dev/collection_a_notrun_cases.gd:407:	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
scripts/dev/collection_a_notrun_cases.gd:463:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:540:		if main.progress_menu != null and main.progress_menu.visible:
scripts/dev/collection_a_notrun_cases.gd:549:		var news: Array = main.progress_menu.get("_new_ids") if main.progress_menu.get("_new_ids") != null else []
scripts/dev/collection_a_notrun_cases.gd:551:		main.progress_menu.dismiss()
scripts/dev/collection_a_notrun_cases.gd:657:	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
scripts/dev/collection_a_notrun_cases.gd:710:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:766:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:888:	var menu_neg = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:939:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:974:	menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:987:	menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:1130:	var menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:1185:	menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:1204:	menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:1237:	menu = main.progress_menu
scripts/dev/collection_a_notrun_cases.gd:1311:	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
scripts/home_cabin.gd:871:	if has_meta("progress_menu_handled_return") and bool(get_meta("progress_menu_handled_return")):
scripts/home_cabin.gd:872:		set_meta("progress_menu_handled_return", false)
scripts/home_cabin.gd:882:	if has_meta("progress_menu_handled_return") and bool(get_meta("progress_menu_handled_return")):
scripts/home_cabin.gd:924:func open_cabin_after_progress_menu(
scripts/home_cabin.gd:1947:			has_meta("progress_menu_handled_return") and bool(get_meta("progress_menu_handled_return"))
scripts/dev/progress_menu_shots.gd:28:	var MenuScr = load("res://scripts/ui/progress_menu.gd")
scripts/dev/progress_menu_shots.gd:188:	print("SHOTS_OK progress_menu BEFORE/MID/AFTER+CATALOG source_sha=%s icons=%s" % [source_sha, tex.size()])
scripts/main.gd:47:const PROGRESS_MENU := preload("res://scripts/ui/progress_menu.gd")
scripts/main.gd:955:var progress_menu
scripts/main.gd:2091:	progress_menu = PROGRESS_MENU.new()
scripts/main.gd:2092:	add_child(progress_menu)
scripts/main.gd:3221:	var leave_result: Dictionary = await _open_progress_menu("win", news, ids, false, "", "", leave_milestones)
scripts/main.gd:3222:	await _finalize_progress_menu_result(leave_result)
scripts/main.gd:3277:	var push_result: Dictionary = await _open_progress_menu(
scripts/main.gd:3280:	await _finalize_progress_menu_result(push_result, true)
scripts/main.gd:3317:	var classic_result: Dictionary = await _open_progress_menu("win", news, ids, false)
scripts/main.gd:3318:	await _finalize_progress_menu_result(classic_result)
scripts/main.gd:3951:	var loss_result: Dictionary = await _open_progress_menu("loss", [], [], false)
scripts/main.gd:3952:	await _finalize_progress_menu_result(loss_result)
scripts/main.gd:4003:	var give_result: Dictionary = await _open_progress_menu("loss", [], [], false)
scripts/main.gd:4004:	await _finalize_progress_menu_result(give_result)
scripts/main.gd:4095:## Callers MUST finalize via _finalize_progress_menu_result so old return coroutines
scripts/main.gd:4097:func _open_progress_menu(
scripts/main.gd:4106:	if progress_menu == null:
scripts/main.gd:4161:	var result: Dictionary = await progress_menu.present(payload, ack)
scripts/main.gd:4163:		home_cabin.set_meta("progress_menu_handled_return", true)
scripts/main.gd:4169:func _finalize_progress_menu_result(result: Dictionary, pause_if_idle: bool = false) -> void:
scripts/main.gd:4188:		if home_cabin != null and home_cabin.has_method("open_cabin_after_progress_menu"):
scripts/main.gd:4194:			await home_cabin.open_cabin_after_progress_menu(
scripts/main.gd:31424:	var tut_result: Dictionary = await _open_progress_menu(tut_kind, [], [], false)
scripts/main.gd:31425:	await _finalize_progress_menu_result(tut_result)
```

## Journey A receipts / collection journey / quiet strip

```
tests/README.md:58:- `scripts/dev/collection_journey_selftest.gd` — Journey A seen/carried/banked projection (offer→seen, provisional distinct, 4+1 gate, milestones). Run: `./tools/qa/run_collection_journey.sh`
scripts/collection_journey.gd:1:class_name CollectionJourney
scripts/collection_journey.gd:3:## Journey A shared state projection — seen / carried / banked / provisional / gate.
scripts/collection_journey.gd:135:static func milestones_from_bank(
scripts/dev/collection_a_live_repot.gd:9:const JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/dev/collection_a_live_repot.gd:235:	main.call("_sync_collection_quiet")
scripts/dev/collection_a_live_repot.gd:255:	var strip = main.collection_quiet
scripts/dev/collection_a_live_repot.gd:441:	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, after, ["b1"], {"b1": 99})
scripts/ui/collection_quiet_strip.gd:2:## Journey A — quiet in-run banked / provisional summary (not a side ledger).
scripts/ui/collection_quiet_strip.gd:19:## `summary` from CollectionJourney.quiet_run_summary.
scripts/ui/progress_menu.gd:11:const JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/ui/progress_menu.gd:399:		## Match production banking roster (main milestones_from_bank) — hold/retired
scripts/ui/progress_menu.gd:673:	## Journey A: locked future cabinets reveal no item names/icons (no spoilers).
scripts/ui/progress_menu.gd:711:	## Anonymous locked slot — no catalog id, name, or art (Journey A spoiler ban).
scripts/ui/progress_menu.gd:846:## "seen" = recognized (offer/reveal) but not banked — Journey A catalogue contract.
scripts/ui/progress_menu.gd:1398:		## Journey A: Esc/Back restores the caller (dismiss without choosing Start/Cabin).
scripts/dev/collection_a_notrun_cases.gd:2:## Journey A honesty drain — isolated Godot, disposable APPDATA sandbox.
scripts/dev/collection_a_notrun_cases.gd:10:const JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/dev/collection_a_notrun_cases.gd:708:	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, main._campaign.state, ["b1"], roster)
scripts/dev/collection_a_notrun_cases.gd:755:	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, after, ["b1"], roster)
scripts/dev/collection_a_notrun_cases.gd:776:	var ms2: Array = JOURNEY.milestones_from_bank(main._campaign.rules, after, after, ["b1"], roster)
scripts/dev/collection_a_notrun_cases.gd:864:	var ms_early: Array = await main._campaign_bank_from_hand_with_milestones(true)
scripts/dev/collection_a_notrun_cases.gd:872:	var ms_push: Array = await main._campaign_bank_from_hand_with_milestones(false)
scripts/dev/collection_a_notrun_cases.gd:923:	var ms: Array = await main._campaign_bank_from_hand_with_milestones(true)
scripts/dev/collection_a_notrun_cases.gd:965:	var ms_once: Array = await main._campaign_bank_from_hand_with_milestones(true)
scripts/dev/collection_a_notrun_cases.gd:1112:	var ms_neg: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before_neg, after_neg, [], roster)
scripts/dev/collection_a_notrun_cases.gd:1143:	## Must NOT inject collection_complete; milestone must come from milestones_from_bank.
scripts/dev/collection_a_notrun_cases.gd:1152:	var ms_pos: Array = JOURNEY.milestones_from_bank(
scripts/dev/collection_a_notrun_cases.gd:1229:	var ms_rep: Array = JOURNEY.milestones_from_bank(
scripts/dev/collection_a_notrun_cases.gd:1305:	var ms_rep: Array = JOURNEY.milestones_from_bank(main._campaign.rules, state, main._campaign.state, [], roster)
tools/qa/run_collection_journey.sh:2:# Journey A collection state projection selftest — headless, no real save I/O.
tools/qa/run_collection_journey.sh:4:#   ./tools/qa/run_collection_journey.sh
tools/qa/run_collection_journey.sh:5:#   GODOT=/path/to/Godot_v4.7.2-stable_* ./tools/qa/run_collection_journey.sh
tools/qa/run_collection_journey.sh:41:"$GODOT_BIN" --headless --path "$ROOT" --script res://scripts/dev/collection_journey_selftest.gd >"$OUT" 2>&1
tools/qa/run_collection_journey.sh:44:echo "----- collection_journey_selftest.gd (exit $CODE) -----"
tools/qa/run_collection_journey.sh:47:if [[ -n "${COLLECTION_JOURNEY_LOG:-}" ]]; then
tools/qa/run_collection_journey.sh:48:  cp "$OUT" "$COLLECTION_JOURNEY_LOG"
tools/qa/run_collection_journey.sh:51:  echo "COLLECTION_JOURNEY failed (exit $CODE)" >&2
tools/qa/run_collection_journey.sh:54:if ! grep -q 'COLLECTION_JOURNEY_OK' "$OUT"; then
tools/qa/run_collection_journey.sh:55:  echo "COLLECTION_JOURNEY missing OK mark" >&2
tools/qa/run_collection_journey.sh:58:echo "COLLECTION_JOURNEY local run OK"
scripts/dev/collection_journey_selftest.gd:2:## Journey A — collection state projection selftest (no main.gd, no real save I/O).
scripts/dev/collection_journey_selftest.gd:3:## Run: ./tools/qa/run_collection_journey.sh
scripts/dev/collection_journey_selftest.gd:6:const OK_MARK := "COLLECTION_JOURNEY_OK"
scripts/dev/collection_journey_selftest.gd:7:const FAIL_MARK := "COLLECTION_JOURNEY_FAIL"
scripts/dev/collection_journey_selftest.gd:8:const JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/dev/collection_journey_selftest.gd:111:	var ms: Array = JOURNEY.milestones_from_bank(rules, before, state, ["b1"], {"b1": 5})
tools/qa/check_progress_menu.py:169:            or '_campaign_bank_from_hand_with_milestones(true)' in main_gd
tools/qa/check_progress_menu.py:174:            or '_campaign_bank_from_hand_with_milestones(false)' in main_gd
scripts/dev/collection_journey_milestones_selftest.gd:3:## Run: godot --headless --path . --script res://scripts/dev/collection_journey_milestones_selftest.gd
scripts/dev/collection_journey_milestones_selftest.gd:5:const JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/dev/collection_journey_milestones_selftest.gd:31:	var ms_g: Array = JOURNEY.milestones_from_bank(rules, before_g, after_g, ["b1"], {"b1": 14})
scripts/dev/collection_journey_milestones_selftest.gd:58:	var ms_n: Array = JOURNEY.milestones_from_bank(rules, before_n, after_n, [], roster)
scripts/dev/collection_journey_milestones_selftest.gd:71:	var ms_p: Array = JOURNEY.milestones_from_bank(rules, before_p, after_p, ["b4"], roster)
scripts/dev/collection_journey_milestones_selftest.gd:84:	var ms_id: Array = JOURNEY.milestones_from_bank(rules, after_p, after_p, ["b4"], roster)
scripts/dev/collection_journey_milestones_selftest.gd:134:	var ms_fc: Array = JOURNEY.milestones_from_bank(rules, SHELL.fresh_state(), fc_state, [], roster)
scripts/home_cabin.gd:923:## Journey A: optional cabin — focus hall/cabinet when unlocked; no S7 bank replay.
scripts/main.gd:43:const COLLECTION_JOURNEY := preload("res://scripts/collection_journey.gd")
scripts/main.gd:627:## Journey A quiet banked/provisional strip (not a persistent ledger).
scripts/main.gd:628:var collection_quiet
scripts/main.gd:1656:	collection_quiet = null
scripts/main.gd:3216:		leave_milestones = await _campaign_bank_from_hand_with_milestones(true)
scripts/main.gd:3261:		push_milestones = await _campaign_bank_from_hand_with_milestones(false)
scripts/main.gd:3804:	await _campaign_bank_from_hand_with_milestones(stamp_crosses)
scripts/main.gd:3807:## Same as `_campaign_bank_from_hand`, returning Journey A milestone facts for the receipt.
scripts/main.gd:3808:func _campaign_bank_from_hand_with_milestones(stamp_crosses: bool = true) -> Array:
scripts/main.gd:3854:	var milestones: Array = COLLECTION_JOURNEY.milestones_from_bank(
scripts/main.gd:4149:		## Permanent offer/reveal recognition — Journey A catalogue (seen ≠ banked).
scripts/main.gd:29505:	_sync_collection_quiet()
scripts/main.gd:29508:## Journey A — local New! / banked-repeat badge from shared projection (no new spend modal).
scripts/main.gd:29532:	var st: String = COLLECTION_JOURNEY.item_status(cid, seen_map, banked, held)
scripts/main.gd:29534:	var fresh: bool = st == COLLECTION_JOURNEY.STATUS_CARRIED
scripts/main.gd:29543:func _sync_collection_quiet() -> void:
```

## Banking + homecoming ceremony

```
scripts/dev/collection_a_live_repot.gd:135:	cabin.bank_pending = []
scripts/dev/collection_a_live_repot.gd:187:			main.home_cabin.call("_ack_bank_presented", id, -1)
scripts/dev/collection_a_live_repot.gd:550:	cabin.bank_pending = [held_new, seen_only]
scripts/dev/collection_a_live_repot.gd:554:	var added1: Dictionary = CAMPAIGN_SHELL.bank(
scripts/dev/collection_a_live_repot.gd:557:	var added2: Dictionary = CAMPAIGN_SHELL.bank(
scripts/dev/collection_a_live_repot.gd:568:	cabin._ack_bank_presented(held_new, -1)
scripts/dev/collection_a_live_repot.gd:569:	var pending_mid: Array = cabin.bank_pending.duplicate()
scripts/dev/collection_a_live_repot.gd:570:	cabin.bank_pending = ["phantom_repot"]
scripts/dev/collection_a_live_repot.gd:572:	var pending_after: Array = cabin.bank_pending.duplicate()
scripts/dev/collection_a_live_repot.gd:614:	cabin.bank_pending = []
scripts/dev/collection_a_live_repot.gd:632:	var pending: int = cabin.bank_pending.size()
scripts/dev/house_unlock_first_return_selftest.gd:215:		"open_hall_after_push_block credits haul for house unlock",
scripts/dev/house_unlock_first_return_selftest.gd:216:		_func_body_contains(src, "func open_hall_after_push_block", "_credit_homecoming_counters"),
scripts/dev/progress_menu_selftest.gd:93:	CAMPAIGN_SHELL.bank(rules, state, openers, pools)
scripts/dev/banking_contract_selftest.gd:364:		"STATIC: _road_finish_to_cabin body has no CampaignShell.bank / _campaign_bank_from_hand / swipe_ids; opens progress menu (tutorial zero credit)",
scripts/dev/banking_contract_selftest.gd:368:		and road_body.find("swipe_ids") < 0
tools/qa/check_cabinet_homecoming.py:82:    ok("cabin.bank_pending_var", "var bank_pending: Array" in cabin)
tools/qa/check_cabinet_homecoming.py:83:    ok("cabin.save_writes_pending", 'data["bank_pending"]' in cabin)
tools/qa/check_cabinet_homecoming.py:84:    ok("cabin.read_default_empty", 'parsed.get("bank_pending", [])' in cabin)
tools/qa/check_cabinet_homecoming.py:85:    ok("cabin.ack_helper", "func _ack_bank_presented" in cabin)
tools/qa/check_cabinet_homecoming.py:86:    ok("cabin.restore_helper", "func _restore_bank_hold_from_pending" in cabin)
tools/qa/check_cabinet_homecoming.py:94:    ok("cabin.clear_anim_keeps_pending", "bank_pending stays on disk" in cabin or "intentionally NOT cleared" in cabin or "Session FX flags only" in cabin)
tools/qa/check_cabinet_homecoming.py:97:    ok("cabin.stage_homecoming", "func _stage_homecoming_bank" in cabin)
tools/qa/check_cabinet_homecoming.py:119:    ok("cabin.push_block_flag", "begin_push_block_bank" in cabin and "_bank_from_push_block" in cabin)
tools/qa/check_cabinet_homecoming.py:120:    ok("cabin.push_mounts_after_dialog", "open_hall_after_push_block" in cabin and "await _play_bank_sequence" in cabin)
tools/qa/check_cabinet_homecoming.py:124:    ok("cabin.begin_bank_ceremony", "func _begin_bank_ceremony" in cabin)
tools/qa/check_cabinet_homecoming.py:143:        "func _ack_bank_presented(step_id: String, ceremony_gen: int = -1)" in cabin,
tools/qa/check_cabinet_homecoming.py:259:    ok("main.no_campaign_bank_on_tutorial_road", "swipe_ids" not in (road.group(0) if road else ""))
scripts/dev/cabin_nav_lock_probe.gd:1083:	cabin.open_hall_after_push_block("b1", "Verdant Hollow", [], ["boot", "net"])
scripts/campaign_shell.gd:441:static func bank(rules: Dictionary, state: Dictionary, ids: Array, pools_by_id: Dictionary) -> Dictionary:
scripts/dev/collection_a_notrun_cases.gd:703:	var bank_res: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, main._campaign.state, [late], pools)
scripts/dev/collection_a_notrun_cases.gd:747:	var bank_res: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, after, [last_id], {last_id: "b1"})
scripts/dev/collection_a_notrun_cases.gd:1149:	var bank_pos: Dictionary = CAMPAIGN_SHELL.bank(
scripts/dev/collection_a_notrun_cases.gd:1303:	var added: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, main._campaign.state, ["net"], {"net": "b1"})
scripts/dev/collection_journey_selftest.gd:94:	var bank_result: Dictionary = CAMPAIGN_SHELL.bank(rules, state, ["throwing_knife"], pools)
scripts/dev/homecoming_live_repot.gd:195:	cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:200:	var mounted: bool = cabin.bank_pending.is_empty() and _banked_has(cabin, id)
scripts/dev/homecoming_live_repot.gd:201:	_verdict("H5b", finished and mounted and not bad and pool != "b1", "pool=%s pending=%s banked=%s verdant_line=%s" % [pool, cabin.bank_pending, _banked_has(cabin, id), bad])
scripts/dev/homecoming_live_repot.gd:219:	cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:239:	_verdict("H3", finished and give and cabin.bank_pending.is_empty(), "give=%s pending=%s" % [give, cabin.bank_pending])
scripts/dev/homecoming_live_repot.gd:246:	var before: int = cabin.bank_pending.size()
scripts/dev/homecoming_live_repot.gd:247:	var news: Array = cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:250:	_verdict("H6", news.is_empty() and before == 0 and cabin.bank_pending.is_empty() and not flew, "news=%s pending=%s busy=%s" % [news, cabin.bank_pending, cabin._bank_busy])
scripts/dev/homecoming_live_repot.gd:260:	cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:284:	var pending_at_cancel: Array = cabin.bank_pending.duplicate()
scripts/dev/homecoming_live_repot.gd:290:	var pending_later: Array = cabin.bank_pending.duplicate()
scripts/dev/homecoming_live_repot.gd:293:	late = late or str(cabin.bank_pending) != str(pending_at_cancel)
scripts/dev/homecoming_live_repot.gd:294:	_log("H11 %s pending_at=%s pending_later=%s fx=%s late=%s" % [phase, pending_at_cancel, cabin.bank_pending, fx_after, late])
scripts/dev/homecoming_live_repot.gd:296:	if not cabin.bank_pending.is_empty():
scripts/dev/homecoming_live_repot.gd:297:		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
scripts/dev/homecoming_live_repot.gd:300:	var once: bool = credited_before and _banked_has(cabin, id) and cabin.bank_pending.is_empty()
scripts/dev/homecoming_live_repot.gd:301:	_verdict("H11-" + phase, reached and fx_after == 0 and not late and not busy_after and pan_ok and once, "reached=%s fx=%s late=%s busy=%s pan=%s pending=%s" % [reached, fx_after,
scripts/dev/homecoming_live_repot.gd:311:	cabin.swipe_ids([ids[4]])
scripts/dev/homecoming_live_repot.gd:328:	if not cabin.bank_pending.is_empty():
scripts/dev/homecoming_live_repot.gd:329:		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
scripts/dev/homecoming_live_repot.gd:335:	_verdict("H11-cabinet", reached and fx_after == 0 and pieces_mid == pieces_before and not cabin._busy() and not dup, "lamp=%s fx=%s pieces=%s->%s pending=%s" % [reached, fx_after
scripts/dev/homecoming_live_repot.gd:347:	cabin.swipe_ids([b1[4]])
scripts/dev/homecoming_live_repot.gd:358:	var pending_before: Array = cabin.bank_pending.duplicate()
scripts/dev/homecoming_live_repot.gd:361:	cabin.play_homecoming("loss", [], [])
scripts/dev/homecoming_live_repot.gd:371:	var grew: bool = cabin.bank_pending.size() != pending_before.size() or (cabin._campaign_shell.state.get("banked", {}) as Dictionary).size() != banked_before
scripts/dev/homecoming_live_repot.gd:372:	_verdict("H7", settled and not grew and not cabin._bank_busy and not _heard_has("Let's give these a home."), "settled=%s pending=%s busy=%s" % [settled, cabin.bank_pending, cabin
scripts/dev/homecoming_live_repot.gd:385:	cabin.play_homecoming("win", [], [])
scripts/dev/homecoming_live_repot.gd:391:	_verdict("H8", line and banked_after == banked_before and cabin.bank_pending.is_empty() and cabin.lesson_tutorial_return_said, "line=%s banked %s->%s pending=%s" % [line, banked_
scripts/dev/homecoming_live_repot.gd:400:	cabin.swipe_ids([done_id])
scripts/dev/homecoming_live_repot.gd:403:	cabin.swipe_ids([stay_id])
scripts/dev/homecoming_live_repot.gd:412:	cabin.bank_pending = []
scripts/dev/homecoming_live_repot.gd:415:	var resumed: bool = cabin.bank_pending.has(stay_id) and not cabin.bank_pending.has(done_id)
scripts/dev/homecoming_live_repot.gd:418:	if not cabin.bank_pending.is_empty():
scripts/dev/homecoming_live_repot.gd:420:		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
scripts/dev/homecoming_live_repot.gd:421:	var replay: bool = cabin.bank_pending.has(done_id)
scripts/dev/homecoming_live_repot.gd:423:	_verdict("H9", saw and resumed and banked_once and not replay and disk_pending.has(stay_id), "disk=%s memory=%s replay=%s" % [disk_pending, cabin.bank_pending, replay])
scripts/dev/homecoming_live_repot.gd:431:	cabin.begin_push_block_bank()
scripts/dev/homecoming_live_repot.gd:433:	cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:435:	cabin.open_hall_after_push_block("b1", "Verdant Hollow", [id], [])
scripts/dev/homecoming_live_repot.gd:436:	await _wait_flag(func() -> bool: return _dialog_open(cabin) or cabin.bank_pending.is_empty(), 8.0)
scripts/dev/homecoming_live_repot.gd:439:	await _wait_flag(func() -> bool: return not cabin._bank_busy and cabin.bank_pending.is_empty(), 12.0)
scripts/dev/homecoming_live_repot.gd:442:	_verdict("H10", _banked_has(cabin, id) and not give and not thresh and _map_pieces(cabin) == pieces_before, "give=%s thresh=%s pieces=%s pending=%s" % [give, thresh, _map_pieces(
scripts/dev/homecoming_live_repot.gd:443:	cabin._bank_from_push_block = false
scripts/dev/homecoming_live_repot.gd:462:	cabin.swipe_ids([id])
scripts/dev/homecoming_live_repot.gd:486:		return stage_done and cabin.bank_pending.is_empty() and not cabin._bank_busy and not cabin._homecoming_bank_staging
scripts/dev/homecoming_live_repot.gd:489:		_log("STAGE TIMEOUT pending=%s busy=%s staging=%s room=%s done=%s" % [cabin.bank_pending, cabin._bank_busy, cabin._homecoming_bank_staging, cabin._current_room, stage_done])
scripts/dev/homecoming_live_repot.gd:606:	cabin._bank_from_push_block = false
scripts/dev/homecoming_live_repot.gd:634:	cabin.bank_pending = []
scripts/dev/homecoming_live_repot.gd:635:	cabin._bank_hold = {}
scripts/dev/homecoming_live_repot.gd:638:	cabin._bank_from_push_block = false
scripts/dev/homecoming_live_repot.gd:650:	cabin.bank_pending = []
scripts/dev/homecoming_live_repot.gd:651:	cabin._bank_hold = {}
scripts/dev/homecoming_live_repot.gd:653:	cabin.bank_pending = []
scripts/dev/homecoming_live_repot.gd:654:	cabin._bank_hold = {}
scripts/dev/homecoming_live_repot.gd:738:	var pending: Variant = (parsed as Dictionary).get("bank_pending", [])
scripts/dev/homecoming_ceremony_selftest.gd:63:	var gen_a: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:66:		"_begin_bank_ceremony marks busy and returns gen",
scripts/dev/homecoming_ceremony_selftest.gd:79:	var gen_b: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:80:	cabin.set("bank_pending", ["net"])
scripts/dev/homecoming_ceremony_selftest.gd:82:	cabin.set("_bank_hold", {"net": true})
scripts/dev/homecoming_ceremony_selftest.gd:83:	cabin.call("_ack_bank_presented", "net", gen_a)
scripts/dev/homecoming_ceremony_selftest.gd:86:		"stale ceremony cannot ack bank_pending",
scripts/dev/homecoming_ceremony_selftest.gd:87:		(cabin.get("bank_pending") as Array).has("net"),
scripts/dev/homecoming_ceremony_selftest.gd:88:		"pending=%s" % str(cabin.get("bank_pending"))
scripts/dev/homecoming_ceremony_selftest.gd:92:	cabin.call("_ack_bank_presented", "net", gen_b)
scripts/dev/homecoming_ceremony_selftest.gd:96:		not (cabin.get("bank_pending") as Array).has("net"),
scripts/dev/homecoming_ceremony_selftest.gd:97:		"pending=%s" % str(cabin.get("bank_pending"))
scripts/dev/homecoming_ceremony_selftest.gd:123:	var gen_t: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:140:	var gen_await: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:159:	cabin.set("bank_pending", ["net"])
scripts/dev/homecoming_ceremony_selftest.gd:160:	cabin.set("_bank_hold", {"net": true})
scripts/dev/homecoming_ceremony_selftest.gd:162:	var gen_sync: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:171:		sync_mid["pending_before"] = (cabin.get("bank_pending") as Array).duplicate()
scripts/dev/homecoming_ceremony_selftest.gd:172:		cabin.call("_ack_bank_presented", "net", gen_sync)
scripts/dev/homecoming_ceremony_selftest.gd:173:		sync_mid["pending_after_ack"] = (cabin.get("bank_pending") as Array).duplicate()
scripts/dev/homecoming_ceremony_selftest.gd:182:		cabin.call("_ack_bank_presented", "net", gen_sync)
scripts/dev/homecoming_ceremony_selftest.gd:183:		sync_late_ack_kept[0] = (cabin.get("bank_pending") as Array).has("net")
scripts/dev/homecoming_ceremony_selftest.gd:201:		"inside abort callback: stale ack leaves bank_pending unchanged",
scripts/dev/homecoming_ceremony_selftest.gd:216:		bool(sync_late_ack_kept[0]) and (cabin.get("bank_pending") as Array).has("net"),
scripts/dev/homecoming_ceremony_selftest.gd:217:		"kept=%s pending=%s" % [sync_late_ack_kept[0], cabin.get("bank_pending")]
scripts/dev/homecoming_ceremony_selftest.gd:221:	var gen_gate: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:239:	var gen_c: int = cabin.call("_begin_bank_ceremony")
scripts/dev/homecoming_ceremony_selftest.gd:379:	var gen: int = cabin.call("_begin_bank_ceremony")
scripts/home_cabin.gd:86:var bank_pending: Array = []
scripts/home_cabin.gd:179:var _bank_hold: Dictionary = {}
scripts/home_cabin.gd:182:var _bank_from_push_block: bool = false
scripts/home_cabin.gd:348:	if _bank_hold.has(sid):
scripts/home_cabin.gd:358:func swipe_ids(ids: Array) -> Array:
scripts/home_cabin.gd:372:			_bank_hold[sid] = true
scripts/home_cabin.gd:374:			if not bank_pending.has(sid):
scripts/home_cabin.gd:375:				bank_pending.append(sid)
scripts/home_cabin.gd:390:func _ack_bank_presented(step_id: String, ceremony_gen: int = -1) -> void:
scripts/home_cabin.gd:396:	_bank_hold.erase(sid)
scripts/home_cabin.gd:397:	var idx := bank_pending.find(sid)
scripts/home_cabin.gd:399:		bank_pending.remove_at(idx)
scripts/home_cabin.gd:403:func _begin_bank_ceremony() -> int:
scripts/home_cabin.gd:587:func _restore_bank_hold_from_pending() -> void:
scripts/home_cabin.gd:588:	_bank_hold.clear()
scripts/home_cabin.gd:590:	for raw in bank_pending:
scripts/home_cabin.gd:597:		_bank_hold[sid] = true
scripts/home_cabin.gd:599:	if kept.size() != bank_pending.size():
scripts/home_cabin.gd:600:		bank_pending = kept
scripts/home_cabin.gd:602:	if not _bank_hold.is_empty():
scripts/home_cabin.gd:873:	elif not bank_pending.is_empty() and is_room_unlocked("hall") and not _bank_from_push_block:
scripts/home_cabin.gd:880:	if _bank_from_push_block:
scripts/home_cabin.gd:886:	if bank_pending.is_empty():
scripts/home_cabin.gd:888:	_stage_homecoming_bank()
scripts/home_cabin.gd:908:func play_homecoming(kind: String, new_ids: Array, held_ids: Array) -> void:
scripts/home_cabin.gd:915:## Call before swipe_ids on the Push-block path so a deferred bank cannot stamp a piece.
scripts/home_cabin.gd:916:func begin_push_block_bank() -> void:
scripts/home_cabin.gd:917:	_bank_from_push_block = true
scripts/home_cabin.gd:922:## Mirrors open_hall_after_push_block credit order: credit → optional key ring → show_menu.
scripts/home_cabin.gd:964:## No map piece on this path (S3 ceremony suppressed via _bank_from_push_block).
scripts/home_cabin.gd:965:func open_hall_after_push_block(pool_id: String, biome_name: String, new_ids: Array = [], held_ids: Array = []) -> void:
scripts/home_cabin.gd:966:	_bank_from_push_block = true
scripts/home_cabin.gd:991:	_restore_bank_hold_from_pending()
scripts/home_cabin.gd:992:	if not _bank_hold.is_empty() and _current_room == "hall" and not _bank_busy:
scripts/home_cabin.gd:993:		var push_gen: int = _begin_bank_ceremony()
scripts/home_cabin.gd:994:		await _play_bank_sequence(push_gen)
scripts/home_cabin.gd:1272:	if gen == _key_ring_gen and visible and not bank_pending.is_empty():
scripts/home_cabin.gd:1273:		await _stage_homecoming_bank()
scripts/home_cabin.gd:1946:		if not bank_pending.is_empty() and not (
scripts/home_cabin.gd:1949:			await _stage_homecoming_bank()
scripts/home_cabin.gd:2600:		for raw in _bank_hold.keys():
scripts/home_cabin.gd:2611:		if bool(swiped.get(sid, false)) and not _bank_hold.has(sid):
scripts/home_cabin.gd:2703:				if not _bank_hold.has(str(id)):
scripts/home_cabin.gd:2706:		if bool(swiped[id]) and not _bank_hold.has(str(id)):
scripts/home_cabin.gd:2718:	for id in _bank_hold.keys():
scripts/home_cabin.gd:3398:	if _bank_busy or _bank_hold.is_empty():
scripts/home_cabin.gd:3407:	var offer_gen: int = _begin_bank_ceremony()
scripts/home_cabin.gd:3408:	_play_bank_sequence(offer_gen)
scripts/home_cabin.gd:3413:	await _stage_homecoming_bank()
scripts/home_cabin.gd:3416:func _stage_homecoming_bank() -> void:
scripts/home_cabin.gd:3417:	_restore_bank_hold_from_pending()
scripts/home_cabin.gd:3418:	if _bank_hold.is_empty() or _bank_busy:
scripts/home_cabin.gd:3430:	for raw in bank_pending:
scripts/home_cabin.gd:3450:	if _bank_hold.is_empty() or _current_room != "hall":
scripts/home_cabin.gd:3457:	var stage_gen: int = _begin_bank_ceremony()
scripts/home_cabin.gd:3459:	await _play_bank_sequence(stage_gen)
scripts/home_cabin.gd:3473:func _play_bank_sequence(ceremony_gen: int = -1) -> void:
scripts/home_cabin.gd:3477:		ceremony_gen = _begin_bank_ceremony()
scripts/home_cabin.gd:3481:	for raw in _bank_hold.keys():
scripts/home_cabin.gd:3487:	var from_push_block := _bank_from_push_block
scripts/home_cabin.gd:3528:		_ack_bank_presented(step_id, ceremony_gen)
scripts/home_cabin.gd:3546:	_bank_from_push_block = false
scripts/home_cabin.gd:3608:	if "_bank_from_push_block" in self:
scripts/home_cabin.gd:3609:		return bool(get("_bank_from_push_block"))
scripts/home_cabin.gd:3940:	## Session FX flags only. bank_pending stays on disk until acknowledged.
scripts/home_cabin.gd:3941:	_bank_hold.clear()
scripts/home_cabin.gd:3944:	_bank_from_push_block = false
scripts/home_cabin.gd:3990:	var is_seen: bool = (bool(seen.get(id, false)) or is_swiped or _bank_hold.has(id) or (_campaign_shell != null and (_campaign_shell.state.get("banked", {}) as Dictionary).has(id))) and not room
scripts/home_cabin.gd:3994:	elif is_swiped and _bank_fresh == "" and _bank_hold.is_empty() and not _bank_played and _just_mounted.has(id):
scripts/home_cabin.gd:4364:	bank_pending = []
scripts/home_cabin.gd:4446:	bank_pending = []
scripts/home_cabin.gd:4447:	for raw_bp in parsed.get("bank_pending", []):
scripts/home_cabin.gd:4449:		if bpid != "" and not bank_pending.has(bpid):
scripts/home_cabin.gd:4450:			bank_pending.append(bpid)
scripts/home_cabin.gd:4456:	_restore_bank_hold_from_pending()
scripts/home_cabin.gd:4496:	data["bank_pending"] = bank_pending.duplicate()
scripts/home_cabin.gd:5634:## rooms_unlocked, hauls, bank ledger, bank_pending, or dialog content.
scripts/home_cabin.gd:5641:	## bank_pending / swiped / banked ledgers are preserved.
scripts/main.gd:3203:		news = home_cabin.swipe_ids(ids)
scripts/main.gd:3244:		# Flag before swipe_ids — deferred bank can run during the dissolve.
scripts/main.gd:3245:		if home_cabin.has_method("begin_push_block_bank"):
scripts/main.gd:3246:			home_cabin.begin_push_block_bank()
scripts/main.gd:3247:		news = home_cabin.swipe_ids(ids)
scripts/main.gd:3314:		news = home_cabin.swipe_ids(ids)
scripts/main.gd:3823:	var result: Dictionary = CAMPAIGN_SHELL.bank(_campaign.rules, _campaign.state, ids, pools)
scripts/main.gd:4159:		if home_cabin != null and home_cabin.has_method("_ack_bank_presented"):
scripts/main.gd:4160:			home_cabin.call("_ack_bank_presented", id, -1)
```

## Gates (campaign shell)

```
data/campaign.json:4:  "cabinet_quota": 5,
scripts/campaign_map.gd:86:## Fresh-start launch affordance on the held plate (can_start / Endless).
scripts/dev/collection_a_live_repot.gd:341:	var cabinet_n: int = int(CAMPAIGN_SHELL.cabinet_count(main._campaign.state, "b1"))
scripts/dev/collection_a_live_repot.gd:363:	print("ROSTER_BIND b1 cabinet=%s roster_total=%s (source=progress_menu._pool_roster + CAMPAIGN_SHELL.cabinet_count)" % [cabinet_n, roster_total])
scripts/dev/collection_a_live_repot.gd:399:		if pid != "" and not CAMPAIGN_SHELL.pool_unlocked(rules, state, pid):
scripts/dev/progress_menu_main_routes.gd:230:	main._campaign.state["map_pieces"] = []
scripts/dev/progress_menu_main_routes.gd:231:	main._campaign.state["pencil_fresh"] = []
scripts/dev/progress_menu_main_routes.gd:245:	var pieces_mid: int = (main._campaign.state.get("map_pieces", []) as Array).size()
scripts/dev/progress_menu_main_routes.gd:248:		"Push path left map_pieces empty (bank handler stamp_crosses=false)",
scripts/dev/progress_menu_main_routes.gd:258:	var b1n: int = CAMPAIGN_SHELL.cabinet_count(main._campaign.state, "b1")
scripts/dev/progress_menu_main_routes.gd:262:	var pieces_after: int = (main._campaign.state.get("map_pieces", []) as Array).size()
scripts/dev/progress_menu_main_routes.gd:263:	var fresh: Array = main._campaign.state.get("pencil_fresh", [])
scripts/dev/progress_menu_main_routes.gd:267:		pieces_after >= 1 and (main._campaign.state.get("map_pieces", []) as Array).has("b2"),
scripts/dev/progress_menu_main_routes.gd:268:		"pieces=%s fresh=%s" % [main._campaign.state.get("map_pieces", []), fresh]
scripts/dev/progress_menu_main_routes.gd:271:	CAMPAIGN_SHELL.clear_pencil_fresh(main._campaign.state)
scripts/dev/progress_menu_main_routes.gd:276:		(main._campaign.state.get("pencil_fresh", []) as Array).is_empty(),
scripts/dev/progress_menu_main_routes.gd:277:		str(main._campaign.state.get("pencil_fresh", []))
scripts/dev/progress_menu_selftest.gd:96:		"after push-like bank, b1 at quota but map_pieces empty",
scripts/dev/progress_menu_selftest.gd:97:		CAMPAIGN_SHELL.cabinet_count(state, "b1") >= 5
scripts/dev/progress_menu_selftest.gd:98:		and (state.get("map_pieces", []) as Array).is_empty(),
scripts/dev/progress_menu_selftest.gd:99:		"b1=%s pieces=%s" % [CAMPAIGN_SHELL.cabinet_count(state, "b1"), state.get("map_pieces", [])]
scripts/dev/progress_menu_selftest.gd:102:	var stamped: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
scripts/dev/progress_menu_selftest.gd:106:		bool(stamped.get("first", false)) and (state.get("map_pieces", []) as Array).has("b2"),
scripts/dev/progress_menu_selftest.gd:107:		"stamp=%s pieces=%s" % [stamped, state.get("map_pieces", [])]
scripts/dev/progress_menu_selftest.gd:109:	var stamped2: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
scripts/dev/progress_menu_selftest.gd:113:		(not bool(stamped2.get("first", true))) and (state.get("map_pieces", []) as Array).size() == 1,
scripts/dev/progress_menu_selftest.gd:114:		"stamp2=%s pieces=%s" % [stamped2, state.get("map_pieces", [])]
scripts/dev/progress_menu_selftest.gd:116:	CAMPAIGN_SHELL.clear_pencil_fresh(state)
scripts/dev/progress_menu_selftest.gd:117:	var stamped3: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
scripts/dev/progress_menu_selftest.gd:121:		(state.get("pencil_fresh", []) as Array).is_empty() and not bool(stamped3.get("first", true)),
scripts/dev/progress_menu_selftest.gd:122:		"fresh=%s stamp3=%s" % [state.get("pencil_fresh", []), stamped3]
scripts/dev/progress_menu_selftest.gd:295:		and main_src.find("cabinet_count(_campaign.state, pool_id) >= quota") >= 0,
scripts/ui/progress_menu.gd:428:	var q: int = CAMPAIGN_SHELL.quota_of(_rules)
scripts/ui/progress_menu.gd:575:			unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, pid)
scripts/ui/progress_menu.gd:614:			unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, pid)
scripts/ui/progress_menu.gd:647:		unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, _area_filter)
scripts/ui/progress_menu.gd:676:		area_unlocked = CAMPAIGN_SHELL.pool_unlocked(_rules, _state, _area_filter)
scripts/ui/progress_menu.gd:978:	var q: int = CAMPAIGN_SHELL.quota_of(_rules)
scripts/ui/progress_menu.gd:980:		if CAMPAIGN_SHELL.biome_unlocked(_rules, _state, i):
scripts/ui/progress_menu.gd:990:			"count": CAMPAIGN_SHELL.cabinet_count(_state, area_id),
scripts/ui/progress_menu.gd:1035:		if not CAMPAIGN_SHELL.can_start(_rules, _state, dest_i):
scripts/ui/progress_menu.gd:1038:				if CAMPAIGN_SHELL.can_start(_rules, _state, si):
scripts/ui/progress_menu.gd:1087:		if CAMPAIGN_SHELL.biome_unlocked(_rules, _state, i):
scripts/ui/progress_menu.gd:1110:		if not CAMPAIGN_SHELL.can_start(_rules, _state, i):
scripts/ui/progress_menu.gd:1111:			if (not showed_req) and i > 0 and not CAMPAIGN_SHELL.shortcut_open(_rules, _state, i):
scripts/dev/banking_contract_selftest.gd:72:		"cabinet_quota == 5",
scripts/dev/banking_contract_selftest.gd:73:		Shell.quota_of(rules) == 5,
scripts/dev/banking_contract_selftest.gd:74:		"quota=%s" % Shell.quota_of(rules)
scripts/dev/banking_contract_selftest.gd:84:		and Shell.cabinet_count(s0, "b1") == 0
scripts/dev/banking_contract_selftest.gd:85:		and not Shell.biome_unlocked(rules, s0, 1),
scripts/dev/banking_contract_selftest.gd:86:		"added=%s b1=%s can_start1=%s" % [
scripts/dev/banking_contract_selftest.gd:87:			r0.get("added", []), Shell.cabinet_count(s0, "b1"), Shell.can_start(rules, s0, 1)
scripts/dev/banking_contract_selftest.gd:97:		and Shell.cabinet_count(s1, "b1") == 1
scripts/dev/banking_contract_selftest.gd:98:		and not Shell.biome_unlocked(rules, s1, 1),
scripts/dev/banking_contract_selftest.gd:99:		"added=%s b1=%s" % [r1.get("added", []), Shell.cabinet_count(s1, "b1")]
scripts/dev/banking_contract_selftest.gd:108:		and Shell.cabinet_count(s2, "b1") == 2
scripts/dev/banking_contract_selftest.gd:109:		and not Shell.biome_unlocked(rules, s2, 1),
scripts/dev/banking_contract_selftest.gd:110:		"added=%s b1=%s" % [r2.get("added", []), Shell.cabinet_count(s2, "b1")]
scripts/dev/banking_contract_selftest.gd:120:		and Shell.cabinet_count(s6, "b1") == 6
scripts/dev/banking_contract_selftest.gd:121:		and Shell.biome_unlocked(rules, s6, 1)
scripts/dev/banking_contract_selftest.gd:122:		and not Shell.can_start(rules, s6, 1)
scripts/dev/banking_contract_selftest.gd:123:		and Shell.can_start(rules, s6, 0)
scripts/dev/banking_contract_selftest.gd:124:		and not Shell.cabinets_complete(rules, s6),
scripts/dev/banking_contract_selftest.gd:125:		"added_n=%s b1=%s dest1=%s can_start1=%s complete_all=%s" % [
scripts/dev/banking_contract_selftest.gd:127:			Shell.cabinet_count(s6, "b1"),
scripts/dev/banking_contract_selftest.gd:128:			Shell.biome_unlocked(rules, s6, 1),
scripts/dev/banking_contract_selftest.gd:129:			Shell.can_start(rules, s6, 1),
scripts/dev/banking_contract_selftest.gd:130:			Shell.cabinets_complete(rules, s6),
scripts/dev/banking_contract_selftest.gd:148:		and Shell.cabinet_count(s4, "b1") == 1
scripts/dev/banking_contract_selftest.gd:168:		and Shell.cabinet_count(s5, "b1") == 1,
scripts/dev/banking_contract_selftest.gd:170:			r5a.get("added", []), r5b.get("added", []), Shell.cabinet_count(s5, "b1")
scripts/dev/banking_contract_selftest.gd:181:		and Shell.cabinet_count(s_sb, "b1") == 2
scripts/dev/banking_contract_selftest.gd:184:		"added=%s b1=%s" % [r_sb.get("added", []), Shell.cabinet_count(s_sb, "b1")]
scripts/dev/banking_contract_selftest.gd:198:		Shell.cabinet_count(su1, "b1") == 4 and not Shell.biome_unlocked(rules, su1, 1),
scripts/dev/banking_contract_selftest.gd:199:		"b1=%s unlock1=%s" % [Shell.cabinet_count(su1, "b1"), Shell.biome_unlocked(rules, su1, 1)]
scripts/dev/banking_contract_selftest.gd:206:		and Shell.cabinet_count(su1, "b1") == 5
scripts/dev/banking_contract_selftest.gd:207:		and Shell.biome_unlocked(rules, su1, 1)
scripts/dev/banking_contract_selftest.gd:208:		and not Shell.can_start(rules, su1, 1)
scripts/dev/banking_contract_selftest.gd:209:		and Shell.can_start(rules, su1, 0)
scripts/dev/banking_contract_selftest.gd:210:		and not Shell.cabinets_complete(rules, su1),
scripts/dev/banking_contract_selftest.gd:211:		"b1=%s dest1=%s can_start1=%s complete=%s" % [
scripts/dev/banking_contract_selftest.gd:212:			Shell.cabinet_count(su1, "b1"),
scripts/dev/banking_contract_selftest.gd:213:			Shell.biome_unlocked(rules, su1, 1),
scripts/dev/banking_contract_selftest.gd:214:			Shell.can_start(rules, su1, 1),
scripts/dev/banking_contract_selftest.gd:215:			Shell.cabinets_complete(rules, su1),
scripts/dev/banking_contract_selftest.gd:224:		Shell.cabinet_count(su2a, "b1") == 5
scripts/dev/banking_contract_selftest.gd:225:		and Shell.biome_unlocked(rules, su2a, 1)
scripts/dev/banking_contract_selftest.gd:226:		and not Shell.can_start(rules, su2a, 1)
scripts/dev/banking_contract_selftest.gd:227:		and Shell.can_start(rules, su2a, 0),
scripts/dev/banking_contract_selftest.gd:228:		"b1=%s dest1=%s can_start1=%s" % [
scripts/dev/banking_contract_selftest.gd:229:			Shell.cabinet_count(su2a, "b1"),
scripts/dev/banking_contract_selftest.gd:230:			Shell.biome_unlocked(rules, su2a, 1),
scripts/dev/banking_contract_selftest.gd:231:			Shell.can_start(rules, su2a, 1),
scripts/dev/banking_contract_selftest.gd:239:		Shell.cabinet_count(su2b, "b1") == 6
scripts/dev/banking_contract_selftest.gd:240:		and Shell.biome_unlocked(rules, su2b, 1)
scripts/dev/banking_contract_selftest.gd:241:		and not Shell.can_start(rules, su2b, 1)
scripts/dev/banking_contract_selftest.gd:242:		and Shell.can_start(rules, su2b, 0),
scripts/dev/banking_contract_selftest.gd:243:		"b1=%s dest1=%s can_start1=%s" % [
scripts/dev/banking_contract_selftest.gd:244:			Shell.cabinet_count(su2b, "b1"),
scripts/dev/banking_contract_selftest.gd:245:			Shell.biome_unlocked(rules, su2b, 1),
scripts/dev/banking_contract_selftest.gd:246:			Shell.can_start(rules, su2b, 1),
scripts/dev/banking_contract_selftest.gd:252:	var stamp1: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
scripts/dev/banking_contract_selftest.gd:262:	var stamp2: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
scripts/dev/banking_contract_selftest.gd:268:		and Shell.cabinet_count(su3, "b1") == 6
scripts/dev/banking_contract_selftest.gd:269:		and Shell.biome_unlocked(rules, su3, 1)
scripts/dev/banking_contract_selftest.gd:270:		and not Shell.can_start(rules, su3, 1)
scripts/dev/banking_contract_selftest.gd:271:		and Shell.can_start(rules, su3, 0)
scripts/dev/banking_contract_selftest.gd:274:		"dup=%s new=%s b1=%s dest1=%s can_start1=%s stamp2_first=%s pieces=%s" % [
scripts/dev/banking_contract_selftest.gd:277:			Shell.cabinet_count(su3, "b1"),
scripts/dev/banking_contract_selftest.gd:278:			Shell.biome_unlocked(rules, su3, 1),
scripts/dev/banking_contract_selftest.gd:279:			Shell.can_start(rules, su3, 1),
scripts/dev/banking_contract_selftest.gd:288:	Shell.stamp_map_piece(rules, sp, "b1")
scripts/dev/banking_contract_selftest.gd:303:		Shell.cabinet_count(shell_load.state, "b1") == 5
scripts/dev/banking_contract_selftest.gd:307:			Shell.cabinet_count(shell_load.state, "b1"),
scripts/dev/banking_contract_selftest.gd:313:	var stamp_again: Dictionary = Shell.stamp_map_piece(rules, shell_load.state, "b1")
scripts/dev/banking_contract_selftest.gd:320:		and Shell.cabinet_count(shell_load.state, "b1") == 5,
scripts/dev/banking_contract_selftest.gd:325:			Shell.cabinet_count(shell_load.state, "b1"),
scripts/dev/banking_contract_selftest.gd:342:		and Shell.cabinet_count(sl, "b1") == 5
scripts/dev/banking_contract_selftest.gd:343:		and Shell.cabinet_count(sl, "b2") == 1
scripts/dev/banking_contract_selftest.gd:346:			Shell.cabinet_count(sl, "b1"),
scripts/dev/banking_contract_selftest.gd:347:			Shell.cabinet_count(sl, "b2"),
scripts/dev/banking_contract_selftest.gd:355:		"per-origin cabinet_count: b1=2, b2=1 independently",
scripts/dev/banking_contract_selftest.gd:356:		Shell.cabinet_count(mix, "b1") == 2 and Shell.cabinet_count(mix, "b2") == 1,
scripts/dev/banking_contract_selftest.gd:357:		"b1=%s b2=%s" % [Shell.cabinet_count(mix, "b1"), Shell.cabinet_count(mix, "b2")]
scripts/collection_journey.gd:103:## Uses CampaignShell.project_cabinet_count — carried fifth is NOT an open gate until banked.
scripts/collection_journey.gd:111:	var quota: int = CAMPAIGN_SHELL.quota_of(rules)
scripts/collection_journey.gd:112:	var now: int = CAMPAIGN_SHELL.cabinet_count(state, pool)
scripts/collection_journey.gd:113:	var projected: int = CAMPAIGN_SHELL.project_cabinet_count(state, pool, held_ids, pools_by_id)
scripts/collection_journey.gd:134:## `won` / cabinets_complete alone must NOT emit it — 66/67 is still incomplete.
scripts/collection_journey.gd:143:	var quota: int = CAMPAIGN_SHELL.quota_of(rules)
scripts/collection_journey.gd:152:		var b0: int = CAMPAIGN_SHELL.cabinet_count(before, pid)
scripts/collection_journey.gd:153:		var b1: int = CAMPAIGN_SHELL.cabinet_count(after, pid)
scripts/collection_journey.gd:196:		if CAMPAIGN_SHELL.cabinet_count(state, pid) < need:
scripts/dev/biome_cabinets_selftest.gd:40:	failed = _check(failed, "quota 5", Cases.quota_of(rules) == 5) or failed
tools/qa/check_progress_menu.py:115:    ok("menu.can_start_gate", "CAMPAIGN_SHELL.can_start" in menu)
tools/qa/check_progress_menu.py:171:        and "stamp_map_piece" in main_gd
tools/qa/check_progress_menu.py:177:            "cabinet_count(_campaign.state, pool_id) >= quota" in main_gd
tools/qa/check_progress_menu.py:178:            or "CAMPAIGN_SHELL.cabinet_count(_campaign.state, pool_id) >= quota" in main_gd
tools/qa/check_progress_menu.py:196:    ok("shell.can_start_exists", "static func can_start" in shell)
tools/qa/check_progress_menu.py:197:    ok("shell.shortcut_open_exists", "static func shortcut_open" in shell)
tools/qa/check_campaign_save_copy.py:4:Godot Dictionary.get("map_pieces", []) returns [] when the key is absent, so
tools/qa/check_campaign_save_copy.py:5:`typeof(...) == TYPE_ARRAY` passes, then disk["map_pieces"] crashes. Older
tools/qa/check_campaign_save_copy.py:43:    if 'disk.get("map_pieces"' not in body and 'disk.has("map_pieces")' not in body:
tools/qa/check_campaign_save_copy.py:44:        print("FAIL: _copy_state does not read map_pieces safely")
tools/qa/check_campaign_save_copy.py:50:        "endless_unlocked": False,
tools/qa/check_campaign_save_copy.py:58:        "map_pieces": [],
tools/qa/check_campaign_save_copy.py:59:        "endless_unlocked": False,
tools/qa/check_campaign_save_copy.py:63:        "pencil_fresh": [],
tools/qa/check_campaign_save_copy.py:72:    state["map_pieces"] = list(old.get("map_pieces", []))
tools/qa/check_campaign_save_copy.py:73:    state["pencil_fresh"] = list(old.get("pencil_fresh", []))
tools/qa/check_campaign_save_copy.py:76:    state["endless_unlocked"] = bool(old.get("endless_unlocked", False))
tools/qa/check_campaign_save_copy.py:83:    assert state["map_pieces"] == []
tools/qa/check_campaign_save_copy.py:90:        "map_pieces": ["b2", "b3"],
tools/qa/check_campaign_save_copy.py:98:    state2["map_pieces"] = list(new.get("map_pieces", []))
tools/qa/check_campaign_save_copy.py:104:    assert state2["map_pieces"] == ["b2", "b3"]
scripts/cabin/rope_exit.gd:46:var _can_push: bool = true
scripts/cabin/rope_exit.gd:713:	if _campaign_mode and not _can_push:
scripts/cabin/rope_exit.gd:945:## can_push: whether deeper is allowed.
scripts/cabin/rope_exit.gd:976:func apply_exit_mode(campaign: bool, can_push: bool, push_interrupt: bool = false, chip: Dictionary = {}, endless: bool = false) -> void:
scripts/cabin/rope_exit.gd:978:	_can_push = (not campaign) or can_push
scripts/cabin/rope_exit.gd:1203:	if _campaign_mode and not _can_push:
scripts/dev/continuation_inventory_probe.gd:185:	failed = _check(failed, "shell_can_push_d1_to_d2", Shell.can_push(rules, state)) or failed
scripts/dev/continuation_inventory_probe.gd:198:	failed = _check(failed, "shell_can_push_d2_to_d3", Shell.can_push(rules, state)) or failed
scripts/dev/continuation_inventory_probe.gd:225:	Shell.stamp_map_piece(rules, state, "b1")
scripts/dev/continuation_inventory_probe.gd:281:	var projected: int = Shell.project_cabinet_count(state, "b1", haul, pools)
scripts/dev/continuation_inventory_probe.gd:282:	failed = _check(failed, "shell_projected_haul_reaches_quota", projected >= Shell.quota_of(rules)) or failed
scripts/dev/continuation_inventory_probe.gd:286:		Shell.cabinet_count(state, "b1") < Shell.quota_of(rules)
scripts/dev/continuation_inventory_probe.gd:291:		not Shell.can_push(rules, state)
scripts/dev/continuation_inventory_probe.gd:308:		Shell.cabinet_count(state, "b1") >= Shell.quota_of(rules) and Shell.can_push(rules, state)
scripts/cabin/map_piece_beat.gd:30:	var nxt: Dictionary = SHELL.stamp_map_piece(shell.rules, shell.state, filled_pool)
scripts/campaign_shell.gd:46:		"map_pieces": [],
scripts/campaign_shell.gd:47:		"endless_unlocked": false,
scripts/campaign_shell.gd:52:		## Distinct from cabinets_complete won/endless and from full-collection inheritance.
scripts/campaign_shell.gd:54:		"pencil_fresh": [],
scripts/campaign_shell.gd:72:	state["endless_unlocked"] = bool(state.get("endless_unlocked", false))
scripts/campaign_shell.gd:77:	state["map_pieces"] = _clean_id_list(state.get("map_pieces", []))
scripts/campaign_shell.gd:78:	state["pencil_fresh"] = _clean_id_list(state.get("pencil_fresh", []))
scripts/campaign_shell.gd:79:	var pieces: Variant = state.get("map_pieces", [])
scripts/campaign_shell.gd:86:	state["map_pieces"] = piece_clean
scripts/campaign_shell.gd:134:static func quota_of(rules: Dictionary) -> int:
scripts/campaign_shell.gd:135:	return maxi(1, int(rules.get("cabinet_quota", 5)))
scripts/campaign_shell.gd:148:static func cabinet_count(state: Dictionary, pool: String) -> int:
scripts/campaign_shell.gd:162:static func biome_unlocked(rules: Dictionary, state: Dictionary, index: int) -> bool:
scripts/campaign_shell.gd:169:	return cabinet_count(state, str(prev.get("id", ""))) >= quota_of(rules)
scripts/campaign_shell.gd:172:static func pool_unlocked(rules: Dictionary, state: Dictionary, pool: String) -> bool:
scripts/campaign_shell.gd:177:			return biome_unlocked(rules, state, i)
scripts/campaign_shell.gd:182:static func pool_open_for_bucket(rules: Dictionary, state: Dictionary, bucket: int) -> bool:
scripts/campaign_shell.gd:184:	return pool != "" and pool_unlocked(rules, state, pool)
scripts/campaign_shell.gd:193:	if cabinets_complete(rules, state):
scripts/campaign_shell.gd:211:static func shortcut_open(rules: Dictionary, state: Dictionary, index: int) -> bool:
scripts/campaign_shell.gd:215:	return biome_unlocked(rules, state, index + 1)
scripts/campaign_shell.gd:223:## no invented D5 fresh-start shortcut. biome_unlocked / can_push stay separate.
scripts/campaign_shell.gd:224:static func can_start(rules: Dictionary, state: Dictionary, index: int) -> bool:
scripts/campaign_shell.gd:229:	return shortcut_open(rules, state, index)
scripts/campaign_shell.gd:232:static func can_push(rules: Dictionary, state: Dictionary) -> bool:
scripts/campaign_shell.gd:240:	return biome_unlocked(rules, state, nxt)
scripts/campaign_shell.gd:244:## Never in Endless. Never at/above quota (even on the last biome where can_push is false).
scripts/campaign_shell.gd:245:static func push_needs_nib(rules: Dictionary, state: Dictionary) -> bool:
scripts/campaign_shell.gd:250:	return cabinet_count(state, pool) < quota_of(rules)
scripts/campaign_shell.gd:275:static func project_cabinet_count(state: Dictionary, pool: String, ids: Array, pools_by_id: Dictionary) -> int:
scripts/campaign_shell.gd:276:	var n := cabinet_count(state, pool)
scripts/campaign_shell.gd:345:	return (state.get("map_pieces", []) as Array).size()
scripts/campaign_shell.gd:375:## pencil_fresh only when the piece is newly owned (first) — already-owned pieces stay
scripts/campaign_shell.gd:376:## unowned-fresh after clear_pencil_fresh so ordinary Leave does not re-mark the map.
scripts/campaign_shell.gd:377:static func stamp_map_piece(rules: Dictionary, state: Dictionary, filled_pool: String) -> Dictionary:
scripts/campaign_shell.gd:383:	var pieces: Array = state["map_pieces"]
scripts/campaign_shell.gd:384:	var fresh: Array = state["pencil_fresh"]
scripts/campaign_shell.gd:396:static func clear_pencil_fresh(state: Dictionary) -> void:
scripts/campaign_shell.gd:398:	state["pencil_fresh"] = []
scripts/campaign_shell.gd:424:	if not can_push(rules, state):
scripts/campaign_shell.gd:452:	var win := cabinets_complete(rules, state)
scripts/campaign_shell.gd:455:		state["endless_unlocked"] = true
scripts/campaign_shell.gd:469:static func cabinets_complete(rules: Dictionary, state: Dictionary) -> bool:
scripts/campaign_shell.gd:470:	var q := quota_of(rules)
scripts/campaign_shell.gd:473:		if cabinet_count(state, str(b.get("id", ""))) < q:
scripts/campaign_shell.gd:509:## Does NOT set won / endless_unlocked (cabinets_complete owns those) and does NOT
scripts/campaign_shell.gd:552:	if cabinets_complete(rules, state):
scripts/campaign_shell.gd:554:		state["endless_unlocked"] = true
scripts/campaign_shell.gd:565:		var need: int = quota_of(rules) - cabinet_count(state, pool)
scripts/campaign_shell.gd:573:	state["map_pieces"] = pieces
scripts/campaign_shell.gd:575:	state["endless_unlocked"] = true
scripts/campaign_shell.gd:642:	var pieces: Array = state.get("map_pieces", [])
scripts/campaign_shell.gd:817:	## Older user://campaign_save.json files omit keys added later (map_pieces,
scripts/campaign_shell.gd:818:	## mudroom_loadout, pencil_fresh, endless_best, …). Never hard-index a key
scripts/campaign_shell.gd:826:	state["map_pieces"] = _clean_id_list(disk.get("map_pieces", []))
scripts/campaign_shell.gd:827:	state["pencil_fresh"] = _clean_id_list(disk.get("pencil_fresh", []))
scripts/campaign_shell.gd:835:	state["endless_unlocked"] = bool(disk.get("endless_unlocked", false))
scripts/dev/collection_a_notrun_cases.gd:500:	## Bank 5 so can_push; carry two NOT yet banked missing ids.
scripts/dev/collection_a_notrun_cases.gd:521:	var can_push: bool = CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state)
scripts/dev/collection_a_notrun_cases.gd:523:	if rope == null or not can_push:
scripts/dev/collection_a_notrun_cases.gd:524:		_row("11", "NOTRUN", "fixture", "rope/can_push unavailable can_push=%s" % can_push)
scripts/dev/collection_a_notrun_cases.gd:591:	var can_push: bool = CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state)
scripts/dev/collection_a_notrun_cases.gd:595:	if can_push and rope != null:
scripts/dev/collection_a_notrun_cases.gd:632:	if can_push and via == "rope_deeper" and pool_now == "b2" and still_held:
scripts/dev/collection_a_notrun_cases.gd:634:	elif can_push and pool_now == "b2":
scripts/dev/collection_a_notrun_cases.gd:637:		_row("12", "NOTRUN", "integration", "Push failed can_push=%s pool=%s via=%s" % [can_push, pool_now, via])
scripts/dev/collection_a_notrun_cases.gd:910:	var cabinets_done: bool = CAMPAIGN_SHELL.cabinets_complete(main._campaign.rules, state)
scripts/dev/collection_a_notrun_cases.gd:912:	var abyss_unlocked: bool = CAMPAIGN_SHELL.pool_unlocked(main._campaign.rules, state, "b5")
scripts/dev/collection_a_notrun_cases.gd:928:	var endless_now: bool = bool(main._campaign.state.get("endless_unlocked", false))
scripts/dev/collection_a_notrun_cases.gd:1110:	after_neg["endless_unlocked"] = true
scripts/dev/collection_a_notrun_cases.gd:1295:	state["endless_unlocked"] = true
scripts/biome_cabinets.gd:335:static func quota_of(rules: Dictionary) -> int:
scripts/biome_cabinets.gd:336:	var q := int(rules.get("cabinet_quota", 5))
scripts/biome_cabinets.gd:446:	if not _SHELL.pool_unlocked(rules, state, pool):
scripts/biome_cabinets.gd:467:	var quota := quota_of(rules)
scripts/biome_cabinets.gd:468:	var cab: int = int(_SHELL.cabinet_count(state, pool))
scripts/cabin/held_map.gd:181:## Fresh-start launch hit exists for this pool (can_start / Endless open).
scripts/cabin/held_map.gd:221:		SHELL.clear_pencil_fresh(_state)
scripts/cabin/held_map.gd:235:		if SHELL.biome_unlocked(_rules, _state, i):
scripts/cabin/held_map.gd:240:	var fresh_raw: Variant = _state.get("pencil_fresh", [])
scripts/cabin/held_map.gd:261:		## Destination visibility (biome_unlocked) is separate from fresh-start
scripts/cabin/held_map.gd:262:		## launch (can_start / one-behind). Unlocked D2 stays on the map with
scripts/cabin/held_map.gd:264:		var unlocked: bool = SHELL.biome_unlocked(_rules, _state, i)
scripts/cabin/held_map.gd:265:		var launchable: bool = SHELL.can_start(_rules, _state, i)
scripts/cabin/held_map.gd:272:	if bool(_state.get("endless_unlocked", false)):
scripts/cabin/held_map.gd:302:		if SHELL.can_start(_rules, _state, i):
scripts/cabin/room_mudroom.gd:199:		var open: bool = CampaignShell.can_start(rules, state, i)
scripts/dev/collection_journey_milestones_selftest.gd:12:		"cabinet_quota": 5,
scripts/dev/collection_journey_milestones_selftest.gd:53:	## Quota-complete every biome so cabinets_complete / won would be true if we keyed off that.
scripts/dev/collection_journey_milestones_selftest.gd:55:	after_n["endless_unlocked"] = true
scripts/dev/collection_journey_milestones_selftest.gd:96:	failed = _check(failed, "fc_not_cabinets", not SHELL.cabinets_complete(rules, fc_state)) or failed
scripts/dev/collection_journey_milestones_selftest.gd:118:	failed = _check(failed, "fc_no_endless", not bool(fc_state.get("endless_unlocked", false))) or failed
scripts/dev/campaign_shell_selftest.gd:41:	failed = _check(failed, "only verdant hollow starts", Shell.can_start(rules, state, 0) and not Shell.can_start(rules, state, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:42:	failed = _check(failed, "fresh: invalid negative start", Shell.can_start(rules, state, -1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:43:	failed = _check(failed, "fresh: out-of-range start", Shell.can_start(rules, state, 5) == false and Shell.can_start(rules, state, 99) == false) or failed
scripts/dev/campaign_shell_selftest.gd:47:	failed = _check(failed, "four held: dungeon2 locked", Shell.cabinet_count(fresh4, "b1") == 4 and not Shell.biome_unlocked(rules, fresh4, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:48:	failed = _check(failed, "four held: only D1 starts", Shell.can_start(rules, fresh4, 0) and not Shell.can_start(rules, fresh4, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:52:	failed = _check(failed, "verdant hollow counts the 3", Shell.cabinet_count(state, "b1") == 3) or failed
scripts/dev/campaign_shell_selftest.gd:53:	failed = _check(failed, "crystal cavern still locked", Shell.biome_unlocked(rules, state, 1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:54:	failed = _check(failed, "no push yet", Shell.can_push(rules, state) == false) or failed
scripts/dev/campaign_shell_selftest.gd:56:	failed = _check(failed, "verdant hollow full", Shell.cabinet_count(state, "b1") == 5) or failed
scripts/dev/campaign_shell_selftest.gd:57:	failed = _check(failed, "crystal cavern opens", Shell.biome_unlocked(rules, state, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:59:	failed = _check(failed, "d2 unlocked does not start d2", Shell.can_start(rules, state, 1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:60:	failed = _check(failed, "d1 still startable after d2 unlock", Shell.can_start(rules, state, 0)) or failed
scripts/dev/campaign_shell_selftest.gd:61:	failed = _check(failed, "ashen crypt stays shut", Shell.can_start(rules, state, 2) == false) or failed
scripts/dev/campaign_shell_selftest.gd:62:	failed = _check(failed, "shortcut to verdant hollow", Shell.shortcut_open(rules, state, 0)) or failed
scripts/dev/campaign_shell_selftest.gd:63:	failed = _check(failed, "no shortcut to crystal cavern yet", Shell.shortcut_open(rules, state, 1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:68:	failed = _check(failed, "six held: dungeon2 destination open", Shell.cabinet_count(six, "b1") == 6 and Shell.biome_unlocked(rules, six, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:69:	failed = _check(failed, "six held: still cannot fresh-start d2", Shell.can_start(rules, six, 1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:70:	# S3: map piece + pencil only via stamp_map_piece (ceremony), never bank() alone.
scripts/dev/campaign_shell_selftest.gd:72:	var stamped: Dictionary = Shell.stamp_map_piece(rules, state, "b1")
scripts/dev/campaign_shell_selftest.gd:75:	failed = _check(failed, "map_pieces has b2", (state["map_pieces"] as Array).has("b2")) or failed
scripts/dev/campaign_shell_selftest.gd:76:	failed = _check(failed, "pencil_fresh has b2", (state["pencil_fresh"] as Array).has("b2")) or failed
scripts/dev/campaign_shell_selftest.gd:77:	var again: Dictionary = Shell.stamp_map_piece(rules, state, "b1")
scripts/dev/campaign_shell_selftest.gd:80:	failed = _check(failed, "stamp does not grant d2 start", Shell.can_start(rules, state, 1) == false) or failed
scripts/dev/campaign_shell_selftest.gd:81:	Shell.clear_pencil_fresh(state)
scripts/dev/campaign_shell_selftest.gd:82:	failed = _check(failed, "pencil clears after map open", (state["pencil_fresh"] as Array).is_empty()) or failed
scripts/dev/campaign_shell_selftest.gd:84:	failed = _check(failed, "can push into crystal cavern", Shell.can_push(rules, state)) or failed
scripts/dev/campaign_shell_selftest.gd:85:	failed = _check(failed, "push stays distinct from can_start d2", Shell.can_push(rules, state) and not Shell.can_start(rules, state, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:86:	failed = _check(failed, "no nib at 5/5", Shell.push_needs_nib(rules, state) == false) or failed
scripts/dev/campaign_shell_selftest.gd:91:	failed = _check(failed, "d3 unlock: destination d3 open", Shell.biome_unlocked(rules, ladder, 2)) or failed
scripts/dev/campaign_shell_selftest.gd:92:	failed = _check(failed, "d3 unlock: d2 destination still open", Shell.biome_unlocked(rules, ladder, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:93:	failed = _check(failed, "d3 unlock: earns d2 fresh start", Shell.can_start(rules, ladder, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:94:	failed = _check(failed, "d3 unlock: d1 start preserved", Shell.can_start(rules, ladder, 0)) or failed
scripts/dev/campaign_shell_selftest.gd:95:	failed = _check(failed, "d3 unlock: cannot fresh-start d3", Shell.can_start(rules, ladder, 2) == false) or failed
scripts/dev/campaign_shell_selftest.gd:96:	failed = _check(failed, "d3 unlock: shortcut_open matches d2 start", Shell.shortcut_open(rules, ladder, 1) == Shell.can_start(rules, ladder, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:98:	failed = _check(failed, "d4 unlock: earns d3 fresh start", Shell.can_start(rules, ladder, 2)) or failed
scripts/dev/campaign_shell_selftest.gd:99:	failed = _check(failed, "d4 unlock: prior d2 start preserved", Shell.can_start(rules, ladder, 1)) or failed
scripts/dev/campaign_shell_selftest.gd:100:	failed = _check(failed, "d4 unlock: cannot fresh-start d4", Shell.can_start(rules, ladder, 3) == false) or failed
scripts/dev/campaign_shell_selftest.gd:102:	failed = _check(failed, "d5 unlock: earns d4 fresh start", Shell.can_start(rules, ladder, 3)) or failed
scripts/dev/campaign_shell_selftest.gd:103:	failed = _check(failed, "d5 unlock: prior starts preserved", Shell.can_start(rules, ladder, 0) and Shell.can_start(rules, ladder, 1) and Shell.can_start(rules, ladder, 2)) or f
scripts/dev/campaign_shell_selftest.gd:104:	failed = _check(failed, "d5 unlock: cannot fresh-start d5", Shell.can_start(rules, ladder, 4) == false) or failed
scripts/dev/campaign_shell_selftest.gd:105:	failed = _check(failed, "no invented d5 shortcut_open", Shell.shortcut_open(rules, ladder, 4) == false) or failed
scripts/dev/campaign_shell_selftest.gd:106:	failed = _check(failed, "ladder out-of-range still false", Shell.can_start(rules, ladder, -3) == false and Shell.can_start(rules, ladder, 5) == false) or failed
scripts/dev/campaign_shell_selftest.gd:109:	failed = _check(failed, "push independent after d5 unlock", Shell.can_push(rules, ladder)) or failed
scripts/dev/campaign_shell_selftest.gd:114:	failed = _check(failed, "nib under 5/5", Shell.push_needs_nib(rules, under)) or failed
scripts/dev/campaign_shell_selftest.gd:115:	failed = _check(failed, "cabinet_count is the ledger", Shell.cabinet_count(under, "b1") == 2) or failed
scripts/dev/campaign_shell_selftest.gd:116:	var proj_n: int = Shell.project_cabinet_count(
scripts/dev/campaign_shell_selftest.gd:127:	failed = _check(failed, "no nib in endless", Shell.push_needs_nib(rules, under) == false) or failed
scripts/dev/campaign_shell_selftest.gd:220:	failed = _check(failed, "win", bool(full.get("won", false)) and bool(full.get("endless_unlocked", false))) or failed
scripts/dev/campaign_shell_selftest.gd:225:	failed = _check(failed, "endless can push", Shell.can_push(rules, full)) or failed
scripts/dev/campaign_shell_selftest.gd:228:	failed = _check(failed, "endless still pushable", Shell.can_push(rules, full)) or failed
scripts/dev/campaign_shell_selftest.gd:234:	piece_state["map_pieces"] = ["b2", "b3"]
scripts/dev/campaign_shell_selftest.gd:245:	## Older campaign_save.json (no map_pieces / mudroom_loadout / …) must load.
scripts/dev/campaign_shell_selftest.gd:250:		"endless_unlocked": false,
scripts/dev/campaign_shell_selftest.gd:259:	failed = _check(failed, "old save map_pieces default", (shell_old.state["map_pieces"] as Array).is_empty()) or failed
scripts/dev/campaign_shell_selftest.gd:261:	failed = _check(failed, "old save pencil_fresh default", (shell_old.state["pencil_fresh"] as Array).is_empty()) or failed
scripts/dev/campaign_shell_selftest.gd:269:		"map_pieces": ["b2", "b3"],
scripts/dev/campaign_shell_selftest.gd:271:		"pencil_fresh": ["b2"],
scripts/dev/campaign_shell_selftest.gd:272:		"endless_unlocked": true,
scripts/dev/campaign_shell_selftest.gd:280:	failed = _check(failed, "new save copies map_pieces", (shell_new.state["map_pieces"] as Array) == ["b2", "b3"]) or failed
scripts/dev/campaign_shell_selftest.gd:282:	failed = _check(failed, "new save copies pencil_fresh", (shell_new.state["pencil_fresh"] as Array).has("b2")) or failed
scripts/dev/campaign_shell_selftest.gd:353:	failed = _check(failed, "fill every cabinet completes", Shell.cabinets_complete(rules, open_state)) or failed
scripts/dev/campaign_shell_selftest.gd:354:	failed = _check(failed, "fill every cabinet inks later stamps", (open_state["map_pieces"] as Array).has("b5")) or failed
scripts/dev/collection_journey_selftest.gd:17:	failed = _check(failed, "quota_five", CAMPAIGN_SHELL.quota_of(rules) == 5) or failed
scripts/home_cabin.gd:17:signal cabinet_gate_crossed(pool_id: String)
scripts/home_cabin.gd:19:signal shortcut_scene_wanted(pool_id: String)
scripts/home_cabin.gd:2596:	# One ledger with Push gating: CampaignShell.cabinet_count (banked).
scripts/home_cabin.gd:2598:		var n: int = CampaignShell.cabinet_count(_campaign_shell.state, pool_id)
scripts/home_cabin.gd:2631:	return maxi(CampaignShell.cabinet_count(state, pool_id), from_swipe)
scripts/home_cabin.gd:2636:	var quota := BiomeCabinets.quota_of(rules)
scripts/home_cabin.gd:2651:	var quota := BiomeCabinets.quota_of(rules)
scripts/home_cabin.gd:2730:		lit.append(CampaignShell.pool_unlocked(rules, state, "b%d" % (i + 1)))
scripts/home_cabin.gd:2749:	if not CampaignShell.pool_unlocked(rules, state, pool_id):
scripts/home_cabin.gd:3385:	var quota := BiomeCabinets.quota_of(_biome_rules())
scripts/home_cabin.gd:3478:	var quota := BiomeCabinets.quota_of(_biome_rules())
scripts/home_cabin.gd:3590:			cabinet_gate_crossed.emit(str(pool_id2))
scripts/home_cabin.gd:3600:				shortcut_scene_wanted.emit("b%d" % (unlocked_i + 1))
scripts/dev/held_map_launch_selftest.gd:49:	failed = _check(failed, "shell.d2.unlocked", SHELL.biome_unlocked(rules, d2, 1)) or failed
scripts/dev/held_map_launch_selftest.gd:50:	failed = _check(failed, "shell.d2.not_start", not SHELL.can_start(rules, d2, 1)) or failed
scripts/dev/held_map_launch_selftest.gd:72:	failed = _check(failed, "shell.d3.can_start_d2", SHELL.can_start(rules, d3, 1)) or failed
scripts/dev/held_map_launch_selftest.gd:73:	failed = _check(failed, "shell.d3.not_start_d3", not SHELL.can_start(rules, d3, 2)) or failed
scripts/dev/main_launch_gate_probe.gd:5:## eligible normal + shortcut pass `can_start` gate; Push does not route through
scripts/dev/main_launch_gate_probe.gd:103:		"source_start_uses_can_start",
scripts/dev/main_launch_gate_probe.gd:104:		src.find("CAMPAIGN_SHELL.can_start") >= 0
scripts/dev/main_launch_gate_probe.gd:190:		Shell.biome_unlocked(main._campaign.rules, main._campaign.state, 1)
scripts/dev/main_launch_gate_probe.gd:191:		and not Shell.can_start(main._campaign.rules, main._campaign.state, 1)
scripts/dev/main_launch_gate_probe.gd:274:		and Shell.can_start(main._campaign.rules, main._campaign.state, 0)
scripts/dev/main_launch_gate_probe.gd:282:		Shell.can_start(main._campaign.rules, main._campaign.state, 1)
scripts/dev/main_launch_gate_probe.gd:316:		Shell.can_push(main._campaign.rules, main._campaign.state)
scripts/dev/homecoming_live_repot.gd:320:	var pieces_before: int = _map_pieces(cabin)
scripts/dev/homecoming_live_repot.gd:326:	var pieces_mid: int = _map_pieces(cabin)
scripts/dev/homecoming_live_repot.gd:353:	_verdict("H5", line and finished and before == 4 and after >= 5, "before=%s after=%s line=%s pieces=%s" % [before, after, line, _map_pieces(cabin)])
scripts/dev/homecoming_live_repot.gd:434:	var pieces_before: int = _map_pieces(cabin)
scripts/dev/homecoming_live_repot.gd:442:	_verdict("H10", _banked_has(cabin, id) and not give and not thresh and _map_pieces(cabin) == pieces_before, "give=%s thresh=%s pieces=%s pending=%s" % [give, thresh, _map_pieces(
scripts/dev/homecoming_live_repot.gd:642:		cabin._campaign_shell.state["map_pieces"] = []
scripts/dev/homecoming_live_repot.gd:679:func _map_pieces(cabin) -> int:
scripts/dev/homecoming_live_repot.gd:682:	return (cabin._campaign_shell.state.get("map_pieces", []) as Array).size()
scripts/main.gd:3385:	# held_map may clear pencil_fresh on present — persist that.
scripts/main.gd:3448:## Revalidate every map→delve launch against CampaignShell.can_start (one-behind).
scripts/main.gd:3463:		return bool(_campaign.state.get("endless_unlocked", false))
scripts/main.gd:3464:	return CAMPAIGN_SHELL.can_start(_campaign.rules, _campaign.state, index)
scripts/main.gd:3590:		var need: int = CAMPAIGN_SHELL.quota_of(_campaign.rules) - CAMPAIGN_SHELL.cabinet_count(_campaign.state, "b1")
scripts/main.gd:3744:	return CAMPAIGN_SHELL.pool_open_for_bucket(_campaign.rules, _campaign.state, BucketRules.of_card(card))
scripts/main.gd:3802:## stamp_map_piece is idempotent per next id — old saves / re-Leave do not double-award.
scripts/main.gd:3822:	var quota: int = CAMPAIGN_SHELL.quota_of(_campaign.rules)
scripts/main.gd:3830:			if CAMPAIGN_SHELL.cabinet_count(_campaign.state, pool_id) >= quota:
scripts/main.gd:3831:				CAMPAIGN_SHELL.stamp_map_piece(_campaign.rules, _campaign.state, pool_id)
scripts/main.gd:3859:	## Distinct from cabinets_complete won/endless and from full-collection inheritance.
scripts/main.gd:4008:	if _campaign_on and _campaign != null and not CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state):
scripts/main.gd:4175:		if not CAMPAIGN_SHELL.can_start(_campaign.rules, _campaign.state, idx):
scripts/main.gd:4406:	if _campaign_on and _campaign != null and not CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state):
scripts/main.gd:29052:				var can_push := false
scripts/main.gd:29056:					can_push = CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state)
scripts/main.gd:29058:					var quota: int = CAMPAIGN_SHELL.quota_of(_campaign.rules)
scripts/main.gd:29059:					var n: int = CAMPAIGN_SHELL.cabinet_count(_campaign.state, pool)
scripts/main.gd:29071:					var projected: int = CAMPAIGN_SHELL.project_cabinet_count(
scripts/main.gd:29076:					## still only shows when can_push — same as before.
scripts/main.gd:29079:					if can_push and next_id != "":
scripts/main.gd:29089:						"show_next": can_push and next_name != "",
scripts/main.gd:29091:					push_interrupt = CAMPAIGN_SHELL.push_needs_nib(_campaign.rules, _campaign.state)
scripts/main.gd:29093:				rope_exit.apply_exit_mode(_campaign_on, can_push, push_interrupt, chip, endless_run)
```

## Map (held map / campaign map / map piece beat)

```
scripts/campaign_map.gd:21:	name = "campaign_map"
scripts/campaign_map.gd:52:	_held = preload("res://scripts/cabin/held_map.gd").new()
scripts/campaign_map.gd:74:## Held parchment Control (scripts/cabin/held_map.gd). Used by map launch tests.
scripts/campaign_map.gd:75:func held_map() -> Control:
scripts/campaign_map.gd:80:func destination_visible(pool: String) -> bool:
scripts/campaign_map.gd:81:	if _held == null or not _held.has_method("destination_visible"):
scripts/campaign_map.gd:83:	return bool(_held.call("destination_visible", pool))
scripts/campaign_map.gd:87:func destination_launchable(pool: String) -> bool:
scripts/campaign_map.gd:88:	if _held == null or not _held.has_method("destination_launchable"):
scripts/campaign_map.gd:90:	return bool(_held.call("destination_launchable", pool))
scripts/dev/shot_harness.gd:1284:	if main._campaign == null or main.campaign_map == null:
scripts/dev/shot_harness.gd:1285:		_skip("gif-05-held-map.png", "campaign or campaign_map missing")
scripts/dev/shot_harness.gd:1287:			_skip("gif-05-held-map_f%02d.png" % i, "campaign or campaign_map missing")
scripts/dev/shot_harness.gd:1289:	if main.has_method("_open_campaign_map"):
scripts/dev/shot_harness.gd:1290:		main._open_campaign_map()
scripts/dev/shot_harness.gd:1292:	if not main.campaign_map.visible:
scripts/dev/shot_harness.gd:1301:	if main.has_method("_close_campaign_map"):
scripts/dev/shot_harness.gd:1302:		main.campaign_map.hide_map()
scripts/dev/shot_harness.gd:3397:		await _capture("75_homecoming_fly_spark.png", "fly spark + trail on mid-air loot")
scripts/cabin/map_piece_beat.gd:14:	name = "MapPieceBeat"
scripts/cabin/held_map.gd:23:const TRAIL: Array[Vector2] = [
scripts/cabin/held_map.gd:31:## Per-biome Deadly patrol lanes (offsets from TRAIL[i+1]). Slot k = k-th telegraph id.
scripts/cabin/held_map.gd:90:	name = "HeldMap"
scripts/cabin/held_map.gd:177:func destination_visible(pool: String) -> bool:
scripts/cabin/held_map.gd:178:	return _pin_with_meta(pool, "destination_visible") != null
scripts/cabin/held_map.gd:182:func destination_launchable(pool: String) -> bool:
scripts/cabin/held_map.gd:202:	var want := "LaunchHit_%s" % pool
scripts/cabin/held_map.gd:249:					# Segment bi connects TRAIL[bi] → TRAIL[bi+1] (cabin→b1 is 0).
scripts/cabin/held_map.gd:252:	_ink.pts = PackedVector2Array(TRAIL)
scripts/cabin/held_map.gd:260:		var spot: Vector2 = TRAIL[i + 1]
scripts/cabin/held_map.gd:315:	hit.name = "LaunchHit_start"
scripts/cabin/held_map.gd:415:	seal.set_meta("destination_visible", true)
scripts/cabin/held_map.gd:427:	hit.name = "LaunchHit_%s" % pool
scripts/cabin/held_map.gd:457:	blob.set_meta("destination_visible", false)
scripts/cabin/held_map.gd:1075:	## Trail segment indices drawn as grey pencil (just stamped) instead of solid ink.
scripts/cabin/map_overlay.gd:3:## The player-facing biome map is scripts/cabin/held_map.gd: Sprout holds this
scripts/cabin/clear_parade.gd:400:	float trail = progress - 1.0;
scripts/cabin/clear_parade.gd:401:	float a = smoothstep(lead + soft, lead - soft, h) * smoothstep(trail - soft, trail + soft, h);
scripts/dev/main_launch_gate_probe.gd:239:	if main.campaign_map == null:
scripts/dev/main_launch_gate_probe.gd:240:		return _check(failed, "campaign_map_present", false)
scripts/dev/main_launch_gate_probe.gd:241:	main.campaign_map.show_map(main._campaign.rules, main._campaign.state, {}, {"read_only": true})
scripts/dev/main_launch_gate_probe.gd:243:	failed = _check(failed, "map_is_read_only", main.campaign_map.is_read_only()) or failed
scripts/dev/main_launch_gate_probe.gd:259:	main.campaign_map.hide_map()
scripts/dev/held_map_launch_selftest.gd:3:## Instantiates campaign_map / held_map, drives present + LaunchHit presses.
scripts/dev/held_map_launch_selftest.gd:4:## Run: godot --headless --path . --script res://scripts/dev/held_map_launch_selftest.gd
scripts/dev/held_map_launch_selftest.gd:8:const CAMPAIGN_MAP := preload("res://scripts/campaign_map.gd")
scripts/dev/held_map_launch_selftest.gd:14:	var map: Control = CAMPAIGN_MAP.new()
scripts/dev/held_map_launch_selftest.gd:22:	failed = _check(failed, "fresh.b1.visible", map.destination_visible("b1")) or failed
scripts/dev/held_map_launch_selftest.gd:23:	failed = _check(failed, "fresh.b1.launchable", map.destination_launchable("b1")) or failed
scripts/dev/held_map_launch_selftest.gd:24:	failed = _check(failed, "fresh.b2.hidden_dest", not map.destination_visible("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:25:	failed = _check(failed, "fresh.b2.not_launchable", not map.destination_launchable("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:52:	failed = _check(failed, "d2.b1.visible", map.destination_visible("b1")) or failed
scripts/dev/held_map_launch_selftest.gd:53:	failed = _check(failed, "d2.b1.launchable", map.destination_launchable("b1")) or failed
scripts/dev/held_map_launch_selftest.gd:54:	failed = _check(failed, "d2.b2.visible", map.destination_visible("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:55:	failed = _check(failed, "d2.b2.not_launchable", not map.destination_launchable("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:57:	failed = _check(failed, "d2.b3.still_locked", not map.destination_visible("b3") and _has_locked(map, "b3")) or failed
scripts/dev/held_map_launch_selftest.gd:75:	failed = _check(failed, "d3.b2.visible", map.destination_visible("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:76:	failed = _check(failed, "d3.b2.launchable", map.destination_launchable("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:77:	failed = _check(failed, "d3.b3.visible", map.destination_visible("b3")) or failed
scripts/dev/held_map_launch_selftest.gd:78:	failed = _check(failed, "d3.b3.not_launchable", not map.destination_launchable("b3")) or failed
scripts/dev/held_map_launch_selftest.gd:90:	failed = _check(failed, "peek.b2.visible", map.destination_visible("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:91:	failed = _check(failed, "peek.b3.visible", map.destination_visible("b3")) or failed
scripts/dev/held_map_launch_selftest.gd:92:	failed = _check(failed, "peek.no_b1_launch", not map.destination_launchable("b1")) or failed
scripts/dev/held_map_launch_selftest.gd:93:	failed = _check(failed, "peek.no_b2_launch", not map.destination_launchable("b2")) or failed
scripts/dev/held_map_launch_selftest.gd:97:		print("HELD_MAP_LAUNCH_FAIL")
scripts/dev/held_map_launch_selftest.gd:100:		print("HELD_MAP_LAUNCH_OK")
scripts/dev/held_map_launch_selftest.gd:130:	if map.has_method("held_map"):
scripts/dev/held_map_launch_selftest.gd:131:		return map.call("held_map") as Control
scripts/dev/held_map_launch_selftest.gd:167:	return pins.get_node_or_null("LaunchHit_start") != null
scripts/dev/held_map_launch_selftest.gd:197:	var hit: Button = pins.get_node_or_null("LaunchHit_%s" % pool) as Button
scripts/home_cabin.gd:9:signal held_map_wanted
scripts/home_cabin.gd:129:var _map_piece_beat
scripts/home_cabin.gd:3591:			if _map_piece_beat:
scripts/home_cabin.gd:3592:				await _map_piece_beat.play(str(pool_id2))
scripts/home_cabin.gd:3613:func _bank_map_piece_beat() -> Variant:
scripts/home_cabin.gd:3614:	if "_map_piece_beat" in self:
scripts/home_cabin.gd:3615:		return get("_map_piece_beat")
scripts/home_cabin.gd:4762:			_ask_held_map()
scripts/home_cabin.gd:4767:		_ask_held_map()
scripts/home_cabin.gd:4776:			_ask_held_map()
scripts/home_cabin.gd:5236:	_map_piece_beat = preload("res://scripts/cabin/map_piece_beat.gd").new()
scripts/home_cabin.gd:5237:	_map_piece_beat.setup(self)
scripts/home_cabin.gd:5238:	add_child(_map_piece_beat)
scripts/home_cabin.gd:5678:			_ask_held_map()
scripts/home_cabin.gd:5800:	_ask_held_map()
scripts/home_cabin.gd:5808:func _ask_held_map() -> void:
scripts/home_cabin.gd:5809:	held_map_wanted.emit()
scripts/home_cabin.gd:5886:	var picker = host.get("campaign_map")
scripts/home_cabin.gd:5957:		_ask_held_map()
scripts/home_cabin.gd:6792:	var trail_tex: Texture2D = KIT.load_tex("fx/fly_trail.png")
scripts/main.gd:45:const CAMPAIGN_MAP := preload("res://scripts/campaign_map.gd")
scripts/main.gd:868:var campaign_map = null
scripts/main.gd:1911:	home_cabin.held_map_wanted.connect(_toggle_held_map)
scripts/main.gd:1937:	campaign_map = CAMPAIGN_MAP.new()
scripts/main.gd:1938:	add_child(campaign_map)
scripts/main.gd:1939:	campaign_map.setup()
scripts/main.gd:1940:	campaign_map.start_asked.connect(_on_campaign_start)
scripts/main.gd:1941:	campaign_map.closed.connect(_close_campaign_map)
scripts/main.gd:1942:	campaign_map.peek_closed.connect(_on_map_peek_closed)
scripts/main.gd:1943:	campaign_map.cheat_asked.connect(_on_campaign_cheat)
scripts/main.gd:2959:	_open_campaign_map()
scripts/main.gd:3336:		_open_campaign_map()
scripts/main.gd:3358:func _toggle_held_map() -> void:
scripts/main.gd:3359:	if campaign_map and campaign_map.visible:
scripts/main.gd:3360:		if campaign_map.has_method("is_picker_open") and campaign_map.is_picker_open():
scripts/main.gd:3361:			if campaign_map.has_method("is_read_only") and campaign_map.is_read_only():
scripts/main.gd:3364:				_close_campaign_map()
scripts/main.gd:3366:	_open_campaign_map()
scripts/main.gd:3369:func _open_campaign_map() -> void:
scripts/main.gd:3370:	if _campaign == null or campaign_map == null:
scripts/main.gd:3375:		campaign_map.show_drawer()
scripts/main.gd:3376:		await campaign_map.continued
scripts/main.gd:3384:	campaign_map.show_map(_campaign.rules, _campaign.state, monsters_by_id, map_opts)
scripts/main.gd:3385:	# held_map may clear pencil_fresh on present — persist that.
scripts/main.gd:3389:func _close_campaign_map() -> void:
scripts/main.gd:3390:	if campaign_map:
scripts/main.gd:3391:		campaign_map.hide_map()
scripts/main.gd:3401:func _can_peek_campaign_map() -> bool:
scripts/main.gd:3402:	if not _campaign_on or _campaign == null or campaign_map == null:
scripts/main.gd:3404:	if campaign_map.visible:
scripts/main.gd:3434:func _peek_campaign_map() -> void:
scripts/main.gd:3435:	if not _can_peek_campaign_map():
scripts/main.gd:3439:	campaign_map.show_map(_campaign.rules, _campaign.state, monsters_by_id, {"read_only": true})
scripts/main.gd:3443:	if campaign_map:
scripts/main.gd:3444:		campaign_map.hide_map()
scripts/main.gd:3454:	if campaign_map != null and campaign_map.has_method("is_read_only") and campaign_map.is_read_only():
scripts/main.gd:3474:	if campaign_map:
scripts/main.gd:3475:		campaign_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
scripts/main.gd:3489:	if campaign_map:
scripts/main.gd:3490:		campaign_map.hide_map()
scripts/main.gd:3491:		campaign_map.mouse_filter = Control.MOUSE_FILTER_STOP
scripts/main.gd:3599:	_open_campaign_map()
scripts/main.gd:3708:	if campaign_map:
scripts/main.gd:3709:		campaign_map.hide_map()
scripts/main.gd:3886:	if bool(result.get("show_drawer", false)) and campaign_map != null:
scripts/main.gd:3887:		campaign_map.show_drawer()
scripts/main.gd:3888:		await campaign_map.continued
scripts/main.gd:3891:		campaign_map.hide_map()
scripts/main.gd:8563:		if (key.keycode == KEY_M or key.physical_keycode == KEY_M) and _can_peek_campaign_map():
scripts/main.gd:8564:			_peek_campaign_map()
scripts/main.gd:8609:		_open_campaign_map()
scripts/main.gd:8935:		_open_campaign_map()
```

## New-pool reveal screen

```
tools/audio/cues.py:166:c("sting.bucket", "Bucket reveal opens", "bucket_reveal.gd:233–234", "new", "Rising whole-tone pizzicato run", ["sting_bucket"], "Stings", -8, N, 0, 1, 3, duck_music=(-6, 0.05, 1.2))
tools/audio/cues.py:171:c("bucket.open", "Bucket overlay opens", "bucket_reveal.gd:233–234", "keep+", "Bong 0.72 + whoosh 0.85 kept; + card-pack tear + bucket sting", [], "SFX", -8, N, 0, 1, 3, [("bucket.pack", 0, 0), 
tools/audio/cues.py:173:c("bucket.card_pop", "Each shadow card pops", "bucket_reveal.gd:254", "replace", "Card placed (replaces drop)", ["card_place_1", "card_place_2", "card_place_3"], "SFX", -10, (0.9, 1.06), 50, 3, 1)
tools/audio/cues.py:174:c("bucket.ready", "Ready to continue", "bucket_reveal.gd:257, 264", "keep", "confirm_big / confirm", ["confirm_big"], "UI", -10, N, 0, 1, 2)
tools/audio/cues.py:175:c("bucket.card_hover", "Hover a revealed card", "bucket_reveal.gd:348–351", "replace", "Card slide + hover (replaces pluck+whoosh+hover stack)", ["card_slide"], "UI", -16, (1.0, 1.1), 90, 1, 0)
scripts/dev/shot_harness.gd:3616:	if main._bucket_reveal != null:
scripts/dev/shot_harness.gd:3617:		var br = main._bucket_reveal
scripts/dev/shot_harness.gd:3630:		await _capture("08_reveal.png", "bucket_reveal: call, then HP N, then Attack N")
scripts/dev/shot_harness.gd:3634:		_skip("08_reveal.png", "bucket_reveal missing")
scripts/dev/progress_menu_main_routes.gd:343:	var saved := {"cut": null, "reveal": main.get("_bucket_reveal")}
scripts/dev/progress_menu_main_routes.gd:344:	## Null reveal → _tutorial_play_unlock returns immediately (entries empty OR reveal null).
scripts/dev/progress_menu_main_routes.gd:345:	main.set("_bucket_reveal", null)
scripts/dev/progress_menu_main_routes.gd:355:		main.set("_bucket_reveal", saved["reveal"])
scripts/dev/full_pool1_reveal_probe.gd:4:## Proves: with tutorial-seen IDs seeded, `_tutorial_unlock_entries` / `_tutorial_play_unlock`
scripts/dev/full_pool1_reveal_probe.gd:5:## still emit the full canonical Pool 1 set from `_bucket_entries(1)` (no missing/extra/
scripts/dev/full_pool1_reveal_probe.gd:107:	var start: int = src.find("func _tutorial_unlock_entries(")
scripts/dev/full_pool1_reveal_probe.gd:110:	failed = _check(failed, "source_unlock_calls_bucket_entries_1", body.find("_bucket_entries(1)") >= 0) or failed
scripts/dev/full_pool1_reveal_probe.gd:115:		src.find("func _tutorial_play_unlock") >= 0 and src.find("_tutorial_unlock_entries()") >= 0
scripts/dev/full_pool1_reveal_probe.gd:120:		src.find("func _road_finish_to_cabin") >= 0 and src.find("_tutorial_play_unlock") >= 0
scripts/dev/full_pool1_reveal_probe.gd:156:	var expected: Array = main._bucket_entries(1)
scripts/dev/full_pool1_reveal_probe.gd:157:	var got: Array = main._tutorial_unlock_entries()
scripts/dev/full_pool1_reveal_probe.gd:160:	failed = _check(failed, "helper_matches_bucket_entries_1", str(exp_ids) == str(got_ids)) or failed
scripts/dev/full_pool1_reveal_probe.gd:178:	var expected_ids: Array = _ids_of(main._bucket_entries(1))
scripts/dev/full_pool1_reveal_probe.gd:182:	var saved_reveal = main.get("_bucket_reveal")
scripts/dev/full_pool1_reveal_probe.gd:183:	main.set("_bucket_reveal", capture)
scripts/dev/full_pool1_reveal_probe.gd:184:	await main._tutorial_play_unlock()
scripts/dev/full_pool1_reveal_probe.gd:194:	main.set("_bucket_reveal", saved_reveal)
scripts/dev/full_pool1_reveal_probe.gd:203:	var yes_like: Array = _ids_of(main._bucket_entries(1))
scripts/dev/full_pool1_reveal_probe.gd:205:	var skip_ids: Array = _ids_of(main._tutorial_unlock_entries())
scripts/dev/collection_a_notrun_cases.gd:310:	var saved_reveal = main.get("_bucket_reveal")
scripts/dev/collection_a_notrun_cases.gd:311:	main.set("_bucket_reveal", null)
scripts/dev/collection_a_notrun_cases.gd:371:	if main.get("_bucket_reveal") == null:
scripts/dev/collection_a_notrun_cases.gd:372:		main.set("_bucket_reveal", saved_reveal)
scripts/dev/tip_smoke_selftest.gd:201:	## Post-tutorial reveal is full Pool 1 via `_bucket_entries(1)` — not `_tut_seen` subtract.
scripts/dev/tip_smoke_selftest.gd:204:		"tutorial_unlock_uses_bucket_entries",
scripts/dev/tip_smoke_selftest.gd:205:		_source_func_calls("res://scripts/main.gd", "_tutorial_unlock_entries", "_bucket_entries")
scripts/dev/tip_smoke_selftest.gd:210:		_tutorial_unlock_entries_omits_tut_seen()
scripts/dev/tip_smoke_selftest.gd:759:	## Pool-1 reveal (`_tutorial_play_unlock`) must run before cabin music / arrive splash.
scripts/dev/tip_smoke_selftest.gd:766:	var unlock_i: int = body.find("_tutorial_play_unlock")
scripts/dev/tip_smoke_selftest.gd:779:func _tutorial_unlock_entries_omits_tut_seen() -> bool:
scripts/dev/tip_smoke_selftest.gd:780:	## Body must reuse `_bucket_entries` and must not filter on `_tut_seen`.
scripts/dev/tip_smoke_selftest.gd:782:	var start: int = src.find("func _tutorial_unlock_entries(")
scripts/dev/tip_smoke_selftest.gd:787:	if body.find("_bucket_entries(1)") < 0 and body.find("_bucket_entries (1)") < 0:
scripts/main.gd:32:const BUCKET_REVEAL := preload("res://scripts/bucket_reveal.gd")
scripts/main.gd:730:var _bucket_reveal
scripts/main.gd:1947:	_bucket_reveal = BUCKET_REVEAL.new()
scripts/main.gd:1948:	_bucket_reveal.sfx = sfx
scripts/main.gd:1949:	_bucket_reveal.card_hovered.connect(_on_unlock_card_hovered)
scripts/main.gd:1950:	_bucket_reveal.card_unhovered.connect(_on_unlock_card_unhovered)
scripts/main.gd:1951:	add_child(_bucket_reveal)
scripts/main.gd:2987:	await _reveal_new_buckets()
scripts/main.gd:3628:	await _reveal_new_buckets()
scripts/main.gd:4429:	await _reveal_new_buckets()
scripts/main.gd:5070:func _reveal_new_buckets() -> void:
scripts/main.gd:5084:		var entries: Array = _bucket_entries(b)
scripts/main.gd:5088:		if _bucket_reveal != null:
scripts/main.gd:5089:			await _bucket_reveal.play(b, entries)
scripts/main.gd:5102:func _bucket_entries(bucket_n: int) -> Array:
scripts/main.gd:26461:	var unlock_tip: bool = _unlock_screen and _bucket_reveal != null and _bucket_reveal.visible
scripts/main.gd:26492:		if _bucket_reveal._next != null:
scripts/main.gd:26493:			blocks.append(_bucket_reveal._next.get_global_rect())
scripts/main.gd:31000:func _tutorial_play_unlock() -> void:
scripts/main.gd:31001:	var entries: Array = _tutorial_unlock_entries()
scripts/main.gd:31002:	if entries.is_empty() or _bucket_reveal == null:
scripts/main.gd:31007:	await _bucket_reveal.play(0, entries)
scripts/main.gd:31015:func _tutorial_unlock_entries() -> Array:
scripts/main.gd:31018:	return _bucket_entries(1)
scripts/main.gd:31414:	await _tutorial_play_unlock()
```

## Lore / journal hover

```
tools/dev/README.md:31:  - in `data/player-copy.json`, `data/player-copy.additions.json` and `data/lore.json`, only the `text` / `entry` / `journal` / `body` / `title` / `engraving` values;
scripts/player_copy.gd:2:## Player-facing prose. Script editor Save writes player-copy.json, lore.json, script-names.json, and card wording on the board.
scripts/player_copy.gd:8:const LORE_PATH := "res://data/lore.json"
scripts/player_copy.gd:15:static var lore_pack: Dictionary = {}
scripts/player_copy.gd:24:	lore_pack = {}
scripts/player_copy.gd:52:	lore_pack = _read_dict(LORE_PATH)
scripts/player_copy.gd:369:	if lore_pack.is_empty():
scripts/player_copy.gd:372:	var engr: String = str(lore_pack.get("engraving", ""))
scripts/player_copy.gd:379:		"author_lock": bool(lore_pack.get("engraving_lock", false)),
scripts/player_copy.gd:381:	var items: Dictionary = lore_pack.get("items", {}) if typeof(lore_pack.get("items", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:402:	var monsters: Dictionary = lore_pack.get("monsters", {}) if typeof(lore_pack.get("monsters", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:412:	for letter in lore_pack.get("letters", []):
scripts/player_copy.gd:430:	var note: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:578:	if lore_pack.is_empty():
scripts/player_copy.gd:588:			lore_pack["engraving"] = t
scripts/player_copy.gd:591:			var dn: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:593:			lore_pack["drawer_note"] = dn
scripts/player_copy.gd:596:			var dn2: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:598:			lore_pack["drawer_note"] = dn2
scripts/player_copy.gd:603:			var items: Dictionary = lore_pack.get("items", {}) if typeof(lore_pack.get("items", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:615:			lore_pack["items"] = items
scripts/player_copy.gd:617:			var monsters: Dictionary = lore_pack.get("monsters", {}) if typeof(lore_pack.get("monsters", {})) == TYPE_DICTIONARY else {}
scripts/player_copy.gd:621:			lore_pack["monsters"] = monsters
scripts/player_copy.gd:623:			var letters: Array = lore_pack.get("letters", []) if typeof(lore_pack.get("letters", [])) == TYPE_ARRAY else []
scripts/player_copy.gd:635:			lore_pack["letters"] = letters
scripts/player_copy.gd:636:	lore_pack["updated"] = Time.get_date_string_from_system()
scripts/player_copy.gd:637:	return AUTHOR_LOCK.write_json(LORE_PATH, lore_pack)
tools/_migrate_script_names.py:1:# One-shot: tokenise proper names in player-copy.json and lore.json.
tools/_migrate_script_names.py:12:LORE_PATH = ROOT / "data" / "lore.json"
tools/script-desk-server.py:22:LORE_PATH = DATA / "lore.json"
tools/script-desk-server.py:695:            "data/lore.json",
tools/cabin/verify_cabin_package.py:30:lore = J(os.path.join(R, 'data/lore.json'))
tools/hooks/pre-commit:49:copy_json='data/player-copy.json data/player-copy.additions.json data/lore.json'
scripts/home_cabin.gd:2756:	_show_lore_panel(item_id, peg, peg_state)
scripts/home_cabin.gd:2760:	_hide_lore_panel()
scripts/home_cabin.gd:3042:	_hide_lore_panel()
scripts/home_cabin.gd:3094:	_hide_lore_panel()
scripts/home_cabin.gd:3097:func _show_lore_panel(item_id: String, peg: Control, peg_state: int) -> void:
scripts/home_cabin.gd:3098:	_hide_lore_panel()
scripts/home_cabin.gd:3146:		locked.text = COPY.text("cabin.tip.locked", "???")
scripts/home_cabin.gd:3177:			var lore_items: Variant = COPY.lore_pack.get("items", {}) if COPY.lore_pack else {}
scripts/home_cabin.gd:3195:			state_lab.text = COPY.text("cabin.hall.lore_claimed", "Claimed")
scripts/home_cabin.gd:3197:			state_lab.text = COPY.text("cabin.tip.seen", "Seen")
scripts/home_cabin.gd:3238:func _hide_lore_panel() -> void:
scripts/home_cabin.gd:4095:			show_hover_tag("cabin.tip.locked", wrap)
scripts/main.gd:1383:	lore = _load_json("res://data/lore.json")
scripts/main.gd:29538:		PLAYER_COPY.text("cabin.tip.seen", "Seen in {the_grumble}. Not home yet.")
```

## Nib placement / movement

```
data/cabin-layout.json:403:    "node": "Nib",
scenes/ui/title_screen.tscn:183:[node name="Nib" type="TextureRect" parent="Art"]
tools/dev/rebuild_tutorial_lines.py:66:		"nib": 0.0,
tools/dev/rebuild_tutorial_lines.py:101:		cur["nib"] = 0.85 if "80%" in low else 0.55
tools/dev/rebuild_tutorial_lines.py:103:		cur["nib"] = 0.0
tools/dev/rebuild_tutorial_lines.py:105:		cur["nib"] = 0.4
tools/dev/rebuild_tutorial_lines.py:229:			cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:239:				cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:244:			nib = float(cur.get("nib", nib) or 0)
tools/dev/rebuild_tutorial_lines.py:246:				cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:250:				cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:254:			cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:258:			cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:264:		cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:266:	cur["nib"] = nib
tools/dev/rebuild_tutorial_lines.py:327:			"nib": b.get("nib") or 0.0,
scripts/cabin/room_main.gd:27:	nib.name = "NibSprite"
scripts/cabin/room_main.gd:42:	var nib_hot = spots.get("Nib", null)
scripts/cabin/room_main.gd:114:		hotspot_activated.emit("Nib")
scripts/cabin/cabin_dialog.gd:423:		_sfx.speak(&"nib", _full)
scripts/cabin/cabin_dialog.gd:425:		cabin.nib_talk(true)
scripts/cabin/cabin_dialog.gd:471:		cabin.nib_talk(false)
scripts/cabin/map_piece_beat.gd:132:	if main_room == null or main_room.nib == null or main_room.nib.sprite_frames == null:
scripts/cabin/map_piece_beat.gd:134:	if main_room.nib.sprite_frames.has_animation(anim):
scripts/cabin/map_piece_beat.gd:135:		main_room.nib.play(anim)
tools/_migrate_script_names.py:151:                if "{nib}" in text and "Nib" in pat:
scripts/dev/collection_a_live_repot.gd:101:		main.home_cabin.key_ring_seen = true
scripts/dev/collection_a_live_repot.gd:615:	cabin.key_ring_seen = true
tools/script-desk-server.py:457:            "nib",
tools/script-desk-server.py:473:            elif extra == "nib":
scripts/script_editor.gd:13:	{"id": "nib", "label": "Nib"},
scripts/script_editor.gd:30:	"nib": Color("8a5a10"),
scripts/script_editor.gd:452:		"Nib":
scripts/script_editor.gd:453:			return "nib"
scripts/script_editor.gd:481:	if sec == "nib":
scripts/script_editor.gd:796:		"nib": 0.0,
scripts/tutorial_guide.gd:555:	nib_close = float(b.get("nib", 0.0))
scripts/tutorial_guide.gd:573:		sfx.speak(&"nib", spoken)
scripts/tutorial_guide.gd:577:	_name.text = COPY.text("tutorial.speaker", "Nib")
scripts/tutorial_guide.gd:1215:		"nib": 0.0,
scripts/tutorial_guide.gd:1257:				cur["nib"] = nib
scripts/tutorial_guide.gd:1262:			nib = float(cur.get("nib", nib))
scripts/tutorial_guide.gd:1264:				cur["nib"] = nib
scripts/tutorial_guide.gd:1268:				cur["nib"] = nib
scripts/tutorial_guide.gd:1272:			cur["nib"] = nib
scripts/tutorial_guide.gd:1280:		cur["nib"] = nib
scripts/tutorial_guide.gd:1282:	cur["nib"] = nib
scripts/tutorial_guide.gd:1317:		cur["nib"] = 0.85 if low.find("80%") >= 0 else 0.55
scripts/tutorial_guide.gd:1319:		cur["nib"] = 0.0
scripts/tutorial_guide.gd:1321:		cur["nib"] = 0.4
scripts/dev/house_unlock_first_return_selftest.gd:65:		"fresh hauls=0 key_ring_seen=false lifetime=0",
scripts/dev/house_unlock_first_return_selftest.gd:67:			and cabin.get("key_ring_seen") == false
scripts/dev/house_unlock_first_return_selftest.gd:70:			str(cabin.get("counters")), cabin.get("key_ring_seen"), cabin.get("lifetime_dungeons_cleared")
scripts/dev/house_unlock_first_return_selftest.gd:179:	cabin.set("key_ring_seen", false)
scripts/dev/house_unlock_first_return_selftest.gd:185:		"hauls>=1 recovers remaining rooms without needing key_ring_seen",
scripts/dev/house_unlock_first_return_selftest.gd:277:	cabin.set("key_ring_seen", true) ## skip key-ring await in headless
scripts/dev/house_unlock_first_return_selftest.gd:287:		want_pm == false ## key_ring_seen true → want_key false, but haul still bumps
tools/audio/cues.py:424:     "speech": {"nib": {"cue": "speech.nib", "chars_per_blip": 3, "burst_if_no_typewriter": [3, 6], "burst_interval_ms": [70, 110], "duck_music_db": -3},
scripts/cabin/cutscene_player.gd:332:			{"tex": "cutscenes/ending_p1.png", "lines": [{"key": "ending.p1", "nib": false}], "hold": 6.0, "fx": "glint", "motion": "pan_x", "sting": "cabin.ending_start"},
scripts/cabin/cutscene_player.gd:333:			{"tex": "cutscenes/ending_p2.png", "lines": [{"key": "ending.p2", "nib": false}], "hold": 6.0, "fx": "", "motion": "", "stamp": true},
scripts/cabin/cutscene_player.gd:334:			{"tex": "cutscenes/ending_p3.png", "lines": [{"key": "ending.p3", "nib": false}, {"key": "ending.p4", "nib": false}, {"key": "ending.nib", "nib": true}], "hold": 7.0, "fx": "deed",
scripts/cabin/cutscene_player.gd:338:			{"tex": "cutscenes/keyring_p1.png", "lines": [{"key": "keyring.1", "nib": true}, {"key": "keyring.2", "nib": true}], "hold": 8.0, "fx": "", "motion": ""},
scripts/cabin/cutscene_player.gd:343:			{"tex": "cutscenes/intro_p5.png", "lines": [{"key": "intro.p5_nib", "nib": true}], "hold": 6.0, "fx": "", "motion": ""},
scripts/cabin/cutscene_player.gd:346:		{"tex": "cutscenes/intro_p1.png", "anim": "cutscenes/intro_p1_candle", "lines": [{"key": "intro.p1", "nib": false}], "hold": 6.0, "fx": "rain_window", "motion": "push_in"},
scripts/cabin/cutscene_player.gd:347:		{"tex": "cutscenes/intro_p2.png", "lines": [{"key": "intro.p2", "nib": false}, {"key": "intro.p2_nib", "nib": true}], "hold": 6.0, "fx": "rain_full", "motion": "", "knock": true},
scripts/cabin/cutscene_player.gd:348:		{"tex": "cutscenes/intro_p3.png", "anim": "cutscenes/intro_p3_seal", "lines": [{"key": "intro.p3", "nib": false}, {"key": "intro.p3_nib", "nib": true}], "hold": 7.0, "fx": "", "moti
scripts/cabin/cutscene_player.gd:352:		panels.append({"tex": "cutscenes/intro_p4.png", "lines": [{"key": "intro.p4", "nib": false}], "hold": 5.0, "fx": "", "motion": "pan_x"})
scripts/cabin/cutscene_player.gd:353:		panels.append({"tex": "cutscenes/intro_p5.png", "lines": [{"key": "intro.p5_nib", "nib": true}], "hold": 6.0, "fx": "", "motion": ""})
scripts/cabin/cutscene_player.gd:483:	var is_nib: bool = bool(line.get("nib", false))
scripts/cabin/cutscene_player.gd:490:			cabin.sfx.speak(&"nib", _full)
scripts/player_copy.gd:291:			"nib": float(row.get("nib", 0.0)),
scripts/player_copy.gd:549:		for extra in ["dir", "wait", "focus", "hint", "go", "branch", "force", "then_focus", "nib", "tiny"]:
scripts/cabin/cabin_room.gd:190:		"Nib": "cabin.hot.nib",
scripts/dev/shot_harness.gd:251:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:354:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:410:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:438:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:560:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:1266:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:1478:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:1594:	cabin.key_ring_seen = false
scripts/dev/shot_harness.gd:1600:	kick.timeout.connect(cabin.play_key_ring, CONNECT_ONE_SHOT)
scripts/dev/shot_harness.gd:1615:	await _capture(filename, "play_key_ring(), abort the panel, wait for doors/side_door_unlock while Nib is at the hall door")
scripts/dev/shot_harness.gd:1893:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:3233:	cabin.key_ring_seen = true
scripts/dev/shot_harness.gd:3308:	cabin.key_ring_seen = true
tools/_board_dump.json:5009:        "text": "Nib",
scripts/playtest_intro.gd:150:		sfx.speak(&"nib", raw)
scripts/audio_fx.gd:689:	if String(kind) == "nib":
scripts/dev/cabin_nav_lock_probe.gd:130:	cabin.key_ring_seen = true
scripts/dev/cabin_nav_lock_probe.gd:495:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:501:	cabin.play_key_ring()
scripts/dev/cabin_nav_lock_probe.gd:516:		if not cabin.key_ring_seen and cabin._beat != "keyring" and not cabin._room_busy and _i > 60:
scripts/dev/cabin_nav_lock_probe.gd:564:		if cabin.key_ring_seen and cabin._room_busy == false:
scripts/dev/cabin_nav_lock_probe.gd:571:		cabin._room_busy == false and cabin.key_ring_seen == true
scripts/dev/cabin_nav_lock_probe.gd:616:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:622:	cabin.play_key_ring()
scripts/dev/cabin_nav_lock_probe.gd:647:		if cabin.key_ring_seen:
scripts/dev/cabin_nav_lock_probe.gd:700:		if cabin.key_ring_seen and cabin._room_busy == false:
scripts/dev/cabin_nav_lock_probe.gd:707:		cabin._room_busy == false and cabin._pan_busy == false and cabin.key_ring_seen
scripts/dev/cabin_nav_lock_probe.gd:773:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:797:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:869:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:962:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:1015:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:1022:	cabin.play_key_ring()
scripts/dev/cabin_nav_lock_probe.gd:1031:	cabin.key_ring_seen = false
scripts/dev/cabin_nav_lock_probe.gd:1054:		cabin.key_ring_seen == false
scripts/dev/cabin_nav_lock_probe.gd:1064:		cabin._room_busy == true and cabin.key_ring_seen == false
scripts/dev/collection_a_notrun_cases.gd:89:		main.home_cabin.key_ring_seen = true
scripts/home_cabin.gd:61:var key_ring_seen: bool = false
scripts/home_cabin.gd:228:## Owns in-flight play_key_ring across awaits/finalizer (separate from arrive).
scripts/home_cabin.gd:688:		return int(counters.hauls) >= 1 and not key_ring_seen
scripts/home_cabin.gd:950:		await play_key_ring()
scripts/home_cabin.gd:981:		await play_key_ring()
scripts/home_cabin.gd:1135:func play_key_ring() -> void:
scripts/home_cabin.gd:1136:	if key_ring_seen:
scripts/home_cabin.gd:1151:	var nib = main_room.nib if main_room else null
scripts/home_cabin.gd:1160:	if not await _move_nib_x(120.0, 0.6, gen):
scripts/home_cabin.gd:1162:	if not await _move_nib_x(216.0, 0.6, gen):
scripts/home_cabin.gd:1183:	if not await _move_nib_x(352.0, 1.0, gen):
scripts/home_cabin.gd:1247:	if not await _move_nib_x(216.0, 0.6, gen):
scripts/home_cabin.gd:1258:	## Finalizer: stale generation must not clear B's lock or stamp key_ring_seen.
scripts/home_cabin.gd:1261:	key_ring_seen = true
scripts/home_cabin.gd:1281:## Gen mismatch = stale resume after hide/show_menu/newer play_key_ring — no lock clears.
scripts/home_cabin.gd:1414:	if not key_ring_seen and hauls < 1:
scripts/home_cabin.gd:1430:	key_ring_seen = true
scripts/home_cabin.gd:1935:			await play_key_ring()
scripts/home_cabin.gd:4345:	key_ring_seen = false
scripts/home_cabin.gd:4409:	key_ring_seen = bool(parsed.get("key_ring_seen", false))
scripts/home_cabin.gd:4476:	data["key_ring_seen"] = key_ring_seen
scripts/home_cabin.gd:4643:			key_ring_seen = false
scripts/home_cabin.gd:4646:			play_key_ring()
scripts/home_cabin.gd:4926:	key_ring_seen = true
scripts/home_cabin.gd:4986:	key_ring_seen = true
scripts/home_cabin.gd:5392:func _move_nib_x(x_native: float, dur: float, owner_gen: int) -> bool:
scripts/home_cabin.gd:5400:	var nib = main_room.nib
scripts/home_cabin.gd:5401:	var hs = main_room.spots.get("Nib", null)
scripts/home_cabin.gd:5582:func nib_talk(on: bool) -> void:
scripts/home_cabin.gd:5584:	if main_room and main_room.nib and main_room.nib.sprite_frames:
scripts/home_cabin.gd:5585:		main_room.nib.play("talk" if on else ("psst" if _gate_on() else "idle"))
scripts/home_cabin.gd:5633:## Clears only in-flight interaction locks. Does not touch key_ring_seen,
scripts/home_cabin.gd:5672:	if _busy() and node_name != "Nib" and not (node_name == "RunDoor" and _gate_on()):
scripts/home_cabin.gd:5691:		"Nib":
scripts/dev/homecoming_live_repot.gd:74:	cabin.key_ring_seen = true
scripts/dev/homecoming_live_repot.gd:381:	cabin.key_ring_seen = true
```

## Room order / rooms_unlocked / navigation

```
data/cabin-layout.json:1254:  "room_order": [
scripts/ui/arrow_glyphs.gd:185:	return _arrow(false, true)
scripts/ui/arrow_glyphs.gd:189:	return _arrow(true, false)
scripts/ui/arrow_glyphs.gd:193:	return _arrow(true, true)
scripts/ui/arrow_glyphs.gd:196:static func _arrow(left_head: bool, right_head: bool) -> Array:
scripts/dev/house_unlock_first_return_selftest.gd:10:##   - interrupted recovery: hauls>=1 + partial rooms → _sync_progress_doors fills rest
scripts/dev/house_unlock_first_return_selftest.gd:61:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:94:	cabin.call("_sync_progress_doors")
scripts/dev/house_unlock_first_return_selftest.gd:99:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:121:	cabin.call("_sync_progress_doors")
scripts/dev/house_unlock_first_return_selftest.gd:126:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:147:			want_0, cabin.get("counters").get("hauls", -1), str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:153:		cabin.get("rooms_unlocked").has("hall")
scripts/dev/house_unlock_first_return_selftest.gd:154:			and cabin.get("rooms_unlocked").has("study")
scripts/dev/house_unlock_first_return_selftest.gd:155:			and cabin.get("rooms_unlocked").has("workshop")
scripts/dev/house_unlock_first_return_selftest.gd:156:			and cabin.get("rooms_unlocked").has("loft")
scripts/dev/house_unlock_first_return_selftest.gd:157:			and cabin.get("rooms_unlocked").has("mudroom"),
scripts/dev/house_unlock_first_return_selftest.gd:158:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:180:	cabin.set("rooms_unlocked", ["main", "hall"])
scripts/dev/house_unlock_first_return_selftest.gd:182:	cabin.call("_sync_progress_doors")
scripts/dev/house_unlock_first_return_selftest.gd:186:		cabin.get("rooms_unlocked").has("study")
scripts/dev/house_unlock_first_return_selftest.gd:187:			and cabin.get("rooms_unlocked").has("workshop")
scripts/dev/house_unlock_first_return_selftest.gd:188:			and cabin.get("rooms_unlocked").has("loft")
scripts/dev/house_unlock_first_return_selftest.gd:189:			and cabin.get("rooms_unlocked").has("mudroom"),
scripts/dev/house_unlock_first_return_selftest.gd:190:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:291:	cabin.call("_sync_progress_doors")
scripts/dev/house_unlock_first_return_selftest.gd:295:		cabin.get("rooms_unlocked").has("hall"),
scripts/dev/house_unlock_first_return_selftest.gd:296:		"rooms=%s" % str(cabin.get("rooms_unlocked"))
scripts/dev/house_unlock_first_return_selftest.gd:332:	var got: Array = cabin.get("rooms_unlocked")
scripts/dev/shot_harness.gd:1481:		if not cabin.rooms_unlocked.has(r):
scripts/dev/shot_harness.gd:1482:			cabin.rooms_unlocked.append(r)
scripts/dev/shot_harness.gd:1595:	cabin.rooms_unlocked = ["main"]
scripts/dev/shot_harness.gd:3235:	if not cabin.rooms_unlocked.has("loft"):
scripts/dev/shot_harness.gd:3236:		cabin.rooms_unlocked.append("loft")
scripts/dev/shot_harness.gd:3237:	if not cabin.rooms_unlocked.has("study"):
scripts/dev/shot_harness.gd:3238:		cabin.rooms_unlocked.append("study")
scripts/dev/shot_harness.gd:3314:		if not cabin.rooms_unlocked.has(r):
scripts/dev/shot_harness.gd:3315:			cabin.rooms_unlocked.append(r)
scripts/cabin/cabin_kit.gd:21:const ROOM_ORDER: Array[String] = ["loft", "workshop", "study", "main", "hall", "mudroom"]
scripts/cabin/cabin_kit.gd:600:	return ROOM_ORDER.find(id)
scripts/dev/cabin_nav_lock_probe.gd:133:	cabin._sync_progress_doors()
scripts/dev/cabin_nav_lock_probe.gd:313:	cabin.rooms_unlocked = ["main", "hall", "mudroom", "study"]
scripts/dev/cabin_nav_lock_probe.gd:496:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:617:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:641:			and cabin.rooms_unlocked.has("study")
scripts/dev/cabin_nav_lock_probe.gd:642:			and not cabin.rooms_unlocked.has("workshop")
scripts/dev/cabin_nav_lock_probe.gd:653:			% [cabin._beat, cabin._nested_phase, str(cabin.rooms_unlocked)]
scripts/dev/cabin_nav_lock_probe.gd:712:		cabin.rooms_unlocked.has("workshop")
scripts/dev/cabin_nav_lock_probe.gd:774:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:798:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:803:	var rooms_b: Array = cabin.rooms_unlocked.duplicate()
scripts/dev/cabin_nav_lock_probe.gd:825:		not cabin.rooms_unlocked.has("hall") and not cabin.rooms_unlocked.has("mudroom")
scripts/dev/cabin_nav_lock_probe.gd:830:		cabin.rooms_unlocked.hash() == rooms_b.hash()
scripts/dev/cabin_nav_lock_probe.gd:871:	cabin.rooms_unlocked = ["main", "hall", "mudroom"]
scripts/dev/cabin_nav_lock_probe.gd:1016:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:1032:	cabin.rooms_unlocked = ["main"]
scripts/dev/cabin_nav_lock_probe.gd:1036:	var rooms_b: Array = cabin.rooms_unlocked.duplicate()
scripts/dev/cabin_nav_lock_probe.gd:1049:		cabin.rooms_unlocked.hash() == rooms_b.hash()
scripts/dev/cabin_nav_lock_probe.gd:1069:		cabin.rooms_unlocked.hash() == rooms_b.hash()
scripts/dev/cabin_nav_lock_probe.gd:1097:		"push_block_rooms_unlocked",
scripts/home_cabin.gd:38:const ROOM_ORDER: Array[String] = ["loft", "workshop", "study", "main", "hall", "mudroom"]
scripts/home_cabin.gd:59:var rooms_unlocked: Array = ["main"]
scripts/home_cabin.gd:687:		_sync_progress_doors()
scripts/home_cabin.gd:714:	return rooms_unlocked.has(id)
scripts/home_cabin.gd:859:	_sync_progress_doors()
scripts/home_cabin.gd:1412:func _sync_progress_doors() -> void:
scripts/home_cabin.gd:1417:	for id in ROOM_ORDER:
scripts/home_cabin.gd:1418:		if not rooms_unlocked.has(id):
scripts/home_cabin.gd:1419:			rooms_unlocked.append(id)
scripts/home_cabin.gd:1427:	for id in ROOM_ORDER:
scripts/home_cabin.gd:1428:		if not rooms_unlocked.has(id):
scripts/home_cabin.gd:1429:			rooms_unlocked.append(id)
scripts/home_cabin.gd:1593:	_rooms_host.size = Vector2(ROOM_W * float(ROOM_ORDER.size()), 1040.0)
scripts/home_cabin.gd:2433:	_arrow(delta)
scripts/home_cabin.gd:4344:	rooms_unlocked = ["main"]
scripts/home_cabin.gd:4394:	rooms_unlocked = []
scripts/home_cabin.gd:4395:	for r in parsed.get("rooms_unlocked", ["main"]):
scripts/home_cabin.gd:4396:		rooms_unlocked.append(str(r))
scripts/home_cabin.gd:4397:	if rooms_unlocked.is_empty():
scripts/home_cabin.gd:4398:		rooms_unlocked = ["main"]
scripts/home_cabin.gd:4400:	if rooms_unlocked.has("mudroom") and not rooms_unlocked.has("hall"):
scripts/home_cabin.gd:4401:		rooms_unlocked.append("hall")
scripts/home_cabin.gd:4402:	if rooms_unlocked.has("hall") and not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:4403:		rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:4457:	_sync_progress_doors()
scripts/home_cabin.gd:4474:	data["rooms_unlocked"] = rooms_unlocked
scripts/home_cabin.gd:4543:		"rooms_unlocked": rooms_unlocked,
scripts/home_cabin.gd:4644:			rooms_unlocked = ["main"]
scripts/home_cabin.gd:4669:				if not rooms_unlocked.has("hall"):
scripts/home_cabin.gd:4670:					rooms_unlocked.append("hall")
scripts/home_cabin.gd:4671:				rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:4817:			_arrow(-1)
scripts/home_cabin.gd:4822:			_arrow(1)
scripts/home_cabin.gd:4963:	_sync_progress_doors()
scripts/home_cabin.gd:4994:	for id in ROOM_ORDER:
scripts/home_cabin.gd:4995:		if not rooms_unlocked.has(id):
scripts/home_cabin.gd:4996:			rooms_unlocked.append(id)
scripts/home_cabin.gd:5029:func _arrow(delta: int) -> void:
scripts/home_cabin.gd:5034:	var i: int = ROOM_ORDER.find(_current_room)
scripts/home_cabin.gd:5036:	if nxt < 0 or nxt >= ROOM_ORDER.size():
scripts/home_cabin.gd:5039:	var dest: String = ROOM_ORDER[nxt]
scripts/home_cabin.gd:5058:	for i in ROOM_ORDER.size():
scripts/home_cabin.gd:5059:		var id: String = ROOM_ORDER[i]
scripts/home_cabin.gd:5278:		_rooms_host.size = Vector2(ROOM_W * float(ROOM_ORDER.size()), ROOM_H)
scripts/home_cabin.gd:5284:	var i: int = ROOM_ORDER.find(room)
scripts/home_cabin.gd:5298:	_sync_progress_doors()
scripts/home_cabin.gd:5305:	var i: int = ROOM_ORDER.find(room)
scripts/home_cabin.gd:5353:		if not rooms_unlocked.has(room):
scripts/home_cabin.gd:5354:			rooms_unlocked.append(room)
scripts/home_cabin.gd:5357:	var i: int = ROOM_ORDER.find(room)
scripts/home_cabin.gd:5479:	if not rooms_unlocked.has(unlock_room):
scripts/home_cabin.gd:5480:		rooms_unlocked.append(unlock_room)
scripts/home_cabin.gd:5482:	if unlock_room == "hall" and not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:5483:		rooms_unlocked.append("mudroom")
scripts/home_cabin.gd:5634:## rooms_unlocked, hauls, bank ledger, bank_pending, or dialog content.
scripts/home_cabin.gd:5984:			_unlock_mudroom_with_hall()
scripts/home_cabin.gd:6018:func _unlock_mudroom_with_hall() -> void:
scripts/home_cabin.gd:6021:	if not rooms_unlocked.has("mudroom"):
scripts/home_cabin.gd:6022:		rooms_unlocked.append("mudroom")
tools/qa/check_sp_p0_remaining.py:143:if "func _sync_progress_doors" not in cabin or "invert_scroll" not in cabin:
```
