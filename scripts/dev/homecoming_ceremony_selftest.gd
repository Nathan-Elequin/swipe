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
	## Bare cabin has no built UI — disable process to avoid nil _process noise.
	cabin.set_process(false)
	cabin.set_physics_process(false)
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

	## --- Lifecycle: await_bank_ceremony_tween completes after kill (no finished hang) ---
	var gen_await: int = cabin.call("_begin_bank_ceremony")
	var hang_tw: Tween = cabin.create_tween()
	hang_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hang_tw.tween_interval(5.0)
	cabin.call("_track_bank_ceremony_tween", hang_tw)
	var await_done: Array = [false]
	var run_await := func() -> void:
		await cabin._await_bank_ceremony_tween(hang_tw, gen_await)
		await_done[0] = true
	run_await.call()
	await process_frame
	cabin.call("_invalidate_bank_ceremony")
	failed = await _assert_completes(
		rows, failed, "LIFE.await_tween_completes_on_kill",
		"cancel-safe tween await resumes after kill (finished is NOT emitted)",
		await_done, 90
	) or failed

	## --- SYNC reentrancy: inside abort callback, gen already retired; ack must no-op ---
	cabin.set("bank_pending", ["net"])
	cabin.set("_bank_hold", {"net": true})
	cabin.set("_persist_writes", false)
	var gen_sync: int = cabin.call("_begin_bank_ceremony")
	var sync_tw: Tween = cabin.create_tween()
	sync_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	sync_tw.tween_interval(5.0)
	cabin.call("_track_bank_ceremony_tween", sync_tw)
	var sync_mid: Dictionary = {}
	var sync_on_abort := func() -> void:
		## Captured AT emit time — not after invalidate returns.
		sync_mid["owns"] = bool(cabin.call("_owns_bank_ceremony", gen_sync))
		sync_mid["pending_before"] = (cabin.get("bank_pending") as Array).duplicate()
		cabin.call("_ack_bank_presented", "net", gen_sync)
		sync_mid["pending_after_ack"] = (cabin.get("bank_pending") as Array).duplicate()
		## Late cue path: owning false is the pop/ack gate; record for assert.
		sync_mid["would_own_for_late_cue"] = bool(cabin.call("_owns_bank_ceremony", gen_sync))
	cabin.bank_ceremony_fx_aborted.connect(sync_on_abort, CONNECT_ONE_SHOT)
	var sync_done: Array = [false]
	var sync_late_ack_kept: Array = [true]
	var run_sync := func() -> void:
		await cabin._await_bank_ceremony_tween(sync_tw, gen_sync)
		## After resume: still must not ack.
		cabin.call("_ack_bank_presented", "net", gen_sync)
		sync_late_ack_kept[0] = (cabin.get("bank_pending") as Array).has("net")
		sync_done[0] = true
	run_sync.call()
	await process_frame
	cabin.call("_invalidate_bank_ceremony")
	failed = await _assert_completes(
		rows, failed, "SYNC.abort_resumes_helper",
		"sync abort resumes awaiter without hang",
		sync_done, 90
	) or failed
	failed = _assert(
		rows, failed, "SYNC.abort_mid_gen_retired",
		"inside abort callback: cancelled gen already does not own",
		sync_mid.has("owns") and sync_mid["owns"] == false,
		"mid=%s" % str(sync_mid)
	) or failed
	failed = _assert(
		rows, failed, "SYNC.abort_mid_ack_noop",
		"inside abort callback: stale ack leaves bank_pending unchanged",
		sync_mid.has("pending_after_ack")
		and (sync_mid["pending_after_ack"] as Array).has("net")
		and (sync_mid["pending_before"] as Array).has("net"),
		"mid=%s" % str(sync_mid)
	) or failed
	failed = _assert(
		rows, failed, "SYNC.abort_mid_no_late_cue_own",
		"inside abort callback: no ownership for late pop/cue",
		sync_mid.get("would_own_for_late_cue", true) == false,
		"mid=%s" % str(sync_mid)
	) or failed
	failed = _assert(
		rows, failed, "SYNC.after_resume_pending_kept",
		"after sync resume, pending still has cancelled item (no late ack/save)",
		bool(sync_late_ack_kept[0]) and (cabin.get("bank_pending") as Array).has("net"),
		"kept=%s pending=%s" % [sync_late_ack_kept[0], cabin.get("bank_pending")]
	) or failed

	## --- Cancelled-before-await must not hang (killed tween → early return) ---
	var gen_gate: int = cabin.call("_begin_bank_ceremony")
	var gate_tw: Tween = cabin.create_tween()
	gate_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	gate_tw.tween_interval(5.0)
	cabin.call("_track_bank_ceremony_tween", gate_tw)
	cabin.call("_invalidate_bank_ceremony")
	var gate_done: Array = [false]
	var run_gate := func() -> void:
		await cabin._await_bank_ceremony_tween(gate_tw, gen_gate)
		gate_done[0] = true
	run_gate.call()
	failed = await _assert_completes(
		rows, failed, "LIFE.settled_gate_no_hang",
		"post-abort await on killed tween returns immediately (no settled hang)",
		gate_done, 30
	) or failed

	## --- Nested: case_opened_beat with null tc must not rebuild when stale ---
	var gen_c: int = cabin.call("_begin_bank_ceremony")
	cabin.call("_invalidate_bank_ceremony")
	cabin.call("_case_opened_beat", "b1", gen_c)
	failed = _assert(
		rows, failed, "NEST.case_opened_stale_returns",
		"stale _case_opened_beat returns without owning (no late mutate)",
		not bool(cabin.call("_owns_bank_ceremony", gen_c)),
		"owns=%s" % cabin.call("_owns_bank_ceremony", gen_c)
	) or failed

	## --- Lifecycle: mid-arc invalidate → helper completes + temp FX freed ---
	failed = await _lifecycle_mid_cancel_helper(
		rows, failed, cabin, "arc",
		func(gen: int) -> void:
			await cabin._bank_fx_arc_to_mount("net", "b1", gen)
	) or failed

	## --- Lifecycle: mid-smoke invalidate → helper completes + temp FX freed ---
	failed = await _lifecycle_mid_cancel_helper(
		rows, failed, cabin, "smoke",
		func(gen: int) -> void:
			await cabin._bank_fx_bag_smoke(gen)
	) or failed

	## --- Lifecycle: mid-loud-count invalidate → helper completes + label freed ---
	var shelf := Control.new()
	shelf.name = "SelftestShelf"
	shelf.size = Vector2(400, 400)
	cabin.add_child(shelf)
	cabin.set("_shelf_host", shelf)
	var case_b1 := Control.new()
	case_b1.name = "Case_b1"
	case_b1.size = Vector2(200, 200)
	shelf.add_child(case_b1)
	failed = await _lifecycle_mid_cancel_helper(
		rows, failed, cabin, "count",
		func(gen: int) -> void:
			await cabin._bank_fx_loud_count({"b1": 1}, 5, gen)
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
		rows, failed, "STATIC.await_ceremony_tween_helper",
		"cancel-safe _await_bank_ceremony_tween exists (kill ≠ finished)",
		"func _await_bank_ceremony_tween" in src and "bank_ceremony_fx_aborted" in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.arc_uses_cancel_safe_await",
		"arc awaits cancel-safe helper, not bare tw.finished",
		"await _await_bank_ceremony_tween(tw, ceremony_gen)" in arc_block
		and "await tw.finished" not in arc_block
	) or failed
	var inv_start := src.find("func _invalidate_bank_ceremony")
	var inv_end := src.find("\nfunc ", inv_start + 1)
	var inv_block := src.substr(inv_start, maxi(0, inv_end - inv_start)) if inv_start >= 0 else ""
	failed = _static(
		rows, failed, "STATIC.invalidate_retires_before_abort",
		"invalidate bumps gen before abort/kill emit",
		inv_block.find("_bank_ceremony_gen += 1") >= 0
		and inv_block.find("_bank_ceremony_gen += 1") < inv_block.find("_abort_bank_ceremony_fx")
	) or failed
	failed = _static(
		rows, failed, "STATIC.await_skips_settled_gate",
		"await helpers return when gate already fired (never await settled)",
		"if gate.fired:" in src and "await gate.settled" in src
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
	_uncovered(rows, "UNCOVERED.item_pop_cue_assert", "Cannot assert KIT.cue(item_pop) absence without cue spy; ownership + cancel-safe await + FX free are the evaluated nested proof.")
	_note(rows, "NOTE.windows_xdg_unverified", "Linux XDG/HOME mktemp isolation is NOT claimed to protect Windows. Use a separate isolated Godot test profile on Cherry for Windows QA.")

	if is_instance_valid(cabin):
		cabin.queue_free()
		await process_frame
	_finish(failed, rows)


## Mid-invalidate one FX helper: assert coroutine completes in bounded frames AND tracked FX gone.
func _lifecycle_mid_cancel_helper(
	rows: Array, failed: bool, cabin: Node, tag: String, starter: Callable
) -> bool:
	var gen: int = cabin.call("_begin_bank_ceremony")
	var done: Array = [false]
	var run := func() -> void:
		await starter.call(gen)
		done[0] = true
	run.call()
	## Let helper create tween + track FX node(s) — prefer frames over long timer.
	var wait_i := 0
	while (cabin.get("_bank_ceremony_fx_nodes") as Array).is_empty() and wait_i < 12:
		await process_frame
		wait_i += 1
	var tracked: Array = cabin.get("_bank_ceremony_fx_nodes") as Array
	var snap: Array = []
	for raw in tracked:
		if raw is Node and is_instance_valid(raw):
			snap.append(raw)
	failed = _assert(
		rows, failed, "LIFE.%s_tracked_fx_before_kill" % tag,
		"mid-%s: at least one temp FX node tracked before invalidate" % tag,
		snap.size() >= 1,
		"tracked=%d wait_frames=%d" % [snap.size(), wait_i]
	) or failed
	cabin.call("_invalidate_bank_ceremony")
	failed = await _assert_completes(
		rows, failed, "LIFE.%s_helper_completes" % tag,
		"mid-%s invalidate: helper/coroutine completes within bounded frames" % tag,
		done, 90
	) or failed
	## queue_free settles by end of frame — give a couple frames.
	await process_frame
	await process_frame
	var survivors := 0
	for n in snap:
		if n != null and is_instance_valid(n) and not n.is_queued_for_deletion():
			survivors += 1
	var left: Array = cabin.get("_bank_ceremony_fx_nodes") as Array
	failed = _assert(
		rows, failed, "LIFE.%s_fx_nodes_gone" % tag,
		"mid-%s invalidate: temporary FX nodes freed (not stranded)" % tag,
		survivors == 0 and left.is_empty(),
		"survivors=%d left=%d" % [survivors, left.size()]
	) or failed
	return failed


## Bound frame wait for a [done] flag set by a cancel-safe coroutine. Not a tween.finished poll.
func _assert_completes(
	rows: Array, failed: bool, id: String, expected: String, done: Array, max_frames: int
) -> bool:
	var frames := 0
	while not bool(done[0]) and frames < max_frames:
		await process_frame
		frames += 1
	var ok := bool(done[0])
	failed = _assert(
		rows, failed, id, expected, ok,
		"done=%s frames=%d max=%d" % [done[0], frames, max_frames]
	) or failed
	return failed


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
		return
	print(OK_MARK)
	quit(0)
