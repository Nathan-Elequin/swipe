extends Control
## Living trophy room title (SCREEN-title.md). Visual API only — Spin owns flow.

signal option_focused(id: StringName)
signal option_activated(id: StringName)

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const BIOME := preload("res://scripts/ui/biome_progress.gd")
const SETTINGS_PANEL := preload("res://scripts/ui/settings_panel.gd")

const FONT_TITLE := "res://assets/ui/fonts/eb_garamond/EBGaramond-SemiBold.ttf"
const FONT_SEMI := "res://assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf"
const FONT_REG := "res://assets/ui/fonts/open_sans/OpenSans-Regular.ttf"

const SLUGS: Array[String] = ["verdant", "crystal", "ashen", "cinder", "shadow"]
const CREAM := Color("f4ede3")
const MUTED := Color("8a7f70")
const GOLD := Color("e8c36a")
const INK := Color("100e0c")

var preview_mode: bool = false
var reduce_motion: bool = false
var _audio = null

var _board: Control
var _windows: Array = [] ## Face TextureRects
var _caps: Array = []
var _icons: Array = []
var _pcts: Array = []
var _names: Array = []
var _twinkles: Array = []
var _title_word: Label
var _menu: Control
var _rows: Array = [] ## {id, row, tag, presenter, idle_frames, present_frames}
var _start_over: Button
var _start_underline: ColorRect
var _nib: TextureRect
var _settings_host: Control
var _settings_panel
var _confirm_layer: Control
var _focus_id: StringName = &""
var _option_ids: Array[StringName] = []
var _built: bool = false
var _press: Label ## teaser compat (hidden by default)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if not _built:
		_build()
	if preview_mode:
		_apply_preview_mode()
	## Stub defaults so the game boots usable without Spin wiring.
	if _option_ids.is_empty():
		set_options([&"new_game", &"settings", &"feedback"])
	set_progress(BIOME.snapshot())


func set_audio(audio) -> void:
	_audio = audio
	if _settings_panel and _settings_panel.has_method("setup"):
		pass


func set_press_visible(on: bool) -> void:
	## Teaser / intro compat — Living trophy room has no PRESS START strip.
	if _press:
		_press.visible = on


func set_options(ids: Array) -> void:
	_option_ids.clear()
	for raw in ids:
		_option_ids.append(StringName(str(raw)))
	if not _built:
		return
	var show_start := false
	## Exactly 3 menu rows from the first three non-start_over ids.
	var row_ids: Array[StringName] = []
	for id in _option_ids:
		if id == &"start_over":
			show_start = true
			continue
		if id == &"continue":
			show_start = true
		if row_ids.size() < 3:
			row_ids.append(id)
	while row_ids.size() < 3:
		row_ids.append(&"settings")
	for i in range(3):
		_configure_row(i, row_ids[i])
	if _start_over:
		_start_over.visible = show_start and not preview_mode
		_start_underline.visible = false


func set_progress(p: Dictionary) -> void:
	if not _built:
		return
	for i in range(SLUGS.size()):
		var slug: String = SLUGS[i]
		var row: Dictionary = p.get(slug, {"state": &"gray", "pct": 0})
		if typeof(row) != TYPE_DICTIONARY:
			row = {"state": &"gray", "pct": 0}
		var state: StringName = StringName(str(row.get("state", "gray")))
		var pct: int = int(row.get("pct", 0))
		_apply_window(i, slug, state, pct)


func open_settings() -> void:
	if _settings_host == null:
		return
	_settings_host.visible = true
	if _settings_panel and _settings_panel.has_method("sync_from_audio"):
		_settings_panel.sync_from_audio()
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.menu_open")


func close_settings() -> void:
	if _settings_host:
		_settings_host.visible = false


