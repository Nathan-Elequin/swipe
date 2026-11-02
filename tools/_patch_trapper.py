from pathlib import Path

p = Path(r"C:\Users\Natha\Documents\boss-rush\scripts\main.gd")
t = p.read_text(encoding="utf-8")
fails = []


def sub(old: str, new: str, label: str) -> None:
    global t
    n = t.count(old)
    if n != 1:
        fails.append(f"{label}: count={n}")
        return
    t = t.replace(old, new, 1)


sub(
    '\t"kobold_trapper": {"id": "hunter_mark", "text": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK"},',
    '\t"kobold_trapper": {"id": "hunter_mark", "text": "When I arrive, I place a Bear Trap on top of the Dungeon Deck"},\n\t"bear_trap": {"id": "bear_trap", "text": "When you Spin me or Move onto me, I immediately Attack you and then I am Defeated"},',
    "special",
)
sub(
    '\t"kobold_trapper": "Hunter\'s Mark",',
    '\t"kobold_trapper": "Bear Trap",\n\t"bear_trap": "Bear Trap",',
    "call",
)
sub(
    '\t"kobold_trapper": "Marked Defeat: +2 HP and ATK",',
    '\t"kobold_trapper": "When I arrive, I put a Bear Trap on top of the Dungeon Deck",\n\t"bear_trap": "Spin or Move onto me: I Attack you, then I am Defeated",',
    "reminder",
)
sub(
    '\t"kobold_trapper": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK",',
    '\t"kobold_trapper": "When I arrive, I place a Bear Trap on top of the Dungeon Deck",\n\t"bear_trap": "When you Spin me or Move onto me, I immediately Attack you and then I am Defeated",',
    "speech",
)
sub(
    """\t\tif str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
			await _harpy_poke()
			if hp <= 0 or phase != "fighting":
				await _bleed_end()
				await _unlock_if_fighting()
				return
			_walker_busy = true
			_sync_buttons()
			m = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else m
		if str(m.get("card_id", "")) == "gargoyle":""",
    """\t\tif str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
			await _harpy_poke()
			if hp <= 0 or phase != "fighting":
				await _bleed_end()
				await _unlock_if_fighting()
				return
			_walker_busy = true
			_sync_buttons()
			m = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else m
		if await _bear_trap_snap():
			await _bleed_end()
			_store_last_faced_hp()
			_undo_arm()
			await _unlock_if_fighting()
			return
		if str(m.get("card_id", "")) == "gargoyle":""",
    "spin",
)
sub(
    """\t\t\tif facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
				if not _wick_waiting(facing_index):
					await _begin_slay()
			return
		"atk_flee_keep":""",
    """\t\t\tif facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
				if not _wick_waiting(facing_index):
					await _begin_slay()
			elif hp > 0 and phase == "fighting":
				await _bear_trap_snap()
			return
		"atk_flee_keep":""",
    "shuriken",
)
sub(
    """func _trapper_mark_newcomers() -> void:
	if not _trapper_phase_ok():
		return
	var changed := false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "kobold_trapper":
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		if bool(wheel[i].get("trapper_entered", false)):
			continue
		wheel[i]["trapper_entered"] = true
		changed = true
		var pool: Array = []
		for j in wheel.size():
			if j == i:
				continue
			if typeof(wheel[j]) != TYPE_DICTIONARY:
				continue
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			if int(wheel[j].get("hp", 0)) <= 0:
				continue
			if bool(wheel[j].get("hunter_mark", false)):
				continue
			pool.append(j)
		var take: int = mini(2, pool.size())
		for _n in take:
			if pool.is_empty():
				break
			var pick: int = rng.randi_range(0, pool.size() - 1)
			var j2: int = int(pool[pick])
			pool.remove_at(pick)
			wheel[j2]["hunter_mark"] = true
			wheel[j2]["marked_by"] = int(wheel[i].get("seat_uid", -1))
			_log("on_resolve", "Marked %s" % str(wheel[j2].get("name", "?")))
	if changed and wheel_view:
		wheel_view.queue_redraw()
""",
    """func _trapper_mark_newcomers() -> void:
	if not _trapper_phase_ok():
		return
	if not monsters_by_id.has("bear_trap"):
		return
	var changed := false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "kobold_trapper":
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		if bool(wheel[i].get("trapper_laid", false)):
			continue
		wheel[i]["trapper_laid"] = true
		wheel[i]["trapper_entered"] = true
		challenge_deck.push_front("bear_trap")
		changed = true
		_log("on_resolve", "Bear Trap on top of the Dungeon Deck")
	if changed:
		if dungeon_deck_ui:
			dungeon_deck_ui.visible = true
			dungeon_deck_ui.set_count(challenge_deck.size())
		if wheel_view:
			wheel_view.queue_redraw()
		_sync_challenge_peek()
""",
    "place",
)
sub(
    """func _install_laid_egg(index: int) -> bool:
	if adventure:
		return false
	if index < 0 or index >= wheel.size():
		return false
	if not bool(wheel[index].get("egg_laid", false)):
		return false
""",
    """func _install_laid_egg(index: int) -> bool:
	if adventure:
		return false
	if index < 0 or index >= wheel.size():
		return false
	if _install_mill_bear_trap(index):
		return true
	if not bool(wheel[index].get("egg_laid", false)):
		return false
""",
    "install",
)
egg_fn = """	_log("on_resolve", "Phoenix Egg")
	return true


func _apply_lifelink(m: Dictionary) -> void:
"""
egg_new = """	_log("on_resolve", "Phoenix Egg")
	return true


func _install_mill_bear_trap(index: int) -> bool:
	if adventure:
		return false
	if index < 0 or index >= wheel.size():
		return false
	if challenge_deck.is_empty() or _deck_card_id(challenge_deck[0]) != "bear_trap":
		return false
	if not monsters_by_id.has("bear_trap"):
		return false
	challenge_deck.pop_front()
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(challenge_deck.size())
	var trap: Dictionary = _make_monster("bear_trap")
	trap["slot"] = str(wheel[index].get("slot", ""))
	wheel[index] = trap
	_reseat_slots()
	_log("on_resolve", "Bear Trap")
	_sync_challenge_peek()
	return true


func _facing_live_bear_trap() -> bool:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return false
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "bear_trap":
		return false
	if str(m.get("kind", "")) != "monster":
		return false
	return int(m.get("hp", 0)) > 0


func _bear_trap_snap() -> bool:
	if not _facing_live_bear_trap():
		return false
	if bool(wheel[facing_index].get("bear_trap_snapped", false)):
		return false
	wheel[facing_index]["bear_trap_snapped"] = true
	_walker_busy = true
	_sync_buttons()
	_trace_resolve("bear trap snap")
	await _announce_slice(facing_index, _hub_hp_pos())
	if not _facing_live_bear_trap():
		_walker_busy = false
		_sync_buttons()
		return true
	var m: Dictionary = wheel[facing_index]
	await _owner_attack(m)
	_walker_busy = false
	_sync_buttons()
	if hp <= 0:
		_player_down()
		return true
	if phase != "fighting":
		return true
	if not _facing_live_bear_trap():
		return true
	if not _wick_waiting(facing_index):
		await _begin_slay()
	return true


func _apply_lifelink(m: Dictionary) -> void:
"""
sub(egg_fn, egg_new, "snap_fns")
sub(
    '\tit["bagged"]["trapper_entered"] = false\n',
    '\tit["bagged"]["trapper_entered"] = false\n\tit["bagged"]["trapper_laid"] = bool(m.get("trapper_laid", false))\n',
    "bag",
)
sub(
    """				if not await _shift_facing(dir, false):
					break
			moves_left = moves_snap
""",
    """				if not await _shift_facing(dir, false):
					break
				if _facing_live_bear_trap():
					await _bear_trap_snap()
					moves_left = moves_snap
					await _bleed_end()
					return
			moves_left = moves_snap
""",
    "hook",
)
sub(
    """	if nid == "kobold_trapper":
		copy["trapper_growth"] = int(src.get("trapper_growth", 0))
""",
    """	if nid == "kobold_trapper":
		copy["trapper_growth"] = int(src.get("trapper_growth", 0))
		copy["trapper_laid"] = bool(src.get("trapper_laid", false))
""",
    "poly",
)
sub(
    """		["phoenix egg", gold],
		["phoenix", gold],
""",
    """		["phoenix egg", gold],
		["phoenix", gold],
		["bear trap", gold],
""",
    "paint",
)
sub(
    """	if await _shift_facing(dir, true):
		if _undo_stale(token):
			_move_busy = false
			return
		_undo_commit()
		if in_tutorial and tut != null and tut.wait == "move":
""",
    """	if await _shift_facing(dir, true):
		if _undo_stale(token):
			_move_busy = false
			return
		if _facing_live_bear_trap():
			await _bear_trap_snap()
		_undo_commit()
		if in_tutorial and tut != null and tut.wait == "move":
""",
    "move",
)
sub(
    """	var first_ok: bool = await _shift_facing(dir, false)
	var second_ok: bool = false
	if first_ok and not _undo_stale(token):
		second_ok = await _shift_facing(dir, false)
	_move_busy = false
	if _undo_stale(token):
		return true
	if not first_ok or not second_ok:
""",
    """	var first_ok: bool = await _shift_facing(dir, false)
	var second_ok: bool = false
	var trap_cut := false
	if first_ok and not _undo_stale(token) and _facing_live_bear_trap():
		trap_cut = true
		await _bear_trap_snap()
	elif first_ok and not _undo_stale(token):
		second_ok = await _shift_facing(dir, false)
		if second_ok and not _undo_stale(token) and _facing_live_bear_trap():
			await _bear_trap_snap()
	_move_busy = false
	if _undo_stale(token):
		return true
	if trap_cut:
		first_ok = true
		second_ok = true
	if not first_ok or not second_ok:
""",
    "jar",
)

