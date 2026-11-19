extends SceneTree
## Feel pass B layout + Inspect v2 monster plate invariants.
## Asserts after controls are in the tree and have processed resize frames:
## 1) wheel + Take arc global rects identical across ready / spinning / fighting
## 2) cascade rail does not intersect hotbar or wheel
## 3) Inspect v2 monster plate: dark, no portrait/rank/stats, smaller than #559 parchment
## Run: godot --headless --path . --script res://scripts/dev/feel_pass_b_selftest.gd

const TAKE := preload("res://scripts/ui/take_arc.gd")
const TICKER := preload("res://scripts/cascade_ticker.gd")
const HOVER := preload("res://scripts/hover_panel.gd")
const COPY := preload("res://scripts/player_copy.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	COPY.reload()
	failed = await _case_phase_rects() or failed
	failed = await _case_ticker_rail() or failed
	failed = await _case_compact_inspect() or failed
	## Static locks from the locked Feel pass B notes.
	failed = _check(
		failed,
		"cascade_ticker vertical VBox",
		FileAccess.get_file_as_string("res://scripts/cascade_ticker.gd").find("VBoxContainer") >= 0
	) or failed
	failed = _check(
		failed,
		"cascade z above hotbar",
		FileAccess.get_file_as_string("res://scripts/cascade_ticker.gd").find("Z_ABOVE_HOTBAR := 45") >= 0
	) or failed
	failed = _check(
		failed,
		"main holds fighting slot",
		FileAccess.get_file_as_string("res://scripts/main.gd").find('"fighting", "slaying", "draft", "devtest"') >= 0
		or FileAccess.get_file_as_string("res://scripts/main.gd").find('"ready", "spinning", "fighting", "slaying"') >= 0
	) or failed
	failed = _check(
		failed,
		"safe idle helper",
		FileAccess.get_file_as_string("res://scripts/main.gd").find("_sync_take_arc_safe_idle") >= 0
	) or failed
	failed = _check(
		failed,
		"hover reconciler",
		FileAccess.get_file_as_string("res://scripts/main.gd").find("_reconcile_hover_inspect") >= 0
	) or failed
	failed = _check(
		failed,
		"wheel motion while busy",
		FileAccess.get_file_as_string("res://scripts/boss_wheel.gd").find("only clicks are blocked") >= 0
		or FileAccess.get_file_as_string("res://scripts/boss_wheel.gd").find("Motion still updates hover") >= 0
		or FileAccess.get_file_as_string("res://scripts/boss_wheel.gd").find("motion still updates hover") >= 0
	) or failed
	failed = _check(
		failed,
		"compact monster fill",
		FileAccess.get_file_as_string("res://scripts/hover_panel.gd").find("_fill_compact_monster") >= 0
	) or failed
	failed = _check(
		failed,
		"inspect v2 ability helper",
		FileAccess.get_file_as_string("res://scripts/hover_panel.gd").find("_inspect_v2_ability") >= 0
	) or failed
	var compact_src := FileAccess.get_file_as_string("res://scripts/hover_panel.gd")
	var compact_i: int = compact_src.find("func _fill_compact_monster")
	var compact_fn: String = compact_src.substr(compact_i, 3200) if compact_i >= 0 else ""
	failed = _check(
		failed,
		"compact has no player Tier/ATK words",
		compact_fn.find('"Tier"') < 0
		and compact_fn.find('"ATK"') < 0
		and compact_fn.find("text = \"ATK\"") < 0
		and compact_fn.find("text = \"Tier\"") < 0
	) or failed
	failed = _check(
		failed,
		"inspect v2 uses dark look",
		compact_fn.find("_apply_look(look)") >= 0
		and compact_fn.find("_apply_parchment_skin") < 0
	) or failed

	if failed:
		print("FEEL_PASS_B_SELFTEST fail")
		quit(1)
	else:
		print("FEEL_PASS_B_SELFTEST ok")
		quit(0)


func _case_phase_rects() -> bool:
	## Mini harness: play_field + wheel + btn_wrap + Take arc, same reservation
	## across ready / spinning / fighting.
	var root_c := Control.new()
	root_c.name = "FeelPassBRoot"
	root_c.size = Vector2(1680, 1040)
	root.add_child(root_c)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_c.add_child(col)
	var play_field := Control.new()
	play_field.name = "PlayField"
	play_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	play_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(play_field)
	var btn_wrap := MarginContainer.new()
	btn_wrap.name = "BtnWrap"
	btn_wrap.custom_minimum_size = Vector2(0, 64)
	col.add_child(btn_wrap)
	var wheel := ColorRect.new()
	wheel.name = "Wheel"
	wheel.color = Color(0.2, 0.15, 0.1, 1)
	play_field.add_child(wheel)
	var take: Button = TAKE.new()
	take.name = "TakeArc"
	root_c.add_child(take)
	await _settle()

	var rects: Array = []
	for phase in ["ready", "spinning", "fighting"]:
		## Constant height reservation (mirrors main._combat_holds_action_slot).
		btn_wrap.custom_minimum_size = Vector2(0, 64)
		btn_wrap.add_theme_constant_override("margin_top", 36)
		await _settle()
		var pf: Vector2 = play_field.size
		var side: float = minf(pf.x, maxf(120.0, pf.y - 16.0))
		var x: float = (pf.x - side) * 0.5
		wheel.position = Vector2(x, 8.0)
		wheel.size = Vector2(side, side)
		var c: Vector2 = wheel.get_global_rect().get_center()
		var rad: float = side * 0.4
		take.visible = true
		take.set_guide(take.get_global_transform().affine_inverse() * c, rad, TAKE.RIM_GAP_DEFAULT)
		## Safe idle in ready/spinning; live Take in fighting — rect must match.
		if phase == "fighting":
			take.self_modulate = Color.WHITE
			take.set_combat(2, 3, "Take", null, "", null, ThemeDB.fallback_font)
		else:
			take.self_modulate = Color(1, 1, 1, 0.55)
			take.set_combat(0, 0, "Safe", null, "", null, ThemeDB.fallback_font)
		take.set_anchors_preset(Control.PRESET_FULL_RECT)
		take.offset_left = 0
		take.offset_top = 0
		take.offset_right = 0
		take.offset_bottom = 0
		take.set_guide(take.get_global_transform().affine_inverse() * c, rad, TAKE.RIM_GAP_DEFAULT)
		var gr: Rect2 = take.arc_global_rect()
		if gr.size.x >= 8.0:
			var parent: Control = take.get_parent() as Control
			var local_pos: Vector2 = parent.get_global_transform().affine_inverse() * gr.position
			take.set_anchors_preset(Control.PRESET_TOP_LEFT)
			take.position = local_pos
			take.size = gr.size
			take.set_guide(take.get_global_transform().affine_inverse() * c, rad, TAKE.RIM_GAP_DEFAULT)
		await _settle()
		rects.append({
			"phase": phase,
			"wheel": wheel.get_global_rect(),
			"take": take.arc_global_rect() if take.has_method("arc_global_rect") else take.get_global_rect(),
			"btn_h": btn_wrap.get_combined_minimum_size().y + float(btn_wrap.get_theme_constant("margin_top")),
		})

	var failed := false
	var w0: Rect2 = rects[0]["wheel"]
	var t0: Rect2 = rects[0]["take"]
	var h0: float = float(rects[0]["btn_h"])
	for i in range(1, rects.size()):
		var wi: Rect2 = rects[i]["wheel"]
		var ti: Rect2 = rects[i]["take"]
		var hi: float = float(rects[i]["btn_h"])
		failed = _check(
			failed,
			"wheel_rect_%s" % rects[i]["phase"],
			is_equal_approx(w0.position.x, wi.position.x)
			and is_equal_approx(w0.position.y, wi.position.y)
			and is_equal_approx(w0.size.x, wi.size.x)
			and is_equal_approx(w0.size.y, wi.size.y)
		) or failed
		failed = _check(
			failed,
			"take_rect_%s" % rects[i]["phase"],
			is_equal_approx(t0.position.x, ti.position.x)
			and is_equal_approx(t0.position.y, ti.position.y)
			and is_equal_approx(t0.size.x, ti.size.x)
			and is_equal_approx(t0.size.y, ti.size.y)
		) or failed
		failed = _check(failed, "btn_wrap_h_%s" % rects[i]["phase"], is_equal_approx(h0, hi)) or failed
	root_c.queue_free()
	await _settle()
	return failed


func _case_ticker_rail() -> bool:
	var root_c := Control.new()
	root_c.size = Vector2(1680, 1040)
	root.add_child(root_c)
	var wheel := ColorRect.new()
	wheel.position = Vector2(480, 80)
	wheel.size = Vector2(720, 720)
	root_c.add_child(wheel)
	var hotbar := ColorRect.new()
	hotbar.name = "Hotbar"
	hotbar.position = Vector2(400, 920)
	hotbar.size = Vector2(880, 100)
	hotbar.z_index = 40
	root_c.add_child(hotbar)
	var ticker = TICKER.new()
	root_c.add_child(ticker)
	ticker.setup()
	ticker.dock_to_wheel(wheel)
	ticker.begin()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.6, 0.2, 1))
	var tex := ImageTexture.create_from_image(img)
	for i in 4:
		ticker.push("tok_%d" % i, tex)
	await _settle()
	var rail: Rect2 = ticker.get_global_rect()
	var wr: Rect2 = wheel.get_global_rect()
	var hr: Rect2 = hotbar.get_global_rect()
	var failed := false
	failed = _check(failed, "ticker_visible", ticker.visible) or failed
	failed = _check(failed, "ticker_z_gt_40", ticker.z_index > 40) or failed
	failed = _check(failed, "ticker_left_of_wheel", rail.end.x <= wr.position.x + 0.5) or failed
	failed = _check(failed, "ticker_no_wheel_overlap", not rail.intersects(wr)) or failed
	failed = _check(failed, "ticker_no_hotbar_overlap", not rail.intersects(hr)) or failed
	failed = _check(failed, "ticker_token_about_40", is_equal_approx(TICKER.TOKEN_PX, 40.0)) or failed
	## Vertical stack: height grows with tokens, width stays ~token+pad.
	failed = _check(failed, "ticker_narrow", rail.size.x < 80.0) or failed
	failed = _check(failed, "ticker_tall", rail.size.y > rail.size.x) or failed
	root_c.queue_free()
	await _settle()
	return failed


