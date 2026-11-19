extends Control
## Spin-cascade stamp rail in the left gutter beside the wheel.
## Feel pass B: vertical ~40px tokens, docked from the wheel's left edge (not a hard Y).

const TOKEN_PX := 40.0
const ICON_PX := 28.0
const GAP := 6.0
const MAX_SHOW := 12
const STRIP_PAD := 10.0
const RAIL_GAP := 10.0 ## Gap between rail right edge and wheel left edge.
const FF_SLOT_H := 36.0
const DIM_A := 0.70
const Z_ABOVE_HOTBAR := 45

const FRAME_PATH := "res://assets/ui/anim/ticker_token_frame.png"
const STAMP_PATHS := [
	"res://assets/ui/anim/ticker_token_stamp_f0.png",
	"res://assets/ui/anim/ticker_token_stamp_f1.png",
	"res://assets/ui/anim/ticker_token_stamp_f2.png",
	"res://assets/ui/anim/ticker_token_stamp_f3.png",
]
const FF_PATH := "res://assets/ui/anim/ticker_ff.png"
const PANEL_PATH := "res://assets/dungeon/ui/panelInset_brown.png"

var active: bool = false
var _strip: NinePatchRect
var _tokens: VBoxContainer
var _ff: TextureRect
var _speed_line: ColorRect
var _entries: Array = [] # {id, node, frame, icon, state}
var _frame_tex: Texture2D
var _stamp_texs: Array = []
var _ff_tex: Texture2D
var _ff_on: bool = false
var _out_tw: Tween
var _wheel_rect := Rect2()
var _has_wheel := false


func _ready() -> void:
	pass


func setup() -> void:
	name = "CascadeTicker"
	top_level = true
	z_index = Z_ABOVE_HOTBAR
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	visible = false
	set_process(false)
	_frame_tex = _load_tex(FRAME_PATH)
	_stamp_texs.clear()
	for p in STAMP_PATHS:
		_stamp_texs.append(_load_tex(p))
	_ff_tex = _load_tex(FF_PATH)
	_strip = NinePatchRect.new()
	_strip.name = "Strip"
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.texture_filter = TEXTURE_FILTER_NEAREST
	var panel: Texture2D = _load_tex(PANEL_PATH)
	if panel != null:
		_strip.texture = panel
		_strip.patch_margin_left = 8
		_strip.patch_margin_right = 8
		_strip.patch_margin_top = 8
		_strip.patch_margin_bottom = 8
	else:
		_strip.modulate = Color(0.078, 0.063, 0.047, 0.92)
	add_child(_strip)
	_tokens = VBoxContainer.new()
	_tokens.name = "Tokens"
	_tokens.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tokens.add_theme_constant_override("separation", int(GAP))
	_strip.add_child(_tokens)
	_ff = TextureRect.new()
	_ff.name = "FF"
	_ff.texture = _ff_tex
	_ff.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ff.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_ff.texture_filter = TEXTURE_FILTER_NEAREST
	_ff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ff.custom_minimum_size = Vector2(32, 24)
	_ff.size = Vector2(32, 24)
	_ff.visible = false
	_strip.add_child(_ff)
	_speed_line = ColorRect.new()
	_speed_line.name = "SpeedLine"
	_speed_line.color = Color("e8c36a")
	_speed_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speed_line.visible = false
	_speed_line.size = Vector2(TOKEN_PX + 8.0, 2)
	_strip.add_child(_speed_line)
	_layout_strip()


## Dock to the left gutter of the wheel. Call from main layout whenever the wheel moves.
func dock_to_wheel(wheel: Control) -> void:
	if wheel == null or not is_instance_valid(wheel):
		_has_wheel = false
		return
	_wheel_rect = wheel.get_global_rect()
	_has_wheel = _wheel_rect.size.x > 8.0 and _wheel_rect.size.y > 8.0
	_layout_strip()


func begin() -> void:
	if _out_tw != null and is_instance_valid(_out_tw):
		_out_tw.kill()
		_out_tw = null
	active = true
	_clear_tokens()
	modulate = Color.WHITE
	visible = true
	set_ff(false)
	_layout_strip()


func push(id: String, tex: Texture2D) -> int:
	if not active:
		return -1
	_dim_older()
	var idx: int = _entries.size()
	var node := Control.new()
	node.name = "Token_%d" % idx
	node.custom_minimum_size = Vector2(TOKEN_PX, TOKEN_PX)
	node.size = Vector2(TOKEN_PX, TOKEN_PX)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.focus_mode = Control.FOCUS_NONE
	node.pivot_offset = Vector2(TOKEN_PX * 0.5, TOKEN_PX * 0.5)
	node.scale = Vector2(0.01, 0.01)
	node.modulate = Color(1, 1, 1, 1)
	var frame := TextureRect.new()
	frame.name = "Frame"
	frame.texture = _frame_tex
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.texture_filter = TEXTURE_FILTER_NEAREST
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.add_child(frame)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = tex
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad: float = (TOKEN_PX - ICON_PX) * 0.5
	icon.position = Vector2(pad, pad)
	icon.size = Vector2(ICON_PX, ICON_PX)
	node.add_child(icon)
	_tokens.add_child(node)
	_entries.append({
		"id": id,
		"node": node,
		"frame": frame,
		"icon": icon,
		"state": "new",
	})
	_trim_overflow()
	_layout_strip()
	## Small pop on the newest token — calm, no flash.
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(1.08, 1.08), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, 0.06)
	return idx


