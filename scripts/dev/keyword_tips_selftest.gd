extends SceneTree
## Direction A keyword tips: defs, textures, editor, wheel node, pin, teach pulses.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = _check_defs_roundtrip() or failed
	failed = _check_def_of_matches_json() or failed
	failed = _check_keep_out_layouts() or failed
	failed = _check_tip_api() or failed
	failed = _check_keyword_textures_load() or failed
	failed = await _check_defs_editor_compiles() or failed
	failed = _check_wheel_returns_node() or failed
	failed = _check_pin_ignores_other_show_def() or failed
	failed = await _check_teach_three_pulses_then_alpha() or failed
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


func _check_keyword_textures_load() -> bool:
	var failed := false
	var dir := DirAccess.open("res://assets/ui/keyword")
	failed = _check("keyword_dir", dir != null) or failed
	if dir == null:
		return failed
	var paths: PackedStringArray = PackedStringArray()
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".png"):
			paths.append("res://assets/ui/keyword/%s" % name)
		name = dir.get_next()
	dir.list_dir_end()
	failed = _check("keyword_png_count", paths.size() >= 48) or failed
	var load_fails: int = 0
	for p in paths:
		var tex: Texture2D = load(p) as Texture2D
		if tex == null:
			load_fails += 1
			push_error("keyword texture failed: %s" % p)
	failed = _check("keyword_textures_load", load_fails == 0) or failed
	## Shared chrome used by the card / teach.
	for extra in ["res://assets/ui/keyword/kw_card_seal.png", "res://assets/ui/keyword/kw_pip_ring.png", "res://assets/ui/keyword/kw_chip_halo_9.png"]:
		failed = _check("load_%s" % extra.get_file(), (load(extra) as Texture2D) != null) or failed
	return failed


func _check_defs_editor_compiles() -> bool:
	var failed := false
	var scr: GDScript = load("res://scripts/keyword_defs_editor.gd") as GDScript
	failed = _check("editor_script_loads", scr != null) or failed
	if scr == null:
		return failed
	var ed: Node = scr.new()
	failed = _check("editor_instantiates", ed != null) or failed
	if ed == null:
		return failed
	root.add_child(ed)
	## Force build path (show_editor → KeywordDefs preload must resolve).
	if ed.has_method("show_editor"):
		ed.call("show_editor")
	await process_frame
	failed = _check("editor_visible", bool(ed.visible)) or failed
	var list: ItemList = ed.get("_list") as ItemList
	failed = _check("editor_list", list != null and list.item_count == 23) or failed
	if ed.has_method("hide_editor"):
		ed.call("hide_editor")
	ed.queue_free()
	return failed


func _check_wheel_returns_node() -> bool:
	var failed := false
	## Fake Main: wheel is an Array (the bug), wheel_view is the Control.
	var main_scr := GDScript.new()
	main_scr.source_code = "extends Node\nvar wheel: Array = []\nvar wheel_view: Node\n"
	var err: Error = main_scr.reload()
	failed = _check("main_stub_reload", err == OK) or failed
	var main: Node = main_scr.new()
	main.name = "Main"
	root.add_child(main)
	main.set("wheel", [{"kind": "monster"}])
	var wv := Control.new()
	wv.name = "WheelView"
	main.add_child(wv)
	main.set("wheel_view", wv)
	var tip: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip)
	tip.setup()
	var got: Variant = tip.call("_wheel")
	failed = _check("wheel_is_node", got is Node) or failed
	failed = _check("wheel_is_not_array", not (got is Array)) or failed
	failed = _check("wheel_is_wheel_view", got == wv) or failed
	## free() not queue_free(): a leftover Main would parent TeachHalo then wipe it.
	tip.free()
	main.free()
	return failed


func _check_pin_ignores_other_show_def() -> bool:
	var failed := false
	var tip: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip)
	tip.setup()
	tip.pin_def(UxStyle.def_of("flee"), tip, "flee", "item")
	failed = _check("pin_kind_flee", str(tip.get("_kind")) == "flee") or failed
	tip.show_def(UxStyle.def_of("spin"), tip, "spin", "item")
	failed = _check("pin_ignores_show_def_spin", str(tip.get("_kind")) == "flee") or failed
	tip.show_def_at(Rect2(10, 10, 40, 40), UxStyle.def_of("poison"), "poison", "pip")
	failed = _check("pin_ignores_show_def_at_poison", str(tip.get("_kind")) == "flee") or failed
	failed = _check("still_pinned", bool(tip.get("_pinned"))) or failed
	tip.unpin()
	tip.queue_free()
	return failed


