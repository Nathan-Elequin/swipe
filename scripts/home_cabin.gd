extends ColorRect
## Cabin is the main menu. Collection only — no spend. Gear is cosmetic.

signal closed
signal inspect_wanted(card_id: String)
signal item_hovered(card_id: String, slot: Control)
signal item_unhovered
signal route_chosen(route: String)
signal held_map_wanted
signal tutorial_wanted
signal quit_wanted
signal comment_wanted(card_id: String)
## Fires when a case's shown collection crosses the quota (5). Map stamp is Slice C.
signal cabinet_gate_crossed(pool_id: String)

const SAVE_PATH := "user://home_cabin.json"
const COPY := preload("res://scripts/player_copy.gd")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0
const ARRIVE_WALK_SPEED := 32.0
const ARRIVE_INT_SPEED := 51.2
const ROOM_W := 1680.0
const ROOM_H := 1040.0
const VIEW_FRAME := preload("res://scripts/ui/view_frame.gd")
const ROOM_ORDER: Array[String] = ["main", "hall", "study", "workshop", "loft"]
const STATION_BEDS := ["cabin", "station_inn", "station_rag", "station_harp"]
const RUG_SECRET_ID := "poison_flask"
const RUG_COPY := {
	"nib.rug.1": "Grandpa stuffed a Poison Flask under the rug. He said the mice had it coming.",
	"nib.rug.2": "There's only one thing that can be done with this.",
	"nib.rug.3": "And that one thing is to drop it directly in the dungeon so you can use it on your next dungeon delve.",
	"nib.rug.again": "Already threw it. You'll see it in the mill next time you leave.",
	"cabin.rug.unlock": "Poison Flask is unlocked. It can show up in every dungeon from here on.",
}

var seen: Dictionary = {}
var swiped: Dictionary = {}
var new_unseen: Dictionary = {}
var intro_seen: bool = false
var intro_pack: int = 1
var nib_first_done: bool = false
var tutorial_done: bool = false
var tutorial_declined: bool = false
var rooms_unlocked: Array = ["main"]
var key_ring_seen: bool = false
var invert_scroll: bool = false
var ending_seen: bool = false
var deepest_belly: int = 0
var met_monsters: Dictionary = {}
var last_route: String = ""
var radio_station: int = 0
var gear_worn: Dictionary = {"head": "", "eyes": "", "belt": ""}
var letters_read: Array = []
var bestiary_read: Array = []
var will_read: bool = false
var drawer_hint_said: bool = false
var drawer_opened: bool = false
var geode_on_mantel: bool = false
var drawer_stuck_index: int = 0
var milestones_said: Array = []
var nib_idle_index: int = 0
var rug_secret_found: bool = false
var counters: Dictionary = {"delves": 0, "homecomings": 0, "hauls": 0, "losses": 0}
var _raw_save: Dictionary = {}
var lore: Dictionary = {}
var layout: Dictionary = {}
var extra: Dictionary = {}
var catalog: Dictionary = {}
var return_room: String = "main"
var trunk_open: bool = false
var _current_room: String = "main"
var _overlay_name: String = ""
var _pan_busy: bool = false
var _menu_on: bool = false
var _homecoming_kind: String = ""
var _held_ids: Array = []
var _new_ids: Array = []
var _gear_last: String = ""
var _geode_line: int = 0
var settings_ui

var art
var sfx
var items_by_id: Dictionary = {}
var tex_by_item: Dictionary = {}
var buckets_open: int = 0

var _ext_root: Control
var _int_root: Control
var _rooms_clip: Control
var _rooms_host: Control
var _rooms: Dictionary = {}
var _toast: TextureRect
var _toast_lab
var _hover_tag
var _overlays: Control
var _dialog
var _cutscene
var _story_seq: int = 0
var _map
var _radio
var _journal
var _will
var _drawer
var _card
var _editor_strip: VBoxContainer
var _gauge: TextureProgressBar
var _hero_layers: Dictionary = {}
var _rocking: bool = false
var _rock_i: int = 1
var _limp: Sprite2D
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
var _chair_empty: Sprite2D
var _chair_hit: Control
var _arrive_pending_name: String = ""
var _arrive_pending_room: String = ""
var _step_fi: int = -1
var _cat_sfx_t: float = 8.0
var _fade: ColorRect
var _shelf_host: Control
var _hole: Control
var _shelf_fade: ColorRect
var _back: Button
var _prev_btn: Control
var _next_btn: Control
var _prev_door: TextureRect
var _next_door: TextureRect
var _cordon: TextureRect
var _pips: HBoxContainer
var _room: int = 0
var _max_room: int = 0
var _max_bucket: int = 0
var _room_busy: bool = false
var _by_bucket: Dictionary = {}
var _campaign_rules: Dictionary = {}
var _bank_hold: Dictionary = {}
var _bank_fresh: String = ""
var _bank_busy: bool = false
var _bank_played: bool = false
var _case_scroll: Dictionary = {}
var _case_columns: Dictionary = {}
var _case_clips: Dictionary = {}
const ROOM_WALK := 1.5
const ROOM_WIPE_AT := 1.0
var _window_glow: TextureRect
var _door_glow: TextureRect
var _lantern_glow: TextureRect
var _fire_glow: TextureRect
var _hover_id: String = ""
var _arriving: bool = false
var _arrive_skip: int = 0
var _arrive_gen: int = 0
var _arrive_motion: Tween
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


func setup(p_art = null, p_sfx = null, p_lore: Dictionary = {}, p_layout: Dictionary = {}, p_catalog: Dictionary = {}) -> void:
	art = p_art
	sfx = p_sfx
	lore = p_lore
	layout = p_layout
	extra = layout.get("extra", {}) if typeof(layout.get("extra", {})) == TYPE_DICTIONARY else {}
	catalog = p_catalog
	name = "CabinRoot"
	visible = false
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	color = Color(0, 0, 0, 1)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rng.randomize()
	_load_save()
	_build()
	_apply_view_frame()
	resized.connect(_apply_view_frame)


func note_seen(id: String) -> void:
	var sid: String = str(id)
	if sid == "" or sid == "spider_egg":
		return
	if bool(seen.get(sid, false)):
		return
	seen[sid] = true
	_save()


func swipe_ids(ids: Array) -> Array:
	var changed := false
	_just_mounted.clear()
	var news: Array = []
	for raw in ids:
		var sid: String = str(raw)
		if sid == "" or sid == "spider_egg":
			continue
		if BucketRules.is_token(items_by_id.get(sid, {}).get("bucket", 0)):
			continue
		seen[sid] = true
		if not bool(swiped.get(sid, false)):
			swiped[sid] = true
			_just_mounted.append(sid)
			_bank_hold[sid] = true
			new_unseen[sid] = true
			news.append(sid)
			changed = true
	if changed:
		_bank_played = false
		_save()
		call_deferred("_offer_bank_sequence")
	return news


func note_met(monster_id: String) -> void:
	var sid: String = str(monster_id)
	if sid == "" or bool(met_monsters.get(sid, false)):
		return
	met_monsters[sid] = true
	_save()


func note_belly(n: int) -> void:
	if n > deepest_belly:
		deepest_belly = n
		_save()


func is_swiped(id: String) -> bool:
	return bool(swiped.get(str(id), false))


func cabinet_progress() -> Vector2i:
	var total := 0
	var home_n := 0
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		total += 1
		if bool(swiped.get(str(id), false)):
			home_n += 1
	return Vector2i(home_n, total)


func is_room_unlocked(id: String) -> bool:
	return rooms_unlocked.has(id)


func shelf_page() -> int:
	return _room


func shelf_page_max() -> int:
	return _max_room


func journal_has_unread() -> bool:
	for id in met_monsters.keys():
		if not bestiary_read.has(str(id)):
			return true
	return false


func mark_bestiary_read(id: String) -> void:
	if id == "" or bestiary_read.has(id):
		return
	if bool(met_monsters.get(id, false)):
		bestiary_read.append(id)
		_save()


func trunk_has_unread() -> bool:
	for letter in lore.get("letters", []):
		if typeof(letter) != TYPE_DICTIONARY:
			continue
		var need: int = int(letter.get("unlock_pct", 100))
		var p: Vector2i = cabinet_progress()
		var pct: int = 0 if p.y <= 0 else int(round(100.0 * float(p.x) / float(p.y)))
		if pct >= need and not letters_read.has(str(letter.get("id", ""))):
			return true
	return false


func intro_pending() -> bool:
	return not intro_seen and _beat != "intro" and not (_cutscene and _cutscene.is_playing())


func cutscene_playing() -> bool:
	return _cutscene != null and _cutscene.is_playing()


func _sync_playtest_fab() -> void:
	var main = get_parent()
	if main != null and main.has_method("_sync_playtest_chrome"):
		main._sync_playtest_chrome()


func open_cabin(p_items: Dictionary, p_tex: Dictionary, p_buckets: int, walk_in: bool, kind: String = "win", new_ids: Array = [], held_ids: Array = []) -> void:
	items_by_id = p_items
	tex_by_item = p_tex
	buckets_open = p_buckets
	_homecoming_kind = kind
	_new_ids = new_ids.duplicate()
	_held_ids = held_ids.duplicate()
	visible = true
	_arriving = walk_in
	_door_busy = false
	_room_busy = false
	_door_glow_open = false
	_menu_on = true
	if not walk_in:
		_just_mounted.clear()
	_room = _start_room()
	if walk_in:
		_arrive_gen += 1
		_arrive_skip = 0
		_arrive_pending_name = ""
		_arrive_pending_room = ""
		_set_idle_hero_visible(false)
		if _rock:
			_rock.visible = false
		_show_exterior()
		_rebuild_shelves()
		_beat = "pan"
		var t := get_tree().create_timer(0.02, true, true, true)
		t.timeout.connect(_play_arrive, CONNECT_ONE_SHOT)
	else:
		show_menu("main")


func show_menu(room: String = "main") -> void:
	items_by_id = items_by_id
	visible = true
	_menu_on = true
	_arriving = false
	_ext_root.visible = false
	_int_root.visible = true
	_current_room = room if is_room_unlocked(room) else "main"
	_apply_view_frame()
	_snap_to(_current_room)
	_start_interior_loops()
	_rebuild_shelves()
	_refresh_rooms()
	_beat = "idle"
	_play_station()
	_sync_progress_doors()
	_start_rock()
	if _chair_hit:
		_chair_hit.visible = true
		_chair_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	_hide_limp_sack()
	if not nib_first_done and _dialog:
		nib_first_done = true
		_save()
		_dialog.say(["nib.first.1", "nib.first.2", "nib.first.3"])
		await _dialog.finished
	_apply_gate()


func hide_for_run() -> void:
	item_unhovered.emit()
	_silence_cabin()
	_stop_rock()
	visible = false
	_menu_on = false
	_beat = ""


func play_homecoming(kind: String, new_ids: Array, held_ids: Array) -> void:
	_homecoming_kind = kind
	_new_ids = new_ids.duplicate()
	_held_ids = held_ids.duplicate()
	open_cabin(items_by_id, tex_by_item, buckets_open, true, kind, new_ids, held_ids)


func play_intro(is_replay: bool = false) -> void:
	visible = true
	_menu_on = true
	_arriving = false
	_ext_root.visible = false
	_int_root.visible = true
	_beat = "intro"
	_story_seq += 1
	var seq: int = _story_seq
	if is_replay:
		if not is_room_unlocked("study"):
			_grant_all_rooms()
		_snap_to("study")
	else:
		_snap_to("main")
	_start_interior_loops()
	if sfx and sfx.has_method("set_combat_music"):
		sfx.set_combat_music(false)
	_play_station()
	if _cutscene:
		_cutscene.play("intro", {"replay": is_replay})
		_sync_playtest_fab()
		await _cutscene.finished
		_sync_playtest_fab()
	if seq != _story_seq or not visible:
		return
	if is_replay:
		_beat = "idle"
		_play_station()
		_snap_to("study")
		_refresh_rooms()
		return
	intro_seen = true
	_save()
	show_menu("main")


func play_key_ring() -> void:
	if key_ring_seen:
		return
	visible = true
	_menu_on = true
	_ext_root.visible = false
	_int_root.visible = true
	_beat = "keyring"
	_room_busy = true
	_snap_to("main")
	_start_interior_loops()
	var main_room = _rooms.get("main")
	var nib = main_room.nib if main_room else null
	if nib and nib.sprite_frames:
		nib.play("gasp")
	KIT.cue(sfx, &"speech.nib_gasp")
	await _wait(0.5)
	if not visible:
		return
	if nib and nib.sprite_frames:
		nib.play("walk")
	await _move_nib_x(120.0, 0.6)
	await _move_nib_x(216.0, 0.6)
	if nib and nib.sprite_frames:
		nib.play("idle")
	if _cutscene:
		_cutscene.play("keyring")
		await _cutscene.finished
	if not visible:
		return
	var ring: AnimatedSprite2D = KIT.anim_sprite(
		["props/key_ring_f0.png", "props/key_ring_f1.png", "props/key_ring_f2.png"],
		"k", 1000.0 / 120.0, true, Vector2(14, 8)
	)
	ring.z_index = 6
	if nib:
		nib.add_child(ring)
		if ring.sprite_frames:
			ring.play("k")
	KIT.cue(sfx, &"cabin.key_jingle")
	if nib and nib.sprite_frames:
		nib.play("walk")
	await _move_nib_x(352.0, 1.0)
	if nib and nib.sprite_frames:
		nib.play("idle")
	await _unlock_spot("main", "SideDoor", "hall", "", false)
	await _pan_unlocked("hall")
	await _say_key("keyring.door.hall")
	await _unlock_spot("hall", "SideDoor", "study", "", false)
	await _pan_unlocked("study")
	await _say_key("keyring.door.study")
	await _unlock_spot("study", "SideDoor", "workshop", "", false)
	await _pan_unlocked("workshop")
	await _say_key("keyring.door.workshop")
	await _unlock_spot("workshop", "Ladder", "loft", "", true)
	await _pan_unlocked("loft")
	await _say_key("keyring.door.loft")
	await _pan_unlocked("main")
	await _move_nib_x(216.0, 0.6)
	if is_instance_valid(ring):
		ring.queue_free()
	if nib and nib.sprite_frames:
		nib.play("idle")
	if _dialog:
		_dialog.say(["keyring.done"])
		await _dialog.finished
	key_ring_seen = true
	_room_busy = false
	_beat = "idle"
	_save()
	for r in _rooms.values():
		if r.has_method("request_bg"):
			r.request_bg()
			r.ensure_bg()
	_refresh_rooms()
	_apply_gate()


func play_ending() -> void:
	if ending_seen:
		return
	visible = true
	_menu_on = true
	_ext_root.visible = false
	_int_root.visible = true
	_beat = "ending"
	_story_seq += 1
	var seq: int = _story_seq
	_snap_to("main")
	_start_interior_loops()
	if _cutscene:
		_cutscene.play("ending")
		await _cutscene.finished
	if seq != _story_seq or not visible:
		return
	ending_seen = true
	_save()
	show_menu("main")
	await _play_cheer()
	if seq != _story_seq:
		return
	if _dialog:
		_dialog.say([], ["ending.continue"])
		await _dialog.finished
	if seq != _story_seq:
		return
	_play_station()
	_beat = "idle"
	await _wait(0.6)
	if seq != _story_seq:
		return
	if not drawer_hint_said:
		KIT.cue(sfx, &"cabin.drawer_unlatch")
		if _dialog:
			_dialog.say(["drawer.hint"])
			await _dialog.finished
		drawer_hint_said = true
		_save()
		_refresh_rooms()
	_apply_gate()


func _sync_progress_doors() -> void:
	var hauls: int = int(counters.get("hauls", 0))
	if not key_ring_seen and hauls < 1:
		return
	var changed := false
	for id in ROOM_ORDER:
		if not rooms_unlocked.has(id):
			rooms_unlocked.append(id)
			changed = true
	if changed:
		_save()
		_refresh_rooms()


func _grant_all_rooms() -> void:
	for id in ROOM_ORDER:
		if not rooms_unlocked.has(id):
			rooms_unlocked.append(id)
	key_ring_seen = true
	_save()
	_refresh_rooms()
	for r in _rooms.values():
		if r.has_method("request_bg"):
			r.request_bg()
			r.ensure_bg()


func close_cabin() -> void:
	item_unhovered.emit()
	_silence_cabin()
	if sfx and sfx.has_method("play_event"):
		sfx.play_event(&"cabin.close")
	visible = false
	closed.emit()


func _silence_cabin() -> void:
	if _radio and _radio.has_method("stop_static"):
		_radio.stop_static()
	if _radio:
		_radio.visible = false
	_overlay_name = ""
	if _rock:
		_rock.stop()
	if sfx and sfx.has_method("stop_cue_voices"):
		sfx.stop_cue_voices(&"cabin.rock")
	if sfx and sfx.has_method("loop_stop_all"):
		sfx.loop_stop_all(0.8)


func _home(name: String) -> Texture2D:
	if art and art.has_method("home_tex"):
		var t: Texture2D = art.home_tex(name)
		if t:
			return t
	return KIT.load_tex(name)


func _px(n: float) -> float:
	return n * PX


func _pt(x: float, y: float) -> Vector2:
	return Vector2(x, y) * PX


func _wait(sec: float, ignore_skip: bool = false) -> void:
	if sec <= 0.0:
		return
	var left: float = sec
	while left > 0.0:
		if not ignore_skip and _arriving and _arrive_skip != 0:
			return
		var step: float = minf(left, 0.04)
		await get_tree().create_timer(step, true, true, true).timeout
		left -= step


func _make_arrive_tween() -> Tween:
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.pause()
	_arrive_motion = tw
	return tw


func _await_arrive_tween(tw: Tween) -> void:
	if tw == null or not is_instance_valid(tw):
		return
	if _arrive_skip != 0:
		tw.kill()
		if _arrive_motion == tw:
			_arrive_motion = null
		return
	var done: Array = [false]
	tw.finished.connect(func() -> void:
		done[0] = true
	, CONNECT_ONE_SHOT)
	tw.play()
	while is_instance_valid(tw) and not bool(done[0]):
		if _arrive_skip != 0:
			tw.kill()
			break
		await get_tree().create_timer(0.02, true, true, true).timeout
	if _arrive_motion == tw:
		_arrive_motion = null


