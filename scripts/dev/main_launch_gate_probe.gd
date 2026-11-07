extends SceneTree
## P3 main launch eligibility — bounded integration probe (sandbox only).
##
## Proves: invalid/stale/ineligible/read-only rejects with no splash/reset mutation;
## eligible normal + shortcut pass `can_start` gate; Push does not route through
## `_on_campaign_start`; `_begin_campaign_delve` initializes begin_run once.
##
## Run via: ./tools/qa/run_main_launch_gate_probe.sh

const MAIN_SCENE := "res://scenes/main.tscn"
const Shell = preload("res://scripts/campaign_shell.gd")


func _initialize() -> void:
	var failed := false
	if not _sandbox_ok():
		print("REFUSED_UNSAFE_DIRECT_USERDATA path=%s" % OS.get_user_data_dir())
		push_error(
			"MAIN_LAUNCH_GATE_PROBE_FAIL refuse: user data '%s' is not a P3 sandbox. "
			% OS.get_user_data_dir()
			+ "Run tools/qa/run_main_launch_gate_probe.sh (sets XDG_DATA_HOME)."
		)
		quit(1)
		return
	print("PROBE_USER_DATA=", OS.get_user_data_dir())
	print("SANDBOX_GUARD_OK")

	failed = _source_contracts() or failed

	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		push_error("MAIN_LAUNCH_GATE_PROBE_FAIL change_scene err=%s" % err)
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
		push_error("MAIN_LAUNCH_GATE_PROBE_FAIL campaign missing after main boot")
		quit(1)
		return

	## Dismiss playtest surfaces so map/start calls are not blocked by hub overlays.
	_quiet_playtest_chrome(main)
	await process_frame

	failed = await _case_reject_ineligible_no_mutation(main) or failed
	failed = await _case_reject_stale_out_of_range(main) or failed
	failed = await _case_reject_read_only_in_run(main) or failed
	failed = _case_eligible_normal_and_shortcut(main) or failed
	failed = _case_push_path_distinct(main) or failed

	if failed:
		push_error("MAIN_LAUNCH_GATE_PROBE_FAIL")
		print("MAIN_LAUNCH_GATE_PROBE_FAIL")
		quit(1)
	else:
		print("MAIN_LAUNCH_GATE_PROBE_OK")
		quit(0)


func _sandbox_ok() -> bool:
	var path := OS.get_user_data_dir()
	return path.find("main-launch-gate") >= 0 or path.find("p3-main-launch") >= 0


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
	var start_idx: int = src.find("func _on_campaign_start")
	var start_end: int = src.find("\nfunc ", start_idx + 1)
	var start_body: String = src.substr(start_idx, maxi(0, start_end - start_idx))
	failed = _check(failed, "source_gate_helper_exists", src.find("func _campaign_launch_allowed") >= 0) or failed
	failed = _check(
		failed,
		"source_start_calls_gate_before_splash_busy",
		start_body.find("_campaign_launch_allowed") >= 0
		and start_body.find("_campaign_launch_allowed") < start_body.find("_splash_busy = true")
	) or failed
	failed = _check(
		failed,
		"source_start_gates_before_present_splash",
		start_body.find("_campaign_launch_allowed") < start_body.find("_present_campaign_splash")
	) or failed
	failed = _check(
		failed,
		"source_start_uses_can_start",
		src.find("CAMPAIGN_SHELL.can_start") >= 0
		and src.find("func _campaign_launch_allowed") >= 0
	) or failed

	var delve_idx: int = src.find("func _begin_campaign_delve")
	var delve_end: int = src.find("\nfunc ", delve_idx + 1)
	var delve_body: String = src.substr(delve_idx, maxi(0, delve_end - delve_idx))
	var begin_count := 0
	var search_from := 0
	while true:
		var hit: int = delve_body.find("CAMPAIGN_SHELL.begin_run", search_from)
		if hit < 0:
			break
		begin_count += 1
		search_from = hit + 1
	failed = _check(failed, "source_begin_delve_begin_run_once", begin_count == 1) or failed
	failed = _check(failed, "source_begin_delve_calls_reset", delve_body.find("_reset_run()") >= 0) or failed

	var push_idx: int = src.find("func _adventure_continue")
	var push_end: int = src.find("\nfunc ", push_idx + 1)
	var push_body: String = src.substr(push_idx, maxi(0, push_end - push_idx))
	failed = _check(failed, "source_push_uses_push_deeper", push_body.find("push_deeper") >= 0) or failed
	failed = _check(
		failed,
		"source_push_not_on_campaign_start",
		push_body.find("_on_campaign_start") < 0 and push_body.find("begin_run") < 0
	) or failed
	failed = _check(
		failed,
		"source_push_not_launch_allowed",
		push_body.find("_campaign_launch_allowed") < 0
	) or failed
	return failed


