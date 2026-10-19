extends Object
class_name PlaytestFlag
## Playtest Web export (`custom_features=playtest`). F5 in the editor is the same playtest game.

static func on() -> bool:
	return OS.has_feature("playtest") or OS.has_feature("editor")


static func tools() -> bool:
	return on()

