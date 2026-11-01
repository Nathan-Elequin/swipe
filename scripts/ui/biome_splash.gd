extends CanvasLayer
## Biome-enter story splash. Layout locked in design/biome-enter-splash/SCREEN-biome-enter-splash.md.
## All player words come from PLAYER_COPY keys. Never invent copy. Never show Tier.

signal dismissed
signal play_in_done

const PLAYER_COPY := preload("res://scripts/player_copy.gd")

const DESIGN := Vector2(1680.0, 1040.0)
const ART_H := 832.0
const BAR_H := 208.0
const SPROUT_PATH := "res://assets/dungeon/anim/player/sprout_idle_f0.png"
const LEAF_PATH := "res://assets/ui/biome_splash/cue_leaf_placeholder.png"
const LEAF_FINAL := "res://assets/ui/biome_splash/cue_leaf.png"

var _root: Control
var _art: TextureRect
var _sprout: TextureRect
var _narration: Label
var _cue_leaf: TextureRect
var _cue_label: Label
var _chrome_biome: Label
var _chrome_dungeon: Label
var _chrome_delves: Label
var _in_tween: Tween
var _cue_tween: Tween
var _skipped: bool = false
var _dismissed_emitted: bool = false
var _play_in_finished: bool = false
var _built: bool = false
var _biome_id: String = ""
var _ctx: Dictionary = {}


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


func narration_text() -> String:
	if _narration == null:
		return ""
	return str(_narration.text)


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


static func narration_key_for_name(biome_name: String) -> String:
	var slug := str(biome_name).strip_edges().to_lower().replace(" ", "_")
	return "splash.biome.%s" % slug


static func art_short_for_name(biome_name: String) -> String:
	var parts: PackedStringArray = str(biome_name).strip_edges().to_lower().split(" ")
	if parts.is_empty() or parts[0] == "":
		return "verdant"
	return str(parts[0])


static func has_narration(biome_name: String) -> bool:
	return PLAYER_COPY.has_key(narration_key_for_name(biome_name))


func _on_play_in_tween_finished() -> void:
	_in_tween = null
	_finish_play_in()


func _finish_play_in() -> void:
	if _play_in_finished:
		return
	_play_in_finished = true
	play_in_done.emit()


func _request_skip() -> void:
	if _dismissed_emitted:
		return
	_skipped = true
	_dismissed_emitted = true
	if _in_tween != null:
		_in_tween.kill()
		_in_tween = null
	# Always unblock play_in (idempotent). Skip may land before, during, or after the dissolve.
	_finish_play_in()
	dismissed.emit()


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

	_art = TextureRect.new()
	_art.name = "Art"
	_art.position = Vector2(0, 0)
	_art.size = Vector2(DESIGN.x, ART_H)
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.texture = _resolve_bg_tex()
	_root.add_child(_art)

	var vignette := TextureRect.new()
	vignette.name = "Vignette"
	vignette.position = Vector2(0, 0)
	vignette.size = Vector2(DESIGN.x, ART_H)
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.texture = _make_vignette()
	_root.add_child(vignette)

	var fade := TextureRect.new()
	fade.name = "BottomFade"
	fade.position = Vector2(0, 760)
	fade.size = Vector2(DESIGN.x, 72)
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.texture = _make_bottom_fade()
	_root.add_child(fade)

	var shadow := ColorRect.new()
	shadow.name = "SproutShadow"
	shadow.color = Color(0x12 / 255.0, 0x26 / 255.0, 0x1b / 255.0, 0.6)
	shadow.position = Vector2(624, 744)
	shadow.size = Vector2(144, 16)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(shadow)

	_sprout = TextureRect.new()
	_sprout.name = "Sprout"
	_sprout.position = Vector2(500, 432)
	_sprout.size = Vector2(320, 320)
	_sprout.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprout.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprout.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(SPROUT_PATH):
		_sprout.texture = load(SPROUT_PATH)
	_root.add_child(_sprout)

	var fireflies := CPUParticles2D.new()
	fireflies.name = "Fireflies"
	fireflies.position = Vector2(840, 360)
	fireflies.amount = 24
	fireflies.lifetime = 4.0
	fireflies.preprocess = 2.0
	fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fireflies.emission_rect_extents = Vector2(700, 280)
	fireflies.gravity = Vector2(0, 0)
	fireflies.direction = Vector2(0, -1)
	fireflies.spread = 180.0
	fireflies.initial_velocity_min = 4.0
	fireflies.initial_velocity_max = 14.0
	fireflies.scale_amount_min = 2.0
	fireflies.scale_amount_max = 2.0
	fireflies.color = Color("E8D36A")
	_root.add_child(fireflies)

	var chrome := VBoxContainer.new()
	chrome.name = "Chrome"
	chrome.position = Vector2(40, 36)
	chrome.add_theme_constant_override("separation", 8)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(chrome)

	_chrome_biome = _chrome_label(true)
	chrome.add_child(_wrap_plate(_chrome_biome, true))
	_chrome_dungeon = _chrome_label(false)
	chrome.add_child(_wrap_plate(_chrome_dungeon, false))
	_chrome_delves = _chrome_label(false)
	chrome.add_child(_wrap_plate(_chrome_delves, false))

	var bar := Panel.new()
	bar.name = "NarrationBar"
	bar.position = Vector2(0, ART_H)
	bar.size = Vector2(DESIGN.x, BAR_H)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = Color("1A120E")
	bar_style.border_color = Color("7A4E2B")
	bar_style.border_width_top = 6
	bar_style.content_margin_left = 24
	bar_style.content_margin_right = 24
	bar_style.content_margin_top = 18
	bar_style.content_margin_bottom = 20
	bar.add_theme_stylebox_override("panel", bar_style)
	_root.add_child(bar)

	var inner := Panel.new()
	inner.name = "NarrationInner"
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 24
	inner.offset_top = 18
	inner.offset_right = -24
	inner.offset_bottom = -20
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner_style := StyleBoxFlat.new()
	inner_style.bg_color = Color("211610")
	inner_style.border_color = Color("3B2618")
	inner_style.set_border_width_all(4)
	inner.add_theme_stylebox_override("panel", inner_style)
	bar.add_child(inner)

	_narration = Label.new()
	_narration.name = "Narration"
	_narration.position = Vector2(96, 870)
	_narration.size = Vector2(1280, 132)
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration.max_lines_visible = 3
	_narration.add_theme_font_size_override("font_size", 36)
	_narration.add_theme_color_override("font_color", Color("E9D3A1"))
	_narration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_narration)

	var cue_row := HBoxContainer.new()
	cue_row.name = "Cue"
	cue_row.alignment = BoxContainer.ALIGNMENT_END
	cue_row.add_theme_constant_override("separation", 8)
	cue_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# right 56, bottom 30 of the bar → absolute
	cue_row.position = Vector2(DESIGN.x - 56 - 280, ART_H + BAR_H - 30 - 28)
	cue_row.size = Vector2(280, 28)
	_root.add_child(cue_row)

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
	cue_row.add_child(_cue_leaf)

	_cue_label = Label.new()
	_cue_label.name = "CueLabel"
	_cue_label.add_theme_font_size_override("font_size", 17)
	_cue_label.add_theme_color_override("font_color", Color("EFE0B6"))
	_cue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cue_row.add_child(_cue_label)

	_apply_copy()
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
	if _narration:
		var key := narration_key_for_name(biome_name)
		_narration.text = PLAYER_COPY.text(key, "")


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
		return load(painted)
	if ResourceLoader.exists(placeholder):
		return load(placeholder)
	if ResourceLoader.exists(fallback):
		return load(fallback)
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
