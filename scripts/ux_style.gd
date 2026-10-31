extends RefCounted
class_name UxStyle
## Shared combat chrome. Chips, plates, and kind colors — not player copy.

const COPY := preload("res://scripts/player_copy.gd")

const INK := Color("f4ede3")
const INK_DIM := Color("c9b9a8")
const INK_OUT := Color("100e0c")
const GOLD := Color("e8c36a")
const GOLD_DIM := Color("c4a574")
const METAL_BRONZE := Color("c08050")
const METAL_SILVER := Color("c5cdd8")
const METAL_GOLD := Color("e8c36a")


static func nine_patch(path: String, ml: float, mt: float, mr: float, mb: float, cl: float, ct: float, cr: float, cb: float) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	if ResourceLoader.exists(path):
		sb.texture = load(path)
	sb.texture_margin_left = ml
	sb.texture_margin_top = mt
	sb.texture_margin_right = mr
	sb.texture_margin_bottom = mb
	sb.content_margin_left = cl
	sb.content_margin_top = ct
	sb.content_margin_right = cr
	sb.content_margin_bottom = cb
	return sb


static func oak_panel(gold: bool = false, content: float = 26.0) -> StyleBoxTexture:
	var path := "res://assets/dungeon/ui/panel_beigeLight.png" if gold else "res://assets/dungeon/ui/panel_brown.png"
	return nine_patch(path, 14, 12, 14, 14, content, content, content, content)


static func plate_inset(tier: int = 0) -> StyleBoxTexture:
	var path := "res://assets/dungeon/ui/panelInset_brown.png"
	if tier >= 3:
		path = "res://assets/dungeon/ui/panelInset_blue.png"
	elif tier == 2:
		path = "res://assets/dungeon/ui/panelInset_beige.png"
	return nine_patch(path, 10, 10, 10, 10, 20, 16, 20, 16)


static func long_button(kind: String = "brown", pressed: bool = false) -> StyleBoxTexture:
	var name := "buttonLong_%s_pressed.png" % kind if pressed else "buttonLong_%s.png" % kind
	var path := "res://assets/dungeon/ui/%s" % name
	var top: float = 10.0
	var bot: float = 12.0
	return nine_patch(path, 20, top, 20, bot, 20, 10, 20, 10)


