extends SceneTree
## Phantom Shroud presentation smoke — item_card veil + keyword wiring.
## Does not boot main.gd. Run:
##   godot --headless --path . --script res://scripts/dev/phantom_shroud_selftest.gd

const CARD := preload("res://scripts/item_card.gd")
const UX := preload("res://scripts/ux_style.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = _check(failed, "kw_shroud_id", UX.def_id_of("Shroud") == "shroud") or failed
	failed = _check(failed, "kw_shrouded_id", UX.def_id_of("Shrouded") == "shroud") or failed
	var body: String = UX.def_of("shroud")
	failed = _check(failed, "kw_shroud_def", body.find("Hidden") >= 0) or failed

	var card: PanelContainer = CARD.new()
	root.add_child(card)
	card.setup(1, "boot", "3", null, Color("5c2626"), Color("c0c0c0"), "Boot", Color.WHITE, "ATK", null)
	card.set_live("3", "", true)
	card.size = Vector2(CARD.CARD_W, CARD.CARD_H)
	card.queue_sort()
	await process_frame
	await process_frame

	card.set_curse(true)
	card.set_shroud(true)
	await process_frame
	failed = _check(failed, "is_shrouded", card.has_method("is_shrouded") and card.is_shrouded()) or failed
	var haze: Node = card.find_child("ShroudHaze", true, false)
	failed = _check(failed, "haze_node", haze != null and haze is Control and (haze as Control).visible) or failed
	var mark: Node = card.find_child("ShroudMark", true, false)
	failed = _check(failed, "mark_node", mark != null and mark is Label and (mark as Label).visible and str((mark as Label).text) == "?") or failed
	## Formula must stay suppressed while shrouded.
	if card.has_method("set_formula"):
		card.set_formula("(3)")
	card.show_formula(true)
	failed = _check(failed, "still_shrouded_after_formula", card.is_shrouded()) or failed
	## Cabinet badge must not peek through after re-sync.
	if card.has_method("set_cabinet_badge"):
		card.set_cabinet_badge(true, "New!", "")
		card.set_shroud(true)
		await process_frame
		var cab: Node = null
		for n in card.find_children("*", "Label", true, false):
			if n is Label and str((n as Label).text) == "New!" and (n as Label).visible:
				cab = n
				break
		failed = _check(failed, "new_badge_hidden", cab == null) or failed

	card.set_shroud(false)
	await process_frame
	failed = _check(failed, "unshroud_clears", not card.is_shrouded()) or failed
	if haze != null:
		failed = _check(failed, "haze_hidden", not (haze as Control).visible) or failed

	card.queue_free()
	failed = await _rules(failed) or failed
	if failed:
		push_error("PHANTOM_SHROUD_SMOKE_FAIL")
		quit(1)
		return
	print("PHANTOM_SHROUD_SMOKE_OK")
	quit(0)


func _mon(id: String, hp: int, atk: int, uid: int, shroud_from: Array = [], seen: bool = false) -> Dictionary:
	return {
		"kind": "monster",
		"card_id": id,
		"name": id,
		"hp": hp,
		"atk": atk,
		"seat_uid": uid,
		"shroud_from": shroud_from,
		"shroud_seen": seen,
		"phantom_shroud": not seen and not shroud_from.is_empty(),
	}


func _rules(failed: bool) -> bool:
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(failed, "helper_present", src.find("func _shroud_reveal_before_defeat") >= 0) or failed
	failed = _check(failed, "deal_awaits_reveal", src.find("await _shroud_reveal_before_defeat(index)") >= 0) or failed
	failed = _check(failed, "cue_cover", src.find("&\"shroud.cover\"") >= 0 or src.find("&'shroud.cover'") >= 0) or failed
	var main: Node = (load("res://scripts/main.gd") as GDScript).new()
	main.phase = "fighting"
	main.hp = 8
	main.blk = 99
	main.facing_index = 0
	main.wheel = [
		_mon("rat", 8, 2, 10, [], true),
		_mon("phantom", 6, 6, 1, [], true),
		_mon("goblin", 8, 1, 2, [1], false),
		_mon("slime", 4, 3, 3, [], true),
		_mon("bat", 2, 8, 4, [1], false),
		_mon("mouse", 4, 1, 5, [], true),
	]
	## 0 rat 8 vis. 1 Phantom. 2 goblin 8 shrouded. 3 slime 4 vis. 4 bat 2/8 shrouded. 5 mouse 4 vis.
	failed = _check(failed, "goblin_shrouded", main._monster_shrouded(main.wheel[2])) or failed
	failed = _check(failed, "scythe_skips_shroud", not main._can_mark(2, "defeat_double_hp")) or failed
	failed = _check(failed, "scythe_allows_visible", main._can_mark(0, "defeat_double_hp")) or failed
	failed = _check(failed, "top_skips_shroud", not main._can_mark(2, "defeat_spins")) or failed
	failed = _check(failed, "love_skips_shroud", not main._can_mark(2, "love_potion")) or failed
	failed = _check(failed, "love_visible_pair", main._love_has_hp_match(3)) or failed
	failed = _check(failed, "love_hidden_partner", not main._love_has_hp_match(0)) or failed
	failed = _check(failed, "hook_allows_shroud", main._can_mark(2, "hook_swap")) or failed
	main.facing_index = 1
	failed = _check(failed, "poly_skips_shroud", not main._can_mark(2, "polymorph")) or failed
	failed = _check(failed, "poly_allows_visible_neighbor", main._can_mark(0, "polymorph")) or failed
	main.facing_index = 0
	main.pending_mark = {"top_n": 4}
	failed = _check(failed, "top_can_mark_visible", main._can_mark(3, "defeat_spins")) or failed
	failed = _check(failed, "top_cannot_mark_shroud", not main._can_mark(2, "defeat_spins")) or failed
	main.pending_mark = {}
	main.facing_index = 5
	failed = _check(failed, "tesla_hidden_across", not main._tesla_can_play()) or failed
	var boot: Dictionary = {"card_id": "da_boot", "ops": {"kind": "defeat_hp"}, "ability": ""}
	main.facing_index = 4
	var boot_view: Dictionary = main._item_view(boot)
	failed = _check(failed, "boot_hidden_cannot", not bool(boot_view.get("can_use", true))) or failed
	var sledge: Dictionary = {"card_id": "sledgehammer", "ops": {"kind": "defeat_atk"}, "ability": ""}
	var sledge_view: Dictionary = main._item_view(sledge)
	failed = _check(failed, "sledge_hidden_cannot", not bool(sledge_view.get("can_use", true))) or failed
	var bow: Dictionary = {"card_id": "longbow", "ops": {"kind": "atk_opposite", "n": 5}, "ability": ""}
	main.facing_index = 0
	var bow_view: Dictionary = main._item_view(bow)
	failed = _check(failed, "longbow_can", bool(bow_view.get("can_use", false))) or failed
	var before_seen: bool = bool(main.wheel[2].get("shroud_seen", false))
	await main._shroud_reveal_before_defeat(2)
	failed = _check(failed, "reveal_was_shrouded", not before_seen) or failed
	failed = _check(failed, "reveal_marks_seen", bool(main.wheel[2].get("shroud_seen", false))) or failed
	failed = _check(failed, "reveal_unshrouds", not main._monster_shrouded(main.wheel[2])) or failed
	var miasma_min: int = main._miasma_min_hp()
	failed = _check(failed, "miasma_visible_min", miasma_min == 4) or failed
	var imp: Array = main._imp_highest_targets()
	failed = _check(failed, "imp_skips_hidden_bat", not imp.has(4)) or failed
	main.queue_free()
	return failed


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % name)
		return failed
	push_error("FAIL %s" % name)
	return true
