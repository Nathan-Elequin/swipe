extends ColorRect
## Walk home, click the door, look at shelves. Collection only — no spend.

signal closed
signal inspect_wanted(card_id: String)

const SAVE_PATH := "user://home_cabin.json"
const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0
const VIEW := Vector2(1680, 1040)

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
var _hero: Sprite2D
var _fire: AnimatedSprite2D
var _rock: AnimatedSprite2D
var _fade: ColorRect
var _shelf_host: Control
var _back: Button
var _hover_id: String = ""
var _arriving: bool = false
var _door_busy: bool = false
var _glints: Array = []


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
	for raw in ids:
		var sid: String = str(raw)
		if sid == "" or sid == "spider_egg":
			continue
		seen[sid] = true
		if not bool(swiped.get(sid, false)):
			swiped[sid] = true
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
	_show_exterior()
	_rebuild_shelves()
	if walk_in:
		_play_arrive()
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


func _build() -> void:
	_ext_root = Control.new()
	_ext_root.set_anchors_preset(PRESET_FULL_RECT)
	_ext_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ext_root)
	_ext_bg = _full_bg(_ext_root)
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
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hero.centered = false
	_hero.visible = false
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
	_fire = AnimatedSprite2D.new()
	_fire.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fire.centered = false
	_fire.position = _pt(76, 164)
	_int_root.add_child(_fire)
	_rock = AnimatedSprite2D.new()
	_rock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rock.centered = false
	_rock.position = _pt(10, 205)
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
	_lantern.sprite_frames = _frames("swing", ["lantern_swing_f0", "lantern_swing_f1", "lantern_swing_f2", "lantern_swing_f1"], 5.0, true)
	_fire.sprite_frames = _frames("burn", ["fire_f0", "fire_f1", "fire_f2"], 1000.0 / 150.0, true)
	_rock.sprite_frames = _frames("rock", ["hero_rock_f0", "hero_rock_f1", "hero_rock_f2", "hero_rock_f3"], 4.0, true)


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
	_ext_root.position = Vector2.ZERO
	_ext_root.modulate = Color.WHITE
	if _lantern.sprite_frames and _lantern.sprite_frames.has_animation("swing"):
		_lantern.play("swing")
	_hero.visible = false
	_arriving = false


func _play_arrive() -> void:
	_arriving = true
	_hero.visible = true
	_hero.texture = _home("hero_walk_loot_f0")
	_ext_root.position = Vector2(280, 0)
	var pan := create_tween()
	pan.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pan.set_trans(Tween.TRANS_CUBIC)
	pan.set_ease(Tween.EASE_OUT)
	pan.tween_property(_ext_root, "position", Vector2.ZERO, 0.6)
	pan.finished.connect(_walk_in)
	if sfx:
		sfx.play("whoosh", -14.0, 0.9)


func _walk_in() -> void:
	if not visible or not _ext_root.visible:
		return
	var p0 := Vector2(-14, 248)
	var p1 := Vector2(70, 250)
	var p2 := Vector2(170, 214)
	var p3 := Vector2(262, 204)
	var samples: Array[Vector2] = []
	var dist := 0.0
	var prev := p0
	for i in 33:
		var t: float = float(i) / 32.0
		var pt: Vector2 = _cubic(p0, p1, p2, p3, t)
		if i > 0:
			dist += prev.distance_to(pt)
		samples.append(pt)
		prev = pt
	var dur: float = maxf(0.8, dist / 32.0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_LINEAR)
	var walk_i := {"n": 0}
	tw.tween_method(func(t: float) -> void:
		var pt: Vector2 = _cubic(p0, p1, p2, p3, t)
		_hero.position = _pt(pt.x - 16.0, pt.y - 30.0)
		walk_i["n"] = int(t * dur * 8.0)
		var fi: int = int(walk_i["n"]) % 4
		var loot: Texture2D = _home("hero_walk_loot_f%s" % fi)
		_hero.texture = loot if loot else _home("hero_walk_f%s" % fi)
	, 0.0, 1.0, dur)
	tw.finished.connect(func() -> void:
		_arriving = false
		_hero.position = _pt(262.0 - 16.0, 204.0 - 30.0)
		var idle: Texture2D = _home("hero_idle_blink_f0")
		_hero.texture = idle if idle else _home("hero_walk_loot_f0")
	)


func _cubic(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * (u * u * u) + b * (3.0 * u * u * t) + c * (3.0 * u * t * t) + d * (t * t * t)


func _on_door() -> void:
	if _int_root.visible or _door_busy:
		return
	_door_busy = true
	_door_hit.disabled = true
	if sfx:
		sfx.play("door_open", -10.0)
	for stem in ["cabin_door_open_f0", "cabin_door_open_f1", "cabin_door_open_f2"]:
		var tex: Texture2D = _home(stem)
		if tex:
			_door.texture = tex
		await get_tree().create_timer(0.08, true, false, true).timeout
	_fade.visible = true
	_fade.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 1.0, 0.2)
	await tw.finished
	_ext_root.visible = false
	_int_root.visible = true
	_rebuild_shelves()
	if _fire.sprite_frames and _fire.sprite_frames.has_animation("burn"):
		_fire.play("burn")
	if _rock.sprite_frames and _rock.sprite_frames.has_animation("rock"):
		_rock.play("rock")
	tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 0.0, 0.2)
	await tw.finished
	_fade.visible = false
	_door_busy = false
	_door_hit.disabled = false
	if sfx:
		sfx.play("confirm", -12.0)


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
		else:
			if cards.is_empty():
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
	var item := TextureRect.new()
	item.position = _pt(8, 8)
	item.size = _pt(16, 16)
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
		lab.add_theme_font_size_override("font_size", 9)
		lab.add_theme_color_override("font_color", Color("e8c36a") if is_swiped else Color("9a8b78"))
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
		_glints.append({"id": id, "node": glint, "hover": false})
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


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if _int_root.visible:
			if _fire:
				_fire.stop()
			if _rock:
				_rock.stop()
			_show_exterior()
		else:
			close_cabin()
		get_viewport().set_input_as_handled()
