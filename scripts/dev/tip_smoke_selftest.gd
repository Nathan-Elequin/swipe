extends SceneTree
## Tip smoke — Brand New / Skip / draft / choice / Harpy→Dragon / cabin-arrive
## rail invariants from data + script. Does not boot main.gd or render.
## Catches soft-lock / rail bugs without F5.
## Run: godot --headless --path . --script res://scripts/dev/tip_smoke_selftest.gd

const COPY := preload("res://scripts/player_copy.gd")
const GUIDE := preload("res://scripts/tutorial_guide.gd")

## Waits the tip rails know how to arm. New wait kinds must get a handler before shipping.
const KNOWN_WAIT_EXACT := {
	"continue": true,
	"spin": true,
	"auto_spin": true,
	"done": true,
	"choice": true,
	"free": true,
	"face": true,
	"move": true,
	"hover": true,
	"hover_item": true,
	"hover_shift": true,
}


func _init() -> void:
	var failed := false
	COPY.reload()
	var lines: Array = COPY.tutorial_lines()
	failed = _check(failed, "tutorial_lines_loaded", lines.size() >= 20) or failed

	var waits := {}
	var choice_rows: Array = []
	var fangs_draft := 0
	var b27c_rows: Array = []
	var skip_only_rows: Array = []
	var reveal_rows: Array = []
	var b55_rows: Array = []
	var auto_spin_rows: Array = []
	var arrow_head_rows: Array = []
	var spine_move := 0
	var spine_shield := 0
	var spine_flail := 0
	var spine_harpy_a := 0
	var spine_dragon := 0
	var b54_idx := -1
	var b55_idx := -1
	for i in range(lines.size()):
		var row: Dictionary = lines[i]
		var w: String = str(row.get("wait", ""))
		waits[w] = int(waits.get(w, 0)) + 1
		var beat: String = str(row.get("beat", ""))
		var branch: String = str(row.get("branch", ""))
		var force: String = str(row.get("force", ""))
		var rig: String = str(row.get("rig", ""))
		if w == "choice":
			choice_rows.append(row)
		if w == "draft:fangs":
			fangs_draft += 1
		if beat == "B27c" or str(row.get("key", "")).find("B27c") >= 0:
			b27c_rows.append(row)
		if branch == "skip_only":
			skip_only_rows.append(row)
		if rig == "reveal" or beat == "B54":
			reveal_rows.append(row)
		if beat == "B54" and b54_idx < 0:
			b54_idx = i
		if beat == "B55":
			b55_rows.append(row)
			if b55_idx < 0:
				b55_idx = i
		if w == "auto_spin":
			auto_spin_rows.append({"i": i, "row": row})
			if force == "tag:harpy_a":
				spine_harpy_a += 1
			if force == "dragon":
				spine_dragon += 1
		if w == "item:arrow_head":
			arrow_head_rows.append(row)
		if w == "move" and (force == "tag:harpy_b" or force.find("harpy") >= 0):
			spine_move += 1
		if w == "item:shield":
			spine_shield += 1
		if w == "item:spiked_flail":
			spine_flail += 1

	## 1) draft:fangs must exist — missing wait soft-locks Brand New at Fangs take.
	failed = _check(failed, "draft_fangs_wait", fangs_draft >= 1) or failed

	## 2) Goblin choice allow: Boot / Breastplate / Take — no Shield (noon soft-lock path).
	failed = _check(failed, "choice_row_exists", choice_rows.size() == 1) or failed
	if choice_rows.size() >= 1:
		var allow: Array = choice_rows[0].get("allow", [])
		failed = _check(failed, "choice_allow_boot", allow.has("da_boot")) or failed
		failed = _check(failed, "choice_allow_breastplate", allow.has("breastplate")) or failed
		failed = _check(failed, "choice_allow_end_fight", allow.has("end_fight")) or failed
		failed = _check(failed, "choice_allow_no_shield", not allow.has("shield")) or failed

	## 3) B27c Breastplate-path branch rows exist for the Goblin Block→Keep teach.
	failed = _check(failed, "b27c_rows", b27c_rows.size() >= 2) or failed
	var b27c_breast := 0
	for raw_b in b27c_rows:
		var br: Dictionary = raw_b
		if str(br.get("branch", "")) == "breastplate":
			b27c_breast += 1
	failed = _check(failed, "b27c_branch_breastplate", b27c_breast >= 2) or failed

	## 4) Every player-copy wait resolves to a known rail vocabulary.
	var unknown: Array[String] = []
	for w_key in waits.keys():
		var w2: String = str(w_key)
		if _wait_known(w2):
			continue
		unknown.append(w2)
	failed = _check(failed, "waits_resolve", unknown.is_empty()) or failed
	if not unknown.is_empty():
		push_error("TIP_SMOKE unknown waits: %s" % ",".join(unknown))

	## 5) Next visibility: continue shows Next; action waits hide it (noon Next soft-lock class).
	var guide = GUIDE.new()
	failed = _check(failed, "guide_has_nudge", guide.has_method("nudge")) or failed
	failed = _check(failed, "guide_has_wait_shows_next", guide.has_method("_wait_shows_next")) or failed
	if guide.has_method("_wait_shows_next"):
		failed = _check(failed, "next_on_continue", bool(guide.call("_wait_shows_next", "continue"))) or failed
		failed = _check(failed, "no_next_on_choice", not bool(guide.call("_wait_shows_next", "choice"))) or failed
		failed = _check(failed, "no_next_on_draft_fangs", not bool(guide.call("_wait_shows_next", "draft:fangs"))) or failed
		failed = _check(failed, "no_next_on_item", not bool(guide.call("_wait_shows_next", "item:sai"))) or failed
		failed = _check(failed, "no_next_on_done", not bool(guide.call("_wait_shows_next", "done"))) or failed
		failed = _check(failed, "no_next_on_auto_spin", not bool(guide.call("_wait_shows_next", "auto_spin"))) or failed
		failed = _check(failed, "no_next_on_move", not bool(guide.call("_wait_shows_next", "move"))) or failed

	## 6) TutorialGuide must not expose a script `hint` property — noon crash was tut.hint = …
	failed = _check(failed, "no_script_hint_property", not _has_script_var(guide, "hint")) or failed

	## 7) No tut.hint assignments in scripts (would crash at Goblin Block→Take).
	var hint_hits: Array[String] = _scan_tut_hint_assignments()
	failed = _check(failed, "no_tut_hint_assignments", hint_hits.is_empty()) or failed
	for hit in hint_hits:
		push_error("TIP_SMOKE tut.hint: %s" % hit)

	## 8) Guide beat load matches player-copy (Brand New rail is data-driven).
	var beats: Array = guide.call("_load_beats")
	failed = _check(failed, "load_beats_count", beats.size() == lines.size()) or failed
	failed = _check(failed, "load_beats_has_draft_fangs", _beats_have_wait(beats, "draft:fangs")) or failed
	failed = _check(failed, "load_beats_has_choice", _beats_have_wait(beats, "choice")) or failed

	## 9) Skip path still names pool-1 reveal before cabin arrive (data keys/beats).
	## S1 skip_only + B54 rig=reveal + B55 home lines, with B54 before B55 in tip order.
	failed = _check(failed, "skip_only_row", skip_only_rows.size() >= 1) or failed
	var reveal_rig := 0
	for rr in reveal_rows:
		if str(rr.get("rig", "")) == "reveal":
			reveal_rig += 1
	failed = _check(failed, "b54_reveal_rig", reveal_rig >= 1) or failed
	failed = _check(failed, "b55_arrive_rows", b55_rows.size() >= 1) or failed
	failed = _check(failed, "reveal_before_arrive", b54_idx >= 0 and b55_idx > b54_idx) or failed

	## 10) Harpy→Dragon spine waits present (verify against tip player-copy, don't invent).
	failed = _check(failed, "spine_auto_spin_harpy_a", spine_harpy_a >= 1) or failed
	failed = _check(failed, "spine_item_arrow_head", arrow_head_rows.size() >= 1) or failed
	failed = _check(failed, "spine_move_harpy_b", spine_move >= 1) or failed
	failed = _check(failed, "spine_item_shield", spine_shield >= 1) or failed
	failed = _check(failed, "spine_auto_spin_dragon", spine_dragon >= 1) or failed
	failed = _check(failed, "spine_item_flail", spine_flail >= 1) or failed
	failed = _check(failed, "spine_auto_spin_count", auto_spin_rows.size() >= 4) or failed

	## 11) Continue→auto_spin after kills when tip data says so.
	## Each Yes-path auto_spin must be preceded by continue or draft:* (kill/loot → auto land).
	var bad_auto_prev := 0
	var yes_auto := 0
	for pack in auto_spin_rows:
		var ai: int = int(pack.get("i", -1))
		var arow: Dictionary = pack.get("row", {})
		var abr: String = str(arow.get("branch", ""))
		if abr == "trigger" or abr == "skip_only":
			continue
		yes_auto += 1
		var prev_w := _prev_yes_wait(lines, ai)
		if prev_w != "continue" and not prev_w.begins_with("draft:"):
			bad_auto_prev += 1
			push_error("TIP_SMOKE auto_spin prev wait=%s at %s" % [prev_w, str(arow.get("key", ""))])
	failed = _check(failed, "auto_spin_after_continue_or_draft", yes_auto >= 1 and bad_auto_prev == 0) or failed

	## 12) Arrow Head available from start if tip data says so.
	if arrow_head_rows.size() >= 1:
		var ah: Dictionary = arrow_head_rows[0]
		var ah_allow: Array = ah.get("allow", [])
		var ah_text: String = str(ah.get("text", "")).to_lower()
		failed = _check(failed, "arrow_head_allow", ah_allow.has("arrow_head")) or failed
		failed = _check(failed, "arrow_head_from_start_copy", ah_text.find("from the start") >= 0) or failed
	var start_hotbar_ok := _main_starts_with_arrow_head()
	failed = _check(failed, "arrow_head_in_start_hotbar", start_hotbar_ok) or failed

	## 13) Cabin under road: cabin/music not before arrive — expressible from guide/data + hooks.
	## B54 reveal before B55; hide-under-road + finish path unlock-then-music_cabin order.
	failed = _check(failed, "hide_cabin_under_road_hook", _source_has_method("res://scripts/home_cabin.gd", "_hide_cabin_under_road")) or failed
	failed = _check(failed, "road_finish_to_cabin_hook", _source_has_func("res://scripts/main.gd", "_road_finish_to_cabin")) or failed
	failed = _check(failed, "tut_skip_finish_path", _source_contains("res://scripts/main.gd", "_road_finish_to_cabin")) or failed
	var finish_order_ok := _road_finish_unlock_before_cabin_music()
	failed = _check(failed, "unlock_before_cabin_music", finish_order_ok) or failed
	## Hide-under-road must silence cabin (no music/chrome during approach/ambush/overlay).
	failed = _check(failed, "hide_under_road_silences", _source_func_calls("res://scripts/home_cabin.gd", "_hide_cabin_under_road", "_silence_cabin")) or failed

	if guide != null and is_instance_valid(guide):
		guide.free()

	print("TIP_SMOKE_BEATS %s" % lines.size())
	print("TIP_SMOKE_WAITS %s" % waits)
	print("TIP_SMOKE_FANGS_DRAFT %s" % fangs_draft)
	print("TIP_SMOKE_B27C %s" % b27c_rows.size())
	print("TIP_SMOKE_AUTO_SPIN %s" % auto_spin_rows.size())
	print("TIP_SMOKE_SKIP_ONLY %s" % skip_only_rows.size())
	if failed:
		push_error("TIP_SMOKE_FAIL")
		quit(1)
	else:
		print("TIP_SMOKE_OK")
		quit(0)


