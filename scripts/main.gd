extends Control
## Full loop: title, mill gate draft, combat, victory/defeat.

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
const FILL_YELLOW := Color("4a3d14")
const STARTER_COUNT := 4
const STARTER_ITEM_COUNT := 4
const REFUSALS_MAX := 3
const DRAFT_ROUNDS := 4
const DEV_ITEM_MAX := 50
const HAND_MAX := 50

const LOG_KIND := {
	"on_click": {"hex": "#E8C36A", "tag": "On Click"},
	"on_spin": {"hex": "#6EC8E8", "tag": "On Spin"},
	"on_item_use": {"hex": "#E07A3D", "tag": "On Item Use"},
	"on_resolve": {"hex": "#F0E6D8", "tag": "On Resolve"},
	"on_remove_slice": {"hex": "#D19A66", "tag": "On Remove Slice"},
	"on_draft": {"hex": "#8DCB8D", "tag": "On Draft"},
	"on_place": {"hex": "#A3BE8C", "tag": "On Place"},
	"on_bribe": {"hex": "#D19A66", "tag": "On Bribe"},
	"var": {"hex": "#C9A0FF", "tag": "Var"},
	"atk": {"hex": "#E06C75", "tag": "ATK"},
	"blk": {"hex": "#6BB3D9", "tag": "BLK"},
	"hp": {"hex": "#E06C75", "tag": "HP"},
	"discard": {"hex": "#8A8178", "tag": "Discard"},
	"keep": {"hex": "#A3BE8C", "tag": "Keep"},
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
	"bracers": {"kind": "blk_neighbor"},
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
	"pocketwatch": {"kind": "atk_strong_neighbor"},
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
	"measuring_tape": {"kind": "atk_hp_gap"},
	"mute_stone": {"kind": "chaos_reroll"},
	"cursed_scroll": {"kind": "heal_full"},
	"spider_egg": {"kind": "egg_hurt", "n": 2},
}

