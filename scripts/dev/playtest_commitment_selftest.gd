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
const OFFRAMP := preload("res://scripts/playtest_offramp.gd")
const VICTORY := preload("res://scripts/playtest_victory.gd")
const VC := preload("res://scripts/playtest_victory_code.gd")
const COPY := preload("res://scripts/player_copy.gd")
const HUB := preload("res://scripts/playtest_hub.gd")


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

	## --- Title menu states (no save / save / after start-over) ---
	var vis_new: Dictionary = HUB.menu_visibility(false, false)
	failed = _check(rows, failed, "hub.menu.no_save.new",
		bool(vis_new.get("new_game", false)) and not bool(vis_new.get("continue", true))
		and not bool(vis_new.get("start_over", true))
		and bool(vis_new.get("settings", false)) and bool(vis_new.get("feedback", false))
		and str(vis_new.get("default_focus", "")) == "new_game",
		"%s" % str(vis_new)) or failed
	var vis_save: Dictionary = HUB.menu_visibility(true, false)
	failed = _check(rows, failed, "hub.menu.save.continue",
		bool(vis_save.get("continue", false)) and not bool(vis_save.get("new_game", true))
		and bool(vis_save.get("start_over", false))
		and bool(vis_save.get("settings", false)) and bool(vis_save.get("feedback", false))
		and str(vis_save.get("default_focus", "")) == "continue",
		"%s" % str(vis_save)) or failed
	var vis_editor: Dictionary = HUB.menu_visibility(false, true)
	failed = _check(rows, failed, "hub.menu.editor.middle",
		bool(vis_editor.get("middle", false)) and bool(vis_editor.get("new_game", false)),
		"%s" % str(vis_editor)) or failed

	var hub_host: Window = get_root()
	var hub_ui = HUB.new()
	hub_host.add_child(hub_ui)
	hub_ui.call("setup")
	hub_ui.call("open_hub", false)
	var ids_new: Array = hub_ui.call("visible_action_ids")
	## Editor may still show Middle Progress; playtest export hides it via middle_progress_allowed().
	failed = _check(rows, failed, "hub.ui.no_save.ids",
		ids_new.has("new_game") and ids_new.has("settings") and ids_new.has("feedback")
		and not ids_new.has("continue") and not ids_new.has("start_over"),
		"%s" % str(ids_new)) or failed
	failed = _check(rows, failed, "hub.ui.no_save.focus",
		str(hub_ui.call("default_focus_id")) == "new_game", "") or failed
	hub_ui.call("open_hub", true)
	var ids_save: Array = hub_ui.call("visible_action_ids")
	failed = _check(rows, failed, "hub.ui.save.ids",
		ids_save.has("continue") and ids_save.has("start_over") and ids_save.has("settings")
		and ids_save.has("feedback") and not ids_save.has("new_game"),
		"%s" % str(ids_save)) or failed
	failed = _check(rows, failed, "hub.ui.save.focus",
		str(hub_ui.call("default_focus_id")) == "continue", "") or failed
	hub_ui.queue_free()

	## Start over wipe: no tier, anon kept.
	var wipe_c: PlaytestCommitment = C.new()
	wipe_c.debug_reset()
	wipe_c.anon_id = "keep-me-anon"
	wipe_c.choose(C.TIER_DEEPER)
	wipe_c.debug_force_milestone(C.M_QUICK)
	wipe_c.ensure_victory_code()
	failed = _check(rows, failed, "wipe.before.tier", wipe_c.tier == C.TIER_DEEPER, "") or failed
	failed = _check(rows, failed, "wipe.before.anon", wipe_c.anon_id == "keep-me-anon", wipe_c.anon_id) or failed
	wipe_c.wipe_progress()
	failed = _check(rows, failed, "wipe.after.tier_none", wipe_c.tier == C.TIER_NONE, "tier=%s" % wipe_c.tier) or failed
	failed = _check(rows, failed, "wipe.after.no_reached",
		not wipe_c.reached_quick and not wipe_c.reached_deeper and not wipe_c.reached_big, "") or failed
	failed = _check(rows, failed, "wipe.after.no_pending", wipe_c.pending_milestone == "", wipe_c.pending_milestone) or failed
	failed = _check(rows, failed, "wipe.after.no_victory", wipe_c.victory_code == "", wipe_c.victory_code) or failed
	failed = _check(rows, failed, "wipe.after.anon_kept", wipe_c.anon_id == "keep-me-anon", wipe_c.anon_id) or failed

	failed = _check(rows, failed, "copy.title.menu.new_game",
		COPY.text("title.menu.new_game", "") != "", "") or failed
	failed = _check(rows, failed, "copy.title.start_over.ask",
		COPY.text("title.start_over.ask", "") != "", "") or failed
	failed = _check(rows, failed, "copy.title.start_over.body",
		COPY.text("title.start_over.body", "") != "", "") or failed
	failed = _check(rows, failed, "copy.settings.sparkles.on",
		COPY.text("settings.sparkles.on", "") != "", "") or failed
	failed = _check(rows, failed, "copy.settings.back",
		COPY.text("settings.back", "") == "Back" or COPY.text("settings.back", "") != "", "") or failed
	failed = _check(rows, failed, "copy.settings.sound",
		COPY.text("settings.sound", "") == "Sound Settings", "") or failed
	failed = _check(rows, failed, "copy.goal.ticker_line",
		COPY.text("playtest.goal.ticker_line", "").find("{goal}") >= 0, "") or failed
	failed = _check(rows, failed, "copy.tier.quick.goal",
		COPY.text("playtest.tier.quick.goal", "") != "", "") or failed
	failed = _check(rows, failed, "copy.intro.preview.caption",
		COPY.text("intro.preview.caption", "") != "", "") or failed
	## Between-dungeon Continue stays on title.continue (not title.menu.continue).
	failed = _check(rows, failed, "copy.title.continue.dungeon",
		COPY.text("title.continue", "") != "", "") or failed
	failed = _assert_visual_copy_keys(rows, failed) or failed

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
	failed = _check(rows, failed, "main.goal_stays_over_boot",
		main_src.find("PlaytestGoalLayer") >= 0
		and main_src.find("playtest_goal_icon.visible = goal_ok") >= 0
		and main_src.find("goal_ok and not hub_up") < 0, "") or failed
	failed = _check(rows, failed, "view.log_clears_goal",
		FileAccess.get_file_as_string("res://scripts/ui/view_frame.gd").find("LOG_Y") >= 0
		and FileAccess.get_file_as_string("res://scripts/ui/view_frame.gd").find("LOG_BTN_Y") >= 0, "") or failed
	failed = _check(rows, failed, "main.new_game_opens_picker",
		main_src.find("_playtest_new_game") >= 0
		and main_src.find("_maybe_open_commitment_picker") >= 0
		and main_src.find("_commitment_picker_from_new_game") >= 0, "") or failed
	failed = _check(rows, failed, "main.intro_skips_picker",
		main_src.find("func _playtest_intro_done") >= 0
		and main_src.find("_maybe_open_teaser") >= 0
		and hub_src.find("title.menu.new_game") >= 0, "") or failed
	failed = _check(rows, failed, "main.start_over_wipe",
		main_src.find("_wipe_playtest_progress_keep_anon") >= 0
		and main_src.find("wipe_progress") >= 0, "") or failed
	failed = _check(rows, failed, "main.tier_chosen_telem",
		main_src.find("tier_chosen") >= 0 and main_src.find("tier_upgraded") >= 0, "") or failed
	failed = _check(rows, failed, "main.debug_reset_key",
		main_src.find("debug_reset") >= 0 and main_src.find("KEY_4") >= 0, "") or failed

	var settings_src := FileAccess.get_file_as_string("res://scripts/settings_menu.gd")
	failed = _check(rows, failed, "pause.go_deeper_signal",
		settings_src.find("go_deeper_pressed") >= 0
		and settings_src.find("show_go_deeper") >= 0
		and settings_src.find("pause.go_deeper") >= 0, "") or failed
	var panel_src := FileAccess.get_file_as_string("res://scripts/ui/settings_panel.gd")
	failed = _check(rows, failed, "settings.toggle_copy_keys",
		panel_src.find("settings.sparkles.on") >= 0
		and panel_src.find("settings.invert_scroll.off") >= 0
		and panel_src.find("settings.reduce_motion.on") >= 0
		and panel_src.find("settings.back") >= 0
		and panel_src.find("settings.sound") >= 0, "") or failed
	failed = _check(rows, failed, "picker.goal_tooltip_src",
		FileAccess.get_file_as_string("res://scripts/playtest_commitment_picker.gd").find("tooltip_text") >= 0
		and FileAccess.get_file_as_string("res://scripts/playtest_commitment_picker.gd").find("biome_key") >= 0
		and FileAccess.get_file_as_string("res://scripts/playtest_commitment_picker.gd").find("goal_key") >= 0, "") or failed

	## --- Slice 3: offramp panel contracts ---
	failed = _check(rows, failed, "offramp.shows_quick",
		OFFRAMP.shows_for_milestone(C.M_QUICK), "") or failed
	failed = _check(rows, failed, "offramp.shows_deeper",
		OFFRAMP.shows_for_milestone(C.M_DEEPER), "") or failed
	failed = _check(rows, failed, "offramp.not_big",
		not OFFRAMP.shows_for_milestone(C.M_BIG), "") or failed

	var o_host: Window = get_root()
	var offramp = OFFRAMP.new()
	o_host.add_child(offramp)
	offramp.call("setup")
	## Big must not open the panel.
	offramp.call("open_offramp", C.M_BIG, {"tier": C.TIER_BIG})
	failed = _check(rows, failed, "offramp.big_stays_hidden", not bool(offramp.visible), "") or failed
	offramp.call("open_offramp", C.M_QUICK, {
		"tier": C.TIER_QUICK,
		"run_count": 1,
		"anon_id": "test-anon",
		"build_id": "abc1234",
		"biomes_unlocked": 1,
		"cabinet_count": 2,
		"play_seconds": 90,
	})
	failed = _check(rows, failed, "offramp.quick_shows", bool(offramp.visible), "") or failed
	var payload: Dictionary = offramp.call("build_payload")
	failed = _check(rows, failed, "offramp.payload_shape",
		OFFRAMP.payload_shape_ok(payload), "%s" % str(payload.keys())) or failed
	failed = _check(rows, failed, "offramp.payload_milestone",
		str(payload.get("milestone", "")) == C.M_QUICK, "") or failed
	failed = _check(rows, failed, "offramp.payload_anon",
		str(payload.get("anon_id", "")) == "test-anon", "") or failed
	## Go deeper hidden when already at BIG.
	offramp.call("close_panel")
	offramp.call("open_offramp", C.M_DEEPER, {"tier": C.TIER_BIG})
	var deeper_btn = offramp.get("_btn_deeper")
	failed = _check(rows, failed, "offramp.deeper_hidden_at_big",
		deeper_btn != null and not bool(deeper_btn.visible), "") or failed
	offramp.call("show_thanks")
	failed = _check(rows, failed, "offramp.thanks_mode",
		str(offramp.get("_mode")) == "thanks" and bool(offramp.get("_thanks").visible), "") or failed
	offramp.call("close_panel")
	offramp.queue_free()

	## Once shown, never re-ask — even after dismiss (flags persist across reload).
	var o: PlaytestCommitment = C.new()
	o.debug_reset()
	o.choose(C.TIER_DEEPER)
	o.debug_force_milestone(C.M_QUICK)
	failed = _check(rows, failed, "offramp.slice3.should_before",
		o.should_offramp(C.M_QUICK), "") or failed
	o.mark_offramp_shown(C.M_QUICK)
	failed = _check(rows, failed, "offramp.slice3.never_reshow",
		not o.should_offramp(C.M_QUICK), "") or failed
	o.save_state()
	var o2: PlaytestCommitment = C.new()
	o2.load_state()
	failed = _check(rows, failed, "offramp.slice3.flag_persists",
		bool(o2.offramp_shown_quick) and not o2.should_offramp(C.M_QUICK), "") or failed
	## Tier gate: deeper reached but tier too low → no offramp.
	var o3: PlaytestCommitment = C.new()
	o3.debug_reset()
	o3.debug_set_tier(C.TIER_QUICK)
	o3.debug_force_milestone(C.M_DEEPER)
	failed = _check(rows, failed, "offramp.slice3.tier_gate",
		not o3.should_offramp(C.M_DEEPER), "") or failed

	failed = _check(rows, failed, "copy.offramp.quick.header",
		COPY.text("playtest.offramp.quick.header", "") != "", "") or failed
	failed = _check(rows, failed, "copy.offramp.deeper.q1",
		COPY.text("playtest.offramp.deeper.q1", "") != "", "") or failed
	failed = _check(rows, failed, "copy.offramp.thanks",
		COPY.text("playtest.offramp.thanks", "") != "", "") or failed

	failed = _check(rows, failed, "main.offramp_preload",
		main_src.find("playtest_offramp.gd") >= 0, "") or failed
	failed = _check(rows, failed, "main.offramp_open",
		main_src.find("_open_commitment_offramp") >= 0, "") or failed
	failed = _check(rows, failed, "main.offramp_victory_hook",
		main_src.find("_maybe_open_commitment_victory") >= 0, "") or failed
	failed = _check(rows, failed, "main.offramp_not_big_panel",
		main_src.find("M_BIG") >= 0 and main_src.find("_maybe_open_commitment_victory") >= 0, "") or failed

	## --- Slice 4: BIG victory ---
	var code_a: String = VC.generate("anon-test-1", C.M_BIG)
	var code_b: String = VC.generate("anon-test-1", C.M_BIG)
	var code_c: String = VC.generate("anon-test-2", C.M_BIG)
	failed = _check(rows, failed, "victory.code.format",
		VC.is_valid_format(code_a) and code_a.begins_with("ABYSS-") and code_a.length() == 15, code_a) or failed
	failed = _check(rows, failed, "victory.code.deterministic",
		code_a == code_b, "%s vs %s" % [code_a, code_b]) or failed
	failed = _check(rows, failed, "victory.code.diff_anon",
		code_a != code_c, "") or failed
	failed = _check(rows, failed, "victory.code.verify_ok",
		VC.verify("anon-test-1", code_a, C.M_BIG), "") or failed
	failed = _check(rows, failed, "victory.code.verify_bad",
		not VC.verify("anon-test-1", code_c, C.M_BIG), "") or failed
	## Ambiguous-char normalize still verifies.
	var messy := code_a.to_lower().replace("-", "")
	failed = _check(rows, failed, "victory.code.normalize",
		VC.verify("anon-test-1", messy, C.M_BIG), messy) or failed

	## Python verifier agrees (when present).
	var py := "res://tools/playtest/verify_victory_code.py"
	if FileAccess.file_exists(py):
		var py_abs := ProjectSettings.globalize_path(py)
		var out: Array = []
		var exit_code: int = OS.execute("python3", [py_abs, "anon-test-1", code_a, "big"], out, true)
		var joined := "\n".join(PackedStringArray(out))
		failed = _check(rows, failed, "victory.verifier_py",
			exit_code == 0 and joined.find("VALID") >= 0, "exit=%s %s" % [exit_code, joined]) or failed

	## Big offramp ignores tier gate; auto-upgrade path.
	var v: PlaytestCommitment = C.new()
	v.debug_reset()
	v.debug_set_tier(C.TIER_QUICK)
	v.anon_id = "anon-test-1"
	v.debug_force_milestone(C.M_BIG)
	failed = _check(rows, failed, "victory.should_without_big_tier",
		v.should_offramp(C.M_BIG), "tier=%s" % v.tier) or failed
	failed = _check(rows, failed, "victory.ensure_upgrade",
		v.ensure_big_tier() and v.tier == C.TIER_BIG, "tier=%s" % v.tier) or failed
	var stored: String = v.ensure_victory_code()
	failed = _check(rows, failed, "victory.code.stored",
		stored == code_a and v.victory_code == code_a, stored) or failed
	v.save_state()
	var v2: PlaytestCommitment = C.new()
	v2.load_state()
	failed = _check(rows, failed, "victory.code.persist",
		v2.victory_code == code_a, v2.victory_code) or failed
	v.mark_offramp_shown(C.M_BIG)
	failed = _check(rows, failed, "victory.shown_once",
		not v.should_offramp(C.M_BIG) and bool(v.offramp_shown_big), "") or failed
	failed = _check(rows, failed, "victory.retrigger",
		v.debug_retrigger_offramp(C.M_BIG) and v.should_offramp(C.M_BIG), "") or failed

	## Victory UI: empty Discord disables; payload includes code.
	var win = VICTORY.new()
	o_host.add_child(win)
	win.call("setup")
	win.call("open_victory", code_a, {
		"tier": C.TIER_BIG,
		"run_count": 4,
		"anon_id": "anon-test-1",
		"build_id": "slice4",
		"biomes_unlocked": 5,
		"cabinet_count": 9,
		"play_seconds": 9000,
	})
	failed = _check(rows, failed, "victory.ui_shows", bool(win.visible), "") or failed
	var discord_btn = win.get("_btn_discord")
	failed = _check(rows, failed, "victory.discord_disabled_empty",
		discord_btn != null and bool(discord_btn.disabled), "") or failed
	var soon := str(discord_btn.text) if discord_btn else ""
	failed = _check(rows, failed, "victory.discord_soon_label",
		soon.find("soon") >= 0 or soon == COPY.text("playtest.victory.discord_soon", "Discord link coming soon"), soon) or failed
	var v_payload: Dictionary = win.call("build_payload")
	failed = _check(rows, failed, "victory.payload_shape",
		VICTORY.payload_shape_ok(v_payload), "%s" % str(v_payload.keys())) or failed
	failed = _check(rows, failed, "victory.payload_code",
		str(v_payload.get("victory_code", "")) == code_a, str(v_payload.get("victory_code", ""))) or failed
	## No Go deeper on victory.
	failed = _check(rows, failed, "victory.no_deeper_btn",
		win.get("_btn_deeper") == null, "") or failed
	win.call("close_panel")
	win.call("open_code_card", code_a, {"anon_id": "anon-test-1"})
	failed = _check(rows, failed, "victory.code_card",
		bool(win.visible) and bool(win.call("is_code_card")), "") or failed
	win.call("close_panel")
	win.queue_free()

	## Offramp still refuses big (separate victory panel).
	failed = _check(rows, failed, "offramp.still_not_big",
		not OFFRAMP.shows_for_milestone(C.M_BIG), "") or failed

	failed = _check(rows, failed, "copy.victory.title",
		COPY.text("playtest.victory.title", "") != "", "") or failed
	failed = _check(rows, failed, "copy.victory.big.q1",
		COPY.text("playtest.offramp.big.q1", "") != "", "") or failed
	failed = _check(rows, failed, "copy.pause.victory_code",
		COPY.text("pause.victory_code", "") != "", "") or failed
	failed = _check(rows, failed, "main.victory_preload",
		main_src.find("playtest_victory.gd") >= 0, "") or failed
	failed = _check(rows, failed, "main.victory_open",
		main_src.find("open_victory") >= 0 or main_src.find("_maybe_open_commitment_victory") >= 0, "") or failed
	failed = _check(rows, failed, "links.file",
		FileAccess.file_exists("res://data/playtest-links.json"), "") or failed

	_print_rows(rows)
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _assert_visual_copy_keys(rows: Array, failed: bool) -> bool:
	## Every literal copy key read by title_screen / settings_panel must exist in player-copy.json.
	var paths: Array[String] = [
		"res://scripts/ui/title_screen.gd",
		"res://scripts/ui/settings_panel.gd",
	]
	var found: Dictionary = {} ## key -> true
	var re := RegEx.new()
	re.compile("\"((?:title|settings|biome|pause|intro|picker|playtest)\\.[a-z0-9_.]+)\"")
	for path in paths:
		var src := FileAccess.get_file_as_string(path)
		for m in re.search_all(src):
			var k: String = str(m.get_string(1))
			if k.ends_with("."):
				continue
			## Expand sprintf templates used by the visual layer.
			if k == "title.menu.%s" or k.ends_with(".%s"):
				var stem := k.trim_suffix("%s")
				match stem:
					"title.menu.":
						for id in ["continue", "new_game", "settings", "feedback", "start_over"]:
							found[stem + id] = true
					"biome.name.":
						for id in ["verdant", "crystal", "ashen", "cinder", "shadow"]:
							found[stem + id] = true
					_:
						pass
				continue
			found[k] = true
	## Always require the Pixel key set Nathan named for this screen.
	for k in [
		"title.menu.continue", "title.menu.new_game", "title.menu.settings",
		"title.menu.feedback", "title.menu.start_over",
		"title.start_over.ask", "title.start_over.body", "title.start_over.no", "title.start_over.yes",
		"settings.sparkles.on", "settings.sparkles.off",
		"settings.invert_scroll.on", "settings.invert_scroll.off",
		"settings.reduce_motion.on", "settings.reduce_motion.off", "settings.back", "settings.sound",
		"intro.preview.caption",
	]:
		found[k] = true
	var missing: Array[String] = []
	for k in found.keys():
		var ks := str(k)
		if not COPY.has_key(ks):
			missing.append(ks)
			continue
		## Labels must never fall through to a raw key name — text must be non-empty.
		if COPY.text(ks, "") == "":
			missing.append("%s(empty)" % ks)
	missing.sort()
	return _check(
		rows,
		failed,
		"copy.visual_keys_present",
		missing.is_empty(),
		",".join(missing)
	)


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
