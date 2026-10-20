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

## Beat starts (seconds), locked to PIXEL.md.
const T_THRESHOLD := 2.0
const T_GRAB := 2.0
const T_SPEND := 5.0
const T_HALL_B := 5.0
const T_SWIRL := 8.5
const T_WHITE := 11.0
const T_WHITE_PEAK := 12.2
const T_STILL := 13.0

const T_BOOT_THROW := 5.6
const T_HELMET_USE := 7.0

const FLOOR_Y := 644.0
const NIB_DOOR_X := 204.0
const ITEM_DRAW := 96.0
const ITEM_FLY_SPEED := 640.0
const LOGO_RECT := Rect2(340, 80, 1000, 160)
const TAG_RECT := Rect2(260, 250, 1160, 80)
const CLICK_RECT := Rect2(340, 920, 1000, 80)
const LOGO_CAP_W := 840.0

const ITEM_CATCH := ["pocketwatch", "lantern", "grimoire", "healing_potion"]
const ITEM_MISS := ["lucky_nickel", "sledgehammer"]
const ITEM_SPEND := ["da_boot", "helmet"]
const MONSTER_IDS := ["goblin", "dire_wolf", "skeleton", "ogre", "hornet_swarm", "spider_queen", "dragon"]
## Chase gaps behind the hero (shipped px). Index matches MONSTER_IDS.
const MONSTER_GAP := [110.0, 150.0, 190.0, 240.0, 280.0, 330.0, 390.0]
## Enter during grab (first three) or spend (crowd-in). Never before T_THRESHOLD.
const MONSTER_BORN := [2.2, 2.7, 3.2, 5.2, 5.7, 6.2, 6.8]

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
var _boot_spent: bool = false
var _helmet_spent: bool = false
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
var _nib_fi: float = 0.0
var _sprout_teaser: bool = false
var _nib: Texture2D
var _cabin: Texture2D
var _title
var _tag
var _click
var _music_lab
var _hall_strip_in_use: String = ""
var _rec = null
var _rec_draw: bool = true


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
	_boot_spent = false
	_helmet_spent = false
	_nib_fi = 0.0
	_hall_strip_in_use = ""
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


func debug_capture(t: float) -> Dictionary:
	if size.x < 8.0 or size.y < 8.0:
		size = Vector2(1680, 1040)
	open_teaser(false)
	var dt := 1.0 / 60.0
	while _t < t and not holding_still:
		var step: float = minf(dt, t - _t)
		_tick(step)
	# Still holds the clock at T_STILL; report the requested sample time.
	var report_t: float = t if holding_still else _t
	_rec = []
	_rec_draw = false
	_paint()
	var blits: Array = _rec
	_rec = null
	_rec_draw = true
	var labels: Array = []
	for lab in [_title, _tag, _click, _music_lab]:
		if lab == null:
			continue
		var r: Rect2 = Rect2(lab.position, lab.size)
		labels.append({
			"name": str(lab.name),
			"rect": [r.position.x, r.position.y, r.size.x, r.size.y],
			"visible": lab.visible,
		})
	return {
		"t": report_t,
		"blits": blits,
		"white": _white,
		"still_a": _still_a,
		"hall_strip_in_use": _hall_strip_in_use,
		"title_visible": _tag != null and _tag.visible,
		"labels": labels,
		"logo_rect": _logo_draw_rect(),
	}


func _build_labels() -> void:
	_title = _plain("_title", COPY.text("title.overlay", "Swipe"), 72, Color("e8c36a"), LOGO_RECT)
	_tag = _plain("_tag", COPY.text("title.sub", "Use it, Lose it, or Lose your head"), 28, Color("f4ede3"), TAG_RECT)
	_click = _plain("_click", COPY.text("intro.next", "Click to continue"), 22, Color("c9b9a8"), CLICK_RECT)
	_music_lab = _plain("_music_lab", "", 14, Color("c9b9a8"), Rect2(1280, 980, 360, 40))
	add_child(_title)
	add_child(_tag)
	add_child(_click)
	add_child(_music_lab)


func _plain(node_name: String, text: String, size_px: int, col: Color, rect: Rect2):
	var lab = FitLabelBox.make()
	lab.name = node_name
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = size_px
	lab.min_font_size = 13
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.set_anchors_preset(Control.PRESET_TOP_LEFT)
	lab.position = rect.position
	lab.custom_minimum_size = rect.size
	lab.size = rect.size
	lab.font_color = col
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 4
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
	_nib = null
	_cabin = null
	if art != null:
		if art.has_method("home_tex"):
			_nib = art.home_tex("nib/nib_idle_f0")
			_cabin = art.home_tex("rooms/room_main")
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


