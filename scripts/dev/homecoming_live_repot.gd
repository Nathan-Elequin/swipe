extends SceneTree
## Windowed live check for REQ-20261107-cabinet-homecoming-restore.
## Refuses to run unless user:// is under a homecoming-live-sandbox profile.
## Does not read or write Nathan's Spinheritance save directory.

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_DIR := "res://playtest/repot/outbox/REQ-20261107-cabinet-homecoming-restore"
const SHOT_DIR := OUT_DIR + "/shots"

var main: Node = null
var log_lines: PackedStringArray = PackedStringArray()
var heard: PackedStringArray = PackedStringArray()
var auto_advance: bool = true
var advance_hold: int = 0
var stage_done: bool = true
var stage_gen: int = 0
var flight_dir: String = ""
var flight_i: int = 0
var flight_tick: int = 0
var recorder: AudioEffectRecord = null
var cue_before: Dictionary = {}
var peak_max: float = -80.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	print("USER_DATA=", ud)
	if ud.find("homecoming-live-sandbox") < 0:
		print("REFUSED_UNSAFE_DIRECT_USERDATA")
		quit(2)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	Engine.max_fps = 60
	DisplayServer.window_set_title("Homecoming live repot (sandbox)")
	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		_fail_all("change_scene %s" % err)
		return
	for _i in 600:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and main.get("home_cabin") != null and main.home_cabin != null:
			break
	if main == null or main.home_cabin == null:
		_fail_all("main/home_cabin missing")
		return
	get_root().size = Vector2i(1680, 1040)
	if main.get_tree():
		main.get_tree().paused = false
	var cabin = main.home_cabin
	if main.items_by_id.is_empty():
		for _j in 300:
			await process_frame
			if not main.items_by_id.is_empty():
				break
	cabin.items_by_id = main.items_by_id
	cabin.tex_by_item = main.tex_by_item
	_log("ITEMS %s" % cabin.items_by_id.size())
	_wipe_bank(cabin)
	cabin.lesson_new_mark_said = false
	cabin.lesson_extract_haul_said = false
	cabin.lesson_five_finds_said = false
	cabin.lesson_five_threshold_said = false
	cabin.lesson_tutorial_return_said = false
	cabin.nib_first_done = true
	cabin.intro_seen = true
	cabin.tutorial_done = true
	cabin.tutorial_declined = false
	cabin.key_ring_seen = true
	cabin._grant_all_rooms()
	_close_playtest_intro()
	_arm_recorder()
	var pools: Dictionary = _pools(cabin)
	_log("POOLS %s" % str(pools.keys()))
	var b1: Array = pools.get("b1", [])
	var other_pool := ""
	var other: Array = []
	for key in pools.keys():
		if str(key) == "b1":
			continue
		if (pools[key] as Array).size() >= 5:
			other_pool = str(key)
			other = pools[key]
			break
	if b1.size() < 6 or other.size() < 5:
		_fail_all("need 6 b1 and 5 other-pool items, got b1=%s other=%s" % [b1.size(), other.size()])
		return
	_log("USING b1=%s other=%s:%s" % [b1.slice(0, 6), other_pool, other.slice(0, 5)])
	await _h1(cabin, str(b1[0]))
	await _h2(cabin, str(b1[1]))
	await _h5b(cabin, str(other[0]), other_pool)
	await _h3(cabin, str(b1[0]))
	await _h6(cabin, str(b1[0]))
	await _h11(cabin, "dialog", str(b1[1]), "")
	await _h11(cabin, "flight", str(b1[2]), "")
	await _h11(cabin, "count", str(b1[3]), "")
	await _h11_cabinet(cabin, other, other_pool)
	await _h5(cabin, b1)
	await _h7(cabin)
	await _h8(cabin)
	await _h9(cabin, str(b1[4]), str(b1[5]))
	await _h10(cabin, str(b1[0]))
	await _h12(cabin, str(b1[0]))
	_write_log()
	print("LIVE_REPOT_DONE")
	quit(0)


