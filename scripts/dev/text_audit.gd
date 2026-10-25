extends CanvasLayer
## Dev-only text collision overlay. F9 toggles. Shot harness writes user://text_audit.json.

const OUT_PATH := "user://text_audit.json"
const COPY_PATH := "res://design/audit-shots/cursor/text_audit.json"
const FIT_LABEL := preload("res://scripts/ui/fit_label_box.gd")

var copy_dir: String = "res://design/audit-shots/cursor"
const MIN_DEFAULT := 16
const MIN_BADGE := 12
const CONTRAST := 4.5

var enabled: bool = false
var last_failures: Array = []
var last_screen: String = ""
var last_shot: String = ""

var _paint: Control
var _hits: Array = []


func setup(_main = null) -> void:
	name = "TextAudit"
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_paint = Control.new()
	_paint.name = "Paint"
	_paint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_paint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_paint.draw.connect(_on_draw)
	add_child(_paint)


func toggle() -> void:
	enabled = not enabled
	visible = enabled
	if enabled:
		scan(last_screen if last_screen != "" else "live", last_shot)
	else:
		_hits.clear()
		if _paint:
			_paint.queue_redraw()


func set_on(on: bool) -> void:
	enabled = on
	visible = on
	if on and _paint:
		_paint.queue_redraw()


func scan(screen: String, shot: String = "") -> Array:
	last_screen = screen
	last_shot = shot
	_hits = _collect()
	last_failures = _flag(_hits, screen, shot)
	_write(last_failures)
	if _paint:
		_paint.queue_redraw()
	return last_failures


func _collect() -> Array:
	var out: Array = []
	var root: Node = get_tree().root
	_walk(root, out)
	return out


func _is_fit(n: Node) -> bool:
	return n != null and FIT_LABEL != null and n.get_script() == FIT_LABEL


func _walk(n: Node, out: Array) -> void:
	if n is CanvasLayer and n == self:
		return
	if _is_fit(n) or n is Label or n is RichTextLabel or n is Button:
		if n is Label and _is_fit(n.get_parent()):
			pass
		else:
			var c: Control = n
			if _visible_text(c):
				out.append({"node": c, "rect": c.get_global_rect(), "kind": _kind(c)})
	for child in n.get_children():
		_walk(child, out)


func _sprite_hits() -> Array:
	var out: Array = []
	var view: Rect2 = get_viewport().get_visible_rect()
	for n in get_tree().root.find_children("*", "CanvasItem", true, false):
		if n == self or (n is CanvasItem and n == _paint):
			continue
		if not (n is CanvasItem) or not (n as CanvasItem).is_visible_in_tree():
			continue
		if _faded(n):
			continue
		var rect := Rect2()
		var kind := ""
		if n is TextureRect:
			var tr: TextureRect = n
			if tr.texture == null:
				continue
			if tr.name == "Frame" and _is_fit(tr.get_parent()):
				continue
			rect = tr.get_global_rect()
			kind = "TextureRect"
		elif n is NinePatchRect:
			var np: NinePatchRect = n
			if np.texture == null or not np.visible:
				continue
			if np.name == "Frame" and _is_fit(np.get_parent()):
				continue
			rect = np.get_global_rect()
			kind = "NinePatchRect"
		elif n is Sprite2D:
			var sp: Sprite2D = n
			rect = _canvas_rect(sp)
			kind = "Sprite2D"
		elif n is AnimatedSprite2D:
			var an: AnimatedSprite2D = n
			rect = _canvas_rect(an)
			kind = "AnimatedSprite2D"
		elif n is ColorRect:
			var cr: ColorRect = n
			if cr.color.a < 0.35:
				continue
			rect = cr.get_global_rect()
			kind = "ColorRect"
		elif n is Panel:
			rect = (n as Panel).get_global_rect()
			kind = "Panel"
		elif n is CPUParticles2D or n is GPUParticles2D or _is_fx_draw(n):
			rect = _fx_rect(n)
			kind = "fx"
		else:
			continue
		rect = _apply_clips(n, rect)
		if rect.size.x < 8.0 or rect.size.y < 8.0:
			continue
		if rect.size.x >= view.size.x * 0.85 and rect.size.y >= view.size.y * 0.85:
			continue
		var vis: Rect2 = rect.intersection(view)
		if vis.size.x < 4.0 or vis.size.y < 4.0:
			continue
		if _behind_scrim(n, rect.get_center()):
			continue
		out.append({"node": n, "rect": rect, "kind": kind})
	return out


