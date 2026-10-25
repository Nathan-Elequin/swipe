extends SceneTree
## SP-30: combat FX budget + the combat-stage / wheel / hall hooks. No main boot.

func _init() -> void:
	var budget = load("res://scripts/combat_fx_budget.gd")
	if budget == null:
		push_error("combat_fx_budget failed to parse")
		quit(1)
		return
	budget.reset()
	if budget.heavy() or budget.heavy_count() != 0:
		push_error("budget must start empty")
		quit(1)
		return
	if budget.is_heavy_state("idle") or budget.is_heavy_state("lowhp"):
		push_error("idle/lowhp must not be heavy")
		quit(1)
		return
	for state in ["use", "attack", "grab", "heal", "swipe", "hit", "block", "run"]:
		if not budget.is_heavy_state(state):
			push_error("missing heavy state %s" % state)
			quit(1)
			return
	budget.begin_heavy()
	if not budget.heavy() or not budget.hold_low_priority_idles():
		push_error("begin_heavy should hold low-priority idles")
		quit(1)
		return
	if budget.decor_step() <= 0.0:
		push_error("heavy FX must cap decorative redraws")
		quit(1)
		return
	budget.begin_heavy()
	if budget.heavy_count() != 2:
		push_error("heavy tokens must stack")
		quit(1)
		return
	budget.end_heavy()
	if not budget.heavy():
		push_error("one leftover token must still be heavy")
		quit(1)
		return
	budget.end_heavy()
	budget.end_heavy()
	if budget.heavy() or budget.heavy_count() != 0:
		push_error("end_heavy must clamp at zero")
		quit(1)
		return
	if budget.decorative_fps() < 0.0:
		push_error("decorative_fps must not be negative")
		quit(1)
		return
	var hooks := {
		"res://scripts/combat_stage.gd": ["hold_low_priority_idles", "_portrait_dirty"],
		"res://scripts/dungeon_bg.gd": ["hold_low_priority_idles", "FLICKER_STEP"],
		"res://scripts/boss_wheel.gd": ["_queue_decor_redraw", "hold_low_priority_idles"],
		"res://scripts/player_stage.gd": ["is_heavy_state", "begin_heavy"],
		"res://scripts/item_card.gd": ["hold_low_priority_idles"],
		"res://scripts/ability_slash.gd": ["begin_heavy", "end_heavy"],
		"res://scripts/main.gd": ["_fight_art_sig"],
	}
	for path in hooks.keys():
		var src: String = FileAccess.get_file_as_string(path)
		if src == "":
			push_error("missing %s" % path)
			quit(1)
			return
		for needle in hooks[path]:
			if not src.contains(str(needle)):
				push_error("%s is missing %s" % [path, needle])
				quit(1)
				return
	print("COMBAT_FX_BUDGET_OK")
	quit(0)
