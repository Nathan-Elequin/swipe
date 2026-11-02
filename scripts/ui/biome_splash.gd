extends CanvasLayer
## Biome-enter story splash. Layout locked in design/biome-enter-splash/SCREEN-biome-enter-splash.md.
## All player words come from PLAYER_COPY keys. Never invent copy. Never show Tier.

signal dismissed
signal play_in_done

const PLAYER_COPY := preload("res://scripts/player_copy.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const ART_H := 832.0
## Grew 208 → 236 (#295) → 340 for Spin-locked first-person paragraphs (≤5 lines + cue).
const BAR_H := 340.0
const NARR_PAD_X := 64.0
const NARR_PAD_Y := 28.0
const NARR_LINE_PX := 42.0
const NARR_MAX_LINES := 5
const CUE_W := 280.0
const CUE_H := 28.0
const CUE_RIGHT := 56.0
const CUE_BOTTOM := 30.0
const CUE_GAP := 10.0
const SPROUT_PATH := "res://assets/dungeon/anim/player/sprout_idle_f0.png"
const LEAF_PATH := "res://assets/ui/biome_splash/cue_leaf_placeholder.png"
const LEAF_FINAL := "res://assets/ui/biome_splash/cue_leaf.png"
## Campaign tip biomes that always get a splash (narration may be blank).
const CAMPAIGN_BIOME_IDS := ["b1", "b2", "b3", "b4", "b5"]
## Chrome / narration / cue sit above BiomeAmbient near bands (absolute z 9).
const CHROME_Z := 50

var _root: Control
var _art: TextureRect
var _sprout: TextureRect
var _ambient_host: Node2D
var _narration: Label
var _cue_leaf: TextureRect
var _cue_label: Label
var _chrome_biome: Label
var _chrome_dungeon: Label
var _chrome_delves: Label
var _chrome_box: VBoxContainer
var _narration_bar: Panel
var _cue_row: HBoxContainer
var _in_tween: Tween
var _cue_tween: Tween
var _page_tween: Tween
var _skipped: bool = false
var _dismissed_emitted: bool = false
var _play_in_finished: bool = false
var _built: bool = false
var _biome_id: String = ""
var _ctx: Dictionary = {}
var _hosted_ambient: Node = null
var _ambient_home: Node = null
var _ambient_home_index: int = -1
## Multi-page narration (same BG / chrome). Click advances; last page dismisses.
var _pages: PackedStringArray = PackedStringArray()
var _page_index: int = 0
var _page_swap_busy: bool = false


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "BiomeSplash"


func play_in(biome_id: String, ctx: Dictionary) -> void:
	_biome_id = str(biome_id)
	_ctx = ctx.duplicate(true) if typeof(ctx) == TYPE_DICTIONARY else {}
	_skipped = false
	_dismissed_emitted = false
	_play_in_finished = false
	_page_index = 0
	_page_swap_busy = false
	_build()
	_root.modulate.a = 0.0
	visible = true
	_in_tween = create_tween()
	_in_tween.set_trans(Tween.TRANS_SINE)
	_in_tween.set_ease(Tween.EASE_IN_OUT)
	_in_tween.tween_property(_root, "modulate:a", 1.0, 0.35)
	_in_tween.finished.connect(_on_play_in_tween_finished, CONNECT_ONE_SHOT)
	await play_in_done


func wait_dismissed() -> void:
	if _skipped or _dismissed_emitted:
		return
	await dismissed


func play_out() -> void:
	if _in_tween != null and is_instance_valid(_in_tween):
		_in_tween.kill()
		_in_tween = null
	if _cue_tween != null and is_instance_valid(_cue_tween):
		_cue_tween.kill()
		_cue_tween = null
	if _page_tween != null and is_instance_valid(_page_tween):
		_page_tween.kill()
		_page_tween = null
	## Detach ambient first so the splash fade does not dim particles; the same
	## kit continues on the play field with no rebuild / preprocess flash.
	detach_ambient()
	if _root == null or not is_instance_valid(_root):
		queue_free()
		return
	var start_a: float = _root.modulate.a
	# Never jump alpha up — fade from whatever the skip left.
	var tw := create_tween()
	tw.tween_property(_root, "modulate:a", 0.0, 0.20)
	await tw.finished
	# Guard: play_out must not raise alpha above start_a at any point.
	if is_instance_valid(_root) and _root.modulate.a > start_a + 0.001:
		_root.modulate.a = start_a
	queue_free()


## Host the shared BiomeAmbient over splash art (in front of art, behind chrome).
## Prefer reparenting the live kit over a second particle system.
func attach_ambient(ambient: Node) -> void:
	if ambient == null or not is_instance_valid(ambient):
		return
	if not _built:
		_build()
	if _ambient_host == null or not is_instance_valid(_ambient_host):
		return
	if _hosted_ambient == ambient:
		return
	detach_ambient()
	_hosted_ambient = ambient
	_ambient_home = ambient.get_parent()
	_ambient_home_index = ambient.get_index() if _ambient_home != null else -1
	if _ambient_home != null:
		_ambient_home.remove_child(ambient)
	_ambient_host.add_child(ambient)
	if ambient.has_method("setup"):
		ambient.call("setup", Vector2(DESIGN.x, ART_H))
	if ambient.has_method("mouse_filter_ignore_tree"):
		ambient.call("mouse_filter_ignore_tree")


func detach_ambient() -> void:
	if _hosted_ambient == null:
		return
	var ambient: Node = _hosted_ambient
	_hosted_ambient = null
	if is_instance_valid(ambient) and ambient.get_parent() == _ambient_host:
		_ambient_host.remove_child(ambient)
	if is_instance_valid(ambient) and _ambient_home != null and is_instance_valid(_ambient_home):
		_ambient_home.add_child(ambient)
		if _ambient_home_index >= 0:
			var max_i: int = maxi(0, _ambient_home.get_child_count() - 1)
			_ambient_home.move_child(ambient, mini(_ambient_home_index, max_i))
		if ambient.has_method("setup"):
			ambient.call("setup", Vector2(DESIGN.x, DESIGN.y))
	_ambient_home = null
	_ambient_home_index = -1


func hosted_ambient() -> Node:
	return _hosted_ambient


func ambient_emitting() -> bool:
	if _hosted_ambient == null or not is_instance_valid(_hosted_ambient):
		return false
	if _hosted_ambient.has_method("total_particle_amount"):
		if int(_hosted_ambient.call("total_particle_amount")) <= 0:
			return false
	if _hosted_ambient.has_method("is_enabled") and not bool(_hosted_ambient.call("is_enabled")):
		return false
	## Any kit emitter still on counts as "emitting during splash".
	for name in ["FarSpores", "HollowFireflies"]:
		var p: Node = _hosted_ambient.get_node_or_null(name)
		if p is CPUParticles2D and (p as CPUParticles2D).emitting:
			return true
	var near_l: Node = _hosted_ambient.find_child("NearMossL", true, false)
	if near_l is CPUParticles2D and (near_l as CPUParticles2D).emitting:
		return true
	return false


func narration_text() -> String:
	if _narration == null:
		return ""
	return str(_narration.text)


func narration_page_index() -> int:
	return _page_index


func narration_page_count() -> int:
	return _pages.size()


func chrome_texts() -> Dictionary:
	return {
		"biome": str(_chrome_biome.text) if _chrome_biome else "",
		"dungeon": str(_chrome_dungeon.text) if _chrome_dungeon else "",
		"delves": str(_chrome_delves.text) if _chrome_delves else "",
		"continue": str(_cue_label.text) if _cue_label else "",
	}


func was_skipped() -> bool:
	return _skipped


func current_alpha() -> float:
	if _root == null:
		return 0.0
	return _root.modulate.a


static func biome_slug(biome_name: String) -> String:
	return str(biome_name).strip_edges().to_lower().replace(" ", "_")


## Legacy single-string key (unused fallback only once .p1/.p2/.p3 exist).
static func narration_key_for_name(biome_name: String) -> String:
	return "splash.biome.%s" % biome_slug(biome_name)


static func narration_page_key(biome_name: String, page: int) -> String:
	return "splash.biome.%s.p%d" % [biome_slug(biome_name), page]


## Ordered page texts for a biome. Prefers .p1/.p2/.p3; legacy single key is fallback only.
static func narration_pages_for_name(biome_name: String) -> PackedStringArray:
	var pages := PackedStringArray()
	for i in range(1, 4):
		var key := narration_page_key(biome_name, i)
		if PLAYER_COPY.has_key(key):
			pages.append(PLAYER_COPY.text(key, ""))
	if pages.is_empty():
		var legacy := narration_key_for_name(biome_name)
		if PLAYER_COPY.has_key(legacy):
			pages.append(PLAYER_COPY.text(legacy, ""))
	return pages


static func art_short_for_name(biome_name: String) -> String:
	var parts: PackedStringArray = str(biome_name).strip_edges().to_lower().split(" ")
	if parts.is_empty() or parts[0] == "":
		return "verdant"
	return str(parts[0])


## True when any page key exists (.p1 preferred; any .pN counts). Legacy alone does not.
static func has_narration(biome_name: String) -> bool:
	for i in range(1, 4):
		if PLAYER_COPY.has_key(narration_page_key(biome_name, i)):
			return true
	return false


## Campaign map→biome enter for tip biomes b1–b5. Endless / unknown skip splash.
static func shows_for_biome(biome_id: String) -> bool:
	return str(biome_id).strip_edges() in CAMPAIGN_BIOME_IDS


func _on_play_in_tween_finished() -> void:
	_in_tween = null
	_finish_play_in()


func _finish_play_in() -> void:
	if _play_in_finished:
		return
	_play_in_finished = true
	play_in_done.emit()


## Click / skip input: advance page, or dismiss on the last page (same cue stays).
func _request_skip() -> void:
	if _dismissed_emitted:
		return
	## Click anytime: finish an in-flight soft swap so the next page can start.
	if _page_tween != null and is_instance_valid(_page_tween):
		_page_tween.kill()
		_page_tween = null
		_page_swap_busy = false
		if _narration != null and is_instance_valid(_narration):
			if _page_index >= 0 and _page_index < _pages.size():
				_narration.text = str(_pages[_page_index])
			_narration.modulate.a = 1.0
			_layout_narration_bar()
	## Still dissolving in: snap to full alpha so page advance stays readable.
	if _in_tween != null and is_instance_valid(_in_tween):
		_in_tween.kill()
		_in_tween = null
		if _root != null and is_instance_valid(_root):
			_root.modulate.a = 1.0
		_finish_play_in()
	elif not _play_in_finished:
		if _root != null and is_instance_valid(_root):
			_root.modulate.a = 1.0
		_finish_play_in()
	if _pages.size() > 0 and _page_index < _pages.size() - 1:
		_advance_page()
		return
	_dismiss_from_input()


func _dismiss_from_input() -> void:
	if _dismissed_emitted:
		return
	_skipped = true
	_dismissed_emitted = true
	if _in_tween != null and is_instance_valid(_in_tween):
		_in_tween.kill()
		_in_tween = null
	if _page_tween != null and is_instance_valid(_page_tween):
		_page_tween.kill()
		_page_tween = null
	# Always unblock play_in (idempotent). Skip may land before, during, or after the dissolve.
	_finish_play_in()
	dismissed.emit()


func _advance_page() -> void:
	if _pages.is_empty() or _page_index >= _pages.size() - 1:
		_dismiss_from_input()
		return
	_page_index += 1
	_apply_page_text(true)


func _apply_page_text(soft_swap: bool) -> void:
	if _narration == null:
		return
	var next_text := ""
	if _page_index >= 0 and _page_index < _pages.size():
		next_text = str(_pages[_page_index])
	if not soft_swap or next_text == str(_narration.text):
		_narration.text = next_text
		_narration.modulate.a = 1.0
		_layout_narration_bar()
		return
	_page_swap_busy = true
	if _page_tween != null and is_instance_valid(_page_tween):
		_page_tween.kill()
		_page_tween = null
	## Soft text swap only — whole-splash dissolve stays for enter/exit.
	_page_tween = create_tween()
	_page_tween.set_trans(Tween.TRANS_SINE)
	_page_tween.set_ease(Tween.EASE_IN_OUT)
	_page_tween.tween_property(_narration, "modulate:a", 0.0, 0.12)
	_page_tween.tween_callback(func() -> void:
		if _narration == null or not is_instance_valid(_narration):
			return
		_narration.text = next_text
		_layout_narration_bar()
	)
	_page_tween.tween_property(_narration, "modulate:a", 1.0, 0.16)
	_page_tween.finished.connect(func() -> void:
		_page_tween = null
		_page_swap_busy = false
	, CONNECT_ONE_SHOT)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _is_skip_event(event):
		get_viewport().set_input_as_handled()
		_request_skip()


func _on_root_gui_input(event: InputEvent) -> void:
	if _is_skip_event(event):
		get_viewport().set_input_as_handled()
		_request_skip()


func _is_skip_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed:
		return true
	if event is InputEventScreenTouch and event.pressed:
		return true
	if event is InputEventKey and event.pressed and not event.echo:
		return true
	return false


func _build() -> void:
	if _built and _root != null and is_instance_valid(_root):
		_apply_copy()
		return
	_built = true
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_root_gui_input)
	_root.modulate.a = 0.0
	add_child(_root)

	## Art stack sits below BiomeAmbient absolute z (−7…9). Chrome sits above (CHROME_Z).
	_art = TextureRect.new()
	_art.name = "Art"
	_art.position = Vector2(0, 0)
	_art.size = Vector2(DESIGN.x, ART_H)
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.z_as_relative = false
	_art.z_index = -20
	_art.texture = _resolve_bg_tex()
	_root.add_child(_art)

	var vignette := TextureRect.new()
	vignette.name = "Vignette"
	vignette.position = Vector2(0, 0)
	vignette.size = Vector2(DESIGN.x, ART_H)
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.z_as_relative = false
	vignette.z_index = -19
	vignette.texture = _make_vignette()
	_root.add_child(vignette)

	var fade := TextureRect.new()
	fade.name = "BottomFade"
	## Sit just above the narration bar top so the blend still meets the taller panel.
	fade.position = Vector2(0, DESIGN.y - BAR_H - 44.0)
	fade.size = Vector2(DESIGN.x, 72)
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.z_as_relative = false
	fade.z_index = -18
	fade.texture = _make_bottom_fade()
	_root.add_child(fade)

	var shadow := ColorRect.new()
	shadow.name = "SproutShadow"
	shadow.color = Color(0x12 / 255.0, 0x26 / 255.0, 0x1b / 255.0, 0.6)
	shadow.position = Vector2(624, 744)
	shadow.size = Vector2(144, 16)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow.z_as_relative = false
	shadow.z_index = -17
	_root.add_child(shadow)

	_sprout = TextureRect.new()
	_sprout.name = "Sprout"
	_sprout.position = Vector2(500, 432)
	_sprout.size = Vector2(320, 320)
	_sprout.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprout.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprout.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprout.z_as_relative = false
	_sprout.z_index = -16
	if ResourceLoader.exists(SPROUT_PATH):
		_sprout.texture = load(SPROUT_PATH)
	_root.add_child(_sprout)

	## Shared BiomeAmbient reparents here: in front of art/sprout, behind chrome.
	## No duplicate one-off particle system (old Verdant fireflies removed).
	_ambient_host = Node2D.new()
	_ambient_host.name = "AmbientHost"
	_ambient_host.z_as_relative = false
	_ambient_host.z_index = 0
	_root.add_child(_ambient_host)

	_chrome_box = VBoxContainer.new()
	_chrome_box.name = "Chrome"
	_chrome_box.position = Vector2(40, 36)
	_chrome_box.add_theme_constant_override("separation", 8)
	_chrome_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome_box.z_as_relative = false
	_chrome_box.z_index = CHROME_Z
	_root.add_child(_chrome_box)

	_chrome_biome = _chrome_label(true)
	_chrome_box.add_child(_wrap_plate(_chrome_biome, true))
	_chrome_dungeon = _chrome_label(false)
	_chrome_box.add_child(_wrap_plate(_chrome_dungeon, false))
	_chrome_delves = _chrome_label(false)
	_chrome_box.add_child(_wrap_plate(_chrome_delves, false))

	_narration_bar = Panel.new()
	_narration_bar.name = "NarrationBar"
	_narration_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_narration_bar.z_as_relative = false
	_narration_bar.z_index = CHROME_Z
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = Color("1A120E")
	bar_style.border_color = Color("7A4E2B")
	bar_style.border_width_top = 6
	## Even content margins so 2–5 line narrations share the same inset.
	bar_style.content_margin_left = 20
	bar_style.content_margin_right = 20
	bar_style.content_margin_top = 20
	bar_style.content_margin_bottom = 20
	_narration_bar.add_theme_stylebox_override("panel", bar_style)
	_root.add_child(_narration_bar)

	var inner := Panel.new()
	inner.name = "NarrationInner"
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 20
	inner.offset_top = 20
	inner.offset_right = -20
	inner.offset_bottom = -20
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = Color("211610")
	inner_style.border_color = Color("3B2618")
	inner_style.set_border_width_all(4)
	inner.add_theme_stylebox_override("panel", inner_style)
	_narration_bar.add_child(inner)

	_narration = Label.new()
	_narration.name = "Narration"
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration.max_lines_visible = NARR_MAX_LINES
	_narration.add_theme_font_size_override("font_size", 36)
	_narration.add_theme_constant_override("line_spacing", 6)
	_narration.add_theme_color_override("font_color", Color("E9D3A1"))
	_narration.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_narration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_narration.z_as_relative = false
	_narration.z_index = CHROME_Z
	_root.add_child(_narration)

	_cue_row = HBoxContainer.new()
	_cue_row.name = "Cue"
	_cue_row.alignment = BoxContainer.ALIGNMENT_END
	_cue_row.add_theme_constant_override("separation", 8)
	_cue_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cue_row.z_as_relative = false
	_cue_row.z_index = CHROME_Z
	_root.add_child(_cue_row)

	_cue_leaf = TextureRect.new()
	_cue_leaf.name = "CueLeaf"
	_cue_leaf.custom_minimum_size = Vector2(24, 24)
	_cue_leaf.size = Vector2(24, 24)
	_cue_leaf.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cue_leaf.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cue_leaf.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cue_leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var leaf_path := LEAF_FINAL if ResourceLoader.exists(LEAF_FINAL) else LEAF_PATH
	if ResourceLoader.exists(leaf_path):
		_cue_leaf.texture = load(leaf_path)
	_cue_row.add_child(_cue_leaf)

	_cue_label = Label.new()
	_cue_label.name = "CueLabel"
	_cue_label.add_theme_font_size_override("font_size", 17)
	_cue_label.add_theme_color_override("font_color", Color("EFE0B6"))
	_cue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cue_row.add_child(_cue_label)

	_apply_copy()
	_layout_narration_bar()
	_start_leaf_bob()


