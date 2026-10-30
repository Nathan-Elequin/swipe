extends Control
class_name TrophyCase
## One biome case: body, glass pages (2×5), door, crown, lamp, sheet, plaque, PageBar.


signal case_hovered(pool_id: String, unlocked: bool)
signal case_unhovered
signal case_clicked(pool_id: String)
signal peg_hovered(item_id: String, peg: Control, peg_state: int)
signal peg_unhovered
signal peg_clicked(item_id: String)
signal page_changed(pool_id: String, page: int)
signal page_wheel(pool_id: String, dir: int)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0
const CELL_N := Vector2(24, 24)
const PAGE_N := Vector2(48, 120)
const CREST_PX := 48.0

var pool_id: String = ""
var case_index: int = 0
var case_spec: Dictionary = {}
var cabin = null
var zoomed: bool = false
var input_enabled: bool = true

var _state: int = BiomeCabinets.CaseState.LOCKED
var _slot_ids: Array = []
var _cards_by_id: Dictionary = {}
var _banked: Dictionary = {}
var _seen: Dictionary = {}
var _page: int = 0
var _page_count: int = 1
var _claimed: int = 0
var _quota: int = 5
var _flip_busy: bool = false
var _wheel_t: float = 0.0

var _body: TextureRect
var _glass: Control
var _page_strip: Control
var _pages: Dictionary = {}
var _page_bar: Control
var _door: AnimatedSprite2D
var _gild: TextureRect
var _crown: Control
var _crest: TextureRect
var _name_lab
var _pips: HBoxContainer
var _count_lab: Label
var _lamp: AnimatedSprite2D
var _lamp_glow: TextureRect
var _sheet_clip: Control
var _sheet_tex: TextureRect
var _hem_tex: TextureRect
var _sheet_crest: TextureRect
var _padlock: TextureRect
var _plaque: NinePatchRect
var _hit: Control
var _missing_logged: Dictionary = {}


func setup(
	p_cabin,
	p_index: int,
	p_spec: Dictionary,
	slot_cards: Array,
	banked: Dictionary,
	seen_map: Dictionary,
	case_state: int,
	claimed: int,
	quota: int,
	page: int
) -> void:
	cabin = p_cabin
	case_index = p_index
	case_spec = p_spec
	pool_id = str(p_spec.get("id", "b%d" % (p_index + 1)))
	name = "Case_%s" % pool_id
	_state = case_state
	_banked = banked
	_seen = seen_map
	_claimed = claimed
	_quota = quota
	_slot_ids.clear()
	_cards_by_id.clear()
	for raw in slot_cards:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id == "":
			continue
		_slot_ids.append(id)
		_cards_by_id[id] = card
	_page_count = BiomeCabinets.page_count(_slot_ids.size())
	_page = clampi(page, 0, _page_count - 1)
	var outer := BiomeCabinets.outer_rect(case_index)
	## Hole is full room; position in room px relative to hole origin (0,0).
	position = outer.position * PX
	size = outer.size * PX
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build()
	_apply_state(false)


func current_page() -> int:
	return _page


func peg_node(item_id: String) -> Control:
	for p in _pages.values():
		if not (p is Control):
			continue
		var n: Node = (p as Control).find_child("Peg_%s" % item_id, true, false)
		if n is Control:
			return n as Control
	return null


func set_zoomed(on: bool) -> void:
	zoomed = on
	_refresh_page_bar_hits()


func set_input_enabled(on: bool) -> void:
	input_enabled = on


func flare_lamp() -> void:
	if _lamp == null:
		return
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_lamp.modulate = Color(1.6, 1.6, 1.6, 1.0)
	tw.tween_property(_lamp, "modulate", Color.WHITE, 0.3)


func play_open_door() -> void:
	if _door == null or _door.sprite_frames == null:
		return
	if _door.sprite_frames.has_animation("swing"):
		_door.play("swing")
		await _door.animation_finished
	_door.play("open")


func set_crest_grey(grey: bool) -> void:
	if _crest == null:
		return
	if grey:
		var g: Texture2D = BiomeCabinets.trophy_grey_texture(case_spec)
		if g:
			_crest.texture = g
	else:
		var c: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
		if c:
			_crest.texture = c


func slide_sheet_off() -> void:
	if _sheet_clip == null or not _sheet_clip.visible:
		return
	var h: float = _sheet_clip.size.y
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(_sheet_clip, "position:y", _sheet_clip.position.y + h, 0.35)
	tw.parallel().tween_property(_sheet_clip, "modulate:a", 0.0, 0.1).set_delay(0.25)
	if _padlock:
		var ptw := create_tween()
		ptw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		ptw.tween_property(_padlock, "position:y", _padlock.position.y + 40.0 * PX / 4.0, 0.2)
		ptw.parallel().tween_property(_padlock, "modulate:a", 0.0, 0.2)
	await tw.finished
	_sheet_clip.visible = false


