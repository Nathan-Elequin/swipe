class_name BoardSequences
extends Node
## Portal (lever) and shortcut (100%) timelines. Package D.
## Host under home_cabin. Uses TrophyBoard API from Package B.


signal portal_finished(face_index: int)
signal shortcut_finished(face_index: int)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const SPLASH := preload("res://scripts/ui/biome_splash.gd")
const PATH_LINE := preload("res://scripts/cabin/map_path_line.gd")
const COPY := preload("res://scripts/player_copy.gd")

const RUMBLE_S := 1.4
const START_BANNER_BOTTOM := Vector2(945, 217)

var cabin = null
var board = null
var sfx = null
var held_map = null
var campaign_map = null
var main_ref = null
var reduce_motion := false

## Test spies (board_gates_selftest).
var last_reveal_bucket: int = -1
var last_reveal_entries: Array = []
var last_map_opts: Dictionary = {}
var _busy := false


func setup(p_cabin, p_board, p_sfx = null, p_held_map = null, p_main = null) -> void:
	cabin = p_cabin
	board = p_board
	sfx = p_sfx
	held_map = p_held_map
	main_ref = p_main
	name = "BoardSequences"


func set_campaign_map(m) -> void:
	campaign_map = m


## Player pulled a READY lever on face_index.
func portal(face_index: int) -> void:
	if _busy:
		return
	_busy = true
	var rules: Dictionary = _rules()
	var state: Dictionary = _state()
	var faces: Array = MODEL.faces(rules, _items())
	if face_index < 0 or face_index >= faces.size():
		_busy = false
		return
	var face: Dictionary = faces[face_index]
	var pool_id := str(face.get("pool_id", ""))
	## Commit save first (SCREEN §7.1).
	var nxt: Dictionary = SHELL.open_portal(rules, state, pool_id)
	_write()
	if board != null and board.has_method("refresh"):
		board.refresh()
	KIT.cue(sfx, &"board.lever_clunk")
	await _wait(0.45)
	await _play_rumble()
	await _fade(0.3, true)
	var next_id := str(nxt.get("id", MODEL.next_biome_id(rules, face)))
	var next_name := str(nxt.get("name", SHELL.biome_name(rules, next_id)))
	var prev_name := str(face.get("name", ""))
	var vars := _token_vars(face, next_name, prev_name)
	if bool(nxt.get("endless", false)) or next_id == "endless":
		await _play_splash(
			"endless",
			"res://assets/ui/trophy_board/splash/portal_endless.png",
			["nib.portal.endless"],
			vars,
			&"sting.portal_open"
		)
		await _fade(0.3, false)
		if board != null and board.has_method("slide_to"):
			board.slide_to(face_index, true)
		_busy = false
		portal_finished.emit(face_index)
		return
	var slug := str(MODEL.SLUGS.get(next_id, next_id))
	var art := "res://assets/ui/trophy_board/splash/portal_%s.png" % slug
	await _play_splash(next_id, art, ["nib.portal.1", "nib.portal.2"], vars, &"sting.portal_open")
	await _fade(0.3, true)
	## Map beat: fog clears, node becomes Known (not startable).
	await _present_map({"reveal": next_id, "read_only": true}, ["nib.portal.map"], vars)
	await _fade(0.3, true)
	## Same new-pool reveal as the tutorial path.
	var bucket_n: int = face_index + 2
	await _play_bucket_reveal(bucket_n, ["nib.portal.reveal.1", "nib.portal.reveal.2"], vars)
	await _fade(0.3, false)
	if board != null and board.has_method("slide_to"):
		board.slide_to(face_index, true)
	if board != null and board.has_method("refresh"):
		board.refresh()
	## If this face is also complete, hand off to shortcut.
	if MODEL.is_complete(state, face) and not _board_complete_seen(pool_id):
		_busy = false
		await shortcut(face_index)
		return
	_busy = false
	portal_finished.emit(face_index)


