extends Control
## Carry-3 layout B: room bag affordance lives on rope_exit; this owns the
## fullscreen overlay + reminder popup and talks to Main's carry hooks.

signal closed
signal delve_requested
signal continue_without_packing

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const RULES := preload("res://scripts/carry3_ui_rules.gd")

const PANEL := Rect2(240, 80, 1200, 880)
const TITLE_R := Rect2(280, 110, 1120, 56)
const HINT_R := Rect2(280, 170, 1120, 56)
const KEEPING_R := Rect2(280, 240, 1120, 40)
const POOL_R := Rect2(280, 300, 700, 480)
const BAG_ZONE := Rect2(1000, 320, 400, 360)
const SATCHEL_R := Rect2(1072, 340, 256, 168)
const SLOT_Y := 540.0
const SLOT_X0 := 1048.0
const SLOT_GAP := 16.0
const SLOT_SZ := 64.0
const DELVE_R := Rect2(1080, 820, 256, 80)
const DELVE_CAP_R := Rect2(1080, 900, 256, 36)
const REMINDER_PANEL := Rect2(520, 300, 640, 360)
const REMINDER_TITLE := Rect2(560, 330, 560, 48)
const REMINDER_BODY := Rect2(560, 390, 560, 120)
const REMINDER_OK := Rect2(560, 540, 240, 72)
const REMINDER_NO := Rect2(840, 540, 280, 72)

var cabin
var art
var main
var _items: Array = []
var _selection: Array = []
var _overlay_open: bool = false
var _reminder_open: bool = false

var _scrim: ColorRect
var _panel: NinePatchRect
var _title: FitLabelBox
var _hint: FitLabelBox
var _keeping: FitLabelBox
var _pool_host: Control
var _bag_host: Control
var _satchel: TextureRect
var _slots: Array = []
var _delve_btn: TextureButton
var _delve_label: FitLabelBox
var _delve_caption: FitLabelBox

var _reminder_root: Control
var _reminder_scrim: ColorRect
var _reminder_panel: NinePatchRect
var _reminder_title: FitLabelBox
var _reminder_body: FitLabelBox
var _reminder_ok: FitButton
var _reminder_ok_lab: FitLabelBox
var _reminder_no: FitButton
var _reminder_no_lab: FitLabelBox


func setup(p_cabin, p_art, p_main) -> void:
	cabin = p_cabin
	art = p_art
	main = p_main
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	z_as_relative = false
	z_index = 92
	_build_overlay()
	_build_reminder()
	_set_overlay_visible(false)
	_set_reminder_visible(false)


func is_overlay_open() -> bool:
	return _overlay_open


func is_reminder_open() -> bool:
	return _reminder_open


func open_overlay(items: Array, selection: Array = []) -> void:
	_items = items.duplicate(true)
	_selection = selection.duplicate()
	if main and main.has_method("mark_bag_opened_this_transition"):
		main.mark_bag_opened_this_transition()
	_set_reminder_visible(false)
	_set_overlay_visible(true)
	_rebuild_lists()
	if main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(false)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.sack_shake")


func close_overlay(keep_chrome: bool = true) -> void:
	if not _overlay_open:
		return
	_set_overlay_visible(false)
	if keep_chrome and main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(true)
	closed.emit()


func show_reminder() -> void:
	_set_overlay_visible(false)
	_set_reminder_visible(true)
	if main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(false)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")


func hide_reminder() -> void:
	_set_reminder_visible(false)
	if main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(true)


