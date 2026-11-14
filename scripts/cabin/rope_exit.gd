extends Control
## Challenge rest screen. Child of Main, z 80.

signal climb
signal deeper
signal peek
## Campaign: hover/focus Push while this biome's cabinet is under quota.
signal push_blocked
## Campaign: player accepted Nib's "take me home" on the Push interrupt.
signal push_home

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const GATE_PORTAL_SCR := preload("res://scripts/cabin/gate_portal.gd")
const PX := 4.0
const LAYOUT_PATH := "res://design/visual/layouts/rope-exit.layout.json"
## New Sprout is 64×64. Scale 2 matches the old 128×128 loot hero and the clear-parade land (SCALE_ROPE).
const SPROUT_SCALE := 2.0
const SPROUT_IDLE_FPS := 5.0
const SPROUT_IDLE: Array[String] = [
	"res://assets/dungeon/anim/player/sprout_idle_f0.png",
	"res://assets/dungeon/anim/player/sprout_idle_f1.png",
	"res://assets/dungeon/anim/player/sprout_idle_f2.png",
	"res://assets/dungeon/anim/player/sprout_idle_f3.png",
]

var cabin
var extra: Dictionary = {}
var _cleared: int = 0
var _lay: Dictionary = {}
var _ladder: AnimatedSprite2D
var _ladder_hover: TextureRect
var _hole: TextureRect
var _hole_glow: AnimatedSprite2D
var _hero: AnimatedSprite2D
var _headline: FitLabelBox
var _sub: FitLabelBox
var _title_band: ColorRect
var _sign: NinePatchRect
var _peek_btn: FitButton
var _hatch_hit: Control
var _gate_hit: Control
## Diegetic Climb/Delve hover parchment (Spin-locked rope.home* / rope.next*).
var _hover_tip: FitLabelBox
var _hover_tip_hit: Control
var _campaign_mode: bool = false
var _can_push: bool = true
var _push_interrupt: bool = false
var _interrupt_fired: bool = false
var _interrupt_open: bool = false
var _chip_biome: FitLabelBox
var _chip_count: FitLabelBox
var _chip_biome_name: String = ""
var _chip_n: int = 0
var _chip_quota: int = 5
var _push_block_key: String = "nib.push_block.1"
var _chip_show_proj: bool = false
var _next_carry: FitLabelBox
var _next_name: String = ""
var _show_next_carry: bool = false
var _nib: Sprite2D
var _dialog
var _busy: bool = false
var _chrome: Array = []
var _loot_host: Control
var _loot_count: int = 0
## Bottoms of the haul icons, in this control's space. Arrows use these while the extract lesson is up.
var _loot_tips: Array[Vector2] = []
var _haul_pointers: HaulPointers
## Crypt Classic: cozy hole/torch stay hidden. Rope ladder is the diegetic Climb
## (Nathan lock 2026-11-03) — centered on the skylight shaft. Hatch plate stays
## on disk but hidden so the open shaft + ladder read clean.
var _legacy_decor_visible: bool = false
var _gate_frame: TextureRect
var _gate_chains: TextureRect
var _gate_open: TextureRect
var _gate_portal ## scripts/cabin/gate_portal.gd — spiral behind GateFrame
var _hatch: TextureRect
## Fullscreen ColorRect for Climb leave wipe (moves UP over the cavern).
var _climb_wipe: ColorRect
var _ladder_rest: Vector2 = Vector2.ZERO
var _climb_hot_tw: Tween
var _gate_shake_tw: Tween
## Chip next biome id (b1–b5). Empty → sealed portal.
var _next_biome_id: String = ""
## Portal awake (lever pulled) vs dead stone arch.
var _portal_alive: bool = false
## Placed uniques on this biome's board (0..5). Arch lights.
var _arch_lights_lit: int = 0
var _arch_lights: Array = []
var _floor_satchel: Control = null
var _loot_strip: Control = null
## Imported for a follow-up socket-fill puzzle; not shown in v1.
var _socket_filled_tex: Texture2D
## Dynamic wall tallies (TALLY-SPEC.md). Driven by lifetime clears, not per-run.
var _tally_host: Control
var _tally_bartleby: TextureRect
## -1 = read cabin.lifetime_dungeons_cleared. >=0 forces a display count (shots / QA).
var _tally_debug: int = -1
## Native wall rect (92,82,56,44) → 4× (368,328,224,176).
const TALLY_ORIGIN := Vector2(368, 328)
const TALLY_SIZE := Vector2(224, 176)
const TALLY_MAX := 50
## Option A (2026-11-03): measured plant from Nathan F5 + Pixel annot.
## Hatch plate coords kept for shaft center math; art hidden when ladder shows.
## Gate posts on floor (bottom ≈ 891).
const HATCH_PLATE := Rect2(693, -40, 256, 256)
## Tip rope_ladder_f* is already 160×904 screen px (rope, not chrome). Center on
## hatch/skylight x = 693+128 = 821 → left 741. Tuck top into the shaft opening.
const LADDER_PLATE := Rect2(741, -40, 160, 904)
const GATE_PLATE := Rect2(1180, 379, 384, 512)
## Measured from rope_exit_gate_frame.png (384×512): posts opaque, aperture 64..319 × 64..511.
const GATE_APERTURE := Rect2(1244, 443, 256, 448)
## Soft floor contact under the arch onto the cavern floor (below plant bottom ≈ 891).
const GATE_FLOOR_SHADOW := Rect2(1252, 868, 240, 56)
## Floor satchel by the portal (left of arch feet). Final art 256×192.
const SATCHEL_FLOOR := Rect2(980, 820, 256, 192)
## Mouth rect inside satchel_floor.png (shipped): (32,56)→(224,112).
const SATCHEL_MOUTH := Rect2(32, 56, 192, 56)
const SATCHEL_ICON := 64.0 ## 16 native ×4
## Bottom carried-item strip (9-slice wood trough). Tall enough for 64px icons + margins.
const LOOT_STRIP := Rect2(80, 920, 1520, 104)
const STRIP_MARGINS := Vector4(24, 20, 24, 20) ## L T R B shipped
## Climb hits: full ladder column + floor rope coil (same Climb handler).
const LADDER_HIT := Rect2(721, 0, 200, 920)
const ROPE_COIL_HIT := Rect2(620, 820, 160, 140)
const HOT_MOD := Color(1.12, 1.1, 0.95, 1.0)
const HOT_IDLE := Color(1, 1, 1, 1)
const LADDER_IDLE_FPS := 1000.0 / 220.0
const LADDER_HOT_FPS := 1000.0 / 110.0
const WIPE_COLOR := Color("080605")
const NATIVE_ICON := 64.0
const STRIP_GAP := 16.0
const UNIQUE_STAR := Vector2(40, 40)