func open_start_over_confirm() -> void:
	if _confirm_layer == null or preview_mode:
		return
	_confirm_layer.visible = true
	_confirm_layer.modulate.a = 1.0
	if reduce_motion:
		pass
	else:
		var dim: ColorRect = _confirm_layer.get_node_or_null("Dim") as ColorRect
		var panel: Control = _confirm_layer.get_node_or_null("Panel") as Control
		if dim:
			dim.color.a = 0.0
		if panel:
			panel.modulate.a = 0.0
			panel.scale = Vector2(0.96, 0.96)
		var tw := create_tween().bind_node(self)
		if dim:
			tw.tween_property(dim, "color:a", 0.6, 0.14).set_trans(Tween.TRANS_LINEAR)
		if panel:
			tw.parallel().tween_property(panel, "modulate:a", 1.0, 0.14)
			tw.parallel().tween_property(panel, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.confirm_open")
	var keep: Button = _confirm_layer.find_child("Keep", true, false) as Button
	if keep:
		keep.grab_focus()


func close_start_over_confirm() -> void:
	if _confirm_layer:
		_confirm_layer.visible = false


func settings_panel_node():
	return _settings_panel


func _build() -> void:
	_built = true
	_add_backdrop()
	_add_board()
	_add_board_labels()
	_add_title_word()
	_add_menu()
	_add_start_over()
	_add_nib()
	_add_settings_screen()
	_add_confirm()
	## Hidden teaser press label for API compat.
	_press = Label.new()
	_press.name = "PressStart"
	_press.visible = false
	_press.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_press)


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _font(path: String) -> Font:
	if ResourceLoader.exists(path):
		return load(path) as Font
	return ThemeDB.fallback_font


func _add_backdrop() -> void:
	var bg := TextureRect.new()
	bg.name = "Backdrop"
	bg.texture = _tex("res://assets/ui/biome_splash/bg_verdant.png")
	bg.texture_filter = TEXTURE_FILTER_NEAREST
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1680, 832)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var floor_c := ColorRect.new()
	floor_c.name = "BackdropFloor"
	floor_c.color = Color("0b0908")
	floor_c.position = Vector2(0, 832)
	floor_c.size = Vector2(1680, 208)
	floor_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_c)
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.043, 0.035, 0.031, 0.52)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)


func _add_board() -> void:
	_board = Control.new()
	_board.name = "TitleBoard"
	_board.position = Vector2(90, 196)
	_board.size = Vector2(332, 194)
	_board.scale = Vector2(2, 2)
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_board)

	for i in range(5):
		var win := Control.new()
		win.name = "Window_%d" % i
		win.position = Vector2(12 + 63 * i, 22)
		win.size = Vector2(56, 154)
		win.clip_contents = true
		win.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_board.add_child(win)
		var face := TextureRect.new()
		face.name = "Face"
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_SCALE
		face.texture_filter = TEXTURE_FILTER_NEAREST
		face.position = Vector2(-126, 0)
		face.size = Vector2(308, 154)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		win.add_child(face)
		_windows.append(face)

		var cap := TextureRect.new()
		cap.name = "Cap_%d" % i
		cap.texture = _tex("res://assets/ui/title/board_window_cap_gold.png")
		cap.texture_filter = TEXTURE_FILTER_NEAREST
		cap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cap.stretch_mode = TextureRect.STRETCH_KEEP
		cap.position = Vector2(12 + 63 * i, 22)
		cap.size = Vector2(56, 4)
		cap.visible = false
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_board.add_child(cap)
		_caps.append(cap)

	var windows := TextureRect.new()
	windows.name = "Windows"
	windows.texture = _tex("res://assets/ui/title/board_windows_5.png")
	windows.texture_filter = TEXTURE_FILTER_NEAREST
	windows.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	windows.stretch_mode = TextureRect.STRETCH_KEEP
	windows.position = Vector2(12, 22)
	windows.size = Vector2(308, 154)
	windows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(windows)

	var frame := TextureRect.new()
	frame.name = "Frame"
	frame.texture = _tex("res://assets/ui/trophy_board/board_frame.png")
	frame.texture_filter = TEXTURE_FILTER_NEAREST
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.position = Vector2.ZERO
	frame.size = Vector2(332, 194)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(frame)

	var trim := TextureRect.new()
	trim.name = "Trim"
	trim.texture = _tex("res://assets/ui/trophy_board/board_trim_gold.png")
	trim.texture_filter = TEXTURE_FILTER_NEAREST
	trim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	trim.stretch_mode = TextureRect.STRETCH_SCALE
	trim.position = Vector2.ZERO
	trim.size = Vector2(332, 194)
	trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(trim)

	for i in range(5):
		var icon := TextureRect.new()
		icon.name = "Icon_%d" % i
		icon.texture_filter = TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP
		icon.position = Vector2(22 + 63 * i, 130)
		icon.size = Vector2(36, 36)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_board.add_child(icon)
		_icons.append(icon)
		_twinkles.append([])