## Face first reaches 100% (b1–b4 → shortcut; b5 → ending drawer).
func shortcut(face_index: int) -> void:
	if _busy:
		return
	_busy = true
	var rules: Dictionary = _rules()
	var state: Dictionary = _state()
	var faces: Array = MODEL.faces(rules, _items())
	if face_index < 0 or face_index >= faces.size():
		_busy = false
		return
	var face: Dictionary = faces[face_index]
	var pool_id := str(face.get("pool_id", ""))
	if _board_complete_seen(pool_id):
		_busy = false
		return
	if board != null and board.has_method("play_gild"):
		board.play_gild(face_index, reduce_motion)
	KIT.cue(sfx, &"board.complete_chime")
	await _wait(0.8 if not reduce_motion else 0.3)
	var vars := _token_vars(face, "", str(face.get("name", "")))
	await _nib(["nib.shortcut.1"] if face_index < 4 else ["nib.board.complete_final"], vars)
	## Shadow Abyss 100%: ending drawer, no shortcut.
	if face_index >= 4 or pool_id == SHELL.last_tip_biome_id(rules):
		SHELL.mark_board_complete_seen(state, pool_id)
		var end: Dictionary = SHELL.complete_abyss_board(rules, state, _items())
		_write()
		if bool(end.get("show_drawer", false)) and campaign_map != null and campaign_map.has_method("show_drawer"):
			campaign_map.show_drawer()
			if campaign_map.has_signal("continued"):
				await campaign_map.continued
			SHELL.mark_drawer_seen(state)
			_write()
			if campaign_map.has_method("hide_map"):
				campaign_map.hide_map()
		_busy = false
		shortcut_finished.emit(face_index)
		return
	var next_id := MODEL.next_biome_id(rules, face)
	var next_name := SHELL.biome_name(rules, next_id)
	vars = _token_vars(face, next_name, str(face.get("name", "")))
	var slug := str(MODEL.SLUGS.get(next_id, next_id))
	var art := "res://assets/ui/trophy_board/splash/shortcut_%s.png" % slug
	await _fade(0.3, true)
	await _play_splash(next_id, art, ["nib.shortcut.2"], vars, &"sting.shortcut")
	## Commit shortcut + fresh badge.
	SHELL.grant_shortcut(rules, state, next_id)
	SHELL.mark_board_complete_seen(state, pool_id)
	_write()
	await _present_map(
		{"shortcut_reveal": next_id, "read_only": true},
		["nib.shortcut.3"],
		vars
	)
	await _fade(0.3, false)
	if board != null and board.has_method("slide_to"):
		board.slide_to(face_index, true)
	_busy = false
	shortcut_finished.emit(face_index)


# --- beats ------------------------------------------------------------------


func _play_rumble() -> void:
	KIT.cue(sfx, &"board.rumble")
	if sfx != null and sfx.has_method("duck_music"):
		sfx.duck_music(-8)
	var root: Node = cabin if cabin != null else self
	var shake_target: Node2D = null
	if cabin != null and cabin.get("_int_root") is Node2D:
		shake_target = cabin.get("_int_root")
	elif cabin != null and cabin is Node2D:
		shake_target = cabin
	if reduce_motion:
		## Dim pulse instead of shake / dust.
		if root is CanvasItem:
			var ci := root as CanvasItem
			var base := ci.modulate
			var tw := create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_property(ci, "modulate", base.darkened(0.25), 0.2)
			tw.tween_property(ci, "modulate", base, 0.2)
			await tw.finished
		else:
			await _wait(0.4)
	else:
		await _shake_and_dust(shake_target, RUMBLE_S)
	if sfx != null and sfx.has_method("unduck"):
		sfx.unduck(0.6)