func _item_frames(id: String) -> Array:
	var frames: Array = _seq("item_%s" % id)
	if not frames.is_empty():
		return frames
	var one: Texture2D = null
	if art != null and art.has_method("item_tex"):
		one = art.item_tex(id)
	if one != null:
		return [one]
	return []


func _mon_frames(id: String) -> Array:
	var frames: Array = _seq("mon_%s" % id)
	if not frames.is_empty():
		return frames
	var one: Texture2D = null
	if art != null and art.has_method("monster_still"):
		one = art.monster_still(id)
	if one != null:
		return [one]
	return []


func _spawn_actors() -> void:
	_items.clear()
	_mons.clear()
	var i := 0
	for id in ITEM_CATCH:
		_items.append(_item_actor(str(id), "catch", T_GRAB + 0.15 + float(i) * 0.45))
		i += 1
	var j := 0
	for id2 in ITEM_MISS:
		_items.append(_item_actor(str(id2), "miss", T_GRAB + 0.35 + float(j) * 0.9))
		j += 1
	var k := 0
	for id3 in ITEM_SPEND:
		_items.append(_item_actor(str(id3), "spend", T_GRAB + 0.25 + float(k) * 0.55))
		k += 1
	for m in range(MONSTER_IDS.size()):
		var mid: String = str(MONSTER_IDS[m])
		var frames: Array = _mon_frames(mid)
		var teaser: bool = _opt("%s/mon_%s_f0.png" % [TITLE_DIR, mid]) != null
		_mons.append({
			"id": mid,
			"frames": frames,
			"fi": 0.0,
			"teaser": teaser,
			"born": float(MONSTER_BORN[m]),
			"gap": float(MONSTER_GAP[m]),
			"hit": false,
			"knock": 0.0,
		})


func _item_actor(id: String, kind: String, born: float) -> Dictionary:
	var frames: Array = _item_frames(id)
	return {
		"id": id,
		"kind": kind,
		"frames": frames,
		"fi": 0.0,
		"born": born,
		"held": false,
		"gone": false,
		"toss": 0.0,
	}


func _process(delta: float) -> void:
	if not visible:
		return
	_tick(delta)
	queue_redraw()


func _tick(delta: float) -> void:
	if _arm > 0.0:
		_arm -= delta
	if not holding_still:
		_t += delta
		var sz: Vector2 = _view_size()
		_step_hero(delta)
		_step_items(sz, delta)
		_step_mons(sz, delta)
		_step_world()
		_step_fade()
		if _t >= T_STILL:
			_land_still()
	else:
		if _click:
			var pulse: float = 0.72 + 0.28 * absf(sin(Time.get_ticks_msec() * 0.005))
			_click.modulate.a = pulse


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
	if not frames.is_empty():
		_hero_fi += delta * fps
		if _hero_anim != "walkoff":
			if _hero_fi >= float(frames.size()):
				_hero_anim = "walkoff"
				_hero_fi = 0.0
		else:
			_hero_fi = fmod(_hero_fi, float(frames.size()))
	if not _nib_lantern.is_empty():
		_nib_fi = fmod(_nib_fi + delta * 3.0, float(_nib_lantern.size()))
	_fire_spend_beats()


func _fire_spend_beats() -> void:
	if not _boot_spent and _t >= T_BOOT_THROW:
		_boot_spent = true
		var boot = _item_by_id("da_boot")
		if boot != null:
			# Force held first if the fly-in has not crossed yet, then throw.
			boot["held"] = false
			boot["toss"] = _t
		_hero_anim = "swipe"
		_hero_fi = 0.0
		var target = _nearest_chase_mon()
		if target != null:
			target["hit"] = true
			target["knock"] = 48.0
	if not _helmet_spent and _t >= T_HELMET_USE:
		_helmet_spent = true
		var helm = _item_by_id("helmet")
		if helm != null:
			helm["held"] = false
			helm["toss"] = 0.0
			helm["gone"] = true
		if not _block.is_empty():
			_hero_anim = "block"
			_hero_fi = 0.0


func _item_by_id(id: String):
	for it in _items:
		if str(it.get("id", "")) == id:
			return it
	return null


func _nearest_chase_mon():
	var best = null
	var best_gap := 1.0e9
	for m in _mons:
		if _t < float(m.get("born", 0.0)):
			continue
		var g: float = float(m.get("gap", 999.0))
		if g < best_gap:
			best_gap = g
			best = m
	return best


