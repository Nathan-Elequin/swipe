extends ColorRect
## Walk home, click the door, look at shelves. Collection only — no spend.

signal closed
signal inspect_wanted(card_id: String)

const SAVE_PATH := "user://home_cabin.json"
const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0

var seen: Dictionary = {}
var swiped: Dictionary = {}
var art
var sfx
var items_by_id: Dictionary = {}
var tex_by_item: Dictionary = {}
var buckets_open: int = 0

var _ext_root: Control
var _int_root: Control
var _ext_bg: TextureRect
var _int_bg: TextureRect
var _door: TextureRect
var _door_hit: Button
var _lantern: AnimatedSprite2D
var _smoke: AnimatedSprite2D
var _cat: TextureRect
var _hero: Sprite2D
var _sack: Sprite2D
var _fire: AnimatedSprite2D
var _rock: AnimatedSprite2D
var _fade: ColorRect
var _shelf_host: Control
var _back: Button
var _window_glow: TextureRect
var _door_glow: TextureRect
var _lantern_glow: TextureRect
var _fire_glow: TextureRect
var _hover_id: String = ""
var _arriving: bool = false
var _door_busy: bool = false
var _glints: Array = []
var _just_mounted: Array = []
var _glows: Array = []
var _cat_state: String = "hold"
var _cat_t: float = 0.0
var _cat_hold: float = 3.0
var _door_glow_open: bool = false
var _beat: String = ""
var _rng := RandomNumberGenerator.new()


func setup(p_art = null, p_sfx = null) -> void:
	art = p_art
	sfx = p_sfx
	visible = false
	set_anchors_preset(PRESET_FULL_RECT)
	color = Color(0, 0, 0, 1)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rng.randomize()
	_load_save()
	_build()


func note_seen(id: String) -> void:
	var sid: String = str(id)
	if sid == "" or sid == "spider_egg":
		return
	if bool(seen.get(sid, false)):
		return
	seen[sid] = true
	_save()


func swipe_ids(ids: Array) -> void:
	var changed := false
	_just_mounted.clear()
	for raw in ids:
		var sid: String = str(raw)
		if sid == "" or sid == "spider_egg":
			continue
		seen[sid] = true
		if not bool(swiped.get(sid, false)):
			swiped[sid] = true
			_just_mounted.append(sid)
			changed = true
	if changed:
		_save()


func open_cabin(p_items: Dictionary, p_tex: Dictionary, p_buckets: int, walk_in: bool) -> void:
	items_by_id = p_items
	tex_by_item = p_tex
	buckets_open = p_buckets
	visible = true
	_arriving = walk_in
	_door_busy = false
	_door_glow_open = false
	if not walk_in:
		_just_mounted.clear()
	_show_exterior()
	_rebuild_shelves()
	if walk_in:
		_beat = "pan"
		var t := get_tree().create_timer(0.02, true, true, true)
		t.timeout.connect(_play_arrive, CONNECT_ONE_SHOT)
	else:
		_beat = "rest"
	if sfx:
		sfx.play("cloth", -12.0)


func close_cabin() -> void:
	visible = false
	closed.emit()


func _home(name: String) -> Texture2D:
	if art == null:
		return null
	if art.has_method("home_tex"):
		return art.home_tex(name)
	return null


func _px(n: float) -> float:
	return n * PX


func _pt(x: float, y: float) -> Vector2:
	return Vector2(x, y) * PX


func _wait(sec: float) -> void:
	await get_tree().create_timer(sec, true, true, true).timeout


