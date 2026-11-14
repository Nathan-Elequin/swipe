extends PanelContainer
## Direction A parchment keyword card. Replaces the gold capsule, combat-log hint,
## and Rust/Phoenix mini-plate callouts. Public API kept for existing callers.

const KeywordDefs := preload("res://scripts/keyword_defs.gd")
const CARD_W := 296.0
const CARD_MIN_H := 96.0
const KEEP_GROW := 16.0
const RAIL_GAP := 24.0
const HOVER_DELAY := 0.15
const OPEN_FADE := 0.12
const CLOSE_FADE := 0.08
const TEACH_PULSE := 0.45
const TEACH_PULSES := 3
const PARCHMENT := "res://assets/ui/trophy/parchment_tag.png"
const SEAL_TEX := "res://assets/ui/keyword/kw_card_seal.png"
const STAR_TEX := "res://assets/ui/hud/new_star.png"
const LEADER_DOT := "res://assets/ui/keyword/kw_leader_dot.png"
const FONT_SEMI := "res://assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf"
const FONT_REG := "res://assets/ui/fonts/open_sans/OpenSans-Regular.ttf"

## Shared across tip instances so only one card shows / one teach runs.
static var _active: WeakRef
static var _teach_queue: Array = []
static var _teach_busy: bool = false
static var _teach_id: String = ""
static var _teach_dismiss_pending: bool = false

var _icon: TextureRect
var _name_lab: Label
var _def: RichTextLabel
var _seal: TextureRect
var _star: TextureRect
var _shadow: NinePatchRect
var _leader: Line2D
var _vbox: VBoxContainer
var _anchor: Control = null
var _anchor_rect := Rect2()
var _kind: String = ""
var _source: String = "" ## monster | item | pip | log | tutorial | cursor
var _pinned: bool = false
var _follow_mouse: bool = false
var _hover_open: bool = false
var _first_sight: bool = false
var _hover_timer: float = -1.0
var _pending_show: Dictionary = {}
var _tween: Tween
var _tutorial_layer: CanvasLayer = null
var _font_title: Font
var _font_body: Font


func setup() -> void:
	visible = false
	z_index = 141
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(CARD_W, CARD_MIN_H)
	_font_title = _load_font(FONT_SEMI)
	_font_body = _load_font(FONT_SEMI)
	_build_chrome()
	set_process(false)


func _load_font(path: String) -> Font:
	if ResourceLoader.exists(path):
		return load(path) as Font
	return ThemeDB.fallback_font


func _build_chrome() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var parch: Texture2D = null
	if ResourceLoader.exists(PARCHMENT):
		parch = load(PARCHMENT) as Texture2D
	_shadow = NinePatchRect.new()
	_shadow.name = "Shadow"
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow.show_behind_parent = true
	_shadow.modulate = Color(0, 0, 0, 0.45)
	_shadow.position = Vector2(0, 4)
	_shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shadow.offset_top = 4
	_shadow.offset_bottom = 4
	if parch:
		_shadow.texture = parch
		_shadow.patch_margin_left = 24
		_shadow.patch_margin_right = 24
		_shadow.patch_margin_top = 24
		_shadow.patch_margin_bottom = 24
	add_child(_shadow)
	var sb := StyleBoxTexture.new()
	if parch:
		sb.texture = parch
		sb.texture_margin_left = 24
		sb.texture_margin_right = 24
		sb.texture_margin_top = 24
		sb.texture_margin_bottom = 24
		sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
		sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 22
	add_theme_stylebox_override("panel", sb)
	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 10)
	_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_vbox)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vbox.add_child(head)
	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(48, 48)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_icon)
	_name_lab = Label.new()
	_name_lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_lab.add_theme_font_size_override("font_size", 20)
	_name_lab.add_theme_color_override("font_color", Color("4A2F1F"))
	_name_lab.add_theme_constant_override("line_spacing", 6)
	if _font_title:
		_name_lab.add_theme_font_override("font", _font_title)
	_name_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_name_lab)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 2)
	rule.color = Color("C9B183")
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vbox.add_child(rule)
	_def = RichTextLabel.new()
	_def.bbcode_enabled = true
	_def.fit_content = true
	_def.scroll_active = false
	_def.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_def.custom_minimum_size = Vector2(CARD_W - 40.0, 0)
	_def.add_theme_font_size_override("normal_font_size", 17)
	_def.add_theme_font_size_override("bold_font_size", 17)
	_def.add_theme_color_override("default_color", Color("4A2F1F"))
	_def.add_theme_constant_override("line_separation", 6)
	if _font_body:
		_def.add_theme_font_override("normal_font", _font_body)
		_def.add_theme_font_override("bold_font", _font_body)
	_def.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vbox.add_child(_def)
	_seal = TextureRect.new()
	_seal.visible = false
	_seal.mouse_filter = Control.MOUSE_FILTER_STOP
	_seal.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_seal.custom_minimum_size = Vector2(40, 40)
	_seal.stretch_mode = TextureRect.STRETCH_KEEP
	if ResourceLoader.exists(SEAL_TEX):
		_seal.texture = load(SEAL_TEX) as Texture2D
	_seal.gui_input.connect(_on_seal_gui)
	add_child(_seal)
	_star = TextureRect.new()
	_star.visible = false
	_star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_star.custom_minimum_size = Vector2(28, 28)
	_star.stretch_mode = TextureRect.STRETCH_KEEP
	if ResourceLoader.exists(STAR_TEX):
		_star.texture = load(STAR_TEX) as Texture2D
	add_child(_star)
	_leader = Line2D.new()
	_leader.visible = false
	_leader.width = 2.0
	_leader.default_color = Color("E8C36A")
	_leader.texture_mode = Line2D.LINE_TEXTURE_TILE
	if ResourceLoader.exists(LEADER_DOT):
		_leader.texture = load(LEADER_DOT) as Texture2D
	_leader.z_index = -1
	add_child(_leader)
	mouse_entered.connect(_on_card_hover)
	mouse_exited.connect(_on_card_unhover)


