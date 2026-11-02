from pathlib import Path

p = Path(r"C:\Users\Natha\Documents\boss-rush\scripts\main.gd")
t = p.read_text(encoding="utf-8")
n = 0


def sub(old: str, new: str, label: str) -> bool:
	global t, n
	c = t.count(old)
	if c != 1:
		print(f"FAIL {label}: count={c}")
		return False
	t = t.replace(old, new, 1)
	n += 1
	print(f"OK {label}")
	return True


ok = True
ok &= sub(
	'''	if kind == "sling":
		if phase == "fighting" and _sling_attack_options(int(it.get("uid", -1))).is_empty():
			unplayable = true
	if str(pending_mark.get("kind", "")) == "sling_any":
		unplayable = true
	elif not pending_choice.is_empty():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		if str(_ops_of(chooser).get("kind", "")) == "sling" or str(chooser.get("card_id", "")) == "sling":
			var pick_uid: int = int(it.get("uid", -1))
			var listed := pick_uid == int(chooser.get("uid", -1))
			if not listed:
				for opt_v2 in pending_choice.get("options", []):
					if typeof(opt_v2) == TYPE_DICTIONARY and int((opt_v2 as Dictionary).get("atk_uid", -1)) == pick_uid:
						listed = true
						break
			if not listed:
				unplayable = true
''',
	'''	if kind == "sling":
		if phase == "fighting" and _sling_convert_options(int(it.get("uid", -1))).is_empty():
			unplayable = true
	if _sling_pick_open():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		var pick_uid: int = int(it.get("uid", -1))
		var listed := pick_uid == int(chooser.get("uid", -1)) or _sling_option_has(pick_uid)
		if listed:
			unplayable = false
		else:
			unplayable = true
''',
	"item_look",
)

ok &= sub(
	'''	var it: Dictionary = _find_item(uid)
	if it.is_empty() or it["spent"]:
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _item_stoned(it):
		_log("on_item_use", "petrified")
		if sfx:
			sfx.play_event(&"hand.petrified")
		return
	if in_tutorial and not _tutorial_allows_item(str(it.get("card_id", ""))):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_item", "Not that one."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if str(pending_mark.get("kind", "")) == "sling_any":
		## Sling is waiting for a monster. Do not let Longbow / Great Axe fire their native aim.
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if not pending_choice.is_empty():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		if str(_ops_of(chooser).get("kind", "")) == "sling" or str(chooser.get("card_id", "")) == "sling":
			if uid == int(chooser.get("uid", -1)):
				return
			for opt_v in pending_choice.get("options", []):
				if typeof(opt_v) != TYPE_DICTIONARY:
					continue
				var opt: Dictionary = opt_v
				if int(opt.get("atk_uid", -1)) == uid:
					await _choose_option(opt)
					return
			if sfx:
				sfx.play("error", -12.0, 1.2)
			return
''',
	'''	var it: Dictionary = _find_item(uid)
	if it.is_empty() or it["spent"]:
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _sling_pick_open():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		if uid == int(chooser.get("uid", -1)):
			pending_choice.clear()
			_undo_abort()
			call_deferred("_refresh")
			return
		for opt_v in pending_choice.get("options", []):
			if typeof(opt_v) != TYPE_DICTIONARY:
				continue
			var opt: Dictionary = opt_v
			if int(opt.get("target_uid", -1)) == uid:
				await _choose_option(opt)
				return
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _item_stoned(it):
		_log("on_item_use", "petrified")
		if sfx:
			sfx.play_event(&"hand.petrified")
		return
	if in_tutorial and not _tutorial_allows_item(str(it.get("card_id", ""))):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_item", "Not that one."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if str(pending_mark.get("kind", "")) == "sling_any":
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
''',
	"use_item_pick",
)

