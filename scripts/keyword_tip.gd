extends PanelContainer
## Keyword definition (sub-tooltip). Docks to the hover inspect plate, not the speech balloon.

const COPY := preload("res://scripts/player_copy.gd")

var _title
var _lab
var _anchor: Control = null
var _kind: String = ""


func setup() -> void:
	visible = false
	z_index = 141
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("100e0cf5")
	hsb.border_color = Color("e8c36a")
	hsb.border_width_left = 4
	hsb.border_width_top = 2
	hsb.border_width_right = 2
	hsb.border_width_bottom = 2
	hsb.set_corner_radius_all(10)
	hsb.content_margin_left = 14
	hsb.content_margin_right = 14
	hsb.content_margin_top = 10
	hsb.content_margin_bottom = 10
	hsb.shadow_color = Color(0.06, 0.04, 0.03, 0.55)
	hsb.shadow_size = 8
	add_theme_stylebox_override("panel", hsb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	_title = FitLabelBox.make()
	_title.show_frame = false
	_title.padding = 0
	_title.max_font_size = 16
	_title.min_font_size = 12
	_title.font_color = Color("e8c36a")
	_title.set_outline(Color("100e0c"), 3)
	_title.custom_minimum_size = Vector2(220, 22)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	_lab = FitLabelBox.make()
	_lab.show_frame = false
	_lab.padding = 0
	_lab.max_font_size = 15
	_lab.min_font_size = 12
	_lab.font_color = Color("f0e6d8")
	_lab.set_outline(Color("100e0c"), 3)
	_lab.custom_minimum_size = Vector2(220, 36)
	_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_lab)
	set_process(false)


func show_def(msg: String, anchor: Control = null, id: String = "") -> void:
	if _lab == null:
		return
	var t: String = msg.strip_edges()
	if t == "":
		hide_def()
		return
	_anchor = anchor
	_kind = id.strip_edges().to_lower()
	if _kind == "always":
		_title.text = COPY.text("keyword.always", "Always")
		_title.visible = true
		_lab.text = COPY.text("keyword.always_body", "cannot be changed in any other way")
	elif _kind == "swap":
		_title.text = COPY.text("keyword.swap", "Swap")
		_title.visible = true
		_lab.text = COPY.text("keyword.swap_body", "exchange for a random Item of the same Tier")
	else:
		_title.text = ""
		_title.visible = false
		_lab.text = t
	visible = true
	reset_size()
	set_process(true)
	_place()


func hide_def() -> void:
	visible = false
	_anchor = null
	_kind = ""
	set_process(false)


func _process(_delta: float) -> void:
	if not visible:
		set_process(false)
		return
	_place()


func _place() -> void:
	reset_size()
	var sz: Vector2 = get_combined_minimum_size()
	sz.x = maxf(sz.x, 236.0)
	var vp: Vector2 = get_viewport_rect().size
	var anchor := Rect2()
	if _anchor != null and is_instance_valid(_anchor) and _anchor.visible:
		anchor = _anchor.get_global_rect()
		if anchor.size.x < 8.0:
			var asz: Vector2 = _anchor.get_combined_minimum_size()
			anchor.size = asz
	else:
		var mouse: Vector2 = get_global_mouse_position()
		anchor = Rect2(mouse, Vector2(12, 12))
	var gap := 10.0
	var right := Vector2(anchor.end.x + gap, anchor.position.y)
	var left := Vector2(anchor.position.x - sz.x - gap, anchor.position.y)
	var below := Vector2(anchor.position.x, anchor.end.y + 8.0)
	var above := Vector2(anchor.position.x, anchor.position.y - sz.y - 8.0)
	var blocks: Array = [anchor]
	var main: Node = get_tree().root.get_node_or_null("Main")
	if main != null and main.has_method("_log_block_rects"):
		blocks.append_array(main._log_block_rects())
	var pos: Vector2 = preload("res://scripts/ui/tooltip_clamp.gd").place(vp, sz, [right, left, below, above], blocks)
	global_position = pos
	size = sz
