extends Control
## Road-to-cabin wrapper: approach (A1) → ambush (A2) → Yes/Skip overlay (O1).
## No Nib portrait or VO. Copy keys: road.caption.* / road.overlay.*.

signal choice_made(chose_tutorial: bool)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0
const SHAKE_S := 0.55
const CAPTION_HOLD := 1.6

var cabin
var _black: ColorRect
var _frame: TextureRect
var _panel: TextureRect
var _bar: Control
var _caption
var _title: Label
var _yes: FitButton
var _no: FitButton
var _busy: bool = false
var _built: bool = false
var _shake: Tween
var _waiting_choice: bool = false
var _choice: int = -1


func setup(p_cabin) -> void:
	cabin = p_cabin
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 9
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()


func is_open() -> bool:
	return visible


func arm_cover() -> void:
	## Solid black only — call the frame after intro p3 so cabin/title never flash.
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_black.modulate.a = 1.0
	_set_overlay_ui(false)
	_set_caption("")
	_bar.visible = false
	if _panel:
		_panel.visible = false
	if _frame:
		_frame.visible = false


func play_and_ask() -> bool:
	## Returns true if Yes (start tutorial), false if Skip.
	if _busy:
		return false
	_busy = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	## Keep solid black under the framed art so cabin chrome never shows through
	## (Nathan: cabin must be fully gone during approach / ambush / overlay).
	_black.modulate.a = 1.0
	if _frame:
		_frame.visible = true
	if _panel:
		_panel.visible = true
	_bar.visible = true
	_set_overlay_ui(false)
	_show_approach()
	## Silence cabin beds/loops; intro bed may still be playing until ambush combat.
	if cabin and cabin.has_method("silence_for_road"):
		cabin.silence_for_road()
	await _caption_beat("road.caption.A1.1", CAPTION_HOLD)
	await _play_ambush()
	await _caption_beat("road.caption.A2.1", 1.2)
	await _caption_beat("road.caption.A2.2", 1.4)
	var yes: bool = await _ask_overlay()
	_busy = false
	## Leave solid black up; home_cabin / main hide cabin then abort this cover.
	choice_made.emit(yes)
	return yes


func abort() -> void:
	if _shake and is_instance_valid(_shake):
		_shake.kill()
	_shake = null
	_busy = false
	_waiting_choice = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _build() -> void:
	if _built:
		return
	_built = true
	_black = ColorRect.new()
	_black.color = Color("100e0c")
	_black.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)
	_frame = KIT.tex_rect("cutscenes/panel_frame.png", Vector2(42, 32), Vector2(336, 196), 4)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_panel = TextureRect.new()
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_panel.stretch_mode = TextureRect.STRETCH_KEEP
	_panel.position = KIT.pt(50, 40)
	_panel.size = Vector2(320, 180) * PX
	_panel.pivot_offset = _panel.size * 0.5
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.z_index = 1
	add_child(_panel)
	_bar = Control.new()
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.z_index = 6
	add_child(_bar)
	var bar_bg := Panel.new()
	bar_bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_sb := StyleBoxFlat.new()
	bar_sb.bg_color = Color("16110d")
	bar_sb.border_color = Color("3a3228")
	bar_sb.set_border_width_all(2)
	bar_sb.set_corner_radius_all(4)
	bar_bg.add_theme_stylebox_override("panel", bar_sb)
	_bar.add_child(bar_bg)
	_caption = KIT.raw_label("", KIT.DIALOG_FONT, KIT.CREAM, true)
	_caption.max_lines = 3
	_caption.min_font_size = 16
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_bar.add_child(_caption)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 36)
	_title.add_theme_color_override("font_color", Color("fff6df"))
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 6)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.z_index = 7
	_title.visible = false
	add_child(_title)
	_yes = KIT.plank(Rect2(520, 560, 280, 72), 8, true)
	_yes.text = COPY.text("road.overlay.yes", "Yes")
	_yes.visible = false
	_yes.pressed.connect(func() -> void: _pick(0))
	add_child(_yes)
	_no = KIT.plank(Rect2(880, 560, 280, 72), 8, false)
	_no.text = COPY.text("road.overlay.no", "Skip")
	_no.visible = false
	_no.pressed.connect(func() -> void: _pick(1))
	add_child(_no)
	_layout()


