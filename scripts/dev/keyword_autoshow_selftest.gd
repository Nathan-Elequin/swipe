extends SceneTree
## Keyword autoshow stack: plate opens all defs, text fits, keep-out, real mouse input.
## Run: godot --headless --path . --script res://scripts/dev/keyword_autoshow_selftest.gd


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = _check_collect_kw_ids() or failed
	failed = _check_registry_three() or failed
	failed = await _check_plate_stack_and_input() or failed
	failed = await _check_catalog_inspect_stacks() or failed
	failed = await _check_log_line_stack() or failed
	failed = _check_text_fits_long_def() or failed
	if failed:
		push_error("keyword_autoshow self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK keyword_autoshow")
		quit(0)


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok


func _check_collect_kw_ids() -> bool:
	var failed := false
	var sample := "Deal 3. [url=kw:defeated underline=never]Defeat[/url] then [url=kw:spin underline=never]Spin[/url] and [url=kw:defeated underline=never]Defeat[/url] again."
	var ids: Array = UxStyle.collect_kw_ids(sample)
	failed = _check("collect_order", ids.size() == 2 and str(ids[0]) == "defeated" and str(ids[1]) == "spin") or failed
	failed = _check("collect_empty", UxStyle.collect_kw_ids("plain text").is_empty()) or failed
	return failed


func _check_registry_three() -> bool:
	var failed := false
	KeywordDefs.reload(true)
	failed = _check("ids_has_neighbor", KeywordDefs.ids().has("neighbor")) or failed
	failed = _check("ids_has_keep", KeywordDefs.ids().has("keep")) or failed
	failed = _check("ids_has_attack", KeywordDefs.ids().has("attack")) or failed
	failed = _check(
		"def_neighbor",
		KeywordDefs.def_of("neighbor")
		== "The spaces right beside another on the wheel: one to its left, one to its right."
	) or failed
	failed = _check(
		"def_keep",
		KeywordDefs.def_of("keep") == "This item stays in your hand after you use it."
	) or failed
	failed = _check(
		"def_attack",
		KeywordDefs.def_of("attack")
		== "Damage from a strike. HP lost any other way doesn't count as Attack."
	) or failed
	failed = _check("def_id_neighbor", UxStyle.def_id_of("Neighbor") == "neighbor") or failed
	failed = _check("def_id_neighbors", UxStyle.def_id_of("Neighbors") == "neighbor") or failed
	failed = _check("def_id_keep", UxStyle.def_id_of("Keep") == "keep") or failed
	failed = _check("def_id_attack", UxStyle.def_id_of("Attack") == "attack") or failed
	## Abbreviation must not become a chip label that shows ATK.
	failed = _check("def_id_atk_blank", UxStyle.def_id_of("Atk") == "" and UxStyle.def_id_of("atk") == "") or failed
	var painted_n: String = UxStyle.paint("Mark a Neighbor with 4 Poison.")
	var painted_k: String = UxStyle.paint("Atk 3, or Atk 1 and Keep this item")
	var painted_a: String = UxStyle.paint("I Attack you for 2 Damage each time I take Attack Damage.")
	var n_ids: Array = UxStyle.collect_kw_ids(painted_n)
	var k_ids: Array = UxStyle.collect_kw_ids(painted_k)
	var a_ids: Array = UxStyle.collect_kw_ids(painted_a)
	failed = _check("paint_poison_flask_neighbor", n_ids.has("neighbor")) or failed
	failed = _check("paint_poison_flask_poison", n_ids.has("poison")) or failed
	failed = _check("paint_knife_keep", k_ids.has("keep")) or failed
	failed = _check("paint_needleback_attack", a_ids.has("attack")) or failed
	return failed


func _catalog_ability(card_id: String) -> String:
	var f := FileAccess.open("res://data/catalog.json", FileAccess.READ)
	if f == null:
		return ""
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return ""
	var root: Dictionary = parsed
	for bucket in ["items", "monsters"]:
		var cards: Variant = root.get(bucket, [])
		if typeof(cards) != TYPE_ARRAY:
			continue
		for row in cards:
			if typeof(row) != TYPE_DICTIONARY:
				continue
			if str((row as Dictionary).get("id", "")) == card_id:
				return str((row as Dictionary).get("ability", ""))
	return ""


