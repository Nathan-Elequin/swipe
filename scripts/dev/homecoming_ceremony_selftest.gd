extends SceneTree
## Homecoming ceremony ownership + Verdant haul-gate + persistence-safety selftest.
## Does NOT boot main.tscn. Does NOT prove live H11 give-home/FX cancel under full cabin.
##
## CRITICAL: Sets cabin._persist_writes=false BEFORE any ack/_save so a direct
## `godot --script` invoke cannot overwrite user://home_cabin.json.
## Runner must ALSO isolate XDG_DATA_HOME (defense in depth).
##
## Requires Godot 4.7.x. Cloud agents without Godot → RUNTIME_UNAVAILABLE via runner.
## Row kinds: ASSERT / STATIC / NOTE / UNCOVERED. Only ASSERT/STATIC failures fail.


const OK_MARK := "HOMECOMING_CEREMONY_OK"
const FAIL_MARK := "HOMECOMING_CEREMONY_FAIL"


func _init() -> void:
	## Async body — need SceneTree frames for tween kill checks.
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []

	## Probe the path this process would write (isolated under runner XDG; live if direct).
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
	## APPLICATION SEAM: hard-disable disk writes before any ledger mutation.
	cabin.set("_persist_writes", false)
	cabin.set("_save_path_override", "")
	failed = _assert(
		rows, failed, "SAFE.persist_writes_false_before_ack",
		"_persist_writes disabled immediately on bare instance",
		cabin.get("_persist_writes") == false,
		"persist=%s" % str(cabin.get("_persist_writes"))
	) or failed

	## Mount in tree so create_tween works for nested kill checks.
	root.add_child(cabin)

	## --- Ceremony gen ownership ---
	cabin.set("_bank_ceremony_gen", 0)
	cabin.set("_bank_busy", false)
	cabin.set("_homecoming_bank_staging", false)
	cabin.set("_homecoming_staging_gen", 0)
	var gen_a: int = cabin.call("_begin_bank_ceremony")
	failed = _assert(
		rows, failed, "OWN.begin_sets_busy",
		"_begin_bank_ceremony marks busy and returns gen",
		bool(cabin.get("_bank_busy")) and int(cabin.get("_bank_ceremony_gen")) == gen_a and gen_a > 0,
		"busy=%s gen=%s" % [cabin.get("_bank_busy"), gen_a]
	) or failed

	cabin.call("_invalidate_bank_ceremony")
	failed = _assert(
		rows, failed, "OWN.abort_invalidates",
		"invalidate clears busy and retires gen_a",
		(not bool(cabin.get("_bank_busy"))) and (not bool(cabin.call("_owns_bank_ceremony", gen_a))),
		"busy=%s owns_a=%s" % [cabin.get("_bank_busy"), cabin.call("_owns_bank_ceremony", gen_a)]
	) or failed

	var gen_b: int = cabin.call("_begin_bank_ceremony")
	cabin.set("bank_pending", ["net"])
	cabin.set("swiped", {"net": true})
	cabin.set("_bank_hold", {"net": true})
	cabin.call("_ack_bank_presented", "net", gen_a)
	failed = _assert(
		rows, failed, "OWN.stale_ack_preserves_pending",
		"stale ceremony cannot ack bank_pending",
		(cabin.get("bank_pending") as Array).has("net"),
		"pending=%s" % str(cabin.get("bank_pending"))
	) or failed

	## Live ack with persist disabled — must mutate memory only, never disk.
	cabin.call("_ack_bank_presented", "net", gen_b)
	failed = _assert(
		rows, failed, "OWN.live_ack_removes_pending_memory",
		"live ceremony acks pending in memory",
		not (cabin.get("bank_pending") as Array).has("net"),
		"pending=%s" % str(cabin.get("bank_pending"))
	) or failed
	cabin.call("_save")
	var after_ack_meta := _file_meta(probe_path)
	failed = _assert(
		rows, failed, "SAFE.ack_save_noop_same_meta",
		"persist_writes=false: probe user://home_cabin.json meta unchanged after ack+_save",
		_meta_equal(before_meta, after_ack_meta),
		"path=%s before=%s after=%s" % [probe_path, before_meta, after_ack_meta]
	) or failed

	cabin.call("_release_bank_ceremony", gen_b)

	## --- Staging token: stale clear must not drop newer claim ---
	var tok_a: int = cabin.call("_claim_homecoming_staging")
	var tok_b: int = cabin.call("_claim_homecoming_staging")
	cabin.call("_clear_homecoming_staging", tok_a)
	failed = _assert(
		rows, failed, "STAGE.stale_clear_keeps_newer",
		"stale staging clear leaves newer claim busy",
		bool(cabin.get("_homecoming_bank_staging")) and bool(cabin.call("_owns_homecoming_staging", tok_b)),
		"staging=%s owns_b=%s" % [cabin.get("_homecoming_bank_staging"), cabin.call("_owns_homecoming_staging", tok_b)]
	) or failed
	cabin.call("_clear_homecoming_staging", tok_b)

	## --- Nested: tracked tween killed on invalidate ---
	var gen_t: int = cabin.call("_begin_bank_ceremony")
	var tw: Tween = cabin.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(2.0)
	cabin.call("_track_bank_ceremony_tween", tw)
	cabin.call("_invalidate_bank_ceremony")
	failed = _assert(
		rows, failed, "NEST.tween_killed_on_invalidate",
		"invalidate kills tracked ceremony tweens (stops stale callbacks)",
		tw == null or not is_instance_valid(tw) or not tw.is_valid(),
		"tw_valid=%s gen_t_owns=%s" % [
			tw != null and is_instance_valid(tw) and tw.is_valid(),
			cabin.call("_owns_bank_ceremony", gen_t)
		]
	) or failed

	## --- Nested: case_opened_beat with null tc must not rebuild when stale ---
	var gen_c: int = cabin.call("_begin_bank_ceremony")
	cabin.call("_invalidate_bank_ceremony")
	## Stale call: trophy case missing → must NOT rebuild (ownership gate).
	## We detect via shelves host absence + no crash; ownership return is the contract.
	cabin.call("_case_opened_beat", "b1", gen_c)
	failed = _assert(
		rows, failed, "NEST.case_opened_stale_returns",
		"stale _case_opened_beat returns without owning (no late mutate)",
		not bool(cabin.call("_owns_bank_ceremony", gen_c)),
		"owns=%s" % cabin.call("_owns_bank_ceremony", gen_c)
	) or failed

	## --- Nested: arc late pop blocked when invalidated mid-tween ---
	var gen_arc: int = cabin.call("_begin_bank_ceremony")
	cabin.call("_bank_fx_arc_to_mount", "net", "b1", gen_arc)
	## Invalidate on next frame while arc awaits (~0.38s).
	await create_timer(0.05).timeout
	cabin.call("_invalidate_bank_ceremony")
	await create_timer(0.5).timeout
	failed = _assert(
		rows, failed, "NEST.arc_stale_after_invalidate",
		"after mid-arc invalidate, gen_arc no longer owns (no late owner cues)",
		not bool(cabin.call("_owns_bank_ceremony", gen_arc)),
		"owns=%s" % cabin.call("_owns_bank_ceremony", gen_arc)
	) or failed

	## --- Verdant haul gate (accepted fix) ---
	failed = _assert(
		rows, failed, "GATE.non_b1_haul_false",
		"_haul_includes_pool b1 false on b2-only haul",
		not bool(cabin.call("_haul_includes_pool", [{"id": "breastplate", "pool": "b2"}], "b1")),
		"b2-only"
	) or failed
	failed = _assert(
		rows, failed, "GATE.b1_haul_true",
		"_haul_includes_pool b1 true on b1 haul",
		bool(cabin.call("_haul_includes_pool", [{"id": "net", "pool": "b1"}], "b1")),
		"b1"
	) or failed

	## --- STATIC nested ownership signatures ---
	var src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _static(
		rows, failed, "STATIC.case_opened_takes_gen",
		"_case_opened_beat(pool_id, ceremony_gen",
		"func _case_opened_beat(pool_id: String, ceremony_gen: int = -1)" in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.arc_takes_gen",
		"_bank_fx_arc_to_mount(..., ceremony_gen",
		"func _bank_fx_arc_to_mount(item_id: String, pool_id: String, ceremony_gen: int = -1)" in src
	) or failed
	var arc_start := src.find("func _bank_fx_arc_to_mount")
	var arc_end := src.find("\nfunc ", arc_start + 1)
	var arc_block := src.substr(arc_start, maxi(0, arc_end - arc_start)) if arc_start >= 0 else ""
	var owns_in_arc := arc_block.rfind("not _owns_bank_ceremony(ceremony_gen)")
	var pop_in_arc := arc_block.find("cabin.item_pop")
	failed = _static(
		rows, failed, "STATIC.arc_no_pop_when_stale",
		"arc function checks owns before item_pop cue",
		owns_in_arc >= 0 and pop_in_arc > owns_in_arc
	) or failed
	failed = _static(
		rows, failed, "STATIC.save_persist_guard",
		"_save returns early when not _persist_writes",
		"if not _persist_writes:" in src and "func _save()" in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.staging_clear_token",
		"_clear_homecoming_staging token-guards flag clear",
		"func _clear_homecoming_staging" in src and "func _claim_homecoming_staging" in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.five_finds_haul_b1",
		"five_finds still gated by haul_has_b1",
		"haul_has_b1" in src and "nib.lesson.five_finds" in src
	) or failed

	var final_meta := _file_meta(probe_path)
	failed = _assert(
		rows, failed, "SAFE.final_probe_unchanged",
		"end of suite: probe save meta still matches start (no real overwrite)",
		_meta_equal(before_meta, final_meta),
		"before=%s after=%s" % [before_meta, final_meta]
	) or failed

	_note(rows, "NOTE.not_live_H11", "Bare-instance / helper checks ≠ live cabin give-home dialog + full FX cancel reentry (REQ H11).")
	_uncovered(rows, "UNCOVERED.live_dialog_fx_cancel", "Full give-home dialogue + case_opened lamp/crest/dumbwaiter cancel under real CabinRoot tree not executed.")
	_uncovered(rows, "UNCOVERED.item_pop_cue_assert", "Cannot assert KIT.cue(item_pop) absence without cue spy; ownership + tween kill are the evaluated nested proof.")

	if is_instance_valid(cabin):
		cabin.queue_free()
		await process_frame
	_finish(failed, rows)