func _build_overlay() -> void:
	_scrim = KIT.scrim(0.78, 50)
	_scrim.name = "Carry3Scrim"
	_scrim.gui_input.connect(_on_scrim_input)
	add_child(_scrim)
	_panel = KIT.ui_nine("carry3/overlay_panel_9.png", 12, 12, 12, 12)
	_panel.name = "Carry3Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	KIT.apply_rect(_panel, PANEL, 55)
	add_child(_panel)
	_title = KIT.fit_label(
		"carry3.overlay.title",
		TITLE_R,
		44,
		24,
		1,
		KIT.TITLE_CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		65
	)
	add_child(_title)
	_hint = KIT.fit_label(
		"carry3.overlay.hint",
		HINT_R,
		26,
		16,
		2,
		KIT.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		65
	)
	add_child(_hint)
	_keeping = KIT.fit_label(
		"carry3.overlay.keeping",
		KEEPING_R,
		28,
		18,
		1,
		Color("ffd84a"),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		65
	)
	add_child(_keeping)
	_pool_host = Control.new()
	_pool_host.name = "LeavePool"
	_pool_host.position = POOL_R.position
	_pool_host.size = POOL_R.size
	_pool_host.z_index = 60
	_pool_host.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_pool_host)
	_bag_host = Control.new()
	_bag_host.name = "BagZone"
	_bag_host.position = BAG_ZONE.position
	_bag_host.size = BAG_ZONE.size
	_bag_host.z_index = 60
	_bag_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bag_host)
	_satchel = TextureRect.new()
	_satchel.name = "SatchelOpen"
	_satchel.texture = KIT.ui_tex("carry3/satchel_open_overlay")
	_satchel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_satchel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_satchel.stretch_mode = TextureRect.STRETCH_SCALE
	_satchel.position = SATCHEL_R.position - BAG_ZONE.position
	_satchel.size = SATCHEL_R.size
	_satchel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_host.add_child(_satchel)
	_slots.clear()
	for i in 3:
		var slot := Control.new()
		slot.name = "Slot_%d" % i
		slot.position = Vector2(SLOT_X0 - BAG_ZONE.position.x + float(i) * (SLOT_SZ + SLOT_GAP), SLOT_Y - BAG_ZONE.position.y)
		slot.size = Vector2(SLOT_SZ, SLOT_SZ)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var pad := TextureRect.new()
		pad.name = "Pad"
		pad.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pad.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pad.stretch_mode = TextureRect.STRETCH_SCALE
		pad.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(pad)
		var rim := TextureRect.new()
		rim.name = "Rim"
		rim.texture = KIT.ui_tex("carry3/keep_rim_64")
		rim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		rim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rim.stretch_mode = TextureRect.STRETCH_SCALE
		rim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rim.visible = false
		slot.add_child(rim)
		var ic := TextureRect.new()
		ic.name = "Icon"
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		ic.offset_left = 6
		ic.offset_top = 6
		ic.offset_right = -6
		ic.offset_bottom = -6
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
		slot.gui_input.connect(_on_slot_input.bind(i))
		_bag_host.add_child(slot)
		_slots.append(slot)
	_delve_btn = TextureButton.new()
	_delve_btn.name = "Delve"
	_delve_btn.ignore_texture_size = true
	_delve_btn.stretch_mode = TextureButton.STRETCH_SCALE
	_delve_btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_delve_btn.texture_normal = KIT.ui_tex("carry3/delve_normal")
	_delve_btn.texture_hover = KIT.ui_tex("carry3/delve_hover")
	_delve_btn.texture_disabled = KIT.ui_tex("carry3/delve_locked_badged")
	_delve_btn.texture_pressed = KIT.ui_tex("carry3/delve_hover")
	KIT.apply_rect(_delve_btn, DELVE_R, 70)
	_delve_btn.pressed.connect(_on_delve_pressed)
	add_child(_delve_btn)
	_delve_label = KIT.fit_label(
		"carry3.overlay.delve",
		DELVE_R,
		36,
		22,
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		71
	)
	_delve_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_delve_label)
	_delve_caption = KIT.fit_label(
		"carry3.overlay.ready",
		DELVE_CAP_R,
		22,
		14,
		1,
		KIT.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		71
	)
	add_child(_delve_caption)


