extends SceneTree
## Walks draft → spin → resolve and asserts the action buttons
## stay visible and take clicks. Run:
##   godot --path . --headless --script res://tools/qa/check_action_buttons.gd

const FAIL_BOOT := 2
const FAIL_DRAFT := 3
const FAIL_SPIN := 4
const FAIL_RESOLVE := 5

const PROBE := preload("res://tools/qa/qa_probe.gd")


func _fail(code: int, msg: String) -> void:
	push_error(msg)
	print("ACTION_BTN_FAIL=", msg)
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
	if str(main.get("phase")) != "title":
		_fail(FAIL_BOOT, "expected title after boot, got %s" % main.get("phase"))
		return
	if not await _check_draft(main):
		return
	if not await _check_spin(main):
		return
	if not await _check_resolve(main):
		return
	print("ACTION_BTN_OK")
	quit(0)


func _check_draft(main: Node) -> bool:
	if not main.has_method("_begin_run"):
		_fail(FAIL_DRAFT, "missing _begin_run")
		return false
	main.call("_begin_run")
	if not await _wait_ask(main, 8.0):
		_fail(FAIL_DRAFT, "mill never reached draft ask")
		return false
	main.call("_refresh")
	await process_frame
	var dump: Dictionary = PROBE.dump(main)
	var btns: Dictionary = dump.get("buttons", {})
	var gate: Dictionary = dump.get("draft_gate", {})
	print("DRAFT_BTNS ", JSON.stringify(btns))
	print("DRAFT_GATE ", JSON.stringify(gate))
	var leave: Button = _leave_btn(main)
	if leave == null:
		_fail(FAIL_DRAFT, "Leave button missing at draft ask")
		return false
	if not leave.visible or not leave.is_visible_in_tree():
		_fail(FAIL_DRAFT, "Leave button hidden at draft ask")
		return false
	if leave.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_DRAFT, "Leave button IGNORE at draft ask")
		return false
	if leave.disabled and int(main.get("refusals_left")) > 0:
		_fail(FAIL_DRAFT, "Leave disabled while passes remain")
		return false
	var item_slot: Control = _find_item_take(main.get("draft_gate"))
	if item_slot == null or item_slot.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_DRAFT, "draft item take slot missing or IGNORE")
		return false
	if bool(btns.get("hearts_visible", true)):
		_fail(FAIL_DRAFT, "top-left hearts_box is still visible")
		return false
	if not bool(gate.get("callout", false)):
		_fail(FAIL_DRAFT, "draft item is not using the hover callout")
		return false
	print("DRAFT_OK leave=", leave.text, " item_filter=", item_slot.mouse_filter, " callout=", gate.get("callout"))
	return true


func _check_spin(main: Node) -> bool:
	if not _seat_ready(main):
		return false
	main.set("phase", "ready")
	main.set("facing_index", -1)
	main.call("_refresh")
	await process_frame
	var spin: Button = main.get("btn_spin") as Button
	if spin == null:
		_fail(FAIL_SPIN, "Spin button missing")
		return false
	if not spin.visible or not spin.is_visible_in_tree():
		_fail(FAIL_SPIN, "Spin hidden at ready")
		return false
	if spin.disabled:
		_fail(FAIL_SPIN, "Spin disabled at ready")
		return false
	if spin.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_SPIN, "Spin IGNORE at ready")
		return false
	var done: Button = main.get("btn_done") as Button
	if done != null and done.visible:
		_fail(FAIL_SPIN, "Done is visible before combat")
		return false
	print("SPIN_OK visible filter=", spin.mouse_filter, " text=", spin.text)
	return true


func _check_resolve(main: Node) -> bool:
	main.set("phase", "fighting")
	main.set("facing_index", 0)
	main.set("blk", 0)
	main.call("_refresh")
	await process_frame
	var dump: Dictionary = PROBE.dump(main)
	var btns: Dictionary = dump.get("buttons", {})
	print("FIGHT_BTNS ", JSON.stringify(btns))
	var spin: Button = main.get("btn_spin") as Button
	if spin != null and spin.visible:
		_fail(FAIL_RESOLVE, "Spin stayed visible after combat began")
		return false
	var done: Button = main.get("btn_done") as Button
	if done == null:
		_fail(FAIL_RESOLVE, "Done / Safe / Take button missing")
		return false
	if not done.visible or not done.is_visible_in_tree():
		_fail(FAIL_RESOLVE, "Done / Safe / Take hidden when combat began")
		return false
	if done.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		_fail(FAIL_RESOLVE, "Done / Safe / Take IGNORE when combat began")
		return false
	if done.disabled:
		_fail(FAIL_RESOLVE, "Done / Safe / Take disabled when combat began")
		return false
	var lab: String = done.text.strip_edges()
	if lab == "" or (not lab.contains("Take") and lab != "Safe" and lab != "Done"):
		_fail(FAIL_RESOLVE, "resolve label unexpected: %s" % lab)
		return false
	print("RESOLVE_OK text=", lab, " filter=", done.mouse_filter)
	return true


func _seat_ready(main: Node) -> bool:
	if not main.has_method("_make_monster") or not main.has_method("_make_item"):
		_fail(FAIL_BOOT, "missing card factories")
		return false
	var golem: Dictionary = main.call("_make_monster", "golem")
	var shield: Dictionary = main.call("_make_item", "shield")
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
	main.set("in_tutorial", false)
	main.set("draft_action", "")
	if main.get("draft_gate") != null and main.get("draft_gate").has_method("hide_gate"):
		main.get("draft_gate").call("hide_gate")
	return true


func _wait_ask(main: Node, seconds: float) -> bool:
	var waited := 0.0
	while waited < seconds:
		await process_frame
		waited += 0.016
		var gate: Node = main.get("draft_gate")
		if str(main.get("draft_action")) == "ask" and gate != null and bool(gate.visible):
			return true
	return false


func _leave_btn(main: Node) -> Button:
	var gate: Node = main.get("draft_gate")
	if gate != null and gate.has_method("leave_btn"):
		return gate.call("leave_btn") as Button
	return _find_button(gate, "Leave")


func _find_item_take(gate: Node) -> Control:
	if gate == null:
		return null
	for c in gate.get_children():
		if c is PanelContainer and int(c.mouse_filter) == Control.MOUSE_FILTER_STOP:
			return c
		var nested: Control = _find_item_take(c)
		if nested != null:
			return nested
	return null


func _find_button(n: Node, label: String) -> Button:
	if n == null:
		return null
	if n is Button:
		var t: String = (n as Button).text.strip_edges()
		if t == label or t.contains(label):
			return n
	for c in n.get_children():
		var hit: Button = _find_button(c, label)
		if hit != null:
			return hit
	return null