func _step_items(sz: Vector2, delta: float) -> void:
	var hx: float = _hero_x(sz)
	for it in _items:
		var frames: Array = it.get("frames", [])
		if not frames.is_empty():
			it["fi"] = float(it.get("fi", 0.0)) + delta * 4.0
		if _t < float(it.get("born", 0.0)):
			continue
		if bool(it.get("gone", false)):
			continue
		if float(it.get("toss", 0.0)) > 0.0:
			var u: float = clampf((_t - float(it.get("toss", 0.0))) / 0.45, 0.0, 1.0)
			if u >= 1.0:
				it["gone"] = true
			continue
		if bool(it.get("held", false)):
			continue
		var age2: float = _t - float(it.get("born", 0.0))
		var ix: float = sz.x * 0.92 - age2 * ITEM_FLY_SPEED
		var kind: String = str(it.get("kind", ""))
		if kind != "miss" and ix <= hx + 20.0:
			it["held"] = true
			_hero_anim = "grab"
			_hero_fi = 0.0


func _step_mons(_sz: Vector2, delta: float) -> void:
	for m in _mons:
		var frames: Array = m.get("frames", [])
		if not frames.is_empty():
			m["fi"] = float(m.get("fi", 0.0)) + delta * 10.0
		if bool(m.get("hit", false)):
			var kn: float = float(m.get("knock", 0.0))
			if kn > 0.0:
				m["knock"] = maxf(0.0, kn - delta * 40.0)


func _step_world() -> void:
	if _hall == null:
		return
	var in_cabin: bool = _t < T_THRESHOLD
	_hall.visible = not in_cabin and _hall_strip == null and _still_a < 0.8
	if _hall.visible:
		_hall.pan = _snap4(_t * 220.0)
		var want: int = int((_t - T_THRESHOLD) / 3.0)
		while _hall.hall < want:
			_hall.bump_hall()


func _step_fade() -> void:
	if _t < T_WHITE:
		_white = 0.0
		_still_a = 0.0
		return
	if _t < T_WHITE_PEAK:
		_white = clampf((_t - T_WHITE) / (T_WHITE_PEAK - T_WHITE), 0.0, 1.0)
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
		_title.visible = on and _logo == null
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


func _view_size() -> Vector2:
	var sz: Vector2 = size
	if sz.x >= 8.0 and sz.y >= 8.0:
		return sz
	if is_inside_tree():
		var vs: Vector2 = get_viewport_rect().size
		if vs.x >= 8.0 and vs.y >= 8.0:
			return vs
	return Vector2(1680, 1040)


func _hero_x(sz: Vector2) -> float:
	if _t < T_THRESHOLD:
		return _snap4(lerpf(sz.x * 0.22, sz.x * 0.36, _t / T_THRESHOLD))
	if _t < T_SWIRL:
		return _snap4(sz.x * 0.36)
	var k: float = clampf((_t - T_SWIRL) / 1.4, 0.0, 1.0)
	return _snap4(lerpf(sz.x * 0.36, sz.x * 0.50, k))


func _snap4(v: float) -> float:
	return floorf(v / 4.0) * 4.0


func _snap_pos(p: Vector2) -> Vector2:
	return Vector2(_snap4(p.x), _snap4(p.y))


func _draw() -> void:
	if not visible:
		return
	_paint()


func _paint() -> void:
	var sz: Vector2 = _view_size()
	_fill_rect(Rect2(Vector2.ZERO, sz), Color("100e0c"))
	if _still_a < 0.99:
		_draw_world(sz)
		_draw_actors(sz)
	if _still_a > 0.0:
		_draw_still(sz, _still_a)
	if _white > 0.0:
		_fill_rect(Rect2(Vector2.ZERO, sz), Color(1, 1, 1, _white))


func _fill_rect(rect: Rect2, col: Color) -> void:
	if not _rec_draw:
		return
	draw_rect(rect, col, true)


func _draw_world(sz: Vector2) -> void:
	_hall_strip_in_use = ""
	if _t < T_THRESHOLD:
		if _hill != null:
			_blit_strip(_hill, sz, _t * 90.0)
			_hall_strip_in_use = "hill"
		elif _cabin != null:
			_blit(_cabin, Rect2(Vector2.ZERO, sz), Color(0.55, 0.5, 0.48, 1.0))
			_hall_strip_in_use = "cabin"
		_draw_nib(sz)
		return
	var use_b: bool = _t >= T_HALL_B and _hall_strip_b != null
	var hall: Texture2D = _hall_strip_b if use_b else _hall_strip
	if hall != null:
		_blit_strip(hall, sz, _t * 220.0)
		_hall_strip_in_use = "hall_b" if use_b else "hall"
	elif use_b:
		_hall_strip_in_use = "hall_b"


