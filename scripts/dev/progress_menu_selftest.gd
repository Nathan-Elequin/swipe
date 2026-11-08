extends SceneTree
## Progress menu presentation + copy + can_start guards. Does NOT boot main.tscn.
## Runner isolates XDG_DATA_HOME. Row kinds: ASSERT / STATIC / NOTE.


const OK_MARK := "PROGRESS_MENU_CEREMONY_OK"
const FAIL_MARK := "PROGRESS_MENU_CEREMONY_FAIL"
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

var _failed := false
var _rows: Array = []
var _menu: CanvasLayer
var _acked: Array = []
var _start_emitted := false
var _present_done := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	PLAYER_COPY.reload()
	var MenuScr = load("res://scripts/ui/progress_menu.gd")
	_failed = _assert(
		"META.menu_script_loads",
		"progress_menu.gd loads",
		MenuScr != null,
		"scr=%s" % str(MenuScr)
	) or _failed
	if MenuScr == null:
		_finish()
		return

	_menu = MenuScr.new()
	root.add_child(_menu)
	await process_frame

	var expected := {
		"postrun.title": "Run Results",
		"postrun.skip": "Skip Recap",
		"postrun.summary.success_none": "Made it home. No new item types added.",
		"postrun.summary.tutorial": "Tutorial complete. Tutorial items don't count toward collection progress.",
		"postrun.hand_note": "Each new run starts with 6 random items from unlocked pools.",
		"postrun.button.start_default": "Start New Run",
	}
	for k in expected.keys():
		var got := PLAYER_COPY.text(str(k), "")
		_failed = _assert(
			"COPY.%s" % str(k).replace(".", "_"),
			"exact copy %s" % k,
			got == str(expected[k]),
			"got=%s" % got
		) or _failed

	var rules := {
		"cabinet_quota": 5,
		"starter_item_mix": [3, 2, 1],
		"biomes": [
			{"id": "b1", "name": "Verdant Hollow"},
			{"id": "b2", "name": "Ashen Reach"},
		],
	}
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	CAMPAIGN_SHELL.normalize(state)

	_failed = _assert(
		"SHELL.hook_count_6",
		"starter_hook_count is 6 for [3,2,1]",
		CAMPAIGN_SHELL.starter_hook_count(rules) == 6,
		"n=%s" % CAMPAIGN_SHELL.starter_hook_count(rules)
	) or _failed
	_failed = _assert(
		"SHELL.can_start_b1",
		"b1 always can_start",
		CAMPAIGN_SHELL.can_start(rules, state, 0),
		""
	) or _failed
	_failed = _assert(
		"SHELL.no_can_start_b2_early",
		"b2 not can_start before D3 unlock shortcut",
		not CAMPAIGN_SHELL.can_start(rules, state, 1),
		""
	) or _failed

	var items := {
		"net": {"id": "net", "name": "Net", "pool": "b1"},
		"knife": {"id": "knife", "name": "Knife", "pool": "b1"},
		"shield": {"id": "shield", "name": "Shield", "pool": "b1"},
	}
	var swiped := {"net": true, "knife": true}

	## --- Win + Skip Recap ---
	_acked.clear()
	_start_emitted = false
	_present_done = false
	if not _menu.start_run_wanted.is_connected(_on_start_emitted):
		_menu.start_run_wanted.connect(_on_start_emitted)
	_kick_present({
		"kind": "win",
		"new_ids": ["net", "knife"],
		"held_ids": ["net", "knife"],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": swiped,
		"rules": rules,
		"state": state,
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.25).timeout
	_failed = _assert(
		"UI.open_after_present",
		"menu visible during present",
		_menu.visible and _menu.is_open(),
		"vis=%s" % _menu.visible
	) or _failed
	_menu.call("_on_skip")
	await create_timer(0.15).timeout
	_failed = _assert(
		"UI.skip_no_autolaunch",
		"Skip Recap does not emit start_run",
		not _start_emitted,
		"start_emitted=%s" % _start_emitted
	) or _failed
	_failed = _assert(
		"UI.skip_acks_new",
		"Skip acks new ids",
		_acked.has("net") and _acked.has("knife"),
		"acked=%s" % str(_acked)
	) or _failed
	_menu.call("_on_cabin")
	await _wait_present_done(2.0)
	_failed = _assert(
		"UI.present_awaits_dismiss",
		"present returns after dismiss",
		_present_done,
		"present_done=%s" % _present_done
	) or _failed
	_failed = _assert(
		"UI.closed_hides",
		"menu hidden after cabin dismiss",
		not _menu.visible,
		"vis=%s" % _menu.visible
	) or _failed

	## --- Tutorial ---
	_present_done = false
	_kick_present({
		"kind": "tutorial",
		"new_ids": [],
		"held_ids": [],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": {},
		"rules": rules,
		"state": state,
		"push_block": false,
		"tutorial": true,
	})
	await create_timer(0.3).timeout
	var summary: Label = _menu.get("_summary")
	var summary_text := str(summary.text) if summary != null else ""
	_failed = _assert(
		"UI.tutorial_summary",
		"tutorial uses exact postrun.summary.tutorial",
		summary_text == PLAYER_COPY.text("postrun.summary.tutorial", ""),
		"got=%s" % summary_text
	) or _failed
	_menu.dismiss()
	await _wait_present_done(2.0)

	## --- Death ---
	_present_done = false
	_kick_present({
		"kind": "loss",
		"new_ids": [],
		"held_ids": [],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": swiped,
		"rules": rules,
		"state": state,
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.3).timeout
	summary = _menu.get("_summary")
	summary_text = str(summary.text) if summary != null else ""
	var expect_death := PLAYER_COPY.fill(
		"postrun.summary.death",
		{"area": "Verdant Hollow"},
		""
	)
	_failed = _assert(
		"UI.death_summary",
		"loss uses exact death summary",
		summary_text == expect_death,
		"got=%s expect=%s" % [summary_text, expect_death]
	) or _failed
	_menu.dismiss()
	await _wait_present_done(2.0)

	## Static wires
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	var menu_src := FileAccess.get_file_as_string("res://scripts/ui/progress_menu.gd")
	_failed = _static(
		"STATIC.main_opens_progress_menu",
		"main defines _open_progress_menu and routes win/loss/tutorial",
		main_src.find("func _open_progress_menu") >= 0
		and main_src.find('_open_progress_menu("win"') >= 0
		and main_src.find('_open_progress_menu("loss"') >= 0
		and main_src.find('_open_progress_menu("tutorial"') >= 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.cabin_meta_gate",
		"cabin gates S7 resume on progress_menu_handled_return",
		cabin_src.find("progress_menu_handled_return") >= 0
		and cabin_src.find("_resume_pending_bank_if_idle") >= 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.menu_can_start_only",
		"progress menu gates Start New Run on can_start",
		menu_src.find("can_start") >= 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.hand_note_gated",
		"hand_note omitted unless starter mix sums to 6",
		menu_src.find("starter_item_mix") >= 0 and menu_src.find("hand_note omitted") >= 0,
		""
	) or _failed

	_rows.append({
		"kind": "NOTE",
		"id": "NOTE.headed_screenshots",
		"ok": true,
		"detail": "1680x1040 headed shots still needed under isolated profile; this suite is headless protocol only.",
	})
	print("NOTE NOTE.headed_screenshots — %s" % _rows[-1]["detail"])

	_finish()


func _on_start_emitted(_i: int) -> void:
	_start_emitted = true


func _on_ack(id: String) -> void:
	_acked.append(id)


func _kick_present(payload: Dictionary) -> void:
	## Fire-and-forget present; completion tracked via _present_done.
	_present_async(payload)


func _present_async(payload: Dictionary) -> void:
	await _menu.present(payload, Callable(self, "_on_ack"))
	_present_done = true


func _wait_present_done(sec: float) -> void:
	var left := sec
	while not _present_done and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05


func _assert(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({
		"kind": "ASSERT",
		"id": id,
		"desc": desc,
		"ok": cond,
		"detail": detail,
	})
	print("%s ASSERT %s — %s%s" % [
		"PASS" if cond else "FAIL",
		id,
		desc,
		(" (%s)" % detail) if detail != "" else "",
	])
	return not cond


func _static(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({
		"kind": "STATIC",
		"id": id,
		"desc": desc,
		"ok": cond,
		"detail": detail,
	})
	print("%s STATIC %s — %s%s" % [
		"PASS" if cond else "FAIL",
		id,
		desc,
		(" (%s)" % detail) if detail != "" else "",
	])
	return not cond


func _finish() -> void:
	var n_fail := 0
	for r in _rows:
		if typeof(r) == TYPE_DICTIONARY and not bool(r.get("ok", true)) and str(r.get("kind", "")) in ["ASSERT", "STATIC"]:
			n_fail += 1
	print("---")
	print("rows=%d fail=%d" % [_rows.size(), n_fail])
	if _failed or n_fail > 0:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
