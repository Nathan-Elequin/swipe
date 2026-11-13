extends TextureRect
class_name CabinHotspot
## Layout-driven clickable. Hover art is 2px larger, placed at origin − (1,1) native.

signal activated(node_name: String)
signal hovered(node_name: String, tag_key: String, hit: Control)
signal unhovered(node_name: String)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var node_id: String = ""
var tag_key: String = ""
var locked_tag: String = "cabin.hot.door_locked"
var idle_tex: Texture2D
var hover_tex: Texture2D
var press_tex: Texture2D
var locked_tex: Texture2D
var origin_native: Vector2 = Vector2.ZERO
var size_native: Vector2 = Vector2.ZERO
var locked: bool = false
var busy: bool = false
var cabin
var _hit: Control
var _pressing: bool = false
var _hovering: bool = false
var _pulse: Tween
## Gold hover frames are transparent in the middle. Swapping them in as the
## only texture revealed the chained door/ladder painted on the room plate.
var _rim: TextureRect
var _frame_cache: Dictionary = {}


func setup(entry: Dictionary, p_cabin, p_tag: String) -> void:
	cabin = p_cabin
	node_id = str(entry.get("node", ""))
	name = node_id
	tag_key = p_tag
	origin_native = Vector2(float(entry.get("origin", [0, 0])[0]), float(entry.get("origin", [0, 0])[1]))
	size_native = Vector2(float(entry.get("size", [1, 1])[0]), float(entry.get("size", [1, 1])[1]))
	idle_tex = KIT.load_tex(str(entry.get("file", ""))) if str(entry.get("file", "")) != "" and str(entry.get("file", "")) != "None" else null
	var hover_rel: String = str(entry.get("hover", ""))
	hover_tex = KIT.load_tex(hover_rel) if hover_rel != "" else null
	var press_rel: String = hover_rel.replace("_hover.png", "_press.png") if hover_rel.ends_with("_hover.png") else ""
	if press_rel == hover_rel:
		press_rel = ""
	press_tex = KIT.load_tex(press_rel) if press_rel != "" else null
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = int(entry.get("z", 2))
	texture = idle_tex
	_place_idle()
	var hs: Variant = entry.get("hotspot", null)
	_hit = Control.new()
	_hit.name = "Hit"
	_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	_hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if hs is Array and (hs as Array).size() >= 4:
		_hit.position = Vector2(float(hs[0]), float(hs[1])) * PX - position
		_hit.size = Vector2(float(hs[2]), float(hs[3])) * PX
	else:
		_hit.position = Vector2.ZERO
		_hit.size = size
	add_child(_hit)
	_hit.mouse_entered.connect(_on_enter)
	_hit.mouse_exited.connect(_on_exit)
	_hit.gui_input.connect(_on_gui)


func start_idle_pulse() -> void:
	if _pulse != null:
		_pulse.kill()
	_pulse = create_tween()
	_pulse.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pulse.set_loops()
	_pulse.tween_property(self, "modulate", Color(1.15, 1.08, 0.88, 1.0), 0.7)
	_pulse.tween_property(self, "modulate", Color.WHITE, 0.7)


func _place_idle() -> void:
	position = origin_native * PX
	if idle_tex:
		size = idle_tex.get_size()
	else:
		size = size_native * PX


func _place_hover() -> void:
	# Hover/press files are 2px larger; sit at origin − (1,1) native.
	position = (origin_native - Vector2(1, 1)) * PX
	if hover_tex:
		size = hover_tex.get_size()


func set_locked(on: bool, p_locked_tex: Texture2D = null) -> void:
	locked = on
	if p_locked_tex:
		locked_tex = p_locked_tex
	_refresh_tex()


func set_idle_tex(tex: Texture2D) -> void:
	idle_tex = tex
	_refresh_tex()


func set_hover_tex(tex: Texture2D) -> void:
	hover_tex = tex
	_refresh_tex()


func _ensure_rim() -> void:
	if _rim != null:
		return
	_rim = TextureRect.new()
	_rim.name = "HoverRim"
	_rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_rim.stretch_mode = TextureRect.STRETCH_KEEP
	_rim.visible = false
	_rim.z_index = 1
	add_child(_rim)


func _refresh_tex() -> void:
	_ensure_rim()
	var plate: Texture2D = idle_tex
	var over: Texture2D = null
	if locked and locked_tex:
		plate = locked_tex
	elif _pressing and press_tex:
		over = press_tex
	elif _hovering and hover_tex and not locked:
		over = hover_tex
	var as_frame := over != null and _is_clear_frame(over)
	if as_frame:
		texture = plate
		_place_idle()
		_rim.texture = over
		_rim.flip_h = flip_h
		_rim.visible = true
		var rim_size := over.get_size()
		_rim.size = rim_size
		_rim.position = (size - rim_size) * 0.5
		return
	_rim.visible = false
	if over:
		texture = over
		_place_hover()
		return
	texture = plate
	_place_idle()


func _is_clear_frame(tex: Texture2D) -> bool:
	var key := tex.resource_path
	if key == "":
		key = str(tex.get_rid())
	if _frame_cache.has(key):
		return bool(_frame_cache[key])
	var clear := false
	var img := tex.get_image()
	if img != null and not img.is_empty():
		if img.is_compressed():
			img.decompress()
		var c := img.get_pixel(int(img.get_width() / 2), int(img.get_height() / 2))
		clear = c.a < 0.08
	_frame_cache[key] = clear
	return clear


func _on_enter() -> void:
	_hovering = true
	if not locked:
		_refresh_tex()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.hover")
	var key: String = locked_tag if locked else tag_key
	hovered.emit(node_id, key, _hit)


func _on_exit() -> void:
	_hovering = false
	_pressing = false
	_refresh_tex()
	unhovered.emit(node_id)


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pressing = true
			if not locked:
				if press_tex:
					_refresh_tex()
				elif hover_tex:
					modulate = Color(0.85, 0.85, 0.85)
			return
		if not _pressing:
			return
		_pressing = false
		modulate = Color.WHITE
		_refresh_tex()
		if busy:
			return
		if locked:
			KIT.cue(cabin.sfx if cabin else null, &"cabin.locked")
			if cabin and cabin.has_method("_bump"):
				cabin._bump()
			if cabin and cabin.has_method("_on_locked_door"):
				cabin._on_locked_door()
			elif cabin and cabin.has_method("say_bubble"):
				cabin.say_bubble("cabin.locked")
			return
		KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
		if press_tex or hover_tex:
			var t := get_tree().create_timer(0.06, true, true, true)
			t.timeout.connect(func() -> void:
				modulate = Color.WHITE
				_refresh_tex()
			, CONNECT_ONE_SHOT)
		activated.emit(node_id)
