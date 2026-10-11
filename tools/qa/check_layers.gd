extends SceneTree

var PATHS := [
	"res://scripts/lanes/game_state.gd",
	"res://scripts/content/content_defs.gd",
	"res://scripts/content/catalog_io.gd",
	"res://scripts/core/fight_flow.gd",
	"res://scripts/core/draft_flow.gd",
	"res://scripts/core/run_flow.gd",
	"res://scripts/core/tutorial_flow.gd",
	"res://scripts/ui/hud_controller.gd",
	"res://scripts/ui/authoring_ui.gd",
	"res://scripts/main.gd",
]


func _init() -> void:
	for p in PATHS:
		print("LOAD ", p)
		var scr: Variant = load(p)
		if scr == null:
			print("  NULL")
		else:
			print("  OK ", scr)
	quit()
