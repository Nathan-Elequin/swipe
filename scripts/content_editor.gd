extends ColorRect
## In-game content sheet. Same fields as the HTML board. Save writes the repo JSON.

signal saved(kind: String, card_id: String, card: Dictionary)
signal closed

const BOARD_PATH := "res://data/content-board.json"
const AUTHOR_LOCK := preload("res://scripts/author_lock.gd")
const RECENT_EDITS := preload("res://scripts/recent_edits.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")
const LINES := preload("res://scripts/monster_lines.gd")
const UX := preload("res://scripts/ux_style.gd")
const DEFAULT_EXPLAINER := {
	"hornet_swarm": "(2) then (2)",
	"goblin": "(NO ATK DMG)",
	"skeleton": "(LAST ENEMY HP)",
	"lich": "(NEIGHBOR HP + 1)",
	"ogre": "(YOUR HP)",
	"berserker": "50% +4 Attack, otherwise lose 3 Attack",
	"dire_wolf": "(ATK = YOUR HP)",
	"bandit": "(ATK = Items)",
	"slime_boss": "(ATK = HP)",
	"wraith": "Defeated: set your HP to my most recent HP",
	"mimic": "Item if I never Attack",
	"spider_queen": "Egg on Spin. +2 HP +2 ATK each Egg",
	"commander": "(NEIGHBOR ATK + 2)",
	"dragon": "(ignores BLK)",
	"sai": "(2) then (4) then (2)…",
	"throwing_knife": "(3) or (1 and Keep)",
	"pocketwatch": "Pick any monster. They Attack the monster Across from them. Unplayable when the number of monsters is odd.",
	"medallion": "(7 − HP)",
	"helmet": "min(YOUR HP, ENEMY HP)",
	"da_boot": "(ENEMY HP < YOUR HP)",
	"bag_of_holding": "(ENEMY HP < YOUR HP). They go in the bag.",
	"measuring_tape": "(ENEMY HP = 2 × YOUR HP)",
	"bloody_gauntlets": "(7 − HP)",
	"bracers": "(Right Neighbor ATK)",
	"knucklers": "(8 − Items)",
	"spiked_flail": "(2 × Bleeds)",
	"sledgehammer": "(ENEMY ATK ≥ 6)",
	"grimoire": "(LAST ENEMY ATK)",
	"breastplate": "(BLK 2) Keep if Bleed",
	"fangs": "Take ATK → Defeat → Heal HP",
	"crossbow": "(ATK 4) Neighbor",
	"arrow_head": "(ATK 6) Lose 2 HP",
	"danger_magnet": "HIGH or LOW or Off",
	"shield": "(BLK 4)",
	"smoke_bomb": "Spin + 1 Item",
	"healing_potion": "Lethal → Heal 3",
	"poison_flask": "Neighbor −5 HP on Spin",
	"left_bracer": "(Left Neighbor ATK)",
	"double_axe": "(ATK 2) facing + Neighbors",
	"victory_flask": "(1 + Defeats)",
	"grappling_hook": "Swap Neighbor + 1 Item",
	"spiked_shield": "(ATK 2) or (BLK 2)",
	"grief_jar": "Spin: −1 HP, +2 BLK",
	"longbow": "(ATK 4) opposite",
	"lantern": "(HEAL 2) Keep if HP < 6",
	"mirror_shard": "(Last BLK)",
	"echo_bell": "(Copy last Item)",
	"quiet_bell": "Silence",
	"net": "(−1) or (−2) or (−3)",
	"iron_chain": "(ATK = BLK) Keep",
	"counting_beads": "(1) then (2) then (3) then (4)",
	"last_match": "0 ATK Items → Defeat",
	"mute_stone": "Swap 1–2 Items",
	"cursed_scroll": "(HEAL 6)  Spin: −1 HP",
	"spider_egg": "(Take ATK 2)",
	"shuriken": "Move →, then (ATK 3).",
	"miasma": "Poison all = min HP",
	"bag_of_marbles": "Fill to 10 Marbles",
	"marble": "(N ATK or N BLK)",
	"hex": "Defeat at Spin 0",
	"ale_flagon": "Heal 3, heal the Enemy 3, draw an Item",
	"napalm": "HP → 1 (you + Enemy + Neighbors)",
	"lucky_nickel": "(BLK 1) Keep if even",
	"double_buckler": "Halve next even ATK",
	"chakram": "(BLK 3 if no Block Items)  (ATK 3 if no Attack Items)",
	"signpost": "(BLK 7) then a Neighbor Attacks you",
	"sling": "Next Attack this fight can target Any",
	"ball_and_chain": "(ATK 2. Whenever you or an Enemy would Flee, cancel it. This gains +2 Attack.)",
	"recycler": "(Every 5th Discard copies that Item into your Hand.)",
	"magicat": "On Spin: 2 Atk or Blk Items become Marbles with that number",
	"rust_bucket": "When I enter the Dungeon, Gain 1 Rust",
	"rust": "Ignore Block. Discard after 3 Spins.",
	"poison_frog": "On Spin and when I take Attack damage: you Gain 2 Poison",
	"mouse": "On Spin: if your HP is higher, I lose 2 HP and Flee",
	"blood_pact": "−2 HP you and Enemy",
	"jar_o_grease": "(HEAL 1) Swap 1  Keep",
	"toll": "−1 / Item Use  Die at 0",
	"cleric": "Spin: if −3 HP, Heal 3 + worst Item",
}