func _behind_scrim(node: Node, mid: Vector2) -> bool:
	var view: Rect2 = get_viewport().get_visible_rect()
	for c in get_tree().root.find_children("*", "ColorRect", true, false):
		if not (c is ColorRect) or c == _paint:
			continue
		var cr: ColorRect = c
		if not cr.is_visible_in_tree() or cr.modulate.a < 0.5 or cr.color.a < 0.5:
			continue
		if cr == node or cr.is_ancestor_of(node) or node.is_ancestor_of(cr):
			continue
		var r: Rect2 = cr.get_global_rect()
		if r.size.x < view.size.x * 0.85 or r.size.y < view.size.y * 0.85:
			continue
		if r.has_point(mid) and _drawn_in_front(cr, node):
			return true
	return false


func _drawn_in_front(a: Node, b: Node) -> bool:
	var seen := {}
	var n: Node = a
	while n:
		seen[n] = true
		n = n.get_parent()
	var child_b: Node = b
	while child_b.get_parent() and not seen.has(child_b.get_parent()):
		child_b = child_b.get_parent()
	var common: Node = child_b.get_parent()
	if common == null:
		return false
	var child_a: Node = a
	while child_a.get_parent() != common:
		child_a = child_a.get_parent()
		if child_a == null:
			return false
	if child_a is CanvasItem and child_b is CanvasItem:
		var za: int = (child_a as CanvasItem).z_index
		var zb: int = (child_b as CanvasItem).z_index
		if za != zb:
			return za > zb
	return child_a.get_index() > child_b.get_index()


func _is_fx_draw(n: Node) -> bool:
	if bool(n.get_meta("fx", false)):
		return true
	if n is TextureRect and bool(n.get_meta("fx", false)):
		return true
	var nm := str(n.name).to_lower()
	if nm == "fx" or nm.ends_with("fx") or nm.contains("particle"):
		return n is CanvasItem and n.has_method("_draw")
	return false


func _fx_rect(n: Node) -> Rect2:
	if n is GPUParticles2D:
		var gp: GPUParticles2D = n
		return _xform_local(gp, gp.visibility_rect)
	if n is CPUParticles2D:
		var cp: CPUParticles2D = n
		var ext := Vector2(48, 48)
		if cp.emission_shape == CPUParticles2D.EMISSION_SHAPE_RECTANGLE:
			ext = cp.emission_rect_extents
		elif cp.emission_shape == CPUParticles2D.EMISSION_SHAPE_SPHERE:
			ext = Vector2.ONE * cp.emission_sphere_radius
		return _xform_local(cp, Rect2(-ext, ext * 2.0))
	if n is Control:
		return (n as Control).get_global_rect()
	if n is Node2D:
		return _canvas_rect(n)
	return Rect2()


func _xform_local(ci: Node2D, r: Rect2) -> Rect2:
	var xf: Transform2D = ci.get_global_transform()
	var p1: Vector2 = xf * r.position
	var p2: Vector2 = xf * (r.position + Vector2(r.size.x, 0))
	var p3: Vector2 = xf * (r.position + Vector2(0, r.size.y))
	var p4: Vector2 = xf * r.end
	var tl := Vector2(minf(minf(p1.x, p2.x), minf(p3.x, p4.x)), minf(minf(p1.y, p2.y), minf(p3.y, p4.y)))
	var br := Vector2(maxf(maxf(p1.x, p2.x), maxf(p3.x, p4.x)), maxf(maxf(p1.y, p2.y), maxf(p3.y, p4.y)))
	return Rect2(tl, br - tl)


