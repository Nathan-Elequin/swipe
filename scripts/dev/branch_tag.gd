extends RefCounted
## Dev-only: shows the current git branch in the bottom-left corner in editor runs.
## Never shown in exported builds or during shot-harness runs. Not player-facing text.

const SHOT_CLI := preload("res://scripts/shot_cli.gd")


static func attach(parent: Node) -> void:
	if not OS.has_feature("editor"):
		return
	if SHOT_CLI.enabled(OS.get_cmdline_user_args()):
		return
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--shots") or str(arg).begins_with("--covering"):
			return
	var branch := read_branch()
	if branch == "":
		return
	var layer := CanvasLayer.new()
	layer.layer = 128
	layer.name = "DevBranchTag"
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 12)
	if branch == "main":
		label.text = "main"
		label.modulate = Color(1, 1, 1, 0.3)
	else:
		label.text = "🧪 " + branch
		label.modulate = Color(1, 1, 1, 0.6)
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	label.position += Vector2(6, -4)
	layer.add_child(label)
	parent.add_child(layer)


static func read_branch() -> String:
	var root := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var git_path := root.path_join(".git")
	var head_path := git_path.path_join("HEAD")
	if FileAccess.file_exists(git_path):
		# Worktree: .git is a file "gitdir: <path>"
		var link := FileAccess.get_file_as_string(git_path).strip_edges()
		if not link.begins_with("gitdir:"):
			return ""
		var gitdir := link.substr(7).strip_edges()
		if gitdir.is_relative_path():
			gitdir = root.path_join(gitdir)
		head_path = gitdir.path_join("HEAD")
	if not FileAccess.file_exists(head_path):
		return ""
	var head := FileAccess.get_file_as_string(head_path).strip_edges()
	if head.begins_with("ref: refs/heads/"):
		return head.substr(16)
	if head.begins_with("ref: "):
		return head.substr(5)
	return head.substr(0, 7)
