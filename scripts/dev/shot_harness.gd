extends Node
## Editor-only audit captures. Main loads this only when `_authoring()`.

const OUT_DIR := "res://design/audit-shots/cursor"
const TEXT_RESERVE := preload("res://scripts/ui/text_reserve.gd")
const SHOT_CLI := preload("res://scripts/shot_cli.gd")
const LAYOUT_CHECK := preload("res://scripts/dev/layout_check.gd")
const TEXT_OUT_DIR := "res://design/cli-runs/05-playtest-pass"
const SAVE_PATH := "user://home_cabin.json"
const SACK_OWNED := ["throwing_knife", "shield"]
const SACK_NEW := ["net", "lantern", "caltrops", "dagger", "longbow"]
const W := 1680
const H := 1040

var main
var finished: bool = false
var running: bool = false
var status: String = ""
var notes: Array = []
var audit_fails: Array = []

var _save_text: String = ""
var _stamp_was: bool = false
var out_dir: String = OUT_DIR
var _quit_when_done: bool = false
var _harness_error: String = ""
var _wanted: Dictionary = {}
var _shot_fns: Dictionary = {}
var _ping_ok: bool = false


func setup(p_main) -> void:
	main = p_main
	name = "ShotHarness"
	process_mode = Node.PROCESS_MODE_ALWAYS


func begin() -> String:
	return begin_shots("all", OUT_DIR, false)


func begin_shots(list_raw: String, dest: String, quit_when_done: bool) -> String:
	_quit_when_done = quit_when_done
	_harness_error = ""
	if main == null or not main._authoring():
		return _finish_early("blocked: not authoring", 2)
	if running:
		return _finish_early("already running", 2)
	var dest_err := _apply_out_dir(dest)
	if dest_err != "":
		return _finish_early(dest_err, 2)
	_ensure_registry()
	var list_err := _fill_wanted(list_raw)
	if list_err != "":
		return _finish_early(list_err, 2)
	running = true
	finished = false
	notes.clear()
	audit_fails.clear()
	status = "starting"
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(_run, CONNECT_ONE_SHOT)
	return "started"


func _finish_early(why: String, code: int) -> String:
	print("SHOT_HARNESS: ", why)
	if _quit_when_done and is_inside_tree():
		get_tree().quit(code)
	return why


func _run() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(out_dir)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	_log_progress("run start")
	get_tree().paused = false
	var guarded := false
	if not SHOT_CLI.begin_guard():
		_harness_error = "save backup failed"
	else:
		guarded = true
		_snapshot_save()
		if main.home_cabin:
			main.home_cabin._load_save()
		if main._copy_stamp:
			_stamp_was = main._copy_stamp.visible
			main._copy_stamp.visible = false
		if main.text_audit == null:
			_harness_error = "text audit missing"
		else:
			main.text_audit.copy_dir = out_dir
			await _run_table()
			_note_missing()
		_restore_all()
		if main._copy_stamp:
			main._copy_stamp.visible = _stamp_was
		if main.text_audit:
			main.text_audit.set_on(false)
	if not guarded and _harness_error == "":
		_harness_error = "save backup failed"
	_write_audit_summary()
	running = false
	finished = true
	status = "done" if _harness_error == "" else _harness_error
	var code := _exit_code()
	_log_progress("exit %s" % code)
	if _quit_when_done:
		get_tree().quit(code)


func _shot_run_hero() -> void:
	status = "run-hero"
	if not _prep_hub():
		_skip("30_hub_idle.png", "wheel_view missing")
		return
	var w = main.wheel_view
	w.debug_hero("idle", 0)
	_pose_vitals(6, 6, -1, 3, -1)
	w.set_hub_pierce(false)
	w.set_hub_gear({"head": "", "eyes": "", "belt": ""})
	await _wait(0.12)
	await _capture("30_hub_idle.png", "SCREEN 8.1 idle goblin 96x96 at c+(-48,-50), no bob")
	await _capture("31_hub_badges.png", "SCREEN 8.2 heart c+(-64,24) shield c+(38,21) numbers y=c.y+41, no captions")
	_pose_vitals(6, 6, -1, 0, -1)
	await _wait(0.05)
	await _capture("32a_blk_empty.png", "SCREEN 8.3 BLK 0 = badge_blk_empty")
	_pose_vitals(6, 6, -1, 4, -1)
	await _wait(0.05)
	await _capture("32b_blk_full.png", "SCREEN 8.3 BLK > 0 = badge_blk")
	_pose_vitals(6, 6, -1, 3, 5)
	await _wait(0.05)
	await _capture("32c_blk_up.png", "SCREEN 8.3 BLK gained = badge_blk_up")
	_pose_vitals(6, 6, 2, 3, -1)
	await _wait(0.05)
	await _capture("32d_hp_flash.png", "SCREEN 8.3 HP flash (ghost < hp)")
	_pose_vitals(2, 6, -1, 3, -1)
	w.debug_hero("lowhp", 0)
	await _wait(0.05)
	await _capture("32e_hp_low.png", "SCREEN 8.3 HP low = badge_hp_low + lowhp f0")
	_pose_vitals(0, 6, -1, 0, -1)
	w.debug_hero("death", 4)
	await _wait(0.05)
	await _capture("32f_hp_empty.png", "SCREEN 8.3 HP 0 = badge_hp_empty")
	_pose_vitals(6, 6, -1, 3, -1)
	w.reset_hero()
	w.debug_hero("idle", 0)
	w.set_hub_pierce(true)
	await _wait(0.18)
	await _capture("33_pierce_float.png", "SCREEN 8.4 pierced badge + IGNORED float, no slash, no static caption")
	w.set_hub_pierce(false)
	w.reset_hero()
	_pose_vitals(6, 6, -1, 3, -1)
	w.debug_hero("swipe", 2)
	await _wait(0.05)
	await _capture("34a_swipe_f2.png", "SCREEN 8.5 swipe hit frame f2")
	w.debug_hero("hit", 0)
	await _wait(0.05)
	await _capture("34b_hit.png", "SCREEN 8.5 hit")
	w.debug_hero("block", 1)
	await _wait(0.05)
	await _capture("34c_block_f1.png", "SCREEN 8.5 block impact f1")
	w.debug_hero("heal", 2)
	await _wait(0.05)
	await _capture("34d_heal_f2.png", "SCREEN 8.5 heal gulp f2")
	w.debug_hero("grab", 1)
	await _wait(0.05)
	await _capture("34e_grab_f1.png", "SCREEN 8.5 grab f1")
	w.debug_hero("victory", 2)
	await _wait(0.05)
	await _capture("34f_victory.png", "SCREEN 8.5 victory")
	w.debug_hero("death", 3)
	await _wait(0.05)
	await _capture("34g_death_f3.png", "SCREEN 8.5 death floor f3")
	w.debug_hero("death", 2)
	await _wait(0.05)
	await _capture("35_death_dim.png", "SCREEN 8.6 badges at 35% from death f2")
	w.reset_hero()
	w.set_vitals(6, 6, -1, 3, -1)
	w.set_hub_gear({"head": "helm", "eyes": "goggles", "belt": "rope"})
	w.debug_hero("idle", 0)
	await _wait(0.05)
	await _capture("36a_gear_helm.png", "SCREEN 8.7 helm+goggles+rope on idle")
	w.debug_hero("swipe", 2)
	await _wait(0.05)
	await _capture("36b_gear_helm_swipe.png", "SCREEN 8.7 helm loadout on swipe f2")
	w.set_hub_gear({"head": "cap", "eyes": "goggles", "belt": "rope"})
	w.debug_hero("idle", 0)
	await _wait(0.05)
	await _capture("36c_gear_cap.png", "SCREEN 8.7 cap+goggles+rope, never cap+helm")
	w.set_hub_gear({"head": "", "eyes": "", "belt": ""})
	w.debug_hero("idle", 0)
	await _wait(0.05)
	await _capture("36d_gear_none.png", "SCREEN 8.7 no gear")
	w.debug_hero("idle", 0)
	await _capture("37a_clear_idle.png", "SCREEN 8.8 clearance idle")
	w.debug_hero("swipe", 2)
	await _capture("37b_clear_swipe_f2.png", "SCREEN 8.8 clearance swipe f2")
	w.debug_hero("block", 1)
	await _capture("37c_clear_block_f1.png", "SCREEN 8.8 clearance block f1")
	w.debug_hero("heal", 2)
	await _capture("37d_clear_heal_f2.png", "SCREEN 8.8 clearance heal f2")
	w.debug_hero("lowhp", 0)
	await _capture("37e_clear_lowhp_f0.png", "SCREEN 8.8 clearance lowhp f0")
	w.reset_hero()
	w.visible = false
	w.set_hub_gear({"head": "helm", "eyes": "goggles", "belt": "rope"})
	if main.home_cabin:
		main.home_cabin.gear_worn = {"head": "helm", "eyes": "goggles", "belt": "rope"}
	if main.has_method("debug_pose_courier"):
		main.debug_pose_courier()
		await _wait(0.12)
		await _capture("38_courier_walkoff.png", "SCREEN 8.9 courier run_walkoff scale 1.0 with gear")
		if main._courier:
			main._courier.visible = false
			if main.has_method("_clear_courier_gear"):
				main._clear_courier_gear()
	else:
		_skip("38_courier_walkoff.png", "debug_pose_courier missing")
	w.visible = true
	await _capture("39_untouched.png", "SCREEN 8.10 hub still using knight_m fallbacks elsewhere; copy files not edited")


