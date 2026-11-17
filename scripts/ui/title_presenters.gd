extends Object
## Biome / pool slug → default title presenter monster id.
## Art lives at assets/ui/title/presenters/{id}_present_f0..f5.png.
## Title menu rows stay goblin / gargoyle / lich; this map is for later biome hooks.


const BIOME_DEFAULT := {
	"verdant": "goblin",
	"verdant_hollow": "goblin",
	"b1": "goblin",
	"crystal": "gargoyle",
	"crystal_cavern": "gargoyle",
	"b2": "gargoyle",
	"ashen": "zombie",
	"ashen_crypt": "zombie",
	"b3": "zombie",
	"cinder": "imp",
	"cinder_forge": "imp",
	"b4": "imp",
	"shadow": "lich",
	"shadow_abyss": "lich",
	"b5": "lich",
}

const FALLBACKS := {
	"zombie": ["wraith"],
	"imp": ["plague_doctor", "cowardly_king"],
}


## Returns a monster id with present frames on disk (falls back if needed).
static func for_biome(slug: String) -> String:
	var key := str(slug).strip_edges().to_lower()
	var primary: String = str(BIOME_DEFAULT.get(key, ""))
	if primary == "":
		return "goblin"
	if _has_present(primary):
		return primary
	var alts: Array = FALLBACKS.get(primary, [])
	for alt in alts:
		if _has_present(str(alt)):
			return str(alt)
	return primary


static func present_path(monster_id: String, frame: int) -> String:
	return "res://assets/ui/title/presenters/%s_present_f%d.png" % [monster_id, frame]


static func idle_path(monster_id: String, frame: int) -> String:
	return "res://assets/dungeon/anim/facing/%s_facing_idle_f%d.png" % [monster_id, frame]


static func _has_present(monster_id: String) -> bool:
	return ResourceLoader.exists(present_path(monster_id, 0))
