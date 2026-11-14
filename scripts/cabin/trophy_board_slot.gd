class_name TrophyBoardSlot
extends Control
## One pyramid slot: plinth + item sprite + claimed glow. No nameplates.


signal hovered(card_id: String, state: StringName)
signal unhovered(card_id: String)
signal clicked(card_id: String, state: StringName)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")

## Pixel drop paths (Nearest). Fall back to legacy recess frames when missing.
const PLINTH_CLAIMED := "trophy/plinth_claimed"
const PLINTH_EMPTY := "trophy/plinth_empty"

var card_id: String = ""
var slot_state: StringName = &"unclaimed"
var item_tex: Texture2D = null
var reduce_motion: bool = false

var _recess: Control
var _glow: ColorRect
var _aura: TextureRect
var _sprite: TextureRect
var _shine: ColorRect
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
	_recess = _make_plinth(false)
	add_child(_recess)
	_glow = ColorRect.new()
	_glow.name = "ClaimGlow"
	_glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_glow.offset_left = 8
	_glow.offset_top = 8
	_glow.offset_right = -8
	_glow.offset_bottom = -8
	_glow.color = Color(1.0, 0.88, 0.45, 0.22)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.visible = false
	_glow.z_index = 0
	add_child(_glow)
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
	_shine = ColorRect.new()
	_shine.name = "ClickShine"
	_shine.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_shine.color = Color(1, 1, 1, 0)
	_shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shine.z_index = 3
	_shine.visible = false
	add_child(_shine)
	_apply_plinth_art(false)
	_load_aura_frame(0)


func _make_plinth(claimed: bool) -> Control:
	var plinth_stem := PLINTH_CLAIMED if claimed else PLINTH_EMPTY
	var tex: Texture2D = KIT.ui_tex(plinth_stem)
	if tex == null:
		var tex_name := "trophy_board/slot_recess_lit" if claimed else "trophy_board/slot_recess_dark"
		if _compact:
			tex_name += "_s"
		tex = KIT.ui_tex(tex_name)
	if tex != null:
		var tr := TextureRect.new()
		tr.name = "Plinth"
		tr.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.texture = tex
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return tr
	var box := Panel.new()
	box.name = "Plinth"
	box.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("5c3a22") if claimed else Color("1e120c")
	sb.border_color = Color("e8c36a") if claimed else Color("4a2f1f")
	sb.set_border_width_all(3 if claimed else 2)
	box.add_theme_stylebox_override("panel", sb)
	return box


func set_item_texture(tex: Texture2D) -> void:
	item_tex = tex
	if _sprite:
		_sprite.texture = tex


func apply_state(st: StringName, force_silhouette := false) -> void:
	## Locked faces force silhouette; unlocked faces are unclaimed or claimed only.
	if force_silhouette:
		slot_state = &"unclaimed"
	elif st == &"claimed":
		slot_state = &"claimed"
	else:
		## Map legacy unseen/seen → unclaimed.
		slot_state = &"unclaimed"
	var claimed := slot_state == &"claimed"
	_apply_plinth_art(claimed)
	if _glow:
		_glow.visible = claimed
		_glow.color = Color(1.0, 0.88, 0.45, 0.28 if claimed else 0.0)
	if _sprite:
		_sprite.visible = true
		if item_tex != null:
			_sprite.texture = item_tex
		if claimed:
			_sprite.modulate = Color(1.08, 1.06, 1.02, 1.0)
		else:
			_sprite.modulate = MODEL.SILHOUETTE
	if _aura:
		_aura.visible = claimed
		if claimed:
			_load_aura_frame(0)
			_aura.modulate = Color(1, 1, 1, 0.55)


func play_claim_pop() -> void:
	apply_state(&"claimed")
	if reduce_motion or _sprite == null:
		return
	_sprite.scale = Vector2(1.15, 1.15)
	_sprite.modulate = Color(1.6, 1.6, 1.6, 1.0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_sprite, "scale", Vector2.ONE, 0.18 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(_sprite, "modulate", Color(1.08, 1.06, 1.02, 1.0), 0.5 / maxf(Engine.time_scale, 0.001))


## Tiny one-shot shine on claimed plinth (~0.3 s white sweep).
func play_click_shine() -> void:
	if slot_state != &"claimed" or _shine == null:
		return
	if reduce_motion:
		_shine.visible = true
		_shine.color = Color(1, 1, 1, 0.35)
		var tw0 := create_tween()
		tw0.tween_property(_shine, "color:a", 0.0, 0.2 / maxf(Engine.time_scale, 0.001))
		tw0.tween_callback(func() -> void:
			if is_instance_valid(_shine):
				_shine.visible = false
		)
		return
	_shine.visible = true
	_shine.color = Color(1, 1, 1, 0.0)
	var tw := create_tween()
	tw.tween_property(_shine, "color:a", 0.55, 0.08 / maxf(Engine.time_scale, 0.001))
	tw.tween_property(_shine, "color:a", 0.0, 0.22 / maxf(Engine.time_scale, 0.001))
	tw.tween_callback(func() -> void:
		if is_instance_valid(_shine):
			_shine.visible = false
	)


## First-return: pulse gently until hovered once. Reduce motion → static brighten.
func set_gentle_pulse(on: bool) -> void:
	_gentle_pulse = on
	if _pulse_tw != null and _pulse_tw.is_valid():
		_pulse_tw.kill()
	_pulse_tw = null
	if _sprite == null:
		return
	if not on:
		_sprite.modulate = Color(1.08, 1.06, 1.02, 1.0) if slot_state == &"claimed" else MODEL.SILHOUETTE
		return
	if reduce_motion:
		_sprite.modulate = Color(1.35, 1.25, 0.9, 1.0)
		return
	_pulse_tw = create_tween().set_loops(24)
	_pulse_tw.tween_property(_sprite, "modulate", Color(1.45, 1.35, 0.95, 1.0), 0.55 / maxf(Engine.time_scale, 0.001))
	_pulse_tw.tween_property(_sprite, "modulate", Color(1.08, 1.06, 1.02, 1.0), 0.55 / maxf(Engine.time_scale, 0.001))


func _apply_plinth_art(claimed: bool) -> void:
	if _recess == null:
		return
	var plinth_stem := PLINTH_CLAIMED if claimed else PLINTH_EMPTY
	var tex: Texture2D = KIT.ui_tex(plinth_stem)
	if tex == null:
		var stem := "trophy_board/slot_recess_lit" if claimed else "trophy_board/slot_recess_dark"
		if _compact:
			stem += "_s"
		tex = KIT.ui_tex(stem)
	if _recess is TextureRect:
		if tex != null:
			(_recess as TextureRect).texture = tex
		## Claimed plinth reads brighter even on the legacy recess fallback.
		(_recess as TextureRect).modulate = Color(1.15, 1.08, 0.95, 1.0) if claimed else Color.WHITE
	elif _recess is Panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("6a4228") if claimed else Color("1e120c")
		sb.border_color = Color("e8c36a") if claimed else Color("4a2f1f")
		sb.set_border_width_all(3 if claimed else 2)
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


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(card_id, slot_state)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		hovered.emit(card_id, slot_state)
	elif what == NOTIFICATION_MOUSE_EXIT:
		unhovered.emit(card_id)