func _build() -> void:
	_ext_root = Control.new()
	_ext_root.set_anchors_preset(PRESET_FULL_RECT)
	_ext_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ext_root)
	_ext_bg = _full_bg(_ext_root)
	_window_glow = _overlay(_ext_root, "window_glow", 170, 208)
	_door_glow = _overlay(_ext_root, "door_glow", 216, 201)
	_lantern_glow = _overlay(_ext_root, "lantern_glow", 288, 133)
	_glows = [
		_glow_d(_window_glow, 0.85, 1.0, 2.5, 4.0, 0.04, 0.08, 0.12),
		_glow_d(_door_glow, 0.82, 1.0, 2.5, 4.0, 0.04, 0.08, 0.12),
		_glow_d(_lantern_glow, 0.75, 1.0, 0.8, 1.6, 0.06, 0.07, 0.11),
	]
	_glows[1]["lag"] = _rng.randf_range(0.2, 0.4)
	_glows[1]["follow"] = 0
	_smoke = AnimatedSprite2D.new()
	_smoke.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_smoke.centered = false
	_smoke.position = _pt(290, 0)
	_ext_root.add_child(_smoke)
	_cat = TextureRect.new()
	_cat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cat.stretch_mode = TextureRect.STRETCH_KEEP
	_cat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cat.position = _pt(202, 64)
	_cat.size = Vector2(64, 60)
	_ext_root.add_child(_cat)
	_door = TextureRect.new()
	_door.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_door.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_door.stretch_mode = TextureRect.STRETCH_KEEP
	_door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_door.position = _pt(236, 134)
	_door.size = _pt(52, 66)
	_ext_root.add_child(_door)
	_lantern = AnimatedSprite2D.new()
	_lantern.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lantern.centered = false
	_lantern.position = _pt(297, 139)
	_ext_root.add_child(_lantern)
	_hero = Sprite2D.new()
	_hero.name = "Hero"
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hero.centered = false
	_hero.visible = false
	_hero.z_index = 1
	_ext_root.add_child(_hero)
	_door_hit = Button.new()
	_door_hit.text = ""
	_door_hit.flat = true
	_door_hit.position = _pt(232, 126)
	_door_hit.size = _pt(60, 74)
	_door_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_door_hit.pressed.connect(_on_door)
	_ext_root.add_child(_door_hit)
	_clear_button(_door_hit)

	_int_root = Control.new()
	_int_root.set_anchors_preset(PRESET_FULL_RECT)
	_int_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_int_root.visible = false
	add_child(_int_root)
	_int_bg = _full_bg(_int_root)
	_fire_glow = _overlay(_int_root, "fire_glow", 0, 136)
	_glows.append(_glow_d(_fire_glow, 0.75, 1.0, 0.6, 1.2, 0.06, 0.06, 0.10))
	_fire = AnimatedSprite2D.new()
	_fire.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fire.centered = false
	_fire.position = _pt(76, 164)
	_int_root.add_child(_fire)
	_sack = Sprite2D.new()
	_sack.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sack.centered = false
	_sack.visible = false
	_sack.position = _pt(70, 205)
	_sack.flip_h = true
	_int_root.add_child(_sack)
	_rock = AnimatedSprite2D.new()
	_rock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rock.centered = false
	_rock.position = _pt(10, 205)
	_rock.visible = false
	_int_root.add_child(_rock)
	var hole := Control.new()
	hole.position = _pt(140, 20)
	hole.size = _pt(260, 160)
	hole.clip_contents = true
	hole.mouse_filter = Control.MOUSE_FILTER_STOP
	_int_root.add_child(hole)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hole.add_child(scroll)
	_shelf_host = Control.new()
	_shelf_host.custom_minimum_size = _pt(260, 160)
	scroll.add_child(_shelf_host)
	_back = Button.new()
	_back.text = COPY.text("title.leave", "Leave")
	_back.position = Vector2(24, 24)
	_back.custom_minimum_size = Vector2(160, 48)
	_back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_back.pressed.connect(close_cabin)
	_back.z_index = 5
	_int_root.add_child(_back)

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_preset(PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.visible = false
	add_child(_fade)
	_apply_art()


func _full_bg(host: Control) -> TextureRect:
	var bg := TextureRect.new()
	bg.name = "bg"
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(bg)
	return bg


func _overlay(host: Control, stem: String, x: float, y: float) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.position = _pt(x, y)
	tr.texture = _home(stem)
	if tr.texture:
		tr.size = tr.texture.get_size()
	host.add_child(tr)
	return tr


func _glow_d(node: TextureRect, min_a: float, max_a: float, pmin: float, pmax: float, namp: float, ndmin: float, ndmax: float) -> Dictionary:
	return {
		"node": node,
		"min": min_a,
		"max": max_a,
		"pmin": pmin,
		"pmax": pmax,
		"namp": namp,
		"ndmin": ndmin,
		"ndmax": ndmax,
		"t": _rng.randf() * 10.0,
		"period": _rng.randf_range(pmin, pmax),
		"noise": 0.0,
		"nt": 0.0,
		"nevery": _rng.randf_range(ndmin, ndmax),
		"lag": 0.0,
		"follow": -1,
		"a": (min_a + max_a) * 0.5,
	}


func _clear_button(b: Button) -> void:
	var empty := StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("hover", empty)
	b.add_theme_stylebox_override("pressed", empty)
	b.add_theme_stylebox_override("focus", empty)
	b.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	b.add_theme_color_override("font_hover_color", Color(0, 0, 0, 0))
	b.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 0))


