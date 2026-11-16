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

## Test spies (board_gates_selftest / biome_unlock_all_selftest).
var last_reveal_bucket: int = -1
var last_reveal_entries: Array = []
var last_map_opts: Dictionary = {}
var last_splash_art: String = ""
var last_splash_music: String = ""
var last_nib_keys: Array = []
var last_splash_nib_keys: Array = []
var last_landed_hall: bool = false
## Package E selftest: true only when a rumble shake tween/loop actually runs.
var last_shake_created: bool = false
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
## Same structure for every face: clunk → rumble → splash → hall → wake → map →
## (bucket reveal when the next biome has a pool) → hall. Endless skips bucket reveal.
func portal(face_index: int) -> void:
	if _busy:
		return
	_busy = true
	last_landed_hall = false
	last_splash_art = ""
	last_splash_music = ""
	last_nib_keys = []
	last_reveal_bucket = -1
	last_map_opts = {}
	_hide_dev_and_tutorial_chrome()
	var rules: Dictionary = _rules()
	var state: Dictionary = _state()
	var faces: Array = MODEL.faces(rules, _items())
	if face_index < 0 or face_index >= faces.size():
		_finish_portal(face_index, false)
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
	var is_endless: bool = bool(nxt.get("endless", false)) or next_id == "endless"
	if is_endless:
		next_id = "endless"
	var next_name := str(nxt.get("name", SHELL.biome_name(rules, next_id)))
	var prev_name := str(face.get("name", ""))
	var vars := _token_vars(face, next_name, prev_name)
	var slug := _portal_slug(next_id)
	var art := "res://assets/ui/trophy_board/splash/portal_%s.png" % slug
	_start_splash_music(next_id)
	await _play_splash(
		next_id,
		art,
		_portal_keys(slug, ["1", "2"], ["nib.portal.1", "nib.portal.2"]),
		vars,
		&"sting.portal_open"
	)
	## Nathan lock: splash gone → trophy hall (not dungeon / not title).
	await _land_hall_after_splash(face_index, next_id)
	## Writer condition (1): endless rumble_wake only if a new pool activates — it does not.
	var wake_keys: Array = _portal_keys(slug, ["rumble_wake"], ["nib.portal.rumble_wake"])
	if is_endless:
		wake_keys = ["nib.portal.rumble_wake"]
	await _nib(wake_keys, vars)
	await _fade(0.3, true)
	## Map beat: fog clears / endless stamp unlocks (Known, not startable until shortcut).
	await _present_map(
		{"reveal": next_id, "read_only": true},
		_portal_keys(slug, ["map"], ["nib.portal.map"]),
		vars
	)
	## Writer condition (2): endless has no item-pool reveal beat.
	if not is_endless:
		await _fade(0.3, true)
		var bucket_n: int = _bucket_for_next_biome(next_id, face_index)
		await _play_bucket_reveal(
			bucket_n,
			_portal_keys(slug, ["reveal.1", "reveal.2"], ["nib.portal.reveal.1", "nib.portal.reveal.2"]),
			vars
		)
	await _fade(0.3, false)
	_restore_hall_control(face_index)
	## If this face is also complete, hand off to shortcut.
	if not is_endless and MODEL.is_complete(state, face) and not _board_complete_seen(pool_id):
		_finish_portal(face_index, false)
		await shortcut(face_index)
		return
	_finish_portal(face_index, true)


