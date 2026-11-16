extends SceneTree
## Display-only tier language: item Common/Uncommon/Rare vs monster Minion/Elite/Boss.
## No Weak/Tough/Deadly as tier labels in player-copy / keyword-defs.

const COPY := preload("res://scripts/player_copy.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	COPY.reload()
	failed = _check_rank_maps() or failed
	failed = _check_no_legacy_tier_words() or failed
	failed = _check_bucket_labels() or failed
	failed = _check_swap_body() or failed
	if failed:
		push_error("tier_language self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK tier_language")
		quit(0)


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok


func _check_rank_maps() -> bool:
	var failed := false
	var item_want := {1: "Common", 2: "Uncommon", 3: "Rare"}
	var mon_want := {1: "Minion", 2: "Elite", 3: "Boss"}
	for t in [1, 2, 3]:
		failed = _check("item_%d" % t, COPY.item_rank_name(t) == str(item_want[t])) or failed
		failed = _check("monster_%d" % t, COPY.monster_rank_name(t) == str(mon_want[t])) or failed
		failed = _check("rank_name_item_%d" % t, COPY.rank_name(t, "item") == str(item_want[t])) or failed
		failed = _check("rank_name_monster_%d" % t, COPY.rank_name(t, "monster") == str(mon_want[t])) or failed
		failed = _check(
			"kinds_differ_%d" % t,
			COPY.item_rank_name(t) != COPY.monster_rank_name(t)
		) or failed
	failed = _check("legacy_tier_name_boss", COPY.tier_name(3) == "Boss") or failed
	return failed


func _check_no_legacy_tier_words() -> bool:
	var failed := false
	var banned := ["Weak", "Tough", "Deadly"]
	var keys := [
		"tier.1.name", "tier.2.name", "tier.3.name",
		"item.rank.1.name", "item.rank.2.name", "item.rank.3.name",
		"monster.rank.1.name", "monster.rank.2.name", "monster.rank.3.name",
		"rank.weak", "rank.tough", "rank.deadly",
		"journal.weak", "journal.tough", "journal.deadly",
		"keyword.swap_body", "tutorial.line.B47.3", "door.guard",
	]
	for key in keys:
		var body: String = COPY.text(key, "")
		for w in banned:
			if body.find(w) >= 0:
				failed = _check("no_%s_in_%s" % [w, key], false) or failed
	var filled: String = COPY.fill("door.guard", {"tier": COPY.monster_rank_name(2)}, "")
	failed = _check("door_guard_elite", filled.find("Elite") >= 0 and filled.find("Tough") < 0) or failed
	return failed


func _check_bucket_labels() -> bool:
	var failed := false
	failed = _check("bucket_item_1", BucketRules.tier_label(1, "item") == "Common") or failed
	failed = _check("bucket_item_2", BucketRules.tier_label(2, "items") == "Uncommon") or failed
	failed = _check("bucket_item_3", BucketRules.tier_label(3, "item") == "Rare") or failed
	failed = _check("bucket_mon_1", BucketRules.tier_label(1, "monster") == "Minion") or failed
	failed = _check("bucket_mon_2", BucketRules.tier_label(2, "monsters") == "Elite") or failed
	failed = _check("bucket_mon_3", BucketRules.tier_label(3, "monster") == "Boss") or failed
	for lab in ["Bronze", "Silver", "Gold", "Copper", "Weak", "Tough", "Deadly"]:
		failed = _check(
			"no_metal_word_%s" % lab,
			BucketRules.tier_label(1, "item") != lab
			and BucketRules.tier_label(2, "item") != lab
			and BucketRules.tier_label(3, "item") != lab
			and BucketRules.tier_label(1, "monster") != lab
			and BucketRules.tier_label(2, "monster") != lab
			and BucketRules.tier_label(3, "monster") != lab
		) or failed
	return failed


func _check_swap_body() -> bool:
	var failed := false
	KeywordDefs.reload(true)
	var body: String = KeywordDefs.def_of("swap")
	failed = _check("swap_mentions_common", body.find("Common") >= 0) or failed
	failed = _check("swap_no_weak", body.find("Weak") < 0) or failed
	failed = _check("swap_no_tough", body.find("Tough") < 0) or failed
	failed = _check("swap_no_deadly", body.find("Deadly") < 0) or failed
	var copy_body: String = COPY.text("keyword.swap_body", "")
	failed = _check("copy_swap_no_deadly", copy_body.find("Deadly") < 0) or failed
	failed = _check("copy_swap_has_rare", copy_body.find("Rare") >= 0) or failed
	var tut: String = COPY.text("tutorial.line.B47.3", "")
	failed = _check("tut_boss", tut.find("Boss") >= 0 and tut.find("Deadly") < 0) or failed
	return failed