const MONSTER_SPECIAL := {
	"goblin": {"id": "no_atk_dmg", "text": "Cannot receive ATK damage. Defeat still works."},
	"skeleton": {"id": "last_hp", "text": "HP = last enemy's HP when you spun them. First fight: 3."},
	"hornet_swarm": {"id": "double_hit", "text": "Attacks twice. Block is spent on the first swing."},
	"lich": {"id": "buff_hp", "text": "+1 HP to neighbors after other modifiers."},
	"ogre": {"id": "hp_spin", "text": "When you lose HP, I lose equal HP."},
	"berserker": {"id": "kill_scale", "text": "I alternate between 3, 4, and 8 Attack every time you Spin."},
	"dire_wolf": {"id": "atk_spin", "text": "ATK = your HP when this slice is spun."},
	"bandit": {"id": "item_atk", "text": "ATK = items in hand when combat starts."},
	"two_headed_serpent": {"id": "two_items", "text": "My Neighbors will attack you (Left, then Right), then I will Heal you for 3 HP."},
	"slime_boss": {"id": "atk_eq_hp", "text": "ATK always equals current HP."},
	"leech_league": {"id": "pack_hp", "text": "HP = 1 + monsters still on the wheel."},
	"wraith": {"id": "copy_atk", "text": "Copies the higher neighboring attack, then Commander."},
	"mimic": {"id": "gift", "text": "If I go down before I swing, you gain an item."},
	"spider_queen": {"id": "queen_hits", "text": "Each time you Spin, Gain 1 Spider Egg."},
	"commander": {"id": "buff_atk", "text": "+2 ATK to neighbors. The first time I would leave, I flee and shuffle."},
	"dragon": {"id": "pierce", "text": "My attack ignores block."},
	"needleback": {"id": "thorns", "text": "Whenever I take attack damage, you take 1 attack. Block can stop that 1."},
	"gelatinous_cube": {"id": "eat_item", "text": "I make you feed me one of two items."},
	"gargoyle": {"id": "petrify", "text": "I petrify your highest Attack item until the next Spin."},
	"harpy": {"id": "interrupt", "text": "I attack you when we meet, and after each item you use."},
	"kobold_trapper": {"id": "item_swings", "text": "I attack an extra time for each item you use this fight."},
	"clockwork_knight": {"id": "split_t2", "text": "If I live, I leave two Tough monsters in my place."},
	"basilisk": {"id": "no_keep", "text": "I discard all items you use immediately while you face me."},
	"hollow": {"id": "even_twice", "text": "Even Attack and even Block happen twice against me."},
	"beggar": {"id": "left_atk", "text": "My Attack copies the Attack number on your leftmost Attack item. If you have none, my Attack is 3."},
	"wick": {"id": "wickrise", "text": "I gain 1 Attack and lose 1 HP whenever you use an item."},
	"anvil": {"id": "one_chip", "text": "I cannot lose more than 1 HP from one source."},
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


func _ready() -> void:
	PLAYER_COPY.reload()
	_load_textures()
	_load_catalog()
	_load_runtime()
	art = DUNGEON_ART.new()
	add_child(art)
	art.setup()
	_prefer_pixel_art()
	_build_ui()
	_empty_wheel()
	phase = "title"
	_refresh()
	if sfx:
		sfx.start_music()


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _authoring() -> bool:
	return OS.has_feature("editor")


func _prefer_pixel_art() -> void:
	if art == null:
		return
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
		"copy_atk": _tex("res://assets/icons/copy.svg"),
		"gift": _tex("res://assets/icons/layers.svg"),
		"queen_hits": _tex("res://assets/icons/swords.svg"),
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


func _load_runtime() -> void:
	var f := FileAccess.open(RUNTIME_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing runtime: %s" % RUNTIME_PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		runtime = parsed


func _build_ui() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	dungeon_bg = DUNGEON_BG.new()
	add_child(dungeon_bg)
	dungeon_bg.setup(art)

	theme = load("res://themes/swipe_theme.tres")
	play_field = Control.new()
	play_field.set_anchors_preset(PRESET_FULL_RECT)
	play_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_field.clip_contents = false
	play_field.resized.connect(_layout_play_field)
	add_child(play_field)

	trophy = TROPHY_MOUNT.new()
	var skull_tex: Texture2D = tex_by_monster.get("skeleton", tex_heart)
	if art != null and art.tile("skull") != null:
		skull_tex = art.tile("skull")
	trophy.setup(skull_tex)
	play_field.add_child(trophy)

	tray = HBoxContainer.new()
	tray.add_theme_constant_override("separation", 12)
	tray.alignment = BoxContainer.ALIGNMENT_CENTER
	tray.visible = false
	play_field.add_child(tray)

	wheel_view = WHEEL_SCRIPT.new()
	wheel_view.custom_minimum_size = Vector2(624, 624)
	play_field.add_child(wheel_view)
	wheel_view.set_atlas(tex_heart, tex_sword, tex_plus, tex_by_monster, tex_special, tex_shield)
	var heart_full: Texture2D = _tex("res://assets/icons/heart_full.png")
	var heart_empty: Texture2D = _tex("res://assets/icons/heart_empty.png")
	if art != null:
		wheel_view.set_portraits(art.portraits())
		wheel_view.set_player(art.frames("knight_m"))
		if art.tile("ui_heart_full") != null:
			heart_full = art.tile("ui_heart_full")
		if art.tile("ui_heart_empty") != null:
			heart_empty = art.tile("ui_heart_empty")
	wheel_view.set_hub_hearts(heart_full, heart_empty)
	wheel_view.z_index = 0
	trophy.z_index = 6
	tray.z_index = 7
	wheel_view.slice_clicked.connect(_on_slice_clicked)
	wheel_view.slice_hovered.connect(_on_slice_hovered)
	wheel_view.slice_right_clicked.connect(_on_slice_right_clicked)

	hud = WHEEL_HUD_SCN.instantiate()
	add_child(hud)
	hearts_box = hud.hearts_box
	cue_label = hud.cue_label
	btn_spin = hud.btn_spin
	btn_done = hud.btn_done
	btn_start = hud.btn_start
	btn_place = hud.btn_place
	btn_bribe = hud.btn_bribe
	hotbar_box = hud.hotbar_box
	choice_box = hud.choice_box
	var ht: Texture2D = heart_full if heart_full != null else tex_heart
	if art != null and art.tile("ui_heart_full") != null:
		ht = art.tile("ui_heart_full")
	hud.setup_hearts(ht)
	btn_spin.pressed.connect(_on_spin)
	btn_done.pressed.connect(_on_done)
	btn_start.pressed.connect(_on_new)
	btn_place.pressed.connect(_on_place_mode)
	btn_bribe.pressed.connect(_on_bribe_mode)
	btn_spin.mouse_entered.connect(_on_spin_hover.bind(true))
	btn_spin.mouse_exited.connect(_on_spin_hover.bind(false))
	btn_place.mouse_entered.connect(_on_place_hover.bind(true))
	btn_place.mouse_exited.connect(_on_place_hover.bind(false))
	btn_done.mouse_entered.connect(_on_done_hover.bind(true))
	btn_done.mouse_exited.connect(_on_done_hover.bind(false))

	blk_hud = PanelContainer.new()
	blk_hud.visible = false
	blk_value = Label.new()

	placement_ui = PLACEMENT_SCN.instantiate()
	placement_ui.visible = false
	hud.plate_slot.add_child(placement_ui)
	fight_ui = FIGHT_SCN.instantiate()
	fight_ui.visible = false
	hud.plate_slot.add_child(fight_ui)
	if fight_ui.btn_resolve:
		fight_ui.btn_resolve.pressed.connect(_on_done)
	inspect = INSPECT_SCN.instantiate()
	inspect.accept_clicks = true
	inspect.size_flags_horizontal = Control.SIZE_FILL
	inspect.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	hud.plate_slot.add_child(inspect)
	victory_ui = VICTORY_SCN.instantiate()
	victory_ui.visible = false
	hud.plate_slot.add_child(victory_ui)
	victory_ui.setup("victory")
	victory_ui.again_pressed.connect(_on_overlay_primary)
	defeat_ui = DEFEAT_SCN.instantiate()
	defeat_ui.visible = false
	hud.plate_slot.add_child(defeat_ui)
	defeat_ui.setup("defeat")
	defeat_ui.again_pressed.connect(_on_overlay_primary)
	if _authoring():
		inspect.edit_pressed.connect(_open_content_editor)
	_idle_inspect()

	dev_panel = VBoxContainer.new()
	dev_panel.visible = false
	dev_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dev_panel.add_theme_constant_override("separation", 8)
	hud.tools_slot.add_child(dev_panel)
	_build_dev_panel()

	log_btn = _pill("Log", Color("2a2622"), Color("6a5f52"), _toggle_log)
	log_btn.custom_minimum_size = Vector2(88, 34)
	log_btn.visible = false
	hud.tools_slot.add_child(log_btn)
	log_label = RichTextLabel.new()
	log_label.size_flags_vertical = Control.SIZE_SHRINK_END
	log_label.custom_minimum_size = Vector2(0, 110)
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	log_label.add_theme_font_size_override("normal_font_size", 12)
	log_label.visible = false
	log_label.add_theme_color_override("default_color", Color("d8cbb8"))
	hud.tools_slot.add_child(log_label)

	_build_overlay()
	_build_copy_stamp()
	fly_tip = HOVER_PANEL.new()
	fly_tip.visible = false
	fly_tip.z_index = 110
	fly_tip.top_level = true
	fly_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly_tip.accept_clicks = false
	add_child(fly_tip)
	if art != null:
		fly_tip.apply_skin(art.ui.get("panel_beige", null))

	talk_ui = TALK_BOX_SCN.instantiate()
	talk_ui.visible = false
	hud.plate_slot.add_child(talk_ui)
	tut = TUTORIAL_GUIDE.new()
	add_child(tut)
	tut.setup(art, talk_ui)
	tut.continued.connect(_tut_on_continue)
	tut.skipped.connect(_tut_skip)
	tut.finished.connect(_tut_finished)
	tut.auto_spin.connect(_tut_auto_spin)
	tut.play_adventure.connect(_tut_play_adventure)
	tut.mill_demo.connect(_tut_mill_demo)

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

	speech_box = SPEECH_BUBBLE.new()
	add_child(speech_box)
	speech_box.setup()

	draft_gate = DRAFT_GATE_SCN.instantiate()
	draft_gate.visible = false
	hud.plate_slot.add_child(draft_gate)
	draft_gate.setup(art)
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
	title_ui = TITLE_SCN.instantiate()
	add_child(title_ui)
	title_ui.setup(art)
	title_ui.visible = false
	title_ui.begin_pressed.connect(_begin_run)
	title_ui.how_pressed.connect(_start_tutorial)
	title_ui.dive_pressed.connect(_quick_start)
	title_ui.adventure_pressed.connect(_begin_adventure)
	title_ui.dev_pressed.connect(_open_dev_test)
	title_ui.roster_pressed.connect(_open_roster)
	title_ui.script_pressed.connect(_open_script)
	settings_ui.mode_picked.connect(_on_pause_mode)
	settings_ui.quit_pressed.connect(_quit_game)
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
		script_ed = SCRIPT_EDITOR.new()
		add_child(script_ed)
		script_ed.setup(sfx)
		script_ed.saved.connect(_on_script_saved)
	call_deferred("_layout_play_field")


func _build_overlay() -> void:
	overlay = ColorRect.new()
	overlay.color = Color("0c0908f4")
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var wrap := CenterContainer.new()
	wrap.set_anchors_preset(PRESET_FULL_RECT)
	overlay.add_child(wrap)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	wrap.add_child(col)
	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 64)
	overlay_title.add_theme_color_override("font_color", Color("e8c36a"))
	overlay_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	overlay_title.add_theme_constant_override("outline_size", 8)
	col.add_child(overlay_title)
	overlay_sub = Label.new()
	overlay_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_sub.custom_minimum_size = Vector2(720, 0)
	overlay_sub.add_theme_font_size_override("font_size", 20)
	overlay_sub.add_theme_color_override("font_color", Color("d8cbb8"))
	overlay_sub.add_theme_color_override("font_outline_color", Color("100e0c"))
	overlay_sub.add_theme_constant_override("outline_size", 3)
	col.add_child(overlay_sub)
	overlay_score = Label.new()
	overlay_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_score.add_theme_font_size_override("font_size", 32)
	overlay_score.add_theme_color_override("font_color", Color("e8c36a"))
	overlay_score.visible = false
	col.add_child(overlay_score)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	col.add_child(row)
	overlay_tut = _pill(PLAYER_COPY.text("title.how_to_play", "How to Play"), Color("3a2820"), Color("e8c36a"), _start_tutorial)
	overlay_dive = _pill(PLAYER_COPY.text("title.dive_in", "Dive In"), Color("2a2622"), Color("c4a574"), _quick_start)
	overlay_btn = _pill(PLAYER_COPY.text("title.begin", "Begin"), Color("2a2622"), Color("6a5f52"), _on_overlay_primary)
	overlay_adventure = _pill(PLAYER_COPY.text("title.adventure", "Adventure Mode"), Color("3a2820"), Color("e8c36a"), _begin_adventure)
	row.add_child(overlay_tut)
	row.add_child(overlay_dive)
	row.add_child(overlay_btn)
	row.add_child(overlay_adventure)
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
	_copy_stamp = Label.new()
	_copy_stamp.text = PLAYER_COPY.stamp()
	_copy_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_copy_stamp.add_theme_font_size_override("font_size", 12)
	_copy_stamp.add_theme_color_override("font_color", Color("8a8178"))
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
	_copy_stamp.visible = false
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


func _pill(text: String, fill: Color, rim: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	b.add_theme_color_override("font_hover_color", Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("c4a574"))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	b.add_theme_stylebox_override("normal", _sb(fill, rim, 2))
	b.add_theme_stylebox_override("hover", _sb(fill.lightened(0.16), rim.lightened(0.2), 3))
	b.add_theme_stylebox_override("pressed", _sb(fill.darkened(0.12), rim, 2))
	b.add_theme_stylebox_override("focus", _sb(fill, rim.lightened(0.35), 3))
	var dim := fill
	dim.a = 0.45
	b.add_theme_stylebox_override("disabled", _sb(dim, Color(rim.r, rim.g, rim.b, 0.35), 1))
	b.pressed.connect(cb)
	return b


func _sb(fill: Color, rim: Color, border: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = rim
	s.set_border_width_all(border)
	s.set_corner_radius_all(999)
	s.shadow_color = Color(0.05, 0.03, 0.02, 0.45)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 2)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


func _build_dev_panel() -> void:
	dev_enter = _pill("Play", Color("3a3220"), Color("e8c36a"), _dev_enter)
	dev_enter.custom_minimum_size = Vector2(0, 48)
	dev_panel.add_child(dev_enter)
	var sort_cap := Label.new()
	sort_cap.text = "Sort by"
	sort_cap.add_theme_font_size_override("font_size", 16)
	sort_cap.add_theme_color_override("font_color", Color("e8c36a"))
	dev_panel.add_child(sort_cap)
	var sort_row := HBoxContainer.new()
	sort_row.add_theme_constant_override("separation", 6)
	dev_panel.add_child(sort_row)
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
	_dev_review = ""
	_reset_run()
	phase = "devtest"
	draft_action = "place"
	if dev_panel:
		dev_panel.visible = true
	if log_label:
		log_label.visible = false
	_fill_dev_grids()
	_sync_dev_sort_btns()
	_log("on_click", "Developer Test")
	if sfx:
		sfx.play("book", -10.0)
	_refresh()


func _fill_dev_grids() -> void:
	if dev_mon_grid == null:
		return
	_clear_box(dev_mon_grid)
	_clear_box(dev_item_grid)
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		if _dev_review != "" and REVIEW_STAGE.of_card(card) != _dev_review:
			continue
		dev_mon_grid.add_child(_dev_tile(str(id), _title_case(str(card.get("name", id))), str(card.get("rarity", "")), int(card.get("tier", 0)), true))
	for id2 in runtime.get("items", []):
		var card2: Dictionary = items_by_id.get(str(id2), {})
		if card2.is_empty():
			continue
		if _dev_review != "" and REVIEW_STAGE.of_card(card2) != _dev_review:
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
	if hotbar.size() >= HAND_MAX:
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
	phase = "ready"
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_open", -8.0)
	_sync_wheel_stats()
	_refresh()


func _sync_dev_panel() -> void:
	if dev_panel == null or not dev_panel.visible:
		return
	if dev_mon_n:
		dev_mon_n.text = "Monsters  %s / 8" % _monsters_left()
	if dev_item_n:
		dev_item_n.text = "Items  %s / %s" % [hotbar.size(), HAND_MAX]
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
	if phase == "title":
		_begin_run()
	elif adventure:
		_begin_adventure()
	else:
		_begin_run()


func _reset_run() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	adventure = false
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1]
	_adventure_busy = false
	if dungeon_bg:
		dungeon_bg.reset_hall()
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
	if speech_box:
		speech_box.hide_speech()
	if not _tut_boot:
		in_tutorial = false
		if tut:
			tut.close()
	if wheel_view != null:
		wheel_view.kill_spin()
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
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	beads_step = 1
	_reroll_skip = -1
	draft_action = "place"
	starters_left = STARTER_COUNT
	starter_items_left = STARTER_ITEM_COUNT
	smoke_given = false
	drafts_left = DRAFT_ROUNDS
	if log_label:
		log_label.clear()
	if combat_stage:
		combat_stage.hide_stage()
	_fill_pools()
	_empty_wheel()
	if dev_panel:
		dev_panel.visible = false


func _begin_run() -> void:
	_reset_run()
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Begin")
	_log("var", "HP %s" % hp)
	_log("on_draft", "The mill")
	_refresh()
	_run_mill()


func _begin_adventure() -> void:
	_reset_run()
	adventure = true
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Adventure Mode")
	_log("var", "HP %s" % hp)
	_log("on_draft", "Dungeon 1")
	_refresh()
	_run_mill()


func _enter_dungeon_clear() -> void:
	if sfx:
		sfx.set_combat_music(false)
		sfx.play("confirm_big", -6.0)
		sfx.duck_music(-2.0)
	_flash_screen(Color("e8c36a"), 0.28)
	if combat_stage:
		combat_stage.hide_stage()
	if in_tutorial or not adventure:
		phase = "victory"
		_log("end", "cleared")
		return
	dungeons_cleared += 1
	phase = "rest"
	_log("end", "dungeon %s" % dungeons_cleared)
	facing_index = -1


func _adventure_leave() -> void:
	if not adventure or phase != "rest":
		return
	phase = "victory"
	_log("end", "leave")
	_refresh()


func _adventure_continue() -> void:
	if not adventure or phase != "rest" or _adventure_busy:
		return
	_adventure_busy = true
	overlay.visible = false
	dungeon_index += 1
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
	await _run_mill()
	_adventure_busy = false


func _prep_next_dungeon() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_mill_beat = ""
	refusals_left = REFUSALS_MAX
	if draft_gate:
		draft_gate.hide_gate()
	if _courier:
		_courier.visible = false
	if speech_box:
		speech_box.hide_speech()
	if wheel_view != null:
		wheel_view.kill_spin()
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
	pending_feed = {}
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	num_items_at_combat = 0
	mobs_defeated = 0
	hp_loss_events = 0
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
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
	if _hall_wipe:
		var tw2 := create_tween()
		tw2.tween_property(_hall_wipe, "modulate:a", 0.0, 0.34)
		await tw2.finished
		_hall_wipe.visible = false
		_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _walk_knight_off() -> void:
	var frames: Array = []
	if art:
		frames = art.run_frames("knight_m")
		if frames.is_empty():
			frames = art.frames("knight_m")
	if frames.is_empty() or _courier == null:
		return
	_courier.texture = frames[0]
	_courier.size = Vector2(96, 96)
	_courier.pivot_offset = Vector2(48, 48)
	_courier.scale = Vector2(1.35, 1.35)
	_courier.modulate.a = 1.0
	var start: Vector2 = Vector2(size.x * 0.46, size.y * 0.58)
	if wheel_view:
		start = wheel_view.global_position + wheel_view.size * Vector2(0.5, 0.62)
	_courier.global_position = start - _courier.pivot_offset
	_courier.visible = true
	if sfx:
		sfx.play("cloth", -10.0)
	var dest := Vector2(size.x + 70.0, start.y) - _courier.pivot_offset
	var tw := create_tween()
	tw.tween_property(_courier, "global_position", dest, 0.62)
	var fi: int = 0
	await get_tree().process_frame
	while tw.is_running():
		fi = (fi + 1) % frames.size()
		_courier.texture = frames[fi]
		await get_tree().create_timer(0.07).timeout
	_courier.visible = false
	_courier.scale = Vector2.ONE


func _quick_start() -> void:
	_reset_run()
	phase = "ready"
	_log("on_click", "Dive In")
	_log("var", "HP %s" % hp)
	for i in range(mini(8, wheel.size())):
		var is_starter: bool = i < STARTER_COUNT
		var rarity: String = "starter" if is_starter else ""
		var rolled: int = 0 if is_starter else _pick_tier()
		var mid: String = _take_card(monster_pool, monsters_by_id, rarity, rolled)
		if mid == "":
			break
		var m: Dictionary = _make_monster(mid)
		m["slot"] = str(wheel[i].get("slot", SLOT_ORDER[i] if i < SLOT_ORDER.size() else ""))
		m["spin_locked"] = false
		var pack_t: int = _pack_tier_for(mid, monsters_by_id, 1 if is_starter else rolled)
		_stamp_pack(m, pack_t, "starter" if is_starter else "draft")
		wheel[i] = m
		_log("on_place", "%s → %s" % [m["name"], m["slot"]])
		var iid: String = ""
		if is_starter:
			if i < STARTER_ITEM_COUNT:
				iid = _next_starter_item()
		else:
			iid = _take_card(item_pool, items_by_id, "", pack_t)
		if iid != "":
			var item: Dictionary = _make_item(iid)
			_stamp_pack(item, _pack_tier_for(iid, items_by_id, pack_t), "starter" if is_starter else "draft")
			hotbar.append(item)
			_log("on_place", "item  %s" % item.get("name", iid))
	_sort_hotbar()
	_sync_wheel_stats()
	_log("on_draft", "enter")
	if sfx:
		sfx.play("door_open", -8.0)
	_refresh()


func _fill_pools() -> void:
	monster_pool.clear()
	item_pool.clear()
	for id in runtime.get("monsters", []):
		var card: Dictionary = monsters_by_id.get(str(id), {})
		if card.is_empty():
			continue
		for _c in range(int(card.get("count", 1))):
			monster_pool.append(str(id))
	for id in runtime.get("items", []):
		var card2: Dictionary = items_by_id.get(str(id), {})
		if card2.is_empty():
			continue
		var flags: Dictionary = card2.get("flags", {}) if typeof(card2.get("flags", {})) == TYPE_DICTIONARY else {}
		if bool(flags.get("hide", false)):
			continue
		var copies: int = int(card2.get("count", 1))
		if copies <= 0:
			continue
		for _c2 in range(copies):
			item_pool.append(str(id))


func _empty_wheel() -> void:
	wheel.clear()
	for slot in SLOT_ORDER:
		wheel.append({"kind": "empty", "slot": slot})
	if wheel_view:
		wheel_view.rot = 0.0
		wheel_view.facing_index = -1


func _pick_tier() -> int:
	var r: float = rng.randf()
	if r < 0.4:
		return 1
	if r < 0.75:
		return 2
	return 3


func _take_id(pool: Array, by_id: Dictionary, rarity: String, tier: int) -> String:
	var matches: Array = []
	for id in pool:
		var card: Dictionary = by_id.get(str(id), {})
		if card.is_empty():
			continue
		if rarity != "" and str(card.get("rarity", "")) != rarity:
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
	return UX.metal(tier)


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


func _item_inspect_body(it: Dictionary, _rule: Dictionary) -> String:
	var ab: String = str(it.get("ability", "")).strip_edges()
	if ab == "" or ab == "---":
		return ""
	if ab.find("[color") < 0 and ab.find("[bgcolor") < 0:
		return _paint_item_text(ab, it, false)
	return ab


func _item_inspect_look(it: Dictionary) -> Dictionary:
	var look: Dictionary = _item_look(it)
	look["title_size"] = 26
	look["title_bold"] = true
	if _shift_held and str(_item_rule(it).get("equation", "")).strip_edges() != "":
		return look
	var view: Dictionary = _item_view(it)
	var k: String = str(view.get("kind", "ATK"))
	var shown: String = str(view.get("number", "")).strip_edges()
	if k == "ATK" and str(it.get("card_id", "")) == "spiked_shield":
		look["stat_kind"] = "BOTH"
		look["stat_atk"] = 2
		look["stat_blk"] = 2
		return look
	if k == "ATK":
		look["stat_kind"] = "ATK"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "BLK":
		look["stat_kind"] = "BLK"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "HEAL":
		look["stat_kind"] = "HEAL"
		look["stat_n"] = int(view.get("n", 0))
		look["stat_shown"] = shown
	elif k == "DEFEAT" or k == "FANGS":
		look["stat_bb"] = _value_bb("Defeat", "", "#C9A0FF")
	elif shown != "" and shown != "—":
		look["stat_bb"] = _paint_explainer(shown)
	elif k != "":
		look["stat_bb"] = _paint_explainer(k.substr(0, 1) + k.substr(1).to_lower())
	return look


func _show_item_inspect(it: Dictionary) -> void:
	if inspect == null or it.is_empty():
		return
	var rule: Dictionary = _item_rule(it)
	var body: String = _item_inspect_body(it, rule)
	var eq: String = str(rule.get("equation", "")) if _shift_held else ""
	var port: Texture2D = null
	if art != null:
		port = art.item_tex(str(it.get("card_id", "")))
	inspect.visible = true
	_set_inspect_idle(false)
	if fight_ui:
		fight_ui.visible = false
	if placement_ui:
		placement_ui.visible = false
	inspect.show_rule(
		str(rule["title"]),
		"",
		eq,
		body,
		str(rule.get("warn", "")),
		port,
		"item",
		str(it.get("card_id", "")),
		_item_inspect_look(it)
	)


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
	if not smoke_given:
		smoke_given = true
		if item_pool.has("smoke_bomb"):
			item_pool.erase("smoke_bomb")
		return "smoke_bomb"
	return _take_card(item_pool, items_by_id, "starter", 0)


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
		_log("on_draft", "%s  %s" % [PLAYER_COPY.tier_name(int(pending_monster.get("pack_tier", 1))), pending_monster.get("name", "?")])
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
	_log("on_draft", "%s lure" % PLAYER_COPY.tier_name(pack_t))
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
	var view: Dictionary = _item_view(pending_item) if not pending_item.is_empty() else {}
	draft_gate.present_mystery(pending_item, _pack_tier_now(), _offer_tex(), passes, str(view.get("number", "")))
	if draft_gate.has_method("set_item_value"):
		draft_gate.set_item_value(str(view.get("number", "")), "", str(view.get("kind", "")))
	if not draft_gate.item_hovered.is_connected(_on_gate_item_hovered):
		draft_gate.item_hovered.connect(_on_gate_item_hovered)
	if not draft_gate.item_unhovered.is_connected(_on_item_unhovered):
		draft_gate.item_unhovered.connect(_on_item_unhovered)
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
			card.set_showcase(false)
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


func _seat_night_watch() -> void:
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
			sfx.play("drop", -10.0, 0.92 + float(si) * 0.02)
		await get_tree().create_timer(0.22).timeout
	starters_left = 0
	if adventure and dungeon_index > 1 and seq == _mill_seq:
		await _upgrade_two_openers()


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
	var seq: int = _mill_seq
	var can: Array = []
	for i in range(4):
		if int(adventure_seat_tiers[i]) < 3:
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
	if in_tutorial and picks.size() >= 2:
		_tut_up_a = int(CARDINAL_SLOTS[int(picks[0])])
		_tut_up_b = int(CARDINAL_SLOTS[int(picks[1])])
	elif in_tutorial and picks.size() == 1:
		_tut_up_a = int(CARDINAL_SLOTS[int(picks[0])])
		_tut_up_b = _tut_up_a
	if speech_box and wheel_view and not picks.is_empty() and not in_tutorial:
		var talk_si: int = int(CARDINAL_SLOTS[int(picks[0])])
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
		var idx: int = int(i)
		var next_t: int = int(adventure_seat_tiers[idx]) + 1
		var nid: String = _take_monster_of_tier(next_t)
		if nid == "":
			continue
		var si: int = int(CARDINAL_SLOTS[idx])
		var old: Dictionary = wheel[si] if si < wheel.size() else {}
		var old_id: String = str(old.get("card_id", ""))
		if old_id != "":
			monster_pool.append(old_id)
		adventure_seat_tiers[idx] = next_t
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
	while starter_items_left > 0:
		var iid: String = _next_starter_item()
		if iid == "":
			break
		hotbar.append(_make_item(iid))
		var iname: String = str(items_by_id.get(iid, {}).get("name", iid))
		_log("on_place", "item  %s" % iname)
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
	_refresh()
	_idle_inspect()
	if in_tutorial and tut != null and tut.wait == "mill_done":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


func _on_gate_send() -> void:
	if in_tutorial and tut != null and tut.wait != "gate_take" and tut.wait != "mill_done":
		return
	if draft_action != "ask" or pending_monster.is_empty():
		return
	var seq: int = _mill_seq
	draft_action = "busy"
	_refresh()
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
	if in_tutorial and tut != null and tut.wait == "gate_take":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


func _on_gate_refuse() -> void:
	if in_tutorial and tut != null and tut.wait != "mill_done":
		if tut:
			tut.nudge("Take this one. You can Leave it on the next visitors.")
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
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
		if wheel_view != null and wheel_view.has_method("shake_seat"):
			wheel_view.shake_seat(index)
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
	var open_next: bool = true
	if in_tutorial and tut != null and tut.wait == "seat":
		open_next = false
	_commit_place(index, open_next)
	if in_tutorial and tut != null and tut.wait == "seat":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()


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
	}
	_apply_formulas_to(s)
	return s


