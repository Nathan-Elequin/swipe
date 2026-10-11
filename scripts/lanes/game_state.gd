extends Control
## Shared run state, paths, and preloads.
## Lane map: design/LANES.md. Every layer below this file sees these vars.

const CATALOG_PATH := "res://data/catalog.json"
const RUNTIME_PATH := "res://data/runtime.json"
const WHEEL_SCRIPT := preload("res://scripts/boss_wheel.gd")
const WHEEL_HUD_SCN := preload("res://scenes/ui/wheel_hud.tscn")
const PLACEMENT_SCN := preload("res://scenes/ui/placement.tscn")
const FIGHT_SCN := preload("res://scenes/ui/fight.tscn")
const INSPECT_SCN := preload("res://scenes/ui/inspect_plate.tscn")
const TITLE_SCN := preload("res://scenes/ui/title_screen.tscn")
const VICTORY_SCN := preload("res://scenes/ui/victory.tscn")
const DEFEAT_SCN := preload("res://scenes/ui/defeat.tscn")
const ITEM_CARD := preload("res://scripts/item_card.gd")
const HAND_CARD_SCN := preload("res://scenes/ui/hand_card.tscn")
const HOVER_PANEL := preload("res://scripts/hover_panel.gd")
const AUDIO_FX := preload("res://scripts/audio_fx.gd")
const SETTINGS_MENU := preload("res://scripts/settings_menu.gd")
const CONTENT_EDITOR := preload("res://scripts/content_editor.gd")
const ROSTER_EDITOR := preload("res://scripts/roster_editor.gd")
const SCRIPT_EDITOR := preload("res://scripts/script_editor.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const MONSTER_LINES := preload("res://scripts/monster_lines.gd")
const DUNGEON_BG := preload("res://scripts/dungeon_bg.gd")
const COMBAT_STAGE := preload("res://scripts/combat_stage.gd")
const TROPHY_MOUNT := preload("res://scripts/trophy_mount.gd")
const TUTORIAL_GUIDE := preload("res://scripts/tutorial_guide.gd")
const TALK_BOX_SCN := preload("res://scenes/ui/talk_box.tscn")
const SPEECH_BUBBLE := preload("res://scripts/speech_bubble.gd")
const DRAFT_GATE_SCN := preload("res://scenes/ui/draft_gate.tscn")
const DRAFT_LINES := preload("res://scripts/draft_lines.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")
const UX := preload("res://scripts/ux_style.gd")
const SLOT_ORDER := ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
const CARDINAL_SLOTS := [0, 2, 4, 6]
const HP_MAX := 6
const STARTER_COUNT := 4
const STARTER_ITEM_COUNT := 4
const REFUSALS_MAX := 3
const DRAFT_ROUNDS := 4
const DEV_ITEM_MAX := 50
const HAND_MAX := 50

var catalog: Dictionary = {}
var runtime: Dictionary = {}
var monsters_by_id: Dictionary = {}
var items_by_id: Dictionary = {}
var monster_pool: Array = []
var item_pool: Array = []

var hp: int = HP_MAX
var blk: int = 0
var phase: String = "title"
var draft_action: String = "place"
var wheel: Array = []
var hotbar: Array = []
var facing_index: int = -1
var pending_choice: Dictionary = {}
var pending_monster: Dictionary = {}
var pending_item: Dictionary = {}
var uid_seq: int = 0
var starters_left: int = 0
var starter_items_left: int = 0
var smoke_given: bool = false
var drafts_left: int = 0
var last_mob_hp: int = 3
var last_mob_atk: int = 0
var items_used_this_combat: int = 0
var last_item_atk: int = 0
var last_blk_gain: int = 0
var last_item_copy: Dictionary = {}
var pending_feed: Dictionary = {}
var skip_swing_this_fight: bool = false
var keep_blocked_this_fight: bool = false
var num_items_at_combat: int = 0
var mobs_defeated: int = 0
var hp_loss_events: int = 0
var lost_hp_this_combat: bool = false
var enemy_attacked: bool = false
var pending_mark: Dictionary = {}
var pending_chaos: Dictionary = {}
var beads_step: int = 1
var _reroll_skip: int = -1
var rng := RandomNumberGenerator.new()
var _hotbar_sig: String = ""
var _blk_shown: int = -1
var _ghost_blk: int = -1
var _inspect_pinned: bool = false

var tex_heart: Texture2D
var tex_sword: Texture2D
var tex_shield: Texture2D
var tex_rotate: Texture2D
var tex_plus: Texture2D
var tex_by_monster: Dictionary = {}
var tex_by_item: Dictionary = {}
var tex_special: Dictionary = {}
var art
var dungeon_bg
var combat_stage
var trophy
var play_field: Control

var wheel_view
var hud
var inspect
var placement_ui
var fight_ui
var title_ui
var victory_ui
var defeat_ui
var talk_ui
var fly_tip
var face_box
var speech_box
var log_label: RichTextLabel
var log_btn: Button
var _log_open: bool = false
var hotbar_box: HBoxContainer
var choice_box: HBoxContainer
var hearts_box: HBoxContainer
var blk_hud: PanelContainer
var blk_value: Label
var cue_label: Label
var tray: HBoxContainer
var overlay: ColorRect
var overlay_title: Label
var overlay_sub: Label
var overlay_btn: Button
var overlay_dive: Button
var overlay_tut: Button
var overlay_dev: Button
var overlay_adventure: Button
var overlay_continue: Button
var overlay_leave: Button
var overlay_score: Label
var overlay_roster: Button
var overlay_rest_row: HBoxContainer
var overlay_tools_row: HBoxContainer
var _hall_wipe: ColorRect
var dev_panel: VBoxContainer
var dev_mon_n: Label
var dev_item_n: Label
var dev_enter: Button
var dev_mon_grid: GridContainer
var dev_item_grid: GridContainer
var _dev_review: String = ""
var _dev_sort_btns: Dictionary = {}
var btn_start: Button
var btn_spin: Button
var btn_done: Button
var btn_place: Button
var btn_bribe: Button
var _fly_card: Control
var _ghost_hp: int = -1
var _hp_shown: int = HP_MAX
var sfx
var settings_ui
var content_ed
var roster_ed
var script_ed
var overlay_script: Button
var _offer_card: Control
var fx_flash: ColorRect
var _cue_shown: String = ""
var _face_atk_shown: String = ""
var _face_hp_shown: String = ""
var _slain_shown: int = -1
var _hover_slice: int = -2
var _hover_item: Dictionary = {}
var _shift_held: bool = false
var tut
var in_tutorial: bool = false
var _tut_boot: bool = false
var _tut_inspect_page: int = -1
var _tut_mill_busy: bool = false
var _tut_up_a: int = -1
var _tut_up_b: int = -1
var draft_gate
var _courier: TextureRect
var _gate_line: String = ""
var _cube_line: String = ""
var _mill_seq: int = 0
var _mill_beat: String = ""
var refusals_left: int = REFUSALS_MAX
var _copy_stamp: Label
var adventure: bool = false
var dungeon_index: int = 1
var dungeons_cleared: int = 0
var adventure_seat_tiers: Array = [1, 1, 1, 1]
var _adventure_busy: bool = false


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _authoring() -> bool:
	return OS.has_feature("editor")


func _empty_wheel() -> void:
	wheel.clear()
	for slot in SLOT_ORDER:
		wheel.append({"kind": "empty", "slot": slot})
	if wheel_view:
		wheel_view.rot = 0.0
		wheel_view.facing_index = -1


func _titled(d: Dictionary) -> String:
	var n: String = _title_case(str(d.get("name", "?")))
	var r: String = _rank_label(d)
	if r == "":
		return n
	return "%s  ·  %s" % [n, r]


func _title_case(s: String) -> String:
	var raw: String = s.strip_edges()
	if raw == "":
		return raw
	var bits: PackedStringArray = PackedStringArray()
	for part in raw.split(" "):
		if part == "":
			continue
		if part.to_upper() == part and part.length() <= 4:
			bits.append(part)
			continue
		var hy: PackedStringArray = PackedStringArray()
		for chunk in part.split("-"):
			if chunk == "":
				continue
			if chunk.to_upper() == chunk and chunk.length() <= 4:
				hy.append(chunk)
			else:
				hy.append(chunk.substr(0, 1).to_upper() + chunk.substr(1))
		bits.append("-".join(hy))
	return " ".join(bits)


func _first_empty() -> int:
	for i in wheel.size():
		if str(wheel[i].get("kind", "")) == "empty":
			return i
	return -1


func _as_int(v: Variant, fallback: int) -> int:
	if v == null:
		return fallback
	var t: int = typeof(v)
	if t == TYPE_INT:
		return int(v)
	if t == TYPE_FLOAT:
		return int(v)
	if t == TYPE_STRING:
		var s: String = str(v).strip_edges()
		if s == "":
			return fallback
		if s.is_valid_int():
			return int(s)
		if s.is_valid_float():
			return int(float(s))
		return fallback
	return fallback


func _wheel_busy() -> bool:
	return wheel_view != null and wheel_view.busy


func _live_item_count() -> int:
	return hotbar.size()


func _find_item(uid: int) -> Dictionary:
	for it in hotbar:
		if int(it["uid"]) == uid:
			return it
	return {}


func _monsters_left() -> int:
	var n: int = 0
	for s in wheel:
		if str(s.get("kind", "")) == "monster":
			n += 1
	return n


func _empty_count() -> int:
	var n: int = 0
	for s in wheel:
		if str(s.get("kind", "")) == "empty":
			n += 1
	return n


func _empty_alcoves() -> int:
	return maxi(0, SLOT_ORDER.size() - _monsters_left())


func _bb(hex: String, text: String) -> String:
	return UX.chip(text, hex)


func _clear_box(box: Node) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _first_empty_slice() -> int:
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			return i
	return 1


func _hotbar_card(id: String) -> Control:
	if hotbar_box == null:
		return null
	for c in hotbar_box.get_children():
		if c.get("card_id") == null:
			continue
		if str(c.card_id) == id:
			return c
	return null


func _index_of_monster(id: String) -> int:
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) == id:
			return i
	return -1