func _apply_copy() -> void:
	var biome_name := str(_ctx.get("biome_name", ""))
	var dungeon_n := int(_ctx.get("dungeon_index", 1))
	var delves_n := int(_ctx.get("delves", 0))
	if _chrome_biome:
		_chrome_biome.text = PLAYER_COPY.fill("splash.chrome.biome", {"name": biome_name}, biome_name)
	if _chrome_dungeon:
		_chrome_dungeon.text = PLAYER_COPY.fill("splash.chrome.dungeon", {"n": dungeon_n}, "Dungeon %s" % dungeon_n)
	if _chrome_delves:
		_chrome_delves.text = PLAYER_COPY.fill("splash.chrome.delves", {"n": delves_n}, "Delves: %s" % delves_n)
	if _cue_label:
		_cue_label.text = PLAYER_COPY.text("splash.chrome.continue", "click anytime")
	## Page list from .p1/.p2/.p3 (legacy single key = unused fallback only).
	_pages = narration_pages_for_name(biome_name)
	if _page_index < 0 or (_pages.size() > 0 and _page_index >= _pages.size()):
		_page_index = 0
	if _narration:
		## Missing Spin pages → blank Label (still show splash). Never invent copy.
		_apply_page_text(false)
	## attach_ambient may _build() before play_in fills _ctx; re-resolve art here.
	if _art:
		_art.texture = _resolve_bg_tex()
	if _built:
		_layout_narration_bar()