func _make_item(id: String) -> Dictionary:
	var card: Dictionary = items_by_id[id]
	uid_seq += 1
	var ops: Dictionary = {}
	if card.has("ops") and typeof(card["ops"]) == TYPE_DICTIONARY:
		ops = (card["ops"] as Dictionary).duplicate(true)
	elif ITEM_OPS.has(id):
		ops = (ITEM_OPS[id] as Dictionary).duplicate(true)
	return {
		"uid": uid_seq,
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ops": ops,
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"card_color": str(card.get("card_color", "")),
		"spent": false,
		"keep_after": false,
		"siphon_blk": 0,
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"petrified": false,
		"echo_copy": last_item_copy.duplicate(true) if id == "echo_bell" and not last_item_copy.is_empty() else {},
		"alt_n": 2 if str(ops.get("kind", "")) == "atk_alt_24" else 0,
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
		"player hp on spin", "player hp", "your hp", "your hp on spin", "player hp at all times":
			return hp
		"last mob hp", "last enemy hp":
			return last_mob_hp
		"num items at combat start", "items held", "item count":
			return hotbar.size()
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
		_:
			if f.is_valid_int():
				return int(f)
			push_warning("Unknown %s formula '%s' — using the printed roster number." % [s.get("card_id", "?"), raw])
			return null


func _apply_formulas_to(s: Dictionary) -> void:
	var id: String = str(s.get("card_id", ""))
	if _is_silenced(s):
		if not bool(s.get("atk_locked", false)):
			s["atk"] = _card_base_atk(id)
		if not bool(s.get("hp_locked", false)):
			s["hp"] = _card_base_hp(id)
			s["hp_max"] = int(s["hp"])
		s["ability"] = ""
		s["explainer"] = ""
		s["special_id"] = ""
		s["special_text"] = ""
		s["call_name"] = ""
		s["reminder"] = ""
		return
	var hold_hp: int = int(s.get("hp", 0))
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
	var card: Dictionary = monsters_by_id.get(id, {})
	s["call_name"] = MONSTER_LINES.call_of(id, card)
	s["reminder"] = MONSTER_LINES.reminder_of(id, card)
	if hp_locked:
		s["hp"] = hold_hp
		if id == "slime_boss":
			s["atk"] = hold_hp
	if atk_locked and id != "slime_boss":
		s["atk"] = hold_atk


func _store_last_faced_hp() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var face: Dictionary = wheel[facing_index]
	if str(face.get("kind", "")) != "monster":
		return
	last_mob_hp = maxi(int(face.get("hp", 3)), 0)


func _sync_wheel_stats() -> void:
	var n: int = wheel.size()
	for i in n:
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if bool(s.get("spin_locked", false)):
			var lid: String = str(s.get("card_id", ""))
			if _is_silenced(s):
				_apply_formulas_to(s)
				wheel[i] = s
			elif lid == "wick" and not _is_silenced(s):
				wheel[i] = s
			elif lid == "beggar" and not _is_silenced(s):
				s["atk"] = _leftmost_atk_n()
				wheel[i] = s
			elif lid == "ogre":
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
		if bool(wheel[i].get("spin_locked", false)):
			continue
		if hp_bonus[i] != 0 and not bool(wheel[i].get("hp_locked", false)):
			wheel[i]["hp"] = int(wheel[i]["hp"]) + hp_bonus[i]
			wheel[i]["hp_max"] = int(wheel[i]["hp_max"]) + hp_bonus[i]
		if atk_bonus[i] != 0:
			wheel[i]["atk"] = int(wheel[i]["atk"]) + atk_bonus[i]
	for i in n:
		if bool(wheel[i].get("atk_locked", false)):
			continue
		if _is_silenced(wheel[i]):
			continue
		if str(wheel[i].get("card_id", "")) == "slime_boss":
			wheel[i]["atk"] = int(wheel[i]["hp"])
		if str(wheel[i].get("card_id", "")) == "berserker" and not _is_silenced(wheel[i]):
			wheel[i]["rage_fire"] = (int(wheel[i].get("rage_step", 0)) % 3) == 2
	_mark_vars()


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
		if cid == "lich" and not _is_silenced(wheel[i]):
			lich_touch[(i - 1 + n) % n] = true
			lich_touch[(i + 1) % n] = true
		elif cid == "commander" and not _is_silenced(wheel[i]):
			cmd_touch[(i - 1 + n) % n] = true
			cmd_touch[(i + 1) % n] = true
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var id: String = str(wheel[i].get("card_id", ""))
		wheel[i]["atk_variable"] = id == "dire_wolf" or id == "bandit" or id == "berserker" or id == "slime_boss" or id == "wraith" or cmd_touch.has(i)
		wheel[i]["hp_variable"] = id == "ogre" or id == "skeleton" or id == "leech_league" or lich_touch.has(i)
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


func _process(_delta: float) -> void:
	if fly_tip != null and fly_tip.visible:
		_place_fly(_fly_card)
	_place_fight_art()
	var sh: bool = Input.is_key_pressed(KEY_SHIFT)
	if sh != _shift_held:
		_shift_held = sh
		_sync_hotbar_formulas()
		_refresh_monster_plates()
		_refresh_gate_owner()
		if not _hover_item.is_empty():
			_show_item_inspect(_hover_item)
		if in_tutorial:
			_tutorial_shift_tick()
	_place_speech()
	if draft_gate != null and draft_gate.visible and wheel_view != null:
		draft_gate.dock(wheel_view)
	if in_tutorial:
		_tut_refresh_focus()
	if hud != null and hud.has_method("layout_hand") and phase != "title":
		hud.layout_hand()


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
	if not event.is_action_pressed("ui_cancel"):
		return
	if settings_ui == null or settings_ui.visible:
		return
	if content_ed != null and content_ed.visible:
		return
	if roster_ed != null and roster_ed.visible:
		return
	if script_ed != null and script_ed.visible:
		return
	if inspect:
		inspect.hide_plate()
	settings_ui.open_menu()
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
		"new":
			_on_new()
		"dev":
			_open_dev_test()
		"roster":
			_open_roster()


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


func _on_script_saved() -> void:
	PLAYER_COPY.reload()
	if _copy_stamp:
		_copy_stamp.text = PLAYER_COPY.stamp()
	if settings_ui:
		settings_ui.apply_copy()
	_apply_overlay_copy()
	_refresh()
	_log("on_click", "Script saved")


func _apply_overlay_copy() -> void:
	if overlay_tut:
		overlay_tut.text = PLAYER_COPY.text("title.how_to_play", "How to Play")
	if overlay_dive:
		overlay_dive.text = PLAYER_COPY.text("title.dive_in", "Dive In")
	if overlay_adventure:
		overlay_adventure.text = PLAYER_COPY.text("title.adventure", "Adventure Mode")
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
	if sfx:
		sfx.play("book", -10.0)


func _on_content_saved(kind: String, card_id: String, board_card: Dictionary) -> void:
	_merge_catalog_card(kind, board_card)
	_write_catalog()
	_apply_live_card(kind, card_id, board_card)
	_log("on_click", "Saved %s" % board_card.get("name", card_id))
	_refresh()
	_refresh_offer_card()


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
	dst["tier"] = _as_int(board_card.get("tier", 1), 1)
	dst["count"] = _as_int(board_card.get("count", 1), 1)
	dst["priority"] = _as_int(board_card.get("priority", 3), 3)
	dst["ability"] = str(board_card.get("ability", ""))
	dst["explainer"] = str(board_card.get("explainer", ""))
	if kind != "monster":
		dst["card_color"] = str(board_card.get("card_color", ""))
	if kind == "monster":
		dst["call_name"] = str(board_card.get("call_name", ""))
		dst["reminder"] = str(board_card.get("reminder", ""))
	dst["defined"] = str(board_card.get("flow", ""))
	dst["exceptions"] = str(board_card.get("notes", ""))
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
			"call_name": "",
			"reminder": "",
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
		}
	return {
		"id": id,
		"name": id,
		"type": "I",
		"ability": "",
		"explainer": "",
		"defined": "",
		"exceptions": "",
		"ops": {"kind": "atk", "n": 1},
		"card_color": "",
		"rarity": "uncommon",
		"tier": 1,
		"count": 1,
		"priority": 3,
		"flags": {"art": false, "dev": false, "hide": false},
		"poc": false,
		"review": "rough",
		"review_note": "",
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
	var view: Dictionary = _item_view(pending_item)
	var rule: Dictionary = _item_rule(pending_item)
	if _offer_card.has_method("set_title"):
		_offer_card.set_title(_title_case(str(pending_item.get("name", "?"))))
	if _offer_card.has_method("set_rank"):
		_offer_card.set_rank("")
	if _offer_card.has_method("set_palette"):
		_offer_card.set_palette(view["fill"], view["rim"], _tier_of(pending_item))
	if _offer_card.has_method("set_live"):
		_offer_card.set_live(str(view["number"]), str(view.get("note", "")), true)
	if _offer_card.has_method("set_showcase"):
		_offer_card.set_showcase(false)
	if _offer_card.has_method("set_ability_bb"):
		_offer_card.set_ability_bb(_item_inspect_body(pending_item, rule))
	if _offer_card.has_method("set_stat_look"):
		var held: bool = _shift_held
		_shift_held = false
		_offer_card.set_stat_look(_item_inspect_look(pending_item))
		_shift_held = held
	if _offer_card.has_method("set_formula"):
		_offer_card.set_formula(str(rule.get("equation", "")))
		_offer_card.show_formula(_shift_held)


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
	it["card_color"] = str(board_card.get("card_color", ""))
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
		_apply_mark(index)
		return
	if phase == "devtest":
		_dev_click_slice(index)
		return
	if phase == "draft" and draft_action == "seat":
		_seat_petitioner(index)


func _on_slice_right_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		return
	_open_content_editor("monster", str(s.get("card_id", "")))


func _on_slice_hovered(index: int) -> void:
	if _fly_card != null:
		return
	if inspect == null:
		return
	if fly_tip != null and fly_tip.edit_kind == "monster":
		fly_tip.hide_plate()
	if index < 0 or index >= wheel.size():
		_hover_slice = -1
		_refresh_seat_preview(-1)
		_idle_inspect()
		return
	if index != _hover_slice and sfx and phase != "spinning":
		sfx.hover()
	_hover_slice = index
	_refresh_seat_preview(index)
	_idle_inspect()
	_sync_torch()
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
	if wheel_view:
		wheel_view.set_seat_fx({})
	_apply_preview({})
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
	if phase != "ready":
		return
	if in_tutorial and (tut == null or tut.wait != "spin"):
		return
	if facing_index >= 0:
		return
	var live: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "monster":
			live.append(i)
	if live.is_empty():
		_enter_dungeon_clear()
		_refresh()
		return
	var idx: int = live[rng.randi_range(0, live.size() - 1)]
	if in_tutorial:
		var forced: int = _tutorial_spin_index()
		if forced >= 0:
			idx = forced
	if _reroll_skip >= 0 and live.size() > 1:
		var filtered: Array[int] = []
		for i in live:
			if i != _reroll_skip:
				filtered.append(i)
		if not filtered.is_empty():
			idx = filtered[rng.randi_range(0, filtered.size() - 1)]
		_reroll_skip = -1
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
		sfx.play("door_close", -8.0)
		sfx.play("land", -14.0)
		sfx.play("bong", -16.0)
	facing_index = idx
	blk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	pending_feed = {}
	_cube_line = ""
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
	phase = "fighting"
	_log("on_spin", str(m["name"]))
	_log("var", "enemy ATK %s   HP %s" % [m["atk"], m["hp"]])
	_log("var", "BLK 0")
	_log("var", "items this combat 0")
	if combat_stage:
		combat_stage.show_monster(str(m.get("card_id", "")))
	_refresh()
	if await _apply_siphon_jars():
		_store_last_faced_hp()
		return
	if await _apply_cursed_scrolls():
		_store_last_faced_hp()
		return
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		_store_last_faced_hp()
		_refresh()
		await _begin_slay()
		return
	if str(m.get("card_id", "")) == "gelatinous_cube":
		_cube_ask_feed()
		m = wheel[facing_index]
	if str(m.get("card_id", "")) == "gargoyle":
		_petrify_best_atk()
	if bool(m.get("poisoned", false)):
		_chip_hp(facing_index, 5)
		m = wheel[facing_index]
		_log("on_spin", "poison  →  %s HP" % m["hp"])
		if int(m["hp"]) <= 0 and not _wick_waiting(facing_index):
			_store_last_faced_hp()
			_refresh()
			await _begin_slay()
			return
	_refresh()
	_step_berserkers()
	_sync_wheel_stats()
	await _apply_queen_eggs_on_spin()
	if str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
		await _harpy_poke()
	_store_last_faced_hp()
	if in_tutorial and phase == "fighting":
		call_deferred("_tutorial_combat_started")


func _on_done() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _wheel_busy():
		return
	if in_tutorial and (tut == null or not _tut_can_done()):
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_wait", "Not yet — finish what I said."))
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if not pending_chaos.is_empty() or not pending_mark.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
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
	_maybe_auto_spin()


func _exit_leave(clockwork_split: bool = true) -> void:
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_leave_visuals()
	await _clear_after_fight(clockwork_split)
	_maybe_auto_spin()


func _play_ended_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		sfx.play("bong", -6.0)
		sfx.play("whoosh", -10.0, 1.15)
		sfx.play("scratch", -10.0, 0.85)
	if combat_stage:
		combat_stage.take_hit()
	if wheel_view and facing_index >= 0:
		await wheel_view.play_slay(facing_index)
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0:
		await wheel_view.collapse_slice(facing_index)


func _play_leave_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	_refresh()
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0:
		await wheel_view.collapse_slice(facing_index)


func _resolve_then_continue(skip_attack: bool) -> void:
	if phase != "fighting":
		return
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
	var _taken: int = await _apply_resolve_hits()
	enemy_attacked = true
	if hp <= 0:
		_player_down()
		return
	if await _try_commander_flee(facing_index):
		return
	await _play_leave_visuals()
	await _clear_after_fight(true)
	_maybe_auto_spin()


func _apply_resolve_hits() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	var hits: int = _hit_count(facing_index)
	var total: int = 0
	for h in range(hits):
		if hp <= 0:
			break
		var incoming: int = await _owner_attack(m, h + 1, hits)
		total += incoming
		if hp <= 0:
			break
		if hits > 1 and h < hits - 1:
			await get_tree().create_timer(0.16).timeout
	return total


## Owner Attacks you. Always lunges. Blocked vs unblocked only changes the tell.
## Returns HP lost on this swing.
func _owner_attack(m: Dictionary, hit_n: int = 1, _hit_total: int = 1) -> int:
	enemy_attacked = true
	if combat_stage and str(m.get("card_id", "")) != "spider_egg":
		await combat_stage.lunge()
	var pierce: bool = str(m.get("card_id", "")) == "dragon" and not _is_silenced(m)
	var swing: Dictionary = _swing(m, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	var hp_before: int = hp
	hp = maxi(0, hp - incoming)
	var lost: int = hp_before - hp
	if lost > 0:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(lost)
	if pierce:
		_log("on_resolve", "hit %s  ATK %s  (ignores BLK)" % [hit_n, m.get("atk", 0)])
	else:
		_log("on_resolve", "hit %s  ATK %s − BLK" % [hit_n, m.get("atk", 0)])
		_log("var", "BLK %s" % blk)
	if incoming > 0:
		_log("hp", "take %s  →  %s" % [incoming, hp])
		await _play_attack_connect()
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
	_sync_wheel_stats()
	return incoming


func _play_attack_connect() -> void:
	_flash_screen(Color("e07a7a"), 0.28)
	_refresh_hearts()
	_refresh_blk(false)
	if sfx:
		sfx.play("chop", -6.0)
		sfx.play("error", -18.0, 0.8)


func _play_attack_blocked() -> void:
	_flash_screen(Color("5aa8e8"), 0.4)
	_refresh_blk(false)
	if sfx:
		sfx.play("block_heavy", -5.0)
		sfx.play("bong", -8.0, 1.12)
		sfx.play("glass", -12.0, 1.3)
	if combat_stage:
		combat_stage.play_block()
	if facing_index >= 0 and wheel_view:
		await wheel_view.play_block(facing_index)


func _player_down() -> void:
	hp = 0
	var adventure_win: bool = adventure and dungeons_cleared >= 1
	phase = "victory" if adventure_win else "defeat"
	_log("end", "cleared" if adventure_win else "dead")
	_flash_screen(Color("e8c36a") if adventure_win else Color("c45c5c"), 0.28)
	if sfx:
		sfx.set_combat_music(false)
		if adventure_win:
			sfx.play("confirm_big", -6.0)
			sfx.duck_music(-2.0)
		else:
			sfx.play("error_big", -6.0)
			sfx.duck_music(-16.0)
	if combat_stage:
		combat_stage.hide_stage()
	_discard_spent_items()
	facing_index = -1
	_refresh()


func _clear_after_fight(clockwork_split: bool = false) -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	var left_id: String = str(m.get("card_id", ""))
	_remove_crossbowed()
	if left_id == "mimic" and not enemy_attacked:
		await _draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	last_mob_atk = int(m.get("atk", 0))
	_remove_facing()
	if clockwork_split and left_id == "clockwork_knight" and not _is_silenced(m):
		_spawn_clockwork_heirs()
	_discard_spent_items()
	blk = 0
	mobs_defeated += 1
	_log("var", "BLK 0")
	_log("var", "defeated %s" % mobs_defeated)
	await _collapse_dead_wicks()
	await _slay_pending_ogres()
	_sync_wheel_stats()
	phase = "ready"
	if _monsters_left() == 0:
		if in_tutorial:
			if combat_stage:
				combat_stage.hide_stage()
			if sfx:
				sfx.set_combat_music(false)
		else:
			_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	if in_tutorial:
		call_deferred("_tutorial_after_fight")


func _maybe_auto_spin() -> void:
	if in_tutorial:
		return
	if phase != "ready":
		return
	if _monsters_left() <= 0:
		return
	await get_tree().create_timer(0.15).timeout
	if phase == "ready":
		_on_spin()


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


func _use_item(uid: int) -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		if sfx:
			sfx.play("error", -12.0, 1.2)
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
			sfx.play("error", -10.0)
			sfx.play("metal_latch", -14.0)
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
	if kind == "choose":
		var opts: Variant = ops.get("options", [])
		if typeof(opts) != TYPE_ARRAY or (opts as Array).is_empty():
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
	if kind == "mark_poison" or kind == "mark_crossbow" or kind == "atk_neighbor" or kind == "hook_swap":
		if _mark_targets(kind).is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			return
		pending_mark = {"uid": uid, "kind": kind}
		_log("on_item_use", "pick a neighbor")
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "chaos_reroll":
		await _begin_chaos(uid)
		return
	await _apply_ops(it, ops, {})
	await _after_item_resolved(it)
	if in_tutorial:
		_tutorial_item_used(str(it.get("card_id", "")))
	call_deferred("_refresh")


func _choose_option(opt: Dictionary) -> void:
	var it: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
	pending_choice.clear()
	if it.is_empty():
		call_deferred("_refresh")
		return
	if int(opt.get("atk_drop", 0)) > 0:
		await _apply_ops(it, {"kind": "atk_drop", "n": int(opt.get("atk_drop", 0))}, opt)
	elif int(opt.get("blk", 0)) > 0:
		await _apply_ops(it, {"kind": "blk", "n": int(opt.get("blk", 0))}, opt)
	else:
		await _apply_ops(it, {"kind": "atk", "n": int(opt.get("atk", 0))}, opt)
	await _after_item_resolved(it)
	if sfx:
		sfx.play("click2", -8.0)
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
	var m: Dictionary = wheel[facing_index]
	var kind: String = str(ops.get("kind", ""))
	var view: Dictionary = _item_view(it)
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
			if _deal_atk(n2):
				it["spent"] = true
				if extra.has("keep"):
					it["keep_after"] = bool(extra["keep"])
				if str(it.get("card_id", "")) == "echo_bell":
					it["keep_after"] = false
				_count_item_use()
				_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [n2, wheel[facing_index]["hp"]])
		"atk_cleave":
			if await _apply_cleave(int(ops.get("n", 2))):
				it["spent"] = true
				_count_item_use()
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
			if _deal_atk_at(opp, n4):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  %s HP %s" % [n4, wheel[opp].get("name", "?"), wheel[opp].get("hp", 0)])
			it["spent"] = true
			_count_item_use()
			_toss_item(int(it["uid"]), false)
			_sync_wheel_stats()
			if opp >= 0 and opp < wheel.size() and int(wheel[opp].get("hp", 0)) <= 0:
				await _maybe_slay_down(opp)
			return
		"heal_kills":
			var flask_n: int = 1 + mobs_defeated
			_log("on_item_use", str(it["name"]))
			_heal(flask_n)
		"heal_full":
			_log("on_item_use", str(it["name"]))
			_heal(HP_MAX - hp)
		"egg_hurt":
			var egg_atk: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			var fake := {"card_id": "spider_egg", "atk": egg_atk, "name": str(it.get("name", "Spider Egg"))}
			await _owner_attack(fake)
			if hp <= 0:
				it["spent"] = true
				_count_item_use()
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
			it["spent"] = true
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_reroll_skip = facing_index
			if facing_index >= 0:
				wheel[facing_index]["spin_locked"] = false
			facing_index = -1
			keep_blocked_this_fight = false
			blk = 0
			pending_mark.clear()
			_toss_item(int(it["uid"]), false)
			_discard_spent_items()
			_sync_wheel_stats()
			phase = "ready"
			if combat_stage:
				combat_stage.hide_stage()
			await _draw_unseen_item()
			call_deferred("_maybe_auto_spin")
			return
		"atk_zero":
			m["atk"] = 0
			m["atk_locked"] = true
			wheel[facing_index] = m
			_log("on_item_use", str(it["name"]))
			_log("atk", "facing ATK 0")
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"atk_drop":
			var drop: int = int(ops.get("n", 1))
			var now: int = int(m.get("atk", 0))
			m["atk"] = maxi(0, now - drop)
			m["atk_locked"] = true
			wheel[facing_index] = m
			_log("on_item_use", str(it["name"]))
			_log("atk", "facing ATK −%s  →  %s" % [drop, m["atk"]])
			if sfx:
				sfx.play("metal_latch", -8.0)
				sfx.play("scratch", -12.0, 1.1)
		"heal_keep":
			var lantern_n: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			_heal(lantern_n)
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
			if not _has_unique_ability(qid) or _is_silenced(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			m["silenced"] = true
			wheel[facing_index] = m
			if qid == "basilisk":
				keep_blocked_this_fight = false
			_sync_wheel_stats()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "silenced %s" % qid)
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("pluck", -10.0, 0.85)
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
			if _deal_atk(copy_blk):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), true)
				return
			_log("atk", "%s  →  enemy HP %s" % [copy_blk, wheel[facing_index]["hp"]])
		"atk_empty":
			var bead_n: int = beads_step
			last_item_atk = bead_n
			if _deal_atk(bead_n):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [bead_n, wheel[facing_index]["hp"]])
		"atk_hp_gap":
			var scythe_n: int = int(hp / 2)
			last_item_atk = scythe_n
			if _deal_atk(scythe_n):
				it["spent"] = true
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
			_log("atk", "%s  →  enemy HP %s" % [scythe_n, wheel[facing_index]["hp"]])
			_heal(scythe_n)
			if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) > 0:
				it["keep_after"] = true
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
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
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
				_count_item_use()
				_toss_item(int(it["uid"]), false)
				_player_down()
				return
			it["spent"] = true
			_count_item_use()
			_toss_item(int(it["uid"]), false)
			await _play_ended_visuals()
			_heal(stored)
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
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
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
			_count_item_use()
			_log("on_item_use", str(it["name"]))
			_log("on_resolve", "defeat")
			if sfx:
				sfx.play("draw", -8.0)
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
	_count_item_use()
	_sync_wheel_stats()
	_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0:
		if not _wick_waiting(facing_index):
			await _begin_slay()


