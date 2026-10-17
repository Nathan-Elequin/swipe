extends Control
## Full loop: title, mill gate draft, combat, victory/defeat.

const CATALOG_PATH := "res://data/catalog.json"
const RUNTIME_PATH := "res://data/runtime.json"
const WHEEL_SCRIPT := preload("res://scripts/boss_wheel.gd")
const ITEM_CARD := preload("res://scripts/item_card.gd")
const HOVER_PANEL := preload("res://scripts/hover_panel.gd")
const AUDIO_FX := preload("res://scripts/audio_fx.gd")
const SETTINGS_MENU := preload("res://scripts/settings_menu.gd")
const CONTENT_EDITOR := preload("res://scripts/content_editor.gd")
const ROSTER_EDITOR := preload("res://scripts/roster_editor.gd")
const BUCKET_OVERLAY := preload("res://scripts/dev_bucket_overlay.gd")
const SCRIPT_EDITOR := preload("res://scripts/script_editor.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const MONSTER_LINES := preload("res://scripts/monster_lines.gd")
const DUNGEON_BG := preload("res://scripts/dungeon_bg.gd")
const COMBAT_STAGE := preload("res://scripts/combat_stage.gd")
const BUCKET_REVEAL := preload("res://scripts/bucket_reveal.gd")
const BUCKET_PROGRESS_PATH := "user://bucket_progress.json"
const TROPHY_MOUNT := preload("res://scripts/trophy_mount.gd")
const TUTORIAL_GUIDE := preload("res://scripts/tutorial_guide.gd")
const SPEECH_BUBBLE := preload("res://scripts/speech_bubble.gd")
const ABILITY_FX := preload("res://scripts/ability_fx.gd")
const DRAFT_GATE := preload("res://scripts/draft_gate.gd")
const DRAFT_LINES := preload("res://scripts/draft_lines.gd")
const DUNGEON_DECK := preload("res://scripts/dungeon_deck.gd")
const CHALLENGE_DRAFT := preload("res://scripts/challenge_draft.gd")
const HOME_CABIN := preload("res://scripts/home_cabin.gd")
const HOT_EMPTY := preload("res://scripts/hot_empty_slot.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")
const RECENT_EDITS := preload("res://scripts/recent_edits.gd")
const SLOT_ORDER := ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
const CARDINAL_SLOTS := [0, 2, 4, 6]
const HP_MAX := 6
const FILL_YELLOW := Color("4a3d14")
const STARTER_COUNT := 4
const STARTER_ITEM_COUNT := 4
const REFUSALS_MAX := 3
const DRAFT_ROUNDS := 4
const DEV_ITEM_MAX := 50
const HAND_MAX := 50
const CHALLENGE_SEATS := 6
const CHALLENGE_DECK_N := 6
const CHALLENGE_HAND := 10
## 1.0 = original speed. Wheel spin ignores this.
## 0.675 = 35% faster than the previous 0.5 setting.
const ANIM_TIME_SCALE := 0.675

const COMBAT_LOG := preload("res://scripts/combat_log.gd")
const ABILITY_SLASH := preload("res://scripts/ability_slash.gd")

const LOG_KIND := {
	"on_click": {"hex": "#E8C36A", "tag": "You"},
	"on_spin": {"hex": "#6EC8E8", "tag": "Spin"},
	"on_item_use": {"hex": "#E07A3D", "tag": "Used"},
	"on_resolve": {"hex": "#F0E6D8", "tag": "Fight"},
	"on_remove_slice": {"hex": "#D19A66", "tag": "Defeated"},
	"on_draft": {"hex": "#8DCB8D", "tag": "Draft"},
	"on_place": {"hex": "#A3BE8C", "tag": "Placed"},
	"on_bribe": {"hex": "#D19A66", "tag": "Bribe"},
	"var": {"hex": "#C9A0FF", "tag": ""},
	"atk": {"hex": "#E06C75", "tag": "ATK"},
	"blk": {"hex": "#6BB3D9", "tag": "BLK"},
	"hp": {"hex": "#E8A0A0", "tag": "HP"},
	"discard": {"hex": "#8A8178", "tag": "Gone"},
	"keep": {"hex": "#A3BE8C", "tag": "Kept"},
	"end": {"hex": "#BF616A", "tag": "End"},
}

const ITEM_OPS := {
	"shield": {"kind": "blk", "n": 4},
	"throwing_knife": {"kind": "choose"},
	"sai": {"kind": "atk_alt_24"},
	"medallion": {"kind": "blk_from_hp"},
	"helmet": {"kind": "blk_min_hp"},
	"da_boot": {"kind": "defeat_hp"},
	"bloody_gauntlets": {"kind": "atk_7_hp"},
	"bracers": {"kind": "blk_neighbor", "side": "right"},
	"left_bracer": {"kind": "blk_neighbor", "side": "left"},
	"knucklers": {"kind": "atk_7_items"},
	"spiked_flail": {"kind": "atk_hp_loss"},
	"sledgehammer": {"kind": "defeat_atk"},
	"grimoire": {"kind": "atk_last"},
	"breastplate": {"kind": "blk_keep", "n": 2},
	"smoke_bomb": {"kind": "smoke"},
	"fangs": {"kind": "fangs"},
	"poison_flask": {"kind": "mark_poison"},
	"healing_potion": {"kind": "passive"},
	"crossbow": {"kind": "atk_neighbor", "n": 4},
	"pocketwatch": {"kind": "hypnotize"},
	"double_axe": {"kind": "atk_cleave", "n": 2},
	"victory_flask": {"kind": "heal_kills"},
	"grappling_hook": {"kind": "hook_swap"},
	"spiked_shield": {"kind": "choose", "options": [
		{"id": "spike", "label": "ATK 2, discard", "atk": 2, "keep": false},
		{"id": "guard", "label": "BLK 2, discard", "blk": 2, "keep": false},
	]},
	"grief_jar": {"kind": "blk_siphon"},
	"longbow": {"kind": "atk_opposite", "n": 4},
	"lantern": {"kind": "heal_keep", "n": 2},
	"mirror_shard": {"kind": "blk_last"},
	"caltrops": {"kind": "atk_zero"},
	"net": {"kind": "choose", "options": [
		{"id": "drop1", "label": "−1 Attack", "atk_drop": 1},
		{"id": "drop2", "label": "−2 Attack", "atk_drop": 2},
		{"id": "drop3", "label": "−3 Attack", "atk_drop": 3},
	]},
	"echo_bell": {"kind": "echo"},
	"quiet_bell": {"kind": "quiet"},
	"iron_chain": {"kind": "atk_spend_blk"},
	"counting_beads": {"kind": "atk_empty"},
	"last_match": {"kind": "defeat_only_item"},
	"measuring_tape": {"kind": "defeat_double_hp"},
	"mute_stone": {"kind": "chaos_reroll"},
	"cursed_scroll": {"kind": "heal_full"},
	"spider_egg": {"kind": "egg_hurt", "n": 2},
	"arrow_head": {"kind": "atk", "n": 3},
	"danger_magnet": {"kind": "magnet", "options": [
		{"id": "high", "label": "Highest Attack"},
		{"id": "low", "label": "Lowest Attack"},
		{"id": "off", "label": "Off"},
	]},
}

const MONSTER_SPECIAL := {
	"goblin": {"id": "no_atk_dmg", "text": "Cannot receive ATK damage. Defeat still works."},
	"skeleton": {"id": "last_hp", "text": "HP = last enemy's HP when you spun them. First fight: 3."},
	"hornet_swarm": {"id": "double_hit", "text": "Attacks twice. Block is spent on the first swing."},
	"lich": {"id": "buff_hp", "text": "+1 HP to neighbors after other modifiers."},
	"ogre": {"id": "hp_spin", "text": "When you lose HP, I lose equal HP."},
	"berserker": {"id": "kill_scale", "text": "I alternate between 3, 4, and 8 Attack every time you Spin."},
	"dire_wolf": {"id": "atk_spin", "text": "ATK always equals your HP. Updates whenever your HP changes."},
	"bandit": {"id": "item_atk", "text": "I Gain +1 Atk for each Item you hold."},
	"two_headed_serpent": {"id": "two_items", "text": "My Neighbors will attack you (Left, then Right), then I will Heal you for 3 HP."},
	"slime_boss": {"id": "atk_eq_hp", "text": "ATK always equals current HP."},
	"leech_league": {"id": "leech_lowest", "text": "On Spin, repeatedly Heals the Lowest HP Monster until it equals the HP of another Monster."},
	"wraith": {"id": "copy_atk", "text": "Copies the higher neighboring attack, then Commander."},
	"mimic": {"id": "gift", "text": "If I go down before I swing, you gain an item."},
	"spider_queen": {"id": "queen_hits", "text": "Each time you Spin, Gain 1 Spider Egg. Spinning me discards those eggs; I gain +2 HP and +2 Attack for each."},
	"commander": {"id": "buff_atk", "text": "I give my Neighbors +2 Attack. The first time I am Defeated, I Flee."},
	"dragon": {"id": "pierce", "text": "My attack ignores block."},
	"needleback": {"id": "thorns", "text": "Whenever I take attack damage, you take 1 attack. Block can stop that 1."},
	"gelatinous_cube": {"id": "eat_item", "text": "I make you feed me one of two items."},
	"gargoyle": {"id": "petrify", "text": "I petrify your highest Attack item until the next Spin."},
	"harpy": {"id": "interrupt", "text": "I attack you when we meet, and after each item you use."},
	"kobold_trapper": {"id": "item_swings", "text": "I attack an extra time for each item you use this fight."},
	"clockwork_knight": {"id": "split_t2", "text": "If I live, I leave two random Tier 2 monsters in my place."},
	"basilisk": {"id": "no_keep", "text": "While facing me, you cannot Gain or Keep any Items."},
	"hollow": {"id": "even_twice", "text": "Even Attack and even Block happen twice against me."},
	"beggar": {"id": "left_atk", "text": "I gain Atk equal to your leftmost Atk Item"},
	"wick": {"id": "last_hp", "text": "I Lose 2 HP each time a Neighbor is Defeated"},
	"anvil": {"id": "one_chip", "text": "I cannot lose more than 1 HP from one source."},
	"vampire": {"id": "bloodlust", "text": "Every time you lose HP, I gain +1 HP and +1 ATK."},
	"bodyguard": {"id": "take_instead", "text": "When my Neighbors would take Attack Damage, I take it instead."},
	"cowardly_king": {"id": "coward", "text": "Whenever I lose HP, I Attack you and Flee."},
	"merchant": {"id": "fair_trade", "text": "When you Spin me, choose an Item and I will upgrade it."},
	"juggernaut": {"id": "gift_shield", "text": "When you face me, Gain a Shield."},
	"cleric": {"id": "insure", "text": "After you Spin, if you are missing at least 3 HP I will Heal you for 3 and take your worst Item"},
}

const MONSTER_CALL := {
	"wizard": "Spellbook",
	"golem": "Stone Fists",
	"goblin": "No Attack",
	"skeleton": "Grave Echo",
	"hornet_swarm": "Twice",
	"lich": "Soul Tithe",
	"ogre": "Your Measure",
	"berserker": "Warpath",
	"dire_wolf": "Kill Shot",
	"bandit": "Cutpurse",
	"two_headed_serpent": "Guarded by Monsters",
	"slime_boss": "One Flesh",
	"leech_league": "Lowest HP",
	"wraith": "Borrowed Edge",
	"mimic": "False Gift",
	"spider_queen": "Egg Layer",
	"commander": "War Cry",
	"dragon": "True Fire",
	"needleback": "Quills",
	"gelatinous_cube": "Devour",
	"gargoyle": "Petrify",
	"harpy": "Interrupt",
	"kobold_trapper": "Tripwire",
	"clockwork_knight": "Two Gears",
	"basilisk": "Discard",
	"hollow": "Even twice",
	"beggar": "Left Attack",
	"wick": "Death Toll",
	"anvil": "One HP",
	"cowardly_king": "Coward",
}

const MONSTER_REMINDER := {
	"wizard": "plain ATK/HP owner",
	"golem": "plain ATK/HP owner",
	"goblin": "no attack damage",
	"skeleton": "last enemy HP",
	"hornet_swarm": "attacks twice",
	"lich": "neighbors +1 HP",
	"ogre": "HP is yours",
	"berserker": "attack and HP plus defeat",
	"dire_wolf": "Attack always equals your HP",
	"bandit": "attack is items",
	"two_headed_serpent": "Neighbors attack, then Heal 3",
	"slime_boss": "attack equals HP",
	"leech_league": "Lowest HP Monster +1 until tied with another",
	"wraith": "copies neighbor attack",
	"mimic": "item if I never swing",
	"spider_queen": "Egg on Spin. Spinning me eats eggs for +2 HP +2 Attack each.",
	"commander": "neighbors +2 attack",
	"dragon": "ignores block",
	"needleback": "poke 1 when hit by ATK",
	"gelatinous_cube": "feed me one of two items",
	"gargoyle": "petrifies highest Attack item",
	"harpy": "attacks on meet and after items",
	"kobold_trapper": "extra swing per item used",
	"clockwork_knight": "if I live, two Tier 2 owners",
	"basilisk": "items discard on use",
	"hollow": "even Attack or Block twice",
	"beggar": "leftmost Attack, or 3",
	"wick": "-2 HP per Neighbor Defeated.",
	"anvil": "max 1 HP per source",
	"cowardly_king": "when I lose HP, Attack then Flee",
}

const MONSTER_SPEECH := {
	"wizard": "My spellbook was in that pile.",
	"golem": "My stone fists want that back.",
	"goblin": "I cannot take attack damage.",
	"skeleton": "I copy the HP of the last enemy you faced.",
	"hornet_swarm": "I attack twice. Your block is spent on each swing.",
	"lich": "I give my neighbors +1 HP.",
	"ogre": "My HP is your HP.",
	"berserker": "I gain one HP and attack with each monster you defeat.",
	"dire_wolf": "My Attack always equals your HP.",
	"bandit": "I Gain +1 Atk for each Item you hold.",
	"two_headed_serpent": "My Neighbors will attack you (Left, then Right), then I will Heal you for 3 HP.",
	"slime_boss": "My attack always equals my HP.",
	"leech_league": "On Spin, repeatedly Heals the Lowest HP Monster until it equals the HP of another Monster.",
	"wraith": "I copy the higher neighbor's attack.",
	"mimic": "If I go down before I attack, you gain an item.",
	"spider_queen": "Each time you Spin, Gain 1 Spider Egg. Spinning me discards those eggs; I gain +2 HP and +2 Attack for each.",
	"commander": "I give my neighbors +2 attack.",
	"dragon": "My attack ignores block.",
	"needleback": "I stick you for 1 attack whenever you cut me. Your block still works.",
	"gelatinous_cube": "I make you feed me one of two items.",
	"gargoyle": "I petrify your highest Attack item until you Spin again.",
	"harpy": "I attack you when we meet, and after each item you use.",
	"kobold_trapper": "I attack an extra time for each item you use this fight.",
	"clockwork_knight": "If I live, I leave two random Tier 2 monsters in my place.",
	"basilisk": "I discard all items you use immediately while you face me.",
	"hollow": "Even Attack and even Block happen twice against me.",
	"beggar": "My Attack copies the Attack number on your leftmost Attack item. If you have none, my Attack is 3.",
	"wick": "I Lose 2 HP each time a Neighbor is Defeated",
	"anvil": "I cannot lose more than 1 HP from one source.",
}

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
var _magnet_seq: int = 0
var _magnet_pending_consume: String = ""
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
var silenced: Dictionary = {}
var pending_feed: Dictionary = {}
var skip_swing_this_fight: bool = false
var keep_blocked_this_fight: bool = false
var _wick_collapsing: bool = false
var num_items_at_combat: int = 0
var mobs_defeated: int = 0
var hp_loss_events: int = 0
var _bleed_hold: int = 0
var _bleed_losses: int = 0
var lost_hp_this_combat: bool = false
var enemy_attacked: bool = false
var last_atk_index: int = -1
var last_atk_line: String = ""
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
var inspect
var fly_tip
var face_box
var hypno_stage
var hypno_box
var _watch_thorns_seat: int = -1
var _watch_skip_thorns: bool = false
var _hypno_src: int = -1
var speech_box
var ability_fx
var ability_slash
var log_label
var log_btn: Button
var right_col: VBoxContainer
var _log_open: bool = false
var _log_user_hid: bool = false
var _log_user_show: bool = false
var hotbar_box: GridContainer
var choice_box: HBoxContainer
var hearts_box: HBoxContainer
var blk_hud: PanelContainer
var blk_value: Label
var cue_label
var tray: HBoxContainer
var overlay: ColorRect
var _ui_root: Control
var _unlock_screen: bool = false
var overlay_title
var overlay_sub
var overlay_btn: Button
var overlay_dive: Button
var overlay_tut: Button
var overlay_dev: Button
var overlay_latest: Button
var overlay_adventure: Button
var overlay_home: Button
var home_cabin
var lore: Dictionary = {}
var cabin_layout: Dictionary = {}
var rope_exit
var sack_peek
var shot_harness
var text_audit
var _cabin_from_leave: bool = false
var _homecoming_kind: String = "win"
var _homecoming_new: Array = []
var _homecoming_held: Array = []
var _spoken_key: String = ""
var overlay_continue: Button
var overlay_leave: Button
var overlay_score
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
var dev_latest_btn: Button
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
var bucket_ed
var script_ed
var overlay_script: Button
var _offer_card: Control
var fx_flash: ColorRect
var _cue_shown: String = ""
var _face_atk_shown: String = ""
var _face_hp_shown: String = ""
var _slain_shown: int = -1
var _hover_slice: int = -2
var _deck_hovering: bool = false
var _peek_slice: Dictionary = {}
var _shift_held: bool = false
var tut
var in_tutorial: bool = false
var _dungeons_ended: int = 0
var _buckets_revealed: int = 0
var _guarantee_bucket: int = 0
var _bucket_reveal
var _tut_next_dungeon: bool = false
var _tut_intro_step: Dictionary = {}
var _tut_d2_done: Dictionary = {}
var _tut_d2_focus: String = ""
var _tut_d2_busy: bool = false
var _tut_d2_pending: String = ""
var _upgraded_slices: Array = []
var _tut_boot: bool = false
var draft_gate
var _courier: TextureRect
var _courier_gear: Dictionary = {}
var _walker_busy: bool = false
var _hero_swipe_armed: bool = false
var _flee_random_spin: bool = false
var _gate_line: String = ""
var _cube_line: String = ""
var _cleric_line: String = ""
var _cleric_talk_index: int = -1
var _mill_seq: int = 0
var _mill_beat: String = ""
var refusals_left: int = REFUSALS_MAX
var _copy_stamp
var adventure: bool = false
var dungeon_index: int = 1
var dungeons_cleared: int = 0
var adventure_seat_tiers: Array = [1, 1, 1, 1, 1, 1]
var _adventure_busy: bool = false
var dungeon_deck_ui
var challenge_draft_ui
var btn_challenge_begin: Button
var hotbar_wrap: MarginContainer
var btn_wrap: MarginContainer
var hotbar_panel: PanelContainer
var challenge_deck: Array = []
var challenge_aim: int = -1
var challenge_armed: bool = false
var challenge_draft_plan: Array = []
var challenge_pick_i: int = 0
var _challenge_force_spin: bool = false
var _challenge_pending_gain: Dictionary = {}
var _challenge_loot_wait: bool = false
var _challenge_pair: Array = []
var _challenge_pick_cb: Callable = Callable()
var _anim_t: float = 0.0
var _undo_stack: Array = []
var _redo_stack: Array = []
var _undo_live: Dictionary = {}
var _undo_inflight: bool = false
var _undo_gen: int = 0
var _undo_busy: bool = false
var btn_undo: Button
var btn_redo: Button
var overlay_undo: Button


func _ready() -> void:
	Engine.time_scale = ANIM_TIME_SCALE
	PLAYER_COPY.reload()
	_load_textures()
	_load_catalog()
	_load_lore()
	_load_runtime()
	_load_bucket_progress()
	art = DUNGEON_ART.new()
	add_child(art)
	art.setup()
	_prefer_pixel_art()
	_build_ui()
	_empty_wheel()
	phase = "title"
	_refresh()
	if sfx and (home_cabin == null or not home_cabin.visible):
		sfx.start_music()


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _authoring() -> bool:
	return DevFlag.on()


func _prefer_pixel_art() -> void:
	if art == null:
		return
	for png_id in DUNGEON_ART.ITEM_PNG.keys():
		var extra: Texture2D = art.item_tex(str(png_id))
		if extra != null:
			tex_by_item[png_id] = extra
	for id in tex_by_item.keys():
		var pix: Texture2D = art.item_tex(str(id))
		if pix != null:
			tex_by_item[id] = pix
	for id2 in tex_by_monster.keys():
		var port: Texture2D = art.monster_still(str(id2))
		if port != null:
			tex_by_monster[id2] = port


func _load_textures() -> void:
	tex_heart = _tex("res://assets/icons/heart.svg")
	tex_sword = _tex("res://assets/icons/sword.svg")
	tex_shield = _tex("res://assets/icons/shield.svg")
	tex_rotate = _tex("res://assets/icons/rotate.svg")
	tex_plus = _tex("res://assets/icons/plus.svg")
	tex_by_monster = {
		"wizard": _tex("res://assets/icons/wand.svg"),
		"golem": _tex("res://assets/icons/mountain.svg"),
		"goblin": _tex("res://assets/icons/users.svg"),
		"skeleton": _tex("res://assets/icons/skull.svg"),
		"hornet_swarm": _tex("res://assets/icons/sparkles.svg"),
		"lich": _tex("res://assets/icons/droplet.svg"),
		"ogre": _tex("res://assets/icons/hammer.svg"),
		"berserker": _tex("res://assets/icons/swords.svg"),
		"dire_wolf": _tex("res://assets/icons/footprints.svg"),
		"bandit": _tex("res://assets/icons/trending.svg"),
		"two_headed_serpent": _tex("res://assets/icons/link.svg"),
		"slime_boss": _tex("res://assets/icons/copy.svg"),
		"leech_league": _tex("res://assets/icons/users.svg"),
		"wraith": _tex("res://assets/icons/sparkles.svg"),
		"mimic": _tex("res://assets/icons/layers.svg"),
		"spider_queen": _tex("res://assets/icons/link.svg"),
		"commander": _tex("res://assets/icons/swords.svg"),
		"dragon": _tex("res://assets/icons/wand.svg"),
		"needleback": _tex("res://assets/icons/link.svg"),
		"gelatinous_cube": _tex("res://assets/icons/layers.svg"),
		"gargoyle": _tex("res://assets/icons/mountain.svg"),
		"harpy": _tex("res://assets/icons/sparkles.svg"),
		"kobold_trapper": _tex("res://assets/icons/users.svg"),
		"clockwork_knight": _tex("res://assets/icons/rotate.svg"),
		"basilisk": _tex("res://assets/icons/ban.svg"),
		"hollow": _tex("res://assets/icons/users.svg"),
		"beggar": _tex("res://assets/icons/layers.svg"),
		"wick": _tex("res://assets/icons/trending.svg"),
		"anvil": _tex("res://assets/icons/mountain.svg"),
		"vampire": _tex("res://assets/icons/heart.svg"),
		"bodyguard": _tex("res://assets/icons/shield.svg"),
		"cowardly_king": _tex("res://assets/icons/users.svg"),
		"merchant": _tex("res://assets/icons/layers.svg"),
		"juggernaut": _tex("res://assets/icons/shield.svg"),
		"cleric": _tex("res://assets/icons/heart.svg"),
	}
	tex_by_item = {
		"shield": tex_shield,
		"throwing_knife": tex_sword,
		"sai": _tex("res://assets/icons/swords.svg"),
		"medallion": _tex("res://assets/icons/sparkles.svg"),
		"helmet": _tex("res://assets/icons/layers.svg"),
		"da_boot": _tex("res://assets/icons/footprints.svg"),
		"bloody_gauntlets": _tex("res://assets/icons/droplet.svg"),
		"bracers": _tex("res://assets/icons/link.svg"),
		"left_bracer": _tex("res://assets/icons/link.svg"),
		"knucklers": _tex("res://assets/icons/hammer.svg"),
		"spiked_flail": _tex("res://assets/icons/trending.svg"),
		"sledgehammer": _tex("res://assets/icons/mountain.svg"),
		"grimoire": _tex("res://assets/icons/wand.svg"),
		"breastplate": _tex("res://assets/icons/shield.svg"),
		"smoke_bomb": _tex("res://assets/icons/sparkles.svg"),
		"fangs": _tex("res://assets/icons/skull.svg"),
		"poison_flask": _tex("res://assets/icons/droplet.svg"),
		"healing_potion": _tex("res://assets/icons/heart.svg"),
		"crossbow": _tex("res://assets/icons/plus.svg"),
		"pocketwatch": _tex("res://assets/icons/rotate.svg"),
		"double_axe": _tex("res://assets/icons/swords.svg"),
		"victory_flask": _tex("res://assets/icons/heart.svg"),
		"grappling_hook": _tex("res://assets/icons/link.svg"),
		"spiked_shield": tex_shield,
		"grief_jar": _tex("res://assets/icons/droplet.svg"),
		"longbow": _tex("res://assets/icons/plus.svg"),
		"lantern": _tex("res://assets/icons/sparkles.svg"),
		"mirror_shard": _tex("res://assets/icons/copy.svg"),
		"caltrops": _tex("res://assets/icons/footprints.svg"),
		"echo_bell": _tex("res://assets/icons/copy.svg"),
		"quiet_bell": _tex("res://assets/icons/ban.svg"),
		"net": _tex("res://assets/icons/link.svg"),
		"iron_chain": _tex("res://assets/icons/link.svg"),
		"counting_beads": _tex("res://assets/icons/sparkles.svg"),
		"last_match": _tex("res://assets/icons/palm.svg"),
		"measuring_tape": tex_sword,
		"mute_stone": _tex("res://assets/icons/rotate.svg"),
		"arrow_head": _tex("res://assets/icons/swords.svg"),
		"danger_magnet": _tex("res://assets/icons/rotate.svg"),
	}
	tex_special = {
		"no_atk_dmg": _tex("res://assets/icons/ban.svg"),
		"last_hp": _tex("res://assets/icons/copy.svg"),
		"double_hit": _tex("res://assets/icons/swords.svg"),
		"buff_hp": _tex("res://assets/icons/users.svg"),
		"hp_spin": tex_heart,
		"kill_scale": _tex("res://assets/icons/trending.svg"),
		"atk_spin": tex_sword,
		"item_atk": _tex("res://assets/icons/layers.svg"),
		"two_items": _tex("res://assets/icons/sparkles.svg"),
		"atk_eq_hp": _tex("res://assets/icons/link.svg"),
		"pack_hp": _tex("res://assets/icons/users.svg"),
		"leech_lowest": tex_heart,
		"copy_atk": _tex("res://assets/icons/copy.svg"),
		"gift": _tex("res://assets/icons/layers.svg"),
		"queen_hits": _tex("res://assets/icons/plus.svg"),
		"buff_atk": _tex("res://assets/icons/trending.svg"),
		"pierce": _tex("res://assets/icons/ban.svg"),
		"thorns": _tex("res://assets/icons/link.svg"),
		"eat_item": _tex("res://assets/icons/layers.svg"),
		"petrify": _tex("res://assets/icons/mountain.svg"),
		"interrupt": _tex("res://assets/icons/sparkles.svg"),
		"item_swings": _tex("res://assets/icons/footprints.svg"),
		"split_t2": _tex("res://assets/icons/rotate.svg"),
		"no_keep": _tex("res://assets/icons/ban.svg"),
		"even_twice": _tex("res://assets/icons/users.svg"),
		"zero_toll": _tex("res://assets/icons/skull.svg"),
		"left_atk": _tex("res://assets/icons/layers.svg"),
		"empty_purse": _tex("res://assets/icons/layers.svg"),
		"wickrise": _tex("res://assets/icons/trending.svg"),
		"one_chip": _tex("res://assets/icons/mountain.svg"),
		"take_instead": _tex("res://assets/icons/shield.svg"),
		"pass_right": _tex("res://assets/icons/link.svg"),
		"coward": _tex("res://assets/icons/footprints.svg"),
		"fair_trade": _tex("res://assets/icons/layers.svg"),
		"gift_shield": _tex("res://assets/icons/shield.svg"),
		"insure": _tex("res://assets/icons/heart.svg"),
		"no_defeat": _tex("res://assets/icons/ban.svg"),
		"atk_eq_blk": _tex("res://assets/icons/link.svg"),
		"item_double": _tex("res://assets/icons/swords.svg"),
		"pack_atk": _tex("res://assets/icons/users.svg"),
	}


func _load_catalog() -> void:
	var f := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing catalog: %s" % CATALOG_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("catalog.json did not parse")
		return
	catalog = parsed
	for m in catalog.get("monsters", []):
		monsters_by_id[str(m["id"])] = m
	for it in catalog.get("items", []):
		items_by_id[str(it["id"])] = it


func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _load_lore() -> void:
	lore = _load_json("res://data/lore.json")
	cabin_layout = _load_json("res://data/cabin-layout.json")


func _load_runtime() -> void:
	var f := FileAccess.open(RUNTIME_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing runtime: %s" % RUNTIME_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		runtime = parsed


func _build_ui() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dungeon_bg = DUNGEON_BG.new()
	add_child(dungeon_bg)
	dungeon_bg.setup(art)

	var root := MarginContainer.new()
	_ui_root = root
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 20)
	root.add_theme_constant_override("margin_right", 20)
	root.add_theme_constant_override("margin_top", 8)
	root.add_theme_constant_override("margin_bottom", 28)
	add_child(root)

	var mid := HBoxContainer.new()
	mid.add_theme_constant_override("separation", 16)
	root.add_child(mid)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 6)
	mid.add_child(left)

	play_field = Control.new()
	play_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	play_field.custom_minimum_size = Vector2(0, 320)
	play_field.clip_contents = false
	play_field.resized.connect(_layout_play_field)
	left.add_child(play_field)

	hearts_box = HBoxContainer.new()
	hearts_box.visible = true
	hearts_box.add_theme_constant_override("separation", 2)
	play_field.add_child(hearts_box)
	for _h in range(HP_MAX):
		var h := TextureRect.new()
		var ht: Texture2D = tex_heart
		if art != null and art.tile("ui_heart_full") != null:
			ht = art.tile("ui_heart_full")
		h.texture = ht
		h.custom_minimum_size = Vector2(32, 32)
		h.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		h.pivot_offset = Vector2(16, 16)
		h.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hearts_box.add_child(h)

	trophy = TROPHY_MOUNT.new()
	var skull_tex: Texture2D = tex_by_monster.get("skeleton", tex_heart)
	if art != null and art.tile("skull") != null:
		skull_tex = art.tile("skull")
	trophy.setup(skull_tex)
	play_field.add_child(trophy)

	cue_label = FitLabelBox.make()
	cue_label.show_frame = false
	cue_label.padding = 0
	cue_label.max_font_size = 22
	cue_label.min_font_size = 16
	cue_label.font_color = Color("f0e6d8")
	cue_label.set_outline(Color("100e0c"), 4)
	cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_field.add_child(cue_label)

	tray = HBoxContainer.new()
	tray.add_theme_constant_override("separation", 12)
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	play_field.add_child(tray)

	wheel_view = WHEEL_SCRIPT.new()
	wheel_view.custom_minimum_size = Vector2(640, 640)
	play_field.add_child(wheel_view)
	wheel_view.set_atlas(tex_heart, tex_sword, tex_plus, tex_by_monster, tex_special, tex_shield)
	var heart_full: Texture2D = _tex("res://assets/icons/heart_full.png")
	var heart_empty: Texture2D = _tex("res://assets/icons/heart_empty.png")
	if art != null:
		wheel_view.set_portraits(art.portraits())
		if wheel_view.has_method("setup_run_hero"):
			wheel_view.setup_run_hero(art)
		else:
			wheel_view.set_player(art.frames("knight_m"))
		if wheel_view.has_signal("death_floor"):
			wheel_view.death_floor.connect(_on_hero_death_floor)
		if art.tile("ui_heart_full") != null:
			heart_full = art.tile("ui_heart_full")
		if art.tile("ui_heart_empty") != null:
			heart_empty = art.tile("ui_heart_empty")
	wheel_view.set_hub_hearts(heart_full, heart_empty)
	wheel_view.z_index = 0
	dungeon_deck_ui = DUNGEON_DECK.new()
	dungeon_deck_ui.setup()
	dungeon_deck_ui.visible = false
	play_field.add_child(dungeon_deck_ui)
	if art != null and art.tile("crate") != null:
		dungeon_deck_ui.art_tex = art.tile("crate")
	elif art != null and art.tile("column") != null:
		dungeon_deck_ui.art_tex = art.tile("column")
	dungeon_deck_ui.hovered.connect(_on_deck_hovered)
	dungeon_deck_ui.unhovered.connect(_on_deck_unhovered)
	dungeon_deck_ui.edit_wanted.connect(_on_deck_edit)
	challenge_draft_ui = CHALLENGE_DRAFT.new()
	challenge_draft_ui.setup()
	play_field.add_child(challenge_draft_ui)
	challenge_draft_ui.hovered_item.connect(_on_item_hovered)
	challenge_draft_ui.unhovered_item.connect(_on_item_unhovered)
	trophy.z_index = 6
	hearts_box.z_index = 6
	cue_label.z_index = 5
	tray.z_index = 7
	wheel_view.slice_clicked.connect(_on_slice_clicked)
	wheel_view.slice_hovered.connect(_on_slice_hovered)
	wheel_view.slice_right_clicked.connect(_on_slice_right_clicked)
	wheel_view.segment_passed.connect(func(_i: int, speed01: float) -> void:
		if sfx:
			sfx.play_tick(speed01)
	)
	wheel_view.atk_ticked.connect(func() -> void:
		if sfx:
			sfx.play_event(&"wheel.num_tick_atk")
	)
	wheel_view.hp_ticked.connect(func() -> void:
		if sfx:
			sfx.play_event(&"wheel.num_tick_hp")
	)

	blk_hud = PanelContainer.new()
	blk_hud.visible = false
	blk_value = Label.new()

	btn_wrap = MarginContainer.new()
	btn_wrap.z_index = 16
	btn_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(btn_wrap)
	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 12)
	btn_wrap.add_child(btns)
	btn_start = _pill("New", Color("2a2622"), Color("6a5f52"), _on_new)
	btn_place = _pill("Place", Color("1a2a1a"), Color("8dcb8d"), _on_place_mode)
	btn_bribe = _pill("Bribe", Color("2a1c14"), Color("d19a66"), _on_bribe_mode)
	btn_spin = _pill(PLAYER_COPY.text("combat.spin", "Spin"), Color("3a3220"), Color("e8c36a"), _on_spin)
	btn_spin.custom_minimum_size = Vector2(156, 48)
	btn_spin.add_theme_font_size_override("font_size", 22)
	if tex_rotate != null:
		btn_spin.icon = tex_rotate
	btn_challenge_begin = _pill(PLAYER_COPY.text("challenge.begin", "Begin"), Color("1a2a1a"), Color("8dcb8d"), _challenge_begin_play)
	btn_challenge_begin.custom_minimum_size = Vector2(156, 48)
	btn_challenge_begin.visible = false
	btn_done = _pill("Done", Color("3a2820"), Color("d19a66"), _on_done)
	btn_undo = _pill("Undo", Color("1c2428"), Color("6bb3d9"), _on_undo)
	btn_redo = _pill("Redo", Color("24201c"), Color("c4a574"), _on_redo)
	btns.add_child(btn_start)
	btns.add_child(btn_place)
	btns.add_child(btn_bribe)
	btns.add_child(btn_spin)
	btns.add_child(btn_challenge_begin)
	btns.add_child(btn_done)
	btns.add_child(btn_undo)
	btns.add_child(btn_redo)
	btn_spin.mouse_entered.connect(_on_spin_hover.bind(true))
	btn_spin.mouse_exited.connect(_on_spin_hover.bind(false))
	btn_place.mouse_entered.connect(_on_place_hover.bind(true))
	btn_place.mouse_exited.connect(_on_place_hover.bind(false))
	btn_done.mouse_entered.connect(_on_done_hover.bind(true))
	btn_done.mouse_exited.connect(_on_done_hover.bind(false))

	choice_box = HBoxContainer.new()
	choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_box.add_theme_constant_override("separation", 10)
	choice_box.z_index = 16
	left.add_child(choice_box)

	hotbar_wrap = MarginContainer.new()
	hotbar_wrap.add_theme_constant_override("margin_top", 6)
	hotbar_wrap.add_theme_constant_override("margin_bottom", 2)
	hotbar_wrap.z_index = 16
	hotbar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hotbar_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(hotbar_wrap)
	var hot_align := HBoxContainer.new()
	hot_align.alignment = BoxContainer.ALIGNMENT_CENTER
	hot_align.add_theme_constant_override("separation", 0)
	hotbar_wrap.add_child(hot_align)
	hotbar_panel = PanelContainer.new()
	hotbar_panel.visible = true
	hotbar_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hotbar_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("14100ce8")
	hsb.border_color = Color("c4a574")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(8)
	hsb.content_margin_left = 6
	hsb.content_margin_right = 6
	hsb.content_margin_top = 6
	hsb.content_margin_bottom = 6
	hotbar_panel.add_theme_stylebox_override("panel", hsb)
	hot_align.add_child(hotbar_panel)
	hotbar_box = GridContainer.new()
	hotbar_box.columns = 12
	hotbar_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hotbar_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hotbar_box.add_theme_constant_override("h_separation", 8)
	hotbar_box.add_theme_constant_override("v_separation", 8)
	hotbar_panel.add_child(hotbar_box)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(0, 0)
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.add_theme_constant_override("separation", 8)
	right.visible = false
	mid.add_child(right)
	right_col = right

	inspect = HOVER_PANEL.new()
	inspect.accept_clicks = true
	inspect.visible = false
	add_child(inspect)
	if art != null:
		inspect.apply_skin(art.ui.get("panel_brown", null))
	if _authoring():
		inspect.edit_pressed.connect(_open_content_editor)

	dev_panel = VBoxContainer.new()
	dev_panel.visible = false
	dev_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dev_panel.add_theme_constant_override("separation", 8)
	right.add_child(dev_panel)
	if _authoring():
		_build_dev_panel()

	log_btn = _pill("Log", Color("2a2622"), Color("6a5f52"), _toggle_log)
	log_btn.custom_minimum_size = Vector2(88, 34)
	log_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	log_btn.z_index = 8
	play_field.add_child(log_btn)
	log_label = COMBAT_LOG.new()
	log_label.setup()
	log_label.visible = false
	log_label.z_index = 4
	log_label.hover_changed.connect(_on_log_hover)
	play_field.add_child(log_label)
	_idle_inspect()

	_build_overlay()
	_build_copy_stamp()
	fly_tip = HOVER_PANEL.new()
	fly_tip.visible = false
	fly_tip.z_index = 110
	fly_tip.top_level = true
	fly_tip.process_mode = Node.PROCESS_MODE_ALWAYS
	fly_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly_tip.accept_clicks = false
	add_child(fly_tip)
	if art != null:
		fly_tip.apply_skin(art.ui.get("panel_beige", null))

	tut = TUTORIAL_GUIDE.new()
	add_child(tut)
	tut.setup(art, sfx)
	tut.continued.connect(_tut_on_continue)
	tut.skipped.connect(_tut_skip)
	tut.finished.connect(_tut_finished)

	combat_stage = COMBAT_STAGE.new()
	add_child(combat_stage)
	combat_stage.setup(art)
	if _authoring():
		combat_stage.edit_wanted.connect(func(id: String) -> void: _open_content_editor("monster", id))

	face_box = HOVER_PANEL.new()
	face_box.visible = false
	face_box.z_index = 11
	face_box.top_level = true
	face_box.accept_clicks = true
	face_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(face_box)
	if art != null:
		face_box.apply_skin(art.ui.get("panel_beige", null))
	if _authoring():
		face_box.edit_pressed.connect(_open_content_editor)

	hypno_stage = COMBAT_STAGE.new()
	add_child(hypno_stage)
	hypno_stage.setup(art)
	hypno_stage.flip_h = true
	hypno_stage.z_index = 13
	if _authoring():
		hypno_stage.edit_wanted.connect(func(id: String) -> void: _open_content_editor("monster", id))

	hypno_box = HOVER_PANEL.new()
	hypno_box.visible = false
	hypno_box.z_index = 12
	hypno_box.top_level = true
	hypno_box.accept_clicks = true
	hypno_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hypno_box)
	if art != null:
		hypno_box.apply_skin(art.ui.get("panel_beige", null))
	if _authoring():
		hypno_box.edit_pressed.connect(_open_content_editor)

	speech_box = SPEECH_BUBBLE.new()
	add_child(speech_box)
	speech_box.setup()
	ability_fx = ABILITY_FX.new()
	add_child(ability_fx)
	ability_fx.setup()
	ability_slash = ABILITY_SLASH.new()
	add_child(ability_slash)
	ability_slash.setup(art)

	draft_gate = DRAFT_GATE.new()
	add_child(draft_gate)
	draft_gate.setup(art, sfx)
	draft_gate.send_pressed.connect(_on_gate_send)
	draft_gate.refuse_pressed.connect(_on_gate_refuse)

	_courier = TextureRect.new()
	_courier.texture_filter = TEXTURE_FILTER_NEAREST
	_courier.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_courier.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_courier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_courier.z_index = 100
	_courier.top_level = true
	_courier.visible = false
	_courier.size = Vector2(96, 96)
	add_child(_courier)
	_ensure_courier_gear()

	fx_flash = ColorRect.new()
	fx_flash.color = Color(1, 1, 1, 1)
	fx_flash.modulate.a = 0.0
	fx_flash.set_anchors_preset(PRESET_FULL_RECT)
	fx_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_flash.z_index = 60
	add_child(fx_flash)
	_hall_wipe = ColorRect.new()
	_hall_wipe.color = Color("080605")
	_hall_wipe.modulate.a = 0.0
	_hall_wipe.visible = false
	_hall_wipe.set_anchors_preset(PRESET_FULL_RECT)
	_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hall_wipe.z_index = 70
	add_child(_hall_wipe)

	sfx = AUDIO_FX.new()
	add_child(sfx)
	sfx.setup()
	settings_ui = SETTINGS_MENU.new()
	add_child(settings_ui)
	settings_ui.setup(sfx)
	settings_ui.mode_picked.connect(_on_pause_mode)
	settings_ui.quit_pressed.connect(_quit_game)
	home_cabin = HOME_CABIN.new()
	add_child(home_cabin)
	home_cabin.setup(art, sfx, lore, cabin_layout, catalog)
	home_cabin.settings_ui = settings_ui
	home_cabin.closed.connect(_on_home_cabin_closed)
	home_cabin.inspect_wanted.connect(_on_cabin_inspect)
	home_cabin.item_hovered.connect(_on_cabin_item_hovered)
	home_cabin.item_unhovered.connect(_on_cabin_item_unhovered)
	home_cabin.route_chosen.connect(_start_route)
	home_cabin.tutorial_wanted.connect(_start_tutorial)
	home_cabin.quit_wanted.connect(_quit_game)
	home_cabin.attach_editor(self)
	settings_ui.peek_pressed.connect(_open_sack_peek)
	settings_ui.give_up_confirmed.connect(_give_up)
	settings_ui.closed.connect(_on_settings_closed)
	if DevFlag.on():
		settings_ui.fresh_save_pressed.connect(_dev_fresh_save)
		settings_ui.complete_save_pressed.connect(_dev_complete_save)
		settings_ui.bucket_progress_pressed.connect(_dev_open_buckets)
	rope_exit = preload("res://scripts/cabin/rope_exit.gd").new()
	add_child(rope_exit)
	rope_exit.setup(home_cabin, cabin_layout.get("extra", {}))
	rope_exit.climb.connect(_adventure_leave)
	rope_exit.deeper.connect(_rope_deeper)
	rope_exit.peek.connect(_open_sack_peek)
	sack_peek = preload("res://scripts/cabin/sack_peek.gd").new()
	add_child(sack_peek)
	sack_peek.setup(home_cabin, cabin_layout.get("extra", {}), art, self)
	_bucket_reveal = BUCKET_REVEAL.new()
	_bucket_reveal.sfx = sfx
	add_child(_bucket_reveal)
	if _authoring():
		settings_ui.roster_pressed.connect(_open_roster)
		settings_ui.script_pressed.connect(_open_script)
		content_ed = CONTENT_EDITOR.new()
		add_child(content_ed)
		content_ed.setup()
		content_ed.saved.connect(_on_content_saved)
		roster_ed = ROSTER_EDITOR.new()
		add_child(roster_ed)
		roster_ed.setup(art, sfx)
		roster_ed.committed.connect(_on_roster_committed)
		roster_ed.open_card.connect(_open_content_editor)
		roster_ed.unlocks_reset.connect(reset_bucket_progress)
		roster_ed.open_buckets.connect(_dev_open_buckets_from_roster)
		bucket_ed = BUCKET_OVERLAY.new()
		add_child(bucket_ed)
		bucket_ed.setup(sfx)
		bucket_ed.revealed_changed.connect(_dev_set_buckets)
		bucket_ed.card_hovered.connect(_dev_bucket_hovered)
		bucket_ed.card_unhovered.connect(_dev_bucket_unhovered)
		bucket_ed.card_edit.connect(_open_content_editor)
		bucket_ed.assignments_saved.connect(_on_bucket_assignments_saved)
		bucket_ed.closed.connect(_on_bucket_ed_closed)
		script_ed = SCRIPT_EDITOR.new()
		add_child(script_ed)
		script_ed.setup(sfx)
		script_ed.saved.connect(_on_script_saved)
		var shot_scr: Script = load("res://scripts/dev/shot_harness.gd") as Script
		if shot_scr != null:
			shot_harness = shot_scr.new()
			add_child(shot_harness)
			shot_harness.setup(self)
		var audit_scr: Script = load("res://scripts/dev/text_audit.gd") as Script
		if audit_scr != null:
			text_audit = audit_scr.new()
			add_child(text_audit)
			text_audit.setup(self)
	call_deferred("_layout_play_field")


func _build_overlay() -> void:
	overlay = ColorRect.new()
	overlay.color = Color("100e0cf2")
	overlay.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var wrap := CenterContainer.new()
	wrap.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	overlay.add_child(wrap)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	wrap.add_child(col)
	overlay_title = FitLabelBox.make()
	overlay_title.show_frame = false
	overlay_title.padding = 0
	overlay_title.max_font_size = 56
	overlay_title.min_font_size = 16
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.custom_minimum_size = Vector2(720, 64)
	overlay_title.font_color = Color("c4a574")
	col.add_child(overlay_title)
	overlay_sub = FitLabelBox.make()
	overlay_sub.show_frame = false
	overlay_sub.padding = 0
	overlay_sub.max_font_size = 20
	overlay_sub.min_font_size = 16
	overlay_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_sub.custom_minimum_size = Vector2(720, 48)
	overlay_sub.font_color = Color("d8cbb8")
	col.add_child(overlay_sub)
	overlay_score = FitLabelBox.make()
	overlay_score.show_frame = false
	overlay_score.padding = 0
	overlay_score.max_font_size = 32
	overlay_score.min_font_size = 16
	overlay_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_score.custom_minimum_size = Vector2(720, 40)
	overlay_score.font_color = Color("e8c36a")
	overlay_score.visible = false
	col.add_child(overlay_score)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	col.add_child(row)
	overlay_tut = _title_pill(PLAYER_COPY.text("title.how_to_play", "How to Play"), _start_tutorial)
	overlay_dive = _title_pill(PLAYER_COPY.text("title.dive_in", "Dive In"), _quick_start)
	overlay_btn = _title_pill(PLAYER_COPY.text("title.begin", "Adventure Mode"), _on_overlay_primary)
	overlay_undo = _pill("Undo", Color("1c2428"), Color("6bb3d9"), _on_undo)
	overlay_adventure = _title_pill(PLAYER_COPY.text("title.adventure", "Challenge Mode"), _begin_adventure)
	overlay_home = _title_pill(PLAYER_COPY.text("title.home", "Home"), _open_home_from_title)
	UxStyle.dress_title_button(overlay_btn, 240)
	UxStyle.dress_title_button(overlay_adventure, 240)
	UxStyle.dress_title_button(overlay_home, 240)
	row.add_child(overlay_tut)
	row.add_child(overlay_dive)
	var modes := HBoxContainer.new()
	modes.alignment = BoxContainer.ALIGNMENT_CENTER
	modes.add_theme_constant_override("separation", 14)
	col.add_child(modes)
	modes.add_child(overlay_btn)
	modes.add_child(overlay_adventure)
	modes.add_child(overlay_home)
	modes.add_child(overlay_undo)
	overlay_rest_row = HBoxContainer.new()
	overlay_rest_row.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay_rest_row.add_theme_constant_override("separation", 14)
	col.add_child(overlay_rest_row)
	overlay_continue = _pill(PLAYER_COPY.text("title.continue", "Continue"), Color("3a3220"), Color("e8c36a"), _adventure_continue)
	overlay_leave = _pill(PLAYER_COPY.text("title.leave", "Leave"), Color("2a2622"), Color("6a5f52"), _adventure_leave)
	overlay_rest_row.add_child(overlay_continue)
	overlay_rest_row.add_child(overlay_leave)
	overlay_rest_row.visible = false
	overlay_tools_row = HBoxContainer.new()
	overlay_tools_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(overlay_tools_row)
	if _authoring():
		overlay_latest = _pill("Play Latest", Color("3a3220"), Color("e8c36a"), _play_latest)
		overlay_tools_row.add_child(overlay_latest)
		overlay_dev = _pill("Developer Test", Color("1c1814"), Color("8a8178"), _open_dev_test)
		overlay_tools_row.add_child(overlay_dev)
		overlay_roster = _pill("Roster", Color("3a2820"), Color("c4a574"), _open_roster)
		overlay_tools_row.add_child(overlay_roster)
		overlay_script = _pill("Script", Color("3a2820"), Color("c4a574"), _open_script)
		overlay_tools_row.add_child(overlay_script)
	else:
		overlay_tools_row.visible = false
	overlay.z_index = 80


func _build_copy_stamp() -> void:
	if not _authoring():
		return
	_copy_stamp = FitLabelBox.make()
	_copy_stamp.show_frame = false
	_copy_stamp.padding = 0
	_copy_stamp.max_font_size = 12
	_copy_stamp.min_font_size = 12
	_copy_stamp.set_plain(PLAYER_COPY.stamp())
	_copy_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_copy_stamp.font_color = Color("8a8178")
	_copy_stamp.z_index = 80
	_copy_stamp.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	_copy_stamp.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_copy_stamp.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_copy_stamp.offset_left = -440
	_copy_stamp.offset_top = -28
	_copy_stamp.offset_right = -14
	_copy_stamp.offset_bottom = -8
	_copy_stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_copy_stamp.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_copy_stamp.visible = true
	add_child(_copy_stamp)


func _legend() -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 4)
	var order: Array[String] = [
		"on_click", "on_spin", "on_item_use", "on_resolve", "on_remove_slice",
		"on_draft", "on_place", "on_bribe",
		"var", "atk", "blk", "hp", "discard", "keep", "end"
	]
	for k in order:
		var info: Dictionary = LOG_KIND[k]
		var l := Label.new()
		l.text = str(info["tag"])
		l.add_theme_font_size_override("font_size", 11)
		l.add_theme_color_override("font_color", Color(str(info["hex"])))
		flow.add_child(l)
	return flow


func _title_pill(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UxStyle.dress_title_button(b)
	b.pressed.connect(cb)
	b.mouse_entered.connect(func() -> void:
		if sfx:
			sfx.play_event(&"ui.hover_title")
	)
	return b


func _pill(text: String, fill: Color, rim: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("c4a574"))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	var kind := "brown"
	if rim.is_equal_approx(Color("e8c36a")) or rim.is_equal_approx(Color("d19a66")):
		kind = "beige"
	elif rim.is_equal_approx(Color("6bb3d9")):
		kind = "blue"
	elif rim.is_equal_approx(Color("8dcb8d")):
		kind = "grey"
	var up := UxStyle.long_button(kind, false)
	var down := UxStyle.long_button(kind, true)
	b.add_theme_stylebox_override("normal", up)
	b.add_theme_stylebox_override("hover", up)
	b.add_theme_stylebox_override("focus", up)
	b.add_theme_stylebox_override("pressed", down)
	var dim := UxStyle.long_button("grey", false)
	b.add_theme_stylebox_override("disabled", dim)
	b.pressed.connect(cb)
	return b


func _sb(fill: Color, rim: Color, border: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = rim
	s.set_border_width_all(border)
	s.set_corner_radius_all(999)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


func _build_dev_panel() -> void:
	var play_row := HBoxContainer.new()
	play_row.add_theme_constant_override("separation", 8)
	dev_panel.add_child(play_row)
	var latest_play := _pill("Play Latest", Color("3a3220"), Color("e8c36a"), _play_latest)
	latest_play.custom_minimum_size = Vector2(0, 48)
	play_row.add_child(latest_play)
	dev_enter = _pill("Play", Color("3a3220"), Color("e8c36a"), _dev_enter)
	dev_enter.custom_minimum_size = Vector2(0, 48)
	play_row.add_child(dev_enter)
	var sort_cap := Label.new()
	sort_cap.text = "Sort by"
	sort_cap.add_theme_font_size_override("font_size", 16)
	sort_cap.add_theme_color_override("font_color", Color("e8c36a"))
	dev_panel.add_child(sort_cap)
	var sort_row := HBoxContainer.new()
	sort_row.add_theme_constant_override("separation", 6)
	dev_panel.add_child(sort_row)
	dev_latest_btn = _pill("Latest", Color("3a1c14"), Color("e8c36a"), _dev_fill_latest.bind(true))
	dev_latest_btn.custom_minimum_size = Vector2(0, 40)
	sort_row.add_child(dev_latest_btn)
	for stage in REVIEW_STAGE.STAGES:
		var b := _pill(str(stage).capitalize(), Color("3a1c14") if str(stage) == "rough" else Color("241c18"), Color("e8c36a") if str(stage) == "rough" else Color("6a5f52"), _dev_sort_by.bind(str(stage)))
		b.custom_minimum_size = Vector2(0, 40)
		_dev_sort_btns[str(stage)] = b
		sort_row.add_child(b)
	dev_mon_n = Label.new()
	dev_mon_n.add_theme_font_size_override("font_size", 16)
	dev_mon_n.add_theme_color_override("font_color", Color("e8c36a"))
	dev_panel.add_child(dev_mon_n)
	var mscroll := ScrollContainer.new()
	mscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mscroll.custom_minimum_size = Vector2(0, 120)
	dev_panel.add_child(mscroll)
	dev_mon_grid = GridContainer.new()
	dev_mon_grid.columns = 2
	dev_mon_grid.add_theme_constant_override("h_separation", 6)
	dev_mon_grid.add_theme_constant_override("v_separation", 6)
	mscroll.add_child(dev_mon_grid)
	dev_item_n = Label.new()
	dev_item_n.add_theme_font_size_override("font_size", 16)
	dev_item_n.add_theme_color_override("font_color", Color("e8c36a"))
	dev_panel.add_child(dev_item_n)
	var iscroll := ScrollContainer.new()
	iscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	iscroll.custom_minimum_size = Vector2(0, 120)
	dev_panel.add_child(iscroll)
	dev_item_grid = GridContainer.new()
	dev_item_grid.columns = 2
	dev_item_grid.add_theme_constant_override("h_separation", 6)
	dev_item_grid.add_theme_constant_override("v_separation", 6)
	iscroll.add_child(dev_item_grid)


func _open_dev_test() -> void:
	if not _authoring():
		return
	_hide_cabin_for_run()
	_dev_review = ""
	_reset_run()
	phase = "devtest"
	draft_action = "place"
	if dev_panel:
		dev_panel.visible = true
	if log_label:
		log_label.visible = false
	if right_col:
		right_col.visible = true
		right_col.custom_minimum_size = Vector2(380, 0)
	_fill_dev_grids()
	_sync_dev_sort_btns()
	_log("on_click", "Developer Test")
	if sfx:
		sfx.play("book", -10.0)
	_refresh()


func _play_latest() -> void:
	if not _authoring():
		return
	_hide_cabin_for_run()
	_reset_run()
	phase = "devtest"
	draft_action = "place"
	if dev_panel:
		dev_panel.visible = false
	if log_label:
		log_label.visible = true
	if not _dev_fill_latest(false):
		phase = "title"
		if sfx:
			sfx.play("error", -12.0, 1.2)
		_refresh()
		return
	_log("on_click", "Play Latest")
	_dev_enter()


func _dev_fill_latest(noisy: bool = true) -> bool:
	if phase != "devtest":
		_open_dev_test()
	_dev_review = "latest"
	_empty_wheel()
	hotbar.clear()
	_fill_dev_grids()
	_sync_dev_sort_btns()
	var mons: PackedStringArray = RECENT_EDITS.latest_ids("monster", monsters_by_id, items_by_id)
	var items: PackedStringArray = RECENT_EDITS.latest_ids("item", monsters_by_id, items_by_id)
	if mons.is_empty():
		if noisy and sfx:
			sfx.play("error", -12.0, 1.2)
		_sync_wheel_stats()
		_refresh()
		return false
	for id in mons:
		_dev_add_monster(str(id), false)
	for id2 in items:
		_dev_add_item(str(id2), false)
	var names: PackedStringArray = PackedStringArray()
	for id3 in mons:
		var mc: Dictionary = monsters_by_id.get(str(id3), {})
		names.append(_title_case(str(mc.get("name", id3))))
	for id4 in items:
		var ic: Dictionary = items_by_id.get(str(id4), {})
		names.append(_title_case(str(ic.get("name", id4))))
	_log("on_draft", " ".join(names))
	if noisy and sfx:
		sfx.play("confirm", -8.0)
	_sync_wheel_stats()
	_refresh()
	return true


func _fill_dev_grids() -> void:
	if dev_mon_grid == null:
		return
	_clear_box(dev_mon_grid)
	_clear_box(dev_item_grid)
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		if _dev_review != "" and _dev_review != "latest" and REVIEW_STAGE.of_card(card) != _dev_review:
			continue
		dev_mon_grid.add_child(_dev_tile(str(id), _title_case(str(card.get("name", id))), str(card.get("rarity", "")), int(card.get("tier", 0)), true))
	for id2 in runtime.get("items", []):
		var card2: Dictionary = items_by_id.get(str(id2), {})
		if card2.is_empty():
			continue
		if _dev_review != "" and _dev_review != "latest" and REVIEW_STAGE.of_card(card2) != _dev_review:
			continue
		dev_item_grid.add_child(_dev_tile(str(id2), _title_case(str(card2.get("name", id2))), str(card2.get("rarity", "")), int(card2.get("tier", 0)), false))


func _dev_tile(id: String, name: String, rarity: String, tier: int, is_mon: bool) -> Button:
	var sub: String = "Tier %s" % tier if tier > 0 else ""
	if rarity != "" and rarity != "starter":
		sub = "%s · %s" % [rarity, sub] if sub != "" else rarity
	var b := Button.new()
	b.text = "%s\n%s" % [name, sub.strip_edges()]
	b.custom_minimum_size = Vector2(168, 56)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	b.add_theme_stylebox_override("normal", _sb(Color("241c18"), Color("6a5f52"), 1))
	b.add_theme_stylebox_override("hover", _sb(Color("2e241c"), Color("e8c36a"), 2))
	b.add_theme_stylebox_override("pressed", _sb(Color("1c1814"), Color("c4a574"), 1))
	if is_mon:
		b.pressed.connect(_dev_add_monster.bind(id))
	else:
		b.pressed.connect(_dev_add_item.bind(id))
	return b


func _dev_add_monster(id: String, noisy: bool = true) -> void:
	if phase != "devtest":
		return
	var idx: int = -1
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "empty":
			idx = i
			break
	if idx < 0:
		if noisy and sfx:
			sfx.play("error", -12.0, 1.2)
		return
	var m: Dictionary = _make_monster(id)
	m["slot"] = str(wheel[idx].get("slot", SLOT_ORDER[idx] if idx < SLOT_ORDER.size() else ""))
	m["spin_locked"] = false
	wheel[idx] = m
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	if noisy:
		if sfx:
			sfx.play("drop", -8.0)
		_sync_wheel_stats()
		_refresh()


func _dev_add_item(id: String, noisy: bool = true) -> void:
	if phase != "devtest":
		return
	if hotbar.size() >= DEV_ITEM_MAX:
		if noisy and sfx:
			sfx.play("error", -12.0, 1.2)
		return
	var it: Dictionary = _make_item(id)
	hotbar.append(it)
	_sort_hotbar()
	_log("on_place", "item  %s" % it.get("name", id))
	if noisy:
		if sfx:
			sfx.play("pluck", -10.0)
		_refresh()


func _dev_sort_by(stage: String) -> void:
	_dev_review = stage
	if phase != "devtest":
		_open_dev_test()
		_dev_review = stage
	_empty_wheel()
	hotbar.clear()
	_fill_dev_grids()
	_sync_dev_sort_btns()
	var mons: Array = _dev_ids_for("monster", stage)
	var items: Array = _dev_ids_for("item", stage)
	if mons.is_empty() and items.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		_sync_wheel_stats()
		_refresh()
		return
	for i in 8:
		if mons.is_empty():
			break
		_dev_add_monster(str(mons[i % mons.size()]), false)
	for j in 8:
		if items.is_empty():
			break
		_dev_add_item(str(items[j % items.size()]), false)
	if sfx:
		sfx.play("confirm", -8.0)
	_sync_wheel_stats()
	_refresh()


func _dev_ids_for(kind: String, stage: String) -> Array:
	var src: Array = runtime.get("monsters" if kind == "monster" else "items", [])
	var by: Dictionary = monsters_by_id if kind == "monster" else items_by_id
	var out: Array = []
	for id in src:
		var card: Dictionary = by.get(str(id), {})
		if card.is_empty():
			continue
		if REVIEW_STAGE.of_card(card) == stage:
			out.append(str(id))
	return out


func _sync_dev_sort_btns() -> void:
	if dev_latest_btn:
		dev_latest_btn.modulate = Color.WHITE if _dev_review == "latest" else Color(1, 1, 1, 0.55)
	for k in _dev_sort_btns.keys():
		var b: Button = _dev_sort_btns[k]
		b.modulate = Color.WHITE if str(k) == _dev_review else Color(1, 1, 1, 0.55)


func _dev_click_slice(index: int) -> void:
	if str(wheel[index].get("kind", "")) != "monster":
		return
	_log("on_bribe", "cut  %s" % wheel[index].get("name", "?"))
	wheel[index] = {"kind": "empty", "slot": str(wheel[index].get("slot", ""))}
	if sfx:
		sfx.play("scratch", -10.0)
	_sync_wheel_stats()
	_refresh()


func _dev_enter() -> void:
	if phase != "devtest":
		return
	if _monsters_left() <= 0:
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	var kept: Array = []
	for s in wheel:
		if str(s.get("kind", "")) == "monster":
			kept.append(s)
	wheel = kept
	_reseat_slots()
	_sort_hotbar()
	if dev_panel:
		dev_panel.visible = false
	if log_label:
		log_label.visible = true
	phase = "ready"
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_open", -8.0)
	_sync_wheel_stats()
	_undo_arm()
	_refresh()


func _sync_dev_panel() -> void:
	if dev_panel == null or not dev_panel.visible:
		return
	if dev_mon_n:
		dev_mon_n.text = "Monsters  %s / 8" % _monsters_left()
	if dev_item_n:
		dev_item_n.text = "Items  %s / %s" % [hotbar.size(), DEV_ITEM_MAX]
	if dev_enter:
		dev_enter.disabled = _monsters_left() <= 0


func _on_new() -> void:
	if phase == "spinning":
		return
	if adventure:
		_begin_adventure()
	else:
		_begin_run()


func _on_overlay_primary() -> void:
	if phase == "defeat":
		_go_home_loss()
		return
	if phase == "title":
		_begin_run()
	elif adventure:
		_begin_adventure()
	else:
		_begin_run()


func _reset_run() -> void:
	_undo_clear()
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_cleric_line = ""
	_cleric_talk_index = -1
	_mill_beat = ""
	adventure = false
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	_adventure_busy = false
	challenge_deck.clear()
	challenge_aim = -1
	challenge_armed = false
	challenge_draft_plan.clear()
	challenge_pick_i = 0
	_challenge_force_spin = false
	_challenge_pending_gain = {}
	_challenge_loot_wait = false
	_challenge_pair.clear()
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	_deck_hovering = false
	_peek_slice = {}
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(0)
		if dungeon_deck_ui.has_method("set_peek"):
			dungeon_deck_ui.set_peek(null, "")
		dungeon_deck_ui.visible = false
	if dungeon_bg:
		dungeon_bg.reset_hall()
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
		_clear_courier_gear()
	_walker_busy = false
	if speech_box:
		speech_box.hide_speech()
	if not _tut_boot:
		in_tutorial = false
		if tut:
			tut.close()
	if wheel_view != null:
		wheel_view.portrait_away = -1
		wheel_view.kill_spin()
		if wheel_view.has_method("reset_hero"):
			wheel_view.reset_hero()
	if sfx:
		sfx.play("confirm_big", -8.0)
		sfx.start_music()
	rng.randomize()
	hp = HP_MAX
	blk = 0
	facing_index = -1
	pending_choice.clear()
	pending_monster.clear()
	pending_item.clear()
	uid_seq = 0
	hotbar.clear()
	_hotbar_sig = ""
	_blk_shown = 0
	_ghost_blk = -1
	_ghost_hp = -1
	_hp_shown = HP_MAX
	_fly_card = null
	_inspect_pinned = false
	_cue_shown = ""
	_face_atk_shown = ""
	_face_hp_shown = ""
	_slain_shown = -1
	last_mob_hp = 3
	last_mob_atk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	last_blk_gain = 0
	last_item_copy = {}
	silenced = {}
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	_bleed_hold = 0
	_bleed_losses = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	_magnet_seq = 0
	_magnet_pending_consume = ""
	beads_step = 1
	_reroll_skip = -1
	draft_action = "place"
	starters_left = STARTER_COUNT
	starter_items_left = STARTER_ITEM_COUNT
	smoke_given = false
	drafts_left = DRAFT_ROUNDS
	if log_label and log_label.has_method("clear_all"):
		log_label.clear_all()
	_log_user_hid = false
	_log_user_show = false
	if combat_stage:
		combat_stage.hide_stage()
	_hide_hypno()
	_fill_pools()
	_empty_wheel()
	if dev_panel:
		dev_panel.visible = false
	_sync_log_panel()


func _begin_run() -> void:
	_hide_cabin_for_run()
	_reset_run()
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Begin")
	_log("var", "HP %s" % hp)
	_log("on_draft", "The mill")
	_refresh()
	_run_mill()


func _begin_adventure() -> void:
	_hide_cabin_for_run()
	_reset_run()
	adventure = true
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Challenge Mode")
	_log("var", "HP %s" % hp)
	_log("on_draft", "Dungeon 1")
	_refresh()
	await _reveal_new_buckets()
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	await _run_challenge_setup()


func _enter_dungeon_clear() -> void:
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("victory", 2)
	if sfx:
		sfx.set_combat_music(false)
		sfx.play("confirm_big", -6.0)
		sfx.play_event(&"sting.clear")
		sfx.music_title()
	_flash_screen(Color("e8c36a"), 0.28)
	if combat_stage:
		combat_stage.hide_stage()
	_hide_hypno()
	_undo_wall()
	if in_tutorial:
		phase = "victory"
		_log("end", "cleared")
		return
	if not adventure:
		_log("end", "cleared")
		_classic_swipe_home()
		return
	dungeons_cleared += 1
	_advance_bucket_counter()
	phase = "rest"
	_log("end", "dungeon %s" % dungeons_cleared)
	facing_index = -1


func _adventure_leave() -> void:
	if not adventure or phase != "rest" or _adventure_busy:
		return
	_adventure_busy = true
	var ids: Array = []
	for it in hotbar:
		var cid: String = str(it.get("card_id", ""))
		if cid != "":
			ids.append(cid)
	var news: Array = []
	if home_cabin:
		news = home_cabin.swipe_ids(ids)
	if overlay:
		overlay.visible = false
	if rope_exit:
		rope_exit.hide_exit()
	_log("end", "leave")
	if sfx:
		sfx.play("whoosh", -10.0, 0.9)
	await get_tree().create_timer(0.45).timeout
	_cabin_from_leave = true
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "win", news, ids)
	_adventure_busy = false


func _classic_swipe_home() -> void:
	var ids: Array = []
	for it in hotbar:
		var cid: String = str(it.get("card_id", ""))
		if cid != "":
			ids.append(cid)
	var news: Array = []
	if home_cabin:
		news = home_cabin.swipe_ids(ids)
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "win", news, ids)


func _hide_cabin_for_run() -> void:
	if home_cabin:
		home_cabin.hide_for_run()
	if rope_exit:
		rope_exit.hide_exit()
	if sack_peek and sack_peek.visible:
		sack_peek.close()
	if overlay:
		overlay.visible = false
	get_tree().paused = false
	_sync_run_hero_gear()


func _start_route(route: String) -> void:
	_hide_cabin_for_run()
	if home_cabin:
		home_cabin.note_belly(1)
	match route:
		"gatehouse":
			_begin_run()
		"long_drop":
			_begin_adventure()
		"shortcut":
			_quick_start()
		_:
			_begin_run()


func _go_home_loss() -> void:
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "loss", [], [])


func _give_up() -> void:
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "loss", [], [])


func _rope_deeper() -> void:
	_adventure_continue()
	if home_cabin:
		home_cabin.note_belly(dungeon_index + 1)


func _open_sack_peek() -> void:
	if sack_peek:
		if settings_ui and settings_ui.visible:
			sack_peek.z_index = 121
		else:
			sack_peek.z_index = 81
		sack_peek.open_peek()


func _open_home_from_title() -> void:
	_cabin_from_leave = false
	_open_home_cabin(false)


func _cabin_up() -> bool:
	return home_cabin != null and home_cabin.visible


func _hide_fight_hover() -> void:
	_fly_card = null
	if fly_tip:
		fly_tip.hide_plate()
	if inspect:
		inspect.visible = false
	if speech_box and speech_box.has_method("hide_speech"):
		speech_box.hide_speech()


func _open_home_cabin(walk_in: bool, kind: String = "win", new_ids: Array = [], held_ids: Array = []) -> void:
	if home_cabin == null:
		return
	_hide_fight_hover()
	home_cabin.open_cabin(items_by_id, tex_by_item, _buckets_revealed, walk_in, kind, new_ids, held_ids)
	if overlay:
		overlay.visible = false
	if rope_exit:
		rope_exit.hide_exit()
	get_tree().paused = true
	_hide_fight_hover()


func _on_home_cabin_closed() -> void:
	get_tree().paused = false
	if fly_tip:
		fly_tip.hide_plate()
	if _cabin_from_leave:
		_cabin_from_leave = false
		_reset_run()
		phase = "title"
		if sfx:
			sfx.start_music()
	_refresh()


func _on_cabin_inspect(card_id: String) -> void:
	_on_cabin_item_hovered(card_id, null)


func _cabin_item_from_id(card_id: String) -> Dictionary:
	var card: Dictionary = items_by_id.get(card_id, {})
	if card.is_empty():
		return {}
	var ops: Dictionary = {}
	if card.has("ops") and typeof(card["ops"]) == TYPE_DICTIONARY:
		ops = (card["ops"] as Dictionary).duplicate(true)
	elif ITEM_OPS.has(card_id):
		ops = (ITEM_OPS[card_id] as Dictionary).duplicate(true)
	return {
		"uid": 0,
		"card_id": card_id,
		"name": str(card.get("name", card_id)),
		"ops": ops,
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"log_hint": str(card.get("log_hint", "")),
		"card_color": str(card.get("card_color", "")),
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "draft",
	}


func _on_cabin_item_hovered(card_id: String, slot: Control = null) -> void:
	var it: Dictionary = _cabin_item_from_id(card_id)
	if it.is_empty() or fly_tip == null:
		return
	_inspect_pinned = false
	_fly_card = slot
	var rule: Dictionary = _item_rule(it)
	var journal: Dictionary = {}
	if lore.has("items"):
		var entry: Dictionary = lore.get("items", {}).get(card_id, {})
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("journal", "")) != "":
			journal = {
				"body": str(entry.get("journal", "")),
				"footnotes": entry.get("footnotes", []),
				"is_new": home_cabin != null and bool(home_cabin.new_unseen.get(card_id, false)),
			}
	if home_cabin and home_cabin.visible and home_cabin.new_unseen.has(card_id):
		home_cabin.new_unseen.erase(card_id)
		home_cabin._save()
	fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), str(rule["body"]), str(rule["warn"]), null, "item", card_id, _item_look(it), journal)
	_place_fly(slot)


func _on_cabin_item_unhovered() -> void:
	_fly_card = null
	if fly_tip:
		fly_tip.hide_plate()


func _adventure_continue() -> void:
	if not adventure or phase != "rest" or _adventure_busy:
		return
	_adventure_busy = true
	_undo_clear()
	overlay.visible = false
	dungeon_index += 1
	await _reveal_new_buckets()
	silenced = {}
	phase = "draft"
	draft_action = "busy"
	_refresh()
	var seq: int = _mill_seq
	await _play_hall_wipe()
	if seq != _mill_seq or not adventure:
		_adventure_busy = false
		return
	_prep_next_dungeon()
	_log("on_draft", "Dungeon %s" % dungeon_index)
	_refresh()
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	await _run_challenge_setup()
	_adventure_busy = false
	_refresh()


func _prep_next_dungeon() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_cleric_line = ""
	_cleric_talk_index = -1
	_mill_beat = ""
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
		_clear_courier_gear()
	_walker_busy = false
	if speech_box:
		speech_box.hide_speech()
	if wheel_view != null:
		wheel_view.portrait_away = -1
		wheel_view.kill_spin()
		if wheel_view.has_method("reset_hero"):
			wheel_view.reset_hero()
	hp = HP_MAX
	blk = 0
	facing_index = -1
	pending_choice.clear()
	pending_monster.clear()
	pending_item.clear()
	_hotbar_sig = ""
	_blk_shown = 0
	_ghost_blk = -1
	_ghost_hp = -1
	_hp_shown = HP_MAX
	_cue_shown = ""
	_face_atk_shown = ""
	_face_hp_shown = ""
	_slain_shown = -1
	last_mob_hp = 3
	last_mob_atk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	last_blk_gain = 0
	last_item_copy = {}
	silenced = {}
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	_bleed_hold = 0
	_bleed_losses = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	_magnet_seq = 0
	_magnet_pending_consume = ""
	beads_step = 1
	_reroll_skip = -1
	draft_action = "busy"
	starters_left = STARTER_COUNT
	starter_items_left = STARTER_ITEM_COUNT
	smoke_given = false
	drafts_left = DRAFT_ROUNDS
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		it["spent"] = false
		it["keep_after"] = false
		it["siphon_blk"] = 0
		if str(_ops_of(it).get("kind", "")) == "atk_alt_24":
			it["alt_n"] = 2
	if combat_stage:
		combat_stage.hide_stage()
	_hide_hypno()
	if adventure:
		_fill_challenge_pools()
		_empty_wheel(CHALLENGE_SEATS)
	else:
		_fill_pools()
		_empty_wheel()


func _play_hall_wipe() -> void:
	if _hall_wipe:
		_hall_wipe.visible = true
		_hall_wipe.mouse_filter = Control.MOUSE_FILTER_STOP
		_hall_wipe.modulate.a = 0.0
	await _walk_knight_off()
	if dungeon_bg:
		var tw_pan := create_tween()
		tw_pan.tween_property(dungeon_bg, "pan", dungeon_bg.pan + 520.0, 0.45)
	if _hall_wipe:
		var tw := create_tween()
		tw.tween_property(_hall_wipe, "modulate:a", 1.0, 0.28)
		await tw.finished
	if dungeon_bg:
		dungeon_bg.bump_hall()
	if sfx:
		sfx.play("door_open", -8.0)
		sfx.play("whoosh", -10.0, 0.9)
		sfx.play_event(&"run.knight_off")
	if _hall_wipe:
		var tw2 := create_tween()
		tw2.tween_property(_hall_wipe, "modulate:a", 0.0, 0.34)
		await tw2.finished
		_hall_wipe.visible = false
		_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ensure_courier_gear() -> void:
	if _courier == null:
		return
	if _courier_gear.size() == 4:
		return
	for piece in ["rope", "goggles", "cap", "helm"]:
		var tr := TextureRect.new()
		tr.name = "Gear_%s" % piece
		tr.texture_filter = TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.position = Vector2.ZERO
		tr.size = Vector2(96, 96)
		tr.visible = false
		_courier.add_child(tr)
		_courier_gear[piece] = tr


func _clear_courier_gear() -> void:
	for piece in _courier_gear.keys():
		var tr: TextureRect = _courier_gear[piece]
		if tr:
			tr.texture = null
			tr.visible = false


func _hub_gear_worn() -> Dictionary:
	if home_cabin:
		return home_cabin.gear_worn
	return {"head": "", "eyes": "", "belt": ""}


func _sync_run_hero_gear() -> void:
	if wheel_view and wheel_view.has_method("set_hub_gear"):
		wheel_view.set_hub_gear(_hub_gear_worn())


func _set_courier_hero_frame(frames: Array, fi: int) -> void:
	_ensure_courier_gear()
	if frames.is_empty() or _courier == null:
		return
	var i: int = fi % frames.size()
	_courier.texture = frames[i]
	var worn: Dictionary = _hub_gear_worn()
	var head: String = str(worn.get("head", ""))
	for piece in ["rope", "goggles", "cap", "helm"]:
		var tr: TextureRect = _courier_gear.get(piece)
		if tr == null:
			continue
		var on: bool = false
		if piece == "rope":
			on = str(worn.get("belt", "")) == "rope"
		elif piece == "goggles":
			on = str(worn.get("eyes", "")) == "goggles"
		elif piece == "cap" or piece == "helm":
			on = head == piece
		if not on or art == null or not art.has_method("hero_run_gear"):
			tr.texture = null
			tr.visible = false
			continue
		var gframes: Array = art.hero_run_gear(piece, "walkoff")
		if gframes.is_empty():
			tr.texture = null
			tr.visible = false
			continue
		tr.size = Vector2(96, 96)
		tr.position = Vector2.ZERO
		tr.texture = gframes[i % gframes.size()]
		tr.visible = true


func _hero_walkoff_frames() -> Array:
	if art and art.has_method("hero_run_anim"):
		var frames: Array = art.hero_run_anim("walkoff")
		if not frames.is_empty():
			return frames
	if art:
		var fb: Array = art.run_frames("knight_m")
		if fb.is_empty():
			fb = art.frames("knight_m")
		return fb
	return []


func debug_pose_courier() -> void:
	var frames: Array = _hero_walkoff_frames()
	if frames.is_empty() or _courier == null:
		return
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2(1, 1)
	_courier.modulate.a = 1.0
	var start: Vector2 = Vector2(size.x * 0.46, size.y * 0.58)
	if wheel_view:
		start = wheel_view.global_position + wheel_view.size * Vector2(0.5, 0.62)
	_courier.global_position = start - _courier.pivot_offset
	_set_courier_hero_frame(frames, 1)
	_courier.visible = true


func _on_hero_death_floor() -> void:
	offset_top = 4.0
	offset_bottom = 4.0
	var tw := create_tween()
	tw.tween_interval(0.07)
	tw.tween_callback(func() -> void:
		offset_top = 0.0
		offset_bottom = 0.0
	)


func _walk_knight_off() -> void:
	var frames: Array = _hero_walkoff_frames()
	if frames.is_empty() or _courier == null:
		return
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2(1, 1)
	_courier.modulate.a = 1.0
	var start: Vector2 = Vector2(size.x * 0.46, size.y * 0.58)
	if wheel_view:
		start = wheel_view.global_position + wheel_view.size * Vector2(0.5, 0.62)
	_courier.global_position = start - _courier.pivot_offset
	_set_courier_hero_frame(frames, 0)
	_courier.visible = true
	if sfx:
		sfx.play("cloth", -10.0)
		sfx.play_event(&"run.knight_off")
	var dest := Vector2(size.x + 70.0, start.y) - _courier.pivot_offset
	var tw := create_tween()
	tw.tween_property(_courier, "global_position", dest, 0.62)
	var fi: int = 0
	await get_tree().process_frame
	while tw.is_running():
		fi = (fi + 1) % frames.size()
		_set_courier_hero_frame(frames, fi)
		await get_tree().create_timer(0.07).timeout
	_courier.visible = false
	_clear_courier_gear()
	_courier.scale = Vector2.ONE


func _quick_start() -> void:
	_hide_cabin_for_run()
	_reset_run()
	adventure = true
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Quick Start")
	_log("var", "HP %s" % hp)
	_log("on_draft", "Dungeon 1")
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	_refresh()
	await _challenge_seat_dungeon(false)
	_challenge_auto_opening_loot()
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	draft_action = ""
	phase = "ready"
	challenge_aim = -1
	if wheel_view:
		wheel_view.selected_index = -1
	_sort_hotbar()
	_sync_wheel_stats()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("confirm", -10.0)
		sfx.play("door_open", -12.0)
	_undo_arm()
	_refresh()
	_layout_play_field()


func _load_bucket_progress() -> void:
	_dungeons_ended = 0
	_buckets_revealed = 0
	var f := FileAccess.open(BUCKET_PROGRESS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_dungeons_ended = maxi(0, int(parsed.get("dungeons_ended", 0)))
	_buckets_revealed = maxi(0, int(parsed.get("revealed", 0)))


func _save_bucket_progress() -> void:
	var f := FileAccess.open(BUCKET_PROGRESS_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"dungeons_ended": _dungeons_ended,
		"revealed": _buckets_revealed,
	}))


func reset_bucket_progress() -> void:
	_dev_set_buckets(0)
	_guarantee_bucket = 0
	_log("var", "buckets reset")


func _dev_set_buckets(n: int) -> void:
	_buckets_revealed = clampi(n, 0, BucketRules.MAX_BUCKET)
	_dungeons_ended = _buckets_revealed
	_save_bucket_progress()
	_fill_pools()
	if home_cabin:
		home_cabin.buckets_open = _buckets_revealed


func _on_settings_closed() -> void:
	if fly_tip:
		fly_tip.z_index = 110
		fly_tip.hide_plate()
	if home_cabin:
		home_cabin.on_pause_closed()


func _dev_fresh_save() -> void:
	if home_cabin:
		home_cabin.stop_story()
	if settings_ui:
		settings_ui.close_menu()
	_reset_run()
	reset_bucket_progress()
	phase = "title"
	if overlay:
		overlay.visible = false
	if home_cabin:
		home_cabin.items_by_id = items_by_id
		home_cabin.tex_by_item = tex_by_item
		home_cabin.buckets_open = _buckets_revealed
		home_cabin.clear_to_fresh_save()
	_refresh()
	_log("on_click", "Fresh Save")


func _dev_complete_save() -> void:
	if home_cabin:
		home_cabin.stop_story()
	if settings_ui:
		settings_ui.close_menu()
	_reset_run()
	_dev_set_buckets(BucketRules.MAX_BUCKET)
	phase = "title"
	if overlay:
		overlay.visible = false
	if home_cabin:
		home_cabin.items_by_id = items_by_id
		home_cabin.tex_by_item = tex_by_item
		home_cabin.buckets_open = _buckets_revealed
		home_cabin.fill_complete_save()
		_open_home_cabin(false)
		home_cabin.play_ending()
	_log("on_click", "One Hundred Percent Complete")


func _dev_open_buckets() -> void:
	_show_bucket_editor()


func _dev_open_buckets_from_roster() -> void:
	_show_bucket_editor()


func _show_bucket_editor() -> void:
	if bucket_ed == null:
		return
	if settings_ui and settings_ui.visible:
		settings_ui.close_menu()
	var board: Dictionary = {}
	if roster_ed and roster_ed.visible:
		if roster_ed.has_method("flush_for_buckets") and not roster_ed.flush_for_buckets():
			return
		if roster_ed.has_method("live_board"):
			board = roster_ed.live_board()
	get_tree().paused = true
	bucket_ed.open_overlay(art, items_by_id, monsters_by_id, _buckets_revealed, board)


func _on_bucket_assignments_saved(items: Array, monsters: Array) -> void:
	_on_roster_committed(items, monsters)
	if roster_ed and roster_ed.visible and roster_ed.has_method("reload_from_disk"):
		roster_ed.reload_from_disk()


func _on_bucket_ed_closed() -> void:
	if fly_tip:
		fly_tip.z_index = 110
		fly_tip.hide_plate()
	if roster_ed and roster_ed.visible:
		return
	if content_ed and content_ed.visible:
		return
	get_tree().paused = false


func _dev_bucket_hovered(kind: String, card_id: String, slot: Control) -> void:
	if fly_tip == null:
		return
	fly_tip.z_index = 129
	_inspect_pinned = false
	_fly_card = slot
	if kind == "monster":
		var s: Dictionary = _preview_monster(card_id)
		if s.is_empty():
			return
		var rule: Dictionary = _monster_rule(s)
		var tex: Texture2D = tex_by_monster.get(card_id, null)
		if art and art.has_method("monster_still"):
			tex = art.monster_still(card_id)
		fly_tip.show_rule(
			str(rule.get("title", "")),
			str(rule.get("value", "")),
			str(rule.get("equation", "")),
			str(rule.get("body", "")),
			str(rule.get("warn", "")),
			tex,
			"monster",
			card_id,
			_monster_look(s)
		)
	else:
		var it: Dictionary = _cabin_item_from_id(card_id)
		if it.is_empty():
			return
		var irule: Dictionary = _item_rule(it)
		fly_tip.show_rule(
			str(irule.get("title", "")),
			str(irule.get("value", "")),
			str(irule.get("equation", "")),
			str(irule.get("body", "")),
			str(irule.get("warn", "")),
			null,
			"item",
			card_id,
			_item_look(it)
		)
	_place_fly(slot)


func _dev_bucket_unhovered() -> void:
	_fly_card = null
	if fly_tip:
		fly_tip.hide_plate()


func _preview_monster(id: String) -> Dictionary:
	var card: Dictionary = monsters_by_id.get(id, {})
	if card.is_empty():
		return {}
	return {
		"kind": "monster",
		"card_id": id,
		"name": str(card.get("name", id)),
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"call_name": MONSTER_LINES.call_of(id, card),
		"reminder": MONSTER_LINES.reminder_of(id, card),
		"atk": _card_base_atk(id),
		"hp": _card_base_hp(id),
		"pack_tier": int(card.get("tier", 1)),
	}


func _advance_bucket_counter() -> void:
	_dungeons_ended += 1
	_save_bucket_progress()
	_log("var", "dungeons ended %s" % _dungeons_ended)


func _bucket_open(card: Dictionary) -> bool:
	var n: int = BucketRules.parse(card.get("bucket", 0))
	return n >= 0 and n <= _buckets_revealed


func _reveal_new_buckets() -> void:
	if _dungeons_ended <= _buckets_revealed:
		return
	var newest: int = _buckets_revealed
	_unlock_screen = true
	_hide_board_for_unlock()
	for b in range(_buckets_revealed + 1, _dungeons_ended + 1):
		var entries: Array = _bucket_entries(b)
		if entries.is_empty():
			continue
		newest = b
		if _bucket_reveal != null:
			await _bucket_reveal.play(b, entries)
	_unlock_screen = false
	if _ui_root:
		_ui_root.visible = true
	if dungeon_bg:
		dungeon_bg.visible = true
	_buckets_revealed = _dungeons_ended
	if newest > 0:
		_guarantee_bucket = newest
	_save_bucket_progress()
	_fill_pools()


func _bucket_entries(bucket_n: int) -> Array:
	var out: Array = []
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if int(card.get("bucket", 0)) != bucket_n:
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_always_starter(card):
			continue
		var loot_tex: Texture2D = tex_by_item.get(id, null)
		if loot_tex == null and art != null:
			loot_tex = art.item_tex(id)
		out.append(_bucket_entry(card, "Loot", loot_tex))
	for id2 in monsters_by_id.keys():
		var card2: Dictionary = monsters_by_id[id2]
		if int(card2.get("bucket", 0)) != bucket_n:
			continue
		if str(card2.get("status", "live")) == "retired" or str(card2.get("status", "live")) == "hold":
			continue
		out.append(_bucket_entry(card2, "Foe", tex_by_monster.get(id2, null)))
	return out


func _bucket_entry(card: Dictionary, kind: String, tex: Texture2D) -> Dictionary:
	var atk_n: String = _bucket_stat(card, "atk")
	var hp_n: String = _bucket_stat(card, "hp")
	return {
		"kind": kind,
		"name": _title_case(str(card.get("name", ""))),
		"tex": tex,
		"ability": str(card.get("ability", "")).strip_edges(),
		"explainer": str(card.get("explainer", "")).strip_edges(),
		"call": str(card.get("call_name", "")).strip_edges(),
		"atk": atk_n,
		"hp": hp_n,
	}


func _bucket_stat(card: Dictionary, key: String) -> String:
	var blob: Variant = card.get(key, null)
	if typeof(blob) == TYPE_DICTIONARY and (blob as Dictionary).has("base"):
		return str(int((blob as Dictionary)["base"]))
	if typeof(blob) == TYPE_FLOAT or typeof(blob) == TYPE_INT:
		return str(int(blob))
	var alt: Variant = card.get(key + "_base", null)
	if typeof(alt) == TYPE_FLOAT or typeof(alt) == TYPE_INT:
		return str(int(alt))
	return ""


func _hide_board_for_unlock() -> void:
	if not _unlock_screen:
		return
	if _ui_root:
		_ui_root.visible = false
	if dungeon_bg:
		dungeon_bg.visible = false
	if overlay:
		overlay.visible = false
	if face_box:
		face_box.visible = false
	if inspect:
		inspect.visible = false
	if fly_tip:
		fly_tip.visible = false
	if speech_box:
		speech_box.hide_speech()


func _pull_bucket(pool: Array, by_id: Dictionary, bucket_n: int) -> String:
	var matches: Array = []
	for id in pool:
		var card: Dictionary = by_id.get(str(id), {})
		if int(card.get("bucket", 0)) == bucket_n:
			matches.append(str(id))
	if matches.is_empty():
		return ""
	var pick: String = str(matches[rng.randi_range(0, matches.size() - 1)])
	pool.erase(pick)
	return pick


func _force_guarantee_monster() -> void:
	if _guarantee_bucket <= 0:
		return
	for s in wheel:
		if str(s.get("kind", "")) != "monster":
			continue
		var have: String = str(s.get("card_id", ""))
		if int(monsters_by_id.get(have, {}).get("bucket", 0)) == _guarantee_bucket:
			return
	var id: String = _pull_bucket(monster_pool, monsters_by_id, _guarantee_bucket)
	if id == "":
		return
	var seats: Array[int] = []
	for raw in CARDINAL_SLOTS:
		var si: int = int(raw)
		if si < wheel.size() and str(wheel[si].get("kind", "")) == "monster":
			seats.append(si)
	if seats.is_empty():
		_seat_opener(int(CARDINAL_SLOTS[0]), id, "starter")
		return
	var at: int = seats[rng.randi_range(0, seats.size() - 1)]
	var old_id: String = str(wheel[at].get("card_id", ""))
	if old_id != "":
		monster_pool.append(old_id)
	_seat_opener(at, id, "starter")
	if wheel_view:
		wheel_view.set_slices(wheel, -1, "none")
		wheel_view.pulse_arrive(at)


func _ensure_starter_smoke(gifted: Array[int]) -> void:
	if not items_by_id.has("smoke_bomb"):
		return
	item_pool.erase("smoke_bomb")
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) == "smoke_bomb":
			smoke_given = true
			return
	var fresh: Dictionary = _make_item("smoke_bomb")
	_stamp_pack(fresh, _pack_tier_for("smoke_bomb", items_by_id, 1), "starter")
	if gifted.is_empty():
		hotbar.append(fresh)
	else:
		var at: int = gifted[rng.randi_range(0, gifted.size() - 1)]
		var old_id: String = str(hotbar[at].get("card_id", ""))
		if old_id != "" and old_id != "smoke_bomb" and not BucketRules.is_always_starter_id(old_id):
			item_pool.append(old_id)
		hotbar[at] = fresh
	smoke_given = true
	_log("on_place", "item  %s" % fresh.get("name", "Smoke Bomb"))


func _force_guarantee_item(gifted: Array[int]) -> void:
	if _guarantee_bucket <= 0:
		return
	for idx in gifted:
		if idx < 0 or idx >= hotbar.size():
			continue
		var have: String = str(hotbar[idx].get("card_id", ""))
		if int(items_by_id.get(have, {}).get("bucket", 0)) == _guarantee_bucket:
			_guarantee_bucket = 0
			return
	var id: String = _pull_bucket(item_pool, items_by_id, _guarantee_bucket)
	_guarantee_bucket = 0
	if id == "":
		return
	if gifted.is_empty():
		hotbar.append(_make_item(id))
		return
	var at: int = gifted[gifted.size() - 1]
	var old_id: String = str(hotbar[at].get("card_id", ""))
	if old_id != "":
		item_pool.append(old_id)
	hotbar[at] = _make_item(id)
	_log("on_place", "item  %s" % items_by_id.get(id, {}).get("name", id))


func _fill_pools() -> void:
	monster_pool.clear()
	item_pool.clear()
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty() or not _bucket_open(card):
			continue
		if not ModePool.allows(card, ModePool.ADVENTURE):
			continue
		for _c in range(maxi(0, int(card.get("count", 1)))):
			monster_pool.append(str(id))
	for id in runtime.get("items", []):
		var card2: Dictionary = items_by_id.get(str(id), {})
		if card2.is_empty() or not _bucket_open(card2):
			continue
		if not ModePool.allows(card2, ModePool.ADVENTURE):
			continue
		if BucketRules.is_always_starter_id(str(id)):
			continue
		for _c2 in range(maxi(0, int(card2.get("count", 1)))):
			item_pool.append(str(id))


func _empty_wheel(n: int = 8) -> void:
	wheel.clear()
	var count: int = n
	if count <= 0:
		count = 8
	for i in count:
		var slot: String = SLOT_ORDER[i] if i < SLOT_ORDER.size() else str(i)
		wheel.append({"kind": "empty", "slot": slot})
	challenge_aim = -1
	if wheel_view:
		wheel_view.rot = 0.0
		wheel_view.facing_index = -1
		wheel_view.selected_index = -1


func _hand_limit() -> int:
	return CHALLENGE_HAND if adventure else HAND_MAX


func _hand_full() -> bool:
	return hotbar.size() >= _hand_limit()


func _challenge_item_banned(id: String) -> bool:
	return not ModePool.allows(items_by_id.get(id, {}), ModePool.CHALLENGE)


func _challenge_monster_banned(id: String) -> bool:
	return not ModePool.allows(monsters_by_id.get(id, {}), ModePool.CHALLENGE)


func _fill_challenge_pools() -> void:
	monster_pool.clear()
	item_pool.clear()
	for id in runtime.get("monsters", []):
		var mid: String = str(id)
		if _challenge_monster_banned(mid):
			continue
		var card: Dictionary = monsters_by_id.get(mid, {})
		if card.is_empty() or not _bucket_open(card):
			continue
		for _c in range(maxi(0, int(card.get("count", 1)))):
			monster_pool.append(mid)
	_challenge_reshuffle_items()


func _challenge_held_counts() -> Dictionary:
	var counts: Dictionary = {}
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var iid: String = str(it.get("card_id", ""))
		if iid == "":
			continue
		counts[iid] = int(counts.get(iid, 0)) + 1
	return counts


func _challenge_reshuffle_items() -> void:
	item_pool.clear()
	var held: Dictionary = _challenge_held_counts()
	for id in runtime.get("items", []):
		var iid: String = str(id)
		if _challenge_item_banned(iid):
			continue
		var card2: Dictionary = items_by_id.get(iid, {})
		if card2.is_empty() or not _bucket_open(card2):
			continue
		if BucketRules.is_always_starter_id(iid):
			continue
		var want: int = maxi(0, int(card2.get("count", 1)) - int(held.get(iid, 0)))
		for _c2 in range(want):
			item_pool.append(iid)


func _challenge_roll_tier() -> int:
	var r: float = rng.randf()
	if r < 0.50:
		return 1
	if r < 0.85:
		return 2
	return 3


func _challenge_dungeon_ids() -> Dictionary:
	var have := {}
	for s in wheel:
		if typeof(s) != TYPE_DICTIONARY:
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		var sid: String = str(s.get("card_id", ""))
		if sid != "":
			have[sid] = true
	for id in challenge_deck:
		var did: String = str(id)
		if did != "":
			have[did] = true
	return have


func _challenge_monster_conflicts(id: String) -> bool:
	var card: Dictionary = monsters_by_id.get(id, {})
	var cons: Variant = card.get("contradiction_ids", [])
	var mine: Array = cons if typeof(cons) == TYPE_ARRAY else []
	var have: Dictionary = _challenge_dungeon_ids()
	if mine.has(id) and have.has(id):
		return true
	for sid in have.keys():
		var other_id: String = str(sid)
		if mine.has(other_id):
			return true
		var other: Dictionary = monsters_by_id.get(other_id, {})
		var ocons: Variant = other.get("contradiction_ids", [])
		var theirs: Array = ocons if typeof(ocons) == TYPE_ARRAY else []
		if theirs.has(id):
			return true
	return false


func _challenge_take_monster_filtered(tier: int) -> String:
	var matches: Array = []
	for mid in monster_pool:
		var iid: String = str(mid)
		var card: Dictionary = monsters_by_id.get(iid, {})
		if card.is_empty():
			continue
		if tier > 0 and int(card.get("tier", 0)) != tier:
			continue
		if _challenge_monster_conflicts(iid):
			continue
		matches.append(iid)
	if matches.is_empty():
		return ""
	var pick: String = str(matches[rng.randi_range(0, matches.size() - 1)])
	monster_pool.erase(pick)
	return pick


func _challenge_take_monster() -> String:
	var t: int = _challenge_roll_tier()
	var id: String = _challenge_take_monster_filtered(t)
	if id == "":
		id = _challenge_take_monster_filtered(0)
	if id == "":
		id = _take_card(monster_pool, monsters_by_id, "", 0)
	return id


func _challenge_take_item(tier: int, exclude_id: String) -> String:
	var matches: Array = []
	for id in item_pool:
		var iid: String = str(id)
		if exclude_id != "" and iid == exclude_id:
			continue
		var card: Dictionary = items_by_id.get(iid, {})
		if card.is_empty():
			continue
		if tier > 0 and int(card.get("tier", 0)) != tier:
			continue
		matches.append(iid)
	if matches.is_empty():
		return ""
	var pick: String = str(matches[rng.randi_range(0, matches.size() - 1)])
	item_pool.erase(pick)
	return pick


func _challenge_draw_pair(tier: int) -> Array:
	var a: String = _challenge_take_item(tier, "")
	if a == "":
		_challenge_reshuffle_items()
		a = _challenge_take_item(tier, "")
	var b: String = _challenge_take_item(tier, a)
	if b == "":
		_challenge_reshuffle_items()
		b = _challenge_take_item(tier, a)
	if a == "" and b == "":
		_challenge_reshuffle_items()
		_log("on_draft", "no tier %s items in the unlocked pool, offering any tier" % tier)
		a = _challenge_take_item(0, "")
		b = _challenge_take_item(0, a)
	var out: Array = []
	if a != "":
		var ia: Dictionary = _make_item(a)
		_stamp_pack(ia, _pack_tier_for(a, items_by_id, 1), "draft")
		out.append(ia)
	if b != "":
		var ib: Dictionary = _make_item(b)
		_stamp_pack(ib, _pack_tier_for(b, items_by_id, 1), "draft")
		out.append(ib)
	return out


func _challenge_draft_card(it: Dictionary) -> Control:
	var card: Control = _spawn_item_card(it, false)
	if card.has_method("set_draft_glow"):
		card.set_draft_glow(true)
	if card.has_method("set_steal_cursor") and art != null:
		card.set_steal_cursor(art.ui.get("cursor_hand", null))
	_dress_showcase_card(card, it, false)
	return card


func _run_challenge_setup() -> void:
	var seq: int = _mill_seq
	draft_action = "busy"
	phase = "draft"
	_refresh()
	await _challenge_seat_dungeon(dungeon_index > 1)
	if seq != _mill_seq:
		return
	await _challenge_run_opening_drafts()


func _challenge_seat_dungeon(upgrade: bool) -> void:
	var seq: int = _mill_seq
	_empty_wheel(CHALLENGE_SEATS)
	challenge_deck.clear()
	challenge_draft_plan.clear()
	challenge_pick_i = 0
	if dungeon_deck_ui:
		dungeon_deck_ui.visible = true
		dungeon_deck_ui.set_count(0)
	_layout_play_field()
	for i in CHALLENGE_SEATS:
		if seq != _mill_seq:
			return
		var mid: String = _challenge_take_monster()
		if mid == "":
			break
		_seat_opener(i, mid, "starter")
		var seated: Dictionary = wheel[i]
		challenge_draft_plan.append({
			"tier": _tier_of(seated),
			"name": str(seated.get("name", "?")),
			"id": str(seated.get("card_id", "")),
		})
		if i < adventure_seat_tiers.size():
			adventure_seat_tiers[i] = _tier_of(seated)
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(i)
		if sfx:
			sfx.play_event(&"chal.seat_dungeon", {"pitch_mul": 1.0 + float(i) * 0.03})
		await get_tree().create_timer(0.12).timeout
	for _d in CHALLENGE_DECK_N:
		if seq != _mill_seq:
			return
		var did: String = _challenge_take_monster()
		if did == "":
			break
		challenge_deck.append(did)
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(challenge_deck.size())
		if sfx:
			sfx.play("cloth", -10.0)
			sfx.play("whoosh", -14.0, 1.2)
		await dungeon_deck_ui.play_shuffle()
	if upgrade and seq == _mill_seq:
		await _upgrade_two_openers()
	_refresh()
	_layout_play_field()


func _challenge_auto_opening_loot() -> void:
	for i in challenge_draft_plan.size():
		if hotbar.size() >= CHALLENGE_HAND:
			break
		var row: Dictionary = challenge_draft_plan[i]
		var t: int = int(row.get("tier", 1))
		var pair: Array = _challenge_draw_pair(t)
		if pair.is_empty():
			_challenge_reshuffle_items()
			pair = _challenge_draw_pair(t)
		if pair.is_empty():
			continue
		var pick: Dictionary = pair[rng.randi_range(0, pair.size() - 1)]
		hotbar.append(pick.duplicate(true))
		_log("on_draft", "gain %s" % pick.get("name", "?"))
	_sort_hotbar()


func _challenge_run_opening_drafts() -> void:
	var seq: int = _mill_seq
	draft_action = "challenge_pick"
	phase = "draft"
	for i in challenge_draft_plan.size():
		if seq != _mill_seq:
			return
		if hotbar.size() >= CHALLENGE_HAND:
			break
		challenge_pick_i = i
		var row: Dictionary = challenge_draft_plan[i]
		var t: int = int(row.get("tier", 1))
		var who: String = str(row.get("name", "Monster"))
		await _challenge_offer_pick(
			PLAYER_COPY.text("challenge.pick_open", "Choose your loot"),
			"%s  ·  Tier %s" % [who, t],
			t,
			true
		)
	if seq != _mill_seq:
		return
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	draft_action = "challenge_begin"
	phase = "draft"
	_sort_hotbar()
	_refresh()
	_layout_play_field()


func _challenge_begin_play() -> void:
	if not adventure:
		return
	if draft_action != "challenge_begin":
		return
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	draft_action = ""
	phase = "ready"
	challenge_aim = -1
	if wheel_view:
		wheel_view.selected_index = -1
	_sort_hotbar()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("confirm", -10.0)
		sfx.play("door_open", -12.0)
	_refresh()
	_layout_play_field()


func _challenge_offer_pick(title: String, sub: String, tier: int, replace_if_full: bool) -> void:
	if not replace_if_full and hotbar.size() >= CHALLENGE_HAND:
		return
	var pair: Array = _challenge_draw_pair(tier)
	if pair.is_empty():
		_challenge_reshuffle_items()
		pair = _challenge_draw_pair(tier)
	if pair.is_empty():
		return
	_challenge_pair = pair
	if challenge_draft_ui == null:
		return
	var a: Control = _challenge_draft_card(pair[0])
	var b: Control = Control.new()
	var ib: Dictionary = pair[0]
	if pair.size() > 1:
		b = _challenge_draft_card(pair[1])
		ib = pair[1]
	else:
		b.custom_minimum_size = Vector2(236, 340)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenge_draft_ui.present(title, sub, a, b, pair[0], ib)
	var seq: int = _mill_seq
	if is_inside_tree():
		await get_tree().process_frame
	if seq != _mill_seq:
		return
	_layout_play_field()
	_refresh()
	if sfx:
		sfx.play("book", -10.0)
		sfx.play("open", -14.0)
	var uid: int = await challenge_draft_ui.chosen
	var pair_snap: Array = _challenge_pair.duplicate()
	_challenge_pair.clear()
	challenge_draft_ui.hide_draft()
	_layout_play_field()
	var picked: Dictionary = {}
	for it in pair_snap:
		if int(it.get("uid", 0)) == uid:
			picked = it
			break
	if picked.is_empty() and not pair_snap.is_empty():
		picked = pair_snap[0]
	await _challenge_commit_item(picked, replace_if_full)


func _challenge_commit_item(it: Dictionary, replace_if_full: bool) -> void:
	if it.is_empty():
		return
	var uid: int = int(it.get("uid", 0))
	for held in hotbar:
		if int(held.get("uid", 0)) == uid:
			return
	if hotbar.size() < CHALLENGE_HAND:
		hotbar.append(it.duplicate(true))
		_sort_hotbar()
		_log("on_draft", "gain %s" % it.get("name", "?"))
		if sfx:
			sfx.play("confirm", -12.0)
			sfx.play("cloth", -14.0)
			sfx.play_event(&"chal.commit")
		_refresh()
		return
	if not replace_if_full:
		return
	_challenge_pending_gain = it.duplicate(true)
	_challenge_loot_wait = true
	_flash_banner(PLAYER_COPY.text("challenge.full_hand", "Hand is full. Click an item to throw away."))
	_refresh()
	while _challenge_loot_wait and is_instance_valid(self):
		await get_tree().process_frame


func _challenge_discard_one(uid: int) -> void:
	if not _challenge_loot_wait:
		return
	var have: Dictionary = _find_item(uid)
	if have.is_empty():
		return
	_toss_item(uid, false, true)
	if not _challenge_pending_gain.is_empty():
		hotbar.append(_challenge_pending_gain.duplicate(true))
		_sort_hotbar()
		_log("on_draft", "gain %s" % _challenge_pending_gain.get("name", "?"))
	_challenge_pending_gain = {}
	_challenge_loot_wait = false
	if sfx:
		sfx.play_event(&"chal.discard")
	_refresh()


func _challenge_vacate(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return
	if wheel_view != null and wheel_view.slay_index == index:
		wheel_view.clear_slay()
	var slot: String = str(m.get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else str(index)))
	wheel[index] = {
		"kind": "empty",
		"slot": slot,
		"challenge_hole": true,
		"loot_tier": _tier_of(m),
		"loot_name": str(m.get("name", "?")),
		"loot_id": str(m.get("card_id", "")),
		"mimic_gift": str(m.get("card_id", "")) == "mimic" and not enemy_attacked,
	}
	_log("on_remove_slice", str(m.get("name", "?")))
	mobs_defeated += 1


func _challenge_holes_clockwise(from: int) -> Array[int]:
	var out: Array[int] = []
	var n: int = wheel.size()
	if n <= 0:
		return out
	var start: int = from if from >= 0 else 0
	start = clampi(start, 0, n - 1)
	for off in n:
		var i: int = (start + off) % n
		if bool(wheel[i].get("challenge_hole", false)):
			out.append(i)
	return out


func _challenge_resolve_holes(from: int) -> void:
	var start: int = from
	while true:
		if wheel.is_empty():
			return
		var holes: Array[int] = _challenge_holes_clockwise(start)
		if holes.is_empty():
			return
		var i: int = holes[0]
		var hole: Dictionary = wheel[i]
		if bool(hole.get("mimic_gift", false)):
			_draw_unseen_item()
			_log("on_remove_slice", "Mimic gift")
		var collapsing: bool = challenge_deck.is_empty()
		await _challenge_refill_or_collapse(i)
		if collapsing:
			if wheel.is_empty():
				return
			start = mini(i, wheel.size() - 1)
			continue
		if i < 0 or i >= wheel.size():
			return
		var arriver: Dictionary = wheel[i]
		if str(arriver.get("kind", "")) != "monster":
			start = (i + 1) % maxi(1, wheel.size())
			continue
		var t: int = _tier_of(arriver)
		var who: String = str(arriver.get("name", "Monster"))
		_flash_banner(PLAYER_COPY.fill("challenge.loot", {"name": who}, "Loot from %s" % who))
		if sfx:
			sfx.play("open", -8.0)
			sfx.play("bong", -14.0, 1.1)
		await _challenge_offer_pick(
			PLAYER_COPY.text("challenge.pick_loot", "Loot"),
			"%s  ·  Tier %s" % [who, t],
			t,
			true
		)
		start = (i + 1) % maxi(1, wheel.size())


func _challenge_refill_or_collapse(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if not challenge_deck.is_empty():
		if dungeon_deck_ui:
			await dungeon_deck_ui.play_draw()
		var nid: String = str(challenge_deck.pop_front())
		if dungeon_deck_ui and not dungeon_deck_ui.is_busy():
			dungeon_deck_ui.set_count(challenge_deck.size())
		if wheel_view:
			await wheel_view.rotate_index_to_top(index, 0.42)
		if ability_slash:
			var tex: Texture2D = null
			if art != null:
				tex = art.monster_still(nid)
			await ability_slash.play({
				"title": _title_case(str(monsters_by_id.get(nid, {}).get("name", nid))),
				"call": MONSTER_LINES.call_of(nid, monsters_by_id.get(nid, {})),
				"tex": tex,
				"is_item": false,
				"card_id": nid,
			})
		_seat_opener(index, nid, "draft")
		if wheel_view:
			if wheel_view.slay_index == index:
				wheel_view.clear_slay()
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(index)
		if sfx:
			sfx.play("drop", -8.0)
			sfx.play("whoosh", -12.0, 0.9)
		_refresh()
		return
	if wheel_view:
		await wheel_view.collapse_slice(index)
	wheel.remove_at(index)
	if challenge_aim == index:
		challenge_aim = -1
	elif challenge_aim > index:
		challenge_aim -= 1
	_reseat_slots()
	_sync_wheel_stats()
	_refresh()


func _challenge_after_fight() -> void:
	var start: int = facing_index
	if facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("kind", "")) == "monster":
		await _wick_on_defeated(facing_index)
		_challenge_vacate(facing_index)
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) > 0 and not bool(s.get("crossbowed", false)):
			continue
		await _wick_on_defeated(i)
		if wheel_view:
			await wheel_view.play_slay(i)
		_challenge_vacate(i)
	facing_index = -1
	if wheel_view:
		wheel_view.selected_index = -1
		wheel_view.facing_index = -1
	_discard_spent_items()
	blk = 0
	_log("var", "BLK 0")
	_log("var", "defeated %s" % mobs_defeated)
	await _challenge_resolve_holes(start)
	_sync_wheel_stats()
	phase = "ready"
	if _monsters_left() == 0:
		_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	_walker_busy = false
	if in_tutorial:
		call_deferred("_tutorial_after_fight")


func _challenge_flee_cleanup() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if bool(wheel[i].get("challenge_hole", false)):
			if wheel_view:
				await wheel_view.collapse_slice(i, facing_index if facing_index >= 0 else -1)
			wheel.remove_at(i)
			if facing_index > i:
				facing_index -= 1
			_reseat_slots()
		i -= 1
	_sync_wheel_stats()
	_refresh()


func _pick_tier() -> int:
	var r: float = rng.randf()
	if r < 0.4:
		return 1
	if r < 0.75:
		return 2
	return 3


func _take_id(pool: Array, by_id: Dictionary, _rarity: String, tier: int) -> String:
	var matches: Array = []
	for id in pool:
		var card: Dictionary = by_id.get(str(id), {})
		if card.is_empty():
			continue
		if tier > 0 and int(card.get("tier", 0)) != tier:
			continue
		matches.append(str(id))
	if matches.is_empty():
		return ""
	var pick: String = str(matches[rng.randi_range(0, matches.size() - 1)])
	pool.erase(pick)
	return pick


func _take_card(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	var id: String = _take_id(pool, by_id, rarity, tier)
	if id == "":
		id = _take_id(pool, by_id, rarity, 0)
	if id == "":
		id = _take_id(pool, by_id, "", 0)
	return id


func _pack_tier_for(id: String, by_id: Dictionary, fallback: int) -> int:
	var t: int = int(by_id.get(id, {}).get("tier", 0))
	if t < 1:
		return fallback
	return t


func _stamp_pack(d: Dictionary, tier: int, kind: String) -> void:
	var t: int = tier
	if t < 1:
		t = int(d.get("pack_tier", 0))
	if t < 1:
		t = 1
	d["pack_tier"] = t
	d["pack_kind"] = kind


func _rank_label(d: Dictionary) -> String:
	var t: int = int(d.get("pack_tier", 0))
	if t < 1:
		t = int(d.get("tier", 0))
	if t >= 1:
		return PLAYER_COPY.tier_name(t)
	return ""


func _tier_of(d: Dictionary) -> int:
	var t: int = int(d.get("pack_tier", 0))
	if t < 1:
		t = int(d.get("tier", 0))
	return maxi(1, t)


func _tier_metal(tier: int) -> Color:
	if tier >= 3:
		return Color("e8c36a")
	if tier == 2:
		return Color("c5cdd8")
	return Color("c08050")


func _utility_fill(ops_kind: String, family: String) -> Color:
	if ops_kind == "atk_neighbor" or ops_kind == "atk_opposite":
		return FILL_YELLOW
	if ops_kind == "hook_swap":
		return FILL_YELLOW
	if ops_kind == "heal_kills" or ops_kind == "heal_keep" or ops_kind == "heal_full":
		return Color("243a22")
	if ops_kind == "chaos_reroll":
		return Color("3a1460")
	match family:
		"BLK":
			return Color("1c3d52")
		"DEFEAT", "FANGS":
			return Color("3a2450")
		"PASSIVE":
			return Color("243a22")
		"SMOKE", "SKIP":
			return Color("3a2a38")
		"MARK":
			if ops_kind == "mark_poison":
				return Color("1e3324")
			return Color("4a3d14")
		_:
			return Color("5c2626")


func _item_look(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var tier: int = _tier_of(it)
	return {
		"fill": view.get("fill", Color("5c2626")),
		"metal": _tier_metal(tier),
		"tier": tier,
	}


func _monster_look(s: Dictionary) -> Dictionary:
	var tier: int = _tier_of(s)
	var fill := Color("2a1610")
	if tier == 2:
		fill = Color("1a0c14")
	elif tier >= 3:
		fill = Color("100308")
	return {
		"fill": fill,
		"metal": _tier_metal(tier),
		"tier": tier,
		"scary": true,
	}


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


func _next_starter_item() -> String:
	if starter_items_left <= 0:
		return ""
	starter_items_left -= 1
	return _take_card(item_pool, items_by_id, "", 0)


func _draw_offer(kind: String) -> void:
	pending_monster.clear()
	pending_item.clear()
	if kind == "starter":
		var mid: String = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			_log("on_draft", "pool empty — enter")
			phase = "ready"
			_sort_hotbar()
			return
		pending_monster = _make_monster(mid)
		_stamp_pack(pending_monster, _pack_tier_for(mid, monsters_by_id, 1), "starter")
		if starter_items_left > 0:
			var iid: String = _next_starter_item()
			if iid != "":
				pending_item = _make_item(iid)
				_stamp_pack(pending_item, _pack_tier_for(iid, items_by_id, int(pending_monster.get("pack_tier", 1))), "starter")
		_log("on_draft", "Tier %s  %s" % [int(pending_monster.get("pack_tier", 1)), pending_monster.get("name", "?")])
		if not pending_item.is_empty():
			_log("on_draft", "pack item  %s" % pending_item.get("name", "?"))
		if sfx:
			sfx.play("book", -10.0)
		return
	var rolled: int = _pick_tier()
	var mid2: String = _take_card(monster_pool, monsters_by_id, "", rolled)
	if mid2 == "":
		_log("on_draft", "pool empty")
		return
	var pack_t: int = _pack_tier_for(mid2, monsters_by_id, rolled)
	pending_monster = _make_monster(mid2)
	_stamp_pack(pending_monster, pack_t, "draft")
	var iid2: String = _take_card(item_pool, items_by_id, "", pack_t)
	if iid2 != "":
		pending_item = _make_item(iid2)
		_stamp_pack(pending_item, pack_t, "draft")
	_log("on_draft", "Tier %s lure" % pack_t)
	if not pending_item.is_empty():
		_log("on_draft", "relic  %s" % pending_item.get("name", "?"))
	if sfx:
		sfx.play("book", -10.0)


func _offer_tex() -> Texture2D:
	if pending_item.is_empty():
		return tex_sword
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex(str(pending_item.get("card_id", "")))
	if tex == null:
		tex = tex_by_item.get(str(pending_item.get("card_id", "")), tex_sword)
	return tex


func _present_gate(passes: int) -> void:
	if draft_gate == null:
		return
	_offer_card = null
	draft_gate.present_mystery(pending_item, _pack_tier_now(), _offer_tex(), passes)
	if not pending_item.is_empty():
		var card: Control = _spawn_item_card(pending_item, false)
		card.picked.connect(func() -> void:
			if draft_action == "ask":
				_on_gate_send()
		)
		if card.has_method("set_draft_glow"):
			card.set_draft_glow(phase == "draft")
		if card.has_method("set_steal_cursor") and art != null:
			card.set_steal_cursor(art.ui.get("cursor_hand", null))
		if card.has_method("set_showcase"):
			card.set_showcase(true)
		if card.has_signal("passed_swipe"):
			card.passed_swipe.connect(func() -> void:
				if draft_action == "ask":
					_on_gate_refuse()
			)
		draft_gate.mount_relic(card)
		_offer_card = card
		_refresh_offer_card()
	if wheel_view:
		draft_gate.dock(wheel_view)


func _reveal_gate() -> void:
	if draft_gate == null:
		return
	var mrule: Dictionary = _monster_rule(pending_monster) if not pending_monster.is_empty() else {}
	draft_gate.reveal(pending_monster, str(mrule.get("value", "")), str(mrule.get("speech", "")), str(mrule.get("reminder", "")))


func _pack_tier_now() -> int:
	if not pending_monster.is_empty():
		return _tier_of(pending_monster)
	if not pending_item.is_empty():
		return _tier_of(pending_item)
	return 1


func _first_empty() -> int:
	for i in wheel.size():
		if str(wheel[i].get("kind", "")) == "empty":
			return i
	return -1


func _run_mill() -> void:
	var seq: int = _mill_seq
	_mill_beat = "watch"
	_refresh()
	await _seat_night_watch()
	if seq != _mill_seq:
		return
	_grant_starter_kit()
	_refresh()
	await get_tree().create_timer(0.4).timeout
	if seq != _mill_seq:
		return
	_open_petitioner()


func _seat_night_watch(upgrade: bool = true) -> void:
	var seq: int = _mill_seq
	for i in range(CARDINAL_SLOTS.size()):
		if seq != _mill_seq:
			return
		var si: int = int(CARDINAL_SLOTS[i])
		var mid: String = ""
		if adventure and dungeon_index > 1:
			mid = _take_monster_of_tier(int(adventure_seat_tiers[i]))
		else:
			mid = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			break
		_seat_opener(si, mid, "starter")
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play_event(&"draft.seat_starter", {"pitch_mul": 1.0 + float(si) * 0.02})
		await get_tree().create_timer(0.22).timeout
	starters_left = 0
	if upgrade and adventure and dungeon_index > 1 and seq == _mill_seq:
		await _upgrade_two_openers()
	if seq == _mill_seq:
		_force_guarantee_monster()


func _seat_opener(si: int, mid: String, pack_kind: String) -> void:
	var m: Dictionary = _make_monster(mid)
	m["slot"] = SLOT_ORDER[si]
	m["spin_locked"] = false
	_stamp_pack(m, _pack_tier_for(mid, monsters_by_id, int(monsters_by_id.get(mid, {}).get("tier", 1))), pack_kind)
	wheel[si] = m
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	_sync_wheel_stats()


func _take_monster_of_tier(tier: int) -> String:
	var t: int = maxi(1, mini(3, tier))
	var id: String = _take_id(monster_pool, monsters_by_id, "", t)
	if id == "":
		id = _take_card(monster_pool, monsters_by_id, "", t)
	return id


func _upgrade_two_openers() -> void:
	if overlay:
		overlay.visible = false
	var seq: int = _mill_seq
	var can: Array = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if _tier_of(wheel[i]) >= 3:
			continue
		can.append(i)
	if can.is_empty():
		return
	for n in range(can.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, n)
		var tmp: Variant = can[n]
		can[n] = can[j]
		can[j] = tmp
	var picks: Array = []
	for k in range(mini(2, can.size())):
		picks.append(int(can[k]))
	_upgraded_slices = []
	for pick in picks:
		_upgraded_slices.append(int(pick))
	if speech_box and wheel_view and not picks.is_empty():
		var talk_si: int = int(picks[0])
		speech_box.present(
			wheel_view.slice_portrait_global(talk_si),
			PLAYER_COPY.text("adventure.scarier", "The dungeon is getting more dangerous.")
		)
	_flash_screen(Color("3a1460"), 0.42)
	if sfx:
		sfx.play("whoosh", -8.0, 0.86)
		sfx.play("bong", -12.0, 0.7)
	await get_tree().create_timer(0.28).timeout
	if seq != _mill_seq:
		return
	for i in picks:
		if seq != _mill_seq:
			return
		var si: int = int(i)
		if si < 0 or si >= wheel.size():
			continue
		var next_t: int = _tier_of(wheel[si]) + 1
		var nid: String = _take_monster_of_tier(next_t)
		if nid == "":
			continue
		var old: Dictionary = wheel[si]
		var old_id: String = str(old.get("card_id", ""))
		if old_id != "":
			monster_pool.append(old_id)
		if si < adventure_seat_tiers.size():
			adventure_seat_tiers[si] = next_t
		_seat_opener(si, nid, "starter")
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play("drop", -8.0, 0.8)
		await get_tree().create_timer(0.32).timeout
	if speech_box:
		await get_tree().create_timer(0.7).timeout
		if seq == _mill_seq:
			speech_box.hide_speech()


func _grant_starter_kit() -> void:
	var gifted: Array[int] = []
	while starter_items_left > 0:
		var iid: String = _next_starter_item()
		if iid == "":
			break
		hotbar.append(_make_item(iid))
		gifted.append(hotbar.size() - 1)
		var iname: String = str(items_by_id.get(iid, {}).get("name", iid))
		_log("on_place", "item  %s" % iname)
	_force_guarantee_item(gifted)
	_ensure_starter_smoke(gifted)
	_sort_hotbar()
	if sfx:
		sfx.play("cloth", -10.0)
		sfx.play("confirm", -14.0)


func _open_petitioner() -> void:
	if _empty_count() <= 0:
		_finish_mill()
		return
	_draw_offer("draft")
	if pending_monster.is_empty():
		_finish_mill()
		return
	draft_action = "ask"
	phase = "draft"
	_mill_beat = "gate"
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	_present_gate(refusals_left)
	if sfx:
		sfx.play("creak", -12.0)
		sfx.play("question", -10.0)
	_refresh()
	_idle_inspect()


func _finish_mill() -> void:
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	if draft_gate:
		draft_gate.hide_gate()
	_offer_card = null
	if speech_box:
		speech_box.hide_speech()
	pending_monster = {}
	pending_item = {}
	phase = "ready"
	draft_action = "place"
	_sort_hotbar()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_close", -10.0)
		sfx.play("confirm_big", -12.0)
		sfx.play_event(&"draft.take")
	_undo_arm()
	_refresh()
	_idle_inspect()


func _on_gate_send() -> void:
	if draft_action != "ask" or pending_monster.is_empty():
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	_refresh()
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("grab")
	if sfx:
		sfx.play("metal_latch", -6.0)
		sfx.play("door_slam", -4.0, 0.92)
		sfx.play("whoosh", -12.0, 1.08)
	_flash_screen(Color("e8c36a"), 0.22)
	if _offer_card != null and is_instance_valid(_offer_card) and _offer_card.has_method("set_draft_glow"):
		_offer_card.set_draft_glow(false)
	if draft_gate:
		await draft_gate.play_slam(false)
	if seq != _mill_seq:
		return
	if sfx:
		sfx.play("door_open", -8.0, 1.05)
		sfx.play("bong", -10.0, 0.9)
	_reveal_gate()
	_refresh_gate_owner()
	_gate_line = ""
	_cube_line = ""
	_log("on_draft", "revealed  %s" % pending_monster.get("name", "?"))
	await get_tree().create_timer(0.7).timeout
	if seq != _mill_seq:
		return
	draft_action = "seat"
	if draft_gate:
		draft_gate.set_seat()
	_refresh_gate_owner()
	_refresh()
	_idle_inspect()


func _on_gate_refuse() -> void:
	if draft_action != "ask":
		return
	if refusals_left <= 0:
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	refusals_left -= 1
	_refresh()
	if sfx:
		sfx.play("scratch", -10.0)
		sfx.play("switch", -14.0, 0.85)
	_log("on_bribe", "pass  %s" % pending_item.get("name", "relic"))
	if not pending_item.is_empty():
		_log("discard", str(pending_item.get("name", "?")))
	if draft_gate:
		await draft_gate.play_pass()
	if seq != _mill_seq:
		return
	pending_monster = {}
	pending_item = {}
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	if refusals_left <= 0:
		await _auto_fill_rest()
	else:
		_open_petitioner()


func _auto_fill_rest() -> void:
	var seq: int = _mill_seq
	_mill_beat = "force"
	draft_action = "busy"
	_refresh()
	if sfx:
		sfx.play("creak", -10.0, 0.8)
	while _empty_count() > 0:
		if seq != _mill_seq:
			return
		_draw_offer("draft")
		if pending_monster.is_empty():
			break
		var idx: int = _first_empty()
		if idx < 0:
			break
		_present_gate(0)
		if sfx:
			sfx.play("door_slam", -8.0, 1.12)
			sfx.play("metal_latch", -12.0)
		if draft_gate:
			await draft_gate.play_slam(true)
			_reveal_gate()
		if sfx:
			sfx.play("door_open", -12.0, 1.2)
		await get_tree().create_timer(0.12).timeout
		if seq != _mill_seq:
			return
		var from: Vector2 = draft_gate.actor_global() if draft_gate else Vector2.ZERO
		var tex: Texture2D = draft_gate.still_tex() if draft_gate else null
		if draft_gate:
			draft_gate.hide_actor()
		var dest: Vector2 = from
		if wheel_view:
			dest = wheel_view.slice_portrait_global(idx)
		await _fly_courier(tex, from, dest, 0.22)
		if seq != _mill_seq:
			return
		_commit_place(idx, false)
	_finish_mill()


func _fly_courier(tex: Texture2D, from: Vector2, to: Vector2, dur: float = 0.4) -> void:
	if _courier == null or tex == null:
		await get_tree().create_timer(0.08).timeout
		return
	_clear_courier_gear()
	_courier.texture = tex
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2.ONE
	_courier.modulate.a = 1.0
	_courier.global_position = from - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("whoosh", -10.0, 1.1)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(_courier, "global_position", to - _courier.pivot_offset, dur)
	tw.parallel().tween_property(_courier, "scale", Vector2(0.42, 0.42), dur)
	await tw.finished
	_courier.visible = false
	_courier.scale = Vector2.ONE


func _seat_petitioner(index: int) -> void:
	if pending_monster.is_empty():
		return
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "empty":
		if sfx:
			sfx.play("error", -14.0)
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	_refresh()
	var from: Vector2 = get_global_mouse_position()
	var tex: Texture2D = null
	if draft_gate:
		from = draft_gate.actor_global()
		tex = draft_gate.still_tex()
		draft_gate.hide_actor()
	_gate_line = ""
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	var dest: Vector2 = from
	if wheel_view:
		dest = wheel_view.slice_portrait_global(index)
	await _fly_courier(tex, from, dest)
	if seq != _mill_seq:
		return
	_commit_place(index)


func _make_monster(id: String) -> Dictionary:
	var card: Dictionary = monsters_by_id[id]
	var spec: Dictionary = MONSTER_SPECIAL.get(id, {})
	var s := {
		"kind": "monster",
		"slot": "",
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"special_id": str(spec.get("id", "")),
		"special_text": str(spec.get("text", card.get("ability", ""))),
		"call_name": MONSTER_LINES.call_of(id, card),
		"reminder": MONSTER_LINES.reminder_of(id, card),
		"log_hint": str(card.get("log_hint", "")),
		"atk": _card_base_atk(id),
		"hp": _card_base_hp(id),
		"hp_max": _card_base_hp(id),
		"spin_locked": false,
		"poisoned": false,
		"crossbowed": false,
		"rarity": str(card.get("rarity", "starter")),
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"atk_variable": false,
		"hp_variable": false,
		"swing_muted": false,
		"fled_once": false,
		"rage_step": 0,
		"rage_fire": false,
		"silenced": false,
		"wick_bonus": 0,
		"egg_atk": 0,
		"aura_hp": 0,
		"aura_atk": 0,
		"atk_mod": 0,
		"atk_zeroed": false,
	}
	uid_seq += 1
	s["seat_uid"] = uid_seq
	_apply_formulas_to(s)
	if home_cabin and not in_tutorial:
		home_cabin.note_met(id)
	return s


func _make_item(id: String) -> Dictionary:
	var card: Dictionary = items_by_id[id]
	uid_seq += 1
	var ops: Dictionary = {}
	if card.has("ops") and typeof(card["ops"]) == TYPE_DICTIONARY:
		ops = (card["ops"] as Dictionary).duplicate(true)
	elif ITEM_OPS.has(id):
		ops = (ITEM_OPS[id] as Dictionary).duplicate(true)
	if home_cabin:
		home_cabin.note_seen(id)
	return {
		"uid": uid_seq,
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ops": ops,
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"log_hint": str(card.get("log_hint", "")),
		"card_color": str(card.get("card_color", "")),
		"spent": false,
		"keep_after": false,
		"siphon_blk": 0,
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"petrified": false,
		"echo_copy": last_item_copy.duplicate(true) if id == "echo_bell" and not last_item_copy.is_empty() else {},
		"alt_n": 2 if str(ops.get("kind", "")) == "atk_alt_24" else 0,
		"magnet_mode": "off",
		"magnet_seq": 0,
	}


func _card_base_atk(id: String) -> int:
	var card: Dictionary = monsters_by_id.get(id, {})
	var a: Variant = card.get("atk", {})
	if typeof(a) == TYPE_DICTIONARY and (a as Dictionary).has("base"):
		return int((a as Dictionary)["base"])
	return 0


func _card_base_hp(id: String) -> int:
	var card: Dictionary = monsters_by_id.get(id, {})
	var h: Variant = card.get("hp", {})
	if typeof(h) == TYPE_DICTIONARY and (h as Dictionary).has("base"):
		return int((h as Dictionary)["base"])
	return 6


func _monster_stat_formula(id: String, which: String) -> String:
	var card: Dictionary = monsters_by_id.get(id, {})
	var blob: Variant = card.get(which, {})
	if typeof(blob) != TYPE_DICTIONARY:
		return ""
	return str((blob as Dictionary).get("formula", "")).strip_edges()


func _try_eval_stat_formula(formula: String, s: Dictionary) -> Variant:
	var raw: String = formula.strip_edges()
	if raw == "":
		return null
	var f: String = raw.to_lower().replace("_", " ").replace("-", " ")
	while f.contains("  "):
		f = f.replace("  ", " ")
	match f:
		"owners left", "monsters left", "monster count":
			return _monsters_left()
		"monsters still in play", "1 + monsters still in play", "1 + owners left":
			return 1 + _monsters_left()
		"player hp on spin", "player hp", "your hp", "your hp on spin":
			return hp
		"last mob hp", "last enemy hp":
			return last_mob_hp
		"num items at combat start", "num items", "items held", "item count":
			return _live_item_count()
		"own hp", "my hp":
			return int(s.get("hp", 0))
		"1 + mobs defeated", "1+mobs defeated":
			return 1 + mobs_defeated
		"2 + mobs defeated", "2+mobs defeated":
			return 2 + mobs_defeated
		"leftmost attack item, else 3", "leftmost attack item else 3", "base atk (0) + leftmost item with an atk value":
			return _leftmost_atk_n()
		"alternates between 3, 4, and 8 atk on spin":
			return [3, 4, 8][int(s.get("rage_step", 0)) % 3]
		"printed attack, plus item uses on the wheel":
			return _card_base_atk(str(s.get("card_id", ""))) + int(s.get("wick_bonus", 0))
		_:
			if f.is_valid_int():
				return int(f)
			push_warning("Unknown %s formula '%s' — using the printed roster number." % [s.get("card_id", "?"), raw])
			return null


func _peel_auras(s: Dictionary) -> void:
	var ah: int = int(s.get("aura_hp", 0))
	var aa: int = int(s.get("aura_atk", 0))
	if ah != 0:
		s["hp"] = maxi(0, int(s.get("hp", 0)) - ah)
		s["hp_max"] = maxi(int(s.get("hp_max", int(s.get("hp", 0)))) - ah, int(s["hp"]))
	if aa != 0:
		s["atk"] = maxi(0, int(s.get("atk", 0)) - aa)
	s["aura_hp"] = 0
	s["aura_atk"] = 0


func _apply_formulas_to(s: Dictionary) -> void:
	_peel_auras(s)
	var id: String = str(s.get("card_id", ""))
	if _is_silenced(s):
		# Quiet Bell freezes Vampire at the HP and Attack it already gained.
		# Queen eggs already eaten stay on the number.
		if id != "vampire":
			if not bool(s.get("atk_locked", false)):
				s["atk"] = _card_base_atk(id) + int(s.get("egg_atk", 0))
			if not bool(s.get("hp_locked", false)):
				s["hp"] = _card_base_hp(id)
				s["hp_max"] = int(s["hp"])
		s["ability"] = ""
		s["explainer"] = ""
		s["special_id"] = ""
		s["special_text"] = ""
		s["call_name"] = ""
		s["reminder"] = ""
		s["log_hint"] = ""
		return
	var hold_hp: int = int(s.get("hp", 0))
	var hold_max: int = int(s.get("hp_max", hold_hp))
	var hold_atk: int = int(s.get("atk", 0))
	var hp_locked: bool = bool(s.get("hp_locked", false))
	var atk_locked: bool = bool(s.get("atk_locked", false))
	s["atk"] = _card_base_atk(id)
	s["hp"] = _card_base_hp(id)
	var hp_f: Variant = _try_eval_stat_formula(_monster_stat_formula(id, "hp"), s)
	if hp_f != null:
		s["hp"] = int(hp_f)
	s["hp_max"] = int(s["hp"])
	var atk_f: Variant = _try_eval_stat_formula(_monster_stat_formula(id, "atk"), s)
	if atk_f != null:
		s["atk"] = int(atk_f)
	s["atk"] = int(s.get("atk", 0)) + int(s.get("egg_atk", 0))
	var card: Dictionary = monsters_by_id.get(id, {})
	s["call_name"] = MONSTER_LINES.call_of(id, card)
	s["reminder"] = MONSTER_LINES.reminder_of(id, card)
	s["log_hint"] = str(card.get("log_hint", ""))
	if hp_locked:
		s["hp"] = hold_hp
		if id == "vampire":
			s["hp_max"] = maxi(hold_max, hold_hp)
		if id == "slime_boss":
			s["atk"] = hold_hp
	elif int(s.get("leech_bonus", 0)) > 0:
		var bonus: int = int(s["leech_bonus"])
		var missing: int = maxi(0, hold_max - hold_hp)
		s["hp_max"] = int(s["hp_max"]) + bonus
		s["hp"] = maxi(0, int(s["hp_max"]) - missing)
	if id == "vampire":
		s["atk"] = _card_base_atk(id) + int(s.get("bloodlust", 0))
	elif atk_locked and id != "slime_boss":
		s["atk"] = hold_atk


func _atk_is_always(who) -> bool:
	if typeof(who) == TYPE_DICTIONARY:
		var s: Dictionary = who
		if _is_silenced(s):
			return false
		var sid: String = str(s.get("card_id", ""))
		return sid == "slime_boss" or sid == "dire_wolf"
	if _is_silenced(who):
		return false
	var id: String = str(who)
	return id == "slime_boss" or id == "dire_wolf"


func _refresh_live_atk(s: Dictionary) -> void:
	var id: String = str(s.get("card_id", ""))
	match id:
		"beggar":
			s["atk"] = _leftmost_atk_n()
		"bandit":
			s["atk"] = _live_item_count()
		"vampire":
			s["atk"] = _card_base_atk(id) + int(s.get("bloodlust", 0))
		"spider_queen":
			s["atk"] = _card_base_atk(id) + int(s.get("egg_atk", 0))
		"dire_wolf":
			s["atk"] = hp
		"slime_boss":
			s["atk"] = int(s.get("hp", 0))
		_:
			pass


func _apply_always_atk() -> void:
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if _is_silenced(wheel[i]):
			wheel[i]["atk_innate"] = int(wheel[i].get("atk", 0))
			continue
		var id: String = str(wheel[i].get("card_id", ""))
		if id == "slime_boss":
			wheel[i]["atk"] = int(wheel[i].get("hp", 0))
		elif id == "dire_wolf":
			wheel[i]["atk"] = hp
		wheel[i]["atk_innate"] = int(wheel[i].get("atk", 0))


func _apply_atk_mods() -> void:
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if _atk_is_always(s):
			continue
		if not bool(s.get("spin_locked", false)):
			continue
		if bool(s.get("atk_zeroed", false)):
			s["atk"] = 0
			wheel[i] = s
			continue
		var mod: int = int(s.get("atk_mod", 0))
		if mod != 0:
			s["atk"] = maxi(0, int(s.get("atk", 0)) + mod)
			wheel[i] = s


func _sync_wheel_stats() -> void:
	var n: int = wheel.size()
	for i in n:
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if not bool(s.get("spin_locked", false)):
			s["atk_mod"] = 0
			s["atk_zeroed"] = false
		if bool(s.get("spin_locked", false)):
			if _is_silenced(s):
				_apply_formulas_to(s)
				wheel[i] = s
			else:
				if s.has("atk_innate"):
					s["atk"] = int(s.get("atk_innate", s.get("atk", 0)))
				_peel_auras(s)
				_refresh_live_atk(s)
				wheel[i] = s
			continue
		_apply_formulas_to(s)
		wheel[i] = s
	_apply_wraith_pass()
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if bool(wheel[i].get("spin_locked", false)):
			continue
		wheel[i]["atk_before_late"] = int(wheel[i].get("atk", 0))
		wheel[i]["hp_before_late"] = int(wheel[i].get("hp", 0))
	_paint_late_auras()
	_apply_always_atk()
	_apply_atk_mods()
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		wheel[i]["silenced"] = _is_silenced(wheel[i])
		if str(wheel[i].get("card_id", "")) == "berserker":
			wheel[i]["rage_fire"] = (not bool(wheel[i]["silenced"])) and (int(wheel[i].get("rage_step", 0)) % 3) == 2
	_mark_vars()


func _paint_late_auras() -> void:
	var n: int = wheel.size()
	var hp_bonus: Array[int] = []
	var atk_bonus: Array[int] = []
	hp_bonus.resize(n)
	atk_bonus.resize(n)
	hp_bonus.fill(0)
	atk_bonus.fill(0)
	for i in n:
		var id: String = str(wheel[i].get("card_id", ""))
		if id != "lich" and id != "commander":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		var left_i: int = (i - 1 + n) % n
		var right_i: int = (i + 1) % n
		for j in [left_i, right_i]:
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			if id == "lich":
				hp_bonus[j] += 1
			else:
				atk_bonus[j] += 2
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var old_h: int = int(wheel[i].get("aura_hp", 0))
		var old_a: int = int(wheel[i].get("aura_atk", 0))
		var new_h: int = hp_bonus[i]
		var new_a: int = atk_bonus[i]
		if old_h != new_h:
			wheel[i]["hp"] = maxi(0, int(wheel[i].get("hp", 0)) - old_h + new_h)
			wheel[i]["hp_max"] = maxi(int(wheel[i].get("hp_max", 0)) - old_h + new_h, int(wheel[i]["hp"]))
			wheel[i]["aura_hp"] = new_h
		if old_a != new_a:
			if _atk_is_always(wheel[i]):
				wheel[i]["aura_atk"] = 0
			else:
				wheel[i]["atk"] = maxi(0, int(wheel[i].get("atk", 0)) - old_a + new_a)
				wheel[i]["aura_atk"] = new_a
		elif _atk_is_always(wheel[i]) and old_a != 0:
			wheel[i]["atk"] = maxi(0, int(wheel[i].get("atk", 0)) - old_a)
			wheel[i]["aura_atk"] = 0


func _apply_wraith_pass() -> void:
	var n: int = wheel.size()
	for i in n:
		if str(wheel[i].get("card_id", "")) != "wraith":
			continue
		if _is_silenced(wheel[i]):
			continue
		if bool(wheel[i].get("spin_locked", false)):
			continue
		var best: int = int(wheel[i].get("atk", 0))
		var src: int = -1
		for off in [n - 1, 1]:
			var j: int = (i + off) % n
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			var their: int = int(wheel[j].get("atk", 0))
			if bool(wheel[j].get("spin_locked", false)) and wheel[j].has("atk_before_late"):
				their = int(wheel[j]["atk_before_late"])
			if their > best:
				best = their
				src = j
		wheel[i]["atk"] = best
		wheel[i]["copy_from"] = src


func _mark_vars() -> void:
	var n: int = wheel.size()
	var lich_touch: Dictionary = {}
	var cmd_touch: Dictionary = {}
	for i in n:
		var cid: String = str(wheel[i].get("card_id", ""))
		if cid == "lich":
			lich_touch[(i - 1 + n) % n] = true
			lich_touch[(i + 1) % n] = true
		elif cid == "commander":
			cmd_touch[(i - 1 + n) % n] = true
			cmd_touch[(i + 1) % n] = true
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var id: String = str(wheel[i].get("card_id", ""))
		wheel[i]["atk_variable"] = id == "dire_wolf" or id == "bandit" or id == "berserker" or id == "slime_boss" or id == "wraith" or id == "beggar" or id == "vampire" or cmd_touch.has(i)
		wheel[i]["hp_variable"] = id == "ogre" or id == "skeleton" or id == "leech_league" or id == "wick" or lich_touch.has(i)
		wheel[i]["cmd_buff"] = cmd_touch.has(i)
		wheel[i]["lich_buff"] = lich_touch.has(i)
		if id != "wraith":
			wheel[i]["copy_from"] = -1


func _on_place_mode() -> void:
	if phase != "draft" and phase != "starter":
		return
	draft_action = "place"
	if sfx:
		sfx.play("switch", -12.0)
	_refresh()


func _on_bribe_mode() -> void:
	if phase != "draft":
		return
	draft_action = "bribe"
	if sfx:
		sfx.play("switch", -12.0, 0.92)
	_refresh()


func _process(delta: float) -> void:
	_anim_t += delta
	if _unlock_screen:
		_hide_board_for_unlock()
		return
	if _cabin_up():
		if fly_tip != null and fly_tip.visible:
			if _fly_card != null and is_instance_valid(_fly_card) and home_cabin.is_ancestor_of(_fly_card):
				_place_fly(_fly_card)
			else:
				_hide_fight_hover()
		return
	_place_fight_art()
	var sh: bool = Input.is_key_pressed(KEY_SHIFT)
	if sh != _shift_held:
		_shift_held = sh
		_sync_hotbar_formulas()
		_refresh_monster_plates()
		_refresh_gate_owner()
		if wheel_view:
			wheel_view.show_shift = _shift_held
			wheel_view.queue_redraw()
		if in_tutorial:
			_tutorial_try_shift_inspect()
	_place_speech()
	if draft_gate != null and draft_gate.visible and wheel_view != null:
		draft_gate.dock(wheel_view)
	if in_tutorial:
		_tut_refresh_focus()
	if btn_spin != null and btn_spin.visible and not btn_spin.disabled:
		var pulse: float = 0.88 + 0.12 * absf(sin(_anim_t * 5.0))
		btn_spin.modulate = Color(1.0, pulse, pulse * 0.85, 1.0)
		btn_spin.pivot_offset = btn_spin.size * 0.5
	elif btn_spin != null:
		btn_spin.modulate = Color.WHITE


func _unhandled_input(event: InputEvent) -> void:
	if phase == "devtest" and event.is_action_pressed("ui_accept"):
		_dev_enter()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		if roster_ed != null and roster_ed.visible:
			return
		if script_ed != null and script_ed.visible:
			return
		_open_roster()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		if roster_ed != null and roster_ed.visible:
			return
		if script_ed != null and script_ed.visible:
			return
		_open_script()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		if text_audit:
			text_audit.toggle()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		if roster_ed != null and roster_ed.visible:
			return
		if script_ed != null and script_ed.visible:
			return
		if content_ed != null and content_ed.visible:
			return
		_play_latest()
		get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if sack_peek != null and sack_peek.visible:
		sack_peek.close()
		get_viewport().set_input_as_handled()
		return
	if settings_ui == null or settings_ui.visible:
		return
	if _cabin_up():
		return
	if content_ed != null and content_ed.visible:
		return
	if roster_ed != null and roster_ed.visible:
		return
	if script_ed != null and script_ed.visible:
		return
	var in_run: bool = phase != "title"
	settings_ui.open_menu(in_run)
	if sfx:
		sfx.play("open", -12.0)
	get_viewport().set_input_as_handled()


func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_pause_mode(mode: String) -> void:
	match mode:
		"tutorial":
			_start_tutorial()
		"dive":
			_quick_start()
		"begin":
			_begin_run()
		"adventure":
			_begin_adventure()
		"dev":
			_open_dev_test()
		"latest":
			_play_latest()
		"roster":
			_open_roster()
		"script":
			_open_script()


func _open_roster() -> void:
	if not _authoring() or in_tutorial or roster_ed == null:
		return
	if fly_tip:
		fly_tip.hide_plate()
	if speech_box:
		speech_box.hide_speech()
	roster_ed.open_roster()


func _open_script() -> void:
	if not _authoring() or in_tutorial or script_ed == null:
		return
	if fly_tip:
		fly_tip.hide_plate()
	if speech_box:
		speech_box.hide_speech()
	script_ed.open_script()


func _on_script_saved(items: Array, monsters: Array) -> void:
	PLAYER_COPY.reload()
	if _copy_stamp:
		_copy_stamp.set_plain(PLAYER_COPY.stamp())
	if settings_ui:
		settings_ui.apply_copy()
	_apply_overlay_copy()
	if not items.is_empty() or not monsters.is_empty():
		_on_roster_committed(items, monsters)
		_log("on_click", "Script saved")
		return
	_refresh()
	_log("on_click", "Script saved")


func _apply_overlay_copy() -> void:
	if overlay_tut:
		overlay_tut.text = PLAYER_COPY.text("title.how_to_play", "How to Play")
	if overlay_dive:
		overlay_dive.text = PLAYER_COPY.text("title.dive_in", "Dive In")
	if overlay_adventure:
		overlay_adventure.text = PLAYER_COPY.text("title.adventure", "Challenge Mode")
	if overlay_home:
		overlay_home.text = PLAYER_COPY.text("title.home", "Home")
	if overlay_continue:
		overlay_continue.text = PLAYER_COPY.text("title.continue", "Continue")
	if overlay_leave:
		overlay_leave.text = PLAYER_COPY.text("title.leave", "Leave")
	if btn_spin:
		btn_spin.text = PLAYER_COPY.text("combat.spin", "Spin")
	_sync_overlay()


func _open_content_editor(kind: String, card_id: String) -> void:
	if not _authoring() or in_tutorial or card_id == "" or content_ed == null:
		return
	if fly_tip:
		fly_tip.hide_plate()
	var cat: Dictionary = {}
	if kind == "monster":
		cat = monsters_by_id.get(card_id, {})
	else:
		cat = items_by_id.get(card_id, {})
	content_ed.open_card(kind, card_id, cat)
	content_ed.move_to_front()
	if sfx:
		sfx.play("book", -10.0)


func _on_content_saved(kind: String, card_id: String, board_card: Dictionary) -> void:
	_merge_catalog_card(kind, board_card)
	_write_catalog()
	_apply_live_card(kind, card_id, board_card)
	_log("on_click", "Saved %s" % board_card.get("name", card_id))
	_refresh()
	_refresh_offer_card()
	if bucket_ed and bucket_ed.visible:
		bucket_ed.reload_board_keep_pending()


func _merge_catalog_card(kind: String, board_card: Dictionary) -> void:
	var id: String = str(board_card.get("id", ""))
	var arr: Array = catalog.get("monsters" if kind == "monster" else "items", [])
	var dst: Dictionary = {}
	for i in arr.size():
		if str(arr[i].get("id", "")) == id:
			dst = arr[i]
			break
	if dst.is_empty():
		dst = _new_catalog_stub(kind, id)
		arr.append(dst)
		catalog["monsters" if kind == "monster" else "items"] = arr
	dst["name"] = _title_case(str(board_card.get("name", id)))
	dst["rarity"] = str(board_card.get("rarity", "starter"))
	dst["bucket"] = _as_int(board_card.get("bucket", 0), 0)
	dst["mode_pool"] = ModePool.parse(board_card.get("mode_pool", "all"))
	dst["tier"] = _as_int(board_card.get("tier", 1), 1)
	dst["count"] = _as_int(board_card.get("count", 1), 1)
	dst["priority"] = _as_int(board_card.get("priority", 3), 3)
	dst["ability"] = str(board_card.get("ability", ""))
	dst["explainer"] = str(board_card.get("explainer", ""))
	dst["call_name"] = str(board_card.get("call_name", ""))
	dst["reminder"] = str(board_card.get("reminder", ""))
	dst["log_hint"] = str(board_card.get("log_hint", ""))
	dst["defined"] = str(board_card.get("flow", ""))
	dst["exceptions"] = str(board_card.get("notes", ""))
	dst["status"] = str(board_card.get("status", dst.get("status", "live")))
	dst["author_lock"] = bool(board_card.get("author_lock", false))
	dst["locked_fields"] = board_card.get("locked_fields", [])
	dst["locked_at"] = str(board_card.get("locked_at", ""))
	dst["review"] = REVIEW_STAGE.of_card(board_card)
	dst["review_note"] = str(board_card.get("review_note", ""))
	if kind == "monster":
		var atk: Dictionary = dst.get("atk", {})
		if typeof(atk) != TYPE_DICTIONARY:
			atk = {}
		if board_card.get("atk_base") != null and str(board_card.get("atk_base", "")).strip_edges() != "":
			atk["base"] = _as_int(board_card.get("atk_base"), 0)
		var af: String = str(board_card.get("atk_formula", ""))
		if af != "":
			atk["formula"] = af
		else:
			atk.erase("formula")
		dst["atk"] = atk
		var hp: Dictionary = dst.get("hp", {})
		if typeof(hp) != TYPE_DICTIONARY:
			hp = {}
		if board_card.get("hp_base") != null and str(board_card.get("hp_base", "")).strip_edges() != "":
			hp["base"] = _as_int(board_card.get("hp_base"), 0)
		var hf: String = str(board_card.get("hp_formula", ""))
		if hf != "":
			hp["formula"] = hf
		else:
			hp.erase("formula")
		dst["hp"] = hp
	else:
		if typeof(board_card.get("ops", null)) == TYPE_DICTIONARY:
			dst["ops"] = (board_card["ops"] as Dictionary).duplicate(true)
	if kind == "monster":
		monsters_by_id[id] = dst
	else:
		items_by_id[id] = dst


func _new_catalog_stub(kind: String, id: String) -> Dictionary:
	if kind == "monster":
		return {
			"id": id,
			"name": id,
			"type": "M",
			"ability": "",
			"explainer": "",
			"log_hint": "",
			"defined": "",
			"exceptions": "",
			"rarity": "uncommon",
			"tier": 1,
			"count": 1,
			"priority": 3,
			"atk": {"base": 2},
			"hp": {"base": 6},
			"flags": {"art": false, "dev": false, "hide": false},
			"poc": false,
			"review": "rough",
			"review_note": "",
			"mode_pool": "all",
		}
	return {
		"id": id,
		"name": id,
		"type": "I",
		"ability": "",
		"explainer": "",
		"log_hint": "",
		"defined": "",
		"exceptions": "",
		"ops": {"kind": "atk", "n": 1},
		"rarity": "uncommon",
		"tier": 1,
		"count": 1,
		"priority": 3,
		"flags": {"art": false, "dev": false, "hide": false},
		"poc": false,
		"review": "rough",
		"review_note": "",
		"mode_pool": "all",
	}


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


func _on_roster_committed(items: Array, monsters: Array) -> void:
	for it in items:
		_merge_catalog_card("item", it)
	for m in monsters:
		_merge_catalog_card("monster", m)
	_write_catalog()
	for it2 in items:
		_apply_live_card("item", str(it2.get("id", "")), it2)
	for m2 in monsters:
		_apply_live_card("monster", str(m2.get("id", "")), m2)
	_log("on_click", "Roster saved")
	_refresh()
	_refresh_offer_card()


func _refresh_offer_card() -> void:
	if _offer_card == null or not is_instance_valid(_offer_card):
		_offer_card = null
		return
	if pending_item.is_empty():
		return
	_dress_showcase_card(_offer_card, pending_item, true)


func _dress_showcase_card(card: Control, it: Dictionary, can_pass: bool) -> void:
	if card == null or not is_instance_valid(card) or it.is_empty():
		return
	var view: Dictionary = _item_view(it)
	var rule: Dictionary = _item_rule(it)
	if card.has_method("set_title"):
		card.set_title(_title_case(str(it.get("name", "?"))))
	if card.has_method("set_rank"):
		card.set_rank("Tier %s" % _tier_of(it))
	if card.has_method("set_palette"):
		card.set_palette(view["fill"], view["rim"], _tier_of(it))
	if card.has_method("set_live"):
		card.set_live(str(view["number"]), str(view.get("note", "")), true)
	if card.has_method("set_showcase"):
		card.set_showcase(true)
	if card.has_method("set_pass_swipe"):
		card.set_pass_swipe(can_pass)
	if card.has_method("set_ability_bb"):
		var ab: String = str(it.get("ability", "")).strip_edges()
		card.set_ability_bb(_paint_explainer(ab) if ab != "" else "")
	if card.has_method("set_formula"):
		card.set_formula(str(rule.get("equation", "")))
		card.show_formula(_shift_held)


func _write_catalog() -> bool:
	var path: String = ProjectSettings.globalize_path(CATALOG_PATH)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		f = FileAccess.open(CATALOG_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Could not write catalog")
		return false
	f.store_string(JSON.stringify(catalog, "\t"))
	return true


func _apply_live_card(kind: String, card_id: String, board_card: Dictionary) -> void:
	if kind == "monster":
		for i in wheel.size():
			if str(wheel[i].get("card_id", "")) != card_id:
				continue
			_stamp_live_monster(wheel[i], board_card)
		if str(pending_monster.get("card_id", "")) == card_id:
			_stamp_live_monster(pending_monster, board_card)
	else:
		var ops: Dictionary = {}
		if typeof(board_card.get("ops", null)) == TYPE_DICTIONARY:
			ops = (board_card["ops"] as Dictionary).duplicate(true)
		for it in hotbar:
			if str(it.get("card_id", "")) != card_id:
				continue
			_stamp_live_item(it, board_card, ops)
		if str(pending_item.get("card_id", "")) == card_id:
			_stamp_live_item(pending_item, board_card, ops)
		_hotbar_sig = ""
	_sync_wheel_stats()


func _stamp_live_monster(s: Dictionary, board_card: Dictionary) -> void:
	s["name"] = _title_case(str(board_card.get("name", s.get("name", ""))))
	s["ability"] = str(board_card.get("ability", ""))
	s["explainer"] = str(board_card.get("explainer", ""))
	s["call_name"] = str(board_card.get("call_name", s.get("call_name", "")))
	s["reminder"] = str(board_card.get("reminder", s.get("reminder", "")))
	s["log_hint"] = str(board_card.get("log_hint", s.get("log_hint", "")))
	s["special_text"] = str(board_card.get("ability", s.get("special_text", "")))
	s["rarity"] = str(board_card.get("rarity", s.get("rarity", "")))
	s["pack_tier"] = int(board_card.get("tier", s.get("pack_tier", 1)))
	var locked: bool = bool(s.get("spin_locked", false))
	s["spin_locked"] = false
	_apply_formulas_to(s)
	s["spin_locked"] = locked


func _stamp_live_item(it: Dictionary, board_card: Dictionary, ops: Dictionary) -> void:
	it["name"] = _title_case(str(board_card.get("name", it.get("name", ""))))
	it["ability"] = str(board_card.get("ability", ""))
	it["explainer"] = str(board_card.get("explainer", ""))
	it["log_hint"] = str(board_card.get("log_hint", it.get("log_hint", "")))
	it["pack_tier"] = int(board_card.get("tier", it.get("pack_tier", 1)))
	it["pack_kind"] = "starter" if str(board_card.get("rarity", "")) == "starter" else "draft"
	if not ops.is_empty():
		it["ops"] = ops.duplicate(true)


func _on_slice_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if _wheel_busy():
		return
	if not pending_mark.is_empty() and phase == "fighting":
		await _apply_mark(index)
		return
	if phase == "devtest":
		_dev_click_slice(index)
		return
	if phase == "draft" and draft_action == "seat":
		_seat_petitioner(index)
		return
	if adventure and phase == "ready" and facing_index < 0:
		if str(wheel[index].get("kind", "")) != "monster":
			return
		if int(wheel[index].get("hp", 0)) <= 0:
			return
		challenge_aim = index
		if wheel_view:
			wheel_view.selected_index = index
		if sfx:
			sfx.play("select", -10.0)
		_refresh()


func _on_slice_right_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		return
	_open_content_editor("monster", str(s.get("card_id", "")))


func _on_slice_hovered(index: int) -> void:
	if _cabin_up():
		return
	if _fly_card != null:
		return
	if _deck_hovering:
		return
	if fly_tip != null and fly_tip.edit_kind == "monster":
		fly_tip.hide_plate()
	if index < 0 or index >= wheel.size():
		_hover_slice = -1
		if _deck_hovering:
			return
		_idle_inspect()
		_apply_preview({})
		return
	if index != _hover_slice and sfx and phase != "spinning":
		sfx.hover()
	_hover_slice = index
	_fill_inspect_from_slice(index)
	if not pending_mark.is_empty() and phase == "fighting":
		_apply_preview(_preview_bribe(index))
	_tutorial_on_slice_hover(index)


func _can_place() -> bool:
	return phase == "draft" and draft_action == "seat" and not pending_monster.is_empty()


func _commit_place(index: int, open_next: bool = true) -> void:
	if pending_monster.is_empty():
		return
	if str(wheel[index].get("kind", "")) != "empty":
		return
	var m: Dictionary = pending_monster.duplicate(true)
	m["slot"] = str(wheel[index].get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else ""))
	m["spin_locked"] = false
	wheel[index] = m
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	if sfx:
		sfx.play("drop", -8.0)
		sfx.play("confirm", -14.0, 1.08)
	if not pending_item.is_empty():
		hotbar.append(pending_item.duplicate(true))
		_log("on_place", "item  %s" % pending_item.get("name", "?"))
	pending_monster = {}
	pending_item = {}
	if draft_gate:
		draft_gate.hide_gate()
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.pulse_arrive(index)
	if not open_next:
		return
	if _empty_count() <= 0:
		_finish_mill()
	else:
		_open_petitioner()


func _place_on(index: int) -> void:
	_commit_place(index)


func _bribe_at(index: int) -> void:
	if str(wheel[index].get("kind", "")) != "monster":
		return
	var name: String = str(wheel[index].get("name", "?"))
	_log("on_bribe", "cut  %s" % name)
	if sfx:
		sfx.play("scratch", -8.0)
		sfx.play("creak", -12.0)
		sfx.play_event(&"wheel.bribe")
	if not pending_item.is_empty():
		_log("discard", str(pending_item.get("name", "?")))
	if not pending_monster.is_empty():
		_log("on_bribe", "skip  %s" % pending_monster.get("name", "?"))
	wheel.remove_at(index)
	_reseat_slots()
	pending_monster = {}
	pending_item = {}
	_sync_wheel_stats()
	drafts_left -= 1
	if drafts_left > 0:
		_draw_offer("draft")
	else:
		phase = "ready"
		_sort_hotbar()
		_log("on_draft", "enter")
	if _monsters_left() == 0 and phase == "ready":
		_enter_dungeon_clear()
	_refresh()


func _reseat_slots() -> void:
	for i in range(wheel.size()):
		if i < SLOT_ORDER.size():
			wheel[i]["slot"] = SLOT_ORDER[i]
		else:
			wheel[i]["slot"] = str(i)


func _on_spin() -> void:
	_trace_resolve("spin start phase=%s" % phase)
	if phase != "ready":
		return
	if in_tutorial and (tut == null or (tut.wait != "spin" and tut.wait != "auto_spin")):
		return
	if facing_index >= 0:
		return
	for i in range(wheel.size()):
		if typeof(wheel[i]) == TYPE_DICTIONARY:
			wheel[i]["spin_locked"] = false
	_sync_wheel_stats()
	var live: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "monster" and int(wheel[i].get("hp", 0)) > 0:
			live.append(i)
	if live.is_empty():
		_enter_dungeon_clear()
		_refresh()
		return
	var pool: Array[int] = live.duplicate()
	if _reroll_skip >= 0 and pool.size() > 1:
		var filtered: Array[int] = []
		for i in pool:
			if i != _reroll_skip:
				filtered.append(i)
		if not filtered.is_empty():
			pool = filtered
		_reroll_skip = -1
	var idx: int = pool[rng.randi_range(0, pool.size() - 1)]
	_magnet_pending_consume = ""
	var tut_forced: int = -1
	if in_tutorial:
		tut_forced = _tutorial_spin_index()
		if tut_forced >= 0:
			idx = tut_forced
	if tut_forced < 0 and adventure:
		if _challenge_force_spin:
			_challenge_force_spin = false
		elif challenge_aim >= 0 and pool.find(challenge_aim) >= 0:
			idx = challenge_aim
		else:
			if sfx:
				sfx.play("error", -12.0)
			_flash_banner(PLAYER_COPY.text("challenge.click_target", "Click who you fight, then Spin."))
			return
	var mag_mode: String = _armed_magnet_mode()
	var flee_rand: bool = _flee_random_spin
	_flee_random_spin = false
	if tut_forced < 0 and not adventure and mag_mode != "" and not flee_rand:
		idx = _magnet_pick(pool, mag_mode == "high")
		_magnet_pending_consume = mag_mode
	challenge_aim = -1
	if wheel_view:
		wheel_view.selected_index = -1
	_undo_wall()
	phase = "spinning"
	pending_choice.clear()
	_refresh()
	_log("on_click", "Spin")
	if sfx:
		sfx.set_combat_music(true)
		sfx.play("door_open", -10.0)
		sfx.play("whoosh", -12.0, 0.9)
	await wheel_view.spin_to(idx)
	if phase != "spinning":
		return
	if sfx:
		var land_m: Dictionary = wheel[idx] if idx >= 0 and idx < wheel.size() else {}
		var land_t: int = _tier_of(land_m) if not land_m.is_empty() else 1
		var land_ctx := {"tier": land_t, "monster_id": str(land_m.get("card_id", ""))}
		if land_t >= 3:
			land_ctx["pitch_mul"] = sfx.deadly_pitch(str(land_m.get("card_id", "")))
		sfx.play_event(sfx.resolve(&"enter", land_ctx), land_ctx)
	facing_index = idx
	if _magnet_pending_consume != "":
		_consume_armed_magnets(_magnet_pending_consume)
		_magnet_pending_consume = ""
	_discard_spent_items()
	blk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	pending_feed = {}
	_cube_line = ""
	_cleric_line = ""
	_cleric_talk_index = -1
	_clear_petrify()
	num_items_at_combat = hotbar.size()
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	_sync_wheel_stats()
	var m: Dictionary = wheel[facing_index]
	m["spin_locked"] = true
	wheel[facing_index] = m
	keep_blocked_this_fight = str(m.get("card_id", "")) == "basilisk" and not _is_silenced(m)
	last_mob_hp = int(m.get("hp", 3))
	last_mob_atk = int(m.get("atk", 0))
	phase = "fighting"
	_walker_busy = true
	_sync_buttons()
	_log_user_hid = false
	_log_user_show = false
	_sync_log_panel()
	_log("on_spin", str(m["name"]))
	_log("var", "enemy ATK %s   HP %s" % [m["atk"], m["hp"]])
	_log("var", "BLK 0")
	_log("var", "items this combat 0")
	if combat_stage:
		combat_stage.show_monster(str(m.get("card_id", "")), int(m.get("tier", 1)))
		_tune_combat_stage()
	_refresh()
	_bleed_begin()
	if await _apply_siphon_jars():
		await _bleed_end()
		_store_last_faced_hp()
		_undo_arm()
		_unlock_if_fighting()
		return
	if await _apply_cursed_scrolls():
		await _bleed_end()
		_store_last_faced_hp()
		_undo_arm()
		_unlock_if_fighting()
		return
	if str(m.get("card_id", "")) == "gargoyle":
		await _petrify_best_atk()
	if bool(m.get("poisoned", false)):
		if await _chip_hp(facing_index, 5):
			_store_last_faced_hp()
			_undo_arm()
			_unlock_if_fighting()
			return
		m = wheel[facing_index]
		_log("on_spin", "poison  →  %s HP" % m["hp"])
		if int(m["hp"]) <= 0 and not _wick_waiting(facing_index):
			_store_last_faced_hp()
			_refresh()
			await _begin_slay()
			_undo_arm()
			return
	_refresh()
	_step_berserkers()
	_sync_wheel_stats()
	await _apply_queen_eggs_on_spin()
	if phase == "fighting":
		await _apply_juggernaut_on_spin()
	m = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else m
	if str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
		await _harpy_poke()
	await _bleed_end()
	if phase == "fighting":
		await _apply_leech_on_spin()
	if phase == "fighting":
		await _cleric_after_spin()
	if phase == "fighting" and facing_index >= 0 and facing_index < wheel.size():
		var face_id: String = str(wheel[facing_index].get("card_id", ""))
		if face_id == "gelatinous_cube":
			_cube_ask_feed()
			_refresh()
		elif face_id == "merchant":
			_merchant_ask()
	_store_last_faced_hp()
	_undo_arm()
	_unlock_if_fighting()
	if in_tutorial and phase == "fighting":
		call_deferred("_tutorial_combat_started")


func _trace_resolve(msg: String) -> void:
	if OS.has_feature("editor"):
		print("[resolve] ", msg)


func _unlock_if_fighting() -> void:
	if phase == "fighting":
		_walker_busy = false
		_sync_buttons()


func _on_done() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _wheel_busy():
		return
	if in_tutorial and (tut == null or (tut.wait != "done" and tut.wait != "choice")):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_wait", "Not yet — finish what I said."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if not pending_chaos.is_empty() or not pending_mark.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	_walker_busy = true
	_sync_buttons()
	_undo_wall()
	_trace_resolve("done face=%s hp=%s skip=%s" % [
		str(wheel[facing_index].get("card_id", "")),
		str(wheel[facing_index].get("hp", 0)),
		skip_swing_this_fight,
	])
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		await _begin_slay()
		return
	if skip_swing_this_fight:
		_log("on_click", "Done")
		if sfx:
			sfx.play("click", -8.0)
		await _resolve_then_continue(true)
		return
	_log("on_click", "Done")
	if sfx:
		sfx.play("click", -8.0)
	await _resolve_then_continue(false)


func _begin_slay(_killed: bool = true) -> void:
	if await _try_commander_flee(facing_index):
		return
	await _exit_ended(false)


func _exit_ended(clockwork_split: bool = false) -> void:
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_ended_visuals()
	await _clear_after_fight(clockwork_split)
	await _maybe_auto_spin()


func _exit_leave(clockwork_split: bool = true) -> void:
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_leave_visuals()
	await _clear_after_fight(clockwork_split)
	await _maybe_auto_spin()


func _play_ended_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		var dead: Dictionary = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else {}
		var dctx := {"tier": _tier_of(dead) if not dead.is_empty() else 1, "monster_id": str(dead.get("card_id", ""))}
		sfx.play_event(sfx.resolve(&"death", dctx), dctx)
	if combat_stage:
		combat_stage.take_hit()
	if wheel_view and facing_index >= 0:
		await wheel_view.play_slay(facing_index)
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0 and not adventure:
		await wheel_view.collapse_slice(facing_index)


func _play_leave_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0 and not adventure:
		await wheel_view.collapse_slice(facing_index)


func _resolve_then_continue(skip_attack: bool) -> void:
	if phase != "fighting":
		return
	_trace_resolve("continue skip=%s" % skip_attack)
	if skip_attack or (facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0):
		if await _try_commander_flee(facing_index):
			return
		if skip_attack:
			await _exit_leave(true)
		else:
			await _exit_ended(false)
		return
	var face_id: String = str(wheel[facing_index].get("card_id", "")) if facing_index >= 0 else ""
	if face_id == "two_headed_serpent" and not _is_silenced(wheel[facing_index]):
		await _damsel_resolve()
		return
	phase = "slaying"
	_refresh()
	_bleed_begin()
	_trace_resolve("hits begin")
	var _taken: int = await _apply_resolve_hits()
	_trace_resolve("hits done taken=%s hp=%s" % [_taken, hp])
	await _bleed_end()
	enemy_attacked = true
	if hp <= 0:
		_player_down()
		return
	if await _try_commander_flee(facing_index):
		return
	_trace_resolve("leave visuals")
	await _play_leave_visuals()
	_trace_resolve("clear after fight")
	await _clear_after_fight(true)
	_trace_resolve("after clear, auto-spin")
	await _maybe_auto_spin()


func _apply_resolve_hits() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	var hits: int = _hit_count(facing_index)
	var total: int = 0
	for h in range(hits):
		if hp <= 0:
			break
		if h > 0:
			await _announce_slice(facing_index, _hub_hp_pos())
		var incoming: int = await _owner_attack(m, h + 1, hits)
		if facing_index >= 0 and facing_index < wheel.size():
			m = wheel[facing_index]
		total += incoming
		if hp <= 0:
			break
		if hits > 1 and h < hits - 1:
			if sfx:
				sfx.play_event(&"mon.hornet_buzz")
			await get_tree().create_timer(0.16).timeout
	return total


## Owner Attacks you. Always lunges. Blocked vs unblocked only changes the tell.
## Returns HP lost on this swing.
func _owner_attack(m: Dictionary, hit_n: int = 1, _hit_total: int = 1) -> int:
	enemy_attacked = true
	_trace_resolve("swing %s n=%s" % [str(m.get("card_id", "")), hit_n])
	if combat_stage:
		if sfx:
			sfx.play_event(&"mon.lunge", {"monster_id": str(m.get("card_id", "")), "tier": _tier_of(m)})
		await combat_stage.lunge()
		_trace_resolve("lunge done")
	var swing: Dictionary = _swing(m, blk)
	var pierce: bool = bool(swing.get("pierce", false))
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	hp = maxi(0, hp - incoming)
	if incoming > 0:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
	if pierce:
		_log("on_resolve", "hit %s  ATK %s  (ignores BLK)" % [hit_n, m.get("atk", 0)])
		if facing_index >= 0:
			await _announce_slice(facing_index, _hub_hp_pos())
	else:
		_log("on_resolve", "hit %s  ATK %s − BLK" % [hit_n, m.get("atk", 0)])
		_log("var", "BLK %s" % blk)
	if incoming > 0:
		_log("hp", "take %s  →  %s" % [incoming, hp])
		if pierce and _hand_pierce():
			_pulse_arrow_heads()
		await _play_attack_connect()
		await _hurt_ogres(incoming)
		await _grow_vampires()
		if hp > 0:
			await _sync_dire_wolves()
	elif pierce:
		_log("hp", "take 0")
		_refresh_blk(false)
		if sfx:
			sfx.play("glass", -10.0)
	else:
		_log("hp", "take 0")
		await _play_attack_blocked()
	if hp <= 0:
		_try_potion()
	if incoming > 0:
		await _cleric_maybe_flush()
	return incoming


## Spider Egg self-damage. Same ATK-vs-Block math as a swing, but no owner lunge,
## no combat-stage burst, and no BLOCKED stamp on the faced slice.
func _apply_egg_hurt(n: int) -> void:
	var dummy := {"atk": n, "card_id": "spider_egg"}
	var swing: Dictionary = _swing(dummy, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	hp = maxi(0, hp - incoming)
	if incoming > 0:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
		_log("hp", "take %s  →  %s" % [incoming, hp])
		_flash_screen(Color("e07a7a"), 0.16)
		_refresh_hearts()
		_refresh_blk(false)
		if sfx:
			sfx.play_event(&"egg.hurt")
		if wheel_view:
			await wheel_view.play_hub_sting("hurt", incoming)
		await _hurt_ogres(incoming)
		await _grow_vampires()
		if hp > 0:
			await _sync_dire_wolves()
	else:
		_log("hp", "take 0")
		_flash_screen(Color("5aa8e8"), 0.22)
		_refresh_blk(false)
		if sfx:
			sfx.play("block_heavy", -5.0)
			sfx.play("bong", -8.0, 1.12)
			sfx.play("glass", -12.0, 1.3)
		if wheel_view:
			await wheel_view.play_hub_sting("block", 0)
	if hp <= 0:
		_try_potion()
	if incoming > 0:
		await _cleric_maybe_flush()


func _play_attack_connect() -> void:
	_flash_screen(Color("e07a7a"), 0.28)
	_refresh_hearts()
	_refresh_blk(false)
	if sfx:
		sfx.play_event(&"player.hurt")


func _play_attack_blocked() -> void:
	_flash_screen(Color("5aa8e8"), 0.4)
	_refresh_blk(false)
	if sfx:
		sfx.play("block_heavy", -5.0)
		sfx.play("bong", -8.0, 1.12)
		sfx.play("glass", -12.0, 1.3)
		sfx.play_event(&"player.blocked")
	if combat_stage:
		combat_stage.play_block()
	if facing_index >= 0 and wheel_view:
		await wheel_view.play_block(facing_index)


func _player_down() -> void:
	hp = 0
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("death")
	if adventure and not in_tutorial:
		_advance_bucket_counter()
	phase = "defeat"
	_log("end", "dead")
	_flash_screen(Color("c45c5c"), 0.28)
	if sfx:
		sfx.set_combat_music(false)
		sfx.play("error_big", -6.0)
		sfx.play_event(&"sting.defeat")
		sfx.music_defeat()
	if combat_stage:
		combat_stage.hide_stage()
	_hide_hypno()
	_discard_spent_items()
	facing_index = -1
	_refresh()


func _clear_after_fight(clockwork_split: bool = false) -> void:
	if adventure:
		await _challenge_after_fight()
		return
	if facing_index < 0 or facing_index >= wheel.size():
		_trace_resolve("clear abort facing=%s n=%s" % [facing_index, wheel.size()])
		return
	var m: Dictionary = wheel[facing_index]
	var left_id: String = str(m.get("card_id", ""))
	_trace_resolve("clear start left=%s n=%s" % [left_id, wheel.size()])
	await _wick_on_defeated(facing_index)
	await _remove_crossbowed()
	_trace_resolve("clear after crossbow n=%s" % wheel.size())
	if left_id == "mimic" and not enemy_attacked:
		_draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	_remove_facing()
	_trace_resolve("clear after remove n=%s" % wheel.size())
	if clockwork_split and left_id == "clockwork_knight" and not _is_silenced(left_id):
		_spawn_clockwork_heirs()
		_trace_resolve("clear after heirs n=%s" % wheel.size())
	_discard_spent_items()
	blk = 0
	mobs_defeated += 1
	_log("var", "BLK 0")
	_log("var", "defeated %s" % mobs_defeated)
	_trace_resolve("clear wicks")
	await _collapse_dead_wicks()
	_trace_resolve("clear sync")
	_sync_wheel_stats()
	await _slay_pending_ogres()
	phase = "ready"
	if _monsters_left() == 0:
		_trace_resolve("clear dungeon clear")
		_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_trace_resolve("clear refresh n=%s" % wheel.size())
	_refresh()
	_walker_busy = false
	_trace_resolve("clear done")
	if in_tutorial:
		call_deferred("_tutorial_after_fight")


func _maybe_auto_spin() -> void:
	if in_tutorial:
		return
	if adventure and not _challenge_force_spin:
		return
	if phase != "ready":
		return
	if _monsters_left() <= 0:
		return
	_trace_resolve("auto-spin wait n=%s" % _monsters_left())
	await get_tree().create_timer(0.15).timeout
	_trace_resolve("auto-spin after timer phase=%s" % phase)
	if ability_slash != null:
		var guard := 0
		while ability_slash.visible and guard < 90:
			await get_tree().process_frame
			guard += 1
	if phase == "ready" and not _wheel_busy():
		_trace_resolve("auto-spin go")
		await _on_spin()


func _remove_facing() -> void:
	var m: Dictionary = wheel[facing_index]
	_log("on_remove_slice", str(m["name"]))
	wheel.remove_at(facing_index)
	facing_index = -1
	_reseat_slots()


func _discard_spent_items() -> void:
	var kept: Array = []
	for it in hotbar:
		if it["spent"] and not it["keep_after"]:
			_log("discard", str(it["name"]))
			continue
		if it["spent"] and it["keep_after"]:
			if keep_blocked_this_fight:
				_log("discard", str(it["name"]))
				continue
			if str(it.get("card_id", "")) == "breastplate" and not lost_hp_this_combat:
				_log("discard", str(it["name"]))
				continue
			it["spent"] = false
			it["keep_after"] = false
			_log("keep", str(it["name"]))
		kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _undo_dup(v: Variant) -> Variant:
	if typeof(v) == TYPE_DICTIONARY:
		return (v as Dictionary).duplicate(true)
	if typeof(v) == TYPE_ARRAY:
		return (v as Array).duplicate(true)
	return v


func _capture_run() -> Dictionary:
	return {
		"hp": hp,
		"blk": blk,
		"phase": phase,
		"draft_action": draft_action,
		"wheel": wheel.duplicate(true),
		"hotbar": hotbar.duplicate(true),
		"facing_index": facing_index,
		"pending_choice": pending_choice.duplicate(true),
		"pending_monster": pending_monster.duplicate(true),
		"pending_item": pending_item.duplicate(true),
		"uid_seq": uid_seq,
		"magnet_seq": _magnet_seq,
		"magnet_pending_consume": _magnet_pending_consume,
		"last_mob_hp": last_mob_hp,
		"last_mob_atk": last_mob_atk,
		"items_used_this_combat": items_used_this_combat,
		"last_item_atk": last_item_atk,
		"last_blk_gain": last_blk_gain,
		"last_item_copy": last_item_copy.duplicate(true),
		"silenced": silenced.duplicate(true),
		"pending_feed": pending_feed.duplicate(true),
		"skip_swing_this_fight": skip_swing_this_fight,
		"keep_blocked_this_fight": keep_blocked_this_fight,
		"num_items_at_combat": num_items_at_combat,
		"mobs_defeated": mobs_defeated,
		"hp_loss_events": hp_loss_events,
		"bleed_hold": _bleed_hold,
		"bleed_losses": _bleed_losses,
		"lost_hp_this_combat": lost_hp_this_combat,
		"enemy_attacked": enemy_attacked,
		"last_atk_index": last_atk_index,
		"last_atk_line": last_atk_line,
		"pending_mark": pending_mark.duplicate(true),
		"pending_chaos": pending_chaos.duplicate(true),
		"beads_step": beads_step,
		"reroll_skip": _reroll_skip,
		"rng_state": rng.state,
		"watch_thorns_seat": _watch_thorns_seat,
		"watch_skip_thorns": _watch_skip_thorns,
		"hypno_src": _hypno_src,
		"cube_line": _cube_line,
		"dungeons_ended": _dungeons_ended,
		"buckets_revealed": _buckets_revealed,
		"guarantee_bucket": _guarantee_bucket,
		"item_pool": item_pool.duplicate(true),
		"monster_pool": monster_pool.duplicate(true),
		"dungeons_cleared": dungeons_cleared,
		"dungeon_index": dungeon_index,
		"challenge_deck": challenge_deck.duplicate(true),
		"challenge_aim": challenge_aim,
		"adventure_seat_tiers": adventure_seat_tiers.duplicate(true),
	}


func _undo_stale(token: int) -> bool:
	return token != _undo_gen


func _undo_in_scope() -> bool:
	if in_tutorial:
		return false
	return phase == "fighting" or phase == "ready" or phase == "slaying" or phase == "defeat" or phase == "victory"


func _undo_can_undo() -> bool:
	if in_tutorial:
		return false
	if _undo_inflight:
		return true
	return not _undo_stack.is_empty()


func _undo_can_redo() -> bool:
	if in_tutorial or _undo_inflight:
		return false
	return not _redo_stack.is_empty()


func _undo_clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	_undo_inflight = false
	_undo_live = {}
	_undo_gen += 1


func _undo_arm() -> void:
	if in_tutorial:
		_undo_inflight = false
		_undo_live = {}
		return
	_undo_inflight = false
	_undo_live = _capture_run()
	_sync_buttons()


func _undo_wall() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	_undo_inflight = false
	if in_tutorial:
		_undo_live = {}
		return
	_undo_live = _capture_run()
	_sync_buttons()


func _undo_begin() -> void:
	if in_tutorial:
		return
	if _undo_live.is_empty():
		_undo_live = _capture_run()
	_undo_inflight = true
	_sync_buttons()


func _undo_abort() -> void:
	_undo_inflight = false
	_sync_buttons()


func _undo_commit() -> void:
	if in_tutorial:
		_undo_inflight = false
		return
	if not _undo_inflight:
		_undo_arm()
		return
	if not _undo_live.is_empty():
		_undo_stack.append(_undo_live)
	_redo_stack.clear()
	_undo_inflight = false
	_undo_live = _capture_run()
	_sync_buttons()


func _undo_finish_item() -> void:
	if in_tutorial:
		_undo_inflight = false
		return
	if not _undo_inflight:
		if _undo_live.is_empty():
			_undo_arm()
		_sync_buttons()
		return
	if phase == "fighting" or phase == "ready" or phase == "defeat" or phase == "victory":
		_undo_commit()
		return
	_undo_wall()


func _undo_kill_motion() -> void:
	_walker_busy = false
	_adventure_busy = false
	if wheel_view != null:
		if wheel_view.has_method("kill_spin"):
			wheel_view.kill_spin()
		wheel_view.busy = false
	if combat_stage != null:
		combat_stage.busy = false
	if _courier:
		_courier.visible = false
		_clear_courier_gear()
	if get_tree() != null:
		for tw in get_tree().get_processed_tweens():
			if tw != null and tw.is_valid():
				tw.kill()
	_undo_clear_stray_cards()


func _undo_clear_stray_cards() -> void:
	if get_tree() == null:
		return
	var keep: Node = hotbar_box
	for child in get_tree().root.get_children():
		if child == self or child == keep:
			continue
		if child.has_meta("tossing") or (child.has_method("toss") and child.has_method("set_live") and child.get_parent() != keep):
			if child.get_parent() == get_tree().root:
				child.queue_free()


func _restore_run(snap: Dictionary) -> void:
	if snap.is_empty():
		return
	_undo_gen += 1
	_undo_kill_motion()
	hp = int(snap.get("hp", hp))
	blk = int(snap.get("blk", blk))
	phase = str(snap.get("phase", phase))
	draft_action = str(snap.get("draft_action", draft_action))
	var w: Variant = snap.get("wheel", wheel)
	if typeof(w) == TYPE_ARRAY:
		wheel = (w as Array).duplicate(true)
	var hb: Variant = snap.get("hotbar", hotbar)
	if typeof(hb) == TYPE_ARRAY:
		hotbar = (hb as Array).duplicate(true)
	facing_index = int(snap.get("facing_index", facing_index))
	pending_choice = _undo_dup(snap.get("pending_choice", {}))
	pending_monster = _undo_dup(snap.get("pending_monster", {}))
	pending_item = _undo_dup(snap.get("pending_item", {}))
	uid_seq = int(snap.get("uid_seq", uid_seq))
	_magnet_seq = int(snap.get("magnet_seq", _magnet_seq))
	_magnet_pending_consume = str(snap.get("magnet_pending_consume", ""))
	last_mob_hp = int(snap.get("last_mob_hp", last_mob_hp))
	last_mob_atk = int(snap.get("last_mob_atk", last_mob_atk))
	items_used_this_combat = int(snap.get("items_used_this_combat", items_used_this_combat))
	last_item_atk = int(snap.get("last_item_atk", last_item_atk))
	last_blk_gain = int(snap.get("last_blk_gain", last_blk_gain))
	last_item_copy = _undo_dup(snap.get("last_item_copy", {}))
	silenced = _undo_dup(snap.get("silenced", {}))
	pending_feed = _undo_dup(snap.get("pending_feed", {}))
	skip_swing_this_fight = bool(snap.get("skip_swing_this_fight", false))
	keep_blocked_this_fight = bool(snap.get("keep_blocked_this_fight", false))
	num_items_at_combat = int(snap.get("num_items_at_combat", num_items_at_combat))
	mobs_defeated = int(snap.get("mobs_defeated", mobs_defeated))
	hp_loss_events = int(snap.get("hp_loss_events", hp_loss_events))
	_bleed_hold = int(snap.get("bleed_hold", 0))
	_bleed_losses = int(snap.get("bleed_losses", 0))
	lost_hp_this_combat = bool(snap.get("lost_hp_this_combat", false))
	enemy_attacked = bool(snap.get("enemy_attacked", false))
	last_atk_index = int(snap.get("last_atk_index", -1))
	last_atk_line = str(snap.get("last_atk_line", ""))
	pending_mark = _undo_dup(snap.get("pending_mark", {}))
	pending_chaos = _undo_dup(snap.get("pending_chaos", {}))
	beads_step = int(snap.get("beads_step", 1))
	_reroll_skip = int(snap.get("reroll_skip", -1))
	rng.state = snap.get("rng_state", rng.state)
	_watch_thorns_seat = int(snap.get("watch_thorns_seat", -1))
	_watch_skip_thorns = bool(snap.get("watch_skip_thorns", false))
	_hypno_src = int(snap.get("hypno_src", -1))
	_cube_line = str(snap.get("cube_line", ""))
	_dungeons_ended = int(snap.get("dungeons_ended", _dungeons_ended))
	_buckets_revealed = int(snap.get("buckets_revealed", _buckets_revealed))
	_guarantee_bucket = int(snap.get("guarantee_bucket", _guarantee_bucket))
	item_pool = _undo_dup(snap.get("item_pool", item_pool))
	monster_pool = _undo_dup(snap.get("monster_pool", monster_pool))
	dungeons_cleared = int(snap.get("dungeons_cleared", dungeons_cleared))
	dungeon_index = int(snap.get("dungeon_index", dungeon_index))
	challenge_deck = _undo_dup(snap.get("challenge_deck", challenge_deck))
	challenge_aim = int(snap.get("challenge_aim", challenge_aim))
	adventure_seat_tiers = _undo_dup(snap.get("adventure_seat_tiers", adventure_seat_tiers))
	if wheel_view:
		wheel_view.selected_index = challenge_aim if phase == "ready" else -1
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(challenge_deck.size() if typeof(challenge_deck) == TYPE_ARRAY else 0)
	_hotbar_sig = ""
	_blk_shown = -1
	_ghost_blk = -1
	_ghost_hp = -1
	_hp_shown = hp
	_face_atk_shown = ""
	_face_hp_shown = ""
	_slain_shown = mobs_defeated
	_fly_card = null
	_inspect_pinned = false
	_save_bucket_progress()
	if speech_box:
		speech_box.hide_speech()
	if _hypno_src >= 0:
		_show_hypno(_hypno_src)
	else:
		_hide_hypno()
	if combat_stage:
		if (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size():
			combat_stage.show_monster(str(wheel[facing_index].get("card_id", "")), int(wheel[facing_index].get("tier", 1)))
			_tune_combat_stage()
		else:
			combat_stage.hide_stage()
	if sfx:
		sfx.set_combat_music(phase == "fighting" or phase == "slaying")
	_refresh()


func _undo_play_fx(is_redo: bool) -> void:
	_flash_screen(Color("c4a574") if is_redo else Color("6bb3d9"), 0.22)
	if sfx:
		sfx.play("whoosh", -10.0, 1.2 if is_redo else 0.72)
		sfx.play("click2", -12.0)


func _on_undo() -> void:
	if in_tutorial or _undo_busy:
		return
	_undo_busy = true
	if _undo_inflight:
		if _undo_live.is_empty():
			_undo_abort()
		else:
			_log("on_click", "Undo")
			_restore_run(_undo_live)
			_undo_inflight = false
			_undo_live = _capture_run()
			_undo_play_fx(false)
			_sync_buttons()
	elif _undo_stack.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
	else:
		_log("on_click", "Undo")
		_redo_stack.append(_capture_run())
		var snap: Dictionary = _undo_stack.pop_back()
		_restore_run(snap)
		_undo_live = _capture_run()
		_undo_play_fx(false)
		_sync_buttons()
	_undo_busy = false


func _on_redo() -> void:
	if in_tutorial or _undo_busy or _undo_inflight or _redo_stack.is_empty():
		if sfx and not in_tutorial and not _undo_busy:
			sfx.play("error", -12.0, 1.2)
		return
	_undo_busy = true
	_log("on_click", "Redo")
	if not _undo_live.is_empty():
		_undo_stack.append(_undo_live)
	else:
		_undo_stack.append(_capture_run())
	var snap: Dictionary = _redo_stack.pop_back()
	_restore_run(snap)
	_undo_live = _capture_run()
	_undo_play_fx(true)
	_sync_buttons()
	_undo_busy = false


func _use_item(uid: int) -> void:
	if _challenge_loot_wait:
		_challenge_discard_one(uid)
		return
	var it_pre: Dictionary = _find_item(uid)
	var magnet_ready: bool = phase == "ready" and _is_magnet(it_pre)
	if not magnet_ready and (phase != "fighting" or facing_index < 0):
		return
	if not pending_feed.is_empty():
		var allowed: Array = pending_feed.get("uids", [])
		if not allowed.has(uid):
			if sfx:
				sfx.play("error", -12.0, 1.2)
			return
		await _feed_cube(uid)
		_undo_arm()
		return
	if _wheel_busy():
		return
	if not pending_chaos.is_empty():
		await _chaos_pick(uid)
		return
	var it: Dictionary = _find_item(uid)
	if it.is_empty() or it["spent"]:
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if bool(it.get("petrified", false)):
		_log("on_item_use", "petrified")
		if sfx:
			sfx.play_event(&"hand.petrified")
		return
	if in_tutorial and not _tutorial_allows_item(str(it.get("card_id", ""))):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_item", "Not that one."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if sfx:
		sfx.play("select", -10.0)
	pending_mark.clear()
	_log("on_click", str(it["name"]))
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind == "passive":
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	_undo_begin()
	var token: int = _undo_gen
	if kind == "choose" or kind == "magnet":
		var opts: Variant = ops.get("options", [])
		if typeof(opts) != TYPE_ARRAY or (opts as Array).is_empty():
			if kind == "magnet":
				opts = [
					{"id": "high", "label": "Highest Attack"},
					{"id": "low", "label": "Lowest Attack"},
					{"id": "off", "label": "Off"},
				]
			else:
				opts = [
					{"id": "throw", "label": PLAYER_COPY.text("combat.knife_throw", "ATK 3, discard"), "atk": 3, "keep": false},
					{"id": "nick", "label": PLAYER_COPY.text("combat.knife_nick", "ATK 1, keep"), "atk": 1, "keep": true},
				]
		pending_choice = {"uid": uid, "options": opts}
		_log("on_item_use", "choose")
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "mark_poison" or kind == "mark_crossbow" or kind == "atk_neighbor" or kind == "hook_swap" or kind == "hypnotize" or kind == "defeat_double_hp":
		if _mark_targets(kind).is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			_undo_abort()
			return
		pending_mark = {"uid": uid, "kind": kind}
		_log("on_item_use", "pick who hits your enemy" if kind == "hypnotize" else ("pick a monster" if kind == "defeat_double_hp" else "pick a neighbor"))
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "chaos_reroll":
		await _begin_chaos(uid)
		if pending_chaos.is_empty():
			_undo_abort()
		return
	_bleed_begin()
	await _apply_ops(it, ops, {})
	if _undo_stale(token):
		return
	await _after_item_resolved(it)
	if _undo_stale(token):
		return
	await _bleed_end()
	if _undo_stale(token):
		return
	if in_tutorial:
		_tutorial_item_used(str(it.get("card_id", "")))
	_undo_finish_item()
	call_deferred("_refresh")


func _choose_option(opt: Dictionary) -> void:
	var it: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
	pending_choice.clear()
	if it.is_empty():
		_undo_abort()
		call_deferred("_refresh")
		return
	var token: int = _undo_gen
	var oid: String = str(opt.get("id", ""))
	if oid == "high" or oid == "low" or oid == "off" or str(_ops_of(it).get("kind", "")) == "magnet":
		await _set_magnet_mode(it, oid)
		if _undo_stale(token):
			return
		if sfx:
			sfx.play("click2", -8.0)
		_undo_finish_item()
		call_deferred("_refresh")
		return
	_bleed_begin()
	if int(opt.get("atk_drop", 0)) > 0:
		await _apply_ops(it, {"kind": "atk_drop", "n": int(opt.get("atk_drop", 0))}, opt)
	elif int(opt.get("blk", 0)) > 0:
		await _apply_ops(it, {"kind": "blk", "n": int(opt.get("blk", 0))}, opt)
	else:
		await _apply_ops(it, {"kind": "atk", "n": int(opt.get("atk", 0))}, opt)
	if _undo_stale(token):
		return
	await _after_item_resolved(it)
	if _undo_stale(token):
		return
	await _bleed_end()
	if _undo_stale(token):
		return
	if sfx:
		sfx.play("click2", -8.0)
	_undo_finish_item()
	call_deferred("_refresh")


func _ops_of(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) == "echo_bell":
		var copy: Variant = it.get("echo_copy", last_item_copy)
		if typeof(copy) == TYPE_DICTIONARY and not (copy as Dictionary).is_empty():
			var cops: Variant = (copy as Dictionary).get("ops", {})
			if typeof(cops) == TYPE_DICTIONARY and not (cops as Dictionary).is_empty():
				return (cops as Dictionary).duplicate(true)
	var ops: Dictionary = it.get("ops", {})
	if ops.is_empty():
		var id: String = str(it.get("card_id", ""))
		if ITEM_OPS.has(id):
			return ITEM_OPS[id]
	return ops


func _apply_ops(it: Dictionary, ops: Dictionary, extra: Dictionary) -> void:
	last_atk_index = -1
	last_atk_line = ""
	var m: Dictionary = wheel[facing_index]
	var kind: String = str(ops.get("kind", ""))
	var view: Dictionary = _item_view(it)
	if kind.begins_with("atk") and kind != "atk_zero" and kind != "atk_drop":
		_hero_swipe_armed = true
	await _announce_item_use(it, _item_fx_dest(kind))
	if str(it.get("card_id", "")) == "echo_bell":
		if sfx:
			sfx.play_event(&"chaos.echo_bell")
		if get_tree():
			await get_tree().create_timer(0.09).timeout
	match kind:
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_from_atk":
			var n: int = int(view.get("n", ops.get("n", 0)))
			if kind == "blk_neighbor" and n < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(maxi(0, n))
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [maxi(0, n), blk])
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "atk_wheel", "atk_echo":
			var n2: int = int(ops["n"]) if ops.has("n") else int(view.get("n", 0))
			if kind == "atk_echo" and n2 <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "atk_strong_neighbor" and n2 < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			last_item_atk = n2
			if await _deal_atk(n2):
				it["spent"] = true
				if extra.has("keep"):
					it["keep_after"] = bool(extra["keep"])
				if str(it.get("card_id", "")) == "echo_bell":
					it["keep_after"] = false
				await _count_item_use()
				_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n2, wheel[facing_index]["hp"]])
		"atk_cleave":
			if await _apply_cleave(int(ops.get("n", 2))):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
		"atk_opposite":
			var opp: int = _opposite_index()
			if opp < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			var n4: int = int(ops.get("n", 4))
			if await _deal_atk_at(opp, n4):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", last_atk_line if last_atk_line != "" else "%s  →  %s HP %s" % [n4, wheel[opp].get("name", "?"), wheel[opp].get("hp", 0)])
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			_sync_wheel_stats()
			var bow_at: int = last_atk_index if last_atk_index >= 0 else opp
			if bow_at >= 0 and bow_at < wheel.size() and int(wheel[bow_at].get("hp", 0)) <= 0:
				await _maybe_slay_down(bow_at)
			return
		"heal_kills":
			var flask_n: int = 1 + mobs_defeated
			_log("on_item_use", str(it["name"]))
			await _heal(flask_n)
		"heal_full":
			_log("on_item_use", str(it["name"]))
			await _heal(6)
		"egg_hurt":
			var egg_atk: int = _atk_with_head(int(ops.get("n", 2)))
			_log("on_item_use", str(it["name"]))
			await _apply_egg_hurt(egg_atk)
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			return
		"blk_siphon":
			var n: int = int(it.get("siphon_blk", 0))
			if n <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(n)
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [n, blk])
		"smoke":
			if sfx:
				sfx.play_event(&"smoke.use")
			it["spent"] = true
			await _count_item_use()
			_draw_unseen_item()
			_log("on_item_use", str(it["name"]))
			_reroll_skip = facing_index
			if facing_index >= 0:
				wheel[facing_index]["spin_locked"] = false
			facing_index = -1
			blk = 0
			pending_mark.clear()
			_toss_item(int(it["uid"]), false)
			_discard_spent_items()
			_sync_wheel_stats()
			phase = "ready"
			if combat_stage:
				combat_stage.hide_stage()
			_hide_hypno()
			call_deferred("_maybe_auto_spin")
			return
		"atk_zero":
			if _atk_is_always(m):
				_log("on_item_use", str(it["name"]))
				_log("atk", "%s always — Attack stays %s" % [m.get("name", "?"), m.get("atk", 0)])
			else:
				m["atk_zeroed"] = true
				wheel[facing_index] = m
				_sync_wheel_stats()
				m = wheel[facing_index]
				_log("on_item_use", str(it["name"]))
				_log("atk", "facing ATK 0")
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"atk_drop":
			var drop: int = int(ops.get("n", 1))
			var before_n: int = int(m.get("atk", 0))
			if _atk_is_always(m):
				_log("on_item_use", str(it["name"]))
				_log("atk", "%s always — Attack stays %s" % [m.get("name", "?"), before_n])
			else:
				m["atk_mod"] = int(m.get("atk_mod", 0)) - drop
				wheel[facing_index] = m
				_sync_wheel_stats()
				m = wheel[facing_index]
				_log("on_item_use", str(it["name"]))
				_log("atk", "facing ATK −%s  →  %s" % [drop, m["atk"]])
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"heal_keep":
			var lantern_n: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			await _heal(lantern_n)
			it["keep_after"] = hp < HP_MAX
		"blk_last":
			if last_blk_gain <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_gain_blk(last_blk_gain)
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [last_blk_gain, blk])
		"quiet":
			var qid: String = str(m.get("card_id", ""))
			if not _has_unique_ability(qid) or _is_silenced(qid):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			silenced[qid] = true
			if qid == "basilisk":
				keep_blocked_this_fight = false
			_sync_wheel_stats()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "silenced %s" % qid)
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("pluck", -10.0, 0.85)
				sfx.play_event(&"util.quiet")
		"atk_spend_blk":
			var copy_blk: int = blk
			if copy_blk <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			last_item_atk = copy_blk
			it["keep_after"] = true
			_log("on_item_use", str(it["name"]))
			if await _deal_atk(copy_blk):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), true)
				return
			_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [copy_blk, wheel[facing_index]["hp"]])
		"atk_empty":
			var bead_n: int = beads_step
			last_item_atk = bead_n
			if await _deal_atk(bead_n):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [bead_n, wheel[facing_index]["hp"]])
		"defeat_only_item":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if _hand_has_atk_item(int(it.get("uid", -1))):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			await _count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play_event(&"defeat.use")
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		"skip_swing":
			skip_swing_this_fight = true
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "skip swing")
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("pluck", -10.0, 0.85)
		"fangs":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			var stored: int = int(m.get("hp", 0))
			_log("on_item_use", str(it["name"]))
			await _owner_attack(m)
			if hp <= 0:
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				_player_down()
				return
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			await _play_ended_visuals()
			await _heal(stored)
			await _clear_after_fight(false)
			_maybe_auto_spin()
			return
		"defeat_hp":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if int(m["hp"]) >= hp:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			await _count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play_event(&"defeat.use")
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		"defeat_atk":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if int(m["atk"]) < 5:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			await _count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play_event(&"defeat.use")
			_toss_item(int(it["uid"]), false)
			await _begin_slay()
			return
		_:
			return
	it["spent"] = true
	if extra.has("keep"):
		it["keep_after"] = bool(extra["keep"])
	elif kind == "blk_keep" or kind == "atk_spend_blk":
		it["keep_after"] = true
	if str(it.get("card_id", "")) == "echo_bell":
		it["keep_after"] = false
	await _count_item_use()
	_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
	_sync_wheel_stats()
	if last_atk_index >= 0 and last_atk_index != facing_index and last_atk_index < wheel.size():
		if int(wheel[last_atk_index].get("hp", 0)) <= 0 and not _wick_waiting(last_atk_index):
			await _maybe_slay_down(last_atk_index)
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0:
		if not _wick_waiting(facing_index):
			await _begin_slay()


func _toss_item(uid: int, keep: bool, slow: bool = false) -> void:
	if keep and _keep_blocked_now():
		keep = false
	for c in hotbar_box.get_children():
		if not c.has_method("toss"):
			continue
		if int(c.uid) != uid:
			continue
		if keep:
			c.bounce()
			if sfx:
				sfx.play("pluck", -10.0)
		else:
			c.toss(slow)
			if sfx:
				sfx.play_event(&"hand.toss")
		break
	if not keep:
		_remove_item_now(uid)
		_sync_wheel_stats()


func _remove_item_now(uid: int) -> void:
	var kept: Array = []
	for it in hotbar:
		if int(it.get("uid", -1)) != uid:
			kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _defeat_blocked(m: Dictionary) -> bool:
	var id: String = str(m.get("card_id", ""))
	return id == "gargoyle" and not _is_silenced(id)


func _wick_waiting(_index: int) -> bool:
	return false


func _wick_on_defeated(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	var who: String = str(wheel[index].get("name", "Neighbor"))
	var nbs: Array[int] = _damsel_neighbors(index)
	for i in nbs:
		if str(wheel[i].get("card_id", "")) != "wick":
			continue
		if _is_silenced(wheel[i]):
			continue
		await _announce_slice(i, _slice_hp_pos(i))
		await _chip_hp(i, 2)
		_log("on_resolve", "Wick -2 (%s Defeated)" % who)
	await _collapse_dead_wicks()


func _twins_facing() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	return str(wheel[facing_index].get("card_id", "")) == "hollow" and not _is_silenced("hollow")


func _twins_double_atk(index: int, n: int) -> bool:
	if n <= 0 or n % 2 != 0:
		return false
	if index < 0 or index >= wheel.size():
		return false
	return str(wheel[index].get("card_id", "")) == "hollow" and not _is_silenced("hollow")


func _twins_double_blk(n: int) -> bool:
	return n > 0 and n % 2 == 0 and _twins_facing()


func _chip_hp(index: int, n: int) -> bool:
	if index < 0 or index >= wheel.size() or n <= 0:
		return false
	var m: Dictionary = wheel[index]
	var drop: int = n
	var cut_chip: bool = false
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced("anvil"):
		if n > 1:
			cut_chip = true
		drop = 1
	var before: int = int(m.get("hp", 0))
	if cut_chip:
		await _announce_slice(index, _slice_hp_pos(index))
	m["hp"] = maxi(0, before - drop)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m
	if wheel_view:
		if cut_chip:
			await wheel_view.play_hp_ticks(index, before, int(m["hp"]))
		else:
			wheel_view.punch_hp(index)
	if before > int(m["hp"]) and int(m["hp"]) > 0:
		return await _coward_after_hp_loss(index)
	return false


func _bandit_atk_now(_s: Dictionary) -> int:
	return maxi(0, _live_item_count())


func _wolf_atk_now(_s: Dictionary) -> int:
	return maxi(0, hp)


func _leftmost_atk_n() -> int:
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if _item_atk_score(it) < 0:
			continue
		return _item_atk_score(it)
	return 3


func _hand_has_atk_item(except_uid: int = -1) -> bool:
	for it in hotbar:
		if int(it.get("uid", -2)) == except_uid:
			continue
		if bool(it.get("spent", false)):
			continue
		if _item_atk_score(it) >= 0:
			return true
	return false


func _collapse_dead_wicks() -> void:
	if _wick_collapsing:
		return
	_wick_collapsing = true
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and str(wheel[i].get("card_id", "")) == "wick" and int(wheel[i].get("hp", 0)) <= 0:
			await _kill_neighbor(i)
		i -= 1
	_wick_collapsing = false


func _maybe_slay_down(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if int(wheel[index].get("hp", 0)) > 0:
		return
	if _wick_waiting(index):
		return
	if await _try_commander_flee(index):
		return
	if index == facing_index:
		await _begin_slay()
	else:
		await _kill_neighbor(index)


func _chaos_candidates(stone_uid: int) -> Array:
	var out: Array = []
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if int(it.get("uid", -1)) == stone_uid:
			continue
		out.append(int(it.get("uid", -1)))
	return out


func _begin_chaos(uid: int) -> void:
	var cands: Array = _chaos_candidates(uid)
	if cands.is_empty():
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	pending_chaos = {
		"uid": uid,
		"picks": [],
		"need": mini(2, cands.size()),
	}
	_log("on_item_use", "pick items")
	if sfx:
		sfx.play("question", -10.0)
	call_deferred("_refresh")


func _chaos_pick(uid: int) -> void:
	var stone_uid: int = int(pending_chaos.get("uid", -1))
	if uid == stone_uid:
		pending_chaos.clear()
		_log("on_item_use", "cancel")
		_undo_abort()
		call_deferred("_refresh")
		return
	var cands: Array = _chaos_candidates(stone_uid)
	if not cands.has(uid):
		if sfx:
			sfx.play("error", -10.0)
		return
	var picks: Array = pending_chaos.get("picks", [])
	if picks.has(uid):
		if sfx:
			sfx.play("error", -10.0)
		return
	picks.append(uid)
	pending_chaos["picks"] = picks
	if sfx:
		sfx.play("select", -10.0)
	if picks.size() < int(pending_chaos.get("need", 1)):
		call_deferred("_refresh")
		return
	await _finish_chaos()


func _finish_chaos() -> void:
	var stone: Dictionary = _find_item(int(pending_chaos.get("uid", -1)))
	var picks: Array = pending_chaos.get("picks", [])
	pending_chaos.clear()
	if stone.is_empty() or bool(stone.get("spent", false)):
		_undo_abort()
		call_deferred("_refresh")
		return
	_flash_screen(Color("3a1460"), 0.42)
	if sfx:
		sfx.play("whoosh", -8.0, 0.86)
		sfx.play("bong", -12.0, 0.7)
		sfx.play_event(&"chaos.transform")
	if get_tree():
		await get_tree().create_timer(0.28).timeout
	for uid_v in picks:
		await _reroll_item_same_tier(int(uid_v))
	stone["spent"] = true
	await _count_item_use()
	_toss_item(int(stone["uid"]), false)
	_sort_hotbar()
	_log("on_item_use", str(stone.get("name", "Chaos Stone")))
	await _after_item_resolved(stone)
	_undo_wall()
	call_deferred("_refresh")


func _reroll_item_same_tier(uid: int) -> void:
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	var tier: int = _tier_of(it)
	var pool: Array = []
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if _as_int(card.get("tier", 1), 1) != tier:
			continue
		pool.append(str(id))
	if pool.is_empty():
		return
	var nid: String = str(pool[rng.randi() % pool.size()])
	var fresh: Dictionary = _make_item(nid)
	var keep_uid: int = int(it.get("uid", uid))
	it.clear()
	for k in fresh.keys():
		it[k] = fresh[k]
	it["uid"] = keep_uid
	_hotbar_sig = ""
	await _play_item_transform(keep_uid)


func _play_item_transform(uid: int) -> void:
	_flash_screen(Color("3a1460"), 0.28)
	if sfx:
		sfx.play("whoosh", -8.0, 0.9)
		sfx.play("pluck", -6.0, 1.15)
		sfx.play("confirm", -10.0, 0.85)
	if hotbar_box:
		for c in hotbar_box.get_children():
			if int(c.get("uid")) != uid:
				continue
			if c.has_method("play_transform"):
				c.play_transform()
			elif c.has_method("bounce"):
				c.bounce()
			break
	if get_tree():
		await get_tree().create_timer(0.36).timeout


func _store_last_faced_hp() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var face: Dictionary = wheel[facing_index]
	if str(face.get("kind", "")) != "monster":
		return
	last_mob_hp = maxi(int(face.get("hp", 3)), 0)



func _apply_cursed_scrolls() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "cursed_scroll":
			continue
		if bool(it.get("spent", false)):
			continue
		_log("on_spin", "Cursed Scroll")
		await _announce_item_use(it, _hub_hp_pos())
		if await _bleed(1):
			return true
	return false


func _apply_siphon_jars() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "grief_jar":
			continue
		if bool(it.get("spent", false)):
			continue
		it["siphon_blk"] = int(it.get("siphon_blk", 0)) + 2
		_log("var", "Grief Jar BLK %s" % it["siphon_blk"])
		await _announce_item_use(it, _hub_hp_pos())
		if await _bleed(1):
			return true
	return false



func _flip_alt_sais() -> void:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(_ops_of(it).get("kind", "")) != "atk_alt_24":
			continue
		var n: int = int(it.get("alt_n", 2))
		it["alt_n"] = 2 if n == 4 else 4



func _directed_neighbor_atk(ccw: bool) -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	# Next index is clockwise on the wheel. Left Bracer passes ccw=false.
	var off: int = n - 1 if ccw else 1
	var j: int = (facing_index + off) % n
	if str(wheel[j].get("kind", "")) != "monster":
		return -1
	return int(wheel[j].get("atk", 0))



## Dire Wolf Attack always equals your HP. Quiet Bell freezes it. Net and Commander do not change it.
func _sync_dire_wolves() -> void:
	var changed: Array[int] = []
	var from_n: Dictionary = {}
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "dire_wolf":
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		if _is_silenced(s):
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		var want: int = _wolf_atk_now(s)
		var before: int = int(s.get("atk", 0))
		if before == want:
			continue
		s["atk"] = want
		wheel[i] = s
		changed.append(i)
		from_n[i] = before
		_log("var", "Dire Wolf ATK %s  →  %s" % [before, want])
	if changed.is_empty():
		return
	_refresh()
	for i in changed:
		var start_n: int = int(from_n.get(i, hp))
		var now_n: int = int(wheel[i].get("atk", hp))
		await _announce_slice(i, _slice_atk_pos(i))
		if wheel_view:
			wheel_view.hit_feedback(i, 0, now_n - start_n)
			await wheel_view.play_atk_ticks(i, start_n, now_n)
	_refresh()


func _hurt_ogres(lost: int) -> void:
	if lost <= 0:
		return
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "ogre":
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		if _is_silenced(s):
			continue
		var before: int = int(s.get("hp", 0))
		s["hp"] = maxi(0, before - lost)
		s["hp_locked"] = true
		if int(s["hp"]) <= 0 and i != facing_index:
			s["pending_slay"] = true
		wheel[i] = s
		await _announce_slice(i, _slice_hp_pos(i))
		if wheel_view:
			await wheel_view.play_hp_ticks(i, before, int(s["hp"]))
	_refresh()
	if phase != "fighting" and phase != "slaying":
		call_deferred("_slay_pending_ogres")


## One bump per loss, not per heart. Every living Vampire on the wheel.
## Quiet Bell skips the bump and leaves the numbers already there.
func _grow_vampires() -> void:
	var any: bool = false
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "vampire":
			continue
		if str(s.get("kind", "")) != "monster":
			continue
		if _is_silenced(s):
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		s["bloodlust"] = int(s.get("bloodlust", 0)) + 1
		s["hp"] = int(s.get("hp", 0)) + 1
		s["hp_max"] = int(s.get("hp_max", s["hp"])) + 1
		s["hp_locked"] = true
		s["atk"] = int(s.get("atk", 0)) + 1
		wheel[i] = s
		any = true
		await _announce_slice(i, _slice_hp_pos(i))
		if wheel_view:
			wheel_view.hit_feedback(i, -1, 1)
			wheel_view.punch_hp(i)
		_log("var", "Vampire +1 HP +1 ATK  →  %s/%s  ATK %s" % [s["hp"], s["hp_max"], s["atk"]])
	if any:
		_refresh()
		if sfx:
			sfx.play("pluck", -10.0, 0.7)


func _slay_pending_ogres() -> void:
	var idxs: Array[int] = []
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "ogre":
			continue
		if int(s.get("hp", 0)) > 0:
			continue
		if i == facing_index:
			continue
		idxs.append(i)
	idxs.reverse()
	for i in idxs:
		await _slay_ogre_at(i)



func _slay_ogre_at(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "ogre":
		return
	var title: String = str(s.get("call_name", "")).strip_edges()
	if title == "":
		title = str(s.get("ability", "")).strip_edges()
	if title != "":
		var at: Vector2 = Vector2.ZERO
		if wheel_view:
			at = wheel_view.slice_portrait_global(index)
		if at != Vector2.ZERO:
			_flash_banner_at(title, at)
		else:
			_flash_banner(title)
	_log("on_remove_slice", str(s.get("name", "Ogre")))
	if sfx:
		sfx.play("whoosh", -8.0, 1.1)
		sfx.play("scratch", -12.0, 0.9)
	if wheel_view:
		await wheel_view.play_slay(index)
		if not adventure:
			await wheel_view.collapse_slice(index, facing_index)
	if adventure:
		_challenge_vacate(index)
		_refresh()
		return
	if index == facing_index:
		facing_index = -1
	elif index < facing_index:
		facing_index -= 1
	wheel.remove_at(index)
	mobs_defeated += 1
	_reseat_slots()
	_refresh()



func _flash_banner(msg: String) -> void:
	if play_field == null or msg.strip_edges() == "":
		return
	var lab: FitLabelBox = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	var long_line: bool = msg.length() > 28
	lab.max_font_size = 22 if long_line else 28
	lab.min_font_size = 16
	lab.set_plain(msg)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.font_color = Color("f0e6d8")
	lab.set_outline(Color("100e0c"), 6)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 40
	play_field.add_child(lab)
	lab.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lab.offset_left = -340.0 if long_line else -220.0
	lab.offset_right = 340.0 if long_line else 220.0
	lab.offset_top = -56.0 if long_line else -24.0
	lab.offset_bottom = 56.0 if long_line else 24.0
	lab.modulate.a = 0.0
	var tw := lab.create_tween()
	tw.tween_property(lab, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.7)
	tw.tween_property(lab, "modulate:a", 0.0, 0.35)
	tw.finished.connect(lab.queue_free)


func _flash_banner_at(msg: String, at: Vector2) -> void:
	if play_field == null or msg.strip_edges() == "":
		return
	var lab: FitLabelBox = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = 20
	lab.min_font_size = 16
	lab.set_plain(msg)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.font_color = Color("f0e6d8")
	lab.set_outline(Color("100e0c"), 6)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 45
	play_field.add_child(lab)
	lab.size = Vector2(240, 36)
	lab.global_position = at - Vector2(120, 18)
	lab.modulate.a = 0.0
	var tw := lab.create_tween()
	tw.tween_property(lab, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.7)
	tw.tween_property(lab, "modulate:a", 0.0, 0.4)
	tw.finished.connect(lab.queue_free)


func _tune_combat_stage() -> void:
	if combat_stage == null:
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if combat_stage.has_method("set_rage_fire"):
		combat_stage.set_rage_fire(str(m.get("card_id", "")) == "berserker" and bool(m.get("rage_fire", false)))
	if combat_stage.has_method("set_fled_mark"):
		combat_stage.set_fled_mark(str(m.get("card_id", "")) == "commander" and bool(m.get("fled_once", false)))


func _hub_hp_pos() -> Vector2:
	if wheel_view:
		return wheel_view.hub_hearts_global()
	return Vector2.ZERO


func _hub_blk_pos() -> Vector2:
	if wheel_view:
		return wheel_view.hub_blk_global()
	return Vector2.ZERO


func _slice_from(index: int) -> Vector2:
	if wheel_view:
		return wheel_view.slice_portrait_global(index)
	return Vector2.ZERO


func _slice_hp_pos(index: int) -> Vector2:
	if wheel_view:
		return wheel_view.hp_global(index)
	return Vector2.ZERO


func _slice_atk_pos(index: int) -> Vector2:
	if wheel_view:
		return wheel_view.atk_global(index)
	return Vector2.ZERO


func _announce(text: String, _from: Vector2, _to: Vector2 = Vector2.INF) -> void:
	if text.strip_edges() == "":
		return
	if ability_slash:
		await ability_slash.play({
			"title": text,
			"call": "",
			"tex": null,
			"is_item": false,
			"card_id": "",
		})


func _announce_slice(index: int, to: Vector2 = Vector2.INF) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	_trace_resolve("announce %s call=%s" % [str(s.get("card_id", "")), str(s.get("call_name", ""))])
	var call_n: String = str(s.get("call_name", "")).strip_edges()
	if call_n == "" and str(s.get("name", "")).strip_edges() == "":
		return
	if ability_slash:
		var tex: Texture2D = null
		if art != null:
			tex = art.monster_still(str(s.get("card_id", "")))
		await ability_slash.play({
			"title": str(s.get("name", "")),
			"call": call_n,
			"tex": tex,
			"is_item": false,
			"card_id": str(s.get("card_id", "")),
		})
	_log_begin_monster(index)


func _announce_item_use(it: Dictionary, to: Vector2 = Vector2.INF) -> void:
	if it.is_empty():
		return
	var title: String = str(it.get("name", "")).strip_edges()
	if title == "":
		return
	_log_flush()
	var uid: int = int(it.get("uid", -1))
	if hotbar_box:
		for c in hotbar_box.get_children():
			if int(c.get("uid")) == uid and c.has_method("bounce"):
				c.bounce()
				break
	if ability_slash:
		var tex: Texture2D = tex_by_item.get(str(it.get("card_id", "")), null)
		if art != null:
			var pix: Texture2D = art.item_tex(str(it.get("card_id", "")))
			if pix != null:
				tex = pix
		await ability_slash.play({
			"title": title,
			"call": "",
			"tex": tex,
			"is_item": true,
			"card_id": str(it.get("card_id", "")),
		})
	_log_begin_item(it)


func _item_fx_dest(kind: String) -> Vector2:
	if kind.begins_with("atk") or kind == "egg_hurt" or kind == "choose":
		return _slice_hp_pos(facing_index)
	if kind.begins_with("blk"):
		return _hub_blk_pos()
	if kind.begins_with("heal"):
		return _hub_hp_pos()
	if kind == "quiet" or kind == "atk_zero" or kind == "atk_drop":
		return _slice_from(facing_index)
	return _hub_hp_pos()



func _gain_blocked_now() -> bool:
	return _keep_blocked_now()



func _try_gain_item(id: String) -> void:
	if id == "":
		return
	if adventure and _hand_full():
		return
	var it: Dictionary = _make_item(id)
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	_refresh()
	if not _gain_blocked_now():
		if sfx:
			sfx.play_event(&"hand.gain", {"card_id": id})
		return
	_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
	_log("discard", str(it.get("name", id)))
	if sfx:
		sfx.play("error", -10.0)
		sfx.play("cloth", -12.0)
	if get_tree():
		await get_tree().create_timer(0.45).timeout
	_toss_item(int(it.get("uid", -1)), false)
	_refresh()



func _shuffle_dungeon() -> void:
	var kept: Array = []
	for s in wheel:
		if str(s.get("kind", "")) == "monster":
			kept.append(s)
	for i in range(kept.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Dictionary = kept[i]
		kept[i] = kept[j]
		kept[j] = tmp
	wheel = kept
	_reseat_slots()



func _try_commander_flee(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "commander":
		return false
	if _is_silenced(s):
		return false
	if bool(s.get("fled_once", false)):
		return false
	s["fled_once"] = true
	s["crossbowed"] = false
	s["hp"] = maxi(1, int(s.get("hp_max", _card_base_hp("commander"))))
	s["hp_locked"] = false
	s["spin_locked"] = false
	wheel[index] = s
	_log("on_resolve", "%s flees" % s.get("name", "Commander"))
	if sfx:
		sfx.play_event(&"mon.commander_flee")
		sfx.play("door_open", -12.0)
	if index == facing_index:
		await _flee_spin()
	else:
		if wheel_view and wheel_view.slay_index == index:
			wheel_view.clear_slay()
		_refresh()
	return true



func _damsel_neighbors(index: int) -> Array[int]:
	var out: Array[int] = []
	var n: int = wheel.size()
	if n <= 0 or index < 0 or index >= n:
		return out
	for j in [(index - 1 + n) % n, (index + 1) % n]:
		if j == index:
			continue
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out



func _damsel_incoming() -> int:
	var left_blk: int = blk
	var total: int = 0
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		for _h in range(_hit_count(j)):
			var swing: Dictionary = _swing(nm, left_blk)
			total += int(swing["dmg"])
			left_blk = int(swing["blk"])
	return total



func _damsel_resolve() -> void:
	phase = "slaying"
	_refresh()
	_bleed_begin()
	if facing_index >= 0:
		var neigh: Array[int] = _damsel_neighbors(facing_index)
		var aim: Vector2 = _hub_hp_pos()
		if not neigh.is_empty():
			aim = _slice_from(neigh[0])
		await _announce_slice(facing_index, aim)
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		if combat_stage:
			combat_stage.show_monster(str(nm.get("card_id", "")), int(nm.get("tier", 1)))
		var hits: int = _hit_count(j)
		for h in range(hits):
			if hp <= 0:
				break
			await _owner_attack(nm, h + 1, hits)
			if hp <= 0:
				break
			if hits > 1 and h < hits - 1:
				await get_tree().create_timer(0.16).timeout
		if hp <= 0:
			await _bleed_end()
			_player_down()
			return
	await _bleed_end()
	if combat_stage:
		combat_stage.show_monster("two_headed_serpent", int(wheel[facing_index].get("tier", 3)) if facing_index >= 0 and facing_index < wheel.size() else 3)
	if sfx:
		sfx.play("pluck", -6.0, 1.35)
		sfx.play("bong", -10.0, 1.5)
		sfx.play("open", -12.0, 1.2)
	_heal(3)
	await _begin_slay()



func _apply_leech_on_spin() -> void:
	var idxs: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "leech_league":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		idxs.append(i)
	for i in idxs:
		if i >= wheel.size() or str(wheel[i].get("card_id", "")) != "leech_league":
			continue
		await _leech_pulse(i)
	if not idxs.is_empty():
		_sync_wheel_stats()
		_refresh()


func _leech_pulse(index: int) -> void:
	var living: Array[int] = []
	for j in range(wheel.size()):
		if str(wheel[j].get("kind", "")) != "monster":
			continue
		if int(wheel[j].get("hp", 0)) <= 0:
			continue
		living.append(j)
	if living.size() < 2:
		return
	var best: int = 999999
	var cands: Array[int] = []
	for j in living:
		var h: int = int(wheel[j].get("hp", 0))
		if h < best:
			best = h
			cands = [j]
		elif h == best:
			cands.append(j)
	if cands.is_empty():
		return
	var target: int = cands[rng.randi_range(0, cands.size() - 1)]
	await _announce_slice(index, _slice_hp_pos(target))
	var steps: int = 0
	while steps < 48:
		steps += 1
		var from: Vector2 = Vector2.ZERO
		var to: Vector2 = Vector2.ZERO
		if wheel_view:
			from = wheel_view.slice_portrait_global(index)
			to = wheel_view.slice_portrait_global(target)
		if sfx:
			sfx.play_event(&"mon.leech_pulse", {"pitch_mul": 1.0 + steps * 0.04})
		if tex_heart != null and from != Vector2.ZERO:
			await _fly_courier(tex_heart, from, to if to != Vector2.ZERO else _slice_hp_pos(target), 0.22)
		_grant_leech_hp(target)
		if wheel_view:
			wheel_view.hit_feedback(target, -1)
		_log("on_spin", "Leech +1 HP → %s" % str(wheel[target].get("name", "?")))
		_refresh()
		if _leech_hp_tied(target):
			break
		if get_tree():
			await get_tree().create_timer(0.08).timeout


func _leech_hp_tied(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return true
	var hp_n: int = int(wheel[index].get("hp", 0))
	for j in range(wheel.size()):
		if j == index:
			continue
		if str(wheel[j].get("kind", "")) != "monster":
			continue
		if int(wheel[j].get("hp", 0)) == hp_n:
			return true
	return false


func _grant_leech_hp(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	s["leech_bonus"] = int(s.get("leech_bonus", 0)) + 1
	s["hp"] = int(s.get("hp", 0)) + 1
	s["hp_max"] = int(s.get("hp_max", s["hp"])) + 1
	wheel[index] = s


func _step_berserkers() -> void:
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "berserker":
			continue
		if _is_silenced(wheel[i]):
			continue
		var old: int = int(wheel[i].get("rage_step", 0)) % 3
		var nxt: int = (old + 1) % 3
		wheel[i]["rage_step"] = nxt
		if nxt == 2 and sfx:
			sfx.play("error_big", -10.0, 0.55)
			sfx.play("chop", -8.0, 0.55)
			sfx.play("whoosh", -12.0, 1.4)
		elif old == 2 and nxt == 0 and sfx:
			sfx.play("glass", -8.0, 0.62)
			sfx.play("cloth", -10.0, 0.7)
			sfx.play("pluck", -14.0, 0.5)
		if combat_stage and facing_index == i:
			_tune_combat_stage()
			if nxt == 2 and combat_stage.has_method("play_rage_up"):
				combat_stage.play_rage_up()
			elif old == 2 and nxt == 0 and combat_stage.has_method("play_rage_down"):
				combat_stage.play_rage_down()



func _apply_queen_eggs_on_spin() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var face_id: String = str(wheel[facing_index].get("card_id", ""))
	if face_id == "spider_queen" and not _is_silenced(wheel[facing_index]):
		var egg_uids: Array = []
		for it in hotbar:
			if str(it.get("card_id", "")) == "spider_egg" and not bool(it.get("spent", false)):
				egg_uids.append(int(it.get("uid", -1)))
		var bonus: int = egg_uids.size()
		for uid in egg_uids:
			_log("discard", "Spider Egg")
			_toss_item(int(uid), false)
		if bonus > 0:
			await _announce_slice(facing_index, _slice_hp_pos(facing_index))
			var q: Dictionary = wheel[facing_index]
			q["hp"] = int(q.get("hp", 0)) + 2 * bonus
			q["hp_max"] = int(q.get("hp_max", q["hp"])) + 2 * bonus
			q["egg_atk"] = int(q.get("egg_atk", 0)) + 2 * bonus
			q["hp_locked"] = true
			wheel[facing_index] = q
			_sync_wheel_stats()
			q = wheel[facing_index]
			_log("var", "Queen +%s HP +%s ATK" % [2 * bonus, 2 * bonus])
			if sfx:
				sfx.play_event(&"egg.queen_eat")
		_refresh()
	for i in range(wheel.size()):
		if i == facing_index:
			continue
		if str(wheel[i].get("card_id", "")) != "spider_queen":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		if _hand_full():
			break
		await _lay_spider_egg(i)
	_refresh()


func _lay_spider_egg(index: int) -> void:
	if _hand_full():
		return
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex("spider_egg")
	if tex == null:
		tex = tex_by_item.get("spider_egg", null)
	var from: Vector2 = Vector2.ZERO
	var to: Vector2 = Vector2.ZERO
	if wheel_view:
		from = wheel_view.slice_portrait_global(index)
	if hotbar_box:
		to = hotbar_box.global_position + hotbar_box.size * 0.5
	if sfx:
		sfx.play_event(&"egg.lay")
	await _announce_slice(index, to if to != Vector2.ZERO else _hub_hp_pos())
	if tex != null and from != Vector2.ZERO:
		await _fly_courier(tex, from, to, 0.42)
	await _try_gain_item("spider_egg")
	var laid: Node = null
	if hotbar_box:
		for c in hotbar_box.get_children():
			if str(c.get("card_id")) == "spider_egg":
				laid = c
	if laid != null and laid.has_method("bounce"):
		laid.bounce()


func _apply_juggernaut_on_spin() -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "juggernaut":
		return
	if _is_silenced(m):
		return
	if _hand_full():
		return
	await _juggernaut_hand_shield()


func _hotbar_empty_slot_global() -> Vector2:
	if hotbar_box == null:
		return Vector2.ZERO
	var kids: Array = hotbar_box.get_children()
	if kids.is_empty():
		return hotbar_box.global_position + hotbar_box.size * 0.5
	var last: Control = kids[kids.size() - 1]
	return last.global_position + Vector2(last.size.x + 8.0 + last.size.x * 0.5, last.size.y * 0.5)


func _juggernaut_hand_shield() -> void:
	var to: Vector2 = _hotbar_empty_slot_global()
	await _announce_slice(facing_index, to)
	var home: Vector2 = await _monster_walk_to(facing_index, "juggernaut", to)
	if phase != "fighting":
		_walker_restore(facing_index)
		return
	await _try_gain_item("shield")
	var planted: Node = null
	if hotbar_box:
		for c in hotbar_box.get_children():
			if str(c.get("card_id")) == "shield":
				planted = c
	if planted != null and planted.has_method("bounce"):
		planted.bounce()
	await _monster_walk_back(facing_index, "juggernaut", home)


func _walker_origin(index: int) -> Vector2:
	if index == facing_index and combat_stage != null and combat_stage.visible:
		return combat_stage.global_position + combat_stage.size * 0.5
	if wheel_view:
		return wheel_view.slice_portrait_global(index)
	return Vector2.ZERO


func _walker_home(index: int) -> Vector2:
	if index == facing_index and combat_stage != null:
		return combat_stage.global_position + combat_stage.size * 0.5
	if wheel_view:
		return wheel_view.slice_portrait_global(index)
	return Vector2.ZERO


func _walker_depart(index: int) -> void:
	_walker_busy = true
	if wheel_view:
		wheel_view.portrait_away = index
	if index == facing_index and combat_stage:
		combat_stage.visible = false


func _walker_restore(index: int) -> void:
	if _courier:
		_courier.visible = false
		_clear_courier_gear()
		_courier.flip_h = false
		_courier.size = Vector2(96, 96)
		_courier.scale = Vector2.ONE
	if wheel_view:
		wheel_view.portrait_away = -1
	if combat_stage != null and phase == "fighting" and facing_index == index and facing_index >= 0:
		combat_stage.visible = true
	_walker_busy = false


func _monster_run_frames(card_id: String) -> Array:
	if art:
		return art.monster_run(card_id)
	return []


func _monster_walk_to(index: int, card_id: String, dest: Vector2) -> Vector2:
	var from: Vector2 = _walker_origin(index)
	_walker_depart(index)
	await _walk_courier(_monster_run_frames(card_id), from, dest, 0.55, false)
	return from


func _monster_walk_back(index: int, card_id: String, home: Vector2) -> void:
	var here: Vector2 = home
	if _courier != null and _courier.visible:
		here = _courier.global_position + _courier.pivot_offset
	var back: Vector2 = home
	if back == Vector2.ZERO:
		back = _walker_home(index)
	await _walk_courier(_monster_run_frames(card_id), here, back, 0.48, true)
	_walker_restore(index)


func _walk_courier(frames: Array, from: Vector2, to: Vector2, dur: float, hide_at_end: bool = true) -> void:
	if _courier == null or frames.is_empty() or from == Vector2.ZERO:
		await get_tree().create_timer(0.08).timeout
		return
	_courier.texture = frames[0]
	_courier.size = Vector2(168, 128)
	_courier.pivot_offset = Vector2(84, 64)
	_courier.scale = Vector2.ONE
	_courier.modulate.a = 1.0
	_courier.flip_h = to.x < from.x
	_courier.global_position = from - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("cloth", -8.0)
		sfx.play("whoosh", -12.0, 0.85)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_courier, "global_position", to - _courier.pivot_offset, dur)
	var fi: int = 0
	await get_tree().process_frame
	while tw.is_running():
		fi = (fi + 1) % frames.size()
		_courier.texture = frames[fi]
		await get_tree().create_timer(0.07).timeout
	if hide_at_end:
		_courier.visible = false
		_courier.flip_h = false
		_courier.size = Vector2(96, 96)
		_courier.scale = Vector2.ONE


func _bleed_begin() -> void:
	_bleed_hold += 1


func _bleed_end() -> void:
	_bleed_hold = maxi(0, _bleed_hold - 1)


func _cleric_maybe_flush() -> void:
	pass


func _missing_hp() -> int:
	return maxi(0, HP_MAX - hp)


func _living_clerics() -> Array[int]:
	var out: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "cleric":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		out.append(i)
	return out


func _cleric_after_spin() -> void:
	if hp <= 0 or phase != "fighting":
		return
	var seats: Array[int] = _living_clerics()
	if seats.is_empty():
		return
	for i in seats:
		if hp <= 0 or phase != "fighting":
			return
		if _missing_hp() < 3:
			return
		if i < 0 or i >= wheel.size():
			continue
		if str(wheel[i].get("card_id", "")) != "cleric":
			continue
		if _is_silenced(wheel[i]) or int(wheel[i].get("hp", 0)) <= 0:
			continue
		await _cleric_play(i)


func _cleric_play(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	_walker_busy = true
	_sync_buttons()
	await _announce_slice(index, _hub_hp_pos())
	if wheel_view:
		wheel_view.aura_index = index
	if sfx:
		sfx.play_event(&"mon.cleric_tax")
	if get_tree():
		await get_tree().create_timer(0.7).timeout
	if wheel_view:
		wheel_view.aura_index = -1
	if _worst_item_uid() < 0:
		await _cleric_refuse(index)
		_walker_busy = false
		_refresh()
		return
	var from: Vector2 = Vector2.ZERO
	var hearts: Vector2 = Vector2.ZERO
	if wheel_view:
		from = wheel_view.slice_portrait_global(index)
		hearts = wheel_view.hub_hearts_global()
	var light: Texture2D = null
	if art != null:
		light = art.vfx.get("magic", art.vfx.get("star", null))
	if light != null and from != Vector2.ZERO:
		await _fly_courier(light, from, hearts, 0.34)
	_heal(3)
	_log("on_spin", "Health Insurance Heal 3  →  %s" % hp)
	var uid: int = _worst_item_uid()
	if uid < 0:
		_walker_busy = false
		_refresh()
		return
	var dest: Vector2 = _item_card_global(uid)
	if dest == Vector2.ZERO:
		dest = hearts
	var home: Vector2 = await _monster_walk_to(index, "cleric", dest)
	_toss_item(uid, false)
	_log("on_spin", "Cleric took worst item")
	_refresh()
	await _monster_walk_back(index, "cleric", home)
	_refresh()


func _cleric_refuse(index: int) -> void:
	_cleric_line = "Wait, you don't have anything to pay. No healing for you."
	_cleric_talk_index = index
	_place_speech()
	if sfx:
		sfx.play("error", -10.0, 0.9)
	var from: Vector2 = _slice_from(index)
	var hearts: Vector2 = _hub_hp_pos()
	var light: Texture2D = null
	if art != null:
		light = art.vfx.get("magic", art.vfx.get("star", null))
	if light != null and from != Vector2.ZERO and hearts != Vector2.ZERO:
		await _cleric_yank_light(light, from, hearts)
	elif get_tree():
		await get_tree().create_timer(0.35).timeout
	_hearts_deny_shake()
	_flash_screen(Color("c45c5c"), 0.2)
	if get_tree():
		await get_tree().create_timer(1.4).timeout
	_cleric_line = ""
	_cleric_talk_index = -1
	if speech_box:
		speech_box.hide_speech()
	_log("on_spin", "Health Insurance refused — empty hand")


func _cleric_yank_light(tex: Texture2D, from: Vector2, to: Vector2) -> void:
	if _courier == null or tex == null or from == Vector2.ZERO:
		if get_tree():
			await get_tree().create_timer(0.08).timeout
		return
	_courier.texture = tex
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2.ONE
	_courier.modulate = Color.WHITE
	_courier.rotation = 0.0
	_courier.global_position = from - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("whoosh", -10.0, 1.1)
	var mid: Vector2 = from.lerp(to, 0.62)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(_courier, "global_position", mid - _courier.pivot_offset, 0.26)
	tw.parallel().tween_property(_courier, "scale", Vector2(0.72, 0.72), 0.26)
	await tw.finished
	if sfx:
		sfx.play("scratch", -8.0, 1.2)
		sfx.play("error", -12.0, 0.85)
	var tw2 := create_tween()
	tw2.set_trans(Tween.TRANS_BACK)
	tw2.set_ease(Tween.EASE_IN)
	tw2.tween_property(_courier, "global_position", from - _courier.pivot_offset, 0.32)
	tw2.parallel().tween_property(_courier, "scale", Vector2(0.12, 0.12), 0.32)
	tw2.parallel().tween_property(_courier, "modulate:a", 0.0, 0.32)
	tw2.parallel().tween_property(_courier, "rotation", 0.9, 0.32)
	await tw2.finished
	_courier.visible = false
	_courier.scale = Vector2.ONE
	_courier.modulate = Color.WHITE
	_courier.rotation = 0.0


func _worst_item_uid() -> int:
	var best: int = 999
	var cands: Array[int] = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		var t: int = int(it.get("pack_tier", 1))
		if str(it.get("card_id", "")) == "spider_egg":
			t = 0
		if t < best:
			best = t
			cands = [uid]
		elif t == best:
			cands.append(uid)
	if cands.is_empty():
		return -1
	return cands[rng.randi() % cands.size()]


func _item_card_global(uid: int) -> Vector2:
	if hotbar_box == null:
		return Vector2.ZERO
	var found: Control = null
	for c in hotbar_box.get_children():
		if int(c.get("uid")) == uid:
			found = c
			break
	if found == null:
		return Vector2.ZERO
	return _card_center(found)


func _card_center(c: Control) -> Vector2:
	var r: Rect2 = c.get_global_rect()
	if r.size.x >= 8.0 and r.size.y >= 8.0:
		return r.get_center()
	var sz: Vector2 = c.size
	if sz.x < 8.0 or sz.y < 8.0:
		sz = c.custom_minimum_size
	if sz.x < 8.0 or sz.y < 8.0:
		sz = Vector2(118.0, 162.0)
	return c.global_position + sz * 0.5


func _item_card_global_by_id(card_id: String) -> Vector2:
	if hotbar_box == null or card_id == "":
		return Vector2.ZERO
	for c in hotbar_box.get_children():
		if str(c.get("card_id")) == card_id:
			return _card_center(c)
	return Vector2.ZERO


func _keep_blocked_now() -> bool:
	if keep_blocked_this_fight:
		return true
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var id: String = str(wheel[facing_index].get("card_id", ""))
	return id == "basilisk" and not _is_silenced(id)


func _is_silenced(who) -> bool:
	if typeof(who) == TYPE_DICTIONARY:
		var s: Dictionary = who
		if bool(s.get("silenced", false)):
			return true
		return bool(silenced.get(str(s.get("card_id", "")), false))
	return bool(silenced.get(str(who), false))


func _has_unique_ability(id: String) -> bool:
	if MONSTER_SPECIAL.has(id):
		return true
	match id:
		"ogre", "dire_wolf", "bandit", "berserker", "skeleton", "slime_boss", "leech_league", "clockwork_knight":
			return true
	return false


func _gain_blk(n: int, skip_twins: bool = false) -> int:
	if n <= 0:
		_refresh_blk(false)
		return 0
	if not skip_twins and _twins_double_blk(n):
		var a: int = _gain_blk(n, true)
		var b: int = _gain_blk(n, true)
		return a + b
	last_blk_gain = n
	blk += n
	_refresh_blk(true)
	_punch_blk()
	if sfx:
		if n >= 4:
			sfx.play_event(&"blk.gain_big", {"n": n})
		else:
			sfx.play_event(&"blk.gain", {"n": n})
	return n


func _heal(n: int) -> int:
	var before: int = hp
	hp = mini(HP_MAX, hp + maxi(0, n))
	var gained: int = hp - before
	_log("hp", "heal %s  →  %s" % [gained, hp])
	if gained <= 0:
		return 0
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("heal")
		if wheel_view.has_method("wait_hero_frame"):
			await wheel_view.wait_hero_frame("heal", 2)
	_refresh_hearts()
	_flash_screen(Color("8fd18f"), 0.28)
	if sfx:
		sfx.play_event(&"heal.gain", {"n": gained})
	_glow_hearts_heal()
	_sync_dire_wolves()
	return gained


func _bleed(n: int) -> bool:
	if n <= 0:
		return false
	var before: int = hp
	hp = maxi(0, hp - n)
	if hp < before:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
	_log("hp", "bleed %s  →  %s" % [n, hp])
	_flash_screen(Color("5c1a6a"), 0.38)
	_refresh_hearts()
	_tint_hearts_bleed()
	if combat_stage:
		combat_stage.play_bleed()
	if sfx:
		sfx.play("bleed", -4.0)
		sfx.play("cloth", -14.0, 0.75)
	if get_tree():
		await get_tree().create_timer(0.38).timeout
	if hp < before:
		await _hurt_ogres(before - hp)
		await _grow_vampires()
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
	if hp != before and hp > 0:
		await _sync_dire_wolves()
	if _bleed_losses > 0:
		await _cleric_maybe_flush()
	return false


func _item_snapshot(it: Dictionary) -> Dictionary:
	var ops: Dictionary = {}
	var raw: Variant = it.get("ops", {})
	if typeof(raw) == TYPE_DICTIONARY and not (raw as Dictionary).is_empty():
		ops = (raw as Dictionary).duplicate(true)
	else:
		var oid: String = str(it.get("card_id", ""))
		if ITEM_OPS.has(oid):
			ops = (ITEM_OPS[oid] as Dictionary).duplicate(true)
	return {
		"card_id": str(it.get("card_id", "")),
		"name": str(it.get("name", "")),
		"ability": str(it.get("ability", "")),
		"explainer": str(it.get("explainer", "")),
		"ops": ops,
	}


func _echo_face(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) != "echo_bell":
		return it
	var copy: Variant = it.get("echo_copy", last_item_copy)
	if typeof(copy) == TYPE_DICTIONARY and not (copy as Dictionary).is_empty():
		return copy
	return {}


func _remember_item_use(it: Dictionary) -> void:
	var snap: Dictionary = _item_snapshot(it)
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			snap = _item_snapshot(face) if face.has("uid") else face.duplicate(true)
			if not snap.has("ops"):
				snap = face.duplicate(true)
	if str(snap.get("card_id", "")) == "echo_bell" or snap.is_empty():
		return
	last_item_copy = snap.duplicate(true)
	for e in hotbar:
		if str(e.get("card_id", "")) != "echo_bell":
			continue
		if int(e.get("uid", -1)) == int(it.get("uid", -2)):
			continue
		e["echo_copy"] = last_item_copy.duplicate(true)


func _after_item_resolved(it: Dictionary) -> void:
	if it.is_empty() or not bool(it.get("spent", false)):
		return
	_remember_item_use(it)
	if phase != "fighting":
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		return
	var hid: String = str(wheel[facing_index].get("card_id", ""))
	if hid == "harpy" and not _is_silenced(hid):
		await _harpy_poke()


func _harpy_poke() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "harpy" or _is_silenced("harpy"):
		return
	if int(m.get("hp", 0)) <= 0:
		return
	_walker_busy = true
	_sync_buttons()
	_trace_resolve("harpy poke")
	await _announce_slice(facing_index, _hub_hp_pos())
	if phase != "fighting" or facing_index < 0:
		_walker_busy = false
		_sync_buttons()
		return
	m = wheel[facing_index]
	await _owner_attack(m)
	_walker_busy = false
	_sync_buttons()
	if hp <= 0:
		_player_down()


func _clear_petrify() -> void:
	for it in hotbar:
		it["petrified"] = false


func _item_atk_score(it: Dictionary) -> int:
	if bool(it.get("petrified", false)) or bool(it.get("spent", false)):
		return -1
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind.begins_with("atk") or kind == "choose":
		if kind == "choose":
			var best: int = -1
			var opts: Variant = ops.get("options", [])
			if typeof(opts) == TYPE_ARRAY:
				for opt in opts:
					if typeof(opt) != TYPE_DICTIONARY:
						continue
					var o: Dictionary = opt
					if not o.has("atk"):
						continue
					var a: int = int(o.get("atk", 0))
					if a > best:
						best = a
			if best < 0:
				return -1
			return _atk_with_head(best)
		return _atk_with_head(int(_item_view(it).get("n", 0)))
	return -1


func _petrify_best_atk() -> void:
	if _is_silenced("gargoyle"):
		return
	var best: int = -1
	var picks: Array = []
	for it in hotbar:
		var sc: int = _item_atk_score(it)
		if sc < 0:
			continue
		if sc > best:
			best = sc
			picks = [it]
		elif sc == best:
			picks.append(it)
	if picks.is_empty():
		_log("on_spin", "petrify none")
		return
	var pick: Dictionary = picks[rng.randi() % picks.size()]
	pick["petrified"] = true
	_log("on_spin", "petrify %s" % str(pick.get("name", "?")))
	if facing_index >= 0:
		await _announce_slice(facing_index, _item_card_global(int(pick.get("uid", -1))))
	if sfx:
		sfx.play_event(&"status.petrify")


func _cube_ask_feed() -> void:
	if _is_silenced("gelatinous_cube"):
		return
	if hotbar.is_empty():
		_log("on_spin", "cube ate nothing")
		return
	var ids: Array = []
	for it in hotbar:
		ids.append(int(it.get("uid", -1)))
	ids.shuffle()
	var offer: Array = []
	offer.append(ids[0])
	if ids.size() >= 2:
		offer.append(ids[1])
	pending_feed = {"uids": offer}
	if offer.size() >= 2:
		_cube_line = "I chose these two. Feed me one."
	else:
		_cube_line = "That's all you've got. Feed me."
	_log("on_spin", "cube demands a feed")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play("cloth", -12.0)


func _merchant_ask() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if _is_silenced(wheel[facing_index]):
		return
	if hotbar.is_empty():
		_log("on_spin", "merchant no items")
		return
	var ids: Array = _merchant_legal_uids()
	if ids.is_empty():
		_log("on_spin", "merchant no upgrade")
		return
	pending_feed = {"uids": ids, "kind": "upgrade"}
	_cube_line = "Pick an item. I will upgrade it."
	_log("on_spin", "merchant offers an upgrade")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play("pluck", -10.0)
		sfx.play_event(&"mon.merchant_ask")
	_refresh()


func _stored_item_tier(it: Dictionary) -> int:
	var card: Dictionary = items_by_id.get(str(it.get("card_id", "")), {})
	if card.has("tier"):
		return int(card.get("tier", 0))
	return int(it.get("pack_tier", 1))


func _upgrade_dest_tier(stored: int) -> int:
	return stored + 1 if stored < 3 else 3


func _upgrade_pool(dest_tier: int) -> Array:
	var held: Dictionary = _challenge_held_counts()
	var out: Array = []
	for id in item_pool:
		var sid: String = str(id)
		var card: Dictionary = items_by_id.get(sid, {})
		if card.is_empty():
			continue
		if int(card.get("tier", 1)) != dest_tier:
			continue
		var status: String = str(card.get("status", "live"))
		if status == "retired" or status == "hold":
			continue
		var cap: int = maxi(0, int(card.get("count", 1)))
		if int(held.get(sid, 0)) >= cap:
			continue
		out.append(sid)
	return out


func _merchant_legal_uids() -> Array:
	var ids: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if bool(it.get("spent", false)):
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		if _upgrade_pool(_upgrade_dest_tier(_stored_item_tier(it))).is_empty():
			continue
		ids.append(uid)
	return ids


func _upgrade_item(uid: int) -> void:
	if pending_feed.is_empty() or str(pending_feed.get("kind", "")) != "upgrade":
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		return
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		pending_feed = {}
		_cube_line = ""
		_refresh()
		return
	var dest: int = _upgrade_dest_tier(_stored_item_tier(it))
	var pool: Array = _upgrade_pool(dest)
	if pool.is_empty():
		_log("on_spin", "no upgrade for %s" % str(it.get("name", "?")))
		if sfx:
			sfx.play("error", -10.0)
		var rest: Array = _merchant_legal_uids()
		if rest.is_empty():
			pending_feed = {}
			_cube_line = ""
		else:
			pending_feed = {"uids": rest, "kind": "upgrade"}
		_refresh()
		return
	var new_id: String = str(pool[rng.randi() % pool.size()])
	item_pool.erase(new_id)
	pending_feed = {}
	_cube_line = ""
	var fresh: Dictionary = _make_item(new_id)
	for i in hotbar.size():
		if int(hotbar[i].get("uid", -1)) == uid:
			hotbar[i] = fresh
			break
	_log("on_spin", "upgrade %s → %s" % [str(it.get("name", "?")), str(fresh.get("name", new_id))])
	_refresh()
	await _play_item_transform(int(fresh.get("uid", uid)))
	_undo_arm()
	_refresh()


func _feed_cube(uid: int) -> void:
	if pending_feed.is_empty():
		return
	if str(pending_feed.get("kind", "")) == "upgrade":
		await _upgrade_item(uid)
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		return
	pending_feed = {}
	var dest: Vector2 = _item_card_global(uid)
	if dest == Vector2.ZERO:
		dest = _hotbar_empty_slot_global()
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	_walker_busy = true
	_refresh()
	var seat: int = facing_index
	var home: Vector2 = Vector2.ZERO
	if seat >= 0:
		home = await _monster_walk_to(seat, "gelatinous_cube", dest)
	var it: Dictionary = _find_item(uid)
	_log("on_spin", "cube ate %s" % str(it.get("name", "?")))
	if sfx:
		sfx.play_event(&"mon.cube_feed")
	_toss_item(uid, false)
	_cube_line = ["Mmm. Thank you.", "Gone. Delicious.", "Thanks. I needed that."][rng.randi() % 3]
	_refresh()
	if seat >= 0:
		await _monster_walk_back(seat, "gelatinous_cube", home)
	else:
		_walker_busy = false
	_undo_arm()
	_refresh()


func _spawn_clockwork_heirs() -> void:
	var pool: Array = []
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		if _as_int(card.get("tier", 1), 1) != 2:
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		pool.append(str(id))
	if pool.is_empty():
		for id2 in monsters_by_id.keys():
			var c2: Dictionary = monsters_by_id[id2]
			if _as_int(c2.get("tier", 1), 1) == 2:
				pool.append(str(id2))
	if pool.is_empty():
		return
	for _i in 2:
		var pick: String = str(pool[rng.randi() % pool.size()])
		var heir: Dictionary = _make_monster(pick)
		heir["slot"] = ""
		wheel.append(heir)
		_log("on_place", "Clockwork left %s" % heir.get("name", pick))
	_reseat_slots()
	if sfx:
		sfx.play_event(&"mon.clockwork_spawn")


func _count_item_use() -> void:
	items_used_this_combat += 1
	beads_step = (beads_step % 4) + 1
	_log("var", "items this combat %s" % items_used_this_combat)
	_flip_alt_sais()
	_sync_wheel_stats()


func _deal_atk(n: int) -> bool:
	return await _deal_atk_at(facing_index, n)


func _is_arrow_head(it: Dictionary) -> bool:
	if it.is_empty() or bool(it.get("spent", false)):
		return false
	if str(it.get("card_id", "")) == "arrow_head":
		return true
	if str(it.get("card_id", "")) != "echo_bell":
		return false
	var copy: Variant = it.get("echo_copy", {})
	return typeof(copy) == TYPE_DICTIONARY and str((copy as Dictionary).get("card_id", "")) == "arrow_head"


func _arrow_head_bonus() -> int:
	var n: int = 0
	for it in hotbar:
		if _is_arrow_head(it):
			n += 1
	return n


func _hand_pierce() -> bool:
	return _arrow_head_bonus() > 0


func _kind_deals_atk(kind: String) -> bool:
	if kind == "atk_zero" or kind == "atk_drop":
		return false
	return kind.begins_with("atk") or kind == "egg_hurt"


func _atk_with_head(n: int) -> int:
	return n + _arrow_head_bonus()


func _is_magnet(it: Dictionary) -> bool:
	if it.is_empty() or bool(it.get("spent", false)):
		return false
	if str(_ops_of(it).get("kind", "")) == "magnet":
		return true
	if str(it.get("card_id", "")) == "danger_magnet":
		return true
	if str(it.get("card_id", "")) != "echo_bell":
		return false
	var copy: Variant = it.get("echo_copy", {})
	return typeof(copy) == TYPE_DICTIONARY and str((copy as Dictionary).get("card_id", "")) == "danger_magnet"


func _magnet_mode_of(it: Dictionary) -> String:
	var mode: String = str(it.get("magnet_mode", "off"))
	if mode != "high" and mode != "low":
		return "off"
	return mode


func _armed_magnet_mode() -> String:
	var best_seq: int = -1
	var mode: String = ""
	for it in hotbar:
		if not _is_magnet(it):
			continue
		var m: String = _magnet_mode_of(it)
		if m == "off":
			continue
		var seq: int = int(it.get("magnet_seq", 0))
		if seq >= best_seq:
			best_seq = seq
			mode = m
	return mode


func _magnet_pick(pool: Array[int], want_high: bool) -> int:
	if pool.is_empty():
		return 0
	var best: int = int(wheel[pool[0]].get("atk", 0))
	for i in pool:
		var a: int = int(wheel[i].get("atk", 0))
		if want_high:
			if a > best:
				best = a
		elif a < best:
			best = a
	var tied: Array[int] = []
	for j in pool:
		if int(wheel[j].get("atk", 0)) == best:
			tied.append(j)
	if tied.is_empty():
		return pool[0]
	return tied[rng.randi_range(0, tied.size() - 1)]


func _set_magnet_mode(it: Dictionary, oid: String) -> void:
	if oid != "high" and oid != "low":
		it["magnet_mode"] = "off"
		_log("on_item_use", "magnet off")
		return
	_magnet_seq += 1
	it["magnet_mode"] = oid
	it["magnet_seq"] = _magnet_seq
	await _announce_item_use(it, _hub_hp_pos())
	_log("on_item_use", "magnet %s" % oid)
	if sfx:
		sfx.play_event(&"util.magnet")
	_remember_item_use(it)
	if phase == "fighting":
		await _count_item_use()
		await _harpy_poke()


func _consume_armed_magnets(mode: String) -> void:
	if mode != "high" and mode != "low":
		return
	var gone: Array = []
	for it in hotbar:
		if not _is_magnet(it):
			continue
		if _magnet_mode_of(it) != mode:
			continue
		gone.append(int(it.get("uid", -1)))
	for uid in gone:
		var it: Dictionary = _find_item(int(uid))
		if it.is_empty():
			continue
		it["spent"] = true
		it["keep_after"] = false
		_toss_item(int(it["uid"]), false)
		_log("discard", str(it.get("name", "Danger Magnet")))


func _pulse_arrow_heads() -> void:
	if hotbar_box == null:
		return
	for c in hotbar_box.get_children():
		if not c.has_method("bounce"):
			continue
		var it: Dictionary = _find_item(int(c.uid))
		if _is_arrow_head(it):
			c.bounce()
			if c.has_method("set_aura"):
				c.set_aura(true)


func _right_monster(index: int) -> int:
	var n: int = wheel.size()
	if n < 2 or index < 0 or index >= n:
		return -1
	var j: int = posmod(index + 1, n)
	if j == index:
		return -1
	if str(wheel[j].get("kind", "")) != "monster":
		return -1
	if int(wheel[j].get("hp", 0)) <= 0:
		return -1
	return j


func _living_id(index: int, id: String) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if str(wheel[index].get("kind", "")) != "monster":
		return false
	if int(wheel[index].get("hp", 0)) <= 0:
		return false
	if str(wheel[index].get("card_id", "")) != id:
		return false
	return not _is_silenced(wheel[index])


func _next_bodyguard(current: int, used: Dictionary) -> int:
	var n: int = wheel.size()
	if n < 2 or current < 0 or current >= n:
		return -1
	for dir in [1, -1]:
		var j: int = posmod(current + int(dir), n)
		if j == current or used.has(j):
			continue
		if _living_id(j, "bodyguard"):
			return j
	return -1


## Each Bodyguard once, to the end of that line.
func _plan_redirect(aim: int, n: int) -> Dictionary:
	var path: Array = [aim]
	var current: int = aim
	var fizzle := false
	var used := {}
	if _living_id(current, "bodyguard"):
		used[current] = true
	var stepping := true
	while stepping:
		stepping = false
		var nxt: int = _next_bodyguard(current, used)
		if nxt >= 0:
			used[nxt] = true
			current = nxt
			path.append(current)
			stepping = true
	var amount: int = n
	var moved: bool = current != aim
	if not fizzle and moved and _twins_double_atk(aim, n):
		amount = n * 2
	return {"final": current, "amount": amount, "path": path, "fizzle": fizzle, "moved": moved}


func _telegraph_pass(path: Array) -> void:
	if path.size() < 2:
		return
	for i in path.size():
		var idx: int = int(path[i])
		if idx < 0 or idx >= wheel.size():
			continue
		if i > 0:
			var nxt: int = int(path[mini(i + 1, path.size() - 1)])
			await _announce_slice(idx, _slice_from(nxt) if nxt != idx else _slice_hp_pos(idx))
		if wheel_view:
			wheel_view.hit_feedback(idx, 0)
			wheel_view.pulse_arrive(idx)
		if sfx and i < path.size() - 1:
			sfx.play("whoosh", -14.0, 1.05 + float(i) * 0.06)
		if i < path.size() - 1 and get_tree():
			await get_tree().create_timer(0.14).timeout


func _deal_atk_at(index: int, n: int, skip_twins: bool = false, skip_redirect: bool = false, head_done: bool = false) -> bool:
	if _hero_swipe_armed:
		_hero_swipe_armed = false
		if wheel_view and wheel_view.has_method("play_hero"):
			wheel_view.play_hero("swipe")
			if wheel_view.has_method("wait_hero_frame"):
				await wheel_view.wait_hero_frame("swipe", 2)
	if not head_done:
		n = _atk_with_head(n)
		head_done = true
	last_item_atk = n
	if index < 0 or index >= wheel.size():
		return false
	if not skip_redirect:
		var plan: Dictionary = _plan_redirect(index, n)
		if bool(plan.get("fizzle", false)) or bool(plan.get("moved", false)):
			await _telegraph_pass(plan.get("path", []))
		if bool(plan.get("fizzle", false)):
			last_atk_index = -1
			last_atk_line = "0  →  no target"
			if sfx:
				sfx.play("glass", -8.0, 0.85)
			return false
		if bool(plan.get("moved", false)):
			var landed: int = int(plan.get("final", index))
			var amount: int = int(plan.get("amount", n))
			var already_doubled: bool = amount != n
			var land_twins: bool = _twins_double_atk(landed, n) and not already_doubled
			return await _deal_atk_at(landed, amount, not land_twins, true, true)
	if not skip_twins and _twins_double_atk(index, n):
		if await _deal_atk_at(index, n, true, true, true):
			return true
		if index < 0 or index >= wheel.size():
			return false
		return await _deal_atk_at(index, n, true, true, true)
	var m: Dictionary = wheel[index]
	var hit_n: int = n
	var cut_chip: bool = false
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced("anvil") and hit_n > 0:
		if hit_n > 1:
			cut_chip = true
		hit_n = 1
	var immune: bool = str(m.get("card_id", "")) == "goblin" and not _is_silenced("goblin")
	last_atk_index = index
	if cut_chip:
		await _announce_slice(index, _slice_hp_pos(index))
	if immune or hit_n <= 0:
		if immune:
			_log("var", "no ATK dmg")
			await _announce_slice(index, _slice_hp_pos(index))
			last_atk_line = "0  →  %s immune" % m.get("name", "Goblin")
		else:
			last_atk_line = "0  →  %s HP %s" % [m.get("name", "?"), m.get("hp", 0)]
			_log("atk", last_atk_line)
		if sfx:
			sfx.play("glass", -8.0, 0.85)
		if wheel_view:
			wheel_view.hit_feedback(index, 0, 0)
		if combat_stage and index == facing_index:
			combat_stage.take_hit()
		return false
	var before_hp: int = int(m.get("hp", 0))
	var before_atk: int = int(m.get("atk", 0))
	m["hp"] = maxi(0, before_hp - hit_n)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m
	last_atk_line = "%s  →  %s HP %s" % [hit_n, m.get("name", "?"), m.get("hp", 0)]
	if sfx:
		var hit_ctx := {"card_id": str(m.get("card_id", "")), "dmg": hit_n, "tier": _tier_of(m), "monster_id": str(m.get("card_id", ""))}
		sfx.play_event(sfx.resolve(&"hit", hit_ctx), hit_ctx)
		sfx.play_event(sfx.resolve(&"hurt", hit_ctx), hit_ctx)
	if wheel_view:
		if cut_chip:
			await wheel_view.play_hp_ticks(index, before_hp, int(m["hp"]))
		else:
			wheel_view.hit_feedback(index, before_hp - int(m["hp"]), int(m["atk"]) - before_atk)
	if combat_stage and index == facing_index:
		combat_stage.take_hit()
	if before_hp > int(m["hp"]) and int(m["hp"]) > 0:
		if await _coward_after_hp_loss(index):
			return true
	if str(m.get("card_id", "")) == "needleback" and not _is_silenced("needleback") and before_hp > 0:
		if _watch_skip_thorns:
			pass
		elif _watch_thorns_seat >= 0:
			var thorn_at: int = _watch_thorns_seat
			await _announce_slice(index, _slice_hp_pos(thorn_at))
			_watch_skip_thorns = true
			var poked: bool = await _deal_atk_at(thorn_at, 1, false, false, true)
			_watch_skip_thorns = false
			if poked:
				return true
		else:
			await _announce_slice(index, _hub_hp_pos())
			if await _player_take_atk(1):
				return true
	return false


func _coward_after_hp_loss(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "cowardly_king":
		return false
	if _is_silenced(s):
		return false
	if int(s.get("hp", 0)) <= 0:
		return false
	await _announce_slice(index, _hub_hp_pos())
	var atk_n: int = int(s.get("atk", 0))
	if index == facing_index:
		await _owner_attack(s)
		if hp <= 0:
			_player_down()
			return true
	elif await _player_take_atk(atk_n):
		return true
	if index != facing_index:
		return false
	await _flee_spin()
	return true


func _flee_spin(_shuffle: bool = false) -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_mark.clear()
	pending_chaos.clear()
	pending_feed = {}
	_hide_hypno()
	if wheel_view:
		wheel_view.clear_slay()
	_refresh()
	if combat_stage:
		await combat_stage.vanish()
	if facing_index >= 0 and facing_index < wheel.size():
		var s: Dictionary = wheel[facing_index]
		s["spin_locked"] = false
		wheel[facing_index] = s
		last_mob_atk = int(s.get("atk", 0))
	if adventure:
		await _challenge_flee_cleanup()
	else:
		await _remove_crossbowed()
	_discard_spent_items()
	blk = 0
	_log("var", "BLK 0")
	facing_index = -1
	_sync_wheel_stats()
	if not adventure:
		await _slay_pending_ogres()
	phase = "ready"
	_walker_busy = false
	if _monsters_left() == 0:
		_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	if in_tutorial:
		call_deferred("_tutorial_after_fight")
		return
	if adventure:
		return
	_flee_random_spin = true
	call_deferred("_maybe_auto_spin")


func _player_take_atk(n: int) -> bool:
	var dummy := {"atk": n, "card_id": ""}
	var swing: Dictionary = _swing(dummy, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	hp = maxi(0, hp - incoming)
	if incoming > 0:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
	if incoming == 0:
		_log("hp", "poke 0")
		_refresh_blk(false)
		if sfx:
			sfx.play("glass", -10.0)
	else:
		_log("hp", "poke %s  →  %s" % [incoming, hp])
		_flash_screen(Color("e07a7a"), 0.22)
		_refresh_hearts()
		_refresh_blk(false)
		if sfx:
			sfx.play_event(&"player.poke")
		await _hurt_ogres(incoming)
		await _grow_vampires()
		if hp > 0:
			await _sync_dire_wolves()
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
	if incoming > 0:
		await _cleric_maybe_flush()
	return false


func _opposite_index() -> int:
	var n: int = wheel.size()
	if n < 2 or n % 2 != 0 or facing_index < 0:
		return -1
	return (facing_index + (n >> 1)) % n


func _cleave_targets() -> Array[int]:
	var seen := {}
	var out: Array[int] = []
	if facing_index >= 0:
		seen[facing_index] = true
		out.append(facing_index)
	for j in _neighbor_indices():
		if seen.has(j):
			continue
		seen[j] = true
		out.append(j)
	return out


func _apply_cleave(n: int) -> bool:
	n = _atk_with_head(n)
	var targets: Array[int] = _cleave_targets()
	var plans: Array = []
	for t in targets:
		if t < 0 or t >= wheel.size():
			continue
		plans.append(_plan_redirect(t, n))
	var touched: Array[int] = []
	for plan in plans:
		if bool(plan.get("fizzle", false)) or bool(plan.get("moved", false)):
			await _telegraph_pass(plan.get("path", []))
		if bool(plan.get("fizzle", false)):
			last_atk_index = -1
			last_atk_line = "0  →  no target"
			_log("atk", last_atk_line)
			if sfx:
				sfx.play("glass", -8.0, 0.85)
			continue
		var landed: int = int(plan.get("final", -1))
		var amount: int = int(plan.get("amount", n))
		var already_doubled: bool = amount != n
		var land_twins: bool = _twins_double_atk(landed, n) and not already_doubled
		if await _deal_atk_at(landed, amount, not land_twins, true, true):
			return true
		_log("atk", last_atk_line)
		if landed >= 0:
			touched.append(landed)
	var dead: Array[int] = []
	var seen_dead := {}
	for t in touched:
		if seen_dead.has(t) or t == facing_index:
			continue
		seen_dead[t] = true
		if t >= 0 and t < wheel.size() and int(wheel[t].get("hp", 0)) <= 0:
			dead.append(t)
	dead.sort()
	dead.reverse()
	for t2 in dead:
		if t2 < 0 or t2 >= wheel.size() or t2 == facing_index:
			continue
		if int(wheel[t2].get("hp", 0)) <= 0:
			await _maybe_slay_down(t2)
	last_atk_index = -1
	return false


func _weakest_neighbor_atk() -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	var vals: Array[int] = []
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if str(wheel[j].get("kind", "")) == "monster":
			vals.append(int(wheel[j].get("atk", 0)))
	if vals.is_empty():
		return -1
	var best: int = vals[0]
	for v in vals:
		best = mini(best, v)
	return best


func _strongest_neighbor_atk() -> int:
	if facing_index < 0:
		return -1
	var n: int = wheel.size()
	if n < 2:
		return -1
	var vals: Array[int] = []
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if str(wheel[j].get("kind", "")) == "monster":
			vals.append(int(wheel[j].get("atk", 0)))
	if vals.is_empty():
		return -1
	var best: int = vals[0]
	for v in vals:
		best = maxi(best, v)
	return best


func _neighbor_indices() -> Array[int]:
	var out: Array[int] = []
	if facing_index < 0:
		return out
	var n: int = wheel.size()
	if n < 2:
		return out
	var seen := {}
	for off in [n - 1, 1]:
		var j: int = (facing_index + off) % n
		if seen.has(j):
			continue
		seen[j] = true
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out


func _mark_targets(kind: String) -> Array[int]:
	var out: Array[int] = []
	if kind == "hypnotize" or kind == "defeat_double_hp":
		for i in range(wheel.size()):
			if _can_mark(i, kind):
				out.append(i)
		return out
	for i in _neighbor_indices():
		if _can_mark(i, kind):
			out.append(i)
	return out


func _can_mark(index: int, kind: String) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if str(wheel[index].get("kind", "")) != "monster":
		return false
	if kind == "hypnotize":
		if index == facing_index:
			return false
		return int(wheel[index].get("hp", 0)) > 0
	if kind == "defeat_double_hp":
		if int(wheel[index].get("hp", 0)) <= 0:
			return false
		if _defeat_blocked(wheel[index]):
			return false
		return int(wheel[index].get("hp", 0)) == hp * 2
	if index == facing_index:
		return false
	if not _neighbor_indices().has(index):
		return false
	if kind == "mark_poison":
		return not bool(wheel[index].get("crossbowed", false))
	if kind == "mark_crossbow" or kind == "atk_neighbor":
		if str(wheel[index].get("card_id", "")) == "goblin":
			return false
		return int(wheel[index].get("hp", 0)) > 0
	if kind == "hook_swap":
		return int(wheel[index].get("hp", 0)) > 0
	return false


func _apply_mark(index: int) -> void:
	var kind: String = str(pending_mark.get("kind", ""))
	if not _can_mark(index, kind):
		if sfx:
			sfx.play("error", -10.0)
		return
	var it: Dictionary = _find_item(int(pending_mark.get("uid", -1)))
	pending_mark.clear()
	if it.is_empty() or bool(it.get("spent", false)):
		_undo_abort()
		call_deferred("_refresh")
		return
	await _announce_item_use(it, _slice_from(index) if index >= 0 else _hub_hp_pos())
	var token: int = _undo_gen
	if kind == "defeat_double_hp":
		await _apply_scythe(index, it, token)
		return
	if kind == "hypnotize":
		await _apply_hypnotize(index, it)
		return
	_bleed_begin()
	if kind == "hook_swap":
		var a: Dictionary = wheel[facing_index].duplicate(true)
		var b: Dictionary = wheel[index].duplicate(true)
		a["spin_locked"] = false
		b["spin_locked"] = true
		wheel[facing_index] = b
		wheel[index] = a
		it["spent"] = true
		await _count_item_use()
		_toss_item(int(it["uid"]), false)
		_log("on_item_use", "hook %s" % b.get("name", "?"))
		_sync_wheel_stats()
		_draw_unseen_item()
		if combat_stage:
			combat_stage.show_monster(str(wheel[facing_index].get("card_id", "")), int(wheel[facing_index].get("tier", 1)))
			_tune_combat_stage()
		if sfx:
			sfx.play_event(&"util.hook")
		await _after_item_resolved(it)
		await _bleed_end()
		if _undo_stale(token):
			return
		_undo_wall()
		call_deferred("_refresh")
		return
	if kind == "mark_poison":
		wheel[index]["poisoned"] = true
		_log("on_item_use", "poisoned %s" % wheel[index].get("name", "?"))
		it["spent"] = true
		await _count_item_use()
		_toss_item(int(it["uid"]), false)
		if sfx:
			sfx.play_event(&"status.poison")
		_sync_wheel_stats()
		await _after_item_resolved(it)
		await _bleed_end()
		if _undo_stale(token):
			return
		_undo_finish_item()
		call_deferred("_refresh")
		return
	var n: int = 4
	var ops: Dictionary = _ops_of(it)
	if ops.has("n"):
		n = int(ops["n"])
	if await _deal_atk_at(index, n):
		it["spent"] = true
		await _count_item_use()
		_toss_item(int(it["uid"]), false)
		await _after_item_resolved(it)
		await _bleed_end()
		if _undo_stale(token):
			return
		_undo_finish_item()
		return
	_log("on_item_use", "crossbow %s" % wheel[index].get("name", "?"))
	_log("atk", last_atk_line if last_atk_line != "" else "%s  →  %s HP %s" % [n, wheel[index].get("name", "?"), wheel[index].get("hp", 0)])
	it["spent"] = true
	await _count_item_use()
	_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()
	await _after_item_resolved(it)
	await _bleed_end()
	if _undo_stale(token):
		return
	_refresh()
	var shot_at: int = last_atk_index if last_atk_index >= 0 else index
	if shot_at >= 0 and shot_at < wheel.size() and int(wheel[shot_at].get("hp", 0)) <= 0:
		await _maybe_slay_down(shot_at)
		if _undo_stale(token):
			return
	_undo_finish_item()


func _hide_hypno() -> void:
	_hypno_src = -1
	_watch_thorns_seat = -1
	_watch_skip_thorns = false
	if hypno_stage:
		hypno_stage.hide_stage()
	if hypno_box:
		hypno_box.hide_plate()


func _refresh_hypno_box() -> void:
	if hypno_box == null:
		return
	if _hypno_src < 0 or _hypno_src >= wheel.size():
		hypno_box.hide_plate()
		return
	if str(wheel[_hypno_src].get("kind", "")) != "monster":
		hypno_box.hide_plate()
		return
	var m: Dictionary = wheel[_hypno_src]
	var rule: Dictionary = _monster_rule(m)
	hypno_box.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), "", str(rule.get("warn", "")), null, "monster", str(m.get("card_id", "")), _monster_plate_look(m, rule))


func _show_hypno(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	_hypno_src = index
	if hypno_stage:
		hypno_stage.show_monster(str(wheel[index].get("card_id", "")), int(wheel[index].get("tier", 1)))
	_refresh_hypno_box()
	_place_fight_art()


func _heal_monster(index: int, n: int) -> void:
	if index < 0 or index >= wheel.size() or n <= 0:
		return
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return
	var cap: int = int(m.get("hp_max", m.get("hp", 0)))
	var before: int = int(m.get("hp", 0))
	m["hp"] = mini(cap, before + n)
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m
	if int(m["hp"]) > before and sfx:
		sfx.play("pluck", -10.0)
	if wheel_view:
		wheel_view.hit_feedback(index, before - int(m["hp"]), 0)
	_refresh_face()


func _apply_scythe(index: int, it: Dictionary, token: int) -> void:
	if index < 0 or index >= wheel.size():
		_undo_abort()
		call_deferred("_refresh")
		return
	var m: Dictionary = wheel[index]
	if _defeat_blocked(m) or int(m.get("hp", 0)) != hp * 2 or int(m.get("hp", 0)) <= 0:
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		call_deferred("_refresh")
		return
	it["spent"] = true
	await _count_item_use()
	_log("on_item_use", str(it["name"]))
	_log("on_resolve", "defeat")
	if sfx:
		sfx.play("draw", -8.0)
	_toss_item(int(it["uid"]), false)
	if index == facing_index:
		await _begin_slay()
	elif await _try_commander_flee(index):
		pass
	else:
		await _kill_neighbor(index)
	if _undo_stale(token):
		return
	await _after_item_resolved(it)
	if _undo_stale(token):
		return
	_undo_finish_item()
	call_deferred("_refresh")


func _apply_hypnotize(src: int, it: Dictionary) -> void:
	if src < 0 or src >= wheel.size() or facing_index < 0 or facing_index >= wheel.size():
		_undo_abort()
		call_deferred("_refresh")
		return
	var dest: int = facing_index
	var snap: int = int(wheel[src].get("atk", 0))
	var hits: int = _hit_count(src)
	_log("on_item_use", "hypnotize %s" % wheel[src].get("name", "?"))
	if sfx:
		sfx.play_event(&"status.hypnotize")
	it["spent"] = true
	await _count_item_use()
	_toss_item(int(it["uid"]), false)
	_bleed_begin()
	_watch_thorns_seat = src
	_show_hypno(src)
	var watch: Texture2D = tex_by_item.get("pocketwatch", null)
	if art != null:
		var pix: Texture2D = art.item_tex("pocketwatch")
		if pix != null:
			watch = pix
	if hypno_stage:
		await hypno_stage.play_hypnotize(watch)
	await _watch_attack(src, dest, snap, hits, {})
	_watch_thorns_seat = -1
	_hide_hypno()
	_sync_wheel_stats()
	await _after_item_resolved(it)
	await _bleed_end()
	if hp <= 0:
		_undo_finish_item()
		return
	await _slay_dead_after_watch()
	_undo_finish_item()
	call_deferred("_refresh")


func _watch_attack(src: int, dest: int, snap: int, hits: int, used_damsels: Dictionary) -> void:
	if src < 0 or src >= wheel.size() or dest < 0 or dest >= wheel.size():
		return
	if int(wheel[dest].get("hp", 0)) <= 0:
		return
	var m: Dictionary = wheel[src]
	if str(m.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(m):
		if used_damsels.has(src):
			return
		used_damsels[src] = true
		for j in _damsel_neighbors(src):
			if dest < 0 or dest >= wheel.size() or int(wheel[dest].get("hp", 0)) <= 0:
				break
			var nb: Dictionary = wheel[j]
			if str(nb.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(nb):
				await _watch_attack(j, dest, int(nb.get("atk", 0)), _hit_count(j), used_damsels)
			else:
				_show_hypno(j)
				await _watch_hits(j, dest, int(nb.get("atk", 0)), _hit_count(j))
		if dest >= 0 and dest < wheel.size() and int(wheel[dest].get("hp", 0)) > 0:
			_heal_monster(dest, 3)
		if src >= 0 and src < wheel.size():
			_show_hypno(src)
		return
	_show_hypno(src)
	await _watch_hits(src, dest, snap, hits)


func _watch_hits(src: int, dest: int, atk: int, hits: int) -> void:
	for h in range(maxi(1, hits)):
		if dest < 0 or dest >= wheel.size():
			return
		if int(wheel[dest].get("hp", 0)) <= 0:
			return
		if hp <= 0:
			return
		if hypno_stage:
			await hypno_stage.lunge()
		if await _deal_atk_at(dest, atk, false, false, true):
			return
		if hits > 1 and h < hits - 1 and get_tree():
			await get_tree().create_timer(0.16).timeout


func _slay_dead_after_watch() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and str(wheel[i].get("kind", "")) == "monster" and int(wheel[i].get("hp", 0)) <= 0:
			await _maybe_slay_down(i)
		i -= 1
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
		await _maybe_slay_down(facing_index)


func _wheel_busy() -> bool:
	if _challenge_loot_wait:
		return true
	if challenge_draft_ui != null and challenge_draft_ui.visible:
		return true
	return _walker_busy or (wheel_view != null and wheel_view.busy) or _hypno_src >= 0


func _kill_neighbor(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if index == facing_index:
		return
	var pin: int = facing_index
	var m: Dictionary = wheel[index]
	await _wick_on_defeated(index)
	if str(m.get("card_id", "")) == "mimic" and not adventure:
		_draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		var nctx := {"tier": _tier_of(m), "monster_id": str(m.get("card_id", ""))}
		sfx.play_event(sfx.resolve(&"death", nctx), nctx)
	if wheel_view:
		await wheel_view.play_slay(index)
	if adventure:
		_challenge_vacate(index)
		_refresh()
		if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
			if not _wick_waiting(facing_index):
				await _maybe_slay_down(facing_index)
		return
	if wheel_view:
		await wheel_view.collapse_slice(index, pin)
	_log("on_remove_slice", str(m.get("name", "?")))
	wheel.remove_at(index)
	mobs_defeated += 1
	if index < pin:
		facing_index -= 1
	_reseat_slots()
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.set_slices(wheel, facing_index, "none")
		await wheel_view.recenter_on(facing_index)
	_refresh()
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
		if not _wick_waiting(facing_index):
			await _maybe_slay_down(facing_index)


func _remove_crossbowed() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and bool(wheel[i].get("crossbowed", false)) and str(wheel[i].get("kind", "")) == "monster":
			await _wick_on_defeated(i)
			_log("on_remove_slice", str(wheel[i]["name"]))
			wheel.remove_at(i)
			mobs_defeated += 1
			if i < facing_index:
				facing_index -= 1
		i -= 1
	_reseat_slots()


func _draw_unseen_item() -> void:
	if adventure and item_pool.is_empty():
		_challenge_reshuffle_items()
	if item_pool.is_empty():
		return
	var id: String = _take_card(item_pool, items_by_id, "", 0)
	if id == "" and adventure:
		_challenge_reshuffle_items()
		id = _take_card(item_pool, items_by_id, "", 0)
	if id == "":
		return
	var it: Dictionary = _make_item(id)
	if adventure and _hand_full():
		_challenge_pending_gain = it.duplicate(true)
		_challenge_loot_wait = true
		_flash_banner(PLAYER_COPY.text("challenge.full_hand", "Hand is full. Click an item to throw away."))
		_refresh()
		return
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	if sfx:
		sfx.play("open", -10.0)


func _try_potion() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "healing_potion":
			continue
		if bool(it.get("spent", false)):
			continue
		it["spent"] = true
		it["keep_after"] = false
		_log("on_item_use", "Healing Potion")
		_heal(3)
		_toss_item(int(it["uid"]), false)
		return true
	return false


func _swing(m: Dictionary, block_left: int) -> Dictionary:
	var atk_n: int = int(m.get("atk", 0))
	var cid: String = str(m.get("card_id", ""))
	var pierce: bool = false
	if cid == "dragon" and not _is_silenced("dragon"):
		pierce = true
	elif cid != "spider_egg" and _hand_pierce():
		pierce = true
	if pierce:
		return {"dmg": maxi(0, atk_n), "blk": block_left, "pierce": true}
	return {
		"dmg": maxi(0, atk_n - block_left),
		"blk": maxi(0, block_left - atk_n),
		"pierce": false,
	}


func _incoming_total() -> int:
	if skip_swing_this_fight:
		return 0
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(m):
		return _damsel_incoming()
	var left: int = blk
	var total: int = 0
	for _h in range(_hit_count(facing_index)):
		var swing: Dictionary = _swing(m, left)
		total += int(swing["dmg"])
		left = int(swing["blk"])
	return total


func _hit_count(index: int) -> int:
	if index < 0 or index >= wheel.size():
		return 1
	var id: String = str(wheel[index].get("card_id", ""))
	if _is_silenced(id):
		return 1
	if bool(wheel[index].get("swing_muted", false)):
		return 1
	if id == "hornet_swarm":
		return 2
	if id == "kobold_trapper":
		return 1 + items_used_this_combat
	return 1


func _item_view(it: Dictionary) -> Dictionary:
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var fighting: bool = phase == "fighting" and facing_index >= 0
	var m: Dictionary = wheel[facing_index] if fighting else {}
	var fill := Color("5c2626")
	var rim := _tier_metal(_tier_of(it))
	var out := {
		"kind": "ATK",
		"number": "—",
		"note": "",
		"n": 0,
		"can_use": fighting,
		"fill": fill,
		"rim": rim,
		"tip": str(it.get("ability", "")),
	}
	match kind:
		"blk":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk":
			out["n"] = int(ops.get("n", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"choose":
			out["kind"] = "ATK"
			var drop_v := false
			var copts_v: Variant = ops.get("options", [])
			if typeof(copts_v) == TYPE_ARRAY:
				for ov in copts_v:
					if typeof(ov) == TYPE_DICTIONARY and (ov as Dictionary).has("atk_drop"):
						drop_v = true
						break
			if drop_v:
				out["number"] = "1–3"
				out["n"] = 0
			elif str(it.get("card_id", "")) == "spiked_shield":
				out["n"] = 2
				out["number"] = "2"
			else:
				out["n"] = 3
				out["number"] = "3"
			out["note"] = ""
		"atk_alt_24":
			var alt: int = int(it.get("alt_n", 0))
			out["n"] = alt if alt == 2 or alt == 4 else (2 if items_used_this_combat % 2 == 0 else 4)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_from_hp":
			out["kind"] = "BLK"
			out["n"] = maxi(0, 6 - hp)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_min_hp":
			out["kind"] = "BLK"
			out["n"] = mini(hp, int(m.get("hp", hp))) if fighting else hp
			out["number"] = str(out["n"])
			out["note"] = ""
		"defeat_hp":
			out["kind"] = "DEFEAT"
			out["number"] = "Defeat"
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("hp", 99)) < hp
		"atk_7_hp":
			out["n"] = maxi(0, 7 - hp)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_neighbor":
			out["kind"] = "BLK"
			var side: String = str(ops.get("side", ""))
			if side == "":
				side = "right"
			# Left = clockwise. Right = counter-clockwise.
			var ccw: bool = side != "left"
			var nb: int = _directed_neighbor_atk(ccw) if fighting else -1
			out["n"] = nb
			out["number"] = "—" if nb < 0 else str(nb)
			out["note"] = ""
			out["can_use"] = fighting and nb >= 0
		"atk_7_items":
			out["n"] = maxi(0, 8 - _live_item_count())
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_2_kills":
			out["n"] = 2 + mobs_defeated
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_hp_loss":
			out["n"] = 2 * hp_loss_events
			out["number"] = str(out["n"])
			out["note"] = ""
		"defeat_atk":
			out["kind"] = "DEFEAT"
			out["number"] = "Defeat"
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("atk", 0)) >= 5
		"atk_last":
			out["n"] = last_mob_atk
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk_strong_neighbor":
			var nb2: int = _strongest_neighbor_atk() if fighting else -1
			out["n"] = nb2
			out["number"] = "—" if nb2 < 0 else str(nb2)
			out["note"] = ""
			out["can_use"] = fighting and nb2 >= 0
		"blk_keep":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
		"smoke":
			out["kind"] = "SMOKE"
			out["number"] = ""
			out["note"] = ""
		"fangs":
			out["kind"] = "FANGS"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _defeat_blocked(m)
		"mark_poison":
			out["kind"] = "MARK"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("mark_poison").is_empty()
		"atk_neighbor", "mark_crossbow":
			out["kind"] = "ATK"
			out["n"] = int(ops.get("n", 4))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("atk_neighbor").is_empty()
		"atk_cleave":
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"atk_opposite":
			out["n"] = int(ops.get("n", 4))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and _opposite_index() >= 0
		"atk_wheel":
			out["n"] = _monsters_left()
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"blk_from_atk":
			out["kind"] = "BLK"
			out["n"] = int(m.get("atk", 0)) if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"atk_zero":
			out["kind"] = "ATK"
			out["number"] = "0"
			out["n"] = 0
			out["note"] = ""
			out["can_use"] = fighting
		"atk_echo":
			out["n"] = last_item_atk
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_item_atk > 0
		"heal_keep":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"blk_last":
			out["kind"] = "BLK"
			out["n"] = last_blk_gain
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_blk_gain > 0
		"quiet":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and _has_unique_ability(str(m.get("card_id", ""))) and not _is_silenced(str(m.get("card_id", "")))
		"atk_spend_blk":
			out["n"] = blk if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and blk > 0
		"atk_empty":
			out["n"] = beads_step
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"defeat_double_hp":
			out["kind"] = "DEFEAT"
			out["number"] = "Defeat"
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("defeat_double_hp").is_empty()
		"defeat_only_item":
			out["kind"] = "DEFEAT"
			out["number"] = "Defeat"
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and not _hand_has_atk_item(int(it.get("uid", -1)))
		"chaos_reroll":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _chaos_candidates(int(it.get("uid", -1))).is_empty()
		"echo":
			out["kind"] = "ATK"
			out["number"] = ""
			out["can_use"] = false
		"skip_swing":
			out["kind"] = "SKIP"
			out["number"] = "Skip"
			out["note"] = ""
			out["can_use"] = fighting
		"heal_full":
			out["kind"] = "HEAL"
			out["n"] = 6
			out["number"] = "6"
			out["note"] = ""
			out["can_use"] = fighting
		"egg_hurt":
			out["kind"] = "ATK"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"heal_kills":
			out["kind"] = "HEAL"
			out["n"] = 1 + mobs_defeated
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"magnet":
			out["kind"] = "SKIP"
			var mm: String = _magnet_mode_of(it)
			if mm == "high":
				out["number"] = "HIGH"
			elif mm == "low":
				out["number"] = "LOW"
			else:
				out["number"] = "Off"
			out["note"] = ""
			out["can_use"] = (fighting or phase == "ready") and not bool(it.get("spent", false))
		"hypnotize":
			out["kind"] = "MARK"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("hypnotize").is_empty()
		"hook_swap":
			out["kind"] = "MARK"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("hook_swap").is_empty()
		"blk_siphon":
			out["kind"] = "BLK"
			out["n"] = int(it.get("siphon_blk", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and int(it.get("siphon_blk", 0)) > 0
		"passive":
			out["kind"] = "PASSIVE"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = false
		_:
			out["can_use"] = false
	if _kind_deals_atk(kind):
		var shown: String = str(out.get("number", ""))
		if shown.is_valid_int() and int(out.get("n", 0)) >= 0:
			out["number"] = str(int(out.get("n", 0)) + _arrow_head_bonus())
	var authored: String = str(it.get("card_color", ""))
	if UxStyle.card_color_id(authored) != "auto":
		out["fill"] = UxStyle.card_color_fill(authored)
	else:
		out["fill"] = _utility_fill(kind, str(out.get("kind", "ATK")))
	out["rim"] = rim
	if it.get("spent", false):
		out["can_use"] = false
	if bool(it.get("petrified", false)):
		out["can_use"] = false
	if not pending_feed.is_empty():
		var feed_uids: Array = pending_feed.get("uids", [])
		out["can_use"] = feed_uids.has(int(it.get("uid", -1))) and not bool(it.get("spent", false))
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if face.is_empty():
			out["can_use"] = false
			out["kind"] = "PASSIVE"
			out["number"] = ""
		elif str(it.get("ops", {}).get("kind", "echo") if typeof(it.get("ops", {})) == TYPE_DICTIONARY else "echo") == "echo":
			pass
	if not pending_chaos.is_empty():
		var stone_uid: int = int(pending_chaos.get("uid", -1))
		var my_uid: int = int(it.get("uid", -1))
		if my_uid == stone_uid:
			out["can_use"] = true
		else:
			out["can_use"] = _chaos_candidates(stone_uid).has(my_uid)
	return out


func _live_item_count() -> int:
	return hotbar.size()


func _find_item(uid: int) -> Dictionary:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -1)) == uid:
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


func _toggle_log() -> void:
	_log_open = not _log_open
	if _log_open:
		_log_user_hid = false
		_log_user_show = true
	else:
		_log_user_hid = true
		_log_user_show = false
	if log_label:
		log_label.visible = _log_open
	if log_btn:
		log_btn.text = PLAYER_COPY.text("combat.log_hide", "Hide log") if _log_open else PLAYER_COPY.text("combat.log", "Log")
	_place_log_overlay()
	if sfx:
		sfx.play("switch", -14.0)


func _sync_log_panel() -> void:
	if log_label == null:
		return
	var in_dev: bool = phase == "devtest" and dev_panel != null and dev_panel.visible
	if right_col:
		right_col.visible = in_dev
		right_col.custom_minimum_size = Vector2(380, 0) if in_dev else Vector2(0, 0)
	if in_dev:
		log_label.visible = false
		if log_btn:
			log_btn.visible = false
		return
	if log_btn:
		log_btn.visible = true
	var in_fight: bool = phase == "fighting" or phase == "slaying"
	if in_fight and not _log_user_hid:
		_log_open = true
	elif not in_fight and not _log_user_show:
		_log_open = false
	log_label.visible = _log_open
	if log_btn:
		log_btn.text = PLAYER_COPY.text("combat.log_hide", "Hide log") if _log_open else PLAYER_COPY.text("combat.log", "Log")
	_place_log_overlay()


func _place_log_overlay() -> void:
	if play_field == null or log_btn == null:
		return
	var sz: Vector2 = play_field.size
	var w := 240.0
	log_btn.reset_size()
	var bsz: Vector2 = log_btn.get_combined_minimum_size()
	bsz.x = maxf(bsz.x, 88.0)
	log_btn.position = Vector2(sz.x - bsz.x - 8.0, 6.0)
	log_btn.size = bsz
	if log_label == null:
		return
	log_label.position = Vector2(sz.x - w - 6.0, 44.0)
	log_label.size = Vector2(w, maxf(120.0, sz.y - 52.0))


func _log_flush() -> void:
	if log_label and log_label.has_method("flush"):
		log_label.flush()


func _log(kind: String, msg: String, highlight: Dictionary = {}) -> void:
	if log_label == null:
		return
	if kind == "on_place":
		return
	if kind == "on_click" or kind == "on_spin" or kind == "on_draft" or kind == "on_bribe" or kind == "end":
		_log_flush()
	if log_label.has_method("push_line"):
		log_label.push_line(kind, msg, highlight)
	_sync_log_panel()


func _on_log_hover(highlight: Dictionary) -> void:
	var p: Dictionary = {}
	var wheel_i: int = int(highlight.get("wheel", -1))
	if wheel_i >= 0:
		p[wheel_i] = {"mark": "log"}
	_apply_preview(p)
	if wheel_view and wheel_view.has_method("set_log_focus"):
		wheel_view.set_log_focus(highlight)
	var uid: int = int(highlight.get("item_uid", -1))
	if hotbar_box:
		for c in hotbar_box.get_children():
			if c.has_method("set_log_focus"):
				c.set_log_focus(int(c.uid) == uid and uid >= 0)
	if combat_stage and combat_stage.has_method("set_log_glow"):
		combat_stage.set_log_glow(bool(highlight.get("fight", false)))
	if ability_slash and ability_slash.has_method("set_log_glow"):
		var slash_on: bool = bool(highlight.get("slash", false))
		if str(highlight.get("card_id", "")) != "" and str(ability_slash.card_id) == str(highlight.get("card_id", "")):
			slash_on = true
		ability_slash.set_log_glow(slash_on and ability_slash.visible)


func _log_hint_of(card: Dictionary) -> String:
	return str(card.get("log_hint", "")).strip_edges()


func _log_begin_monster(index: int) -> void:
	if log_label == null or not log_label.has_method("begin_proc"):
		return
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	var title: String = str(s.get("call_name", "")).strip_edges()
	if title == "":
		title = str(s.get("name", "?"))
	var hint: String = _log_hint_of(s)
	if hint == "":
		hint = _log_hint_of(monsters_by_id.get(str(s.get("card_id", "")), {}))
	var cid: String = str(s.get("card_id", ""))
	if cid == "commander" or cid == "cowardly_king":
		var flee_def: String = UxStyle.def_of("flee")
		if hint == "":
			hint = flee_def
		elif hint.find(flee_def) < 0:
			hint = "%s\n%s" % [hint, flee_def]
	var hl := {
		"wheel": index,
		"hp": true,
		"atk": true,
		"fight": index == facing_index,
		"slash": true,
		"card_id": str(s.get("card_id", "")),
	}
	log_label.begin_proc({
		"kind": "monster",
		"title": title,
		"subtitle": str(s.get("name", "")),
		"hint": hint,
		"tier": int(s.get("pack_tier", 1)),
		"highlight": hl,
	})


func _log_begin_item(it: Dictionary) -> void:
	if log_label == null or not log_label.has_method("begin_proc"):
		return
	if it.is_empty():
		return
	var id: String = str(it.get("card_id", ""))
	var cat: Dictionary = items_by_id.get(id, {})
	var hint: String = _log_hint_of(it)
	if hint == "":
		hint = _log_hint_of(cat)
	var hl := {
		"item_uid": int(it.get("uid", -1)),
		"slash": true,
		"card_id": id,
	}
	log_label.begin_proc({
		"kind": "item",
		"title": str(it.get("name", "?")),
		"hint": hint,
		"tier": int(it.get("pack_tier", cat.get("tier", 1))),
		"highlight": hl,
	})


func _sort_hotbar() -> void:
	hotbar.sort_custom(func(a, b) -> bool:
		return _item_rank(a) < _item_rank(b)
	)
	_hotbar_sig = ""


func _item_rank(it: Dictionary) -> int:
	var view: Dictionary = _item_view(it)
	var k: String = str(view.get("kind", ""))
	var fill: Color = view.get("fill", Color.BLACK)
	if _is_yellow_fill(fill):
		return 1
	if k == "ATK":
		return 0
	if k == "BLK":
		return 2
	if k == "DEFEAT" or k == "FANGS":
		return 3
	return 4


func _is_yellow_fill(fill: Color) -> bool:
	return fill.r > 0.22 and fill.g > 0.18 and fill.b < 0.16 and fill.r >= fill.g


func _apply_preview(p: Dictionary) -> void:
	if wheel_view:
		wheel_view.set_preview(p)
	_refresh_blk(false)


func _on_spin_hover(on: bool) -> void:
	if on and sfx:
		sfx.play_event(&"wheel.spin_hover")
	if not on or phase != "ready":
		_apply_preview({})
		return
	var p: Dictionary = {}
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if bool(s.get("atk_variable", false)) or bool(s.get("hp_variable", false)):
			p[i] = {"mark": "spin"}
	_apply_preview(p)


func _on_place_hover(on: bool) -> void:
	if not on or pending_item.is_empty() or (phase != "starter" and phase != "draft"):
		if not on:
			_apply_preview({})
		return
	var p: Dictionary = {}
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) == "bandit":
			p[i] = {"atk": 1}
	_apply_preview(p)


func _preview_bribe(index: int) -> Dictionary:
	var p: Dictionary = {}
	var n: int = wheel.size()
	if index < 0 or index >= n:
		return p
	if str(wheel[index].get("card_id", "")) == "lich":
		for off in [n - 1, 1]:
			var j: int = (index + off) % n
			if str(wheel[j].get("kind", "")) == "monster":
				p[j] = {"hp": -1}
	if str(wheel[index].get("card_id", "")) == "commander":
		for off_c in [n - 1, 1]:
			var jc: int = (index + off_c) % n
			if str(wheel[jc].get("kind", "")) == "monster":
				var curc: Dictionary = p.get(jc, {})
				curc["atk"] = int(curc.get("atk", 0)) - 2
				p[jc] = curc
	for off2 in [n - 1, 1]:
		var k: int = (index + off2) % n
		if str(wheel[k].get("card_id", "")) == "lich" and str(wheel[index].get("kind", "")) == "monster":
			var cur: Dictionary = p.get(index, {})
			cur["hp"] = int(cur.get("hp", 0)) - 1
			p[index] = cur
		if str(wheel[k].get("card_id", "")) == "commander" and str(wheel[index].get("kind", "")) == "monster":
			var cur2: Dictionary = p.get(index, {})
			cur2["atk"] = int(cur2.get("atk", 0)) - 2
			p[index] = cur2
	return p


func _preview_from_item(it: Dictionary) -> Dictionary:
	_ghost_blk = -1
	var p: Dictionary = {}
	if phase != "fighting" or facing_index < 0:
		return p
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var view: Dictionary = _item_view(it)
	var n: int = int(view.get("n", 0))
	match kind:
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_siphon", "blk_from_atk":
			if bool(view.get("can_use", false)):
				var gain_n: int = maxi(0, n)
				if _twins_double_blk(gain_n):
					gain_n *= 2
				_ghost_blk = blk + gain_n
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "choose", "atk_wheel", "atk_echo", "atk_spend_blk", "atk_empty":
			var drop_prev := false
			if kind == "choose":
				var popts: Variant = _ops_of(it).get("options", [])
				if typeof(popts) == TYPE_ARRAY:
					for po in popts:
						if typeof(po) == TYPE_DICTIONARY and (po as Dictionary).has("atk_drop"):
							drop_prev = true
							break
			if drop_prev:
				pass
			elif bool(view.get("can_use", false)) and str(wheel[facing_index].get("card_id", "")) != "goblin":
				var dmg: int = n if kind != "choose" else int(view.get("n", 3))
				if _kind_deals_atk(kind):
					dmg = _atk_with_head(dmg)
				var procs: int = 2 if _twins_double_atk(facing_index, dmg) else 1
				var total: int = 0
				for _p in range(procs):
					var hitn: int = dmg
					if str(wheel[facing_index].get("card_id", "")) == "anvil" and not _is_silenced("anvil"):
						hitn = mini(hitn, 1)
					total += hitn
				p[facing_index] = {"hp": -total}
				if int(wheel[facing_index].get("hp", 0)) - total <= 0:
					if str(wheel[facing_index].get("card_id", "")) != "wick" or _is_silenced("wick"):
						p[facing_index]["kill"] = true
				if str(wheel[facing_index].get("card_id", "")) == "slime_boss":
					p[facing_index]["atk"] = -total
		"atk_cleave":
			if bool(view.get("can_use", false)):
				var cn: int = _atk_with_head(int(view.get("n", 2)))
				for ci in _cleave_targets():
					if str(wheel[ci].get("card_id", "")) == "goblin":
						continue
					var procs_c: int = 2 if _twins_double_atk(ci, cn) else 1
					var hitn: int = 0
					for _pc in range(procs_c):
						var one: int = cn
						if str(wheel[ci].get("card_id", "")) == "anvil" and not _is_silenced("anvil"):
							one = mini(cn, 1)
						hitn += one
					var slot: Dictionary = p.get(ci, {})
					slot["hp"] = int(slot.get("hp", 0)) - hitn
					if int(wheel[ci].get("hp", 0)) + int(slot.get("hp", 0)) <= 0:
						slot["kill"] = true
					if str(wheel[ci].get("card_id", "")) == "slime_boss":
						slot["atk"] = int(slot.get("atk", 0)) - cn
					p[ci] = slot
		"atk_opposite":
			var oi: int = _opposite_index()
			if bool(view.get("can_use", false)) and oi >= 0 and str(wheel[oi].get("card_id", "")) != "goblin":
				var od: int = _atk_with_head(int(view.get("n", 4)))
				var procs_o: int = 2 if _twins_double_atk(oi, od) else 1
				var od_total: int = 0
				for _po in range(procs_o):
					var one_o: int = od
					if str(wheel[oi].get("card_id", "")) == "anvil" and not _is_silenced("anvil"):
						one_o = mini(od, 1)
					od_total += one_o
				od = od_total
				p[oi] = {"hp": -od}
				if int(wheel[oi].get("hp", 0)) - od <= 0:
					p[oi]["kill"] = true
				if str(wheel[oi].get("card_id", "")) == "slime_boss":
					p[oi]["atk"] = -od
		"defeat_hp", "defeat_atk", "fangs", "defeat_only_item":
			if bool(view.get("can_use", false)):
				p[facing_index] = {"hp": -int(wheel[facing_index].get("hp", 0)), "kill": true}
		"defeat_double_hp":
			if bool(view.get("can_use", false)):
				for si in _mark_targets("defeat_double_hp"):
					p[si] = {"hp": -int(wheel[si].get("hp", 0)), "kill": true}
		"atk_zero", "atk_drop":
			if bool(view.get("can_use", false)) and not _atk_is_always(wheel[facing_index]):
				var curz: Dictionary = p.get(facing_index, {})
				var drop_n: int = int(wheel[facing_index].get("atk", 0)) if kind == "atk_zero" else mini(3, int(wheel[facing_index].get("atk", 0)))
				curz["atk"] = -drop_n if kind == "atk_zero" else -mini(int(view.get("n", 3)), int(wheel[facing_index].get("atk", 0)))
				p[facing_index] = curz
		"skip_swing":
			if bool(view.get("can_use", false)):
				p[facing_index] = {"kill": true}
	if items_used_this_combat + 1 >= 2:
		for i in range(wheel.size()):
			if str(wheel[i].get("card_id", "")) == "two_headed_serpent" and i == facing_index:
				var cur2: Dictionary = p.get(i, {})
				cur2["atk"] = -int(wheel[i].get("atk", 0))
				p[i] = cur2
	if not bool(it.get("keep_after", false)) and kind != "choose":
		for i2 in range(wheel.size()):
			if str(wheel[i2].get("card_id", "")) != "bandit":
				continue
			if _is_silenced(wheel[i2]):
				continue
			var cur3: Dictionary = p.get(i2, {})
			cur3["atk"] = int(cur3.get("atk", 0)) - 1
			p[i2] = cur3
	return p


func _punch_blk() -> void:
	if wheel_view:
		wheel_view.punch_hub()


func _refresh_blk(punch: bool) -> void:
	if wheel_view:
		wheel_view.set_vitals(hp, HP_MAX, _ghost_hp, blk, _ghost_blk)
		if wheel_view.has_method("set_hub_pierce"):
			wheel_view.set_hub_pierce(_hand_pierce() and phase == "fighting")
		_sync_run_hero_gear()
	if punch and _ghost_blk < 0 and blk > _blk_shown and _blk_shown >= 0:
		_punch_blk()
	if _ghost_blk < 0:
		_blk_shown = blk


func _inspect_item(it: Dictionary, force: bool = false) -> void:
	if fly_tip == null:
		return
	if _inspect_pinned and not force:
		return
	var rule: Dictionary = _item_rule(it)
	fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), str(rule["body"]), str(rule["warn"]), null, "item", str(it.get("card_id", "")), _item_look(it))
	_place_fly(_fly_card)


func _bb(hex: String, text: String) -> String:
	return "[color=%s][b]%s[/b][/color]" % [hex, text]


func _paint_explainer(raw: String, num_hex: String = "#E07A7A") -> String:
	return _rewrite_keywords(raw, true, num_hex)


func _capitalize_keywords(raw: String) -> String:
	return _rewrite_keywords(raw, false, "")


func _rewrite_keywords(raw: String, colored: bool, num_hex: String) -> String:
	var t: String = raw.strip_edges()
	if t == "" or t.find("[color") >= 0:
		return raw
	var gold := "#E8C36A"
	var hp_c := "#E8A0A0"
	var atk_c := "#E07A7A"
	var var_c := "#C9A0FF"
	var blk_c := "#6BB3D9"
	var phrases: Array = [
		["item if i never swing", gold],
		["no attack damage", gold],
		["no atk damage", gold],
		["attacks twice", gold],
		["double hit", gold],
		["ignores block", gold],
		["times you bled", hp_c],
		["monsters left", var_c],
		["take their atk", hp_c],
		["heal their hp", hp_c],
		["last enemy atk", atk_c],
		["last enemy hp", hp_c],
		["higher neighbor", atk_c],
		["neighbor atk", atk_c],
		["neighbor hp", hp_c],
		["enemy atk", atk_c],
		["enemy hp", hp_c],
		["your hp", hp_c],
		["even atk", gold],
	]
	var stems := PackedStringArray([
		"defeated", "defeats", "defeating", "defeat",
		"attacks", "attacking", "attacked", "attack",
		"blocked", "blocking", "blocks", "block",
		"items", "item",
		"heals", "healed", "healing", "heal",
		"neighbors", "neighboring", "neighbor",
		"owners", "owner",
		"thorns", "thorn",
		"keep",
		"bled", "bleeds", "bleeding", "bleed",
		"fleeing", "flees", "fled", "flee",
		"petrifies", "petrified", "petrify",
		"spinning", "spins", "spin",
		"random",
		"always",
		"atk", "blk", "hp",
	])
	var nums := "one|two|three|four|five|six|seven|eight|nine|ten|twice|thrice"
	var alts: PackedStringArray = PackedStringArray()
	for p in phrases:
		alts.append(str(p[0]))
	alts.append("\\b(?:%s)\\b" % "|".join(stems))
	alts.append("\\b(?:%s)\\b" % nums)
	alts.append("[+\\-−]?\\d+")
	var rx := RegEx.new()
	if rx.compile("(?i)(%s)" % "|".join(alts)) != OK:
		return raw
	var hits: Array = rx.search_all(t)
	var out := t
	for i in range(hits.size() - 1, -1, -1):
		var m: RegExMatch = hits[i]
		var piece: String = m.get_string()
		var shown: String = _format_keyword(piece)
		if colored:
			var hex: String = _paint_hex(piece, t, m.get_start(), m.get_end(), num_hex, gold, hp_c, atk_c, var_c, blk_c, phrases)
			shown = _bb(hex, shown)
		shown = UxStyle.with_def_link(shown, piece)
		out = out.substr(0, m.get_start()) + shown + out.substr(m.get_end())
	return out


func _format_keyword(piece: String) -> String:
	if piece.find(" ") < 0:
		return _format_keyword_token(piece)
	var bits: PackedStringArray = PackedStringArray()
	for w in piece.split(" "):
		bits.append(_format_keyword_token(w))
	return " ".join(bits)


func _format_keyword_token(tok: String) -> String:
	var prefix := ""
	var suffix := ""
	var core := tok
	while core.length() > 0 and _is_paint_sep(core.substr(0, 1)):
		prefix += core.substr(0, 1)
		core = core.substr(1)
	while core.length() > 0 and _is_paint_sep(core.substr(core.length() - 1, 1)):
		suffix = core.substr(core.length() - 1, 1) + suffix
		core = core.substr(0, core.length() - 1)
	if core == "":
		return tok
	var low: String = core.to_lower()
	if low == "atk" or low == "blk" or low == "hp":
		return prefix + low.to_upper() + suffix
	if low == "always":
		return prefix + "Always" + suffix
	if _is_word_num(low) or _token_has_digit(core):
		return tok
	if _is_keyword_stem(low):
		return prefix + core.substr(0, 1).to_upper() + core.substr(1).to_lower() + suffix
	return tok


func _token_has_digit(s: String) -> bool:
	for ch in s:
		if String(ch).is_valid_int():
			return true
	return false


func _is_word_num(low: String) -> bool:
	return low in ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "twice", "thrice"]


func _is_paint_sep(ch: String) -> bool:
	return ch.strip_edges() == "" or "()[]{},.:;!?+−↔/—–'\"“”".find(ch) >= 0


func _is_paint_glue(low: String) -> bool:
	return low in ["or", "and", "of", "to", "the", "a", "an", "more", "less", "minus", "plus", "per", "if", "than", "with", "from", "your", "their", "vs", "equal", "equals"]


func _is_keyword_stem(low: String) -> bool:
	return _stem_hex(low, "1", "1", "1", "1", "1") != ""


func _stem_hex(low: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> String:
	if low == "always":
		return UxStyle.ALWAYS
	if low.begins_with("defeat"):
		return var_c
	if low.begins_with("attack") or low == "atk":
		return atk_c
	if low.begins_with("block") or low == "blk":
		return blk_c
	if low.begins_with("item"):
		return gold
	if low.begins_with("heal"):
		return hp_c
	if low == "hp":
		return hp_c
	if low.begins_with("bleed") or low == "bled":
		return hp_c
	if low.begins_with("thorn"):
		return atk_c
	if low == "keep" or low == "random" or low.begins_with("owner") or low.begins_with("neighbor"):
		return gold
	if low.begins_with("flee") or low.begins_with("spin"):
		return gold
	if low.begins_with("petrif"):
		return gold
	return ""


func _paint_hex(piece: String, full: String, start: int, end: int, fallback: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String, phrases: Array) -> String:
	var low: String = piece.to_lower()
	for p in phrases:
		if low == str(p[0]):
			return str(p[1])
	var stem: String = _stem_hex(low, gold, hp_c, atk_c, var_c, blk_c)
	if stem != "":
		return stem
	if _is_word_num(low) or _token_has_digit(piece):
		return _number_hex(full, start, end, fallback, gold, hp_c, atk_c, var_c, blk_c)
	return fallback


func _token_left(s: String, from: int) -> Dictionary:
	var i: int = from - 1
	while i >= 0 and _is_paint_sep(s.substr(i, 1)):
		i -= 1
	if i < 0:
		return {}
	var j: int = i
	while j >= 0 and not _is_paint_sep(s.substr(j, 1)):
		j -= 1
	return {"t": s.substr(j + 1, i - j), "a": j + 1, "b": i + 1}


func _token_right(s: String, from: int) -> Dictionary:
	var i: int = from
	while i < s.length() and _is_paint_sep(s.substr(i, 1)):
		i += 1
	if i >= s.length():
		return {}
	var j: int = i
	while j < s.length() and not _is_paint_sep(s.substr(j, 1)):
		j += 1
	return {"t": s.substr(i, j - i), "a": i, "b": j}


func _scan_key_hex(full: String, from: int, going_left: bool, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> Dictionary:
	var cursor: int = from
	for _s in range(4):
		var tok: Dictionary = _token_left(full, cursor) if going_left else _token_right(full, cursor)
		if tok.is_empty():
			return {}
		var low: String = str(tok["t"]).to_lower()
		var hex: String = _stem_hex(low, gold, hp_c, atk_c, var_c, blk_c)
		if hex != "":
			return {"hex": hex, "d": (from - int(tok["b"])) if going_left else (int(tok["a"]) - from)}
		if _is_paint_glue(low):
			cursor = int(tok["a"]) if going_left else int(tok["b"])
			continue
		break
	return {}


func _number_hex(full: String, start: int, end: int, fallback: String, gold: String, hp_c: String, atk_c: String, var_c: String, blk_c: String) -> String:
	var left: Dictionary = _scan_key_hex(full, start, true, gold, hp_c, atk_c, var_c, blk_c)
	var right: Dictionary = _scan_key_hex(full, end, false, gold, hp_c, atk_c, var_c, blk_c)
	var l_ok: bool = not left.is_empty()
	var r_ok: bool = not right.is_empty()
	if l_ok and r_ok:
		if int(left["d"]) <= int(right["d"]):
			return str(left["hex"])
		return str(right["hex"])
	if r_ok:
		return str(right["hex"])
	if l_ok:
		return str(left["hex"])
	return fallback


func _value_bb(word: String, n: String, hex: String) -> String:
	if n == "":
		return "[b][color=%s]%s[/color][/b]" % [hex, word]
	return "[b][color=%s]%s %s[/color][/b]" % [hex, word, n]


func _item_rule(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var kind: String = str(_ops_of(it).get("kind", ""))
	var live: int = int(view.get("n", 0))
	if _kind_deals_atk(kind) and live >= 0:
		live = _atk_with_head(live)
	var fighting: bool = phase == "fighting" and facing_index >= 0
	var m: Dictionary = wheel[facing_index] if fighting else {}
	var out := {
		"title": _title_case(str(it.get("name", "?"))),
		"value": "",
		"equation": "",
		"body": "",
		"warn": "",
	}
	if str(it.get("card_id", "")) == "echo_bell":
		var face_t: Dictionary = _echo_face(it)
		if not face_t.is_empty():
			out["title"] = _title_case(str(face_t.get("name", "Echo Bell")))
	var hp_c := "#E8A0A0"
	var atk_c := "#E07A7A"
	var var_c := "#C9A0FF"
	var gold := "#E8C36A"
	var blk_c := "#6BB3D9"
	var num_c: String = blk_c if kind.begins_with("blk") else atk_c
	if kind == "heal_kills" or kind == "heal_keep" or kind == "heal_full":
		num_c = hp_c
	elif kind == "smoke" or kind == "hook_swap":
		num_c = gold
	var cream := num_c
	match kind:
		"blk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["body"] = "Gain 4 block."
		"atk_alt_24":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) then (%s) then (%s)…" % [_bb(atk_c, "2"), _bb(atk_c, "4"), _bb(atk_c, "2")]
			out["body"] = "Flips 2 ↔ 4 after any item is used. The number stays for later fights in this dungeon. A new dungeon starts it at 2."
		"choose":
			var drop_n := false
			var spike_n := false
			var copts: Variant = _ops_of(it).get("options", [])
			if typeof(copts) == TYPE_ARRAY:
				for o2 in copts:
					if typeof(o2) != TYPE_DICTIONARY:
						continue
					if (o2 as Dictionary).has("atk_drop"):
						drop_n = true
					if (o2 as Dictionary).has("blk") and (o2 as Dictionary).has("atk"):
						spike_n = true
			if drop_n:
				out["value"] = _value_bb("Attack", "−1 / −2 / −3", atk_c)
				out["body"] = "Click 1, 2, or 3. The facing owner's Attack drops by that much after their own ability and Commander, then stays there this fight. Owners whose Attack always equals a number ignore this."
				if fighting and _atk_is_always(m):
					out["warn"] = "Their Attack Always equals that number. This will not change the plate."
			elif spike_n or str(it.get("card_id", "")) == "spiked_shield":
				var spike_atk: int = _atk_with_head(2)
				out["value"] = "%s    %s" % [_value_bb("Attack", str(spike_atk), atk_c), _value_bb("Block", "2", blk_c)]
				out["equation"] = "(%s) or (%s)" % [_bb(atk_c, str(spike_atk)), _bb(blk_c, "2")]
				out["body"] = "Deal 2 attack, or gain 2 block."
			else:
				out["value"] = _value_bb("Attack", str(live if live > 0 else 3), atk_c)
				out["equation"] = "(%s) or (%s and %s)" % [_bb(atk_c, str(_atk_with_head(3))), _bb(atk_c, str(_atk_with_head(1))), _bb(gold, "Keep")]
				out["body"] = "Throw for 3 and lose it, or nick for 1 and keep it."
		"atk":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			if _is_arrow_head(it) or str(it.get("card_id", "")) == "arrow_head":
				var bonus: int = maxi(1, _arrow_head_bonus())
				out["equation"] = "(%s) + (%s)    %s" % [_bb(atk_c, "3"), _bb(atk_c, "+%s" % bonus), _bb(gold, "ignores Block")]
			else:
				out["equation"] = "(%s)" % _bb(atk_c, str(live))
			out["body"] = str(it.get("ability", "Deal Attack."))
		"atk_if_enemy_atk_even":
			out["value"] = _value_bb("Attack", str(live if fighting else 4), atk_c)
			out["equation"] = "(%s) or (%s if %s)" % [_bb(cream, "2"), _bb(atk_c, "4"), _bb(gold, "Even ATK")]
			out["body"] = "Attack 2, or 4 if the enemy's attack is even."
		"blk_from_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "6"), _bb(hp_c, "HP")]
			out["body"] = "Block equal to the HP you are missing."
		"blk_min_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(the lower of %s and %s)" % [_bb(hp_c, "Your HP"), _bb(hp_c, "Enemy HP")]
			out["body"] = "Block equal to whoever has less HP — you or the enemy."
		"defeat_hp":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s < %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = "Defeat an enemy with less HP than you. Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.boot", "Can't — this enemy has as much HP as you, or more.")
		"atk_7_hp":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "7"), _bb(hp_c, "HP")]
			out["body"] = "Attack equal to the HP you are missing, counted from 7."
		"blk_neighbor":
			out["value"] = _value_bb("Block", str(live) if live >= 0 else "—", blk_c)
			var side_word: String = "Left" if str(_ops_of(it).get("side", "")) == "left" else "Right"
			out["equation"] = "(%s)" % _bb(atk_c, "%s Neighbor ATK" % side_word)
			out["body"] = "Block equal to the %s neighbor's Attack. Left is clockwise. Right is counter-clockwise." % side_word.to_lower()
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"atk_7_items":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "8"), _bb(gold, "Items")]
			out["body"] = "Attack equal to 8 minus the items still in your hand."
		"atk_2_kills":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "2"), _bb(var_c, "Defeat")]
			out["body"] = "Get stronger. +1 attack for each monster defeated."
		"atk_hp_loss":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s × %s)" % [_bb(cream, "2"), _bb(hp_c, "Times you Bled")]
			out["body"] = "Gets stronger. +2 attack each time you lose any HP."
		"defeat_atk":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s ≥ %s)" % [_bb(atk_c, "Enemy ATK"), _bb(cream, "5")]
			out["body"] = "Defeat an enemy with 5 or more attack. Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.sledge", "Can't — this enemy's attack is under 5.")
		"atk_last":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Last Enemy ATK")
			out["body"] = "Attack equal to the attack of the last monster you faced."
		"atk_strong_neighbor":
			out["value"] = _value_bb("Attack", str(live) if live >= 0 else "—", atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Highest Neighbor ATK")
			out["body"] = "Attack equal to the attack of the strongest neighboring enemy."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"blk_keep":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s) and %s if you Bled" % [_bb(blk_c, "2"), _bb(gold, "Keep")]
			out["body"] = "Gain 2 block. If you lose HP this combat, keep this item."
		"smoke":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Abort this fight, spin again (not the same slice), and gain a random unseen item."
		"fangs":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s) then %s then %s" % [_bb(hp_c, "Take their ATK"), _bb(var_c, "Defeat"), _bb(hp_c, "Heal their HP")]
			out["body"] = "Take their hit (block still works), defeat them, then heal equal to the HP they had."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
		"mark_poison":
			out["value"] = _value_bb("Mark", "", gold)
			out["body"] = "Mark a neighbor. When you spin them, they lose 5 HP immediately."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.poison", "Can't — no neighbor you can poison.")
		"atk_neighbor", "mark_crossbow":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) to Neighbor" % _bb(atk_c, "ATK 4")
			out["body"] = "Deal 4 Attack to a neighboring enemy."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"atk_cleave":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) to facing and neighbors" % _bb(atk_c, "2")
			out["body"] = "Deal 2 attack to the enemy you face and each neighboring enemy. The same enemy is only hit once."
		"atk_opposite":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) opposite if even count" % _bb(atk_c, "4")
			out["body"] = "Deal 4 attack to the owner across from you. Needs an even number of owners."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — odd number of owners on the wheel."
		"heal_kills":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "1"), _bb(var_c, "Defeat")]
			out["body"] = "Heal 1, plus 1 for each owner you have already defeated."
		"heal_full":
			out["value"] = _value_bb("Heal", "6", hp_c)
			out["equation"] = "(%s)" % _bb(hp_c, "6")
			out["body"] = "Heal 6. On Spin, lose 1 HP."
		"magnet":
			out["value"] = _value_bb("Spin", str(view.get("number", "Off")), gold)
			out["equation"] = "(%s) or (%s) or (%s)" % [_bb(atk_c, "Highest ATK"), _bb(atk_c, "Lowest ATK"), _bb(gold, "Off")]
			out["body"] = str(it.get("ability", "The next Spin lands on the Highest or Lowest Attack monster, then this is discarded."))
		"hypnotize":
			out["value"] = _value_bb("Hypnotize", "", gold)
			out["body"] = str(it.get("ability", "Select an enemy. They Attack the enemy you are facing."))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — pick a different enemy than the one you are facing."
		"hook_swap":
			out["value"] = _value_bb("Swap", "", gold)
			out["body"] = "Swap a neighboring owner into this fight, then draw a random item."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"blk_siphon":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s) +2 per Spin" % _bb(blk_c, "BLK")
			out["body"] = "Each Spin: lose 1 HP. This card gains 2 Block. Click it to spend that Block."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no block stored yet."
		"atk_wheel":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(var_c, "Owners left")
			out["body"] = "Attack equal to how many owners are still on the wheel."
		"blk_from_atk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Facing ATK")
			out["body"] = "Block equal to the facing owner's attack."
		"atk_zero":
			out["value"] = _value_bb("Attack", "0", atk_c)
			out["body"] = "The facing owner's attack becomes 0 this fight."
		"atk_drop":
			out["value"] = _value_bb("Attack", "−1 / −2 / −3", atk_c)
			out["body"] = "Click 1, 2, or 3. The facing owner's Attack drops by that much after their own ability and Commander, then stays there this fight. Owners whose Attack always equals a number ignore this."
			if fighting and _atk_is_always(m):
				out["warn"] = "Their Attack Always equals that number. This will not change the plate."
		"heal_keep":
			out["value"] = _value_bb("Heal", "2", hp_c)
			out["equation"] = "(%s) then Keep if still missing HP" % _bb(hp_c, "2")
			out["body"] = "Heal 2. Keep this if you are still below 6 HP. If you are already at 6, it is used up."
		"blk_last":
			out["value"] = _value_bb("Block", str(last_blk_gain), blk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "Last Block gained")
			out["body"] = "Block equal to the last Block you gained this dungeon."
			if fighting and last_blk_gain <= 0:
				out["warn"] = "Can't — you have not gained Block yet this dungeon."
		"quiet":
			out["value"] = _value_bb("Quiet", "", var_c)
			out["body"] = "Remove the facing owner's unique ability for the rest of this dungeon. They use their printed Attack and HP."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — they have no unique ability."
		"echo":
			out["value"] = _value_bb("Unplayable", "", gold)
			out["body"] = "Becomes a copy of the last item you used this dungeon."
			out["warn"] = "Can't — you have not used an item this dungeon."
		"atk_echo":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Last Item ATK")
			out["body"] = "Attack equal to the last item attack you used this fight."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — you have not dealt attack with an item this fight."
		"atk_spend_blk":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "BLK")
			out["body"] = "Deal Attack equal to Block you hold. Keep this item. You keep the Block."
			if fighting and blk <= 0:
				out["warn"] = "Can't — you have 0 Block."
		"atk_empty":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(var_c, "cycle")
			out["body"] = "Deal Attack 1, then 2, then 3, then 4. Every item use this dungeon advances the cycle."
		"defeat_double_hp":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s = %s × 2)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = "Defeat any Monster with exactly double your HP"
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no monster has exactly double your HP."
		"defeat_only_item":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["body"] = "If you have zero items that deal Attack, Defeat them."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and _hand_has_atk_item(int(it.get("uid", -1))):
				out["warn"] = "Can't — you are holding an Attack item."
		"chaos_reroll":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Click other items in your hand. Each becomes a random item of that item's tier."
			if fighting and _chaos_candidates(int(it.get("uid", -1))).is_empty():
				out["warn"] = "Can't — this is the only item in your hand."
		"skip_swing":
			out["value"] = _value_bb("Skip", "", var_c)
			out["body"] = "Skip their attack this fight. They still leave the wheel."
		"passive":
			out["value"] = _value_bb("Unplayable", "", gold)
			out["body"] = "Unplayable. If you would die, discard this and heal 3."
		_:
			out["value"] = str(view.get("kind", ""))
			out["body"] = str(it.get("ability", ""))
	if it.get("spent", false):
		out["warn"] = PLAYER_COPY.text("warn.spent", "Already used this fight.")
	if bool(it.get("petrified", false)):
		out["warn"] = "Petrify — Unplayable until your next Spin."
	var ab: String = str(it.get("ability", ""))
	if str(it.get("card_id", "")) == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			ab = str(face.get("ability", ab))
			var fex: String = str(face.get("explainer", ""))
			if fex != "":
				out["equation"] = _paint_explainer(fex, cream)
			if ab != "" and ab != "---":
				out["body"] = _paint_explainer(ab, cream)
			return out
	if ab != "" and ab != "---":
		out["body"] = _paint_explainer(ab, cream)
	var ex: String = str(it.get("explainer", ""))
	if ex != "" and ex != "---":
		out["equation"] = _paint_explainer(ex, cream)
	return out


func _monster_rule(s: Dictionary) -> Dictionary:
	var id: String = str(s.get("card_id", ""))
	var atk_n: String = str(s.get("atk", 0))
	var hp_n: String = str(s.get("hp", 0))
	var atk_c := "#E07A7A"
	var hp_c := "#E8A0A0"
	var gold := "#E8C36A"
	var out := {
		"title": _title_case(str(s.get("name", "?"))),
		"value": "%s    %s" % [_value_bb("Attack", atk_n, atk_c), _value_bb("HP", hp_n, hp_c)],
		"equation": "",
		"body": "",
		"warn": "",
		"speech": "",
		"hint": "",
		"reminder": "",
	}
	var reminder: String = str(s.get("reminder", "")).strip_edges()
	if reminder == "" or reminder == "---":
		reminder = str(s.get("ability", "")).strip_edges()
	out["reminder"] = reminder
	var call_n: String = str(s.get("call_name", "")).strip_edges()
	out["call"] = call_n
	if _is_silenced(id):
		out["speech"] = ""
		out["equation"] = ""
		out["reminder"] = ""
		out["hint"] = ""
		out["call"] = ""
		return out
	if id == "gargoyle" and _shift_held:
		out["warn"] = "Petrify — becomes Unplayable until your next Spin."
	if id == "cowardly_king" or id == "commander":
		out["warn"] = "Flee — if you are facing them, Spin the wheel at random."
	if _shift_held:
		if reminder != "":
			out["equation"] = _paint_explainer(reminder, atk_c)
	elif call_n != "":
		out["equation"] = _value_bb(call_n, "", gold)
	var speech: String = str(s.get("ability", "")).strip_edges()
	if speech == "" or speech == "---":
		speech = str(s.get("special_text", "")).strip_edges()
	if speech != "":
		out["speech"] = _rewrite_keywords(speech, true, "#E8C36A")
	return out


func _monster_plate_look(s: Dictionary, rule: Dictionary) -> Dictionary:
	var look: Dictionary = _monster_look(s)
	look["rank"] = "Tier %s" % _tier_of(s)
	if _shift_held:
		look["hint"] = ""
	else:
		look["hint"] = str(rule.get("hint", ""))
	return look


func _refresh_gate_owner() -> void:
	if draft_gate == null or not draft_gate.visible:
		return
	if not draft_gate.has_method("show_owner"):
		return
	if pending_monster.is_empty() or str(draft_gate.card_id) == "":
		if draft_gate.has_method("hide_owner"):
			draft_gate.hide_owner()
		return
	var rule: Dictionary = _monster_rule(pending_monster)
	draft_gate.show_owner(
		str(rule.get("title", "")),
		str(rule.get("value", "")),
		str(rule.get("equation", "")),
		"",
		str(rule.get("warn", "")),
		_monster_plate_look(pending_monster, rule)
	)


func _idle_inspect() -> void:
	if inspect:
		inspect.visible = false
	if _fly_card != null:
		return
	if fly_tip:
		fly_tip.hide_plate()


func _fill_inspect_from_slice(index: int) -> void:
	if _cabin_up():
		_hide_fight_hover()
		return
	if index < 0 or index >= wheel.size():
		_idle_inspect()
		return
	if inspect:
		inspect.visible = false
	if fly_tip == null:
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		fly_tip.show_text(
			PLAYER_COPY.text("inspect.empty_title", "Empty"),
			PLAYER_COPY.text("inspect.empty_place", "Click this alcove. That's where they'll wait.") if _can_place() else PLAYER_COPY.text("inspect.empty", "An empty alcove.")
		)
		_place_fly(null, wheel_view.slice_portrait_global(index) if wheel_view else Vector2.INF)
		return
	var rule: Dictionary = _monster_rule(s)
	var body: String = str(rule.get("speech", ""))
	var port: Texture2D = null
	if art != null:
		port = art.monster_still(str(s.get("card_id", "")))
	fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), body, str(rule.get("warn", "")), port, "monster", str(s.get("card_id", "")), _monster_plate_look(s, rule))
	_place_fly(null, wheel_view.slice_portrait_global(index) if wheel_view else Vector2.INF)


func _refresh_monster_plates() -> void:
	if _cabin_up():
		return
	if _deck_hovering:
		_fill_inspect_from_deck()
	elif _hover_slice >= 0:
		_fill_inspect_from_slice(_hover_slice)
	_refresh_face()


func _fly_goes_left(near: Control) -> bool:
	if near == _offer_card:
		return true
	if dungeon_deck_ui != null and near == dungeon_deck_ui:
		return true
	if challenge_draft_ui != null and challenge_draft_ui.visible and challenge_draft_ui.is_ancestor_of(near):
		return true
	if home_cabin != null and home_cabin.visible and home_cabin.is_ancestor_of(near):
		return true
	return false


func _place_fly(near: Control = null, at: Vector2 = Vector2.INF) -> void:
	if fly_tip == null or not fly_tip.visible:
		return
	fly_tip.reset_size()
	var sz: Vector2 = fly_tip.get_combined_minimum_size()
	sz.x = maxf(sz.x, 280.0)
	var pos: Vector2
	if at.x < 100000.0:
		pos = at + Vector2(18.0, -8.0)
	elif near != null and is_instance_valid(near):
		if _fly_goes_left(near):
			pos = near.global_position + Vector2(-sz.x - 12.0, -8.0)
		else:
			pos = near.global_position + Vector2(near.size.x + 10.0, -8.0)
	else:
		pos = get_global_mouse_position() + Vector2(20.0, 16.0)
	var vp: Vector2 = get_viewport_rect().size
	var room: float = 250.0 if bool(fly_tip.get("_pin_always")) else 8.0
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - sz.x - room))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - sz.y - 8.0))
	var tip_r := Rect2(pos, sz)
	for other in [face_box, inspect, speech_box]:
		if other == null or other == fly_tip or not (other is Control):
			continue
		var oc: Control = other
		if not oc.visible or not oc.is_visible_in_tree():
			continue
		var orr: Rect2 = oc.get_global_rect()
		if not tip_r.intersects(orr):
			continue
		var left_x: float = orr.position.x - sz.x - 12.0
		if left_x >= 8.0:
			pos.x = left_x
		else:
			pos.x = orr.end.x + 12.0
		pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - sz.x - 8.0))
		pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - sz.y - 8.0))
		tip_r = Rect2(pos, sz)
	fly_tip.global_position = pos
	fly_tip.size = sz
	if fly_tip.has_method("pin_always_def"):
		fly_tip.pin_always_def()


func _place_speech() -> void:
	if speech_box == null:
		return
	if _cabin_up():
		speech_box.hide_speech()
		return
	if overlay != null and overlay.visible:
		speech_box.hide_speech()
		return
	if content_ed != null and content_ed.visible:
		speech_box.hide_speech()
		return
	if roster_ed != null and roster_ed.visible:
		speech_box.hide_speech()
		return
	if script_ed != null and script_ed.visible:
		speech_box.hide_speech()
		return
	if fly_tip != null and fly_tip.visible and fly_tip.edit_kind == "item":
		speech_box.hide_speech()
		return
	if _gate_line != "" and draft_gate != null and draft_gate.visible:
		var look := {}
		if not pending_monster.is_empty():
			look = _monster_look(pending_monster)
		speech_box.present(draft_gate.mouth_global(), _gate_line, look, true, draft_gate.panel_left())
		_maybe_speak_monster(_gate_line, pending_monster)
		return
	if _cube_line != "" and not _shift_held and combat_stage != null and combat_stage.visible:
		var cube_look := {}
		if facing_index >= 0 and facing_index < wheel.size():
			cube_look = _monster_look(wheel[facing_index])
		speech_box.present(combat_stage.mouth_global(), _cube_line, cube_look, true)
		var cube_mon: Dictionary = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else {}
		_maybe_speak_monster(_cube_line, cube_mon)
		return
	if _cleric_line != "":
		var cleric_talk := {}
		var cleric_mouth := Vector2.ZERO
		var ti: int = _cleric_talk_index
		if ti >= 0 and ti < wheel.size():
			cleric_talk = wheel[ti]
			if wheel_view:
				cleric_mouth = wheel_view.slice_portrait_global(ti)
			if ti == facing_index and combat_stage != null and combat_stage.visible:
				cleric_mouth = combat_stage.mouth_global()
		if cleric_mouth != Vector2.ZERO:
			speech_box.present(cleric_mouth, _cleric_line, _monster_look(cleric_talk))
			_maybe_speak_monster(_cleric_line, cleric_talk)
			return
		speech_box.hide_speech()
		return
	if _shift_held and draft_gate != null and draft_gate.visible and not pending_monster.is_empty() and str(draft_gate.card_id) != "":
		var seat_rule: Dictionary = _monster_rule(pending_monster)
		var line: String = str(seat_rule.get("speech", ""))
		if line != "":
			speech_box.present(draft_gate.mouth_global(), line, _monster_look(pending_monster), true, draft_gate.panel_left())
			_maybe_speak_monster(line, pending_monster)
			return
	if not _shift_held:
		speech_box.hide_speech()
		return
	if fly_tip != null and fly_tip.visible and fly_tip.edit_kind == "item":
		speech_box.hide_speech()
		return
	var s: Dictionary = {}
	var mouth: Vector2 = Vector2.ZERO
	var hover_i: int = -1
	if wheel_view != null:
		hover_i = int(wheel_view.hover_index)
	if _fly_card != null and not pending_monster.is_empty() and fly_tip != null and fly_tip.edit_kind == "monster":
		s = pending_monster
		mouth = _fly_card.get_global_rect().position + Vector2(36, 28)
	elif _deck_hovering and not _peek_slice.is_empty():
		s = _peek_slice
		if dungeon_deck_ui != null:
			mouth = dungeon_deck_ui.get_global_rect().get_center()
	elif hover_i >= 0 and hover_i < wheel.size() and str(wheel[hover_i].get("kind", "")) == "monster":
		s = wheel[hover_i]
		mouth = wheel_view.slice_portrait_global(hover_i)
	elif (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("kind", "")) == "monster":
		s = wheel[facing_index]
		mouth = wheel_view.slice_portrait_global(facing_index)
	if s.is_empty():
		speech_box.hide_speech()
		return
	var in_fight: bool = phase == "fighting" or phase == "slaying"
	var hover_other: bool = hover_i >= 0 and hover_i != facing_index
	if in_fight and not hover_other and combat_stage != null and combat_stage.visible:
		mouth = combat_stage.mouth_global()
	var rule: Dictionary = _monster_rule(s)
	var line: String = str(rule.get("speech", ""))
	if line == "":
		speech_box.hide_speech()
		return
	speech_box.present(mouth, line, _monster_look(s))
	_maybe_speak_monster(line, s)


func _maybe_speak_monster(text: String, mon: Dictionary) -> void:
	if sfx == null or text.strip_edges() == "":
		return
	var key: String = "%s|%s" % [str(mon.get("card_id", "")), text]
	if key == _spoken_key:
		return
	_spoken_key = key
	sfx.speak(&"monster", text, {"tier": _tier_of(mon) if not mon.is_empty() else 1, "monster_id": str(mon.get("card_id", ""))})


func _place_fight_art() -> void:
	if wheel_view == null:
		return
	var wr: Rect2 = wheel_view.get_global_rect()
	var stack_w := 252.0
	var port_sz := Vector2(192, 160)
	var gap := 8.0
	var plaque_h := 0.0
	if face_box != null and face_box.visible:
		face_box.reset_size()
		plaque_h = face_box.get_combined_minimum_size().y
	var port_h: float = port_sz.y if combat_stage != null and combat_stage.visible else 0.0
	var total: float = port_h
	if port_h > 0.0 and plaque_h > 0.0:
		total += gap
	total += plaque_h
	var gap_side := 16.0
	var right_x: float = wr.end.x + gap_side
	var left_x: float = wr.position.x - gap_side - stack_w
	left_x = maxf(8.0, left_x)
	var speech_room := 156.0
	var y: float = wr.end.y - total - 18.0
	y = maxf(y, wr.position.y + speech_room)
	if y + total > wr.end.y + 8.0:
		y = wr.position.y + maxf(8.0, wr.size.y - total)
	var port_y: float = y
	if combat_stage != null and combat_stage.visible and not combat_stage.busy:
		combat_stage.size = port_sz
		combat_stage.global_position = Vector2(right_x + (stack_w - port_sz.x) * 0.5, y)
		y += port_sz.y + gap
	if face_box != null and face_box.visible:
		var psz: Vector2 = face_box.get_combined_minimum_size()
		psz.x = stack_w
		face_box.size = psz
		face_box.global_position = Vector2(right_x, y)
	if hypno_stage != null and hypno_stage.visible:
		hypno_stage.size = port_sz
		hypno_stage.global_position = Vector2(left_x + (stack_w - port_sz.x) * 0.5, port_y)
		if hypno_box != null and hypno_box.visible:
			hypno_box.reset_size()
			var hsz: Vector2 = hypno_box.get_combined_minimum_size()
			hsz.x = stack_w
			hypno_box.size = hsz
			hypno_box.global_position = Vector2(left_x, port_y + port_sz.y + gap)
	if ability_slash != null and not ability_slash.visible:
		ability_slash.size = Vector2(stack_w, port_sz.y + 72.0)
		ability_slash.global_position = Vector2(left_x, port_y)


func _speech_gutter() -> Rect2:
	if wheel_view == null:
		return Rect2()
	var wr: Rect2 = wheel_view.get_global_rect()
	var left: float = wr.end.x + 10.0
	var right: float = get_viewport_rect().size.x - 12.0
	if combat_stage != null and combat_stage.visible:
		right = minf(right, combat_stage.global_position.x - 8.0)
	var top: float = wr.position.y
	var bottom: float = wr.end.y - 8.0
	if btn_spin != null and btn_spin.visible:
		bottom = minf(bottom, btn_spin.global_position.y - 12.0)
	if hotbar_box != null and hotbar_box.visible:
		bottom = minf(bottom, hotbar_box.global_position.y - 12.0)
	if combat_stage != null and combat_stage.visible:
		bottom = minf(bottom, combat_stage.global_position.y - 10.0)
	if face_box != null and face_box.visible and (combat_stage == null or not combat_stage.visible):
		bottom = minf(bottom, face_box.global_position.y - 10.0)
	var w: float = maxf(right - left, 168.0)
	var h: float = maxf(bottom - top, 72.0)
	return Rect2(left, top, w, h)


func _incoming_hit() -> int:
	return _incoming_total()


func _on_done_hover(on: bool) -> void:
	if not on or phase != "fighting":
		_ghost_hp = -1
		_refresh_hearts()
		return
	if sfx:
		sfx.hover()
	_ghost_hp = maxi(0, hp - _incoming_hit())
	_refresh_hearts()


func _refresh_hearts() -> void:
	if wheel_view:
		wheel_view.set_vitals(hp, HP_MAX, _ghost_hp, blk, _ghost_blk)
		if wheel_view.has_method("set_hub_pierce"):
			wheel_view.set_hub_pierce(_hand_pierce() and phase == "fighting")
	if hearts_box == null:
		return
	hearts_box.visible = overlay == null or not overlay.visible
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		var live: bool = hi < hp
		var lost_soon: bool = _ghost_hp >= 0 and hi >= _ghost_hp and hi < hp
		if live:
			tr.modulate = Color("e07a7a") if lost_soon else Color.WHITE
		else:
			tr.modulate = Color(1, 1, 1, 0.18)
		hi += 1
	_hp_shown = hp


func _punch_heart(tr: TextureRect) -> void:
	tr.pivot_offset = tr.size * 0.5
	var tw := create_tween()
	tw.tween_property(tr, "scale", Vector2(1.35, 1.35), 0.08)
	tw.tween_property(tr, "scale", Vector2.ONE, 0.16)
	tw.parallel().tween_property(tr, "modulate", Color(1, 1, 1, 0.18), 0.2)


func _hearts_deny_shake() -> void:
	if hearts_box == null:
		return
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		if hi >= hp:
			tr.pivot_offset = tr.size * 0.5
			tr.modulate = Color("c45c5c")
			var tw := create_tween()
			tw.tween_property(tr, "scale", Vector2(1.16, 1.16), 0.07)
			tw.tween_property(tr, "scale", Vector2.ONE, 0.18)
			tw.parallel().tween_property(tr, "modulate", Color(1, 1, 1, 0.18), 0.22)
		hi += 1


func _glow_hearts_heal() -> void:
	if hearts_box == null:
		return
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		if hi < hp:
			tr.pivot_offset = tr.size * 0.5
			tr.modulate = Color("8fd18f")
			var tw := create_tween()
			tw.tween_property(tr, "scale", Vector2(1.22, 1.22), 0.08)
			tw.tween_property(tr, "scale", Vector2.ONE, 0.16)
			tw.parallel().tween_property(tr, "modulate", Color.WHITE, 0.22)
		hi += 1


func _tint_hearts_bleed() -> void:
	if hearts_box == null:
		return
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		if hi < hp:
			tr.modulate = Color("9b4dca")
			var tw := create_tween()
			tw.tween_property(tr, "modulate", Color.WHITE, 0.35)
		elif hi == hp:
			tr.modulate = Color("5c1a6a")
			var tw2 := create_tween()
			tw2.tween_property(tr, "modulate", Color(1, 1, 1, 0.18), 0.35)
		hi += 1


func _punch_label(lab: Label) -> void:
	if lab == null:
		return
	lab.pivot_offset = lab.size * 0.5
	var tw := create_tween()
	tw.tween_property(lab, "scale", Vector2(1.18, 1.18), 0.08)
	tw.tween_property(lab, "scale", Vector2.ONE, 0.14)


func _flash_screen(col: Color, a: float = 0.3) -> void:
	if fx_flash == null:
		return
	fx_flash.color = col
	fx_flash.modulate.a = a
	var tw := create_tween()
	tw.tween_property(fx_flash, "modulate:a", 0.0, 0.32)


func _num_color(kind: String) -> Color:
	if kind == "BLK":
		return Color("6bb3d9")
	if kind == "ATK":
		return Color("e06c75")
	if kind == "HEAL":
		return Color("8fd18f")
	if kind == "DEFEAT" or kind == "FANGS":
		return Color("f0e6d8")
	return Color("f0e6d8")


func _kind_mark(kind: String) -> Texture2D:
	if kind == "BLK":
		return tex_shield
	if kind == "HEAL":
		return tex_heart
	if kind == "DEFEAT" or kind == "FANGS":
		if art != null and art.tile("skull") != null:
			return art.tile("skull")
		return tex_by_monster.get("skeleton", tex_heart)
	if art != null and art.vfx.get("star", null) != null:
		return art.vfx["star"]
	return tex_sword


func _sync_hotbar_formulas() -> void:
	if hotbar_box == null:
		return
	for c in hotbar_box.get_children():
		if not c.has_method("show_formula"):
			continue
		var it: Dictionary = _find_item(int(c.uid))
		if it.is_empty():
			continue
		var rule: Dictionary = _item_rule(it)
		c.set_formula(str(rule.get("equation", "")))
		c.show_formula(_shift_held)
	_refresh_offer_card()
	_refresh_challenge_draft_cards()
	if choice_box == null:
		return
	for c in choice_box.get_children():
		if not c.has_method("show_formula"):
			continue
		c.show_formula(_shift_held)


func _refresh_challenge_draft_cards() -> void:
	if challenge_draft_ui == null or not challenge_draft_ui.visible:
		return
	if not challenge_draft_ui.has_method("draft_cards"):
		return
	for c in challenge_draft_ui.draft_cards():
		if c == null or not c.has_method("show_formula"):
			continue
		var it: Dictionary = {}
		for row in _challenge_pair:
			if int(row.get("uid", 0)) == int(c.uid):
				it = row
				break
		if it.is_empty():
			continue
		_dress_showcase_card(c, it, false)


func _wheel_side_gutter() -> float:
	if not adventure or phase == "title" or phase == "victory" or phase == "defeat" or phase == "rest":
		return 0.0
	if challenge_draft_ui != null and challenge_draft_ui.visible:
		var dmin: Vector2 = challenge_draft_ui.get_combined_minimum_size()
		return maxf(524.0, dmin.x + 16.0)
	return 110.0


func _layout_play_field() -> void:
	if play_field == null or wheel_view == null:
		return
	var sz: Vector2 = play_field.size
	if sz.x < 8.0 or sz.y < 8.0:
		return
	var trophy_h := 0.0
	if trophy:
		trophy.visible = mobs_defeated > 0
		if trophy.visible:
			var ts: Vector2 = trophy.get_combined_minimum_size()
			trophy.size = ts
			trophy.position = Vector2(0.0, 4.0)
			trophy_h = ts.y + 6.0
	if hearts_box:
		var hs: Vector2 = hearts_box.get_combined_minimum_size()
		hearts_box.size = hs
		hearts_box.position = Vector2(8.0, trophy_h + 4.0)
	if tray != null and tray.visible:
		var tmin: Vector2 = tray.get_combined_minimum_size()
		tray.position = Vector2((sz.x - tmin.x) * 0.5, 6.0)
		tray.size = tmin
	var extra: float = _wheel_side_gutter()
	var side: float = minf(sz.x - extra, maxf(120.0, sz.y - 48.0))
	side = minf(640.0, side)
	var x: float = (sz.x - side - extra) * 0.5
	var wheel_y: float = maxf(8.0, (sz.y - side) * 0.5)
	if tray != null and tray.visible:
		wheel_y = maxf(wheel_y, tray.position.y + tray.size.y + 8.0)
	wheel_view.custom_minimum_size = Vector2(side, side)
	wheel_view.position = Vector2(x, wheel_y)
	wheel_view.size = Vector2(side, side)
	var gutter_px: int = int(round(extra if adventure else 0.0))
	if hotbar_wrap:
		hotbar_wrap.add_theme_constant_override("margin_right", gutter_px)
	if btn_wrap:
		btn_wrap.add_theme_constant_override("margin_right", gutter_px)
	if dungeon_deck_ui:
		var show_deck: bool = adventure and phase != "title" and phase != "victory" and phase != "defeat" and phase != "rest"
		dungeon_deck_ui.visible = show_deck
		dungeon_deck_ui.size = Vector2(110, 156)
		dungeon_deck_ui.position = Vector2(x + side + 8.0, wheel_y)
		if not dungeon_deck_ui.is_busy():
			dungeon_deck_ui.set_count(challenge_deck.size())
		_sync_challenge_peek()
	if challenge_draft_ui != null and challenge_draft_ui.visible:
		challenge_draft_ui.reset_size()
		var dmin: Vector2 = challenge_draft_ui.get_combined_minimum_size()
		var w: float = maxf(508.0, dmin.x)
		var h: float = dmin.y
		if h > 560.0:
			h = 452.0
		h = minf(h, maxf(200.0, sz.y - 16.0))
		challenge_draft_ui.size = Vector2(w, h)
		var deck_bottom: float = 140.0
		if dungeon_deck_ui != null and dungeon_deck_ui.visible:
			deck_bottom = dungeon_deck_ui.position.y + dungeon_deck_ui.size.y + 8.0
		var draft_y: float = deck_bottom
		if draft_y + h > sz.y - 8.0:
			draft_y = maxf(8.0, sz.y - h - 8.0)
		challenge_draft_ui.position = Vector2(x + side + 8.0, draft_y)
	if cue_label:
		cue_label.position = Vector2(12.0, maxf(side + 4.0, sz.y - 40.0))
		cue_label.size = Vector2(maxf(sz.x - 24.0, 180.0), 36.0)
	_place_log_overlay()
	_place_fight_art()


func _set_cue(_t: String) -> void:
	if cue_label == null:
		return
	_cue_shown = ""
	cue_label.text = ""
	cue_label.visible = false


func _refresh_face() -> void:
	if face_box == null:
		return
	var show_plate: bool = (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size()
	if not show_plate:
		face_box.hide_plate()
		if combat_stage and phase != "slaying" and phase != "fighting":
			combat_stage.hide_stage()
		if phase != "slaying" and phase != "fighting":
			_hide_hypno()
		_refresh_hypno_box()
		return
	var m: Dictionary = wheel[facing_index]
	var rule: Dictionary = _monster_rule(m)
	face_box.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), str(rule.get("speech", "")), str(rule.get("warn", "")), null, "monster", str(m.get("card_id", "")), _monster_plate_look(m, rule))
	var atk_s: String = str(m.get("atk", 0))
	var hp_s: String = str(m.get("hp", 0))
	if (atk_s != _face_atk_shown and _face_atk_shown != "") or (hp_s != _face_hp_shown and _face_hp_shown != ""):
		face_box.pivot_offset = face_box.size * 0.5
		var tw := create_tween()
		tw.tween_property(face_box, "scale", Vector2(1.06, 1.06), 0.08)
		tw.tween_property(face_box, "scale", Vector2.ONE, 0.12)
	_face_atk_shown = atk_s
	_face_hp_shown = hp_s
	_refresh_hypno_box()
	_place_fight_art()


func _sync_challenge_peek() -> void:
	if dungeon_deck_ui == null:
		return
	if not dungeon_deck_ui.has_method("set_peek"):
		return
	if challenge_deck.is_empty():
		_peek_slice = {}
		dungeon_deck_ui.set_peek(null, "")
		if _deck_hovering:
			_deck_hovering = false
			_idle_inspect()
		return
	var nid: String = str(challenge_deck[0])
	var nm: String = str(monsters_by_id.get(nid, {}).get("name", nid))
	var tex: Texture2D = null
	if art != null:
		tex = art.monster_still(nid)
	dungeon_deck_ui.set_peek(tex, nm)
	if str(_peek_slice.get("card_id", "")) != nid:
		if monsters_by_id.has(nid):
			_peek_slice = _make_monster(nid)
			_stamp_pack(_peek_slice, _pack_tier_for(nid, monsters_by_id, int(monsters_by_id.get(nid, {}).get("tier", 1))), "draft")
		else:
			_peek_slice = {}
	elif not _peek_slice.is_empty():
		_apply_formulas_to(_peek_slice)
	if _deck_hovering:
		_fill_inspect_from_deck()


func _on_deck_hovered() -> void:
	if _cabin_up():
		return
	if _fly_card != null:
		return
	if challenge_deck.is_empty() or _peek_slice.is_empty():
		_sync_challenge_peek()
	if _peek_slice.is_empty():
		return
	if sfx and not _deck_hovering:
		sfx.hover()
	_deck_hovering = true
	_fill_inspect_from_deck()


func _on_deck_unhovered() -> void:
	_deck_hovering = false
	if _cabin_up():
		return
	if _fly_card != null:
		return
	if wheel_view != null and int(wheel_view.hover_index) >= 0:
		_fill_inspect_from_slice(int(wheel_view.hover_index))
	else:
		_idle_inspect()


func _on_deck_edit() -> void:
	if _peek_slice.is_empty():
		return
	_open_content_editor("monster", str(_peek_slice.get("card_id", "")))


func _fill_inspect_from_deck() -> void:
	if _cabin_up():
		_hide_fight_hover()
		return
	if inspect:
		inspect.visible = false
	if fly_tip == null:
		return
	if _peek_slice.is_empty():
		_idle_inspect()
		return
	_apply_formulas_to(_peek_slice)
	var s: Dictionary = _peek_slice
	var rule: Dictionary = _monster_rule(s)
	var body: String = str(rule.get("speech", ""))
	var port: Texture2D = null
	if art != null:
		port = art.monster_still(str(s.get("card_id", "")))
	fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), body, str(rule.get("warn", "")), port, "monster", str(s.get("card_id", "")), _monster_plate_look(s, rule))
	var at := Vector2.INF
	if dungeon_deck_ui != null:
		at = dungeon_deck_ui.get_global_rect().get_center()
	_place_fly(dungeon_deck_ui, at)


func _refresh() -> void:
	_sync_log_panel()
	_sync_wheel_stats()
	_refresh_hearts()
	_refresh_blk(true)
	_refresh_face()
	_sync_challenge_peek()
	if trophy:
		if mobs_defeated != _slain_shown and _slain_shown >= 0:
			trophy.set_count(mobs_defeated, mobs_defeated > _slain_shown)
			if sfx and mobs_defeated > _slain_shown:
				sfx.play("bong", -8.0, 0.85)
				sfx.play("pluck", -10.0, 1.35)
		else:
			trophy.set_count(mobs_defeated, false)
		_slain_shown = mobs_defeated

	var mode: String = "none"
	if not pending_mark.is_empty() and phase == "fighting":
		mode = "mark"
		var mk: String = str(pending_mark.get("kind", ""))
		for i in wheel.size():
			wheel[i]["markable"] = _can_mark(i, mk)
	else:
		for i2 in wheel.size():
			wheel[i2]["markable"] = false
		if (phase == "draft" and draft_action == "seat") or phase == "devtest":
			mode = "place"
	if wheel_view:
		wheel_view.set_slices(wheel, facing_index, mode)
		wheel_view.draft_glow = phase == "draft"

	_set_cue(_cue_text())
	_rebuild_tray()
	_sync_hotbar()
	_rebuild_choice()
	_sync_buttons()
	_sync_overlay()
	_sync_dev_panel()
	if adventure:
		call_deferred("_layout_play_field")


func _cue_text() -> String:
	match phase:
		"draft":
			if _mill_beat == "watch":
				return PLAYER_COPY.text("cue.starters", "Starters take north, east, south, and west.")
			if _mill_beat == "force":
				return PLAYER_COPY.text("cue.force", "Out of time")
			if draft_action == "ask":
				if refusals_left <= 0:
					return PLAYER_COPY.text("cue.steal", "Out of time")
				return PLAYER_COPY.text("cue.ask", "Take it or leave it?")
			if draft_action == "seat":
				return PLAYER_COPY.text("cue.seat", "A monster approaches. Select their location.")
			if draft_action == "busy":
				return ""
			if draft_action == "challenge_pick":
				return PLAYER_COPY.text("challenge.pick_open", "Pick one.")
			if draft_action == "challenge_begin":
				return PLAYER_COPY.text("challenge.begin_cue", "Begin when you're ready.")
			return PLAYER_COPY.text("cue.filling", "The nest is filling.")
		"devtest":
			return PLAYER_COPY.text("cue.devtest", "Click a monster to seat it, an item to add it to your hand. Play when you have at least one owner.")
		"rest":
			return PLAYER_COPY.fill("title.rest_sub", {"n": dungeons_cleared}, "Dungeon %s is behind you." % dungeons_cleared)
		"ready":
			if not pending_choice.is_empty():
				return "Highest Attack, Lowest Attack, or Off."
			if adventure:
				if challenge_aim < 0:
					return PLAYER_COPY.text("challenge.click_target", "Click who you fight, then Spin.")
				return PLAYER_COPY.text("challenge.spin_confirm", "Spin to lock that fight.")
			return PLAYER_COPY.text("cue.ready", "Spin — the nest turns.")
		"fighting":
			if not pending_feed.is_empty():
				if str(pending_feed.get("kind", "")) == "upgrade":
					return "Pick an item. I will upgrade it."
				return "Feed the cube one of those items."
			if not pending_chaos.is_empty():
				var need_n: int = int(pending_chaos.get("need", 1))
				if need_n <= 1:
					return "Click the other item to reroll it."
				return "Click two other items to reroll them."
			if not pending_mark.is_empty():
				if str(pending_mark.get("kind", "")) == "hypnotize" or str(pending_mark.get("kind", "")) == "defeat_double_hp":
					return "Click any monster."
				return PLAYER_COPY.text("cue.mark", "Click a neighboring enemy")
			if facing_index >= 0 and _wick_waiting(facing_index):
				return "They are at 0 HP. Click Done."
			return PLAYER_COPY.text("cue.fighting", "Click an item, or take the hit")
		"slaying":
			return ""
		"spinning":
			return ""
		_:
			return ""


func _sync_buttons() -> void:
	var busy: bool = phase == "spinning" or phase == "slaying" or (phase == "draft" and draft_action == "busy") or _wheel_busy() or _adventure_busy
	var enemy_up: bool = phase == "fighting" and facing_index >= 0 and (int(wheel[facing_index].get("hp", 0)) > 0 or _wick_waiting(facing_index))
	var need_aim: bool = adventure and challenge_aim < 0 and not _challenge_force_spin
	btn_spin.disabled = busy or phase != "ready" or need_aim
	btn_done.disabled = busy or not enemy_up or not pending_feed.is_empty() or not pending_chaos.is_empty()
	btn_start.disabled = busy
	btn_place.visible = false
	btn_bribe.visible = false
	btn_spin.visible = phase == "ready"
	btn_done.visible = enemy_up
	if btn_challenge_begin:
		btn_challenge_begin.visible = adventure and phase == "draft" and draft_action == "challenge_begin"
		btn_challenge_begin.disabled = busy
	if btn_undo:
		btn_undo.visible = _undo_in_scope() and (phase == "fighting" or phase == "ready" or phase == "slaying")
		btn_undo.disabled = not _undo_can_undo()
	if btn_redo:
		btn_redo.visible = _undo_in_scope() and (phase == "fighting" or phase == "ready" or phase == "slaying")
		btn_redo.disabled = busy or not _undo_can_redo()
	if phase == "devtest":
		btn_spin.visible = false
		btn_done.visible = false
		if btn_undo:
			btn_undo.visible = false
		if btn_redo:
			btn_redo.visible = false
	btn_start.visible = _authoring() and (phase == "title" or (overlay != null and overlay.visible))
	btn_start.modulate = Color.WHITE
	if in_tutorial:
		btn_start.disabled = true
		btn_spin.disabled = busy or phase != "ready" or tut == null or (tut.wait != "spin" and tut.wait != "auto_spin")
		btn_done.disabled = busy or not enemy_up or tut == null or (tut.wait != "done" and tut.wait != "choice")
	if enemy_up:
		var hit: int = _incoming_hit()
		btn_done.text = PLAYER_COPY.fill("combat.take_hit", {"n": hit}, "Take %s" % hit) if hit > 0 else PLAYER_COPY.text("combat.safe", "Safe")


func _sync_overlay() -> void:
	if home_cabin != null and home_cabin.visible:
		overlay.visible = false
		if rope_exit:
			rope_exit.visible = false
		return
	if _unlock_screen:
		_hide_board_for_unlock()
		return
	if in_tutorial and tut != null and tut.visible:
		overlay.visible = false
		return
	if phase == "title":
		overlay.visible = false
		if rope_exit:
			rope_exit.visible = false
		if home_cabin:
			home_cabin.items_by_id = items_by_id
			home_cabin.tex_by_item = tex_by_item
			home_cabin.buckets_open = _buckets_revealed
			if home_cabin.intro_pending():
				home_cabin.play_intro()
			elif not home_cabin.visible:
				home_cabin.show_menu()
			get_tree().paused = true
		return
	if phase == "rest":
		overlay.visible = false
		if rope_exit:
			rope_exit.open_exit(dungeons_cleared)
		return
	if phase == "victory":
		overlay.visible = false
		return
	var show_defeat: bool = phase == "defeat"
	overlay.visible = show_defeat
	if overlay_dive:
		overlay_dive.visible = false
	if overlay_tut:
		overlay_tut.visible = false
	if overlay_adventure:
		overlay_adventure.visible = false
	if overlay_home:
		overlay_home.visible = false
	if overlay_dev:
		overlay_dev.visible = false
	if overlay_latest:
		overlay_latest.visible = false
	if overlay_tools_row:
		overlay_tools_row.visible = false
	if overlay_rest_row:
		overlay_rest_row.visible = false
	if overlay_sub:
		overlay_sub.visible = false
	if overlay_btn:
		overlay_btn.visible = true
	if overlay_undo:
		overlay_undo.visible = _undo_can_undo() and phase == "defeat"
	if overlay_score:
		overlay_score.visible = adventure and phase == "defeat"
		if overlay_score.visible:
			overlay_score.text = PLAYER_COPY.fill("title.dungeons_cleared", {"n": dungeons_cleared}, "Dungeons cleared: %s" % dungeons_cleared)
	if phase == "defeat":
		overlay_title.text = PLAYER_COPY.text("title.lose", "Caught")
		overlay_btn.text = PLAYER_COPY.text("defeat.home", "")


func _rebuild_tray() -> void:
	_clear_box(tray)
	tray.visible = false
	call_deferred("_layout_play_field")


func _monster_chip(s: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.custom_minimum_size = Vector2(220, 118)
	var look: Dictionary = _monster_look(s)
	var sb := StyleBoxFlat.new()
	sb.bg_color = look.get("fill", Color("241c18"))
	sb.border_color = look.get("metal", Color("c4a574"))
	var bw: int = 3
	var tier: int = int(look.get("tier", 1))
	if tier == 2:
		bw = 4
	elif tier >= 3:
		bw = 5
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(4 if tier >= 3 else (8 if tier == 2 else 12))
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	p.add_child(row)
	var ic := TextureRect.new()
	ic.texture = tex_by_monster.get(str(s.get("card_id", "")), null)
	if art != null:
		var port: Texture2D = art.monster_still(str(s.get("card_id", "")))
		if port != null:
			ic.texture = port
	ic.custom_minimum_size = Vector2(36, 36)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(ic)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	row.add_child(col)
	var n := Label.new()
	n.text = _title_case(str(s.get("name", "?")))
	n.add_theme_font_size_override("font_size", 18)
	n.add_theme_color_override("font_color", Color("f0e6d8"))
	col.add_child(n)
	var stats := Label.new()
	stats.text = "%s / %s" % [s.get("atk", 0), s.get("hp", 0)]
	stats.add_theme_font_size_override("font_size", 22)
	stats.add_theme_color_override("font_color", Color("ffffff"))
	col.add_child(stats)
	var spec := Label.new()
	var chip_rule: Dictionary = _monster_rule(s)
	var st: String = str(chip_rule.get("reminder", ""))
	spec.text = st if st != "" else "No special"
	spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spec.add_theme_font_size_override("font_size", 13)
	spec.add_theme_color_override("font_color", Color("c9b9a8"))
	spec.custom_minimum_size = Vector2(160, 0)
	col.add_child(spec)
	p.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_open_content_editor("monster", str(s.get("card_id", "")))
	)
	p.mouse_entered.connect(func() -> void:
		if fly_tip == null:
			return
		_fly_card = p
		var rule: Dictionary = _monster_rule(s)
		fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), "", str(rule.get("warn", "")), null, "monster", str(s.get("card_id", "")), _monster_plate_look(s, rule))
		_place_fly(p)
	)
	p.mouse_exited.connect(_on_item_unhovered)
	return p


func _sync_hotbar() -> void:
	if hotbar_box is GridContainer:
		hotbar_box.columns = 5 if adventure else 12
	if hotbar_panel:
		hotbar_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if adventure:
			var hsb := StyleBoxFlat.new()
			hsb.bg_color = Color("14100ce8")
			hsb.border_color = Color("c4a574")
			hsb.set_border_width_all(2)
			hsb.set_corner_radius_all(8)
			hsb.content_margin_left = 6
			hsb.content_margin_right = 6
			hsb.content_margin_top = 6
			hsb.content_margin_bottom = 6
			hotbar_panel.add_theme_stylebox_override("panel", hsb)
		else:
			hotbar_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var gutter_px: int = int(round(_wheel_side_gutter() if adventure else 0.0))
	if hotbar_wrap:
		hotbar_wrap.add_theme_constant_override("margin_right", gutter_px)
	if btn_wrap:
		btn_wrap.add_theme_constant_override("margin_right", gutter_px)
	var sig := PackedStringArray()
	for it in hotbar:
		var echo_id: String = ""
		if typeof(it.get("echo_copy", null)) == TYPE_DICTIONARY:
			echo_id = str((it["echo_copy"] as Dictionary).get("card_id", ""))
		sig.append("%s:%s:%s:%s" % [it.get("uid", 0), it.get("card_id", ""), echo_id, it.get("petrified", false)])
	var empties: int = (CHALLENGE_HAND - hotbar.size()) if adventure else 0
	var joined: String = ",".join(sig) + "|e%s|d%s" % [empties, 1 if _challenge_loot_wait else 0]
	if joined != _hotbar_sig:
		_hotbar_sig = joined
		for c in hotbar_box.get_children():
			hotbar_box.remove_child(c)
			c.queue_free()
		for it in hotbar:
			if typeof(it) != TYPE_DICTIONARY:
				continue
			var spawned: Control = _spawn_item_card(it, true)
			if spawned:
				hotbar_box.add_child(spawned)
		if adventure:
			for _e in range(maxi(0, empties)):
				hotbar_box.add_child(_make_hot_empty())
	for c in hotbar_box.get_children():
		var card = c
		if not card.has_method("set_live"):
			continue
		var it: Dictionary = _find_item(int(card.uid))
		if it.is_empty():
			continue
		var view: Dictionary = _item_view(it)
		var uid_n: int = int(it.get("uid", -1))
		var spent_n: bool = bool(it.get("spent", false))
		var feed_uids: Array = pending_feed.get("uids", []) if not pending_feed.is_empty() else []
		var is_snack: bool = feed_uids.has(uid_n)
		var in_fight: bool = phase == "fighting"
		var magnet_ready: bool = phase == "ready" and _is_magnet(it)
		var can_click: bool = false
		if _challenge_loot_wait:
			can_click = true
		elif not pending_feed.is_empty():
			can_click = is_snack
		else:
			can_click = (in_fight or magnet_ready) and bool(view["can_use"]) and not spent_n and not bool(it.get("petrified", false))
		card.spent = spent_n
		card.set_palette(view["fill"], view["rim"], _tier_of(it))
		card.set_live(str(view["number"]), str(view["note"]), can_click)
		if card.has_method("set_playable"):
			card.set_playable(can_click)
		if card.has_method("set_petrified"):
			card.set_petrified(bool(it.get("petrified", false)))
		var head_on: bool = _is_arrow_head(it)
		var mag_on: bool = _is_magnet(it) and _magnet_mode_of(it) != "off"
		if card.has_method("set_aura"):
			card.set_aura(is_snack or (head_on and phase == "fighting") or (mag_on and (phase == "fighting" or phase == "ready")))
		if card.has_method("set_passive_icons"):
			if head_on:
				card.set_passive_icons(tex_plus, tex_special.get("pierce", tex_by_item.get("quiet_bell", tex_plus)), true)
			else:
				card.set_passive_icons(null, null, false)
	_sync_hotbar_formulas()


func _make_hot_empty() -> Control:
	return HOT_EMPTY.new()


func _spawn_item_card(it: Dictionary, usable: bool) -> PanelContainer:
	var view: Dictionary = _item_view(it)
	var card = ITEM_CARD.new()
	var show_id: String = str(it.get("card_id", ""))
	var show_name: String = str(it.get("name", "?"))
	if show_id == "echo_bell":
		var face: Dictionary = _echo_face(it)
		if not face.is_empty():
			show_id = str(face.get("card_id", show_id))
			show_name = str(face.get("name", show_name))
	var icon: Texture2D = tex_by_item.get(show_id, tex_sword)
	if art != null:
		var pix: Texture2D = art.item_tex(show_id)
		if pix != null:
			icon = pix
	var k: String = str(view.get("kind", "ATK"))
	card.setup(
		int(it.get("uid", 0)),
		str(it.get("card_id", "")),
		str(view["number"]),
		icon,
		view["fill"],
		view["rim"],
		_title_case(show_name),
		_num_color(k),
		k,
		_kind_mark(k)
	)
	if card.has_method("set_echo_mark") and str(it.get("card_id", "")) == "echo_bell" and art != null:
		card.set_echo_mark(art.item_tex("echo_bell"))
	if card.has_method("set_petrified"):
		card.set_petrified(bool(it.get("petrified", false)))
	if card.has_method("set_aura"):
		card.set_aura(_is_arrow_head(it) and phase == "fighting")
	if card.has_method("set_passive_icons"):
		if _is_arrow_head(it):
			card.set_passive_icons(tex_plus, tex_special.get("pierce", tex_plus), true)
		else:
			card.set_passive_icons(null, null, false)
	card.set_palette(view["fill"], view["rim"], _tier_of(it))
	var rule: Dictionary = _item_rule(it)
	card.set_formula(str(rule.get("equation", "")))
	card.set_live(str(view["number"]))
	card.show_formula(_shift_held)
	card.hovered.connect(func() -> void:
		_on_item_hovered(it, card)
	)
	card.unhovered.connect(_on_item_unhovered)
	if _authoring():
		card.edit_wanted.connect(_open_content_editor.bind("item", str(it.get("card_id", ""))))
	if usable:
		card.picked.connect(_use_item.bind(int(it.get("uid", 0))))
		_attach_hand_glint(card, str(it.get("card_id", "")))
	return card


func _attach_hand_glint(card: Control, card_id: String) -> void:
	if home_cabin == null or card_id == "" or home_cabin.is_swiped(card_id):
		return
	if BucketRules.is_token(items_by_id.get(card_id, {}).get("bucket", 0)):
		return
	var glint := AnimatedSprite2D.new()
	glint.centered = true
	glint.position = card.size * 0.5
	glint.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glint.material = mat
	var sf := SpriteFrames.new()
	sf.add_animation("g")
	sf.set_animation_speed("g", 12.0)
	sf.set_animation_loop("g", false)
	for i in 5:
		var tex: Texture2D = load("res://assets/dungeon/home/fx/hand_glint_f%d.png" % i) if ResourceLoader.exists("res://assets/dungeon/home/fx/hand_glint_f%d.png" % i) else null
		if tex:
			sf.add_frame("g", tex)
	glint.sprite_frames = sf
	card.add_child(glint)
	var timer := Timer.new()
	timer.wait_time = randf_range(4.0, 7.0)
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func() -> void:
		if is_instance_valid(glint) and glint.sprite_frames:
			glint.play("g")
		if is_instance_valid(timer) and timer.is_inside_tree():
			timer.wait_time = randf_range(4.0, 7.0)
			timer.start()
	)
	card.add_child(timer)


func _on_item_hovered(it: Dictionary, card: Control = null) -> void:
	if _cabin_up():
		return
	_fly_card = card
	if sfx:
		sfx.hover()
	var rule: Dictionary = _item_rule(it)
	if fly_tip:
		fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), str(rule["body"]), str(rule["warn"]), null, "item", str(it.get("card_id", "")), _item_look(it))
		_place_fly(card)
	_apply_preview(_preview_from_item(it))
	_refresh_blk(false)
	_tutorial_on_item_hover()


func _on_item_unhovered() -> void:
	_fly_card = null
	_ghost_blk = -1
	_apply_preview({})
	if fly_tip:
		fly_tip.hide_plate()
	if _cabin_up():
		return
	if _deck_hovering:
		_fill_inspect_from_deck()
	elif wheel_view != null and int(wheel_view.hover_index) >= 0:
		_fill_inspect_from_slice(int(wheel_view.hover_index))
	else:
		_idle_inspect()


func _clear_box(box: Node) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _rebuild_choice() -> void:
	_clear_box(choice_box)
	if not pending_feed.is_empty():
		for uid in pending_feed.get("uids", []):
			var it: Dictionary = _find_item(int(uid))
			if it.is_empty():
				continue
			var upgrading: bool = str(pending_feed.get("kind", "")) == "upgrade"
			var lab: String = ("Upgrade  %s" if upgrading else "Feed  %s") % _title_case(str(it.get("name", "?")))
			var ob: Button = _pill(lab, Color("3a1c14"), Color("e8c36a"), _feed_cube.bind(int(uid)))
			choice_box.add_child(ob)
		return
	if pending_choice.is_empty():
		return
	for opt in pending_choice.get("options", []):
		var lab: String = str(opt.get("label", "?"))
		var oid: String = str(opt.get("id", ""))
		if oid == "throw":
			lab = PLAYER_COPY.text("combat.knife_throw", lab)
		elif oid == "nick":
			lab = PLAYER_COPY.text("combat.knife_nick", lab)
		var ob: Button = _pill(lab, Color("3a3220"), Color("e8c36a"), _choose_option.bind(opt))
		choice_box.add_child(ob)


func _start_tutorial() -> void:
	_hide_cabin_for_run()
	_tut_boot = true
	_tut_next_dungeon = false
	_tut_intro_step = {}
	_tut_d2_done = {}
	_tut_d2_focus = ""
	_tut_d2_busy = false
	_tut_d2_pending = ""
	_upgraded_slices = []
	in_tutorial = true
	_reset_run()
	_tut_boot = false
	var seats: Array[String] = ["wizard", "golem", "goblin"]
	var slots: Array[int] = [0, 2, 4]
	for k in range(seats.size()):
		var m: Dictionary = _make_monster(seats[k])
		var si: int = slots[k]
		m["slot"] = SLOT_ORDER[si]
		m["spin_locked"] = false
		wheel[si] = m
		_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	for iid in ["sai", "helmet", "da_boot", "knucklers"]:
		hotbar.append(_make_item(iid))
		_log("on_place", "item  %s" % iid)
	_sort_hotbar()
	_sync_wheel_stats()
	phase = "ready"
	_log("on_click", "Tutorial")
	_log("var", "HP %s" % hp)
	if sfx:
		sfx.play("book", -10.0)
		sfx.play("door_open", -8.0)
	if tut:
		tut.open()
	_refresh()
	_tut_refresh_focus()


func _tut_on_continue() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "continue":
		return
	if sfx:
		sfx.play("click", -12.0)
	tut.advance()
	_tut_after_advance()


func _tut_skip() -> void:
	if sfx:
		sfx.play_event(&"tut.skip")
	in_tutorial = false
	if tut:
		tut.close()
	if home_cabin:
		home_cabin.tutorial_declined = true
		home_cabin._save()
	_reset_run()
	phase = "title"
	_refresh()


func _tut_finished() -> void:
	in_tutorial = false
	if tut:
		tut.close()
	if home_cabin:
		home_cabin.tutorial_done = true
		home_cabin._save()
	_reset_run()
	phase = "title"
	_refresh()


func _tut_after_advance() -> void:
	_tut_refresh_focus()
	_sync_buttons()
	if tut != null and tut.visible and tut.wait == "auto_spin":
		call_deferred("_on_spin")


func _tut_refresh_focus() -> void:
	if tut == null or not in_tutorial or not tut.visible:
		return
	_tutorial_stage_dungeon2()
	var spots: Array = []
	var arrows: Array = []
	_tut_collect_spots(spots, arrows)
	tut.set_spots(spots, arrows)


func _tut_d2_want() -> String:
	var said: String = tut.spoken().to_lower()
	if said.find("pick loot") >= 0 or said.find("two items") >= 0 or said.find("draft new") >= 0 or (said.find("remaining") >= 0 and said.find("item") >= 0):
		return "draft"
	if said.find("nastier") >= 0 or said.find("upgraded") >= 0 or said.find("more dangerous") >= 0:
		return "upgrade"
	if said.find("six monsters") >= 0 or said.find("face-down") >= 0 or said.find("starting monster") >= 0 or said.find("build a new dungeon") >= 0:
		return "seat"
	if said.find("survived all") >= 0 or said.find("venture deeper") >= 0 or said.find("challenge mode") >= 0:
		return "arrive"
	return ""


func _tutorial_stage_dungeon2() -> void:
	var want: String = _tut_d2_want()
	_tut_d2_focus = want
	if want == "" or want == "arrive":
		return
	_tut_d2_pending = want
	if _tut_d2_busy or bool(_tut_d2_done.get(want, false)):
		return
	_tutorial_d2_catchup()


func _tutorial_d2_catchup() -> void:
	var order: Array[String] = ["seat", "upgrade", "draft"]
	var target: int = order.find(_tut_d2_pending)
	if target < 0:
		return
	_tut_d2_busy = true
	for i in range(target + 1):
		var step: String = order[i]
		if bool(_tut_d2_done.get(step, false)):
			continue
		_tut_d2_done[step] = true
		if step == "seat":
			await _tutorial_d2_seat()
		elif step == "upgrade":
			await _upgrade_two_openers()
		elif step == "draft":
			await _challenge_run_opening_drafts()
	_tut_d2_busy = false
	var latest: String = _tut_d2_want()
	if latest != "" and latest != "arrive" and not bool(_tut_d2_done.get(latest, false)):
		_tut_d2_pending = latest
		_tutorial_d2_catchup()


func _tutorial_d2_seat() -> void:
	adventure = true
	dungeons_cleared = 1
	dungeon_index = 2
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	_upgraded_slices = []
	if overlay:
		overlay.visible = false
	phase = "draft"
	draft_action = "busy"
	if dungeon_bg:
		dungeon_bg.bump_hall()
	if sfx:
		sfx.play("door_open", -8.0)
		sfx.play("whoosh", -10.0, 0.9)
	_prep_next_dungeon()
	_refresh()
	await _challenge_seat_dungeon(false)


func _tut_add_control(spots: Array, node: Control) -> void:
	if node == null or not is_instance_valid(node) or not node.is_visible_in_tree():
		return
	var r: Rect2 = node.get_global_rect()
	if r.size.x < 4.0 or r.size.y < 4.0:
		return
	spots.append(r.grow(8.0))


func _tut_add_rect(spots: Array, r: Rect2) -> void:
	if r.size.x < 4.0 or r.size.y < 4.0:
		return
	spots.append(r.grow(6.0))


func _tut_fight_open(spots: Array) -> void:
	if wheel_view != null:
		_tut_add_rect(spots, wheel_view.focus_rect("face"))
	_tut_add_control(spots, combat_stage)
	_tut_add_control(spots, face_box)
	_tut_add_control(spots, inspect)
	_tut_add_control(spots, speech_box)


func _tut_collect_spots(spots: Array, arrows: Array) -> void:
	var tag: String = tut.focus_tag
	var waiting: String = tut.wait
	if waiting == "choice":
		var boot: Control = _hotbar_card("da_boot")
		_tut_add_control(spots, boot)
		_tut_add_control(spots, btn_done)
		var a: Vector2 = boot.get_global_rect().get_center() if boot != null and boot.is_visible_in_tree() else Vector2.ZERO
		var b: Vector2 = btn_done.get_global_rect().get_center() if btn_done != null and btn_done.visible else Vector2.ZERO
		var origin: Vector2 = Vector2.ZERO
		if a != Vector2.ZERO and b != Vector2.ZERO:
			origin = (a + b) * 0.5 + Vector2(0.0, -110.0)
		elif a != Vector2.ZERO:
			origin = a + Vector2(0.0, -90.0)
		elif b != Vector2.ZERO:
			origin = b + Vector2(0.0, -90.0)
		if a != Vector2.ZERO:
			arrows.append([origin, a])
		if b != Vector2.ZERO:
			arrows.append([origin, b])
		return
	if tag == "atk" and wheel_view != null:
		_tut_add_rect(spots, wheel_view.focus_rect("atk"))
		return
	if tag == "hp" and wheel_view != null:
		_tut_add_rect(spots, wheel_view.focus_rect("hp"))
		return
	if tag == "hp_math" and wheel_view != null:
		var hub: Rect2 = wheel_view.focus_rect("hub_hp")
		var mon: Rect2 = wheel_view.focus_rect("hp")
		var helm: Control = _hotbar_card("helmet")
		_tut_add_rect(spots, hub)
		_tut_add_rect(spots, mon)
		_tut_add_control(spots, helm)
		if helm != null and helm.is_visible_in_tree():
			var hc: Vector2 = helm.get_global_rect().get_center()
			if hub.size.x > 4.0:
				arrows.append([hub.get_center(), hc])
			if mon.size.x > 4.0:
				arrows.append([mon.get_center(), hc])
		return
	if tag == "block" and wheel_view != null:
		_tut_add_rect(spots, wheel_view.focus_rect("hub_blk"))
		return
	if tag == "empty" and wheel_view != null:
		_tut_add_rect(spots, wheel_view.focus_rect("empty"))
		return
	if tag == "hearts":
		_tut_add_control(spots, hearts_box)
		if wheel_view != null:
			_tut_add_rect(spots, wheel_view.focus_rect("hub_hp"))
		return
	if _tut_d2_focus == "seat":
		_tut_add_control(spots, wheel_view)
		_tut_add_control(spots, dungeon_deck_ui)
		return
	if _tut_d2_focus == "upgrade":
		_tut_add_upgrade_slices(spots)
		return
	if _tut_d2_focus == "draft":
		_tut_add_control(spots, hotbar_box)
		_tut_add_control(spots, challenge_draft_ui)
		if draft_gate != null and draft_gate.visible and draft_gate.has_method("gate_rect"):
			var gate: Rect2 = draft_gate.gate_rect()
			if gate.size.x > 4.0:
				spots.append(gate.grow(12.0))
		return
	if _tut_d2_focus == "arrive":
		return
	var node: Control = _tut_focus()
	_tut_add_control(spots, node)
	if tag == "" and _tut_is_intro_beat():
		_tut_fight_open(spots)


func _tut_is_intro_beat() -> bool:
	if phase != "fighting" and phase != "slaying":
		return false
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var id: String = str(wheel[facing_index].get("card_id", ""))
	if id == "":
		return false
	var at: int = tut.step
	if not _tut_intro_step.has(id):
		_tut_intro_step[id] = at
	return int(_tut_intro_step[id]) == at


func _tut_add_upgrade_slices(spots: Array) -> void:
	if wheel_view == null:
		return
	var any: bool = false
	for raw in _upgraded_slices:
		var r: Rect2 = wheel_view.slice_rect(int(raw))
		if r.size.x < 4.0:
			continue
		_tut_add_rect(spots, r)
		any = true
	if not any:
		_tut_add_control(spots, wheel_view)


func _tut_focus() -> Control:
	if tut == null:
		return null
	var tag: String = tut.focus_tag
	match tag:
		"wheel", "empty", "atk", "hp", "block":
			return wheel_view
		"hearts":
			return hearts_box
		"hotbar":
			return hotbar_box
		"spin":
			return btn_spin
		"done":
			return btn_done
		"trophy":
			return trophy
		"face":
			return face_box
		"inspect":
			return inspect
		_:
			if tag.begins_with("item:"):
				return _hotbar_card(tag.substr(5))
	return null


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


func _tutorial_spin_index() -> int:
	if tut != null and str(tut.force_id) != "":
		var forced: int = _index_of_monster(str(tut.force_id))
		if forced >= 0:
			return forced
	for id in ["wizard", "golem", "goblin", "berserker"]:
		var i: int = _index_of_monster(id)
		if i >= 0:
			return i
	return -1


func _tutorial_allows_item(id: String) -> bool:
	if tut == null:
		return false
	var w: String = tut.wait
	if w == "choice":
		return id == "da_boot"
	if not w.begins_with("item:"):
		return false
	return w == "item:%s" % id


func _tutorial_item_used(id: String) -> void:
	if tut == null or not in_tutorial:
		return
	if tut.wait == "choice" and id == "da_boot":
		tut.choice = "boot"
		return
	if tut.wait != "item:%s" % id:
		return
	if id == "da_boot":
		tut.choice = "boot"
		return
	tut.advance()
	_tut_after_advance()


func _tutorial_combat_started() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "spin" and tut.wait != "auto_spin":
		return
	tut.advance()
	_tut_after_advance()


func _tutorial_after_fight() -> void:
	if not in_tutorial or tut == null:
		return
	var w: String = tut.wait
	if w == "choice" or w == "item:da_boot":
		if tut.choice == "":
			tut.choice = "take"
		tut.advance()
		_tut_after_advance()
		return
	if w == "done":
		tut.advance()
		_tut_after_advance()


func _tutorial_on_item_hover() -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_item":
		return
	tut.advance()
	_tut_after_advance()


func _tutorial_on_slice_hover(index: int) -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait == "hover_shift":
		_tutorial_try_shift_inspect()
		return
	if tut.wait != "hover_slice:berserker":
		return
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("card_id", "")) != "berserker":
		return
	tut.advance()
	_tut_after_advance()


func _tutorial_try_shift_inspect() -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_shift":
		return
	if not _shift_held:
		return
	if wheel_view == null:
		return
	var hi: int = int(wheel_view.hover_index)
	if hi < 0 or hi >= wheel.size():
		return
	if str(wheel[hi].get("kind", "")) != "monster":
		return
	var reveal: String = tut.then_focus
	if reveal == "inspect" and facing_index >= 0 and facing_index < wheel.size():
		_hover_slice = facing_index
		_fill_inspect_from_slice(facing_index)
	tut.advance()
	if reveal != "" and tut.focus_tag == "":
		tut.focus_tag = reveal
	_tut_after_advance()
