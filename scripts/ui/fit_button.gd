extends Button
class_name FitButton
## Same shrink / wrap / ellipsis rules as FitLabelBox. Keeps the theme font.
@warning_ignore_start("native_method_override")

@export var min_font_size: int = 16
@export var max_font_size: int = 22

var _last: String = ""
var _last_sz: Vector2 = Vector2.ZERO


func _ready() -> void:
	clip_text = true
	if has_theme_font_override("font"):
		remove_theme_font_override("font")
	_apply()
	resized.connect(_apply)


func _process(_delta: float) -> void:
	if text != _last or size != _last_sz:
		_apply()


func _apply() -> void:
	_last = text
	_last_sz = size
	if has_theme_font_override("font"):
		remove_theme_font_override("font")
	FitLabelBox.fit_button(self, max_font_size, min_font_size)