func _apply_art() -> void:
	_ext_bg.texture = _home("cabin_exterior")
	_int_bg.texture = _home("cabin_interior")
	_door.texture = _home("cabin_door_closed")
	_window_glow.texture = _home("window_glow")
	_door_glow.texture = _home("door_glow")
	_lantern_glow.texture = _home("lantern_glow")
	_fire_glow.texture = _home("fire_glow")
	_lantern.sprite_frames = _frames("swing", ["lantern_swing_f0", "lantern_swing_f1", "lantern_swing_f2", "lantern_swing_f1"], 5.0, true)
	_smoke.sprite_frames = _frames("puff", ["smoke_puff_f0", "smoke_puff_f1", "smoke_puff_f2"], 1000.0 / 260.0, true)
	_fire.sprite_frames = _frames("burn", ["fire_f0", "fire_f1", "fire_f2"], 1000.0 / 150.0, true)
	_rock.sprite_frames = _frames("rock", ["hero_rock_f1", "hero_rock_f2", "hero_rock_f3", "hero_rock_f0"], 4.0, true)
	_cat.texture = _home("cat_idle_f0")
	_sack.texture = _home("loot_sack_dropped")


func _frames(anim: String, stems: Array, fps: float, loop: bool) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for stem in stems:
		var tex: Texture2D = _home(str(stem))
		if tex:
			sf.add_frame(anim, tex)
	return sf


func _show_exterior() -> void:
	_ext_root.visible = true
	_int_root.visible = false
	_door_hit.disabled = false
	_door.texture = _home("cabin_door_closed")
	_door_glow_open = false
	_ext_root.position = Vector2.ZERO
	_host_hero(_ext_root)
	_hero.flip_h = false
	_hero.visible = false
	_rock.visible = false
	if _lantern.sprite_frames:
		_lantern.play("swing")
	if _smoke.sprite_frames:
		_smoke.play("puff")
	_cat_state = "hold"
	_cat_t = 0.0
	_cat_hold = _rng.randf_range(2.0, 6.0)


func _host_hero(host: Control) -> void:
	var p: Node = _hero.get_parent()
	if p == host:
		return
	if p:
		p.remove_child(_hero)
	host.add_child(_hero)


func _place_hero(origin: Vector2) -> void:
	var x: float = origin.x
	if _hero.flip_h:
		x += 32.0
	_hero.position = _pt(x, origin.y)


