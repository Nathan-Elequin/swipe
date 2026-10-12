extends "res://scripts/content/catalog_io.gd"
## Core lane. Fight resolution, item ops interpreter, monster specials, targeting.


func _store_last_faced_hp() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var face: Dictionary = wheel[facing_index]
	if str(face.get("kind", "")) != "monster":
		return
	last_mob_hp = maxi(int(face.get("hp", 3)), 0)


func _sync_wheel_stats() -> void:
	var n: int = wheel.size()
	for i in n:
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if bool(s.get("spin_locked", false)):
			var lid: String = str(s.get("card_id", ""))
			if _is_silenced(s):
				_apply_formulas_to(s)
				wheel[i] = s
			elif lid == "wick" and not _is_silenced(s):
				wheel[i] = s
			elif lid == "beggar" and not _is_silenced(s):
				s["atk"] = _leftmost_atk_n()
				wheel[i] = s
			elif lid == "ogre":
				wheel[i] = s
			continue
		_apply_formulas_to(s)
		wheel[i] = s
	_apply_wraith_pass()
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if bool(wheel[i].get("spin_locked", false)):
			continue
		wheel[i]["atk_before_late"] = int(wheel[i].get("atk", 0))
		wheel[i]["hp_before_late"] = int(wheel[i].get("hp", 0))
	var hp_bonus: Array[int] = []
	var atk_bonus: Array[int] = []
	hp_bonus.resize(n)
	atk_bonus.resize(n)
	hp_bonus.fill(0)
	atk_bonus.fill(0)
	for i in n:
		var id: String = str(wheel[i].get("card_id", ""))
		if id != "lich" and id != "commander":
			continue
		if _is_silenced(wheel[i]):
			continue
		var left_i: int = (i - 1 + n) % n
		var right_i: int = (i + 1) % n
		for j in [left_i, right_i]:
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			if id == "lich":
				hp_bonus[j] += 1
			else:
				atk_bonus[j] += 2
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if bool(wheel[i].get("spin_locked", false)):
			continue
		if hp_bonus[i] != 0 and not bool(wheel[i].get("hp_locked", false)):
			wheel[i]["hp"] = int(wheel[i]["hp"]) + hp_bonus[i]
			wheel[i]["hp_max"] = int(wheel[i]["hp_max"]) + hp_bonus[i]
		if atk_bonus[i] != 0:
			wheel[i]["atk"] = int(wheel[i]["atk"]) + atk_bonus[i]
	for i in n:
		if bool(wheel[i].get("atk_locked", false)):
			continue
		if _is_silenced(wheel[i]):
			continue
		if str(wheel[i].get("card_id", "")) == "slime_boss":
			wheel[i]["atk"] = int(wheel[i]["hp"])
		if str(wheel[i].get("card_id", "")) == "berserker" and not _is_silenced(wheel[i]):
			wheel[i]["rage_fire"] = (int(wheel[i].get("rage_step", 0)) % 3) == 2
	_mark_vars()


func _apply_wraith_pass() -> void:
	var n: int = wheel.size()
	for i in n:
		if str(wheel[i].get("card_id", "")) != "wraith":
			continue
		if _is_silenced(wheel[i]):
			continue
		if bool(wheel[i].get("spin_locked", false)):
			continue
		var best: int = int(wheel[i].get("atk", 0))
		var src: int = -1
		for off in [n - 1, 1]:
			var j: int = (i + off) % n
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			var their: int = int(wheel[j].get("atk", 0))
			if bool(wheel[j].get("spin_locked", false)) and wheel[j].has("atk_before_late"):
				their = int(wheel[j]["atk_before_late"])
			if their > best:
				best = their
				src = j
		wheel[i]["atk"] = best
		wheel[i]["copy_from"] = src


func _mark_vars() -> void:
	var n: int = wheel.size()
	var lich_touch: Dictionary = {}
	var cmd_touch: Dictionary = {}
	for i in n:
		var cid: String = str(wheel[i].get("card_id", ""))
		if cid == "lich" and not _is_silenced(wheel[i]):
			lich_touch[(i - 1 + n) % n] = true
			lich_touch[(i + 1) % n] = true
		elif cid == "commander" and not _is_silenced(wheel[i]):
			cmd_touch[(i - 1 + n) % n] = true
			cmd_touch[(i + 1) % n] = true
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var id: String = str(wheel[i].get("card_id", ""))
		wheel[i]["atk_variable"] = id == "dire_wolf" or id == "bandit" or id == "berserker" or id == "slime_boss" or id == "wraith" or cmd_touch.has(i)
		wheel[i]["hp_variable"] = id == "ogre" or id == "skeleton" or id == "leech_league" or lich_touch.has(i)
		wheel[i]["cmd_buff"] = cmd_touch.has(i)
		wheel[i]["lich_buff"] = lich_touch.has(i)
		if id != "wraith":
			wheel[i]["copy_from"] = -1


func _on_spin() -> void:
	if phase != "ready":
		return
	if in_tutorial and (tut == null or tut.wait != "spin"):
		return
	if facing_index >= 0:
		return
	var live: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "monster":
			live.append(i)
	if live.is_empty():
		_enter_dungeon_clear()
		_refresh()
		return
	var idx: int = live[rng.randi_range(0, live.size() - 1)]
	if in_tutorial:
		var forced: int = _tutorial_spin_index()
		if forced >= 0:
			idx = forced
	if _reroll_skip >= 0 and live.size() > 1:
		var filtered: Array[int] = []
		for i in live:
			if i != _reroll_skip:
				filtered.append(i)
		if not filtered.is_empty():
			idx = filtered[rng.randi_range(0, filtered.size() - 1)]
		_reroll_skip = -1
	phase = "spinning"
	pending_choice.clear()
	_refresh()
	_log("on_click", "Spin")
	if sfx:
		sfx.set_combat_music(true)
		sfx.play("door_open", -10.0)
		sfx.play("whoosh", -12.0, 0.9)
	await wheel_view.spin_to(idx)
	if phase != "spinning":
		return
	if sfx:
		sfx.play("door_close", -8.0)
		sfx.play("land", -14.0)
		sfx.play("bong", -16.0)
	facing_index = idx
	blk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	pending_feed = {}
	_cube_line = ""
	_clear_petrify()
	num_items_at_combat = hotbar.size()
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	_sync_wheel_stats()
	var m: Dictionary = wheel[facing_index]
	m["spin_locked"] = true
	wheel[facing_index] = m
	keep_blocked_this_fight = str(m.get("card_id", "")) == "basilisk" and not _is_silenced(m)
	phase = "fighting"
	_log("on_spin", str(m["name"]))
	_log("var", "enemy ATK %s   HP %s" % [m["atk"], m["hp"]])
	_log("var", "BLK 0")
	_log("var", "items this combat 0")
	if combat_stage:
		combat_stage.show_monster(str(m.get("card_id", "")))
	_refresh()
	if await _apply_siphon_jars():
		_store_last_faced_hp()
		return
	if await _apply_cursed_scrolls():
		_store_last_faced_hp()
		return
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		_store_last_faced_hp()
		_refresh()
		await _begin_slay()
		return
	if str(m.get("card_id", "")) == "gelatinous_cube":
		_cube_ask_feed()
		m = wheel[facing_index]
	if str(m.get("card_id", "")) == "gargoyle":
		_petrify_best_atk()
	if bool(m.get("poisoned", false)):
		_chip_hp(facing_index, 5)
		m = wheel[facing_index]
		_log("on_spin", "poison  →  %s HP" % m["hp"])
		if int(m["hp"]) <= 0 and not _wick_waiting(facing_index):
			_store_last_faced_hp()
			_refresh()
			await _begin_slay()
			return
	_refresh()
	_step_berserkers()
	_sync_wheel_stats()
	await _apply_queen_eggs_on_spin()
	if str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
		await _harpy_poke()
	_store_last_faced_hp()
	if in_tutorial and phase == "fighting":
		call_deferred("_tutorial_combat_started")


func _on_done() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _wheel_busy():
		return
	if in_tutorial and (tut == null or not _tut_can_done()):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_wait", "Not yet — finish what I said."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if not pending_chaos.is_empty() or not pending_mark.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		await _begin_slay()
		return
	if skip_swing_this_fight:
		_log("on_click", "Done")
		if sfx:
			sfx.play("click", -8.0)
		await _resolve_then_continue(true)
		return
	_log("on_click", "Done")
	if sfx:
		sfx.play("click", -8.0)
	await _resolve_then_continue(false)


func _begin_slay(_killed: bool = true) -> void:
	if _intent_simulating:
		_intent_mark_kill(facing_index)
		if facing_index >= 0 and facing_index < wheel.size():
			wheel[facing_index]["hp"] = 0
		return
	if await _try_commander_flee(facing_index):
		return
	await _exit_ended(false)


func _exit_ended(clockwork_split: bool = false) -> void:
	if _intent_simulating:
		_intent_mark_kill(facing_index)
		blk = 0
		return
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_ended_visuals()
	await _clear_after_fight(clockwork_split)
	_maybe_auto_spin()