func _apply_clips(node: Node, rect: Rect2) -> Rect2:
	var out := rect
	var p: Node = node.get_parent()
	while p is Control:
		var pc: Control = p
		if pc.clip_contents:
			out = out.intersection(pc.get_global_rect())
		p = p.get_parent()
	return out


func _canvas_rect(ci: Node2D) -> Rect2:
	var r := Rect2()
	if ci is Sprite2D:
		r = (ci as Sprite2D).get_rect()
	elif ci is AnimatedSprite2D:
		var an: AnimatedSprite2D = ci
		if an.sprite_frames and an.sprite_frames.has_animation(an.animation):
			var tex: Texture2D = an.sprite_frames.get_frame_texture(an.animation, an.frame)
			if tex:
				var sz: Vector2 = tex.get_size()
				if an.centered:
					r = Rect2(-sz * 0.5, sz)
				else:
					r = Rect2(Vector2.ZERO, sz)
	var xf: Transform2D = ci.get_global_transform()
	var p1: Vector2 = xf * r.position
	var p2: Vector2 = xf * (r.position + Vector2(r.size.x, 0))
	var p3: Vector2 = xf * (r.position + Vector2(0, r.size.y))
	var p4: Vector2 = xf * r.end
	var tl := Vector2(minf(minf(p1.x, p2.x), minf(p3.x, p4.x)), minf(minf(p1.y, p2.y), minf(p3.y, p4.y)))
	var br := Vector2(maxf(maxf(p1.x, p2.x), maxf(p3.x, p4.x)), maxf(maxf(p1.y, p2.y), maxf(p3.y, p4.y)))
	return Rect2(tl, br - tl)


func _kind(c: Control) -> String:
	if c is Button:
		return "Button"
	if c is RichTextLabel:
		return "RichTextLabel"
	if c is Label:
		return "Label"
	return c.get_class()


func _visible_text(c: Control) -> bool:
	if c == null or not c.is_inside_tree():
		return false
	if not c.is_visible_in_tree():
		return false
	if c.size.x < 1.0 or c.size.y < 1.0:
		return false
	if _faded(c):
		return false
	var t: String = _text_of(c).strip_edges()
	if t == "":
		return false
	var rect: Rect2 = c.get_global_rect()
	var view: Rect2 = get_viewport().get_visible_rect()
	var vis: Rect2 = rect.intersection(view)
	if vis.size.x < 4.0 or vis.size.y < 4.0:
		return false
	if not _inside_clips(c, rect):
		return false
	if _hidden_by_screen(c, rect):
		return false
	return true


func _faded(c: CanvasItem) -> bool:
	var n: Node = c
	while n is CanvasItem:
		var ci: CanvasItem = n
		if ci.modulate.a < 0.2 or ci.self_modulate.a < 0.2:
			return true
		n = n.get_parent()
	return false


func _inside_clips(node: Control, rect: Rect2) -> bool:
	var p: Node = node.get_parent()
	while p is Control:
		var pc: Control = p
		if pc.clip_contents:
			var pr: Rect2 = pc.get_global_rect()
			if not pr.intersects(rect):
				return false
			var hit: Rect2 = rect.intersection(pr)
			if hit.size.x < 4.0 or hit.size.y < 4.0:
				return false
		p = p.get_parent()
	return true


