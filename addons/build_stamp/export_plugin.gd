@tool
extends EditorExportPlugin
## Puts the current short SHA into the export at res://data/build_stamp.txt.
## Skips any on-disk copy of that path so a stale file cannot win.

const Stamp := preload("res://scripts/build_stamp.gd")


func _get_name() -> String:
	return "BuildStamp"


func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	add_file(Stamp.STAMP_PATH, Stamp.bake_bytes(), false)


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if path == Stamp.STAMP_PATH:
		skip()
