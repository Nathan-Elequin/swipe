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
var _play_log_enabled: bool = false
var hotbar_box: Container
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
var overlay_log: Button
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

## Stubs so parent layers can call methods defined further down the chain.
## The running scene is Main; the real function on the leaf wins.
func _load_catalog() -> void:
	pass

func _load_runtime() -> void:
	pass

func _fill_pools() -> void:
	pass

func _pick_tier() -> int:
	return 0

func _take_id(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	return ""

func _take_card(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	return ""

func _pack_tier_for(id: String, by_id: Dictionary, fallback: int) -> int:
	return 0

func _stamp_pack(d: Dictionary, tier: int, kind: String) -> void:
	pass

func _rank_label(d: Dictionary) -> String:
	return ""

func _tier_of(d: Dictionary) -> int:
	return 0

func _next_starter_item() -> String:
	return ""

func _pack_tier_now() -> int:
	return 0

func _take_monster_of_tier(tier: int) -> String:
	return ""

func _grant_starter_kit() -> void:
	pass

func _make_monster(id: String) -> Dictionary:
	return {}

func _make_item(id: String) -> Dictionary:
	return {}

func _card_base_atk(id: String) -> int:
	return 0

func _card_base_hp(id: String) -> int:
	return 0

func _monster_stat_formula(id: String, which: String) -> String:
	return ""

func _try_eval_stat_formula(formula: String, s: Dictionary) -> Variant:
	return null

func _apply_formulas_to(s: Dictionary) -> void:
	pass

func _merge_catalog_card(kind: String, board_card: Dictionary) -> void:
	pass

func _new_catalog_stub(kind: String, id: String) -> Dictionary:
	return {}

func _write_catalog() -> bool:
	return false

func _apply_live_card(kind: String, card_id: String, board_card: Dictionary) -> void:
	pass

func _stamp_live_monster(s: Dictionary, board_card: Dictionary) -> void:
	pass

func _stamp_live_item(it: Dictionary, board_card: Dictionary, ops: Dictionary) -> void:
	pass

func _ops_of(it: Dictionary) -> Dictionary:
	return {}

func _leftmost_atk_n() -> int:
	return 0

func _hand_has_atk_item(except_uid: int = -1) -> bool:
	return false

func _is_silenced(s: Dictionary) -> bool:
	return false

func _has_unique_ability(id: String) -> bool:
	return false

func _item_snapshot(it: Dictionary) -> Dictionary:
	return {}

func _echo_face(it: Dictionary) -> Dictionary:
	return {}

func _item_atk_score(it: Dictionary) -> int:
	return 0

func _item_rank(it: Dictionary) -> int:
	return 0

func _store_last_faced_hp() -> void:
	pass

func _sync_wheel_stats() -> void:
	pass

func _apply_wraith_pass() -> void:
	pass

func _mark_vars() -> void:
	pass

func _on_spin() -> void:
	pass

func _on_done() -> void:
	pass

func _begin_slay(_killed: bool = true) -> void:
	pass

func _exit_ended(clockwork_split: bool = false) -> void:
	pass

func _exit_leave(clockwork_split: bool = true) -> void:
	pass

func _resolve_then_continue(skip_attack: bool) -> void:
	pass

func _apply_resolve_hits() -> int:
	return 0

func _owner_attack(m: Dictionary, hit_n: int = 1, _hit_total: int = 1) -> int:
	return 0

func _player_down() -> void:
	pass

func _clear_after_fight(clockwork_split: bool = false) -> void:
	pass

func _maybe_auto_spin() -> void:
	pass

func _remove_facing() -> void:
	pass

func _discard_spent_items() -> void:
	pass

func _use_item(uid: int) -> void:
	pass

func _choose_option(opt: Dictionary) -> void:
	pass

func _apply_ops(it: Dictionary, ops: Dictionary, extra: Dictionary) -> void:
	pass

func _toss_item(uid: int, keep: bool) -> void:
	pass

func _remove_item_now(uid: int) -> void:
	pass

func _defeat_blocked(m: Dictionary) -> bool:
	return false

func _wick_waiting(index: int) -> bool:
	return false

func _twins_facing() -> bool:
	return false

func _twins_double_atk(index: int, n: int) -> bool:
	return false

func _twins_double_blk(n: int) -> bool:
	return false

func _chip_hp(index: int, n: int) -> void:
	pass

func _collapse_dead_wicks() -> void:
	pass

func _maybe_slay_down(index: int) -> void:
	pass

func _chaos_candidates(stone_uid: int) -> Array:
	return []

func _begin_chaos(uid: int) -> void:
	pass

func _chaos_pick(uid: int) -> void:
	pass

func _finish_chaos() -> void:
	pass

func _reroll_item_same_tier(uid: int) -> void:
	pass

func _keep_blocked_now() -> bool:
	return false

func _gain_blk(n: int, skip_twins: bool = false) -> int:
	return 0

func _heal(n: int) -> int:
	return 0

func _bleed(n: int) -> bool:
	return false

func _remember_item_use(it: Dictionary) -> void:
	pass

func _after_item_resolved(it: Dictionary) -> void:
	pass

func _harpy_poke() -> void:
	pass

func _clear_petrify() -> void:
	pass

func _petrify_best_atk() -> void:
	pass

func _cube_ask_feed() -> void:
	pass

func _feed_cube(uid: int) -> void:
	pass

func _spawn_clockwork_heirs() -> void:
	pass

func _count_item_use() -> void:
	pass

func _deal_atk(n: int) -> bool:
	return false

func _deal_atk_at(index: int, n: int, skip_twins: bool = false) -> bool:
	return false

func _player_take_atk(n: int) -> bool:
	return false

func _apply_siphon_jars() -> bool:
	return false

func _apply_cursed_scrolls() -> bool:
	return false

func _opposite_index() -> int:
	return 0

func _cleave_targets() -> Array[int]:
	return []

func _apply_cleave(n: int) -> bool:
	return false

func _flip_alt_sais() -> void:
	pass

func _directed_neighbor_atk(ccw: bool) -> int:
	return 0

func _weakest_neighbor_atk() -> int:
	return 0

func _strongest_neighbor_atk() -> int:
	return 0

func _neighbor_indices() -> Array[int]:
	return []

func _mark_targets(kind: String) -> Array[int]:
	return []

func _can_mark(index: int, kind: String) -> bool:
	return false

func _apply_mark(index: int) -> void:
	pass

func _kill_neighbor(index: int) -> void:
	pass

func _hurt_ogres(lost: int) -> void:
	pass

func _slay_pending_ogres() -> void:
	pass

func _slay_ogre_at(index: int) -> void:
	pass

func _gain_blocked_now() -> bool:
	return false

func _try_gain_item(id: String) -> void:
	pass

func _shuffle_dungeon() -> void:
	pass

func _try_commander_flee(index: int) -> bool:
	return false

func _damsel_neighbors(index: int) -> Array[int]:
	return []

func _damsel_incoming() -> int:
	return 0

func _damsel_resolve() -> void:
	pass

func _step_berserkers() -> void:
	pass

func _apply_queen_eggs_on_spin() -> void:
	pass

func _remove_crossbowed() -> void:
	pass

func _draw_unseen_item() -> void:
	pass

func _try_potion() -> bool:
	return false

func _swing(m: Dictionary, block_left: int) -> Dictionary:
	return {}

func _incoming_total() -> int:
	return 0

func _hit_count(index: int) -> int:
	return 0

func _queen_double(index: int) -> bool:
	return false

func _item_view(it: Dictionary) -> Dictionary:
	return {}

func _sort_hotbar() -> void:
	pass

func _incoming_hit() -> int:
	return 0

func _draw_offer(kind: String) -> void:
	pass

func _offer_tex() -> Texture2D:
	return null

func _present_gate(passes: int) -> void:
	pass

func _reveal_gate() -> void:
	pass

func _run_mill() -> void:
	pass

func _seat_night_watch() -> void:
	pass

func _seat_opener(si: int, mid: String, pack_kind: String) -> void:
	pass

func _upgrade_two_openers() -> void:
	pass

func _open_petitioner() -> void:
	pass

func _finish_mill() -> void:
	pass

func _on_gate_send() -> void:
	pass

func _on_gate_refuse() -> void:
	pass

func _auto_fill_rest() -> void:
	pass

func _seat_petitioner(index: int) -> void:
	pass

func _on_place_mode() -> void:
	pass

func _on_bribe_mode() -> void:
	pass

func _refresh_offer_card() -> void:
	pass

func _on_slice_clicked(index: int) -> void:
	pass

func _on_slice_right_clicked(index: int) -> void:
	pass

func _can_place() -> bool:
	return false

func _commit_place(index: int, open_next: bool = true) -> void:
	pass

func _place_on(index: int) -> void:
	pass

func _bribe_at(index: int) -> void:
	pass

func _reseat_slots() -> void:
	pass

func _on_new() -> void:
	pass

func _on_overlay_primary() -> void:
	pass

func _reset_run() -> void:
	pass

func _begin_run() -> void:
	pass

func _begin_adventure() -> void:
	pass

func _enter_dungeon_clear() -> void:
	pass

func _adventure_leave() -> void:
	pass

func _adventure_continue() -> void:
	pass

func _prep_next_dungeon() -> void:
	pass

func _quick_start() -> void:
	pass

func _quit_game() -> void:
	pass

func _on_pause_mode(mode: String) -> void:
	pass

func _on_script_saved() -> void:
	pass

func _on_content_saved(kind: String, card_id: String, board_card: Dictionary) -> void:
	pass

func _on_roster_committed(items: Array, monsters: Array) -> void:
	pass

func _start_tutorial() -> void:
	pass

func _tut_on_continue() -> void:
	pass

func _tut_skip() -> void:
	pass

func _tut_finished() -> void:
	pass

func _tut_auto_spin() -> void:
	pass

func _tut_play_adventure() -> void:
	pass

func _tut_mill_demo(kind: String) -> void:
	pass

func _tut_run_mill(kind: String) -> void:
	pass

func _tut_mill_seat() -> void:
	pass

func _tut_refresh_focus() -> void:
	pass

func _tut_focus() -> Control:
	return null

func _tut_fill_inspect() -> void:
	pass

func _tut_monster_slice(id: String) -> Control:
	return null

func _tut_monster_stat(id: String, kind: String) -> Control:
	return null

func _tut_both_hp() -> Array:
	return []

func _tut_apply_wedges() -> void:
	pass

func _tut_empty_indices() -> Array:
	return []

func _tut_empty_proxies() -> Array:
	return []

func _tut_two_slices() -> Array:
	return []

func _tutorial_spin_index() -> int:
	return 0

func _tut_can_done() -> bool:
	return false

func _tutorial_allows_item(id: String) -> bool:
	return false

func _tutorial_item_used(id: String) -> void:
	pass

func _tutorial_combat_started() -> void:
	pass

func _tutorial_after_fight() -> void:
	pass

func _tutorial_on_item_hover(id: String = "") -> void:
	pass

func _tutorial_on_slice_hover(index: int) -> void:
	pass

func _tutorial_shift_tick() -> void:
	pass

func _prefer_pixel_art() -> void:
	pass

func _load_textures() -> void:
	pass

func _build_ui() -> void:
	pass

func _build_overlay() -> void:
	pass

func _legend() -> HFlowContainer:
	return HFlowContainer.new()

func _pill(text: String, fill: Color, rim: Color, cb: Callable) -> Button:
	return Button.new()

func _sb(fill: Color, rim: Color, border: int) -> StyleBoxFlat:
	return StyleBoxFlat.new()

func _play_hall_wipe() -> void:
	pass

func _walk_knight_off() -> void:
	pass

func _tier_metal(tier: int) -> Color:
	return Color.WHITE

func _utility_fill(ops_kind: String, family: String) -> Color:
	return Color.WHITE

func _item_look(it: Dictionary) -> Dictionary:
	return {}

func _item_inspect_body(it: Dictionary, _rule: Dictionary) -> String:
	return ""

func _item_inspect_look(it: Dictionary) -> Dictionary:
	return {}

func _item_display_kind(it: Dictionary) -> String:
	return ""

func _pin_top_right(panel: Control) -> void:
	pass

func _show_item_inspect(it: Dictionary) -> void:
	pass

func _monster_look(s: Dictionary) -> Dictionary:
	return {}

func _fly_courier(tex: Texture2D, from: Vector2, to: Vector2, dur: float = 0.4) -> void:
	pass

func _apply_overlay_copy() -> void:
	pass

func _on_slice_hovered(index: int) -> void:
	pass

func _play_ended_visuals() -> void:
	pass

func _play_leave_visuals() -> void:
	pass

func _play_attack_connect() -> void:
	pass

func _play_attack_blocked() -> void:
	pass

func _flash_banner(msg: String) -> void:
	pass

func _is_yellow_fill(fill: Color) -> bool:
	return false

func _apply_preview(p: Dictionary) -> void:
	pass

func _on_spin_hover(on: bool) -> void:
	pass

func _on_place_hover(on: bool) -> void:
	pass

func _refresh_seat_preview(index: int) -> void:
	pass

func _preview_bribe(index: int) -> Dictionary:
	return {}

func _preview_from_item(it: Dictionary) -> Dictionary:
	return {}

func _punch_blk() -> void:
	pass

func _refresh_blk(punch: bool) -> void:
	pass

func _inspect_item(it: Dictionary, force: bool = false) -> void:
	pass

func _paint_explainer(raw: String, num_hex: String = "#E07A7A") -> String:
	return ""

func _paint_item_text(raw: String, it: Dictionary, formula: bool = false) -> String:
	return ""

func _capitalize_keywords(raw: String) -> String:
	return ""

func _value_bb(word: String, n: String, hex: String) -> String:
	return ""

func _item_rule(it: Dictionary) -> Dictionary:
	return {}

func _monster_rule(s: Dictionary, swap_on_shift: bool = true) -> Dictionary:
	return {}

func _monster_plate_look(s: Dictionary, rule: Dictionary, title_size: int = 22) -> Dictionary:
	return {}

func _refresh_gate_owner() -> void:
	pass

func _sync_placement() -> void:
	pass

func _sync_torch() -> void:
	pass

func _idle_inspect() -> void:
	pass

func _set_inspect_idle(on: bool) -> void:
	pass

func _fill_inspect_from_slice(index: int) -> void:
	pass

func _refresh_monster_plates() -> void:
	pass

func _place_fly(near: Control = null) -> void:
	pass

func _place_speech() -> void:
	pass

func _place_fight_art() -> void:
	pass

func _speech_gutter() -> Rect2:
	return Rect2()

func _on_done_hover(on: bool) -> void:
	pass

func _refresh_hearts() -> void:
	pass

func _punch_heart(tr: TextureRect) -> void:
	pass

func _glow_hearts_heal() -> void:
	pass

func _tint_hearts_bleed() -> void:
	pass

func _punch_label(lab: Label) -> void:
	pass

func _flash_screen(col: Color, a: float = 0.3) -> void:
	pass

func _num_color(kind: String) -> Color:
	return Color.WHITE

func _kind_mark(kind: String) -> Texture2D:
	return null

func _sync_hotbar_formulas() -> void:
	pass

func _layout_play_field() -> void:
	pass

func _set_cue(t: String) -> void:
	pass

func _refresh_face() -> void:
	pass

func _refresh() -> void:
	pass

func _cue_text() -> String:
	return ""

func _sync_buttons() -> void:
	pass

func _sync_overlay() -> void:
	pass

func _rebuild_tray() -> void:
	pass

func _monster_chip(s: Dictionary) -> PanelContainer:
	return PanelContainer.new()

func _sync_hotbar() -> void:
	pass

func _spawn_item_card(it: Dictionary, usable: bool) -> PanelContainer:
	return PanelContainer.new()

func _on_gate_item_hovered() -> void:
	pass

func _on_item_hovered(it: Dictionary, card: Control = null) -> void:
	pass

func _on_item_unhovered() -> void:
	pass

func _rebuild_choice() -> void:
	pass

func _build_copy_stamp() -> void:
	pass

func _build_dev_panel() -> void:
	pass

func _open_dev_test() -> void:
	pass

func _fill_dev_grids() -> void:
	pass

func _dev_tile(id: String, name: String, rarity: String, tier: int, is_mon: bool) -> Button:
	return Button.new()

func _dev_add_monster(id: String, noisy: bool = true) -> void:
	pass

func _dev_add_item(id: String, noisy: bool = true) -> void:
	pass

func _dev_sort_by(stage: String) -> void:
	pass

func _dev_ids_for(kind: String, stage: String) -> Array:
	return []

func _sync_dev_sort_btns() -> void:
	pass

func _dev_click_slice(index: int) -> void:
	pass

func _dev_enter() -> void:
	pass

func _sync_dev_panel() -> void:
	pass

func _open_roster() -> void:
	pass

func _open_script() -> void:
	pass

func _open_content_editor(kind: String, card_id: String) -> void:
	pass

func _toggle_log() -> void:
	pass

func _toggle_play_log() -> void:
	pass

func _refresh_gate_item() -> void:
	pass

func _pin_side_callout(panel: Control, side: String) -> void:
	pass

func _sync_authoring_chrome() -> void:
	pass

func _log(kind: String, msg: String) -> void:
	pass

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass

