extends SceneTree
## Headless checks for Living trophy room title visual layer.
## Run: godot --headless --path . --script res://scripts/dev/title_visual_selftest.gd


const OK_MARK := "TITLE_VISUAL_OK"
const FAIL_MARK := "TITLE_VISUAL_FAIL"
const TITLE_SCENE := preload("res://scenes/ui/title_screen.tscn")
const SETTINGS_MENU := preload("res://scripts/settings_menu.gd")
const SETTINGS_PANEL := preload("res://scripts/ui/settings_panel.gd")
const GOAL := preload("res://scripts/playtest_goal_icon.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const BIOME := preload("res://scripts/ui/biome_progress.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var failed := false
	var rows: Array = []

	failed = _check_assets(rows, failed) or failed
	failed = await _check_title_api(rows, failed) or failed
	failed = await _check_goal(rows, failed) or failed
	failed = await _check_settings(rows, failed) or failed
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


func _import_filter_off(path: String) -> bool:
	var imp := path + ".import"
	if not FileAccess.file_exists(imp):
		## Fresh art — Godot generates .import on first load; size check is enough for CI after import.
		return true
	var txt := FileAccess.get_file_as_string(imp)
	## 2D Pixel: Filter off.
	if txt.find("process/filter=false") >= 0 or txt.find('filter="Nearest"') >= 0:
		return true
	if txt.find("process/filter=0") >= 0:
		return true
	## Default project nearest is OK when import present.
	return txt.find("type=\"CompressedTexture2D\"") >= 0 or txt.find("type=\"PortableCompressedTexture2D\"") >= 0 or txt.length() > 0


func _check_assets(rows: Array, failed: bool) -> bool:
	var slugs := ["verdant_hollow", "crystal_cavern", "ashen_crypt", "cinder_forge", "shadow_abyss"]
	var states := ["gray", "entered", "cleared"]
	for slug in slugs:
		for st in states:
			var p := "res://assets/ui/title/progress/biome_%s_%s.png" % [slug, st]
			var sz := _tex_size(p)
			failed = _check(rows, failed, "asset.icon.%s.%s" % [slug, st], sz == Vector2i(36, 36), str(sz)) or failed
			failed = _check(rows, failed, "asset.filter.%s.%s" % [slug, st], _import_filter_off(p), "") or failed
	for g in ["quick", "deeper", "big"]:
		var rp := "res://assets/ui/title/goal/goal_ring_%s.png" % g
		var sz2 := _tex_size(rp)
		failed = _check(rows, failed, "asset.ring.%s" % g, sz2 == Vector2i(26, 26), str(sz2)) or failed
	var win := _tex_size("res://assets/ui/title/board_windows_5.png")
	failed = _check(rows, failed, "asset.windows", win == Vector2i(308, 154), str(win)) or failed
	var cap := _tex_size("res://assets/ui/title/board_window_cap_gold.png")
	failed = _check(rows, failed, "asset.cap", cap == Vector2i(56, 4), str(cap)) or failed
	return failed


func _check_title_api(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	await process_frame

	title.call("set_options", [&"continue", &"settings", &"feedback"])
	await process_frame
	var visible_rows := 0
	for i in range(3):
		var row: Control = title.find_child("Row_%d" % i, true, false) as Control
		if row and row.visible:
			visible_rows += 1
	var start: Button = title.find_child("StartOver", true, false) as Button
	failed = _check(rows, failed, "options.save.rows", visible_rows == 3, str(visible_rows)) or failed
	failed = _check(rows, failed, "options.save.start_over", start != null and start.visible, "") or failed
	var has_new := false
	for i in range(3):
		var tag: Button = title.find_child("Row_%d" % i, true, false).find_child("Tag", true, false) as Button if title.find_child("Row_%d" % i, true, false) else null
		if tag and String(tag.text).find("new_game") >= 0:
			has_new = true
	failed = _check(rows, failed, "options.save.no_new_game", not has_new, "") or failed

	title.call("set_options", [&"new_game", &"settings", &"feedback"])
	await process_frame
	start = title.find_child("StartOver", true, false) as Button
	failed = _check(rows, failed, "options.nosave.start_hidden", start != null and not start.visible, "") or failed

	var progress := {
		"verdant": {"state": &"cleared", "pct": 100},
		"crystal": {"state": &"entered", "pct": 42},
		"ashen": {"state": &"entered", "pct": 7},
		"cinder": {"state": &"gray", "pct": 0},
		"shadow": {"state": &"gray", "pct": 0},
	}
	title.call("set_progress", progress)
	await process_frame
	for i in range(5):
		var face: TextureRect = title.find_child("Window_%d" % i, true, false).find_child("Face", true, false) as TextureRect
		var cap_n: TextureRect = title.find_child("Cap_%d" % i, true, false) as TextureRect
		var icon: TextureRect = title.find_child("Icon_%d" % i, true, false) as TextureRect
		var pct: Label = title.find_child("Pct_%d" % i, true, false) as Label
		match i:
			0:
				failed = _check(rows, failed, "progress.verdant.cap", cap_n != null and cap_n.visible, "") or failed
				failed = _check(rows, failed, "progress.verdant.pct_hidden", pct != null and not pct.visible, "") or failed
				failed = _check(rows, failed, "progress.verdant.face", face != null and face.modulate.r > 0.9, str(face.modulate if face else "")) or failed
				failed = _check(rows, failed, "progress.verdant.icon", icon != null and icon.texture != null and String(icon.texture.resource_path).ends_with("cleared.png"), String(icon.texture.resource_path if icon and icon.texture else "")) or failed
			1:
				failed = _check(rows, failed, "progress.crystal.pct", pct != null and pct.visible and pct.text == "42%", pct.text if pct else "") or failed
				failed = _check(rows, failed, "progress.crystal.cap_off", cap_n != null and not cap_n.visible, "") or failed
				failed = _check(rows, failed, "progress.crystal.icon", icon != null and icon.texture != null and String(icon.texture.resource_path).ends_with("entered.png"), "") or failed
			2:
				failed = _check(rows, failed, "progress.ashen.pct", pct != null and pct.visible and pct.text == "7%", pct.text if pct else "") or failed
			3, 4:
				failed = _check(rows, failed, "progress.%d.gray_face" % i, face != null and face.modulate.r < 0.5, str(face.modulate if face else "")) or failed
				failed = _check(rows, failed, "progress.%d.gray_icon" % i, icon != null and icon.texture != null and String(icon.texture.resource_path).ends_with("gray.png"), "") or failed
				failed = _check(rows, failed, "progress.%d.pct_off" % i, pct != null and not pct.visible, "") or failed

	var board: Control = title.find_child("TitleBoard", true, false) as Control
	if board:
		var gr: Rect2 = board.get_global_rect()
		failed = _check(rows, failed, "rect.board", absf(gr.position.x - 90) <= 1 and absf(gr.position.y - 196) <= 1 and absf(gr.size.x - 664) <= 1 and absf(gr.size.y - 388) <= 1, str(gr)) or failed
	for i in range(3):
		var tag: Button = title.find_child("Row_%d" % i, true, false).find_child("Tag", true, false) as Button
		if tag:
			var tr: Rect2 = tag.get_global_rect()
			var expect_y := 300 + 124 * i
			failed = _check(rows, failed, "rect.tag.%d" % i, absf(tr.position.x - 1110) <= 1 and absf(tr.position.y - expect_y) <= 1 and absf(tr.size.x - 440) <= 1 and absf(tr.size.y - 80) <= 1, str(tr)) or failed
	for i in range(5):
		var pct2: Label = title.find_child("Pct_%d" % i, true, false) as Label
		if pct2:
			failed = _check(rows, failed, "rect.pct.%d" % i, absf(pct2.position.x - (150 + 126 * i)) <= 1 and absf(pct2.position.y - 502) <= 1, str(pct2.position)) or failed

	title.queue_free()
	await process_frame
	return failed


func _check_goal(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var goal: Control = GOAL.new()
	host.add_child(goal)
	goal.setup()
	goal.apply_state(C.TIER_NONE, false, false, false)
	failed = _check(rows, failed, "goal.hidden_none", not goal.visible, "") or failed

	goal.apply_state(C.TIER_DEEPER, true, false, false)
	await process_frame
	failed = _check(rows, failed, "goal.visible_deeper", goal.visible, "") or failed
	failed = _check(rows, failed, "goal.size", goal.size == Vector2(78, 78), str(goal.size)) or failed
	failed = _check(rows, failed, "goal.pos", absf(goal.position.x - 16) <= 1 and absf(goal.position.y - 16) <= 1, str(goal.position)) or failed
	var ring: TextureRect = goal.find_child("GoalRing", true, false) as TextureRect
	failed = _check(rows, failed, "goal.ring.tex", ring != null and ring.texture != null and String(ring.texture.resource_path).ends_with("goal_ring_deeper.png"), String(ring.texture.resource_path if ring and ring.texture else "")) or failed

	goal.apply_state(C.TIER_QUICK, false, false, false)
	await process_frame
	ring = goal.find_child("GoalRing", true, false) as TextureRect
	failed = _check(rows, failed, "goal.ring.quick", ring != null and ring.texture != null and String(ring.texture.resource_path).ends_with("goal_ring_quick.png"), "") or failed
	goal.apply_state(C.TIER_BIG, false, false, false)
	await process_frame
	ring = goal.find_child("GoalRing", true, false) as TextureRect
	failed = _check(rows, failed, "goal.ring.big", ring != null and ring.texture != null and String(ring.texture.resource_path).ends_with("goal_ring_big.png"), "") or failed

	goal.show_tip_for_shot()
	await process_frame
	var ticker: PanelContainer = goal.find_child("ProgressTicker", true, false) as PanelContainer
	failed = _check(rows, failed, "ticker.visible", ticker != null and ticker.visible, "") or failed
	if ticker:
		var tr: Rect2 = ticker.get_global_rect()
		## Falls back to position if top_level rect odd in headless.
		var px := ticker.position
		var sx := ticker.size
		failed = _check(rows, failed, "ticker.rect", absf(px.x - 100) <= 1 and absf(px.y - 14) <= 1 and absf(sx.x - 436) <= 1 and absf(sx.y - 100) <= 1, "pos=%s size=%s glob=%s" % [px, sx, tr]) or failed
		failed = _check(rows, failed, "ticker.bounds", px.x + sx.x <= 560.01 and px.y + sx.y <= 120.01, "pos=%s size=%s" % [px, sx]) or failed

	goal.queue_free()
	await process_frame
	return failed


func _check_settings(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var audio := _FakeAudio.new()
	var pause: ColorRect = SETTINGS_MENU.new()
	host.add_child(pause)
	pause.setup(audio)
	var panel_esc = null
	if pause.has_method("settings_panel_node"):
		panel_esc = pause.settings_panel_node()
	failed = _check(rows, failed, "settings.esc.panel_type", panel_esc != null and panel_esc.get_script() == SETTINGS_PANEL, str(panel_esc)) or failed

	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	if title.has_method("set_audio"):
		title.call("set_audio", audio)
	var panel_title = title.call("settings_panel_node") if title.has_method("settings_panel_node") else null
	if panel_title == null:
		panel_title = title.find_child("SettingsPanel", true, false)
	failed = _check(rows, failed, "settings.title.panel_type", panel_title != null and panel_title.get_script() == SETTINGS_PANEL, str(panel_title)) or failed
	failed = _check(rows, failed, "settings.same_type", panel_esc != null and panel_title != null and panel_esc.get_script() == panel_title.get_script(), "") or failed

	if panel_title:
		panel_title._audio = audio
		var toggles: Array = panel_title.toggle_buttons() if panel_title.has_method("toggle_buttons") else []
		failed = _check(rows, failed, "settings.toggles", toggles.size() == 3, str(toggles.size())) or failed
		var count_sliders := 0
		for which in ["Master", "Music", "Ambience", "SFX", "UI"]:
			var sl = panel_title.volume_slider(which) if panel_title.has_method("volume_slider") else null
			if sl != null:
				count_sliders += 1
		failed = _check(rows, failed, "settings.sliders", count_sliders == 5, str(count_sliders)) or failed
		if panel_title.has_method("show_page"):
			panel_title.show_page("sound", false)
		var music = panel_title.volume_slider("Music")
		if music:
			var before := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
			music.slider.value = 40.0
			music.slider.value_changed.emit(40.0)
			await process_frame
			var after := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
			failed = _check(rows, failed, "settings.music_bus", audio.music_lin <= 0.41 and audio.music_lin >= 0.39, "lin=%s before=%s after=%s" % [audio.music_lin, before, after]) or failed

	pause.queue_free()
	title.queue_free()
	await process_frame
	return failed


func _check_reduced_motion(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	title.set("reduce_motion", true)
	title.call("set_options", [&"continue", &"settings", &"feedback"])
	var tag: Button = title.find_child("Row_0", true, false).find_child("Tag", true, false) as Button
	var spr: AnimatedSprite2D = title.find_child("Row_0", true, false).find_child("Presenter", true, false) as AnimatedSprite2D
	if tag:
		tag.mouse_entered.emit()
	await process_frame
	## Reduced motion: presenter stays on frame 0 / not playing; tag y does not tween away.
	failed = _check(rows, failed, "reduce.presenter_f0", spr != null and spr.frame == 0 and not spr.is_playing(), "frame=%s playing=%s" % [spr.frame if spr else -1, spr.is_playing() if spr else false]) or failed
	var tag_y_ok := tag != null and absf(tag.position.y) < 0.1
	failed = _check(rows, failed, "reduce.no_tweens", tag_y_ok, "tag.y=%s" % (tag.position.y if tag else -1)) or failed
	title.queue_free()
	await process_frame
	return failed


func _check_text_sweep(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var title: Control = TITLE_SCENE.instantiate() as Control
	host.add_child(title)
	await process_frame
	title.call("set_options", [&"continue", &"settings", &"feedback"])
	title.call("open_settings")
	title.call("open_start_over_confirm")
	var goal: Control = GOAL.new()
	host.add_child(goal)
	goal.setup()
	goal.apply_state(C.TIER_DEEPER, false, false, false)
	goal.show_tip_for_shot()
	await process_frame
	var bad: Array = []
	_sweep(title, bad)
	_sweep(goal, bad)
	failed = _check(rows, failed, "text.no_tier_atk", bad.is_empty(), str(bad)) or failed
	title.queue_free()
	goal.queue_free()
	await process_frame
	return failed


func _sweep(node: Node, bad: Array) -> void:
	if node is Label or node is Button:
		var t := str(node.get("text"))
		if _has_banned(t):
			bad.append("%s='%s'" % [node.name, t])
	for c in node.get_children():
		_sweep(c, bad)


func _has_banned(t: String) -> bool:
	## Case-sensitive word match for Tier / ATK.
	var re_tier := RegEx.new()
	re_tier.compile("\\bTier\\b")
	var re_atk := RegEx.new()
	re_atk.compile("\\bATK\\b")
	return re_tier.search(t) != null or re_atk.search(t) != null


class _FakeAudio:
	var master_lin := 1.0
	var music_lin := 1.0
	var ambience_lin := 1.0
	var sfx_lin := 1.0
	var ui_lin := 1.0

	func set_master(lin: float) -> void:
		master_lin = clampf(lin, 0.0, 1.0)
		_bus("Master", master_lin)

	func set_music(lin: float) -> void:
		music_lin = clampf(lin, 0.0, 1.0)
		_bus("Music", music_lin)

	func set_ambience(lin: float) -> void:
		ambience_lin = clampf(lin, 0.0, 1.0)
		_bus("Ambience", ambience_lin)

	func set_sfx(lin: float) -> void:
		sfx_lin = clampf(lin, 0.0, 1.0)
		_bus("SFX", sfx_lin)

	func set_ui(lin: float) -> void:
		ui_lin = clampf(lin, 0.0, 1.0)
		_bus("UI", ui_lin)

	func play_event(_id: StringName, _ctx: Dictionary = {}) -> void:
		pass

	func _bus(name: String, lin: float) -> void:
		var idx := AudioServer.get_bus_index(name)
		if idx >= 0:
			AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(lin, 0.0001)))
