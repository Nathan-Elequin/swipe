extends Control
## Mystery door: silhouette + shiny. Slam open to reveal who owned it.

signal send_pressed
signal refuse_pressed

const COPY := preload("res://scripts/player_copy.gd")
const HOVER_PANEL := preload("res://scripts/hover_panel.gd")

var art
var sfx
var mode: String = "hidden"
var card_id: String = ""
var pack_tier: int = 1
var _idle: Array = []
var _run: Array = []
var _fi: float = 0.0
var _bob: float = 0.0
var _shake: float = 0.0
var _doors: float = 0.55
var _mystery: bool = true
var lock_dock: bool = false
var _dim: ColorRect
var _panel: PanelContainer
var _glow: GlowFrame
var _stamp: TierStamp
var _actor: Control
var _stage: Control
var _cue
var _tier_sub: Label
var _relic_host: CenterContainer
var _item_tag: Label
var _door_title
var _owner_tag: Label
var _rules_box: PanelContainer
var _rules: RichTextLabel
var _hook: Label
var _refuse: Button
var _hint
var _guard
var _btns: HBoxContainer
var _owner_plate
var _pips: HBoxContainer
var _pip_dots: Array = []
const GATE_W := 400.0


func setup(p_art, p_sfx = null) -> void:
	art = p_art
	sfx = p_sfx
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 40
	visible = false
	texture_filter = TEXTURE_FILTER_NEAREST
	_dim = ColorRect.new()
	_dim.color = Color(0.04, 0.02, 0.01, 0.08)
	_dim.set_anchors_preset(PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)
	_glow = GlowFrame.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glow)
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.custom_minimum_size = Vector2(GATE_W, 0)
	_skin_panel(1)
	add_child(_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_panel.add_child(col)
	_cue = FitLabelBox.make()
	_cue.show_frame = false
	_cue.padding = 0
	_cue.max_font_size = 24
	_cue.min_font_size = 16
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.font_color = Color("f0e6d8")
	_cue.set_outline(Color("100e0c"), 6)
	_cue.custom_minimum_size = Vector2(GATE_W - 24, 32)
	col.add_child(_cue)
	_hint = FitLabelBox.make()
	_hint.show_frame = false
	_hint.padding = 0
	_hint.max_font_size = 16
	_hint.min_font_size = 12
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.font_color = Color("c4a574")
	_hint.set_outline(Color("100e0c"), 4)
	_hint.custom_minimum_size = Vector2(GATE_W - 24, 24)
	col.add_child(_hint)
	_guard = FitLabelBox.make()
	_guard.show_frame = false
	_guard.padding = 0
	_guard.max_font_size = 22
	_guard.min_font_size = 16
	_guard.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guard.font_color = Color("e8c36a")
	_guard.set_outline(Color("100e0c"), 6)
	_guard.custom_minimum_size = Vector2(GATE_W - 24, 28)
	_guard.visible = false
	col.add_child(_guard)
	_stamp = TierStamp.new()
	_stamp.custom_minimum_size = Vector2(0, 128)
	_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_stamp)
	_stage = Control.new()
	_stage.custom_minimum_size = Vector2(248, 360)
	_stage.clip_contents = false
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	col.add_child(_stage)
	_relic_host = CenterContainer.new()
	_relic_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_relic_host.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage.add_child(_relic_host)
	_actor = Actor.new()
	_actor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actor.texture_filter = TEXTURE_FILTER_NEAREST
	_actor.visible = false
	_stage.add_child(_actor)
	_door_title = Label.new()
	_door_title.visible = false
	_item_tag = Label.new()
	_item_tag.visible = false
	_owner_tag = Label.new()
	_owner_tag.visible = false
	_tier_sub = Label.new()
	_tier_sub.visible = false
	_hook = Label.new()
	_hook.visible = false
	_rules_box = PanelContainer.new()
	_rules_box.visible = false
	_rules = RichTextLabel.new()
	_rules.visible = false
	_pips = HBoxContainer.new()
	_pips.alignment = BoxContainer.ALIGNMENT_CENTER
	_pips.add_theme_constant_override("separation", 14)
	col.add_child(_pips)
	for _n in range(3):
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(18, 18)
		d.color = Color("c08050")
		d.mouse_filter = Control.MOUSE_FILTER_STOP
		d.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		d.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				if _refuse != null and not _refuse.disabled:
					refuse_pressed.emit()
		)
		_pips.add_child(d)
		_pip_dots.append(d)
	_owner_plate = HOVER_PANEL.new()
	_owner_plate.visible = false
	_owner_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_owner_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(_owner_plate)
	_btns = HBoxContainer.new()
	_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	_btns.add_theme_constant_override("separation", 10)
	col.add_child(_btns)
	_refuse = _kenney(COPY.fill("door.pass", {"n": 3}, "Leave it"), "btn_brown", "btn_brown_down", Color("f0e6d8"))
	_refuse.custom_minimum_size = Vector2(280, 48)
	_refuse.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btns.add_child(_refuse)
	_refuse.pressed.connect(func() -> void: refuse_pressed.emit())
	if art != null and _owner_plate != null and _owner_plate.has_method("apply_skin"):
		_owner_plate.apply_skin(art.ui.get("panel_beige", null))
	set_process(true)