func _h1(cabin, id: String) -> void:
	await _banner("H1")
	cabin.visible = false
	main.in_tutorial = false
	main.adventure = true
	main._campaign_on = true
	main.phase = "ready"
	if main.get("play_field"):
		main.play_field.visible = true
	main.hotbar = [main._make_item(id)]
	main._hotbar_sig = ""
	cabin.swiped.erase(id)
	cabin.lesson_new_mark_said = false
	main._lesson_new_mark_queued = false
	if main.has_method("_sync_hotbar"):
		main._sync_hotbar()
	var seen_line := await _wait_heard("See that 'New!' mark?", 8.0)
	await _shot("H1-new-mark.png")
	auto_advance = true
	await _wait_closed(4.0)
	var badge := _hotbar_has_new()
	_verdict("H1", seen_line and badge and cabin.lesson_new_mark_said, "line=%s badge=%s lesson=%s" % [seen_line, badge, cabin.lesson_new_mark_said])


func _h2(cabin, id: String) -> void:
	await _banner("H2")
	auto_advance = false
	cabin.visible = false
	main.in_tutorial = false
	main.adventure = true
	main._campaign_on = true
	main.phase = "rest"
	if main.get("play_field"):
		main.play_field.visible = true
	main.hotbar = [main._make_item(id)]
	main._hotbar_sig = ""
	cabin.swiped.erase(id)
	cabin.lesson_extract_haul_said = false
	main._lesson_extract_queued = false
	var run = main.get("_run_lesson_dialog")
	if run != null and run.has_method("dismiss"):
		run.dismiss()
		run.visible = false
	var exit = main.get("rope_exit")
	if exit != null:
		exit.visible = true
	if main._campaign != null:
		main._maybe_queue_extract_haul_lesson({})
	else:
		_log("H2 campaign missing")
	var seen := await _wait_flag(func() -> bool:
		if exit == null:
			return false
		var rope = exit.get("_dialog")
		if rope == null or not rope.has_method("is_open") or not rope.is_open():
			return false
		var lab = rope.get("_text")
		return lab != null and str(lab.text).find("These are the new finds you can bring home.") >= 0
	, 8.0)
	await _frames(320)
	if exit != null:
		var rope_now = exit.get("_dialog")
		var lab_now = rope_now.get("_text") if rope_now != null else null
		_log("H2 visible=%s" % (str(lab_now.text) if lab_now != null else ""))
	await _shot("H2-extract-haul.png")
	auto_advance = true
	await _wait_closed(3.0)
	if exit != null:
		exit.visible = false
	_verdict("H2", seen and cabin.lesson_extract_haul_said, "line=%s lesson=%s campaign=%s" % [seen, cabin.lesson_extract_haul_said, main._campaign != null])


func _h5b(cabin, id: String, pool: String) -> void:
	await _banner("H5b")
	_wipe_bank(cabin)
	cabin.swiped = {}
	cabin.lesson_five_finds_said = false
	cabin.lesson_extract_haul_said = false
	cabin.lesson_five_threshold_said = false
	heard = PackedStringArray()
	await _show_main(cabin)
	cabin.swipe_ids([id])
	_start_stage(cabin)
	var finished: bool = await _wait_stage(cabin, 18.0)
	await _shot("H5b-non-verdant-haul.png")
	var bad := _heard_has("Five different finds")
	var mounted: bool = cabin.bank_pending.is_empty() and _banked_has(cabin, id)
	_verdict("H5b", finished and mounted and not bad and pool != "b1", "pool=%s pending=%s banked=%s verdant_line=%s" % [pool, cabin.bank_pending, _banked_has(cabin, id), bad])


