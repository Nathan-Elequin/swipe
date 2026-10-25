extends SceneTree
## Writes the SP-04 BMFont atlas next to this checkout.


func _initialize() -> void:
	var arrows = load("res://scripts/ui/arrow_glyphs.gd")
	var abs_dir: String = ProjectSettings.globalize_path("res://assets/ui/fonts")
	arrows.write_bundle(abs_dir)
	print("WROTE_ARROW_FONT ", abs_dir)
	quit(0)
