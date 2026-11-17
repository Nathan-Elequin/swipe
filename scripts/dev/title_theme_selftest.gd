extends SceneTree
## Title theme bed: Dungeon Quest on title_theme only; drip stays on title.
## Run: godot --headless --path . --script res://scripts/dev/title_theme_selftest.gd

const OK_MARK := "TITLE_THEME_OK"
const FAIL_MARK := "TITLE_THEME_FAIL"
const AUDIO := preload("res://scripts/audio_fx.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	Engine.time_scale = 8.0

	var map_txt := FileAccess.get_file_as_string("res://data/sfx-map.json")
	var map: Dictionary = JSON.parse_string(map_txt)
	var music: Dictionary = map.get("music", {})
	var beds: Dictionary = music.get("beds", {})
	var states: Dictionary = music.get("states", {})

	failed = _check(rows, failed, "map.has_title_theme", beds.has("title_theme")) or failed
	failed = _check(rows, failed, "map.title_still_drip", str(beds.get("title", {}).get("file", "")) == "music") or failed
	failed = _check(
		rows, failed, "map.title_theme_file",
		str(beds.get("title_theme", {}).get("file", "")) == "music_title"
	) or failed
	failed = _check(
		rows, failed, "map.title_theme_loop_offset",
		is_equal_approx(float(beds.get("title_theme", {}).get("loop_offset", -1.0)), 26.281)
	) or failed
	failed = _check(rows, failed, "map.states.title", str(states.get("title", "")) == "title_theme") or failed
	failed = _check(rows, failed, "map.states.draft", str(states.get("draft", "")) == "title") or failed
	failed = _check(rows, failed, "map.states.tutorial", str(states.get("tutorial", "")) == "title") or failed
	failed = _check(
		rows, failed, "map.states.challenge_setup",
		str(states.get("challenge_setup", "")) == "title"
	) or failed
	failed = _check(rows, failed, "map.states.credits", str(states.get("credits", "")) == "title_theme") or failed
	failed = _check(
		rows, failed, "map.no_resume",
		not bool(beds.get("title_theme", {}).get("resume_position", false))
	) or failed

	var root := get_root()
	var sfx = AUDIO.new()
	root.add_child(sfx)
	if sfx.has_method("setup"):
		sfx.setup()

	failed = _check(rows, failed, "runtime.has_menu", sfx.has_method("music_title_menu")) or failed
	if sfx.has_method("music_title_menu"):
		sfx.music_title_menu()
	await _wait_s(0.2)
	failed = _check(rows, failed, "runtime.menu_bed", String(sfx.current_bed()) == "title_theme") or failed
	var stream: Variant = sfx.music.stream if sfx.music != null else null
	failed = _check(rows, failed, "runtime.stream_loaded", stream is AudioStreamOggVorbis) or failed
	if stream is AudioStreamOggVorbis:
		var ogg := stream as AudioStreamOggVorbis
		failed = _check(rows, failed, "runtime.loop", ogg.loop) or failed
		failed = _check(
			rows, failed, "runtime.loop_offset",
			is_equal_approx(ogg.loop_offset, 26.281)
		) or failed

	if sfx.has_method("music_title"):
		sfx.music_title()
	await _wait_s(0.2)
	failed = _check(rows, failed, "runtime.drip_bed", String(sfx.current_bed()) == "title") or failed

	if sfx.has_method("start_music"):
		sfx.start_music()
	await _wait_s(0.2)
	failed = _check(rows, failed, "runtime.start_music_menu", String(sfx.current_bed()) == "title_theme") or failed

	for row in rows:
		print(row)
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _check(rows: Array, failed: bool, id: String, ok: bool) -> bool:
	rows.append("%s %s" % ["PASS" if ok else "FAIL", id])
	return failed or not ok


func _wait_s(sec: float) -> void:
	await create_timer(sec).timeout
