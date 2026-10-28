extends RefCounted
## Compact ring buffer for playtest reports. Last 500 events ride along with F2.

const CAP := 500

var _events: Array = []


func push(kind: String, msg: String, extra: Dictionary = {}) -> void:
	var row := {
		"t": Time.get_ticks_msec(),
		"kind": kind,
		"msg": msg,
	}
	if not extra.is_empty():
		row["x"] = extra
	_events.append(row)
	if _events.size() > CAP:
		_events = _events.slice(_events.size() - CAP)


func dump() -> Array:
	return _events.duplicate(true)


func dump_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	for ev in _events:
		if typeof(ev) != TYPE_DICTIONARY:
			continue
		lines.append("%s %s %s" % [ev.get("t", 0), ev.get("kind", ""), ev.get("msg", "")])
	return "\n".join(lines)


func clear() -> void:
	_events.clear()
