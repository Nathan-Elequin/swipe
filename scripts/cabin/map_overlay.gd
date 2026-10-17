extends Control
## Two equal-weight courses on Grandpa's map. Click a route to pick; confirm starts it.

signal closed
signal go(route: String)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const COPY := preload("res://scripts/player_copy.gd")
const DEV_FLAGS := preload("res://scripts/dev_flags.gd")
const LAYOUT_PATH := "res://design/visual/layouts/map-routes.layout.json"
const ROUTES: Array[String] = ["gatehouse", "long_drop"]
const SEAL := 48.0
const SEAL_GAP := 4.0
const TRAIL_HIT := 16.0

var cabin
var extra: Dictionary = {}
var selected: String = "gatehouse"
var _lay: Dictionary = {}
var _sheet: TextureRect
var _hero: AnimatedSprite2D
var _panel: NinePatchRect
var _panel_name: FitLabelBox
var _panel_mode: FitLabelBox
var _panel_body: FitLabelBox
var _panel_foot: FitLabelBox
var _go_lab: FitLabelBox
var _go_btn: FitButton
var _tip: FitLabelBox
var _group: ButtonGroup
var _tags: Dictionary = {}
var _pins: Dictionary = {}
var _seals: Dictionary = {}
var _dots: Dictionary = {}
var _hover_n: Dictionary = {}
var _hovered: String = ""
var _click_id: String = ""
var _click_ms: int = 0
var _dot_tween: Tween


func setup(p_cabin, p_extra: Dictionary) -> void:
	cabin = p_cabin
	extra = p_extra
	_lay = KIT.load_layout(LAYOUT_PATH)
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_as_relative = false
	z_index = 50
	visible = false
	_group = ButtonGroup.new()
	_group.allow_unpress = false
	var scrim: ColorRect = KIT.scrim(0.75, 50)
	scrim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close()
	)
	add_child(scrim)
	var sheet_el: Dictionary = KIT.layout_el(_lay, "Sheet")
	_sheet = TextureRect.new()
	_sheet.texture = KIT.ui_tex("map/map_close_v2.png")
	_sheet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sheet.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sheet.stretch_mode = TextureRect.STRETCH_KEEP
	_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	KIT.apply_rect(_sheet, KIT.rect_px(sheet_el.get("rect", [120, 56, 1440, 928])), int(sheet_el.get("z", 55)))
	add_child(_sheet)
	_add_flags()
	_build_route("Route.Classic", "gatehouse")
	_build_route("Route.Challenge", "long_drop")
	_hero = KIT.anim_sprite(["overlays/map_hero_f0.png", "overlays/map_hero_f1.png"], "h", 1000.0 / 400.0, true, Vector2.ZERO)
	var hero_el: Dictionary = KIT.layout_el(_lay, "HeroMarker")
	_hero.centered = false
	_hero.position = KIT.rect_px(hero_el.get("rect", [148, 776, 64, 64])).position
	_hero.z_index = int(hero_el.get("z", 58))
	add_child(_hero)
	if _hero.sprite_frames:
		_hero.play("h")
	_build_panel()
	_build_title()
	_build_close()
	_build_confirm()
	_build_dev_tag()
	_tip = KIT.fit_label("", Rect2(0, 0, 160, 36), 20, 16, 1, KIT.INK, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, 80)
	_tip.show_frame = true
	_tip.frame_texture = KIT.load_tex("ui/tooltip_parchment_9.png")
	_tip.patch_margin_left = 32
	_tip.patch_margin_right = 32
	_tip.patch_margin_top = 16
	_tip.patch_margin_bottom = 16
	_tip.padding = 8
	_tip.grow_to_text = true
	_tip.max_width = 280
	_tip.visible = false
	add_child(_tip)


func open_map(route: String = "") -> void:
	visible = true
	var want: String = route if route != "" else str(cabin.last_route if cabin else "")
	if want not in ROUTES:
		want = "gatehouse"
	selected = want
	_hovered = ""
	_refresh_all(true)
	if _go_btn:
		_go_btn.grab_focus()
	_sheet.scale = Vector2(0.92, 0.92)
	_sheet.modulate.a = 0.0
	_sheet.pivot_offset = _sheet.size * 0.5
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_sheet, "scale", Vector2.ONE, 0.18)
	tw.parallel().tween_property(_sheet, "modulate:a", 1.0, 0.18)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.scroll")


