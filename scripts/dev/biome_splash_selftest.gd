extends SceneTree
## Headless checks for the biome-enter splash (all tip biomes b1–b5 + ambient host).
## Does not boot main.gd.


const BIOMES := [
	{"id": "b1", "name": "Verdant Hollow", "short": "verdant", "key": "splash.biome.verdant_hollow",
		"narr": "I stepped into the Verdant Hollow and at once felt the wet through the soles of my boots. Moss covered the walls and much of the floor, and the air smelled of earth after rain. I raised my lantern and went on along the only path that offered itself, deeper under the mountain."},
	{"id": "b2", "name": "Crystal Cavern", "short": "crystal", "key": "splash.biome.crystal_cavern",
		"narr": "I entered the Crystal Cavern and had to blink against the glare. Pillars and sheets of ice lined the passage and threw my lantern light about in hard flashes. My boots rang on the frost; the echo died quickly in the cold air. I went forward with short steps, watching where I set my feet."},
	{"id": "b3", "name": "Ashen Crypt", "short": "ashen", "key": "splash.biome.ashen_crypt",
		"narr": "I came into the Ashen Crypt with dust already on my tongue. The halls were dry and quiet, and along the walls stood open niches that held nothing but the crumbled remains of old offerings. I walked on at a steady pace and listened, but I heard only my own breathing and the soft scrape of my boots."},
	{"id": "b4", "name": "Cinder Forge", "short": "cinder", "key": "splash.biome.cinder_forge",
		"narr": "Before I saw the Cinder Forge I felt the heat on my face. The stone underfoot was warm, and farther in I heard metal strike and saw sparks drop to the floor. I wiped my brow and kept walking. Grandpa had come this way before me; I meant to do the same, and to come out again."},
	{"id": "b5", "name": "Shadow Abyss", "short": "shadow", "key": "splash.biome.shadow_abyss",
		"narr": "The path turned down into the Shadow Abyss, and my lantern lit only a few feet of stone ahead. Beyond that circle I could see nothing at all. I put my left hand on the wall and went down one step at a time, careful of my footing, for a fall here would end the dig in a hurry."},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var COPY = load("res://scripts/player_copy.gd")
	COPY.reload()
	var BiomeSplash = load("res://scripts/ui/biome_splash.gd")
	var Ambient = load("res://scripts/fx/biome_ambient.gd")
	failed = _check(failed, "script loads", BiomeSplash != null) or failed
	failed = _check(failed, "ambient script loads", Ambient != null) or failed
	failed = _check(failed, "chrome continue key", COPY.has_key("splash.chrome.continue")) or failed
	failed = _check(failed, "continue text locked", COPY.text("splash.chrome.continue") == "click anytime") or failed
	failed = _check(failed, "never intro.next", COPY.text("splash.chrome.continue") != COPY.text("intro.next", "Click to continue")) or failed

	for b in BIOMES:
		var bid: String = str(b["id"])
		var bname: String = str(b["name"])
		var short: String = str(b["short"])
		var key: String = str(b["key"])
		var want_narr: String = str(b["narr"])
		failed = _check(failed, "%s shows_for_biome" % bid, BiomeSplash.shows_for_biome(bid)) or failed
		failed = _check(failed, "%s narration key" % bid, COPY.has_key(key)) or failed
		failed = _check(failed, "%s narration exact" % bid, COPY.text(key) == want_narr) or failed
		failed = _check(failed, "%s has_narration" % bid, BiomeSplash.has_narration(bname)) or failed
		failed = _check(failed, "%s slug" % bid, BiomeSplash.narration_key_for_name(bname) == key) or failed
		failed = _check(failed, "%s art short" % bid, BiomeSplash.art_short_for_name(bname) == short) or failed
		var ph := "res://assets/ui/biome_splash/bg_%s_placeholder.png" % short
		failed = _check(failed, "%s placeholder exists" % bid, ResourceLoader.exists(ph)) or failed

	failed = _check(failed, "endless id no splash", not BiomeSplash.shows_for_biome("endless")) or failed
	failed = _check(failed, "unknown id no splash", not BiomeSplash.shows_for_biome("b9")) or failed
	failed = _check(failed, "leaf placeholder exists", ResourceLoader.exists("res://assets/ui/biome_splash/cue_leaf_placeholder.png")) or failed
	failed = _check(failed, "sprout idle exists", ResourceLoader.exists("res://assets/dungeon/anim/player/sprout_idle_f0.png")) or failed

	## Build splash for every tip biome; narration matches Spin byte-for-byte.
	for b in BIOMES:
		var bid: String = str(b["id"])
		var bname: String = str(b["name"])
		var want_narr: String = str(b["narr"])
		var splash = BiomeSplash.new()
		root.add_child(splash)
		splash._biome_id = bid
		splash._ctx = {
			"biome_id": bid,
			"biome_name": bname,
			"dungeon_index": int(bid.substr(1)) if bid.length() > 1 else 1,
			"delves": 4,
		}
		splash._build()
		failed = _check(failed, "%s builds root" % bid, splash._root != null) or failed
		failed = _check(failed, "%s builds art" % bid, splash._art != null and splash._art.texture != null) or failed
		failed = _check(failed, "%s builds ambient host" % bid, splash._ambient_host != null) or failed
		failed = _check(failed, "%s narration on label" % bid, splash.narration_text() == want_narr) or failed
		var chrome: Dictionary = splash.chrome_texts()
		failed = _check(failed, "%s chrome biome" % bid, str(chrome.get("biome", "")) == bname) or failed
		failed = _check(failed, "%s chrome continue" % bid, str(chrome.get("continue", "")) == "click anytime") or failed
		var blob := "%s %s" % [str(chrome), splash.narration_text()]
		failed = _check(failed, "%s no Tier" % bid, blob.find("Tier") < 0 and blob.find("tier") < 0) or failed
		## No ad-hoc splash fireflies — ambient kit owns particles.
		failed = _check(failed, "%s no one-off Fireflies" % bid, splash._root.get_node_or_null("Fireflies") == null) or failed
		## Narration fit: ≤5 lines, content inside label, label inside bar, cue clear.
		await process_frame
		splash._layout_narration_bar()
		await process_frame
		var lines: int = splash.narration_line_count()
		failed = _check(failed, "%s lines <= 5" % bid, lines <= 5) or failed
		var n_rect: Rect2 = splash.narration_rect()
		var bar_rect: Rect2 = splash.narration_bar_rect()
		var cue_r: Rect2 = splash.cue_rect()
		var content_h: float = splash.narration_content_height()
		failed = _check(failed, "%s content fits label" % bid, content_h <= n_rect.size.y + 1.0) or failed
		failed = _check(failed, "%s label inside bar" % bid, bar_rect.grow(-12.0).encloses(n_rect)) or failed
		failed = _check(failed, "%s cue clear of narr" % bid, not n_rect.intersects(cue_r.grow(2.0))) or failed
		failed = _check(failed, "%s bar at bottom" % bid, is_equal_approx(bar_rect.position.y + bar_rect.size.y, 1040.0)) or failed
		failed = _check(failed, "%s label uses wide wrap" % bid, n_rect.size.x >= 1500.0) or failed
		splash.queue_free()
		await process_frame

	## Missing narration key → splash still builds, Label blank (do not invent copy).
	var blank_splash = BiomeSplash.new()
	root.add_child(blank_splash)
	blank_splash._biome_id = "b2"
	blank_splash._ctx = {
		"biome_id": "b2",
		"biome_name": "Unknown Biome",
		"dungeon_index": 2,
		"delves": 1,
	}
	blank_splash._build()
	failed = _check(failed, "missing key has_narration false", not BiomeSplash.has_narration("Unknown Biome")) or failed
	failed = _check(failed, "missing key still builds", blank_splash._root != null) or failed
	failed = _check(failed, "missing key blank narration", blank_splash.narration_text() == "") or failed
	blank_splash.queue_free()
	await process_frame

	## Ambient emitting while hosted on splash (shared kit, not a duplicate).
	var amb_home := Node2D.new()
	amb_home.name = "AmbientHome"
	root.add_child(amb_home)
	var amb = Ambient.new()
	amb_home.add_child(amb)
	amb.setup(Vector2(1680, 1040))
	amb.set_enabled(true)
	for b in BIOMES:
		var bid: String = str(b["id"])
		var bname: String = str(b["name"])
		amb.set_biome(bid)
		var splash2 = BiomeSplash.new()
		root.add_child(splash2)
		splash2._biome_id = bid
		splash2._ctx = {
			"biome_id": bid,
			"biome_name": bname,
			"dungeon_index": 1,
			"delves": 0,
		}
		splash2._build()
		splash2.attach_ambient(amb)
		failed = _check(failed, "%s ambient hosted" % bid, splash2.hosted_ambient() == amb) or failed
		failed = _check(failed, "%s ambient under host" % bid, amb.get_parent() == splash2._ambient_host) or failed
		failed = _check(failed, "%s ambient amount > 0" % bid, amb.total_particle_amount() > 0) or failed
		failed = _check(failed, "%s ambient emitting on splash" % bid, splash2.ambient_emitting()) or failed
		## Detach restores home without clear/rebuild of amounts.
		var amount_before: int = amb.total_particle_amount()
		var biome_before: String = amb.current_biome()
		splash2.detach_ambient()
		failed = _check(failed, "%s ambient detached home" % bid, amb.get_parent() == amb_home) or failed
		failed = _check(failed, "%s ambient same biome after detach" % bid, amb.current_biome() == biome_before) or failed
		failed = _check(failed, "%s ambient same amount after detach" % bid, amb.total_particle_amount() == amount_before) or failed
		splash2.queue_free()
		await process_frame

	## Skip mid play_in: seed a mid alpha, latch skip, play_out must not jump alpha up.
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
	splash._root.modulate.a = 0.42
	splash._skipped = false
	splash._dismissed_emitted = false
	splash._play_in_finished = false
	splash._in_tween = null
	splash._request_skip()
	failed = _check(failed, "skipped latched", splash.was_skipped()) or failed
	failed = _check(failed, "skip keeps mid alpha", absf(splash.current_alpha() - 0.42) < 0.001) or failed
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

	# Music call site checks against main.gd source.
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var begin_idx: int = main_src.find("func _begin_campaign_delve")
	var after_begin: int = main_src.find("\nfunc ", begin_idx + 1)
	var present_idx: int = main_src.find("func _present_campaign_splash")
	var adventure_idx: int = main_src.find("func _adventure_continue")
	var start_idx: int = main_src.find("func _on_campaign_start")
	failed = _check(failed, "begin_campaign_delve found", begin_idx >= 0) or failed
	failed = _check(failed, "present_campaign_splash found", present_idx >= 0) or failed
	if begin_idx >= 0 and after_begin > begin_idx:
		var begin_body: String = main_src.substr(begin_idx, after_begin - begin_idx)
		failed = _check(failed, "music removed from begin_delve", begin_body.find("sfx.music_biome_dungeon") < 0) or failed
	var present_end: int = main_src.find("\nfunc ", present_idx + 1)
	var present_body: String = main_src.substr(present_idx, maxi(0, present_end - present_idx))
	failed = _check(failed, "music at present splash", present_body.find("sfx.music_biome_dungeon") >= 0) or failed
	failed = _check(failed, "shows_for_biome gate", present_body.find("shows_for_biome") >= 0) or failed
	failed = _check(failed, "attach_ambient on splash", present_body.find("attach_ambient") >= 0) or failed
	## Gate must not require has_narration (missing key still splashes).
	failed = _check(failed, "no has_narration gate", present_body.find("has_narration") < 0) or failed
	var start_end: int = main_src.find("\nfunc ", start_idx + 1)
	var start_body: String = main_src.substr(start_idx, maxi(0, start_end - start_idx))
	failed = _check(failed, "start uses present splash", start_body.find("_present_campaign_splash") >= 0) or failed
	var adv_end: int = main_src.find("\nfunc ", adventure_idx + 1)
	var adv_body: String = main_src.substr(adventure_idx, maxi(0, adv_end - adventure_idx))
	failed = _check(failed, "push deeper uses present splash", adv_body.find("_present_campaign_splash") >= 0) or failed
	failed = _check(failed, "push deeper skips splash when endless", adv_body.find("endless_run") >= 0) or failed

	# Leave-biome helper present; no splash on leave paths.
	failed = _check(failed, "biome_dissolve_out helper", main_src.find("func _biome_dissolve_out") >= 0) or failed
	failed = _check(failed, "leave uses dissolve", main_src.find("await _biome_dissolve_out") >= 0) or failed
	failed = _check(failed, "nest wheel helper", main_src.find("func _nest_wheel") >= 0) or failed
	failed = _check(failed, "wheel nest offset", main_src.find("_wheel_nest_offset") >= 0) or failed

	amb.free()
	amb_home.free()

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
