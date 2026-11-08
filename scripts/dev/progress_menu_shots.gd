extends SceneTree
## CATALOG stills with BEFORE / MID / AFTER land settle evidence.
## Prints SOURCE_BODY_SHA from env (instrumentation commit stamps separately).


const OUT_DIR := "res://playtest/repot/outbox/REQ-20261108-progress-menu/shots"
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

var _present_done := false
var _failed_bright := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	PLAYER_COPY.reload()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var source_sha := OS.get_environment("PROGRESS_SOURCE_SHA")
	if source_sha == "":
		source_sha = "unset"
	print("SHOT_SOURCE_BODY_SHA=%s" % source_sha)

	var MenuScr = load("res://scripts/ui/progress_menu.gd")
	var menu: CanvasLayer = MenuScr.new()
	root.add_child(menu)
	await process_frame

	var ArtScr = load("res://scripts/dungeon_art.gd")
	var art = ArtScr.new()
	root.add_child(art)
	if art.has_method("setup"):
		art.setup()
	await process_frame

	var rules: Dictionary = CAMPAIGN_SHELL.read_json("res://data/campaign.json")
	var catalog: Dictionary = CAMPAIGN_SHELL.read_json("res://data/catalog.json")
	var items: Dictionary = {}
	for raw in catalog.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var id := str(raw.get("id", ""))
		if id != "":
			items[id] = raw
	var tex: Dictionary = {}
	for id in items.keys():
		var t: Texture2D = art.item_tex(str(id))
		if t != null:
			tex[str(id)] = t

	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for id in ["net", "sai", "shield", "spinning_top"]:
		if items.has(id):
			state["banked"][id] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	var swiped := {}
	for id in state["banked"].keys():
		swiped[str(id)] = true

	var payload := {
		"kind": "win",
		"new_ids": ["net", "sai"],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": tex,
		"swiped": swiped,
		"rules": rules,
		"state": state,
		"push_block": false,
		"tutorial": false,
	}

	## --- BEFORE: new cells hidden (alpha 0), count excludes unrevealed news ---
	_present_done = false
	_kick_present(menu, payload)
	await create_timer(0.08).timeout
	menu.call("_cancel_presentation")
	menu.set("_phase", 1) ## AREA
	menu.set("_revealed_new", {})
	menu.call("_show_panel", 1)
	menu.set("_area_filter", "b1")
	menu.call("_rebuild_area_tabs")
	await process_frame
	var before_ev := _cell_evidence(menu, "net")
	print("EVIDENCE BEFORE net=%s" % before_ev)
	await _write_shot("CATALOG-BEFORE-new-hidden.png", source_sha, before_ev)

	## --- MID: land with animate; capture mid-fade (~half of 0.12s land tween) ---
	menu.call("_land_new", "net", true)
	menu.call("_land_new", "sai", true)
	await create_timer(0.06).timeout
	var mid_ev := _cell_evidence(menu, "net")
	print("EVIDENCE MID net=%s" % mid_ev)
	await _write_shot("CATALOG-MID-new-fading.png", source_sha, mid_ev)

	## --- AFTER: settle full bright ---
	if menu.has_method("settle_landed_visuals"):
		menu.call("settle_landed_visuals")
	await create_timer(0.15).timeout
	await process_frame
	var after_ev := _cell_evidence(menu, "net")
	print("EVIDENCE AFTER net=%s" % after_ev)
	_failed_bright = false
	if float(after_ev.get("modulate_a", 0.0)) < 0.99:
		print("FAIL EVIDENCE AFTER modulate_a not settled")
		_failed_bright = true
	if str(after_ev.get("state", "")) != PLAYER_COPY.text("postrun.collection.item_new", "New!"):
		print("FAIL EVIDENCE AFTER state not New!")
		_failed_bright = true
	await _write_shot("CATALOG-AFTER-new-settled.png", source_sha, after_ev)

	## Overview with total aggregate
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	await _write_shot("CATALOG-03-overview.png", source_sha, {"tab": "overview"})

	## Next goal / death / tutorial stills (settled)
	await _settled_tab_shot(menu, {
		"file": "CATALOG-01-collection-b1.png",
		"payload": payload,
		"tab": 1,
		"source_sha": source_sha,
	})
	await _settled_tab_shot(menu, {
		"file": "CATALOG-02-next-goal.png",
		"payload": {
			"kind": "win",
			"new_ids": [],
			"played_pool": "b1",
			"played_name": "Verdant Hollow",
			"items_by_id": items,
			"tex_by_item": tex,
			"swiped": swiped,
			"rules": rules,
			"state": state,
			"push_block": false,
			"tutorial": false,
		},
		"tab": 2,
		"source_sha": source_sha,
	})
	await _settled_tab_shot(menu, {
		"file": "CATALOG-04-death.png",
		"payload": {
			"kind": "loss",
			"new_ids": [],
			"played_pool": "b1",
			"played_name": "Verdant Hollow",
			"items_by_id": items,
			"tex_by_item": tex,
			"swiped": swiped,
			"rules": rules,
			"state": state,
			"push_block": false,
			"tutorial": false,
		},
		"tab": 1,
		"source_sha": source_sha,
	})
	await _settled_tab_shot(menu, {
		"file": "CATALOG-05-tutorial.png",
		"payload": {
			"kind": "tutorial",
			"new_ids": [],
			"played_pool": "b1",
			"played_name": "Verdant Hollow",
			"items_by_id": items,
			"tex_by_item": tex,
			"swiped": {},
			"rules": rules,
			"state": CAMPAIGN_SHELL.fresh_state(),
			"push_block": false,
			"tutorial": true,
		},
		"tab": 0,
		"source_sha": source_sha,
	})

	if _failed_bright:
		print("SHOTS_FAIL bright settle evidence")
		quit(1)
	print("SHOTS_OK progress_menu BEFORE/MID/AFTER+CATALOG source_sha=%s icons=%s" % [source_sha, tex.size()])
	quit(0)


