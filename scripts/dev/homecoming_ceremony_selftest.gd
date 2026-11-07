extends SceneTree
## Homecoming ceremony ownership + Verdant haul-gate selftest.
## Does not boot main.tscn. Avoids CampaignShell.write / live cabin UI.
## Requires Godot 4.7.x. Cloud agents without Godot cannot execute this.
##
## Row kinds: ASSERT (evaluated), STATIC (source shape), NOTE, UNCOVERED.
## Only ASSERT/STATIC failures fail the process.


const OK_MARK := "HOMECOMING_CEREMONY_OK"
const FAIL_MARK := "HOMECOMING_CEREMONY_FAIL"


func _init() -> void:
	var failed := false
	var rows: Array = []

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
	failed = _assert(
		rows, failed, "META.cabin_instance",
		"home_cabin instance constructs",
		cabin != null,
		"cabin=%s" % str(cabin)
	) or failed
	if cabin == null:
		_finish(failed, rows)
		return

	## --- Ceremony gen ownership (engine-evaluated, no UI) ---
	cabin.set("_bank_ceremony_gen", 0)
	cabin.set("_bank_busy", false)
	cabin.set("_homecoming_bank_staging", false)
	var gen_a: int = cabin.call("_begin_bank_ceremony")
	failed = _assert(
		rows, failed, "OWN.begin_sets_busy",
		"_begin_bank_ceremony marks busy and returns gen",
		bool(cabin.get("_bank_busy")) and int(cabin.get("_bank_ceremony_gen")) == gen_a and gen_a > 0,
		"busy=%s gen=%s" % [cabin.get("_bank_busy"), gen_a]
	) or failed
	failed = _assert(
		rows, failed, "OWN.owns_live",
		"live gen owns ceremony",
		bool(cabin.call("_owns_bank_ceremony", gen_a)),
		"gen_a=%s" % gen_a
	) or failed

	## Abort / invalidate while gen_a "awaiting"
	cabin.call("_invalidate_bank_ceremony")
	failed = _assert(
		rows, failed, "OWN.abort_invalidates",
		"invalidate clears busy and retires gen_a",
		(not bool(cabin.get("_bank_busy"))) and (not bool(cabin.call("_owns_bank_ceremony", gen_a))),
		"busy=%s owns_a=%s gen=%s" % [
			cabin.get("_bank_busy"), cabin.call("_owns_bank_ceremony", gen_a), cabin.get("_bank_ceremony_gen")
		]
	) or failed

	## Newer ceremony starts; stale gen_a must not release its locks or ack pending
	var gen_b: int = cabin.call("_begin_bank_ceremony")
	failed = _assert(
		rows, failed, "OWN.reentry_new_gen",
		"reentry begin yields new gen that owns busy",
		gen_b != gen_a and bool(cabin.get("_bank_busy")) and bool(cabin.call("_owns_bank_ceremony", gen_b)),
		"a=%s b=%s" % [gen_a, gen_b]
	) or failed

	cabin.set("bank_pending", ["net"])
	cabin.set("swiped", {"net": true})
	cabin.set("_bank_hold", {"net": true})
	## Stale ack after cancel must preserve pending + hold
	cabin.call("_ack_bank_presented", "net", gen_a)
	var pending_after_stale: Array = cabin.get("bank_pending")
	failed = _assert(
		rows, failed, "OWN.stale_ack_preserves_pending",
		"stale ceremony cannot ack bank_pending",
		pending_after_stale.has("net") and bool((cabin.get("_bank_hold") as Dictionary).has("net")),
		"pending=%s hold=%s" % [pending_after_stale, cabin.get("_bank_hold")]
	) or failed

	## Stale release must not clear live busy
	cabin.call("_release_bank_ceremony", gen_a)
	failed = _assert(
		rows, failed, "OWN.stale_release_keeps_live_busy",
		"stale release does not clear newer ceremony busy",
		bool(cabin.get("_bank_busy")) and bool(cabin.call("_owns_bank_ceremony", gen_b)),
		"busy=%s owns_b=%s" % [cabin.get("_bank_busy"), cabin.call("_owns_bank_ceremony", gen_b)]
	) or failed

	## Live ack removes pending only
	cabin.call("_ack_bank_presented", "net", gen_b)
	var pending_live: Array = cabin.get("bank_pending")
	failed = _assert(
		rows, failed, "OWN.live_ack_removes_pending",
		"live ceremony acks pending id",
		(not pending_live.has("net")) and (not bool((cabin.get("_bank_hold") as Dictionary).has("net"))),
		"pending=%s hold=%s" % [pending_live, cabin.get("_bank_hold")]
	) or failed

	cabin.call("_release_bank_ceremony", gen_b)
	failed = _assert(
		rows, failed, "OWN.live_release_retires",
		"live release clears busy and retires gen_b",
		(not bool(cabin.get("_bank_busy"))) and (not bool(cabin.call("_owns_bank_ceremony", gen_b))),
		"busy=%s owns_b=%s" % [cabin.get("_bank_busy"), cabin.call("_owns_bank_ceremony", gen_b)]
	) or failed

	## --- Verdant haul gate ---
	var b1_seq: Array = [{"id": "net", "pool": "b1"}, {"id": "sai", "pool": "b1"}]
	var b2_seq: Array = [{"id": "breastplate", "pool": "b2"}]
	var mixed: Array = [{"id": "breastplate", "pool": "b2"}, {"id": "net", "pool": "b1"}]
	failed = _assert(
		rows, failed, "GATE.b1_haul_true",
		"_haul_includes_pool b1 on b1 haul",
		bool(cabin.call("_haul_includes_pool", b1_seq, "b1")),
		"b1_seq"
	) or failed
	failed = _assert(
		rows, failed, "GATE.non_b1_haul_false",
		"_haul_includes_pool b1 false on b2-only haul (regression: no Verdant teach)",
		not bool(cabin.call("_haul_includes_pool", b2_seq, "b1")),
		"b2_seq"
	) or failed
	failed = _assert(
		rows, failed, "GATE.mixed_includes_b1",
		"mixed haul with b1 item counts as b1 haul",
		bool(cabin.call("_haul_includes_pool", mixed, "b1")),
		"mixed"
	) or failed

	## --- STATIC: play path uses ownership on give-home await ---
	var src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _static(
		rows, failed, "STATIC.give_home_checks_owns",
		"give-home await continuation checks _owns_bank_ceremony",
		'["nib.home.give_home"]' in src and "_owns_bank_ceremony(ceremony_gen)" in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.five_finds_requires_haul_b1",
		"five_finds block gated by haul_has_b1",
		"haul_has_b1" in src and 'nib.lesson.five_finds' in src
	) or failed
	failed = _static(
		rows, failed, "STATIC.abort_invalidates_gen",
		"_abort_cabin_interaction calls _invalidate_bank_ceremony",
		"_invalidate_bank_ceremony()" in src
		and src.find("func _abort_cabin_interaction") >= 0
	) or failed

	## Engine cancellation *reentry under live dialog/FX awaits* needs a full cabin tree.
	_note(rows, "NOTE.no_full_cabin_tree", "This suite does not open cabin dialog/FX; gen protocol is evaluated on a bare instance.")
	_uncovered(rows, "UNCOVERED.live_give_home_cancel_reentry", "Full give-home dialog cancel → resumed ceremony under real cabin tree not executed here.")

	if cabin != null and is_instance_valid(cabin):
		cabin.free()
	_finish(failed, rows)


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
	if failed or af > 0 or sf > 0:
		print(FAIL_MARK)
		quit(1)
	print(OK_MARK)
	quit(0)
