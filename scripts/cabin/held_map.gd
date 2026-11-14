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

## Loom-free held plate (Doop w8wF4MIkv8 → ChatGPT Grandpa plate 2026-10-30).
## Fall back to the older inked plate.
const HELD_PLATE := "map/held/map_in_hands_living.png"
const HELD_PLATE_FALLBACK := "map/held/map_in_hands.png"
const SHEET := Vector2(1680, 1040)
## Stamp hit centres on the held plate (1680×1040 screen space).
## Cabin → Verdant → Crystal Cavern → Ashen → Cinder → Shadow.
## ChatGPT plate feel-test 2026-10-30: kept Doop centres for b1–b4 / START;
## nudged Shadow + Endless only (>~40px miss vs painted badges).
const TRAIL: Array[Vector2] = [
	Vector2(816, 236),
	Vector2(962, 363),
	Vector2(648, 473),
	Vector2(998, 567),
	Vector2(659, 672),
	Vector2(1020, 798),
]
## Per-biome Deadly patrol lanes (offsets from TRAIL[i+1]). Slot k = k-th telegraph id.
## Feet sit left of the wax stamp (names live to the right). Average rest is
## about twice as far from the seal as the first pass, with a longer patrol.
const LANES := {
	"b1": [{"at": Vector2(-104, 32), "dx": 36.0}],
	"b2": [{"at": Vector2(-108, 16), "dx": 40.0}, {"at": Vector2(-84, 88), "dx": 36.0}],
	"b3": [{"at": Vector2(-108, 16), "dx": 40.0}, {"at": Vector2(-84, 88), "dx": 36.0}],
	"b4": [{"at": Vector2(-108, 16), "dx": 40.0}, {"at": Vector2(-84, 88), "dx": 36.0}],
	"b5": [
		{"at": Vector2(-108, 8), "dx": 40.0},
		{"at": Vector2(-136, 76), "dx": 36.0},
		{"at": Vector2(-48, 100), "dx": 32.0},
	],
}
const ENDLESS_AT := Vector2(410, 856)
const WAX := {
	"b1": Color("5f8f3c"),
	"b2": Color("7fa9c4"),
	"b3": Color("7a463c"),
	"b4": Color("d06828"),
	"b5": Color("3c3488"),
	"endless": Color("2a2048"),
}
## Pool id → stamp filename slug (assets/ui/map/stamps/stamp_<slug>_<state>.png).
const POOL_SLUG := {
	"b1": "verdant_hollow",
	"b2": "sunken_mire",
	"b3": "ashen_crypt",
	"b4": "cinder_forge",
	"b5": "shadow_abyss",
	"endless": "endless",
}
## Spin COPY-FINALS map chrome (verbatim stubs until Jam keys land).
const TIP_CLICK := "click to set off"
const TIP_START := "START HERE"
## Bright-red banner measured on map_in_hands_living.png (1680×1040).
const START_BANNER := Rect2(805, 163, 280, 54)
const TIP_ENDLESS_SEALED := "ENDLESS · SEALED"
const TIP_ENDLESS_SEALED_SUB := "Opens when you pull the last lever"
const LABEL_UNMAPPED := "%s · unmapped"
const KNOWN_MODULATE := Color(0.62, 0.58, 0.52)
const START_BANNER_BOTTOM := Vector2(945, 217)

var _sheet: Control
var _ink: RouteInk
var _monsters: Control
var _pins: Control
var _hands: Hands
var _tip: Label
var _rules: Dictionary = {}
var _state: Dictionary = {}
var _monsters_by_id: Dictionary = {}
var _read_only: bool = false
var _going: bool = false
var _lane_rng := RandomNumberGenerator.new()
## Living/ChatGPT plate already paints biome names, START HERE, and Endless sealed.
## Skip always-on code name Labels that would smear over that paint.
var _plate_paints_names: bool = false
var _reveal_pool: String = ""
var _shortcut_reveal: String = ""
var _reduce_motion: bool = false
var _path_lines: Array = []


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
	## Doop map-in-hands plate is already full 1680×1040 POV (hands baked in).
	_sheet.position = Vector2.ZERO
	_sheet.size = SHEET
	_sheet.pivot_offset = SHEET * 0.5
	_sheet.scale = Vector2.ONE
	_sheet.rotation = 0.0
	_sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sheet)
	var paper := TextureRect.new()
	paper.name = "HeldPlate"
	var living_tex: Texture2D = KIT.ui_tex(HELD_PLATE)
	paper.texture = living_tex
	## Living plate (ChatGPT Grandpa art) paints title, badge names, START HERE,
	## and Endless sealed note — hide duplicate always-on code Labels.
	_plate_paints_names = living_tex != null
	if paper.texture == null:
		paper.texture = KIT.ui_tex(HELD_PLATE_FALLBACK)
	if paper.texture == null:
		paper.texture = KIT.ui_tex("map/map_close_v2.png")
	paper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.stretch_mode = TextureRect.STRETCH_KEEP
	paper.mouse_filter = Control.MOUSE_FILTER_STOP
	paper.position = Vector2.ZERO
	paper.size = SHEET
	_sheet.add_child(paper)
	## Route ink stays for pencil-fresh segments; plate already has printed trails.
	_ink = RouteInk.new()
	_ink.size = SHEET
	_ink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ink.modulate = Color(1, 1, 1, 0.35)
	_sheet.add_child(_ink)
	## Living Deadlies sit above route ink. Higher z than pins so monster hover
	## wins when a lane overlaps a stamp hit rect; tip stays above both.
	_monsters = Control.new()
	_monsters.name = "Monsters"
	_monsters.size = SHEET
	_monsters.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_monsters.z_index = 7
	_sheet.add_child(_monsters)
	_pins = Control.new()
	_pins.name = "Pins"
	_pins.size = SHEET
	_pins.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pins.z_index = 5
	_sheet.add_child(_pins)
	_tip = Label.new()
	_tip.name = "StampTip"
	_tip.visible = false
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.z_index = 12
	_tip.add_theme_font_size_override("font_size", 22)
	_tip.add_theme_color_override("font_color", KIT.INK)
	_tip.add_theme_color_override("font_outline_color", Color("f0e6d8"))
	_tip.add_theme_constant_override("outline_size", 4)
	_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sheet.add_child(_tip)
	_build_close()
	## Plate already draws Sprout's hands — skip procedural mitts.
	_hands = Hands.new()
	_hands.visible = false
	_hands.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hands)
	if DEV.on():
		_build_cheats()


