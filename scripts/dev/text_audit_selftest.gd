extends SceneTree
## Headless proof for text_audit wrap checks. Does not boot main.gd or touch user://.

func _init() -> void:
	var audit = load("res://scripts/dev/text_audit.gd").new()
	var font: Font = ThemeDB.fallback_font
	var hello_w: float = font.get_string_size("hello", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var both_w: float = font.get_string_size("hello world", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var space_w: float = hello_w + 8.0
	print("SPACE_WIDTHS hello=%s both=%s used=%s" % [hello_w, both_w, space_w])
	var bad_mode: Label = _label("WordMode", "Hi", TextServer.AUTOWRAP_WORD, TextServer.OVERRUN_NO_TRIMMING, Vector2(80, 24), 0, font)
	var split: Label = _label("SplitWord", "Supercalifragilistic", TextServer.AUTOWRAP_WORD_SMART, TextServer.OVERRUN_NO_TRIMMING, Vector2(48, 120), 0, font)
	var ellipsis: Label = _label("EllipsisWord", "Supercalifragilistic", TextServer.AUTOWRAP_WORD_SMART, TextServer.OVERRUN_TRIM_ELLIPSIS, Vector2(80, 22), 1, font)
	var spaced: Label = _label("SpaceWrap", "hello world", TextServer.AUTOWRAP_WORD_SMART, TextServer.OVERRUN_NO_TRIMMING, Vector2(space_w, 80), 0, font)
	var cases := [
		{"name": "wrap_mode", "node": bad_mode, "want_wrap": true, "want_mid": false},
		{"name": "mid_word", "node": split, "want_wrap": false, "want_mid": true},
		{"name": "ellipsis", "node": ellipsis, "want_wrap": false, "want_mid": false},
		{"name": "space_wrap", "node": spaced, "want_wrap": false, "want_mid": false},
	]
	var failed := false
	for row in cases:
		var node: Label = row["node"]
		var reasons: PackedStringArray = audit._wrap_reasons(node)
		var joined := ", ".join(reasons)
		var has_wrap := false
		var has_mid := false
		for reason in reasons:
			if str(reason).begins_with("wrap_mode"):
				has_wrap = true
			if str(reason) == "mid_word":
				has_mid = true
		var ok: bool = has_wrap == bool(row["want_wrap"]) and has_mid == bool(row["want_mid"])
		if not ok:
			failed = true
		print("CASE %s path=%s mode=%s reasons=[%s] ok=%s" % [
			row["name"],
			str(node.name),
			audit._autowrap_name(audit._autowrap_of(node)),
			joined,
			ok,
		])
	var space_para := TextParagraph.new()
	space_para.break_flags = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_MANDATORY | TextServer.BREAK_TRIM_EDGE_SPACES
	space_para.width = spaced.size.x
	space_para.add_string(spaced.text, font, 16)
	var space_lines := space_para.get_line_count()
	print("SPACE_LINES %s" % space_lines)
	if space_lines < 2:
		failed = true
		push_error("space wrap did not break onto two lines")
	if failed:
		push_error("text_audit self-test failed")
		_free_all(audit, cases)
		quit(1)
	else:
		print("SELFTEST_OK")
		_free_all(audit, cases)
		quit(0)


func _free_all(audit: Object, cases: Array) -> void:
	if audit is Node:
		(audit as Node).free()
	for row in cases:
		var node: Object = row["node"]
		if node is Node and is_instance_valid(node):
			(node as Node).free()


func _label(node_name: String, text: String, mode: TextServer.AutowrapMode, overrun: TextServer.OverrunBehavior, box: Vector2, max_lines: int, font: Font) -> Label:
	var lab := Label.new()
	lab.name = node_name
	lab.text = text
	lab.autowrap_mode = mode
	lab.text_overrun_behavior = overrun
	lab.max_lines_visible = max_lines
	lab.custom_minimum_size = box
	lab.size = box
	lab.add_theme_font_override("font", font)
	lab.add_theme_font_size_override("font_size", 16)
	return lab
