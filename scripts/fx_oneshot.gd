extends RefCounted
## Self-freeing one-shot AnimatedSprite2D FX. Prefer FxOneShot.play(...) over duplicating setup.

const ANIM := &"fx"


static func play(
	parent: Node,
	frames: Array,
	global_pos: Vector2,
	draw_scale: float = 4.0,
	fps: float = 14.0,
	loop: bool = false,
	z: int = 40,
	centered: bool = true
) -> AnimatedSprite2D:
	if parent == null or frames.is_empty():
		return null
	var sf := SpriteFrames.new()
	sf.add_animation(ANIM)
	sf.set_animation_loop(ANIM, loop)
	sf.set_animation_speed(ANIM, maxf(1.0, fps))
	var added := 0
	for t in frames:
		if t is Texture2D and t != null:
			sf.add_frame(ANIM, t as Texture2D)
			added += 1
	if added < 1:
		return null
	var spr := AnimatedSprite2D.new()
	spr.name = "FxOneShot"
	spr.centered = centered
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	spr.sprite_frames = sf
	spr.scale = Vector2(draw_scale, draw_scale)
	# Parent first so global_position is in the parent's space. Setting it before
	# add_child treats the position as root-local, which offsets wheel-parented FX.
	parent.add_child(spr)
	spr.global_position = global_pos
	spr.play(ANIM)
	if not loop:
		spr.animation_finished.connect(spr.queue_free, CONNECT_ONE_SHOT)
	return spr


static func await_play(
	tree: SceneTree,
	parent: Node,
	frames: Array,
	global_pos: Vector2,
	draw_scale: float = 4.0,
	fps: float = 14.0,
	z: int = 40,
	centered: bool = true
) -> void:
	var spr: AnimatedSprite2D = play(parent, frames, global_pos, draw_scale, fps, false, z, centered)
	if spr == null:
		return
	if not is_instance_valid(spr):
		return
	if spr.is_playing():
		await spr.animation_finished