func setup(p_cabin, p_extra: Dictionary) -> void:
	cabin = p_cabin
	extra = p_extra
	_lay = KIT.load_layout(LAYOUT_PATH)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 80
	visible = false
	var bg := TextureRect.new()
	bg.name = "CavernBg"
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	# Crypt Classic cavern plate is exact 1680×1040. Fall back to legacy cozy BG if missing.
	bg.texture = KIT.load_tex("overlays/rope_exit_cavern_bg.png")
	if bg.texture == null:
		bg.texture = KIT.load_tex("overlays/rope_exit_bg.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_build_cavern_props()
	_build_tally_wall()
	var torch := KIT.anim_sprite(
		["overlays/torch_flame_f0.png", "overlays/torch_flame_f1.png", "overlays/torch_flame_f2.png"],
		"t", 1000.0 / 120.0, true, Vector2(384, 92)
	)
	torch.visible = _legacy_decor_visible
	add_child(torch)
	if _legacy_decor_visible and torch.sprite_frames:
		torch.play("t")
	# Tip rope_ladder_f* already reads as rope (160×904). Plant in screen space
	# centered on the Crypt Classic skylight — do not use cozy native×4 origin.
	var ladder_r := _layout_rect("Ladder", LADDER_PLATE)
	_ladder = AnimatedSprite2D.new()
	_ladder.name = "RopeLadder"
	_ladder.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ladder.centered = false
	_ladder.position = ladder_r.position
	_ladder.z_index = 3
	_ladder.sprite_frames = KIT.frames(
		["overlays/rope_ladder_f0.png", "overlays/rope_ladder_f1.png", "overlays/rope_ladder_f2.png", "overlays/rope_ladder_f1.png"],
		"l",
		LADDER_IDLE_FPS,
		true
	)
	_ladder_rest = ladder_r.position
	_ladder.visible = true
	add_child(_ladder)
	if _ladder.sprite_frames and _ladder.sprite_frames.get_frame_count("l") > 0:
		_ladder.play("l")
	_ladder_hover = TextureRect.new()
	_ladder_hover.name = "RopeLadderHover"
	_ladder_hover.texture = KIT.load_tex("overlays/rope_ladder_hover.png")
	_ladder_hover.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ladder_hover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ladder_hover.stretch_mode = TextureRect.STRETCH_SCALE
	_ladder_hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ladder_hover.position = ladder_r.position
	_ladder_hover.size = ladder_r.size
	_ladder_hover.z_index = 3
	_ladder_hover.visible = false
	add_child(_ladder_hover)
	_build_climb_wipe()
	_hole = KIT.tex_rect("overlays/deeper_hole_idle.png", Vector2(250, 214), Vector2(96, 40), 3)
	_hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hole.visible = _legacy_decor_visible
	add_child(_hole)
	_hole_glow = KIT.anim_sprite(
		["overlays/deeper_hole_glow_f0.png", "overlays/deeper_hole_glow_f1.png"],
		"g", 1000.0 / 500.0, true, Vector2(250, 214)
	)
	_hole_glow.z_index = 2
	_hole_glow.visible = false
	add_child(_hole_glow)
	if _legacy_decor_visible and _hole_glow.sprite_frames and _hole_glow.sprite_frames.get_frame_count("g") > 0:
		_hole_glow.visible = true
		_hole_glow.play("g")
	_hero = _make_sprout()
	add_child(_hero)
	_nib = Sprite2D.new()
	_nib.name = "PushNib"
	_nib.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_nib.centered = false
	_nib.position = KIT.pt(282, 168)
	_nib.texture = KIT.load_tex("nib/nib_gasp.png")
	_nib.z_index = 6
	_nib.visible = false
	_nib.modulate.a = 0.0
	add_child(_nib)
	_loot_host = Control.new()
	_loot_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loot_host.z_index = 12
	add_child(_loot_host)
	_build_chrome()
	_build_hover_tip()
	_build_hotspots()
	_dialog = preload("res://scripts/cabin/cabin_dialog.gd").new()
	_dialog.setup(cabin)
	_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	_dialog.z_index = 90
	add_child(_dialog)
	_haul_pointers = HaulPointers.new()
	_haul_pointers.name = "HaulPointers"
	add_child(_haul_pointers)


## Layer order (bottom → top under chrome): cavern BG, hatch (hidden shaft cap),
## portal stack, GateFrame (posts/lintel clip the swirl), tallies, rope ladder.
## Painterly chains / gate_open clash with Crypt Classic — keep files, hide.
func _build_cavern_props() -> void:
	var hatch_rect := _layout_rect("Hatch", HATCH_PLATE)
	var gate_rect := _layout_rect("GateFrame", GATE_PLATE)
	var aperture := _layout_rect("GateAperture", GATE_APERTURE)
	var floor_shadow := _layout_rect("GateFloorShadow", GATE_FLOOR_SHADOW)
	# Hatch PNG kept for shaft math / later reuse; hidden so the rope ladder
	# reads as Climb through the open skylight (Climb C lock 2026-11-03).
	_hatch = _plate_rect(
		"overlays/rope_exit_hatch.png",
		hatch_rect,
		1,
		"HomeHatch"
	)
	_hatch.visible = false
	add_child(_hatch)
	# Portal BEFORE GateFrame so wood posts/lintel draw on top and clip the spiral.
	_gate_portal = GATE_PORTAL_SCR.new()
	_gate_portal.name = "GatePortal"
	_gate_portal.z_index = 0
	add_child(_gate_portal)
	_gate_portal.configure(aperture, floor_shadow)
	_gate_portal.set_next_biome("")
	if _gate_portal.has_method("set_alive"):
		_gate_portal.set_alive(false)
	# Gate frame PNG is 384×512; posts floor-planted (option A — was mid-air at y 180).
	# z=1 (above portal z=0) so the arch alpha-masks void + particles.
	_gate_frame = _plate_rect(
		"overlays/rope_exit_gate_frame.png",
		gate_rect,
		1,
		"GateFrame"
	)
	add_child(_gate_frame)
	_build_arch_lights(gate_rect)
	_gate_open = _plate_rect(
		"overlays/rope_exit_gate_open.png",
		gate_rect,
		1,
		"GateOpen"
	)
	_gate_open.visible = false
	add_child(_gate_open)
	_gate_chains = _plate_rect(
		"overlays/rope_exit_chains.png",
		Rect2(gate_rect.position.x + 36.0, gate_rect.position.y + 72.0, gate_rect.size.x - 72.0, gate_rect.size.x - 72.0),
		2,
		"GateChains"
	)
	# Painterly chains stay on disk for a later redraw; hide for Crypt Classic v1.
	_gate_chains.visible = false
	add_child(_gate_chains)
	_socket_filled_tex = KIT.load_tex("overlays/rope_exit_socket_filled.png")
	_apply_gate_locked(true)


func _layout_rect(el_id: String, fallback: Rect2) -> Rect2:
	var el: Dictionary = KIT.layout_el(_lay, el_id)
	var r: Rect2 = KIT.rect_px(el.get("rect", []))
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return fallback
	return r


func _plate_rect(rel: String, r: Rect2, z: int, node_name: String) -> TextureRect:
	var tr := TextureRect.new()
	tr.name = node_name
	tr.texture = KIT.load_tex(rel)
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.position = r.position
	tr.size = r.size
	tr.z_index = z
	return tr


func _build_climb_wipe() -> void:
	_climb_wipe = ColorRect.new()
	_climb_wipe.name = "ClimbWipe"
	_climb_wipe.color = WIPE_COLOR
	_climb_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_climb_wipe.z_index = 100
	_climb_wipe.visible = false
	_climb_wipe.process_mode = Node.PROCESS_MODE_ALWAYS
	_climb_wipe.position = Vector2(0, KIT.ROOM_H)
	_climb_wipe.size = Vector2(KIT.ROOM_W, KIT.ROOM_H)
	add_child(_climb_wipe)


func _reset_climb_wipe() -> void:
	if _climb_wipe == null:
		return
	_climb_wipe.visible = false
	_climb_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_climb_wipe.modulate = Color(1, 1, 1, 1)
	_climb_wipe.position = Vector2(0, KIT.ROOM_H)
	_climb_wipe.size = Vector2(KIT.ROOM_W, KIT.ROOM_H)


## Visual-only for now. No unlock flag / socket gameplay in this PR.
## Crypt Classic: frame alone; chains / open plate stay hidden even when "locked".
func _apply_gate_locked(_locked: bool) -> void:
	if _gate_frame:
		_gate_frame.visible = true
	if _gate_chains:
		_gate_chains.visible = false
	if _gate_open:
		_gate_open.visible = false


## Five arch lanterns along the wooden lintel — count placed uniques (0..5).
func _build_arch_lights(gate_rect: Rect2) -> void:
	_arch_lights.clear()
	var host := Control.new()
	host.name = "ArchLights"
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.z_index = 2
	add_child(host)
	var light_w := 32.0
	var light_h := 48.0
	var gap := 12.0
	var total_w := 5.0 * light_w + 4.0 * gap
	var x0 := gate_rect.position.x + (gate_rect.size.x - total_w) * 0.5
	## Lintel: gate plate y + ~8 shipped.
	var y0 := gate_rect.position.y + 8.0
	for k in 5:
		var lr := Rect2(x0 + float(k) * (light_w + gap), y0, light_w, light_h)
		var light := TextureRect.new()
		light.name = "ArchLight%d" % k
		light.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		light.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		light.stretch_mode = TextureRect.STRETCH_SCALE
		light.mouse_filter = Control.MOUSE_FILTER_IGNORE
		light.position = lr.position
		light.size = lr.size
		var tex: Texture2D = KIT.load_tex("overlays/arch_light_off.png")
		if tex != null:
			light.texture = tex
		else:
			light.modulate = Color("2b1a12")
		host.add_child(light)
		_arch_lights.append(light)
	_set_arch_lights(0)


func _set_arch_lights(lit: int) -> void:
	_arch_lights_lit = clampi(lit, 0, 5)
	for i in _arch_lights.size():
		var node: Control = _arch_lights[i]
		var on: bool = i < _arch_lights_lit
		var tex: Texture2D = KIT.load_tex(
			"overlays/arch_light_on.png" if on else "overlays/arch_light_off.png"
		)
		if node is TextureRect and tex != null:
			(node as TextureRect).texture = tex
			(node as TextureRect).modulate = Color.WHITE
		elif node is TextureRect:
			(node as TextureRect).modulate = Color("ffd84a") if on else Color("2b1a12")


func _build_tally_wall() -> void:
	_tally_host = Control.new()
	_tally_host.name = "TallyWall"
	_tally_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tally_host.position = TALLY_ORIGIN
	_tally_host.size = TALLY_SIZE
	_tally_host.z_index = 2
	add_child(_tally_host)
	_tally_bartleby = TextureRect.new()
	_tally_bartleby.name = "BartlebyChalk"
	_tally_bartleby.texture = KIT.load_tex("overlays/tally/tally_bartleby_chalk_4x.png")
	if _tally_bartleby.texture == null:
		_tally_bartleby.texture = KIT.load_tex("overlays/tally/tally_bartleby_chalk.png")
	_tally_bartleby.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tally_bartleby.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tally_bartleby.stretch_mode = TextureRect.STRETCH_SCALE
	_tally_bartleby.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tally_bartleby.position = Vector2.ZERO
	_tally_bartleby.size = TALLY_SIZE
	_tally_bartleby.visible = false
	_tally_host.add_child(_tally_bartleby)
	_refresh_tallies()


## Lifetime clears drive the wall. Clamp 0..50; at >=50 show Bartleby chalk instead of strokes.
func _tally_count() -> int:
	if _tally_debug >= 0:
		return clampi(_tally_debug, 0, TALLY_MAX)
	var life := 0
	if cabin != null:
		life = int(cabin.lifetime_dungeons_cleared)
	return clampi(life, 0, TALLY_MAX)


## Shot / QA: force a display count without mutating the save. Pass -1 to clear.
func set_tally_debug(count: int) -> void:
	_tally_debug = count
	_refresh_tallies()


func _refresh_tallies() -> void:
	if _tally_host == null:
		return
	for c in _tally_host.get_children():
		if c == _tally_bartleby:
			continue
		_tally_host.remove_child(c)
		c.free()
	var count: int = _tally_count()
	if count >= TALLY_MAX:
		if _tally_bartleby:
			_tally_bartleby.visible = true
		return
	if _tally_bartleby:
		_tally_bartleby.visible = false
	if count <= 0:
		return
	var full_groups: int = int(count / 5)
	var rem: int = count % 5
	var group5: Texture2D = KIT.load_tex("overlays/tally/tally_group5.png")
	var sheet: Texture2D = KIT.load_tex("overlays/tally/tally_sheet.png")
	for g in range(full_groups):
		_add_tally_group(g, group5, null, 5)
	if rem > 0 and sheet != null:
		_add_tally_group(full_groups, null, sheet, rem)


func _add_tally_group(g: int, group5: Texture2D, sheet: Texture2D, marks: int) -> void:
	# Spec: ox = 1 + (g % 5) * 11, oy = 4 + (g / 5) * 22 — native px inside the rect.
	var ox: float = 1.0 + float(g % 5) * 11.0
	var oy: float = 4.0 + float(int(g / 5)) * 22.0
	var tr := TextureRect.new()
	tr.name = "TallyG%d" % g
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.position = Vector2(ox, oy) * PX
	tr.size = Vector2(10, 12) * PX
	if marks >= 5 and group5 != null:
		tr.texture = group5
	elif sheet != null and marks >= 1 and marks <= 4:
		var at := AtlasTexture.new()
		at.atlas = sheet
		# tally_sheet.png: 5 frames of 10×12 laid out horizontally; frame n-1 for n marks.
		at.region = Rect2(float(marks - 1) * 10.0, 0.0, 10.0, 12.0)
		tr.texture = at
	else:
		return
	_tally_host.add_child(tr)


## When true, the next open_exit skips the 0.3s alpha tween (dungeon-clear wipe swap).
var open_instant: bool = false


func open_exit(cleared: int, loot: Array = []) -> void:
	_cleared = cleared
	_busy = false
	_interrupt_fired = false
	_interrupt_open = false
	_loot_count = loot.size()
	# apply_exit_mode always follows from Main. Clear campaign chip state so
	# set_chrome_visible cannot flash a prior run's chips (or raw templates).
	_campaign_mode = false
	_chip_biome_name = ""
	_chip_n = 0
	_chip_show_proj = false
	_next_name = ""
	_next_biome_id = ""
	_show_next_carry = false
	if _gate_portal and _gate_portal.has_method("set_next_biome"):
		_gate_portal.set_next_biome("")
	_reset_hero_pose()
	_apply_banner()
	_apply_sub_line()
	set_chrome_visible(true)
	if _peek_btn:
		_peek_btn.visible = false
	_show_loot(loot)
	_refresh_tallies()
	_hide_nib()
	var instant := open_instant
	open_instant = false
	if visible:
		if instant:
			modulate.a = 1.0
		return
	visible = true
	if instant:
		## Zero-latency swap under the black wipe (dungeon-clear resolve).
		modulate.a = 1.0
	else:
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.3)
	KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")