func _exit_leave(clockwork_split: bool = true) -> void:
	if _intent_simulating:
		_intent_mark_kill(facing_index)
		blk = 0
		return
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_leave_visuals()
	await _clear_after_fight(clockwork_split)
	_maybe_auto_spin()


func _resolve_then_continue(skip_attack: bool) -> void:
	if phase != "fighting":
		return
	if skip_attack or (facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0):
		if await _try_commander_flee(facing_index):
			return
		if skip_attack:
			await _exit_leave(true)
		else:
			await _exit_ended(false)
		return
	var face_id: String = str(wheel[facing_index].get("card_id", "")) if facing_index >= 0 else ""
	if face_id == "two_headed_serpent" and not _is_silenced(wheel[facing_index]):
		await _damsel_resolve()
		return
	phase = "slaying"
	_refresh()
	var _taken: int = await _apply_resolve_hits()
	enemy_attacked = true
	if hp <= 0:
		_player_down()
		return
	if await _try_commander_flee(facing_index):
		return
	await _play_leave_visuals()
	await _clear_after_fight(true)
	_maybe_auto_spin()


func _apply_resolve_hits() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	var hits: int = _hit_count(facing_index)
	var total: int = 0
	for h in range(hits):
		if hp <= 0:
			break
		var incoming: int = 0
		if _intent_simulating:
			incoming = _apply_owner_swing(m)
		else:
			incoming = await _owner_attack(m, h + 1, hits)
		total += incoming
		if hp <= 0:
			break
		if hits > 1 and h < hits - 1 and not _intent_simulating:
			await get_tree().create_timer(0.16).timeout
	return total


## Owner Attacks you. Always lunges. Blocked vs unblocked only changes the tell.
## Returns HP lost on this swing.
func _owner_attack(m: Dictionary, hit_n: int = 1, _hit_total: int = 1) -> int:
	enemy_attacked = true
	if _intent_simulating:
		return _apply_owner_swing(m)
	if combat_stage and str(m.get("card_id", "")) != "spider_egg":
		await combat_stage.lunge()
	var pierce: bool = str(m.get("card_id", "")) == "dragon" and not _is_silenced(m)
	var swing: Dictionary = _swing(m, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	var hp_before: int = hp
	hp = maxi(0, hp - incoming)
	var lost: int = hp_before - hp
	if lost > 0:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(lost)
	if pierce:
		_log("on_resolve", "hit %s  ATK %s  (ignores BLK)" % [hit_n, m.get("atk", 0)])
	else:
		_log("on_resolve", "hit %s  ATK %s − BLK" % [hit_n, m.get("atk", 0)])
		_log("var", "BLK %s" % blk)
	if incoming > 0:
		_log("hp", "take %s  →  %s" % [incoming, hp])
		await _play_attack_connect()
	elif pierce:
		_log("hp", "take 0")
		_refresh_blk(false)
		if sfx:
			sfx.play("glass", -10.0)
	else:
		_log("hp", "take 0")
		await _play_attack_blocked()
	if hp <= 0:
		_try_potion()
	_sync_wheel_stats()
	return incoming


func _player_down() -> void:
	hp = 0
	if _intent_simulating:
		return
	var adventure_win: bool = adventure and dungeons_cleared >= 1
	phase = "victory" if adventure_win else "defeat"
	_log("end", "cleared" if adventure_win else "dead")
	_flash_screen(Color("e8c36a") if adventure_win else Color("c45c5c"), 0.28)
	if sfx:
		sfx.set_combat_music(false)
		if adventure_win:
			sfx.play("confirm_big", -6.0)
			sfx.duck_music(-2.0)
		else:
			sfx.play("error_big", -6.0)
			sfx.duck_music(-16.0)
	if combat_stage:
		combat_stage.hide_stage()
	_discard_spent_items()
	facing_index = -1
	_refresh()


func _clear_after_fight(clockwork_split: bool = false) -> void:
	if _intent_simulating:
		_intent_mark_kill(facing_index)
		blk = 0
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	var left_id: String = str(m.get("card_id", ""))
	_remove_crossbowed()
	if left_id == "mimic" and not enemy_attacked:
		await _draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	last_mob_atk = int(m.get("atk", 0))
	_remove_facing()
	if clockwork_split and left_id == "clockwork_knight" and not _is_silenced(m):
		_spawn_clockwork_heirs()
	_discard_spent_items()
	blk = 0
	mobs_defeated += 1
	_log("var", "BLK 0")
	_log("var", "defeated %s" % mobs_defeated)
	await _collapse_dead_wicks()
	await _slay_pending_ogres()
	_sync_wheel_stats()
	phase = "ready"
	if _monsters_left() == 0:
		if in_tutorial:
			if combat_stage:
				combat_stage.hide_stage()
			if sfx:
				sfx.set_combat_music(false)
		else:
			_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	if in_tutorial:
		call_deferred("_tutorial_after_fight")


func _maybe_auto_spin() -> void:
	if _intent_simulating:
		return
	if in_tutorial:
		return
	if phase != "ready":
		return
	if _monsters_left() <= 0:
		return
	await get_tree().create_timer(0.15).timeout
	if phase == "ready":
		_on_spin()


func _remove_facing() -> void:
	var m: Dictionary = wheel[facing_index]
	_log("on_remove_slice", str(m["name"]))
	wheel.remove_at(facing_index)
	facing_index = -1
	_reseat_slots()


func _discard_spent_items() -> void:
	var kept: Array = []
	for it in hotbar:
		if it["spent"] and not it["keep_after"]:
			_log("discard", str(it["name"]))
			continue
		if it["spent"] and it["keep_after"]:
			if keep_blocked_this_fight:
				_log("discard", str(it["name"]))
				continue
			if str(it.get("card_id", "")) == "breastplate" and not lost_hp_this_combat:
				_log("discard", str(it["name"]))
				continue
			it["spent"] = false
			it["keep_after"] = false
			_log("keep", str(it["name"]))
		kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _use_item(uid: int) -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _wheel_busy():
		return
	if not pending_chaos.is_empty():
		await _chaos_pick(uid)
		return
	var it: Dictionary = _find_item(uid)
	if it.is_empty() or it["spent"]:
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if bool(it.get("petrified", false)):
		_log("on_item_use", "petrified")
		if sfx:
			sfx.play("error", -10.0)
			sfx.play("metal_latch", -14.0)
		return
	if in_tutorial and not _tutorial_allows_item(str(it.get("card_id", ""))):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_item", "Not that one."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if sfx:
		sfx.play("select", -10.0)
	pending_mark.clear()
	_log("on_click", str(it["name"]))
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind == "passive":
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if kind == "choose":
		var opts: Variant = ops.get("options", [])
		if typeof(opts) != TYPE_ARRAY or (opts as Array).is_empty():
			opts = [
				{"id": "throw", "label": PLAYER_COPY.text("combat.knife_throw", "ATK 3, discard"), "atk": 3, "keep": false},
				{"id": "nick", "label": PLAYER_COPY.text("combat.knife_nick", "ATK 1, keep"), "atk": 1, "keep": true},
			]
		pending_choice = {"uid": uid, "options": opts}
		_log("on_item_use", "choose")
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "mark_poison" or kind == "mark_crossbow" or kind == "atk_neighbor" or kind == "hook_swap":
		if _mark_targets(kind).is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			return
		pending_mark = {"uid": uid, "kind": kind}
		_log("on_item_use", "pick a neighbor")
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "chaos_reroll":
		await _begin_chaos(uid)
		return
	await _apply_ops(it, ops, {})
	await _after_item_resolved(it)
	if in_tutorial:
		_tutorial_item_used(str(it.get("card_id", "")))
	call_deferred("_refresh")


func _choose_option(opt: Dictionary) -> void:
	var it: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
	pending_choice.clear()
	if it.is_empty():
		call_deferred("_refresh")
		return
	if int(opt.get("atk_drop", 0)) > 0:
		await _apply_ops(it, {"kind": "atk_drop", "n": int(opt.get("atk_drop", 0))}, opt)
	elif int(opt.get("blk", 0)) > 0:
		await _apply_ops(it, {"kind": "blk", "n": int(opt.get("blk", 0))}, opt)
	else:
		await _apply_ops(it, {"kind": "atk", "n": int(opt.get("atk", 0))}, opt)
	await _after_item_resolved(it)
	if sfx:
		sfx.play("click2", -8.0)
	call_deferred("_refresh")


func _apply_ops(it: Dictionary, ops: Dictionary, extra: Dictionary) -> void:
	var m: Dictionary = wheel[facing_index]
	var kind: String = str(ops.get("kind", ""))
	var view: Dictionary = _item_view(it)
	match kind:
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_from_atk":
			var n: int = int(view.get("n", ops.get("n", 0)))
			if kind == "blk_neighbor" and n < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(maxi(0, n))
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [maxi(0, n), blk])
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "atk_wheel", "atk_echo":
			var n2: int = int(ops["n"]) if ops.has("n") else int(view.get("n", 0))
			if kind == "atk_echo" and n2 <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "atk_strong_neighbor" and n2 < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			last_item_atk = n2
			if _deal_atk(n2):
				it["spent"] = true
				if extra.has("keep"):
					it["keep_after"] = bool(extra["keep"])
				if str(it.get("card_id", "")) == "echo_bell":
					it["keep_after"] = false
				_count_item_use()
				_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [n2, wheel[facing_index]["hp"]])
		"atk_cleave":
			if await _apply_cleave(int(ops.get("n", 2))):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
		"atk_opposite":
			var opp: int = _opposite_index()
			if opp < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			var n4: int = int(ops.get("n", 4))
			if _deal_atk_at(opp, n4):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  %s HP %s" % [n4, wheel[opp].get("name", "?"), wheel[opp].get("hp", 0)])
			it["spent"] = true
			_count_item_use()
			_toss_item(int(it["uid"]), false)
			_sync_wheel_stats()
			if opp >= 0 and opp < wheel.size() and int(wheel[opp].get("hp", 0)) <= 0:
				await _maybe_slay_down(opp)
			return
		"heal_kills":
			var flask_n: int = 1 + mobs_defeated
			_log("on_item_use", str(it["name"]))
			_heal(flask_n)
		"heal_full":
			_log("on_item_use", str(it["name"]))
			_heal(HP_MAX - hp)
		"egg_hurt":
			var egg_atk: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			var fake := {"card_id": "spider_egg", "atk": egg_atk, "name": str(it.get("name", "Spider Egg"))}
			await _owner_attack(fake)
			if hp <= 0:
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
		"blk_siphon":
			var n: int = int(it.get("siphon_blk", 0))
			if n <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(n)
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [n, blk])
		"smoke":
			it["spent"] = true
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_reroll_skip = facing_index
			if facing_index >= 0:
				wheel[facing_index]["spin_locked"] = false
			facing_index = -1
			keep_blocked_this_fight = false
			blk = 0
			pending_mark.clear()
			_toss_item(int(it["uid"]), false)
			_discard_spent_items()
			_sync_wheel_stats()
			phase = "ready"
			if combat_stage and not _intent_simulating:
				combat_stage.hide_stage()
			await _draw_unseen_item()
			if not _intent_simulating:
				call_deferred("_maybe_auto_spin")
			return
		"atk_zero":
			m["atk"] = 0
			m["atk_locked"] = true
			wheel[facing_index] = m
			_log("on_item_use", str(it["name"]))
			_log("atk", "facing ATK 0")
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"atk_drop":
			var drop: int = int(ops.get("n", 1))
			var now: int = int(m.get("atk", 0))
			m["atk"] = maxi(0, now - drop)
			m["atk_locked"] = true
			wheel[facing_index] = m
			_log("on_item_use", str(it["name"]))
			_log("atk", "facing ATK −%s  →  %s" % [drop, m["atk"]])
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"heal_keep":
			var lantern_n: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			_heal(lantern_n)
			it["keep_after"] = hp < HP_MAX
		"blk_last":
			if last_blk_gain <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(last_blk_gain)
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [last_blk_gain, blk])
		"quiet":
			var qid: String = str(m.get("card_id", ""))
			if not _has_unique_ability(qid) or _is_silenced(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			m["silenced"] = true
			wheel[facing_index] = m
			if qid == "basilisk":
				keep_blocked_this_fight = false
			_sync_wheel_stats()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "silenced %s" % qid)
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("pluck", -10.0, 0.85)
		"atk_spend_blk":
			var copy_blk: int = blk
			if copy_blk <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			last_item_atk = copy_blk
			it["keep_after"] = true
			_log("on_item_use", str(it["name"]))
			if _deal_atk(copy_blk):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), true)
				return
			_log("atk", "%s  →  enemy HP %s" % [copy_blk, wheel[facing_index]["hp"]])
		"atk_empty":
			var bead_n: int = beads_step
			last_item_atk = bead_n
			if _deal_atk(bead_n):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [bead_n, wheel[facing_index]["hp"]])
		"atk_hp_gap":
			var scythe_n: int = int(hp / 2)
			last_item_atk = scythe_n
			if _deal_atk(scythe_n):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [scythe_n, wheel[facing_index]["hp"]])
			_heal(scythe_n)
			if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) > 0:
				it["keep_after"] = true
		"defeat_only_item":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if _hand_has_atk_item(int(it.get("uid", -1))):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		"skip_swing":
			skip_swing_this_fight = true
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "skip swing")
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("pluck", -10.0, 0.85)
		"fangs":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			var stored: int = int(m.get("hp", 0))
			_log("on_item_use", str(it["name"]))
			await _owner_attack(m)
			if hp <= 0:
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				_player_down()
				return
			it["spent"] = true
			_count_item_use()
			_toss_item(int(it["uid"]), false)
			await _play_ended_visuals()
			_heal(stored)
			await _clear_after_fight(false)
			_maybe_auto_spin()
			return
		"defeat_hp":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if int(m["hp"]) >= hp:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		"defeat_atk":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if int(m["atk"]) < 5:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		_:
			return
	it["spent"] = true
	if extra.has("keep"):
		it["keep_after"] = bool(extra["keep"])
	elif kind == "blk_keep" or kind == "atk_spend_blk":
		it["keep_after"] = true
	if str(it.get("card_id", "")) == "echo_bell":
		it["keep_after"] = false
	_count_item_use()
	_sync_wheel_stats()
	_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0:
		if not _wick_waiting(facing_index):
			await _begin_slay()