func show_def_at_cursor(msg: String, id: String = "") -> void:
	_follow_mouse = true
	_source = "cursor"
	show_def(msg, null, id, "cursor")


func show_def_at(rect: Rect2, msg: String = "", id: String = "", source: String = "") -> void:
	_follow_mouse = false
	_anchor = null
	_anchor_rect = rect
	_source = source if source != "" else "monster"
	var body: String = msg if msg != "" else KeywordDefs.def_of(id)
	_reveal(body, id, false)


func show_def_hover(msg: String, anchor: Control = null, id: String = "", source: String = "") -> void:
	## Chip hover: 0.15s delay before open (spec §5).
	show_def(msg, anchor, id, source, true)


func show_def(msg: String, anchor: Control = null, id: String = "", source: String = "", delayed: bool = false) -> void:
	if _def == null:
		return
	if _is_other_pinned():
		return
	var t: String = msg.strip_edges()
	var kid: String = id.strip_edges().to_lower()
	if t == "" and kid != "":
		t = KeywordDefs.def_of(kid)
	if t == "":
		hide_def()
		return
	_follow_mouse = false
	_anchor = anchor
	_source = source if source != "" else _detect_source(anchor)
	if _pinned and _kind == kid:
		_reveal(t, kid, false)
		return
	## Hover delay unless teach / pin / already open on same id.
	if not _first_sight and not _pinned and visible and _kind == kid:
		_reveal(t, kid, false)
		return
	if delayed and not _first_sight and not _pinned and not visible:
		_pending_show = {"msg": t, "id": kid, "anchor": anchor, "source": _source}
		_hover_timer = HOVER_DELAY
		set_process(true)
		return
	_reveal(t, kid, false)


func pin_def(msg: String, anchor: Control = null, id: String = "", source: String = "") -> void:
	if _pinned and _kind == id.strip_edges().to_lower():
		unpin()
		return
	_claim_active()
	_pinned = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_first_sight = false
	_hover_timer = -1.0
	_pending_show.clear()
	var kid: String = id.strip_edges().to_lower()
	var t: String = msg.strip_edges()
	if t == "" and kid != "":
		t = KeywordDefs.def_of(kid)
	_anchor = anchor
	_source = source if source != "" else _detect_source(anchor)
	_reveal(t, kid, false)
	_show_seal(true)


