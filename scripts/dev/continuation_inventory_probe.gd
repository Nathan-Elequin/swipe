extends SceneTree
## P4 continuation inventory / reroll proof — bounded integration probe (sandbox only).
##
## Proves Design B/C same-run Push: active run index increments; remaining hotbar
## UID identities survive Push; used/dropped UIDs stay absent; bank ledger unchanged
## on Push; no begin_run/_reset_run on Push; delve reroll grants once per dungeon
## (unused carries + map-piece bonus); six-per-delve grant remains on the Push path;
## no free Push when BANKED cabinet is under quota even if projected haul would
## hit 5; death/abort after Push banks nothing.
##
## Does not rebalance or remove replenishment.
## Run via: ./tools/qa/run_continuation_inventory_probe.sh

const MAIN_SCENE := "res://scenes/main.tscn"
const Shell = preload("res://scripts/campaign_shell.gd")


func _initialize() -> void:
	var failed := false
	if not _sandbox_ok():
		print("REFUSED_UNSAFE_DIRECT_USERDATA path=%s" % OS.get_user_data_dir())
		push_error(
			"CONTINUATION_INVENTORY_PROBE_FAIL refuse: user data '%s' is not a P4 sandbox. "
			% OS.get_user_data_dir()
			+ "Run tools/qa/run_continuation_inventory_probe.sh (sets XDG_DATA_HOME)."
		)
		quit(1)
		return
	print("PROBE_USER_DATA=", OS.get_user_data_dir())
	print("SANDBOX_GUARD_OK")

	failed = _source_contracts() or failed
	failed = _shell_push_index_and_bank() or failed
	failed = _shell_reroll_carry_and_once() or failed
	failed = _shell_no_free_push_under_banked_quota() or failed
	failed = _shell_death_after_push_banks_nothing() or failed

	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		push_error("CONTINUATION_INVENTORY_PROBE_FAIL change_scene err=%s" % err)
		quit(1)
		return

	var main: Node = null
	var tries := 0
	while tries < 300:
		await process_frame
		tries += 1
		main = root.get_node_or_null("Main")
		if main != null and ("_campaign" in main) and main._campaign != null:
			break
	if main == null or main._campaign == null:
		push_error("CONTINUATION_INVENTORY_PROBE_FAIL campaign missing after main boot")
		quit(1)
		return

	_quiet_playtest_chrome(main)
	await process_frame

	failed = await _case_inventory_uids_survive_push(main) or failed
	failed = await _case_death_abort_after_push_no_bank(main) or failed

	if failed:
		push_error("CONTINUATION_INVENTORY_PROBE_FAIL")
		print("CONTINUATION_INVENTORY_PROBE_FAIL")
		quit(1)
	else:
		print("CONTINUATION_INVENTORY_PROBE_OK")
		quit(0)


func _sandbox_ok() -> bool:
	var path := OS.get_user_data_dir()
	return path.find("continuation-inventory") >= 0 or path.find("p4-continuation") >= 0


func _quiet_playtest_chrome(main: Node) -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		if key in main and main.get(key) != null:
			var n: Variant = main.get(key)
			if n is CanvasItem:
				(n as CanvasItem).visible = false
	if "phase" in main:
		main.phase = "cabin"