func _check_catalog_inspect_stacks() -> bool:
	## Poison Flask → neighbor+poison; Throwing Knife → keep+attack; Needleback → attack.
	var failed := false
	var stray: Node = root.get_node_or_null("Main")
	if stray != null:
		stray.free()
	var main: Node = _make_main_stub()
	failed = _check("catalog_main_stub", main != null) or failed
	if main == null:
		return failed
	var plate_scr: GDScript = load("res://scripts/hover_panel.gd") as GDScript
	var plate: PanelContainer = plate_scr.new()
	plate.set("accept_clicks", false)
	root.add_child(plate)
	await process_frame
	plate.position = Vector2(1280, 520)
	plate.size = Vector2(280, 200)
	## Poison Flask ability paints Neighbor + Poison chips.
	var flask_ab: String = _catalog_ability("poison_flask")
	failed = _check("catalog_poison_flask", flask_ab != "") or failed
	var flask_body: String = UxStyle.paint(flask_ab if flask_ab != "" else "Mark a Neighbor with 4 Poison.")
	plate.show_rule("Poison Flask", "", "", flask_body, "", null, "item", "poison_flask", {})
	await process_frame
	await process_frame
	var stack: Control = plate.get("_kw_stack")
	var flask_ids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("flask_stack_neighbor", flask_ids.has("neighbor")) or failed
	failed = _check("flask_stack_poison", flask_ids.has("poison")) or failed
	## Throwing Knife: Keep from ability + Attack from value line (production _value_bb).
	var knife_ab: String = _catalog_ability("throwing_knife")
	failed = _check("catalog_throwing_knife", knife_ab != "") or failed
	var knife_body: String = UxStyle.paint(knife_ab if knife_ab != "" else "Atk 3, or Atk 1 and Keep this item")
	var knife_value: String = UxStyle.chip_bbcode("Attack", "attack", "#E07A7A", false) + " 3"
	plate.show_rule("Throwing Knife", knife_value, "", knife_body, "", null, "item", "throwing_knife", {})
	await process_frame
	await process_frame
	var knife_ids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("knife_stack_keep", knife_ids.has("keep")) or failed
	failed = _check("knife_stack_attack", knife_ids.has("attack")) or failed
	## Needleback speech/ability.
	var needle_ab: String = _catalog_ability("needleback")
	failed = _check("catalog_needleback", needle_ab != "") or failed
	var needle_body: String = UxStyle.paint(
		needle_ab if needle_ab != "" else "I Attack you for 2 Damage each time I take Attack Damage."
	)
	plate.show_rule(
		"Needleback",
		"",
		"",
		needle_body,
		"",
		null,
		"monster",
		"needleback",
		{"hp_n": "3", "atk_n": "1"}
	)
	await process_frame
	await process_frame
	var needle_ids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("needleback_stack_attack", needle_ids.has("attack")) or failed
	if stack != null and stack.has_method("hide_stack"):
		stack.hide_stack()
	plate.queue_free()
	await process_frame
	if is_instance_valid(main):
		main.free()
	return failed


func _make_main_stub() -> Node:
	var main_scr := GDScript.new()
	main_scr.source_code = "extends Node\nvar wheel: Array = []\nvar wheel_view: Node\nvar home_cabin: Node\n"
	var err: Error = main_scr.reload()
	if err != OK:
		return null
	var main: Node = main_scr.new()
	main.name = "Main"
	root.add_child(main)
	var wv_scr := GDScript.new()
	wv_scr.source_code = """extends Control
func _center() -> Vector2:
	return size * 0.5
func _radius() -> float:
	return minf(size.x, size.y) * 0.5
"""
	wv_scr.reload()
	var wv: Control = wv_scr.new()
	wv.name = "WheelView"
	wv.position = Vector2(480, 40)
	wv.size = Vector2(736, 736)
	main.add_child(wv)
	main.set("wheel_view", wv)
	## Fake cabin so first-sighting seen_keywords works.
	var cabin_scr := GDScript.new()
	cabin_scr.source_code = """extends Node
var seen_keywords: Array = []
func has_seen_keyword(id: String) -> bool:
	return seen_keywords.has(id.strip_edges().to_lower())
func mark_keyword_seen(id: String) -> void:
	var kid := id.strip_edges().to_lower()
	if kid != \"\" and not seen_keywords.has(kid):
		seen_keywords.append(kid)
"""
	if cabin_scr.reload() != OK:
		return main
	var cabin: Node = cabin_scr.new()
	cabin.name = "HomeCabin"
	main.add_child(cabin)
	main.set("home_cabin", cabin)
	return main


