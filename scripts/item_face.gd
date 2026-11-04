extends Control
class_name ItemFace
## Hotbar / offer face glyphs. Paths stay on PNG faces; recipes live in main._face_rows.

## Idle hotbar glyphs: 24 → 36 (+50%, #297) → 43 (+20% retune, 2026-11-02). Offer stays 48.
const SIZE_HOTBAR := 43
const SIZE_OFFER := 48
const FONT_HOTBAR := 22
const FONT_OFFER := 22
const FONT_TEXT_HOTBAR := 19
const FONT_TEXT_OFFER := 18
const OUTLINE := Color("100e0c")
const OUTLINE_SIZE := 4
const TINT_BLUE := Color("6bb3d9")
## Positive / reclaim mint — matches Hex@1 / Recycler armed (item_card COL_HEX_GOOD).
const TINT_MINT := Color("5FD3A0")
const SELF_BORDER := Color("c4a574")

## Crypt Classic faces under assets/ui/icons/face/ (native 24×24, scaled via TextureRect).
const FACE_DIR := "res://assets/ui/icons/face/"

## Shared icons that stay at their existing paths (not redesigned here).
const HEART := "res://assets/ui/hub/heart_full.png"
const BURST := "res://assets/ui/icons/atk_burst_single_s24_2x.png"
const SHIELD := "res://assets/ui/icons/pips/pip_block_s24_2x.png"
const SKULL := "res://assets/ui/icons/pips/pip_skull_s24_2x.png"
const DROPLET := "res://assets/icons/droplet.svg"
const BAN := "res://assets/icons/ban.svg"
const COPY := "res://assets/icons/copy.svg"


static func _is_pip_path(path: String) -> bool:
	return path.find("/pips/pip_") >= 0

static var _cache: Dictionary = {}

var _col: VBoxContainer
## Set by ItemCard.set_showcase — do not guess from host height (idle host expands).
var _offer_mode: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _col == null:
		_ensure_col()


func set_offer_mode(on: bool) -> void:
	_offer_mode = on


func _ensure_col() -> void:
	if _col != null:
		return
	_col = VBoxContainer.new()
	_col.name = "Rows"
	_col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	## Vertically center the glyph row in the leftover band under the item sprite.
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


## TextureRect sized for the hotbar (43) or offer card (48), nearest filter.
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
	lab.add_theme_font_size_override("font_size", FONT_OFFER if offer else FONT_HOTBAR)
	return lab


func _is_offer() -> bool:
	return _offer_mode


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
		lab.add_theme_font_size_override("font_size", FONT_TEXT_OFFER if offer else FONT_TEXT_HOTBAR)
		lab.custom_minimum_size = Vector2(maxi(px, t.length() * (10 if offer else 9)), px)
		if tint == "blue":
			lab.add_theme_color_override("font_color", TINT_BLUE)
		elif tint == "mint" or tint == "green":
			lab.add_theme_color_override("font_color", TINT_MINT)
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

	var pip_icon: bool = _is_pip_path(_path_for(tex_key))
	var mint_tint: bool = tint == "mint" or tint == "green"

	if t != "":
		var num := make_number(t, offer)
		# Pip art is already colored — skip blue/mint tint on the number sitting on it.
		if tint == "blue" and not pip_icon:
			num.add_theme_color_override("font_color", TINT_BLUE)
		elif mint_tint and not pip_icon:
			num.add_theme_color_override("font_color", TINT_MINT)
			## Recycler armed zero — slightly louder than a normal face pip number.
			if t == "0":
				num.add_theme_font_size_override("font_size", (FONT_OFFER if offer else FONT_HOTBAR) + 4)
				num.add_theme_constant_override("outline_size", OUTLINE_SIZE + 1)
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

	if tint == "blue" and t == "" and not pip_icon:
		icon.modulate = TINT_BLUE
	elif mint_tint and not pip_icon:
		## Recycle arrows around the zero read mint with the plate glow.
		icon.modulate = TINT_MINT

	return host
