extends Control
## Left-stage Sprout (retired for combat). Fight anims play in the wheel hub.
## Kept for legacy callers / hide paths; stays invisible during fights.

const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

var art
var hp: int = 6
var hp_max: int = 6
var _heavy_token: bool = false

var _state: String = ""
var _frames: Array = []
var _frame: int = 0
var _t: float = 0.0
var _loops_left: int = 0
var _hold: bool = false
var _blinking: bool = false
var _blink_t: float = 5.0
var _blue: float = 0.0
var _pending_hide: bool = false
## Displayed height of Sprout's solid pixels. Main sets this to a medium monster (Goblin / Bandit).
var body_px: float = 184.0
var _opaque: Dictionary = {}

const FRAME_SEC := 0.18
const FOOT_PAD := 18.0

var face_left: bool = false
## While a run tween owns global x, layout may still set y.
var traveling: bool = false


func setup(p_art) -> void:
	art = p_art
	texture_filter = TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	top_level = true
	z_index = 15
	visible = false
	set_process(false)


func _exit_tree() -> void:
	_set_heavy(false)


func _set_heavy(on: bool) -> void:
	if on == _heavy_token:
		return
	_heavy_token = on
	if on:
		FX_BUDGET.begin_heavy()
	else:
		FX_BUDGET.end_heavy()


func play(state: String, loops: int = 1) -> void:
	_set_heavy(FX_BUDGET.is_heavy_state(state))
	_pending_hide = false
	_blinking = false
	_hold = false
	_blue = 0.0
	_state = state
	_frames = _frames_for(state)
	_frame = 0
	_t = 0.0
	_loops_left = maxi(1, loops)
	if state == "defeat":
		_loops_left = 1
	visible = true
	set_process(true)
	queue_redraw()


func note_hp() -> void:
	if _blinking or (_state != "idle" and _state != "lowhp"):
		return
	var nxt := "lowhp" if _is_low() else "idle"
	if nxt != _state:
		idle()


func idle() -> void:
	_set_heavy(false)
	var nxt := "lowhp" if _is_low() else "idle"
	_pending_hide = false
	_blinking = false
	_hold = false
	_state = nxt
	_frames = _frames_for(nxt)
	_frame = 0
	_t = 0.0
	_loops_left = 0
	_blink_t = randf_range(4.0, 6.0)
	visible = true
	set_process(true)
	queue_redraw()


func hide_stage() -> void:
	if _state == "victory":
		_pending_hide = true
		return
	if _state == "defeat":
		if not _pending_hide:
			_pending_hide = true
			return
		_finish_hide()
		return
	_finish_hide()


func _finish_hide() -> void:
	_set_heavy(false)
	visible = false
	_state = ""
	_frames = []
	_frame = 0
	_hold = false
	_blinking = false
	_pending_hide = false
	_blue = 0.0
	set_process(false)
	queue_redraw()


func _is_low() -> bool:
	if hp <= 0:
		return false
	if hp <= 3:
		return true
	return hp_max > 0 and float(hp) / float(hp_max) <= 0.30


func _frames_for(state: String) -> Array:
	var frames: Array = []
	if art != null and art.has_method("sprout_anim"):
		frames = art.sprout_anim(state)
	if not frames.is_empty():
		return frames
	if state == "block":
		_blue = 0.28
		if art == null:
			return []
		return art.sprout_anim("idle")
	if state == "use" or state == "heal":
		if art == null:
			return []
		return art.sprout_anim("grab")
	if state == "lowhp":
		if art == null:
			return []
		return art.sprout_anim("idle")
	return []


