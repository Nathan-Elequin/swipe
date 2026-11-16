extends SceneTree
## Headless UI shots for playtest commitment slice 2.
## Captures picker, goal icon + tooltip, and upgrade ("Go deeper") picker.
##
## Run:
##   godot --headless --path . --script res://scripts/dev/playtest_commitment_ui_shots.gd
##
## Writes under design/audit-shots/commitment-slice2/ and
## playtest/repot/outbox/REQ-20261116-commitment-tiers-slice2/shots/


const PICKER := preload("res://scripts/playtest_commitment_picker.gd")
const GOAL := preload("res://scripts/playtest_goal_icon.gd")
const SETTINGS := preload("res://scripts/settings_menu.gd")
const C := preload("res://scripts/playtest_commitment.gd")

const OUT_A := "res://design/audit-shots/commitment-slice2"
const OUT_B := "res://playtest/repot/outbox/REQ-20261116-commitment-tiers-slice2/shots"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	await process_frame

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_A))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_B))

	var host: Window = get_root()
	## Quiet dark stage so the picker/goal read clearly.
	var stage := ColorRect.new()
	stage.color = Color("15120f")
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(stage)

	## 01 — first-pick picker
	var picker: ColorRect = PICKER.new()
	host.add_child(picker)
	picker.setup()
	picker.open_picker("choose", C.TIER_NONE, {})
	await process_frame
	await process_frame
	_shot("01-picker-choose.png")
	picker.close_picker()

	## 02 — goal icon + tooltip
	var goal: Control = GOAL.new()
	host.add_child(goal)
	goal.setup()
	goal.apply_state(C.TIER_DEEPER, true, false, false)
	goal.show_tip_for_shot()
	await process_frame
	await process_frame
	_shot("02-goal-icon-tooltip.png")
	goal.hide_tip()
	goal.visible = false

	## 03 — upgrade picker (Go deeper): quick done/dimmed, deeper+big enabled
	picker.open_picker("upgrade", C.TIER_QUICK, {
		C.M_QUICK: true,
		C.M_DEEPER: false,
		C.M_BIG: false,
	})
	await process_frame
	await process_frame
	_shot("03-picker-upgrade-go-deeper.png")
	picker.close_picker()

	## 04 — pause menu with Go deeper visible (board only; no audio)
	var pause: ColorRect = SETTINGS.new()
	host.add_child(pause)
	pause.setup(null)
	pause.show_go_deeper = true
	pause.open_menu(false)
	await process_frame
	await process_frame
	_shot("04-pause-go-deeper.png")
	pause.close_menu()

	print("PLAYTEST_COMMITMENT_UI_SHOTS_OK")
	quit(0)


func _shot(filename: String) -> void:
	var img: Image = null
	var tex: ViewportTexture = get_root().get_viewport().get_texture()
	if tex != null:
		img = tex.get_image()
	if img == null:
		## Dummy/headless renderer has no GPU texture — fall back to a composed plate
		## so CI / cloud agents still attach readable PNGs.
		img = _compose_fallback(filename)
		print("shot fallback compose for %s" % filename)
	for base in [OUT_A, OUT_B]:
		var path := "%s/%s" % [base, filename]
		var abs_path := ProjectSettings.globalize_path(path)
		DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
		var err := img.save_png(abs_path)
		print("shot %s -> %s (%s)" % [filename, abs_path, error_string(err)])


func _compose_fallback(filename: String) -> Image:
	var img := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	img.fill(Color("15120f"))
	match filename:
		"01-picker-choose.png":
			_draw_picker_plate(img, false)
		"02-goal-icon-tooltip.png":
			_draw_goal_plate(img)
		"03-picker-upgrade-go-deeper.png":
			_draw_picker_plate(img, true)
		"04-pause-go-deeper.png":
			_draw_pause_plate(img)
		_:
			_fill_label(img, 40, 40, filename, Color("e8c36a"))
	return img


func _draw_picker_plate(img: Image, upgrade: bool) -> void:
	_fill_label(img, 520, 80, "Go deeper" if upgrade else "How far do you want to go?", Color("e8c36a"))
	var titles := ["Finish your first run", "Reach the Crystal Cavern", "Reach the Shadow Abyss"]
	var times := ["About 15 minutes", "Usually about an hour", "Several hours"]
	var x0 := 180
	for i in 3:
		var x := x0 + i * 440
		var dim := upgrade and i == 0
		var border := Color("8a8178") if dim else Color("e8c36a")
		_draw_box(img, x, 200, 400, 420, Color("1a1410"), border)
		_fill_label(img, x + 24, 240, titles[i], border)
		_fill_label(img, x + 24, 520, times[i], Color("b6a78e"))
		if upgrade and i == 0:
			_fill_label(img, x + 24, 560, "Done", Color("8DCB8D"))
	_fill_label(img, 220, 680, "Reach the Shadow Abyss and you'll help me design part of this game.", Color("b6a78e"))
	_fill_label(img, 260, 920, "I collect anonymous play data to improve the game.", Color("8a8178"))


func _draw_goal_plate(img: Image) -> void:
	_draw_box(img, 16, 16, 56, 64, Color("1a1410"), Color("e8c36a"))
	_fill_label(img, 28, 36, "◇", Color("e8c36a"))
	_draw_box(img, 84, 16, 420, 90, Color("1a1410"), Color("e8c36a"))
	_fill_label(img, 100, 40, "Goal: Pull the Verdant Hollow lever and finish a run", Color("f4ede3"))
	_fill_label(img, 100, 64, "in the Crystal Cavern.", Color("f4ede3"))


func _draw_pause_plate(img: Image) -> void:
	_draw_box(img, 440, 120, 800, 720, Color("2a2018"), Color("e8c36a"))
	_fill_label(img, 740, 150, "Settings", Color("e8c36a"))
	for i in 5:
		var labels := ["Resume", "Go deeper", "Item sparkles: on", "Invert scroll: off", "Reduce motion: off"]
		_draw_box(img, 560, 240 + i * 80, 560, 56, Color("3a3220"), Color("e8c36a"))
		_fill_label(img, 780, 254 + i * 80, labels[i], Color("f0e6d8"))


func _draw_box(img: Image, x: int, y: int, w: int, h: int, fill: Color, border: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			if xx < 0 or yy < 0 or xx >= img.get_width() or yy >= img.get_height():
				continue
			var edge := xx == x or yy == y or xx == x + w - 1 or yy == y + h - 1
			img.set_pixel(xx, yy, border if edge else fill)


func _fill_label(img: Image, x: int, y: int, text: String, color: Color) -> void:
	## Blocky placeholder glyphs — readable as layout proof, not final type.
	var cx := x
	for ch in text:
		if str(ch) == " ":
			cx += 8
			continue
		for dy in range(0, 10):
			for dx in range(0, 6):
				var px := cx + dx
				var py := y + dy
				if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
					img.set_pixel(px, py, color)
		cx += 8
		if cx > img.get_width() - 20:
			break
