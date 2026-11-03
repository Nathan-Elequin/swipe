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
const PX := 4.0
const LAYOUT_PATH := "res://design/visual/layouts/rope-exit.layout.json"

var cabin
var extra: Dictionary = {}
var _cleared: int = 0
var _lay: Dictionary = {}
var _ladder: AnimatedSprite2D
var _ladder_hover: TextureRect
var _hole: TextureRect
var _hole_glow: AnimatedSprite2D
var _hero: Sprite2D
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
## Crypt Classic cavern plates. Old cozy ladder/hole/torch sprites clash — keep
## nodes for hover/anim hooks, but hide the art. Diegetic hits are hatch + gate.
var _legacy_decor_visible: bool = false
var _gate_frame: TextureRect
var _gate_chains: TextureRect
var _gate_open: TextureRect
var _hatch: TextureRect
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
## Hatch clips into ceiling (negative y intentional). Gate posts on floor (bottom ≈ 891).
const HATCH_PLATE := Rect2(693, -40, 256, 256)
const GATE_PLATE := Rect2(1180, 379, 384, 512)
const HATCH_HIT := Rect2(693, 0, 287, 320)
const ROPE_COIL_HIT := Rect2(620, 820, 160, 140)
const HOT_MOD := Color(1.12, 1.1, 0.95, 1.0)
const HOT_IDLE := Color(1, 1, 1, 1)


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
	_ladder = KIT.anim_sprite(
		["overlays/rope_ladder_f0.png", "overlays/rope_ladder_f1.png", "overlays/rope_ladder_f2.png", "overlays/rope_ladder_f1.png"],
		"l", 1000.0 / 220.0, true, Vector2(96, 0)
	)
	_ladder.z_index = 3
	_ladder.visible = _legacy_decor_visible
	add_child(_ladder)
	if _legacy_decor_visible and _ladder.sprite_frames:
		_ladder.play("l")
	_ladder_hover = KIT.tex_rect("overlays/rope_ladder_hover.png", Vector2(96, 0), Vector2(40, 226), 3)
	_ladder_hover.visible = false
	add_child(_ladder_hover)
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
	_hero = Sprite2D.new()
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hero.centered = false
	# Nudge toward the lit floor center under the shaft (cavern plate).
	_hero.position = KIT.pt(188, 208)
	_hero.texture = KIT.load_tex("hero/hero_idle_loot_f0.png")
	_hero.z_index = 4
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


## Layer order (bottom → top under chrome): cavern BG, hatch (shaft), gate frame,
## tallies. Painterly chains / gate_open clash with Crypt Classic — keep files, hide.
func _build_cavern_props() -> void:
	var hatch_rect := _layout_rect("Hatch", HATCH_PLATE)
	var gate_rect := _layout_rect("GateFrame", GATE_PLATE)
	# Hatch PNG is 256×256 Crypt Classic; sit over the green shaft (top-center).
	_hatch = _plate_rect(
		"overlays/rope_exit_hatch.png",
		hatch_rect,
		1,
		"HomeHatch"
	)
	add_child(_hatch)
	# Gate frame PNG is 384×512; posts floor-planted (option A — was mid-air at y 180).
	_gate_frame = _plate_rect(
		"overlays/rope_exit_gate_frame.png",
		gate_rect,
		1,
		"GateFrame"
	)
	add_child(_gate_frame)
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


## Visual-only for now. No unlock flag / socket gameplay in this PR.
## Crypt Classic: frame alone; chains / open plate stay hidden even when "locked".
func _apply_gate_locked(_locked: bool) -> void:
	if _gate_frame:
		_gate_frame.visible = true
	if _gate_chains:
		_gate_chains.visible = false
	if _gate_open:
		_gate_open.visible = false


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
	_show_next_carry = false
	_reset_hero_pose()
	_apply_banner()
	_apply_sub_line()
	set_chrome_visible(true)
	if _peek_btn:
		_peek_btn.visible = false
	_show_loot(loot)
	_refresh_tallies()
	_hide_nib()
	if visible:
		return
	visible = true
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")


func _reset_hero_pose() -> void:
	if _hero:
		_hero.position = KIT.pt(188, 208)
		_hero.scale = Vector2.ONE
		_hero.modulate = Color(1, 1, 1, 1)
		_hero.texture = KIT.load_tex("hero/hero_idle_loot_f0.png")
	if _hatch:
		_hatch.modulate = HOT_IDLE
	if _gate_frame:
		_gate_frame.modulate = HOT_IDLE


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
	_interrupt_open = false
	if _dialog and _dialog.has_method("dismiss"):
		_dialog.dismiss()
	if cabin and cabin.sfx and cabin.sfx.has_method("loop_stop"):
		cabin.sfx.loop_stop(&"amb.rope_creak", 0.3)


func _clear_loot() -> void:
	if _loot_host == null:
		return
	for c in _loot_host.get_children():
		c.queue_free()


