extends VBoxContainer
## Compact draft ask: item (click to take) + threat block + Leave (pass).

signal send_pressed
signal refuse_pressed
signal item_hovered
signal item_unhovered

const COPY := preload("res://scripts/player_copy.gd")
const UI := preload("res://scripts/ui_palette.gd")
const UX := preload("res://scripts/ux_style.gd")

const GOLD := Color("FFD84A")
const TORCH := Color("F09A34")
const SOOT := Color("1A120E")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
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
var _item_slot: Control
var _bait: PanelContainer
var _item_icon: TextureRect
var _item_name: Label
var _item_num: Label
var _item_tag: Label
var _value_row: HBoxContainer
var _fallback: VBoxContainer
var _threat_slot: Control
var _threat: Control
var _threat_name: Label
var _threat_icon: TextureRect
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
var _actor: Control


func setup(p_art) -> void:
	art = p_art
	theme = load("res://themes/swipe_theme.tres")
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	_font_sk = load("res://assets/ui/fonts/Silkscreen-Bold.ttf")
	add_theme_constant_override("separation", 8)
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
	_cue.max_lines_visible = 2
	if _font_px != null:
		_cue.add_theme_font_override("font", _font_px)
	_cue.add_theme_font_size_override("font_size", 28)
	_cue.add_theme_color_override("font_color", PARCHMENT)
	_cue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_cue)

	_item_slot = Control.new()
	_item_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_slot.size_flags_stretch_ratio = 0.6
	_item_slot.custom_minimum_size = Vector2(0, 160)
	add_child(_item_slot)

	_bait = PanelContainer.new()
	_bait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bait.mouse_filter = Control.MOUSE_FILTER_STOP
	_bait.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_bait.gui_input.connect(_on_bait_input)
	_bait.mouse_entered.connect(func() -> void: item_hovered.emit())
	_bait.mouse_exited.connect(func() -> void: item_unhovered.emit())
	_style_bait()
	_item_slot.add_child(_bait)

	var bait_col := VBoxContainer.new()
	bait_col.alignment = BoxContainer.ALIGNMENT_CENTER
	bait_col.add_theme_constant_override("separation", 4)
	bait_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bait.add_child(bait_col)

	_relic_host = CenterContainer.new()
	_relic_host.visible = false
	_relic_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_relic_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bait_col.add_child(_relic_host)

	_fallback = VBoxContainer.new()
	_fallback.alignment = BoxContainer.ALIGNMENT_CENTER
	_fallback.add_theme_constant_override("separation", 4)
	_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fallback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bait_col.add_child(_fallback)

	_item_icon = TextureRect.new()
	_item_icon.custom_minimum_size = Vector2(96, 96)
	_item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_item_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_fallback.add_child(_item_icon)

	_item_name = Label.new()
	_item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_item_name.autowrap_mode = TextServer.AUTOWRAP_WORD
	_item_name.max_lines_visible = 2
	UI.apply_name(_item_name, PARCHMENT, UI.SIZE_NAME)
	_fallback.add_child(_item_name)

	_value_row = HBoxContainer.new()
	_value_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_value_row.add_theme_constant_override("separation", 6)
	_value_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fallback.add_child(_value_row)
	_item_num = Label.new()
	_item_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.apply_number(_item_num, PARCHMENT, UI.SIZE_NUMBER)
	_value_row.add_child(_item_num)
	_item_tag = Label.new()
	_item_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.apply_tag(_item_tag, PARCHMENT, UI.SIZE_TAG)
	_value_row.add_child(_item_tag)

	_threat_slot = Control.new()
	_threat_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_threat_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_threat_slot.size_flags_stretch_ratio = 0.4
	_threat_slot.custom_minimum_size = Vector2(0, 88)
	add_child(_threat_slot)

	_threat = Control.new()
	_threat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_threat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_threat.draw.connect(_draw_threat)
	_threat_slot.add_child(_threat)

	var threat_col := VBoxContainer.new()
	threat_col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	threat_col.alignment = BoxContainer.ALIGNMENT_CENTER
	threat_col.add_theme_constant_override("separation", 4)
	threat_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_threat.add_child(threat_col)

	_threat_icon = TextureRect.new()
	_threat_icon.custom_minimum_size = Vector2(36, 36)
	_threat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_threat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_threat_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_threat_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_threat_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_threat_icon.visible = false
	if ResourceLoader.exists("res://assets/icons/skull.svg"):
		_threat_icon.texture = load("res://assets/icons/skull.svg")
	threat_col.add_child(_threat_icon)

	_threat_name = Label.new()
	_threat_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_threat_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _font_sk != null:
		_threat_name.add_theme_font_override("font", _font_sk)
	_threat_name.add_theme_font_size_override("font_size", 28)
	_threat_name.add_theme_color_override("font_color", SOOT)
	threat_col.add_child(_threat_name)

	_actor = Control.new()
	_actor.visible = false
	_actor.custom_minimum_size = Vector2(0, 0)
	_actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actor.draw.connect(_draw_arch)
	add_child(_actor)

	var plate_scn: PackedScene = load("res://scenes/ui/owner_plate.tscn")
	if plate_scn != null:
		_owner_plate = plate_scn.instantiate()
		_owner_plate.visible = false
		add_child(_owner_plate)

	_refuse = Button.new()
	_refuse.custom_minimum_size = Vector2(0, 56)
	_refuse.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_refuse.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		_refuse.add_theme_font_override("font", _font_px)
	_refuse.add_theme_font_size_override("font_size", 26)
	_style_leave(true)
	_refuse.pressed.connect(func() -> void: refuse_pressed.emit())
	add_child(_refuse)

	_pips = HBoxContainer.new()
	_pips.alignment = BoxContainer.ALIGNMENT_CENTER
	_pips.add_theme_constant_override("separation", 8)
	add_child(_pips)
	for _n in range(3):
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(22, 8)
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


