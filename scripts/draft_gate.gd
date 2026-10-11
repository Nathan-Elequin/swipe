extends VBoxContainer
## Column draft gate: Take / Leave, no dim over the dungeon.

signal send_pressed
signal refuse_pressed

const COPY := preload("res://scripts/player_copy.gd")

const GOLD := Color("FFD84A")
const TORCH := Color("F09A34")
const SOOT := Color("1A120E")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
const VOID := Color("0B0706")
const EDGE := Color("7A4E2B")
const WEAK := Color("B8733A")
const TOUGH := Color("C9CED6")
const DEADLY := Color("FFD84A")
const ATK := Color("D5443B")

var art
var mode: String = "hidden"
var card_id: String = ""
var pack_tier: int = 1
var lock_dock: bool = false
var _idle: Array = []
var _run: Array = []
var _fi: float = 0.0
var _bob: float = 0.0
var _shake: float = 0.0
var _doors: float = 0.55
var _mystery: bool = true
var _cue: Label
var _help: Label
var _owner_lab: Label
var _pill: Label
var _actor: Control
var _bait: PanelContainer
var _shiny_lab: Label
var _item_icon: TextureRect
var _item_name: Label
var _guard_row: HBoxContainer
var _guard_a: Label
var _guard_pill: Label
var _guard_b: Label
var _take: Button
var _refuse: Button
var _pips: HBoxContainer
var _pip_dots: Array = []
var _owner_plate
var _relic_host: CenterContainer
var _nib: TextureRect
var _glow_t: float = 0.0
var _font_px: Font
var _font_vt: Font
var _font_sk: Font
var _item_tex: Texture2D


func setup(p_art) -> void:
	art = p_art
	theme = load("res://themes/swipe_theme.tres")
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	_font_sk = load("res://assets/ui/fonts/Silkscreen-Bold.ttf")
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	visible = false
	_build()
	set_process(true)