func show_callout(pack: Dictionary, anchor: Control = null, id: String = "") -> void:
	## Direction A: no mini-plate. Open the shared parchment with this id's def,
	## falling back to the callout body text when the id has no keyword-defs row.
	if pack.is_empty():
		hide_def()
		return
	var kid: String = id.strip_edges().to_lower()
	var body: String = KeywordDefs.def_of(kid)
	if body == "":
		body = str(pack.get("body", "")).strip_edges()
		var url_rx := RegEx.new()
		if url_rx.compile("\\[url=[^\\]]+\\]|\\[/url\\]") == OK:
			body = url_rx.sub(body, "", true)
	if body == "":
		body = str(pack.get("value", "")).strip_edges()
	show_def(body, anchor, kid if kid != "" else str(pack.get("title", "")).to_lower(), _detect_source(anchor))


func hide_def() -> void:
	if _pinned:
		return
	if _teach_dismiss_pending and _kind == _teach_id:
		_finish_teach_dismiss()
	_hover_open = false
	_hover_timer = -1.0
	_pending_show.clear()
	_first_sight = false
	visible = false
	_anchor = null
	_kind = ""
	_follow_mouse = false
	_source = ""
	if _seal:
		_seal.visible = false
	if _star:
		_star.visible = false
	if _leader:
		_leader.visible = false
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_release_active()


func unpin() -> void:
	_pinned = false
	if _seal:
		_seal.visible = false
	hide_def()


func is_pinned() -> bool:
	return _pinned


func current_id() -> String:
	return _kind


func card_rect() -> Rect2:
	return get_global_rect()


## First-sighting teach entry point. Queues if another teach is running.
func offer_teach(id: String, anchor: Control = null, source: String = "") -> void:
	var kid: String = id.strip_edges().to_lower()
	if kid == "" or _has_seen(kid):
		return
	for q in _teach_queue:
		if str(q.get("id", "")) == kid:
			return
	if _teach_busy and _teach_id == kid:
		return
	_teach_queue.append({"id": kid, "anchor": anchor, "source": source})
	_pump_teach()


func notify_player_action() -> void:
	## Spin / Use / Take / Move / outside click — dismisses an open teach.
	if _teach_dismiss_pending and visible and _kind == _teach_id:
		_finish_teach_dismiss()
		hide_def()


func preview_first_sighting(id: String) -> void:
	## Dev editor: play teach for the selected id without touching the save.
	var kid: String = id.strip_edges().to_lower()
	if kid == "":
		return
	_teach_busy = true
	_teach_id = kid
	_teach_dismiss_pending = true
	_first_sight = true
	_pinned = false
	_source = "item"
	_reveal(KeywordDefs.def_of(kid), kid, true)
	_pulse_then_open_star()


func keep_out_rect(vp: Vector2 = Vector2.ZERO) -> Rect2:
	var wheel: Node = _wheel()
	if wheel == null:
		return Rect2()
	var c: Vector2 = Vector2.ZERO
	var r: float = 0.0
	if wheel.has_method("_center") and wheel.has_method("_radius"):
		c = wheel.get_global_transform() * wheel.call("_center")
		r = float(wheel.call("_radius")) + KEEP_GROW
	else:
		var wr: Rect2 = (wheel as Control).get_global_rect()
		c = wr.get_center()
		r = maxf(wr.size.x, wr.size.y) * 0.5 + KEEP_GROW
	return Rect2(c.x - r, c.y - r, r * 2.0, r * 2.0)


func intersects_keep_out(card: Rect2, keep: Rect2) -> bool:
	## Circle keep-out approximated by grown bounding rect (spec §3).
	return card.intersects(keep)


func _reveal(msg: String, id: String, teach: bool) -> void:
	_claim_active()
	_kind = id
	_name_lab.text = KeywordDefs.title_of(id) if id != "" else ""
	_name_lab.visible = id != ""
	var icon_path: String = KeywordDefs.card_icon_path(id)
	if ResourceLoader.exists(icon_path):
		_icon.texture = load(icon_path) as Texture2D
		_icon.visible = true
	else:
		var chip_path: String = KeywordDefs.icon_path(id)
		if ResourceLoader.exists(chip_path):
			_icon.texture = load(chip_path) as Texture2D
			_icon.visible = true
		else:
			_icon.visible = false
	## Nested keywords inside the card body: bold brown, not hoverable.
	_def.clear()
	_def.append_text(_bold_nested_keywords(msg))
	_star.visible = teach or _first_sight
	_seal.visible = _pinned
	_layout_chrome()
	visible = true
	modulate.a = 1.0
	reset_size()
	_place()
	set_process(true)
	_hover_open = true