func _play_arrive() -> void:
	if not visible:
		return
	_arriving = true
	_door_busy = true
	_door_hit.disabled = true
	_beat = "pan"
	_host_hero(_ext_root)
	_hero.z_index = 1
	_hero.visible = true
	_hero.flip_h = false
	_hero.texture = _home("hero_walk_loot_f0")
	_place_hero(Vector2(-30, 218))
	_ext_root.position = Vector2(280, 0)
	var pan := create_tween()
	pan.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pan.set_trans(Tween.TRANS_CUBIC)
	pan.set_ease(Tween.EASE_OUT)
	pan.tween_property(_ext_root, "position", Vector2.ZERO, 0.6)
	if sfx:
		sfx.play("whoosh", -14.0, 0.9)
	await pan.finished
	if not visible:
		return
	_beat = "walk"
	await _walk_path()
	if not visible:
		return
	_place_hero(Vector2(242, 175))
	_hero.texture = _home("hero_idle_blink_f0")
	_beat = "door"
	if sfx:
		sfx.play("door_open", -10.0)
	for stem in ["cabin_door_open_f0", "cabin_door_open_f1", "cabin_door_open_f2"]:
		var tex: Texture2D = _home(stem)
		if tex:
			_door.texture = tex
		await _wait(0.08)
	_door_glow_open = true
	_beat = "enter"
	_hero.z_index = 2
	await _walk_hero(Vector2(242, 175), Vector2(248, 148), true, false)
	if not visible:
		return
	_beat = "fade"
	await _fade_to_interior()
	if not visible:
		return
	_host_hero(_int_root)
	_hero.z_index = 1
	_hero.visible = true
	_hero.flip_h = true
	_place_hero(Vector2(388, 205))
	_hero.texture = _home("hero_walk_loot_f0")
	_beat = "int_walk"
	await _walk_hero(Vector2(388, 205), Vector2(70, 205), true, true)
	if not visible:
		return
	_beat = "drop"
	await _play_drop()
	if not visible:
		return
	_sack.visible = true
	_sack.texture = _home("loot_sack_dropped")
	_sack.flip_h = true
	_place_sack(Vector2(70, 205))
	await _wait(0.3)
	_beat = "to_chair"
	await _walk_hero(Vector2(70, 205), Vector2(10, 205), false, true)
	if not visible:
		return
	_hero.flip_h = false
	_place_hero(Vector2(10, 205))
	_beat = "sit"
	await _play_sit()
	if not visible:
		return
	_hero.visible = false
	_rock.visible = true
	if _rock.sprite_frames:
		_rock.play("rock")
	_beat = "rock"
	_arriving = false
	_door_busy = false


func _place_sack(origin: Vector2) -> void:
	var x: float = origin.x
	if _sack.flip_h:
		x += 32.0
	_sack.position = _pt(x, origin.y)


func _walk_path() -> void:
	var p0 := Vector2(-14, 248)
	var p1 := Vector2(70, 250)
	var p2 := Vector2(170, 214)
	var p3 := Vector2(258, 205)
	var dist := 0.0
	var prev := p0
	for i in 33:
		var t: float = float(i) / 32.0
		var pt: Vector2 = _cubic(p0, p1, p2, p3, t)
		if i > 0:
			dist += prev.distance_to(pt)
		prev = pt
	var dur: float = maxf(0.8, dist / 32.0)
	_hero.flip_h = false
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_method(func(t: float) -> void:
		var feet: Vector2 = _cubic(p0, p1, p2, p3, t)
		_place_hero(Vector2(feet.x - 16.0, feet.y - 30.0))
		var fi: int = int(t * dur * 8.0) % 4
		var tex: Texture2D = _home("hero_walk_loot_f%s" % fi)
		if tex:
			_hero.texture = tex
	, 0.0, 1.0, dur)
	await tw.finished
	_place_hero(Vector2(242, 175))


