extends RefCounted
class_name ShotCli
## Command-line shot runner args and save backup. Ships in exports so a leftover marker can be restored. The runner itself never starts when OS.has_feature("template") is true.

const TEXT_TARGETS := "13a_intro_panel1,13b_intro_panel2,13c_intro_panel3,text_combat_tips,text_item_hand,40_itch_midfight,41_itch_draft_gate,42_itch_boss,text_cabin_main,text_cabin_nib,text_pause,text_map,text_map_adventure,text_radio,text_challenge_ready,text_tutorial_nib,text_journal,wide_1280x800_cabin,wide_1280x800_combat,wide_1920x1080_cabin,wide_1920x1080_combat,wide_2560x1080_cabin,wide_2560x1080_combat,wide_3440x1440_cabin,wide_3440x1440_combat"
const DEFAULT_OUT := "res://design/audit-shots/cursor"
const SAVE := "user://home_cabin.json"
const BACKUP_DIR := "user://_harness_backup"
const BACKUP := "user://_harness_backup/home_cabin.json"
const ABSENT := "user://_harness_backup/absent"
const MARKER := "user://_harness_marker"


static func enabled(args: PackedStringArray) -> bool:
	return enabled_for(OS.has_feature("template"), args)


static func enabled_for(is_template: bool, args: PackedStringArray) -> bool:
	if is_template:
		return false
	return has_shot_arg(args)


static func has_shot_arg(args: PackedStringArray) -> bool:
	for arg in args:
		var text := str(arg)
		if text.begins_with("--shots=") or text == "--text-targets":
			return true
	return false


static func list_raw(args: PackedStringArray) -> String:
	var saw_shots := false
	var shots := ""
	var text_alias := false
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--shots="):
			saw_shots = true
			shots = text.substr(8)
		elif text == "--text-targets":
			text_alias = true
	if saw_shots:
		return shots
	if text_alias:
		return TEXT_TARGETS
	return ""


static func out_dir(args: PackedStringArray) -> String:
	for arg in args:
		var text: String = str(arg)
		if text.begins_with("--shots-out="):
			return text.substr(12).strip_edges()
	return DEFAULT_OUT


static func parse_names(raw: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for part in raw.split(",", false):
		var stem := str(part).strip_edges()
		if stem == "":
			continue
		if stem.ends_with(".png"):
			stem = stem.get_basename()
		out.append(stem)
	return out


static func recover_if_marked() -> bool:
	if not FileAccess.file_exists(MARKER):
		return true
	if not restore_backup():
		push_error("Shot harness marker found but home_cabin.json restore failed")
		return false
	if not delete_marker():
		push_error("Shot harness save restored but marker delete failed")
		return false
	return true


static func begin_guard() -> bool:
	if FileAccess.file_exists(MARKER):
		if not restore_backup():
			return false
		if not delete_marker():
			return false
	if not write_backup():
		return false
	return write_marker()


static func end_guard() -> bool:
	if not restore_backup():
		return false
	return delete_marker()


static func write_backup() -> bool:
	if not _ensure_backup_dir():
		return false
	if not FileAccess.file_exists(SAVE):
		if not _remove_if_there(BACKUP):
			return false
		var marker := FileAccess.open(ABSENT, FileAccess.WRITE)
		if marker == null:
			return false
		marker.store_string("absent\n")
		marker.close()
		return true
	if not _remove_if_there(ABSENT):
		return false
	return _copy_file(SAVE, BACKUP)


static func restore_backup() -> bool:
	if FileAccess.file_exists(ABSENT):
		return _remove_if_there(SAVE)
	if not FileAccess.file_exists(BACKUP):
		return false
	return _copy_file(BACKUP, SAVE)


static func write_marker() -> bool:
	var f := FileAccess.open(MARKER, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string("shots\n")
	f.close()
	return true


static func delete_marker() -> bool:
	return _remove_if_there(MARKER)


static func _ensure_backup_dir() -> bool:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BACKUP_DIR))
	return err == OK or err == ERR_ALREADY_EXISTS


static func _copy_file(src: String, dst: String) -> bool:
	if not FileAccess.file_exists(src):
		return false
	var bytes := FileAccess.get_file_as_bytes(src)
	if FileAccess.get_open_error() != OK:
		return false
	var f := FileAccess.open(dst, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(bytes)
	f.close()
	return true


static func _remove_if_there(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var err := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	return err == OK or err == ERR_FILE_NOT_FOUND