func close() -> void:
	if not visible:
		return
	KIT.cue(cabin.sfx if cabin else null, &"cabin.scroll")
	visible = false
	_hide_tip()
	closed.emit()


func debug_select(route: String) -> void:
	if route not in ROUTES:
		return
	_select(route, false)
	_hovered = ""
	_refresh_all(false)


func debug_hover(route: String) -> void:
	_hovered = route if route in ROUTES else ""
	_refresh_all(false)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		_go()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build_route(el_id: String, route: String) -> void:
	var el: Dictionary = KIT.layout_el(_lay, el_id)
	var hits: Dictionary = el.get("hit_areas", {})
	var tag_r: Rect2 = KIT.rect_px(hits.get("tag", el.get("rect", [])))
	var pin_r: Rect2 = KIT.rect_px(hits.get("pin", []))
	var poly: Array = hits.get("trail_polyline_px", [])
	var z: int = int(el.get("z", 60))
	var host := Control.new()
	host.name = el_id
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.z_index = 56
	add_child(host)
	var dots: Array = []
	for p in poly:
		if typeof(p) != TYPE_ARRAY or (p as Array).size() < 2:
			continue
		var pt := Vector2(float(p[0]), float(p[1]))
		var d := TextureRect.new()
		d.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		d.stretch_mode = TextureRect.STRETCH_KEEP
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		d.texture = KIT.ui_tex("map/route_dot_idle.png")
		d.size = Vector2(8, 8)
		d.position = pt - Vector2(4, 4)
		d.z_index = 56
		host.add_child(d)
		dots.append(d)
		var hit := Control.new()
		hit.position = pt - Vector2(TRAIL_HIT, TRAIL_HIT)
		hit.size = Vector2(TRAIL_HIT * 2.0, TRAIL_HIT * 2.0)
		hit.mouse_filter = Control.MOUSE_FILTER_STOP
		hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit.z_index = 57
		_bind_route_hit(hit, route)
		host.add_child(hit)
	_dots[route] = dots
	var pin := TextureRect.new()
	pin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pin.stretch_mode = TextureRect.STRETCH_KEEP
	pin.mouse_filter = Control.MOUSE_FILTER_STOP
	pin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	KIT.apply_rect(pin, pin_r, 57)
	_bind_route_hit(pin, route)
	add_child(pin)
	_pins[route] = pin
	var tag := Button.new()
	tag.toggle_mode = true
	tag.button_group = _group
	tag.focus_mode = Control.FOCUS_NONE
	tag.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tag.clip_text = false
	tag.add_theme_stylebox_override("normal", KIT.route_card_style("idle"))
	tag.add_theme_stylebox_override("hover", KIT.route_card_style("hover"))
	tag.add_theme_stylebox_override("pressed", KIT.route_card_style("selected"))
	tag.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	KIT.apply_rect(tag, tag_r, z)
	tag.toggled.connect(func(on: bool) -> void:
		if not on and selected == route:
			tag.set_pressed_no_signal(true)
	)
	_bind_route_hit(tag, route)
	add_child(tag)
	_tags[route] = tag
	var name_el: Dictionary = KIT.layout_child(el, el_id + ".Name")
	var mode_el: Dictionary = KIT.layout_child(el, el_id + ".Mode")
	var name_t: Dictionary = name_el.get("text", {})
	var mode_t: Dictionary = mode_el.get("text", {})
	var name_r: Rect2 = KIT.rect_px(name_el.get("rect", []))
	var name_lab: FitLabelBox = KIT.fit_label(
		"map.route.%s" % route,
		Rect2(name_r.position - tag_r.position, name_r.size),
		int(name_t.get("font_max", 40)),
		int(name_t.get("font_min", 20)),
		int(name_t.get("max_lines", 1)),
		Color(str(name_t.get("color", "#3a2414"))),
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		1
	)
	tag.add_child(name_lab)
	var mode_r: Rect2 = KIT.rect_px(mode_el.get("rect", []))
	var mode_col := Color(str(mode_t.get("color", "#5a3a24")))
	var mode_lab: FitLabelBox = KIT.fit_label(
		"map.route.%s.mode" % route,
		Rect2(mode_r.position - tag_r.position, mode_r.size),
		int(mode_t.get("font_max", 32)),
		int(mode_t.get("font_min", 16)),
		int(mode_t.get("max_lines", 1)),
		mode_col,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		1
	)
	tag.add_child(mode_lab)
	var seal := TextureRect.new()
	seal.texture = KIT.ui_tex("map/route_seal_check.png")
	seal.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	seal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	seal.stretch_mode = TextureRect.STRETCH_KEEP
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seal.size = Vector2(SEAL, SEAL)
	seal.position = Vector2(tag_r.position.x + tag_r.size.x + SEAL_GAP, tag_r.position.y - SEAL - SEAL_GAP)
	seal.z_index = z + 2
	seal.visible = false
	add_child(seal)
	_seals[route] = seal