func flip_to_page(page: int, animate := true) -> void:
	page = clampi(page, 0, _page_count - 1)
	if page == _page and not animate:
		return
	if _flip_busy:
		return
	_ensure_pages_around(page)
	if not animate or _page_strip == null:
		_page = page
		if _page_strip:
			_page_strip.position.x = -float(page) * PAGE_N.x * PX
		_refresh_page_bar()
		page_changed.emit(pool_id, _page)
		return
	_flip_busy = true
	var from_x: float = _page_strip.position.x
	var to_x: float = -float(page) * PAGE_N.x * PX
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(v: float) -> void:
		if is_instance_valid(_page_strip):
			_page_strip.position.x = floor(v / PX) * PX
	, from_x, to_x, 0.18)
	await tw.finished
	_page = page
	_flip_busy = false
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	_refresh_page_bar()
	page_changed.emit(pool_id, _page)


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_pages.clear()
	var shape := BiomeCabinets.shape_of(case_index)
	## Body (b2 always draws Crystal Cavern frame over olive plate paint).
	if case_index == 1 or shape == "spires":
		_body = _tex("Body", str(case_spec.get("frame", "cabinets/case_crystal_cavern")), Vector2.ZERO, size)
		if _body.texture == null:
			_fallback_rect("BodyFallback", Color(Color("b4d6ea"), 0.35), Vector2.ZERO, size)
	## Glass
	var glass_n := BiomeCabinets.glass_rect(case_index)
	var outer_n := BiomeCabinets.outer_rect(case_index)
	var glass_local := (glass_n.position - outer_n.position) * PX
	_glass = Control.new()
	_glass.name = "Glass"
	_glass.position = glass_local
	_glass.size = glass_n.size * PX
	_glass.clip_contents = true
	_glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glass)
	_page_strip = Control.new()
	_page_strip.name = "PageStrip"
	_page_strip.position = Vector2.ZERO
	_page_strip.size = Vector2(PAGE_N.x * PX * float(_page_count), PAGE_N.y * PX)
	_page_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glass.add_child(_page_strip)
	_ensure_pages_around(_page)
	_page_strip.position.x = -float(_page) * PAGE_N.x * PX
	## Door
	_door = _make_door(shape)
	if _door:
		## Origin = glass rect − (14,4) native relative to case outer.
		var door_origin_room := glass_n.position - Vector2(14, 4)
		_door.position = (door_origin_room - outer_n.position) * PX
		_door.centered = false
		_door.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_door.z_index = 4
		add_child(_door)
	## Gild
	_gild = _tex("Gild", "cabinets/case_gild_%s" % shape, _sheet_origin_local(shape), _sheet_size(shape))
	if _gild:
		_gild.z_index = 5
		_gild.visible = false
	## Crown
	_build_crown(outer_n)
	## Lamp
	_build_lamp(outer_n)
	## Sheet
	_build_sheet(shape, outer_n)
	## PageBar
	_build_page_bar(glass_n, outer_n)
	## Plaque
	_build_plaque(outer_n)
	## Case hit
	_hit = Control.new()
	_hit.name = "CaseHit"
	_hit.position = Vector2.ZERO
	_hit.size = size
	_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_hit.z_index = 8
	_hit.gui_input.connect(_on_case_input)
	_hit.mouse_entered.connect(_on_case_enter)
	_hit.mouse_exited.connect(_on_case_exit)
	add_child(_hit)


func _sheet_origin_local(shape: String) -> Vector2:
	var outer_n := BiomeCabinets.outer_rect(case_index)
	if shape == "spires":
		return (BiomeCabinets.SPIRES_SHEET_ORIGIN - outer_n.position) * PX
	var glass_n := BiomeCabinets.glass_rect(case_index)
	var origin := glass_n.position - Vector2(8, 32)
	return (origin - outer_n.position) * PX


func _sheet_size(shape: String) -> Vector2:
	if shape == "spires":
		return Vector2(64, 180) * PX
	return Vector2(56, 166) * PX


