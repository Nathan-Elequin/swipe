extends SceneTree
## Tip smoke — Brand New / Skip / draft / choice / Harpy→Dragon / cabin-arrive
## rail invariants from data + script. Does not boot main.gd or render.
## Catches soft-lock / rail bugs without F5.
## Run: godot --headless --path . --script res://scripts/dev/tip_smoke_selftest.gd

const COPY := preload("res://scripts/player_copy.gd")
const GUIDE := preload("res://scripts/tutorial_guide.gd")

## Waits the tip rails know how to arm. New wait kinds must get a handler before shipping.
const KNOWN_WAIT_EXACT := {
	"continue": true,
	"spin": true,
	"auto_spin": true,
	"done": true,
	"choice": true,
	"free": true,
	"face": true,
	"move": true,
	"hover": true,
	"hover_item": true,
	"hover_shift": true,
}


func _init() -> void:
	var failed := false
	COPY.reload()
	var lines: Array = COPY.tutorial_lines()
	failed = _check(failed, "tutorial_lines_loaded", lines.size() >= 20) or failed

	var waits := {}
	var choice_rows: Array = []
	var fangs_draft := 0
	var b27c_rows: Array = []
	var skip_only_rows: Array = []
	var reveal_rows: Array = []
	var b55_rows: Array = []
	var auto_spin_rows: Array = []
	var arrow_head_rows: Array = []
	var spine_move := 0
	var spine_shield := 0
	var spine_flail := 0
	var spine_harpy_a := 0
	var spine_dragon := 0
	var b54_idx := -1
	var b55_idx := -1
	for i in range(lines.size()):
		var row: Dictionary = lines[i]
		var w: String = str(row.get("wait", ""))
		waits[w] = int(waits.get(w, 0)) + 1
		var beat: String = str(row.get("beat", ""))
		var branch: String = str(row.get("branch", ""))
		var force: String = str(row.get("force", ""))
		var rig: String = str(row.get("rig", ""))
		if w == "choice":
			choice_rows.append(row)
		if w == "draft:fangs":
			fangs_draft += 1
		if beat == "B27c" or str(row.get("key", "")).find("B27c") >= 0:
			b27c_rows.append(row)
		if branch == "skip_only":
			skip_only_rows.append(row)
		if rig == "reveal" or beat == "B54":
			reveal_rows.append(row)
		if beat == "B54" and b54_idx < 0:
			b54_idx = i
		if beat == "B55":
			b55_rows.append(row)
			if b55_idx < 0:
				b55_idx = i
		if w == "auto_spin":
			auto_spin_rows.append({"i": i, "row": row})
			if force == "tag:harpy_a":
				spine_harpy_a += 1
			if force == "dragon":
				spine_dragon += 1
		if w == "item:arrow_head":
			arrow_head_rows.append(row)
		if w == "move" and (force == "tag:harpy_b" or force.find("harpy") >= 0):
			spine_move += 1
		if w == "item:shield":
			spine_shield += 1
		if w == "item:spiked_flail":
			spine_flail += 1

	## 1) draft:fangs must exist — missing wait soft-locks Brand New at Fangs take.
	failed = _check(failed, "draft_fangs_wait", fangs_draft >= 1) or failed

	## 2) Goblin choice allow: Boot / Breastplate / Take — no Shield (noon soft-lock path).
	failed = _check(failed, "choice_row_exists", choice_rows.size() == 1) or failed
	if choice_rows.size() >= 1:
		var allow: Array = choice_rows[0].get("allow", [])
		failed = _check(failed, "choice_allow_boot", allow.has("da_boot")) or failed
		failed = _check(failed, "choice_allow_breastplate", allow.has("breastplate")) or failed
		failed = _check(failed, "choice_allow_end_fight", allow.has("end_fight")) or failed
		failed = _check(failed, "choice_allow_no_shield", not allow.has("shield")) or failed

	## 3) B27c Breastplate-path branch rows exist for the Goblin Block→Keep teach.
	failed = _check(failed, "b27c_rows", b27c_rows.size() >= 2) or failed
	var b27c_breast := 0
	for raw_b in b27c_rows:
		var br: Dictionary = raw_b
		if str(br.get("branch", "")) == "breastplate":
			b27c_breast += 1
	failed = _check(failed, "b27c_branch_breastplate", b27c_breast >= 2) or failed

	## 4) Every player-copy wait resolves to a known rail vocabulary.
	var unknown: Array[String] = []
	for w_key in waits.keys():
		var w2: String = str(w_key)
		if _wait_known(w2):
			continue
		unknown.append(w2)
	failed = _check(failed, "waits_resolve", unknown.is_empty()) or failed
	if not unknown.is_empty():
		push_error("TIP_SMOKE unknown waits: %s" % ",".join(unknown))

	## 5) Next visibility: continue shows Next; action waits hide it (noon Next soft-lock class).
	var guide = GUIDE.new()
	failed = _check(failed, "guide_has_nudge", guide.has_method("nudge")) or failed
	failed = _check(failed, "guide_has_wait_shows_next", guide.has_method("_wait_shows_next")) or failed
	if guide.has_method("_wait_shows_next"):
		failed = _check(failed, "next_on_continue", bool(guide.call("_wait_shows_next", "continue"))) or failed
		failed = _check(failed, "no_next_on_choice", not bool(guide.call("_wait_shows_next", "choice"))) or failed
		failed = _check(failed, "no_next_on_draft_fangs", not bool(guide.call("_wait_shows_next", "draft:fangs"))) or failed
		failed = _check(failed, "no_next_on_item", not bool(guide.call("_wait_shows_next", "item:sai"))) or failed
		failed = _check(failed, "no_next_on_done", not bool(guide.call("_wait_shows_next", "done"))) or failed
		failed = _check(failed, "no_next_on_auto_spin", not bool(guide.call("_wait_shows_next", "auto_spin"))) or failed
		failed = _check(failed, "no_next_on_move", not bool(guide.call("_wait_shows_next", "move"))) or failed

	## 6) TutorialGuide must not expose a script `hint` property — noon crash was tut.hint = …
	failed = _check(failed, "no_script_hint_property", not _has_script_var(guide, "hint")) or failed

	## 7) No tut.hint assignments in scripts (would crash at Goblin Block→Take).
	var hint_hits: Array[String] = _scan_tut_hint_assignments()
	failed = _check(failed, "no_tut_hint_assignments", hint_hits.is_empty()) or failed
	for hit in hint_hits:
		push_error("TIP_SMOKE tut.hint: %s" % hit)

	## 8) Guide beat load matches player-copy (Brand New rail is data-driven).
	var beats: Array = guide.call("_load_beats")
	failed = _check(failed, "load_beats_count", beats.size() == lines.size()) or failed
	failed = _check(failed, "load_beats_has_draft_fangs", _beats_have_wait(beats, "draft:fangs")) or failed
	failed = _check(failed, "load_beats_has_choice", _beats_have_wait(beats, "choice")) or failed

	## 9) Yes ending is B50. Pool unlock and the cabin splash are code, not extra beats.
	## Skip still uses the same cabin landing.
	var b50_end := false
	for row50 in lines:
		if str(row50.get("key", "")) == "tutorial.line.B50.3":
			b50_end = str(row50.get("text", "")).find("home") >= 0
	failed = _check(failed, "b50_ends_tutorial", b50_end) or failed
	failed = _check(failed, "road_finish_to_cabin_hook", _source_has_func("res://scripts/main.gd", "_road_finish_to_cabin")) or failed

	## 10) Harpy→Dragon spine waits present (verify against tip player-copy, don't invent).
	failed = _check(failed, "spine_auto_spin_harpy_a", spine_harpy_a >= 1) or failed
	failed = _check(failed, "spine_item_arrow_head", arrow_head_rows.size() >= 1) or failed
	failed = _check(failed, "spine_move_harpy_b", spine_move >= 1) or failed
	failed = _check(failed, "spine_item_shield", spine_shield >= 1) or failed
	failed = _check(failed, "spine_auto_spin_dragon", spine_dragon >= 1) or failed
	failed = _check(failed, "spine_item_flail", spine_flail >= 1) or failed
	failed = _check(failed, "spine_auto_spin_count", auto_spin_rows.size() >= 4) or failed

	## 11) Continue→auto_spin after kills when tip data says so.
	## Each Yes-path auto_spin must be preceded by continue or draft:* (kill/loot → auto land).
	var bad_auto_prev := 0
	var yes_auto := 0
	for pack in auto_spin_rows:
		var ai: int = int(pack.get("i", -1))
		var arow: Dictionary = pack.get("row", {})
		var abr: String = str(arow.get("branch", ""))
		if abr == "trigger" or abr == "skip_only":
			continue
		yes_auto += 1
		var prev_w := _prev_yes_wait(lines, ai)
		if prev_w != "continue" and not prev_w.begins_with("draft:"):
			bad_auto_prev += 1
			push_error("TIP_SMOKE auto_spin prev wait=%s at %s" % [prev_w, str(arow.get("key", ""))])
	failed = _check(failed, "auto_spin_after_continue_or_draft", yes_auto >= 1 and bad_auto_prev == 0) or failed

	## 12) Arrow Head available from start if tip data says so.
	if arrow_head_rows.size() >= 1:
		var ah: Dictionary = arrow_head_rows[0]
		var ah_allow: Array = ah.get("allow", [])
		var ah_text: String = str(ah.get("text", "")).to_lower()
		failed = _check(failed, "arrow_head_allow", ah_allow.has("arrow_head")) or failed
		failed = _check(failed, "arrow_head_teach_copy", ah_text.find("arrow head") >= 0) or failed
	var start_hotbar_ok := _main_starts_with_arrow_head()
	failed = _check(failed, "arrow_head_in_start_hotbar", start_hotbar_ok) or failed

	## 13) Cabin under road: cabin/music not before arrive — expressible from guide/data + hooks.
	## B54 reveal before B55; hide-under-road + finish path unlock-then-music_cabin order.
	failed = _check(failed, "hide_cabin_under_road_hook", _source_has_method("res://scripts/home_cabin.gd", "_hide_cabin_under_road")) or failed
	failed = _check(failed, "road_finish_to_cabin_hook", _source_has_func("res://scripts/main.gd", "_road_finish_to_cabin")) or failed
	failed = _check(failed, "tut_skip_finish_path", _source_contains("res://scripts/main.gd", "_road_finish_to_cabin")) or failed
	var finish_order_ok := _road_finish_unlock_before_cabin_music()
	failed = _check(failed, "unlock_before_cabin_music", finish_order_ok) or failed
	## Hide-under-road must silence cabin (no music/chrome during approach/ambush/overlay).
	failed = _check(failed, "hide_under_road_silences", _source_func_calls("res://scripts/home_cabin.gd", "_hide_cabin_under_road", "_silence_cabin")) or failed
	## Post-tutorial reveal is full Pool 1 via `_bucket_entries(1)` — not `_tut_seen` subtract.
	failed = _check(
		failed,
		"tutorial_unlock_uses_bucket_entries",
		_source_func_calls("res://scripts/main.gd", "_tutorial_unlock_entries", "_bucket_entries")
	) or failed
	failed = _check(
		failed,
		"tutorial_unlock_no_tut_seen_filter",
		_tutorial_unlock_entries_omits_tut_seen()
	) or failed

	## 14) Kiss of Death / Venom Veins mill membership + combat hooks (runtime, not flags.dev).
	failed = _check(failed, "runtime_has_kiss_of_death", _runtime_has_item("kiss_of_death")) or failed
	failed = _check(failed, "runtime_has_venom_veins", _runtime_has_item("venom_veins")) or failed
	failed = _check(failed, "kiss_flags_dev_clear", not _catalog_item_flag("kiss_of_death", "dev")) or failed
	failed = _check(failed, "venom_flags_dev_clear", not _catalog_item_flag("venom_veins", "dev")) or failed
	failed = _check(failed, "kiss_ops_wired", _source_contains("res://scripts/main.gd", "\"kiss_of_death\":")) or failed
	failed = _check(failed, "kiss_apply_hook", _source_has_func("res://scripts/main.gd", "_apply_kiss_of_death_mark")) or failed
	failed = _check(failed, "venom_click_hook", _source_has_func("res://scripts/main.gd", "_apply_venom_veins")) or failed
	failed = _check(
		failed,
		"venom_click_poison_and_flask",
		_source_func_calls("res://scripts/main.gd", "_apply_venom_veins", "_gain_player_poison")
		and _source_func_calls("res://scripts/main.gd", "_apply_venom_veins", "_gain_marked_poison_flask")
		and not _source_contains("res://scripts/main.gd", "_venom_veins_on_hp_lost")
	) or failed
	failed = _check(failed, "runtime_pruned_danger_magnet", not _runtime_has_item("danger_magnet")) or failed
	failed = _check(failed, "runtime_pruned_basilisk", not _runtime_has_monster("basilisk")) or failed

	## 15) Lucky Nickel is a random coin (not a knife-style choose picker).
	failed = _check(failed, "runtime_has_lucky_nickel", _runtime_has_item("lucky_nickel")) or failed
	failed = _check(failed, "lucky_nickel_ops_coin", _catalog_item_ops_kind("lucky_nickel", "blk_coin_keep")) or failed
	failed = _check(
		failed,
		"lucky_nickel_item_ops_coin",
		_source_contains("res://scripts/main.gd", '"lucky_nickel": {"kind": "blk_coin_keep"')
		or _source_contains("res://scripts/main.gd", "\"lucky_nickel\": {\"kind\": \"blk_coin_keep\"")
	) or failed
	failed = _check(
		failed,
		"lucky_nickel_no_choose_kind",
		not _source_contains("res://scripts/main.gd", '"lucky_nickel": {"kind": "choose"')
		and not _source_contains("res://scripts/main.gd", "\"lucky_nickel\": {\"kind\": \"choose\"")
	) or failed
	failed = _check(
		failed,
		"lucky_nickel_no_choose_prompt",
		not _source_contains("res://scripts/main.gd", "combat.nickel_choose_prompt")
	) or failed
	failed = _check(
		failed,
		"lucky_nickel_face_slash_chance_icons",
		_source_contains("res://scripts/main.gd", '"lucky_nickel":')
		and _source_contains("res://scripts/main.gd", '", "", "", "", "slash")')
		and _source_contains("res://scripts/main.gd", '_fg("shield", "2")')
		and _source_contains("res://scripts/main.gd", '_fg("shield", "6")')
		and _source_contains("res://scripts/main.gd", '_fg("heart", "−2")')
	) or failed

	## 16) Ball & Chain: Flee Neighbor → Spin lands → Draw a Card; shared draw face glyph.
	failed = _check(failed, "runtime_has_ball_and_chain", _runtime_has_item("ball_and_chain")) or failed
	failed = _check(failed, "ball_and_chain_ops_chain_flee", _catalog_item_ops_kind("ball_and_chain", "chain_flee")) or failed
	failed = _check(
		failed,
		"ball_and_chain_item_ops_chain_flee",
		_source_contains("res://scripts/main.gd", '"ball_and_chain": {"kind": "chain_flee"')
	) or failed
	failed = _check(
		failed,
		"ball_and_chain_no_pure_draw_ops",
		not _source_contains("res://scripts/main.gd", '"ball_and_chain": {"kind": "draw"')
	) or failed
	failed = _check(
		failed,
		"ball_and_chain_ability_flee_spin_draw",
		_catalog_item_ability_contains("ball_and_chain", "Flee")
		and _catalog_item_ability_contains("ball_and_chain", "Draw a Card")
		and _catalog_item_ability_contains("ball_and_chain", "Neighbor")
	) or failed
	failed = _check(
		failed,
		"ball_and_chain_apply_sets_spin_land",
		_source_contains("res://scripts/main.gd", "func _apply_chain_flee")
		and _source_contains("res://scripts/main.gd", "_spin_land_uid = _seat_uid_at(index)")
		and _source_contains("res://scripts/main.gd", "_chain_flee_draw_pending = true")
	) or failed
	failed = _check(
		failed,
		"ball_and_chain_draw_after_spin_land",
		_source_contains("res://scripts/main.gd", "if _chain_flee_draw_pending:")
		and _source_contains("res://scripts/main.gd", "_draw_unseen_item()")
	) or failed
	failed = _check(
		failed,
		"ball_and_chain_face_keeps_draw_glyph",
		_source_contains("res://scripts/main.gd", '"ball_and_chain":')
		and _source_contains("res://scripts/main.gd", '", "", "", "", "draw")')
	) or failed
	failed = _check(
		failed,
		"shared_draw_face_alias",
		_source_contains("res://scripts/item_face.gd", '"draw", "draw_card", "bag"')
		or _source_contains("res://scripts/item_face.gd", "\"draw\", \"draw_card\", \"bag\"")
	) or failed
	failed = _check(
		failed,
		"draw_items_use_draw_face_glyph",
		_source_contains("res://scripts/main.gd", '", "", "", "", "draw")')
		and _source_contains("res://scripts/main.gd", '"smoke_bomb":')
		and _source_contains("res://scripts/main.gd", '"ale_flagon":')
		and _source_contains("res://scripts/main.gd", '"grappling_hook":')
		and _source_contains("res://scripts/main.gd", '"catapult":')
		and _source_contains("res://scripts/main.gd", '"sling":')
	) or failed

	## 17) Collector Bags other on Defeat for −3 HP; discard tax gone.
	failed = _check(failed, "runtime_has_collector", _runtime_has_monster("collector")) or failed
	failed = _check(
		failed,
		"collector_ability_bag_lose_3",
		_catalog_monster_ability_contains("collector", "lose 3 HP")
		and _catalog_monster_ability_contains("collector", "Bag")
	) or failed
	failed = _check(
		failed,
		"collector_ability_no_discard_tax",
		not _catalog_monster_ability_contains("collector", "Discard")
	) or failed
	failed = _check(
		failed,
		"collector_bag_self_cost_hook",
		_source_has_func("res://scripts/main.gd", "_collector_bag_self_cost")
		and _source_func_calls("res://scripts/main.gd", "_collector_bag_defeated", "_collector_bag_self_cost")
	) or failed
	failed = _check(
		failed,
		"collector_no_discard_tax_func",
		not _source_has_func("res://scripts/main.gd", "_collector_discard_tax")
	) or failed
	failed = _check(
		failed,
		"collector_toss_no_discard_tax",
		not _source_func_calls("res://scripts/main.gd", "_toss_item", "_collector_discard_tax")
	) or failed

	## 18) Spinning Top — Defeat equal-HP counter from 0; no ATK / Discard-at-7.
	failed = _check(failed, "runtime_has_spinning_top", _runtime_has_item("spinning_top")) or failed
	failed = _check(
		failed,
		"spinning_top_ops_defeat_spins",
		_catalog_item_ops_kind("spinning_top", "defeat_spins")
	) or failed
	failed = _check(
		failed,
		"spinning_top_item_ops_defeat_spins",
		_source_contains("res://scripts/main.gd", '"spinning_top": {"kind": "defeat_spins"}')
		or _source_contains("res://scripts/main.gd", "\"spinning_top\": {\"kind\": \"defeat_spins\"}")
	) or failed
	failed = _check(
		failed,
		"spinning_top_ability_defeat_equal",
		_catalog_item_ability_contains("spinning_top", "Defeat")
		and _catalog_item_ability_contains("spinning_top", "Starts at 0")
	) or failed
	failed = _check(
		failed,
		"spinning_top_ability_no_discard_cap",
		not _catalog_item_ability_contains("spinning_top", "Discard")
		and not _catalog_item_ability_contains("spinning_top", "ATK")
	) or failed
	failed = _check(
		failed,
		"spinning_top_step_no_discard_max",
		_source_has_func("res://scripts/main.gd", "_step_spinning_tops")
		and _source_has_func("res://scripts/main.gd", "_spinning_top_n")
		and not _source_has_func("res://scripts/main.gd", "_discard_maxed_spinning_tops")
		and not _source_has_func("res://scripts/main.gd", "_spinning_top_atk")
	) or failed
	failed = _check(
		failed,
		"spinning_top_recycle_preserves_snap",
		_source_func_calls("res://scripts/main.gd", "_recycle_insert_copy", "duplicate(true)")
	) or failed

	## 19) Glass Asp — Bitter Blood: +2 Poison each Spin, Attack equals HP actually lost.
	failed = _check(failed, "runtime_has_glass_asp", _runtime_has_monster("glass_asp")) or failed
	failed = _check(
		failed,
		"glass_asp_stats_12_2",
		_catalog_monster_hp_atk("glass_asp", 12, 2)
	) or failed
	failed = _check(
		failed,
		"glass_asp_ability_poison_and_atk",
		_catalog_monster_ability_contains("glass_asp", "On Spin")
		and _catalog_monster_ability_contains("glass_asp", "2 Poison")
		and _catalog_monster_ability_contains("glass_asp", "When I lose HP")
		and _catalog_monster_ability_contains("glass_asp", "equal Attack")
		and not _catalog_monster_ability_contains("glass_asp", "set your HP")
	) or failed
	failed = _check(
		failed,
		"glass_asp_spin_adds_two_no_slash",
		_source_has_func("res://scripts/main.gd", "_apply_glass_asp_on_spin")
		and _source_func_calls("res://scripts/main.gd", "_apply_glass_asp_on_spin", "_add_monster_poison")
		and not _source_func_calls("res://scripts/main.gd", "_apply_glass_asp_on_spin", "_announce_slice")
		and not _source_func_calls("res://scripts/main.gd", "_apply_glass_asp_on_spin", "_chip_hp")
	) or failed
	failed = _check(
		failed,
		"glass_asp_hp_loss_gains_atk",
		_source_has_func("res://scripts/main.gd", "_glass_asp_after_hp_loss")
		and _source_func_calls("res://scripts/main.gd", "_chip_hp", "_glass_asp_after_hp_loss")
		and _source_func_calls("res://scripts/main.gd", "_deal_atk_at", "_glass_asp_after_hp_loss")
		and _source_func_calls("res://scripts/main.gd", "_glass_asp_after_hp_loss", "_announce_slice")
	) or failed
	failed = _check(
		failed,
		"glass_asp_no_spin_me_hp_set",
		not _source_has_func("res://scripts/main.gd", "_apply_glass_asp_set_hp")
		and not _source_has_func("res://scripts/main.gd", "_apply_glass_asp_spin_me_set")
		and not _source_func_calls("res://scripts/main.gd", "_tick_facing_monster_poison", "_apply_glass_asp_set_hp")
	) or failed

	## 20) Captain's Wheel (id shardplate) — +2 stored Block per Move Left; cash on play.
	failed = _check(failed, "runtime_has_shardplate", _runtime_has_item("shardplate")) or failed
	failed = _check(
		failed,
		"shardplate_ops_kind",
		_catalog_item_ops_kind("shardplate", "shardplate")
	) or failed
	failed = _check(
		failed,
		"shardplate_ability_move_left",
		_catalog_item_ability_contains("shardplate", "Move Left")
		and _catalog_item_ability_contains("shardplate", "+2 Block")
	) or failed
	failed = _check(
		failed,
		"shardplate_left_step_hook",
		_source_has_func("res://scripts/main.gd", "_captain_wheel_on_left_step")
		and _source_func_calls("res://scripts/main.gd", "_shift_facing", "_captain_wheel_on_left_step")
		and not _source_func_calls("res://scripts/main.gd", "_deal_atk_at", "_captain_wheel_on_left_step")
	) or failed
	failed = _check(
		failed,
		"shardplate_cash_on_play",
		_source_contains("res://scripts/main.gd", '"shardplate":')
		and _source_contains("res://scripts/main.gd", "shard_blk")
		and _source_contains("res://scripts/main.gd", 'it["shard_blk"]')
	) or failed

	## 21) Love Potion — equal HP, random Defeat, gift that HP.
	failed = _check(failed, "runtime_has_love_potion", _runtime_has_item("love_potion")) or failed
	failed = _check(
		failed,
		"love_potion_ops_kind",
		_catalog_item_ops_kind("love_potion", "love_potion")
	) or failed
	failed = _check(
		failed,
		"love_potion_ability_select_two",
		_catalog_item_ability_contains("love_potion", "Equal HP")
		and _catalog_item_ability_contains("love_potion", "Defeat")
	) or failed
	failed = _check(
		failed,
		"love_potion_equalize_helpers",
		_source_has_func("res://scripts/main.gd", "_apply_love_potion_mark")
		and _source_has_func("res://scripts/main.gd", "_love_potion_defeat")
		and _source_has_func("res://scripts/main.gd", "_love_gift_hp")
	) or failed
	failed = _check(
		failed,
		"love_potion_hp_via_chip_not_attack",
		_source_func_calls("res://scripts/main.gd", "_love_potion_defeat", "_lich_chip_defeat")
		and not _source_func_calls("res://scripts/main.gd", "_love_gift_hp", "_deal_atk_at")
	) or failed
	failed = _check(
		failed,
		"love_potion_mark_wired",
		_source_contains("res://scripts/main.gd", 'kind == "love_potion"')
		and _source_contains("res://scripts/main.gd", '"love_potion"')
	) or failed

	## 22) KissOfDeath — Neighbor mark only; 4 Poison + Wraith Lifelink; louder apply FX.
	failed = _check(failed, "runtime_has_kiss_of_death_m", _runtime_has_item("kiss_of_death")) or failed
	failed = _check(
		failed,
		"kiss_ops_kind_m",
		_catalog_item_ops_kind("kiss_of_death", "kiss_of_death")
	) or failed
	failed = _check(
		failed,
		"kiss_ability_neighbor_poison",
		_catalog_item_ability_contains("kiss_of_death", "Mark a Neighbor with 4 Poison")
		and _catalog_item_ability_contains("kiss_of_death", "Lifelink")
	) or failed
	failed = _check(
		failed,
		"kiss_mark_neighbor_wired",
		_source_has_func("res://scripts/main.gd", "_apply_kiss_of_death_mark")
		and _source_contains("res://scripts/main.gd", 'kind == "kiss_of_death"')
		and _source_contains("res://scripts/main.gd", '_can_mark(index, "kiss_of_death")')
		and not _source_contains("res://scripts/main.gd", "living[rng.randi() % living.size()]")
	) or failed
	failed = _check(
		failed,
		"kiss_paint_wraith_lifelink",
		_source_has_func("res://scripts/main.gd", "_paint_kiss_lifelink")
		and _source_func_calls("res://scripts/main.gd", "_apply_kiss_of_death_mark", "_paint_kiss_lifelink")
		and _source_contains("res://scripts/main.gd", "When I am Defeated, set your HP to my most recent HP.")
	) or failed
	failed = _check(
		failed,
		"kiss_louder_apply_fx",
		_source_func_calls("res://scripts/main.gd", "_apply_kiss_of_death_mark", "mark_slice")
		and _source_contains("res://scripts/poison_pop.gd", "func mark_slice")
		and _source_contains("res://scripts/boss_wheel.gd", "loud: bool = false")
	) or failed

	## 23) TeslaCoil — Across full-block Defeat; silent TakeX; consume on success only; no charge/spin.
	failed = _check(failed, "runtime_has_tesla_coil", _runtime_has_item("tesla_coil")) or failed
	failed = _check(
		failed,
		"tesla_ops_kind",
		_catalog_item_ops_kind("tesla_coil", "tesla_coil")
	) or failed
	failed = _check(
		failed,
		"tesla_ability_across_block",
		_catalog_item_ability_contains("tesla_coil", "Across")
		and _catalog_item_ability_contains("tesla_coil", "fully Blocking")
		and not _catalog_item_ability_contains("tesla_coil", "Charge")
		and not _catalog_item_ability_contains("tesla_coil", "Flee")
	) or failed
	failed = _check(
		failed,
		"tesla_across_helpers",
		_source_has_func("res://scripts/main.gd", "_use_tesla_coil")
		and _source_has_func("res://scripts/main.gd", "_tesla_can_play")
		and _source_has_func("res://scripts/main.gd", "_tesla_across_takex")
		and _source_has_func("res://scripts/main.gd", "_incoming_total_at")
		and _source_has_func("res://scripts/main.gd", "_damsel_incoming_at")
	) or failed
	failed = _check(
		failed,
		"tesla_no_charge_spin_fire",
		not _source_has_func("res://scripts/main.gd", "_tesla_on_spin")
		and not _source_has_func("res://scripts/main.gd", "_tesla_to_fire")
		and not _source_has_func("res://scripts/main.gd", "_tesla_charge")
		and _source_func_calls("res://scripts/main.gd", "_use_tesla_coil", "_hydra_defeat_as_item")
		and _source_func_calls("res://scripts/main.gd", "_use_tesla_coil", "_lich_keep_defeat_item")
	) or failed
	failed = _check(
		failed,
		"tesla_grey_unless_full_block",
		_source_contains("res://scripts/main.gd", '"tesla_coil":')
		and _source_contains("res://scripts/main.gd", "out[\"can_use\"] = _tesla_can_play()")
		and _source_func_calls("res://scripts/main.gd", "_tesla_can_play", "_tesla_across_takex")
	) or failed
	failed = _check(
		failed,
		"tesla_flags_dev_clear",
		not _catalog_item_flag("tesla_coil", "dev")
	) or failed

	## 24) Hydra HungryHeads — On Spin random Neighbor Attack; Defeat → extra Take swing.
	failed = _check(failed, "runtime_has_hydra", _runtime_has_monster("hydra")) or failed
	failed = _check(
		failed,
		"hydra_stats_10_3",
		_catalog_monster_hp_atk("hydra", 10, 3)
	) or failed
	failed = _check(
		failed,
		"hydra_ability_neighbor_no_hp_gain",
		_catalog_monster_ability_contains("hydra", "Neighbor")
		and _catalog_monster_ability_contains("hydra", "On Spin")
		and _catalog_monster_ability_contains("hydra", "extra Attack")
		and not _catalog_monster_ability_contains("hydra", "Gain their HP")
		and not _catalog_monster_ability_contains("hydra", "any other Monster")
	) or failed
	failed = _check(
		failed,
		"hydra_hungry_heads_helpers",
		_source_has_func("res://scripts/main.gd", "_apply_hydra_on_spin")
		and _source_has_func("res://scripts/main.gd", "_hydra_multiattack_pop")
		and _source_func_calls("res://scripts/main.gd", "_apply_hydra_on_spin", "_hydra_multiattack_pop")
		and _source_func_calls("res://scripts/main.gd", "_on_spin", "_apply_hydra_on_spin")
		and _source_contains("res://scripts/main.gd", "hydra_heads")
		and not _source_func_calls("res://scripts/main.gd", "_apply_hydra_on_spin", "_fly_stat_courier")
	) or failed
	failed = _check(
		failed,
		"hydra_flags_dev_clear",
		not _catalog_monster_flag("hydra", "dev")
	) or failed

	if guide != null and is_instance_valid(guide):
		guide.free()

	print("TIP_SMOKE_BEATS %s" % lines.size())
	print("TIP_SMOKE_WAITS %s" % waits)
	print("TIP_SMOKE_FANGS_DRAFT %s" % fangs_draft)
	print("TIP_SMOKE_B27C %s" % b27c_rows.size())
	print("TIP_SMOKE_AUTO_SPIN %s" % auto_spin_rows.size())
	print("TIP_SMOKE_SKIP_ONLY %s" % skip_only_rows.size())
	if failed:
		push_error("TIP_SMOKE_FAIL")
		quit(1)
	else:
		print("TIP_SMOKE_OK")
		quit(0)