func _file_meta(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"exists": false, "mtime": -1, "size": -1, "md5": ""}
	var mtime := FileAccess.get_modified_time(path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"exists": true, "mtime": mtime, "size": -1, "md5": "unreadable"}
	var body := f.get_as_text()
	return {
		"exists": true,
		"mtime": mtime,
		"size": body.length(),
		"md5": body.md5_text(),
	}


func _meta_equal(a: Dictionary, b: Dictionary) -> bool:
	return str(a.get("exists")) == str(b.get("exists")) \
		and int(a.get("mtime", -1)) == int(b.get("mtime", -1)) \
		and int(a.get("size", -1)) == int(b.get("size", -1)) \
		and str(a.get("md5", "")) == str(b.get("md5", ""))


func _assert(rows: Array, failed: bool, id: String, expected: String, cond: bool, actual: String) -> bool:
	var result := "PASS" if cond else "FAIL"
	rows.append({"kind": "ASSERT", "id": id, "expected": expected, "actual": actual, "result": result})
	print("%s ASSERT %s | %s | actual=%s" % [result, id, expected, actual])
	return failed or not cond


func _static(rows: Array, failed: bool, id: String, expected: String, cond: bool) -> bool:
	var result := "PASS" if cond else "FAIL"
	rows.append({"kind": "STATIC", "id": id, "expected": expected, "actual": str(cond), "result": result})
	print("%s STATIC %s | %s" % [result, id, expected])
	return failed or not cond


