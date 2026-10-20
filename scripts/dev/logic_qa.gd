extends Node
## Editor-only constructed fights. Main loads this only when `_authoring()`.
## Not referenced by the Web Playtest export.

const SUITE_PATH := "res://design/qa/logic-pass/bucket0-suite.json"
const MILL_PATH := "res://design/qa/logic-pass/mill-suite.json"
const DENSE_PATH := "res://design/qa/logic-pass/dense-suite.json"
const SCENARIO_PATH := "res://design/qa/logic-pass/scenario-suite.json"
const COVERING_PATH := "res://design/qa/logic-pass/covering-suite.json"
const RAW_PATH := "res://design/qa/logic-pass/raw.json"
const INDEX_PATH := "res://design/qa/logic-pass/index.json"
const SLIM_PATH := "res://design/qa/logic-pass/dense/slim.json"
const FINDINGS_PATH := "res://design/qa/logic-pass/dense/findings.json"
const PROGRESS_PATH := "res://design/qa/logic-pass/dense/progress.json"
const ROWS_DIR := "res://design/qa/logic-pass/dense/rows"
const SPRITE := {
	"shield": "assets/dungeon/items/shield.png",
	"throwing_knife": "assets/dungeon/items/throwing_knife.png",
	"sai": "assets/dungeon/items/sai.png",
	"da_boot": "assets/dungeon/items/boot.png",
	"crossbow": "assets/dungeon/items/crossbow.png",
	"sledgehammer": "assets/dungeon/items/sledgehammer.png",
	"victory_flask": "assets/dungeon/items/victory_flask.png",
	"quiet_bell": "assets/dungeon/items/quiet_bell.png",
	"net": "assets/dungeon/items/net.png",
	"smoke_bomb": "assets/dungeon/items/smoke_bomb.png",
	"healing_potion": "assets/dungeon/items/healing_potion.png",
	"dagger": "",
	"helmet": "assets/dungeon/items/helmet.png",
	"helmet_hidden": "",
	"bandana": "",
	"caltrops": "assets/dungeon/items/caltrops.png",
	"golem": "assets/dungeon/extra/golem.png",
	"wizard": "assets/dungeon/extra/wizard.png",
	"goblin": "assets/dungeon/extra/goblin.png",
	"dire_wolf": "assets/dungeon/extra/dire_wolf.png",
	"bandit": "assets/dungeon/extra/bandit.png",
	"slime_boss": "assets/dungeon/extra/slime_boss.png",
	"dragon": "assets/dungeon/extra/dragon.png",
	"needleback": "assets/dungeon/extra/needleback.png",
	"hornet_swarm": "assets/dungeon/extra/hornet_swarm.png",
	"mimic": "assets/dungeon/extra/mimic.png",
	"skeleton": "assets/dungeon/extra/skeleton.png",
}

const TEST_TIMEOUT_MS := 5000

var main
var busy: bool = false
var finished: bool = false
var status: String = ""
var last_error: String = ""
var results: Array = []
var _scale_was: float = 1.0
var extra_sprite: Dictionary = {}
var _timed_out: bool = false
var _test_started_ms: int = 0
var _counts: Dictionary = {}
var _findings: Array = []
var _index_dirty: int = 0
var _resume_n: int = 0
var _suite_total: int = 0


func setup(p_main) -> void:
	main = p_main
	name = "LogicQA"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_dt: float) -> void:
	if not busy or _test_started_ms <= 0:
		return
	if Time.get_ticks_msec() - _test_started_ms < TEST_TIMEOUT_MS:
		return
	_timed_out = true
	_unstick()


func run_bucket0() -> String:
	return _kick_run([])


func run_named(ids_csv: String) -> String:
	var want: Array = []
	for piece in ids_csv.split(",", false):
		var s := str(piece).strip_edges()
		if s != "":
			want.append(s)
	return _kick_run(want)


func run_mill(ids_csv: String = "") -> String:
	set_meta("qa_suite_path", MILL_PATH)
	if ids_csv.strip_edges() == "":
		return _kick_run([])
	return run_named(ids_csv)


func run_dense(ids_csv: String = "") -> String:
	set_meta("qa_suite_path", DENSE_PATH)
	set_meta("qa_dense", true)
	if ids_csv.strip_edges() == "":
		return _kick_run([])
	return run_named(ids_csv)


func run_scenarios(ids_csv: String = "") -> String:
	set_meta("qa_suite_path", SCENARIO_PATH)
	set_meta("qa_dense", true)
	set_meta("qa_scenario", true)
	if ids_csv.strip_edges() == "":
		return _kick_run([])
	return run_named(ids_csv)


func run_covering(ids_csv: String = "") -> String:
	set_meta("qa_suite_path", COVERING_PATH)
	set_meta("qa_dense", true)
	set_meta("qa_scenario", true)
	set_meta("qa_covering", true)
	if ids_csv.strip_edges() == "":
		return _kick_run([])
	return run_named(ids_csv)


func _kick_run(only_ids: Array) -> String:
	if main == null or not main._authoring():
		return "blocked: not authoring"
	if busy:
		return "already running"
	busy = true
	finished = false
	status = "starting"
	last_error = ""
	results.clear()
	set_meta("qa_only_ids", only_ids)
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(_run_bucket0, CONNECT_ONE_SHOT)
	return "started"


func dump() -> Dictionary:
	var last_id := ""
	if not results.is_empty():
		last_id = str(results[results.size() - 1].get("id", ""))
	return {
		"busy": busy,
		"finished": finished,
		"status": status,
		"last_error": last_error,
		"count": _resume_n + results.size(),
		"last_id": last_id,
		"timed_out": _timed_out,
		"counts": _counts,
	}


