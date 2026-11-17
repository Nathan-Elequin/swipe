extends SceneTree
## Endless clear tally: title + Continue horizontally centered; counter ticks once.
## Run: godot --headless --path . --script res://scripts/dev/endless_clear_tally_selftest.gd


const CLEAR := preload("res://scripts/ui/endless_clear_menu.gd")
const HUD := preload("res://scripts/ui/endless_hud.gd")
const VIEW_W := 1680.0
const VIEW_H := 1040.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	root.get_viewport().size = Vector2i(int(VIEW_W), int(VIEW_H))

	var hud = HUD.new()
	root.add_child(hud)
	hud.hold_floor(3, 3)
	failed = _check(failed, "hud holds 3", hud.shown_n() == 3) or failed

	var menu = CLEAR.new()
	root.add_child(menu)
	menu.bind_host(null, hud, null)

	## Skip path via reduce_motion + open (settles after short waits).
	await menu.open_menu({
		"from_n": 3,
		"to_n": 4,
		"best": 3,
		"new_best": true,
		"reduce_motion": true,
		"hud": hud,
	})
	await _frames(4)

	failed = _check(failed, "menu settled", menu.is_settled()) or failed
	failed = _check(failed, "counter applied once", menu.counter_applied_once()) or failed
	failed = _check(failed, "hud shows 4", hud.shown_n() == 4) or failed
	failed = _check(failed, "tick_count == 1", hud.tick_count() == 1) or failed

	## Re-receive must not double-tick.
	hud.receive_tally(4, 4, false, true)
	failed = _check(failed, "no double tick", hud.tick_count() == 1) or failed

	var mid: float = menu.viewport_center_x()
	var title_x: float = menu.title_center_x()
	var btn_x: float = menu.continue_center_x()
	failed = _check(failed, "title centered ≤2px", absf(title_x - mid) <= 2.0) or failed
	failed = _check(failed, "continue centered ≤2px", absf(btn_x - mid) <= 2.0) or failed

	## Second open: tick again once (new clear).
	var ticks_before: int = hud.tick_count()
	await menu.open_menu({
		"from_n": 4,
		"to_n": 5,
		"best": 4,
		"new_best": true,
		"reduce_motion": true,
		"hud": hud,
	})
	await _frames(3)
	failed = _check(failed, "second clear +1 tick", hud.tick_count() == ticks_before + 1) or failed
	failed = _check(failed, "hud shows 5", hud.shown_n() == 5) or failed

	## show_floor same value must not fly/tick again.
	var t2: int = hud.tick_count()
	hud.show_floor(5, 5, true)
	failed = _check(failed, "show_floor no extra tick", hud.tick_count() == t2) or failed

	## Cue map keys exist for Reel placeholders.
	var map_txt := FileAccess.get_file_as_string("res://data/sfx-map.json")
	for key in [
		"endless.clear_ring",
		"endless.plus_stamp",
		"endless.plus_fly",
		"endless.counter_tick",
		"endless.new_best",
		"ui.continue_appear",
	]:
		failed = _check(failed, "sfx cue " + key, map_txt.find('"%s"' % key) >= 0) or failed

	## Main wires tally open (hold before commit, await open_menu).
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(failed, "main hold_floor before menu", main_src.find("hold_floor") >= 0) or failed
	failed = _check(failed, "main awaits open_menu", main_src.find("await endless_clear_menu.open_menu") >= 0) or failed
	failed = _check(failed, "continue uses hud show false", main_src.find("_endless_hud_show(false)") >= 0) or failed

	menu.queue_free()
	hud.queue_free()
	if failed:
		push_error("endless_clear_tally self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK endless_clear_tally")
		quit(0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("ok  ", label)
		return failed
	push_error("FAIL " + label)
	return true
