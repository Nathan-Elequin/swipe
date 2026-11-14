extends SceneTree
## Direction A keyword tips: defs round-trip + keep-out for 4- and 8-monster layouts.


func _init() -> void:
	var failed := false
	failed = _check_defs_roundtrip() or failed
	failed = _check_def_of_matches_json() or failed
	failed = _check_keep_out_layouts() or failed
	failed = _check_tip_api() or failed
	if failed:
		push_error("keyword_tips self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK keyword_tips")
		quit(0)


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok


func _check_defs_roundtrip() -> bool:
	var failed := false
	KeywordDefs.reload(true)
	var before: Dictionary = {}
	for id in KeywordDefs.all_ids():
		before[id] = KeywordDefs.entry(id)
	failed = _check("defs_count_23", before.size() == 23) or failed
	failed = _check("defs_save", KeywordDefs.save_all(before)) or failed
	KeywordDefs.reload(true)
	for id in KeywordDefs.all_ids():
		var a: Dictionary = before[id]
		var b: Dictionary = KeywordDefs.entry(id)
		failed = _check("roundtrip_%s_title" % id, str(a.get("title")) == str(b.get("title"))) or failed
		failed = _check("roundtrip_%s_body" % id, str(a.get("body")) == str(b.get("body"))) or failed
	return failed


func _check_def_of_matches_json() -> bool:
	var failed := false
	## Seed strings that must stay verbatim (including ATK in bear_trap/marked).
	var expect := {
		"bear_trap": "a 2 HP 3 ATK monster that Attacks you when you Move or Spin onto it",
		"marked": "upon Defeat, Trapper gains +2 HP and ATK",
		"poison": "When you Spin that monster, they lose that much HP immediately, then the mark clears. Other marked monsters keep theirs. Your Poison pays first on a Spin. Not Attack.",
		"always": "Always: cannot be changed in any other way",
		"swap": "Swap: trade it for a random item of the same rank (Weak, Tough or Deadly).",
		"loaded": "Loaded: your next Attack can hit any monster.",
		"flee": "If you are facing them, Spin the wheel at random. They are not removed.",
	}
	for id in expect.keys():
		failed = _check("def_of_%s" % id, UxStyle.def_of(id) == str(expect[id])) or failed
		failed = _check("json_%s" % id, KeywordDefs.def_of(id) == str(expect[id])) or failed
	return failed


func _check_keep_out_layouts() -> bool:
	var failed := false
	var tip: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip)
	tip.setup()
	## Spec reference rects at 1680×1040 (formulas win over mock coords).
	var layouts: Array = [
		{"name": "4mon", "c": Vector2(848, 407), "r": 364.0, "rail": 1252.0},
		{"name": "8mon", "c": Vector2(840, 469), "r": 456.0, "rail": 1336.0},
	]
	for L in layouts:
		var c: Vector2 = L["c"]
		var r: float = float(L["r"]) + 16.0
		var keep := Rect2(c.x - r, c.y - r, r * 2.0, r * 2.0)
		var card_sz := Vector2(296, 256)
		## Poison pip card on the rail (spec examples).
		var rail_x: float = float(L["rail"])
		var card := Rect2(rail_x, 352.0, card_sz.x, card_sz.y)
		failed = _check("keepout_%s_no_intersect" % L["name"], not tip.intersects_keep_out(card, keep)) or failed
		## A card centered on the wheel MUST intersect — sanity.
		var bad := Rect2(c - card_sz * 0.5, card_sz)
		failed = _check("keepout_%s_center_hits" % L["name"], tip.intersects_keep_out(bad, keep)) or failed
	tip.queue_free()
	return failed


func _check_tip_api() -> bool:
	var failed := false
	var tip: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip)
	tip.setup()
	tip.show_def(UxStyle.def_of("flee"), tip, "flee", "item")
	tip.reset_size()
	var sz: Vector2 = tip.get_combined_minimum_size()
	failed = _check("flee_card_w", sz.x + 0.01 >= 296.0) or failed
	failed = _check("flee_card_h", sz.y + 0.01 >= 96.0) or failed
	tip.pin_def(UxStyle.def_of("flee"), tip, "flee", "item")
	failed = _check("flee_pin", bool(tip.get("_pinned"))) or failed
	failed = _check("flee_seal", tip.get("_seal") != null and bool((tip.get("_seal") as CanvasItem).visible)) or failed
	tip.unpin()
	failed = _check("flee_unpin", not bool(tip.get("_pinned"))) or failed
	tip.queue_free()
	## Chip BBCode includes icon path for flee.
	var chip: String = UxStyle.chip_bbcode("Flee", "flee", "#E8C36A", false)
	failed = _check("chip_has_img", chip.find("kw_flee.png") >= 0) or failed
	failed = _check("chip_has_url", chip.find("[url=kw:flee") >= 0) or failed
	return failed