func _toss_item(uid: int, keep: bool) -> void:
	if keep and _keep_blocked_now():
		keep = false
	if _intent_simulating:
		if not keep:
			_remove_item_now(uid)
		return
	for c in hotbar_box.get_children():
		if not c.has_method("toss"):
			continue
		if int(c.uid) != uid:
			continue
		if keep:
			c.bounce()
			if sfx:
				sfx.play("pluck", -10.0)
		else:
			c.toss()
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("whoosh", -16.0, 1.2)
		break
	if not keep:
		_remove_item_now(uid)


func _remove_item_now(uid: int) -> void:
	var kept: Array = []
	for it in hotbar:
		if int(it.get("uid", -1)) != uid:
			kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _defeat_blocked(m: Dictionary) -> bool:
	var id: String = str(m.get("card_id", ""))
	return id == "gargoyle" and not _is_silenced(m)


func _wick_waiting(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if str(wheel[index].get("card_id", "")) != "wick":
		return false
	if _is_silenced(wheel[index]):
		return false
	return int(wheel[index].get("hp", 0)) <= 0


func _twins_facing() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	return str(wheel[facing_index].get("card_id", "")) == "hollow" and not _is_silenced(wheel[facing_index])


func _twins_double_atk(index: int, n: int) -> bool:
	if n <= 0 or n % 2 != 0:
		return false
	if index < 0 or index >= wheel.size():
		return false
	return str(wheel[index].get("card_id", "")) == "hollow" and not _is_silenced(wheel[index])


func _twins_double_blk(n: int) -> bool:
	return n > 0 and n % 2 == 0 and _twins_facing()


func _chip_hp(index: int, n: int) -> void:
	if index < 0 or index >= wheel.size() or n <= 0:
		return
	var m: Dictionary = wheel[index]
	var drop: int = n
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m):
		drop = 1
	m["hp"] = maxi(0, int(m.get("hp", 0)) - drop)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m


func _collapse_dead_wicks() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if _wick_waiting(i) and i != facing_index:
			await _kill_neighbor(i)
		i -= 1


func _maybe_slay_down(index: int) -> void:
	if _intent_simulating:
		if index >= 0 and index < wheel.size() and int(wheel[index].get("hp", 0)) <= 0:
			_intent_mark_kill(index)
		return
	if index < 0 or index >= wheel.size():
		return
	if int(wheel[index].get("hp", 0)) > 0:
		return
	if _wick_waiting(index):
		return
	if index == facing_index:
		await _begin_slay()
	else:
		await _kill_neighbor(index)


func _chaos_candidates(stone_uid: int) -> Array:
	var out: Array = []
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if int(it.get("uid", -1)) == stone_uid:
			continue
		out.append(int(it.get("uid", -1)))
	return out


func _begin_chaos(uid: int) -> void:
	var cands: Array = _chaos_candidates(uid)
	if cands.is_empty():
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	pending_chaos = {
		"uid": uid,
		"picks": [],
		"need": mini(2, cands.size()),
	}
	_log("on_item_use", "pick items")
	if sfx:
		sfx.play("question", -10.0)
	call_deferred("_refresh")


func _chaos_pick(uid: int) -> void:
	var stone_uid: int = int(pending_chaos.get("uid", -1))
	if uid == stone_uid:
		pending_chaos.clear()
		_log("on_item_use", "cancel")
		call_deferred("_refresh")
		return
	var cands: Array = _chaos_candidates(stone_uid)
	if not cands.has(uid):
		if sfx:
			sfx.play("error", -10.0)
		return
	var picks: Array = pending_chaos.get("picks", [])
	if picks.has(uid):
		if sfx:
			sfx.play("error", -10.0)
		return
	picks.append(uid)
	pending_chaos["picks"] = picks
	if sfx:
		sfx.play("select", -10.0)
	if picks.size() < int(pending_chaos.get("need", 1)):
		call_deferred("_refresh")
		return
	await _finish_chaos()