func _h3(cabin, id: String) -> void:
	await _banner("H3")
	_wipe_bank(cabin)
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = true
	heard = PackedStringArray()
	cue_before = _cue_snapshot()
	peak_max = -80.0
	flight_dir = ProjectSettings.globalize_path(SHOT_DIR + "/H3-flight")
	DirAccess.make_dir_recursive_absolute(flight_dir)
	flight_i = 0
	flight_tick = 0
	if recorder:
		recorder.set_recording_active(true)
	await _show_main(cabin)
	cabin.swipe_ids([id])
	_start_stage(cabin)
	var give := await _wait_heard("Let's give these a home.", 8.0)
	await _shot("H3-give-home.png")
	var finished: bool = await _wait_stage(cabin, 25.0)
	await _shot("H3-after-mount.png")
	if recorder:
		recorder.set_recording_active(false)
		var stream: AudioStreamWAV = recorder.get_recording()
		if stream != null:
			var wav_path := ProjectSettings.globalize_path(OUT_DIR + "/H3-sfx.wav")
			var save_err: Error = stream.save_to_wav(wav_path)
			_log("H3 wav err=%s path=%s" % [save_err, wav_path])
	var whoosh := _cue_fired("cabin.item_whoosh")
	var pop := _cue_fired("cabin.item_pop")
	var chime := _cue_fired("cabin.shelf_chime")
	_log("H3 cues whoosh=%s pop=%s chime=%s peak_db=%s frames=%s" % [whoosh, pop, chime, peak_max, flight_i])
	var buses_on := _buses_audible()
	flight_dir = ""
	_log("H3 cue_delta=%s" % _cues_delta())
	_verdict("H3", finished and give and cabin.bank_pending.is_empty(), "give=%s pending=%s" % [give, cabin.bank_pending])
	_verdict("H4", whoosh and pop and chime and buses_on and peak_max > -50.0, "whoosh=%s pop=%s chime=%s buses=%s peak=%s" % [whoosh, pop, chime, buses_on, peak_max])


func _h6(cabin, id: String) -> void:
	await _banner("H6")
	heard = PackedStringArray()
	var before: int = cabin.bank_pending.size()
	var news: Array = cabin.swipe_ids([id])
	await _frames(45)
	var flew: bool = _heard_has("Let's give these a home.") or cabin._bank_busy
	_verdict("H6", news.is_empty() and before == 0 and cabin.bank_pending.is_empty() and not flew, "news=%s pending=%s busy=%s" % [news, cabin.bank_pending, cabin._bank_busy])


func _h11(cabin, phase: String, id: String, _pool: String) -> void:
	await _banner("H11-" + phase)
	_wipe_bank(cabin)
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = true
	heard = PackedStringArray()
	await _show_main(cabin)
	cabin.swipe_ids([id])
	var credited_before := _banked_has(cabin, id)
	_start_stage(cabin)
	var reached := false
	if phase == "dialog":
		reached = await _wait_heard("Let's give these a home.", 8.0)
		await _shot("H11-dialog.png")
		_send_cancel(cabin)
		_log("H11 dialog after Escape busy=%s text_open=%s" % [cabin._bank_busy, _dialog_open(cabin)])
	elif phase == "flight":
		reached = await _wait_heard("Let's give these a home.", 8.0)
		auto_advance = true
		reached = await _wait_flag(func() -> bool: return not _dialog_open(cabin) and cabin._bank_busy, 6.0)
		await _frames(8)
		await _shot("H11-flight.png")
		_send_cancel(cabin)
		_log("H11 flight after Escape busy=%s fx=%s" % [cabin._bank_busy, _fx_alive(cabin)])
	else:
		reached = await _wait_heard("Let's give these a home.", 8.0)
		auto_advance = true
		reached = await _wait_flag(func() -> bool: return _plus_label(cabin) != "", 12.0)
		await _shot("H11-count.png")
		_log("H11 count label=%s" % _plus_label(cabin))
		_send_cancel(cabin)
	var pending_at_cancel: Array = cabin.bank_pending.duplicate()
	var banked_at_cancel := _banked_has(cabin, id)
	cabin.hide_for_run()
	_dismiss(cabin)
	await _frames(20)
	var fx_after: int = _fx_alive(cabin)
	var pending_later: Array = cabin.bank_pending.duplicate()
	var late: bool = str(pending_later) != str(pending_at_cancel) or _banked_has(cabin, id) != banked_at_cancel
	await _frames(20)
	late = late or str(cabin.bank_pending) != str(pending_at_cancel)
	_log("H11 %s pending_at=%s pending_later=%s fx=%s late=%s" % [phase, pending_at_cancel, cabin.bank_pending, fx_after, late])
	await _show_hall(cabin)
	if not cabin.bank_pending.is_empty():
		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
	var busy_after: bool = cabin._busy()
	var pan_ok: bool = await _pan_main(cabin)
	var once: bool = credited_before and _banked_has(cabin, id) and cabin.bank_pending.is_empty()
	_verdict("H11-" + phase, reached and fx_after == 0 and not late and not busy_after and pan_ok and once, "reached=%s fx=%s late=%s busy=%s pan=%s pending=%s" % [reached, fx_after, late, busy_after, pan_ok, cabin.bank_pending])