func _bold_nested_keywords(raw: String) -> String:
	var t: String = raw.strip_edges()
	if t == "":
		return ""
	## Strip any accidental urls; bold known keyword stems in brown.
	var rx := RegEx.new()
	if rx.compile("\\[url=[^\\]]+\\]|\\[/url\\]") == OK:
		t = rx.sub(t, "", true)
	var word_rx := RegEx.new()
	if word_rx.compile("(?i)\\b(flee|spin|poison|decay|shroud|always|swap|loaded|unplayable|rust|gaze|petrify|curse|toll|hex|beggar|marked|defeated|across|move|eject|any)\\b") != OK:
		return t
	var hits: Array = word_rx.search_all(t)
	var out := t
	for i in range(hits.size() - 1, -1, -1):
		var m: RegExMatch = hits[i]
		var w: String = m.get_string()
		out = out.substr(0, m.get_start()) + "[b][color=#7A4E2B]%s[/color][/b]" % w + out.substr(m.get_end())
	return out


func _layout_chrome() -> void:
	if _seal:
		_seal.position = Vector2(-12, -12)
		_seal.size = Vector2(40, 40)
	if _star:
		_star.position = Vector2(CARD_W - 24.0, -4.0)
		_star.size = Vector2(28, 28)


func _process(delta: float) -> void:
	if _hover_timer >= 0.0:
		_hover_timer -= delta
		if _hover_timer <= 0.0:
			_hover_timer = -1.0
			if not _pending_show.is_empty():
				var p: Dictionary = _pending_show.duplicate()
				_pending_show.clear()
				_anchor = p.get("anchor")
				_source = str(p.get("source", ""))
				_reveal(str(p.get("msg", "")), str(p.get("id", "")), false)
				_fade_open()
		return
	if not visible:
		set_process(false)
		return
	_place()


func _fade_open() -> void:
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	var from: Vector2 = global_position + Vector2(0, 6)
	var to: Vector2 = global_position
	global_position = from
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, OPEN_FADE)
	_tween.parallel().tween_property(self, "global_position", to, OPEN_FADE)


func _place() -> void:
	reset_size()
	var sz: Vector2 = get_combined_minimum_size()
	sz.x = CARD_W
	sz.y = maxf(sz.y, CARD_MIN_H)
	size = sz
	var vp := Vector2(1680, 1040)
	if is_inside_tree():
		var got: Vector2 = get_viewport_rect().size
		if got.x >= 8.0:
			vp = got
	var keep: Rect2 = keep_out_rect(vp)
	var hotbar: Rect2 = _hotbar_rect()
	var rail_x: float = maxf(keep.end.x if keep.size.x > 0.0 else 0.0, hotbar.end.x if hotbar.size.x > 0.0 else 0.0) + RAIL_GAP
	if rail_x < RAIL_GAP + 8.0:
		rail_x = maxf(vp.x * 0.72, 1252.0)
	var clamp_r := Rect2(24, 24, maxf(vp.x - 48.0, 100.0), maxf(vp.y - 48.0, 100.0))
	var anchor := _anchor_global()
	var candidates: Array = _dock_candidates(anchor, sz, keep, rail_x, vp)
	var pos: Vector2 = _first_fit(candidates, sz, keep, clamp_r)
	global_position = pos
	size = sz
	_layout_chrome()
	_update_leader(anchor, pos, sz)
	if OS.is_debug_build() and keep.size.x > 0.0:
		var card := Rect2(pos, sz)
		if intersects_keep_out(card, keep):
			push_warning("KeywordTip overlaps wheel keep-out: %s vs %s" % [card, keep])


func _anchor_global() -> Rect2:
	if _follow_mouse:
		var mouse: Vector2 = get_global_mouse_position()
		return Rect2(mouse + Vector2(14, 10), Vector2(12, 12))
	if _anchor != null and is_instance_valid(_anchor) and _anchor.visible:
		var r: Rect2 = _anchor.get_global_rect()
		if r.size.x < 8.0:
			r.size = _anchor.get_combined_minimum_size()
		return r
	if _anchor_rect.size.x > 0.0:
		return _anchor_rect
	var mouse2: Vector2 = get_global_mouse_position()
	return Rect2(mouse2, Vector2(12, 12))


