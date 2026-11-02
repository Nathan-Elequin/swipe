extends Object
## Official editor boxes (HP, ATK, Ability, …) leave the same kind of unread mark as the gold box.
## Chat reads data/editor-pending.json every message. Save writes it. Clearing it is the agent's job after applying.

const PATH := "res://data/editor-pending.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")

const FIELDS := [
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
	"pool",
	"status",
	"mode_pool",
]


static func stamp(kind: String, card_id: String, previous: Dictionary, card: Dictionary) -> void:
	var cid: String = card_id.strip_edges()
	if cid == "" or kind.strip_edges() == "":
		return
	var diffs: Dictionary = {}
	for f in FIELDS:
		var before: Variant = previous.get(f)
		var after: Variant = card.get(f)
		if _same(before, after):
			continue
		diffs[str(f)] = {"from": before, "to": after}
	if diffs.is_empty():
		return
	var data: Dictionary = _read()
	if data.is_empty():
		data = {"id": "boss-rush-editor-pending", "cards": {}}
	var cards: Dictionary = data.get("cards", {})
	if typeof(cards) != TYPE_DICTIONARY:
		cards = {}
	var key: String = "%s:%s" % [kind, cid]
	var row: Dictionary = {}
	if typeof(cards.get(key, null)) == TYPE_DICTIONARY:
		row = (cards[key] as Dictionary).duplicate(true)
	var fields: Dictionary = {}
	if typeof(row.get("fields", null)) == TYPE_DICTIONARY:
		fields = (row["fields"] as Dictionary).duplicate(true)
	for f2 in diffs.keys():
		fields[str(f2)] = diffs[f2]
	row["name"] = str(card.get("name", previous.get("name", cid)))
	row["kind"] = kind
	row["id"] = cid
	row["fields"] = fields
	row["saved_at"] = Time.get_datetime_string_from_system(true)
	cards[key] = row
	data["id"] = "boss-rush-editor-pending"
	data["updated"] = Time.get_datetime_string_from_system(true)
	data["cards"] = cards
	AUTHOR_LOCK.write_json(PATH, data)
	card["pending_fields"] = fields.duplicate(true)


static func _same(a: Variant, b: Variant) -> bool:
	if a == null and b == null:
		return true
	var ta: int = typeof(a)
	var tb: int = typeof(b)
	if (ta == TYPE_INT or ta == TYPE_FLOAT) and (tb == TYPE_INT or tb == TYPE_FLOAT):
		return float(a) == float(b)
	if ta == TYPE_NIL:
		return str(b).strip_edges() == "" or b == null
	if tb == TYPE_NIL:
		return str(a).strip_edges() == "" or a == null
	return AUTHOR_LOCK.fingerprint(a) == AUTHOR_LOCK.fingerprint(b)


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
