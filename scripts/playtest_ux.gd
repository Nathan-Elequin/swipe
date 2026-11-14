extends Object
## Shared playtest UX policy for SP-06 / SP-10 / SP-12 / SP-13.
## Keep numbers here so the self-test can read the same defaults the game uses.


static func hover_inspect_allowed(phase: String) -> bool:
	match phase:
		"title", "victory", "defeat", "rest":
			return false
		_:
			return true


static func hover_examples() -> PackedStringArray:
	return PackedStringArray(["wizard", "golem", "goblin", "bandit", "commander"])


static func keyword_tip_min_size() -> Vector2:
	## Direction A parchment card: fixed width 296, min height 96.
	return Vector2(296, 96)


static func keyword_tip_title_font() -> Vector2i:
	return Vector2i(20, 16)


static func keyword_tip_body_font() -> Vector2i:
	return Vector2i(17, 14)


static func caption_align_while_typing() -> int:
	return HORIZONTAL_ALIGNMENT_LEFT


static func dialog_choice_reserve_px() -> float:
	return 18.0 * 4.0


static func move_arrow_outer_pad() -> float:
	## Pre-B2 / no-Take-arc rest distance from wheel rim to arrow path center.
	return 72.0


static func move_arrow_start_offset() -> float:
	## Angular gap from six-o'clock to the arrow's near tip (no Take arc).
	return 0.58


static func move_arrow_b2_pad() -> float:
	## H3-B2: closer than pre-B2, but far enough that the arrow HEAD flare
	## clears the gold rim. Head flare reaches ~BODY_W*0.78 inward of the path.
	## BODY_W is 30 → need pad ≳ 30*0.78 + rim clearance.
	return 40.0


static func move_arrow_b2_start_offset() -> float:
	## H3-B2: start past the Take arc tip so shafts / spins stay readable.
	## Take arc half-sweep is ~0.71; clear it with a small gap.
	return 0.88


static func loot_opening_total(plan_n: int, seat_n: int) -> int:
	if plan_n > 0:
		return plan_n
	return maxi(1, seat_n)


static func loot_remaining(opening: bool, pick_i: int, plan_n: int, seat_n: int, deck_n: int, offering: bool) -> Dictionary:
	if opening:
		var total: int = loot_opening_total(plan_n, seat_n)
		return {
			"remaining": clampi(total - pick_i, 0, total),
			"total": total,
		}
	var rem: int = maxi(0, deck_n)
	if offering:
		rem += 1
	return {
		"remaining": rem,
		"total": maxi(rem, seat_n),
	}


static func keep_face_after_neighbor_hole() -> bool:
	return true


static func draft_tip_prefer_below() -> bool:
	return true


static func closed_empty_in_tutorial() -> bool:
	return true


static func spotlight_lift_alpha() -> float:
	return 0.10


static func spotlight_dim_alpha() -> float:
	return 0.72


static func space_hint_always_when_waiting() -> bool:
	## SP-10 blink alone is not enough — show floating Space copy whenever a beat waits on Space.
	return true


## F2 Feedback is open: shortcuts (M, Space, F-keys) must not fire. Escape still closes it.
static func feedback_open(tree: SceneTree) -> bool:
	if tree == null:
		return false
	for n in tree.get_nodes_in_group("playtest_feedback"):
		if n is CanvasItem and (n as CanvasItem).is_visible_in_tree():
			return true
	return false
