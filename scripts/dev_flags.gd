extends Object
class_name DevFlags
## Editor/debug chrome that never ships. Player exports never see Quick Start.

static var quick_start: bool = true


static func show_quick_start() -> bool:
	return DevFlag.on() and quick_start
