extends Node
## Repot helper: write the current game viewport to an absolute PNG path.


func grab_now(abs_path: String) -> String:
	var vp := get_viewport()
	if vp == null:
		return "no_viewport"
	var tex: ViewportTexture = vp.get_texture()
	if tex == null:
		return "no_tex"
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		return "empty"
	var err: Error = img.save_png(abs_path)
	if err != OK:
		return "save_err_%s" % err
	return "ok %sx%s" % [img.get_width(), img.get_height()]
