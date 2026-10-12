extends SceneTree
## Headless checks: use an item in a fight, then draft take (click item) and leave (pass).
## Run: godot --path . --headless --script res://tools/qa/check_hand_use.gd

const PROBE := preload("res://tools/qa/qa_probe.gd")

var _main: Node
var _n := 0
var _step := "boot"
var _wait := 0
var _ok := true
var _notes: PackedStringArray = PackedStringArray()
var _take_item := ""
var _passes_before := -1
var _hand_before := 0
var _blk_before := 0
var _used_uid := 0


func _initialize() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		_fail("missing main.tscn")
		quit()
		return
	_main = packed.instantiate()
	root.add_child(_main)
	print("check_hand_use: boot")


func _process(_delta: float) -> bool:
	_n += 1
	_wait += 1
	if _n == 12 and _step == "boot":
		_start_fight()
		return false
	if _step == "spin" and _wait > 8:
		if str(_main.get("phase")) == "fighting":
			_use_hand()
		elif _wait > 240:
			_fail("spin never reached fighting")
			_start_draft()
		return false
	if _step == "used" and _wait > 4:
		_check_hand_use()
		_start_draft()
		return false
	if _step == "mill" and _wait > 6:
		var gate: Node = _main.get("draft_gate")
		if str(_main.get("draft_action")) == "ask" and gate != null and bool(gate.visible):
			_save_shot("draft_gate_compact.png")
			_check_layout()
			_leave_offer()
		elif _wait > 360:
			_fail("mill never reached draft ask")
			_finish()
		return false
	if _step == "left" and _wait > 6:
		if str(_main.get("draft_action")) == "ask":
			_check_leave()
			_take_offer()
		elif _wait > 240:
			_fail("leave never returned a new ask")
			_finish()
		return false
	if _step == "took" and _wait > 6:
		if str(_main.get("draft_action")) == "seat":
			_check_take()
			_finish()
		elif _wait > 300:
			_fail("take never reached seat")
			_finish()
		return false
	if _n > 900:
		_fail("timeout at %s" % _step)
		_finish()
	return false


func _start_fight() -> void:
	if _main.has_method("_quick_start"):
		_main.call("_quick_start")
	_hand_before = (_main.get("hotbar") as Array).size()
	if _hand_before <= 0:
		_fail("quick start left an empty hand")
	_step = "spin"
	_wait = 0
	if _main.has_method("_on_spin"):
		_main.call("_on_spin")
	print("check_hand_use: spin")


func _use_hand() -> void:
	_blk_before = int(_main.get("blk"))
	var used := false
	for it in _main.get("hotbar"):
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var ops: Dictionary = it.get("ops", {}) if typeof(it.get("ops", {})) == TYPE_DICTIONARY else {}
		if str(ops.get("kind", "")) != "blk":
			continue
		_used_uid = int(it.get("uid", 0))
		if _main.has_method("_use_item"):
			_main.call("_use_item", _used_uid)
			used = true
			print("check_hand_use: used %s" % it.get("name", "?"))
			break
	if not used:
		_fail("no Block item in the Dive In hand")
	_step = "used"
	_wait = 0


func _check_hand_use() -> void:
	var dump: Dictionary = PROBE.dump(_main)
	var blk_now: int = int(dump.get("blk", 0))
	if blk_now <= _blk_before:
		_fail("Block did not rise after using a Block item (was %s now %s)" % [_blk_before, blk_now])
	else:
		_notes.append("hand use: BLK %s → %s" % [_blk_before, blk_now])
	print("check_hand_use: hand_use blk=%s" % blk_now)


func _start_draft() -> void:
	if _main.has_method("_begin_run"):
		_main.call("_begin_run")
	_step = "mill"
	_wait = 0
	print("check_hand_use: mill")


func _check_layout() -> void:
	var dump: Dictionary = PROBE.dump(_main)
	var layout: Dictionary = dump.get("layout", {})
	if bool(layout.get("overlap", false)):
		_fail("draft column overlaps the hand")
	var gate: Dictionary = dump.get("draft_gate", {})
	var leave: String = str(gate.get("leave", ""))
	if leave.contains("{n}") or leave == "":
		_fail("leave copy is empty or still has {n}: %s" % leave)
	if bool(gate.get("take_present", false)):
		_fail("Take button is still present")
	if str(gate.get("threat", "")).to_lower().contains("tier"):
		_fail("threat shows the word Tier")
	_notes.append("layout ok; leave='%s' threat='%s'" % [leave, gate.get("threat", "")])
	print("check_hand_use: layout %s" % JSON.stringify(layout))
	print("check_hand_use: gate %s" % JSON.stringify(gate))


func _leave_offer() -> void:
	_passes_before = int(_main.get("refusals_left"))
	_take_item = str((_main.get("pending_item") as Dictionary).get("name", ""))
	if _main.has_method("_on_gate_refuse"):
		_main.call("_on_gate_refuse")
	_step = "left"
	_wait = 0
	print("check_hand_use: leave %s passes=%s" % [_take_item, _passes_before])


func _check_leave() -> void:
	var now: int = int(_main.get("refusals_left"))
	if _passes_before > 0 and now != _passes_before - 1:
		_fail("leave did not spend a pass (was %s now %s)" % [_passes_before, now])
	else:
		_notes.append("leave spent a pass: %s → %s" % [_passes_before, now])
	print("check_hand_use: after leave passes=%s action=%s" % [now, _main.get("draft_action")])


func _take_offer() -> void:
	_take_item = str((_main.get("pending_item") as Dictionary).get("name", ""))
	if _main.has_method("_on_gate_send"):
		_main.call("_on_gate_send")
	_step = "took"
	_wait = 0
	print("check_hand_use: take %s" % _take_item)


func _check_take() -> void:
	var action: String = str(_main.get("draft_action"))
	var pending: Dictionary = _main.get("pending_item") if typeof(_main.get("pending_item")) == TYPE_DICTIONARY else {}
	if action != "seat":
		_fail("take did not move to seat (action=%s)" % action)
	if pending.is_empty() and _take_item == "":
		_fail("take cleared the offer before seating")
	else:
		_notes.append("take reached seat with %s" % pending.get("name", _take_item))
	print("check_hand_use: take ok action=%s item=%s" % [action, pending.get("name", "")])


func _save_shot(filename: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		return
	DirAccess.make_dir_recursive_absolute("res://design/visual/qa")
	img.save_png("res://design/visual/qa/" + filename)
	print("check_hand_use: saved design/visual/qa/%s" % filename)


func _fail(msg: String) -> void:
	_ok = false
	_notes.append("FAIL: %s" % msg)
	push_error("check_hand_use: %s" % msg)


func _finish() -> void:
	var dump: Dictionary = PROBE.dump(_main) if _main != null else {}
	print("check_hand_use: RESULT %s" % ("PASS" if _ok else "FAIL"))
	for line in _notes:
		print("check_hand_use: %s" % line)
	print("check_hand_use: dump %s" % JSON.stringify(dump))
	quit()
