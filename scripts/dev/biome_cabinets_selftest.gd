extends SceneTree
## Headless checks for the five biome cases. Does not boot main.gd.


func _init() -> void:
	var Cases = load("res://scripts/biome_cabinets.gd")
	var Shell = load("res://scripts/campaign_shell.gd")
	var rules: Dictionary = Shell.read_json("res://data/campaign.json")
	var failed := false
	var names: Array = Cases.case_names(rules)
	failed = _check(failed, "five cases", names.size() == 5) or failed
	var want := ["Verdant Hollow", "Crystal Cavern", "Ashen Crypt", "Cinder Forge", "Shadow Abyss"]
	for i in want.size():
		failed = _check(failed, "name %s" % want[i], i < names.size() and str(names[i]) == str(want[i])) or failed
	for raw_case_name in Cases.CASES:
		failed = _check(failed, "no Sunken Mire in CASES", str((raw_case_name as Dictionary).get("name", "")) != "Sunken Mire") or failed
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
	var old_board := {
		"biomes": [
			{"id": "b1", "name": "Torch Burrow"},
			{"id": "b2", "name": "Slime Pits"},
			{"id": "b3", "name": "Bone Gallery"},
			{"id": "b4", "name": "Bog Mother"},
			{"id": "b5", "name": "Gulp King"},
		],
	}
	failed = _check(failed, "board stubs become locked names", Cases.case_names(old_board) == want) or failed
	var custom := {"biomes": [{"id": "b1", "name": "Moss Hall"}]}
	failed = _check(failed, "non-stub name kept", str(Cases.case_names(custom)[0]) == "Moss Hall") or failed
	failed = _check(failed, "quota 5", Cases.quota_of(rules) == 5) or failed
	failed = _check(failed, "pool b1", Cases.pool_for_bucket(rules, 1) == "b1") or failed
	failed = _check(failed, "pool b5", Cases.pool_for_bucket(rules, 5) == "b5") or failed
	failed = _check(failed, "fallback pair", Cases.pool_for_bucket({}, 4) == "b4") or failed
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
	var trophies: Array = []
	for raw_case in Cases.resolved_cases(rules):
		var c: Dictionary = raw_case
		frames.append(str(c.get("frame", "")))
		trophies.append(str(c.get("trophy", "")))
	failed = _check(failed, "frame paths", frames == [
		"cabinets/case_verdant_hollow",
		"cabinets/case_crystal_cavern",
		"cabinets/case_ashen_crypt",
		"cabinets/case_cinder_forge",
		"cabinets/case_shadow_abyss",
	]) or failed
	failed = _check(failed, "trophy paths", trophies == [
		"cabinets/trophy_verdant_hollow",
		"cabinets/trophy_crystal_cavern",
		"cabinets/trophy_ashen_crypt",
		"cabinets/trophy_cinder_forge",
		"cabinets/trophy_shadow_abyss",
	]) or failed
	for raw_case2 in Cases.resolved_cases(rules):
		var spec: Dictionary = raw_case2
		var stem := str(spec.get("trophy", ""))
		var idle_path := "res://assets/dungeon/home/%s.png" % stem
		var hover_path := "res://assets/dungeon/home/%s_hover.png" % stem
		failed = _check(failed, "trophy file %s" % str(spec.get("id", "")), ResourceLoader.exists(idle_path)) or failed
		failed = _check(failed, "trophy hover file %s" % str(spec.get("id", "")), ResourceLoader.exists(hover_path)) or failed
		var idle: Texture2D = Cases.trophy_texture(spec, false)
		var hov: Texture2D = Cases.trophy_texture(spec, true)
		## Import may lag in headless CI; file existence is the lock. Soft-warn textures.
		if idle == null:
			push_warning("trophy_texture null (import?): %s" % str(spec.get("id", "")))
		if hov == null:
			push_warning("trophy_texture_hover null (import?): %s" % str(spec.get("id", "")))
	failed = _check(failed, "trophy_texture missing null", Cases.trophy_texture({}, false) == null) or failed
	var bounds: Rect2 = Cases.cases_bounds_rect()
	failed = _check(failed, "cases bounds full room", bounds.position == Vector2(0, 0) and bounds.size == Vector2(420, 260)) or failed
	failed = _check(failed, "five glass", Cases.CASE_GLASS.size() == 5) or failed
	var g1: Rect2 = Cases.glass_rect(1)
	failed = _check(failed, "b2 glass 138,68", g1.position == Vector2(138, 68) and g1.size == Vector2(48, 121)) or failed
	## Pitch: b0→b1 is 56 (138-82), then 60 thereafter — Crystal body is wider.
	failed = _check(failed, "glass height 121 native", Cases.glass_rect(0).size.y == 121.0) or failed
	## Legacy trophy helpers still work.
	var g0: Rect2 = Cases.glass_rect(0)
	var gsize: Vector2 = g0.size * 4.0
	var tslot: Rect2 = Cases.trophy_local_rect(gsize, 4.0)
	failed = _check(failed, "trophy size 96", tslot.size == Vector2(96, 96)) or failed
	failed = _check(failed, "trophy inside glass", Rect2(Vector2.ZERO, gsize).encloses(tslot)) or failed
	## fixed_slots: stable under shuffle + banked order; keeps every item.
	var pool_cards: Array = []
	for i in 23:
		pool_cards.append({"id": "i%02d" % i, "name": "N%d" % ((i * 7) % 13), "tier": (i % 3) + 1})
	var shuffled: Array = pool_cards.duplicate()
	shuffled.shuffle()
	var fixed_a: Array = Cases.fixed_slots(shuffled)
	var fixed_b: Array = Cases.fixed_slots(pool_cards)
	var ids_a: Array = []
	var ids_b: Array = []
	for raw_a in fixed_a:
		ids_a.append(str((raw_a as Dictionary).get("id", "")))
	for raw_b in fixed_b:
		ids_b.append(str((raw_b as Dictionary).get("id", "")))
	failed = _check(failed, "fixed_slots keeps all 23", ids_a.size() == 23) or failed
	failed = _check(failed, "fixed_slots stable", ids_a == ids_b) or failed
	failed = _check(failed, "page_count 23 -> 3", Cases.page_count(23) == 3) or failed
	failed = _check(failed, "page_count 10 -> 1", Cases.page_count(10) == 1) or failed
	failed = _check(failed, "page_count 11 -> 2", Cases.page_count(11) == 2) or failed
	failed = _check(failed, "page_count 0 -> 1", Cases.page_count(0) == 1) or failed
	failed = _check(failed, "slot 22 -> page 2", Cases.slot_page(22) == 2) or failed
	var cell22: Vector2i = Cases.slot_cell(22)
	failed = _check(failed, "slot 22 cell col2? local 2 -> col0 row1", cell22.x == 0 and cell22.y == 1) or failed
	## local for 22: 22%10=2 → col 0, row 1. Spec said "page 2 cell 2" meaning local index 2.
	failed = _check(failed, "pips_lit clamp", Cases.pips_lit(7, 5) == 5 and Cases.pips_lit(3, 5) == 3 and Cases.pips_lit(-1, 5) == 0) or failed
	failed = _check(failed, "crown_text", Cases.crown_text(3, 12) == "3/12") or failed
	## page_state FULL only when every id on page claimed
	var slot_ids: Array = ids_a
	var banked_partial := {}
	for i in 10:
		banked_partial[str(slot_ids[i])] = true
	failed = _check(failed, "page0 full when 10 claimed", Cases.page_state(slot_ids, 0, banked_partial) == Cases.PageState.PAGE_FULL) or failed
	failed = _check(failed, "page1 open", Cases.page_state(slot_ids, 1, banked_partial) == Cases.PageState.PAGE_OPEN) or failed
	## case_state truth table
	var fresh: Dictionary = Shell.fresh_state()
	var unlocked_state: Dictionary = Shell.fresh_state()
	## Unlock b1 always; give b1 four banked → in progress
	var b1_ids: Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]
	for i in 4:
		unlocked_state["banked"][b1_ids[i]] = "b1"
	var st_prog: int = Cases.case_state(rules, unlocked_state, "b1", b1_ids, {})
	failed = _check(failed, "4 -> in progress", st_prog == Cases.CaseState.IN_PROGRESS) or failed
	## any 5 → opened
	var open_state: Dictionary = Shell.fresh_state()
	for i in 5:
		open_state["banked"][b1_ids[i]] = "b1"
	var st_open: int = Cases.case_state(rules, open_state, "b1", b1_ids, {})
	failed = _check(failed, "any 5 -> opened", st_open == Cases.CaseState.OPENED) or failed
	## all → complete
	var done_state: Dictionary = Shell.fresh_state()
	var claimed_all := {}
	for id in b1_ids:
		done_state["banked"][id] = "b1"
		claimed_all[id] = true
	var st_done: int = Cases.case_state(rules, done_state, "b1", b1_ids, claimed_all)
	failed = _check(failed, "all -> complete", st_done == Cases.CaseState.COMPLETE) or failed
	## b2 locked when b1 under quota
	var st_locked: int = Cases.case_state(rules, unlocked_state, "b2", ["x", "y"], {})
	failed = _check(failed, "b2 locked while b1 under quota", st_locked == Cases.CaseState.LOCKED) or failed
	## Complete needs every page — page_state on last page open means not complete
	var almost: Dictionary = Shell.fresh_state()
	var almost_claim := {}
	for i in 22:
		almost["banked"][str(slot_ids[i])] = "b1"
		almost_claim[str(slot_ids[i])] = true
	var st_almost: int = Cases.case_state(rules, almost, "b1", slot_ids, almost_claim)
	failed = _check(failed, "missing last page item not complete", st_almost != Cases.CaseState.COMPLETE) or failed
	## Legacy peg column still green
	var cell := Vector2(128, 160)
	for gi2 in range(Cases.CASE_GLASS.size()):
		var gi_rect: Rect2 = Cases.glass_rect(gi2)
		var gi_px: Vector2 = gi_rect.size * 4.0
		var lay: Dictionary = Cases.peg_column_layout(gi_px, cell, Cases.PEG_FIT_MAX)
		var msize: Vector2 = lay.get("msize", Vector2.ZERO)
		failed = _check(failed, "peg int empty %d" % gi2, msize.x == floor(msize.x) and msize.y == floor(msize.y)) or failed
	## Hall zoom must keep the focused case inside the 1680×1040 viewport even when
	## RoomHall sits at layout x=6720 (4th room after loft/workshop/study/main).
	var hall_layout := Vector2(6720, 0)
	var verdant_outer: Rect2 = Cases.outer_rect(0)
	var verdant_px := Rect2(verdant_outer.position * 4.0, verdant_outer.size * 4.0)
	var zoom_target: Vector2 = Cases.hall_zoom_target(hall_layout, verdant_px.position + verdant_px.size * 0.5)
	failed = _check(failed, "zoom target keeps layout seat", zoom_target.x > 5000.0) or failed
	failed = _check(
		failed,
		"zoom case in viewport from layout 6720",
		Cases.hall_zoom_case_in_viewport(hall_layout, verdant_px)
	) or failed
	## Broken absolute clamp (old bug) would land near 0 and leave a black frame.
	var broken := Vector2(840, 520) - (verdant_px.position + verdant_px.size * 0.5) * 2.0
	broken.x = clampf(broken.x, -1680.0, 0.0)
	failed = _check(failed, "old absolute clamp != layout-aware target", broken != zoom_target) or failed
	## Bank-flip pool: spiked_flail is Crystal Cavern (b2) page index 1 (2nd page).
	var catalog: Dictionary = Shell.read_json("res://data/catalog.json")
	var cat_items: Array = catalog.get("items", [])
	var b2_cards: Array = []
	var flail_pool := ""
	for raw_it in cat_items:
		if typeof(raw_it) != TYPE_DICTIONARY:
			continue
		var it: Dictionary = raw_it
		var st := str(it.get("status", "live"))
		if st in ["retired", "hold"]:
			continue
		var bucket := int(it.get("pool", it.get("bucket", 0)))
		if str(it.get("id", "")) == "spiked_flail":
			flail_pool = Cases.pool_for_bucket(rules, bucket)
		if bucket == 2:
			b2_cards.append(it)
	var b2_slots: Array = Cases.fixed_slots(b2_cards)
	var flail_idx := -1
	for i in b2_slots.size():
		if str((b2_slots[i] as Dictionary).get("id", "")) == "spiked_flail":
			flail_idx = i
			break
	failed = _check(failed, "spiked_flail pool b2", flail_pool == "b2") or failed
	failed = _check(failed, "spiked_flail in Crystal slots", flail_idx >= 0) or failed
	failed = _check(failed, "spiked_flail page index 1", flail_idx >= 0 and Cases.slot_page(flail_idx) == 1) or failed
	var flail_seq: Array = Cases.bank_sequence(["spiked_flail"], {"spiked_flail": "b2"})
	failed = _check(
		failed,
		"bank_sequence targets b2 for flail",
		flail_seq.size() == 1 and str((flail_seq[0] as Dictionary).get("pool", "")) == "b2"
	) or failed
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
