extends Object
## Progress provider for title board + goal ticker.
## Visual PR ships a stub. Spin replaces snapshot() with real save reads.


const SLUGS: Array[String] = [
	"verdant",
	"crystal",
	"ashen",
	"cinder",
	"shadow",
]

const SLUG_FULL := {
	"verdant": "verdant_hollow",
	"crystal": "crystal_cavern",
	"ashen": "ashen_crypt",
	"cinder": "cinder_forge",
	"shadow": "shadow_abyss",
}


## Stub: all gray except Verdant entered at 0%.
static func snapshot() -> Dictionary:
	var out := {}
	for slug in SLUGS:
		if slug == "verdant":
			out[slug] = {"state": &"entered", "pct": 0}
		else:
			out[slug] = {"state": &"gray", "pct": 0}
	return out


static func full_slug(slug: String) -> String:
	return str(SLUG_FULL.get(slug, slug))
