extends Object
class_name TextReserve
## Each text control keeps a rect that does not cover a sibling portrait, sprite, or other text.


static func settle(root: Node) -> void:
	if root == null:
		return
	var texts: Array = []
	_gather(root, texts)
	for node in texts:
		if node is Control:
			_yield(node as Control)


static func _gather(n: Node, out: Array) -> void:
	if n is FitLabelBox or n is RichTextLabel or (n is Label and not (n.get_parent() is FitLabelBox)):
		out.append(n)
	for c in n.get_children():
		_gather(c, out)


static func _yield(node: Control) -> void:
	var parent: Node = node.get_parent()
	if not (parent is Control):
		return
	var origin: Vector2 = (parent as Control).get_global_rect().position
	var r: Rect2 = node.get_global_rect()
	if r.size.x < 4.0 or r.size.y < 4.0:
		return
	var changed := false
	for s in parent.get_children():
		if s == node or not (s is CanvasItem):
			continue
		if not (s as CanvasItem).is_visible_in_tree():
			continue
		if not _blocks(s):
			continue
		var sr: Rect2 = _global_rect(s)
		if sr.size.x < 4.0 or sr.size.y < 4.0:
			continue
		if sr.size.x >= r.size.x * 0.92 and sr.size.y >= r.size.y * 0.92 and sr.encloses(r):
			continue
		if not r.intersects(sr):
			continue
		var hit: Rect2 = r.intersection(sr)
		if hit.size.x < 2.0 or hit.size.y < 2.0:
			continue
		var next: Rect2 = _cut(r, sr)
		if next.size.x < 8.0 or next.size.y < 8.0:
			continue
		r = next
		changed = true
	if not changed:
		return
	node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	node.position = r.position - origin
	node.size = r.size
	if node is FitLabelBox:
		(node as FitLabelBox).fit()


static func _blocks(n: Node) -> bool:
	if n is FitLabelBox or n is Label or n is RichTextLabel or n is Button:
		if n is Label and n.get_parent() is FitLabelBox:
			return false
		if n is Button and str((n as Button).text).strip_edges() == "":
			return false
		return true
	if n is TextureRect:
		return (n as TextureRect).texture != null
	if n is NinePatchRect:
		var np: NinePatchRect = n
		if np.name == "Frame" and np.get_parent() is FitLabelBox:
			return false
		return np.texture != null and np.visible
	if n is Sprite2D or n is AnimatedSprite2D:
		return true
	return false


static func _global_rect(n: Node) -> Rect2:
	if n is Control:
		return (n as Control).get_global_rect()
	if n is Node2D:
		var local: Rect2 = _node2d_rect(n as Node2D)
		var xf: Transform2D = (n as Node2D).get_global_transform()
		var p1: Vector2 = xf * local.position
		var p2: Vector2 = xf * local.end
		var tl := Vector2(minf(p1.x, p2.x), minf(p1.y, p2.y))
		var br := Vector2(maxf(p1.x, p2.x), maxf(p1.y, p2.y))
		return Rect2(tl, br - tl)
	return Rect2()


static func _node2d_rect(ci: Node2D) -> Rect2:
	var r := Rect2()
	if ci is Sprite2D:
		r = (ci as Sprite2D).get_rect()
	elif ci is AnimatedSprite2D:
		var an: AnimatedSprite2D = ci
		if an.sprite_frames and an.sprite_frames.has_animation(an.animation):
			var tex: Texture2D = an.sprite_frames.get_frame_texture(an.animation, an.frame)
			if tex:
				var sz: Vector2 = tex.get_size() * an.scale
				r = Rect2(Vector2.ZERO, sz) if not an.centered else Rect2(-sz * 0.5, sz)
	return r


static func _cut(host: Rect2, block: Rect2) -> Rect2:
	var hit: Rect2 = host.intersection(block)
	if hit.size.x < 2.0 or hit.size.y < 2.0:
		return host
	# Prefer the cut that removes the smaller strip.
	var from_left: float = hit.end.x - host.position.x
	var from_right: float = host.end.x - hit.position.x
	var from_top: float = hit.end.y - host.position.y
	var from_bot: float = host.end.y - hit.position.y
	var horizontal: bool = minf(from_left, from_right) <= minf(from_top, from_bot)
	if horizontal:
		if from_left <= from_right:
			return Rect2(hit.end.x, host.position.y, host.end.x - hit.end.x, host.size.y)
		return Rect2(host.position.x, host.position.y, hit.position.x - host.position.x, host.size.y)
	if from_top <= from_bot:
		return Rect2(host.position.x, hit.end.y, host.size.x, host.end.y - hit.end.y)
	return Rect2(host.position.x, host.position.y, host.size.x, hit.position.y - host.position.y)