func _hidden_by_screen(node: Control, rect: Rect2) -> bool:
	var mid: Vector2 = rect.get_center()
	var view: Rect2 = get_viewport().get_visible_rect()
	var cabin: Node = get_tree().root.get_node_or_null("Main/CabinRoot")
	if cabin is Control:
		var cc: Control = cabin
		if cc.visible and cc.is_visible_in_tree() and not cc.is_ancestor_of(node) and cc.get_global_rect().has_point(mid):
			return true
	var root: Node = get_tree().root.get_node_or_null("Main")
	if root:
		for child in root.get_children():
			if not (child is Control):
				continue
			var host: Control = child
			if host == node or host.is_ancestor_of(node) or not host.visible or not host.is_visible_in_tree():
				continue
			if host.modulate.a < 0.8:
				continue
			var r: Rect2 = host.get_global_rect()
			if r.size.x < view.size.x * 0.85 or r.size.y < view.size.y * 0.85:
				continue
			if host.mouse_filter == Control.MOUSE_FILTER_IGNORE:
				continue
			if r.has_point(mid):
				return true
	for ov in _overlay_rects():
		var host2: Control = ov["node"]
		if host2 == node or host2.is_ancestor_of(node):
			continue
		var ov_root: Node = host2.get_parent()
		if ov_root and (ov_root == node or ov_root.is_ancestor_of(node)):
			continue
		var r2: Rect2 = ov["rect"]
		if r2.size.x < view.size.x * 0.85:
			continue
		if r2.has_point(mid):
			return true
	return false


func _text_of(c: Control) -> String:
	if c is Button:
		return (c as Button).text
	if c is RichTextLabel:
		return (c as RichTextLabel).get_parsed_text()
	if c is Label:
		return (c as Label).text
	if _is_fit(c):
		return str(c.get("text"))
	return ""


func _flag(hits: Array, screen: String, shot: String) -> Array:
	var fails: Array = []
	var overlays: Array = _overlay_rects()
	var sprites: Array = _sprite_hits()
	var img: Image = _grab()
	for i in hits.size():
		var a: Dictionary = hits[i]
		var node: Control = a["node"]
		var rect: Rect2 = a["rect"]
		var path: String = str(node.get_path())
		var reasons: PackedStringArray = PackedStringArray()
		if _clipped(node, rect):
			reasons.append("clipped")
		if _ellipsis(node):
			reasons.append("ellipsis")
		if _overflow_parent(node, rect):
			reasons.append("overflow_parent")
		if _under_overlay(node, rect, overlays):
			reasons.append("under_overlay")
		if _below_min(node):
			reasons.append("below_min_size")
		if not _contrast_ok(node, rect, img):
			reasons.append("contrast")
		for wrap_reason in _wrap_reasons(node):
			reasons.append(wrap_reason)
		var glyph_font: Font = _font_of(node)
		for missing in preload("res://scripts/ui/arrow_glyphs.gd").missing_from(glyph_font, _text_of(node)):
			reasons.append("missing_glyph:%s" % missing)
		var overlapped := false
		for j in hits.size():
			if j <= i:
				continue
			var b: Dictionary = hits[j]
			var other: Control = b["node"]
			if _related(node, other):
				continue
			if rect.intersects(b["rect"]):
				var ov: Rect2 = rect.intersection(b["rect"])
				if ov.size.x >= 2.0 and ov.size.y >= 2.0:
					reasons.append("overlap:%s" % other.get_path())
					overlapped = true
					break
		if not overlapped:
			for sp in sprites:
				var spr: Node = sp["node"]
				if _related_node(node, spr):
					continue
				if rect.intersects(sp["rect"]):
					var hit: Rect2 = rect.intersection(sp["rect"])
					var backdrop: bool = (sp is ColorRect or sp is Panel or sp is NinePatchRect) and sp["rect"].encloses(rect)
					if hit.size.x >= 2.0 and hit.size.y >= 2.0 and not backdrop and not _on_own_panel(node, spr):
						reasons.append("overlap:%s" % spr.get_path())
						break
		if reasons.is_empty():
			continue
		fails.append({
			"screen": screen,
			"path": path,
			"reason": ", ".join(reasons),
			"shot": shot,
			"kind": a["kind"],
			"text": _text_of(node).substr(0, 80),
		})
	return fails


