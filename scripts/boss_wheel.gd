extends Control
## Stone wheel. Frameless sprites (24 native at 2x = 48px). B4 name tag + medallion. HP left, ATK right.

signal slice_clicked(index: int)
signal slice_hovered(index: int)
signal slice_right_clicked(index: int)
signal segment_passed(index: int, speed01: float)
signal atk_ticked
signal hp_ticked
signal stat_style_changed(style: int)

const SHOW_STAT_LAYOUT := false

var show_shift: bool = false

const COPY := preload("res://scripts/player_copy.gd")
const FX_RAYS := preload("res://scripts/fx_rays.gd")
const ABILITY_CARD := preload("res://scripts/ui/ability_card.gd")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")
const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")
const FRAME_METRICS := preload("res://scripts/frame_metrics.gd")
const INK_ON_DARK := Color("f0e6d8")
const TAG_GOLD := Color("FFD84A")
const SHADOW_COL := Color(0.039, 0.024, 0.016, 0.47)
const OUTLINE_PX := Color("100e0c")
const MEDAL_OF := {
	"wizard": "wand",
	"golem": "mountain",
	"goblin": "users",
	"skeleton": "skull",
	"hornet_swarm": "sparkles",
	"lich": "droplet",
	"ogre": "hammer",
	"berserker": "swords",
	"dire_wolf": "footprints",
	"bandit": "trending",
	"two_headed_serpent": "link",
	"slime_boss": "copy",
	"leech_league": "users",
	"wraith": "sparkles",
	"mimic": "layers",
	"spider_queen": "link",
	"commander": "swords",
	"dragon": "wand",
	"needleback": "link",
	"gelatinous_cube": "layers",
	"gargoyle": "mountain",
	"harpy": "sparkles",
	"kobold_trapper": "users",
	"clockwork_knight": "rotate",
	"basilisk": "mountain",
	"zombie": "ban",
	"hollow": "users",
	"beggar": "layers",
	"wick": "trending",
	"anvil": "mountain",
	"vampire": "heart",
	"bodyguard": "shield",
	"cowardly_king": "users",
	"merchant": "layers",
	"oligarch": "layers",
	"juggernaut": "shield",
	"cleric": "heart",
	"hydra": "users",
	"triclops": "users",
	"phoenix_egg": "sparkles",
	"phoenix": "sparkles",
	"amalgam": "rotate",
	"fairy": "heart",
	"eel": "link",
	"druid": "heart",
	"shambling_mound": "swords",
	"almighty_worm": "layers",
	"cultist": "droplet",
	"bushido": "rotate",
	"shark": "swords",
	"mouse": "footprints",
	"magicat": "sparkles",
	"poison_frog": "droplet",
	"rust_bucket": "ban",
	"hired_hand": "users",
	"martyr": "heart",
	"prism": "sparkles",
	"death_bell": "skull",
	"plague_doctor": "droplet",
}

const SIX := PI / 2.0
const EMPTY_FILL := Color("1c1914")
const STONE := Color("2a231e")
const STONE_DEEP := Color("1c1814")
const RING := Color("c4a574")
const HUB := Color("100e0c")
const HUB_FRAC := 0.34
const HUB_HERO_EDGE := 56.0
## 64px Sprout frames draw at 1.5 (96px). 48px frames draw at 2.0, also 96px.
const HUB_SPROUT_SCALE := 1.5
## Display scale of existing 24-native wheel art. Pass 6 shipped 4x/96px; Nathan 2026-10-21: shrink, do not redraw.
## Opaque pixels fill a 48px box on their long axis (empty canvas padding is ignored).
const WHEEL_SPRITE_SCALE := 2.0
const WHEEL_SPRITE_MAX := 48.0
const WHEEL_FIT_H := 96.0
const WHEEL_FIT_W := 100.0
const WHEEL_SCALE_STEP := 0.25
const MEDAL_PX := 28.0
const BADGE_ICON_PX := 24.0
const TAG_H := 48.0
const TAG_H_CALL := 70.0
const FACE_RIM := Color("e8c36a")
const PLACE_RIM := Color("8dcb8d")
const MARK_GREEN := Color("8FD18F")
const MARK_GREEN_HOT := Color("7BC950")
const BRIBE_RIM := Color("d19a66")
const ATK_COL := Color("e8dcc8")
const ATK_FILL := Color("c45a14")
const ATK_EDGE := Color("f0a040")
const HP_COL := Color("f0e6d8")
const HP_FILL := Color("c4282a")
const DOWN_COL := Color("c45c5c")
const UP_COL := Color("7dba7d")
const SPIN_COL := Color("e8c36a")
# Total spin_to tween length. Was 1.2 s; ~30% longer after #138 mid-spin feel.
const SPIN_DURATION := 1.56

var slices: Array = []
var facing_index: int = -1
var selected_index: int = -1
var hover_index: int = -1
var closed_empties: bool = false
var spinning: bool = false
var highlight: String = "none"
var preview: Dictionary = {}
var log_focus: Dictionary = {}
var rot: float = 0.0:
	set(v):
		rot = v
		queue_redraw()

var tex_heart: Texture2D
var tex_poison: Texture2D
var tex_atk: Texture2D
var _atk_variant_cache: Dictionary = {}
var tex_plus: Texture2D
var tex_shield: Texture2D
var tex_heart_full: Texture2D
var tex_heart_empty: Texture2D
var tex_by_id: Dictionary = {}
var tex_special: Dictionary = {}
var tex_portraits: Dictionary = {}
var tex_wheel_frames: Dictionary = {}
var tex_name_tag: Texture2D
var _art = null
var tex_medals: Dictionary = {}
var _used_cache: Dictionary = {}
var _fit_cache: Dictionary = {}
var _fit_sig: String = ""
var _fit_clearance: Array = []
var _tag_fs: Dictionary = {}
var _ability_cards: Array = []
var _chrome_hover: int = -1
var _mark_hover: bool = false
var _mark_tip: PanelContainer = null
var ability_suppressed: bool = false

var _spin_tween: Tween
var _recenter_tween: Tween
var _tick_seg: int = -1
var _tick_last_rot: float = 0.0
var _peak_omega: float = 0.0
var _lift: Dictionary = {}
var _floaters: Array = []
var _flash: Dictionary = {}
var _burn: Dictionary = {}
var _tex_fire: Texture2D
var _hp_disp: Dictionary = {}
var _hp_punch: Dictionary = {}
var _atk_disp: Dictionary = {}
var _atk_punch: Dictionary = {}
var slay_index: int = -1
var slay_kind: String = "slay"
var slay_t: float = 0.0:
	set(v):
		slay_t = v
		queue_redraw()
var collapse: float = 0.0:
	set(v):
		collapse = v
		queue_redraw()
var busy: bool = false
var hub_blk: int = -1
var hub_ghost: int = -1
var portrait_away: int = -1:
	set(v):
		portrait_away = v
		queue_redraw()
var hide_portraits: Array = []:
	set(v):
		hide_portraits = v
		queue_redraw()
var aura_index: int = -1:
	set(v):
		aura_index = v
		queue_redraw()
var threat_indices: Array[int] = []:
	set(v):
		var typed: Array[int] = []
		for x in v:
			typed.append(int(x))
		threat_indices = typed
		queue_redraw()
var hub_on: bool = false
var hub_flash: float = 0.0:
	set(v):
		hub_flash = v
		queue_redraw()
var hub_hp_flash: float = 0.0:
	set(v):
		hub_hp_flash = v
		queue_redraw()
var hub_sting: float = 0.0:
	set(v):
		hub_sting = v
		queue_redraw()
var hub_sting_kind: String = "hurt"
var hub_nudge: Vector2 = Vector2.ZERO:
	set(v):
		hub_nudge = v
		queue_redraw()
var _hub_old: String = ""
var _hub_old_t: float = 0.0:
	set(v):
		_hub_old_t = v
		queue_redraw()
var _hub_hp_old: String = ""
var _hub_hp_old_t: float = 0.0:
	set(v):
		_hub_hp_old_t = v
		queue_redraw()
var _pt_ghosts: Array = []
var tex_player: Array = []
var hub_hp: int = 6
var hub_hp_max: int = 6
var hub_hp_ghost: int = -1
var hub_moves: int = 0
var hub_moves_max: int = 0
## 0 number inside the icon, 1 plate under the icon, 2 both. F5 test button cycles these.
var stat_style: int = 0
var _icon_used: Dictionary = {}
var hurt_preview: bool = false
var move_hint_dir: int = 0
var move_hint_amt: float = 0.0
## Signed hover nudge, in radians. Wedges, sprites, and name tags all read this.
var _hint_ang: float = 0.0
var _scale_note: Dictionary = {}
var _ability_avoids: Array = []
var hub_poison: int = 0
var hub_poison_locked: bool = false
var _poison_drip: Array = []
var _poison_lock_tex: Texture2D
var _poison_badge_scale: Dictionary = {}
var _poison_clear_t: Dictionary = {}
var _aura_glyphs: Dictionary = {}
var _bond_anim: Dictionary = {}
var _bond_prev: Dictionary = {}
var _bond_hold_diff: bool = false
var _facing_for_bonds: int = -1
var threat_t: float = 0.0:
	set(v):
		threat_t = v
		queue_redraw()
var _threat_tween: Tween
var draft_glow: bool = false
var _glow_t: float = 0.0
var _decor_wait: float = 0.0
var hub_pierce: bool = false
signal death_floor

const HERO_PRI := {
	"death": 0,
	"hit": 1,
	"block": 2,
	"heal": 3,
	"swipe": 4,
	"grab": 5,
	"use": 5,
	"victory": 6,
	"lowhp": 7,
	"idle": 8,
	"walkoff": 9,
}
const HERO_GEAR_ORDER := ["rope", "goggles", "cap", "helm"]

var _hero_layout: Dictionary = {}
var _hero_frames: Dictionary = {}
var _hero_gear: Dictionary = {}
var _badge_tex: Dictionary = {}
var hub_gear: Dictionary = {"head": "", "eyes": "", "belt": ""}
var hero_anim: String = "idle"
var hero_frame: int = 0
var _hero_t: float = 0.0
var hub_death_dim: bool = false
var _sprout_hub: bool = false
## Hub Sprout can leave the wheel. Hearts and Block stay.
var hub_sprout_on: bool = true
## Clear-parade overlay owns the hub Sprout; keep the drawn hub hero off.
var hub_parade_hide: bool = false
var hub_flip: bool = false
var hub_sy: float = 1.0
var hub_mod: Color = Color.WHITE
## When set, badge painters draw onto this canvas instead of the wheel.
var _ext_ci: CanvasItem = null
var _sprout_blink_t: float = 0.0
var _sprout_blink_wait: float = 5.0
var _sprout_gear_warned: bool = false
var _hero_hold: bool = false
var _hero_loops: int = 1
var _hero_frozen: bool = false
var _hero_heavy_token: bool = false
var _pierce_float_t: float = -1.0
var _hp_punch_t: float = 0.0
var _blk_punch_t: float = 0.0


func set_hub_pierce(on: bool) -> void:
	if on and not hub_pierce:
		_pierce_float_t = 0.0
	if not on:
		_pierce_float_t = -1.0
	hub_pierce = on
	queue_redraw()


func set_hub_gear(worn: Dictionary) -> void:
	hub_gear = {
		"head": str(worn.get("head", "")),
		"eyes": str(worn.get("eyes", "")),
		"belt": str(worn.get("belt", "")),
	}
	queue_redraw()


func setup_run_hero(art) -> void:
	_art = art
	_hero_layout = {}
	if FileAccess.file_exists("res://assets/dungeon/hero_run/layout.json"):
		var txt: String = FileAccess.get_file_as_string("res://assets/dungeon/hero_run/layout.json")
		var parsed: Variant = JSON.parse_string(txt)
		if typeof(parsed) == TYPE_DICTIONARY:
			_hero_layout = parsed
	_hero_frames.clear()
	_hero_gear.clear()
	_badge_tex.clear()
	_sprout_hub = false
	if art and art.has_method("sprout_anim"):
		var idle: Array = art.sprout_anim("idle")
		if not idle.is_empty():
			_sprout_hub = true
			_hero_frames["idle"] = idle
			_hero_frames["lowhp"] = idle
			_hero_frames["swipe"] = art.sprout_anim("attack")
			_hero_frames["hit"] = art.sprout_anim("hit")
			_hero_frames["block"] = idle
			_hero_frames["heal"] = art.sprout_anim("grab")
			_hero_frames["death"] = art.sprout_anim("defeat")
			_hero_frames["victory"] = art.sprout_anim("victory")
			_hero_frames["grab"] = art.sprout_anim("grab")
			var use_frames: Array = art.sprout_anim("use")
			if use_frames.is_empty():
				use_frames = _hero_frames["grab"]
			_hero_frames["use"] = use_frames
			_hero_frames["walkoff"] = art.sprout_anim("run")
			_hero_frames["blink"] = art.sprout_anim("blink")
			_sprout_blink_t = 0.0
			_sprout_blink_wait = randf_range(4.0, 6.0)
	if not _sprout_hub:
		var anims: Dictionary = _hero_layout.get("anims", {})
		if anims.is_empty():
			anims = {
				"idle": {}, "lowhp": {}, "swipe": {}, "hit": {}, "block": {},
				"heal": {}, "death": {}, "victory": {}, "grab": {}, "walkoff": {},
			}
		for anim in anims.keys():
			var name: String = str(anim)
			if art and art.has_method("hero_run_anim"):
				_hero_frames[name] = art.hero_run_anim(name)
				for piece in HERO_GEAR_ORDER:
					if not _hero_gear.has(piece):
						_hero_gear[piece] = {}
					_hero_gear[piece][name] = art.hero_run_gear(piece, name)
	if art and art.has_method("hero_run_badge"):
		for stem in ["badge_hp", "badge_hp_flash", "badge_hp_low", "badge_hp_empty", "badge_blk", "badge_blk_empty", "badge_blk_up", "badge_blk_pierced"]:
			_badge_tex[stem] = art.hero_run_badge(stem)
	reset_hero()


func _exit_tree() -> void:
	_set_hero_heavy(false)


func _set_hero_heavy(on: bool) -> void:
	if on == _hero_heavy_token:
		return
	_hero_heavy_token = on
	if on:
		FX_BUDGET.begin_heavy()
	else:
		FX_BUDGET.end_heavy()


func reset_hero() -> void:
	hub_death_dim = false
	_pierce_float_t = -1.0
	_hp_punch_t = 0.0
	_blk_punch_t = 0.0
	_hero_frozen = false
	_set_hero_heavy(false)
	play_hero("idle", 1, true)
	queue_redraw()


func play_hero(anim: String, loops: int = 1, force: bool = false) -> void:
	if anim == "":
		return
	if not force:
		var pri: int = int(HERO_PRI.get(anim, 99))
		var cur: int = int(HERO_PRI.get(hero_anim, 99))
		if not _hero_is_loop(hero_anim) and pri > cur:
			return
	hero_anim = anim
	hero_frame = 0
	_hero_t = 0.0
	_hero_hold = false
	_hero_frozen = false
	_hero_loops = maxi(1, loops)
	# Hub now owns combat Sprout FX (face-off left stage retired). Mark heavy so
	# SP-30 still pauses portrait / hall / card idles during swipe / grab / hit.
	_set_hero_heavy(FX_BUDGET.is_heavy_state(anim))
	_on_hero_frame()


func debug_hero(anim: String, frame: int) -> void:
	hero_anim = anim
	hero_frame = maxi(0, frame)
	_hero_t = 0.0
	_hero_hold = true
	_hero_frozen = true
	_hero_loops = 1
	if anim == "death" and hero_frame >= 2:
		hub_death_dim = true
	queue_redraw()


func wait_hero_frame(anim: String, fi: int) -> void:
	if hero_anim != anim:
		play_hero(anim)
	while is_inside_tree() and hero_anim == anim and hero_frame < fi and not _hero_frozen:
		await get_tree().process_frame


func wait_hero_done() -> void:
	while is_inside_tree() and not _hero_is_loop(hero_anim) and not _hero_hold and not _hero_frozen:
		await get_tree().process_frame
	if hero_anim == "death":
		while is_inside_tree() and hero_frame < 4 and not _hero_frozen:
			await get_tree().process_frame


func _hero_is_loop(anim: String) -> bool:
	return anim == "idle" or anim == "lowhp" or anim == "walkoff"


func _hero_is_low() -> bool:
	if hub_hp <= 0:
		return false
	if hub_hp <= 3:
		return true
	return hub_hp_max > 0 and float(hub_hp) / float(hub_hp_max) <= 0.30


func _hero_spec(anim: String) -> Dictionary:
	var anims: Dictionary = _hero_layout.get("anims", {})
	var spec: Variant = anims.get(anim, {})
	if typeof(spec) == TYPE_DICTIONARY:
		return spec
	return {}


func _hero_return_idle() -> void:
	_set_hero_heavy(false)
	var nxt: String = "lowhp" if _hero_is_low() else "idle"
	play_hero(nxt, 1, true)


func _on_hero_frame() -> void:
	if hero_anim == "death":
		if hero_frame >= 2:
			hub_death_dim = true
		if hero_frame == 3:
			death_floor.emit()
	if hero_anim == "block" and hero_frame == 1:
		_start_blk_punch()
	queue_redraw()


func _hero_tick(delta: float) -> void:
	if _pierce_float_t >= 0.0:
		_pierce_float_t += delta
		if _pierce_float_t >= 0.7:
			_pierce_float_t = -1.0
	if _hp_punch_t > 0.0:
		_hp_punch_t = maxf(0.0, _hp_punch_t - delta)
	if _blk_punch_t > 0.0:
		_blk_punch_t = maxf(0.0, _blk_punch_t - delta)
	if _hero_frozen or _hero_hold:
		return
	# Mid-spin: freeze hub idle/lowhp loops — rot redraw already paints.
	if spinning and _hero_is_loop(hero_anim):
		return
	if FX_BUDGET.hold_low_priority_idles() and _hero_is_loop(hero_anim):
		return
	if _hero_is_loop(hero_anim) and (hero_anim == "idle" or hero_anim == "lowhp"):
		var want: String = "lowhp" if _hero_is_low() else "idle"
		if want != hero_anim:
			play_hero(want, 1, true)
			return
	var spec: Dictionary = _hero_spec(hero_anim)
	var ms: Array = spec.get("ms", [])
	var nframes: int = int(spec.get("frames", _hero_frames.get(hero_anim, []).size()))
	if nframes <= 0:
		nframes = 1
	if hero_frame < 0 or hero_frame >= nframes:
		hero_frame = clampi(hero_frame, 0, nframes - 1)
	var wait_ms: float = 180.0
	if hero_frame < ms.size():
		wait_ms = float(ms[hero_frame])
	if wait_ms <= 0.0:
		_hero_hold = true
		hero_frame = nframes - 1
		_on_hero_frame()
		return
	_hero_t += delta
	if _hero_t < wait_ms / 1000.0:
		return
	_hero_t = 0.0
	if hero_frame + 1 < nframes:
		hero_frame += 1
		_on_hero_frame()
		return
	if _hero_loops > 1:
		_hero_loops -= 1
		hero_frame = 0
		_on_hero_frame()
		return
	if str(spec.get("playback", "")) == "loop" or _hero_is_loop(hero_anim):
		hero_frame = 0
		_on_hero_frame()
		return
	_hero_return_idle()


func _start_blk_punch() -> void:
	_blk_punch_t = 0.06
	hub_flash = 1.0


func _start_hp_punch() -> void:
	_hp_punch_t = 0.06
	hub_hp_flash = 1.0


func _layout_xy(folder: String, key: String, fallback: Vector2) -> Vector2:
	var d: Variant = _hero_layout.get(folder, {})
	if typeof(d) != TYPE_DICTIONARY:
		return fallback
	var v: Variant = (d as Dictionary).get(key, null)
	if typeof(v) != TYPE_ARRAY or (v as Array).size() < 2:
		return fallback
	var a: Array = v
	return Vector2(float(a[0]), float(a[1]))


func _badge_xy(which: String, key: String, fallback: Vector2) -> Vector2:
	var badges: Variant = _hero_layout.get("badges", {})
	if typeof(badges) != TYPE_DICTIONARY:
		return fallback
	var d: Variant = (badges as Dictionary).get(which, {})
	if typeof(d) != TYPE_DICTIONARY:
		return fallback
	var v: Variant = (d as Dictionary).get(key, null)
	if typeof(v) != TYPE_ARRAY or (v as Array).size() < 2:
		return fallback
	var a: Array = v
	return Vector2(float(a[0]), float(a[1]))


func _badge_rect_from_c(which: String) -> Rect2:
	var d: Dictionary = _hero_layout.get("badges", {}).get(which, {}) if typeof(_hero_layout.get("badges", {})) == TYPE_DICTIONARY else {}
	var r: Variant = d.get("rect_from_c", [])
	if typeof(r) == TYPE_ARRAY and (r as Array).size() >= 4:
		var a: Array = r
		return Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
	if which == "hp":
		return Rect2(-64, 24, 44, 40)
	return Rect2(-22, 52, 44, 48)


