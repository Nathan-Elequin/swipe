extends Object
## Call name and Shift line come from the card Save. Empty means empty.


static func call_of(_id: String, card: Dictionary = {}) -> String:
	return str(card.get("call_name", "")).strip_edges()


static func reminder_of(_id: String, card: Dictionary = {}) -> String:
	return str(card.get("reminder", "")).strip_edges()
