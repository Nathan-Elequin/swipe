extends RefCounted
class_name CombatFxBudget
## Shared combat animation budget (SP-30).
## The web export freezes when Sprout's item-use frames overlap a facing
## portrait idle, a full-wheel redraw, and the tiled hall — all of those
## were `queue_redraw()` every process tick. Heavy FX (item use, slash,
## lunge, hit, hub swipe/grab) pauses low-priority idles; decorative
## redraws are capped on web and on desktop fight-idle (Mac fight_idle
## was ~31 FPS / ~937 draws / wheel every frame when desktop rest was
## uncapped). Attack path (Mac attack_x5 @ 77610e7c: heavy ~80%, p95
## ~87 ms) widens that pause set and uses a stricter decorative ceiling
## so hall / hotbar shimmer / seat idles / residual stage bob do not
## compete with the slash banner + hit read. Hub `play_hero` owns combat
## Sprout FX after the left face-off strip; player_stage stays dark.
## Not an AnimationPlayer / Tween bug. SP-03 (Undo freeze) is separate.

static var _heavy: int = 0
## Wheel mid-spin. Hall torch flicker and other low-priority decor back off
## so they do not compete with spin redraws (Mac spin_x5 hall+wheel coupling).
static var _spinning: bool = false


static func is_web() -> bool:
	return OS.has_feature("web")


static func begin_heavy() -> void:
	_heavy += 1


static func end_heavy() -> void:
	_heavy = maxi(0, _heavy - 1)


static func set_spinning(v: bool) -> void:
	_spinning = v


static func is_spinning() -> bool:
	return _spinning


static func reset() -> void:
	_heavy = 0
	_spinning = false


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
## Attack + slash banner widen this: hall flicker, hotbar shimmer, seat
## idles, non-essential stage bob / residual splatters, and decorative-only
## wheel live-draws all consult this (or `decorative_fps`) and back off.
static func hold_low_priority_idles() -> bool:
	return _heavy > 0


## Decorative redraws per second. Heavy FX (attack/slash) is stricter so
## the banner + hit stay readable; rest uses the same 12fps ceiling as web
## (desktop fight-idle used to return 0 = uncapped).
static func decorative_fps() -> float:
	if _heavy > 0:
		# Was 8; attack_x5 still spent ~80% of frames heavy with residual
		# wheel/stage decor competing. 4fps is enough for seat freeze /
		# shimmer hold to read as paused, not as hitch.
		return 4.0
	# Web rest + desktop fight-idle rest. Spin redraws come from boss_wheel's
	# `rot` setter (fit cached in base space); not from this decorative path.
	return 12.0


## Seconds between decorative redraws. 0 = draw every process frame.
static func decor_step() -> float:
	var fps: float = decorative_fps()
	if fps <= 0.0:
		return 0.0
	return 1.0 / fps