func _draw_nib(sz: Vector2) -> void:
	var tex: Texture2D = _nib
	if not _nib_lantern.is_empty():
		var idx: int = clampi(int(_nib_fi), 0, _nib_lantern.size() - 1)
		tex = _nib_lantern[idx]
	if tex == null:
		return
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw < 1.0 or th < 1.0:
		return
	var pan: float = _snap4(_t * 90.0)
	var strip_w: float = sz.x
	if _hill != null:
		var scale: float = sz.y / maxf(1.0, float(_hill.get_height()))
		strip_w = float(_hill.get_width()) * scale
	var x0: float = -fmod(pan, strip_w)
	if x0 > 0.0:
		x0 -= strip_w
	var door_x: float = x0 + NIB_DOOR_X
	var feet := _snap_pos(Vector2(door_x, FLOOR_Y))
	_blit(tex, Rect2(feet.x - tw * 0.5, feet.y - th, tw, th), Color.WHITE)


func _draw_actors(sz: Vector2) -> void:
	var hx: float = _hero_x(sz)
	var hy: float = FLOOR_Y
	var swirl: bool = _t >= T_SWIRL
	var cx: float = _snap4(sz.x * 0.5)
	var cy: float = _snap4(sz.y * 0.52)
	for m in _mons:
		if _t < T_THRESHOLD:
			continue
		if _t < float(m.get("born", 0.0)):
			continue
		var frames: Array = m.get("frames", [])
		if frames.is_empty():
			continue
		var fi: int = clampi(int(m.get("fi", 0.0)) % frames.size(), 0, frames.size() - 1)
		var tex: Texture2D = frames[fi]
		if tex == null:
			continue
		var age: float = _t - float(m.get("born", 0.0))
		var p: Vector2
		if swirl:
			var a: float = age * 1.7 + float(m.get("gap", 100.0)) * 0.02
			p = Vector2(cx, cy) + Vector2(cos(a), sin(a)) * (180.0 + float(m.get("gap", 100.0)) * 0.15)
		else:
			var ease: float = clampf(age / 0.6, 0.0, 1.0)
			ease = ease * ease * (3.0 - 2.0 * ease)
			var slot_x: float = hx - float(m.get("gap", 110.0))
			var from_x: float = -120.0
			var bob: float = sin(_t * 5.0 + float(m.get("gap", 0.0)) * 0.01) * 6.0
			p = Vector2(lerpf(from_x, slot_x, ease), hy + bob)
			p.x -= float(m.get("knock", 0.0))
		p = _snap_pos(p)
		var dim: Color = Color(1, 0.55, 0.5, 1.0) if bool(m.get("hit", false)) else Color.WHITE
		var ms: Vector2 = _mon_draw_size(str(m.get("id", "")), tex)
		var flip: bool = _mon_flip_h(str(m.get("id", "")), bool(m.get("teaser", false)))
		_blit(tex, Rect2(p.x - ms.x * 0.5, p.y - ms.y, ms.x, ms.y), dim, flip)
	var held_i := 0
	for it in _items:
		if _t < float(it.get("born", 0.0)):
			continue
		if bool(it.get("gone", false)):
			continue
		var frames2: Array = it.get("frames", [])
		if frames2.is_empty():
			continue
		var fi2: int = clampi(int(it.get("fi", 0.0)) % frames2.size(), 0, frames2.size() - 1)
		var tex2: Texture2D = frames2[fi2]
		if tex2 == null:
			continue
		var age2: float = _t - float(it.get("born", 0.0))
		if not bool(it.get("held", false)) and float(it.get("toss", 0.0)) == 0.0:
			var ix: float = _snap4(sz.x * 0.92 - age2 * ITEM_FLY_SPEED)
			var iy: float = _snap4(hy - 70.0 + sin(age2 * 4.0) * 18.0)
			_blit(tex2, Rect2(ix, iy, ITEM_DRAW, ITEM_DRAW), Color.WHITE)
			continue
		if float(it.get("toss", 0.0)) > 0.0:
			var u: float = clampf((_t - float(it.get("toss", 0.0))) / 0.45, 0.0, 1.0)
			var tp := _snap_pos(Vector2(hx, hy - 40.0).lerp(Vector2(hx - 220.0, hy - 80.0), u))
			_blit(tex2, Rect2(tp.x, tp.y, ITEM_DRAW, ITEM_DRAW), Color(1, 1, 1, 1.0 - u))
			continue
		var ang: float = _t * 2.4 + float(held_i) * 0.9
		var rad: float = 70.0 if not swirl else 130.0
		var hp := Vector2(hx, hy - 40.0)
		if swirl:
			hp = Vector2(cx, cy)
		var p2: Vector2 = _snap_pos(hp + Vector2(cos(ang), sin(ang)) * rad)
		_blit(tex2, Rect2(p2.x - ITEM_DRAW * 0.5, p2.y - ITEM_DRAW * 0.5, ITEM_DRAW, ITEM_DRAW), Color.WHITE)
		held_i += 1
	_draw_hero(Vector2(hx, hy))