func _on_own_panel(text: Control, sprite: Node) -> bool:
	var p: Node = text.get_parent()
	while p:
		if (p is Panel or p is NinePatchRect or p is ColorRect) and p is Control:
			var host: Control = p
			if host.is_visible_in_tree() and not host.is_ancestor_of(sprite) and sprite != host:
				var pr: Rect2 = host.get_global_rect()
				var tr: Rect2 = text.get_global_rect()
				if pr.encloses(tr) and _drawn_in_front(host, sprite):
					return true
		p = p.get_parent()
	return false


func _related_node(a: Node, b: Node) -> bool:
	if a == b:
		return true
	if a.is_ancestor_of(b) or b.is_ancestor_of(a):
		return true
	if a.get_parent() == b or b.get_parent() == a:
		return true
	return false


func _related(a: Control, b: Control) -> bool:
	if a == b:
		return true
	if a.is_ancestor_of(b) or b.is_ancestor_of(a):
		return true
	if a.get_parent() == b or b.get_parent() == a:
		return true
	return false


func _clipped(node: Control, rect: Rect2) -> bool:
	var p: Node = node.get_parent()
	while p is Control:
		var pc: Control = p
		if pc.clip_contents:
			var pr: Rect2 = pc.get_global_rect()
			if not pr.encloses(rect) and pr.intersects(rect):
				var clipped: Rect2 = rect.intersection(pr)
				if clipped.size.x + 3.0 < rect.size.x or clipped.size.y + 3.0 < rect.size.y:
					return true
		p = p.get_parent()
	if node is Label:
		var lab: Label = node
		if lab.clip_text and _content_size(lab).x > lab.size.x + 4.0:
			return true
	if node is RichTextLabel:
		var rtl: RichTextLabel = node
		if rtl.get_content_height() > int(rtl.size.y) + 2 and not rtl.scroll_active:
			return true
	return false


func _ellipsis(node: Control) -> bool:
	var plan: Variant = node.get_meta("fit_plan", {})
	if typeof(plan) == TYPE_DICTIONARY and bool(plan.get("ellipsis", false)):
		return true
	if node is Label:
		var lab: Label = node
		if lab.text_overrun_behavior != TextServer.OVERRUN_TRIM_ELLIPSIS:
			return false
		var need: Vector2 = _content_size(lab)
		if need.x > lab.size.x + 1.0:
			return true
		if lab.max_lines_visible > 0 and lab.get_line_count() > lab.max_lines_visible:
			return true
	if _is_fit(node):
		return bool(node.get("last_fit").get("ellipsis", false))
	return false


func _overflow_parent(node: Control, rect: Rect2) -> bool:
	var p: Node = node.get_parent()
	if not (p is Control):
		return false
	var pc: Control = p
	if _is_fit(pc):
		return false
	var pr: Rect2 = pc.get_global_rect()
	if pr.size.x < 2.0 or pr.size.y < 2.0:
		return false
	return rect.position.x + 1.0 < pr.position.x or rect.position.y + 1.0 < pr.position.y or rect.end.x > pr.end.x + 1.0 or rect.end.y > pr.end.y + 1.0


func _under_overlay(node: Control, rect: Rect2, overlays: Array) -> bool:
	var mid: Vector2 = rect.get_center()
	var view_w: float = get_viewport().get_visible_rect().size.x
	for ov in overlays:
		var host: Control = ov["node"]
		if host == node or host.is_ancestor_of(node) or node.is_ancestor_of(host):
			continue
		var r: Rect2 = ov["rect"]
		if r.size.x >= view_w * 0.85:
			continue
		if r.has_point(mid) and int(host.z_index) >= int(node.z_index):
			return true
	return false