func _walk_hero(from: Vector2, to: Vector2, loot: bool, flipped: bool) -> void:
	_hero.flip_h = flipped
	_place_hero(from)
	var dist: float = from.distance_to(to)
	var dur: float = maxf(0.25, dist / 32.0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_method(func(t: float) -> void:
		_place_hero(from.lerp(to, t))
		var fi: int = int(t * dur * 8.0) % 4
		var stem: String = ("hero_walk_loot_f%s" if loot else "hero_walk_f%s") % fi
		var tex: Texture2D = _home(stem)
		if tex:
			_hero.texture = tex
	, 0.0, 1.0, dur)
	await tw.finished
	_place_hero(to)


func _play_drop() -> void:
	_hero.flip_h = true
	_place_hero(Vector2(70, 205))
	var stems := ["hero_drop_sack_f0", "hero_drop_sack_f1", "hero_drop_sack_f2", "hero_drop_sack_f3"]
	var durs := [0.14, 0.14, 0.22, 0.16]
	for i in stems.size():
		var tex: Texture2D = _home(stems[i])
		if tex:
			_hero.texture = tex
		if i == 2:
			_bump()
		await _wait(durs[i])


func _play_sit() -> void:
	_hero.flip_h = false
	_place_hero(Vector2(10, 205))
	var stems := ["hero_sit_f0", "hero_sit_f1", "hero_sit_f2", "hero_sit_f3", "hero_sit_f4"]
	var durs := [0.15, 0.12, 0.11, 0.20, 0.25]
	for i in stems.size():
		var tex: Texture2D = _home(stems[i])
		if tex:
			_hero.texture = tex
		if i == 3:
			_bump()
		await _wait(durs[i])


func _bump() -> void:
	offset_top = 4.0
	offset_bottom = 4.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(0.07)
	tw.tween_callback(func() -> void:
		offset_top = 0.0
		offset_bottom = 0.0
	)


func _fade_to_interior() -> void:
	_fade.visible = true
	_fade.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 1.0, 0.2)
	await tw.finished
	_ext_root.visible = false
	_int_root.visible = true
	_start_interior_loops()
	_rebuild_shelves()
	tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 0.0, 0.2)
	await tw.finished
	_fade.visible = false


func _start_interior_loops() -> void:
	if _fire.sprite_frames:
		_fire.play("burn")
	if sfx:
		sfx.play("confirm", -12.0)


