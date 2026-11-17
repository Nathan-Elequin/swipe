extends SceneTree
## Batch-2 title presenters: 6-frame bows, dirt-free gargoyle, reduced motion, Tier/ATK sweep.
## Run: godot --headless --path . --script res://scripts/dev/title_presenters_v2_selftest.gd


const OK_MARK := "TITLE_PRESENTERS_V2_OK"
const FAIL_MARK := "TITLE_PRESENTERS_V2_FAIL"
const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const PRESENTERS := preload("res://scripts/ui/title_presenters.gd")

const TITLE_ROWS := ["goblin", "gargoyle", "lich"]
const EXPECT_SIZE := {
	"goblin": Vector2i(48, 48),
	"gargoyle": Vector2i(48, 48),
	"lich": Vector2i(64, 64),
}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var failed := false
	var rows: Array = []

	failed = _check_assets(rows, failed) or failed
	failed = _check_lookup(rows, failed) or failed
	failed = _check_dirt(rows, failed) or failed
	failed = await _check_spriteframes(rows, failed) or failed
	failed = await _check_reduced_motion(rows, failed) or failed
	failed = await _check_text_sweep(rows, failed) or failed

	for r in rows:
		print(r)
	if failed:
		print("%s: see rows above" % FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String) -> bool:
	rows.append("%s %s%s" % ["PASS" if ok else "FAIL", name, (": " + detail) if (not ok and detail != "") else ""])
	return failed or not ok


func _tex_size(path: String) -> Vector2i:
	var img := Image.new()
	if img.load(path) != OK:
		return Vector2i(-1, -1)
	return Vector2i(img.get_width(), img.get_height())


func _opaque_bbox(path: String) -> Rect2i:
	var img := Image.new()
	if img.load(path) != OK:
		return Rect2i()
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.2:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _import_filter_off(path: String) -> bool:
	var imp := path + ".import"
	if not FileAccess.file_exists(imp):
		return true
	var txt := FileAccess.get_file_as_string(imp)
	if txt.find("mipmaps/generate=true") >= 0:
		return false
	return txt.find("type=\"CompressedTexture2D\"") >= 0 or txt.length() > 0


func _list_present_monsters() -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open("res://assets/ui/title/presenters")
	if dir == null:
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.ends_with("_present_f0.png"):
			out.append(name.trim_suffix("_present_f0.png"))
		name = dir.get_next()
	dir.list_dir_end()
	out.sort()
	return out


func _check_assets(rows: Array, failed: bool) -> bool:
	var monsters := _list_present_monsters()
	failed = _check(rows, failed, "asset.presenter_count", monsters.size() >= 3, str(monsters.size())) or failed
	for m in monsters:
		var idle_sz := _tex_size("res://assets/dungeon/anim/facing/%s_facing_idle_f0.png" % m)
		for f in range(6):
			var p := "res://assets/ui/title/presenters/%s_present_f%d.png" % [m, f]
			var sz := _tex_size(p)
			var expect := idle_sz if idle_sz.x > 0 else Vector2i(48, 48)
			failed = _check(rows, failed, "asset.%s.f%d.size" % [m, f], sz == expect, "got %s expect %s" % [sz, expect]) or failed
			failed = _check(rows, failed, "asset.%s.f%d.filter" % [m, f], _import_filter_off(p), "") or failed
			var box := _opaque_bbox(p)
			failed = _check(rows, failed, "asset.%s.f%d.bbox" % [m, f], box.size.x > 0 and box.size.y > 0, str(box)) or failed
	for m in TITLE_ROWS:
		var expect: Vector2i = EXPECT_SIZE[m]
		var sz0 := _tex_size("res://assets/ui/title/presenters/%s_present_f0.png" % m)
		failed = _check(rows, failed, "asset.title_row.%s" % m, sz0 == expect, str(sz0)) or failed
	for slug in ["verdant", "crystal", "ashen", "cinder", "shadow"]:
		var pane := "res://assets/ui/title/panes/pane_%s.png" % slug
		var psz := _tex_size(pane)
		failed = _check(rows, failed, "asset.pane.%s" % slug, psz == Vector2i(56, 154), str(psz)) or failed
	return failed


func _check_lookup(rows: Array, failed: bool) -> bool:
	failed = _check(rows, failed, "lookup.b1", PRESENTERS.for_biome("verdant") == "goblin", PRESENTERS.for_biome("verdant")) or failed
	failed = _check(rows, failed, "lookup.b2", PRESENTERS.for_biome("crystal") == "gargoyle", PRESENTERS.for_biome("crystal")) or failed
	failed = _check(rows, failed, "lookup.b3", PRESENTERS.for_biome("ashen") == "zombie", PRESENTERS.for_biome("ashen")) or failed
	failed = _check(rows, failed, "lookup.b4", PRESENTERS.for_biome("cinder") == "imp", PRESENTERS.for_biome("cinder")) or failed
	failed = _check(rows, failed, "lookup.b5", PRESENTERS.for_biome("shadow") == "lich", PRESENTERS.for_biome("shadow")) or failed
	return failed