func _cell_evidence(menu: CanvasLayer, id: String) -> Dictionary:
	var cell: Control = menu.get("_cell_by_id").get(id, null)
	if cell == null:
		return {"id": id, "missing": true}
	var state_l: Label = cell.find_child("State", true, false) as Label
	var icon: TextureRect = cell.find_child("Icon", true, false) as TextureRect
	return {
		"id": id,
		"modulate_a": cell.modulate.a,
		"modulate": str(cell.modulate),
		"state": state_l.text if state_l else "",
		"icon_modulate": str(icon.modulate) if icon else "",
		"count_lab": str(menu.get("_area_count_lab").text) if menu.get("_area_count_lab") else "",
	}


func _write_shot(file: String, source_sha: String, evidence: Dictionary) -> void:
	var path := "%s/%s" % [OUT_DIR, file]
	var vp_tex: ViewportTexture = get_root().get_viewport().get_texture()
	var img: Image = vp_tex.get_image() if vp_tex != null else null
	if img == null:
		print("SKIP_SHOT %s" % path)
		return
	img.save_png(path)
	print("WROTE %s source_sha=%s size=%sx%s evidence=%s" % [
		path, source_sha, img.get_width(), img.get_height(), evidence
	])


func _settled_tab_shot(menu: CanvasLayer, spec: Dictionary) -> void:
	_present_done = false
	_kick_present(menu, spec["payload"])
	await create_timer(0.2).timeout
	menu.call("_cancel_presentation")
	menu.set("_phase", 3)
	for id in spec["payload"].get("new_ids", []):
		menu.get("_revealed_new")[str(id)] = true
	menu.call("_on_tab", int(spec["tab"]))
	if menu.has_method("settle_landed_visuals"):
		menu.call("settle_landed_visuals")
	await create_timer(0.2).timeout
	await process_frame
	await _write_shot(str(spec["file"]), str(spec.get("source_sha", "")), {"tab": spec["tab"]})
	menu.dismiss()
	await _wait_present_done(2.0)


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
