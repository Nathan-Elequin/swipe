extends "res://scripts/core/fight_flow.gd"
## Core lane. Mill gate, take/leave, seat, bribe, starter kit.


func _draw_offer(kind: String) -> void:
	pending_monster.clear()
	pending_item.clear()
	if kind == "starter":
		var mid: String = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			_log("on_draft", "pool empty — enter")
			phase = "ready"
			_sort_hotbar()
			return
		pending_monster = _make_monster(mid)
		_stamp_pack(pending_monster, _pack_tier_for(mid, monsters_by_id, 1), "starter")
		if starter_items_left > 0:
			var iid: String = _next_starter_item()
			if iid != "":
				pending_item = _make_item(iid)
				_stamp_pack(pending_item, _pack_tier_for(iid, items_by_id, int(pending_monster.get("pack_tier", 1))), "starter")
		_log("on_draft", "%s  %s" % [PLAYER_COPY.tier_name(int(pending_monster.get("pack_tier", 1))), pending_monster.get("name", "?")])
		if not pending_item.is_empty():
			_log("on_draft", "pack item  %s" % pending_item.get("name", "?"))
		if sfx:
			sfx.play("book", -10.0)
		return
	var rolled: int = _pick_tier()
	var mid2: String = _take_card(monster_pool, monsters_by_id, "", rolled)
	if mid2 == "":
		_log("on_draft", "pool empty")
		return
	var pack_t: int = _pack_tier_for(mid2, monsters_by_id, rolled)
	pending_monster = _make_monster(mid2)
	_stamp_pack(pending_monster, pack_t, "draft")
	var iid2: String = _take_card(item_pool, items_by_id, "", pack_t)
	if iid2 != "":
		pending_item = _make_item(iid2)
		_stamp_pack(pending_item, pack_t, "draft")
	_log("on_draft", "%s lure" % PLAYER_COPY.tier_name(pack_t))
	if not pending_item.is_empty():
		_log("on_draft", "relic  %s" % pending_item.get("name", "?"))
	if sfx:
		sfx.play("book", -10.0)


func _offer_tex() -> Texture2D:
	if pending_item.is_empty():
		return tex_sword
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex(str(pending_item.get("card_id", "")))
	if tex == null:
		tex = tex_by_item.get(str(pending_item.get("card_id", "")), tex_sword)
	return tex


func _present_gate(passes: int) -> void:
	if draft_gate == null:
		return
	_offer_card = null
	draft_gate.present_mystery(pending_item, _pack_tier_now(), _offer_tex(), passes)
	if not pending_item.is_empty():
		var card: Control = _spawn_item_card(pending_item, false)
		card.picked.connect(func() -> void:
			if draft_action == "ask":
				_on_gate_send()
		)
		if card.has_method("set_draft_glow"):
			card.set_draft_glow(phase == "draft")
		if card.has_method("set_steal_cursor") and art != null:
			card.set_steal_cursor(art.ui.get("cursor_hand", null))
		if card.has_method("set_showcase"):
			card.set_showcase(false)
		if card.has_signal("passed_swipe"):
			card.passed_swipe.connect(func() -> void:
				if draft_action == "ask":
					_on_gate_refuse()
			)
		draft_gate.mount_relic(card)
		_offer_card = card
		_refresh_offer_card()
	if wheel_view:
		draft_gate.dock(wheel_view)


func _reveal_gate() -> void:
	if draft_gate == null:
		return
	var mrule: Dictionary = _monster_rule(pending_monster) if not pending_monster.is_empty() else {}
	draft_gate.reveal(pending_monster, str(mrule.get("value", "")), str(mrule.get("speech", "")), str(mrule.get("reminder", "")))


func _run_mill() -> void:
	var seq: int = _mill_seq
	_mill_beat = "watch"
	_refresh()
	await _seat_night_watch()
	if seq != _mill_seq:
		return
	_grant_starter_kit()
	_refresh()
	await get_tree().create_timer(0.4).timeout
	if seq != _mill_seq:
		return
	_open_petitioner()


