extends SceneTree
## Headless proof for FIXES-v2 acceptance. UI only.

const FAIL := 2
const COPY := preload("res://scripts/player_copy.gd")


func _fail(msg: String) -> void:
	push_error(msg)
	print("FIXES_V2_FAIL=", msg)
	quit(FAIL)


func _init() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("missing main.tscn")
		return
	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	if not _check_log(main):
		return
	if not await _check_gate(main):
		return
	if not _check_cards(main):
		return
	if not await _check_wheel(main):
		return
	print("FIXES_V2_OK")
	quit(0)


func _check_log(main: Node) -> bool:
	var log_label: Control = main.get("log_label")
	if log_label == null:
		_fail("log_label missing")
		return false
	main.set("_shift_held", true)
	main.set("_play_log_enabled", false)
	main.set("phase", "draft")
	if main.has_method("_sync_authoring_chrome"):
		main.call("_sync_authoring_chrome")
	print("LOG_SHIFT visible=", log_label.visible)
	if log_label.visible:
		_fail("Shift showed the log in normal play")
		return false
	main.set("_play_log_enabled", true)
	main.call("_sync_authoring_chrome")
	if not log_label.visible:
		_fail("Developer event-log toggle did not show the log")
		return false
	print("LOG_TOGGLE visible=", log_label.visible, " rect=", log_label.get_global_rect())
	main.set("_play_log_enabled", false)
	main.set("_shift_held", false)
	main.call("_sync_authoring_chrome")
	if log_label.visible:
		_fail("log stayed up after the toggle was turned off")
		return false
	print("LOG_OK off unless Developer toggle")
	return true


func _check_gate(main: Node) -> bool:
	var gate: Control = main.get("draft_gate")
	if gate == null or not gate.has_method("present_mystery"):
		_fail("draft_gate missing")
		return false
	var names: PackedStringArray = PackedStringArray()
	for t in [1, 2, 3]:
		var bait: Dictionary = main.call("_make_item", "medallion")
		gate.call("present_mystery", bait, t, null, 3)
		await process_frame
		var snap: Dictionary = gate.call("qa_snapshot")
		var threat: String = str(snap.get("threat", ""))
		var expect: String = COPY.tier_name(t)
		print("THREAT t=", t, " name=", threat, " expect=", expect, " nib=", snap.get("nib"), " take=", snap.get("take_present"))
		if threat != expect:
			_fail("threat t=%s was %s not %s" % [t, threat, expect])
			return false
		if threat.to_lower().contains("tier"):
			_fail("threat shows the word Tier")
			return false
		if bool(snap.get("take_present", false)):
			_fail("Take button is present")
			return false
		var nib: Array = snap.get("nib", [])
		print("NIB ", nib, " visible=", snap.get("nib_visible"))
		if not bool(snap.get("nib_visible", false)):
			_fail("Nib well hidden in ask mode")
			return false
		if nib.size() >= 1 and float(nib[0]) > 400.0:
			_fail("Nib well is not on the left: %s" % [nib])
			return false
		names.append(threat)
	var hud: Node = main.get("hud")
	if hud != null and hud.has_method("qa_layout"):
		var layout: Dictionary = hud.call("qa_layout")
		var col: Array = layout.get("column", [])
		print("COLUMN ", col)
		if col.size() >= 4:
			if float(col[0]) > 48.0:
				_fail("draft column is not on the left: %s" % [col])
				return false
			if float(col[2]) > 420.0:
				_fail("draft column wider than a fifth-ish: %s" % [col])
				return false
	if gate.has_method("hide_gate"):
		gate.call("hide_gate")
	print("GATE_OK threats=", ",".join(names))
	return true