func _make_sprout() -> AnimatedSprite2D:
	var sp := AnimatedSprite2D.new()
	sp.name = "Hero"
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.centered = false
	sp.position = KIT.pt(188, 208)
	sp.scale = Vector2(SPROUT_SCALE, SPROUT_SCALE)
	sp.z_index = 4
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", true)
	sf.set_animation_speed("idle", SPROUT_IDLE_FPS)
	for path in SPROUT_IDLE:
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path)
			if tex:
				sf.add_frame("idle", tex)
	sp.sprite_frames = sf
	_play_sprout_idle(sp)
	return sp


func _play_sprout_idle(sp: AnimatedSprite2D = null) -> void:
	var hero: AnimatedSprite2D = sp if sp != null else _hero
	if hero == null or hero.sprite_frames == null:
		return
	if hero.sprite_frames.get_frame_count("idle") <= 0:
		return
	if hero.sprite_frames.get_animation_speed("idle") != SPROUT_IDLE_FPS:
		hero.sprite_frames.set_animation_speed("idle", SPROUT_IDLE_FPS)
	if not hero.is_playing() or hero.animation != "idle":
		hero.play("idle")


func set_hero_hidden(hidden: bool) -> void:
	## Call AFTER open_exit — open_exit/_reset_hero_pose restores the idle loop and pose.
	if _hero:
		_hero.visible = not hidden