func _toss_item(uid: int, keep: bool) -> void:
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
			c.toss()
			if sfx:
				sfx.play("cloth", -8.0)
				sfx.play("whoosh", -16.0, 1.2)
		break
	if not keep:
		_remove_item_now(uid)


func _remove_item_now(uid: int) -> void:
	var kept: Array = []
	for it in hotbar:
		if int(it.get("uid", -1)) != uid:
			kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _defeat_blocked(m: Dictionary) -> bool:
	var id: String = str(m.get("card_id", ""))
	return id == "gargoyle" and not _is_silenced(m)


func _wick_waiting(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if str(wheel[index].get("card_id", "")) != "wick":
		return false
	if _is_silenced(wheel[index]):
		return false
	return int(wheel[index].get("hp", 0)) <= 0


func _twins_facing() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	return str(wheel[facing_index].get("card_id", "")) == "hollow" and not _is_silenced(wheel[facing_index])


func _twins_double_atk(index: int, n: int) -> bool:
	if n <= 0 or n % 2 != 0:
		return false
	if index < 0 or index >= wheel.size():
		return false
	return str(wheel[index].get("card_id", "")) == "hollow" and not _is_silenced(wheel[index])


func _twins_double_blk(n: int) -> bool:
	return n > 0 and n % 2 == 0 and _twins_facing()


func _chip_hp(index: int, n: int) -> void:
	if index < 0 or index >= wheel.size() or n <= 0:
		return
	var m: Dictionary = wheel[index]
	var drop: int = n
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m):
		drop = 1
	m["hp"] = maxi(0, int(m.get("hp", 0)) - drop)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m


func _leftmost_atk_n() -> int:
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if _item_atk_score(it) < 0:
			continue
		return int(_item_view(it).get("n", 0))
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
	var i: int = wheel.size() - 1
	while i >= 0:
		if _wick_waiting(i) and i != facing_index:
			await _kill_neighbor(i)
		i -= 1


func _maybe_slay_down(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if int(wheel[index].get("hp", 0)) > 0:
		return
	if _wick_waiting(index):
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
		call_deferred("_refresh")
		return
	_flash_screen(Color("3a1460"), 0.42)
	if sfx:
		sfx.play("whoosh", -8.0, 0.86)
		sfx.play("bong", -12.0, 0.7)
	if get_tree():
		await get_tree().create_timer(0.28).timeout
	for uid_v in picks:
		await _reroll_item_same_tier(int(uid_v))
	stone["spent"] = true
	_count_item_use()
	_toss_item(int(stone["uid"]), false)
	_sort_hotbar()
	_log("on_item_use", str(stone.get("name", "Chaos Stone")))
	await _after_item_resolved(stone)
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
	if sfx:
		sfx.play("drop", -8.0, 0.8)
	for c in hotbar_box.get_children():
		if c.has_method("bounce") and int(c.uid) == keep_uid:
			c.bounce()
			break
	if get_tree():
		await get_tree().create_timer(0.32).timeout


func _keep_blocked_now() -> bool:
	if keep_blocked_this_fight:
		return true
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var id: String = str(wheel[facing_index].get("card_id", ""))
	return id == "basilisk" and not _is_silenced(wheel[facing_index])


func _is_silenced(s: Dictionary) -> bool:
	return bool(s.get("silenced", false))


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
		sfx.play("block", -8.0)
		if n >= 4:
			sfx.play("block_heavy", -14.0)
	return n


func _heal(n: int) -> int:
	var before: int = hp
	hp = mini(HP_MAX, hp + maxi(0, n))
	var gained: int = hp - before
	_log("hp", "heal %s  →  %s" % [gained, hp])
	_refresh_hearts()
	if gained <= 0:
		return 0
	_sync_wheel_stats()
	_flash_screen(Color("8fd18f"), 0.28)
	if sfx:
		sfx.play("pluck", -8.0)
	_glow_hearts_heal()
	return gained


func _bleed(n: int) -> bool:
	if n <= 0:
		return false
	var before: int = hp
	hp = maxi(0, hp - n)
	if hp < before:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(before - hp)
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
	_sync_wheel_stats()
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
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
	if hid == "harpy" and not _is_silenced(wheel[facing_index]):
		await _harpy_poke()


func _harpy_poke() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "harpy" or _is_silenced(m):
		return
	if int(m.get("hp", 0)) <= 0:
		return
	await _owner_attack(m)
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
			return best
		return int(_item_view(it).get("n", 0))
	return -1


func _petrify_best_atk() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or _is_silenced(wheel[facing_index]):
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
	if sfx:
		sfx.play("metal_latch", -8.0)
		sfx.play("cloth", -12.0)


func _cube_ask_feed() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or _is_silenced(wheel[facing_index]):
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
		_cube_line = ["Two snacks. Feed me one.", "I'm hungry. Pick one.", "Feed me. The other one can wait."][rng.randi() % 3]
	else:
		_cube_line = "That's all you've got. Feed me."
	_log("on_spin", "cube demands a feed")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play("cloth", -12.0)


func _feed_cube(uid: int) -> void:
	if pending_feed.is_empty():
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		return
	pending_feed = {}
	var it: Dictionary = _find_item(uid)
	_cube_line = ["Mmm. Thank you.", "Gone. Delicious.", "Thanks. I needed that."][rng.randi() % 3]
	_log("on_spin", "cube ate %s" % str(it.get("name", "?")))
	if sfx:
		sfx.play("cloth", -6.0)
		sfx.play("glass", -12.0, 0.8)
	_toss_item(uid, false)
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
		sfx.play("drop", -8.0)
		sfx.play("metal_latch", -14.0)


func _count_item_use() -> void:
	items_used_this_combat += 1
	beads_step = (beads_step % 4) + 1
	_log("var", "items this combat %s" % items_used_this_combat)
	_flip_alt_sais()
	for i in wheel.size():
		if str(wheel[i].get("card_id", "")) != "wick":
			continue
		if _is_silenced(wheel[i]):
			continue
		wheel[i]["atk"] = int(wheel[i].get("atk", 0)) + 1
		wheel[i]["atk_locked"] = true
		_chip_hp(i, 1)
	_sync_wheel_stats()


func _deal_atk(n: int) -> bool:
	return _deal_atk_at(facing_index, n)


func _deal_atk_at(index: int, n: int, skip_twins: bool = false) -> bool:
	last_item_atk = n
	if index < 0 or index >= wheel.size():
		return false
	if not skip_twins and _twins_double_atk(index, n):
		if _deal_atk_at(index, n, true):
			return true
		if index < 0 or index >= wheel.size():
			return false
		return _deal_atk_at(index, n, true)
	var m: Dictionary = wheel[index]
	var hit_n: int = n
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m) and hit_n > 0:
		hit_n = 1
	var immune: bool = str(m.get("card_id", "")) == "goblin" and not _is_silenced(m)
	if immune or hit_n <= 0:
		if immune:
			_log("var", "no ATK dmg")
		else:
			_log("atk", "0  →  enemy HP %s" % m.get("hp", 0))
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
	if sfx:
		sfx.play("hit", -7.0, 0.94 + rng.randf() * 0.14)
		sfx.play("chop", -16.0)
	if wheel_view:
		wheel_view.hit_feedback(index, before_hp - int(m["hp"]), int(m["atk"]) - before_atk)
	if combat_stage and index == facing_index:
		combat_stage.take_hit()
	if str(m.get("card_id", "")) == "needleback" and not _is_silenced(m) and before_hp > 0:
		if _player_take_atk(1):
			return true
	return false


