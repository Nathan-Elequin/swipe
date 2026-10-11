extends SceneTree
## Boot + Dive In screenshots for the Nunito pass. Testing only.

var _n := 0
var _main: Node
var _dived := false


func _initialize() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("qa_font_shot: missing main.tscn")
		quit()
		return
	_main = packed.instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_n += 1
	if _n == 16:
		_save("nunito_boot.png")
		if _main != null and _main.has_method("_quick_start"):
			_main.call("_quick_start")
			_dived = true
		return false
	if _dived and _n == 40:
		_save("nunito_hand.png")
		quit()
		return true
	return false


func _save(filename: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		push_error("qa_font_shot: no viewport image for %s" % filename)
		return
	DirAccess.make_dir_recursive_absolute("res://design/visual/qa")
	img.save_png("res://design/visual/qa/" + filename)
	print("qa_font_shot: saved design/visual/qa/%s %sx%s" % [filename, img.get_width(), img.get_height()])
