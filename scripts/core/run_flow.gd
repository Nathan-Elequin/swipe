extends "res://scripts/core/draft_flow.gd"
## Core lane. Title start, reset, adventure halls, pause mode routing.


func _on_new() -> void:
	if phase == "spinning":
		return
	if adventure:
		_begin_adventure()
	else:
		_begin_run()


func _on_overlay_primary() -> void:
	if phase == "title":
		_begin_run()
	elif adventure:
		_begin_adventure()
	else:
		_begin_run()


func _reset_run() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	adventure = false
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1]
	_adventure_busy = false
	if dungeon_bg:
		dungeon_bg.reset_hall()
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
	if speech_box:
		speech_box.hide_speech()
	if not _tut_boot:
		in_tutorial = false
		if tut:
			tut.close()
	if wheel_view != null:
		wheel_view.kill_spin()
	if sfx:
		sfx.play("confirm_big", -8.0)
		sfx.start_music()
	rng.randomize()
	hp = HP_MAX
	blk = 0
	facing_index = -1
	pending_choice.clear()
	pending_monster.clear()
	pending_item.clear()
	uid_seq = 0
	hotbar.clear()
	_hotbar_sig = ""
	_blk_shown = 0
	_ghost_blk = -1
	_ghost_hp = -1
	_hp_shown = HP_MAX
	_fly_card = null
	_inspect_pinned = false
	_cue_shown = ""
	_face_atk_shown = ""
	_face_hp_shown = ""
	_slain_shown = -1
	last_mob_hp = 3
	last_mob_atk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	last_blk_gain = 0
	last_item_copy = {}
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	beads_step = 1
	_reroll_skip = -1
	draft_action = "place"
	starters_left = STARTER_COUNT
	starter_items_left = STARTER_ITEM_COUNT
	smoke_given = false
	drafts_left = DRAFT_ROUNDS
	if log_label:
		log_label.clear()
	if combat_stage:
		combat_stage.hide_stage()
	_fill_pools()
	_empty_wheel()
	if dev_panel:
		dev_panel.visible = false


func _begin_run() -> void:
	_reset_run()
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Begin")
	_log("var", "HP %s" % hp)
	_log("on_draft", "The mill")
	_refresh()
	_run_mill()


func _begin_adventure() -> void:
	_reset_run()
	adventure = true
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Adventure Mode")
	_log("var", "HP %s" % hp)
	_log("on_draft", "Dungeon 1")
	_refresh()
	_run_mill()


func _enter_dungeon_clear() -> void:
	if sfx:
		sfx.set_combat_music(false)
		sfx.play("confirm_big", -6.0)
		sfx.duck_music(-2.0)
	_flash_screen(Color("e8c36a"), 0.28)
	if combat_stage:
		combat_stage.hide_stage()
	if in_tutorial or not adventure:
		phase = "victory"
		_log("end", "cleared")
		return
	dungeons_cleared += 1
	phase = "rest"
	_log("end", "dungeon %s" % dungeons_cleared)
	facing_index = -1


func _adventure_leave() -> void:
	if not adventure or phase != "rest":
		return
	phase = "victory"
	_log("end", "leave")
	_refresh()


func _adventure_continue() -> void:
	if not adventure or phase != "rest" or _adventure_busy:
		return
	_adventure_busy = true
	overlay.visible = false
	dungeon_index += 1
	phase = "draft"
	draft_action = "busy"
	_refresh()
	var seq: int = _mill_seq
	await _play_hall_wipe()
	if seq != _mill_seq or not adventure:
		_adventure_busy = false
		return
	_prep_next_dungeon()
	_log("on_draft", "Dungeon %s" % dungeon_index)
	_refresh()
	await _run_mill()
	_adventure_busy = false