func _overlay_rects() -> Array:
	var out: Array = []
	for n in get_tree().root.find_children("*", "Control", true, false):
		if not (n is Control):
			continue
		var c: Control = n
		if not c.is_visible_in_tree():
			continue
		if c == _paint:
			continue
		var nm: String = c.name.to_lower()
		var overlayish: bool = nm == "veil" or nm == "scrim" or nm == "overlay" or nm.ends_with("overlay")
		if not overlayish:
			continue
		if c.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			continue
		var r: Rect2 = c.get_global_rect()
		if r.size.x < 200.0 or r.size.y < 200.0:
			continue
		out.append({"node": c, "rect": r})
	return out


func _below_min(node: Control) -> bool:
	var min_px: int = MIN_DEFAULT
	if node.has_meta("fit_min"):
		min_px = int(node.get_meta("fit_min"))
	var sz: int = _font_size(node)
	if sz <= 0:
		return false
	return sz < min_px


func _font_size(node: Control) -> int:
	if node is Label:
		if (node as Label).has_theme_font_size_override("font_size"):
			return (node as Label).get_theme_font_size("font_size")
		return (node as Label).get_theme_font_size("font_size")
	if node is Button:
		return (node as Button).get_theme_font_size("font_size")
	if node is RichTextLabel:
		return (node as RichTextLabel).get_theme_font_size("normal_font_size")
	if _is_fit(node):
		var lab: Label = node.get_node_or_null("Label")
		if lab:
			return lab.get_theme_font_size("font_size")
	return 0


## Visible Label / RichTextLabel / Button only. Reason codes: "wrap_mode:<mode>", "mid_word".
func _wrap_reasons(node: Control) -> PackedStringArray:
	var out := PackedStringArray()
	var measured := _measured_text_control(node)
	if not (measured is Label or measured is RichTextLabel or measured is Button):
		return out
	var mode := _autowrap_of(measured)
	if mode != TextServer.AUTOWRAP_OFF and mode != TextServer.AUTOWRAP_WORD_SMART:
		out.append("wrap_mode:%s" % _autowrap_name(mode))
	if _has_mid_word_break(measured):
		out.append("mid_word")
	return out


func _measured_text_control(node: Control) -> Control:
	if _is_fit(node):
		var inner: Label = node.get_node_or_null("Label")
		if inner:
			return inner
	return node


func _autowrap_of(node: Control) -> int:
	if "autowrap_mode" in node:
		return int(node.get("autowrap_mode"))
	return TextServer.AUTOWRAP_OFF


func _autowrap_name(mode: int) -> String:
	match mode:
		TextServer.AUTOWRAP_OFF:
			return "AUTOWRAP_OFF"
		TextServer.AUTOWRAP_ARBITRARY:
			return "AUTOWRAP_ARBITRARY"
		TextServer.AUTOWRAP_WORD:
			return "AUTOWRAP_WORD"
		TextServer.AUTOWRAP_WORD_SMART:
			return "AUTOWRAP_WORD_SMART"
		_:
			return str(mode)


func _break_flags_for(mode: int) -> int:
	var flags := TextServer.BREAK_MANDATORY
	match mode:
		TextServer.AUTOWRAP_WORD_SMART:
			flags = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_MANDATORY
		TextServer.AUTOWRAP_WORD:
			flags = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY
		TextServer.AUTOWRAP_ARBITRARY:
			flags = TextServer.BREAK_GRAPHEME_BOUND | TextServer.BREAK_MANDATORY
		_:
			flags = TextServer.BREAK_MANDATORY
	if mode != TextServer.AUTOWRAP_OFF:
		flags |= TextServer.BREAK_TRIM_EDGE_SPACES
	return flags


