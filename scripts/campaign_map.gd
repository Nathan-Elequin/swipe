extends Control
## Readable stand-in for the campaign map, the boss telegraph, and the win drawer.

signal start_asked(index: int, shortcut: bool, endless: bool)
signal closed
signal cheat_asked(action: String)
signal continued

var _body: VBoxContainer
var _margin: Control
var _held: Control
var _waiting: bool = false
var _kind: String = ""


func setup() -> void:
	name = "campaign_map"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_as_relative = false
	z_index = 140
	visible = false
	var scrim := ColorRect.new()
	scrim.color = Color("100e0cf2")
	scrim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)
	var margin := MarginContainer.new()
	_margin = margin
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 48)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	margin.add_child(scroll)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 14)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.custom_minimum_size = Vector2(900, 0)
	scroll.add_child(_body)
	_held = preload("res://scripts/cabin/held_map.gd").new()
	_held.setup()
	_held.start_asked.connect(func(index: int, shortcut: bool, endless: bool) -> void:
		start_asked.emit(index, shortcut, endless)
	)
	_held.cheat_asked.connect(func(action: String) -> void:
		cheat_asked.emit(action)
	)
	_held.closed.connect(func() -> void:
		closed.emit()
	)
	add_child(_held)


func is_picker_open() -> bool:
	return visible and _kind == "map"


func hide_map() -> void:
	var was_map := _kind == "map"
	visible = false
	_waiting = false
	_kind = ""
	if _held:
		_held.visible = false
	if was_map:
		_cue_scroll()


func show_map(rules: Dictionary, state: Dictionary) -> void:
	_waiting = false
	_kind = "map"
	_clear()
	# Held parchment is the real map (#118 wire). Text VBox stays for bosses/drawer.
	if _margin:
		_margin.visible = false
	if _held and _held.has_method("present"):
		_held.present(rules, state)
	_cue_scroll()
	visible = true
	move_to_front()


func _input(event: InputEvent) -> void:
	if _authoring_desk_open():
		return
	if not is_picker_open():
		return
	if _space(event) or event.is_action_pressed("ui_cancel"):
		closed.emit()
		get_viewport().set_input_as_handled()


func _authoring_desk_open() -> bool:
	if not is_inside_tree():
		return false
	for n in get_tree().get_nodes_in_group("authoring_overlay"):
		if n is CanvasItem and (n as CanvasItem).is_visible_in_tree():
			return true
	return false


func _space(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return false
	return key.keycode == KEY_SPACE or key.physical_keycode == KEY_SPACE


func show_bosses(biome_name: String, names: Array) -> void:
	_waiting = true
	_kind = "bosses"
	_show_text()
	_clear()
	_add_label(biome_name, 42, Color("e8c36a"))
	if names.is_empty():
		_add_label("None could be dealt.", 22, Color("e07040"))
	else:
		var n := names.size()
		if n == 1:
			_add_label("One Deadly boss is in this delve.", 24, Color("f4ede3"))
		else:
			_add_label("%d Deadly bosses are in this delve." % n, 24, Color("f4ede3"))
		for raw in names:
			_add_label(str(raw), 28, Color("e8c36a"))
	_add_button("Enter", func() -> void:
		if _waiting:
			_waiting = false
			continued.emit()
	)
	visible = true
	move_to_front()


func show_drawer() -> void:
	_waiting = true
	_kind = "drawer"
	_show_text()
	_clear()
	var COPY := preload("res://scripts/player_copy.gd")
	var eyebrow := COPY.text("endless.complete.eyebrow", "Campaign complete")
	var headline := COPY.text("endless.complete.headline", "Every cabinet is full.")
	var body := COPY.text("endless.complete.body", "Twenty-five uniques on the shelves. Something below them clicks.")
	var unlocked := COPY.text("endless.complete.unlocked", "Endless unlocked")
	var toast := COPY.text("endless.unlock_toast", "The deep opens.")
	var cta := COPY.text("endless.complete.enter", "Enter Endless")
	var cont := COPY.text("campaign.drawer.continue", "Continue")
	_add_label(eyebrow, 22, Color("c4a574"))
	_add_label(headline, 42, Color("e8c36a"))
	_add_label(body, 24, Color("f4ede3"))
	_add_label(unlocked, 26, Color("e8c36a"))
	_add_label(toast, 22, Color("c4a574"))
	## Bank path awaits `continued` then returns to the cabin; Endless starts from the map.
	_add_button(cta, func() -> void:
		if _waiting:
			_waiting = false
			continued.emit()
	)
	_add_button(cont, func() -> void:
		if _waiting:
			_waiting = false
			continued.emit()
	)
	visible = true
	move_to_front()


func _cue_scroll() -> void:
	var n: Node = self
	while n:
		var bank = n.get("sfx")
		if bank != null:
			var kit = load("res://scripts/cabin/cabin_kit.gd")
			kit.cue(bank, &"cabin.scroll")
			return
		n = n.get_parent()


func _show_text() -> void:
	if _held:
		_held.visible = false
	if _margin:
		_margin.visible = true


func _clear() -> void:
	if _body == null:
		return
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()


func _add_label(text: String, size_px: int, col: Color) -> void:
	var lab := Label.new()
	lab.text = text
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.add_theme_font_override("font", ThemeDB.fallback_font)
	lab.add_theme_font_size_override("font_size", size_px)
	lab.add_theme_color_override("font_color", col)
	_body.add_child(lab)


func _add_button(text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 48)
	b.add_theme_font_override("font", ThemeDB.fallback_font)
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(cb)
	_body.add_child(b)
