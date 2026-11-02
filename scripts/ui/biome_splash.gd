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
var _skipped: bool = false
var _dismissed_emitted: bool = false
var _play_in_finished: bool = false
var _built: bool = false
var _biome_id: String = ""
var _ctx: Dictionary = {}
var _hosted_ambient: Node = null
var _ambient_home: Node = null
var _ambient_home_index: int = -1


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
	fade.position = Vector2(0, 760)
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
	_narration_bar.position = Vector2(0, ART_H)
	_narration_bar.size = Vector2(DESIGN.x, BAR_H)
	_narration_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_narration_bar.z_as_relative = false
	_narration_bar.z_index = CHROME_Z
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = Color("1A120E")
	bar_style.border_color = Color("7A4E2B")
	bar_style.border_width_top = 6
	bar_style.content_margin_left = 24
	bar_style.content_margin_right = 24
	bar_style.content_margin_top = 18
	bar_style.content_margin_bottom = 20
	_narration_bar.add_theme_stylebox_override("panel", bar_style)
	_root.add_child(_narration_bar)

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
	_narration_bar.add_child(inner)

	_narration = Label.new()
	_narration.name = "Narration"
	_narration.position = Vector2(96, 870)
	_narration.size = Vector2(1280, 132)
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration.max_lines_visible = 3
	_narration.add_theme_font_size_override("font_size", 36)
	_narration.add_theme_color_override("font_color", Color("E9D3A1"))
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
	# right 56, bottom 30 of the bar → absolute
	_cue_row.position = Vector2(DESIGN.x - 56 - 280, ART_H + BAR_H - 30 - 28)
	_cue_row.size = Vector2(280, 28)
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
		## Missing Spin key → blank Label (still show splash). Never invent copy.
		var key := narration_key_for_name(biome_name)
		if PLAYER_COPY.has_key(key):
			_narration.text = PLAYER_COPY.text(key, "")
		else:
			_narration.text = ""


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
