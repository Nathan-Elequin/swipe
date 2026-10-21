extends Control
## Boot teaser: chase, spend-to-keep, whiteout, title still, click to continue.

signal finished

const COPY := preload("res://scripts/player_copy.gd")
const DUNGEON_BG := preload("res://scripts/dungeon_bg.gd")

const STILL_PATH := "res://assets/dungeon/title/title_still.png"
const HILL_PATH := "res://assets/dungeon/title/hill_strip.png"
const HALL_PATH := "res://assets/dungeon/title/hall_strip.png"
const HALL_B_PATH := "res://assets/dungeon/title/hall_strip_b.png"
const LOGO_PATH := "res://assets/dungeon/title/logo.png"
const TITLE_DIR := "res://assets/dungeon/title"

const T_THRESHOLD := 2.0
const T_GRAB := 5.0
const T_SPEND := 8.5
const T_SWIRL := 11.0
const T_WHITE_PEAK := 12.2
const T_STILL := 13.0

const ITEM_CATCH := ["pocketwatch", "lantern", "grimoire", "healing_potion"]
const ITEM_MISS := ["lucky_nickel", "sledgehammer"]
const ITEM_SPEND := ["da_boot", "helmet"]
const MONSTER_IDS := ["goblin", "dire_wolf", "skeleton", "ogre", "hornet_swarm", "spider_queen", "dragon"]

var art
var sfx
var skippable: bool = false
var music_dip: bool = false
var holding_still: bool = false
var _yielded: bool = false

var _t: float = 0.0
var _arm: float = 0.5
var _white: float = 0.0
var _still_a: float = 0.0
var _hero_anim: String = "walkoff"
var _hero_fi: float = 0.0
var _hero_once: bool = false
var _spent: bool = false
var _hall
var _items: Array = []
var _mons: Array = []
var _walk: Array = []
var _swipe: Array = []
var _block: Array = []
var _grab: Array = []
var _still: Texture2D
var _hill: Texture2D
var _hall_strip: Texture2D
var _hall_strip_b: Texture2D
var _logo: Texture2D
var _nib_lantern: Array = []
var _sprout_teaser: bool = false
var _nib: Texture2D
var _cabin: Texture2D
var _door: Texture2D
var _title
var _tag
var _click
var _music_lab


static func still_ready() -> bool:
	return ResourceLoader.exists(STILL_PATH)


func setup(p_art, p_sfx) -> void:
	art = p_art
	sfx = p_sfx
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 128
	visible = false
	name = "title_teaser"
	texture_filter = TEXTURE_FILTER_NEAREST
	gui_input.connect(_on_gui)
	set_process(true)
	set_process_input(true)
	_hall = DUNGEON_BG.new()
	add_child(_hall)
	_hall.setup(art)
	_hall.z_index = 0
	_hall.show_behind_parent = true
	_hall.process_mode = Node.PROCESS_MODE_ALWAYS
	_hall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_labels()
	_set_title_visible(false)


func open_teaser(can_skip: bool) -> void:
	skippable = can_skip
	music_dip = false
	holding_still = false
	_yielded = false
	_t = 0.0
	_arm = 0.5
	_white = 0.0
	_still_a = 0.0
	_hero_anim = "walkoff"
	_hero_fi = 0.0
	_hero_once = false
	_spent = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 128
	_load_art()
	_spawn_actors()
	if _hall:
		_hall.reset_hall()
		_hall.visible = true
	_set_title_visible(false)
	visible = true
	move_to_front()
	if sfx and sfx.has_method("set_combat_music"):
		sfx.set_combat_music(true)


func close_teaser() -> void:
	visible = false
	holding_still = false
	_yielded = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 128
	if _hall:
		_hall.visible = false


func yield_to_hub() -> void:
	_yielded = true
	_set_title_visible(false)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 120
	if _hall:
		_hall.visible = false


