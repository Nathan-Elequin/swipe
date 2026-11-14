class_name TrophyBoardSlot
extends Control
## One pyramid slot: recess + item sprite + claimed aura.


signal hovered(card_id: String, state: StringName)
signal unhovered(card_id: String)
signal clicked(card_id: String, state: StringName)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")

var card_id: String = ""
var slot_state: StringName = &"unseen"
var item_tex: Texture2D = null
var reduce_motion: bool = false

var _recess: Control
var _aura: TextureRect
var _sprite: TextureRect
var _twinkle: TextureRect
var _twinkle_t: float = 0.0
var _aura_i: int = 0
var _aura_t: float = 0.0
var _compact: bool = false
var _gentle_pulse: bool = false
var _pulse_tw: Tween = null


func setup(p_id: String, rect: Rect2, compact: bool) -> void:
	card_id = p_id
	_compact = compact
	name = "Slot_%s" % p_id
	position = rect.position
	size = rect.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_recess = _make_recess()
	add_child(_recess)
	_aura = TextureRect.new()
	_aura.name = "Aura"
	_aura.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_aura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_aura.stretch_mode = TextureRect.STRETCH_SCALE
	_aura.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aura.visible = false
	_aura.z_index = 0
	add_child(_aura)
	_sprite = TextureRect.new()
	_sprite.name = "Sprite"
	_sprite.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite.z_index = 1
	add_child(_sprite)
	_twinkle = TextureRect.new()
	_twinkle.name = "Twinkle"
	_twinkle.size = Vector2(32, 32)
	_twinkle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_twinkle.stretch_mode = TextureRect.STRETCH_SCALE
	_twinkle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_twinkle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_twinkle.visible = false
	_twinkle.z_index = 2
	add_child(_twinkle)
	_twinkle_t = randf_range(3.0, 6.0)
	_apply_recess_art(false)
	_load_aura_frame(0)


func _make_recess() -> Control:
	var tex_name := "trophy_board/slot_recess_dark_s" if _compact else "trophy_board/slot_recess_dark"
	var tex: Texture2D = KIT.ui_tex(tex_name)
	if tex != null:
		var tr := TextureRect.new()
		tr.name = "Recess"
		tr.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.texture = tex
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return tr
	var box := Panel.new()
	box.name = "Recess"
	box.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1e120c")
	sb.border_color = Color("4a2f1f")
	sb.set_border_width_all(2)
	box.add_theme_stylebox_override("panel", sb)
	return box


func set_item_texture(tex: Texture2D) -> void:
	item_tex = tex
	if _sprite:
		_sprite.texture = tex


func apply_state(st: StringName, force_unseen := false) -> void:
	slot_state = &"unseen" if force_unseen else st
	var claimed := slot_state == &"claimed"
	_apply_recess_art(claimed)
	if _sprite:
		_sprite.visible = true
		if item_tex != null:
			_sprite.texture = item_tex
		if slot_state == &"unseen":
			_sprite.modulate = MODEL.SILHOUETTE
		else:
			_sprite.modulate = Color.WHITE
	if _aura:
		_aura.visible = claimed and not reduce_motion
		if claimed and reduce_motion:
			_aura.visible = true
			_load_aura_frame(0)
	if _twinkle:
		_twinkle.visible = false


func play_claim_pop() -> void:
	apply_state(&"claimed")
	if reduce_motion or _sprite == null:
		return
	_sprite.scale = Vector2(1.15, 1.15)
	_sprite.modulate = Color(1.6, 1.6, 1.6, 1.0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_sprite, "scale", Vector2.ONE, 0.18 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.5 / maxf(Engine.time_scale, 0.001))


## First-return: pulse gently until hovered once. Reduce motion → static brighten.
func set_gentle_pulse(on: bool) -> void:
	_gentle_pulse = on
	if _pulse_tw != null and _pulse_tw.is_valid():
		_pulse_tw.kill()
	_pulse_tw = null
	if _sprite == null:
		return
	if not on:
		_sprite.modulate = Color.WHITE if slot_state != &"unseen" else MODEL.SILHOUETTE
		return
	if reduce_motion:
		_sprite.modulate = Color(1.35, 1.25, 0.9, 1.0)
		return
	_pulse_tw = create_tween().set_loops(24)
	_pulse_tw.tween_property(_sprite, "modulate", Color(1.45, 1.35, 0.95, 1.0), 0.55 / maxf(Engine.time_scale, 0.001))
	_pulse_tw.tween_property(_sprite, "modulate", Color.WHITE, 0.55 / maxf(Engine.time_scale, 0.001))


func _apply_recess_art(lit: bool) -> void:
	if _recess == null:
		return
	var stem := "trophy_board/slot_recess_lit" if lit else "trophy_board/slot_recess_dark"
	if _compact:
		stem += "_s"
	if _recess is TextureRect:
		var tex: Texture2D = KIT.ui_tex(stem)
		if tex != null:
			(_recess as TextureRect).texture = tex
	elif _recess is Panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("5c3a22") if lit else Color("1e120c")
		sb.border_color = Color("e8c36a") if lit else Color("4a2f1f")
		sb.set_border_width_all(3 if lit else 2)
		(_recess as Panel).add_theme_stylebox_override("panel", sb)


func _load_aura_frame(i: int) -> void:
	if _aura == null:
		return
	var stem := "trophy_board/aura_claimed_s_f%d" % i if _compact else "trophy_board/aura_claimed_f%d" % i
	var tex: Texture2D = KIT.ui_tex(stem)
	if tex != null:
		_aura.texture = tex
	else:
		_aura.texture = null
		_aura.modulate = Color(1, 0.85, 0.3, 0.35)


func _process(delta: float) -> void:
	if slot_state != &"claimed" or reduce_motion:
		return
	_aura_t += delta * Engine.time_scale
	if _aura_t >= 1.0 / 8.0:
		_aura_t = 0.0
		_aura_i = (_aura_i + 1) % 6
		_load_aura_frame(_aura_i)
	_twinkle_t -= delta * Engine.time_scale
	if _twinkle_t <= 0.0 and _twinkle != null:
		_twinkle_t = randf_range(3.0, 6.0)
		var tex: Texture2D = KIT.ui_tex("trophy_board/twinkle_f0")
		_twinkle.texture = tex
		_twinkle.position = Vector2(randf_range(0, maxf(0, size.x - 32)), randf_range(0, maxf(0, size.y - 32)))
		_twinkle.visible = true
		var tw := create_tween()
		tw.tween_interval(0.25 / maxf(Engine.time_scale, 0.001))
		tw.tween_callback(func() -> void:
			if is_instance_valid(_twinkle):
				_twinkle.visible = false
		)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(card_id, slot_state)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		hovered.emit(card_id, slot_state)
	elif what == NOTIFICATION_MOUSE_EXIT:
		unhovered.emit(card_id)
