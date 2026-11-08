extends SceneTree
## House-room unlock after first successful full dungeon return.
## Does NOT boot main.tscn. Does NOT write live user:// saves.
##
## Cases:
##   - tutorial-only win arrive (lifetime clears 0) → NO haul / rooms stay main
##   - death/loss → NO haul / rooms stay main
##   - success with 0 new uniques → haul + doors sync / keyring due
##   - success with 3 new uniques → same
##   - interrupted recovery: hauls>=1 + partial rooms → _sync_progress_doors fills rest
##
## Run: ./tools/qa/run_house_unlock_first_return.sh


const OK_MARK := "HOUSE_UNLOCK_FIRST_RETURN_OK"
const FAIL_MARK := "HOUSE_UNLOCK_FIRST_RETURN_FAIL"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []

	var probe_path := ProjectSettings.globalize_path("user://home_cabin.json")
	var before_meta := _file_meta(probe_path)

	var CabinScr = load("res://scripts/home_cabin.gd")
	failed = _assert(
		rows, failed, "META.cabin_script_loads",
		"home_cabin.gd loads",
		CabinScr != null,
		"scr=%s" % str(CabinScr)
	) or failed
	if CabinScr == null:
		_finish(failed, rows)
		return

	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set("_save_path_override", "")
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)

	failed = _assert(
		rows, failed, "SAFE.persist_writes_false",
		"_persist_writes disabled on bare instance",
		cabin.get("_persist_writes") == false,
		"persist=%s" % str(cabin.get("_persist_writes"))
	) or failed

	## Fresh defaults.
	cabin.call("_apply_defaults")
	failed = _assert(
		rows, failed, "FRESH.rooms_main_only",
		"fresh save starts with main only",
		_rooms_eq(cabin, ["main"]),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed
	failed = _assert(
		rows, failed, "FRESH.no_haul",
		"fresh hauls=0 key_ring_seen=false lifetime=0",
		int(cabin.get("counters").get("hauls", -1)) == 0
			and cabin.get("key_ring_seen") == false
			and int(cabin.get("lifetime_dungeons_cleared")) == 0,
		"counters=%s key=%s life=%s" % [
			str(cabin.get("counters")), cabin.get("key_ring_seen"), cabin.get("lifetime_dungeons_cleared")
		]
	) or failed

	## --- Tutorial-only (win kind, no dungeon clear) ---
	cabin.call("_apply_defaults")
	cabin.set("tutorial_done", true)
	cabin.set("_homecoming_kind", "win")
	cabin.set("_new_ids", [])
	cabin.set("_held_ids", [])
	cabin.set("lifetime_dungeons_cleared", 0)
	failed = _assert(
		rows, failed, "GATE.tutorial_not_success",
		"tutorial win is not a successful dungeon return",
		cabin.call("counts_as_successful_dungeon_return", "win") == false,
		"life=%s" % cabin.get("lifetime_dungeons_cleared")
	) or failed
	var want_tut: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "TUT.no_haul_credit",
		"tutorial credit does not bump hauls or request keyring",
		want_tut == false and int(cabin.get("counters").get("hauls", -1)) == 0,
		"want=%s hauls=%s" % [want_tut, cabin.get("counters").get("hauls", -1)]
	) or failed
	cabin.call("_sync_progress_doors")
	failed = _assert(
		rows, failed, "TUT.rooms_stay_main",
		"tutorial alone does not unlock house rooms",
		_rooms_eq(cabin, ["main"]),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed

	## --- Death / loss ---
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "loss")
	failed = _assert(
		rows, failed, "GATE.loss_not_success",
		"loss is not a successful dungeon return even after a prior clear tally",
		cabin.call("counts_as_successful_dungeon_return", "loss") == false,
		"kind=loss life=1"
	) or failed
	var want_loss: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "LOSS.no_haul",
		"death credits losses only",
		want_loss == false
			and int(cabin.get("counters").get("hauls", -1)) == 0
			and int(cabin.get("counters").get("losses", -1)) == 1,
		"want=%s counters=%s" % [want_loss, str(cabin.get("counters"))]
	) or failed
	cabin.call("_sync_progress_doors")
	failed = _assert(
		rows, failed, "LOSS.rooms_stay_main",
		"death does not unlock house rooms",
		_rooms_eq(cabin, ["main"]),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed

	## --- Success with 0 new uniques ---
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "win")
	cabin.set("_new_ids", [])
	cabin.set("_held_ids", ["boot", "net"]) ## held, but none NEW
	failed = _assert(
		rows, failed, "GATE.success_0_new",
		"cleared dungeon + win counts even with 0 new uniques",
		cabin.call("counts_as_successful_dungeon_return", "win") == true,
		"life=%s new=%s" % [cabin.get("lifetime_dungeons_cleared"), str(cabin.get("_new_ids"))]
	) or failed
	var want_0: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "WIN0.haul_and_key_due",
		"0-new success credits haul and requests keyring",
		want_0 == true and int(cabin.get("counters").get("hauls", -1)) == 1,
		"want=%s hauls=%s rooms=%s" % [
			want_0, cabin.get("counters").get("hauls", -1), str(cabin.get("rooms_unlocked"))
		]
	) or failed
	failed = _assert(
		rows, failed, "WIN0.doors_synced",
		"haul sync unlocks navigation rooms (interrupted-flow recovery path)",
		cabin.get("rooms_unlocked").has("hall")
			and cabin.get("rooms_unlocked").has("study")
			and cabin.get("rooms_unlocked").has("workshop")
			and cabin.get("rooms_unlocked").has("loft")
			and cabin.get("rooms_unlocked").has("mudroom"),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed

	## --- Success with 3 new uniques ---
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "win")
	cabin.set("_new_ids", ["net", "lantern", "caltrops"])
	cabin.set("_held_ids", ["net", "lantern", "caltrops"])
	var want_3: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "WIN3.haul_and_key_due",
		"3-new success credits haul and requests keyring (same house rule)",
		want_3 == true and int(cabin.get("counters").get("hauls", -1)) == 1,
		"want=%s hauls=%s new=%s" % [
			want_3, cabin.get("counters").get("hauls", -1), str(cabin.get("_new_ids"))
		]
	) or failed

	## --- Interrupted-flow recovery: hauls already credited, partial rooms ---
	cabin.call("_apply_defaults")
	cabin.set("key_ring_seen", false)
	cabin.set("rooms_unlocked", ["main", "hall"])
	cabin.set("counters", {"delves": 1, "homecomings": 1, "hauls": 1, "losses": 0})
	cabin.call("_sync_progress_doors")
	failed = _assert(
		rows, failed, "RECOVER.partial_fills_rest",
		"hauls>=1 recovers remaining rooms without needing key_ring_seen",
		cabin.get("rooms_unlocked").has("study")
			and cabin.get("rooms_unlocked").has("workshop")
			and cabin.get("rooms_unlocked").has("loft")
			and cabin.get("rooms_unlocked").has("mudroom"),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed

	## --- Source contracts: arrive/push-block/progress-menu use the shared credit helper ---
	var src := _read_source("res://scripts/home_cabin.gd")
	failed = _assert(
		rows, failed, "STATIC.has_gate_helper",
		"counts_as_successful_dungeon_return exists",
		src.find("func counts_as_successful_dungeon_return") >= 0,
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.credit_helper",
		"_credit_homecoming_counters exists",
		src.find("func _credit_homecoming_counters") >= 0,
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.arrive_uses_credit",
		"arrive finalizer calls _credit_homecoming_counters",
		src.find("_credit_homecoming_counters()") >= 0,
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.push_block_uses_credit",
		"open_hall_after_push_block credits haul for house unlock",
		_func_body_contains(src, "func open_hall_after_push_block", "_credit_homecoming_counters"),
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.progress_menu_api_credits",
		"open_cabin_after_progress_menu credits haul for house unlock",
		_func_body_contains(src, "func open_cabin_after_progress_menu", "_credit_homecoming_counters"),
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.gate_uses_lifetime",
		"house gate keys off lifetime_dungeons_cleared (not unique count)",
		_func_body_contains(src, "func counts_as_successful_dungeon_return", "lifetime_dungeons_cleared"),
		""
	) or failed

	## Live Pixel path: finalize must open cabin via credit API (not bare walk_in=false).
	var main_src := _read_source("res://scripts/main.gd")
	failed = _assert(
		rows, failed, "STATIC.finalize_uses_progress_credit",
		"finalize cabin path calls open_cabin_after_progress_menu (credits haul on win)",
		_func_body_contains(
			main_src,
			"func _finalize_progress_menu_result",
			"open_cabin_after_progress_menu"
		),
		""
	) or failed
	failed = _assert(
		rows, failed, "STATIC.finalize_passes_kind",
		"finalize preserves progress-menu kind (no hardcoded win-only cabin open)",
		_func_body_contains(
			main_src,
			"func _finalize_progress_menu_result",
			'result.get("kind"'
		),
		""
	) or failed
	## Regression: win finalize must not open cabin without credit helper.
	failed = _assert(
		rows, failed, "STATIC.finalize_no_bare_win_cabin",
		"finalize must not call _open_home_cabin(false, \"win\") as the only cabin path",
		not _func_body_contains(
			main_src,
			"func _finalize_progress_menu_result",
			'_open_home_cabin(false, "win"'
		),
		""
	) or failed

	var menu_src := _read_source("res://scripts/ui/progress_menu.gd")
	failed = _assert(
		rows, failed, "STATIC.menu_returns_kind",
		"progress_menu present() stamps kind onto result for finalize",
		menu_src.find('out["kind"]') >= 0 or menu_src.find("out[\"kind\"]") >= 0,
		""
	) or failed

	## Runtime: progress-menu API credits haul on win + lifetime>=1 (0 new uniques).
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("key_ring_seen", true) ## skip key-ring await in headless
	cabin.set("_persist_writes", false)
	## Simulate open_cabin_after_progress_menu credit body without awaiting UI.
	cabin.set("_homecoming_kind", "win")
	cabin.set("_new_ids", [])
	cabin.set("_held_ids", [])
	var want_pm: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "PMENU.win_credits_haul",
		"progress-menu win path credits haul when lifetime>=1",
		want_pm == false ## key_ring_seen true → want_key false, but haul still bumps
			and int(cabin.get("counters").get("hauls", -1)) == 1,
		"want=%s hauls=%s" % [want_pm, cabin.get("counters").get("hauls", -1)]
	) or failed
	cabin.call("_sync_progress_doors")
	failed = _assert(
		rows, failed, "PMENU.win_unlocks_rooms",
		"progress-menu win haul unlocks house rooms",
		cabin.get("rooms_unlocked").has("hall"),
		"rooms=%s" % str(cabin.get("rooms_unlocked"))
	) or failed
	## Tutorial kind must not unlock even with lifetime>=1 (edge: prior clear then tutorial replay).
	cabin.call("_apply_defaults")
	cabin.set("lifetime_dungeons_cleared", 1)
	cabin.set("_homecoming_kind", "tutorial")
	var want_pm_tut: bool = cabin.call("_credit_homecoming_counters")
	failed = _assert(
		rows, failed, "PMENU.tutorial_no_haul",
		"progress-menu tutorial kind does not credit haul",
		want_pm_tut == false and int(cabin.get("counters").get("hauls", -1)) == 0,
		"want=%s hauls=%s" % [want_pm_tut, cabin.get("counters").get("hauls", -1)]
	) or failed

	cabin.call("_save")
	var after_meta := _file_meta(probe_path)
	failed = _assert(
		rows, failed, "SAFE.save_noop_same_meta",
		"_persist_writes=false leaves user://home_cabin.json meta unchanged",
		before_meta == after_meta,
		"before=%s after=%s" % [before_meta, after_meta]
	) or failed

	## Honest gap: helper/static finalize wiring ≠ headed GUI Pixel progress-menu click path.
	rows.append({
		"kind": "UNCOVERED",
		"id": "UNCOVERED.fresh_save_gui_progress_menu",
		"msg": "Does not prove headed F5 Brand New → tutorial → first delve → progress-menu Cabin → doors open",
	})
	print("NOTE UNCOVERED.fresh_save_gui_progress_menu — static+helper ≠ headed Pixel progress-menu GUI")

	cabin.queue_free()
	_finish(failed, rows)