func _add_board_labels() -> void:
	var labels := Control.new()
	labels.name = "BoardLabels"
	labels.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(labels)
	var font_semi := _font(FONT_SEMI)
	for i in range(5):
		var pct := Label.new()
		pct.name = "Pct_%d" % i
		pct.position = Vector2(150 + 126 * i, 502)
		pct.size = Vector2(40, 14)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pct.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pct.add_theme_font_override("font", font_semi)
		pct.add_theme_font_size_override("font_size", 13)
		pct.add_theme_color_override("font_color", GOLD)
		pct.add_theme_constant_override("outline_size", 0)
		pct.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pct.visible = false
		labels.add_child(pct)
		_pcts.append(pct)

		var nm := Label.new()
		nm.name = "Name_%d" % i
		nm.position = Vector2(110 + 126 * i, 592)
		nm.size = Vector2(120, 22)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nm.add_theme_font_override("font", font_semi)
		nm.add_theme_font_size_override("font_size", 16)
		nm.add_theme_color_override("font_color", MUTED)
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var key := "biome.name.%s" % SLUGS[i]
		nm.text = COPY.text(key, key)
		labels.add_child(nm)
		_names.append(nm)


func _add_title_word() -> void:
	_title_word = Label.new()
	_title_word.name = "TitleWord"
	_title_word.position = Vector2(930, 150)
	_title_word.size = Vector2(700, 100)
	_title_word.add_theme_font_override("font", _font(FONT_TITLE))
	_title_word.add_theme_font_size_override("font_size", 86)
	_title_word.add_theme_color_override("font_color", CREAM)
	_title_word.add_theme_color_override("font_shadow_color", INK)
	_title_word.add_theme_constant_override("shadow_offset_x", 0)
	_title_word.add_theme_constant_override("shadow_offset_y", 5)
	_title_word.add_theme_constant_override("shadow_outline_size", 0)
	_title_word.text = COPY.text("title.overlay", "title.overlay")
	_title_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_word)


func _add_menu() -> void:
	_menu = Control.new()
	_menu.name = "Menu"
	_menu.position = Vector2(1000, 300)
	_menu.size = Vector2(560, 328)
	_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_menu)
	var presenters := [
		{"idle": "goblin", "present": "goblin", "native": 48},
		{"idle": "gargoyle", "present": "gargoyle", "native": 48},
		{"idle": "lich", "present": "lich", "native": 64},
	]
	for i in range(3):
		var row := Control.new()
		row.name = "Row_%d" % i
		row.position = Vector2(0, 124 * i)
		row.size = Vector2(560, 80)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_menu.add_child(row)

		var spr := AnimatedSprite2D.new()
		spr.name = "Presenter"
		spr.centered = true
		spr.position = Vector2(40, 40)
		spr.scale = Vector2(2, 2)
		spr.texture_filter = TEXTURE_FILTER_NEAREST
		var frames := _make_presenter_frames(presenters[i])
		spr.sprite_frames = frames
		spr.animation = &"idle"
		spr.frame = 0
		spr.pause()
		## Gargoyle: crop dirt/ground base if present (transparent pad check via region).
		if str(presenters[i].get("present", "")) == "gargoyle":
			_maybe_crop_gargoyle(spr)
		row.add_child(spr)

		var tag := KIT.choice_tag("title.menu.settings", Vector2(110, 20))
		tag.name = "Tag"
		tag.position = Vector2(110, 0)
		tag.focus_mode = Control.FOCUS_ALL
		tag.pressed.connect(_on_tag_pressed.bind(i))
		tag.focus_entered.connect(_on_row_focus.bind(i, true))
		tag.mouse_entered.connect(_on_row_focus.bind(i, true))
		tag.mouse_exited.connect(_on_row_focus.bind(i, false))
		row.add_child(tag)

		_rows.append({
			"id": &"settings",
			"row": row,
			"tag": tag,
			"presenter": spr,
			"base_tag_y": 0.0,
			"base_pres_x": 40.0,
		})