func _case_compact_inspect() -> bool:
	var root_c := Control.new()
	root_c.size = Vector2(1680, 1040)
	root.add_child(root_c)
	var tip: PanelContainer = HOVER.new()
	root_c.add_child(tip)
	tip.keyword_tips_enabled = false
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.7, 0.3, 1))
	var tex := ImageTexture.create_from_image(img)
	## Dark facing-callout look keys (same as main._monster_look).
	var look := {
		"fill": Color("2a1610"),
		"metal": Color("c08050"),
		"tier": 1,
		"scary": true,
		"rank": COPY.monster_rank_name(1),
		"hp_n": "4",
		"atk_n": "3",
		"call_chip": "TestCall",
		"call_color": Color("e8c36a"),
		"stat_style": 0,
	}
	tip.show_rule("Goblin", "", "", "Hits the seat across for 1.", "", tex, "monster", "goblin", look)
	await _settle()
	var sz: Vector2 = tip.get_combined_minimum_size()
	if tip.size.x > 1.0:
		sz = tip.size
	var failed := false
	failed = _check(failed, "compact_flag", bool(tip.get("_compact_monster"))) or failed
	failed = _check(failed, "inspect_v2_on_dark", bool(tip.get("_on_dark"))) or failed
	failed = _check(failed, "inspect_v2_w_le_280", sz.x <= HOVER.MONSTER_CARD_MAX_W + 0.5) or failed
	failed = _check(failed, "inspect_v2_w_lt_feel_b", sz.x < HOVER.FEEL_PASS_B_MONSTER_W) or failed
	## Must be clearly smaller than Feel pass B (#559) parchment card.
	failed = _check(failed, "inspect_v2_h_lt_feel_b", sz.y < HOVER.FEEL_PASS_B_MONSTER_TYPICAL_H) or failed
	failed = _check(
		failed,
		"inspect_v2_area_lt_feel_b",
		sz.x * sz.y < HOVER.FEEL_PASS_B_MONSTER_W * HOVER.FEEL_PASS_B_MONSTER_TYPICAL_H
	) or failed
	failed = _check(failed, "inspect_v2_h_lt_legacy", sz.y < HOVER.LEGACY_MONSTER_TYPICAL_H) or failed
	## No portrait / rank / HP-ATK badge children on the plate.
	failed = _check(failed, "no_portrait_visible", not _has_named_or_tex(tip, "portrait")) or failed
	failed = _check(failed, "no_rank_visible", not _has_rank_label(tip, str(look.get("rank", "")))) or failed
	failed = _check(failed, "no_stat_badges", not _has_stat_badge(tip)) or failed
	failed = _check(failed, "has_name", _has_named(tip, "InspectName")) or failed
	failed = _check(failed, "has_ability_pill", _has_named(tip, "InspectAbility")) or failed
	failed = _check(failed, "has_body", _has_named(tip, "InspectBody")) or failed
	## No flavor/hint child when hint was in look — Inspect v2 drops it.
	look["hint"] = "A leftover flavor line that must not show."
	tip.show_rule("Goblin", "", "", "Hits the seat across for 1.", "", tex, "monster", "goblin", look)
	await _settle()
	var found_hint := false
	for n in tip.get_children():
		if n is RichTextLabel and str((n as RichTextLabel).text).find("leftover flavor") >= 0:
			found_hint = true
		for c in n.get_children():
			if c is RichTextLabel and str((c as RichTextLabel).text).find("leftover flavor") >= 0:
				found_hint = true
	failed = _check(failed, "no_flavor_line", not found_hint) or failed
	## Item path still works and is not forced onto the dark compact plate.
	tip.show_rule("Boot", "2", "", "Kick them.", "", null, "item", "boot", {})
	await _settle()
	failed = _check(failed, "item_not_compact", not bool(tip.get("_compact_monster"))) or failed
	print("INSPECT_V2_SIZE %.1fx%.1f (Feel B was %.0fx%.0f)" % [
		sz.x, sz.y, HOVER.FEEL_PASS_B_MONSTER_W, HOVER.FEEL_PASS_B_MONSTER_TYPICAL_H,
	])
	root_c.queue_free()
	await _settle()
	return failed


