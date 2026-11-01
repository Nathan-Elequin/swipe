extends RefCounted
class_name ViewFrame
## Keeps combat and cabin inside the designed 1680×1040 frame on wide viewports.

const DESIGN := Vector2(1680, 1040)
const MARGIN := 8.0
## Combat log overlay (left gutter). Callout uses the matching right gutter.
const LOG_W := 240.0
const LOG_BTN_GAP := 8.0
const CALLOUT_RIGHT_MARGIN := 12.0
const ARROW_CALLOUT_GAP := 16.0
## Retired #199 left-nudge. Wheel / arrows / hotbar are dead-centered now.
const COMBAT_CLUSTER_LEFT_FRAC := 0.0
const SHOT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 800),
	Vector2i(1920, 1080),
	Vector2i(2560, 1080),
	Vector2i(3440, 1440),
]


static func design_size() -> Vector2:
	return DESIGN


static func combat_cluster_left_nudge(view_w: float = 0.0) -> float:
	var w: float = view_w if view_w > 1.0 else DESIGN.x
	return w * COMBAT_CLUSTER_LEFT_FRAC


static func frame_rect(view: Vector2) -> Rect2:
	var w: float = minf(DESIGN.x, maxf(1.0, view.x))
	var h: float = minf(DESIGN.y, maxf(1.0, view.y))
	var x: float = maxf(0.0, (view.x - w) * 0.5)
	var y: float = maxf(0.0, (view.y - h) * 0.5)
	return Rect2(Vector2(x, y), Vector2(w, h))


static func mirror_axis_x(view: Vector2) -> float:
	return maxf(1.0, view.x)


static func clamp_x(x: float, width: float, view: Vector2) -> float:
	var span: float = maxf(MARGIN, view.x - width - MARGIN)
	return clampf(x, MARGIN, span)


static func sprout_home_x(monster_center_x: float, sprout_w: float, view: Vector2) -> float:
	var raw: float = mirror_axis_x(view) - monster_center_x - sprout_w * 0.5
	return clamp_x(raw, sprout_w, view)


static func actor_fully_on_screen(pos: Vector2, size: Vector2, view: Vector2) -> bool:
	if size.x <= 0.0 or size.y <= 0.0:
		return false
	var box := Rect2(pos, size)
	var vis := Rect2(Vector2.ZERO, view)
	return vis.encloses(box)


static func next_room_hidden(view: Vector2, clip: Rect2, room_w: float = DESIGN.x) -> bool:
	if clip.size.x <= 0.0:
		return false
	return clip.size.x <= room_w + 0.5 and clip.size.x <= view.x + 0.5
