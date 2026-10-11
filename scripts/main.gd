extends "res://scripts/ui/authoring_ui.gd"
## Thin coordinator. Boot, frame, and input. Logic lives in scripts/{content,core,ui}/.
## Lane map: design/LANES.md.

func _ready() -> void:
	PLAYER_COPY.reload()
	_load_textures()
	_load_catalog()
	_load_runtime()
	art = DUNGEON_ART.new()
	add_child(art)
	art.setup()
	_prefer_pixel_art()
	_build_ui()
	_empty_wheel()
	phase = "title"
	_refresh()
	if sfx:
		sfx.start_music()


func _process(_delta: float) -> void:
	if fly_tip != null and fly_tip.visible:
		_place_fly(_fly_card)
	_place_fight_art()
	var sh: bool = Input.is_key_pressed(KEY_SHIFT)
	if sh != _shift_held:
		_shift_held = sh
		_sync_hotbar_formulas()
		_refresh_monster_plates()
		_refresh_gate_owner()
		if not _hover_item.is_empty():
			_show_item_inspect(_hover_item)
		if in_tutorial:
			_tutorial_shift_tick()
	_place_speech()
	if draft_gate != null and draft_gate.visible and wheel_view != null:
		draft_gate.dock(wheel_view)
	if in_tutorial:
		_tut_refresh_focus()
	if hud != null and hud.has_method("layout_hand") and phase != "title":
		hud.layout_hand()


func _unhandled_input(event: InputEvent) -> void:
	if phase == "devtest" and event.is_action_pressed("ui_accept"):
		_dev_enter()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		if roster_ed != null and roster_ed.visible:
			return
		if script_ed != null and script_ed.visible:
			return
		_open_roster()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		if roster_ed != null and roster_ed.visible:
			return
		if script_ed != null and script_ed.visible:
			return
		_open_script()
		get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if settings_ui == null or settings_ui.visible:
		return
	if content_ed != null and content_ed.visible:
		return
	if roster_ed != null and roster_ed.visible:
		return
	if script_ed != null and script_ed.visible:
		return
	if inspect:
		inspect.hide_plate()
	settings_ui.open_menu()
	if sfx:
		sfx.play("open", -12.0)
	get_viewport().set_input_as_handled()