func hero_land_global() -> Vector2:
	## Top-left of the Rope Exit hero (centered=false). Overlay lands here.
	if _hero == null:
		return Vector2.ZERO
	return _hero.get_global_transform_with_canvas().origin


func _reset_hero_pose() -> void:
	if _hero:
		_hero.position = KIT.pt(188, 208)
		_hero.scale = Vector2(SPROUT_SCALE, SPROUT_SCALE)
		_hero.modulate = Color(1, 1, 1, 1)
		_play_sprout_idle()
		_hero.visible = true
	if _ladder:
		_ladder.position = _ladder_rest
		_ladder.modulate = HOT_IDLE
		if _ladder.sprite_frames:
			_ladder.sprite_frames.set_animation_speed("l", LADDER_IDLE_FPS)
			if not _ladder.is_playing():
				_ladder.play("l")
	if _ladder_hover:
		_ladder_hover.visible = false
		_ladder_hover.position = _ladder_rest
		_ladder_hover.modulate = HOT_IDLE
	_kill_climb_hot_tw()
	_reset_climb_wipe()
	if _hatch:
		_hatch.modulate = HOT_IDLE
		_hatch.visible = false
	if _gate_frame:
		_gate_frame.modulate = HOT_IDLE
	if _gate_portal and _gate_portal.has_method("set_hot"):
		_gate_portal.set_hot(false)


func _apply_banner() -> void:
	if _headline == null:
		return
	if _campaign_mode and _chip_biome_name != "":
		_headline.set_copy("extract.banner", {"biome": _chip_biome_name})
	else:
		_headline.set_copy("rope.cleared", {"n": _cleared})


func _apply_sub_line() -> void:
	if _sub == null:
		return
	if _campaign_mode:
		_sub.set_copy("extract.haul", {"n": _loot_count})
	else:
		_sub.set_copy("rope.loot_tip")


func _rank_key(tier: int) -> String:
	var t: int = clampi(tier, 1, 3)
	if t >= 3:
		return "rank.deadly"
	if t == 2:
		return "rank.tough"
	return "rank.weak"


func _rank_color(tier: int) -> Color:
	var t: int = clampi(tier, 1, 3)
	if t >= 3:
		return Color("e8c36a")
	if t == 2:
		return Color("c5cdd8")
	return Color("c08050")


func hide_exit() -> void:
	visible = false
	_hide_exit_tip()
	_clear_loot()
	_hide_nib()
	_kill_climb_hot_tw()
	_reset_climb_wipe()
	_interrupt_open = false
	if _dialog and _dialog.has_method("dismiss"):
		_dialog.dismiss()
	if cabin and cabin.sfx and cabin.sfx.has_method("loop_stop"):
		cabin.sfx.loop_stop(&"amb.rope_creak", 0.3)


func _clear_loot() -> void:
	_loot_tips.clear()
	_hide_haul_pointers()
	_floor_satchel = null
	_loot_strip = null
	if _loot_host == null:
		return
	for c in _loot_host.get_children():
		c.queue_free()


func _show_loot(loot: Array) -> void:
	## Satchel on the floor by the portal (≤3 peeks) + bottom strip of every carried item.
	## No wall grid, no "New unique" text, no rank labels. Gold star for new uniques.
	_clear_loot()
	if _loot_host == null:
		return
	var rows: Array = []
	for row in loot:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if row.get("tex", null) == null and str(row.get("id", "")) == "":
			continue
		rows.append(row)
	_loot_count = rows.size()
	_build_floor_satchel(rows)
	_build_loot_strip(rows)


func _build_floor_satchel(rows: Array) -> void:
	_floor_satchel = Control.new()
	_floor_satchel.name = "FloorSatchel"
	_floor_satchel.position = SATCHEL_FLOOR.position
	_floor_satchel.size = SATCHEL_FLOOR.size
	_floor_satchel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floor_satchel.z_index = 5
	_loot_host.add_child(_floor_satchel)
	var bag := TextureRect.new()
	bag.name = "Bag"
	bag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bag.stretch_mode = TextureRect.STRETCH_SCALE
	bag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bag.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	## Floor satchel only — never the homecoming satchel_* set.
	var bag_tex: Texture2D = KIT.load_tex("overlays/satchel_floor.png")
	if bag_tex != null:
		bag.texture = bag_tex
	else:
		bag.modulate = Color("5c3a22")
	_floor_satchel.add_child(bag)
	## Mouth-shadow fill covers painted placeholders; real icons draw on top.
	var mouth_fill := ColorRect.new()
	mouth_fill.name = "MouthShadow"
	mouth_fill.color = Color(0.20, 0.12, 0.08, 1.0)
	mouth_fill.position = SATCHEL_MOUTH.position
	mouth_fill.size = SATCHEL_MOUTH.size
	mouth_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouth_fill.z_index = 1
	_floor_satchel.add_child(mouth_fill)
	var peek_n: int = mini(3, rows.size())
	var icon_sz := SATCHEL_ICON
	var my1: float = SATCHEL_MOUTH.position.y + SATCHEL_MOUTH.size.y
	for i in peek_n:
		var row: Dictionary = rows[i]
		var tex: Texture2D = row.get("tex", null)
		var peek := TextureRect.new()
		peek.name = "Peek%d" % i
		peek.texture = tex
		peek.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		peek.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		peek.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		peek.mouse_filter = Control.MOUSE_FILTER_IGNORE
		peek.size = Vector2(icon_sz, icon_sz)
		## Lower part sits in the mouth (peek); top clears mouth.y by 8px.
		peek.position = Vector2(
			SATCHEL_MOUTH.position.x + float(i) * icon_sz,
			my1 - icon_sz
		)
		peek.z_index = 2
		_floor_satchel.add_child(peek)
		if bool(row.get("is_new", false)):
			_add_gold_star(peek, Vector2(icon_sz - UNIQUE_STAR.x * 0.55, -UNIQUE_STAR.y * 0.35))


