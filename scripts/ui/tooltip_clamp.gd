extends RefCounted
class_name TooltipClamp
## Keeps a tooltip inside the 32px screen margin, off the hovered control, and off the log.


const SAFE := 32.0


static func bounds(vp: Vector2) -> Rect2:
	return Rect2(SAFE, SAFE, maxf(8.0, vp.x - SAFE * 2.0), maxf(8.0, vp.y - SAFE * 2.0))


static func place(vp: Vector2, sz: Vector2, candidates: Array, blocks: Array) -> Vector2:
	var box := bounds(vp)
	for c in candidates:
		if typeof(c) != TYPE_VECTOR2:
			continue
		var fitted: Vector2 = _fit(c, sz, box, blocks)
		if fitted.x < 100000.0:
			return fitted
	var fallback := Vector2.ZERO
	if candidates.size() > 0 and typeof(candidates[0]) == TYPE_VECTOR2:
		fallback = candidates[0]
	var pos := _clamp(fallback, sz, box)
	for b in blocks:
		if typeof(b) != TYPE_RECT2:
			continue
		var br: Rect2 = b
		if br.size.x < 1.0 or br.size.y < 1.0:
			continue
		var tip := Rect2(pos, sz)
		if not tip.intersects(br):
			continue
		var options: Array = [
			Vector2(br.position.x - sz.x - 12.0, pos.y),
			Vector2(br.end.x + 12.0, pos.y),
			Vector2(pos.x, br.position.y - sz.y - 12.0),
			Vector2(pos.x, br.end.y + 12.0),
		]
		var moved := false
		for opt in options:
			var trial: Vector2 = _fit(opt, sz, box, blocks)
			if trial.x < 100000.0:
				pos = trial
				moved = true
				break
		if not moved:
			pos = _clamp(Vector2(br.position.x - sz.x - 12.0, pos.y), sz, box)
	return pos


static func _fit(pos: Vector2, sz: Vector2, box: Rect2, blocks: Array) -> Vector2:
	var p := _clamp(pos, sz, box)
	var tip := Rect2(p, sz)
	if tip.end.x > box.end.x + 0.5 or tip.end.y > box.end.y + 0.5:
		return Vector2(INF, INF)
	if tip.position.x < box.position.x - 0.5 or tip.position.y < box.position.y - 0.5:
		return Vector2(INF, INF)
	for b in blocks:
		if typeof(b) != TYPE_RECT2:
			continue
		var br: Rect2 = b
		if br.size.x < 1.0 or br.size.y < 1.0:
			continue
		if tip.intersects(br):
			return Vector2(INF, INF)
	return p


static func _clamp(pos: Vector2, sz: Vector2, box: Rect2) -> Vector2:
	return Vector2(
		clampf(pos.x, box.position.x, maxf(box.position.x, box.end.x - sz.x)),
		clampf(pos.y, box.position.y, maxf(box.position.y, box.end.y - sz.y))
	)