func _wash(tier: int) -> Color:
	if tier >= 3:
		return Color(0.42, 0.06, 0.05, 0.98)
	if tier == 2:
		return Color(0.12, 0.15, 0.22, 0.98)
	return Color(0.32, 0.12, 0.05, 0.98)


func _skin_panel(tier: int) -> void:
	if _panel == null:
		return
	var metal: Color = _metal(tier)
	var sb := StyleBoxFlat.new()
	sb.bg_color = _wash(tier)
	sb.border_color = metal
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(14)
	sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.72)
	sb.shadow_size = 28
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 18
	_panel.add_theme_stylebox_override("panel", sb)


func _kenney(text: String, up_key: String, down_key: String, ink: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", ink)
	b.add_theme_color_override("font_hover_color", ink.lightened(0.15))
	b.add_theme_color_override("font_pressed_color", ink.darkened(0.1))
	b.custom_minimum_size = Vector2(0, 46)
	var up: Texture2D = art.ui.get(up_key, null) if art else null
	var down: Texture2D = art.ui.get(down_key, null) if art else null
	if up != null:
		b.add_theme_stylebox_override("normal", _tex_sb(up))
		b.add_theme_stylebox_override("hover", _tex_sb(up))
		b.add_theme_stylebox_override("focus", _tex_sb(up))
	if down != null:
		b.add_theme_stylebox_override("pressed", _tex_sb(down))
	return b


func _tex_sb(tex: Texture2D) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex
	s.texture_margin_left = 20
	s.texture_margin_right = 20
	s.texture_margin_top = 10
	s.texture_margin_bottom = 12
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 10
	s.content_margin_bottom = 12
	return s


func _metal(tier: int) -> Color:
	if tier >= 3:
		return Color("e8c36a")
	if tier == 2:
		return Color("8a96a8")
	return Color("c08050")


func _show_copy(value_bb: String, body: String) -> void:
	var parts: PackedStringArray = []
	if value_bb.strip_edges() != "":
		parts.append("[center]%s[/center]" % value_bb)
	if body.strip_edges() != "":
		parts.append("[center][color=#3a2a1c]%s[/color][/center]" % body)
	_rules.text = "\n".join(parts)
	var on: bool = parts.size() > 0
	_rules.visible = on
	if _rules_box != null:
		_rules_box.visible = on


func clear_relic() -> void:
	if _relic_host == null:
		return
	for c in _relic_host.get_children():
		_relic_host.remove_child(c)
		c.queue_free()


func mount_relic(card: Control) -> void:
	clear_relic()
	if card == null or _relic_host == null:
		return
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	_relic_host.add_child(card)


func present_mystery(_item: Dictionary, tier: int, _item_tex: Texture2D, passes_left: int, _value_bb: String = "", _body: String = "") -> void:
	card_id = ""
	pack_tier = maxi(1, tier)
	_mystery = true
	_doors = 0.58
	if sfx:
		sfx.play_event(&"draft.mystery")
	_idle.clear()
	_run.clear()
	_fi = 0.0
	_shake = 0.0
	_stamp.tier = pack_tier
	_stamp.loom = true
	_stamp.visible = true
	_stamp.custom_minimum_size = Vector2(0, 128)
	_stamp.queue_redraw()
	_skin_panel(pack_tier)
	_show_guard(pack_tier)
	if _rules_box != null:
		_rules_box.visible = false
	if _hook:
		_hook.visible = false
	if _hint:
		_hint.visible = true
		_hint.text = COPY.text("door.help", "The finer the loot, the fiercer its owner.")
	hide_owner()
	set_passes(passes_left)
	_btns.visible = true
	_pips.visible = true
	if _relic_host:
		_relic_host.visible = true
	if _stage:
		_stage.custom_minimum_size = Vector2(248, 360)
	_actor.visible = false
	_actor.modulate = Color.WHITE
	_actor.scale = Vector2.ONE
	var wash: Color = _wash(pack_tier)
	_dim.color = Color(wash.r, wash.g, wash.b, 0.34)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	lock_dock = false
	mode = "ask"
	visible = true
	_write_cue(passes_left, false)
	_panel.pivot_offset = Vector2(GATE_W * 0.5, 40)
	_panel.scale = Vector2(0.88, 0.88)
	_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_panel, "scale", Vector2.ONE, 0.28)
	tw.parallel().tween_property(_panel, "modulate:a", 1.0, 0.16)
	_sync_actor()


