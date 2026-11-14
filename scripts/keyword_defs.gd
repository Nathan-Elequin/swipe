extends Object
class_name KeywordDefs
## Loads data/keyword-defs.json. Hot-reloads when the file mtime changes.
## Bodies are Nathan's authored definitions — never invent or restyle them here.

const PATH := "res://data/keyword-defs.json"

static var _cache: Dictionary = {}
static var _mtime: int = -1


static func ids() -> PackedStringArray:
	return PackedStringArray([
		"any", "eject", "across", "bear_trap", "move", "flee", "defeated", "marked",
		"poison", "spin", "always", "swap", "loaded", "unplayable", "rust", "decay",
		"gaze", "petrify", "curse", "shroud", "toll", "hex", "beggar",
	])


static func reload(force: bool = false) -> void:
	var abs_path: String = ProjectSettings.globalize_path(PATH)
	var m: int = -1
	if FileAccess.file_exists(PATH):
		m = int(FileAccess.get_modified_time(PATH))
	elif FileAccess.file_exists(abs_path):
		m = int(FileAccess.get_modified_time(abs_path))
	if not force and m == _mtime and not _cache.is_empty():
		return
	_mtime = m
	_cache.clear()
	if not FileAccess.file_exists(PATH):
		push_warning("KeywordDefs: missing %s" % PATH)
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		push_warning("KeywordDefs: cannot read %s" % PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("KeywordDefs: invalid JSON in %s" % PATH)
		return
	for k in (parsed as Dictionary).keys():
		var id: String = str(k)
		var row: Variant = (parsed as Dictionary)[k]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = row
		_cache[id] = {
			"title": str(d.get("title", id.capitalize())),
			"body": str(d.get("body", "")),
		}


static func all_ids() -> PackedStringArray:
	reload()
	return ids()


static func title_of(id: String) -> String:
	reload()
	var key: String = id.strip_edges().to_lower()
	if _cache.has(key):
		return str((_cache[key] as Dictionary).get("title", key.capitalize()))
	return key.capitalize()


static func def_of(id: String) -> String:
	reload()
	var key: String = id.strip_edges().to_lower()
	if _cache.has(key):
		return str((_cache[key] as Dictionary).get("body", ""))
	return ""


static func entry(id: String) -> Dictionary:
	reload()
	var key: String = id.strip_edges().to_lower()
	if _cache.has(key):
		return (_cache[key] as Dictionary).duplicate()
	return {"title": key.capitalize(), "body": ""}


static func save_all(entries: Dictionary) -> bool:
	## Pretty-printed, stable key order matching ids() (not alphabetical).
	## Godot's JSON.stringify sorts object keys — build the document by hand.
	var lines: PackedStringArray = PackedStringArray()
	lines.append("{")
	var all: PackedStringArray = ids()
	for i in all.size():
		var id: String = all[i]
		var row: Variant = entries.get(id, _cache.get(id, {}))
		if typeof(row) != TYPE_DICTIONARY:
			row = {"title": id.capitalize(), "body": ""}
		var d: Dictionary = row
		var title: String = str(d.get("title", id.capitalize()))
		var body: String = str(d.get("body", ""))
		var comma: String = "," if i < all.size() - 1 else ""
		lines.append("  %s: {" % JSON.stringify(id))
		lines.append("    \"title\": %s," % JSON.stringify(title))
		lines.append("    \"body\": %s" % JSON.stringify(body))
		lines.append("  }%s" % comma)
	lines.append("}")
	lines.append("")
	var text: String = "\n".join(lines)
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_error("KeywordDefs: cannot write %s" % PATH)
		return false
	f.store_string(text)
	f.close()
	reload(true)
	return true


static func icon_path(id: String) -> String:
	return "res://assets/ui/keyword/kw_%s.png" % id.strip_edges().to_lower()


static func card_icon_path(id: String) -> String:
	return "res://assets/ui/keyword/kw_%s_card.png" % id.strip_edges().to_lower()
