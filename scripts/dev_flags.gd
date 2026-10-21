extends Object
class_name DevFlags
## Editor/debug chrome that never ships. Player exports never see Quick Start.

static var quick_start: bool = true
## Archived Long Drop / Challenge Mode. Flip on in the editor to show the route again.
const SHOW_LONG_DROP := false
## Archived 8-seat Gatehouse (Door draft, passes, starter kit). Flip on in the editor to restore it.
const SHOW_OLD_GATEHOUSE := false


static func show_quick_start() -> bool:
	return DevFlag.on() and quick_start


static func show_long_drop() -> bool:
	return DevFlag.on() and SHOW_LONG_DROP


static func show_old_gatehouse() -> bool:
	return DevFlag.on() and SHOW_OLD_GATEHOUSE
