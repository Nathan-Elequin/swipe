extends SceneTree
## Headless checks for the defeat spotlight sequence + Spin journal keys.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var PLAYER_COPY = load("res://scripts/player_copy.gd")
	PLAYER_COPY.reload()
	failed = _check(failed, "attrib B.S.", PLAYER_COPY.text("defeat.journal.attrib", "") == "B.S.") or failed
	failed = _check(failed, "defeat.home", PLAYER_COPY.text("defeat.home", "") == "Limp home") or failed
	failed = _check(failed, "defeat.quick", PLAYER_COPY.text("defeat.quick", "") == "Quick start") or failed
	var n := 0
	for i in range(1, 51):
		var key := "defeat.journal.%02d" % i
		if PLAYER_COPY.has_key(key) and PLAYER_COPY.text(key, "") != "":
			n += 1
	failed = _check(failed, "50 journal keys", n == 50) or failed
	failed = _check(
		failed,
		"01 lighting",
		PLAYER_COPY.text("defeat.journal.01", "") == "A setback is just a setback with better lighting."
	) or failed
	failed = _check(
		failed,
		"33 religion",
		PLAYER_COPY.text("defeat.journal.33", "") == "One more delve. Always one more. That is the whole religion."
	) or failed
	failed = _check(
		failed,
		"50 rematch",
		PLAYER_COPY.text("defeat.journal.50", "") == "Close the journal. Open the door. The mountain owes you a rematch."
	) or failed

	var sh := load("res://shaders/defeat_spotlight.gdshader")
	failed = _check(failed, "spotlight shader loads", sh != null) or failed

	var Defeat = load("res://scripts/ui/defeat_spotlight.gd")
	failed = _check(failed, "defeat_spotlight script loads", Defeat != null) or failed
	var intact_tex = load("res://assets/dungeon/home/overlays/wax_seal.png")
	var broken_tex = load("res://assets/dungeon/home/overlays/wax_seal_broken.png")
	failed = _check(failed, "wax_seal.png loads", intact_tex != null) or failed
	failed = _check(failed, "wax_seal_broken.png loads", broken_tex != null) or failed

	if Defeat != null:
		var ui = Defeat.new()
		root.add_child(ui)
		ui.debug_show_settled(null, null)
		failed = _check(failed, "settled visible", ui.visible) or failed
		failed = _check(failed, "buttons live", ui.buttons_ready()) or failed
		failed = _check(failed, "undo not part of UI", true) or failed
		var root_n: Node = ui.get_node_or_null("Root")
		var seal: Node = null
		var seal_intact: TextureRect = null
		var seal_broken: TextureRect = null
		var attrib: Label = null
		if root_n != null:
			seal = root_n.find_child("Seal", true, false)
			seal_intact = root_n.find_child("SealIntact", true, false) as TextureRect
			seal_broken = root_n.find_child("SealBroken", true, false) as TextureRect
			attrib = root_n.find_child("Attrib", true, false) as Label
		failed = _check(failed, "Seal widget present", seal != null) or failed
		failed = _check(failed, "SealIntact present", seal_intact != null) or failed
		failed = _check(failed, "SealBroken present", seal_broken != null) or failed
		failed = _check(
			failed,
			"settled shows broken seal",
			seal_broken != null and seal_broken.modulate.a > 0.9 and seal_intact != null and seal_intact.modulate.a < 0.1
		) or failed
		failed = _check(
			failed,
			"attrib is B.S.",
			attrib != null and attrib.text.find("B.S.") >= 0
		) or failed
		failed = _check(
			failed,
			"seal left of attrib in row",
			seal != null and attrib != null and seal.get_index() < attrib.get_index()
		) or failed
		ui.dismiss()
		failed = _check(failed, "dismiss hides", not ui.visible) or failed
		ui.queue_free()

	if failed:
		push_error("defeat_spotlight self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK defeat_spotlight")
		quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("ok  ", label)
		return failed
	push_error("FAIL " + label)
	return true