var _kind: String = ""
var _id: String = ""
var _board: Dictionary = {}
var _original: Dictionary = {}
var _fields: Dictionary = {}
var _status: Label
var _bucket_warn: BucketAlertBar
var _scroll: ScrollContainer
var _sheet: VBoxContainer
var _was_paused: bool = false


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("authoring_overlay")
	visible = false
	top_level = true
	set_anchors_preset(PRESET_FULL_RECT)
	color = Color("100e0ce8")
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	z_index = 200

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("f3e6d0")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size = Vector2(720, 820)
	center.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	panel.add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	root.add_child(head)
	var title := Label.new()
	title.text = "Edit card"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("1c120c"))
	head.add_child(title)
	head.add_child(_btn("Cancel", Color("3a3220"), Color("9a8b78"), close_editor, 110))
	head.add_child(_btn("Save", Color("3a2820"), Color("c4a574"), _on_save, 110))

	var hint := Label.new()
	hint.text = "Save writes the board and catalog, and locks this card. Typed fields update inspect immediately. A gold-box note is also a real overwrite — Cursor writes it into Ability, numbers, and code on the next message. Arrows move between boxes. Space types. Enter saves. Esc closes without saving."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("6b4a10"))
	root.add_child(hint)

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	root.add_child(_status)

	_bucket_warn = BucketAlertBar.new()
	root.add_child(_bucket_warn)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size = Vector2(0, 560)
	root.add_child(_scroll)
	_sheet = VBoxContainer.new()
	_sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sheet.add_theme_constant_override("separation", 4)
	_scroll.add_child(_sheet)


func open_card(kind: String, card_id: String, catalog_card: Dictionary = {}) -> void:
	_kind = kind
	_id = card_id
	_load_board()
	var card: Dictionary = _find_card(kind, card_id)
	if card.is_empty():
		card = _from_catalog(kind, card_id, catalog_card)
	else:
		card = card.duplicate(true)
		_fill_bases_from_catalog(card, catalog_card)
	_original = card.duplicate(true)
	_rebuild(card)
	_status.text = "Editing %s · %s" % [kind, card_id]
	_was_paused = get_tree().paused
	visible = true
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var vis: Rect2 = get_viewport().get_visible_rect() if get_viewport() else Rect2()
	if vis.size.x > 8.0:
		size = vis.size
		global_position = vis.position
	move_to_front()
	get_tree().paused = true
	var vp := get_viewport()
	if vp:
		vp.gui_cancel_drag()
		vp.gui_release_focus()
	call_deferred("_focus_first_field")


func close_editor() -> void:
	visible = false
	get_tree().paused = _was_paused
	closed.emit()


func _load_board() -> void:
	var f := FileAccess.open(BOARD_PATH, FileAccess.READ)
	if f == null:
		_board = {"id": "boss-rush-content-board", "updated": "", "monsters": [], "items": []}
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		_board = parsed
	else:
		_board = {"id": "boss-rush-content-board", "updated": "", "monsters": [], "items": []}


func _find_card(kind: String, card_id: String) -> Dictionary:
	var arr: Array = _board.get("monsters" if kind == "monster" else "items", [])
	for c in arr:
		if str(c.get("id", "")) == card_id:
			return c
	return {}


