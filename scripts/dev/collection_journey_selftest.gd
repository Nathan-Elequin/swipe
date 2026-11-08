extends SceneTree
## Journey A — collection state projection selftest (no main.gd, no real save I/O).
## Run: ./tools/qa/run_collection_journey.sh


const OK_MARK := "COLLECTION_JOURNEY_OK"
const FAIL_MARK := "COLLECTION_JOURNEY_FAIL"
const JOURNEY := preload("res://scripts/collection_journey.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	var failed := false
	var rules: Dictionary = CAMPAIGN_SHELL.read_json("res://data/campaign.json")
	var catalog: Dictionary = CAMPAIGN_SHELL.read_json("res://data/catalog.json")
	var pools: Dictionary = JOURNEY.pools_from_catalog(catalog, rules)
	failed = _check(failed, "quota_five", CAMPAIGN_SHELL.quota_of(rules) == 5) or failed
	failed = _check(failed, "knife_is_b1", str(pools.get("throwing_knife", "")) == "b1") or failed

	var banked := {}
	var seen := {}
	var held: Array = []

	## unseen → unknown
	failed = _check(
		failed, "status_unknown",
		JOURNEY.item_status("throwing_knife", seen, banked, held) == JOURNEY.STATUS_UNKNOWN
	) or failed

	## offer/reveal: seen, not carried
	seen["throwing_knife"] = true
	failed = _check(
		failed, "status_seen_after_offer",
		JOURNEY.item_status("throwing_knife", seen, banked, held) == JOURNEY.STATUS_SEEN
	) or failed

	## take one copy → carried (provisional)
	held = ["throwing_knife"]
	failed = _check(
		failed, "status_carried",
		JOURNEY.item_status("throwing_knife", seen, banked, held) == JOURNEY.STATUS_CARRIED
	) or failed
	failed = _check(
		failed, "provisional_one",
		JOURNEY.provisional_distinct_ids(held, banked).size() == 1
	) or failed

	## duplicate held → still one distinct provisional
	held = ["throwing_knife", "throwing_knife"]
	failed = _check(
		failed, "provisional_dup_collapses",
		JOURNEY.provisional_distinct_ids(held, banked).size() == 1
	) or failed
	failed = _check(
		failed, "held_qty_two",
		JOURNEY.held_quantity(held, "throwing_knife") == 2
	) or failed

	## spend one copy → qty 1, provisional still 1
	held = ["throwing_knife"]
	failed = _check(
		failed, "after_spend_one_still_provisional",
		JOURNEY.provisional_distinct_ids(held, banked).size() == 1
	) or failed

	## spend last copy → provisional 0, seen persists
	held = []
	failed = _check(
		failed, "after_last_spend_zero_provisional",
		JOURNEY.provisional_distinct_ids(held, banked).is_empty()
	) or failed
	failed = _check(
		failed, "seen_survives_spend",
		JOURNEY.item_status("throwing_knife", seen, banked, held) == JOURNEY.STATUS_SEEN
	) or failed

	## 4 banked + 1 held knife → gate still 4/5; would_cross_on_bank true
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for id in ["net", "sai", "shield", "spinning_top"]:
		state["banked"][id] = "b1"
		seen[id] = true
	held = ["throwing_knife"]
	var gate: Dictionary = JOURNEY.gate_projection(rules, state, "b1", held, pools)
	failed = _check(failed, "gate_banked_four", int(gate.get("banked", 0)) == 4) or failed
	failed = _check(failed, "gate_not_open_on_carry", not bool(gate.get("gate_open_now", true))) or failed
	failed = _check(failed, "would_cross_on_bank", bool(gate.get("would_cross_on_bank", false))) or failed
	failed = _check(
		failed, "projected_five_if_banked",
		int(gate.get("projected_if_banked", 0)) == 5
	) or failed

	## bank knife → banked; catalogue collected
	var before: Dictionary = state.duplicate(true)
	var bank_result: Dictionary = CAMPAIGN_SHELL.bank(rules, state, ["throwing_knife"], pools)
	failed = _check(failed, "bank_added_knife", (bank_result.get("added", []) as Array).has("throwing_knife")) or failed
	held = []
	failed = _check(
		failed, "status_banked",
		JOURNEY.item_status("throwing_knife", seen, state["banked"], held) == JOURNEY.STATUS_BANKED
	) or failed
	failed = _check(
		failed, "catalogue_collected",
		JOURNEY.catalogue_cell_kind("throwing_knife", seen, state["banked"], ["throwing_knife"]) == "new"
	) or failed
	failed = _check(
		failed, "catalogue_seen_not_banked",
		JOURNEY.catalogue_cell_kind("breastplate", {"breastplate": true}, {}, []) == "seen"
	) or failed

	## milestones: gate 4→5 (+ optional cabinet_full when roster_totals say so)
	var ms: Array = JOURNEY.milestones_from_bank(rules, before, state, ["b1"], {"b1": 5})
	var has_gate := false
	var has_full := false
	for raw in ms:
		var kind := str((raw as Dictionary).get("kind", ""))
		if kind == "gate":
			has_gate = true
			failed = _check(
				failed, "gate_next_crystal",
				str((raw as Dictionary).get("next_id", "")) == "b2"
			) or failed
		elif kind == "cabinet_full":
			has_full = true
	failed = _check(failed, "milestone_gate_present", has_gate) or failed
	failed = _check(failed, "milestone_cabinet_full_at_roster", has_full) or failed

	## banked repeat still banked_carried when held again
	held = ["throwing_knife"]
	failed = _check(
		failed, "banked_repeat_status",
		JOURNEY.item_status("throwing_knife", seen, state["banked"], held) == JOURNEY.STATUS_BANKED_CARRIED
	) or failed
	failed = _check(
		failed, "banked_repeat_no_provisional",
		JOURNEY.provisional_distinct_ids(held, state["banked"]).is_empty()
	) or failed

	## cabinet_full helper (roster_total independent of Doop page size)
	var cab: Dictionary = JOURNEY.cabinet_complete_milestone("b1", 13, 14, 14)
	failed = _check(failed, "cabinet_full_fires", str(cab.get("kind", "")) == "cabinet_full") or failed
	var cab2: Dictionary = JOURNEY.cabinet_complete_milestone("b1", 5, 5, 14)
	failed = _check(failed, "cabinet_full_not_on_quota_alone", cab2.is_empty()) or failed

	## quiet summary shape
	var quiet: Dictionary = JOURNEY.quiet_run_summary(rules, state, ["net"], pools, "b1")
	failed = _check(failed, "quiet_has_quota", int(quiet.get("quota", 0)) == 5) or failed

	## loss: provisional gone, seen remains (simulation — no CampaignShell mutation of seen)
	held = []
	failed = _check(
		failed, "loss_keeps_seen",
		JOURNEY.item_status("breastplate", {"breastplate": true}, {}, held) == JOURNEY.STATUS_SEEN
	) or failed

	if failed:
		print(FAIL_MARK)
		quit(1)
	print(OK_MARK)
	quit(0)


func _check(failed: bool, id: String, ok: bool) -> bool:
	if ok:
		print("PASS ", id)
		return failed
	print("FAIL ", id)
	return true