## Face first reaches 100% (b1–b4 → shortcut; b5 → ending drawer).
func shortcut(face_index: int) -> void:
	if _busy:
		return
	_busy = true
	_hide_dev_and_tutorial_chrome()
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
	if cabin != null and cabin.has_method("nib_react"):
		cabin.nib_react()
	await _wait(0.8 if not reduce_motion else 0.3)
	var vars := _token_vars(face, "", str(face.get("name", "")))
	var face_slug := str(face.get("slug", MODEL.SLUGS.get(pool_id, pool_id)))
	await _nib(
		_shortcut_keys(face_slug, ["1"], ["nib.shortcut.1"]) if face_index < 4 else ["nib.board.complete_final"],
		vars
	)
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
		_restore_hall_control(face_index)
		_busy = false
		shortcut_finished.emit(face_index)
		return
	var next_id := MODEL.next_biome_id(rules, face)
	var next_name := SHELL.biome_name(rules, next_id)
	vars = _token_vars(face, next_name, str(face.get("name", "")))
	var slug := _portal_slug(next_id)
	var art := "res://assets/ui/trophy_board/splash/shortcut_%s.png" % slug
	await _fade(0.3, true)
	await _play_splash(
		next_id,
		art,
		_shortcut_keys(slug, ["2"], ["nib.shortcut.2"]),
		vars,
		&"sting.shortcut"
	)
	## Commit shortcut + fresh badge.
	SHELL.grant_shortcut(rules, state, next_id)
	SHELL.mark_board_complete_seen(state, pool_id)
	_write()
	await _present_map(
		{"shortcut_reveal": next_id, "read_only": true},
		_shortcut_keys(slug, ["3"], ["nib.shortcut.3"]),
		vars
	)
	await _fade(0.3, false)
	_restore_hall_control(face_index)
	_busy = false
	shortcut_finished.emit(face_index)


# --- beats ------------------------------------------------------------------


func _play_rumble() -> void:
	## Duck comes from sfx-map board.rumble.duck_music (−12) via play_event — do not duck again here.
	KIT.cue(sfx, &"board.rumble")
	## Package E: Nib gasps during the rumble. Music duck is on board.rumble in sfx-map (#503).
	if cabin != null and cabin.has_method("nib_gasp"):
		cabin.nib_gasp()
	var root: Node = cabin if cabin != null else self
	var shake_target: Node2D = null
	## Selftests spy this: when reduce_motion, never create a shake tween.
	last_shake_created = false
	if cabin != null and cabin.get("_int_root") is Node2D:
		shake_target = cabin.get("_int_root")
	elif cabin != null and cabin is Node2D:
		shake_target = cabin
	if reduce_motion:
		## Dim pulse instead of shake / dust.
		var tween_host: Node = self
		if cabin is Node and (cabin as Node).is_inside_tree():
			tween_host = cabin
		if root is CanvasItem and tween_host.is_inside_tree():
			var ci := root as CanvasItem
			var base := ci.modulate
			var tw := tween_host.create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_property(ci, "modulate", base.darkened(0.25), 0.2 / maxf(0.001, Engine.time_scale))
			tw.tween_property(ci, "modulate", base, 0.2 / maxf(0.001, Engine.time_scale))
			await tw.finished
		else:
			await _wait(0.4)
	else:
		last_shake_created = true
		await _shake_and_dust(shake_target, RUMBLE_S)


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
	last_splash_art = art_path
	last_nib_keys = nib_keys.duplicate()
	last_splash_nib_keys = nib_keys.duplicate()
	_hide_dev_and_tutorial_chrome()
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
	_hide_biome_splash()


## After splash dismiss: fade wipe out, hide BiomeSplash, restore trophy hall + cabin music.
func _land_hall_after_splash(face_index: int, _biome_id: String) -> void:
	_hide_biome_splash()
	_restore_cabin_music()
	_hide_dev_and_tutorial_chrome()
	## Ensure hall / board are the live surface before the wipe clears.
	if cabin != null:
		## Cabin must stay up — never flash Main title / Developer Test under a wipe.
		if cabin is CanvasItem:
			(cabin as CanvasItem).visible = true
		var int_root = cabin.get("_int_root") if cabin != null else null
		var cur_room := ""
		if cabin.get("_current_room") != null:
			cur_room = str(cabin.get("_current_room"))
		if int_root != null and int_root is CanvasItem and (int_root as CanvasItem).visible:
			if cur_room != "hall" and cabin.has_method("pan_to"):
				cabin.pan_to("hall")
		elif cabin.has_method("show_menu"):
			cabin.show_menu("hall")
		if cabin.has_method("_release_cabin_tree_pause"):
			cabin._release_cabin_tree_pause()
	if board != null and board.has_method("slide_to"):
		board.slide_to(face_index, true)
	if board != null and board.has_method("refresh"):
		board.refresh()
	await _fade(0.3, false)
	_hide_biome_splash()
	## Belt-and-suspenders: never leave an opaque full-screen wipe on the cabin.
	_clear_opaque_wipes()
	last_landed_hall = true


