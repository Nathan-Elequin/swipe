extends Control
## Auto-show stack of parchment keyword cards beside an inspect plate / log line.
## Locked 2026-11-14: inspect shows every keyword at once (StS-style), no word-hover required.

const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")
const KeywordDefs := preload("res://scripts/keyword_defs.gd")
const CARD_W := 296.0
const STACK_GAP := 8.0
const COL_GAP := 12.0
const EDGE := 24.0
const PLATE_GAP := 12.0

var _cards: Array = [] ## PanelContainer keyword_tip instances
var _ids: Array = []
var _anchor: Control = null
var _source: String = ""
var _highlighted: String = ""
var _layout_host: Control = null


func setup() -> void:
	name = "KeywordStack"
	visible = false
	z_index = 141
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func current_ids() -> Array:
	return _ids.duplicate()


func card_count() -> int:
	return _cards.size()


func cards() -> Array:
	return _cards.duplicate()


func is_showing() -> bool:
	return visible and not _ids.is_empty()


func show_for_bbcode(text: String, anchor: Control = null, source: String = "") -> void:
	show_ids(UxStyle.collect_kw_ids(text), anchor, source)


func show_ids(ids: Array, anchor: Control = null, source: String = "") -> void:
	var cleaned: Array = []
	var seen: Dictionary = {}
	var known: Dictionary = {}
	for kid0 in KeywordDefs.ids():
		known[str(kid0)] = true
	known["phoenix"] = true
	known["phoenix_egg"] = true
	for raw in ids:
		var kid: String = str(raw).strip_edges().to_lower()
		if kid == "" or seen.has(kid):
			continue
		if not known.has(kid):
			continue
		seen[kid] = true
		cleaned.append(kid)
	if cleaned.is_empty():
		hide_stack()
		return
	_anchor = anchor
	_source = source if source != "" else _detect_source(anchor)
	_ids = cleaned
	_rebuild_cards()
	visible = true
	set_process(true)
	_place()
	_offer_first_sight_teach()


func hide_stack() -> void:
	for tip in _cards:
		if tip != null and is_instance_valid(tip):
			if tip.has_method("notify_player_action"):
				tip.notify_player_action()
			tip.set("stack_mode", false)
			if tip.has_method("hide_def"):
				tip.set("_pinned", false)
				tip.hide_def()
			tip.queue_free()
	_cards.clear()
	_ids.clear()
	_highlighted = ""
	_anchor = null
	_source = ""
	visible = false
	set_process(false)


func highlight_id(id: String) -> void:
	var kid: String = id.strip_edges().to_lower()
	_highlighted = kid
	for tip in _cards:
		if tip == null or not is_instance_valid(tip):
			continue
		var on: bool = kid != "" and str(tip.get("_kind")) == kid
		if tip.has_method("set_stack_highlight"):
			tip.set_stack_highlight(on)


func clear_highlight() -> void:
	_highlighted = ""
	for tip in _cards:
		if tip != null and is_instance_valid(tip) and tip.has_method("set_stack_highlight"):
			tip.set_stack_highlight(false)


func notify_player_action() -> void:
	for tip in _cards:
		if tip != null and is_instance_valid(tip) and tip.has_method("notify_player_action"):
			tip.notify_player_action()


func stack_rect() -> Rect2:
	if not visible or _cards.is_empty():
		return Rect2()
	var union := Rect2()
	var first := true
	for tip in _cards:
		if tip == null or not is_instance_valid(tip) or not tip.visible:
			continue
		## Prefer global_position+size: get_global_rect() can lag a frame for top_level cards.
		var r := Rect2(tip.global_position, tip.size)
		if r.size.x < 1.0 or r.size.y < 1.0:
			r = tip.get_global_rect()
		if first:
			union = r
			first = false
		else:
			union = union.merge(r)
	return union


func text_overflows() -> bool:
	## True when any card's definition RichTextLabel would clip.
	for tip in _cards:
		if tip == null or not is_instance_valid(tip):
			continue
		var def: RichTextLabel = tip.get("_def") as RichTextLabel
		if def == null:
			continue
		## fit_content cards should expose full line count; visible < content ⇒ clip.
		var lines: int = def.get_line_count()
		var visible_lines: int = def.get_visible_line_count()
		if lines > 0 and visible_lines > 0 and visible_lines < lines:
			return true
		var content_h: float = def.get_content_height()
		if content_h > 1.0 and def.size.y + 1.0 < content_h:
			return true
	return false


func _process(_delta: float) -> void:
	if not visible or _cards.is_empty():
		set_process(false)
		return
	if not is_inside_tree():
		set_process(false)
		return
	_place()