func _build() -> void:
	_cue = Label.new()
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_px != null:
		_cue.add_theme_font_override("font", _font_px)
	_cue.add_theme_font_size_override("font_size", 46)
	_cue.add_theme_color_override("font_color", PARCHMENT)
	add_child(_cue)

	_help = Label.new()
	_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_vt != null:
		_help.add_theme_font_override("font", _font_vt)
	_help.add_theme_font_size_override("font_size", 30)
	_help.add_theme_color_override("font_color", TORCH)
	add_child(_help)

	_owner_lab = Label.new()
	_owner_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_vt != null:
		_owner_lab.add_theme_font_override("font", _font_vt)
	_owner_lab.add_theme_font_size_override("font_size", 26)
	_owner_lab.add_theme_color_override("font_color", DIM)
	add_child(_owner_lab)

	_pill = Label.new()
	_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pill.custom_minimum_size = Vector2(88, 28)
	if _font_sk != null:
		_pill.add_theme_font_override("font", _font_sk)
	_pill.add_theme_font_size_override("font_size", 15)
	_pill.add_theme_color_override("font_color", SOOT)
	_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_pill)

	_actor = Control.new()
	_actor.custom_minimum_size = Vector2(300, 230)
	_actor.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actor.draw.connect(_draw_arch)
	add_child(_actor)

	_bait = PanelContainer.new()
	_bait.custom_minimum_size = Vector2(400, 280)
	_bait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bait.gui_input.connect(_on_bait_input)
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color("2A1C10")
	bsb.border_color = GOLD
	bsb.set_border_width_all(8)
	bsb.content_margin_left = 16
	bsb.content_margin_right = 16
	bsb.content_margin_top = 12
	bsb.content_margin_bottom = 12
	_bait.add_theme_stylebox_override("panel", bsb)
	add_child(_bait)
	var bcol := VBoxContainer.new()
	bcol.add_theme_constant_override("separation", 6)
	bcol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bait.add_child(bcol)
	_shiny_lab = Label.new()
	_shiny_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_vt != null:
		_shiny_lab.add_theme_font_override("font", _font_vt)
	_shiny_lab.add_theme_font_size_override("font_size", 26)
	_shiny_lab.add_theme_color_override("font_color", DIM)
	bcol.add_child(_shiny_lab)
	_item_icon = TextureRect.new()
	_item_icon.custom_minimum_size = Vector2(128, 128)
	_item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_item_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bcol.add_child(_item_icon)
	_item_name = Label.new()
	_item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_px != null:
		_item_name.add_theme_font_override("font", _font_px)
	_item_name.add_theme_font_size_override("font_size", 32)
	_item_name.add_theme_color_override("font_color", PARCHMENT)
	bcol.add_child(_item_name)
	_guard_row = HBoxContainer.new()
	_guard_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_guard_row.add_theme_constant_override("separation", 6)
	_guard_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bcol.add_child(_guard_row)
	_guard_a = Label.new()
	if _font_vt != null:
		_guard_a.add_theme_font_override("font", _font_vt)
	_guard_a.add_theme_font_size_override("font_size", 26)
	_guard_a.add_theme_color_override("font_color", DIM)
	_guard_row.add_child(_guard_a)
	_guard_pill = Label.new()
	_guard_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guard_pill.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_sk != null:
		_guard_pill.add_theme_font_override("font", _font_sk)
	_guard_pill.add_theme_font_size_override("font_size", 15)
	_guard_pill.add_theme_color_override("font_color", SOOT)
	_guard_row.add_child(_guard_pill)
	_guard_b = Label.new()
	if _font_vt != null:
		_guard_b.add_theme_font_override("font", _font_vt)
	_guard_b.add_theme_font_size_override("font_size", 26)
	_guard_b.add_theme_color_override("font_color", DIM)
	_guard_row.add_child(_guard_b)

	_relic_host = CenterContainer.new()
	_relic_host.visible = false
	_relic_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_relic_host)

	var plate_scn: PackedScene = load("res://scenes/ui/owner_plate.tscn")
	if plate_scn != null:
		_owner_plate = plate_scn.instantiate()
		_owner_plate.visible = false
		add_child(_owner_plate)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spacer)

	_take = Button.new()
	_take.custom_minimum_size = Vector2(0, 84)
	_take.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_take.theme_type_variation = "ButtonGold"
	_take.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		_take.add_theme_font_override("font", _font_px)
	_take.add_theme_font_size_override("font_size", 40)
	_take.add_theme_color_override("font_color", SOOT)
	_take.pressed.connect(func() -> void: send_pressed.emit())
	add_child(_take)

	_refuse = Button.new()
	_refuse.custom_minimum_size = Vector2(0, 60)
	_refuse.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refuse.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_vt != null:
		_refuse.add_theme_font_override("font", _font_vt)
	_refuse.add_theme_font_size_override("font_size", 30)
	_refuse.add_theme_color_override("font_color", GOLD)
	var leave_n := StyleBoxFlat.new()
	leave_n.bg_color = Color(0, 0, 0, 0)
	leave_n.border_color = GOLD
	leave_n.set_border_width_all(4)
	leave_n.content_margin_top = 10
	leave_n.content_margin_bottom = 10
	_refuse.add_theme_stylebox_override("normal", leave_n)
	var leave_h := leave_n.duplicate()
	leave_h.bg_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.12)
	_refuse.add_theme_stylebox_override("hover", leave_h)
	_refuse.add_theme_stylebox_override("pressed", leave_h)
	_refuse.pressed.connect(func() -> void: refuse_pressed.emit())
	add_child(_refuse)

	_pips = HBoxContainer.new()
	_pips.alignment = BoxContainer.ALIGNMENT_CENTER
	_pips.add_theme_constant_override("separation", 10)
	add_child(_pips)
	for _n in range(3):
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(34, 12)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pips.add_child(d)
		_pip_dots.append(d)

	_nib = TextureRect.new()
	_nib.top_level = true
	_nib.position = Vector2(24, 900)
	_nib.size = Vector2(80, 80)
	_nib.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_nib.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_nib.texture_filter = TEXTURE_FILTER_NEAREST
	_nib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_nib.z_index = 8
	if art != null and art.has_method("nib_portrait"):
		_nib.texture = art.nib_portrait()
	add_child(_nib)