func _process(delta: float) -> void:
	if _blue > 0.0:
		_blue = maxf(0.0, _blue - delta)
		queue_redraw()
	if not visible or _hold or _frames.is_empty():
		return
	if _state == "idle" and not _blinking:
		_blink_t -= delta
		if _blink_t <= 0.0:
			_blink_t = randf_range(4.0, 6.0)
			var blink: Array = []
			if art != null:
				blink = art.sprout_anim("blink")
			if not blink.is_empty():
				_blinking = true
				_frames = blink
				_frame = 0
				_t = 0.0
	_t += delta
	if _t < FRAME_SEC:
		return
	_t = 0.0
	_frame += 1
	if _frame < _frames.size():
		queue_redraw()
		return
	if _blinking:
		_blinking = false
		idle()
		return
	if _state == "idle" or _state == "lowhp":
		_frame = 0
		queue_redraw()
		return
	_loops_left -= 1
	if _loops_left > 0:
		_frame = 0
		queue_redraw()
		return
	if _state == "defeat":
		_frame = _frames.size() - 1
		_hold = true
		queue_redraw()
		return
	if _pending_hide:
		_finish_hide()
		return
	idle()


func set_body_px(v: float) -> void:
	var n: float = maxf(32.0, v)
	if is_equal_approx(body_px, n):
		return
	body_px = n
	queue_redraw()


func body_center_y() -> float:
	return float(_layout().get("center_y", size.y * 0.5))


func head_y() -> float:
	return float(_layout().get("head_y", 0.0))


func foot_y() -> float:
	return float(_layout().get("foot_y", size.y))


func _opaque_rect(tex: Texture2D) -> Rect2:
	var path: String = str(tex.resource_path)
	if path == "":
		path = str(tex.get_instance_id())
	var key: String = "%s:%s" % [path, tex.get_size()]
	if _opaque.has(key):
		return _opaque[key]
	var region := Rect2(Vector2.ZERO, tex.get_size())
	var img: Image = tex.get_image()
	if img != null:
		var used: Rect2 = img.get_used_rect()
		if used.size.x >= 1.0 and used.size.y >= 1.0:
			region = used
	_opaque[key] = region
	return region


func _layout() -> Dictionary:
	var foot: float = size.y - FOOT_PAD
	var dh: float = maxf(32.0, body_px)
	var out := {
		"foot_y": foot,
		"center_y": foot - dh * 0.5,
		"head_y": foot - dh,
		"dest": Rect2(),
		"body_w": dh * 0.6,
	}
	if _frames.is_empty():
		return out
	var i: int = clampi(_frame, 0, _frames.size() - 1)
	var tex: Texture2D = _frames[i]
	if tex == null:
		return out
	var used: Rect2 = _opaque_rect(tex)
	var uh: float = maxf(1.0, used.size.y)
	var scale_n: float = dh / uh
	var full := Vector2(float(tex.get_width()) * scale_n, float(tex.get_height()) * scale_n)
	var opaque_bottom: float = used.position.y + used.size.y
	var dest_y: float = foot - (opaque_bottom / maxf(1.0, float(tex.get_height()))) * full.y
	var dest := Rect2(Vector2((size.x - full.x) * 0.5, dest_y), full)
	dest.position = dest.position.round()
	out["dest"] = dest
	out["body_w"] = maxf(48.0, used.size.x * scale_n)
	return out


func _draw() -> void:
	if _frames.is_empty():
		return
	var i: int = clampi(_frame, 0, _frames.size() - 1)
	var tex: Texture2D = _frames[i]
	if tex == null:
		return
	var lay: Dictionary = _layout()
	var dest: Rect2 = lay["dest"]
	var foot := Vector2(dest.get_center().x, float(lay["foot_y"]))
	UxStyle.draw_floor_shadow(self, foot, dest.size.x)
	var tint := Color.WHITE
	if _blue > 0.0:
		tint = Color(0.55, 0.78, 1.0)
	if face_left:
		var pivot := Vector2(dest.get_center().x, dest.position.y + dest.size.y)
		draw_set_transform(pivot, 0.0, Vector2(-1, 1))
		draw_texture_rect(tex, Rect2(dest.position - pivot, dest.size), false, tint)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(tex, dest, false, tint)