func set_map_monster_stats(on: bool) -> void:
	MapMonster.include_stats = on
	if visible:
		_rebuild()


## Destination stamp is on the parchment (unlocked), even when not a start floor.
func destination_visible(pool: String) -> bool:
	return _pin_with_meta(pool, "destination_visible") != null


## Fresh-start launch hit exists for this pool (can_start / Endless open).
func destination_launchable(pool: String) -> bool:
	return _launch_hit(pool) != null


func _pin_with_meta(pool: String, flag: String) -> Control:
	if _pins == null or pool == "":
		return null
	for child in _pins.get_children():
		if not (child is Control):
			continue
		if str(child.get_meta("pool_id", "")) != pool:
			continue
		if bool(child.get_meta(flag, false)):
			return child as Control
	return null


func _launch_hit(pool: String) -> Button:
	if _pins == null or pool == "":
		return null
	var want := "LaunchHit_%s" % pool
	for child in _pins.get_children():
		if child is Button and child.name == want:
			return child as Button
	return null


func present(rules: Dictionary, state: Dictionary, monsters_by_id: Dictionary = {}, opts: Dictionary = {}) -> void:
	_rules = rules
	_state = state
	_monsters_by_id = monsters_by_id
	_read_only = bool(opts.get("read_only", false))
	_reveal_pool = str(opts.get("reveal", ""))
	_shortcut_reveal = str(opts.get("shortcut_reveal", ""))
	_reduce_motion = bool(opts.get("reduce_motion", false))
	_going = false
	_hide_tip()
	_rebuild()
	visible = true
	_hands.queue_redraw()
	# Fresh pencil shows on this open, then clears so the next view is inked solid.
	if not _read_only:
		SHELL.clear_pencil_fresh(_state)
	var focus_pool := str(opts.get("focus_pool", ""))
	if focus_pool != "":
		call_deferred("_pulse_focus_stamp", focus_pool)
	if _reveal_pool != "":
		call_deferred("_play_reveal_fog", _reveal_pool)
	if _shortcut_reveal != "":
		call_deferred("_play_shortcut_reveal", _shortcut_reveal)


func _rebuild() -> void:
	## Kill looping glow/badge tweens before freeing pins (avoids set_loops errors).
	for c in _pins.get_children():
		_kill_peel_tween(c)
		if c.has_meta("loop_tw"):
			var loop_tw: Variant = c.get_meta("loop_tw")
			if loop_tw is Tween and is_instance_valid(loop_tw):
				(loop_tw as Tween).kill()
		_pins.remove_child(c)
		c.queue_free()
	_clear_monsters()
	_clear_path_lines()
	var solid := 1
	for i in range(1, 5):
		if SHELL.biome_unlocked(_rules, _state, i):
			solid += 1
		else:
			break
	var fresh_segs: Array = []
	var fresh_raw: Variant = _state.get("pencil_fresh", [])
	if typeof(fresh_raw) == TYPE_ARRAY or typeof(fresh_raw) == TYPE_PACKED_STRING_ARRAY:
		var biomes_for_fresh: Array = SHELL.biomes_of(_rules)
		for raw_fresh in fresh_raw:
			var fid := str(raw_fresh)
			if fid == "" or fid == str(_rules.get("endless", {}).get("id", "endless")):
				continue
			for bi in biomes_for_fresh.size():
				if str((biomes_for_fresh[bi] as Dictionary).get("id", "")) == fid:
					# Segment bi connects TRAIL[bi] → TRAIL[bi+1] (cabin→b1 is 0).
					fresh_segs.append(bi)
					break
	_ink.pts = PackedVector2Array(TRAIL)
	_ink.solid = solid
	_ink.fresh = fresh_segs
	_ink.queue_redraw()
	var biomes: Array = SHELL.biomes_of(_rules)
	for i in mini(5, biomes.size()):
		var b: Dictionary = biomes[i]
		var pool := str(b.get("id", "b%d" % (i + 1)))
		var spot: Vector2 = TRAIL[i + 1]
		## Three states (Package D): unknown / known / shortcut-startable.
		var unlocked: bool = SHELL.biome_unlocked(_rules, _state, i)
		var launchable: bool = SHELL.can_start(_rules, _state, i)
		if not unlocked:
			_add_fog_unknown(spot, str(b.get("name", pool)), pool)
		elif launchable:
			_add_stamp(spot, str(b.get("name", pool)), pool, WAX.get(pool, KIT.INK), i, false, true)
			_spawn_pool_monsters(pool, spot)
			_maybe_add_shortcut_chrome(pool, spot, i)
			_maybe_add_static_path(pool, i)
		else:
			## Known: flat ink, no hit, no hover affordance.
			_add_stamp(spot, str(b.get("name", pool)), pool, WAX.get(pool, KIT.INK), i, false, false)
			_spawn_pool_monsters(pool, spot)
	var endless_name := str(_rules.get("endless", {}).get("name", "Endless"))
	if bool(_state.get("endless_unlocked", false)):
		_add_stamp(ENDLESS_AT, endless_name, "endless", WAX["endless"], 0, true, true)
		var best: int = int(_state.get("endless_best", 0))
		if best > 0:
			var best_txt: String = KIT.fill_text("endless.best", {"n": best})
			if best_txt.strip_edges() == "":
				best_txt = "Deepest: %s" % best
			## Depth record is not painted on the plate — keep as always-on.
			_add_name(ENDLESS_AT + Vector2(-90, 56), best_txt, true, true)
		var open_tip: String = KIT.copy_text("map.endless.open")
		if open_tip.strip_edges() != "":
			## Open/unlocked status is not painted — keep as always-on.
			_add_name(ENDLESS_AT + Vector2(-110, -56), open_tip, true, true)
	else:
		var sealed: String = KIT.copy_text("map.endless.sealed")
		if sealed.strip_edges() == "":
			sealed = TIP_ENDLESS_SEALED
		_add_locked(ENDLESS_AT, sealed, "endless")
		## Plate paints "ENDLESS - SEALED / opens when…"; skip duplicate always-on.
		var sealed_sub: String = KIT.copy_text("map.endless.sealed_sub")
		if sealed_sub.strip_edges() == "":
			sealed_sub = TIP_ENDLESS_SEALED_SUB
		if sealed_sub.strip_edges() != "" and not _plate_paints_names:
			_add_name(ENDLESS_AT + Vector2(-110, 28), sealed_sub, false)
	## Painted red "START HERE" banner (living plate). Always launches Verdant
	## until a shortcut is earned — still the earliest launchable index.
	_add_start_banner()