func present_mystery(item: Dictionary, tier: int, item_tex: Texture2D, passes_left: int, _value_bb: String = "", _body: String = "") -> void:
	card_id = ""
	pack_tier = maxi(1, tier)
	_mystery = true
	_doors = 0.0
	_idle.clear()
	_run.clear()
	_fi = 0.0
	_shake = 0.0
	_item_tex = item_tex
	lock_dock = false
	mode = "ask"
	visible = true
	if _nib:
		_nib.visible = true
	_cue.text = COPY.need("cue.ask")
	_help.text = COPY.need("door.help")
	_help.visible = true
	_owner_lab.text = COPY.need("door.owner")
	_owner_lab.visible = true
	_pill.text = COPY.tier_name(pack_tier)
	_style_pill(_pill, pack_tier)
	_pill.visible = true
	_actor.visible = true
	_bait.visible = true
	_shiny_lab.text = COPY.need("door.shiny")
	_item_icon.texture = item_tex
	_item_name.text = str(item.get("name", ""))
	_write_guard(pack_tier)
	_take.visible = true
	_take.text = COPY.need("door.take")
	_pips.visible = true
	hide_owner()
	set_passes(passes_left)
	modulate.a = 1.0
	pivot_offset = Vector2(size.x * 0.5, 40)
	scale = Vector2(0.92, 0.92)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.28)
	_actor.queue_redraw()


func _write_guard(tier: int) -> void:
	var tname: String = COPY.tier_name(tier)
	var filled: String = COPY.fill("door.guard", {"tier": tname}, COPY.need("door.guard"))
	var parts: PackedStringArray = filled.split(tname, true, 1)
	if parts.size() >= 2:
		_guard_a.text = parts[0]
		_guard_pill.text = tname
		_guard_b.text = parts[1]
		_style_pill(_guard_pill, tier)
		_guard_pill.visible = true
		_guard_b.visible = true
	else:
		_guard_a.text = filled
		_guard_pill.visible = false
		_guard_b.visible = false


func _style_pill(lab: Label, tier: int) -> void:
	var col: Color = WEAK
	if tier >= 3:
		col = DEADLY
	elif tier == 2:
		col = TOUGH
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.border_color = SOOT
	sb.set_border_width_all(3)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	lab.add_theme_stylebox_override("normal", sb)


func set_passes(n: int) -> void:
	if _refuse == null:
		return
	if n <= 0:
		_refuse.text = COPY.text("door.pass_none", "No passes left")
	elif n == 1:
		_refuse.text = COPY.text("door.pass_one", "Leave it (1 pass left)")
	else:
		_refuse.text = COPY.fill("door.pass", {"n": n}, "Leave it (%s passes left)" % n)
	_refuse.disabled = n <= 0
	_refuse.modulate.a = 1.0 if n > 0 else 0.38
	if mode == "ask" and _cue:
		if n <= 0:
			_cue.text = COPY.text("cue.steal", "No passes left")
		else:
			_cue.text = COPY.need("cue.ask")
	for i in _pip_dots.size():
		var d: ColorRect = _pip_dots[i]
		d.color = TORCH if i < n else Color(EDGE.r, EDGE.g, EDGE.b, 0.35)


func reveal(monster: Dictionary, _value_bb: String = "", _speech: String = "", _reminder: String = "") -> void:
	card_id = str(monster.get("card_id", ""))
	_mystery = false
	_idle = art.monster_idle(card_id) if art else []
	_run = art.monster_run(card_id) if art else []
	_fi = 0.0
	_doors = 0.0
	_cue.text = COPY.need("cue.seat")
	_help.visible = false
	_bait.visible = false
	_take.visible = false
	_refuse.visible = false
	_pips.visible = false
	_actor.visible = true
	_actor.queue_redraw()


func set_seat() -> void:
	mode = "seat"
	_take.visible = false
	_refuse.visible = false
	_pips.visible = false
	_help.visible = false
	_bait.visible = false
	if _cue:
		_cue.text = COPY.text("cue.seat", "A monster approaches. Select their location.")