func _source_contracts() -> bool:
	var failed := false
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")

	var push_idx: int = src.find("func _adventure_continue")
	var push_end: int = src.find("\nfunc ", push_idx + 1)
	var push_body: String = src.substr(push_idx, maxi(0, push_end - push_idx))
	failed = _check(failed, "source_push_uses_push_deeper", push_body.find("push_deeper") >= 0) or failed
	failed = _check(failed, "source_push_grants_delve_reroll", push_body.find("grant_delve_reroll") >= 0) or failed
	failed = _check(
		failed,
		"source_push_no_begin_run",
		push_body.find("begin_run") < 0 and push_body.find("_begin_run") < 0
	) or failed
	failed = _check(failed, "source_push_no_reset_run", push_body.find("_reset_run") < 0) or failed
	failed = _check(
		failed,
		"source_push_arms_challenge_setup",
		push_body.find("_run_challenge_setup") >= 0
	) or failed

	var prep_idx: int = src.find("func _prep_next_dungeon")
	var prep_end: int = src.find("\nfunc ", prep_idx + 1)
	var prep_body: String = src.substr(prep_idx, maxi(0, prep_end - prep_idx))
	failed = _check(failed, "source_prep_keeps_hotbar", prep_body.find("hotbar.clear") < 0) or failed
	failed = _check(failed, "source_prep_no_reset_run", prep_body.find("_reset_run") < 0) or failed

	var setup_idx: int = src.find("func _run_challenge_setup")
	var setup_end: int = src.find("\nfunc ", setup_idx + 1)
	var setup_body: String = src.substr(setup_idx, maxi(0, setup_end - setup_idx))
	failed = _check(
		failed,
		"source_setup_grants_starter_six_on_campaign",
		setup_body.find("_campaign_grant_starter_six") >= 0
	) or failed

	var loss_idx: int = src.find("func _go_home_loss")
	var loss_end: int = src.find("\nfunc ", loss_idx + 1)
	var loss_body: String = src.substr(loss_idx, maxi(0, loss_end - loss_idx))
	failed = _check(failed, "source_loss_calls_abort", loss_body.find("_campaign_abort") >= 0) or failed
	failed = _check(
		failed,
		"source_loss_no_bank_from_hand",
		loss_body.find("_campaign_bank_from_hand") < 0
	) or failed

	var abort_idx: int = src.find("func _campaign_abort")
	var abort_end: int = src.find("\nfunc ", abort_idx + 1)
	var abort_body: String = src.substr(abort_idx, maxi(0, abort_end - abort_idx))
	failed = _check(failed, "source_abort_ends_run", abort_body.find("end_run") >= 0) or failed
	failed = _check(failed, "source_abort_no_bank", abort_body.find(".bank(") < 0) or failed

	var shell_src := FileAccess.get_file_as_string("res://scripts/campaign_shell.gd")
	var grant_idx: int = shell_src.find("static func grant_delve_reroll")
	var grant_end: int = shell_src.find("\nstatic func ", grant_idx + 1)
	var grant_body: String = shell_src.substr(grant_idx, maxi(0, grant_end - grant_idx))
	failed = _check(
		failed,
		"source_grant_once_via_delve_granted",
		grant_body.find("delve_granted") >= 0
	) or failed
	failed = _check(
		failed,
		"source_push_deeper_clears_delve_granted",
		shell_src.find("run[\"delve_granted\"] = false") >= 0
		or shell_src.find("run['delve_granted'] = false") >= 0
	) or failed
	return failed


func _fill_pool(rules: Dictionary, state: Dictionary, pool: String, n: int) -> void:
	var ids: Array = []
	var pools := {}
	for i in n:
		var id := "%s_p4_%d" % [pool, i]
		ids.append(id)
		pools[id] = pool
	Shell.bank(rules, state, ids, pools)


func _bank_fingerprint(state: Dictionary) -> Dictionary:
	var banked: Dictionary = state.get("banked", {})
	var keys: Array = banked.keys()
	keys.sort()
	var pairs: Array = []
	for k in keys:
		pairs.append("%s=%s" % [str(k), str(banked[k])])
	return {"n": keys.size(), "sig": "|".join(pairs)}


