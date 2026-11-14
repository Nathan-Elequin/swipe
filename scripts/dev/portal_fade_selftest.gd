extends SceneTree
## Portal splash must not leave a full-screen black wipe or BiomeSplash covering the hall.
## Run: GODOT=~/godot/Godot_v4.7.2-stable_linux.x86_64 ./tools/qa/run_portal_fade.sh
##   or: godot --headless --path . --script res://scripts/dev/portal_fade_selftest.gd


const SHELL := preload("res://scripts/campaign_shell.gd")
const SEQ := preload("res://scripts/cabin/board_sequences.gd")
const SPLASH := preload("res://scripts/ui/biome_splash.gd")


func _init() -> void:
	var failed := false
	failed = await _test_named_fade_reuse() or failed
	failed = await _test_portal_leaves_hall_clear() or failed
	failed = await _test_no_orphan_wipe_after_land() or failed
	if failed:
		print("PORTAL_FADE_FAIL")
		quit(1)
	print("PORTAL_FADE_OK")
	quit(0)


func _test_named_fade_reuse() -> bool:
	var failed := false
	var host := Control.new()
	host.name = "CabinRoot"
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	var cabin = _CabinFadeHost.new()
	host.add_child(cabin)
	await process_frame
	var seq = SEQ.new()
	host.add_child(seq)
	seq.setup(cabin, null, null, null, null)
	seq.reduce_motion = false
	Engine.time_scale = 1.0
	var w1: ColorRect = seq._ensure_board_fade()
	var w2: ColorRect = seq._ensure_board_fade()
	failed = _check(failed, "fade.named", str(w1.name) == "BoardFadeWipe") or failed
	failed = _check(failed, "fade.reused", w1 == w2) or failed
	failed = _check(failed, "fade.under_cabin", w1.get_parent() == cabin) or failed
	await seq._fade(0.05, true)
	failed = _check(failed, "fade.to_black.visible", w1.visible and w1.modulate.a > 0.9) or failed
	await seq._fade(0.05, false)
	failed = _check(failed, "fade.out.hidden", not w1.visible or w1.modulate.a < 0.05) or failed
	## Second to_black must not spawn a second ColorRect.
	await seq._fade(0.05, true)
	var count := 0
	for c in cabin.get_children():
		if c is ColorRect and str(c.name) == "BoardFadeWipe":
			count += 1
		elif c is ColorRect and str(c.name).begins_with("@ColorRect"):
			count += 10
	failed = _check(failed, "fade.no_orphan", count == 1) or failed
	await seq._fade(0.05, false)
	Engine.time_scale = 1.0
	host.queue_free()
	await process_frame
	return failed


func _test_portal_leaves_hall_clear() -> bool:
	var failed := false
	var host := Control.new()
	host.name = "CabinRoot"
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	var cabin = load("res://scripts/dev/board_gates_cabin_shim.gd").new()
	host.add_child(cabin)
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var state: Dictionary = SHELL.fresh_state()
	state["migrated_board_v1"] = true
	_fill_stored(state, "b1", 5)
	cabin.bind(rules, state)
	await process_frame
	var seq = SEQ.new()
	host.add_child(seq)
	seq.reduce_motion = true
	Engine.time_scale = 8.0
	seq.setup(cabin, null, null, null, cabin)
	await seq.portal(0)
	await process_frame
	failed = _check(failed, "portal.opened_b2", SHELL.portal_opened(cabin._campaign_shell.state, "b2")) or failed
	failed = _scan_opaque_covers(failed, host, "after_portal") or failed
	Engine.time_scale = 1.0
	host.queue_free()
	await process_frame
	return failed


