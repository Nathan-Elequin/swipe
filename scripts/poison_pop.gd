extends Node2D
## Poison wait drip + tick burst. Slice/hub badges draw in boss_wheel; this owns burst, fly number, heart drips.

const BURST_PATHS := [
	"res://assets/ui/anim/poison_burst_f0.png",
	"res://assets/ui/anim/poison_burst_f1.png",
	"res://assets/ui/anim/poison_burst_f2.png",
	"res://assets/ui/anim/poison_burst_f3.png",
]
const HEART_DRIP_PATHS := [
	"res://assets/ui/anim/heart_drip_f0.png",
	"res://assets/ui/anim/heart_drip_f1.png",
	"res://assets/ui/anim/heart_drip_f2.png",
	"res://assets/ui/anim/heart_drip_f3.png",
]

var _main: Node = null
var _burst: AnimatedSprite2D
var _num: Label
var _drip_pool: Array = []
var _burst_frames: Array = []
var _heart_frames: Array = []


func setup(main: Node) -> void:
	_main = main
	name = "PoisonPop"
	top_level = true
	z_index = 14
	texture_filter = TEXTURE_FILTER_NEAREST
	_burst_frames = _load_frames(BURST_PATHS)
	_heart_frames = _load_frames(HEART_DRIP_PATHS)
	_burst = AnimatedSprite2D.new()
	_burst.name = "Burst"
	_burst.texture_filter = TEXTURE_FILTER_NEAREST
	_burst.centered = true
	_burst.visible = false
	_burst.scale = Vector2(4, 4)
	var frames := SpriteFrames.new()
	frames.add_animation("burst")
	frames.set_animation_speed("burst", 20.0)
	frames.set_animation_loop("burst", false)
	for tex in _burst_frames:
		if tex != null:
			frames.add_frame("burst", tex)
	_burst.sprite_frames = frames
	add_child(_burst)
	_num = Label.new()
	_num.name = "Num"
	_num.visible = false
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_num.add_theme_font_size_override("font_size", 28)
	_num.add_theme_color_override("font_color", Color("e07a7a"))
	_num.add_theme_color_override("font_outline_color", Color("100e0c"))
	_num.add_theme_constant_override("outline_size", 3)
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_num.custom_minimum_size = Vector2(64, 40)
	_num.size = Vector2(64, 40)
	add_child(_num)
	# One drip sprite per heart. The cap is the player's heart count, not the wheel seat count.
	for i in 6:
		var drip := AnimatedSprite2D.new()
		drip.name = "Drip%s" % i
		drip.texture_filter = TEXTURE_FILTER_NEAREST
		drip.centered = true
		drip.visible = false
		drip.scale = Vector2(4, 4)
		var df := SpriteFrames.new()
		df.add_animation("drip")
		df.set_animation_speed("drip", 12.5)
		df.set_animation_loop("drip", false)
		for tex2 in _heart_frames:
			if tex2 != null:
				df.add_frame("drip", tex2)
		drip.sprite_frames = df
		add_child(drip)
		_drip_pool.append(drip)


func burst_slice(index: int, n: int) -> void:
	if n <= 0 or _main == null:
		return
	var wheel = _main.get("wheel_view")
	if wheel == null:
		return
	var slices: Variant = wheel.get("slices")
	if typeof(slices) != TYPE_ARRAY or index < 0 or index >= (slices as Array).size():
		return
	var from: Vector2 = _slice_badge_global(wheel, index)
	var to: Vector2 = wheel.hp_global(index) if wheel.has_method("hp_global") else from
	await _play_burst(from, to, n, false)


func burst_hub(n: int) -> void:
	if n <= 0 or _main == null:
		return
	var wheel = _main.get("wheel_view")
	var from: Vector2 = Vector2(232, 27)
	if wheel != null and wheel.has_method("hub_hearts_global"):
		from = wheel.hub_hearts_global() + Vector2(54, 0)
	var to: Vector2 = from + Vector2(-40, 0)
	if wheel != null and wheel.has_method("hub_hearts_global"):
		to = wheel.hub_hearts_global()
	await _play_burst(from, to, n, true)


func _play_burst(from: Vector2, to: Vector2, n: int, heart_drips: bool) -> void:
	# Swell is drawn on the wheel badge via meta; local burst sprite carries the pop.
	global_position = Vector2.ZERO
	_burst.global_position = from
	_burst.scale = Vector2(4, 4)
	_burst.visible = true
	var swell := create_tween()
	swell.tween_property(_burst, "scale", Vector2(5.6, 5.6), 0.10)
	await swell.finished
	if _burst.sprite_frames != null and _burst.sprite_frames.get_frame_count("burst") > 0:
		_burst.play("burst")
		await get_tree().create_timer(0.20).timeout
	else:
		await get_tree().create_timer(0.20).timeout
	_burst.visible = false
	_num.text = "−%s" % n
	_num.visible = true
	_num.global_position = from - _num.size * 0.5
	_num.modulate.a = 1.0
	var fly := create_tween()
	fly.set_trans(Tween.TRANS_QUAD)
	fly.set_ease(Tween.EASE_IN)
	fly.tween_property(_num, "global_position", to - _num.size * 0.5, 0.24)
	fly.parallel().tween_property(_num, "modulate:a", 0.0, 0.24)
	await fly.finished
	_num.visible = false
	_num.modulate.a = 1.0
	if heart_drips:
		await _run_heart_drips(to, n)


func _run_heart_drips(at: Vector2, n: int) -> void:
	var count: int = mini(n, _drip_pool.size())
	for i in count:
		var drip: AnimatedSprite2D = _drip_pool[i]
		drip.global_position = at + Vector2(float(i) * 14.0 - float(count) * 7.0, 0.0)
		drip.visible = true
		drip.modulate.a = 1.0
		if drip.sprite_frames != null and drip.sprite_frames.get_frame_count("drip") > 0:
			drip.play("drip")
		var tw := create_tween()
		tw.tween_property(drip, "global_position", drip.global_position + Vector2(0, 18), 0.08)
		tw.parallel().tween_property(drip, "modulate:a", 0.0, 0.08)
		await tw.finished
		drip.visible = false
		drip.modulate.a = 1.0


func _slice_badge_global(wheel: Node, index: int) -> Vector2:
	if wheel.has_method("hp_global"):
		return wheel.hp_global(index) + Vector2(22, -12)
	return Vector2.ZERO


func _load_frames(paths: Array) -> Array:
	var out: Array = []
	for p in paths:
		if ResourceLoader.exists(str(p)):
			out.append(load(str(p)) as Texture2D)
		else:
			out.append(null)
	return out
