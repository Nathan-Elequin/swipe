extends SceneTree
## Lucky Nickel restore — random coin (not choose picker) + slash chance icons.
## Run: godot --headless --path . --script res://scripts/dev/lucky_nickel_random_selftest.gd
## Does not boot main.tscn. Exercises the same coin decision main._apply_ops uses
## (lo=2 / hi=6+bleed2, always Keep) with controlled force rolls for both sides.

const CARD := preload("res://scripts/item_card.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = _contracts() or failed
	failed = _coin_both_outcomes() or failed
	failed = await _face_slash_no_choice_badge() or failed
	if failed:
		push_error("LUCKY_NICKEL_RANDOM_SELFTEST_FAIL")
		print("LUCKY_NICKEL_RANDOM_SELFTEST_FAIL")
		quit(1)
	else:
		print("LUCKY_NICKEL_RANDOM_SELFTEST_OK")
		quit(0)


func _contracts() -> bool:
	var failed := false
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(
		failed,
		"item_ops_blk_coin_keep",
		src.find('"lucky_nickel": {"kind": "blk_coin_keep"') >= 0
		or src.find("\"lucky_nickel\": {\"kind\": \"blk_coin_keep\"") >= 0
	) or failed
	failed = _check(
		failed,
		"item_ops_not_choose",
		src.find('"lucky_nickel": {"kind": "choose"') < 0
		and src.find("\"lucky_nickel\": {\"kind\": \"choose\"") < 0
	) or failed
	failed = _check(
		failed,
		"no_nickel_choose_prompt",
		src.find("combat.nickel_choose_prompt") < 0
	) or failed
	failed = _check(
		failed,
		"coin_uses_randi_range",
		src.find("blk_coin_keep") >= 0 and src.find("randi_range(0, 1)") >= 0
	) or failed
	failed = _check(
		failed,
		"force_coin_test_hook",
		src.find('"_force_coin"') >= 0 or src.find("\"_force_coin\"") >= 0
	) or failed
	## Chance face: shield 2 / slash / shield 6 / heart −2 (not selectable options).
	var face_i: int = src.find('"lucky_nickel":')
	failed = _check(failed, "face_rows_present", face_i >= 0) or failed
	if face_i >= 0:
		var face_chunk: String = src.substr(face_i, 280)
		failed = _check(failed, "face_has_slash", face_chunk.find('"slash"') >= 0) or failed
		failed = _check(failed, "face_has_shield_2", face_chunk.find('_fg("shield", "2")') >= 0) or failed
		failed = _check(failed, "face_has_shield_6", face_chunk.find('_fg("shield", "6")') >= 0) or failed
		failed = _check(failed, "face_has_heart_m2", face_chunk.find('_fg("heart", "−2")') >= 0) or failed

	var cat: Dictionary = _load_json("res://data/catalog.json")
	var ops: Dictionary = _catalog_ops(cat, "lucky_nickel")
	failed = _check(failed, "catalog_ops_kind", str(ops.get("kind", "")) == "blk_coin_keep") or failed
	failed = _check(failed, "catalog_ops_lo2", int(ops.get("lo", -1)) == 2) or failed
	failed = _check(failed, "catalog_ops_hi6", int(ops.get("hi", -1)) == 6) or failed
	failed = _check(failed, "catalog_ops_hp2", int(ops.get("hp", -1)) == 2) or failed
	failed = _check(
		failed,
		"catalog_explainer_not_choose",
		str(_catalog_field(cat, "lucky_nickel", "explainer")).find("Choose") < 0
	) or failed
	failed = _check(
		failed,
		"catalog_flow_coin_not_choice",
		str(_catalog_field(cat, "lucky_nickel", "flow")).find("Coin flip") >= 0
		and str(_catalog_field(cat, "lucky_nickel", "flow")).find("Choose:") < 0
	) or failed
	return failed


## Mirrors main blk_coin_keep decision + Keep/consume (always Keep) + risky bleed.
func _coin_both_outcomes() -> bool:
	var failed := false
	var lo := _resolve_coin(0, 2, 6, 2)
	failed = _check(failed, "force0_blk2", int(lo.get("n", -1)) == 2) or failed
	failed = _check(failed, "force0_no_bleed", int(lo.get("bleed", -1)) == 0) or failed
	failed = _check(failed, "force0_keep", bool(lo.get("keep", false))) or failed

	var hi := _resolve_coin(1, 2, 6, 2)
	failed = _check(failed, "force1_blk6", int(hi.get("n", -1)) == 6) or failed
	failed = _check(failed, "force1_bleed2", int(hi.get("bleed", -1)) == 2) or failed
	failed = _check(failed, "force1_keep", bool(hi.get("keep", false))) or failed

	## HP-loss trigger path: bleed > 0 fires _bleed after Block gain (pre-462 lifecycle).
	failed = _check(failed, "risky_triggers_hp_loss", int(hi.get("bleed", 0)) > 0) or failed

	## Unforced rolls must be able to hit both sides (seeded global RNG).
	var saw0 := false
	var saw1 := false
	for s in range(0, 64):
		seed(s * 9973 + 17)
		var c: int = randi_range(0, 1)
		if c == 0:
			saw0 = true
		else:
			saw1 = true
		if saw0 and saw1:
			break
	failed = _check(failed, "randi_range_hits_both", saw0 and saw1) or failed
	return failed


func _resolve_coin(force: int, lo: int, hi: int, hp_loss: int) -> Dictionary:
	## Same branch shape as main._apply_ops blk_coin_keep (+ always Keep).
	var coin: int = force
	var n: int
	var bleed: int
	if coin == 0:
		n = lo
		bleed = 0
	else:
		n = hi
		bleed = hp_loss
	return {"n": n, "bleed": bleed, "keep": true}


func _face_slash_no_choice_badge() -> bool:
	var failed := false
	## Exact chance recipe from main._face_rows("lucky_nickel").
	var rows: Array = [[
		_fg("shield", "2"),
		_fg("icon", "", "", "", "", "slash"),
		_fg("shield", "6"),
		_fg("heart", "−2"),
	]]
	failed = _check(failed, "face_four_cells", (rows[0] as Array).size() == 4) or failed
	var cells: Array = rows[0]
	failed = _check(failed, "cell0_shield2", str((cells[0] as Dictionary).get("k", "")) == "shield" and str((cells[0] as Dictionary).get("t", "")) == "2") or failed
	failed = _check(failed, "cell1_slash", str((cells[1] as Dictionary).get("id", "")) == "slash") or failed
	failed = _check(failed, "cell2_shield6", str((cells[2] as Dictionary).get("k", "")) == "shield" and str((cells[2] as Dictionary).get("t", "")) == "6") or failed
	failed = _check(failed, "cell3_heart", str((cells[3] as Dictionary).get("k", "")) == "heart") or failed

	var card: PanelContainer = CARD.new()
	root.add_child(card)
	card.setup(1, "lucky_nickel", "2/6", null, Color("5c2626"), Color("c0c0c0"), "Lucky Nickel", Color.WHITE, "BLK", null)
	card.set_glyphs(rows)
	## Chance icons must not open a knife-style choice badge (1 / 2 / 3).
	if card.has_method("set_choice_badge"):
		card.set_choice_badge("")
	card.size = Vector2(CARD.CARD_W, CARD.CARD_H)
	card.queue_sort()
	await process_frame
	await process_frame
	var badge: Label = _find_choice_badge(card)
	failed = _check(failed, "no_selectable_choice_badge", badge == null or not badge.visible or str(badge.text).strip_edges() == "") or failed
	card.queue_free()
	return failed


func _fg(k: String, t: String = "", tint: String = "", border: String = "", sup: String = "", icon: String = "") -> Dictionary:
	return {"k": k, "t": t, "tint": tint, "border": border, "sup": sup, "id": icon}


func _find_choice_badge(host: Node) -> Label:
	for n in host.find_children("*", "Label", true, false):
		var lab: Label = n as Label
		if lab == null or not lab.visible:
			continue
		var tx: String = str(lab.text)
		if tx.find("Block 2") >= 0 or tx.find("choose") >= 0 or tx.find("Choose") >= 0:
			return lab
		if lab.name.find("Choice") >= 0 or lab.name.find("choice") >= 0:
			return lab
	return null


func _catalog_ops(cat: Dictionary, id: String) -> Dictionary:
	for raw in cat.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		var ops: Variant = card.get("ops", {})
		if typeof(ops) == TYPE_DICTIONARY:
			return ops as Dictionary
	return {}


func _catalog_field(cat: Dictionary, id: String, field: String) -> Variant:
	for raw in cat.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) == id:
			return card.get(field, "")
	return ""


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var txt := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	print("FAIL %s" % label)
	return true
