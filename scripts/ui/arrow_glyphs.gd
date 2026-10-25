extends RefCounted
class_name ArrowGlyphs
## Bundled BMFont for ← → ↔ so web never depends on a system font.

const LEFT := 0x2190
const RIGHT := 0x2192
const BOTH := 0x2194
const GAMEPLAY := [LEFT, RIGHT, BOTH]
const CELL := 12
const BUNDLE := "res://assets/ui/fonts/arrow_glyphs.fnt"
const USER_FNT := "user://fonts/arrow_glyphs.fnt"
const USER_PNG := "user://fonts/arrow_glyphs.png"
const INK := Color("100e0c")
const GOLD := Color("FFD84A")

static var _font: FontFile
static var _installed: bool = false


static func ensure() -> FontFile:
	if _font == null or not _covers_all(_font):
		_font = _build_font()
	_install()
	return _font


static func font() -> FontFile:
	return ensure()


static func stack_has(font: Font, code: int) -> bool:
	if font != null and font.has_char(code):
		return true
	if _font != null and _font.has_char(code):
		return true
	return false


static func missing_from(font: Font, text: String, use_bundle: bool = true) -> PackedStringArray:
	if use_bundle:
		ensure()
	var out := PackedStringArray()
	if text == "":
		return out
	for i in text.length():
		var c: int = text.unicode_at(i)
		if not (c in GAMEPLAY):
			continue
		var ok: bool = false
		if font != null and font.has_char(c):
			ok = true
		elif use_bundle and covers(c):
			ok = true
		if not ok and not out.has(String.chr(c)):
			out.append(String.chr(c))
	return out


static func covers(code: int) -> bool:
	ensure()
	return _char_ok(_font, code)


static func _covers_all(font: FontFile) -> bool:
	if font == null:
		return false
	for c in GAMEPLAY:
		if not _char_ok(font, c):
			return false
	return true


static func _char_ok(font: Font, code: int) -> bool:
	if font == null:
		return false
	if font.has_char(code):
		return true
	if font.get_glyph_index(CELL, code, 0) != 0:
		return true
	if font.get_glyph_index(0, code, 0) != 0:
		return true
	return false


static func _install() -> void:
	if _installed or _font == null:
		return
	var base: Font = ThemeDB.fallback_font
	if base == null:
		return
	var existing: Array = base.fallbacks
	for f in existing:
		if f == _font:
			_installed = true
			return
	var next: Array[Font] = [_font]
	for f2 in existing:
		if f2 is Font:
			next.append(f2)
	base.fallbacks = next
	_installed = true


static func _build_font() -> FontFile:
	var font: FontFile = _try_load(BUNDLE)
	if font != null:
		return font
	_write_user_bundle()
	font = _try_load(USER_FNT)
	if font != null:
		return font
	return FontFile.new()


static func _try_load(path: String) -> FontFile:
	if path == "" or not FileAccess.file_exists(path):
		return null
	var font := FontFile.new()
	font.allow_system_fallback = false
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.oversampling = 1.0
	font.fixed_size = CELL
	var err: Variant = font.load_bitmap_font(path)
	if typeof(err) == TYPE_INT and int(err) != OK:
		return null
	if not _covers_all(font):
		return null
	return font


static func _write_user_bundle() -> void:
	var abs_dir: String = ProjectSettings.globalize_path("user://fonts")
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var img: Image = _atlas()
	img.save_png(USER_PNG)
	_write_fnt(USER_FNT, USER_PNG.get_file())


static func write_bundle(dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	var img: Image = _atlas()
	img.save_png(dir.path_join("arrow_glyphs.png"))
	_write_fnt(dir.path_join("arrow_glyphs.fnt"), "arrow_glyphs.png")


static func _write_fnt(path: String, page_file: String) -> void:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("info face=\"ArrowGlyphs\" size=12 bold=0 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=0 aa=0 padding=0,0,0,0 spacing=0,0 outline=0")
	lines.append("common lineHeight=12 base=10 scaleW=36 scaleH=12 pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4")
	lines.append("page id=0 file=\"%s\"" % page_file)
	lines.append("chars count=3")
	var codes: Array[int] = [LEFT, RIGHT, BOTH]
	for i in codes.size():
		var ch: int = codes[i]
		var x: int = i * CELL
		lines.append("char id=%d x=%d y=0 width=12 height=12 xoffset=0 yoffset=2 xadvance=12 page=0 chnl=15" % [ch, x])
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	f.store_string("\n".join(lines) + "\n")
	f.close()


static func _atlas() -> Image:
	var img := Image.create(CELL * 3, CELL, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_blit(img, 0, _pixels_left())
	_blit(img, CELL, _pixels_right())
	_blit(img, CELL * 2, _pixels_both())
	return img


static func _blit(img: Image, ox: int, dots: Array) -> void:
	for p in dots:
		if typeof(p) != TYPE_DICTIONARY:
			continue
		var x: int = ox + int(p.get("x", 0))
		var y: int = int(p.get("y", 0))
		if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
			continue
		img.set_pixel(x, y, p.get("z", GOLD))


static func _pixels_right() -> Array:
	return _arrow(false, true)


static func _pixels_left() -> Array:
	return _arrow(true, false)


static func _pixels_both() -> Array:
	return _arrow(true, true)


static func _arrow(left_head: bool, right_head: bool) -> Array:
	var dots: Array = []
	var mid := 5
	for x in range(2, 10):
		_dot(dots, x, mid, GOLD)
		_dot(dots, x, mid - 1, INK)
		_dot(dots, x, mid + 1, INK)
	if right_head:
		for i in 4:
			_dot(dots, 8 + i / 2, mid - i, GOLD)
			_dot(dots, 8 + i / 2, mid + i, GOLD)
			_dot(dots, 7 + i / 2, mid - i, INK)
			_dot(dots, 7 + i / 2, mid + i, INK)
		_dot(dots, 11, mid, GOLD)
		_dot(dots, 11, mid - 1, INK)
		_dot(dots, 11, mid + 1, INK)
	if left_head:
		for i in 4:
			_dot(dots, 3 - i / 2, mid - i, GOLD)
			_dot(dots, 3 - i / 2, mid + i, GOLD)
			_dot(dots, 4 - i / 2, mid - i, INK)
			_dot(dots, 4 - i / 2, mid + i, INK)
		_dot(dots, 0, mid, GOLD)
		_dot(dots, 0, mid - 1, INK)
		_dot(dots, 0, mid + 1, INK)
	return dots


static func _dot(dots: Array, x: int, y: int, col: Color) -> void:
	if x < 0 or y < 0 or x >= CELL or y >= CELL:
		return
	dots.append({"x": x, "y": y, "z": col})