func _h11_cabinet(cabin, ids: Array, pool: String) -> void:
	await _banner("H11-cabinet")
	_wipe_bank(cabin)
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = true
	_prebank(cabin, [ids[0], ids[1], ids[2], ids[3]])
	await _show_main(cabin)
	cabin.swipe_ids([ids[4]])
	_start_stage(cabin)
	var reached: bool = await _wait_flag(func() -> bool: return _lamp_on(cabin, pool), 25.0)
	var on_hall: bool = str(cabin._current_room) == "hall"
	if not on_hall:
		on_hall = await _wait_flag(func() -> bool: return str(cabin._current_room) == "hall", 8.0)
	_log("H11 cabinet room=%s on_hall=%s lamp=%s" % [cabin._current_room, on_hall, reached])
	await _frames(30)
	await _shot("H11-cabinet-open.png")
	var pieces_before: int = _map_pieces(cabin)
	_send_cancel(cabin)
	cabin.hide_for_run()
	_dismiss(cabin)
	await _frames(25)
	var fx_after: int = _fx_alive(cabin)
	var pieces_mid: int = _map_pieces(cabin)
	await _show_hall(cabin)
	if not cabin.bank_pending.is_empty():
		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
	var dup: bool = false
	var banked: Dictionary = cabin._campaign_shell.state.get("banked", {})
	for raw in [ids[0], ids[1], ids[2], ids[3], ids[4]]:
		if not banked.has(str(raw)):
			dup = true
	_verdict("H11-cabinet", reached and fx_after == 0 and pieces_mid == pieces_before and not cabin._busy() and not dup, "lamp=%s fx=%s pieces=%s->%s pending=%s" % [reached, fx_after, pieces_before, pieces_mid, cabin.bank_pending])


func _h5(cabin, b1: Array) -> void:
	await _banner("H5")
	_wipe_bank(cabin)
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = false
	_prebank(cabin, [b1[0], b1[1], b1[2], b1[3]])
	heard = PackedStringArray()
	await _show_main(cabin)
	var before: int = cabin._shown_count("b1")
	cabin.swipe_ids([b1[4]])
	_start_stage(cabin)
	var line: bool = await _wait_heard("Five different finds! There's a way beyond", 25.0)
	await _shot("H5-five-find-unlock.png")
	var finished: bool = await _wait_stage(cabin, 25.0)
	var after: int = cabin._shown_count("b1")
	_verdict("H5", line and finished and before == 4 and after >= 5, "before=%s after=%s line=%s pieces=%s" % [before, after, line, _map_pieces(cabin)])


func _h7(cabin) -> void:
	await _banner("H7")
	var pending_before: Array = cabin.bank_pending.duplicate()
	var banked_before: int = (cabin._campaign_shell.state.get("banked", {}) as Dictionary).size()
	heard = PackedStringArray()
	cabin.play_homecoming("loss", [], [])
	cabin._arrive_skip = 2
	var settled := false
	for _i in 700:
		await process_frame
		_pump()
		if cabin._beat == "idle" and not cabin._arriving:
			settled = true
			break
	await _shot("H7-loss.png")
	var grew: bool = cabin.bank_pending.size() != pending_before.size() or (cabin._campaign_shell.state.get("banked", {}) as Dictionary).size() != banked_before
	_verdict("H7", settled and not grew and not cabin._bank_busy and not _heard_has("Let's give these a home."), "settled=%s pending=%s busy=%s" % [settled, cabin.bank_pending, cabin._bank_busy])


