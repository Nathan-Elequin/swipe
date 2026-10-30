extends Control
## NEW items only. Read-only. Max 10 drawn.

signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const LAYOUT_PATH := "res://design/visual/layouts/rope-exit-sack-peek.layout.json"

var cabin
var extra: Dictionary = {}
var art
var main
var _lay: Dictionary = {}
var _count: FitLabelBox
var _slots: Array = []
var _close_btn: FitButton


func setup(p_cabin, p_extra: Dictionary, p_art, p_main) -> void:
	cabin = p_cabin
	extra = p_extra
	art = p_art
	main = p_main
	_lay = KIT.load_layout(LAYOUT_PATH)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	z_as_relative = false
	z_index = 90
	var scrim_el: Dictionary = KIT.layout_el(_lay, "Scrim")
	var scrim: ColorRect = KIT.scrim(float(scrim_el.get("alpha", 0.75)), int(scrim_el.get("z", 50)))
	scrim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			close()
	)
	add_child(scrim)
	var panel_el: Dictionary = KIT.layout_el(_lay, "SackPanel")
	var panel: NinePatchRect = KIT.ui_nine("panel/parchment_panel_9.png", 24, 24, 24, 24)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	KIT.apply_rect(panel, KIT.rect_px(panel_el.get("rect", [440, 136, 800, 768])), int(panel_el.get("z", 55)))
	add_child(panel)
	var title_el: Dictionary = KIT.layout_child(panel_el, "Sack.Title")
	var tt: Dictionary = title_el.get("text", {})
	var title: FitLabelBox = KIT.fit_label(
		"sack.title",
		KIT.rect_px(title_el.get("rect", [])),
		int(tt.get("font_max", 48)),
		int(tt.get("font_min", 24)),
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(title_el.get("z", 65))
	)
	add_child(title)
	var count_el: Dictionary = KIT.layout_child(panel_el, "Sack.Count")
	var ct: Dictionary = count_el.get("text", {})
	_count = KIT.fit_label(
		"sack.none",
		KIT.rect_px(count_el.get("rect", [])),
		int(ct.get("font_max", 32)),
		int(ct.get("font_min", 20)),
		int(ct.get("max_lines", 2)),
		KIT.WOOD,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(count_el.get("z", 65))
	)
	add_child(_count)
	var grid_el: Dictionary = KIT.layout_child(panel_el, "Sack.Grid")
	var grid_r: Rect2 = KIT.rect_px(grid_el.get("rect", [480, 304, 720, 368]))
	var cell: Array = grid_el.get("cell", [120, 152])
	var gap: Array = grid_el.get("gap", [16, 24])
	var cw: float = float(cell[0])
	var ch: float = float(cell[1])
	var gx: float = float(gap[0])
	var gy: float = float(gap[1])
	var cols: int = int(grid_el.get("cols", 5))
	var rows: int = int(grid_el.get("rows", 2))
	for row in rows:
		for col in cols:
			var wrap := Control.new()
			wrap.position = grid_r.position + Vector2(float(col) * (cw + gx), float(row) * (ch + gy))
			wrap.size = Vector2(cw, ch)
			wrap.z_index = int(grid_el.get("z", 62))
			wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var glow := TextureRect.new()
			glow.texture = KIT.load_tex("overlays/sack_slot_glow.png")
			glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			glow.set_anchors_preset(Control.PRESET_FULL_RECT)
			glow.offset_left = 8
			glow.offset_top = 8
			glow.offset_right = -8
			glow.offset_bottom = -8
			glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
			wrap.add_child(glow)
			var ic := TextureRect.new()
			ic.name = "Icon"
			ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			ic.set_anchors_preset(Control.PRESET_FULL_RECT)
			ic.offset_left = 16
			ic.offset_top = 16
			ic.offset_right = -16
			ic.offset_bottom = -16
			ic.pivot_offset = Vector2((cw - 32.0) * 0.5, (ch - 32.0) * 0.5)
			wrap.add_child(ic)
			add_child(wrap)
			_slots.append(wrap)
	var hint_el: Dictionary = KIT.layout_child(panel_el, "Sack.Hint")
	var ht: Dictionary = hint_el.get("text", {})
	var hint: FitLabelBox = KIT.fit_label(
		"sack.hint",
		KIT.rect_px(hint_el.get("rect", [])),
		int(ht.get("font_max", 28)),
		int(ht.get("font_min", 16)),
		int(ht.get("max_lines", 2)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(hint_el.get("z", 65))
	)
	add_child(hint)
	var close_el: Dictionary = KIT.layout_el(_lay, "Sack.Close")
	_close_btn = KIT.plank(KIT.rect_px(close_el.get("rect", [640, 776, 400, 96])), int(close_el.get("z", 70)), true)
	_close_btn.pressed.connect(close)
	add_child(_close_btn)
	var clab_el: Dictionary = KIT.layout_child(close_el, "Sack.Close.Label")
	var clt: Dictionary = clab_el.get("text", {})
	var clab: FitLabelBox = KIT.fit_label(
		"sack.close",
		KIT.rect_px(clab_el.get("rect", [])),
		int(clt.get("font_max", 40)),
		int(clt.get("font_min", 24)),
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(clab_el.get("z", 71))
	)
	add_child(clab)


func open_peek() -> void:
	visible = true
	if main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(false)
	var ids: Array = _new_ids()
	var n: int = ids.size()
	if n == 0:
		_count.set_copy("sack.none")
	else:
		_count.set_copy("sack.new_count", {"n": n})
	for i in _slots.size():
		var wrap: Control = _slots[i]
		var ic: TextureRect = wrap.get_node("Icon")
		if i < mini(n, 10):
			var id: String = str(ids[i])
			ic.texture = art.item_tex(id) if art else null
			wrap.visible = true
			ic.scale = Vector2.ZERO
			var tw := create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_interval(0.05 * float(i))
			tw.tween_property(ic, "scale", Vector2.ONE, 0.12)
		else:
			wrap.visible = false
	if _close_btn:
		_close_btn.grab_focus()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.sack_shake")


func _new_ids() -> Array:
	var out: Array = []
	var seen_ids: Dictionary = {}
	if main == null:
		return out
	for it in main.hotbar:
		var id: String = str(it.get("card_id", ""))
		if id == "" or seen_ids.has(id):
			continue
		if BucketRules.is_token(it):
			continue
		if cabin and cabin.is_swiped(id):
			continue
		seen_ids[id] = true
		out.append(id)
	return out


func close() -> void:
	if not visible:
		return
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	visible = false
	if main and main.rope_exit and main.rope_exit.has_method("set_chrome_visible"):
		main.rope_exit.set_chrome_visible(true)
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