func leave_btn() -> Control:
	return _refuse


func relic_host() -> Control:
	return _item_icon if _item_icon != null else _relic_host


func hide_gate() -> void:
	mode = "hidden"
	visible = false
	card_id = ""
	lock_dock = false
	_mystery = true
	_doors = 0.58
	_idle.clear()
	_run.clear()
	hide_owner()
	if _nib:
		_nib.visible = false
	clear_relic()
	scale = Vector2.ONE
	modulate.a = 1.0


func show_owner(title: String, value_line: String, equation: String, body: String, warn: String, look: Dictionary) -> void:
	if _owner_plate == null:
		return
	_owner_plate.visible = true
	if _owner_plate.has_method("show_monster"):
		var tex: Texture2D = still_tex()
		var m := {
			"name": title,
			"ability": body,
			"atk": int(look.get("atk", 0)),
			"hp": int(look.get("hp", 0)),
			"pack_tier": pack_tier,
			"card_id": card_id,
		}
		_owner_plate.show_monster(m, tex)
	elif _owner_plate.has_method("show_rule"):
		_owner_plate.show_rule(title, value_line, equation, body, warn, null, "monster", card_id, look)


func hide_owner() -> void:
	if _owner_plate:
		_owner_plate.visible = false
		if _owner_plate.has_method("hide_plate"):
			_owner_plate.hide_plate()


func hide_actor() -> void:
	if _actor:
		_actor.visible = false


func mouth_global() -> Vector2:
	if _actor == null:
		return Vector2(1236, 190)
	return _actor.global_position + Vector2(_actor.size.x * 0.5, _actor.size.y - 8.0)


func actor_global() -> Vector2:
	if _actor == null:
		return Vector2.ZERO
	return _actor.global_position + _actor.size * 0.5


func panel_left() -> float:
	return global_position.x


func still_tex() -> Texture2D:
	if not _idle.is_empty():
		return _idle[0]
	return null


func dock(_wheel: Control) -> void:
	if _nib:
		_nib.global_position = Vector2(24, 900)


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
	card.visible = false
	if card.has_method("get") == false:
		pass
	if _item_icon and _item_tex == null and card.get("texture") != null:
		pass


func play_slam(fast: bool = false) -> void:
	_take.visible = false
	_refuse.visible = false
	_pips.visible = false
	_doors = 1.0
	if _actor:
		_actor.queue_redraw()
	var slam := create_tween()
	slam.tween_property(self, "_doors", 1.0, 0.04 if fast else 0.06)
	await slam.finished
	var hit := create_tween()
	hit.tween_property(self, "position:x", position.x + 6.0, 0.04)
	hit.tween_property(self, "position:x", position.x - 6.0, 0.04)
	hit.tween_property(self, "position:x", position.x, 0.04)
	var open := create_tween()
	open.set_trans(Tween.TRANS_BACK)
	open.set_ease(Tween.EASE_OUT)
	open.tween_property(self, "_doors", 0.0, 0.16 if fast else 0.32)
	await open.finished


func play_pass() -> void:
	lock_dock = true
	_shake = 1.0
	var tw := create_tween()
	tw.tween_property(self, "_shake", 0.0, 0.22)
	await get_tree().create_timer(0.12).timeout
	var out := create_tween()
	out.set_trans(Tween.TRANS_QUAD)
	out.set_ease(Tween.EASE_IN)
	out.tween_property(self, "modulate:a", 0.0, 0.18)
	await out.finished
	lock_dock = false


func _on_bait_input(ev: InputEvent) -> void:
	if mode != "ask":
		return
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		send_pressed.emit()


func _metal() -> Color:
	if pack_tier >= 3:
		return DEADLY
	if pack_tier == 2:
		return TOUGH
	return WEAK


