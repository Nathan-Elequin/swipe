extends SceneTree
## Headless: every catalog item's hand-card type matches JSON card_color.

const FAIL_BOOT := 2
const FAIL_TYPE := 3

const UX := preload("res://scripts/ux_style.gd")


func _fail(code: int, msg: String) -> void:
	push_error(msg)
	print("ITEM_TYPE_FAIL=", msg)
	quit(code)


func _expected(it: Dictionary, view_kind: String) -> String:
	var tint: String = str(it.get("card_color", "")).strip_edges()
	var shown: String = UX.display_kind(tint)
	if shown != "":
		return shown
	return view_kind


func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(FAIL_BOOT, "missing main.tscn")
		return
	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	if not main.has_method("_make_item") or not main.has_method("_item_display_kind"):
		_fail(FAIL_BOOT, "missing _make_item / _item_display_kind")
		return
	var items: Dictionary = main.get("items_by_id")
	if items.is_empty():
		_fail(FAIL_BOOT, "catalog items empty")
		return
	var bad: PackedStringArray = PackedStringArray()
	var checked := 0
	for id in items.keys():
		var it: Dictionary = main.call("_make_item", str(id))
		if it.is_empty() or str(it.get("card_id", "")) == "":
			bad.append("%s factory empty" % id)
			continue
		var view: Dictionary = main.call("_item_view", it)
		var got: String = str(main.call("_item_display_kind", it))
		var exp: String = _expected(it, str(view.get("kind", "ATK")))
		checked += 1
		print("TYPE id=", id, " card_color=", it.get("card_color", ""), " display=", got, " expected=", exp)
		if got != exp:
			bad.append("%s display=%s expected=%s color=%s" % [id, got, exp, it.get("card_color", "")])
			continue
		var tint: String = UX.display_kind(str(it.get("card_color", "")))
		if tint == "UTILITY" or tint == "SMOKE" or tint == "CHAOS" or tint == "EGG":
			if got == "ATK":
				bad.append("%s utility-family tagged ATK" % id)
	var hook: Dictionary = main.call("_make_item", "grappling_hook")
	var flask: Dictionary = main.call("_make_item", "poison_flask")
	var hook_k: String = str(main.call("_item_display_kind", hook))
	var flask_k: String = str(main.call("_item_display_kind", flask))
	print("HOOK_KIND=", hook_k, " FLASK_KIND=", flask_k)
	if hook_k == "ATK":
		bad.append("grappling_hook still ATK")
	if flask_k == "ATK":
		bad.append("poison_flask still ATK")
	if not _check_shift_size(main, bad):
		pass
	if not bad.is_empty():
		_fail(FAIL_TYPE, "mismatches=%s %s" % [bad.size(), ", ".join(bad)])
		return
	print("ITEM_TYPE_OK checked=", checked)
	quit(0)


func _check_shift_size(main: Node, bad: PackedStringArray) -> bool:
	if not main.has_method("_make_monster"):
		return true
	var golem: Dictionary = main.call("_make_monster", "golem")
	var hook: Dictionary = main.call("_make_item", "grappling_hook")
	if main.has_method("_empty_wheel"):
		main.call("_empty_wheel")
	var wheel: Array = main.get("wheel")
	if wheel.is_empty():
		wheel = [golem]
	else:
		wheel[0] = golem
	main.set("wheel", wheel)
	main.set("hotbar", [hook])
	main.set("_hotbar_sig", "")
	main.set("facing_index", 0)
	main.set("phase", "fighting")
	main.call("_sync_hotbar")
	var box: Node = main.get("hotbar_box")
	if box == null or box.get_child_count() < 1:
		bad.append("no hand card for shift-size check")
		return false
	var card: Control = box.get_child(0)
	var before: Vector2 = card.get_combined_minimum_size()
	if card.has_method("set_formula") and card.has_method("show_formula"):
		card.set_formula("(3) or (1 and Keep)")
		card.show_formula(true)
	var after: Vector2 = card.get_combined_minimum_size()
	print("SHIFT_SIZE before=", before, " after=", after, " kind=", card.get("kind"))
	if after.y > before.y + 0.5:
		bad.append("shift grew card height %s -> %s" % [before.y, after.y])
		return false
	if str(card.get("kind", "")) == "ATK":
		bad.append("grappling_hook card.kind is ATK")
		return false
	return true