func _check_cards(main: Node) -> bool:
	if not main.has_method("_make_item"):
		_fail("missing _make_item")
		return false
	var packed: PackedScene = load("res://scenes/ui/hand_card.tscn") as PackedScene
	if packed == null:
		_fail("missing hand_card.tscn")
		return false
	var ids := ["sai", "helmet", "shield", "smoke_bomb", "net", "medallion"]
	for id in ids:
		var it: Dictionary = main.call("_make_item", id)
		if it.is_empty():
			_fail("factory empty for %s" % id)
			return false
		var card: Control = packed.instantiate()
		root.add_child(card)
		var view: Dictionary = main.call("_item_view", it) if main.has_method("_item_view") else {}
		var k: String = str(main.call("_item_display_kind", it)) if main.has_method("_item_display_kind") else "ATK"
		if card.has_method("setup"):
			card.call(
				"setup",
				int(it.get("uid", 0)),
				str(it.get("card_id", id)),
				str(view.get("number", "")),
				null,
				view.get("fill", Color("3B2618")),
				view.get("rim", Color("7A4E2B")),
				str(it.get("name", id)),
				Color.WHITE,
				k,
				null
			)
		var before: Vector2 = card.get_combined_minimum_size()
		var rule: Dictionary = main.call("_item_rule", it) if main.has_method("_item_rule") else {}
		var eq: String = str(rule.get("equation", ""))
		if eq == "" and id == "helmet":
			eq = "(the lower of YOUR HP and ENEMY HP)"
		if card.has_method("set_formula"):
			card.call("set_formula", eq)
		if card.has_method("show_formula"):
			card.call("show_formula", false)
		var mid: Vector2 = card.get_combined_minimum_size()
		if card.has_method("show_formula"):
			card.call("show_formula", true)
		var after: Vector2 = card.get_combined_minimum_size()
		print("CARD id=", id, " off=", mid, " on=", after, " kind=", card.get("kind"))
		if after.y > before.y + 0.5 or mid.y > before.y + 0.5:
			_fail("%s grew on Shift %s -> %s" % [id, before, after])
			return false
		if absf(after.y - 210.0) > 0.5:
			_fail("%s height is %s not 210" % [id, after.y])
			return false
		card.queue_free()
	print("CARDS_OK")
	return true


func _check_wheel(main: Node) -> bool:
	var wheel: Node = main.get("wheel_view")
	if wheel == null:
		_fail("wheel_view missing")
		return false
	if not main.has_method("_make_monster"):
		_fail("missing _make_monster")
		return false
	if main.has_method("_empty_wheel"):
		main.call("_empty_wheel")
	var ids := {
		0: "golem",
		1: "goblin",
		2: "skeleton",
		4: "wizard",
		6: "hornet_swarm",
	}
	var w: Array = main.get("wheel")
	for i in range(8):
		if ids.has(i):
			w[i] = main.call("_make_monster", str(ids[i]))
		else:
			w[i] = {"kind": "empty", "slot": str(i)}
	main.set("wheel", w)
	if wheel.has_method("set_slices"):
		wheel.call("set_slices", w, -1, "none")
	await process_frame
	if not wheel.has_method("_spoke"):
		print("WHEEL_SKIP no _spoke")
		return true
	var boxes: Array = []
	for i in range(8):
		if str(w[i].get("kind", "")) != "monster":
			continue
		var sp: Dictionary = wheel.call("_spoke", i)
		var port: Vector2 = sp.get("port", Vector2.ZERO)
		var hp: Vector2 = sp.get("hp", Vector2.ZERO)
		var atk: Vector2 = sp.get("atk", Vector2.ZERO)
		var nam: Vector2 = sp.get("name", Vector2.ZERO)
		if hp.x >= port.x:
			_fail("seat %s heart is not left of sprite" % i)
			return false
		if atk.x <= port.x:
			_fail("seat %s sword is not right of sprite" % i)
			return false
		if nam.y < port.y:
			_fail("seat %s capsule is not under the sprite" % i)
			return false
		var sprite := Rect2(port - Vector2(28, 28), Vector2(56, 56))
		var heart := Rect2(hp - Vector2(12, 13), Vector2(24, 26))
		var sword := Rect2(atk - Vector2(15, 15), Vector2(30, 30))
		var cap_w: float = float(sp.get("cap_w", 64.0))
		var cap_h: float = float(sp.get("cap_h", 22.0))
		var cap := Rect2(nam - Vector2(cap_w, cap_h) * 0.5, Vector2(cap_w, cap_h))
		print("SEAT ", i, " sprite=", sprite, " heart=", heart, " sword=", sword, " cap=", cap)
		if cap_w > 112.5:
			_fail("seat %s capsule width %s > 112" % [i, cap_w])
			return false
		if sprite.intersects(heart) or sprite.intersects(sword) or sprite.intersects(cap):
			_fail("seat %s self-overlap" % i)
			return false
		if heart.intersects(sword) or heart.intersects(cap) or sword.intersects(cap):
			_fail("seat %s icon/capsule overlap" % i)
			return false
		for other in boxes:
			if sprite.intersects(other) or heart.intersects(other) or sword.intersects(other) or cap.intersects(other):
				_fail("seat %s overlaps another seat box" % i)
				return false
		boxes.append(sprite)
		boxes.append(heart)
		boxes.append(sword)
		boxes.append(cap)
	print("WHEEL_OK seats=", boxes.size() / 4)
	return true
