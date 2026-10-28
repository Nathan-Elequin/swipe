extends Control
class_name ItemFace
## Hotbar / offer face glyphs. Paths stay on PNG faces; recipes live in main._face_rows.

const SIZE_HOTBAR := 24
const SIZE_OFFER := 48
const OUTLINE := Color("100e0c")
const OUTLINE_SIZE := 4
const TINT_BLUE := Color("6bb3d9")
const SELF_BORDER := Color("c4a574")

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

var _col: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _col == null:
		_ensure_col()


func _ensure_col() -> void:
	if _col != null:
		return
	_col = VBoxContainer.new()
	_col.name = "Rows"
	_col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_col.add_theme_constant_override("separation", 2)
	_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_col)


## Resolve a face key to a resource path. Accepts bare keys (nw), face_* aliases
## from the rejected SVG set (face_nw), and bagq → question.
static func _path_for(key: String) -> String:
	var k: String = str(key).strip_edges().to_lower()
	if k.begins_with("face_"):
		k = k.substr(5)
	match k:
		"heart", "heart_full":
			return HEART
		"burst", "atk", "atk_burst", "impact":
			return BURST
		"shield", "block", "blk":
			return SHIELD
		"skull", "defeat":
			return SKULL
		"droplet", "poison", "drop", "heal":
			return DROPLET
		"ban":
			return BAN
		"copy":
			return COPY
		"bagq", "question", "?":
			return FACE_DIR + "question.png"
		"noflee":
			return FACE_DIR + "flee.png"
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


func _is_offer() -> bool:
	if size.y >= 50.0:
		return true
	var p := get_parent()
	if p is Control and (p as Control).custom_minimum_size.y >= 50.0:
		return true
	return false


## rows: Array of row Arrays; each cell is {_fg} dict {k,t,tint,border,sup,id}.
func set_rows(rows: Array) -> void:
	_ensure_col()
	for c in _col.get_children():
		_col.remove_child(c)
		c.queue_free()
	if rows.is_empty():
		return
	var offer: bool = _is_offer()
	for row_v in rows:
		if typeof(row_v) != TYPE_ARRAY:
			continue
		var row: Array = row_v
		var h := HBoxContainer.new()
		h.alignment = BoxContainer.ALIGNMENT_CENTER
		h.add_theme_constant_override("separation", 2)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for cell_v in row:
			if typeof(cell_v) != TYPE_DICTIONARY:
				continue
			var cell: Control = _make_cell(cell_v as Dictionary, offer)
			if cell != null:
				h.add_child(cell)
		if h.get_child_count() > 0:
			_col.add_child(h)


func _make_cell(g: Dictionary, offer: bool) -> Control:
	var k: String = str(g.get("k", ""))
	var t: String = str(g.get("t", ""))
	var tint: String = str(g.get("tint", ""))
	var border: String = str(g.get("border", ""))
	var sup: String = str(g.get("sup", ""))
	var icon_id: String = str(g.get("id", ""))
	var host := Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var px: int = SIZE_OFFER if offer else SIZE_HOTBAR

	if k == "bar" or icon_id == "bar":
		var bar := ColorRect.new()
		bar.color = Color("f0e6d8")
		bar.custom_minimum_size = Vector2(2, px)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.custom_minimum_size = Vector2(6, px)
		bar.position = Vector2(2, 0)
		host.add_child(bar)
		return host

	if k == "text":
		var lab := Label.new()
		lab.text = t
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.add_theme_color_override("font_outline_color", OUTLINE)
		lab.add_theme_constant_override("outline_size", OUTLINE_SIZE)
		lab.add_theme_font_size_override("font_size", 18 if offer else 12)
		lab.custom_minimum_size = Vector2(maxi(px, t.length() * (10 if offer else 7)), px)
		if tint == "blue":
			lab.add_theme_color_override("font_color", TINT_BLUE)
		host.custom_minimum_size = lab.custom_minimum_size
		host.add_child(lab)
		lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		return host

	var tex_key: String = icon_id
	match k:
		"impact":
			tex_key = "burst"
		"shield":
			tex_key = "shield"
		"heart":
			tex_key = "heart"
		"skull":
			tex_key = "skull"
		"drop":
			tex_key = "droplet"
		"icon":
			tex_key = icon_id
		_:
			if tex_key == "":
				tex_key = k

	var icon := make_icon(tex_key, offer)
	host.custom_minimum_size = Vector2(px, px)
	host.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if t != "":
		var num := make_number(t, offer)
		if tint == "blue":
			num.add_theme_color_override("font_color", TINT_BLUE)
		host.add_child(num)

	if border == "self":
		var frame := Panel.new()
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_color = SELF_BORDER
		sb.set_border_width_all(1)
		frame.add_theme_stylebox_override("panel", sb)
		host.add_child(frame)

	if sup == "bleed":
		var drip := make_icon("droplet", false)
		var s: float = float(px) * 0.45
		drip.custom_minimum_size = Vector2(s, s)
		drip.size = Vector2(s, s)
		drip.position = Vector2(px - s, 0)
		drip.modulate = Color("e06c75")
		host.add_child(drip)

	if tint == "blue" and t == "":
		icon.modulate = TINT_BLUE

	return host