func _make_presenter_frames(spec: Dictionary) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation(&"idle")
	sf.add_animation(&"present")
	sf.set_animation_speed(&"idle", 4.0)
	sf.set_animation_loop(&"idle", true)
	sf.set_animation_speed(&"present", 10.0)
	sf.set_animation_loop(&"present", false)
	var idle_name: String = str(spec.get("idle", "goblin"))
	var present_name: String = str(spec.get("present", idle_name))
	var native: int = int(spec.get("native", 48))
	var have_present := true
	for f in range(4):
		var idle_path := "res://assets/dungeon/anim/facing/%s_facing_idle_f%d.png" % [idle_name, f]
		var tex := _tex(idle_path)
		if tex:
			sf.add_frame(&"idle", tex)
	for f in range(4):
		var present_path := "res://assets/ui/title/presenters/%s_present_f%d.png" % [present_name, f]
		var ptex := _tex(present_path)
		if ptex == null:
			have_present = false
			break
		sf.add_frame(&"present", ptex)
	if not have_present:
		## Fallback: present uses idle at 8 fps.
		sf.clear(&"present")
		sf.set_animation_speed(&"present", 8.0)
		for f in range(sf.get_frame_count(&"idle")):
			sf.add_frame(&"present", sf.get_frame_texture(&"idle", f))
	return sf


func _maybe_crop_gargoyle(spr: AnimatedSprite2D) -> void:
	## Frames are 48x48 with no bottom transparent pad; leave full. Note in PR if dirt shows.
	spr.offset = Vector2.ZERO


func _configure_row(i: int, id: StringName) -> void:
	if i < 0 or i >= _rows.size():
		return
	var info: Dictionary = _rows[i]
	info["id"] = id
	var tag: Button = info["tag"]
	## Spin keys: title.new_game / title.continue / title.settings / title.feedback
	## (title.menu.* aliases also resolve to the same text when present).
	var sid := String(id)
	var key := "title.%s" % sid
	var menu_key := "title.menu.%s" % sid
	var txt := COPY.text(key, "")
	if txt == "":
		txt = COPY.text(menu_key, menu_key)
	tag.text = txt
	tag.visible = true
	info["row"].visible = true


func _add_start_over() -> void:
	_start_over = Button.new()
	_start_over.name = "StartOver"
	_start_over.flat = true
	_start_over.focus_mode = Control.FOCUS_ALL
	_start_over.position = Vector2(1210, 700)
	_start_over.size = Vector2(240, 26)
	_start_over.add_theme_font_override("font", _font(FONT_REG))
	_start_over.add_theme_font_size_override("font_size", 17)
	_start_over.add_theme_color_override("font_color", Color("9c8f7d"))
	_start_over.add_theme_color_override("font_hover_color", CREAM)
	_start_over.add_theme_color_override("font_focus_color", CREAM)
	_start_over.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_start_over.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_start_over.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_start_over.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_start_over.text = COPY.text("title.start_over", COPY.text("title.menu.start_over", "Start over"))
	_start_over.visible = false
	_start_over.pressed.connect(func() -> void:
		option_activated.emit(&"start_over")
		open_start_over_confirm()
	)
	_start_over.mouse_entered.connect(func() -> void:
		_start_underline.visible = _start_over.visible
		option_focused.emit(&"start_over")
	)
	_start_over.mouse_exited.connect(func() -> void:
		_start_underline.visible = false
	)
	add_child(_start_over)
	_start_underline = ColorRect.new()
	_start_underline.name = "StartOverUnderline"
	_start_underline.color = CREAM
	_start_underline.position = Vector2(1210, 722)
	_start_underline.size = Vector2(240, 1)
	_start_underline.visible = false
	_start_underline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_start_underline)


func _add_nib() -> void:
	_nib = TextureRect.new()
	_nib.name = "Nib"
	_nib.texture = _tex("res://assets/ui/title/title_nib_lantern.png")
	_nib.texture_filter = TEXTURE_FILTER_NEAREST
	_nib.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_nib.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_nib.position = Vector2(560, 624)
	_nib.size = Vector2(274, 274)
	_nib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_nib)


