extends "res://scripts/cabin/cabin_room.gd"
## Outpost: large labeled wall map is the only run control. Back door → trophy hall.

signal out_wanted

const ROOM_W_NATIVE := 420.0
const ROOM_H_NATIVE := 260.0
const FLOOR_Y_NATIVE := 228.0
const MAP_ORIGIN := Vector2(110, 36)
const MAP_SIZE := Vector2(200, 148)
const POOL_SLUG := {
	"b1": "verdant_hollow",
	"b2": "sunken_mire",
	"b3": "ashen_crypt",
	"b4": "cinder_forge",
	"b5": "shadow_abyss",
}

var _title_lab: Label
var _hint_lab: Label
var _map_host: Control
var _map_pins: Control
var _mudroom_bg_built: bool = false


func _build_special() -> void:
	_title_lab = Label.new()
	_title_lab.name = "MudroomTitle"
	_title_lab.text = KIT.copy_text("room.mudroom.name")
	if _title_lab.text.strip_edges() == "":
		_title_lab.text = "Outpost"
	_title_lab.add_theme_font_size_override("font_size", 42)
	_title_lab.add_theme_color_override("font_color", KIT.TITLE_CREAM)
	_title_lab.position = KIT.pt(12, 10)
	_title_lab.size = KIT.pt(200, 24)
	_title_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_lab.z_index = 8
	add_child(_title_lab)
	_hint_lab = Label.new()
	_hint_lab.name = "MudroomHint"
	_hint_lab.add_theme_font_size_override("font_size", 22)
	_hint_lab.add_theme_color_override("font_color", KIT.CREAM)
	_hint_lab.position = KIT.pt(12, 34)
	_hint_lab.size = KIT.pt(280, 16)
	_hint_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_lab.z_index = 8
	_hint_lab.text = KIT.copy_text("mudroom.space")
	if _hint_lab.text.strip_edges() == "":
		_hint_lab.text = "Space or wall — map in hands"
	add_child(_hint_lab)
	_build_wall_map()


func _build_wall_map() -> void:
	_map_host = Control.new()
	_map_host.name = "WallMap"
	_map_host.position = MAP_ORIGIN * PX
	_map_host.size = MAP_SIZE * PX
	_map_host.mouse_filter = Control.MOUSE_FILTER_STOP
	_map_host.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_map_host.z_index = 4
	var paper := ColorRect.new()
	paper.name = "Parchment"
	paper.color = Color("e8d4a8")
	paper.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(paper)
	## 1px native outline drawn as four bars.
	var top := ColorRect.new()
	top.color = Color("100e0c")
	top.position = Vector2.ZERO
	top.size = Vector2(_map_host.size.x, PX)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(top)
	var bot := ColorRect.new()
	bot.color = Color("100e0c")
	bot.position = Vector2(0, _map_host.size.y - PX)
	bot.size = Vector2(_map_host.size.x, PX)
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(bot)
	var left := ColorRect.new()
	left.color = Color("100e0c")
	left.position = Vector2.ZERO
	left.size = Vector2(PX, _map_host.size.y)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(left)
	var right := ColorRect.new()
	right.color = Color("100e0c")
	right.position = Vector2(_map_host.size.x - PX, 0)
	right.size = Vector2(PX, _map_host.size.y)
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(right)
	_map_pins = Control.new()
	_map_pins.name = "Pins"
	_map_pins.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_map_pins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_host.add_child(_map_pins)
	_map_host.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			hotspot_activated.emit("OutDoor")
			accept_event()
	)
	_map_host.mouse_entered.connect(func() -> void:
		hotspot_hovered.emit("OutDoor", "mudroom.exit.out", _map_host)
	)
	_map_host.mouse_exited.connect(func() -> void:
		hotspot_unhovered.emit("OutDoor")
	)
	add_child(_map_host)
	spots["WallMap"] = _map_host
	spots["OutDoor"] = _map_host


func request_bg() -> void:
	_apply_bg()


func ensure_bg() -> void:
	_apply_bg()