func _dock_candidates(anchor: Rect2, sz: Vector2, keep: Rect2, rail_x: float, vp: Vector2) -> Array:
	var out: Array = []
	match _source:
		"monster":
			out.append(Vector2(anchor.end.x - sz.x, anchor.end.y + 8.0))
			out.append(Vector2(anchor.position.x, anchor.position.y - 8.0 - sz.y))
			out.append(Vector2(rail_x, 24.0))
		"item":
			out.append(Vector2(anchor.end.x + 12.0, anchor.position.y))
			out.append(Vector2(anchor.position.x - 12.0 - sz.x, anchor.position.y))
			out.append(Vector2(rail_x, clamp(anchor.position.y, 24.0, vp.y - 24.0 - sz.y)))
		"pip":
			out.append(Vector2(rail_x, clampf(anchor.position.y - 40.0, 24.0, maxf(24.0, vp.y - 24.0 - sz.y))))
		"log":
			out.append(Vector2(24.0, anchor.end.y + 6.0))
			out.append(Vector2(24.0, anchor.position.y - 6.0 - sz.y))
		"tutorial":
			out.append(Vector2(anchor.position.x + 124.0, anchor.end.y + 12.0))
			out.append(Vector2(anchor.position.x + 124.0, anchor.position.y - 12.0 - sz.y))
		_:
			out.append(Vector2(anchor.end.x + 8.0, anchor.position.y))
			out.append(Vector2(anchor.position.x - 8.0 - sz.x, anchor.position.y))
			out.append(Vector2(rail_x, 24.0))
	## Always offer the rail as last resort.
	out.append(Vector2(rail_x, 24.0))
	out.append(Vector2(rail_x, clampf(anchor.position.y, 24.0, maxf(24.0, vp.y - 24.0 - sz.y))))
	return out


func _first_fit(candidates: Array, sz: Vector2, keep: Rect2, clamp_r: Rect2) -> Vector2:
	for c in candidates:
		var p: Vector2 = c
		p.x = clampf(p.x, clamp_r.position.x, clamp_r.end.x - sz.x)
		p.y = clampf(p.y, clamp_r.position.y, clamp_r.end.y - sz.y)
		var card := Rect2(p, sz)
		if keep.size.x > 0.0 and intersects_keep_out(card, keep):
			continue
		return p
	## Forced: push to rail right of keep-out.
	var forced := Vector2(keep.end.x + RAIL_GAP if keep.size.x > 0.0 else clamp_r.position.x, clamp_r.position.y)
	forced.x = clampf(forced.x, clamp_r.position.x, clamp_r.end.x - sz.x)
	forced.y = clampf(forced.y, clamp_r.position.y, clamp_r.end.y - sz.y)
	return forced


func _update_leader(anchor: Rect2, pos: Vector2, sz: Vector2) -> void:
	if _leader == null:
		return
	if _source != "pip":
		_leader.visible = false
		return
	_leader.visible = true
	_leader.clear_points()
	var a: Vector2 = Vector2(anchor.end.x, anchor.get_center().y) - pos
	var b: Vector2 = Vector2(0.0, 16.0 + 24.0) ## mid-head of card in local space
	_leader.add_point(a)
	_leader.add_point(b)


func _detect_source(anchor: Control) -> String:
	if anchor == null:
		return "cursor"
	if str(anchor.get("plate_kind")) == "item" or str(anchor.get("edit_kind")) == "item":
		return "item"
	if str(anchor.get("plate_kind")) == "monster" or str(anchor.get("edit_kind")) == "monster":
		return "monster"
	var n: Node = anchor
	while n != null:
		var nm: String = n.get_class()
		var sn: String = str(n.name).to_lower()
		var path: String = str(n.get_script().resource_path) if n.get_script() else ""
		if path.ends_with("combat_log.gd") or sn.find("combatlog") >= 0 or sn.find("combat_log") >= 0:
			return "log"
		if path.ends_with("tutorial_guide.gd") or sn.find("tutorial") >= 0:
			return "tutorial"
		if path.ends_with("hover_panel.gd"):
			var pk: String = str(n.get("edit_kind"))
			if pk == "item":
				return "item"
			if pk == "monster":
				return "monster"
		n = n.get_parent()
	return "monster"


func _wheel() -> Node:
	var main: Node = get_tree().root.get_node_or_null("Main") if is_inside_tree() else null
	if main != null and main.get("wheel") != null:
		return main.get("wheel")
	return get_tree().root.find_child("BossWheel", true, false) if is_inside_tree() else null