func _add_settings_screen() -> void:
	_settings_host = Control.new()
	_settings_host.name = "SettingsScreen"
	_settings_host.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_settings_host.visible = false
	_settings_host.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_host.z_index = 40
	add_child(_settings_host)

	var bg := TextureRect.new()
	bg.texture = _tex("res://assets/ui/biome_splash/bg_verdant.png")
	bg.texture_filter = TEXTURE_FILTER_NEAREST
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1680, 832)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_host.add_child(bg)
	var floor_c := ColorRect.new()
	floor_c.color = Color("0b0908")
	floor_c.position = Vector2(0, 832)
	floor_c.size = Vector2(1680, 208)
	floor_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_host.add_child(floor_c)
	var dim := ColorRect.new()
	dim.color = Color(0.043, 0.035, 0.031, 0.62)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_host.add_child(dim)

	var board := TextureRect.new()
	board.name = "Board"
	board.texture = KIT.load_tex("overlays/pause_board.png")
	board.texture_filter = TEXTURE_FILTER_NEAREST
	board.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	board.stretch_mode = TextureRect.STRETCH_KEEP
	board.position = Vector2(440, 60)
	board.size = Vector2(800, 720)
	board.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_host.add_child(board)

	var plaque := Label.new()
	plaque.name = "Plaque"
	plaque.position = Vector2(680, 62)
	plaque.size = Vector2(324, 54)
	plaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plaque.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plaque.add_theme_font_override("font", _font(FONT_TITLE))
	plaque.add_theme_font_size_override("font_size", 32)
	plaque.add_theme_color_override("font_color", Color("2a1c10"))
	plaque.text = COPY.text("pause.settings", "pause.settings")
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_host.add_child(plaque)

	_settings_panel = SETTINGS_PANEL.new()
	_settings_panel.setup(_audio, true)
	_settings_panel.position = Vector2(584, 148)
	_settings_panel.set_back_position(Vector2(664 - 584, 796 - 148))
	_settings_panel.back_pressed.connect(close_settings)
	_settings_panel.reduce_motion_toggled.connect(func(on: bool) -> void:
		reduce_motion = on
	)
	_settings_host.add_child(_settings_panel)

	var nib := TextureRect.new()
	nib.texture = _tex("res://assets/ui/title/title_nib_lantern.png")
	nib.texture_filter = TEXTURE_FILTER_NEAREST
	nib.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nib.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	nib.position = Vector2(110, 560)
	nib.size = Vector2(274, 274)
	nib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_host.add_child(nib)


func _add_confirm() -> void:
	_confirm_layer = Control.new()
	_confirm_layer.name = "ConfirmLayer"
	_confirm_layer.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_confirm_layer.visible = false
	_confirm_layer.z_index = 50
	_confirm_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_confirm_layer)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.043, 0.035, 0.031, 0.6)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close_start_over_confirm()
	)
	_confirm_layer.add_child(dim)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(560, 220)
	panel.size = Vector2(560, 220)
	panel.position = Vector2(840 - 280, 520 - 110)
	panel.pivot_offset = Vector2(280, 110)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("100e0ce8")
	sb.border_color = GOLD
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	_confirm_layer.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)

	var ask := Label.new()
	ask.name = "Ask"
	ask.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ask.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ask.add_theme_font_override("font", _font(FONT_SEMI))
	ask.add_theme_font_size_override("font_size", 22)
	ask.add_theme_color_override("font_color", CREAM)
	## Specced confirm copy is title.start_over.confirm; ask/body aliases optional.
	var ask_txt := COPY.text("title.start_over.confirm", "")
	if ask_txt == "":
		ask_txt = COPY.text("title.start_over.ask", "title.start_over.ask")
	ask.text = ask_txt
	col.add_child(ask)

	var body := Label.new()
	body.name = "Body"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_override("font", _font(FONT_REG))
	body.add_theme_font_size_override("font_size", 17)
	body.add_theme_color_override("font_color", Color("9c8f7d"))
	var body_txt := COPY.text("title.start_over.body", "")
	body.text = body_txt
	body.visible = body_txt != ""
	col.add_child(body)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 24)
	col.add_child(buttons)

	var keep := KIT.choice_tag("title.start_over.no", Vector2(56, 16))
	keep.name = "Keep"
	keep.text = COPY.text("title.start_over.no", "title.start_over.no")
	keep.focus_mode = Control.FOCUS_ALL
	keep.pressed.connect(close_start_over_confirm)
	buttons.add_child(keep)

	var wipe := KIT.choice_tag("title.start_over.yes", Vector2(56, 16))
	wipe.name = "Wipe"
	wipe.text = COPY.text("title.start_over.yes", "title.start_over.yes")
	wipe.focus_mode = Control.FOCUS_ALL
	wipe.pressed.connect(func() -> void:
		if _audio and _audio.has_method("play_event"):
			_audio.play_event(&"ui.start_over_confirm")
		## Wipe itself is Spin's flow — emit only.
		option_activated.emit(&"start_over_wipe")
		close_start_over_confirm()
	)
	buttons.add_child(wipe)


