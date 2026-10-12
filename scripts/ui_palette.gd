extends RefCounted
class_name UiPalette
## Utility type (names, descriptions, stats). Flavor type stays Pixelify / VT323 / Silkscreen.
## Names and body copy use Barlow Semi Condensed. Numbers stay Nunito Bold / ExtraBold.

const FONT_REGULAR := "res://assets/ui/fonts/Nunito-Regular.ttf"
const FONT_SEMIBOLD := "res://assets/ui/fonts/Nunito-SemiBold.ttf"
const FONT_BOLD := "res://assets/ui/fonts/Nunito-Bold.ttf"
const FONT_EXTRABOLD := "res://assets/ui/fonts/Nunito-ExtraBold.ttf"
const FONT_NAME := "res://assets/ui/fonts/BarlowSemiCondensed-SemiBold.ttf"
const FONT_BODY := "res://assets/ui/fonts/BarlowSemiCondensed-Regular.ttf"
const FONT_BODY_BOLD := "res://assets/ui/fonts/BarlowSemiCondensed-Bold.ttf"
const FONT_PIXEL := "res://assets/ui/fonts/PixelifySans-Bold.ttf"
const FONT_SILK := "res://assets/ui/fonts/Silkscreen-Bold.ttf"
const FONT_VT := "res://assets/ui/fonts/VT323-Regular.ttf"

const SIZE_NAME := 24
const SIZE_BODY := 20
const SIZE_NUMBER := 28
const SIZE_TAG := 18
const SIZE_MIN := 18
const SIZE_CHIP := 18
const SIZE_FORMULA := 13
const SIZE_FIT_MIN := 10

const PARCHMENT := Color("E9D3A1")
const DIM := Color("B89A70")
const SOOT := Color("1A120E")
const HUB := Color("140D0A")
const OAK := Color("3B2618")
const NUMBER_PLATE := Color("140D0A")

const ATK := Color("D5443B")
const BLK := Color("4FA3D9")
const HEAL := Color("7BC950")
const KO := Color("A866C9")
const HP := Color("D5443B")

## Lightened so ATK / KO hit ~4.5:1 on oak. BLK / HEAL already pass.
const ATK_INK := Color("E86A62")
const BLK_INK := Color("4FA3D9")
const HEAL_INK := Color("7BC950")
const KO_INK := Color("C080E0")
const HP_INK := Color("E86A62")
const HP_CHIP_FILL := Color("C43B34")


static func font_regular() -> Font:
	return load(FONT_REGULAR) as Font


static func font_semibold() -> Font:
	return load(FONT_SEMIBOLD) as Font


static func font_bold() -> Font:
	return load(FONT_BOLD) as Font


static func font_extrabold() -> Font:
	return load(FONT_EXTRABOLD) as Font


static func font_name() -> Font:
	return load(FONT_NAME) as Font


static func font_body() -> Font:
	return load(FONT_BODY) as Font


static func font_body_bold() -> Font:
	return load(FONT_BODY_BOLD) as Font


static func font_pixel() -> Font:
	return load(FONT_PIXEL) as Font


static func font_silk() -> Font:
	return load(FONT_SILK) as Font


static func font_vt() -> Font:
	return load(FONT_VT) as Font


static func kind_ink(kind: String) -> Color:
	var k: String = kind.to_upper()
	if k == "BLK" or k.begins_with("BLK"):
		return BLK_INK
	if k == "HEAL" or k.contains("HEAL"):
		return HEAL_INK
	if k == "DEFEAT" or k == "FANGS" or k == "KO":
		return KO_INK
	if k == "HP":
		return HP_INK
	if k == "ATK" or k.contains("ATK"):
		return ATK_INK
	return PARCHMENT


static func _set_label(node: Label, font: Font, size: int, color: Color, variation: String) -> void:
	if node == null:
		return
	if variation != "":
		node.theme_type_variation = variation
	if font != null:
		node.add_theme_font_override("font", font)
	node.add_theme_font_size_override("font_size", maxi(SIZE_MIN, size))
	node.add_theme_color_override("font_color", color)
	node.add_theme_constant_override("outline_size", 0)


static func apply_name(node: Label, color: Color = PARCHMENT, size: int = SIZE_NAME) -> void:
	_set_label(node, font_name(), size, color, "UtilityName")


static func apply_body(node: Label, color: Color = PARCHMENT, size: int = SIZE_BODY) -> void:
	_set_label(node, font_body(), size, color, "UtilityBody")


static func apply_number(node: Label, color: Color = PARCHMENT, size: int = SIZE_NUMBER) -> void:
	_set_label(node, font_extrabold(), size, color, "UtilityNumber")


static func apply_tag(node: Label, color: Color = PARCHMENT, size: int = SIZE_TAG) -> void:
	_set_label(node, font_bold(), size, color, "UtilityTag")


static func apply_rich(node: RichTextLabel, role: String = "body", color: Color = PARCHMENT) -> void:
	if node == null:
		return
	var regular: Font = font_body()
	var bold: Font = font_body_bold()
	var extra: Font = font_extrabold()
	var size: int = SIZE_BODY
	var variation := "UtilityBody"
	if role == "name":
		size = SIZE_NAME
		variation = "UtilityName"
		regular = font_name()
		if font_body_bold() != null:
			bold = font_body_bold()
	elif role == "number":
		size = SIZE_NUMBER
		variation = "UtilityNumber"
		regular = font_extrabold()
		if extra != null:
			bold = extra
	elif role == "tag":
		size = SIZE_TAG
		variation = "UtilityTag"
		regular = font_bold()
		if regular != null:
			bold = regular
	elif role == "formula":
		size = SIZE_FORMULA
		variation = "UtilityBody"
		regular = font_body()
		bold = font_body_bold()
	node.theme_type_variation = variation
	if regular != null:
		node.add_theme_font_override("normal_font", regular)
		node.add_theme_font_override("italics_font", regular)
	if bold != null:
		node.add_theme_font_override("bold_font", bold)
		node.add_theme_font_override("bold_italics_font", bold)
	node.add_theme_font_size_override("normal_font_size", size)
	node.add_theme_font_size_override("bold_font_size", size)
	node.add_theme_font_size_override("italics_font_size", size)
	node.add_theme_font_size_override("bold_italics_font_size", size)
	node.add_theme_color_override("default_color", color)
	node.add_theme_constant_override("outline_size", 0)


## Shrink `start_size` until `text` fits on one line in `max_w`. Never wraps.
static func fit_one_line(font: Font, text: String, max_w: float, start_size: int = SIZE_MIN, min_size: int = SIZE_FIT_MIN) -> Dictionary:
	var shown: String = text.strip_edges()
	var fs: int = maxi(min_size, start_size)
	var floor_fs: int = maxi(8, min_size)
	if font == null or shown == "":
		return {"text": shown, "size": fs, "width": 0.0, "height": float(fs)}
	while fs > floor_fs:
		var w: float = font.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if w <= max_w:
			return {"text": shown, "size": fs, "width": w, "height": float(font.get_height(fs))}
		fs -= 1
	var final_w: float = font.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	return {"text": shown, "size": fs, "width": final_w, "height": float(font.get_height(fs))}


static func number_plate() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = NUMBER_PLATE
	sb.set_corner_radius_all(4)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	return sb