func _build() -> void:
	_ext_root = Control.new()
	_ext_root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
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
	_door_hit.z_index = 8
	_door_hit.pressed.connect(_on_door)
	_ext_root.add_child(_door_hit)
	_clear_button(_door_hit)

	_rooms_clip = Control.new()
	_rooms_clip.name = "RoomsClip"
	_rooms_clip.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	_rooms_clip.position = Vector2.ZERO
	_rooms_clip.size = Vector2(ROOM_W, ROOM_H)
	_rooms_clip.clip_contents = true
	_rooms_clip.mouse_filter = Control.MOUSE_FILTER_STOP
	_rooms_clip.visible = false
	add_child(_rooms_clip)
	_int_root = _rooms_clip
	_rooms_host = Control.new()
	_rooms_host.name = "RoomsHost"
	_rooms_host.position = Vector2.ZERO
	_rooms_host.size = Vector2(ROOM_W * 5.0, 1040.0)
	_rooms_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rooms_clip.add_child(_rooms_host)
	_build_rooms()
	_build_chrome()
	_build_overlays()
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.visible = false
	_fade.z_index = 20
	add_child(_fade)
	_apply_art()


func _full_bg(host: Control) -> TextureRect:
	var bg := TextureRect.new()
	bg.name = "bg"
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
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
	if _int_bg:
		_int_bg.texture = _home("cabin_interior")
	_door.texture = _home("cabin_door_closed")
	_window_glow.texture = _home("window_glow")
	_door_glow.texture = _home("door_glow")
	_lantern_glow.texture = _home("lantern_glow")
	if _fire_glow:
		_fire_glow.texture = _home("rooms/room_main_fire_glow.png")
	_lantern.sprite_frames = _frames("swing", ["lantern_swing_f0", "lantern_swing_f1", "lantern_swing_f2", "lantern_swing_f1"], 5.0, true)
	_smoke.sprite_frames = _frames("puff", ["smoke_puff_f0", "smoke_puff_f1", "smoke_puff_f2"], 1000.0 / 260.0, true)
	if _fire:
		_fire.sprite_frames = _frames("burn", ["fire_f0", "fire_f1", "fire_f2"], 1000.0 / 150.0, true)
	if _rock:
		_rock.sprite_frames = _frames("rock", ["hero_rock_f1", "hero_rock_f2", "hero_rock_f3", "hero_rock_f0"], 4.0, true)
	if _chair_empty:
		_chair_empty.texture = _home("chair_empty")
	_cat.texture = _home("cat_idle_f0")
	if _sack:
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
	item_unhovered.emit()
	_ext_root.visible = true
	_int_root.visible = false
	_door_hit.disabled = false
	_door.texture = _home("cabin_door_closed")
	_door_glow_open = false
	_ext_root.position = Vector2.ZERO
	_host_hero(_ext_root)
	_hero.flip_h = false
	_hero.visible = false
	_stop_rock()
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


func _arrive_alive(gen: int) -> bool:
	return visible and gen == _arrive_gen


func _play_arrive() -> void:
	if not visible:
		return
	var gen: int = _arrive_gen
	_arriving = true
	_door_busy = false
	_door_hit.disabled = false
	_set_idle_hero_visible(false)
	if _rock:
		_rock.visible = false
	_beat = "pan"
	_host_hero(_ext_root)
	_hero.z_index = 1
	_hero.visible = true
	_hero.flip_h = false
	_set_wide_offset(false)
	_set_hero_frame(_walk_family(true), 0)
	_place_hero(Vector2(-30, 218))
	_ext_root.position = Vector2(280, 0)
	if _homecoming_kind == "loss" and _arrive_skip == 0:
		_ext_root.position = Vector2.ZERO
		_place_hero(Vector2(140, 218))
	if _arrive_skip == 0:
		var pan := _make_arrive_tween()
		pan.set_trans(Tween.TRANS_CUBIC)
		pan.set_ease(Tween.EASE_OUT)
		pan.tween_property(_ext_root, "position", Vector2.ZERO, 0.36 if _homecoming_kind == "loss" else 0.6)
		if sfx:
			sfx.play("whoosh", -14.0, 0.9)
		await _await_arrive_tween(pan)
		if not _arrive_alive(gen):
			return
	if _arrive_skip == 0:
		_beat = "walk"
		await _walk_path()
		if not _arrive_alive(gen):
			return
	if _arrive_skip == 0:
		_place_hero(Vector2(242, 175))
		_set_hero_frame("hero_idle_blink", 0)
		_beat = "door"
		if sfx:
			sfx.play("door_open", -10.0)
		for stem in ["cabin_door_open_f0", "cabin_door_open_f1", "cabin_door_open_f2"]:
			var tex: Texture2D = _home(stem)
			if tex:
				_door.texture = tex
			await _wait(0.05)
			if _arrive_skip != 0:
				break
		_door_glow_open = true
		_beat = "enter"
		_hero.z_index = 2
		if _arrive_skip == 0:
			await _walk_hero(Vector2(242, 175), Vector2(248, 148), true, false)
			if not _arrive_alive(gen):
				return
	if _arrive_skip != 0 or _ext_root.visible:
		_beat = "fade"
		await _cut_arrive_to_interior()
		if not _arrive_alive(gen):
			return
		if _arrive_skip == 1:
			_arrive_skip = 0
	if _arrive_skip >= 2:
		await _sit_into_chair(true)
	else:
		_set_idle_hero_visible(false)
		_show_empty_chair(true)
		_hero.z_index = 4
		_hero.visible = true
		_hero.flip_h = true
		var start_in := Vector2(220, 205) if _homecoming_kind == "loss" else Vector2(388, 205)
		var int_spd: float = ARRIVE_INT_SPEED * (1.4 if _homecoming_kind == "loss" else 1.0)
		_place_hero(start_in)
		_set_hero_frame(_walk_family(true), 0)
		_beat = "int_walk"
		await _walk_hero(start_in, Vector2(70, 205), true, true, -1.0, int_spd)
		if not _arrive_alive(gen):
			return
		if _arrive_skip >= 2:
			await _sit_into_chair(true)
		else:
			_beat = "drop"
			if _homecoming_kind == "loss":
				await _play_sack_shake()
			else:
				_set_hero_frame("hero_idle_loot", 0)
				await _wait(0.5)
				_set_hero_frame("hero_idle_loot", 1)
				await _wait(0.5)
				await _play_sack_dump()
				await _play_cheer()
			if not _arrive_alive(gen):
				return
			if _homecoming_kind != "loss":
				_sack.visible = true
				_sack.texture = _home("loot_sack_dropped")
				_sack.flip_h = true
				_place_sack(Vector2(70, 205))
			await _wait(0.3)
			if _arrive_skip >= 2:
				await _sit_into_chair(true)
			else:
				_beat = "to_chair"
				await _walk_hero(Vector2(70, 205), Vector2(10, 205), false, true, -1.0, ARRIVE_INT_SPEED)
				if not _arrive_alive(gen):
					return
				_hero.flip_h = false
				_place_hero(Vector2(10, 205))
				_beat = "sit"
				await _play_sit()
				if not _arrive_alive(gen):
					return
				_settle_arrive_chair()
	if not _arrive_alive(gen):
		return
	_arriving = false
	_door_busy = false
	_door_hit.disabled = true
	_show_empty_chair(false)
	if _arrive_pending_name != "":
		var pending_n: String = _arrive_pending_name
		var pending_r: String = _arrive_pending_room
		_arrive_pending_name = ""
		_arrive_pending_room = ""
		counters.homecomings = int(counters.get("homecomings", 0)) + 1
		if _homecoming_kind == "loss":
			counters.losses = int(counters.get("losses", 0)) + 1
		else:
			counters.hauls = int(counters.get("hauls", 0)) + 1
		_sync_progress_doors()
		_save()
		_beat = "idle"
		_play_station()
		_apply_gate()
		_on_hotspot(pending_n, pending_r)
		return
	counters.homecomings = int(counters.get("homecomings", 0)) + 1
	if _homecoming_kind == "loss":
		counters.losses = int(counters.get("losses", 0)) + 1
	else:
		counters.hauls = int(counters.get("hauls", 0)) + 1
		_sync_progress_doors()
		var p: Vector2i = cabinet_progress()
		if p.y > 0:
			var pct: int = int(round(100.0 * float(p.x) / float(p.y)))
			for m in [25, 50, 75]:
				if pct >= m and not milestones_said.has(m):
					milestones_said.append(m)
					if _dialog:
						_dialog.say(["nib.milestone.%d" % m])
			if pct >= 100 and not ending_seen:
				_save()
				await play_ending()
				return
		if int(counters.hauls) >= 1 and not key_ring_seen:
			_save()
			await play_key_ring()
			return
	_save()
	_beat = "idle"
	_play_station()
	_apply_gate()


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
	var dur: float = maxf(0.8, dist / ARRIVE_WALK_SPEED)
	_hero.flip_h = false
	var tw := _make_arrive_tween()
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_method(func(t: float) -> void:
		var feet: Vector2 = _cubic(p0, p1, p2, p3, t)
		_place_hero(Vector2(feet.x - 16.0, feet.y - 30.0))
		var fi: int = int(t * dur * 8.0) % 4
		_foot(fi)
		_set_hero_frame(_walk_family(true), fi)
	, 0.0, 1.0, dur)
	await _await_arrive_tween(tw)
	if _arrive_skip == 0:
		_place_hero(Vector2(242, 175))


func _begin_walk(from: Vector2, to: Vector2, loot: bool, flipped: bool, dur: float) -> Tween:
	_hero.flip_h = flipped
	_place_hero(from)
	var tw := _make_arrive_tween()
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_method(func(t: float) -> void:
		_place_hero(from.lerp(to, t))
		var fi: int = int(t * dur * 8.0) % 4
		_foot(fi)
		_set_hero_frame(_walk_family(loot), fi)
	, 0.0, 1.0, dur)
	tw.tween_callback(func() -> void:
		_place_hero(to)
	)
	return tw


func _walk_hero(from: Vector2, to: Vector2, loot: bool, flipped: bool, dur: float = -1.0, speed: float = ARRIVE_WALK_SPEED) -> void:
	var dist: float = from.distance_to(to)
	if dur < 0.0:
		dur = maxf(0.25, dist / speed)
	var tw: Tween = _begin_walk(from, to, loot, flipped, dur)
	await _await_arrive_tween(tw)


func _play_drop() -> void:
	await _play_sack_dump()


func _play_sack_dump() -> void:
	_hero.flip_h = true
	_place_hero(Vector2(70, 205))
	_set_wide_offset(true)
	var durs := [0.12, 0.20, 0.26, 0.26, 0.30]
	for i in durs.size():
		_set_hero_frame("hero_sack_dump", i)
		if i == 2:
			_bump()
			KIT.cue(sfx, &"cabin.hero_yip")
			await _spawn_sack_pops()
		await _wait(durs[i])
	_set_wide_offset(false)


func _play_sack_shake() -> void:
	_hero.flip_h = true
	_place_hero(Vector2(70, 205))
	_set_wide_offset(true)
	var durs := [0.12, 0.16, 0.16, 0.16, 0.40, 0.50]
	for i in durs.size():
		_set_hero_frame("hero_sack_shake", i)
		if i == 0:
			KIT.cue(sfx, &"cabin.sack")
		if i == 1:
			KIT.cue(sfx, &"cabin.sack_shake")
		if i == 2:
			_spawn_moth()
		if i == 4:
			KIT.cue(sfx, &"cabin.sack_empty")
			KIT.cue(sfx, &"sting.empty")
		if i == 5:
			KIT.cue(sfx, &"cabin.hero_sigh")
		await _wait(durs[i])
	_set_wide_offset(false)
	_spawn_limp_sack()


func _sit_into_chair(fast: bool = false) -> void:
	_kill_arrive_motion()
	_set_idle_hero_visible(false)
	_hero.visible = true
	_hero.z_index = 4
	await _play_sit(fast)
	_settle_arrive_chair()


func _play_sit(fast: bool = false) -> void:
	_show_empty_chair(false)
	_hero.flip_h = false
	_hero.z_index = 4
	_hero.visible = true
	_place_hero(Vector2(10, 205))
	var durs := [0.08, 0.06, 0.06, 0.10, 0.12] if fast else [0.15, 0.12, 0.11, 0.20, 0.25]
	_set_wide_offset(false)
	for i in durs.size():
		_set_hero_frame("hero_sit", i)
		if i == 3:
			_bump()
			if sfx and sfx.has_method("play_event"):
				sfx.play_event(&"cabin.sit")
		await _wait(durs[i], true)


func _foot(fi: int) -> void:
	if fi == _step_fi:
		return
	_step_fi = fi
	if sfx and sfx.has_method("play_event"):
		sfx.play_event(&"cabin.step")


func _hook_rock() -> void:
	if _rock == null or _rock.animation_looped.is_connected(_on_rock_loop):
		return
	_rock.animation_looped.connect(_on_rock_loop)


func _on_rock_loop() -> void:
	if not visible or _rock == null or not _rock.visible or not _rock.is_playing():
		return
	if sfx and sfx.has_method("play_event"):
		sfx.play_event(&"cabin.rock")


func _bump() -> void:
	offset_top = 4.0
	offset_bottom = 4.0
	_spawn_dust_puff(_hero.position + Vector2(16, 30) * PX if _hero else Vector2(70, 235) * PX)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(0.07)
	tw.tween_callback(func() -> void:
		offset_top = 0.0
		offset_bottom = 0.0
	)


func _spawn_dust_puff(at_px: Vector2) -> void:
	var rels := ["fx/dust_puff_f0.png", "fx/dust_puff_f1.png", "fx/dust_puff_f2.png"]
	if KIT.load_tex(rels[0]) == null:
		return
	var host: Node = _rooms.get(_current_room) if _rooms.has(_current_room) else self
	if host == null:
		host = self
	var puff: AnimatedSprite2D = KIT.anim_sprite(rels, "dust", 1000.0 / 80.0, false, Vector2.ZERO)
	puff.centered = true
	puff.position = at_px
	puff.z_index = 9
	host.add_child(puff)
	if puff.sprite_frames:
		puff.play("dust")
		puff.animation_finished.connect(func() -> void:
			puff.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		puff.queue_free()


func _fade_to_interior() -> void:
	_hero.visible = false
	_set_idle_hero_visible(false)
	_fade.visible = true
	_fade.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 1.0, 0.2)
	await tw.finished
	_ext_root.visible = false
	_int_root.visible = true
	_current_room = "main"
	_snap_to("main")
	_set_idle_hero_visible(false)
	_start_interior_loops()
	_rebuild_shelves()
	var main_room = _rooms.get("main", null)
	if main_room:
		_host_hero(main_room)
	tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fade, "color:a", 0.0, 0.2)
	await tw.finished
	_fade.visible = false


func _start_interior_loops() -> void:
	if _fire.sprite_frames:
		_fire.play("burn")
	if sfx:
		if sfx.has_method("play_event"):
			sfx.play_event(&"cabin.fire_start")
		else:
			sfx.play("confirm", -12.0)
		if sfx.has_method("loop_start"):
			sfx.loop_start(&"amb.cat_purr", 1.2)


func _make_gallery_door(left: bool) -> Control:
	var wrap := Control.new()
	wrap.z_index = 6
	wrap.size = _pt(36, 88)
	wrap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var rim := ColorRect.new()
	rim.name = "rim"
	rim.set_anchors_preset(PRESET_FULL_RECT)
	rim.offset_left = -6
	rim.offset_top = -6
	rim.offset_right = 6
	rim.offset_bottom = 6
	rim.color = Color("e8c36a00")
	rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(rim)
	var pic := TextureRect.new()
	pic.name = "pic"
	pic.set_anchors_preset(PRESET_FULL_RECT)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_SCALE
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var custom: String = "gallery_door_left" if left else "gallery_door_right"
	var tex: Texture2D = _home(custom)
	if tex == null:
		tex = _home("cabin_door_closed")
		pic.flip_h = left
	pic.texture = tex
	wrap.add_child(pic)
	if left:
		_prev_door = pic
	else:
		_next_door = pic
	var hit := Button.new()
	hit.set_anchors_preset(PRESET_FULL_RECT)
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_clear_button(hit)
	hit.pressed.connect(_on_nav.bind(-1 if left else 1))
	hit.mouse_entered.connect(func() -> void:
		if wrap.modulate.a < 0.5:
			return
		pic.modulate = Color(1.18, 1.12, 0.92)
		rim.color = Color("e8c36a88")
	)
	hit.mouse_exited.connect(func() -> void:
		pic.modulate = Color.WHITE
		rim.color = Color("e8c36a00")
	)
	wrap.add_child(hit)
	return wrap


func _screen_of_bucket(b: int) -> int:
	if b <= 0:
		return 0
	return 1 + int((b - 1) / 3)


func _start_room() -> int:
	for id in _just_mounted:
		var card: Dictionary = items_by_id.get(str(id), {})
		var b: int = BucketRules.parse(card.get("bucket", 0))
		if b >= 0:
			return _screen_of_bucket(b)
	return 0