func _fingerprint(main: Node) -> Dictionary:
	var state: Dictionary = main._campaign.state
	var run: Dictionary = state.get("run", {})
	return {
		"splash_busy": bool(main._splash_busy),
		"campaign_on": bool(main._campaign_on),
		"run_active": bool(run.get("active", false)),
		"biome_index": int(run.get("biome_index", -1)),
		"banked_n": (state.get("banked", {}) as Dictionary).size(),
		"next_run_keys": (state.get("next_run", {}) as Dictionary).keys(),
		"dungeon_index": int(main.dungeon_index),
		"phase": str(main.phase),
		"splash_kids": _count_named_children(main, "BiomeSplash"),
		"wipe_alpha": _wipe_alpha(main),
	}


func _wipe_alpha(main: Node) -> float:
	if not ("_biome_wipe" in main) or main._biome_wipe == null:
		return 0.0
	return float(main._biome_wipe.modulate.a)


func _count_named_children(host: Node, needle: String) -> int:
	var n := 0
	for c in host.get_children():
		if str(c.name).find(needle) >= 0 or c.get_script() != null and str(c.get_script().resource_path).find("biome_splash") >= 0:
			n += 1
	return n


func _fill_pool(rules: Dictionary, state: Dictionary, pool: String, n: int) -> void:
	var ids: Array = []
	var pools := {}
	for i in n:
		var id := "%s_p3_%d" % [pool, i]
		ids.append(id)
		pools[id] = pool
	Shell.bank(rules, state, ids, pools)