func _finish_chaos() -> void:
	var stone: Dictionary = _find_item(int(pending_chaos.get("uid", -1)))
	var picks: Array = pending_chaos.get("picks", [])
	pending_chaos.clear()
	if stone.is_empty() or bool(stone.get("spent", false)):
		call_deferred("_refresh")
		return
	_flash_screen(Color("3a1460"), 0.42)
	if sfx:
		sfx.play("whoosh", -8.0, 0.86)
		sfx.play("bong", -12.0, 0.7)
	if get_tree():
		await get_tree().create_timer(0.28).timeout
	for uid_v in picks:
		await _reroll_item_same_tier(int(uid_v))
	stone["spent"] = true
	_count_item_use()
	_toss_item(int(stone["uid"]), false)
	_sort_hotbar()
	_log("on_item_use", str(stone.get("name", "Chaos Stone")))
	await _after_item_resolved(stone)
	call_deferred("_refresh")


func _reroll_item_same_tier(uid: int) -> void:
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	var tier: int = _tier_of(it)
	var pool: Array = []
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if _as_int(card.get("tier", 1), 1) != tier:
			continue
		pool.append(str(id))
	if pool.is_empty():
		return
	var nid: String = str(pool[rng.randi() % pool.size()])
	var fresh: Dictionary = _make_item(nid)
	var keep_uid: int = int(it.get("uid", uid))
	it.clear()
	for k in fresh.keys():
		it[k] = fresh[k]
	it["uid"] = keep_uid
	_hotbar_sig = ""
	if sfx:
		sfx.play("drop", -8.0, 0.8)
	for c in hotbar_box.get_children():
		if c.has_method("bounce") and int(c.uid) == keep_uid:
			c.bounce()
			break
	if get_tree():
		await get_tree().create_timer(0.32).timeout


func _keep_blocked_now() -> bool:
	if keep_blocked_this_fight:
		return true
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var id: String = str(wheel[facing_index].get("card_id", ""))
	return id == "basilisk" and not _is_silenced(wheel[facing_index])


func _gain_blk(n: int, skip_twins: bool = false) -> int:
	if n <= 0:
		if not _intent_simulating:
			_refresh_blk(false)
		return 0
	if not skip_twins and _twins_double_blk(n):
		var a: int = _gain_blk(n, true)
		var b: int = _gain_blk(n, true)
		return a + b
	last_blk_gain = n
	blk += n
	if _intent_simulating:
		return n
	_refresh_blk(true)
	_punch_blk()
	if sfx:
		sfx.play("block", -8.0)
		if n >= 4:
			sfx.play("block_heavy", -14.0)
	return n


func _heal(n: int) -> int:
	var before: int = hp
	hp = mini(HP_MAX, hp + maxi(0, n))
	var gained: int = hp - before
	_log("hp", "heal %s  →  %s" % [gained, hp])
	if _intent_simulating:
		if gained > 0:
			_sync_wheel_stats()
		return gained
	_refresh_hearts()
	if gained <= 0:
		return 0
	_sync_wheel_stats()
	_flash_screen(Color("8fd18f"), 0.28)
	if sfx:
		sfx.play("pluck", -8.0)
	_glow_hearts_heal()
	return gained


func _bleed(n: int) -> bool:
	if n <= 0:
		return false
	var before: int = hp
	hp = maxi(0, hp - n)
	if hp < before:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(before - hp)
	_log("hp", "bleed %s  →  %s" % [n, hp])
	if not _intent_simulating:
		_flash_screen(Color("5c1a6a"), 0.38)
		_refresh_hearts()
		_tint_hearts_bleed()
		if combat_stage:
			combat_stage.play_bleed()
		if sfx:
			sfx.play("bleed", -4.0)
			sfx.play("cloth", -14.0, 0.75)
	if not _intent_simulating and get_tree():
		await get_tree().create_timer(0.38).timeout
	_sync_wheel_stats()
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
	return false


func _remember_item_use(it: Dictionary) -> void:
	var snap: Dictionary = _item_snapshot(it)
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			snap = _item_snapshot(face) if face.has("uid") else face.duplicate(true)
			if not snap.has("ops"):
				snap = face.duplicate(true)
	if str(snap.get("card_id", "")) == "echo_bell" or snap.is_empty():
		return
	last_item_copy = snap.duplicate(true)
	for e in hotbar:
		if str(e.get("card_id", "")) != "echo_bell":
			continue
		if int(e.get("uid", -1)) == int(it.get("uid", -2)):
			continue
		e["echo_copy"] = last_item_copy.duplicate(true)


func _after_item_resolved(it: Dictionary) -> void:
	if it.is_empty() or not bool(it.get("spent", false)):
		return
	_remember_item_use(it)
	if phase != "fighting":
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		return
	var hid: String = str(wheel[facing_index].get("card_id", ""))
	if hid == "harpy" and not _is_silenced(wheel[facing_index]):
		if _intent_simulating:
			_owner_attack(wheel[facing_index])
		else:
			await _harpy_poke()


func _harpy_poke() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "harpy" or _is_silenced(m):
		return
	if int(m.get("hp", 0)) <= 0:
		return
	await _owner_attack(m)
	if hp <= 0:
		_player_down()


func _clear_petrify() -> void:
	for it in hotbar:
		it["petrified"] = false


func _petrify_best_atk() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or _is_silenced(wheel[facing_index]):
		return
	var best: int = -1
	var picks: Array = []
	for it in hotbar:
		var sc: int = _item_atk_score(it)
		if sc < 0:
			continue
		if sc > best:
			best = sc
			picks = [it]
		elif sc == best:
			picks.append(it)
	if picks.is_empty():
		_log("on_spin", "petrify none")
		return
	var pick: Dictionary = picks[rng.randi() % picks.size()]
	pick["petrified"] = true
	_log("on_spin", "petrify %s" % str(pick.get("name", "?")))
	if sfx:
		sfx.play("metal_latch", -8.0)
		sfx.play("cloth", -12.0)


func _cube_ask_feed() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or _is_silenced(wheel[facing_index]):
		return
	if hotbar.is_empty():
		_log("on_spin", "cube ate nothing")
		return
	var ids: Array = []
	for it in hotbar:
		ids.append(int(it.get("uid", -1)))
	ids.shuffle()
	var offer: Array = []
	offer.append(ids[0])
	if ids.size() >= 2:
		offer.append(ids[1])
	pending_feed = {"uids": offer}
	if offer.size() >= 2:
		_cube_line = ["Two snacks. Feed me one.", "I'm hungry. Pick one.", "Feed me. The other one can wait."][rng.randi() % 3]
	else:
		_cube_line = "That's all you've got. Feed me."
	_log("on_spin", "cube demands a feed")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play("cloth", -12.0)


func _feed_cube(uid: int) -> void:
	if pending_feed.is_empty():
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		return
	pending_feed = {}
	var it: Dictionary = _find_item(uid)
	_cube_line = ["Mmm. Thank you.", "Gone. Delicious.", "Thanks. I needed that."][rng.randi() % 3]
	_log("on_spin", "cube ate %s" % str(it.get("name", "?")))
	if sfx:
		sfx.play("cloth", -6.0)
		sfx.play("glass", -12.0, 0.8)
	_toss_item(uid, false)
	_refresh()


func _spawn_clockwork_heirs() -> void:
	var pool: Array = []
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		if _as_int(card.get("tier", 1), 1) != 2:
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		pool.append(str(id))
	if pool.is_empty():
		for id2 in monsters_by_id.keys():
			var c2: Dictionary = monsters_by_id[id2]
			if _as_int(c2.get("tier", 1), 1) == 2:
				pool.append(str(id2))
	if pool.is_empty():
		return
	for _i in 2:
		var pick: String = str(pool[rng.randi() % pool.size()])
		var heir: Dictionary = _make_monster(pick)
		heir["slot"] = ""
		wheel.append(heir)
		_log("on_place", "Clockwork left %s" % heir.get("name", pick))
	_reseat_slots()
	if sfx:
		sfx.play("drop", -8.0)
		sfx.play("metal_latch", -14.0)


func _count_item_use() -> void:
	items_used_this_combat += 1
	beads_step = (beads_step % 4) + 1
	_log("var", "items this combat %s" % items_used_this_combat)
	_flip_alt_sais()
	for i in wheel.size():
		if str(wheel[i].get("card_id", "")) != "wick":
			continue
		if _is_silenced(wheel[i]):
			continue
		wheel[i]["atk"] = int(wheel[i].get("atk", 0)) + 1
		wheel[i]["atk_locked"] = true
		_chip_hp(i, 1)
	_sync_wheel_stats()


func _deal_atk(n: int) -> bool:
	return _deal_atk_at(facing_index, n)


