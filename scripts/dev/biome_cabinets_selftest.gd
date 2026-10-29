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
		"cabinets/case_sunken_mire",
		"cabinets/case_ashen_crypt",
		"cabinets/case_cinder_forge",
		"cabinets/case_shadow_abyss",
	]) or failed
	failed = _check(failed, "trophy paths", trophies == [
		"cabinets/trophy_verdant_hollow",
		"cabinets/trophy_sunken_mire",
		"cabinets/trophy_ashen_crypt",
		"cabinets/trophy_cinder_forge",
		"cabinets/trophy_shadow_abyss",
	]) or failed
	for raw_case2 in Cases.resolved_cases(rules):
		var spec: Dictionary = raw_case2
		var idle: Texture2D = Cases.trophy_texture(spec, false)
		var hov: Texture2D = Cases.trophy_texture(spec, true)
		failed = _check(failed, "trophy_texture %s" % str(spec.get("id", "")), idle != null) or failed
		failed = _check(failed, "trophy_texture_hover %s" % str(spec.get("id", "")), hov != null) or failed
	failed = _check(failed, "trophy_texture missing null", Cases.trophy_texture({}, false) == null) or failed
	var bounds: Rect2 = Cases.cases_bounds_rect()
	failed = _check(failed, "cases bounds", bounds.position == Vector2(76, 56) and bounds.size == Vector2(298, 160)) or failed
	failed = _check(failed, "five glass", Cases.CASE_GLASS.size() == 5) or failed
	var g0: Rect2 = Cases.glass_rect(0)
	failed = _check(failed, "glass0 inside bounds", bounds.encloses(g0)) or failed
	## Pitch vs Doop SHIP-D: glass centers step 60 native; Doop cab pitch 244 screen (~61 native).
	var pitch_ok := true
	for gi in range(1, Cases.CASE_GLASS.size()):
		var a: Array = Cases.CASE_GLASS[gi - 1]
		var b: Array = Cases.CASE_GLASS[gi]
		if int(b[0]) - int(a[0]) != 60:
			pitch_ok = false
			break
	failed = _check(failed, "glass pitch 60", pitch_ok) or failed
	## Trophy sits in the glass top, fully inside, clear of peg floor / case base.
	var gsize: Vector2 = g0.size * 4.0
	failed = _check(failed, "glass height 121 native", g0.size.y == 121.0) or failed
	failed = _check(failed, "glass px height 484", gsize.y == 484.0) or failed
	var tslot: Rect2 = Cases.trophy_local_rect(gsize, 4.0)
	failed = _check(failed, "trophy size 96", tslot.size == Vector2(96, 96)) or failed
	failed = _check(failed, "trophy inside glass", Rect2(Vector2.ZERO, gsize).encloses(tslot)) or failed
	failed = _check(failed, "trophy top band", tslot.position.y < gsize.y * 0.35) or failed
	var reserved: float = Cases.trophy_reserved_height(gsize, 4.0)
	failed = _check(failed, "reserved clears trophy", reserved >= tslot.position.y + tslot.size.y) or failed
	failed = _check(failed, "reserved leaves peg room", reserved < gsize.y) or failed
	## Peg shields: PEG_FIT_MAX must sit fully inside the clip, above the case base,
	## with and without the trophy band reserved. msize stays integer pixels.
	var cell := Vector2(128, 160)
	for gi2 in range(Cases.CASE_GLASS.size()):
		var gi_rect: Rect2 = Cases.glass_rect(gi2)
		var gi_px: Vector2 = gi_rect.size * 4.0
		var gi_slot: Rect2 = Cases.trophy_local_rect(gi_px, 4.0)
		failed = _check(failed, "trophy inside glass %d" % gi2, Rect2(Vector2.ZERO, gi_px).encloses(gi_slot)) or failed
		var res_i: float = Cases.trophy_reserved_height(gi_px, 4.0)
		var clip_trophy := Vector2(gi_px.x, maxf(0.0, gi_px.y - res_i))
		var clip_empty := gi_px
		for pair in [
			["trophy", clip_trophy],
			["empty", clip_empty],
		]:
			var label: String = str(pair[0])
			var clip: Vector2 = pair[1]
			var lay: Dictionary = Cases.peg_column_layout(clip, cell, Cases.PEG_FIT_MAX)
			var msize: Vector2 = lay.get("msize", Vector2.ZERO)
			var gap_y: float = float(lay.get("gap_y", 0.0))
			var pad_top: float = float(lay.get("pad_top", 0.0))
			failed = _check(failed, "peg int %s %d" % [label, gi2], msize.x == floor(msize.x) and msize.y == floor(msize.y)) or failed
			var col_h: float = Cases.peg_column_height(Cases.PEG_FIT_MAX, msize.y, gap_y, pad_top)
			failed = _check(failed, "pegs fit %s %d" % [label, gi2], col_h <= clip.y + 0.01) or failed
			## Clip sits at y=reserved inside glass; peg bottoms must stay < glass bottom.
			var clip_top: float = res_i if label == "trophy" else 0.0
			var peg_bottom: float = clip_top + col_h
			failed = _check(failed, "peg above base %s %d" % [label, gi2], peg_bottom <= gi_px.y + 0.01) or failed
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
