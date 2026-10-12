extends "res://scripts/content/content_defs.gd"
## Content lane. Catalog/runtime load, card factories, formulas, tier/pool helpers.


func _load_catalog() -> void:
	var f := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing catalog: %s" % CATALOG_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("catalog.json did not parse")
		return
	catalog = parsed
	for m in catalog.get("monsters", []):
		monsters_by_id[str(m["id"])] = m
	for it in catalog.get("items", []):
		items_by_id[str(it["id"])] = it


func _load_runtime() -> void:
	var f := FileAccess.open(RUNTIME_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing runtime: %s" % RUNTIME_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		runtime = parsed


func _fill_pools() -> void:
	monster_pool.clear()
	item_pool.clear()
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		for _c in range(int(card.get("count", 1))):
			monster_pool.append(str(id))
	for id in runtime.get("items", []):
		var card2: Dictionary = items_by_id.get(str(id), {})
		if card2.is_empty():
			continue
		var flags: Dictionary = card2.get("flags", {}) if typeof(card2.get("flags", {})) == TYPE_DICTIONARY else {}
		if bool(flags.get("hide", false)):
			continue
		var copies: int = int(card2.get("count", 1))
		if copies <= 0:
			continue
		for _c2 in range(copies):
			item_pool.append(str(id))


func _pick_tier() -> int:
	var r: float = rng.randf()
	if r < 0.4:
		return 1
	if r < 0.75:
		return 2
	return 3


func _take_id(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	var matches: Array = []
	for id in pool:
		var card: Dictionary = by_id.get(str(id), {})
		if card.is_empty():
			continue
		if rarity != "" and str(card.get("rarity", "")) != rarity:
			continue
		if tier > 0 and int(card.get("tier", 0)) != tier:
			continue
		matches.append(str(id))
	if matches.is_empty():
		return ""
	var pick: String = str(matches[rng.randi_range(0, matches.size() - 1)])
	pool.erase(pick)
	return pick


func _take_card(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	var id: String = _take_id(pool, by_id, rarity, tier)
	if id == "":
		id = _take_id(pool, by_id, rarity, 0)
	if id == "":
		id = _take_id(pool, by_id, "", 0)
	return id


func _pack_tier_for(id: String, by_id: Dictionary, fallback: int) -> int:
	var t: int = int(by_id.get(id, {}).get("tier", 0))
	if t < 1:
		return fallback
	return t


func _stamp_pack(d: Dictionary, tier: int, kind: String) -> void:
	var t: int = tier
	if t < 1:
		t = int(d.get("pack_tier", 0))
	if t < 1:
		t = 1
	d["pack_tier"] = t
	d["pack_kind"] = kind


func _rank_label(d: Dictionary) -> String:
	var t: int = int(d.get("pack_tier", 0))
	if t < 1:
		t = int(d.get("tier", 0))
	if t >= 1:
		return PLAYER_COPY.tier_name(t)
	return ""


func _tier_of(d: Dictionary) -> int:
	var t: int = int(d.get("pack_tier", 0))
	if t < 1:
		t = int(d.get("tier", 0))
	return maxi(1, t)


func _next_starter_item() -> String:
	if starter_items_left <= 0:
		return ""
	starter_items_left -= 1
	if not smoke_given:
		smoke_given = true
		if item_pool.has("smoke_bomb"):
			item_pool.erase("smoke_bomb")
		return "smoke_bomb"
	return _take_card(item_pool, items_by_id, "starter", 0)


func _pack_tier_now() -> int:
	if not pending_monster.is_empty():
		return _tier_of(pending_monster)
	if not pending_item.is_empty():
		return _tier_of(pending_item)
	return 1


func _take_monster_of_tier(tier: int) -> String:
	var t: int = maxi(1, mini(3, tier))
	var id: String = _take_id(monster_pool, monsters_by_id, "", t)
	if id == "":
		id = _take_card(monster_pool, monsters_by_id, "", t)
	return id


func _grant_starter_kit() -> void:
	while starter_items_left > 0:
		var iid: String = _next_starter_item()
		if iid == "":
			break
		hotbar.append(_make_item(iid))
		var iname: String = str(items_by_id.get(iid, {}).get("name", iid))
		_log("on_place", "item  %s" % iname)
	_sort_hotbar()
	if sfx:
		sfx.play("cloth", -10.0)
		sfx.play("confirm", -14.0)


func _make_monster(id: String) -> Dictionary:
	var card: Dictionary = monsters_by_id[id]
	var spec: Dictionary = MONSTER_SPECIAL.get(id, {})
	var s := {
		"kind": "monster",
		"slot": "",
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"special_id": str(spec.get("id", "")),
		"special_text": str(spec.get("text", card.get("ability", ""))),
		"call_name": MONSTER_LINES.call_of(id, card),
		"reminder": MONSTER_LINES.reminder_of(id, card),
		"atk": _card_base_atk(id),
		"hp": _card_base_hp(id),
		"hp_max": _card_base_hp(id),
		"spin_locked": false,
		"poisoned": false,
		"crossbowed": false,
		"rarity": str(card.get("rarity", "starter")),
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"atk_variable": false,
		"hp_variable": false,
		"swing_muted": false,
		"fled_once": false,
		"rage_step": 0,
		"rage_fire": false,
		"silenced": false,
	}
	_apply_formulas_to(s)
	return s


func _make_item(id: String) -> Dictionary:
	var card: Dictionary = items_by_id[id]
	uid_seq += 1
	var ops: Dictionary = {}
	if card.has("ops") and typeof(card["ops"]) == TYPE_DICTIONARY:
		ops = (card["ops"] as Dictionary).duplicate(true)
	elif ITEM_OPS.has(id):
		ops = (ITEM_OPS[id] as Dictionary).duplicate(true)
	return {
		"uid": uid_seq,
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ops": ops,
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"card_color": str(card.get("card_color", "")),
		"face_text": str(card.get("face_text", "")),
		"spent": false,
		"keep_after": false,
		"siphon_blk": 0,
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"petrified": false,
		"echo_copy": last_item_copy.duplicate(true) if id == "echo_bell" and not last_item_copy.is_empty() else {},
		"alt_n": 2 if str(ops.get("kind", "")) == "atk_alt_24" else 0,
	}


func _card_base_atk(id: String) -> int:
	var card: Dictionary = monsters_by_id.get(id, {})
	var a: Variant = card.get("atk", {})
	if typeof(a) == TYPE_DICTIONARY and (a as Dictionary).has("base"):
		return int((a as Dictionary)["base"])
	return 0


func _card_base_hp(id: String) -> int:
	var card: Dictionary = monsters_by_id.get(id, {})
	var h: Variant = card.get("hp", {})
	if typeof(h) == TYPE_DICTIONARY and (h as Dictionary).has("base"):
		return int((h as Dictionary)["base"])
	return 6


func _monster_stat_formula(id: String, which: String) -> String:
	var card: Dictionary = monsters_by_id.get(id, {})
	var blob: Variant = card.get(which, {})
	if typeof(blob) != TYPE_DICTIONARY:
		return ""
	return str((blob as Dictionary).get("formula", "")).strip_edges()


func _try_eval_stat_formula(formula: String, s: Dictionary) -> Variant:
	var raw: String = formula.strip_edges()
	if raw == "":
		return null
	var f: String = raw.to_lower().replace("_", " ").replace("-", " ")
	while f.contains("  "):
		f = f.replace("  ", " ")
	match f:
		"owners left", "monsters left", "monster count":
			return _monsters_left()
		"monsters still in play", "1 + monsters still in play", "1 + owners left":
			return 1 + _monsters_left()
		"player hp on spin", "player hp", "your hp", "your hp on spin", "player hp at all times":
			return hp
		"last mob hp", "last enemy hp":
			return last_mob_hp
		"num items at combat start", "items held", "item count":
			return hotbar.size()
		"own hp", "my hp":
			return int(s.get("hp", 0))
		"1 + mobs defeated", "1+mobs defeated":
			return 1 + mobs_defeated
		"2 + mobs defeated", "2+mobs defeated":
			return 2 + mobs_defeated
		"leftmost attack item, else 3", "leftmost attack item else 3", "base atk (0) + leftmost item with an atk value":
			return _leftmost_atk_n()
		"alternates between 3, 4, and 8 atk on spin":
			return [3, 4, 8][int(s.get("rage_step", 0)) % 3]
		_:
			if f.is_valid_int():
				return int(f)
			push_warning("Unknown %s formula '%s' — using the printed roster number." % [s.get("card_id", "?"), raw])
			return null


func _apply_formulas_to(s: Dictionary) -> void:
	var id: String = str(s.get("card_id", ""))
	if _is_silenced(s):
		if not bool(s.get("atk_locked", false)):
			s["atk"] = _card_base_atk(id)
		if not bool(s.get("hp_locked", false)):
			s["hp"] = _card_base_hp(id)
			s["hp_max"] = int(s["hp"])
		s["ability"] = ""
		s["explainer"] = ""
		s["special_id"] = ""
		s["special_text"] = ""
		s["call_name"] = ""
		s["reminder"] = ""
		return
	var hold_hp: int = int(s.get("hp", 0))
	var hold_atk: int = int(s.get("atk", 0))
	var hp_locked: bool = bool(s.get("hp_locked", false))
	var atk_locked: bool = bool(s.get("atk_locked", false))
	s["atk"] = _card_base_atk(id)
	s["hp"] = _card_base_hp(id)
	var hp_f: Variant = _try_eval_stat_formula(_monster_stat_formula(id, "hp"), s)
	if hp_f != null:
		s["hp"] = int(hp_f)
	s["hp_max"] = int(s["hp"])
	var atk_f: Variant = _try_eval_stat_formula(_monster_stat_formula(id, "atk"), s)
	if atk_f != null:
		s["atk"] = int(atk_f)
	var card: Dictionary = monsters_by_id.get(id, {})
	s["call_name"] = MONSTER_LINES.call_of(id, card)
	s["reminder"] = MONSTER_LINES.reminder_of(id, card)
	if hp_locked:
		s["hp"] = hold_hp
		if id == "slime_boss":
			s["atk"] = hold_hp
	if atk_locked and id != "slime_boss":
		s["atk"] = hold_atk


func _merge_catalog_card(kind: String, board_card: Dictionary) -> void:
	var id: String = str(board_card.get("id", ""))
	var arr: Array = catalog.get("monsters" if kind == "monster" else "items", [])
	var dst: Dictionary = {}
	for i in arr.size():
		if str(arr[i].get("id", "")) == id:
			dst = arr[i]
			break
	if dst.is_empty():
		dst = _new_catalog_stub(kind, id)
		arr.append(dst)
		catalog["monsters" if kind == "monster" else "items"] = arr
	dst["name"] = _title_case(str(board_card.get("name", id)))
	dst["rarity"] = str(board_card.get("rarity", "starter"))
	dst["tier"] = _as_int(board_card.get("tier", 1), 1)
	dst["count"] = _as_int(board_card.get("count", 1), 1)
	dst["priority"] = _as_int(board_card.get("priority", 3), 3)
	dst["ability"] = str(board_card.get("ability", ""))
	dst["explainer"] = str(board_card.get("explainer", ""))
	if kind != "monster":
		dst["card_color"] = str(board_card.get("card_color", ""))
		dst["face_text"] = str(board_card.get("face_text", ""))
	if kind == "monster":
		dst["call_name"] = str(board_card.get("call_name", ""))
		dst["reminder"] = str(board_card.get("reminder", ""))
	dst["defined"] = str(board_card.get("flow", ""))
	dst["exceptions"] = str(board_card.get("notes", ""))
	dst["author_lock"] = bool(board_card.get("author_lock", false))
	dst["locked_fields"] = board_card.get("locked_fields", [])
	dst["locked_at"] = str(board_card.get("locked_at", ""))
	dst["review"] = REVIEW_STAGE.of_card(board_card)
	dst["review_note"] = str(board_card.get("review_note", ""))
	if kind == "monster":
		var atk: Dictionary = dst.get("atk", {})
		if typeof(atk) != TYPE_DICTIONARY:
			atk = {}
		if board_card.get("atk_base") != null and str(board_card.get("atk_base", "")).strip_edges() != "":
			atk["base"] = _as_int(board_card.get("atk_base"), 0)
		var af: String = str(board_card.get("atk_formula", ""))
		if af != "":
			atk["formula"] = af
		else:
			atk.erase("formula")
		dst["atk"] = atk
		var hp: Dictionary = dst.get("hp", {})
		if typeof(hp) != TYPE_DICTIONARY:
			hp = {}
		if board_card.get("hp_base") != null and str(board_card.get("hp_base", "")).strip_edges() != "":
			hp["base"] = _as_int(board_card.get("hp_base"), 0)
		var hf: String = str(board_card.get("hp_formula", ""))
		if hf != "":
			hp["formula"] = hf
		else:
			hp.erase("formula")
		dst["hp"] = hp
	else:
		if typeof(board_card.get("ops", null)) == TYPE_DICTIONARY:
			dst["ops"] = (board_card["ops"] as Dictionary).duplicate(true)
	if kind == "monster":
		monsters_by_id[id] = dst
	else:
		items_by_id[id] = dst


func _new_catalog_stub(kind: String, id: String) -> Dictionary:
	if kind == "monster":
		return {
			"id": id,
			"name": id,
			"type": "M",
			"ability": "",
			"explainer": "",
			"call_name": "",
			"reminder": "",
			"defined": "",
			"exceptions": "",
			"rarity": "uncommon",
			"tier": 1,
			"count": 1,
			"priority": 3,
			"atk": {"base": 2},
			"hp": {"base": 6},
			"flags": {"art": false, "dev": false, "hide": false},
			"poc": false,
			"review": "rough",
			"review_note": "",
		}
	return {
		"id": id,
		"name": id,
		"type": "I",
		"ability": "",
		"explainer": "",
		"defined": "",
		"exceptions": "",
		"ops": {"kind": "atk", "n": 1},
		"card_color": "",
		"face_text": "",
		"rarity": "uncommon",
		"tier": 1,
		"count": 1,
		"priority": 3,
		"flags": {"art": false, "dev": false, "hide": false},
		"poc": false,
		"review": "rough",
		"review_note": "",
	}


func _write_catalog() -> bool:
	var path: String = ProjectSettings.globalize_path(CATALOG_PATH)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		f = FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Could not write catalog")
		return false
	f.store_string(JSON.stringify(catalog, "\t"))
	return true


func _apply_live_card(kind: String, card_id: String, board_card: Dictionary) -> void:
	if kind == "monster":
		for i in wheel.size():
			if str(wheel[i].get("card_id", "")) != card_id:
				continue
			_stamp_live_monster(wheel[i], board_card)
		if str(pending_monster.get("card_id", "")) == card_id:
			_stamp_live_monster(pending_monster, board_card)
	else:
		var ops: Dictionary = {}
		if typeof(board_card.get("ops", null)) == TYPE_DICTIONARY:
			ops = (board_card["ops"] as Dictionary).duplicate(true)
		for it in hotbar:
			if str(it.get("card_id", "")) != card_id:
				continue
			_stamp_live_item(it, board_card, ops)
		if str(pending_item.get("card_id", "")) == card_id:
			_stamp_live_item(pending_item, board_card, ops)
		_hotbar_sig = ""
	_sync_wheel_stats()


func _stamp_live_monster(s: Dictionary, board_card: Dictionary) -> void:
	s["name"] = _title_case(str(board_card.get("name", s.get("name", ""))))
	s["ability"] = str(board_card.get("ability", ""))
	s["explainer"] = str(board_card.get("explainer", ""))
	s["call_name"] = str(board_card.get("call_name", s.get("call_name", "")))
	s["reminder"] = str(board_card.get("reminder", s.get("reminder", "")))
	s["rarity"] = str(board_card.get("rarity", s.get("rarity", "")))
	s["pack_tier"] = int(board_card.get("tier", s.get("pack_tier", 1)))
	var locked: bool = bool(s.get("spin_locked", false))
	s["spin_locked"] = false
	_apply_formulas_to(s)
	s["spin_locked"] = locked


func _stamp_live_item(it: Dictionary, board_card: Dictionary, ops: Dictionary) -> void:
	it["name"] = _title_case(str(board_card.get("name", it.get("name", ""))))
	it["ability"] = str(board_card.get("ability", ""))
	it["explainer"] = str(board_card.get("explainer", ""))
	it["card_color"] = str(board_card.get("card_color", ""))
	it["face_text"] = str(board_card.get("face_text", ""))
	it["pack_tier"] = int(board_card.get("tier", it.get("pack_tier", 1)))
	it["pack_kind"] = "starter" if str(board_card.get("rarity", "")) == "starter" else "draft"
	if not ops.is_empty():
		it["ops"] = ops.duplicate(true)


func _ops_of(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) == "echo_bell":
		var copy: Variant = it.get("echo_copy", last_item_copy)
		if typeof(copy) == TYPE_DICTIONARY and not (copy as Dictionary).is_empty():
			var cops: Variant = (copy as Dictionary).get("ops", {})
			if typeof(cops) == TYPE_DICTIONARY and not (cops as Dictionary).is_empty():
				return (cops as Dictionary).duplicate(true)
	var ops: Dictionary = it.get("ops", {})
	if ops.is_empty():
		var id: String = str(it.get("card_id", ""))
		if ITEM_OPS.has(id):
			return ITEM_OPS[id]
	return ops


func _leftmost_atk_n() -> int:
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if _item_atk_score(it) < 0:
			continue
		return int(_item_view(it).get("n", 0))
	return 3


func _hand_has_atk_item(except_uid: int = -1) -> bool:
	for it in hotbar:
		if int(it.get("uid", -2)) == except_uid:
			continue
		if bool(it.get("spent", false)):
			continue
		if _item_atk_score(it) >= 0:
			return true
	return false


func _is_silenced(s: Dictionary) -> bool:
	return bool(s.get("silenced", false))


func _has_unique_ability(id: String) -> bool:
	if MONSTER_SPECIAL.has(id):
		return true
	match id:
		"ogre", "dire_wolf", "bandit", "berserker", "skeleton", "slime_boss", "leech_league", "clockwork_knight":
			return true
	return false


func _item_snapshot(it: Dictionary) -> Dictionary:
	var ops: Dictionary = {}
	var raw: Variant = it.get("ops", {})
	if typeof(raw) == TYPE_DICTIONARY and not (raw as Dictionary).is_empty():
		ops = (raw as Dictionary).duplicate(true)
	else:
		var oid: String = str(it.get("card_id", ""))
		if ITEM_OPS.has(oid):
			ops = (ITEM_OPS[oid] as Dictionary).duplicate(true)
	return {
		"card_id": str(it.get("card_id", "")),
		"name": str(it.get("name", "")),
		"ability": str(it.get("ability", "")),
		"explainer": str(it.get("explainer", "")),
		"ops": ops,
	}


func _echo_face(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) != "echo_bell":
		return it
	var copy: Variant = it.get("echo_copy", last_item_copy)
	if typeof(copy) == TYPE_DICTIONARY and not (copy as Dictionary).is_empty():
		return copy
	return {}


func _item_atk_score(it: Dictionary) -> int:
	if bool(it.get("petrified", false)) or bool(it.get("spent", false)):
		return -1
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind.begins_with("atk") or kind == "choose":
		if kind == "choose":
			var best: int = -1
			var opts: Variant = ops.get("options", [])
			if typeof(opts) == TYPE_ARRAY:
				for opt in opts:
					if typeof(opt) != TYPE_DICTIONARY:
						continue
					var o: Dictionary = opt
					if not o.has("atk"):
						continue
					var a: int = int(o.get("atk", 0))
					if a > best:
						best = a
			return best
		return int(_item_view(it).get("n", 0))
	return -1


func _item_rank(it: Dictionary) -> int:
	var view: Dictionary = _item_view(it)
	var k: String = str(view.get("kind", ""))
	var fill: Color = view.get("fill", Color.BLACK)
	if _is_yellow_fill(fill):
		return 1
	if k == "ATK":
		return 0
	if k == "BLK":
		return 2
	if k == "DEFEAT" or k == "FANGS":
		return 3
	return 4
