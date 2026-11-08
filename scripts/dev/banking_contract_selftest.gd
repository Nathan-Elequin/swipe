extends SceneTree
## ARC2 — Banking contract selftest (tests-only).
## CampaignShell ledger / unlock math for the weekend progression contract.
## Does not boot main.gd. Does not call CampaignShell.write / user save I/O.
## Row kinds: ASSERT (evaluated shell/catalog), STATIC (source-shape), NOTE, UNCOVERED.
## Only ASSERT/STATIC failures fail the process. NOTE/UNCOVERED never count as PASS.


const OK_MARK := "BANKING_CONTRACT_OK"
const FAIL_MARK := "BANKING_CONTRACT_FAIL"

## Audit §3.3 / plan fixtures (revalidated against catalog at tip). Distinct ids.
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
	var case_rows: Array = [] ## {kind, id, expected, actual, result}

	## --- Helper correctness for multiset compare (ASSERT) ---
	failed = _assert(
		case_rows, failed, "META.multiset_rejects_dup_mismatch",
		"_same_id_multiset([net,sai],[net,net]) is false (length+membership alone is insufficient)",
		not _same_id_multiset(["net", "sai"], ["net", "net"]),
		"helper_ok"
	) or failed
	failed = _assert(
		case_rows, failed, "META.multiset_accepts_permutation",
		"_same_id_multiset accepts same counts regardless of order",
		_same_id_multiset(["sai", "net"], ["net", "sai"]),
		"helper_ok"
	) or failed

	## --- Catalog attribution ---
	var pools_by_id: Dictionary = _pools_from_catalog(catalog, Bucket, Shell, rules)
	failed = _assert(
		case_rows, failed, "ATTR.catalog_b1_openers",
		"net/sai/shield/spinning_top/throwing_knife/flying_saucer → b1",
		_all_pool(pools_by_id, A + [F], "b1"),
		"pools=%s" % _subset(pools_by_id, A + [F])
	) or failed
	failed = _assert(
		case_rows, failed, "ATTR.breastplate_is_b2",
		"breastplate catalog pool → b2 (item origin, not delve location)",
		str(pools_by_id.get(BREASTPLATE, "")) == "b2",
		"pool=%s" % str(pools_by_id.get(BREASTPLATE, ""))
	) or failed
	failed = _assert(
		case_rows, failed, "ATTR.smoke_bomb_catalog_b1",
		"smoke_bomb catalog pool → b1 (current; mill-skip ≠ bank skip)",
		str(pools_by_id.get(SMOKE, "")) == "b1",
		"pool=%s" % str(pools_by_id.get(SMOKE, ""))
	) or failed
	failed = _assert(
		case_rows, failed, "ATTR.bracers_catalog_b1",
		"bracers catalog pool → b1 (current; pair-extra ≠ bank skip)",
		str(pools_by_id.get(BRACERS, "")) == "b1",
		"pool=%s" % str(pools_by_id.get(BRACERS, ""))
	) or failed
	failed = _assert(
		case_rows, failed, "ATTR.quota_five",
		"cabinet_quota == 5",
		Shell.quota_of(rules) == 5,
		"quota=%s" % Shell.quota_of(rules)
	) or failed

	## --- B0–B3 ---
	var s0: Dictionary = Shell.fresh_state()
	var r0: Dictionary = Shell.bank(rules, s0, [], pools_by_id)
	failed = _assert(
		case_rows, failed, "B0.empty_hand",
		"bank [] → added 0, b1=0, dungeon2 locked",
		(r0.get("added", []) as Array).is_empty()
		and Shell.cabinet_count(s0, "b1") == 0
		and not Shell.biome_unlocked(rules, s0, 1),
		"added=%s b1=%s can_start1=%s" % [
			r0.get("added", []), Shell.cabinet_count(s0, "b1"), Shell.can_start(rules, s0, 1)
		]
	) or failed

	var s1: Dictionary = Shell.fresh_state()
	var r1: Dictionary = Shell.bank(rules, s1, ["net"], pools_by_id)
	failed = _assert(
		case_rows, failed, "B1.one_held",
		"bank [net] → +1 b1, dungeon2 locked",
		(r1.get("added", []) as Array) == ["net"]
		and Shell.cabinet_count(s1, "b1") == 1
		and not Shell.biome_unlocked(rules, s1, 1),
		"added=%s b1=%s" % [r1.get("added", []), Shell.cabinet_count(s1, "b1")]
	) or failed

	var s2: Dictionary = Shell.fresh_state()
	var r2: Dictionary = Shell.bank(rules, s2, ["net", "sai"], pools_by_id)
	failed = _assert(
		case_rows, failed, "B2.two_held",
		"bank [net,sai] → +2 b1, dungeon2 locked (distinct fixtures)",
		_same_id_multiset(r2.get("added", []), ["net", "sai"])
		and Shell.cabinet_count(s2, "b1") == 2
		and not Shell.biome_unlocked(rules, s2, 1),
		"added=%s b1=%s" % [r2.get("added", []), Shell.cabinet_count(s2, "b1")]
	) or failed

	var s6: Dictionary = Shell.fresh_state()
	var haul6: Array = A + [F]
	var r6: Dictionary = Shell.bank(rules, s6, haul6, pools_by_id)
	failed = _assert(
		case_rows, failed, "B3.six_held_A_plus_F",
		"bank A+F → +6 b1, Crystal Cavern destination open; fresh-start stays D1 (INTENDED 0→6)",
		_same_id_multiset(r6.get("added", []), haul6)
		and Shell.cabinet_count(s6, "b1") == 6
		and Shell.biome_unlocked(rules, s6, 1)
		and not Shell.can_start(rules, s6, 1)
		and Shell.can_start(rules, s6, 0)
		and not Shell.cabinets_complete(rules, s6),
		"added_n=%s b1=%s dest1=%s can_start1=%s complete_all=%s" % [
			(r6.get("added", []) as Array).size(),
			Shell.cabinet_count(s6, "b1"),
			Shell.biome_unlocked(rules, s6, 1),
			Shell.can_start(rules, s6, 1),
			Shell.cabinets_complete(rules, s6),
		]
	) or failed
	failed = _assert(
		case_rows, failed, "B3.bank_alone_no_stamp",
		"bank alone grants no map piece (ceremony separate)",
		Shell.map_piece_count(s6) == 0,
		"pieces=%s" % Shell.map_piece_count(s6)
	) or failed

	## --- B4: shell sees only the explicit id list (not in-game consume/drop/carry-in) ---
	var s4: Dictionary = Shell.fresh_state()
	var filtered_list: Array = ["net"] ## caller omitted sai/shield; shell never saw them
	var r4: Dictionary = Shell.bank(rules, s4, filtered_list, pools_by_id)
	failed = _assert(
		case_rows, failed, "B4.shell_explicit_filtered_list",
		"bank([net]) credits only net; ids absent from the list get 0 (shell input filter, not consume/drop path)",
		(r4.get("added", []) as Array) == ["net"]
		and Shell.cabinet_count(s4, "b1") == 1
		and not (s4["banked"] as Dictionary).has("sai")
		and not (s4["banked"] as Dictionary).has("shield"),
		"banked=%s" % (s4["banked"] as Dictionary).keys()
	) or failed
	_uncovered(
		case_rows,
		"B4.live_consume_drop_carry_in",
		"In-run consume / drop / starter carry-in → hotbar → bank is not exercised; B4 only feeds an explicit filtered id list into CampaignShell.bank"
	)

	## --- B5 duplicates ---
	var s5: Dictionary = Shell.fresh_state()
	var r5a: Dictionary = Shell.bank(rules, s5, ["net", "net"], pools_by_id)
	var r5b: Dictionary = Shell.bank(rules, s5, ["net"], pools_by_id)
	failed = _assert(
		case_rows, failed, "B5.duplicate_same_haul_then_repeat",
		"[net,net] → +1; bank net again → +0; b1 stays 1",
		(r5a.get("added", []) as Array) == ["net"]
		and (r5b.get("added", []) as Array).is_empty()
		and Shell.cabinet_count(s5, "b1") == 1,
		"first=%s second=%s b1=%s" % [
			r5a.get("added", []), r5b.get("added", []), Shell.cabinet_count(s5, "b1")
		]
	) or failed

	## --- B6 smoke_bomb / bracers current bank credit ---
	var s_sb: Dictionary = Shell.fresh_state()
	var r_sb: Dictionary = Shell.bank(rules, s_sb, [SMOKE, BRACERS], pools_by_id)
	failed = _assert(
		case_rows, failed, "B6.smoke_and_bracers_bank_b1",
		"smoke_bomb+bracers with catalog pools → both credit b1 (current behavior)",
		_same_id_multiset(r_sb.get("added", []), [SMOKE, BRACERS])
		and Shell.cabinet_count(s_sb, "b1") == 2
		and str((s_sb["banked"] as Dictionary).get(SMOKE, "")) == "b1"
		and str((s_sb["banked"] as Dictionary).get(BRACERS, "")) == "b1",
		"added=%s b1=%s" % [r_sb.get("added", []), Shell.cabinet_count(s_sb, "b1")]
	) or failed
	_note(
		case_rows,
		"B6.mill_skip_vs_bank",
		"Mill-skip (BucketRules) is orthogonal to CampaignShell.bank; eligibility here is caller pools_by_id. Covered by B6 credit ASSERT above — not a separate evaluated proof that production never filters."
	)

	## --- U1 / U2 / U3 ---
	var su1: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su1, FOUR, pools_by_id)
	failed = _assert(
		case_rows, failed, "U1.four_baseline_locked",
		"four baseline → b1=4, dungeon2 locked",
		Shell.cabinet_count(su1, "b1") == 4 and not Shell.biome_unlocked(rules, su1, 1),
		"b1=%s unlock1=%s" % [Shell.cabinet_count(su1, "b1"), Shell.biome_unlocked(rules, su1, 1)]
	) or failed
	var ru1: Dictionary = Shell.bank(rules, su1, [KNIFE], pools_by_id)
	failed = _assert(
		case_rows, failed, "U1.four_to_five_unlocks",
		"4→5 via throwing_knife unlocks Crystal Cavern destination; fresh-start stays D1; Pool1 complete still false",
		(ru1.get("added", []) as Array) == [KNIFE]
		and Shell.cabinet_count(su1, "b1") == 5
		and Shell.biome_unlocked(rules, su1, 1)
		and not Shell.can_start(rules, su1, 1)
		and Shell.can_start(rules, su1, 0)
		and not Shell.cabinets_complete(rules, su1),
		"b1=%s dest1=%s can_start1=%s complete=%s" % [
			Shell.cabinet_count(su1, "b1"),
			Shell.biome_unlocked(rules, su1, 1),
			Shell.can_start(rules, su1, 1),
			Shell.cabinets_complete(rules, su1),
		]
	) or failed

	var su2a: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su2a, A, pools_by_id)
	failed = _assert(
		case_rows, failed, "U2.zero_to_five_first_return",
		"first successful return with A (5) unlocks dungeon2 destination; start stays D1 (INTENDED)",
		Shell.cabinet_count(su2a, "b1") == 5
		and Shell.biome_unlocked(rules, su2a, 1)
		and not Shell.can_start(rules, su2a, 1)
		and Shell.can_start(rules, su2a, 0),
		"b1=%s dest1=%s can_start1=%s" % [
			Shell.cabinet_count(su2a, "b1"),
			Shell.biome_unlocked(rules, su2a, 1),
			Shell.can_start(rules, su2a, 1),
		]
	) or failed
	var su2b: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su2b, A + [F], pools_by_id)
	failed = _assert(
		case_rows, failed, "U2.zero_to_six_first_return",
		"first successful return with A+F (6) unlocks destination; start stays D1; six openers vs quota five INTENDED",
		Shell.cabinet_count(su2b, "b1") == 6
		and Shell.biome_unlocked(rules, su2b, 1)
		and not Shell.can_start(rules, su2b, 1)
		and Shell.can_start(rules, su2b, 0),
		"b1=%s dest1=%s can_start1=%s" % [
			Shell.cabinet_count(su2b, "b1"),
			Shell.biome_unlocked(rules, su2b, 1),
			Shell.can_start(rules, su2b, 1),
		]
	) or failed

	var su3: Dictionary = Shell.fresh_state()
	Shell.bank(rules, su3, A, pools_by_id)
	var stamp1: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
	failed = _assert(
		case_rows, failed, "U3.stamp_first_after_threshold",
		"stamp after 5 → first Crystal Cavern piece",
		str(stamp1.get("id", "")) == "b2" and bool(stamp1.get("first", false))
		and Shell.map_piece_count(su3) == 1,
		"stamp=%s pieces=%s" % [stamp1, Shell.map_piece_count(su3)]
	) or failed
	var ru3_dup: Dictionary = Shell.bank(rules, su3, A, pools_by_id)
	var ru3_new: Dictionary = Shell.bank(rules, su3, [F], pools_by_id)
	var stamp2: Dictionary = Shell.stamp_map_piece(rules, su3, "b1")
	failed = _assert(
		case_rows, failed, "U3.later_bank_no_repeated_unlock_stamp",
		"repeat A → +0; new F → +1; stamp again not first; destination unlock stays; start stays D1",
		(ru3_dup.get("added", []) as Array).is_empty()
		and (ru3_new.get("added", []) as Array) == [F]
		and Shell.cabinet_count(su3, "b1") == 6
		and Shell.biome_unlocked(rules, su3, 1)
		and not Shell.can_start(rules, su3, 1)
		and Shell.can_start(rules, su3, 0)
		and not bool(stamp2.get("first", true))
		and Shell.map_piece_count(su3) == 1,
		"dup=%s new=%s b1=%s dest1=%s can_start1=%s stamp2_first=%s pieces=%s" % [
			ru3_dup.get("added", []),
			ru3_new.get("added", []),
			Shell.cabinet_count(su3, "b1"),
			Shell.biome_unlocked(rules, su3, 1),
			Shell.can_start(rules, su3, 1),
			stamp2.get("first", null),
			Shell.map_piece_count(su3),
		]
	) or failed

	## --- P1 isolated in-memory persist helpers (not live user save non-write proof) ---
	var sp: Dictionary = Shell.fresh_state()
	Shell.bank(rules, sp, A, pools_by_id)
	Shell.stamp_map_piece(rules, sp, "b1")
	var disk_json := JSON.stringify(sp)
	var parsed: Variant = JSON.parse_string(disk_json)
	failed = _assert(
		case_rows, failed, "P1.roundtrip_parse",
		"JSON.stringify → parse_string yields Dictionary (in-memory fixture)",
		typeof(parsed) == TYPE_DICTIONARY,
		"typeof=%s" % typeof(parsed)
	) or failed
	var shell_load = Shell.new()
	shell_load._copy_state(parsed as Dictionary)
	Shell.normalize(shell_load.state)
	failed = _assert(
		case_rows, failed, "P1.load_keeps_ledger_and_count",
		"after _copy_state+normalize: b1=5, net present, map piece count 1",
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
	failed = _assert(
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
	_note(
		case_rows,
		"P1.suite_avoids_live_save_io",
		"Suite design uses fresh_state / JSON.stringify / _copy_state only. That is not a runtime proof production never writes user://campaign_save.json."
	)

	## --- L1 / per-origin ---
	var sl: Dictionary = Shell.fresh_state()
	Shell.bank(rules, sl, A, pools_by_id)
	var rl: Dictionary = Shell.bank(rules, sl, [BREASTPLATE], pools_by_id)
	failed = _assert(
		case_rows, failed, "L1.breastplate_credits_b2_not_location",
		"breastplate with catalog pool credits b2; b1 retained",
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
	Shell.bank(rules, mix, ["net", "sai", BREASTPLATE], pools_by_id)
	failed = _assert(
		case_rows, failed, "L1.per_origin_counters",
		"per-origin cabinet_count: b1=2, b2=1 independently",
		Shell.cabinet_count(mix, "b1") == 2 and Shell.cabinet_count(mix, "b2") == 1,
		"b1=%s b2=%s" % [Shell.cabinet_count(mix, "b1"), Shell.cabinet_count(mix, "b2")]
	) or failed

	## --- STATIC source-shape (immutable tip source; not general runtime proof) ---
	var road_body := _func_body("res://scripts/main.gd", "_road_finish_to_cabin")
	failed = _static(
		case_rows, failed, "T.src_tutorial_finish_no_bank_call",
		"STATIC: _road_finish_to_cabin body has no CampaignShell.bank / _campaign_bank_from_hand / swipe_ids; opens progress menu (tutorial zero credit)",
		road_body != ""
		and road_body.find("CampaignShell.bank") < 0
		and road_body.find("_campaign_bank_from_hand") < 0
		and road_body.find("swipe_ids") < 0
		and (
			road_body.find('_open_progress_menu("tutorial"') >= 0
			or road_body.find("_open_progress_menu(tut_kind") >= 0
		),
		"has_progress_menu=%s has_bank=%s" % [
			road_body.find('_open_progress_menu("tutorial"') >= 0
			or road_body.find("_open_progress_menu(tut_kind") >= 0,
			road_body.find("_campaign_bank_from_hand") >= 0,
		]
	) or failed
	failed = _static(
		case_rows, failed, "T.src_yes_skip_finish_call_strings",
		"STATIC: main.gd source contains _road_finish_to_cabin(true) and (...false) strings — not Yes/Skip/midSkip three-route execution",
		_source_contains("res://scripts/main.gd", "_road_finish_to_cabin(true)")
		and _source_contains("res://scripts/main.gd", "_road_finish_to_cabin(false)"),
		"true_call=%s false_call=%s" % [
			_source_contains("res://scripts/main.gd", "_road_finish_to_cabin(true)"),
			_source_contains("res://scripts/main.gd", "_road_finish_to_cabin(false)"),
		]
	) or failed
	var loss_body := _func_body("res://scripts/main.gd", "_go_home_loss")
	var abort_body := _func_body("res://scripts/main.gd", "_campaign_abort")
	failed = _static(
		case_rows, failed, "N.src_death_loss_no_bank",
		"STATIC: _go_home_loss body references _campaign_abort; _campaign_abort body has no .bank( call",
		loss_body.find("_campaign_abort") >= 0
		and abort_body != ""
		and abort_body.find("CAMPAIGN_SHELL.bank") < 0
		and abort_body.find(".bank(") < 0,
		"loss_calls_abort=%s abort_has_bank=%s" % [
			loss_body.find("_campaign_abort") >= 0,
			abort_body.find(".bank(") >= 0,
		]
	) or failed

	_uncovered(
		case_rows,
		"BOUNDARY.mocked_empty_hand_not_caller_proof",
		"bank([]) / empty-list helper pass is not proof tutorial or death callers never bank; STATIC rows only reflect current source shape"
	)
	_uncovered(
		case_rows,
		"BOUNDARY.ui_cabin_hotbar_save",
		"Cabin clicks, live hotbar, Trophy Room UI, exported-web save, and real _campaign_bank_from_hand under hotbar are not covered (ARC1/3/4/6 + human matrix)"
	)

	var totals := _count_kinds(case_rows)
	print("--- BANKING_CONTRACT_CASES ---")
	for raw_row in case_rows:
		var row: Dictionary = raw_row
		print(
			"%s\t%s\t%s\texpected=%s\tactual=%s"
			% [
				row.get("result", ""),
				row.get("kind", ""),
				row.get("id", ""),
				row.get("expected", ""),
				row.get("actual", ""),
			]
		)
	print("--- BANKING_CONTRACT_CASES_END ---")
	print(
		"TOTALS\tassert_pass=%s\tassert_fail=%s\tstatic_pass=%s\tstatic_fail=%s\tnote=%s\tuncovered=%s"
		% [
			totals["assert_pass"],
			totals["assert_fail"],
			totals["static_pass"],
			totals["static_fail"],
			totals["note"],
			totals["uncovered"],
		]
	)

	if failed or int(totals["assert_fail"]) > 0 or int(totals["static_fail"]) > 0:
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


## Multiset equality by id counts (order-insensitive). Rejects [net,sai] vs [net,net].
func _same_id_multiset(a: Variant, b: Array) -> bool:
	if typeof(a) != TYPE_ARRAY:
		return false
	var left: Array = a
	if left.size() != b.size():
		return false
	var counts := {}
	for raw in left:
		var k := str(raw)
		counts[k] = int(counts.get(k, 0)) + 1
	for raw2 in b:
		var k2 := str(raw2)
		if int(counts.get(k2, 0)) <= 0:
			return false
		counts[k2] = int(counts[k2]) - 1
	for leftover in counts.keys():
		if int(counts[leftover]) != 0:
			return false
	return true


func _assert(rows: Array, failed: bool, id: String, expected: String, ok: bool, actual: String) -> bool:
	return _eval_row(rows, failed, "ASSERT", id, expected, ok, actual)


func _static(rows: Array, failed: bool, id: String, expected: String, ok: bool, actual: String) -> bool:
	return _eval_row(rows, failed, "STATIC", id, expected, ok, actual)


func _note(rows: Array, id: String, text: String) -> void:
	rows.append({
		"kind": "NOTE",
		"id": id,
		"expected": text,
		"actual": "note",
		"result": "NOTE",
	})


func _uncovered(rows: Array, id: String, text: String) -> void:
	rows.append({
		"kind": "UNCOVERED",
		"id": id,
		"expected": text,
		"actual": "uncovered",
		"result": "UNCOVERED",
	})


func _eval_row(
	rows: Array, failed: bool, kind: String, id: String, expected: String, ok: bool, actual: String
) -> bool:
	var result := "PASS" if ok else "FAIL"
	rows.append({
		"kind": kind,
		"id": id,
		"expected": expected,
		"actual": actual,
		"result": result,
	})
	if ok:
		return failed
	push_error("%s %s :: %s :: actual=%s" % [kind, id, expected, actual])
	return true


func _count_kinds(rows: Array) -> Dictionary:
	var out := {
		"assert_pass": 0,
		"assert_fail": 0,
		"static_pass": 0,
		"static_fail": 0,
		"note": 0,
		"uncovered": 0,
	}
	for raw in rows:
		var row: Dictionary = raw
		var kind := str(row.get("kind", ""))
		var result := str(row.get("result", ""))
		if kind == "ASSERT":
			if result == "PASS":
				out["assert_pass"] = int(out["assert_pass"]) + 1
			else:
				out["assert_fail"] = int(out["assert_fail"]) + 1
		elif kind == "STATIC":
			if result == "PASS":
				out["static_pass"] = int(out["static_pass"]) + 1
			else:
				out["static_fail"] = int(out["static_fail"]) + 1
		elif kind == "NOTE":
			out["note"] = int(out["note"]) + 1
		elif kind == "UNCOVERED":
			out["uncovered"] = int(out["uncovered"]) + 1
	return out


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