func _mon_draw_size(id: String, tex: Texture2D) -> Vector2:
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw < 1.0 or th < 1.0:
		return Vector2(128, 128)
	var target_h := 128.0
	if id == "dragon":
		target_h = 256.0
	elif id in ["ogre", "spider_queen"]:
		target_h = 192.0
	var mult: int = maxi(1, int(round(target_h / th)))
	if id == "dragon":
		while float(mult) * th < 256.0:
			mult += 1
	return Vector2(tw * float(mult), th * float(mult))


func _mon_flip_h(id: String, teaser: bool) -> bool:
	if teaser:
		return false
	return id == "dragon" or id == "ogre"


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
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if _sprout_teaser:
		_blit(tex, Rect2(pos.x - tw * 0.5, pos.y - th, tw, th), Color.WHITE)
	else:
		_blit(tex, Rect2(pos.x - 48, pos.y - 96, 96, 96), Color.WHITE)


func _logo_draw_rect() -> Array:
	if _logo == null:
		return [LOGO_RECT.position.x, LOGO_RECT.position.y, LOGO_RECT.size.x, LOGO_RECT.size.y]
	var lw: float = float(_logo.get_width())
	var lh: float = float(_logo.get_height())
	if lw > LOGO_CAP_W:
		var s: float = LOGO_CAP_W / lw
		lw = LOGO_CAP_W
		lh = lh * s
	var x: float = LOGO_RECT.position.x + (LOGO_RECT.size.x - lw) * 0.5
	var y: float = LOGO_RECT.position.y + (LOGO_RECT.size.y - lh) * 0.5
	return [x, y, lw, lh]


func _draw_still(sz: Vector2, a: float) -> void:
	var col := Color(1, 1, 1, a)
	if _still != null:
		_blit(_still, Rect2(Vector2.ZERO, sz), col)
	else:
		_fill_rect(Rect2(Vector2.ZERO, sz), Color(0.08, 0.07, 0.06, a))
		if _cabin != null:
			_blit(_cabin, Rect2(Vector2.ZERO, sz), Color(0.7, 0.65, 0.6, a * 0.85))
		if not _walk.is_empty() and _walk[0] != null:
			var t0: Texture2D = _walk[0]
			var tw: float = float(t0.get_width())
			var th: float = float(t0.get_height())
			_blit(t0, Rect2(sz.x * 0.42, sz.y * 0.38, tw, th), col)
	if _logo != null:
		var lr: Array = _logo_draw_rect()
		_blit(_logo, Rect2(float(lr[0]), float(lr[1]), float(lr[2]), float(lr[3])), col)


func _blit_strip(tex: Texture2D, sz: Vector2, pan: float) -> void:
	if tex == null:
		return
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw < 1.0:
		return
	var scale: float = sz.y / th
	var w: float = tw * scale
	var x: float = -fmod(_snap4(pan), w)
	if x > 0.0:
		x -= w
	x = _snap4(x)
	while x < sz.x:
		_blit(tex, Rect2(x, 0, w, sz.y), Color.WHITE)
		x = _snap4(x + w)


func _blit(tex: Texture2D, rect: Rect2, col: Color, flip_h: bool = false) -> void:
	if tex == null:
		return
	var r := Rect2(_snap4(rect.position.x), _snap4(rect.position.y), rect.size.x, rect.size.y)
	if _rec != null:
		var path := ""
		if tex.resource_path != "":
			path = tex.resource_path
		_rec.append({
			"tex": path,
			"rect": [r.position.x, r.position.y, r.size.x, r.size.y],
			"flip_h": flip_h,
			"mod": [col.r, col.g, col.b, col.a],
		})
	if not _rec_draw:
		return
	if flip_h:
		draw_texture_rect(tex, Rect2(r.position.x + r.size.x, r.position.y, -r.size.x, r.size.y), false, col)
	else:
		draw_texture_rect(tex, r, false, col)