func _wait_known(w: String) -> bool:
	if w == "":
		return false
	if KNOWN_WAIT_EXACT.has(w):
		return true
	if w.begins_with("item:") and w.length() > 5:
		return true
	if w.begins_with("draft:") and w.length() > 6:
		return true
	if w.begins_with("hover"):
		return true
	return false


func _beats_have_wait(beats: Array, want: String) -> bool:
	for raw in beats:
		var b: Dictionary = raw
		if str(b.get("wait", "")) == want:
			return true
	return false


func _prev_yes_wait(lines: Array, at: int) -> String:
	## Walk backward past trigger / skip_only / empty-branch-mismatch rows to the prior Yes beat wait.
	var j: int = at - 1
	while j >= 0:
		var prev: Dictionary = lines[j]
		var br: String = str(prev.get("branch", ""))
		if br == "trigger" or br == "skip_only":
			j -= 1
			continue
		## Branch rows (boot/take/breastplate/wizard) still sit on the Yes spine after a choice.
		return str(prev.get("wait", ""))
	return ""


func _has_script_var(obj: Object, name: String) -> bool:
	for p in obj.get_property_list():
		if str(p.get("name", "")) != name:
			continue
		var usage: int = int(p.get("usage", 0))
		## Script-declared vars carry PROPERTY_USAGE_SCRIPT_VARIABLE (4096).
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			return true
	return false


