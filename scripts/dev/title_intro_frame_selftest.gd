extends SceneTree
## Headless checks for intro_frame still behind title SubViewport preview.
## Run: godot --headless --path . --script res://scripts/dev/title_intro_frame_selftest.gd


const OK_MARK := "TITLE_INTRO_FRAME_OK"
const FAIL_MARK := "TITLE_INTRO_FRAME_FAIL"
const INTRO := preload("res://scripts/playtest_intro.gd")
const FRAME_PATH := "res://assets/ui/title/intro/intro_frame.png"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var failed := false
	var rows: Array = []

	failed = _check_asset(rows, failed) or failed
	failed = await _check_intro_scene(rows, failed) or failed

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


func _check_asset(rows: Array, failed: bool) -> bool:
	var img := Image.new()
	var err := img.load(FRAME_PATH)
	failed = _check(rows, failed, "asset.load", err == OK, str(err)) or failed
	if err != OK:
		return failed
	failed = _check(rows, failed, "asset.size", img.get_width() == 200 and img.get_height() == 124, "%dx%d" % [img.get_width(), img.get_height()]) or failed
	failed = _check(rows, failed, "asset.filter", _import_filter_off(FRAME_PATH), "") or failed
	failed = _check(rows, failed, "asset.opaque_bbox", _opaque_bbox_nonempty(img), "") or failed
	return failed


func _import_filter_off(path: String) -> bool:
	var imp := path + ".import"
	if not FileAccess.file_exists(imp):
		return true
	var txt := FileAccess.get_file_as_string(imp)
	if txt.find("process/filter=false") >= 0 or txt.find('filter="Nearest"') >= 0:
		return true
	if txt.find("process/filter=0") >= 0:
		return true
	## Godot 4.7 CompressedTexture2D + node-side nearest is enough when mipmaps off.
	return txt.find("mipmaps/generate=false") >= 0


func _opaque_bbox_nonempty(img: Image) -> bool:
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.05:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	return max_x >= min_x and max_y >= min_y


func _check_intro_scene(rows: Array, failed: bool) -> bool:
	var host: Window = get_root()
	var intro = INTRO.new()
	host.add_child(intro)
	intro.setup(null, null, null, null)
	await process_frame
	intro.open_intro()
	## Advance to first title focus beat (index 3).
	while intro.step < 3 and intro.visible:
		intro.call("_advance")
		await process_frame
	await process_frame
	await process_frame

	var still: TextureRect = intro.find_child("IntroStill", true, false) as TextureRect
	failed = _check(rows, failed, "still.exists", still != null, "") or failed
	if still != null:
		failed = _check(rows, failed, "still.visible", still.is_visible_in_tree(), "") or failed
		var sz: Vector2 = still.size
		var w_ok: bool = absf(sz.x - 1176.0) <= 24.0
		var h_ok: bool = absf(sz.y - 736.0) <= 24.0 or absf(sz.y - 730.0) <= 24.0
		failed = _check(rows, failed, "still.size", w_ok and h_ok, str(sz)) or failed

	failed = _check(rows, failed, "no_tier_atk", not _labels_have_tier_or_atk(intro), "") or failed

	var title: Node = intro.find_child("TitlePreview", true, false)
	var preview_ok := title != null and bool(title.get("preview_mode"))
	failed = _check(rows, failed, "subviewport.preview_mode", preview_ok, "") or failed

	var host_sv: SubViewportContainer = intro.find_child("IntroPreviewHost", true, false) as SubViewportContainer
	failed = _check(rows, failed, "subviewport.host", host_sv != null, "") or failed

	intro.queue_free()
	await process_frame
	return failed


func _labels_have_tier_or_atk(root: Node) -> bool:
	var re_tier := RegEx.new()
	re_tier.compile("\\bTier\\b")
	var re_atk := RegEx.new()
	re_atk.compile("\\bATK\\b")
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for c in n.get_children():
			stack.append(c)
		var text := ""
		if n is Label:
			text = (n as Label).text
		elif n is Button:
			text = (n as Button).text
		elif n is RichTextLabel:
			text = (n as RichTextLabel).get_parsed_text()
		if text != "" and (re_tier.search(text) != null or re_atk.search(text) != null):
			return true
	return false
