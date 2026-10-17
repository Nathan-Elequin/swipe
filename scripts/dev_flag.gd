extends Object
class_name DevFlag
## Editor-only chrome. Player exports never see Play Latest, Roster, Script, Developer Mode, or the copy stamp.

static func on() -> bool:
	return OS.has_feature("editor")