func _cubic(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * (u * u * u) + b * (3.0 * u * u * t) + c * (3.0 * u * t * t) + d * (t * t * t)


func _on_door() -> void:
	if _int_root.visible or _door_busy or _arriving:
		return
	_door_busy = true
	_door_hit.disabled = true
	if sfx:
		sfx.play("door_open", -10.0)
	for stem in ["cabin_door_open_f0", "cabin_door_open_f1", "cabin_door_open_f2"]:
		var tex: Texture2D = _home(stem)
		if tex:
			_door.texture = tex
		await _wait(0.08)
	_door_glow_open = true
	await _fade_to_interior()
	_hero.visible = false
	_rock.visible = true
	if _rock.sprite_frames:
		_rock.play("rock")
	_beat = "rock"
	_door_busy = false


func _rebuild_shelves() -> void:
	for c in _shelf_host.get_children():
		_shelf_host.remove_child(c)
		c.queue_free()
	_glints.clear()
	var by_bucket: Dictionary = {}
	var max_b: int = 0
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		var b: int = BucketRules.parse(card.get("bucket", 0))
		if b < 0:
			continue
		max_b = maxi(max_b, b)
		if not by_bucket.has(b):
			by_bucket[b] = []
		(by_bucket[b] as Array).append(card)
	var row_i: int = 0
	for b2 in range(0, max_b + 1):
		var cards: Array = by_bucket.get(b2, [])
		cards.sort_custom(func(a, b): return str(a.get("name", "")) < str(b.get("name", "")))
		if b2 > buckets_open:
			_add_locked_row(row_i)
			row_i += 1
		elif cards.is_empty():
			_add_open_row(row_i, [])
			row_i += 1
		else:
			var i: int = 0
			while i < cards.size():
				_add_open_row(row_i, cards.slice(i, mini(i + 8, cards.size())))
				row_i += 1
				i += 8
	_shelf_host.custom_minimum_size = Vector2(_px(260), maxf(_px(160), float(row_i) * _px(40)))


func _row_y(row_i: int) -> float:
	return float(row_i) * _px(40)


func _add_locked_row(row_i: int) -> void:
	var y: float = _row_y(row_i)
	for i in 2:
		var lock := TextureRect.new()
		lock.texture = _home("shelf_locked")
		lock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_KEEP
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock.position = Vector2(_px(2) + float(i) * _px(128), y)
		lock.size = _pt(128, 40)
		_shelf_host.add_child(lock)


func _add_open_row(row_i: int, cards: Array) -> void:
	var y: float = _row_y(row_i)
	var x0: float = _px(2)
	for i in 8:
		var card: Dictionary = cards[i] if i < cards.size() else {}
		_shelf_host.add_child(_mount_slot(card, Vector2(x0 + float(i) * _px(32), y)))


func _mount_slot(card: Dictionary, pos: Vector2) -> Control:
	var wrap := Control.new()
	wrap.position = pos
	wrap.size = _pt(32, 40)
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	var mount := TextureRect.new()
	mount.name = "mount"
	mount.texture = _home("trophy_mount")
	mount.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mount.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mount.stretch_mode = TextureRect.STRETCH_KEEP
	mount.set_anchors_preset(PRESET_FULL_RECT)
	mount.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(mount)
	if card.is_empty():
		return wrap
	var id: String = str(card.get("id", ""))
	var is_swiped: bool = bool(swiped.get(id, false))
	var is_seen: bool = bool(seen.get(id, false)) or is_swiped
	var fresh: bool = _just_mounted.has(id)
	var item := TextureRect.new()
	item.position = _pt(8, 8)
	item.size = _pt(16, 16)
	item.pivot_offset = _pt(8, 8)
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = tex_by_item.get(id, null)
	if tex == null and art != null:
		tex = art.item_tex(id)
	item.texture = tex
	if is_swiped:
		item.modulate = Color.WHITE
	elif is_seen:
		item.modulate = Color("8a8a8a")
	else:
		item.modulate = Color(0.18, 0.16, 0.14, 0.35)
	wrap.add_child(item)
	if fresh and is_swiped:
		item.scale = Vector2.ZERO
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(item, "scale", Vector2(1.15, 1.15), 0.12)
		tw.tween_property(item, "scale", Vector2.ONE, 0.13)
		_play_burst(wrap)
	if is_seen and not is_swiped:
		var overlay := TextureRect.new()
		overlay.texture = _home("item_seen_overlay")
		overlay.position = _pt(8, 8)
		overlay.size = _pt(16, 16)
		overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		overlay.stretch_mode = TextureRect.STRETCH_KEEP
		overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(overlay)
	if is_seen:
		var lab := Label.new()
		lab.text = str(card.get("name", id))
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.position = Vector2(_px(1), _px(32))
		lab.size = Vector2(_px(30), _px(8))
		lab.add_theme_font_size_override("font_size", 8)
		lab.add_theme_color_override("font_color", Color("24150e") if is_swiped else Color("3a3228"))
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.clip_text = true
		wrap.add_child(lab)
		wrap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var glint := AnimatedSprite2D.new()
		glint.centered = false
		glint.position = _pt(8, 32)
		glint.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glint.material = mat
		glint.sprite_frames = _frames("glint", ["plaque_glint_f0", "plaque_glint_f1", "plaque_glint_f2", "plaque_glint_f3"], 4.0 / 1.2, true)
		wrap.add_child(glint)
		if is_swiped:
			glint.play("glint")
		else:
			glint.visible = false
		_glints.append({"id": id, "node": glint})
		wrap.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				inspect_wanted.emit(id)
		)
		wrap.mouse_entered.connect(func() -> void:
			_hover_id = id
			var hover_tex: Texture2D = _home("trophy_mount_hover")
			if hover_tex:
				mount.texture = hover_tex
			_set_glint(id, true)
		)
		wrap.mouse_exited.connect(func() -> void:
			if _hover_id == id:
				_hover_id = ""
			mount.texture = _home("trophy_mount")
			_set_glint(id, false)
		)
	return wrap


func _play_burst(wrap: Control) -> void:
	var burst := AnimatedSprite2D.new()
	burst.centered = false
	burst.position = _pt(-8, -4)
	burst.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	burst.material = mat
	var sf := SpriteFrames.new()
	sf.add_animation("burst")
	sf.set_animation_speed("burst", 1.0)
	sf.set_animation_loop("burst", false)
	var stems := [
		"trophy_place_burst_f0", "trophy_place_burst_f1", "trophy_place_burst_f2",
		"trophy_place_burst_f3", "trophy_place_burst_f4",
	]
	var durs := [0.06, 0.07, 0.08, 0.09, 0.10]
	for i in stems.size():
		var tex: Texture2D = _home(stems[i])
		if tex:
			sf.add_frame("burst", tex, durs[i])
	burst.sprite_frames = sf
	wrap.add_child(burst)
	burst.play("burst")
	burst.animation_finished.connect(func() -> void:
		burst.queue_free()
	)