func _heart_arc_layout() -> Dictionary:
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	var n: int = maxi(hub_hp_max, 1)
	var hs: float = clampf(hub_r * 0.25, 20.0, 32.0)
	var r_arc_inner: float = hub_r - 1.3
	var r: float = maxf((r_arc_inner + HUB_HERO_EDGE) * 0.5, HUB_HERO_EDGE + hs * 0.5)
	var span: float = deg_to_rad(112.0)
	if n > 1:
		hs = minf(hs, 2.0 * r * sin(span / float(n - 1) * 0.5) * 0.9)
	var a0: float = -PI * 0.5 - span * 0.5
	var pts: Array = []
	for i in n:
		var t: float = 0.5 if n <= 1 else float(i) / float(n - 1)
		var a: float = a0 + span * t
		pts.append(c + Vector2.from_angle(a) * r)
	return {"pts": pts, "hs": hs, "c": c, "r": r}


func _heart_arc_global_rect() -> Rect2:
	var laid: Dictionary = _heart_arc_layout()
	var pts: Array = laid.get("pts", [])
	var hs: float = float(laid.get("hs", 20.0))
	if pts.is_empty():
		return Rect2()
	var pad: float = hs * 0.6
	var tl: Vector2 = pts[0]
	var br: Vector2 = pts[0]
	for p in pts:
		tl = Vector2(minf(tl.x, p.x), minf(tl.y, p.y))
		br = Vector2(maxf(br.x, p.x), maxf(br.y, p.y))
	var local := Rect2(tl - Vector2(pad, pad), (br - tl) + Vector2(pad, pad) * 2.0)
	return _xform_rect(local)


func _draw_hub_poison_badge(font: Font, dim: float) -> void:
	if hub_poison <= 0:
		return
	_ensure_poison_drip()
	var anchor: Vector2 = _center()
	var pts: Array = _heart_arc_layout().get("pts", [])
	if not pts.is_empty():
		anchor = pts[int(pts.size() / 2)] + Vector2(54, 0)
	var bob: float = 0.0 if hub_poison_locked else (2.0 * sin(_glow_t * 4.0))
	anchor.y += bob
	var sz := Vector2(64, 64)
	# PixelLab drip/burst art already has its purple ramp — draw unmodulated.
	var art_col := Color(1, 1, 1, dim)
	var legacy_col := Color("7dba7d", dim)
	var drip_tex: Texture2D = null
	if not hub_poison_locked and not _poison_drip.is_empty():
		var fi: int = int(floor(_glow_t / 0.15)) % _poison_drip.size()
		drip_tex = _poison_drip[fi]
	if drip_tex != null:
		var ink := Color("100e0c", dim)
		var rim: Vector2 = sz + Vector2(8, 8)
		draw_texture_rect(drip_tex, Rect2(anchor - rim * 0.5, rim), false, ink)
		draw_texture_rect(drip_tex, Rect2(anchor - sz * 0.5, sz), false, art_col)
	else:
		var tex: Texture2D = _poison_tex()
		if tex != null:
			draw_texture_rect(tex, Rect2(anchor - Vector2(20, 20), Vector2(40, 40)), false, Color("100e0c", dim))
			draw_texture_rect(tex, Rect2(anchor - Vector2(16, 16), Vector2(32, 32)), false, legacy_col)
		else:
			draw_circle(anchor, 14.0, Color("100e0c", dim))
			draw_circle(anchor, 10.0, legacy_col)
	_draw_bold_num(font, anchor + Vector2(22, 4), str(hub_poison), 18, Color("d8f0d0", dim))
	if hub_poison_locked and _poison_lock_tex != null:
		draw_texture_rect(_poison_lock_tex, Rect2(anchor + Vector2(10, 8), Vector2(12, 12)), false, Color(1, 1, 1, dim))


func _draw_hub_heart_arc(dim: float) -> void:
	var laid: Dictionary = _heart_arc_layout()
	var pts: Array = laid.get("pts", [])
	var hs: float = float(laid.get("hs", 20.0))
	var n: int = pts.size()
	var punch: bool = hub_hp_flash > 0.12 or _hp_punch_t > 0.0 or (hurt_preview and absf(sin(_glow_t * 7.0)) > 0.35)
	var sz := Vector2(hs, hs)
	if punch:
		sz *= 1.12
	for i in n:
		var live: bool = i < hub_hp
		var soon: bool = hub_hp_ghost >= 0 and i >= hub_hp_ghost and i < hub_hp
		if hub_poison > 0:
			var from_p: int = maxi(0, hub_hp - hub_poison)
			if i >= from_p and i < hub_hp:
				soon = true
		var tint := Color(1, 1, 1, dim)
		if live and hub_hp_ghost >= 0 and i >= hub_hp_ghost and i < hub_hp:
			tint = Color("e07a7a", dim)
		elif live and hub_poison > 0 and i >= maxi(0, hub_hp - hub_poison) and i < hub_hp:
			tint = Color("6ebd6e", dim)
		elif not live:
			tint = Color(1, 1, 1, 0.9 * dim)
		_draw_hub_pip(pts[i], sz, live, soon, tint)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)
	mouse_exited.connect(_on_mouse_out)
	set_process(true)
	_mark_tip = KEYWORD_TIP.new()
	add_child(_mark_tip)
	_mark_tip.setup()
	_mark_tip.z_index = 160
	_mark_tip.top_level = true
	call_deferred("_mount_mark_tip")
	# Dev cycle for where the numbers sit. Off unless this is turned on here.
	if SHOW_STAT_LAYOUT:
		var numbers := Button.new()
		numbers.name = "StatLayout"
		numbers.focus_mode = Control.FOCUS_NONE
		numbers.position = Vector2(8, 8)
		numbers.z_index = 30
		numbers.text = "Numbers: inside"
		numbers.pressed.connect(_cycle_stat_style)
		add_child(numbers)


func _mount_mark_tip() -> void:
	if _mark_tip == null:
		return
	var host: Node = get_tree().root.get_node_or_null("Main")
	if host == null:
		host = get_tree().root
	var layer: CanvasLayer = host.get_node_or_null("MarkTipLayer") as CanvasLayer
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = "MarkTipLayer"
		layer.layer = 90
		host.add_child(layer)
	if _mark_tip.get_parent() != layer:
		if _mark_tip.get_parent() != null:
			_mark_tip.get_parent().remove_child(_mark_tip)
		layer.add_child(_mark_tip)
	_mark_tip.top_level = false
	_mark_tip.z_index = 1
	_mark_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _cycle_stat_style() -> void:
	stat_style = (stat_style + 1) % 3
	var labels: PackedStringArray = PackedStringArray(["Numbers: inside", "Numbers: plate", "Numbers: both"])
	var btn: Node = get_node_or_null("StatLayout")
	if btn is Button:
		(btn as Button).text = labels[stat_style]
	_fit_sig = ""
	stat_style_changed.emit(stat_style)
	queue_redraw()


func set_atlas(heart: Texture2D, sword: Texture2D, plus: Texture2D, by_id: Dictionary, specials: Dictionary, shield: Texture2D = null) -> void:
	tex_heart = heart
	tex_atk = sword
	if ResourceLoader.exists("res://assets/ui/icons/atk_burst.png"):
		var burst: Texture2D = load("res://assets/ui/icons/atk_burst.png") as Texture2D
		if burst != null:
			tex_atk = burst
	tex_plus = plus
	tex_by_id = by_id
	tex_special = specials
	tex_shield = shield
	texture_filter = TEXTURE_FILTER_NEAREST
	_load_wheel_ui()
	queue_redraw()


func set_portraits(d: Dictionary) -> void:
	tex_portraits = d
	_fit_sig = ""
	queue_redraw()


func set_wheel_frames(d: Dictionary) -> void:
	tex_wheel_frames = d
	_fit_sig = ""
	queue_redraw()


func set_player(frames: Array) -> void:
	tex_player = frames
	queue_redraw()


func set_hub_hearts(full: Texture2D, empty: Texture2D) -> void:
	tex_heart_full = full
	tex_heart_empty = empty
	if ResourceLoader.exists("res://assets/ui/hub/heart_full.png"):
		tex_heart_full = load("res://assets/ui/hub/heart_full.png") as Texture2D
	if ResourceLoader.exists("res://assets/ui/hub/heart_empty.png"):
		tex_heart_empty = load("res://assets/ui/hub/heart_empty.png") as Texture2D
	queue_redraw()


func set_vitals(hp_n: int, hp_max: int, hp_ghost: int, blk_n: int, blk_ghost: int) -> void:
	if hub_on and hub_hp != hp_n and hub_hp >= 0:
		_hub_hp_old = "%s/%s" % [hub_hp, hub_hp_max]
		_hub_hp_old_t = 1.0
		hub_hp_flash = 1.0
		var htw := create_tween()
		htw.tween_property(self, "_hub_hp_old_t", 0.0, 0.28)
		var htw2 := create_tween()
		htw2.tween_property(self, "hub_hp_flash", 0.0, 0.34)
	hub_hp = hp_n
	hub_hp_max = maxi(1, hp_max)
	hub_hp_ghost = hp_ghost
	if _hero_is_loop(hero_anim) and (hero_anim == "idle" or hero_anim == "lowhp"):
		var want: String = "lowhp" if _hero_is_low() else "idle"
		if want != hero_anim:
			play_hero(want, 1, true)
	if hub_on and hub_blk != blk_n and hub_blk >= 0:
		_hub_old = str(hub_blk)
		_hub_old_t = 1.0
		var tw := create_tween()
		tw.tween_property(self, "_hub_old_t", 0.0, 0.22)
	hub_blk = blk_n
	hub_ghost = blk_ghost
	hub_on = true
	queue_redraw()


func clear_slay() -> void:
	slay_index = -1
	slay_t = 0.0
	slay_kind = "slay"
	queue_redraw()


func set_slices(next: Array, face: int, mode: String = "none") -> void:
	var slay_key := ""
	if slay_index >= 0 and slay_index < slices.size():
		var held: Dictionary = slices[slay_index]
		slay_key = "%s:%s" % [held.get("kind", ""), held.get("card_id", "")]
	var bonds_before: Dictionary = _bond_prev if _bond_hold_diff else _bond_pair_map()
	_bond_hold_diff = false
	slices = next
	facing_index = face
	_facing_for_bonds = face
	highlight = mode
	_fit_sig = ""
	if slay_index >= 0:
		if slay_index >= slices.size():
			clear_slay()
		else:
			var now: Dictionary = slices[slay_index]
			var now_key := "%s:%s" % [now.get("kind", ""), now.get("card_id", "")]
			if now_key != slay_key:
				clear_slay()
			elif slay_kind == "block" and face != slay_index:
				# Flee leaves the monster in place. Drop BLOCKED once we are no longer facing them.
				clear_slay()
	# Old HP/ATK used to be drawn again on top of the new number for a short fade.
	# That left a second number on the badge and a loose number on the slice.
	_pt_ghosts.clear()
	_bond_prev = _bond_pair_map()
	_start_bond_diff(bonds_before, _bond_prev)
	queue_redraw()


func set_preview(next: Dictionary) -> void:
	preview = next
	queue_redraw()


func set_log_focus(next: Dictionary) -> void:
	log_focus = next
	queue_redraw()


func set_hub(blk_n: int, ghost: int, on: bool) -> void:
	if on and hub_on and hub_blk != blk_n and hub_blk >= 0:
		_hub_old = str(hub_blk)
		_hub_old_t = 1.0
		var tw := create_tween()
		tw.tween_property(self, "_hub_old_t", 0.0, 0.22)
	hub_blk = blk_n
	hub_ghost = ghost
	hub_on = on
	queue_redraw()


func punch_hub() -> void:
	_start_blk_punch()
	var tw := create_tween()
	tw.tween_property(self, "hub_flash", 0.0, 0.06)


## Small player-hub hit / block tell. Not the faced-slice BLOCKED stamp.
## release_early: return after the knock snap so resolve overlaps the settle.
func play_hub_sting(kind: String, amount: int = 0, release_early: bool = false) -> void:
	hub_sting_kind = kind
	hub_sting = 1.0
	var c: Vector2 = _center()
	if kind == "hurt":
		play_hero("hit")
		if amount > 0:
			var hp_anchor: Vector2 = _badge_xy("hp", "number_anchor_from_c", Vector2(-42, 41))
			_floaters.append({
				"pos": c + hp_anchor,
				"text": "-%s" % amount,
				"col": DOWN_COL,
				"t": 0.0,
				"life": 0.7,
			})
			_start_hp_punch()
			var htw := create_tween()
			htw.tween_property(self, "hub_hp_flash", 0.0, 0.26)
	elif kind == "block":
		play_hero("block")
	var knock := Vector2(5.0, 3.0) if kind == "hurt" else Vector2(-2.5, 0.0)
	var dur: float = 0.30 if kind == "hurt" else 0.34
	var tw := create_tween()
	tw.tween_property(self, "hub_nudge", knock, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hub_nudge", Vector2.ZERO, dur - 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fade := create_tween()
	fade.tween_property(self, "hub_sting", 0.0, dur)
	if release_early:
		# Knock snap is the tell; settle continues while resolve moves on.
		await get_tree().create_timer(0.06).timeout
		return
	await tw.finished


func play_slay(index: int) -> void:
	busy = true
	slay_kind = "slay"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.55)
	await tw.finished
	busy = false


func play_escape(index: int) -> void:
	busy = true
	slay_kind = "escape"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.5)
	await tw.finished
	busy = false


## Faced-slice BLOCKED stamp. release_early returns once the word is readable
## (slay_t > 0.18) so Take/resolve does not wait out the full 0.5s hold.
func play_block(index: int, release_early: bool = false) -> void:
	busy = true
	slay_kind = "block"
	slay_index = index
	slay_t = 0.0
	var tw := create_tween()
	tw.tween_property(self, "slay_t", 1.0, 0.5)
	if release_early:
		await get_tree().create_timer(0.20).timeout
		busy = false
		return
	await tw.finished
	busy = false


func collapse_slice(index: int, pin: int = -1) -> void:
	busy = true
	slay_index = index
	collapse = 0.0
	_bond_prev = _bond_pair_map()
	_bond_hold_diff = true
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_IN)
	if pin >= 0 and pin != index:
		tw.tween_method(
			func(v: float) -> void:
				collapse = v
				rot = rot_to_center(pin)
				queue_redraw(),
			0.0,
			1.0,
			0.48
		)
	else:
		tw.tween_property(self, "collapse", 1.0, 0.48)
	await tw.finished
	if pin >= 0 and pin != index:
		rot = rot_to_center(pin)
	else:
		var base: float = rot
		var jostle := create_tween()
		jostle.tween_property(self, "rot", base + 0.055, 0.07)
		jostle.tween_property(self, "rot", base - 0.035, 0.08)
		jostle.tween_property(self, "rot", base, 0.08)
		await jostle.finished
	busy = false
	slay_index = -1
	slay_kind = "slay"
	collapse = 0.0
	slay_t = 0.0
	_bond_hold_diff = true
	queue_redraw()