func _show_guard(tier: int) -> void:
	if _guard == null:
		return
	var name: String = COPY.tier_name(tier)
	_guard.text = COPY.fill("door.guard", {"tier": name}, "Guarded by a %s monster" % name)
	_guard.add_theme_color_override("font_color", _metal(tier).lightened(0.15))
	_guard.visible = true


func _write_cue(passes_left: int, seating: bool) -> void:
	if _cue == null:
		return
	_cue.visible = true
	if seating:
		_cue.text = COPY.text("cue.seat", "A monster approaches. Select their location.")
	elif passes_left <= 0:
		_cue.text = COPY.text("cue.steal", "Out of time")
	else:
		_cue.text = COPY.text("cue.ask", "Take it or leave it?")


func set_passes(n: int) -> void:
	if n <= 0:
		_refuse.text = COPY.text("door.pass_none", "Out of time")
	elif n == 1 and COPY.text("door.pass_one", "").strip_edges() != "":
		_refuse.text = COPY.fill("door.pass_one", {"n": n}, COPY.text("door.pass_one", ""))
	else:
		_refuse.text = COPY.fill("door.pass", {"n": n}, "Leave it")
	_refuse.disabled = n <= 0
	_refuse.modulate.a = 1.0 if n > 0 else 0.38
	if mode == "ask":
		_write_cue(n, false)
	for i in _pip_dots.size():
		var d: ColorRect = _pip_dots[i]
		d.color = _metal(pack_tier) if i < n else Color(0.22, 0.18, 0.14, 0.55)


func reveal(monster: Dictionary, _value_bb: String = "", _speech: String = "", _reminder: String = "") -> void:
	card_id = str(monster.get("card_id", ""))
	_mystery = false
	if _stamp:
		_stamp.loom = false
		_stamp.visible = false
	if _guard:
		_guard.visible = false
	_idle = art.monster_idle(card_id) if art else []
	_run = art.monster_run(card_id) if art else []
	_fi = 0.0
	_doors = 0.0
	if _relic_host:
		_relic_host.visible = false
	_actor.visible = true
	if _stage:
		_stage.custom_minimum_size = Vector2(248, 240)
	if _rules_box != null:
		_rules_box.visible = false
	if _cue:
		_cue.visible = true
		_cue.text = COPY.text("cue.seat", "A monster approaches. Select their location.")
	if _hint:
		_hint.visible = false
	_sync_actor()
	_actor.pivot_offset = _actor.size * 0.5
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(_actor, "scale", Vector2(1.16, 1.16), 0.12)
	tw.tween_property(_actor, "scale", Vector2.ONE, 0.16)


func set_seat() -> void:
	mode = "seat"
	_btns.visible = false
	_pips.visible = false
	if _hook:
		_hook.visible = false
	if _hint:
		_hint.visible = false
	_write_cue(0, true)
	_dim.color.a = 0.0
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE


func hide_gate() -> void:
	mode = "hidden"
	visible = false
	card_id = ""
	lock_dock = false
	_mystery = true
	_doors = 0.58
	_idle.clear()
	_run.clear()
	_btns.visible = true
	_pips.visible = true
	if _hint:
		_hint.visible = false
	if _guard:
		_guard.visible = false
	if _stamp:
		_stamp.loom = false
		_stamp.visible = false
	if _hook:
		_hook.visible = false
	hide_owner()
	_actor.visible = false
	_actor.modulate = Color.WHITE
	if _relic_host:
		_relic_host.visible = true
	if _stage:
		_stage.custom_minimum_size = Vector2(248, 360)
	_panel.scale = Vector2.ONE
	_panel.modulate.a = 1.0
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.set_custom_mouse_cursor(null)
	clear_relic()


