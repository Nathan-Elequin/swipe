extends Control
## Sprout's point of view, holding Grandpa's map. Not a zoom of the cabin wall.
## Space (handled by the parent) closes it. Click Verdant Hollow to start a normal
## run. A later biome's wax stamp is a shortcut once that biome is unlocked.

signal start_asked(index: int, shortcut: bool, endless: bool)
signal cheat_asked(action: String)
signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const DEV := preload("res://scripts/dev_flag.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")

const SHEET := Vector2(1440, 928)
## Cabin mark on the parchment, then the five biomes walking up the mountain.
const TRAIL: Array[Vector2] = [
	Vector2(78, 808),
	Vector2(168, 736),
	Vector2(360, 676),
	Vector2(456, 572),
	Vector2(408, 452),
	Vector2(496, 292),
]
const ENDLESS_AT := Vector2(1120, 488)
const WAX := {
	"b1": Color("5f8f3c"),
	"b2": Color("6e5a30"),
	"b3": Color("7a463c"),
	"b4": Color("d06828"),
	"b5": Color("3c3488"),
	"endless": Color("2a2048"),
}

var _sheet: Control
var _ink: RouteInk
var _pins: Control
var _hands: Hands
var _rules: Dictionary = {}
var _state: Dictionary = {}


func setup() -> void:
	name = "HeldMap"
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = false
	var scrim := ColorRect.new()
	scrim.color = Color("1a1410")
	scrim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scrim)
	_sheet = Control.new()
	_sheet.name = "Sheet"
	_sheet.position = Vector2(300, 36)
	_sheet.size = SHEET
	_sheet.pivot_offset = SHEET * 0.5
	_sheet.scale = Vector2(0.72, 0.72)
	_sheet.rotation = deg_to_rad(-6.0)
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sheet)
	var shadow := ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.45)
	shadow.position = Vector2(22, 28)
	shadow.size = SHEET
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(shadow)
	var paper := TextureRect.new()
	paper.texture = KIT.ui_tex("map/map_close_v2.png")
	paper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_KEEP
	paper.mouse_filter = Control.MOUSE_FILTER_STOP
	paper.position = Vector2.ZERO
	paper.size = SHEET
	_sheet.add_child(paper)
	_ink = RouteInk.new()
	_ink.size = SHEET
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_ink)
	_pins = Control.new()
	_pins.name = "Pins"
	_pins.size = SHEET
	_pins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_pins)
	var title: FitLabelBox = KIT.fit_label(
		"map.title",
		Rect2(220, 28, 980, 70),
		34,
		18,
		2,
		KIT.INK,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		4
	)
	_sheet.add_child(title)
	_build_close()
	_hands = Hands.new()
	_hands.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_hands.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hands.z_index = 8
	add_child(_hands)
	if DEV.on():
		_build_cheats()


func present(rules: Dictionary, state: Dictionary) -> void:
	_rules = rules
	_state = state
	_rebuild()
	visible = true
	_hands.queue_redraw()


func _rebuild() -> void:
	for c in _pins.get_children():
		if c.has_meta("peel_tw"):
			var prev: Variant = c.get_meta("peel_tw")
			if prev is Tween:
				(prev as Tween).kill()
		_pins.remove_child(c)
		c.queue_free()
	var solid := 1
	for i in range(1, 5):
		if SHELL.biome_unlocked(_rules, _state, i):
			solid += 1
		else:
			break
	_ink.pts = PackedVector2Array(TRAIL)
	_ink.solid = solid
	_ink.queue_redraw()
	var biomes: Array = SHELL.biomes_of(_rules)
	for i in mini(5, biomes.size()):
		var b: Dictionary = biomes[i]
		var pool := str(b.get("id", "b%d" % (i + 1)))
		var spot: Vector2 = TRAIL[i + 1]
		var open: bool = SHELL.can_start(_rules, _state, i)
		if i == 0:
			_add_start(spot, str(b.get("name", pool)), open)
		elif open:
			_add_stamp(spot, str(b.get("name", pool)), WAX.get(pool, KIT.INK), i, false)
		else:
			_add_locked(spot, str(b.get("name", pool)))
	var endless_name := str(_rules.get("endless", {}).get("name", "Endless"))
	if bool(_state.get("endless_unlocked", false)):
		_add_stamp(ENDLESS_AT, endless_name, WAX["endless"], 0, true)
		var best: int = int(_state.get("endless_best", 0))
		if best > 0:
			var best_txt: String = KIT.fill_text("endless.best", {"n": best})
			if best_txt.strip_edges() == "":
				best_txt = "Deepest: %s" % best
			_add_name(ENDLESS_AT + Vector2(-90, 56), best_txt, true)
		var open_tip: String = KIT.copy_text("map.endless.open")
		if open_tip.strip_edges() != "":
			_add_name(ENDLESS_AT + Vector2(-110, -56), open_tip, true)
	else:
		var sealed: String = KIT.copy_text("map.endless.sealed")
		if sealed.strip_edges() == "":
			sealed = "ENDLESS · SEALED"
		_add_locked(ENDLESS_AT, sealed)
		var sealed_sub: String = KIT.copy_text("map.endless.sealed_sub")
		if sealed_sub.strip_edges() != "":
			_add_name(ENDLESS_AT + Vector2(-110, 28), sealed_sub, false)