func _shot_cabin_hero() -> void:
	status = "cabin-hero"
	var cabin = main.home_cabin
	if cabin == null:
		_skip("40a_cabin_gear_helm_sit.png", "home_cabin missing")
		return
	_reset_between()
	_hide_chrome(false)
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	cabin.gear_worn = {"head": "helm", "eyes": "goggles", "belt": "rope"}
	cabin.visible = true
	cabin.show_menu("main")
	await _wait(0.2)
	if not cabin.has_method("debug_hero_family"):
		_skip("40a_cabin_gear_helm_sit.png", "debug_hero_family missing")
		return
	var families := [
		["hero_sit", 4, "40a_cabin_gear_helm_sit.png", "SPEC 4 sit with helm+goggles+rope"],
		["hero_rock", 1, "40b_cabin_gear_helm_rock.png", "SPEC 4 rock with helm loadout"],
		["hero_walk", 1, "40c_cabin_gear_helm_walk.png", "SPEC 4 walk with helm loadout"],
		["hero_walk_sad", 1, "40d_cabin_gear_helm_walk_sad.png", "SPEC 4 walk_sad with helm loadout"],
		["hero_sack_dump", 2, "40e_cabin_gear_helm_dump.png", "SPEC 4 sack_dump with helm loadout"],
		["hero_sack_shake", 2, "40f_cabin_gear_helm_shake.png", "SPEC 4 sack_shake with helm loadout"],
	]
	for row in families:
		cabin.debug_hero_family(str(row[0]), int(row[1]), false)
		await _wait(0.08)
		await _capture(str(row[2]), str(row[3]))
	cabin.gear_worn = {"head": "cap", "eyes": "goggles", "belt": "rope"}
	if cabin.has_method("_start_rock"):
		cabin._start_rock()
		await _wait(0.3)
		await _capture("41a_cabin_rock_cap.png", "SPEC 4 cap on rock, no helm")
		cabin.gear_worn = {"head": "helm", "eyes": "goggles", "belt": "rope"}
		cabin._set_hero_frame("hero_rock", cabin._rock_i)
		await _wait(0.08)
		await _capture("41b_cabin_rock_helm.png", "SPEC 4 swap cap to helm while rocking")
	cabin.gear_worn = {"head": "", "eyes": "", "belt": ""}
	cabin.debug_hero_family("hero_sit", 4, false)
	await _wait(0.08)
	await _capture("42_cabin_gear_none.png", "SPEC 4 nothing worn, layers null")
	cabin.gear_worn = {"head": "helm", "eyes": "goggles", "belt": "rope"}
	cabin.debug_hero_family("hero_walk_loot", 1, true)
	await _wait(0.08)
	await _capture("43a_cabin_flip_walk_loot.png", "SPEC 4 walk_loot flip_h mirrors layers")
	cabin.debug_hero_family("hero_sack_dump", 2, true)
	await _wait(0.08)
	await _capture("43b_cabin_flip_dump.png", "SPEC 4 sack_dump flip_h mirrors layers")
	cabin.visible = false
	cabin.stop_story()


func _pose_vitals(hp_n: int, hp_max: int, hp_ghost: int, blk_n: int, blk_ghost: int) -> void:
	main.hp = hp_n
	main.blk = blk_n
	main._ghost_hp = hp_ghost
	main._ghost_blk = blk_ghost
	if main.wheel_view:
		main.wheel_view.set_vitals(hp_n, hp_max, hp_ghost, blk_n, blk_ghost)


func _prep_hub() -> bool:
	_reset_between()
	_stow_cabin()
	_hide_chrome(false)
	if main.overlay:
		main.overlay.visible = false
	if main.play_field:
		main.play_field.visible = true
	main.adventure = true
	main.in_tutorial = false
	main.phase = "fighting"
	main.hp = 6
	main.blk = 3
	if main.wheel_view == null:
		return false
	var w = main.wheel_view
	w.visible = true
	w.hub_on = true
	if w.has_method("setup_run_hero") and main.art:
		w.setup_run_hero(main.art)
	var dummy: Array = []
	for i in 6:
		dummy.append({"kind": "empty", "slot": str(i), "atk": 0, "hp": 0})
	w.set_slices(dummy, -1, "none")
	w.set_vitals(6, 6, -1, 3, -1)
	if w.has_method("set_hub_pierce"):
		w.set_hub_pierce(false)
	if w.has_method("reset_hero"):
		w.reset_hero()
	if main.has_method("_sync_run_hero_gear"):
		main._sync_run_hero_gear()
	return true


func _shot_map_routes() -> void:
	status = "map-routes"
	_reset_between()
	_hide_chrome(false)
	var cabin = main.home_cabin
	if cabin == null or cabin._map == null:
		_skip("15a_map_classic_selected.png", "map overlay missing")
		return
	if main.play_field:
		main.play_field.visible = false
	if main.overlay:
		main.overlay.visible = false
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.deepest_belly = 3
	cabin.last_route = "gatehouse"
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._open_map()
	await _wait(0.28)
	if cabin._map._sheet:
		cabin._map._sheet.scale = Vector2.ONE
		cabin._map._sheet.modulate.a = 1.0
	if cabin._map.has_method("debug_select"):
		cabin._map.debug_select("gatehouse")
	await _wait(0.45)
	if not cabin._map.visible:
		_skip("15a_map_classic_selected.png", "map overlay did not stay visible")
		return
	await _capture("15a_map_classic_selected.png", "cabin._open_map(), gatehouse selected, confirm uses map.go.named")
	if cabin._map.has_method("debug_hover"):
		cabin._map.debug_hover("long_drop")
	await _wait(0.12)
	await _capture("15b_map_challenge_hover.png", "gatehouse selected, long_drop hover previews the panel")
	if cabin._map.has_method("debug_select"):
		cabin._map.debug_select("long_drop")
	await _wait(0.45)
	await _capture("15c_map_challenge_selected.png", "long_drop selected, deepest footer on, confirm names Challenge Mode")
	cabin._map.close()
	cabin.visible = false
	cabin.stop_story()
	if main.play_field:
		main.play_field.visible = true


func _shot_rope_belly1() -> void:
	await _shot_rope("18_rope_exit_belly1.png", 1, "sign visible, nothing else open")


func _shot_rope_belly3() -> void:
	await _shot_rope("24_rope_exit_belly3.png", 3, "later belly headline")


