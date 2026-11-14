extends SceneTree
## Package A: legacy Outpost / progress-menu save migration (headless).
## Run: ./tools/qa/run_legacy_removal.sh

const OK_MARK := "LEGACY_REMOVAL_OK"
const FAIL_MARK := "LEGACY_REMOVAL_FAIL"

const REMOVED_LAYOUT_IDS := ["mudroom", "RunDoor", "SignOutpost"]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []

	var CabinScr = load("res://scripts/home_cabin.gd")
	failed = _assert(rows, failed, "META.cabin_script_loads", CabinScr != null, "") or failed
	if CabinScr == null:
		_finish(failed, rows)
		return

	## --- Fixture: save_mudroom.json ---
	var mud: Dictionary = _load_fixture("res://tests/fixtures/save_mudroom.json")
	failed = _assert(rows, failed, "FIX.mudroom_fixture", not mud.is_empty(), "") or failed
	var cabin_a: Node = CabinScr.new()
	cabin_a.set("_persist_writes", false)
	cabin_a.set_process(false)
	cabin_a.set_physics_process(false)
	root.add_child(cabin_a)
	cabin_a.call("_read_v2", mud)
	failed = _assert(
		rows,
		failed,
		"MUD.rooms_stripped",
		not cabin_a.get("rooms_unlocked").has("mudroom"),
		"rooms=%s" % str(cabin_a.get("rooms_unlocked"))
	) or failed
	failed = _assert(
		rows,
		failed,
		"MUD.return_not_mudroom",
		str(cabin_a.get("return_room")) != "mudroom",
		"return=%s" % cabin_a.get("return_room")
	) or failed
	failed = _assert(
		rows,
		failed,
		"MUD.return_hall_when_unlocked",
		str(cabin_a.get("return_room")) == "hall",
		"return=%s" % cabin_a.get("return_room")
	) or failed
	var save_path_a := "user://legacy_removal_mudroom_probe.json"
	cabin_a.set("_save_path_override", save_path_a)
	cabin_a.set("_persist_writes", true)
	cabin_a.call("_save")
	var disk_a := _read_json_user(save_path_a)
	failed = _assert(
		rows,
		failed,
		"MUD.save_no_mudroom_loadout",
		not disk_a.has("mudroom_loadout"),
		"keys=%s" % str(disk_a.keys())
	) or failed
	failed = _assert(
		rows,
		failed,
		"MUD.save_no_mudroom_unlock",
		not (disk_a.get("rooms_unlocked", []) as Array).has("mudroom"),
		"rooms=%s" % str(disk_a.get("rooms_unlocked"))
	) or failed
	cabin_a.queue_free()

	## --- Fixture: save_progress_menu_mid.json ---
	var mid: Dictionary = _load_fixture("res://tests/fixtures/save_progress_menu_mid.json")
	failed = _assert(rows, failed, "FIX.mid_fixture", not mid.is_empty(), "") or failed
	var cabin_b: Node = CabinScr.new()
	cabin_b.set("_persist_writes", false)
	cabin_b.set_process(false)
	cabin_b.set_physics_process(false)
	root.add_child(cabin_b)
	## _read_v2 alone does not hydrate seen/swiped (that is _load_save). Seed them
	## so _restore_bank_hold_from_pending keeps fixture bank_pending rows.
	for sid in mid.get("swiped", []):
		cabin_b.swiped[str(sid)] = true
		cabin_b.seen[str(sid)] = true
	for sid2 in mid.get("seen", []):
		cabin_b.seen[str(sid2)] = true
	cabin_b.call("_read_v2", mid)
	failed = _assert(
		rows,
		failed,
		"MID.read_no_crash",
		cabin_b.get("bank_pending").size() == 2,
		"pending=%s" % str(cabin_b.get("bank_pending"))
	) or failed
	failed = _assert(
		rows,
		failed,
		"MID.no_mudroom_unlock",
		not cabin_b.get("rooms_unlocked").has("mudroom"),
		"rooms=%s" % str(cabin_b.get("rooms_unlocked"))
	) or failed
	var save_path_b := "user://legacy_removal_mid_probe.json"
	cabin_b.set("_save_path_override", save_path_b)
	cabin_b.set("_persist_writes", true)
	cabin_b.call("_save")
	var disk_b := _read_json_user(save_path_b)
	failed = _assert(
		rows,
		failed,
		"MID.save_no_mudroom_keys",
		not disk_b.has("mudroom_loadout")
			and not (disk_b.get("rooms_unlocked", []) as Array).has("mudroom"),
		"disk=%s" % str(disk_b)
	) or failed
	cabin_b.queue_free()

	## --- Source / layout grep: removed ids must not appear as live rooms ---
	var cabin_src := _read_source("res://scripts/home_cabin.gd")
	var order_hit := false
	for rid in REMOVED_LAYOUT_IDS:
		if cabin_src.find('"%s"' % rid) >= 0 or cabin_src.find("'%s'" % rid) >= 0:
			## migration comments may mention mudroom; ROOM_ORDER must not list removed rooms.
			if _room_order_lists_id(cabin_src, rid):
				order_hit = true
	failed = _assert(
		rows,
		failed,
		"GREP.room_order_clean",
		not order_hit,
		"removed id still in ROOM_ORDER"
	) or failed

	var layout_text := _read_source("res://data/cabin-layout.json")
	var layout_hits: Array = []
	for lid in REMOVED_LAYOUT_IDS:
		if layout_text.find('"%s"' % lid) >= 0:
			layout_hits.append(lid)
	failed = _assert(
		rows,
		failed,
		"GREP.cabin_layout_clean",
		layout_hits.is_empty(),
		"hits=%s" % str(layout_hits)
	) or failed

	var home_src := _read_source("res://scripts/home_cabin.gd")
	failed = _assert(
		rows,
		failed,
		"STATIC.no_progress_menu_entrypoints",
		home_src.find("open_cabin_after_progress_menu") < 0
			and home_src.find("open_hall_after_push_block") < 0,
		""
	) or failed
	var main_src := _read_source("res://scripts/main.gd")
	failed = _assert(
		rows,
		failed,
		"STATIC.main_has_go_home",
		main_src.find("func _go_home") >= 0,
		""
	) or failed
	failed = _assert(
		rows,
		failed,
		"STATIC.go_home_walk_in",
		_func_body_contains(main_src, "func _go_home(", "open_cabin")
			and _func_body_contains(main_src, "func _go_home(", "true"),
		""
	) or failed

	_finish(failed, rows)


