class_name TrophyBoardSlot
extends Control
## One pyramid slot: low plinth slab + item sprite + claimed glow. No nameplates.


signal hovered(card_id: String, state: StringName)
signal unhovered(card_id: String)
signal clicked(card_id: String, state: StringName)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const AURA_FPS := 6.0

## Pixel drop paths (Nearest). Low slabs under each cell — never the old square recess.
const PLINTH_CLAIMED := "trophy/plinth_claimed"
const PLINTH_EMPTY := "trophy/plinth_empty"
const PLINTH_CLAIMED_S := "trophy/plinth_claimed_s"
const PLINTH_EMPTY_S := "trophy/plinth_empty_s"
## Slab local rects (slot-local). Overlaps cell bottom; extends into the row gap.
const PLINTH_RECT := Rect2(0, 116, 128, 32)
const PLINTH_RECT_S := Rect2(0, 68, 80, 24)

var card_id: String = ""
var slot_state: StringName = &"unclaimed"
var claim_metal: String = ""
var item_tex: Texture2D = null
var reduce_motion: bool = false

var _recess: Control
var _glow: ColorRect
var _aura: AnimatedSprite2D
var _sprite: TextureRect
var _shine: ColorRect
var _compact: bool = false
var _gentle_pulse: bool = false
var _pulse_tw: Tween = null
var _rest_pad: float = 0.0


static func metal_for_rank(rank: int) -> String:
	match clampi(rank, 1, 3):
		3:
			return "gold"
		2:
			return "silver"
		_:
			return "bronze"


func set_claim_metal(metal: String) -> void:
	claim_metal = str(metal).strip_edges()


func resolve_plinth_tex(claimed: bool) -> Texture2D:
	if not claimed:
		return KIT.ui_tex(_plinth_stem(false))
	var metal := claim_metal.strip_edges()
	if metal != "":
		var stem := "trophy/plinth_claimed_s_%s" % metal if _compact else "trophy/plinth_claimed_%s" % metal
		var tinted: Texture2D = KIT.ui_tex(stem)
		if tinted != null:
			return tinted
	return KIT.ui_tex(_plinth_stem(true))


func resolve_aura_stem() -> String:
	if slot_state != &"claimed":
		return ""
	var metal := claim_metal.strip_edges()
	if metal == "":
		return "trophy_board/aura_claimed_s_f0" if _compact else "trophy_board/aura_claimed_f0"
	if _compact:
		return "trophy_board/aura_claimed_s_%s_f0" % metal
	return "trophy_board/aura_claimed_%s_f0" % metal


func setup(p_id: String, rect: Rect2, compact: bool) -> void:
	card_id = p_id
	_compact = compact
	name = "Slot_%s" % p_id
	position = rect.position
	size = rect.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	## Slab draws below the cell into the row gap.
	clip_contents = false
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	_recess = _make_plinth(false)
	add_child(_recess)
	## Soft gold wash behind claimed items (kept subtle under the pulse ring).
	_glow = ColorRect.new()
	_glow.name = "ClaimGlow"
	_glow.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_glow.offset_left = 16
	_glow.offset_top = 16
	_glow.offset_right = -16
	_glow.offset_bottom = -16
	_glow.color = Color(1.0, 0.88, 0.45, 0.16)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.visible = false
	_glow.z_index = 1
	add_child(_glow)
	## Claimed metal auras loop at 6 fps; pulse_ring is the last fallback.
	_aura = AnimatedSprite2D.new()
	_aura.name = "Aura"
	_aura.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_aura.centered = true
	_aura.visible = false
	_aura.z_index = 1
	add_child(_aura)
	_place_pulse_ring()
	_sprite = TextureRect.new()
	_sprite.name = "Sprite"
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	## Above the slab — silhouette modulate must never tint the plinth.
	_sprite.z_index = 2
	_sprite.position = Vector2.ZERO
	_sprite.size = size
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
	_refresh_aura_visual()


func _plinth_stem(claimed: bool) -> String:
	if _compact:
		return PLINTH_CLAIMED_S if claimed else PLINTH_EMPTY_S
	return PLINTH_CLAIMED if claimed else PLINTH_EMPTY


func _plinth_rect() -> Rect2:
	return PLINTH_RECT_S if _compact else PLINTH_RECT


func _make_plinth(claimed: bool) -> Control:
	var tex: Texture2D = KIT.ui_tex(_plinth_stem(claimed))
	var pr: Rect2 = _plinth_rect()
	if tex != null:
		var tr := TextureRect.new()
		tr.name = "Plinth"
		tr.position = pr.position
		tr.size = pr.size
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.texture = tex
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		## z=0 (not -1): negative z draws behind the face oak bg sibling and hides slabs.
		tr.z_index = 0
		tr.modulate = Color.WHITE
		return tr
	## Missing art only — never the old square recess on the board.
	var box := Panel.new()
	box.name = "Plinth"
	box.position = pr.position
	box.size = pr.size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("5c3a22") if claimed else Color("1e120c")
	sb.border_color = Color("e8c36a") if claimed else Color("4a2f1f")
	sb.set_border_width_all(3 if claimed else 2)
	box.add_theme_stylebox_override("panel", sb)
	return box


