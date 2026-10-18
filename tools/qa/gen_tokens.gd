extends SceneTree
## Headless: godot --headless --path . --script res://tools/qa/gen_tokens.gd
## Reads design/visual/tokens.json. Writes scripts/ui/tokens.gd and themes/swipe_theme.tres.
## Does not boot main.gd and does not assign the project theme.

const SRC := "res://design/visual/tokens.json"
const GD_OUT := "res://scripts/ui/tokens.gd"
const THEME_OUT := "res://themes/swipe_theme.tres"

func _init() -> void:
	var code := _run()
	quit(code)


func _run() -> int:
	var parsed: Variant = _read_json(SRC)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("tokens.json did not parse to an object")
		return 1
	var data: Dictionary = parsed
	if str(data.get("font", "")) != "fallback":
		push_error("font must be fallback (ThemeDB.fallback_font only)")
		return 1
	var colors: Dictionary = data.get("colors", {})
	var sizes: Dictionary = data.get("sizes", {})
	var outlines: Dictionary = data.get("outline_widths", {})
	var theme_spec: Dictionary = data.get("theme", {})
	if colors.is_empty() or sizes.is_empty() or outlines.is_empty() or theme_spec.is_empty():
		push_error("tokens.json is missing colors, sizes, outline_widths, or theme")
		return 1
	var default_size := int(data.get("default_font_size", 0))
	if default_size <= 0:
		push_error("default_font_size must be a positive int")
		return 1

	var gd := _script_text(colors, sizes, outlines, default_size)
	if not _write_text(GD_OUT, gd):
		return 1

	var theme := Theme.new()
	# Leave default_font unset so controls use ThemeDB.fallback_font.
	theme.default_font_size = default_size
	for type_name in ["Label", "Button", "RichTextLabel"]:
		if not theme_spec.has(type_name):
			push_error("theme missing %s" % type_name)
			return 1
		var spec: Dictionary = theme_spec[type_name]
		for key in spec.keys():
			var role := str(spec[key])
			if key == "outline_size":
				if not outlines.has(role):
					push_error("unknown outline role %s" % role)
					return 1
				theme.set_constant("outline_size", type_name, int(outlines[role]))
			else:
				if not colors.has(role):
					push_error("unknown color role %s" % role)
					return 1
				theme.set_color(str(key), type_name, _to_color(colors[role]))
	if theme.default_font != null:
		push_error("default_font must stay empty")
		return 1

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://themes"))
	var err := ResourceSaver.save(theme, THEME_OUT)
	if err != OK:
		push_error("ResourceSaver failed: %s" % err)
		return 1

	var loaded := load(THEME_OUT) as Theme
	if loaded == null or loaded.default_font != null:
		push_error("saved theme missing or has a font")
		return 1
	if loaded.default_font_size != default_size:
		push_error("saved default_font_size mismatch")
		return 1
	var ink := _to_color(colors["ink_on_dark"])
	if loaded.get_color("font_color", "Label") != ink:
		push_error("Label font_color mismatch")
		return 1
	if loaded.get_color("default_color", "RichTextLabel") != ink:
		push_error("RichTextLabel default_color mismatch")
		return 1
	if loaded.get_constant("outline_size", "Button") != int(outlines["title_button"]):
		push_error("Button outline_size mismatch")
		return 1
	var written := FileAccess.get_file_as_string(GD_OUT)
	if not written.begins_with("## generated - do not edit"):
		push_error("tokens.gd header missing")
		return 1
	print("gen_tokens PASS colors=%d sizes=%d font=%s" % [colors.size(), sizes.size(), loaded.default_font])
	return 0


func _script_text(colors: Dictionary, sizes: Dictionary, outlines: Dictionary, default_size: int) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("## generated - do not edit")
	lines.append("## Source: res://design/visual/tokens.json — run tools/qa/gen_tokens.gd")
	lines.append("class_name Tokens")
	lines.append("extends RefCounted")
	lines.append("")
	lines.append("const FONT := \"fallback\"")
	lines.append("const DEFAULT_FONT_SIZE := %d" % default_size)
	lines.append("")
	lines.append("const colors := {")
	for key in colors.keys():
		lines.append("\t\"%s\": %s," % [key, _color_literal(colors[key])])
	lines.append("}")
	lines.append("")
	lines.append("const sizes := {")
	for key in sizes.keys():
		lines.append("\t\"%s\": %d," % [key, int(sizes[key])])
	lines.append("}")
	lines.append("")
	lines.append("const outline_widths := {")
	for key in outlines.keys():
		lines.append("\t\"%s\": %d," % [key, int(outlines[key])])
	lines.append("}")
	lines.append("")
	return "\n".join(lines)


func _color_literal(v: Variant) -> String:
	if typeof(v) == TYPE_STRING:
		return "Color(\"%s\")" % str(v).trim_prefix("#")
	var d: Dictionary = v
	return "Color(%s, %s, %s, %s)" % [d["r"], d["g"], d["b"], d["a"]]


func _to_color(v: Variant) -> Color:
	if typeof(v) == TYPE_STRING:
		return Color(str(v).trim_prefix("#"))
	var d: Dictionary = v
	return Color(float(d["r"]), float(d["g"]), float(d["b"]), float(d["a"]))


func _read_json(path: String) -> Variant:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("could not read %s" % path)
		return null
	return JSON.parse_string(text)


func _write_text(path: String, text: String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("could not write %s (%s)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(text)
	f.close()
	return true