func _h8(cabin) -> void:
	await _banner("H8")
	_wipe_bank(cabin)
	cabin.lesson_tutorial_return_said = false
	cabin.tutorial_done = true
	cabin.tutorial_declined = false
	cabin.key_ring_seen = true
	cabin.nib_first_done = true
	heard = PackedStringArray()
	var banked_before: int = (cabin._campaign_shell.state.get("banked", {}) as Dictionary).size()
	cabin.play_homecoming("win", [], [])
	cabin._arrive_skip = 2
	var line: bool = await _wait_heard("Back in one piece.", 15.0)
	await _shot("H8-tutorial-return.png")
	await _wait_closed(4.0)
	var banked_after: int = (cabin._campaign_shell.state.get("banked", {}) as Dictionary).size()
	_verdict("H8", line and banked_after == banked_before and cabin.bank_pending.is_empty() and cabin.lesson_tutorial_return_said, "line=%s banked %s->%s pending=%s" % [line, banked_before, banked_after, cabin.bank_pending])


func _h9(cabin, done_id: String, stay_id: String) -> void:
	await _banner("H9")
	_wipe_bank(cabin)
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = true
	await _show_main(cabin)
	cabin.swipe_ids([done_id])
	_start_stage(cabin)
	await _wait_stage(cabin, 20.0)
	cabin.swipe_ids([stay_id])
	_start_stage(cabin)
	var saw: bool = await _wait_heard("Let's give these a home.", 8.0)
	cabin.hide_for_run()
	_dismiss(cabin)
	await _frames(10)
	cabin._save()
	var path: String = str(cabin._effective_save_path())
	var disk_pending := _pending_on_disk(path)
	cabin.bank_pending = []
	cabin.swiped = {}
	cabin._load_save()
	var resumed: bool = cabin.bank_pending.has(stay_id) and not cabin.bank_pending.has(done_id)
	var banked_once: bool = _banked_has(cabin, done_id)
	await _show_hall(cabin)
	if not cabin.bank_pending.is_empty():
		heard = PackedStringArray()
		await _wait_flag(func() -> bool: return cabin.bank_pending.is_empty() and not cabin._bank_busy, 18.0)
	var replay: bool = cabin.bank_pending.has(done_id)
	await _shot("H9-reload-resume.png")
	_verdict("H9", saw and resumed and banked_once and not replay and disk_pending.has(stay_id), "disk=%s memory=%s replay=%s" % [disk_pending, cabin.bank_pending, replay])


func _h10(cabin, id: String) -> void:
	await _banner("H10")
	_wipe_bank(cabin)
	cabin.lesson_five_threshold_said = false
	heard = PackedStringArray()
	cabin.begin_push_block_bank()
	await _show_hall(cabin)
	cabin.swipe_ids([id])
	var pieces_before: int = _map_pieces(cabin)
	cabin.open_hall_after_push_block("b1", "Verdant Hollow", [id], [])
	await _wait_flag(func() -> bool: return _dialog_open(cabin) or cabin.bank_pending.is_empty(), 8.0)
	await _shot("H10-push-block.png")
	auto_advance = true
	await _wait_flag(func() -> bool: return not cabin._bank_busy and cabin.bank_pending.is_empty(), 12.0)
	var give := _heard_has("Let's give these a home.")
	var thresh := _heard_has("Five different finds!")
	_verdict("H10", _banked_has(cabin, id) and not give and not thresh and _map_pieces(cabin) == pieces_before, "give=%s thresh=%s pieces=%s pending=%s" % [give, thresh, _map_pieces(cabin), cabin.bank_pending])
	cabin._bank_from_push_block = false