## Earliest biome the shell will actually start (Dungeon 1, then earned shortcuts).
func _first_launchable_index() -> int:
	var biomes: Array = SHELL.biomes_of(_rules)
	for i in mini(5, biomes.size()):
		if SHELL.can_start(_rules, _state, i):
			return i
	return -1


## Same launch as the first playable stamp. The painted banner had no hit of its own.
func _add_start_banner() -> void:
	if _read_only or _pins == null:
		return
	var idx := _first_launchable_index()
	if idx < 0:
		return
	var hit := _hit_button(START_BANNER)
	hit.name = "LaunchHit_start"
	hit.z_index = 8
	hit.mouse_entered.connect(func() -> void:
		_show_tip_at(START_BANNER.position + Vector2(START_BANNER.size.x * 0.5, -8), TIP_START)
	)
	hit.mouse_exited.connect(func() -> void:
		_hide_tip()
	)
	hit.pressed.connect(func() -> void:
		await _launch_first_available()
	)
	_pins.add_child(hit)


func _launch_first_available() -> void:
	var idx := _first_launchable_index()
	if idx < 0 or _pins == null:
		return
	var biomes: Array = SHELL.biomes_of(_rules)
	if idx >= biomes.size():
		return
	var pool := str((biomes[idx] as Dictionary).get("id", ""))
	var seal := _pins.get_node_or_null("Stamp_%s" % pool) as WaxStamp
	if seal != null:
		await _start_from_stamp(seal, idx, false)
		return
	_start_from_pin(idx, true, false)


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
	if not open or _read_only:
		return
	var hit := _hit_button(Rect2(spot + Vector2(-150, -90), Vector2(280, 170)))
	hit.mouse_entered.connect(func() -> void:
		_show_tip_at(spot + Vector2(0, -100), TIP_START)
	)
	hit.mouse_exited.connect(func() -> void:
		_hide_tip()
	)
	hit.pressed.connect(func() -> void:
		_start_from_pin(0, false, false)
	)
	_pins.add_child(hit)


func _pulse_focus_stamp(pool: String) -> void:
	if pool == "" or _pins == null:
		return
	for child in _pins.get_children():
		if not (child is CanvasItem):
			continue
		if str(child.get_meta("pool_id", "")) != pool:
			continue
		var node := child as Control
		var base := node.scale
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_trans(Tween.TRANS_QUAD)
		tw.set_ease(Tween.EASE_IN_OUT)
		for _i in 2:
			tw.tween_property(node, "scale", base * 1.12, 0.18)
			tw.tween_property(node, "scale", base, 0.18)
		return


func _add_stamp(
	spot: Vector2,
	biome_name: String,
	pool: String,
	wax: Color,
	index: int,
	endless: bool,
	launchable: bool = true
) -> void:
	var seal := WaxStamp.new()
	seal.name = "Stamp_%s" % pool
	seal.wax = wax
	seal.pool_slug = str(POOL_SLUG.get(pool, pool))
	seal.set_stamp_state("idle")
	seal.position = spot + Vector2(-28, -28)
	seal.size = Vector2(56, 56)
	seal.pivot_offset = Vector2(28, 56)
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seal.set_meta("pool_id", pool)
	seal.set_meta("destination_visible", true)
	seal.set_meta("launchable", launchable and not _read_only)
	## Known (unlocked, not startable): flat ink, no peel / hover.
	if not launchable and not endless:
		seal.modulate = KNOWN_MODULATE
	_pins.add_child(seal)
	if launchable and not endless and not _read_only:
		_add_node_glow(spot, pool)
	var name_at := spot + Vector2(36, 8)
	if endless:
		name_at = spot + Vector2(-90, 36)
	_add_name(name_at, biome_name, true)
	## Visible destination without a fresh-start floor: keep the stamp, skip launch hit.
	if _read_only or not launchable:
		return
	var hit_rect := Rect2(spot + Vector2(-100, -40), Vector2(220, 130)) if endless else Rect2(spot + Vector2(-40, -40), Vector2(280, 110))
	var hit := _hit_button(hit_rect)
	hit.name = "LaunchHit_%s" % pool
	hit.set_meta("pool_id", pool)
	hit.set_meta("map_launch", true)
	hit.mouse_entered.connect(func() -> void:
		_peel(seal, true)
		seal.set_stamp_state("hover")
		_show_tip_at(spot + Vector2(0, -48), TIP_CLICK)
	)
	hit.mouse_exited.connect(func() -> void:
		_peel(seal, false)
		if not _going:
			seal.set_stamp_state("idle")
		_hide_tip()
	)
	## Await the flatten tween so start_asked still fires after press.
	hit.pressed.connect(func() -> void:
		await _start_from_stamp(seal, index, endless)
	)
	_pins.add_child(hit)


func _add_locked(spot: Vector2, biome_name: String, pool: String) -> void:
	var endless := pool == "endless"
	var blob := ColorRect.new()
	blob.name = "Locked_%s" % pool
	blob.color = Color("2a2218")
	blob.size = Vector2(36, 28)
	blob.position = spot + Vector2(-18, -14)
	blob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blob.set_meta("pool_id", pool)
	blob.set_meta("destination_visible", false)
	blob.set_meta("launchable", false)
	_pins.add_child(blob)
	var label := biome_name
	if endless:
		label = TIP_ENDLESS_SEALED
	## Biome / Endless sealed names are painted on the living plate — skip always-on.
	_add_name(spot + Vector2(28, -8) if not endless else spot + Vector2(-90, 36), label, false)
	if endless and not _read_only:
		var hit := _hit_button(Rect2(spot + Vector2(-100, -40), Vector2(220, 130)))
		## Reworded away from cabinets (Package D).
		var sealed_sub: String = KIT.copy_text("map.endless.sealed_sub")
		if sealed_sub.strip_edges() == "":
			sealed_sub = TIP_ENDLESS_SEALED_SUB
		var sealed_tip := TIP_ENDLESS_SEALED if _plate_paints_names else sealed_sub
		hit.mouse_entered.connect(func() -> void:
			_show_tip_at(spot + Vector2(0, -48), sealed_tip)
		)
		hit.mouse_exited.connect(func() -> void:
			_hide_tip()
		)
		_pins.add_child(hit)


