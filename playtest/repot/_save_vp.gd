extends Node
## Local-only helper for repot PNG dumps. Not used in exports.

var out_dir: String = ""
var t0_ms: int = 0
var marks: Array = []
var names: Array = []
var next_i: int = 0
var results: PackedStringArray = []


func arm(p_out_dir: String, p_marks: Array, p_names: Array) -> void:
	out_dir = p_out_dir
	marks = p_marks
	names = p_names
	next_i = 0
	t0_ms = Time.get_ticks_msec()
	set_process(true)


func _process(_dt: float) -> void:
	if next_i >= names.size():
		set_process(false)
		return
	var elapsed: int = Time.get_ticks_msec() - t0_ms
	if elapsed < int(marks[next_i]):
		return
	var fname: String = str(names[next_i])
	var path: String = out_dir.path_join(fname)
	var vp := get_viewport()
	var tex: ViewportTexture = vp.get_texture() if vp else null
	if tex == null:
		results.append("%s no-tex" % fname)
		next_i += 1
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		results.append("%s empty" % fname)
		next_i += 1
		return
	var err: Error = img.save_png(path)
	if err != OK:
		results.append("%s err=%s" % [fname, err])
	else:
		results.append("%s ok %sx%s" % [fname, img.get_width(), img.get_height()])
	next_i += 1
