extends Object
## Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save.

const PATH := "res://data/player-copy.json"
const CSV_PATH := "res://data/player-copy.csv"
const BOARD_PATH := "res://data/content-board.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")

static var pack: Dictionary = {}
static var by_key: Dictionary = {}


static func reload() -> void:
	pack = {}
	by_key = {}
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	pack = parsed
	for row in pack.get("rows", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var k: String = str(row.get("key", ""))
		if k != "":
			by_key[k] = row


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


static func text(key: String, fallback: String = "") -> String:
	if by_key.is_empty():
		reload()
	var row: Variant = by_key.get(key, null)
	if typeof(row) != TYPE_DICTIONARY:
		return fallback
	var t: String = str(row.get("text", ""))
	return t if t != "" else fallback


static func fill(key: String, vars: Dictionary, fallback: String = "") -> String:
	var t: String = text(key, fallback)
	for k in vars.keys():
		t = t.replace("{%s}" % str(k), str(vars[k]))
	return t


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
		out.append(row)
	return out


static func card_snapshot() -> Array:
	var out: Array = []
	var f := FileAccess.open(BOARD_PATH, FileAccess.READ)
	if f == null:
		return out
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return out
	var board: Dictionary = parsed
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
			out.append({"cat": "Cards", "key": "card.%s.%s.name" % [kind, cid], "where": "Roster · %s name (%s)" % [kind, st], "text": name})
			out.append({"cat": "Cards", "key": "card.%s.%s.ability" % [kind, cid], "where": "Roster · %s player text (%s)" % [kind, name], "text": str(card.get("ability", ""))})
			out.append({"cat": "Cards", "key": "card.%s.%s.explainer" % [kind, cid], "where": "Roster · %s Shift math (%s)" % [kind, name], "text": str(card.get("explainer", ""))})
			out.append({"cat": "Cards", "key": "card.%s.%s.log_hint" % [kind, cid], "where": "Roster · %s log hover (%s)" % [kind, name], "text": str(card.get("log_hint", ""))})
			if kind == "monster":
				out.append({"cat": "Cards", "key": "card.%s.%s.call_name" % [kind, cid], "where": "Roster · %s call name (%s)" % [kind, name], "text": str(card.get("call_name", ""))})
				out.append({"cat": "Cards", "key": "card.%s.%s.reminder" % [kind, cid], "where": "Roster · %s Shift line (%s)" % [kind, name], "text": str(card.get("reminder", ""))})
	return out


static func save_script(rows: Array) -> String:
	var kept: Array = []
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if str(row.get("cat", "")) == "Cards":
			continue
		var key: String = str(row.get("key", ""))
		var entry := {
			"cat": str(row.get("cat", "")),
			"key": key,
			"where": str(row.get("where", "")),
			"text": str(row.get("text", "")),
		}
		if bool(row.get("author_lock", false)):
			entry["author_lock"] = true
			entry["locked_at"] = str(row.get("locked_at", ""))
		var previous: Variant = by_key.get(key, {})
		if typeof(previous) != TYPE_DICTIONARY:
			previous = {}
		AUTHOR_LOCK.stamp_script_row(entry, previous)
		kept.append(entry)
	if str(pack.get("id", "")) == "":
		pack["id"] = "swipe-player-copy-v2"
	pack["updated"] = Time.get_date_string_from_system()
	pack["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
	pack["rows"] = kept
	if not AUTHOR_LOCK.write_json(PATH, pack):
		return ""
	by_key.clear()
	for row2 in kept:
		var k: String = str(row2.get("key", ""))
		if k != "":
			by_key[k] = row2
	_write_csv(kept)
	AUTHOR_LOCK.rebuild_ledger(null, pack)
	return ProjectSettings.globalize_path(PATH)


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
