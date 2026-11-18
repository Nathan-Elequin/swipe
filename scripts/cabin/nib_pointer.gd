class_name NibPointer
extends Control
## Tutorial-style pointer from Nib's talk bar to a hall target, plus a pulsing ring.
## Prefers pulse_ring_sheet.png (4×160 frames) and falls back to pulse_ring.png.


const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PULSE_RING_PATH := "res://assets/ui/trophy/pulse_ring.png"
const PULSE_RING_SHEET_PATH := "res://assets/ui/trophy/pulse_ring_sheet.png"
const PULSE_FRAME := 160
const PULSE_FPS := 8.0
const GLOVE_PATH := "res://assets/ui/tutorial/tut_glove_bob_f%d.png"
const ARROWHEAD_PATH := "res://assets/ui/tutorial/tut_arrowhead_f0.png"
## Glove art points right; arrowhead points up-right (~-PI/4 from +X).
const ARROW_ART_ANGLE := -PI / 4.0

var _ink: Control = null
var _ring: Control = null
var _ring_art: CanvasItem = null
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _active: bool = false
var _pulse_tw: Tween = null
var _ring_px: float = PULSE_FRAME
var _glove: AnimatedSprite2D = null
var _arrowhead: Sprite2D = null
var _sprite_pointer: bool = false


func _ready() -> void:
	name = "NibPointer"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 60
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_ink = Control.new()
	_ink.name = "PointerInk"
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_ink.draw.connect(_draw_pointer)
	add_child(_ink)
	_ensure_pointer_sprites()
	_ensure_pulse_ring()
	visible = false


func _ensure_pointer_sprites() -> void:
	if _glove != null and is_instance_valid(_glove):
		return
	var sf := SpriteFrames.new()
	sf.add_animation("bob")
	sf.set_animation_speed("bob", 6.0)
	sf.set_animation_loop("bob", true)
	var glove_ok := false
	for i in 5:
		var path := GLOVE_PATH % i
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			sf.add_frame("bob", tex)
			glove_ok = true
	var ah_tex: Texture2D = null
	if ResourceLoader.exists(ARROWHEAD_PATH):
		ah_tex = load(ARROWHEAD_PATH) as Texture2D
	if not glove_ok or ah_tex == null:
		_sprite_pointer = false
		return
	_sprite_pointer = true
	_glove = AnimatedSprite2D.new()
	_glove.name = "TutGlove"
	_glove.sprite_frames = sf
	_glove.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_glove.centered = true
	_glove.scale = Vector2(2.5, 2.5)
	_glove.z_index = 2
	_glove.visible = false
	add_child(_glove)
	_glove.play("bob")
	_arrowhead = Sprite2D.new()
	_arrowhead.name = "TutArrowhead"
	_arrowhead.texture = ah_tex
	_arrowhead.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_arrowhead.centered = true
	_arrowhead.scale = Vector2(2.5, 2.5)
	_arrowhead.z_index = 2
	_arrowhead.visible = false
	add_child(_arrowhead)


func _ensure_pulse_ring() -> void:
	if _ring != null and is_instance_valid(_ring):
		return
	_ring = Control.new()
	_ring.name = "PulseRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.z_index = 1
	_ring.size = Vector2(PULSE_FRAME, PULSE_FRAME)
	add_child(_ring)
	if ResourceLoader.exists(PULSE_RING_SHEET_PATH):
		var sheet: Texture2D = load(PULSE_RING_SHEET_PATH) as Texture2D
		var spr := AnimatedSprite2D.new()
		spr.name = "PulseRingArt"
		spr.centered = false
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var sf := SpriteFrames.new()
		sf.add_animation("pulse")
		sf.set_animation_speed("pulse", PULSE_FPS)
		sf.set_animation_loop("pulse", true)
		for i in 4:
			var at := AtlasTexture.new()
			at.atlas = sheet
			at.region = Rect2(i * PULSE_FRAME, 0, PULSE_FRAME, PULSE_FRAME)
			sf.add_frame("pulse", at)
		spr.sprite_frames = sf
		spr.position = Vector2.ZERO
		_ring.add_child(spr)
		_ring_art = spr
	elif ResourceLoader.exists(PULSE_RING_PATH):
		var tr := TextureRect.new()
		tr.name = "PulseRingArt"
		tr.texture = load(PULSE_RING_PATH) as Texture2D
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ring.add_child(tr)
		_ring_art = tr
	else:
		var box := ColorRect.new()
		box.name = "PulseRingPlaceholder"
		box.color = Color(1.0, 0.85, 0.3, 0.45)
		box.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ring.add_child(box)
		_ring_art = box
	_ring.visible = false


