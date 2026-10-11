extends SceneTree
## Headless: after a spin, a hand card must take clicks and actually use.
## Catches the spinning mouse_filter leak and a game_state _use_item stub no-op.

const FAIL_BOOT := 2
const FAIL_FILTER := 3
const FAIL_USE := 4
const FAIL_CLICKS := 5


func _fail(code: int, msg: String) -> void:
	push_error(msg)
	print("HAND_USE_FAIL=", msg)
	quit(code)


func _init() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(FAIL_BOOT, "missing main.tscn")
		return
	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	if str(main.get("phase")) != "title":
		_fail(FAIL_BOOT, "expected title after boot, got %s" % main.get("phase"))
		return
	if not _seat_fight(main):
		return
	if not await _check_filter_restore(main):
		return
	if not await _check_item_use(main):
		return
	if not _check_other_clicks(main):
		return
	print("HAND_USE_OK")
	quit(0)


func _seat_fight(main: Node) -> bool:
	if not main.has_method("_make_monster") or not main.has_method("_make_item"):
		_fail(FAIL_BOOT, "missing card factories")
		return false
	var golem: Dictionary = main.call("_make_monster", "golem")
	var shield: Dictionary = main.call("_make_item", "shield")
	if str(golem.get("card_id", "")) != "golem" or str(shield.get("card_id", "")) != "shield":
		_fail(FAIL_BOOT, "factory returned empty (game_state stub?) golem=%s shield=%s" % [golem, shield])
		return false
	if main.has_method("_empty_wheel"):
		main.call("_empty_wheel")
	var wheel: Array = main.get("wheel")
	if wheel.is_empty():
		wheel = [golem]
	else:
		wheel[0] = golem
	main.set("wheel", wheel)
	main.set("hotbar", [shield])
	main.set("_hotbar_sig", "")
	main.set("facing_index", 0)
	main.set("blk", 0)
	main.set("in_tutorial", false)
	print("SEATED golem ATK=", golem.get("atk"), " HP=", golem.get("hp"), " shield uid=", shield.get("uid"))
	return true


func _hand_cards(main: Node) -> Array:
	var box: Node = main.get("hotbar_box")
	if box == null:
		return []
	var out: Array = []
	for c in box.get_children():
		if c.has_method("set_live") and c.get("uid") != null:
			out.append(c)
	return out


func _check_filter_restore(main: Node) -> bool:
	main.set("phase", "spinning")
	main.call("_refresh")
	await process_frame
	var spinning: Array = _hand_cards(main)
	if spinning.is_empty():
		_fail(FAIL_FILTER, "no hand cards after spinning refresh")
		return false
	for card in spinning:
		var mf: int = int(card.mouse_filter)
		print("SPIN_FILTER uid=", card.get("uid"), " mouse_filter=", mf)
		if mf != Control.MOUSE_FILTER_IGNORE:
			_fail(FAIL_FILTER, "spinning card should IGNORE clicks, got %s" % mf)
			return false
	main.set("phase", "fighting")
	main.set("facing_index", 0)
	main.call("_refresh")
	await process_frame
	var fighting: Array = _hand_cards(main)
	if fighting.is_empty():
		_fail(FAIL_FILTER, "no hand cards after fighting refresh")
		return false
	for card in fighting:
		var mf2: int = int(card.mouse_filter)
		print("FIGHT_FILTER uid=", card.get("uid"), " mouse_filter=", mf2)
		if mf2 != Control.MOUSE_FILTER_STOP:
			_fail(FAIL_FILTER, "after spin, hand card mouse_filter stayed %s (expected STOP)" % mf2)
			return false
		if int(card.get_signal_connection_list("picked").size()) < 1:
			_fail(FAIL_FILTER, "hand card has no picked connection")
			return false
	print("FILTER_OK spinning=IGNORE fighting=STOP connections=", fighting[0].get_signal_connection_list("picked").size())
	return true