## Unknown biome: fog bank, no hit, no hover.
func _add_fog_unknown(spot: Vector2, biome_name: String, pool: String) -> void:
	var slug := str(POOL_SLUG.get(pool, pool))
	## ASSETS D1 uses crystal/ashen/cinder/shadow — map from pool.
	var fog_slug: String = str({
		"b2": "crystal", "b3": "ashen", "b4": "cinder", "b5": "shadow",
	}.get(pool, "crystal"))
	var fog := TextureRect.new()
	fog.name = "Fog_%s" % pool
	fog.texture = KIT.ui_tex("map/trophy/fog_%s.png" % fog_slug)
	if fog.texture == null:
		## Flat placeholder when art is missing.
		var ph := ColorRect.new()
		ph.name = "Fog_%s" % pool
		ph.color = Color(0.72, 0.70, 0.64, 0.85)
		ph.size = Vector2(192, 128)
		ph.position = spot + Vector2(-96, -64)
		ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ph.set_meta("pool_id", pool)
		ph.set_meta("destination_visible", false)
		ph.set_meta("launchable", false)
		_pins.add_child(ph)
		_add_locked(spot, biome_name, pool)
		return
	fog.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fog.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fog.stretch_mode = TextureRect.STRETCH_KEEP
	fog.size = Vector2(192, 128)
	fog.position = spot + Vector2(-96, -64)
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog.set_meta("pool_id", pool)
	fog.set_meta("destination_visible", false)
	fog.set_meta("launchable", false)
	_pins.add_child(fog)
	## Soft drift.
	var tw := create_tween()
	tw.set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	var base_x: float = fog.position.x
	tw.tween_property(fog, "position:x", base_x + 2.0, 3.0)
	tw.tween_property(fog, "position:x", base_x - 2.0, 3.0)
	## Keep a locked meta pin so destination_visible probes still work.
	_add_locked(spot, biome_name, pool)
	## Hide the dark blob under fog — fog is the read.
	var locked := _pins.get_node_or_null("Locked_%s" % pool)
	if locked is CanvasItem:
		(locked as CanvasItem).modulate.a = 0.0


func _add_node_glow(spot: Vector2, pool: String) -> void:
	var glow := TextureRect.new()
	glow.name = "Glow_%s" % pool
	glow.texture = KIT.ui_tex("map/trophy/node_glow_f0.png")
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_KEEP
	glow.size = Vector2(160, 160)
	glow.position = spot + Vector2(-80, -80)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.z_index = -1
	glow.modulate = Color(1, 1, 1, 0.75)
	_pins.add_child(glow)
	if _reduce_motion:
		return
	var frames: Array = []
	for i in 4:
		var t: Texture2D = KIT.ui_tex("map/trophy/node_glow_f%d.png" % i)
		if t != null:
			frames.append(t)
	if frames.size() >= 2:
		glow.texture = frames[0]
	var tw := create_tween()
	glow.set_meta("loop_tw", tw)
	tw.set_loops()
	## Property tween so set_loops has non-zero duration (Godot 4.7).
	tw.tween_property(glow, "modulate:a", 0.55, 0.5)
	tw.tween_property(glow, "modulate:a", 0.85, 0.5)
	if frames.size() >= 2:
		tw.tween_callback(func() -> void:
			if is_instance_valid(glow):
				var cur: int = int(glow.get_meta("glow_frame", 0))
				cur = (cur + 1) % frames.size()
				glow.set_meta("glow_frame", cur)
				glow.texture = frames[cur]
		)


func _maybe_add_shortcut_chrome(pool: String, spot: Vector2, index: int) -> void:
	if index <= 0:
		return
	var fresh: Array = _state.get("shortcut_fresh", [])
	var badge_seen: Array = _state.get("shortcut_badge_seen", [])
	if typeof(fresh) != TYPE_ARRAY:
		fresh = []
	if typeof(badge_seen) != TYPE_ARRAY:
		badge_seen = []
	if not fresh.has(pool) or badge_seen.has(pool):
		return
	## Bouncing pointer + Start here badge.
	var pointer := TextureRect.new()
	pointer.name = "Pointer_%s" % pool
	pointer.texture = KIT.ui_tex("map/trophy/start_pointer.png")
	pointer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pointer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pointer.stretch_mode = TextureRect.STRETCH_KEEP
	pointer.size = Vector2(48, 64)
	pointer.position = spot + Vector2(-24, -96)
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointer.z_index = 9
	_pins.add_child(pointer)
	var badge := TextureRect.new()
	badge.name = "Badge_%s" % pool
	badge.texture = KIT.ui_tex("map/trophy/badge_start_here.png")
	badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP
	badge.size = Vector2(160, 48)
	badge.position = spot + Vector2(-80, 40)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.z_index = 9
	_pins.add_child(badge)
	var lab := Label.new()
	lab.text = KIT.copy_text("map.badge.start_here")
	if lab.text.strip_edges() == "":
		lab.text = "Start here"
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 22)
	lab.add_theme_color_override("font_color", KIT.INK)
	lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(lab)
	if _reduce_motion:
		return
	var base_y: float = pointer.position.y
	var tw := create_tween()
	pointer.set_meta("loop_tw", tw)
	tw.set_loops()
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(pointer, "position:y", base_y - 8.0, 0.31)
	tw.tween_property(pointer, "position:y", base_y, 0.31)


