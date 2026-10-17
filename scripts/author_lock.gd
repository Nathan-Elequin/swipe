extends Object
## Nathan's editor Save stamps these. Chat may not rewrite locked fields unless he clearly overrides, and must stop and ask first.

const BOARD_PATH := "res://data/content-board.json"
const COPY_PATH := "res://data/player-copy.json"
const LEDGER_PATH := "res://data/author-locks.json"

const CARD_FIELDS := [
	"name",
	"ability",
	"explainer",
	"call_name",
	"reminder",
	"log_hint",
	"flow",
	"notes",
	"ops",
	"rarity",
	"tier",
	"count",
	"priority",
	"atk_base",
	"hp_base",
	"atk_formula",
	"hp_formula",
	"card_color",
]


static func fingerprint(v: Variant) -> String:
	if v == null:
		return ""
	var t: int = typeof(v)
	if t == TYPE_DICTIONARY or t == TYPE_ARRAY:
		return JSON.stringify(v)
	return str(v)


static func differs(a: Variant, b: Variant) -> bool:
	return fingerprint(a) != fingerprint(b)


static func stamp_card(card: Dictionary, previous: Dictionary = {}, only_changed: bool = false) -> void:
	var fields: Array = []
	var prev_f: Variant = previous.get("locked_fields", [])
	if typeof(prev_f) == TYPE_ARRAY:
		for x in prev_f:
			var s: String = str(x)
			if s != "" and not fields.has(s):
				fields.append(s)
	for f in CARD_FIELDS:
		if only_changed and not differs(card.get(f), previous.get(f)):
			continue
		if not fields.has(f):
			fields.append(f)
	if fields.is_empty():
		if bool(previous.get("author_lock", false)):
			card["author_lock"] = true
			card["locked_fields"] = prev_f if typeof(prev_f) == TYPE_ARRAY else []
			card["locked_at"] = str(previous.get("locked_at", ""))
		return
	card["author_lock"] = true
	card["locked_fields"] = fields
	card["locked_at"] = Time.get_date_string_from_system()


static func stamp_script_row(row: Dictionary, previous: Dictionary = {}) -> void:
	var was: bool = bool(row.get("author_lock", false)) or bool(previous.get("author_lock", false))
	var changed: bool = differs(row.get("text", ""), previous.get("text", ""))
	if not was and not changed:
		return
	row["author_lock"] = true
	row["locked_at"] = Time.get_date_string_from_system()


static func rebuild_ledger(board: Variant = null, copy: Variant = null, names: Variant = null) -> void:
	var board_d: Dictionary = {}
	var copy_d: Dictionary = {}
	if typeof(board) == TYPE_DICTIONARY:
		board_d = board
	else:
		board_d = _read_json(BOARD_PATH)
	if typeof(copy) == TYPE_DICTIONARY:
		copy_d = copy
	else:
		copy_d = _read_json(COPY_PATH)
	var cards := {}
	for pair in [["item", board_d.get("items", [])], ["monster", board_d.get("monsters", [])]]:
		var kind: String = str(pair[0])
		var arr: Array = pair[1] if typeof(pair[1]) == TYPE_ARRAY else []
		for card in arr:
			if typeof(card) != TYPE_DICTIONARY:
				continue
			if not bool(card.get("author_lock", false)):
				continue
			var cid: String = str(card.get("id", ""))
			if cid == "":
				continue
			cards["%s:%s" % [kind, cid]] = {
				"name": str(card.get("name", cid)),
				"fields": card.get("locked_fields", []),
				"locked_at": str(card.get("locked_at", "")),
			}
	var script := {}
	for row in copy_d.get("rows", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if not bool(row.get("author_lock", false)):
			continue
		var k: String = str(row.get("key", ""))
		if k == "":
			continue
		script[k] = {
			"cat": str(row.get("cat", "")),
			"where": str(row.get("where", "")),
			"text": str(row.get("text", "")),
			"locked_at": str(row.get("locked_at", "")),
		}
	var names_d: Dictionary = {}
	if typeof(names) == TYPE_DICTIONARY:
		names_d = names
	else:
		names_d = _read_json("res://data/script-names.json")
	var name_locks := {}
	for nrow in names_d.get("names", []):
		if typeof(nrow) != TYPE_DICTIONARY:
			continue
		if not bool(nrow.get("author_lock", false)):
			continue
		var nid: String = str(nrow.get("id", ""))
		if nid == "":
			continue
		name_locks[nid] = {
			"display": str(nrow.get("display", "")),
			"note": str(nrow.get("note", "")),
			"locked_at": str(nrow.get("locked_at", "")),
		}
	var ledger := {
		"id": "boss-rush-author-locks",
		"updated": Time.get_date_string_from_system(),
		"instructions": "Nathan locked these by clicking Save in Roster, the card editor, the Script editor, or the HTML board. Do not restyle them. A gold-box note that replaces a field is the overwrite. If chat asks to change a locked field with no gold-box note, stop, name the keys, and wait for a yes.",
		"cards": cards,
		"script": script,
		"names": name_locks,
	}
	write_json(LEDGER_PATH, ledger)


static func write_json(res_path: String, data: Dictionary) -> bool:
	var text: String = JSON.stringify(data, "\t")
	var abs_path: String = ProjectSettings.globalize_path(res_path)
	var tmp: String = abs_path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		f = FileAccess.open(abs_path, FileAccess.WRITE)
		if f == null:
			f = FileAccess.open(res_path, FileAccess.WRITE)
		if f == null:
			push_error("Could not write %s" % res_path)
			return false
		f.store_string(text)
		f.flush()
		f.close()
		return true
	f.store_string(text)
	f.flush()
	f.close()
	if FileAccess.file_exists(abs_path):
		DirAccess.remove_absolute(abs_path)
	if DirAccess.rename_absolute(tmp, abs_path) != OK:
		var f2 := FileAccess.open(abs_path, FileAccess.WRITE)
		if f2 == null:
			f2 = FileAccess.open(res_path, FileAccess.WRITE)
		if f2 == null:
			push_error("Could not replace %s" % res_path)
			return false
		f2.store_string(text)
		f2.flush()
		f2.close()
		DirAccess.remove_absolute(tmp)
	return true


static func _read_json(path: String) -> Dictionary:
	var abs_path: String = ProjectSettings.globalize_path(path)
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var raw: String = f.get_as_text()
	f.close()
	if raw.strip_edges() == "":
		return {}
	var j := JSON.new()
	if j.parse(raw) != OK:
		push_warning("author_lock: %s line %s: %s" % [path, j.get_error_line(), j.get_error_message()])
		return {}
	if typeof(j.data) != TYPE_DICTIONARY:
		return {}
	return j.data
