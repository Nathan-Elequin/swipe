extends SceneTree
## Headless: hovering an item must preview the same numbers the click produces.
## Run: godot --path . --headless --script res://tools/qa/check_intent_preview.gd

const FAIL_BOOT := 2
const FAIL_PREVIEW := 3


func _fail(code: int, msg: String) -> void:
	push_error(msg)
	print("INTENT_FAIL=", msg)
	quit(code)


func _init() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(FAIL_BOOT, "missing main.tscn")
		return
	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	if not await _check_shield(main):
		return
	if not await _check_sai(main):
		return
	if not await _check_lantern(main):
		return
	if not await _check_goblin(main):
		return
	if not await _check_leave(main):
		return
	if not await _check_done(main):
		return
	print("INTENT_PREVIEW_OK")
	quit(0)


func _seat(main: Node, monster_id: String, item_id: String, extra_items: Array = []) -> Dictionary:
	if main.has_method("_empty_wheel"):
		main.call("_empty_wheel")
	var mon: Dictionary = main.call("_make_monster", monster_id)
	var it: Dictionary = main.call("_make_item", item_id)
	var wheel: Array = main.get("wheel")
	if wheel.is_empty():
		wheel = [mon]
	else:
		wheel[0] = mon
	main.set("wheel", wheel)
	var hand: Array = [it]
	for eid in extra_items:
		hand.append(main.call("_make_item", str(eid)))
	main.set("hotbar", hand)
	main.set("_hotbar_sig", "")
	main.set("facing_index", 0)
	main.set("phase", "fighting")
	main.set("blk", 0)
	main.set("in_tutorial", false)
	main.set("items_used_this_combat", 0)
	if main.has_method("_sync_wheel_stats"):
		main.call("_sync_wheel_stats")
	return {"monster": mon, "item": it}


func _check_shield(main: Node) -> bool:
	_seat(main, "golem", "shield")
	main.set("blk", 0)
	var it: Dictionary = (main.get("hotbar") as Array)[0]
	var prev: Dictionary = main.call("_simulate_item", it)
	var pred_blk: int = int(prev.get("blk", -1))
	print("SHIELD_PREVIEW blk=", pred_blk, " hp=", prev.get("hp"), " wheel=", prev.get("wheel"))
	if pred_blk != 4:
		_fail(FAIL_PREVIEW, "shield preview blk want 4 got %s" % pred_blk)
		return false
	await main.call("_use_item", int(it.get("uid", -1)))
	await process_frame
	var got: int = int(main.get("blk"))
	print("SHIELD_AFTER blk=", got)
	if got != pred_blk:
		_fail(FAIL_PREVIEW, "shield preview %s != after %s" % [pred_blk, got])
		return false
	return true


func _check_sai(main: Node) -> bool:
	_seat(main, "wizard", "sai")
	main.set("blk", 0)
	var wheel: Array = main.get("wheel")
	var before_hp: int = int((wheel[0] as Dictionary).get("hp", 0))
	var it: Dictionary = (main.get("hotbar") as Array)[0]
	var prev: Dictionary = main.call("_simulate_item", it)
	var w: Dictionary = prev.get("wheel", {})
	var row: Dictionary = w.get(0, w.get("0", {}))
	if typeof(row) != TYPE_DICTIONARY:
		row = {}
	var pred_hp: int = before_hp + int(row.get("hp", 0))
	print("SAI_PREVIEW before=", before_hp, " delta=", row.get("hp"), " pred=", pred_hp)
	if int(row.get("hp", 0)) >= 0:
		_fail(FAIL_PREVIEW, "sai should preview an HP drop, row=%s" % row)
		return false
	await main.call("_use_item", int(it.get("uid", -1)))
	await process_frame
	wheel = main.get("wheel")
	var after_hp: int = before_hp
	if not wheel.is_empty() and typeof(wheel[0]) == TYPE_DICTIONARY:
		after_hp = int((wheel[0] as Dictionary).get("hp", 0))
	if bool(row.get("kill", false)):
		if wheel.is_empty() or str((wheel[0] as Dictionary).get("kind", "")) != "monster" or after_hp <= 0:
			after_hp = 0
			pred_hp = 0
	print("SAI_AFTER hp=", after_hp)
	if after_hp != pred_hp and not (pred_hp <= 0 and after_hp <= 0):
		_fail(FAIL_PREVIEW, "sai preview hp %s != after %s" % [pred_hp, after_hp])
		return false
	return true