func _style_bait() -> void:
	var bsb := StyleBoxFlat.new()
	bsb.bg_color = Color("2A1C10")
	bsb.border_color = GOLD
	bsb.set_border_width_all(6)
	bsb.content_margin_left = 10
	bsb.content_margin_right = 10
	bsb.content_margin_top = 8
	bsb.content_margin_bottom = 8
	_bait.add_theme_stylebox_override("panel", bsb)


func _style_leave(on: bool) -> void:
	if _refuse == null:
		return
	var ink: Color = GOLD if on else Color("8A7550")
	_refuse.add_theme_color_override("font_color", ink)
	_refuse.add_theme_color_override("font_hover_color", PARCHMENT)
	_refuse.add_theme_color_override("font_disabled_color", Color("8A7550"))
	var leave_n := StyleBoxFlat.new()
	leave_n.bg_color = Color(0, 0, 0, 0)
	leave_n.border_color = ink
	leave_n.set_border_width_all(4)
	leave_n.content_margin_top = 10
	leave_n.content_margin_bottom = 10
	_refuse.add_theme_stylebox_override("normal", leave_n)
	var leave_h := leave_n.duplicate()
	leave_h.bg_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.14)
	_refuse.add_theme_stylebox_override("hover", leave_h)
	_refuse.add_theme_stylebox_override("pressed", leave_h)
	var leave_d := leave_n.duplicate()
	leave_d.border_color = Color("8A7550")
	_refuse.add_theme_stylebox_override("disabled", leave_d)


func present_mystery(item: Dictionary, tier: int, item_tex: Texture2D, passes_left: int, value_bb: String = "", _body: String = "") -> void:
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
	_cue.visible = _cue.text.strip_edges() != ""
	if _actor:
		_actor.visible = false
	_bait.visible = true
	_item_slot.visible = true
	_threat_slot.visible = true
	_item_icon.texture = item_tex
	_item_name.text = str(item.get("name", ""))
	_apply_value(str(item.get("kind", "")), value_bb)
	_fallback.visible = true
	_write_threat(pack_tier)
	_refuse.visible = true
	_pips.visible = true
	hide_owner()
	set_passes(passes_left)
	modulate.a = 1.0
	pivot_offset = Vector2(size.x * 0.5, 24)
	scale = Vector2(0.94, 0.94)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.22)
	if _threat:
		_threat.queue_redraw()


func set_item_value(number_text: String, tag: String, kind: String) -> void:
	_apply_value(kind, number_text, tag)


