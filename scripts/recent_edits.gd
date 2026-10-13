extends Object
## Recency for Play Latest. Editor Save stamps a card. Paper Fight done files and locked_at fill in the rest.

const PATH := "res://data/recent-edits.json"
const DONE_DIR := "res://design/paper-fight/done"
const COUNT := 8
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")
const SKIP := {
	"and": true,
	"buckets": true,
	"copy": true,
	"dungeon": true,
	"even": true,
	"from": true,
	"hp": true,
	"last": true,
	"loot": true,
	"mode": true,
	"new": true,
	"notes": true,
	"owner": true,
	"redesigns": true,
	"roster": true,
	"rough": true,
	"saves": true,
	"shared": true,
	"ten": true,
	"this": true,
	"verbs": true,
	"wave": true,
	"wave2": true,
	"with": true,
}


static func touch(kind: String, id: String) -> void:
	var cid: String = id.strip_edges()
	if cid == "" or kind.strip_edges() == "":
		return
	var data: Dictionary = _read()
	if data.is_empty():
		data = {"id": "boss-rush-recent-edits", "cards": {}}
	var cards: Dictionary = data.get("cards", {})
	if typeof(cards) != TYPE_DICTIONARY:
		cards = {}
	cards["%s:%s" % [kind, cid]] = int(Time.get_unix_time_from_system())
	data["id"] = "boss-rush-recent-edits"
	data["updated"] = Time.get_datetime_string_from_system(true)
	data["cards"] = cards
	AUTHOR_LOCK.write_json(PATH, data)


static func latest_ids(kind: String, monsters_by_id: Dictionary, items_by_id: Dictionary, n: int = COUNT) -> PackedStringArray:
	var by: Dictionary = monsters_by_id if kind == "monster" else items_by_id
	var out := PackedStringArray()
	for row in ranked(monsters_by_id, items_by_id):
		if str(row.get("kind", "")) != kind:
			continue
		var cid: String = str(row.get("id", ""))
		if cid == "" or not by.has(cid) or out.has(cid):
			continue
		if _hidden(by[cid]):
			continue
		out.append(cid)
		if out.size() >= n:
			break
	return out


static func ranked(monsters_by_id: Dictionary, items_by_id: Dictionary) -> Array:
	var at := {}
	var ledger: Dictionary = _read()
	var cards: Variant = ledger.get("cards", {})
	if typeof(cards) == TYPE_DICTIONARY:
		for key in (cards as Dictionary).keys():
			at[str(key)] = int((cards as Dictionary)[key])
	_apply_locked(at, "monster", monsters_by_id)
	_apply_locked(at, "item", items_by_id)
	_apply_paper_fights(at, monsters_by_id, items_by_id)
	var rows: Array = []
	for key in at.keys():
		var bits: PackedStringArray = str(key).split(":", true, 1)
		if bits.size() != 2:
			continue
		rows.append({"kind": str(bits[0]), "id": str(bits[1]), "at": int(at[key])})
	rows.sort_custom(_newer)
	return rows


static func _newer(a: Dictionary, b: Dictionary) -> bool:
	var ta: int = int(a.get("at", 0))
	var tb: int = int(b.get("at", 0))
	if ta != tb:
		return ta > tb
	return str(a.get("id", "")) < str(b.get("id", ""))


static func _apply_locked(at: Dictionary, kind: String, by_id: Dictionary) -> void:
	for id in by_id.keys():
		var card: Dictionary = by_id[id]
		if _hidden(card):
			continue
		var unix: int = _unix_from_day(str(card.get("locked_at", "")))
		if unix <= 0:
			continue
		var key: String = "%s:%s" % [kind, id]
		at[key] = maxi(int(at.get(key, 0)), unix)


static func _apply_paper_fights(at: Dictionary, monsters_by_id: Dictionary, items_by_id: Dictionary) -> void:
	var known := {}
	for id in monsters_by_id.keys():
		known[str(id)] = "monster"
	for id2 in items_by_id.keys():
		if not known.has(str(id2)):
			known[str(id2)] = "item"
	var names: PackedStringArray = DirAccess.get_files_at(DONE_DIR)
	for fname in names:
		var file: String = str(fname)
		if not file.ends_with(".md"):
			continue
		var base: String = file.get_basename()
		if base.length() < 12:
			continue
		var day: String = base.substr(0, 10)
		if not day.contains("-"):
			continue
		var slug: String = base.substr(11)
		var unix: int = _unix_from_day(day)
		var mtime: int = int(FileAccess.get_modified_time("%s/%s" % [DONE_DIR, file]))
		if mtime > unix:
			unix = mtime
		if unix <= 0:
			continue
		for cid in _ids_from_slug(slug, known):
			var kind: String = str(known.get(cid, ""))
			if kind == "":
				continue
			var key: String = "%s:%s" % [kind, cid]
			at[key] = maxi(int(at.get(key, 0)), unix)


static func _ids_from_slug(slug: String, known: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	var full: String = slug.replace("-", "_")
	if known.has(full):
		out.append(full)
	for part in slug.split("-"):
		var p: String = str(part).strip_edges().to_lower()
		if p.length() < 4 or SKIP.has(p):
			continue
		if known.has(p):
			if not out.has(p):
				out.append(p)
			continue
		var hits := PackedStringArray()
		for id in known.keys():
			var sid: String = str(id)
			if sid.ends_with("_" + p) or sid.begins_with(p + "_"):
				hits.append(sid)
		if hits.size() == 1 and not out.has(hits[0]):
			out.append(hits[0])
	return out


static func _hidden(card: Dictionary) -> bool:
	var st: String = str(card.get("status", "live"))
	if st == "retired" or st == "hold":
		return true
	var flags: Variant = card.get("flags", {})
	if typeof(flags) == TYPE_DICTIONARY and bool((flags as Dictionary).get("hide", false)):
		return true
	return false


static func _unix_from_day(day: String) -> int:
	var bits: PackedStringArray = day.strip_edges().split("-")
	if bits.size() < 3:
		return 0
	if not str(bits[0]).is_valid_int() or not str(bits[1]).is_valid_int() or not str(bits[2]).is_valid_int():
		return 0
	return int(Time.get_unix_time_from_datetime_dict({
		"year": int(bits[0]),
		"month": int(bits[1]),
		"day": int(bits[2]),
		"hour": 12,
		"minute": 0,
		"second": 0,
	}))


static func _read() -> Dictionary:
	var abs_path: String = ProjectSettings.globalize_path(PATH)
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return {}
	var raw: String = f.get_as_text()
	f.close()
	if raw.strip_edges() == "":
		return {}
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