func _build_labels() -> void:
	var col := VBoxContainer.new()
	col.set_anchors_preset(PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.z_index = 4
	add_child(col)
	_title = _plain(COPY.text("title.overlay", "Swipe"), 72, Color("e8c36a"), 88)
	_tag = _plain(COPY.text("title.sub", "Use it, Lose it, or Lose your head"), 28, Color("f4ede3"), 48)
	_click = _plain(COPY.text("intro.next", "Click to continue"), 22, Color("c9b9a8"), 36)
	_music_lab = _plain("", 14, Color("c9b9a8"), 28)
	col.add_child(_title)
	col.add_child(_tag)
	col.add_child(_click)
	col.add_child(_music_lab)


func _plain(text: String, size_px: int, col: Color, height: int):
	var lab = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = size_px
	lab.min_font_size = 13
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(980, height)
	lab.font_color = col
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.set_plain(text)
	return lab


func _load_art() -> void:
	_walk = _seq("sprout_run")
	_sprout_teaser = not _walk.is_empty()
	if _walk.is_empty():
		_walk = _frames("walkoff")
	_swipe = _seq("sprout_throw")
	if _swipe.is_empty():
		_swipe = _frames("swipe")
	_block = _frames("block")
	_grab = _seq("sprout_grab")
	if _grab.is_empty():
		_grab = _frames("grab")
	_still = _opt(STILL_PATH)
	_hill = _opt(HILL_PATH)
	_hall_strip = _opt(HALL_PATH)
	_hall_strip_b = _opt(HALL_B_PATH)
	_logo = _opt(LOGO_PATH)
	_nib_lantern = _seq("nib_lantern")
	if art != null:
		if art.has_method("home_tex"):
			_nib = art.home_tex("nib/nib_idle_f0")
			_cabin = art.home_tex("rooms/room_main")
			_door = art.home_tex("doors/run_door_open_f0")
		if (_nib == null or not is_instance_valid(_nib)) and art.has_method("nib_frames"):
			var nf: Array = art.nib_frames()
			if not nf.is_empty():
				_nib = nf[0]
	if not _nib_lantern.is_empty():
		_nib = _nib_lantern[0]


func _frames(anim: String) -> Array:
	if art != null and art.has_method("hero_run_anim"):
		return art.hero_run_anim(anim)
	return []


func _seq(stem: String) -> Array:
	var out: Array = []
	for i in 8:
		var t: Texture2D = _opt("%s/%s_f%d.png" % [TITLE_DIR, stem, i])
		if t == null:
			break
		out.append(t)
	return out


func _opt(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _item_tex(id: String) -> Texture2D:
	var teaser: Texture2D = _opt("%s/item_%s_f0.png" % [TITLE_DIR, id])
	if teaser != null:
		return teaser
	if art != null and art.has_method("item_tex"):
		return art.item_tex(id)
	return null


func _mon_tex(id: String) -> Texture2D:
	var teaser: Texture2D = _opt("%s/mon_%s_f0.png" % [TITLE_DIR, id])
	if teaser != null:
		return teaser
	if art != null and art.has_method("monster_still"):
		return art.monster_still(id)
	return null


func _spawn_actors() -> void:
	_items.clear()
	_mons.clear()
	var i := 0
	for id in ITEM_CATCH:
		_items.append(_item_actor(str(id), "catch", 2.1 + float(i) * 0.45))
		i += 1
	for id2 in ITEM_MISS:
		_items.append(_item_actor(str(id2), "miss", 2.4 + float(i) * 0.4))
		i += 1
	for id3 in ITEM_SPEND:
		_items.append(_item_actor(str(id3), "spend", 2.0 + float(i) * 0.35))
		i += 1
	for m in range(MONSTER_IDS.size()):
		var mid: String = str(MONSTER_IDS[m])
		_mons.append({
			"id": mid,
			"tex": _mon_tex(mid),
			"big": _opt("%s/mon_%s_f0.png" % [TITLE_DIR, mid]) != null,
			"born": 1.6 + float(m) * 0.55,
			"lane": 0.12 + 0.04 * float(m % 3),
			"hit": false,
		})


func _item_actor(id: String, kind: String, born: float) -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"tex": _item_tex(id),
		"big": _opt("%s/item_%s_f0.png" % [TITLE_DIR, id]) != null,
		"born": born,
		"held": false,
		"gone": false,
		"toss": 0.0,
	}


func _process(delta: float) -> void:
	if not visible:
		return
	if _arm > 0.0:
		_arm -= delta
	if not holding_still:
		_t += delta
		_step_hero(delta)
		_step_world()
		_step_fade()
		if _t >= T_STILL:
			_land_still()
	else:
		if _click:
			var pulse: float = 0.72 + 0.28 * absf(sin(Time.get_ticks_msec() * 0.005))
			_click.modulate.a = pulse
	queue_redraw()


func _step_hero(delta: float) -> void:
	var frames: Array = _walk
	var fps := 14.0
	if _hero_anim == "swipe":
		frames = _swipe
		fps = 12.0
	elif _hero_anim == "block":
		frames = _block
		fps = 10.0
	elif _hero_anim == "grab":
		frames = _grab
		fps = 10.0
	if frames.is_empty():
		return
	_hero_fi += delta * fps
	if _hero_anim != "walkoff":
		if _hero_fi >= float(frames.size()):
			_hero_anim = "walkoff"
			_hero_fi = 0.0
			_hero_once = false
	else:
		_hero_fi = fmod(_hero_fi, float(frames.size()))
	if not _spent and _t >= T_GRAB + 1.2:
		_spent = true
		_hero_anim = "swipe"
		_hero_fi = 0.0
		for it in _items:
			if str(it.get("kind", "")) == "spend" and bool(it.get("held", false)):
				it["toss"] = _t
				it["held"] = false
		if not _mons.is_empty():
			_mons[0]["hit"] = true
	elif _t >= T_THRESHOLD + 1.2 and _t < T_THRESHOLD + 1.7 and _hero_anim == "walkoff" and not _hero_once:
		_hero_anim = "grab"
		_hero_fi = 0.0
		_hero_once = true


func _step_world() -> void:
	if _hall == null:
		return
	var in_cabin: bool = _t < T_THRESHOLD
	_hall.visible = not in_cabin and _hall_strip == null and _still_a < 0.8
	if _hall.visible:
		_hall.pan = _t * 220.0
		var want: int = int((_t - T_THRESHOLD) / 3.0)
		while _hall.hall < want:
			_hall.bump_hall()


func _step_fade() -> void:
	if _t < T_SWIRL:
		_white = 0.0
		_still_a = 0.0
		return
	if _t < T_WHITE_PEAK:
		_white = clampf((_t - T_SWIRL) / (T_WHITE_PEAK - T_SWIRL), 0.0, 1.0)
		_still_a = 0.0
		return
	_white = clampf(1.0 - (_t - T_WHITE_PEAK) / (T_STILL - T_WHITE_PEAK), 0.0, 1.0)
	_still_a = clampf((_t - T_WHITE_PEAK) / (T_STILL - T_WHITE_PEAK), 0.0, 1.0)


func _land_still() -> void:
	holding_still = true
	_t = T_STILL
	_white = 0.0
	_still_a = 1.0
	_set_title_visible(true)
	_sync_music_lab()
	if _hall:
		_hall.visible = false
	if music_dip:
		_apply_music_dip(true)


func _set_title_visible(on: bool) -> void:
	if _title:
		_title.visible = on
	if _tag:
		_tag.visible = on
	if _click:
		_click.visible = on
	if _music_lab:
		_music_lab.visible = on and OS.has_feature("editor")


func _sync_music_lab() -> void:
	if _music_lab == null:
		return
	if music_dip:
		_music_lab.set_plain("M: title bed (dip)")
	else:
		_music_lab.set_plain("M: combat through")


func _apply_music_dip(on: bool) -> void:
	if sfx == null:
		return
	if on and sfx.has_method("music_title"):
		sfx.music_title()
	elif sfx.has_method("set_combat_music"):
		sfx.set_combat_music(true)


func _on_gui(ev: InputEvent) -> void:
	if not visible:
		return
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		_try_advance()
		accept_event()


func _input(ev: InputEvent) -> void:
	if not visible:
		return
	if ev is InputEventKey and ev.pressed and not ev.echo:
		if ev.keycode == KEY_M and holding_still:
			music_dip = not music_dip
			_apply_music_dip(music_dip)
			_sync_music_lab()
			get_viewport().set_input_as_handled()
			return
		if ev.keycode == KEY_ESCAPE or ev.keycode == KEY_SPACE or ev.keycode == KEY_ENTER:
			_try_advance()
			get_viewport().set_input_as_handled()


func _try_advance() -> void:
	if _yielded:
		return
	if _arm > 0.0:
		return
	if holding_still:
		finished.emit()
		return
	if skippable:
		_land_still()


func _hero_x(sz: Vector2) -> float:
	if _t < T_THRESHOLD:
		return lerpf(sz.x * 0.22, sz.x * 0.36, _t / T_THRESHOLD)
	if _t < T_SPEND:
		return sz.x * 0.36
	if _t < T_SWIRL:
		return sz.x * 0.38
	var k: float = clampf((_t - T_SWIRL) / 1.4, 0.0, 1.0)
	return lerpf(sz.x * 0.36, sz.x * 0.50, k)


func _hero_y(sz: Vector2) -> float:
	return sz.y * 0.62


func _draw() -> void:
	if not visible:
		return
	var sz: Vector2 = size
	if sz.x < 8.0:
		sz = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, sz), Color("100e0c"), true)
	if _still_a < 0.99:
		_draw_world(sz)
		_draw_actors(sz)
	if _still_a > 0.0:
		_draw_still(sz, _still_a)
	if _white > 0.0:
		draw_rect(Rect2(Vector2.ZERO, sz), Color(1, 1, 1, _white), true)


