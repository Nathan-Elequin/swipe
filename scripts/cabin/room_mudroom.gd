extends "res://scripts/cabin/cabin_room.gd"
## Outpost (room id mudroom): pegboard starting loot + reroll jar. Wall / Space → map in hands.

signal peg_changed
signal out_wanted
signal jar_reroll_wanted

const PEG_EMPTY := "props/gear_peg_empty.png"
const HOOK_W := 18.0
const HOOK_H := 18.0
const MUD_WALL := "mudroom/mudroom_wall_96"
const MUD_FLOOR := "mudroom/mudroom_floor_96x32"
const MUD_PEGS := "mudroom/mudroom_pegs_96x32"
const MUD_BOOTS := "mudroom/mudroom_boots_32x32"
const MUD_PREP := "mudroom/mudroom_prep_table_96x48"
const ROOM_W_NATIVE := 420.0
const FLOOR_Y_NATIVE := 228.0
const FLOOR_H_NATIVE := 32.0

var _hooks: Array = []
var _mudroom_bg_built: bool = false
var _hook_ids: Array = []
var _selected: Dictionary = {}
var _jar_lab: Label
var _title_lab: Label
var _hint_lab: Label
var _peg_host: Control


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
	_hint_lab.size = KIT.pt(220, 16)
	_hint_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint_lab.z_index = 8
	_hint_lab.text = KIT.copy_text("mudroom.space")
	if _hint_lab.text.strip_edges() == "":
		_hint_lab.text = "Space or wall — map in hands"
	add_child(_hint_lab)
	_peg_host = Control.new()
	_peg_host.name = "PegBoard"
	_peg_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_peg_host.z_index = 5
	add_child(_peg_host)
	_ensure_jar_label()


func _ensure_jar_label() -> void:
	if _jar_lab != null:
		return
	var jar = spots.get("RerollJar", null)
	_jar_lab = Label.new()
	_jar_lab.name = "JarLabel"
	_jar_lab.add_theme_font_size_override("font_size", 20)
	_jar_lab.add_theme_color_override("font_color", KIT.TITLE_CREAM)
	_jar_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_jar_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_jar_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_jar_lab.z_index = 6
	if jar is Control:
		_jar_lab.position = jar.position + Vector2(0, jar.size.y + 4.0)
		_jar_lab.size = Vector2(maxi(120.0, jar.size.x), 56.0)
	else:
		_jar_lab.position = KIT.pt(340, 180)
		_jar_lab.size = KIT.pt(60, 28)
	add_child(_jar_lab)


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
	var wall_h: float = FLOOR_Y_NATIVE
	var wall: NinePatchRect = KIT.nine(MUD_WALL, Vector2(12, 12))
	wall.name = "BackWall"
	wall.position = Vector2.ZERO
	wall.size = Vector2(ROOM_W_NATIVE, wall_h) * PX
	wall.z_index = 0
	host.add_child(wall)
	var floor_tex: Texture2D = KIT.load_tex(MUD_FLOOR)
	if floor_tex:
		var x: float = 0.0
		var idx := 0
		while x < ROOM_W_NATIVE:
			var tile := TextureRect.new()
			tile.name = "Floor_%d" % idx
			tile.texture = floor_tex
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_KEEP
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.position = Vector2(x, FLOOR_Y_NATIVE) * PX
			tile.size = Vector2(96.0, FLOOR_H_NATIVE) * PX
			tile.z_index = 1
			host.add_child(tile)
			x += 96.0
			idx += 1
	var pegs: TextureRect = KIT.tex_rect(MUD_PEGS, Vector2(160, 36), Vector2(96, 32), 2)
	pegs.name = "PegRail"
	host.add_child(pegs)
	var boots: TextureRect = KIT.tex_rect(MUD_BOOTS, Vector2(48, 232), Vector2(32, 32), 2)
	boots.name = "Boots"
	host.add_child(boots)
	var prep: TextureRect = KIT.tex_rect(MUD_PREP, Vector2(308, 96), Vector2(96, 48), 3)
	prep.name = "PrepTable"
	host.add_child(prep)
	add_child(host)
	move_child(host, 1)


func _refresh_doors() -> void:
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "mudroom.exit.cabin"
		back.set_locked(false)
		var closed: Texture2D = KIT.load_tex("doors/side_door_closed.png")
		if closed:
			back.set_idle_tex(closed)
		back.hover_tex = KIT.load_tex("doors/doorway_hover.png")
	var out = spots.get("OutDoor", null)
	if out is CabinHotspot:
		out.tag_key = "mudroom.exit.out"
		out.set_locked(false)
		var run_closed: Texture2D = KIT.load_tex("doors/run_door_closed.png")
		if run_closed:
			out.set_idle_tex(run_closed)
		out.hover_tex = KIT.load_tex("doors/run_door_hover.png")
	var jar = spots.get("RerollJar", null)
	if jar is CabinHotspot:
		jar.tag_key = "mudroom.jar"