func show_owner(title: String, value_line: String, equation: String, body: String, warn: String, look: Dictionary) -> void:
	if _owner_plate == null:
		return
	_owner_plate.visible = true
	_owner_plate.show_rule(title, value_line, equation, body, warn, null, "monster", card_id, look)


func hide_owner() -> void:
	if _owner_plate == null:
		return
	_owner_plate.hide_plate()


func hide_actor() -> void:
	_actor.visible = false


func mouth_global() -> Vector2:
	var r: Rect2 = _actor.get_global_rect()
	return r.position + Vector2(r.size.x * 0.62, r.size.y * 0.38)


func actor_global() -> Vector2:
	var r: Rect2 = _actor.get_global_rect()
	return r.position + r.size * 0.5


func panel_left() -> float:
	return _panel.global_position.x


func gate_rect() -> Rect2:
	if _panel == null or not _panel.is_visible_in_tree():
		return Rect2()
	return _panel.get_global_rect()


func still_tex() -> Texture2D:
	if not _idle.is_empty():
		return _idle[0]
	return null


func dock(wheel: Control) -> void:
	if not visible or lock_dock or wheel == null:
		return
	var wr: Rect2 = wheel.get_global_rect()
	var vp: Vector2 = get_viewport_rect().size
	var available: float = maxf(280.0, vp.x - wr.end.x - 16.0)
	var want_w: float = minf(GATE_W, available)
	var want_h: float = maxf(_panel.get_combined_minimum_size().y, 500.0 if mode == "seat" else 520.0)
	var want := Vector2(want_w, want_h)
	var x: float = wr.end.x + 8.0
	if x + want.x > vp.x - 8.0:
		x = vp.x - want.x - 8.0
	var y: float = wr.position.y + 12.0
	x = clampf(x, 10.0, maxf(10.0, vp.x - want.x - 10.0))
	y = clampf(y, 8.0, maxf(8.0, vp.y - want.y - 12.0))
	_panel.global_position = Vector2(x, y)
	_panel.size = want
	_glow.global_position = Vector2(x - 22.0, y - 22.0)
	_glow.size = want + Vector2(44.0, 44.0)
	_glow.metal = _metal(pack_tier)
	_glow.pulse = 0.40 + 0.60 * absf(sin(_bob * 2.6))
	_glow.queue_redraw()


func play_slam(fast: bool = false) -> void:
	Input.set_custom_mouse_cursor(null)
	_btns.visible = false
	_pips.visible = false
	_actor.visible = true
	_actor.modulate = Color.WHITE
	_doors = 1.0
	_sync_actor()
	var slam := create_tween()
	slam.tween_property(self, "_doors", 1.0, 0.04 if fast else 0.06)
	await slam.finished
	var open := create_tween()
	open.set_trans(Tween.TRANS_BACK)
	open.set_ease(Tween.EASE_OUT)
	open.tween_property(self, "_doors", 0.0, 0.10 if fast else 0.20)
	await open.finished


func play_pass() -> void:
	Input.set_custom_mouse_cursor(null)
	lock_dock = true
	_shake = 1.0
	var tw := create_tween()
	tw.tween_property(self, "_shake", 0.0, 0.22)
	await get_tree().create_timer(0.12).timeout
	var out := create_tween()
	out.set_trans(Tween.TRANS_QUAD)
	out.set_ease(Tween.EASE_IN)
	out.tween_property(_panel, "modulate:a", 0.0, 0.18)
	out.parallel().tween_property(_panel, "position:x", _panel.position.x - 120.0, 0.18)
	await out.finished
	lock_dock = false


func _sync_actor() -> void:
	if _actor == null:
		return
	_actor.mystery = _mystery
	_actor.tier = pack_tier
	_actor.doors = _doors
	_actor.bob = _bob
	_actor.shake = _shake
	if _mystery or _idle.is_empty():
		_actor.tex = null
	else:
		var frames: Array = _run if mode == "seat" and not _run.is_empty() else _idle
		if not frames.is_empty():
			_actor.tex = frames[int(_fi) % frames.size()]
	_actor.queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_fi += delta * 5.5
	_bob += delta
	_stamp.bob = _bob
	_stamp.queue_redraw()
	if _guard != null and _guard.visible:
		var speed: float = 2.0 + float(pack_tier) * 0.9
		var pulse: float = 0.78 + 0.22 * absf(sin(_bob * speed))
		_guard.modulate = Color(1.0, pulse, pulse * (0.55 if pack_tier >= 3 else 0.92), 1.0)
	_sync_actor()
	if _glow != null:
		_glow.metal = _metal(pack_tier)
		_glow.pulse = 0.35 + 0.65 * absf(sin(_bob * 2.6))
		_glow.queue_redraw()