func _add_start(spot: Vector2, biome_name: String, open: bool) -> void:
	var flag := TextureRect.new()
	flag.texture = KIT.load_tex("overlays/map_flag.png")
	flag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flag.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flag.stretch_mode = TextureRect.STRETCH_KEEP
	flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flag.size = Vector2(40, 56)
	flag.position = spot + Vector2(-20, -78)
	_pins.add_child(flag)
	var dot := NodeDot.new()
	dot.wax = WAX["b1"]
	dot.position = spot + Vector2(-14, -14)
	dot.size = Vector2(28, 28)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pins.add_child(dot)
	_add_name(spot + Vector2(-130, 18), biome_name, true)
	if not open:
		return
	var hit := _hit_button(Rect2(spot + Vector2(-150, -90), Vector2(280, 170)))
	hit.pressed.connect(func() -> void:
		_cue(&"cabin.map_pin")
		start_asked.emit(0, false, false)
	)
	_pins.add_child(hit)


func _add_stamp(spot: Vector2, biome_name: String, wax: Color, index: int, endless: bool) -> void:
	var seal := WaxStamp.new()
	seal.wax = wax
	seal.position = spot + Vector2(-28, -28)
	seal.size = Vector2(56, 56)
	seal.pivot_offset = Vector2(28, 56)
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pins.add_child(seal)
	var name_at := spot + Vector2(36, 8)
	if endless:
		name_at = spot + Vector2(-90, 36)
	_add_name(name_at, biome_name, true)
	var hit_rect := Rect2(spot + Vector2(-100, -40), Vector2(220, 130)) if endless else Rect2(spot + Vector2(-40, -40), Vector2(280, 110))
	var hit := _hit_button(hit_rect)
	hit.mouse_entered.connect(func() -> void:
		_peel(seal, true)
	)
	hit.mouse_exited.connect(func() -> void:
		_peel(seal, false)
	)
	hit.pressed.connect(func() -> void:
		_cue(&"cabin.map_pin")
		if endless:
			start_asked.emit(0, false, true)
		else:
			start_asked.emit(index, true, false)
	)
	_pins.add_child(hit)


func _add_locked(spot: Vector2, biome_name: String) -> void:
	var ring := NodeDot.new()
	ring.hollow = true
	ring.position = spot + Vector2(-12, -12)
	ring.size = Vector2(24, 24)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pins.add_child(ring)
	_add_name(spot + Vector2(28, -8), biome_name, false)


func _add_name(at: Vector2, biome_name: String, ink: bool) -> void:
	var lab: FitLabelBox = KIT.fit_label(
		"",
		Rect2(at, Vector2(200, 44)),
		26,
		14,
		2,
		KIT.INK if ink else KIT.MUTED,
		HORIZONTAL_ALIGNMENT_CENTER,
		VERTICAL_ALIGNMENT_CENTER,
		3
	)
	lab.set_plain(biome_name)
	var inner := lab.get_node_or_null("Label") as Label
	if inner:
		inner.text = biome_name
	_pins.add_child(lab)


func _hit_button(r: Rect2) -> Button:
	var hit := Button.new()
	hit.focus_mode = Control.FOCUS_NONE
	hit.flat = true
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	hit.add_theme_stylebox_override("normal", empty)
	hit.add_theme_stylebox_override("hover", empty)
	hit.add_theme_stylebox_override("pressed", empty)
	hit.add_theme_stylebox_override("focus", empty)
	KIT.apply_rect(hit, r, 6)
	return hit


func _peel(seal: Control, up: bool) -> void:
	if not seal.has_meta("rest_y"):
		seal.set_meta("rest_y", seal.position.y)
	var prev: Variant = seal.get_meta("peel_tw", null)
	if prev is Tween:
		(prev as Tween).kill()
	var rest: float = float(seal.get_meta("rest_y"))
	var tw := create_tween()
	seal.set_meta("peel_tw", tw)
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(seal, "rotation", deg_to_rad(-16.0 if up else 0.0), 0.12)
	tw.parallel().tween_property(seal, "position:y", rest - (12.0 if up else 0.0), 0.12)


func _build_close() -> void:
	var b := TextureButton.new()
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.texture_normal = KIT.ui_tex("map/map_close_x_normal.png")
	b.texture_hover = KIT.ui_tex("map/map_close_x_hover.png")
	b.texture_pressed = KIT.ui_tex("map/map_close_x_pressed.png")
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	KIT.apply_rect(b, Rect2(1328, 36, 64, 64), 7)
	b.pressed.connect(func() -> void:
		closed.emit()
	)
	_sheet.add_child(b)