func _cubic(a: Vector2, b: Vector2, c: Vector2, d: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * (u * u * u) + b * (3.0 * u * u * t) + c * (3.0 * u * t * t) + d * (t * t * t)


func _kill_arrive_motion() -> void:
	if _arrive_motion and is_instance_valid(_arrive_motion):
		_arrive_motion.kill()
	_arrive_motion = null


func _set_idle_hero_visible(on: bool) -> void:
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	var hs = main_room.spots.get("Hero", null)
	if hs:
		hs.visible = on


func _show_empty_chair(on: bool) -> void:
	if _chair_empty == null:
		return
	if on and _chair_empty.texture == null:
		var tex: Texture2D = _home("chair_empty")
		if tex:
			_chair_empty.texture = tex
	_chair_empty.visible = on
	if _chair_hit:
		_chair_hit.visible = on
		_chair_hit.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE


func _on_empty_chair_input(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT):
		return
	if _arriving and _int_root.visible:
		_arrive_skip = maxi(_arrive_skip, 2)
		_kill_arrive_motion()
		get_viewport().set_input_as_handled()
		return
	if _busy():
		return
	_on_chair()
	get_viewport().set_input_as_handled()


func _cut_arrive_to_interior() -> void:
	_kill_arrive_motion()
	_ext_root.position = Vector2.ZERO
	if _arrive_skip != 0:
		var open_tex: Texture2D = _home("cabin_door_open_f2")
		if open_tex:
			_door.texture = open_tex
		_door_glow_open = true
		if sfx:
			sfx.play("door_open", -10.0)
	_set_idle_hero_visible(false)
	if _rock:
		_rock.visible = false
	await _fade_to_interior()
	_door_hit.disabled = true


func _settle_arrive_chair() -> void:
	_kill_arrive_motion()
	_hero.visible = false
	_show_empty_chair(false)
	_set_idle_hero_visible(false)
	if _sack and _homecoming_kind != "loss":
		_sack.visible = true
		_sack.texture = _home("loot_sack_dropped")
		_sack.flip_h = true
		_place_sack(Vector2(70, 205))
	_start_rock()
	_snap_to("main")


func _on_door() -> void:
	if _arriving and _ext_root.visible:
		_arrive_skip = maxi(_arrive_skip, 1)
		_kill_arrive_motion()
		return
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
		await _wait(0.08)
	_door_glow_open = true
	await _fade_to_interior()
	_set_idle_hero_visible(false)
	_show_empty_chair(false)
	_start_rock()
	_door_busy = false


func _collect_buckets() -> void:
	_by_bucket.clear()
	_max_bucket = 0
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		var b: int = BucketRules.parse(card.get("bucket", 0))
		if b < 0:
			continue
		_max_bucket = maxi(_max_bucket, b)
		if not _by_bucket.has(b):
			_by_bucket[b] = []
		(_by_bucket[b] as Array).append(card)
	for b2 in _by_bucket.keys():
		(_by_bucket[b2] as Array).sort_custom(func(a, c): return str(a.get("name", "")).to_lower() < str(c.get("name", "")).to_lower())
	# One wall of five biome cases. Bucket pages used to walk this room.
	_max_room = 0
	_room = 0


func _mount_cell() -> Vector2:
	var tex: Texture2D = _home("trophy_mount")
	if tex:
		return tex.get_size()
	return _pt(32, 40)


func _carve(count: int, hole: Vector2, cell: Vector2) -> Dictionary:
	var n: int = maxi(1, count)
	var best_cols := n
	var best_rows := 1
	var best_score := -1.0
	var best_s := 0.0
	var best_cell := cell
	for rows in range(1, n + 1):
		var cols: int = int(ceil(float(n) / float(rows)))
		var slot := Vector2(hole.x / float(cols), hole.y / float(rows))
		var s: float = minf(slot.x / cell.x, slot.y / cell.y) * 0.94
		var leftover: int = cols * rows - n
		var score: float = s
		score *= 1.0 - 0.28 * float(leftover) / float(maxi(1, cols * rows))
		score /= 1.0 + 0.22 * float(absi(cols - rows))
		if score > best_score:
			best_score = score
			best_s = s
			best_cols = cols
			best_rows = rows
			best_cell = slot
	if best_s < 0.35:
		best_s = 0.35
	var grid := Vector2(best_cell.x * float(best_cols), best_cell.y * float(best_rows))
	var origin := Vector2((hole.x - grid.x) * 0.5, (hole.y - grid.y) * 0.5)
	return {
		"cols": best_cols,
		"rows": best_rows,
		"scale": best_s,
		"origin": origin,
		"slot": best_cell,
		"size": cell * best_s,
	}


func _place_nav() -> void:
	var hall = _rooms.get("hall", null)
	if hall and hall.has_method("refresh_locks"):
		hall.refresh_locks()


func _rebuild_pips() -> void:
	pass


func _on_pip(dest: int) -> void:
	_on_nav(dest - _room)


func _on_nav(delta: int) -> void:
	if delta == 0 or _room_busy or _arriving or _door_busy or _pan_busy:
		return
	if _current_room != "hall" or not _int_root.visible:
		return
	var nxt: int = _room + delta
	if nxt < 0:
		pan_to("main")
		return
	if nxt > _max_room:
		if is_room_unlocked("study"):
			pan_to("study")
		else:
			_bump()
			KIT.cue(sfx, &"cabin.locked")
			say_bubble("cabin.locked")
		return
	_change_room(nxt)


func _change_room(nxt: int) -> void:
	if nxt == _room:
		return
	_room_busy = true
	item_unhovered.emit()
	var going_next: bool = nxt > _room
	await _wipe_pan(going_next, nxt)
	_beat = "idle"
	_room_busy = false
	_place_nav()


func _nudge_door(pic: TextureRect) -> void:
	if pic == null:
		return
	if sfx:
		sfx.play("door_open", -12.0)
	if _home("gallery_door_right") != null:
		pic.modulate = Color(1.25, 1.18, 0.9)
		await _wait(0.12)
		pic.modulate = Color.WHITE
		return
	for stem in ["cabin_door_open_f0", "cabin_door_open_f1", "cabin_door_open_f2"]:
		var tex: Texture2D = _home(stem)
		if tex:
			pic.texture = tex
		await _wait(0.05)
	pic.texture = _home("cabin_door_closed")
	if pic == _prev_door:
		pic.flip_h = true


func _wipe_pan(going_next: bool, nxt: int) -> void:
	var off: float = _hole.size.x * (1.0 if going_next else -1.0)
	if _shelf_fade:
		_shelf_fade.visible = true
		_shelf_fade.color.a = 0.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_parallel(true)
	tw.tween_property(_shelf_host, "position:x", -off, 0.25)
	if _shelf_fade:
		tw.tween_property(_shelf_fade, "color:a", 0.55, 0.25)
	await tw.finished
	if not visible:
		return
	_room = nxt
	_rebuild_shelves()
	_shelf_host.position.x = off
	tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_parallel(true)
	tw.tween_property(_shelf_host, "position:x", 0.0, 0.25)
	if _shelf_fade:
		tw.tween_property(_shelf_fade, "color:a", 0.0, 0.25)
	await tw.finished
	if _shelf_fade:
		_shelf_fade.visible = false
	_shelf_host.position.x = 0.0


func _play_stand() -> void:
	_stop_rock()
	_show_empty_chair(false)
	_host_hero(_int_root)
	_hero.visible = true
	_hero.z_index = 4
	_hero.flip_h = false
	_set_wide_offset(false)
	_place_hero(Vector2(10, 205))
	var durs := [0.06, 0.05, 0.05, 0.06, 0.08]
	for i in durs.size():
		_set_hero_frame("hero_sit", 4 - i)
		await _wait(durs[i])
	_show_empty_chair(true)
	_set_hero_frame("hero_walk", 0)
	await _play_chair_settle()


func _play_chair_settle() -> void:
	if _chair_empty == null:
		return
	var rels := ["chair_settle_f0", "chair_settle_f1", "chair_settle_f2", "chair_settle_f3"]
	if _home(rels[0]) == null:
		return
	_chair_empty.visible = true
	for stem in rels:
		var tex: Texture2D = _home(str(stem))
		if tex:
			_chair_empty.texture = tex
		await _wait(0.08)
	var rest: Texture2D = _home("chair_empty")
	if rest:
		_chair_empty.texture = rest


func _fade_shelf(out: bool) -> void:
	if _shelf_fade == null:
		return
	_shelf_fade.visible = true
	_shelf_fade.color.a = 0.0 if out else 1.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_shelf_fade, "color:a", 1.0 if out else 0.0, 0.16)
	await tw.finished
	if not out:
		_shelf_fade.visible = false


func _rebuild_shelves() -> void:
	if _shelf_host == null:
		return
	for c in _shelf_host.get_children():
		_shelf_host.remove_child(c)
		c.queue_free()
	_glints.clear()
	_case_columns.clear()
	_case_clips.clear()
	_collect_buckets()
	_shelf_host.size = _hole.size if _hole else _pt(260, 160)
	if _cordon:
		_cordon.visible = false
	_fill_biome_cases()
	_rebuild_pips()
	_place_nav()
	if not _bank_busy:
		call_deferred("_offer_bank_sequence")


func _biome_rules() -> Dictionary:
	if _campaign_rules.is_empty():
		_campaign_rules = CampaignShell.read_json(CampaignShell.DATA_PATH)
	return _campaign_rules


func _live_pool(card: Dictionary) -> String:
	if str(card.get("status", "live")) in ["retired", "hold"]:
		return ""
	if BucketRules.is_token(card.get("bucket", 0)):
		return ""
	var b: int = BucketRules.parse(card.get("bucket", 0))
	if b < 0:
		return ""
	return BiomeCabinets.pool_for_bucket(_biome_rules(), b)


func _group_cards_by_pool() -> Dictionary:
	var grouped := {}
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		var pool := _live_pool(card)
		if pool == "":
			continue
		if not grouped.has(pool):
			grouped[pool] = []
		(grouped[pool] as Array).append(card)
	return grouped


func _shown_count(pool_id: String) -> int:
	var n := 0
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if _live_pool(card) != pool_id:
			continue
		var sid := str(card.get("id", id))
		if bool(swiped.get(sid, false)) and not _bank_hold.has(sid):
			n += 1
	return n


func _biome_progress_lines() -> Array:
	var rules := _biome_rules()
	var quota := BiomeCabinets.quota_of(rules)
	var grouped := _group_cards_by_pool()
	var lines: Array = []
	for raw in BiomeCabinets.resolved_cases(rules):
		var spec: Dictionary = raw
		var pool := str(spec.get("id", ""))
		var cards: Array = grouped.get(pool, [])
		lines.append(BiomeCabinets.progress_text(_shown_count(pool), cards.size(), quota))
	return lines


func _fill_biome_cases() -> void:
	var rules := _biome_rules()
	var cases: Array = BiomeCabinets.resolved_cases(rules)
	var quota := BiomeCabinets.quota_of(rules)
	var hole: Vector2 = _shelf_host.size
	var n: int = maxi(1, cases.size())
	var gap := 8.0
	var case_w: float = (hole.x - gap * float(n - 1)) / float(n)
	var grouped := _group_cards_by_pool()
	var order: Array = swiped.keys()
	for i in cases.size():
		var spec: Dictionary = cases[i]
		var pool_id := str(spec.get("id", ""))
		var cards: Array = grouped.get(pool_id, [])
		var mounted: Array = BiomeCabinets.order_mounts(cards, order)
		_build_biome_case(spec, mounted, quota, float(i) * (case_w + gap), case_w, hole.y)


func _build_biome_case(spec: Dictionary, cards: Array, quota: int, x: float, case_w: float, case_h: float) -> void:
	var pool_id := str(spec.get("id", ""))
	var root := Control.new()
	root.name = "Case_%s" % pool_id
	root.position = Vector2(x, 0)
	root.size = Vector2(case_w, case_h)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tint := Color(str(spec.get("tint", "241812")))
	var accent := Color(str(spec.get("accent", "e8c36a")))
	var style := StyleBoxFlat.new()
	style.bg_color = tint
	style.border_color = accent
	style.set_border_width_all(6)
	style.set_corner_radius_all(0)
	var frame := Panel.new()
	frame.name = "Frame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", style)
	root.add_child(frame)
	var frame_tex: Texture2D = _home(str(spec.get("frame", "")))
	if frame_tex:
		var case_art := TextureRect.new()
		case_art.name = "CaseArt"
		case_art.texture = frame_tex
		case_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		case_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		case_art.stretch_mode = TextureRect.STRETCH_SCALE
		case_art.set_anchors_preset(Control.PRESET_FULL_RECT)
		case_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(case_art)
	var shown := 0
	for raw in cards:
		var shown_id := str((raw as Dictionary).get("id", ""))
		if bool(swiped.get(shown_id, false)) and not _bank_hold.has(shown_id):
			shown += 1
	var name_lab := KIT.raw_label(str(spec.get("name", pool_id)), 22, KIT.TITLE_CREAM, true)
	name_lab.max_lines = 2
	name_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lab.position = Vector2(8, 8)
	name_lab.size = Vector2(case_w - 16.0, 56)
	name_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(name_lab)
	name_lab.fit()
	var count_text := BiomeCabinets.progress_text(shown, cards.size(), quota)
	var count_col := Color("ffd84a") if shown >= quota else KIT.TITLE_CREAM
	var count_lab := KIT.raw_label(count_text, 22, count_col, false)
	count_lab.max_lines = 1
	count_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lab.position = Vector2(8, 64)
	count_lab.size = Vector2(case_w - 16.0, 28)
	count_lab.mouse_filter = Control.MOUSE_FILTER_STOP
	count_lab.mouse_entered.connect(_on_case_hover.bind(pool_id, count_lab))
	count_lab.mouse_exited.connect(hide_hover_tag)
	root.add_child(count_lab)
	count_lab.fit()
	var pip := ColorRect.new()
	pip.name = "GatePip"
	pip.color = Color("ffd84a")
	pip.position = Vector2(16, 96)
	pip.size = Vector2(case_w - 32.0, 4)
	pip.visible = shown >= quota
	pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pip)
	var clip := Control.new()
	clip.name = "Clip"
	clip.position = Vector2(4, 108)
	clip.size = Vector2(case_w - 8.0, maxf(40.0, case_h - 116.0))
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(clip)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_bind_case_scroll(root, pool_id)
	_bind_case_scroll(clip, pool_id)
	_bind_case_scroll(count_lab, pool_id)
	var column := Control.new()
	column.name = "Column"
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(column)
	_case_clips[pool_id] = clip
	_case_columns[pool_id] = column
	var cell: Vector2 = _mount_cell()
	var s: float = 0.62
	if cell.x > 1.0:
		s = minf(0.62, (clip.size.x - 8.0) / cell.x)
	var msize: Vector2 = cell * s
	var gap_y := 6.0
	var y := 4.0
	var x0: float = maxf(0.0, (clip.size.x - msize.x) * 0.5)
	var collected_slots := 0
	for i in cards.size():
		var card: Dictionary = cards[i]
		var slot := _mount_slot(card, Vector2(x0, y), msize, false)
		_bind_case_scroll(slot, pool_id)
		column.add_child(slot)
		y += msize.y
		var sid := str(card.get("id", ""))
		if bool(swiped.get(sid, false)) and not _bank_hold.has(sid):
			collected_slots += 1
			if collected_slots == quota:
				var gate := ColorRect.new()
				gate.name = "GateLine"
				gate.color = Color("ffd84a")
				gate.position = Vector2(8, y + 2)
				gate.size = Vector2(clip.size.x - 16.0, 3)
				gate.mouse_filter = Control.MOUSE_FILTER_IGNORE
				column.add_child(gate)
				y += 8.0
		y += gap_y
	column.size = Vector2(clip.size.x, maxf(y, clip.size.y))
	column.custom_minimum_size = column.size
	var view: float = clip.size.y
	var max_s: float = maxf(0.0, column.size.y - view)
	var cur: float = clampf(float(_case_scroll.get(pool_id, 0.0)), 0.0, max_s)
	if _bank_fresh != "":
		var fresh_node := column.find_child("Mount_%s" % _bank_fresh, false, false)
		if fresh_node is Control:
			var fy: float = (fresh_node as Control).position.y
			var fh: float = (fresh_node as Control).size.y
			if fy < cur:
				cur = fy
			elif fy + fh > cur + view:
				cur = fy + fh - view
			cur = clampf(cur, 0.0, max_s)
	_case_scroll[pool_id] = cur
	column.position = Vector2(0, -cur)
	_shelf_host.add_child(root)


func _bind_case_scroll(node: Control, pool_id: String) -> void:
	node.gui_input.connect(_on_case_wheel.bind(node, pool_id))


func _on_case_wheel(event: InputEvent, node: Control, pool_id: String) -> void:
	if not (event is InputEventMouseButton) or not (event as InputEventMouseButton).pressed:
		return
	var btn := event as InputEventMouseButton
	var dir := 0
	if btn.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		dir = 1
	elif btn.button_index == MOUSE_BUTTON_WHEEL_UP:
		dir = -1
	else:
		return
	_scroll_case(pool_id, dir)
	node.accept_event()


func _scroll_case(pool_id: String, dir: int) -> void:
	var clip_v: Variant = _case_clips.get(pool_id, null)
	var col_v: Variant = _case_columns.get(pool_id, null)
	if not (clip_v is Control) or not (col_v is Control):
		return
	var clip := clip_v as Control
	var col := col_v as Control
	var max_s: float = maxf(0.0, col.size.y - clip.size.y)
	var cur: float = clampf(float(_case_scroll.get(pool_id, 0.0)) + float(dir) * 72.0, 0.0, max_s)
	_case_scroll[pool_id] = cur
	col.position.y = -cur


func _on_case_hover(pool_id: String, hit: Control) -> void:
	var total := 0
	var got := _shown_count(pool_id)
	for id in items_by_id.keys():
		if _live_pool(items_by_id[id]) == pool_id:
			total += 1
	var key := "cabin.hall.full" if got >= total and total > 0 else "cabin.hall.gauge"
	show_hover_tag(key, hit, {"n": got, "total": total})


func _offer_bank_sequence() -> void:
	if _bank_busy or _bank_hold.is_empty():
		return
	if _current_room != "hall" or _int_root == null or not _int_root.visible:
		return
	_bank_busy = true
	_play_bank_sequence()


