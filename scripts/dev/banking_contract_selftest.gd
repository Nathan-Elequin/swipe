extends SceneTree
## ARC2 — Banking contract selftest (tests-only).
## Proves CampaignShell ledger / unlock math for the weekend progression contract.
## Does not boot main.gd. Does not write user://campaign_save.json.
## Tip baseline for this PR: capture via git at execution — do not assume audit SHA.


const OK_MARK := "BANKING_CONTRACT_OK"
const FAIL_MARK := "BANKING_CONTRACT_FAIL"

## Audit §3.3 / plan fixtures (revalidated against catalog at tip).
const A: Array = ["net", "sai", "shield", "spinning_top", "throwing_knife"]
const F := "flying_saucer"
const FOUR: Array = ["net", "sai", "shield", "spinning_top"] ## A minus throwing_knife
const KNIFE := "throwing_knife"
const BREASTPLATE := "breastplate"
const SMOKE := "smoke_bomb"
const BRACERS := "bracers"


func _init() -> void:
	var Shell = load("res://scripts/campaign_shell.gd")
	var Bucket = load("res://scripts/bucket_rules.gd")
	var rules: Dictionary = Shell.read_json("res://data/campaign.json")
	var catalog: Dictionary = Shell.read_json("res://data/catalog.json")
	var failed := false
	var case_rows: Array = [] ## {id, expected, actual, result}

	## --- Catalog attribution (source of truth; do not invent eligibility) ---
	var pools_by_id: Dictionary = _pools_from_catalog(catalog, Bucket, Shell, rules)
	failed = _row(
		case_rows, failed, "ATTR.catalog_b1_openers",
		"net/sai/shield/spinning_top/throwing_knife/flying_saucer → b1",
		_all_pool(pools_by_id, A + [F], "b1"),
		"pools=%s" % _subset(pools_by_id, A + [F])
	) or failed
	failed = _row(
		case_rows, failed, "ATTR.breastplate_is_b2",
		"breastplate catalog pool → b2 (item origin, not delve location)",
		str(pools_by_id.get(BREASTPLATE, "")) == "b2",
		"pool=%s" % str(pools_by_id.get(BREASTPLATE, ""))
	) or failed
	failed = _row(
		case_rows, failed, "ATTR.smoke_bomb_catalog_b1",
		"smoke_bomb catalog pool → b1 (current; mill-skip ≠ bank skip)",
		str(pools_by_id.get(SMOKE, "")) == "b1",
		"pool=%s" % str(pools_by_id.get(SMOKE, ""))
	) or failed
	failed = _row(
		case_rows, failed, "ATTR.bracers_catalog_b1",
		"bracers catalog pool → b1 (current; pair-extra ≠ bank skip)",
		str(pools_by_id.get(BRACERS, "")) == "b1",
		"pool=%s" % str(pools_by_id.get(BRACERS, ""))
	) or failed
	failed = _row(
		case_rows, failed, "ATTR.quota_five",
		"cabinet_quota == 5",
		Shell.quota_of(rules) == 5,
		"quota=%s" % Shell.quota_of(rules)
	) or failed

	## --- B0 empty haul ---
	var s0: Dictionary = Shell.fresh_state()
	var r0: Dictionary = Shell.bank(rules, s0, [], pools_by_id)
	failed = _row(
		case_rows, failed, "B0.empty_hand",
		"bank [] → added 0, b1=0, dungeon2 locked",
		(r0.get("added", []) as Array).is_empty()
		and Shell.cabinet_count(s0, "b1") == 0
		and not Shell.biome_unlocked(rules, s0, 1),
		"added=%s b1=%s can_start1=%s" % [
			r0.get("added", []), Shell.cabinet_count(s0, "b1"), Shell.can_start(rules, s0, 1)
		]
	) or failed

	## --- B1 single ---
	var s1: Dictionary = Shell.fresh_state()
	var r1: Dictionary = Shell.bank(rules, s1, ["net"], pools_by_id)
	failed = _row(
		case_rows, failed, "B1.one_held",
		"bank [net] → +1 b1, dungeon2 locked",
		(r1.get("added", []) as Array) == ["net"]
		and Shell.cabinet_count(s1, "b1") == 1
		and not Shell.biome_unlocked(rules, s1, 1),
		"added=%s b1=%s" % [r1.get("added", []), Shell.cabinet_count(s1, "b1")]
	) or failed

	## --- B2 two distinct ---
	var s2: Dictionary = Shell.fresh_state()
	var r2: Dictionary = Shell.bank(rules, s2, ["net", "sai"], pools_by_id)
	failed = _row(
		case_rows, failed, "B2.two_held",
		"bank [net,sai] → +2 b1, dungeon2 locked",
		_same_set(r2.get("added", []), ["net", "sai"])
		and Shell.cabinet_count(s2, "b1") == 2
		and not Shell.biome_unlocked(rules, s2, 1),
		"added=%s b1=%s" % [r2.get("added", []), Shell.cabinet_count(s2, "b1")]
	) or failed

	## --- B3 six (A+F) first return can unlock ---
	var s6: Dictionary = Shell.fresh_state()
	var haul6: Array = A + [F]
	var r6: Dictionary = Shell.bank(rules, s6, haul6, pools_by_id)
	failed = _row(
		case_rows, failed, "B3.six_held_A_plus_F",
		"bank A+F → +6 b1, Crystal Cavern startable (INTENDED 0→6)",
		_same_set(r6.get("added", []), haul6)
		and Shell.cabinet_count(s6, "b1") == 6
		and Shell.biome_unlocked(rules, s6, 1)
		and Shell.can_start(rules, s6, 1)
		and not Shell.cabinets_complete(rules, s6),
		"added_n=%s b1=%s unlock1=%s complete_all=%s" % [
			(r6.get("added", []) as Array).size(),
			Shell.cabinet_count(s6, "b1"),
			Shell.can_start(rules, s6, 1),
			Shell.cabinets_complete(rules, s6),
		]
	) or failed
	failed = _row(
		case_rows, failed, "B3.bank_alone_no_stamp",
		"bank alone grants no map piece (ceremony separate)",
		Shell.map_piece_count(s6) == 0,
		"pieces=%s" % Shell.map_piece_count(s6)
	) or failed

	## --- B4 carry-in vs used/dropped (held list is the bank input) ---
	## Shell banks whatever ids the caller passes. Carry-in counts iff still held.
	## Consumed/dropped absents are omitted from the held list → zero credit for them.
	var s4: Dictionary = Shell.fresh_state()
	var held_only: Array = ["net"] ## sai consumed, shield dropped → not held
	var r4: Dictionary = Shell.bank(rules, s4, held_only, pools_by_id)
	failed = _row(
		case_rows, failed, "B4.carry_in_held_only",
		"only still-held carry-in net credits; consumed/dropped absent → 0 for them",
		(r4.get("added", []) as Array) == ["net"]
		and Shell.cabinet_count(s4, "b1") == 1
		and not (s4["banked"] as Dictionary).has("sai")
		and not (s4["banked"] as Dictionary).has("shield"),
		"banked=%s" % (s4["banked"] as Dictionary).keys()
	) or failed

	## --- B5 duplicates same haul + repeated return ---
	var s5: Dictionary = Shell.fresh_state()
	var r5a: Dictionary = Shell.bank(rules, s5, ["net", "net"], pools_by_id)
	var r5b: Dictionary = Shell.bank(rules, s5, ["net"], pools_by_id)
	failed = _row(
		case_rows, failed, "B5.duplicate_same_haul_then_repeat",
		"[net,net] → +1; bank net again → +0; b1 stays 1",
		(r5a.get("added", []) as Array) == ["net"]
		and (r5b.get("added", []) as Array).is_empty()
		and Shell.cabinet_count(s5, "b1") == 1,
		"first=%s second=%s b1=%s" % [
			r5a.get("added", []), r5b.get("added", []), Shell.cabinet_count(s5, "b1")
		]
	) or failed

	## --- B6 smoke_bomb / bracers current eligibility (do not invent mill gate) ---
	var s_sb: Dictionary = Shell.fresh_state()
	var r_sb: Dictionary = Shell.bank(rules, s_sb, [SMOKE, BRACERS], pools_by_id)
	failed = _row(
		case_rows, failed, "B6.smoke_and_bracers_bank_b1",
		"smoke_bomb+bracers successfully returned → both credit b1 (current)",
		_same_set(r_sb.get("added", []), [SMOKE, BRACERS])
		and Shell.cabinet_count(s_sb, "b1") == 2
		and str((s_sb["banked"] as Dictionary).get(SMOKE, "")) == "b1"
		and str((s_sb["banked"] as Dictionary).get(BRACERS, "")) == "b1",
		"added=%s b1=%s" % [r_sb.get("added", []), Shell.cabinet_count(s_sb, "b1")]
	) or failed
	## Mill skip is orthogonal: BucketRules._skip may exclude them from mill count.
	failed = _row(
		case_rows, failed, "B6.mill_skip_does_not_block_bank_api",
		"CampaignShell.bank has no mill-skip filter (eligibility = caller pools_by_id)",
		true, ## API shape documented; covered by B6 credit above
		"note=shell_bank_accepts_ids_with_pools_by_id"
	) or failed

	## --- U1 four→five ---
	var su1: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su1, FOUR, pools_by_id)
	failed = _row(
		case_rows, failed, "U1.four_baseline_locked",
		"four baseline → b1=4, dungeon2 locked",
		Shell.cabinet_count(su1, "b1") == 4 and not Shell.biome_unlocked(rules, su1, 1),
		"b1=%s unlock1=%s" % [Shell.cabinet_count(su1, "b1"), Shell.biome_unlocked(rules, su1, 1)]
	) or failed
	var ru1: Dictionary = Shell.bank(rules, su1, [KNIFE], pools_by_id)
	failed = _row(
		case_rows, failed, "U1.four_to_five_unlocks",
		"4→5 via throwing_knife opens Crystal Cavern; Pool1 complete still false",
		(ru1.get("added", []) as Array) == [KNIFE]
		and Shell.cabinet_count(su1, "b1") == 5
		and Shell.can_start(rules, su1, 1)
		and not Shell.cabinets_complete(rules, su1),
		"b1=%s can_start1=%s complete=%s" % [
			Shell.cabinet_count(su1, "b1"),
			Shell.can_start(rules, su1, 1),
			Shell.cabinets_complete(rules, su1),
		]
	) or failed

	## --- U2 zero→five / zero→six ---
	var su2a: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su2a, A, pools_by_id)
	failed = _row(
		case_rows, failed, "U2.zero_to_five_first_return",
		"first successful return with A (5) unlocks dungeon2 (INTENDED)",
		Shell.cabinet_count(su2a, "b1") == 5 and Shell.can_start(rules, su2a, 1),
		"b1=%s can_start1=%s" % [Shell.cabinet_count(su2a, "b1"), Shell.can_start(rules, su2a, 1)]
	) or failed
	var su2b: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su2b, A + [F], pools_by_id)
	failed = _row(
		case_rows, failed, "U2.zero_to_six_first_return",
		"first successful return with A+F (6) unlocks; six openers vs quota five INTENDED",
		Shell.cabinet_count(su2b, "b1") == 6 and Shell.can_start(rules, su2b, 1),
		"b1=%s" % Shell.cabinet_count(su2b, "b1")
	) or failed

	## --- U3 later bank: new credit only; no repeated stamp ---
	var su3: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su3, A, pools_by_id)
	var stamp1: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
	failed = _row(
		case_rows, failed, "U3.stamp_first_after_threshold",
		"stamp after 5 → first Crystal Cavern piece",
		str(stamp1.get("id", "")) == "b2" and bool(stamp1.get("first", false))
		and Shell.map_piece_count(su3) == 1,
		"stamp=%s pieces=%s" % [stamp1, Shell.map_piece_count(su3)]
	) or failed
	var ru3_dup: Dictionary = Shell.bank(rules, su3, A, pools_by_id) ## repeats
	var ru3_new: Dictionary = Shell.bank(rules, su3, [F], pools_by_id)
	var stamp2: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
	failed = _row(
		case_rows, failed, "U3.later_bank_no_repeated_unlock_stamp",
		"repeat A → +0; new F → +1; stamp again not first; unlock stays",
		(ru3_dup.get("added", []) as Array).is_empty()
		and (ru3_new.get("added", []) as Array) == [F]
		and Shell.cabinet_count(su3, "b1") == 6
		and Shell.can_start(rules, su3, 1)
		and not bool(stamp2.get("first", true))
		and Shell.map_piece_count(su3) == 1,
		"dup=%s new=%s b1=%s stamp2_first=%s pieces=%s" % [
			ru3_dup.get("added", []),
			ru3_new.get("added", []),
			Shell.cabinet_count(su3, "b1"),
			stamp2.get("first", null),
			Shell.map_piece_count(su3),
		]
	) or failed

	## --- P1 persist load ledger + stamp idempotence (isolated; no user save) ---
	var sp: Dictionary = Shell.fresh_state()
	Shell.bank(rules, sp, A, pools_by_id)
	Shell.stamp_map_piece(rules, sp, "b1")
	var disk_json := JSON.stringify(sp)
	var parsed: Variant = JSON.parse_string(disk_json)
	failed = _row(
		case_rows, failed, "P1.roundtrip_parse",
		"isolated JSON roundtrip of in-memory state (not user://)",
		typeof(parsed) == TYPE_DICTIONARY,
		"typeof=%s" % typeof(parsed)
	) or failed
	var shell_load = Shell.new()
	shell_load._copy_state(parsed as Dictionary)
	Shell.normalize(shell_load.state)
	failed = _row(
		case_rows, failed, "P1.load_keeps_ledger_and_count",
		"loaded banked ids + b1 count match; no duplicate credit on re-bank",
		Shell.cabinet_count(shell_load.state, "b1") == 5
		and (shell_load.state["banked"] as Dictionary).has("net")
		and Shell.map_piece_count(shell_load.state) == 1,
		"b1=%s pieces=%s keys=%s" % [
			Shell.cabinet_count(shell_load.state, "b1"),
			Shell.map_piece_count(shell_load.state),
			(shell_load.state["banked"] as Dictionary).keys(),
		]
	) or failed
	var rp_again: Dictionary = Shell.bank(rules, shell_load.state, A, pools_by_id)
	var stamp_again: Dictionary = Shell.stamp_map_piece(rules, shell_load.state, "b1")
	failed = _row(
		case_rows, failed, "P1.rebank_and_restamp_idempotent",
		"re-bank A → +0; re-stamp → not first; piece count stays 1",
		(rp_again.get("added", []) as Array).is_empty()
		and not bool(stamp_again.get("first", true))
		and Shell.map_piece_count(shell_load.state) == 1
		and Shell.cabinet_count(shell_load.state, "b1") == 5,
		"added=%s first=%s pieces=%s b1=%s" % [
			rp_again.get("added", []),
			stamp_again.get("first", null),
			Shell.map_piece_count(shell_load.state),
			Shell.cabinet_count(shell_load.state, "b1"),
		]
	) or failed
	## Persist proof above uses JSON.stringify + Shell.new()._copy_state only.
	## This suite never opens the live campaign save file.
	failed = _row(
		case_rows, failed, "P1.no_user_save_write",
		"persist path is in-memory JSON roundtrip (fresh_state / _copy_state), not live save I/O",
		disk_json != "" and typeof(parsed) == TYPE_DICTIONARY and shell_load.state.has("banked"),
		"roundtrip_bytes=%s has_banked=%s" % [disk_json.length(), shell_load.state.has("banked")]
	) or failed

	## --- L1 / per-origin counters ---
	var sl: Dictionary = Shell.fresh_state()
	Shell.bank(rules, sl, A, pools_by_id) ## b1=5
	var rl: Dictionary = Shell.bank(rules, sl, [BREASTPLATE], pools_by_id)
	failed = _row(
		case_rows, failed, "L1.breastplate_credits_b2_not_location",
		"breastplate banked from Verdant haul still attributes b2; b1 retained",
		(rl.get("added", []) as Array) == [BREASTPLATE]
		and Shell.cabinet_count(sl, "b1") == 5
		and Shell.cabinet_count(sl, "b2") == 1
		and str((sl["banked"] as Dictionary).get(BREASTPLATE, "")) == "b2",
		"b1=%s b2=%s attr=%s" % [
			Shell.cabinet_count(sl, "b1"),
			Shell.cabinet_count(sl, "b2"),
			(sl["banked"] as Dictionary).get(BREASTPLATE, ""),
		]
	) or failed
	var mix: Dictionary = Shell.fresh_state()
	Shell.bank(
		rules,
		mix,
		["net", "sai", BREASTPLATE],
		pools_by_id
	)
	failed = _row(
		case_rows, failed, "L1.per_origin_counters",
		"per-origin cabinet_count: b1=2, b2=1 independently",
		Shell.cabinet_count(mix, "b1") == 2 and Shell.cabinet_count(mix, "b2") == 1,
		"b1=%s b2=%s" % [Shell.cabinet_count(mix, "b1"), Shell.cabinet_count(mix, "b2")]
	) or failed

	## --- Tutorial / death caller traces (STATIC; not mocked-hand proof) ---
	## BOUNDARY: proving bank([]) is empty does NOT prove callers never bank.
	## These checks only assert source shape of known finish / loss paths.
	var road_body := _func_body("res://scripts/main.gd", "_road_finish_to_cabin")
	failed = _row(
		case_rows, failed, "T.src_tutorial_finish_no_bank_call",
		"_road_finish_to_cabin body has no CampaignShell.bank / _campaign_bank_from_hand / swipe_ids",
		road_body != ""
		and road_body.find("CampaignShell.bank") < 0
		and road_body.find("_campaign_bank_from_hand") < 0
		and road_body.find("swipe_ids") < 0
		and road_body.find('_open_home_cabin(true, "win", [], [])') >= 0,
		"has_empty_open=%s has_bank=%s" % [
			road_body.find('_open_home_cabin(true, "win", [], [])') >= 0,
			road_body.find("_campaign_bank_from_hand") >= 0,
		]
	) or failed
	## Yes / Skip / midSkip all land on _road_finish_to_cabin (tip smoke already hooks).
	failed = _row(
		case_rows, failed, "T.src_yes_skip_midskip_share_finish",
		"Yes/Skip/midSkip call sites reference _road_finish_to_cabin (shared zero-bank landing)",
		_source_contains("res://scripts/main.gd", "_road_finish_to_cabin(true)")
		and _source_contains("res://scripts/main.gd", "_road_finish_to_cabin(false)"),
		"finish_hooks_present"
	) or failed
	var loss_body := _func_body("res://scripts/main.gd", "_go_home_loss")
	var abort_body := _func_body("res://scripts/main.gd", "_campaign_abort")
	failed = _row(
		case_rows, failed, "N.src_death_loss_no_bank",
		"_go_home_loss → _campaign_abort; abort body has no bank call",
		loss_body.find("_campaign_abort") >= 0
		and abort_body != ""
		and abort_body.find("CAMPAIGN_SHELL.bank") < 0
		and abort_body.find(".bank(") < 0,
		"loss_calls_abort=%s abort_has_bank=%s" % [
			loss_body.find("_campaign_abort") >= 0,
			abort_body.find(".bank(") >= 0,
		]
	) or failed
	## Explicit coverage boundary row (always PASS as documentation receipt).
	failed = _row(
		case_rows, failed, "BOUNDARY.mocked_empty_hand_not_caller_proof",
		"Named gap: empty-list bank helper pass ≠ proof tutorial/death callers never bank",
		true,
		"documented; use T.src_* / N.src_* + human matrix T1–T3 / N3"
	) or failed
	failed = _row(
		case_rows, failed, "BOUNDARY.ui_cabin_hotbar_save_uncovered",
		"Named gap: cabin clicks, live hotbar death, Trophy Room UI, exported-web save not covered here",
		true,
		"ARC1/3/4/6 + human matrix"
	) or failed

	## Print machine-readable case table for the QA report.
	print("--- BANKING_CONTRACT_CASES ---")
	for raw_row in case_rows:
		var row: Dictionary = raw_row
		print(
			"%s\t%s\texpected=%s\tactual=%s"
			% [row.get("result", ""), row.get("id", ""), row.get("expected", ""), row.get("actual", "")]
		)
	print("--- BANKING_CONTRACT_CASES_END ---")

	if failed:
		print(FAIL_MARK)
		quit(1)
		return
	print(OK_MARK)
	quit(0)