func _from_catalog(kind: String, card_id: String, cat: Dictionary) -> Dictionary:
	var atk: Variant = cat.get("atk", {})
	var hp: Variant = cat.get("hp", {})
	var atk_d: Dictionary = atk if typeof(atk) == TYPE_DICTIONARY else {}
	var hp_d: Dictionary = hp if typeof(hp) == TYPE_DICTIONARY else {}
	return {
		"id": card_id,
		"name": str(cat.get("name", card_id)),
		"kind": kind,
		"status": "live",
		"rarity": str(cat.get("rarity", "starter")),
		"tier": int(cat.get("tier", 1)),
		"count": int(cat.get("count", 1)),
		"priority": int(cat.get("priority", 3)),
		"atk_base": atk_d.get("base", null),
		"hp_base": hp_d.get("base", null),
		"atk_formula": str(atk_d.get("formula", "")),
		"hp_formula": str(hp_d.get("formula", "")),
		"ability": str(cat.get("ability", "")),
		"explainer": str(cat.get("explainer", "")),
		"call_name": str(cat.get("call_name", "")),
		"log_hint": str(cat.get("log_hint", "")),
		"reminder": str(cat.get("reminder", "")),
		"card_color": str(cat.get("card_color", "")),
		"flow": str(cat.get("defined", "")),
		"notes": str(cat.get("exceptions", cat.get("notes", ""))),
		"ops": cat.get("ops", {}),
		"contradiction_ids": [],
		"review": REVIEW_STAGE.of_card(cat),
		"review_note": str(cat.get("review_note", "")),
		"mode_pool": ModePool.parse(cat.get("mode_pool", "all")),
	}


func _fill_bases_from_catalog(card: Dictionary, cat: Dictionary) -> void:
	if cat.is_empty():
		return
	var atk: Variant = cat.get("atk", {})
	var hp: Variant = cat.get("hp", {})
	var atk_d: Dictionary = atk if typeof(atk) == TYPE_DICTIONARY else {}
	var hp_d: Dictionary = hp if typeof(hp) == TYPE_DICTIONARY else {}
	if card.get("atk_base") == null and atk_d.has("base"):
		card["atk_base"] = atk_d.get("base")
	if card.get("hp_base") == null and hp_d.has("base"):
		card["hp_base"] = hp_d.get("base")
	if str(card.get("atk_formula", "")).strip_edges() == "" and str(atk_d.get("formula", "")) != "":
		card["atk_formula"] = str(atk_d.get("formula", ""))
	if str(card.get("hp_formula", "")).strip_edges() == "" and str(hp_d.get("formula", "")) != "":
		card["hp_formula"] = str(hp_d.get("formula", ""))


func _explainer_shown(card: Dictionary) -> String:
	var ex: String = str(card.get("explainer", "")).strip_edges()
	if ex != "" and ex != "---":
		return ex
	return str(DEFAULT_EXPLAINER.get(str(card.get("id", "")), ""))