func _player_take_atk(n: int) -> bool:
	var dummy := {"atk": n, "card_id": ""}
	var swing: Dictionary = _swing(dummy, blk)
	var incoming: int = int(swing["dmg"])
	blk = int(swing["blk"])
	var hp_before: int = hp
	hp = maxi(0, hp - incoming)
	var lost: int = hp_before - hp
	if lost > 0:
		hp_loss_events += 1
		lost_hp_this_combat = true
		_hurt_ogres(lost)
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
			sfx.play("chop", -8.0)
	if hp <= 0 and not _try_potion():
		_player_down()
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
		if await _bleed(1):
			return true
	return false


func _apply_cursed_scrolls() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "cursed_scroll":
			continue
		if bool(it.get("spent", false)):
			continue
		_log("on_spin", "Cursed Scroll")
		if await _bleed(1):
			return true
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
	var targets: Array[int] = _cleave_targets()
	for t in targets:
		if t < 0 or t >= wheel.size():
			continue
		if _deal_atk_at(t, n):
			return true
		_log("atk", "%s  →  %s HP %s" % [n, wheel[t].get("name", "?"), wheel[t].get("hp", 0)])
	var dead: Array[int] = []
	for t in targets:
		if t == facing_index:
			continue
		if t >= 0 and t < wheel.size() and int(wheel[t].get("hp", 0)) <= 0:
			dead.append(t)
	dead.sort()
	dead.reverse()
	for t in dead:
		if t < 0 or t >= wheel.size() or t == facing_index:
			continue
		if int(wheel[t].get("hp", 0)) <= 0:
			await _maybe_slay_down(t)
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
	var off: int = n - 1 if ccw else 1
	var j: int = (facing_index + off) % n
	if str(wheel[j].get("kind", "")) != "monster":
		return -1
	return int(wheel[j].get("atk", 0))


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
	for i in _neighbor_indices():
		if _can_mark(i, kind):
			out.append(i)
	return out


func _can_mark(index: int, kind: String) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if index == facing_index:
		return false
	if not _neighbor_indices().has(index):
		return false
	if str(wheel[index].get("kind", "")) != "monster":
		return false
	if kind == "mark_poison":
		return not bool(wheel[index].get("crossbowed", false))
	if kind == "mark_crossbow" or kind == "atk_neighbor":
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
		call_deferred("_refresh")
		return
	if kind == "hook_swap":
		var a: Dictionary = wheel[facing_index].duplicate(true)
		var b: Dictionary = wheel[index].duplicate(true)
		a["spin_locked"] = false
		b["spin_locked"] = true
		wheel[facing_index] = b
		wheel[index] = a
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		_log("on_item_use", "hook %s" % b.get("name", "?"))
		_sync_wheel_stats()
		await _draw_unseen_item()
		if combat_stage:
			combat_stage.show_monster(str(wheel[facing_index].get("card_id", "")))
		if sfx:
			sfx.play("whoosh", -8.0)
			sfx.play("click2", -8.0)
		await _after_item_resolved(it)
		call_deferred("_refresh")
		return
	if kind == "mark_poison":
		wheel[index]["poisoned"] = true
		_log("on_item_use", "poisoned %s" % wheel[index].get("name", "?"))
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		if sfx:
			sfx.play("click2", -8.0)
		_sync_wheel_stats()
		await _after_item_resolved(it)
		call_deferred("_refresh")
		return
	var n: int = 4
	var ops: Dictionary = _ops_of(it)
	if ops.has("n"):
		n = int(ops["n"])
	if _deal_atk_at(index, n):
		it["spent"] = true
		_count_item_use()
		_toss_item(int(it["uid"]), false)
		await _after_item_resolved(it)
		return
	_log("on_item_use", "crossbow %s" % wheel[index].get("name", "?"))
	_log("atk", "%s  →  %s HP %s" % [n, wheel[index].get("name", "?"), wheel[index].get("hp", 0)])
	it["spent"] = true
	_count_item_use()
	_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()
	await _after_item_resolved(it)
	_refresh()
	if int(wheel[index].get("hp", 0)) <= 0:
		await _maybe_slay_down(index)


func _wheel_busy() -> bool:
	return wheel_view != null and wheel_view.busy


func _kill_neighbor(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if index == facing_index:
		return
	if await _try_commander_flee(index):
		return
	var pin: int = facing_index
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) == "mimic":
		await _draw_unseen_item()
		_log("on_remove_slice", "Mimic gift")
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		sfx.play("bong", -6.0)
		sfx.play("whoosh", -10.0, 1.15)
		sfx.play("scratch", -10.0, 0.85)
	if wheel_view:
		await wheel_view.play_slay(index)
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
		if wheel_view:
			wheel_view.hit_feedback(i, before - int(s["hp"]), 0)
	_refresh()
	if phase != "fighting" and phase != "slaying":
		call_deferred("_slay_pending_ogres")


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
		_flash_banner(title)
	_log("on_remove_slice", str(s.get("name", "Ogre")))
	if sfx:
		sfx.play("whoosh", -8.0, 1.1)
		sfx.play("scratch", -12.0, 0.9)
	if wheel_view:
		wheel_view.flash_slice(index)
		await wheel_view.play_slay(index)
		await wheel_view.collapse_slice(index, facing_index)
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
	var lab := Label.new()
	lab.text = msg
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 28)
	lab.add_theme_color_override("font_color", Color("f0e6d8"))
	lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	lab.add_theme_constant_override("outline_size", 6)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 40
	play_field.add_child(lab)
	lab.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lab.offset_left = -220.0
	lab.offset_right = 220.0
	lab.offset_top = -24.0
	lab.offset_bottom = 24.0
	lab.modulate.a = 0.0
	var tw := lab.create_tween()
	tw.tween_property(lab, "modulate:a", 1.0, 0.12)
	tw.tween_interval(0.7)
	tw.tween_property(lab, "modulate:a", 0.0, 0.35)
	tw.finished.connect(lab.queue_free)


func _gain_blocked_now() -> bool:
	return _keep_blocked_now()


func _try_gain_item(id: String) -> void:
	if id == "":
		return
	var it: Dictionary = _make_item(id)
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	_refresh()
	if not _gain_blocked_now():
		if sfx:
			sfx.play("open", -10.0)
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
	s["hp"] = maxi(1, int(s.get("hp_max", _card_base_hp("commander"))))
	s["hp_locked"] = false
	wheel[index] = s
	_log("on_resolve", "%s flees" % s.get("name", "Commander"))
	if sfx:
		sfx.play("whoosh", -8.0, 1.2)
		sfx.play("door_open", -12.0)
	pending_choice.clear()
	pending_mark.clear()
	pending_chaos.clear()
	pending_feed = {}
	if combat_stage:
		combat_stage.hide_stage()
	facing_index = -1
	phase = "ready"
	blk = 0
	_shuffle_dungeon()
	_sync_wheel_stats()
	_refresh()
	_maybe_auto_spin()
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
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		if combat_stage:
			combat_stage.show_monster(str(nm.get("card_id", "")))
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
			_player_down()
			return
	if combat_stage:
		combat_stage.show_monster("two_headed_serpent")
	_heal(3)
	await _begin_slay()


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
			sfx.play("error_big", -14.0, 1.35)
			sfx.play("chop", -12.0, 0.7)
		elif old == 2 and nxt == 0 and sfx:
			sfx.play("glass", -10.0, 0.8)
			sfx.play("cloth", -12.0)


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
			var q: Dictionary = wheel[facing_index]
			q["hp"] = int(q.get("hp", 0)) + 2 * bonus
			q["hp_max"] = int(q.get("hp_max", q["hp"])) + 2 * bonus
			q["atk"] = int(q.get("atk", 0)) + 2 * bonus
			q["hp_locked"] = true
			q["atk_locked"] = true
			wheel[facing_index] = q
			_log("var", "Queen +%s HP +%s ATK" % [2 * bonus, 2 * bonus])
			if sfx:
				sfx.play("cloth", -8.0, 0.7)
		_refresh()
		return
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "spider_queen":
			continue
		if _is_silenced(wheel[i]):
			continue
		if hotbar.size() >= HAND_MAX:
			break
		if wheel_view and wheel_view.has_method("flash_slice"):
			wheel_view.flash_slice(i)
		await _try_gain_item("spider_egg")
	_refresh()


func _remove_crossbowed() -> void:
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and bool(wheel[i].get("crossbowed", false)) and str(wheel[i].get("kind", "")) == "monster":
			_log("on_remove_slice", str(wheel[i]["name"]))
			wheel.remove_at(i)
			mobs_defeated += 1
			if i < facing_index:
				facing_index -= 1
		i -= 1
	_reseat_slots()


func _draw_unseen_item() -> void:
	if item_pool.is_empty():
		return
	var id: String = _take_card(item_pool, items_by_id, "", 0)
	if id == "":
		return
	await _try_gain_item(id)


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
	if str(m.get("card_id", "")) == "dragon" and not _is_silenced(m):
		return {"dmg": maxi(0, atk_n), "blk": block_left}
	return {
		"dmg": maxi(0, atk_n - block_left),
		"blk": maxi(0, block_left - atk_n),
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
	if _is_silenced(wheel[index]):
		return 1
	if bool(wheel[index].get("swing_muted", false)):
		return 1
	if id == "hornet_swarm":
		return 2
	if id == "kobold_trapper":
		return 1 + items_used_this_combat
	return 1


func _queen_double(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var n: int = wheel.size()
	var qhp: int = int(wheel[index].get("hp", 0))
	for off in [n - 1, 1]:
		var j: int = (index + off) % n
		if str(wheel[j].get("kind", "")) == "monster" and int(wheel[j].get("hp", 0)) < qhp:
			return true
	return false


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
			out["n"] = int(it.get("alt_n", 2))
			if out["n"] != 2 and out["n"] != 4:
				out["n"] = 2
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
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("hp", 99)) < hp
		"atk_7_hp":
			out["n"] = maxi(0, 7 - hp)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_neighbor":
			out["kind"] = "BLK"
			var ccw: bool = str(it.get("card_id", "")) != "left_bracer"
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
			out["can_use"] = fighting and int(out["n"]) > 0
		"defeat_atk":
			out["kind"] = "DEFEAT"
			out["number"] = ""
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
			out["can_use"] = fighting and _has_unique_ability(str(m.get("card_id", ""))) and not _is_silenced(m)
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
		"atk_hp_gap":
			out["n"] = int(hp / 2) if fighting else 0
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"defeat_only_item":
			out["kind"] = "DEFEAT"
			out["number"] = ""
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
		"heal_kills":
			out["kind"] = "HEAL"
			out["n"] = 1 + mobs_defeated
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
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
			out["loss_icon"] = true
			out["can_use"] = fighting and int(it.get("siphon_blk", 0)) > 0
		"passive":
			out["kind"] = "PASSIVE"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = false
		_:
			out["can_use"] = false
	var tint: String = str(it.get("card_color", "")).strip_edges()
	if tint == "":
		var cat: Dictionary = items_by_id.get(str(it.get("card_id", "")), {})
		tint = str(cat.get("card_color", "")).strip_edges()
	var forced: Color = UX.card_color_fill(tint)
	if forced.a > 0.08:
		out["fill"] = forced
		var fam: String = UX.card_color_family(tint)
		if fam != "":
			out["kind"] = fam
	else:
		out["fill"] = _utility_fill(kind, str(out.get("kind", "ATK")))
	out["rim"] = rim
	if bool(out.get("loss_icon", false)):
		out["fill"] = Color(out["fill"]).lerp(Color(UX.HP), 0.38)
	if it.get("spent", false):
		out["can_use"] = false
	if bool(it.get("petrified", false)):
		out["can_use"] = false
	if not pending_feed.is_empty():
		out["can_use"] = false
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


func _toggle_log() -> void:
	if not _authoring() or phase != "devtest":
		return
	_log_open = not _log_open
	if log_label:
		log_label.visible = _log_open
	if log_btn:
		log_btn.text = "Hide log" if _log_open else "Log"
	if sfx:
		sfx.play("switch", -14.0)


func _sync_authoring_chrome() -> void:
	var show: bool = _authoring() and phase == "devtest"
	if log_btn:
		log_btn.visible = show
		if not show:
			log_btn.text = "Log"
	if not show:
		_log_open = false
	if log_label:
		log_label.visible = show and _log_open
	if _copy_stamp:
		_copy_stamp.visible = show


func _log(kind: String, msg: String) -> void:
	if log_label == null:
		return
	if kind == "on_place":
		return
	var info: Dictionary = LOG_KIND.get(kind, LOG_KIND["var"])
	log_label.append_text("[color=%s][b]%s[/b][/color]  %s\n" % [info["hex"], info["tag"], msg])


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


func _refresh_seat_preview(index: int) -> void:
	if wheel_view == null:
		return
	if not _can_place() or index < 0 or index >= wheel.size() or str(wheel[index].get("kind", "")) != "empty":
		if not wheel_view.seat_fx.is_empty():
			wheel_view.set_seat_fx({})
			_apply_preview({})
		return
	var n: int = wheel.size()
	var before_hp: Array[int] = []
	var before_atk: Array[int] = []
	var before_copy: Array[int] = []
	var before_x2: Array[bool] = []
	before_hp.resize(n)
	before_atk.resize(n)
	before_copy.resize(n)
	before_x2.resize(n)
	for i in n:
		before_hp[i] = int(wheel[i].get("hp", 0))
		before_atk[i] = int(wheel[i].get("atk", 0))
		before_copy[i] = int(wheel[i].get("copy_from", -1))
		before_x2[i] = false
	var saved: Array = []
	for s in wheel:
		saved.append((s as Dictionary).duplicate(true))
	var m: Dictionary = pending_monster.duplicate(true)
	m["slot"] = str(wheel[index].get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else ""))
	m["spin_locked"] = false
	wheel[index] = m
	_sync_wheel_stats()
	var preview: Dictionary = {}
	var links: Array = []
	for i in n:
		var hp_d: int = int(wheel[i].get("hp", 0)) - before_hp[i]
		var atk_d: int = int(wheel[i].get("atk", 0)) - before_atk[i]
		if i == index:
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if hp_d != 0 or atk_d != 0:
			var row: Dictionary = {}
			if hp_d != 0:
				row["hp"] = hp_d
				links.append({"to": i, "stat": "hp", "delta": hp_d})
			if atk_d != 0:
				row["atk"] = atk_d
				var tag := ""
				var copy_src: int = int(wheel[i].get("copy_from", -1))
				if str(wheel[i].get("card_id", "")) == "wraith" and copy_src >= 0 and copy_src != before_copy[i]:
					tag = "copy"
				links.append({"to": i, "stat": "atk", "delta": atk_d, "tag": tag, "src": copy_src})
			preview[i] = row
	var own_hp: int = int(pending_monster.get("hp", 0))
	var own_atk: int = int(pending_monster.get("atk", 0))
	var self_row := {
		"id": str(wheel[index].get("card_id", "")),
		"name": str(wheel[index].get("name", "")),
		"hp": int(wheel[index].get("hp", 0)),
		"atk": int(wheel[index].get("atk", 0)),
		"hp_d": int(wheel[index].get("hp", 0)) - own_hp,
		"atk_d": int(wheel[index].get("atk", 0)) - own_atk,
		"pack_tier": int(wheel[index].get("pack_tier", wheel[index].get("tier", 1))),
		"copy_from": int(wheel[index].get("copy_from", -1)),
		"preview_x2": false,
	}
	if str(self_row["id"]) == "wraith" and int(self_row["copy_from"]) >= 0:
		links.append({
			"to": index,
			"stat": "atk",
			"delta": int(self_row["atk_d"]),
			"tag": "copy",
			"src": int(self_row["copy_from"]),
		})
	if bool(self_row["preview_x2"]):
		var qn: int = wheel.size()
		for off in [qn - 1, 1]:
			var nb: int = (index + off) % qn
			if str(wheel[nb].get("kind", "")) == "monster" and int(wheel[nb].get("hp", 0)) < int(self_row["hp"]):
				links.append({"to": index, "stat": "atk", "delta": 0, "tag": "x2", "src": nb})
	var prev_from: int = int(wheel_view.seat_fx.get("from", -1))
	wheel.clear()
	for s2 in saved:
		wheel.append(s2)
	_sync_wheel_stats()
	_apply_preview(preview)
	wheel_view.set_seat_fx({"from": index, "links": links, "self": self_row})
	if not links.is_empty() and sfx and prev_from != index:
		sfx.play("whoosh", -16.0, 1.25)