func _build_cheats() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(16, 16)
	box.z_index = 20
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	_cheat(box, "Grant 3 uniques", "grant3")
	_cheat(box, "Fill the Verdant Hollow cabinet", "fill_b1")
	_cheat(box, "Fill every cabinet", "win")
	_cheat(box, "Fresh campaign", "fresh")


func _cheat(box: VBoxContainer, label: String, action: String) -> void:
	var b := Button.new()
	b.text = label
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func() -> void:
		cheat_asked.emit(action)
	)
	box.add_child(b)


func _cue(id: StringName) -> void:
	var n: Node = self
	while n:
		var bank = n.get("sfx")
		if bank != null:
			KIT.cue(bank, id)
			return
		n = n.get_parent()


class RouteInk extends Control:
	var pts: PackedVector2Array = PackedVector2Array()
	var solid: int = 1

	func _draw() -> void:
		if pts.size() < 2:
			return
		for i in pts.size() - 1:
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[i + 1]
			if i < solid:
				draw_line(a, b, Color("3a2414"), 8.0, false)
			else:
				_dash(a, b)


	func _dash(a: Vector2, b: Vector2) -> void:
		var dir := b - a
		var dist := dir.length()
		if dist < 1.0:
			return
		dir /= dist
		var t := 0.0
		while t < dist:
			var t2: float = minf(t + 14.0, dist)
			draw_line(a + dir * t, a + dir * t2, Color("8a7048"), 5.0, false)
			t += 26.0


class WaxStamp extends Control:
	var wax: Color = Color("5f8f3c")

	func _draw() -> void:
		var c := size * 0.5
		var rad: float = minf(size.x, size.y) * 0.46
		draw_circle(c + Vector2(3, 4), rad, Color(0, 0, 0, 0.35))
		draw_circle(c, rad, wax)
		draw_arc(c, rad, 0, TAU, 28, Color("100e0c"), 3.0, true)
		draw_arc(c, rad * 0.62, 0, TAU, 20, Color("100e0c"), 2.0, true)


class NodeDot extends Control:
	var wax: Color = Color("3a2414")
	var hollow: bool = false

	func _draw() -> void:
		var c := size * 0.5
		var rad: float = minf(size.x, size.y) * 0.45
		if hollow:
			draw_arc(c, rad, 0, TAU, 16, Color("8a7d70"), 3.0, true)
		else:
			draw_circle(c, rad, wax)
			draw_arc(c, rad, 0, TAU, 16, Color("100e0c"), 2.0, true)


class Hands extends Control:
	const KIT := preload("res://scripts/cabin/cabin_kit.gd")
	var _frame: int = 0
	var _acc: float = 0.0

	func _process(delta: float) -> void:
		if not is_visible_in_tree():
			return
		_acc += delta
		if _acc < 0.45:
			return
		_acc = 0.0
		_frame = 1 - _frame
		queue_redraw()


	func _draw() -> void:
		_mitt(Vector2(36, 760), false)
		_mitt(Vector2(1320, 790), true)
		var tex: Texture2D = KIT.load_tex("overlays/map_hero_f%d.png" % _frame)
		if tex:
			draw_texture_rect(tex, Rect2(760, 860, 160, 160), false)


	func _mitt(origin: Vector2, flip: bool) -> void:
		var skin := Color("e4b48a")
		var leaf := Color("3d6b32")
		var ink := Color("100e0c")
		var cells: Array = [
			[1, 5, leaf], [2, 5, leaf], [3, 5, leaf], [4, 5, leaf], [5, 5, leaf],
			[1, 4, leaf], [2, 4, leaf], [3, 4, leaf], [4, 4, leaf], [5, 4, leaf],
			[2, 3, skin], [3, 3, skin], [4, 3, skin], [5, 3, skin], [6, 3, skin],
			[0, 2, skin], [1, 2, skin], [2, 2, skin], [3, 2, skin], [4, 2, skin], [5, 2, skin], [6, 2, skin],
			[2, 1, skin], [3, 1, skin], [4, 1, skin], [5, 1, skin],
			[2, 0, skin], [3, 0, skin], [5, 0, skin],
		]
		var s := 18.0
		for raw in cells:
			var cell: Array = raw
			var x := int(cell[0])
			if flip:
				x = 6 - x
			var y := int(cell[1])
			var p := origin + Vector2(float(x) * s, float(y) * s)
			draw_rect(Rect2(p - Vector2(2, 2), Vector2(s + 2, s + 2)), ink)
		for raw2 in cells:
			var cell2: Array = raw2
			var x2 := int(cell2[0])
			if flip:
				x2 = 6 - x2
			var p2 := origin + Vector2(float(x2) * s, float(cell2[1]) * s)
			draw_rect(Rect2(p2, Vector2(s - 2, s - 2)), cell2[2])