if fails:
    print("FAILS:")
    for f in fails:
        print(" ", f)
    raise SystemExit(1)
p.write_text(t, encoding="utf-8")
print("patched", p)

root = Path(r"C:\Users\Natha\Documents\boss-rush")
fails2 = []


def subf(path: Path, old: str, new: str, label: str) -> None:
    s = path.read_text(encoding="utf-8")
    n = s.count(old)
    if n != 1:
        fails2.append(f"{path.name}:{label}: count={n}")
        return
    path.write_text(s.replace(old, new, 1), encoding="utf-8")
    print("patched", path.name, label)


cat = root / "data" / "catalog.json"
board = root / "data" / "content-board.json"
ux = root / "scripts" / "ux_style.gd"
subf(
    cat,
    '\t\t"spin": "The wheel lands on a random living monster."\n',
    '\t\t"spin": "The wheel lands on a random living monster.",\n\t\t"bear_trap": "a 2 HP 4 ATK monster that Attacks you when you Move or Spin onto it"\n',
    "kw",
)
subf(
    cat,
    '"ability": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK"',
    '"ability": "When I arrive, I place a Bear Trap on top of the Dungeon Deck"',
    "ability",
)
subf(
    cat,
    '"call_name": "Hunter\'s Mark"',
    '"call_name": "Bear Trap"',
    "call",
)
subf(
    cat,
    '"explainer": "On enter, Mark 2 other monsters. When one is Defeated, +2 HP and +2 ATK."',
    '"explainer": "When I arrive, I put a Bear Trap on top of the Dungeon Deck."',
    "explainer",
)
subf(
    cat,
    '"defined": "On Done, swing count is 1 plus items used this fight. Cube feed does not count. Block is spent per swing."',
    '"defined": "When I sit on the wheel, put a Bear Trap token on top of the Dungeon Deck. I stay as a 2 HP / 3 Attack fight. Challenge and Adventure draw the trap as the next hole fill. Mill seats it into the next vacated seat. The trap is never part of the opening wheel."',
    "defined",
)
subf(
    cat,
    '"flow": "On Done, swing count is 1 plus items used this fight. Cube feed does not count. Block is spent per swing."',
    '"flow": "When I sit on the wheel, put a Bear Trap token on top of the Dungeon Deck. I stay as a 2 HP / 3 Attack fight. Challenge and Adventure draw the trap as the next hole fill. Mill seats it into the next vacated seat. The trap is never part of the opening wheel."',
    "flow",
)
subf(
    cat,
    '\t\t\t"hp": {\n\t\t\t\t"base": 3.0\n\t\t\t},\n\t\t\t"hp_base": 3.0,\n\t\t\t"hp_formula": "",\n\t\t\t"id": "kobold_trapper",',
    '\t\t\t"hp": {\n\t\t\t\t"base": 2.0\n\t\t\t},\n\t\t\t"hp_base": 2.0,\n\t\t\t"hp_formula": "",\n\t\t\t"id": "kobold_trapper",',
    "hp",
)
subf(
    cat,
    '"log_hint": "Extra hits per item used"',
    '"log_hint": "Arrive: Bear Trap on top of the Dungeon Deck"',
    "log",
)
subf(
    cat,
    '"notes": "0 items = 1 swing. 2 items = 3 swings."',
    '"notes": "Rework 2026-10-30. Places Bear Trap token. Hunter\'s Mark is gone."',
    "notes",
)
BEAR = '''
		{
			"ability": "When you Spin me or Move onto me, I immediately Attack you and then I am Defeated",
			"atk": {"base": 4.0},
			"atk_base": 4.0,
			"atk_formula": "",
			"author_lock": true,
			"call_name": "Bear Trap",
			"card_color": "",
			"count": 0.0,
			"defined": "When your Spin lands on me, or any Move/slide lands on me, I Attack you once (Block works) and then I am Defeated like any other monster. Shuriken finishes its 3 Attack first; if that Defeats me I do not Attack. Jar: if the first slide lands on me, I snap and the second slide does not happen. I am never on the opening wheel.",
			"exceptions": "Token. Not drafted. Trapper places this on top of the Dungeon Deck.",
			"explainer": "Spin or Move onto me: I Attack you, then I am Defeated",
			"flags": {"art": false, "dev": true, "hide": true},
			"flow": "When your Spin lands on me, or any Move/slide lands on me, I Attack you once (Block works) and then I am Defeated like any other monster. Shuriken finishes its 3 Attack first; if that Defeats me I do not Attack. Jar: if the first slide lands on me, I snap and the second slide does not happen. I am never on the opening wheel.",
			"hp": {"base": 2.0},
			"hp_base": 2.0,
			"hp_formula": "",
			"id": "bear_trap",
			"locked_at": "2026-10-30",
			"locked_fields": ["name", "ability", "explainer", "call_name", "atk_base", "hp_base"],
			"log_hint": "Spin or Move onto me: Attack, then Defeated",
			"mode_pool": "all",
			"name": "Bear Trap",
			"notes": "Token. Trapper creates it. Paper Fight 2026-10-30.",
			"ops": {},
			"poc": false,
			"pool": -1.0,
			"priority": 3.0,
			"rarity": "uncommon",
			"reminder": "",
			"review": "rough",
			"review_note": "",
			"status": "live",
			"tier": 2.0,
			"type": "M"
		},'''
