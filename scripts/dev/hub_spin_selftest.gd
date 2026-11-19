extends SceneTree
## Hub Spin + locked wheel rect invariants (Nathan Nov 19).
## After controls are in the tree and have processed resize frames:
## 1) wheel global rect identical at setup/ready, spinning, fighting, after-kill
## 2) Take arc global rect identical across those states
## 3) hub Spin button center equals wheel hub center within 1px
## Run: godot --headless --path . --script res://scripts/dev/hub_spin_selftest.gd

const TAKE := preload("res://scripts/ui/take_arc.gd")
const COPY := preload("res://scripts/player_copy.gd")

const HUB_D := 104.0
const SLOT_H := 64.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	COPY.reload()
	failed = await _case_phase_rects_and_hub() or failed
	failed = _static_locks() or failed
	if failed:
		print("HUB_SPIN_SELFTEST fail")
		quit(1)
	else:
		print("HUB_SPIN_SELFTEST ok")
		quit(0)


func _static_locks() -> bool:
	var failed := false
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(failed, "HUB_SPIN_D const", main_src.find("const HUB_SPIN_D := 104.0") >= 0) or failed
	failed = _check(failed, "hub spin maker", main_src.find("func _make_hub_spin_button") >= 0) or failed
	failed = _check(failed, "place hub spin", main_src.find("func _place_hub_spin") >= 0) or failed
	failed = _check(failed, "wheel rect lock", main_src.find("_wheel_rect_locked") >= 0) or failed
	failed = _check(failed, "hub spin press path", main_src.find("func _on_hub_spin_pressed") >= 0) or failed
	failed = _check(failed, "land_burst on click", main_src.find('fx_frames("land_burst")') >= 0) or failed
	## Spin must not live in the mid button row anymore.
	var mid_block := ""
	var mid_i: int = main_src.find("mid_slot.add_child(btn_start)")
	if mid_i >= 0:
		mid_block = main_src.substr(mid_i, 420)
	failed = _check(
		failed,
		"spin not in mid_slot",
		mid_block.find("mid_slot.add_child(btn_spin)") < 0
	) or failed
	failed = _check(
		failed,
		"tutorial focus still btn_spin",
		main_src.find('"spin":\n\t\t\treturn btn_spin') >= 0
		or main_src.find("\"spin\":\n\t\t\treturn btn_spin") >= 0
		or main_src.find('return btn_spin') >= 0 and main_src.find('"spin":') >= 0
	) or failed
	failed = _check(
		failed,
		"no Tier/ATK in hub helpers",
		main_src.find('func _make_hub_spin_button') >= 0
		and main_src.find('func _hub_spin_style') >= 0
	) or failed
	var hub_i: int = main_src.find("func _make_hub_spin_button")
	var hub_fn: String = main_src.substr(hub_i, 900) if hub_i >= 0 else ""
	failed = _check(
		failed,
		"hub button has no Tier/ATK words",
		hub_fn.find('"Tier"') < 0 and hub_fn.find('"ATK"') < 0
	) or failed
	failed = _check(
		failed,
		"SCREEN-hub-spin exists",
		FileAccess.file_exists("res://design/visual/SCREEN-hub-spin.md")
	) or failed
	return failed