func _set_glint(id: String, hovered: bool) -> void:
	for g in _glints:
		if str(g.get("id", "")) != id:
			continue
		var node: AnimatedSprite2D = g.get("node")
		if node == null or node.sprite_frames == null:
			continue
		node.visible = true
		if hovered:
			node.sprite_frames.set_animation_speed("glint", 4.0 / 0.4)
			node.play("glint")
		else:
			node.sprite_frames.set_animation_speed("glint", 4.0 / 1.2)
			if bool(swiped.get(id, false)):
				node.play("glint")
			else:
				node.stop()
				node.visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_tick_glows(delta)
	if _ext_root.visible:
		_tick_cat(delta)


func _tick_glows(delta: float) -> void:
	var window_a: float = 1.0
	for i in _glows.size():
		var g: Dictionary = _glows[i]
		var node: TextureRect = g.get("node")
		if node == null or not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		g["t"] = float(g["t"]) + delta
		g["nt"] = float(g["nt"]) + delta
		if float(g["nt"]) >= float(g["nevery"]):
			g["nt"] = 0.0
			g["nevery"] = _rng.randf_range(float(g["ndmin"]), float(g["ndmax"]))
			g["noise"] = _rng.randf_range(-float(g["namp"]), float(g["namp"]))
		var period: float = float(g["period"])
		if period < 0.2:
			period = 1.0
		if float(g["t"]) >= period:
			g["t"] -= period
			g["period"] = _rng.randf_range(float(g["pmin"]), float(g["pmax"]))
		var t: float = float(g["t"])
		var follow_i: int = int(g.get("follow", -1))
		if follow_i >= 0 and follow_i < _glows.size():
			t = float(_glows[follow_i]["t"]) - float(g.get("lag", 0.0))
		var wave: float = 0.5 + 0.5 * sin(t / period * TAU)
		var a: float = lerpf(float(g["min"]), float(g["max"]), wave) + float(g["noise"])
		if node == _door_glow and _door_glow_open:
			a = 1.0
		if node == _fire_glow and _fire and _fire.is_playing() and _fire.frame == 1:
			a += 0.05
		a = clampf(a, float(g["min"]), 1.0)
		g["a"] = lerpf(float(g["a"]), a, clampf(delta * 12.0, 0.0, 1.0))
		node.modulate.a = float(g["a"])
		_glows[i] = g


func _tick_cat(delta: float) -> void:
	_cat_t += delta
	match _cat_state:
		"hold":
			_cat.texture = _home("cat_idle_f0")
			if _cat_t >= _cat_hold:
				_cat_t = 0.0
				if _rng.randf() < 0.7:
					_cat_state = "blink"
				else:
					_cat_state = "flick"
		"blink":
			_cat.texture = _home("cat_idle_f1")
			if _cat_t >= 0.13:
				_cat_state = "hold"
				_cat_t = 0.0
				_cat_hold = _rng.randf_range(2.0, 6.0)
		"flick":
			var step: int = int(_cat_t / 0.16)
			if step <= 0:
				_cat.texture = _home("cat_idle_f2")
			elif step == 1:
				_cat.texture = _home("cat_idle_f3")
			elif step == 2:
				_cat.texture = _home("cat_idle_f2")
			else:
				_cat_state = "hold"
				_cat_t = 0.0
				_cat_hold = _rng.randf_range(2.0, 6.0)


func _load_save() -> void:
	seen.clear()
	swiped.clear()
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for id in parsed.get("seen", []):
		seen[str(id)] = true
	for id2 in parsed.get("swiped", []):
		swiped[str(id2)] = true
		seen[str(id2)] = true


