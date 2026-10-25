extends SceneTree
## Headless proof for SP-02 / SP-04 / SP-05 helpers. Does not boot main.tscn.

const VIEW := preload("res://scripts/ui/view_frame.gd")
const ARROWS := preload("res://scripts/ui/arrow_glyphs.gd")
const VOL := preload("res://scripts/ui/volume_slider.gd")
const AUDIO := preload("res://scripts/audio_fx.gd")


func _initialize() -> void:
	var bad := 0
	bad += _audio_log()
	bad += _slider_steps()
	bad += _glyphs()
	bad += _wide_layout()
	if bad == 0:
		print("WEB_PLATFORM_SELFTEST ok")
		quit(0)
	else:
		print("WEB_PLATFORM_SELFTEST fail ", bad)
		quit(1)


func _audio_log() -> int:
	var fx = AUDIO.new()
	root.add_child(fx)
	fx.log_audio("setup", "boot")
	fx.log_audio("start", "selftest")
	fx.log_audio("stop", "selftest")
	var start_n := 0
	var stop_n := 0
	var has_setup := false
	for row2 in fx.audio_log:
		if str(row2.get("op", "")) == "setup":
			has_setup = true
		if str(row2.get("op", "")) == "start":
			start_n += 1
		if str(row2.get("op", "")) == "stop":
			stop_n += 1
	fx.free()
	if has_setup and start_n >= 1 and stop_n >= 1:
		print("PASS audio_log")
		return 0
	print("FAIL audio_log setup=%s start=%s stop=%s" % [has_setup, start_n, stop_n])
	return 1


func _slider_steps() -> int:
	var ok: bool = VOL.stepped(50.0, 5.0) == 55.0
	ok = ok and VOL.stepped(50.0, -5.0) == 45.0
	ok = ok and VOL.stepped(2.0, -5.0) == 0.0
	ok = ok and VOL.stepped(98.0, 10.0) == 100.0
	ok = ok and VOL.KEY_STEP == 5.0
	ok = ok and VOL.PAGE_STEP == 10.0
	if ok:
		print("PASS slider_steps")
		return 0
	print("FAIL slider_steps")
	return 1


func _glyphs() -> int:
	var empty := FontFile.new()
	var sai := "Flips 2 ↔ 4 after each Item used."
	var shuri := "Move →, then Attack 3."
	var miss: PackedStringArray = ARROWS.missing_from(empty, sai + shuri, false)
	if miss.size() < 2:
		print("FAIL glyphs_flag got=", miss)
		return 1
	var font: FontFile = ARROWS.ensure()
	if font == null or not ARROWS.covers(ARROWS.LEFT) or not ARROWS.covers(ARROWS.RIGHT) or not ARROWS.covers(ARROWS.BOTH):
		print("FAIL glyphs_bundle")
		return 1
	var after: PackedStringArray = ARROWS.missing_from(ThemeDB.fallback_font, sai + shuri, true)
	if after.size() != 0:
		print("FAIL glyphs_after ", after)
		return 1
	print("PASS glyphs")
	return 0


func _wide_layout() -> int:
	var cases: Array = [
		{"win": Vector2(1280, 800), "view": Vector2(1680, 1050)},
		{"win": Vector2(1920, 1080), "view": Vector2(1849, 1040)},
		{"win": Vector2(2560, 1080), "view": Vector2(2466, 1040)},
		{"win": Vector2(3440, 1440), "view": Vector2(2484, 1040)},
	]
	for row in cases:
		var view: Vector2 = row["view"]
		var clip: Rect2 = VIEW.frame_rect(view)
		if not VIEW.next_room_hidden(view, clip):
			print("FAIL cabin_clip ", row["win"], " clip=", clip)
			return 1
		var monster_cx: float = view.x - 200.0
		var sx: float = VIEW.sprout_home_x(monster_cx, 280.0, view)
		if not VIEW.actor_fully_on_screen(Vector2(sx, 320), Vector2(280, 240), view):
			print("FAIL sprout ", row["win"], " x=", sx, " view=", view)
			return 1
		var old_x: float = 1680.0 - monster_cx - 140.0
		if view.x > 2000.0 and old_x >= 8.0:
			print("NOTE old_mirror_still_on_screen win=", row["win"], " old=", old_x)
	print("PASS wide_layout")
	return 0