func _build_crown(outer_n: Rect2) -> void:
	var cr := BiomeCabinets.crown_rect(case_index)
	_crown = Control.new()
	_crown.name = "Crown"
	_crown.position = (cr.position - outer_n.position) * PX
	_crown.size = cr.size * PX
	_crown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crown.z_index = 6
	add_child(_crown)
	_crest = TextureRect.new()
	_crest.name = "Crest"
	_crest.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_crest.stretch_mode = TextureRect.STRETCH_SCALE
	_crest.size = Vector2(CREST_PX, CREST_PX)
	_crest.position = Vector2(( _crown.size.x - CREST_PX) * 0.5, -CREST_PX * 0.55)
	_crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var idle: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
	if idle:
		_crest.texture = idle
	_crest.set_meta("idle", idle)
	_crest.set_meta("hover", BiomeCabinets.trophy_texture(case_spec, true))
	_crest.set_meta("grey", BiomeCabinets.trophy_grey_texture(case_spec))
	_crown.add_child(_crest)
	var name_col := Color("efe0b6")
	var nm := str(case_spec.get("name", ""))
	if case_index == 1 or case_index == 2:
		name_col = Color("1e120c")
	var name_lab := Label.new()
	name_lab.name = "Name"
	name_lab.text = nm
	name_lab.add_theme_font_size_override("font_size", 14)
	name_lab.add_theme_color_override("font_color", name_col)
	name_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lab.size = _crown.size
	name_lab.position = Vector2.ZERO
	name_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crown.add_child(name_lab)
	_name_lab = name_lab
	_pips = HBoxContainer.new()
	_pips.name = "Pips"
	_pips.add_theme_constant_override("separation", int(PX))
	_pips.position = Vector2((_crown.size.x - (5.0 * 12.0 + 4.0 * 4.0)) * 0.5, _crown.size.y + 2.0)
	_pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crown.add_child(_pips)
	for i in 5:
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(12, 12)
		pip.size = Vector2(12, 12)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pips.add_child(pip)
	_count_lab = Label.new()
	_count_lab.name = "Count"
	_count_lab.add_theme_font_size_override("font_size", 12)
	_count_lab.add_theme_color_override("font_color", name_col)
	_count_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_lab.position = Vector2(0, _crown.size.y + 16.0)
	_count_lab.size = Vector2(_crown.size.x, 16)
	_count_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crown.add_child(_count_lab)


func _build_lamp(outer_n: Rect2) -> void:
	var lamp_at := BiomeCabinets.lamp_anchor(case_index)
	_lamp = AnimatedSprite2D.new()
	_lamp.name = "Lamp"
	_lamp.centered = false
	_lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lamp.position = (lamp_at - Vector2(4, 0) - outer_n.position) * PX
	_lamp.z_index = 7
	var sf := SpriteFrames.new()
	sf.add_animation("off")
	sf.set_animation_loop("off", false)
	var off_tex: Texture2D = KIT.load_tex("cabinets/case_lamp_off")
	if off_tex:
		sf.add_frame("off", off_tex)
	sf.add_animation("on")
	sf.set_animation_loop("on", true)
	sf.set_animation_speed("on", 1000.0 / 140.0)
	for fi in 3:
		var ft: Texture2D = KIT.load_tex("cabinets/case_lamp_on_f%d" % fi)
		if ft:
			sf.add_frame("on", ft)
	_lamp.sprite_frames = sf
	_lamp.play("off")
	add_child(_lamp)
	_lamp_glow = TextureRect.new()
	_lamp_glow.name = "LampGlow"
	_lamp_glow.texture = KIT.load_tex("lantern_glow")
	_lamp_glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lamp_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lamp_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_lamp_glow.size = Vector2(35, 37) * PX / 4.0 * 4.0  ## shipped size
	if _lamp_glow.texture:
		_lamp_glow.size = _lamp_glow.texture.get_size()
	_lamp_glow.position = _lamp.position + Vector2(-_lamp_glow.size.x * 0.35, 8)
	_lamp_glow.modulate = Color("f09a34", 0.5)
	_lamp_glow.visible = false
	_lamp_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lamp_glow.material = mat
	_lamp_glow.z_index = 6
	add_child(_lamp_glow)


