extends RefCounted
class_name BuildStamp
## Corner label: the short git commit of this checkout.
## Editor play (F5, and `godot --path`) reads the repo at startup, so a pull
## shows up on the next run with no extra command. Exported builds have no
## .git folder; they read res://data/build_stamp.txt, which the editor export
## plugin bakes at export time. A trailing * means tracked or untracked
## changes were present when the string was read (the stamp file itself
## does not count).

const STAMP_PATH := "res://data/build_stamp.txt"
const LAYER_NAME := "BuildStamp"
const LABEL_NAME := "Sha"


static func attach(parent: Node) -> void:
	if parent == null:
		return
	if parent.get_node_or_null(LAYER_NAME) != null:
		return
	var canvas := CanvasLayer.new()
	canvas.name = LAYER_NAME
	canvas.layer = 200
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	var label := Label.new()
	label.name = LABEL_NAME
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.focus_mode = Control.FOCUS_NONE
	label.process_mode = Node.PROCESS_MODE_ALWAYS
	label.text = text()
	label.clip_text = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.78, 0.73, 0.64, 0.88))
	label.add_theme_color_override("font_outline_color", Color(0.063, 0.055, 0.047, 0.95))
	label.add_theme_constant_override("outline_size", 3)
	label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	label.offset_left = -168.0
	label.offset_top = 4.0
	label.offset_right = -8.0
	label.offset_bottom = 22.0
	canvas.add_child(label)
	parent.add_child(canvas)


static func text() -> String:
	if OS.has_feature("editor"):
		var live := from_repo()
		if live != "":
			return live
	var baked := read_baked()
	if baked != "":
		return baked
	return "no-sha"


static func from_repo() -> String:
	if OS.has_feature("web"):
		return ""
	var root := _project_root()
	if root == "" or _git_dir(root) == "":
		return ""
	var sha := _git_short(root)
	if sha == "":
		sha = _sha_from_files(root)
	if sha == "":
		return ""
	if _git_dirty(root):
		return sha + "*"
	return sha


static func read_baked() -> String:
	if not FileAccess.file_exists(STAMP_PATH):
		return ""
	var raw := FileAccess.get_file_as_string(STAMP_PATH).strip_edges()
	if raw == "":
		return ""
	var line := raw.split("\n", false)[0].strip_edges()
	return line


static func write_disk() -> bool:
	var body := from_repo()
	if body == "":
		body = read_baked()
	if body == "":
		return false
	if read_baked() == body:
		return true
	var f := FileAccess.open(STAMP_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(body + "\n")
	f.close()
	return true


static func bake_bytes() -> PackedByteArray:
	var body := from_repo()
	if body == "":
		body = read_baked()
	if body == "":
		body = "no-sha"
	return (body + "\n").to_utf8_buffer()


static func _project_root() -> String:
	var root := ProjectSettings.globalize_path("res://")
	while root.ends_with("/") or root.ends_with("\\"):
		root = root.substr(0, root.length() - 1)
	return root


static func _git_dir(root: String) -> String:
	var git_path := root.path_join(".git")
	if FileAccess.file_exists(git_path):
		var link := FileAccess.get_file_as_string(git_path).strip_edges()
		if not link.begins_with("gitdir:"):
			return ""
		var gitdir := link.substr(7).strip_edges()
		if gitdir.is_relative_path():
			gitdir = root.path_join(gitdir)
		return gitdir
	if DirAccess.dir_exists_absolute(git_path):
		return git_path
	return ""


static func _git_short(root: String) -> String:
	var output: Array = []
	var code := OS.execute("git", PackedStringArray(["-C", root, "rev-parse", "--short", "HEAD"]), output, false)
	if code != 0:
		return ""
	var joined := _join(output).strip_edges().to_lower()
	if not _is_hex(joined):
		return ""
	return joined


static func _git_dirty(root: String) -> bool:
	var output: Array = []
	var code := OS.execute("git", PackedStringArray([
		"-C", root, "status", "--porcelain", "--untracked-files=normal",
	]), output, false)
	if code != 0:
		return false
	for line in _join(output).split("\n", false):
		var t := line.strip_edges()
		if t == "":
			continue
		if t.ends_with("data/build_stamp.txt"):
			continue
		return true
	return false


## First 7 hex digits of HEAD. That is git's default minimum for
## `rev-parse --short` when the prefix is unique.
static func _sha_from_files(root: String) -> String:
	var gitdir := _git_dir(root)
	if gitdir == "":
		return ""
	var head_path := gitdir.path_join("HEAD")
	if not FileAccess.file_exists(head_path):
		return ""
	var head := FileAccess.get_file_as_string(head_path).strip_edges()
	var full := ""
	if head.begins_with("ref: "):
		var refname := head.substr(5).strip_edges()
		var loose := gitdir.path_join(refname)
		if FileAccess.file_exists(loose):
			full = FileAccess.get_file_as_string(loose).strip_edges()
		if full.length() < 40:
			full = _packed_ref(gitdir, refname)
	else:
		full = head
	full = full.strip_edges().to_lower()
	if full.length() < 7 or not _is_hex(full.substr(0, 7)):
		return ""
	return full.substr(0, 7)


static func _packed_ref(gitdir: String, refname: String) -> String:
	var path := gitdir.path_join("packed-refs")
	if not FileAccess.file_exists(path):
		return ""
	var text := FileAccess.get_file_as_string(path)
	for line in text.split("\n", false):
		var t := line.strip_edges()
		if t == "" or t.begins_with("#") or t.begins_with("^"):
			continue
		var space := t.find(" ")
		if space < 7:
			continue
		var sha := t.substr(0, space).strip_edges()
		var name := t.substr(space + 1).strip_edges()
		if name == refname:
			return sha
	return ""


static func _is_hex(s: String) -> bool:
	if s.length() < 7 or s.length() > 40:
		return false
	for i in s.length():
		var c: int = s.unicode_at(i)
		var digit := c >= 48 and c <= 57
		var lower := c >= 97 and c <= 102
		var upper := c >= 65 and c <= 70
		if not (digit or lower or upper):
			return false
	return true


static func _join(items: Array) -> String:
	var s := ""
	for item in items:
		s += str(item)
	return s
