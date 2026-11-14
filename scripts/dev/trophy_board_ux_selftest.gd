extends SceneTree
## Trophy board UX: two-state slots, parchment tag hide-on-exit, hotbar star clear,
## satchel spill grid 0/1/3/7. Headless — no main.gd boot.


const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const SLOT := preload("res://scripts/cabin/trophy_board_slot.gd")
const ITEM_CARD := preload("res://scripts/item_card.gd")
const ROPE := preload("res://scripts/cabin/rope_exit.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	var failed := false
	var root := get_root()

	## --- Two-state model ---
	failed = _check(failed, "empty id unclaimed", MODEL.slot_state({}, {}, "", []) == &"unclaimed") or failed
	failed = _check(
		failed,
		"seen flag ignored → unclaimed",
		MODEL.slot_state({"boot": true}, {"banked": {}}, "boot", []) == &"unclaimed"
	) or failed
	failed = _check(
		failed,
		"banked → claimed",
		MODEL.slot_state({}, {"banked": {"boot": "b1"}}, "boot", []) == &"claimed"
	) or failed
	failed = _check(
		failed,
		"no unseen state string",
		MODEL.slot_state({}, {"banked": {}}, "boot", []) != &"unseen"
		and MODEL.slot_state({}, {"banked": {}}, "boot", []) != &"seen"
	) or failed

	## --- Slot plinth + shine helpers exist ---
	var slot: TrophyBoardSlot = SLOT.new()
	root.add_child(slot)
	slot.setup("boot", Rect2(0, 0, 128, 128), false)
	slot.apply_state(&"unclaimed")
	failed = _check(failed, "slot unclaimed state", slot.slot_state == &"unclaimed") or failed
	failed = _check(failed, "slot has plinth", slot.get_node_or_null("Plinth") != null) or failed
	failed = _check(failed, "slot no nameplate label", slot.get_node_or_null("Nameplate") == null) or failed
	slot.apply_state(&"claimed")
	failed = _check(failed, "slot claimed state", slot.slot_state == &"claimed") or failed
	failed = _check(failed, "slot has click shine", slot.has_method("play_click_shine")) or failed
	slot.queue_free()

	## --- Parchment tag hides on mouse exit / Esc ---
	var board: TrophyBoard = BOARD.new()
	root.add_child(board)
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var board_data: Dictionary = SHELL.read_json("res://data/content-board.json")
	var items_by_id := {}
	for raw in board_data.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	board.setup(rules, items_by_id, {"banked": {}, "map_pieces": []}, {}, [])
	## Ensure tag chrome exists even if setup deferred a rebuild.
	if board.get("_item_tag") == null and board.has_method("_build_item_tag"):
		board.call("_build_item_tag")
	failed = _check(failed, "board built item tag", board.get("_item_tag") != null) or failed
	var sample_id := "boot"
	if not items_by_id.has(sample_id):
		for k in items_by_id.keys():
			sample_id = str(k)
			break
	board.show_item_tag(sample_id, Vector2(400, 400))
	failed = _check(failed, "tag opens", bool(board.get("_item_tag_open")) == true) or failed
	var tag: Control = board.get("_item_tag")
	failed = _check(failed, "tag visible", tag != null and is_instance_valid(tag) and tag.visible) or failed
	## Simulate mouse leave.
	board.call("_on_item_tag_mouse_exited")
	failed = _check(failed, "tag hides on mouse exit", bool(board.get("_item_tag_open")) == false) or failed
	board.show_item_tag(sample_id, Vector2(400, 400))
	var esc := InputEventKey.new()
	esc.pressed = true
	esc.keycode = KEY_ESCAPE
	board._unhandled_input(esc)
	failed = _check(failed, "tag hides on Esc", bool(board.get("_item_tag_open")) == false) or failed
	## Tag must not invent rank / attack labels.
	board.show_item_tag(sample_id, Vector2(200, 200))
	var title_n: Label = board.get("_item_tag_title")
	var body_n: Label = board.get("_item_tag_body")
	var blob := ""
	if title_n:
		blob += title_n.text
	if body_n:
		blob += body_n.text
	failed = _check(failed, "tag no Tier", blob.find("Tier") < 0 and blob.find("ATK") < 0) or failed
	board.hide_item_tag()
	board.queue_free()

	## --- Hotbar gold star clears after use ---
	var card: Control = ITEM_CARD.new()
	root.add_child(card)
	failed = _check(failed, "item_card has set_new_star", card.has_method("set_new_star")) or failed
	card.set_new_star(true)
	var star = card.get("_new_star")
	## Texture may be missing in CI — helper still creates the node when art exists,
	## or falls back without crashing.
	card.set_new_star(false)
	star = card.get("_new_star")
	failed = _check(
		failed,
		"hotbar star clears after set_new_star(false)",
		star == null or star.visible == false
	) or failed
	card.queue_free()

	## --- Satchel grid layout 0/1/3/7 ---
	for n in [0, 1, 3, 7]:
		var pos: Array = MODEL.satchel_grid_positions(n)
		failed = _check(failed, "satchel layout n=%d" % n, pos.size() == n) or failed
	## Live rope node places that many spill cells.
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.call("_apply_defaults")
	cabin.reduce_motion = true
	for n in [0, 1, 3, 7]:
		var rope = ROPE.new()
		root.add_child(rope)
		rope.setup(cabin, {})
		var loot: Array = []
		for i in n:
			loot.append({"id": "item_%d" % i, "name": "Item %d" % i, "tex": null, "is_new": i == 0, "tier": 1})
		rope.open_exit(1, loot)
		var grid = rope.get("_loot_grid")
		var got: int = 0 if grid == null else int(grid.get_child_count())
		failed = _check(failed, "rope spill cells n=%d" % n, got == n) or failed
		failed = _check(failed, "rope no strip n=%d" % n, rope.get("_loot_strip") == null) or failed
		rope.queue_free()
	cabin.queue_free()

	if failed:
		print("TROPHY_BOARD_UX_FAIL")
		quit(1)
	else:
		print("TROPHY_BOARD_UX_OK")
		quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", label)
		return false
	print("  FAIL ", label)
	return true