func _room_order_lists_id(src: String, id: String) -> bool:
	var start := src.find("const ROOM_ORDER")
	if start < 0:
		return false
	var chunk := src.substr(start, mini(200, src.length() - start))
	return chunk.find('"%s"' % id) >= 0 or chunk.find("'%s'" % id) >= 0


func _load_fixture(res_path: String) -> Dictionary:
	var path := ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


func _read_json_user(user_path: String) -> Dictionary:
	var path := ProjectSettings.globalize_path(user_path)
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


func _read_source(res_path: String) -> String:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _func_body_contains(src: String, sig: String, needle: String) -> bool:
	var start: int = src.find(sig)
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	return body.find(needle) >= 0


func _assert(rows: Array, failed: bool, id: String, ok: bool, detail: String) -> bool:
	rows.append({"kind": "ASSERT", "id": id, "ok": ok, "detail": detail})
	if ok:
		print("PASS ASSERT %s" % id)
		return failed
	print("FAIL ASSERT %s (%s)" % [id, detail])
	push_error("%s %s (%s)" % [FAIL_MARK, id, detail])
	return true


func _finish(failed: bool, rows: Array) -> void:
	var fails := 0
	for raw in rows:
		var r: Dictionary = raw
		if str(r.get("kind", "")) == "ASSERT" and not bool(r.get("ok", false)):
			fails += 1
	if failed or fails > 0:
		print(FAIL_MARK)
		quit(1)
		return
	print(OK_MARK)
	quit(0)