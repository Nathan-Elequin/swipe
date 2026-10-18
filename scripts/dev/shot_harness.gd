extends Node
## Editor-only audit captures. Main loads this only when `_authoring()`.

const OUT_DIR := "res://design/audit-shots/cursor"
const TEXT_RESERVE := preload("res://scripts/ui/text_reserve.gd")
const LAYOUT_CHECK := preload("res://scripts/dev/layout_check.gd")
const TEXT_OUT_DIR := "res://design/cli-runs/02-fx-tooltips"
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


func setup(p_main) -> void:
	main = p_main
	name = "ShotHarness"
	process_mode = Node.PROCESS_MODE_ALWAYS


func begin() -> String:
	if main == null or not main._authoring():
		return "blocked: not authoring"
	if running:
		return "already running"
	running = true
	finished = false
	notes.clear()
	audit_fails.clear()
	status = "starting"
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(_run, CONNECT_ONE_SHOT)
	return "started"


func begin_text_targets() -> String:
	if main == null or not main._authoring():
		return "blocked: not authoring"
	if running:
		return "already running"
	running = true
	finished = false
	notes.clear()
	audit_fails.clear()
	status = "text-targets"
	out_dir = TEXT_OUT_DIR
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(_run_text_targets, CONNECT_ONE_SHOT)
	return "started"


func _run() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	_log_progress("run start")
	get_tree().paused = false
	_snapshot_save()
	if main._copy_stamp:
		_stamp_was = main._copy_stamp.visible
		main._copy_stamp.visible = false

	await _shot_run_hero()
	await _shot_cabin_hero()
	await _shot_map_routes()

	await _shot_rope("18_rope_exit_belly1.png", 1, "sign visible, nothing else open")
	await _shot_rope_peek("19_rope_exit_sack_peek.png")
	await _shot_caught("20_caught_sheet.png")
	_skip("21a_win_homecoming_dump.png", "Live homecoming still uses hero_drop_sack then the chair. Items do not pop out of the sack.")
	_skip("21b_win_homecoming_fly.png", "NEW items do not fly to the cabinet yet. Only a scale burst on a rebuilt mount exists.")
	await _shot_loss("22_loss_homecoming.png")
	await _shot_intro()
	await _shot_combat_tooltips()
	await _shot_item_hand()
	await _shot_keyring("14_keyring_midbeat.png")
	await _shot_rope("24_rope_exit_belly3.png", 3, "later belly headline")
	await _shot_text_screens()

	_restore_all()
	if main._copy_stamp:
		main._copy_stamp.visible = _stamp_was
	running = false
	finished = true
	status = "done"


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
	if main.rope_exit == null or main.sack_peek == null:
		_skip(filename, "rope_exit or sack_peek missing")
		return
	main.rope_exit.z_index = 200
	main.rope_exit.open_exit(1)
	await _wait(0.4)
	main.rope_exit.modulate.a = 1.0
	main._open_sack_peek()
	main.sack_peek.z_index = 210
	await _wait(0.45)
	if not main.sack_peek.visible:
		_skip(filename, "sack peek did not open")
		return
	await _capture(filename, "same rest/rope_exit as Belly 1, HUD stowed, then sack_peek.open_peek() with 5 new ids")
	main.rope_exit.z_index = 80
	main.sack_peek.z_index = 81
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


func _run_text_targets() -> void:
	out_dir = TEXT_OUT_DIR
	var abs_dir: String = ProjectSettings.globalize_path(out_dir)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	_log_progress("text-targets start")
	get_tree().paused = false
	_snapshot_save()
	if main._copy_stamp:
		_stamp_was = main._copy_stamp.visible
		main._copy_stamp.visible = false
	if main.text_audit:
		main.text_audit.set_on(true)
	await _shot_intro()
	await _shot_combat_tooltips()
	await _shot_item_hand()
	_restore_all()
	if main._copy_stamp:
		main._copy_stamp.visible = _stamp_was
	if main.text_audit:
		main.text_audit.set_on(false)
		var pack := {
			"updated": Time.get_datetime_string_from_system(),
			"failures": audit_fails,
		}
		var raw: String = JSON.stringify(pack, "\t")
		var f := FileAccess.open("user://text_audit.json", FileAccess.WRITE)
		if f:
			f.store_string(raw)
		var g := FileAccess.open(out_dir.path_join("text_audit.json"), FileAccess.WRITE)
		if g:
			g.store_string(raw)
	running = false
	finished = true
	status = "done"
	if OS.get_cmdline_user_args().has("--text-targets"):
		get_tree().quit()


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
		cabin.say_bubble("cabin.locked")
		await _wait(0.2)
		await _capture("text_cabin_bubble.png", "locked bubble")
	if main.settings_ui:
		main.settings_ui.open_menu(false)
		await _wait(0.2)
		await _capture("text_pause.png", "pause settings")
		if main.settings_ui.has_method("close_menu"):
			main.settings_ui.close_menu()
	if cabin.has_method("_open_map"):
		cabin._open_map()
		await _wait(0.25)
		await _capture("text_map.png", "map overlay")
		if cabin._map:
			cabin._map.close()
	if cabin.has_method("_open_journal"):
		cabin._open_journal()
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
		var pack := {
			"updated": Time.get_datetime_string_from_system(),
			"failures": audit_fails,
		}
		var raw: String = JSON.stringify(pack, "\t")
		var f := FileAccess.open("user://text_audit.json", FileAccess.WRITE)
		if f:
			f.store_string(raw)
		var g := FileAccess.open(OUT_DIR.path_join("text_audit.json"), FileAccess.WRITE)
		if g:
			g.store_string(raw)


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
