extends SceneTree
## Headless check: the corner string matches `git rev-parse --short HEAD`,
## plus a trailing * when `git status --porcelain` shows anything except the
## generated stamp file. Does not boot main.gd.

const Stamp := preload("res://scripts/build_stamp.gd")


func _initialize() -> void:
	var root := ProjectSettings.globalize_path("res://")
	while root.ends_with("/") or root.ends_with("\\"):
		root = root.substr(0, root.length() - 1)
	var sha := _git(PackedStringArray(["-C", root, "rev-parse", "--short", "HEAD"]))
	if sha == "":
		push_error("git rev-parse --short HEAD failed")
		quit(1)
		return
	var dirty := false
	var status: Dictionary = _git_raw(PackedStringArray([
		"-C", root, "status", "--porcelain", "--untracked-files=normal",
	]))
	if not bool(status["ok"]):
		push_error("git status failed")
		quit(1)
		return
	var status_text := String(status["text"])
	for line in status_text.split("\n", false):
		var t := String(line).strip_edges()
		if t == "" or t.ends_with("data/build_stamp.txt"):
			continue
		dirty = true
		break
	var want := sha + ("*" if dirty else "")
	var got := String(Stamp.text())
	if got != want:
		push_error("on-screen stamp '%s' != '%s'" % [got, want])
		quit(1)
		return
	var from_files := String(Stamp._sha_from_files(root))
	if from_files == "" or not sha.begins_with(from_files):
		push_error("file HEAD '%s' is not a prefix of '%s'" % [from_files, sha])
		quit(1)
		return
	var plug := load("res://addons/build_stamp/plugin.gd") as GDScript
	var exp := load("res://addons/build_stamp/export_plugin.gd") as GDScript
	if plug == null or exp == null:
		push_error("build stamp editor plugin failed to parse")
		quit(1)
		return
	if not Stamp.write_disk():
		push_error("could not write data/build_stamp.txt")
		quit(1)
		return
	var baked := String(Stamp.read_baked())
	if baked != got:
		push_error("baked '%s' != live '%s'" % [baked, got])
		quit(1)
		return
	var abs_path := ProjectSettings.globalize_path(Stamp.STAMP_PATH)
	DirAccess.remove_absolute(abs_path)
	print("BUILD_STAMP_OK %s" % got)
	quit(0)


func _git(args: PackedStringArray) -> String:
	var raw: Dictionary = _git_raw(args)
	if not bool(raw["ok"]):
		return ""
	return String(raw["text"]).strip_edges().to_lower()


func _git_raw(args: PackedStringArray) -> Dictionary:
	var output: Array = []
	var code := OS.execute("git", args, output, false)
	var s := ""
	for item in output:
		s += str(item)
	return {"ok": code == 0, "text": s}