func _build_sheet(shape: String, _outer_n: Rect2) -> void:
	_sheet_clip = Control.new()
	_sheet_clip.name = "Sheet"
	_sheet_clip.position = _sheet_origin_local(shape)
	_sheet_clip.size = _sheet_size(shape)
	_sheet_clip.clip_contents = true
	_sheet_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet_clip.z_index = 9
	add_child(_sheet_clip)
	_sheet_tex = _tex_child(_sheet_clip, "SheetTex", "cabinets/case_sheet_%s" % shape, Vector2.ZERO, _sheet_clip.size)
	_hem_tex = _tex_child(_sheet_clip, "Hem", "cabinets/case_sheet_%s_hem" % shape, Vector2.ZERO, _sheet_clip.size)
	if _hem_tex:
		var accent := Color(str(case_spec.get("accent", "7dae62")))
		_hem_tex.modulate = accent
	_sheet_crest = TextureRect.new()
	_sheet_crest.name = "SheetCrest"
	_sheet_crest.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sheet_crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sheet_crest.stretch_mode = TextureRect.STRETCH_SCALE
	_sheet_crest.size = Vector2(CREST_PX, CREST_PX)
	_sheet_crest.position = Vector2((_sheet_clip.size.x - CREST_PX) * 0.5, _sheet_clip.size.y * 0.40 - CREST_PX * 0.5)
	var crest_tex: Texture2D = BiomeCabinets.trophy_texture(case_spec, false)
	if crest_tex:
		_sheet_crest.texture = crest_tex
	_sheet_crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet_clip.add_child(_sheet_crest)
	_padlock = TextureRect.new()
	_padlock.name = "Padlock"
	_padlock.texture = KIT.load_tex("cabinets/case_padlock")
	_padlock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_padlock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_padlock.stretch_mode = TextureRect.STRETCH_SCALE
	_padlock.size = Vector2(10, 12) * PX
	_padlock.position = Vector2((_sheet_clip.size.x - _padlock.size.x) * 0.5, _sheet_clip.size.y * 0.58)
	_padlock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet_clip.add_child(_padlock)


func _build_page_bar(glass_n: Rect2, outer_n: Rect2) -> void:
	if _page_count <= 1:
		_page_bar = null
		return
	_page_bar = Control.new()
	_page_bar.name = "PageBar"
	var bar_n := Rect2(glass_n.position.x, float(BiomeCabinets.PAGE_BAR_Y), glass_n.size.x, float(BiomeCabinets.PAGE_BAR_H))
	_page_bar.position = (bar_n.position - outer_n.position) * PX
	## Hit strip pads 4 native up into glass and down to plaque.
	_page_bar.size = Vector2(bar_n.size.x * PX, (bar_n.size.y + 8.0) * PX)
	_page_bar.position.y -= 4.0 * PX
	_page_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	_page_bar.z_index = 7
	_page_bar.gui_input.connect(_on_page_bar_input)
	add_child(_page_bar)
	_refresh_page_bar()


func _refresh_page_bar() -> void:
	if _page_bar == null:
		return
	for c in _page_bar.get_children():
		_page_bar.remove_child(c)
		c.queue_free()
	var chev: Texture2D = KIT.load_tex("cabinets/case_page_chevron")
	var chev_h: Texture2D = KIT.load_tex("cabinets/case_page_chevron_hover")
	var left := TextureRect.new()
	left.name = "ChevL"
	left.texture = chev
	left.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	left.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	left.stretch_mode = TextureRect.STRETCH_SCALE
	left.size = Vector2(4, 5) * PX
	left.position = Vector2(2 * PX, (_page_bar.size.y - left.size.y) * 0.5)
	left.modulate.a = 0.35 if _page <= 0 else 1.0
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_bar.add_child(left)
	var right := TextureRect.new()
	right.name = "ChevR"
	right.texture = chev
	right.flip_h = true
	right.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	right.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	right.stretch_mode = TextureRect.STRETCH_SCALE
	right.size = Vector2(4, 5) * PX
	right.position = Vector2(_page_bar.size.x - right.size.x - 2 * PX, (_page_bar.size.y - right.size.y) * 0.5)
	right.modulate.a = 0.35 if _page >= _page_count - 1 else 1.0
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_bar.add_child(right)
	## Ticks windowed to 7.
	var max_show := mini(7, _page_count)
	var start := 0
	if _page_count > 7:
		start = clampi(_page - 3, 0, _page_count - 7)
	var tick_w := 12.0
	var gap := 8.0
	var total_w := float(max_show) * tick_w + float(maxi(0, max_show - 1)) * gap
	var x0 := (_page_bar.size.x - total_w) * 0.5
	var banked_claim := _banked
	for ti in max_show:
		var pi := start + ti
		var tick := Panel.new()
		tick.name = "Tick_%d" % pi
		tick.custom_minimum_size = Vector2(tick_w, tick_w)
		tick.size = Vector2(tick_w, tick_w)
		tick.position = Vector2(x0 + float(ti) * (tick_w + gap), (_page_bar.size.y - tick_w) * 0.5)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var col := Color("3a2a1c")
		if BiomeCabinets.page_state(_slot_ids, pi, banked_claim) == BiomeCabinets.PageState.PAGE_FULL:
			col = Color("ffd84a")
		if pi == _page:
			col = Color("f09a34")
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.border_color = Color("1e120c")
		sb.set_border_width_all(4)
		tick.add_theme_stylebox_override("panel", sb)
		_page_bar.add_child(tick)
	_refresh_page_bar_hits()
	## Store hover alts
	left.set_meta("hover", chev_h)
	right.set_meta("hover", chev_h)


