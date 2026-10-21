extends Node2D
## Grappling Hook: throw rope → taut → arc-swap portraits → retract.

const THROW_PATHS := [
	"res://assets/dungeon/anim/hook_throw_f0.png",
	"res://assets/dungeon/anim/hook_throw_f1.png",
	"res://assets/dungeon/anim/hook_throw_f2.png",
	"res://assets/dungeon/anim/hook_throw_f3.png",
	"res://assets/dungeon/anim/hook_throw_f4.png",
	"res://assets/dungeon/anim/hook_throw_f5.png",
]
const TAUT_PATH := "res://assets/dungeon/anim/hook_taut.png"
const ROPE_PATH := "res://assets/dungeon/anim/rope_tile.png"

var _main: Node = null
var _rope: Line2D
var _head: AnimatedSprite2D
var _taut_tex: Texture2D
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _sag: float = 20.0
var _tip_u: float = 0.0
var _ghost_a: TextureRect
var _ghost_b: TextureRect


func setup(main: Node) -> void:
	_main = main
	name = "HookFx"
	top_level = true
	z_index = 13
	texture_filter = TEXTURE_FILTER_NEAREST
	visible = false
	_taut_tex = _load_tex(TAUT_PATH)
	_rope = Line2D.new()
	_rope.name = "Rope"
	_rope.width = 10.0
	_rope.default_color = Color("c4a574")
	_rope.texture_mode = Line2D.LINE_TEXTURE_TILE
	_rope.texture_filter = TEXTURE_FILTER_NEAREST
	_rope.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_rope.end_cap_mode = Line2D.LINE_CAP_ROUND
	_rope.joint_mode = Line2D.LINE_JOINT_ROUND
	var rope_tex: Texture2D = _load_tex(ROPE_PATH)
	if rope_tex != null:
		_rope.texture = rope_tex
	_rope.antialiased = false
	add_child(_rope)
	_head = AnimatedSprite2D.new()
	_head.name = "Head"
	_head.texture_filter = TEXTURE_FILTER_NEAREST
	_head.centered = true
	_head.scale = Vector2(2.5, 2.5)
	_head.z_index = 1
	var frames := SpriteFrames.new()
	frames.add_animation("throw")
	frames.set_animation_speed("throw", 25.0)
	frames.set_animation_loop("throw", false)
	for p in THROW_PATHS:
		var tex: Texture2D = _load_tex(p)
		if tex != null:
			frames.add_frame("throw", tex)
	frames.add_animation("taut")
	frames.set_animation_loop("taut", true)
	if _taut_tex != null:
		frames.add_frame("taut", _taut_tex)
	_head.sprite_frames = frames
	add_child(_head)
	_ghost_a = _make_ghost("GhostA")
	_ghost_b = _make_ghost("GhostB")
	add_child(_ghost_a)
	add_child(_ghost_b)


func throw(from_card: Vector2, to_slice: Vector2) -> void:
	_from = from_card
	_to = to_slice
	_sag = 20.0
	_tip_u = 0.0
	visible = true
	_head.visible = true
	_rope.visible = true
	_update_rope(0.0)
	if _head.sprite_frames != null and _head.sprite_frames.get_frame_count("throw") > 0:
		_head.play("throw")
	var tw := create_tween()
	tw.tween_method(_update_rope, 0.0, 1.0, 0.24)
	await tw.finished
	_sag = 0.0
	_update_rope(1.0)
	if _head.sprite_frames != null and _head.sprite_frames.has_animation("taut"):
		_head.play("taut")
	# Catch shake on target slice.
	var wheel = _main.get("wheel_view") if _main != null else null
	if wheel != null:
		var base: Vector2 = wheel.global_position
		var shake := create_tween()
		shake.tween_property(wheel, "global_position", base + Vector2(3, 0), 0.04)
		shake.tween_property(wheel, "global_position", base + Vector2(-3, 0), 0.04)
		shake.tween_property(wheel, "global_position", base, 0.04)
		await shake.finished
	else:
		await get_tree().create_timer(0.08).timeout


func yank(face_i: int, neighbor_i: int) -> void:
	var wheel = _main.get("wheel_view") if _main != null else null
	if wheel == null:
		await get_tree().create_timer(0.32).timeout
		return
	var art = _main.get("art") if _main != null else null
	var slices: Array = wheel.slices
	var id_a := ""
	var id_b := ""
	if face_i >= 0 and face_i < slices.size():
		id_a = str(slices[face_i].get("card_id", ""))
	if neighbor_i >= 0 and neighbor_i < slices.size():
		id_b = str(slices[neighbor_i].get("card_id", ""))
	var tex_a: Texture2D = null
	var tex_b: Texture2D = null
	if art != null and art.has_method("monster_still"):
		tex_a = art.monster_still(id_a)
		tex_b = art.monster_still(id_b)
	var from_a: Vector2 = wheel.slice_portrait_global(face_i)
	var from_b: Vector2 = wheel.slice_portrait_global(neighbor_i)
	var hub: Vector2 = wheel.get_global_transform() * (wheel.size * 0.5)
	_ghost_a.texture = tex_a
	_ghost_b.texture = tex_b
	_ghost_a.visible = tex_a != null
	_ghost_b.visible = tex_b != null
	_ghost_a.global_position = from_a - _ghost_a.size * 0.5
	_ghost_b.global_position = from_b - _ghost_b.size * 0.5
	var rad_a: float = maxf(8.0, from_a.distance_to(hub))
	var rad_b: float = maxf(8.0, from_b.distance_to(hub))
	var ang_a0: float = (from_a - hub).angle()
	var ang_b0: float = (from_b - hub).angle()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_method(
		func(u: float) -> void:
			var aa: float = lerpf(ang_a0, ang_b0, u)
			var ab: float = lerpf(ang_b0, ang_a0, u)
			var pa: Vector2 = hub + Vector2.from_angle(aa) * rad_a
			var pb: Vector2 = hub + Vector2.from_angle(ab) * rad_b
			_ghost_a.global_position = pa - _ghost_a.size * 0.5
			_ghost_b.global_position = pb - _ghost_b.size * 0.5
			_from = pa
			_to = pb
			_update_rope(1.0),
		0.0,
		1.0,
		0.32
	)
	await tw.finished
	_ghost_a.visible = false
	_ghost_b.visible = false
	wheel.queue_redraw()


func retract() -> void:
	var tw := create_tween()
	tw.tween_method(
		func(u: float) -> void:
			_tip_u = 1.0 - u
			_update_rope(_tip_u),
		0.0,
		1.0,
		0.16
	)
	await tw.finished
	visible = false
	_head.visible = false
	_rope.visible = false


func _update_rope(u: float) -> void:
	_tip_u = clampf(u, 0.0, 1.0)
	var tip: Vector2 = _from.lerp(_to, _tip_u)
	var mid: Vector2 = (_from + tip) * 0.5 + Vector2(0, _sag)
	_rope.clear_points()
	_rope.add_point(_from)
	_rope.add_point(mid)
	_rope.add_point(tip)
	_head.global_position = tip


func _make_ghost(n: String) -> TextureRect:
	var g := TextureRect.new()
	g.name = n
	g.visible = false
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.texture_filter = TEXTURE_FILTER_NEAREST
	g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	g.custom_minimum_size = Vector2(96, 96)
	g.size = Vector2(96, 96)
	return g


func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null