func _build_reminder() -> void:
	_reminder_root = Control.new()
	_reminder_root.name = "Carry3Reminder"
	_reminder_root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_reminder_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_reminder_root.z_index = 80
	add_child(_reminder_root)
	_reminder_scrim = KIT.scrim(0.72, 50)
	_reminder_root.add_child(_reminder_scrim)
	_reminder_panel = KIT.ui_nine("carry3/reminder_panel_9.png", 14, 14, 14, 14)
	_reminder_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	KIT.apply_rect(_reminder_panel, REMINDER_PANEL, 55)
	_reminder_root.add_child(_reminder_panel)
	_reminder_title = KIT.fit_label(
		"carry3.reminder.title",
		REMINDER_TITLE,
		36,
		22,
		2,
		KIT.TITLE_CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		65
	)
	_reminder_root.add_child(_reminder_title)
	_reminder_body = KIT.fit_label(
		"carry3.reminder.body",
		REMINDER_BODY,
		24,
		14,
		4,
		KIT.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_TOP,
		65
	)
	_reminder_root.add_child(_reminder_body)
	_reminder_ok = KIT.plank(REMINDER_OK, 70, true)
	_reminder_ok.pressed.connect(_on_reminder_okay)
	_reminder_root.add_child(_reminder_ok)
	_reminder_ok_lab = KIT.fit_label(
		"carry3.reminder.okay",
		REMINDER_OK,
		28,
		16,
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		71
	)
	_reminder_ok_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reminder_root.add_child(_reminder_ok_lab)
	_reminder_no = KIT.plank(REMINDER_NO, 70, false)
	_reminder_no.pressed.connect(_on_reminder_continue)
	_reminder_root.add_child(_reminder_no)
	_reminder_no_lab = KIT.fit_label(
		"carry3.reminder.continue",
		REMINDER_NO,
		26,
		14,
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		71
	)
	_reminder_no_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reminder_root.add_child(_reminder_no_lab)


func _set_overlay_visible(on: bool) -> void:
	_overlay_open = on
	_scrim.visible = on
	_panel.visible = on
	_title.visible = on
	_hint.visible = on
	_keeping.visible = on
	_pool_host.visible = on
	_bag_host.visible = on
	_delve_btn.visible = on
	_delve_label.visible = on
	_delve_caption.visible = on
	mouse_filter = Control.MOUSE_FILTER_STOP if on or _reminder_open else Control.MOUSE_FILTER_IGNORE


func _set_reminder_visible(on: bool) -> void:
	_reminder_open = on
	_reminder_root.visible = on
	mouse_filter = Control.MOUSE_FILTER_STOP if on or _overlay_open else Control.MOUSE_FILTER_IGNORE


func _rebuild_lists() -> void:
	for c in _pool_host.get_children():
		c.queue_free()
	var packed: Dictionary = {}
	for raw in _selection:
		packed[int(raw)] = true
	var leave: Array = []
	var keep_items: Array = []
	for it in _items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		if packed.has(uid):
			keep_items.append(it)
		else:
			leave.append(it)
	var cols := 4
	var cell_w := 140.0
	var cell_h := 200.0
	var gap_x := 20.0
	var gap_y := 16.0
	for i in leave.size():
		var it: Dictionary = leave[i]
		var col: int = i % cols
		var row: int = i / cols
		var wrap := _make_pool_card(it, false)
		wrap.position = Vector2(float(col) * (cell_w + gap_x), float(row) * (cell_h + gap_y))
		_pool_host.add_child(wrap)
	for i in 3:
		var slot: Control = _slots[i]
		var pad: TextureRect = slot.get_node("Pad")
		var rim: TextureRect = slot.get_node("Rim")
		var ic: TextureRect = slot.get_node("Icon")
		if i < keep_items.size():
			var kit: Dictionary = keep_items[i]
			pad.texture = KIT.ui_tex("carry3/slot_filled_64")
			rim.visible = true
			ic.texture = _item_tex(kit)
			slot.set_meta("uid", int(kit.get("uid", -1)))
		else:
			pad.texture = KIT.ui_tex("carry3/slot_empty_dashed_64")
			rim.visible = false
			ic.texture = null
			slot.set_meta("uid", -1)
	_refresh_keeping_and_delve()
	_push_selection_to_main()