func _refresh_page_bar_hits() -> void:
	if _page_bar == null:
		return
	## Overview: whole bar is one hit (already). Zoom: expose chevron/tick hits via gui.
	_page_bar.mouse_filter = Control.MOUSE_FILTER_STOP if _state != BiomeCabinets.CaseState.LOCKED else Control.MOUSE_FILTER_IGNORE


func _build_plaque(outer_n: Rect2) -> void:
	var pr := BiomeCabinets.plaque_rect(case_index)
	_plaque = NinePatchRect.new()
	_plaque.name = "Plaque"
	_plaque.texture = KIT.load_tex("cabinets/case_plaque_9")
	_plaque.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_plaque.patch_margin_left = 16
	_plaque.patch_margin_top = 16
	_plaque.patch_margin_right = 16
	_plaque.patch_margin_bottom = 16
	_plaque.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	_plaque.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	_plaque.position = (pr.position - outer_n.position) * PX
	_plaque.size = pr.size * PX
	_plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque.z_index = 3
	add_child(_plaque)
	## Depth bars
	var bars := HBoxContainer.new()
	bars.name = "DepthBars"
	bars.add_theme_constant_override("separation", int(PX))
	bars.position = Vector2(4, (_plaque.size.y - 20) * 0.5)
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque.add_child(bars)
	var depth := case_index + 1
	for i in 5:
		var bar := Panel.new()
		bar.custom_minimum_size = Vector2(8, 20)
		bar.size = Vector2(8, 20)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("ffd84a") if i < depth else Color("4a3020")
		sb.border_color = Color("1e120c")
		sb.set_border_width_all(1)
		bar.add_theme_stylebox_override("panel", sb)
		bars.add_child(bar)
	var ordinals: Array[String] = ["1st", "2nd", "3rd", "4th", "5th"]
	var ordinal_fallback: String = ordinals[clampi(depth - 1, 0, 4)]
	var ordinal: String = COPY.fill("cabin.hall.ordinal_%d" % depth, {}, ordinal_fallback)
	var plaque_txt: String = COPY.fill(
		"cabin.hall.plaque",
		{"ordinal": ordinal},
		"Wares of the %s Depth and below" % ordinal
	)
	var lab := Label.new()
	lab.name = "PlaqueLabel"
	lab.text = plaque_txt
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.add_theme_font_size_override("font_size", 10)
	lab.add_theme_color_override("font_color", Color("1e120c"))
	lab.position = Vector2(bars.position.x + 5.0 * 8.0 + 4.0 * 4.0 + 4.0, 2)
	lab.size = Vector2(maxi(8.0, _plaque.size.x - lab.position.x - 4.0), _plaque.size.y - 4.0)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque.add_child(lab)


func _make_door(shape: String) -> AnimatedSprite2D:
	var door_shape := "arch" if shape == "arch" else "rect"
	var spr := AnimatedSprite2D.new()
	spr.name = "Door"
	var sf := SpriteFrames.new()
	sf.add_animation("shut")
	sf.set_animation_loop("shut", false)
	sf.add_animation("open")
	sf.set_animation_loop("open", false)
	sf.add_animation("swing")
	sf.set_animation_loop("swing", false)
	sf.set_animation_speed("swing", 10.0)
	for fi in 4:
		var t: Texture2D = KIT.load_tex("cabinets/case_door_%s_f%d" % [door_shape, fi])
		if t == null:
			continue
		if fi == 0:
			sf.add_frame("shut", t)
		if fi == 3:
			sf.add_frame("open", t)
		sf.add_frame("swing", t)
	spr.sprite_frames = sf
	return spr


func _ensure_pages_around(center: int) -> void:
	for p in range(maxi(0, center - 1), mini(_page_count, center + 2)):
		if _pages.has(p):
			continue
		_pages[p] = _build_page(p)