func _rebuild_cards() -> void:
	for tip in _cards:
		if tip != null and is_instance_valid(tip):
			tip.queue_free()
	_cards.clear()
	var host: Node = _card_host()
	for kid in _ids:
		var tip: PanelContainer = KEYWORD_TIP.new()
		host.add_child(tip)
		tip.setup()
		tip.set("stack_mode", true)
		tip.set("top_level", true)
		tip.z_index = 141
		if tip.has_method("show_in_stack"):
			tip.show_in_stack(kid, _anchor, _source)
		else:
			tip.show_def(KeywordDefs.def_of(kid), _anchor, kid, _source, false)
		_cards.append(tip)


func _prune_dead_cards() -> void:
	var live: Array = []
	for tip in _cards:
		if tip != null and is_instance_valid(tip):
			live.append(tip)
	_cards = live


func _card_host() -> Node:
	## Prefer Main so cards paint with the fight HUD and are not clipped by the plate.
	if is_inside_tree():
		var main: Node = get_tree().root.get_node_or_null("Main")
		if main != null:
			return main
	var p: Node = get_parent()
	return p if p != null else self


func _offer_first_sight_teach() -> void:
	## First unseen keyword in appearance order gets gold pulse + new_star once.
	for tip in _cards:
		if tip == null or not is_instance_valid(tip):
			continue
		var kid: String = str(tip.get("_kind"))
		if kid == "":
			continue
		if tip.has_method("_has_seen") and tip.call("_has_seen", kid):
			continue
		if tip.has_method("offer_teach"):
			tip.offer_teach(kid, _anchor, _source)
		return


func _place() -> void:
	_prune_dead_cards()
	if _cards.is_empty():
		set_process(false)
		return
	## Fight HUD is authored at 1680×1040. Always dock in that design space so
	## headless / oversized windows match what the player sees in F5.
	var vp := Vector2(1680, 1040)
	var sizes: Array = []
	var total_h := 0.0
	for tip in _cards:
		if tip == null or not is_instance_valid(tip):
			sizes.append(Vector2(CARD_W, 96))
			continue
		tip.reset_size()
		var sz: Vector2 = tip.get_combined_minimum_size()
		sz.x = CARD_W
		sz.y = maxf(sz.y, 96.0)
		## Grow to fit definition — never ellipsize.
		var def: RichTextLabel = tip.get("_def") as RichTextLabel
		if def != null:
			def.custom_minimum_size.x = CARD_W - 40.0
			def.fit_content = true
			def.scroll_active = false
			tip.reset_size()
			sz = tip.get_combined_minimum_size()
			sz.x = CARD_W
			sz.y = maxf(sz.y, 96.0)
		tip.size = sz
		sizes.append(sz)
		total_h += sz.y
	total_h += STACK_GAP * maxf(float(_cards.size() - 1), 0.0)
	var plate := _anchor_rect()
	var keep: Rect2 = _keep_out()
	var max_stack_h: float = maxf(vp.y - EDGE * 2.0, 200.0)
	## Two columns when a single column would not fit in the viewport height.
	var cols := 1
	var two_w: float = CARD_W * 2.0 + COL_GAP
	var room_for_two := (vp.x - EDGE * 2.0) >= two_w + 8.0
	if room_for_two and _cards.size() >= 2 and total_h > max_stack_h - 8.0:
		cols = 2
	var col_heights: Array = [0.0, 0.0]
	var col_cards: Array = [[], []]
	for i in range(_cards.size()):
		var c: int = 0
		if cols == 2:
			c = 0 if float(col_heights[0]) <= float(col_heights[1]) else 1
		(col_cards[c] as Array).append(i)
		col_heights[c] = float(col_heights[c]) + float((sizes[i] as Vector2).y) + STACK_GAP
	## If 1-col still overflows after packing, force 2-col and rebuild columns.
	var stack_h_probe: float = maxf(float(col_heights[0]) - STACK_GAP, 96.0)
	if cols == 1 and room_for_two and _cards.size() >= 2 and stack_h_probe > max_stack_h - 8.0:
		cols = 2
		col_heights = [0.0, 0.0]
		col_cards = [[], []]
		for i2 in range(_cards.size()):
			var c2: int = 0 if float(col_heights[0]) <= float(col_heights[1]) else 1
			(col_cards[c2] as Array).append(i2)
			col_heights[c2] = float(col_heights[c2]) + float((sizes[i2] as Vector2).y) + STACK_GAP
	var stack_w: float = CARD_W if cols == 1 else two_w
	var stack_h: float = float(col_heights[0])
	if cols == 2:
		stack_h = maxf(float(col_heights[0]), float(col_heights[1]))
	stack_h = maxf(stack_h - STACK_GAP, 96.0)
	var origin: Vector2 = _dock_origin(plate, Vector2(stack_w, stack_h), keep, vp)
	## Start high enough that the real column fits inside the design viewport.
	origin.y = minf(origin.y, vp.y - EDGE - stack_h)
	origin.y = maxf(origin.y, EDGE)
	origin.x = clampf(origin.x, EDGE, maxf(EDGE, vp.x - EDGE - stack_w))
	## Place each column's cards top-down from origin (no per-card Y clamp —
	## that would leave the first card low while later cards pile up).
	for c in range(cols):
		var x: float = origin.x + float(c) * (CARD_W + COL_GAP)
		var y: float = origin.y
		for idx in col_cards[c]:
			var tip_v: Variant = _cards[idx]
			var sz: Vector2 = sizes[idx]
			if tip_v != null and typeof(tip_v) == TYPE_OBJECT and is_instance_valid(tip_v):
				var tip: PanelContainer = tip_v
				tip.global_position = Vector2(x, y)
				tip.size = sz
				if tip.has_method("_layout_chrome"):
					tip._layout_chrome()
			y += sz.y + STACK_GAP
	## Final shift: keep the whole stack inside the design viewport.
	_shift_stack_into_viewport(vp, keep, plate)
	## Debug keep-out assert on the union.
	if OS.is_debug_build() and keep.size.x > 0.0:
		var union: Rect2 = stack_rect()
		if union.size.x > 0.0 and union.intersects(keep):
			push_warning("KeywordStack overlaps wheel keep-out: %s vs %s" % [union, keep])