func _make_pool_card(it: Dictionary, _in_bag: bool) -> Control:
	var wrap := Control.new()
	wrap.size = Vector2(140, 200)
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	wrap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var uid: int = int(it.get("uid", -1))
	wrap.set_meta("uid", uid)
	var front := TextureRect.new()
	front.texture = KIT.ui_tex("carry3/card_front")
	front.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	front.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	front.stretch_mode = TextureRect.STRETCH_SCALE
	front.position = Vector2(6, 0)
	front.size = Vector2(128, 176)
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(front)
	var dim := TextureRect.new()
	dim.texture = KIT.ui_tex("carry3/leave_dim_pad")
	dim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dim.stretch_mode = TextureRect.STRETCH_SCALE
	dim.position = Vector2(40, 40)
	dim.size = Vector2(64, 64)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.modulate = Color(1, 1, 1, 0.55)
	wrap.add_child(dim)
	var ic := TextureRect.new()
	ic.texture = _item_tex(it)
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.position = Vector2(36, 36)
	ic.size = Vector2(72, 72)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(ic)
	var chip := TextureRect.new()
	chip.texture = KIT.ui_tex("carry3/leave_chip")
	chip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	chip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chip.stretch_mode = TextureRect.STRETCH_SCALE
	chip.position = Vector2(34, 176)
	chip.size = Vector2(72, 18)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(chip)
	var lab := KIT.fit_label(
		"carry3.overlay.leave",
		Rect2(34, 174, 72, 22),
		14,
		10,
		1,
		KIT.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		2
	)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(lab)
	wrap.gui_input.connect(_on_pool_card_input.bind(uid))
	return wrap


func _item_tex(it: Dictionary) -> Texture2D:
	var sid := str(it.get("card_id", ""))
	if art != null and art.has_method("item_tex"):
		var pix: Texture2D = art.item_tex(sid)
		if pix != null:
			return pix
	if main != null and main.has_method("_item_icon_tex"):
		return main._item_icon_tex(it)
	return null


func _refresh_keeping_and_delve() -> void:
	var n: int = _selection.size()
	_keeping.set_copy("carry3.overlay.keeping", {"n": n})
	var locked: bool = RULES.delve_locked(n)
	_delve_btn.disabled = locked
	if locked:
		_delve_btn.texture_normal = KIT.ui_tex("carry3/delve_locked_badged")
		_delve_btn.texture_hover = KIT.ui_tex("carry3/delve_locked_badged")
		_delve_caption.set_copy("carry3.overlay.locked", {"n": n})
	else:
		_delve_btn.texture_normal = KIT.ui_tex("carry3/delve_normal")
		_delve_btn.texture_hover = KIT.ui_tex("carry3/delve_hover")
		_delve_caption.set_copy("carry3.overlay.ready", {"n": n})


func _push_selection_to_main() -> void:
	if main and main.has_method("set_carry_bag_selection"):
		main.set_carry_bag_selection(_selection)
	if main and main.rope_exit and main.rope_exit.has_method("set_carry_bag_badge"):
		main.rope_exit.set_carry_bag_badge(_selection.size())


func _toggle(uid: int) -> void:
	if uid < 0:
		return
	_selection = RULES.toggle_uid(_selection, uid)
	_rebuild_lists()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")


func _on_pool_card_input(ev: InputEvent, uid: int) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		_toggle(uid)


func _on_slot_input(ev: InputEvent, slot_i: int) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		var slot: Control = _slots[slot_i]
		var uid: int = int(slot.get_meta("uid", -1))
		_toggle(uid)


func _on_scrim_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		close_overlay()


func _on_delve_pressed() -> void:
	if RULES.delve_locked(_selection.size()):
		return
	_push_selection_to_main()
	close_overlay(false)
	delve_requested.emit()


func _on_reminder_okay() -> void:
	hide_reminder()
	var items: Array = _items
	var sel: Array = _selection
	if main != null:
		items = main.hotbar.duplicate(true)
		if main.has_method("get_carry_bag_selection"):
			sel = main.get_carry_bag_selection()
	open_overlay(items, sel)


func _on_reminder_continue() -> void:
	hide_reminder()
	continue_without_packing.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _overlay_open and not _reminder_open:
		return
	if event.is_action_pressed("ui_cancel"):
		if _overlay_open:
			close_overlay()
			get_viewport().set_input_as_handled()
		elif _reminder_open:
			hide_reminder()
			get_viewport().set_input_as_handled()