func _has_mid_word_break(node: Control) -> bool:
	var text := _text_of(node)
	if text.length() < 2:
		return false
	var mode := _autowrap_of(node)
	var font := _font_of(node)
	var px := _font_size(node)
	if px <= 0:
		px = 16
	var para := TextParagraph.new()
	para.break_flags = _break_flags_for(mode)
	para.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	para.max_lines_visible = 0
	if mode == TextServer.AUTOWRAP_OFF:
		para.width = -1
	else:
		para.width = _wrap_width(node)
	para.add_string(text, font, px)
	var lines := para.get_line_count()
	if lines <= 1:
		return false
	var shown := lines
	if _overrun_trims(node):
		shown = mini(lines, _visible_line_budget(node, font, px))
	if shown <= 1:
		return false
	for i in shown - 1:
		var nxt: Vector2i = para.get_line_range(i + 1)
		if _chars_split_word(text, nxt.x):
			return true
	return false


func _overrun_trims(node: Control) -> bool:
	if not ("text_overrun_behavior" in node):
		return false
	var behavior := int(node.get("text_overrun_behavior"))
	return behavior != TextServer.OVERRUN_NO_TRIMMING


func _visible_line_budget(node: Control, font: Font, px: int) -> int:
	var spacing := 0
	if node is CanvasItem:
		spacing = int(node.get_theme_constant("line_spacing"))
	var line_h := float(font.get_height(px)) + float(spacing)
	var h := _control_box(node).y
	var fit := int(floor(h / maxf(line_h, 1.0)))
	fit = maxi(fit, 1)
	if "max_lines_visible" in node:
		var cap := int(node.get("max_lines_visible"))
		if cap > 0:
			fit = mini(fit, cap)
	return fit


func _control_box(node: Control) -> Vector2:
	var s := node.size
	if s.x < 1.0 or s.y < 1.0:
		s = node.custom_minimum_size
	return s


func _wrap_width(node: Control) -> float:
	var w := _control_box(node).x
	if node is Button:
		var sb: StyleBox = (node as Button).get_theme_stylebox("normal")
		if sb:
			w -= sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT)
	return maxf(w, 1.0)


func _font_of(node: Control) -> Font:
	var font: Font = null
	if node is RichTextLabel:
		font = (node as RichTextLabel).get_theme_font("normal_font")
	elif node is Label or node is Button:
		font = node.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	return font


func _chars_split_word(text: String, next_start: int) -> bool:
	if next_start <= 0 or next_start >= text.length():
		return false
	var before := text.substr(next_start - 1, 1)
	var after := text.substr(next_start, 1)
	if _is_break_sep(before) or _is_break_sep(after):
		return false
	return _is_word_char(before) and _is_word_char(after)


func _is_break_sep(ch: String) -> bool:
	if ch == " " or ch == "\t" or ch == "\n" or ch == "\r":
		return true
	var c := ch.unicode_at(0)
	return c == 0x2D or c == 0xAD or c == 0x2010 or c == 0x2011 or c == 0x2012 or c == 0x2013 or c == 0x2014


func _is_word_char(ch: String) -> bool:
	if ch.is_empty():
		return false
	var c := ch.unicode_at(0)
	if c >= 0x30 and c <= 0x39:
		return true
	return ch.to_lower() != ch.to_upper()


func _content_size(lab: Label) -> Vector2:
	var font: Font = lab.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var px: int = lab.get_theme_font_size("font_size")
	if lab.autowrap_mode != TextServer.AUTOWRAP_OFF:
		return font.get_multiline_string_size(lab.text, lab.horizontal_alignment, lab.size.x, px)
	return font.get_string_size(lab.text, lab.horizontal_alignment, -1, px)


func _contrast_ok(node: Control, rect: Rect2, img: Image) -> bool:
	if img == null or img.is_empty():
		return true
	if node is Label and (node as Label).get_theme_constant("outline_size") >= 2:
		return true
	if node is Button:
		if (node as Button).get_theme_constant("outline_size") >= 2:
			return true
		var sb: StyleBox = (node as Button).get_theme_stylebox("normal")
		if sb is StyleBoxTexture:
			return true
	if _is_fit(node):
		var lab: Label = node.get_node_or_null("Label")
		if lab and lab.get_theme_constant("outline_size") >= 2:
			return true
	var ink: Color = _ink_of(node)
	var bg: Color = _sample(img, rect, ink)
	if bg.a <= 0.0:
		return true
	return _ratio(ink, bg) >= CONTRAST