func _build_loot_strip(rows: Array) -> void:
	_loot_strip = Control.new()
	_loot_strip.name = "LootStrip"
	_loot_strip.position = LOOT_STRIP.position
	_loot_strip.size = LOOT_STRIP.size
	_loot_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loot_strip.z_index = 12
	_loot_host.add_child(_loot_strip)
	## Wood trough 9-slice (margins L24 T20 R24 B20 shipped).
	var trough: NinePatchRect = KIT.ui_nine(
		"trophy_board/carried_strip_9",
		int(STRIP_MARGINS.x), int(STRIP_MARGINS.y), int(STRIP_MARGINS.z), int(STRIP_MARGINS.w)
	)
	trough.name = "StripTrough"
	trough.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_loot_strip.add_child(trough)
	var n: int = rows.size()
	if n <= 0:
		return
	var icon := NATIVE_ICON
	var gap := STRIP_GAP
	var total := float(n) * icon + float(maxi(0, n - 1)) * gap
	var x0 := maxf(0.0, (LOOT_STRIP.size.x - total) * 0.5)
	var y0 := maxf(0.0, (LOOT_STRIP.size.y - icon) * 0.5)
	for i in n:
		var row: Dictionary = rows[i]
		var cell := Control.new()
		cell.name = "Strip_%d" % i
		cell.position = Vector2(x0 + float(i) * (icon + gap), y0)
		cell.size = Vector2(icon, icon)
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var spr := TextureRect.new()
		spr.texture = row.get("tex", null)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(spr)
		if bool(row.get("is_new", false)):
			_add_gold_star(cell, Vector2(icon - UNIQUE_STAR.x * 0.55, -UNIQUE_STAR.y * 0.35))
		var cid := str(row.get("id", ""))
		var tip_name := str(row.get("name", cid))
		cell.mouse_entered.connect(_on_loot_icon_hover.bind(cid, tip_name, cell))
		cell.mouse_exited.connect(_on_loot_icon_unhover)
		_loot_strip.add_child(cell)
		_loot_tips.append(cell.position + LOOT_STRIP.position + Vector2(icon * 0.5, icon))


func _add_gold_star(parent: Control, at: Vector2) -> void:
	var star := TextureRect.new()
	star.name = "NewStar"
	star.texture = KIT.ui_tex("trophy_board/unique_star")
	star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	star.stretch_mode = TextureRect.STRETCH_SCALE
	star.position = at
	star.size = UNIQUE_STAR
	star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star.z_index = 2
	if star.texture == null:
		## Fallback only if art missing — never show Tier/ATK.
		var lab := Label.new()
		lab.name = "NewStar"
		lab.text = "*"
		lab.add_theme_font_size_override("font_size", 18)
		lab.add_theme_color_override("font_color", Color("ffd84a"))
		lab.position = at
		lab.size = Vector2(16, 16)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.z_index = 2
		parent.add_child(lab)
		return
	parent.add_child(star)


func _on_loot_icon_hover(card_id: String, tip_name: String, cell: Control) -> void:
	## Prefer the existing cabin/item fly tip when Main is wired; else parchment name.
	if cabin != null and cabin.has_signal("item_hovered") and card_id != "":
		cabin.item_hovered.emit(card_id, cell)
		return
	if tip_name != "":
		_show_exit_tip_plain(tip_name, cell)


func _on_loot_icon_unhover() -> void:
	if cabin != null and cabin.has_signal("item_unhovered"):
		cabin.item_unhovered.emit()
	_hide_exit_tip()


func _show_exit_tip_plain(plain: String, hit: Control) -> void:
	if _hover_tip == null or hit == null:
		return
	_hover_tip.set_plain(plain)
	_hover_tip_hit = hit
	_place_hover_tip(hit)
	_hover_tip.visible = true


func set_chrome_visible(on: bool) -> void:
	for n in _chrome:
		if n:
			n.visible = on
	# Campaign chips are NOT in _chrome — set_chrome_visible used to force them
	# on with the raw `{biome}` / `{n}` templates from construction. Only show
	# after _refresh_chips fills the vars (sack peek close calls this too).
	if on:
		_refresh_chips()
	else:
		if _chip_biome:
			_chip_biome.visible = false
		if _chip_count:
			_chip_count.visible = false
		if _next_carry:
			_next_carry.visible = false


func _on_climb() -> void:
	if _interrupt_open or _busy:
		return
	_do_climb()


func _on_deeper() -> void:
	if _interrupt_open or _busy:
		return
	if _campaign_mode and not _can_push:
		## Dead portal: fizzle + shake. No dialogue, no progress block.
		_fizzle_dead_portal()
		return
	_do_deeper()


func _build_chrome() -> void:
	var band_el: Dictionary = KIT.layout_el(_lay, "TitleBand")
	_title_band = ColorRect.new()
	var band_col := KIT.SCRIM
	band_col.a = 0.6
	_title_band.color = band_col
	_title_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	KIT.apply_rect(_title_band, KIT.rect_px(band_el.get("rect", [0, 32, 1680, 128])), int(band_el.get("z", 5)))
	add_child(_title_band)
	_chrome.append(_title_band)
	var head_el: Dictionary = KIT.layout_el(_lay, "Headline")
	var ht: Dictionary = head_el.get("text", {})
	_headline = KIT.fit_label(
		"rope.cleared",
		KIT.rect_px(head_el.get("rect", [240, 44, 1200, 56])),
		int(ht.get("font_max", 48)),
		int(ht.get("font_min", 28)),
		int(ht.get("max_lines", 2)),
		KIT.TITLE_CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(head_el.get("z", 10))
	)
	add_child(_headline)
	_chrome.append(_headline)
	var sub_el: Dictionary = KIT.layout_el(_lay, "Sub")
	var st: Dictionary = sub_el.get("text", {})
	_sub = KIT.fit_label(
		"rope.sub",
		KIT.rect_px(sub_el.get("rect", [240, 104, 1200, 40])),
		int(st.get("font_max", 32)),
		int(st.get("font_min", 20)),
		int(st.get("max_lines", 2)),
		Color("e2d0b0"),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(sub_el.get("z", 10))
	)
	add_child(_sub)
	_chrome.append(_sub)
	# Empty copy key at build — do not bake `{biome}` / `{n}` templates into the
	# label. Visibility + filled set_copy live only in _refresh_chips (not _chrome).
	_chip_biome = KIT.fit_label(
		"",
		Rect2(1200, 40, 420, 32),
		22,
		14,
		1,
		Color("e2d0b0"),
		HORIZONTAL_ALIGNMENT_RIGHT,
		VERTICAL_ALIGNMENT_CENTER,
		12
	)
	_chip_biome.visible = false
	add_child(_chip_biome)
	_chip_count = KIT.fit_label(
		"",
		Rect2(1200, 72, 420, 36),
		28,
		18,
		1,
		Color("ffd84a"),
		HORIZONTAL_ALIGNMENT_RIGHT,
		VERTICAL_ALIGNMENT_CENTER,
		12
	)
	_chip_count.visible = false
	add_child(_chip_count)
	_next_carry = KIT.fit_label(
		"",
		Rect2(240, 148, 1200, 36),
		24,
		14,
		2,
		Color("e2d0b0"),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		12
	)
	_next_carry.visible = false
	add_child(_next_carry)
	var sign_el: Dictionary = KIT.layout_el(_lay, "Sign")
	var ns: Dictionary = sign_el.get("nine_slice_4x", {"l": 24, "t": 24, "r": 24, "b": 28})
	_sign = KIT.ui_nine(
		"rope/rope_sign_9.png",
		int(ns.get("l", 24)),
		int(ns.get("t", 24)),
		int(ns.get("r", 24)),
		int(ns.get("b", 28))
	)
	KIT.apply_rect(_sign, KIT.rect_px(sign_el.get("rect", [32, 440, 352, 152])), int(sign_el.get("z", 5)))
	add_child(_sign)
	_chrome.append(_sign)
	var sign_lab_el: Dictionary = KIT.layout_child(sign_el, "Sign.Title")
	var slt: Dictionary = sign_lab_el.get("text", {})
	var sign_lab: FitLabelBox = KIT.fit_label(
		"rope.sign",
		KIT.rect_px(sign_lab_el.get("rect", sign_el.get("inner_rect", [60, 468, 296, 92]))),
		int(slt.get("font_max", 32)),
		int(slt.get("font_min", 16)),
		int(slt.get("max_lines", 2)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(sign_lab_el.get("z", 10))
	)
	add_child(sign_lab)
	_chrome.append(sign_lab)
	# Option A: Climb/Delve chrome planks removed. Hotspots on ladder + gate drive exits.
	_peek_btn = null


func _build_hover_tip() -> void:
	# Same parchment look as cabin hover tags / map tip. Title + body as two lines.
	_hover_tip = KIT.fit_label(
		"",
		Rect2(0, 0, 360, 72),
		24,
		16,
		3,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		40
	)
	_hover_tip.show_frame = true
	_hover_tip.frame_texture = KIT.load_tex("ui/tooltip_parchment_9.png")
	_hover_tip.patch_margin_left = 32
	_hover_tip.patch_margin_right = 32
	_hover_tip.patch_margin_top = 16
	_hover_tip.patch_margin_bottom = 16
	_hover_tip.padding = 8
	_hover_tip.grow_to_text = true
	_hover_tip.max_width = 420
	_hover_tip.visible = false
	_hover_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hover_tip)


