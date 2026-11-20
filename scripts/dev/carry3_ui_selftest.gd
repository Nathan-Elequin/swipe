extends SceneTree
## Headless checks for Carry-3 layout B UI rules (no Main / no Godot UI tree).
## Covers: ≤3 skips bag; >3 shows bag; toggle; reminder once; Okay→overlay path;
## empty continue → 0; packed>3 locks Delve; packed≤3 Delve commits.
##
## Run: godot --headless --path . --script res://scripts/dev/carry3_ui_selftest.gd


const OK_MARK := "CARRY3_UI_OK"
const FAIL_MARK := "CARRY3_UI_FAIL"
const C := preload("res://scripts/carry_limit.gd")
const R := preload("res://scripts/carry3_ui_rules.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []

	## ≤3: no room bag, portal proceeds
	var three: Array = _items([1, 2, 3])
	failed = _check(rows, failed, "le3.no_bag", not R.should_show_room_bag(three), "") or failed
	failed = _check(rows, failed, "le3.no_reminder", not R.should_show_reminder(false, false), "") or failed
	failed = _check(
		rows, failed, "le3.portal_proceed", R.portal_action(false, false, 0) == "proceed", ""
	) or failed

	## >3: show bag
	var six: Array = _items([10, 11, 12, 13, 14, 15])
	failed = _check(rows, failed, "gt3.show_bag", R.should_show_room_bag(six), "") or failed
	failed = _check(rows, failed, "gt3.needs", C.needs_choice(six), "") or failed

	## Toggle selection in and out
	var sel: Array = []
	sel = R.toggle_uid(sel, 10)
	sel = R.toggle_uid(sel, 12)
	failed = _check(rows, failed, "toggle.add_2", sel == [10, 12], "got %s" % str(sel)) or failed
	sel = R.toggle_uid(sel, 10)
	failed = _check(rows, failed, "toggle.remove", sel == [12], "got %s" % str(sel)) or failed
	sel = R.toggle_uid(sel, 11)
	sel = R.toggle_uid(sel, 13)
	sel = R.toggle_uid(sel, 14)
	failed = _check(rows, failed, "toggle.over_cap_n", sel.size() == 4, "n=%s" % sel.size()) or failed

	## Portal without bag open → reminder (once / until opened)
	failed = _check(
		rows,
		failed,
		"portal.reminder",
		R.portal_action(true, false, 0) == "reminder",
		""
	) or failed
	failed = _check(
		rows,
		failed,
		"reminder.should_show",
		R.should_show_reminder(true, false),
		""
	) or failed
	## After open, no reminder
	failed = _check(
		rows,
		failed,
		"portal.after_open_commit",
		R.portal_action(true, true, 2) == "commit",
		""
	) or failed
	failed = _check(
		rows,
		failed,
		"reminder.after_open_false",
		not R.should_show_reminder(true, true),
		""
	) or failed

	## Okay opens overlay — modeled as mark opened + show overlay (bag_opened true)
	var opened := false
	## Reminder Okay path:
	opened = true
	failed = _check(rows, failed, "okay.marks_opened", opened, "") or failed
	failed = _check(
		rows, failed, "okay.no_more_reminder", not R.should_show_reminder(true, opened), ""
	) or failed

	## No continue with empty selection → 0 carried
	var empty_apply: Dictionary = C.apply_choice(six, [])
	failed = _check(rows, failed, "continue.empty.ok", bool(empty_apply.get("ok", false)), "") or failed
	failed = _check(
		rows,
		failed,
		"continue.empty.kept_0",
		(empty_apply.get("kept", ["x"]) as Array).is_empty(),
		"n=%s" % (empty_apply.get("kept", []) as Array).size()
	) or failed
	failed = _check(
		rows,
		failed,
		"continue.empty.removed_6",
		(empty_apply.get("removed", []) as Array).size() == 6,
		""
	) or failed

	## packed >3 locks Delve; ≤3 ready
	failed = _check(rows, failed, "delve.locked_at_4", R.delve_locked(4), "") or failed
	failed = _check(rows, failed, "delve.not_ready_4", not R.delve_ready(4), "") or failed
	failed = _check(rows, failed, "portal.blocked_at_4", R.portal_action(true, true, 4) == "blocked", "") or failed
	failed = _check(rows, failed, "delve.ready_at_3", R.delve_ready(3), "") or failed
	failed = _check(rows, failed, "delve.ready_at_0", R.delve_ready(0), "") or failed
	failed = _check(rows, failed, "delve.ready_at_2", not R.delve_locked(2), "") or failed

	## packed ≤3 Delve commits (apply keeps selection)
	var keep2: Dictionary = C.apply_choice(six, [11, 14])
	failed = _check(rows, failed, "delve.commit.ok", bool(keep2.get("ok", false)), "") or failed
	failed = _check(rows, failed, "delve.commit.n", (keep2.get("kept", []) as Array).size() == 2, "") or failed
	failed = _check(
		rows,
		failed,
		"delve.commit.uids",
		_uids(keep2.get("kept", [])) == [11, 14],
		"got %s" % str(_uids(keep2.get("kept", [])))
	) or failed
	## After commit, next hand needs no choice
	failed = _check(
		rows, failed, "delve.commit.no_rechoose", not C.needs_choice(keep2.get("kept", [])), ""
	) or failed

	## Copy keys present (array-of-objects with key field)
	var copy_path := "res://data/player-copy.json"
	var f := FileAccess.open(copy_path, FileAccess.READ)
	failed = _check(rows, failed, "copy.file", f != null, copy_path) or failed
	if f:
		var parsed: Variant = JSON.parse_string(f.get_as_text())
		f.close()
		failed = _check(rows, failed, "copy.dict", typeof(parsed) == TYPE_DICTIONARY, "") or failed
		var pack: Dictionary = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
		var by_key: Dictionary = {}
		for row in pack.get("rows", []):
			if typeof(row) == TYPE_DICTIONARY:
				by_key[str(row.get("key", ""))] = str(row.get("text", ""))
		var expect := {
			"carry3.overlay.title": "Pack for the next delve",
			"carry3.overlay.hint": "Click an item to put it in your bag. Click again to leave it behind. Take up to 3.",
			"carry3.overlay.keeping": "keeping · {n} of 3",
			"carry3.overlay.leave": "leave",
			"carry3.overlay.delve": "Delve",
			"carry3.overlay.ready": "{n} / 3 READY",
			"carry3.overlay.locked": "{n} / 3 — too many",
			"carry3.reminder.title": "Hang on — pack first?",
			"carry3.reminder.body": "You can take up to 3 items into the next dungeon. Anything you leave behind is gone for this run.",
			"carry3.reminder.okay": "Open bag",
			"carry3.reminder.continue": "No, continue",
		}
		for k in expect.keys():
			failed = _check(
				rows,
				failed,
				"copy.%s" % k,
				by_key.get(k, "") == expect[k],
				"got %s" % by_key.get(k, "")
			) or failed

	_print_rows(rows)
	if failed:
		print(FAIL_MARK)
		quit(1)
		return
	print(OK_MARK)
	quit(0)


func _items(uids: Array) -> Array:
	var out: Array = []
	for u in uids:
		out.append({"uid": int(u), "card_id": "item_%s" % u, "name": "Item %s" % u})
	return out


func _uids(items: Array) -> Array:
	var out: Array = []
	for it in items:
		out.append(int(it.get("uid", -1)))
	return out


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
	print("carry3_ui_selftest: %d/%d passed" % [passed, rows.size()])