func _prep_next_dungeon() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
	if speech_box:
		speech_box.hide_speech()
	if wheel_view != null:
		wheel_view.kill_spin()
	hp = HP_MAX
	blk = 0
	facing_index = -1
	pending_choice.clear()
	pending_monster.clear()
	pending_item.clear()
	_hotbar_sig = ""
	_blk_shown = 0
	_ghost_blk = -1
	_ghost_hp = -1
	_hp_shown = HP_MAX
	_cue_shown = ""
	_face_atk_shown = ""
	_face_hp_shown = ""
	_slain_shown = -1
	last_mob_hp = 3
	last_mob_atk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	last_blk_gain = 0
	last_item_copy = {}
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	beads_step = 1
	_reroll_skip = -1
	draft_action = "busy"
	starters_left = STARTER_COUNT
	starter_items_left = STARTER_ITEM_COUNT
	smoke_given = false
	drafts_left = DRAFT_ROUNDS
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		it["spent"] = false
		it["keep_after"] = false
		it["siphon_blk"] = 0
		if str(_ops_of(it).get("kind", "")) == "atk_alt_24":
			it["alt_n"] = 2
	if combat_stage:
		combat_stage.hide_stage()
	_fill_pools()
	_empty_wheel()


func _quick_start() -> void:
	_reset_run()
	phase = "ready"
	_log("on_click", "Dive In")
	_log("var", "HP %s" % hp)
	for i in range(mini(8, wheel.size())):
		var is_starter: bool = i < STARTER_COUNT
		var rarity: String = "starter" if is_starter else ""
		var rolled: int = 0 if is_starter else _pick_tier()
		var mid: String = _take_card(monster_pool, monsters_by_id, rarity, rolled)
		if mid == "":
			break
		var m: Dictionary = _make_monster(mid)
		m["slot"] = str(wheel[i].get("slot", SLOT_ORDER[i] if i < SLOT_ORDER.size() else ""))
		m["spin_locked"] = false
		var pack_t: int = _pack_tier_for(mid, monsters_by_id, 1 if is_starter else rolled)
		_stamp_pack(m, pack_t, "starter" if is_starter else "draft")
		wheel[i] = m
		_log("on_place", "%s → %s" % [m["name"], m["slot"]])
		var iid: String = ""
		if is_starter:
			if i < STARTER_ITEM_COUNT:
				iid = _next_starter_item()
		else:
			iid = _take_card(item_pool, items_by_id, "", pack_t)
		if iid != "":
			var item: Dictionary = _make_item(iid)
			_stamp_pack(item, _pack_tier_for(iid, items_by_id, pack_t), "starter" if is_starter else "draft")
			hotbar.append(item)
			_log("on_place", "item  %s" % item.get("name", iid))
	_sort_hotbar()
	_sync_wheel_stats()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_open", -8.0)
	_refresh()


func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_pause_mode(mode: String) -> void:
	match mode:
		"tutorial":
			_start_tutorial()
		"dive":
			_quick_start()
		"begin":
			_begin_run()
		"adventure":
			_begin_adventure()
		"new":
			_on_new()
		"dev":
			_open_dev_test()
		"roster":
			_open_roster()


func _on_script_saved() -> void:
	PLAYER_COPY.reload()
	if _copy_stamp:
		_copy_stamp.text = PLAYER_COPY.stamp()
	if settings_ui:
		settings_ui.apply_copy()
	_apply_overlay_copy()
	_refresh()
	_log("on_click", "Script saved")


func _on_content_saved(kind: String, card_id: String, board_card: Dictionary) -> void:
	_merge_catalog_card(kind, board_card)
	_write_catalog()
	_apply_live_card(kind, card_id, board_card)
	_log("on_click", "Saved %s" % board_card.get("name", card_id))
	_refresh()
	_refresh_offer_card()


func _on_roster_committed(items: Array, monsters: Array) -> void:
	for it in items:
		_merge_catalog_card("item", it)
	for m in monsters:
		_merge_catalog_card("monster", m)
	_write_catalog()
	for it2 in items:
		_apply_live_card("item", str(it2.get("id", "")), it2)
	for m2 in monsters:
		_apply_live_card("monster", str(m2.get("id", "")), m2)
	_log("on_click", "Roster saved")
	_refresh()
	_refresh_offer_card()
