extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("missing main.tscn")
		quit(1)
		return
	var main: Node = packed.instantiate()
	root.add_child(main)
	# one idle frame so _ready finishes
	await process_frame
	var QaProbe = load("res://tools/qa/qa_probe.gd")
	var dump: Dictionary = QaProbe.dump(main)
	print("BOOT_PHASE=", dump.get("phase"))
	print("BOOT_HP=", dump.get("hp"))
	print("BOOT_BLK=", dump.get("blk"))
	print("BOOT_TUTORIAL=", dump.get("in_tutorial"))
	print("BOOT_ADVENTURE=", dump.get("adventure"))
	print("BOOT_REFUSALS=", dump.get("refusals_left"))
	print("BOOT_WHEEL=", (dump.get("wheel") as Array).size())
	print("BOOT_HOTBAR=", (dump.get("hotbar") as Array).size())
	print("ITEM_OPS=", (main.get("ITEM_OPS") as Dictionary).size())
	print("MONSTER_SPECIAL=", (main.get("MONSTER_SPECIAL") as Dictionary).size())
	print("CATALOG_ITEMS=", (main.get("items_by_id") as Dictionary).size())
	print("CATALOG_MONSTERS=", (main.get("monsters_by_id") as Dictionary).size())
	print("HP_MAX=", main.get("HP_MAX"))
	var shield: Dictionary = main.call("_make_item", "shield")
	var goblin: Dictionary = main.call("_make_monster", "goblin")
	var ops: Dictionary = main.call("_ops_of", shield)
	var view: Dictionary = main.call("_item_view", shield)
	print("SHIELD_OPS=", ops)
	print("SHIELD_VIEW_KIND=", view.get("kind"), " N=", view.get("n"))
	print("GOBLIN_SPECIAL=", goblin.get("special_id"), " ATK=", goblin.get("atk"), " HP=", goblin.get("hp"))
	if str(ops.get("kind")) != "blk" or int(ops.get("n", 0)) != 4:
		push_error("shield ops mismatch")
		quit(4)
		return
	if str(goblin.get("special_id")) != "no_atk_dmg":
		push_error("goblin special mismatch")
		quit(5)
		return
	if str(dump.get("phase")) != "title":
		push_error("expected title phase")
		quit(2)
		return
	if int(dump.get("hp")) != 6:
		push_error("expected hp 6")
		quit(3)
		return
	print("BOOT_OK")
	quit(0)
