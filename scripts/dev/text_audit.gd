extends CanvasLayer
## Dev-only text collision overlay. F9 toggles. Shot harness writes user://text_audit.json.

const OUT_PATH := "user://text_audit.json"
const COPY_PATH := "res://design/audit-shots/cursor/text_audit.json"
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


func _walk(n: Node, out: Array) -> void:
	if n is CanvasLayer and n == self:
		return
	if n is FitLabelBox or n is Label or n is RichTextLabel or n is Button:
		if n is Label and n.get_parent() is FitLabelBox:
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
			if tr.name == "Frame" and tr.get_parent() is FitLabelBox:
				continue
			rect = tr.get_global_rect()
			kind = "TextureRect"
		elif n is NinePatchRect:
			var np: NinePatchRect = n
			if np.texture == null or not np.visible:
				continue
			if np.name == "Frame" and np.get_parent() is FitLabelBox:
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
		else:
			continue
		if rect.size.x < 8.0 or rect.size.y < 8.0:
			continue
		if rect.size.x >= view.size.x * 0.5 or rect.size.y >= view.size.y * 0.5:
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
	if c is FitLabelBox:
		return (c as FitLabelBox).text
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
					if hit.size.x >= 2.0 and hit.size.y >= 2.0:
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
	if node is FitLabelBox:
		return bool((node as FitLabelBox).last_fit.get("ellipsis", false))
	return false


func _overflow_parent(node: Control, rect: Rect2) -> bool:
	var p: Node = node.get_parent()
	if not (p is Control):
		return false
	var pc: Control = p
	if pc is FitLabelBox:
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
	if node is FitLabelBox:
		var lab: Label = node.get_node_or_null("Label")
		if lab:
			return lab.get_theme_font_size("font_size")
	return 0


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
	if node is FitLabelBox:
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
	if node is FitLabelBox:
		return (node as FitLabelBox).font_color
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
	var abs_copy: String = ProjectSettings.globalize_path(COPY_PATH)
	DirAccess.make_dir_recursive_absolute(abs_copy.get_base_dir())
	var g := FileAccess.open(COPY_PATH, FileAccess.WRITE)
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