func _wait_known(w: String) -> bool:
	if w == "":
		return false
	if KNOWN_WAIT_EXACT.has(w):
		return true
	if w.begins_with("item:") and w.length() > 5:
		return true
	if w.begins_with("draft:") and w.length() > 6:
		return true
	if w.begins_with("hover"):
		return true
	return false


func _beats_have_wait(beats: Array, want: String) -> bool:
	for raw in beats:
		var b: Dictionary = raw
		if str(b.get("wait", "")) == want:
			return true
	return false


func _prev_yes_wait(lines: Array, at: int) -> String:
	## Walk backward past trigger / skip_only / empty-branch-mismatch rows to the prior Yes beat wait.
	var j: int = at - 1
	while j >= 0:
		var prev: Dictionary = lines[j]
		var br: String = str(prev.get("branch", ""))
		if br == "trigger" or br == "skip_only":
			j -= 1
			continue
		## Branch rows (boot/take/breastplate/wizard) still sit on the Yes spine after a choice.
		return str(prev.get("wait", ""))
	return ""


func _has_script_var(obj: Object, name: String) -> bool:
	for p in obj.get_property_list():
		if str(p.get("name", "")) != name:
			continue
		var usage: int = int(p.get("usage", 0))
		## Script-declared vars carry PROPERTY_USAGE_SCRIPT_VARIABLE (4096).
		if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			return true
	return false


