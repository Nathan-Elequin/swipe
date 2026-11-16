extends SceneTree
## Every biome portal unlock (faces 0..4) uses the Crystal Cavern structure.
## Run: godot --headless --path . --script res://scripts/dev/biome_unlock_all_selftest.gd
## Expect: BIOME_UNLOCK_ALL_OK


const SHELL := preload("res://scripts/campaign_shell.gd")
const SEQ := preload("res://scripts/cabin/board_sequences.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const COPY := preload("res://scripts/player_copy.gd")
const SPLASH := preload("res://scripts/ui/biome_splash.gd")

const EXPECT := [
	{"face": 0, "from": "b1", "next": "b2", "slug": "crystal", "bucket": 2, "art": "portal_crystal.png", "endless": false},
	{"face": 1, "from": "b2", "next": "b3", "slug": "ashen", "bucket": 3, "art": "portal_ashen.png", "endless": false},
	{"face": 2, "from": "b3", "next": "b4", "slug": "cinder", "bucket": 4, "art": "portal_cinder.png", "endless": false},
	{"face": 3, "from": "b4", "next": "b5", "slug": "shadow", "bucket": 5, "art": "portal_shadow.png", "endless": false},
	{"face": 4, "from": "b5", "next": "endless", "slug": "endless", "bucket": -1, "art": "portal_endless.png", "endless": true},
]


func _init() -> void:
	COPY.reload()
	var failed := false
	failed = _check_copy_keys() or failed
	failed = await _run_all_faces() or failed
	if failed:
		print("BIOME_UNLOCK_ALL_FAIL")
		quit(1)
	print("BIOME_UNLOCK_ALL_OK")
	quit(0)


func _check_copy_keys() -> bool:
	var failed := false
	for row in EXPECT:
		var slug: String = str(row["slug"])
		for part in ["1", "2", "rumble_wake", "map", "reveal.1", "reveal.2"]:
			var key := "nib.portal.%s.%s" % [slug, part]
			var text: String = COPY.text(key, "")
			failed = _check(failed, "copy.%s" % key, text.strip_edges() != "") or failed
			## Never ship Tier / ATK to players.
			failed = _check(failed, "copy.no_tier.%s" % key, text.find("Tier") < 0 and text.find("ATK") < 0) or failed
	failed = _check(failed, "copy.endless.main", COPY.text("nib.portal.endless", "").find("bottom") >= 0) or failed
	## Crystal splash line 1 stays the discovery line.
	failed = _check(
		failed,
		"copy.crystal.1",
		COPY.text("nib.portal.crystal.1", "") == "So THAT's what it does!"
	) or failed
	return failed


func _run_all_faces() -> bool:
	var failed := false
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	for row in EXPECT:
		failed = await _run_one(rules, row) or failed
	return failed


func _run_one(rules: Dictionary, row: Dictionary) -> bool:
	var failed := false
	var face: int = int(row["face"])
	var label := "face%d.%s" % [face, row["slug"]]
	var host := Control.new()
	host.name = "CabinRoot"
	host.size = Vector2(1680, 1040)
	host.visible = true
	root.add_child(host)

	var state: Dictionary = SHELL.fresh_state()
	state["migrated_board_v1"] = true
	## Prior portals already open so this face's next unlock is the one under test.
	for prior in EXPECT:
		if int(prior["face"]) >= face:
			break
		_fill_stored(state, str(prior["from"]), 5)
		SHELL.open_portal(rules, state, str(prior["from"]))
	_fill_stored(state, str(row["from"]), 5)

	var cabin = _SpyCabin.new()
	host.add_child(cabin)
	cabin.bind(rules, state)
	await process_frame

	var seq = SEQ.new()
	host.add_child(seq)
	seq.reduce_motion = true
	Engine.time_scale = 8.0
	seq.setup(cabin, null, cabin.sfx, null, cabin)
	## Fake campaign map that supports closed + peek_closed (soft-lock regression).
	var cmap = _SpyCampaignMap.new()
	host.add_child(cmap)
	seq.set_campaign_map(cmap)

	await seq.portal(face)
	await process_frame

	var next_id: String = str(row["next"])
	failed = _check(failed, "%s.busy_clear" % label, seq.is_busy() == false) or failed
	failed = _check(failed, "%s.landed_hall" % label, seq.last_landed_hall) or failed
	failed = _check(
		failed,
		"%s.portal_opened" % label,
		SHELL.portal_opened(cabin._campaign_shell.state, next_id)
	) or failed
	failed = _check(
		failed,
		"%s.splash_art" % label,
		seq.last_splash_art.ends_with(str(row["art"]))
	) or failed
	failed = _check(
		failed,
		"%s.music" % label,
		seq.last_splash_music == next_id or seq.last_splash_music == str(row["slug"])
	) or failed
	## Per-biome keys requested on the splash (.1 / .2).
	var splash_keys := ",".join(PackedStringArray(seq.last_splash_nib_keys.map(func(k): return str(k))))
	if bool(row["endless"]):
		failed = _check(
			failed,
			"%s.keys.endless" % label,
			splash_keys.find("nib.portal.endless") >= 0
		) or failed
		failed = _check(failed, "%s.no_bucket" % label, seq.last_reveal_bucket < 0) or failed
		failed = _check(
			failed,
			"%s.map_reveal" % label,
			str(seq.last_map_opts.get("reveal", "")) == "endless"
		) or failed
	else:
		failed = _check(
			failed,
			"%s.keys.slug" % label,
			splash_keys.find("nib.portal.%s." % row["slug"]) >= 0
		) or failed
		failed = _check(
			failed,
			"%s.bucket" % label,
			seq.last_reveal_bucket == int(row["bucket"])
		) or failed
		failed = _check(
			failed,
			"%s.map_reveal" % label,
			str(seq.last_map_opts.get("reveal", "")) == next_id
		) or failed
	failed = _check(failed, "%s.no_dev_strip" % label, not cabin.dev_strip_shown) or failed
	failed = _check(failed, "%s.no_tut_overlay" % label, not cabin.tutorial_shown) or failed
	failed = _check(failed, "%s.cabin_visible" % label, cabin.visible) or failed
	failed = _check(failed, "%s.input_ok" % label, not seq.is_busy()) or failed
	## No leftover opaque BiomeSplash / wipe.
	failed = _scan_opaque(failed, host, label) or failed

	Engine.time_scale = 1.0
	host.queue_free()
	await process_frame
	return failed


func _scan_opaque(failed: bool, host: Node, label: String) -> bool:
	var bad: Array = []
	_collect_opaque(host, bad)
	var ok := bad.is_empty()
	if not ok:
		print("FAIL opaque.", label, " → ", bad)
	else:
		print("OK opaque.", label)
	return failed or not ok


func _collect_opaque(n: Node, out: Array) -> void:
	if n == null or not is_instance_valid(n):
		return
	if n is ColorRect:
		var cr := n as ColorRect
		if cr.visible and cr.modulate.a > 0.05:
			if str(cr.name) == "BoardFadeWipe" or cr.z_index >= 100:
				out.append("%s a=%.2f" % [cr.get_path(), cr.modulate.a])
	if n is CanvasLayer and n.visible and str(n.name) == "BiomeSplash":
		out.append("%s BiomeSplash visible" % n.get_path())
	if n.get_script() == SPLASH and n.get("visible") == true:
		out.append("%s splash script visible" % n.get_path())
	for c in n.get_children():
		_collect_opaque(c, out)


func _fill_stored(state: Dictionary, pool: String, n: int) -> void:
	var banked: Dictionary = state.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
		state["banked"] = banked
	for i in n:
		banked["%s_fill_%d" % [pool, i]] = pool


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("OK ", label)
		return failed
	print("FAIL ", label)
	return true


class _SpySfx extends RefCounted:
	var last_biome: String = ""

	func music_biome_dungeon(biome_id: String, _fade_s: float = -1.0) -> void:
		last_biome = str(biome_id)

	func music_cabin() -> void:
		pass

	func music_to(_bed: StringName, _fade: float = 0.8) -> void:
		pass

	func play_event(_id: StringName) -> void:
		pass

	func play(_id: String, _db: float = 0.0, _pitch: float = 1.0) -> void:
		pass


class _SpyDialog extends Node:
	signal finished(choice: int)
	var last_keys: Array = []

	func say(keys: Array, _choices: Array = [], _vars: Dictionary = {}, _fallbacks: Dictionary = {}) -> void:
		last_keys = keys.duplicate()
		call_deferred("_emit_done")

	func _emit_done() -> void:
		finished.emit(-1)

	func _close(_c: int = -1) -> void:
		finished.emit(_c)


class _SpyBucketReveal extends Control:
	signal finished
	var _go: bool = false
	var _playing: bool = false
	var last_bucket: int = -1

	func _ready() -> void:
		visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS

	func force_continue() -> void:
		_go = true

	func play(bucket_n: int, _entries: Array) -> void:
		_playing = true
		last_bucket = bucket_n
		visible = true
		_go = false
		if Engine.time_scale >= 4.0:
			_go = true
		while not _go:
			await get_tree().process_frame
		_playing = false
		visible = false
		finished.emit()


class _SpyCampaignMap extends Control:
	signal closed
	signal peek_closed
	signal continued
	var _held: Control = null
	var last_opts: Dictionary = {}

	func _ready() -> void:
		visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS
		_held = Control.new()
		_held.name = "Held"
		_held.visible = false
		add_child(_held)

	func held_map() -> Control:
		return _held

	func show_map(_rules: Dictionary, _state: Dictionary, _m: Dictionary = {}, opts: Dictionary = {}) -> void:
		last_opts = opts.duplicate(true)
		visible = true
		_held.visible = true

	func hide_map() -> void:
		visible = false
		_held.visible = false

	func present(_rules: Dictionary, _state: Dictionary, _m: Dictionary = {}, opts: Dictionary = {}) -> void:
		show_map(_rules, _state, _m, opts)


class _SpyCabin extends Control:
	var items_by_id: Dictionary = {}
	var _campaign_shell = null
	var _rules: Dictionary = {}
	var sfx = null
	var hero_name := "Sprout"
	var _current_room := "hall"
	var _int_root: Control = null
	var _dialog = null
	var _bucket_reveal = null
	var _unlock_screen: bool = false
	var overlay: Control = null
	var overlay_tools_row: Control = null
	var overlay_dev: Control = null
	var tut: Control = null
	var dev_strip_shown: bool = false
	var tutorial_shown: bool = false

	func _ready() -> void:
		_int_root = Control.new()
		_int_root.name = "RoomsClip"
		_int_root.visible = true
		add_child(_int_root)
		_ensure_fade()
		sfx = _SpySfx.new()
		_dialog = _SpyDialog.new()
		add_child(_dialog)
		_bucket_reveal = _SpyBucketReveal.new()
		add_child(_bucket_reveal)
		overlay = Control.new()
		overlay.visible = false
		add_child(overlay)
		overlay_tools_row = Control.new()
		overlay_tools_row.visible = false
		add_child(overlay_tools_row)
		overlay_dev = Control.new()
		overlay_dev.visible = false
		add_child(overlay_dev)
		tut = Control.new()
		tut.visible = false
		add_child(tut)

	func bind(rules: Dictionary, state: Dictionary) -> void:
		_rules = rules
		_campaign_shell = load("res://scripts/campaign_shell.gd").new()
		_campaign_shell.rules = rules
		_campaign_shell.state = state

	func _ensure_fade() -> ColorRect:
		var wipe = get_node_or_null("BoardFadeWipe")
		if wipe is ColorRect:
			return wipe as ColorRect
		wipe = ColorRect.new()
		wipe.name = "BoardFadeWipe"
		wipe.color = Color("0B0706")
		wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wipe.size = Vector2(1680, 1040)
		wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wipe.z_index = 200
		wipe.visible = false
		wipe.modulate.a = 0.0
		add_child(wipe)
		return wipe as ColorRect

	func hide_cabin_dev_strip() -> void:
		dev_strip_shown = false

	func show_menu(room: String = "hall") -> void:
		_current_room = room
		visible = true

	func pan_to(room: String) -> void:
		_current_room = room
		visible = true

	func _release_cabin_tree_pause() -> void:
		if is_inside_tree():
			get_tree().paused = false

	func _biome_rules() -> Dictionary:
		return _rules

	func _campaign_shell_state() -> Dictionary:
		if _campaign_shell != null:
			return _campaign_shell.state
		return {}

	func bucket_reveal_for(bucket_n: int) -> Array:
		return [{"id": "spy_%d" % bucket_n, "name": "Spy", "kind": "Loot"}]

	func _bucket_entries(bucket_n: int) -> Array:
		return bucket_reveal_for(bucket_n)

	func _hide_board_for_unlock() -> void:
		pass

	func nib_talk(_on: bool = true) -> void:
		pass

	func nib_gasp() -> void:
		pass

	func nib_react() -> void:
		pass

	func clear_nib_pointer() -> void:
		pass