func pulse_arrive(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_lift[index] = 1.25
	queue_redraw()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_method(
		func(v: float) -> void:
			_lift[index] = v
			queue_redraw(),
		1.25,
		0.0,
		0.42
	)


func hit_feedback(index: int, hp_lost: int, atk_delta: int = 0) -> void:
	if index < 0 or index >= slices.size():
		return
	_flash[index] = 0.5
	var pos: Vector2 = _hp_pos(index)
	if hp_lost > 0:
		_floaters.append({"pos": pos, "text": "-%s" % hp_lost, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	elif hp_lost < 0:
		_floaters.append({"pos": pos, "text": "+%s" % -hp_lost, "col": UP_COL, "t": 0.0, "life": 0.9})
	if atk_delta < 0:
		_floaters.append({"pos": _atk_pos(index), "text": "%s" % atk_delta, "col": DOWN_COL, "t": 0.0, "life": 0.9})
	elif atk_delta > 0:
		_floaters.append({"pos": _atk_pos(index), "text": "+%s" % atk_delta, "col": UP_COL, "t": 0.0, "life": 0.9})
	queue_redraw()


func rotation_for_index(index: int) -> float:
	var n: int = _n()
	var ang: float = TAU / float(n)
	var center_at_zero: float = float(index) * ang + ang * 0.5
	return SIX - center_at_zero


func _seg_under_pointer() -> int:
	var n: int = _n()
	var ang: float = TAU / float(n)
	var shifted: float = fposmod(SIX - rot - ang * 0.5, TAU)
	return posmod(int(floor(shifted / ang)), n)


func rotation_for_top(index: int) -> float:
	return rotation_for_index(index) + PI


func rotate_index_to_top(index: int, dur: float = 0.42) -> void:
	if index < 0 or index >= slices.size():
		return
	var target: float = rotation_for_top(index)
	var delta: float = fposmod(target - rot + PI, TAU) - PI
	if absf(delta) < 0.01:
		rot = fposmod(target, TAU)
		return
	busy = true
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "rot", rot + delta, dur)
	await tw.finished
	rot = fposmod(rot, TAU)
	busy = false
	queue_redraw()


func rot_to_center(index: int) -> float:
	if index < 0 or index >= slices.size():
		return rot
	var mid: float = _span(index) * 0.5
	for i in index:
		mid += _span(i)
	return SIX - mid


func snap_to_index(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	rot = fposmod(rotation_for_index(index), TAU)
	facing_index = index
	queue_redraw()


func set_moves(left: int, cap: int) -> void:
	hub_moves = maxi(0, left)
	hub_moves_max = maxi(0, cap)
	queue_redraw()


func set_ability_avoids(rects: Array) -> void:
	_ability_avoids = rects
	_sync_ability_cards()


func recenter_on(index: int, dur: float = 0.28) -> void:
	if index < 0 or index >= slices.size():
		return
	var target: float = rotation_for_index(index)
	var delta: float = fposmod(target - rot + PI, TAU) - PI
	if absf(delta) < 0.01:
		rot = fposmod(target, TAU)
		return
	_kill_recenter()
	busy = true
	_recenter_tween = create_tween()
	_recenter_tween.set_trans(Tween.TRANS_CUBIC)
	_recenter_tween.set_ease(Tween.EASE_OUT)
	_recenter_tween.tween_property(self, "rot", rot + delta, dur)
	while _recenter_tween != null and _recenter_tween.is_valid() and _recenter_tween.is_running():
		await get_tree().process_frame
	if _recenter_tween != null and _recenter_tween.is_valid():
		rot = fposmod(rot, TAU)
	_recenter_tween = null
	busy = false
	queue_redraw()


func spin_to(index: int) -> void:
	if _spin_tween != null:
		_spin_tween.kill()
	if slay_index >= 0:
		clear_slay()
	spinning = true
	FX_BUDGET.set_spinning(true)
	facing_index = -1
	hover_index = -1
	preview.clear()
	for card in _ability_cards:
		card.visible = false
	queue_redraw()
	var target: float = rotation_for_index(index)
	var instant: bool = OS.has_feature("editor") and bool(get_meta("qa_instant", false))
	if instant:
		rot = fposmod(target, TAU)
		spinning = false
		FX_BUDGET.set_spinning(false)
		facing_index = index
		queue_redraw()
		return
	var delta: float = fposmod(target - rot, TAU)
	if delta < 0.45:
		delta += TAU
	delta += TAU
	_spin_tween = create_tween()
	_spin_tween.set_ignore_time_scale(true)
	_spin_tween.set_trans(Tween.TRANS_CUBIC)
	_spin_tween.set_ease(Tween.EASE_IN_OUT)
	_tick_seg = -1
	_tick_last_rot = rot
	_peak_omega = 0.0
	_spin_tween.tween_property(self, "rot", rot + delta, SPIN_DURATION)
	await _spin_tween.finished
	rot = fposmod(rot, TAU)
	spinning = false
	FX_BUDGET.set_spinning(false)
	facing_index = index
	_play_threat()
	queue_redraw()


func _kill_recenter() -> void:
	if _recenter_tween != null:
		_recenter_tween.kill()
		_recenter_tween = null
	busy = false


func kill_spin() -> void:
	if _spin_tween != null:
		_spin_tween.kill()
		_spin_tween = null
	spinning = false
	FX_BUDGET.set_spinning(false)
	_kill_recenter()


func _n() -> int:
	return maxi(slices.size(), 1)


func _center() -> Vector2:
	return size * 0.5


func _play_threat() -> void:
	if _threat_tween != null:
		_threat_tween.kill()
	threat_t = 0.0
	_threat_tween = create_tween()
	_threat_tween.tween_property(self, "threat_t", 1.0, 0.72).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _radius() -> float:
	return minf(size.x, size.y) * 0.48


func _process(delta: float) -> void:
	_glow_t += delta
	# One angle for the whole wheel. Seats used to snap in 0.02 rad steps while the wedges eased, so the art looked like it was stuttering against the rim.
	var hint_goal: float = -0.32 * float(move_hint_dir)
	var hint_k: float = 1.0 - exp(-delta * 8.0)
	_hint_ang = lerpf(_hint_ang, hint_goal, hint_k)
	if absf(_hint_ang - hint_goal) < 0.0004:
		_hint_ang = hint_goal
	move_hint_amt = clampf(absf(_hint_ang) / 0.32, 0.0, 1.0)
	var anim_dirty: bool = false
	for k in _bond_anim.keys():
		var ent: Dictionary = _bond_anim[k]
		ent["t"] = float(ent.get("t", 0.0)) + delta
		_bond_anim[k] = ent
		anim_dirty = true
	if anim_dirty:
		queue_redraw()
	if spinning:
		var drot: float = absf(rot - _tick_last_rot)
		_tick_last_rot = rot
		var omega: float = drot / maxf(delta, 0.0001)
		if omega > _peak_omega:
			_peak_omega = omega
		var speed01: float = omega / maxf(_peak_omega, 0.001)
		var seg: int = _seg_under_pointer()
		if seg != _tick_seg:
			_tick_seg = seg
			segment_passed.emit(seg, speed01)
	for i in slices.size():
		var want: float = 0.0
		if not spinning:
			if i == selected_index and facing_index < 0:
				want = 0.62 + 0.28 * sin(_glow_t * 5.0)
			elif threat_indices.has(i) and facing_index < 0:
				want = 0.72 + 0.28 * sin(_glow_t * 7.0)
			elif highlight == "mark" and i < slices.size() and bool(slices[i].get("markable", false)):
				want = 0.78 + 0.22 * absf(sin(_glow_t * 6.5))
			elif i == hover_index:
				want = 0.7
			elif i == facing_index:
				want = 0.12
		var cur: float = float(_lift.get(i, 0.0))
		var nxt: float = lerpf(cur, want, clampf(delta * 10.0, 0.0, 1.0))
		if absf(nxt - cur) > 0.002:
			_lift[i] = nxt
		else:
			_lift[i] = want
	var keep: Array = []
	for f in _floaters:
		f["t"] = float(f["t"]) + delta
		if float(f["t"]) < float(f["life"]):
			keep.append(f)
	_floaters = keep
	var gkeep: Array = []
	for g in _pt_ghosts:
		g["t"] = float(g["t"]) + delta
		if float(g["t"]) < float(g["life"]):
			gkeep.append(g)
	_pt_ghosts = gkeep
	var flash_keep := {}
	for k in _flash.keys():
		var t: float = float(_flash[k]) - delta
		if t > 0.0:
			flash_keep[k] = t
	_flash = flash_keep
	var burn_keep := {}
	for bk in _burn.keys():
		var bv: float = float(_burn[bk]) - delta * 1.6
		if bv > 0.02:
			burn_keep[bk] = bv
	_burn = burn_keep
	var punch_keep := {}
	for pk in _hp_punch.keys():
		var pv: float = float(_hp_punch[pk]) - delta * 3.4
		if pv > 0.02:
			punch_keep[pk] = pv
	_hp_punch = punch_keep
	var atk_punch_keep := {}
	for ak in _atk_punch.keys():
		var av: float = float(_atk_punch[ak]) - delta * 3.4
		if av > 0.02:
			atk_punch_keep[ak] = av
	_atk_punch = atk_punch_keep
	_hero_tick(delta)
	if not spinning:
		_sync_chrome_hover()
		_sync_mark_hover()
		_sync_ability_cards()
		# Mid-spin: `rot` setter already queue_redraws each tween tick.
		# note_wheel lives in `_draw` (truthful, same as hall).
		if _wheel_wants_live_draw():
			_queue_decor_redraw(delta)


func _wheel_wants_live_draw() -> bool:
	# Hit / punch / burn / floater reads always paint — attack must stay readable.
	if not _floaters.is_empty() or not _pt_ghosts.is_empty():
		return true
	if not _flash.is_empty() or not _hp_punch.is_empty() or not _atk_punch.is_empty() or not _burn.is_empty():
		return true
	if not _bond_anim.is_empty():
		return true
	# Non-loop hub combat anims (swipe / grab / hit / attack) need paced
	# redraws — `_on_hero_frame` already queues, but decor capping still
	# applies between advances when heavy FX is up.
	if hub_sprout_on and not hub_parade_hide and not _hero_is_loop(hero_anim) and not _hero_hold and not _hero_frozen:
		return true
	# During attack/slash heavy, pause decorative-only live draws (hover,
	# selected/threat pulse, draft glow, hall-adjacent poison bob, rage
	# seat fire, hint arc). Seat idles already freeze via `_wheel_idle_held`.
	if FX_BUDGET.hold_low_priority_idles():
		return false
	if facing_index < 0 and (selected_index >= 0 or not threat_indices.is_empty()):
		return true
	if hover_index >= 0:
		return true
	if _mark_hover:
		return true
	for marked in slices:
		if bool(marked.get("hunter_mark", false)):
			return true
	if hurt_preview or draft_glow or hub_poison > 0:
		return true
	if absf(_hint_ang) > 0.0004:
		return true
	for s in slices:
		if bool(s.get("rage_fire", false)):
			return true
	return false


func _queue_decor_redraw(delta: float) -> void:
	# Uses CombatFxBudget.decor_step(): heavy→4fps, else→12fps (web + desktop
	# fight-idle). Spin redraws come from the `rot` setter, not this path.
	# note_wheel is counted in `_draw`.
	var step: float = FX_BUDGET.decor_step()
	if step <= 0.0:
		queue_redraw()
		return
	_decor_wait -= delta
	if _decor_wait > 0.0:
		return
	_decor_wait = step
	queue_redraw()


func slice_at(local: Vector2) -> int:
	if slices.is_empty() or spinning or busy:
		return -1
	var c: Vector2 = _center()
	var v: Vector2 = local - c
	var radius: float = _radius()
	var d: float = v.length()
	if d < radius * 0.22 or d > radius * 1.22:
		return -1
	var a: float = fposmod(v.angle() - rot, TAU)
	var starts: PackedFloat32Array = _starts()
	var n: int = slices.size()
	for i in n:
		var a0: float = fposmod(starts[i] - rot, TAU)
		var a1: float = a0 + _span(i)
		if a >= a0 and a < a1:
			return i
		if a1 > TAU and a < a1 - TAU:
			return i
	return clampi(int(a / (TAU / float(n))), 0, n - 1)


func _gui_input(event: InputEvent) -> void:
	if spinning or busy:
		return
	if event is InputEventMouseMotion:
		var i: int = slice_at(event.position)
		if i != hover_index:
			hover_index = i
			slice_hovered.emit(i)
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		var i2: int = slice_at(event.position)
		if i2 < 0:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			slice_clicked.emit(i2)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slice_right_clicked.emit(i2)


func _on_mouse_out() -> void:
	if hover_index != -1:
		hover_index = -1
		slice_hovered.emit(-1)
		queue_redraw()
	_set_mark_hover(false)


func _lift_of(i: int) -> float:
	return float(_lift.get(i, 0.0))


func _weight(i: int) -> float:
	if i == slay_index:
		return maxf(1.0 - collapse, 0.02)
	return 1.0


func _span(i: int) -> float:
	var tot: float = 0.0
	for j in slices.size():
		tot += _weight(j)
	if tot <= 0.0:
		return TAU / float(_n())
	return TAU * _weight(i) / tot


func _move_hint_angle() -> float:
	# Left hover is move_hint_dir +1. That click faces the monster on the left,
	# and the wheel turns counterclockwise to get there.
	return _hint_ang


func _starts() -> PackedFloat32Array:
	return _wedge_starts(rot + _move_hint_angle())


func _wedge_starts(base_angle: float) -> PackedFloat32Array:
	var n: int = slices.size()
	var s := PackedFloat32Array()
	s.resize(n)
	var a: float = base_angle
	for i in n:
		s[i] = a
		a += _span(i)
	return s


func _dir_of(i: int) -> Vector2:
	var starts: PackedFloat32Array = _starts()
	if i < 0 or i >= starts.size():
		return Vector2.DOWN
	var mid: float = starts[i] + _span(i) * 0.5
	return Vector2.from_angle(mid)


func _bezel_pos(i: int) -> Vector2:
	return _hp_pos(i)


func _spoke(i: int) -> Dictionary:
	# Fit + seat chrome live in base (rot=0) space; spin the whole spoke by
	# live wheel angle + move-hint. Keeps pass6 fit cached across a Spin.
	var built: Dictionary = _spoke_rest(i)
	return _spin_spoke(built, rot + _move_hint_angle())


func _spoke_rest(i: int) -> Dictionary:
	var c: Vector2 = _center()
	# Base-space geometry (rot=0). `_spoke` applies live rot + hint.
	var starts: PackedFloat32Array = _wedge_starts(0.0)
	var dir: Vector2 = Vector2.DOWN
	if i >= 0 and i < starts.size():
		dir = Vector2.from_angle(starts[i] + _span(i) * 0.5)
	var tan: Vector2 = Vector2(-dir.y, dir.x)
	var lift: float = _lift_of(i)
	# Slay push must use base dir here — `_dir_of` is live (rot+hint).
	var push: Vector2 = Vector2.ZERO
	if i == slay_index and collapse > 0.0:
		push = dir * collapse * _radius() * 0.42
	var origin: Vector2 = c + dir * (lift * 8.0) + push
	var r: float = _radius() + lift * 12.0
	var sz: Vector2 = _seat_sprite_size(i)
	var w: float = sz.x
	var h: float = sz.y
	var feet: Vector2 = origin
	var table: Array = _fit_table(slices.size())
	if i >= 0 and i < table.size():
		feet = table[i] + dir * (lift * 8.0) + push
	else:
		feet = origin + dir * (r * 0.60)
	if _breathe_bob(i):
		var odd: int = int(_glow_t / 0.6 + float(i) * 0.37) % 2
		feet += Vector2(0, -4.0 if odd == 1 else 0.0)
	var port: Vector2 = feet - Vector2(0, h * 0.5)
	var dx: float = clampf(w * 0.5 - 4.0, 30.0, 40.0)
	var hp: Vector2 = feet + Vector2(-dx, -8.0)
	var atk: Vector2 = feet + Vector2(dx, -8.0)
	var tag_w: float = _tag_width_px(i)
	var tag_h: float = _tag_height_px(i)
	var tag_rect := Rect2(Vector2(feet.x - tag_w * 0.5, feet.y + 10.0), Vector2(tag_w, tag_h))
	var icon_px := 36.0
	var atk_rect := Rect2(atk - Vector2(icon_px * 0.5, icon_px * 0.5), Vector2(icon_px, icon_px))
	var hp_rect := Rect2(hp - Vector2(icon_px * 0.5, icon_px * 0.5), Vector2(icon_px, icon_px))
	var shell := tag_rect.grow_individual(18.0, 2.0, 4.0, 2.0)
	var steps := 0
	while steps < 16 and (shell.intersects(atk_rect.grow(4.0)) or shell.intersects(hp_rect.grow(4.0))):
		tag_rect.position.y += 4.0
		shell.position.y += 4.0
		steps += 1
	var medal := Vector2(tag_rect.position.x - 2.0, tag_rect.position.y + tag_h * 0.5)
	var sprite_rect := Rect2(Vector2(feet.x - w * 0.5, feet.y - h), Vector2(w, h))
	return {
		"c": c,
		"dir": dir,
		"tan": tan,
		"origin": origin,
		"r": r,
		"win": h if h > 1.0 else 48.0,
		"plate_r": 48.0,
		"port": port,
		"feet": feet,
		"name": Vector2(feet.x, feet.y + 60.0),
		"atk": atk,
		"hp": hp,
		"tag_rect": tag_rect,
		"medal": medal,
		"sprite_rect": sprite_rect,
		"span": _span(i),
	}


func slice_portrait_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	var local: Vector2 = _spoke(i)["port"]
	return get_global_transform() * local


func slice_avoid_global(i: int) -> Rect2:
	if i < 0 or i >= slices.size():
		return Rect2(global_position, Vector2(8, 8))
	var sp: Dictionary = _spoke(i)
	var local: Rect2 = sp.get("sprite_rect", Rect2())
	var tag: Rect2 = sp.get("tag_rect", Rect2())
	if tag.size.x > 1.0:
		local = local.merge(tag)
	var medal: Vector2 = sp.get("medal", Vector2.ZERO)
	local = local.merge(Rect2(medal - Vector2(MEDAL_PX * 0.5, MEDAL_PX * 0.5), Vector2(MEDAL_PX, MEDAL_PX)))
	local = local.merge(Rect2(sp["hp"] - Vector2(BADGE_ICON_PX * 0.5, BADGE_ICON_PX * 0.5), Vector2(BADGE_ICON_PX, BADGE_ICON_PX)))
	local = local.merge(Rect2(sp["atk"] - Vector2(BADGE_ICON_PX * 0.5, BADGE_ICON_PX * 0.5), Vector2(BADGE_ICON_PX, BADGE_ICON_PX)))
	return _xform_rect(local)


func hub_edge_global(i: int) -> Vector2:
	var c: Vector2 = _center()
	var dir: Vector2 = _dir_of(i)
	var hub_r: float = _radius() * HUB_FRAC
	return get_global_transform() * (c + dir * (hub_r + 40.0))


func qa_hover_chrome(i: int) -> void:
	hover_index = i
	_chrome_hover = i
	_sync_ability_cards()
	queue_redraw()


func fit_clearances() -> Array:
	_fit_table(slices.size())
	return _fit_clearance.duplicate()


func _xform_rect(r: Rect2) -> Rect2:
	var xf: Transform2D = get_global_transform()
	var p1: Vector2 = xf * r.position
	var p2: Vector2 = xf * (r.position + Vector2(r.size.x, 0))
	var p3: Vector2 = xf * (r.position + Vector2(0, r.size.y))
	var p4: Vector2 = xf * r.end
	var tl := Vector2(minf(minf(p1.x, p2.x), minf(p3.x, p4.x)), minf(minf(p1.y, p2.y), minf(p3.y, p4.y)))
	var br := Vector2(maxf(maxf(p1.x, p2.x), maxf(p3.x, p4.x)), maxf(maxf(p1.y, p2.y), maxf(p3.y, p4.y)))
	return Rect2(tl, br - tl)


func hp_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	return get_global_transform() * _hp_pos(i)


func atk_global(i: int) -> Vector2:
	if i < 0 or i >= slices.size():
		return global_position
	return get_global_transform() * _atk_pos(i)


func hub_hearts_global() -> Vector2:
	var laid: Dictionary = _heart_arc_layout()
	var pts: Array = laid.get("pts", [])
	if pts.is_empty():
		return get_global_transform() * _center()
	var mid: int = int(pts.size() / 2)
	return get_global_transform() * pts[mid]


func hub_blk_global() -> Vector2:
	var c: Vector2 = _center()
	var local: Rect2 = _badge_rect_from_c("blk")
	var vis: Vector2 = _badge_xy("blk", "visual_centre_from_c", local.position + local.size * 0.5)
	return get_global_transform() * (c + vis)


func play_burn(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_burn[index] = 1.0
	_flash[index] = 0.7
	queue_redraw()
	if get_tree():
		await get_tree().create_timer(0.34).timeout


func _fire_tex() -> Texture2D:
	if _tex_fire == null and ResourceLoader.exists("res://assets/dungeon/vfx/fire.png"):
		_tex_fire = load("res://assets/dungeon/vfx/fire.png") as Texture2D
	return _tex_fire


func punch_hp(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_hp_punch[index] = 1.0
	_flash[index] = 0.55
	queue_redraw()


func punch_atk(index: int) -> void:
	if index < 0 or index >= slices.size():
		return
	_atk_punch[index] = 1.0
	_flash[index] = 0.55
	queue_redraw()


func play_atk_ticks(index: int, from_n: int, to_n: int) -> void:
	if index < 0 or index >= slices.size() or from_n == to_n:
		punch_atk(index)
		return
	var step: int = -1 if to_n < from_n else 1
	var n: int = from_n
	_atk_disp[index] = n
	punch_atk(index)
	while n != to_n:
		n += step
		_atk_disp[index] = n
		punch_atk(index)
		atk_ticked.emit()
		if get_tree():
			await get_tree().create_timer(0.035).timeout
	_atk_disp.erase(index)
	queue_redraw()


func play_hp_ticks(index: int, from_n: int, to_n: int) -> void:
	if index < 0 or index >= slices.size() or from_n == to_n:
		punch_hp(index)
		return
	var step: int = -1 if to_n < from_n else 1
	var n: int = from_n
	_hp_disp[index] = n
	punch_hp(index)
	while n != to_n:
		n += step
		_hp_disp[index] = n
		punch_hp(index)
		hp_ticked.emit()
		if get_tree():
			await get_tree().create_timer(0.035).timeout
	_hp_disp.erase(index)
	queue_redraw()


func _atk_pos(i: int) -> Vector2:
	return _spoke(i)["atk"]


func _hp_pos(i: int) -> Vector2:
	return _spoke(i)["hp"]


func focus_rect(kind: String) -> Rect2:
	var c: Vector2 = _center()
	if kind == "hub_hp":
		return _heart_arc_global_rect()
	if kind == "hub_blk":
		var local: Rect2 = _badge_rect_from_c("blk")
		var vis: Vector2 = _badge_xy("blk", "visual_centre_from_c", local.position + local.size * 0.5)
		return _global_badge(c + vis, maxf(local.size.x, local.size.y) * 0.55)
	if kind == "atk" and facing_index >= 0:
		return _global_badge(_atk_pos(facing_index), 34.0)
	if kind == "hp" and facing_index >= 0:
		return _global_badge(_hp_pos(facing_index), 34.0)
	if kind == "empty":
		return _slice_annulus_rect(_first_empty_slice())
	if kind == "moves" and hub_moves_max > 0:
		var hub_r: float = _radius() * HUB_FRAC
		var gap: float = 24.0
		var y: float = c.y + hub_r - 16.0
		var total: float = gap * float(hub_moves_max - 1)
		var left: float = c.x - total * 0.5 - 16.0
		var right: float = c.x + total * 0.5 + 16.0
		var xf: Transform2D = get_global_transform()
		var p0: Vector2 = xf * Vector2(left, y - 16.0)
		var p1: Vector2 = xf * Vector2(right, y + 16.0)
		return Rect2(p0, p1 - p0)
	if kind == "face" and facing_index >= 0:
		return _slice_global_rect(facing_index)
	return Rect2()


func _global_badge(local: Vector2, rad: float) -> Rect2:
	var g: Vector2 = get_global_transform() * local
	return Rect2(g - Vector2(rad, rad), Vector2(rad * 2.0, rad * 2.0))


func _first_empty_slice() -> int:
	for i in slices.size():
		if str(slices[i].get("kind", "")) != "monster":
			return i
	return -1


func slice_rect(i: int) -> Rect2:
	return _slice_global_rect(i)


func _slice_annulus_rect(i: int) -> Rect2:
	if i < 0 or i >= slices.size():
		return Rect2()
	var starts: PackedFloat32Array = _starts()
	var a0: float = starts[i]
	var a1: float = a0 + _span(i)
	var c: Vector2 = _center()
	var radius: float = _radius()
	var inner: float = radius * 0.42
	var mn := Vector2(1.0e9, 1.0e9)
	var mx := Vector2(-1.0e9, -1.0e9)
	for k in 9:
		var ang: float = lerpf(a0, a1, float(k) / 8.0)
		for rad in [inner, radius]:
			var g: Vector2 = get_global_transform() * (c + Vector2.from_angle(ang) * rad)
			mn.x = minf(mn.x, g.x)
			mn.y = minf(mn.y, g.y)
			mx.x = maxf(mx.x, g.x)
			mx.y = maxf(mx.y, g.y)
	return Rect2(mn, mx - mn).grow(4.0)


func _slice_global_rect(i: int) -> Rect2:
	if i < 0 or i >= slices.size():
		return Rect2()
	var starts: PackedFloat32Array = _starts()
	var a0: float = starts[i]
	var a1: float = a0 + _span(i)
	var c: Vector2 = _center()
	var radius: float = _radius()
	var mn := Vector2(1.0e9, 1.0e9)
	var mx := Vector2(-1.0e9, -1.0e9)
	var pts: Array[Vector2] = [c]
	for k in 9:
		pts.append(c + Vector2.from_angle(lerpf(a0, a1, float(k) / 8.0)) * radius)
	for p in pts:
		var g: Vector2 = get_global_transform() * p
		mn.x = minf(mn.x, g.x)
		mn.y = minf(mn.y, g.y)
		mx.x = maxf(mx.x, g.x)
		mx.y = maxf(mx.y, g.y)
	return Rect2(mn, mx - mn).grow(10.0)


func _clamp_to_rim(pos: Vector2, icon_r: float) -> Vector2:
	# Kept for old callers. Badges no longer clamp to the rim.
	return pos


func _load_wheel_ui() -> void:
	if ResourceLoader.exists("res://assets/ui/wheel/name_tag.png"):
		tex_name_tag = load("res://assets/ui/wheel/name_tag.png") as Texture2D
	for key in MEDAL_OF.values():
		var path := "res://assets/ui/wheel/medallion_%s.png" % str(key)
		if ResourceLoader.exists(path):
			tex_medals[str(key)] = load(path) as Texture2D


func _medal_key(id: String) -> String:
	return str(MEDAL_OF.get(id, "sparkles"))


func _medal_tex(id: String) -> Texture2D:
	return tex_medals.get(_medal_key(id), null)


func medal_tex_for(card_id: String) -> Texture2D:
	if tex_medals.is_empty():
		_load_wheel_ui()
	return _medal_tex(card_id)


func ability_color_for(sid: String) -> Color:
	return _ability_icon_color(sid)


func _wheel_tex(i: int) -> Texture2D:
	if i < 0 or i >= slices.size():
		return null
	var pid: String = str(slices[i].get("card_id", ""))
	var frames: Array = tex_wheel_frames.get(pid, [])
	if frames.is_empty():
		if tex_portraits.has(pid):
			return tex_portraits[pid]
		return null
	if frames.size() == 1 or _wheel_idle_held(i):
		return frames[0]
	# 200ms per frame. Process delta already follows Engine.time_scale, so Shift speeds this.
	var fi: int = int(_glow_t / 0.2 + float(i) * 0.37) % frames.size()
	return frames[fi]


func _wheel_idle_held(i: int) -> bool:
	if i < 0 or i >= slices.size():
		return true
	var s: Dictionary = slices[i]
	if int(s.get("hp", 1)) <= 0:
		return true
	if bool(s.get("fled_once", false)):
		return true
	if bool(s.get("petrified", false)) or int(s.get("petrify_n", 0)) > 0:
		return true
	# Mid-spin: freeze seat breathe frames — spin paints rotation, not idles.
	if spinning:
		return true
	# Same seats _draw_slice_contents draws dimmed while a fight is facing someone else.
	if facing_index >= 0 and i != facing_index and i != hover_index:
		return true
	if FX_BUDGET.hold_low_priority_idles():
		return true
	return false


func _breathe_bob(_i: int) -> bool:
	return false


func _tex_used(tex: Texture2D) -> Rect2:
	if tex == null:
		return Rect2()
	var key: String = str(tex.resource_path)
	if key == "":
		key = str(tex.get_instance_id())
	if _used_cache.has(key):
		return _used_cache[key]
	var full := Rect2(0, 0, tex.get_width(), tex.get_height())
	var img: Image = tex.get_image()
	if img != null:
		var used: Rect2i = img.get_used_rect()
		if used.size.x >= 1 and used.size.y >= 1:
			full = Rect2(used)
	_used_cache[key] = full
	return full


func _sprite_slot(i: int) -> float:
	var span: float = _span(i) if i >= 0 else 1.0
	var chord: float = _radius() * maxf(span, 0.2) * 0.72
	return clampf(minf(chord, _radius() * 0.42), 64.0, 96.0)


func _seat_sprite_size(i: int) -> Vector2:
	var tex: Texture2D = null
	var pid := ""
	if i >= 0 and i < slices.size():
		pid = str(slices[i].get("card_id", ""))
		var frames: Array = tex_wheel_frames.get(pid, [])
		if frames.size() > 0:
			tex = frames[0]
	if tex == null:
		tex = _wheel_tex(i)
	if tex == null:
		return Vector2(WHEEL_SPRITE_MAX, WHEEL_SPRITE_MAX)
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var s: float = minf(WHEEL_FIT_H / th, WHEEL_FIT_W / tw)
	if s < 1.0 and not _scale_note.has(pid):
		_scale_note[pid] = true
		push_warning("wheel sprite %s is %sx%s and does not fit the wedge at a whole-pixel scale" % [pid, tw, th])
	s = floorf(s / WHEEL_SCALE_STEP) * WHEEL_SCALE_STEP
	s = clampf(s, 1.0, 4.0)
	return Vector2(tw * s, th * s)


func _call_of_slice(i: int) -> String:
	if i < 0 or i >= slices.size():
		return ""
	var s: Dictionary = slices[i]
	if bool(s.get("silenced", false)):
		return ""
	var name_s: String = str(s.get("name", "")).strip_edges()
	var call_s: String = str(s.get("call_name", "")).strip_edges()
	if call_s == "" or call_s.to_lower() == name_s.to_lower():
		return ""
	return call_s


func _tag_height_px(i: int) -> float:
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var fs: int = int(_tag_fs.get(i, 15))
	var h: float = 6.0 + font.get_height(fs) + 8.0
	if _call_of_slice(i) != "":
		h += 1.0 + font.get_height(11)
	return h


func _tag_width_px(i: int) -> float:
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var name_s: String = ""
	var call_s: String = _call_of_slice(i)
	if i >= 0 and i < slices.size():
		name_s = str(slices[i].get("name", "")).strip_edges()
	var fs: int = int(_tag_fs.get(i, 15))
	var name_px: float = 48.0
	if font != null and name_s != "":
		name_px = font.get_string_size(name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if call_s != "":
			name_px = maxf(name_px, font.get_string_size(call_s, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x)
	var native_w: float = maxf(36.0, ceil((name_px + 40.0) / 3.0))
	return native_w * 3.0


func _fit_sig_of(n: int) -> String:
	# Do NOT key on `rot`. Pass6 fit is base-space; `_spoke` spins it.
	# Mac spin_x5 @ c208e866: rot in the sig rebuilt `_search_feet` every
	# ~0.02 rad (~80–100 ms frames, process_ms ≈ 433 on wheel spikes).
	var bits: PackedStringArray = PackedStringArray()
	bits.append(str(n))
	bits.append(str(int(_radius())))
	for i in n:
		var sz: Vector2 = _seat_sprite_size(i)
		var name_s := ""
		if i < slices.size():
			name_s = str(slices[i].get("name", ""))
		bits.append("%s:%s:%s:%s" % [sz.x, sz.y, name_s, _call_of_slice(i)])
	return ",".join(bits)


func _fit_table(n: int) -> Array:
	if n <= 0:
		return []
	var sig: String = _fit_sig_of(n)
	if _fit_sig == sig and _fit_cache.has(n) and (_fit_cache[n] as Array).size() == n:
		return _fit_cache[n]
	var c: Vector2 = _center()
	var R: float = _radius()
	var hub_r: float = R * HUB_FRAC
	# Fit once in base space (rot=0). Live Spin / move-hint rotate via `_spoke`.
	# Re-fitting every rot tick was the Mac spin hitch (search_feet × N seats).
	var starts: PackedFloat32Array = _wedge_starts(0.0)
	var feet_out: Array = []
	_fit_clearance.clear()
	_tag_fs.clear()
	for i in n:
		_tag_fs[i] = 15
		var dir: Vector2 = Vector2.DOWN
		if i >= 0 and i < starts.size():
			dir = Vector2.from_angle(starts[i] + _span(i) * 0.5)
		var a0: float = starts[i] if i < starts.size() else (-PI * 0.5 + float(i) * TAU / float(n))
		var a1: float = a0 + _span(i)
		var sz: Vector2 = _seat_sprite_size(i)
		var best_f: Vector2 = c + dir * (R * 0.60)
		var best_cl: float = -1.0e9
		var best_r: float = R * 0.60
		var best_dy: float = 0.0
		var found := _search_feet(c, R, hub_r, dir, a0, a1, sz, i, best_f)
		best_f = found.feet
		best_cl = found.cl
		best_r = found.rr
		best_dy = found.dy
		if best_cl < 0.0:
			_tag_fs[i] = 13
			found = _search_feet(c, R, hub_r, dir, a0, a1, sz, i, best_f)
			best_f = found.feet
			best_cl = found.cl
			best_r = found.rr
			best_dy = found.dy
			if best_cl < 0.0:
				push_warning("pass6 fit: seat %s clearance %s still < 0 (r=%s dy=%s)" % [i, best_cl, best_r, best_dy])
		feet_out.append(best_f)
		_fit_clearance.append(best_cl)
	_fit_cache[n] = feet_out
	_fit_sig = sig
	if not spinning:
		print("[pass6-fit] n=%s clearances=%s" % [n, _fit_clearance])
	return feet_out


func _spin_pt(p: Vector2, c: Vector2, ang: float) -> Vector2:
	var d: Vector2 = p - c
	var cs: float = cos(ang)
	var sn: float = sin(ang)
	return c + Vector2(d.x * cs - d.y * sn, d.x * sn + d.y * cs)


func _spin_spoke(sp: Dictionary, ang: float) -> Dictionary:
	if absf(ang) < 0.00001:
		return sp
	var c: Vector2 = sp["c"]
	# Spin the seat's feet around the hub, then rebuild upright chrome from that
	# point. Spinning the tag/sprite AABBs by their centers (#138, 5d91ca4b) left
	# sprites standing on-screen-down while name tags and medallions orbited,
	# so the top seats had tags on the rim and medals beside the monster.
	var rest_feet: Vector2 = sp["feet"]
	var feet: Vector2 = _spin_pt(rest_feet, c, ang)
	var origin: Vector2 = _spin_pt(sp["origin"] as Vector2, c, ang)
	var dir: Vector2 = (sp["dir"] as Vector2).rotated(ang)
	var sprite: Rect2 = sp["sprite_rect"]
	var tag: Rect2 = sp["tag_rect"]
	var w: float = sprite.size.x
	var h: float = sprite.size.y
	var tag_w: float = tag.size.x
	var tag_h: float = tag.size.y
	var extra_y: float = tag.position.y - (rest_feet.y + 10.0)
	var dx: float = clampf(w * 0.5 - 4.0, 30.0, 40.0)
	var tag_rect := Rect2(Vector2(feet.x - tag_w * 0.5, feet.y + 10.0 + extra_y), Vector2(tag_w, tag_h))
	sp["origin"] = origin
	sp["dir"] = dir
	sp["tan"] = Vector2(-dir.y, dir.x)
	sp["feet"] = feet
	sp["port"] = feet - Vector2(0, h * 0.5)
	sp["name"] = Vector2(feet.x, feet.y + 60.0)
	sp["hp"] = feet + Vector2(-dx, -8.0)
	sp["atk"] = feet + Vector2(dx, -8.0)
	sp["tag_rect"] = tag_rect
	sp["medal"] = Vector2(tag_rect.position.x - 2.0, tag_rect.position.y + tag_h * 0.5)
	sp["sprite_rect"] = Rect2(Vector2(feet.x - w * 0.5, feet.y - h), Vector2(w, h))
	return sp


func _search_feet(c: Vector2, R: float, hub_r: float, dir: Vector2, a0: float, a1: float, sz: Vector2, i: int, fallback: Vector2) -> Dictionary:
	var best_f: Vector2 = fallback
	var best_cl: float = -1.0e9
	var best_r: float = R * 0.60
	var best_dy: float = 0.0
	var r: float = R * 0.40
	while r <= R * 0.86 + 0.01:
		var dy: float = -24.0
		while dy <= 24.01:
			var f: Vector2 = c + dir * r + Vector2(0, dy)
			var cl: float = _block_clearance(f, c, R, hub_r, a0, a1, sz, i)
			var cl_cmp: float = snappedf(cl, 4.0)
			var best_cmp: float = snappedf(best_cl, 4.0)
			var better: bool = cl_cmp > best_cmp
			if is_equal_approx(cl_cmp, best_cmp):
				var d0: float = absf(r - R * 0.60)
				var d1: float = absf(best_r - R * 0.60)
				better = d0 < d1 or (is_equal_approx(d0, d1) and absf(dy) < absf(best_dy))
			if better:
				best_cl = cl
				best_f = f
				best_r = r
				best_dy = dy
			dy += 4.0
		r += 3.0
	return {"feet": best_f, "cl": best_cl, "rr": best_r, "dy": best_dy}


func _block_clearance(f: Vector2, c: Vector2, R: float, hub_r: float, a0: float, a1: float, sz: Vector2, i: int) -> float:
	var w: float = sz.x
	var h: float = sz.y
	var tag_w: float = _tag_width_px(i)
	var tag_h: float = _tag_height_px(i)
	var rects: Array[Rect2] = [
		Rect2(Vector2(f.x - w * 0.5, f.y - h), Vector2(w, h)),
		Rect2(Vector2(f.x - (w * 0.5 + 28.0), f.y - 32.0), Vector2(w + 56.0, 40.0)),
		Rect2(Vector2(f.x - tag_w * 0.5, f.y + 10.0), Vector2(tag_w, tag_h)),
	]
	var worst: float = 1.0e9
	for rec in rects:
		for p in _rect_samples(rec):
			worst = minf(worst, _point_clearance(p, c, R, hub_r, a0, a1))
	return worst


func _rect_samples(r: Rect2) -> Array[Vector2]:
	var p: Vector2 = r.position
	var s: Vector2 = r.size
	return [
		p,
		p + Vector2(s.x, 0),
		p + Vector2(0, s.y),
		p + s,
		p + Vector2(s.x * 0.5, 0),
		p + Vector2(s.x * 0.5, s.y),
		p + Vector2(0, s.y * 0.5),
		p + Vector2(s.x, s.y * 0.5),
	]


func _point_clearance(p: Vector2, c: Vector2, R: float, hub_r: float, a0: float, a1: float) -> float:
	var d: Vector2 = p - c
	var n0: Vector2 = Vector2.from_angle(a0).rotated(PI * 0.5)
	var n1: Vector2 = Vector2.from_angle(a1).rotated(-PI * 0.5)
	var wedge: float = minf(d.dot(n0), d.dot(n1))
	var dist: float = d.length()
	return minf(wedge, minf(dist - (hub_r + 6.0), (R - 6.0) - dist))


func _sync_chrome_hover() -> void:
	if spinning or busy:
		_chrome_hover = -1
		return
	var local: Vector2 = get_local_mouse_position()
	_chrome_hover = -1
	if hover_index >= 0 and hover_index < slices.size() and str(slices[hover_index].get("kind", "")) == "monster":
		var sp: Dictionary = _spoke(hover_index)
		var tag: Rect2 = sp.get("tag_rect", Rect2())
		var medal := Rect2(sp["medal"] - Vector2(MEDAL_PX * 0.5, MEDAL_PX * 0.5), Vector2(MEDAL_PX, MEDAL_PX))
		if tag.has_point(local) or medal.has_point(local):
			_chrome_hover = hover_index


func _mark_chip_rect(sp: Dictionary, font: Font) -> Rect2:
	var tag: Rect2 = sp.get("tag_rect", Rect2())
	if tag.size.x < 4.0:
		return Rect2()
	var label := "Marked"
	var fs := 11
	var tsz: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var pad_x := 10.0
	var h := 20.0
	var w: float = maxf(56.0, tsz.x + pad_x * 2.0)
	var x: float = tag.position.x + (tag.size.x - w) * 0.5
	var y: float = tag.position.y + tag.size.y - 1.0
	return Rect2(Vector2(x, y), Vector2(w, h))


func _draw_mark_chip(font: Font, sp: Dictionary, dim: float, _i: int) -> void:
	var chip: Rect2 = _mark_chip_rect(sp, font)
	if chip.size.x < 4.0:
		return
	var pulse: float = 0.55 + 0.45 * absf(sin(_glow_t * 5.0))
	var fill := Color("100e0c")
	fill.a = 0.92 * dim
	var edge := MARK_GREEN_HOT
	edge.a = (0.82 + 0.18 * pulse) * dim
	_draw_capsule(chip, fill, edge)
	var tag: Rect2 = sp.get("tag_rect", Rect2())
	if tag.size.x > 4.0:
		var neck_x: float = chip.position.x + chip.size.x * 0.5
		var neck_y0: float = tag.position.y + tag.size.y - 1.0
		var neck_y1: float = chip.position.y + 2.0
		draw_line(Vector2(neck_x - 10.0, neck_y0), Vector2(neck_x + 10.0, neck_y0), edge, 3.0, true)
		draw_line(Vector2(neck_x, neck_y0), Vector2(neck_x, neck_y1), edge, 2.0, true)
	var fs := 11
	var label := "Marked"
	var tsz: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p := Vector2(chip.position.x + (chip.size.x - tsz.x) * 0.5, chip.position.y + 4.0 + font.get_ascent(fs))
	var ink := Color("100e0c")
	ink.a = dim
	var col := MARK_GREEN
	col.a = dim
	if _mark_hover:
		col = MARK_GREEN_HOT
		col.a = dim
	for ox in range(-2, 3):
		for oy in range(-2, 3):
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_string(font, p, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _sync_mark_hover() -> void:
	if spinning or busy:
		_set_mark_hover(false)
		return
	var local: Vector2 = get_local_mouse_position()
	var font: Font = ThemeDB.fallback_font
	var hit := false
	for i in slices.size():
		if str(slices[i].get("kind", "")) != "monster":
			continue
		if not bool(slices[i].get("hunter_mark", false)):
			continue
		var sp: Dictionary = _spoke(i)
		var sprite: Rect2 = sp.get("sprite_rect", Rect2()).grow(10.0)
		var chip: Rect2 = _mark_chip_rect(sp, font)
		if sprite.has_point(local) or chip.has_point(local):
			hit = true
			break
	_set_mark_hover(hit)


func _set_mark_hover(on: bool) -> void:
	if on == _mark_hover:
		return
	_mark_hover = on
	queue_redraw()
	if _mark_tip == null:
		return
	if on:
		_mark_tip.show_def_at_cursor(UxStyle.def_of("marked"), "marked")
	elif _mark_tip.has_method("hide_def"):
		_mark_tip.hide_def()


func _item_held() -> bool:
	if ability_suppressed:
		return true
	var root: Node = get_parent()
	if root == null:
		return false
	return _scan_held(root)


func _scan_held(n: Node) -> bool:
	if n.get("_holding") == true:
		return true
	for c in n.get_children():
		if _scan_held(c):
			return true
	return false


func _ensure_ability_cards() -> void:
	while _ability_cards.size() < 8:
		var card = ABILITY_CARD.new()
		add_child(card)
		_ability_cards.append(card)


func _sync_ability_cards() -> void:
	_ensure_ability_cards()
	for card in _ability_cards:
		card.visible = false
	# `_item_held` walks the scene tree — skip entirely mid-spin.
	if spinning or busy or _item_held() or not show_shift:
		return
	var hub_g: Vector2 = get_global_transform() * _center()
	var used := 0
	for i in slices.size():
		if used >= _ability_cards.size():
			break
		if str(slices[i].get("kind", "")) != "monster":
			continue
		var s: Dictionary = slices[i]
		var sp: Dictionary = _spoke(i)
		var card = _ability_cards[used]
		var body: String = str(s.get("reminder", "")).strip_edges()
		if body == "" or body == "---":
			body = str(s.get("explainer", "")).strip_edges()
		if body == "":
			body = str(s.get("ability", "")).strip_edges()
		var call_s: String = str(s.get("call_name", "")).strip_edges()
		if bool(s.get("fled_once", false)) and str(s.get("card_id", "")) == "commander" and call_s != "":
			call_s = "%s · used" % call_s
		card.set_content(call_s, body, _medal_tex(str(s.get("card_id", ""))), _ability_icon_color(str(s.get("special_id", ""))), bool(s.get("silenced", false)))
		var tag_g: Rect2 = _xform_rect(sp["tag_rect"])
		if card.place_from_tag(tag_g, sp["dir"], hub_g, _ability_avoids):
			used += 1


func _ability_rects_fit(idxs: Array[int]) -> bool:
	var rects: Array[Rect2] = []
	for i in idxs:
		var sp: Dictionary = _spoke(i)
		var guess := Rect2(_xform_rect(sp["tag_rect"]).position + Vector2(12, 0), Vector2(340, 72))
		for other in rects:
			if guess.intersects(other):
				return false
		rects.append(guess)
	return true


func _slay_push(i: int) -> Vector2:
	if i != slay_index or collapse <= 0.0:
		return Vector2.ZERO
	return _dir_of(i) * collapse * _radius() * 0.42


func _draw() -> void:
	# Count real draws — queue_redraw in _process inflated wheel spike tags.
	FRAME_METRICS.note_wheel()
	var c: Vector2 = _center()
	var radius: float = _radius()
	if slices.is_empty():
		draw_arc(c, radius, 0.0, TAU, 72, Color("3a322b"), 2.0, true)
		_draw_pointer(c, radius)
		_draw_hub_block(c, radius)
		return
	var n: int = slices.size()
	var starts: PackedFloat32Array = _starts()
	var top: Array[int] = []
	for i in n:
		if i == hover_index or i == facing_index:
			top.append(i)
		else:
			_draw_slice(c, radius, starts[i], starts[i] + _span(i), i)
	draw_circle(c, radius * HUB_FRAC, HUB)
	draw_arc(c, radius * HUB_FRAC, 0.0, TAU, 48, RING, 2.6, true)
	draw_arc(c, radius, 0.0, TAU, 80, RING, 3.0, true)
	for i in top:
		_draw_slice(c, radius, starts[i], starts[i] + _span(i), i)
	_draw_pointer(c, radius)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	for i in n:
		_draw_slice_contents(font, c, radius, starts[i], _span(i), i)
	# Mid-spin: skip bond/hint/threat chrome — rotation is the read.
	if not spinning:
		_draw_bonds(c, radius)
		_draw_move_hint(c, radius)
		_draw_across_aim()
	_draw_hub_block(c, radius)
	if not spinning:
		_draw_threat(c, radius)
		_draw_floaters(font)
	if slay_index >= 0 and slay_t > 0.0:
		_draw_slay(font, c, radius)


func _across_aimed(i: int) -> bool:
	if hover_index < 0 or hover_index >= slices.size() or hover_index == i:
		return false
	return int(slices[hover_index].get("across", -1)) == i


func _draw_across_aim() -> void:
	if highlight != "mark" or hover_index < 0 or hover_index >= slices.size():
		return
	var dest: int = int(slices[hover_index].get("across", -1))
	if dest < 0 or dest >= slices.size() or dest == hover_index:
		return
	var a: Vector2 = _spoke(hover_index)["port"]
	var b: Vector2 = _spoke(dest)["port"]
	var pulse: float = 0.45 + 0.35 * absf(sin(_glow_t * 9.0))
	draw_circle(b, 64.0, Color(0.78, 0.08, 0.08, 0.22 + 0.16 * pulse))
	draw_arc(b, 58.0, 0.0, TAU, 32, Color(0.95, 0.22, 0.16, 0.45 + 0.4 * pulse), 3.0, true)
	var delta: Vector2 = b - a
	var length: float = delta.length()
	if length < 24.0:
		return
	var nrm: Vector2 = delta / length
	var travel: float = fposmod(_glow_t * 84.0, 26.0)
	var start: float = 40.0
	var end: float = length - 52.0
	var t: float = start + travel
	while t < end:
		var p: Vector2 = a + nrm * t
		var seg: float = minf(12.0, end - t)
		draw_line(p, p + nrm * seg, Color(0.86, 0.12, 0.1, 0.9), 4.0, true)
		t += 26.0
	var tip: Vector2 = b - nrm * 50.0
	var side: Vector2 = Vector2(-nrm.y, nrm.x)
	draw_colored_polygon(PackedVector2Array([
		tip + nrm * 18.0,
		tip - nrm * 6.0 + side * 9.0,
		tip - nrm * 6.0 - side * 9.0,
	]), Color(0.92, 0.16, 0.12, 0.95))


func _draw_pointer(c: Vector2, radius: float) -> void:
	var bob: float = 3.0 + absf(sin(_glow_t * 8.0)) * 6.0
	var tip := Vector2(c.x, c.y + radius - 4.0)
	var left := Vector2(c.x - 22.0, c.y + radius + 28.0 + bob)
	var right := Vector2(c.x + 22.0, c.y + radius + 28.0 + bob)
	var pulse: float = 0.45 + 0.55 * absf(sin(_glow_t * 7.0))
	draw_arc(c, radius + 8.0, SIX - 0.18, SIX + 0.18, 12, Color(1.0, 0.85, 0.29, 0.35 + 0.4 * pulse), 7.0, true)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color("100e0c"))
	draw_colored_polygon(PackedVector2Array([
		tip + Vector2(0.0, 6.0),
		left + Vector2(5.0, -3.0),
		right + Vector2(-5.0, -3.0),
	]), FACE_RIM)
	draw_colored_polygon(PackedVector2Array([
		tip + Vector2(0.0, 10.0),
		left + Vector2(8.0, -6.0),
		right + Vector2(-8.0, -6.0),
	]), Color("f0e6d8"))


func _fill_for(s: Dictionary, is_face: bool, is_hover: bool) -> Color:
	if str(s.get("kind", "")) != "monster":
		if highlight == "place":
			return Color("1a2a1a")
		if highlight == "bribe":
			return Color("2a1c14")
		return EMPTY_FILL
	var fill: Color = STONE
	var pt: int = int(s.get("pack_tier", 0))
	if pt <= 0:
		pt = int(s.get("tier", 0))
	if pt == 3:
		fill = Color(0.58, 0.16, 0.08)
	elif pt == 2:
		fill = Color(0.14, 0.30, 0.48)
	elif pt == 1:
		fill = Color(0.52, 0.28, 0.10)
	elif str(s.get("rarity", "")) == "uncommon":
		fill = Color("24262a")
	if is_face:
		fill = fill.lightened(0.16)
	elif is_hover:
		fill = fill.lightened(0.10)
	elif facing_index >= 0 and (not spinning) and str(s.get("kind", "")) == "monster":
		fill = fill.darkened(0.18)
	if bool(s.get("crossbowed", false)):
		fill = fill.lerp(Color("5a4a18"), 0.45)
	if highlight == "mark" and bool(s.get("markable", false)):
		fill = fill.lightened(0.16)
	return fill


func _draw_wedge(origin: Vector2, r: float, a0: float, a1: float, fill: Color) -> void:
	var span: float = a1 - a0
	if r < 1.0 or fill.a <= 0.001 or absf(span) < 0.001:
		return
	if absf(span) >= TAU - 0.02:
		draw_circle(origin, r, fill)
		return
	var steps: int = clampi(int(ceili(absf(span) / 0.14)), 8, 48)
	var prev: Vector2 = origin + Vector2.from_angle(a0) * r
	for k in range(1, steps + 1):
		var nxt: Vector2 = origin + Vector2.from_angle(lerpf(a0, a1, float(k) / float(steps))) * r
		if absf((prev - origin).cross(nxt - origin)) < 0.5:
			prev = nxt
			continue
		draw_colored_polygon(PackedVector2Array([origin, prev, nxt]), fill)
		prev = nxt


func _draw_slice(c: Vector2, radius: float, a0: float, a1: float, i: int) -> void:
	if i < 0 or i >= slices.size():
		return
	var s: Dictionary = slices[i]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = i == hover_index
	var is_sel: bool = (not spinning) and i == selected_index and facing_index < 0
	var is_threat: bool = (not spinning) and facing_index < 0 and threat_indices.has(i)
	var lift: float = _lift_of(i)
	var dir: Vector2 = Vector2.from_angle((a0 + a1) * 0.5)
	var origin: Vector2 = c + dir * (lift * 8.0) + _slay_push(i)
	var r: float = radius + lift * 12.0
	var fill: Color = _fill_for(s, is_face or is_sel, is_hover)
	if _flash.has(i):
		fill = fill.lerp(DOWN_COL, clampf(float(_flash[i]) * 1.4, 0.0, 0.55))
	if i == slay_index and collapse > 0.0:
		fill.a *= 1.0 - collapse * 0.85
	_draw_wedge(origin, r, a0, a1, fill)
	if str(s.get("kind", "")) == "monster":
		var wash: Color = fill.lightened(0.22)
		wash.a = 0.42
		_draw_wedge(origin, r * 0.86, a0 + 0.03, a1 - 0.03, wash)
		var glow: Color = fill.lightened(0.38)
		glow.a = 0.22
		_draw_wedge(origin, r * 0.70, a0 + 0.05, a1 - 0.05, glow)
	var rim: Color = Color("2a241e")
	var rw: float = 1.4
	if is_face:
		rim = FACE_RIM
		rw = 5.2
	elif is_sel or is_threat:
		rim = FACE_RIM
		rw = 6.4 if is_sel else 7.2
	elif highlight == "place" and str(s.get("kind", "")) == "empty":
		rim = PLACE_RIM
		rw = 2.5
	elif highlight == "bribe" and is_hover:
		rim = BRIBE_RIM
		rw = 3.0
	elif highlight == "mark" and bool(s.get("markable", false)):
		var mark_pulse: float = 0.55 + 0.45 * absf(sin(_glow_t * 7.0))
		if is_hover and int(s.get("across", -1)) >= 0:
			rim = Color("ffd84a")
			rw = 4.2 + mark_pulse * 1.6
		elif is_hover:
			rim = Color("ffd84a")
			rw = 4.6 + mark_pulse * 1.8
		else:
			rim = Color("e8c36a").lerp(Color("8dcb8d"), 0.35)
			rw = 4.0 + mark_pulse * 2.2
		draw_arc(origin, r + 8.0 + mark_pulse * 4.0, a0, a1, 26, Color(1.0, 0.90, 0.40, 0.28 + 0.42 * mark_pulse), 3.5 + mark_pulse * 2.0, true)
	elif str(s.get("kind", "")) == "monster":
		var t: int = _plate_tier(s)
		rim = Color("c08050")
		rw = 2.6
		if t == 2:
			rim = Color("c5cdd8")
			rw = 3.2
		elif t >= 3:
			rim = Color("e8c36a")
			rw = 3.8
		if is_hover:
			rim = rim.lightened(0.18)
			rw += 0.8
	elif is_hover:
		rim = Color("f0e6d8")
		rw = 2.4
	if int(log_focus.get("wheel", -1)) == i:
		rim = Color("fff0c0")
		rw += 2.4
		var pulse: float = 0.55 + 0.45 * sin(_glow_t * 8.0)
		draw_arc(origin, r + 6.0, a0, a1, 26, Color(1.0, 0.94, 0.75, 0.35 + 0.4 * pulse), 4.0, true)
	elif _across_aimed(i):
		rim = Color("c42828")
		rw = 4.6
	draw_arc(origin, r, a0, a1, 26, rim, rw, true)


func _draw_slice_contents(font: Font, c: Vector2, radius: float, a0: float, ang: float, i: int) -> void:
	if i < 0 or i >= slices.size():
		return
	var s: Dictionary = slices[i]
	var sp: Dictionary = _spoke(i)
	var dir: Vector2 = sp["dir"]
	var origin: Vector2 = sp["origin"]
	var r: float = sp["r"]
	var is_face: bool = (not spinning) and i == facing_index
	var is_hover: bool = i == hover_index
	var dim: float = 1.0
	if facing_index >= 0 and not spinning and not is_face and not is_hover:
		dim = 0.84
	if str(s.get("kind", "")) != "monster":
		if closed_empties:
			_draw_closed_empty(origin, dir, r)
		elif tex_plus != null:
			var p: Vector2 = origin + dir * r * 0.58
			var a: float = 0.88 if highlight == "place" else 0.42
			draw_texture_rect(tex_plus, Rect2(p - Vector2(16, 16), Vector2(32, 32)), false, Color(1, 1, 1, a))
		return
	var pv: Dictionary = preview.get(i, preview.get(str(i), {}))
	if typeof(pv) != TYPE_DICTIONARY:
		pv = {}
	var pid: String = str(s.get("card_id", ""))
	var port_pos: Vector2 = sp["port"]
	var sprite_rect: Rect2 = sp.get("sprite_rect", Rect2(port_pos - Vector2(48, 48), Vector2(96, 96)))
	var plate_r: float = 48.0
	if i == aura_index or threat_indices.has(i):
		var glow := Color("e8c36a")
		glow.a = 0.50 + 0.28 * absf(sin(_glow_t * 9.0))
		draw_circle(port_pos, plate_r + 16.0, glow)
		draw_arc(port_pos, plate_r + 20.0, 0.0, TAU, 28, Color(1.0, 0.90, 0.35, 0.45 + 0.35 * absf(sin(_glow_t * 9.0))), 3.5, true)
	if _mark_hover and str(s.get("card_id", "")) == "kobold_trapper":
		var trap_pulse: float = 0.55 + 0.45 * absf(sin(_glow_t * 8.0))
		var trap_fill := MARK_GREEN_HOT
		trap_fill.a = 0.38 + 0.28 * trap_pulse
		draw_circle(port_pos, plate_r + 18.0, trap_fill)
		draw_arc(port_pos, plate_r + 22.0, 0.0, TAU, 32, Color(MARK_GREEN_HOT.r, MARK_GREEN_HOT.g, MARK_GREEN_HOT.b, 0.75 + 0.25 * trap_pulse), 4.2, true)
	if i != portrait_away and not hide_portraits.has(i):
		_draw_wheel_sprite(i, sp, s, dim)
	if bool(s.get("hunter_mark", false)):
		_draw_hunter_mark(sprite_rect.grow(8.0), dim)
	var burn: float = float(_burn.get(i, 0.0))
	if burn > 0.02:
		var fire: Texture2D = _fire_tex()
		var bob := Vector2(0, -6.0 * sin(_glow_t * 18.0))
		var fr := Rect2(port_pos + bob - Vector2(28, 36), Vector2(56, 56))
		if fire != null:
			draw_texture_rect(fire, fr, false, Color(1, 1, 1, clampf(burn, 0.35, 1.0)))
		draw_circle(port_pos + bob, 18.0 + 8.0 * burn, Color(1.0, 0.42, 0.08, 0.35 * burn))
	if bool(s.get("rage_fire", false)):
		var flicker: float = 0.45 + 0.35 * absf(sin(_glow_t * 11.0))
		draw_circle(port_pos, plate_r + 10.0, Color(1.0, 0.35, 0.08, flicker * 0.55))
		draw_circle(port_pos + Vector2(0, -plate_r * 0.35), plate_r * 0.55, Color(1.0, 0.78, 0.18, flicker * 0.4))
	if bool(s.get("fled_once", false)):
		var dust := Color(0.62, 0.58, 0.52, 0.55 * dim)
		draw_circle(port_pos + Vector2(plate_r * 0.55, -plate_r * 0.55), 7.0, dust)
		draw_arc(port_pos, plate_r + 4.0, 0.2, 1.4, 8, Color(0.78, 0.74, 0.68, 0.7 * dim), 2.0, true)
	var sid: String = str(s.get("special_id", ""))
	if sid != "" and tex_special.has(sid) and _wheel_tex(i) == null:
		var st: Texture2D = tex_special[sid]
		draw_texture_rect(st, Rect2(port_pos - Vector2(9, 9), Vector2(18, 18)), false, Color(dim, dim, dim, dim))
	var big: bool = true
	_draw_name_tag(font, sp, s, is_face, dim, is_hover or i == _chrome_hover, i)
	if bool(s.get("hunter_mark", false)):
		_draw_mark_chip(font, sp, dim, i)
	_draw_heart_stat(font, sp["hp"], s, pv, big, i, is_hover)
	_draw_atk_stat(font, sp["atk"], s, pv, big, i, is_hover)
	var would_die: bool = int(s.get("hp", 0)) + int(pv.get("hp", 0)) <= 0 and int(pv.get("hp", 0)) < 0
	if would_die or bool(pv.get("kill", false)):
		var xa: float = 0.55 + 0.25 * sin(_glow_t * 12.0)
		var xc := Color(DOWN_COL.r, DOWN_COL.g, DOWN_COL.b, xa)
		var arm: float = 22.0
		draw_line(port_pos + Vector2(-arm, -arm), port_pos + Vector2(arm, arm), xc, 4.0, true)
		draw_line(port_pos + Vector2(arm, -arm), port_pos + Vector2(-arm, arm), xc, 4.0, true)


func _plate_tier(s: Dictionary) -> int:
	var t: int = int(s.get("pack_tier", 0))
	if t < 1:
		t = int(s.get("tier", 1))
	return t


func _plate_pts(center: Vector2, rad: float, tier: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	if tier >= 3:
		for k in 10:
			var a: float = -PI * 0.5 + float(k) * TAU / 10.0
			var rr: float = rad * (1.12 if k % 2 == 0 else 0.72)
			pts.append(center + Vector2.from_angle(a) * rr)
	elif tier == 2:
		for k2 in 6:
			var a2: float = -PI * 0.5 + float(k2) * TAU / 6.0
			pts.append(center + Vector2.from_angle(a2) * rad)
	else:
		for k3 in 24:
			var a3: float = -PI * 0.5 + float(k3) * TAU / 24.0
			pts.append(center + Vector2.from_angle(a3) * rad)
	return pts


func _draw_tier_plate(center: Vector2, rad: float, s: Dictionary) -> void:
	var t: int = _plate_tier(s)
	var fill: Color = UxStyle.metal_well(t)
	var rim: Color = UxStyle.metal(t)
	var w: float = 2.2
	if t == 2:
		w = 2.6
	elif t >= 3:
		w = 3.0
	if draft_glow:
		var pulse: float = 0.50 + 0.50 * absf(sin(_glow_t * 3.0 + float(t) * 0.7))
		rim = rim.lerp(rim.lightened(0.55), pulse * 0.75)
		w += pulse * (2.4 if t >= 3 else 1.6)
	UxStyle.draw_squircle(self, center, rad, t, fill, rim, w)


func _fill_poly(pts: PackedVector2Array, col: Color) -> void:
	var count: int = pts.size()
	if count < 3:
		return
	var mid: Vector2 = Vector2.ZERO
	for p in pts:
		mid += p
	mid /= float(count)
	for i in count:
		draw_colored_polygon(PackedVector2Array([mid, pts[i], pts[(i + 1) % count]]), col)


func _draw_tier_num(_font: Font, _pos: Vector2, _s: Dictionary, _is_face: bool, _crowded: bool) -> void:
	pass


func _draw_tier_rim(_center: Vector2, _rad: float, _s: Dictionary) -> void:
	pass


func _draw_hunter_mark(rect: Rect2, dim: float) -> void:
	var pulse: float = 0.55 + 0.45 * absf(sin(_glow_t * 5.0))
	var inset: float = 2.0 + 1.5 * sin(_glow_t * 3.2)
	var arm: float = 18.0
	var x: float = rect.position.x + inset
	var y: float = rect.position.y + inset
	var w: float = maxf(12.0, rect.size.x - inset * 2.0)
	var h: float = maxf(12.0, rect.size.y - inset * 2.0)
	var wash := MARK_GREEN
	wash.a = (0.22 + 0.16 * pulse) * dim
	draw_rect(Rect2(x, y, w, h), wash, false, 3.0)
	var ink := Color("100e0c")
	ink.a = 0.92 * dim
	var green := MARK_GREEN_HOT
	green.a = (0.82 + 0.18 * pulse) * dim
	var corners: Array = [
		[Vector2(x, y), Vector2(1, 0), Vector2(0, 1)],
		[Vector2(x + w, y), Vector2(-1, 0), Vector2(0, 1)],
		[Vector2(x + w, y + h), Vector2(-1, 0), Vector2(0, -1)],
		[Vector2(x, y + h), Vector2(1, 0), Vector2(0, -1)],
	]
	for c in corners:
		var row: Array = c
		var origin: Vector2 = row[0] as Vector2
		var a: Vector2 = row[1] as Vector2
		var b: Vector2 = row[2] as Vector2
		draw_line(origin, origin + a * arm, ink, 5.2, true)
		draw_line(origin, origin + b * arm, ink, 5.2, true)
		draw_line(origin, origin + a * arm, green, 3.2, true)
		draw_line(origin, origin + b * arm, green, 3.2, true)


func _draw_portrait_window(center: Vector2, rad: float, s: Dictionary, tex: Texture2D, face_ang: float, dim: float = 1.0) -> void:
	if tex == null:
		return
	var side: float = rad * 1.55
	var box := Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side))
	var dest := _native_feet_rect(tex, box)
	var mod := Color(dim, dim, dim, 1.0)
	var glow: Color = Color("c08050")
	var t: int = _plate_tier(s)
	if t == 2:
		glow = Color("c5cdd8")
	elif t >= 3:
		glow = Color("e8c36a")
	glow.a = dim
	if absf(face_ang) > 0.01:
		draw_set_transform(center, face_ang, Vector2.ONE)
		var local := Rect2(dest.position - center, dest.size)
		_draw_tex_outline(tex, local, glow)
		draw_texture_rect(tex, local, false, mod)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		_draw_tex_outline(tex, dest, glow)
		draw_texture_rect(tex, dest, false, mod)


func _native_feet_rect(tex: Texture2D, box: Rect2) -> Rect2:
	var tw: float = maxf(1.0, float(tex.get_width()))
	var th: float = maxf(1.0, float(tex.get_height()))
	var k: float = minf(box.size.x / tw, box.size.y / th)
	var sz := Vector2(tw * k, th * k)
	return Rect2(Vector2(box.position.x + (box.size.x - sz.x) * 0.5, box.end.y - sz.y), sz)


func _draw_tex_outline(tex: Texture2D, dest: Rect2, col: Color) -> void:
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_texture_rect(tex, Rect2(dest.position + Vector2(ox, oy) * 1.5, dest.size), false, col)


func _draw_outlined_string(font: Font, pos: Vector2, text: String, fs: int, col: Color, outline: Color) -> void:
	var tsz: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = pos + Vector2(-tsz.x * 0.5, 0.0)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _edge_angle_between(i: int, j: int) -> float:
	var n: int = slices.size()
	var starts: PackedFloat32Array = _starts()
	if n == 0 or i < 0 or j < 0:
		return 0.0
	if j == (i + 1) % n:
		return starts[j]
	return starts[i]


func _draw_edge_ticks(i: int, j: int, col: Color) -> void:
	var c: Vector2 = _center()
	var radius: float = _radius()
	var ang: float = _edge_angle_between(i, j)
	var a: Vector2 = Vector2.from_angle(ang)
	draw_line(c + a * radius * HUB_FRAC, c + a * radius * 0.76, col, 3.2, true)


func set_facing_for_bonds(index: int) -> void:
	_facing_for_bonds = index
	queue_redraw()


func poison_badge_gain(index: int) -> void:
	_poison_badge_scale[index] = 1.2
	queue_redraw()
	var tw := create_tween()
	tw.tween_method(
		func(v: float) -> void:
			_poison_badge_scale[index] = v
			queue_redraw(),
		1.2,
		1.0,
		0.10
	)


func poison_badge_clear(index: int) -> void:
	_poison_clear_t[index] = 1.0
	queue_redraw()
	var tw := create_tween()
	tw.tween_method(
		func(v: float) -> void:
			_poison_clear_t[index] = v
			queue_redraw(),
		1.0,
		0.0,
		0.12
	)


func hub_poison_badge_global() -> Vector2:
	return hub_hearts_global() + Vector2(54, 0)


func _start_bond_diff(before: Dictionary, after: Dictionary) -> void:
	if before.is_empty() and after.is_empty():
		return
	var lost: Array = []
	var gained: Array = []
	for k in before.keys():
		if not after.has(k):
			lost.append(before[k])
	for k2 in after.keys():
		if not before.has(k2):
			gained.append(after[k2])
	if lost.is_empty() and gained.is_empty():
		return
	for pair in lost:
		var key: String = str(pair.get("key", ""))
		_bond_anim[key] = {"t": 0.0, "kind": "snap", "pair": pair}
	var stagger: int = 0
	for pair2 in gained:
		var key2: String = str(pair2.get("key", ""))
		_bond_anim[key2] = {"t": -0.08 * float(stagger), "kind": "tie", "pair": pair2}
		stagger += 1
		var j: int = int(pair2.get("j", -1))
		if j >= 0:
			if str(pair2.get("punch", "")) == "hp":
				punch_hp(j)
			else:
				punch_atk(j)
	queue_redraw()


func _bond_pair_map() -> Dictionary:
	var out := {}
	for pair in _collect_bond_pairs():
		out[str(pair.get("key", ""))] = pair
	return out


func _collect_bond_pairs() -> Array:
	var n: int = slices.size()
	var out: Array = []
	if n == 0:
		return out
	for i in n:
		var s: Dictionary = slices[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		var cid: String = str(s.get("card_id", ""))
		var silenced: bool = bool(s.get("silenced", false))
		match cid:
			"commander":
				# Still draw when silenced (grey); only skip if the aura was stripped for another reason.
				for off in [n - 1, 1]:
					var j: int = (i + off) % n
					if not _living_neighbor(j):
						continue
					out.append(_bond_pair(i, j, "commander", Color("d63a2a"), "sword", false, false, silenced, "atk"))
			"lich":
				for off2 in [n - 1, 1]:
					var j2: int = (i + off2) % n
					if not _living_neighbor(j2):
						continue
					out.append(_bond_pair(i, j2, "lich", Color("8dcb8d"), "wisp", false, false, silenced, "hp"))
			"plague_doctor":
				for off3 in [n - 1, 1]:
					var j3: int = (i + off3) % n
					if not _living_neighbor(j3):
						continue
					out.append(_bond_pair(i, j3, "plague", Color("9a5bd1"), "drop", false, false, silenced, "hp", true))
			"wraith":
				var src: int = int(s.get("copy_from", -1))
				if src < 0:
					src = _higher_atk_neighbor(i)
				if src >= 0 and src < n and _living_neighbor(src):
					out.append(_bond_pair(src, i, "wraith", Color("c9b9a8"), "", true, false, silenced, "atk"))
			"slime_boss":
				out.append({"key": "slime:%s" % i, "i": i, "j": i, "kind": "slime", "col": Color(0.45, 0.82, 0.42, 0.85), "glyph": "", "dashed": false, "dotted": false, "silenced": false, "punch": "", "lock": false, "special": "slime"})
			"bodyguard":
				for off4 in [n - 1, 1]:
					var j4: int = (i + off4) % n
					if not _living_neighbor(j4):
						continue
					# Arrow from neighbour → Bodyguard.
					out.append(_bond_pair(j4, i, "bodyguard", Color("a0a8b8"), "shield", false, false, silenced, "hp"))
			"prism":
				for off5 in [n - 1, 1]:
					var j5: int = (i + off5) % n
					if not _living_neighbor(j5):
						continue
					out.append(_bond_pair(i, j5, "prism", Color("e8c36a"), "", false, false, silenced, "atk", false, true))
			"cowardly_king":
				var jr: int = (i + 1) % n
				if _living_neighbor(jr):
					out.append(_bond_pair(i, jr, "king", Color("a0a8b8"), "", false, false, silenced, "atk"))
			"wick":
				for off6 in [n - 1, 1]:
					var j6: int = (i + off6) % n
					if not _living_neighbor(j6):
						continue
					out.append(_bond_pair(i, j6, "wick", Color("f0d48a"), "", false, true, silenced, "hp"))
			"leech_league":
				if i != _facing_for_bonds:
					continue
				var low: int = _lowest_hp_other(i)
				if low >= 0:
					out.append(_bond_pair(i, low, "leech", Color("6a1c14"), "", false, false, silenced, "hp"))
	return out


func _bond_pair(i: int, j: int, kind: String, col: Color, glyph: String, dashed: bool, dotted: bool, silenced: bool, punch: String, lock_end: bool = false, rainbow: bool = false) -> Dictionary:
	return {
		"key": "%s:%s>%s" % [kind, i, j],
		"i": i,
		"j": j,
		"kind": kind,
		"col": col,
		"glyph": glyph,
		"dashed": dashed,
		"dotted": dotted,
		"silenced": silenced,
		"punch": punch,
		"lock": lock_end,
		"rainbow": rainbow,
		"special": "",
	}


func _higher_atk_neighbor(i: int) -> int:
	var n: int = slices.size()
	var best: int = -1
	var best_atk: int = -1
	for off in [n - 1, 1]:
		var j: int = (i + off) % n
		if not _living_neighbor(j):
			continue
		var a: int = int(slices[j].get("atk", 0))
		if a > best_atk:
			best_atk = a
			best = j
	return best


func _lowest_hp_other(i: int) -> int:
	var best: int = -1
	var best_hp: int = 999999
	for j in slices.size():
		if j == i or not _living_neighbor(j):
			continue
		var h: int = int(slices[j].get("hp", 0))
		if h < best_hp:
			best_hp = h
			best = j
	return best


func rim_global() -> Vector2:
	return get_global_transform() * _center()


func rim_radius() -> float:
	return _radius()


func _step_living(from: int, dir: int) -> int:
	var n: int = slices.size()
	if n <= 0 or from < 0 or dir == 0:
		return -1
	var i: int = from
	for _step in n:
		i = (i + dir) % n
		if i < 0:
			i += n
		if i == from:
			return -1
		if str(slices[i].get("kind", "")) != "monster":
			continue
		if int(slices[i].get("hp", 0)) <= 0:
			continue
		return i
	return -1


func _draw_move_hint(c: Vector2, radius: float) -> void:
	if move_hint_dir == 0 or move_hint_amt < 0.04 or facing_index < 0:
		return
	var dest: int = _step_living(facing_index, move_hint_dir)
	if dest < 0:
		return
	var starts: PackedFloat32Array = _starts()
	if dest >= starts.size():
		return
	var a0: float = starts[dest]
	var a1: float = a0 + _span(dest)
	var col := Color("FFD84A", 0.25 + 0.55 * move_hint_amt)
	draw_arc(c, radius + 10.0, a0, a1, 20, col, 7.0, true)


func _draw_bonds(_c: Vector2, _radius: float) -> void:
	var n: int = slices.size()
	if n == 0:
		return
	var pulse: float = 0.50 + 0.50 * sin(_glow_t * 6.0)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	_ensure_aura_glyphs()
	for pair in _collect_bond_pairs():
		if str(pair.get("special", "")) == "slime":
			var i_s: int = int(pair.get("i", -1))
			if i_s < 0:
				continue
			var sp_s: Dictionary = _spoke(i_s)
			var midp: Vector2 = (sp_s["atk"] + sp_s["hp"]) * 0.5
			_draw_outlined_string(font, midp + Vector2(0, 5), "=", 15, Color(0.45, 0.82, 0.42, 0.85), Color("1c120c"))
			continue
		var i: int = int(pair.get("i", -1))
		var j: int = int(pair.get("j", -1))
		if i < 0 or j < 0 or i >= n or j >= n:
			continue
		var key: String = str(pair.get("key", ""))
		var anim: Dictionary = _bond_anim.get(key, {})
		var kind: String = str(anim.get("kind", ""))
		var at: float = float(anim.get("t", 0.0))
		if kind == "snap":
			_draw_bond_snap(pair, at)
			if at >= 0.18:
				_bond_anim.erase(key)
			continue
		var u_draw: float = 1.0
		if kind == "tie":
			if at < 0.0:
				continue
			u_draw = clampf(at / 0.24, 0.0, 1.0)
			if at >= 0.24:
				_bond_anim.erase(key)
		var hot: bool = i == hover_index or j == hover_index
		var col: Color = pair.get("col", Color.WHITE)
		if bool(pair.get("rainbow", false)):
			var hue: float = fposmod(_glow_t * 0.35, 1.0)
			col = Color.from_hsv(hue, 0.65, 0.95)
		if bool(pair.get("silenced", false)):
			col = Color(0.55, 0.55, 0.55, 0.25)
		else:
			var a: float = (0.82 + 0.18 * pulse) if hot else (0.30 + 0.10 * pulse)
			col.a = a
		if i == hover_index:
			var ring: float = 18.0 + 10.0 * absf(sin(_glow_t * 5.0))
			draw_arc(_spoke(i)["port"], ring, 0.0, TAU, 24, Color(col.r, col.g, col.b, 0.55), 2.4, true)
		var a_sp: Dictionary = _spoke(i)
		var b_sp: Dictionary = _spoke(j)
		var a_pt: Vector2 = a_sp.get("feet", a_sp["port"])
		var b_pt: Vector2 = b_sp.get("feet", b_sp["port"])
		var hub: Vector2 = _center()
		var mid: Vector2 = (a_pt + b_pt) * 0.5
		var bow: Vector2 = mid.lerp(hub, 0.35)
		bow = mid + (bow - mid).normalized() * 18.0
		if u_draw < 0.999:
			b_pt = _quad_bezier(a_pt, bow, b_pt, u_draw)
			bow = a_pt.lerp(bow, u_draw)
		_draw_thread(a_pt, bow, b_pt, col, hot, bool(pair.get("dashed", false)), bool(pair.get("dotted", false)))
		var glyph: String = str(pair.get("glyph", ""))
		# Glyphs sit on the thread near the bow (never over either portrait).
		if glyph != "" and u_draw > 0.85:
			var gp: Vector2 = _quad_bezier(a_pt, bow, b_pt, 0.48)
			_draw_aura_glyph(gp, glyph, col)
		if bool(pair.get("lock", false)) and u_draw > 0.85:
			var lock_p: Vector2 = _quad_bezier(a_pt, bow, b_pt, 0.58) + Vector2(6, -8)
			_draw_aura_glyph(lock_p, "lock", col)
		if bool(pair.get("silenced", false)):
			var lab: String = COPY.text("status.silenced", "Silenced")
			_draw_outlined_string(font, bow + Vector2(0, -10), lab, 11, Color(0.78, 0.78, 0.78, 0.70), Color("100e0c"))


func _draw_bond_snap(pair: Dictionary, t: float) -> void:
	var i: int = int(pair.get("i", -1))
	var j: int = int(pair.get("j", -1))
	var n_now: int = slices.size()
	if i < 0 or j < 0 or i >= n_now or j >= n_now:
		return
	var a_sp: Dictionary = _spoke(i)
	var b_sp: Dictionary = _spoke(j)
	var a_pt: Vector2 = a_sp.get("feet", a_sp["port"])
	var b_pt: Vector2 = b_sp.get("feet", b_sp["port"])
	var mid: Vector2 = (a_pt + b_pt) * 0.5
	var hub: Vector2 = _center()
	var bow: Vector2 = mid + (mid.lerp(hub, 0.35) - mid).normalized() * 18.0
	var u: float = clampf(t / 0.18, 0.0, 1.0)
	var col: Color = pair.get("col", Color.WHITE)
	col.a = 0.55 * (1.0 - u)
	var left_end: Vector2 = mid.lerp(a_pt, u)
	var right_end: Vector2 = mid.lerp(b_pt, u)
	draw_line(a_pt, left_end, Color("100e0c", col.a), 5.0 if false else 4.0, true)
	draw_line(a_pt, left_end, col, 3.0, true)
	draw_line(b_pt, right_end, Color("100e0c", col.a), 4.0, true)
	draw_line(b_pt, right_end, col, 3.0, true)
	if ResourceLoader.exists("res://assets/dungeon/vfx/spark.png") and u < 0.5:
		var spark: Texture2D = load("res://assets/dungeon/vfx/spark.png") as Texture2D
		if spark != null:
			for k in 3:
				var ang: float = float(k) * TAU / 3.0 + t * 8.0
				var off := Vector2.from_angle(ang) * (4.0 + u * 10.0)
				draw_texture_rect(spark, Rect2(bow + off - Vector2(4, 4), Vector2(8, 8)), false, Color(1, 1, 1, 1.0 - u))


func _draw_thread(a: Vector2, bow: Vector2, b: Vector2, col: Color, hot: bool, dashed: bool, dotted: bool) -> void:
	var w: float = 4.0 if hot else 3.0
	var ink := Color("100e0c", col.a * 0.85)
	var pts: PackedVector2Array = PackedVector2Array()
	var steps: int = 12
	for s in steps + 1:
		var u: float = float(s) / float(steps)
		pts.append(_quad_bezier(a, bow, b, u))
	if dashed or dotted:
		var gap: int = 2 if dotted else 3
		var on: int = 1 if dotted else 2
		var i: int = 0
		while i < pts.size() - 1:
			if (i % (on + gap)) < on:
				draw_line(pts[i], pts[i + 1], ink, w + 1.0, true)
				draw_line(pts[i], pts[i + 1], col, w, true)
			i += 1
	else:
		for i2 in pts.size() - 1:
			draw_line(pts[i2], pts[i2 + 1], ink, w + 1.0, true)
			draw_line(pts[i2], pts[i2 + 1], col, w, true)


func _quad_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return u * u * a + 2.0 * u * t * b + t * t * c


func _ensure_aura_glyphs() -> void:
	if not _aura_glyphs.is_empty():
		return
	for name in ["sword", "wisp", "drop", "lock", "shield"]:
		var p := "res://assets/ui/anim/aura_glyph_%s.png" % name
		if name == "sword":
			p = "res://assets/ui/icons/atk_burst_18.png"
		if ResourceLoader.exists(p):
			_aura_glyphs[name] = load(p) as Texture2D


func _draw_aura_glyph(pos: Vector2, name: String, col: Color) -> void:
	var tex: Texture2D = _aura_glyphs.get(name, null)
	# 8×8 native at 3× = 24px. PixelLab glyphs keep their own colours (unmodulated).
	var sz := Vector2(24, 24)
	if tex != null:
		var a: float = clampf(col.a + 0.35, 0.0, 1.0)
		draw_texture_rect(tex, Rect2(pos - sz * 0.5, sz), false, Color(1, 1, 1, a))
	else:
		draw_circle(pos, 4.0, col)


func _living_neighbor(j: int) -> bool:
	if j < 0 or j >= slices.size():
		return false
	if str(slices[j].get("kind", "")) != "monster":
		return false
	return int(slices[j].get("hp", 0)) > 0


func _draw_bold_name(font: Font, pos: Vector2, text: String, fs: int, col: Color, wrap: float = 108.0) -> void:
	_draw_outlined_string(font, pos, text, fs, col, Color("100e0c"))


func _draw_wheel_sprite(_i: int, sp: Dictionary, s: Dictionary, dim: float) -> void:
	var tex: Texture2D = _wheel_tex(_i)
	var sprite_rect: Rect2 = sp.get("sprite_rect", Rect2())
	var feet: Vector2 = sp.get("feet", sp["port"] + Vector2(0, 48))
	var w: float = sprite_rect.size.x if sprite_rect.size.x > 1.0 else WHEEL_SPRITE_MAX
	var h: float = sprite_rect.size.y if sprite_rect.size.y > 1.0 else WHEEL_SPRITE_MAX
	var dest := sprite_rect
	if dest.size.x < 1.0 or dest.size.y < 1.0:
		dest = Rect2(Vector2(feet.x - w * 0.5, feet.y - h), Vector2(w, h))
	var shadow_at := Vector2(dest.position.x + dest.size.x * 0.5, dest.end.y)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_colored_polygon(_shadow_pts(shadow_at, dest.size.x * 0.9, 10.0), SHADOW_COL)
	if tex == null:
		return
	var card_id := str(s.get("card_id", ""))
	var flip: bool = _art != null and _art.has_method("monster_flip_h") and _art.monster_flip_h(card_id, "L")
	var src := Rect2(0, 0, tex.get_width(), tex.get_height())
	if flip:
		draw_set_transform(Vector2(2.0 * shadow_at.x, 0.0), 0.0, Vector2(-1.0, 1.0))
	var outline := Color(OUTLINE_PX.r, OUTLINE_PX.g, OUTLINE_PX.b, dim)
	var ring: float = WHEEL_SPRITE_SCALE
	for k in 8:
		var a: float = float(k) * TAU / 8.0
		draw_texture_rect_region(tex, Rect2(dest.position + Vector2.from_angle(a) * ring, dest.size), src, outline)
	var mod := Color(dim, dim, dim, 1.0)
	draw_texture_rect_region(tex, dest, src, mod)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _shadow_pts(feet: Vector2, width: float, height: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 16:
		var a: float = float(k) * TAU / 16.0
		pts.append(feet + Vector2(cos(a) * width * 0.5, sin(a) * height * 0.5))
	return pts


func _draw_nine_slice(tex: Texture2D, dest: Rect2, src_m: float, dst_m: float) -> void:
	if tex == null:
		draw_rect(dest, Color("1c1814"), true)
		draw_rect(dest, Color("c4a574"), false, 2.0)
		return
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var sx: Array[float] = [0.0, src_m, tw - src_m, tw]
	var sy: Array[float] = [0.0, src_m, th - src_m, th]
	var dx: Array[float] = [dest.position.x, dest.position.x + dst_m, dest.end.x - dst_m, dest.end.x]
	var dy: Array[float] = [dest.position.y, dest.position.y + dst_m, dest.end.y - dst_m, dest.end.y]
	for iy in 3:
		for ix in 3:
			var src := Rect2(sx[ix], sy[iy], sx[ix + 1] - sx[ix], sy[iy + 1] - sy[iy])
			var dst := Rect2(dx[ix], dy[iy], dx[ix + 1] - dx[ix], dy[iy + 1] - dy[iy])
			if src.size.x < 0.5 or src.size.y < 0.5 or dst.size.x < 0.5 or dst.size.y < 0.5:
				continue
			draw_texture_rect_region(tex, dst, src)


func _draw_name_tag(font: Font, sp: Dictionary, s: Dictionary, is_face: bool, dim: float, is_hover: bool, i: int = -1) -> void:
	var name_s: String = str(s.get("name", "")).strip_edges()
	if name_s == "":
		return
	var fs: int = int(_tag_fs.get(i, 15))
	var tag: Rect2 = sp.get("tag_rect", Rect2())
	var lip := 16.0
	var shell := Rect2(tag.position - Vector2(lip, 0.0), Vector2(tag.size.x + lip, tag.size.y))
	_draw_nine_slice(tex_name_tag, shell, 5.0, minf(8.0, shell.size.y * 0.28))
	var col: Color = Color("e8c36a") if is_face else INK_ON_DARK
	col.a = dim
	var call_s: String = _call_of_slice(i)
	var text_box := Rect2(tag.position.x + 10.0, tag.position.y, maxf(24.0, tag.size.x - 10.0), tag.size.y)
	var name_y: float = text_box.position.y + 6.0 + font.get_ascent(fs)
	var tsz: Vector2 = font.get_string_size(name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = Vector2(text_box.position.x + (text_box.size.x - tsz.x) * 0.5, name_y)
	for ox in range(-3, 4):
		for oy in range(-3, 4):
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("100e0c"))
	draw_string(font, p, name_s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	if call_s != "":
		var call_col: Color = _ability_icon_color(str(s.get("special_id", "")))
		call_col.a = dim
		var csz: Vector2 = font.get_string_size(call_s, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		var call_y: float = name_y + (font.get_height(fs) - font.get_ascent(fs)) + 1.0 + font.get_ascent(11)
		var cp: Vector2 = Vector2(text_box.position.x + (text_box.size.x - csz.x) * 0.5, call_y)
		for ox2 in range(-2, 3):
			for oy2 in range(-2, 3):
				if ox2 == 0 and oy2 == 0:
					continue
				draw_string(font, cp + Vector2(ox2, oy2), call_s, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("100e0c"))
		draw_string(font, cp, call_s, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, call_col)
	var medal: Vector2 = sp.get("medal", Vector2(shell.position.x + 14.0, shell.position.y + shell.size.y * 0.5))
	var mtex: Texture2D = _medal_tex(str(s.get("card_id", "")))
	var ring: float = MEDAL_PX * 0.62
	var ma: float = 0.45 if bool(s.get("silenced", false)) else dim
	draw_circle(medal, ring + 1.5, Color("1a120e", ma))
	draw_arc(medal, ring + 1.5, 0.0, TAU, 28, Color("c4a574", ma), 3.0, true)
	var mdest := Rect2(medal - Vector2(MEDAL_PX * 0.5, MEDAL_PX * 0.5), Vector2(MEDAL_PX, MEDAL_PX))
	if mtex != null:
		draw_texture_rect(mtex, mdest, false, Color(1, 1, 1, ma))
	else:
		draw_circle(medal, MEDAL_PX * 0.34, Color(0.16, 0.14, 0.12, ma))
	if is_hover and show_shift:
		draw_arc(Vector2(mdest.get_center()), MEDAL_PX * 0.55, 0.0, TAU, 28, TAG_GOLD, 3.0, true)


func _draw_slice_title(font: Font, sp: Dictionary, s: Dictionary, is_face: bool, crowded: bool, dim: float = 1.0, is_hover: bool = false) -> void:
	var laid: Dictionary = _title_metrics(font, sp, s, is_face, crowded, is_hover)
	if laid.is_empty():
		return
	var name_fs: int = int(laid.name_fs)
	var call_fs: int = int(laid.call_fs)
	var rect: Rect2 = laid.rect
	var name_txt: String = str(laid.name_txt)
	var call_txt: String = str(laid.call_txt)
	name_fs = int(laid.name_fs)
	call_fs = int(laid.call_fs)
	var inner_w: float = float(laid.inner_w)
	var fill := Color(0.08, 0.06, 0.05, 0.90 * dim)
	var edge: Color = Color("e8c36a") if is_face else Color("c4a574")
	edge.a = dim
	_draw_capsule(rect, fill, edge)
	var ink := Color(0.06, 0.05, 0.04, dim)
	var name_col: Color = Color("e8c36a") if is_face else Color("f0e6d8")
	name_col.a = dim
	var np := Vector2(float(laid.name_x), float(laid.name_base))
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_multiline_string(font, np + Vector2(ox, oy), name_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, name_fs, 2, ink)
	draw_multiline_string(font, np, name_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, name_fs, 2, name_col)
	if call_txt != "":
		var col: Color = _ability_icon_color(str(s.get("special_id", "")))
		col.a = dim
		var cp := Vector2(float(laid.name_x), float(laid.call_base))
		for ox2 in [-1, 0, 1]:
			for oy2 in [-1, 0, 1]:
				if ox2 == 0 and oy2 == 0:
					continue
				draw_multiline_string(font, cp + Vector2(ox2, oy2), call_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, call_fs, 2, ink)
		draw_multiline_string(font, cp, call_txt, HORIZONTAL_ALIGNMENT_CENTER, inner_w, call_fs, 2, col)


func _title_metrics(font: Font, sp: Dictionary, s: Dictionary, is_face: bool, crowded: bool, is_hover: bool) -> Dictionary:
	var name_s: String = str(s.get("name", "")).strip_edges()
	var call_s: String = str(s.get("call_name", "")).strip_edges()
	if bool(s.get("silenced", false)):
		call_s = COPY.text("status.silenced", "Silenced")
	elif show_shift and str(s.get("card_id", "")) != "golem" and str(s.get("card_id", "")) != "wizard":
		var shift_s: String = str(s.get("reminder", "")).strip_edges()
		if shift_s == "" or shift_s == "---":
			shift_s = str(s.get("ability", "")).strip_edges()
		if shift_s != "":
			call_s = shift_s
	if bool(s.get("fled_once", false)) and str(s.get("card_id", "")) == "commander" and call_s != "":
		call_s = "%s · used" % call_s
	if name_s == "":
		return {}
	if call_s.to_lower() == name_s.to_lower() or (call_s != "" and name_s.to_lower().find(call_s.to_lower()) >= 0):
		call_s = ""
	var name_fs: int = 18 if is_face else (15 if is_hover else 13)
	var call_fs: int = 12 if is_face else 11
	if crowded:
		name_fs = maxi(12, name_fs - 2)
		call_fs = maxi(10, call_fs - 1)
	var span: float = absf(float(sp.get("span", 0.6)))
	var max_w: float = clampf(_radius() * maxf(span, 0.18) * 0.92, 88.0, 168.0)
	var name_fit: Dictionary = _fit_plate_label(font, name_s, name_fs, 10 if crowded else 11, max_w)
	name_fs = int(name_fit.get("fs", name_fs))
	var name_txt: String = str(name_fit.get("text", name_s))
	var edge_w := 1.6
	var sub_clear := 2.0
	# Text is stroked 1px, and the capsule stroke sits on the rect edge.
	var pad_x := 8.0
	var pad_top := 4.0
	var pad_bot := sub_clear + edge_w + 1.0
	var gap := 2.0
	var max_h: float = clampf(_radius() * 0.30, 56.0, 108.0)
	var name_sz: Vector2 = font.get_multiline_string_size(name_txt, HORIZONTAL_ALIGNMENT_CENTER, max_w, name_fs)
	var call_txt := ""
	var call_sz := Vector2.ZERO
	if call_s != "":
		var room: float = max_h - pad_top - pad_bot - name_sz.y - gap
		room = maxf(font.get_height(8), room)
		var plan: Dictionary = FitLabelBox.plan(font, call_s, Vector2(max_w, room), call_fs, 8 if crowded else 9, 2)
		call_fs = int(plan.get("size", call_fs))
		if bool(plan.get("wrap", false)):
			var wrapped: String = _wrap_at_break_only(font, call_s, call_fs, max_w)
			call_txt = wrapped if wrapped != "" else call_s
		else:
			call_txt = call_s
		call_sz = font.get_multiline_string_size(call_txt, HORIZONTAL_ALIGNMENT_CENTER, max_w, call_fs)
	var inner_w: float = minf(maxf(name_sz.x, call_sz.x), max_w)
	var w: float = inner_w + pad_x * 2.0
	var h: float = pad_top + name_sz.y + pad_bot
	if call_txt != "":
		h += gap + call_sz.y
	var dir: Vector2 = sp["dir"]
	var port: Vector2 = sp["port"]
	var plate_r: float = float(sp.get("plate_r", 36.0))
	var rim: Vector2 = Vector2(sp["origin"]) + dir * float(sp["r"])
	var band_a: Vector2 = port + dir * (plate_r + 10.0)
	var band_b: Vector2 = rim - dir * (h * 0.5 + 6.0)
	var pos: Vector2 = band_a.lerp(band_b, 0.42) if band_a.distance_to(band_b) > 4.0 else Vector2(sp["name"])
	var top_left := Vector2(pos.x - w * 0.5, pos.y - h * 0.5)
	var name_base: float = top_left.y + pad_top + font.get_ascent(name_fs)
	var cursor: float = top_left.y + pad_top + name_sz.y
	var call_base := 0.0
	if call_txt != "":
		call_base = cursor + gap + font.get_ascent(call_fs)
		cursor += gap + call_sz.y
	return {
		"rect": Rect2(top_left, Vector2(w, h)),
		"name_txt": name_txt,
		"call_txt": call_txt,
		"tier_txt": "",
		"name_fs": name_fs,
		"call_fs": call_fs,
		"tier_fs": 0,
		"inner_w": inner_w,
		"name_x": top_left.x + pad_x,
		"name_base": name_base,
		"call_base": call_base,
		"tier_base": 0.0,
	}


func _ability_icon_color(sid: String) -> Color:
	match sid:
		"item_atk", "two_items", "gift", "eat_item", "petrify", "petrify_gaze", "no_keep", "item_swings", "hunter_mark", "fair_trade", "gift_shield", "insure", "triple_threat", "hunger_pains", "dance_swap", "hatch", "rebirth", "adaptation", "fairy_dust", "fairy_bottle", "cats_eye", "toxic_skin", "decay":
			return Color("e8c36a")
		"no_atk_dmg", "double_hit", "self_deconstruct", "atk_spin", "copy_atk", "buff_atk", "pierce", "thorns", "queen_hits", "interrupt", "even_twice", "left_atk", "pass_right", "coward", "blood_thresh", "conductive":
			return Color("e07040")
		"last_hp", "buff_hp", "undying", "hp_spin", "pack_hp", "leech_lowest", "one_chip", "take_instead", "blood_pact", "three_hp", "cultivator", "lifelink":
			return Color("e8a0a0")
		"kill_scale", "atk_eq_hp":
			return Color("c9a0ff")
		"wickrise":
			return Color("e8c36a")
		"split_t2":
			return Color("c5cdd8")
		"refract":
			return Color("7eb6d6")
		"toll_dead":
			return Color("d4a24a")
		"rust":
			return Color("c47a3a")
		_:
			if sid == "":
				return Color("c5cdd8")
			var palette: Array[Color] = [
				Color("7eb6d6"), Color("d4a24a"), Color("c47a3a"), Color("7dba7d"),
				Color("c9a0ff"), Color("e07040"), Color("e8a0a0"), Color("c5cdd8"),
			]
			return palette[absi(sid.hash()) % palette.size()]


func _fit_plate_label(font: Font, label: String, start_fs: int, min_fs: int, max_w: float) -> Dictionary:
	if label == "":
		return {"text": "", "fs": start_fs}
	var fs: int = start_fs
	while fs >= min_fs:
		if font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= max_w:
			return {"text": label, "fs": fs}
		var wrapped: String = _wrap_at_break_only(font, label, fs, max_w)
		if wrapped != "":
			return {"text": wrapped, "fs": fs}
		fs -= 1
	var last: String = _wrap_at_break_only(font, label, min_fs, max_w)
	if last != "":
		return {"text": last, "fs": min_fs}
	return {"text": label, "fs": min_fs}


func _wrap_at_break_only(font: Font, label: String, fs: int, max_w: float) -> String:
	var best := -1
	for i in label.length():
		var ch: String = label.substr(i, 1)
		if ch != " " and ch != "-":
			continue
		var left: String = label.substr(0, i + (1 if ch == "-" else 0))
		if font.get_string_size(left, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= max_w:
			best = i
	if best < 0:
		return ""
	var cut: int = best + (1 if label.substr(best, 1) == "-" else 0)
	var a: String = label.substr(0, cut).strip_edges()
	var b: String = label.substr(cut).strip_edges()
	if b.begins_with("-"):
		b = b.substr(1).strip_edges()
	if a == "" or b == "":
		return ""
	return a + "\n" + b


func _draw_capsule(rect: Rect2, fill: Color, edge: Color) -> void:
	var rr: float = rect.size.y * 0.5
	var y: float = rect.position.y + rr
	var x0: float = rect.position.x + rr
	var x1: float = rect.position.x + rect.size.x - rr
	draw_circle(Vector2(x0, y), rr, fill)
	draw_circle(Vector2(x1, y), rr, fill)
	draw_rect(Rect2(x0, rect.position.y, maxf(0.0, x1 - x0), rect.size.y), fill, true)
	draw_arc(Vector2(x0, y), rr, PI * 0.5, PI * 1.5, 12, edge, 1.6, true)
	draw_arc(Vector2(x1, y), rr, -PI * 0.5, PI * 0.5, 12, edge, 1.6, true)
	draw_line(Vector2(x0, rect.position.y), Vector2(x1, rect.position.y), edge, 1.6, true)
	draw_line(Vector2(x0, rect.position.y + rect.size.y), Vector2(x1, rect.position.y + rect.size.y), edge, 1.6, true)


func _d() -> CanvasItem:
	return _ext_ci if _ext_ci != null else self


func _draw_bold_num(font: Font, pos: Vector2, txt: String, fs: int, col: Color) -> void:
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = pos + Vector2(-tsz.x * 0.5, fs * 0.36)
	var ink := Color("100e0c")
	var ci := _d()
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			ci.draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	ci.draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _star_pts(c: Vector2, outer: float, inner: float, n: int = 8) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n * 2:
		var rad: float = outer if i % 2 == 0 else inner
		var a: float = -PI * 0.5 + float(i) * PI / float(n)
		pts.append(c + Vector2.from_angle(a) * rad)
	return pts


func _atk_variant_texture(kind: String) -> Texture2D:
	var key: String = kind if kind == "loop" or kind == "double" else "single"
	if _atk_variant_cache.has(key):
		return _atk_variant_cache[key]
	var path := "res://assets/ui/icons/atk_burst_%s_s18_2x.png" % key
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		tex = tex_atk
	_atk_variant_cache[key] = tex
	return tex


func _draw_atk_variant(pos: Vector2, kind: String, punch: float, fill: Color) -> Vector2:
	var tex: Texture2D = _atk_variant_texture(kind)
	var front: Vector2 = Vector2(18.0, 18.0)
	if kind == "double":
		front = Vector2(18.0, 24.0)
	if tex == null:
		_draw_stat_icon(pos, null, 36.0, fill, false, true)
		return pos + Vector2(18.0, -18.0)
	var grow: float = 1.0 + punch * 0.08
	var draw_sz: Vector2 = tex.get_size() * grow
	var top_left: Vector2 = pos - front * grow
	var rect := Rect2(top_left, draw_sz)
	var ci := _d()
	for k in 8:
		var o: Vector2 = Vector2.from_angle(float(k) * TAU / 8.0) * 2.2
		ci.draw_texture_rect(tex, Rect2(rect.position + o, rect.size), false, Color("100e0c"))
	ci.draw_texture_rect(tex, rect, false, Color.WHITE)
	return top_left + Vector2(draw_sz.x, 0.0)


func _draw_closed_empty(origin: Vector2, dir: Vector2, r: float) -> void:
	var mid: Vector2 = origin + dir * r * 0.62
	var plank := Color("2a2218")
	var rim := Color("6a5a48")
	var w := 34.0
	var h := 42.0
	draw_rect(Rect2(mid - Vector2(w * 0.5, h * 0.5), Vector2(w, h)), plank, true)
	draw_rect(Rect2(mid - Vector2(w * 0.5, h * 0.5), Vector2(w, h)), rim, false, 2.0)
	draw_line(mid + Vector2(-w * 0.42, -h * 0.38), mid + Vector2(w * 0.42, h * 0.38), Color("100e0c"), 5.0, true)
	draw_line(mid + Vector2(w * 0.42, -h * 0.38), mid + Vector2(-w * 0.42, h * 0.38), Color("100e0c"), 5.0, true)
	draw_line(mid + Vector2(-w * 0.42, -h * 0.38), mid + Vector2(w * 0.42, h * 0.38), Color("8a7a62"), 2.2, true)
	draw_line(mid + Vector2(w * 0.42, -h * 0.38), mid + Vector2(-w * 0.42, h * 0.38), Color("8a7a62"), 2.2, true)


func _draw_atk_stat(font: Font, pos: Vector2, s: Dictionary, pv: Dictionary, big: bool, i: int = -1, is_hover: bool = false) -> void:
	var atk: int = int(s.get("atk", 0))
	if i >= 0 and _atk_disp.has(i):
		atk = int(_atk_disp[i])
	var atk_d: int = int(pv.get("atk", 0))
	var atk_next: int = atk + atk_d
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
	var fill: Color = ATK_FILL
	if bool(s.get("atk_variable", false)) or str(pv.get("mark", "")) == "spin" or (int(log_focus.get("wheel", -1)) == i and bool(log_focus.get("atk", false))):
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if atk_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif atk_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var punch: float = float(_atk_punch.get(i, 0.0)) if i >= 0 else 0.0
	if punch > 0.02:
		fill = fill.lerp(Color("ffd0a0"), punch * 0.55)
	var icon_sz: float = 36.0 + punch * 4.0
	var atk_kind: String = str(s.get("atk_kind", "single"))
	if atk_kind != "loop" and atk_kind != "double":
		atk_kind = "single"
	var atk_n: int = int(s.get("atk_n", 1))
	_draw_stat_plate(pos, icon_sz)
	if is_hover:
		var glow: float = 0.40 + 0.45 * absf(sin(_glow_t * 8.0))
		_d().draw_arc(pos, icon_sz * 0.72, 0.0, TAU, 22, Color(1.0, 0.85, 0.29, glow), 3.2, true)
	var drawn: Vector2 = _draw_atk_variant(pos, atk_kind, punch, fill)
	var ci := _d()
	if bool(s.get("cmd_buff", false)):
		ci.draw_arc(pos, icon_sz * 0.58, 0.0, TAU, 24, Color(0.95, 0.22, 0.16, 0.45 + 0.5 * pulse), 2.6, true)
	if int(s.get("copy_from", -1)) >= 0:
		ci.draw_arc(pos, icon_sz * 0.55, 0.0, TAU, 24, Color(0.72, 0.42, 0.92, 0.4 + 0.45 * pulse), 2.4, true)
	_draw_stat_number(font, pos, icon_sz, str(atk), 0.0)
	if atk_d != 0:
		var blink: float = 0.40 + 0.60 * absf(sin(_glow_t * 10.0))
		var dc: Color = UP_COL if atk_d > 0 else DOWN_COL
		dc.a = blink
		_draw_bold_num(font, pos + Vector2(0.0, -icon_sz * 0.62), str(atk_next), 18 if big else 15, dc)
		ci.draw_string(font, pos + Vector2(icon_sz * 0.28, -icon_sz * 0.38), _delta_text(atk_d), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, dc)
	if atk_kind == "double" and atk_n >= 3:
		UxStyle.draw_multi_tag(ci, drawn, "×%d" % atk_n, font)


func _draw_atk_badge(pos: Vector2, rad: float, fill: Color) -> void:
	var ink := Color("100e0c")
	var edge: Color = ATK_EDGE
	_fill_star(pos, rad * 1.22, rad * 0.46, ink)
	_fill_star(pos, rad * 1.08, rad * 0.40, fill)
	_d().draw_arc(pos, rad * 0.42, 0.0, TAU, 22, edge, 1.6, true)


func _fill_star(c: Vector2, outer: float, inner: float, col: Color, n: int = 8) -> void:
	var pts: PackedVector2Array = _star_pts(c, outer, inner, n)
	var count: int = pts.size()
	if count < 3:
		return
	var ci := _d()
	for i in count:
		ci.draw_colored_polygon(PackedVector2Array([c, pts[i], pts[(i + 1) % count]]), col)


func _draw_heart_stat(font: Font, pos: Vector2, s: Dictionary, pv: Dictionary, big: bool, i: int = -1, is_hover: bool = false) -> void:
	var hp: int = int(s.get("hp", 0))
	if i >= 0 and _hp_disp.has(i):
		hp = int(_hp_disp[i])
	var hp_d: int = int(pv.get("hp", 0))
	var hp_next: int = hp + hp_d
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
	var fill: Color = HP_FILL
	if bool(s.get("hp_variable", false)) or str(pv.get("mark", "")) == "spin" or (int(log_focus.get("wheel", -1)) == i and bool(log_focus.get("hp", false))):
		fill = fill.lerp(SPIN_COL, 0.25 * pulse)
	if hp_d < 0:
		fill = fill.lerp(DOWN_COL, 0.45)
	elif hp_d > 0:
		fill = fill.lerp(UP_COL, 0.35)
	var punch: float = float(_hp_punch.get(i, 0.0)) if i >= 0 else 0.0
	if punch > 0.02:
		fill = fill.lerp(Color("ffd0a0"), punch * 0.55)
	var hs: float = 36.0 + punch * 4.0
	var heart_tex: Texture2D = tex_heart_full if tex_heart_full != null else tex_heart
	_draw_stat_plate(pos, hs)
	if is_hover:
		var glow: float = 0.40 + 0.45 * absf(sin(_glow_t * 8.0))
		_d().draw_arc(pos, hs * 0.72, 0.0, TAU, 22, Color(1.0, 0.85, 0.29, glow), 3.2, true)
	_draw_stat_icon(pos, heart_tex, hs, fill, true, true)
	var ci := _d()
	if punch > 0.35:
		var slash := Color("f0e6d8", punch * 0.85)
		var arm: float = hs * 0.42
		ci.draw_line(pos + Vector2(-arm, -arm * 0.2), pos + Vector2(arm, arm * 0.55), Color("1c120c", punch), 4.2, true)
		ci.draw_line(pos + Vector2(-arm, -arm * 0.2), pos + Vector2(arm, arm * 0.55), slash, 2.4, true)
	if bool(s.get("lich_buff", false)):
		var pulse2: float = 0.55 + 0.45 * sin(_glow_t * 7.0)
		ci.draw_arc(pos, hs * 0.52, 0.0, TAU, 20, Color(0.95, 0.88, 0.72, 0.4 + 0.5 * pulse2), 2.6, true)
	_draw_stat_number(font, pos, hs, str(hp), -0.08)
	_draw_poison_badge(font, pos, s, big, i)
	if hp_d != 0:
		var blink: float = 0.40 + 0.60 * absf(sin(_glow_t * 10.0))
		var dc: Color = UP_COL if hp_d > 0 else DOWN_COL
		dc.a = blink
		_draw_bold_num(font, pos + Vector2(0.0, -hs * 0.62), str(hp_next), 18 if big else 15, dc)
		ci.draw_string(font, pos + Vector2(hs * 0.28, -hs * 0.38), _delta_text(hp_d), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, dc)



func _poison_n(s: Dictionary) -> int:
	if s.has("poison"):
		return maxi(0, int(s.get("poison", 0)))
	return 5 if bool(s.get("poisoned", false)) else 0


func _poison_tex() -> Texture2D:
	if tex_poison == null and ResourceLoader.exists("res://assets/icons/droplet.svg"):
		tex_poison = load("res://assets/icons/droplet.svg") as Texture2D
	return tex_poison


func _ensure_poison_drip() -> void:
	if not _poison_drip.is_empty():
		return
	for i in 4:
		var p := "res://assets/ui/anim/poison_badge_drip_f%s.png" % i
		if ResourceLoader.exists(p):
			_poison_drip.append(load(p) as Texture2D)
	if _poison_lock_tex == null and ResourceLoader.exists("res://assets/ui/anim/poison_lock.png"):
		_poison_lock_tex = load("res://assets/ui/anim/poison_lock.png") as Texture2D


func _draw_poison_badge(font: Font, pos: Vector2, s: Dictionary, big: bool, idx: int = -1) -> void:
	var n: int = _poison_n(s)
	var clear_t: float = float(_poison_clear_t.get(idx, 0.0)) if idx >= 0 else 0.0
	if n <= 0 and clear_t <= 0.01:
		return
	_ensure_poison_drip()
	var locked: bool = bool(s.get("plague_held", false))
	var drop_pos: Vector2 = pos + Vector2(26.0 if big else 22.0, -16.0 if big else -14.0)
	var bob: float = 0.0 if locked else (2.0 * sin(_glow_t * 4.0))
	drop_pos.y += bob
	var sc: float = float(_poison_badge_scale.get(idx, 1.0)) if idx >= 0 else 1.0
	if clear_t > 0.01:
		sc *= clear_t
	var base_sz := Vector2(48, 48) if big else Vector2(42, 42)
	var sz: Vector2 = base_sz * sc
	var art_col := Color.WHITE
	var legacy_col := Color("7dba7d")
	var drip_tex: Texture2D = null
	if not locked and not _poison_drip.is_empty():
		var fi: int = int(floor(_glow_t / 0.15)) % _poison_drip.size()
		drip_tex = _poison_drip[fi]
	var ci := _d()
	if drip_tex != null:
		var ink := Color("100e0c", art_col.a)
		var rim: Vector2 = sz + Vector2(6, 6)
		ci.draw_texture_rect(drip_tex, Rect2(drop_pos - rim * 0.5, rim), false, ink)
		ci.draw_texture_rect(drip_tex, Rect2(drop_pos - sz * 0.5, sz), false, art_col)
	else:
		var tex: Texture2D = _poison_tex()
		if tex != null:
			ci.draw_texture_rect(tex, Rect2(drop_pos - sz * 0.5, sz * 0.5), false, Color("100e0c"))
			ci.draw_texture_rect(tex, Rect2(drop_pos - sz * 0.45, sz * 0.42), false, legacy_col)
		else:
			ci.draw_circle(drop_pos, 8.0 * sc if big else 7.0 * sc, Color("100e0c"))
			ci.draw_circle(drop_pos, 6.0 * sc if big else 5.0 * sc, legacy_col)
	if n > 0:
		_draw_bold_num(font, drop_pos + Vector2(16.0 * sc, 2.0), str(n), 16 if big else 14, Color("d8f0d0"))
	if locked and _poison_lock_tex != null:
		var lz := Vector2(12, 12) if big else Vector2(10, 10)
		ci.draw_texture_rect(_poison_lock_tex, Rect2(drop_pos + Vector2(6, 4) - lz * 0.5, lz), false, Color.WHITE)
	elif locked:
		ci.draw_rect(Rect2(drop_pos + Vector2(4, 2), Vector2(6, 7)), Color("e8c36a"))


func _delta_text(d: int) -> String:
	if d > 0:
		return "+%s" % d
	return str(d)


func _draw_floaters(font: Font) -> void:
	for f in _floaters:
		var t: float = float(f["t"])
		var life: float = float(f["life"])
		var a: float = 1.0 - t / life
		var pos: Vector2 = f["pos"] + Vector2(0.0, -36.0 * t)
		var col: Color = f["col"]
		col.a = a
		var fs: int = int(f.get("fs", 26))
		draw_string(font, pos, str(f["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	for g in _pt_ghosts:
		var t2: float = float(g["t"])
		var life2: float = float(g["life"])
		var a2: float = 1.0 - t2 / life2
		var pos2: Vector2 = g["pos"] + Vector2(0.0, -16.0 * t2)
		var col2: Color = g["col"]
		col2.a = a2
		draw_string(font, pos2, str(g["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, int(g.get("fs", 18)), col2)


func _draw_hub_block(c: Vector2, _radius: float) -> void:
	var sting_tint := Color.WHITE
	if hub_sting > 0.02:
		if hub_sting_kind == "hurt":
			sting_tint = Color.WHITE.lerp(Color("e07a7a"), hub_sting * 0.85)
		else:
			sting_tint = Color.WHITE.lerp(Color("8ec8f0"), hub_sting * 0.7)
	var top: Vector2 = _layout_xy("hero", "texture_top_left_from_c", Vector2(-48, -50))
	var hero_rect := Rect2(c + top + hub_nudge, Vector2(96, 96))
	hero_rect.position = hero_rect.position.round()
	var frames: Array = _hero_frames.get(hero_anim, tex_player)
	var tex: Texture2D = null
	if typeof(frames) == TYPE_ARRAY and not frames.is_empty():
		var fi: int = clampi(hero_frame, 0, frames.size() - 1)
		tex = frames[fi]
	if tex and hub_sprout_on and not hub_parade_hide and hub_mod.a > 0.01:
		var tint: Color = sting_tint * hub_mod
		var pivot := Vector2(hero_rect.get_center().x, hero_rect.end.y)
		var scx: float = -1.0 if hub_flip else 1.0
		draw_set_transform(pivot, 0.0, Vector2(scx, hub_sy))
		draw_texture_rect(tex, Rect2(hero_rect.position - pivot, hero_rect.size), false, tint)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if not hub_flip and is_equal_approx(hub_sy, 1.0):
			_draw_hub_gear(hero_rect, tint)
	elif tex == null and not hub_parade_hide:
		draw_circle(c + Vector2(0, 8) + hub_nudge, 16.0, Color("c4a574") * sting_tint)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var dim: float = 0.35 if hub_death_dim else 1.0
	_draw_hub_heart_arc(dim)
	_draw_hub_poison_badge(font, dim)
	_draw_blk_badge(c, font, dim)
	if hub_sting > 0.02:
		var ink: Color = Color("e07a7a") if hub_sting_kind == "hurt" else Color("5aa8e8")
		ink.a = hub_sting * 0.9
		var origin: Vector2 = c + (Vector2(0, 8) if hub_sting_kind == "hurt" else _badge_xy("blk", "visual_centre_from_c", Vector2(0, 71)))
		var burst: float = lerpf(22.0, 10.0, hub_sting)
		draw_arc(origin, burst * 0.55, 0.0, TAU, 18, Color(ink.r, ink.g, ink.b, hub_sting * 0.45), 2.0, true)
		for i in 6:
			var ang: float = float(i) * TAU / 6.0
			var inner: Vector2 = origin + Vector2.from_angle(ang) * burst * 0.22
			var outer: Vector2 = origin + Vector2.from_angle(ang) * burst
			draw_line(inner, outer, ink, 2.4, true)


func _draw_hub_gear(hero_rect: Rect2, sting_tint: Color) -> void:
	var head: String = str(hub_gear.get("head", ""))
	for piece in HERO_GEAR_ORDER:
		var worn: bool = false
		if piece == "rope":
			worn = str(hub_gear.get("belt", "")) == "rope"
		elif piece == "goggles":
			worn = str(hub_gear.get("eyes", "")) == "goggles"
		elif piece == "cap" or piece == "helm":
			worn = head == piece
		if not worn:
			continue
		var by_anim: Dictionary = _hero_gear.get(piece, {})
		var frames: Array = by_anim.get(hero_anim, [])
		if frames.is_empty():
			continue
		var fi: int = clampi(hero_frame, 0, frames.size() - 1)
		var gtex: Texture2D = frames[fi]
		if gtex:
			draw_texture_rect(gtex, hero_rect, false, sting_tint)


func _hp_badge_stem() -> String:
	if hub_hp <= 0:
		return "badge_hp_empty"
	if _hero_is_low():
		return "badge_hp_low"
	var flashing: bool = (hub_hp_ghost >= 0 and hub_hp_ghost < hub_hp) or bool(log_focus.get("hub_hp", false))
	if flashing and sin(_glow_t * 12.0) > 0.0:
		return "badge_hp_flash"
	return "badge_hp"


func _blk_badge_stem() -> String:
	if hub_pierce:
		return "badge_blk_pierced"
	var shown: int = hub_ghost if hub_ghost >= 0 else hub_blk
	if shown <= 0:
		return "badge_blk_empty"
	if (hub_ghost >= 0 and hub_ghost > hub_blk) or bool(log_focus.get("hub_blk", false)):
		return "badge_blk_up"
	return "badge_blk"


func _draw_badge_tex(c: Vector2, which: String, stem: String, punch: bool, dim: float) -> Rect2:
	var local: Rect2 = _badge_rect_from_c(which)
	var vis: Vector2 = _badge_xy(which, "visual_centre_from_c", local.position + local.size * 0.5)
	var size: Vector2 = local.size
	if punch:
		size = size * 1.25
	var pos: Vector2 = c + vis - size * 0.5
	if not punch:
		pos = (c + local.position).round()
		size = local.size
	var rect := Rect2(pos.round() if punch else pos, size)
	var tex: Texture2D = _badge_tex.get(stem, null)
	var col := Color(1, 1, 1, dim)
	if tex:
		draw_texture_rect(tex, rect, false, col)
	return rect


func _draw_hp_badge(c: Vector2, font: Font, dim: float) -> void:
	_draw_badge_tex(c, "hp", _hp_badge_stem(), _hp_punch_t > 0.0, dim)
	var anchor: Vector2 = c + _badge_xy("hp", "number_anchor_from_c", Vector2(-42, 41))
	var ncol := Color("f0e6d8")
	ncol.a = dim
	_draw_bold_num(font, anchor, str(maxi(hub_hp, 0)), 18, ncol)


func _draw_blk_badge(c: Vector2, font: Font, dim: float) -> void:
	_draw_badge_tex(c, "blk", _blk_badge_stem(), _blk_punch_t > 0.0, dim)
	var shown: int = hub_ghost if hub_ghost >= 0 else hub_blk
	var txt: String = str(maxi(shown, 0))
	var anchor: Vector2 = c + _badge_xy("blk", "number_anchor_from_c", Vector2(0, 72))
	var ncol := Color("f0e6d8")
	ncol.a = dim
	_draw_bold_num(font, anchor, txt, 18, ncol)
	if _hub_old_t > 0.0 and _hub_old != txt:
		var oc := Color(0.94, 0.90, 0.85, _hub_old_t * dim)
		var osz: Vector2 = font.get_string_size(_hub_old, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
		draw_string(font, anchor + Vector2(-osz.x * 0.5, 8.0 - (1.0 - _hub_old_t) * 16.0), _hub_old, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, oc)
	if _pierce_float_t >= 0.0:
		var t: float = clampf(_pierce_float_t / 0.7, 0.0, 1.0)
		var from_c: Vector2 = _badge_xy("blk", "from_c", Vector2(0, 48))
		var pierce: Dictionary = _hero_layout.get("badges", {}).get("pierce_text", {}) if typeof(_hero_layout.get("badges", {})) == TYPE_DICTIONARY else {}
		var from_a: Variant = pierce.get("from_c", [0, 48])
		var to_a: Variant = pierce.get("to_c", [0, 34])
		if typeof(from_a) == TYPE_ARRAY and (from_a as Array).size() >= 2:
			from_c = Vector2(float(from_a[0]), float(from_a[1]))
		var to_c := Vector2(0, 34)
		if typeof(to_a) == TYPE_ARRAY and (to_a as Array).size() >= 2:
			to_c = Vector2(float(to_a[0]), float(to_a[1]))
		var pos: Vector2 = c + from_c.lerp(to_c, t)
		var a: float = 1.0
		if _pierce_float_t > 0.4:
			a = clampf(1.0 - (_pierce_float_t - 0.4) / 0.3, 0.0, 1.0)
		var col := Color("e8c36a", a)
		var ink := Color("100e0c", a)
		_draw_outlined_string(font, pos + Vector2(0, 4), "IGNORED", 10, col, ink)


func _heart_pts(pos: Vector2, hs: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 28:
		var th: float = TAU * float(k) / 28.0
		var x: float = 16.0 * pow(sin(th), 3.0)
		var y: float = -(13.0 * cos(th) - 5.0 * cos(2.0 * th) - 2.0 * cos(3.0 * th) - cos(4.0 * th))
		pts.append(pos + Vector2(x, y) * (hs / 34.0))
	return pts


func _draw_heart_shape(pos: Vector2, hs: float, fill: Color, outline: Color) -> void:
	var ci := _d()
	var outer: PackedVector2Array = _heart_pts(pos, hs * 1.14)
	ci.draw_colored_polygon(outer, outline)
	var inner: PackedVector2Array = _heart_pts(pos, hs)
	ci.draw_colored_polygon(inner, fill)
	ci.draw_circle(pos + Vector2(-hs * 0.16, -hs * 0.10), hs * 0.11, fill.lightened(0.28))


func _draw_stat_plate(pos: Vector2, px: float) -> void:
	if stat_style == 0:
		return
	var plate := Rect2(pos - Vector2(px * 0.72, px * 0.62), Vector2(px * 1.44, px * 1.35))
	var ci := _d()
	ci.draw_rect(plate, Color("100e0c", 0.82), true)
	ci.draw_rect(plate, Color("c4a574"), false, 1.5)


func _draw_stat_number(font: Font, pos: Vector2, px: float, txt: String, y_k: float = 0.08) -> void:
	var at: Vector2 = pos
	var fs: int = 15
	if stat_style == 1:
		at = pos + Vector2(0.0, px * 0.55)
		fs = 14
	elif stat_style == 0:
		at = pos + Vector2(0.0, px * y_k)
	else:
		at = pos + Vector2(0.0, px * 0.08)
	_draw_bold_num(font, at, txt, fs, Color("f0e6d8"))


func _icon_region(tex: Texture2D) -> Rect2:
	var key: String = tex.resource_path
	if _icon_used.has(key):
		return _icon_used[key]
	var img: Image = tex.get_image()
	var region := Rect2(Vector2.ZERO, tex.get_size())
	if img != null:
		var used: Rect2 = img.get_used_rect()
		if used.size.x >= 1.0 and used.size.y >= 1.0:
			region = used
	_icon_used[key] = region
	return region


func _draw_stat_icon(pos: Vector2, tex: Texture2D, px: float, tint: Color, heart_shape: bool, outline: bool = false) -> void:
	if tex != null:
		var region: Rect2 = _icon_region(tex)
		var rect := Rect2(pos - Vector2(px, px) * 0.5, Vector2(px, px))
		var ci := _d()
		if outline:
			for k in 8:
				var o: Vector2 = Vector2.from_angle(float(k) * TAU / 8.0) * 2.2
				ci.draw_texture_rect_region(tex, Rect2(rect.position + o, rect.size), region, Color("100e0c"))
		ci.draw_texture_rect_region(tex, rect, region, Color.WHITE)
		return
	if heart_shape:
		_draw_heart_shape(pos, px * 0.42, tint, Color("1c120c"))
	else:
		_draw_atk_badge(pos, px * 0.42, tint)


func _draw_hub_move_pips(dim: float) -> void:
	if hub_moves_max <= 0:
		return
	var c: Vector2 = _center()
	var hub_r: float = _radius() * HUB_FRAC
	var n: int = hub_moves_max
	var gap: float = 24.0
	var y: float = c.y + hub_r - 16.0
	var total: float = gap * float(n - 1)
	for i in n:
		var p := Vector2(c.x - total * 0.5 + gap * float(i), y)
		_draw_winged_foot(p, 11.0, i < hub_moves, dim)


func _draw_winged_foot(pos: Vector2, s: float, live: bool, dim: float) -> void:
	var a: float = dim if live else dim * 0.38
	var ink := Color("100e0c", a)
	var gold := Color("FFD84A", a)
	var leather := Color("7a4e2b", a)
	var cream := Color("f0e6d8", a)
	if not live:
		gold = Color("6a5f52", a)
		leather = Color("3a322b", a)
		cream = Color("5c6474", a)
	# The five-point wing crosses itself (upper tip through the notch). Godot will not triangulate that.
	var wing_root := pos + Vector2(-s * 0.15, -s * 0.05)
	var wing_notch := pos + Vector2(-s * 0.35, -s * 0.55)
	draw_colored_polygon(PackedVector2Array([
		wing_root,
		pos + Vector2(-s * 1.05, -s * 0.85),
		wing_notch,
	]), ink)
	draw_colored_polygon(PackedVector2Array([
		wing_root,
		wing_notch,
		pos + Vector2(-s * 1.15, -s * 0.25),
		pos + Vector2(-s * 0.20, s * 0.10),
	]), ink)
	var fill: Color = gold if live else cream
	var wing_root_in := pos + Vector2(-s * 0.12, -s * 0.02)
	var wing_notch_in := pos + Vector2(-s * 0.32, -s * 0.48)
	draw_colored_polygon(PackedVector2Array([
		wing_root_in,
		pos + Vector2(-s * 0.92, -s * 0.72),
		wing_notch_in,
	]), fill)
	draw_colored_polygon(PackedVector2Array([
		wing_root_in,
		wing_notch_in,
		pos + Vector2(-s * 0.98, -s * 0.22),
		pos + Vector2(-s * 0.16, s * 0.06),
	]), fill)
	var sole := PackedVector2Array([
		pos + Vector2(-s * 0.45, s * 0.08),
		pos + Vector2(s * 0.70, -s * 0.02),
		pos + Vector2(s * 0.62, s * 0.42),
		pos + Vector2(-s * 0.38, s * 0.48),
	])
	draw_colored_polygon(sole, ink)
	var sole_in := PackedVector2Array([
		pos + Vector2(-s * 0.35, s * 0.14),
		pos + Vector2(s * 0.58, s * 0.04),
		pos + Vector2(s * 0.52, s * 0.34),
		pos + Vector2(-s * 0.28, s * 0.38),
	])
	draw_colored_polygon(sole_in, leather)
	draw_line(pos + Vector2(-s * 0.10, s * 0.16), pos + Vector2(s * 0.40, s * 0.10), cream, 1.2, false)


func _draw_hub_pip(pos: Vector2, sz: Vector2, live: bool, soon: bool, tint: Color = Color.WHITE) -> void:
	var pulse: float = 0.55 + 0.45 * sin(_glow_t * 14.0)
	var draw_sz: Vector2 = sz
	if soon:
		draw_sz *= 1.0 + 0.16 * pulse
	var tex: Texture2D = tex_heart_full if live else tex_heart_empty
	if soon and pulse > 0.55:
		tex = tex_heart_empty
	if tex != null:
		var col: Color = tint
		if soon:
			col = tint.lerp(Color("f0e6d8"), pulse * 0.35)
		draw_texture_rect(tex, Rect2(pos - draw_sz * 0.5, draw_sz), false, col)
		return
	var hcol := HP_FILL if live else Color(0.28, 0.18, 0.16, 0.9)
	if soon:
		hcol = hcol.lerp(Color("f0e6d8"), 0.35 + 0.35 * pulse)
	_draw_heart_shape(pos, draw_sz.x * 0.72, hcol, Color("1c120c"))


func _draw_mini_heart(pos: Vector2, hs: float, col: Color) -> void:
	_draw_heart_shape(pos, hs, col, Color("1c120c"))


func _draw_threat(c: Vector2, radius: float) -> void:
	if threat_t <= 0.02 or facing_index < 0 or facing_index >= slices.size():
		return
	if str(slices[facing_index].get("kind", "")) != "monster":
		return
	var grow: float = clampf(threat_t / 0.38, 0.0, 1.0)
	grow = grow * grow * (3.0 - 2.0 * grow)
	var fade: float = 1.0 if threat_t < 0.58 else clampf(1.0 - (threat_t - 0.58) / 0.42, 0.0, 1.0)
	var from: Vector2 = _spoke(facing_index)["port"]
	var dir: Vector2 = (c - from)
	if dir.length() < 4.0:
		return
	dir = dir.normalized()
	var to: Vector2 = from + (c - from) * (0.18 + 0.62 * grow)
	var col := Color(0.92, 0.18, 0.12, 0.88 * fade)
	var hot := Color(0.98, 0.72, 0.22, 0.75 * fade)
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var pts := PackedVector2Array()
	pts.append(from + perp * 3.0)
	var segs: int = 8
	for k in range(1, segs):
		var t: float = float(k) / float(segs)
		var wob: float = (1.0 if k % 2 == 0 else -1.0) * (7.0 + float(k % 3) * 5.0) * grow
		pts.append(from.lerp(to, t) + perp * wob)
	pts.append(to)
	draw_polyline(pts, col, 6.0 * grow, true)
	draw_polyline(pts, hot, 2.2, true)
	var head := PackedVector2Array([
		to,
		to - dir * 16.0 * grow + perp * 10.0 * grow,
		to - dir * 16.0 * grow - perp * 10.0 * grow,
	])
	draw_colored_polygon(head, col)


func _draw_slay(font: Font, c: Vector2, radius: float) -> void:
	if slay_index < 0 or slay_index >= slices.size():
		return
	var dir: Vector2 = _dir_of(slay_index)
	var pos: Vector2 = c + dir * radius * 0.52 + _slay_push(slay_index)
	var a: float = clampf(slay_t * 1.4, 0.0, 1.0)
	var blocked: bool = slay_kind == "block"
	var escaped: bool = slay_kind == "escape"
	var ink: Color = Color("5aa8e8") if blocked else (Color("e8c36a") if escaped else DOWN_COL)
	var xcol := Color(ink.r, ink.g, ink.b, a)
	var arm: float = lerpf(10.0, 54.0, a)
	if blocked:
		var burst: float = lerpf(18.0, 58.0, a)
		draw_arc(pos, burst, 0.0, TAU, 28, xcol, 7.0, true)
		draw_arc(pos, burst * 0.62, 0.2, TAU + 0.2, 22, Color(ink.r, ink.g, ink.b, a * 0.55), 4.0, true)
		for i in 8:
			var ang: float = float(i) * TAU / 8.0 + slay_t * 0.6
			var inner: Vector2 = pos + Vector2.from_angle(ang) * burst * 0.18
			var outer: Vector2 = pos + Vector2.from_angle(ang) * burst
			draw_line(inner, outer, xcol, 5.0, true)
	elif escaped:
		var arc_r: float = lerpf(14.0, 42.0, a)
		draw_arc(pos, arc_r, -0.6, 0.9, 18, xcol, 6.0, true)
	else:
		draw_line(pos + Vector2(-arm, -arm), pos + Vector2(arm, arm), xcol, 8.0, true)
		draw_line(pos + Vector2(arm, -arm), pos + Vector2(-arm, arm), xcol, 8.0, true)
	if slay_t > 0.18:
		var word: String = COPY.text("combat.blocked", "BLOCKED") if blocked else (COPY.text("combat.escaped", "Escaped") if escaped else COPY.text("combat.slain", "SLAIN"))
		var ta: float = clampf((slay_t - 0.18) / 0.45, 0.0, 1.0)
		var fs: int = 32
		var sz: Vector2 = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var banner := Rect2(pos + Vector2(-sz.x * 0.5 - 12.0, 28.0), Vector2(sz.x + 24.0, 38.0))
		var bg := Color("100e0ce8")
		bg.a *= ta
		var rim: Color = ink if blocked else FACE_RIM
		draw_rect(banner, bg, true)
		draw_rect(banner, Color(rim.r, rim.g, rim.b, ta), false, 2.0)
		draw_string(font, pos + Vector2(-sz.x * 0.5, 56.0), word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(rim.r, rim.g, rim.b, ta))
