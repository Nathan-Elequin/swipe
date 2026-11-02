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
	if Defeat != null:
		var ui = Defeat.new()
		root.add_child(ui)
		ui.debug_show_settled(null, null)
		failed = _check(failed, "settled visible", ui.visible) or failed
		failed = _check(failed, "buttons live", ui.buttons_ready()) or failed
		failed = _check(failed, "undo not part of UI", true) or failed
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
