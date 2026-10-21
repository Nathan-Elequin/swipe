extends Control
## One claw badge: raw hit number, lit/burst/blocked/flame, optional chip.

const PLAYER_COPY := preload("res://scripts/player_copy.gd")

const SIZE_ON := Vector2(64, 64)
const ANIM := "res://assets/ui/anim/"
const FRAME_MS := 0.040
const BLUE := Color("6ec8e8")
const INK := Color("f0e6d8")
const OUTLINE := Color("100e0c")
const SPENT_A := 0.55

var n_raw: int = 0
var soaked: bool = false
var pierce: bool = false
var poison: bool = false
var overflow: bool = false
var spent: bool = false
var is_next: bool = false
var chip_kind: String = ""
var neighbour_tex: Texture2D

var _face: AnimatedSprite2D
var _burst: AnimatedSprite2D
var _num: Label
var _chip: TextureRect
var _pulse_tw: Tween
var _flash_tw: Tween
var _dissolve_tw: Tween


func _ready() -> void:
	custom_minimum_size = SIZE_ON
	size = SIZE_ON
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	pivot_offset = SIZE_ON * 0.5
	_face = AnimatedSprite2D.new()
	_face.name = "Face"
	_face.centered = true
	_face.position = SIZE_ON * 0.5
	_face.scale = Vector2(4, 4)
	_face.texture_filter = TEXTURE_FILTER_NEAREST
	_face.sprite_frames = _build_frames()
	add_child(_face)
	_burst = AnimatedSprite2D.new()
	_burst.name = "Burst"
	_burst.centered = true
	_burst.position = SIZE_ON * 0.5
	_burst.scale = Vector2(4, 4)
	_burst.texture_filter = TEXTURE_FILTER_NEAREST
	_burst.sprite_frames = _face.sprite_frames
	_burst.visible = false
	_burst.z_index = 1
	add_child(_burst)
	_num = Label.new()
	_num.name = "Num"
	_num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_num.add_theme_color_override("font_color", INK)
	_num.add_theme_color_override("font_outline_color", OUTLINE)
	_num.add_theme_constant_override("outline_size", 3)
	add_child(_num)
	_chip = TextureRect.new()
	_chip.name = "Chip"
	_chip.custom_minimum_size = Vector2(32, 32)
	_chip.size = Vector2(32, 32)
	_chip.position = Vector2(SIZE_ON.x - 28, SIZE_ON.y - 28)
	_chip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chip.texture_filter = TEXTURE_FILTER_NEAREST
	_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chip.visible = false
	add_child(_chip)
	_show_idle()
	_apply_num()
	_apply_chip()
	set_process(false)


func setup(hit: Dictionary) -> void:
	n_raw = int(hit.get("n_raw", 0))
	soaked = bool(hit.get("soaked", false))
	pierce = bool(hit.get("pierce", false))
	poison = bool(hit.get("poison", false))
	overflow = bool(hit.get("overflow", false))
	chip_kind = str(hit.get("chip", ""))
	neighbour_tex = hit.get("neighbour_tex", null)
	spent = false
	is_next = false
	if is_inside_tree():
		_show_idle()
		_apply_num()
		_apply_chip()
		modulate = Color.WHITE
		scale = Vector2.ONE


func set_number(n: int) -> void:
	if n == n_raw:
		return
	var old: String = _num.text if _num else str(n_raw)
	n_raw = n
	_apply_num()
	if _num == null:
		return
	if _dissolve_tw != null and is_instance_valid(_dissolve_tw):
		_dissolve_tw.kill()
	_num.modulate.a = 0.0
	_num.text = old
	_dissolve_tw = create_tween()
	_dissolve_tw.tween_property(_num, "modulate:a", 0.0, 0.10)
	_dissolve_tw.tween_callback(func() -> void:
		_apply_num()
		_num.modulate.a = 0.0
	)
	_dissolve_tw.tween_property(_num, "modulate:a", 1.0, 0.10)


func set_next(on: bool) -> void:
	is_next = on and not spent
	set_process(is_next)
	if not is_next:
		scale = Vector2.ONE
		if _pulse_tw != null and is_instance_valid(_pulse_tw):
			_pulse_tw.kill()
			_pulse_tw = null
		return
	if _pulse_tw != null and is_instance_valid(_pulse_tw):
		_pulse_tw.kill()
	_pulse_tw = create_tween().set_loops()
	_pulse_tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.25).set_trans(Tween.TRANS_SINE)
	_pulse_tw.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_SINE)