func _check_lantern(main: Node) -> bool:
	_seat(main, "golem", "lantern")
	main.set("hp", 3)
	main.set("blk", 0)
	var it: Dictionary = (main.get("hotbar") as Array)[0]
	var prev: Dictionary = main.call("_simulate_item", it)
	var pred_hp: int = int(prev.get("hp", -1))
	print("LANTERN_PREVIEW hp=", pred_hp)
	if pred_hp != 5:
		_fail(FAIL_PREVIEW, "lantern preview hp want 5 got %s" % pred_hp)
		return false
	await main.call("_use_item", int(it.get("uid", -1)))
	await process_frame
	var got: int = int(main.get("hp"))
	print("LANTERN_AFTER hp=", got)
	if got != pred_hp:
		_fail(FAIL_PREVIEW, "lantern preview %s != after %s" % [pred_hp, got])
		return false
	return true


func _check_goblin(main: Node) -> bool:
	_seat(main, "goblin", "sai")
	var wheel: Array = main.get("wheel")
	var before_hp: int = int((wheel[0] as Dictionary).get("hp", 0))
	var it: Dictionary = (main.get("hotbar") as Array)[0]
	var prev: Dictionary = main.call("_simulate_item", it)
	var w: Dictionary = prev.get("wheel", {})
	var row: Dictionary = w.get(0, w.get("0", {}))
	if typeof(row) != TYPE_DICTIONARY:
		row = {}
	print("GOBLIN_PREVIEW row=", row, " before=", before_hp)
	if int(row.get("hp", 0)) != 0:
		_fail(FAIL_PREVIEW, "goblin must preview no ATK hp drop, row=%s" % row)
		return false
	await main.call("_use_item", int(it.get("uid", -1)))
	await process_frame
	wheel = main.get("wheel")
	var after_hp: int = before_hp
	if not wheel.is_empty() and typeof(wheel[0]) == TYPE_DICTIONARY:
		after_hp = int((wheel[0] as Dictionary).get("hp", 0))
	print("GOBLIN_AFTER hp=", after_hp)
	if after_hp != before_hp:
		_fail(FAIL_PREVIEW, "goblin took ATK damage %s → %s" % [before_hp, after_hp])
		return false
	return true


func _check_leave(main: Node) -> bool:
	main.set("phase", "draft")
	main.set("draft_action", "ask")
	main.set("refusals_left", 3)
	var prev: Dictionary = main.call("_simulate_leave")
	var pred: int = int(prev.get("refusals", -1))
	print("LEAVE_PREVIEW refusals=", pred)
	if pred != 2:
		_fail(FAIL_PREVIEW, "leave preview want 2 got %s" % pred)
		return false
	return true


func _check_done(main: Node) -> bool:
	_seat(main, "golem", "shield")
	main.set("hp", 6)
	main.set("blk", 0)
	var before_hp: int = int(main.get("hp"))
	var prev: Dictionary = main.call("_simulate_done")
	var pred_hp: int = int(prev.get("hp", -1))
	print("DONE_PREVIEW hp=", pred_hp, " incoming would drop from ", before_hp)
	if pred_hp < 0 or pred_hp >= before_hp:
		_fail(FAIL_PREVIEW, "Take X should preview lost hearts, hp=%s" % pred_hp)
		return false
	return true