func light(ticket: int) -> void:
	if ticket < 0 or ticket >= _entries.size():
		return
	var e: Dictionary = _entries[ticket]
	var node: Control = e.get("node")
	if node == null or not is_instance_valid(node):
		return
	e["state"] = "active"
	node.modulate = Color(1, 1, 1, 1)
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2(1.06, 1.06), 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, 0.05)


func stamp(ticket: int) -> void:
	if ticket < 0 or ticket >= _entries.size():
		return
	var e: Dictionary = _entries[ticket]
	var node: Control = e.get("node")
	var frame: TextureRect = e.get("frame")
	if node == null or not is_instance_valid(node):
		return
	e["state"] = "stamping"
	node.scale = Vector2.ONE
	if frame != null and not _stamp_texs.is_empty():
		for i in range(_stamp_texs.size()):
			frame.texture = _stamp_texs[i]
			await get_tree().create_timer(0.04, false).timeout
			if not is_instance_valid(frame):
				return
	if frame != null and _frame_tex != null:
		frame.texture = _frame_tex
	node.modulate = Color(1, 1, 1, DIM_A)
	e["state"] = "done"
	if node.get_node_or_null("Tick") == null:
		var tick := Label.new()
		tick.name = "Tick"
		tick.text = "+"
		tick.add_theme_font_size_override("font_size", 12)
		tick.add_theme_color_override("font_color", Color("e8c36a"))
		tick.add_theme_color_override("font_outline_color", Color("100e0c"))
		tick.add_theme_constant_override("outline_size", 4)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.position = Vector2(TOKEN_PX - 16.0, TOKEN_PX - 16.0)
		tick.size = Vector2(16, 16)
		node.add_child(tick)


func end() -> void:
	active = false
	set_ff(false)
	if not visible or _entries.is_empty():
		_clear_tokens()
		visible = false
		return
	if _out_tw != null and is_instance_valid(_out_tw):
		_out_tw.kill()
	_out_tw = create_tween()
	_out_tw.tween_interval(0.40)
	_out_tw.tween_property(self, "modulate:a", 0.0, 0.20)
	_out_tw.finished.connect(func() -> void:
		_clear_tokens()
		visible = false
		modulate = Color.WHITE
		_out_tw = null
	)


func set_ff(on: bool) -> void:
	_ff_on = on
	if _ff != null:
		_ff.visible = on
	if _speed_line != null:
		_speed_line.visible = on
	_layout_strip()


func is_ff() -> bool:
	return _ff_on


func rail_global_rect() -> Rect2:
	return get_global_rect()


func _dim_older() -> void:
	for e in _entries:
		var st: String = str(e.get("state", ""))
		if st == "active":
			continue
		var node: Control = e.get("node")
		if node == null or not is_instance_valid(node):
			continue
		node.modulate = Color(1, 1, 1, DIM_A)
		if st == "new":
			e["state"] = "dim"


func _trim_overflow() -> void:
	while _tokens.get_child_count() > MAX_SHOW:
		var old: Node = _tokens.get_child(0)
		if old == null or not is_instance_valid(old):
			break
		var fade := old.create_tween()
		fade.tween_property(old, "modulate:a", 0.0, 0.12)
		fade.finished.connect(old.queue_free)


func _layout_strip() -> void:
	var n: int = maxi(1, _tokens.get_child_count())
	var ff_h: float = FF_SLOT_H if _ff_on else 0.0
	var inner_h: float = float(n) * TOKEN_PX + float(maxi(0, n - 1)) * GAP + STRIP_PAD * 2.0 + ff_h
	var w: float = TOKEN_PX + STRIP_PAD * 2.0
	var h: float = maxf(TOKEN_PX + STRIP_PAD * 2.0, inner_h)
	size = Vector2(w, h)
	var pos := Vector2(8.0, 200.0)
	if _has_wheel:
		## Left gutter: rail right edge sits RAIL_GAP left of the wheel.
		pos.x = _wheel_rect.position.x - w - RAIL_GAP
		## Start near the top of the wheel seat band; keep clear of the combat log top.
		pos.y = _wheel_rect.position.y + 24.0
		## Clamp so we never sit under the log button strip or off-screen.
		pos.x = maxf(8.0, pos.x)
		pos.y = clampf(pos.y, 180.0, maxf(180.0, _wheel_rect.end.y - h - 8.0))
	else:
		var view_w: float = 1680.0
		var vp := get_viewport()
		if vp != null:
			var vr: Rect2 = vp.get_visible_rect()
			if vr.size.x > 1.0:
				view_w = vr.size.x
		## Fallback when no wheel yet: left gutter of a centered ~720 wheel.
		var wheel_left: float = (view_w - 720.0) * 0.5
		pos = Vector2(maxf(8.0, wheel_left - w - RAIL_GAP), 220.0)
	global_position = pos
	_strip.position = Vector2.ZERO
	_strip.size = size
	_tokens.position = Vector2(STRIP_PAD, STRIP_PAD)
	_tokens.size = Vector2(TOKEN_PX, h - STRIP_PAD * 2.0 - ff_h)
	if _ff != null:
		_ff.position = Vector2((w - 32.0) * 0.5, h - STRIP_PAD - 24.0)
	if _speed_line != null:
		_speed_line.position = Vector2(STRIP_PAD - 2.0, h - 6.0)
		_speed_line.size = Vector2(TOKEN_PX + 4.0, 2.0)


func _clear_tokens() -> void:
	for c in _tokens.get_children():
		c.queue_free()
	_entries.clear()


func _load_tex(path: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
