class_name BiomeCabinets
extends RefCounted
## Five vertical trophy cases, one per biome pool.
## Art drop (Nearest, lossless, no mipmaps). Missing files use a tinted frame:
##   res://assets/dungeon/home/cabinets/case_verdant_hollow.png
##   res://assets/dungeon/home/cabinets/case_sunken_mire.png
##   res://assets/dungeon/home/cabinets/case_ashen_crypt.png
##   res://assets/dungeon/home/cabinets/case_cinder_forge.png
##   res://assets/dungeon/home/cabinets/case_shadow_abyss.png


const CASES: Array = [
	{
		"id": "b1",
		"name": "Verdant Hollow",
		"tint": "1c3320",
		"accent": "7dae62",
		"frame": "cabinets/case_verdant_hollow",
	},
	{
		"id": "b2",
		"name": "Sunken Mire",
		"tint": "2a2916",
		"accent": "8a7a3e",
		"frame": "cabinets/case_sunken_mire",
	},
	{
		"id": "b3",
		"name": "Ashen Crypt",
		"tint": "2c2828",
		"accent": "8d3d3d",
		"frame": "cabinets/case_ashen_crypt",
	},
	{
		"id": "b4",
		"name": "Cinder Forge",
		"tint": "241812",
		"accent": "d06a28",
		"frame": "cabinets/case_cinder_forge",
	},
	{
		"id": "b5",
		"name": "Shadow Abyss",
		"tint": "100e18",
		"accent": "4c4588",
		"frame": "cabinets/case_shadow_abyss",
	},
]

const STUB_NAMES := {
	"The Cellar": "Verdant Hollow",
	"The Warren": "Sunken Mire",
	"The Chapel": "Ashen Crypt",
	"The Vault": "Cinder Forge",
	"The Throat": "Shadow Abyss",
	"Torch Burrow": "Verdant Hollow",
	"Slime Pits": "Sunken Mire",
	"Bone Gallery": "Ashen Crypt",
	"Bog Mother": "Cinder Forge",
	"Gulp King": "Shadow Abyss",
}


static func resolved_cases(rules: Dictionary) -> Array:
	var names := {}
	var raw_biomes: Variant = rules.get("biomes", [])
	if typeof(raw_biomes) == TYPE_ARRAY:
		for raw in raw_biomes:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var biome: Dictionary = raw
			names[str(biome.get("id", ""))] = str(biome.get("name", ""))
	var out: Array = []
	for raw_spec in CASES:
		var spec: Dictionary = (raw_spec as Dictionary).duplicate()
		var fallback := str(spec.get("name", ""))
		var from_rules := str(names.get(str(spec.get("id", "")), ""))
		spec["name"] = display_name(from_rules, fallback)
		out.append(spec)
	return out


static func case_names(rules: Dictionary) -> Array:
	var out: Array = []
	for raw in resolved_cases(rules):
		out.append(str((raw as Dictionary).get("name", "")))
	return out


static func display_name(rules_name: String, fallback: String) -> String:
	var n := rules_name.strip_edges()
	if STUB_NAMES.has(n):
		return str(STUB_NAMES[n])
	if n == "":
		return fallback
	return n


static func quota_of(rules: Dictionary) -> int:
	var q := int(rules.get("cabinet_quota", 5))
	if q <= 0:
		return 5
	return q


static func pool_for_bucket(rules: Dictionary, bucket: int) -> String:
	if bucket < 0:
		return ""
	var mapped := str(rules.get("bucket_pools", {}).get(str(bucket), ""))
	if mapped != "":
		return mapped
	var idx := int(bucket / 2)
	if idx < 0:
		return ""
	if idx > 4:
		idx = 4
	return "b%d" % [idx + 1]


## Collected ids stay in swipe order. Everything else fills the remaining slots
## in a stable scatter so silhouettes do not jump on every redraw.
static func order_mounts(cards: Array, swiped_order: Array) -> Array:
	var by_id := {}
	for raw in cards:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		by_id[str(card.get("id", ""))] = card
	var out: Array = []
	for raw_id in swiped_order:
		var id := str(raw_id)
		if not by_id.has(id):
			continue
		out.append(by_id[id])
		by_id.erase(id)
	var rest: Array = []
	for key in by_id.keys():
		rest.append(by_id[key])
	rest.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ha := int(str(a.get("id", "")).hash())
		var hb := int(str(b.get("id", "")).hash())
		if ha == hb:
			return str(a.get("id", "")) < str(b.get("id", ""))
		return ha < hb
	)
	for raw_rest in rest:
		out.append(raw_rest)
	return out


## Under the gate the line is collected/5. After it, collected/pool so the case keeps filling.
static func progress_text(collected: int, total: int, quota: int = 5) -> String:
	if collected < quota:
		return "%d/%d" % [collected, quota]
	return "%d/%d" % [collected, maxi(total, collected)]


static func crossed_gate(before: int, after: int, quota: int = 5) -> bool:
	return before < quota and after >= quota


## One newly banked id per step, in arrival order, across whichever cases they belong to.
static func bank_sequence(ids: Array, pools_by_id: Dictionary) -> Array:
	var out: Array = []
	for raw in ids:
		var id := str(raw)
		if id == "":
			continue
		out.append({
			"id": id,
			"pool": str(pools_by_id.get(id, "")),
		})
	return out