func _dirt_mound_score(path: String) -> int:
	## Count opaque dirt-brown pixels in the bottom third. Idle gargoyle has a mound (~hundreds);
	## batch-2 present frames should stay near gold-claw noise only.
	var img := Image.new()
	if img.load(path) != OK:
		return -1
	var w := img.get_width()
	var h := img.get_height()
	var y0 := int(h * 2.0 / 3.0)
	var dirt := 0
	for y in range(y0, h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.a < 0.78:
				continue
			var r := int(c.r * 255.0)
			var g := int(c.g * 255.0)
			var b := int(c.b * 255.0)
			## Dirt brown: warm mid-brown, not gold (#FFD84A-ish) and not stone gray.
			var is_gold := r > 200 and g > 160 and b < 120
			var is_dirt := r > 70 and g > 40 and b < 90 and r > g and g > b + 5 and not is_gold
			if is_dirt:
				dirt += 1
	return dirt


func _check_dirt(rows: Array, failed: bool) -> bool:
	var idle_dirt := _dirt_mound_score("res://assets/dungeon/anim/facing/gargoyle_facing_idle_f0.png")
	failed = _check(rows, failed, "dirt.idle_has_mound", idle_dirt > 80, str(idle_dirt)) or failed
	for f in range(6):
		var p := "res://assets/ui/title/presenters/gargoyle_present_f%d.png" % f
		var score := _dirt_mound_score(p)
		## Present frames must not keep the idle dirt mound (batch-2 trimmed it).
		failed = _check(rows, failed, "dirt.present_f%d" % f, score >= 0 and score < 60, "dirt=%d idle=%d" % [score, idle_dirt]) or failed
	return failed


func _check_spriteframes(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	await process_frame
	title.call("set_options", [&"new_game", &"settings", &"feedback"])
	await process_frame
	for i in range(3):
		var row: Control = title.find_child("Row_%d" % i, true, false) as Control
		var spr: AnimatedSprite2D = row.find_child("Presenter", true, false) as AnimatedSprite2D if row else null
		failed = _check(rows, failed, "sf.row%d.exists" % i, spr != null and spr.sprite_frames != null, "") or failed
		if spr == null or spr.sprite_frames == null:
			continue
		var sf: SpriteFrames = spr.sprite_frames
		failed = _check(rows, failed, "sf.row%d.present_count" % i, sf.get_frame_count(&"present") == 6, str(sf.get_frame_count(&"present"))) or failed
		failed = _check(rows, failed, "sf.row%d.present_fps" % i, is_equal_approx(sf.get_animation_speed(&"present"), 10.0), str(sf.get_animation_speed(&"present"))) or failed
		failed = _check(rows, failed, "sf.row%d.present_noloop" % i, not sf.get_animation_loop(&"present"), "") or failed
		failed = _check(rows, failed, "sf.row%d.idle_fps" % i, is_equal_approx(sf.get_animation_speed(&"idle"), 4.0), str(sf.get_animation_speed(&"idle"))) or failed
		## At rest: idle f0, not playing.
		failed = _check(rows, failed, "sf.row%d.rest" % i, spr.animation == &"idle" and spr.frame == 0 and not spr.is_playing(), "anim=%s frame=%s playing=%s" % [spr.animation, spr.frame, spr.is_playing()]) or failed
	## Select plays present once.
	var tag0: Button = title.find_child("Row_0", true, false).find_child("Tag", true, false) as Button
	if tag0:
		tag0.emit_signal("pressed")
		await process_frame
		var spr0: AnimatedSprite2D = title.find_child("Row_0", true, false).find_child("Presenter", true, false) as AnimatedSprite2D
		failed = _check(rows, failed, "sf.select.present", spr0 != null and (spr0.animation == &"present" or spr0.is_playing()), "anim=%s playing=%s" % [spr0.animation if spr0 else "", spr0.is_playing() if spr0 else false]) or failed
	title.queue_free()
	await process_frame
	return failed


func _check_reduced_motion(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	title.set("reduce_motion", true)
	title.call("set_options", [&"new_game", &"settings", &"feedback"])
	await process_frame
	var tag: Button = title.find_child("Row_1", true, false).find_child("Tag", true, false) as Button
	var spr: AnimatedSprite2D = title.find_child("Row_1", true, false).find_child("Presenter", true, false) as AnimatedSprite2D
	if tag:
		tag.emit_signal("focus_entered")
		await process_frame
		tag.emit_signal("pressed")
		await process_frame
	failed = _check(rows, failed, "reduce.presenter_f0", spr != null and spr.frame == 0 and not spr.is_playing(), "frame=%s playing=%s" % [spr.frame if spr else -1, spr.is_playing() if spr else false]) or failed
	title.queue_free()
	await process_frame
	return failed


func _check_text_sweep(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	title.call("set_options", [&"continue", &"settings", &"feedback"])
	title.call("set_progress", {
		"verdant": {"state": &"cleared", "pct": 100},
		"crystal": {"state": &"entered", "pct": 42},
		"ashen": {"state": &"entered", "pct": 7},
		"cinder": {"state": &"gray", "pct": 0},
		"shadow": {"state": &"gray", "pct": 0},
	})
	await process_frame
	var bad: Array[String] = []
	_walk_labels(title, bad)
	failed = _check(rows, failed, "text.no_tier_atk", bad.is_empty(), ",".join(bad)) or failed
	title.queue_free()
	await process_frame
	return failed


func _walk_labels(n: Node, bad: Array[String]) -> void:
	if n is Label or n is Button or n is RichTextLabel:
		var t := ""
		if n is RichTextLabel:
			t = (n as RichTextLabel).get_parsed_text()
		else:
			t = str(n.get("text"))
		if t.find("Tier") >= 0 or t.find("ATK") >= 0 or t.find("atk") >= 0:
			bad.append("%s=%s" % [n.get_path(), t])
	for c in n.get_children():
		_walk_labels(c, bad)
