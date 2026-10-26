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
var _climb_btn: FitButton
var _deeper_btn: FitButton
var _peek_btn: FitButton
var _deeper_sub: FitLabelBox
var _climb_lab: FitLabelBox
var _climb_sub: FitLabelBox
var _deeper_lab: FitLabelBox
var _hole_hit: Control
var _campaign_mode: bool = false
var _can_push: bool = true
var _push_interrupt: bool = false
var _interrupt_fired: bool = false
var _interrupt_open: bool = false
var _chip_biome: FitLabelBox
var _chip_count: FitLabelBox
var _chip_biome_name: String = ""
var _chip_n: int = 0
var _nib: Sprite2D
var _dialog
var _plank_normal: StyleBox
var _plank_hover: StyleBox
var _busy: bool = false
var _chrome: Array = []
var _loot_host: Control


func setup(p_cabin, p_extra: Dictionary) -> void:
	cabin = p_cabin
	extra = p_extra
	_lay = KIT.load_layout(LAYOUT_PATH)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 80
	visible = false
	_plank_normal = KIT.tex_style("button/btn_plank_normal.png", 16, 16, 16, 20)
	_plank_hover = KIT.tex_style("button/btn_plank_hover.png", 16, 16, 16, 20)
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	bg.texture = KIT.load_tex("overlays/rope_exit_bg.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var torch := KIT.anim_sprite(
		["overlays/torch_flame_f0.png", "overlays/torch_flame_f1.png", "overlays/torch_flame_f2.png"],
		"t", 1000.0 / 120.0, true, Vector2(384, 92)
	)
	add_child(torch)
	if torch.sprite_frames:
		torch.play("t")
	_ladder = KIT.anim_sprite(
		["overlays/rope_ladder_f0.png", "overlays/rope_ladder_f1.png", "overlays/rope_ladder_f2.png", "overlays/rope_ladder_f1.png"],
		"l", 1000.0 / 220.0, true, Vector2(96, 0)
	)
	_ladder.z_index = 3
	add_child(_ladder)
	if _ladder.sprite_frames:
		_ladder.play("l")
	_ladder_hover = KIT.tex_rect("overlays/rope_ladder_hover.png", Vector2(96, 0), Vector2(40, 226), 3)
	_ladder_hover.visible = false
	add_child(_ladder_hover)
	_hole = KIT.tex_rect("overlays/deeper_hole_idle.png", Vector2(250, 214), Vector2(96, 40), 3)
	_hole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hole)
	_hole_glow = KIT.anim_sprite(
		["overlays/deeper_hole_glow_f0.png", "overlays/deeper_hole_glow_f1.png"],
		"g", 1000.0 / 500.0, true, Vector2(250, 214)
	)
	_hole_glow.z_index = 2
	_hole_glow.visible = false
	add_child(_hole_glow)
	if _hole_glow.sprite_frames and _hole_glow.sprite_frames.get_frame_count("g") > 0:
		_hole_glow.visible = true
		_hole_glow.play("g")
	_hero = Sprite2D.new()
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hero.centered = false
	_hero.position = KIT.pt(170, 200)
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
	_build_hotspots()
	_dialog = preload("res://scripts/cabin/cabin_dialog.gd").new()
	_dialog.setup(cabin)
	_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	_dialog.z_index = 90
	add_child(_dialog)


func open_exit(cleared: int, loot: Array = []) -> void:
	_cleared = cleared
	_busy = false
	_interrupt_fired = false
	_interrupt_open = false
	_headline.set_copy("rope.cleared", {"n": cleared})
	if _sub:
		_sub.set_copy("rope.loot_tip")
	if not _campaign_mode and _deeper_sub:
		_deeper_sub.set_copy("rope.deeper_sub", {"n": cleared + 1})
	set_chrome_visible(true)
	if _peek_btn:
		_peek_btn.visible = false
	_show_loot(loot)
	_hide_nib()
	if visible:
		return
	visible = true
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")


func hide_exit() -> void:
	visible = false
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
		var spr := TextureRect.new()
		spr.texture = tex
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.size = Vector2(64, 64)
		spr.pivot_offset = Vector2(32, 32)
		var col: int = i % 6
		var rw: int = int(i / 6)
		spr.position = Vector2(520.0 + float(col) * 72.0, 240.0 + float(rw) * 80.0)
		spr.modulate = Color("fff3d6") if bool(row.get("is_new", false)) else Color("c4a574")
		_loot_host.add_child(spr)
		var tw := create_tween()
		tw.set_loops(4)
		tw.tween_property(spr, "modulate:a", 0.55, 0.45)
		tw.tween_property(spr, "modulate:a", 1.0, 0.45)
		i += 1


