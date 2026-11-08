extends SceneTree
## 1680×1040 progress-menu stills. Fixture shots labeled; catalog shot is acceptance evidence.


const OUT_DIR := "res://playtest/repot/outbox/REQ-20261108-progress-menu/shots"
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

var _present_done := false


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
	## Seed partial Verdant progress.
	for id in ["net", "sai", "shield", "spinning_top"]:
		if items.has(id):
			state["banked"][id] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	var swiped := {}
	for id in state["banked"].keys():
		swiped[str(id)] = true

	## --- FIXTURE (6-ish synthetic clarity; labeled) ---
	var fixture_items := {
		"net": {"id": "net", "name": "Net", "pool": 1},
		"sai": {"id": "sai", "name": "Sai", "pool": 1},
		"shield": {"id": "shield", "name": "Shield", "pool": 1},
		"spinning_top": {"id": "spinning_top", "name": "Spinning Top", "pool": 1},
		"throwing_knife": {"id": "throwing_knife", "name": "Throwing Knife", "pool": 1},
		"flying_saucer": {"id": "flying_saucer", "name": "Flying Saucer", "pool": 1},
	}
	var fixture_tex := {}
	for id in fixture_items.keys():
		if tex.has(id):
			fixture_tex[id] = tex[id]

	await _shot(menu, {
		"file": "FIXTURE-01-win-collection.png",
		"label": "FIXTURE",
		"payload": {
			"kind": "win",
			"new_ids": ["net", "sai"],
			"played_pool": "b1",
			"played_name": "Verdant Hollow",
			"items_by_id": fixture_items,
			"tex_by_item": fixture_tex,
			"swiped": {"net": true, "sai": true, "shield": true, "spinning_top": true},
			"rules": rules,
			"state": state,
			"push_block": false,
			"tutorial": false,
		},
		"tab": 1,
	})
	await _shot(menu, {
		"file": "FIXTURE-02-next-goal.png",
		"label": "FIXTURE",
		"payload": {
			"kind": "win",
			"new_ids": [],
			"played_pool": "b1",
			"played_name": "Verdant Hollow",
			"items_by_id": fixture_items,
			"tex_by_item": fixture_tex,
			"swiped": swiped,
			"rules": rules,
			"state": state,
			"push_block": false,
			"tutorial": false,
		},
		"tab": 2,
	})

	## --- CATALOG acceptance (full b1 roster + real icons) ---
	await _shot(menu, {
		"file": "CATALOG-01-collection-b1.png",
		"label": "CATALOG",
		"payload": {
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
		},
		"tab": 1,
	})
	await _shot(menu, {
		"file": "CATALOG-02-next-goal.png",
		"label": "CATALOG",
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
	})
	await _shot(menu, {
		"file": "CATALOG-03-overview.png",
		"label": "CATALOG",
		"payload": {
			"kind": "win",
			"new_ids": ["net"],
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
		"tab": 0,
	})
	await _shot(menu, {
		"file": "CATALOG-04-death.png",
		"label": "CATALOG",
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
	})
	await _shot(menu, {
		"file": "CATALOG-05-tutorial.png",
		"label": "CATALOG",
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
	})

	print("SHOTS_OK progress_menu FIXTURE+CATALOG")
	print("RESULT_LABELS: FIXTURE-* = synthetic/example; CATALOG-* = full catalog acceptance")
	quit(0)


func _shot(menu: CanvasLayer, spec: Dictionary) -> void:
	_present_done = false
	_kick_present(menu, spec["payload"])
	await create_timer(0.85).timeout
	## Conclude auto so cells are visible, then force tab.
	if menu.has_method("_cancel_presentation"):
		menu.call("_cancel_presentation")
	menu.set("_phase", 3)
	if menu.has_method("_on_tab"):
		menu.call("_on_tab", int(spec["tab"]))
	if menu.has_method("_reveal_all_new_in_view"):
		menu.call("_reveal_all_new_in_view")
	await process_frame
	await process_frame
	var path := "%s/%s" % [OUT_DIR, str(spec["file"])]
	var vp_tex: ViewportTexture = get_root().get_viewport().get_texture()
	var img: Image = vp_tex.get_image() if vp_tex != null else null
	if img == null:
		print("SKIP_SHOT %s label=%s" % [path, spec.get("label", "")])
	else:
		img.save_png(path)
		print("WROTE %s label=%s size=%sx%s icons=%s roster_hint=catalog" % [
			path, spec.get("label", ""), img.get_width(), img.get_height(),
			(spec["payload"].get("tex_by_item", {}) as Dictionary).size(),
		])
	menu.dismiss()
	await _wait_present_done(2.0)
	await process_frame


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