func _check_item_use(main: Node) -> bool:
	var before_blk: int = int(main.get("blk"))
	var cards: Array = _hand_cards(main)
	if cards.is_empty():
		_fail(FAIL_USE, "no hand card to pick")
		return false
	var card: Node = cards[0]
	print("EMIT_PICKED uid=", card.get("uid"), " phase=", main.get("phase"), " blk=", before_blk)
	card.picked.emit()
	for _i in 12:
		await process_frame
	var after_blk: int = int(main.get("blk"))
	print("AFTER_PICKED blk=", after_blk, " phase=", main.get("phase"))
	if after_blk <= before_blk:
		_fail(FAIL_USE, "picked did not raise Block (before %s after %s). _use_item is a no-op or the stub won." % [before_blk, after_blk])
		return false
	print("USE_OK blk ", before_blk, " -> ", after_blk)
	return true


func _check_other_clicks(main: Node) -> bool:
	var overlay: CanvasItem = main.get("overlay")
	if overlay != null and overlay.visible:
		_fail(FAIL_CLICKS, "rest overlay is visible during fight and would eat clicks")
		return false
	var spin: Control = main.get("btn_spin")
	if spin == null or spin.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_CLICKS, "Spin button missing or IGNORE")
		return false
	print("SPIN_BTN filter=", spin.mouse_filter, " visible=", spin.visible)

	var wheel: Control = main.get("wheel_view")
	if wheel == null or wheel.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_CLICKS, "wheel missing or IGNORE (placement / inspect seats)")
		return false
	print("WHEEL filter=", wheel.mouse_filter)

	var inspect: Control = main.get("inspect")
	if inspect == null:
		_fail(FAIL_CLICKS, "inspect plate missing")
		return false
	if inspect.has_method("hide_plate"):
		inspect.hide_plate()
	if inspect.mouse_filter == Control.MOUSE_FILTER_STOP and inspect.visible:
		_fail(FAIL_CLICKS, "inspect is STOP+visible while hidden and would cover the hand")
		return false
	print("INSPECT filter=", inspect.mouse_filter, " visible=", inspect.visible)

	var settings: Control = main.get("settings_ui")
	if settings == null or not settings.has_method("open_menu"):
		_fail(FAIL_CLICKS, "pause menu missing open_menu")
		return false
	if settings.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_CLICKS, "pause menu IGNORE")
		return false
	var resume: Button = _find_button(settings, "Resume")
	if resume == null:
		resume = _find_button(settings, "Back")
	print("PAUSE filter=", settings.mouse_filter, " resume=", resume != null)

	var gate: Control = main.get("draft_gate")
	if gate == null:
		_fail(FAIL_CLICKS, "draft_gate missing")
		return false
	if gate.has_method("present_mystery"):
		var bait: Dictionary = main.call("_make_item", "healing_potion")
		gate.call("present_mystery", bait, 1, null, 2)
	var take: Button = _find_button(gate, "Take")
	var leave: Button = _find_button(gate, "Leave")
	if take == null:
		take = _first_button(gate)
	if take == null or take.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_CLICKS, "door Take missing or IGNORE")
		return false
	if leave != null and leave.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_CLICKS, "door Leave IGNORE")
		return false
	print("DOOR take=", take.text, " leave=", leave.text if leave else "(none)")
	if gate.has_method("hide_gate"):
		gate.call("hide_gate")

	var hud: Node = main.get("hud")
	if hud != null:
		var col: Control = hud.get("column") as Control
		if col != null and col.mouse_filter == Control.MOUSE_FILTER_STOP and col.visible:
			print("COLUMN_WARN filter=STOP visible=", col.visible)
		else:
			print("COLUMN filter=", col.mouse_filter if col else "missing", " visible=", col.visible if col else false)

	print("CLICKS_OK spin/wheel/inspect/pause/door")
	return true


func _find_button(n: Node, label: String) -> Button:
	if n is Button:
		var t: String = (n as Button).text.strip_edges()
		if t == label or t.contains(label):
			return n
	for c in n.get_children():
		var hit: Button = _find_button(c, label)
		if hit != null:
			return hit
	return null


func _first_button(n: Node) -> Button:
	if n is Button and (n as Button).visible:
		return n
	for c in n.get_children():
		var hit: Button = _first_button(c)
		if hit != null:
			return hit
	return null