func _show_exit_tip(title_key: String, body_key: String, vars: Dictionary, hit: Control) -> void:
	if _hover_tip == null or hit == null:
		return
	var title: String = KIT.fill_text(title_key, vars) if vars.size() > 0 else KIT.copy_text(title_key)
	var body: String = KIT.fill_text(body_key, vars) if vars.size() > 0 else KIT.copy_text(body_key)
	if title == "" and body == "":
		return
	var plain: String = title if body == "" else ("%s\n%s" % [title, body] if title != "" else body)
	_hover_tip.set_plain(plain)
	_hover_tip_hit = hit
	_place_hover_tip(hit)
	_hover_tip.visible = true


func _place_hover_tip(hit: Control) -> void:
	if _hover_tip == null or hit == null:
		return
	if _hover_tip.has_method("fit"):
		_hover_tip.fit()
	var g: Rect2 = hit.get_global_rect()
	var tip_sz: Vector2 = _hover_tip.size
	if tip_sz.x <= 1.0 or tip_sz.y <= 1.0:
		tip_sz = Vector2(360, 72)
	var x: float = g.position.x + g.size.x * 0.5 - tip_sz.x * 0.5
	x = clampf(x, 8.0, 1680.0 - tip_sz.x - 8.0)
	var above_y: float = g.position.y - tip_sz.y - 8.0
	var y: float = above_y
	if above_y < 8.0:
		y = g.position.y + g.size.y + 8.0
	_hover_tip.global_position = Vector2(x, y)


func _hide_exit_tip() -> void:
	_hover_tip_hit = null
	if _hover_tip:
		_hover_tip.visible = false


func _build_hotspots() -> void:
	# Climb = rope ladder (skylight shaft) + floor rope coil. Delve = floor gate.
	_hatch_hit = _make_hit(
		"LadderHit",
		_layout_rect("Ladder.Hit", LADDER_HIT),
		int(KIT.layout_el(_lay, "Ladder.Hit").get("z", 2)),
		_set_climb_hot,
		_on_climb
	)
	_make_hit(
		"RopeCoilHit",
		_layout_rect("RopeCoil.Hit", ROPE_COIL_HIT),
		int(KIT.layout_el(_lay, "RopeCoil.Hit").get("z", 2)),
		_set_climb_hot,
		_on_climb
	)
	_gate_hit = _make_hit(
		"GateHit",
		_layout_rect("Gate.Hit", GATE_PLATE),
		int(KIT.layout_el(_lay, "Gate.Hit").get("z", 2)),
		_set_delve_hot,
		_on_deeper
	)


func _make_hit(node_name: String, r: Rect2, z: int, hover: Callable, action: Callable) -> Control:
	var hit := Control.new()
	hit.name = node_name
	KIT.apply_rect(hit, r, z)
	hit.mouse_filter = Control.MOUSE_FILTER_STOP
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.mouse_entered.connect(func() -> void:
		hover.call(true, hit)
	)
	hit.mouse_exited.connect(func() -> void:
		hover.call(false, hit)
	)
	hit.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and not _busy and not _interrupt_open:
			_hide_exit_tip()
			action.call()
	)
	add_child(hit)
	return hit


## campaign chips + banner. push_interrupt: Nib on gate hover when this cabinet is under quota.
## chip: {biome, n, quota, projected, show_proj, next, next_id, show_next}.
## next_id (b1–b5) drives the GatePortal spiral; empty → dim sealed.
## can_push: whether deeper is allowed.
## endless: kept for callers; used to swap Push plank copy (planks removed — option A).
@warning_ignore("unused_parameter")
## In-run extract lesson (Spin). Blocks Leave advance until dismissed.
func say_lesson(keys: Array) -> void:
	if _dialog == null or keys.is_empty():
		return
	var point_haul := false
	for k in keys:
		if str(k) == "nib.lesson.extract_haul":
			point_haul = true
			break
	_dialog.say(keys)
	if point_haul:
		_show_haul_pointers()
	await _dialog.finished
	_hide_haul_pointers()


func _show_haul_pointers() -> void:
	if _haul_pointers == null or _dialog == null or not _dialog.has_method("talk_bar_rect"):
		return
	var bar: Rect2 = _dialog.talk_bar_rect()
	_haul_pointers.show_at(_loot_tips, bar.position.y)


func _hide_haul_pointers() -> void:
	if _haul_pointers:
		_haul_pointers.hide_pointers()