func _h12(cabin, id: String) -> void:
	await _banner("H12")
	cabin.lesson_new_mark_said = true
	cabin.lesson_extract_haul_said = true
	cabin.lesson_five_finds_said = true
	cabin.lesson_five_threshold_said = true
	cabin.lesson_tutorial_return_said = true
	heard = PackedStringArray()
	main.phase = "ready"
	main._lesson_new_mark_queued = false
	main._lesson_extract_queued = false
	if main.has_method("_maybe_queue_new_mark_lesson"):
		main._maybe_queue_new_mark_lesson()
	await _frames(30)
	var repeat_new := _heard_has("See that 'New!' mark?")
	await _show_main(cabin)
	cabin.swipe_ids([id])
	await _frames(40)
	var repeat_give := _heard_has("Let's give these a home.")
	var repeat_five := _heard_has("Five different finds")
	await _shot("H12-no-repeat.png")
	_verdict("H12", not repeat_new and not repeat_give and not repeat_five, "new=%s give=%s five=%s heard=%s" % [repeat_new, repeat_give, repeat_five, heard])


func _start_stage(cabin) -> void:
	stage_gen += 1
	var mine: int = stage_gen
	stage_done = false
	auto_advance = true
	_stage_async(cabin, mine)


func _stage_async(cabin, mine: int) -> void:
	await cabin.stage_homecoming_bank()
	if mine == stage_gen:
		stage_done = true


func _wait_stage(cabin, seconds: float) -> bool:
	var ok: bool = await _wait_flag(func() -> bool:
		return stage_done and cabin.bank_pending.is_empty() and not cabin._bank_busy and not cabin._homecoming_bank_staging
	, seconds)
	if not ok:
		_log("STAGE TIMEOUT pending=%s busy=%s staging=%s room=%s done=%s" % [cabin.bank_pending, cabin._bank_busy, cabin._homecoming_bank_staging, cabin._current_room, stage_done])
	return ok


func _wait_heard(fragment: String, seconds: float) -> bool:
	return await _wait_flag(func() -> bool: return _heard_has(fragment), seconds)


func _wait_closed(seconds: float) -> bool:
	return await _wait_flag(func() -> bool: return not _any_dialog(), seconds)


func _wait_flag(pred: Callable, seconds: float) -> bool:
	var t0: int = Time.get_ticks_msec()
	var limit: int = int(seconds * 1000.0)
	while Time.get_ticks_msec() - t0 < limit:
		await process_frame
		_pump()
		if pred.call():
			return true
	return false


func _frames(n: int) -> void:
	for _i in n:
		await process_frame
		_pump()


func _pump() -> void:
	_note_dialog(main.home_cabin._dialog, "cabin")
	if main.get("_run_lesson_dialog") != null:
		_note_dialog(main._run_lesson_dialog, "run")
	if main.rope_exit != null:
		_note_dialog(main.rope_exit.get("_dialog"), "rope")
	if auto_advance:
		advance_hold += 1
		if advance_hold >= 18:
			_advance_open()
			advance_hold = 0
	if flight_dir != "" and not stage_done:
		flight_tick += 1
		if flight_tick % 4 == 0 and flight_i < 24:
			flight_i += 1
			_save_view(flight_dir + "/frame-%02d.png" % flight_i)
		var idx: int = AudioServer.get_bus_index("SFX")
		if idx >= 0:
			peak_max = maxf(peak_max, AudioServer.get_bus_peak_volume_left_db(idx, 0))


func _advance_open() -> void:
	for d in _dialogs():
		if d != null and d.has_method("is_open") and d.is_open() and d.has_method("advance"):
			d.advance()
			if d.has_method("is_open") and d.is_open():
				d.advance()


func _dialogs() -> Array:
	var out: Array = [main.home_cabin._dialog]
	if main.get("_run_lesson_dialog") != null:
		out.append(main._run_lesson_dialog)
	if main.rope_exit != null:
		out.append(main.rope_exit.get("_dialog"))
	return out


