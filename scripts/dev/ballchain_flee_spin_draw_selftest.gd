extends SceneTree
## Ball & Chain — Flee Neighbor → Spin lands → Draw once; cancel/invalid = no consume.
## Run: godot --headless --path . --script res://scripts/dev/ballchain_flee_spin_draw_selftest.gd
## Source + catalog contracts (no main.tscn boot). Mirrors tip_smoke §16 + consume rules.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = _contracts() or failed
	failed = _consume_and_cancel_contracts() or failed
	if failed:
		push_error("BALLCHAIN_FLEE_SPIN_DRAW_SELFTEST_FAIL")
		print("BALLCHAIN_FLEE_SPIN_DRAW_SELFTEST_FAIL")
		quit(1)
	else:
		print("BALLCHAIN_FLEE_SPIN_DRAW_SELFTEST_OK")
		quit(0)


func _contracts() -> bool:
	var failed := false
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(
		failed,
		"item_ops_chain_flee",
		src.find('"ball_and_chain": {"kind": "chain_flee"') >= 0
	) or failed
	failed = _check(
		failed,
		"item_ops_not_pure_draw",
		src.find('"ball_and_chain": {"kind": "draw"') < 0
	) or failed
	failed = _check(
		failed,
		"apply_sets_spin_land_uid",
		src.find("func _apply_chain_flee") >= 0
		and src.find("_spin_land_uid = _seat_uid_at(index)") >= 0
	) or failed
	failed = _check(
		failed,
		"pending_draw_armed_on_apply",
		src.find("_chain_flee_draw_pending = true") >= 0
	) or failed
	failed = _check(
		failed,
		"draw_fires_after_spin_land",
		src.find("if _chain_flee_draw_pending:") >= 0
		and src.find("_draw_unseen_item()") >= 0
	) or failed
	failed = _check(
		failed,
		"consume_once_in_apply",
		_apply_block_contains(src, 'it["spent"] = true')
		and _apply_block_contains(src, "_toss_item(")
		and _apply_block_contains(src, "await _flee_spin()")
	) or failed
	failed = _check(
		failed,
		"face_keeps_shared_draw_glyph",
		src.find('"ball_and_chain":') >= 0
		and src.find(', "", "", "", "draw")') >= 0
	) or failed
	failed = _check(
		failed,
		"living_neighbor_gate",
		src.find('if kind == "signpost" or kind == "chain_flee":') >= 0
		and src.find("return int(wheel[index].get(\"hp\", 0)) > 0") >= 0
	) or failed

	var cat: Dictionary = _load_json("res://data/catalog.json")
	var ops: Dictionary = _catalog_ops(cat, "ball_and_chain")
	var ability: String = str(_catalog_field(cat, "ball_and_chain", "ability"))
	failed = _check(failed, "catalog_ops_chain_flee", str(ops.get("kind", "")) == "chain_flee") or failed
	failed = _check(failed, "catalog_ability_neighbor", ability.find("Neighbor") >= 0) or failed
	failed = _check(failed, "catalog_ability_flee", ability.find("Flee") >= 0) or failed
	failed = _check(failed, "catalog_ability_draw", ability.find("Draw a Card") >= 0) or failed
	failed = _check(
		failed,
		"catalog_flow_full_hand",
		str(_catalog_field(cat, "ball_and_chain", "flow")).find("hand is full") >= 0
	) or failed
	return failed


func _consume_and_cancel_contracts() -> bool:
	## Cancel / invalid selection must not reach consume: mark path returns before
	## _apply_chain_flee when _can_mark fails; pending_mark alone does not spend.
	var failed := false
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var apply_i: int = src.find("func _apply_mark_inner")
	var chain_call: int = src.find('await _apply_chain_flee(', apply_i)
	var can_mark_guard: int = src.find("if not _can_mark(index, kind):", apply_i)
	failed = _check(
		failed,
		"invalid_mark_returns_before_apply",
		apply_i >= 0 and can_mark_guard >= 0 and chain_call > can_mark_guard
	) or failed
	## Early abort in _apply_chain_flee clears pending draw and does not leave spend half-done
	## after a bad index (spent is only set after the index guard).
	var fn_i: int = src.find("func _apply_chain_flee")
	var guard_return: int = src.find("_undo_abort()", fn_i)
	var spent_i: int = src.find('it["spent"] = true', fn_i)
	failed = _check(
		failed,
		"bad_index_aborts_before_spend",
		fn_i >= 0 and guard_return >= 0 and spent_i > guard_return
	) or failed
	failed = _check(
		failed,
		"undo_abort_clears_pending_draw",
		src.find("func _undo_abort") >= 0
		and src.find("_chain_flee_draw_pending = false") >= 0
	) or failed
	## Pending mark without confirm: use_item only arms pending_mark for chain_flee.
	var use_arm: int = src.find('pending_mark = {"uid": uid, "kind": kind}')
	failed = _check(
		failed,
		"mark_arm_does_not_spend_inline",
		use_arm >= 0
		and src.find('kind == "chain_flee"', use_arm - 800) >= 0
	) or failed
	return failed


func _apply_block_contains(src: String, needle: String) -> bool:
	var start: int = src.find("func _apply_chain_flee")
	if start < 0:
		return false
	var stop: int = src.find("\nfunc ", start + 1)
	if stop < 0:
		stop = src.length()
	return src.substr(start, stop - start).find(needle) >= 0


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("OK  ", name)
		return failed
	push_error("FAIL %s" % name)
	print("FAIL ", name)
	return true


func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


func _catalog_ops(cat: Dictionary, card_id: String) -> Dictionary:
	for it in cat.get("items", []):
		if typeof(it) == TYPE_DICTIONARY and str(it.get("id", "")) == card_id:
			var ops: Variant = it.get("ops", {})
			if typeof(ops) == TYPE_DICTIONARY:
				return ops as Dictionary
	return {}


func _catalog_field(cat: Dictionary, card_id: String, field: String) -> Variant:
	for it in cat.get("items", []):
		if typeof(it) == TYPE_DICTIONARY and str(it.get("id", "")) == card_id:
			return it.get(field, "")
	return ""