func _maybe_add_static_path(pool: String, index: int) -> void:
	if index <= 0:
		return
	var shorts: Variant = _state.get("shortcuts", [])
	if typeof(shorts) != TYPE_ARRAY and typeof(shorts) != TYPE_PACKED_STRING_ARRAY:
		return
	if not (shorts as Array).has(pool):
		return
	var line := preload("res://scripts/cabin/map_path_line.gd").new()
	var dash: Texture2D = KIT.ui_tex("map/trophy/path_dash.png")
	line.setup(START_BANNER_BOTTOM, TRAIL[index + 1], dash)
	line.set_reduce_motion(true)
	line.appear_whole()
	var fresh: Array = _state.get("shortcut_fresh", [])
	if typeof(fresh) == TYPE_ARRAY and fresh.has(pool) and not _reduce_motion:
		line.set_reduce_motion(false)
		line._march = true
	_sheet.add_child(line)
	_path_lines.append(line)


func _clear_path_lines() -> void:
	for raw in _path_lines:
		if is_instance_valid(raw):
			(raw as Node).queue_free()
	_path_lines.clear()


func _play_reveal_fog(pool: String) -> void:
	var fog := _pins.get_node_or_null("Fog_%s" % pool) as CanvasItem
	if fog == null:
		return
	if _reduce_motion:
		KIT.cue(_find_sfx(), &"board.fog_clear")
		var tw := create_tween()
		tw.tween_property(fog, "modulate:a", 0.0, 0.3)
		await tw.finished
		fog.visible = false
		return
	for i in 6:
		if fog is TextureRect:
			var tex: Texture2D = KIT.ui_tex("map/trophy/fog_clear_f%d.png" % i)
			if tex != null:
				(fog as TextureRect).texture = tex
		await get_tree().create_timer(0.1).timeout
	fog.visible = false
	KIT.cue(_find_sfx(), &"board.fog_clear")


func _play_shortcut_reveal(pool: String) -> void:
	var biomes: Array = SHELL.biomes_of(_rules)
	var idx := -1
	for i in biomes.size():
		if str((biomes[i] as Dictionary).get("id", "")) == pool:
			idx = i
			break
	if idx < 0:
		return
	var spot: Vector2 = TRAIL[idx + 1]
	var line := preload("res://scripts/cabin/map_path_line.gd").new()
	var dash: Texture2D = KIT.ui_tex("map/trophy/path_dash.png")
	line.setup(START_BANNER_BOTTOM, spot, dash)
	line.set_reduce_motion(_reduce_motion)
	_sheet.add_child(line)
	_path_lines.append(line)
	KIT.cue(_find_sfx(), &"board.path_draw")
	await line.play_draw_in(1.2, true)
	## Ensure startable chrome is present after rebuild opts.
	_maybe_add_shortcut_chrome(pool, spot, idx)
	var pointer := _pins.get_node_or_null("Pointer_%s" % pool) as Control
	var badge := _pins.get_node_or_null("Badge_%s" % pool) as Control
	if pointer != null and not _reduce_motion:
		pointer.scale = Vector2.ZERO
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_BOUNCE)
		tw.tween_property(pointer, "scale", Vector2.ONE, 0.3)
	if badge != null:
		KIT.cue(_find_sfx(), &"board.badge_pop")
		if _reduce_motion:
			badge.scale = Vector2.ONE
		else:
			badge.scale = Vector2.ZERO
			var tw2 := create_tween()
			tw2.tween_property(badge, "scale", Vector2(1.1, 1.1), 0.15)
			tw2.tween_property(badge, "scale", Vector2.ONE, 0.15)


func _find_sfx():
	var n: Node = self
	while n:
		var bank = n.get("sfx")
		if bank != null:
			return bank
		n = n.get_parent()
	return null


func _clear_monsters() -> void:
	if _monsters == null:
		return
	for c in _monsters.get_children():
		_monsters.remove_child(c)
		c.queue_free()


func _spawn_pool_monsters(pool: String, spot: Vector2) -> void:
	## Locked/unmapped biomes never spawn. Endless has no living monsters this pass.
	if pool == "endless" or pool == "":
		return
	var nr: Variant = _state.get("next_run", {})
	if typeof(nr) != TYPE_DICTIONARY:
		return
	var deals: Variant = (nr as Dictionary).get("deals", {})
	if typeof(deals) != TYPE_DICTIONARY:
		return
	var deal: Variant = (deals as Dictionary).get(pool, {})
	if typeof(deal) != TYPE_DICTIONARY:
		return
	var telegraph: Variant = (deal as Dictionary).get("telegraph", [])
	if typeof(telegraph) != TYPE_ARRAY and typeof(telegraph) != TYPE_PACKED_STRING_ARRAY:
		return
	var seen: Array = []
	if _read_only:
		var raw_seen: Variant = _state.get("seen_deadly", [])
		if typeof(raw_seen) == TYPE_ARRAY or typeof(raw_seen) == TYPE_PACKED_STRING_ARRAY:
			for s in raw_seen:
				seen.append(str(s))
	var lanes: Array = LANES.get(pool, [])
	var slot := 0
	for raw_id in telegraph:
		var mid := str(raw_id)
		if mid == "":
			continue
		if _read_only and seen.has(mid):
			continue
		var lane: Dictionary = {}
		if slot < lanes.size():
			lane = lanes[slot]
		elif not lanes.is_empty():
			var base: Dictionary = lanes[lanes.size() - 1]
			var overflow: int = slot - (lanes.size() - 1)
			lane = {
				"at": (base.get("at", Vector2.ZERO) as Vector2) + Vector2(0, 26.0 * float(overflow)),
				"dx": float(base.get("dx", 40.0)),
			}
		else:
			lane = {"at": Vector2(40, 40), "dx": 40.0}
		var display := mid
		var card: Dictionary = _monsters_by_id.get(mid, {})
		if not card.is_empty():
			display = str(card.get("name", mid))
		var monster := MapMonster.new()
		monster.setup(mid, display, spot + (lane.get("at", Vector2.ZERO) as Vector2), float(lane.get("dx", 40.0)), _lane_rng, card)
		_monsters.add_child(monster)
		slot += 1


func _add_name(at: Vector2, biome_name: String, ink: bool, keep_on_painted: bool = false) -> void:
	## Living/ChatGPT plate already paints biome names + Endless sealed note.
	## State-only lines (depth record, open tip) pass keep_on_painted=true.
	if _plate_paints_names and not keep_on_painted:
		return
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


