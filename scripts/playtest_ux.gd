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
	return Vector2(280, 80)


static func keyword_tip_title_font() -> Vector2i:
	return Vector2i(18, 14)


static func keyword_tip_body_font() -> Vector2i:
	return Vector2i(16, 13)


static func caption_align_while_typing() -> int:
	return HORIZONTAL_ALIGNMENT_LEFT


static func dialog_choice_reserve_px() -> float:
	return 18.0 * 4.0


static func move_arrow_outer_pad() -> float:
	return 72.0


static func move_arrow_start_offset() -> float:
	return 0.58


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