func _rebuild(card: Dictionary) -> void:
	_fields.clear()
	for c in _sheet.get_children():
		_sheet.remove_child(c)
		c.queue_free()
	var is_m: bool = _kind == "monster"
	_label_head("%s" % str(card.get("name", _id)))
	if bool(card.get("author_lock", false)):
		var lock_n := Label.new()
		lock_n.text = "Locked by your last Save. Chat will not restyle these. A gold-box note that replaces a field is the overwrite."
		lock_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lock_n.add_theme_font_size_override("font_size", 14)
		lock_n.add_theme_color_override("font_color", Color("6b1008"))
		_sheet.add_child(lock_n)
	var stage: String = REVIEW_STAGE.of_card(card)
	if stage == "rough":
		var banner := Label.new()
		banner.text = "ROUGH — type what to change in the gold box. Save is a real overwrite. The next Cursor message writes this into Ability, numbers, and code."
		banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		banner.add_theme_font_size_override("font_size", 18)
		banner.add_theme_color_override("font_color", Color("8b1e1e"))
		_sheet.add_child(banner)
	var rev_row := _grid(2)
	_add_pick(rev_row, "Review", "review", stage, REVIEW_STAGE.STAGES)
	_sheet.add_child(rev_row)
	_add_review_note(_sheet, str(card.get("review_note", "")), stage)
	if _fields.has("review") and _fields["review"] is OptionButton:
		(_fields["review"] as OptionButton).item_selected.connect(_on_review_pick)
	var row1 := _grid(2)
	_add_line(row1, "Name", "name", str(card.get("name", "")))
	_add_line(row1, "Id", "id", str(card.get("id", _id)), true)
	_sheet.add_child(row1)
	var row2 := _grid(3)
	_add_pick(row2, "Status", "status", str(card.get("status", "live")), ["live", "todo", "hold", "retired"])
	_add_pick(row2, "Rarity", "rarity", str(card.get("rarity", "starter")), ["starter", "uncommon"])
	var bucket_opts: Array = []
	for bucket_label in BucketRules.options():
		bucket_opts.append(bucket_label)
	_add_pick(row2, "Bucket", "bucket", BucketRules.label_of(card.get("bucket", 0)), bucket_opts)
	_sheet.add_child(row2)
	var row_mode := _grid(2)
	_add_pick(row_mode, "Modes", "mode_pool", ModePool.label_of(card.get("mode_pool", "all")), ["All", "Adventure-Only", "Challenge-Only"])
	_sheet.add_child(row_mode)
	if _fields.has("bucket") and _fields["bucket"] is OptionButton:
		var bucket_pick: OptionButton = _fields["bucket"]
		BucketRules.paint(bucket_pick)
		bucket_pick.item_selected.connect(func(_i: int) -> void:
			BucketRules.paint(bucket_pick)
			_refresh_bucket_warn()
		)
	_refresh_bucket_warn()
	var row_tier := _grid(3)
	_add_line(row_tier, "Tier", "tier", _num_s(card.get("tier", 1)))
	_sheet.add_child(row_tier)
	var row3 := _grid(3)
	_add_line(row3, "Count", "count", _num_s(card.get("count", 1)))
	_add_line(row3, "Priority", "priority", _num_s(card.get("priority", 3)))
	if is_m:
		_add_line(row3, "ATK base", "atk_base", _num_s(card.get("atk_base", 0)))
	else:
		_add_line(row3, "", "_pad", "")
	_sheet.add_child(row3)
	if is_m:
		var row4 := _grid(2)
		_add_line(row4, "HP base", "hp_base", _num_s(card.get("hp_base", 0)))
		_add_line(row4, "ATK formula", "atk_formula", str(card.get("atk_formula", "")))
		_sheet.add_child(row4)
		_add_area(_sheet, "HP formula", "hp_formula", str(card.get("hp_formula", "")), 48, false)
		var stat_n := Label.new()
		var af: String = str(card.get("atk_formula", "")).strip_edges()
		if af != "":
			stat_n.text = "ATK base is the printed number. This owner’s live Attack uses the formula (%s), so changing ATK base will not change the number on the wheel." % af
		else:
			stat_n.text = "ATK base and HP base are the printed numbers the fight uses, unless a formula is filled in."
		stat_n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stat_n.add_theme_font_size_override("font_size", 13)
		stat_n.add_theme_color_override("font_color", Color("6b4a10"))
		_sheet.add_child(stat_n)
	_add_area(_sheet, "Ability (player-facing, short)", "ability", str(card.get("ability", "")), 90, false)
	if _kind == "monster":
		_add_area(_sheet, "Inspect extra (if Ability is empty)", "explainer", _explainer_shown(card), 80, false)
		_add_line(_sheet, "Call name (subtitle under the title)", "call_name", str(card.get("call_name", LINES.call_of(str(card.get("id", "")), card))))
		_add_area(_sheet, "Log hover (under 6 words, on the Call name in the fight log)", "log_hint", str(card.get("log_hint", "")), 48, false)
		_add_area(_sheet, "Shift Text (the formula when holding Shift)", "reminder", str(card.get("reminder", LINES.reminder_of(str(card.get("id", "")), card))), 64, false)
	else:
		_add_area(_sheet, "Shift Text (the formula when holding Shift)", "explainer", _explainer_shown(card), 80, false)
		_add_area(_sheet, "Log hover (under 6 words, on this item in the fight log)", "log_hint", str(card.get("log_hint", "")), 48, false)
	_add_pick(_sheet, "Card color", "card_color", UX.card_color_id(str(card.get("card_color", ""))), ["auto", "atk", "blk", "heal", "defeat", "utility", "smoke", "chaos", "egg"])
	_add_area(_sheet, "Function flow / pseudocode (long)", "flow", str(card.get("flow", "")), 160, true)
	_add_area(_sheet, "Notes for the implementer", "notes", str(card.get("notes", "")), 110, false)
	var ops_s: String = JSON.stringify(card.get("ops", {}), "\t")
	if ops_s == "null":
		ops_s = "{}"
	_add_area(_sheet, "Ops JSON", "ops_text", ops_s, 120, true)
	_wire_field_nav()


func _label_head(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("1c120c"))
	_sheet.add_child(l)


func _grid(cols: int) -> GridContainer:
	var g := GridContainer.new()
	g.columns = cols
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 4)
	return g


func _cap(host: Control, label: String) -> VBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", 3)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color("6b4a10"))
	wrap.add_child(l)
	host.add_child(wrap)
	return wrap


func _skin_edit(e: Control) -> void:
	e.add_theme_color_override("font_color", Color("1c120c"))
	if e is LineEdit:
		e.add_theme_color_override("font_uneditable_color", Color("6b4a10"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("fffaf2")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	if e is LineEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("read_only", sb)
		e.add_theme_stylebox_override("focus", sb)
	elif e is TextEdit:
		e.add_theme_stylebox_override("normal", sb)
		e.add_theme_stylebox_override("focus", sb)
		e.add_theme_stylebox_override("read_only", sb)


func _on_review_pick(_i: int) -> void:
	var stage: String = _text_of("review")
	if _fields.has("review_note") and _fields["review_note"] is TextEdit:
		_skin_review_note(_fields["review_note"] as TextEdit, stage)


func _add_review_note(host: Control, value: String, stage: String) -> void:
	var wrap := VBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.text = "Your notes for Cursor"
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color("8b1e1e") if stage == "rough" else Color("6b4a10"))
	wrap.add_child(l)
	var e := TextEdit.new()
	e.text = value
	e.placeholder_text = "Type what to change. Save. The next Cursor message writes this into Ability, numbers, and code."
	e.custom_minimum_size = Vector2(0, 140 if stage == "rough" else 80)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	_skin_review_note(e, stage)
	wrap.add_child(e)
	host.add_child(wrap)
	_fields["review_note"] = e


func _skin_review_note(e: TextEdit, stage: String) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	if stage == "rough":
		sb.bg_color = Color("ffe08a")
		sb.border_color = Color("8b1e1e")
		sb.set_border_width_all(4)
		e.add_theme_color_override("font_color", Color("6b1008"))
		e.add_theme_color_override("font_placeholder_color", Color("8b1e1e"))
		e.add_theme_font_size_override("font_size", 16)
		e.custom_minimum_size.y = 140
	else:
		sb.bg_color = Color("fffaf2")
		sb.border_color = Color("c4a574")
		sb.set_border_width_all(2)
		e.add_theme_color_override("font_color", Color("1c120c"))
		e.add_theme_color_override("font_placeholder_color", Color("8a6a3a"))
		e.add_theme_font_size_override("font_size", 14)
		e.custom_minimum_size.y = 80
	e.add_theme_stylebox_override("normal", sb)
	e.add_theme_stylebox_override("focus", sb)
	e.add_theme_stylebox_override("read_only", sb)


func _add_line(host: Control, label: String, key: String, value: String, readonly: bool = false) -> void:
	if key == "_pad":
		host.add_child(Control.new())
		return
	var wrap := _cap(host, label)
	var e := LineEdit.new()
	e.text = value
	e.editable = not readonly
	e.focus_mode = Control.FOCUS_ALL
	e.placeholder_text = "type a number" if key == "atk_base" or key == "hp_base" else ""
	_skin_edit(e)
	if not readonly:
		e.focus_entered.connect(func() -> void: e.call_deferred("select_all"))
	wrap.add_child(e)
	_fields[key] = e


func _add_pick(host: Control, label: String, key: String, value: String, opts: Array) -> void:
	var wrap := _cap(host, label)
	var e := OptionButton.new()
	e.add_theme_color_override("font_color", Color("1c120c"))
	for i in opts.size():
		e.add_item(str(opts[i]), i)
		if str(opts[i]) == value:
			e.select(i)
	wrap.add_child(e)
	_fields[key] = e


func _add_area(host: Control, label: String, key: String, value: String, h: float, mono: bool) -> void:
	var wrap := _cap(host, label)
	var e := TextEdit.new()
	e.text = value
	e.custom_minimum_size = Vector2(0, h)
	e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	e.scroll_fit_content_height = false
	if mono:
		e.add_theme_font_size_override("font_size", 13)
	_skin_edit(e)
	wrap.add_child(e)
	_fields[key] = e


func _num_s(v: Variant) -> String:
	if v == null:
		return ""
	if typeof(v) == TYPE_FLOAT:
		return str(int(v))
	return str(v)


func _text_of(key: String) -> String:
	var n: Variant = _fields.get(key, null)
	if n is LineEdit:
		return (n as LineEdit).text.strip_edges()
	if n is TextEdit:
		return (n as TextEdit).text
	if n is OptionButton:
		return (n as OptionButton).get_item_text((n as OptionButton).selected)
	return ""


func _int_of(key: String, fallback: int) -> int:
	var s: String = _text_of(key)
	if s == "":
		return fallback
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return int(float(s))
	return fallback


func _null_or_int(key: String) -> Variant:
	var s: String = _text_of(key)
	if s == "":
		return null
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return int(float(s))
	return null


func _gather() -> Dictionary:
	var ops: Variant = _original.get("ops", {})
	var ops_raw: String = _text_of("ops_text")
	var parsed: Variant = JSON.parse_string(ops_raw if ops_raw != "" else "{}")
	if typeof(parsed) == TYPE_DICTIONARY:
		ops = parsed
	elif typeof(parsed) == TYPE_ARRAY:
		ops = parsed
	else:
		_status.text = "Ops JSON did not parse — fix the braces, then Save."
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return {}
	var card := {
		"id": _id,
		"name": _text_of("name"),
		"kind": _kind,
		"status": _text_of("status"),
		"rarity": _text_of("rarity"),
		"bucket": BucketRules.parse(_text_of("bucket")),
		"mode_pool": ModePool.parse(_text_of("mode_pool")) if _fields.has("mode_pool") else ModePool.parse(_original.get("mode_pool", "all")),
		"tier": _int_of("tier", 1),
		"count": _int_of("count", 1),
		"priority": _int_of("priority", 3),
		"atk_base": _null_or_int("atk_base") if _fields.has("atk_base") else _original.get("atk_base", null),
		"hp_base": _null_or_int("hp_base") if _fields.has("hp_base") else _original.get("hp_base", null),
		"atk_formula": _text_of("atk_formula") if _fields.has("atk_formula") else str(_original.get("atk_formula", "")),
		"hp_formula": _text_of("hp_formula") if _fields.has("hp_formula") else str(_original.get("hp_formula", "")),
		"ability": _text_of("ability"),
		"explainer": _text_of("explainer"),
		"call_name": _text_of("call_name") if _fields.has("call_name") else str(_original.get("call_name", "")),
		"log_hint": _text_of("log_hint") if _fields.has("log_hint") else str(_original.get("log_hint", "")),
		"reminder": _text_of("reminder") if _fields.has("reminder") else str(_original.get("reminder", "")),
		"card_color": "" if UX.card_color_id(_text_of("card_color") if _fields.has("card_color") else str(_original.get("card_color", ""))) == "auto" else UX.card_color_id(_text_of("card_color") if _fields.has("card_color") else str(_original.get("card_color", ""))),
		"flow": _text_of("flow"),
		"notes": _text_of("notes"),
		"review": _text_of("review") if _fields.has("review") else REVIEW_STAGE.of_card(_original),
		"review_note": _text_of("review_note") if _fields.has("review_note") else str(_original.get("review_note", "")),
		"ops": ops,
		"contradiction_ids": _original.get("contradiction_ids", []),
	}
	var logic_changed: bool = str(card["flow"]) != str(_original.get("flow", "")) \
		or str(card["notes"]) != str(_original.get("notes", "")) \
		or str(card["atk_formula"]) != str(_original.get("atk_formula", "")) \
		or str(card["hp_formula"]) != str(_original.get("hp_formula", "")) \
		or str(card["review_note"]) != str(_original.get("review_note", ""))
	if logic_changed and str(card["status"]) == "live":
		card["status"] = "todo"
	AUTHOR_LOCK.stamp_card(card, _original, false)
	return card


func _refresh_bucket_warn() -> void:
	if _bucket_warn == null:
		return
	var items: Array = []
	var monsters: Array = []
	for card in _board.get("items", []):
		items.append((card as Dictionary).duplicate(true))
	for card2 in _board.get("monsters", []):
		monsters.append((card2 as Dictionary).duplicate(true))
	var live: Array = items if _kind == "item" else monsters
	for card3 in live:
		if str(card3.get("id", "")) == _id:
			card3["bucket"] = BucketRules.parse(_text_of("bucket"))
			break
	var msg: String = BucketRules.counts_warning(items, monsters)
	_bucket_warn.set_message(msg)


func _on_save() -> void:
	var card: Dictionary = _gather()
	if card.is_empty():
		return
	_load_board()
	var key: String = "monsters" if _kind == "monster" else "items"
	var arr: Array = _board.get(key, [])
	var found := false
	for i in arr.size():
		if str(arr[i].get("id", "")) == _id:
			arr[i] = card
			found = true
			break
	if not found:
		arr.append(card)
	_board[key] = arr
	_board["updated"] = Time.get_date_string_from_system()
	_board["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
	var path: String = ProjectSettings.globalize_path(BOARD_PATH)
	if not AUTHOR_LOCK.write_json(BOARD_PATH, _board):
		_status.text = "Could not write %s (error %s)." % [path, FileAccess.get_open_error()]
		_status.add_theme_color_override("font_color", Color("8b1e1e"))
		return
	AUTHOR_LOCK.rebuild_ledger(_board, null)
	RECENT_EDITS.touch(_kind, _id)
	_status.text = "Saved and locked · %s" % path
	_status.add_theme_color_override("font_color", Color("3d6b3d"))
	saved.emit(_kind, _id, card)
	close_editor()


func _btn(text: String, fill: Color, rim: Color, cb: Callable, width: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 40)
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = rim
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate()
	(h as StyleBoxFlat).bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b


func _field_chain() -> Array:
	var chain: Array = []
	for k in _fields:
		var n: Variant = _fields[k]
		if n is LineEdit or n is TextEdit:
			chain.append(n)
	return chain


func _wire_field_nav() -> void:
	var chain: Array = _field_chain()
	if chain.is_empty():
		return
	for i in chain.size():
		var cur: Control = chain[i]
		var nxt: Control = chain[(i + 1) % chain.size()]
		var prv: Control = chain[(i - 1 + chain.size()) % chain.size()]
		cur.focus_next = nxt.get_path()
		cur.focus_previous = prv.get_path()
		cur.focus_neighbor_bottom = nxt.get_path()
		cur.focus_neighbor_top = prv.get_path()
		if not cur.has_meta("nav_hook"):
			cur.set_meta("nav_hook", true)
			cur.gui_input.connect(_on_field_nav.bind(cur))


func _on_field_nav(event: InputEvent, e: Control) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.ctrl_pressed or key.alt_pressed:
		return
	var chain: Array = _field_chain()
	var i: int = chain.find(e)
	if i < 0:
		return
	if key.keycode == KEY_UP:
		if e is LineEdit or (e is TextEdit and (e as TextEdit).get_caret_line() <= 0):
			_focus_field_at(chain, i - 1)
			e.accept_event()
	elif key.keycode == KEY_DOWN:
		if e is LineEdit or (e is TextEdit and (e as TextEdit).get_caret_line() >= (e as TextEdit).get_line_count() - 1):
			_focus_field_at(chain, i + 1)
			e.accept_event()


func _focus_field_at(chain: Array, i: int) -> void:
	if chain.is_empty():
		return
	i = (i + chain.size()) % chain.size()
	var e: Control = chain[i]
	e.grab_focus()
	if _scroll:
		_scroll.ensure_control_visible(e)


func _focus_first_field() -> void:
	var chain: Array = _field_chain()
	if chain.is_empty():
		return
	_focus_field_at(chain, 0)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.keycode == KEY_ESCAPE:
		close_editor()
		get_viewport().set_input_as_handled()
		return
	if key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		if key.ctrl_pressed or key.alt_pressed or key.meta_pressed:
			return
		_on_save()
		get_viewport().set_input_as_handled()
		return
	if key.ctrl_pressed and key.keycode == KEY_S:
		_on_save()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT or key.keycode == KEY_UP or key.keycode == KEY_DOWN or key.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
