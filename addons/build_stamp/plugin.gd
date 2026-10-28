@tool
extends EditorPlugin
## Before F5, refresh the fallback stamp file. The running game still reads
## git itself, so this file is only the copy exports and non-editor runs use.
## Returns true even when the write fails so a stamp problem cannot block play.

const ExportPlug := preload("res://addons/build_stamp/export_plugin.gd")
const Stamp := preload("res://scripts/build_stamp.gd")

var _export: EditorExportPlugin


func _enter_tree() -> void:
	_export = ExportPlug.new()
	add_export_plugin(_export)


func _exit_tree() -> void:
	if _export != null:
		remove_export_plugin(_export)
		_export = null


func _build() -> bool:
	Stamp.write_disk()
	return true