func _kill_peel_tween(seal: Object) -> void:
	if seal == null or not is_instance_valid(seal):
		return
	if not seal.has_meta("peel_tw"):
		return
	var prev: Variant = seal.get_meta("peel_tw")
	if prev is Tween:
		(prev as Tween).kill()


func _peel(seal: Control, up: bool) -> void:
	if not seal.has_meta("rest_y"):
		seal.set_meta("rest_y", seal.position.y)
	_kill_peel_tween(seal)
	var rest: float = float(seal.get_meta("rest_y"))
	var tw := create_tween()
	seal.set_meta("peel_tw", tw)
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(seal, "rotation", deg_to_rad(-16.0 if up else 0.0), 0.12)
	tw.parallel().tween_property(seal, "position:y", rest - (12.0 if up else 0.0), 0.12)


func _start_from_pin(index: int, shortcut: bool, endless: bool) -> void:
	if _going:
		return
	_going = true
	_hide_tip()
	_cue(&"cabin.map_pin")
	start_asked.emit(index, shortcut, endless)


func _start_from_stamp(seal: WaxStamp, index: int, endless: bool) -> void:
	if _going:
		return
	_going = true
	_hide_tip()
	await _press_flat(seal)
	_cue(&"cabin.map_pin")
	if endless:
		start_asked.emit(0, false, true)
	else:
		## Clear fresh shortcut badge on first launch from this node.
		var biomes: Array = SHELL.biomes_of(_rules)
		if index >= 0 and index < biomes.size():
			var pool := str((biomes[index] as Dictionary).get("id", ""))
			SHELL.note_shortcut_launched(_state, pool)
		## Second arg is always true for a stamp press (selftest + begin_run contract).
		start_asked.emit(index, true, false)


func _press_flat(seal: WaxStamp) -> void:
	if seal == null or not is_instance_valid(seal):
		return
	_kill_peel_tween(seal)
	if not seal.has_meta("rest_y"):
		seal.set_meta("rest_y", seal.position.y)
	var rest: float = float(seal.get_meta("rest_y"))
	seal.set_stamp_state("press")
	var tw := create_tween()
	seal.set_meta("peel_tw", tw)
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(seal, "rotation", 0.0, 0.06)
	tw.parallel().tween_property(seal, "position:y", rest + 2.0, 0.06)
	tw.parallel().tween_property(seal, "scale", Vector2(1.0, 0.88), 0.06)
	await tw.finished
	await get_tree().create_timer(0.05).timeout


func _show_tip_at(at: Vector2, text: String) -> void:
	if _tip == null or text.strip_edges() == "":
		return
	_tip.text = text
	_tip.reset_size()
	_tip.position = at - Vector2(_tip.size.x * 0.5, _tip.size.y)
	_tip.visible = true


func _hide_tip() -> void:
	if _tip:
		_tip.visible = false


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
	KIT.apply_rect(b, Rect2(1580, 24, 64, 64), 7)
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