func _hotbar_rect() -> Rect2:
	var main: Node = get_tree().root.get_node_or_null("Main") if is_inside_tree() else null
	if main == null:
		return Rect2()
	for key in ["hotbar", "item_bar", "hand_row"]:
		var n: Variant = main.get(key) if key in main else null
		if n is Control and (n as Control).visible:
			return (n as Control).get_global_rect()
	return Rect2()


func _has_seen(id: String) -> bool:
	var cabin: Node = _cabin()
	if cabin != null and cabin.has_method("has_seen_keyword"):
		return bool(cabin.call("has_seen_keyword", id))
	return false


func _mark_seen(id: String) -> void:
	var cabin: Node = _cabin()
	if cabin != null and cabin.has_method("mark_keyword_seen"):
		cabin.call("mark_keyword_seen", id)


func _cabin() -> Node:
	var main: Node = get_tree().root.get_node_or_null("Main") if is_inside_tree() else null
	if main != null and main.get("home_cabin") != null:
		return main.get("home_cabin")
	return null


func _pump_teach() -> void:
	if _teach_busy or _teach_queue.is_empty():
		return
	var job: Dictionary = _teach_queue.pop_front()
	var kid: String = str(job.get("id", ""))
	if kid == "" or _has_seen(kid):
		call_deferred("_pump_teach")
		return
	_teach_busy = true
	_teach_id = kid
	_teach_dismiss_pending = true
	_first_sight = true
	_pinned = false
	_anchor = job.get("anchor")
	_source = str(job.get("source", _detect_source(_anchor)))
	_reveal(KeywordDefs.def_of(kid), kid, true)
	_pulse_then_open_star()


func _pulse_then_open_star() -> void:
	## Card opens at end of pulse 1 (t=0.45). Star pops after open.
	if _tween:
		_tween.kill()
	modulate.a = 0.0
	visible = true
	_star.visible = false
	_tween = create_tween()
	_tween.tween_interval(TEACH_PULSE)
	_tween.tween_callback(_fade_open)
	_tween.tween_callback(_pop_star)


func _pop_star() -> void:
	if _star == null:
		return
	_star.visible = true
	_star.scale = Vector2.ZERO
	_star.pivot_offset = Vector2(14, 14)
	var tw := create_tween()
	tw.tween_property(_star, "scale", Vector2(1.2, 1.2), 0.15)
	tw.tween_property(_star, "scale", Vector2.ONE, 0.10)


func _finish_teach_dismiss() -> void:
	if _teach_id != "":
		_mark_seen(_teach_id)
	_teach_dismiss_pending = false
	_teach_busy = false
	_teach_id = ""
	_first_sight = false
	if _star:
		_star.visible = false
	call_deferred("_pump_teach")


func _claim_active() -> void:
	var prev: Object = _active.get_ref() if _active != null else null
	if prev != null and prev != self and prev.has_method("hide_def"):
		if bool(prev.get("_pinned")):
			prev.call("unpin")
		else:
			prev.set("_pinned", false)
			prev.call("hide_def")
	_active = weakref(self)


func _release_active() -> void:
	var cur: Object = _active.get_ref() if _active != null else null
	if cur == self:
		_active = null


func _is_other_pinned() -> bool:
	var cur: Object = _active.get_ref() if _active != null else null
	if cur != null and cur != self and bool(cur.get("_pinned")):
		return true
	return false


func _on_card_hover() -> void:
	_hover_open = true


func _on_card_unhover() -> void:
	if _pinned or _teach_dismiss_pending:
		return
	## Close shortly after leaving both chip and card — chip unhover already calls hide_def.
	pass


func _on_seal_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unpin()


func _show_seal(on: bool) -> void:
	if _seal == null:
		return
	_seal.visible = on
	if on:
		_seal.scale = Vector2.ZERO
		_seal.pivot_offset = Vector2(20, 20)
		var tw := create_tween()
		tw.tween_property(_seal, "scale", Vector2(1.15, 1.15), 0.08)
		tw.tween_property(_seal, "scale", Vector2.ONE, 0.04)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _pinned:
			unpin()
			get_viewport().set_input_as_handled()
		elif _teach_dismiss_pending:
			notify_player_action()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _pinned and not get_global_rect().has_point(event.position):
			unpin()
		elif _teach_dismiss_pending and not get_global_rect().has_point(event.position):
			notify_player_action()