func _shake_and_dust(target: Node2D, seconds: float) -> void:
	var host: Node = cabin if cabin != null else self
	var dust_parent: Node = host
	if cabin != null and cabin.get("_int_root") != null:
		dust_parent = cabin.get("_int_root")
	for i in 10:
		var mote := TextureRect.new()
		mote.texture = KIT.ui_tex("trophy_board/dust_fall_f0.png")
		mote.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		mote.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		mote.stretch_mode = TextureRect.STRETCH_KEEP
		mote.size = Vector2(16, 16)
		mote.position = Vector2(randf() * 1680.0, -16.0 - randf() * 40.0)
		mote.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mote.z_index = 80
		dust_parent.add_child(mote)
		var fall_t: float = 0.6 + randf() * 0.5
		var delay: float = randf() * 0.8
		var twm := create_tween()
		twm.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		twm.tween_interval(delay / maxf(0.001, Engine.time_scale))
		twm.tween_property(mote, "position:y", 900.0 + randf() * 120.0, fall_t / maxf(0.001, Engine.time_scale))
		twm.tween_callback(mote.queue_free)
	if target == null:
		await _wait(seconds)
		return
	var origin := target.position
	var elapsed := 0.0
	var step := 1.0 / 30.0
	while elapsed < seconds:
		var amp: float = 10.0 * (1.0 - elapsed / seconds)
		target.position = origin + Vector2(randf_range(-amp, amp), randf_range(-amp, amp))
		await _wait(step)
		elapsed += step
	target.position = origin


func _play_splash(
	biome_id: String,
	art_path: String,
	nib_keys: Array,
	vars: Dictionary,
	sting: StringName
) -> void:
	KIT.cue(sfx, sting)
	var splash = SPLASH.new()
	var layer_parent: Node = cabin if cabin != null else self
	layer_parent.add_child(splash)
	var ctx := {
		"biome_name": SHELL.biome_name(_rules(), biome_id) if biome_id != "endless" else "Endless",
		"art_override": art_path,
		"nib_lines": nib_keys,
		"nib_vars": vars,
		"dungeon": 0,
	}
	await splash.play_in(biome_id if biome_id != "endless" else "b5", ctx)
	## Headless / fast selftests cannot click — auto-dismiss.
	if reduce_motion or Engine.time_scale >= 4.0:
		if splash.has_method("_dismiss_from_input"):
			splash._dismiss_from_input()
		elif splash.has_signal("dismissed"):
			splash.dismissed.emit()
	else:
		await splash.wait_dismissed()
	await splash.play_out()


func _present_map(opts: Dictionary, nib_keys: Array, vars: Dictionary) -> void:
	last_map_opts = opts.duplicate(true)
	var map = held_map
	if map == null and cabin != null and cabin.get("held_map") != null:
		map = cabin.held_map
	if map == null and campaign_map != null and campaign_map.has_method("show_map"):
		campaign_map.show_map(_rules(), _state(), {}, opts)
		map = campaign_map.get("held") if campaign_map.get("held") != null else campaign_map
	if map != null and map.has_method("present"):
		map.present(_rules(), _state(), {}, opts)
	await _nib(nib_keys, vars)
	## Wait for continue / Space — read_only map closes via closed signal or button.
	if map != null and map.has_signal("closed"):
		## Auto-continue after a short beat in headless / reduce path.
		if Engine.is_editor_hint() or reduce_motion or Engine.time_scale >= 4.0:
			await _wait(0.2)
			if map.has_method("hide") or map.get("visible") == true:
				map.visible = false
				if map.has_signal("closed"):
					map.closed.emit()
		else:
			await map.closed
	else:
		await _wait(0.2)
	if map != null:
		map.visible = false


func _play_bucket_reveal(bucket_n: int, nib_keys: Array, vars: Dictionary) -> void:
	last_reveal_bucket = bucket_n
	var entries: Array = []
	if main_ref != null and main_ref.has_method("bucket_reveal_for"):
		entries = main_ref.bucket_reveal_for(bucket_n)
	elif main_ref != null and main_ref.has_method("_bucket_entries"):
		entries = main_ref._bucket_entries(bucket_n)
	last_reveal_entries = entries.duplicate()
	if main_ref != null and main_ref.get("_bucket_reveal") != null:
		var br = main_ref.get("_bucket_reveal")
		if br.has_method("play"):
			## Fire Nib lines after cards pop — best-effort overlay.
			call_deferred("_nib_after_reveal_start", br, nib_keys, vars)
			await br.play(bucket_n, entries)
			return
	## Headless / missing reveal: still record the call.
	await _nib(nib_keys, vars)


