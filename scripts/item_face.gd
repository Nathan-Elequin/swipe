extends RefCounted
class_name ItemFace
## Hotbar / offer face glyphs. Paths only — recipes live in main._face_rows.

const SIZE_HOTBAR := 24
const SIZE_OFFER := 48
const OUTLINE := Color("100e0c")
const OUTLINE_SIZE := 4

## New 24×24 Crypt Classic faces under assets/ui/icons/face/.
const FACE_DIR := "res://assets/ui/icons/face/"

## Shared icons that stay at their existing paths (not redesigned here).
const HEART := "res://assets/ui/hub/heart_full.png"
const BURST := "res://assets/ui/icons/atk_burst_single_s24_2x.png"
const SHIELD := "res://assets/icons/shield.svg"
const SKULL := "res://assets/icons/skull.svg"
const DROPLET := "res://assets/icons/droplet.svg"
const BAN := "res://assets/icons/ban.svg"
const COPY := "res://assets/icons/copy.svg"

static var _cache: Dictionary = {}


## Resolve a face key to a resource path. Accepts bare keys (nw), face_* aliases
## from the rejected SVG set (face_nw), and bagq → question.
static func _path_for(key: String) -> String:
	var k: String = str(key).strip_edges().to_lower()
	if k.begins_with("face_"):
		k = k.substr(5)
	match k:
		"heart", "heart_full":
			return HEART
		"burst", "atk", "atk_burst":
			return BURST
		"shield", "block", "blk":
			return SHIELD
		"skull", "defeat":
			return SKULL
		"droplet", "poison", "heal":
			return DROPLET
		"ban":
			return BAN
		"copy":
			return COPY
		"bagq", "question", "?":
			return FACE_DIR + "question.png"
		"nw", "ne", "east", "far", "cleave", "spin", "retain", "hand", "bag", "flee", "slash", "swap":
			return FACE_DIR + k + ".png"
		_:
			if k.ends_with(".png") or k.ends_with(".svg"):
				return k if k.begins_with("res://") else FACE_DIR + k
			return ""


static func path_for(key: String) -> String:
	return _path_for(key)


static func tex_for(key: String) -> Texture2D:
	var path: String = _path_for(key)
	if path == "":
		return null
	if _cache.has(path):
		return _cache[path] as Texture2D
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path) as Texture2D
	if tex != null:
		_cache[path] = tex
	return tex


## TextureRect sized for the hotbar (24) or offer card (48), nearest filter.
static func make_icon(key: String, offer: bool = false) -> TextureRect:
	var tr := TextureRect.new()
	var px: int = SIZE_OFFER if offer else SIZE_HOTBAR
	tr.custom_minimum_size = Vector2(px, px)
	tr.size = Vector2(px, px)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.texture = tex_for(key)
	return tr


## Number centered on a face icon. Outline #100e0c, size 4.
static func make_number(text: String, offer: bool = false) -> Label:
	var lab := Label.new()
	lab.text = text
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.add_theme_color_override("font_outline_color", OUTLINE)
	lab.add_theme_constant_override("outline_size", OUTLINE_SIZE)
	lab.add_theme_font_size_override("font_size", 22 if offer else 14)
	return lab