func _clear_opaque_wipes() -> void:
	var wipe := _ensure_board_fade()
	wipe.modulate.a = 0.0
	wipe.visible = false
	wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var roots: Array = []
	if cabin != null:
		roots.append(cabin)
	roots.append(self)
	if main_ref != null:
		roots.append(main_ref)
	for parent in roots:
		if parent == null or not (parent is Node):
			continue
		_clear_opaque_under(parent as Node, wipe)


func _clear_opaque_under(parent: Node, wipe: ColorRect) -> void:
	for child in parent.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if child is ColorRect and child != wipe:
			var cr := child as ColorRect
			## Full-screen leftovers (named BoardFadeWipe or anonymous high-z).
			var full: bool = cr.anchor_right >= 0.99 and cr.anchor_bottom >= 0.99
			if (str(cr.name) == "BoardFadeWipe" or cr.z_index >= 100 or full) and cr.modulate.a > 0.05:
				cr.modulate.a = 0.0
				cr.visible = false
				cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				if str(cr.name) != "BoardFadeWipe" and str(cr.name) != "CabinRoomFade":
					cr.queue_free()
		elif child is CanvasLayer:
			var layer := child as CanvasLayer
			## Orphan BiomeSplash / fade layers left at full opacity.
			if str(layer.name) == "BiomeSplash" or (layer.get_script() == SPLASH):
				layer.visible = false
				if layer.has_method("queue_free"):
					layer.queue_free()


func _hide_biome_splash() -> void:
	var roots: Array = []
	if cabin != null:
		roots.append(cabin)
	roots.append(self)
	if main_ref != null:
		roots.append(main_ref)
	for root in roots:
		if root == null or not (root is Node):
			continue
		_hide_splash_under(root as Node)


func _hide_splash_under(root: Node) -> void:
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if str(child.name) == "BiomeSplash" or child.get_script() == SPLASH:
			child.visible = false
			if child is CanvasLayer:
				(child as CanvasLayer).visible = false
			if child.has_method("queue_free"):
				child.queue_free()


func _start_splash_music(biome_id: String) -> void:
	last_splash_music = str(biome_id)
	if sfx == null:
		return
	## Fade the newly opened biome bed in over ~1.5s while the splash holds.
	if sfx.has_method("music_biome_dungeon"):
		sfx.music_biome_dungeon(biome_id, 1.5)
	elif sfx.has_method("dungeon_bed_for_biome") and sfx.has_method("music_to"):
		var bed: StringName = sfx.dungeon_bed_for_biome(biome_id)
		if bed != &"":
			sfx.music_to(bed, 1.5)


func _restore_cabin_music() -> void:
	if sfx == null:
		return
	## Back in the hall: intentional cabin bed (clears biome delve lock).
	## Do not music_to(cabin) while locked — that path is refused after map/portal splash.
	if sfx.has_method("music_cabin"):
		sfx.music_cabin()
	elif sfx.has_method("music_to"):
		sfx.music_to(&"cabin", 1.0)


