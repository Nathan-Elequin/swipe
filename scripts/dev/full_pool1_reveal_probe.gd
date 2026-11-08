extends SceneTree
## Post-tutorial Pool 1 reveal — isolated sandbox probe.
##
## Proves: with tutorial-seen IDs seeded, `_tutorial_unlock_entries` / `_tutorial_play_unlock`
## still emit the full canonical Pool 1 set from `_bucket_entries(1)` (no missing/extra/
## duplicates; seen IDs present). Skip (empty seen) matches the same set.
##
## Run via: ./tools/qa/run_full_pool1_reveal_probe.sh

const MAIN_SCENE := "res://scenes/main.tscn"

## Typical Yes-path seats/drafts/grants that used to be subtracted.
const SEEN_SEED: PackedStringArray = [
	"throwing_knife",
	"shield",
	"bracers",
	"golem",
	"dire_wolf",
	"needleback",
	"vampire",
	"goblin",
	"net",
	"spinning_top",
]


class RevealCapture extends Node:
	var play_calls: int = 0
	var last_bucket: int = -999
	var last_entries: Array = []

	func play(bucket_n: int, entries: Array) -> void:
		play_calls += 1
		last_bucket = bucket_n
		last_entries = entries.duplicate(true)


func _initialize() -> void:
	var failed := false
	if not _sandbox_ok():
		print("REFUSED_UNSAFE_DIRECT_USERDATA path=%s" % OS.get_user_data_dir())
		push_error(
			"FULL_POOL1_REVEAL_PROBE_FAIL refuse: user data '%s' is not a pool1-reveal sandbox. "
			% OS.get_user_data_dir()
			+ "Run tools/qa/run_full_pool1_reveal_probe.sh (sets XDG_DATA_HOME)."
		)
		quit(1)
		return
	print("PROBE_USER_DATA=", OS.get_user_data_dir())
	print("SANDBOX_GUARD_OK")

	failed = _source_contracts() or failed

	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		push_error("FULL_POOL1_REVEAL_PROBE_FAIL change_scene err=%s" % err)
		quit(1)
		return

	var main: Node = null
	var tries := 0
	while tries < 300:
		await process_frame
		tries += 1
		main = root.get_node_or_null("Main")
		if main != null and ("items_by_id" in main) and main.items_by_id != null:
			break
	if main == null or main.items_by_id == null:
		push_error("FULL_POOL1_REVEAL_PROBE_FAIL main/catalog missing after boot")
		quit(1)
		return

	_quiet_playtest_chrome(main)
	await process_frame

	failed = _case_helper_parity_with_seen(main) or failed
	failed = await _case_play_unlock_path_with_seen(main) or failed
	failed = _case_skip_empty_seen_same_set(main) or failed

	if failed:
		push_error("FULL_POOL1_REVEAL_PROBE_FAIL")
		print("FULL_POOL1_REVEAL_PROBE_FAIL")
		quit(1)
	else:
		print("FULL_POOL1_REVEAL_PROBE_OK")
		quit(0)


func _sandbox_ok() -> bool:
	var path := OS.get_user_data_dir()
	return path.find("full-pool1-reveal") >= 0 or path.find("pool1-reveal") >= 0


func _quiet_playtest_chrome(main: Node) -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		if key in main and main.get(key) != null:
			var n: Variant = main.get(key)
			if n is CanvasItem:
				(n as CanvasItem).visible = false
	if "phase" in main:
		main.phase = "cabin"


func _source_contracts() -> bool:
	var failed := false
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var start: int = src.find("func _tutorial_unlock_entries(")
	var end: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, maxi(0, end - start))
	failed = _check(failed, "source_unlock_calls_bucket_entries_1", body.find("_bucket_entries(1)") >= 0) or failed
	failed = _check(failed, "source_unlock_omits_tut_seen", body.find("_tut_seen") < 0) or failed
	failed = _check(
		failed,
		"source_play_unlock_uses_unlock_entries",
		src.find("func _tutorial_play_unlock") >= 0 and src.find("_tutorial_unlock_entries()") >= 0
	) or failed
	failed = _check(
		failed,
		"source_road_finish_still_plays_unlock",
		src.find("func _road_finish_to_cabin") >= 0 and src.find("_tutorial_play_unlock") >= 0
	) or failed
	return failed


