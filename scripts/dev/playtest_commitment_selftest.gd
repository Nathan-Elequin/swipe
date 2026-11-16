extends SceneTree
## Headless checks for playtest commitment tiers (slice 1 logic + slice 2 UI contracts).
## Does not boot main.gd.
##
## Run: godot --headless --path . --script res://scripts/dev/playtest_commitment_selftest.gd


const OK_MARK := "PLAYTEST_COMMITMENT_OK"
const FAIL_MARK := "PLAYTEST_COMMITMENT_FAIL"
const C := preload("res://scripts/playtest_commitment.gd")
const PICKER := preload("res://scripts/playtest_commitment_picker.gd")
const GOAL := preload("res://scripts/playtest_goal_icon.gd")
const COPY := preload("res://scripts/player_copy.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	var tmp_user := _make_temp_user()
	failed = _check(rows, failed, "temp.user_dir", tmp_user != "" and DirAccess.dir_exists_absolute(tmp_user), tmp_user) or failed

	## --- Persist / reload ---
	var a: PlaytestCommitment = C.new()
	a.debug_reset()
	failed = _check(rows, failed, "fresh.tier_none", a.tier == C.TIER_NONE, "") or failed
	failed = _check(rows, failed, "choose.quick", a.choose(C.TIER_QUICK), "") or failed
	failed = _check(rows, failed, "choose.idempotent", not a.choose(C.TIER_DEEPER), "second choose must fail") or failed
	failed = _check(rows, failed, "tier.after_choose", a.tier == C.TIER_QUICK, "") or failed
	a.save_state()

	var b: PlaytestCommitment = C.new()
	b.load_state()
	failed = _check(rows, failed, "reload.tier", b.tier == C.TIER_QUICK, "got %s" % b.tier) or failed
	failed = _check(rows, failed, "reload.chosen_at", b.chosen_at != "", "") or failed

	## --- Upgrade-only ---
	failed = _check(rows, failed, "upgrade.lower_rejected", not b.upgrade(C.TIER_QUICK), "") or failed
	failed = _check(rows, failed, "upgrade.deeper", b.upgrade(C.TIER_DEEPER), "") or failed
	failed = _check(rows, failed, "tier.after_upgrade", b.tier == C.TIER_DEEPER, "") or failed
	failed = _check(rows, failed, "upgrade.big", b.upgrade(C.TIER_BIG), "") or failed
	failed = _check(rows, failed, "upgrade.same_rejected", not b.upgrade(C.TIER_BIG), "") or failed

	## --- localStorage-merge logic (mock, no web) ---
	var left := {
		"tier": 1,
		"reached_quick": true,
		"reached_deeper": false,
		"reached_big": false,
		"offramp_shown_quick": false,
		"run_count": 2,
		"chosen_at": "2026-01-01T00:00:00",
	}
	var right := {
		"tier": 3,
		"reached_quick": false,
		"reached_deeper": true,
		"reached_big": false,
		"offramp_shown_quick": true,
		"run_count": 1,
		"chosen_at": "2026-02-01T00:00:00",
	}
	var merged: Dictionary = C.merge_dicts(left, right)
	failed = _check(rows, failed, "merge.tier_max", int(merged.get("tier", 0)) == 3, "") or failed
	failed = _check(rows, failed, "merge.reached_or", bool(merged.get("reached_quick", false)) and bool(merged.get("reached_deeper", false)), "") or failed
	failed = _check(rows, failed, "merge.offramp_or", bool(merged.get("offramp_shown_quick", false)), "") or failed
	failed = _check(rows, failed, "merge.run_count_max", int(merged.get("run_count", 0)) == 2, "") or failed
	failed = _check(rows, failed, "merge.chosen_later", str(merged.get("chosen_at", "")) == "2026-02-01T00:00:00", "") or failed

	## --- Milestones fire once ---
	var c: PlaytestCommitment = C.new()
	c.debug_reset()
	c.choose(C.TIER_BIG)
	var seen: Dictionary = {}
	c.milestone_reached.connect(func(id: String, _t: int, _n: int) -> void:
		seen[id] = int(seen.get(id, 0)) + 1
	)

	## Tutorial must not count for quick.
	c.note_run_start(true, 0)
	c.note_run_end("leave")
	var tut_fired: Array = c.note_homecoming_settled("tutorial")
	failed = _check(rows, failed, "tut.no_quick", tut_fired.is_empty() and not c.reached_quick, "") or failed

	## First real leave → quick.
	c.note_run_start(false, 0)
	c.note_biome(0)
	c.note_run_end("leave")
	var q_fired: Array = c.note_homecoming_settled("win")
	failed = _check(rows, failed, "quick.fires", q_fired.has(C.M_QUICK) and c.reached_quick, "%s" % str(q_fired)) or failed
	failed = _check(rows, failed, "quick.once_signal", int(seen.get(C.M_QUICK, 0)) >= 1, "") or failed
	var q_again: Array = []
	c.note_run_start(false, 0)
	c.note_run_end("leave")
	q_again = c.note_homecoming_settled("win")
	failed = _check(rows, failed, "quick.no_refire", not q_again.has(C.M_QUICK), "%s" % str(q_again)) or failed

	## Death also qualifies for quick when not yet reached; here it is already reached —
	## return value must not list a new reach (pending may still re-signal for UI).
	c.note_run_start(false, 0)
	c.note_run_end("dead")
	var dead_fired: Array = c.note_homecoming_settled("loss")
	failed = _check(rows, failed, "quick.dead_no_refire", not dead_fired.has(C.M_QUICK), "%s" % str(dead_fired)) or failed

	## Deeper: enter b2 then end.
	c.note_run_start(false, 0)
	c.note_biome(1)
	c.note_run_end("leave")
	var d_fired: Array = c.note_homecoming_settled("win")
	failed = _check(rows, failed, "deeper.fires", d_fired.has(C.M_DEEPER) and c.reached_deeper, "%s" % str(d_fired)) or failed
	c.note_run_start(false, 1)
	c.note_run_end("dead")
	var d_again: Array = c.note_homecoming_settled("loss")
	failed = _check(rows, failed, "deeper.no_refire", not d_again.has(C.M_DEEPER), "%s" % str(d_again)) or failed

	## Big: enter b5 then end.
	c.note_run_start(false, 4)
	c.note_run_end("leave")
	var big_fired: Array = c.note_homecoming_settled("win")
	failed = _check(rows, failed, "big.fires", big_fired.has(C.M_BIG) and c.reached_big, "%s" % str(big_fired)) or failed
	c.note_run_start(false, 4)
	c.note_run_end("dead")
	var big_again: Array = c.note_homecoming_settled("loss")
	failed = _check(rows, failed, "big.no_refire", not big_again.has(C.M_BIG), "%s" % str(big_again)) or failed

	## --- should_offramp gating ---
	var g: PlaytestCommitment = C.new()
	g.debug_reset()
	g.debug_force_milestone(C.M_QUICK)
	g.debug_force_milestone(C.M_DEEPER)
	failed = _check(rows, failed, "offramp.none_without_tier", not g.should_offramp(C.M_QUICK), "") or failed
	g.debug_set_tier(C.TIER_QUICK)
	failed = _check(rows, failed, "offramp.quick_ok", g.should_offramp(C.M_QUICK), "") or failed
	failed = _check(rows, failed, "offramp.deeper_blocked", not g.should_offramp(C.M_DEEPER), "tier 1 < deeper") or failed
	g.debug_set_tier(C.TIER_DEEPER)
	failed = _check(rows, failed, "offramp.deeper_ok", g.should_offramp(C.M_DEEPER), "") or failed
	failed = _check(rows, failed, "offramp.quick_still", g.should_offramp(C.M_QUICK), "still unshown") or failed
	g.mark_offramp_shown(C.M_QUICK)
	failed = _check(rows, failed, "offramp.never_reshow", not g.should_offramp(C.M_QUICK), "") or failed
	failed = _check(rows, failed, "offramp.next_is_deeper", g.next_offramp() == C.M_DEEPER, g.next_offramp()) or failed

	## --- Pending survives reload ---
	var p: PlaytestCommitment = C.new()
	p.debug_reset()
	p.choose(C.TIER_QUICK)
	p.note_run_start(false, 0)
	p.note_run_end("leave")
	p.note_homecoming_settled("win")
	failed = _check(rows, failed, "pending.set", p.pending_milestone == C.M_QUICK and p.should_offramp(C.M_QUICK), p.pending_milestone) or failed
	p.save_state()
	## Simulate quit before offramp UI — reload must keep pending.
	var p2: PlaytestCommitment = C.new()
	p2.load_state()
	failed = _check(rows, failed, "pending.reload", p2.pending_milestone == C.M_QUICK, p2.pending_milestone) or failed
	failed = _check(rows, failed, "pending.should", p2.should_offramp(C.M_QUICK), "") or failed
	var cabin_seen: Array = []
	p2.milestone_reached.connect(func(id: String, _t: int, _n: int) -> void:
		cabin_seen.append(id)
	)
	var reemit: Array = p2.note_cabin_visit()
	failed = _check(rows, failed, "pending.cabin_reemit", reemit.has(C.M_QUICK) and cabin_seen.has(C.M_QUICK), "%s" % str(reemit)) or failed
	p2.mark_offramp_shown(C.M_QUICK)
	var p3: PlaytestCommitment = C.new()
	p3.load_state()
	failed = _check(rows, failed, "pending.cleared", p3.pending_milestone == "" and not p3.should_offramp(C.M_QUICK), p3.pending_milestone) or failed

	## --- Meta keys preserved ---
	var root_path := "user://playtest_meta.json"
	var root_before := {
		"intro_v2": true,
		"intro_build": "test-sha",
		"preset": "middle",
		"teaser_v1": true,
		"commitment": {"tier": 2},
	}
	var rf := FileAccess.open(root_path, FileAccess.WRITE)
	rf.store_string(JSON.stringify(root_before))
	rf.close()
	var keep: PlaytestCommitment = C.new()
	keep.load_state()
	failed = _check(rows, failed, "meta.tier_loaded", keep.tier == 2, "") or failed
	keep.upgrade(C.TIER_BIG)
	var root_after: Variant = JSON.parse_string(FileAccess.get_file_as_string(root_path))
	failed = _check(rows, failed, "meta.root_dict", typeof(root_after) == TYPE_DICTIONARY, "") or failed
	if typeof(root_after) == TYPE_DICTIONARY:
		var rd: Dictionary = root_after
		failed = _check(rows, failed, "meta.keep_intro", bool(rd.get("intro_v2", false)), "") or failed
		failed = _check(rows, failed, "meta.keep_teaser", bool(rd.get("teaser_v1", false)), "") or failed
		failed = _check(rows, failed, "meta.keep_preset", str(rd.get("preset", "")) == "middle", "") or failed
		failed = _check(rows, failed, "meta.commitment_tier", int((rd.get("commitment", {}) as Dictionary).get("tier", 0)) == 3, "") or failed

	## --- Hub public-build hide contract (source) ---
	var hub_src := FileAccess.get_file_as_string("res://scripts/playtest_hub.gd")
	failed = _check(rows, failed, "hub.hide_middle_src",
		hub_src.find("has_feature(\"playtest\")") >= 0
		and hub_src.find("has_feature(\"editor\")") >= 0
		and hub_src.find("_btn_mid") >= 0
		and hub_src.find("middle_progress_allowed") >= 0,
		"open_hub must hide Middle Progress in exported playtest") or failed

	## --- Main hook contracts (source) ---
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(rows, failed, "main.commitment_preload",
		main_src.find("playtest_commitment.gd") >= 0, "") or failed
	failed = _check(rows, failed, "main.note_run_start",
		main_src.find("note_run_start") >= 0, "") or failed
	failed = _check(rows, failed, "main.note_biome",
		main_src.find("note_biome") >= 0, "") or failed
	failed = _check(rows, failed, "main.note_run_end",
		main_src.find("note_run_end") >= 0, "") or failed
	failed = _check(rows, failed, "main.homecoming_settled",
		main_src.find("note_homecoming_settled") >= 0
		or main_src.find("arrive_settled") >= 0, "") or failed

	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "cabin.arrive_settled_signal",
		cabin_src.find("signal arrive_settled") >= 0, "") or failed

	## --- Slice 2: picker / goal / pause contracts ---
	failed = _check(rows, failed, "ui.picker_only_tier0",
		PICKER.shows_only_when_tier_none(0) and not PICKER.shows_only_when_tier_none(1), "") or failed
	failed = _check(rows, failed, "ui.upgrade_disables_lower",
		PICKER.upgrade_disables_lower(1, 1) and PICKER.upgrade_disables_lower(1, 0)
		and not PICKER.upgrade_disables_lower(1, 2), "") or failed

	var host: Window = get_root()
	var picker = PICKER.new()
	host.add_child(picker)
	picker.call("setup")
	picker.call("open_picker", "choose", 0, {})
	failed = _check(rows, failed, "ui.picker_shows_tier0", bool(picker.visible), "") or failed
	picker.call("close_picker")
	picker.call("open_picker", "upgrade", 1, {"quick": true})
	failed = _check(rows, failed, "ui.upgrade_open", bool(picker.visible), "") or failed
	failed = _check(rows, failed, "ui.upgrade_blocks_quick",
		PICKER.upgrade_disables_lower(1, 1), "") or failed
	picker.call("close_picker")
	picker.queue_free()

	var goal = GOAL.new()
	host.add_child(goal)
	goal.call("setup")
	goal.call("apply_state", 0, false, false, false)
	failed = _check(rows, failed, "ui.goal_hidden_tier0", not bool(goal.visible), "") or failed
	goal.call("apply_state", 1, false, false, false)
	failed = _check(rows, failed, "ui.goal_shown_tier1", bool(goal.visible), "") or failed
	goal.queue_free()

	failed = _check(rows, failed, "copy.tier_quick_title",
		COPY.text("playtest.tier.quick.title", "") != "", "") or failed
	failed = _check(rows, failed, "copy.goal_done",
		COPY.text("playtest.goal.done", "") != "", "") or failed
	failed = _check(rows, failed, "copy.pause_go_deeper",
		COPY.text("pause.go_deeper", "") != "", "") or failed

	failed = _check(rows, failed, "main.picker_preload",
		main_src.find("playtest_commitment_picker.gd") >= 0, "") or failed
	failed = _check(rows, failed, "main.goal_preload",
		main_src.find("playtest_goal_icon.gd") >= 0, "") or failed
	failed = _check(rows, failed, "main.after_intro_picker",
		main_src.find("_maybe_open_commitment_picker") >= 0, "") or failed
	failed = _check(rows, failed, "main.tier_chosen_telem",
		main_src.find("tier_chosen") >= 0 and main_src.find("tier_upgraded") >= 0, "") or failed
	failed = _check(rows, failed, "main.debug_reset_key",
		main_src.find("debug_reset") >= 0 and main_src.find("KEY_4") >= 0, "") or failed

	var settings_src := FileAccess.get_file_as_string("res://scripts/settings_menu.gd")
	failed = _check(rows, failed, "pause.go_deeper_signal",
		settings_src.find("go_deeper_pressed") >= 0
		and settings_src.find("show_go_deeper") >= 0
		and settings_src.find("pause.go_deeper") >= 0, "") or failed

	_print_rows(rows)
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String) -> bool:
	rows.append({"name": name, "ok": ok, "detail": detail})
	if not ok:
		print("FAIL %s %s" % [name, detail])
	return (not ok) or failed


func _print_rows(rows: Array) -> void:
	var passed := 0
	for r in rows:
		if bool(r.get("ok", false)):
			passed += 1
	print("playtest_commitment_selftest: %d/%d passed" % [passed, rows.size()])


func _make_temp_user() -> String:
	var base := OS.get_temp_dir().path_join("swipe-pt-commitment-%d" % Time.get_ticks_msec())
	DirAccess.make_dir_recursive_absolute(base)
	## Isolate playtest_meta.json so this selftest does not clobber a live profile.
	var meta := "user://playtest_meta.json"
	if FileAccess.file_exists(meta):
		var bak := "user://playtest_meta.commitment_selftest.bak"
		var raw := FileAccess.get_file_as_string(meta)
		var bf := FileAccess.open(bak, FileAccess.WRITE)
		if bf:
			bf.store_string(raw)
			bf.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(meta))
	return base