func _scan_tut_hint_assignments() -> Array[String]:
	var hits: Array[String] = []
	var root := ProjectSettings.globalize_path("res://scripts")
	_scan_dir_for_tut_hint(root, hits)
	return hits


func _scan_dir_for_tut_hint(path: String, hits: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full: String = path.path_join(name)
		if dir.current_is_dir():
			_scan_dir_for_tut_hint(full, hits)
		elif name.ends_with(".gd"):
			## Skip this harness — it mentions tut.hint in the scanner itself.
			if name == "tip_smoke_selftest.gd":
				name = dir.get_next()
				continue
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null:
				var line_n := 0
				while not f.eof_reached():
					line_n += 1
					var line: String = f.get_line()
					var stripped: String = line.strip_edges()
					if stripped.begins_with("#"):
						continue
					## Only real assignments crash (tut.hint = …). Mentions in strings/docs are fine.
					var eq: int = stripped.find("tut.hint")
					if eq < 0:
						continue
					var after: String = stripped.substr(eq + "tut.hint".length()).strip_edges()
					if after.begins_with("="):
						hits.append("%s:%d:%s" % [full.replace("\\", "/"), line_n, stripped])
		name = dir.get_next()
	dir.list_dir_end()


func _read_source(res_path: String) -> String:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _source_contains(res_path: String, needle: String) -> bool:
	return _read_source(res_path).find(needle) >= 0


func _source_has_method(res_path: String, method: String) -> bool:
	## Match `func method(` declarations (not calls).
	var src := _read_source(res_path)
	return src.find("func %s(" % method) >= 0


func _source_has_func(res_path: String, method: String) -> bool:
	return _source_has_method(res_path, method)


func _source_func_calls(res_path: String, method: String, callee: String) -> bool:
	## True if the body of `func method(` contains a call to callee before the next top-level func.
	var src := _read_source(res_path)
	var start: int = src.find("func %s(" % method)
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	return body.find(callee) >= 0


func _main_starts_with_arrow_head() -> bool:
	## Tip board seats Arrow Head in the opening hotbar (Nathan 2026-11-04).
	var src := _read_source("res://scripts/main.gd")
	var start: int = src.find("func _start_tutorial(")
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	## Prefer the hotbar grant loop; fall back to any arrow_head string in the starter body.
	if body.find("arrow_head") < 0:
		return false
	## Must appear with the other opening items (sai / breastplate / spiked_flail).
	return body.find("sai") >= 0 and body.find("spiked_flail") >= 0 and body.find("arrow_head") >= 0


func _road_finish_unlock_before_cabin_music() -> bool:
	## Pool-1 reveal (`_tutorial_play_unlock`) must run before cabin music / arrive splash.
	var src := _read_source("res://scripts/main.gd")
	var start: int = src.find("func _road_finish_to_cabin(")
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	var unlock_i: int = body.find("_tutorial_play_unlock")
	var music_i: int = body.find("music_cabin")
	var arrive_i: int = body.find("play_arrive_splash")
	if unlock_i < 0:
		return false
	if music_i >= 0 and music_i < unlock_i:
		return false
	if arrive_i >= 0 and arrive_i < unlock_i:
		return false
	## At least one of music / arrive should follow unlock (arrive splash owns cabin return).
	return music_i > unlock_i or arrive_i > unlock_i


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("TIP_SMOKE_PASS %s" % label)
		return failed
	push_error("TIP_SMOKE_FAIL %s" % label)
	print("TIP_SMOKE_FAIL %s" % label)
	return true