func _play_bank_sequence() -> void:
	# S7 / C4: bag smoke → rays → per-item arcs, then S3 map-piece handoff if present.
	# FX only on the extract bank path — never Push/Nib interrupt, cheats, or death.
	var quota := BiomeCabinets.quota_of(_biome_rules())
	var pending: Array = []
	var pools := {}
	for raw in _bank_hold.keys():
		var held_id := str(raw)
		pending.append(held_id)
		pools[held_id] = _live_pool(items_by_id.get(held_id, {}))
	var seq: Array = BiomeCabinets.bank_sequence(pending, pools)
	_bank_played = true
	var from_push_block := _bank_is_push_block()
	var play_fx := (not from_push_block) and (not seq.is_empty())
	var pool_adds: Dictionary = {}
	var crossed: Array = []
	if play_fx:
		await _bank_fx_bag_smoke()
		if not is_inside_tree():
			_bank_busy = false
			return
		await _bank_fx_rays()
		if not is_inside_tree():
			_bank_busy = false
			return
	for raw_step in seq:
		if not is_inside_tree():
			_bank_busy = false
			return
		var step: Dictionary = raw_step
		var step_id := str(step.get("id", ""))
		var pool := str(step.get("pool", ""))
		var before := _shown_count(pool)
		if play_fx:
			await _bank_fx_arc_to_mount(step_id, pool)
			if not is_inside_tree():
				_bank_busy = false
				return
		_bank_hold.erase(step_id)
		_bank_fresh = step_id
		_rebuild_shelves()
		pool_adds[pool] = int(pool_adds.get(pool, 0)) + 1
		if not from_push_block and BiomeCabinets.crossed_gate(before, _shown_count(pool), quota) \
				and not crossed.has(pool):
			crossed.append(pool)
		await _wait(0.25 if play_fx else 0.34, true)
	_bank_fresh = ""
	if is_inside_tree():
		_rebuild_shelves()
	if play_fx and is_inside_tree():
		await _bank_fx_loud_count(pool_adds, quota)
	# S3 handoff: ceremony after FX when a cabinet crosses 5/5 (no Nib in this slice).
	if not from_push_block and not crossed.is_empty() and is_inside_tree():
		for pool_id in crossed:
			cabinet_gate_crossed.emit(str(pool_id))
			var beat: Variant = _bank_map_piece_beat()
			if beat != null and beat.has_method("play"):
				await beat.play(str(pool_id))
	_bank_busy = false


func _bank_is_push_block() -> bool:
	# S2/S3 set this before interrupt banks; absent on tips without that wire.
	if "_bank_from_push_block" in self:
		return bool(get("_bank_from_push_block"))
	return false


func _bank_map_piece_beat() -> Variant:
	if "_map_piece_beat" in self:
		return get("_map_piece_beat")
	return null


func _bank_fx_host() -> Control:
	if _hole != null and is_instance_valid(_hole):
		return _hole
	if _shelf_host != null and is_instance_valid(_shelf_host):
		return _shelf_host
	return self


func _bank_bag_origin_local(host: Control) -> Vector2:
	if host == null:
		return Vector2.ZERO
	return Vector2(host.size.x * 0.5, host.size.y * 0.78)


func _bank_fx_bag_smoke() -> void:
	var host: Control = _bank_fx_host()
	var origin: Vector2 = _bank_bag_origin_local(host)
	KIT.cue(sfx, &"cabin.sack")
	var smoke_sf := _frames(
		"bag_smoke",
		["smoke_puff_f0", "smoke_puff_f1", "smoke_puff_f2"],
		1000.0 / 140.0,
		false
	)
	if smoke_sf.get_frame_count("bag_smoke") == 0:
		var dust := ["fx/dust_puff_f0.png", "fx/dust_puff_f1.png", "fx/dust_puff_f2.png"]
		if KIT.load_tex(dust[0]) != null:
			var puff: AnimatedSprite2D = KIT.anim_sprite(dust, "dust", 1000.0 / 90.0, false, Vector2.ZERO)
			puff.centered = true
			puff.position = origin
			puff.z_index = 12
			host.add_child(puff)
			if puff.sprite_frames and puff.sprite_frames.get_frame_count("dust") > 0:
				puff.play("dust")
				await puff.animation_finished
			if is_instance_valid(puff):
				puff.queue_free()
			return
		# Code-only fallback when no puff art is available.
		var blob := ColorRect.new()
		blob.color = Color("c8b89a", 0.55)
		blob.size = Vector2(96, 72)
		blob.pivot_offset = blob.size * 0.5
		blob.position = origin - blob.pivot_offset
		blob.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blob.z_index = 12
		host.add_child(blob)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_parallel(true)
		tw.tween_property(blob, "scale", Vector2(1.6, 1.6), 0.28)
		tw.tween_property(blob, "modulate:a", 0.0, 0.28)
		await tw.finished
		if is_instance_valid(blob):
			blob.queue_free()
		return
	var smoke := AnimatedSprite2D.new()
	smoke.centered = true
	smoke.position = origin
	smoke.scale = Vector2(1.35, 1.35)
	smoke.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	smoke.sprite_frames = smoke_sf
	smoke.z_index = 12
	host.add_child(smoke)
	smoke.play("bag_smoke")
	await smoke.animation_finished
	if is_instance_valid(smoke):
		smoke.queue_free()


func _bank_fx_rays() -> void:
	var host: Control = _bank_fx_host()
	var origin: Vector2 = _bank_bag_origin_local(host)
	KIT.cue(sfx, &"cabin.item_burst")
	var rays: Array = []
	var n := 8
	for i in n:
		var ray := ColorRect.new()
		ray.color = Color("ffd84a", 0.72)
		ray.size = Vector2(5.0, 140.0)
		ray.pivot_offset = Vector2(2.5, 0.0)
		ray.position = origin - ray.pivot_offset
		ray.rotation = TAU * float(i) / float(n) + 0.12
		ray.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ray.z_index = 11
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		ray.material = mat
		host.add_child(ray)
		rays.append(ray)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_parallel(true)
		tw.tween_property(ray, "size:y", 220.0, 0.22)
		tw.tween_property(ray, "modulate:a", 0.0, 0.32).set_delay(0.08)
	# Soft gold flash behind the rays.
	var flash := ColorRect.new()
	flash.color = Color("fff3d6", 0.35)
	flash.size = Vector2(160, 160)
	flash.pivot_offset = flash.size * 0.5
	flash.position = origin - flash.pivot_offset
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 10
	host.add_child(flash)
	var ftw := create_tween()
	ftw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	ftw.set_parallel(true)
	ftw.tween_property(flash, "scale", Vector2(1.8, 1.8), 0.3)
	ftw.tween_property(flash, "modulate:a", 0.0, 0.3)
	await _wait(0.34, true)
	for r in rays:
		if is_instance_valid(r):
			(r as Node).queue_free()
	if is_instance_valid(flash):
		flash.queue_free()


func _bank_mount_global_center(item_id: String, pool_id: String) -> Vector2:
	var col_v: Variant = _case_columns.get(pool_id, null)
	if col_v is Control:
		var mount: Node = (col_v as Control).find_child("Mount_%s" % item_id, false, false)
		if mount is Control:
			var gr: Rect2 = (mount as Control).get_global_rect()
			return gr.position + gr.size * 0.45
	if _shelf_host != null:
		var case_n: Node = _shelf_host.get_node_or_null("Case_%s" % pool_id)
		if case_n is Control:
			var cr: Rect2 = (case_n as Control).get_global_rect()
			return cr.position + Vector2(cr.size.x * 0.5, cr.size.y * 0.55)
	var host: Control = _bank_fx_host()
	var hr: Rect2 = host.get_global_rect()
	return hr.position + hr.size * 0.5


func _bank_fx_arc_to_mount(item_id: String, pool_id: String) -> void:
	var host: Control = _bank_fx_host()
	var from_local: Vector2 = _bank_bag_origin_local(host)
	var to_global: Vector2 = _bank_mount_global_center(item_id, pool_id)
	var to_local: Vector2 = host.get_global_transform_with_canvas().affine_inverse() * to_global
	var tex: Texture2D = tex_by_item.get(item_id, null)
	if tex == null and art != null:
		tex = art.item_tex(item_id)
	var spr := Sprite2D.new()
	spr.centered = true
	spr.position = from_local
	spr.z_index = 14
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if tex != null:
		spr.texture = tex
		spr.scale = _item_spr_scale(tex, 0.85)
	else:
		# Tiny stand-in chip when the item texture is missing.
		var chip := ColorRect.new()
		chip.color = Color("ffd84a")
		chip.size = Vector2(28, 28)
		chip.position = Vector2(-14, -14)
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spr.add_child(chip)
	host.add_child(spr)
	_attach_fly_fx(spr)
	KIT.cue(sfx, &"cabin.item_whoosh")
	var peak: Vector2 = Vector2(
		(from_local.x + to_local.x) * 0.5,
		minf(from_local.y, to_local.y) - 64.0
	)
	var start_scale: Vector2 = spr.scale
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(t: float) -> void:
		if is_instance_valid(spr):
			spr.position = _quad_bez(from_local, peak, to_local, t)
	, 0.0, 1.0, 0.38)
	tw.parallel().tween_property(spr, "scale", start_scale * 1.2, 0.2)
	tw.parallel().tween_property(spr, "scale", start_scale * 0.95, 0.18).set_delay(0.2)
	await tw.finished
	KIT.cue(sfx, &"cabin.item_pop")
	if is_instance_valid(spr):
		spr.queue_free()


func _bank_fx_loud_count(pool_adds: Dictionary, quota: int) -> void:
	if pool_adds.is_empty() or _shelf_host == null:
		return
	var best_pool := ""
	var best_n := 0
	for raw_pool in pool_adds.keys():
		var p := str(raw_pool)
		var n: int = int(pool_adds[p])
		if n > best_n:
			best_n = n
			best_pool = p
	if best_pool == "" or best_n <= 0:
		return
	var case_n: Node = _shelf_host.get_node_or_null("Case_%s" % best_pool)
	if not (case_n is Control):
		return
	var case_c := case_n as Control
	var shown := _shown_count(best_pool)
	var total := 0
	for id in items_by_id.keys():
		if _live_pool(items_by_id[id]) == best_pool:
			total += 1
	var gauge := BiomeCabinets.progress_text(shown, total, quota)
	var lab := Label.new()
	lab.text = "+%d  %s" % [best_n, gauge]
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 36)
	lab.add_theme_color_override("font_color", Color("ffd84a"))
	lab.add_theme_color_override("font_outline_color", Color("1c120c"))
	lab.add_theme_constant_override("outline_size", 6)
	lab.size = Vector2(case_c.size.x, 48)
	lab.position = Vector2(0, case_c.size.y * 0.28)
	lab.pivot_offset = lab.size * 0.5
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 16
	lab.scale = Vector2(0.4, 0.4)
	case_c.add_child(lab)
	KIT.cue(sfx, &"cabin.shelf_chime")
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(lab, "scale", Vector2(1.15, 1.15), 0.22)
	tw.tween_property(lab, "scale", Vector2.ONE, 0.12)
	tw.tween_interval(0.55)
	tw.tween_property(lab, "modulate:a", 0.0, 0.2)
	await tw.finished
	if is_instance_valid(lab):
		lab.queue_free()


func _clear_bank_anim() -> void:
	_bank_hold.clear()
	_bank_fresh = ""
	_bank_busy = false
	_bank_played = false
	_case_scroll.clear()


func _paint_cordon(locked: bool, origin: Vector2, grid: Vector2) -> void:
	if _cordon == null:
		return
	_cordon.visible = locked
	_cordon.set_anchors_preset(PRESET_TOP_LEFT)
	if not locked:
		return
	var cover: Texture2D = _home("gallery_cordon")
	if cover != null:
		_cordon.texture = cover
		_cordon.modulate = Color(1, 1, 1, 0.82)
		_cordon.position = origin
		_cordon.size = grid
		_cordon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return
	_cordon.texture = _home("shelf_locked")
	_cordon.modulate = Color(1, 1, 1, 0.92)
	_cordon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var native: Vector2 = _cordon.texture.get_size() if _cordon.texture else Vector2(512, 160)
	var h: float = minf(native.y, maxf(grid.y * 0.38, 72.0))
	var w: float = minf(grid.x * 0.92, native.x * (h / native.y))
	_cordon.size = Vector2(w, h)
	_cordon.position = origin + Vector2((grid.x - w) * 0.5, grid.y * 0.62)


func _mount_stem(is_swiped: bool, is_seen: bool) -> String:
	if is_swiped:
		return "trophy_mount"
	if is_seen:
		return "trophy_mount_seen" if _home("trophy_mount_seen") else "trophy_mount"
	return "trophy_mount_unseen" if _home("trophy_mount_unseen") else "trophy_mount"


func _mount_slot(card: Dictionary, pos: Vector2, msize: Vector2, room_locked: bool) -> Control:
	var wrap := Control.new()
	wrap.position = pos
	wrap.size = msize
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	var id: String = str(card.get("id", ""))
	wrap.name = "Mount_%s" % id
	var is_swiped: bool = bool(swiped.get(id, false)) and not room_locked and not _bank_hold.has(id)
	var is_seen: bool = (bool(seen.get(id, false)) or is_swiped or _bank_hold.has(id)) and not room_locked
	var fresh: bool = false
	if is_swiped and _bank_fresh == id:
		fresh = true
	elif is_swiped and _bank_fresh == "" and _bank_hold.is_empty() and not _bank_played and _just_mounted.has(id):
		fresh = true
	var stem: String = _mount_stem(is_swiped, is_seen)
	var rest_tex: Texture2D = _home(stem)
	if rest_tex == null:
		rest_tex = _home("trophy_mount")
	var hover_stem: String = "trophy_mount_hover"
	if is_seen and not is_swiped:
		hover_stem = "trophy_mount_seen_hover" if _home("trophy_mount_seen_hover") else stem
	elif not is_seen:
		hover_stem = stem
	var hover_tex: Texture2D = _home(hover_stem)
	if hover_tex == null:
		hover_tex = rest_tex
	var mount := TextureRect.new()
	mount.name = "mount"
	mount.texture = rest_tex
	mount.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mount.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mount.stretch_mode = TextureRect.STRETCH_SCALE
	mount.set_anchors_preset(PRESET_FULL_RECT)
	mount.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not is_swiped and not is_seen:
		mount.modulate = Color(0.62, 0.55, 0.48)
	wrap.add_child(mount)
	if is_seen and not is_swiped and _home("trophy_mount_seen") == null:
		var dull := ColorRect.new()
		var plate: Rect2 = _plate_rect(msize)
		dull.position = plate.position + Vector2(4, 2)
		dull.size = plate.size - Vector2(8, 4)
		dull.color = Color("5a3a24")
		dull.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(dull)
	var well: Rect2 = _well_rect(msize)
	var item := TextureRect.new()
	item.position = well.position
	item.size = well.size
	item.pivot_offset = well.size * 0.5
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex: Texture2D = tex_by_item.get(id, null)
	if tex == null and art != null:
		tex = art.item_tex(id)
	item.texture = tex
	if is_swiped or is_seen:
		item.modulate = Color.WHITE
	else:
		item.modulate = Color(0.09, 0.07, 0.06, 1.0)
	wrap.add_child(item)
	# Seen-but-not-owned: grey frame over the 16x16 recess (item_seen_overlay).
	if is_seen and not is_swiped:
		var seen_ov: Texture2D = _home("item_seen_overlay")
		if seen_ov:
			var ov := TextureRect.new()
			ov.name = "SeenOverlay"
			ov.texture = seen_ov
			ov.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			ov.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ov.stretch_mode = TextureRect.STRETCH_SCALE
			ov.position = well.position
			ov.size = well.size
			ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ov.z_index = 2
			wrap.add_child(ov)
	if fresh:
		item.scale = Vector2.ZERO
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(item, "scale", Vector2(1.15, 1.15), 0.12)
		tw.tween_property(item, "scale", Vector2.ONE, 0.13)
		_play_burst(wrap)
		if bool(new_unseen.get(id, false)):
			_play_new_burst(wrap)
	if is_seen:
		var plate: Rect2 = _plate_rect(msize)
		var font_n: int = clampi(int(msize.x * 0.13), 17, 24)
		var lab: FitLabelBox = FitLabelBox.make()
		lab.show_frame = false
		lab.padding = 0
		lab.max_font_size = font_n
		lab.min_font_size = 12
		lab.set_plain(str(card.get("name", id)))
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.size = Vector2(msize.x - 8.0, maxf(plate.size.y + 10.0, float(font_n) * 2.2))
		lab.position = Vector2(4.0, msize.y - lab.size.y + 2.0)
		lab.font_color = Color("1c120c")
		lab.set_outline(Color("f3e6d0"), 2)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var glint := AnimatedSprite2D.new()
		glint.centered = false
		glint.position = Vector2((msize.x - 64.0) * 0.5, plate.position.y)
		glint.scale = Vector2(msize.x / _mount_cell().x, msize.x / _mount_cell().x)
		glint.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glint.material = mat
		glint.sprite_frames = _frames("glint", ["plaque_glint_f0", "plaque_glint_f1", "plaque_glint_f2", "plaque_glint_f3"], 4.0 / 1.2, true)
		wrap.add_child(glint)
		wrap.add_child(lab)
		if is_swiped:
			glint.play("glint")
		else:
			glint.visible = false
		_glints.append({"id": id, "node": glint, "swiped": is_swiped})
		wrap.mouse_entered.connect(func() -> void:
			_hover_id = id
			if hover_tex:
				mount.texture = hover_tex
			if is_swiped:
				_set_glint(id, true)
			item_hovered.emit(id, wrap)
		)
		wrap.mouse_exited.connect(func() -> void:
			if _hover_id == id:
				_hover_id = ""
			mount.texture = rest_tex
			_set_glint(id, false)
			item_unhovered.emit()
		)
		wrap.gui_input.connect(func(event: InputEvent) -> void:
			if not PLAYTEST_FLAG.on():
				return
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				comment_wanted.emit(id)
				wrap.accept_event()
		)
	else:
		wrap.mouse_entered.connect(func() -> void:
			show_hover_tag("cabin.tip.locked", wrap)
		)
		wrap.mouse_exited.connect(func() -> void:
			hide_hover_tag()
		)
	if bool(new_unseen.get(id, false)) and is_swiped:
		var glow := AnimatedSprite2D.new()
		glow.centered = false
		glow.position = Vector2(-16, -16)
		glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		glow.sprite_frames = _frames("ng", ["fx/shelf_new_glow_f0", "fx/shelf_new_glow_f1", "fx/shelf_new_glow_f2", "fx/shelf_new_glow_f3"], 1000.0 / 160.0, true)
		wrap.add_child(glow)
		if glow.sprite_frames:
			glow.play("ng")
		var tag := TextureRect.new()
		tag.texture = _home("fx/new_tag.png")
		tag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tag.position = Vector2(msize.x - 8.0, -8.0)
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(tag)
	return wrap