func _preview_bribe(index: int) -> Dictionary:
	var p: Dictionary = {}
	var n: int = wheel.size()
	if index < 0 or index >= n:
		return p
	if str(wheel[index].get("card_id", "")) == "lich" and not _is_silenced(wheel[index]):
		for off in [n - 1, 1]:
			var j: int = (index + off) % n
			if str(wheel[j].get("kind", "")) == "monster":
				p[j] = {"hp": -1}
	if str(wheel[index].get("card_id", "")) == "commander" and not _is_silenced(wheel[index]):
		for off_c in [n - 1, 1]:
			var jc: int = (index + off_c) % n
			if str(wheel[jc].get("kind", "")) == "monster":
				var curc: Dictionary = p.get(jc, {})
				curc["atk"] = int(curc.get("atk", 0)) - 2
				p[jc] = curc
	for off2 in [n - 1, 1]:
		var k: int = (index + off2) % n
		if str(wheel[k].get("card_id", "")) == "lich" and not _is_silenced(wheel[k]) and str(wheel[index].get("kind", "")) == "monster":
			var cur: Dictionary = p.get(index, {})
			cur["hp"] = int(cur.get("hp", 0)) - 1
			p[index] = cur
		if str(wheel[k].get("card_id", "")) == "commander" and not _is_silenced(wheel[k]) and str(wheel[index].get("kind", "")) == "monster":
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
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "choose", "atk_wheel", "atk_echo", "atk_spend_blk", "atk_empty", "atk_hp_gap":
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
				var procs: int = 2 if _twins_double_atk(facing_index, dmg) else 1
				var total: int = 0
				for _p in range(procs):
					var hitn: int = dmg
					if str(wheel[facing_index].get("card_id", "")) == "anvil" and not _is_silenced(wheel[facing_index]):
						hitn = mini(hitn, 1)
					total += hitn
				p[facing_index] = {"hp": -total}
				if int(wheel[facing_index].get("hp", 0)) - total <= 0:
					if str(wheel[facing_index].get("card_id", "")) != "wick" or _is_silenced(wheel[facing_index]):
						p[facing_index]["kill"] = true
				if str(wheel[facing_index].get("card_id", "")) == "slime_boss":
					p[facing_index]["atk"] = -total
		"atk_cleave":
			if bool(view.get("can_use", false)):
				var cn: int = int(view.get("n", 2))
				for ci in _cleave_targets():
					if str(wheel[ci].get("card_id", "")) == "goblin":
						continue
					var procs_c: int = 2 if _twins_double_atk(ci, cn) else 1
					var hitn: int = 0
					for _pc in range(procs_c):
						var one: int = cn
						if str(wheel[ci].get("card_id", "")) == "anvil" and not _is_silenced(wheel[ci]):
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
				var od: int = int(view.get("n", 4))
				var procs_o: int = 2 if _twins_double_atk(oi, od) else 1
				var od_total: int = 0
				for _po in range(procs_o):
					var one_o: int = od
					if str(wheel[oi].get("card_id", "")) == "anvil" and not _is_silenced(wheel[oi]):
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
		"atk_zero", "atk_drop":
			if bool(view.get("can_use", false)):
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
			if str(wheel[i2].get("card_id", "")) == "bandit" and not bool(wheel[i2].get("spin_locked", false)):
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
	if punch and _ghost_blk < 0 and blk > _blk_shown and _blk_shown >= 0:
		_punch_blk()
	if _ghost_blk < 0:
		_blk_shown = blk


func _inspect_item(it: Dictionary, force: bool = false) -> void:
	if inspect == null:
		return
	if _inspect_pinned and not force:
		return
	_show_item_inspect(it)


func _bb(hex: String, text: String) -> String:
	return UX.chip(text, hex)


func _paint_explainer(raw: String, num_hex: String = "#E07A7A") -> String:
	return UX.paint(raw, true, num_hex)


func _paint_item_text(raw: String, it: Dictionary, formula: bool = false) -> String:
	var t: String = raw.strip_edges()
	if t == "" or t.find("[color") >= 0 or t.find("[bgcolor") >= 0:
		return raw
	if str(it.get("card_id", "")) == "spiked_shield":
		return UX.paint(t, true, "#E07A7A", "", false)
	var view: Dictionary = _item_view(it)
	var k: String = str(view.get("kind", "")).strip_edges()
	if k == "" or k == "PASSIVE" or k == "BOTH":
		return UX.paint(t, true, "#E07A7A", "", formula)
	return UX.paint(t, true, UX.kind_hex(k), k, formula)


func _capitalize_keywords(raw: String) -> String:
	return UX.paint(raw, false, "")


func _value_bb(word: String, n: String, hex: String) -> String:
	if n == "":
		return UX.chip(word, hex)
	return UX.chip("%s %s" % [word, n], hex)


func _item_rule(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var kind: String = str(_ops_of(it).get("kind", ""))
	var live: int = int(view.get("n", 0))
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
	var num_c: String = UX.kind_hex(str(view.get("kind", "ATK")))
	if kind == "smoke" or kind == "hook_swap":
		num_c = gold
	var cream := num_c
	match kind:
		"blk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["body"] = "Gain 4 block."
		"atk_alt_24":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) or (%s) on Item use" % [_bb(atk_c, "2"), _bb(atk_c, "4")]
			out["body"] = "Atk swaps between 2 ↔ 4 each time an Item is used."
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
				out["body"] = "Click 1, 2, or 3. The facing monster's Attack drops by that much after every other formula, then stays there this fight."
			elif spike_n or str(it.get("card_id", "")) == "spiked_shield":
				out["value"] = "%s    %s" % [_value_bb("Attack", "2", atk_c), _value_bb("Block", "2", blk_c)]
				out["equation"] = "(%s) or (%s)" % [_bb(atk_c, "2"), _bb(blk_c, "2")]
				out["body"] = "Deal 2 attack, or gain 2 block."
			else:
				out["value"] = _value_bb("Attack", "3", atk_c)
				out["equation"] = "(%s) or (%s and %s)" % [_bb(atk_c, "3"), _bb(atk_c, "1"), _bb(gold, "Keep")]
				out["body"] = "Throw for 3 and lose it, or nick for 1 and keep it."
		"atk_if_enemy_atk_even":
			out["value"] = _value_bb("Attack", str(live if fighting else 4), atk_c)
			out["equation"] = "(%s) or (%s if %s)" % [_bb(cream, "2"), _bb(atk_c, "4"), _bb(gold, "Even ATK")]
			out["body"] = "Attack 2, or 4 if the enemy's attack is even."
		"blk_from_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "6"), _bb(blk_c, "HP")]
			out["body"] = "Block equal to the HP you are missing."
		"blk_min_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(the lower of %s and %s)" % [_bb(blk_c, "Your HP"), _bb(blk_c, "Enemy HP")]
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
			if str(it.get("card_id", "")) == "left_bracer":
				out["equation"] = "(%s)" % _bb(blk_c, "Left Neighbor ATK")
				out["body"] = "Block equal to the Atk of the Neighbor to the Left."
			else:
				out["equation"] = "(%s)" % _bb(blk_c, "Right Neighbor ATK")
				out["body"] = "Block equal to the Atk of the Neighbor to the Right."
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
			out["body"] = "Starts at 0. +2 attack each time you lose any HP."
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
			out["equation"] = "(%s) to a Neighbor" % _bb(atk_c, "ATK 4")
			out["body"] = "Deal 4 Attack to a Neighboring enemy."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"atk_cleave":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) to facing and neighbors" % _bb(atk_c, "2")
			out["body"] = "Deal 2 attack to the monster you face and each neighboring monster. The same monster is only hit once."
		"atk_opposite":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) opposite if even count" % _bb(atk_c, "4")
			out["body"] = "Deal 4 attack to the monster across from you. Needs an even number of monsters."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — odd number of monsters on the wheel."
		"heal_kills":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "1"), _bb(var_c, "Defeat")]
			out["body"] = "Heal 1, plus 1 for each monster you have already defeated."
		"hook_swap":
			out["value"] = _value_bb("Swap", "", gold)
			out["body"] = "Swap a neighboring monster into this fight, then draw a random item."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"blk_siphon":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s) +2 per fight start" % _bb(blk_c, "BLK")
			out["body"] = "Each fight start: lose 1 HP. This card gains 2 block. Click it to spend that block."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no block stored yet."
		"atk_wheel":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(var_c, "Monsters left")
			out["body"] = "Attack equal to how many monsters are still on the wheel."
		"blk_from_atk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "Facing ATK")
			out["body"] = "Block equal to the facing monster's attack."
		"atk_zero":
			out["value"] = _value_bb("Attack", "0", atk_c)
			out["body"] = "The facing monster's attack becomes 0 this fight."
		"atk_drop":
			out["value"] = _value_bb("Attack", "−1 / −2 / −3", atk_c)
			out["body"] = "Click 1, 2, or 3. The facing monster's Attack drops by that much after every other formula, then stays there this fight."
		"heal_keep":
			out["value"] = _value_bb("Heal", "2", cream)
			out["equation"] = "(%s) then Keep if still missing HP" % _bb(cream, "2")
			out["body"] = "Heal 2. Keep this if you are still below 6 HP. If you are already at 6, it is used up."
		"heal_full":
			out["value"] = _value_bb("Heal", "to 6", cream)
			out["equation"] = "(%s)" % _bb(cream, "HP 6")
			out["body"] = "Heal your HP up to 6."
		"egg_hurt":
			out["value"] = _value_bb("Attack", "2", atk_c)
			out["equation"] = "(%s) to you" % _bb(atk_c, "2")
			out["body"] = str(it.get("ability", "Take 2 Attack."))
		"blk_last":
			out["value"] = _value_bb("Block", str(last_blk_gain), blk_c)
			out["equation"] = "(%s)" % _bb(blk_c, "Last Block gained")
			out["body"] = "Block equal to the last Block you gained this dungeon."
			if fighting and last_blk_gain <= 0:
				out["warn"] = "Can't — you have not gained Block yet this dungeon."
		"quiet":
			out["value"] = _value_bb("Quiet", "", var_c)
			out["body"] = "Remove the facing monster's unique ability for the rest of this dungeon. They use their printed Attack and HP."
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
		"atk_hp_gap":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s ÷ 2)" % _bb(hp_c, "your HP")
			out["body"] = "Deal Attack equal to half your HP (rounded down) and Heal that much. If they survive, Keep this item."
		"defeat_only_item":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["body"] = "If you have zero items that deal Attack, Defeat them."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and _hand_has_atk_item(int(it.get("uid", -1))):
				out["warn"] = "Can't — you are holding an Attack item."
		"chaos_reroll":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Click other items in your hand. Each becomes a random item of the same Weak, Tough, or Deadly."
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
				out["equation"] = _paint_item_text(fex, face, true)
			if ab != "" and ab != "---":
				out["body"] = _paint_item_text(ab, face, false)
			return out
	if ab != "" and ab != "---":
		out["body"] = _paint_item_text(ab, it, false)
	var ex: String = str(it.get("explainer", ""))
	if ex != "" and ex != "---":
		out["equation"] = _paint_item_text(ex, it, true)
	return out


func _monster_rule(s: Dictionary, swap_on_shift: bool = true) -> Dictionary:
	var id: String = str(s.get("card_id", ""))
	var atk_n: String = str(s.get("atk", 0))
	var hp_n: String = str(s.get("hp", 0))
	var atk_c := "#E07A7A"
	var hp_c := "#E8A0A0"
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
	var card: Dictionary = monsters_by_id.get(id, {})
	var reminder: String = str(s.get("reminder", "")).strip_edges()
	if reminder == "":
		reminder = str(card.get("reminder", "")).strip_edges()
	out["reminder"] = reminder
	var call_n: String = str(s.get("call_name", "")).strip_edges()
	if call_n == "":
		call_n = str(card.get("call_name", "")).strip_edges()
	out["call"] = call_n
	var sid: String = str(s.get("special_id", ""))
	out["call_hex"] = UX.call_hex(sid)
	if _is_silenced(s):
		out["speech"] = ""
		out["equation"] = ""
		out["reminder"] = ""
		out["hint"] = ""
		out["call"] = ""
		out["call_hex"] = ""
		return out
	if swap_on_shift and _shift_held:
		if reminder != "":
			out["equation"] = _paint_explainer(reminder, atk_c)
			out["equation_kind"] = "formula"
	elif call_n != "":
		out["equation"] = UX.call_bb(call_n, sid)
		out["equation_kind"] = "call"
	var speech: String = str(s.get("ability", "")).strip_edges()
	if speech == "" or speech == "---":
		speech = str(card.get("ability", "")).strip_edges()
	if speech == "---":
		speech = ""
	if speech != "":
		out["speech"] = _paint_explainer(speech)
	return out


func _monster_plate_look(s: Dictionary, rule: Dictionary, title_size: int = 22) -> Dictionary:
	var look: Dictionary = _monster_look(s)
	if _shift_held:
		look["hint"] = ""
	else:
		look["hint"] = str(rule.get("hint", ""))
	look["hp"] = int(s.get("hp", 0))
	look["atk"] = int(s.get("atk", 0))
	look["title_size"] = title_size
	look["title_bold"] = true
	look["call_hex"] = str(rule.get("call_hex", UX.call_hex(str(s.get("special_id", "")))))
	look["equation_kind"] = str(rule.get("equation_kind", ""))
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
	var look: Dictionary = _monster_plate_look(pending_monster, rule, 26)
	look["body_size"] = 17
	draft_gate.show_owner(
		str(rule.get("title", "")),
		str(rule.get("value", "")),
		str(rule.get("equation", "")),
		str(rule.get("speech", "")),
		str(rule.get("warn", "")),
		look
	)


func _sync_placement() -> void:
	var seating: bool = phase == "draft" and draft_action == "seat" and not pending_monster.is_empty()
	if placement_ui != null:
		placement_ui.visible = seating
		if seating:
			var tex: Texture2D = null
			if art != null:
				tex = art.monster_still(str(pending_monster.get("card_id", "")))
			if placement_ui.has_method("show_pending"):
				placement_ui.show_pending(pending_monster, tex)
			if draft_gate != null:
				draft_gate.visible = false
	_sync_torch()


func _sync_torch() -> void:
	if hud == null or not hud.has_method("set_torch"):
		return
	var seating: bool = phase == "draft" and draft_action == "seat"
	var hi: int = -1
	if wheel_view != null:
		hi = int(wheel_view.hover_index)
	var on: bool = seating and hi >= 0 and hi < wheel.size() and str(wheel[hi].get("kind", "")) == "empty"
	if not on:
		hud.set_torch(Vector2.ZERO, Vector2.ZERO, false)
		return
	var mouth: Vector2 = Vector2(1236, 190)
	if placement_ui != null and placement_ui.has_method("door_mouth_global"):
		mouth = placement_ui.door_mouth_global()
	var dest: Vector2 = wheel_view.slice_portrait_global(hi)
	hud.set_torch(mouth, dest, true)