func _check_plate_stack_and_input() -> bool:
	var failed := false
	var stray: Node = root.get_node_or_null("Main")
	if stray != null:
		stray.free()
	var main: Node = _make_main_stub()
	failed = _check("main_stub", main != null) or failed
	if main == null:
		return failed
	var tip_probe: PanelContainer = (load("res://scripts/keyword_tip.gd") as GDScript).new()
	root.add_child(tip_probe)
	tip_probe.setup()
	## Hover plate with 3+ keywords (Defeat, Spin, Always).
	var plate_scr: GDScript = load("res://scripts/hover_panel.gd") as GDScript
	var plate: PanelContainer = plate_scr.new()
	plate.set("accept_clicks", false)
	root.add_child(plate)
	await process_frame
	var body := "%s then %s. %s." % [
		UxStyle.chip_bbcode("Defeat", "defeated", "#C9A0FF", false),
		UxStyle.chip_bbcode("Spin", "spin", "#E8C36A", false),
		UxStyle.chip_bbcode("Always", "always", "#E8C36A", false),
	]
	## Sit clearly to the right of the wheel keep-out so a single-col stack can dock beside it.
	plate.position = Vector2(1280, 640)
	plate.size = Vector2(280, 180)
	plate.show_rule("Boot", "", "", body, "", null, "item", "boot", {})
	await process_frame
	await process_frame
	var stack: Control = plate.get("_kw_stack")
	failed = _check("stack_exists", stack != null) or failed
	failed = _check("stack_showing", stack != null and bool(stack.call("is_showing"))) or failed
	var ids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("stack_has_3", ids.size() >= 3) or failed
	failed = _check("stack_has_defeated", ids.has("defeated")) or failed
	failed = _check("stack_has_spin", ids.has("spin")) or failed
	failed = _check("stack_has_always", ids.has("always")) or failed
	failed = _check("no_text_overflow", stack != null and not bool(stack.call("text_overflows"))) or failed
	var union: Rect2 = stack.call("stack_rect") if stack != null else Rect2()
	failed = _check("stack_inside_viewport", union.size.x > 0.0 and union.position.x >= 0.0 and union.end.x <= 1680.0 + 1.0 and union.position.y >= 0.0 and union.end.y <= 1040.0 + 1.0) or failed
	var keep: Rect2 = tip_probe.keep_out_rect()
	## With stub wheel lacking _center/_radius, keep may be the Control rect — still assert no overlap when keep is valid.
	if keep.size.x > 8.0:
		failed = _check("no_wheel_overlap", not union.intersects(keep)) or failed
	else:
		failed = _check("no_wheel_overlap_skip_empty_keep", true) or failed
	## Real input: mouse motion over the plate — stack stays up.
	var motion := InputEventMouseMotion.new()
	motion.position = plate.get_global_rect().get_center()
	motion.global_position = motion.position
	Input.parse_input_event(motion)
	await process_frame
	failed = _check("stack_after_mouse_motion", stack != null and bool(stack.call("is_showing"))) or failed
	## Hide plate removes stack same frame.
	plate.hide_plate()
	await process_frame
	failed = _check("stack_hidden_with_plate", stack != null and not bool(stack.call("is_showing"))) or failed
	## Monster plate path.
	plate.show_rule(
		"Harpy",
		"",
		"",
		"%s from this seat." % UxStyle.chip_bbcode("Flee", "flee", "#E8C36A", false),
		"",
		null,
		"monster",
		"harpy",
		{"hp_n": "3", "atk_n": "2"}
	)
	await process_frame
	await process_frame
	var mids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("monster_stack_flee", mids.has("flee")) or failed
	var mm := InputEventMouseMotion.new()
	mm.position = plate.get_global_rect().get_center()
	mm.global_position = mm.position
	Input.parse_input_event(mm)
	await process_frame
	failed = _check("monster_stack_after_motion", stack != null and bool(stack.call("is_showing"))) or failed
	if stack != null and stack.has_method("hide_stack"):
		stack.hide_stack()
	plate.queue_free()
	tip_probe.queue_free()
	await process_frame
	if is_instance_valid(main):
		main.free()
	return failed


