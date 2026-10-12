extends SceneTree
## Headless parse of How to Play. Not shipped in the Web export.

func _init() -> void:
	var g = load("res://scripts/tutorial_guide.gd").new()
	var beats: Array = g._load_beats()
	var waits := {}
	for b in beats:
		var w: String = str(b.get("wait", ""))
		waits[w] = int(waits.get(w, 0)) + 1
	var needed := ["spin", "item:sai", "auto_spin", "item:helmet", "done", "choice", "hover_shift"]
	var missing: Array[String] = []
	for n in needed:
		if not waits.has(n):
			missing.append(n)
	var helmet_focus := false
	for b in beats:
		if str(b.get("wait", "")) == "item:helmet" and str(b.get("focus", "")) == "item:helmet":
			helmet_focus = true
	print("TUT_BEATS %s" % beats.size())
	print("TUT_WAITS %s" % waits)
	print("TUT_MISSING %s" % ",".join(missing))
	print("TUT_HELMET_FOCUS %s" % helmet_focus)
	print("TUT_BOOT %s" % _has_branch(beats, "boot"))
	print("TUT_TAKE %s" % _has_branch(beats, "take"))
	if beats.size() < 20 or not missing.is_empty() or not helmet_focus:
		push_error("tutorial beats failed")
		quit(1)
	else:
		print("TUT_OK")
		quit(0)


func _has_branch(beats: Array, name: String) -> bool:
	for b in beats:
		if str(b.get("branch", "")) == name:
			return true
	return false