func _deal_atk_at(index: int, n: int, skip_twins: bool = false) -> bool:
	last_item_atk = n
	if index < 0 or index >= wheel.size():
		return false
	if not skip_twins and _twins_double_atk(index, n):
		if _deal_atk_at(index, n, true):
			return true
		if index < 0 or index >= wheel.size():
			return false
		return _deal_atk_at(index, n, true)
	var m: Dictionary = wheel[index]
	var hit_n: int = n
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m) and hit_n > 0:
		hit_n = 1
	var immune: bool = str(m.get("card_id", "")) == "goblin" and not _is_silenced(m)
	if immune or hit_n <= 0:
		if immune:
			_log("var", "no ATK dmg")
		else:
			_log("atk", "0  →  enemy HP %s" % m.get("hp", 0))
		if not _intent_simulating:
			if sfx:
				sfx.play("glass", -8.0, 0.85)
			if wheel_view:
				wheel_view.hit_feedback(index, 0, 0)
			if combat_stage and index == facing_index:
				combat_stage.take_hit()
		return false
	var before_hp: int = int(m.get("hp", 0))
	var before_atk: int = int(m.get("atk", 0))
	m["hp"] = maxi(0, before_hp - hit_n)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m
	if not _intent_simulating:
		if sfx:
			sfx.play("hit", -7.0, 0.94 + rng.randf() * 0.14)
			sfx.play("chop", -16.0)
		if wheel_view:
			wheel_view.hit_feedback(index, before_hp - int(m["hp"]), int(m["atk"]) - before_atk)
		if combat_stage and index == facing_index:
			combat_stage.take_hit()
	if str(m.get("card_id", "")) == "needleback" and not _is_silenced(m) and before_hp > 0:
		if _player_take_atk(1):
			return true
	return false


