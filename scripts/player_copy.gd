extends Object
## Player-facing prose. Script editor Save writes player-copy.json, lore.json, script-names.json, and card wording on the board.

const PATH := "res://data/player-copy.json"
const CSV_PATH := "res://data/player-copy.csv"
const BOARD_PATH := "res://data/content-board.json"
const NAMES_PATH := "res://data/script-names.json"
const LORE_PATH := "res://data/lore.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")

static var pack: Dictionary = {}
static var by_key: Dictionary = {}
static var names_pack: Dictionary = {}
static var names_by_id: Dictionary = {}
static var lore_pack: Dictionary = {}
static var last_board: Dictionary = {}


static func reload() -> void:
	pack = {}
	by_key = {}
	names_pack = {}
	names_by_id = {}
	lore_pack = {}
	_load_copy()
	_load_names()
	_load_lore()


static func _load_copy() -> void:
	var parsed: Dictionary = _read_dict(PATH)
	pack = parsed
	for row in pack.get("rows", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var k: String = str(row.get("key", ""))
		if k != "":
			by_key[k] = row


static func _load_names() -> void:
	names_pack = _read_dict(NAMES_PATH)
	for row in names_pack.get("names", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var nid: String = str(row.get("id", "")).strip_edges()
		if nid != "":
			names_by_id[nid] = row


static func _load_lore() -> void:
	lore_pack = _read_dict(LORE_PATH)


static func _read_dict(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
	if f == null:
		return {}
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


static func stamp() -> String:
	if pack.is_empty():
		reload()
	if pack.is_empty():
		return "copy: MISSING"
	var cid: String = str(pack.get("id", "")).strip_edges()
	var upd: String = str(pack.get("updated", "")).strip_edges()
	if cid == "" and upd == "":
		return "copy: MISSING"
	return "copy: %s · %s" % [cid, upd]


static func _raw(key: String, fallback: String = "") -> String:
	if by_key.is_empty():
		reload()
	var row: Variant = by_key.get(key, null)
	if typeof(row) != TYPE_DICTIONARY:
		return fallback
	var t: String = str(row.get("text", ""))
	return t if t != "" else fallback


static func has_key(key: String) -> bool:
	if by_key.is_empty():
		reload()
	return by_key.has(key)


static func text(key: String, fallback: String = "") -> String:
	return apply_names(_raw(key, fallback))


static func fill(key: String, vars: Dictionary, fallback: String = "") -> String:
	var t: String = _raw(key, fallback)
	for k in vars.keys():
		t = t.replace("{%s}" % str(k), str(vars[k]))
	return apply_names(t)


static func possessive(display: String) -> String:
	var d: String = display.strip_edges()
	if d == "":
		return ""
	var last: String = d.substr(d.length() - 1, 1)
	if last.to_lower() == "s":
		return d + "'"
	return d + "'s"


static func apply_names(t: String) -> String:
	if t == "":
		return t
	if names_by_id.is_empty():
		_load_names()
	var out: String = t
	for id in _name_ids_longest():
		var row: Dictionary = names_by_id[id]
		var display: String = str(row.get("display", ""))
		if display == "":
			continue
		out = out.replace("{%s|poss}" % str(id), possessive(display))
		out = out.replace("{%s}" % str(id), display)
	return out


static func _name_ids_longest() -> Array:
	var keys: Array = names_by_id.keys()
	keys.sort_custom(func(a, b) -> bool: return str(a).length() > str(b).length())
	return keys


static func tokenize(filled: String) -> String:
	if filled == "":
		return filled
	if names_by_id.is_empty():
		_load_names()
	var pairs: Array = []
	for id in names_by_id.keys():
		var row: Dictionary = names_by_id[id]
		var display: String = str(row.get("display", ""))
		if display == "":
			continue
		pairs.append([possessive(display), "{%s|poss}" % str(id), display.length() + 2])
		pairs.append([display, "{%s}" % str(id), display.length()])
	pairs.sort_custom(func(a, b) -> bool: return int(a[2]) > int(b[2]))
	var out: String = filled
	for pair in pairs:
		out = _replace_word(out, str(pair[0]), str(pair[1]))
	return out


static func _is_word_char(ch: String) -> bool:
	if ch == "":
		return false
	var c: String = ch.to_lower()
	if c >= "a" and c <= "z":
		return true
	if c >= "0" and c <= "9":
		return true
	return c == "_"


static func _replace_word(text: String, needle: String, repl: String) -> String:
	if needle == "" or text == "":
		return text
	var bits: PackedStringArray = PackedStringArray()
	var i: int = 0
	var nlen: int = needle.length()
	while i < text.length():
		var at: int = text.find(needle, i)
		if at < 0:
			bits.append(text.substr(i))
			break
		if at > i:
			bits.append(text.substr(i, at - i))
		var before_ok: bool = at == 0 or not _is_word_char(text.substr(at - 1, 1))
		var after_i: int = at + nlen
		var after_ok: bool = after_i >= text.length() or not _is_word_char(text.substr(after_i, 1))
		if before_ok and after_ok:
			bits.append(repl)
			i = after_i
		else:
			bits.append(text.substr(at, 1))
			i = at + 1
		if i <= at:
			i = at + 1
	return "".join(bits)


static func name_rows() -> Array:
	if names_pack.is_empty():
		_load_names()
	var out: Array = []
	for row in names_pack.get("names", []):
		if typeof(row) == TYPE_DICTIONARY:
			out.append((row as Dictionary).duplicate(true))
	return out


static func displays_for_highlight() -> Array:
	if names_by_id.is_empty():
		_load_names()
	var out: Array = []
	for id in names_by_id.keys():
		var display: String = str(names_by_id[id].get("display", ""))
		if display == "":
			continue
		out.append(possessive(display))
		out.append(display)
	out.sort_custom(func(a, b) -> bool: return str(a).length() > str(b).length())
	return out


static func tier_name(tier: int) -> String:
	var t: int = clampi(tier, 1, 3)
	var fallback := "Weak"
	if t == 2:
		fallback = "Tough"
	elif t == 3:
		fallback = "Deadly"
	return text("tier.%d.name" % t, fallback)


static func taunts(id: String) -> Array:
	if by_key.is_empty():
		reload()
	var out: Array = []
	for i in range(1, 6):
		var t: String = text("taunt.%s.%d" % [id, i], "")
		if t != "":
			out.append(t)
	if out.is_empty():
		for j in range(1, 6):
			var d: String = text("taunt.default.%d" % j, "")
			if d != "":
				out.append(d)
	return out


static func script_rows() -> Array:
	if pack.is_empty():
		reload()
	var out: Array = []
	for row in pack.get("rows", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("cat", "")) == "Cards":
			continue
		var copy: Dictionary = (row as Dictionary).duplicate(true)
		copy["src"] = "copy"
		out.append(copy)
	return out


static func lore_rows() -> Array:
	if lore_pack.is_empty():
		_load_lore()
	var out: Array = []
	var engr: String = str(lore_pack.get("engraving", ""))
	out.append({
		"src": "lore",
		"cat": "Journal",
		"key": "lore.engraving",
		"where": "Trophy hall engraving",
		"text": engr,
		"author_lock": bool(lore_pack.get("engraving_lock", false)),
	})
	var items: Dictionary = lore_pack.get("items", {}) if typeof(lore_pack.get("items", {})) == TYPE_DICTIONARY else {}
	for id in items.keys():
		var entry: Dictionary = items[id] if typeof(items[id]) == TYPE_DICTIONARY else {}
		var st: String = str(entry.get("status", ""))
		var name_ref: String = str(entry.get("name_ref", id))
		out.append({
			"src": "lore",
			"cat": "Journal",
			"key": "lore.item.%s.journal" % str(id),
			"where": "Curiosities · %s (%s)" % [name_ref, st],
			"text": str(entry.get("journal", "")),
		})
		var fns: Array = entry.get("footnotes", []) if typeof(entry.get("footnotes", [])) == TYPE_ARRAY else []
		for i in fns.size():
			out.append({
				"src": "lore",
				"cat": "Journal",
				"key": "lore.item.%s.fn.%d" % [str(id), i],
				"where": "Curiosities · %s footnote %d" % [name_ref, i + 1],
				"text": str(fns[i]),
			})
	var monsters: Dictionary = lore_pack.get("monsters", {}) if typeof(lore_pack.get("monsters", {})) == TYPE_DICTIONARY else {}
	for mid in monsters.keys():
		var ment: Dictionary = monsters[mid] if typeof(monsters[mid]) == TYPE_DICTIONARY else {}
		out.append({
			"src": "lore",
			"cat": "Journal",
			"key": "lore.monster.%s.entry" % str(mid),
			"where": "Bestiary · %s (%s)" % [str(ment.get("name_ref", mid)), str(ment.get("status", ""))],
			"text": str(ment.get("entry", "")),
		})
	for letter in lore_pack.get("letters", []):
		if typeof(letter) != TYPE_DICTIONARY:
			continue
		var lid: String = str(letter.get("id", ""))
		out.append({
			"src": "lore",
			"cat": "Journal",
			"key": "lore.letter.%s.title" % lid,
			"where": "Trunk letter · %s title (unlock %s%%)" % [lid, str(letter.get("unlock_pct", ""))],
			"text": str(letter.get("title", "")),
		})
		out.append({
			"src": "lore",
			"cat": "Journal",
			"key": "lore.letter.%s.body" % lid,
			"where": "Trunk letter · %s body" % lid,
			"text": str(letter.get("body", "")),
		})
	var note: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
	if not note.is_empty():
		out.append({
			"src": "lore",
			"cat": "Drawer",
			"key": "lore.drawer.title",
			"where": "Left-hand drawer note title",
			"text": str(note.get("title", "")),
		})
		out.append({
			"src": "lore",
			"cat": "Drawer",
			"key": "lore.drawer.body",
			"where": "Left-hand drawer note body",
			"text": str(note.get("body", "")),
		})
	return out


static func card_snapshot() -> Array:
	var out: Array = []
	var board: Dictionary = _read_dict(BOARD_PATH)
	for pair in [["item", board.get("items", [])], ["monster", board.get("monsters", [])]]:
		var kind: String = str(pair[0])
		var arr: Array = pair[1] if typeof(pair[1]) == TYPE_ARRAY else []
		for card in arr:
			if typeof(card) != TYPE_DICTIONARY:
				continue
			var st: String = str(card.get("status", ""))
			if st == "retired":
				continue
			var cid: String = str(card.get("id", ""))
			var name: String = str(card.get("name", cid))
			out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.name" % [kind, cid], "where": "%s name (%s)" % [kind, st], "text": name, "author_lock": bool(card.get("author_lock", false))})
			out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.ability" % [kind, cid], "where": "%s Ability (%s)" % [kind, name], "text": str(card.get("ability", "")), "author_lock": bool(card.get("author_lock", false))})
			out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.explainer" % [kind, cid], "where": "%s Shift Text (%s)" % [kind, name], "text": str(card.get("explainer", "")), "author_lock": bool(card.get("author_lock", false))})
			out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.log_hint" % [kind, cid], "where": "%s log hover (%s)" % [kind, name], "text": str(card.get("log_hint", "")), "author_lock": bool(card.get("author_lock", false))})
			if kind == "monster":
				out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.call_name" % [kind, cid], "where": "%s Call name (%s)" % [kind, name], "text": str(card.get("call_name", "")), "author_lock": bool(card.get("author_lock", false))})
				out.append({"src": "card", "cat": "Cards", "key": "card.%s.%s.reminder" % [kind, cid], "where": "%s Shift Text (%s)" % [kind, name], "text": str(card.get("reminder", "")), "author_lock": bool(card.get("author_lock", false))})
	return out


static func save_all(rows: Array, names: Array) -> String:
	if not _save_names(names):
		return ""
	if not _save_copy(rows):
		return ""
	if not _save_lore(rows):
		return ""
	if not _save_cards(rows):
		return ""
	AUTHOR_LOCK.rebuild_ledger(last_board if not last_board.is_empty() else null, pack, names_pack)
	return ProjectSettings.globalize_path(PATH)


static func _save_names(names: Array) -> bool:
	if names_pack.is_empty():
		_load_names()
	var kept: Array = []
	var prev_by: Dictionary = names_by_id.duplicate()
	for row in names:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var nid: String = str(row.get("id", "")).strip_edges()
		if nid == "":
			continue
		var entry := {
			"id": nid,
			"display": str(row.get("display", "")),
			"note": str(row.get("note", "")),
		}
		var previous: Variant = prev_by.get(nid, {})
		if typeof(previous) != TYPE_DICTIONARY:
			previous = {}
		if bool(row.get("author_lock", false)) or bool(previous.get("author_lock", false)):
			entry["author_lock"] = true
			entry["locked_at"] = str(row.get("locked_at", previous.get("locked_at", "")))
		if AUTHOR_LOCK.differs(entry.get("display", ""), previous.get("display", "")) or AUTHOR_LOCK.differs(entry.get("note", ""), previous.get("note", "")):
			entry["author_lock"] = true
			entry["locked_at"] = Time.get_date_string_from_system()
		kept.append(entry)
	if str(names_pack.get("id", "")) == "":
		names_pack["id"] = "swipe-script-names-v1"
	names_pack["updated"] = Time.get_date_string_from_system()
	names_pack["instructions"] = "Shared proper names. Lines store {id} and {id|poss}. Script editor Save locks a changed display. Chat may not restyle locked names unless Nathan overrides."
	names_pack["names"] = kept
	if not AUTHOR_LOCK.write_json(NAMES_PATH, names_pack):
		return false
	names_by_id.clear()
	for row2 in kept:
		names_by_id[str(row2.get("id", ""))] = row2
	return true


static func _save_copy(rows: Array) -> bool:
	var kept: Array = []
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("src", "copy")) != "copy":
			continue
		if str(row.get("cat", "")) == "Cards":
			continue
		var key: String = str(row.get("key", ""))
		if key.begins_with("lore.") or key.begins_with("card."):
			continue
		var previous: Variant = by_key.get(key, {})
		if typeof(previous) != TYPE_DICTIONARY:
			previous = {}
		var entry := {
			"cat": str(row.get("cat", previous.get("cat", ""))),
			"key": key,
			"where": str(row.get("where", previous.get("where", ""))),
			"text": str(row.get("text", "")),
		}
		if bool(row.get("draft", false)) or bool(previous.get("draft", false)):
			entry["draft"] = true
		if bool(row.get("author_lock", false)):
			entry["author_lock"] = true
			entry["locked_at"] = str(row.get("locked_at", ""))
		AUTHOR_LOCK.stamp_script_row(entry, previous)
		kept.append(entry)
	if str(pack.get("id", "")) == "":
		pack["id"] = "swipe-player-copy-v2"
	pack["updated"] = Time.get_date_string_from_system()
	pack["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
	pack["rows"] = kept
	if not AUTHOR_LOCK.write_json(PATH, pack):
		return false
	by_key.clear()
	for row2 in kept:
		var k: String = str(row2.get("key", ""))
		if k != "":
			by_key[k] = row2
	_write_csv(kept)
	return true


static func _save_lore(rows: Array) -> bool:
	if lore_pack.is_empty():
		_load_lore()
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("src", "")) != "lore":
			continue
		var key: String = str(row.get("key", ""))
		var t: String = str(row.get("text", ""))
		if key == "lore.engraving":
			lore_pack["engraving"] = t
			continue
		if key == "lore.drawer.title":
			var dn: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
			dn["title"] = t
			lore_pack["drawer_note"] = dn
			continue
		if key == "lore.drawer.body":
			var dn2: Dictionary = lore_pack.get("drawer_note", {}) if typeof(lore_pack.get("drawer_note", {})) == TYPE_DICTIONARY else {}
			dn2["body"] = t
			lore_pack["drawer_note"] = dn2
			continue
		var parts: PackedStringArray = key.split(".")
		if parts.size() >= 4 and parts[1] == "item":
			var iid: String = parts[2]
			var items: Dictionary = lore_pack.get("items", {}) if typeof(lore_pack.get("items", {})) == TYPE_DICTIONARY else {}
			var ent: Dictionary = items.get(iid, {}) if typeof(items.get(iid, {})) == TYPE_DICTIONARY else {}
			if parts[3] == "journal":
				ent["journal"] = t
			elif parts[3] == "fn" and parts.size() >= 5:
				var fns: Array = ent.get("footnotes", []) if typeof(ent.get("footnotes", [])) == TYPE_ARRAY else []
				var idx: int = int(parts[4])
				while fns.size() <= idx:
					fns.append("")
				fns[idx] = t
				ent["footnotes"] = fns
			items[iid] = ent
			lore_pack["items"] = items
		elif parts.size() >= 4 and parts[1] == "monster" and parts[3] == "entry":
			var monsters: Dictionary = lore_pack.get("monsters", {}) if typeof(lore_pack.get("monsters", {})) == TYPE_DICTIONARY else {}
			var ment: Dictionary = monsters.get(parts[2], {}) if typeof(monsters.get(parts[2], {})) == TYPE_DICTIONARY else {}
			ment["entry"] = t
			monsters[parts[2]] = ment
			lore_pack["monsters"] = monsters
		elif parts.size() >= 4 and parts[1] == "letter":
			var letters: Array = lore_pack.get("letters", []) if typeof(lore_pack.get("letters", [])) == TYPE_ARRAY else []
			for i in letters.size():
				if typeof(letters[i]) != TYPE_DICTIONARY:
					continue
				if str(letters[i].get("id", "")) != parts[2]:
					continue
				var let: Dictionary = letters[i]
				if parts[3] == "title":
					let["title"] = t
				elif parts[3] == "body":
					let["body"] = t
				letters[i] = let
			lore_pack["letters"] = letters
	lore_pack["updated"] = Time.get_date_string_from_system()
	return AUTHOR_LOCK.write_json(LORE_PATH, lore_pack)


static func _save_cards(rows: Array) -> bool:
	var board: Dictionary = _read_dict(BOARD_PATH)
	if board.is_empty():
		last_board = {}
		return true
	var by_card: Dictionary = {}
	for pair in [["item", board.get("items", [])], ["monster", board.get("monsters", [])]]:
		var kind: String = str(pair[0])
		var arr: Array = pair[1] if typeof(pair[1]) == TYPE_ARRAY else []
		for i in arr.size():
			if typeof(arr[i]) != TYPE_DICTIONARY:
				continue
			by_card["%s:%s" % [kind, str(arr[i].get("id", ""))]] = {"kind": kind, "idx": i, "prev": (arr[i] as Dictionary).duplicate(true)}
	var touched := false
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("src", "")) != "card" and str(row.get("cat", "")) != "Cards":
			continue
		var key: String = str(row.get("key", ""))
		var bits: PackedStringArray = key.split(".")
		if bits.size() < 4 or bits[0] != "card":
			continue
		var kind2: String = bits[1]
		var cid: String = bits[2]
		var field: String = bits[3]
		var slot: Variant = by_card.get("%s:%s" % [kind2, cid], null)
		if typeof(slot) != TYPE_DICTIONARY:
			continue
		var arr2: Array = board.get("items" if kind2 == "item" else "monsters", [])
		var idx: int = int(slot.get("idx", -1))
		if idx < 0 or idx >= arr2.size():
			continue
		var card: Dictionary = arr2[idx]
		var previous: Dictionary = slot.get("prev", {})
		if not AUTHOR_LOCK.differs(card.get(field, ""), row.get("text", "")):
			continue
		card[field] = str(row.get("text", ""))
		AUTHOR_LOCK.stamp_card(card, previous, true)
		arr2[idx] = card
		board["items" if kind2 == "item" else "monsters"] = arr2
		touched = true
	last_board = board
	if not touched:
		return true
	board["updated"] = Time.get_date_string_from_system()
	return AUTHOR_LOCK.write_json(BOARD_PATH, board)


static func save_script(rows: Array) -> String:
	return save_all(rows, name_rows())


static func _csv_cell(s: String) -> String:
	if s.contains(",") or s.contains("\"") or s.contains("\n") or s.contains("\r"):
		return "\"%s\"" % s.replace("\"", "\"\"")
	return s


static func _write_csv(script: Array) -> void:
	var path: String = ProjectSettings.globalize_path(CSV_PATH)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		f = FileAccess.open(CSV_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string("\uFEFF")
	f.store_line("category,key,where,text")
	var all: Array = script.duplicate()
	all.append_array(card_snapshot())
	for row in all:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		f.store_line("%s,%s,%s,%s" % [
			_csv_cell(str(row.get("cat", ""))),
			_csv_cell(str(row.get("key", ""))),
			_csv_cell(str(row.get("where", ""))),
			_csv_cell(str(row.get("text", ""))),
		])