func _idle_inspect() -> void:
	if inspect == null:
		return
	if in_tutorial and tut != null and tut.visible:
		inspect.hide_plate()
		_set_inspect_idle(false)
		if fight_ui:
			fight_ui.visible = false
		if placement_ui and not (phase == "draft" and draft_action == "seat"):
			placement_ui.visible = false
		if talk_ui:
			talk_ui.visible = not (draft_gate != null and draft_gate.visible and draft_gate.mode == "ask")
		return
	if talk_ui and not in_tutorial:
		talk_ui.visible = false
	if phase == "title":
		inspect.hide_plate()
		_set_inspect_idle(false)
		return
	if phase == "draft" and draft_action == "seat":
		inspect.hide_plate()
		_set_inspect_idle(false)
		_sync_torch()
		return
	var gate_up: bool = draft_gate != null and draft_gate.visible and phase == "draft"
	if gate_up and (draft_action == "ask" or draft_action == "seat" or draft_action == "busy"):
		if _fly_card != null or not _hover_item.is_empty():
			return
		inspect.hide_plate()
		_set_inspect_idle(false)
		return
	if _fly_card != null:
		return
	if _hover_slice >= 0 and _hover_slice < wheel.size() and _hover_slice != facing_index:
		if str(wheel[_hover_slice].get("kind", "")) == "monster":
			_fill_inspect_from_slice(_hover_slice)
			return
	inspect.hide_plate()
	_set_inspect_idle(phase == "ready" or phase == "spinning")
	if fight_ui != null and (phase == "fighting" or phase == "slaying"):
		fight_ui.visible = true
	if placement_ui != null and phase == "draft" and draft_action == "seat":
		placement_ui.visible = true


func _set_inspect_idle(on: bool) -> void:
	if hud != null and hud.has_method("set_idle_visible"):
		hud.set_idle_visible(on)


func _fill_inspect_from_slice(index: int) -> void:
	if inspect == null or index < 0 or index >= wheel.size():
		_idle_inspect()
		return
	inspect.visible = true
	_set_inspect_idle(false)
	if fight_ui:
		fight_ui.visible = false
	if placement_ui:
		placement_ui.visible = false
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		inspect.show_text(
			PLAYER_COPY.text("inspect.empty_title", "Empty"),
			PLAYER_COPY.text("inspect.empty_place", "Click this alcove. That's where they'll wait.") if _can_place() else PLAYER_COPY.text("inspect.empty", "An empty alcove.")
		)
		return
	var rule: Dictionary = _monster_rule(s, false)
	var body: String = str(rule.get("speech", ""))
	var port: Texture2D = null
	if art != null:
		port = art.monster_still(str(s.get("card_id", "")))
	inspect.show_rule(str(rule["title"]), "", str(rule["equation"]), body, str(rule.get("warn", "")), port, "monster", str(s.get("card_id", "")), _monster_plate_look(s, rule, 26))


func _refresh_monster_plates() -> void:
	_idle_inspect()
	_refresh_face()


func _place_fly(near: Control = null) -> void:
	if fly_tip == null or not fly_tip.visible:
		return
	fly_tip.reset_size()
	var sz: Vector2 = fly_tip.get_combined_minimum_size()
	sz.x = maxf(sz.x, 280.0)
	var pos: Vector2
	if near != null and is_instance_valid(near):
		if near == _offer_card:
			pos = near.global_position + Vector2(-sz.x - 12.0, -8.0)
		else:
			pos = near.global_position + Vector2(near.size.x + 10.0, -8.0)
	else:
		pos = get_global_mouse_position() + Vector2(20.0, 16.0)
	var vp: Vector2 = get_viewport_rect().size
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - sz.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - sz.y - 8.0))
	fly_tip.global_position = pos
	fly_tip.size = sz


func _place_speech() -> void:
	if speech_box == null:
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
		return
	if _cube_line != "" and not _shift_held and combat_stage != null and combat_stage.visible:
		var cube_look := {}
		if facing_index >= 0 and facing_index < wheel.size():
			cube_look = _monster_look(wheel[facing_index])
		speech_box.present(combat_stage.mouth_global(), _cube_line, cube_look, true)
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


func _place_fight_art() -> void:
	if wheel_view == null:
		return
	var wr: Rect2 = wheel_view.get_global_rect()
	var stack_w := 252.0
	var port_sz := Vector2(168, 128)
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
	var x: float = wr.end.x + 14.0
	if inspect != null:
		x = minf(x, inspect.global_position.x - stack_w - 12.0)
	x = maxf(x, wr.end.x + 10.0)
	var speech_room := 156.0
	var y: float = wr.end.y - total - 18.0
	y = maxf(y, wr.position.y + speech_room)
	if y + total > wr.end.y + 8.0:
		y = wr.position.y + maxf(8.0, wr.size.y - total)
	if combat_stage != null and combat_stage.visible:
		combat_stage.size = port_sz
		combat_stage.global_position = Vector2(x + (stack_w - port_sz.x) * 0.5, y)
		y += port_sz.y + gap
	if face_box != null and face_box.visible:
		var psz: Vector2 = face_box.get_combined_minimum_size()
		psz.x = stack_w
		face_box.size = psz
		face_box.global_position = Vector2(x, y)


func _speech_gutter() -> Rect2:
	if wheel_view == null:
		return Rect2()
	var wr: Rect2 = wheel_view.get_global_rect()
	var left: float = wr.end.x + 10.0
	var right: float = get_viewport_rect().size.x - 12.0
	if inspect != null:
		right = minf(right, inspect.global_position.x - 12.0)
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
			if lost_soon:
				tr.modulate = Color("e07a7a")
			elif hp <= 2:
				tr.modulate = Color("f0b0a8")
			else:
				tr.modulate = Color.WHITE
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
	if col.r > 0.55 and col.g < 0.45 and col.b < 0.45:
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
		var skull: Texture2D = load("res://assets/icons/skull.svg") as Texture2D
		if skull != null:
			return skull
		if tex_by_item.has("fangs"):
			return tex_by_item["fangs"]
		if art != null and art.tile("skull") != null:
			return art.tile("skull")
		return tex_heart
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
		var ab: String = str(it.get("ability", ""))
		if ab != "" and ab != "---" and c.has_method("set_ability_bb"):
			c.set_ability_bb(_paint_item_text(ab, it, false))
		c.show_formula(_shift_held)
	_refresh_offer_card()
	if choice_box == null:
		return
	for c in choice_box.get_children():
		if not c.has_method("show_formula"):
			continue
		c.show_formula(_shift_held)


func _layout_play_field() -> void:
	if play_field == null or wheel_view == null:
		return
	if trophy:
		trophy.visible = false
	if tray != null and tray.visible:
		var tmin: Vector2 = tray.get_combined_minimum_size()
		tray.position = Vector2(32.0, 68.0)
		tray.size = tmin
	wheel_view.position = Vector2(236, 38)
	wheel_view.size = Vector2(624, 624)
	if hud != null and hud.has_method("layout_hand"):
		hud.layout_hand()


func _set_cue(t: String) -> void:
	_cue_shown = t
	if hud != null and hud.has_method("set_cue"):
		hud.set_cue(t)
		hud.set_cue_dim(phase == "spinning")
	elif cue_label != null:
		cue_label.text = t
		cue_label.visible = t != ""