func set_chrome_visible(on: bool) -> void:
	for n in _chrome:
		if n:
			n.visible = on


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
	_chip_biome = KIT.fit_label(
		"rope.campaign.chip_biome",
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
	_chrome.append(_chip_biome)
	_chip_count = KIT.fit_label(
		"rope.campaign.chip_count",
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
	_chrome.append(_chip_count)
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
	_climb_btn = _plank_choice("Climb", "rope.climb", "rope.climb_sub", {}, _on_climb)
	_deeper_btn = _plank_choice("Delve", "rope.deeper", "rope.deeper_sub", {"n": 1}, _on_deeper)
	if _deeper_btn:
		_deeper_btn.focus_entered.connect(_on_push_focus)
	_peek_btn = null


func _plank_choice(el_id: String, label_key: String, sub_key: String, vars: Dictionary, action: Callable) -> FitButton:
	var el: Dictionary = KIT.layout_el(_lay, el_id)
	var b: FitButton = KIT.plank(KIT.rect_px(el.get("rect", [])), int(el.get("z", 20)))
	b.pressed.connect(action)
	add_child(b)
	_chrome.append(b)
	var lab_el: Dictionary = KIT.layout_child(el, el_id + ".Label")
	var lt: Dictionary = lab_el.get("text", {})
	var lab: FitLabelBox = KIT.fit_label(
		label_key,
		KIT.rect_px(lab_el.get("rect", [])),
		int(lt.get("font_max", 40)),
		int(lt.get("font_min", 24)),
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(lab_el.get("z", 21))
	)
	add_child(lab)
	_chrome.append(lab)
	var sub_el: Dictionary = KIT.layout_child(el, el_id + ".Consequence")
	var st: Dictionary = sub_el.get("text", {})
	var sub: FitLabelBox = KIT.fit_label(
		sub_key,
		KIT.rect_px(sub_el.get("rect", [])),
		int(st.get("font_max", 28)),
		int(st.get("font_min", 16)),
		int(st.get("max_lines", 2)),
		KIT.WOOD,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(sub_el.get("z", 21))
	)
	if vars.is_empty():
		sub.set_copy(sub_key)
	else:
		sub.set_copy(sub_key, vars)
	add_child(sub)
	_chrome.append(sub)
	if el_id == "Climb":
		_climb_lab = lab
		_climb_sub = sub
	elif el_id == "Delve":
		_deeper_lab = lab
		_deeper_sub = sub
	return b


func _build_hotspots() -> void:
	var lad_el: Dictionary = KIT.layout_el(_lay, "Ladder.Hit")
	var lad := Control.new()
	KIT.apply_rect(lad, KIT.rect_px(lad_el.get("rect", [384, 0, 160, 904])), int(lad_el.get("z", 2)))
	lad.mouse_filter = Control.MOUSE_FILTER_STOP
	lad.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	lad.mouse_entered.connect(func() -> void:
		_set_climb_hot(true)
	)
	lad.mouse_exited.connect(func() -> void:
		_set_climb_hot(false)
	)
	lad.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and not _busy and not _interrupt_open:
			_on_climb()
	)
	add_child(lad)
	var hole_el: Dictionary = KIT.layout_el(_lay, "Hole.Hit")
	var hole_hit := Control.new()
	KIT.apply_rect(hole_hit, KIT.rect_px(hole_el.get("rect", [1000, 856, 384, 160])), int(hole_el.get("z", 2)))
	hole_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	hole_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hole_hit.mouse_entered.connect(func() -> void:
		_set_delve_hot(true)
	)
	hole_hit.mouse_exited.connect(func() -> void:
		_set_delve_hot(false)
	)
	hole_hit.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and not _busy and not _interrupt_open:
			_on_deeper()
	)
	add_child(hole_hit)
	_hole_hit = hole_hit


