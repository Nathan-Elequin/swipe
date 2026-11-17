extends SceneTree
## Headless UI shots for title-menu flow (logic placeholders).
## Writes under playtest/repot/outbox/REQ-20261117-title-menu-flow/shots/
##
## Run:
##   godot --headless --path . --script res://scripts/dev/playtest_title_menu_ui_shots.gd


const HUB := preload("res://scripts/playtest_hub.gd")
const PICKER := preload("res://scripts/playtest_commitment_picker.gd")
const SETTINGS := preload("res://scripts/settings_menu.gd")
const C := preload("res://scripts/playtest_commitment.gd")

const OUT := "res://playtest/repot/outbox/REQ-20261117-title-menu-flow/shots"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))

	var host: Window = get_root()
	var stage := ColorRect.new()
	stage.color = Color("15120f")
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(stage)

	var hub = HUB.new()
	host.add_child(hub)
	hub.setup()

	## 01 — no save
	hub.open_hub(false)
	await process_frame
	await process_frame
	_shot("01-title-no-save.png")

	## 02 — with save
	hub.open_hub(true)
	await process_frame
	await process_frame
	_shot("02-title-with-save.png")

	## 03 — start over confirm
	hub.open_hub(true)
	hub.call("_show_start_over_confirm")
	await process_frame
	await process_frame
	_shot("03-start-over-confirm.png")
	hub.close_hub()

	## 04 — title settings (shared settings_menu)
	var pause = SETTINGS.new()
	host.add_child(pause)
	pause.setup(null)
	pause.open_menu(false)
	await process_frame
	await process_frame
	_shot("04-title-settings.png")
	pause.close_menu()
	pause.visible = false

	## 05 — picker card + tooltip text present (native tooltip may not paint headless)
	var picker = PICKER.new()
	host.add_child(picker)
	picker.setup()
	picker.open_picker("choose", C.TIER_NONE, {})
	await process_frame
	await process_frame
	## Focus middle card so selection reads; tooltip_text is set on the card.
	if picker.get("_card_nodes") != null and picker._card_nodes.size() > 1:
		picker._focus_i = 1
		picker._paint_focus()
		picker._grab_focus_card()
	await process_frame
	await process_frame
	_shot("05-picker-card-tooltip.png")

	print("TITLE_MENU_UI_SHOTS_OK")
	quit(0)


func _shot(name: String) -> void:
	var img: Image = get_root().get_viewport().get_texture().get_image()
	if img == null:
		push_error("shot failed: %s" % name)
		return
	var path := "%s/%s" % [OUT, name]
	img.save_png(path)
	print("wrote ", path)