func _show_loot(loot: Array) -> void:
	_clear_loot()
	if _loot_host == null:
		return
	var i: int = 0
	for row in loot:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var tex: Texture2D = row.get("tex", null)
		if tex == null:
			continue
		var col: int = i % 6
		var rw: int = int(i / 6)
		var origin := Vector2(520.0 + float(col) * 72.0, 240.0 + float(rw) * 96.0)
		var is_new: bool = bool(row.get("is_new", false))
		var tier: int = int(row.get("tier", 1))
		var cell := Control.new()
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.position = origin
		cell.size = Vector2(64, 92)
		_loot_host.add_child(cell)
		if is_new:
			var nu: FitLabelBox = KIT.fit_label(
				"extract.new_unique",
				Rect2(origin.x - 12.0, origin.y - 18.0, 88, 16),
				14,
				10,
				1,
				Color("ffd84a"),
				HORIZONTAL_ALIGNMENT_CENTER,
				VERTICAL_ALIGNMENT_CENTER,
				13
			)
			nu.set_outline(Color("100e0c"), 3)
			_loot_host.add_child(nu)
		var spr := TextureRect.new()
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.size = Vector2(64, 64)
		spr.pivot_offset = Vector2(32, 32)
		spr.position = Vector2.ZERO
		spr.modulate = Color("fff3d6") if is_new else Color("c4a574")
		cell.add_child(spr)
		var rank: FitLabelBox = KIT.fit_label(
			_rank_key(tier),
			Rect2(origin.x - 4.0, origin.y + 64.0, 72, 18),
			16,
			11,
			1,
			_rank_color(tier),
			HORIZONTAL_ALIGNMENT_CENTER,
			VERTICAL_ALIGNMENT_CENTER,
			13
		)
		rank.set_outline(Color("100e0c"), 3)
		_loot_host.add_child(rank)
		var tw := create_tween()
		tw.set_loops(4)
		tw.tween_property(spr, "modulate:a", 0.55, 0.45)
		tw.tween_property(spr, "modulate:a", 1.0, 0.45)
		i += 1


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
		_try_push_interrupt()
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
	# Option A: Climb/Delve chrome planks removed. Hotspots on hatch + gate drive exits.
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
	# Climb = hatch/shaft + rope coil (same action). Delve = floor-planted gate.
	_hatch_hit = _make_hit(
		"HatchHit",
		_layout_rect("Hatch.Hit", HATCH_HIT),
		int(KIT.layout_el(_lay, "Hatch.Hit").get("z", 2)),
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
## chip: {biome, n, quota, projected, show_proj, next, show_next}. can_push: whether deeper is allowed.
## endless: kept for callers; used to swap Push plank copy (planks removed — option A).
@warning_ignore("unused_parameter")
func apply_exit_mode(campaign: bool, can_push: bool, push_interrupt: bool = false, chip: Dictionary = {}, endless: bool = false) -> void:
	_campaign_mode = campaign
	_can_push = (not campaign) or can_push
	_push_interrupt = campaign and push_interrupt
	_interrupt_fired = false
	_chip_biome_name = str(chip.get("biome", ""))
	_chip_n = int(chip.get("n", 0))
	_chip_show_proj = bool(chip.get("show_proj", false))
	_next_name = str(chip.get("next", ""))
	_show_next_carry = bool(chip.get("show_next", false)) and _next_name != ""
	_apply_banner()
	_apply_sub_line()
	# Climb/Delve planks gone — diegetic hatch + gate hotspots always drive both doors.
	if _gate_hit:
		_gate_hit.visible = true
	if _hatch_hit:
		_hatch_hit.visible = true
	if _hole:
		_hole.visible = _legacy_decor_visible
	if _hole_glow:
		_hole_glow.visible = _legacy_decor_visible and _hole_glow.sprite_frames != null and _hole_glow.sprite_frames.get_frame_count("g") > 0
	_refresh_chips()


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
	if _legacy_decor_visible:
		_ladder_hover.visible = on
		if _ladder and _ladder.sprite_frames:
			_ladder.sprite_frames.set_animation_speed("l", 1000.0 / (110.0 if on else 220.0))
	if _hatch:
		_hatch.modulate = HOT_MOD if on else HOT_IDLE
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")
		# Spin-locked Climb strings — Hatch.Hit + RopeCoil.Hit share these.
		_show_exit_tip("rope.home", "rope.home.sub", {}, hit)
	elif hit == null or hit == _hover_tip_hit:
		_hide_exit_tip()


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
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		# Spin-locked Delve strings. {n} = next dungeon = cleared + 1.
		_show_exit_tip("rope.next", "rope.next.sub", {"n": _cleared + 1}, hit)
		if _push_interrupt:
			_try_push_interrupt()
	elif hit == null or hit == _hover_tip_hit:
		_hide_exit_tip()


func _try_push_interrupt() -> void:
	if not _push_interrupt or _interrupt_fired or _interrupt_open or _busy:
		return
	_interrupt_fired = true
	_interrupt_open = true
	_hide_exit_tip()
	push_blocked.emit()
	_show_nib_interrupt()


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
	_dialog.say(["nib.push_block.1"], ["nib.push_block.yes"], vars)
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
	_busy = true
	_hide_exit_tip()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	# Center under the shaft, then climb UP into the hatch (option A).
	var hatch_r := _layout_rect("Hatch", HATCH_PLATE)
	var under_x: float = hatch_r.position.x + hatch_r.size.x * 0.5 - 64.0
	var tw := create_tween()
	tw.tween_property(_hero, "position:x", under_x, 0.28)
	await tw.finished
	_hero.texture = KIT.load_tex("hero/hero_climb_f0.png")
	var tw2 := create_tween()
	tw2.tween_property(_hero, "position:y", -160.0, 1.6)
	tw2.parallel().tween_property(_hero, "modulate:a", 0.0, 1.4)
	var t := 0.0
	while t < 1.6:
		await get_tree().create_timer(0.32).timeout
		t += 0.32
		KIT.cue(cabin.sfx if cabin else null, &"cabin.rope_climb")
		_hero.texture = KIT.load_tex("hero/hero_climb_f%d.png" % (int(t / 0.16) % 2))
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