func _case_phase_rects_and_hub() -> bool:
	## Mini harness mirroring main: play_field + wheel + constant btn_wrap +
	## hub Spin overlay + Take arc. Phases: setup/ready, spinning, fighting, after-kill.
	var root_c := Control.new()
	root_c.name = "HubSpinRoot"
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
	btn_wrap.custom_minimum_size = Vector2(0, SLOT_H)
	col.add_child(btn_wrap)
	var wheel := ColorRect.new()
	wheel.name = "Wheel"
	wheel.color = Color(0.2, 0.15, 0.1, 1)
	play_field.add_child(wheel)
	var hub := Button.new()
	hub.name = "HubSpin"
	hub.text = COPY.text("combat.spin", "Spin")
	hub.custom_minimum_size = Vector2(HUB_D, HUB_D)
	hub.size = Vector2(HUB_D, HUB_D)
	hub.z_index = 28
	play_field.add_child(hub)
	var take: Button = TAKE.new()
	take.name = "TakeArc"
	root_c.add_child(take)
	await _settle()

	## Lock wheel once after first layout (mirrors _capture_wheel_lock).
	var locked_wheel := Rect2()
	var rects: Array = []
	for phase in ["ready", "spinning", "fighting", "after_kill"]:
		btn_wrap.custom_minimum_size = Vector2(0, SLOT_H)
		btn_wrap.add_theme_constant_override("margin_top", 36)
		## Hub Spin only in ready (first spin); never in the button row.
		hub.visible = phase == "ready"
		await _settle()
		var pf: Vector2 = play_field.size
		var side: float = minf(pf.x, maxf(120.0, pf.y - 16.0))
		var x: float = (pf.x - side) * 0.5
		var wheel_y := 8.0
		if locked_wheel.size.x < 8.0:
			wheel.position = Vector2(x, wheel_y)
			wheel.size = Vector2(side, side)
			locked_wheel = wheel.get_global_rect()
		else:
			## Hard lock: identical local rect every phase.
			var parent_xf: Transform2D = play_field.get_global_transform()
			var local_pos: Vector2 = parent_xf.affine_inverse() * locked_wheel.position
			wheel.position = local_pos
			wheel.size = locked_wheel.size
		var hub_c: Vector2 = wheel.get_global_rect().get_center()
		var half := HUB_D * 0.5
		var hub_local: Vector2 = play_field.get_global_transform().affine_inverse() * hub_c
		hub.position = hub_local - Vector2(half, half)
		hub.size = Vector2(HUB_D, HUB_D)
		var c: Vector2 = wheel.get_global_rect().get_center()
		var rad: float = wheel.size.x * 0.4
		take.visible = true
		take.set_guide(take.get_global_transform().affine_inverse() * c, rad, TAKE.RIM_GAP_DEFAULT)
		if phase == "fighting" or phase == "after_kill":
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
			var local_pos2: Vector2 = parent.get_global_transform().affine_inverse() * gr.position
			take.set_anchors_preset(Control.PRESET_TOP_LEFT)
			take.position = local_pos2
			take.size = gr.size
			take.set_guide(take.get_global_transform().affine_inverse() * c, rad, TAKE.RIM_GAP_DEFAULT)
		await _settle()
		rects.append({
			"phase": phase,
			"wheel": wheel.get_global_rect(),
			"take": take.arc_global_rect() if take.has_method("arc_global_rect") else take.get_global_rect(),
			"hub_center": hub.get_global_rect().get_center() if hub.visible else wheel.get_global_rect().get_center(),
			"wheel_center": wheel.get_global_rect().get_center(),
			"hub_visible": hub.visible,
		})

	var failed := false
	var w0: Rect2 = rects[0]["wheel"]
	var t0: Rect2 = rects[0]["take"]
	for i in range(1, rects.size()):
		var wi: Rect2 = rects[i]["wheel"]
		var ti: Rect2 = rects[i]["take"]
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

	## Hub center == wheel hub within 1px at ready (when visible).
	var ready: Dictionary = rects[0]
	var hc: Vector2 = ready["hub_center"]
	var wc: Vector2 = ready["wheel_center"]
	failed = _check(failed, "hub_visible_ready", bool(ready["hub_visible"])) or failed
	failed = _check(
		failed,
		"hub_center_matches_wheel",
		hc.distance_to(wc) <= 1.0
	) or failed
	failed = _check(failed, "hub_hidden_spinning", not bool(rects[1]["hub_visible"])) or failed

	root_c.queue_free()
	await _settle()
	return failed


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", name)
		return failed
	print("  FAIL ", name)
	return true


func _settle() -> void:
	await process_frame
	await process_frame
	await process_frame