func _rooms_eq(cabin: Node, want: Array) -> bool:
	var got: Array = cabin.get("rooms_unlocked")
	if got.size() != want.size():
		return false
	for id in want:
		if not got.has(id):
			return false
	return true


func _func_body_contains(src: String, sig: String, needle: String) -> bool:
	var start: int = src.find(sig)
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	return body.find(needle) >= 0


func _read_source(res_path: String) -> String:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _file_meta(path: String) -> String:
	if not FileAccess.file_exists(path):
		return "missing"
	var abs := path
	var modified := FileAccess.get_modified_time(abs)
	var size := FileAccess.get_file_as_bytes(abs).size()
	return "mod=%s size=%s" % [modified, size]


func _assert(rows: Array, failed: bool, id: String, msg: String, ok: bool, detail: String) -> bool:
	var row := {"kind": "ASSERT", "id": id, "msg": msg, "ok": ok, "detail": detail}
	rows.append(row)
	if ok:
		print("PASS ASSERT %s — %s" % [id, msg])
		return failed
	print("FAIL ASSERT %s — %s (%s)" % [id, msg, detail])
	push_error("%s %s (%s)" % [FAIL_MARK, id, detail])
	return true


func _finish(failed: bool, rows: Array) -> void:
	var asserts := 0
	var fails := 0
	for raw in rows:
		var r: Dictionary = raw
		if str(r.get("kind", "")) == "ASSERT":
			asserts += 1
			if not bool(r.get("ok", false)):
				fails += 1
	print("SUMMARY asserts=%s fails=%s" % [asserts, fails])
	if failed or fails > 0:
		print(FAIL_MARK)
		quit(1)
		return
	print(OK_MARK)
	quit(0)