## Size the narration bar for up to 5 lines with even padding; widen the label
## so wrap uses most of the panel. Cue stays bottom-right and clear of text.
func _layout_narration_bar() -> void:
	if _narration_bar == null or _narration == null:
		return
	var bar_y: float = DESIGN.y - BAR_H
	_narration_bar.position = Vector2(0, bar_y)
	_narration_bar.size = Vector2(DESIGN.x, BAR_H)

	var text_w: float = DESIGN.x - NARR_PAD_X * 2.0
	## Pin wrap width first; Label has no get_content_height — measure via lines.
	_narration.size = Vector2(text_w, NARR_LINE_PX * float(NARR_MAX_LINES))
	var content_h: float = _measure_narration_height()
	_narration.size = Vector2(text_w, content_h)

	var cue_band: float = CUE_H + CUE_BOTTOM
	var text_zone_top: float = bar_y + NARR_PAD_Y
	var text_zone_bot: float = bar_y + BAR_H - cue_band - CUE_GAP
	var text_zone_h: float = maxf(0.0, text_zone_bot - text_zone_top)
	## Center 1–5 line blocks in the text zone so every biome gets even padding.
	var narr_y: float = text_zone_top + maxf(0.0, (text_zone_h - content_h) * 0.5)
	## Clamp so the last line never crosses into the cue band / bar border.
	var max_narr_y: float = text_zone_bot - content_h
	if max_narr_y < text_zone_top:
		narr_y = text_zone_top
		_narration.size = Vector2(text_w, maxf(NARR_LINE_PX, text_zone_h))
	else:
		narr_y = clampf(narr_y, text_zone_top, max_narr_y)
	_narration.position = Vector2(NARR_PAD_X, narr_y)

	if _cue_row != null:
		_cue_row.position = Vector2(DESIGN.x - CUE_RIGHT - CUE_W, bar_y + BAR_H - CUE_BOTTOM - CUE_H)
		_cue_row.size = Vector2(CUE_W, CUE_H)


