extends SceneTree
## Headless checks for the five biome cases. Does not boot main.gd.


func _init() -> void:
	var Cases = load("res://scripts/biome_cabinets.gd")
	var Shell = load("res://scripts/campaign_shell.gd")
	var rules: Dictionary = Shell.read_json("res://data/campaign.json")
	var failed := false
	var names: Array = Cases.case_names(rules)
	failed = _check(failed, "five cases", names.size() == 5) or failed
	var want := ["Verdant Hollow", "Sunken Mire", "Ashen Crypt", "Cinder Forge", "Shadow Abyss"]
	for i in want.size():
		failed = _check(failed, "name %s" % want[i], i < names.size() and str(names[i]) == str(want[i])) or failed
	var stubs := {
		"biomes": [
			{"id": "b1", "name": "The Cellar"},
			{"id": "b2", "name": "The Warren"},
			{"id": "b3", "name": "The Chapel"},
			{"id": "b4", "name": "The Vault"},
			{"id": "b5", "name": "The Throat"},
		],
	}
	var rewritten: Array = Cases.case_names(stubs)
	failed = _check(failed, "stubs become locked names", rewritten == want) or failed
	var custom := {"biomes": [{"id": "b1", "name": "Moss Hall"}]}
	failed = _check(failed, "non-stub name kept", str(Cases.case_names(custom)[0]) == "Moss Hall") or failed
	failed = _check(failed, "quota 5", Cases.quota_of(rules) == 5) or failed
	failed = _check(failed, "pool b1", Cases.pool_for_bucket(rules, 0) == "b1" and Cases.pool_for_bucket(rules, 1) == "b1") or failed
	failed = _check(failed, "pool b5", Cases.pool_for_bucket(rules, 8) == "b5" and Cases.pool_for_bucket(rules, 9) == "b5") or failed
	failed = _check(failed, "fallback pair", Cases.pool_for_bucket({}, 4) == "b3") or failed
	var cards: Array = [
		{"id": "c"},
		{"id": "a"},
		{"id": "b"},
		{"id": "d"},
	]
	var ordered: Array = Cases.order_mounts(cards, ["b", "a"])
	var ids: Array = []
	for raw in ordered:
		ids.append(str((raw as Dictionary).get("id", "")))
	failed = _check(failed, "collect order first", ids.size() == 4 and ids[0] == "b" and ids[1] == "a") or failed
	var again: Array = Cases.order_mounts(cards, ["b", "a"])
	var ids2: Array = []
	for raw2 in again:
		ids2.append(str((raw2 as Dictionary).get("id", "")))
	failed = _check(failed, "scatter stable", ids == ids2) or failed
	failed = _check(failed, "uncollected after", ids[2] != "b" and ids[3] != "a") or failed
	failed = _check(failed, "toward gate", Cases.progress_text(3, 12, 5) == "3/5") or failed
	failed = _check(failed, "past gate crown", Cases.progress_text(7, 12, 5) == "5/5") or failed
	failed = _check(failed, "at gate crown", Cases.progress_text(5, 12, 5) == "5/5") or failed
	failed = _check(failed, "past_gate helper", Cases.past_gate(5, 5) and Cases.past_gate(7, 5) and not Cases.past_gate(4, 5)) or failed
	failed = _check(failed, "next_piece need", Cases.next_piece_need(3, 5) == 2 and Cases.next_piece_need(5, 5) == 0) or failed
	failed = _check(failed, "crosses", Cases.crossed_gate(4, 5, 5) and not Cases.crossed_gate(5, 6, 5)) or failed
	var seq: Array = Cases.bank_sequence(["net", "boot", "hex"], {"net": "b1", "boot": "b2", "hex": "b1"})
	failed = _check(failed, "sequence length", seq.size() == 3) or failed
	var step0: Dictionary = seq[0]
	var step1: Dictionary = seq[1]
	var step2: Dictionary = seq[2]
	failed = _check(failed, "sequence order", str(step0.get("id", "")) == "net" and str(step1.get("pool", "")) == "b2" and str(step2.get("id", "")) == "hex") or failed
	var frames: Array = []
	for raw_case in Cases.resolved_cases(rules):
		frames.append(str((raw_case as Dictionary).get("frame", "")))
	failed = _check(failed, "frame paths", frames == [
		"cabinets/case_verdant_hollow",
		"cabinets/case_sunken_mire",
		"cabinets/case_ashen_crypt",
		"cabinets/case_cinder_forge",
		"cabinets/case_shadow_abyss",
	]) or failed
	if failed:
		print("BIOME_CABINETS_FAIL")
		quit(1)
		return
	print("BIOME_CABINETS_OK")
	quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		return failed
	push_error(label)
	return true