ok &= sub(
	'''	if kind == "sling":
		var sling_opts: Array = _sling_attack_options(uid)
''',
	'''	if kind == "sling":
		var sling_opts: Array = _sling_convert_options(uid)
''',
	"use_item_opts",
)

ok &= sub(
	'''	if str(_ops_of(it).get("kind", "")) == "sling" or str(it.get("card_id", "")) == "sling":
		var atk_uid: int = int(opt.get("atk_uid", -1))
		if _mark_targets("sling_any").is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			_undo_abort()
			call_deferred("_refresh")
			return
		pending_mark = {"uid": int(it.get("uid", -1)), "kind": "sling_any", "atk_uid": atk_uid}
		_log("on_item_use", "pick a monster")
		_loud_mark_prompt("sling_any")
		call_deferred("_refresh")
		return
''',
	'''	if str(_ops_of(it).get("kind", "")) == "sling" or str(it.get("card_id", "")) == "sling":
		await _apply_sling_convert(it, int(opt.get("target_uid", -1)))
		return
''',
	"choose_option",
)

ok &= sub(
	'''		"sling":
			out["kind"] = "ATK"
			out["number"] = PLAYER_COPY.text("status.sling_loaded", "Loaded") if _sling_is_loaded(it) else "Any"
			out["note"] = ""
			out["can_use"] = fighting and not _sling_attack_options(int(it.get("uid", -1))).is_empty()
''',
	'''		"sling":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _sling_convert_options(int(it.get("uid", -1))).is_empty()
''',
	"item_view",
)

ok &= sub(
	'''		"sling":
			if _sling_is_loaded(it):
				out["value"] = UxStyle.with_def_link(_value_bb(PLAYER_COPY.text("status.sling_loaded", "Loaded"), "", gold), "Loaded")
			else:
				out["value"] = _value_bb("Any", "", gold)
			out["body"] = str(it.get("ability", "Select an Attack. It can target Any monster. Draw 1 Item"))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — you need an Attack item."
''',
	'''		"sling":
			out["value"] = _value_bb("Marble", "0", gold)
			out["body"] = str(it.get("ability", "Turn any Item in your hand into a Marble, then Draw 1 Item"))
''',
	"inspect",
)

ok &= sub(
	'''		"sling":
			return [[_fg("text", n if n != "" else "Any")]]
''',
	'''		"sling":
			return [[_fg("text", n)]]
''',
	"face",
)

ok &= sub(
	'''		var sling_on: bool = cid == "sling" and _sling_is_loaded(it)
		var armed: bool = sling_on
''',
	'''		var sling_on: bool = cid == "sling" and _sling_pick_open() and int(pending_choice.get("uid", -1)) == int(it.get("uid", -1))
		var armed: bool = sling_on
''',
	"armed",
)

ok &= sub(
	'''		elif not pending_feed.is_empty():
			can_click = is_snack
		else:
			can_click = (in_fight or magnet_ready) and bool(view["can_use"]) and not spent_n and not _item_stoned(it)
''',
	'''		elif not pending_feed.is_empty():
			can_click = is_snack
		elif _sling_pick_open():
			can_click = (not spent_n) and (uid_n == int(pending_choice.get("uid", -1)) or _sling_option_has(uid_n))
		else:
			can_click = (in_fight or magnet_ready) and bool(view["can_use"]) and not spent_n and not _item_stoned(it)
''',
	"can_click",
)

FUNCS_OLD_START = "func _sling_is_loaded(it: Dictionary) -> bool:"
FUNCS_OLD_END = "func _apply_signpost(index: int, it: Dictionary) -> void:"
i0 = t.find(FUNCS_OLD_START)
i1 = t.find(FUNCS_OLD_END)
if i0 < 0 or i1 < i0:
	print("FAIL funcs block", i0, i1)
	ok = False
