extends PanelContainer
## Keyword definition as a small capsule on the monster callout (inspect plate).

const COPY := preload("res://scripts/player_copy.gd")

const PlaytestUx := preload("res://scripts/playtest_ux.gd")

var _title
var _lab
var _col: VBoxContainer
var _mini: PanelContainer
var _anchor: Control = null
var _kind: String = ""
var _gold_sb: StyleBox
var _pinned: bool = false


func setup() -> void:
	visible = false
	z_index = 141
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("100e0cf5")
	hsb.border_color = Color("e8c36a")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(12)
	hsb.content_margin_left = 14
	hsb.content_margin_right = 14
	hsb.content_margin_top = 10
	hsb.content_margin_bottom = 10
	hsb.shadow_color = Color(0.06, 0.04, 0.03, 0.45)
	hsb.shadow_size = 4
	_gold_sb = hsb
	add_theme_stylebox_override("panel", hsb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	_col = col
	var title_fs: Vector2i = PlaytestUx.keyword_tip_title_font()
	var body_fs: Vector2i = PlaytestUx.keyword_tip_body_font()
	var min_sz: Vector2 = PlaytestUx.keyword_tip_min_size()
	_title = FitLabelBox.make()
	_title.show_frame = false
	_title.padding = 0
	_title.max_font_size = title_fs.x
	_title.min_font_size = title_fs.y
	_title.font_color = Color("e8c36a")
	_title.set_outline(Color("100e0c"), 2)
	_title.custom_minimum_size = Vector2(min_sz.x - 28.0, 22)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	_lab = FitLabelBox.make()
	_lab.show_frame = false
	_lab.padding = 0
	_lab.max_font_size = body_fs.x
	_lab.min_font_size = body_fs.y
	_lab.font_color = Color("f0e6d8")
	_lab.set_outline(Color("100e0c"), 2)
	_lab.custom_minimum_size = Vector2(min_sz.x - 28.0, 36)
	_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_lab)
	custom_minimum_size = min_sz
	set_process(false)


func show_def(msg: String, anchor: Control = null, id: String = "") -> void:
	if _lab == null:
		return
	var t: String = msg.strip_edges()
	if t == "":
		hide_def()
		return
	_hide_mini()
	if _gold_sb:
		add_theme_stylebox_override("panel", _gold_sb)
	_anchor = anchor
	_kind = id.strip_edges().to_lower()
	_title.visible = _kind != ""
	_title.text = _kind.capitalize() if _kind != "" else ""
	if _kind == "always":
		_lab.text = COPY.text("keyword.always_body", "cannot be changed in any other way")
	elif _kind == "swap":
		_lab.text = COPY.text("keyword.swap_body", "Swap: trade it for a random item of the same rank (Weak, Tough or Deadly).")
	elif _kind == "loaded":
		_lab.text = COPY.text("status.sling_loaded_tip", "Loaded: your next Attack can hit any monster.")
	elif _kind == "any":
		_lab.text = t
	elif _kind == "eject":
		_lab.text = t
	else:
		_lab.text = t
	_lab.visible = true
	visible = true
	reset_size()
	set_process(true)
	_place()


func pin_def(msg: String, anchor: Control = null, id: String = "") -> void:
	_pinned = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	show_def(msg, anchor, id)


func show_callout(pack: Dictionary, anchor: Control = null, id: String = "") -> void:
	if pack.is_empty():
		hide_def()
		return
	_hide_text()
	_anchor = anchor
	_kind = id.strip_edges().to_lower()
	var clear := StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", clear)
	if _mini == null:
		_mini = (load("res://scripts/hover_panel.gd") as GDScript).new()
		_col.add_child(_mini)
		_mini.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_mini.scale = Vector2(0.7, 0.7)
		_mini.pivot_offset = Vector2.ZERO
	_mini.visible = true
	var body: String = str(pack.get("body", ""))
	var url_rx := RegEx.new()
	if url_rx.compile("\\[url=[^\\]]+\\]|\\[/url\\]") == OK:
		body = url_rx.sub(body, "", true)
	_mini.show_rule(
		str(pack.get("title", "")),
		str(pack.get("value", "")),
		str(pack.get("equation", "")),
		body,
		str(pack.get("warn", "")),
		pack.get("portrait", null),
		str(pack.get("plate_kind", "monster")),
		str(pack.get("card_id", "")),
		pack.get("look", {})
	)
	visible = true
	reset_size()
	set_process(true)
	_place()


func _hide_text() -> void:
	if _title:
		_title.visible = false
	if _lab:
		_lab.visible = false


func _hide_mini() -> void:
	if _mini != null:
		_mini.visible = false
		if _mini.has_method("hide_plate"):
			_mini.hide_plate()


func hide_def() -> void:
	if _pinned:
		return
	visible = false
	_anchor = null
	_kind = ""
	_hide_mini()
	if _gold_sb:
		add_theme_stylebox_override("panel", _gold_sb)
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func unpin() -> void:
	_pinned = false
	hide_def()


func _process(_delta: float) -> void:
	if not visible:
		set_process(false)
		return
	_place()


func _place() -> void:
	reset_size()
	var sz: Vector2 = get_combined_minimum_size()
	var floor_sz: Vector2 = PlaytestUx.keyword_tip_min_size()
	sz.x = maxf(sz.x, floor_sz.x)
	sz.y = maxf(sz.y, floor_sz.y)
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
	var gap := 8.0
	var right := Vector2(anchor.end.x + gap, anchor.position.y)
	var left := Vector2(anchor.position.x - sz.x - gap, anchor.position.y)
	var below := Vector2(anchor.position.x, anchor.end.y + 6.0)
	var above := Vector2(anchor.position.x, anchor.position.y - sz.y - 6.0)
	var blocks: Array = [anchor]
	var main: Node = get_tree().root.get_node_or_null("Main")
	if main != null and main.has_method("_log_block_rects"):
		blocks.append_array(main._log_block_rects())
	var pos: Vector2 = preload("res://scripts/ui/tooltip_clamp.gd").place(vp, sz, [right, left, below, above], blocks)
	global_position = pos
	size = sz
