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
	failed = _check(failed, "kw_shroud_def", body.find("Click") >= 0 and body.find("reveal") >= 0) or failed

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
	if failed:
		push_error("PHANTOM_SHROUD_SMOKE_FAIL")
		quit(1)
	print("PHANTOM_SHROUD_SMOKE_OK")
	quit(0)


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % name)
		return failed
	push_error("FAIL %s" % name)
	return true