func _build_page(page: int) -> Control:
	var page_n := Control.new()
	page_n.name = "Page_%d" % page
	page_n.position = Vector2(float(page) * PAGE_N.x * PX, 0)
	page_n.size = PAGE_N * PX
	page_n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_strip.add_child(page_n)
	var start := page * BiomeCabinets.PAGE_SLOTS
	for cell_i in BiomeCabinets.PAGE_SLOTS:
		var gi := start + cell_i
		var col := cell_i % 2
		var row := int(cell_i / 2)
		var cell_pos := Vector2(float(col) * CELL_N.x, float(row) * CELL_N.y) * PX
		if gi >= _slot_ids.size():
			_build_empty_recess(page_n, cell_pos)
			continue
		var id := str(_slot_ids[gi])
		var card: Dictionary = _cards_by_id.get(id, {"id": id, "name": id})
		_build_peg(page_n, cell_pos, card)
	return page_n


func _build_empty_recess(host: Control, pos: Vector2) -> void:
	var wrap := Control.new()
	wrap.name = "EmptyRecess"
	wrap.position = pos
	wrap.size = CELL_N * PX
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(wrap)
	_add_recess(wrap)
	_add_ledge(wrap)


func _build_peg(host: Control, pos: Vector2, card: Dictionary) -> void:
	var id := str(card.get("id", ""))
	var wrap := Control.new()
	wrap.name = "Peg_%s" % id
	wrap.position = pos
	wrap.size = CELL_N * PX
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.set_meta("item_id", id)
	host.add_child(wrap)
	_add_recess(wrap)
	var pst := BiomeCabinets.peg_state(id, _banked, _seen)
	## Item
	var item := TextureRect.new()
	item.name = "Item"
	item.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_SCALE
	item.position = Vector2(4, 0) * PX
	item.size = Vector2(16, 16) * PX
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = null
	if cabin != null:
		tex = cabin.tex_by_item.get(id, null) if "tex_by_item" in cabin else null
		if tex == null and cabin.art != null and cabin.art.has_method("item_tex"):
			tex = cabin.art.item_tex(id)
	item.texture = tex
	match pst:
		BiomeCabinets.PegState.UNSEEN:
			item.modulate = Color(0.09, 0.07, 0.06)
		BiomeCabinets.PegState.SEEN:
			item.modulate = Color(0.55, 0.55, 0.58)
		_:
			item.modulate = Color.WHITE
	wrap.add_child(item)
	if pst == BiomeCabinets.PegState.SEEN:
		var hatch := TextureRect.new()
		hatch.name = "Hatch"
		hatch.texture = KIT.load_tex("cabinets/item_seen_hatch")
		hatch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hatch.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hatch.stretch_mode = TextureRect.STRETCH_SCALE
		hatch.position = item.position
		hatch.size = item.size
		hatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(hatch)
	_add_ledge(wrap)
	## Placard
	var placard := NinePatchRect.new()
	placard.name = "Placard"
	var stem := "cabinets/placard_blank_9"
	if pst == BiomeCabinets.PegState.SEEN:
		stem = "cabinets/placard_seen_9"
	elif pst == BiomeCabinets.PegState.CLAIMED:
		stem = "cabinets/placard_gold_9"
	placard.texture = KIT.load_tex(stem)
	placard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	placard.patch_margin_left = 12
	placard.patch_margin_right = 12
	placard.patch_margin_top = 4
	placard.patch_margin_bottom = 4
	placard.position = Vector2(1, 19) * PX
	placard.size = Vector2(22, 5) * PX
	placard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(placard)
	if pst != BiomeCabinets.PegState.UNSEEN:
		var ink := Color("1e120c") if pst == BiomeCabinets.PegState.CLAIMED else Color("6e6e6e")
		var nm := str(card.get("name", id)).to_upper()
		var lab := Label.new()
		lab.name = "Label"
		lab.text = nm
		lab.add_theme_font_size_override("font_size", 10)
		lab.add_theme_color_override("font_color", ink)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.position = Vector2(PX, 0)
		lab.size = placard.size - Vector2(2 * PX, 0)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.clip_text = true
		placard.add_child(lab)
	if pst == BiomeCabinets.PegState.CLAIMED:
		_arm_twinkle(wrap)
	## Zoom hit
	var hit := Control.new()
	hit.name = "PegHit"
	hit.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	hit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hit.gui_input.connect(_on_peg_input.bind(id, wrap, pst))
	hit.mouse_entered.connect(_on_peg_enter.bind(id, wrap, pst))
	hit.mouse_exited.connect(_on_peg_exit)
	wrap.add_child(hit)
	wrap.set_meta("peg_state", pst)
	wrap.set_meta("hit", hit)