func _player_take_atk(n: int) -> bool:
	var dummy := {"atk": n, "card_id": ""}
	var swing: Dictionary = _swing(dummy, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	var hp_before: int = hp
	hp = maxi(0, hp - incoming)
	var lost: int = hp_before - hp
	if lost > 0:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(lost)
	if incoming == 0:
		_log("hp", "poke 0")
		if not _intent_simulating:
			_refresh_blk(false)
			if sfx:
				sfx.play("glass", -10.0)
	else:
		_log("hp", "poke %s  →  %s" % [incoming, hp])
		if not _intent_simulating:
			_flash_screen(Color("e07a7a"), 0.22)
			_refresh_hearts()
			_refresh_blk(false)
			if sfx:
				sfx.play("chop", -8.0)
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
	return false


func _apply_siphon_jars() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "grief_jar":
			continue
		if bool(it.get("spent", false)):
			continue
		it["siphon_blk"] = int(it.get("siphon_blk", 0)) + 2
		_log("var", "Grief Jar BLK %s" % it["siphon_blk"])
		if await _bleed(1):
			return true
	return false


func _apply_cursed_scrolls() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "cursed_scroll":
			continue
		if bool(it.get("spent", false)):
			continue
		_log("on_spin", "Cursed Scroll")
		if await _bleed(1):
			return true
	return false


func _opposite_index() -> int:
	var n: int = wheel.size()
	if n < 2 or n % 2 != 0 or facing_index < 0:
		return -1
	return (facing_index + (n >> 1)) % n


func _cleave_targets() -> Array[int]:
	var seen := {}
	var out: Array[int] = []
	if facing_index >= 0:
		seen[facing_index] = true
		out.append(facing_index)
	for j in _neighbor_indices():
		if seen.has(j):
			continue
		seen[j] = true
		out.append(j)
	return out


func _apply_cleave(n: int) -> bool:
	var targets: Array[int] = _cleave_targets()
	for t in targets:
		if t < 0 or t >= wheel.size():
			continue
		if _deal_atk_at(t, n):
			return true
		_log("atk", "%s  →  %s HP %s" % [n, wheel[t].get("name", "?"), wheel[t].get("hp", 0)])
	var dead: Array[int] = []
	for t in targets:
		if t == facing_index:
			continue
		if t >= 0 and t < wheel.size() and int(wheel[t].get("hp", 0)) <= 0:
			dead.append(t)
	dead.sort()
	dead.reverse()
	for t in dead:
		if t < 0 or t >= wheel.size() or t == facing_index:
			continue
		if int(wheel[t].get("hp", 0)) <= 0:
			if _intent_simulating:
				_intent_mark_kill(t)
			else:
				await _maybe_slay_down(t)
	return false


func _flip_alt_sais() -> void:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(_ops_of(it).get("kind", "")) != "atk_alt_24":
			continue
		var n: int = int(it.get("alt_n", 2))
		it["alt_n"] = 2 if n == 4 else 4


func _directed_neighbor_atk(ccw: bool) -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	var off: int = n - 1 if ccw else 1
	var j: int = (facing_index + off) % n
	if str(wheel[j].get("kind", "")) != "monster":
		return -1
	return int(wheel[j].get("atk", 0))


func _weakest_neighbor_atk() -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	var vals: Array[int] = []
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if str(wheel[j].get("kind", "")) == "monster":
			vals.append(int(wheel[j].get("atk", 0)))
	if vals.is_empty():
		return -1
	var best: int = vals[0]
	for v in vals:
		best = mini(best, v)
	return best


func _strongest_neighbor_atk() -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	var vals: Array[int] = []
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if str(wheel[j].get("kind", "")) == "monster":
			vals.append(int(wheel[j].get("atk", 0)))
	if vals.is_empty():
		return -1
	var best: int = vals[0]
	for v in vals:
		best = maxi(best, v)
	return best


func _neighbor_indices() -> Array[int]:
	var out: Array[int] = []
	if facing_index < 0:
		return out
	var n: int = wheel.size()
	if n < 2:
		return out
	var seen := {}
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if seen.has(j):
			continue
		seen[j] = true
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out


func _mark_targets(kind: String) -> Array[int]:
	var out: Array[int] = []
	for i in _neighbor_indices():
		if _can_mark(i, kind):
			out.append(i)
	return out


func _can_mark(index: int, kind: String) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if index == facing_index:
		return false
	if not _neighbor_indices().has(index):
		return false
	if str(wheel[index].get("kind", "")) != "monster":
		return false
	if kind == "mark_poison":
		return not bool(wheel[index].get("crossbowed", false))
	if kind == "mark_crossbow" or kind == "atk_neighbor":
		return int(wheel[index].get("hp", 0)) > 0
	if kind == "hook_swap":
		return int(wheel[index].get("hp", 0)) > 0
	return false


func _apply_mark(index: int) -> void:
	var kind: String = str(pending_mark.get("kind", ""))
	if not _can_mark(index, kind):
		if sfx:
			sfx.play("error", -10.0)
		return
	var it: Dictionary = _find_item(int(pending_mark.get("uid", -1)))
	pending_mark.clear()
	if it.is_empty() or bool(it.get("spent", false)):
		call_deferred("_refresh")
		return
	if kind == "hook_swap":
		var a: Dictionary = wheel[facing_index].duplicate(true)
		var b: Dictionary = wheel[index].duplicate(true)
		a["spin_locked"] = false
		b["spin_locked"] = true
		wheel[facing_index] = b
		wheel[index] = a
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		_log("on_item_use", "hook %s" % b.get("name", "?"))
		_sync_wheel_stats()
		await _draw_unseen_item()
		if combat_stage:
			combat_stage.show_monster(str(wheel[facing_index].get("card_id", "")))
		if sfx:
			sfx.play("whoosh", -8.0)
			sfx.play("click2", -8.0)
		await _after_item_resolved(it)
		call_deferred("_refresh")
		return
	if kind == "mark_poison":
		wheel[index]["poisoned"] = true
		_log("on_item_use", "poisoned %s" % wheel[index].get("name", "?"))
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		if sfx:
			sfx.play("click2", -8.0)
		_sync_wheel_stats()
		await _after_item_resolved(it)
		call_deferred("_refresh")
		return
	var n: int = 4
	var ops: Dictionary = _ops_of(it)
	if ops.has("n"):
		n = int(ops["n"])
	if _deal_atk_at(index, n):
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		await _after_item_resolved(it)
		return
	_log("on_item_use", "crossbow %s" % wheel[index].get("name", "?"))
	_log("atk", "%s  →  %s HP %s" % [n, wheel[index].get("name", "?"), wheel[index].get("hp", 0)])
	it["spent"] = true
	_count_item_use()
	_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()
	await _after_item_resolved(it)
	_refresh()
	if int(wheel[index].get("hp", 0)) <= 0:
		await _maybe_slay_down(index)


func _kill_neighbor(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if index == facing_index:
		return
	if await _try_commander_flee(index):
		return
	var pin: int = facing_index
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) == "mimic":
		await _draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		sfx.play("bong", -6.0)
		sfx.play("whoosh", -10.0, 1.15)
		sfx.play("scratch", -10.0, 0.85)
	if wheel_view:
		await wheel_view.play_slay(index)
		await wheel_view.collapse_slice(index, pin)
	_log("on_remove_slice", str(m.get("name", "?")))
	wheel.remove_at(index)
	mobs_defeated += 1
	if index < pin:
		facing_index -= 1
	_reseat_slots()
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.set_slices(wheel, facing_index, "none")
		await wheel_view.recenter_on(facing_index)
	_refresh()


func _hurt_ogres(lost: int) -> void:
	if lost <= 0:
		return
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "ogre":
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		if _is_silenced(s):
			continue
		var before: int = int(s.get("hp", 0))
		s["hp"] = maxi(0, before - lost)
		s["hp_locked"] = true
		if int(s["hp"]) <= 0 and i != facing_index:
			s["pending_slay"] = true
		wheel[i] = s
		if wheel_view:
			wheel_view.hit_feedback(i, before - int(s["hp"]), 0)
	_refresh()
	if phase != "fighting" and phase != "slaying":
		call_deferred("_slay_pending_ogres")


func _slay_pending_ogres() -> void:
	var idxs: Array[int] = []
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "ogre":
			continue
		if int(s.get("hp", 0)) > 0:
			continue
		if i == facing_index:
			continue
		idxs.append(i)
	idxs.reverse()
	for i in idxs:
		await _slay_ogre_at(i)


func _slay_ogre_at(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "ogre":
		return
	var title: String = str(s.get("call_name", "")).strip_edges()
	if title == "":
		title = str(s.get("ability", "")).strip_edges()
	if title != "":
		_flash_banner(title)
	_log("on_remove_slice", str(s.get("name", "Ogre")))
	if sfx:
		sfx.play("whoosh", -8.0, 1.1)
		sfx.play("scratch", -12.0, 0.9)
	if wheel_view:
		wheel_view.flash_slice(index)
		await wheel_view.play_slay(index)
		await wheel_view.collapse_slice(index, facing_index)
	if index == facing_index:
		facing_index = -1
	elif index < facing_index:
		facing_index -= 1
	wheel.remove_at(index)
	mobs_defeated += 1
	_reseat_slots()
	_refresh()


func _gain_blocked_now() -> bool:
	return _keep_blocked_now()


func _try_gain_item(id: String) -> void:
	if id == "":
		return
	var it: Dictionary = _make_item(id)
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	_refresh()
	if not _gain_blocked_now():
		if sfx:
			sfx.play("open", -10.0)
		return
	_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
	_log("discard", str(it.get("name", id)))
	if sfx:
		sfx.play("error", -10.0)
		sfx.play("cloth", -12.0)
	if get_tree():
		await get_tree().create_timer(0.45).timeout
	_toss_item(int(it.get("uid", -1)), false)
	_refresh()


func _shuffle_dungeon() -> void:
	var kept: Array = []
	for s in wheel:
		if str(s.get("kind", "")) == "monster":
			kept.append(s)
	for i in range(kept.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Dictionary = kept[i]
		kept[i] = kept[j]
		kept[j] = tmp
	wheel = kept
	_reseat_slots()


func _try_commander_flee(index: int) -> bool:
	if _intent_simulating:
		return false
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "commander":
		return false
	if _is_silenced(s):
		return false
	if bool(s.get("fled_once", false)):
		return false
	s["fled_once"] = true
	s["hp"] = maxi(1, int(s.get("hp_max", _card_base_hp("commander"))))
	s["hp_locked"] = false
	wheel[index] = s
	_log("on_resolve", "%s flees" % s.get("name", "Commander"))
	if sfx:
		sfx.play("whoosh", -8.0, 1.2)
		sfx.play("door_open", -12.0)
	pending_choice.clear()
	pending_mark.clear()
	pending_chaos.clear()
	pending_feed = {}
	if combat_stage:
		combat_stage.hide_stage()
	facing_index = -1
	phase = "ready"
	blk = 0
	_shuffle_dungeon()
	_sync_wheel_stats()
	_refresh()
	_maybe_auto_spin()
	return true


func _damsel_neighbors(index: int) -> Array[int]:
	var out: Array[int] = []
	var n: int = wheel.size()
	if n <= 0 or index < 0 or index >= n:
		return out
	for j in [(index - 1 + n) % n, (index + 1) % n]:
		if j == index:
			continue
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out


func _damsel_incoming() -> int:
	var left_blk: int = blk
	var total: int = 0
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		for _h in range(_hit_count(j)):
			var swing: Dictionary = _swing(nm, left_blk)
			total += int(swing["dmg"])
			left_blk = int(swing["blk"])
	return total


func _damsel_resolve() -> void:
	phase = "slaying"
	_refresh()
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		if combat_stage:
			combat_stage.show_monster(str(nm.get("card_id", "")))
		var hits: int = _hit_count(j)
		for h in range(hits):
			if hp <= 0:
				break
			await _owner_attack(nm, h + 1, hits)
			if hp <= 0:
				break
			if hits > 1 and h < hits - 1:
				await get_tree().create_timer(0.16).timeout
		if hp <= 0:
			_player_down()
			return
	if combat_stage:
		combat_stage.show_monster("two_headed_serpent")
	_heal(3)
	await _begin_slay()


func _step_berserkers() -> void:
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "berserker":
			continue
		if _is_silenced(wheel[i]):
			continue
		var old: int = int(wheel[i].get("rage_step", 0)) % 3
		var nxt: int = (old + 1) % 3
		wheel[i]["rage_step"] = nxt
		if nxt == 2 and sfx:
			sfx.play("error_big", -14.0, 1.35)
			sfx.play("chop", -12.0, 0.7)
		elif old == 2 and nxt == 0 and sfx:
			sfx.play("glass", -10.0, 0.8)
			sfx.play("cloth", -12.0)


func _apply_queen_eggs_on_spin() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var face_id: String = str(wheel[facing_index].get("card_id", ""))
	if face_id == "spider_queen" and not _is_silenced(wheel[facing_index]):
		var egg_uids: Array = []
		for it in hotbar:
			if str(it.get("card_id", "")) == "spider_egg" and not bool(it.get("spent", false)):
				egg_uids.append(int(it.get("uid", -1)))
		var bonus: int = egg_uids.size()
		for uid in egg_uids:
			_log("discard", "Spider Egg")
			_toss_item(int(uid), false)
		if bonus > 0:
			var q: Dictionary = wheel[facing_index]
			q["hp"] = int(q.get("hp", 0)) + 2 * bonus
			q["hp_max"] = int(q.get("hp_max", q["hp"])) + 2 * bonus
			q["atk"] = int(q.get("atk", 0)) + 2 * bonus
			q["hp_locked"] = true
			q["atk_locked"] = true
			wheel[facing_index] = q
			_log("var", "Queen +%s HP +%s ATK" % [2 * bonus, 2 * bonus])
			if sfx:
				sfx.play("cloth", -8.0, 0.7)
		_refresh()
		return
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "spider_queen":
			continue
		if _is_silenced(wheel[i]):
			continue
		if hotbar.size() >= HAND_MAX:
			break
		if wheel_view and wheel_view.has_method("flash_slice"):
			wheel_view.flash_slice(i)
		await _try_gain_item("spider_egg")
	_refresh()


func _remove_crossbowed() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and bool(wheel[i].get("crossbowed", false)) and str(wheel[i].get("kind", "")) == "monster":
			_log("on_remove_slice", str(wheel[i]["name"]))
			wheel.remove_at(i)
			mobs_defeated += 1
			if i < facing_index:
				facing_index -= 1
		i -= 1
	_reseat_slots()


func _draw_unseen_item() -> void:
	if _intent_simulating:
		return
	if item_pool.is_empty():
		return
	var id: String = _take_card(item_pool, items_by_id, "", 0)
	if id == "":
		return
	await _try_gain_item(id)


func _try_potion() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "healing_potion":
			continue
		if bool(it.get("spent", false)):
			continue
		it["spent"] = true
		it["keep_after"] = false
		_log("on_item_use", "Healing Potion")
		_heal(3)
		_toss_item(int(it["uid"]), false)
		return true
	return false


func _swing(m: Dictionary, block_left: int) -> Dictionary:
	var atk_n: int = int(m.get("atk", 0))
	if str(m.get("card_id", "")) == "dragon" and not _is_silenced(m):
		return {"dmg": maxi(0, atk_n), "blk": block_left}
	return {
		"dmg": maxi(0, atk_n - block_left),
		"blk": maxi(0, block_left - atk_n),
	}


func _incoming_total() -> int:
	if skip_swing_this_fight:
		return 0
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(m):
		return _damsel_incoming()
	var left: int = blk
	var total: int = 0
	for _h in range(_hit_count(facing_index)):
		var swing: Dictionary = _swing(m, left)
		total += int(swing["dmg"])
		left = int(swing["blk"])
	return total


func _hit_count(index: int) -> int:
	if index < 0 or index >= wheel.size():
		return 1
	var id: String = str(wheel[index].get("card_id", ""))
	if _is_silenced(wheel[index]):
		return 1
	if bool(wheel[index].get("swing_muted", false)):
		return 1
	if id == "hornet_swarm":
		return 2
	if id == "kobold_trapper":
		return 1 + items_used_this_combat
	return 1


func _queen_double(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var n: int = wheel.size()
	var qhp: int = int(wheel[index].get("hp", 0))
	for off in [n - 1, 1]:
		var j: int = (index + off) % n
		if str(wheel[j].get("kind", "")) == "monster" and int(wheel[j].get("hp", 0)) < qhp:
			return true
	return false


func _item_view(it: Dictionary) -> Dictionary:
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var fighting: bool = phase == "fighting" and facing_index >= 0
	var m: Dictionary = wheel[facing_index] if fighting else {}
	var fill := Color("5c2626")
	var rim := _tier_metal(_tier_of(it))
	var out := {
		"kind": "ATK",
		"number": "—",
		"note": "",
		"n": 0,
		"can_use": fighting,
		"fill": fill,
		"rim": rim,
		"tip": str(it.get("ability", "")),
	}
	match kind:
		"blk":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
		"choose":
			out["kind"] = "ATK"
			var drop_v := false
			var copts_v: Variant = ops.get("options", [])
			if typeof(copts_v) == TYPE_ARRAY:
				for ov in copts_v:
					if typeof(ov) == TYPE_DICTIONARY and (ov as Dictionary).has("atk_drop"):
						drop_v = true
						break
			if drop_v:
				out["number"] = "1–3"
				out["n"] = 0
			elif str(it.get("card_id", "")) == "spiked_shield":
				out["n"] = 2
				out["number"] = "2"
			else:
				out["n"] = 3
				out["number"] = "3"
			out["note"] = ""
		"atk_alt_24":
			out["n"] = int(it.get("alt_n", 2))
			if out["n"] != 2 and out["n"] != 4:
				out["n"] = 2
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_from_hp":
			out["kind"] = "BLK"
			out["n"] = maxi(0, 6 - hp)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_min_hp":
			out["kind"] = "BLK"
			out["n"] = mini(hp, int(m.get("hp", hp))) if fighting else hp
			out["number"] = str(out["n"])
			out["note"] = ""
		"defeat_hp":
			out["kind"] = "DEFEAT"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("hp", 99)) < hp
		"atk_7_hp":
			out["n"] = maxi(0, 7 - hp)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_neighbor":
			out["kind"] = "BLK"
			var ccw: bool = str(it.get("card_id", "")) != "left_bracer"
			var nb: int = _directed_neighbor_atk(ccw) if fighting else -1
			out["n"] = nb
			out["number"] = "—" if nb < 0 else str(nb)
			out["note"] = ""
			out["can_use"] = fighting and nb >= 0
		"atk_7_items":
			out["n"] = maxi(0, 8 - _live_item_count())
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_2_kills":
			out["n"] = 2 + mobs_defeated
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_hp_loss":
			out["n"] = 2 * hp_loss_events
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and int(out["n"]) > 0
		"defeat_atk":
			out["kind"] = "DEFEAT"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("atk", 0)) >= 5
		"atk_last":
			out["n"] = last_mob_atk
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_strong_neighbor":
			var nb2: int = _strongest_neighbor_atk() if fighting else -1
			out["n"] = nb2
			out["number"] = "—" if nb2 < 0 else str(nb2)
			out["note"] = ""
			out["can_use"] = fighting and nb2 >= 0
		"blk_keep":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
		"smoke":
			out["kind"] = "SMOKE"
			out["number"] = ""
			out["note"] = ""
		"fangs":
			out["kind"] = "FANGS"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _defeat_blocked(m)
		"mark_poison":
			out["kind"] = "MARK"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("mark_poison").is_empty()
		"atk_neighbor", "mark_crossbow":
			out["kind"] = "ATK"
			out["n"] = int(ops.get("n", 4))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("atk_neighbor").is_empty()
		"atk_cleave":
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"atk_opposite":
			out["n"] = int(ops.get("n", 4))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and _opposite_index() >= 0
		"atk_wheel":
			out["n"] = _monsters_left()
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"blk_from_atk":
			out["kind"] = "BLK"
			out["n"] = int(m.get("atk", 0)) if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"atk_zero":
			out["kind"] = "ATK"
			out["number"] = "0"
			out["n"] = 0
			out["note"] = ""
			out["can_use"] = fighting
		"atk_echo":
			out["n"] = last_item_atk
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_item_atk > 0
		"heal_keep":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"heal_full":
			out["kind"] = "HEAL"
			out["n"] = 6
			out["number"] = "6"
			out["note"] = ""
			out["can_use"] = fighting
		"egg_hurt":
			out["kind"] = "ATK"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"blk_last":
			out["kind"] = "BLK"
			out["n"] = last_blk_gain
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_blk_gain > 0
		"quiet":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and _has_unique_ability(str(m.get("card_id", ""))) and not _is_silenced(m)
		"atk_spend_blk":
			out["n"] = blk if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and blk > 0
		"atk_empty":
			out["n"] = beads_step
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"atk_hp_gap":
			out["n"] = int(hp / 2) if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"defeat_only_item":
			out["kind"] = "DEFEAT"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and not _hand_has_atk_item(int(it.get("uid", -1)))
		"chaos_reroll":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _chaos_candidates(int(it.get("uid", -1))).is_empty()
		"echo":
			out["kind"] = "ATK"
			out["number"] = ""
			out["can_use"] = false
		"skip_swing":
			out["kind"] = "SKIP"
			out["number"] = "Skip"
			out["note"] = ""
			out["can_use"] = fighting
		"heal_kills":
			out["kind"] = "HEAL"
			out["n"] = 1 + mobs_defeated
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"hook_swap":
			out["kind"] = "MARK"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("hook_swap").is_empty()
		"blk_siphon":
			out["kind"] = "BLK"
			out["n"] = int(it.get("siphon_blk", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["loss_icon"] = true
			out["can_use"] = fighting and int(it.get("siphon_blk", 0)) > 0
		"passive":
			out["kind"] = "PASSIVE"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = false
		_:
			out["can_use"] = false
	var tint: String = str(it.get("card_color", "")).strip_edges()
	if tint == "":
		var cat: Dictionary = items_by_id.get(str(it.get("card_id", "")), {})
		tint = str(cat.get("card_color", "")).strip_edges()
	var forced: Color = UX.card_color_fill(tint)
	if forced.a > 0.08:
		out["fill"] = forced
		var fam: String = UX.card_color_family(tint)
		if fam != "":
			out["kind"] = fam
	else:
		out["fill"] = _utility_fill(kind, str(out.get("kind", "ATK")))
	out["rim"] = rim
	if bool(out.get("loss_icon", false)):
		out["fill"] = Color(out["fill"]).lerp(Color(UX.HP), 0.38)
	if it.get("spent", false):
		out["can_use"] = false
	if bool(it.get("petrified", false)):
		out["can_use"] = false
	if not pending_feed.is_empty():
		out["can_use"] = false
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if face.is_empty():
			out["can_use"] = false
			out["kind"] = "PASSIVE"
			out["number"] = ""
		elif str(it.get("ops", {}).get("kind", "echo") if typeof(it.get("ops", {})) == TYPE_DICTIONARY else "echo") == "echo":
			pass
	if not pending_chaos.is_empty():
		var stone_uid: int = int(pending_chaos.get("uid", -1))
		var my_uid: int = int(it.get("uid", -1))
		if my_uid == stone_uid:
			out["can_use"] = true
		else:
			out["can_use"] = _chaos_candidates(stone_uid).has(my_uid)
	return out


func _sort_hotbar() -> void:
	hotbar.sort_custom(func(a, b) -> bool:
		return _item_rank(a) < _item_rank(b)
	)
	_hotbar_sig = ""


func _incoming_hit() -> int:
	return _incoming_total()


func _intent_mark_kill(index: int) -> void:
	if index < 0:
		return
	if not _intent_killed.has(index):
		_intent_killed.append(index)


func _intent_snapshot() -> Dictionary:
	var w: Array = []
	for s in wheel:
		if typeof(s) == TYPE_DICTIONARY:
			w.append((s as Dictionary).duplicate(true))
		else:
			w.append(s)
	var h: Array = []
	for it in hotbar:
		if typeof(it) == TYPE_DICTIONARY:
			h.append((it as Dictionary).duplicate(true))
		else:
			h.append(it)
	return {
		"hp": hp,
		"blk": blk,
		"wheel": w,
		"hotbar": h,
		"facing_index": facing_index,
		"phase": phase,
		"items_used_this_combat": items_used_this_combat,
		"beads_step": beads_step,
		"last_item_atk": last_item_atk,
		"last_blk_gain": last_blk_gain,
		"skip_swing_this_fight": skip_swing_this_fight,
		"keep_blocked_this_fight": keep_blocked_this_fight,
		"hp_loss_events": hp_loss_events,
		"lost_hp_this_combat": lost_hp_this_combat,
		"last_item_copy": last_item_copy.duplicate(true),
		"pending_mark": pending_mark.duplicate(true),
		"pending_choice": pending_choice.duplicate(true),
		"pending_chaos": pending_chaos.duplicate(true),
		"last_mob_atk": last_mob_atk,
		"last_mob_hp": last_mob_hp,
		"mobs_defeated": mobs_defeated,
		"enemy_attacked": enemy_attacked,
		"_reroll_skip": _reroll_skip,
		"refusals_left": refusals_left,
		"hotbar_sig": _hotbar_sig,
	}


func _intent_restore(s: Dictionary) -> void:
	hp = int(s.get("hp", hp))
	blk = int(s.get("blk", blk))
	wheel.clear()
	for row in s.get("wheel", []):
		if typeof(row) == TYPE_DICTIONARY:
			wheel.append((row as Dictionary).duplicate(true))
	hotbar.clear()
	for it in s.get("hotbar", []):
		if typeof(it) == TYPE_DICTIONARY:
			hotbar.append((it as Dictionary).duplicate(true))
	facing_index = int(s.get("facing_index", facing_index))
	phase = str(s.get("phase", phase))
	items_used_this_combat = int(s.get("items_used_this_combat", items_used_this_combat))
	beads_step = int(s.get("beads_step", beads_step))
	last_item_atk = int(s.get("last_item_atk", last_item_atk))
	last_blk_gain = int(s.get("last_blk_gain", last_blk_gain))
	skip_swing_this_fight = bool(s.get("skip_swing_this_fight", skip_swing_this_fight))
	keep_blocked_this_fight = bool(s.get("keep_blocked_this_fight", keep_blocked_this_fight))
	hp_loss_events = int(s.get("hp_loss_events", hp_loss_events))
	lost_hp_this_combat = bool(s.get("lost_hp_this_combat", lost_hp_this_combat))
	last_item_copy = (s.get("last_item_copy", {}) as Dictionary).duplicate(true)
	pending_mark = (s.get("pending_mark", {}) as Dictionary).duplicate(true)
	pending_choice = (s.get("pending_choice", {}) as Dictionary).duplicate(true)
	pending_chaos = (s.get("pending_chaos", {}) as Dictionary).duplicate(true)
	last_mob_atk = int(s.get("last_mob_atk", last_mob_atk))
	last_mob_hp = int(s.get("last_mob_hp", last_mob_hp))
	mobs_defeated = int(s.get("mobs_defeated", mobs_defeated))
	enemy_attacked = bool(s.get("enemy_attacked", enemy_attacked))
	_reroll_skip = int(s.get("_reroll_skip", _reroll_skip))
	refusals_left = int(s.get("refusals_left", refusals_left))
	_hotbar_sig = str(s.get("hotbar_sig", _hotbar_sig))
	_intent_killed.clear()


func _intent_diff(before: Dictionary, after: Dictionary) -> Dictionary:
	var wheel_p := {}
	var before_w: Array = before.get("wheel", [])
	var after_w: Array = after.get("wheel", [])
	var n: int = mini(before_w.size(), after_w.size())
	for i in n:
		if typeof(before_w[i]) != TYPE_DICTIONARY or typeof(after_w[i]) != TYPE_DICTIONARY:
			continue
		var b: Dictionary = before_w[i]
		var a: Dictionary = after_w[i]
		if str(b.get("kind", "")) != "monster" and str(a.get("kind", "")) != "monster":
			continue
		var row := {}
		var hp_d: int = int(a.get("hp", 0)) - int(b.get("hp", 0))
		var atk_d: int = int(a.get("atk", 0)) - int(b.get("atk", 0))
		if hp_d != 0:
			row["hp"] = hp_d
		if atk_d != 0:
			row["atk"] = atk_d
		if _intent_killed.has(i) or (int(a.get("hp", 1)) <= 0 and int(b.get("hp", 0)) > 0):
			row["kill"] = true
		if not row.is_empty():
			wheel_p[i] = row
	var items := {}
	var after_h: Array = after.get("hotbar", [])
	for it in after_h:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		var view: Dictionary = _item_view(it)
		items[uid] = str(view.get("number", ""))
	var out := {
		"hp": int(after.get("hp", hp)),
		"blk": int(after.get("blk", blk)),
		"refusals": int(after.get("refusals_left", refusals_left)),
		"wheel": wheel_p,
		"items": items,
	}
	if int(after.get("hp", hp)) == int(before.get("hp", hp)):
		out["hp"] = -1
	if int(after.get("blk", blk)) == int(before.get("blk", blk)):
		out["blk"] = -1
	if int(after.get("refusals_left", refusals_left)) == int(before.get("refusals_left", refusals_left)):
		out["refusals"] = -1
	return out


func _apply_owner_swing(m: Dictionary) -> int:
	var swing: Dictionary = _swing(m, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	var hp_before: int = hp
	hp = maxi(0, hp - incoming)
	var lost: int = hp_before - hp
	if lost > 0:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(lost)
	if hp <= 0:
		_try_potion()
	_sync_wheel_stats()
	return incoming


func _intent_mute() -> Variant:
	var saved = sfx
	sfx = null
	return saved


func _intent_unmute(saved) -> void:
	sfx = saved


func _simulate_item(it: Dictionary, extra: Dictionary = {}) -> Dictionary:
	if _intent_simulating or it.is_empty():
		return {}
	if phase != "fighting" or facing_index < 0:
		return {}
	var before: Dictionary = _intent_snapshot()
	var saved_sfx = _intent_mute()
	_intent_simulating = true
	_intent_killed.clear()
	var work: Dictionary = _find_item(int(it.get("uid", -1)))
	if work.is_empty():
		work = it
	var ops: Dictionary = _ops_of(work)
	var kind: String = str(ops.get("kind", ""))
	if kind == "choose" and extra.is_empty():
		var opts: Variant = ops.get("options", [])
		if typeof(opts) == TYPE_ARRAY and not (opts as Array).is_empty() and typeof(opts[0]) == TYPE_DICTIONARY:
			extra = opts[0]
	if kind == "choose":
		if int(extra.get("atk_drop", 0)) > 0:
			_apply_ops(work, {"kind": "atk_drop", "n": int(extra.get("atk_drop", 0))}, extra)
		elif int(extra.get("blk", 0)) > 0:
			_apply_ops(work, {"kind": "blk", "n": int(extra.get("blk", 0))}, extra)
		else:
			_apply_ops(work, {"kind": "atk", "n": int(extra.get("atk", 0))}, extra)
	elif kind == "mark_poison" or kind == "mark_crossbow" or kind == "atk_neighbor" or kind == "hook_swap" or kind == "chaos_reroll" or kind == "passive":
		pass
	else:
		_apply_ops(work, ops, extra)
	_after_item_resolved(work)
	_sync_wheel_stats()
	var after: Dictionary = _intent_snapshot()
	var diff: Dictionary = _intent_diff(before, after)
	_intent_restore(before)
	_intent_unmute(saved_sfx)
	_intent_simulating = false
	_intent_last = diff
	return diff


func _simulate_done() -> Dictionary:
	if _intent_simulating or phase != "fighting" or facing_index < 0:
		return {}
	var before: Dictionary = _intent_snapshot()
	var saved_sfx = _intent_mute()
	_intent_simulating = true
	_intent_killed.clear()
	if skip_swing_this_fight:
		_intent_mark_kill(facing_index)
		blk = 0
	else:
		_apply_resolve_hits()
		_intent_mark_kill(facing_index)
		blk = 0
	_sync_wheel_stats()
	var after: Dictionary = _intent_snapshot()
	var diff: Dictionary = _intent_diff(before, after)
	if facing_index >= 0:
		var w: Dictionary = diff.get("wheel", {})
		var row: Dictionary = w.get(facing_index, {})
		row["kill"] = true
		w[facing_index] = row
		diff["wheel"] = w
	_intent_restore(before)
	_intent_unmute(saved_sfx)
	_intent_simulating = false
	_intent_last = diff
	return diff


func _simulate_leave() -> Dictionary:
	if refusals_left <= 0:
		return {}
	return {"hp": -1, "blk": -1, "refusals": refusals_left - 1, "wheel": {}, "items": {}}


func _simulate_take_draft() -> Dictionary:
	if _intent_simulating or pending_item.is_empty():
		return {}
	var before: Dictionary = _intent_snapshot()
	var saved_sfx = _intent_mute()
	_intent_simulating = true
	var add: Dictionary = pending_item.duplicate(true)
	if not add.has("uid"):
		add["uid"] = -999
	hotbar.append(add)
	_sync_wheel_stats()
	var after: Dictionary = _intent_snapshot()
	var diff: Dictionary = _intent_diff(before, after)
	_intent_restore(before)
	_intent_unmute(saved_sfx)
	_intent_simulating = false
	_intent_last = diff
	return diff


func _simulate_mark(index: int) -> Dictionary:
	if _intent_simulating or pending_mark.is_empty():
		return {}
	var before: Dictionary = _intent_snapshot()
	var saved_sfx = _intent_mute()
	_intent_simulating = true
	_intent_killed.clear()
	_apply_mark(index)
	_sync_wheel_stats()
	var after: Dictionary = _intent_snapshot()
	var diff: Dictionary = _intent_diff(before, after)
	_intent_restore(before)
	_intent_unmute(saved_sfx)
	_intent_simulating = false
	_intent_last = diff
	return diff
