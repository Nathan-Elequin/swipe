class_name NibPointer
extends Control
## Tutorial-style pointer from Nib's talk bar to a hall target, plus a pulsing ring.
## Loads assets/ui/trophy/pulse_ring.png when present so Pixel can swap art later.


const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PULSE_RING_PATH := "res://assets/ui/trophy/pulse_ring.png"

var _ink: Control = null
var _ring: Control = null
var _ring_art: CanvasItem = null
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _active: bool = false
var _pulse_tw: Tween = null


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
	_ensure_pulse_ring()
	visible = false


func _ensure_pulse_ring() -> void:
	if _ring != null and is_instance_valid(_ring):
		return
	_ring = Control.new()
	_ring.name = "PulseRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.z_index = 1
	add_child(_ring)
	if ResourceLoader.exists(PULSE_RING_PATH):
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
func point_at(from_global: Vector2, target: Control, ring_pad: Vector2 = Vector2(24, 24)) -> void:
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
	_ring.size = g.size + ring_pad * 2.0
	_ring.global_position = g.position + g.size * 0.5 - _ring.size * 0.5
	_ring.visible = true
	_ink.queue_redraw()
	_start_pulse()


func point_at_rect(from_global: Vector2, target_global: Rect2, ring_pad: Vector2 = Vector2(24, 24)) -> void:
	_ensure_pulse_ring()
	_active = true
	visible = true
	_from = from_global
	_to = target_global.position + target_global.size * 0.5
	_ring.size = target_global.size + ring_pad * 2.0
	_ring.global_position = target_global.position + target_global.size * 0.5 - _ring.size * 0.5
	_ring.visible = true
	_ink.queue_redraw()
	_start_pulse()


func clear() -> void:
	_active = false
	visible = false
	if _ring != null:
		_ring.visible = false
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
	_pulse_tw = create_tween()
	_pulse_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pulse_tw.set_loops()
	_pulse_tw.tween_property(_ring, "modulate:a", 0.35, 0.45)
	_pulse_tw.tween_property(_ring, "modulate:a", 0.95, 0.45)


func _draw_pointer() -> void:
	if not _active or _ink == null:
		return
	var origin: Vector2 = _ink.global_position
	var a: Vector2 = _from - origin
	var b: Vector2 = _to - origin
	if a.distance_to(b) < 12.0:
		return
	## Same gold tutorial stroke as TutorialGuide.SpotInk.
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