func _refresh_face() -> void:
	if face_box:
		face_box.hide_plate()
	if combat_stage:
		combat_stage.visible = false
	var show: bool = (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size()
	if fight_ui:
		fight_ui.visible = show
	if not show:
		return
	var m: Dictionary = wheel[facing_index]
	var tex: Texture2D = null
	if art != null:
		tex = art.monster_still(str(m.get("card_id", "")))
	if fight_ui != null and fight_ui.has_method("show_owner"):
		fight_ui.show_owner(m, tex)
	if placement_ui:
		placement_ui.visible = false
	var atk_s: String = str(m.get("atk", 0))
	var hp_s: String = str(m.get("hp", 0))
	if fight_ui != null and ((atk_s != _face_atk_shown and _face_atk_shown != "") or (hp_s != _face_hp_shown and _face_hp_shown != "")):
		var tw := create_tween()
		tw.tween_property(fight_ui, "modulate", Color(1.15, 1.08, 0.95, 1), 0.08)
		tw.tween_property(fight_ui, "modulate", Color.WHITE, 0.12)
	_face_atk_shown = atk_s
	_face_hp_shown = hp_s
	_place_fight_art()


func _refresh() -> void:
	_sync_wheel_stats()
	_refresh_hearts()
	_refresh_blk(true)
	_refresh_face()
	_idle_inspect()
	if trophy:
		trophy.visible = false
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
	_sync_placement()
	if wheel_view != null:
		wheel_view.seat_hover_on = phase == "ready" or (phase == "draft" and draft_action == "seat")
		wheel_view.dim_nonfacing = phase == "fighting" or phase == "slaying"
	_rebuild_tray()
	_sync_hotbar()
	_rebuild_choice()
	_sync_buttons()
	_sync_overlay()
	_sync_dev_panel()
	_sync_authoring_chrome()
	_place_speech()


func _cue_text() -> String:
	if in_tutorial:
		return ""
	if draft_gate != null and draft_gate.visible and phase == "draft" and draft_action == "ask":
		return ""
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
			return PLAYER_COPY.text("cue.filling", "The nest is filling.")
		"devtest":
			return PLAYER_COPY.text("cue.devtest", "Click a monster to seat it, an item to add it to your hand. Play when you have at least one monster.")
		"rest":
			return PLAYER_COPY.fill("title.rest_sub", {"n": dungeons_cleared}, "Dungeon %s is behind you." % dungeons_cleared)
		"ready":
			return PLAYER_COPY.need("cue.ready")
		"fighting":
			if not pending_feed.is_empty():
				return "Feed the cube one of those items."
			if not pending_chaos.is_empty():
				var need_n: int = int(pending_chaos.get("need", 1))
				if need_n <= 1:
					return "Click the other item to reroll it."
				return "Click two other items to reroll them."
			if not pending_mark.is_empty():
				return PLAYER_COPY.text("cue.mark", "Click a neighboring enemy")
			if facing_index >= 0 and _wick_waiting(facing_index):
				return "They are at 0 HP. Click Done."
			return PLAYER_COPY.need("cue.fighting")
		"slaying":
			return ""
		"spinning":
			return PLAYER_COPY.need("cue.ready")
		_:
			return ""


func _sync_buttons() -> void:
	var busy: bool = phase == "spinning" or phase == "slaying" or (phase == "draft" and draft_action == "busy") or _wheel_busy() or _adventure_busy
	var enemy_up: bool = phase == "fighting" and facing_index >= 0 and (int(wheel[facing_index].get("hp", 0)) > 0 or _wick_waiting(facing_index))
	btn_spin.disabled = busy or phase != "ready"
	btn_done.disabled = busy or not enemy_up or not pending_feed.is_empty() or not pending_chaos.is_empty()
	btn_start.disabled = busy
	btn_place.visible = false
	btn_bribe.visible = false
	btn_spin.visible = phase == "ready" or phase == "spinning"
	btn_done.visible = false
	if phase == "devtest":
		btn_spin.visible = false
		btn_done.visible = false
	btn_start.visible = false
	btn_start.modulate = Color.WHITE
	if in_tutorial:
		btn_start.disabled = true
		btn_spin.disabled = busy or phase != "ready" or tut == null or tut.wait != "spin"
		btn_done.disabled = busy or not enemy_up or tut == null or not _tut_can_done()
	if hud != null and hud.has_method("set_spin_live"):
		hud.set_spin_live(btn_spin.visible and not btn_spin.disabled)
	if enemy_up:
		var hit: int = _incoming_hit()
		var lab: String = PLAYER_COPY.fill("combat.take_hit", {"n": hit}, "Take %s" % hit) if hit > 0 else PLAYER_COPY.text("combat.safe", "Safe")
		btn_done.text = lab
		if fight_ui != null and fight_ui.has_method("set_resolve"):
			fight_ui.set_resolve(lab, hit > 0, btn_done.disabled)


func _sync_overlay() -> void:
	if in_tutorial and tut != null and tut.visible:
		overlay.visible = false
		if title_ui:
			title_ui.visible = false
		if hud != null:
			hud.visible = true
			if hud.hotbar_box:
				hud.hotbar_box.visible = true
			if hud.has_method("layout_hand"):
				hud.layout_hand()
		return
	var on_title: bool = phase == "title"
	var on_win: bool = phase == "victory"
	var on_lose: bool = phase == "defeat"
	if title_ui:
		title_ui.visible = on_title
		if on_title:
			title_ui.grab_play()
	if victory_ui:
		victory_ui.visible = on_win
		if on_win:
			victory_ui.refresh_copy()
			var loot_n: int = 0
			for it in hotbar:
				if typeof(it) == TYPE_DICTIONARY:
					loot_n += 1
			if victory_ui.has_method("play_win_intro"):
				victory_ui.play_win_intro(loot_n)
			victory_ui.grab_again()
		elif victory_ui.has_method("reset_win_intro"):
			victory_ui.reset_win_intro()
	if defeat_ui:
		defeat_ui.visible = on_lose
		if on_lose:
			defeat_ui.refresh_copy()
			defeat_ui.grab_again()
	if fight_ui and (on_win or on_lose or on_title):
		fight_ui.visible = false
	if inspect and (on_win or on_lose or on_title):
		inspect.hide_plate()
	if draft_gate and (on_win or on_lose or on_title):
		draft_gate.hide_gate()
	if talk_ui and (on_win or on_lose or on_title):
		talk_ui.visible = false
	if wheel_view:
		if on_win:
			wheel_view.modulate = Color(1, 1, 1, 0.5)
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(true)
		elif on_lose:
			wheel_view.modulate = Color(Color("5A5048"), 0.22)
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(false)
		else:
			wheel_view.modulate = Color.WHITE
			if wheel_view.has_method("set_nest_empty"):
				wheel_view.set_nest_empty(false)
	if hud != null:
		if hud.has_method("set_column_kind"):
			if on_win:
				hud.set_column_kind("victory")
			elif on_lose:
				hud.set_column_kind("defeat")
			else:
				hud.set_column_kind("")
		if hud.has_method("set_pointer_dim"):
			hud.set_pointer_dim("defeat" if on_lose else "")
		if hud.has_method("set_ghost_hand"):
			hud.set_ghost_hand(on_lose)
		if hud.hotbar_box:
			hud.hotbar_box.visible = not on_win and not on_lose and not (phase == "title")
		if on_win and hud.has_method("show_loot"):
			var loot: Array = []
			for it in hotbar:
				if typeof(it) != TYPE_DICTIONARY:
					continue
				var tex: Texture2D = null
				if art != null:
					tex = art.item_tex(str(it.get("card_id", "")))
				if tex != null:
					loot.append(tex)
			hud.show_loot(loot)
		elif hud.has_method("hide_loot"):
			hud.hide_loot()
	var show: bool = phase == "rest"
	overlay.visible = show
	if hud != null:
		hud.visible = not on_title
	if overlay_dive:
		overlay_dive.visible = on_title
	if overlay_tut:
		overlay_tut.visible = on_title
	if overlay_adventure:
		overlay_adventure.visible = on_title
	if overlay_dev:
		overlay_dev.visible = on_title and _authoring()
	if overlay_tools_row:
		overlay_tools_row.visible = on_title and _authoring()
	if overlay_rest_row:
		overlay_rest_row.visible = phase == "rest"
	if overlay_btn:
		overlay_btn.visible = phase != "rest"
	if overlay_score:
		overlay_score.visible = adventure and (phase == "victory" or phase == "defeat")
		if overlay_score.visible:
			overlay_score.text = PLAYER_COPY.fill("title.dungeons_cleared", {"n": dungeons_cleared}, "Dungeons cleared: %s" % dungeons_cleared)
	if phase == "title":
		overlay_title.text = PLAYER_COPY.text("title.overlay", "Swipe")
		overlay_sub.text = PLAYER_COPY.text("title.sub", "You just couldn't keep your grubby hands off their loot, could ya?")
		overlay_btn.text = PLAYER_COPY.text("title.begin", "Begin")
	elif phase == "rest":
		overlay_title.text = PLAYER_COPY.text("title.rest", "Another hall")
		overlay_sub.text = PLAYER_COPY.fill("title.rest_sub", {"n": dungeons_cleared}, "Dungeon %s is behind you. Leftover cards stay. Heal to full." % dungeons_cleared)
	elif phase == "victory":
		if adventure:
			overlay_title.text = PLAYER_COPY.text("title.adventure_win", "Victory")
			overlay_sub.text = ""
		else:
			overlay_title.text = PLAYER_COPY.text("title.win", "Kept it")
			overlay_sub.text = PLAYER_COPY.text("title.win_sub", "The pile is yours.")
		overlay_btn.text = PLAYER_COPY.text("title.again", "Again")
	elif phase == "defeat":
		overlay_title.text = PLAYER_COPY.text("title.lose", "Caught")
		if adventure:
			overlay_sub.text = ""
		else:
			overlay_sub.text = PLAYER_COPY.text("title.lose_sub", "They took it all back.")
		overlay_btn.text = PLAYER_COPY.text("title.again", "Again")


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
	UiPalette.apply_name(n, Color("f0e6d8"), UiPalette.SIZE_NAME)
	col.add_child(n)
	var stats := Label.new()
	stats.text = "%s / %s" % [s.get("atk", 0), s.get("hp", 0)]
	UiPalette.apply_number(stats, Color("ffffff"), UiPalette.SIZE_NUMBER)
	col.add_child(stats)
	var spec := Label.new()
	var chip_rule: Dictionary = _monster_rule(s)
	var st: String = str(chip_rule.get("reminder", ""))
	spec.text = st if st != "" else "No special"
	spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiPalette.apply_body(spec, Color("c9b9a8"), UiPalette.SIZE_BODY)
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
	var sig := PackedStringArray()
	for it in hotbar:
		var echo_id: String = ""
		if typeof(it.get("echo_copy", null)) == TYPE_DICTIONARY:
			echo_id = str((it["echo_copy"] as Dictionary).get("card_id", ""))
		sig.append("%s:%s:%s:%s" % [it.get("uid", 0), it.get("card_id", ""), echo_id, it.get("petrified", false)])
	var joined: String = ",".join(sig)
	if joined != _hotbar_sig:
		_hotbar_sig = joined
		for c in hotbar_box.get_children():
			hotbar_box.remove_child(c)
			c.queue_free()
		for it in hotbar:
			hotbar_box.add_child(_spawn_item_card(it, true))
	var n: int = hotbar_box.get_child_count()
	var sep: int = 10 if n >= 8 else 14
	hotbar_box.add_theme_constant_override("h_separation", sep)
	hotbar_box.add_theme_constant_override("v_separation", sep)
	for c in hotbar_box.get_children():
		if c.has_method("set_compact"):
			c.set_compact(n >= 8)
	for c in hotbar_box.get_children():
		var card = c
		if not card.has_method("set_live"):
			continue
		var it: Dictionary = _find_item(int(card.uid))
		if it.is_empty():
			continue
		var view: Dictionary = _item_view(it)
		var dim: bool = phase == "fighting" and not bool(view["can_use"])
		card.spent = bool(it.get("spent", false))
		card.set_palette(view["fill"], view["rim"], _tier_of(it))
		card.set_live(str(view["number"]), str(view["note"]), not dim)
		if card.has_method("set_loss_icon"):
			card.set_loss_icon(tex_heart if bool(view.get("loss_icon", false)) else null)
		if card.has_method("set_playable"):
			card.set_playable(phase == "fighting" and bool(view["can_use"]) and not bool(it.get("spent", false)) and not bool(it.get("petrified", false)))
		if card.has_method("set_petrified"):
			card.set_petrified(bool(it.get("petrified", false)))
		if phase == "spinning":
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if card.has_method("set_playable"):
				card.set_playable(false)
	_sync_hotbar_formulas()
	if hud != null and hud.has_method("layout_hand"):
		hud.layout_hand()


func _spawn_item_card(it: Dictionary, usable: bool) -> PanelContainer:
	var view: Dictionary = _item_view(it)
	var card = HAND_CARD_SCN.instantiate()
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
	card.set_palette(view["fill"], view["rim"], _tier_of(it))
	var rule: Dictionary = _item_rule(it)
	card.set_formula(str(rule.get("equation", "")))
	var dim: bool = phase == "fighting" and not bool(view.get("can_use", true))
	card.set_live(str(view["number"]), str(view.get("note", "")), not dim)
	if card.has_method("set_loss_icon"):
		card.set_loss_icon(tex_heart if bool(view.get("loss_icon", false)) else null)
	var ab: String = str(it.get("ability", ""))
	if ab != "" and ab != "---":
		card.set_ability_bb(_paint_item_text(ab, it, false))
	card.show_formula(_shift_held)
	card.hovered.connect(func() -> void:
		_on_item_hovered(it, card)
	)
	card.unhovered.connect(_on_item_unhovered)
	if _authoring():
		card.edit_wanted.connect(_open_content_editor.bind("item", str(it.get("card_id", ""))))
	if usable:
		card.picked.connect(_use_item.bind(int(it["uid"])))
	return card


func _on_gate_item_hovered() -> void:
	if pending_item.is_empty():
		return
	var host: Control = null
	if draft_gate != null and draft_gate.has_method("relic_host"):
		host = draft_gate.relic_host()
	_on_item_hovered(pending_item, host)


func _on_item_hovered(it: Dictionary, card: Control = null) -> void:
	_fly_card = card
	_hover_item = it
	if sfx:
		sfx.hover()
	if inspect != null and phase != "title":
		_show_item_inspect(it)
	if fly_tip:
		fly_tip.hide_plate()
	_apply_preview(_preview_from_item(it))
	_refresh_blk(false)
	if in_tutorial and tut != null and tut.wait == "hover_item":
		_inspect_item(it, true)
	_tutorial_on_item_hover(str(it.get("card_id", "")))


func _on_item_unhovered() -> void:
	_fly_card = null
	_hover_item = {}
	_ghost_blk = -1
	_apply_preview({})
	if fly_tip:
		fly_tip.hide_plate()
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
			var lab: String = "Feed  %s" % _title_case(str(it.get("name", "?")))
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
	_tut_boot = true
	in_tutorial = true
	_tut_inspect_page = -1
	_tut_mill_busy = false
	_tut_up_a = -1
	_tut_up_b = -1
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
	if _tut_mill_busy or not tut.armed():
		return
	if sfx:
		sfx.play("click", -12.0)
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tut_skip() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if draft_gate:
		draft_gate.hide_gate()
	if tut:
		tut.close()
	_reset_run()
	phase = "title"
	_refresh()


func _tut_finished() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if tut:
		tut.close()
	_refresh()


func _tut_auto_spin() -> void:
	if not in_tutorial or phase != "ready":
		return
	_on_spin()


func _tut_play_adventure() -> void:
	in_tutorial = false
	_tut_mill_busy = false
	if wheel_view:
		wheel_view.tut_wedges = []
	if draft_gate:
		draft_gate.hide_gate()
	if tut:
		tut.close()
	_begin_adventure()


func _tut_mill_demo(kind: String) -> void:
	if not in_tutorial:
		return
	_tut_run_mill(kind)


func _tut_run_mill(kind: String) -> void:
	_tut_mill_busy = true
	match kind:
		"seat":
			await _tut_mill_seat()
		"upgrade":
			adventure = true
			dungeon_index = maxi(dungeon_index, 2)
			await _upgrade_two_openers()
			_tut_refresh_focus()
		"draft":
			if draft_action != "ask":
				_open_petitioner()
		"fill":
			if _empty_count() > 0 and pending_monster.is_empty():
				_open_petitioner()
	_tut_mill_busy = false
	_refresh()
	_tut_refresh_focus()


func _tut_mill_seat() -> void:
	adventure = true
	dungeon_index = 2
	adventure_seat_tiers = [1, 1, 1, 1]
	hp = HP_MAX
	blk = 0
	facing_index = -1
	_empty_wheel()
	phase = "draft"
	draft_action = "busy"
	_refresh()
	var seq: int = _mill_seq
	for i in range(CARDINAL_SLOTS.size()):
		if seq != _mill_seq or not in_tutorial:
			return
		var si: int = int(CARDINAL_SLOTS[i])
		var mid: String = _take_card(monster_pool, monsters_by_id, "starter", 0)
		if mid == "":
			mid = _take_monster_of_tier(1)
		if mid == "":
			break
		_seat_opener(si, mid, "starter")
		if wheel_view:
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play("drop", -10.0, 0.92 + float(si) * 0.02)
		await get_tree().create_timer(0.22).timeout
	starters_left = 0
	_refresh()


func _tut_refresh_focus() -> void:
	if tut == null or not in_tutorial or not tut.visible:
		return
	if (tut.wait == "end" or tut.wait == "walk") and draft_gate:
		draft_gate.hide_gate()
	_tut_apply_wedges()
	var tag: String = tut.focus_tag
	if tut.wait == "seat" or tut.wait == "mill_done":
		tut.follow_many(_tut_empty_proxies())
		return
	if tag == "both_hp":
		tut.follow_many(_tut_both_hp())
		return
	if tag == "two_slices":
		tut.follow_many(_tut_two_slices())
		return
	if tag == "choice":
		tut.follow_many([_hotbar_card("da_boot"), btn_done])
		return
	if tag == "inspect" and int(tut._page_i) != _tut_inspect_page:
		_tut_inspect_page = int(tut._page_i)
		_tut_fill_inspect()
	tut.follow(_tut_focus())


func _tut_focus() -> Control:
	if tut == null:
		return null
	var tag: String = tut.focus_tag
	match tag:
		"wheel":
			return wheel_view
		"hearts":
			if hearts_box != null and hearts_box.visible:
				return hearts_box
			if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
				return wheel_view.hub_stat_proxy("hp")
			return wheel_view
		"block":
			if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
				return wheel_view.hub_stat_proxy("blk")
			return wheel_view
		"hotbar":
			return hotbar_box
		"empty_slice":
			if wheel_view != null and wheel_view.has_method("slice_focus_proxy"):
				return wheel_view.slice_focus_proxy(_first_empty_slice())
			return wheel_view
		"wizard_atk":
			return _tut_monster_stat("wizard", "atk")
		"wizard_hp":
			return _tut_monster_stat("wizard", "hp")
		"monster":
			return _tut_monster_slice("goblin")
		"inspect":
			return inspect
		"gate":
			return draft_gate
		"gate_take":
			if _offer_card != null and is_instance_valid(_offer_card):
				return _offer_card
			if draft_gate != null and draft_gate.has_method("relic_host"):
				return draft_gate.relic_host()
			return draft_gate
		"gate_leave":
			if draft_gate != null and draft_gate.has_method("leave_btn"):
				return draft_gate.leave_btn()
			return draft_gate
		"spin":
			return btn_spin
		"done":
			return btn_done
		"trophy":
			return trophy
		"face":
			return face_box
		_:
			if tag.begins_with("item:"):
				return _hotbar_card(tag.substr(5))
	return null


func _tut_fill_inspect() -> void:
	if facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("card_id", "")) == "goblin":
		_fill_inspect_from_slice(facing_index)
		return
	for it in hotbar:
		if str(it.get("card_id", "")) == "helmet" and not bool(it.get("spent", false)):
			_inspect_item(it, true)
			return
	if facing_index >= 0:
		_fill_inspect_from_slice(facing_index)


func _tut_monster_slice(id: String) -> Control:
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return wheel_view
	var i: int = _index_of_monster(id)
	if i < 0 and facing_index >= 0:
		i = facing_index
	return wheel_view.slice_focus_proxy(i)


func _tut_monster_stat(id: String, kind: String) -> Control:
	if wheel_view == null or not wheel_view.has_method("slice_stat_proxy"):
		return _tut_monster_slice(id)
	var i: int = _index_of_monster(id)
	if i < 0 and facing_index >= 0:
		i = facing_index
	return wheel_view.slice_stat_proxy(i, kind)


func _tut_both_hp() -> Array:
	var out: Array = []
	if wheel_view != null and wheel_view.has_method("hub_stat_proxy"):
		out.append(wheel_view.hub_stat_proxy("hp"))
	elif hearts_box != null:
		out.append(hearts_box)
	var g: Control = _tut_monster_stat("golem", "hp")
	if g != null:
		out.append(g)
	return out


func _tut_apply_wedges() -> void:
	if wheel_view == null:
		return
	var tag: String = tut.focus_tag if tut else ""
	var w: String = tut.wait if tut else ""
	var idx: Array = []
	if w == "seat" or w == "mill_done" or tag == "empty_slice":
		if w == "seat" or w == "mill_done":
			idx = _tut_empty_indices()
		else:
			idx = [_first_empty_slice()]
	elif tag == "two_slices":
		if _tut_up_a >= 0:
			idx.append(_tut_up_a)
		if _tut_up_b >= 0 and _tut_up_b != _tut_up_a:
			idx.append(_tut_up_b)
	elif tag == "monster":
		var g: int = _index_of_monster("goblin")
		if g < 0:
			g = facing_index
		if g >= 0:
			idx.append(g)
	wheel_view.tut_wedges = idx


func _tut_empty_indices() -> Array:
	var out: Array = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			out.append(i)
	return out


func _tut_empty_proxies() -> Array:
	var out: Array = []
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return [wheel_view]
	for i in _tut_empty_indices():
		out.append(wheel_view.slice_focus_proxy(int(i), str(i)))
	return out


func _tut_two_slices() -> Array:
	if wheel_view == null or not wheel_view.has_method("slice_focus_proxy"):
		return [wheel_view]
	var a: int = _tut_up_a
	var b: int = _tut_up_b
	if a < 0 or b < 0:
		a = int(CARDINAL_SLOTS[0])
		b = int(CARDINAL_SLOTS[2])
	return [wheel_view.slice_focus_proxy(a, "A"), wheel_view.slice_focus_proxy(b, "B")]


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


func _tutorial_spin_index() -> int:
	if tut != null and str(tut.spin_id) != "":
		var want: int = _index_of_monster(str(tut.spin_id))
		if want >= 0:
			return want
	for id in ["wizard", "golem", "goblin"]:
		var i: int = _index_of_monster(id)
		if i >= 0:
			return i
	return -1


func _tut_can_done() -> bool:
	if tut == null:
		return false
	if tut.wait == "done" or tut.wait == "choice":
		return true
	return tut.wait == "continue" and tut.focus_tag == "done"


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
		tut.set_choice("boot")
		return
	if tut.wait != "item:%s" % id:
		return
	if id == "sai" or id == "da_boot":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_combat_started() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "spin":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_after_fight() -> void:
	if not in_tutorial or tut == null:
		return
	var w: String = tut.wait
	if w != "item:sai" and w != "item:da_boot" and w != "done" and w != "choice":
		return
	if w == "choice" and str(tut.branch_pick) == "":
		tut.set_choice("take")
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_on_item_hover(id: String = "") -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_item":
		return
	if id != "" and id != "da_boot":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_on_slice_hover(index: int) -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if tut.wait != "hover_shift":
		return
	if not _shift_held:
		return
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	tut.advance()
	_tut_refresh_focus()
	_sync_buttons()


func _tutorial_shift_tick() -> void:
	if not in_tutorial or tut == null or not tut.armed():
		return
	if not _shift_held:
		return
	if tut.wait == "hover_shift" and _hover_slice >= 0 and _hover_slice < wheel.size():
		if str(wheel[_hover_slice].get("kind", "")) == "monster":
			tut.advance()
			_tut_refresh_focus()
			_sync_buttons()
			return
	if tut.wait == "hover_item":
		tut.advance()
		_tut_refresh_focus()
		_sync_buttons()