func _seat_night_watch() -> void:
	var seq: int = _mill_seq
	for i in range(CARDINAL_SLOTS.size()):
		if seq != _mill_seq:
			return
		var si: int = int(CARDINAL_SLOTS[i])
		var mid: String = ""
		if adventure and dungeon_index > 1:
			mid = _take_monster_of_tier(int(adventure_seat_tiers[i]))
		else:
			mid = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			break
		_seat_opener(si, mid, "starter")
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play("drop", -10.0, 0.92 + float(si) * 0.02)
		await get_tree().create_timer(0.22).timeout
	starters_left = 0
	if adventure and dungeon_index > 1 and seq == _mill_seq:
		await _upgrade_two_openers()


func _seat_opener(si: int, mid: String, pack_kind: String) -> void:
	var m: Dictionary = _make_monster(mid)
	m["slot"] = SLOT_ORDER[si]
	m["spin_locked"] = false
	_stamp_pack(m, _pack_tier_for(mid, monsters_by_id, int(monsters_by_id.get(mid, {}).get("tier", 1))), pack_kind)
	wheel[si] = m
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	_sync_wheel_stats()


func _upgrade_two_openers() -> void:
	var seq: int = _mill_seq
	var can: Array = []
	for i in range(4):
		if int(adventure_seat_tiers[i]) < 3:
			can.append(i)
	if can.is_empty():
		return
	for n in range(can.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, n)
		var tmp: Variant = can[n]
		can[n] = can[j]
		can[j] = tmp
	var picks: Array = []
	for k in range(mini(2, can.size())):
		picks.append(int(can[k]))
	if in_tutorial and picks.size() >= 2:
		_tut_up_a = int(CARDINAL_SLOTS[int(picks[0])])
		_tut_up_b = int(CARDINAL_SLOTS[int(picks[1])])
	elif in_tutorial and picks.size() == 1:
		_tut_up_a = int(CARDINAL_SLOTS[int(picks[0])])
		_tut_up_b = _tut_up_a
	if speech_box and wheel_view and not picks.is_empty() and not in_tutorial:
		var talk_si: int = int(CARDINAL_SLOTS[int(picks[0])])
		speech_box.present(
			wheel_view.slice_portrait_global(talk_si),
			PLAYER_COPY.text("adventure.scarier", "The dungeon is getting more dangerous.")
		)
	_flash_screen(Color("3a1460"), 0.42)
	if sfx:
		sfx.play("whoosh", -8.0, 0.86)
		sfx.play("bong", -12.0, 0.7)
	await get_tree().create_timer(0.28).timeout
	if seq != _mill_seq:
		return
	for i in picks:
		if seq != _mill_seq:
			return
		var idx: int = int(i)
		var next_t: int = int(adventure_seat_tiers[idx]) + 1
		var nid: String = _take_monster_of_tier(next_t)
		if nid == "":
			continue
		var si: int = int(CARDINAL_SLOTS[idx])
		var old: Dictionary = wheel[si] if si < wheel.size() else {}
		var old_id: String = str(old.get("card_id", ""))
		if old_id != "":
			monster_pool.append(old_id)
		adventure_seat_tiers[idx] = next_t
		_seat_opener(si, nid, "starter")
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play("drop", -8.0, 0.8)
		await get_tree().create_timer(0.32).timeout
	if speech_box:
		await get_tree().create_timer(0.7).timeout
		if seq == _mill_seq:
			speech_box.hide_speech()


func _open_petitioner() -> void:
	if _empty_count() <= 0:
		_finish_mill()
		return
	_draw_offer("draft")
	if pending_monster.is_empty():
		_finish_mill()
		return
	draft_action = "ask"
	phase = "draft"
	_mill_beat = "gate"
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	_present_gate(refusals_left)
	if sfx:
		sfx.play("creak", -12.0)
		sfx.play("question", -10.0)
	_refresh()
	_idle_inspect()


func _finish_mill() -> void:
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	if draft_gate:
		draft_gate.hide_gate()
	_offer_card = null
	if speech_box:
		speech_box.hide_speech()
	pending_monster = {}
	pending_item = {}
	phase = "ready"
	draft_action = "place"
	_sort_hotbar()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_close", -10.0)
		sfx.play("confirm_big", -12.0)
	_refresh()
	_idle_inspect()
	if in_tutorial and tut != null and tut.wait == "mill_done":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


func _on_gate_send() -> void:
	if in_tutorial and tut != null and tut.wait != "gate_take" and tut.wait != "mill_done":
		return
	if draft_action != "ask" or pending_monster.is_empty():
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	_refresh()
	if sfx:
		sfx.play("metal_latch", -6.0)
		sfx.play("door_slam", -4.0, 0.92)
		sfx.play("whoosh", -12.0, 1.08)
	_flash_screen(Color("e8c36a"), 0.22)
	if _offer_card != null and is_instance_valid(_offer_card) and _offer_card.has_method("set_draft_glow"):
		_offer_card.set_draft_glow(false)
	if draft_gate:
		await draft_gate.play_slam(false)
	if seq != _mill_seq:
		return
	if sfx:
		sfx.play("door_open", -8.0, 1.05)
		sfx.play("bong", -10.0, 0.9)
	_reveal_gate()
	_refresh_gate_owner()
	_gate_line = ""
	_cube_line = ""
	_log("on_draft", "revealed  %s" % pending_monster.get("name", "?"))
	await get_tree().create_timer(0.7).timeout
	if seq != _mill_seq:
		return
	draft_action = "seat"
	if draft_gate:
		draft_gate.set_seat()
	_refresh_gate_owner()
	_refresh()
	_idle_inspect()
	if in_tutorial and tut != null and tut.wait == "gate_take":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


func _on_gate_refuse() -> void:
	if in_tutorial and tut != null and tut.wait != "mill_done":
		if tut:
			tut.nudge("Take this one. You can Leave it on the next visitors.")
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if draft_action != "ask":
		return
	if refusals_left <= 0:
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	refusals_left -= 1
	_refresh()
	if sfx:
		sfx.play("scratch", -10.0)
		sfx.play("switch", -14.0, 0.85)
	_log("on_bribe", "pass  %s" % pending_item.get("name", "relic"))
	if not pending_item.is_empty():
		_log("discard", str(pending_item.get("name", "?")))
	if draft_gate:
		await draft_gate.play_pass()
	if seq != _mill_seq:
		return
	pending_monster = {}
	pending_item = {}
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	if refusals_left <= 0:
		await _auto_fill_rest()
	else:
		_open_petitioner()


func _auto_fill_rest() -> void:
	var seq: int = _mill_seq
	_mill_beat = "force"
	draft_action = "busy"
	_refresh()
	if sfx:
		sfx.play("creak", -10.0, 0.8)
	while _empty_count() > 0:
		if seq != _mill_seq:
			return
		_draw_offer("draft")
		if pending_monster.is_empty():
			break
		var idx: int = _first_empty()
		if idx < 0:
			break
		_present_gate(0)
		if sfx:
			sfx.play("door_slam", -8.0, 1.12)
			sfx.play("metal_latch", -12.0)
		if draft_gate:
			await draft_gate.play_slam(true)
			_reveal_gate()
		if sfx:
			sfx.play("door_open", -12.0, 1.2)
		await get_tree().create_timer(0.12).timeout
		if seq != _mill_seq:
			return
		var from: Vector2 = draft_gate.actor_global() if draft_gate else Vector2.ZERO
		var tex: Texture2D = draft_gate.still_tex() if draft_gate else null
		if draft_gate:
			draft_gate.hide_actor()
		var dest: Vector2 = from
		if wheel_view:
			dest = wheel_view.slice_portrait_global(idx)
		await _fly_courier(tex, from, dest, 0.22)
		if seq != _mill_seq:
			return
		_commit_place(idx, false)
	_finish_mill()


func _seat_petitioner(index: int) -> void:
	if pending_monster.is_empty():
		return
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "empty":
		if sfx:
			sfx.play("error", -14.0)
		if wheel_view != null and wheel_view.has_method("shake_seat"):
			wheel_view.shake_seat(index)
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	_refresh()
	var from: Vector2 = get_global_mouse_position()
	var tex: Texture2D = null
	if draft_gate:
		from = draft_gate.actor_global()
		tex = draft_gate.still_tex()
		draft_gate.hide_actor()
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	var dest: Vector2 = from
	if wheel_view:
		dest = wheel_view.slice_portrait_global(index)
	await _fly_courier(tex, from, dest)
	if seq != _mill_seq:
		return
	var open_next: bool = true
	if in_tutorial and tut != null and tut.wait == "seat":
		open_next = false
	_commit_place(index, open_next)
	if in_tutorial and tut != null and tut.wait == "seat":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


func _on_place_mode() -> void:
	if phase != "draft" and phase != "starter":
		return
	draft_action = "place"
	if sfx:
		sfx.play("switch", -12.0)
	_refresh()


func _on_bribe_mode() -> void:
	if phase != "draft":
		return
	draft_action = "bribe"
	if sfx:
		sfx.play("switch", -12.0, 0.92)
	_refresh()


func _refresh_offer_card() -> void:
	if _offer_card == null or not is_instance_valid(_offer_card):
		_offer_card = null
		return
	if pending_item.is_empty():
		return
	var view: Dictionary = _item_view(pending_item)
	var rule: Dictionary = _item_rule(pending_item)
	if _offer_card.has_method("set_title"):
		_offer_card.set_title(_title_case(str(pending_item.get("name", "?"))))
	if _offer_card.has_method("set_rank"):
		_offer_card.set_rank("")
	if _offer_card.has_method("set_palette"):
		_offer_card.set_palette(view["fill"], view["rim"], _tier_of(pending_item))
	if _offer_card.has_method("set_live"):
		_offer_card.set_live(str(view["number"]), str(view.get("note", "")), true)
	if _offer_card.has_method("set_showcase"):
		_offer_card.set_showcase(true)
	if _offer_card.has_method("set_ability_bb"):
		_offer_card.set_ability_bb(_item_inspect_body(pending_item, rule))
	if _offer_card.has_method("set_stat_look"):
		var held: bool = _shift_held
		_shift_held = false
		_offer_card.set_stat_look(_item_inspect_look(pending_item))
		_shift_held = held
	if _offer_card.has_method("set_formula"):
		_offer_card.set_formula(str(rule.get("equation", "")))
		_offer_card.show_formula(_shift_held)


func _on_slice_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if _wheel_busy():
		return
	if not pending_mark.is_empty() and phase == "fighting":
		_apply_mark(index)
		return
	if phase == "devtest":
		_dev_click_slice(index)
		return
	if phase == "draft" and draft_action == "seat":
		_seat_petitioner(index)


func _on_slice_right_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		return
	_open_content_editor("monster", str(s.get("card_id", "")))


func _can_place() -> bool:
	return phase == "draft" and draft_action == "seat" and not pending_monster.is_empty()


func _commit_place(index: int, open_next: bool = true) -> void:
	if pending_monster.is_empty():
		return
	if str(wheel[index].get("kind", "")) != "empty":
		return
	var m: Dictionary = pending_monster.duplicate(true)
	m["slot"] = str(wheel[index].get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else ""))
	m["spin_locked"] = false
	wheel[index] = m
	if wheel_view:
		wheel_view.set_seat_fx({})
	_apply_preview({})
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	if sfx:
		sfx.play("drop", -8.0)
		sfx.play("confirm", -14.0, 1.08)
	if not pending_item.is_empty():
		hotbar.append(pending_item.duplicate(true))
		_log("on_place", "item  %s" % pending_item.get("name", "?"))
	pending_monster = {}
	pending_item = {}
	if draft_gate:
		draft_gate.hide_gate()
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.pulse_arrive(index)
	if not open_next:
		return
	if _empty_count() <= 0:
		_finish_mill()
	else:
		_open_petitioner()


func _place_on(index: int) -> void:
	_commit_place(index)


func _bribe_at(index: int) -> void:
	if str(wheel[index].get("kind", "")) != "monster":
		return
	var name: String = str(wheel[index].get("name", "?"))
	_log("on_bribe", "cut  %s" % name)
	if sfx:
		sfx.play("scratch", -8.0)
		sfx.play("creak", -12.0)
	if not pending_item.is_empty():
		_log("discard", str(pending_item.get("name", "?")))
	if not pending_monster.is_empty():
		_log("on_bribe", "skip  %s" % pending_monster.get("name", "?"))
	wheel.remove_at(index)
	_reseat_slots()
	pending_monster = {}
	pending_item = {}
	_sync_wheel_stats()
	drafts_left -= 1
	if drafts_left > 0:
		_draw_offer("draft")
	else:
		phase = "ready"
		_sort_hotbar()
		_log("on_draft", "enter")
	if _monsters_left() == 0 and phase == "ready":
		_enter_dungeon_clear()
	_refresh()


func _reseat_slots() -> void:
	for i in range(wheel.size()):
		if i < SLOT_ORDER.size():
			wheel[i]["slot"] = SLOT_ORDER[i]
		else:
			wheel[i]["slot"] = str(i)
