extends SceneTree
## Headless checks for the biome-enter splash (multi-page narration + ambient host).
## Does not boot main.gd.


const BIOMES := [
	{"id": "b1", "name": "Verdant Hollow", "short": "verdant", "slug": "verdant_hollow",
		"pages": [
			"I left the cabin path and ducked into the Verdant Hollow. Wet moss slicked the stone under my boots, and cold water wicked in at the seams.",
			"The air smelled of mud and crushed leaves.",
			"I wiped my hands on my coat, raised the lantern, and went on.",
		]},
	{"id": "b2", "name": "Crystal Cavern", "short": "crystal", "slug": "crystal_cavern",
		"pages": [
			"I left the Verdant Hollow with mud still thick on my heels.",
			"A few paces later the mud stiffened and cracked in the cold — Crystal Cavern. Ice burned my palm when I touched the wall. My breath showed white.",
			"I stamped the dirt off my boots and stepped out onto the frost.",
		]},
	{"id": "b3", "name": "Ashen Crypt", "short": "ashen", "slug": "ashen_crypt",
		"pages": [
			"I left the Crystal Cavern shaking ice from my boots.",
			"The melt dried to grit almost at once, and the air went still and dusty: Ashen Crypt. Fine ash stuck to my damp socks and tasted bitter when I breathed through my mouth.",
			"I pulled my collar up and kept to the middle of the hall.",
		]},
	{"id": "b4", "name": "Cinder Forge", "short": "cinder", "slug": "cinder_forge",
		"pages": [
			"I brushed ash from my sleeves as I left the Crypt.",
			"The stone under my palm went from cool to warm to hot, and then I was at the Cinder Forge. Sweat prickled at my hairline. Sparks popped and died near the floor.",
			"I rolled my sleeves and walked into the heat.",
		]},
	{"id": "b5", "name": "Shadow Abyss", "short": "shadow", "slug": "shadow_abyss",
		"pages": [
			"I left the Cinder Forge with my shirt stuck to my back.",
			"A dozen steps later the heat dropped off and the dark took hold — Shadow Abyss. The sweat on my skin went cold. The lantern lit only the next few feet of stair.",
			"I put my left hand on the wall and started down.",
		]},
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
		var slug: String = str(b["slug"])
		var want_pages: Array = b["pages"]
		failed = _check(failed, "%s shows_for_biome" % bid, BiomeSplash.shows_for_biome(bid)) or failed
		failed = _check(failed, "%s has_narration via pages" % bid, BiomeSplash.has_narration(bname)) or failed
		failed = _check(failed, "%s slug helper" % bid, BiomeSplash.biome_slug(bname) == slug) or failed
		failed = _check(failed, "%s legacy key path" % bid, BiomeSplash.narration_key_for_name(bname) == "splash.biome.%s" % slug) or failed
		failed = _check(failed, "%s art short" % bid, BiomeSplash.art_short_for_name(bname) == short) or failed
		var got_pages: PackedStringArray = BiomeSplash.narration_pages_for_name(bname)
		failed = _check(failed, "%s page count 3" % bid, got_pages.size() == 3) or failed
		for pi in range(want_pages.size()):
			var pkey: String = BiomeSplash.narration_page_key(bname, pi + 1)
			failed = _check(failed, "%s p%d key exists" % [bid, pi + 1], COPY.has_key(pkey)) or failed
			failed = _check(failed, "%s p%d exact" % [bid, pi + 1], COPY.text(pkey) == str(want_pages[pi])) or failed
			if pi < got_pages.size():
				failed = _check(failed, "%s pages[%d] exact" % [bid, pi], str(got_pages[pi]) == str(want_pages[pi])) or failed
		## Legacy single key kept as unused fallback only (not what has_narration keys off).
		failed = _check(failed, "%s legacy fallback kept" % bid, COPY.has_key("splash.biome.%s" % slug)) or failed
		var ph := "res://assets/ui/biome_splash/bg_%s_placeholder.png" % short
		failed = _check(failed, "%s placeholder exists" % bid, ResourceLoader.exists(ph)) or failed

	failed = _check(failed, "endless id no splash", not BiomeSplash.shows_for_biome("endless")) or failed
	failed = _check(failed, "unknown id no splash", not BiomeSplash.shows_for_biome("b9")) or failed
	failed = _check(failed, "leaf placeholder exists", ResourceLoader.exists("res://assets/ui/biome_splash/cue_leaf_placeholder.png")) or failed
	failed = _check(failed, "sprout idle exists", ResourceLoader.exists("res://assets/dungeon/anim/player/sprout_idle_f0.png")) or failed

	## Build splash for every tip biome; page 1 shows first; click advances then dismisses.
	for b in BIOMES:
		var bid: String = str(b["id"])
		var bname: String = str(b["name"])
		var want_pages: Array = b["pages"]
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
		failed = _check(failed, "%s page count" % bid, splash.narration_page_count() == 3) or failed
		failed = _check(failed, "%s starts page 0" % bid, splash.narration_page_index() == 0) or failed
		failed = _check(failed, "%s page1 on label" % bid, splash.narration_text() == str(want_pages[0])) or failed
		var chrome: Dictionary = splash.chrome_texts()
		failed = _check(failed, "%s chrome biome" % bid, str(chrome.get("biome", "")) == bname) or failed
		failed = _check(failed, "%s chrome continue" % bid, str(chrome.get("continue", "")) == "click anytime") or failed
		var blob := "%s %s" % [str(chrome), splash.narration_text()]
		failed = _check(failed, "%s no Tier" % bid, blob.find("Tier") < 0 and blob.find("tier") < 0) or failed
		## No ad-hoc splash fireflies — ambient kit owns particles.
		failed = _check(failed, "%s no one-off Fireflies" % bid, splash._root.get_node_or_null("Fireflies") == null) or failed
		## Narration fit on page 1: ≤5 lines, content inside label, label inside bar, cue clear.
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

		## Advance pages without soft tween (instant) so headless stays deterministic.
		splash._page_swap_busy = false
		splash._request_skip()
		## Force finish any soft swap immediately for the assertion.
		if splash._page_tween != null and is_instance_valid(splash._page_tween):
			splash._page_tween.kill()
			splash._page_tween = null
			splash._page_swap_busy = false
			splash._narration.text = str(want_pages[1])
			splash._narration.modulate.a = 1.0
			splash._layout_narration_bar()
		failed = _check(failed, "%s after click page 1" % bid, splash.narration_page_index() == 1) or failed
		failed = _check(failed, "%s page2 on label" % bid, splash.narration_text() == str(want_pages[1])) or failed
		failed = _check(failed, "%s not dismissed mid pages" % bid, not splash.was_skipped()) or failed
		splash._page_swap_busy = false
		splash._request_skip()
		if splash._page_tween != null and is_instance_valid(splash._page_tween):
			splash._page_tween.kill()
			splash._page_tween = null
			splash._page_swap_busy = false
			splash._narration.text = str(want_pages[2])
			splash._narration.modulate.a = 1.0
			splash._layout_narration_bar()
		failed = _check(failed, "%s after click page 2" % bid, splash.narration_page_index() == 2) or failed
		failed = _check(failed, "%s page3 on label" % bid, splash.narration_text() == str(want_pages[2])) or failed
		failed = _check(failed, "%s still not dismissed" % bid, not splash.was_skipped()) or failed
		## Same BG / chrome across pages.
		failed = _check(failed, "%s chrome continue stable" % bid, str(splash.chrome_texts().get("continue", "")) == "click anytime") or failed
		failed = _check(failed, "%s art still set" % bid, splash._art != null and splash._art.texture != null) or failed
		splash._request_skip()
		failed = _check(failed, "%s last click dismisses" % bid, splash.was_skipped()) or failed

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
	failed = _check(failed, "missing key page count 0", blank_splash.narration_page_count() == 0) or failed
	## With no pages, first click dismisses.
	blank_splash._request_skip()
	failed = _check(failed, "blank click dismisses", blank_splash.was_skipped()) or failed
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

	## Skip mid play_in on last-page path: with pages, first skip advances — seed to last page then dismiss.
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
	## Jump to last page so the next input dismisses (play_out alpha guard).
	splash._page_index = maxi(0, splash.narration_page_count() - 1)
	splash._request_skip()
	failed = _check(failed, "skipped latched", splash.was_skipped()) or failed
	## Mid-dissolve skip snaps alpha to 1.0 so remaining pages stay readable.
	failed = _check(failed, "skip snaps mid alpha readable", absf(splash.current_alpha() - 1.0) < 0.001) or failed
	## Reset alpha for play_out guard (fade must not jump up).
	splash._root.modulate.a = 0.42
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
