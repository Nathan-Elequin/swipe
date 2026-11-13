extends SceneTree
## Headless proof for H3-B2 Take arc geometry (split L/R, rim clearance).
## Also asserts Take-arc readability: always-on Block shield, native 1× upright icons.
## Does not boot main.gd.

const UX := preload("res://scripts/playtest_ux.gd")
const TAKE := preload("res://scripts/ui/take_arc.gd")
const ARROW := preload("res://scripts/ui/move_arrow.gd")
const ITEM_FACE := preload("res://scripts/item_face.gd")
const SHIELD_PATH := "res://assets/ui/icons/pips/pip_block_s24_2x.png"


func _init() -> void:
	var failed := false
	failed = _check("sweep_positive", TAKE.SWEEP > 0.74 and TAKE.SWEEP < 0.86) or failed
	failed = _check("split_left_third", TAKE.SPLIT_T > 0.25 and TAKE.SPLIT_T < 0.4) or failed
	## BODY_W 60: double burst is 56 tall + 2px clearance each side.
	failed = _check("body_w", TAKE.BODY_W >= 58.0 and TAKE.BODY_W <= 64.0) or failed
	## ICON_MAX 64: double burst is 64 wide; draw at native 1× (no fractional scale).
	failed = _check("icon_max_native", TAKE.ICON_MAX >= 64.0) or failed
	failed = _check("double_fits_band", TAKE.BODY_W >= 56.0 + 4.0) or failed
	failed = _check("bevel_ink", TAKE.BEVEL_INK >= 2.0 and TAKE.BEVEL_HI >= 1.0) or failed
	failed = _check("rim_gap", TAKE.RIM_GAP_DEFAULT >= 8.0) or failed
	failed = _check("content_outward", TAKE.CONTENT_OUTWARD >= 0.0 and TAKE.CONTENT_OUTWARD <= 2.0) or failed
	failed = _check("word_fs_26", TAKE.WORD_FS == 26) or failed
	failed = _check("num_matches_itemface", TAKE.NUM_FS == 22 and TAKE.NUM_OUTLINE == 4) or failed
	failed = _check("word_ink_dark", TAKE.WORD_INK.r < 0.2) or failed
	failed = _check("b2_pad_lt_pre", UX.move_arrow_b2_pad() < UX.move_arrow_outer_pad()) or failed
	failed = _check("b2_pad_clears_flare", UX.move_arrow_b2_pad() >= ARROW.BODY_W * 0.78 + 6.0) or failed
	failed = _check("b2_start_past_arc", UX.move_arrow_b2_start_offset() > TAKE.SWEEP * 0.5) or failed

	var arc: Button = TAKE.new()
	root.add_child(arc)
	arc.set_guide(Vector2(400, 300), 200.0, TAKE.RIM_GAP_DEFAULT)
	var shield: Texture2D = null
	if ResourceLoader.exists(SHIELD_PATH):
		shield = load(SHIELD_PATH) as Texture2D
	## Headless CI may lack .ctex until --import; keep a native 48×48 stand-in.
	if shield == null:
		var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.4, 0.6, 0.8, 1.0))
		shield = ImageTexture.create_from_image(img)
	failed = _check("itemface_shield_const", str(ITEM_FACE.SHIELD) == SHIELD_PATH) or failed
	failed = _check("take_shield_path", TAKE.SHIELD_PATH == SHIELD_PATH) or failed
	arc.set_combat(4, 2, "Take", null, "", shield, ThemeDB.fallback_font)
	failed = _check("has_play_pop", arc.has_method("play_pop")) or failed
	failed = _check("has_burst_ink_outline_fn", arc.has_method("_draw_burst_ink_outline")) or failed
	failed = _check("no_burst_rim_fn", not arc.has_method("_draw_burst_rim")) or failed
	failed = _check("keeps_arc_text", arc.has_method("_draw_arc_text")) or failed

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

	## Safe / block_n 0: shield still draws (always-on Block pip).
	arc.set_combat(0, 0, "Safe", null, "", shield, ThemeDB.fallback_font)
	failed = _check("safe_keeps_guide", arc.guide_r >= 8.0) or failed
	failed = _check("safe_block_zero", arc.block_n == 0) or failed
	failed = _check("safe_take_zero", arc.take_n == 0) or failed
	failed = _check("shield_draws_at_block_zero", arc.should_draw_block() and arc.block_n == 0) or failed
	failed = _check("uses_itemface_shield_path", TAKE.SHIELD_PATH == ITEM_FACE.SHIELD) or failed
	## Passed block_tex is what draws; size must stay native 48×48 (item-card pip).
	failed = _check("block_tex_assigned", arc.block_tex == shield) or failed

	## Icons: native 1× scale, upright (no rotation).
	failed = _check("icons_upright", arc.icons_upright()) or failed
	failed = _check("icons_integer_scale_1x", is_equal_approx(arc.icon_draw_scale(shield), 1.0)) or failed
	var native: Vector2 = arc._icon_draw_size(shield)
	failed = _check("shield_native_48", native.x == 48.0 and native.y == 48.0) or failed
	failed = _check("no_fractional_fit", arc._fitted_icon_size(shield) == native) or failed

	## Hit test: a point on the left third of the band must register.
	var hit_left: Vector2 = arc._chord_point(0.15)
	failed = _check("hit_left_third", arc._has_point(hit_left)) or failed
	var miss_above: Vector2 = arc.guide_c + Vector2(0, -arc.guide_r)
	failed = _check("miss_top", not arc._has_point(miss_above)) or failed

	## Square radial cuts: the end-face still hits; a point past the cut misses.
	failed = _check("no_end_caps", not arc.has_method("_draw_end_caps")) or failed
	failed = _check("has_bevel", arc.has_method("_draw_bevel")) or failed
	failed = _check("has_corner_ticks", arc.has_method("_draw_corner_ticks")) or failed
	var left_cap: Vector2 = arc._chord_point(0.0)
	var right_cap: Vector2 = arc._chord_point(1.0)
	failed = _check("hit_left_end", arc._has_point(left_cap)) or failed
	failed = _check("hit_right_end", arc._has_point(right_cap)) or failed
	var away_l: Vector2 = (left_cap - arc.guide_c).normalized()
	var tang_l: Vector2 = Vector2(-away_l.y, away_l.x)
	## Tangential outward from the left tip (past the square end).
	var hit_left_cap: Vector2 = left_cap + tang_l * (TAKE.BODY_W * 0.35)
	failed = _check("miss_past_left_end", not arc._has_point(hit_left_cap)) or failed
	var away_r: Vector2 = (right_cap - arc.guide_c).normalized()
	var tang_r: Vector2 = Vector2(-away_r.y, away_r.x)
	## Tangential outward from the right tip.
	var hit_right_cap: Vector2 = right_cap - tang_r * (TAKE.BODY_W * 0.35)
	failed = _check("miss_past_right_end", not arc._has_point(hit_right_cap)) or failed

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