func _effective_modulate_a(node: CanvasItem) -> float:
	## Inherited alpha = product of modulate.a * self_modulate.a up the CanvasItem chain.
	var a: float = node.modulate.a * node.self_modulate.a
	var p: Node = node.get_parent()
	while p != null:
		if p is CanvasItem:
			var c: CanvasItem = p as CanvasItem
			a *= c.modulate.a * c.self_modulate.a
		p = p.get_parent()
	return a


func _check_teach_three_pulses_then_alpha() -> bool:
	var failed := false
	## Drop any stub Main left by earlier cases so TeachHalo is not parented onto it.
	var stray_main: Node = root.get_node_or_null("Main")
	if stray_main != null:
		stray_main.free()
	var tip: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip)
	tip.setup()
	## Chip stand-in so the halo docks on a real rect (not under the card).
	var chip := Control.new()
	chip.name = "FakeChip"
	chip.position = Vector2(120, 180)
	chip.size = Vector2(48, 24)
	root.add_child(chip)
	tip.set("_anchor", chip)
	tip.set("_source", "item")
	failed = _check("teach_pulses_const", int(tip.get("TEACH_PULSES")) == 3) or failed
	## Anchor must be set before preview so the first pulse docks on the chip.
	tip.preview_first_sighting("spin")
	failed = _check("teach_starts_alpha0", float(tip.modulate.a) < 0.05) or failed
	## During the pulse phase: card stays a≈0 while halo inherited alpha > 0.5.
	var saw_halo_bright := false
	var card_a0_while_bright := false
	var pulse_deadline_ms: int = Time.get_ticks_msec() + 1400
	while Time.get_ticks_msec() < pulse_deadline_ms:
		var halo_mid: CanvasItem = _alive_canvas(tip.get("_teach_halo"))
		if halo_mid == null:
			halo_mid = _alive_canvas(tip.get_node_or_null("TeachHalo"))
		if halo_mid == null:
			var host: Node = root.get_node_or_null("KeywordTeachHaloHost")
			if host != null:
				halo_mid = _alive_canvas(host.get_node_or_null("TeachHalo"))
		if halo_mid != null and is_instance_valid(tip) and _effective_modulate_a(halo_mid) > 0.5:
			saw_halo_bright = true
			card_a0_while_bright = float(tip.modulate.a) < 0.05
			break
		await process_frame
	failed = _check("teach_halo_effective_a_gt_05_while_card_a0", saw_halo_bright and card_a0_while_bright) or failed
	var halo: Node = _alive_node(tip.get("_teach_halo"))
	if halo == null:
		halo = tip.get_node_or_null("TeachHalo")
	if halo == null:
		var host2: Node = root.get_node_or_null("KeywordTeachHaloHost")
		if host2 != null:
			halo = host2.get_node_or_null("TeachHalo")
	failed = _check("teach_halo_created", halo != null and is_instance_valid(halo)) or failed
	failed = _check("teach_halo_not_under_card", halo != null and is_instance_valid(halo) and not tip.is_ancestor_of(halo)) or failed
	## Finish the remaining pulses + open fade (~0.18) + buffer.
	var deadline_ms: int = Time.get_ticks_msec() + 2200
	while Time.get_ticks_msec() < deadline_ms and is_instance_valid(tip) and float(tip.modulate.a) < 0.99:
		await process_frame
	failed = _check("teach_reaches_alpha1", is_instance_valid(tip) and float(tip.modulate.a) >= 0.99) or failed
	var star: CanvasItem = _alive_canvas(tip.get("_star")) if is_instance_valid(tip) else null
	failed = _check("teach_star_visible", star != null and star.visible) or failed
	if is_instance_valid(tip):
		tip.queue_free()
	if is_instance_valid(chip):
		chip.queue_free()
	return failed


func _alive_node(v: Variant) -> Node:
	if v == null:
		return null
	if typeof(v) != TYPE_OBJECT:
		return null
	if not is_instance_valid(v):
		return null
	if v is Node:
		return v
	return null


func _alive_canvas(v: Variant) -> CanvasItem:
	var n: Node = _alive_node(v)
	if n != null and n is CanvasItem:
		return n
	return null