func _check_log_line_stack() -> bool:
	var failed := false
	var stray: Node = root.get_node_or_null("Main")
	if stray != null:
		stray.free()
	var main: Node = _make_main_stub()
	var log_scr: GDScript = load("res://scripts/combat_log.gd") as GDScript
	var log: ScrollContainer = log_scr.new()
	root.add_child(log)
	log.setup()
	log.position = Vector2(24, 24)
	log.size = Vector2(360, 400)
	log.push_line("on_spin", "You %s the wheel." % UxStyle.chip_bbcode("Spin", "spin", "#E8C36A", false))
	await process_frame
	await process_frame
	## Find the body label and simulate row hover.
	var stack: Control = log.get("_kw_stack")
	var body: RichTextLabel = null
	var stack_nodes: Array = [log]
	while not stack_nodes.is_empty() and body == null:
		var n: Node = stack_nodes.pop_back()
		if n is RichTextLabel and str((n as RichTextLabel).text).find("kw:spin") >= 0:
			body = n as RichTextLabel
			break
		for c in n.get_children():
			stack_nodes.append(c)
	failed = _check("log_body_found", body != null) or failed
	if body != null and log.has_method("_on_row_kw"):
		log.call("_on_row_kw", body)
	await process_frame
	failed = _check("log_stack_showing", stack != null and bool(stack.call("is_showing"))) or failed
	var ids: Array = stack.call("current_ids") if stack != null else []
	failed = _check("log_stack_spin", ids.has("spin")) or failed
	log.clear_all()
	await process_frame
	failed = _check("log_stack_hidden", stack != null and not bool(stack.call("is_showing"))) or failed
	if stack != null and stack.has_method("hide_stack"):
		stack.hide_stack()
	log.queue_free()
	await process_frame
	if is_instance_valid(main):
		main.free()
	return failed


func _check_text_fits_long_def() -> bool:
	var failed := false
	var stray: Node = root.get_node_or_null("Main")
	if stray != null:
		stray.free()
	var stack: Control = (load("res://scripts/keyword_stack.gd") as GDScript).new()
	root.add_child(stack)
	stack.setup()
	var anchor := Control.new()
	anchor.position = Vector2(1200, 200)
	anchor.size = Vector2(260, 160)
	root.add_child(anchor)
	## Poison is the longest def in keyword-defs.json.
	stack.show_ids(["poison", "defeated", "spin", "always"], anchor, "item")
	## Force a layout pass.
	for _i in 3:
		stack.call("_place")
	failed = _check("long_stack_showing", bool(stack.call("is_showing"))) or failed
	failed = _check("long_stack_4", int(stack.call("card_count")) == 4) or failed
	failed = _check("long_no_overflow", not bool(stack.call("text_overflows"))) or failed
	var union: Rect2 = stack.call("stack_rect")
	print("NOTE long_stack_rect=%s" % union)
	failed = _check(
		"long_inside_vp",
		union.size.x > 0.0
		and union.position.x >= -1.0
		and union.position.y >= -1.0
		and union.end.x <= 1680.0 + 2.0
		and union.end.y <= 1040.0 + 2.0
	) or failed
	stack.hide_stack()
	stack.queue_free()
	anchor.queue_free()
	return failed
