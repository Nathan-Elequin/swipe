class_name ModePool
extends RefCounted

## Which dungeon modes a card may appear in.
## Stored on the board / catalog as "all" | "adventure" | "challenge".

const ALL := "all"
const ADVENTURE := "adventure"
const CHALLENGE := "challenge"
const LABELS := ["All", "Adventure-Only", "Challenge-Only"]
const IDS := [ALL, ADVENTURE, CHALLENGE]


static func parse(v: Variant) -> String:
	var s: String = str(v).strip_edges().to_lower()
	s = s.replace(" ", "").replace("_", "-")
	if s == "adventure" or s == "adventure-only" or s == "adventureonly":
		return ADVENTURE
	if s == "challenge" or s == "challenge-only" or s == "challengeonly":
		return CHALLENGE
	return ALL


static func label_of(v: Variant) -> String:
	var id: String = parse(v)
	if id == ADVENTURE:
		return "Adventure-Only"
	if id == CHALLENGE:
		return "Challenge-Only"
	return "All"


static func allows(card: Dictionary, mode: String) -> bool:
	var want: String = parse(mode)
	if want == ALL:
		return true
	var have: String = parse(card.get("mode_pool", ALL))
	if have == ALL:
		return true
	return have == want
