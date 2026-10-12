extends SceneTree
## Headless: static face_text override paints the hand card; empty falls back to auto.

const FAIL_BOOT := 2
const FAIL_FACE := 3
const UX := preload("res://scripts/ux_style.gd")


func _fail(code: int, msg: String) -> void:
	push_error(msg)
	print("FACE_TEXT_FAIL=", msg)
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
	if not _check_parse():
		return
	if not _check_card_hook():
		return
	if not _check_live_hand(main):
		return
	if not _check_editor_field(main):
		return
	print("FACE_TEXT_OK")
	quit(0)


func _check_parse() -> bool:
	var a: Dictionary = UX.parse_face_text("3 ATK")
	var b: Dictionary = UX.parse_face_text("3 HEAL")
	var c: Dictionary = UX.parse_face_text("UTIL")
	var d: Dictionary = UX.parse_face_text("")
	var e: Dictionary = UX.parse_face_text("4BLK")
	print("PARSE atk=", a, " heal=", b, " util=", c, " empty=", d, " glued=", e)
	if str(a.get("n", "")) != "3" or str(a.get("tag", "")) != "ATK":
		_fail(FAIL_FACE, "parse 3 ATK -> %s" % a)
		return false
	if str(b.get("n", "")) != "3" or str(b.get("tag", "")) != "HEAL":
		_fail(FAIL_FACE, "parse 3 HEAL -> %s" % b)
		return false
	if str(c.get("tag", "")) != "UTIL":
		_fail(FAIL_FACE, "parse UTIL -> %s" % c)
		return false
	if not d.is_empty():
		_fail(FAIL_FACE, "empty parse should be {}")
		return false
	if str(e.get("n", "")) != "4" or str(e.get("tag", "")) != "BLK":
		_fail(FAIL_FACE, "parse 4BLK -> %s" % e)
		return false
	return true


func _check_card_hook() -> bool:
	var scn: PackedScene = load("res://scenes/ui/hand_card.tscn") as PackedScene
	if scn == null:
		_fail(FAIL_BOOT, "missing hand_card.tscn")
		return false
	var card: Control = scn.instantiate()
	root.add_child(card)
	card.setup(1, "throwing_knife", "3", null, Color("5c2626"), Color("B8733A"), "Throwing Knife", Color.WHITE, "ATK")
	var auto_n: String = str(card.get("_num").text)
	var auto_t: String = str(card.get("_tag").text)
	print("AUTO_FACE num=", auto_n, " tag=", auto_t)
	if auto_n != "3":
		_fail(FAIL_FACE, "auto face num=%s expected 3" % auto_n)
		return false
	if auto_t != "ATK":
		_fail(FAIL_FACE, "auto face tag=%s expected ATK" % auto_t)
		return false
	if not card.has_method("set_face_text"):
		_fail(FAIL_FACE, "item_card missing set_face_text")
		return false
	card.set_face_text("9 UTIL")
	var over_n: String = str(card.get("_num").text)
	var over_t: String = str(card.get("_tag").text)
	print("OVERRIDE_FACE num=", over_n, " tag=", over_t)
	if over_n != "9" or over_t != "UTIL":
		_fail(FAIL_FACE, "override rendered %s %s" % [over_n, over_t])
		return false
	card.set_face_text("")
	var back_n: String = str(card.get("_num").text)
	var back_t: String = str(card.get("_tag").text)
	print("FALLBACK_FACE num=", back_n, " tag=", back_t)
	if back_n != "3" or back_t != "ATK":
		_fail(FAIL_FACE, "empty override did not fall back (%s %s)" % [back_n, back_t])
		return false
	card.queue_free()
	return true


func _check_live_hand(main: Node) -> bool:
	if not main.has_method("_make_item") or not main.has_method("_sync_hotbar"):
		_fail(FAIL_BOOT, "missing _make_item / _sync_hotbar")
		return false
	var knife: Dictionary = main.call("_make_item", "throwing_knife")
	if str(knife.get("face_text", "")) != "":
		_fail(FAIL_FACE, "catalog throwing_knife already has face_text=%s" % knife.get("face_text", ""))
		return false
	knife["face_text"] = "3 ATK"
	main.set("hotbar", [knife])
	main.set("_hotbar_sig", "")
	main.set("phase", "fighting")
	main.call("_sync_hotbar")
	var box: Node = main.get("hotbar_box")
	if box == null or box.get_child_count() < 1:
		_fail(FAIL_FACE, "no hand card after sync")
		return false
	var card: Node = box.get_child(0)
	var n: String = str(card.get("_num").text)
	var t: String = str(card.get("_tag").text)
	print("LIVE_OVERRIDE num=", n, " tag=", t, " stored=", knife.get("face_text", ""))
	if n != "3" or t != "ATK":
		_fail(FAIL_FACE, "live override rendered %s %s" % [n, t])
		return false
	knife["face_text"] = ""
	main.call("_sync_hotbar")
	var card2: Node = box.get_child(0)
	print("LIVE_FALLBACK num=", card2.get("_num").text, " tag=", card2.get("_tag").text)
	return true


func _check_editor_field(main: Node) -> bool:
	var ed: Node = main.get("content_ed")
	if ed == null:
		_fail(FAIL_FACE, "content_ed missing")
		return false
	if not ed.has_method("open_card"):
		_fail(FAIL_FACE, "content_ed has no open_card")
		return false
	var cat: Dictionary = (main.get("items_by_id") as Dictionary).get("throwing_knife", {})
	ed.call("open_card", "item", "throwing_knife", cat)
	var fields: Dictionary = ed.get("_fields")
	print("EDITOR_FIELDS has_face_text=", fields.has("face_text"))
	if not fields.has("face_text"):
		_fail(FAIL_FACE, "Edit card view has no face_text field")
		return false
	var lock: Script = load("res://scripts/author_lock.gd")
	if not lock.CARD_FIELDS.has("face_text"):
		_fail(FAIL_FACE, "author_lock CARD_FIELDS missing face_text")
		return false
	if ed.has_method("close_editor"):
		ed.call("close_editor")
	return true
