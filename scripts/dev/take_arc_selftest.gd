extends SceneTree
## Headless proof for H3-B2 Take arc geometry (split L/R, rim clearance).
## Does not boot main.gd.

const UX := preload("res://scripts/playtest_ux.gd")
const TAKE := preload("res://scripts/ui/take_arc.gd")
const ARROW := preload("res://scripts/ui/move_arrow.gd")


func _init() -> void:
	var failed := false
	failed = _check("sweep_positive", TAKE.SWEEP > 1.0 and TAKE.SWEEP < 1.7) or failed
	failed = _check("split_left_third", TAKE.SPLIT_T > 0.25 and TAKE.SPLIT_T < 0.4) or failed
	failed = _check("body_w", TAKE.BODY_W >= 40.0) or failed
	failed = _check("rim_gap", TAKE.RIM_GAP_DEFAULT >= 2.0) or failed
	failed = _check("b2_pad_lt_pre", UX.move_arrow_b2_pad() < UX.move_arrow_outer_pad()) or failed
	failed = _check("b2_pad_clears_flare", UX.move_arrow_b2_pad() >= ARROW.BODY_W * 0.78 + 6.0) or failed
	failed = _check("b2_start_past_arc", UX.move_arrow_b2_start_offset() > TAKE.SWEEP * 0.5) or failed

	var arc: Button = TAKE.new()
	root.add_child(arc)
	arc.set_guide(Vector2(400, 300), 200.0, TAKE.RIM_GAP_DEFAULT)
	arc.set_combat(4, 2, "Take", null, "", null, ThemeDB.fallback_font)

	var span: Vector2 = arc._arc_span()
	failed = _check("span_sweeps_rightward", span.y < 0.0) or failed
	var left_ang: float = span.x
	var right_ang: float = span.x + span.y
	failed = _check("left_ang_gt_right", left_ang > right_ang) or failed

	var block_pt: Vector2 = arc._chord_point(TAKE.SPLIT_T * 0.5)
	var take_pt: Vector2 = arc._chord_point(TAKE.SPLIT_T + (1.0 - TAKE.SPLIT_T) * 0.5)
	## Visual left = smaller x at the bottom of a circle centered on guide_c.
	failed = _check("block_left_of_take", block_pt.x < take_pt.x) or failed
	failed = _check("block_below_center", block_pt.y > arc.guide_c.y) or failed
	failed = _check("take_below_center", take_pt.y > arc.guide_c.y) or failed

	var inn: float = arc.inner_radius()
	var out: float = arc.outer_radius()
	failed = _check("inner_outside_rim", inn >= 200.0 + TAKE.RIM_GAP_DEFAULT - 0.01) or failed
	failed = _check("outer_thick", out >= inn + TAKE.BODY_W - 0.01) or failed

	## Safe state still keeps split chrome (divider + blank left).
	arc.set_combat(0, 0, "Safe", null, "", null, ThemeDB.fallback_font)
	failed = _check("safe_keeps_guide", arc.guide_r >= 8.0) or failed
	failed = _check("safe_block_blank", arc.block_n == 0) or failed
	failed = _check("safe_take_zero", arc.take_n == 0) or failed

	## Hit test: a point on the left third of the band must register.
	var hit_left: Vector2 = arc._chord_point(0.15)
	failed = _check("hit_left_third", arc._has_point(hit_left)) or failed
	var miss_above: Vector2 = arc.guide_c + Vector2(0, -arc.guide_r)
	failed = _check("miss_top", not arc._has_point(miss_above)) or failed

	## Rounded end caps: accept points near the left/right chord tips
	## (past the old square radial cut, inside the disk).
	var left_cap: Vector2 = arc._chord_point(0.0)
	var right_cap: Vector2 = arc._chord_point(1.0)
	var away_l: Vector2 = (left_cap - arc.guide_c).normalized()
	var tang_l: Vector2 = Vector2(-away_l.y, away_l.x)
	## Tangential outward from the left tip (past the square end).
	var hit_left_cap: Vector2 = left_cap + tang_l * (TAKE.BODY_W * 0.35)
	failed = _check("hit_left_cap", arc._has_point(hit_left_cap)) or failed
	var away_r: Vector2 = (right_cap - arc.guide_c).normalized()
	var tang_r: Vector2 = Vector2(-away_r.y, away_r.x)
	## Tangential outward from the right tip.
	var hit_right_cap: Vector2 = right_cap - tang_r * (TAKE.BODY_W * 0.35)
	failed = _check("hit_right_cap", arc._has_point(hit_right_cap)) or failed

	## Arrow B2 pad keeps head flare outside the gold rim.
	var arrow: Button = ARROW.new()
	root.add_child(arrow)
	arrow.pointing = -1
	var b2_pad: float = UX.move_arrow_b2_pad()
	arrow.set_guide(Vector2(400, 300), 200.0, 3, true, b2_pad, PI * 0.28, UX.move_arrow_b2_start_offset())
	var path_r: float = 200.0 + b2_pad
	var head_inward: float = ARROW.BODY_W * 0.78
	failed = _check("arrow_tip_clears_rim", path_r - head_inward > 200.0) or failed
	var a_span: Vector2 = arrow._arc_span()
	var arrow_near: float = a_span.x
	var take_left: float = PI * 0.5 + TAKE.SWEEP * 0.5
	## Left arrow starts at PI/2 + start_offset; must be past Take's left tip.
	failed = _check("arrow_starts_past_take", arrow_near >= take_left - 0.02) or failed

	arc.queue_free()
	arrow.queue_free()
	if failed:
		push_error("take_arc self-test failed")
		quit(1)
	else:
		print("SELFTEST_OK take_arc")
		quit(0)


func _check(name: String, ok: bool) -> bool:
	print("CASE %s ok=%s" % [name, ok])
	if not ok:
		push_error("CASE failed: %s" % name)
	return not ok