func _ink_of(node: Control) -> Color:
	if node is Label:
		return (node as Label).get_theme_color("font_color")
	if node is Button:
		return (node as Button).get_theme_color("font_color")
	if node is RichTextLabel:
		return (node as RichTextLabel).get_theme_color("default_color")
	if _is_fit(node):
		return node.get("font_color")
	return Color.WHITE


func _sample(img: Image, rect: Rect2, ink: Color = Color.WHITE) -> Color:
	var acc := Color(0, 0, 0, 0)
	var n := 0
	var pts := PackedVector2Array()
	for i in 12:
		var a: float = float(i) / 12.0 * TAU
		pts.append(rect.get_center() + Vector2(cos(a), sin(a)) * Vector2(rect.size.x * 0.38, rect.size.y * 0.38))
	pts.append(rect.position + Vector2(3, 3))
	pts.append(Vector2(rect.end.x - 3.0, rect.position.y + 3.0))
	pts.append(Vector2(rect.position.x + 3.0, rect.end.y - 3.0))
	pts.append(Vector2(rect.end.x - 3.0, rect.end.y - 3.0))
	for p in pts:
		var x: int = clampi(int(p.x), 0, img.get_width() - 1)
		var y: int = clampi(int(p.y), 0, img.get_height() - 1)
		var col: Color = img.get_pixel(x, y)
		if col.a < 0.2:
			continue
		if absf(col.r - ink.r) + absf(col.g - ink.g) + absf(col.b - ink.b) < 0.45:
			continue
		acc += col
		n += 1
	if n <= 0:
		return Color(0, 0, 0, 0)
	return acc / float(n)


func _ratio(a: Color, b: Color) -> float:
	var l1: float = _lum(a)
	var l2: float = _lum(b)
	var hi: float = maxf(l1, l2)
	var lo: float = minf(l1, l2)
	return (hi + 0.05) / (lo + 0.05)


func _lum(c: Color) -> float:
	return 0.2126 * _chan(c.r) + 0.7152 * _chan(c.g) + 0.0722 * _chan(c.b)


func _chan(v: float) -> float:
	if v <= 0.03928:
		return v / 12.92
	return pow((v + 0.055) / 1.055, 2.4)


func _grab() -> Image:
	var tex: ViewportTexture = get_viewport().get_texture()
	if tex == null:
		return null
	return tex.get_image()


func _write(fails: Array) -> void:
	var pack := {
		"updated": Time.get_datetime_string_from_system(),
		"screen": last_screen,
		"shot": last_shot,
		"failures": fails,
	}
	var raw: String = JSON.stringify(pack, "\t")
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f:
		f.store_string(raw)
	var copy_path := copy_dir.path_join("text_audit.json") if copy_dir.begins_with("res://") else COPY_PATH
	var abs_copy: String = ProjectSettings.globalize_path(copy_path)
	DirAccess.make_dir_recursive_absolute(abs_copy.get_base_dir())
	var g := FileAccess.open(copy_path, FileAccess.WRITE)
	if g:
		g.store_string(raw)


func _on_draw() -> void:
	if not enabled:
		return
	for hit in _hits:
		var rect: Rect2 = hit["rect"]
		var node: Control = hit["node"]
		var bad: bool = false
		for fail in last_failures:
			if str(fail.get("path", "")) == str(node.get_path()):
				bad = true
				break
		var col: Color = Color(1, 0.15, 0.1, 0.9) if bad else Color(0.2, 0.85, 0.35, 0.7)
		_paint.draw_rect(rect, Color(col.r, col.g, col.b, 0.12), true)
		_paint.draw_rect(rect, col, false, 2.0)
