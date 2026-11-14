extends CanvasLayer
## Dev-only keyword definition editor (F1). Hidden in release exports.
## Lists all 23 keywords, edits title/body, live parchment preview, Save / Revert.

const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")

var _root: Control
var _list: ItemList
var _title_edit: LineEdit
var _body_edit: TextEdit
var _count_lab: Label
var _preview_host: Control
var _preview: PanelContainer
var _dirty: Dictionary = {}
var _selected: String = ""
var _status: Label


func _ready() -> void:
	layer = 100
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()


func toggle() -> void:
	if visible:
		hide_editor()
	else:
		show_editor()


func show_editor() -> void:
	if OS.has_feature("release") and not OS.has_feature("editor") and not OS.is_debug_build():
		return
	KeywordDefs.reload(true)
	_dirty.clear()
	_rebuild_list()
	visible = true
	if _list.item_count > 0:
		_list.select(0)
		_on_select(0)


func hide_editor() -> void:
	visible = false
	if _preview != null and _preview.has_method("hide_def"):
		_preview.set("_pinned", false)
		_preview.hide_def()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.05, 0.03, 0.02, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	var panel := PanelContainer.new()
	panel.position = Vector2(80, 60)
	panel.size = Vector2(1520, 920)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410f5")
	sb.border_color = Color("e8c36a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sb)
	_root.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var title := Label.new()
	title.text = "Keyword definitions (dev)"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("e8c36a"))
	head.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "Close (F1)"
	close_btn.pressed.connect(hide_editor)
	head.add_child(close_btn)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	v.add_child(row)
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(280, 0)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_selected.connect(_on_select)
	row.add_child(_list)
	var edit_col := VBoxContainer.new()
	edit_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	edit_col.add_theme_constant_override("separation", 8)
	row.add_child(edit_col)
	var tlab := Label.new()
	tlab.text = "Title"
	tlab.add_theme_color_override("font_color", Color("c9b9a8"))
	edit_col.add_child(tlab)
	_title_edit = LineEdit.new()
	_title_edit.text_changed.connect(_on_title)
	edit_col.add_child(_title_edit)
	var blab := Label.new()
	blab.text = "Body"
	blab.add_theme_color_override("font_color", Color("c9b9a8"))
	edit_col.add_child(blab)
	_body_edit = TextEdit.new()
	_body_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_body_edit.text_changed.connect(_on_body)
	edit_col.add_child(_body_edit)
	_count_lab = Label.new()
	_count_lab.add_theme_color_override("font_color", Color("a89880"))
	edit_col.add_child(_count_lab)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	edit_col.add_child(btns)
	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_on_save)
	btns.add_child(save_btn)
	var rev_btn := Button.new()
	rev_btn.text = "Revert"
	rev_btn.pressed.connect(_on_revert)
	btns.add_child(rev_btn)
	var teach_btn := Button.new()
	teach_btn.text = "Preview first-sighting"
	teach_btn.pressed.connect(_on_preview_teach)
	btns.add_child(teach_btn)
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.add_theme_color_override("font_color", Color("8ec8a0"))
	btns.add_child(_status)
	_preview_host = Control.new()
	_preview_host.custom_minimum_size = Vector2(340, 0)
	_preview_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(_preview_host)
	var prev_lab := Label.new()
	prev_lab.text = "Live card preview"
	prev_lab.position = Vector2(0, 0)
	prev_lab.add_theme_color_override("font_color", Color("c9b9a8"))
	_preview_host.add_child(prev_lab)
	_preview = KEYWORD_TIP.new()
	_preview_host.add_child(_preview)
	_preview.setup()
	_preview.top_level = false
	_preview.z_index = 2
	_preview.position = Vector2(20, 36)


func _rebuild_list() -> void:
	_list.clear()
	for id in KeywordDefs.all_ids():
		var title: String = KeywordDefs.title_of(id)
		if _dirty.has(id):
			title = str((_dirty[id] as Dictionary).get("title", title))
		var icon_path: String = KeywordDefs.icon_path(id)
		var idx: int = _list.add_item("%s  (%s)" % [title, id])
		if ResourceLoader.exists(icon_path):
			_list.set_item_icon(idx, load(icon_path) as Texture2D)
		_list.set_item_metadata(idx, id)


func _on_select(idx: int) -> void:
	_selected = str(_list.get_item_metadata(idx))
	var entry: Dictionary = _dirty.get(_selected, KeywordDefs.entry(_selected))
	_title_edit.text = str(entry.get("title", ""))
	_body_edit.text = str(entry.get("body", ""))
	_refresh_count()
	_refresh_preview()


func _on_title(t: String) -> void:
	if _selected == "":
		return
	var row: Dictionary = _dirty.get(_selected, KeywordDefs.entry(_selected))
	row["title"] = t
	row["body"] = _body_edit.text
	_dirty[_selected] = row
	_refresh_preview()


func _on_body() -> void:
	if _selected == "":
		return
	var row: Dictionary = _dirty.get(_selected, KeywordDefs.entry(_selected))
	row["title"] = _title_edit.text
	row["body"] = _body_edit.text
	_dirty[_selected] = row
	_refresh_count()
	_refresh_preview()


func _refresh_count() -> void:
	var body: String = _body_edit.text
	var lines: int = body.split("\n").size()
	_count_lab.text = "%d characters · %d line(s)" % [body.length(), lines]


func _refresh_preview() -> void:
	if _preview == null or _selected == "":
		return
	var body: String = _body_edit.text
	_preview.set("_pinned", false)
	_preview.set("_first_sight", false)
	_preview.set("_source", "item")
	_preview.show_def(body, null, _selected, "item")
	_preview.position = Vector2(20, 36)
	_preview.top_level = false


func _on_save() -> void:
	if _selected != "":
		_dirty[_selected] = {"title": _title_edit.text, "body": _body_edit.text}
	var merged: Dictionary = {}
	for id in KeywordDefs.all_ids():
		merged[id] = _dirty.get(id, KeywordDefs.entry(id))
	if KeywordDefs.save_all(merged):
		_dirty.clear()
		_status.text = "Saved data/keyword-defs.json"
		_rebuild_list()
		_refresh_preview()
	else:
		_status.text = "Save failed"


func _on_revert() -> void:
	KeywordDefs.reload(true)
	_dirty.clear()
	_rebuild_list()
	if _selected != "":
		for i in _list.item_count:
			if str(_list.get_item_metadata(i)) == _selected:
				_list.select(i)
				_on_select(i)
				break
	_status.text = "Reverted"


func _on_preview_teach() -> void:
	if _selected == "" or _preview == null:
		return
	if _preview.has_method("preview_first_sighting"):
		_preview.preview_first_sighting(_selected)
		_preview.position = Vector2(20, 36)
		_preview.top_level = false
	_status.text = "Playing first-sighting for %s" % _selected