func _apply_value(kind: String, number_text: String, tag: String = "") -> void:
	var k: String = kind.to_upper()
	var shown: String = number_text.strip_edges()
	if shown.begins_with("[") and shown.contains("]"):
		shown = _strip_bb(shown)
	if shown == "—" or shown == "–" or shown == "-" or shown.to_upper() == "X":
		shown = "?"
	var t: String = tag
	if t == "":
		if k == "DEFEAT" or k == "FANGS" or k == "KO":
			shown = COPY.need("hand.tag.ko")
			t = ""
		elif k == "ATK" or k.contains("ATK"):
			t = COPY.need("hand.tag.atk")
		elif k == "BLK" or k.contains("BLK"):
			t = COPY.need("hand.tag.blk")
		elif k == "HEAL" or k.contains("HEAL"):
			t = COPY.need("hand.tag.heal")
	var ink: Color = UI.kind_ink(k if k != "" else t)
	if _item_num:
		_item_num.text = shown
		UI.apply_number(_item_num, ink, UI.SIZE_NUMBER)
		_item_num.visible = shown != ""
	if _item_tag:
		_item_tag.text = t
		UI.apply_tag(_item_tag, ink, UI.SIZE_TAG)
		_item_tag.visible = t.strip_edges() != ""
	if _value_row:
		_value_row.visible = shown != "" or t.strip_edges() != ""


func _strip_bb(s: String) -> String:
	var out := ""
	var i := 0
	while i < s.length():
		if s[i] == "[":
			var close: int = s.find("]", i)
			if close >= 0:
				i = close + 1
				continue
		out += s[i]
		i += 1
	return out.strip_edges()


func _write_threat(tier: int) -> void:
	if _threat_name:
		_threat_name.text = COPY.tier_name(tier)
		_threat_name.add_theme_color_override("font_color", UX.metal_ink(tier))
		if _font_sk != null:
			_threat_name.add_theme_font_override("font", _font_sk)
		_threat_name.add_theme_font_size_override("font_size", 22 if tier <= 1 else (26 if tier == 2 else 32))
	if _threat_icon:
		_threat_icon.visible = tier >= 2
		_threat_icon.modulate = UX.metal_ink(tier)
		_threat_icon.custom_minimum_size = Vector2(28, 28) if tier == 2 else Vector2(40, 40)
	if _threat:
		_threat.queue_redraw()


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
	_style_leave(n > 0)
	_refuse.modulate.a = 1.0 if n > 0 else 0.55
	if mode == "ask" and _cue:
		if n <= 0:
			_cue.text = COPY.text("cue.steal", COPY.need("door.pass_none"))
		else:
			_cue.text = COPY.need("cue.ask")
	for i in _pip_dots.size():
		var d: ColorRect = _pip_dots[i]
		d.color = TORCH if i < n else Color(UX.metal(1).r, UX.metal(1).g, UX.metal(1).b, 0.28)


func reveal(monster: Dictionary, _value_bb: String = "", _speech: String = "", _reminder: String = "") -> void:
	card_id = str(monster.get("card_id", ""))
	_mystery = false
	_idle = art.monster_idle(card_id) if art else []
	_run = art.monster_run(card_id) if art else []
	_fi = 0.0
	_doors = 0.0
	_cue.text = COPY.need("cue.seat")
	_bait.visible = false
	_item_slot.visible = false
	_threat_slot.visible = false
	_refuse.visible = false
	_pips.visible = false
	if _actor:
		_actor.visible = true
		_actor.custom_minimum_size = Vector2(220, 160)
		_actor.queue_redraw()


func set_seat() -> void:
	mode = "seat"
	_refuse.visible = false
	_pips.visible = false
	_bait.visible = false
	_item_slot.visible = false
	_threat_slot.visible = false
	if _cue:
		_cue.text = COPY.text("cue.seat", "A monster approaches. Select their location.")


func leave_btn() -> Control:
	return _refuse


func relic_host() -> Control:
	if _relic_host != null:
		return _relic_host
	return _item_icon


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
	if _threat != null and _threat.visible:
		return _threat.global_position + Vector2(_threat.size.x * 0.5, _threat.size.y)
	if _actor == null:
		return Vector2(1236, 190)
	return _actor.global_position + Vector2(_actor.size.x * 0.5, _actor.size.y - 8.0)