## Label does not expose get_content_height; lines × line_height is the fit measure.
func _measure_narration_height() -> float:
	if _narration == null:
		return NARR_LINE_PX
	var lines: int = _narration.get_line_count()
	if lines < 1:
		lines = 1
	lines = mini(lines, NARR_MAX_LINES)
	var line_h: float = float(_narration.get_line_height())
	if line_h < 1.0:
		line_h = NARR_LINE_PX
	var max_h: float = NARR_LINE_PX * float(NARR_MAX_LINES) + 4.0
	return minf(float(lines) * line_h, max_h)


func narration_rect() -> Rect2:
	if _narration == null:
		return Rect2()
	return Rect2(_narration.position, _narration.size)


func narration_bar_rect() -> Rect2:
	if _narration_bar == null:
		return Rect2()
	return Rect2(_narration_bar.position, _narration_bar.size)


func cue_rect() -> Rect2:
	if _cue_row == null:
		return Rect2()
	return Rect2(_cue_row.position, _cue_row.size)


func narration_line_count() -> int:
	if _narration == null:
		return 0
	return _narration.get_line_count()


func narration_content_height() -> float:
	return _measure_narration_height()


func _chrome_label(plate: bool) -> Label:
	var lab := Label.new()
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if plate:
		lab.add_theme_font_size_override("font_size", 28)
		lab.add_theme_color_override("font_color", Color("9cc45a"))
	else:
		lab.add_theme_font_size_override("font_size", 17)
		lab.add_theme_color_override("font_color", Color("EFE0B6"))
	return lab