func _well_rect(mount_size: Vector2) -> Rect2:
	var cell: Vector2 = _mount_cell()
	var s: float = mount_size.x / cell.x
	if cell.x >= 150.0:
		return Rect2(Vector2(48, 40) * s, Vector2(64, 64) * s)
	return Rect2(Vector2(32, 32) * s, Vector2(64, 64) * s)


func _plate_rect(mount_size: Vector2) -> Rect2:
	var cell: Vector2 = _mount_cell()
	var s: float = mount_size.x / cell.x
	var native_h: float = 40.0 if cell.x < 150.0 else 56.0
	var plate_n: float = 8.0 if cell.x < 150.0 else 14.0
	var h: float = cell.y * s
	var plate_h: float = plate_n / native_h * h
	return Rect2(0.0, h - plate_h, mount_size.x, plate_h)


func _play_burst(wrap: Control) -> void:
	var burst := AnimatedSprite2D.new()
	burst.centered = false
	var s: float = wrap.size.x / _mount_cell().x
	burst.position = Vector2(-8, -4) * 4.0 * s
	burst.scale = Vector2(s, s)
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
	if sfx and sfx.has_method("play_event"):
		sfx.play_event(&"cabin.trophy")
	burst.animation_finished.connect(func() -> void:
		burst.queue_free()
	)


func _play_new_burst(wrap: Control) -> void:
	var rels := [
		"fx/new_burst_f0.png", "fx/new_burst_f1.png", "fx/new_burst_f2.png",
		"fx/new_burst_f3.png", "fx/new_burst_f4.png", "fx/new_burst_f5.png",
	]
	if KIT.load_tex(rels[0]) == null:
		return
	var burst: AnimatedSprite2D = KIT.anim_sprite(rels, "nb", 1000.0 / 60.0, false, Vector2.ZERO)
	burst.centered = true
	var s: float = wrap.size.x / _mount_cell().x
	# Centre (24,24) native on 48x48 canvas → mount recess centre.
	burst.position = Vector2(wrap.size.x * 0.5, wrap.size.y * 0.4)
	burst.scale = Vector2(s, s)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	burst.material = mat
	burst.z_index = 6
	wrap.add_child(burst)
	if burst.sprite_frames:
		burst.play("nb")
		burst.animation_finished.connect(func() -> void:
			burst.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		burst.queue_free()


func _set_glint(id: String, hovered: bool) -> void:
	for g in _glints:
		if str(g.get("id", "")) != id:
			continue
		var node: AnimatedSprite2D = g.get("node")
		if node == null or node.sprite_frames == null:
			continue
		if not bool(g.get("swiped", false)):
			node.stop()
			node.visible = false
			continue
		node.visible = true
		if hovered:
			node.sprite_frames.set_animation_speed("glint", 4.0 / 0.4)
			node.play("glint")
			if sfx and sfx.has_method("play_event"):
				sfx.play_event(&"cabin.glint")
		else:
			node.sprite_frames.set_animation_speed("glint", 4.0 / 1.2)
			node.play("glint")


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
	_cat_sfx_t += delta
	match _cat_state:
		"hold":
			_cat.texture = _home("cat_idle_f0")
			if _cat_t >= _cat_hold:
				_cat_t = 0.0
				if _rng.randf() < 0.7:
					_cat_state = "blink"
				else:
					_cat_state = "flick"
				if _cat_sfx_t >= 8.0 and _rng.randf() < 0.35 and sfx and sfx.has_method("play_event"):
					_cat_sfx_t = 0.0
					sfx.play_event(&"cabin.cat")
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
	new_unseen.clear()
	met_monsters.clear()
	_clear_bank_anim()
	_raw_save.clear()
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		_apply_defaults()
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_apply_defaults()
		return
	_raw_save = (parsed as Dictionary).duplicate(true)
	for id in parsed.get("seen", []):
		seen[str(id)] = true
	for id2 in parsed.get("swiped", []):
		swiped[str(id2)] = true
		seen[str(id2)] = true
	if not parsed.has("version"):
		_migrate_v1()
		return
	_read_v2(parsed)


func _apply_defaults() -> void:
	intro_seen = false
	intro_pack = 1
	nib_first_done = false
	tutorial_done = false
	tutorial_declined = false
	rooms_unlocked = ["main"]
	key_ring_seen = false
	ending_seen = false
	deepest_belly = 0
	last_route = ""
	radio_station = 0
	gear_worn = {"head": "", "eyes": "", "belt": ""}
	letters_read = []
	bestiary_read = []
	will_read = false
	drawer_hint_said = false
	drawer_opened = false
	geode_on_mantel = false
	drawer_stuck_index = 0
	milestones_said = []
	nib_idle_index = 0
	rug_secret_found = false
	counters = {"delves": 0, "homecomings": 0, "hauls": 0, "losses": 0}


func _migrate_v1() -> void:
	_apply_defaults()
	intro_seen = false
	tutorial_declined = true
	nib_first_done = true
	if swiped.size() > 0:
		counters.hauls = 1
	deepest_belly = 0
	met_monsters.clear()


func _read_v2(parsed: Dictionary) -> void:
	for id in parsed.get("new_unseen", []):
		new_unseen[str(id)] = true
	intro_seen = bool(parsed.get("intro_seen", false))
	intro_pack = int(parsed.get("intro_pack", 0))
	if intro_pack < 1:
		intro_seen = false
		intro_pack = 1
	nib_first_done = bool(parsed.get("nib_first_done", false))
	tutorial_done = bool(parsed.get("tutorial_done", false))
	tutorial_declined = bool(parsed.get("tutorial_declined", false))
	rooms_unlocked = []
	for r in parsed.get("rooms_unlocked", ["main"]):
		rooms_unlocked.append(str(r))
	if rooms_unlocked.is_empty():
		rooms_unlocked = ["main"]
	key_ring_seen = bool(parsed.get("key_ring_seen", false))
	invert_scroll = bool(parsed.get("invert_scroll", false))
	ending_seen = bool(parsed.get("ending_seen", false))
	deepest_belly = int(parsed.get("deepest_belly", 0))
	for m in parsed.get("met_monsters", []):
		met_monsters[str(m)] = true
	last_route = str(parsed.get("last_route", ""))
	radio_station = int(parsed.get("radio_station", 0))
	var gw: Variant = parsed.get("gear_worn", {})
	if typeof(gw) == TYPE_DICTIONARY:
		gear_worn = {"head": str(gw.get("head", "")), "eyes": str(gw.get("eyes", "")), "belt": str(gw.get("belt", ""))}
	letters_read = []
	for l in parsed.get("letters_read", []):
		letters_read.append(str(l))
	bestiary_read = []
	for b in parsed.get("bestiary_read", []):
		bestiary_read.append(str(b))
	will_read = bool(parsed.get("will_read", false))
	drawer_hint_said = bool(parsed.get("drawer_hint_said", false))
	drawer_opened = bool(parsed.get("drawer_opened", false))
	geode_on_mantel = bool(parsed.get("geode_on_mantel", false))
	drawer_stuck_index = int(parsed.get("drawer_stuck_index", 0))
	milestones_said = []
	for ms in parsed.get("milestones_said", []):
		milestones_said.append(int(ms) if typeof(ms) != TYPE_STRING else str(ms))
	nib_idle_index = int(parsed.get("nib_idle_index", 0))
	rug_secret_found = bool(parsed.get("rug_secret_found", false))
	var c: Variant = parsed.get("counters", {})
	if typeof(c) == TYPE_DICTIONARY:
		counters = {
			"delves": int(c.get("delves", 0)),
			"homecomings": int(c.get("homecomings", 0)),
			"hauls": int(c.get("hauls", 0)),
			"losses": int(c.get("losses", 0)),
		}
	_sync_progress_doors()


func _save() -> void:
	var data: Dictionary = _raw_save.duplicate(true)
	data["version"] = 2
	data["seen"] = seen.keys()
	data["swiped"] = swiped.keys()
	data["new_unseen"] = new_unseen.keys()
	data["intro_seen"] = intro_seen
	data["intro_pack"] = intro_pack
	data["nib_first_done"] = nib_first_done
	data["tutorial_done"] = tutorial_done
	data["tutorial_declined"] = tutorial_declined
	data["rooms_unlocked"] = rooms_unlocked
	data["key_ring_seen"] = key_ring_seen
	data["invert_scroll"] = invert_scroll
	data["ending_seen"] = ending_seen
	data["deepest_belly"] = deepest_belly
	data["met_monsters"] = met_monsters.keys()
	data["last_route"] = last_route
	data["radio_station"] = radio_station
	data["gear_worn"] = gear_worn
	data["letters_read"] = letters_read
	data["bestiary_read"] = bestiary_read
	data["will_read"] = will_read
	data["drawer_hint_said"] = drawer_hint_said
	data["drawer_opened"] = drawer_opened
	data["geode_on_mantel"] = geode_on_mantel
	data["drawer_stuck_index"] = drawer_stuck_index
	data["milestones_said"] = milestones_said
	data["nib_idle_index"] = nib_idle_index
	data["rug_secret_found"] = rug_secret_found
	data["counters"] = counters
	_raw_save = data
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
	var prog: Vector2i = cabinet_progress()
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
		"biome_cases": BiomeCabinets.case_names(_biome_rules()),
		"biome_progress": _biome_progress_lines(),
		"buckets": buckets_open,
		"room": _current_room,
		"shelf_page": _room,
		"max_room": _max_room,
		"max_bucket": _max_bucket,
		"overlay": _cutscene.kind if _cutscene and _cutscene.is_playing() else _overlay_name,
		"cut_panel": _cutscene.panel_index if _cutscene and _cutscene.is_playing() else -1,
		"rooms_unlocked": rooms_unlocked,
		"tutorial_done": tutorial_done,
		"new_unseen": new_unseen.size(),
		"progress": [prog.x, prog.y],
		"intro_seen": intro_seen,
		"ending_seen": ending_seen,
		"drawer_opened": drawer_opened,
		"geode_on_mantel": geode_on_mantel,
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
	_clear_bank_anim()
	_rebuild_shelves()


func debug_pose(beat: String) -> void:
	_arriving = false
	_door_busy = false
	_beat = beat
	visible = true
	_menu_on = true
	_overlay_name = ""
	if _map and _map.has_method("close"):
		_map.close()
	if _radio and _radio.has_method("close"):
		_radio.close()
	if _journal and _journal.has_method("close"):
		_journal.close()
	if _will and _will.has_method("close"):
		_will.close()
	if _drawer and _drawer.has_method("close"):
		_drawer.close()
	if _card and _card.has_method("close"):
		_card.close()
	if _dialog:
		_dialog.visible = false
	match beat:
		"walk":
			_show_exterior()
			_hero.visible = true
			_hero.flip_h = false
			_place_hero(Vector2(140, 188))
			_set_hero_frame("hero_walk_loot", 1)
		"intro", "intro_p1":
			intro_seen = false
			play_intro()
		"nib_first", "main_gate":
			tutorial_done = false
			tutorial_declined = false
			nib_first_done = true
			show_menu("main")
			_apply_gate()
		"map":
			show_menu("main")
			_open_map()
		"radio":
			show_menu("main")
			_open_radio()
		"gear":
			gear_worn = {"head": "helm", "eyes": "goggles", "belt": "rope"}
			show_menu("main")
			_refresh_rooms()
		"rope_exit":
			pass
		"sack_peek":
			pass
		"pause_give_up", "pause_in_run":
			pass
		"caught":
			pass
		"homecoming_loss", "loss":
			_homecoming_kind = "loss"
			show_menu("main")
		"homecoming_win", "win":
			_homecoming_kind = "win"
			show_menu("main")
		"keyring", "key_ring":
			key_ring_seen = false
			rooms_unlocked = ["main"]
			_refresh_rooms()
			play_key_ring()
		"hall", "trophy":
			if not is_room_unlocked("hall"):
				_grant_all_rooms()
			show_menu("hall")
		"study", "journal", "will":
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			show_menu("study")
			if beat == "journal" and _journal:
				_journal.open_journal("bestiary")
			if beat == "will" and _will:
				_will.open_will()
		"workshop":
			if not is_room_unlocked("workshop"):
				_grant_all_rooms()
			show_menu("workshop")
		"loft":
			if not is_room_unlocked("loft"):
				_grant_all_rooms()
			show_menu("loft")
		"ending":
			ending_seen = false
			play_ending()
		"drawer_stuck":
			ending_seen = false
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			ending_seen = false
			show_menu("study")
		"drawer_hint":
			ending_seen = true
			drawer_hint_said = false
			show_menu("main")
		"drawer_ajar":
			ending_seen = true
			drawer_opened = false
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			show_menu("study")
			_refresh_rooms()
		"drawer_open":
			ending_seen = true
			drawer_opened = true
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			show_menu("study")
			if _drawer:
				_drawer.open_drawer()
		"geode":
			geode_on_mantel = true
			show_menu("main")
			_refresh_rooms()
		"will_replay":
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			show_menu("study")
			if _journal:
				_journal.open_journal("will")
		"intro_replay":
			if not is_room_unlocked("study"):
				_grant_all_rooms()
			play_intro(true)
		"declined":
			tutorial_declined = true
			tutorial_done = false
			show_menu("main")
			_apply_gate()
		"drop":
			show_menu("main")
			_hero.visible = true
			_hero.flip_h = true
			_place_hero(Vector2(70, 205))
			_set_wide_offset(true)
			_set_hero_frame("hero_sack_dump", 2)
		"sit", "rock", "interior":
			show_menu("main")
		"rest":
			_show_exterior()
		_:
			show_menu("main")


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if settings_ui and settings_ui.visible:
		return
	if _cutscene and _cutscene.is_playing():
		if event.is_action_pressed("ui_cancel"):
			_open_pause()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			_cutscene.request_advance()
			get_viewport().set_input_as_handled()
		return
	if _space_key(event):
		if _picker_open():
			_ask_held_map()
			get_viewport().set_input_as_handled()
			return
		if _busy():
			return
		if _gate_on():
			if _dialog:
				_dialog.say(["map.first_only"])
			get_viewport().set_input_as_handled()
			return
		_ask_held_map()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		if _picker_open():
			_ask_held_map()
			get_viewport().set_input_as_handled()
			return
		_escape()
		get_viewport().set_input_as_handled()
		return
	if _journal and _journal.visible and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
		_journal.handle_page(-1 if event.is_action_pressed("ui_left") else 1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_left") and _int_root.visible:
		_arrow(-1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_right") and _int_root.visible:
		_arrow(1)
		get_viewport().set_input_as_handled()
		return


func _escape() -> void:
	if _arriving:
		_arrive_skip = 2
		_kill_arrive_motion()
		get_viewport().set_input_as_handled()
		return
	if _dialog and _dialog.is_open():
		if _dialog.has_choices():
			return
		_dialog.advance()
		return
	if _close_top_overlay():
		return
	if _current_room != "main":
		pan_to("main")
		return
	if settings_ui and settings_ui.visible:
		settings_ui.close_menu()
		return
	_open_pause()


func _open_pause() -> void:
	if settings_ui == null or not settings_ui.has_method("open_menu"):
		return
	if _cutscene and _cutscene.is_playing():
		_cutscene.set_held(true)
	settings_ui.open_menu(false)


func on_pause_closed() -> void:
	if _cutscene and _cutscene.is_playing():
		_cutscene.set_held(false)


func stop_story() -> void:
	_story_seq += 1
	if _cutscene and _cutscene.is_playing():
		_cutscene.abort()
	if _dialog and _dialog.has_method("close"):
		_dialog.visible = false
	elif _dialog:
		_dialog.visible = false
	_close_top_overlay()
	_arriving = false
	_room_busy = false
	_beat = "idle"


func clear_to_fresh_save() -> void:
	stop_story()
	seen.clear()
	swiped.clear()
	new_unseen.clear()
	met_monsters.clear()
	_just_mounted.clear()
	_clear_bank_anim()
	_raw_save.clear()
	_apply_defaults()
	_save()
	_rebuild_shelves()
	_refresh_rooms()
	_apply_gate()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func fill_middle_save() -> void:
	stop_story()
	seen.clear()
	swiped.clear()
	new_unseen.clear()
	met_monsters.clear()
	_just_mounted.clear()
	_clear_bank_anim()
	_apply_defaults()
	intro_seen = true
	nib_first_done = true
	tutorial_done = true
	tutorial_declined = true
	key_ring_seen = true
	ending_seen = false
	counters = {"delves": 3, "homecomings": 3, "hauls": 3, "losses": 0}
	deepest_belly = 3
	last_route = "gatehouse"
	var owned := 0
	var ids: Array = items_by_id.keys()
	ids.sort()
	for id in ids:
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		if BucketRules.parse(card.get("bucket", 0)) > 3:
			continue
		var sid: String = str(id)
		if sid == "spider_egg":
			continue
		seen[sid] = true
		if owned < 8:
			swiped[sid] = true
			owned += 1
	var mons: Variant = catalog.get("monsters", [])
	if typeof(mons) == TYPE_ARRAY:
		for raw in mons:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var st: String = str(raw.get("status", "live"))
			if st == "retired" or st == "hold":
				continue
			if BucketRules.parse(raw.get("bucket", 0)) > 3:
				continue
			var mid: String = str(raw.get("id", ""))
			if mid != "":
				met_monsters[mid] = true
	_save()
	_sync_progress_doors()
	_rebuild_shelves()
	_refresh_rooms()
	_apply_gate()
	for r in _rooms.values():
		if r.has_method("request_bg"):
			r.request_bg()
			r.ensure_bg()


func fill_complete_save() -> void:
	stop_story()
	seen.clear()
	swiped.clear()
	new_unseen.clear()
	met_monsters.clear()
	_just_mounted.clear()
	_clear_bank_anim()
	_apply_defaults()
	intro_seen = true
	nib_first_done = true
	tutorial_done = true
	tutorial_declined = false
	key_ring_seen = true
	ending_seen = false
	drawer_hint_said = false
	drawer_opened = false
	geode_on_mantel = false
	milestones_said = [25, 50, 75]
	counters = {"delves": 12, "homecomings": 12, "hauls": 12, "losses": 0}
	deepest_belly = 12
	for id in ROOM_ORDER:
		if not rooms_unlocked.has(id):
			rooms_unlocked.append(id)
	for id2 in items_by_id.keys():
		var card: Dictionary = items_by_id[id2]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if BucketRules.is_token(card.get("bucket", 0)):
			continue
		var sid: String = str(id2)
		if sid == "spider_egg":
			continue
		swiped[sid] = true
		seen[sid] = true
	var mons: Variant = catalog.get("monsters", [])
	if typeof(mons) == TYPE_ARRAY:
		for raw in mons:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var st: String = str(raw.get("status", "live"))
			if st == "retired" or st == "hold":
				continue
			var mid: String = str(raw.get("id", ""))
			if mid != "":
				met_monsters[mid] = true
	_save()
	_rebuild_shelves()
	_refresh_rooms()
	_apply_gate()
	for r in _rooms.values():
		if r.has_method("request_bg"):
			r.request_bg()
			r.ensure_bg()


func _arrow(delta: int) -> void:
	if _current_room == "hall":
		_on_nav(delta)
		return
	var i: int = ROOM_ORDER.find(_current_room)
	var nxt: int = i + delta
	if nxt < 0 or nxt >= ROOM_ORDER.size():
		_bump()
		return
	var dest: String = ROOM_ORDER[nxt]
	if is_room_unlocked(dest):
		pan_to(dest)
	else:
		_bump()
		KIT.cue(sfx, &"cabin.locked")
		say_bubble("cabin.locked")


func _build_rooms() -> void:
	var scripts := {
		"main": preload("res://scripts/cabin/room_main.gd"),
		"hall": preload("res://scripts/cabin/room_hall.gd"),
		"study": preload("res://scripts/cabin/room_study.gd"),
		"workshop": preload("res://scripts/cabin/room_workshop.gd"),
		"loft": preload("res://scripts/cabin/room_loft.gd"),
	}
	var rooms_layout: Dictionary = layout.get("rooms", {})
	for i in ROOM_ORDER.size():
		var id: String = ROOM_ORDER[i]
		var room = scripts[id].new()
		room.name = "Room" + id.capitalize()
		room.position = Vector2(float(i) * ROOM_W, 0)
		room.setup(self, id, rooms_layout.get(id, []), extra)
		room.hotspot_activated.connect(_on_hotspot.bind(id))
		room.hotspot_hovered.connect(_on_spot_hover)
		room.hotspot_unhovered.connect(_on_spot_unhover)
		_rooms_host.add_child(room)
		_rooms[id] = room
	var main_room = _rooms.get("main")
	_fire_glow = main_room.spots.get("room_main_fire_glow", null)
	_fire = AnimatedSprite2D.new()
	_fire.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fire.centered = false
	_fire.position = _pt(76, 164)
	_fire.z_index = 4
	main_room.add_child(_fire)
	_sack = Sprite2D.new()
	_sack.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sack.centered = false
	_sack.visible = false
	_sack.position = _pt(70, 205)
	_sack.flip_h = true
	_sack.z_index = 5
	main_room.add_child(_sack)
	_rock = AnimatedSprite2D.new()
	_rock.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rock.centered = false
	_rock.position = _pt(10, 205)
	_rock.visible = false
	_rock.z_index = 5
	main_room.add_child(_rock)
	_chair_empty = Sprite2D.new()
	_chair_empty.name = "EmptyChair"
	_chair_empty.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_chair_empty.centered = false
	_chair_empty.position = _pt(10, 205)
	_chair_empty.visible = false
	_chair_empty.z_index = 3
	main_room.add_child(_chair_empty)
	_chair_hit = Control.new()
	_chair_hit.name = "EmptyChairHit"
	_chair_hit.position = _pt(10, 205)
	_chair_hit.size = _pt(32, 32)
	_chair_hit.visible = false
	_chair_hit.z_index = 6
	_chair_hit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chair_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_chair_hit.gui_input.connect(_on_empty_chair_input)
	main_room.add_child(_chair_hit)
	var hall = _rooms.get("hall")
	_hole = Control.new()
	_hole.position = _pt(100, 24)
	_hole.size = _pt(260, 160)
	_hole.clip_contents = true
	_hole.mouse_filter = Control.MOUSE_FILTER_STOP
	_hole.z_index = 3
	hall.add_child(_hole)
	_shelf_host = Control.new()
	_shelf_host.position = Vector2.ZERO
	_shelf_host.size = _hole.size
	_shelf_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hole.add_child(_shelf_host)
	_cordon = TextureRect.new()
	_cordon.set_anchors_preset(PRESET_FULL_RECT)
	_cordon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cordon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cordon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cordon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cordon.visible = false
	_hole.add_child(_cordon)
	_shelf_fade = ColorRect.new()
	_shelf_fade.set_anchors_preset(PRESET_FULL_RECT)
	_shelf_fade.color = Color(0.07, 0.05, 0.04, 0)
	_shelf_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shelf_fade.visible = false
	_hole.add_child(_shelf_fade)
	_gauge = TextureProgressBar.new()
	_gauge.texture_under = KIT.load_tex("ui/gauge_under.png")
	_gauge.texture_progress = KIT.load_tex("ui/gauge_fill.png")
	_gauge.min_value = 0
	_gauge.max_value = 1
	_gauge.value = 0
	_gauge.nine_patch_stretch = false
	_gauge.position = _pt(148, 188)
	_gauge.size = _pt(164, 5)
	_gauge.z_index = 3
	_gauge.mouse_filter = Control.MOUSE_FILTER_STOP
	_gauge.mouse_entered.connect(func() -> void:
		var p: Vector2i = cabinet_progress()
		var key: String = "cabin.hall.full" if p.x >= p.y and p.y > 0 else "cabin.hall.gauge"
		show_hover_tag(key, _gauge, {"n": p.x, "total": p.y})
	)
	_gauge.mouse_exited.connect(hide_hover_tag)
	hall.add_child(_gauge)


func _build_chrome() -> void:
	_toast = TextureRect.new()
	_toast.texture = KIT.load_tex("ui/room_toast.png")
	_toast.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_toast.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_toast.size = _toast.texture.get_size() if _toast.texture else _pt(120, 26)
	_toast.position = Vector2((1680.0 - _toast.size.x) * 0.5, -26.0 * PX)
	_toast.z_index = 4
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast)
	_toast_lab = KIT.raw_label("", 28, KIT.CREAM)
	_toast_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_lab.set_anchors_preset(PRESET_FULL_RECT)
	_toast.add_child(_toast_lab)
	_hover_tag = KIT.framed("", 20, "ui/tooltip_parchment_9.png", Vector2(8, 8), KIT.INK, true)
	_hover_tag.grow_to_text = true
	_hover_tag.max_width = 420
	_hover_tag.z_index = 5
	_hover_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hover_tag.visible = false
	add_child(_hover_tag)
	_editor_strip = VBoxContainer.new()
	_editor_strip.position = Vector2(16, 16)
	_editor_strip.z_index = 9
	_editor_strip.visible = false
	add_child(_editor_strip)


func _build_overlays() -> void:
	_overlays = Control.new()
	_overlays.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_overlays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlays.z_index = 6
	add_child(_overlays)
	_map = preload("res://scripts/cabin/map_overlay.gd").new()
	_map.setup(self, extra)
	_map.go.connect(_on_map_go)
	_map.closed.connect(func() -> void:
		_overlay_name = ""
	)
	_overlays.add_child(_map)
	_radio = preload("res://scripts/cabin/radio_overlay.gd").new()
	_radio.setup(self, extra, sfx)
	_radio.closed.connect(func() -> void:
		_overlay_name = ""
		_overlays.z_index = 6
	)
	_overlays.add_child(_radio)
	_journal = preload("res://scripts/cabin/journal_overlay.gd").new()
	_journal.setup(self, extra, lore, catalog, art)
	_journal.closed.connect(func() -> void:
		_overlay_name = ""
	)
	_journal.replay_intro.connect(func() -> void:
		play_intro(true)
	)
	_overlays.add_child(_journal)
	_will = preload("res://scripts/cabin/will_overlay.gd").new()
	_will.setup(self, extra)
	_will.closed.connect(func() -> void:
		_overlay_name = ""
	)
	_overlays.add_child(_will)
	_drawer = preload("res://scripts/cabin/drawer_overlay.gd").new()
	_drawer.setup(self, extra)
	_drawer.closed.connect(func() -> void:
		_overlay_name = ""
	)
	_drawer.take_geode.connect(_on_take_geode)
	_drawer.open_note.connect(_on_drawer_note)
	_overlays.add_child(_drawer)
	_card = preload("res://scripts/cabin/parchment_card.gd").new()
	_card.setup()
	_card.closed.connect(func() -> void:
		_overlay_name = ""
	)
	_overlays.add_child(_card)
	_dialog = preload("res://scripts/cabin/cabin_dialog.gd").new()
	_dialog.setup(self)
	add_child(_dialog)
	_cutscene = preload("res://scripts/cabin/cutscene_player.gd").new()
	_cutscene.setup(self)
	add_child(_cutscene)


func attach_editor(main) -> void:
	if main == null or not DevFlag.on():
		return
	_editor_strip.visible = true
	for pair in [["Play Latest", "latest"], ["Developer Test", "dev"], ["Roster", "roster"], ["Script", "script"]]:
		var b := Button.new()
		b.text = str(pair[0])
		b.pressed.connect(func() -> void:
			if main.settings_ui:
				main.settings_ui.mode_picked.emit(str(pair[1]))
		)
		_editor_strip.add_child(b)


func _play_station() -> void:
	if sfx == null:
		return
	var bed: String = STATION_BEDS[clampi(radio_station, 0, 3)]
	if sfx.has_method("music_to"):
		sfx.music_to(StringName(bed), 0.8)
	elif sfx.has_method("music_cabin"):
		sfx.music_cabin()


func _apply_view_frame() -> void:
	if _rooms_clip == null:
		return
	var view: Vector2 = size
	if view.x < 8.0 or view.y < 8.0:
		view = get_viewport_rect().size
	var fr: Rect2 = VIEW_FRAME.frame_rect(view)
	_rooms_clip.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	_rooms_clip.position = fr.position
	_rooms_clip.size = fr.size
	_rooms_clip.clip_contents = true
	if _rooms_host:
		_rooms_host.size = Vector2(ROOM_W * 5.0, ROOM_H)
	_snap_to(_current_room)


func _snap_to(room: String) -> void:
	_current_room = room
	var i: int = ROOM_ORDER.find(room)
	if i < 0:
		i = 0
	if _rooms_host:
		_rooms_host.position.x = -float(i) * ROOM_W
		_rooms_host.position.y = 0
	var r = _rooms.get(room)
	if r and r.has_method("ensure_bg"):
		r.ensure_bg()


func pan_to(room: String) -> void:
	_sync_progress_doors()
	if _pan_busy or not is_room_unlocked(room):
		if not is_room_unlocked(room):
			_bump()
			KIT.cue(sfx, &"cabin.locked")
			say_bubble("cabin.locked")
		return
	var i: int = ROOM_ORDER.find(room)
	if i < 0:
		return
	_pan_busy = true
	_rooms_host.mouse_filter = Control.MOUSE_FILTER_STOP
	KIT.cue(sfx, &"cabin.pan")
	var r = _rooms.get(room)
	if r and r.has_method("request_bg"):
		r.request_bg()
		r.ensure_bg()
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_rooms_host, "position:x", -float(i) * ROOM_W, 0.45)
	await tw.finished
	if not is_inside_tree():
		return
	_current_room = room
	_pan_busy = false
	_rooms_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_show_toast("cabin.room.%s" % room)
	if room == "hall":
		call_deferred("_offer_bank_sequence")


func _pan_unlocked(room: String) -> void:
	if not is_room_unlocked(room):
		if not rooms_unlocked.has(room):
			rooms_unlocked.append(room)
			_save()
			_refresh_rooms()
	var i: int = ROOM_ORDER.find(room)
	if i < 0:
		return
	_pan_busy = true
	KIT.cue(sfx, &"cabin.pan")
	var r = _rooms.get(room)
	if r and r.has_method("request_bg"):
		r.request_bg()
		r.ensure_bg()
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_rooms_host, "position:x", -float(i) * ROOM_W, 0.45)
	await tw.finished
	if not is_inside_tree():
		return
	_current_room = room
	_pan_busy = false
	_show_toast("cabin.room.%s" % room)
	if room == "hall":
		call_deferred("_offer_bank_sequence")