func _save() -> void:
	var data := {"seen": seen.keys(), "swiped": swiped.keys()}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data, "\t"))


func _mcp_state() -> Dictionary:
	var hero_tex := ""
	if _hero and _hero.texture:
		hero_tex = String(_hero.texture.resource_path).get_file()
	var door_tex := ""
	if _door and _door.texture:
		door_tex = String(_door.texture.resource_path).get_file()
	return {
		"beat": _beat,
		"cabin_on": visible,
		"ext": _ext_root.visible if _ext_root else false,
		"intv": _int_root.visible if _int_root else false,
		"arriving": _arriving,
		"hero_vis": _hero.visible if _hero else false,
		"hero_flip": _hero.flip_h if _hero else false,
		"hero_tex": hero_tex,
		"door_tex": door_tex,
		"lantern_on": _lantern.is_playing() if _lantern else false,
		"smoke_on": _smoke.is_playing() if _smoke else false,
		"fire_on": _fire.is_playing() if _fire else false,
		"rock_on": _rock.is_playing() if _rock else false,
		"rock_vis": _rock.visible if _rock else false,
		"sack_vis": _sack.visible if _sack else false,
		"just_n": _just_mounted.size(),
		"swiped_n": swiped.size(),
		"buckets": buckets_open,
	}


func debug_seed(owned: int, seen_only: int, buckets: int) -> void:
	swiped.clear()
	seen.clear()
	_just_mounted.clear()
	var ids: Array = items_by_id.keys()
	ids.sort()
	var n: int = 0
	for id in ids:
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		if n < owned:
			swiped[str(id)] = true
			seen[str(id)] = true
			if n < 3:
				_just_mounted.append(str(id))
		elif n < owned + seen_only:
			seen[str(id)] = true
		n += 1
	buckets_open = buckets
	_rebuild_shelves()


func debug_pose(beat: String) -> void:
	_arriving = false
	_door_busy = false
	_beat = beat
	match beat:
		"walk":
			_show_exterior()
			_hero.visible = true
			_hero.flip_h = false
			_place_hero(Vector2(140, 188))
			_hero.texture = _home("hero_walk_loot_f1")
		"door":
			_show_exterior()
			_hero.visible = true
			_hero.flip_h = false
			_place_hero(Vector2(242, 175))
			_hero.texture = _home("hero_idle_blink_f0")
			_door.texture = _home("cabin_door_open_f1")
			_door_glow_open = true
		"drop":
			_ext_root.visible = false
			_int_root.visible = true
			_start_interior_loops()
			_host_hero(_int_root)
			_hero.visible = true
			_hero.flip_h = true
			_place_hero(Vector2(70, 205))
			_hero.texture = _home("hero_drop_sack_f2")
			_sack.visible = false
			_rock.visible = false
			_bump()
		"sit":
			_ext_root.visible = false
			_int_root.visible = true
			_start_interior_loops()
			_host_hero(_int_root)
			_hero.visible = true
			_hero.flip_h = false
			_place_hero(Vector2(10, 205))
			_hero.texture = _home("hero_sit_f3")
			_sack.visible = true
			_sack.flip_h = true
			_place_sack(Vector2(70, 205))
			_rock.visible = false
			_bump()
		"rock":
			_ext_root.visible = false
			_int_root.visible = true
			_start_interior_loops()
			_hero.visible = false
			_sack.visible = true
			_sack.flip_h = true
			_place_sack(Vector2(70, 205))
			_rock.visible = true
			if _rock.sprite_frames:
				_rock.play("rock")
		"rest":
			_show_exterior()
		"interior":
			_ext_root.visible = false
			_int_root.visible = true
			_start_interior_loops()
			_hero.visible = false
			_rock.visible = true
			if _rock.sprite_frames:
				_rock.play("rock")
		_:
			pass


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _arriving:
			get_viewport().set_input_as_handled()
			return
		if _int_root.visible:
			if _fire:
				_fire.stop()
			if _rock:
				_rock.stop()
			_show_exterior()
		else:
			close_cabin()
		get_viewport().set_input_as_handled()