func _has_named(root: Node, want: String) -> bool:
	if root.name == want:
		return true
	for c in root.get_children():
		if c == root.get("_kw_stack"):
			continue
		if _has_named(c, want):
			return true
	return false


func _has_named_or_tex(root: Node, _tag: String) -> bool:
	## Portrait would be a TextureRect under the old head row; Inspect v2 has only AbilityIcon.
	for c in root.get_children():
		if c == root.get("_kw_stack"):
			continue
		if c is TextureRect and str(c.name) != "AbilityIcon":
			if (c as TextureRect).visible and (c as TextureRect).texture != null:
				return true
		if _has_named_or_tex(c, _tag):
			return true
	return false


func _has_rank_label(root: Node, rank: String) -> bool:
	if rank.strip_edges() == "":
		return false
	if root is Label and str((root as Label).text).strip_edges() == rank.strip_edges():
		## Name label must not equal rank; InspectName holds the monster name.
		if str(root.name) == "InspectName":
			return false
		return (root as Label).visible
	for c in root.get_children():
		if c == root.get("_kw_stack"):
			continue
		if _has_rank_label(c, rank):
			return true
	return false


func _has_stat_badge(root: Node) -> bool:
	## WheelStatBadge is an inner class on hover_panel — detect via is_heart + num_text + style.
	for c in root.get_children():
		if c == root.get("_kw_stack"):
			continue
		if c is Control and c.get("is_heart") != null and c.get("num_text") != null and c.get("style") != null:
			if c.get_script() != null:
				return true
		if _has_stat_badge(c):
			return true
	return false


func _settle() -> void:
	await process_frame
	await process_frame
	await process_frame


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("PASS ", name)
		return failed
	print("FAIL ", name)
	return true