func _add_recess(wrap: Control) -> void:
	var recess := Panel.new()
	recess.name = "Recess"
	recess.position = Vector2(1, 0) * PX
	recess.size = Vector2(22, 17) * PX
	recess.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("120c09")
	sb.border_color = Color("2b1a12")
	sb.set_border_width_all(4)
	recess.add_theme_stylebox_override("panel", sb)
	wrap.add_child(recess)


func _add_ledge(wrap: Control) -> void:
	var ledge := Panel.new()
	ledge.name = "Ledge"
	ledge.position = Vector2(0, 17) * PX
	ledge.size = Vector2(24, 2) * PX
	ledge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("5c3a22")
	sb.border_color = Color("8a5a32")
	sb.border_width_top = 4
	ledge.add_theme_stylebox_override("panel", sb)
	wrap.add_child(ledge)


func _arm_twinkle(wrap: Control) -> void:
	var twinkle := AnimatedSprite2D.new()
	twinkle.name = "Twinkle"
	twinkle.centered = false
	twinkle.position = Vector2(16, -2) * PX
	twinkle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sf := SpriteFrames.new()
	sf.add_animation("glint")
	sf.set_animation_loop("glint", false)
	sf.set_animation_speed("glint", 1000.0 / 60.0)
	for fi in 4:
		var t: Texture2D = KIT.load_tex("plaque_glint_f%d" % fi)
		if t:
			sf.add_frame("glint", t)
	twinkle.sprite_frames = sf
	twinkle.visible = false
	wrap.add_child(twinkle)
	var timer := Timer.new()
	timer.name = "TwinkleTimer"
	timer.one_shot = true
	timer.wait_time = randf_range(3.0, 6.0)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(twinkle):
			return
		twinkle.visible = true
		twinkle.play("glint")
		await twinkle.animation_finished
		if is_instance_valid(twinkle):
			twinkle.visible = false
		if is_instance_valid(timer):
			timer.wait_time = randf_range(3.0, 6.0)
			timer.start()
	)
	wrap.add_child(timer)
	timer.start()


func _apply_state(_animate: bool) -> void:
	var locked := _state == BiomeCabinets.CaseState.LOCKED
	var opened := _state == BiomeCabinets.CaseState.OPENED or _state == BiomeCabinets.CaseState.COMPLETE
	var complete := _state == BiomeCabinets.CaseState.COMPLETE
	if _sheet_clip:
		_sheet_clip.visible = locked
	if _door:
		_door.visible = not locked
		if opened:
			_door.play("open")
		else:
			_door.play("shut")
	if _lamp:
		if opened:
			_lamp.play("on")
			if _lamp_glow:
				_lamp_glow.visible = true
		else:
			_lamp.play("off")
			if _lamp_glow:
				_lamp_glow.visible = false
	if _gild:
		_gild.visible = complete
	if _crest:
		if locked:
			pass
		elif _state == BiomeCabinets.CaseState.IN_PROGRESS:
			var g: Texture2D = _crest.get_meta("grey", null)
			if g:
				_crest.texture = g
		else:
			var idle: Texture2D = _crest.get_meta("idle", null)
			if idle:
				_crest.texture = idle
	## Crown hidden under sheet when locked
	if _crown:
		_crown.visible = not locked
	_refresh_pips()
	if _count_lab:
		_count_lab.text = BiomeCabinets.crown_text(_claimed, _slot_ids.size())
	if _page_bar:
		_page_bar.visible = not locked and _page_count > 1
	## Peg hits only in zoom
	_set_peg_hits(zoomed and not locked)


func _refresh_pips() -> void:
	if _pips == null:
		return
	var lit := BiomeCabinets.pips_lit(_claimed, _quota)
	var i := 0
	for child in _pips.get_children():
		if not (child is Panel):
			continue
		var on := i < lit
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("ffd84a") if on else Color("3a2a1c")
		sb.border_color = Color("1a120e")
		sb.set_border_width_all(4)
		(child as Panel).add_theme_stylebox_override("panel", sb)
		i += 1


func _set_peg_hits(on: bool) -> void:
	for p in _pages.values():
		if not (p is Control):
			continue
		for child in (p as Control).get_children():
			if not (child is Control):
				continue
			var hit_v: Variant = (child as Control).get_meta("hit", null)
			if hit_v is Control:
				(hit_v as Control).mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE


func _on_case_enter() -> void:
	if not input_enabled:
		return
	if _crest and _state != BiomeCabinets.CaseState.LOCKED and _state != BiomeCabinets.CaseState.IN_PROGRESS:
		var h: Texture2D = _crest.get_meta("hover", null)
		if h:
			_crest.texture = h
	elif _crest and _state == BiomeCabinets.CaseState.IN_PROGRESS:
		var h2: Texture2D = _crest.get_meta("hover", null)
		if h2:
			_crest.texture = h2
	case_hovered.emit(pool_id, _state != BiomeCabinets.CaseState.LOCKED)