func _move_nib_x(x_native: float, dur: float) -> void:
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	var nib = main_room.nib
	var hs = main_room.spots.get("Nib", null)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_parallel(true)
	if nib:
		tw.tween_property(nib, "position:x", x_native * PX, dur)
	if hs is Control:
		tw.tween_property(hs, "position:x", x_native * PX, dur)
	await tw.finished


func _unlock_spot(room_id: String, node_name: String, unlock_room: String, line_key: String, ladder: bool) -> void:
	var room = _rooms.get(room_id)
	if room == null:
		return
	var hs = room.spots.get(node_name, null)
	var origin := Vector2.ZERO
	if hs is CabinHotspot:
		origin = hs.origin_native
		hs.visible = false
	var rels: Array = (
		["doors/ladder_unlock_f0.png", "doors/ladder_unlock_f1.png", "doors/ladder_unlock_f2.png", "doors/ladder_unlock_f3.png"]
		if ladder else
		["doors/side_door_unlock_f0.png", "doors/side_door_unlock_f1.png", "doors/side_door_unlock_f2.png", "doors/side_door_unlock_f3.png"]
	)
	var anim: AnimatedSprite2D = KIT.anim_sprite(rels, "u", 1000.0 / 110.0, false, origin)
	anim.z_index = 6
	room.add_child(anim)
	if anim.sprite_frames:
		anim.play("u")
	var spark: AnimatedSprite2D = KIT.anim_sprite(
		["doors/unlock_sparkle_f0.png", "doors/unlock_sparkle_f1.png", "doors/unlock_sparkle_f2.png", "doors/unlock_sparkle_f3.png"],
		"s", 1000.0 / 110.0, false, origin + Vector2(0, 16)
	)
	spark.z_index = 7
	room.add_child(spark)
	if spark.sprite_frames:
		spark.play("s")
	KIT.cue(sfx, &"cabin.unlock")
	KIT.cue(sfx, &"sting.unlock")
	if not ladder:
		var t := get_tree().create_timer(0.22, true, true, true)
		t.timeout.connect(func() -> void:
			KIT.cue(sfx, &"cabin.chain_drop")
		, CONNECT_ONE_SHOT)
	await _wait(0.44)
	if is_instance_valid(anim):
		anim.queue_free()
	if is_instance_valid(spark):
		spark.queue_free()
	if not rooms_unlocked.has(unlock_room):
		rooms_unlocked.append(unlock_room)
	_save()
	_refresh_rooms()
	if hs:
		hs.visible = true
	await _say_key(line_key)


func _say_key(key: String) -> void:
	if key == "" or _dialog == null:
		return
	_dialog.say([key])
	await _dialog.finished


func _play_cheer() -> void:
	var main_room = _rooms.get("main")
	_stop_rock()
	_set_idle_hero_visible(false)
	_host_hero(main_room if main_room else _int_root)
	_hero.visible = true
	_set_wide_offset(false)
	var origin: Vector2 = Vector2(70, 205) if _arriving else Vector2(10, 205)
	_place_hero(origin)
	_set_hero_frame("hero_cheer", 0)
	await _wait(0.14)
	_set_hero_frame("hero_cheer", 1)
	var base_y: float = _hero.position.y
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_hero, "position:y", base_y - _px(4), 0.12)
	tw.tween_property(_hero, "position:y", base_y, 0.14)
	await _wait(0.26)


func _show_toast(key: String, vars: Dictionary = {}) -> void:
	_toast_lab.text = KIT.fill_text(key, vars) if vars.size() > 0 else KIT.copy_text(key)
	_toast.position.y = -26.0 * PX
	KIT.cue(sfx, &"cabin.room_sign")
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_toast, "position:y", 0.0, 0.18)
	tw.tween_interval(1.2)
	tw.tween_property(_toast, "position:y", -26.0 * PX, 0.18)


func show_hover_tag(key: String, hit: Control, vars: Dictionary = {}) -> void:
	var t: String = KIT.fill_text(key, vars) if vars.size() > 0 else KIT.copy_text(key)
	if t == "":
		return
	_hover_tag.set_plain(t)
	if hit:
		var g: Vector2 = hit.get_global_rect().position
		_hover_tag.global_position = Vector2(g.x, g.y - 12.0 * PX - _hover_tag.size.y)
	_hover_tag.visible = true


func hide_hover_tag() -> void:
	_hover_tag.visible = false


func say_bubble(key: String, vars: Dictionary = {}) -> void:
	if _dialog:
		_dialog.say_bubble(key, Vector2(216, 150), vars)


func nib_talk(on: bool) -> void:
	var main_room = _rooms.get("main")
	if main_room and main_room.nib and main_room.nib.sprite_frames:
		main_room.nib.play("talk" if on else ("psst" if _gate_on() else "idle"))


func _gate_on() -> bool:
	return not tutorial_done and not tutorial_declined


func _apply_gate() -> void:
	var main_room = _rooms.get("main")
	if main_room and main_room.has_method("set_gate"):
		var talking: bool = _dialog != null and _dialog.has_method("is_open") and _dialog.is_open()
		main_room.set_gate(_gate_on() and not talking)
	_refresh_rooms()


func _refresh_rooms() -> void:
	for r in _rooms.values():
		if r.has_method("refresh_locks"):
			r.refresh_locks()
	_refresh_gauge()


func _refresh_gauge() -> void:
	if _gauge == null:
		return
	var p: Vector2i = cabinet_progress()
	_gauge.max_value = maxi(p.y, 1)
	_gauge.value = p.x