func fire(blocked: bool, pierce_hit: bool) -> void:
	set_next(false)
	spent = true
	var full_soak: bool = blocked and soaked
	if blocked or soaked:
		await _flash_blue()
		_show_chip("shield")
		if full_soak and int(n_raw) > 0 and not pierce_hit:
			_mark_spent()
			return
	if pierce_hit:
		pierce = true
	await _play_lit_burst(pierce_hit)
	_mark_spent()


func pop_in(delay: float = 0.0) -> void:
	scale = Vector2.ZERO
	modulate.a = 1.0
	var tw := create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(self, "scale", Vector2(1.15, 1.15), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.06)


func shrink_out() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ZERO, 0.12)
	await tw.finished
	queue_free()


func _mark_spent() -> void:
	spent = true
	modulate = Color(0.55, 0.55, 0.55, SPENT_A)
	_show_idle()
	if _burst:
		_burst.visible = false


func _flash_blue() -> void:
	if _flash_tw != null and is_instance_valid(_flash_tw):
		_flash_tw.kill()
	var was: Color = modulate
	_flash_tw = create_tween()
	_flash_tw.tween_property(self, "modulate", BLUE, 0.06)
	_flash_tw.tween_interval(0.06)
	_flash_tw.tween_property(self, "modulate", was, 0.06)
	await _flash_tw.finished


func _play_lit_burst(flame: bool) -> void:
	if _face == null:
		return
	var lit_anim := "flame_lit" if flame else "lit"
	var burst_anim := "flame_burst" if flame else "burst"
	if _face.sprite_frames.has_animation(lit_anim):
		_face.play(lit_anim)
		await get_tree().create_timer(FRAME_MS * 4.0).timeout
	if _burst and _burst.sprite_frames.has_animation(burst_anim):
		_burst.visible = true
		_burst.play(burst_anim)
		await get_tree().create_timer(FRAME_MS * 4.0).timeout
		_burst.visible = false


func _show_idle() -> void:
	if _face == null:
		return
	var anim := "flame_idle" if pierce else "idle"
	if _face.sprite_frames.has_animation(anim):
		_face.animation = anim
		_face.frame = 0
		_face.pause()


func _apply_num() -> void:
	if _num == null:
		return
	if overflow:
		_num.text = PLAYER_COPY.fill("combat.intent_overflow", {"n": n_raw}, "×%s" % n_raw)
	else:
		_num.text = str(n_raw)
	var digits: int = _num.text.length()
	_num.add_theme_font_size_override("font_size", 24 if digits >= 2 else 30)


func _apply_chip() -> void:
	if poison:
		_show_chip("drop")
	elif chip_kind != "":
		_show_chip(chip_kind)
	elif neighbour_tex != null:
		_chip.texture = neighbour_tex
		_chip.visible = true
	else:
		_chip.visible = false


func _show_chip(kind: String) -> void:
	var path := ""
	match kind:
		"shield":
			path = ANIM + "intent_chip_shield.png"
		"drop":
			path = ANIM + "intent_chip_drop.png"
		"flee":
			path = ANIM + "intent_chip_flee.png"
	if path != "" and ResourceLoader.exists(path):
		_chip.texture = load(path)
		_chip.visible = true


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_still(sf, "idle", ANIM + "intent_claw_idle.png")
	_add_still(sf, "flame_idle", ANIM + "intent_claw_flame_idle.png")
	_add_seq(sf, "lit", ANIM + "intent_claw_lit_f%d.png", 4)
	_add_seq(sf, "burst", ANIM + "intent_claw_burst_f%d.png", 4)
	_add_seq(sf, "flame_burst", ANIM + "intent_claw_flame_burst_f%d.png", 4)
	# flame lit reuses lit frames tinted via modulate at play time if needed
	_add_seq(sf, "flame_lit", ANIM + "intent_claw_lit_f%d.png", 4)
	return sf


func _add_still(sf: SpriteFrames, anim: String, path: String) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, 1.0)
	sf.set_animation_loop(anim, false)
	var t := _tex(path)
	if t:
		sf.add_frame(anim, t)


func _add_seq(sf: SpriteFrames, anim: String, pattern: String, n: int) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, 1.0 / FRAME_MS)
	sf.set_animation_loop(anim, false)
	for i in range(n):
		var t := _tex(pattern % i)
		if t:
			sf.add_frame(anim, t)