func _wrap_plate(lab: Label, plate: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(26 / 255.0, 18 / 255.0, 14 / 255.0, 0.9)
	style.set_border_width_all(3)
	style.content_margin_top = 3
	style.content_margin_bottom = 2
	style.content_margin_left = 10
	style.content_margin_right = 10
	if plate:
		style.border_color = Color("7A4E2B")
	else:
		style.border_color = Color("4A2F1F")
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(lab)
	return panel


func _start_leaf_bob() -> void:
	if _cue_leaf == null:
		return
	var base_y: float = _cue_leaf.position.y
	_cue_tween = create_tween()
	_cue_tween.set_loops()
	_cue_tween.set_trans(Tween.TRANS_SINE)
	_cue_tween.set_ease(Tween.EASE_IN_OUT)
	_cue_tween.tween_property(_cue_leaf, "position:y", base_y - 2.0, 0.4)
	_cue_tween.tween_property(_cue_leaf, "position:y", base_y, 0.4)


func _resolve_bg_tex() -> Texture2D:
	var biome_name := str(_ctx.get("biome_name", ""))
	var short := art_short_for_name(biome_name)
	var painted := "res://assets/ui/biome_splash/bg_%s.png" % short
	var placeholder := "res://assets/ui/biome_splash/bg_%s_placeholder.png" % short
	var fallback := "res://assets/ui/biome_full/bg_wheel_%s.png" % _biome_id
	if ResourceLoader.exists(painted):
		var painted_tex = load(painted)
		if painted_tex != null:
			return painted_tex
	if ResourceLoader.exists(placeholder):
		var ph_tex = load(placeholder)
		if ph_tex != null:
			return ph_tex
	if ResourceLoader.exists(fallback):
		var fb_tex = load(fallback)
		if fb_tex != null:
			return fb_tex
	return null


func _make_vignette() -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(11 / 255.0, 7 / 255.0, 6 / 255.0, 0.0),
		Color(11 / 255.0, 7 / 255.0, 6 / 255.0, 0.7),
	])
	g.offsets = PackedFloat32Array([0.45, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 256
	tex.height = 256
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.45)
	tex.fill_to = Vector2(0.95, 0.45)
	return tex


func _make_bottom_fade() -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(11 / 255.0, 7 / 255.0, 6 / 255.0, 0.0),
		Color(11 / 255.0, 7 / 255.0, 6 / 255.0, 0.85),
	])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 16
	tex.height = 72
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	return tex