func _shell_push_index_and_bank() -> bool:
	var failed := false
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var state: Dictionary = Shell.fresh_state()
	_fill_pool(rules, state, "b1", 5)
	_fill_pool(rules, state, "b2", 5)
	Shell.begin_run(state, 0, false, false)
	var before := _bank_fingerprint(state)
	failed = _check(failed, "shell_can_push_d1_to_d2", Shell.can_push(rules, state)) or failed
	failed = _check(failed, "shell_push_d1_to_d2", Shell.push_deeper(rules, state)) or failed
	failed = _check(
		failed,
		"shell_active_index_increments_d2",
		int(state["run"]["biome_index"]) == 1 and bool(state["run"]["active"])
	) or failed
	var after := _bank_fingerprint(state)
	failed = _check(
		failed,
		"shell_bank_unchanged_on_push_d1d2",
		int(after["n"]) == int(before["n"]) and str(after["sig"]) == str(before["sig"])
	) or failed
	failed = _check(failed, "shell_can_push_d2_to_d3", Shell.can_push(rules, state)) or failed
	failed = _check(failed, "shell_push_d2_to_d3", Shell.push_deeper(rules, state)) or failed
	failed = _check(
		failed,
		"shell_active_index_increments_d3",
		int(state["run"]["biome_index"]) == 2
	) or failed
	var after2 := _bank_fingerprint(state)
	failed = _check(
		failed,
		"shell_bank_unchanged_on_push_d2d3",
		int(after2["n"]) == int(before["n"]) and str(after2["sig"]) == str(before["sig"])
	) or failed
	failed = _check(
		failed,
		"shell_push_no_begin_run_side_effect",
		bool(state["run"]["active"]) and not bool(state["run"].get("shortcut", true))
	) or failed
	Shell.end_run(state)
	return failed


func _shell_reroll_carry_and_once() -> bool:
	var failed := false
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var state: Dictionary = Shell.fresh_state()
	_fill_pool(rules, state, "b1", 5)
	Shell.stamp_map_piece(rules, state, "b1")
	Shell.begin_run(state, 0, false, false)
	Shell.grant_delve_reroll(rules, state)
	var after_first: int = int(state["run"]["rerolls"])
	## Base 1 + 1 per map piece (default rules).
	var want_first: int = 1 + Shell.map_piece_count(state) * int(rules.get("rerolls_per_map_piece", 1))
	failed = _check(failed, "shell_grant_first_delve_with_piece", after_first == want_first) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(
		failed,
		"shell_grant_exactly_once_same_dungeon",
		int(state["run"]["rerolls"]) == after_first
	) or failed
	## Spend none — unused carries through Push.
	failed = _check(failed, "shell_push_for_reroll_carry", Shell.push_deeper(rules, state)) or failed
	failed = _check(
		failed,
		"shell_unused_reroll_carries_across_push",
		int(state["run"]["rerolls"]) == after_first
	) or failed
	failed = _check(
		failed,
		"shell_delve_granted_reset_on_push",
		bool(state["run"].get("delve_granted", true)) == false
	) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(
		failed,
		"shell_next_dungeon_adds_another_grant",
		int(state["run"]["rerolls"]) == after_first + want_first
	) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(
		failed,
		"shell_second_dungeon_still_once",
		int(state["run"]["rerolls"]) == after_first + want_first
	) or failed
	Shell.end_run(state)
	return failed


func _shell_no_free_push_under_banked_quota() -> bool:
	var failed := false
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var state: Dictionary = Shell.fresh_state()
	## BANKED 4 — under quota 5.
	_fill_pool(rules, state, "b1", 4)
	Shell.begin_run(state, 0, false, false)
	var haul: Array = ["b1_p4_0", "b1_haul_a", "b1_haul_b", "b1_haul_c", "b1_haul_d"]
	var pools := {
		"b1_p4_0": "b1",
		"b1_haul_a": "b1",
		"b1_haul_b": "b1",
		"b1_haul_c": "b1",
		"b1_haul_d": "b1",
	}
	var projected: int = Shell.project_cabinet_count(state, "b1", haul, pools)
	failed = _check(failed, "shell_projected_haul_reaches_quota", projected >= Shell.quota_of(rules)) or failed
	failed = _check(
		failed,
		"shell_banked_still_under_quota",
		Shell.cabinet_count(state, "b1") < Shell.quota_of(rules)
	) or failed
	failed = _check(
		failed,
		"shell_no_free_push_under_banked_despite_projected_haul5",
		not Shell.can_push(rules, state)
	) or failed
	failed = _check(
		failed,
		"shell_push_deeper_refuses_under_banked",
		not Shell.push_deeper(rules, state)
	) or failed
	failed = _check(
		failed,
		"shell_index_stuck_when_push_refused",
		int(state["run"]["biome_index"]) == 0
	) or failed
	## Fill BANKED to quota → Push opens (destination unlock), still distinct from haul.
	Shell.bank(rules, state, ["b1_p4_fill"], {"b1_p4_fill": "b1"})
	failed = _check(
		failed,
		"shell_push_opens_only_when_banked_hits_quota",
		Shell.cabinet_count(state, "b1") >= Shell.quota_of(rules) and Shell.can_push(rules, state)
	) or failed
	Shell.end_run(state)
	return failed