func _apply_window(i: int, slug: String, state: StringName, pct: int) -> void:
	var face: TextureRect = _windows[i]
	var full := BIOME.full_slug(slug)
	face.texture = _tex("res://assets/ui/trophy_board/face_bg_%s.png" % slug)
	var icon: TextureRect = _icons[i]
	var cap: TextureRect = _caps[i]
	var pct_l: Label = _pcts[i]
	var name_l: Label = _names[i]
	match state:
		&"cleared":
			face.modulate = Color(1, 1, 1)
			cap.visible = true
			icon.texture = _tex("res://assets/ui/title/progress/biome_%s_cleared.png" % full)
			pct_l.visible = false
			name_l.add_theme_color_override("font_color", CREAM)
			_set_twinkles(i, true)
		&"entered":
			face.modulate = Color(1, 1, 1)
			cap.visible = false
			icon.texture = _tex("res://assets/ui/title/progress/biome_%s_entered.png" % full)
			pct_l.visible = true
			pct_l.text = "%d%%" % pct
			pct_l.add_theme_font_size_override("font_size", 11 if pct >= 100 else 13)
			name_l.add_theme_color_override("font_color", CREAM)
			_set_twinkles(i, false)
		_:
			face.modulate = Color(0.36, 0.36, 0.40)
			cap.visible = false
			icon.texture = _tex("res://assets/ui/title/progress/biome_%s_gray.png" % full)
			pct_l.visible = false
			name_l.add_theme_color_override("font_color", MUTED)
			_set_twinkles(i, false)


func _set_twinkles(i: int, on: bool) -> void:
	## Twinkles live in screen space above icons; skip when reduced motion / preview.
	if preview_mode or reduce_motion:
		on = false
	## Lightweight: modulate icon only if no twinkle sprites attached yet.
	if not on:
		return


func _apply_preview_mode() -> void:
	preview_mode = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _start_over:
		_start_over.visible = false
	if _settings_host:
		_settings_host.visible = false
	if _confirm_layer:
		_confirm_layer.visible = false
	set_options([&"new_game", &"settings", &"feedback"])
	set_progress(BIOME.snapshot())
	for info in _rows:
		var spr: AnimatedSprite2D = info.get("presenter")
		if spr:
			spr.pause()
			spr.frame = 0


func _on_row_focus(i: int, on: bool) -> void:
	if preview_mode or i < 0 or i >= _rows.size():
		return
	var info: Dictionary = _rows[i]
	var id: StringName = info.get("id", &"")
	var spr: AnimatedSprite2D = info.get("presenter")
	if on:
		_focus_id = id
		option_focused.emit(id)
		if _audio and _audio.has_method("play_event"):
			_audio.play_event(&"ui.hover_title")
		if spr and not reduce_motion:
			spr.play(&"idle")
		elif spr:
			spr.pause()
			spr.frame = 0
	else:
		if spr:
			spr.pause()
			spr.frame = 0
			spr.animation = &"idle"


func _on_tag_pressed(i: int) -> void:
	if preview_mode or i < 0 or i >= _rows.size():
		return
	var info: Dictionary = _rows[i]
	var id: StringName = info.get("id", &"")
	var tag: Button = info.get("tag")
	var spr: AnimatedSprite2D = info.get("presenter")
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.title_select")
	if not reduce_motion:
		if tag:
			var base_y: float = float(info.get("base_tag_y", 0.0))
			var tw := create_tween().bind_node(self)
			tw.tween_property(tag, "position:y", base_y + 4.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(tag, "position:y", base_y, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if spr:
			var base_x: float = float(info.get("base_pres_x", 40.0))
			var tw2 := create_tween().bind_node(self)
			tw2.tween_property(spr, "position:x", base_x + 8.0, 0.08)
			tw2.tween_property(spr, "position:x", base_x, 0.08)
			spr.play(&"present")
	option_activated.emit(id)
	if id == &"settings":
		open_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or preview_mode:
		return
	if _confirm_layer and _confirm_layer.visible and event.is_action_pressed("ui_cancel"):
		close_start_over_confirm()
		get_viewport().set_input_as_handled()
		return
	if _settings_host and _settings_host.visible and event.is_action_pressed("ui_cancel"):
		close_settings()
		get_viewport().set_input_as_handled()