func apply_exit_mode(campaign: bool, can_push: bool, push_interrupt: bool = false, chip: Dictionary = {}, endless: bool = false) -> void:
	_campaign_mode = campaign
	_can_push = (not campaign) or can_push
	## Nib never blocks progress. Keep the flag for tests, but do not fire a blocking interrupt.
	_push_interrupt = false
	_interrupt_fired = false
	_chip_biome_name = str(chip.get("biome", ""))
	_chip_n = int(chip.get("n", 0))
	_chip_quota = int(chip.get("quota", 5))
	_push_block_key = str(chip.get("push_block_key", ""))
	if _push_block_key == "":
		_push_block_key = "nib.push_block.lever" if _chip_n >= _chip_quota else "nib.push_block.1"
	_chip_show_proj = bool(chip.get("show_proj", false))
	_next_name = str(chip.get("next", ""))
	_next_biome_id = str(chip.get("next_id", "")).strip_edges()
	_show_next_carry = bool(chip.get("show_next", false)) and _next_name != ""
	_portal_alive = bool(chip.get("portal_alive", _can_push))
	var lights: int = int(chip.get("lights_lit", _chip_n))
	if _portal_alive:
		lights = 5
	_set_arch_lights(lights)
	if _gate_portal:
		if _gate_portal.has_method("set_next_biome"):
			# Palette for alive swirl; dead portal still learns the next id for later.
			_gate_portal.set_next_biome(_next_biome_id if campaign else "")
		if _gate_portal.has_method("set_alive"):
			_gate_portal.set_alive(campaign and _portal_alive and _next_biome_id != "")
	_apply_banner()
	_apply_sub_line()
	# Climb/Delve planks gone — diegetic ladder + gate hotspots always drive both doors.
	if _gate_hit:
		_gate_hit.visible = true
	if _hatch_hit:
		_hatch_hit.visible = true
	if _hole:
		_hole.visible = _legacy_decor_visible
	if _hole_glow:
		_hole_glow.visible = _legacy_decor_visible and _hole_glow.sprite_frames != null and _hole_glow.sprite_frames.get_frame_count("g") > 0
	_refresh_chips()
	## First visit near a dead portal: Nib comments once, never blocks Climb/Leave.
	if campaign and not _portal_alive and not bool(endless):
		call_deferred("_maybe_dead_portal_comment")
	## Silence unused push_interrupt so callers stay compatible.
	if push_interrupt:
		pass


## Fill campaign chip / next-carry copy with vars, then show. Never show raw `{biome}` / `{n}`.
func _refresh_chips() -> void:
	var show_chip := _campaign_mode and _chip_biome_name != ""
	if _chip_biome:
		if show_chip:
			_chip_biome.set_copy("rope.campaign.chip_biome", {"biome": _chip_biome_name})
		_chip_biome.visible = show_chip
	if _chip_count:
		if show_chip:
			if _chip_show_proj:
				_chip_count.set_copy("extract.case_proj", {"n": _chip_n})
			else:
				_chip_count.set_copy("rope.campaign.chip_count", {"n": _chip_n})
		_chip_count.visible = show_chip
	_refresh_next_carry()


func _refresh_next_carry() -> void:
	if _next_carry == null:
		return
	var show := _campaign_mode and _show_next_carry and _next_name != ""
	if show:
		_next_carry.set_copy("extract.next_carry", {"next": _next_name})
	_next_carry.visible = show


func _set_climb_hot(on: bool, hit: Control = null) -> void:
	if _interrupt_open:
		return
	if _ladder and _ladder.sprite_frames:
		_ladder.sprite_frames.set_animation_speed("l", LADDER_HOT_FPS if on else LADDER_IDLE_FPS)
		_ladder.modulate = HOT_MOD if on else HOT_IDLE
	if _ladder_hover:
		_ladder_hover.visible = on
		_ladder_hover.modulate = HOT_MOD if on else HOT_IDLE
	_set_ladder_sway(on)
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")
		# Spin-locked Climb strings — Ladder.Hit + RopeCoil.Hit share these.
		_show_exit_tip("rope.home", "rope.home.sub", {}, hit)
	elif hit == null or hit == _hover_tip_hit:
		_hide_exit_tip()


func _kill_climb_hot_tw() -> void:
	if _climb_hot_tw and _climb_hot_tw.is_valid():
		_climb_hot_tw.kill()
	_climb_hot_tw = null


func _set_ladder_sway(on: bool) -> void:
	_kill_climb_hot_tw()
	if _ladder == null:
		return
	_ladder.position = _ladder_rest
	if _ladder_hover:
		_ladder_hover.position = _ladder_rest
	if not on:
		return
	# Slight idle sway while hovered — reads as rope, not a rigid prop.
	_climb_hot_tw = create_tween()
	_climb_hot_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_climb_hot_tw.set_loops()
	_climb_hot_tw.tween_property(_ladder, "position:x", _ladder_rest.x + 3.0, 0.18)
	if _ladder_hover:
		_climb_hot_tw.parallel().tween_property(_ladder_hover, "position:x", _ladder_rest.x + 3.0, 0.18)
	_climb_hot_tw.tween_property(_ladder, "position:x", _ladder_rest.x - 3.0, 0.36)
	if _ladder_hover:
		_climb_hot_tw.parallel().tween_property(_ladder_hover, "position:x", _ladder_rest.x - 3.0, 0.36)
	_climb_hot_tw.tween_property(_ladder, "position:x", _ladder_rest.x, 0.18)
	if _ladder_hover:
		_climb_hot_tw.parallel().tween_property(_ladder_hover, "position:x", _ladder_rest.x, 0.18)


func _set_delve_hot(on: bool, hit: Control = null) -> void:
	if _interrupt_open:
		return
	if _legacy_decor_visible:
		_hole.texture = KIT.load_tex("overlays/deeper_hole_hover.png" if on else "overlays/deeper_hole_idle.png")
		if _hole_glow:
			_hole_glow.visible = not on and _hole_glow.sprite_frames != null and _hole_glow.sprite_frames.get_frame_count("g") > 0
			if _hole_glow.visible and not _hole_glow.is_playing():
				_hole_glow.play("g")
	if _gate_frame:
		_gate_frame.modulate = HOT_MOD if on else HOT_IDLE
	## Only heat the swirl when the portal is alive.
	if _gate_portal and _gate_portal.has_method("set_hot") and _portal_alive:
		_gate_portal.set_hot(on)
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		if _portal_alive:
			# Spin-locked Delve strings. {n} = next dungeon = cleared + 1.
			_show_exit_tip("rope.next", "rope.next.sub", {"n": _cleared + 1}, hit)
		else:
			## Dead portal: no delve tip that promises a way through.
			_hide_exit_tip()
	elif hit == null or hit == _hover_tip_hit:
		_hide_exit_tip()


## Dead portal click: dull fizzle + short arch shake. No text. Never blocks.
func _fizzle_dead_portal() -> void:
	var sfx = cabin.sfx if cabin else null
	if sfx != null and sfx.has_method("play_event"):
		## portal.fizzle falls back to cabin.locked sample when mapped.
		if _has_sfx_cue(sfx, "portal.fizzle"):
			sfx.play_event(&"portal.fizzle")
		else:
			sfx.play_event(&"cabin.locked")
	else:
		KIT.cue(sfx, &"cabin.locked")
	_shake_gate(0.2)
	## Observability for selftests.
	set_meta("last_portal_fizzle", true)


func _has_sfx_cue(sfx, id: String) -> bool:
	if sfx == null:
		return false
	if sfx.has_method("has_cue"):
		return bool(sfx.has_cue(StringName(id)))
	var map = sfx.get("_cues") if sfx.get("_cues") != null else null
	if typeof(map) == TYPE_DICTIONARY:
		return (map as Dictionary).has(id)
	return true


func _shake_gate(seconds: float) -> void:
	if _gate_frame == null:
		return
	var reduce := false
	if cabin != null and "reduce_motion" in cabin:
		reduce = bool(cabin.get("reduce_motion"))
	if reduce:
		## Static highlight instead of shake.
		_gate_frame.modulate = Color(0.85, 0.88, 0.95, 1.0)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_interval(seconds / maxf(0.001, Engine.time_scale))
		tw.tween_callback(func() -> void:
			if is_instance_valid(_gate_frame):
				_gate_frame.modulate = HOT_IDLE
		)
		return
	if _gate_shake_tw != null and _gate_shake_tw.is_valid():
		_gate_shake_tw.kill()
	var origin: Vector2 = _gate_frame.position
	_gate_shake_tw = create_tween()
	_gate_shake_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var steps := 4
	var step_s := seconds / float(steps)
	for i in steps:
		var amp: float = 4.0 if i % 2 == 0 else -4.0
		_gate_shake_tw.tween_property(_gate_frame, "position:x", origin.x + amp, step_s / maxf(0.001, Engine.time_scale))
	_gate_shake_tw.tween_property(_gate_frame, "position", origin, 0.01)