static func title_button_style(pressed: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color("2a1c14") if pressed else Color("1c140e")
	s.border_color = Color("e8c36a")
	s.set_border_width_all(3)
	s.set_corner_radius_all(10)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


static func dress_small_button(b: Button, width: float = 0.0) -> void:
	if b == null:
		return
	b.custom_minimum_size = Vector2(width, 32)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color("f8f2ea"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("e8c36a"))
	b.add_theme_color_override("font_outline_color", Color("100e0c"))
	b.add_theme_constant_override("outline_size", 2)
	var up := title_button_style(false)
	up.set_border_width_all(2)
	up.set_corner_radius_all(8)
	up.content_margin_left = 10
	up.content_margin_right = 10
	up.content_margin_top = 4
	up.content_margin_bottom = 4
	var hover := up.duplicate() as StyleBoxFlat
	hover.bg_color = Color("2a1c14")
	var down := title_button_style(true)
	down.set_border_width_all(2)
	down.set_corner_radius_all(8)
	down.content_margin_left = 10
	down.content_margin_right = 10
	down.content_margin_top = 4
	down.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", up)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("pressed", down)


static func dress_title_button(b: Button, width: float = 0.0) -> void:
	if b == null:
		return
	b.custom_minimum_size = Vector2(width, 52)
	b.add_theme_font_size_override("font_size", 21)
	b.add_theme_color_override("font_color", Color("f8f2ea"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("e8c36a"))
	b.add_theme_color_override("font_outline_color", Color("100e0c"))
	b.add_theme_constant_override("outline_size", 4)
	var up := title_button_style(false)
	var hover := title_button_style(false)
	hover.bg_color = Color("2a1c14")
	var down := title_button_style(true)
	b.add_theme_stylebox_override("normal", up)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_stylebox_override("pressed", down)


## Same metals the item rims use. 1 Weak / bronze, 2 Tough / silver, 3 Deadly / gold.
static func metal(tier: int) -> Color:
	if tier >= 3:
		return METAL_GOLD
	if tier == 2:
		return METAL_SILVER
	return METAL_BRONZE


static func metal_wedge(tier: int) -> Color:
	if tier >= 3:
		return Color("6e5418")
	if tier == 2:
		return Color("4a5560")
	return Color("6a3e24")


static func metal_well(tier: int) -> Color:
	if tier >= 3:
		return Color("2a1c08")
	if tier == 2:
		return Color("14161a")
	return Color("24160e")


static func metal_chip(tier: int) -> Color:
	if tier >= 3:
		return Color("1c1408e8")
	if tier == 2:
		return Color("101418e8")
	return Color("1a100ce8")


static func metal_ink(tier: int) -> Color:
	if tier >= 3:
		return Color("ffe9a8")
	if tier == 2:
		return Color("eef2f8")
	return Color("f3d2b0")


static func metal_call(tier: int) -> Color:
	if tier >= 3:
		return Color("e8c36a")
	if tier == 2:
		return Color("c5cdd8")
	return Color("e0b090")


## Rounded square used for monster portraits. `rad` is half the box.
static func round_plate(center: Vector2, rad: float) -> PackedVector2Array:
	var hw: float = rad
	var hh: float = rad * 0.92
	var cr: float = minf(hw, hh) * 0.42
	var pts := PackedVector2Array()
	var ccs := PackedVector2Array([
		center + Vector2(hw - cr, -hh + cr),
		center + Vector2(hw - cr, hh - cr),
		center + Vector2(-hw + cr, hh - cr),
		center + Vector2(-hw + cr, -hh + cr),
	])
	var a0s := PackedFloat32Array([-PI * 0.5, 0.0, PI * 0.5, PI])
	var a1s := PackedFloat32Array([0.0, PI * 0.5, PI, PI * 1.5])
	for i in 4:
		for k in 7:
			var a: float = lerpf(a0s[i], a1s[i], float(k) / 6.0)
			pts.append(ccs[i] + Vector2.from_angle(a) * cr)
	return pts


const SQUIRCLE_PNG := {
	1: "res://assets/ui/wheel/squircle_t1.png",
	2: "res://assets/ui/wheel/squircle_t2.png",
	3: "res://assets/ui/wheel/squircle_t3.png",
}
const INSPECT_SQUIRCLE_PNG := {
	1: "res://assets/ui/inspect/squircle_t1.png",
	2: "res://assets/ui/inspect/squircle_t2.png",
	3: "res://assets/ui/inspect/squircle_t3.png",
}
static var _squircle_tex: Dictionary = {}
static var _inspect_squircle_tex: Dictionary = {}


static func squircle_tex(tier: int, inspect: bool = false) -> Texture2D:
	var t: int = clampi(tier, 1, 3)
	var cache: Dictionary = _inspect_squircle_tex if inspect else _squircle_tex
	if cache.has(t):
		return cache[t]
	var table: Dictionary = INSPECT_SQUIRCLE_PNG if inspect else SQUIRCLE_PNG
	var path: String = str(table.get(t, ""))
	var tex: Texture2D = null
	if path != "" and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null and inspect:
		tex = squircle_tex(t, false)
	cache[t] = tex
	return tex


## Code stand-in until Pixel's squircle PNGs land. Uses today's metals; Pixel picks brown / blue / deep red.
## Hornet ×2 / Shambling ∞ / Shark ↻ capsule. Shared by the wheel and the intent plate.
static func draw_multi_tag(ci: CanvasItem, mark: Vector2, tag: String, font: Font) -> void:
	if ci == null or font == null:
		return
	var badge := Rect2(mark - Vector2(16.0, 8.0), Vector2(32.0, 16.0))
	ci.draw_rect(badge, Color("1c120ce8"), true)
	ci.draw_rect(badge, Color("e8c36a"), false, 1.5)
	var fs: int = 12
	var col := Color("e8c36a")
	var outline := Color("1c120c")
	var tsz: Vector2 = font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = mark + Vector2(-tsz.x * 0.5, 4.0)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			ci.draw_string(font, p + Vector2(ox, oy), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline)
	ci.draw_string(font, p, tag, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


static func draw_squircle(ci: CanvasItem, center: Vector2, rad: float, tier: int, fill: Color, rim: Color, rim_w: float, inspect: bool = false) -> void:
	if ci == null or rad < 2.0:
		return
	var tex: Texture2D = squircle_tex(tier, inspect)
	if tex != null:
		var hh: float = rad * 0.92
		var box := Rect2(center - Vector2(rad, hh), Vector2(rad * 2.0, hh * 2.0))
		ci.draw_texture_rect(tex, box, false)
		return
	var pts: PackedVector2Array = round_plate(center, rad)
	if pts.size() < 3:
		return
	ci.draw_colored_polygon(pts, fill)
	var loop: PackedVector2Array = pts.duplicate()
	loop.append(pts[0])
	ci.draw_polyline(loop, rim, rim_w, true)


const CALL_ATK := Color("e07040")
const CALL_HP := Color("e8a0a0")
const CALL_VAR := Color("c9a0ff")
const CALL_STEEL := Color("c5cdd8")
const CALL_INK := Color("f0e6d8")
const PLATE := Color("1a1410f6")
const WELL := Color("0c0908")
const ATK := "#E07A7A"
const HP := "#E8A0A0"
const BLK := "#6BB3D9"
const VAR := "#C9A0FF"
const HEAL := "#8FD18F"
const ALWAYS := "#E8C36A"
const UNPLAYABLE := "#C8C2BA"


## Same color the wheel uses for a monster's call name (the subtitle under the name).
static func call_color(special_id: String) -> Color:
	match special_id:
		"item_atk", "two_items", "gift", "eat_item", "petrify", "petrify_gaze", "no_keep", "item_swings", "hunter_mark", "bear_trap", "wickrise", "fair_trade", "gift_shield", "insure", "triple_threat", "hunger_pains", "dance_swap", "hatch", "rebirth", "adaptation", "fairy_dust", "fairy_bottle", "cats_eye", "toxic_skin", "rust", "decay":
			return GOLD
		"no_atk_dmg", "double_hit", "self_deconstruct", "atk_spin", "copy_atk", "buff_atk", "pierce", "thorns", "queen_hits", "interrupt", "even_twice", "left_atk", "pass_right", "coward", "blood_thresh", "conductive":
			return CALL_ATK
		"last_hp", "buff_hp", "undying", "hp_spin", "pack_hp", "leech_lowest", "one_chip", "take_instead", "blood_pact", "three_hp", "cultivator", "lifelink":
			return CALL_HP
		"kill_scale", "atk_eq_hp":
			return CALL_VAR
		"split_t2", "synchronize":
			return CALL_STEEL
		_:
			return CALL_INK


static func call_hex(special_id: String) -> String:
	return "#%s" % call_color(special_id).to_html(false)


static func call_bb(text: String, special_id: String) -> String:
	var shown: String = text.strip_edges()
	if shown == "":
		return ""
	return "[color=%s]%s[/color]" % [call_hex(special_id), shown]


static func chip(text: String, ink_hex: String) -> String:
	var shown: String = text.strip_edges()
	if shown == "":
		return ""
	var hex: String = ink_hex.strip_edges()
	if hex == "":
		hex = "#E8C36A"
	## Colored word on the same baseline. No box, no padding — those overflow the line.
	return "[color=%s][b]%s[/b][/color]" % [hex, shown]


static func def_id_of(piece: String) -> String:
	var low: String = piece.strip_edges().to_lower()
	if low == "any" or low == "any monster":
		return "any"
	if low.begins_with("eject"):
		return "eject"
	if low == "phoenix egg":
		return "phoenix_egg"
	if low == "phoenix":
		return "phoenix"
	if low == "bear trap":
		return "bear_trap"
	if low == "across":
		return "across"
	if low == "move":
		return "move"
	if low.begins_with("flee"):
		return "flee"
	if low.begins_with("defeat"):
		return "defeated"
	if low.begins_with("mark"):
		return "marked"
	if low.find("poison") >= 0:
		return "poison"
	if low.begins_with("spin") or low == "spun":
		return "spin"
	if low == "always":
		return "always"
	if low == "swap" or low.begins_with("swap"):
		return "swap"
	if low == "loaded":
		return "loaded"
	if low == "unplayable":
		return "unplayable"
	if low == "rust":
		return "rust"
	if low == "decay" or low.begins_with("decayed"):
		return "decay"
	return ""


static func def_of(id: String) -> String:
	match id:
		"any":
			return "You may choose any Monster on the wheel, not only the one you are facing."
		"eject":
			return "remove them from the dungeon immediately, placing them on the bottom of the Dungeon Deck"
		"across":
			return "across on the opposite side of the wheel."
		"bear_trap":
			return "a 2 HP 4 ATK monster that Attacks you when you Move or Spin onto it"
		"move":
			return "shift to a Neighbor without Spinning"
		"flee":
			return "If you are facing them, Spin the wheel at random. They are not removed."
		"defeated":
			return "They leave the wheel. Flee is different — they stay. Escaped means you took the hit and lived."
		"marked":
			return "upon Defeat, Trapper gains +2 HP and ATK"
		"poison":
			return "When you Spin that monster, they lose that much HP immediately, then the mark clears. Other marked monsters keep theirs. Your Poison pays first on a Spin. Not Attack."
		"spin":
			return "The wheel lands on a random living monster."
		"always":
			return "Always: cannot be changed in any other way"
		"swap":
			return COPY.text("keyword.swap_body", "Swap: trade it for a random item of the same rank (Weak, Tough or Deadly).")
		"loaded":
			return COPY.text("status.sling_loaded_tip", "Loaded: your next Attack can hit any monster.")
		"unplayable":
			return "You cannot click this."
		"rust":
			return "Gain 2 Block, Lose 1 HP. Whenever you Gain Block, Gain 1 Rust."
		"decay":
			return "Decayed Items are linked. When you use one, Keep it and discard the other."
		_:
			return ""


static func with_def_link(shown: String, piece: String) -> String:
	var id: String = def_id_of(piece)
	if id == "" or shown.find("[url=") >= 0:
		return shown
	return "[url=kw:%s]%s[/url]" % [id, shown]


static func wire_def_hover(rtl: RichTextLabel, tip: Node, anchor: Control = null) -> void:
	if rtl == null or tip == null:
		return
	rtl.bbcode_enabled = true
	rtl.meta_underlined = false
	if not rtl.meta_hover_started.is_connected(_on_def_hover.bind(tip, anchor)):
		rtl.meta_hover_started.connect(_on_def_hover.bind(tip, anchor))
	if not rtl.meta_hover_ended.is_connected(_on_def_unhover.bind(tip, anchor)):
		rtl.meta_hover_ended.connect(_on_def_unhover.bind(tip, anchor))
	if not rtl.meta_clicked.is_connected(_on_def_click.bind(tip, anchor)):
		rtl.meta_clicked.connect(_on_def_click.bind(tip, anchor))


static func _on_def_hover(meta: Variant, tip: Node, anchor: Control = null) -> void:
	if tip == null:
		return
	var id: String = str(meta).trim_prefix("kw:")
	if id == "phoenix" or id == "phoenix_egg":
		var main: Node = tip.get_tree().root.get_node_or_null("Main")
		if main != null and main.has_method("keyword_monster_callout") and tip.has_method("show_callout"):
			tip.show_callout(main.keyword_monster_callout(id), anchor, id)
			return
	if id == "rust":
		var main_i: Node = tip.get_tree().root.get_node_or_null("Main")
		if main_i != null and main_i.has_method("keyword_item_callout") and tip.has_method("show_callout"):
			tip.show_callout(main_i.keyword_item_callout("rust"), anchor, id)
			return
	if tip.has_method("show_def"):
		tip.show_def(def_of(id), anchor, id)


static func _on_def_unhover(_meta: Variant, tip: Node, anchor: Control = null) -> void:
	if tip != null and bool(tip.get("_pinned")):
		return
	if anchor != null and bool(anchor.get("_pin_always")) and anchor.has_method("pin_always_def"):
		anchor.pin_always_def()
		return
	if tip != null and tip.has_method("hide_def"):
		tip.hide_def()


static func _on_def_click(meta: Variant, tip: Node, anchor: Control = null) -> void:
	if tip == null:
		return
	var id: String = str(meta).trim_prefix("kw:")
	if tip.has_method("pin_def"):
		tip.pin_def(def_of(id), anchor, id)
		return
	if tip.has_method("show_def"):
		tip.show_def(def_of(id), anchor, id)


## Hairline outline + tiny drop shadow on cream talk paper. Keep this thin — 15px blobs at 3+.
static func ink_on_paper(node: Control, outline: int = 1) -> void:
	if node == null:
		return
	node.add_theme_color_override("font_outline_color", Color("2a1c12"))
	node.add_theme_constant_override("outline_size", outline)
	node.add_theme_color_override("font_shadow_color", Color(0.08, 0.05, 0.03, 0.28))
	node.add_theme_constant_override("shadow_offset_x", 0)
	node.add_theme_constant_override("shadow_offset_y", 1)
	node.add_theme_constant_override("shadow_outline_size", 0)


static func kind_hex(kind: String) -> String:
	var k: String = kind.to_upper()
	if k == "BLK" or k.begins_with("BLK"):
		return BLK
	if k == "HEAL" or k.contains("HEAL"):
		return HEAL
	if k == "DEFEAT" or k == "FANGS":
		return VAR
	if k == "ATK" or k.contains("ATK"):
		return ATK
	return "#E8C36A"


static func kind_color(kind: String) -> Color:
	return Color(kind_hex(kind))


## Authorable item-card fill. Empty / "auto" keeps the old ops guess.
static func card_color_opts() -> Array:
	return [
		{"id": "auto", "label": "Auto"},
		{"id": "atk", "label": "Attack"},
		{"id": "blk", "label": "Block"},
		{"id": "heal", "label": "Heal"},
		{"id": "defeat", "label": "Defeat"},
		{"id": "utility", "label": "Utility"},
		{"id": "smoke", "label": "Smoke"},
		{"id": "chaos", "label": "Chaos"},
		{"id": "egg", "label": "Egg"},
		{"id": "yellow", "label": "Yellow"},
	]


static func card_color_id(raw: String) -> String:
	var s: String = raw.strip_edges().to_lower()
	if s == "" or s == "auto":
		return "auto"
	for o in card_color_opts():
		if str(o["id"]) == s or str(o["label"]) == raw.strip_edges():
			return str(o["id"])
	return "auto"


static func card_color_fill(id: String) -> Color:
	match card_color_id(id):
		"atk":
			return Color("5c2626")
		"blk":
			return Color("1c3d52")
		"heal":
			return Color("243a22")
		"defeat":
			return Color("3a2450")
		"utility":
			return Color("4a3d14")
		"smoke":
			return Color("3a2a38")
		"chaos":
			return Color("3a1460")
		"egg":
			return Color("070605")
		"yellow":
			return Color("4a3d14")
		_:
			return Color(0, 0, 0, 0)


static func card_color_ink(id: String) -> Color:
	return Color("1c120c") if card_color_id(id) == "auto" else Color("f4ede3")


static func card_color_swatch(id: String, w: int = 28, h: int = 16) -> Texture2D:
	var fill: Color = card_color_fill(id)
	if fill.a < 0.08:
		fill = Color("e4d4c0")
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(fill)
	var rim := Color("c4a574")
	for x in w:
		img.set_pixel(x, 0, rim)
		img.set_pixel(x, h - 1, rim)
	for y in h:
		img.set_pixel(0, y, rim)
		img.set_pixel(w - 1, y, rim)
	return ImageTexture.create_from_image(img)


static func paint_color_pick(e: OptionButton) -> void:
	if e == null:
		return
	for i in e.item_count:
		e.set_item_icon(i, card_color_swatch(str(e.get_item_metadata(i)), 40, 18))
	var sel := "auto"
	if e.selected >= 0:
		sel = str(e.get_item_metadata(e.selected))
	var face: Color = card_color_fill(sel)
	var face_ink: Color = card_color_ink(sel)
	if face.a < 0.08:
		face = Color("e4d4c0")
	var sb := StyleBoxFlat.new()
	sb.bg_color = face
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	var hover := sb.duplicate() as StyleBoxFlat
	hover.bg_color = face.lightened(0.08)
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("hover", hover)
	e.add_theme_stylebox_override("pressed", sb)
	e.add_theme_stylebox_override("focus", hover)
	e.add_theme_color_override("font_color", face_ink)
	e.add_theme_color_override("font_hover_color", face_ink)
	e.add_theme_color_override("font_pressed_color", face_ink)
	e.add_theme_color_override("font_focus_color", face_ink)


static func card_color_family(id: String) -> String:
	match card_color_id(id):
		"atk", "utility":
			return "ATK"
		"blk":
			return "BLK"
		"heal":
			return "HEAL"
		"defeat":
			return "DEFEAT"
		"smoke":
			return "SMOKE"
		"chaos":
			return "SKIP"
		"egg":
			return "ATK"
		"yellow":
			return "ATK"
		_:
			return ""


static func plate() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PLATE
	sb.border_color = GOLD_DIM
	sb.border_width_left = 3
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0.05, 0.03, 0.02, 0.55)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 3)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb


static func well() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = WELL
	sb.border_color = Color("3a3228")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 4
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


static func legend_bb() -> String:
	return "%s  %s  %s  %s" % [chip("Attack", ATK), chip("Block", BLK), chip("HP", HP), chip("Defeat", VAR)]


static func paint(raw: String, colored: bool = true, num_hex: String = "#E07A7A", output_kind: String = "", formula: bool = false) -> String:
	var t: String = raw.strip_edges()
	if t == "" or t.find("[color") >= 0 or t.find("[bgcolor") >= 0:
		return raw
	var gold := "#E8C36A"
	var hp_c := HP
	var atk_c := ATK
	var var_c := VAR
	var blk_c := BLK
	var out_k: String = output_kind.strip_edges()
	if out_k != "":
		num_hex = kind_hex(out_k)
	## Formula lines are the output, even when they name an input stat (Neighbor ATK on Bracers).
	if formula and out_k != "" and colored:
		return "[color=%s]%s[/color]" % [num_hex, t]
	var phrases: Array = [
		["item if i never swing", gold],
		["no attack damage", gold],
		["no atk damage", gold],
		["attacks twice", gold],
		["double hit", gold],
		["ignores block", gold],
		["times you bled", hp_c],
		["monsters left", var_c],
		["take their atk", hp_c],
		["heal their hp", hp_c],
		["last enemy atk", atk_c],
		["last enemy hp", hp_c],
		["higher neighbor", atk_c],
		["neighbor atk", atk_c],
		["neighbor hp", hp_c],
		["enemy atk", atk_c],
		["enemy hp", hp_c],
		["your hp", hp_c],
		["even atk", gold],
		["any monster", gold],
		["phoenix egg", gold],
		["phoenix", gold],
		["bear trap", gold],
	]
	var stems := PackedStringArray([
		"defeated", "defeats", "defeating", "defeat",
		"marked", "marks", "mark",
		"attacks", "attacking", "attacked", "attack",
		"blocked", "blocking", "blocks", "block",
		"defending", "defends", "defend",
		"heals", "healed", "healing", "heal",
		"thorns", "thorn",
		"keep",
		"move",
		"bled", "bleeds", "bleeding", "bleed",
		"fleeing", "flees", "fled", "flee",
		"poisoned", "poisons", "poison",
		"any",
		"spinning", "spins", "spun", "spin",
		"losing", "loses", "lost", "lose",
		"always",
		"eject",
		"unplayable",
		"rust",
		"atk", "blk", "hp",
	])
	var nums := "one|two|three|four|five|six|seven|eight|nine|ten|twice|thrice"
	var alts: PackedStringArray = PackedStringArray()
	for p in phrases:
		alts.append(str(p[0]))
	alts.append("\\b(?:%s)\\b" % "|".join(stems))
	alts.append("\\b(?:%s)\\b" % nums)
	alts.append("[+\\-−]?\\d+")
	var rx := RegEx.new()
	if rx.compile("(?i)(%s)" % "|".join(alts)) != OK:
		return raw
	var hits: Array = rx.search_all(t)
	var spans: Array = []
	for m in hits:
		spans.append({"a": m.get_start(), "b": m.get_end()})
	var merged: Array = []
	var i: int = 0
	while i < spans.size():
		var a: int = int(spans[i]["a"])
		var b: int = int(spans[i]["b"])
		while i + 1 < spans.size():
			var nxt_a: int = int(spans[i + 1]["a"])
			var gap: String = t.substr(b, nxt_a - b)
			if gap.strip_edges() != "":
				break
			b = int(spans[i + 1]["b"])
			i += 1
		merged.append({"a": a, "b": b})
		i += 1
	var out := t
	for j in range(merged.size() - 1, -1, -1):
		var span: Dictionary = merged[j]
		var a2: int = int(span["a"])
		var b2: int = int(span["b"])
		var piece: String = t.substr(a2, b2 - a2)
		if piece.strip_edges().to_lower() == "any":
			var after: String = t.substr(b2).strip_edges().to_lower()
			if not after.begins_with("monster") and not after.begins_with("enemy"):
				continue
		var shown: String = _format_keyword(piece)
		if colored:
			var hex: String = _paint_hex(piece, t, a2, b2, num_hex, gold, hp_c, atk_c, var_c, blk_c, phrases, out_k)
			shown = chip(shown, hex)
		shown = with_def_link(shown, piece)
		out = out.substr(0, a2) + shown + out.substr(b2)
	return out


static func _format_keyword(piece: String) -> String:
	if piece.find(" ") < 0:
		return _format_keyword_token(piece)
	var bits: PackedStringArray = PackedStringArray()
	for w in piece.split(" "):
		bits.append(_format_keyword_token(w))
	return " ".join(bits)


static func _format_keyword_token(tok: String) -> String:
	var prefix := ""
	var suffix := ""
	var core := tok
	while core.length() > 0 and _is_paint_sep(core.substr(0, 1)):
		prefix += core.substr(0, 1)
		core = core.substr(1)
	while core.length() > 0 and _is_paint_sep(core.substr(core.length() - 1, 1)):
		suffix = core.substr(core.length() - 1, 1) + suffix
		core = core.substr(0, core.length() - 1)
	if core == "":
		return tok
	var low: String = core.to_lower()
	if low == "atk" or low == "blk" or low == "hp":
		return prefix + low.to_upper() + suffix
	if low == "always":
		return prefix + "Always" + suffix
	if low == "unplayable":
		return prefix + "Unplayable" + suffix
	if _is_word_num(low) or _token_has_digit(core):
		return tok
	if _is_keyword_stem(low):
		return prefix + core.substr(0, 1).to_upper() + core.substr(1).to_lower() + suffix
	return tok


static func _token_has_digit(s: String) -> bool:
	for ch in s:
		if String(ch).is_valid_int():
			return true
	return false


static func _is_word_num(low: String) -> bool:
	return low in ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "twice", "thrice"]