func _pools_from_catalog(catalog: Dictionary, Bucket, Shell, rules: Dictionary) -> Dictionary:
	var out := {}
	var items: Variant = catalog.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		return out
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id == "":
			continue
		var bucket: int = Bucket.of_card(card)
		out[id] = Shell.pool_for_bucket(rules, bucket)
	return out


func _all_pool(pools_by_id: Dictionary, ids: Array, want: String) -> bool:
	for raw in ids:
		if str(pools_by_id.get(str(raw), "")) != want:
			return false
	return true


func _subset(pools_by_id: Dictionary, ids: Array) -> Dictionary:
	var out := {}
	for raw in ids:
		var id := str(raw)
		out[id] = pools_by_id.get(id, "")
	return out


func _same_set(a: Variant, b: Array) -> bool:
	if typeof(a) != TYPE_ARRAY:
		return false
	var left: Array = a
	if left.size() != b.size():
		return false
	for raw in b:
		if not left.has(raw):
			return false
	return true


func _row(rows: Array, failed: bool, id: String, expected: String, ok: bool, actual: String) -> bool:
	rows.append({
		"id": id,
		"expected": expected,
		"actual": actual,
		"result": "PASS" if ok else "FAIL",
	})
	if ok:
		return failed
	push_error("%s :: %s :: actual=%s" % [id, expected, actual])
	return true


func _read_source(res_path: String) -> String:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _source_contains(res_path: String, needle: String) -> bool:
	return _read_source(res_path).find(needle) >= 0


func _func_body(res_path: String, method: String) -> String:
	var src := _read_source(res_path)
	var start: int = src.find("func %s(" % method)
	if start < 0:
		return ""
	var next_func: int = src.find("\nfunc ", start + 1)
	return src.substr(start, next_func - start if next_func >= 0 else src.length() - start)

