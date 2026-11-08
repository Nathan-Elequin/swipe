extends SceneTree
## Headless/isolated 1680×1040 progress-menu stills for REQ-20261108-progress-menu.


const OUT_DIR := "res://playtest/repot/outbox/REQ-20261108-progress-menu/shots"
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	PLAYER_COPY.reload()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var MenuScr = load("res://scripts/ui/progress_menu.gd")
	var menu: CanvasLayer = MenuScr.new()
	root.add_child(menu)
	await process_frame

	var rules := {
		"cabinet_quota": 5,
		"starter_item_mix": [3, 2, 1],
		"biomes": [
			{"id": "b1", "name": "Verdant Hollow"},
			{"id": "b2", "name": "Crystal Cavern"},
			{"id": "b3", "name": "Ashen Crypt"},
		],
	}
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	## Seed four Verdant uniques so overview shows partial progress.
	state["banked"] = {
		"net": "b1",
		"sai": "b1",
		"shield": "b1",
		"spinning_top": "b1",
	}
	CAMPAIGN_SHELL.normalize(state)

	var items := {
		"net": {"id": "net", "name": "Net", "pool": "b1"},
		"sai": {"id": "sai", "name": "Sai", "pool": "b1"},
		"shield": {"id": "shield", "name": "Shield", "pool": "b1"},
		"spinning_top": {"id": "spinning_top", "name": "Spinning Top", "pool": "b1"},
		"throwing_knife": {"id": "throwing_knife", "name": "Throwing Knife", "pool": "b1"},
		"flying_saucer": {"id": "flying_saucer", "name": "Flying Saucer", "pool": "b1"},
	}
	var swiped := {
		"net": true,
		"sai": true,
		"shield": true,
		"spinning_top": true,
	}

	var shots := [
		{
			"file": "01-win-new.png",
			"payload": {
				"kind": "win",
				"new_ids": ["net", "sai"],
				"held_ids": ["net", "sai"],
				"played_pool": "b1",
				"played_name": "Verdant Hollow",
				"items_by_id": items,
				"tex_by_item": {},
				"swiped": swiped,
				"rules": rules,
				"state": state,
				"push_block": false,
				"tutorial": false,
			},
			"tab": 1,
		},
		{
			"file": "02-win-none.png",
			"payload": {
				"kind": "win",
				"new_ids": [],
				"held_ids": ["net"],
				"played_pool": "b1",
				"played_name": "Verdant Hollow",
				"items_by_id": items,
				"tex_by_item": {},
				"swiped": swiped,
				"rules": rules,
				"state": state,
				"push_block": false,
				"tutorial": false,
			},
			"tab": 0,
		},
		{
			"file": "03-death.png",
			"payload": {
				"kind": "loss",
				"new_ids": [],
				"held_ids": [],
				"played_pool": "b1",
				"played_name": "Verdant Hollow",
				"items_by_id": items,
				"tex_by_item": {},
				"swiped": swiped,
				"rules": rules,
				"state": state,
				"push_block": false,
				"tutorial": false,
			},
			"tab": 0,
		},
		{
			"file": "04-tutorial.png",
			"payload": {
				"kind": "tutorial",
				"new_ids": [],
				"held_ids": [],
				"played_pool": "b1",
				"played_name": "Verdant Hollow",
				"items_by_id": items,
				"tex_by_item": {},
				"swiped": {},
				"rules": rules,
				"state": state,
				"push_block": false,
				"tutorial": true,
			},
			"tab": 0,
		},
		{
			"file": "05-next-goal.png",
			"payload": {
				"kind": "win",
				"new_ids": [],
				"held_ids": [],
				"played_pool": "b1",
				"played_name": "Verdant Hollow",
				"items_by_id": items,
				"tex_by_item": {},
				"swiped": swiped,
				"rules": rules,
				"state": state,
				"push_block": false,
				"tutorial": false,
			},
			"tab": 2,
		},
	]

	for spec in shots:
		_present_done = false
		_kick_present(menu, spec["payload"])
		## Wait until built + presentation idle, then force tab for still.
		await create_timer(0.9).timeout
		if menu.has_method("_on_tab"):
			menu.call("_on_tab", int(spec["tab"]))
		## Reveal any staggered cells.
		menu.set("_phase", 3) ## IDLE
		if int(spec["tab"]) == 1 and menu.has_method("_rebuild_grid"):
			menu.call("_rebuild_grid")
		var cells: Dictionary = menu.get("_cell_by_id") if typeof(menu.get("_cell_by_id")) == TYPE_DICTIONARY else {}
		for id in spec["payload"].get("new_ids", []):
			var cell: Control = cells.get(str(id), null)
			if cell != null:
				cell.modulate.a = 1.0
		await process_frame
		await process_frame
		var path := "%s/%s" % [OUT_DIR, str(spec["file"])]
		var vp_tex: ViewportTexture = get_root().get_viewport().get_texture()
		var img: Image = vp_tex.get_image() if vp_tex != null else null
		if img == null:
			print("SKIP_SHOT %s (no viewport image in this headless renderer)" % path)
		else:
			img.save_png(path)
			print("WROTE %s size=%sx%s" % [path, img.get_width(), img.get_height()])
		menu.dismiss()
		await _wait_present_done(2.0)
		await process_frame

	print("SHOTS_OK progress_menu")
	quit(0)


var _present_done := false


func _kick_present(menu: CanvasLayer, payload: Dictionary) -> void:
	_present_async(menu, payload)


func _present_async(menu: CanvasLayer, payload: Dictionary) -> void:
	await menu.present(payload, Callable())
	_present_done = true


func _wait_present_done(sec: float) -> void:
	var left := sec
	while not _present_done and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