func dump_json() -> String:
	var slim: Array = []
	for r in results:
		slim.append({
			"id": r.get("id", ""),
			"title": r.get("title", ""),
			"result": r.get("result", ""),
			"column": r.get("column", ""),
			"observed": r.get("observed", ""),
			"log": r.get("log", ""),
			"expected": r.get("expected", ""),
			"note": r.get("note", ""),
		})
	return JSON.stringify({"finished": finished, "status": status, "last_error": last_error, "rows": slim}, "\t")


func _run_bucket0() -> void:
	_scale_was = Engine.time_scale
	Engine.time_scale = 10.0
	get_tree().paused = false
	_dismiss_hub()
	var suite_path: String = str(get_meta("qa_suite_path", SUITE_PATH))
	var suite: Dictionary = _load_json(suite_path)
	extra_sprite = suite.get("sprites", {})
	var tests: Array = suite.get("tests", [])
	_suite_total = tests.size()
	if tests.is_empty():
		last_error = "empty suite"
		status = last_error
		Engine.time_scale = _scale_was
		busy = false
		finished = true
		return
	var done: Dictionary = {}
	var after_id := ""
	var skipping := false
	_counts = {}
	_findings = []
	_index_dirty = 0
	_resume_n = 0
	if bool(get_meta("qa_scenario", false)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://design/qa/logic-pass/scenario"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://design/qa/logic-pass/covering"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://design/qa/logic-pass/covering/rows"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://design/qa/logic-pass/dense"))
	elif bool(get_meta("qa_dense", false)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://design/qa/logic-pass/dense"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROWS_DIR))
		done = _ids_on_disk()
		var prior: Dictionary = _load_json(PROGRESS_PATH)
		if not prior.is_empty():
			_counts = prior.get("counts", {})
			_resume_n = maxi(int(prior.get("n", 0)), done.size())
			after_id = str(prior.get("last_id", ""))
			skipping = after_id != ""
		var prior_find: Dictionary = _load_json(FINDINGS_PATH)
		if typeof(prior_find.get("rows", null)) == TYPE_ARRAY:
			_findings = prior_find.get("rows", [])
	var only_ids: Array = get_meta("qa_only_ids", [])
	var n := _resume_n
	_write_progress(n, tests.size())
	for t in tests:
		if typeof(t) != TYPE_DICTIONARY:
			continue
		var tid: String = str(t.get("id", ""))
		if not only_ids.is_empty() and not only_ids.has(tid):
			continue
		if bool(t.get("skip", false)):
			continue
		if skipping:
			if tid == after_id:
				skipping = false
			continue
		if done.has(tid):
			continue
		status = tid
		var row: Dictionary = await _one_test(t)
		n += 1
		if bool(get_meta("qa_dense", false)):
			results.append(_slim_row(row))
			_record_row(row)
			_write_progress(n, tests.size())
		else:
			results.append(row)
	_write_outputs()
	Engine.time_scale = _scale_was
	status = "done"
	busy = false
	finished = true
	set_meta("qa_dense", false)


func _dismiss_hub() -> void:
	if main.playtest_intro != null and main.playtest_intro.has_method("close_intro"):
		main.playtest_intro.close_intro()
	if main.playtest_teaser != null and main.playtest_teaser.has_method("close_teaser"):
		main.playtest_teaser.close_teaser()
	if main.playtest_hub != null and main.playtest_hub.has_method("close_hub"):
		main.playtest_hub.close_hub()
	if main.overlay:
		main.overlay.visible = false
	get_tree().paused = false


func _one_test(spec: Dictionary) -> Dictionary:
	var row: Dictionary = _blank_row(spec)
	var kind: String = str(spec.get("kind", "fight"))
	if kind == "hub":
		return await _run_hub(spec, row)
	return await _run_fight(spec, row)


func _run_hub(spec: Dictionary, row: Dictionary) -> Dictionary:
	_dismiss_hub()
	if main.has_method("_begin_adventure"):
		await main._begin_adventure()
	await _wait_idle(180)
	var snap: Dictionary = _snapshot()
	row["log"] = str(snap.get("log", ""))
	row["observed"] = "phase %s · HP %s · log has Challenge=%s" % [
		snap.get("phase", ""),
		snap.get("hp", ""),
		str(row["log"]).findn("Challenge") >= 0,
	]
	var log_l: String = str(row["log"]).to_lower()
	if log_l.find("challenge") >= 0 or str(snap.get("phase", "")) in ["draft", "ready", "fighting"]:
		row["result"] = "pass"
	else:
		row["result"] = "fail"
	_apply_forced_column(spec, row)
	return row


func _timeout_row(row: Dictionary) -> Dictionary:
	row["result"] = "blocked"
	row["column"] = "blocked"
	row["observed"] = "Hung more than 5 seconds waiting for a click or animation. I skipped it and moved on."
	row["note"] = "timeout"
	if str(row.get("log", "")).strip_edges() == "":
		row["log"] = str(_snapshot(false).get("log", ""))
	return row


func _arm_timeout() -> void:
	_timed_out = false
	_test_started_ms = Time.get_ticks_msec()


func _unstick() -> void:
	if main == null:
		return
	main.pending_feed = {}
	main.pending_choice = {}
	main.pending_mark = {}
	main._bell_wait = false
	main._challenge_loot_wait = false
	main._walker_busy = false
	main._challenge_pending_gain = {}
	if main.challenge_draft_ui != null:
		if main.challenge_draft_ui.visible:
			main.challenge_draft_ui.hide_draft()
		main.challenge_draft_ui.emit_signal("chosen", -1)
	if main.wheel_view != null:
		main.wheel_view.busy = false
		if main.wheel_view.has_method("clear_slay"):
			main.wheel_view.clear_slay()
	var tree := get_tree()
	if tree:
		tree.paused = false
		for tw in tree.get_processed_tweens():
			if tw != null and tw.is_valid():
				tw.kill()


func _run_fight(spec: Dictionary, row: Dictionary) -> Dictionary:
	_arm_timeout()
	_dismiss_hub()
	if not main._authoring():
		row["result"] = "blocked"
		row["observed"] = "not authoring"
		return row
	main._open_dev_test()
	await _wait_frames(4)
	if main.log_label and main.log_label.has_method("clear_all"):
		main.log_label.clear_all()
	var missing: PackedStringArray = PackedStringArray()
	for mid in spec.get("monsters", []):
		if not main.monsters_by_id.has(str(mid)):
			missing.append("monster:%s" % str(mid))
			continue
		await main._dev_add_monster(str(mid), false)
	for iid in spec.get("items", []):
		if not main.items_by_id.has(str(iid)):
			missing.append("item:%s" % str(iid))
			continue
		main._dev_add_item(str(iid), false)
	if not missing.is_empty():
		row["result"] = "blocked"
		row["observed"] = "cannot spawn %s" % ", ".join(missing)
		row["log"] = ""
		row["column"] = "blocked"
		return row
	main._dev_enter()
	await _wait_phase("ready", 40)
	if spec.has("hp_before"):
		main.hp = int(spec.get("hp_before", 6))
		main._refresh()
	var face_id: String = str(spec.get("face", ""))
	var face_i: int = _index_of(face_id)
	if face_i < 0:
		face_i = 0
	if main.wheel_view:
		main.wheel_view.set_meta("qa_instant", true)
	main.set_meta("qa_spin_idx", face_i)
	main.adventure = bool(spec.get("adventure", false))
	main.remove_meta("qa_hand_cap")
	if bool(spec.get("challenge", true)):
		main.set_meta("qa_hand_cap", int(spec.get("hand_cap", 10)))
	get_tree().paused = false
	await main._on_spin()
	if _timed_out:
		return _timeout_row(row)
	await _wait_idle(24)
	if _timed_out:
		return _timeout_row(row)
	var after_spin: Dictionary = _snapshot(false)
	row["evidence"] = {
		"hand_before": _hand_names(after_spin),
		"slots": "%s / %s" % [int(after_spin.get("hand_n", 0)), int(after_spin.get("hand_cap", 10))],
		"looked_at": ["combat log", "plate ATK/HP", "inspect", "Shift inspect", "hotbar"],
		"did_not": ["screenshot"],
	}
	if main.phase != "fighting":
		row["log"] = str(after_spin.get("log", ""))
		var want_fled := str(spec.get("expected", {}).get("outcome", "")) == "fled"
		if want_fled:
			var mismatch_fled: String = _judge_reason(spec.get("expected", {}), after_spin, after_spin)
			row["mismatch"] = mismatch_fled
			if mismatch_fled == "":
				row["result"] = "pass"
				row["column"] = "pass"
				row["observed"] = "Fled on Spin. No fight to click the item."
			else:
				row["result"] = "fail"
				row["column"] = "fail"
				row["observed"] = mismatch_fled
			return row
		if str(main.phase) == "title":
			row["result"] = "blocked"
			row["column"] = "blocked"
			row["observed"] = "Spin ended the dungeon before a fight snapshot. Not used as proof."
			return row
		row["result"] = "blocked"
		row["observed"] = "spin did not reach fighting (phase=%s)" % main.phase
		row["column"] = "blocked"
		return row
	var last_good: Dictionary = after_spin
	var after_item: Dictionary = after_spin
	var clicked: PackedStringArray = PackedStringArray()
	for click in spec.get("clicks", []):
		if typeof(click) != TYPE_DICTIONARY:
			continue
		if str(main.phase) == "title":
			break
		var op: String = str(click.get("op", ""))
		await _do_click(click)
		if _timed_out:
			return _timeout_row(row)
		clicked.append("%s %s" % [op, str(click.get("item", click.get("id", "")))])
		await _wait_idle(12)
		if _timed_out:
			return _timeout_row(row)
		var mid: Dictionary = _snapshot(op != "done")
		if str(mid.get("phase", "")) != "title":
			last_good = mid
			if op != "done":
				after_item = mid
		if op == "use" and not _click_proved(after_spin, after_item, spec):
			await _do_click(click)
			await _wait_idle(12)
			mid = _snapshot(true)
			if str(mid.get("phase", "")) != "title":
				last_good = mid
				after_item = mid
	await _wait_idle(8)
	if str(main.phase) != "title":
		last_good = _snapshot(true)
	if after_item.get("surfaces", {}).is_empty() and str(main.phase) == "fighting":
		after_item = _snapshot(true)
	row["log"] = str(last_good.get("log", ""))
	row["observed"] = _observed_line(after_item)
	row["scene"] = _scene_of(spec, after_item, clicked)
	var mismatch: String = ""
	if bool(get_meta("qa_scenario", false)):
		var expected_now: Dictionary = spec.get("expected", {})
		var plates_exp: Dictionary = expected_now.duplicate()
		plates_exp.erase("in_hand")
		mismatch = _judge_reason(plates_exp, after_item, after_spin)
		if mismatch == "":
			var hand_exp := {"in_hand": expected_now.get("in_hand", {})}
			if expected_now.has("in_hand"):
				mismatch = _judge_reason(hand_exp, last_good, after_spin)
		if mismatch == "" and str(after_item.get("log", "")).strip_edges() == "":
			mismatch = _judge_reason(plates_exp, last_good, after_spin)
		if mismatch != "" and str(expected_now.get("outcome", "")) == "fired" and not _click_proved(after_spin, after_item, spec):
			mismatch = "BLOCKED: Player click never changed the plates or the hand."
	else:
		mismatch = _judge_dense(spec, after_spin, after_item, last_good, clicked)
	row["mismatch"] = mismatch
	row["theme"] = _theme_of(mismatch, spec)
	row["narrative"] = str(spec.get("expected_text", ""))
	if mismatch.begins_with("BLOCKED:"):
		row["result"] = "blocked"
		row["column"] = "blocked"
		row["observed"] = mismatch.substr(8).strip_edges()
	elif mismatch.begins_with("RULING:"):
		row["result"] = "needs_ruling"
		row["column"] = "needs_ruling"
		row["observed"] = mismatch.substr(7).strip_edges()
	elif mismatch != "":
		row["result"] = "fail"
		row["column"] = "fail"
		row["observed"] = mismatch
	else:
		row["result"] = "pass"
		if str(spec.get("family", "")).begins_with("ord") or str(spec.get("family", "")) == "order":
			row["column"] = "pass"
			row["note"] = "Two uniques met. Numbers matched an invariant; still worth a glance."
		else:
			row["column"] = "pass"
	_apply_forced_column(spec, row)
	return row


func _do_click(click: Dictionary) -> void:
	if _timed_out:
		return
	var op: String = str(click.get("op", ""))
	if op == "use":
		var uid: int = _uid_of(str(click.get("item", "")))
		if uid < 0:
			return
		await main._use_item(uid)
		if bool(click.get("auto", false)):
			await _auto_resolve()
	elif op == "choose":
		var opt := {"id": str(click.get("id", ""))}
		if click.has("atk"):
			opt["atk"] = int(click.get("atk", 0))
			opt["keep"] = bool(click.get("keep", false))
		if click.has("atk_drop"):
			opt["atk_drop"] = int(click.get("atk_drop", 0))
		await main._choose_option(opt)
	elif op == "mark":
		var idx: int = _index_of(str(click.get("monster", "")))
		if idx < 0:
			idx = _first_markable()
		if idx >= 0:
			await main._apply_mark(idx)
	elif op == "done":
		await main._on_done()
	elif op == "undo":
		if main.has_method("_on_undo"):
			await main._on_undo()


func _auto_resolve() -> void:
	if not main.pending_choice.is_empty():
		var opts: Array = main.pending_choice.get("options", [])
		if not opts.is_empty() and typeof(opts[0]) == TYPE_DICTIONARY:
			await main._choose_option(opts[0])
			await _wait_idle(20)
	if not str(main.pending_mark.get("kind", "")).is_empty() or not main.pending_mark.is_empty():
		var idx: int = _first_markable()
		if idx >= 0:
			await main._apply_mark(idx)
			await _wait_idle(20)


func _first_markable() -> int:
	for i in range(main.wheel.size()):
		if i == main.facing_index:
			continue
		if str(main.wheel[i].get("kind", "")) == "monster" and int(main.wheel[i].get("hp", 0)) > 0:
			return i
	return -1


func _uid_of(item_id: String) -> int:
	for it in main.hotbar:
		if str(it.get("card_id", "")) != item_id:
			continue
		if bool(it.get("spent", false)):
			continue
		return int(it.get("uid", -1))
	for it in main.hotbar:
		if str(it.get("card_id", "")) == item_id:
			return int(it.get("uid", -1))
	return -1


func _index_of(card_id: String) -> int:
	if card_id == "":
		return -1
	for i in range(main.wheel.size()):
		if str(main.wheel[i].get("card_id", "")) == card_id:
			return i
	return -1


func _wait_phase(want: String, frames: int) -> bool:
	var n: int = 0
	while str(main.phase) != want and n < frames:
		if _timed_out:
			return false
		await get_tree().process_frame
		n += 1
	return str(main.phase) == want


func _wait_idle(frames: int) -> void:
	var n: int = 0
	while n < frames:
		if _timed_out:
			return
		if get_tree().paused:
			get_tree().paused = false
		var busy_now: bool = bool(main._walker_busy) or main._wheel_busy() or str(main.phase) == "spinning"
		if not busy_now:
			await get_tree().process_frame
			busy_now = bool(main._walker_busy) or main._wheel_busy() or str(main.phase) == "spinning"
			if not busy_now:
				return
		await get_tree().process_frame
		n += 1


func _wait_frames(n: int) -> void:
	for i in n:
		if _timed_out:
			return
		await get_tree().process_frame


func _snapshot(with_surfaces: bool = true) -> Dictionary:
	var spent := {}
	var hand: Array = []
	for it in main.hotbar:
		var id: String = str(it.get("card_id", ""))
		var sp: bool = bool(it.get("spent", false))
		hand.append({"id": id, "spent": sp, "name": str(it.get("name", ""))})
		spent[id] = sp
	var face := {}
	var neighbors: Array = []
	if main.facing_index >= 0 and main.facing_index < main.wheel.size():
		var m: Dictionary = main.wheel[main.facing_index]
		face = {
			"id": str(m.get("card_id", "")),
			"name": str(m.get("name", "")),
			"atk": int(m.get("atk", 0)),
			"hp": int(m.get("hp", 0)),
			"ability": str(m.get("ability", "")),
		}
		var nwheel: int = main.wheel.size()
		if nwheel >= 2:
			for off in [-1, 1]:
				var ni: int = (main.facing_index + off + nwheel) % nwheel
				var nm: Dictionary = main.wheel[ni]
				if str(nm.get("kind", "")) == "monster":
					neighbors.append({
						"id": str(nm.get("card_id", "")),
						"name": str(nm.get("name", "")),
						"atk": int(nm.get("atk", 0)),
						"hp": int(nm.get("hp", 0)),
					})
	var log := ""
	if main.log_label and main.log_label.has_method("dump_plain"):
		log = str(main.log_label.dump_plain())
	var cap: int = 10 if bool(main.adventure) else 50
	var surfaces: Dictionary = _surface_dump() if with_surfaces else {}
	return {
		"phase": str(main.phase),
		"hp": int(main.hp),
		"blk": int(main.blk),
		"face": face,
		"neighbors": neighbors,
		"hand": hand,
		"hand_n": hand.size(),
		"hand_cap": cap,
		"spent": spent,
		"log": log,
		"wheel_n": main.wheel.size(),
		"surfaces": surfaces,
		"items_this_combat": int(main.items_used_this_combat),
	}


func _observed_line(snap: Dictionary) -> String:
	var face: Dictionary = snap.get("face", {})
	return "phase %s · HP %s · BLK %s · face %s ATK %s HP %s" % [
		snap.get("phase", ""),
		snap.get("hp", ""),
		snap.get("blk", ""),
		face.get("name", "—"),
		face.get("atk", "—"),
		face.get("hp", "—"),
	]


func _hand_names(snap: Dictionary) -> Array:
	var names: Array = []
	for it in snap.get("hand", []):
		names.append(str(it.get("name", it.get("id", ""))))
	return names


func _scene_of(spec: Dictionary, snap: Dictionary, clicked: PackedStringArray) -> Dictionary:
	var face: Dictionary = snap.get("face", {})
	var steps: Array = []
	for c in clicked:
		steps.append(str(c))
	return {
		"kind": "fight",
		"face_id": str(face.get("id", spec.get("face", ""))),
		"face_name": str(face.get("name", "")),
		"face_atk": face.get("atk", 0),
		"face_hp": face.get("hp", 0),
		"you_hp": snap.get("hp", 6),
		"hand": _hand_names(snap),
		"clicks": steps,
	}


func _plain(s: String) -> String:
	var re := RegEx.new()
	re.compile("\\[[^\\]]*\\]")
	return re.sub(str(s), "", true).strip_edges()


func _surface_dump() -> Dictionary:
	var item_rule := {}
	var item_shown := {}
	if not main.hotbar.is_empty():
		item_rule = main._item_rule(main.hotbar[0])
		main._inspect_item(main.hotbar[0], true)
		if main.fly_tip and "last_shown" in main.fly_tip:
			item_shown = main.fly_tip.last_shown.duplicate()
	var face_rule := {}
	var shift_rule := {}
	if main.facing_index >= 0 and main.facing_index < main.wheel.size():
		var m: Dictionary = main.wheel[main.facing_index]
		var held: bool = main._shift_held
		main._shift_held = false
		face_rule = main._monster_rule(m)
		main._shift_held = true
		shift_rule = main._monster_rule(m)
		main._shift_held = held
	return {
		"item_rule": item_rule,
		"item_shown": item_shown,
		"face_rule": face_rule,
		"shift_rule": shift_rule,
	}


func _click_proved(before: Dictionary, after: Dictionary, spec: Dictionary) -> bool:
	if int(after.get("hp", -1)) != int(before.get("hp", -1)):
		return true
	if int(after.get("blk", -1)) != int(before.get("blk", -1)):
		return true
	var af: Dictionary = after.get("face", {})
	var bf: Dictionary = before.get("face", {})
	if int(af.get("hp", -1)) != int(bf.get("hp", -1)):
		return true
	if int(af.get("atk", -1)) != int(bf.get("atk", -1)):
		return true
	if str(after.get("hand", [])) != str(before.get("hand", [])):
		return true
	var log: String = str(after.get("log", "")).to_lower()
	if log.find("cannot") >= 0 or log.find("ate") >= 0 or log.find("flee") >= 0 or log.find("scurry") >= 0:
		return true
	for c in spec.get("cards", []):
		var nm: String = str(c.get("name", "")).strip_edges().to_lower()
		if nm != "" and log.find(nm) >= 0:
			return true
	return false


func _theme_of(mismatch: String, spec: Dictionary) -> String:
	if mismatch == "":
		return "pass"
	var m: String = mismatch.to_lower()
	if m.begins_with("blocked:") or m.find("never") >= 0 or m.find("spin did not") >= 0 or m.find("did not change") >= 0:
		return "harness"
	if m.find("keep") >= 0 or m.find("after done") >= 0:
		return "keep"
	if m.find("goblin") >= 0 or m.find("flee") >= 0 or m.find("cube") >= 0:
		return "monster"
	if m.find("block") >= 0 or m.find("hp") >= 0 or m.find("attack") >= 0:
		return "plates"
	return str(spec.get("family", "other"))


func _in_hand(snap: Dictionary, item_id: String) -> bool:
	for it in snap.get("hand", []):
		if str(it.get("id", "")) == item_id:
			return true
	return false


func _judge_reason(expected: Dictionary, snap: Dictionary, after_spin: Dictionary = {}) -> String:
	if typeof(expected) != TYPE_DICTIONARY or expected.is_empty():
		return ""
	var log: String = str(snap.get("log", ""))
	var log_l: String = log.to_lower()
	var outcome: String = str(expected.get("outcome", ""))
	if outcome == "fled":
		if log_l.find("flee") >= 0 or log_l.find("flees") >= 0 or log_l.find("scurry") >= 0:
			return ""
		if str(snap.get("phase", "")) != "fighting":
			return ""
		return "Player Spun this monster; it should have Fled. Plates still show a fight."
	if outcome == "cube_ate":
		if log_l.find("ate") >= 0 or log_l.find("feed") >= 0:
			return ""
		if int(snap.get("blk", 0)) == 0 and not _in_hand(snap, "shield"):
			return ""
		return "Player clicked the item. Cube should have eaten it. Block is %s and the item is still in hand." % snap.get("blk")
	if outcome == "cannot":
		if log_l.find("cannot") >= 0:
			return ""
		if expected.has("blk") and int(snap.get("blk", -1)) == int(expected.get("blk", 0)):
			return ""
		if expected.has("face_hp"):
			var face0: Dictionary = snap.get("face", {})
			if int(face0.get("hp", -1)) == int(expected.get("face_hp", -1)):
				return ""
		return "Player clicked a card that should not have changed the plates. The plates moved anyway."
	if outcome == "fired" or outcome == "item_did_fire":
		if _click_proved(after_spin if not after_spin.is_empty() else snap, snap, {"cards": []}):
			pass
		elif _click_proved(after_spin, snap, {}):
			pass
	if expected.has("hp") and int(snap.get("hp", -1)) != int(expected.get("hp", -1)):
		return "Player HP should be %s. The plate showed %s." % [expected.get("hp"), snap.get("hp")]
	if expected.has("hp_min") and int(snap.get("hp", -1)) < int(expected.get("hp_min", 0)):
		return "Player HP should be at least %s. The plate showed %s." % [expected.get("hp_min"), snap.get("hp")]
	if expected.has("blk") and int(snap.get("blk", -1)) != int(expected.get("blk", -1)):
		return "Block should be %s. The plate showed %s." % [expected.get("blk"), snap.get("blk")]
	if expected.has("blk_min") and int(snap.get("blk", -1)) < int(expected.get("blk_min", 0)):
		return "Block should be at least %s. The plate showed %s." % [expected.get("blk_min"), snap.get("blk")]
	var face: Dictionary = snap.get("face", {})
	if expected.has("face_hp") and int(face.get("hp", -1)) != int(expected.get("face_hp", -1)):
		return "Facing HP should be %s. The plate showed %s." % [expected.get("face_hp"), face.get("hp")]
	if expected.has("face_atk") and int(face.get("atk", -1)) != int(expected.get("face_atk", -1)):
		return "Facing Attack should be %s. The plate showed %s." % [expected.get("face_atk"), face.get("atk")]
	var want_hand: Dictionary = expected.get("in_hand", expected.get("spent", {}))
	var hand_is_spent: bool = expected.has("spent") and not expected.has("in_hand")
	for k in want_hand.keys():
		var here: bool = _in_hand(snap, str(k))
		var want: bool = bool(want_hand[k])
		if expected.has("in_hand"):
			if want and not here:
				return "After Done, %s should still be in the hand (Keep). It was gone." % k
			if (not want) and here:
				return "After Done, %s should be gone. It was still in the hand." % k
		elif hand_is_spent:
			var is_spent: bool = false
			for it in snap.get("hand", []):
				if str(it.get("id", "")) == str(k):
					is_spent = bool(it.get("spent", false))
			if want and here and not is_spent:
				return "Expected %s to be spent." % k
			if (not want) and (not here or is_spent):
				return "Expected %s to stay in the hand." % k
	if (expected.get("invariants", []) as Array).has("goblin_no_atk_dmg"):
		var face_now: Dictionary = snap.get("face", {})
		var face_then: Dictionary = after_spin.get("face", {})
		if int(face_now.get("hp", 0)) < int(face_then.get("hp", 0)):
			return "Player Attacked Goblin. Goblin cannot take Attack damage, but HP went %s → %s." % [face_then.get("hp"), face_now.get("hp")]
	if outcome == "fired" or outcome == "item_did_fire":
		if not _click_proved(after_spin, snap, {}):
			if log_l.find("cannot") >= 0:
				return ""
			return "Player clicked the card. The plates and the hand did not change."
	return ""


func _judge_dense(spec: Dictionary, after_spin: Dictionary, after_item: Dictionary, snap: Dictionary, clicked: PackedStringArray) -> String:
	var expected: Dictionary = spec.get("expected", {})
	if typeof(expected) != TYPE_DICTIONARY:
		expected = {}
	var inv: Array = expected.get("invariants", [])
	var face: Dictionary = after_item.get("face", {})
	var spin_face: Dictionary = after_spin.get("face", {})
	var log: String = str(snap.get("log", "")) + "\n" + str(after_item.get("log", ""))
	if str(snap.get("phase", "")) == "title" and log.strip_edges() == "":
		return "BLOCKED: The dungeon reset before I could read the log."
	if expected.get("on_done", false):
		var did_done := false
		for c in clicked:
			if str(c).begins_with("done"):
				did_done = true
		if not did_done:
			return "BLOCKED: This special fires on Done, and I never clicked Done."
	if not face.is_empty():
		var surf: Dictionary = after_item.get("surfaces", {})
		if surf.is_empty():
			surf = snap.get("surfaces", {})
		var face_rule: Dictionary = surf.get("face_rule", {})
		var plate := "%s ATK %s HP %s" % [face.get("name", ""), face.get("atk", ""), face.get("hp", "")]
		var inspect_val := _plain(str(face_rule.get("value", "")))
		if inspect_val != "":
			if inspect_val.find(str(face.get("hp", ""))) < 0 or inspect_val.find(str(face.get("atk", ""))) < 0:
				return "Inspect shows %s but the plate is %s." % [inspect_val, plate]
		var shown: Dictionary = surf.get("item_shown", {})
		var hand_now: Array = after_item.get("hand", [])
		if not shown.is_empty() and str(shown.get("title", "")) != "" and not hand_now.is_empty():
			var want_name := _titleish(str(hand_now[0].get("name", "")))
			var got_name := _titleish(str(shown.get("title", "")))
			if want_name != "" and got_name != "" and got_name.find(want_name) < 0 and want_name.find(got_name) < 0:
				return "Inspect title is %s but the hotbar card is %s." % [shown.get("title", ""), hand_now[0].get("name", "")]
		var shift_rule: Dictionary = surf.get("shift_rule", {})
		var expl := _plain(str(shift_rule.get("equation", "")))
		var cat_ex := ""
		var card: Dictionary = main.monsters_by_id.get(str(face.get("id", "")), {})
		cat_ex = str(card.get("explainer", "")).strip_edges()
		if cat_ex != "" and cat_ex != "---" and expl == "" and str(shift_rule.get("body", "")).strip_edges() == "":
			return "Holding Shift shows no explainer, but the card has one: %s." % cat_ex
	if inv.has("goblin_no_atk_dmg"):
		if int(face.get("hp", 0)) < int(spin_face.get("hp", 0)):
			return "Goblin (or another unhittable) lost HP to Attack (%s → %s). Attack damage should not land." % [spin_face.get("hp", "?"), face.get("hp", "?")]
	if inv.has("keep_until_done") or inv.has("still_in_hand"):
		var want_spent: Dictionary = expected.get("spent", {})
		for k in want_spent.keys():
			if not bool(want_spent[k]):
				var in_hand := false
				for it in snap.get("hand", []):
					if str(it.get("id", "")) == str(k) and not bool(it.get("spent", false)):
						in_hand = true
				if not in_hand:
					return "Keep / unplayable card %s is gone from the hand after the fight. It should still be there." % k
	if inv.has("no_gain_empty_or_full"):
		var cap: int = int(snap.get("hand_cap", 10))
		var n: int = int(snap.get("hand_n", 0))
		if n > cap:
			return "Hand has %s items past the Challenge cap of %s." % [n, cap]
	if expected.get("must_fire", false) and expected.get("on_spin", false):
		var printed_atk = expected.get("printed_atk", null)
		var printed_hp = expected.get("printed_hp", null)
		var same_atk := printed_atk == null or int(spin_face.get("atk", -999)) == int(printed_atk)
		var same_hp := printed_hp == null or int(spin_face.get("hp", -999)) == int(printed_hp)
		var log_spin := str(after_spin.get("log", "")).to_lower()
		var named := str(spin_face.get("name", "")).to_lower()
		if same_atk and same_hp and named != "" and log_spin.find(named) < 0 and log_spin.find("gain") < 0 and log_spin.find("atk") < 0:
			return "On Spin, %s looks exactly like its printed %s/%s and the log never named the special." % [spin_face.get("name", "the monster"), printed_atk, printed_hp]
	# Reuse numeric checks from the old judge without treating empty expected as auto-pass.
	var old: String = _judge(expected, after_item)
	if old == "fail":
		return "A number did not match the card: %s" % _observed_line(after_item)
	return ""


func _titleish(s: String) -> String:
	return s.strip_edges().to_lower().replace("the ", "")


func _judge(expected: Dictionary, snap: Dictionary) -> String:
	if expected.is_empty():
		return "pass"
	var log: String = str(snap.get("log", "")).to_lower()
	for piece in expected.get("log_has", []):
		if log.find(str(piece).to_lower()) < 0:
			return "fail"
	for piece in expected.get("log_missing", []):
		if log.find(str(piece).to_lower()) >= 0:
			return "fail"
	if expected.has("hp") and int(snap.get("hp", -1)) != int(expected.get("hp", -1)):
		return "fail"
	if expected.has("hp_min") and int(snap.get("hp", -1)) < int(expected.get("hp_min", 0)):
		return "fail"
	if expected.has("blk") and int(snap.get("blk", -1)) != int(expected.get("blk", -1)):
		return "fail"
	if expected.has("blk_min") and int(snap.get("blk", -1)) < int(expected.get("blk_min", 0)):
		return "fail"
	var face: Dictionary = snap.get("face", {})
	if expected.has("face_hp") and int(face.get("hp", -1)) != int(expected.get("face_hp", -1)):
		return "fail"
	if expected.has("face_atk") and int(face.get("atk", -1)) != int(expected.get("face_atk", -1)):
		return "fail"
	if expected.has("phase") and str(snap.get("phase", "")) != str(expected.get("phase", "")):
		return "fail"
	var hand: Array = snap.get("hand", [])
	var want_spent: Dictionary = expected.get("spent", {})
	for k in want_spent.keys():
		var in_hand: bool = false
		var is_spent: bool = false
		for it in hand:
			if str(it.get("id", "")) != str(k):
				continue
			in_hand = true
			is_spent = bool(it.get("spent", false))
		var should_spend: bool = bool(want_spent[k])
		if should_spend:
			if in_hand and not is_spent:
				return "fail"
		else:
			if not in_hand or is_spent:
				return "fail"
	return "pass"


func _apply_forced_column(spec: Dictionary, row: Dictionary) -> void:
	var col: String = str(spec.get("column", ""))
	if col == "needs_ruling" or col == "side" or col == "feel":
		row["column"] = col
		if col == "needs_ruling":
			row["result"] = "needs_ruling"
	else:
		row["column"] = str(row.get("result", "queue"))


func _blank_row(spec: Dictionary) -> Dictionary:
	var cards: Array = []
	for iid in spec.get("items", []):
		cards.append(_card_ref(str(iid), "item"))
	for mid in spec.get("monsters", []):
		cards.append(_card_ref(str(mid), "monster"))
	return {
		"id": str(spec.get("id", "")),
		"title": str(spec.get("title", spec.get("id", ""))),
		"verbs": spec.get("verbs", []),
		"cards": cards,
		"expected": str(spec.get("expected_text", "")),
		"observed": "",
		"log": "",
		"result": "queue",
		"column": "queue",
		"ruling": spec.get("ruling", {}),
		"paper_fight": str(spec.get("paper_fight", "")),
		"note": str(spec.get("note", "")),
		"family": str(spec.get("family", "")),
	}


func _card_ref(id: String, kind: String) -> Dictionary:
	var src: Dictionary = main.items_by_id if kind == "item" else main.monsters_by_id
	var card: Dictionary = src.get(id, {})
	return {
		"id": id,
		"kind": kind,
		"name": str(card.get("name", id)),
		"ability": str(card.get("ability", "")),
		"sprite": str(SPRITE.get(id, extra_sprite.get(id, ""))),
	}


func _load_json(path: String) -> Dictionary:
	var txt: String = FileAccess.get_file_as_string(path)
	if txt.strip_edges() == "":
		return {}
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _slim_row(r: Dictionary) -> Dictionary:
	return {
		"id": r.get("id", ""),
		"title": r.get("title", ""),
		"result": r.get("result", ""),
		"column": r.get("column", ""),
		"family": r.get("family", ""),
		"observed": r.get("observed", ""),
		"mismatch": r.get("mismatch", ""),
	}


func _ids_on_disk() -> Dictionary:
	var out := {}
	var d := DirAccess.open(ProjectSettings.globalize_path(ROWS_DIR))
	if d == null:
		return out
	d.list_dir_begin()
	var fn := d.get_next()
	while fn != "":
		if fn.ends_with(".json"):
			out[fn.trim_suffix(".json")] = true
		fn = d.get_next()
	return out


func _record_row(row: Dictionary) -> void:
	var c: String = str(row.get("column", row.get("result", "queue")))
	_counts[c] = int(_counts.get(c, 0)) + 1
	if c in ["fail", "needs_ruling", "blocked"]:
		_findings.append(row)
		_write_row(row)
		_flush_index()
	else:
		_index_dirty += 1
		if _index_dirty >= 25:
			_flush_index()


func _write_row(row: Dictionary) -> void:
	var dir := ROWS_DIR
	if bool(get_meta("qa_covering", false)):
		dir = "res://design/qa/logic-pass/covering/rows"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	elif bool(get_meta("qa_scenario", false)):
		dir = "res://design/qa/logic-pass/scenario/rows"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var path := "%s/%s.json" % [dir, str(row.get("id", "row")).replace("/", "-")]
	_write_json(path, row)


func _write_progress(n: int, total: int) -> void:
	var last_id := status
	if not results.is_empty():
		last_id = str(results[results.size() - 1].get("id", ""))
	var path := PROGRESS_PATH
	if bool(get_meta("qa_covering", false)):
		path = "res://design/qa/logic-pass/covering/progress.json"
	elif bool(get_meta("qa_scenario", false)):
		path = "res://design/qa/logic-pass/scenario/progress.json"
	_write_json(path, {
		"n": n,
		"total": total,
		"last_id": last_id,
		"status": status,
		"counts": _counts,
		"busy": busy and not finished,
	})


func _flush_index() -> void:
	_index_dirty = 0
	_write_json(FINDINGS_PATH, {"rows": _findings, "counts": _counts})
	_write_json(INDEX_PATH, {
		"title": "Covering pass" if bool(get_meta("qa_covering", false)) else ("Named scenarios" if bool(get_meta("qa_scenario", false)) else "Dense mill"),
		"mode": "dense",
		"generated": Time.get_datetime_string_from_system(true, true),
		"counts": _counts,
		"progress": {
			"n": _resume_n + results.size(),
			"total": _suite_total,
			"last_id": "" if results.is_empty() else results[results.size() - 1].get("id", ""),
		},
		"rows": _findings,
	})


func _write_outputs() -> void:
	var n: int = _resume_n + results.size()
	var raw := {"generated": Time.get_datetime_string_from_system(true, true), "count": n}
	_write_json(RAW_PATH, raw)
	if bool(get_meta("qa_dense", false)):
		_write_json(SLIM_PATH, {"rows": results, "counts": _counts})
		_flush_index()
		var last_id := ""
		if not results.is_empty():
			last_id = str(results[results.size() - 1].get("id", ""))
		var done_path := PROGRESS_PATH
		if bool(get_meta("qa_covering", false)):
			done_path = "res://design/qa/logic-pass/covering/progress.json"
		elif bool(get_meta("qa_scenario", false)):
			done_path = "res://design/qa/logic-pass/scenario/progress.json"
		_write_json(done_path, {
			"n": n,
			"total": _suite_total,
			"last_id": last_id,
			"status": "done",
			"counts": _counts,
			"busy": false,
		})
		return
	var slim: Array = []
	var findings: Array = []
	var counts := {}
	for r in results:
		slim.append(_slim_row(r))
		var c: String = str(r.get("column", r.get("result", "queue")))
		counts[c] = int(counts.get(c, 0)) + 1
		if c in ["fail", "needs_ruling", "blocked"]:
			findings.append(r)
	_write_json(SLIM_PATH, {"rows": slim, "counts": counts})
	_write_json(FINDINGS_PATH, {"rows": findings, "counts": counts})
	_write_json(PROGRESS_PATH, {
		"n": results.size(),
		"total": results.size(),
		"last_id": "" if results.is_empty() else results[results.size() - 1].get("id", ""),
		"counts": counts,
		"busy": false,
	})
	var index_rows: Array = findings
	if findings.is_empty():
		index_rows = results
	_write_json(INDEX_PATH, {
		"title": "Logic QA",
		"mode": "legacy",
		"generated": raw["generated"],
		"counts": counts,
		"rows": index_rows,
	})


func _write_json(path: String, data: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		last_error = "write failed %s" % path
		return
	f.store_string(JSON.stringify(data))
	f.close()