func _seed_seen(main: Node) -> void:
	main._tut_seen = {}
	for id in SEEN_SEED:
		main._tut_seen[str(id)] = true


func _ids_of(entries: Array) -> Array:
	var out: Array = []
	for raw in entries:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		out.append(str((raw as Dictionary).get("id", "")))
	out.sort()
	return out


func _dupes(ids: Array) -> Array:
	var seen: Dictionary = {}
	var dups: Array = []
	for id in ids:
		var s := str(id)
		if seen.has(s):
			dups.append(s)
		else:
			seen[s] = true
	return dups


func _case_helper_parity_with_seen(main: Node) -> bool:
	var failed := false
	_seed_seen(main)
	var expected: Array = main._bucket_entries(1)
	var got: Array = main._tutorial_unlock_entries()
	var exp_ids: Array = _ids_of(expected)
	var got_ids: Array = _ids_of(got)
	failed = _check(failed, "helper_matches_bucket_entries_1", str(exp_ids) == str(got_ids)) or failed
	failed = _check(failed, "helper_no_duplicates", _dupes(got_ids).is_empty()) or failed
	failed = _check(failed, "helper_nonempty", got_ids.size() > 0) or failed
	var missing_seen: Array = []
	for id in SEEN_SEED:
		if not got_ids.has(str(id)) and exp_ids.has(str(id)):
			missing_seen.append(str(id))
	failed = _check(failed, "helper_keeps_seen_ids", missing_seen.is_empty()) or failed
	if not missing_seen.is_empty():
		push_error("FULL_POOL1_REVEAL missing seen: %s" % ",".join(missing_seen))
	print("POOL1_REVEAL_IDS %s" % ",".join(got_ids))
	print("POOL1_REVEAL_COUNT %s" % got_ids.size())
	return failed


func _case_play_unlock_path_with_seen(main: Node) -> bool:
	var failed := false
	_seed_seen(main)
	var expected_ids: Array = _ids_of(main._bucket_entries(1))
	var capture := RevealCapture.new()
	capture.name = "RevealCapture"
	main.add_child(capture)
	var saved_reveal = main.get("_bucket_reveal")
	main.set("_bucket_reveal", capture)
	await main._tutorial_play_unlock()
	failed = _check(failed, "play_unlock_called_reveal", capture.play_calls == 1) or failed
	var got_ids: Array = _ids_of(capture.last_entries)
	failed = _check(failed, "play_unlock_full_pool1", str(got_ids) == str(expected_ids)) or failed
	failed = _check(failed, "play_unlock_no_dupes", _dupes(got_ids).is_empty()) or failed
	var missing_seen: Array = []
	for id in SEEN_SEED:
		if not got_ids.has(str(id)) and expected_ids.has(str(id)):
			missing_seen.append(str(id))
	failed = _check(failed, "play_unlock_keeps_seen", missing_seen.is_empty()) or failed
	main.set("_bucket_reveal", saved_reveal)
	if is_instance_valid(capture):
		capture.queue_free()
	return failed


func _case_skip_empty_seen_same_set(main: Node) -> bool:
	var failed := false
	main._tut_seen = {}
	var yes_like: Array = _ids_of(main._bucket_entries(1))
	## Seed then clear is not needed — empty seen must still equal full Pool 1.
	var skip_ids: Array = _ids_of(main._tutorial_unlock_entries())
	failed = _check(failed, "skip_empty_seen_full_pool1", str(skip_ids) == str(yes_like)) or failed
	return failed


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("FULL_POOL1_REVEAL_PASS %s" % label)
		return failed
	push_error("FULL_POOL1_REVEAL_FAIL %s" % label)
	print("FULL_POOL1_REVEAL_FAIL %s" % label)
	return true
