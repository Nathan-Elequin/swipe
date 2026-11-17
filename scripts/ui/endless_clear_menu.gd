extends CanvasLayer
## One-button Endless clear: title + Continue. No Leave, no ladder.

signal continue_pressed

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const GOLD := Color("e8c36a")
const CREAM := Color("f0e6d8")

var _btn: Button
var _title: Label
var _live: bool = false


func _ready() -> void:
	layer = 68
	name = "EndlessClearMenu"
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var lock := Control.new()
	lock.name = "Lock"
	lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lock.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(lock)
	var dim := ColorRect.new()
	dim.color = Color("100e0c", 0.35)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock.add_child(dim)
	_title = Label.new()
	_title.name = "Title"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_override("font", ThemeDB.fallback_font)
	_title.add_theme_font_size_override("font_size", 36)
	_title.add_theme_color_override("font_color", CREAM)
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 6)
	_title.position = Vector2(340, 390)
	_title.size = Vector2(1000, 56)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock.add_child(_title)
	_btn = KIT.choice_tag("endless.clear.continue", Vector2(120, 18))
	_btn.position = Vector2(740, 470)
	_btn.pressed.connect(_on_continue)
	lock.add_child(_btn)


func open_menu() -> void:
	_title.text = COPY.text("endless.clear.title", "You cleared this dungeon.")
	if _btn:
		_btn.text = COPY.text("endless.clear.continue", "Continue")
		_btn.disabled = false
	_live = true
	visible = true


func hide_menu() -> void:
	_live = false
	visible = false
	if _btn:
		_btn.disabled = true


func _on_continue() -> void:
	if not _live:
		return
	_live = false
	continue_pressed.emit()