## One-time non-blocking Nib comment near a dead portal.
func _maybe_dead_portal_comment() -> void:
	if cabin == null:
		return
	if "portal_cold_said" in cabin and bool(cabin.get("portal_cold_said")):
		return
	if "portal_cold_said" in cabin:
		cabin.portal_cold_said = true
	if cabin.has_method("_save"):
		cabin.call("_save")
	## Comment only — do not open interrupt / push_home / lock Climb.
	if _dialog != null and _dialog.has_method("say"):
		_dialog.say(
			["nib.portal.cold"],
			[],
			{},
			{"nib.portal.cold": "That arch is stone cold. I wonder what it'd take to wake it up."}
		)


func _try_push_interrupt() -> void:
	## Retired: Nib never blocks the portal. Kept as a no-op for older callers/tests.
	return


func _show_nib_interrupt() -> void:
	if _nib:
		_nib.visible = true
		_nib.texture = KIT.load_tex("nib/nib_gasp.png")
		_nib.modulate.a = 0.0
		_nib.position = KIT.pt(282, 188)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(_nib, "modulate:a", 1.0, 0.18)
		tw.parallel().tween_property(_nib, "position:y", KIT.pt(282, 168).y, 0.22)
		tw.tween_callback(func() -> void:
			if _nib:
				_nib.texture = KIT.load_tex("nib/nib_point.png")
		)
	KIT.cue(cabin.sfx if cabin else null, &"speech.nib_gasp")
	if _headline:
		_headline.set_copy("extract.push_block.title")
	if _dialog == null:
		push_home.emit()
		return
	var vars := {
		"biome": _chip_biome_name,
		"n": _chip_n,
	}
	## Package D: at 5 lights with the lever still unpulled, use the lever line.
	_dialog.say([_push_block_key], ["nib.push_block.yes"], vars)
	var ch: int = await _dialog.finished
	if ch == 0 or ch == -1:
		# Only CTA is Yes; treat empty choice close the same.
		if _nib:
			_nib.texture = KIT.load_tex("nib/nib_talk_f0.png")
		push_home.emit()


func _hide_nib() -> void:
	if _nib:
		_nib.visible = false
		_nib.modulate.a = 0.0


func _do_climb() -> void:
	## Climb C lock (2026-11-03): ladder jiggle → Sprout dissolve → wipe UP.
	## No hero_climb_f0/f1 up-shaft loop.
	_busy = true
	_hide_exit_tip()
	_kill_climb_hot_tw()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	if _ladder_hover:
		_ladder_hover.visible = false
	if _ladder:
		_ladder.modulate = HOT_IDLE
		_ladder.position = _ladder_rest
		if _ladder.sprite_frames:
			_ladder.sprite_frames.set_animation_speed("l", LADDER_IDLE_FPS)
	# Hero already stands under the shaft (KIT.pt 188,208). Keep the idle loop.
	if _hero:
		_play_sprout_idle()
	# 1) Short ladder jiggle (rope shake).
	KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")
	if _ladder:
		var jig := create_tween()
		jig.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var rest_x: float = _ladder_rest.x
		jig.tween_property(_ladder, "position:x", rest_x + 8.0, 0.05)
		jig.tween_property(_ladder, "position:x", rest_x - 8.0, 0.05)
		jig.tween_property(_ladder, "position:x", rest_x + 6.0, 0.05)
		jig.tween_property(_ladder, "position:x", rest_x - 6.0, 0.05)
		jig.tween_property(_ladder, "position:x", rest_x, 0.05)
		await jig.finished
	# 2) Dissolve Sprout in place (no climb frames).
	KIT.cue(cabin.sfx if cabin else null, &"cabin.rope_climb")
	if _hero:
		var fade := create_tween()
		fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fade.tween_property(_hero, "modulate:a", 0.0, 0.28)
		await fade.finished
	# 3) Quick vertical wipe UP, then leave.
	if _climb_wipe:
		_climb_wipe.visible = true
		_climb_wipe.mouse_filter = Control.MOUSE_FILTER_STOP
		_climb_wipe.modulate = Color(1, 1, 1, 1)
		_climb_wipe.size = Vector2(KIT.ROOM_W, KIT.ROOM_H)
		_climb_wipe.position = Vector2(0, KIT.ROOM_H)
		var wipe := create_tween()
		wipe.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		wipe.tween_property(_climb_wipe, "position:y", 0.0, 0.32)
		await wipe.finished
	hide_exit()
	climb.emit()


func _do_deeper() -> void:
	if _campaign_mode and not _can_push:
		return
	_busy = true
	_hide_exit_tip()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	# Walk RIGHT into the floor-planted gate. No jump-through-floor / scale-down.
	var gate_r := _layout_rect("GateFrame", GATE_PLATE)
	var walk_y: float = _hero.position.y
	var into_x: float = gate_r.position.x + gate_r.size.x * 0.35
	var past_x: float = gate_r.position.x + gate_r.size.x * 0.85
	var tw := create_tween()
	tw.tween_property(_hero, "position", Vector2(into_x, walk_y), 0.5)
	await tw.finished
	var tw2 := create_tween()
	tw2.tween_property(_hero, "position:x", past_x, 0.45)
	tw2.parallel().tween_property(_hero, "modulate:a", 0.0, 0.45)
	await tw2.finished
	hide_exit()
	deeper.emit()


## Straight arrows from the top of Nib's bar up to each haul icon.
class HaulPointers extends Control:
	var _tips: PackedVector2Array = PackedVector2Array()
	var _bar_top: float = 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		z_index = 96
		visible = false

	func show_at(tips: Array, bar_top: float) -> void:
		_tips = PackedVector2Array()
		for t in tips:
			if typeof(t) == TYPE_VECTOR2:
				_tips.append(t)
		_bar_top = bar_top
		visible = not _tips.is_empty()
		queue_redraw()

	func hide_pointers() -> void:
		visible = false
		_tips = PackedVector2Array()
		queue_redraw()

	func _draw() -> void:
		var ink := Color("100e0c")
		var gold := Color("ffd84a")
		for tip in _tips:
			var x := snappedf(tip.x, 4.0)
			var tip_y := snappedf(tip.y, 4.0)
			var start_y := snappedf(_bar_top, 4.0)
			var head := 20.0
			if start_y <= tip_y + head + 8.0:
				continue
			var shaft_top := tip_y + head
			var start := Vector2(x, start_y)
			var shaft_end := Vector2(x, shaft_top)
			draw_line(start, shaft_end, ink, 16.0, false)
			draw_line(start, shaft_end, gold, 8.0, false)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, tip_y - 4.0),
				Vector2(x - 22.0, shaft_top + 4.0),
				Vector2(x + 22.0, shaft_top + 4.0),
			]), ink)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, tip_y),
				Vector2(x - 14.0, shaft_top),
				Vector2(x + 14.0, shaft_top),
			]), gold)