class GlowFrame extends Control:
	var metal: Color = Color("c08050")
	var pulse: float = 0.5

	func _draw() -> void:
		var r := Rect2(Vector2(6, 6), size - Vector2(12, 12))
		var col := Color(metal.r, metal.g, metal.b, 0.10 + pulse * 0.22)
		draw_rect(r.grow(8.0), Color(metal.r, metal.g, metal.b, 0.06 + pulse * 0.10), false, 10.0)
		draw_rect(r, col, false, 4.0 + pulse * 3.0)


class TierStamp extends Control:
	var tier: int = 1
	var bob: float = 0.0
	var loom: bool = false

	func _metal() -> Color:
		if tier >= 3:
			return Color("e8c36a")
		if tier == 2:
			return Color("c5cdd8")
		return Color("c08050")

	func _plate_pts(center: Vector2, rad: float) -> PackedVector2Array:
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

	func _draw() -> void:
		if loom:
			_draw_loom()
			return
		var metal: Color = _metal()
		var pulse: float = 0.55 + 0.45 * absf(sin(bob * 3.0))
		var glow := Color(metal.r, metal.g, metal.b, 0.28 + pulse * 0.50)
		var c := Vector2(size.x * 0.5, size.y * 0.5)
		var plate_r := 28.0 + pulse * 3.2
		draw_circle(c, plate_r + 14.0, glow)
		var fill := Color("241610")
		if tier == 2:
			fill = Color("161018")
		elif tier >= 3:
			fill = Color("100308")
		var pts: PackedVector2Array = _plate_pts(c, plate_r)
		draw_colored_polygon(pts, fill)
		var rim: Color = metal.lerp(metal.lightened(0.5), pulse * 0.6)
		var w: float = 3.0 + pulse * 1.8
		if tier >= 2:
			var ring: PackedVector2Array = pts.duplicate()
			ring.append(pts[0])
			draw_polyline(ring, rim, w, true)
		else:
			draw_arc(c, plate_r, 0.0, TAU, 32, rim, w, true)
		if tier >= 3:
			for i in 5:
				var ang: float = bob * 2.2 + float(i) * TAU / 5.0
				var sp: Vector2 = c + Vector2.from_angle(ang) * (plate_r + 18.0 + sin(bob * 5.0 + float(i)) * 4.0)
				draw_circle(sp, 2.4 + pulse * 1.6, Color(metal.r, metal.g, metal.b, 0.40 + pulse * 0.55))

	func _draw_loom() -> void:
		var metal: Color = _metal()
		var speed: float = 1.6 + float(tier) * 0.85
		var pulse: float = 0.45 + 0.55 * absf(sin(bob * speed))
		var sway: float = sin(bob * speed) * (5.0 + float(tier) * 4.0)
		var breathe: float = 1.0 + sin(bob * speed * 0.65) * (0.03 + float(tier) * 0.025)
		var sc: float = breathe * (0.92 + float(mini(tier, 3) - 1) * 0.16)
		var c := Vector2(size.x * 0.5 + sway, size.y * 0.58)
		var ink := Color(0.04, 0.015, 0.01, 0.98)
		if tier == 2:
			ink = Color(0.02, 0.03, 0.06, 0.98)
		elif tier >= 3:
			ink = Color(0.08, 0.01, 0.01, 0.98)
		var glow := Color(metal.r, metal.g, metal.b, 0.16 + pulse * 0.28)
		draw_circle(Vector2(c.x, c.y - 18.0 * sc), 54.0 * sc, glow)
		var shoulder: float = 70.0 * sc
		if tier == 2:
			shoulder *= 1.15
		elif tier >= 3:
			shoulder *= 1.35
		var body := PackedVector2Array([
			c + Vector2(-shoulder, -8.0 * sc),
			c + Vector2(shoulder, -8.0 * sc),
			c + Vector2(shoulder * 0.72, 52.0 * sc),
			c + Vector2(-shoulder * 0.72, 52.0 * sc),
		])
		draw_colored_polygon(body, ink)
		var arm_drop: float = 28.0 + float(tier) * 16.0
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-shoulder, -4.0),
			c + Vector2(-shoulder + 22.0, -4.0),
			c + Vector2(-shoulder + 10.0, arm_drop),
			c + Vector2(-shoulder - 8.0, arm_drop),
		]), ink)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(shoulder, -4.0),
			c + Vector2(shoulder - 22.0, -4.0),
			c + Vector2(shoulder - 10.0, arm_drop),
			c + Vector2(shoulder + 8.0, arm_drop),
		]), ink)
		var head := c + Vector2(0, -36.0 * sc)
		var head_r: float = 18.0 * sc
		draw_circle(head, head_r, ink)
		draw_colored_polygon(PackedVector2Array([
			head + Vector2(-head_r - 6.0, 0),
			head + Vector2(0, -head_r - 16.0 * sc),
			head + Vector2(head_r + 6.0, 0),
			head + Vector2(head_r * 0.35, 10.0),
			head + Vector2(-head_r * 0.35, 10.0),
		]), ink)
		if tier >= 3:
			draw_colored_polygon(PackedVector2Array([
				head + Vector2(-8, -head_r + 2),
				head + Vector2(-22, -head_r - 22),
				head + Vector2(-2, -head_r - 2),
			]), ink)
			draw_colored_polygon(PackedVector2Array([
				head + Vector2(8, -head_r + 2),
				head + Vector2(22, -head_r - 22),
				head + Vector2(2, -head_r - 2),
			]), ink)
			for i in 5:
				var ang: float = bob * 2.4 + float(i) * TAU / 5.0
				var sp: Vector2 = c + Vector2.from_angle(ang) * (46.0 + sin(bob * 5.0 + float(i)) * 5.0)
				draw_circle(sp, 2.2 + pulse * 1.8, Color(metal.r, metal.g, metal.b, 0.35 + pulse * 0.6))
		var eye: Color = metal.lightened(0.25)
		eye.a = 0.55 + pulse * 0.45
		var er: float = 3.4 + float(tier) * 0.8
		draw_circle(head + Vector2(-7.0 * sc, 1), er, eye)
		draw_circle(head + Vector2(7.0 * sc, 1), er, eye)
		draw_arc(Vector2(c.x, c.y + 8.0), 34.0 * sc, PI * 1.05, PI * 1.95, 18, Color(metal.r, metal.g, metal.b, 0.55 + pulse * 0.4), 3.0 + pulse * 2.0, true)