func _case_reject_ineligible_no_mutation(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	main._campaign_on = false
	main._splash_busy = false
	## D2 destination open does not license D2 fresh start (one-behind).
	_fill_pool(main._campaign.rules, main._campaign.state, "b1", 5)
	failed = _check(
		failed,
		"setup_d2_dest_open_not_startable",
		Shell.biome_unlocked(main._campaign.rules, main._campaign.state, 1)
		and not Shell.can_start(main._campaign.rules, main._campaign.state, 1)
	) or failed
	failed = _check(
		failed,
		"allowed_rejects_d2_when_only_d2_unlocked",
		not main._campaign_launch_allowed(1, false, false)
	) or failed
	var before := _fingerprint(main)
	main._on_campaign_start(1, false, false)
	for _i in 20:
		await process_frame
	var after := _fingerprint(main)
	failed = _check(failed, "reject_ineligible_splash_busy_unchanged", after["splash_busy"] == before["splash_busy"] and after["splash_busy"] == false) or failed
	failed = _check(failed, "reject_ineligible_no_campaign_on", after["campaign_on"] == false) or failed
	failed = _check(failed, "reject_ineligible_run_still_idle", after["run_active"] == false) or failed
	failed = _check(failed, "reject_ineligible_no_splash_node", int(after["splash_kids"]) == 0) or failed
	failed = _check(failed, "reject_ineligible_no_wipe", float(after["wipe_alpha"]) <= 0.01) or failed
	failed = _check(failed, "reject_ineligible_phase_unchanged", str(after["phase"]) == str(before["phase"])) or failed
	failed = _check(failed, "reject_ineligible_dungeon_index_unchanged", int(after["dungeon_index"]) == int(before["dungeon_index"])) or failed
	return failed


func _case_reject_stale_out_of_range(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	main._campaign_on = false
	main._splash_busy = false
	failed = _check(failed, "allowed_rejects_negative", not main._campaign_launch_allowed(-1, false, false)) or failed
	failed = _check(failed, "allowed_rejects_oob", not main._campaign_launch_allowed(99, true, false)) or failed
	var before := _fingerprint(main)
	main._on_campaign_start(-1, false, false)
	await process_frame
	main._on_campaign_start(5, true, false)
	for _i in 12:
		await process_frame
	var after := _fingerprint(main)
	failed = _check(failed, "reject_stale_no_splash_busy", after["splash_busy"] == false) or failed
	failed = _check(failed, "reject_stale_run_idle", after["run_active"] == false and after["campaign_on"] == false) or failed
	failed = _check(failed, "reject_stale_banked_untouched", int(after["banked_n"]) == int(before["banked_n"])) or failed
	return failed


func _case_reject_read_only_in_run(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	Shell.begin_run(main._campaign.state, 0, false, false)
	main._campaign_on = true
	main._splash_busy = false
	if main.campaign_map == null:
		return _check(failed, "campaign_map_present", false)
	main.campaign_map.show_map(main._campaign.rules, main._campaign.state, {}, {"read_only": true})
	await process_frame
	failed = _check(failed, "map_is_read_only", main.campaign_map.is_read_only()) or failed
	failed = _check(
		failed,
		"allowed_rejects_read_only_peek",
		not main._campaign_launch_allowed(0, false, false)
	) or failed
	var before := _fingerprint(main)
	main._on_campaign_start(0, false, false)
	for _i in 16:
		await process_frame
	var after := _fingerprint(main)
	failed = _check(failed, "reject_readonly_splash_busy_false", after["splash_busy"] == false) or failed
	failed = _check(failed, "reject_readonly_still_in_run", after["run_active"] == true and after["campaign_on"] == true) or failed
	failed = _check(failed, "reject_readonly_biome_index_kept", int(after["biome_index"]) == int(before["biome_index"])) or failed
	failed = _check(failed, "reject_readonly_no_splash_node", int(after["splash_kids"]) == 0) or failed
	## Cleanup so later cases start clean.
	main.campaign_map.hide_map()
	Shell.end_run(main._campaign.state)
	main._campaign_on = false
	return failed


func _case_eligible_normal_and_shortcut(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	main._campaign_on = false
	main._splash_busy = false
	failed = _check(
		failed,
		"eligible_normal_d1",
		main._campaign_launch_allowed(0, false, false)
		and Shell.can_start(main._campaign.rules, main._campaign.state, 0)
	) or failed
	## Unlock through D3 → D2 fresh-start shortcut (one-behind).
	_fill_pool(main._campaign.rules, main._campaign.state, "b1", 5)
	_fill_pool(main._campaign.rules, main._campaign.state, "b2", 5)
	failed = _check(
		failed,
		"eligible_shortcut_d2_after_d3",
		Shell.can_start(main._campaign.rules, main._campaign.state, 1)
		and main._campaign_launch_allowed(1, true, false)
	) or failed
	failed = _check(
		failed,
		"eligible_still_rejects_d3_fresh",
		not main._campaign_launch_allowed(2, true, false)
	) or failed
	## Initialize once via the same shell entry `_begin_campaign_delve` uses.
	Shell.begin_run(main._campaign.state, 1, true, false)
	var run: Dictionary = main._campaign.state.get("run", {})
	failed = _check(failed, "init_once_run_active", bool(run.get("active", false))) or failed
	failed = _check(failed, "init_once_shortcut_flag", bool(run.get("shortcut", false))) or failed
	failed = _check(failed, "init_once_biome_index_d2", int(run.get("biome_index", -1)) == 1) or failed
	Shell.begin_run(main._campaign.state, 1, true, false)
	run = main._campaign.state.get("run", {})
	failed = _check(
		failed,
		"init_idempotent_still_single_active_run",
		bool(run.get("active", false)) and int(run.get("biome_index", -1)) == 1
	) or failed
	Shell.end_run(main._campaign.state)
	return failed


func _case_push_path_distinct(main: Node) -> bool:
	var failed := false
	main._campaign.state = Shell.fresh_state()
	_fill_pool(main._campaign.rules, main._campaign.state, "b1", 5)
	Shell.begin_run(main._campaign.state, 0, false, false)
	main._campaign_on = true
	failed = _check(
		failed,
		"push_can_while_start_blocked",
		Shell.can_push(main._campaign.rules, main._campaign.state)
		and not main._campaign_launch_allowed(1, false, false)
	) or failed
	failed = _check(
		failed,
		"push_deeper_not_new_run_launch",
		Shell.push_deeper(main._campaign.rules, main._campaign.state)
		and int(main._campaign.state["run"]["biome_index"]) == 1
		and not bool(main._campaign.state["run"].get("shortcut", true))
	) or failed
	Shell.end_run(main._campaign.state)
	main._campaign_on = false
	return failed


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	print("FAIL %s" % label)
	return true