func _shell_death_after_push_banks_nothing() -> bool:
	var failed := false
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var state: Dictionary = Shell.fresh_state()
	_fill_pool(rules, state, "b1", 5)
	Shell.begin_run(state, 0, false, false)
	Shell.push_deeper(rules, state)
	var before := _bank_fingerprint(state)
	## Death / limp-home path: end_run without bank().
	Shell.end_run(state)
	var after := _bank_fingerprint(state)
	failed = _check(
		failed,
		"shell_death_after_push_bank_unchanged",
		int(after["n"]) == int(before["n"]) and str(after["sig"]) == str(before["sig"])
	) or failed
	failed = _check(
		failed,
		"shell_death_after_push_run_idle",
		not bool(state["run"].get("active", true))
	) or failed
	return failed


func _hotbar_uids(main: Node) -> Array:
	var out: Array = []
	for it in main.hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		out.append(int(it.get("uid", -1)))
	out.sort()
	return out


func _pick_item_ids(main: Node, n: int) -> Array:
	var out: Array = []
	for id in main.items_by_id.keys():
		var sid := str(id)
		if sid == "" or sid == "smoke_bomb":
			continue
		out.append(sid)
		if out.size() >= n:
			break
	return out


func _case_inventory_uids_survive_push(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	_fill_pool(main._campaign.rules, main._campaign.state, "b1", 5)
	_fill_pool(main._campaign.rules, main._campaign.state, "b2", 5)
	Shell.begin_run(main._campaign.state, 0, false, false)
	Shell.grant_delve_reroll(main._campaign.rules, main._campaign.state)
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main.dungeon_index = 1
	main.hotbar.clear()
	main.uid_seq = 100
	var ids: Array = _pick_item_ids(main, 4)
	failed = _check(failed, "main_enough_catalog_items", ids.size() >= 4) or failed
	if ids.size() < 4:
		return true
	for iid in ids:
		main.hotbar.append(main._make_item(str(iid)))
	## Drop / use the last UID before Push — must stay absent after.
	var dropped_uid: int = int(main.hotbar[main.hotbar.size() - 1].get("uid", -1))
	main.hotbar.pop_back()
	var kept_before: Array = _hotbar_uids(main)
	failed = _check(failed, "main_dropped_absent_before_push", not kept_before.has(dropped_uid)) or failed
	failed = _check(failed, "main_kept_three_before_push", kept_before.size() == 3) or failed
	var bank_before := _bank_fingerprint(main._campaign.state)
	var rerolls_before: int = int(main._campaign.state["run"]["rerolls"])
	var index_before: int = int(main._campaign.state["run"]["biome_index"])

	## Same shell ops `_adventure_continue` runs before splash / prep / six-grant.
	failed = _check(
		failed,
		"main_push_deeper_ok",
		Shell.push_deeper(main._campaign.rules, main._campaign.state)
	) or failed
	Shell.grant_delve_reroll(main._campaign.rules, main._campaign.state)
	failed = _check(
		failed,
		"main_active_index_incremented",
		int(main._campaign.state["run"]["biome_index"]) == index_before + 1
	) or failed
	failed = _check(
		failed,
		"main_unused_reroll_carried_plus_grant",
		int(main._campaign.state["run"]["rerolls"]) == rerolls_before + 1
	) or failed
	var bank_mid := _bank_fingerprint(main._campaign.state)
	failed = _check(
		failed,
		"main_bank_unchanged_mid_push",
		int(bank_mid["n"]) == int(bank_before["n"]) and str(bank_mid["sig"]) == str(bank_before["sig"])
	) or failed

	## Prep next dungeon must keep remaining identities (no hotbar.clear).
	main.dungeon_index += 1
	main._prep_next_dungeon()
	await process_frame
	var kept_after_prep: Array = _hotbar_uids(main)
	failed = _check(
		failed,
		"main_inventory_uids_survive_prep_after_push",
		kept_after_prep == kept_before
	) or failed
	failed = _check(
		failed,
		"main_dropped_still_absent_after_push",
		not kept_after_prep.has(dropped_uid)
	) or failed

	## Existing six-per-delve added separately — append without wiping carried UIDs.
	var before_six: Array = kept_after_prep.duplicate()
	## Force sync grant path used by QA / autopilot (no deal animation).
	if main.logic_qa == null:
		## Headless builds may lack logic_qa; inject the six directly as the grant does.
		var tiers: Array = Shell.starter_tiers(main._campaign.rules, main.rng)
		var added := 0
		for raw_t in tiers:
			var t: int = int(raw_t)
			var iid2: String = ""
			for cand in main.items_by_id.keys():
				var c: Dictionary = main.items_by_id[cand]
				if int(c.get("tier", 0)) == t and str(cand) != "smoke_bomb":
					iid2 = str(cand)
					break
			if iid2 == "":
				continue
			main.hotbar.append(main._make_item(iid2))
			added += 1
		failed = _check(failed, "main_six_grant_simulated", added == 6) or failed
	else:
		main.logic_qa.busy = true
		await main._campaign_grant_starter_six()
		main.logic_qa.busy = false
	var after_six: Array = _hotbar_uids(main)
	failed = _check(
		failed,
		"main_carried_uids_still_present_after_six",
		_subset_uids(before_six, after_six)
	) or failed
	failed = _check(
		failed,
		"main_six_added_separately",
		after_six.size() == before_six.size() + 6
	) or failed

	var bank_after := _bank_fingerprint(main._campaign.state)
	failed = _check(
		failed,
		"main_bank_still_unchanged_after_inventory_push",
		int(bank_after["n"]) == int(bank_before["n"]) and str(bank_after["sig"]) == str(bank_before["sig"])
	) or failed

	## D2→D3 second Push keeps the enlarged hand identities.
	var mid_uids: Array = _hotbar_uids(main)
	failed = _check(
		failed,
		"main_second_push_ok",
		Shell.push_deeper(main._campaign.rules, main._campaign.state)
	) or failed
	main.dungeon_index += 1
	main._prep_next_dungeon()
	await process_frame
	failed = _check(
		failed,
		"main_d2_d3_uids_survive",
		_hotbar_uids(main) == mid_uids
	) or failed
	failed = _check(
		failed,
		"main_active_index_d3",
		int(main._campaign.state["run"]["biome_index"]) == 2
	) or failed

	Shell.end_run(main._campaign.state)
	main._campaign_on = false
	main.hotbar.clear()
	return failed


func _case_death_abort_after_push_no_bank(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	_fill_pool(main._campaign.rules, main._campaign.state, "b1", 5)
	Shell.begin_run(main._campaign.state, 0, false, false)
	Shell.push_deeper(main._campaign.rules, main._campaign.state)
	main._campaign_on = true
	main.adventure = true
	main.hotbar.clear()
	var ids: Array = _pick_item_ids(main, 2)
	for iid in ids:
		main.hotbar.append(main._make_item(str(iid)))
	var bank_before := _bank_fingerprint(main._campaign.state)
	## Same abort `_go_home_loss` uses — no bank from hand.
	main._campaign_abort()
	var bank_after := _bank_fingerprint(main._campaign.state)
	failed = _check(
		failed,
		"main_death_after_push_banks_nothing",
		int(bank_after["n"]) == int(bank_before["n"]) and str(bank_after["sig"]) == str(bank_before["sig"])
	) or failed
	failed = _check(
		failed,
		"main_death_after_push_run_idle",
		not bool(main._campaign.state["run"].get("active", true))
	) or failed
	main._campaign_on = false
	main.hotbar.clear()
	return failed


func _subset_uids(need: Array, have: Array) -> bool:
	for u in need:
		if not have.has(u):
			return false
	return true


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	print("FAIL %s" % label)
	return true