func _apply_bg() -> void:
	if _loaded_bg:
		return
	bg.texture = null
	_build_mudroom_layers()
	_loaded_bg = true


func _build_mudroom_layers() -> void:
	if _mudroom_bg_built:
		return
	_mudroom_bg_built = true
	var host := Control.new()
	host.name = "MudroomLayers"
	host.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.z_index = 0
	var wall := ColorRect.new()
	wall.name = "BackWall"
	wall.color = Color("5a3a24")
	wall.position = Vector2.ZERO
	wall.size = Vector2(ROOM_W_NATIVE, FLOOR_Y_NATIVE) * PX
	wall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(wall)
	var floor := ColorRect.new()
	floor.name = "Floor"
	floor.color = Color("3a2414")
	floor.position = Vector2(0, FLOOR_Y_NATIVE) * PX
	floor.size = Vector2(ROOM_W_NATIVE, ROOM_H_NATIVE - FLOOR_Y_NATIVE) * PX
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(floor)
	add_child(host)
	move_child(host, 1)


func _refresh_doors() -> void:
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_hall"
		back.set_locked(false)
		var closed: Texture2D = KIT.load_tex("doors/side_door_closed.png")
		if closed:
			back.set_idle_tex(closed)
		back.hover_tex = KIT.load_tex("doors/doorway_hover.png")
	for hide_name in ["LeaveDoor", "RerollJar"]:
		var n = spots.get(hide_name, null)
		if n is CanvasItem:
			(n as CanvasItem).visible = false
		if n is CabinHotspot:
			(n as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
			if (n as CabinHotspot)._hit:
				(n as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var laid = get_node_or_null("OutDoor")
	if laid is CanvasItem and laid != _map_host:
		(laid as CanvasItem).visible = false
		if laid is CabinHotspot:
			(laid as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var jar_lab = get_node_or_null("JarLabel")
	if jar_lab:
		jar_lab.queue_free()


func refresh_map_board(rules: Dictionary, state: Dictionary) -> void:
	if _map_pins == null:
		return
	for c in _map_pins.get_children():
		c.queue_free()
	var biomes: Array = CampaignShell.biomes_of(rules)
	var n: int = mini(5, biomes.size())
	if n <= 0:
		return
	var gap: float = _map_host.size.x / float(n + 1)
	var y: float = _map_host.size.y * 0.38
	for i in n:
		var b: Dictionary = biomes[i]
		var pool := str(b.get("id", "b%d" % (i + 1)))
		var name := str(b.get("name", pool))
		var open: bool = CampaignShell.can_start(rules, state, i)
		var x: float = gap * float(i + 1)
		_add_wall_node(Vector2(x, y), name, pool, open)


func _add_wall_node(at: Vector2, biome_name: String, pool: String, open: bool) -> void:
	var slug := str(POOL_SLUG.get(pool, pool))
	var icon := TextureRect.new()
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size = Vector2(28, 28) * PX
	icon.position = at - icon.size * 0.5
	if open:
		icon.texture = KIT.ui_tex("map/stamps/stamp_%s_idle.png" % slug)
	else:
		var blob := ColorRect.new()
		blob.color = Color("2a2218")
		blob.size = Vector2(16, 12) * PX
		blob.position = at - blob.size * 0.5
		blob.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_map_pins.add_child(blob)
	if icon.texture:
		_map_pins.add_child(icon)
	var lab := Label.new()
	lab.text = biome_name
	lab.add_theme_font_size_override("font_size", 16)
	lab.add_theme_color_override("font_color", Color("3a2414") if open else Color("6e5434"))
	lab.add_theme_color_override("font_outline_color", Color("f0e6d8"))
	lab.add_theme_constant_override("outline_size", 3)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.position = at + Vector2(-70, 18 * PX)
	lab.size = Vector2(140, 22)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_pins.add_child(lab)


func set_jar_count(_n: int) -> void:
	pass


func hook_ids() -> Array:
	return []


func selected_ids() -> Array:
	return []


func set_hooks(_ids: Array, _tex_by_item: Dictionary, _names_by_id: Dictionary = {}) -> void:
	pass