## Heart / sword with the number on the icon — same sprites as combat callouts, smaller.
class MapStatBadge extends Control:
	var is_heart: bool = true
	var num_text: String = ""
	var _tex: Texture2D
	var _region := Rect2()

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		custom_minimum_size = Vector2(32, 36)
		size = Vector2(32, 36)
		var path := "res://assets/ui/hub/heart_full.png" if is_heart else "res://assets/ui/icons/atk_burst.png"
		if not ResourceLoader.exists(path):
			path = "res://assets/icons/heart_full.png" if is_heart else "res://assets/icons/sword.svg"
		if ResourceLoader.exists(path):
			_tex = load(path) as Texture2D
		if _tex != null:
			_region = Rect2(Vector2.ZERO, _tex.get_size())
			var img := _tex.get_image()
			if img != null:
				var used := img.get_used_rect()
				if used.size.x >= 1.0 and used.size.y >= 1.0:
					_region = used


	func _draw() -> void:
		var px := 28.0
		## Icons may sit at different optical centers; the number is always
		## on this mid-line so 6 and 5 share a row with the monster name.
		var mid := Vector2(size.x * 0.5, size.y * 0.5)
		if _tex != null:
			var icon_mid := mid
			if is_heart:
				icon_mid.y -= 1.0
			else:
				icon_mid.y += 1.0
			var rect := Rect2(icon_mid - Vector2(px, px) * 0.5, Vector2(px, px))
			for k in 8:
				var o := Vector2.from_angle(float(k) * TAU / 8.0) * 1.6
				draw_texture_rect_region(_tex, Rect2(rect.position + o, rect.size), _region, Color("100e0c"))
			draw_texture_rect_region(_tex, rect, _region, Color.WHITE)
		var font: Font = ThemeDB.fallback_font
		if font == null or num_text == "":
			return
		var fs := 12
		var tsz := font.get_string_size(num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var p := Vector2(mid.x - tsz.x * 0.5, mid.y + fs * 0.32)
		var ink := Color("100e0c")
		for ox in [-1, 0, 1]:
			for oy in [-1, 0, 1]:
				if ox == 0 and oy == 0:
					continue
				draw_string(font, p + Vector2(ox, oy), num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
		draw_string(font, p, num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("f0e6d8"))


## Tiny full-color Deadly on the parchment. Hover lifts + compact callout; click does nothing.
class MapMonster extends Control:
	const KIT := preload("res://scripts/cabin/cabin_kit.gd")
	const LINES := preload("res://scripts/monster_lines.gd")
	const UX := preload("res://scripts/ux_style.gd")
	const FACING := "res://assets/dungeon/anim/facing/%s_facing_idle_f%d.png"
	const HIT := Vector2(36, 36)
	const SHADOW_IDLE := Vector2(22, 5)
	const SHADOW_HOVER := Vector2(26, 5)
	const TAG_W := 152.0
	const TITLE_RED := Color("6E181E")
	## Flip for the two hover reads Nathan asked to see. True = name + call + HP/Attack + ability.
	static var include_stats: bool = true

	var monster_id: String = ""
	var display_name: String = ""
	var _call_name: String = ""
	var _ability: String = ""
	var _hp_n: int = 0
	var _atk_n: int = 0
	var _show_stats: bool = true
	var _anchor: Vector2 = Vector2.ZERO
	var _dx: float = 40.0
	var _body: AnimatedSprite2D
	var _shadow: ColorRect
	var _tag: PanelContainer
	var _patrol: Tween
	var _lift: Tween
	var _bob_acc: float = 0.0
	var _bob_on: bool = false
	var _hovered: bool = false
	var _body_base_y: float = -32.0


	func setup(id: String, name_text: String, foot: Vector2, dx: float, rng: RandomNumberGenerator, card: Dictionary = {}) -> void:
		monster_id = id
		display_name = name_text if name_text != "" else id
		_call_name = LINES.call_of(id, card)
		_ability = str(card.get("ability", "")).strip_edges()
		if _ability == "" or _ability == "---":
			_ability = LINES.reminder_of(id, card)
		_hp_n = _stat_base(card.get("hp", {}), card.get("hp_base", 0))
		_atk_n = _stat_base(card.get("atk", {}), card.get("atk_base", 0))
		_show_stats = include_stats
		_anchor = foot
		_dx = dx
		name = "MapMonster_%s" % id
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		size = HIT
		## Foot sits 8px above the bottom of the hit rect.
		position = foot - Vector2(HIT.x * 0.5, HIT.y - 8.0)
		_anchor = position
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_shadow = ColorRect.new()
		_shadow.name = "Shadow"
		_shadow.color = Color(0.227, 0.141, 0.078, 0.32)
		_shadow.size = SHADOW_IDLE
		_shadow.position = Vector2((HIT.x - SHADOW_IDLE.x) * 0.5, HIT.y - 10.0)
		_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_shadow)
		_body = AnimatedSprite2D.new()
		_body.name = "Body"
		_body.centered = true
		_body.offset = Vector2(0, -32)
		_body.position = Vector2(HIT.x * 0.5, HIT.y - 8.0)
		_body_base_y = _body.position.y
		_body.scale = Vector2(0.75, 0.75)
		_body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var frames := _build_frames(id)
		if frames == null:
			push_warning("living map: missing facing_idle frames for %s" % id)
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			return
		_body.sprite_frames = frames
		_body.play("idle")
		add_child(_body)
		_build_tag()
		mouse_entered.connect(_on_hover.bind(true))
		mouse_exited.connect(_on_hover.bind(false))
		gui_input.connect(_on_gui_input)
		_start_patrol(rng)


	func _build_frames(id: String) -> SpriteFrames:
		var sf := SpriteFrames.new()
		sf.add_animation("idle")
		sf.set_animation_speed("idle", 4.0)
		sf.set_animation_loop("idle", true)
		var got := 0
		for i in 4:
			var path := FACING % [id, i]
			if not ResourceLoader.exists(path):
				return null
			var tex: Texture2D = load(path) as Texture2D
			if tex == null:
				return null
			sf.add_frame("idle", tex)
			got += 1
		if got < 4:
			return null
		return sf


	func _stat_base(blob: Variant, fallback: Variant = 0) -> int:
		if typeof(blob) == TYPE_DICTIONARY and (blob as Dictionary).has("base"):
			return int(float((blob as Dictionary)["base"]))
		if typeof(fallback) == TYPE_FLOAT or typeof(fallback) == TYPE_INT:
			return int(float(fallback))
		return 0


	func _title_pill() -> PanelContainer:
		var chip := PanelContainer.new()
		chip.name = "Name"
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.custom_minimum_size.y = 36
		var chip_sb := StyleBoxFlat.new()
		chip_sb.bg_color = TITLE_RED
		chip_sb.border_color = Color("100E0C")
		chip_sb.set_border_width_all(2)
		chip_sb.content_margin_left = 10
		chip_sb.content_margin_right = 10
		chip_sb.content_margin_top = 0
		chip_sb.content_margin_bottom = 0
		chip_sb.set_corner_radius_all(8)
		chip.add_theme_stylebox_override("panel", chip_sb)
		var lab: FitLabelBox = KIT.fit_label(
			"",
			Rect2(0, 0, 140, 36),
			14,
			10,
			1,
			Color("F8F2EA"),
			HORIZONTAL_ALIGNMENT_CENTER
		)
		lab.name = "Label"
		lab.grow_to_text = true
		lab.max_width = 160
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.set_plain(display_name)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.custom_minimum_size.y = 36
		chip.add_child(lab)
		return chip


	func _stat_badge(heart: bool, n: int) -> MapStatBadge:
		var b := MapStatBadge.new()
		b.is_heart = heart
		b.num_text = str(n)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return b


	func _layout_head() -> void:
		var head := _tag.get_node_or_null("Col/Head") as Control
		if head == null:
			return
		var pill := head.get_node_or_null("Name") as Control
		if pill == null:
			return
		var name_lab := pill.get_node_or_null("Label") as FitLabelBox
		if name_lab:
			name_lab.fit()
		pill.reset_size()


	func _build_tag() -> void:
		_tag = PanelContainer.new()
		_tag.name = "Tag"
		_tag.visible = false
		_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_tag.z_index = 20
		_tag.z_as_relative = true
		var sb := StyleBoxFlat.new()
		## Square plaque: cream on parchment. Ability wraps to about three lines.
		sb.bg_color = Color("FFF6DE")
		sb.border_color = Color("1A120E")
		sb.set_border_width_all(2)
		sb.shadow_size = 3
		sb.shadow_offset = Vector2(0, 3)
		sb.shadow_color = Color(0.102, 0.071, 0.055, 0.85)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 8
		sb.content_margin_bottom = 10
		sb.set_corner_radius_all(0)
		_tag.add_theme_stylebox_override("panel", sb)
		var col := VBoxContainer.new()
		col.name = "Col"
		col.add_theme_constant_override("separation", 6)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		_tag.add_child(col)
		var head := HBoxContainer.new()
		head.name = "Head"
		head.add_theme_constant_override("separation", 10)
		head.mouse_filter = Control.MOUSE_FILTER_IGNORE
		head.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(head)
		if _hp_n > 0 or _atk_n > 0:
			var hp := _stat_badge(true, _hp_n)
			hp.name = "Hp"
			hp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			head.add_child(hp)
		head.add_child(_title_pill())
		if _hp_n > 0 or _atk_n > 0:
			var atk := _stat_badge(false, _atk_n)
			atk.name = "Atk"
			atk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			head.add_child(atk)
		if _ability != "":
			var body := Label.new()
			body.name = "Ability"
			body.text = _ability
			body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			body.max_lines_visible = 4
			body.custom_minimum_size = Vector2(TAG_W, 0)
			body.add_theme_font_size_override("font_size", 11)
			body.add_theme_color_override("font_color", Color("2A1C14"))
			body.mouse_filter = Control.MOUSE_FILTER_IGNORE
			col.add_child(body)
		var tip := Polygon2D.new()
		tip.name = "Pointer"
		tip.color = Color("1A120E")
		tip.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(10, 0), Vector2(5, 5),
		])
		tip.set_meta("is_pointer", true)
		_tag.add_child(tip)
		add_child(_tag)
		call_deferred("_place_tag")


	func _place_tag() -> void:
		if _tag == null:
			return
		_layout_head()
		_tag.reset_size()
		var tag_sz: Vector2 = _tag.get_combined_minimum_size()
		if tag_sz.x < 8.0 or tag_sz.y < 8.0:
			tag_sz = _tag.size
		if tag_sz.x < 8.0 or tag_sz.y < 8.0:
			tag_sz = Vector2(TAG_W + 24.0, 52.0)
			_tag.size = tag_sz
		else:
			_tag.size = tag_sz
		var foot_local := Vector2(HIT.x * 0.5, HIT.y - 8.0)
		var at := foot_local + Vector2(-tag_sz.x * 0.5, -tag_sz.y - 48.0)
		## Clamp to the sheet in parent space.
		var parent_sz := Vector2(1680, 1040)
		if get_parent() is Control:
			var psz: Vector2 = (get_parent() as Control).size
			if psz.x > 1.0 and psz.y > 1.0:
				parent_sz = psz
		var world := position + at
		world.x = clampf(world.x, 8.0, maxf(8.0, parent_sz.x - tag_sz.x - 8.0))
		world.y = clampf(world.y, 8.0, maxf(8.0, parent_sz.y - tag_sz.y - 8.0))
		_tag.position = world - position
		for child in _tag.get_children():
			if child is Polygon2D and child.has_meta("is_pointer"):
				(child as Polygon2D).position = Vector2(tag_sz.x * 0.5 - 5.0, tag_sz.y)


	func _start_patrol(rng: RandomNumberGenerator) -> void:
		if _body == null:
			return
		var period: float = rng.randf_range(4.0, 6.0)
		var pause: float = rng.randf_range(1.0, 2.0)
		_patrol = create_tween()
		_patrol.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_patrol.set_loops()
		_patrol.set_trans(Tween.TRANS_SINE)
		_patrol.set_ease(Tween.EASE_IN_OUT)
		_patrol.tween_property(self, "position:x", _anchor.x + _dx, period)
		_patrol.tween_interval(pause)
		_patrol.tween_property(self, "position:x", _anchor.x, period)
		_patrol.tween_interval(pause)
		## Random phase so monsters sharing a biome stay out of step.
		var cycle: float = period * 2.0 + pause * 2.0
		var seek_t: float = rng.randf() * cycle
		_patrol.custom_step(seek_t)


	func _process(delta: float) -> void:
		if _body == null or _hovered:
			return
		_bob_acc += delta
		if _bob_acc < 0.45:
			return
		_bob_acc = 0.0
		_bob_on = not _bob_on
		_body.position.y = _body_base_y + (-3.0 if _bob_on else 0.0)


	func _on_hover(_on: bool) -> void:
		## Next-run mill monsters are unfought. Do not lift them or open the
		## name / HP / ability plaque — that read as collected / unlocked.
		if _tag:
			_tag.visible = false


	func _on_gui_input(event: InputEvent) -> void:
		## Clicking a monster does nothing (no start, no cue).
		if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			accept_event()


