extends SceneTree
## Headless proof for SP-06 / SP-10 / SP-12 / SP-13. Does not boot main.gd.

const UX := preload("res://scripts/playtest_ux.gd")
const KEYWORD_TIP := preload("res://scripts/keyword_tip.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const WHEEL := preload("res://scripts/boss_wheel.gd")
const ARROW := preload("res://scripts/ui/move_arrow.gd")
const DRAFT := preload("res://scripts/challenge_draft.gd")


func _init() -> void:
	var failed := false
	failed = _check("hover_fighting", UX.hover_inspect_allowed("fighting")) or failed
	failed = _check("hover_slaying", UX.hover_inspect_allowed("slaying")) or failed
	failed = _check("hover_ready", UX.hover_inspect_allowed("ready")) or failed
	failed = _check("hover_draft", UX.hover_inspect_allowed("draft")) or failed
	failed = _check("no_hover_title", not UX.hover_inspect_allowed("title")) or failed
	var examples: PackedStringArray = UX.hover_examples()
	for id in ["wizard", "golem", "goblin", "bandit", "commander"]:
		failed = _check("example_%s" % id, examples.has(id)) or failed
	var tip_sz: Vector2 = UX.keyword_tip_min_size()
	failed = _check("tip_min_w", tip_sz.x >= 280.0) or failed
	failed = _check("tip_min_h", tip_sz.y >= 72.0) or failed
	failed = _check("ltr_align", UX.caption_align_while_typing() == HORIZONTAL_ALIGNMENT_LEFT) or failed
	failed = _check("choice_reserve", UX.dialog_choice_reserve_px() > 0.0) or failed
	failed = _check("arrow_pad", UX.move_arrow_outer_pad() >= 64.0) or failed
	failed = _check("arrow_off", UX.move_arrow_start_offset() >= 0.5) or failed
	failed = _check("keep_face", UX.keep_face_after_neighbor_hole()) or failed
	failed = _check("draft_below", UX.draft_tip_prefer_below()) or failed
	failed = _check("closed_empty", UX.closed_empty_in_tutorial()) or failed
	failed = _check("lift_lt_dim", UX.spotlight_lift_alpha() < UX.spotlight_dim_alpha()) or failed
	var open_pips: Dictionary = UX.loot_remaining(true, 0, 6, 6, 6, true)
	failed = _check("loot_open_six", int(open_pips.get("remaining", 0)) == 6 and int(open_pips.get("total", 0)) == 6) or failed
	var mid_pips: Dictionary = UX.loot_remaining(true, 2, 6, 6, 6, true)
	failed = _check("loot_open_four", int(mid_pips.get("remaining", 0)) == 4) or failed
	var hole_pips: Dictionary = UX.loot_remaining(false, 0, 0, 6, 3, true)
	failed = _check("loot_entry_four", int(hole_pips.get("remaining", 0)) == 4) or failed
	var view := Vector2(1280, 720)
	var no_choice: Dictionary = KIT.dialog_bar(view, 0.0, KIT.DIALOG_SAFE_CABIN)
	var reserved: Dictionary = KIT.dialog_bar(view, UX.dialog_choice_reserve_px(), KIT.DIALOG_SAFE_CABIN)
	var bar_a: Rect2 = no_choice["bar"]
	var bar_b: Rect2 = reserved["bar"]
	failed = _check("dialog_reserve_grows", bar_b.size.y > bar_a.size.y) or failed
	failed = _check("dialog_reserve_same_bottom", is_equal_approx(bar_a.end.y, bar_b.end.y) or bar_b.position.y <= bar_a.position.y) or failed
	var tip: PanelContainer = KEYWORD_TIP.new()
	root.add_child(tip)
	tip.setup()
	tip.show_def("If you are facing them, Spin the wheel at random.", tip, "flee")
	tip.reset_size()
	var got: Vector2 = tip.get_combined_minimum_size()
	failed = _check("flee_tip_w", got.x + 0.01 >= tip_sz.x) or failed
	failed = _check("flee_tip_h", got.y + 0.01 >= tip_sz.y) or failed
	if tip.has_method("pin_def"):
		tip.pin_def("If you are facing them, Spin the wheel at random.", tip, "flee")
		failed = _check("flee_pin", bool(tip.get("_pinned"))) or failed
	tip.queue_free()
	var wheel = WHEEL.new()
	root.add_child(wheel)
	wheel.closed_empties = true
	wheel.set_slices([
		{"kind": "monster", "card_id": "wizard", "name": "Wizard", "hp": 3, "atk": 2},
		{"kind": "empty", "slot": "NE"},
		{"kind": "monster", "card_id": "golem", "name": "Golem", "hp": 5, "atk": 3},
	], 0, "none")
	failed = _check("closed_flag", wheel.closed_empties) or failed
	failed = _check("pointer_at_six", is_equal_approx(WHEEL.SIX, PI * 0.5)) or failed
	wheel.queue_free()
	var arrow = ARROW.new()
	root.add_child(arrow)
	arrow.set_guide(Vector2(200, 200), 180.0, 3, true)
	var pts: PackedVector2Array = arrow._arc_pts()
	failed = _check("arrow_pts", pts.size() >= 8) or failed
	var outer: float = pts[0].distance_to(Vector2(200, 200))
	failed = _check("arrow_outer", outer >= 180.0 + 64.0) or failed
	arrow.queue_free()
	var draft = DRAFT.new()
	root.add_child(draft)
	draft.setup()
	if draft.has_method("set_loot_pips"):
		draft.set_loot_pips(6, 6)
		failed = _check("draft_pips", draft._pips != null and draft._pips.get_child_count() == 6) or failed
	draft.queue_free()
	if failed:
		push_error("playtest UX self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK playtest_ux")
		quit(0)


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok
