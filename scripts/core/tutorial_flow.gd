extends "res://scripts/core/run_flow.gd"
## Core lane. How to Play step orchestration. Talk-box look stays in UI scripts.


func _start_tutorial() -> void:
	_tut_boot = true
	in_tutorial = true
	_tut_inspect_page = -1
	_tut_mill_busy = false
	_tut_up_a = -1
	_tut_up_b = -1
	_reset_run()
	_tut_boot = false
	var seats: Array[String] = ["wizard", "golem", "goblin"]
	var slots: Array[int] = [0, 2, 4]
	for k in range(seats.size()):
		var m: Dictionary = _make_monster(seats[k])
		var si: int = slots[k]
		m["slot"] = SLOT_ORDER[si]
		m["spin_locked"] = false
		wheel[si] = m
		_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	for iid in ["sai", "helmet", "da_boot", "knucklers"]:
		hotbar.append(_make_item(iid))
		_log("on_place", "item  %s" % iid)
	_sort_hotbar()
	_sync_wheel_stats()
	phase = "ready"
	_log("on_click", "Tutorial")
	_log("var", "HP %s" % hp)
	if sfx:
		sfx.play("book", -10.0)
		sfx.play("door_open", -8.0)
	if tut:
		tut.open()
	_refresh()
	_tut_refresh_focus()


func _tut_on_continue() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "continue":
		return
	if _tut_mill_busy or not tut.armed():
		return
	if sfx:
		sfx.play("click", -12.0)
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tut_skip() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if draft_gate:
		draft_gate.hide_gate()
	if tut:
		tut.close()
	_reset_run()
	phase = "title"
	_refresh()


func _tut_finished() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if tut:
		tut.close()
	_refresh()


func _tut_auto_spin() -> void:
	if not in_tutorial or phase != "ready":
		return
	_on_spin()


func _tut_play_adventure() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if draft_gate:
		draft_gate.hide_gate()
	if tut:
		tut.close()
	_begin_adventure()


func _tut_mill_demo(kind: String) -> void:
	if not in_tutorial:
		return
	_tut_run_mill(kind)


func _tut_run_mill(kind: String) -> void:
	_tut_mill_busy = true
	match kind:
		"seat":
			await _tut_mill_seat()
		"upgrade":
			adventure = true
			dungeon_index = maxi(dungeon_index, 2)
			await _upgrade_two_openers()
			_tut_refresh_focus()
		"draft":
			if draft_action != "ask":
				_open_petitioner()
		"fill":
			if _empty_count() > 0 and pending_monster.is_empty():
				_open_petitioner()
	_tut_mill_busy = false
	_refresh()
	_tut_refresh_focus()


func _tut_mill_seat() -> void:
	adventure = true
	dungeon_index = 2
	adventure_seat_tiers = [1, 1, 1, 1]
	hp = HP_MAX
	blk = 0
	facing_index = -1
	_empty_wheel()
	phase = "draft"
	draft_action = "busy"
	_refresh()
	var seq: int = _mill_seq
	for i in range(CARDINAL_SLOTS.size()):
		if seq != _mill_seq or not in_tutorial:
			return
		var si: int = int(CARDINAL_SLOTS[i])
		var mid: String = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			mid = _take_monster_of_tier(1)
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
	_refresh()


func _tut_refresh_focus() -> void:
	if tut == null or not in_tutorial or not tut.visible:
		return
	if (tut.wait == "end" or tut.wait == "walk") and draft_gate:
		draft_gate.hide_gate()
	_tut_apply_wedges()
	var tag: String = tut.focus_tag
	if tut.wait == "seat" or tut.wait == "mill_done":
		tut.follow_many(_tut_empty_proxies())
		return
	if tag == "both_hp":
		tut.follow_many(_tut_both_hp())
		return
	if tag == "two_slices":
		tut.follow_many(_tut_two_slices())
		return
	if tag == "choice":
		tut.follow_many([_hotbar_card("da_boot"), btn_done])
		return
	if tag == "inspect" and int(tut._page_i) != _tut_inspect_page:
		_tut_inspect_page = int(tut._page_i)
		_tut_fill_inspect()
	tut.follow(_tut_focus())


func _tut_focus() -> Control:
	if tut == null:
		return null
	var tag: String = tut.focus_tag
	match tag:
		"wheel":
			return wheel_view
		"hearts":
			if hearts_box != null and hearts_box.visible:
				return hearts_box
			if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
				return wheel_view.hub_stat_proxy("hp")
			return wheel_view
		"block":
			if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
				return wheel_view.hub_stat_proxy("blk")
			return wheel_view
		"hotbar":
			return hotbar_box
		"empty_slice":
			if wheel_view != null and wheel_view.has_method("slice_focus_proxy"):
				return wheel_view.slice_focus_proxy(_first_empty_slice())
			return wheel_view
		"wizard_atk":
			return _tut_monster_stat("wizard", "atk")
		"wizard_hp":
			return _tut_monster_stat("wizard", "hp")
		"monster":
			return _tut_monster_slice("goblin")
		"inspect":
			return inspect
		"gate":
			return draft_gate
		"gate_take":
			if _offer_card != null and is_instance_valid(_offer_card):
				return _offer_card
			if draft_gate != null and draft_gate.has_method("relic_host"):
				return draft_gate.relic_host()
			return draft_gate
		"gate_leave":
			if draft_gate != null and draft_gate.has_method("leave_btn"):
				return draft_gate.leave_btn()
			return draft_gate
		"spin":
			return btn_spin
		"done":
			return btn_done
		"trophy":
			return trophy
		"face":
			return face_box
		_:
			if tag.begins_with("item:"):
				return _hotbar_card(tag.substr(5))
	return null


func _tut_fill_inspect() -> void:
	if facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("card_id", "")) == "goblin":
		_fill_inspect_from_slice(facing_index)
		return
	for it in hotbar:
		if str(it.get("card_id", "")) == "helmet" and not bool(it.get("spent", false)):
			_inspect_item(it, true)
			return
	if facing_index >= 0:
		_fill_inspect_from_slice(facing_index)


func _tut_monster_slice(id: String) -> Control:
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return wheel_view
	var i: int = _index_of_monster(id)
	if i < 0 and facing_index >= 0:
		i = facing_index
	return wheel_view.slice_focus_proxy(i)


func _tut_monster_stat(id: String, kind: String) -> Control:
	if wheel_view == null or not wheel_view.has_method("slice_stat_proxy"):
		return _tut_monster_slice(id)
	var i: int = _index_of_monster(id)
	if i < 0 and facing_index >= 0:
		i = facing_index
	return wheel_view.slice_stat_proxy(i, kind)


func _tut_both_hp() -> Array:
	var out: Array = []
	if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
		out.append(wheel_view.hub_stat_proxy("hp"))
	elif hearts_box != null:
		out.append(hearts_box)
	var g: Control = _tut_monster_stat("golem", "hp")
	if g != null:
		out.append(g)
	return out


func _tut_apply_wedges() -> void:
	if wheel_view == null:
		return
	var tag: String = tut.focus_tag if tut else ""
	var w: String = tut.wait if tut else ""
	var idx: Array = []
	if w == "seat" or w == "mill_done" or tag == "empty_slice":
		if w == "seat" or w == "mill_done":
			idx = _tut_empty_indices()
		else:
			idx = [_first_empty_slice()]
	elif tag == "two_slices":
		if _tut_up_a >= 0:
			idx.append(_tut_up_a)
		if _tut_up_b >= 0 and _tut_up_b != _tut_up_a:
			idx.append(_tut_up_b)
	elif tag == "monster":
		var g: int = _index_of_monster("goblin")
		if g < 0:
			g = facing_index
		if g >= 0:
			idx.append(g)
	wheel_view.tut_wedges = idx


func _tut_empty_indices() -> Array:
	var out: Array = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			out.append(i)
	return out


func _tut_empty_proxies() -> Array:
	var out: Array = []
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return [wheel_view]
	for i in _tut_empty_indices():
		out.append(wheel_view.slice_focus_proxy(int(i), str(i)))
	return out


func _tut_two_slices() -> Array:
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return [wheel_view]
	var a: int = _tut_up_a
	var b: int = _tut_up_b
	if a < 0 or b < 0:
		a = int(CARDINAL_SLOTS[0])
		b = int(CARDINAL_SLOTS[2])
	return [wheel_view.slice_focus_proxy(a, "A"), wheel_view.slice_focus_proxy(b, "B")]


func _tutorial_spin_index() -> int:
	if tut != null and str(tut.spin_id) != "":
		var want: int = _index_of_monster(str(tut.spin_id))
		if want >= 0:
			return want
	for id in ["wizard", "golem", "goblin"]:
		var i: int = _index_of_monster(id)
		if i >= 0:
			return i
	return -1


func _tut_can_done() -> bool:
	if tut == null:
		return false
	if tut.wait == "done" or tut.wait == "choice":
		return true
	return tut.wait == "continue" and tut.focus_tag == "done"


func _tutorial_allows_item(id: String) -> bool:
	if tut == null:
		return false
	var w: String = tut.wait
	if w == "choice":
		return id == "da_boot"
	if not w.begins_with("item:"):
		return false
	return w == "item:%s" % id


func _tutorial_item_used(id: String) -> void:
	if tut == null or not in_tutorial:
		return
	if tut.wait == "choice" and id == "da_boot":
		tut.set_choice("boot")
		return
	if tut.wait != "item:%s" % id:
		return
	if id == "sai" or id == "da_boot":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_combat_started() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "spin":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_after_fight() -> void:
	if not in_tutorial or tut == null:
		return
	var w: String = tut.wait
	if w != "item:sai" and w != "item:da_boot" and w != "done" and w != "choice":
		return
	if w == "choice" and str(tut.branch_pick) == "":
		tut.set_choice("take")
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_on_item_hover(id: String = "") -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_item":
		return
	if id != "" and id != "da_boot":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_on_slice_hover(index: int) -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_shift":
		return
	if not _shift_held:
		return
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_shift_tick() -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if not _shift_held:
		return
	if tut.wait == "hover_shift" and _hover_slice >= 0 and _hover_slice < wheel.size():
		if str(wheel[_hover_slice].get("kind", "")) == "monster":
			tut.advance()
			_tut_refresh_focus()
			_sync_buttons()
			return
	if tut.wait == "hover_item":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()