class RouteInk extends Control:
	var pts: PackedVector2Array = PackedVector2Array()
	var solid: int = 1
	## Trail segment indices drawn as grey pencil (just stamped) instead of solid ink.
	var fresh: Array = []

	func _draw() -> void:
		if pts.size() < 2:
			return
		for i in pts.size() - 1:
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[i + 1]
			if fresh.has(i):
				_pencil(a, b)
			elif i < solid:
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


	func _pencil(a: Vector2, b: Vector2) -> void:
		var dir := b - a
		var dist := dir.length()
		if dist < 1.0:
			return
		dir /= dist
		var t := 0.0
		while t < dist:
			var t2: float = minf(t + 10.0, dist)
			draw_line(a + dir * t, a + dir * t2, Color("6a6a6a"), 4.0, false)
			t += 16.0


class WaxStamp extends Control:
	const KIT := preload("res://scripts/cabin/cabin_kit.gd")
	var wax: Color = Color("5f8f3c")
	var pool_slug: String = ""
	## idle | hover | press — picks stamp_<slug>_<state>.png when present.
	var state: String = "idle"
	## Hollow / sealed node: stamp_locked.png or stamp_endless_sealed.png.
	var sealed: bool = false
	var _tex: Texture2D = null

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


	func set_stamp_state(next: String) -> void:
		var want := next if next in ["idle", "hover", "press"] else "idle"
		if state == want and _tex != null:
			return
		state = want
		_reload_tex()
		queue_redraw()


	func _reload_tex() -> void:
		_tex = null
		if sealed:
			var sealed_rel := "map/stamps/stamp_endless_sealed.png" if pool_slug == "endless" else "map/stamps/stamp_locked.png"
			_tex = KIT.ui_tex(sealed_rel)
			return
		if pool_slug == "":
			return
		_tex = KIT.ui_tex("map/stamps/stamp_%s_%s.png" % [pool_slug, state])
		if _tex == null and state != "idle":
			_tex = KIT.ui_tex("map/stamps/stamp_%s_idle.png" % pool_slug)


	func _draw() -> void:
		if _tex == null:
			_reload_tex()
		if _tex:
			## 112×112 source drawn into the 56×56 control (0.5 scale), Nearest.
			draw_texture_rect(_tex, Rect2(Vector2.ZERO, size), false)
			return
		if sealed:
			var c0 := size * 0.5
			var rad0: float = minf(size.x, size.y) * 0.42
			draw_arc(c0, rad0, 0, TAU, 20, Color("8a7d70"), 3.0, true)
			return
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
