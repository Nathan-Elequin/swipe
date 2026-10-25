extends RefCounted
class_name CombatFxBudget
## Shared combat animation budget (SP-30).
## The web export freezes when Sprout's item-use frames overlap a facing
## portrait idle, a full-wheel redraw, and the tiled hall — all of those
## were `queue_redraw()` every process tick. Heavy FX (item use, slash,
## lunge, hit) pauses low-priority idles; web also caps decorative redraws.
## Not an AnimationPlayer / Tween bug. SP-03 (Undo freeze) is separate.

static var _heavy: int = 0


static func is_web() -> bool:
	return OS.has_feature("web")


static func begin_heavy() -> void:
	_heavy += 1


static func end_heavy() -> void:
	_heavy = maxi(0, _heavy - 1)


static func reset() -> void:
	_heavy = 0


static func heavy_count() -> int:
	return _heavy


static func heavy() -> bool:
	return _heavy > 0


static func is_heavy_state(state: String) -> bool:
	match state:
		"use", "attack", "grab", "heal", "swipe", "hit", "block", "run":
			return true
		_:
			return false


## Pause off-facing / low-priority loops while a heavy combat FX is playing.
static func hold_low_priority_idles() -> bool:
	return _heavy > 0


## Decorative redraws per second. 0 = uncapped (desktop, no heavy FX).
static func decorative_fps() -> float:
	if _heavy > 0:
		return 8.0
	if is_web():
		return 12.0
	return 0.0


## Seconds between decorative redraws. 0 = draw every process frame.
static func decor_step() -> float:
	var fps: float = decorative_fps()
	if fps <= 0.0:
		return 0.0
	return 1.0 / fps