func _present_map(opts: Dictionary, nib_keys: Array, vars: Dictionary) -> void:
	var merged: Dictionary = opts.duplicate(true)
	merged["reduce_motion"] = reduce_motion
	last_map_opts = merged.duplicate(true)
	last_nib_keys = nib_keys.duplicate()
	_hide_dev_and_tutorial_chrome()
	## Clear the black wipe so the map is visible under the ceremony.
	_clear_opaque_wipes()
	var map = held_map
	if map == null and cabin != null and cabin.get("held_map") != null:
		map = cabin.held_map
	if map == null and campaign_map != null:
		if campaign_map.has_method("show_map"):
			campaign_map.show_map(_rules(), _state(), {}, merged)
		if campaign_map.has_method("held_map"):
			map = campaign_map.held_map()
		elif campaign_map.get("held") != null:
			map = campaign_map.get("held")
		else:
			map = campaign_map
	elif map != null and map.has_method("present"):
		map.present(_rules(), _state(), {}, merged)
	await _nib(nib_keys, vars)
	## Soft-lock fix: read_only Space emits peek_closed on campaign_map (not closed).
	## Prefer campaign_map for dismiss signals; held_map only has closed (X button).
	var dismiss_target = campaign_map if campaign_map != null else map
	await _await_map_dismiss(dismiss_target)
	if campaign_map != null and campaign_map.has_method("hide_map"):
		campaign_map.hide_map()
	elif map != null:
		map.visible = false
	_hide_dev_and_tutorial_chrome()
	_clear_opaque_wipes()


func _await_map_dismiss(map) -> void:
	if map == null:
		await _wait(0.2)
		return
	## Auto-continue after a short beat in headless / reduce path.
	if Engine.is_editor_hint() or reduce_motion or Engine.time_scale >= 4.0:
		await _wait(0.2)
		if map.has_method("hide_map"):
			map.hide_map()
		else:
			map.visible = false
		if map.has_signal("closed"):
			map.closed.emit()
		return
	var done := {"v": false}
	var finish := func(_a = null) -> void:
		done["v"] = true
	if map.has_signal("closed"):
		map.closed.connect(finish, CONNECT_ONE_SHOT)
	if map.has_signal("peek_closed"):
		## Soft-lock root cause: read_only Space → peek_closed, never closed.
		map.peek_closed.connect(finish, CONNECT_ONE_SHOT)
	var held = null
	if map.has_method("held_map"):
		held = map.held_map()
	elif map.get("held") != null:
		held = map.get("held")
	if held != null and held.has_signal("closed") and held != map:
		held.closed.connect(finish, CONNECT_ONE_SHOT)
	while not done["v"]:
		if map.get("visible") == false:
			break
		await _wait(0.05)


func _play_bucket_reveal(bucket_n: int, nib_keys: Array, vars: Dictionary) -> void:
	last_reveal_bucket = bucket_n
	last_nib_keys = nib_keys.duplicate()
	_hide_dev_and_tutorial_chrome()
	## Reveal paints its own dark plate — wipe must be clear or player sees black forever.
	_clear_opaque_wipes()
	var entries: Array = []
	if main_ref != null and main_ref.has_method("bucket_reveal_for"):
		entries = main_ref.bucket_reveal_for(bucket_n)
	elif main_ref != null and main_ref.has_method("_bucket_entries"):
		entries = main_ref._bucket_entries(bucket_n)
	last_reveal_entries = entries.duplicate()
	if main_ref != null and main_ref.get("_bucket_reveal") != null:
		var br = main_ref.get("_bucket_reveal")
		if br.has_method("play"):
			if main_ref.get("_unlock_screen") != null:
				main_ref.set("_unlock_screen", true)
			if main_ref.has_method("_hide_board_for_unlock"):
				main_ref._hide_board_for_unlock()
			## Fire Nib lines after cards pop — best-effort overlay.
			call_deferred("_nib_after_reveal_start", br, nib_keys, vars)
			if reduce_motion or Engine.time_scale >= 4.0:
				call_deferred("_auto_finish_bucket_reveal", br)
			await br.play(bucket_n, entries)
			if main_ref.get("_unlock_screen") != null:
				main_ref.set("_unlock_screen", false)
			_hide_dev_and_tutorial_chrome()
			_clear_opaque_wipes()
			return
	## Headless / missing reveal: still record the call.
	await _nib(nib_keys, vars)


func _auto_finish_bucket_reveal(br) -> void:
	await _wait(0.15)
	if br != null and is_instance_valid(br) and br.has_method("force_continue"):
		br.force_continue()
	elif br != null and is_instance_valid(br):
		br.set("_go", true)