func _draw_world(sz: Vector2) -> void:
	if _t < T_THRESHOLD:
		if _hill != null:
			_blit_strip(_hill, sz, _t * 90.0)
		elif _cabin != null:
			_blit(_cabin, Rect2(Vector2.ZERO, sz), Color(0.55, 0.5, 0.48, 1.0))
		if _door != null:
			var dw := sz.x * 0.16
			var dh := sz.y * 0.42
			_blit(_door, Rect2(sz.x * 0.62, sz.y * 0.38, dw, dh), Color.WHITE)
		if _nib != null:
			_blit(_nib, Rect2(sz.x * 0.10, sz.y * 0.48, 96, 96), Color.WHITE)
			var lamp: Texture2D = _item_tex("lantern")
			if lamp != null:
				_blit(lamp, Rect2(sz.x * 0.10 + 70, sz.y * 0.52, 40, 40), Color.WHITE)
		return
	var hall: Texture2D = _hall_strip_b if _t >= T_SPEND and _hall_strip_b != null else _hall_strip
	if hall != null:
		_blit_strip(hall, sz, _t * 220.0)


func _draw_actors(sz: Vector2) -> void:
	var hx: float = _hero_x(sz)
	var hy: float = _hero_y(sz)
	var swirl: bool = _t >= T_SWIRL
	var cx: float = sz.x * 0.5
	var cy: float = sz.y * 0.52
	for m in _mons:
		if _t < float(m.get("born", 0.0)):
			continue
		var tex: Texture2D = m.get("tex")
		if tex == null:
			continue
		var age: float = _t - float(m.get("born", 0.0))
		var p: Vector2
		if swirl:
			var a: float = age * 1.7 + float(m.get("lane", 0.1)) * 12.0
			p = Vector2(cx, cy) + Vector2(cos(a), sin(a)) * (180.0 + 40.0 * float(m.get("lane", 0.1)) * 8.0)
		else:
			p = Vector2(hx - 80.0 - age * 28.0, hy + 8.0 + sin(age * 3.0) * 10.0)
			if bool(m.get("hit", false)):
				p += Vector2(-40.0, -30.0)
		var dim: Color = Color(1, 0.55, 0.5, 1.0) if bool(m.get("hit", false)) else Color.WHITE
		var ms: float = 72.0
		if bool(m.get("big", false)):
			ms = 192.0 if str(m.get("id", "")) in ["ogre", "spider_queen", "dragon"] else 128.0
		_blit(tex, Rect2(p.x - ms * 0.5, p.y - ms, ms, ms), dim)
	var held_i := 0
	for it in _items:
		if _t < float(it.get("born", 0.0)):
			continue
		if bool(it.get("gone", false)):
			continue
		var tex2: Texture2D = it.get("tex")
		if tex2 == null:
			continue
		var age2: float = _t - float(it.get("born", 0.0))
		var kind: String = str(it.get("kind", ""))
		if not bool(it.get("held", false)) and float(it.get("toss", 0.0)) == 0.0:
			var ix: float = sz.x * 0.92 - age2 * 260.0
			var iy: float = hy - 70.0 + sin(age2 * 4.0) * 18.0
			if kind != "miss" and ix < hx + 20.0 and ix > hx - 10.0:
				it["held"] = true
			var isz: float = 128.0 if bool(it.get("big", false)) else 48.0
			_blit(tex2, Rect2(ix, iy, isz, isz), Color.WHITE)
			continue
		if float(it.get("toss", 0.0)) > 0.0:
			var u: float = clampf((_t - float(it.get("toss", 0.0))) / 0.45, 0.0, 1.0)
			var tp := Vector2(hx, hy - 20.0).lerp(Vector2(hx - 90.0, hy - 10.0), u)
			var tsz: float = 128.0 if bool(it.get("big", false)) else 40.0
			_blit(tex2, Rect2(tp.x, tp.y, tsz, tsz), Color(1, 1, 1, 1.0 - u))
			if u >= 1.0:
				it["gone"] = true
			continue
		var ang: float = _t * 2.4 + float(held_i) * 0.9
		var rad: float = 70.0 if not swirl else 130.0
		var hp := Vector2(hx, hy - 20.0)
		if swirl:
			hp = Vector2(cx, cy)
		var p2: Vector2 = hp + Vector2(cos(ang), sin(ang)) * rad
		var hsz: float = 128.0 if bool(it.get("big", false)) else 44.0
		_blit(tex2, Rect2(p2.x - hsz * 0.5, p2.y - hsz * 0.5, hsz, hsz), Color.WHITE)
		held_i += 1
	_draw_hero(Vector2(hx, hy))