func _bind_route_hit(c: Control, route: String) -> void:
	c.mouse_entered.connect(func() -> void:
		_route_enter(route)
	)
	c.mouse_exited.connect(func() -> void:
		_route_exit(route)
	)
	c.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_on_route_clicked(route)
	)


func _build_panel() -> void:
	var el: Dictionary = KIT.layout_el(_lay, "Panel")
	_panel = KIT.ui_nine("panel/parchment_panel_9.png", 24, 24, 24, 24)
	KIT.apply_rect(_panel, KIT.rect_px(el.get("rect", [992, 204, 512, 508])), int(el.get("z", 60)))
	add_child(_panel)
	var nm: Dictionary = KIT.layout_child(el, "Panel.Name")
	var md: Dictionary = KIT.layout_child(el, "Panel.Mode")
	var rule: Dictionary = KIT.layout_child(el, "Panel.Rule")
	var body: Dictionary = KIT.layout_child(el, "Panel.Body")
	var foot: Dictionary = KIT.layout_child(el, "Panel.Footer")
	_panel_name = KIT.fit_label(
		"map.route.gatehouse",
		KIT.rect_px(nm.get("rect", [])),
		int(nm.get("text", {}).get("font_max", 48)),
		int(nm.get("text", {}).get("font_min", 24)),
		1,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(nm.get("z", 65))
	)
	add_child(_panel_name)
	_panel_mode = KIT.fit_label(
		"map.route.gatehouse.mode",
		KIT.rect_px(md.get("rect", [])),
		int(md.get("text", {}).get("font_max", 32)),
		int(md.get("text", {}).get("font_min", 16)),
		1,
		KIT.MODE_RED,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(md.get("z", 65))
	)
	add_child(_panel_mode)
	var rule_r: Rect2 = KIT.rect_px(rule.get("rect", [1028, 336, 440, 12]))
	var rule_n := KIT.ui_nine("panel/parchment_rule.png", 8, 0, 8, 0)
	KIT.apply_rect(rule_n, rule_r, int(rule.get("z", 62)))
	add_child(rule_n)
	_panel_body = KIT.fit_label(
		"map.route.gatehouse.desc",
		KIT.rect_px(body.get("rect", [])),
		int(body.get("text", {}).get("font_max", 32)),
		int(body.get("text", {}).get("font_min", 20)),
		int(body.get("text", {}).get("max_lines", 6)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_LEFT,
		VERTICAL_ALIGNMENT_TOP,
		int(body.get("z", 65))
	)
	add_child(_panel_body)
	_panel_foot = KIT.fit_label(
		"map.deepest",
		KIT.rect_px(foot.get("rect", [])),
		int(foot.get("text", {}).get("font_max", 28)),
		int(foot.get("text", {}).get("font_min", 20)),
		1,
		KIT.WOOD,
		HORIZONTAL_ALIGNMENT_LEFT,
		VERTICAL_ALIGNMENT_CENTER,
		int(foot.get("z", 65))
	)
	add_child(_panel_foot)


func _build_title() -> void:
	var title_el: Dictionary = KIT.layout_el(_lay, "Title")
	var tt: Dictionary = title_el.get("text", {})
	var title: FitLabelBox = KIT.fit_label(
		"map.title",
		KIT.rect_px(title_el.get("rect", [])),
		int(tt.get("font_max", 40)),
		int(tt.get("font_min", 24)),
		int(tt.get("max_lines", 2)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(title_el.get("z", 65))
	)
	add_child(title)
	var leg_el: Dictionary = KIT.layout_el(_lay, "Legend")
	var lt: Dictionary = leg_el.get("text", {})
	var legend: FitLabelBox = KIT.fit_label(
		"map.legend",
		KIT.rect_px(leg_el.get("rect", [])),
		int(lt.get("font_max", 28)),
		int(lt.get("font_min", 20)),
		int(lt.get("max_lines", 2)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_LEFT,
		VERTICAL_ALIGNMENT_CENTER,
		int(leg_el.get("z", 65))
	)
	add_child(legend)


func _build_close() -> void:
	var el: Dictionary = KIT.layout_el(_lay, "CloseX")
	var b := TextureButton.new()
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP
	b.texture_normal = KIT.ui_tex("map/map_close_x_normal.png")
	b.texture_hover = KIT.ui_tex("map/map_close_x_hover.png")
	b.texture_pressed = KIT.ui_tex("map/map_close_x_pressed.png")
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	KIT.apply_rect(b, KIT.rect_px(el.get("rect", [1452, 108, 64, 64])), int(el.get("z", 70)))
	b.pressed.connect(close)
	b.mouse_entered.connect(func() -> void:
		_show_tip("map.back", b)
	)
	b.mouse_exited.connect(_hide_tip)
	add_child(b)


func _build_confirm() -> void:
	var el: Dictionary = KIT.layout_el(_lay, "Confirm")
	_go_btn = KIT.plank(KIT.rect_px(el.get("rect", [992, 724, 512, 108])), int(el.get("z", 70)), true)
	_go_btn.pressed.connect(_go)
	add_child(_go_btn)
	var lab_el: Dictionary = KIT.layout_child(el, "Confirm.Label")
	var lt: Dictionary = lab_el.get("text", {})
	_go_lab = KIT.fit_label(
		"map.go",
		KIT.rect_px(lab_el.get("rect", [])),
		int(lt.get("font_max", 40)),
		int(lt.get("font_min", 24)),
		int(lt.get("max_lines", 2)),
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(lab_el.get("z", 71))
	)
	add_child(_go_lab)


func _build_dev_tag() -> void:
	if not DEV_FLAGS.show_quick_start():
		return
	var el: Dictionary = KIT.layout_el(_lay, "DevTag.QuickStart")
	var b: FitButton = KIT.dev_plank(KIT.rect_px(el.get("rect", [164, 122, 148, 44])), int(el.get("z", 90)))
	b.pressed.connect(_quick_start)
	add_child(b)
	var lab_el: Dictionary = KIT.layout_child(el, "DevTag.QuickStart.Label")
	var lt: Dictionary = lab_el.get("text", {})
	var lab: FitLabelBox = KIT.fit_label(
		"",
		KIT.rect_px(lab_el.get("rect", [180, 128, 120, 32])),
		int(lt.get("font_max", 24)),
		int(lt.get("font_min", 16)),
		1,
		KIT.CREAM,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		int(lab_el.get("z", 91))
	)
	lab.set_plain("Quick Start")
	add_child(lab)


func _add_flags() -> void:
	var flags: Array = extra.get("map_deep_flags", [])
	var origin: Array = extra.get("overlay_origins", {}).get("overlays/map_close.png", [30, 14])
	var sheet_pos := Vector2(float(origin[0]), float(origin[1])) * 4.0
	var belly: int = int(cabin.deepest_belly) if cabin else 0
	for i in flags.size():
		var tip: Array = flags[i]
		var fl := TextureRect.new()
		fl.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fl.position = sheet_pos + Vector2(float(tip[0]) - 2.0, float(tip[1]) - 13.0) * 4.0
		fl.size = Vector2(8, 14) * 4.0
		fl.z_index = 56
		fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fl.texture = KIT.load_tex("overlays/map_flag.png" if belly >= i + 1 else "overlays/map_flag_unreached.png")
		add_child(fl)


func _shown_route() -> String:
	if _hovered != "" and _hovered != selected:
		return _hovered
	return selected


func _route_enter(route: String) -> void:
	_hover_n[route] = int(_hover_n.get(route, 0)) + 1
	if _hovered != route:
		_hovered = route
		KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
		_refresh_all(false)


func _route_exit(route: String) -> void:
	_hover_n[route] = maxi(0, int(_hover_n.get(route, 0)) - 1)
	if int(_hover_n.get(route, 0)) == 0 and _hovered == route:
		_hovered = ""
		_refresh_all(false)


func _on_route_clicked(route: String) -> void:
	var now: int = Time.get_ticks_msec()
	if selected == route and _click_id == route and now - _click_ms < 400:
		_go()
		return
	_click_id = route
	_click_ms = now
	_select(route, true)
	var tag: Button = _tags.get(route)
	if tag:
		tag.set_pressed_no_signal(true)


func _select(route: String, sfx_on: bool) -> void:
	if route not in ROUTES:
		return
	selected = route
	if cabin:
		cabin.last_route = route
		cabin._save()
	if sfx_on:
		KIT.cue(cabin.sfx if cabin else null, &"cabin.map_pin")
	_refresh_all(true)


func _refresh_all(draw_on: bool) -> void:
	for r in ROUTES:
		_apply_route_visual(r, draw_on and r == selected)
	_refresh_panel()
	_refresh_go()
	var tag: Button = _tags.get(selected)
	if tag and not tag.button_pressed:
		tag.set_pressed_no_signal(true)


func _apply_route_visual(route: String, draw_on: bool) -> void:
	var st: String = "idle"
	if route == selected:
		st = "selected"
	elif route == _hovered:
		st = "hover"
	var tag: Button = _tags.get(route)
	if tag:
		var sb: StyleBox = KIT.route_card_style("idle" if st == "idle" else ("hover" if st == "hover" else "selected"))
		tag.add_theme_stylebox_override("normal", sb)
		tag.add_theme_stylebox_override("hover", KIT.route_card_style("hover" if st != "selected" else "selected"))
		tag.add_theme_stylebox_override("pressed", KIT.route_card_style("selected"))
	var pin: TextureRect = _pins.get(route)
	if pin:
		pin.texture = KIT.load_tex("overlays/map_pin_%s_%s.png" % [route, st if st != "selected" else "selected"])
	var seal: TextureRect = _seals.get(route)
	if seal:
		seal.visible = route == selected
	var dots: Array = _dots.get(route, [])
	var dot_rel: String = "map/route_dot_idle.png"
	if st == "hover":
		dot_rel = "map/route_dot_hover.png"
	elif st == "selected":
		dot_rel = "map/route_dot_lit.png"
	var tex: Texture2D = KIT.ui_tex(dot_rel)
	if draw_on and st == "selected" and dots.size() > 0:
		if _dot_tween:
			_dot_tween.kill()
		_dot_tween = create_tween()
		_dot_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var step: float = 0.4 / float(maxi(1, dots.size()))
		for i in dots.size():
			var d: TextureRect = dots[i]
			d.texture = tex
			d.modulate.a = 0.0
			_dot_tween.parallel().tween_property(d, "modulate:a", 1.0, step).set_delay(step * float(i))
	else:
		for d2 in dots:
			(d2 as TextureRect).texture = tex
			(d2 as TextureRect).modulate.a = 1.0


func _refresh_panel() -> void:
	var id: String = _shown_route()
	_panel_name.set_copy("map.route.%s" % id)
	_panel_mode.set_copy("map.route.%s.mode" % id)
	_panel_mode.font_color = KIT.MODE_RED if id == "long_drop" else KIT.WOOD
	_panel_body.set_copy("map.route.%s.desc" % id)
	var deepest: int = int(cabin.deepest_belly) if cabin else 0
	if id == "long_drop" and deepest > 0:
		_panel_foot.visible = true
		_panel_foot.set_copy("map.deepest", {"n": deepest})
	else:
		_panel_foot.visible = false


func _refresh_go() -> void:
	var mode: String = KIT.copy_text("map.route.%s.mode" % selected)
	if COPY.has_key("map.go.named"):
		_go_lab.set_copy("map.go.named", {"mode": mode})
	else:
		_go_lab.set_copy("map.go")


func _show_tip(key: String, hit: Control) -> void:
	_tip.set_copy(key)
	_tip.visible = true
	_tip.fit()
	var g: Rect2 = hit.get_global_rect()
	_tip.global_position = Vector2(g.position.x + g.size.x * 0.5 - _tip.size.x * 0.5, g.position.y - _tip.size.y - 8.0)


func _hide_tip() -> void:
	_tip.visible = false


func _go() -> void:
	var r: String = selected
	if r not in ROUTES:
		r = "gatehouse"
	close()
	go.emit(r)


func _quick_start() -> void:
	close()
	var m: Node = cabin.get_parent() if cabin else null
	if m and m.has_method("_quick_start"):
		m._quick_start()
