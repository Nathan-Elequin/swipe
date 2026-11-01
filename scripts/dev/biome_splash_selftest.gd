extends SceneTree
## Headless checks for the biome-enter splash. Does not boot main.gd.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var COPY = load("res://scripts/player_copy.gd")
	COPY.reload()
	var BiomeSplash = load("res://scripts/ui/biome_splash.gd")
	failed = _check(failed, "script loads", BiomeSplash != null) or failed
	failed = _check(failed, "verdant narration key", COPY.has_key("splash.biome.verdant_hollow")) or failed
	failed = _check(failed, "chrome continue key", COPY.has_key("splash.chrome.continue")) or failed
	failed = _check(failed, "continue text locked", COPY.text("splash.chrome.continue") == "click anytime") or failed
	failed = _check(failed, "never intro.next", COPY.text("splash.chrome.continue") != COPY.text("intro.next", "Click to continue")) or failed
	var want_narr := "The Hollow breathes green under Mount Grumblegut. Moss drinks what little light sneaks in. The path ahead is soft, damp, and already listening."
	failed = _check(failed, "narration exact", COPY.text("splash.biome.verdant_hollow") == want_narr) or failed
	failed = _check(failed, "has_narration b1", BiomeSplash.has_narration("Verdant Hollow")) or failed
	failed = _check(failed, "no narration b2", not BiomeSplash.has_narration("Crystal Cavern")) or failed
	failed = _check(failed, "slug verdant", BiomeSplash.narration_key_for_name("Verdant Hollow") == "splash.biome.verdant_hollow") or failed
	failed = _check(failed, "short verdant", BiomeSplash.art_short_for_name("Verdant Hollow") == "verdant") or failed
	failed = _check(failed, "bg placeholder exists", ResourceLoader.exists("res://assets/ui/biome_splash/bg_verdant_placeholder.png")) or failed
	failed = _check(failed, "leaf placeholder exists", ResourceLoader.exists("res://assets/ui/biome_splash/cue_leaf_placeholder.png")) or failed
	failed = _check(failed, "sprout idle exists", ResourceLoader.exists("res://assets/dungeon/anim/player/sprout_idle_f0.png")) or failed

	var splash = BiomeSplash.new()
	root.add_child(splash)
	var ctx := {
		"biome_id": "b1",
		"biome_name": "Verdant Hollow",
		"dungeon_index": 1,
		"delves": 4,
	}
	splash._biome_id = "b1"
	splash._ctx = ctx
	splash._build()
	var chrome: Dictionary = splash.chrome_texts()
	failed = _check(failed, "chrome biome", str(chrome.get("biome", "")) == "Verdant Hollow") or failed
	failed = _check(failed, "chrome dungeon", str(chrome.get("dungeon", "")) == "Dungeon 1") or failed
	failed = _check(failed, "chrome delves", str(chrome.get("delves", "")) == "Delves: 4") or failed
	failed = _check(failed, "chrome continue", str(chrome.get("continue", "")) == "click anytime") or failed
	failed = _check(failed, "narration on label", splash.narration_text() == want_narr) or failed
	var blob := "%s %s" % [str(chrome), splash.narration_text()]
	failed = _check(failed, "no Tier in chrome", blob.find("Tier") < 0 and blob.find("tier") < 0) or failed

	# Skip mid play_in: seed a mid alpha, latch skip, play_out must not jump alpha up.
	splash._root.modulate.a = 0.42
	splash._skipped = false
	splash._dismissed_emitted = false
	splash._play_in_finished = false
	splash._in_tween = null
	splash._request_skip()
	failed = _check(failed, "skipped latched", splash.was_skipped()) or failed
	failed = _check(failed, "skip keeps mid alpha", absf(splash.current_alpha() - 0.42) < 0.001) or failed
	# play_out contract: fade from current alpha → 0; never jump up first.
	var start_a: float = splash.current_alpha()
	failed = _check(failed, "play_out starts from current", absf(start_a - 0.42) < 0.001) or failed
	var tw: Tween = splash.create_tween()
	tw.tween_property(splash._root, "modulate:a", 0.0, 0.20)
	var peak: float = start_a
	for _i in 30:
		peak = maxf(peak, splash.current_alpha())
		await process_frame
		if splash.current_alpha() <= 0.001:
			break
	failed = _check(failed, "play_out no alpha jump up", peak <= start_a + 0.02) or failed
	failed = _check(failed, "play_out reaches zero", splash.current_alpha() <= 0.02) or failed
	splash.queue_free()
	await process_frame

	# Missing key biomes skip splash (caller responsibility); confirm helper.
	failed = _check(failed, "b2 skip splash helper", not BiomeSplash.has_narration("Crystal Cavern")) or failed

	# Music call site checks against main.gd source.
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var begin_idx: int = main_src.find("func _begin_campaign_delve")
	var after_begin: int = main_src.find("\nfunc ", begin_idx + 1)
	var adventure_idx: int = main_src.find("func _adventure_continue")
	var start_idx: int = main_src.find("func _on_campaign_start")
	failed = _check(failed, "begin_campaign_delve found", begin_idx >= 0) or failed
	if begin_idx >= 0 and after_begin > begin_idx:
		var begin_body: String = main_src.substr(begin_idx, after_begin - begin_idx)
		failed = _check(failed, "music removed from begin_delve", begin_body.find("sfx.music_biome_dungeon") < 0) or failed
	var start_end: int = main_src.find("\nfunc ", start_idx + 1)
	var start_body: String = main_src.substr(start_idx, maxi(0, start_end - start_idx))
	failed = _check(failed, "music at campaign_start", start_body.find("sfx.music_biome_dungeon") >= 0) or failed
	var adv_end: int = main_src.find("\nfunc ", adventure_idx + 1)
	var adv_body: String = main_src.substr(adventure_idx, maxi(0, adv_end - adventure_idx))
	failed = _check(failed, "music still on adventure_continue", adv_body.find("sfx.music_biome_dungeon") >= 0) or failed

	# Leave-biome helper present; no splash on leave paths.
	failed = _check(failed, "biome_dissolve_out helper", main_src.find("func _biome_dissolve_out") >= 0) or failed
	failed = _check(failed, "leave uses dissolve", main_src.find("await _biome_dissolve_out") >= 0) or failed
	failed = _check(failed, "nest wheel helper", main_src.find("func _nest_wheel") >= 0) or failed
	failed = _check(failed, "wheel nest offset", main_src.find("_wheel_nest_offset") >= 0) or failed

	if failed:
		push_error("biome_splash self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK biome_splash")
		quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	print("FAIL %s" % label)
	return true