func _layout() -> void:
	var view := Vector2(KIT.ROOM_W, KIT.ROOM_H)
	if is_inside_tree():
		view = get_viewport_rect().size
	var L: Dictionary = KIT.dialog_bar(view)
	var bar: Rect2 = L["bar"]
	_bar.position = bar.position
	_bar.size = bar.size
	var inner: Rect2 = L["inner"]
	_caption.position = inner.position
	_caption.size = inner.size
	_caption.fit()
	_title.position = Vector2(view.x * 0.15, view.y * 0.38)
	_title.size = Vector2(view.x * 0.7, 80.0)
	_yes.position = Vector2(view.x * 0.5 - 300.0, view.y * 0.52)
	_no.position = Vector2(view.x * 0.5 + 20.0, view.y * 0.52)


func _show_approach() -> void:
	## Approach: assets/dungeon/home/cutscenes/intro_p4.png
	_panel.texture = KIT.load_tex("cutscenes/intro_p4.png")
	_panel.position = KIT.pt(50, 40)
	_set_caption("")


func _play_ambush() -> void:
	## Ambush: assets/dungeon/home/cutscenes/intro_ambush.png (Pixel #363 @ baf0ab09).
	_panel.texture = KIT.load_tex("cutscenes/intro_ambush.png")
	if cabin and cabin.sfx:
		if cabin.sfx.has_method("play_event"):
			cabin.sfx.play_event(&"sting.intro")
		elif cabin.sfx.has_method("play"):
			cabin.sfx.play("scratch", -8.0)
		if cabin.sfx.has_method("set_combat_music"):
			cabin.sfx.set_combat_music(true)
	var base: Vector2 = KIT.pt(50, 40)
	_panel.position = base
	if _shake and is_instance_valid(_shake):
		_shake.kill()
	_shake = create_tween()
	_shake.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var steps := 8
	for i in steps:
		var ox: float = (1.0 if i % 2 == 0 else -1.0) * (6.0 - float(i) * 0.5) * PX
		_shake.tween_property(_panel, "position", base + Vector2(ox, 0.0), SHAKE_S / float(steps))
	_shake.tween_property(_panel, "position", base, 0.08)
	await _shake.finished
	_shake = null


func _ask_overlay() -> bool:
	_set_caption("")
	_bar.visible = false
	_title.text = COPY.text("road.overlay.title", "Go through the tutorial with Nib?")
	_yes.text = COPY.text("road.overlay.yes", "Yes")
	_no.text = COPY.text("road.overlay.no", "Skip")
	_set_overlay_ui(true)
	_layout()
	_waiting_choice = true
	_choice = -1
	while _choice < 0 and visible:
		await get_tree().process_frame
	_waiting_choice = false
	_set_overlay_ui(false)
	_bar.visible = true
	return _choice == 0


func _pick(n: int) -> void:
	if not _waiting_choice:
		return
	if cabin and cabin.sfx and cabin.sfx.has_method("play"):
		cabin.sfx.play("click", -12.0)
	_choice = n


func _set_overlay_ui(on: bool) -> void:
	_title.visible = on
	_yes.visible = on
	_no.visible = on


func _set_caption(key: String) -> void:
	var t: String = COPY.text(key, "") if key != "" else ""
	if t == "" and key != "":
		t = KIT.copy_text(key)
	_caption.text = COPY.apply_names(t) if t != "" else ""
	_caption.visible_characters = -1
	_caption.fit()


func _caption_beat(key: String, hold: float) -> void:
	_set_caption(key)
	_bar.visible = true
	_layout()
	var left: float = hold
	while left > 0.0 and visible:
		await get_tree().process_frame
		left -= get_process_delta_time()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and visible:
		_layout()