func _draw_arch() -> void:
	if _actor == null:
		return
	var sz: Vector2 = _actor.size
	var jig: float = sin(_bob * 48.0) * _shake * 5.0
	var c := Vector2(sz.x * 0.5 + jig, sz.y)
	var rad: float = sz.x * 0.5
	var pts := PackedVector2Array()
	pts.append(Vector2(0, sz.y))
	for k in 16:
		var a: float = PI + float(k) / 16.0 * PI
		pts.append(Vector2(c.x + cos(a) * rad, c.y + sin(a) * rad))
	pts.append(Vector2(sz.x, sz.y))
	_actor.draw_colored_polygon(pts, Color("241610"))
	for k in 16:
		var a0: float = PI + float(k) / 16.0 * PI
		var a1: float = PI + float(k + 1) / 16.0 * PI
		var p0: Vector2 = Vector2(c.x + cos(a0) * rad, c.y + sin(a0) * rad)
		var p1: Vector2 = Vector2(c.x + cos(a1) * rad, c.y + sin(a1) * rad)
		_actor.draw_line(p0, p1, EDGE, 8.0, false)
	var mid := Vector2(sz.x * 0.5 + jig, sz.y * 0.62)
	if _mystery:
		_draw_silhouette(mid, sz)
	elif not _idle.is_empty():
		var frames: Array = _run if mode == "seat" and not _run.is_empty() else _idle
		var tex: Texture2D = frames[int(_fi) % frames.size()]
		var side := 128.0
		var dest := Rect2(Vector2((sz.x - side) * 0.5 + jig, 24.0), Vector2(side, side))
		_actor.draw_texture_rect(tex, dest, false)
	_draw_doors(sz)
	_actor.draw_circle(Vector2(sz.x * 0.5, sz.y - 10.0), 28.0, Color(TORCH.r, TORCH.g, TORCH.b, 0.22))


func _draw_silhouette(c: Vector2, _sz: Vector2) -> void:
	var ink := Color(0.04, 0.03, 0.03, 0.94)
	var scale: float = 0.78 + float(mini(pack_tier, 3)) * 0.08
	var head_r: float = 16.0 * scale
	var head := c + Vector2(0, -48.0 * scale)
	_actor.draw_circle(head, head_r, ink)
	var body := PackedVector2Array([
		c + Vector2(-28.0 * scale, -18.0 * scale),
		c + Vector2(28.0 * scale, -18.0 * scale),
		c + Vector2(36.0 * scale, 36.0 * scale),
		c + Vector2(-36.0 * scale, 36.0 * scale),
	])
	_actor.draw_colored_polygon(body, ink)
	var glow: float = 0.55 + 0.45 * absf(sin(_bob * 2.4))
	var eye := Color(ATK.r, ATK.g, ATK.b, glow)
	_actor.draw_circle(head + Vector2(-6, 1), 3.0, eye)
	_actor.draw_circle(head + Vector2(6, 1), 3.0, eye)


func _draw_doors(sz: Vector2) -> void:
	var t: float = clampf(_doors, 0.0, 1.0)
	if t <= 0.02:
		return
	var wood := Color("4a3018")
	var hole := Rect2(Vector2(18, 22), Vector2(sz.x - 36, sz.y - 36))
	var leaf_w: float = hole.size.x * 0.5 * t
	_actor.draw_rect(Rect2(hole.position, Vector2(leaf_w, hole.size.y)), wood)
	_actor.draw_rect(Rect2(Vector2(hole.end.x - leaf_w, hole.position.y), Vector2(leaf_w, hole.size.y)), wood)


func _process(delta: float) -> void:
	if not visible:
		return
	_fi += delta * 5.5
	_bob += delta
	_glow_t += delta
	if _bait and _bait.visible:
		var pulse: float = 0.55 + 0.45 * absf(sin(_glow_t * TAU / 1.2))
		_bait.modulate = Color(1, 1, 1, 0.85 + 0.15 * pulse)
		var sb: StyleBoxFlat = _bait.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.shadow_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.25 + 0.35 * pulse)
			sb.shadow_size = int(18 + 10 * pulse)
	if _actor:
		_actor.queue_redraw()
	if _nib:
		_nib.global_position = Vector2(24, 900)