func _nib_after_reveal_start(br, nib_keys: Array, vars: Dictionary) -> void:
	await _wait(0.6)
	await _nib(nib_keys, vars)


func _nib(keys: Array, vars: Dictionary) -> void:
	if keys.is_empty():
		return
	last_nib_keys = keys.duplicate()
	## Resolve per-biome → generic so dialog always has text.
	var resolved: Array = []
	for raw in keys:
		resolved.append(_resolve_copy_key(str(raw)))
	if cabin != null and cabin.has_method("nib_talk"):
		## Prefer cabin dialog if present.
		var dialog = cabin.get("_dialog")
		if dialog != null and dialog.has_method("say"):
			dialog.say(resolved, [], vars)
			if dialog.has_signal("finished"):
				## Headless / fast: auto-advance Nib lines.
				if reduce_motion or Engine.time_scale >= 4.0:
					await _wait(0.05)
					if dialog.has_method("_close"):
						dialog._close(-1)
					elif dialog.has_signal("finished"):
						dialog.finished.emit(-1)
					return
				await dialog.finished
				return
	## Fallback: no-op wait so sequences stay timed in tests.
	await _wait(0.05)


func _portal_slug(biome_id: String) -> String:
	if biome_id == "endless":
		return "endless"
	return str(MODEL.SLUGS.get(biome_id, biome_id))


## Prefer per-biome keys; fall back to generic keys when a row is missing.
func _portal_keys(slug: String, parts: Array, generics: Array) -> Array:
	var out: Array = []
	for i in parts.size():
		var part := str(parts[i])
		var specific := "nib.portal.%s.%s" % [slug, part]
		var generic := str(generics[i]) if i < generics.size() else specific
		out.append(specific if COPY.has_key(specific) else generic)
	return out


func _shortcut_keys(slug: String, parts: Array, generics: Array) -> Array:
	var out: Array = []
	for i in parts.size():
		var part := str(parts[i])
		var specific := "nib.shortcut.%s.%s" % [slug, part]
		var generic := str(generics[i]) if i < generics.size() else specific
		out.append(specific if COPY.has_key(specific) else generic)
	return out


func _resolve_copy_key(key: String) -> String:
	if COPY.has_key(key) and COPY.text(key, "").strip_edges() != "":
		return key
	## nib.portal.ashen.1 → nib.portal.1 ; nib.portal.endless.rumble_wake → nib.portal.rumble_wake
	if key.begins_with("nib.portal."):
		var rest := key.substr("nib.portal.".length())
		var dot := rest.find(".")
		if dot >= 0:
			var generic := "nib.portal.%s" % rest.substr(dot + 1)
			if COPY.has_key(generic):
				return generic
	if key.begins_with("nib.shortcut."):
		var rest2 := key.substr("nib.shortcut.".length())
		var dot2 := rest2.find(".")
		if dot2 >= 0:
			var generic2 := "nib.shortcut.%s" % rest2.substr(dot2 + 1)
			if COPY.has_key(generic2):
				return generic2
	return key


## face 0 (b1) opens b2 → bucket 2; face 1 opens b3 → bucket 3; …
func _bucket_for_next_biome(next_id: String, face_index: int) -> int:
	match next_id:
		"b2":
			return 2
		"b3":
			return 3
		"b4":
			return 4
		"b5":
			return 5
		_:
			return face_index + 2


func _hide_dev_and_tutorial_chrome() -> void:
	if cabin != null and cabin.has_method("hide_cabin_dev_strip"):
		cabin.hide_cabin_dev_strip()
	if main_ref == null:
		return
	## Title / Developer Test strip must never appear mid-portal.
	if main_ref.get("overlay") != null:
		main_ref.overlay.visible = false
	if main_ref.get("overlay_tools_row") != null:
		main_ref.overlay_tools_row.visible = false
	if main_ref.get("overlay_dev") != null:
		main_ref.overlay_dev.visible = false
	if main_ref.get("tut") != null:
		var tut = main_ref.tut
		if tut is CanvasItem:
			(tut as CanvasItem).visible = false
	## Tutorial guide / unlock screen leftovers.
	if main_ref.get("_unlock_screen") == true and main_ref.get("_bucket_reveal") != null:
		var br = main_ref.get("_bucket_reveal")
		if br != null and br.get("visible") == true and not br.get("_playing"):
			br.visible = false


