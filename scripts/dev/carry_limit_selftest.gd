extends SceneTree
## Headless checks for Carry-3 slice 1 (pure carry_limit.gd).
## Does not boot main.gd.
##
## Run: godot --headless --path . --script res://scripts/dev/carry_limit_selftest.gd


const OK_MARK := "CARRY_LIMIT_OK"
const FAIL_MARK := "CARRY_LIMIT_FAIL"
const C := preload("res://scripts/carry_limit.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []

	failed = _check(rows, failed, "const.carry_max_3", C.CARRY_MAX == 3, "got %s" % C.CARRY_MAX) or failed
	failed = _check(rows, failed, "const.dev_empty_fallback", C.DEV_FALLBACK_EMPTY_SELECTION == true, "") or failed

	## --- 0 items ---
	var empty: Array = []
	failed = _check(rows, failed, "zero.needs_choice_false", not C.needs_choice(empty), "") or failed
	var z: Dictionary = C.resolve_for_transition(empty)
	failed = _check(rows, failed, "zero.resolve_ok", bool(z.get("ok", false)), "") or failed
	failed = _check(rows, failed, "zero.kept_empty", (z.get("kept", ["x"]) as Array).is_empty(), "") or failed
	failed = _check(rows, failed, "zero.needed_false", not bool(z.get("needed_choice", true)), "") or failed

	## --- 3 items: under/at cap, no choice — carry all even if bag empty ---
	var three: Array = _items([1, 2, 3])
	failed = _check(rows, failed, "three.needs_choice_false", not C.needs_choice(three), "") or failed
	var t: Dictionary = C.resolve_for_transition(three, [])
	failed = _check(rows, failed, "three.resolve_ok", bool(t.get("ok", false)), "") or failed
	failed = _check(rows, failed, "three.kept_all", (t.get("kept", []) as Array).size() == 3, "n=%s" % (t.get("kept", []) as Array).size()) or failed
	failed = _check(rows, failed, "three.removed_none", (t.get("removed", ["x"]) as Array).is_empty(), "") or failed

	## --- 4 items: must choose ---
	var four: Array = _items([10, 11, 12, 13])
	failed = _check(rows, failed, "four.needs_choice_true", C.needs_choice(four), "") or failed
	failed = _check(rows, failed, "four.validate_reject_4", not C.validate(four, [10, 11, 12, 13]), "4 kept must fail") or failed
	failed = _check(rows, failed, "four.validate_accept_3", C.validate(four, [10, 11, 12]), "") or failed
	failed = _check(rows, failed, "four.validate_empty_ok", C.validate(four, []), "empty bag is legal") or failed
	var bad_apply: Dictionary = C.apply_choice(four, [10, 11, 12, 13])
	failed = _check(rows, failed, "four.apply_reject_4", not bool(bad_apply.get("ok", true)), "") or failed

	## --- choose fewer than 3 ---
	var few: Dictionary = C.apply_choice(four, [13, 10])
	failed = _check(rows, failed, "fewer.ok", bool(few.get("ok", false)), "") or failed
	failed = _check(rows, failed, "fewer.kept_n", (few.get("kept", []) as Array).size() == 2, "") or failed
	failed = _check(rows, failed, "fewer.removed_n", (few.get("removed", []) as Array).size() == 2, "") or failed
	failed = _check(rows, failed, "fewer.source_order", _uids(few.get("kept", [])) == [10, 13], "got %s" % str(_uids(few.get("kept", [])))) or failed

	## --- >3 + empty bag selection → carry NOTHING ---
	var eight: Array = _items([101, 102, 103, 104, 105, 106, 107, 108])
	failed = _check(rows, failed, "eight.needs_choice", C.needs_choice(eight), "") or failed
	var empty_bag: Dictionary = C.apply_choice(eight, [])
	failed = _check(rows, failed, "empty_bag.ok", bool(empty_bag.get("ok", false)), "") or failed
	failed = _check(rows, failed, "empty_bag.kept_0", (empty_bag.get("kept", ["x"]) as Array).is_empty(), "n=%s" % (empty_bag.get("kept", []) as Array).size()) or failed
	failed = _check(rows, failed, "empty_bag.removed_8", (empty_bag.get("removed", []) as Array).size() == 8, "n=%s" % (empty_bag.get("removed", []) as Array).size()) or failed

	var r8: Dictionary = C.resolve_for_transition(eight, [])
	failed = _check(rows, failed, "eight.resolve_ok", bool(r8.get("ok", false)), "") or failed
	failed = _check(rows, failed, "eight.needed_choice", bool(r8.get("needed_choice", false)), "") or failed
	failed = _check(rows, failed, "eight.empty_fallback_kept_0", (r8.get("kept", ["x"]) as Array).is_empty(), "n=%s" % (r8.get("kept", []) as Array).size()) or failed
	failed = _check(rows, failed, "eight.empty_fallback_removed_8", (r8.get("removed", []) as Array).size() == 8, "n=%s" % (r8.get("removed", []) as Array).size()) or failed
	failed = _check(rows, failed, "eight.kept_ids_empty", (r8.get("kept_ids", ["x"]) as Array).is_empty(), "") or failed

	## --- Over-cap with a real bag selection of 3 ---
	var bag3: Dictionary = C.resolve_for_transition(eight, [103, 105, 108])
	failed = _check(rows, failed, "bag3.ok", bool(bag3.get("ok", false)), "") or failed
	failed = _check(rows, failed, "bag3.kept_n", (bag3.get("kept", []) as Array).size() == 3, "") or failed
	failed = _check(rows, failed, "bag3.order", _uids(bag3.get("kept", [])) == [103, 105, 108], "got %s" % str(_uids(bag3.get("kept", [])))) or failed

	## --- Removed items do not reappear in the next dungeon hand ---
	var next_hand: Array = (r8.get("kept", []) as Array).duplicate()
	var removed_uids: Dictionary = {}
	for it in r8.get("removed", []):
		removed_uids[int(it.get("uid", -1))] = true
	var leaked := false
	for it in next_hand:
		if removed_uids.has(int(it.get("uid", -1))):
			leaked = true
			break
	failed = _check(rows, failed, "next_dungeon.no_removed", not leaked, "") or failed
	failed = _check(rows, failed, "next_dungeon.size_le_max", next_hand.size() <= C.CARRY_MAX, "n=%s" % next_hand.size()) or failed
	## Empty carry into next dungeon: still no choice, stays empty.
	failed = _check(rows, failed, "next_dungeon.no_rechoose", not C.needs_choice(next_hand), "") or failed
	var r_again: Dictionary = C.resolve_for_transition(next_hand)
	failed = _check(rows, failed, "next_dungeon.stable_empty", (r_again.get("kept", ["x"]) as Array).is_empty(), "") or failed

	## After a 3-from-bag commit, next dungeon keeps those 3.
	var next3: Array = (bag3.get("kept", []) as Array).duplicate()
	failed = _check(rows, failed, "next3.no_rechoose", not C.needs_choice(next3), "") or failed
	var r_next3: Dictionary = C.resolve_for_transition(next3)
	failed = _check(rows, failed, "next3.stable", _uids(r_next3.get("kept", [])) == [103, 105, 108], "got %s" % str(_uids(r_next3.get("kept", [])))) or failed

	## --- Unknown / duplicate kept ids rejected ---
	failed = _check(rows, failed, "validate.unknown_id", not C.validate(four, [10, 999]), "") or failed
	failed = _check(rows, failed, "validate.duplicate", not C.validate(four, [10, 10]), "") or failed

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
	print("carry_limit_selftest: %d/%d passed" % [passed, rows.size()])
