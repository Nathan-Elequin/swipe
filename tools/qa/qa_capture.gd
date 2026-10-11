extends Object
## Save a full-viewport PNG for the visual-refresh handoff.
## Testing only — not in the Web export.

const OUT_DIR := "res://design/visual/screenshots/current/"


static func side_by_side(tree: SceneTree, mockup_path: String, out_name: String) -> Dictionary:
	if tree == null:
		return {"error": "no tree"}
	var win: Window = tree.root
	if win.get_size() != Vector2i(1680, 1040):
		win.size = Vector2i(1680, 1040)
	var right: Image = win.get_viewport().get_texture().get_image()
	if right == null:
		return {"error": "no image"}
	var left := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	left.fill(Color("1A120E"))
	var mock_ok := false
	if mockup_path != "" and FileAccess.file_exists(mockup_path):
		var mock := Image.new()
		if mock.load(mockup_path) == OK:
			mock.resize(1680, 1040, Image.INTERPOLATE_NEAREST)
			if mock.get_format() != Image.FORMAT_RGBA8:
				mock.convert(Image.FORMAT_RGBA8)
			left = mock
			mock_ok = true
	if right.get_format() != Image.FORMAT_RGBA8:
		right.convert(Image.FORMAT_RGBA8)
	var out := Image.create(3360, 1040, false, Image.FORMAT_RGBA8)
	out.fill(Color("1A120E"))
	out.blit_rect(left, Rect2i(0, 0, left.get_width(), left.get_height()), Vector2i(0, 0))
	out.blit_rect(right, Rect2i(0, 0, right.get_width(), right.get_height()), Vector2i(1680, 0))
	var dest: String = "res://design/visual/qa/" + out_name
	var err: int = out.save_png(dest)
	return {"path": dest, "err": err, "mock": mock_ok, "w": out.get_width(), "h": out.get_height()}


static func save(tree: SceneTree, filename: String, dest_dir: String = OUT_DIR) -> Dictionary:
	if tree == null:
		return {"error": "no tree"}
	var win: Window = tree.root
	if win.get_size() != Vector2i(1680, 1040):
		win.size = Vector2i(1680, 1040)
	var vp: Viewport = win.get_viewport()
	var img: Image = vp.get_texture().get_image()
	if img == null:
		return {"error": "no image"}
	var path: String = dest_dir + filename
	var err: int = img.save_png(path)
	return {
		"path": path,
		"w": img.get_width(),
		"h": img.get_height(),
		"err": err,
		"win": [win.size.x, win.size.y],
		"vp": [vp.size.x, vp.size.y],
	}
