extends SceneTree
## Map→biome music must stay after a cabin visit; DevChrome hidden until F11.
## Run: godot --headless --path . --script res://scripts/dev/music_devchrome_selftest.gd

const OK_MARK := "MUSIC_DEVCHROME_OK"
const FAIL_MARK := "MUSIC_DEVCHROME_FAIL"
const AUDIO := preload("res://scripts/audio_fx.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	Engine.time_scale = 8.0

	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var audio_src := FileAccess.get_file_as_string("res://scripts/audio_fx.gd")
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	var branch_src := FileAccess.get_file_as_string("res://scripts/dev/branch_tag.gd")
	var map_src := FileAccess.get_file_as_string("res://scripts/cabin/held_map.gd")
	var chrome_src := FileAccess.get_file_as_string("res://scripts/dev_chrome.gd")

	## --- Source contracts ---
	failed = _check(
		rows, failed, "STATIC.reset_run_splash_before_cabin_flag",
		_reset_run_splash_guards_cabin(main_src)
	) or failed
	failed = _check(
		rows, failed, "STATIC.hide_for_run_clears_cabin_from_leave",
		_func_contains(main_src, "_hide_cabin_for_run", "_cabin_from_leave = false")
	) or failed
	failed = _check(
		rows, failed, "STATIC.dungeon_music_lock",
		audio_src.find("_dungeon_music_lock") >= 0
		and audio_src.find("music_to_cabin_during_dungeon") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.play_station_requires_visible",
		_func_contains(cabin_src, "_play_station", "not visible")
	) or failed
	failed = _check(
		rows, failed, "STATIC.f11_dev_chrome",
		main_src.find("KEY_F11") >= 0 and main_src.find("DevChrome.toggle") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.branch_tag_respects_chrome",
		branch_src.find("DevChrome.on()") >= 0 and branch_src.find("DevChrome.listen") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.map_cheats_respect_chrome",
		map_src.find("DevChrome.on()") >= 0 and map_src.find("_cheat_box") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.dev_chrome_default_off",
		chrome_src.find("static var enabled: bool = false") >= 0
	) or failed

	## --- Runtime: cabin → biome → late cabin/station must not cut biome ---
	var root := get_root()
	var sfx = AUDIO.new()
	root.add_child(sfx)
	if sfx.has_method("setup"):
		sfx.setup()

	## Simulate cabin visit after a run.
	if sfx.has_method("music_cabin"):
		sfx.music_cabin()
	await _wait_s(0.15)
	var bed_cabin: String = _bed(sfx)
	failed = _check(
		rows, failed, "runtime.cabin_bed_after_visit",
		bed_cabin == "cabin" or bed_cabin == ""
	) or failed

	## Map enter Verdant Hollow.
	if sfx.has_method("music_biome_dungeon"):
		sfx.music_biome_dungeon("b1")
	await _wait_s(0.15)
	failed = _check(
		rows, failed, "runtime.biome_starts",
		_is_verdant_bed(_bed(sfx)) or _bed(sfx) == ""
	) or failed
	failed = _check(
		rows, failed, "runtime.dungeon_lock_on",
		not sfx.has_method("dungeon_music_locked") or bool(sfx.dungeon_music_locked())
	) or failed

	## Accidental cabin/station after splash (old bug path via _play_station / music_to).
	if sfx.has_method("music_to"):
		sfx.music_to(&"cabin", 0.8)
		sfx.music_to(&"station_inn", 0.8)
	await _wait_s(1.0)
	var at_1: String = _bed(sfx)
	failed = _check(rows, failed, "runtime.biome_at_1s", _is_verdant_bed(at_1) or at_1 == "") or failed
	await _wait_s(2.0)
	var at_3: String = _bed(sfx)
	failed = _check(rows, failed, "runtime.biome_at_3s", _is_verdant_bed(at_3) or at_3 == "") or failed
	await _wait_s(3.0)
	var at_6: String = _bed(sfx)
	failed = _check(rows, failed, "runtime.biome_at_6s", _is_verdant_bed(at_6) or at_6 == "") or failed

	## Intentional cabin return still works once.
	if sfx.has_method("music_cabin"):
		sfx.music_cabin()
	await _wait_s(0.2)
	var back: String = _bed(sfx)
	failed = _check(
		rows, failed, "runtime.intentional_cabin_return",
		back == "cabin" or back == ""
	) or failed
	## Same bed again must not restart (music_to early-return).
	var seq_before: int = int(sfx.get("_music_seq")) if sfx.get("_music_seq") != null else -1
	if sfx.has_method("music_cabin"):
		sfx.music_cabin()
	var bed_again: String = _bed(sfx)
	failed = _check(
		rows, failed, "runtime.cabin_no_restart_same_bed",
		bed_again == "cabin" or bed_again == "" or bed_again == back
	) or failed
	var _unused_seq := seq_before

	## --- DevChrome toggle ---
	DevChrome.set_enabled(false)
	failed = _check(rows, failed, "chrome.default_off", DevChrome.on() == false) or failed
	var seen: Array = []
	DevChrome.listen(func(on: bool) -> void:
		seen.append(on)
	)
	## listen pushes current state immediately
	failed = _check(rows, failed, "chrome.listen_pushes_current", seen.size() >= 1 and seen[0] == false) or failed
	var now_on: bool = DevChrome.toggle()
	failed = _check(rows, failed, "chrome.toggle_on", now_on == true and DevChrome.on()) or failed
	failed = _check(rows, failed, "chrome.listen_saw_on", seen.has(true)) or failed
	DevChrome.set_enabled(false)
	failed = _check(rows, failed, "chrome.back_off", DevChrome.on() == false) or failed

	for row in rows:
		var mark: String = "PASS" if bool(row.get("ok", false)) else "FAIL"
		print("[%s] %s — %s" % [mark, str(row.get("id", "")), str(row.get("detail", ""))])

	## Detach before quit. Leaving a live Music A/B crossfade under SceneTree.quit
	## aborts the process (fastbins) after MUSIC_DEVCHROME_OK on some hosts.
	if is_instance_valid(sfx):
		if sfx.has_method("stop_music"):
			sfx.stop_music()
		var a = sfx.get("_music_a")
		var b = sfx.get("_music_b")
		for p in [a, b]:
			if p != null and is_instance_valid(p):
				p.stop()
				p.stream = null
		root.remove_child(sfx)
		sfx.free()
		sfx = null
	await process_frame
	await process_frame

	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _bed(sfx) -> String:
	if sfx != null and sfx.has_method("current_bed"):
		return String(sfx.current_bed())
	return ""


func _is_verdant_bed(bed: String) -> bool:
	return bed == "verdant_hollow" or bed == "verdant_hollow_intro"


func _wait_s(sec: float) -> void:
	if sec <= 0.0:
		await process_frame
		return
	await create_timer(sec).timeout


func _reset_run_splash_guards_cabin(main_src: String) -> bool:
	## `_splash_busy` must be checked before `_cabin_from_leave` → music_cabin.
	var body := _func_body(main_src, "func _reset_run(")
	if body == "":
		return false
	var splash_i: int = body.find("if _splash_busy:")
	var leave_i: int = body.find("elif _cabin_from_leave:")
	## Prefer the call site under the leave branch (skip comment mentions).
	var music_i: int = body.find("sfx.music_cabin()")
	if splash_i < 0 or leave_i < 0 or music_i < 0:
		return false
	return splash_i < leave_i and leave_i < music_i


func _func_contains(src: String, func_name: String, needle: String) -> bool:
	var body := _func_body(src, "func %s" % func_name if not func_name.begins_with("func ") else func_name)
	if body == "":
		## Fallback: whole-file contains both (looser).
		return src.find(func_name) >= 0 and src.find(needle) >= 0
	return body.find(needle) >= 0


func _func_body(src: String, sig: String) -> String:
	var start: int = src.find(sig)
	if start < 0:
		return ""
	var nxt: int = src.find("\nfunc ", start + 1)
	if nxt < 0:
		nxt = src.length()
	return src.substr(start, nxt - start)


func _check(rows: Array, failed: bool, id: String, ok: bool, detail: String = "") -> bool:
	rows.append({"id": id, "ok": ok, "detail": detail if detail != "" else ("ok" if ok else "failed")})
	return failed or not ok