## Point from a talk-bar rect (global) to a target control/rect. Shows ring on the target.
## ring_size: pulse art native is 160 (trophy slot). Pass ~96 for a hotbar New! star.
func point_at(from_global: Vector2, target: Control, ring_pad: Vector2 = Vector2(24, 24), ring_size: float = -1.0) -> void:
	_ensure_pulse_ring()
	_active = true
	visible = true
	_from = from_global
	var g: Rect2
	if target != null and is_instance_valid(target):
		g = target.get_global_rect()
	else:
		g = Rect2(from_global + Vector2(80, -120), Vector2(64, 64))
	_to = g.position + g.size * 0.5
	_place_ring(_to, ring_size)
	_ink.queue_redraw()
	_start_pulse()


func point_at_rect(from_global: Vector2, target_global: Rect2, ring_pad: Vector2 = Vector2(24, 24), ring_size: float = -1.0) -> void:
	_ensure_pulse_ring()
	_active = true
	visible = true
	_from = from_global
	_to = target_global.position + target_global.size * 0.5
	_place_ring(_to, ring_size)
	_ink.queue_redraw()
	_start_pulse()


func _place_ring(center: Vector2, ring_size: float = -1.0) -> void:
	## 160×160 ring centred on the target (encloses a 128 slot). Scale down for smaller marks.
	_ring_px = PULSE_FRAME if ring_size <= 0.0 else ring_size
	_ring.size = Vector2(_ring_px, _ring_px)
	_ring.global_position = center - _ring.size * 0.5
	_ring.visible = true
	var s: float = _ring_px / float(PULSE_FRAME)
	if _ring_art is AnimatedSprite2D:
		var spr := _ring_art as AnimatedSprite2D
		spr.scale = Vector2(s, s)
		if spr.sprite_frames != null and spr.sprite_frames.has_animation("pulse"):
			spr.play("pulse")
	elif _ring_art is Control:
		(_ring_art as Control).set_anchors_and_offsets_preset(PRESET_FULL_RECT)


func clear() -> void:
	_active = false
	visible = false
	if _ring != null:
		_ring.visible = false
	if _ring_art is AnimatedSprite2D:
		(_ring_art as AnimatedSprite2D).stop()
	if _glove != null:
		_glove.visible = false
		_glove.stop()
	if _arrowhead != null:
		_arrowhead.visible = false
	if _pulse_tw != null and is_instance_valid(_pulse_tw):
		_pulse_tw.kill()
		_pulse_tw = null
	if _ink != null:
		_ink.queue_redraw()


func _start_pulse() -> void:
	if _ring == null:
		return
	if _pulse_tw != null and is_instance_valid(_pulse_tw):
		_pulse_tw.kill()
	_ring.modulate = Color(1, 1, 1, 1)
	## Sheet animation carries the expand/fade; keep a soft opacity breathe as backup.
	if _ring_art is AnimatedSprite2D:
		return
	_pulse_tw = create_tween()
	_pulse_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pulse_tw.set_loops()
	_pulse_tw.tween_property(_ring, "modulate:a", 0.35, 0.45)
	_pulse_tw.tween_property(_ring, "modulate:a", 0.95, 0.45)


func _place_sprite_pointer() -> void:
	_ensure_pointer_sprites()
	if not _sprite_pointer or _glove == null or _arrowhead == null:
		if _glove != null:
			_glove.visible = false
		if _arrowhead != null:
			_arrowhead.visible = false
		return
	var dir: Vector2 = _to - _from
	if dir.length() < 12.0:
		_glove.visible = false
		_arrowhead.visible = false
		return
	dir = dir.normalized()
	var ang: float = dir.angle()
	_glove.global_position = _from
	_glove.rotation = ang
	_glove.visible = true
	if not _glove.is_playing():
		_glove.play("bob")
	_arrowhead.global_position = _to
	_arrowhead.rotation = ang - ARROW_ART_ANGLE
	_arrowhead.visible = true


func _draw_pointer() -> void:
	if not _active or _ink == null:
		return
	_place_sprite_pointer()
	if _sprite_pointer:
		return
	var origin: Vector2 = _ink.global_position
	var a: Vector2 = _from - origin
	var b: Vector2 = _to - origin
	if a.distance_to(b) < 12.0:
		return
	## Fallback vector stroke when glove/arrowhead textures are missing.
	var gold := Color("e8c36a")
	_ink.draw_line(a, b, Color("100e0c"), 9.0, true)
	_ink.draw_line(a, b, gold, 5.0, true)
	var dir: Vector2 = (b - a).normalized()
	var side: Vector2 = Vector2(-dir.y, dir.x)
	_ink.draw_colored_polygon(PackedVector2Array([
		b,
		b - dir * 18.0 + side * 9.0,
		b - dir * 18.0 - side * 9.0,
	]), Color("100e0c"))
	_ink.draw_colored_polygon(PackedVector2Array([
		b - dir * 2.0,
		b - dir * 16.0 + side * 6.0,
		b - dir * 16.0 - side * 6.0,
	]), gold)