func _shot_21a() -> void:
	status = "21a_win_homecoming_dump.png"
	_reset_between()
	_hide_chrome(false)
	var cabin = main.home_cabin
	if cabin == null or not cabin.has_method("debug_hero_family"):
		_skip("21a_win_homecoming_dump.png", "home_cabin missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._new_ids = SACK_NEW.duplicate()
	cabin._held_ids = SACK_OWNED.duplicate()
	cabin._held_ids.append_array(SACK_NEW)
	if cabin.has_method("debug_win_dump"):
		cabin.debug_win_dump()
	else:
		cabin.debug_hero_family("hero_sack_dump", 2, false)
	await _wait(0.2)
	await _capture("21a_win_homecoming_dump.png", "win dump pose at the sack, items grown at the dump")
	cabin.visible = false
	cabin.stop_story()


func _shot_21b() -> void:
	status = "21b_win_homecoming_fly.png"
	_reset_between()
	_hide_chrome(false)
	var cabin = main.home_cabin
	if cabin == null or not cabin.has_method("debug_win_fly"):
		_skip("21b_win_homecoming_fly.png", "debug_win_fly missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	cabin.debug_win_fly()
	await _wait(0.25)
	await _capture("21b_win_homecoming_fly.png", "new items in the air flying toward the hall glow")
	if cabin.has_method("clear_debug_fx"):
		cabin.clear_debug_fx()
	cabin.visible = false
	cabin.stop_story()


func _shot_rope(filename: String, cleared: int, extra: String) -> void:
	status = filename
	_reset_between()
	_plant_sack()
	main.adventure = true
	main.phase = "rest"
	main.dungeons_cleared = cleared
	main.in_tutorial = false
	_stow_cabin()
	_hide_chrome(false)
	if main.play_field:
		main.play_field.visible = false
	get_tree().paused = false
	if main.rope_exit == null:
		_skip(filename, "rope_exit node missing")
		return
	main.rope_exit.z_index = 200
	if main.has_method("_rope_loot_rows"):
		main.rope_exit.open_exit(cleared, main._rope_loot_rows())
	else:
		main.rope_exit.open_exit(cleared)
	await _wait(0.45)
	main.rope_exit.modulate.a = 1.0
	if not main.rope_exit.visible:
		_skip(filename, "rope_exit did not stay visible")
		return
	await _capture(filename, "phase=rest, dungeons_cleared=%s, rope_exit.open_exit(%s), HUD stowed, %s" % [cleared, cleared, extra])
	main.rope_exit.z_index = 80
	if main.play_field:
		main.play_field.visible = true


func _shot_rope_peek(filename: String) -> void:
	status = filename
	_reset_between()
	_plant_sack()
	main.adventure = true
	main.phase = "rest"
	main.dungeons_cleared = 1
	main.in_tutorial = false
	_stow_cabin()
	_hide_chrome(false)
	if main.play_field:
		main.play_field.visible = false
	get_tree().paused = false
	if main.rope_exit == null:
		_skip(filename, "rope_exit node missing")
		return
	main.rope_exit.z_index = 200
	if main.has_method("_rope_loot_rows"):
		main.rope_exit.open_exit(1, main._rope_loot_rows())
	else:
		main.rope_exit.open_exit(1)
	await _wait(0.4)
	main.rope_exit.modulate.a = 1.0
	if not main.rope_exit.visible:
		_skip(filename, "rope_exit did not stay visible")
		return
	await _capture(filename, "rope exit with loot in the air, no peek overlay")
	main.rope_exit.z_index = 80
	if main.play_field:
		main.play_field.visible = true


func _shot_caught(filename: String) -> void:
	status = filename
	_reset_between()
	_stow_cabin()
	if main.rope_exit:
		main.rope_exit.hide_exit()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	_hide_chrome(true)
	get_tree().paused = false
	main.adventure = true
	main.in_tutorial = false
	main.phase = "defeat"
	main.dungeons_cleared = 1
	main._undo_stack = [{"shot": true}]
	main._undo_inflight = false
	main._refresh()
	if main.home_cabin and main.home_cabin.visible:
		main.home_cabin.visible = false
		main._sync_overlay()
	if main.overlay:
		main.overlay.z_index = 200
	await _wait(0.2)
	if main.overlay == null or not main.overlay.visible:
		_skip(filename, "Caught overlay did not show")
		return
	if main.overlay_undo and not main.overlay_undo.visible:
		_skip(filename, "Undo was not visible on the Caught sheet")
		return
	await _capture(filename, "phase=defeat after stowing the cabin, planted one undo snapshot, overlay_btn=defeat.home")
	if main.overlay:
		main.overlay.z_index = 80


func _shot_loss(filename: String) -> void:
	status = filename
	_reset_between()
	_hide_chrome(false)
	main.hotbar.clear()
	var cabin = main.home_cabin
	if cabin == null:
		_skip(filename, "home_cabin missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	main._open_home_cabin(true, "loss", [], [])
	cabin._arrive_skip = 2
	var ok: bool = await _until(func() -> bool:
		return cabin.visible and not cabin._arriving and cabin._int_root.visible and not cabin._sack.visible
	, 8.0)
	if not ok:
		_skip(filename, "loss arrival never settled to interior with the sack hidden")
		return
	await _wait(0.25)
	await _capture(filename, "open_cabin walk-in kind=loss, empty hotbar, skip to chair; sack hidden on settle")


func _shot_intro() -> void:
	status = "13a_intro_panel1.png"
	_reset_between()
	var cabin = main.home_cabin
	if cabin == null or cabin._cutscene == null:
		_skip("13a_intro_panel1.png", "cabin or cutscene missing")
		_skip("13b_intro_panel2.png", "cabin or cutscene missing")
		_skip("13c_intro_panel3.png", "cabin or cutscene missing")
		return
	cabin.intro_seen = false
	cabin.nib_first_done = true
	_hide_chrome(false)
	get_tree().paused = false
	cabin.play_intro(false)
	var started: bool = await _until(func() -> bool:
		return cabin._cutscene != null and cabin._cutscene.is_playing()
	, 3.0)
	if not started:
		_skip("13a_intro_panel1.png", "intro cutscene did not start")
		_skip("13b_intro_panel2.png", "intro cutscene did not start")
		_skip("13c_intro_panel3.png", "intro cutscene did not start")
		return
	await _wait(0.35)
	_finish_cut_line(cabin._cutscene)
	cabin._cutscene.set_held(true)
	await _wait(0.12)
	if cabin._cutscene.panel_index != 0:
		_skip("13a_intro_panel1.png", "intro was not on panel 1 (index 0)")
	else:
		await _capture("13a_intro_panel1.png", "play_intro(), full caption on panel 0, rain clipped inside the frame")
	cabin._cutscene.set_held(false)
	cabin._cutscene._show_panel(1, true)
	cabin._cutscene._start_line()
	_finish_cut_line(cabin._cutscene)
	cabin._cutscene.set_held(true)
	await _wait(0.12)
	if cabin._cutscene.panel_index != 1:
		_skip("13b_intro_panel2.png", "could not hold intro panel 2 (index 1)")
	else:
		await _capture("13b_intro_panel2.png", "intro panel 2, full-frame rain under the dialog")
	cabin._cutscene.set_held(false)
	cabin._cutscene._show_panel(2, true)
	cabin._cutscene._line_i = 1
	cabin._cutscene._start_line()
	_finish_cut_line(cabin._cutscene)
	cabin._cutscene.set_held(true)
	await _wait(0.12)
	if cabin._cutscene.panel_index != 2:
		_skip("13c_intro_panel3.png", "could not hold intro panel 3 (index 2)")
	else:
		await _capture("13c_intro_panel3.png", "same intro, panel 3 Nib line, reserved portrait/text/prompt")
	cabin._cutscene.abort()
	cabin.stop_story()


func _finish_cut_line(cut) -> void:
	if cut == null:
		return
	cut._shown = str(cut._full).length()
	cut._typing = false
	if cut._caption:
		cut._caption.visible_characters = -1
		cut._caption.text = cut._full
	if cut._next:
		cut._next.visible = true
	if cut.has_method("_layout_dialog"):
		cut._layout_dialog()


func _shot_combat_tooltips() -> void:
	status = "text_combat_tips.png"
	_reset_between()
	_stow_cabin()
	if main.overlay:
		main.overlay.visible = false
	if main.tut:
		main.tut.visible = false
	if main.play_field:
		main.play_field.visible = true
	main.adventure = false
	main.in_tutorial = false
	main.phase = "fighting"
	main.hp = 6
	main.blk = 3
	var mid := "goblin"
	if not main.monsters_by_id.has(mid):
		for id in main.monsters_by_id.keys():
			mid = str(id)
			break
	var iid := "throwing_knife"
	if not main.items_by_id.has(iid):
		for id2 in main.items_by_id.keys():
			iid = str(id2)
			break
	main.wheel = []
	for _i in 8:
		main.wheel.append(main._make_monster(mid))
	main.facing_index = 0
	main.hotbar.clear()
	main.hotbar.append(main._make_item(iid))
	main._hotbar_sig = ""
	main._refresh()
	await _wait(0.25)
	var card: Control = null
	if main.hotbar_box and main.hotbar_box.get_child_count() > 0:
		card = main.hotbar_box.get_child(0) as Control
	if card and main.hotbar.size() > 0:
		main._on_item_hovered(main.hotbar[0], card)
	await _wait(0.2)
	await _capture("text_combat_tips.png", "fighting goblin, face plaque + item tooltip open")
	main._hide_fight_hover()


func _shot_challenge_ready() -> void:
	status = "text_challenge_ready.png"
	_prep_play("ready")
	main.adventure = true
	main.in_tutorial = false
	main.facing_index = -1
	main.challenge_aim = 0
	_seat_ids(["goblin", "wizard", "golem", "ogre", "harpy", "bandit"])
	main.phase = "ready"
	main._refresh()
	await _wait(0.25)
	await _capture("text_challenge_ready.png", "Challenge ready, Spin is reminder text, a slice is selected")


func _shot_tutorial_nib() -> void:
	status = "text_tutorial_nib.png"
	_prep_play("ready")
	if main.tut == null:
		_skip("text_tutorial_nib.png", "tutorial missing")
		return
	main.in_tutorial = true
	main.tut.visible = true
	main.tut.open()
	await _wait(0.3)
	await _capture("text_tutorial_nib.png", "tutorial Nib box to the right of the wheel")
	main.tut.close()
	main.in_tutorial = false


func _prep_play(phase_name: String) -> void:
	_reset_between()
	_stow_cabin()
	_hide_chrome(false)
	if main.overlay:
		main.overlay.visible = false
	if main.tut:
		main.tut.visible = false
	if main.play_field:
		main.play_field.visible = true
	main.adventure = false
	main.in_tutorial = false
	main.phase = phase_name
	main.facing_index = -1
	main.wheel = []
	main.hotbar.clear()
	main._hotbar_sig = ""
	if main.wheel_view and main.art and main.wheel_view.has_method("setup_run_hero"):
		main.wheel_view.setup_run_hero(main.art)
	if main.fly_tip:
		main.fly_tip.hide_plate()
	if main.has_method("_hide_fight_hover"):
		main._hide_fight_hover()


func _seat_ids(ids: Array, seat_count: int = 0) -> void:
	## Build a wheel from the given monster ids. Optional seat_count pads empty
	## seats (or trims) so QA can cover 4–8 without assuming Adventure's 8.
	main.wheel = []
	for id in ids:
		var mid := str(id)
		if main.monsters_by_id.has(mid):
			main.wheel.append(main._make_monster(mid))
	if main.wheel.is_empty():
		for id2 in main.monsters_by_id.keys():
			main.wheel.append(main._make_monster(str(id2)))
			if seat_count > 0 and main.wheel.size() >= seat_count:
				break
			if seat_count <= 0 and main.wheel.size() >= 8:
				break
	if seat_count > 0:
		while main.wheel.size() < seat_count:
			var slot: String = str(main.wheel.size())
			main.wheel.append({"kind": "empty", "slot": slot})
		if main.wheel.size() > seat_count:
			main.wheel.resize(seat_count)


func _hand_ids(ids: Array) -> void:
	main.hotbar.clear()
	for id in ids:
		var iid := str(id)
		if main.items_by_id.has(iid):
			main.hotbar.append(main._make_item(iid))
	main._hotbar_sig = ""


func _shot_itch_midfight() -> void:
	status = "40_itch_midfight.png"
	_prep_play("fighting")
	_seat_ids(["goblin", "skeleton", "bandit", "hornet_swarm", "wizard", "ogre", "mimic", "harpy"])
	_hand_ids(["throwing_knife", "shield", "net", "lantern"])
	main.facing_index = 0
	main.hp = 5
	main.blk = 2
	main._refresh()
	main._layout_play_field()
	if main.fly_tip:
		main.fly_tip.hide_plate()
	await _wait(0.3)
	await _capture("40_itch_midfight.png", "mid-fight, eight different monsters, hero HP/BLK, four cards, no tooltip")


func _shot_itch_draft_gate() -> void:
	status = "41_itch_draft_gate.png"
	_prep_play("draft")
	_seat_ids(["goblin", "skeleton", "wizard", "bandit", "ogre", "hornet_swarm"])
	main.draft_action = "ask"
	var lure := "bandit"
	if not main.monsters_by_id.has(lure):
		lure = str(main.wheel[0].get("card_id", "goblin")) if main.wheel.size() > 0 else "goblin"
	main.pending_monster = main._make_monster(lure)
	var guard_tier: int = main._tier_of(main.pending_monster)
	main._stamp_pack(main.pending_monster, guard_tier, "draft")
	var relic := "breastplate"
	if not main.items_by_id.has(relic):
		relic = "shield" if main.items_by_id.has("shield") else "throwing_knife"
	main.pending_item = main._make_item(relic)
	main._stamp_pack(main.pending_item, guard_tier, "draft")
	main._refresh()
	main._layout_play_field()
	main._present_gate(2)
	await _wait(0.45)
	if main.fly_tip:
		main.fly_tip.hide_plate()
	if main.draft_gate and main.wheel_view:
		main.draft_gate.dock(main.wheel_view)
	await _wait(0.1)
	await _capture("41_itch_draft_gate.png", "draft gate over a seated dungeon, loot card up, no tooltip")
	if main.draft_gate:
		main.draft_gate.hide_gate()


func _shot_itch_boss() -> void:
	status = "42_itch_boss.png"
	_prep_play("fighting")
	_seat_ids(["dragon", "lich", "vampire", "commander", "wraith", "slime_boss", "cowardly_king", "spider_queen"])
	_hand_ids(["throwing_knife", "shield", "longbow"])
	main.facing_index = 0
	main.hp = 4
	main.blk = 1
	main._refresh()
	main._layout_play_field()
	if main.fly_tip:
		main.fly_tip.hide_plate()
	await _wait(0.3)
	await _capture("42_itch_boss.png", "Deadly dragon fight, other monsters on the wheel, hero HP/BLK, cards in hand")


func _shot_item_hand() -> void:
	status = "text_item_hand.png"
	_reset_between()
	_stow_cabin()
	if main.overlay:
		main.overlay.visible = false
	if main.tut:
		main.tut.visible = false
	if main.play_field:
		main.play_field.visible = true
	main.adventure = false
	main.in_tutorial = false
	main.phase = "ready"
	main.facing_index = -1
	main.wheel = []
	main.hotbar.clear()
	for id in ["throwing_knife", "shield", "net", "lantern"]:
		if main.items_by_id.has(id):
			main.hotbar.append(main._make_item(id))
	main._hotbar_sig = ""
	main._refresh()
	await _wait(0.25)
	await _capture("text_item_hand.png", "ready phase, four-item hand, no tooltip")


func _shot_keyring(filename: String) -> void:
	status = filename
	_reset_between()
	var cabin = main.home_cabin
	if cabin == null:
		_skip(filename, "home_cabin missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	_hide_chrome(false)
	cabin.visible = true
	cabin._refresh_rooms()
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(cabin.play_key_ring, CONNECT_ONE_SHOT)
	var cut_on: bool = await _until(func() -> bool:
		return cabin._cutscene != null and cabin._cutscene.is_playing()
	, 4.0)
	if cut_on:
		cabin._cutscene.abort()
	var unlocking: bool = await _until(func() -> bool:
		return _find_anim(cabin, "u") != null
	, 8.0)
	if not unlocking:
		_skip(filename, "side-door unlock sprite never appeared after skipping the key-ring panel")
		cabin.visible = false
		cabin.stop_story()
		return
	await _wait(0.18)
	await _capture(filename, "play_key_ring(), abort the panel, wait for doors/side_door_unlock while Nib is at the hall door")
	cabin.visible = false
	cabin.stop_story()
	await _wait(0.4)


func _plant_sack() -> void:
	var cabin = main.home_cabin
	main.hotbar.clear()
	var ids: Array = []
	ids.append_array(SACK_OWNED)
	ids.append_array(SACK_NEW)
	for id in ids:
		var it: Dictionary = main._make_item(str(id))
		if it.is_empty():
			continue
		main.hotbar.append(it)
	if cabin == null:
		return
	for id2 in SACK_OWNED:
		cabin.swiped[str(id2)] = true
		cabin.seen[str(id2)] = true
	for id3 in SACK_NEW:
		cabin.swiped.erase(str(id3))


func _stow_cabin() -> void:
	var cabin = main.home_cabin
	if cabin == null:
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.stop_story()
	if cabin._cutscene and cabin._cutscene.is_playing():
		cabin._cutscene.abort()
	cabin.hide_for_run()
	cabin.visible = false


func _hide_chrome(keep_overlay: bool) -> void:
	var nodes: Array = [
		main.tut, main.speech_box, main.inspect, main.face_box, main.fly_tip,
		main.log_btn, main.log_label, main._copy_stamp, main._courier,
		main.settings_ui, main.combat_stage,
	]
	for n in nodes:
		if n:
			n.visible = false
	if main.overlay and not keep_overlay:
		main.overlay.visible = false
	if main.overlay_tools_row:
		main.overlay_tools_row.visible = false
	if main.overlay_latest:
		main.overlay_latest.visible = false
	if main.btn_start:
		main.btn_start.visible = false
	if main.overlay_dev:
		main.overlay_dev.visible = false
	if main.overlay_roster:
		main.overlay_roster.visible = false
	if main.overlay_script:
		main.overlay_script.visible = false
	if main.home_cabin and main.home_cabin._editor_strip:
		main.home_cabin._editor_strip.visible = false


func _reset_between() -> void:
	_restore_disk()
	if main.home_cabin:
		main.home_cabin.stop_story()
		if main.home_cabin.has_method("clear_debug_fx"):
			main.home_cabin.clear_debug_fx()
		if main.home_cabin._dialog and main.home_cabin._dialog.has_method("dismiss"):
			main.home_cabin._dialog.dismiss()
		if main.home_cabin._cutscene and main.home_cabin._cutscene.is_playing():
			main.home_cabin._cutscene.abort()
		main.home_cabin._load_save()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	if main.rope_exit:
		main.rope_exit.hide_exit()
		main.rope_exit.z_index = 80
	if main.settings_ui and main.settings_ui.visible and main.settings_ui.has_method("close_menu"):
		main.settings_ui.close_menu()
	if main.play_field:
		main.play_field.visible = true
	main.in_tutorial = false
	main._undo_stack.clear()
	main._undo_inflight = false


func _snapshot_save() -> void:
	_save_text = ""
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			_save_text = f.get_as_text()


func _restore_disk() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(_save_text)


func _restore_all() -> void:
	_restore_disk()
	if not SHOT_CLI.end_guard():
		_harness_error = "save restore failed"
	if main.home_cabin:
		main.home_cabin.stop_story()
		main.home_cabin._load_save()
		main.home_cabin.hide_for_run()
	if main.rope_exit:
		main.rope_exit.hide_exit()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	main.hotbar.clear()
	main.phase = "title"
	main.adventure = false
	main.dungeons_cleared = 0
	main._undo_stack.clear()
	if main.play_field:
		main.play_field.visible = true
	if main.overlay:
		main.overlay.z_index = 80
	if main.home_cabin and main.home_cabin._editor_strip and main._authoring():
		main.home_cabin._editor_strip.visible = true
	main._refresh()


func _capture(filename: String, how: String, layout_id: String = "") -> void:
	if not _wants_file(filename):
		return
	TEXT_RESERVE.settle(main)
	if main.text_audit:
		main.text_audit.visible = false
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var tex: ViewportTexture = main.get_viewport().get_texture()
	if tex == null:
		_skip(filename, "viewport texture missing")
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		_skip(filename, "viewport image empty")
		return
	if img.get_width() != W or img.get_height() != H:
		img.resize(W, H, Image.INTERPOLATE_NEAREST)
	var abs_path: String = ProjectSettings.globalize_path(out_dir).path_join(filename)
	var err: Error = img.save_png(abs_path)
	if err != OK:
		_skip(filename, "save_png failed (%s)" % err)
		return
	notes.append({"file": filename, "status": "ok", "how": how})
	_audit_shot(filename)
	if layout_id != "":
		LAYOUT_CHECK.layout_check(layout_id, get_tree())


func _skip(filename: String, why: String) -> void:
	if not _wants_file(filename):
		return
	notes.append({"file": filename, "status": "skip", "how": why})
	_log_progress("skip %s: %s" % [filename, why])


func _log_progress(line: String) -> void:
	var path: String = ProjectSettings.globalize_path(out_dir).path_join("_harness.log")
	var prev := ""
	if FileAccess.file_exists(path):
		prev = FileAccess.get_file_as_string(path)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(prev + line + "\n")
	print("SHOT_HARNESS: ", line)


func _audit_shot(filename: String) -> void:
	if main == null or main.text_audit == null:
		return
	var shot: String = out_dir.path_join(filename)
	var fails: Array = main.text_audit.scan(filename.get_basename(), shot)
	for row in fails:
		audit_fails.append(row)
		notes.append({"file": filename, "status": "text_audit", "how": "%s — %s" % [row.get("path", ""), row.get("reason", "")]})


func _shot_text_screens() -> void:
	status = "text-audit"
	if main.text_audit:
		main.text_audit.set_on(true)
	_reset_between()
	var cabin = main.home_cabin
	if cabin == null:
		_skip("text_cabin_main.png", "home_cabin missing")
		return
	_hide_chrome(false)
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	await _wait(0.25)
	await _capture("text_cabin_main.png", "cabin main idle")
	if cabin._dialog and cabin._dialog.has_method("say"):
		cabin._dialog.say(["cabin.locked.first"], ["cabin.locked.try", "cabin.locked.wait"])
		cabin._dialog.advance()
		cabin._dialog.advance()
		await _wait(0.25)
		await _capture("text_cabin_nib.png", "cabin Nib talk box with try-again")
		if cabin._dialog.has_method("dismiss"):
			cabin._dialog.dismiss()
		cabin.say_bubble("cabin.locked")
		await _wait(0.2)
		await _capture("text_cabin_bubble.png", "locked bubble")
		if cabin._dialog.has_method("dismiss"):
			cabin._dialog.dismiss()
	if main.settings_ui:
		main.settings_ui.open_menu(false)
		await _wait(0.2)
		await _capture("text_pause.png", "pause settings")
		if main.settings_ui.has_method("close_menu"):
			main.settings_ui.close_menu()
	if cabin.has_method("_open_map"):
		cabin._open_map()
		await _wait(0.25)
		if cabin._map and cabin._map.has_method("debug_select"):
			cabin._map.debug_select("gatehouse")
			await _wait(0.2)
			await _capture("text_map_adventure.png", "map Adventure / Gatehouse selected")
			cabin._map.debug_select("long_drop")
			await _wait(0.2)
		await _capture("text_map.png", "map Challenge / Long Drop selected")
		if cabin._map:
			cabin._map.close()
	if cabin.has_method("_open_journal"):
		cabin._open_journal()
		if cabin._journal and cabin._journal.has_method("open_spread"):
			cabin._journal.open_spread()
		await _wait(0.25)
		await _capture("text_journal.png", "journal overlay")
		if cabin._journal:
			cabin._journal.close()
	if cabin.has_method("_open_radio"):
		cabin._open_radio()
		await _wait(0.25)
		await _capture("text_radio.png", "radio overlay")
		if cabin._radio:
			cabin._radio.close()
	if cabin.has_method("_open_will"):
		cabin._open_will()
		await _wait(0.25)
		await _capture("text_will.png", "will overlay")
		if cabin._will:
			cabin._will.close()
	if cabin._drawer:
		cabin._drawer.open_drawer()
		await _wait(0.25)
		await _capture("text_drawer.png", "drawer overlay")
		cabin._drawer.close()
	if cabin._card:
		cabin._card.open_card("cabin.brag.title", "Brag", "cabin.brag.close")
		await _wait(0.25)
		await _capture("text_parchment.png", "parchment card")
		cabin._card.close()
	cabin.visible = false
	cabin.stop_story()
	if main.text_audit:
		main.text_audit.set_on(false)


func shot_names() -> PackedStringArray:
	_ensure_registry()
	var names := PackedStringArray()
	for stem in _shot_fns.keys():
		names.append(str(stem))
	return names


func self_check() -> String:
	_ensure_registry()
	if _shot_fns.size() < 40:
		return "registry short (%s)" % _shot_fns.size()
	var seen := {}
	var method_of := {}
	for stem in _shot_fns.keys():
		var name := str(stem)
		if seen.has(name):
			return "duplicate stem %s" % name
		seen[name] = true
		if name == "" or name.contains("."):
			return "bad stem %s" % name
		var fn: Callable = _shot_fns[stem]
		var method_id := str(fn.get_method())
		if method_id == "":
			return "empty runner id for %s" % name
		method_of[name] = method_id
	if method_of["30_hub_idle"] != method_of["39_untouched"]:
		return "hub shots do not share a runner"
	if method_of["18_rope_exit_belly1"] == method_of["24_rope_exit_belly3"]:
		return "rope belly shots collapsed to one runner"
	for target in SHOT_CLI.parse_names(SHOT_CLI.TEXT_TARGETS):
		if not _shot_fns.has(target):
			return "text target missing %s" % target
	var unknown := _fill_wanted("no_such_shot")
	if not unknown.begins_with("unknown"):
		return "unknown shot was accepted"
	var all_err := _fill_wanted("all")
	if all_err != "" or _wanted.size() != _shot_fns.size():
		return "all did not select every shot"
	var list_err := _fill_wanted("30_hub_idle,31_hub_badges.png")
	if list_err != "" or not _wanted.has("30_hub_idle") or not _wanted.has("31_hub_badges") or _wanted.size() != 2:
		return "comma list failed"
	if not _wants_file("30_hub_idle.png") or not _wants_file("31_hub_badges.png"):
		return "want filter missed a requested shot"
	if _apply_out_dir("C:/temp") == "":
		return "non-res shots-out was accepted"
	if _apply_out_dir("res://design/audit-shots/cursor") != "":
		return "res:// shots-out was rejected"
	if not _wants_file("30_hub_idle.png"):
		return "out dir change cleared the shot list"
	_fill_wanted("30_hub_idle")
	if not _wants_file("30_hub_idle.png") or _wants_file("31_hub_badges.png"):
		return "want filter failed"
	return ""


func self_check_async() -> String:
	_ping_ok = false
	var fn := _ping
	await fn.call()
	if not _ping_ok:
		return "callable await failed"
	return ""


func _ping() -> void:
	await get_tree().process_frame
	_ping_ok = true


func _ensure_registry() -> void:
	if not _shot_fns.is_empty():
		return
	_bind_many([
		"30_hub_idle", "31_hub_badges", "32a_blk_empty", "32b_blk_full", "32c_blk_up",
		"32d_hp_flash", "32e_hp_low", "32f_hp_empty", "33_pierce_float", "34a_swipe_f2",
		"34b_hit", "34c_block_f1", "34d_heal_f2", "34e_grab_f1", "34f_victory",
		"34g_death_f3", "35_death_dim", "36a_gear_helm", "36b_gear_helm_swipe",
		"36c_gear_cap", "36d_gear_none", "37a_clear_idle", "37b_clear_swipe_f2",
		"37c_clear_block_f1", "37d_clear_heal_f2", "37e_clear_lowhp_f0",
		"38_courier_walkoff", "39_untouched",
	], _shot_run_hero)
	_bind_many([
		"40a_cabin_gear_helm_sit", "40b_cabin_gear_helm_rock", "40c_cabin_gear_helm_walk",
		"40d_cabin_gear_helm_walk_sad", "40e_cabin_gear_helm_dump", "40f_cabin_gear_helm_shake",
		"41a_cabin_rock_cap", "41b_cabin_rock_helm", "42_cabin_gear_none",
		"43a_cabin_flip_walk_loot", "43b_cabin_flip_dump",
	], _shot_cabin_hero)
	_bind_many([
		"15a_map_classic_selected", "15b_map_challenge_hover", "15c_map_challenge_selected",
	], _shot_map_routes)
	_shot_fns["18_rope_exit_belly1"] = _shot_rope_belly1
	_shot_fns["19_rope_exit_sack_peek"] = _shot_peek
	_shot_fns["20_caught_sheet"] = _shot_caught_sheet
	_shot_fns["21a_win_homecoming_dump"] = _shot_21a
	_shot_fns["21b_win_homecoming_fly"] = _shot_21b
	_shot_fns["22_loss_homecoming"] = _shot_loss_home
	_bind_many(["13a_intro_panel1", "13b_intro_panel2", "13c_intro_panel3"], _shot_intro)
	_shot_fns["text_combat_tips"] = _shot_combat_tooltips
	_shot_fns["text_item_hand"] = _shot_item_hand
	_shot_fns["40_itch_midfight"] = _shot_itch_midfight
	_shot_fns["41_itch_draft_gate"] = _shot_itch_draft_gate
	_shot_fns["42_itch_boss"] = _shot_itch_boss
	_shot_fns["14_keyring_midbeat"] = _shot_keyring_mid
	_shot_fns["24_rope_exit_belly3"] = _shot_rope_belly3
	_bind_many([
		"text_cabin_main", "text_cabin_nib", "text_cabin_bubble", "text_pause", "text_map",
		"text_map_adventure", "text_journal",
		"text_radio", "text_will", "text_drawer", "text_parchment",
	], _shot_text_screens)
	_shot_fns["text_challenge_ready"] = _shot_challenge_ready
	_shot_fns["text_tutorial_nib"] = _shot_tutorial_nib
	_bind_many([
		"01_hornet_plate", "02_hit1_lit", "03_hit2", "04_hornet_block_soak",
		"05_kobold_3", "06_dragon_flame", "07_shark_loop", "08_shambling_overflow",
	], _shot_anim_intent_plate)
	_bind_many([
		"01_hornet_two_rings", "02_poison_pacemaker",
	], _shot_anim_bleed_pulse)
	_bind_many([
		"01_ogre_60ms", "02_ogre_300ms", "03_ogre_700ms",
		"04_hornet_still", "05_vampire_frames",
		"06_queue_three", "07_ogre_first", "08_ogre_second",
		"09_item_banner", "10_ogre_6_seats",
	], _shot_anim_slash_portrait)
	_bind_many([
		"01_cascade_300ms", "02_cascade_900ms", "03_cascade_1800ms",
		"04_cascade_ff_600ms", "05_cascade_ff_release", "06_space_untouched",
		"07_six_seats", "08_intent_plate_final_art",
	], _shot_anim_cascade_ticker)
	_bind_many([
		"60_loft", "61_loft_cat_rub", "62_journal_cover", "63_journal_bestiary",
		"64_journal_items", "65_journal_memories", "66_journal_unmet",
	], _shot_playtest_art)
	_bind_many([
		"67_run_door_open_f2", "68_side_door_open", "69_drawer_rattle", "70_drawer_open",
		"71_dummy_tilt", "72_radio_knob_hover", "73_journal_page_flip", "74_deeper_hole_glow",
		"75_homecoming_fly_spark", "76_new_burst", "77_drop_sack", "78_settings_sliders",
		"79_dialog_speech_tail", "80_trunk_open_hover",
	], _shot_cabin_wiring)


func _bind_many(stems: Array, fn: Callable) -> void:
	for stem in stems:
		_shot_fns[str(stem)] = fn


func _anim_ready_seat(monsters: Array, items: Array, hp_n: int = 6, blk_n: int = 0, seat_count: int = 0) -> void:
	_prep_play("ready")
	_seat_ids(monsters, seat_count)
	_hand_ids(items)
	main.hp = hp_n
	main.blk = blk_n
	main.player_poison = 0
	main.facing_index = -1
	main.phase = "ready"
	# Do not force combat_stage visible here — show_monster on Spin owns that.
	# A pre-shown empty stage parked the intent plate on a bad rect.
	if main.combat_stage and main.combat_stage.has_method("hide_stage"):
		main.combat_stage.hide_stage()
	elif main.combat_stage:
		main.combat_stage.visible = false
	main._sync_wheel_stats()
	main._refresh()
	main._layout_play_field()
	if main.wheel_view:
		main.wheel_view.set_meta("qa_instant", true)
	await _wait(0.05)


func _anim_spin_face(idx: int = 0) -> void:
	main.set_meta("qa_spin_idx", idx)
	await main._on_spin()
	await _wait(0.30)
	if main.has_method("_sync_intent_plate"):
		main._sync_intent_plate()
	if main.intent_plate != null and main.intent_plate.has_method("reanchor"):
		main.intent_plate.reanchor()
	await _wait(0.10)


func _anim_capture_hook(filename: String) -> void:
	var how := "anim QA mid-sequence"
	match filename:
		"02_hit1_lit.png":
			how = "real Take: badge 1 lit/spent after lunge"
		"03_hit2.png":
			how = "real Take: badge 2 after hit 2 lunge"
		"04_hornet_block_soak.png":
			how = "real Take + 2 Block: badge 1 blue flash, still 2"
		"01_hornet_two_rings.png":
			how = "real Take HP loss: two bleed rings + Flail/Vampire"
		"02_poison_pacemaker.png":
			how = "poison tick 2: ring visible + Pacemaker heal 1"
	await _capture(filename, how)


func _anim_arm_capture() -> void:
	main.set_meta("qa_anim_capture", _anim_capture_hook)


func _anim_clear_capture() -> void:
	if main.has_meta("qa_anim_capture"):
		main.remove_meta("qa_anim_capture")
	if main.has_meta("qa_anim_hit_shots"):
		main.remove_meta("qa_anim_hit_shots")
	if main.has_meta("qa_anim_bleed_shot"):
		main.remove_meta("qa_anim_bleed_shot")


func _shot_anim_intent_plate() -> void:
	out_dir = "res://design/visual/anim-qa/intent-plate"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	status = "anim-intent-plate"
	_anim_arm_capture()
	await _anim_ready_seat(["hornet_swarm", "goblin", "skeleton", "bandit"], [], 6, 0)
	await _anim_spin_face(0)
	await _wait(0.20)
	await _capture("01_hornet_plate.png", "Hornet Swarm: two badges each 2")
	if main.phase == "fighting":
		main._walker_busy = false
		main.set_meta("qa_anim_hit_shots", {1: "02_hit1_lit.png", 2: "03_hit2.png"})
		await main._on_done()
		if main.has_meta("qa_anim_hit_shots"):
			main.remove_meta("qa_anim_hit_shots")
	await _anim_ready_seat(["hornet_swarm", "goblin"], [], 6, 2)
	await _anim_spin_face(0)
	main.blk = 2
	main._refresh()
	if main.has_method("_sync_intent_plate"):
		main._sync_intent_plate()
	await _wait(0.20)
	if main.phase == "fighting":
		main._walker_busy = false
		main.set_meta("qa_anim_hit_shots", {1: "04_hornet_block_soak.png"})
		await main._on_done()
		if main.has_meta("qa_anim_hit_shots"):
			main.remove_meta("qa_anim_hit_shots")
	await _anim_ready_seat(["kobold_trapper", "goblin"], ["throwing_knife", "lantern", "net"], 6, 0)
	await _anim_spin_face(0)
	main.items_used_this_combat = 2
	main._refresh()
	if main.has_method("_sync_intent_plate"):
		main._sync_intent_plate()
	await _wait(0.20)
	await _capture("05_kobold_3.png", "Kobold after 2 items: 3 badges")
	await _anim_ready_seat(["dragon", "goblin"], [], 6, 4)
	await _anim_spin_face(0)
	main.blk = 4
	main._refresh()
	if main.has_method("_sync_intent_plate"):
		main._sync_intent_plate()
	await _wait(0.25)
	await _capture("06_dragon_flame.png", "Dragon pierce flame variant")
	await _anim_ready_seat(["shark", "goblin"], [], 6, 0)
	await _anim_spin_face(0)
	await _wait(0.25)
	await _capture("07_shark_loop.png", "Shark badge + loop chip matching wheel tag")
	await _anim_ready_seat(["shambling_mound", "goblin"], [], 6, 0)
	await _anim_spin_face(0)
	if main.facing_index >= 0 and main.facing_index < main.wheel.size():
		main.wheel[main.facing_index]["hp"] = 9
		main.wheel[main.facing_index]["hp_max"] = 9
	main._refresh()
	if main.has_method("_sync_intent_plate"):
		main._sync_intent_plate()
	await _wait(0.25)
	await _capture("08_shambling_overflow.png", "Shambling HP 9: overflow ×N")
	_anim_clear_capture()


func _shot_anim_bleed_pulse() -> void:
	out_dir = "res://design/visual/anim-qa/bleed-pulse"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	status = "anim-bleed-pulse"
	_anim_arm_capture()
	await _anim_ready_seat(["hornet_swarm", "vampire", "goblin"], ["spiked_flail"], 6, 0)
	await _anim_spin_face(0)
	if main.phase == "fighting":
		main._walker_busy = false
		main.set_meta("qa_anim_bleed_shot", "01_hornet_two_rings.png")
		await main._on_done()
	# Poison tick of 2 with Pacemaker: capture while the ring is mid-flight.
	await _anim_ready_seat(["golem", "goblin"], ["pacemaker"], 6, 0)
	main.player_poison = 2
	main._refresh()
	main.set_meta("qa_spin_idx", 0)
	main.set_meta("qa_anim_bleed_shot", "02_poison_pacemaker.png")
	await main._on_spin()
	_anim_clear_capture()


func _slash_payload(id: String, is_item: bool = false) -> Dictionary:
	var title := id.capitalize().replace("_", " ")
	var call_n := ""
	var tex: Texture2D = null
	if is_item:
		if main.items_by_id.has(id):
			var it: Dictionary = main._make_item(id)
			title = str(it.get("name", title))
			if main.has_method("_item_icon_tex"):
				tex = main._item_icon_tex(it)
		return {"title": title, "call": "", "tex": tex, "is_item": true, "card_id": id, "fast": false}
	if main.monsters_by_id.has(id):
		var m: Dictionary = main._make_monster(id)
		title = str(m.get("name", title))
		call_n = str(m.get("call_name", "")).strip_edges()
		if call_n == "" and id == "triclops":
			call_n = "Cut And Run"
	if main.art != null and main.art.has_method("monster_still"):
		tex = main.art.monster_still(id)
	return {
		"title": title,
		"call": call_n,
		"tex": tex,
		"is_item": false,
		"card_id": id,
		"fast": false,
	}


func _slash_wait_idle(timeout: float = 4.0) -> void:
	await _until(func() -> bool:
		if main.ability_slash == null:
			return true
		if main.ability_slash.has_method("is_busy") and main.ability_slash.is_busy():
			return false
		return not main.ability_slash.visible
	, timeout)


func _shot_anim_slash_portrait() -> void:
	out_dir = "res://design/visual/anim-qa/slash-portrait"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	status = "anim-slash-portrait"
	# Seat count is not fixed at 8; slash cut-in must work with 4–8. Start with 4.
	await _anim_ready_seat(["ogre", "hornet_swarm", "vampire", "goblin"], ["shield"], 6, 0)
	if main.ability_slash == null:
		_skip("01_ogre_60ms.png", "ability_slash missing")
		return
	main.ability_slash.reset_slash_seen()
	# Timed marks use the normal hold (not the first-cut-in +250ms) so 700ms lands in slash-out.
	if main.ability_slash.has_method("mark_slash_seen"):
		main.ability_slash.mark_slash_seen("ogre")
	# Ogre timed shots (frames path).
	main.ability_slash.play(_slash_payload("ogre"))
	await _wait(0.06)
	await _capture("01_ogre_60ms.png", "Ogre cut-in ~60ms band entering")
	await _wait(0.24)
	await _capture("02_ogre_300ms.png", "Ogre cut-in ~300ms mid action; compare mock_slash_portrait_ogre.png")
	await _wait(0.40)
	await _capture("03_ogre_700ms.png", "Ogre cut-in ~700ms slash-out")
	await _slash_wait_idle()
	# Still fallback: Hornet Swarm (frames pending). Vampire has real frames.
	main.ability_slash.play(_slash_payload("hornet_swarm"))
	await _wait(0.28)
	await _capture("04_hornet_still.png", "Hornet Swarm still fallback punch-in")
	await _slash_wait_idle()
	main.ability_slash.play(_slash_payload("vampire"))
	await _wait(0.28)
	await _capture("05_vampire_frames.png", "Vampire cut-in using real slash frames")
	await _slash_wait_idle()
	# Three queued triggers never overlap.
	var overlap := false
	var seen_busy := 0
	main.ability_slash.play(_slash_payload("ogre"))
	main.ability_slash.play(_slash_payload("hornet_swarm"))
	main.ability_slash.play(_slash_payload("vampire"))
	var guard_ms: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < guard_ms:
		if main.ability_slash.visible:
			seen_busy += 1
		# Queue depth cannot be two visibles; only one Control.
		await _wait(0.03)
		if not main.ability_slash.is_busy():
			break
	if seen_busy < 3:
		overlap = true
	await _capture("06_queue_three.png", "after three queued cut-ins; serialized=%s" % (not overlap))
	_log_progress("queue_three seen_busy_ticks=%s overlap_flag=%s" % [seen_busy, overlap])
	await _slash_wait_idle()
	# First Ogre cut-in longer than second (+250ms hold).
	main.ability_slash.reset_slash_seen()
	var t0: int = Time.get_ticks_msec()
	await main.ability_slash.play(_slash_payload("ogre"))
	var first_ms: int = Time.get_ticks_msec() - t0
	await _capture("07_ogre_first.png", "first Ogre cut-in done (%sms)" % first_ms)
	var t1: int = Time.get_ticks_msec()
	await main.ability_slash.play(_slash_payload("ogre"))
	var second_ms: int = Time.get_ticks_msec() - t1
	await _capture("08_ogre_second.png", "second Ogre cut-in done (%sms); first_longer=%s" % [second_ms, first_ms > second_ms + 100])
	_log_progress("ogre_first_ms=%s ogre_second_ms=%s" % [first_ms, second_ms])
	# Item keeps the small gutter banner.
	main._layout_play_field()
	main.ability_slash.play(_slash_payload("shield", true))
	await _wait(0.20)
	await _capture("09_item_banner.png", "item trigger still uses small gutter banner")
	await _slash_wait_idle()
	# Six seats seated (Challenge-sized wheel); cut-in must not assume 8.
	await _anim_ready_seat([
		"ogre", "goblin", "skeleton", "vampire", "bandit", "lich",
	], ["shield"], 6, 0)
	_log_progress("six_seats wheel_size=%s" % main.wheel.size())
	main.ability_slash.reset_slash_seen()
	if main.ability_slash.has_method("mark_slash_seen"):
		main.ability_slash.mark_slash_seen("ogre")
	main.ability_slash.play(_slash_payload("ogre"))
	await _wait(0.30)
	await _capture("10_ogre_6_seats.png", "Ogre cut-in with 6 wheel seats seated")
	await _slash_wait_idle()


func _cascade_capture(filename: String, how: String) -> void:
	## Concurrent with `_on_spin`; avoid RenderingServer.frame_post_draw (can stall mid-await).
	if not _wants_file(filename):
		return
	if main.text_audit:
		main.text_audit.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	var tex: ViewportTexture = main.get_viewport().get_texture()
	if tex == null:
		_skip(filename, "viewport texture missing")
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		_skip(filename, "viewport image empty")
		return
	if img.get_width() != W or img.get_height() != H:
		img.resize(W, H, Image.INTERPOLATE_NEAREST)
	var abs_path: String = ProjectSettings.globalize_path(out_dir).path_join(filename)
	var err: Error = img.save_png(abs_path)
	if err != OK:
		_skip(filename, "save_png failed (%s)" % err)
		return
	notes.append({"file": filename, "status": "ok", "how": how})
	_log_progress("captured %s" % filename)


func _shot_anim_cascade_ticker() -> void:
	out_dir = "res://design/visual/anim-qa/spin-cascade-ticker"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	status = "anim-cascade-ticker"
	# Plague Doctor, Spider Queen, Cultist, Harpy + Grief Jar + Marble.
	# Force-spin a Cultist neighbour (Harpy at index 3; Cultist at 2).
	# Wheel size = seated count (4 here); strip must not assume 8.
	await _anim_ready_seat(
		["plague_doctor", "spider_queen", "cultist", "harpy"],
		["grief_jar", "marble"],
		6, 0, 0
	)
	if main.cascade_ticker == null:
		_skip("01_cascade_300ms.png", "cascade_ticker missing")
		return
	_log_progress("cascade seat ok wheel=%s" % main.wheel.size())
	main.set_meta("qa_spin_idx", 3)
	main._on_spin()
	var t0: int = Time.get_ticks_msec()
	await _wait(0.30)
	_log_progress("mark_300ms elapsed=%s ticker=%s" % [Time.get_ticks_msec() - t0, main.cascade_ticker.visible])
	await _cascade_capture("01_cascade_300ms.png", "cascade ~300ms: tokens appearing")
	await _wait(0.60)
	_log_progress("mark_900ms elapsed=%s" % [Time.get_ticks_msec() - t0])
	await _cascade_capture("02_cascade_900ms.png", "cascade ~900ms: active token lifted")
	await _wait(0.90)
	_log_progress("mark_1800ms elapsed=%s" % [Time.get_ticks_msec() - t0])
	await _cascade_capture("03_cascade_1800ms.png", "cascade ~1800ms: stamped tokens")
	await _until(func() -> bool:
		return not bool(main._walker_busy)
	, 20.0)
	_log_progress("cascade1 done phase=%s busy=%s hp=%s" % [main.phase, main._walker_busy, main.hp])
	# Let the first `_on_spin` coroutine finish its deferred intent-plate tail.
	await _wait(0.35)
	# Repeat with Shift / FF held. Fresh HP so Grief Jar bleed cannot end the cascade early.
	await _anim_ready_seat(
		["plague_doctor", "spider_queen", "cultist", "harpy"],
		["grief_jar", "marble"],
		8, 0, 0
	)
	main.hp = 8
	main.set_meta("qa_force_shift", true)
	main.set_meta("qa_spin_idx", 3)
	_log_progress("ff_start time_scale=%s hp=%s wheel=%s" % [Engine.time_scale, main.hp, main.wheel.size()])
	main._on_spin()
	# Wall-clock ~200ms at 3x ≈ 600ms cascade time; capture before the next slash fills the strip.
	await _wait(0.20)
	_log_progress("ff_held time_scale=%s ff_chip=%s busy=%s phase=%s" % [
		Engine.time_scale,
		main.cascade_ticker != null and main.cascade_ticker.is_ff(),
		main._walker_busy,
		main.phase,
	])
	await _cascade_capture("04_cascade_ff_600ms.png", "Shift FF ~600ms cascade-time: FF chip + time_scale≈3")
	main.set_meta("qa_force_shift", false)
	await _wait(0.12)
	_log_progress("ff_release time_scale=%s" % Engine.time_scale)
	await _cascade_capture("05_cascade_ff_release.png", "Shift released mid-cascade: time_scale back to 1.0")
	await _until(func() -> bool:
		return not bool(main._walker_busy)
	, 20.0)
	if main.has_meta("qa_force_shift"):
		main.remove_meta("qa_force_shift")
	_log_progress("space_untouched: no Spin shortcut added; ui_accept left alone")
	await _cascade_capture("06_space_untouched.png", "Space/ui_accept unchanged; no new Spin shortcut")
	# Challenge-sized wheel (6 seats). Strip width follows tokens, not seat count.
	await _anim_ready_seat(
		["plague_doctor", "spider_queen", "cultist", "harpy", "goblin", "skeleton"],
		["grief_jar", "marble"],
		8, 0, 6
	)
	_log_progress("six_seats wheel=%s" % main.wheel.size())
	main.set_meta("qa_spin_idx", 3)
	main._on_spin()
	await _wait(0.90)
	await _cascade_capture("07_six_seats.png", "cascade with 6 wheel seats; ticker independent of seat count")
	await _until(func() -> bool:
		return not bool(main._walker_busy)
	, 20.0)
	await _wait(0.25)
	# Hornet Swarm intent plate with final PixelLab claw art.
	await _anim_ready_seat(["hornet_swarm", "goblin", "skeleton", "bandit"], [], 6, 0, 0)
	await _anim_spin_face(0)
	await _wait(0.20)
	await _cascade_capture("08_intent_plate_final_art.png", "Hornet Swarm intent plate: final claw art")


func _shot_peek() -> void:
	await _shot_rope_peek("19_rope_exit_sack_peek.png")


func _shot_caught_sheet() -> void:
	await _shot_caught("20_caught_sheet.png")


func _shot_loss_home() -> void:
	await _shot_loss("22_loss_homecoming.png")


func _shot_keyring_mid() -> void:
	await _shot_keyring("14_keyring_midbeat.png")


func _shot_playtest_art() -> void:
	status = "playtest-art"
	_reset_between()
	_hide_chrome(false)
	var cabin = main.home_cabin
	if cabin == null:
		_skip("60_loft.png", "home_cabin missing")
		return
	if main.play_field:
		main.play_field.visible = false
	if main.overlay:
		main.overlay.visible = false
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	if not cabin.rooms_unlocked.has("loft"):
		cabin.rooms_unlocked.append("loft")
	if not cabin.rooms_unlocked.has("study"):
		cabin.rooms_unlocked.append("study")
	cabin.visible = true
	cabin.show_menu("loft")
	await _wait(0.25)
	var loft = cabin._rooms.get("loft") if cabin._rooms else null
	if loft and loft.cat_sleep:
		loft.cat_sleep.position = Vector2(176, 196) * 4.0
		if loft.cat_sleep.sprite_frames and loft.cat_sleep.sprite_frames.has_animation("z"):
			loft.cat_sleep.play("z")
	await _capture("60_loft.png", "loft, sleep cat at native (176, 196)")
	if loft and loft.has_method("pose_rub_frame"):
		loft.pose_rub_frame(2)
		await _wait(0.08)
		await _capture("61_loft_cat_rub.png", "loft cat rub frame f2 at native (180, 196)")
	else:
		_skip("61_loft_cat_rub.png", "pose_rub_frame missing")
	if cabin._journal == null:
		_skip("62_journal_cover.png", "journal overlay missing")
		cabin.visible = false
		return
	cabin.show_menu("study")
	await _wait(0.2)
	var first_id := ""
	var mons: Variant = cabin.catalog.get("monsters", [])
	if mons is Array:
		for row in mons:
			if row is Dictionary and str(row.get("id", "")) != "":
				first_id = str(row.get("id", ""))
				break
	cabin.met_monsters = {}
	if first_id != "":
		cabin.met_monsters[first_id] = true
	cabin._journal.open_journal("bestiary")
	await _wait(0.2)
	await _capture("62_journal_cover.png", "journal cover at the spread origin, spread still closed")
	cabin._journal.open_spread()
	await _wait(0.15)
	await _capture("63_journal_bestiary.png", "bestiary spread, first monster met")
	cabin._journal.show_tab("items")
	await _wait(0.12)
	await _capture("64_journal_items.png", "items tab, no lore rect")
	cabin._journal.show_tab("memories")
	await _wait(0.12)
	await _capture("65_journal_memories.png", "memories tab, intro shots under tape wells")
	cabin.met_monsters = {}
	cabin._journal.show_tab("bestiary")
	await _wait(0.12)
	await _capture("66_journal_unmet.png", "unmet bestiary entry, scribble inside the right lore rect")
	cabin._journal.close()
	cabin.visible = false
	cabin.stop_story()
	if main.play_field:
		main.play_field.visible = true


func _shot_cabin_wiring() -> void:
	status = "cabin-wiring"
	_reset_between()
	_hide_chrome(false)
	var cabin = main.home_cabin
	if cabin == null:
		_skip("67_run_door_open_f2.png", "home_cabin missing")
		return
	if main.play_field:
		main.play_field.visible = false
	if main.overlay:
		main.overlay.visible = false
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.ending_seen = true
	cabin.drawer_opened = false
	cabin.stop_story()
	cabin.visible = true
	for r in ["hall", "study", "workshop", "loft"]:
		if not cabin.rooms_unlocked.has(r):
			cabin.rooms_unlocked.append(r)
	cabin.show_menu("main")
	await _wait(0.2)
	if cabin.has_method("debug_run_door_open"):
		cabin.debug_run_door_open(2)
		await _wait(0.08)
		await _capture("67_run_door_open_f2.png", "run door open f2 (night + Grumblegut)")
	else:
		_skip("67_run_door_open_f2.png", "debug_run_door_open missing")
	if cabin.has_method("debug_side_door_open"):
		cabin.debug_side_door_open("main")
		await _wait(0.08)
		await _capture("68_side_door_open.png", "main side door open state")
	else:
		_skip("68_side_door_open.png", "debug_side_door_open missing")
	cabin.show_menu("study")
	await _wait(0.15)
	cabin._refresh_rooms()
	if cabin.has_method("debug_drawer_rattle_frame"):
		cabin.debug_drawer_rattle_frame(1)
		await _wait(0.08)
		await _capture("69_drawer_rattle.png", "stuck drawer rattle mid-frame")
	else:
		_skip("69_drawer_rattle.png", "debug_drawer_rattle_frame missing")
	if cabin.has_method("debug_drawer_open_frame"):
		cabin.debug_drawer_open_frame(3)
		await _wait(0.08)
		await _capture("70_drawer_open.png", "drawer open hold f3")
	else:
		_skip("70_drawer_open.png", "debug_drawer_open_frame missing")
	cabin.show_menu("workshop")
	await _wait(0.15)
	if cabin.has_method("debug_dummy_tilt"):
		cabin.debug_dummy_tilt("l")
		await _wait(0.08)
		await _capture("71_dummy_tilt.png", "training dummy tilt_l")
	else:
		_skip("71_dummy_tilt.png", "debug_dummy_tilt missing")
	cabin.show_menu("main")
	await _wait(0.1)
	if cabin._radio:
		cabin._open_radio()
		await _wait(0.15)
		if cabin._radio._knobs.size() > 0:
			cabin._radio._knob_hover[0] = true
			cabin._radio._refresh_knob(0)
		await _wait(0.08)
		await _capture("72_radio_knob_hover.png", "radio knob 0 hover frame")
		cabin._radio.close()
	else:
		_skip("72_radio_knob_hover.png", "radio missing")
	cabin.show_menu("study")
	await _wait(0.1)
	if cabin._journal:
		cabin.met_monsters = {"goblin": true}
		cabin._journal.open_journal("bestiary")
		await _wait(0.15)
		cabin._journal.open_spread()
		await _wait(0.1)
		cabin._journal._play_page_flip(true)
		await _wait(0.12)
		await _capture("73_journal_page_flip.png", "journal page flip mid anim")
		cabin._journal.close()
	else:
		_skip("73_journal_page_flip.png", "journal missing")
	if main.rope_exit:
		cabin.visible = false
		main.rope_exit.z_index = 200
		main.rope_exit.open_exit(1, [])
		main.rope_exit.modulate.a = 1.0
		await _wait(0.25)
		await _capture("74_deeper_hole_glow.png", "deeper hole idle glow pulse")
		main.rope_exit.hide_exit()
		main.rope_exit.z_index = 80
		cabin.visible = true
	else:
		_skip("74_deeper_hole_glow.png", "rope_exit missing")
	cabin.show_menu("main")
	await _wait(0.1)
	if cabin.has_method("debug_win_fly"):
		cabin.debug_win_fly()
		await _wait(0.2)
		await _capture("75_homecoming_fly_spark.png", "fly spark + trail on mid-air loot")
		if cabin.has_method("clear_debug_fx"):
			cabin.clear_debug_fx()
	else:
		_skip("75_homecoming_fly_spark.png", "debug_win_fly missing")
	cabin.show_menu("hall")
	await _wait(0.15)
	if cabin.has_method("debug_new_burst"):
		cabin.debug_new_burst()
		await _wait(0.12)
		await _capture("76_new_burst.png", "NEW item burst on mount")
		if cabin.has_method("clear_debug_fx"):
			cabin.clear_debug_fx()
	else:
		_skip("76_new_burst.png", "debug_new_burst missing")
	cabin.show_menu("main")
	await _wait(0.1)
	if cabin.has_method("debug_drop_sack"):
		cabin.debug_drop_sack(2)
		await _wait(0.08)
		await _capture("77_drop_sack.png", "hero_drop_sack f2 at (70,205) flip_h")
	else:
		_skip("77_drop_sack.png", "debug_drop_sack missing")
	if main.settings_ui:
		main.settings_ui.open_menu(false)
		await _wait(0.15)
		await _capture("78_settings_sliders.png", "pause sliders with cabin track/grabber")
		if main.settings_ui.has_method("close_menu"):
			main.settings_ui.close_menu()
	else:
		_skip("78_settings_sliders.png", "settings_ui missing")
	cabin.show_menu("main")
	await _wait(0.1)
	if cabin._dialog:
		cabin._dialog.say(["nib.idle.1"])
		await _wait(0.2)
		await _capture("79_dialog_speech_tail.png", "dialog box with speech_tail under bust")
		if cabin._dialog.has_method("dismiss"):
			cabin._dialog.dismiss()
	else:
		_skip("79_dialog_speech_tail.png", "dialog missing")
	cabin.trunk_open = true
	cabin.show_menu("loft")
	await _wait(0.15)
	cabin._refresh_rooms()
	var loft = cabin._rooms.get("loft")
	var trunk = loft.spots.get("Trunk", null) if loft else null
	if trunk is CabinHotspot:
		trunk._hovering = true
		trunk._refresh_tex()
		await _wait(0.08)
		await _capture("80_trunk_open_hover.png", "trunk open + open_hover")
		trunk._hovering = false
		trunk._refresh_tex()
	else:
		_skip("80_trunk_open_hover.png", "trunk hotspot missing")
	cabin.trunk_open = false
	cabin.visible = false
	cabin.stop_story()
	if main.play_field:
		main.play_field.visible = true


func _apply_out_dir(dest: String) -> String:
	var path := dest.strip_edges()
	if path == "":
		path = OUT_DIR
	if not path.begins_with("res://"):
		return "shots-out must be a res:// directory"
	out_dir = path
	return ""


func _fill_wanted(raw: String) -> String:
	var names := SHOT_CLI.parse_names(raw)
	if names.is_empty():
		return "empty shot list"
	var use_all := false
	for name in names:
		if name == "all":
			use_all = true
			break
	_wanted.clear()
	if use_all:
		for stem in _shot_fns.keys():
			_wanted[str(stem)] = true
		return ""
	var unknown: PackedStringArray = []
	for name in names:
		if name == "all":
			continue
		if not _shot_fns.has(name):
			unknown.append(name)
		else:
			_wanted[name] = true
	if unknown.size() > 0:
		return "unknown shot: " + ",".join(unknown)
	if _wanted.is_empty():
		return "empty shot list"
	return ""


func _run_table() -> void:
	var ran := {}
	for stem in _shot_fns.keys():
		if not _wanted.has(str(stem)):
			continue
		var fn: Callable = _shot_fns[stem]
		var id := str(fn.get_method())
		if ran.has(id):
			continue
		ran[id] = true
		await fn.call()


func _wants_file(filename: String) -> bool:
	return _wanted.has(filename.get_basename())


func _noted(stem: String) -> bool:
	for row in notes:
		if str(row.get("file", "")).get_basename() == stem:
			return true
	return false


func _note_missing() -> void:
	for stem in _wanted.keys():
		if _noted(str(stem)):
			continue
		notes.append({"file": str(stem) + ".png", "status": "skip", "how": "not captured"})
		_log_progress("skip %s: not captured" % stem)


func _exit_code() -> int:
	if _harness_error != "":
		return 2
	for row in notes:
		var st := str(row.get("status", ""))
		if st == "skip" or st == "text_audit":
			return 1
	return 0


func _write_audit_summary() -> void:
	var pack := {
		"updated": Time.get_datetime_string_from_system(),
		"failures": audit_fails,
	}
	var raw: String = JSON.stringify(pack, "\t")
	var copy_path := out_dir.path_join("text_audit.json")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	var g := FileAccess.open(copy_path, FileAccess.WRITE)
	if g:
		g.store_string(raw)
		g.close()
	var f := FileAccess.open("user://text_audit.json", FileAccess.WRITE)
	if f:
		f.store_string(raw)
		f.close()


func _wait(sec: float) -> void:
	get_tree().paused = false
	var end_ms: int = Time.get_ticks_msec() + int(round(maxf(0.0, sec) * 1000.0))
	while Time.get_ticks_msec() < end_ms:
		await get_tree().process_frame


func _until(pred: Callable, timeout: float) -> bool:
	var t := 0.0
	while t < timeout:
		if pred.call():
			return true
		await _wait(0.05)
		t += 0.05
	return false


func _find_anim(node: Node, anim: String) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		var spr: AnimatedSprite2D = node
		if spr.is_playing() and spr.animation == anim:
			return spr
	for child in node.get_children():
		var found: AnimatedSprite2D = _find_anim(child, anim)
		if found:
			return found
	return null
