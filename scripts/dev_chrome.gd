extends Object
class_name DevChrome
## Editor-only dummy chrome (branch tag, copy stamp, map cheats).
## Off by default for normal play / playtest; F11 toggles. BuildStamp + Feedback stay.

static var enabled: bool = false
static var _listeners: Array = []


static func on() -> bool:
	return enabled


static func set_enabled(want: bool) -> void:
	var next: bool = bool(want)
	if enabled == next:
		return
	enabled = next
	_notify()


static func toggle() -> bool:
	enabled = not enabled
	_notify()
	return enabled


## Register a Callable(bool) that receives the new enabled state.
static func listen(cb: Callable) -> void:
	if cb.is_null():
		return
	_listeners.append(cb)
	## Push current state so late listeners match the toggle.
	if cb.is_valid():
		cb.call(enabled)


static func _notify() -> void:
	var keep: Array = []
	for cb in _listeners:
		if typeof(cb) != TYPE_CALLABLE:
			continue
		var call := cb as Callable
		if not call.is_valid():
			continue
		keep.append(call)
		call.call(enabled)
	_listeners = keep