func _tidy_blocking() -> void:
	if _cutscene and _cutscene.is_playing() and _beat == "idle":
		_cutscene.abort()
	if _dialog and _dialog.has_method("is_open") and _dialog.is_open() and not _dialog.visible:
		if _dialog.has_method("dismiss"):
			_dialog.dismiss()
	if _overlay_name == "radio" and (_radio == null or not _radio.visible):
		_overlay_name = ""
	elif _overlay_name == "map" and (_map == null or not _map.visible):
		_overlay_name = ""
	elif _overlay_name == "journal" and (_journal == null or not _journal.visible):
		_overlay_name = ""
	elif _overlay_name == "will" and (_will == null or not _will.visible):
		_overlay_name = ""
	elif _overlay_name == "drawer" and (_drawer == null or not _drawer.visible):
		_overlay_name = ""


func _busy() -> bool:
	_tidy_blocking()
	return _pan_busy or _room_busy or _arriving or (_dialog and _dialog.is_open()) or _overlay_name != "" or (_cutscene and _cutscene.is_playing())


func _on_hotspot(node_name: String, room: String = "main") -> void:
	if _arriving and _int_root.visible:
		if node_name == "Hero":
			_arrive_skip = maxi(_arrive_skip, 2)
			_kill_arrive_motion()
			return
		if node_name == "RunDoor" or node_name == "SideDoor" or node_name == "BackDoor":
			_arrive_pending_name = node_name
			_arrive_pending_room = room
			_arrive_skip = maxi(_arrive_skip, 2)
			_kill_arrive_motion()
			return
	if _dialog and _dialog.is_open() and not _dialog.has_choices():
		_dialog.advance()
		return
	if _busy() and node_name != "Nib" and not (node_name == "RunDoor" and _gate_on()):
		return
	match node_name:
		"RunDoor":
			_on_run_door()
		"SideDoor":
			_on_side_door(room)
		"BackDoor":
			_on_back_door(room)
		"Map":
			_on_map()
		"Radio", "RadioFirefly":
			_open_radio()
		"Nib":
			_on_nib()
		"Fire":
			if _dialog:
				_dialog.say(["nib.fire"])
		"Rug":
			_on_rug()
		"Hero":
			_on_chair()
		"PortraitSmall":
			if _dialog:
				_dialog.say(["nib.portrait"])
		"LuckyGeode":
			_on_geode()
		"Gear_helm", "Gear_cap", "Gear_goggles", "Gear_rope":
			var piece: String = node_name.trim_prefix("Gear_")
			var slot: String = str(extra.get("gear_slots", {}).get(piece, ""))
			if slot != "" and str(gear_worn.get(slot, "")) == piece:
				_hang(piece)
			else:
				_wear(piece)
		"ShelfPrev":
			_on_nav(-1)
		"ShelfNext":
			_on_nav(1)
		"PortraitBig", "Will":
			_open_will()
		"Journal":
			_open_journal()
		"MountainModel":
			var k: String = "cabin.model.none" if deepest_belly <= 0 else "cabin.model.deepest"
			show_hover_tag(k, null, {"n": deepest_belly})
		"Drawer":
			_on_drawer()
		"Dummy":
			_on_dummy()
		"BragOMeter":
			_open_brag()
		"Patents":
			_open_patents()
		"Ladder":
			pan_to("loft")
		"Bed":
			_on_bed()
		"Telescope":
			var tk: String = "cabin.telescope.none" if deepest_belly <= 0 else "cabin.telescope.line"
			var tvars: Dictionary = {} if deepest_belly <= 0 else {"n": deepest_belly}
			if _dialog:
				_dialog.z_index = 40
				var line: String = KIT.fill_text(tk, tvars)
				if line.strip_edges() == "":
					_dialog.say([tk], [], tvars, {tk: "Not yet."})
				else:
					_dialog.say([tk], [], tvars)
			KIT.cue(sfx, &"cabin.telescope")
		"Trunk":
			_on_trunk()
		"Cat":
			_on_cat()
		"Hatch":
			pan_to("workshop")


func _on_spot_hover(_n: String, key: String, hit: Control) -> void:
	show_hover_tag(key, hit)


func _on_spot_unhover(_n: String) -> void:
	hide_hover_tag()


func _on_run_door() -> void:
	if _gate_on():
		_interrupt()
		return
	_ask_held_map()


func _play_run_door_open() -> void:
	var room = _rooms.get("main")
	if room == null:
		return
	var hs = room.spots.get("RunDoor", null)
	if hs == null or not (hs is CabinHotspot):
		return
	var rels := ["doors/run_door_open_f0.png", "doors/run_door_open_f1.png", "doors/run_door_open_f2.png"]
	if KIT.load_tex(rels[0]) == null:
		return
	var closed: Texture2D = hs.idle_tex
	var ms := [100.0, 100.0, 100.0]
	for i in rels.size():
		var tex: Texture2D = KIT.load_tex(str(rels[i]))
		if tex:
			hs.texture = tex
			hs.position = hs.origin_native * PX
			hs.size = tex.get_size()
		await _wait(ms[i] / 1000.0)
	# Hold f2 briefly then restore closed for next visit.
	await _wait(0.05)
	if closed:
		hs.set_idle_tex(closed)


func _on_map() -> void:
	if _gate_on():
		if _dialog:
			_dialog.say(["map.first_only"])
		return
	_ask_held_map()


func _open_map() -> void:
	_overlay_name = "map"
	_map.open_map(last_route)


func _ask_held_map() -> void:
	held_map_wanted.emit()


func _picker_open() -> bool:
	var host: Node = get_parent()
	if host == null:
		return false
	var picker = host.get("campaign_map")
	return picker != null and picker.has_method("is_picker_open") and bool(picker.is_picker_open())


func _space_key(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return false
	return key.keycode == KEY_SPACE or key.physical_keycode == KEY_SPACE


func _open_radio() -> void:
	_overlay_name = "radio"
	_overlays.z_index = 20
	_radio.open_radio()


func _open_journal() -> void:
	_overlay_name = "journal"
	var tab := "bestiary" if met_monsters.size() > 0 else "items"
	_journal.open_journal(tab)


func _open_will() -> void:
	_overlay_name = "will"
	_will.open_will()


func _on_map_go(route: String) -> void:
	last_route = route
	_save()
	await _play_run_door_open()
	_leave_for_run(route)


func _leave_for_run(route: String) -> void:
	counters.delves = int(counters.get("delves", 0)) + 1
	last_route = route
	_save()
	route_chosen.emit(route)


func _interrupt() -> void:
	var main_room = _rooms.get("main")
	if main_room and main_room.nib:
		KIT.cue(sfx, &"speech.nib_gasp")
		main_room.nib.play("gasp")
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(main_room.nib, "position:x", 232.0 * PX, 0.4)
	if _dialog == null:
		tutorial_declined = true
		_save()
		_apply_gate()
		_ask_held_map()
		return
	if _dialog.has_method("dismiss"):
		_dialog.dismiss()
	_dialog.say(["nib.interrupt.1", "nib.interrupt.2"], ["nib.interrupt.yes", "nib.interrupt.no"])
	var ch: int = await _dialog.finished
	if ch == 0:
		tutorial_wanted.emit()
	else:
		tutorial_declined = true
		_save()
		_dialog.say(["nib.interrupt.no_reply"])
		await _dialog.finished
		_apply_gate()
		_ask_held_map()


func _on_nib() -> void:
	if _gate_on():
		_interrupt()
		return
	var keys := ["nib.idle.1", "nib.idle.2", "nib.idle.3", "nib.idle.4", "nib.idle.5", "nib.idle.6"]
	var k: String = str(keys[nib_idle_index % keys.size()])
	nib_idle_index = (nib_idle_index + 1) % keys.size()
	_save()
	if _dialog:
		_dialog.say([k])
	if nib_idle_index in [1, 4, 0]:
		KIT.cue(sfx, &"speech.nib_chuckle")


func _on_locked_door() -> void:
	if _dialog == null:
		return
	_dialog.say(["cabin.locked.first"], ["cabin.locked.try", "cabin.locked.wait"])
	var ch: int = await _dialog.finished
	if ch == 0:
		_ask_held_map()


func _on_cat() -> void:
	say_bubble("cabin.cat.line")
	KIT.cue(sfx, &"cabin.cat")
	if sfx and sfx.has_method("loop_start"):
		sfx.loop_start(&"amb.cat_purr", 0.0)
	var loft = _rooms.get("loft")
	if loft and loft.has_method("play_rub") and loft.play_rub():
		await loft.cat_sleep.animation_finished
	elif loft and loft.cat_sleep:
		var cat: AnimatedSprite2D = loft.cat_sleep
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(cat, "scale", Vector2(1.12, 0.92), 0.12)
		tw.tween_property(cat, "scale", Vector2.ONE, 0.18)


func _on_side_door(room: String) -> void:
	await _flash_side_door_open(room)
	match room:
		"main":
			pan_to("hall")
		"hall":
			pan_to("study")
		"study":
			pan_to("workshop")


func _flash_side_door_open(room: String) -> void:
	var r = _rooms.get(room)
	if r == null:
		return
	var hs = r.spots.get("SideDoor", null)
	if hs == null or not (hs is CabinHotspot) or hs.locked:
		return
	var open_tex: Texture2D = KIT.load_tex("doors/side_door_open.png")
	if open_tex == null:
		return
	var closed: Texture2D = hs.idle_tex
	hs.texture = open_tex
	hs.position = hs.origin_native * PX
	hs.size = open_tex.get_size()
	await _wait(0.12)
	if closed:
		hs.set_idle_tex(closed)


func _on_back_door(room: String) -> void:
	match room:
		"hall":
			pan_to("main")
		"study":
			pan_to("hall")
		"workshop":
			pan_to("study")


func _on_chair() -> void:
	var any: bool = str(gear_worn.get("head", "")) != "" or str(gear_worn.get("eyes", "")) != "" or str(gear_worn.get("belt", "")) != ""
	if any:
		_hang(_gear_last if _gear_last != "" else "helm")
		return
	if _dialog:
		_dialog.say(["nib.chair"])


func _on_rug() -> void:
	if rug_secret_found:
		if _dialog:
			_dialog.say(["nib.rug.again"], [], {}, RUG_COPY)
		return
	await _play_rug_secret()


func _play_rug_secret() -> void:
	_room_busy = true
	var room = _rooms.get("main")
	var flask := TextureRect.new()
	flask.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flask.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flask.stretch_mode = TextureRect.STRETCH_KEEP
	flask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flask.z_index = 8
	var tex: Texture2D = tex_by_item.get(RUG_SECRET_ID, null)
	if tex == null:
		tex = load("res://assets/dungeon/items/poison_flask.png") as Texture2D
	flask.texture = tex
	flask.size = Vector2(16, 16) * PX * 2.0
	flask.pivot_offset = flask.size * 0.5
	flask.position = Vector2(48, 214) * PX
	flask.scale = Vector2(0.2, 0.2)
	flask.modulate = Color(0.55, 0.55, 0.55, 1.0)
	if room:
		room.add_child(flask)
	else:
		add_child(flask)
	KIT.cue(sfx, &"cabin.item_pop")
	var pop := create_tween()
	pop.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pop.set_trans(Tween.TRANS_BACK)
	pop.set_ease(Tween.EASE_OUT)
	pop.tween_property(flask, "scale", Vector2.ONE, 0.35)
	pop.parallel().tween_property(flask, "modulate", Color.WHITE, 0.35)
	pop.parallel().tween_property(flask, "position:y", flask.position.y - 18.0 * PX, 0.35)
	await pop.finished
	if _dialog:
		_dialog.say(["nib.rug.1", "nib.rug.2"], [], {}, RUG_COPY)
		await _dialog.finished
	await _wait(0.55, true)
	KIT.cue(sfx, &"cabin.item_whoosh")
	var toss := create_tween()
	toss.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	toss.set_trans(Tween.TRANS_QUAD)
	toss.set_ease(Tween.EASE_IN)
	toss.tween_property(flask, "position", Vector2(520, 150) * PX, 0.7)
	toss.parallel().tween_property(flask, "rotation", TAU * 2.2, 0.7)
	toss.parallel().tween_property(flask, "scale", Vector2(0.7, 0.7), 0.7)
	await toss.finished
	if sfx and sfx.has_method("play"):
		sfx.play("error_big", -4.0)
	if is_instance_valid(flask):
		flask.queue_free()
	await _wait(0.4, true)
	if _dialog:
		_dialog.say(["nib.rug.3"], [], {}, RUG_COPY)
		await _dialog.finished
	rug_secret_found = true
	_save()
	await _show_system_banner(str(RUG_COPY["cabin.rug.unlock"]))
	_room_busy = false


func _show_system_banner(text: String) -> void:
	var host := Control.new()
	host.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_STOP
	host.z_index = 9
	add_child(host)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	veil.color = Color("100e0c88")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(veil)
	var box: NinePatchRect = KIT.nine("ui/dialog_box_9.png", Vector2(KIT.DIALOG_PATCH_NATIVE, KIT.DIALOG_PATCH_NATIVE))
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(box)
	var lab = KIT.raw_label(text, KIT.DIALOG_FONT, KIT.INK, true)
	box.add_child(lab)
	var sz: Vector2 = KIT.fit_bubble(box, lab, text, KIT.DIALOG_FONT)
	sz.x = maxf(sz.x, 220.0 * PX)
	box.size = sz
	lab.size = Vector2(sz.x - KIT.DIALOG_PATCH_NATIVE * PX * 2.0, sz.y - KIT.DIALOG_PATCH_NATIVE * PX * 2.0)
	lab.fit()
	box.position = Vector2((KIT.ROOM_W - box.size.x) * 0.5, KIT.ROOM_H * 0.42)
	KIT.cue(sfx, &"sting.unlock")
	var done := false
	host.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			done = true
	)
	var t: float = 0.0
	while not done and t < 3.4:
		await get_tree().process_frame
		t += get_process_delta_time()
	if is_instance_valid(host):
		host.queue_free()


func _wear(piece: String) -> void:
	var slot: String = str(extra.get("gear_slots", {}).get(piece, ""))
	if slot == "":
		return
	var old: String = str(gear_worn.get(slot, ""))
	if old != "" and old != piece:
		gear_worn[slot] = ""
	gear_worn[slot] = piece
	_gear_last = piece
	KIT.cue(sfx, &"cabin.gear_take")
	_save()
	_refresh_rooms()
	if _rocking:
		_set_hero_frame("hero_rock", _rock_i)
	elif _hero and _hero.visible and _hero.texture:
		var path: String = String(_hero.texture.resource_path).get_file().get_basename()
		var fam: String = path.substr(0, path.rfind("_f")) if path.rfind("_f") >= 0 else ""
		var fi: int = int(path.get_slice("_f", 1)) if path.contains("_f") else 0
		if fam != "":
			_set_hero_frame(fam, fi)


func _hang(piece: String) -> void:
	var slot: String = str(extra.get("gear_slots", {}).get(piece, ""))
	if slot == "":
		return
	gear_worn[slot] = ""
	KIT.cue(sfx, &"cabin.gear_hang")
	_save()
	_refresh_rooms()
	if _rocking:
		_set_hero_frame("hero_rock", _rock_i)


func _on_geode() -> void:
	_geode_line = 1 - _geode_line
	var k: String = "cabin.geode.line.1" if _geode_line == 0 else "cabin.geode.line.2"
	if _dialog:
		_dialog.say([k])
	KIT.cue(sfx, &"cabin.geode_chime")


func _on_drawer() -> void:
	if not ending_seen:
		KIT.cue(sfx, &"cabin.drawer_stuck")
		await _play_drawer_rattle()
		drawer_stuck_index = (drawer_stuck_index + 1) % 3
		_save()
		if _dialog:
			_dialog.say(["drawer.stuck.%d" % (drawer_stuck_index if drawer_stuck_index > 0 else 3)])
		return
	KIT.cue(sfx, &"cabin.drawer_open")
	await _play_drawer_open()
	if not drawer_opened:
		drawer_opened = true
		_save()
		_refresh_rooms()
		if _dialog:
			_dialog.say(["drawer.open.nib"])
			await _dialog.finished
	_overlay_name = "drawer"
	_drawer.open_drawer()


func _drawer_hotspot() -> CabinHotspot:
	var study = _rooms.get("study")
	if study == null:
		return null
	var hs = study.spots.get("Drawer", null)
	if hs is CabinHotspot:
		return hs
	return null


func _play_drawer_rattle() -> void:
	var hs: CabinHotspot = _drawer_hotspot()
	if hs == null:
		return
	var rels := [
		"props/desk_drawer_rattle_f0.png",
		"props/desk_drawer_rattle_f1.png",
		"props/desk_drawer_rattle_f2.png",
		"props/desk_drawer_rattle_f0.png",
	]
	if KIT.load_tex(rels[0]) == null:
		return
	var rest: Texture2D = hs.idle_tex
	var origin := Vector2(200, 166)
	for rel in rels:
		var tex: Texture2D = KIT.load_tex(str(rel))
		if tex:
			hs.texture = tex
			hs.position = origin * PX
			hs.size = tex.get_size()
		await _wait(0.06)
	if rest:
		hs.set_idle_tex(rest)


func _play_drawer_open() -> void:
	var hs: CabinHotspot = _drawer_hotspot()
	if hs == null:
		return
	var rels := [
		"props/desk_drawer_open_f0.png",
		"props/desk_drawer_open_f1.png",
		"props/desk_drawer_open_f2.png",
		"props/desk_drawer_open_f3.png",
	]
	if KIT.load_tex(rels[0]) == null:
		return
	var origin := Vector2(198, 163)
	for i in rels.size():
		var tex: Texture2D = KIT.load_tex(str(rels[i]))
		if tex:
			hs.texture = tex
			hs.position = origin * PX
			hs.size = tex.get_size()
		await _wait(0.09)
	# Hold f3 while close-up is up; overlay open follows.


func _on_take_geode() -> void:
	geode_on_mantel = true
	_save()
	pan_to("main")
	_refresh_rooms()
	if _dialog:
		_dialog.say(["drawer.taken.nib"])


func _on_drawer_note() -> void:
	var note: Dictionary = lore.get("drawer_note", {})
	_overlay_name = "letter"
	_card.open_card("drawer.note", KIT.named(str(note.get("body", ""))), "cabin.trunk.close")
	KIT.cue(sfx, &"cabin.scroll")