func _shift_stack_into_viewport(vp: Vector2, keep: Rect2, plate: Rect2) -> void:
	var union: Rect2 = stack_rect()
	if union.size.x < 1.0:
		return
	var dx := 0.0
	var dy := 0.0
	if union.position.x < EDGE:
		dx = EDGE - union.position.x
	elif union.end.x > vp.x - EDGE:
		dx = (vp.x - EDGE) - union.end.x
	if union.position.y < EDGE:
		dy = EDGE - union.position.y
	elif union.end.y > vp.y - EDGE:
		dy = (vp.y - EDGE) - union.end.y
	if absf(dx) < 0.5 and absf(dy) < 0.5:
		return
	for tip in _cards:
		if tip != null and is_instance_valid(tip):
			tip.global_position += Vector2(dx, dy)
	## If the shift pushed us into the wheel or plate, try a horizontal nudge instead.
	union = stack_rect()
	if keep.size.x > 0.0 and union.intersects(keep):
		var nudge := 0.0
		if union.get_center().x <= keep.get_center().x:
			nudge = keep.position.x - PLATE_GAP - union.size.x - union.position.x
		else:
			nudge = keep.end.x + PLATE_GAP - union.position.x
		for tip2 in _cards:
			if tip2 != null and is_instance_valid(tip2):
				tip2.global_position.x += nudge
		union = stack_rect()
		## Re-clamp X after nudge.
		var dx2 := 0.0
		if union.position.x < EDGE:
			dx2 = EDGE - union.position.x
		if union.end.x > vp.x - EDGE:
			dx2 = (vp.x - EDGE) - union.end.x
		if absf(dx2) >= 0.5:
			for tip3 in _cards:
				if tip3 != null and is_instance_valid(tip3):
					tip3.global_position.x += dx2
	if plate.size.x > 0.0:
		union = stack_rect()
		if union.intersects(plate.grow(-2.0)):
			## Prefer above the plate when still overlapping after the shift.
			var above_y: float = plate.position.y - PLATE_GAP - union.size.y
			var dy2: float = above_y - union.position.y
			if above_y >= EDGE:
				for tip4 in _cards:
					if tip4 != null and is_instance_valid(tip4):
						tip4.global_position.y += dy2