static func _is_paint_sep(ch: String) -> bool:
	return ch.strip_edges() == "" or "()[]{},.:;!?+−↔/—–'\"“”".find(ch) >= 0


static func _is_paint_glue(low: String) -> bool:
	return low in ["or", "and", "of", "to", "the", "a", "an", "more", "less", "minus", "plus", "per", "if", "than", "with", "from", "your", "their", "vs", "equal", "equals"]


static func _is_keyword_stem(low: String) -> bool:
	return _stem_hex(low, "1", "1", "1", "1", "1") != ""


static func _stem_hex(low: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> String:
	if low == "always":
		return ALWAYS
	if low.begins_with("defeat"):
		return var_c
	if low.begins_with("mark"):
		return gold
	if low.begins_with("attack") or low == "atk":
		return atk_c
	if low.begins_with("block") or low == "blk":
		return blk_c
	if low.begins_with("defend"):
		return blk_c
	if low.begins_with("heal"):
		return hp_c
	if low == "hp":
		return hp_c
	if low.begins_with("bleed") or low == "bled":
		return hp_c
	if low.begins_with("thorn"):
		return atk_c
	if low == "keep":
		return gold
	if low == "across":
		return gold
	if low == "move":
		return gold
	if low.begins_with("flee"):
		return gold
	if low.begins_with("poison"):
		return gold
	if low == "any":
		return gold
	if low.begins_with("spin") or low == "spun":
		return gold
	if low == "swap" or low.begins_with("swap"):
		return gold
	if low == "loaded":
		return gold
	if low.begins_with("eject"):
		return gold
	if low == "unplayable":
		return UNPLAYABLE
	if low == "rust":
		return gold
	if low == "decay" or low == "decayed":
		return gold
	return ""


static func _paint_hex(piece: String, full: String, start: int, end: int, fallback: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String, phrases: Array, output_kind: String = "") -> String:
	## Item text takes its color from what the card does, not from a named input stat.
	## Heal cards keep HP / Bleed / lose in HP-pink; Heal words stay the Heal color.
	var out_k: String = output_kind.strip_edges().to_upper()
	if out_k == "HEAL":
		var hlow: String = piece.to_lower()
		if hlow == "hp" or hlow.begins_with("bleed") or hlow == "bled" or hlow.begins_with("lose"):
			return hp_c
		for p in phrases:
			if hlow == str(p[0]) and str(p[1]) == hp_c:
				return hp_c
		if _is_word_num(hlow) or _token_has_digit(piece):
			return _number_hex(full, start, end, fallback, gold, hp_c, atk_c, var_c, blk_c)
		return fallback
	if out_k != "":
		return fallback
	var low: String = piece.to_lower()
	for p in phrases:
		if low == str(p[0]):
			return str(p[1])
	var stem: String = _stem_hex(low, gold, hp_c, atk_c, var_c, blk_c)
	if stem != "":
		return stem
	for w in piece.split(" "):
		var inner: String = _stem_hex(w.strip_edges().to_lower(), gold, hp_c, atk_c, var_c, blk_c)
		if inner != "":
			return inner
	if _is_word_num(low) or _token_has_digit(piece):
		return _number_hex(full, start, end, fallback, gold, hp_c, atk_c, var_c, blk_c)
	return fallback


static func _token_left(s: String, from: int) -> Dictionary:
	var i: int = from - 1
	while i >= 0 and _is_paint_sep(s.substr(i, 1)):
		i -= 1
	if i < 0:
		return {}
	var j: int = i
	while j >= 0 and not _is_paint_sep(s.substr(j, 1)):
		j -= 1
	return {"t": s.substr(j + 1, i - j), "a": j + 1, "b": i + 1}


static func _token_right(s: String, from: int) -> Dictionary:
	var i: int = from
	while i < s.length() and _is_paint_sep(s.substr(i, 1)):
		i += 1
	if i >= s.length():
		return {}
	var j: int = i
	while j < s.length() and not _is_paint_sep(s.substr(j, 1)):
		j += 1
	return {"t": s.substr(i, j - i), "a": i, "b": j}


static func _scan_key_hex(full: String, from: int, going_left: bool, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> Dictionary:
	var cursor: int = from
	for _s in range(4):
		var tok: Dictionary = _token_left(full, cursor) if going_left else _token_right(full, cursor)
		if tok.is_empty():
			return {}
		var low: String = str(tok["t"]).to_lower()
		var hex: String = _stem_hex(low, gold, hp_c, atk_c, var_c, blk_c)
		if hex != "":
			return {"hex": hex, "d": (from - int(tok["b"])) if going_left else (int(tok["a"]) - from)}
		if _is_paint_glue(low):
			cursor = int(tok["a"]) if going_left else int(tok["b"])
			continue
		break
	return {}


static func _number_hex(full: String, start: int, end: int, fallback: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> String:
	var left: Dictionary = _scan_key_hex(full, start, true, gold, hp_c, atk_c, var_c, blk_c)
	var right: Dictionary = _scan_key_hex(full, end, false, gold, hp_c, atk_c, var_c, blk_c)
	var l_ok: bool = not left.is_empty()
	var r_ok: bool = not right.is_empty()
	if l_ok and r_ok:
		if int(left["d"]) <= int(right["d"]):
			return str(left["hex"])
		return str(right["hex"])
	if r_ok:
		return str(right["hex"])
	if l_ok:
		return str(left["hex"])
	return fallback


static func _ellipse_pts(c: Vector2, rx: float, ry: float, n: int = 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Soft floor contact under a fight sprite. Width is 70% of the sprite, 10px tall.
static func draw_floor_shadow(ci: CanvasItem, foot: Vector2, sprite_w: float) -> void:
	var rx: float = maxf(6.0, sprite_w * 0.35)
	var col := Color(0, 0, 0, 0.45)
	ci.draw_colored_polygon(_ellipse_pts(foot, rx, 5.0, 20), col)


## Code-drawn fight floor. obvious = Sprout's lit slab. The monster gets the same shape, smaller.
static func draw_stage_plinth(ci: CanvasItem, foot: Vector2, width: float, obvious: bool) -> void:
	var rx: float = maxf(24.0, width * 0.5)
	var ry: float = 11.0 if obvious else 7.0
	var shadow := INK_OUT
	shadow.a = 0.62 if obvious else 0.4
	ci.draw_colored_polygon(_ellipse_pts(foot + Vector2(0, 8.0), rx * 1.08, ry), shadow)
	var top_w: float = rx * 0.76
	var h: float = 30.0 if obvious else 16.0
	var slab := PackedVector2Array([
		foot + Vector2(-top_w, -h * 0.42),
		foot + Vector2(top_w, -h * 0.42),
		foot + Vector2(rx, h * 0.38),
		foot + Vector2(-rx, h * 0.38),
	])
	var top_c := GOLD if obvious else GOLD_DIM
	var bot_c := Color("1c140e")
	ci.draw_polygon(slab, PackedColorArray([top_c, top_c, bot_c, bot_c]))
	var rim := GOLD if obvious else INK_OUT
	var outline := slab.duplicate()
	outline.append(slab[0])
	ci.draw_polyline(outline, rim, 2.0 if obvious else 1.5, false)
	if obvious:
		var pool := INK
		pool.a = 0.72
		ci.draw_colored_polygon(_ellipse_pts(foot + Vector2(0, -4.0), top_w * 0.62, 5.5), pool)


## Flat gold bands, not a smooth gradient, so the beam stays in the pixel-art fight.
static func draw_spot_beam(ci: CanvasItem, head: Vector2, foot: Vector2, width: float) -> void:
	var top := Vector2(head.x, head.y - 46.0)
	var bot := Vector2(foot.x, foot.y + 6.0)
	var bands := 4
	var w0: float = 36.0
	var w1: float = maxf(width, 150.0)
	for i in bands:
		var t_a: float = float(i) / float(bands)
		var t_b: float = float(i + 1) / float(bands)
		var col := GOLD
		col.a = lerpf(0.34, 0.78, (t_a + t_b) * 0.5)
		var wa: float = lerpf(w0, w1, t_a)
		var wb: float = lerpf(w0, w1, t_b)
		var ya: float = lerpf(top.y, bot.y, t_a)
		var yb: float = lerpf(top.y, bot.y, t_b)
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(head.x - wa * 0.5, ya),
			Vector2(head.x + wa * 0.5, ya),
			Vector2(head.x + wb * 0.5, yb),
			Vector2(head.x - wb * 0.5, yb),
		]), col)
	var core := INK
	core.a = 0.55
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(head.x - 14.0, top.y),
		Vector2(head.x + 14.0, top.y),
		Vector2(head.x + w1 * 0.18, bot.y),
		Vector2(head.x - w1 * 0.18, bot.y),
	]), core)
