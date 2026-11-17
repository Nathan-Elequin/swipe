extends ColorRect
## Playtest title hub — hosts Pixel's Living trophy room (`title_screen`) and owns menu flow.
## Copy keys: title.menu.* / title.start_over.* (Pixel visual layer). Visual nodes stay Pixel's.
## Between-dungeon Continue stays on title.continue — do not reuse title.menu.continue there.

signal brand_new
signal middle_progress
signal continue_save
signal feedback_wanted
signal settings_wanted
signal start_over_confirmed

const COPY := preload("res://scripts/player_copy.gd")
const TITLE_SCREEN_SCENE := preload("res://scenes/ui/title_screen.tscn")
const BIOME := preload("res://scripts/ui/biome_progress.gd")

## Kept for source contracts / selftests (Middle Progress is editor-only).
var _btn_mid: Button
var _title_screen: Control = null
var _has_save: bool = false
var _audio = null
var _built: bool = false
var _option_ids: Array[StringName] = []


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color(0, 0, 0, 0) ## Title screen paints its own backdrop.
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	visible = false
	name = "playtest_hub"
	_build()
	_built = true


func set_audio(audio) -> void:
	_audio = audio
	if _title_screen and _title_screen.has_method("set_audio"):
		_title_screen.set_audio(audio)


func open_hub(can_continue: bool, _see_through: bool = false) -> void:
	_has_save = bool(can_continue)
	_apply_menu_state(_has_save)
	if _title_screen and _title_screen.has_method("set_progress"):
		_title_screen.set_progress(BIOME.snapshot())
	if _title_screen and _title_screen.has_method("close_settings"):
		_title_screen.close_settings()
	if _title_screen and _title_screen.has_method("close_start_over_confirm"):
		_title_screen.close_start_over_confirm()
	visible = true
	move_to_front()
	call_deferred("_focus_default")


## Exported playtest build only — editor F5 still shows Middle Progress.
static func middle_progress_allowed() -> bool:
	if OS.has_feature("editor"):
		return true
	if OS.has_feature("playtest"):
		return false
	return true


## Pure menu-visibility contract for selftests (no node tree required).
static func menu_visibility(has_save: bool, allow_middle: bool = false) -> Dictionary:
	return {
		"new_game": not has_save,
		"continue": has_save,
		"start_over": has_save,
		"middle": bool(allow_middle),
		"settings": true,
		"feedback": true,
		"default_focus": "continue" if has_save else "new_game",
	}


func close_hub() -> void:
	if _title_screen and _title_screen.has_method("close_settings"):
		_title_screen.close_settings()
	if _title_screen and _title_screen.has_method("close_start_over_confirm"):
		_title_screen.close_start_over_confirm()
	visible = false


func visible_action_ids() -> Array:
	var out: Array = []
	for id in _option_ids:
		out.append(String(id))
	if _btn_mid != null and _btn_mid.visible:
		if not out.has("middle"):
			out.append("middle")
	return out


func default_focus_id() -> String:
	if _has_save:
		return "continue"
	return "new_game"


func open_title_settings() -> void:
	if _title_screen and _title_screen.has_method("open_settings"):
		_title_screen.open_settings()


func close_title_settings() -> void:
	if _title_screen and _title_screen.has_method("close_settings"):
		_title_screen.close_settings()


func settings_panel_node():
	if _title_screen and _title_screen.has_method("settings_panel_node"):
		return _title_screen.settings_panel_node()
	return null


func sync_settings_toggles(sparkles_on: bool, invert_scroll: bool, reduce_motion: bool) -> void:
	var panel = settings_panel_node()
	if panel == null:
		return
	if "sparkles_on" in panel:
		panel.sparkles_on = sparkles_on
	if "invert_scroll" in panel:
		panel.invert_scroll = invert_scroll
	if "reduce_motion" in panel:
		panel.reduce_motion = reduce_motion
	if panel.has_method("apply_toggle_labels"):
		panel.apply_toggle_labels()
	if _title_screen and "reduce_motion" in _title_screen:
		_title_screen.reduce_motion = reduce_motion


func _apply_menu_state(has_save: bool) -> void:
	_has_save = has_save
	_option_ids.clear()
	## title.menu.{new_game|continue|settings|feedback|start_over}
	if has_save:
		_option_ids.append(&"continue")
	else:
		_option_ids.append(&"new_game")
	_option_ids.append(&"settings")
	_option_ids.append(&"feedback")
	if has_save:
		_option_ids.append(&"start_over")
	if _title_screen and _title_screen.has_method("set_options"):
		_title_screen.set_options(_option_ids.duplicate())
	if _btn_mid:
		_btn_mid.visible = middle_progress_allowed()


func _build() -> void:
	_title_screen = TITLE_SCREEN_SCENE.instantiate() as Control
	if _title_screen == null:
		push_error("playtest_hub: title_screen scene missing")
		return
	_title_screen.name = "TitleScreen"
	_title_screen.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_title_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_title_screen)
	if _title_screen.has_method("set_audio"):
		_title_screen.set_audio(_audio)
	if _title_screen.has_signal("option_activated"):
		_title_screen.option_activated.connect(_on_option_activated)

	## Editor-only Middle Progress (export hides via middle_progress_allowed).
	_btn_mid = Button.new()
	_btn_mid.name = "MiddleProgress"
	_btn_mid.flat = true
	_btn_mid.focus_mode = Control.FOCUS_ALL
	_btn_mid.position = Vector2(1210, 660)
	_btn_mid.size = Vector2(240, 26)
	_btn_mid.add_theme_font_size_override("font_size", 17)
	_btn_mid.add_theme_color_override("font_color", Color("9c8f7d"))
	_btn_mid.add_theme_color_override("font_hover_color", Color("f4ede3"))
	_btn_mid.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_btn_mid.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_btn_mid.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_btn_mid.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_btn_mid.text = "Middle Progress"
	_btn_mid.visible = false
	_btn_mid.pressed.connect(func() -> void: middle_progress.emit())
	add_child(_btn_mid)


func _on_option_activated(id: StringName) -> void:
	match String(id):
		"new_game":
			brand_new.emit()
		"continue":
			continue_save.emit()
		"feedback":
			feedback_wanted.emit()
		"settings":
			## title_screen already opens its SettingsScreen; sync cabin → panel via main.
			settings_wanted.emit()
		"start_over":
			## Confirm UI is owned by title_screen; wait for wipe.
			pass
		"start_over_wipe":
			start_over_confirmed.emit()
		_:
			pass


func _focus_default() -> void:
	if _title_screen == null:
		return
	var want := default_focus_id()
	for i in range(3):
		var row: Control = _title_screen.find_child("Row_%d" % i, true, false) as Control
		if row == null or not row.visible:
			continue
		var tag: Button = row.find_child("Tag", true, false) as Button
		if tag == null:
			continue
		## Tag text is player copy (title.menu.new_game / title.menu.continue / …).
		var label := COPY.text("title.menu.%s" % want, "")
		if label != "" and tag.text == label:
			tag.grab_focus()
			return
	## Fallback: first visible row tag.
	for i in range(3):
		var row2: Control = _title_screen.find_child("Row_%d" % i, true, false) as Control
		if row2 and row2.visible:
			var tag2: Button = row2.find_child("Tag", true, false) as Button
			if tag2:
				tag2.grab_focus()
				return