func _note_dialog(d, source: String) -> void:
	if d == null or not d.has_method("is_open") or not d.is_open():
		return
	var lab = d.get("_text")
	if lab == null:
		return
	var text := str(lab.text).strip_edges()
	if text == "":
		return
	var row := "%s: %s" % [source, text]
	if heard.is_empty() or heard[heard.size() - 1] != row:
		heard.append(row)
		_log("HEARD " + row)


func _heard_has(fragment: String) -> bool:
	for row in heard:
		if str(row).find(fragment) >= 0:
			return true
	return false


func _dialog_open(cabin) -> bool:
	return cabin._dialog != null and cabin._dialog.is_open()


func _any_dialog() -> bool:
	for d in _dialogs():
		if d != null and d.has_method("is_open") and d.is_open():
			return true
	return false


func _dismiss(cabin) -> void:
	if cabin._dialog != null and cabin._dialog.has_method("dismiss"):
		cabin._dialog.dismiss()
	for d in _dialogs():
		if d != null and d.has_method("dismiss"):
			d.dismiss()


func _send_cancel(cabin) -> void:
	var ev := InputEventAction.new()
	ev.action = "ui_cancel"
	ev.pressed = true
	cabin._input(ev)


func _show_main(cabin) -> void:
	cabin.visible = true
	cabin._bank_from_push_block = false
	cabin._arriving = false
	if cabin.has_method("stop_story"):
		cabin.stop_story()
	await cabin.show_menu("main")
	await _frames(5)


func _show_hall(cabin) -> void:
	cabin.visible = true
	cabin._arriving = false
	if cabin.has_method("stop_story"):
		cabin.stop_story()
	await cabin.show_menu("hall")
	await _frames(5)


func _pan_main(cabin) -> bool:
	if cabin._busy():
		_dismiss(cabin)
		await _frames(5)
	cabin.pan_to("main")
	return await _wait_flag(func() -> bool: return str(cabin._current_room) == "main" and not cabin._pan_busy, 6.0)


func _wipe_bank(cabin) -> void:
	cabin.swiped = {}
	cabin.seen = {}
	cabin.bank_pending = []
	cabin._bank_hold = {}
	cabin._bank_busy = false
	cabin._homecoming_bank_staging = false
	cabin._bank_from_push_block = false
	cabin._invalidate_bank_ceremony()
	if cabin._campaign_shell != null:
		cabin._campaign_shell.state["banked"] = {}
		cabin._campaign_shell.state["map_pieces"] = []


func _prebank(cabin, ids: Array) -> void:
	for raw in ids:
		var id := str(raw)
		cabin.swiped[id] = true
		cabin.seen[id] = true
	cabin.bank_pending = []
	cabin._bank_hold = {}
	cabin.mirror_swiped_into_banked()
	cabin.bank_pending = []
	cabin._bank_hold = {}


func _pools(cabin) -> Dictionary:
	var grouped := {}
	for raw in cabin.items_by_id.keys():
		var id := str(raw)
		var pool := str(cabin._live_pool(cabin.items_by_id[id]))
		if pool == "":
			continue
		if not grouped.has(pool):
			grouped[pool] = []
		(grouped[pool] as Array).append(id)
	for key in grouped.keys():
		(grouped[key] as Array).sort()
	return grouped


func _banked_has(cabin, id: String) -> bool:
	if cabin._campaign_shell == null:
		return false
	var banked: Dictionary = cabin._campaign_shell.state.get("banked", {})
	return banked.has(id)


func _map_pieces(cabin) -> int:
	if cabin._campaign_shell == null:
		return -1
	return (cabin._campaign_shell.state.get("map_pieces", []) as Array).size()


func _hotbar_has_new() -> bool:
	var box = main.get("hotbar_box")
	if box == null:
		return false
	return _tree_has_text(box, "New!")


func _tree_has_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text and (node as CanvasItem).visible:
		return true
	for child in node.get_children():
		if _tree_has_text(child, text):
			return true
	return false


func _plus_label(cabin) -> String:
	return _find_plus(cabin)