func _dock_origin(plate: Rect2, stack_sz: Vector2, keep: Rect2, vp: Vector2) -> Vector2:
	var clamp_r := Rect2(EDGE, EDGE, maxf(vp.x - EDGE * 2.0, 100.0), maxf(vp.y - EDGE * 2.0, 100.0))
	## Side of the plate away from the wheel center.
	var wheel_c: Vector2 = keep.get_center() if keep.size.x > 0.0 else Vector2(vp.x * 0.5, vp.y * 0.4)
	var plate_c: Vector2 = plate.get_center() if plate.size.x > 0.0 else Vector2(vp.x * 0.75, vp.y * 0.7)
	var prefer_left: bool = plate_c.x >= wheel_c.x
	var rail_x: float = (keep.end.x + PLATE_GAP) if keep.size.x > 0.0 else maxf(vp.x * 0.72, 1252.0)
	var left_rail: float = EDGE
	if keep.size.x > 0.0:
		left_rail = maxf(EDGE, keep.position.x - PLATE_GAP - stack_sz.x)
	var candidates: Array = []
	if prefer_left:
		candidates.append(Vector2(plate.position.x - PLATE_GAP - stack_sz.x, plate.position.y))
		candidates.append(Vector2(plate.end.x + PLATE_GAP, plate.position.y))
	else:
		candidates.append(Vector2(plate.end.x + PLATE_GAP, plate.position.y))
		candidates.append(Vector2(plate.position.x - PLATE_GAP - stack_sz.x, plate.position.y))
	## Above / below when side slots collide with plate or wheel.
	candidates.append(Vector2(plate.position.x, plate.position.y - PLATE_GAP - stack_sz.y))
	candidates.append(Vector2(plate.end.x - stack_sz.x, plate.position.y - PLATE_GAP - stack_sz.y))
	candidates.append(Vector2(plate.position.x + (plate.size.x - stack_sz.x) * 0.5, plate.position.y - PLATE_GAP - stack_sz.y))
	candidates.append(Vector2(plate.position.x, plate.end.y + PLATE_GAP))
	candidates.append(Vector2(plate.end.x - stack_sz.x, plate.end.y + PLATE_GAP))
	## Rails outside the wheel keep-out.
	candidates.append(Vector2(rail_x, EDGE))
	candidates.append(Vector2(rail_x, clampf(plate.position.y, EDGE, maxf(EDGE, vp.y - EDGE - stack_sz.y))))
	candidates.append(Vector2(left_rail, EDGE))
	candidates.append(Vector2(left_rail, clampf(plate.position.y, EDGE, maxf(EDGE, vp.y - EDGE - stack_sz.y))))
	var best := Vector2.INF
	var best_pen := 1.0e12
	for raw in candidates:
		var p: Vector2 = raw
		## Only clamp when the raw slot already fits; otherwise clamping can
		## drag a right-of-plate slot leftward into the wheel.
		var fits_x: bool = p.x >= clamp_r.position.x and p.x + stack_sz.x <= clamp_r.end.x
		var fits_y: bool = p.y >= clamp_r.position.y and p.y + stack_sz.y <= clamp_r.end.y
		if fits_x and fits_y:
			var card := Rect2(p, stack_sz)
			if plate.size.x > 0.0 and card.intersects(plate.grow(-2.0)):
				continue
			if keep.size.x > 0.0 and card.intersects(keep):
				continue
			return p
		## Soft candidate: clamp and score by keep/plate penetration.
		p.x = clampf(p.x, clamp_r.position.x, maxf(clamp_r.position.x, clamp_r.end.x - stack_sz.x))
		p.y = clampf(p.y, clamp_r.position.y, maxf(clamp_r.position.y, clamp_r.end.y - stack_sz.y))
		var soft := Rect2(p, stack_sz)
		var pen := 0.0
		if keep.size.x > 0.0 and soft.intersects(keep):
			var hit: Rect2 = soft.intersection(keep)
			pen += hit.get_area()
		if plate.size.x > 0.0 and soft.intersects(plate):
			var hit2: Rect2 = soft.intersection(plate)
			pen += hit2.get_area() * 2.0
		if pen < best_pen:
			best_pen = pen
			best = p
	if best.x < 1.0e11:
		return best
	## Last resort: top-right corner of the design viewport.
	return Vector2(clampf(vp.x - EDGE - stack_sz.x, EDGE, vp.x - EDGE), EDGE)


func _anchor_rect() -> Rect2:
	if _anchor != null and is_instance_valid(_anchor) and _anchor.visible:
		var r: Rect2 = _anchor.get_global_rect()
		if r.size.x < 8.0:
			r.size = _anchor.get_combined_minimum_size()
		return r
	return Rect2()


func _keep_out() -> Rect2:
	## Reuse tip keep-out math via a live card when possible.
	for tip in _cards:
		if tip != null and is_instance_valid(tip) and tip.has_method("keep_out_rect"):
			return tip.keep_out_rect()
	return Rect2()


func _detect_source(anchor: Control) -> String:
	if anchor == null:
		return "item"
	if str(anchor.get("edit_kind")) == "item" or str(anchor.get("plate_kind")) == "item":
		return "item"
	if str(anchor.get("edit_kind")) == "monster" or str(anchor.get("plate_kind")) == "monster":
		return "monster"
	var n: Node = anchor
	while n != null:
		var path: String = str(n.get_script().resource_path) if n.get_script() else ""
		var sn: String = str(n.name).to_lower()
		if path.ends_with("combat_log.gd") or sn.find("combatlog") >= 0 or sn.find("combat_log") >= 0:
			return "log"
		n = n.get_parent()
	return "item"
