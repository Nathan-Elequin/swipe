extends SceneTree
## Headless: gate cap + collection_complete full-roster honesty.
## Run: godot --headless --path . --script res://scripts/dev/collection_journey_milestones_selftest.gd

const JOURNEY := preload("res://scripts/collection_journey.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	var failed := false
	var rules: Dictionary = {
		"cabinet_quota": 5,
		"biomes": [
			{"id": "b1", "name": "Verdant Hollow"},
			{"id": "b2", "name": "Crystal Cavern"},
			{"id": "b3", "name": "Ashen Crypt"},
			{"id": "b4", "name": "Cinder Forge"},
			{"id": "b5", "name": "Shadow Abyss"},
		],
	}
	var roster := {"b1": 14, "b2": 13, "b3": 13, "b4": 13, "b5": 14}
	## Totals 67 when summed — Cinder 13 matches Pixel review shape.

	## Gate display capped at quota even when raw cabinet jumps 4 → 14.
	var before_g: Dictionary = SHELL.fresh_state()
	for i in 4:
		before_g["banked"]["g%d" % i] = "b1"
	var after_g: Dictionary = before_g.duplicate(true)
	for i in range(4, 14):
		after_g["banked"]["g%d" % i] = "b1"
	var ms_g: Array = JOURNEY.milestones_from_bank(rules, before_g, after_g, ["b1"], {"b1": 14})
	var gate: Dictionary = {}
	for raw in ms_g:
		if str((raw as Dictionary).get("kind", "")) == "gate":
			gate = raw
	failed = _check(failed, "gate_emitted", not gate.is_empty()) or failed
	failed = _check(failed, "gate_from_capped", int(gate.get("from", -1)) == 4) or failed
	failed = _check(failed, "gate_to_capped", int(gate.get("to", -1)) == 5) or failed
	failed = _check(failed, "gate_quota", int(gate.get("quota", -1)) == 5) or failed
	failed = _check(failed, "gate_raw_to_uncapped", int(gate.get("raw_to", -1)) == 14) or failed

	## Negative: 66/67 must NOT emit collection_complete (even if quota-won).
	var before_n: Dictionary = SHELL.fresh_state()
	var after_n: Dictionary = SHELL.fresh_state()
	var n := 0
	for pool in roster.keys():
		var need: int = int(roster[pool])
		## Leave one missing on b4 (Cinder) → 66/67.
		var take: int = need if pool != "b4" else need - 1
		for i in take:
			after_n["banked"]["%s_%d" % [pool, i]] = pool
			n += 1
	## Quota-complete every biome so cabinets_complete / won would be true if we keyed off that.
	after_n["won"] = true
	after_n["endless_unlocked"] = true
	failed = _check(failed, "neg_banked_66", n == 66) or failed
	failed = _check(failed, "neg_roster_incomplete", not JOURNEY.roster_complete(after_n, rules, roster)) or failed
	var ms_n: Array = JOURNEY.milestones_from_bank(rules, before_n, after_n, [], roster)
	var has_complete_n := false
	for raw2 in ms_n:
		if str((raw2 as Dictionary).get("kind", "")) == "collection_complete":
			has_complete_n = true
	failed = _check(failed, "neg_66_no_collection_complete", not has_complete_n) or failed

	## Positive: last eligible bank → 67/67 emits collection_complete once.
	var before_p: Dictionary = after_n.duplicate(true)
	before_p["won"] = false
	var after_p: Dictionary = before_p.duplicate(true)
	after_p["banked"]["b4_last"] = "b4"
	failed = _check(failed, "pos_roster_complete", JOURNEY.roster_complete(after_p, rules, roster)) or failed
	var ms_p: Array = JOURNEY.milestones_from_bank(rules, before_p, after_p, ["b4"], roster)
	var has_complete_p := false
	var has_cabinet_full := false
	for raw3 in ms_p:
		var k := str((raw3 as Dictionary).get("kind", ""))
		if k == "collection_complete":
			has_complete_p = true
		if k == "cabinet_full":
			has_cabinet_full = true
	failed = _check(failed, "pos_67_collection_complete", has_complete_p) or failed
	failed = _check(failed, "pos_cabinet_full_on_last", has_cabinet_full) or failed

	## Idempotent: already-complete before → no second collection_complete.
	var ms_id: Array = JOURNEY.milestones_from_bank(rules, after_p, after_p, ["b4"], roster)
	var has_complete_id := false
	for raw4 in ms_id:
		if str((raw4 as Dictionary).get("kind", "")) == "collection_complete":
			has_complete_id = true
	failed = _check(failed, "idempotent_no_replay_complete", not has_complete_id) or failed

	## Final-dungeon clear: independent of cabinets_complete / inheritance.
	var fc_state: Dictionary = SHELL.fresh_state()
	## Incomplete cabinets + incomplete roster.
	for pool2 in ["b1", "b2", "b3", "b4", "b5"]:
		fc_state["banked"]["%s_a" % pool2] = pool2
	failed = _check(failed, "fc_not_cabinets", not SHELL.cabinets_complete(rules, fc_state)) or failed
	failed = _check(failed, "fc_not_roster", not JOURNEY.roster_complete(fc_state, rules, roster)) or failed
	failed = _check(failed, "fc_last_id", SHELL.last_tip_biome_id(rules) == "b5") or failed
	var fc1: Dictionary = SHELL.recognize_final_dungeon_clear(rules, fc_state, "b5")
	failed = _check(failed, "fc_emits_once", str(fc1.get("kind", "")) == "final_clear") or failed
	failed = _check(failed, "fc_flag_set", bool(fc_state.get("final_dungeon_cleared", false))) or failed
	failed = _check(failed, "fc_no_won", not bool(fc_state.get("won", false))) or failed
	failed = _check(failed, "fc_no_endless", not bool(fc_state.get("endless_unlocked", false))) or failed
	var fc2: Dictionary = SHELL.recognize_final_dungeon_clear(rules, fc_state, "b5")
	failed = _check(failed, "fc_idempotent", fc2.is_empty()) or failed
	var fc_b1_state: Dictionary = SHELL.fresh_state()
	var fc_b1: Dictionary = SHELL.recognize_final_dungeon_clear(rules, fc_b1_state, "b1")
	failed = _check(failed, "fc_not_on_b1", fc_b1.is_empty() and not bool(fc_b1_state.get("final_dungeon_cleared", false))) or failed
	## Inheritance still independent: incomplete roster after final clear → no collection_complete.
	var ms_fc: Array = JOURNEY.milestones_from_bank(rules, SHELL.fresh_state(), fc_state, [], roster)
	var has_cc_fc := false
	for raw5 in ms_fc:
		if str((raw5 as Dictionary).get("kind", "")) == "collection_complete":
			has_cc_fc = true
	failed = _check(failed, "fc_no_inheritance", not has_cc_fc) or failed

	if failed:
		print("MILESTONE_SELFTEST_FAIL")
		quit(1)
	print("MILESTONE_SELFTEST_OK")
	quit(0)


func _check(failed: bool, name: String, ok: bool) -> bool:
	print("%s %s" % ["PASS" if ok else "FAIL", name])
	return failed or not ok