func _restore_hall_control(face_index: int) -> void:
	_hide_dev_and_tutorial_chrome()
	_clear_opaque_wipes()
	_hide_biome_splash()
	if cabin != null:
		if cabin is CanvasItem:
			(cabin as CanvasItem).visible = true
		if cabin.has_method("_release_cabin_tree_pause"):
			cabin._release_cabin_tree_pause()
		var cur_room := str(cabin.get("_current_room")) if cabin.get("_current_room") != null else ""
		if cur_room != "hall" and cabin.has_method("pan_to"):
			cabin.pan_to("hall")
	if board != null and board.has_method("slide_to"):
		board.slide_to(face_index, true)
	if board != null and board.has_method("refresh"):
		board.refresh()
	last_landed_hall = true


func _finish_portal(face_index: int, emit_finished: bool) -> void:
	_restore_hall_control(face_index)
	_busy = false
	if emit_finished:
		portal_finished.emit(face_index)


func is_busy() -> bool:
	return _busy


func _fade(seconds: float, to_black: bool) -> void:
	var wipe: ColorRect = _ensure_board_fade()
	## Camera wipe / fade: drop any line-bound Nib pointer so it cannot linger.
	if cabin != null and cabin.has_method("clear_nib_pointer"):
		cabin.clear_nib_pointer()
	## Instant final state for reduce-motion / fast selftests — never leave alpha stuck at 1.
	if reduce_motion or Engine.time_scale >= 4.0:
		wipe.visible = to_black
		wipe.modulate.a = 1.0 if to_black else 0.0
		if not to_black:
			wipe.visible = false
			wipe.modulate.a = 0.0
		await _wait(seconds)
		if not to_black:
			_clear_opaque_wipes()
		return
	wipe.visible = true
	wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wipe.modulate.a = 0.0 if to_black else 1.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(wipe, "modulate:a", 1.0 if to_black else 0.0, seconds / maxf(0.001, Engine.time_scale))
	## Guaranteed cleanup if the tween is killed mid-crossfade (music interrupt / skip).
	var finished_ok := false
	tw.finished.connect(func() -> void: finished_ok = true, CONNECT_ONE_SHOT)
	await tw.finished
	if not to_black or not finished_ok:
		wipe.modulate.a = 0.0 if not to_black else wipe.modulate.a
		if not to_black:
			wipe.visible = false
			wipe.modulate.a = 0.0
			_clear_opaque_wipes()


## One named, reused full-screen wipe. Never spawn anonymous ColorRects.
func _ensure_board_fade() -> ColorRect:
	if cabin != null and cabin.has_method("_ensure_fade"):
		var from_cabin = cabin._ensure_fade()
		if from_cabin is ColorRect:
			return from_cabin as ColorRect
	var parent: Node = cabin if cabin != null else self
	var existing = parent.get_node_or_null("BoardFadeWipe")
	if existing is ColorRect:
		return existing as ColorRect
	var wipe := ColorRect.new()
	wipe.name = "BoardFadeWipe"
	wipe.color = Color("0B0706")
	wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wipe.z_index = 200
	wipe.visible = false
	wipe.modulate.a = 0.0
	parent.add_child(wipe)
	return wipe


func _wait(seconds: float) -> void:
	var t: float = seconds / maxf(0.001, Engine.time_scale)
	var tree: SceneTree = get_tree()
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	## Cabin leaves SceneTree.paused while open — ignore_pause so portal/splash never sticks black.
	await tree.create_timer(t, true, false, true).timeout


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