func actor_global() -> Vector2:
	if _threat != null and _threat.visible:
		return _threat.global_position + _threat.size * 0.5
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
	_relic_host.visible = false
	if _fallback:
		_fallback.visible = true


func mount_relic(card: Control) -> void:
	clear_relic()
	if card == null or _relic_host == null:
		return
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	_relic_host.add_child(card)
	card.visible = true
	_relic_host.visible = true
	if _fallback:
		_fallback.visible = false


func play_slam(fast: bool = false) -> void:
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


func qa_snapshot() -> Dictionary:
	var r: Rect2 = get_global_rect()
	return {
		"mode": mode,
		"visible": visible,
		"header": _cue.text if _cue else "",
		"leave": _refuse.text if _refuse else "",
		"leave_disabled": _refuse.disabled if _refuse else true,
		"take_present": false,
		"tier": pack_tier,
		"threat": _threat_name.text if _threat_name else "",
		"item_name": _item_name.text if _item_name else "",
		"rect": [r.position.x, r.position.y, r.size.x, r.size.y],
	}


func _draw_threat() -> void:
	if _threat == null:
		return
	var sz: Vector2 = _threat.size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var t: int = clampi(pack_tier, 1, 3)
	var well: Color = UX.metal_well(t)
	var rim: Color = UX.metal(t)
	var pulse: float = 0.0
	if t >= 3:
		pulse = 0.45 + 0.55 * absf(sin(_glow_t * TAU / 0.85))
	elif t == 2:
		pulse = 0.15
	var pad := 2.0
	var box := Rect2(Vector2(pad, pad), sz - Vector2(pad * 2.0, pad * 2.0))
	_threat.draw_rect(box, well, true)
	if t >= 3:
		var glow := Color(ATK.r, ATK.g, ATK.b, 0.18 + 0.42 * pulse)
		_threat.draw_rect(box.grow(6.0 + 4.0 * pulse), glow, false, 8.0 + 6.0 * pulse)
	var bw: float = 3.0 if t <= 1 else (5.0 if t == 2 else 8.0)
	_threat.draw_rect(box, rim, false, bw)
	if t >= 3:
		_threat.draw_rect(box.grow(-5.0), Color(ATK.r, ATK.g, ATK.b, 0.35 + 0.4 * pulse), false, 3.0)
	if t >= 2 and (_threat_icon == null or _threat_icon.texture == null):
		_draw_skull(sz * 0.5 + Vector2(0, -10), 14.0 if t == 2 else 18.0, UX.metal_ink(t))


func _draw_skull(c: Vector2, r: float, col: Color) -> void:
	if _threat == null:
		return
	_threat.draw_circle(c, r, col)
	_threat.draw_circle(c + Vector2(-r * 0.35, -r * 0.05), r * 0.22, SOOT)
	_threat.draw_circle(c + Vector2(r * 0.35, -r * 0.05), r * 0.22, SOOT)
	_threat.draw_rect(Rect2(c + Vector2(-r * 0.22, r * 0.28), Vector2(r * 0.44, r * 0.28)), SOOT)


func _draw_arch() -> void:
	if _actor == null or not _actor.visible:
		return
	var sz: Vector2 = _actor.size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var jig: float = sin(_bob * 48.0) * _shake * 5.0
	if not _idle.is_empty():
		var frames: Array = _run if mode == "seat" and not _run.is_empty() else _idle
		var tex: Texture2D = frames[int(_fi) % frames.size()]
		var side := 128.0
		var dest := Rect2(Vector2((sz.x - side) * 0.5 + jig, 16.0), Vector2(side, side))
		_actor.draw_texture_rect(tex, dest, false)
	_draw_doors(sz)


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
		var pulse: float = 0.70 + 0.30 * absf(sin(_glow_t * TAU / 1.2))
		_bait.modulate = Color(1, 1, 1, 0.90 + 0.10 * pulse)
		var sb: StyleBoxFlat = _bait.get_theme_stylebox("panel") as StyleBoxFlat
		if sb:
			sb.shadow_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.20 + 0.25 * pulse)
			sb.shadow_size = int(10 + 8 * pulse)
	if _threat and _threat.visible:
		_threat.queue_redraw()
	if _actor and _actor.visible:
		_actor.queue_redraw()
	if _nib:
		_nib.global_position = Vector2(24, 900)