class Actor extends Control:
	var tex: Texture2D
	var mystery: bool = true
	var tier: int = 1
	var doors: float = 0.55
	var bob: float = 0.0
	var shake: float = 0.0

	func _metal() -> Color:
		if tier >= 3:
			return Color("e8c36a")
		if tier == 2:
			return Color("c5cdd8")
		return Color("c08050")

	func _plate_pts(center: Vector2, rad: float) -> PackedVector2Array:
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

	func _draw() -> void:
		var sz: Vector2 = size
		var jig: float = sin(bob * 48.0) * shake * 5.0
		var bounce: float = sin(bob * 3.2) * 3.0
		var c := Vector2(sz.x * 0.5 + jig, sz.y * 0.56 + bounce)
		var plate_r: float = minf(sz.x, sz.y) * 0.30
		_draw_arch(sz)
		_draw_plate(Vector2(sz.x * 0.5 + jig, sz.y * 0.52 + bounce), plate_r)
		if mystery:
			_draw_silhouette(c, sz)
		elif tex != null:
			var tw: float = float(tex.get_width())
			var th: float = float(tex.get_height())
			var dest := Rect2(Vector2((sz.x - tw) * 0.5 + jig, sz.y - th - 20.0 + bounce), Vector2(tw, th))
			var glow: Color = _metal()
			for ox in [-1, 0, 1]:
				for oy in [-1, 0, 1]:
					if ox == 0 and oy == 0:
						continue
					draw_texture_rect(tex, Rect2(dest.position + Vector2(ox, oy) * 1.5, dest.size), false, glow)
			draw_texture_rect(tex, dest, false)
		_draw_plate_rim(Vector2(sz.x * 0.5 + jig, sz.y * 0.52 + bounce), plate_r)
		_draw_doors(sz)

	func _draw_arch(sz: Vector2) -> void:
		var stone := Color("2a231c")
		draw_rect(Rect2(Vector2(8, 10), Vector2(sz.x - 16, sz.y - 16)), stone)
		draw_rect(Rect2(Vector2(18, 22), Vector2(sz.x - 36, sz.y - 36)), Color("100e0c"))
		draw_arc(Vector2(sz.x * 0.5, 48), sz.x * 0.36, PI, TAU, 18, Color("3a3228"), 6.0, true)

	func _draw_plate(center: Vector2, rad: float) -> void:
		var fill := Color("241610")
		if tier == 2:
			fill = Color("161018")
		elif tier >= 3:
			fill = Color("100308")
		draw_colored_polygon(_plate_pts(center, rad), fill)

	func _draw_plate_rim(center: Vector2, rad: float) -> void:
		var metal: Color = _metal()
		var pulse: float = 0.55 + 0.45 * absf(sin(bob * 3.0))
		var col: Color = metal.lerp(metal.lightened(0.45), pulse * 0.7)
		var w: float = 2.4 + pulse * 1.6
		var pts: PackedVector2Array = _plate_pts(center, rad)
		if tier >= 2:
			pts.append(pts[0])
			draw_polyline(pts, col, w, true)
		else:
			draw_arc(center, rad, 0.0, TAU, 28, col, w, true)
		if tier >= 3:
			for i in 4:
				var ang: float = bob * 2.4 + float(i) * TAU / 4.0
				draw_circle(center + Vector2.from_angle(ang) * (rad + 8.0), 2.0 + pulse, Color(metal.r, metal.g, metal.b, 0.45 + pulse * 0.4))

	func _draw_silhouette(c: Vector2, sz: Vector2) -> void:
		var ink := Color(0.04, 0.03, 0.03, 0.94)
		var scale: float = 0.78 + float(mini(tier, 3)) * 0.08
		var head_r: float = 16.0 * scale
		var head := c + Vector2(0, -38.0 * scale)
		draw_circle(head, head_r, ink)
		var hood := PackedVector2Array([
			head + Vector2(-head_r - 4, -2),
			head + Vector2(0, -head_r - 10),
			head + Vector2(head_r + 4, -2),
			head + Vector2(head_r * 0.4, 8),
			head + Vector2(-head_r * 0.4, 8),
		])
		draw_colored_polygon(hood, ink)
		var body := PackedVector2Array([
			c + Vector2(-28.0 * scale, -12.0 * scale),
			c + Vector2(28.0 * scale, -12.0 * scale),
			c + Vector2(36.0 * scale, 48.0 * scale),
			c + Vector2(-36.0 * scale, 48.0 * scale),
		])
		draw_colored_polygon(body, ink)
		if tier >= 3:
			draw_colored_polygon(PackedVector2Array([
				head + Vector2(-10, -head_r + 2),
				head + Vector2(-18, -head_r - 14),
				head + Vector2(-4, -head_r - 2),
			]), ink)
			draw_colored_polygon(PackedVector2Array([
				head + Vector2(10, -head_r + 2),
				head + Vector2(18, -head_r - 14),
				head + Vector2(4, -head_r - 2),
			]), ink)
		var eye: Color = _metal()
		var glow: float = 0.55 + 0.45 * absf(sin(bob * 2.4))
		eye.a = glow
		var er: float = 3.2 if tier >= 2 else 2.6
		draw_circle(head + Vector2(-6, 1), er, eye)
		draw_circle(head + Vector2(6, 1), er, eye)

	func _draw_doors(sz: Vector2) -> void:
		var t: float = clampf(doors, 0.0, 1.0)
		if t <= 0.02:
			return
		var wood := Color("4a3018")
		var band: Color = _metal()
		var hole := Rect2(Vector2(18, 22), Vector2(sz.x - 36, sz.y - 36))
		var leaf_w: float = hole.size.x * 0.5 * t
		var left := Rect2(hole.position, Vector2(leaf_w, hole.size.y))
		var right := Rect2(Vector2(hole.end.x - leaf_w, hole.position.y), Vector2(leaf_w, hole.size.y))
		draw_rect(left, wood)
		draw_rect(right, wood)
		if leaf_w > 8.0:
			draw_rect(Rect2(left.position + Vector2(leaf_w - 5, 8), Vector2(4, left.size.y - 16)), band)
			draw_rect(Rect2(right.position + Vector2(1, 8), Vector2(4, right.size.y - 16)), band)