## campaign: always show Push. push_interrupt: Nib on hover when this cabinet is under quota.
## chip: {biome, n, quota} for the run chip. can_push: whether deeper is allowed.
func apply_exit_mode(campaign: bool, can_push: bool, push_interrupt: bool = false, chip: Dictionary = {}) -> void:
	_campaign_mode = campaign
	_can_push = (not campaign) or can_push
	_push_interrupt = campaign and push_interrupt
	_interrupt_fired = false
	_chip_biome_name = str(chip.get("biome", ""))
	_chip_n = int(chip.get("n", 0))
	if _climb_lab:
		if campaign:
			_climb_lab.set_copy("rope.campaign.bank")
		else:
			_climb_lab.set_copy("rope.climb")
	if _climb_sub:
		if campaign:
			_climb_sub.set_copy("rope.campaign.bank_eyebrow")
		else:
			_climb_sub.set_copy("rope.climb_sub")
	if _deeper_lab:
		if campaign:
			_deeper_lab.set_copy("rope.campaign.push")
		else:
			_deeper_lab.set_copy("rope.deeper")
	if _deeper_sub:
		if campaign:
			_deeper_sub.set_copy("rope.campaign.push_eyebrow")
		elif not campaign:
			_deeper_sub.set_copy("rope.deeper_sub", {"n": _cleared + 1})
	# Campaign always shows Push (even when can_push is false). Challenge also shows both doors.
	for raw_n in [_deeper_btn, _deeper_lab, _deeper_sub, _hole, _hole_hit]:
		var n := raw_n as CanvasItem
		if n:
			n.visible = true
	if _hole_glow:
		_hole_glow.visible = _hole_glow.sprite_frames != null and _hole_glow.sprite_frames.get_frame_count("g") > 0
	var show_chip := campaign and _chip_biome_name != ""
	if _chip_biome:
		_chip_biome.visible = show_chip
		if show_chip:
			_chip_biome.set_copy("rope.campaign.chip_biome", {"biome": _chip_biome_name})
	if _chip_count:
		_chip_count.visible = show_chip
		if show_chip:
			_chip_count.set_copy("rope.campaign.chip_count", {"n": _chip_n})


func _on_push_focus() -> void:
	if _push_interrupt:
		_try_push_interrupt()


func _set_climb_hot(on: bool) -> void:
	if _interrupt_open:
		return
	_ladder_hover.visible = on
	if _ladder.sprite_frames:
		_ladder.sprite_frames.set_animation_speed("l", 1000.0 / (110.0 if on else 220.0))
	if _climb_btn:
		_climb_btn.add_theme_stylebox_override("normal", _plank_hover if on else _plank_normal)
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		KIT.cue(cabin.sfx if cabin else null, &"amb.rope_creak")


func _set_delve_hot(on: bool) -> void:
	if _interrupt_open:
		return
	_hole.texture = KIT.load_tex("overlays/deeper_hole_hover.png" if on else "overlays/deeper_hole_idle.png")
	if _hole_glow:
		_hole_glow.visible = not on and _hole_glow.sprite_frames != null and _hole_glow.sprite_frames.get_frame_count("g") > 0
		if _hole_glow.visible and not _hole_glow.is_playing():
			_hole_glow.play("g")
	if _deeper_btn:
		_deeper_btn.add_theme_stylebox_override("normal", _plank_hover if on else _plank_normal)
	if on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		if _push_interrupt:
			_try_push_interrupt()


func _try_push_interrupt() -> void:
	if not _push_interrupt or _interrupt_fired or _interrupt_open or _busy:
		return
	_interrupt_fired = true
	_interrupt_open = true
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
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	var tw := create_tween()
	tw.tween_property(_hero, "position:x", 100.0 * PX, 0.5)
	await tw.finished
	_hero.texture = KIT.load_tex("hero/hero_climb_f0.png")
	var tw2 := create_tween()
	tw2.tween_property(_hero, "position:y", -40.0 * PX, 1.6)
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
	KIT.cue(cabin.sfx if cabin else null, &"cabin.hole_rumble")
	var tw := create_tween()
	tw.tween_property(_hero, "position", KIT.pt(282, 198), 0.45)
	await tw.finished
	var tw2 := create_tween()
	tw2.tween_property(_hero, "position:y", _hero.position.y - 10.0 * PX, 0.15)
	tw2.tween_property(_hero, "position:y", _hero.position.y + 40.0 * PX, 0.35)
	tw2.parallel().tween_property(_hero, "scale", Vector2(0.6, 0.6), 0.5)
	tw2.parallel().tween_property(_hero, "modulate:a", 0.0, 0.5)
	await tw2.finished
	hide_exit()
	deeper.emit()