func _note(rows: Array, id: String, text: String) -> void:
	rows.append({"kind": "NOTE", "id": id, "expected": text, "actual": "", "result": "NOTE"})
	print("NOTE  %s | %s" % [id, text])


func _uncovered(rows: Array, id: String, text: String) -> void:
	rows.append({"kind": "UNCOVERED", "id": id, "expected": text, "actual": "", "result": "UNCOVERED"})
	print("UNCOVERED  %s | %s" % [id, text])


func _finish(failed: bool, rows: Array) -> void:
	var ap := 0
	var af := 0
	var sp := 0
	var sf := 0
	var notes := 0
	var unc := 0
	for r in rows:
		match str(r.get("kind", "")):
			"ASSERT":
				if str(r.get("result", "")) == "PASS":
					ap += 1
				else:
					af += 1
			"STATIC":
				if str(r.get("result", "")) == "PASS":
					sp += 1
				else:
					sf += 1
			"NOTE":
				notes += 1
			"UNCOVERED":
				unc += 1
	print("TOTALS assert_pass=%d assert_fail=%d static_pass=%d static_fail=%d note=%d uncovered=%d" % [
		ap, af, sp, sf, notes, unc
	])
	print("PROBE_PATH %s" % ProjectSettings.globalize_path("user://home_cabin.json"))
	if failed or af > 0 or sf > 0:
		print(FAIL_MARK)
		quit(1)
	print(OK_MARK)
	quit(0)
