class_name ReviewStage
extends Object
## Wave for new cards: rough → refined → polish → finished.

const STAGES := ["rough", "refined", "polish", "finished"]


static func of_card(card: Dictionary) -> String:
	var s: String = str(card.get("review", "")).strip_edges().to_lower()
	if STAGES.has(s):
		return s
	return "polish"


static func rank(stage: String) -> int:
	var i: int = STAGES.find(stage)
	return i if i >= 0 else 2


static func item_type(card: Dictionary) -> String:
	var ops: Variant = card.get("ops", {})
	if typeof(ops) != TYPE_DICTIONARY:
		return "other"
	var kind: String = str((ops as Dictionary).get("kind", "")).to_lower()
	if kind.begins_with("atk"):
		return "atk"
	if kind.begins_with("blk"):
		return "blk"
	if kind.begins_with("defeat") or kind == "fangs":
		return "defeat"
	if kind.begins_with("heal"):
		return "heal"
	if kind == "choose":
		return "choose"
	if kind == "smoke" or kind == "skip_swing":
		return "exit"
	if kind.begins_with("mark") or kind == "hook_swap":
		return "mark"
	if kind == "passive":
		return "passive"
	if kind == "":
		return "other"
	return kind