func _draw_hero(pos: Vector2) -> void:
	var frames: Array = _walk
	if _hero_anim == "swipe":
		frames = _swipe
	elif _hero_anim == "block":
		frames = _block
	elif _hero_anim == "grab":
		frames = _grab
	if frames.is_empty():
		return
	var idx: int = clampi(int(_hero_fi), 0, frames.size() - 1)
	var tex: Texture2D = frames[idx]
	if tex == null:
		return
	if _sprout_teaser:
		_blit(tex, Rect2(pos.x - 96, pos.y - 184, 192, 192), Color.WHITE)
	else:
		_blit(tex, Rect2(pos.x - 48, pos.y - 86, 96, 96), Color.WHITE)


func _draw_still(sz: Vector2, a: float) -> void:
	var col := Color(1, 1, 1, a)
	if _still != null:
		_blit(_still, Rect2(Vector2.ZERO, sz), col)
	else:
		draw_rect(Rect2(Vector2.ZERO, sz), Color(0.08, 0.07, 0.06, a), true)
		if _cabin != null:
			_blit(_cabin, Rect2(Vector2.ZERO, sz), Color(0.7, 0.65, 0.6, a * 0.85))
		if not _walk.is_empty() and _walk[0] != null:
			_blit(_walk[0], Rect2(sz.x * 0.42, sz.y * 0.38, 192, 192), col)
	if _logo != null:
		var lw: float = minf(sz.x * 0.5, float(_logo.get_width()))
		var lh: float = lw * float(_logo.get_height()) / maxf(1.0, float(_logo.get_width()))
		_blit(_logo, Rect2((sz.x - lw) * 0.5, sz.y * 0.12, lw, lh), col)


func _blit_strip(tex: Texture2D, sz: Vector2, pan: float) -> void:
	if tex == null:
		return
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw < 1.0:
		return
	var scale: float = sz.y / th
	var w: float = tw * scale
	var x: float = -fmod(pan, w)
	if x > 0.0:
		x -= w
	while x < sz.x:
		draw_texture_rect(tex, Rect2(x, 0, w, sz.y), false)
		x += w


func _blit(tex: Texture2D, rect: Rect2, col: Color) -> void:
	if tex == null:
		return
	draw_texture_rect(tex, rect, false, col)