func set_item_texture(tex: Texture2D) -> void:
	item_tex = tex
	_rest_pad = _bottom_pad_px(tex)
	if _sprite:
		_sprite.texture = tex
		_apply_sprite_rest()


## Transparent bottom rows × display scale so the icon rests on the slab top face (y=128 / y=80).
func _bottom_pad_px(tex: Texture2D) -> float:
	if tex == null:
		return 0.0
	var img: Image = tex.get_image()
	if img == null and tex.resource_path != "":
		img = Image.new()
		if img.load(tex.resource_path) != OK:
			return 0.0
	if img == null:
		return 0.0
	var used: Rect2i = img.get_used_rect()
	var bottom_pad: float = float(img.get_height()) - float(used.end.y)
	## Icons are 64 native; board shows them at 2× (128) or 1.25× (80 compact).
	var scale: float = 1.25 if _compact else 2.0
	return maxf(0.0, bottom_pad * scale)


func _apply_sprite_rest() -> void:
	if _sprite == null:
		return
	_sprite.position = Vector2(0.0, _rest_pad)
	_sprite.size = size


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
		_apply_sprite_rest()
		if claimed:
			_sprite.modulate = Color(1.08, 1.06, 1.02, 1.0)
		else:
			_sprite.modulate = MODEL.SILHOUETTE
	if _aura:
		if claimed:
			_refresh_aura_visual()
			_aura.visible = true
			_aura.modulate = Color(1, 1, 1, 0.85)
			_place_pulse_ring()
			if _aura.sprite_frames != null and _aura.sprite_frames.get_frame_count("aura") > 0:
				_aura.play("aura")
			else:
				_aura.stop()
		else:
			_aura.visible = false
			_aura.stop()


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
	var tex: Texture2D = resolve_plinth_tex(claimed)
	var pr: Rect2 = _plinth_rect()
	## Keep slab on WIRING rect; never inherit silhouette/dark modulate.
	_recess.z_index = 0
	_recess.modulate = Color.WHITE
	_recess.visible = true
	if _recess is TextureRect:
		var tr := _recess as TextureRect
		tr.position = pr.position
		tr.size = pr.size
		if tex != null:
			tr.texture = tex
		tr.modulate = Color.WHITE
	elif _recess is Panel:
		var box := _recess as Panel
		box.position = pr.position
		box.size = pr.size
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("6a4228") if claimed else Color("3a2418")
		sb.border_color = Color("e8c36a") if claimed else Color("6a4a32")
		sb.set_border_width_all(3 if claimed else 2)
		box.add_theme_stylebox_override("panel", sb)


func _place_pulse_ring() -> void:
	if _aura == null:
		return
	var cx: float = size.x * 0.5
	var cy: float = size.y * 0.5
	_aura.position = Vector2(cx, cy)


func _aura_frame_stems(metal: String) -> Array:
	var stems: Array = []
	var prefix := "trophy_board/aura_claimed_s_%s_f" % metal if _compact else "trophy_board/aura_claimed_%s_f" % metal
	for fi in 6:
		stems.append("%s%d" % [prefix, fi])
	return stems


func _untinted_aura_stems() -> Array:
	var stems: Array = []
	var prefix := "trophy_board/aura_claimed_s_f" if _compact else "trophy_board/aura_claimed_f"
	for fi in 6:
		stems.append("%s%d" % [prefix, fi])
	return stems


func _build_aura_frames(stems: Array) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation("aura")
	sf.set_animation_speed("aura", AURA_FPS)
	sf.set_animation_loop("aura", true)
	var any := false
	for stem in stems:
		var tex: Texture2D = KIT.ui_tex(str(stem))
		if tex != null:
			sf.add_frame("aura", tex)
			any = true
	if not any:
		return null
	return sf


func _refresh_aura_visual() -> void:
	if _aura == null:
		return
	_place_pulse_ring()
	var sf: SpriteFrames = null
	var metal := claim_metal.strip_edges()
	if metal != "":
		sf = _build_aura_frames(_aura_frame_stems(metal))
	if sf == null:
		sf = _build_aura_frames(_untinted_aura_stems())
	if sf == null:
		var ring: Texture2D = KIT.ui_tex("trophy/pulse_ring")
		if ring != null:
			sf = SpriteFrames.new()
			sf.add_animation("aura")
			sf.set_animation_speed("aura", AURA_FPS)
			sf.set_animation_loop("aura", true)
			sf.add_frame("aura", ring)
	if sf == null:
		_aura.sprite_frames = null
		_aura.modulate = Color(1, 0.85, 0.3, 0.35)
		return
	_aura.sprite_frames = sf
	_aura.scale = Vector2.ONE
	var f0: Texture2D = sf.get_frame_texture("aura", 0)
	if f0 != null and _compact and f0.get_width() >= 120:
		var ring_sz: float = 100.0
		_aura.scale = Vector2(ring_sz / float(f0.get_width()), ring_sz / float(f0.get_height()))
	elif f0 != null and not _compact and f0.get_width() >= 120:
		var ring_sz2: float = 160.0
		_aura.scale = Vector2(ring_sz2 / float(f0.get_width()), ring_sz2 / float(f0.get_height()))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(card_id, slot_state)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		hovered.emit(card_id, slot_state)
	elif what == NOTIFICATION_MOUSE_EXIT:
		unhovered.emit(card_id)
