extends SceneTree
## Tip smoke v1 — Brand New / Skip / draft / choice rail invariants from data + script.
## Does not boot main.gd or render. Catches noon soft-lock class bugs without F5.
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
	for raw in lines:
		var row: Dictionary = raw
		var w: String = str(row.get("wait", ""))
		waits[w] = int(waits.get(w, 0)) + 1
		if w == "choice":
			choice_rows.append(row)
		if w == "draft:fangs":
			fangs_draft += 1
		if str(row.get("beat", "")) == "B27c" or str(row.get("key", "")).find("B27c") >= 0:
			b27c_rows.append(row)

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

	if guide != null and is_instance_valid(guide):
		guide.free()

	print("TIP_SMOKE_BEATS %s" % lines.size())
	print("TIP_SMOKE_WAITS %s" % waits)
	print("TIP_SMOKE_FANGS_DRAFT %s" % fangs_draft)
	print("TIP_SMOKE_B27C %s" % b27c_rows.size())
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


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("TIP_SMOKE_PASS %s" % label)
		return failed
	push_error("TIP_SMOKE_FAIL %s" % label)
	print("TIP_SMOKE_FAIL %s" % label)
	return true
