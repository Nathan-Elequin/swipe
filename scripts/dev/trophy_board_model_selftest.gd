extends SceneTree
## Pure TrophyBoardModel checks. Does not boot main.gd.


const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	var failed := false
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var board: Dictionary = SHELL.read_json("res://data/content-board.json")
	var items_by_id := {}
	for raw in board.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	failed = _check(failed, "items loaded", items_by_id.size() >= 50) or failed

	var faces: Array = MODEL.faces(rules, items_by_id)
	failed = _check(failed, "five faces", faces.size() == 5) or failed
	var want_sizes := [14, 14, 14, 12, 11]
	var want_rows := [
		[3, 5, 6],
		[3, 6, 5],
		[3, 5, 6],
		[2, 5, 5],
		[2, 5, 4],
	]
	for i in faces.size():
		var f: Dictionary = faces[i]
		var ids: Array = MODEL.face_ids_flat(f)
		failed = _check(
			failed,
			"face %d size %d" % [i + 1, want_sizes[i]],
			ids.size() == want_sizes[i]
		) or failed
		var rows: Dictionary = f.get("rows", {})
		var got := [
			(rows.get(3, []) as Array).size(),
			(rows.get(2, []) as Array).size(),
			(rows.get(1, []) as Array).size(),
		]
		failed = _check(failed, "face %d rows" % (i + 1), got == want_rows[i]) or failed
		failed = _check(failed, "no smoke on board", not ids.has("smoke_bomb")) or failed

	## Membership excludes retired / hold / token / always-starter
	failed = _check(
		failed,
		"smoke not a member",
		MODEL.board_ids(rules, items_by_id, "b1").find("smoke_bomb") < 0
	) or failed

	## Layout: b1 top/bottom rects (SCREEN §2/§3)
	var b1: Dictionary = faces[0]
	var lay: Dictionary = MODEL.layout(b1)
	failed = _check(failed, "b1 normal mode", str(lay.get("mode", "")) == "normal") or failed
	var rects: Dictionary = lay.get("rects", {})
	var top_ids: Array = (b1.get("rows", {}) as Dictionary).get(3, [])
	var bot_ids: Array = (b1.get("rows", {}) as Dictionary).get(1, [])
	## Raised board (#512): pyramid tracks PYRAMID_AREA (272 − BOARD_RAISE_PX).
	var top_y: float = MODEL.PYRAMID_AREA.position.y
	var bot_y: float = top_y + 2.0 * (MODEL.SLOT_NORMAL + MODEL.VGAP_NORMAL)
	if top_ids.size() >= 1:
		var tr: Rect2 = rects[str(top_ids[0])]
		failed = _check(failed, "top y raised pyramid", is_equal_approx(tr.position.y, top_y)) or failed
		failed = _check(failed, "top x0 624", is_equal_approx(tr.position.x, 624.0)) or failed
		var last_top: Rect2 = rects[str(top_ids[top_ids.size() - 1])]
		failed = _check(
			failed,
			"top last ends 1056",
			is_equal_approx(last_top.position.x + last_top.size.x, 1056.0)
		) or failed
	if bot_ids.size() >= 1:
		var br: Rect2 = rects[str(bot_ids[0])]
		failed = _check(failed, "bottom y raised pyramid", is_equal_approx(br.position.y, bot_y)) or failed
		failed = _check(failed, "bottom x0 396", is_equal_approx(br.position.x, 396.0)) or failed

	## Compact mode: 9 tier-1 items
	var compact_face := {
		"pool_id": "bx",
		"name": "Test",
		"slug": "verdant",
		"index": 0,
		"rows": {
			3: [],
			2: [],
			1: ["a", "b", "c", "d", "e", "f", "g", "h", "i"],
		},
		"ids": ["a", "b", "c", "d", "e", "f", "g", "h", "i"],
	}
	var clay: Dictionary = MODEL.layout(compact_face)
	failed = _check(failed, "compact mode", str(clay.get("mode", "")) == "compact") or failed
	failed = _check(failed, "compact slot 80", int(clay.get("slot", 0)) == 80) or failed

	## Overflow loud fail path: 60 items → >4 compact lines
	var many: Array = []
	for n in 60:
		many.append("x%d" % n)
	var over := {
		"rows": {3: [], 2: [], 1: many},
		"ids": many,
	}
	var olay: Dictionary = MODEL.layout(over)
	failed = _check(failed, "overflow flagged", bool(olay.get("overflow", false))) or failed

	## Lights / latch / lever / slot state
	var state := {"banked": {}, "map_pieces": [], "endless_unlocked": false}
	var held: Array = []
	failed = _check(failed, "lights 0", MODEL.lights_lit(rules, state, b1, held) == 0) or failed
	var b1_ids: Array = MODEL.face_ids_flat(b1)
	for i in mini(5, b1_ids.size()):
		state["banked"][str(b1_ids[i])] = "b1"
	failed = _check(failed, "lights 5 unique", MODEL.lights_lit(rules, state, b1, held) == 5) or failed
	failed = _check(failed, "lever ready", MODEL.lever_state(rules, state, b1) == &"ready") or failed
	## Duplicate bank does not add lights (set)
	state["banked"][str(b1_ids[0])] = "b1"
	failed = _check(failed, "dup still 5", MODEL.lights_lit(rules, state, b1, held) == 5) or failed
	## Latch when next portal open
	state["map_pieces"] = ["b2"]
	failed = _check(failed, "latched 5", MODEL.lights_lit(rules, state, b1, held) == 5) or failed
	failed = _check(failed, "lever spent", MODEL.lever_state(rules, state, b1) == &"spent") or failed
	## Held subtracts before latch
	state["map_pieces"] = []
	var hold_one: Array = [str(b1_ids[0])]
	failed = _check(
		failed,
		"held subtracts",
		MODEL.lights_lit(rules, state, b1, hold_one) == 4
	) or failed

	var seen := {}
	## Two-state model: unlocked biome → unclaimed or claimed only. Old seen flags ignored.
	failed = _check(
		failed,
		"slot unclaimed when not banked",
		MODEL.slot_state(seen, {"banked": {}}, str(b1_ids[0]), []) == &"unclaimed"
	) or failed
	seen[str(b1_ids[0])] = true
	failed = _check(
		failed,
		"slot ignores old seen flag",
		MODEL.slot_state(seen, {"banked": {}}, str(b1_ids[0]), []) == &"unclaimed"
	) or failed
	failed = _check(
		failed,
		"slot claimed",
		MODEL.slot_state(seen, {"banked": {str(b1_ids[0]): "b1"}}, str(b1_ids[0]), []) == &"claimed"
	) or failed
	failed = _check(
		failed,
		"slot banked-in-hold stays claimed",
		MODEL.slot_state(
			seen,
			{"banked": {str(b1_ids[0]): "b1"}},
			str(b1_ids[0]),
			[str(b1_ids[0])]
		) == &"claimed"
	) or failed

	## Satchel spill grid: 0 / 1 / 3 / 7 items.
	failed = _check(failed, "satchel grid 0", MODEL.satchel_grid_positions(0).is_empty()) or failed
	failed = _check(failed, "satchel grid 1 count", MODEL.satchel_grid_positions(1).size() == 1) or failed
	failed = _check(failed, "satchel grid 3 count", MODEL.satchel_grid_positions(3).size() == 3) or failed
	var seven: Array = MODEL.satchel_grid_positions(7, 56.0, 5, 8.0)
	failed = _check(failed, "satchel grid 7 count", seven.size() == 7) or failed
	if seven.size() >= 7:
		## Second row starts after one cell+gap; first of row 2 is index 5.
		failed = _check(
			failed,
			"satchel grid 7 wraps to row 2",
			is_equal_approx((seven[5] as Vector2).y, 56.0 + 8.0)
		) or failed

	## item_status absorb
	failed = _check(
		failed,
		"item_status carried",
		MODEL.item_status("throwing_knife", {}, {}, ["throwing_knife"]) == MODEL.STATUS_CARRIED
	) or failed
	failed = _check(
		failed,
		"item_status banked",
		MODEL.item_status("throwing_knife", {}, {"throwing_knife": "b1"}, []) == MODEL.STATUS_BANKED
	) or failed

	## Locked face helper
	var b2: Dictionary = faces[1]
	failed = _check(
		failed,
		"b2 locked without map piece",
		MODEL.is_face_locked(rules, {"map_pieces": []}, b2)
	) or failed
	failed = _check(
		failed,
		"b2 open with map piece",
		not MODEL.is_face_locked(rules, {"map_pieces": ["b2"]}, b2)
	) or failed
	failed = _check(failed, "b1 never locked", not MODEL.is_face_locked(rules, {}, b1)) or failed

	## No Tier/ATK in board scripts (text grep via FileAccess)
	for path in [
		"res://scripts/cabin/trophy_board_model.gd",
		"res://scripts/cabin/trophy_board.gd",
		"res://scripts/cabin/trophy_board_face.gd",
		"res://scripts/cabin/trophy_board_slot.gd",
	]:
		var body := FileAccess.get_file_as_string(path)
		failed = _check(failed, "no Tier in %s" % path, body.find("Tier") < 0) or failed
		failed = _check(failed, "no ATK in %s" % path, body.find("ATK") < 0) or failed

	if failed:
		print("TROPHY_BOARD_MODEL_FAIL")
		quit(1)
	else:
		print("TROPHY_BOARD_MODEL_OK")
		quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", label)
		return false
	print("  FAIL ", label)
	return true