func _scan_tut_hint_assignments() -> Array[String]:
	var hits: Array[String] = []
	var root := ProjectSettings.globalize_path("res://scripts")
	_scan_dir_for_tut_hint(root, hits)
	return hits


func _scan_dir_for_tut_hint(path: String, hits: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full: String = path.path_join(name)
		if dir.current_is_dir():
			_scan_dir_for_tut_hint(full, hits)
		elif name.ends_with(".gd"):
			## Skip this harness — it mentions tut.hint in the scanner itself.
			if name == "tip_smoke_selftest.gd":
				name = dir.get_next()
				continue
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null:
				var line_n := 0
				while not f.eof_reached():
					line_n += 1
					var line: String = f.get_line()
					var stripped: String = line.strip_edges()
					if stripped.begins_with("#"):
						continue
					## Only real assignments crash (tut.hint = …). Mentions in strings/docs are fine.
					var eq: int = stripped.find("tut.hint")
					if eq < 0:
						continue
					var after: String = stripped.substr(eq + "tut.hint".length()).strip_edges()
					if after.begins_with("="):
						hits.append("%s:%d:%s" % [full.replace("\\", "/"), line_n, stripped])
		name = dir.get_next()
	dir.list_dir_end()


func _read_source(res_path: String) -> String:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _source_contains(res_path: String, needle: String) -> bool:
	return _read_source(res_path).find(needle) >= 0


func _source_has_method(res_path: String, method: String) -> bool:
	## Match `func method(` declarations (not calls).
	var src := _read_source(res_path)
	return src.find("func %s(" % method) >= 0


func _source_has_func(res_path: String, method: String) -> bool:
	return _source_has_method(res_path, method)


func _source_func_calls(res_path: String, method: String, callee: String) -> bool:
	## True if the body of `func method(` contains a call to callee before the next top-level func.
	var src := _read_source(res_path)
	var start: int = src.find("func %s(" % method)
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	return body.find(callee) >= 0


func _main_starts_with_arrow_head() -> bool:
	## Tip board seats Arrow Head in the opening hotbar (Nathan 2026-11-04).
	var src := _read_source("res://scripts/main.gd")
	var start: int = src.find("func _start_tutorial(")
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	## Prefer the hotbar grant loop; fall back to any arrow_head string in the starter body.
	if body.find("arrow_head") < 0:
		return false
	## Must appear with the other opening items (sai / breastplate / spiked_flail).
	return body.find("sai") >= 0 and body.find("spiked_flail") >= 0 and body.find("arrow_head") >= 0


func _road_finish_unlock_before_cabin_music() -> bool:
	## Pool-1 reveal (`_tutorial_play_unlock`) must run before cabin music / arrive splash.
	var src := _read_source("res://scripts/main.gd")
	var start: int = src.find("func _road_finish_to_cabin(")
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	var unlock_i: int = body.find("_tutorial_play_unlock")
	var music_i: int = body.find("music_cabin")
	var arrive_i: int = body.find("play_arrive_splash")
	if unlock_i < 0:
		return false
	if music_i >= 0 and music_i < unlock_i:
		return false
	if arrive_i >= 0 and arrive_i < unlock_i:
		return false
	## At least one of music / arrive should follow unlock (arrive splash owns cabin return).
	return music_i > unlock_i or arrive_i > unlock_i


func _tutorial_unlock_entries_omits_tut_seen() -> bool:
	## Body must reuse `_bucket_entries` and must not filter on `_tut_seen`.
	var src := _read_source("res://scripts/main.gd")
	var start: int = src.find("func _tutorial_unlock_entries(")
	if start < 0:
		return false
	var next_func: int = src.find("\nfunc ", start + 1)
	var body: String = src.substr(start, next_func - start if next_func >= 0 else src.length() - start)
	if body.find("_bucket_entries(1)") < 0 and body.find("_bucket_entries (1)") < 0:
		return false
	return body.find("_tut_seen") < 0


func _load_json(res_path: String) -> Dictionary:
	var path := ProjectSettings.globalize_path(res_path)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


func _runtime_has_item(id: String) -> bool:
	var rt: Dictionary = _load_json("res://data/runtime.json")
	var items: Variant = rt.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		return false
	return (items as Array).has(id)


func _runtime_has_monster(id: String) -> bool:
	var rt: Dictionary = _load_json("res://data/runtime.json")
	var mons: Variant = rt.get("monsters", [])
	if typeof(mons) != TYPE_ARRAY:
		return false
	return (mons as Array).has(id)


func _catalog_item_flag(id: String, flag: String) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var items: Variant = cat.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		return false
	for raw in items as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		var flags: Variant = card.get("flags", {})
		if typeof(flags) != TYPE_DICTIONARY:
			return false
		return bool((flags as Dictionary).get(flag, false))
	return false


func _catalog_monster_flag(id: String, flag: String) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var mons: Variant = cat.get("monsters", [])
	if typeof(mons) != TYPE_ARRAY:
		return false
	for raw in mons as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		var flags: Variant = card.get("flags", {})
		if typeof(flags) != TYPE_DICTIONARY:
			return false
		return bool((flags as Dictionary).get(flag, false))
	return false


func _catalog_item_ops_kind(id: String, kind: String) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var items: Variant = cat.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		return false
	for raw in items as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		var ops: Variant = card.get("ops", {})
		if typeof(ops) != TYPE_DICTIONARY:
			return false
		return str((ops as Dictionary).get("kind", "")) == kind
	return false


func _catalog_item_ability_contains(id: String, needle: String) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var items: Variant = cat.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		return false
	for raw in items as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		return str(card.get("ability", "")).find(needle) >= 0
	return false


func _catalog_monster_ability_contains(id: String, needle: String) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var mons: Variant = cat.get("monsters", [])
	if typeof(mons) != TYPE_ARRAY:
		return false
	for raw in mons as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		return str(card.get("ability", "")).find(needle) >= 0
	return false


func _catalog_monster_hp_atk(id: String, hp: int, atk: int) -> bool:
	var cat: Dictionary = _load_json("res://data/catalog.json")
	var mons: Variant = cat.get("monsters", [])
	if typeof(mons) != TYPE_ARRAY:
		return false
	for raw in mons as Array:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		if str(card.get("id", "")) != id:
			continue
		return int(card.get("hp_base", -1)) == hp and int(card.get("atk_base", -1)) == atk
	return false


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("TIP_SMOKE_PASS %s" % label)
		return failed
	push_error("TIP_SMOKE_FAIL %s" % label)
	print("TIP_SMOKE_FAIL %s" % label)
	return true
