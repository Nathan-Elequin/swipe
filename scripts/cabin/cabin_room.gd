extends Control
class_name CabinRoom
## One 1680×1040 room, built from data/cabin-layout.json. No hand-typed rects.

signal hotspot_activated(node_name: String)
signal hotspot_hovered(node_name: String, tag_key: String, hit: Control)
signal hotspot_unhovered(node_name: String)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const HOT := preload("res://scripts/cabin/cabin_hotspot.gd")
const PX := 4.0

var cabin
var room_id: String = ""
var layout: Array = []
var extra: Dictionary = {}
var spots: Dictionary = {}
var bg: TextureRect
var glow: TextureRect
var _loaded_bg: bool = false
var _bg_rel: String = ""


func setup(p_cabin, p_id: String, p_layout: Array, p_extra: Dictionary) -> void:
	cabin = p_cabin
	room_id = p_id
	## Study + workshop sit on the LEFT of main after the cabin flip — H-flip art
	## so doorways / ladder face the correct neighbor without new PNGs.
	var flip_x: bool = p_id == "study" or p_id == "workshop"
	layout = _mirror_layout(p_layout) if flip_x else p_layout
	extra = p_extra
	custom_minimum_size = Vector2(KIT.ROOM_W, KIT.ROOM_H)
	size = Vector2(KIT.ROOM_W, KIT.ROOM_H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	_bg_rel = "rooms/room_%s.png" % room_id
	bg = TextureRect.new()
	bg.name = "Bg"
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.flip_h = flip_x
	add_child(bg)
	if room_id == "main":
		_apply_bg()
	_build_entries()
	_build_special()
	refresh_locks()


const ROOM_NATIVE_W := 420.0


func _mirror_layout(src: Array) -> Array:
	var out: Array = []
	for entry in src:
		if typeof(entry) != TYPE_DICTIONARY:
			out.append(entry)
			continue
		var e: Dictionary = (entry as Dictionary).duplicate(true)
		var origin: Array = e.get("origin", [0, 0])
		var sz: Array = e.get("size", [1, 1])
		if origin is Array and origin.size() >= 2 and sz is Array and sz.size() >= 2:
			var w: float = float(sz[0])
			e["origin"] = [ROOM_NATIVE_W - float(origin[0]) - w, float(origin[1])]
		var hs: Variant = e.get("hotspot", null)
		if hs is Array and (hs as Array).size() >= 4:
			var ha: Array = hs
			var hw: float = float(ha[2])
			e["hotspot"] = [ROOM_NATIVE_W - float(ha[0]) - hw, float(ha[1]), hw, float(ha[3])]
		out.append(e)
	return out


func ensure_bg() -> void:
	if _loaded_bg:
		return
	if ResourceLoader.load_threaded_get_status(KIT.HOME + _bg_rel) == ResourceLoader.THREAD_LOAD_LOADED:
		bg.texture = ResourceLoader.load_threaded_get(KIT.HOME + _bg_rel)
		_loaded_bg = true
		return
	_apply_bg()


func request_bg() -> void:
	if _loaded_bg:
		return
	ResourceLoader.load_threaded_request(KIT.HOME + _bg_rel)


func _apply_bg() -> void:
	bg.texture = KIT.load_tex(_bg_rel)
	if bg.texture == null and room_id == "mudroom":
		bg.texture = KIT.load_tex("rooms/room_workshop.png")
		if bg.texture == null:
			bg.texture = KIT.load_tex("rooms/room_main.png")
	_loaded_bg = bg.texture != null


func _build_entries() -> void:
	for entry in layout:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var node_name: String = str(entry.get("node", ""))
		var vis: String = str(entry.get("visible_when", ""))
		if entry.get("hotspot", null) != null:
			var hs: CabinHotspot = HOT.new()
			var tag: String = _tag_for(node_name)
			hs.setup(entry, cabin, tag)
			hs.activated.connect(func(n: String) -> void:
				hotspot_activated.emit(n)
			)
			hs.hovered.connect(func(n: String, k: String, hit: Control) -> void:
				hotspot_hovered.emit(n, k, hit)
			)
			hs.unhovered.connect(func(n: String) -> void:
				hotspot_unhovered.emit(n)
			)
			add_child(hs)
			spots[node_name] = hs
			if vis != "":
				hs.set_meta("visible_when", vis)
				hs.visible = KIT.eval_visible(vis, cabin)
		else:
			var rel: String = str(entry.get("file", ""))
			if rel == "" or rel == "None":
				continue
			var origin: Array = entry.get("origin", [0, 0])
			var sz: Array = entry.get("size", [1, 1])
			var tr: TextureRect = KIT.tex_rect(rel, Vector2(float(origin[0]), float(origin[1])), Vector2(float(sz[0]), float(sz[1])), int(entry.get("z", 1)))
			tr.name = node_name
			add_child(tr)
			spots[node_name] = tr
			if vis != "":
				tr.set_meta("visible_when", vis)
				tr.visible = KIT.eval_visible(vis, cabin)
			if node_name.ends_with("glow") or node_name.ends_with("Glow") or node_name.begins_with("room_") and node_name.ends_with("_glow") or node_name == "Moon" or "glow" in node_name.to_lower() or "moon" in node_name.to_lower():
				glow = tr
				_flicker(tr, node_name)


func _flicker(tr: TextureRect, node_name: String) -> void:
	var lo := 0.85
	var hi := 1.0
	var dur := 0.6
	if "hall" in node_name:
		lo = 0.9
		dur = 0.8
	elif "study" in node_name:
		lo = 0.92
		dur = 0.7
	elif "workshop" in node_name:
		lo = 0.9
		dur = 0.9
	elif "moon" in node_name.to_lower():
		lo = 0.85
		dur = 3.0
	tr.modulate.a = lo
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_loops()
	tw.tween_property(tr, "modulate:a", hi, dur)
	tw.tween_property(tr, "modulate:a", lo, dur)


func _tag_for(node_name: String) -> String:
	var table := {
		"RunDoor": "cabin.hot.run_door",
		"SideDoor": "cabin.hot.door_hall",
		"LeftDoor": "cabin.hot.door_study",
		"LeaveDoor": "mudroom.exit.out",
		"Map": "cabin.hot.map",
		"Radio": "cabin.hot.radio",
		"RadioFirefly": "radio.gloria",
		"Gear_helm": "cabin.gear.helm",
		"Gear_cap": "cabin.gear.cap",
		"Gear_goggles": "cabin.gear.goggles",
		"Gear_rope": "cabin.gear.rope",
		"LuckyGeode": "cabin.hot.geode",
		"PortraitSmall": "cabin.hot.portrait_small",
		"Nib": "cabin.hot.nib",
		"Fire": "cabin.hot.fire",
		"Hero": "cabin.hot.chair",
		"Rug": "cabin.hot.rug",
		"BackDoor": "cabin.hot.back",
		"ShelfPrev": "cabin.hot.cabinet",
		"ShelfNext": "cabin.hot.cabinet",
		"Gauge": "cabin.hot.gauge",
		"PortraitBig": "cabin.hot.portrait_big",
		"Journal": "cabin.hot.journal",
		"Will": "cabin.hot.will",
		"MountainModel": "cabin.hot.model",
		"Drawer": "cabin.hot.drawer",
		"Dummy": "cabin.hot.dummy",
		"BragOMeter": "cabin.hot.brag",
		"Patents": "cabin.hot.patents",
		"Ladder": "cabin.hot.door_loft",
		"Bed": "cabin.hot.bed",
		"Telescope": "cabin.hot.telescope",
		"Trunk": "cabin.hot.trunk",
		"Cat": "cabin.hot.cat",
		"Hatch": "cabin.hot.hatch",
		"OutDoor": "mudroom.exit.out",
		"RerollJar": "mudroom.jar",
	}
	if room_id == "mudroom" and node_name == "BackDoor":
		return "mudroom.exit.cabin"
	return str(table.get(node_name, "cabin.hot." + node_name.to_snake_case()))


func _build_special() -> void:
	pass


func refresh_locks() -> void:
	for n in spots.keys():
		var node = spots[n]
		if node is CabinHotspot and node.has_meta("visible_when"):
			node.visible = KIT.eval_visible(str(node.get_meta("visible_when")), cabin)
		elif node is CanvasItem and node.has_meta("visible_when"):
			node.visible = KIT.eval_visible(str(node.get_meta("visible_when")), cabin)
	_refresh_doors()


func _refresh_doors() -> void:
	pass


func set_busy(on: bool) -> void:
	for n in spots.values():
		if n is CabinHotspot:
			n.busy = on


func _candle(origin: Vector2) -> void:
	var sp: AnimatedSprite2D = KIT.anim_sprite(
		["props/candle_flame_f0.png", "props/candle_flame_f1.png", "props/candle_flame_f2.png"],
		"flame", 1000.0 / 140.0, true, origin
	)
	add_child(sp)
	if sp.sprite_frames:
		sp.frame = randi() % 3
		sp.play("flame")