func _on_case_exit() -> void:
	if _crest:
		if _state == BiomeCabinets.CaseState.IN_PROGRESS:
			var g: Texture2D = _crest.get_meta("grey", null)
			if g:
				_crest.texture = g
		else:
			var idle: Texture2D = _crest.get_meta("idle", null)
			if idle:
				_crest.texture = idle
	case_unhovered.emit()


func _on_case_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var btn := event as InputEventMouseButton
		if btn.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_try_wheel(1)
			accept_event()
			return
		if btn.button_index == MOUSE_BUTTON_WHEEL_UP:
			_try_wheel(-1)
			accept_event()
			return
		if btn.button_index == MOUSE_BUTTON_LEFT:
			case_clicked.emit(pool_id)
			accept_event()


func _on_page_bar_input(event: InputEvent) -> void:
	if not input_enabled or _page_bar == null:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var btn := event as InputEventMouseButton
		if btn.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_try_wheel(1)
			accept_event()
			return
		if btn.button_index == MOUSE_BUTTON_WHEEL_UP:
			_try_wheel(-1)
			accept_event()
			return
		if btn.button_index != MOUSE_BUTTON_LEFT:
			return
		var local_x: float = _page_bar.get_local_mouse_position().x
		if zoomed:
			## Chevrons / ticks
			if local_x < _page_bar.size.x * 0.2:
				flip_to_page(_page - 1)
			elif local_x > _page_bar.size.x * 0.8:
				flip_to_page(_page + 1)
			else:
				## Approximate tick jump by x fraction
				var frac := clampf((local_x - _page_bar.size.x * 0.2) / maxf(1.0, _page_bar.size.x * 0.6), 0.0, 0.999)
				var target := int(floor(frac * float(_page_count)))
				flip_to_page(target)
		else:
			if local_x < _page_bar.size.x * 0.5:
				flip_to_page(_page - 1)
			else:
				flip_to_page(_page + 1)
		accept_event()


func _try_wheel(dir: int) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _wheel_t < 0.2:
		return
	_wheel_t = now
	page_wheel.emit(pool_id, dir)
	flip_to_page(_page + dir)


func _on_peg_enter(item_id: String, peg: Control, pst: int) -> void:
	if not zoomed or not input_enabled:
		return
	## Amber frame
	if peg.get_node_or_null("HoverFrame") == null:
		var frame := Panel.new()
		frame.name = "HoverFrame"
		frame.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_color = Color("f09a34")
		sb.set_border_width_all(4)
		frame.add_theme_stylebox_override("panel", sb)
		peg.add_child(frame)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
	peg_hovered.emit(item_id, peg, pst)


func _on_peg_exit() -> void:
	peg_unhovered.emit()


func _on_peg_input(event: InputEvent, item_id: String, _peg: Control, pst: int) -> void:
	if not zoomed or not input_enabled:
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var btn := event as InputEventMouseButton
		if btn.button_index == MOUSE_BUTTON_RIGHT:
			return  ## zoom-out handled by cabin
		if btn.button_index == MOUSE_BUTTON_LEFT:
			if pst == BiomeCabinets.PegState.UNSEEN:
				return
			peg_clicked.emit(item_id)
			accept_event()


func _tex(node_name: String, rel: String, pos: Vector2, sz: Vector2) -> TextureRect:
	var tr := TextureRect.new()
	tr.name = node_name
	tr.texture = KIT.load_tex(rel)
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.position = pos
	tr.size = sz
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tr.texture == null:
		_log_missing(rel)
	add_child(tr)
	return tr


func _tex_child(host: Control, node_name: String, rel: String, pos: Vector2, sz: Vector2) -> TextureRect:
	var tr := TextureRect.new()
	tr.name = node_name
	tr.texture = KIT.load_tex(rel)
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.position = pos
	tr.size = sz
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tr.texture == null:
		_log_missing(rel)
	host.add_child(tr)
	return tr


func _fallback_rect(node_name: String, col: Color, pos: Vector2, sz: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.name = node_name
	r.color = col
	r.position = pos
	r.size = sz
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _log_missing(rel: String) -> void:
	if _missing_logged.has(rel):
		return
	_missing_logged[rel] = true
	push_warning("TrophyCase missing art: %s (pool %s)" % [rel, pool_id])