subf(
    cat,
    '\t\t\t"id": "kobold_trapper",',
    '\t\t\t"id": "kobold_trapper",',
    "id-noop",
)
cs = cat.read_text(encoding="utf-8")
if '"id": "bear_trap"' not in cs:
    needle = '\t\t\t"status": "live",\n\t\t\t"tier": 2.0,\n\t\t\t"type": "M"\n\t\t},\n\t\t{\n\t\t\t"ability": "When I am Defeated, my Neighbors gain HP until they are equal, and then gain Attack until they are equal."'
    if cs.count(needle) != 1:
        fails2.append(f"catalog.json:insert: count={cs.count(needle)}")
    else:
        cat.write_text(cs.replace(needle, '\t\t\t"status": "live",\n\t\t\t"tier": 2.0,\n\t\t\t"type": "M"\n\t\t},' + BEAR + '\n\t\t{\n\t\t\t"ability": "When I am Defeated, my Neighbors gain HP until they are equal, and then gain Attack until they are equal."', 1), encoding="utf-8")
        print("patched catalog.json insert")

subf(
    board,
    '"ability": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK"',
    '"ability": "When I arrive, I place a Bear Trap on top of the Dungeon Deck"',
    "b-ability",
)
subf(
    board,
    '"call_name": "Hunter\'s Mark"',
    '"call_name": "Bear Trap"',
    "b-call",
)
subf(
    board,
    '"explainer": "On enter, Mark 2 other monsters. When one is Defeated, +2 HP and +2 ATK."',
    '"explainer": "When I arrive, I put a Bear Trap on top of the Dungeon Deck."',
    "b-explainer",
)
subf(
    board,
    '"hp_base": 3.0,\n\t\t\t"hp_formula": "",\n\t\t\t"id": "kobold_trapper",',
    '"hp_base": 2.0,\n\t\t\t"hp_formula": "",\n\t\t\t"id": "kobold_trapper",',
    "b-hp",
)
subf(
    ux,
    '\tif low == "phoenix":\n\t\treturn "phoenix"\n\tif low == "across":',
    '\tif low == "phoenix":\n\t\treturn "phoenix"\n\tif low == "bear trap":\n\t\treturn "bear_trap"\n\tif low == "across":',
    "defid",
)
subf(
    ux,
    '\t\t"move":\n\t\t\treturn "shift to a Neighbor without Spinning"',
    '\t\t"bear_trap":\n\t\t\treturn "a 2 HP 4 ATK monster that Attacks you when you Move or Spin onto it"\n\t\t"move":\n\t\t\treturn "shift to a Neighbor without Spinning"',
    "defof",
)
subf(
    ux,
    '\t\t["phoenix egg", gold],\n\t\t["phoenix", gold],\n\t]',
    '\t\t["phoenix egg", gold],\n\t\t["phoenix", gold],\n\t\t["bear trap", gold],\n\t]',
    "phrases",
)
subf(
    ux,
    '"item_swings", "hunter_mark", "wickrise"',
    '"item_swings", "hunter_mark", "bear_trap", "wickrise"',
    "color",
)

if fails2:
    print("FAILS2:")
    for f in fails2:
        print(" ", f)
    raise SystemExit(2)
print("data ok")