func _test_no_orphan_wipe_after_land() -> bool:
	var failed := false
	var host := Control.new()
	host.name = "CabinRoot"
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	var cabin = _CabinFadeHost.new()
	host.add_child(cabin)
	await process_frame
	var seq = SEQ.new()
	host.add_child(seq)
	seq.setup(cabin, null, null, null, null)
	seq.reduce_motion = false
	## Simulate the old bug: anonymous full-screen ColorRect left opaque.
	var orphan := ColorRect.new()
	orphan.color = Color("0B0706")
	orphan.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	orphan.size = Vector2(1680, 1040)
	orphan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	orphan.z_index = 200
	orphan.modulate.a = 1.0
	orphan.visible = true
	cabin.add_child(orphan)
	## Named wipe path must clear and stay clear after land; orphans get swept.
	await seq._fade(0.05, true)
	await seq._land_hall_after_splash(0, "b2")
	await process_frame
	var wipe_n: ColorRect = cabin.get_node("BoardFadeWipe") as ColorRect
	failed = _check(
		failed,
		"land.named_clear",
		wipe_n != null and (wipe_n.modulate.a < 0.05 or not wipe_n.visible)
	) or failed
	## BiomeSplash must not linger visible.
	var splash = SPLASH.new()
	cabin.add_child(splash)
	splash.visible = true
	seq._hide_biome_splash()
	await process_frame
	var splash_left := cabin.get_node_or_null("BiomeSplash")
	failed = _check(
		failed,
		"land.splash_gone",
		splash_left == null or not splash_left.visible
	) or failed
	failed = _scan_opaque_covers(failed, host, "after_land") or failed
	host.queue_free()
	await process_frame
	return failed


func _scan_opaque_covers(failed: bool, host: Node, label: String) -> bool:
	var bad: Array = []
	_collect_opaque(host, bad)
	var ok := bad.is_empty()
	if not ok:
		print("FAIL opaque_covers.", label, " → ", bad)
	else:
		print("OK opaque_covers.", label)
	return failed or not ok


func _collect_opaque(n: Node, out: Array) -> void:
	if n == null or not is_instance_valid(n):
		return
	if n is ColorRect:
		var cr := n as ColorRect
		if cr.visible and cr.modulate.a > 0.05 and _looks_fullscreen(cr):
			## CabinRoot plate itself can be black at z95 in live game; ignore zero-size / unnamed cabin plate only if alpha on color.
			if cr.modulate.a > 0.05 and (cr.color.a > 0.5 or cr.modulate.a > 0.5):
				if str(cr.name) == "BoardFadeWipe" or str(cr.name).begins_with("@ColorRect") or cr.z_index >= 100:
					out.append("%s a=%.2f z=%d" % [cr.get_path(), cr.modulate.a, cr.z_index])
	if n is CanvasLayer:
		var cl := n as CanvasLayer
		if cl.visible and str(cl.name) == "BiomeSplash":
			out.append("%s (BiomeSplash visible)" % cl.get_path())
	for c in n.get_children():
		_collect_opaque(c, out)


func _looks_fullscreen(cr: ColorRect) -> bool:
	var s: Vector2 = cr.size
	if s.x >= 1600.0 and s.y >= 1000.0:
		return true
	## Anchored full-rect often reports size 0 until in tree layout — treat named wipe as full.
	return str(cr.name) == "BoardFadeWipe" or str(cr.name).begins_with("@ColorRect")


func _fill_stored(state: Dictionary, pool: String, n: int) -> void:
	var banked: Dictionary = state.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
		state["banked"] = banked
	for i in n:
		banked["%s_fill_%d" % [pool, i]] = pool


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("OK ", label)
		return failed
	print("FAIL ", label)
	return true


class _CabinFadeHost extends Node:
	var items_by_id: Dictionary = {}
	var _campaign_shell = null
	var _rules: Dictionary = {}
	var sfx = null
	var hero_name := "Sprout"
	var _current_room := "hall"
	var _int_root: Control = null

	func _ready() -> void:
		_int_root = Control.new()
		_int_root.name = "RoomsClip"
		_int_root.visible = true
		add_child(_int_root)
		_ensure_fade()

	func _ensure_fade() -> ColorRect:
		var wipe = get_node_or_null("BoardFadeWipe")
		if wipe is ColorRect:
			return wipe as ColorRect
		wipe = ColorRect.new()
		wipe.name = "BoardFadeWipe"
		wipe.color = Color("0B0706")
		wipe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wipe.size = Vector2(1680, 1040)
		wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wipe.z_index = 200
		wipe.visible = false
		wipe.modulate.a = 0.0
		add_child(wipe)
		return wipe as ColorRect

	func hide_cabin_dev_strip() -> void:
		pass

	func show_menu(room: String = "hall") -> void:
		_current_room = room

	func pan_to(room: String) -> void:
		_current_room = room

	func bind(rules: Dictionary, state: Dictionary) -> void:
		_rules = rules
		_campaign_shell = load("res://scripts/campaign_shell.gd").new()
		_campaign_shell.rules = rules
		_campaign_shell.state = state

	func _biome_rules() -> Dictionary:
		return _rules

	func _campaign_shell_state() -> Dictionary:
		if _campaign_shell != null:
			return _campaign_shell.state
		return {}
