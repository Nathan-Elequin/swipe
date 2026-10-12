extends Object
## Read-only dump of Swipe combat state for QA.
## Not in the Web export (see export_presets.cfg exclude_filter).
## From godot_exec, in the running game:
##   var QaProbe = load("res://tools/qa/qa_probe.gd")
##   return QaProbe.dump(get_tree().current_scene)

static func dump(main: Node) -> Dictionary:
	if main == null:
		return {"error": "no current scene"}
	var facing: Dictionary = {}
	var fi: int = int(main.get("facing_index"))
	var wheel: Array = main.get("wheel")
	if fi >= 0 and fi < wheel.size() and typeof(wheel[fi]) == TYPE_DICTIONARY:
		facing = _card(wheel[fi])
	var owners: Array = []
	for c in wheel:
		if typeof(c) == TYPE_DICTIONARY:
			owners.append(_card(c))
	var hand: Array = []
	for it in main.get("hotbar"):
		if typeof(it) == TYPE_DICTIONARY:
			hand.append(_item(it))
	var gate: Node = main.get("draft_gate")
	var gate_info: Dictionary = {}
	if gate != null and gate.has_method("qa_snapshot"):
		gate_info = gate.qa_snapshot()
	elif gate != null:
		gate_info = {"visible": bool(gate.get("visible")), "mode": str(gate.get("mode"))}
	var hud: Node = main.get("hud")
	var layout: Dictionary = {}
	if hud != null and hud.has_method("qa_layout"):
		layout = hud.qa_layout()
	var pending: Dictionary = main.get("pending_item") if typeof(main.get("pending_item")) == TYPE_DICTIONARY else {}
	var spin: Control = main.get("btn_spin") as Control
	var done: Control = main.get("btn_done") as Control
	var leave: Control = null
	if gate != null and gate.has_method("leave_btn"):
		leave = gate.call("leave_btn") as Control
	var hearts: Control = main.get("hearts_box") as Control
	return {
		"phase": str(main.get("phase")),
		"draft_action": str(main.get("draft_action")),
		"hp": int(main.get("hp")),
		"blk": int(main.get("blk")),
		"facing_index": fi,
		"facing": facing,
		"wheel": owners,
		"hotbar": hand,
		"refusals_left": int(main.get("refusals_left")),
		"pending_item": str(pending.get("name", "")),
		"pending_item_id": str(pending.get("card_id", "")),
		"in_tutorial": bool(main.get("in_tutorial")),
		"cue": str(main.get("_cue_shown")),
		"adventure": bool(main.get("adventure")),
		"last_mob_hp": int(main.get("last_mob_hp")),
		"draft_gate": gate_info,
		"layout": layout,
		"buttons": {
			"spin_visible": spin.visible if spin else false,
			"spin_disabled": spin.disabled if spin else true,
			"spin_filter": spin.mouse_filter if spin else -1,
			"done_visible": done.visible if done else false,
			"done_disabled": done.disabled if done else true,
			"done_filter": done.mouse_filter if done else -1,
			"done_text": done.text if done else "",
			"leave_visible": leave.visible if leave else false,
			"leave_disabled": leave.disabled if leave else true,
			"leave_filter": leave.mouse_filter if leave else -1,
			"hearts_visible": hearts.visible if hearts else false,
			"play_log": bool(main.get("_play_log_enabled")),
		},
	}


static func _card(d: Dictionary) -> Dictionary:
	return {
		"card_id": str(d.get("card_id", "")),
		"name": str(d.get("name", "")),
		"kind": str(d.get("kind", "")),
		"atk": int(d.get("atk", 0)),
		"hp": int(d.get("hp", 0)),
		"silenced": bool(d.get("silenced", false)),
		"pack_tier": int(d.get("pack_tier", d.get("tier", 0))),
	}


static func _item(d: Dictionary) -> Dictionary:
	return {
		"card_id": str(d.get("card_id", "")),
		"name": str(d.get("name", "")),
		"spent": bool(d.get("spent", false)),
		"keep_after": bool(d.get("keep_after", false)),
		"ops_kind": str((d.get("ops", {}) as Dictionary).get("kind", "")),
		"alt_n": int(d.get("alt_n", 0)),
	}


## Find a Button whose text matches (exact, then contains). Emits pressed.
## Testing only — does not edit scenes on disk.
static func press_button(root: Node, label: String) -> String:
	var hit: Button = _find_button(root, label)
	if hit == null:
		return "no button matching '%s'" % label
	if hit.disabled:
		return "button '%s' is disabled" % label
	hit.pressed.emit()
	return "pressed:%s" % hit.text


static func _find_button(n: Node, label: String) -> Button:
	if n is Button:
		var t: String = (n as Button).text.strip_edges()
		if t == label or t.contains(label):
			return n
	for c in n.get_children():
		var found: Button = _find_button(c, label)
		if found:
			return found
	return null