func set_jar_count(n: int) -> void:
	_ensure_jar_label()
	if _jar_lab == null:
		return
	var title: String = KIT.fill_text("mudroom.jar", {"n": n})
	if title.strip_edges() == "":
		title = "Reroll jar · %s" % n
	var sub: String = KIT.copy_text("mudroom.jar.sub")
	if sub.strip_edges() == "":
		sub = "+1 each time Nib stamps a new biome"
	_jar_lab.text = "%s\n%s" % [title, sub]


func hook_ids() -> Array:
	return _hook_ids.duplicate()


func selected_ids() -> Array:
	var out: Array = []
	for id in _hook_ids:
		if bool(_selected.get(str(id), true)):
			out.append(str(id))
	return out


func set_hooks(ids: Array, tex_by_item: Dictionary, names_by_id: Dictionary = {}) -> void:
	_hook_ids.clear()
	_selected.clear()
	for c in _peg_host.get_children():
		c.queue_free()
	_hooks.clear()
	var n: int = ids.size()
	if n <= 0:
		return
	var cols := mini(3, n)
	var rows := int(ceil(float(n) / float(cols)))
	var start := Vector2(120.0, 90.0)
	var gap := Vector2(36.0, 40.0)
	for i in n:
		var id := str(ids[i])
		_hook_ids.append(id)
		_selected[id] = true
		var col: int = i % cols
		var row: int = int(i / cols)
		var origin := start + Vector2(col * gap.x, row * gap.y)
		var peg := _make_peg(i, id, origin, tex_by_item.get(id, null), str(names_by_id.get(id, id)))
		_peg_host.add_child(peg)
		_hooks.append(peg)
	## Keep layout row count unused warning quiet when n is small.
	if rows < 0:
		pass


func _make_peg(index: int, item_id: String, origin_native: Vector2, item_tex: Texture2D, item_name: String) -> Control:
	var root := Control.new()
	root.name = "PegHook_%d" % index
	root.position = origin_native * PX
	root.size = Vector2(HOOK_W, HOOK_H) * PX
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.set_meta("item_id", item_id)
	var peg := TextureRect.new()
	peg.name = "Peg"
	peg.texture = KIT.load_tex(PEG_EMPTY)
	peg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	peg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	peg.stretch_mode = TextureRect.STRETCH_KEEP
	peg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	peg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	root.add_child(peg)
	var icon := TextureRect.new()
	icon.name = "Item"
	icon.texture = item_tex
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2(2, 2) * PX
	icon.size = Vector2(HOOK_W - 4.0, HOOK_H - 4.0) * PX
	root.add_child(icon)
	var ring := ColorRect.new()
	ring.name = "Sel"
	ring.color = Color("e8c36a")
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.position = Vector2(-2, -2) * PX
	ring.size = root.size + Vector2(4, 4) * PX
	ring.z_index = -1
	root.add_child(ring)
	root.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_toggle_peg(item_id, root)
			accept_event()
	)
	root.mouse_entered.connect(func() -> void:
		## Avoid hotspot_hovered here — cabin hover has no {item} vars.
		if cabin and cabin.has_method("show_hover_tag"):
			cabin.show_hover_tag("mudroom.hook.hover", root, {"item": item_name})
	)
	root.mouse_exited.connect(func() -> void:
		if cabin and cabin.has_method("hide_hover_tag"):
			cabin.hide_hover_tag()
	)
	_paint_peg(root, true)
	return root


func _toggle_peg(item_id: String, root: Control) -> void:
	var on: bool = not bool(_selected.get(item_id, true))
	## Keep at least one hook seated so the loadout never empties.
	if not on:
		var kept := 0
		for id in _hook_ids:
			if bool(_selected.get(str(id), true)):
				kept += 1
		if kept <= 1:
			return
	_selected[item_id] = on
	_paint_peg(root, on)
	peg_changed.emit()


func _paint_peg(root: Control, on: bool) -> void:
	var icon = root.get_node_or_null("Item")
	var ring = root.get_node_or_null("Sel")
	if icon is CanvasItem:
		icon.modulate = Color.WHITE if on else Color(0.35, 0.35, 0.4, 0.7)
	if ring is CanvasItem:
		ring.visible = on


func refresh_selection_paint() -> void:
	for root in _hooks:
		if not (root is Control):
			continue
		var id := str(root.get_meta("item_id", ""))
		_paint_peg(root, bool(_selected.get(id, true)))