func _on_dummy() -> void:
	KIT.cue(sfx, &"cabin.dummy")
	await _play_dummy_tilt()
	if _dialog:
		_dialog.say(["cabin.dummy.ask"], ["cabin.dummy.yes", "cabin.dummy.no"])
		var ch: int = await _dialog.finished
		if ch == 0:
			return_room = "workshop"
			tutorial_wanted.emit()


func _play_dummy_tilt() -> void:
	var shop = _rooms.get("workshop")
	if shop == null:
		return
	var hs = shop.spots.get("Dummy", null)
	if hs == null or not (hs is CabinHotspot):
		return
	var idle: Texture2D = hs.idle_tex if hs.idle_tex else KIT.load_tex("props/dummy.png")
	var tilt_l: Texture2D = KIT.load_tex("props/dummy_tilt_l.png")
	var tilt_r: Texture2D = KIT.load_tex("props/dummy_tilt_r.png")
	if tilt_l == null or tilt_r == null:
		return
	var seq: Array = [idle, tilt_l, tilt_r, tilt_l, idle]
	for tex in seq:
		if tex:
			hs.texture = tex
			hs.position = hs.origin_native * PX
			hs.size = tex.get_size()
		await _wait(0.07)
	if idle:
		hs.set_idle_tex(idle)


func _open_brag() -> void:
	KIT.cue(sfx, &"cabin.brag")
	var p: Vector2i = cabinet_progress()
	var lines := [
		KIT.fill_text("cabin.brag.delves", {"n": counters.get("delves", 0)}),
		KIT.fill_text("cabin.brag.homecomings", {"n": counters.get("hauls", 0)}),
		KIT.fill_text("cabin.brag.deepest", {"n": deepest_belly}),
		KIT.fill_text("cabin.brag.swiped", {"n": p.x, "total": p.y}),
		KIT.fill_text("cabin.brag.met", {"n": met_monsters.size(), "total": 35}),
	]
	_overlay_name = "brag"
	_card.open_card("cabin.brag.title", "\n".join(lines), "cabin.brag.close")


func _open_patents() -> void:
	KIT.cue(sfx, &"cabin.scroll")
	_overlay_name = "patents"
	_card.open_card("cabin.credits.title", KIT.copy_text("cabin.credits.body"), "cabin.credits.close")


func _on_bed() -> void:
	KIT.cue(sfx, &"cabin.bed")
	if _dialog == null:
		return
	if _dialog.is_open() and not _dialog.has_choices():
		_dialog.advance()
		return
	_dialog.z_index = 40
	if OS.has_feature("web"):
		_dialog.say(["cabin.bed.web"])
		await _dialog.finished
		return
	_dialog.say(["cabin.bed.ask"], ["cabin.bed.yes", "cabin.bed.no"])
	var ch: int = await _dialog.finished
	if ch == 0:
		quit_wanted.emit()


func _on_trunk() -> void:
	KIT.cue(sfx, &"cabin.trunk")
	trunk_open = true
	_refresh_rooms()
	var unlocked: Array = []
	var p: Vector2i = cabinet_progress()
	var pct: int = 0 if p.y <= 0 else int(round(100.0 * float(p.x) / float(p.y)))
	for letter in lore.get("letters", []):
		if typeof(letter) != TYPE_DICTIONARY:
			continue
		if pct >= int(letter.get("unlock_pct", 100)):
			unlocked.append(letter)
	if unlocked.is_empty():
		if _dialog:
			_dialog.say(["cabin.trunk.empty"])
		return
	var pick: Dictionary = unlocked[unlocked.size() - 1]
	var lid: String = str(pick.get("id", ""))
	if lid != "" and not letters_read.has(lid):
		letters_read.append(lid)
		_save()
	_overlay_name = "letter"
	_card.open_card("", KIT.named(str(pick.get("body", ""))), "cabin.trunk.close")
	_card._title.text = KIT.named(str(pick.get("title", "")))


func _close_top_overlay() -> bool:
	for o in [_journal, _will, _drawer, _card, _map, _radio]:
		if o and o.visible:
			if o.has_method("close"):
				o.close()
			elif o.has_method("close_card"):
				o.close()
			_overlay_name = ""
			return true
	return false


func _ensure_hero_layers() -> void:
	if _hero == null:
		return
	if _hero_layers.size() >= 4:
		return
	for piece in ["rope", "goggles", "cap", "helm"]:
		if _hero_layers.has(piece) and is_instance_valid(_hero_layers[piece]):
			continue
		var spr := Sprite2D.new()
		spr.name = "Gear_%s" % piece
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = _hero.centered
		spr.offset = _hero.offset
		spr.flip_h = _hero.flip_h
		spr.position = Vector2.ZERO
		_hero.add_child(spr)
		_hero_layers[piece] = spr


func _set_wide_offset(on: bool) -> void:
	_hero.offset = Vector2(-8, -8) * PX if on else Vector2.ZERO
	for piece in _hero_layers.keys():
		var layer: Sprite2D = _hero_layers[piece]
		if layer:
			layer.offset = _hero.offset


func _set_hero_frame(family: String, i: int) -> void:
	_ensure_hero_layers()
	var rel: String = "hero/%s_f%d.png" % [family, i]
	var tex: Texture2D = _home(rel)
	if tex == null:
		tex = _home("%s_f%d" % [family, i])
	if tex:
		_hero.texture = tex
	var head: String = str(gear_worn.get("head", ""))
	for piece in ["rope", "goggles", "cap", "helm"]:
		var layer: Sprite2D = _hero_layers.get(piece)
		if layer == null:
			continue
		layer.centered = _hero.centered
		layer.offset = _hero.offset
		layer.flip_h = _hero.flip_h
		var slot: String = str(extra.get("gear_slots", {}).get(piece, ""))
		var worn: bool = str(gear_worn.get(slot, "")) == piece
		if piece == "cap" or piece == "helm":
			worn = worn and head == piece
		if not worn:
			layer.texture = null
			continue
		layer.texture = KIT.load_tex("hero/gear/%s/%s_f%d.png" % [piece, family, i])


func _walk_family(loot: bool) -> String:
	if _homecoming_kind == "loss":
		return "hero_walk_sad"
	return "hero_walk_loot" if loot else "hero_walk"


func _start_rock() -> void:
	_stop_rock()
	if _rock:
		_rock.stop()
		_rock.visible = false
	_show_empty_chair(false)
	_set_idle_hero_visible(false)
	var main_room = _rooms.get("main")
	_host_hero(main_room if main_room else _int_root)
	_hero.visible = true
	_hero.z_index = 4
	_hero.flip_h = false
	_set_wide_offset(false)
	_place_hero(Vector2(10, 205))
	_rocking = true
	_rock_i = 1
	_set_hero_frame("hero_rock", _rock_i)
	_beat = "rock"
	_tick_rock()


func _tick_rock() -> void:
	if not _rocking or not visible:
		return
	var t := get_tree().create_timer(0.25, true, true, true)
	t.timeout.connect(func() -> void:
		if not _rocking or not visible:
			return
		_rock_i = (_rock_i + 1) % 4
		_set_hero_frame("hero_rock", _rock_i)
		if _rock_i == 0:
			KIT.cue(sfx, &"cabin.rock")
		_tick_rock()
	, CONNECT_ONE_SHOT)


func _stop_rock() -> void:
	_rocking = false
	if _rock:
		_rock.stop()
		_rock.visible = false


func debug_hero_family(family: String, i: int, flip: bool = false) -> void:
	_stop_rock()
	_set_idle_hero_visible(false)
	if _rock:
		_rock.visible = false
	var main_room = _rooms.get("main")
	if main_room:
		_host_hero(main_room)
	_hero.visible = true
	_hero.flip_h = flip
	var wide: bool = family == "hero_sack_dump" or family == "hero_sack_shake"
	var drop: bool = family == "hero_drop_sack"
	var seated: bool = family == "hero_sit" or family == "hero_rock"
	_set_wide_offset(wide)
	if seated:
		_show_empty_chair(false)
		_place_hero(Vector2(10, 205))
	else:
		_show_empty_chair(true)
		_place_hero(Vector2(70, 205) if (wide or drop) else Vector2(80, 205))
	_set_hero_frame(family, i)


func debug_win_dump() -> void:
	debug_hero_family("hero_sack_dump", 2, false)
	_place_debug_loot(false)
	_spawn_hall_glow(false)


func debug_win_fly() -> void:
	debug_hero_family("hero_sack_dump", 2, false)
	_place_debug_loot(true)
	_spawn_hall_glow(false)


func debug_drop_sack(frame: int = 2) -> void:
	debug_hero_family("hero_drop_sack", clampi(frame, 0, 3), true)


func debug_run_door_open(frame: int = 2) -> void:
	var room = _rooms.get("main")
	if room == null:
		return
	var hs = room.spots.get("RunDoor", null)
	if hs == null or not (hs is CabinHotspot):
		return
	var tex: Texture2D = KIT.load_tex("doors/run_door_open_f%d.png" % clampi(frame, 0, 2))
	if tex:
		hs.texture = tex
		hs.position = hs.origin_native * PX
		hs.size = tex.get_size()


func debug_side_door_open(room_id: String = "main") -> void:
	var r = _rooms.get(room_id)
	if r == null:
		return
	var hs = r.spots.get("SideDoor", null)
	if hs == null or not (hs is CabinHotspot):
		return
	var tex: Texture2D = KIT.load_tex("doors/side_door_open.png")
	if tex:
		hs.texture = tex
		hs.position = hs.origin_native * PX
		hs.size = tex.get_size()


func debug_drawer_rattle_frame(frame: int = 1) -> void:
	var hs: CabinHotspot = _drawer_hotspot()
	if hs == null:
		return
	var tex: Texture2D = KIT.load_tex("props/desk_drawer_rattle_f%d.png" % clampi(frame, 0, 2))
	if tex:
		hs.texture = tex
		hs.position = Vector2(200, 166) * PX
		hs.size = tex.get_size()


func debug_drawer_open_frame(frame: int = 3) -> void:
	var hs: CabinHotspot = _drawer_hotspot()
	if hs == null:
		return
	var tex: Texture2D = KIT.load_tex("props/desk_drawer_open_f%d.png" % clampi(frame, 0, 3))
	if tex:
		hs.texture = tex
		hs.position = Vector2(198, 163) * PX
		hs.size = tex.get_size()


func debug_dummy_tilt(side: String = "l") -> void:
	var shop = _rooms.get("workshop")
	if shop == null:
		return
	var hs = shop.spots.get("Dummy", null)
	if hs == null or not (hs is CabinHotspot):
		return
	var rel: String = "props/dummy_tilt_l.png" if side != "r" else "props/dummy_tilt_r.png"
	var tex: Texture2D = KIT.load_tex(rel)
	if tex:
		hs.texture = tex
		hs.position = hs.origin_native * PX
		hs.size = tex.get_size()


func debug_new_burst() -> void:
	var hall = _rooms.get("hall")
	if hall == null or _shelf_host == null:
		return
	var wrap := Control.new()
	wrap.size = _mount_cell()
	wrap.position = Vector2(80, 40)
	wrap.add_to_group("debug_fx")
	_shelf_host.add_child(wrap)
	_play_new_burst(wrap)


func _item_spr_scale(tex: Texture2D, mul: float = 1.0) -> Vector2:
	var w: float = float(tex.get_width()) if tex else 16.0
	var s: float = 64.0 / maxf(w, 1.0)
	return Vector2(s, s) * mul


func _place_debug_loot(flying: bool) -> void:
	if _new_ids.is_empty():
		_new_ids = ["net", "lantern", "caltrops"]
	if _held_ids.is_empty():
		_held_ids = ["throwing_knife", "shield", "net", "lantern", "caltrops"]
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	var from: Vector2 = _pt(69, 231)
	var i: int = 0
	for id3 in _new_ids:
		var tex: Texture2D = tex_by_item.get(str(id3), null)
		if tex == null and art:
			tex = art.item_tex(str(id3))
		if tex == null:
			continue
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = true
		spr.z_index = 7
		spr.name = "DebugLoot%s" % i
		spr.add_to_group("debug_fx")
		spr.scale = _item_spr_scale(tex, 1.35)
		if flying:
			spr.position = from + Vector2(280.0 + float(i) * 110.0, -90.0 - float(i) * 36.0)
		else:
			spr.position = from + Vector2(float(i) * 36.0 - 12.0, -28.0 - float(i % 2) * 18.0)
		main_room.add_child(spr)
		if flying:
			_attach_fly_fx(spr)
		i += 1


func clear_debug_fx() -> void:
	var doomed: Array = []
	for n in get_tree().get_nodes_in_group("debug_fx"):
		doomed.append(n)
	for n2 in doomed:
		if is_instance_valid(n2):
			n2.free()


func _spawn_moth() -> void:
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	var moth := AnimatedSprite2D.new()
	moth.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	moth.centered = false
	moth.position = _pt(60, 198)
	moth.z_index = 8
	moth.sprite_frames = _frames("moth", ["fx/moth_f0.png", "fx/moth_f1.png"], 10.0, true)
	main_room.add_child(moth)
	if moth.sprite_frames:
		moth.play("moth")
	KIT.cue(sfx, &"cabin.moth")
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(moth, "position", moth.position + _pt(-18, -36), 1.2).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(moth, "modulate:a", 0.0, 1.2)
	tw.tween_callback(moth.queue_free)


func _spawn_limp_sack() -> void:
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	if _limp == null:
		_limp = Sprite2D.new()
		_limp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_limp.centered = false
		_limp.z_index = 4
		main_room.add_child(_limp)
	_limp.texture = _home("hero/hero_sack_empty_limp.png")
	_limp.position = _pt(70 + 14, 205 + 24)
	_limp.visible = true
	if _sack:
		_sack.visible = false


func _hide_limp_sack() -> void:
	if _limp:
		_limp.visible = false


func _spawn_sack_pops() -> void:
	var ids: Array = []
	for id in _new_ids:
		ids.append(id)
	var extras: int = 0
	for id2 in _held_ids:
		if _new_ids.has(id2):
			continue
		if extras >= 12:
			break
		ids.append(id2)
		extras += 1
	if ids.is_empty():
		return
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	_spawn_spin_coin(main_room, _pt(69, 220))
	var i: int = 0
	for id3 in ids:
		var tex: Texture2D = tex_by_item.get(str(id3), null)
		if tex == null:
			continue
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.centered = true
		spr.position = _pt(69, 231)
		spr.z_index = 7
		spr.scale = _item_spr_scale(tex, 0.4)
		main_room.add_child(spr)
		_attach_fly_fx(spr)
		KIT.cue(sfx, &"cabin.item_pop")
		var from: Vector2 = spr.position
		var dest: Vector2 = Vector2(ROOM_W + 80.0, from.y - 40.0 - float(i % 5) * 18.0)
		var peak: Vector2 = Vector2((from.x + dest.x) * 0.45, from.y - _px(40))
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(spr, "scale", _item_spr_scale(tex, 1.35), 0.18)
		tw.tween_method(func(t: float) -> void:
			spr.position = _quad_bez(from, peak, dest, t)
		, 0.0, 1.0, 0.55)
		tw.parallel().tween_property(spr, "modulate:a", 0.0, 0.55)
		tw.tween_callback(func() -> void:
			if is_instance_valid(spr):
				spr.queue_free()
		)
		i += 1
		await _wait(0.10)
	_spawn_hall_glow()


func _spawn_spin_coin(host: Node, at_px: Vector2) -> void:
	var rels := ["fx/coin_f0.png", "fx/coin_f1.png", "fx/coin_f2.png", "fx/coin_f3.png"]
	if KIT.load_tex(rels[0]) == null:
		return
	var coin: AnimatedSprite2D = KIT.anim_sprite(rels, "coin", 1000.0 / 80.0, true, Vector2.ZERO)
	coin.centered = true
	coin.position = at_px
	coin.z_index = 8
	host.add_child(coin)
	if coin.sprite_frames:
		coin.play("coin")
	var peak: Vector2 = at_px + Vector2(24, -48) * PX
	var land: Vector2 = at_px + Vector2(40, 8) * PX
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_method(func(t: float) -> void:
		coin.position = _quad_bez(at_px, peak, land, t)
	, 0.0, 1.0, 0.55)
	tw.tween_property(coin, "modulate:a", 0.0, 0.2)
	tw.tween_callback(coin.queue_free)


func _attach_fly_fx(spr: Sprite2D) -> void:
	var spark_rels := ["fx/fly_spark_f0.png", "fx/fly_spark_f1.png", "fx/fly_spark_f2.png"]
	if KIT.load_tex(spark_rels[0]):
		var spark: AnimatedSprite2D = KIT.anim_sprite(spark_rels, "spark", 1000.0 / 80.0, true, Vector2.ZERO)
		spark.centered = true
		spark.z_index = 1
		spr.add_child(spark)
		if spark.sprite_frames:
			spark.play("spark")
	var trail_tex: Texture2D = KIT.load_tex("fx/fly_trail.png")
	if trail_tex:
		var parts := CPUParticles2D.new()
		parts.texture = trail_tex
		parts.amount = 12
		parts.lifetime = 0.35
		parts.emitting = true
		parts.direction = Vector2(-1, 0)
		parts.spread = 18.0
		parts.gravity = Vector2.ZERO
		parts.initial_velocity_min = 20.0
		parts.initial_velocity_max = 60.0
		parts.scale_amount_min = 0.6
		parts.scale_amount_max = 1.2
		parts.z_index = 0
		spr.add_child(parts)


func _spawn_hall_glow(fade: bool = true) -> void:
	var main_room = _rooms.get("main")
	if main_room == null:
		return
	var glow := ColorRect.new()
	glow.name = "HallGlow"
	glow.add_to_group("debug_fx")
	glow.color = Color("fff3d6aa")
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.z_index = 8
	glow.size = Vector2(320, KIT.ROOM_H)
	glow.position = Vector2(ROOM_W - 320.0, 0)
	main_room.add_child(glow)
	if not fade:
		return
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(glow, "modulate:a", 0.0, 1.1)
	tw.tween_callback(glow.queue_free)


func _quad_bez(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * (u * u) + b * (2.0 * u * t) + c * (t * t)