else:
	new_funcs = '''func _sling_pick_open() -> bool:
	if pending_choice.is_empty():
		return false
	var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
	if chooser.is_empty():
		return false
	return str(_ops_of(chooser).get("kind", "")) == "sling" or str(chooser.get("card_id", "")) == "sling"


func _sling_option_has(uid: int) -> bool:
	for opt_v in pending_choice.get("options", []):
		if typeof(opt_v) != TYPE_DICTIONARY:
			continue
		if int((opt_v as Dictionary).get("target_uid", -1)) == uid:
			return true
	return false


func _sling_convert_options(skip_uid: int) -> Array:
	var out: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -1)) == skip_uid:
			continue
		if bool(it.get("spent", false)):
			continue
		out.append({
			"id": "marble_%s" % int(it.get("uid", -1)),
			"label": _title_case(str(it.get("name", "?"))),
			"target_uid": int(it.get("uid", -1)),
		})
	return out


func _sling_morph_into_marble(it: Dictionary) -> void:
	if _bag_is_loaded(it):
		var snap: Dictionary = _empty_bag(it)
		if not snap.is_empty() and str(snap.get("kind", "monster")) != "empty":
			_seat_released_bag(snap)
	var keep_uid: int = int(it.get("uid", -1))
	var fresh: Dictionary = _make_item("marble")
	it.clear()
	for k in fresh.keys():
		it[k] = fresh[k]
	it["uid"] = keep_uid
	it["marble_n"] = 0
	it["marble_monster"] = ""
	it["cats_eye"] = false
	it["petrified"] = false
	it["petrify_n"] = 0
	it["keep_after"] = false
	it["spent"] = false


func _apply_sling_convert(sling: Dictionary, target_uid: int) -> void:
	var target: Dictionary = _find_item(target_uid)
	if target.is_empty() or bool(target.get("spent", false)) or target_uid == int(sling.get("uid", -1)):
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		call_deferred("_refresh")
		return
	_log("on_item_use", "sling %s → Marble 0" % str(target.get("name", "?")))
	_sling_morph_into_marble(target)
	sling["spent"] = true
	await _count_item_use()
	_toss_item(int(sling.get("uid", -1)), false)
	_hotbar_sig = ""
	var before_uids: Dictionary = {}
	for held in hotbar:
		if typeof(held) == TYPE_DICTIONARY:
			before_uids[int(held.get("uid", -1))] = true
	_draw_unseen_item()
	_refresh()
	if _challenge_loot_wait:
		await _after_item_resolved(sling)
		_undo_finish_item()
		call_deferred("_refresh")
		return
	for held in hotbar:
		if typeof(held) != TYPE_DICTIONARY:
			continue
		var drawn_uid: int = int(held.get("uid", -1))
		if before_uids.has(drawn_uid):
			continue
		var drawn_card = _hotbar_card_by_uid(drawn_uid)
		if drawn_card != null and drawn_card.has_method("play_transform"):
			drawn_card.play_transform()
		break
	var marble_card = _hotbar_card_by_uid(target_uid)
	if marble_card != null and marble_card.has_method("play_transform"):
		marble_card.play_transform()
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()
	await _after_item_resolved(sling)
	_undo_finish_item()
	call_deferred("_refresh")


'''
	t = t[:i0] + new_funcs + t[i1:]
	n += 1
	print("OK funcs")

ok &= sub(
	'''func _apply_sling(aim: int, sling: Dictionary, atk_uid: int) -> void:
	var payload: Dictionary = _find_item(atk_uid)
''',
	'''func _apply_sling(aim: int, sling: Dictionary, atk_uid: int) -> void:
	await _apply_sling_convert(sling, atk_uid)
	return
	var payload: Dictionary = _find_item(atk_uid)
''',
	"apply_sling_stub",
)

if not ok:
	raise SystemExit(1)
p.write_text(t, encoding="utf-8")
print("wrote", n, "patches")
print("pick_open", "_sling_pick_open" in t)
print("convert", "_sling_convert_options" in t)
print("is_loaded", "_sling_is_loaded" in t)