func _nib_after_reveal_start(br, nib_keys: Array, vars: Dictionary) -> void:
	await _wait(0.6)
	await _nib(nib_keys, vars)


func _nib(keys: Array, vars: Dictionary) -> void:
	if keys.is_empty():
		return
	if cabin != null and cabin.has_method("nib_talk"):
		## Prefer cabin dialog if present.
		var dialog = cabin.get("_dialog")
		if dialog != null and dialog.has_method("say"):
			dialog.say(keys, [], vars)
			if dialog.has_signal("finished"):
				await dialog.finished
				return
	## Fallback: no-op wait so sequences stay timed in tests.
	await _wait(0.05)


func _fade(seconds: float, to_black: bool) -> void:
	if reduce_motion or Engine.time_scale >= 4.0:
		await _wait(seconds)
		return
	var wipe: ColorRect = null
	if cabin != null and cabin.has_method("_ensure_fade"):
		wipe = cabin._ensure_fade()
	if wipe == null:
		wipe = ColorRect.new()
		wipe.color = Color("0B0706")
		wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wipe.z_index = 200
		var parent: Node = cabin if cabin != null else self
		parent.add_child(wipe)
	wipe.visible = true
	wipe.modulate.a = 0.0 if to_black else 1.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(wipe, "modulate:a", 1.0 if to_black else 0.0, seconds / maxf(0.001, Engine.time_scale))
	await tw.finished
	if not to_black:
		wipe.visible = false


func _wait(seconds: float) -> void:
	var t: float = seconds / maxf(0.001, Engine.time_scale)
	var tree: SceneTree = get_tree()
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	await tree.create_timer(t).timeout


func _token_vars(face: Dictionary, next_name: String, biome_or_prev: String) -> Dictionary:
	var hero := "Sprout"
	if cabin != null and cabin.get("hero_name") != null:
		hero = str(cabin.hero_name)
	return {
		"hero": hero,
		"biome": str(face.get("name", biome_or_prev)),
		"prev": biome_or_prev,
		"next": next_name,
		"the_grumble": "the Grumble",
		"grandpa|poss": "Grandpa's",
	}


func _rules() -> Dictionary:
	if cabin != null and cabin.has_method("_biome_rules"):
		return cabin._biome_rules()
	if main_ref != null and main_ref.get("_campaign") != null:
		return main_ref._campaign.rules
	return SHELL.read_json(SHELL.DATA_PATH)


func _state() -> Dictionary:
	if cabin != null and cabin.get("_campaign_shell") != null:
		return cabin._campaign_shell.state
	if cabin != null and cabin.has_method("_campaign_shell_state"):
		return cabin._campaign_shell_state()
	if main_ref != null and main_ref.get("_campaign") != null:
		return main_ref._campaign.state
	return SHELL.fresh_state()


func _items() -> Dictionary:
	if cabin != null and typeof(cabin.get("items_by_id")) == TYPE_DICTIONARY:
		return cabin.items_by_id
	if main_ref != null and typeof(main_ref.get("items_by_id")) == TYPE_DICTIONARY:
		return main_ref.items_by_id
	return {}


func _write() -> void:
	if cabin != null and cabin.get("_campaign_shell") != null and cabin._campaign_shell.has_method("write"):
		cabin._campaign_shell.write()
	elif main_ref != null and main_ref.get("_campaign") != null and main_ref._campaign.has_method("write"):
		main_ref._campaign.write()


func _board_complete_seen(pool_id: String) -> bool:
	var seen: Variant = _state().get("board_complete_seen", [])
	if typeof(seen) != TYPE_ARRAY and typeof(seen) != TYPE_PACKED_STRING_ARRAY:
		return false
	return (seen as Array).has(pool_id)