func _find_plus(node: Node) -> String:
	if node is Label and str((node as Label).text).begins_with("+") and (node as CanvasItem).visible:
		return str((node as Label).text)
	for child in node.get_children():
		var found := _find_plus(child)
		if found != "":
			return found
	return ""


func _lamp_on(cabin, pool: String) -> bool:
	var tc = cabin._trophy_cases.get(pool, null)
	if tc == null:
		return false
	var lamp = tc.get("_lamp")
	return lamp != null and lamp.visible


func _fx_alive(cabin) -> int:
	var n := 0
	for raw in cabin._bank_ceremony_fx_nodes:
		if is_instance_valid(raw):
			n += 1
	return n


func _pending_on_disk(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var pending: Variant = (parsed as Dictionary).get("bank_pending", [])
	return pending if typeof(pending) == TYPE_ARRAY else []


func _arm_recorder() -> void:
	var idx: int = AudioServer.get_bus_index("SFX")
	if idx < 0:
		_log("H4 no SFX bus")
		return
	recorder = AudioEffectRecord.new()
	AudioServer.add_bus_effect(idx, recorder)
	recorder.set_recording_active(false)


func _cue_snapshot() -> Dictionary:
	var sfx = main.home_cabin.sfx
	if sfx == null:
		return {}
	return (sfx._last_fired_ms as Dictionary).duplicate(true)


func _cues_delta() -> String:
	var sfx = main.home_cabin.sfx
	if sfx == null:
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in sfx._last_fired_ms.keys():
		if int(sfx._last_fired_ms[key]) > int(cue_before.get(key, 0)):
			parts.append(str(key))
	return ", ".join(parts)


func _cue_fired(id: String) -> bool:
	var sfx = main.home_cabin.sfx
	if sfx == null:
		return false
	return int(sfx._last_fired_ms.get(id, 0)) > int(cue_before.get(id, 0))


func _buses_audible() -> bool:
	var sfx_i: int = AudioServer.get_bus_index("SFX")
	var mus_i: int = AudioServer.get_bus_index("Music")
	if sfx_i < 0 or mus_i < 0:
		return false
	return not AudioServer.is_bus_mute(sfx_i) and not AudioServer.is_bus_mute(mus_i) and AudioServer.get_bus_volume_db(sfx_i) > -40.0


func _close_playtest_intro() -> void:
	var intro = main.get("playtest_intro")
	if intro != null:
		if intro.has_method("close_intro"):
			intro.close_intro()
		intro.visible = false


func _shot(filename: String) -> void:
	_close_playtest_intro()
	await process_frame
	await process_frame
	var path := ProjectSettings.globalize_path(SHOT_DIR + "/" + filename)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var img: Image = root.get_viewport().get_texture().get_image()
	var err: Error = img.save_png(path)
	_log("SHOT %s %sx%s err=%s" % [filename, img.get_width(), img.get_height(), err])


func _save_view(abs_path: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	img.save_png(abs_path)


func _banner(id: String) -> void:
	print("BEGIN " + id)
	_log("BEGIN " + id)
	auto_advance = true
	advance_hold = 0
	if not stage_done:
		await _wait_stage(main.home_cabin, 30.0)
	if main != null and main.home_cabin != null:
		var cabin = main.home_cabin
		if cabin._bank_busy or _any_dialog():
			_dismiss(cabin)
			cabin.hide_for_run()
			cabin._invalidate_bank_ceremony()
			await _frames(8)


func _verdict(id: String, ok: bool, detail: String) -> void:
	var row := "%s %s | %s" % ["PASS" if ok else "FAIL", id, detail]
	print(row)
	_log(row)


func _log(line: String) -> void:
	log_lines.append(line)
	print(line)


func _fail_all(why: String) -> void:
	_log("FAIL BOOT | " + why)
	_write_log()
	print("LIVE_REPOT_FAIL")
	quit(1)


func _write_log() -> void:
	var path := ProjectSettings.globalize_path(OUT_DIR + "/live-repot.log")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		print("LOG_WRITE_FAIL ", path)
		return
	f.store_string("\n".join(log_lines))
	f.close()
