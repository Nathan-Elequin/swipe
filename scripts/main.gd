extends Control
## Full loop: title, mill gate draft, combat, victory/defeat.

signal bled(n: int)

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
const PlaytestUx := preload("res://scripts/playtest_ux.gd")
const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const MONSTER_LINES := preload("res://scripts/monster_lines.gd")
const P1 := preload("res://scripts/spinheritance_p1.gd")
const SP_DALLAS := preload("res://scripts/sp_dallas_pack.gd")
const DUNGEON_BG := preload("res://scripts/dungeon_bg.gd")
const COMBAT_STAGE := preload("res://scripts/combat_stage.gd")
const PLAYER_STAGE := preload("res://scripts/player_stage.gd")
const MOVE_ARROW := preload("res://scripts/ui/move_arrow.gd")
const VIEW_FRAME := preload("res://scripts/ui/view_frame.gd")
const ARROW_GLYPHS := preload("res://scripts/ui/arrow_glyphs.gd")
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
const HUB_CUE_CAPSULE := preload("res://scripts/ui/hub_cue_capsule.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const CAMPAIGN_MAP := preload("res://scripts/campaign_map.gd")
const HOME_CABIN := preload("res://scripts/home_cabin.gd")
const SHOT_CLI := preload("res://scripts/shot_cli.gd")
const BUILD_STAMP := preload("res://scripts/build_stamp.gd")
const FRAME_METRICS := preload("res://scripts/frame_metrics.gd")
const HOT_EMPTY := preload("res://scripts/hot_empty_slot.gd")
const REVIEW_STAGE := preload("res://scripts/review_stage.gd")
const RECENT_EDITS := preload("res://scripts/recent_edits.gd")
const SLOT_ORDER := ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
const FLOOR_Y := 560.0
const STAGE_MIRROR_X := 1680.0
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
const ADVENTURE_MOVES := 3
const MARBLE_FILL := 10
## 1.0 = original speed. Wheel spin ignores this.
## 0.675 = 35% faster than the previous 0.5 setting.
const ANIM_TIME_SCALE := 0.675

const COMBAT_LOG := preload("res://scripts/combat_log.gd")
const ABILITY_SLASH := preload("res://scripts/ability_slash.gd")
const INTENT_PLATE := preload("res://scripts/intent_plate.gd")
const BLEED_PULSE := preload("res://scripts/bleed_pulse.gd")
const CASCADE_TICKER := preload("res://scripts/cascade_ticker.gd")
const POISON_POP := preload("res://scripts/poison_pop.gd")
const HOOK_FX := preload("res://scripts/hook_fx.gd")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const PLAYTEST_HUB := preload("res://scripts/playtest_hub.gd")
const PLAYTEST_FEEDBACK := preload("res://scripts/playtest_feedback.gd")
const PLAYTEST_TIER := preload("res://scripts/playtest_tier_list.gd")
const PLAYTEST_INBOX := preload("res://scripts/playtest_inbox.gd")
const SESSION_LOG := preload("res://scripts/session_log.gd")
const PLAYTEST_INTRO := preload("res://scripts/playtest_intro.gd")
const TITLE_TEASER := preload("res://scripts/title_teaser.gd")
const PLAYTEST_META_PATH := "user://playtest_meta.json"

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
	"orb": {"kind": "orb"},
	"bag_of_holding": {"kind": "bag_hold"},
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
	"poison_flask": {"kind": "mark_poison", "n": 5},
	"healing_potion": {"kind": "passive"},
	"crossbow": {"kind": "atk_neighbor", "n": 4},
	"pocketwatch": {"kind": "hypnotize"},
	"double_axe": {"kind": "atk_cleave", "n": 2},
	"victory_flask": {"kind": "heal_kills"},
	"grappling_hook": {"kind": "hook_swap"},
	"spiked_shield": {"kind": "shield_alt"},
	"pacemaker": {"kind": "pacemaker_use"},
	"catapult": {"kind": "eject_draw"},
	"polymorph": {"kind": "polymorph"},
	"stone_wall": {"kind": "blk", "n": 10},
	"flying_saucer": {"kind": "flee_then_blk", "n": 5},
	"blood_chalice": {"kind": "heal_last_loss"},
	"grief_jar": {"kind": "blk_siphon"},
	"longbow": {"kind": "atk_opposite", "n": 5},
	"lantern": {"kind": "heal_keep", "n": 1},
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
	"arrow_head": {"kind": "atk", "n": 6},
	"danger_magnet": {"kind": "magnet", "options": [
		{"id": "high", "label": "Highest Attack"},
		{"id": "low", "label": "Lowest Attack"},
		{"id": "off", "label": "Off"},
	]},
	"shuriken": {"kind": "atk_move", "n": 3},
	"miasma": {"kind": "miasma"},
	"bag_of_marbles": {"kind": "bag_marbles"},
	"marble": {"kind": "marble"},
	"hex": {"kind": "hex"},
	"ale_flagon": {"kind": "heal_both_draw", "heal": 3},
	"fairy_in_a_bottle": {"kind": "heal", "n": 2},
	"napalm": {"kind": "napalm"},
	"lucky_nickel": {"kind": "blk_coin_keep", "lo": 2, "hi": 6, "hp": 2},
	"double_buckler": {"kind": "blk_half_atk"},
	"blood_pact": {"kind": "blood_pact", "n": 2},
	"jar_o_grease": {"kind": "move2_keep", "n": 2},
	"toll": {"kind": "toll"},
	"chakram": {"kind": "chakram", "blk": 3, "atk": 3},
	"signpost": {"kind": "signpost", "n": 7},
	"sling": {"kind": "sling"},
	"ball_and_chain": {"kind": "atk", "n": 2},
	"energy_drink": {"kind": "player_flee_keep"},
	"recycler": {"kind": "recycle_watch"},
	"rust": {"kind": "rust_watch"},
}

const MONSTER_SPECIAL := {
	"goblin": {"id": "no_atk_dmg", "text": "Cannot receive ATK damage. Defeat still works."},
	"skeleton": {"id": "last_hp", "text": "HP = last enemy's HP when you spun them. First fight: 3."},
	"hornet_swarm": {"id": "double_hit", "text": "Attacks twice. Block is spent on the first swing."},
	"lich": {"id": "undying", "text": "Defeat items chip 1 HP and are Kept. Nothing else lowers HP."},
	"ogre": {"id": "hp_spin", "text": "When you lose HP, I lose equal HP."},
	"berserker": {"id": "kill_scale", "text": "On Spin, 50%: gain +4 Attack. Otherwise: lose 3 Attack."},
	"dire_wolf": {"id": "atk_spin", "text": "ATK always equals your HP. Updates whenever your HP changes."},
	"bandit": {"id": "item_atk", "text": "I Gain +1 Atk for each Item you hold."},
	"two_headed_serpent": {"id": "two_items", "text": "My Neighbors will attack you (Left, then Right), then I will Heal you for 3 HP."},
	"slime_boss": {"id": "atk_eq_hp", "text": "ATK always equals current HP."},
	"leech_league": {"id": "leech_lowest", "text": "On Spin, repeatedly Heals the Lowest HP Monster until it equals the HP of another Monster."},
	"wraith": {"id": "lifelink", "text": "When I am Defeated, set your HP to my most recent HP."},
	"mimic": {"id": "gift", "text": "If I go down before I swing, you gain an item."},
	"spider_queen": {"id": "queen_hits", "text": "Each time you Spin, Gain 1 Spider Egg. Spinning me discards those eggs; I gain +2 HP and +2 Attack for each."},
	"commander": {"id": "buff_atk", "text": "I give my Neighbors +2 Attack. The first time I am Defeated, I Flee and the wheel Spins at random."},
	"dragon": {"id": "pierce", "text": "My attack ignores block."},
	"needleback": {"id": "thorns", "text": "Whenever I take attack damage, you take 2 attack. Block can stop that 2."},
	"gelatinous_cube": {"id": "eat_item", "text": "When you Spin me, feed me one of two items."},
	"gargoyle": {"id": "petrify", "text": "I petrify your highest Attack item until the next Spin."},
	"harpy": {"id": "interrupt", "text": "I attack you when you Spin me, and after each item you use when facing me."},
	"kobold_trapper": {"id": "hunter_mark", "text": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK"},
	"clockwork_knight": {"id": "synchronize", "text": "When I am Defeated, my Neighbors gain HP until they are equal, and then gain Attack until they are equal."},
	"basilisk": {"id": "petrify_gaze", "text": "The first time you Spin me, I Flee and Petrify every other Item for 3 Spins."},
	"zombie": {"id": "decay", "text": "When you Spin me, I Decay two of your Items."},
	"hollow": {"id": "even_twice", "text": "Even Attack and even Block happen twice against me."},
	"beggar": {"id": "finders_keepers", "text": "While I am in the Dungeon I will Always select a random Item. That Item is Discarded when you Spin me"},
	"wick": {"id": "last_hp", "text": "I Lose 2 HP each time a Neighbor is Defeated"},
	"anvil": {"id": "one_chip", "text": "I cannot lose more than 1 HP from one source."},
	"vampire": {"id": "bloodlust", "text": "Every time you lose HP, I gain +1 HP and +1 Attack."},
	"bodyguard": {"id": "take_instead", "text": "When my Neighbors would take Attack Damage, I take it instead."},
	"cowardly_king": {"id": "vindictive", "text": "Any time I lose HP, I command the monster to my right to Attack you immediately"},
	"merchant": {"id": "fair_trade", "text": "When you Spin me, choose an Item and I will upgrade it."},
	"juggernaut": {"id": "gift_shield", "text": "When you face me, Gain a Shield."},
	"cleric": {"id": "insure", "text": "After you Spin, if you are missing at least 3 HP I will Heal you for 3 and take your worst Item"},
	"martyr": {"id": "noble_death", "text": "When I lose HP or Attack, I die. Neighbors gain my remaining HP."},
	"prism": {"id": "refract", "text": "Attack at me hits both neighbors instead."},
	"plague_doctor": {"id": "time_bomb", "text": "On each Spin, I give all You and all Monsters 1 Poison."},
	"hired_hand": {"id": "bribe", "text": "Discard an item: I Attack a Neighbor and Flee."},
	"hydra": {"id": "even_killer", "text": "I Petrify all Items with an Even Atk or Blk value and Gain +2 Atk for each"},
	"three_seeker": {"id": "triple_threat", "text": "If you have 3, 6, or 9 Items, you Always Spin me next"},
	"triclops": {"id": "three_hp", "text": "If I have 3 HP, I am Defeated. If I would be Defeated in any other way, I instead lose 2 HP and Flee."},
	"phoenix_egg": {"id": "hatch", "text": "When I am Defeated, I Flee and hatch into a Phoenix."},
	"phoenix": {"id": "rebirth", "text": "If I am Defeated before I Attack, add a Phoenix Egg to the Dungeon Deck."},
	"amalgam": {"id": "adaptation", "text": "After any Item you Use, double my remaining HP and ATK."},
	"fairy": {"id": "buff_hp", "text": "I give my Neighbors +1 HP."},
	"eel": {"id": "conductive", "text": "When facing me, I take Attack damage equal to Block you gain."},
	"druid": {"id": "cultivator", "text": "If I Attack, I Heal you for double the HP I cause you to lose."},
	"shambling_mound": {"id": "self_deconstruct", "text": "I Attack repeatedly until I die. I lose 1 HP each time I Attack."},
	"almighty_worm": {"id": "hunger_pains", "text": "When you Spin me, you may Discard Items. Each sacrifice reduces my Atk and HP by 3."},
	"cultist": {"id": "blood_pact", "text": "When you Spin me or my Neighbor, Gain 1 Blood Pact"},
	"bushido": {"id": "dance_swap", "text": "After each Item you use while facing me, swap my HP and Attack."},
	"shark": {"id": "blood_thresh", "text": "I Attack until you lose HP"},
	"death_bell": {"id": "toll_dead", "text": "When I Spawn, Gain 1 Toll. On Spin, I lose 2 HP. When I am Defeated, Discard 1 Item."},
	"mouse": {"id": "scurry", "text": "When you Spin me, if you have more HP than me I lose 2 HP and Flee"},
	"magicat": {"id": "cats_eye", "text": "When you Spin me, I turn two of your Atk or Blk Items into a Marble with the same value"},
	"scorpion": {"id": "venom_sac", "text": "When you Spin me, I transform a random Attack or Block Item into a Poison Flask of equal value"},
	"poison_frog": {"id": "toxic_skin", "text": "When you Spin me and when I take Atk damage from any source, you Gain 2 Poison"},
	"rust_bucket": {"id": "rust", "text": "When I enter the Dungeon, Gain 1 Rust"},
	"fungal_colony": {"id": "cordyceps", "text": "When I deal any Atk damage to you, I replace the weakest monster in the dungeon with a Copy of myself, then I Flee."},
	"sandbag": {"id": "sandbag", "text": "When you Spin me, if my Attack would kill you, I Flee and lose 1 Attack"},
	"oligarch": {"id": "wealth_tax", "text": "When I enter the Dungeon, Gain 2 Items. Whenever you Spin, I force you to use a random Item"},
}

const MONSTER_CALL := {
	"wizard": "Spellbook",
	"golem": "Stone Fists",
	"goblin": "No Attack",
	"skeleton": "Grave Echo",
	"hornet_swarm": "Twice",
	"lich": "Undying",
	"ogre": "Your Measure",
	"berserker": "Hot and Cold",
	"dire_wolf": "Kill Shot",
	"bandit": "Cutpurse",
	"two_headed_serpent": "Guarded by Monsters",
	"slime_boss": "One Flesh",
	"leech_league": "Lowest HP",
	"wraith": "Lifelink",
	"mimic": "False Gift",
	"spider_queen": "Egg Layer",
	"commander": "War Cry",
	"dragon": "True Fire",
	"needleback": "Quills",
	"gelatinous_cube": "Devour",
	"gargoyle": "Petrify",
	"harpy": "Interrupt",
	"kobold_trapper": "Hunter's Mark",
	"clockwork_knight": "Synchronize",
	"basilisk": "Petrifying Gaze",
	"zombie": "Decay",
	"hollow": "Even twice",
	"beggar": "Finders Keepers",
	"wick": "Death Toll",
	"anvil": "One HP",
	"cowardly_king": "Vindictive",
	"hydra": "Even Killer",
	"three_seeker": "Triple Threat",
	"phoenix_egg": "Hatch",
	"phoenix": "Rebirth",
	"amalgam": "Adaptation",
	"fairy": "Fairy Dust",
	"eel": "Conductive",
	"druid": "Cultivator",
	"shambling_mound": "Self Deconstruct",
	"almighty_worm": "Hunger Pains",
	"cultist": "Blood Pact",
	"bushido": "Dance Swap",
	"shark": "Blood Thresh",
	"death_bell": "Toll Of The Dead",
	"mouse": "Scurry",
	"magicat": "Cat's Eye",
	"poison_frog": "Toxic Skin",
	"plague_doctor": "Outbreak",
	"rust_bucket": "Rust",
	"oligarch": "Wealth Tax",
}

const MONSTER_REMINDER := {
	"wizard": "plain ATK/HP owner",
	"golem": "plain ATK/HP owner",
	"goblin": "no attack damage",
	"skeleton": "last enemy HP",
	"hornet_swarm": "attacks twice",
	"lich": "Defeat chips 1. No other HP loss.",
	"ogre": "HP is yours",
	"berserker": "50% +4 Attack, otherwise lose 3 Attack",
	"dire_wolf": "Attack always equals your HP",
	"bandit": "attack is items",
	"two_headed_serpent": "Neighbors attack, then Heal 3",
	"slime_boss": "attack equals HP",
	"leech_league": "Lowest HP Monster +1 until tied with another",
	"wraith": "Defeated: set your HP to my most recent HP",
	"mimic": "item if I never swing",
	"spider_queen": "Egg on Spin. Spinning me eats eggs for +2 HP +2 Attack each.",
	"commander": "neighbors +2 attack",
	"dragon": "ignores block",
	"needleback": "poke 2 when hit by ATK",
	"gelatinous_cube": "feed me one of two items",
	"gargoyle": "petrifies highest Attack item",
	"harpy": "attacks when you Spin her, and after items while facing her",
	"kobold_trapper": "Marked Defeat: +2 HP and ATK",
	"clockwork_knight": "Defeated: neighbors match HP, then Attack",
	"basilisk": "first Spin: Flee, petrify 2nd, 4th, … for 3",
	"zombie": "Decayed Items are linked. When you use one, Keep it and discard the other.",
	"hollow": "even Attack or Block twice",
	"beggar": "Marks a random item. Spin this Beggar: that item is discarded.",
	"wick": "-2 HP per Neighbor Defeated.",
	"anvil": "max 1 HP per source",
	"cowardly_king": "when I lose HP, the monster on my right Attacks you",
	"three_seeker": "3, 6, or 9 items: Always Spin me next",
	"triclops": "3 HP: Defeated. Else Defeat: −2 HP and Flee",
	"phoenix_egg": "Defeated: Flee, become Phoenix",
	"phoenix": "Defeated before I Attack: add a Phoenix Egg to the Dungeon Deck",
	"amalgam": "Each Use: remaining HP and ATK ×2",
	"fairy": "Neighbors +1 HP",
	"eel": "Facing: takes Attack = Block you Gain",
	"druid": "Attack: Heal you 2× HP lost, after death check",
	"shambling_mound": "Attacks until it dies; loses 1 HP per Attack",
	"almighty_worm": "Discard items: I lose 3 Attack and 3 HP each",
	"cultist": "Spin me or my neighbor: Gain Blood Pact",
	"bushido": "After each item: swap HP and Attack",
	"shark": "Attacks until you lose HP",
	"death_bell": "Spawn Toll. Spin −2 HP. Defeat: Discard 1 Item.",
	"mouse": "On Spin: if your HP is higher, I lose 2 HP and Flee",
	"magicat": "On Spin: 2 Atk or Blk Items become Marbles with that number",
	"poison_frog": "On Spin and when I take Attack damage: you Gain 2 Poison",
	"plague_doctor": "Each Spin: you and every monster Gain 1 Poison",
	"rust_bucket": "When I enter the Dungeon, Gain 1 Rust",
	"oligarch": "On entry: Gain 2 Items. After each Spin's choices: one playable Item is used",
}

const MONSTER_SPEECH := {
	"wizard": "My spellbook was in that pile.",
	"golem": "My stone fists want that back.",
	"goblin": "I cannot take attack damage.",
	"skeleton": "I copy the HP of the last enemy you faced.",
	"hornet_swarm": "I attack twice. Your block is spent on each swing.",
	"lich": "When you use Defeat Items against me, they fail, reduce my HP by 1, and are Kept. I cannot lose HP in any other way.",
	"ogre": "My HP is your HP.",
	"berserker": "On Spin, 50%: gain +4 Attack. Otherwise: lose 3 Attack.",
	"dire_wolf": "My Attack always equals your HP.",
	"bandit": "I Gain +1 Atk for each Item you hold.",
	"two_headed_serpent": "My Neighbors will attack you (Left, then Right), then I will Heal you for 3 HP.",
	"slime_boss": "My attack always equals my HP.",
	"leech_league": "On Spin, repeatedly Heals the Lowest HP Monster until it equals the HP of another Monster.",
	"wraith": "When I am Defeated, set your HP to my most recent HP.",
	"mimic": "If I go down before I attack, you gain an item.",
	"spider_queen": "Each time you Spin, Gain 1 Spider Egg. Spinning me discards those eggs; I gain +2 HP and +2 Attack for each.",
	"commander": "I give my Neighbors +2 Attack. The first time I am Defeated, I Flee and the wheel Spins at random.",
	"dragon": "My attack ignores block.",
	"needleback": "I stick you for 2 attack whenever you cut me. Your block still works.",
	"gelatinous_cube": "When you Spin me, feed me one of two items.",
	"gargoyle": "I petrify your highest Attack item until you Spin again.",
	"harpy": "I attack you when you Spin me, and after each item you use when facing me.",
	"kobold_trapper": "When I enter the Dungeon I Mark 2 other Monsters. Each time a Marked monster is Defeated, I gain +2 HP and ATK",
	"clockwork_knight": "When I am Defeated, my Neighbors gain HP until they are equal, and then gain Attack until they are equal.",
	"basilisk": "The first time you Spin me, I Flee and Petrify every other Item for 3 Spins.",
	"zombie": "When you Spin me, I Decay two of your Items.",
	"hollow": "Even Attack and even Block happen twice against me.",
	"beggar": "While I am in the Dungeon I will Always select a random Item. That Item is Discarded when you Spin me",
	"wick": "I Lose 2 HP each time a Neighbor is Defeated",
	"anvil": "I cannot lose more than 1 HP from one source.",
	"cowardly_king": "Any time I lose HP, I command the monster to my right to Attack you immediately",
	"three_seeker": "If you have 3, 6, or 9 Items, you Always Spin me next",
	"triclops": "If I have 3 HP, I am Defeated. If I would be Defeated in any other way, I instead lose 2 HP and Flee.",
	"phoenix_egg": "When I am Defeated, I Flee and hatch into a Phoenix.",
	"phoenix": "If I am Defeated before I Attack, add a Phoenix Egg to the Dungeon Deck.",
	"amalgam": "After any Item you Use, double my remaining HP and ATK.",
	"fairy": "I give my Neighbors +1 HP.",
	"eel": "When facing me, I take Attack damage equal to Block you gain.",
	"druid": "If I Attack, I Heal you for double the HP I cause you to lose.",
	"shambling_mound": "I Attack repeatedly until I die. I lose 1 HP each time I Attack.",
	"almighty_worm": "When you Spin me, you may Discard Items. Each sacrifice reduces my Atk and HP by 3.",
	"cultist": "When you Spin me or my Neighbor, Gain 1 Blood Pact",
	"bushido": "After each Item you use while facing me, swap my HP and Attack.",
	"shark": "I Attack until you lose HP",
	"death_bell": "When I Spawn, Gain 1 Toll. On Spin, I lose 2 HP. When I am Defeated, Discard 1 Item.",
	"mouse": "When you Spin me, if you have more HP than me I lose 2 HP and Flee",
	"magicat": "When you Spin me, I turn two of your Atk or Blk Items into a Marble with the same value",
	"poison_frog": "When you Spin me and when I take Atk damage from any source, you Gain 2 Poison",
	"plague_doctor": "On each Spin, I give all You and all Monsters 1 Poison.",
	"rust_bucket": "When I enter the Dungeon, Gain 1 Rust",
	"oligarch": "When I enter the Dungeon, Gain 2 Items. Whenever you Spin, I force you to use a random Item",
}

var catalog: Dictionary = {}
var runtime: Dictionary = {}
var monsters_by_id: Dictionary = {}
var items_by_id: Dictionary = {}
var monster_pool: Array = []
var item_pool: Array = []
var _rug_secret_in_run: bool = false

var hp: int = HP_MAX
var player_poison: int = 0
var _flushing_poison_sides: bool = false
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
var last_hp_lost: int = 0
var _stone_saved: int = 0
var _stone_armed: bool = false
var _saucer_blk_due: int = 0
var last_item_copy: Dictionary = {}
var silenced: Dictionary = {}
var session_log = SESSION_LOG.new()
var pending_feed: Dictionary = {}
var _bell_wait: bool = false
var _toll_death_armed: bool = false
var skip_swing_this_fight: bool = false
var keep_blocked_this_fight: bool = false
var _lich_chip_open: bool = false
var _decay_busy: bool = false
var _beggar_hold: bool = false
var _beggar_intro_running: bool = false
var _beggar_fill_running: bool = false
var _wick_collapsing: bool = false
var _share_seq: int = 0
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
var tex_atk: Texture2D
var tex_shield: Texture2D
var tex_rotate: Texture2D
var tex_plus: Texture2D
var tex_by_monster: Dictionary = {}
var tex_by_item: Dictionary = {}
var tex_special: Dictionary = {}
var art
var dungeon_bg
var combat_stage
var player_stage
## hub, leaving, entering, stage, returning, hub_in
var _sprout_mode: String = "hub"
var _sprout_tw: Tween
var _sprout_home_x: float = 80.0
var _fight_art_sig: String = ""
## Set while spin defers full gutter layout, or when a same-frame place is coalesced.
var _fight_art_dirty: bool = false
## Process-frame id of the last full `_place_fight_art` (stops resized cascades).
var _fight_art_frame: int = -1
## One deferred flush queued for `_fight_art_dirty` (not a per-frame poll).
var _fight_art_flush_queued: bool = false
## Bumped when face plate content changes; full place skips reset_size when equal.
var _face_plate_rev: int = 0
## Last plate content key — avoid bumping rev / blanking gutter sig on no-op refresh.
var _face_plate_content_sig: String = ""
var _fight_art_plaque_rev: int = -1
var _fight_art_plaque_h: float = 0.0
## Last applied combat_stage rect — skip `_place_sprite` when unchanged.
var _fight_art_stage_pos: Vector2 = Vector2.INF
var _fight_art_stage_sz: Vector2 = Vector2.ZERO
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
var _watch_portrait: int = -1
var speech_box
var ability_fx
var ability_slash
var intent_plate
var bleed_pulse
var cascade_ticker
var poison_pop
var hook_fx
var _cascade_ff: bool = false
var _phase_for_ff: String = ""
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
var hub_cue
var _draft_final_item: bool = false
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
var logic_qa
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
var _take_burst: Control
var _take_style_base: Dictionary = {}
var _take_style_had: Dictionary = {}
var _take_style_ready: bool = false
var btn_place: Button
var btn_bribe: Button
var _fly_card: Control
var _ghost_hp: int = -1
var _hover_preview_tw: Tween
var _hover_ghost_on: bool = false
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
var _screen_shake: Tween
var _shake_base: Vector2 = Vector2.ZERO
var _shaking: bool = false
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
var _tut_bandit_seated: bool = false
var _tut_show_deck: bool = false
var _tut_draft_busy: bool = false
var _tut_finisher_armed: bool = false
var _tut_hold_slay: bool = false
var _tut_moves_on: bool = false
var _tut_face_busy: bool = false
var _tut_inspected_tag: String = ""
var _upgraded_slices: Array = []
var _tut_boot: bool = false
var draft_gate
var _courier: TextureRect
var _courier_gear: Dictionary = {}
var _walker_busy: bool = false
var _hold_holes: int = 0
var _item_hold: bool = false
var _vindictive_queue: Array = []
var _vindictive_flushing: bool = false
var _flushing_holes: bool = false
var _spin_after_holes: bool = false
var _death_seq: int = 0
var _death_batch: int = 0
var _simul_depth: int = 0
var _hole_serial: int = 0
var _hero_swipe_armed: bool = false
var _sling_aim: int = -1
var _skip_item_use_count: bool = false
var _flee_random_spin: bool = false
var _pending_item_flee: bool = false
var _chakram_halves_busy: bool = false
var _fungal_stop_fight: bool = false
var _drink_hp_due: bool = false
var _gate_line: String = ""
var _cube_line: String = ""
var _speech_from_index: int = -1
var _cleric_line: String = ""
var _cleric_talk_index: int = -1
var _berserk_line: String = ""
var _berserk_talk_index: int = -1
var _mill_seq: int = 0
var _mill_beat: String = ""
var refusals_left: int = REFUSALS_MAX
var _copy_stamp
var adventure: bool = false
## True only for archived Long Drop (click-to-pick spin, rope, more dungeons).
var challenge_route: bool = false
var _campaign = null
var campaign_map = null
var _campaign_on: bool = false
var _campaign_queue: Array = []
var _campaign_starter_left: Array = []
var _campaign_exclude: Array = []
var _campaign_telegraph: Array = []
## Play Latest asks for the live mode, then the next draws prefer recent cards.
var _latest_rig_request: bool = false
var _latest_rig: bool = false
var _latest_monster_ids: PackedStringArray = PackedStringArray()
var _latest_item_ids: PackedStringArray = PackedStringArray()
var _latest_monster_q: Array = []
var _latest_item_q: Array = []
var dungeon_index: int = 1
var dungeons_cleared: int = 0
var moves_left: int = 0
var _move_busy: bool = false
var _howto_move_shown: bool = false
var move_box: Control
var move_count: Label
var btn_move_left: Button
var btn_move_right: Button
var adventure_seat_tiers: Array = [1, 1, 1, 1, 1, 1]
var _adventure_busy: bool = false
var dungeon_deck_ui
var challenge_draft_ui
var btn_challenge_begin: Button
var hotbar_wrap: MarginContainer
var btn_wrap: MarginContainer
var hotbar_panel: PanelContainer
var hotbar_overflow: Control
var challenge_deck: Array = []
var challenge_aim: int = -1
var _unspin_armed: bool = false
var challenge_armed: bool = false
var challenge_draft_plan: Array = []
var challenge_pick_i: int = 0
var _challenge_force_spin: bool = false
var _await_first_spin: bool = false
var _challenge_pending_gain: Dictionary = {}
var _challenge_loot_wait: bool = false
var _loot_epoch: int = 0
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
var playtest_hub
var playtest_feedback
var playtest_tier
var playtest_inbox
var playtest_intro
var playtest_teaser
var playtest_fab: Button
var playtest_voice: Label
var _playtest_preset: String = ""
var _playtest_boot: bool = false


func _attach_dev_branch_tag() -> void:
	# scripts/dev is left out of the web export. A preload here stops the game from starting.
	if not OS.has_feature("editor"):
		return
	if not ResourceLoader.exists("res://scripts/dev/branch_tag.gd"):
		return
	var scr := load("res://scripts/dev/branch_tag.gd") as GDScript
	if scr != null:
		scr.call("attach", self)


func _ready() -> void:
	BUILD_STAMP.attach(self)
	if PLAYTEST_FLAG.on():
		FRAME_METRICS.attach(self)
	_attach_dev_branch_tag()
	if not SHOT_CLI.enabled(OS.get_cmdline_user_args()):
		SHOT_CLI.recover_if_marked()
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
	_load_playtest_preset()
	var covering_ids := _covering_cli_ids()
	var scenario_ids := _scenarios_cli_ids()
	if PLAYTEST_FLAG.on() and not SHOT_CLI.enabled(OS.get_cmdline_user_args()) and covering_ids == "" and scenario_ids == "":
		_playtest_boot = true
	_refresh()
	if sfx and (home_cabin == null or not home_cabin.visible):
		sfx.start_music()
	if covering_ids != "" and logic_qa != null:
		call_deferred("_kick_covering", covering_ids)
	elif scenario_ids != "" and logic_qa != null:
		call_deferred("_kick_scenarios", scenario_ids)
	elif SHOT_CLI.enabled(OS.get_cmdline_user_args()) and shot_harness:
		call_deferred("_kick_shots")
	elif PLAYTEST_FLAG.on():
		call_deferred("_open_playtest_hub")


func _covering_cli_ids() -> String:
	for arg in OS.get_cmdline_user_args():
		var text := str(arg)
		if text.begins_with("--covering="):
			return text.substr(11).strip_edges()
	return ""


func _scenarios_cli_ids() -> String:
	for arg in OS.get_cmdline_user_args():
		var text := str(arg)
		if text == "--scenarios":
			return "*"
		if text.begins_with("--scenarios="):
			var raw := text.substr(12).strip_edges()
			return "*" if raw == "" else raw
	return ""


func _kick_scenarios(ids: String) -> void:
	if logic_qa == null:
		get_tree().quit(2)
		return
	var started: String = logic_qa.run_scenarios("" if ids == "*" else ids)
	print("SCENARIOS: ", started)
	if not started.begins_with("started"):
		get_tree().quit(2)
		return
	while logic_qa != null and bool(logic_qa.busy):
		await get_tree().process_frame
	print("SCENARIOS: ", logic_qa.dump_json() if logic_qa else "{}")
	get_tree().quit(0 if logic_qa != null and str(logic_qa.last_error) == "" else 1)


func _kick_covering(ids: String) -> void:
	if logic_qa == null:
		get_tree().quit(2)
		return
	var started: String = logic_qa.run_covering(ids)
	print("COVERING: ", started)
	if not started.begins_with("started"):
		get_tree().quit(2)
		return
	while logic_qa != null and bool(logic_qa.busy):
		await get_tree().process_frame
	print("COVERING: ", logic_qa.dump_json() if logic_qa else "{}")
	get_tree().quit(0 if logic_qa != null and str(logic_qa.last_error) == "" else 1)


func _kick_shots() -> void:
	if shot_harness == null:
		get_tree().quit(2)
		return
	var args := OS.get_cmdline_user_args()
	shot_harness.begin_shots(SHOT_CLI.list_raw(args), SHOT_CLI.out_dir(args), true)


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _authoring() -> bool:
	return DevFlag.on() or SHOT_CLI.enabled(OS.get_cmdline_user_args()) or _covering_cli_ids() != "" or _scenarios_cli_ids() != ""


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
	tex_atk = _tex("res://assets/ui/icons/atk_burst.png")
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
		"basilisk": _tex("res://assets/icons/mountain.svg"),
		"zombie": _tex("res://assets/icons/ban.svg"),
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
		"hydra": _tex("res://assets/icons/users.svg"),
		"three_seeker": _tex("res://assets/icons/users.svg"),
		"triclops": _tex("res://assets/icons/users.svg"),
		"phoenix_egg": _tex("res://assets/icons/sparkles.svg"),
		"phoenix": _tex("res://assets/icons/sparkles.svg"),
		"amalgam": _tex("res://assets/icons/rotate.svg"),
		"fairy": _tex("res://assets/icons/heart.svg"),
		"eel": _tex("res://assets/icons/link.svg"),
		"druid": _tex("res://assets/icons/heart.svg"),
		"shambling_mound": _tex("res://assets/icons/swords.svg"),
		"almighty_worm": _tex("res://assets/icons/layers.svg"),
		"cultist": _tex("res://assets/icons/droplet.svg"),
		"bushido": _tex("res://assets/icons/rotate.svg"),
		"shark": _tex("res://assets/icons/swords.svg"),
		"mouse": _tex("res://assets/icons/footprints.svg"),
		"magicat": _tex("res://assets/icons/sparkles.svg"),
		"poison_frog": _tex("res://assets/icons/droplet.svg"),
		"rust_bucket": _tex("res://assets/icons/ban.svg"),
		"sandbag": _tex("res://assets/icons/footprints.svg"),
		"oligarch": _tex("res://assets/icons/layers.svg"),
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
		"napalm": _tex("res://assets/icons/sparkles.svg"),
		"lucky_nickel": _tex("res://assets/icons/sparkles.svg"),
		"double_buckler": tex_shield,
		"blood_pact": _tex("res://assets/icons/droplet.svg"),
		"jar_o_grease": _tex("res://assets/icons/sparkles.svg"),
		"toll": _tex("res://assets/icons/skull.svg"),
		"pacemaker": _tex("res://assets/icons/heart.svg"),
		"catapult": _tex("res://assets/icons/footprints.svg"),
		"polymorph": _tex("res://assets/icons/rotate.svg"),
		"stone_wall": tex_shield,
		"blood_chalice": _tex("res://assets/icons/droplet.svg"),
		"chakram": _tex("res://assets/icons/swords.svg"),
		"signpost": tex_shield,
		"sling": _tex("res://assets/icons/swords.svg"),
	}
	tex_special = {
		"no_atk_dmg": _tex("res://assets/icons/ban.svg"),
		"last_hp": _tex("res://assets/icons/copy.svg"),
		"double_hit": _tex("res://assets/icons/swords.svg"),
		"buff_hp": _tex("res://assets/icons/users.svg"),
		"undying": _tex("res://assets/icons/ban.svg"),
		"hp_spin": tex_heart,
		"kill_scale": _tex("res://assets/icons/trending.svg"),
		"atk_spin": tex_sword,
		"item_atk": _tex("res://assets/icons/layers.svg"),
		"two_items": _tex("res://assets/icons/sparkles.svg"),
		"atk_eq_hp": _tex("res://assets/icons/link.svg"),
		"pack_hp": _tex("res://assets/icons/users.svg"),
		"leech_lowest": tex_heart,
		"copy_atk": _tex("res://assets/icons/copy.svg"),
		"lifelink": _tex("res://assets/icons/heart.svg"),
		"gift": _tex("res://assets/icons/layers.svg"),
		"queen_hits": _tex("res://assets/icons/plus.svg"),
		"buff_atk": _tex("res://assets/icons/trending.svg"),
		"pierce": _tex("res://assets/icons/ban.svg"),
		"thorns": _tex("res://assets/icons/link.svg"),
		"eat_item": _tex("res://assets/icons/layers.svg"),
		"petrify": _tex("res://assets/icons/mountain.svg"),
		"petrify_gaze": _tex("res://assets/icons/mountain.svg"),
		"interrupt": _tex("res://assets/icons/sparkles.svg"),
		"item_swings": _tex("res://assets/icons/footprints.svg"),
		"split_t2": _tex("res://assets/icons/rotate.svg"),
		"synchronize": _tex("res://assets/icons/rotate.svg"),
		"no_keep": _tex("res://assets/icons/ban.svg"),
		"decay": _tex("res://assets/icons/link.svg"),
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
		"even_killer": _tex("res://assets/icons/mountain.svg"),
		"triple_threat": _tex("res://assets/icons/users.svg"),
		"self_deconstruct": _tex("res://assets/icons/swords.svg"),
		"hunger_pains": _tex("res://assets/icons/layers.svg"),
		"blood_pact": _tex("res://assets/icons/droplet.svg"),
		"dance_swap": _tex("res://assets/icons/rotate.svg"),
		"blood_thresh": _tex("res://assets/icons/swords.svg"),
		"toll_dead": _tex("res://assets/icons/skull.svg"),
		"no_defeat": _tex("res://assets/icons/ban.svg"),
		"atk_eq_blk": _tex("res://assets/icons/link.svg"),
		"item_double": _tex("res://assets/icons/swords.svg"),
		"pack_atk": _tex("res://assets/icons/users.svg"),
		"three_hp": _tex("res://assets/icons/heart.svg"),
		"hatch": _tex("res://assets/icons/sparkles.svg"),
		"rebirth": _tex("res://assets/icons/sparkles.svg"),
		"adaptation": _tex("res://assets/icons/rotate.svg"),
		"fairy_dust": _tex("res://assets/icons/heart.svg"),
		"fairy_bottle": _tex("res://assets/icons/heart.svg"),
		"cats_eye": _tex("res://assets/icons/sparkles.svg"),
		"toxic_skin": _tex("res://assets/icons/droplet.svg"),
		"rust": _tex("res://assets/icons/ban.svg"),
		"conductive": _tex("res://assets/icons/link.svg"),
		"cultivator": _tex("res://assets/icons/heart.svg"),
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
	hearts_box.visible = false
	hearts_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		if wheel_view.has_method("set_wheel_frames") and art.has_method("wheel_frames_all"):
			wheel_view.set_wheel_frames(art.wheel_frames_all())
		if wheel_view.has_method("setup_run_hero"):
			wheel_view.setup_run_hero(art)
		else:
			wheel_view.set_player(art.frames("knight_m"))
		if wheel_view.has_signal("death_floor"):
			wheel_view.death_floor.connect(_on_hero_death_floor)
		if wheel_view.has_signal("stat_style_changed"):
			wheel_view.stat_style_changed.connect(_on_stat_style_changed)
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
	_build_move_ui()
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
	btns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btns.add_theme_constant_override("separation", 12)
	btn_wrap.add_child(btns)
	btn_start = _pill("New", Color("2a2622"), Color("6a5f52"), _on_new)
	btn_place = _pill("Place", Color("1a2a1a"), Color("8dcb8d"), _on_place_mode)
	btn_bribe = _pill("Bribe", Color("2a1c14"), Color("d19a66"), _on_bribe_mode)
	btn_spin = _pill(PLAYER_COPY.text("combat.spin", "Spin"), Color("3a3220"), Color("e8c36a"), _on_spin)
	btn_spin.custom_minimum_size = Vector2(228, 56)
	btn_spin.add_theme_font_size_override("font_size", 28)
	btn_spin.add_theme_constant_override("outline_size", 6)
	if tex_rotate != null:
		btn_spin.icon = tex_rotate
	btn_challenge_begin = _pill(PLAYER_COPY.text("challenge.begin", "Begin"), Color("1a2a1a"), Color("8dcb8d"), _challenge_begin_play)
	btn_challenge_begin.custom_minimum_size = Vector2(228, 56)
	btn_challenge_begin.visible = false
	btn_done = _pill("Done", Color("3a2820"), Color("d19a66"), _on_done)
	btn_done.custom_minimum_size = Vector2(228, 56)
	btn_done.add_theme_font_size_override("font_size", 28)
	btn_done.add_theme_constant_override("outline_size", 6)
	btn_undo = _pill("Undo", Color("1c2428"), Color("6bb3d9"), _on_undo)
	btn_redo = _pill("Redo", Color("24201c"), Color("c4a574"), _on_redo)
	var left_slot := HBoxContainer.new()
	left_slot.alignment = BoxContainer.ALIGNMENT_END
	left_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_slot.add_theme_constant_override("separation", 12)
	var mid_slot := HBoxContainer.new()
	mid_slot.alignment = BoxContainer.ALIGNMENT_CENTER
	mid_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mid_slot.add_theme_constant_override("separation", 12)
	var right_slot := HBoxContainer.new()
	right_slot.alignment = BoxContainer.ALIGNMENT_BEGIN
	right_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_slot.add_theme_constant_override("separation", 12)
	btns.add_child(left_slot)
	btns.add_child(mid_slot)
	btns.add_child(right_slot)
	left_slot.add_child(btn_undo)
	mid_slot.add_child(btn_start)
	mid_slot.add_child(btn_place)
	mid_slot.add_child(btn_bribe)
	mid_slot.add_child(btn_spin)
	mid_slot.add_child(btn_challenge_begin)
	mid_slot.add_child(btn_done)
	right_slot.add_child(btn_redo)
	btn_spin.mouse_entered.connect(_on_spin_hover.bind(true))
	btn_spin.mouse_exited.connect(_on_spin_hover.bind(false))
	btn_place.mouse_entered.connect(_on_place_hover.bind(true))
	btn_place.mouse_exited.connect(_on_place_hover.bind(false))
	btn_done.mouse_entered.connect(_on_done_hover.bind(true))
	btn_done.mouse_exited.connect(_on_done_hover.bind(false))
	btn_done.button_down.connect(_on_done_press.bind(true))
	btn_done.button_up.connect(_on_done_press.bind(false))

	choice_box = HBoxContainer.new()
	choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_box.add_theme_constant_override("separation", 10)
	choice_box.z_index = 16
	left.add_child(choice_box)

	hotbar_wrap = MarginContainer.new()
	hotbar_wrap.add_theme_constant_override("margin_top", 2)
	hotbar_wrap.add_theme_constant_override("margin_bottom", 2)
	hotbar_wrap.z_index = 16
	hotbar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hotbar_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(hotbar_wrap)
	var hot_align := HBoxContainer.new()
	hot_align.alignment = BoxContainer.ALIGNMENT_CENTER
	hot_align.add_theme_constant_override("separation", 0)
	hotbar_wrap.clip_contents = false
	hotbar_wrap.add_child(hot_align)
	hotbar_overflow = Control.new()
	hotbar_overflow.name = "HotbarOverflow"
	hotbar_overflow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotbar_overflow.clip_contents = false
	hotbar_overflow.z_index = 8
	hotbar_overflow.draw.connect(_draw_hotbar_overflow)
	hotbar_wrap.add_child(hotbar_overflow)
	hotbar_panel = PanelContainer.new()
	hotbar_panel.visible = true
	hotbar_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hotbar_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("14100ce8")
	hsb.border_color = Color("c4a574")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(8)
	hsb.content_margin_left = 4
	hsb.content_margin_right = 4
	hsb.content_margin_top = 4
	hsb.content_margin_bottom = 4
	hotbar_panel.add_theme_stylebox_override("panel", hsb)
	hot_align.add_child(hotbar_panel)
	hotbar_box = GridContainer.new()
	hotbar_box.columns = 12
	hotbar_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hotbar_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hotbar_box.add_theme_constant_override("h_separation", 8)
	hotbar_box.add_theme_constant_override("v_separation", 4)
	hotbar_panel.add_child(hotbar_box)

	hub_cue = HUB_CUE_CAPSULE.new()
	hub_cue.name = "HubCueCapsule"
	btn_wrap.add_child(hub_cue)
	if hub_cue.has_signal("finished"):
		hub_cue.finished.connect(_sync_hub_cue)

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
	if _authoring() or PLAYTEST_FLAG.on():
		inspect.edit_pressed.connect(_on_playtest_or_edit)

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
	tut.progress_key.connect(_tut_on_progress_key)
	tut.skipped.connect(_tut_skip)
	tut.finished.connect(_tut_finished)
	tut.branch_ok = _tut_branch_ok

	combat_stage = COMBAT_STAGE.new()
	add_child(combat_stage)
	combat_stage.setup(art)
	combat_stage.z_index = 15
	if _authoring() or PLAYTEST_FLAG.on():
		combat_stage.edit_wanted.connect(_on_monster_right_click)
	player_stage = PLAYER_STAGE.new()
	add_child(player_stage)
	player_stage.setup(art)
	player_stage.z_index = 15

	face_box = HOVER_PANEL.new()
	face_box.visible = false
	face_box.z_index = 14
	face_box.top_level = true
	face_box.accept_clicks = true
	face_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(face_box)
	if art != null:
		face_box.apply_skin(art.ui.get("panel_beige", null))
	if _authoring() or PLAYTEST_FLAG.on():
		face_box.edit_pressed.connect(_on_playtest_or_edit)

	hypno_stage = COMBAT_STAGE.new()
	add_child(hypno_stage)
	hypno_stage.setup(art)
	hypno_stage.face_want = "R"
	hypno_stage.lunge_dir = 1.0
	hypno_stage.z_index = 13
	if _authoring() or PLAYTEST_FLAG.on():
		hypno_stage.edit_wanted.connect(_on_monster_right_click)

	hypno_box = HOVER_PANEL.new()
	hypno_box.visible = false
	hypno_box.z_index = 12
	hypno_box.top_level = true
	hypno_box.accept_clicks = true
	hypno_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hypno_box)
	if art != null:
		hypno_box.apply_skin(art.ui.get("panel_beige", null))
	if _authoring() or PLAYTEST_FLAG.on():
		hypno_box.edit_pressed.connect(_on_playtest_or_edit)

	speech_box = SPEECH_BUBBLE.new()
	add_child(speech_box)
	speech_box.setup()
	ability_fx = ABILITY_FX.new()
	add_child(ability_fx)
	ability_fx.setup()
	ability_slash = ABILITY_SLASH.new()
	add_child(ability_slash)
	ability_slash.setup(art)
	intent_plate = INTENT_PLATE.new()
	add_child(intent_plate)
	intent_plate.setup(self)
	bleed_pulse = BLEED_PULSE.new()
	add_child(bleed_pulse)
	bleed_pulse.setup(self)
	bled.connect(bleed_pulse.on_bled)
	cascade_ticker = CASCADE_TICKER.new()
	add_child(cascade_ticker)
	cascade_ticker.setup()
	ability_slash.cascade_ticker = cascade_ticker
	poison_pop = POISON_POP.new()
	add_child(poison_pop)
	poison_pop.setup(self)
	hook_fx = HOOK_FX.new()
	add_child(hook_fx)
	hook_fx.setup(self)

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
	if sfx.has_method("set_session_log"):
		sfx.set_session_log(session_log)
	_session("scene", "boot")
	ARROW_GLYPHS.ensure()
	settings_ui = SETTINGS_MENU.new()
	add_child(settings_ui)
	settings_ui.setup(sfx)
	settings_ui.mode_picked.connect(_on_pause_mode)
	settings_ui.sparkles_toggled.connect(_on_sparkles_toggled)
	settings_ui.invert_scroll_toggled.connect(_on_invert_scroll_toggled)
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
	home_cabin.held_map_wanted.connect(_toggle_held_map)
	home_cabin.tutorial_wanted.connect(_start_tutorial)
	home_cabin.quit_wanted.connect(_quit_game)
	home_cabin.comment_wanted.connect(func(id: String) -> void: _open_playtest_comment("item", id))
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
	if rope_exit.has_signal("push_home"):
		rope_exit.push_home.connect(_push_interrupt_home)
	_campaign = CAMPAIGN_SHELL.new()
	_campaign.load_all()
	_campaign_seed_next_run_if_needed(false)
	if home_cabin and home_cabin.has_method("bind_campaign"):
		home_cabin.bind_campaign(_campaign)
	campaign_map = CAMPAIGN_MAP.new()
	add_child(campaign_map)
	campaign_map.setup()
	campaign_map.start_asked.connect(_on_campaign_start)
	campaign_map.closed.connect(_close_campaign_map)
	campaign_map.peek_closed.connect(_on_map_peek_closed)
	campaign_map.cheat_asked.connect(_on_campaign_cheat)
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
		var qa_scr: Script = load("res://scripts/dev/logic_qa.gd") as Script
		if qa_scr != null:
			logic_qa = qa_scr.new()
			add_child(logic_qa)
			logic_qa.setup(self)
		var audit_scr: Script = load("res://scripts/dev/text_audit.gd") as Script
		if audit_scr != null:
			text_audit = audit_scr.new()
			add_child(text_audit)
			text_audit.setup(self)
	_build_playtest()
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
	modes.add_child(overlay_home)
	overlay_btn.visible = false
	overlay_adventure.visible = false
	modes.add_child(overlay_btn)
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
	b.add_theme_color_override("font_color", Color("1c120c") if rim.is_equal_approx(Color("e8c36a")) or rim.is_equal_approx(Color("d19a66")) else Color("f0e6d8"))
	b.add_theme_color_override("font_hover_color", Color("100e0c") if rim.is_equal_approx(Color("e8c36a")) or rim.is_equal_approx(Color("d19a66")) else Color("ffffff"))
	b.add_theme_color_override("font_pressed_color", Color("c4a574"))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	b.add_theme_color_override("font_outline_color", Color("100e0c"))
	b.add_theme_constant_override("outline_size", 3)
	b.mouse_entered.connect(func() -> void:
		b.modulate = Color(1.18, 1.16, 1.1)
	)
	b.mouse_exited.connect(func() -> void:
		b.modulate = Color.WHITE
	)
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
	_latest_rig_request = true
	_log("on_click", "Play Latest")
	await _begin_adventure()


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
		await _dev_add_monster(str(id), false)
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
	var sub: String = PLAYER_COPY.tier_name(tier) if tier > 0 else ""
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
	await _maybe_enter_gains(idx)


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
		await _dev_add_monster(str(mons[i % mons.size()]), false)
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


func _is_long_drop() -> bool:
	return adventure and challenge_route


func _is_adventure_mode() -> bool:
	return adventure and not challenge_route


func _click_choose_fight() -> bool:
	## Click-a-monster start is retired. Opening Spin is `_await_first_spin`; later Spins auto-fire.
	return false


func _qa_busy() -> bool:
	return OS.has_feature("editor") and logic_qa != null and bool(logic_qa.busy)


func _reset_moves() -> void:
	moves_left = ADVENTURE_MOVES if _is_adventure_mode() else 0
	_move_busy = false
	_howto_move_shown = false


func _on_new() -> void:
	if phase == "spinning":
		return
	if DevFlags.show_old_gatehouse() and not adventure:
		_begin_run()
	elif _is_long_drop():
		_begin_long_drop()
	else:
		_begin_adventure()


func _on_overlay_primary() -> void:
	if phase == "defeat":
		_go_home_loss()
		return
	if phase == "title":
		if DevFlags.show_old_gatehouse():
			_begin_run()
		else:
			_begin_adventure()
	elif _is_long_drop():
		_begin_long_drop()
	else:
		_begin_adventure()


func _reset_run() -> void:
	_undo_clear()
	_mill_seq += 1
	if ability_slash != null and ability_slash.has_method("reset_slash_seen"):
		ability_slash.reset_slash_seen()
	_rug_secret_in_run = false
	_gate_line = ""
	_cube_line = ""
	_speech_from_index = -1
	_cleric_line = ""
	_cleric_talk_index = -1
	_berserk_line = ""
	_berserk_talk_index = -1
	_mill_beat = ""
	adventure = false
	challenge_route = false
	_campaign_on = false
	_campaign_queue.clear()
	_campaign_starter_left.clear()
	_campaign_exclude.clear()
	_campaign_telegraph.clear()
	_latest_rig = false
	_latest_monster_ids = PackedStringArray()
	_latest_item_ids = PackedStringArray()
	_latest_monster_q = []
	_latest_item_q = []
	moves_left = 0
	_move_busy = false
	_howto_move_shown = false
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	_adventure_busy = false
	challenge_deck.clear()
	challenge_aim = -1
	_unspin_armed = false
	challenge_armed = false
	challenge_draft_plan.clear()
	challenge_pick_i = 0
	_challenge_force_spin = false
	_await_first_spin = false
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
	player_poison = 0
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
	last_hp_lost = 0
	_stone_saved = 0
	_stone_armed = false
	_saucer_blk_due = 0
	last_item_copy = {}
	silenced = {}
	pending_feed = {}
	_bell_wait = false
	_toll_death_armed = false
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
	_pending_item_flee = false
	_drink_hp_due = false
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
	if player_stage:
		player_stage.hide_stage()
	_hide_hypno()
	_fill_pools()
	_empty_wheel()
	if dev_panel:
		dev_panel.visible = false
	_sync_log_panel()


func _begin_run() -> void:
	_hide_cabin_for_run()
	_reset_run()
	_arm_rug_secret_for_run()
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Begin")
	_log("var", "HP %s" % hp)
	_log("on_draft", "The mill")
	_refresh()
	_run_mill()


func _begin_adventure() -> void:
	_open_campaign_map()


func _begin_long_drop() -> void:
	await _begin_six_seat_run(true)


func _begin_six_seat_run(long_drop: bool) -> void:
	_hide_cabin_for_run()
	_reset_run()
	if _latest_rig_request:
		_latest_rig = true
		_latest_rig_request = false
		_latest_monster_ids = RECENT_EDITS.latest_ids("monster", monsters_by_id, items_by_id)
		_latest_item_ids = RECENT_EDITS.latest_ids("item", monsters_by_id, items_by_id)
	_arm_rug_secret_for_run()
	adventure = true
	challenge_route = long_drop
	_reset_moves()
	dungeon_index = 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Challenge Mode" if long_drop else "Adventure Mode")
	_log("var", "HP %s" % hp)
	_log("on_draft", "Dungeon 1")
	_refresh()
	await _reveal_new_buckets()
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	await _run_challenge_setup()
	if not long_drop and draft_action == "challenge_begin":
		_challenge_begin_play()
		await _maybe_auto_spin()


func _drop_dungeon_tokens() -> void:
	var kept: Array = []
	var n := 0
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = items_by_id.get(str(it.get("card_id", "")), {})
		if BucketRules.is_token(card):
			n += 1
			continue
		kept.append(it)
	if n <= 0:
		return
	hotbar = kept
	_hotbar_sig = ""
	_log("end", "drop %s tokens" % n)
	if hotbar_box:
		_sync_hotbar()


func _enter_dungeon_clear() -> void:
	if not _find_loaded_bag().is_empty():
		return
	_drop_dungeon_tokens()
	if sfx:
		sfx.set_combat_music(false)
		sfx.play("confirm_big", -6.0)
		sfx.play_event(&"sting.clear")
		if sfx.has_method("music_after_dungeon_clear"):
			sfx.music_after_dungeon_clear()
		else:
			sfx.music_title()
	if combat_stage:
		combat_stage.hide_stage()
	if player_stage:
		player_stage.hide_stage()
	_hide_hypno()
	_undo_wall()
	if in_tutorial:
		if wheel_view and wheel_view.has_method("play_hero"):
			wheel_view.play_hero("victory", 2)
		_player_play("victory", 2)
		_flash_screen(Color("e8c36a"), 0.28)
		phase = "victory"
		_log("end", "cleared")
		return
	if not adventure:
		if wheel_view and wheel_view.has_method("play_hero"):
			wheel_view.play_hero("victory", 2)
		_player_play("victory", 2)
		_flash_screen(Color("e8c36a"), 0.28)
		_log("end", "cleared")
		_classic_swipe_home()
		return
	# Rope stays shut until the parade finishes (~2.7s). No wax seal.
	# Callers start this without await, then _refresh() while still in ready —
	# so we must refresh again after rest, or the rope never opens (itch soft-lock).
	await _play_clear_parade()
	dungeons_cleared += 1
	_advance_bucket_counter()
	phase = "rest"
	_log("end", "dungeon %s" % dungeons_cleared)
	facing_index = -1
	_refresh()


func _play_clear_parade() -> void:
	var saved := true
	if wheel_view:
		saved = wheel_view.hub_sprout_on
		wheel_view.hub_sprout_on = false
		wheel_view.hub_parade_hide = true
		wheel_view.hub_flip = false
		wheel_view.queue_redraw()
	var parade := preload("res://scripts/cabin/clear_parade.gd").new()
	parade.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(parade)
	# Clear hub_parade_hide even if the parade node is freed mid-await.
	var _parade_exiting := func() -> void:
		if wheel_view != null and is_instance_valid(wheel_view):
			wheel_view.hub_parade_hide = false
	if not parade.tree_exiting.is_connected(_parade_exiting):
		parade.tree_exiting.connect(_parade_exiting)
	if get_tree() != null:
		await parade.run(wheel_view, art)
	if is_instance_valid(parade):
		if parade.tree_exiting.is_connected(_parade_exiting):
			parade.tree_exiting.disconnect(_parade_exiting)
		parade.queue_free()
	if wheel_view:
		wheel_view.hub_parade_hide = false
		wheel_view.hub_sprout_on = saved
		wheel_view.hub_flip = false
		wheel_view.queue_redraw()


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
	if _campaign_on:
		await _campaign_bank_from_hand()
	_cabin_from_leave = true
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "win", news, ids)
	_adventure_busy = false


## Nib blocked Push under 5/5: bank the haul, dissolve home to that biome's case. No map piece.
func _push_interrupt_home() -> void:
	if not adventure or phase != "rest" or _adventure_busy:
		return
	_adventure_busy = true
	var pool := ""
	var biome_name := ""
	if _campaign_on and _campaign != null:
		pool = CAMPAIGN_SHELL.current_biome_id(_campaign.rules, _campaign.state)
		biome_name = CAMPAIGN_SHELL.biome_name(_campaign.rules, pool)
	var ids: Array = []
	for it in hotbar:
		var cid: String = str(it.get("card_id", ""))
		if cid != "":
			ids.append(cid)
	var news: Array = []
	if home_cabin:
		# Flag before swipe_ids — deferred bank can run during the dissolve.
		if home_cabin.has_method("begin_push_block_bank"):
			home_cabin.begin_push_block_bank()
		news = home_cabin.swipe_ids(ids)
	if overlay:
		overlay.visible = false
	if rope_exit:
		rope_exit.hide_exit()
	_log("end", "push_block_home")
	if sfx:
		sfx.play("whoosh", -10.0, 0.9)
	await _dissolve_to_black(0.6)
	if _campaign_on:
		await _campaign_bank_from_hand()
	_cabin_from_leave = true
	_reset_run()
	phase = "title"
	if pool != "":
		_sync_dungeon_biome(pool)
	if home_cabin and home_cabin.has_method("open_hall_after_push_block"):
		_hide_fight_hover()
		home_cabin.items_by_id = items_by_id
		home_cabin.tex_by_item = tex_by_item
		home_cabin.buckets_open = _buckets_revealed
		await home_cabin.open_hall_after_push_block(pool, biome_name, news, ids)
		if overlay:
			overlay.visible = false
		get_tree().paused = true
		_hide_fight_hover()
	else:
		_open_home_cabin(true, "win", news, ids)
	await _fade_from_black(0.35)
	_adventure_busy = false


func _dissolve_to_black(seconds: float = 0.6) -> void:
	if _hall_wipe == null:
		await get_tree().create_timer(seconds).timeout
		return
	_hall_wipe.visible = true
	_hall_wipe.mouse_filter = Control.MOUSE_FILTER_STOP
	_hall_wipe.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_hall_wipe, "modulate:a", 1.0, seconds)
	await tw.finished


func _fade_from_black(seconds: float = 0.35) -> void:
	if _hall_wipe == null:
		return
	var tw := create_tween()
	tw.tween_property(_hall_wipe, "modulate:a", 0.0, seconds)
	await tw.finished
	_hall_wipe.visible = false
	_hall_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
	if route == "gatehouse":
		_open_campaign_map()
		return
	_hide_cabin_for_run()
	if home_cabin:
		home_cabin.note_belly(1)
	match route:
		"gatehouse":
			if DevFlags.show_old_gatehouse():
				_begin_run()
			else:
				_begin_adventure()
		"long_drop":
			if DevFlags.show_long_drop():
				_begin_long_drop()
			else:
				_begin_adventure()
		"shortcut":
			_quick_start()
		_:
			_begin_adventure()


func _toggle_held_map() -> void:
	if campaign_map and campaign_map.visible:
		if campaign_map.has_method("is_picker_open") and campaign_map.is_picker_open():
			if campaign_map.has_method("is_read_only") and campaign_map.is_read_only():
				_on_map_peek_closed()
			else:
				_close_campaign_map()
		return
	_open_campaign_map()


func _open_campaign_map() -> void:
	if _campaign == null or campaign_map == null:
		return
	_campaign_seed_next_run_if_needed(false)
	if bool(_campaign.state.get("won", false)) and not bool(_campaign.state.get("drawer_seen", false)):
		campaign_map.show_drawer()
		await campaign_map.continued
		CAMPAIGN_SHELL.mark_drawer_seen(_campaign.state)
		_campaign.write()
	var map_opts := {}
	if home_cabin != null and home_cabin.has_method("consume_map_focus_pool"):
		var focus_pool: String = str(home_cabin.consume_map_focus_pool())
		if focus_pool != "":
			map_opts["focus_pool"] = focus_pool
	campaign_map.show_map(_campaign.rules, _campaign.state, monsters_by_id, map_opts)
	# held_map may clear pencil_fresh on present — persist that.
	_campaign.write()


func _close_campaign_map() -> void:
	if campaign_map:
		campaign_map.hide_map()
	if phase == "title" and home_cabin != null and home_cabin.visible:
		return
	if _campaign_on:
		_campaign_abort()
	_reset_run()
	phase = "title"
	_open_home_cabin(false)


func _can_peek_campaign_map() -> bool:
	if not _campaign_on or _campaign == null or campaign_map == null:
		return false
	if campaign_map.visible:
		return false
	if phase == "title" or phase == "devtest":
		return false
	if home_cabin != null and home_cabin.visible:
		return false
	if settings_ui != null and settings_ui.visible:
		return false
	if sack_peek != null and sack_peek.visible:
		return false
	if playtest_feedback != null and playtest_feedback.visible:
		return false
	if playtest_tier != null and playtest_tier.visible:
		return false
	if playtest_hub != null and playtest_hub.visible:
		return false
	if playtest_intro != null and playtest_intro.visible:
		return false
	if roster_ed != null and roster_ed.visible:
		return false
	if script_ed != null and script_ed.visible:
		return false
	if content_ed != null and content_ed.visible:
		return false
	for n in get_tree().get_nodes_in_group("authoring_overlay"):
		if n is CanvasItem and (n as CanvasItem).is_visible_in_tree():
			return false
	return true


func _peek_campaign_map() -> void:
	if not _can_peek_campaign_map():
		return
	_campaign_seed_next_run_if_needed(false)
	get_tree().paused = true
	campaign_map.show_map(_campaign.rules, _campaign.state, monsters_by_id, {"read_only": true})


func _on_map_peek_closed() -> void:
	if campaign_map:
		campaign_map.hide_map()
	get_tree().paused = false


func _on_campaign_start(index: int, shortcut: bool, endless: bool) -> void:
	if campaign_map:
		campaign_map.hide_map()
	await _begin_campaign_delve(index, shortcut, endless)


func _on_campaign_cheat(action: String) -> void:
	if _campaign == null or not DevFlag.on():
		return
	if action == "fresh":
		_campaign.state = CAMPAIGN_SHELL.fresh_state()
	elif action == "grant3":
		CAMPAIGN_SHELL.debug_bank_matching(_campaign.rules, _campaign.state, _campaign_item_entries(), 3, "")
	elif action == "fill_b1":
		var need: int = CAMPAIGN_SHELL.quota_of(_campaign.rules) - CAMPAIGN_SHELL.cabinet_count(_campaign.state, "b1")
		CAMPAIGN_SHELL.debug_bank_matching(_campaign.rules, _campaign.state, _campaign_item_entries(), maxi(0, need), "b1")
	elif action == "win":
		for raw in CAMPAIGN_SHELL.biomes_of(_campaign.rules):
			var pool := str((raw as Dictionary).get("id", ""))
			var need2: int = CAMPAIGN_SHELL.quota_of(_campaign.rules) - CAMPAIGN_SHELL.cabinet_count(_campaign.state, pool)
			CAMPAIGN_SHELL.debug_bank_matching(_campaign.rules, _campaign.state, _campaign_item_entries(), maxi(0, need2), pool)
	_campaign_seed_next_run_if_needed(true)
	_campaign.write()
	if home_cabin and home_cabin.has_method("sync_swiped_from_banked"):
		home_cabin.sync_swiped_from_banked()
	_open_campaign_map()


func _begin_campaign_delve(index: int, shortcut: bool, endless: bool) -> void:
	_session("scene", "campaign")
	_hide_cabin_for_run()
	_reset_run()
	if _campaign == null:
		return
	_campaign_on = true
	adventure = true
	challenge_route = false
	CAMPAIGN_SHELL.begin_run(_campaign.state, index, shortcut, endless)
	CAMPAIGN_SHELL.grant_delve_reroll(_campaign.rules, _campaign.state)
	_campaign.write()
	_sync_dungeon_biome()
	_reset_moves()
	dungeon_index = 1 if endless else index + 1
	dungeons_cleared = 0
	adventure_seat_tiers = [1, 1, 1, 1, 1, 1]
	phase = "draft"
	draft_action = "busy"
	_log("on_click", "Campaign")
	_log("var", "HP %s" % hp)
	# Verdant Hollow (b1): intro once, then loop for the delve. Other biomes keep combat bed.
	if sfx and sfx.has_method("music_biome_dungeon") and not endless:
		var biome_id := CAMPAIGN_SHELL.current_biome_id(_campaign.rules, _campaign.state)
		sfx.music_biome_dungeon(biome_id)
	_refresh()
	await _reveal_new_buckets()
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	await _campaign_arm_delve()
	await _run_challenge_setup()
	if draft_action == "challenge_begin":
		_challenge_begin_play()


func _campaign_rows(for_seed: bool = false) -> Array:
	## Arm-delve uses open pools only. Seeding the full next-run chain needs every
	## adventure-ok monster so later biomes can draw their own Deadlies.
	var rows: Array = []
	for id in monsters_by_id.keys():
		var card: Dictionary = monsters_by_id[id]
		if for_seed:
			if not _campaign_card_seed_ok(card):
				continue
		elif not _campaign_card_ok(card):
			continue
		var contra: Array = []
		var raw: Variant = card.get("contradiction_ids", [])
		if typeof(raw) == TYPE_ARRAY:
			for c in raw:
				contra.append(str(c))
		rows.append({"id": str(id), "tier": int(card.get("tier", 1)), "contra": contra})
	return rows


func _campaign_seed_next_run_if_needed(force: bool = false) -> void:
	if _campaign == null:
		return
	CAMPAIGN_SHELL.normalize(_campaign.state)
	var nr: Variant = _campaign.state.get("next_run", {})
	var deals: Dictionary = {}
	if typeof(nr) == TYPE_DICTIONARY:
		var raw_deals: Variant = (nr as Dictionary).get("deals", {})
		if typeof(raw_deals) == TYPE_DICTIONARY:
			deals = raw_deals
	if not force and not deals.is_empty():
		return
	var seed: int = int(Time.get_unix_time_from_system()) ^ rng.randi()
	if seed == 0:
		seed = 1
	CAMPAIGN_SHELL.seed_next_run(_campaign.rules, _campaign.state, _campaign_rows(true), seed)
	_campaign.write()


func _campaign_arm_delve() -> void:
	if _campaign == null:
		return
	var rows: Array = _campaign_rows(false)
	var biome := CAMPAIGN_SHELL.current_biome_id(_campaign.rules, _campaign.state)
	_sync_dungeon_biome(biome)
	CAMPAIGN_SHELL.normalize(_campaign.state)
	var deal: Dictionary = CAMPAIGN_SHELL.consume_next_run_deal(
		_campaign.rules, _campaign.state, rows, biome, rng
	)
	_campaign.write()
	_campaign_queue = deal.get("ids", [])
	_campaign_telegraph = deal.get("telegraph", [])
	_campaign_starter_left = CAMPAIGN_SHELL.starter_tiers(_campaign.rules, rng)
	for queued in _campaign_queue:
		monster_pool.erase(queued)
	if campaign_map:
		campaign_map.hide_map()


func _campaign_take_queued() -> String:
	if not _campaign_on or _campaign_queue.is_empty():
		return ""
	return str(_campaign_queue.pop_front())


func _campaign_card_base_ok(card: Dictionary) -> bool:
	if card.is_empty() or _campaign == null:
		return false
	var st := str(card.get("status", "live"))
	if st == "retired" or st == "hold":
		return false
	if not ModePool.allows(card, ModePool.ADVENTURE):
		return false
	var cid := str(card.get("id", ""))
	if cid == "smoke_bomb" or BucketRules.is_always_starter_id(cid):
		return false
	if BucketRules.is_token(card):
		return false
	return true


func _campaign_card_seed_ok(card: Dictionary) -> bool:
	if not _campaign_card_base_ok(card):
		return false
	## Any mapped pool is fine for seeding — locked biomes still need their Deadlies.
	return CAMPAIGN_SHELL.pool_for_bucket(_campaign.rules, BucketRules.of_card(card)) != ""


func _campaign_card_ok(card: Dictionary) -> bool:
	if not _campaign_card_base_ok(card):
		return false
	return CAMPAIGN_SHELL.pool_open_for_bucket(_campaign.rules, _campaign.state, BucketRules.of_card(card))


func _campaign_item_entries() -> Array:
	var out: Array = []
	if _campaign == null:
		return out
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		var st := str(card.get("status", "live"))
		if st == "hold" or st == "retired":
			continue
		var pool := CAMPAIGN_SHELL.pool_for_bucket(_campaign.rules, BucketRules.of_card(card))
		if pool == "":
			continue
		out.append({"id": str(id), "pool": pool})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return out


func _campaign_pool_of_item(id: String) -> String:
	if _campaign == null:
		return ""
	var card: Dictionary = items_by_id.get(id, {})
	return CAMPAIGN_SHELL.pool_for_bucket(_campaign.rules, BucketRules.of_card(card))


func _campaign_rerolls() -> int:
	if not _campaign_on or _campaign == null:
		return 0
	return int(_campaign.state.get("run", {}).get("rerolls", 0))


func _campaign_spend_reroll() -> bool:
	if _campaign == null:
		return false
	var ok: bool = CAMPAIGN_SHELL.spend_reroll(_campaign.state)
	if ok:
		_campaign.write()
	return ok


func _campaign_abort() -> void:
	if not _campaign_on or _campaign == null:
		return
	CAMPAIGN_SHELL.end_run(_campaign.state)
	_campaign.write()


func _campaign_bank_from_hand() -> void:
	if _campaign == null:
		return
	var ids: Array = []
	var pools := {}
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var id := str(it.get("card_id", ""))
		if id == "":
			continue
		ids.append(id)
		pools[id] = _campaign_pool_of_item(id)
	var result: Dictionary = CAMPAIGN_SHELL.bank(_campaign.rules, _campaign.state, ids, pools)
	CAMPAIGN_SHELL.end_run(_campaign.state)
	## Next run's Deadlies are seeded as soon as the haul banks home.
	_campaign_seed_next_run_if_needed(true)
	_campaign.write()
	if home_cabin and home_cabin.has_method("sync_swiped_from_banked"):
		home_cabin.sync_swiped_from_banked()
	if bool(result.get("show_drawer", false)) and campaign_map != null:
		campaign_map.show_drawer()
		await campaign_map.continued
		CAMPAIGN_SHELL.mark_drawer_seen(_campaign.state)
		_campaign.write()
		campaign_map.hide_map()


func _campaign_draw_pair(tier: int) -> Array:
	var entries: Array = []
	for id in item_pool:
		var card: Dictionary = items_by_id.get(str(id), {})
		entries.append({"id": str(id), "tier": int(card.get("tier", 1))})
	var picked: Array = CAMPAIGN_SHELL.take_pair(rng, entries, tier, _campaign_exclude)
	_campaign_exclude.clear()
	var out: Array = []
	for raw in picked:
		var iid := str(raw)
		if iid == "":
			continue
		item_pool.erase(iid)
		var made: Dictionary = _make_item(iid)
		_stamp_pack(made, _pack_tier_for(iid, items_by_id, tier), "draft")
		out.append(made)
	return out


func _campaign_draft_decision() -> Dictionary:
	var box := {"kind": "", "uid": 0}
	var epoch: int = _loot_epoch
	var on_pick := func(uid: int) -> void:
		if str(box["kind"]) == "":
			box["kind"] = "pick"
			box["uid"] = uid
	var on_roll := func() -> void:
		if str(box["kind"]) == "":
			box["kind"] = "reroll"
	if challenge_draft_ui == null:
		return box
	challenge_draft_ui.chosen.connect(on_pick)
	if challenge_draft_ui.has_signal("reroll_wanted"):
		challenge_draft_ui.reroll_wanted.connect(on_roll)
	while str(box["kind"]) == "" and is_instance_valid(self):
		if epoch != _loot_epoch:
			box["kind"] = "cancel"
			break
		await get_tree().process_frame
	if challenge_draft_ui.chosen.is_connected(on_pick):
		challenge_draft_ui.chosen.disconnect(on_pick)
	if challenge_draft_ui.has_signal("reroll_wanted") and challenge_draft_ui.reroll_wanted.is_connected(on_roll):
		challenge_draft_ui.reroll_wanted.disconnect(on_roll)
	return box


func _go_home_loss() -> void:
	_campaign_abort()
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "loss", [], [])


func _give_up() -> void:
	_campaign_abort()
	_reset_run()
	phase = "title"
	_open_home_cabin(true, "loss", [], [])
	if home_cabin:
		home_cabin._arrive_skip = 2


func _rope_deeper() -> void:
	if _campaign_on and _campaign != null and not CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state):
		return
	_adventure_continue()
	if home_cabin:
		home_cabin.note_belly(dungeon_index + 1)
	if _campaign_on and _campaign != null and bool(_campaign.state.get("run", {}).get("endless", false)):
		_campaign.write()


func _rope_loot_rows() -> Array:
	var rows: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var id: String = str(it.get("card_id", ""))
		if id == "":
			continue
		var owned: bool = home_cabin != null and bool(home_cabin.swiped.get(id, false))
		rows.append({
			"id": id,
			"name": str(it.get("name", id)),
			"tier": _tier_of(it),
			"is_new": not owned,
			"tex": tex_by_item.get(id, null),
		})
	rows.sort_custom(func(a, b) -> bool:
		var an: int = 1 if bool(a.get("is_new", false)) else 0
		var bn: int = 1 if bool(b.get("is_new", false)) else 0
		if an != bn:
			return an > bn
		return int(a.get("tier", 1)) > int(b.get("tier", 1))
	)
	return rows


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
	_on_item_unhovered()
	if inspect:
		inspect.visible = false
	if speech_box and speech_box.has_method("hide_speech"):
		speech_box.hide_speech()


func _sync_dungeon_biome(biome_id: String = "") -> void:
	if dungeon_bg == null or not dungeon_bg.has_method("set_biome"):
		return
	var id := str(biome_id).strip_edges()
	if id == "" and _campaign_on and _campaign != null:
		id = CAMPAIGN_SHELL.current_biome_id(_campaign.rules, _campaign.state)
	dungeon_bg.set_biome(id)


func _open_home_cabin(walk_in: bool, kind: String = "win", new_ids: Array = [], held_ids: Array = []) -> void:
	if home_cabin == null:
		return
	_hide_fight_hover()
	if _campaign != null:
		_sync_dungeon_biome()
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
	if _campaign_on and _campaign != null and not CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state):
		return
	_adventure_busy = true
	if _campaign_on and _campaign != null:
		CAMPAIGN_SHELL.push_deeper(_campaign.rules, _campaign.state)
		CAMPAIGN_SHELL.grant_delve_reroll(_campaign.rules, _campaign.state)
		_campaign.write()
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
	_reset_moves()
	_fill_challenge_pools()
	_empty_wheel(CHALLENGE_SEATS)
	if _campaign_on:
		await _campaign_arm_delve()
	await _run_challenge_setup()
	if not challenge_route and draft_action == "challenge_begin":
		_challenge_begin_play()
		if not _campaign_on:
			await _maybe_auto_spin()
	_adventure_busy = false
	_refresh()


func _prep_next_dungeon() -> void:
	_mill_seq += 1
	_gate_line = ""
	_cube_line = ""
	_cleric_line = ""
	_cleric_talk_index = -1
	_berserk_line = ""
	_berserk_talk_index = -1
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
	player_poison = 0
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
	last_hp_lost = 0
	_stone_saved = 0
	_stone_armed = false
	_saucer_blk_due = 0
	last_item_copy = {}
	silenced = {}
	pending_feed = {}
	_bell_wait = false
	_toll_death_armed = false
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
	_pending_item_flee = false
	_drink_hp_due = false
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
		if str(_ops_of(it).get("kind", "")) == "shield_alt":
			_set_shield_face(it, "atk")
		if str(it.get("card_id", "")) == "hex":
			it["hex_n"] = 6
	_drop_dungeon_tokens()
	if combat_stage:
		combat_stage.hide_stage()
	if player_stage:
		player_stage.hide_stage()
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
	_open_home_from_title()


func _first_mill_bucket() -> int:
	var first: int = BucketRules.MAX_BUCKET + 1
	for card in items_by_id.values():
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if not BucketRules.counts_for_mill(card):
			continue
		var b: int = BucketRules.of_card(card)
		if b >= 1 and b < first:
			first = b
	for card2 in monsters_by_id.values():
		if typeof(card2) != TYPE_DICTIONARY:
			continue
		if not BucketRules.counts_for_mill(card2):
			continue
		var b2: int = BucketRules.of_card(card2)
		if b2 >= 1 and b2 < first:
			first = b2
	if first > BucketRules.MAX_BUCKET:
		return 1
	return first


func _load_bucket_progress() -> void:
	_dungeons_ended = 0
	_buckets_revealed = 0
	var f := FileAccess.open(BUCKET_PROGRESS_PATH, FileAccess.READ)
	if f == null:
		_buckets_revealed = _first_mill_bucket()
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_buckets_revealed = _first_mill_bucket()
		return
	_dungeons_ended = maxi(0, int(parsed.get("dungeons_ended", 0)))
	_buckets_revealed = maxi(0, int(parsed.get("revealed", 0)))
	if _buckets_revealed == 0:
		_buckets_revealed = _first_mill_bucket()


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
	_guarantee_bucket = _buckets_revealed
	_log("var", "buckets reset")


func _dev_set_buckets(n: int) -> void:
	if n <= 0:
		n = _first_mill_bucket()
	_buckets_revealed = clampi(n, 1, BucketRules.MAX_BUCKET)
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
	if _campaign != null:
		_campaign.state = CAMPAIGN_SHELL.fresh_state()
		_campaign.write()
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
		_open_home_cabin(false)
		home_cabin.play_intro()
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
	fly_tip.z_index = 140 if playtest_tier != null and playtest_tier.visible else 129
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
			_monster_plate_look(s, rule)
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
	var n: int = BucketRules.of_card(card)
	return n >= 0 and n <= _buckets_revealed


func _bucket_over_quota(bucket: int) -> bool:
	var ni: int = 0
	var nm: int = 0
	for card in items_by_id.values():
		if typeof(card) != TYPE_DICTIONARY:
			continue
		if not BucketRules.counts_for_mill(card):
			continue
		if BucketRules.of_card(card) == bucket:
			ni += 1
	for card2 in monsters_by_id.values():
		if typeof(card2) != TYPE_DICTIONARY:
			continue
		if not BucketRules.counts_for_mill(card2):
			continue
		if BucketRules.of_card(card2) == bucket:
			nm += 1
	return ni > BucketRules.want_items(bucket) or nm > BucketRules.want_monsters(bucket)


func _reveal_new_buckets() -> void:
	if _campaign_on:
		return
	if _dungeons_ended <= _buckets_revealed:
		return
	var newest: int = _buckets_revealed
	_unlock_screen = true
	_hide_board_for_unlock()
	for b in range(_buckets_revealed + 1, _dungeons_ended + 1):
		if b > BucketRules.MAX_BUCKET:
			break
		if _bucket_over_quota(b):
			break
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
	_buckets_revealed = newest
	if newest > 0:
		_guarantee_bucket = newest
	_save_bucket_progress()
	_fill_pools()


func _bucket_entries(bucket_n: int) -> Array:
	var loot: Array = []
	var loot_extra: Array = []
	var foes: Array = []
	var foe_extra: Array = []
	for id in items_by_id.keys():
		var card: Dictionary = items_by_id[id]
		if BucketRules.of_card(card) != bucket_n:
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card):
			continue
		if BucketRules.is_always_starter(card):
			continue
		var loot_tex: Texture2D = tex_by_item.get(id, null)
		if loot_tex == null and art != null:
			loot_tex = art.item_tex(id)
		var entry: Dictionary = _bucket_entry(card, "Loot", loot_tex)
		entry["extra"] = not BucketRules.counts_for_mill(card)
		if bool(entry["extra"]):
			loot_extra.append(entry)
		else:
			loot.append(entry)
	for id2 in monsters_by_id.keys():
		var card2: Dictionary = monsters_by_id[id2]
		if BucketRules.of_card(card2) != bucket_n:
			continue
		if str(card2.get("status", "live")) == "retired" or str(card2.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card2):
			continue
		var entry2: Dictionary = _bucket_entry(card2, "Foe", tex_by_monster.get(id2, null))
		entry2["extra"] = not BucketRules.counts_for_mill(card2)
		if bool(entry2["extra"]):
			foe_extra.append(entry2)
		else:
			foes.append(entry2)
	var out: Array = []
	out.append_array(loot)
	out.append_array(loot_extra)
	out.append_array(foes)
	out.append_array(foe_extra)
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
		if BucketRules.of_card(card) == bucket_n:
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
		if BucketRules.of_card(monsters_by_id.get(have, {})) == _guarantee_bucket:
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
		await _seat_opener(int(CARDINAL_SLOTS[0]), id, "starter")
		return
	var at: int = seats[rng.randi_range(0, seats.size() - 1)]
	var old_id: String = str(wheel[at].get("card_id", ""))
	if old_id != "":
		monster_pool.append(old_id)
	await _seat_opener(at, id, "starter")
	if wheel_view:
		_stamp_atk_variants()
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
		if BucketRules.of_card(items_by_id.get(have, {})) == _guarantee_bucket:
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
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
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
		if _rug_secret_gated(str(id)):
			continue
		for _c2 in range(maxi(0, int(card2.get("count", 1)))):
			item_pool.append(str(id))


func _arm_rug_secret_for_run() -> void:
	_rug_secret_in_run = home_cabin != null and bool(home_cabin.rug_secret_found)


func _rug_secret_gated(id: String) -> bool:
	return id == "poison_flask" and not _rug_secret_in_run


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
	if OS.has_feature("editor") and has_meta("qa_hand_cap"):
		return int(get_meta("qa_hand_cap"))
	if _campaign_on:
		return HAND_MAX
	return CHALLENGE_HAND if adventure else HAND_MAX


func _hand_full() -> bool:
	return hotbar.size() >= _hand_limit()


func _item_is_curse(it: Dictionary) -> bool:
	var id: String = str(it.get("card_id", ""))
	var card: Dictionary = items_by_id.get(id, {})
	if bool(card.get("curse", false)):
		return true
	return id == "spider_egg" or id == "toll" or id == "rust"


func _item_blocks_hand_tax(it: Dictionary) -> bool:
	if it.is_empty():
		return false
	if _item_is_curse(it):
		return true
	var id: String = str(it.get("card_id", ""))
	var card: Dictionary = items_by_id.get(id, {})
	if str(card.get("card_color", "")) == "egg":
		return true
	return id == "blood_pact"


func _filter_toss_uids(uids: Array) -> Array:
	var out: Array = []
	for uidv in uids:
		var uid: int = int(uidv)
		var it: Dictionary = _find_item(uid)
		if it.is_empty():
			continue
		if _item_blocks_hand_tax(it):
			continue
		out.append(uid)
	return out


func _toss_pick_mode() -> bool:
	if _challenge_loot_wait:
		return true
	if pending_feed.is_empty():
		return false
	return str(pending_feed.get("kind", "")) != "upgrade"


func _abort_full_hand_gain(it: Dictionary) -> void:
	_challenge_loot_wait = false
	_challenge_pending_gain = {}
	_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
	_sync_hub_cue()
	_log("discard", str(it.get("name", "?")))
	if sfx:
		sfx.play("error", -10.0)
		sfx.play("cloth", -12.0)
	_refresh()


func _start_full_hand_replace(it: Dictionary) -> bool:
	if it.is_empty():
		return false
	if _filter_toss_uids(_hand_all_uids()).is_empty():
		_abort_full_hand_gain(it)
		return false
	_challenge_pending_gain = it.duplicate(true)
	_challenge_loot_wait = true
	_refresh()
	return true


func _challenge_item_banned(id: String) -> bool:
	return not ModePool.allows(items_by_id.get(id, {}), ModePool.CHALLENGE)


func _challenge_monster_banned(id: String) -> bool:
	return not ModePool.allows(monsters_by_id.get(id, {}), ModePool.CHALLENGE)


func _fill_challenge_pools() -> void:
	monster_pool.clear()
	item_pool.clear()
	for id in runtime.get("monsters", []):
		var mid: String = str(id)
		if _campaign_on:
			if not _campaign_card_ok(monsters_by_id.get(mid, {})):
				continue
		elif _challenge_monster_banned(mid):
			continue
		var card: Dictionary = monsters_by_id.get(mid, {})
		if card.is_empty():
			continue
		if not _campaign_on and not _bucket_open(card):
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		for _c in range(maxi(0, int(card.get("count", 1)))):
			monster_pool.append(mid)
	if _latest_rig:
		_arm_latest_queues()
	_challenge_reshuffle_items()
	if _latest_rig:
		_inject_latest_ids(_latest_monster_q, monster_pool, true)


func _arm_latest_queues() -> void:
	_latest_monster_q = []
	for id in _latest_monster_ids:
		_latest_monster_q.append(str(id))
	_latest_item_q = []
	for id2 in _latest_item_ids:
		_latest_item_q.append(str(id2))


func _inject_latest_ids(q: Array, pool: Array, monster: bool) -> void:
	for raw in q:
		var id: String = str(raw)
		if monster:
			if _challenge_monster_banned(id) or monsters_by_id.get(id, {}).is_empty():
				continue
		else:
			if _challenge_item_banned(id) or items_by_id.get(id, {}).is_empty():
				continue
			if BucketRules.is_always_starter_id(id) or _rug_secret_gated(id):
				continue
		if not pool.has(id):
			pool.append(id)


func _take_latest_queued(q: Array, pool: Array, exclude: String, monster: bool) -> String:
	var i: int = 0
	while i < q.size():
		var id: String = str(q[i])
		if exclude != "" and id == exclude:
			i += 1
			continue
		if monster and _challenge_monster_conflicts(id):
			i += 1
			continue
		if not pool.has(id):
			q.remove_at(i)
			continue
		q.remove_at(i)
		pool.erase(id)
		return id
	return ""


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
		if _campaign_on:
			if not _campaign_card_ok(items_by_id.get(iid, {})):
				continue
		elif _challenge_item_banned(iid):
			continue
		var card2: Dictionary = items_by_id.get(iid, {})
		if card2.is_empty():
			continue
		if not _campaign_on and not _bucket_open(card2):
			continue
		if BucketRules.is_always_starter_id(iid):
			continue
		if _rug_secret_gated(iid):
			continue
		var want: int = maxi(0, int(card2.get("count", 1)) - int(held.get(iid, 0)))
		for _c2 in range(want):
			item_pool.append(iid)
	if _latest_rig:
		_inject_latest_ids(_latest_item_q, item_pool, false)


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
		var did: String = _deck_card_id(id)
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
	if _latest_rig:
		var forced: String = _take_latest_queued(_latest_monster_q, monster_pool, "", true)
		if forced != "":
			return forced
	var t: int = _challenge_roll_tier()
	var id: String = _challenge_take_monster_filtered(t)
	if id == "":
		id = _challenge_take_monster_filtered(0)
	if id == "":
		id = _take_card(monster_pool, monsters_by_id, "", 0)
	return id


func _challenge_take_item(tier: int, exclude_id: String) -> String:
	if _latest_rig:
		var forced: String = _take_latest_queued(_latest_item_q, item_pool, exclude_id, false)
		if forced != "":
			return forced
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
	if card.has_method("set_rim_glow"):
		card.set_rim_glow(false)
	if card.has_method("set_draft_glow"):
		card.set_draft_glow(false)
	if card.has_method("set_steal_cursor") and art != null:
		card.set_steal_cursor(art.ui.get("cursor_hand", null))
	_dress_showcase_card(card, it, false)
	return card


func _run_challenge_setup() -> void:
	var seq: int = _mill_seq
	draft_action = "busy"
	phase = "draft"
	_refresh()
	await _challenge_seat_dungeon(dungeon_index > 1 and not _campaign_on)
	if seq != _mill_seq:
		return
	if _campaign_on:
		_campaign_grant_starter_six()
		await _enforce_hand_cap()
		if challenge_draft_ui:
			challenge_draft_ui.hide_draft()
		draft_action = "challenge_begin"
		phase = "draft"
		_sort_hotbar()
		_refresh()
		_layout_play_field()
		return
	if _qa_busy():
		_challenge_auto_opening_loot()
		if challenge_draft_ui:
			challenge_draft_ui.hide_draft()
		draft_action = "challenge_begin"
		phase = "draft"
		_sort_hotbar()
		_refresh()
		_layout_play_field()
		return
	await _challenge_run_opening_drafts()


func _campaign_grant_starter_six() -> void:
	if _campaign == null:
		return
	_challenge_reshuffle_items()
	var tiers: Array = CAMPAIGN_SHELL.starter_tiers(_campaign.rules, rng)
	for raw_t in tiers:
		if hotbar.size() >= _hand_limit():
			break
		var t: int = int(raw_t)
		var iid: String = _challenge_take_item(t, "")
		if iid == "" or iid == "smoke_bomb":
			_challenge_reshuffle_items()
			iid = _challenge_take_item(t, "")
		if iid == "" or iid == "smoke_bomb":
			iid = _challenge_take_item(0, "")
		if iid == "" or iid == "smoke_bomb":
			continue
		var seated: Dictionary = _make_item(iid)
		_stamp_pack(seated, _pack_tier_for(iid, items_by_id, t), "draft")
		hotbar.append(seated.duplicate(true))
		_log("on_draft", "gain %s" % seated.get("name", "?"))
	_sort_hotbar()


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
	var deck_n := CHALLENGE_DECK_N
	if _campaign_on and _campaign != null:
		deck_n = CAMPAIGN_SHELL.deck_counts(_campaign.rules).y
	for i in CHALLENGE_SEATS:
		if seq != _mill_seq:
			return
		var mid: String = _campaign_take_queued()
		if mid == "":
			mid = _challenge_take_monster()
		if mid == "":
			break
		await _seat_opener(i, mid, "starter")
		var seated: Dictionary = wheel[i]
		challenge_draft_plan.append({
			"tier": _tier_of(seated),
			"name": str(seated.get("name", "?")),
			"id": str(seated.get("card_id", "")),
		})
		if i < adventure_seat_tiers.size():
			adventure_seat_tiers[i] = _tier_of(seated)
		if wheel_view:
			_stamp_atk_variants()
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(i)
		if sfx:
			sfx.play_event(&"chal.seat_dungeon", {"pitch_mul": 1.0 + float(i) * 0.03})
		await get_tree().create_timer(0.08).timeout
	for _d in deck_n:
		if seq != _mill_seq:
			return
		var did: String = _campaign_take_queued()
		if did == "":
			did = _challenge_take_monster()
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
	var mud_load: Array = []
	if _campaign_on and _campaign != null:
		mud_load = CAMPAIGN_SHELL.mudroom_loadout_of(_campaign.state)
	if mud_load.is_empty() and home_cabin != null:
		mud_load = home_cabin.mudroom_loadout.duplicate()
	for i in challenge_draft_plan.size():
		if seq != _mill_seq:
			return
		if hotbar.size() >= CHALLENGE_HAND:
			break
		challenge_pick_i = i
		var row: Dictionary = challenge_draft_plan[i]
		var t: int = int(row.get("tier", 1))
		if _campaign_on and not _campaign_starter_left.is_empty():
			t = int(_campaign_starter_left.pop_front())
		## Mudroom peg picks seat the opening hand; skip the pair offer for those.
		if not mud_load.is_empty():
			var mid := str(mud_load.pop_front())
			if mid != "":
				item_pool.erase(mid)
				var seated: Dictionary = _make_item(mid)
				_stamp_pack(seated, _pack_tier_for(mid, items_by_id, t), "draft")
				await _challenge_commit_item(seated, true)
				continue
		var who: String = str(row.get("name", "Monster"))
		await _challenge_offer_pick(
			PLAYER_COPY.text("challenge.pick_open", "Choose your loot"),
			"%s  ·  %s" % [who, PLAYER_COPY.tier_name(t)],
			t,
			true,
			_campaign_on
		)
		if in_tutorial and i == 0:
			if tut:
				tut.nib_close = 0.7
				tut.nudge("You will see bigger loot as the monsters get bigger. This is just a demo — I'll fill the rest.")
			for j in range(i + 1, challenge_draft_plan.size()):
				if hotbar.size() >= CHALLENGE_HAND:
					break
				var row2: Dictionary = challenge_draft_plan[j]
				var t2: int = int(row2.get("tier", 1))
				var pair2: Array = _challenge_draw_pair(t2)
				if pair2.is_empty():
					_challenge_reshuffle_items()
					pair2 = _challenge_draw_pair(t2)
				if pair2.is_empty():
					continue
				hotbar.append(pair2[0].duplicate(true))
			_sort_hotbar()
			break
	if seq != _mill_seq:
		return
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	draft_action = "challenge_begin"
	phase = "draft"
	_sort_hotbar()
	_refresh()
	_layout_play_field()


func _live_facing_seat() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return -1
	var face: Dictionary = wheel[facing_index]
	if str(face.get("kind", "")) != "monster":
		return -1
	if int(face.get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		return -1
	return facing_index


func _sync_loot_pips() -> void:
	if challenge_draft_ui == null or not challenge_draft_ui.has_method("set_loot_pips"):
		return
	if not challenge_draft_ui.visible:
		challenge_draft_ui.set_loot_pips(0, 0)
		return
	var opening: bool = draft_action == "challenge_pick"
	var pack: Dictionary = PlaytestUx.loot_remaining(
		opening,
		challenge_pick_i,
		challenge_draft_plan.size(),
		CHALLENGE_SEATS,
		challenge_deck.size(),
		true
	)
	challenge_draft_ui.set_loot_pips(int(pack.get("remaining", 0)), int(pack.get("total", 0)))


func _challenge_begin_play() -> void:
	if not adventure:
		return
	if draft_action != "challenge_begin":
		return
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()
	draft_action = ""
	phase = "ready"
	_await_first_spin = true
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


func _challenge_offer_pick(title: String, sub: String, tier: int, replace_if_full: bool, allow_reroll: bool = false) -> void:
	if not replace_if_full and hotbar.size() >= CHALLENGE_HAND:
		return
	var picked: Dictionary = {}
	while true:
		var pair: Array = _campaign_draw_pair(tier) if allow_reroll else _challenge_draw_pair(tier)
		if pair.is_empty():
			_challenge_reshuffle_items()
			pair = _campaign_draw_pair(tier) if allow_reroll else _challenge_draw_pair(tier)
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
		var charges := _campaign_rerolls() if allow_reroll else 0
		if challenge_draft_ui.has_method("set_reroll"):
			challenge_draft_ui.set_reroll(charges > 0, "Reroll (%s left)" % charges)
		_sync_loot_pips()
		var last_loot: bool = challenge_deck.is_empty() and draft_action != "challenge_pick"
		if draft_action == "challenge_pick":
			last_loot = challenge_pick_i >= challenge_draft_plan.size() - 1 and challenge_deck.is_empty()
		_draft_final_item = last_loot
		if challenge_draft_ui.has_method("set_final_item"):
			challenge_draft_ui.set_final_item(false)
		_sync_hub_cue()
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
		var epoch: int = _loot_epoch
		var token: int = _undo_gen
		var decision: Dictionary = await _campaign_draft_decision()
		var pair_snap: Array = _challenge_pair.duplicate()
		_challenge_pair.clear()
		if _undo_stale(token) or epoch != _loot_epoch or str(decision.get("kind", "")) == "cancel":
			if challenge_draft_ui:
				challenge_draft_ui.hide_draft()
			_layout_play_field()
			return
		if str(decision.get("kind", "")) == "reroll" and allow_reroll and _campaign_spend_reroll():
			_campaign_exclude.clear()
			for it in pair_snap:
				var back := str(it.get("card_id", ""))
				if back != "":
					_campaign_exclude.append(back)
					item_pool.append(back)
			challenge_draft_ui.hide_draft()
			continue
		challenge_draft_ui.hide_draft()
		_layout_play_field()
		var uid: int = int(decision.get("uid", 0))
		for it2 in pair_snap:
			if int(it2.get("uid", 0)) == uid:
				picked = it2
				break
		if picked.is_empty() and not pair_snap.is_empty():
			picked = pair_snap[0]
		break
	await _challenge_commit_item(picked, replace_if_full)


func _challenge_commit_item(it: Dictionary, replace_if_full: bool) -> void:
	if it.is_empty():
		return
	var epoch: int = _loot_epoch
	var token: int = _undo_gen
	var uid: int = int(it.get("uid", 0))
	for held in hotbar:
		if int(held.get("uid", 0)) == uid:
			return
	if hotbar.size() < CHALLENGE_HAND:
		if epoch != _loot_epoch or _undo_stale(token):
			return
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
	if not _start_full_hand_replace(it):
		return
	while _challenge_loot_wait and is_instance_valid(self):
		if epoch != _loot_epoch or _undo_stale(token):
			_challenge_loot_wait = false
			_challenge_pending_gain = {}
			return
		await get_tree().process_frame


func _challenge_discard_one(uid: int) -> void:
	if not _challenge_loot_wait:
		return
	var have: Dictionary = _find_item(uid)
	if have.is_empty():
		return
	if _item_blocks_hand_tax(have):
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	_discard_from_hand(uid, true, false)
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
	if int(m.get("died_seq", 0)) <= 0:
		_note_death(m)
	_hole_serial += 1
	wheel[index]["hole_id"] = _hole_serial
	wheel[index]["died_seq"] = int(m.get("died_seq", 0))
	wheel[index]["died_batch"] = int(m.get("died_batch", 0))


func _begin_simul() -> void:
	_death_batch += 1
	_simul_depth += 1


func _end_simul() -> void:
	_simul_depth = maxi(0, _simul_depth - 1)


func _note_death(m: Dictionary) -> void:
	if int(m.get("died_seq", 0)) > 0:
		return
	if _simul_depth <= 0:
		_death_batch += 1
	_death_seq += 1
	m["died_seq"] = _death_seq
	m["died_batch"] = _death_batch


func _arm_item_hold() -> void:
	if _item_hold:
		return
	_item_hold = true
	_hold_holes += 1


func _release_item_hold() -> void:
	if not _item_hold:
		return
	_item_hold = false
	_hold_holes = maxi(0, _hold_holes - 1)


func _has_challenge_holes() -> bool:
	for s in wheel:
		if typeof(s) != TYPE_DICTIONARY:
			continue
		if bool(s.get("challenge_hole", false)):
			return true
	return false


func _index_of_hole(hid: int) -> int:
	for i in range(wheel.size()):
		if int(wheel[i].get("hole_id", -1)) != hid:
			continue
		if bool(wheel[i].get("challenge_hole", false)):
			return i
	return -1


func _index_of_seat(uid: int) -> int:
	if uid < 0:
		return -1
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("seat_uid", -1)) == uid:
			return i
	return -1


func _clockwise_to_top(index: int) -> float:
	if wheel_view == null:
		return float(index)
	var target: float = wheel_view.rotation_for_top(index)
	return fposmod(target - wheel_view.rot, TAU)


func _order_clockwise(idxs: Array) -> Array[int]:
	var out: Array[int] = []
	if idxs.is_empty():
		return out
	var start: int = int(idxs[0])
	var best: float = _clockwise_to_top(start)
	for raw in idxs:
		var i: int = int(raw)
		var dist: float = _clockwise_to_top(i)
		if dist < best - 0.0001 or (absf(dist - best) <= 0.0001 and i < start):
			best = dist
			start = i
	var n: int = wheel.size()
	if n <= 0:
		out.append(start)
		return out
	for off in n:
		var j: int = (start + off) % n
		if idxs.has(j):
			out.append(j)
	return out


func _ordered_hole_ids() -> Array:
	var batches: Dictionary = {}
	var keys: Array[int] = []
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if not bool(s.get("challenge_hole", false)):
			continue
		var batch: int = int(s.get("died_batch", 1000000 + i))
		if not batches.has(batch):
			batches[batch] = []
			keys.append(batch)
		(batches[batch] as Array).append(i)
	keys.sort()
	var ids: Array = []
	for batch in keys:
		var group: Array = batches[batch]
		var ordered: Array[int] = _order_clockwise(group)
		for i in ordered:
			ids.append(int(wheel[i].get("hole_id", 0)))
	return ids


func _ensure_face_at_six() -> void:
	if phase != "fighting":
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var face: Dictionary = wheel[facing_index]
	if str(face.get("kind", "")) != "monster":
		return
	if int(face.get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		return
	if wheel_view == null:
		return
	wheel_view.facing_index = facing_index
	wheel_view.selected_index = -1
	var token: int = _undo_gen
	await wheel_view.recenter_on(facing_index)
	if _undo_stale(token):
		return
	wheel_view.snap_to_index(facing_index)
	_stamp_atk_variants()
	wheel_view.set_slices(wheel, facing_index, "none")
	if combat_stage and not combat_stage.visible:
		combat_stage.show_monster(str(face.get("card_id", "")), _tier_of(face))
		_tune_combat_stage()
	_refresh()


func _flush_midfight_holes() -> void:
	if _hold_holes > 0 or _flushing_holes:
		return
	_flushing_holes = true
	var token: int = _undo_gen
	var spin_after: bool = _spin_after_holes
	_spin_after_holes = false
	var keep_uid: int = -1
	if phase == "fighting" and facing_index >= 0 and facing_index < wheel.size():
		var face: Dictionary = wheel[facing_index]
		if str(face.get("kind", "")) == "monster" and (int(face.get("hp", 0)) > 0 or _wick_waiting(facing_index)):
			keep_uid = _seat_uid_at(facing_index)
	_walker_busy = true
	_sync_buttons()
	if adventure and _has_challenge_holes():
		await _challenge_resolve_holes(0)
	if _undo_stale(token):
		_flushing_holes = false
		_walker_busy = false
		return
	if keep_uid >= 0 and phase == "fighting":
		var back: int = _index_of_seat(keep_uid)
		if back >= 0:
			facing_index = back
			await _ensure_face_at_six()
	elif phase == "fighting":
		await _ensure_face_at_six()
	if _undo_stale(token):
		_flushing_holes = false
		_walker_busy = false
		return
	_flushing_holes = false
	_walker_busy = false
	_sync_buttons()
	_refresh()
	if spin_after and phase == "ready" and facing_index < 0:
		await _maybe_auto_spin()


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


func _challenge_resolve_holes(_from: int) -> void:
	var token: int = _undo_gen
	var ids: Array = _ordered_hole_ids()
	var guard: int = 0
	var k: int = 0
	while k < ids.size() and guard < 24:
		guard += 1
		if _undo_stale(token):
			return
		var hid: int = int(ids[k])
		k += 1
		var i: int = _index_of_hole(hid)
		if i < 0:
			continue
		await _fill_challenge_hole(i)
		if _undo_stale(token):
			return
		if _index_of_hole(hid) >= 0:
			ids.append(hid)


func _fill_challenge_hole(i: int) -> void:
	if wheel.is_empty() or i < 0 or i >= wheel.size():
		return
	if not bool(wheel[i].get("challenge_hole", false)):
		return
	var token: int = _undo_gen
	var hole: Dictionary = wheel[i]
	if bool(hole.get("mimic_gift", false)):
		await _grant_mimic_gift()
		if _undo_stale(token):
			return
	var collapsing: bool = challenge_deck.is_empty()
	await _challenge_refill_or_collapse(i)
	if _undo_stale(token) or collapsing:
		return
	if i < 0 or i >= wheel.size():
		return
	var arriver: Dictionary = wheel[i]
	if str(arriver.get("kind", "")) != "monster":
		return
	var t: int = _tier_of(arriver)
	var who: String = str(arriver.get("name", "Monster"))
	if sfx:
		sfx.play("open", -8.0)
		sfx.play("bong", -14.0, 1.1)
	await _challenge_offer_pick(
		PLAYER_COPY.text("challenge.pick_loot", "Loot"),
		"%s  ·  %s" % [who, PLAYER_COPY.tier_name(t)],
		t,
		true
	)


func _challenge_refill_or_collapse(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var token: int = _undo_gen
	if not challenge_deck.is_empty():
		if dungeon_deck_ui:
			if wheel_view:
				dungeon_deck_ui.entry_global = wheel_view.slice_portrait_global(index)
			await dungeon_deck_ui.play_draw()
			if _undo_stale(token):
				return
		if challenge_deck.is_empty() or index < 0 or index >= wheel.size():
			return
		if not bool(wheel[index].get("challenge_hole", false)):
			return
		var raw: Variant = challenge_deck.pop_front()
		var nid: String = _deck_card_id(raw)
		if dungeon_deck_ui and not dungeon_deck_ui.is_busy():
			dungeon_deck_ui.set_count(challenge_deck.size())
		if wheel_view:
			if PlaytestUx.keep_face_after_neighbor_hole() and _live_facing_seat() >= 0:
				await wheel_view.recenter_on(_live_facing_seat(), 0.28)
			else:
				await wheel_view.rotate_index_to_top(index, 0.42)
			if _undo_stale(token):
				return
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
			if _undo_stale(token):
				return
		if index < 0 or index >= wheel.size() or not bool(wheel[index].get("challenge_hole", false)):
			return
		await _seat_opener(index, nid, "draft")
		if _undo_stale(token):
			return
		if typeof(raw) == TYPE_DICTIONARY:
			_apply_deck_scars(index, raw)
		if wheel_view:
			if wheel_view.slay_index == index:
				wheel_view.clear_slay()
			_stamp_atk_variants()
			var keep_face: int = _live_facing_seat()
			if PlaytestUx.keep_face_after_neighbor_hole() and keep_face >= 0:
				wheel_view.set_slices(wheel, keep_face, "none")
				await wheel_view.recenter_on(keep_face, 0.22)
			else:
				wheel_view.set_slices(wheel, -1, "none")
			if _undo_stale(token):
				return
			wheel_view.pulse_arrive(index)
		if sfx:
			sfx.play("drop", -8.0)
			sfx.play("whoosh", -12.0, 0.9)
		_refresh()
		return
	if wheel_view:
		await wheel_view.collapse_slice(index)
		if _undo_stale(token):
			return
	if index < 0 or index >= wheel.size():
		return
	wheel.remove_at(index)
	if challenge_aim == index:
		challenge_aim = -1
	elif challenge_aim > index:
		challenge_aim -= 1
	if facing_index == index:
		facing_index = -1
	elif facing_index > index:
		facing_index -= 1
	if wheel_view:
		wheel_view.facing_index = facing_index
	_reseat_slots()
	_sync_wheel_stats()
	_refresh()


func _challenge_after_fight() -> void:
	var token: int = _undo_gen
	var start: int = facing_index
	if facing_index >= 0 and facing_index < wheel.size() and str(wheel[facing_index].get("kind", "")) == "monster":
		await _on_owner_defeated(facing_index)
		if _undo_stale(token) or hp <= 0:
			return
		await _wick_on_defeated(facing_index)
		if _undo_stale(token):
			return
		_challenge_vacate(facing_index)
	for i in range(wheel.size()):
		if _undo_stale(token):
			return
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) > 0 and not bool(s.get("crossbowed", false)):
			continue
		await _on_owner_defeated(i)
		if _undo_stale(token) or hp <= 0:
			return
		await _wick_on_defeated(i)
		if _undo_stale(token):
			return
		if wheel_view:
			await wheel_view.play_slay(i)
		if _undo_stale(token):
			return
		_challenge_vacate(i)
	if _undo_stale(token):
		return
	facing_index = -1
	if wheel_view:
		wheel_view.selected_index = -1
		wheel_view.facing_index = -1
	_discard_spent_items()
	_bank_stone_wall()
	blk = 0
	_log("var", "BLK 0")
	_log("var", "defeated %s" % mobs_defeated)
	await _challenge_resolve_holes(start)
	if _undo_stale(token):
		return
	_sync_wheel_stats()
	phase = "ready"
	if _monsters_left() == 0:
		if await _try_release_bag():
			_refresh()
			await _maybe_auto_spin()
			_walker_busy = false
			if in_tutorial:
				call_deferred("_tutorial_after_fight")
			return
		_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	_walker_busy = false
	if in_tutorial:
		call_deferred("_tutorial_after_fight")
	elif _is_adventure_mode() and _monsters_left() > 0:
		await _maybe_auto_spin()


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
	if ops_kind == "heal" or ops_kind == "heal_both_draw" or ops_kind == "heal_kills" or ops_kind == "heal_keep" or ops_kind == "heal_full" or ops_kind == "heal_poison" or ops_kind == "heal_swap_keep":
		return Color("243a22")
	if ops_kind == "chaos_reroll":
		return Color("3a1460")
	if ops_kind == "napalm":
		return Color("5c2626")
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
	var kind: String = str(_ops_of(it).get("kind", ""))
	var unplayable: bool = _kind_always_unplayable(kind) or _item_stoned(it)
	if str(it.get("card_id", "")) == "echo_bell" and _echo_face(it).is_empty():
		unplayable = true
	if kind == "chakram":
		var halves: Dictionary = _chakram_halves(it)
		if not bool(halves.get("blk", false)) and not bool(halves.get("atk", false)):
			unplayable = true
	if kind == "sling":
		if phase == "fighting" and _sling_attack_options(int(it.get("uid", -1))).is_empty():
			unplayable = true
	if str(pending_mark.get("kind", "")) == "sling_any":
		unplayable = true
	elif not pending_choice.is_empty():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		if str(_ops_of(chooser).get("kind", "")) == "sling" or str(chooser.get("card_id", "")) == "sling":
			var pick_uid: int = int(it.get("uid", -1))
			var listed := pick_uid == int(chooser.get("uid", -1))
			if not listed:
				for opt_v2 in pending_choice.get("options", []):
					if typeof(opt_v2) == TYPE_DICTIONARY and int((opt_v2 as Dictionary).get("atk_uid", -1)) == pick_uid:
						listed = true
						break
			if not listed:
				unplayable = true
	if kind == "signpost":
		if phase == "fighting" and _mark_targets("signpost").is_empty():
			unplayable = true
	if kind == "blk_half_atk" and not bool(view.get("can_use", false)):
		unplayable = true
	return {
		"fill": view.get("fill", Color("5c2626")),
		"metal": _tier_metal(tier),
		"tier": tier,
		"rank": PLAYER_COPY.tier_name(tier),
		"unplayable": unplayable,
	}


func _special_id_of(s: Dictionary) -> String:
	var sid: String = str(s.get("special_id", "")).strip_edges()
	if sid != "":
		return sid
	var spec: Dictionary = MONSTER_SPECIAL.get(str(s.get("card_id", "")), {})
	return str(spec.get("id", ""))


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


func _hotbar_ids() -> Dictionary:
	var have := {}
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var iid: String = str(it.get("card_id", ""))
		if iid != "":
			have[iid] = true
	if not pending_item.is_empty():
		var pid: String = str(pending_item.get("card_id", ""))
		if pid != "":
			have[pid] = true
	return have


func _next_starter_item() -> String:
	if starter_items_left <= 0:
		return ""
	var have: Dictionary = _hotbar_ids()
	var put_back: Array[String] = []
	var iid: String = ""
	while true:
		iid = _take_card(item_pool, items_by_id, "", 0)
		if iid == "":
			break
		if not have.has(iid):
			break
		put_back.append(iid)
	for p in put_back:
		item_pool.append(p)
	if iid == "" or have.has(iid):
		return ""
	starter_items_left -= 1
	return iid


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
	var guard_tier: int = _pack_tier_now()
	draft_gate.present_mystery(pending_item, guard_tier, _offer_tex(), passes)
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
		_refresh_offer_card(guard_tier)
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
	await get_tree().create_timer(0.25).timeout
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
		await _seat_opener(si, mid, "starter")
		if wheel_view:
			_stamp_atk_variants()
			wheel_view.set_slices(wheel, -1, "none")
			wheel_view.pulse_arrive(si)
		if sfx:
			sfx.play_event(&"draft.seat_starter", {"pitch_mul": 1.0 + float(si) * 0.02})
		await get_tree().create_timer(0.14).timeout
	starters_left = 0
	if upgrade and adventure and dungeon_index > 1 and seq == _mill_seq:
		await _upgrade_two_openers()
	if seq == _mill_seq:
		await _force_guarantee_monster()


func _seat_opener(si: int, mid: String, pack_kind: String) -> void:
	if pack_kind == "draft" and (si < 0 or si >= wheel.size() or not bool(wheel[si].get("challenge_hole", false))):
		return
	var m: Dictionary = _make_monster(mid)
	m["slot"] = SLOT_ORDER[si]
	m["spin_locked"] = false
	_stamp_pack(m, _pack_tier_for(mid, monsters_by_id, int(monsters_by_id.get(mid, {}).get("tier", 1))), pack_kind)
	wheel[si] = m
	_log("on_place", "%s → %s" % [m["name"], m["slot"]])
	_sync_wheel_stats()
	await _maybe_enter_gains(si)


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
		await _seat_opener(si, nid, "starter")
		if wheel_view:
			_stamp_atk_variants()
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
		await get_tree().create_timer(0.55).timeout
		if seq != _mill_seq:
			return
		var from: Vector2 = draft_gate.actor_global() if draft_gate else Vector2.ZERO
		var tex: Texture2D = draft_gate.still_tex() if draft_gate else null
		if draft_gate:
			draft_gate.hide_actor()
		var dest: Vector2 = from
		if wheel_view:
			dest = wheel_view.slice_portrait_global(idx)
		await _fly_courier(tex, from, dest, 0.14)
		if seq != _mill_seq:
			return
		await _commit_place(idx, false)
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
	await _commit_place(index)


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
		"poison": 0,
		"plague_held": false,
		"crossbowed": false,
		"rarity": str(card.get("rarity", "starter")),
		"pack_tier": int(card.get("tier", 0)),
		"pack_kind": "starter" if str(card.get("rarity", "starter")) == "starter" else "draft",
		"atk_variable": false,
		"hp_variable": false,
		"swing_muted": false,
		"fled_once": false,
		"rage_step": 0,
		"outburst": 0,
		"rage_fire": false,
		"silenced": false,
		"wick_bonus": 0,
		"egg_atk": 0,
		"aura_hp": 0,
		"aura_atk": 0,
		"atk_mod": 0,
		"atk_zeroed": false,
		"hydra_bonus": 0,
		"gaze_done": false,
		"hunger_n": 0,
		"has_attacked": false,
		"polymorphed_this_fight": false,
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
		"petrify_n": 0,
		"echo_copy": last_item_copy.duplicate(true) if id == "echo_bell" and not last_item_copy.is_empty() else {},
		"alt_n": 2 if str(ops.get("kind", "")) == "atk_alt_24" else 0,
		"shield_face": "atk" if str(ops.get("kind", "")) == "shield_alt" else "",
		"magnet_mode": "off",
		"magnet_seq": 0,
		"hex_n": 6 if id == "hex" else 0,
		"marble_n": 0,
		"marble_monster": "",
		"cats_eye": false,
		"toll_n": 6 if id == "toll" else 0,
		"recycle_n": 5 if id == "recycler" else 0,
		"rust_n": 3 if id == "rust" else 0,
		"rust_seen": false,
		"bagged": {},
		"bagged_hp": 0,
		"bagged_name": "",
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


func _apply_hunger_penalty(s: Dictionary, touch_atk: bool = true, touch_hp: bool = true) -> void:
	var n: int = int(s.get("hunger_n", 0))
	if n <= 0:
		return
	var cut: int = n * 3
	if touch_atk:
		s["atk"] = maxi(0, int(s.get("atk", 0)) - cut)
	if touch_hp:
		s["hp"] = maxi(0, int(s.get("hp", 0)) - cut)
		s["hp_max"] = maxi(int(s.get("hp_max", 0)) - cut, int(s.get("hp", 0)))


func _apply_formulas_to(s: Dictionary) -> void:
	_peel_auras(s)
	var id: String = str(s.get("card_id", ""))
	if _is_silenced(s):
		# Quiet Bell freezes Vampire at the HP and Attack it already gained.
		# Queen eggs already eaten stay on the number.
		if id != "vampire":
			if not bool(s.get("atk_locked", false)):
				var atk_n: int = _card_base_atk(id) + int(s.get("egg_atk", 0)) + int(s.get("hydra_bonus", 0)) + int(s.get("outburst", 0))
				if id == "kobold_trapper":
					atk_n += int(s.get("trapper_growth", 0))
				s["atk"] = atk_n
			if not bool(s.get("hp_locked", false)):
				var missing_pre: int = 0
				if id == "kobold_trapper":
					missing_pre = maxi(0, int(s.get("hp_max", int(s.get("hp", 0)))) - int(s.get("hp", 0)))
				s["hp"] = _card_base_hp(id)
				s["hp_max"] = int(s["hp"])
				var dust: int = int(s.get("fairy_dust", 0))
				if dust > 0:
					s["hp_max"] = int(s["hp_max"]) + dust
					s["hp"] = int(s["hp"]) + dust
				var growth_q: int = int(s.get("trapper_growth", 0)) if id == "kobold_trapper" else 0
				if growth_q > 0:
					s["hp_max"] = int(s["hp_max"]) + growth_q
					s["hp"] = maxi(0, int(s["hp_max"]) - missing_pre)
			_apply_hunger_penalty(s, not bool(s.get("atk_locked", false)), not bool(s.get("hp_locked", false)))
		if not bool(s.get("atk_locked", false)):
			_apply_sandbag_cut(s)
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
	s["atk"] = int(s.get("atk", 0)) + int(s.get("egg_atk", 0)) + int(s.get("hydra_bonus", 0)) + int(s.get("outburst", 0)) + int(s.get("trapper_growth", 0))
	_apply_hunger_penalty(s, true, true)
	var card: Dictionary = monsters_by_id.get(id, {})
	s["call_name"] = MONSTER_LINES.call_of(id, card)
	s["reminder"] = MONSTER_LINES.reminder_of(id, card)
	s["log_hint"] = str(card.get("log_hint", ""))
	if hp_locked:
		s["hp"] = hold_hp
		if id == "vampire" or id == "amalgam" or id == "bushido":
			s["hp_max"] = maxi(hold_max, hold_hp)
		if id == "slime_boss":
			s["atk"] = hold_hp
	else:
		var bonus: int = int(s.get("leech_bonus", 0)) + int(s.get("fairy_dust", 0)) + int(s.get("trapper_growth", 0)) + int(s.get("sync_hp", 0))
		if bonus > 0:
			var missing: int = maxi(0, hold_max - hold_hp)
			s["hp_max"] = int(s["hp_max"]) + bonus
			s["hp"] = maxi(0, int(s["hp_max"]) - missing)
	if id == "vampire":
		s["atk"] = _card_base_atk(id) + int(s.get("bloodlust", 0))
	elif atk_locked and id != "slime_boss":
		s["atk"] = hold_atk
	if not _atk_is_always(s):
		var held_atk: bool = atk_locked and id != "slime_boss" and id != "vampire"
		if not held_atk:
			var extra_atk: int = int(s.get("sync_atk", 0))
			if extra_atk != 0:
				s["atk"] = int(s.get("atk", 0)) + extra_atk
	if not atk_locked:
		_apply_sandbag_cut(s)


func _apply_sandbag_cut(s: Dictionary) -> void:
	if str(s.get("card_id", "")) != "sandbag":
		return
	var n: int = int(s.get("sandbag_cut", 0))
	if n <= 0:
		return
	s["atk"] = maxi(0, int(s.get("atk", 0)) - n)


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
	if _is_silenced(s):
		return
	var id: String = str(s.get("card_id", ""))
	match id:
		"bandit":
			s["atk"] = _live_item_count()
		"vampire":
			s["atk"] = _card_base_atk(id) + int(s.get("bloodlust", 0))
		"spider_queen":
			s["atk"] = _card_base_atk(id) + int(s.get("egg_atk", 0))
		"hydra":
			s["atk"] = _card_base_atk(id) + int(s.get("hydra_bonus", 0))
		"dire_wolf":
			s["atk"] = hp
		"slime_boss":
			s["atk"] = int(s.get("hp", 0))
		_:
			pass
	if not _atk_is_always(s):
		var live_extra: int = int(s.get("sync_atk", 0))
		if live_extra != 0:
			s["atk"] = int(s.get("atk", 0)) + live_extra


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
		var innate: int = int(wheel[i].get("atk", 0))
		if not _atk_is_always(wheel[i]):
			innate = maxi(0, innate - int(wheel[i].get("sync_atk", 0)))
		wheel[i]["atk_innate"] = innate


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
			wheel[i]["rage_fire"] = (not bool(wheel[i]["silenced"])) and int(wheel[i].get("outburst", 0)) > 0
	_sync_plague_poison()
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
		if id != "fairy" and id != "commander":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		var left_i: int = (i - 1 + n) % n
		var right_i: int = (i + 1) % n
		for j in [left_i, right_i]:
			# Alone on the wheel, left/right wrap to this seat — skip self.
			if j == i:
				continue
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			if id == "fairy":
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
	## SP-26: Wraith no longer copies a neighbor's Attack.
	pass


func _mark_vars() -> void:
	var n: int = wheel.size()
	var lich_touch: Dictionary = {}
	var cmd_touch: Dictionary = {}
	for i in n:
		var cid: String = str(wheel[i].get("card_id", ""))
		if cid == "fairy":
			var ll: int = (i - 1 + n) % n
			var lr: int = (i + 1) % n
			if ll != i:
				lich_touch[ll] = true
			if lr != i:
				lich_touch[lr] = true
		elif cid == "commander":
			var cl: int = (i - 1 + n) % n
			var cr: int = (i + 1) % n
			if cl != i:
				cmd_touch[cl] = true
			if cr != i:
				cmd_touch[cr] = true
	for i in n:
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var id: String = str(wheel[i].get("card_id", ""))
		wheel[i]["atk_variable"] = id == "dire_wolf" or id == "bandit" or id == "berserker" or id == "slime_boss" or id == "vampire" or cmd_touch.has(i)
		wheel[i]["hp_variable"] = id == "ogre" or id == "skeleton" or id == "leech_league" or id == "wick" or lich_touch.has(i)
		wheel[i]["cmd_buff"] = cmd_touch.has(i)
		wheel[i]["lich_buff"] = lich_touch.has(i)
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
	if hub_cue != null and hub_cue.visible:
		_place_hub_cue()
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
	# Fight portrait/gutter place is dirty/deferred only — not every process frame.
	# (Per-frame calls flooded place_calls and mis-tagged Scorecard spikes as place.)
	_sync_move_hint()
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
	if in_tutorial:
		_tutorial_try_shift_inspect()
	_sync_cascade_ff()
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Alt-tab clears the 3x scale; holding Shift after focus returns re-applies it.
		# Shot harness may run unfocused — keep QA force-shift alive.
		if has_meta("qa_force_shift") and bool(get_meta("qa_force_shift")):
			return
		if _cascade_ff or Engine.time_scale > ANIM_TIME_SCALE + 0.01:
			_restore_cascade_time_scale()


func _text_input_focused() -> bool:
	var vp := get_viewport()
	if vp == null:
		return false
	var f: Control = vp.gui_get_focus_owner() as Control
	return f is LineEdit or f is TextEdit


func _sync_cascade_ff() -> void:
	if str(phase) != _phase_for_ff:
		var left_cascade: bool = _phase_for_ff in ["fighting", "slaying"] and phase not in ["fighting", "slaying"]
		_phase_for_ff = str(phase)
		if left_cascade:
			_restore_cascade_time_scale()
	var in_cascade: bool = phase in ["fighting", "slaying"] and _walker_busy
	if not in_cascade:
		if _cascade_ff:
			_restore_cascade_time_scale()
		return
	var shift_down: bool = Input.is_key_pressed(KEY_SHIFT)
	if has_meta("qa_force_shift"):
		shift_down = bool(get_meta("qa_force_shift"))
	var ff: bool = shift_down and not _text_input_focused()
	var want: float = ANIM_TIME_SCALE * 3.0 if ff else ANIM_TIME_SCALE  # x3 on top of the game's normal anim speed
	if not is_equal_approx(Engine.time_scale, want):
		Engine.time_scale = want
		print("[cascade-ff] time_scale=", Engine.time_scale, " ff=", ff)
	if ff != _cascade_ff:
		_cascade_ff = ff
		if cascade_ticker != null and cascade_ticker.has_method("set_ff"):
			cascade_ticker.set_ff(ff)
		if ability_slash != null and ability_slash.has_method("set_fast_holds"):
			ability_slash.set_fast_holds(ff)


func _restore_cascade_time_scale() -> void:
	_cascade_ff = false
	# Cascade runs at ANIM_TIME_SCALE (x3 while Shift is held); restore the global anim scale.
	Engine.time_scale = ANIM_TIME_SCALE
	if cascade_ticker != null and cascade_ticker.has_method("set_ff"):
		cascade_ticker.set_ff(false)
	if ability_slash != null and ability_slash.has_method("set_fast_holds"):
		ability_slash.set_fast_holds(false)
	print("[cascade-ff] restore time_scale=", Engine.time_scale, " busy=", _walker_busy, " phase=", phase)


func _unhandled_input(event: InputEvent) -> void:
	if phase == "devtest" and event.is_action_pressed("ui_accept"):
		_dev_enter()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if (key.keycode == KEY_M or key.physical_keycode == KEY_M) and _can_peek_campaign_map():
			_peek_campaign_map()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2 and PLAYTEST_FLAG.tools():
		if playtest_intro != null and playtest_intro.visible:
			get_viewport().set_input_as_handled()
			return
		if playtest_teaser != null and playtest_teaser.visible and not playtest_teaser.holding_still:
			get_viewport().set_input_as_handled()
			return
		_toggle_playtest_feedback()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F6:
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
		await _play_latest()
		get_viewport().set_input_as_handled()
		return
	if _authoring() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F7:
		_open_campaign_map()
		get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if playtest_tier != null and playtest_tier.visible:
		playtest_tier.close_list()
		get_viewport().set_input_as_handled()
		return
	if playtest_feedback != null and playtest_feedback.visible:
		playtest_feedback.close_box()
		get_viewport().set_input_as_handled()
		return
	if playtest_hub != null and playtest_hub.visible:
		get_viewport().set_input_as_handled()
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
	if home_cabin:
		settings_ui.invert_scroll = bool(home_cabin.invert_scroll)
	settings_ui.open_menu(in_run)
	if sfx:
		sfx.play("open", -12.0)
	get_viewport().set_input_as_handled()


func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_sparkles_toggled(on: bool) -> void:
	RankShimmer.shown = on


func _on_invert_scroll_toggled(on: bool) -> void:
	if home_cabin == null:
		return
	home_cabin.invert_scroll = on
	home_cabin._save()


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
			await _play_latest()
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
	if not _authoring() or in_tutorial:
		return
	if fly_tip:
		fly_tip.hide_plate()
	if speech_box:
		speech_box.hide_speech()
	var ps1: String = ProjectSettings.globalize_path("res://tools/dev/open-script-desk.ps1")
	var err: int = OS.create_process("powershell.exe", PackedStringArray([
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", ps1,
	]))
	if err == -1:
		OS.shell_open("http://127.0.0.1:8765/")
	_log("on_click", "Script desk")


func _build_playtest() -> void:
	playtest_inbox = PLAYTEST_INBOX.new()
	add_child(playtest_inbox)
	playtest_inbox.setup()
	playtest_inbox.finished.connect(_on_playtest_sent)
	playtest_hub = PLAYTEST_HUB.new()
	add_child(playtest_hub)
	playtest_hub.setup()
	playtest_hub.brand_new.connect(_playtest_brand_new)
	playtest_hub.middle_progress.connect(_playtest_middle)
	playtest_hub.continue_save.connect(_playtest_continue)
	playtest_hub.feedback_wanted.connect(func() -> void: _open_playtest_comment("", ""))
	playtest_feedback = PLAYTEST_FEEDBACK.new()
	add_child(playtest_feedback)
	playtest_feedback.setup()
	playtest_feedback.send_wanted.connect(_on_playtest_note)
	playtest_feedback.tier_wanted.connect(_open_playtest_tier)
	playtest_tier = PLAYTEST_TIER.new()
	add_child(playtest_tier)
	playtest_tier.setup()
	playtest_tier.send_wanted.connect(_on_playtest_ranks)
	playtest_tier.card_hovered.connect(_dev_bucket_hovered)
	playtest_tier.card_unhovered.connect(_dev_bucket_unhovered)
	playtest_tier.closed.connect(_on_playtest_tier_closed)
	if not PLAYTEST_FLAG.on():
		return
	playtest_fab = _pill(PLAYER_COPY.text("playtest.feedback", "Feedback"), Color("3a3220"), Color("e8c36a"), func() -> void: _open_playtest_comment("", ""))
	playtest_fab.process_mode = Node.PROCESS_MODE_ALWAYS
	playtest_fab.z_index = 120
	playtest_fab.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	playtest_fab.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	playtest_fab.grow_vertical = Control.GROW_DIRECTION_BEGIN
	playtest_fab.offset_left = -200
	playtest_fab.offset_top = -64
	playtest_fab.offset_right = -16
	playtest_fab.offset_bottom = -16
	add_child(playtest_fab)
	playtest_voice = Label.new()
	playtest_voice.process_mode = Node.PROCESS_MODE_ALWAYS
	playtest_voice.text = PLAYER_COPY.text("playtest.play_chip", "Right-click a Monster/Item, or press F2, to send a note.")
	playtest_voice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	playtest_voice.add_theme_font_size_override("font_size", 13)
	playtest_voice.add_theme_color_override("font_color", Color("d8cbb8"))
	playtest_voice.add_theme_color_override("font_outline_color", Color("100e0c"))
	playtest_voice.add_theme_constant_override("outline_size", 2)
	playtest_voice.z_index = 120
	playtest_voice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	playtest_voice.set_anchors_preset(PRESET_BOTTOM_LEFT)
	playtest_voice.grow_vertical = Control.GROW_DIRECTION_BEGIN
	playtest_voice.offset_left = 16
	playtest_voice.offset_top = -72
	playtest_voice.offset_right = 420
	playtest_voice.offset_bottom = -16
	add_child(playtest_voice)
	playtest_intro = PLAYTEST_INTRO.new()
	add_child(playtest_intro)
	playtest_intro.setup(art, sfx, playtest_fab, playtest_feedback.send_button() if playtest_feedback else null)
	if playtest_feedback:
		playtest_intro.pin_panel(playtest_feedback.panel())
	playtest_intro.finished.connect(_playtest_intro_done)
	playtest_intro.skipped.connect(_playtest_intro_done)
	playtest_intro.wants_f2.connect(_playtest_intro_f2)
	playtest_intro.wants_fab.connect(_playtest_intro_fab)
	playtest_teaser = TITLE_TEASER.new()
	add_child(playtest_teaser)
	playtest_teaser.setup(art, sfx)
	playtest_teaser.finished.connect(_playtest_teaser_done)
	_sync_playtest_chrome()


func _open_playtest_hub() -> void:
	_session("scene", "hub")
	if playtest_hub == null:
		return
	_playtest_boot = false
	if home_cabin:
		home_cabin.visible = false
	if overlay:
		overlay.visible = false
	get_tree().paused = true
	if playtest_intro != null and not _playtest_intro_seen():
		if playtest_hub:
			playtest_hub.close_hub()
		playtest_intro.pin_send(playtest_feedback.send_button() if playtest_feedback else null)
		if playtest_feedback:
			playtest_intro.pin_panel(playtest_feedback.panel())
		playtest_intro.open_intro()
		_sync_playtest_chrome()
		return
	_maybe_open_teaser()


func _show_playtest_hub(over_still: bool = false) -> void:
	if playtest_intro:
		playtest_intro.close_intro()
	if playtest_feedback:
		playtest_feedback.force_close()
	var can_continue: bool = home_cabin != null and home_cabin.has_save()
	playtest_hub.open_hub(can_continue, over_still)
	_sync_playtest_chrome()


func _playtest_intro_done() -> void:
	_mark_playtest_intro_seen()
	_maybe_open_teaser()


func _teaser_should_play() -> bool:
	if not PLAYTEST_FLAG.on():
		return false
	if OS.has_feature("editor"):
		return true
	return TITLE_TEASER.still_ready()


func _maybe_open_teaser() -> void:
	if playtest_intro:
		playtest_intro.close_intro()
	if TITLE_TEASER.archived():
		if playtest_teaser:
			playtest_teaser.open_archived_still()
		if sfx and sfx.has_method("music_title"):
			sfx.music_title()
		_show_playtest_hub(true)
		return
	if playtest_teaser == null or not _teaser_should_play():
		_show_playtest_hub()
		return
	if playtest_hub:
		playtest_hub.close_hub()
	playtest_teaser.open_teaser(_playtest_teaser_seen())
	_sync_playtest_chrome()


func _playtest_teaser_done() -> void:
	_mark_playtest_teaser_seen()
	if playtest_teaser:
		playtest_teaser.yield_to_hub()
	_show_playtest_hub(true)


func _playtest_teaser_seen() -> bool:
	return bool(_playtest_meta().get("teaser_v1", false))


func _mark_playtest_teaser_seen() -> void:
	_save_playtest_meta({"teaser_v1": true})


func _close_playtest_teaser() -> void:
	if playtest_teaser:
		playtest_teaser.close_teaser()


func _playtest_intro_f2(on: bool) -> void:
	if playtest_feedback == null:
		return
	if on:
		playtest_feedback.set_demo(true)
		playtest_feedback.open_box("", "", "")
		playtest_feedback.z_index = 145
		if playtest_intro:
			playtest_intro.pin_send(playtest_feedback.send_button())
			playtest_intro.pin_panel(playtest_feedback.panel())
	else:
		playtest_feedback.force_close()
		playtest_feedback.z_index = 130


func _playtest_intro_fab(on: bool) -> void:
	if playtest_fab == null:
		return
	playtest_fab.visible = PLAYTEST_FLAG.on() and on
	playtest_fab.z_index = 148 if on else 120
	playtest_fab.mouse_filter = Control.MOUSE_FILTER_IGNORE if on else Control.MOUSE_FILTER_STOP
	_sync_playtest_chrome()


func _playtest_brand_new() -> void:
	if playtest_hub:
		playtest_hub.close_hub()
	_close_playtest_teaser()
	_set_playtest_preset("new")
	_sync_playtest_chrome()
	_dev_fresh_save()


func _playtest_middle() -> void:
	if playtest_hub:
		playtest_hub.close_hub()
	_close_playtest_teaser()
	_set_playtest_preset("middle")
	if settings_ui:
		settings_ui.close_menu()
	if home_cabin:
		home_cabin.stop_story()
	_reset_run()
	_dev_set_buckets(3)
	phase = "title"
	if overlay:
		overlay.visible = false
	if home_cabin:
		home_cabin.items_by_id = items_by_id
		home_cabin.tex_by_item = tex_by_item
		home_cabin.buckets_open = _buckets_revealed
		home_cabin.fill_middle_save()
		_open_home_cabin(false)
		_open_campaign_map()
	_sync_playtest_chrome()
	_refresh()


func _playtest_continue() -> void:
	if playtest_hub:
		playtest_hub.close_hub()
	_close_playtest_teaser()
	if _playtest_preset == "":
		_set_playtest_preset("continue")
	_sync_playtest_chrome()
	_refresh()


func _toggle_playtest_feedback() -> void:
	if playtest_feedback != null and playtest_feedback.visible:
		playtest_feedback.close_box()
		return
	_open_playtest_comment("", "")


func _open_playtest_comment(kind: String, card_id: String) -> void:
	if playtest_intro != null and playtest_intro.visible:
		return
	if playtest_teaser != null and playtest_teaser.visible and not playtest_teaser.holding_still:
		return
	if playtest_feedback == null:
		return
	if playtest_tier != null and playtest_tier.visible:
		playtest_tier.close_list()
	playtest_feedback.open_box(kind, card_id, _playtest_card_name(kind, card_id))


func _open_playtest_tier() -> void:
	if playtest_tier == null:
		return
	if playtest_feedback:
		playtest_feedback.visible = false
	playtest_tier.open_list(items_by_id, monsters_by_id, art, _buckets_revealed)


func _on_playtest_tier_closed() -> void:
	if playtest_feedback == null:
		return
	playtest_feedback.show_again()


func _on_playtest_or_edit(kind: String, card_id: String) -> void:
	if _authoring():
		_open_content_editor(kind, card_id)
		return
	_open_playtest_comment(kind, card_id)


func _on_monster_right_click(card_id: String) -> void:
	if _authoring():
		_open_content_editor("monster", card_id)
		return
	if PLAYTEST_FLAG.on():
		_open_playtest_comment("monster", card_id)


func _on_item_right_click(card_id: String) -> void:
	if _authoring():
		_open_content_editor("item", card_id)
		return
	if PLAYTEST_FLAG.on():
		_open_playtest_comment("item", card_id)


func _on_playtest_note(note: String, kind: String, card_id: String) -> void:
	if playtest_inbox == null:
		return
	playtest_inbox.send(_playtest_payload({
		"kind": kind,
		"card_id": card_id,
		"card_name": _playtest_card_name(kind, card_id),
		"title": _playtest_card_name(kind, card_id) if _playtest_card_name(kind, card_id) != "" else "general",
		"note": note,
		"log": _playtest_log_text(),
	}))


func _on_playtest_ranks(ranks: Dictionary) -> void:
	if playtest_inbox == null:
		return
	playtest_inbox.send(_playtest_payload({
		"kind": "ranks",
		"title": "tier list",
		"note": "",
		"ranks": ranks,
	}))


func _playtest_payload(extra: Dictionary) -> Dictionary:
	var out := {
		"preset": _playtest_preset,
		"when": Time.get_datetime_string_from_system(true, true),
		"build": "%s %s" % [OS.get_name(), Engine.get_architecture_name()],
	}
	if session_log:
		out["session_log"] = session_log.dump()
	for k in extra.keys():
		out[k] = extra[k]
	return out


func _playtest_card_name(kind: String, card_id: String) -> String:
	if card_id == "":
		return ""
	var src: Dictionary = monsters_by_id if kind == "monster" else items_by_id
	return str(src.get(card_id, {}).get("name", card_id))


func _playtest_log_text() -> String:
	if phase != "fighting" and phase != "slaying":
		return ""
	if log_label != null and log_label.has_method("dump_plain"):
		return str(log_label.dump_plain())
	return ""


func _on_playtest_sent(ok: bool, detail: String) -> void:
	if playtest_tier != null and playtest_tier.visible:
		playtest_tier.show_result(ok, detail)
		return
	if playtest_feedback != null:
		playtest_feedback.show_result(ok, detail)


func _playtest_meta() -> Dictionary:
	if not FileAccess.file_exists(PLAYTEST_META_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PLAYTEST_META_PATH))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _save_playtest_meta(patch: Dictionary) -> void:
	var d: Dictionary = _playtest_meta()
	for k in patch.keys():
		d[k] = patch[k]
	var f := FileAccess.open(PLAYTEST_META_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))


func _load_playtest_preset() -> void:
	_playtest_preset = str(_playtest_meta().get("preset", ""))


func _set_playtest_preset(preset: String) -> void:
	_playtest_preset = preset
	_save_playtest_meta({"preset": preset})


func _playtest_intro_seen() -> bool:
	if OS.has_feature("editor"):
		return false
	return bool(_playtest_meta().get("intro_v2", false))


func _mark_playtest_intro_seen() -> void:
	_save_playtest_meta({"intro_v2": true})


func _sync_playtest_chrome() -> void:
	var hub_up: bool = playtest_hub != null and playtest_hub.visible
	var intro_up: bool = playtest_intro != null and playtest_intro.visible
	var teaser_up: bool = playtest_teaser != null and playtest_teaser.visible
	if playtest_fab:
		var cut_up: bool = home_cabin != null and home_cabin.visible and home_cabin.has_method("cutscene_playing") and home_cabin.cutscene_playing()
		var show_fab: bool = PLAYTEST_FLAG.on() and not hub_up and not cut_up and not teaser_up and (not intro_up or playtest_intro.showing_fab())
		playtest_fab.visible = show_fab
	if playtest_voice:
		playtest_voice.visible = PLAYTEST_FLAG.on() and not hub_up and not intro_up and not teaser_up


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
	dst["pool"] = BucketRules.of_card(board_card)
	dst.erase("bucket")
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


func _refresh_offer_card(guard_tier: int = -1) -> void:
	if _offer_card == null or not is_instance_valid(_offer_card):
		_offer_card = null
		return
	if pending_item.is_empty():
		return
	var tier: int = guard_tier if guard_tier >= 1 else _pack_tier_now()
	_dress_showcase_card(_offer_card, pending_item, true, tier)


func _dress_showcase_card(card: Control, it: Dictionary, can_pass: bool, guard_tier: int = -1) -> void:
	if card == null or not is_instance_valid(card) or it.is_empty():
		return
	var view: Dictionary = _item_view(it)
	var rule: Dictionary = _item_rule(it)
	var tier: int = guard_tier if guard_tier >= 1 else _tier_of(it)
	if guard_tier >= 1:
		view["rim"] = _tier_metal(tier)
	if card.has_method("set_title"):
		card.set_title(_title_case(str(it.get("name", "?"))))
	if card.has_method("set_palette"):
		card.set_palette(view["fill"], view["rim"], tier)
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
	if card.has_method("set_glyphs"):
		var pn_offer: int = int(it.get("petrify_n", 0))
		card.set_glyphs([] if pn_offer > 0 else _face_rows(it, view))


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
	if _beggar_pending_intro() or _beggar_intro_running:
		_kick_beggar_intro()
		return
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
	if in_tutorial and tut != null:
		if tut.visible:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_wait", "Hey — finish this first."))
			if sfx:
				sfx.play("error", -12.0)
		return


func _on_slice_right_clicked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		return
	_on_monster_right_click(str(s.get("card_id", "")))


func _on_slice_hovered(index: int) -> void:
	if _cabin_up():
		return
	if _fly_card != null:
		return
	if _deck_hovering:
		return
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
		var mk: String = str(pending_mark.get("kind", ""))
		if mk == "atk_neighbor" or mk == "mark_crossbow" or mk == "mark_poison" or mk == "hook_swap" or mk == "polymorph" or mk == "signpost" or mk == "hypnotize" or mk == "defeat_double_hp" or mk == "sling_any":
			_apply_preview(_preview_mark_aim(mk, index))
		else:
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
	await _maybe_enter_gains(index)
	if not open_next:
		return
	if _empty_count() <= 0:
		_finish_mill()
	else:
		_open_petitioner()


func _place_on(index: int) -> void:
	await _commit_place(index)


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
		if await _try_release_bag():
			_refresh()
			return
		_enter_dungeon_clear()
	_refresh()


func _reseat_slots() -> void:
	for i in range(wheel.size()):
		if i < SLOT_ORDER.size():
			wheel[i]["slot"] = SLOT_ORDER[i]
		else:
			wheel[i]["slot"] = str(i)


func _on_spin() -> void:
	if _beggar_pending_intro() or _beggar_intro_running:
		_kick_beggar_intro()
		return
	_trace_resolve("spin start phase=%s" % phase)
	_session("spin", "spin")
	if phase != "ready":
		return
	if in_tutorial and (tut == null or (tut.wait != "spin" and tut.wait != "auto_spin" and tut.wait != "face")):
		return
	if facing_index >= 0:
		return
	for i in range(wheel.size()):
		if typeof(wheel[i]) == TYPE_DICTIONARY:
			wheel[i]["spin_locked"] = false
			wheel[i]["polymorphed_this_fight"] = false
	_sync_wheel_stats()
	var live: Array[int] = []
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "monster" and int(wheel[i].get("hp", 0)) > 0:
			live.append(i)
	if live.is_empty():
		await _try_release_bag()
		_refresh()
		live.clear()
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
	if OS.has_feature("editor") and has_meta("qa_spin_idx"):
		var forced: int = int(get_meta("qa_spin_idx"))
		remove_meta("qa_spin_idx")
		if pool.find(forced) >= 0:
			idx = forced
	_magnet_pending_consume = ""
	var tut_forced: int = -1
	if in_tutorial:
		tut_forced = _tutorial_spin_index()
		if tut_forced >= 0:
			idx = tut_forced
	var clicked: int = challenge_aim
	var flee_rand: bool = _flee_random_spin
	_flee_random_spin = false
	var tri: Array[int] = []
	if tut_forced < 0:
		tri = _triclops_seats()
	if not tri.is_empty():
		idx = tri[rng.randi_range(0, tri.size() - 1)]
		if adventure and not flee_rand and clicked >= 0 and clicked < wheel.size() and str(wheel[clicked].get("card_id", "")) != "three_seeker":
			await _triclops_sorry(idx)
	elif tut_forced < 0 and flee_rand:
		_challenge_force_spin = false
	elif tut_forced < 0 and _click_choose_fight():
		_challenge_force_spin = false
		if challenge_aim >= 0 and pool.find(challenge_aim) >= 0:
			idx = challenge_aim
	elif tut_forced < 0 and adventure:
		_challenge_force_spin = false
	var mag_mode: String = _armed_magnet_mode()
	if tri.is_empty() and tut_forced < 0 and not adventure and mag_mode != "" and not flee_rand:
		idx = _magnet_pick(pool, mag_mode == "high")
		_magnet_pending_consume = mag_mode
	challenge_aim = -1
	if wheel_view:
		wheel_view.selected_index = -1
	if _undo_inflight:
		# Keep the item snapshot (Bag of Holding, Boot, …). Spinning the next
		# owner is still that same click — Undo must rewind all of it.
		_unspin_armed = false
	elif _click_choose_fight() and adventure and not in_tutorial:
		_undo_stack.append(_capture_run())
		_redo_stack.clear()
		_unspin_armed = true
		_undo_live = {}
	else:
		_undo_wall()
		_unspin_armed = false
	_await_first_spin = false
	phase = "spinning"
	# Drop cached gutter layout — next place after land must run full work.
	_fight_art_sig = ""
	_sprout_begin_exit()
	pending_choice.clear()
	_refresh()
	_log("on_click", "Spin")
	if sfx:
		sfx.set_combat_music(true)
		var spin_m: Dictionary = wheel[idx] if idx >= 0 and idx < wheel.size() else {}
		if not spin_m.is_empty() and _tier_of(spin_m) >= 3 and sfx.has_method("forge_boss_spin"):
			sfx.forge_boss_spin()
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
	if _stone_saved > 0:
		blk = _stone_saved
		_stone_saved = 0
	else:
		blk = 0
	items_used_this_combat = 0
	last_item_atk = 0
	skip_swing_this_fight = false
	keep_blocked_this_fight = false
	pending_feed = {}
	_bell_wait = false
	_cube_line = ""
	_speech_from_index = -1
	_cleric_line = ""
	_cleric_talk_index = -1
	_berserk_line = ""
	_berserk_talk_index = -1
	await _clear_petrify()
	await _tick_gaze_petrify()
	num_items_at_combat = hotbar.size()
	lost_hp_this_combat = false
	enemy_attacked = false
	pending_mark.clear()
	pending_chaos.clear()
	_sync_wheel_stats()
	var m: Dictionary = wheel[facing_index]
	m["spin_locked"] = true
	m["polymorphed_this_fight"] = false
	wheel[facing_index] = m
	last_mob_hp = int(m.get("hp", 3))
	last_mob_atk = maxi(int(m.get("atk", 0)), 0)
	phase = "fighting"
	_walker_busy = true
	_sync_buttons()
	if log_label and log_label.has_method("clear_all"):
		log_label.clear_all()
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
	# Land callout: one sync place now so portrait + plate appear with the seat.
	# Later refreshes still coalesce via dirty flush (#141) — this does not blank
	# the gutter sig, so the deferred flush from `_refresh_face` early-outs.
	if not _spin_holds_fight_art():
		_place_fight_art(true)
	_bleed_begin()
	if cascade_ticker != null:
		cascade_ticker.begin()
	# Player Poison, then this landing's Poison, then Outbreak +1s, then Hex
	# and every other on-spin. Other seats keep their stacks.
	if _living_monster_count() > 0:
		if await _tick_player_poison():
			_undo_arm()
			return
	if await _tick_facing_monster_poison():
		_undo_arm()
		return
	await _apply_plague_doctor_on_spin()
	var beggar_spin: int = -1
	if facing_index >= 0 and facing_index < wheel.size():
		var face_now: Dictionary = wheel[facing_index]
		if str(face_now.get("card_id", "")) == "beggar" and not _is_silenced(face_now) and int(face_now.get("hp", 0)) > 0:
			beggar_spin = facing_index
			_beggar_hold = true
			_beggar_force_discard(facing_index)
	_beggar_hold = false
	if beggar_spin >= 0 and beggar_spin < wheel.size() and str(wheel[beggar_spin].get("card_id", "")) == "beggar" and int(wheel[beggar_spin].get("hp", 0)) > 0 and not _is_silenced(wheel[beggar_spin]):
		await _beggar_assign(beggar_spin, true)
	_sync_plague_poison()
	if _facing_can_act():
		if await _apply_basilisk_gaze():
			await _bleed_end()
			_store_last_faced_hp()
			_undo_arm()
			await _unlock_if_fighting()
			return
	if await _apply_siphon_jars():
		await _bleed_end()
		_store_last_faced_hp()
		_undo_arm()
		await _unlock_if_fighting()
		return
	if await _apply_cursed_scrolls():
		await _bleed_end()
		_store_last_faced_hp()
		_undo_arm()
		await _unlock_if_fighting()
		return
	if _facing_can_act():
		m = wheel[facing_index]
		# Land swing happens before Hex / Rust tick. A countdown is not an item use.
		if str(m.get("card_id", "")) == "harpy" and not _is_silenced(m):
			await _harpy_poke()
			if hp <= 0 or phase != "fighting":
				await _bleed_end()
				await _unlock_if_fighting()
				return
			_walker_busy = true
			_sync_buttons()
			m = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else m
		if str(m.get("card_id", "")) == "gargoyle":
			await _petrify_best_atk()
		elif str(m.get("card_id", "")) == "hydra":
			await _hydra_even_killer()
		await _apply_death_bell_on_spin()
		if await _apply_mouse_scurry():
			await _bleed_end()
			_store_last_faced_hp()
			_undo_arm()
			await _unlock_if_fighting()
			return
		if await _step_hexs():
			await _bleed_end()
			return
	_refresh()
	await _step_berserkers()
	_step_marbles()
	_step_rusts()
	_sync_wheel_stats()
	await _apply_queen_eggs_on_spin()
	if phase == "fighting":
		await _apply_cultist_pacts_on_spin()
	if phase == "fighting":
		await _apply_juggernaut_on_spin()
	if phase == "fighting":
		await _apply_magicat_on_spin()
	if phase == "fighting":
		await _apply_poison_frog_on_spin()
	await _bleed_end()
	if phase == "fighting":
		await _apply_leech_on_spin()
	if phase == "fighting":
		await _cleric_after_spin()
	if phase == "fighting":
		await _zombie_decay_on_spin()
	if phase == "fighting":
		await _fairy_after_spin()
	if phase == "fighting" and _facing_can_act():
		var face_id: String = str(wheel[facing_index].get("card_id", ""))
		if face_id == "gelatinous_cube":
			_cube_ask_feed()
			_refresh()
		elif face_id == "merchant":
			_merchant_ask()
		elif face_id == "hired_hand":
			_hired_ask_bribe()
			_refresh()
		elif face_id == "almighty_worm":
			_worm_ask_hunger()
			_refresh()
	await _flush_poison_sides()
	if phase == "fighting":
		await _apply_scorpion_on_spin()
	if phase == "fighting" and await _sandbag_after_spin():
		return
	if phase == "fighting":
		await _apply_oligarch_on_spin()
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		_undo_stack.append(_capture_run())
		_redo_stack.clear()
		_undo_inflight = false
		_unspin_armed = false
		_store_last_faced_hp()
		_refresh()
		await _begin_slay()
		_undo_arm()
		return
	_store_last_faced_hp()
	_undo_arm()
	await _unlock_if_fighting()
	# Layout is often deferred one frame after Spin lands; re-sync so the
	# intent plate is not left at the pre-layout stage rect (missing on the
	# first fight until a later refresh).
	if phase == "fighting":
		await get_tree().process_frame
		_sync_intent_plate()
		if intent_plate != null and intent_plate.has_method("reanchor"):
			intent_plate.reanchor()
	if in_tutorial and phase == "fighting":
		call_deferred("_tutorial_combat_started")


func _trace_resolve(msg: String) -> void:
	if OS.has_feature("editor"):
		print("[resolve] ", msg)


func _grant_saucer_block() -> bool:
	if _saucer_blk_due <= 0 or phase != "fighting" or hp <= 0:
		return false
	var n: int = _saucer_blk_due
	_saucer_blk_due = 0
	_gain_blk(n)
	_log("blk", "+%s  →  %s" % [n, blk])
	_refresh()
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
		await _begin_slay()
		return true
	return false


func _unlock_if_fighting() -> void:
	if await _grant_saucer_block():
		return
	_release_item_hold()
	if await _flush_vindictive():
		return
	await _flush_midfight_holes()
	if cascade_ticker != null and cascade_ticker.has_method("end"):
		cascade_ticker.end()
	_restore_cascade_time_scale()
	if phase == "fighting" or phase == "ready":
		_walker_busy = false
		_sync_buttons()


func _lock_item_fx() -> void:
	_walker_busy = true
	_sync_buttons()


func _on_done() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not pending_feed.is_empty():
		var feed_kind: String = str(pending_feed.get("kind", ""))
		if feed_kind == "worm_hunger":
			await _continue_worm()
			return
		if feed_kind == "hired_bribe":
			_decline_hired_hand()
			return
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if _wheel_busy() or _walker_busy:
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
	_undo_stack.append(_capture_run())
	_redo_stack.clear()
	_undo_inflight = false
	_unspin_armed = false
	_undo_live = {}
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


func _begin_slay(banner: String = "slay") -> void:
	if _tut_hold_slay:
		## Cube→Shuriken beat: clear the dead Cube, keep Bandit for the next item.
		await _tutorial_clear_held_dead()
		return
	var token: int = _undo_gen
	await _on_owner_defeated(facing_index)
	if _undo_stale(token) or hp <= 0:
		return
	await _flush_poison_sides()
	if _undo_stale(token):
		return
	await _maybe_bell_defeat_tax()
	if _undo_stale(token):
		return
	if await _resolve_toll_death():
		return
	if await _try_phoenix_cycle(facing_index):
		return
	if _undo_stale(token):
		return
	if await _try_triclops_bail(facing_index):
		return
	if await _try_commander_flee(facing_index):
		return
	if _undo_stale(token):
		return
	await _exit_ended(false, banner)


func _exit_ended(clockwork_split: bool = false, banner: String = "slay") -> void:
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	var token: int = _undo_gen
	await _play_ended_visuals(banner)
	if _undo_stale(token):
		return
	await _clear_after_fight(clockwork_split)
	if _undo_stale(token):
		return
	await _maybe_auto_spin()


func _exit_leave(clockwork_split: bool = true) -> void:
	if phase != "fighting" and phase != "slaying":
		return
	if facing_index < 0:
		return
	await _play_leave_visuals()
	await _clear_after_fight(clockwork_split)
	await _maybe_auto_spin()


func _play_ended_visuals(banner: String = "slay") -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	if intent_plate:
		intent_plate.clear()
	_refresh()
	if OS.has_feature("editor") and logic_qa != null and bool(logic_qa.busy):
		return
	if banner == "slay":
		_flash_screen(Color("e8c36a"), 0.32)
		if sfx:
			var dead: Dictionary = wheel[facing_index] if facing_index >= 0 and facing_index < wheel.size() else {}
			var dctx := {"tier": _tier_of(dead) if not dead.is_empty() else 1, "monster_id": str(dead.get("card_id", ""))}
			sfx.play_event(sfx.resolve(&"death", dctx), dctx)
		if combat_stage:
			combat_stage.take_hit()
		if wheel_view and facing_index >= 0:
			await wheel_view.play_slay(facing_index)
	elif banner == "escape":
		if wheel_view and facing_index >= 0:
			await wheel_view.play_escape(facing_index)
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0 and not adventure and not _tutorial_keeps_seat():
		await wheel_view.collapse_slice(facing_index)


func _play_leave_visuals() -> void:
	phase = "slaying"
	pending_choice.clear()
	pending_feed = {}
	if intent_plate:
		intent_plate.clear()
	_refresh()
	if OS.has_feature("editor") and logic_qa != null and bool(logic_qa.busy):
		return
	if combat_stage:
		await combat_stage.vanish()
	if wheel_view and facing_index >= 0 and not adventure and not _tutorial_keeps_seat():
		await wheel_view.collapse_slice(facing_index)


func _resolve_then_continue(skip_attack: bool) -> void:
	if phase != "fighting":
		return
	_trace_resolve("continue skip=%s" % skip_attack)
	if skip_attack or (facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0):
		await _on_owner_defeated(facing_index)
		if hp <= 0:
			return
		await _maybe_bell_defeat_tax()
		if await _try_phoenix_cycle(facing_index):
			return
		if await _try_triclops_bail(facing_index):
			return
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
	if _fungal_stop_fight:
		_fungal_stop_fight = false
		if hp <= 0:
			_player_down()
		return
	if hp <= 0:
		_player_down()
		return
	var still_up: bool = facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) > 0
	var banner := "slay"
	if still_up:
		banner = "escape" if _taken > 0 else "none"
	await _begin_slay(banner)


func _apply_resolve_hits() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	if _blood_threshes(facing_index):
		return await _shark_attack_player(facing_index)
	var m: Dictionary = wheel[facing_index]
	var hits: int = _hit_count(facing_index)
	var total: int = 0
	for h in range(hits):
		if hp <= 0:
			break
		if h > 0:
			await _announce_slice(facing_index, _hub_hp_pos(), hits > 1)
		var incoming: int = await _owner_attack(m, h + 1, hits)
		await _after_self_deconstruct(facing_index)
		if facing_index >= 0 and facing_index < wheel.size():
			m = wheel[facing_index]
		total += incoming
		if _fungal_stop_fight or hp <= 0:
			break
		if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
			break
		if hits > 1 and h < hits - 1:
			if sfx:
				sfx.play_event(&"mon.hornet_buzz")
			await get_tree().create_timer(0.04).timeout
	return total


## Owner Attacks you. Always lunges. Blocked vs unblocked only changes the tell.
## Returns HP lost on this swing.
func _owner_attack(m: Dictionary, hit_n: int = 1, _hit_total: int = 1, src: int = -1) -> int:
	enemy_attacked = true
	var at: int = src if src >= 0 else facing_index
	if at >= 0 and at < wheel.size():
		wheel[at]["has_attacked"] = true
	_trace_resolve("swing %s n=%s" % [str(m.get("card_id", "")), hit_n])
	if combat_stage:
		if sfx:
			sfx.play_event(&"mon.lunge", {"monster_id": str(m.get("card_id", "")), "tier": _tier_of(m)})
		await combat_stage.lunge(hit_n > 1)
		_trace_resolve("lunge done")
	var swing: Dictionary = _swing(m, blk)
	var pierce: bool = bool(swing.get("pierce", false))
	var incoming: int = int(swing["dmg"])
	if intent_plate:
		var fire_i: int = maxi(0, hit_n - 1)
		var blocked_hit: bool = incoming == 0 and not pierce
		var shot_name := ""
		if OS.has_feature("editor") and has_meta("qa_anim_hit_shots"):
			var shots: Variant = get_meta("qa_anim_hit_shots")
			if typeof(shots) == TYPE_DICTIONARY and (shots as Dictionary).has(hit_n):
				shot_name = str((shots as Dictionary)[hit_n])
		var capturer: Callable = Callable()
		if shot_name != "" and has_meta("qa_anim_capture") and get_meta("qa_anim_capture") is Callable:
			capturer = get_meta("qa_anim_capture") as Callable
		# release_early: HP/BLK tell overlaps badge burst (same idea as #142/#143).
		await intent_plate.fire(fire_i, blocked_hit, pierce, shot_name, capturer, true)
	blk = int(swing["blk"])
	hp = maxi(0, hp - incoming)
	if incoming > 0:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
		_note_hp_lost(incoming)
	if pierce:
		_log("on_resolve", "hit %s  ATK %s  (ignores BLK)" % [hit_n, m.get("atk", 0)])
		if at >= 0:
			await _announce_slice(at, _hub_hp_pos())
	else:
		_log("on_resolve", "hit %s  ATK %s − BLK" % [hit_n, m.get("atk", 0)])
		_log("var", "BLK %s" % blk)
	if incoming > 0:
		_log("hp", "take -%s  now %s" % [incoming, hp])
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
	if hp > 0 and incoming > 0 and str(m.get("card_id", "")) == "druid" and not _is_silenced(m):
		await _heal(incoming * 2)
	if incoming > 0 and str(m.get("card_id", "")) == "fungal_colony":
		await _fungal_on_damage(at, m)
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
		_note_hp_lost(incoming)
		_log("hp", "take -%s  now %s" % [incoming, hp])
		_flash_screen(Color("e07a7a"), 0.16)
		_refresh_hearts()
		_refresh_blk(false)
		if sfx:
			sfx.play_event(&"egg.hurt")
		if wheel_view:
			await wheel_view.play_hub_sting("hurt", incoming, true)
		_player_play("hit")
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
			await wheel_view.play_hub_sting("block", 0, true)
		_player_play("block")
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
	_player_play("hit")


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
	_player_play("block")
	if facing_index >= 0 and wheel_view:
		# Stamp snaps readable (~0.2s); hold/fade overlaps the next resolve beat.
		await wheel_view.play_block(facing_index, true)


func _player_down(skip_pose: bool = false) -> void:
	hp = 0
	if not skip_pose:
		if wheel_view and wheel_view.has_method("play_hero"):
			wheel_view.play_hero("death")
		_player_play("defeat")
	if adventure and not in_tutorial:
		_advance_bucket_counter()
	phase = "defeat"
	_log("end", "dead")
	_flash_screen(Color("c45c5c"), 0.28)
	if sfx:
		if sfx.has_method("music_hold_for_undo"):
			sfx.music_hold_for_undo()
		sfx.set_combat_music(false)
		sfx.play("error_big", -6.0)
		sfx.play_event(&"sting.defeat")
		sfx.music_defeat()
	if combat_stage:
		combat_stage.hide_stage()
	if player_stage:
		player_stage.hide_stage()
	_hide_hypno()
	_discard_spent_items()
	facing_index = -1
	_refresh()


func _clear_after_fight(_clockwork_split: bool = false) -> void:
	var token: int = _undo_gen
	if adventure:
		await _challenge_after_fight()
		return
	if _undo_stale(token):
		return
	if facing_index < 0 or facing_index >= wheel.size():
		_trace_resolve("clear abort facing=%s n=%s" % [facing_index, wheel.size()])
		return
	var m: Dictionary = wheel[facing_index]
	var left_id: String = str(m.get("card_id", ""))
	_trace_resolve("clear start left=%s n=%s" % [left_id, wheel.size()])
	if _tutorial_keeps_seat():
		await _tutorial_replace_with_deck(facing_index, "bandit")
		facing_index = -1
	else:
		await _wick_on_defeated(facing_index)
		await _remove_crossbowed()
		_trace_resolve("clear after crossbow n=%s" % wheel.size())
		if left_id == "mimic" and not enemy_attacked:
			await _grant_mimic_gift()
		if _install_laid_egg(facing_index):
			facing_index = -1
		else:
			_remove_facing()
	_trace_resolve("clear after remove n=%s" % wheel.size())
	_discard_spent_items()
	_bank_stone_wall()
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
		if await _try_release_bag():
			_refresh()
			await _maybe_auto_spin()
			_walker_busy = false
			_trace_resolve("clear done")
			if in_tutorial:
				call_deferred("_tutorial_after_fight")
			return
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
	if phase == "devtest":
		return
	if _qa_busy() and not _is_adventure_mode():
		return
	if _await_first_spin:
		return
	if phase != "ready":
		return
	if _drink_hp_due:
		_drink_hp_due = false
		if await _bleed(1):
			return
		if phase != "ready":
			return
	if _monsters_left() <= 0:
		return
	_trace_resolve("auto-spin wait n=%s" % _monsters_left())
	# One process frame so hotbar/layout from the draft commit paints; no 0.15s
	# dead air between draft confirm and Spin (feel D).
	await get_tree().process_frame
	if _qa_busy() and not _is_adventure_mode():
		return
	_trace_resolve("auto-spin after settle phase=%s" % phase)
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
	_discard_unused_decay()
	var kept: Array = []
	var failed_keep: Array = []
	for it in hotbar:
		if it["spent"] and not it["keep_after"]:
			_log("discard", str(it["name"]))
			continue
		if it["spent"] and it["keep_after"]:
			if keep_blocked_this_fight:
				_log("discard", str(it["name"]))
				failed_keep.append((it as Dictionary).duplicate(true))
				continue
			if str(it.get("card_id", "")) == "breastplate" and not lost_hp_this_combat:
				_log("discard", str(it["name"]))
				failed_keep.append((it as Dictionary).duplicate(true))
				continue
			it["spent"] = false
			it["keep_after"] = false
			_log("keep", str(it["name"]))
		kept.append(it)
	hotbar = kept
	_hotbar_sig = ""
	for snap in failed_keep:
		_recycle_after_gone(snap)


func _undo_dup(v: Variant) -> Variant:
	if typeof(v) == TYPE_DICTIONARY:
		return (v as Dictionary).duplicate(true)
	if typeof(v) == TYPE_ARRAY:
		return (v as Array).duplicate(true)
	return v


func _capture_run() -> Dictionary:
	return {
		"hp": hp,
		"player_poison": player_poison,
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
		"last_hp_lost": last_hp_lost,
		"stone_saved": _stone_saved,
		"stone_armed": _stone_armed,
		"saucer_blk_due": _saucer_blk_due,
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
		"pending_item_flee": _pending_item_flee,
		"hypno_src": _hypno_src,
		"watch_portrait": _watch_portrait,
		"cube_line": _cube_line,
		"speech_from_index": _speech_from_index,
		"dungeons_ended": _dungeons_ended,
		"buckets_revealed": _buckets_revealed,
		"guarantee_bucket": _guarantee_bucket,
		"item_pool": item_pool.duplicate(true),
		"monster_pool": monster_pool.duplicate(true),
		"dungeons_cleared": dungeons_cleared,
		"dungeon_index": dungeon_index,
		"challenge_deck": challenge_deck.duplicate(true),
		"challenge_aim": challenge_aim,
		"await_first_spin": _await_first_spin,
		"adventure_seat_tiers": adventure_seat_tiers.duplicate(true),
		"moves_left": moves_left,
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
	if _unspin_armed:
		_unspin_armed = false
		_undo_stack.clear()
		_redo_stack.clear()
		_undo_live = _capture_run()
	if _undo_live.is_empty():
		_undo_live = _capture_run()
	_undo_inflight = true
	_sync_buttons()


func _undo_abort() -> void:
	_sling_aim = -1
	_skip_item_use_count = false
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
	_move_busy = false
	_flushing_holes = false
	if wheel_view != null:
		if wheel_view.has_method("kill_spin"):
			wheel_view.kill_spin()
		wheel_view.busy = false
	if combat_stage != null:
		combat_stage.busy = false
	if ability_slash != null and ability_slash.has_method("abort_all"):
		ability_slash.abort_all()
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


func _abort_open_loot() -> void:
	_loot_epoch += 1
	_challenge_loot_wait = false
	_challenge_pending_gain = {}
	_challenge_pair.clear()
	if challenge_draft_ui:
		challenge_draft_ui.hide_draft()


func _clear_fx_banners() -> void:
	if play_field == null:
		return
	for child in play_field.get_children():
		if child != null and child.has_meta("fx_banner"):
			child.queue_free()


func _restore_run(snap: Dictionary) -> void:
	if snap.is_empty():
		return
	var undoing_defeat: bool = phase == "defeat"
	_undo_gen += 1
	_abort_open_loot()
	_undo_kill_motion()
	_clear_fx_banners()
	hp = int(snap.get("hp", hp))
	player_poison = int(snap.get("player_poison", player_poison))
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
	last_hp_lost = int(snap.get("last_hp_lost", last_hp_lost))
	_stone_saved = int(snap.get("stone_saved", _stone_saved))
	_stone_armed = bool(snap.get("stone_armed", _stone_armed))
	_saucer_blk_due = int(snap.get("saucer_blk_due", 0))
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
	_pending_item_flee = bool(snap.get("pending_item_flee", false))
	_hypno_src = int(snap.get("hypno_src", -1))
	_watch_portrait = int(snap.get("watch_portrait", -1))
	_cube_line = str(snap.get("cube_line", ""))
	_speech_from_index = int(snap.get("speech_from_index", -1))
	_dungeons_ended = int(snap.get("dungeons_ended", _dungeons_ended))
	_buckets_revealed = int(snap.get("buckets_revealed", _buckets_revealed))
	_guarantee_bucket = int(snap.get("guarantee_bucket", _guarantee_bucket))
	item_pool = _undo_dup(snap.get("item_pool", item_pool))
	monster_pool = _undo_dup(snap.get("monster_pool", monster_pool))
	dungeons_cleared = int(snap.get("dungeons_cleared", dungeons_cleared))
	dungeon_index = int(snap.get("dungeon_index", dungeon_index))
	challenge_deck = _undo_dup(snap.get("challenge_deck", challenge_deck))
	challenge_aim = int(snap.get("challenge_aim", challenge_aim))
	_await_first_spin = bool(snap.get("await_first_spin", _await_first_spin))
	adventure_seat_tiers = _undo_dup(snap.get("adventure_seat_tiers", adventure_seat_tiers))
	moves_left = int(snap.get("moves_left", moves_left))
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
	var kept_portrait: int = _watch_portrait
	if _hypno_src >= 0:
		_show_hypno(_hypno_src)
	else:
		_hide_hypno()
	_watch_portrait = kept_portrait
	if combat_stage:
		if (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size():
			_show_fight_portrait()
		else:
			combat_stage.hide_stage()
			if player_stage:
				player_stage.hide_stage()
	if wheel_view and wheel_view.has_method("snap_to_index") and facing_index >= 0:
		wheel_view.snap_to_index(facing_index)
	if sfx:
		var want_combat: bool = phase == "fighting" or phase == "slaying"
		if undoing_defeat and sfx.has_method("music_resume_held"):
			sfx.music_resume_held(want_combat)
		else:
			sfx.set_combat_music(want_combat)
	_refresh()


func _undo_play_fx(is_redo: bool) -> void:
	_flash_screen(Color("c4a574") if is_redo else Color("6bb3d9"), 0.22)
	if sfx:
		sfx.play("whoosh", -10.0, 1.2 if is_redo else 0.72)
		sfx.play("click2", -12.0)
	_apply_sai_static()


func _on_undo() -> void:
	if in_tutorial or _undo_busy:
		return
	_undo_busy = true
	_session("undo", "Undo")
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
	_session("undo", "Redo")
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
	if not pending_feed.is_empty():
		var allowed: Array = pending_feed.get("uids", [])
		if not allowed.has(uid):
			if sfx:
				sfx.play("error", -12.0, 1.2)
			return
		await _feed_cube(uid)
		_undo_arm()
		return
	if _walker_busy:
		return
	var it_pre: Dictionary = _find_item(uid)
	var magnet_ready: bool = phase == "ready" and _is_magnet(it_pre)
	if not magnet_ready and (phase != "fighting" or facing_index < 0):
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
	if _item_stoned(it):
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
	if str(pending_mark.get("kind", "")) == "sling_any":
		## Sling is waiting for a monster. Do not let Longbow / Great Axe fire their native aim.
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	if not pending_choice.is_empty():
		var chooser: Dictionary = _find_item(int(pending_choice.get("uid", -1)))
		if str(_ops_of(chooser).get("kind", "")) == "sling" or str(chooser.get("card_id", "")) == "sling":
			if uid == int(chooser.get("uid", -1)):
				return
			for opt_v in pending_choice.get("options", []):
				if typeof(opt_v) != TYPE_DICTIONARY:
					continue
				var opt: Dictionary = opt_v
				if int(opt.get("atk_uid", -1)) == uid:
					await _choose_option(opt)
					return
			if sfx:
				sfx.play("error", -12.0, 1.2)
			return
	if sfx:
		sfx.play("select", -10.0)
	pending_mark.clear()
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind == "passive" or kind == "toll" or kind == "hex" or kind == "recycle_watch" or kind == "rust_watch":
		if sfx:
			sfx.play("error", -12.0, 1.2)
		return
	_undo_begin()
	var token: int = _undo_gen
	if kind == "sling":
		var sling_opts: Array = _sling_attack_options(uid)
		if sling_opts.is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			_undo_abort()
			return
		pending_choice = {"uid": uid, "options": sling_opts}
		_log_begin_item(it)
		_log("on_item_use", "%s — choose" % str(it.get("name", "?")))
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
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
		_log_begin_item(it)
		_log("on_item_use", "%s — choose" % str(it.get("name", "?")))
		if sfx:
			sfx.play("question", -10.0)
		call_deferred("_refresh")
		return
	if kind == "mark_poison" or kind == "mark_crossbow" or kind == "atk_neighbor" or kind == "hook_swap" or kind == "hypnotize" or kind == "defeat_double_hp" or kind == "polymorph" or kind == "signpost":
		if _mark_targets(kind).is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			_undo_abort()
			return
		if kind == "signpost":
			_gain_blk(7)
			_log("on_item_use", str(it.get("name", "Signpost")))
			_log("blk", "+%s  →  %s" % [7, blk])
		pending_mark = {"uid": uid, "kind": kind}
		_log("on_item_use", "pick who attacks across" if kind == "hypnotize" else ("pick a monster" if kind == "defeat_double_hp" or kind == "sling_any" or kind == "hook_swap" else "pick a neighbor"))
		_loud_mark_prompt(kind)
		call_deferred("_refresh")
		return
	if kind == "chaos_reroll":
		await _begin_chaos(uid)
		if pending_chaos.is_empty():
			_undo_abort()
		return
	_bleed_begin()
	_lock_item_fx()
	_arm_item_hold()
	_beggar_hold = true
	await _apply_ops(it, ops, {})
	if _undo_stale(token):
		_beggar_hold = false
		await _unlock_if_fighting()
		return
	await _after_item_resolved(it)
	if _undo_stale(token):
		await _unlock_if_fighting()
		return
	await _bleed_end()
	if _undo_stale(token):
		await _unlock_if_fighting()
		return
	if in_tutorial:
		_tutorial_item_used(str(it.get("card_id", "")))
	_undo_finish_item()
	await _unlock_if_fighting()
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
	if str(_ops_of(it).get("kind", "")) == "sling" or str(it.get("card_id", "")) == "sling":
		var atk_uid: int = int(opt.get("atk_uid", -1))
		if _mark_targets("sling_any").is_empty():
			_log("on_item_use", "cannot")
			if sfx:
				sfx.play("error", -10.0)
			_undo_abort()
			call_deferred("_refresh")
			return
		pending_mark = {"uid": int(it.get("uid", -1)), "kind": "sling_any", "atk_uid": atk_uid}
		_log("on_item_use", "pick a monster")
		_loud_mark_prompt("sling_any")
		call_deferred("_refresh")
		return
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
	_lock_item_fx()
	_arm_item_hold()
	if int(opt.get("atk_drop", 0)) > 0:
		await _apply_ops(it, {"kind": "atk_drop", "n": int(opt.get("atk_drop", 0))}, opt)
	elif int(opt.get("blk", 0)) > 0:
		await _apply_ops(it, {"kind": "blk", "n": int(opt.get("blk", 0))}, opt)
	else:
		await _apply_ops(it, {"kind": "atk", "n": int(opt.get("atk", 0))}, opt)
	if _undo_stale(token):
		await _unlock_if_fighting()
		return
	await _after_item_resolved(it)
	if _undo_stale(token):
		await _unlock_if_fighting()
		return
	await _bleed_end()
	if _undo_stale(token):
		await _unlock_if_fighting()
		return
	if sfx:
		sfx.play("click2", -8.0)
	_undo_finish_item()
	await _unlock_if_fighting()
	call_deferred("_refresh")


func _ops_of(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) == "echo_bell":
		var copy: Dictionary = _echo_face(it)
		if not copy.is_empty():
			var cops: Variant = copy.get("ops", {})
			if typeof(cops) == TYPE_DICTIONARY and not (cops as Dictionary).is_empty():
				return (cops as Dictionary).duplicate(true)
	var ops: Dictionary = it.get("ops", {})
	var id: String = str(it.get("card_id", ""))
	if id == "jar_o_grease":
		return {"kind": "move2_keep", "n": 2}
	if ops.is_empty() or str(ops.get("kind", "")).strip_edges() == "":
		if ITEM_OPS.has(id):
			return (ITEM_OPS[id] as Dictionary).duplicate(true)
	return ops


func _apply_ops(it: Dictionary, ops: Dictionary, extra: Dictionary) -> void:
	last_atk_index = -1
	last_atk_line = ""
	var m: Dictionary = wheel[facing_index]
	var kind: String = str(ops.get("kind", ""))
	if kind == "move2_keep" and not _jar_can_move():
		_log_begin_item(it)
		_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		return
	var view: Dictionary = _item_view(it)
	var chakram_h: Dictionary = _chakram_halves(it) if kind == "chakram" else {}
	if kind.begins_with("atk") and kind != "atk_zero" and kind != "atk_drop":
		_hero_swipe_armed = true
	elif kind == "chakram" and bool(chakram_h.get("atk", false)):
		_hero_swipe_armed = true
	elif kind == "shield_alt" and _shield_face(it) == "atk":
		_hero_swipe_armed = true
	elif not kind.begins_with("atk"):
		_player_play("use")
	var fx_at: Vector2 = _item_fx_dest(kind)
	if kind == "chakram":
		fx_at = _slice_hp_pos(facing_index) if bool(chakram_h.get("atk", false)) else _hub_blk_pos()
	elif kind == "shield_alt" and _shield_face(it) == "atk":
		fx_at = _slice_hp_pos(facing_index)
	await _announce_item_use(it, fx_at)
	if str(it.get("card_id", "")) == "miasma" or kind == "miasma":
		await _use_miasma(it)
		return
	if str(it.get("card_id", "")) == "echo_bell":
		if sfx:
			sfx.play_event(&"chaos.echo_bell")
		if get_tree():
			await get_tree().create_timer(0.09).timeout
	match kind:
		"shield_alt":
			if _shield_face(it) == "atk":
				var sn: int = 3
				last_item_atk = sn
				var shield_ended: bool = await _deal_atk(sn)
				if not shield_ended:
					_log("on_item_use", str(it["name"]))
					_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [sn, wheel[facing_index]["hp"]])
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				if shield_ended:
					return
				_sync_wheel_stats()
				if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
					if not _wick_waiting(facing_index):
						await _begin_slay()
				return
			var shield_gain: int = _gain_blk(3)
			_log("on_item_use", str(it["name"]))
			_log("blk", "+%s  →  %s" % [shield_gain, blk])
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_from_atk", "blk_even_keep", "blk_from_highest_atk", "blk_half_atk", "blk_coin_keep":
			var n: int = int(view.get("n", ops.get("n", 0)))
			if kind == "blk_coin_keep":
				if randi_range(0, 1) == 0:
					n = int(ops.get("lo", 2))
					it["_coin_bleed"] = 0
				else:
					n = int(ops.get("hi", 6))
					it["_coin_bleed"] = int(ops.get("hp", 2))
			if kind == "blk_half_atk" and not bool(view.get("can_use", false)):
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "blk_neighbor" and n < 0:
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "blk_from_hp" and n <= 0:
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			var gained: int = _gain_blk(maxi(0, n))
			_log("on_item_use", str(it["name"]))
			var shown_blk: int = gained if kind == "blk_coin_keep" else maxi(0, n)
			_log("blk", "+%s  →  %s" % [shown_blk, blk])
		"atk_move":
			await _shift_facing(-1, false)
			var n_mv: int = int(ops.get("n", 3))
			last_item_atk = n_mv
			var move_ended: bool = await _deal_atk(n_mv)
			if not move_ended:
				_log("on_item_use", str(it["name"]))
				_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n_mv, wheel[facing_index]["hp"]])
			it["spent"] = true
			it["keep_after"] = false
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			if move_ended:
				return
			_sync_wheel_stats()
			if last_atk_index >= 0 and last_atk_index != facing_index and last_atk_index < wheel.size():
				if int(wheel[last_atk_index].get("hp", 0)) <= 0 and not _wick_waiting(last_atk_index):
					await _maybe_slay_down(last_atk_index)
			if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
				if not _wick_waiting(facing_index):
					await _begin_slay()
			return
		"atk_flee_keep":
			var n_shuri: int = int(ops["n"]) if ops.has("n") else int(view.get("n", 2))
			last_item_atk = n_shuri
			if await _deal_atk(n_shuri):
				it["spent"] = true
				it["keep_after"] = hp > 0
				await _count_item_use()
				_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
				return
			_log("on_item_use", str(it["name"]))
			var live_hp: int = int(wheel[facing_index].get("hp", 0)) if facing_index >= 0 and facing_index < wheel.size() else 0
			_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n_shuri, live_hp])
			it["spent"] = true
			if live_hp <= 0:
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				_sync_wheel_stats()
				if facing_index >= 0 and not _wick_waiting(facing_index):
					await _begin_slay()
				return
			if last_atk_index >= 0 and last_atk_index != facing_index and last_atk_index < wheel.size():
				if int(wheel[last_atk_index].get("hp", 0)) <= 0 and not _wick_waiting(last_atk_index):
					await _maybe_slay_down(last_atk_index)
			it["keep_after"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), true)
			if last_atk_index == facing_index or _sling_aim < 0:
				_pending_item_flee = true
			return
		"flee_then_blk":
			if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			var saucer_n: int = int(ops.get("n", view.get("n", 5)))
			_log("on_item_use", str(it["name"]))
			it["spent"] = true
			it["keep_after"] = false
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
				await _begin_slay()
				return
			var saucer_fled: bool = await _flee_spin()
			if not saucer_fled:
				_gain_blk(saucer_n)
				_log("blk", "+%s  →  %s" % [saucer_n, blk])
				if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0 and not _wick_waiting(facing_index):
					await _begin_slay()
					return
				_refresh()
				return
			if hp <= 0 or _monsters_left() <= 0:
				_saucer_blk_due = 0
				return
			_saucer_blk_due = saucer_n
			_refresh()
			return
		"player_flee_keep":
			if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			_log("on_item_use", str(it["name"]))
			it["spent"] = true
			it["keep_after"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), true)
			var fled: bool = await _flee_spin()
			if not fled:
				_drink_hp_due = false
				it["spent"] = false
				it["keep_after"] = false
				phase = "fighting"
				_walker_busy = false
				if await _bleed(1):
					return
				_refresh()
				return
			if in_tutorial:
				_drink_hp_due = false
				if await _bleed(1):
					return
			else:
				_drink_hp_due = true
			_refresh()
			return
		"atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_2_kills", "atk_hp_loss", "atk_last", "atk_strong_neighbor", "atk_wheel", "atk_echo":
			var n2: int = int(ops["n"]) if ops.has("n") else int(view.get("n", 0))
			if kind == "atk_echo" and n2 <= 0:
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "atk_last" and n2 <= 0:
				_log_begin_item(it)
				_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
				if sfx:
					sfx.play("error", -10.0)
				return
			if kind == "atk_strong_neighbor" and n2 < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			last_item_atk = n2
			var atk_ended: bool = await _deal_atk(n2)
			if not atk_ended:
				_log("on_item_use", str(it["name"]))
				_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n2, wheel[facing_index]["hp"]])
			if _is_arrow_head(it) or str(it.get("card_id", "")) == "arrow_head":
				if await _bleed(2):
					it["spent"] = true
					if str(it.get("card_id", "")) == "echo_bell":
						it["keep_after"] = false
					await _count_item_use()
					_toss_item(int(it["uid"]), false)
					return
			elif atk_ended:
				it["spent"] = true
				if extra.has("keep"):
					it["keep_after"] = bool(extra["keep"])
				if str(it.get("card_id", "")) == "echo_bell":
					it["keep_after"] = false
				await _count_item_use()
				_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
				return
			if atk_ended:
				it["spent"] = true
				if str(it.get("card_id", "")) == "echo_bell":
					it["keep_after"] = false
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
		"atk_cleave":
			if await _apply_cleave(int(ops.get("n", 2))):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			_log("on_item_use", str(it["name"]))
		"atk_opposite":
			var opp: int = _sling_aim if _sling_aim >= 0 else _opposite_index()
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
		"heal_poison":
			_log("on_item_use", str(it["name"]))
			await _heal(int(ops.get("heal", 5)))
			_gain_player_poison(int(ops.get("poison", 2)))
		"heal":
			_log("on_item_use", str(it["name"]))
			await _heal(int(ops.get("n", 2)))
		"heal_both_draw":
			_log("on_item_use", str(it["name"]))
			var both_n: int = int(ops.get("heal", 3))
			await _heal(both_n)
			if facing_index >= 0 and facing_index < wheel.size():
				var ale_face: Dictionary = wheel[facing_index]
				if str(ale_face.get("kind", "")) == "monster" and int(ale_face.get("hp", 0)) > 0:
					_heal_monster(facing_index, both_n)
			_draw_unseen_item()
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
			_walker_busy = false
			_challenge_force_spin = true
			if combat_stage:
				combat_stage.hide_stage()
			if player_stage:
				player_stage.hide_stage()
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
			var lantern_n: int = maxi(1, int(ops.get("n", 1)))
			_log("on_item_use", str(it["name"]))
			await _heal(lantern_n)
			var lantern_stays: bool = hp < HP_MAX and not _keep_blocked_now()
			it["keep_after"] = hp < HP_MAX
			if lantern_stays and str(it.get("card_id", "")) == "lantern":
				_lantern_set_n(it, lantern_n + 1)
		"move2_keep":
			if await _jar_slide_two(it):
				return
			return
		"heal_swap_keep":
			var jar_n: int = int(ops.get("n", 2))
			_log("on_item_use", str(it["name"]))
			await _heal(jar_n)
			it["spent"] = true
			it["keep_after"] = false
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
		"blood_pact":
			_log("on_item_use", str(it["name"]))
			if facing_index >= 0 and facing_index < wheel.size():
				await _chip_hp(facing_index, int(ops.get("n", 2)))
			if await _bleed(int(ops.get("n", 2))):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				await _maybe_slay_down(facing_index)
				return
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
			_mark_silenced(m, true)
			wheel[facing_index] = m
			if qid == "zombie":
				keep_blocked_this_fight = false
				_decay_clear_all()
			if qid == "beggar":
				m["beggar_mark"] = -1
				wheel[facing_index] = m
			if qid == "kobold_trapper":
				_trapper_clear_marks(int(m.get("seat_uid", -1)))
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
			if _undying(m):
				_log("on_item_use", str(it["name"]))
				_log("on_resolve", "undying")
				await _lich_keep_defeat_item(it)
				if await _lich_chip_defeat(facing_index):
					await _begin_slay()
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
			if _undying(m):
				await _owner_attack(m)
				if hp <= 0:
					it["spent"] = true
					await _count_item_use()
					_toss_item(int(it["uid"]), false)
					_player_down()
					return
				_log("on_resolve", "undying")
				await _lich_keep_defeat_item(it)
				var lich_down: bool = await _lich_chip_defeat(facing_index)
				await _heal(stored)
				if lich_down:
					await _begin_slay()
				return
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
			if _undying(m):
				_log("on_item_use", str(it["name"]))
				_log("on_resolve", "undying")
				await _lich_keep_defeat_item(it)
				if await _lich_chip_defeat(facing_index):
					await _begin_slay()
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
		"orb":
			await _use_orb(it)
			return
		"bag_hold":
			await _use_bag_hold(it)
			return
		"defeat_atk":
			if _defeat_blocked(m):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
					sfx.play("metal_latch", -14.0)
				return
			if int(m["atk"]) < 6:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			if _undying(m):
				_log("on_item_use", str(it["name"]))
				_log("on_resolve", "undying")
				await _lich_keep_defeat_item(it)
				if await _lich_chip_defeat(facing_index):
					await _begin_slay()
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
		"heal_last_loss":
			if last_hp_lost <= 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			_log("on_item_use", str(it["name"]))
			await _heal(last_hp_lost)
		"pacemaker_use":
			_log("on_item_use", str(it["name"]))
			if await _bleed(2):
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
		"eject_draw":
			if not adventure or facing_index < 0:
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			it["spent"] = true
			await _count_item_use()
			_log("on_item_use", str(it["name"]))
			_toss_item(int(it["uid"]), false)
			await _apply_catapult()
			return
		"napalm":
			_log("on_item_use", str(it["name"]))
			if await _apply_napalm():
				it["spent"] = true
				await _count_item_use()
				_toss_item(int(it["uid"]), false)
				return
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it["uid"]), false)
			_sync_wheel_stats()
			if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
				if not _wick_waiting(facing_index):
					await _begin_slay()
			return
		"miasma":
			await _use_miasma(it)
			return
		"bag_marbles":
			await _apply_bag_marbles(it)
			return
		"marble":
			if await _apply_marble(it):
				return
		"chakram":
			var chak_h: Dictionary = _chakram_halves(it)
			if not bool(chak_h.get("blk", false)) and not bool(chak_h.get("atk", false)):
				_log("on_item_use", "cannot")
				if sfx:
					sfx.play("error", -10.0)
				return
			if await _apply_chakram(it):
				return
		_:
			return
	it["spent"] = true
	if str(it.get("card_id", "")) == "stone_wall":
		_stone_armed = true
	if extra.has("keep"):
		it["keep_after"] = bool(extra["keep"])
	elif kind == "blk_keep" or kind == "atk_spend_blk":
		it["keep_after"] = true
	elif kind == "blk_even_keep":
		it["keep_after"] = (blk % 2 == 0)
	elif kind == "blk_coin_keep":
		it["keep_after"] = true
	if str(it.get("card_id", "")) == "echo_bell":
		it["keep_after"] = false
	var coin_bleed: int = int(it.get("_coin_bleed", 0))
	if it.has("_coin_bleed"):
		it.erase("_coin_bleed")
	if coin_bleed > 0 and await _bleed(coin_bleed):
		await _count_item_use()
		_toss_item(int(it["uid"]), bool(it.get("keep_after", false)))
		return
	await _count_item_use()
	var kept_now: bool = bool(it.get("keep_after", false))
	if kept_now:
		_toss_item(int(it["uid"]), true)
	elif kind == "heal_keep" or kind == "blk_even_keep":
		_discard_from_hand(int(it["uid"]))
	else:
		_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()
	if last_atk_index >= 0 and last_atk_index != facing_index and last_atk_index < wheel.size():
		if int(wheel[last_atk_index].get("hp", 0)) <= 0 and not _wick_waiting(last_atk_index):
			await _maybe_slay_down(last_atk_index)
	if facing_index >= 0 and int(wheel[facing_index].get("hp", 0)) <= 0:
		if not _wick_waiting(facing_index):
			await _begin_slay()


func _trapper_phase_ok() -> bool:
	return phase == "ready" or phase == "fighting" or phase == "devtest"


func _trapper_mark_newcomers() -> void:
	if not _trapper_phase_ok():
		return
	var changed := false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "kobold_trapper":
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		if bool(wheel[i].get("trapper_entered", false)):
			continue
		wheel[i]["trapper_entered"] = true
		changed = true
		var pool: Array = []
		for j in wheel.size():
			if j == i:
				continue
			if typeof(wheel[j]) != TYPE_DICTIONARY:
				continue
			if str(wheel[j].get("kind", "")) != "monster":
				continue
			if int(wheel[j].get("hp", 0)) <= 0:
				continue
			if bool(wheel[j].get("hunter_mark", false)):
				continue
			pool.append(j)
		var take: int = mini(2, pool.size())
		for _n in take:
			if pool.is_empty():
				break
			var pick: int = rng.randi_range(0, pool.size() - 1)
			var j2: int = int(pool[pick])
			pool.remove_at(pick)
			wheel[j2]["hunter_mark"] = true
			wheel[j2]["marked_by"] = int(wheel[i].get("seat_uid", -1))
			_log("on_resolve", "Marked %s" % str(wheel[j2].get("name", "?")))
	if changed and wheel_view:
		wheel_view.queue_redraw()


func _trapper_clear_marks(seat_uid: int) -> void:
	if seat_uid < 0:
		return
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if int(wheel[i].get("marked_by", -1)) != seat_uid:
			continue
		wheel[i]["hunter_mark"] = false
		wheel[i]["marked_by"] = -1


func _grant_trapper_growth(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	s["trapper_growth"] = int(s.get("trapper_growth", 0)) + 2
	wheel[index] = s
	_apply_formulas_to(s)
	wheel[index] = s
	_log("on_resolve", "Trapper +2 HP +2 ATK → %s / %s" % [int(s.get("hp", 0)), int(s.get("atk", 0))])
	if wheel_view:
		wheel_view.hit_feedback(index, -2, 2)


func _trapper_pay_marked(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if not bool(wheel[index].get("hunter_mark", false)):
		return
	wheel[index]["hunter_mark"] = false
	wheel[index]["marked_by"] = -1
	for i in wheel.size():
		if i == index:
			continue
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if str(wheel[i].get("card_id", "")) != "kobold_trapper":
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		if _is_silenced(wheel[i]):
			continue
		_grant_trapper_growth(i)


func _on_owner_defeated(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return
	if bool(m.get("defeat_rewards_done", false)):
		return
	m["defeat_rewards_done"] = true
	wheel[index] = m
	_trapper_pay_marked(index)
	m = wheel[index]
	var cid: String = str(m.get("card_id", ""))
	var quiet: bool = _is_silenced(m)
	if cid == "phoenix" and P1.phoenix_lays_egg(bool(m.get("has_attacked", false)), quiet):
		if not bool(m.get("egg_laid", false)):
			m["egg_laid"] = true
			wheel[index] = m
			_lay_phoenix_egg()
	elif cid == "wraith" and not quiet:
		await _apply_lifelink(m)
		if hp <= 0:
			return
	elif cid == "martyr" and SP_DALLAS.martyr_dies_on_defeat(
		int(m.get("hp", 0)), quiet, bool(m.get("noble_death_done", false))
	):
		## SP-24: Defeat while still holding HP gifts remaining HP to neighbors.
		await _martyr_gift_neighbors(index)


func _lay_phoenix_egg() -> void:
	if not monsters_by_id.has("phoenix_egg"):
		return
	challenge_deck.push_front("phoenix_egg")
	if dungeon_deck_ui:
		dungeon_deck_ui.visible = true
		dungeon_deck_ui.set_count(challenge_deck.size())
	_log("on_resolve", "Phoenix Egg on top of the Dungeon Deck")


## Mill has no hole fill. Pop the egg we just put on top and seat it here.
## Challenge and Adventure leave it for the normal draw.
func _install_laid_egg(index: int) -> bool:
	if adventure:
		return false
	if index < 0 or index >= wheel.size():
		return false
	if not bool(wheel[index].get("egg_laid", false)):
		return false
	if challenge_deck.is_empty() or _deck_card_id(challenge_deck[0]) != "phoenix_egg":
		return false
	challenge_deck.pop_front()
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(challenge_deck.size())
	var egg: Dictionary = _make_monster("phoenix_egg")
	egg["slot"] = str(wheel[index].get("slot", ""))
	wheel[index] = egg
	_reseat_slots()
	_log("on_resolve", "Phoenix Egg")
	return true


func _apply_lifelink(m: Dictionary) -> void:
	var cur: int = int(m.get("hp", 0))
	var has_pre: bool = m.has("hp_pre_hit")
	var died: bool = cur <= 0 and has_pre
	var pre: int = int(m.get("hp_pre_hit", cur))
	var source: int = P1.lifelink_hp(cur, pre, died)
	var change: Dictionary = P1.lifelink_change(hp, source, HP_MAX)
	_log("on_resolve", "Lifelink %s" % source)
	var kind: String = str(change.get("kind", "none"))
	if kind == "heal":
		await _heal(int(change.get("n", 0)))
	elif kind == "bleed":
		await _bleed(int(change.get("n", 0)))


func _gain_token_item(id: String) -> void:
	if not items_by_id.has(id):
		return
	var it: Dictionary = _make_item(id)
	if adventure and _hand_full():
		_start_full_hand_replace(it)
		return
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	if sfx:
		sfx.play("open", -10.0)
	_hotbar_sig = ""
	_refresh()


func _item_has_keep(it: Dictionary) -> bool:
	var id: String = str(it.get("card_id", ""))
	if id == "throwing_knife" or id == "iron_chain":
		return true
	var kind: String = str(_ops_of(it).get("kind", ""))
	if kind == "heal_swap_keep":
		return false
	if kind.find("keep") >= 0:
		return true
	if str(it.get("ability", "")).to_lower().find("keep") >= 0:
		return true
	return false


func _decay_clear_mark(it: Dictionary) -> void:
	it["decay_marked"] = false
	it["decay_partner"] = -1
	it["decay_solo"] = false


func _decay_clear_all() -> void:
	for it in hotbar:
		if typeof(it) == TYPE_DICTIONARY:
			_decay_clear_mark(it)


func _discard_unused_decay() -> void:
	var unused: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if bool(it.get("decay_marked", false)) and not bool(it.get("spent", false)):
			unused.append(int(it.get("uid", -1)))
	if unused.is_empty():
		return
	for it2 in hotbar:
		if typeof(it2) == TYPE_DICTIONARY and int(it2.get("uid", -1)) in unused:
			_decay_clear_mark(it2)
			_log("discard", "Decay %s" % it2.get("name", "?"))
	_decay_busy = true
	for uid in unused:
		_discard_from_hand(int(uid))
	_decay_busy = false


func _decay_claim_use(uid: int) -> bool:
	var it: Dictionary = _find_item(uid)
	if it.is_empty() or not bool(it.get("decay_marked", false)):
		return false
	var partner: int = int(it.get("decay_partner", -1))
	_decay_clear_mark(it)
	it["keep_after"] = true
	if partner >= 0:
		var other: Dictionary = _find_item(partner)
		if not other.is_empty():
			_decay_clear_mark(other)
		_decay_busy = true
		_discard_from_hand(partner)
		_decay_busy = false
	return true


func _zombie_decay_on_spin() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "zombie" or _is_silenced(m) or int(m.get("hp", 0)) <= 0:
		return
	var eligible: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if bool(it.get("spent", false)) or _item_stoned(it) or _item_has_keep(it):
			continue
		eligible.append(int(it.get("uid", -1)))
	var picked: Array = []
	if has_meta("qa_decay_uids"):
		var want: Variant = get_meta("qa_decay_uids")
		if typeof(want) == TYPE_ARRAY:
			for raw in want:
				var uid: int = int(raw)
				if uid in eligible and picked.size() < 2 and not picked.has(uid):
					picked.append(uid)
	else:
		var bag: Array = eligible.duplicate()
		for i in range(bag.size() - 1, 0, -1):
			var j: int = rng.randi_range(0, i)
			var tmp: int = int(bag[i])
			bag[i] = bag[j]
			bag[j] = tmp
		var n_pick: int = mini(2, bag.size())
		for k in n_pick:
			picked.append(int(bag[k]))
	if picked.is_empty():
		_log("on_spin", "Decay — nothing to link")
		return
	if picked.size() == 1:
		var solo: Dictionary = _find_item(int(picked[0]))
		if solo.is_empty():
			return
		solo["decay_marked"] = true
		solo["decay_solo"] = true
		solo["decay_partner"] = -1
		_log("on_spin", "Decay %s" % solo.get("name", "?"))
		return
	var a: Dictionary = _find_item(int(picked[0]))
	var b: Dictionary = _find_item(int(picked[1]))
	if a.is_empty() or b.is_empty():
		return
	a["decay_marked"] = true
	a["decay_solo"] = false
	a["decay_partner"] = int(b.get("uid", -1))
	b["decay_marked"] = true
	b["decay_solo"] = false
	b["decay_partner"] = int(a.get("uid", -1))
	_log("on_spin", "Decay %s + %s" % [a.get("name", "?"), b.get("name", "?")])


func _toss_item(uid: int, keep: bool, slow: bool = false) -> void:
	if not _decay_busy and _decay_claim_use(uid):
		keep = true
	if keep and _keep_blocked_now():
		keep = false
	for c in _hotbar_all_cards():
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


func _discard_from_hand(uid: int, slow: bool = false, recycle: bool = true) -> void:
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	var snap: Dictionary = it.duplicate(true)
	_toss_item(uid, false, slow)
	if recycle:
		_recycle_after_gone(snap)
	if not _beggar_hold and not _decay_busy:
		_kick_beggar_fill()


func _recycle_insert_copy(snap: Dictionary) -> void:
	uid_seq += 1
	var copy: Dictionary = snap.duplicate(true)
	copy["uid"] = uid_seq
	copy["spent"] = false
	copy["keep_after"] = false
	if str(copy.get("card_id", "")) == "recycler":
		copy["recycle_n"] = 5
	hotbar.append(copy)
	_sort_hotbar()
	_log("on_draft", "copy %s" % copy.get("name", "?"))
	if sfx:
		sfx.play_event(&"hand.gain", {"card_id": str(copy.get("card_id", ""))})


func _recycle_after_gone(snap: Dictionary) -> void:
	if snap.is_empty():
		return
	var leaving_uid: int = int(snap.get("uid", -1))
	var fire_uids: Array = []
	var tick_uids: Array = []
	for r in hotbar:
		if typeof(r) != TYPE_DICTIONARY:
			continue
		if str(r.get("card_id", "")) != "recycler":
			continue
		if _item_stoned(r):
			continue
		var rid: int = int(r.get("uid", -1))
		if rid == leaving_uid:
			continue
		if int(r.get("recycle_n", 5)) <= 1:
			fire_uids.append(rid)
		else:
			tick_uids.append(rid)
	var self_fire: bool = str(snap.get("card_id", "")) == "recycler" and int(snap.get("recycle_n", 5)) <= 1
	for rid in tick_uids:
		var t: Dictionary = _find_item(int(rid))
		if t.is_empty():
			continue
		t["recycle_n"] = maxi(1, int(t.get("recycle_n", 5)) - 1)
	var copies: int = fire_uids.size()
	if self_fire:
		copies += 1
	for rid2 in fire_uids:
		var f: Dictionary = _find_item(int(rid2))
		if not f.is_empty():
			f["recycle_n"] = 5
	if copies <= 0:
		_hotbar_sig = ""
		_refresh()
		return
	for it in hotbar:
		if str(it.get("card_id", "")) == "recycler" and int(it.get("uid", -1)) in fire_uids:
			if hotbar_box:
				for c in hotbar_box.get_children():
					if _control_uid(c) == int(it.get("uid", -1)) and c.has_method("bounce"):
						c.bounce()
	for _i in copies:
		if _hand_full():
			_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
			_log("discard", "can't copy %s" % snap.get("name", "?"))
			if sfx:
				sfx.play("error", -10.0)
			continue
		_recycle_insert_copy(snap)
	_hotbar_sig = ""
	_refresh()


func _remove_item_now(uid: int) -> void:
	var kept: Array = []
	for it in hotbar:
		if int(it.get("uid", -1)) != uid:
			kept.append(it)
	hotbar = kept
	_hotbar_sig = ""


func _defeat_blocked(m: Dictionary) -> bool:
	if m.is_empty():
		return false
	if bool(m.get("polymorphed_this_fight", false)):
		return false
	var id: String = str(m.get("card_id", ""))
	return id == "gargoyle" and not _is_silenced(m)


func _bag_threshold(it: Dictionary) -> int:
	var cap: int = int(it.get("bagged_hp", 0))
	if cap > 0:
		return cap
	return hp


func _use_orb(it: Dictionary) -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	var m: Dictionary = wheel[facing_index]
	if _defeat_blocked(m) or _incoming_hit() > 0:
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	var atk_n: int = int(m.get("atk", 0))
	var mid: String = str(m.get("card_id", ""))
	if _undying(m):
		_log("on_item_use", str(it["name"]))
		_log("on_resolve", "undying")
		await _lich_keep_defeat_item(it)
		if await _lich_chip_defeat(facing_index):
			_gain_orb_marble(atk_n, mid)
			await _begin_slay()
		return
	it["spent"] = true
	await _count_item_use()
	_log("on_item_use", str(it["name"]))
	_log("on_resolve", "defeat")
	if sfx:
		sfx.play_event(&"defeat.use")
	_toss_item(int(it["uid"]), false)
	_gain_orb_marble(atk_n, mid)
	await _begin_slay()


func _gain_orb_marble(atk_n: int, monster_id: String) -> void:
	if _gain_blocked_now() or hotbar.size() >= MARBLE_FILL:
		_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
		_log("on_draft", "no Marble")
		if sfx:
			sfx.play("error", -10.0)
		return
	var tok: Dictionary = _make_item("marble")
	tok["marble_n"] = maxi(0, atk_n)
	tok["marble_monster"] = monster_id
	hotbar.append(tok)
	_sort_hotbar()
	_log("on_draft", "Marble %s  %s" % [tok["marble_n"], monster_id])
	if sfx:
		sfx.play_event(&"hand.gain", {"card_id": "marble"})
	_hotbar_sig = ""
	_sync_hotbar()


func _use_bag_hold(it: Dictionary) -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("kind", "")) != "monster":
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	if int(m.get("hp", 99)) >= _bag_threshold(it):
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	await _count_item_use()
	var token: int = _undo_gen
	if _undo_stale(token):
		return
	_log("on_item_use", str(it["name"]))
	_log("on_resolve", "bag")
	_fill_bag(it, m)
	if sfx:
		sfx.play_event(&"defeat.use")
		sfx.play("whoosh", -8.0, 0.9)
	_flash_screen(Color("6d4c9a"), 0.28)
	_hotbar_sig = ""
	_refresh()
	await _bag_remove_facing()
	if _undo_stale(token):
		return


func _fill_bag(it: Dictionary, m: Dictionary) -> void:
	var who: String = str(m.get("name", "Monster"))
	var cap: int = int(m.get("hp", 0))
	it["bagged"] = m.duplicate(true)
	it["bagged"]["hunter_mark"] = false
	it["bagged"]["marked_by"] = -1
	it["bagged"]["trapper_entered"] = false
	it["bagged_hp"] = cap
	it["bagged_name"] = who
	it["name"] = "Bag of %s" % who
	it["ability"] = "Bag an Enemy with Less HP than this"
	it["explainer"] = "(ENEMY HP < %s)" % cap
	it["spent"] = false
	it["keep_after"] = true


func _empty_bag(it: Dictionary) -> Dictionary:
	var snap: Dictionary = {}
	if typeof(it.get("bagged", null)) == TYPE_DICTIONARY:
		snap = (it["bagged"] as Dictionary).duplicate(true)
	it["bagged"] = {}
	it["bagged_hp"] = 0
	it["bagged_name"] = ""
	var card: Dictionary = items_by_id.get("bag_of_holding", {})
	it["name"] = _title_case(str(card.get("name", "Bag of Holding")))
	it["ability"] = str(card.get("ability", "Bag an enemy with less HP than you."))
	it["explainer"] = str(card.get("explainer", ""))
	it["keep_after"] = false
	return snap


func _bag_is_loaded(it: Dictionary) -> bool:
	if str(it.get("card_id", "")) != "bag_of_holding":
		return false
	if int(it.get("bagged_hp", 0)) <= 0:
		return false
	if typeof(it.get("bagged", null)) != TYPE_DICTIONARY:
		return false
	return not (it["bagged"] as Dictionary).is_empty()


func _find_loaded_bag() -> Dictionary:
	var best: Dictionary = {}
	var best_x: float = INF
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if not _bag_is_loaded(it):
			continue
		var x: float = 0.0
		var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null:
			x = card.global_position.x
		if best.is_empty() or x < best_x:
			best = it
			best_x = x
	return best


func _bag_remove_facing() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var token: int = _undo_gen
	await _on_owner_defeated(facing_index)
	if _undo_stale(token) or hp <= 0:
		return
	if adventure:
		var start: int = facing_index
		_challenge_vacate(facing_index)
		facing_index = -1
		if wheel_view:
			wheel_view.selected_index = -1
			wheel_view.facing_index = -1
		_discard_spent_items()
		_bank_stone_wall()
		blk = 0
		_log("var", "BLK 0")
		await _challenge_resolve_holes(start)
		if _undo_stale(token):
			return
		_sync_wheel_stats()
	else:
		var m: Dictionary = wheel[facing_index]
		var left_id: String = str(m.get("card_id", ""))
		if left_id == "mimic" and not enemy_attacked:
			await _grant_mimic_gift()
			if _undo_stale(token):
				return
		if _install_laid_egg(facing_index):
			facing_index = -1
		else:
			_remove_facing()
		_discard_spent_items()
		_bank_stone_wall()
		blk = 0
		mobs_defeated += 1
		_log("var", "BLK 0")
		_log("var", "defeated %s" % mobs_defeated)
		await _collapse_dead_wicks()
		if _undo_stale(token):
			return
		_sync_wheel_stats()
		await _slay_pending_ogres()
		if _undo_stale(token):
			return
	phase = "ready"
	if _monsters_left() == 0:
		if await _try_release_bag():
			if _undo_stale(token):
				return
			_refresh()
			_walker_busy = false
			await _maybe_auto_spin()
			return
		if _undo_stale(token):
			return
		_enter_dungeon_clear()
		_refresh()
		_walker_busy = false
		return
	if sfx:
		sfx.set_combat_music(false)
	_refresh()
	_walker_busy = false
	await _maybe_auto_spin()


func _try_release_bag() -> bool:
	var it: Dictionary = _find_loaded_bag()
	if it.is_empty():
		return false
	var snap: Dictionary = _empty_bag(it)
	if snap.is_empty() or str(snap.get("kind", "monster")) == "empty":
		it["spent"] = true
		it["keep_after"] = false
		_discard_from_hand(int(it.get("uid", -1)))
		_discard_spent_items()
		return await _try_release_bag()
	_log("on_resolve", "bag opens")
	var token: int = _undo_gen
	_hotbar_sig = ""
	_refresh()
	var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
	if card != null:
		_apply_bag_look(card, it)
		if card.has_method("play_transform"):
			card.play_transform()
	if sfx:
		sfx.play_event(&"item.bag_release")
	_flash_screen(Color("6d4c9a"), 0.38)
	if combat_stage:
		combat_stage.hide_stage()
	if player_stage:
		player_stage.hide_stage()
	if get_tree():
		await get_tree().create_timer(0.42).timeout
	if _undo_stale(token):
		return false
	it["spent"] = true
	it["keep_after"] = false
	_discard_from_hand(int(it.get("uid", -1)))
	_discard_spent_items()
	var seat: int = _seat_released_bag(snap)
	_hotbar_sig = ""
	phase = "ready"
	if wheel_view and seat >= 0:
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, -1, "none")
		wheel_view.pulse_arrive(seat)
	if sfx:
		sfx.set_combat_music(false)
	_refresh()
	return true


func _seat_released_bag(snap: Dictionary) -> int:
	var m: Dictionary = snap.duplicate(true)
	m["kind"] = "monster"
	m["slot"] = str(m.get("slot", ""))
	var hole: int = -1
	for i in range(wheel.size()):
		if str(wheel[i].get("kind", "")) == "empty":
			hole = i
			break
	if hole >= 0:
		if adventure:
			m["slot"] = str(wheel[hole].get("slot", m.get("slot", "")))
		wheel[hole] = m
	else:
		wheel.append(m)
		hole = wheel.size() - 1
	_reseat_slots()
	_sync_wheel_stats()
	_log("on_place", "%s left the bag" % str(m.get("name", "Monster")))
	return hole


func _clockwork_synchronize(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "clockwork_knight":
		return
	if bool(m.get("synchronized", false)):
		return
	m["synchronized"] = true
	wheel[index] = m
	if _is_silenced(m):
		return
	var nbs: Array[int] = []
	for j in _damsel_neighbors(index):
		if int(wheel[j].get("hp", 0)) <= 0:
			continue
		if str(wheel[j].get("kind", "")) != "monster":
			continue
		nbs.append(j)
	if nbs.size() < 2:
		return
	await _announce_slice(index, _slice_hp_pos(nbs[0]))
	await _sync_pair_stat(index, nbs[0], nbs[1], true)
	await _sync_pair_stat(index, nbs[0], nbs[1], false)
	var before: Dictionary = {}
	for j2 in nbs:
		if j2 < 0 or j2 >= wheel.size():
			continue
		if _atk_is_always(wheel[j2]):
			before[j2] = int(wheel[j2].get("atk", 0))
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.set_slices(wheel, facing_index, "none")
	for j3 in before.keys():
		var ji: int = int(j3)
		if ji < 0 or ji >= wheel.size():
			continue
		if not _atk_is_always(wheel[ji]):
			continue
		var now_atk: int = int(wheel[ji].get("atk", 0))
		if now_atk == int(before[j3]):
			continue
		_log("on_resolve", "Reset due to ability")
		_flash_reset_line(ji)
		if wheel_view:
			wheel_view.punch_atk(ji)
		if get_tree():
			await get_tree().create_timer(0.45).timeout


func _sync_pair_stat(src: int, a: int, b: int, hp_stat: bool) -> void:
	var key: String = "hp" if hp_stat else "atk"
	var guard: int = 0
	while guard < 48:
		guard += 1
		if a < 0 or b < 0 or a >= wheel.size() or b >= wheel.size():
			return
		if int(wheel[a].get("hp", 0)) <= 0 or int(wheel[b].get("hp", 0)) <= 0:
			return
		var av: int = int(wheel[a].get(key, 0))
		var bv: int = int(wheel[b].get(key, 0))
		if av == bv:
			return
		var low: int = a if av < bv else b
		await _sync_grant_one(src, low, hp_stat)
	if a < 0 or b < 0 or a >= wheel.size() or b >= wheel.size():
		return
	var av2: int = int(wheel[a].get(key, 0))
	var bv2: int = int(wheel[b].get(key, 0))
	if av2 == bv2:
		return
	var low2: int = a if av2 < bv2 else b
	var goal: int = bv2 if av2 < bv2 else av2
	var cur: int = av2 if av2 < bv2 else bv2
	while cur < goal:
		_sync_grant_instant(low2, hp_stat)
		cur += 1
	_show_sync_slice(low2, hp_stat)


func _sync_grant_one(src: int, low: int, hp_stat: bool) -> void:
	var from: Vector2 = _slice_from(src)
	var to: Vector2 = _slice_hp_pos(low) if hp_stat else _slice_atk_pos(low)
	var tex: Texture2D = tex_heart if hp_stat else tex_sword
	if tex != null and from != Vector2.ZERO:
		await _fly_courier(tex, from, to if to != Vector2.ZERO else from, 0.16)
	_sync_grant_instant(low, hp_stat)
	_show_sync_slice(low, hp_stat)
	if sfx:
		sfx.play_event(&"mon.leech_pulse", {"pitch_mul": 1.08 if hp_stat else 0.92})
	var stat_name: String = "HP" if hp_stat else "Attack"
	_log("on_resolve", "Synchronize +1 %s → %s" % [stat_name, str(wheel[low].get("name", "?"))])


func _sync_grant_instant(low: int, hp_stat: bool) -> void:
	if low < 0 or low >= wheel.size():
		return
	var s: Dictionary = wheel[low]
	if hp_stat:
		s["hp"] = int(s.get("hp", 0)) + 1
		s["hp_max"] = int(s.get("hp_max", s["hp"])) + 1
		s["sync_hp"] = int(s.get("sync_hp", 0)) + 1
	else:
		s["atk"] = int(s.get("atk", 0)) + 1
		if not _atk_is_always(s):
			s["sync_atk"] = int(s.get("sync_atk", 0)) + 1
	wheel[low] = s


func _show_sync_slice(index: int, hp_stat: bool) -> void:
	if wheel_view == null:
		return
	wheel_view.set_slices(wheel, facing_index, "none")
	if hp_stat:
		wheel_view.punch_hp(index)
	else:
		wheel_view.punch_atk(index)


func _flash_reset_line(index: int) -> void:
	if play_field == null:
		return
	var at: Vector2 = _slice_from(index)
	if at == Vector2.ZERO:
		at = _slice_hp_pos(index)
	var lab: FitLabelBox = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = 15
	lab.min_font_size = 12
	lab.set_plain("Reset due to ability")
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.font_color = Color("f0e6d8")
	lab.set_outline(Color("100e0c"), 4)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.z_index = 46
	play_field.add_child(lab)
	lab.size = Vector2(220, 28)
	lab.global_position = at - Vector2(110, 36)
	lab.modulate.a = 0.0
	var tw := lab.create_tween()
	tw.tween_property(lab, "modulate:a", 1.0, 0.1)
	tw.parallel().tween_property(lab, "global_position", lab.global_position + Vector2(0, -22), 0.7)
	tw.chain().tween_interval(0.35)
	tw.tween_property(lab, "modulate:a", 0.0, 0.3)
	tw.finished.connect(lab.queue_free)


func _wick_waiting(_index: int) -> bool:
	return false


func _wick_on_defeated(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	await _clockwork_synchronize(index)
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	var who: String = str(wheel[index].get("name", "Neighbor"))
	var nbs: Array[int] = _damsel_neighbors(index)
	_begin_simul()
	for i in nbs:
		if str(wheel[i].get("card_id", "")) != "wick":
			continue
		if _is_silenced(wheel[i]):
			continue
		await _announce_slice(i, _slice_hp_pos(i))
		if await _chip_hp(i, 2):
			_end_simul()
			await _collapse_dead_wicks()
			return
		_log("on_resolve", "Wick -2 (%s Defeated)" % who)
	_end_simul()
	await _collapse_dead_wicks()


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


func _undying(m: Dictionary) -> bool:
	return str(m.get("card_id", "")) == "lich" and not _is_silenced(m)


func _lich_keep_defeat_item(it: Dictionary) -> void:
	it["spent"] = true
	var echo: bool = str(it.get("card_id", "")) == "echo_bell"
	it["keep_after"] = not echo
	await _count_item_use()
	if echo:
		_log("discard", str(it.get("name", "Echo Bell")))
	else:
		_log("keep", str(it.get("name", "?")))
	_toss_item(int(it.get("uid", -1)), not echo)


## True when the 1 HP chip dropped them to 0.
func _lich_chip_defeat(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	_lich_chip_open = true
	await _chip_hp(index, 1)
	_lich_chip_open = false
	if index < 0 or index >= wheel.size():
		return true
	if str(wheel[index].get("card_id", "")) != "lich":
		return true
	_log("hp", "Undying −1  →  %s" % wheel[index].get("hp", 0))
	return int(wheel[index].get("hp", 0)) <= 0


func _chip_hp(index: int, n: int) -> bool:
	if index < 0 or index >= wheel.size() or n <= 0:
		return false
	var m: Dictionary = wheel[index]
	var drop: int = n
	var cut_chip: bool = false
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m):
		if n > 1:
			cut_chip = true
		drop = 1
	var before: int = int(m.get("hp", 0))
	m["hp_pre_hit"] = before
	if _undying(m):
		if not _lich_chip_open:
			_log("var", "no HP loss")
			if wheel_view:
				wheel_view.hit_feedback(index, 0, 0)
			return false
		drop = 1
		cut_chip = false
	if cut_chip:
		await _announce_slice(index, _slice_hp_pos(index))
	m["hp"] = maxi(0, before - drop)
	if before > 0 and int(m["hp"]) <= 0:
		_note_death(m)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = int(m["hp"])
	wheel[index] = m
	if wheel_view:
		if cut_chip:
			await wheel_view.play_hp_ticks(index, before, int(m["hp"]))
		else:
			wheel_view.punch_hp(index)
	if before > int(m["hp"]):
		if await _martyr_after_hp_loss(index, before, int(m["hp"])):
			return true
		if await _vindictive_after_hp_loss(index):
			return true
	return false


func _poison_of(m: Dictionary) -> int:
	if m.has("poison"):
		return maxi(0, int(m.get("poison", 0)))
	return 5 if bool(m.get("poisoned", false)) else 0


func _add_monster_poison(index: int, n: int) -> void:
	if index < 0 or index >= wheel.size() or n <= 0:
		return
	var m: Dictionary = wheel[index]
	var amt: int = _poison_of(m) + n
	m["poison"] = amt
	m["poisoned"] = amt > 0
	wheel[index] = m
	if wheel_view != null and wheel_view.has_method("poison_badge_gain"):
		wheel_view.poison_badge_gain(index)
	_sync_plague_poison()


func _plague_doctor_indices() -> Array[int]:
	var out: Array[int] = []
	for i in wheel.size():
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "plague_doctor":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		if _is_silenced(s):
			continue
		out.append(i)
	return out


func _sync_plague_poison() -> void:
	for i in wheel.size():
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		var dose: int = _poison_of(wheel[i])
		wheel[i]["poisoned"] = dose > 0
		wheel[i]["plague_held"] = false
	if wheel_view != null:
		wheel_view.hub_poison_locked = false


func _apply_plague_doctor_on_spin() -> void:
	for pd in _plague_doctor_indices():
		if pd < 0 or pd >= wheel.size():
			continue
		if int(wheel[pd].get("hp", 0)) <= 0:
			continue
		if _is_silenced(wheel[pd]):
			continue
		_gain_player_poison(1)
		for i in wheel.size():
			if str(wheel[i].get("kind", "")) != "monster":
				continue
			if int(wheel[i].get("hp", 0)) <= 0:
				continue
			_add_monster_poison(i, 1)
		_log("on_spin", "Outbreak  →  you and every monster +1")
		await _announce_slice(pd, _slice_hp_pos(pd))
	_sync_plague_poison()
	_refresh()


func _miasma_min_hp() -> int:
	var lowest: int = 0
	for s in wheel:
		if typeof(s) != TYPE_DICTIONARY:
			continue
		if str(s.get("card_id", "")).strip_edges() == "":
			continue
		if str(s.get("kind", "monster")) == "item":
			continue
		var h: int = int(s.get("hp", 0))
		if h <= 0:
			continue
		if lowest <= 0 or h < lowest:
			lowest = h
	return lowest


func _use_miasma(it: Dictionary) -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	var n: int = _miasma_min_hp()
	if n <= 0:
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return
	_log("on_item_use", str(it.get("name", "Miasma")))
	_log("on_resolve", "poison %s all" % n)
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")).strip_edges() == "":
			continue
		if str(wheel[i].get("kind", "monster")) == "item":
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		_add_monster_poison(i, n)
	_sync_plague_poison()
	_refresh()
	if sfx:
		sfx.play_event(&"status.poison")
	it["spent"] = true
	await _count_item_use()
	_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()


func _clear_monster_poison(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	wheel[index]["poison"] = 0
	wheel[index]["poisoned"] = false
	wheel[index]["plague_held"] = false
	if wheel_view != null and wheel_view.has_method("poison_badge_clear"):
		wheel_view.poison_badge_clear(index)
	_sync_plague_poison()


func _living_monster_count() -> int:
	var n: int = 0
	for s in wheel:
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) > 0:
			n += 1
	return n


func _last_living_monster_is_down() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	if int(wheel[facing_index].get("hp", 0)) > 0:
		return false
	return _living_monster_count() <= 0


func _facing_can_act() -> bool:
	if phase != "fighting":
		return false
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	if str(wheel[facing_index].get("kind", "")) != "monster":
		return false
	return int(wheel[facing_index].get("hp", 0)) > 0


func _tick_facing_monster_poison() -> bool:
	var i: int = facing_index
	if i < 0 or i >= wheel.size():
		return false
	if str(wheel[i].get("kind", "")) != "monster":
		return false
	if int(wheel[i].get("hp", 0)) <= 0:
		return false
	var dose: int = _poison_of(wheel[i])
	if dose <= 0:
		return false
	_ticker_push_poison("monster_poison")
	if poison_pop != null and poison_pop.has_method("burst_slice"):
		await poison_pop.burst_slice(i, dose)
	if i < 0 or i >= wheel.size() or i != facing_index:
		return false
	var stopped: bool = await _chip_hp(i, dose)
	if i < 0 or i >= wheel.size():
		return false
	_clear_monster_poison(i)
	if int(wheel[i].get("hp", 0)) <= 0 and not _wick_waiting(i):
		wheel[i]["poison_down"] = true
	var m: Dictionary = wheel[i]
	_log("on_spin", "poison  →  %s HP" % m.get("hp", 0))
	_refresh()
	if stopped:
		_store_last_faced_hp()
		_undo_arm()
		await _unlock_if_fighting()
		return true
	return false


func _flush_poison_sides() -> void:
	if _flushing_poison_sides:
		return
	_flushing_poison_sides = true
	var i: int = wheel.size() - 1
	while i >= 0:
		if i != facing_index and i < wheel.size() and bool(wheel[i].get("poison_down", false)):
			wheel[i].erase("poison_down")
			if str(wheel[i].get("kind", "")) == "monster" and int(wheel[i].get("hp", 0)) <= 0 and not _wick_waiting(i):
				await _maybe_slay_down(i)
		i -= 1
	_flushing_poison_sides = false


func _gain_player_poison(n: int) -> void:
	if n <= 0:
		return
	player_poison = maxi(0, player_poison) + n
	_log("on_item_use", "poison %s" % player_poison)
	_sync_plague_poison()
	_refresh()
	if sfx:
		sfx.play_event(&"status.poison")


func _tick_player_poison() -> bool:
	var n: int = player_poison
	if n <= 0:
		return false
	_ticker_push_poison("player_poison")
	_refresh_hearts()
	if hearts_box:
		var hi: int = 0
		var from: int = maxi(0, hp - n)
		for child in hearts_box.get_children():
			var tr := child as TextureRect
			if tr != null and hi >= from and hi < hp:
				_punch_heart(tr)
			hi += 1
	if poison_pop != null and poison_pop.has_method("burst_hub"):
		await poison_pop.burst_hub(n)
	elif get_tree():
		await get_tree().create_timer(0.22).timeout
	player_poison = 0
	var before: int = hp
	hp = maxi(0, hp - n)
	if hp < before:
		hp_loss_events += 1
		_bleed_losses += 1
		lost_hp_this_combat = true
		_note_hp_lost(before - hp)
	_log("hp", "poison -%s  now %s" % [n, hp])
	_flash_screen(Color("2e4a32"), 0.28)
	_refresh_hearts()
	if sfx:
		sfx.play_event(&"status.poison")
	if hp < before:
		await _hurt_ogres(before - hp)
		await _grow_vampires()
	if hp <= 0 and not _try_potion():
		_player_down()
		return true
	if hp != before and hp > 0:
		await _sync_dire_wolves()
	_refresh()
	return false


func _hired_living_neighbors(index: int) -> Array[int]:
	var out: Array[int] = []
	for j in _damsel_neighbors(index):
		if int(wheel[j].get("hp", 0)) > 0:
			out.append(j)
	return out


func _hired_ask_bribe() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or str(wheel[facing_index].get("card_id", "")) != "hired_hand" or _is_silenced(wheel[facing_index]):
		return
	var nbs: Array[int] = _hired_living_neighbors(facing_index)
	var uids: Array = []
	if not nbs.is_empty():
		uids = _hand_discard_uids()
	pending_feed = {"uids": uids, "kind": "hired_bribe"}
	if nbs.is_empty():
		_cube_line = "Nobody next to me. Decline — we fight."
	elif uids.is_empty():
		_cube_line = "You've got nothing. Decline — we fight."
	else:
		_cube_line = "Pay me. Discard any item, or Decline."
	_log("on_spin", "hired hand bribe")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play("cloth", -12.0)


func _hand_discard_uids() -> Array:
	var uids: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if bool(it.get("spent", false)):
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			uids.append(uid)
	return uids


func _hand_all_uids() -> Array:
	var uids: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			uids.append(uid)
	return uids


func _hand_bell_defeat_uids() -> Array:
	var uids: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) == "rust":
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			uids.append(uid)
	return uids


func _maybe_enter_gains(index: int) -> void:
	await _maybe_death_bell_spawn(index)
	await _maybe_rust_bucket_spawn(index)
	await _maybe_oligarch_spawn(index)


func _item_uid_in_hand(uid: int) -> bool:
	if uid < 0:
		return false
	return not _find_item(uid).is_empty()


func _beggar_phase_ok() -> bool:
	return phase == "ready" or phase == "fighting" or phase == "devtest"


func _beggar_drop_invalid_owners() -> void:
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if int(wheel[i].get("beggar_mark", -1)) < 0:
			continue
		var alive: bool = str(wheel[i].get("card_id", "")) == "beggar" and str(wheel[i].get("kind", "")) == "monster" and int(wheel[i].get("hp", 0)) > 0 and not _is_silenced(wheel[i])
		if not alive:
			wheel[i]["beggar_mark"] = -1


func _beggar_pending_intro() -> bool:
	if not _beggar_phase_ok():
		return false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "beggar":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		if not bool(wheel[i].get("beggar_seen", false)):
			return true
	return false


func _beggar_has_gap() -> bool:
	if not _beggar_phase_ok():
		return false
	var any_item: bool = false
	for it in hotbar:
		if typeof(it) == TYPE_DICTIONARY and int(it.get("uid", -1)) >= 0:
			any_item = true
			break
	if not any_item:
		return false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "beggar":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		if not bool(wheel[i].get("beggar_seen", false)):
			continue
		if not _item_uid_in_hand(int(wheel[i].get("beggar_mark", -1))):
			return true
	return false


func _beggar_marked(uid: int) -> bool:
	if uid < 0:
		return false
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "beggar":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("beggar_mark", -1)) == uid:
			return true
	return false


func _beggar_pick_uid(owner: int) -> int:
	var taken: Dictionary = {}
	for i in wheel.size():
		if i == owner:
			continue
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if str(wheel[i].get("card_id", "")) != "beggar":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		var held: int = int(wheel[i].get("beggar_mark", -1))
		if _item_uid_in_hand(held):
			taken[held] = true
	var preferred: Array = []
	var any: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var uid: int = int(it.get("uid", -1))
		if uid < 0:
			continue
		any.append(uid)
		if not taken.has(uid):
			preferred.append(uid)
	var bag: Array = preferred if not preferred.is_empty() else any
	if bag.is_empty():
		return -1
	if OS.has_feature("editor") and has_meta("qa_beggar_uid"):
		var forced: int = int(get_meta("qa_beggar_uid"))
		remove_meta("qa_beggar_uid")
		if bag.has(forced):
			return forced
	return int(bag[rng.randi_range(0, bag.size() - 1)])


func _beggar_assign(index: int, anim: bool) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "beggar" or int(m.get("hp", 0)) <= 0 or _is_silenced(m):
		m["beggar_mark"] = -1
		wheel[index] = m
		return
	if _item_uid_in_hand(int(m.get("beggar_mark", -1))):
		return
	var uid: int = _beggar_pick_uid(index)
	m["beggar_mark"] = uid
	wheel[index] = m
	if uid < 0:
		_log("on_spin", "Beggar — nothing to mark")
		_refresh()
		return
	var named: Dictionary = _find_item(uid)
	_log("on_spin", "Beggar marks %s" % named.get("name", "?"))
	_refresh()
	if anim:
		await _beggar_flash(uid)


func _beggar_flash(uid: int) -> void:
	var card: Control = _hotbar_card_by_uid(uid)
	if card != null and card.has_method("play_beggar_pick"):
		card.play_beggar_pick()
	if sfx:
		sfx.play("whoosh", -8.0, 1.15)
		sfx.play("pluck", -6.0, 1.2)
	if get_tree():
		await get_tree().create_timer(0.28).timeout


func _beggar_force_discard(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "beggar" or _is_silenced(m) or int(m.get("hp", 0)) <= 0:
		return
	var uid: int = int(m.get("beggar_mark", -1))
	m["beggar_mark"] = -1
	wheel[index] = m
	if not _item_uid_in_hand(uid):
		return
	var it: Dictionary = _find_item(uid)
	var partner: int = int(it.get("decay_partner", -1))
	_decay_clear_mark(it)
	if partner >= 0:
		var other: Dictionary = _find_item(partner)
		if not other.is_empty():
			_decay_clear_mark(other)
	it["keep_after"] = false
	_log("discard", "Beggar %s" % it.get("name", "?"))
	_decay_busy = true
	_discard_from_hand(uid)
	_decay_busy = false


func _beggar_note_use(uid: int) -> void:
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if int(wheel[i].get("beggar_mark", -1)) == uid:
			wheel[i]["beggar_mark"] = -1


func _kick_beggar_intro() -> void:
	if _beggar_intro_running or _beggar_hold:
		return
	if not _beggar_pending_intro():
		return
	_beggar_intro_running = true
	_run_beggar_intros()


func _run_beggar_intros() -> void:
	_beggar_hold = true
	while _beggar_pending_intro():
		var index: int = -1
		for i in wheel.size():
			if typeof(wheel[i]) != TYPE_DICTIONARY:
				continue
			if str(wheel[i].get("card_id", "")) != "beggar":
				continue
			if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
				continue
			if bool(wheel[i].get("beggar_seen", false)):
				continue
			index = i
			break
		if index < 0:
			break
		wheel[index]["beggar_seen"] = true
		var who: Dictionary = wheel[index]
		if ability_slash:
			var tex: Texture2D = null
			if art != null:
				tex = art.monster_still("beggar")
			await ability_slash.play({
				"title": str(who.get("name", "Beggar")),
				"call": str(who.get("call_name", "Finders Keepers")),
				"tex": tex,
				"is_item": false,
				"card_id": "beggar",
			})
		if index < wheel.size() and str(wheel[index].get("card_id", "")) == "beggar" and int(wheel[index].get("hp", 0)) > 0 and not _is_silenced(wheel[index]):
			await _beggar_assign(index, true)
	_beggar_hold = false
	_beggar_intro_running = false
	_refresh()
	_kick_beggar_fill()


func _kick_beggar_fill() -> void:
	if _beggar_hold or _beggar_intro_running or _beggar_fill_running:
		return
	if _beggar_pending_intro():
		return
	_beggar_drop_invalid_owners()
	if not _beggar_has_gap():
		return
	_beggar_fill_running = true
	_run_beggar_fill()


func _run_beggar_fill() -> void:
	var guard: int = 0
	while _beggar_has_gap() and guard < 12:
		guard += 1
		var index: int = -1
		for i in wheel.size():
			if typeof(wheel[i]) != TYPE_DICTIONARY:
				continue
			if str(wheel[i].get("card_id", "")) != "beggar":
				continue
			if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
				continue
			if not bool(wheel[i].get("beggar_seen", false)):
				continue
			if not _item_uid_in_hand(int(wheel[i].get("beggar_mark", -1))):
				index = i
				break
		if index < 0:
			break
		await _beggar_assign(index, true)
	_beggar_fill_running = false
	_refresh()


func _maybe_death_bell_spawn(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "death_bell":
		return
	if bool(m.get("toll_granted", false)):
		return
	m["toll_granted"] = true
	wheel[index] = m
	await _force_gain_toll()


func _maybe_rust_bucket_spawn(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "rust_bucket":
		return
	if bool(m.get("rust_granted", false)):
		return
	m["rust_granted"] = true
	wheel[index] = m
	await _force_gain_rust()


func _oligarch_gift_pool() -> Array:
	var ids: Array = []
	for idv in item_pool:
		var iid: String = str(idv)
		if BucketRules.is_always_starter_id(iid):
			continue
		var card: Dictionary = items_by_id.get(iid, {})
		if card.is_empty():
			continue
		if BucketRules.is_token(card):
			continue
		var st: String = str(card.get("status", "live"))
		if st == "retired" or st == "hold":
			continue
		if bool(card.get("curse", false)):
			continue
		ids.append(iid)
	return ids


func _forced_hand_cap() -> int:
	return CHALLENGE_HAND


func _enforce_hand_cap() -> void:
	while hotbar.size() > _forced_hand_cap() and is_instance_valid(self):
		await _forced_gain_tax()
		if pending_feed.is_empty() and hotbar.size() > _forced_hand_cap():
			break


func _is_forced_gain_feed(kind: String) -> bool:
	return kind == "forced_gain" or kind == "oligarch_gift" or kind == "rust_spawn" or kind == "bell_spawn"


func _is_toss_feed(kind: String) -> bool:
	return _is_forced_gain_feed(kind) or kind == "bell_defeat"


func _forced_gain_tax() -> void:
	if hotbar.size() <= _forced_hand_cap():
		return
	var uids: Array = _filter_toss_uids(_hand_all_uids())
	if uids.is_empty():
		while hotbar.size() > _forced_hand_cap():
			var extra: Dictionary = hotbar.pop_back()
			if typeof(extra) == TYPE_DICTIONARY:
				_abort_full_hand_gain(extra)
		_sort_hotbar()
		return
	pending_feed = {"uids": uids, "kind": "forced_gain"}
	_refresh()
	_sync_hub_cue()
	await _wait_bell_pick()
	if hotbar.size() <= _forced_hand_cap():
		_sort_hotbar()
	_refresh()


func _maybe_oligarch_spawn(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "oligarch":
		return
	if _is_silenced(m):
		return
	if bool(m.get("oligarch_gifted", false)):
		return
	m["oligarch_gifted"] = true
	wheel[index] = m
	_speech_from_index = index
	_cube_line = "Here, I bought you something nice"
	_refresh()
	var pool: Array = _oligarch_gift_pool()
	pool.shuffle()
	var n: int = mini(2, pool.size())
	for i in range(n):
		await _oligarch_deliver_item(str(pool[i]), index)
	_cube_line = ""
	_speech_from_index = -1
	if speech_box:
		speech_box.hide_speech()
	_refresh()


func _oligarch_deliver_item(id: String, from_i: int) -> void:
	if id == "":
		return
	var it: Dictionary = _make_item(id)
	var from: Vector2 = Vector2.ZERO
	if wheel_view and from_i >= 0:
		from = wheel_view.slice_portrait_global(from_i)
	var to: Vector2 = _hotbar_empty_slot_global()
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex(id)
	if tex == null:
		tex = tex_by_item.get(id, tex_sword)
	if tex != null and from != Vector2.ZERO and to != Vector2.ZERO:
		await _fly_courier(tex, from, to, 0.42)
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	if sfx:
		sfx.play_event(&"hand.gain", {"card_id": id})
	_refresh()
	var planted: Node = null
	if hotbar_box:
		for c in hotbar_box.get_children():
			if _control_uid(c) == int(it.get("uid", -1)) and c.has_method("bounce"):
				c.bounce()
				planted = c
				break
	if planted == null and hotbar_box:
		for c2 in hotbar_box.get_children():
			if str(c2.get("card_id")) == id and c2.has_method("bounce"):
				c2.bounce()
				break
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()
		_speech_from_index = from_i
		_cube_line = "Here, I bought you something nice"
		_refresh()


func _oligarch_playable_uids() -> Array:
	var out: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if bool(it.get("spent", false)):
			continue
		if _item_stoned(it):
			continue
		var iid: String = str(it.get("card_id", ""))
		if BucketRules.is_always_starter_id(iid):
			continue
		if not bool(_item_view(it).get("can_use", false)):
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			out.append(uid)
	return out


func _apply_oligarch_on_spin() -> void:
	if phase != "fighting":
		return
	if not pending_feed.is_empty() or not pending_chaos.is_empty():
		return
	var seats: Array = []
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if str(s.get("card_id", "")) != "oligarch":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		if _is_silenced(s):
			continue
		seats.append(i)
	for _seat in seats:
		var uids: Array = _oligarch_playable_uids()
		if uids.is_empty():
			continue
		var pick: int = int(uids[rng.randi_range(0, uids.size() - 1)])
		_log("on_spin", "Oligarch uses a random Item")
		await _use_item(pick)
		if phase != "fighting":
			return


func _force_gain_rust() -> void:
	var it: Dictionary = _make_item("rust")
	it["rust_n"] = 3
	it["rust_seen"] = false
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", "Rust"))
	if sfx:
		sfx.play("drop", -10.0)
	_refresh()
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()


func _force_gain_toll() -> void:
	var it: Dictionary = _make_item("toll")
	it["toll_n"] = 6
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", "Toll"))
	if sfx:
		sfx.play("bong", -8.0, 0.85)
		sfx.play("drop", -10.0)
	_refresh()
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()


func _wait_bell_pick() -> void:
	_bell_wait = true
	if OS.has_feature("editor") and logic_qa != null and bool(logic_qa.busy) and not pending_feed.is_empty():
		var uids: Array = pending_feed.get("uids", [])
		if not uids.is_empty():
			_feed_bell_overlay(int(uids[0]))
		_bell_wait = false
		return
	while _bell_wait and is_instance_valid(self) and not pending_feed.is_empty():
		await get_tree().process_frame
	_bell_wait = false


func _feed_bell_overlay(uid: int) -> void:
	if pending_feed.is_empty():
		return
	var kind: String = str(pending_feed.get("kind", ""))
	if kind != "bell_spawn" and kind != "bell_defeat" and kind != "rust_spawn" and kind != "oligarch_gift" and kind != "forced_gain":
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		if sfx:
			sfx.play("error", -12.0)
		return
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	if _is_forced_gain_feed(kind) and _item_blocks_hand_tax(it):
		if sfx:
			sfx.play("error", -12.0)
		return
	_log("on_spin", "discard %s" % str(it.get("name", "?")))
	_discard_from_hand(uid)
	if kind == "forced_gain" and hotbar.size() > _forced_hand_cap():
		var next_uids: Array = _filter_toss_uids(_hand_all_uids())
		if next_uids.is_empty():
			while hotbar.size() > _forced_hand_cap():
				var extra: Dictionary = hotbar.pop_back()
				if typeof(extra) == TYPE_DICTIONARY:
					_abort_full_hand_gain(extra)
			pending_feed = {}
			_cube_line = ""
			_bell_wait = false
			_sort_hotbar()
		else:
			pending_feed = {"uids": next_uids, "kind": "forced_gain"}
			if sfx:
				sfx.play_event(&"hand.toss")
			_refresh()
			_sync_hub_cue()
			return
	pending_feed = {}
	_cube_line = ""
	_bell_wait = false
	if hotbar.size() <= _forced_hand_cap():
		_sort_hotbar()
	if speech_box:
		speech_box.hide_speech()
	if sfx:
		sfx.play_event(&"hand.toss")
	_refresh()


func _apply_death_bell_on_spin() -> void:
	var hit: Array[int] = []
	for i in range(wheel.size()):
		var m: Dictionary = wheel[i]
		if str(m.get("card_id", "")) != "death_bell":
			continue
		if int(m.get("hp", 0)) <= 0:
			continue
		if _is_silenced(m):
			continue
		hit.append(i)
	for i in hit:
		if i < 0 or i >= wheel.size():
			continue
		if str(wheel[i].get("card_id", "")) != "death_bell":
			continue
		if int(wheel[i].get("hp", 0)) <= 0 or _is_silenced(wheel[i]):
			continue
		await _chip_hp(i, 2)
		_log("on_spin", "Death Bell -2 HP")
		if sfx:
			sfx.play("bong", -10.0, 0.75)
	var i2: int = wheel.size() - 1
	while i2 >= 0:
		if i2 == facing_index:
			i2 -= 1
			continue
		if i2 >= wheel.size():
			i2 -= 1
			continue
		var bell: Dictionary = wheel[i2]
		if str(bell.get("card_id", "")) == "death_bell" and int(bell.get("hp", 0)) <= 0 and not _wick_waiting(i2):
			await _maybe_slay_down(i2)
			continue
		i2 -= 1


func _apply_mouse_scurry() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "mouse":
		return false
	if int(m.get("hp", 0)) <= 0:
		return false
	if _is_silenced(m):
		return false
	var mouse_hp: int = int(m.get("hp", 0))
	if hp <= mouse_hp:
		return false
	await _announce_slice(facing_index, _slice_hp_pos(facing_index))
	await _chip_hp(facing_index, 2)
	_log("on_spin", "Scurry -2 HP")
	if sfx:
		sfx.play("whoosh", -10.0, 1.2)
	if facing_index < 0 or facing_index >= wheel.size():
		return true
	if str(wheel[facing_index].get("card_id", "")) != "mouse":
		return true
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		await _begin_slay()
		return true
	if await _flee_spin():
		return true
	return false


func _maybe_bell_defeat_tax(index: int = -1) -> void:
	if index < 0:
		index = facing_index
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "death_bell":
		return
	if bool(m.get("bell_taxed", false)):
		return
	m["bell_taxed"] = true
	wheel[index] = m
	if _is_silenced(m):
		await _play_bell_ring()
		return
	if hotbar.is_empty():
		await _play_bell_ring()
		return
	var toss_uids: Array = _hand_bell_defeat_uids()
	if toss_uids.is_empty():
		await _play_bell_ring()
		return
	pending_feed = {"uids": toss_uids, "kind": "bell_defeat"}
	_cube_line = ""
	_refresh()
	if ability_slash:
		var tex: Texture2D = null
		if art != null:
			tex = art.monster_still("death_bell")
		await ability_slash.play({
			"title": str(m.get("name", "Death Bell")),
			"call": MONSTER_LINES.call_of("death_bell", monsters_by_id.get("death_bell", {})),
			"tex": tex,
			"is_item": false,
			"card_id": "death_bell",
		})
	await _wait_bell_pick()
	await _play_bell_ring()


func _play_bell_ring() -> void:
	_flash_screen(Color("3a1460"), 0.36)
	if sfx:
		sfx.play("bong", -4.0, 0.55)
		sfx.play("whoosh", -8.0, 0.7)
	if combat_stage:
		combat_stage.take_hit()
	if get_tree():
		await get_tree().create_timer(0.28).timeout


func _tick_tolls() -> void:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "toll":
			continue
		var n: int = int(it.get("toll_n", 6))
		if n <= 0:
			continue
		var next_n: int = n - 1
		it["toll_n"] = next_n
		_log("var", "Toll %s" % next_n)
		if next_n <= 0:
			_toll_death_armed = true
		elif sfx:
			sfx.play("bong", -8.0, 0.65 + 0.07 * float(next_n))
	_hotbar_sig = ""


func _bell_kill_this_use() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "death_bell":
		return false
	if _is_silenced(m):
		return false
	return int(m.get("hp", 0)) <= 0


func _resolve_toll_death() -> bool:
	if not _toll_death_armed:
		return false
	_toll_death_armed = false
	var zeros: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "toll":
			continue
		if int(it.get("toll_n", 6)) <= 0:
			zeros.append(int(it.get("uid", -1)))
	if zeros.is_empty():
		return false
	await _play_toll_zero_sequence(zeros)
	hp = 0
	if wheel_view:
		wheel_view.hub_hp = 0
	_refresh_hearts()
	_log("hp", "Toll set HP to 0")
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("death", 1, true)
	_player_play("defeat")
	if wheel_view and wheel_view.has_method("wait_hero_frame"):
		await wheel_view.wait_hero_frame("death", 2)
	if get_tree():
		await get_tree().create_timer(0.28).timeout
	var saved: bool = false
	for it in hotbar:
		if str(it.get("card_id", "")) != "healing_potion":
			continue
		if bool(it.get("spent", false)):
			continue
		it["spent"] = true
		it["keep_after"] = false
		_log_begin_item(it)
		if wheel_view and wheel_view.has_method("reset_hero"):
			wheel_view.reset_hero()
		await _heal(3)
		_toss_item(int(it["uid"]), false)
		saved = true
		break
	for uid in zeros:
		_toss_item(int(uid), false)
	_cube_line = ""
	_speech_from_index = -1
	if speech_box:
		speech_box.hide_speech()
	if saved:
		_refresh()
		return false
	_player_down(true)
	return true


func _toll_speaker_index() -> int:
	var dead_i: int = -1
	if facing_index >= 0 and facing_index < wheel.size():
		if str(wheel[facing_index].get("card_id", "")) == "death_bell":
			if int(wheel[facing_index].get("hp", 0)) > 0:
				return facing_index
			dead_i = facing_index
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "death_bell":
			continue
		if int(wheel[i].get("hp", 0)) > 0:
			return i
		if dead_i < 0:
			dead_i = i
	return dead_i


func _play_toll_zero_sequence(zeros: Array) -> void:
	var talk_i: int = _toll_speaker_index()
	if talk_i >= 0:
		_speech_from_index = talk_i
		_cube_line = "The bell toll..."
		_place_speech()
	if sfx:
		sfx.play("bong", -2.0, 0.42)
		sfx.play("whoosh", -6.0, 0.62)
		sfx.play("error_big", -10.0, 0.8)
	_flash_screen(Color("5a1a8a"), 0.62)
	var first: Control = null
	for uid in zeros:
		var card: Control = _hotbar_card_by_uid(int(uid))
		if card == null or not card.has_method("play_toll_zero"):
			continue
		if first == null:
			first = card
		else:
			card.play_toll_zero()
	if first != null:
		await first.play_toll_zero()
	elif get_tree():
		await get_tree().create_timer(0.45).timeout
	_flash_screen(Color("7a28c4"), 0.48)


func _worm_ask_hunger() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if _is_silenced(wheel[facing_index]):
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		return
	var uids: Array = _hand_discard_uids()
	pending_feed = {"uids": uids, "kind": "worm_hunger"}
	_cube_line = "When you Spin me, you may Discard Items. Each sacrifice reduces my Atk and HP by 3."
	_log("on_spin", "almighty worm hunger")
	if sfx:
		sfx.play("question", -8.0)
		sfx.play_event(&"mon.merchant_ask")


func _continue_worm() -> void:
	if pending_feed.is_empty() or str(pending_feed.get("kind", "")) != "worm_hunger":
		return
	pending_feed = {}
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	_log("on_spin", "worm hunger done")
	if sfx:
		sfx.play("click", -8.0)
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
		await _begin_slay()
		return
	_refresh()
	_undo_arm()


func _feed_worm(uid: int) -> void:
	if pending_feed.is_empty() or str(pending_feed.get("kind", "")) != "worm_hunger":
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		if sfx:
			sfx.play("error", -12.0)
		return
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	_log("on_spin", "worm ate %s" % str(it.get("name", "?")))
	_discard_from_hand(uid)
	if facing_index >= 0 and facing_index < wheel.size():
		var m: Dictionary = wheel[facing_index]
		m["hunger_n"] = int(m.get("hunger_n", 0)) + 1
		var before_atk: int = int(m.get("atk", 0))
		var before_innate: int = int(m.get("atk_innate", before_atk))
		m["atk"] = maxi(0, before_atk - 3)
		m["atk_innate"] = maxi(0, before_innate - 3)
		if not _undying(m):
			m["hp"] = maxi(0, int(m.get("hp", 0)) - 3)
			m["hp_max"] = maxi(int(m.get("hp_max", 0)) - 3, int(m.get("hp", 0)))
		else:
			_log("var", "no HP loss")
		wheel[facing_index] = m
	_sync_wheel_stats()
	if wheel_view and facing_index >= 0:
		wheel_view.punch_hp(facing_index)
		wheel_view.punch_atk(facing_index)
	if sfx:
		sfx.play_event(&"hand.toss")
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
		pending_feed = {}
		_cube_line = ""
		if speech_box:
			speech_box.hide_speech()
		_refresh()
		await _begin_slay()
		return
	pending_feed = {"uids": _hand_discard_uids(), "kind": "worm_hunger"}
	_refresh()
	_undo_arm()


func _decline_hired_hand() -> void:
	if pending_feed.is_empty() or str(pending_feed.get("kind", "")) != "hired_bribe":
		return
	pending_feed = {}
	var lines: Array = [
		"Fine. I'll do it myself.",
		"Cheap. Draw.",
		"Coward. Let's go.",
	]
	_cube_line = str(lines[rng.randi() % lines.size()])
	_log("on_spin", "hired hand declined")
	if sfx:
		sfx.play("cloth", -10.0)
	_refresh()
	_undo_arm()


func _pay_hired_hand(uid: int) -> void:
	if pending_feed.is_empty() or str(pending_feed.get("kind", "")) != "hired_bribe":
		return
	var allowed: Array = pending_feed.get("uids", [])
	if not allowed.has(uid):
		if sfx:
			sfx.play("error", -12.0)
		return
	var nbs: Array[int] = _hired_living_neighbors(facing_index)
	if nbs.is_empty():
		if sfx:
			sfx.play("error", -12.0)
		return
	pending_feed = {}
	_cube_line = ""
	if speech_box:
		speech_box.hide_speech()
	var it: Dictionary = _find_item(uid)
	_log("on_spin", "bribe %s" % str(it.get("name", "?")))
	_discard_from_hand(uid)
	_refresh()
	if sfx:
		sfx.play_event(&"hand.toss")
	var dest: int = nbs[rng.randi() % nbs.size()]
	var src: int = facing_index
	var snap: int = int(wheel[src].get("atk", 0)) if src >= 0 and src < wheel.size() else 3
	var hits: int = _hit_count(src) if src >= 0 else 1
	_watch_thorns_seat = src
	await _announce_slice(src, _slice_hp_pos(dest))
	await _watch_attack(src, dest, snap, hits, {})
	_watch_thorns_seat = -1
	if hp <= 0:
		_undo_arm()
		return
	await _slay_dead_after_watch()
	if phase != "fighting":
		_undo_arm()
		return
	if facing_index < 0 or facing_index >= wheel.size():
		_undo_arm()
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		await _begin_slay()
		_undo_arm()
		return
	if str(wheel[facing_index].get("card_id", "")) != "hired_hand":
		_undo_arm()
		_refresh()
		return
	_log("on_resolve", "Hired Hand Flees")
	if not await _flee_spin():
		_undo_arm()
		await _unlock_if_fighting()
		_refresh()


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


func _run_dead_sweep() -> void:
	if _tut_hold_slay:
		await _tutorial_clear_held_dead()
		return
	if false:
		await _maybe_slay_down(-1)
	var guard: int = 0
	while guard < 24:
		guard += 1
		var victim: int = -1
		for i in range(wheel.size()):
			if str(wheel[i].get("kind", "")) != "monster":
				continue
			if int(wheel[i].get("hp", 0)) > 0:
				continue
			if _wick_waiting(i):
				continue
			victim = i
			break
		if victim < 0:
			await _maybe_slay_down(-1)
			return
		await _maybe_slay_down(victim)
		if phase != "fighting" and phase != "slaying":
			return


func _tutorial_clear_held_dead() -> void:
	## Hold keeps Bandit until Shuriken resolves, but a dead Cube must leave the wheel.
	if not in_tutorial or not _tut_hold_slay:
		return
	var i: int = 0
	while i < wheel.size():
		if str(wheel[i].get("kind", "")) != "monster":
			i += 1
			continue
		if int(wheel[i].get("hp", 0)) > 0:
			i += 1
			continue
		if _wick_waiting(i):
			i += 1
			continue
		var cid: String = str(wheel[i].get("card_id", ""))
		if cid == "bandit":
			i += 1
			continue
		await _tutorial_vacate_dead(i)
		i += 1


func _tutorial_vacate_dead(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("kind", "")) != "monster":
		return
	if int(wheel[index].get("hp", 0)) > 0:
		return
	var m: Dictionary = wheel[index]
	_log("on_remove_slice", str(m.get("name", "?")))
	if sfx:
		var nctx := {"tier": _tier_of(m), "monster_id": str(m.get("card_id", ""))}
		sfx.play_event(sfx.resolve(&"death", nctx), nctx)
	if wheel_view:
		await wheel_view.play_slay(index)
	var slot: String = str(m.get("slot", SLOT_ORDER[index] if index < SLOT_ORDER.size() else str(index)))
	wheel[index] = {
		"kind": "empty",
		"slot": slot,
	}
	mobs_defeated += 1
	if int(m.get("died_seq", 0)) <= 0:
		_note_death(m)
	_sync_wheel_stats()
	if wheel_view:
		if wheel_view.slay_index == index and wheel_view.has_method("clear_slay"):
			wheel_view.clear_slay()
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, facing_index, "none")
	_refresh()


func _maybe_slay_down(index: int) -> void:
	if false:
		await _kill_neighbor(0)
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
		if _item_stoned(it):
			continue
		if _swap_pool_ids(_item_swap_tier(it)).is_empty():
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
		await _swap_item_same_tier(int(uid_v))
	stone["spent"] = true
	await _count_item_use()
	_toss_item(int(stone["uid"]), false)
	_sort_hotbar()
	_log("on_item_use", str(stone.get("name", "Chaos Stone")))
	await _after_item_resolved(stone)
	_undo_wall()
	call_deferred("_refresh")


func _tier_of_item_id(id: String) -> int:
	return _as_int(items_by_id.get(id, {}).get("tier", 1), 1)


func _swap_pool_ids(tier: int) -> Array:
	var out: Array = []
	for raw in item_pool:
		var iid: String = str(raw)
		var card: Dictionary = items_by_id.get(iid, {})
		if BucketRules.is_token(card):
			continue
		if _rug_secret_gated(iid):
			continue
		if _tier_of_item_id(iid) != tier:
			continue
		out.append(iid)
	if not out.is_empty():
		return out
	if not item_pool.is_empty() or adventure:
		return out
	for id in items_by_id.keys():
		var card2: Dictionary = items_by_id[id]
		if str(card2.get("status", "live")) == "retired" or str(card2.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card2):
			continue
		var flags: Variant = card2.get("flags", {})
		if typeof(flags) == TYPE_DICTIONARY and bool((flags as Dictionary).get("hide", false)):
			continue
		if _as_int(card2.get("tier", 1), 1) != tier:
			continue
		if _rug_secret_gated(str(id)):
			continue
		out.append(str(id))
	return out


func _jar_swap_targets(jar_uid: int) -> Array:
	var out: Array = []
	for it in hotbar:
		if bool(it.get("spent", false)):
			continue
		if int(it.get("uid", -1)) == jar_uid:
			continue
		if _item_stoned(it):
			continue
		if _swap_pool_ids(_item_swap_tier(it)).is_empty():
			continue
		out.append(int(it.get("uid", -1)))
	return out


func _item_swap_tier(it: Dictionary) -> int:
	var t: int = int(it.get("pack_tier", 0))
	if t < 1:
		t = int(it.get("tier", 0))
	return t


func _swap_item_same_tier(uid: int) -> void:
	var it: Dictionary = _find_item(uid)
	if it.is_empty():
		return
	var old_id: String = str(it.get("card_id", ""))
	var tier: int = _item_swap_tier(it)
	var pool: Array = _swap_pool_ids(tier)
	if pool.is_empty():
		return
	var nid: String = str(pool[rng.randi() % pool.size()])
	if item_pool.has(nid):
		item_pool.erase(nid)
		if old_id != "":
			item_pool.append(old_id)
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
			if _control_uid(c) != uid:
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
	# Grimoire: Attack of the last monster you spun (stored on Spin).
	last_mob_atk = maxi(int(face.get("atk", 0)), 0)



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
		var old_n: int = int(it.get("alt_n", 2))
		var new_n: int = 2 if old_n == 4 else 4
		it["alt_n"] = new_n
		var card: Control = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("play_sai"):
			card.play_sai(old_n, new_n)


func _shield_face(it: Dictionary) -> String:
	var src: Dictionary = it
	if str(it.get("card_id", "")) == "echo_bell":
		var echoed: Dictionary = _echo_face(it)
		if not echoed.is_empty():
			src = echoed
	return "blk" if str(src.get("shield_face", "atk")) == "blk" else "atk"


func _set_shield_face(it: Dictionary, face: String) -> void:
	var next: String = "blk" if face == "blk" else "atk"
	var src: Dictionary = it
	if str(it.get("card_id", "")) == "echo_bell":
		var echoed: Dictionary = _echo_face(it)
		if echoed.is_empty():
			return
		src = echoed
	src["shield_face"] = next
	src["card_color"] = "atk" if next == "atk" else "blk"


func _flip_shield_faces() -> void:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(_ops_of(it).get("kind", "")) != "shield_alt":
			continue
		var nxt: String = "atk" if _shield_face(it) == "blk" else "blk"
		_set_shield_face(it, nxt)



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
	_begin_simul()
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
		if before > 0 and int(s["hp"]) <= 0:
			_note_death(s)
		s["hp_locked"] = true
		if int(s["hp"]) <= 0 and i != facing_index:
			s["pending_slay"] = true
		wheel[i] = s
		await _announce_slice(i, _slice_hp_pos(i))
		if wheel_view:
			await wheel_view.play_hp_ticks(i, before, int(s["hp"]))
	_end_simul()
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
	_log("on_remove_slice", str(s.get("name", "Ogre")))
	if sfx:
		sfx.play("whoosh", -8.0, 1.1)
		sfx.play("scratch", -12.0, 0.9)
	if wheel_view:
		await wheel_view.play_slay(index, true)
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



func _flash_banner(msg: String, ticker_id: String = "", ticker_tex: Texture2D = null) -> void:
	if msg.strip_edges() == "":
		return
	# Item triggers that flash a banner (no slash) still stamp the cascade ticker.
	if ticker_id != "" and cascade_ticker != null and cascade_ticker.active:
		var ticket_i: int = cascade_ticker.push(ticker_id, ticker_tex)
		if ticket_i >= 0:
			cascade_ticker.light(ticket_i)
			cascade_ticker.stamp(ticket_i)
	_place_hub_cue()
	if hub_cue != null:
		hub_cue.show_brief(msg)


func _sync_hub_cue() -> void:
	_place_hub_cue()
	if hub_cue == null:
		return
	if hub_cue.brief_active():
		return
	if overlay != null and overlay.visible:
		hub_cue.clear_hold()
		return
	if _challenge_loot_wait or (not pending_feed.is_empty() and _is_toss_feed(str(pending_feed.get("kind", "")))):
		hub_cue.show_hold(PLAYER_COPY.text("challenge.full_hand", "Hand is full. Click an item to throw away."), "full_hand")
		return
	if not pending_mark.is_empty() and phase == "fighting":
		var mk: String = str(pending_mark.get("kind", ""))
		var line: String = PLAYER_COPY.text("cue.mark", "Pick a neighbor.")
		if mk == "hypnotize" or mk == "defeat_double_hp" or mk == "sling_any":
			line = "Click any monster."
		hub_cue.show_hold(line, "mark")
		return
	if challenge_draft_ui != null and challenge_draft_ui.visible and _draft_final_item:
		hub_cue.show_hold(PLAYER_COPY.text("challenge.final_item", "Final Item"), "final_item")
		return
	hub_cue.clear_hold()


func _place_hub_cue() -> void:
	if hub_cue == null or btn_wrap == null:
		return
	var bar: Control = hotbar_panel if hotbar_panel != null else hotbar_wrap
	var wr: Rect2 = btn_wrap.get_global_rect()
	var br: Rect2 = wr
	if bar != null:
		br = bar.get_global_rect()
	var h: float = maxf(wr.size.y, 56.0)
	var w: float = maxf(br.size.x, 420.0)
	var x: float = br.position.x - wr.position.x
	if wr.size.x <= 1.0:
		return
	hub_cue.position = Vector2(x, (wr.size.y - h) * 0.5)
	hub_cue.size = Vector2(w, h)
	if hub_cue.has_method("apply_pill"):
		hub_cue.apply_pill()


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


func _announce_slice(index: int, to: Vector2 = Vector2.INF, fast: bool = false) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	_trace_resolve("announce %s call=%s" % [str(s.get("card_id", "")), str(s.get("call_name", ""))])
	var call_n: String = str(s.get("call_name", "")).strip_edges()
	var mid: String = str(s.get("card_id", ""))
	if call_n == "" and mid == "triclops":
		call_n = "Cut And Run"
	if call_n == "" and str(s.get("name", "")).strip_edges() == "":
		return
	if ability_slash:
		var tex: Texture2D = null
		if art != null:
			tex = art.monster_still(mid)
		var ticket_i: int = -1
		if cascade_ticker != null and cascade_ticker.active:
			ticket_i = cascade_ticker.push(mid, tex)
		await ability_slash.play({
			"title": str(s.get("name", "")),
			"call": call_n,
			"tex": tex,
			"is_item": false,
			"card_id": mid,
			"fast": fast,
			"ticket": ticket_i,
			# Release after portrait punch/frames so HP/ATK tells land during
			# hold/slash-out (passive → resolve wall-clock). Deck seat cut-ins
			# call play() directly and still full-wait.
			"release_early": true,
		})
	_log_begin_monster(index)


func _announce_item_use(it: Dictionary, to: Vector2 = Vector2.INF, release_early: bool = true) -> void:
	if it.is_empty():
		return
	var title: String = str(it.get("name", "")).strip_edges()
	if title == "":
		return
	_log_flush()
	var uid: int = int(it.get("uid", -1))
	if hotbar_box:
		for c in hotbar_box.get_children():
			if _control_uid(c) == uid and c.has_method("bounce"):
				c.bounce()
				break
	if ability_slash:
		var tex: Texture2D = _item_icon_tex(it)
		var iid: String = str(it.get("card_id", ""))
		var ticket_i: int = -1
		if cascade_ticker != null and cascade_ticker.active:
			ticket_i = cascade_ticker.push(iid, tex)
		await ability_slash.play({
			"title": title,
			"call": "",
			"tex": tex,
			"is_item": true,
			"card_id": iid,
			"ticket": ticket_i,
			# Default: release after gutter snap-in so ATK/BLK land during hold/fade.
			# Signpost / Hypnotize must wait the full banner — overlapping it with
			# an owner lunge freezes (item banner + run frames + hall redraw).
			"release_early": release_early,
		})
	_log_begin_item(it)


func _ticker_push_poison(id: String) -> void:
	if cascade_ticker == null or not cascade_ticker.active:
		return
	var tex: Texture2D = null
	if ResourceLoader.exists("res://assets/ui/anim/poison_badge_drip_f0.png"):
		tex = load("res://assets/ui/anim/poison_badge_drip_f0.png") as Texture2D
	elif ResourceLoader.exists("res://assets/ui/anim/intent_chip_drop.png"):
		tex = load("res://assets/ui/anim/intent_chip_drop.png") as Texture2D
	elif ResourceLoader.exists("res://assets/icons/droplet.svg"):
		tex = load("res://assets/icons/droplet.svg") as Texture2D
	var ticket_i: int = cascade_ticker.push(id, tex)
	if ticket_i >= 0:
		cascade_ticker.light(ticket_i)
		cascade_ticker.stamp(ticket_i)


func _item_fx_dest(kind: String) -> Vector2:
	if kind.begins_with("atk") or kind == "egg_hurt" or kind == "choose":
		var at: int = _sling_aim if _sling_aim >= 0 else facing_index
		return _slice_hp_pos(at)
	if kind.begins_with("blk"):
		return _hub_blk_pos()
	if kind.begins_with("heal") or kind == "napalm":
		return _hub_hp_pos()
	if kind == "quiet" or kind == "atk_zero" or kind == "atk_drop":
		return _slice_from(facing_index)
	return _hub_hp_pos()



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
	if _gain_blocked_now():
		_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
		_log("discard", str(it.get("name", id)))
		if sfx:
			sfx.play("error", -10.0)
			sfx.play("cloth", -12.0)
		if get_tree():
			await get_tree().create_timer(0.45).timeout
		_toss_item(int(it.get("uid", -1)), false)
		_refresh()
		return
	if sfx:
		sfx.play_event(&"hand.gain", {"card_id": id})
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()



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



func _resume_facing_fight() -> void:
	phase = "fighting"
	_walker_busy = false
	if wheel_view:
		wheel_view.clear_slay()
	_show_fight_portrait()
	_tune_combat_stage()
	_refresh()


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
	if await _play_chain_cancel():
		var keep: int = int(s.get("hp", 0))
		if keep <= 0:
			keep = int(s.get("hp_pre_hit", 0))
		if keep <= 0:
			keep = 1
		s["hp"] = keep
		s["hp_locked"] = false
		s["spin_locked"] = index == facing_index
		s.erase("hp_pre_hit")
		wheel[index] = s
		facing_index = index
		_resume_facing_fight()
		return true
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


func _highest_hand_atk() -> int:
	var best: int = 0
	for it in hotbar:
		var sc: int = _item_atk_score(it)
		if sc > best:
			best = sc
	return best


func _note_hp_lost(n: int) -> void:
	if n <= 0:
		return
	last_hp_lost = n
	bled.emit(n)
	_shake_screen()
	if n != 2:
		return
	var has_pace: bool = false
	for it in hotbar:
		if str(it.get("card_id", "")) == "pacemaker" and not bool(it.get("spent", false)):
			has_pace = true
			break
	if has_pace:
		_heal(1)


func _bank_stone_wall() -> void:
	if _stone_armed:
		_stone_saved = blk
		_stone_armed = false


func _amalgam_after_use() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var s: Dictionary = wheel[facing_index]
	if str(s.get("card_id", "")) != "amalgam":
		return
	if _is_silenced(s) or int(s.get("hp", 0)) <= 0:
		return
	s["hp"] = int(s.get("hp", 0)) * 2
	s["hp_max"] = int(s.get("hp_max", s.get("hp", 0))) * 2
	s["atk"] = int(s.get("atk", 0)) * 2
	s["hp_locked"] = true
	s["atk_locked"] = true
	s["atk_innate"] = int(s["atk"])
	wheel[facing_index] = s
	_log("on_resolve", "Amalgam doubles  →  %s/%s  ATK %s" % [s["hp"], s["hp_max"], s["atk"]])


func _eel_on_blk(n: int) -> void:
	if n <= 0 or facing_index < 0 or facing_index >= wheel.size():
		return
	var s: Dictionary = wheel[facing_index]
	if str(s.get("card_id", "")) != "eel":
		return
	if _is_silenced(s) or int(s.get("hp", 0)) <= 0:
		return
	_eel_take_atk(n)


func _eel_take_atk(n: int) -> void:
	await _deal_atk_at(facing_index, n)


func _fairy_after_spin() -> void:
	## SP-23: Fairy no longer heals on Spin. The bottle is granted on a clean Defeat.
	return


func _grant_fairy_hp(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("kind", "")) != "monster":
		return
	if int(s.get("hp", 0)) <= 0:
		return
	s["fairy_dust"] = int(s.get("fairy_dust", 0)) + 2
	s["hp"] = int(s.get("hp", 0)) + 2
	s["hp_max"] = int(s.get("hp_max", s.get("hp", 0))) + 2
	wheel[index] = s
	_log("on_spin", "Fairy Dust +2  →  %s HP %s" % [s.get("name", "?"), s["hp"]])
	if sfx:
		sfx.play("pluck", -10.0)
	if wheel_view:
		wheel_view.hit_feedback(index, -2, 0)


func _try_phoenix_cycle(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	var id: String = str(s.get("card_id", ""))
	if _is_silenced(s):
		return false
	var to_id := ""
	if id == "phoenix_egg":
		to_id = "phoenix"
	else:
		## SP-21: Phoenix lays the egg onto the deck in _on_owner_defeated, then leaves normally.
		return false
	if not monsters_by_id.has(to_id):
		return false
	var nxt: Dictionary = _make_monster(to_id)
	nxt["slot"] = str(s.get("slot", ""))
	wheel[index] = nxt
	_sync_wheel_stats()
	if wheel_view:
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, facing_index, "none")
	_log("on_resolve", "%s Flee and become %s" % [s.get("name", id), nxt.get("name", to_id)])
	if sfx:
		sfx.play_event(&"mon.commander_flee")
	if combat_stage and index == facing_index:
		combat_stage.show_monster(to_id, int(nxt.get("tier", 1)))
		_tune_combat_stage()
	if index == facing_index:
		await _flee_spin()
	await _sweep_triclops_three()
	return true


func _try_triclops_bail(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "triclops":
		return false
	if _is_silenced(s):
		return false
	var hp_now: int = int(s.get("hp", 0))
	if hp_now == 3:
		return false
	var before: int = int(s.get("triclops_before", hp_now if hp_now > 0 else s.get("hp_max", 7)))
	s["hp"] = maxi(0, before - 2)
	s.erase("triclops_before")
	s["hp_locked"] = true
	s["spin_locked"] = false
	s["crossbowed"] = false
	wheel[index] = s
	_log("on_resolve", "Triclops −2 HP and Flee  →  %s" % s["hp"])
	if int(s["hp"]) <= 0:
		return false
	if index == facing_index:
		await _flee_spin()
	await _sweep_triclops_three()
	return true


func _check_triclops_three(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "triclops":
		return false
	if int(s.get("hp", 0)) != 3:
		return false
	_log("on_resolve", "Triclops has 3 HP")
	if index == facing_index:
		await _begin_slay()
		return true
	return false


func _sweep_triclops_three() -> void:
	for i in range(wheel.size() - 1, -1, -1):
		if str(wheel[i].get("card_id", "")) != "triclops":
			continue
		if int(wheel[i].get("hp", 0)) != 3:
			continue
		if i == facing_index and phase == "fighting":
			await _begin_slay()
			return


func _fungal_host(except_i: int) -> int:
	var best := 99
	var cands: Array[int] = []
	for i in range(wheel.size()):
		if i == except_i:
			continue
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		if str(s.get("card_id", "")) == "fungal_colony":
			continue
		var tier: int = _tier_of(s)
		if tier >= 3:
			continue
		if tier < best:
			best = tier
			cands = [i]
		elif tier == best:
			cands.append(i)
	if cands.is_empty():
		return -1
	return cands[rng.randi_range(0, cands.size() - 1)]


func _fungal_infect(src_i: int, dst_i: int) -> void:
	var src: Dictionary = wheel[src_i]
	var nid := "fungal_colony"
	if not monsters_by_id.has(nid):
		return
	var copy: Dictionary = _make_monster(nid)
	copy["slot"] = str(wheel[dst_i].get("slot", ""))
	copy["hp"] = int(src.get("hp", copy.get("hp", 0)))
	copy["hp_max"] = int(src.get("hp_max", copy.get("hp_max", 0)))
	copy["atk"] = maxi(0, int(src.get("atk", 0)) - int(src.get("aura_atk", 0)))
	copy["poison"] = _poison_of(src)
	copy["poisoned"] = int(copy["poison"]) > 0
	copy["spin_locked"] = true
	copy["pack_tier"] = int(src.get("pack_tier", copy.get("pack_tier", 2)))
	copy["pack_kind"] = str(src.get("pack_kind", copy.get("pack_kind", "draft")))
	var old_name: String = str(wheel[dst_i].get("name", "?"))
	wheel[dst_i] = copy
	_sync_wheel_stats()
	_log("on_resolve", "Cordycepticide %s → %s" % [old_name, str(wheel[dst_i].get("name", nid))])
	_refresh()
	if wheel_view and wheel_view.has_method("pulse_infect"):
		wheel_view.pulse_infect(dst_i)
	_flash_screen(Color("c77dff"), 0.5)
	if sfx:
		sfx.play("whoosh", -4.0, 0.72)
		sfx.play("pluck", -6.0, 0.65)
	if ability_slash:
		var tex: Texture2D = tex_by_monster.get(nid, null)
		await ability_slash.play({
			"title": str(src.get("name", "Fungal Colony")),
			"call": str(src.get("call_name", "Cordycepticide")),
			"tex": tex,
			"is_item": false,
			"card_id": nid,
		})
	if get_tree():
		await get_tree().create_timer(0.4).timeout


func _fungal_on_damage(seat: int, attacker: Dictionary) -> void:
	if str(attacker.get("card_id", "")) != "fungal_colony":
		return
	if seat < 0 or seat >= wheel.size():
		return
	if _is_silenced(wheel[seat]):
		return
	var body: Dictionary = wheel[seat]
	if str(body.get("card_id", "")) != "fungal_colony":
		return
	if int(body.get("hp", 0)) <= 0:
		var keep_hp: int = int(body.get("hp_pre_hit", 0))
		if keep_hp <= 0:
			keep_hp = int(body.get("hp_max", _card_base_hp("fungal_colony")))
		if keep_hp <= 0:
			keep_hp = 1
		body["hp"] = keep_hp
		body.erase("hp_pre_hit")
		wheel[seat] = body
		if wheel_view and wheel_view.slay_index == seat:
			wheel_view.clear_slay()
		_refresh()
	var host: int = _fungal_host(seat)
	if host >= 0:
		await _fungal_infect(seat, host)
	else:
		_log("on_resolve", "Cordycepticide — no host")
	if seat != facing_index:
		return
	_fungal_stop_fight = true
	if await _flee_spin():
		return
	phase = "fighting"
	_walker_busy = false
	_refresh()


func _apply_polymorph(index: int, it: Dictionary) -> void:
	if facing_index < 0 or facing_index >= wheel.size() or index < 0 or index >= wheel.size():
		_undo_abort()
		return
	var src: Dictionary = wheel[index]
	var dst_slot: String = str(wheel[facing_index].get("slot", ""))
	var nid: String = str(src.get("card_id", ""))
	if not monsters_by_id.has(nid):
		_undo_abort()
		return
	var copy: Dictionary = _make_monster(nid)
	copy["slot"] = dst_slot
	copy["hp"] = int(src.get("hp", copy.get("hp", 0)))
	copy["hp_max"] = int(src.get("hp_max", copy.get("hp_max", 0)))
	copy["atk"] = maxi(0, int(src.get("atk", 0)) - int(src.get("aura_atk", 0)))
	copy["poison"] = _poison_of(src)
	copy["poisoned"] = int(copy["poison"]) > 0
	copy["spin_locked"] = true
	copy["polymorphed_this_fight"] = true
	copy["pack_tier"] = int(src.get("pack_tier", copy.get("pack_tier", 1)))
	copy["pack_kind"] = str(src.get("pack_kind", copy.get("pack_kind", "draft")))
	if nid == "kobold_trapper":
		copy["trapper_growth"] = int(src.get("trapper_growth", 0))
	wheel[facing_index] = copy
	it["spent"] = true
	await _count_item_use()
	_toss_item(int(it["uid"]), false)
	_sync_wheel_stats()
	var now: Dictionary = wheel[facing_index]
	_log("on_item_use", "Polymorph → %s" % now.get("name", nid))
	if combat_stage:
		combat_stage.show_monster(str(now.get("card_id", nid)), _tier_of(now))
		_tune_combat_stage()
		if combat_stage.has_method("play_transform"):
			combat_stage.play_transform()
	if sfx:
		sfx.play("whoosh", -8.0, 1.15)
		sfx.play("pluck", -10.0, 1.25)
	await _after_item_resolved(it)
	_undo_finish_item()
	_refresh()


func _apply_catapult() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var s: Dictionary = wheel[facing_index]
	var hole: int = facing_index
	var ejected := {
		"id": str(s.get("card_id", "")),
		"hp": int(s.get("hp", 0)),
		"hp_max": int(s.get("hp_max", 0)),
		"atk": maxi(0, int(s.get("atk", 0)) - int(s.get("aura_atk", 0))),
		"poison": _poison_of(s),
	}
	challenge_deck.append(ejected)
	if dungeon_deck_ui:
		dungeon_deck_ui.set_count(challenge_deck.size())
	if int(s.get("died_seq", 0)) <= 0:
		_note_death(s)
	_hole_serial += 1
	var slot: String = str(s.get("slot", SLOT_ORDER[hole] if hole < SLOT_ORDER.size() else str(hole)))
	wheel[hole] = {
		"kind": "empty",
		"slot": slot,
		"challenge_hole": true,
		"loot_tier": _tier_of(s),
		"loot_name": str(s.get("name", "?")),
		"loot_id": str(s.get("card_id", "")),
		"mimic_gift": false,
		"hole_id": _hole_serial,
		"died_seq": int(s.get("died_seq", 0)),
		"died_batch": int(s.get("died_batch", 0)),
	}
	_log("on_resolve", "%s Ejected" % s.get("name", "?"))
	_walker_busy = true
	_sync_buttons()
	if combat_stage:
		var fade := create_tween()
		fade.tween_property(combat_stage, "modulate:a", 0.0, 0.2)
		await get_tree().create_timer(0.22).timeout
		combat_stage.hide_stage()
		combat_stage.modulate.a = 1.0
		if player_stage:
			player_stage.hide_stage()
	facing_index = -1
	phase = "ready"
	if wheel_view:
		wheel_view.facing_index = -1
		wheel_view.selected_index = -1
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, -1, "none")
	_sync_challenge_peek()
	_sync_wheel_stats()
	_refresh()
	if _monsters_left() == 0 and challenge_deck.is_empty():
		if await _try_release_bag():
			_refresh()
			_spin_after_holes = true
		else:
			_enter_dungeon_clear()
	else:
		if sfx:
			sfx.set_combat_music(false)
		_spin_after_holes = true


func _deck_card_id(v: Variant) -> String:
	if typeof(v) == TYPE_DICTIONARY:
		var d: Dictionary = v
		var a: String = str(d.get("id", ""))
		if a != "":
			return a
		return str(d.get("card_id", ""))
	return str(v)


func _apply_deck_scars(index: int, snap: Dictionary) -> void:
	if index < 0 or index >= wheel.size() or snap.is_empty():
		return
	if not snap.has("hp"):
		return
	var s: Dictionary = wheel[index]
	s["hp"] = int(snap.get("hp", s.get("hp", 0)))
	if snap.has("hp_max"):
		s["hp_max"] = int(snap.get("hp_max", s.get("hp_max", 0)))
	if snap.has("atk"):
		s["atk"] = int(snap.get("atk", s.get("atk", 0)))
	if snap.has("poison"):
		s["poison"] = int(snap.get("poison", 0))
		s["poisoned"] = int(s["poison"]) > 0
	wheel[index] = s




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
	var buckler_ok: bool = true
	for j in _damsel_neighbors(facing_index):
		var nm: Dictionary = wheel[j]
		for _h in range(_hit_count(j)):
			var swing: Dictionary = _preview_swing(nm, left_blk, buckler_ok)
			total += int(swing["dmg"])
			left_blk = int(swing["blk"])
			if bool(swing.get("used_buckler", false)):
				buckler_ok = false
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
		if _blood_threshes(j):
			await _shark_attack_player(j)
			if hp <= 0:
				await _bleed_end()
				_player_down()
				return
			continue
		var hits: int = _hit_count(j)
		for h in range(hits):
			if hp <= 0:
				break
			await _owner_attack(nm, h + 1, hits, j)
			await _after_self_deconstruct(j)
			if j >= 0 and j < wheel.size():
				nm = wheel[j]
			if hp <= 0:
				break
			if j >= 0 and j < wheel.size() and int(wheel[j].get("hp", 0)) <= 0:
				break
			if hits > 1 and h < hits - 1:
				await get_tree().create_timer(0.08).timeout
		if hp <= 0:
			await _bleed_end()
			_player_down()
			return
	await _slay_dead_after_watch()
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
	var base_n: int = _card_base_atk("berserker")
	var any := false
	var angry: Array[int] = []
	for i in range(wheel.size()):
		var s: Dictionary = wheel[i]
		if str(s.get("card_id", "")) != "berserker":
			continue
		if int(s.get("hp", 0)) <= 0 or str(s.get("kind", "")) != "monster":
			continue
		if _is_silenced(s):
			continue
		var hot := rng.randf() < 0.5
		if has_meta("qa_berserker_hot"):
			hot = bool(get_meta("qa_berserker_hot"))
		var intrinsic: int = base_n + int(s.get("outburst", 0))
		var nxt: int = P1.next_intrinsic_atk(intrinsic, hot)
		s["outburst"] = nxt - base_n
		wheel[i] = s
		any = true
		var delta: int = nxt - intrinsic
		_log("var", "Hot and Cold %s%d  →  %s" % ["+" if delta >= 0 else "−", absi(delta), nxt])
		if i == facing_index and combat_stage:
			_tune_combat_stage()
			if hot and combat_stage.has_method("play_rage_up"):
				combat_stage.play_rage_up()
			elif not hot and combat_stage.has_method("play_rage_down"):
				combat_stage.play_rage_down()
		elif wheel_view:
			wheel_view.hit_feedback(i, 0, delta)
		if sfx:
			if hot:
				sfx.play("error_big", -10.0, 0.55)
				sfx.play("chop", -8.0, 0.55)
			else:
				sfx.play("cloth", -10.0, 0.8)
		if delta > 0:
			angry.append(i)
	if any:
		_sync_wheel_stats()
	for ai in angry:
		if phase != "fighting":
			break
		await _berserker_angry_tell(int(ai))


func _berserker_angry_tell(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if str(wheel[index].get("card_id", "")) != "berserker":
		return
	await _announce_slice(index, _slice_atk_pos(index))
	if ability_slash != null:
		var guard := 0
		while ability_slash.visible and guard < 90:
			await get_tree().process_frame
			guard += 1
	if phase != "fighting":
		return
	_berserk_line = "I'm getting angry!"
	_berserk_talk_index = index
	_place_speech()
	if get_tree():
		await get_tree().create_timer(1.15).timeout
	if _berserk_talk_index != index:
		return
	_berserk_line = ""
	_berserk_talk_index = -1
	if _spoken_key.begins_with("berserker|"):
		_spoken_key = ""
	if speech_box:
		speech_box.hide_speech()


func _step_hexs() -> bool:
	var fired: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "hex":
			continue
		if bool(it.get("spent", false)):
			continue
		if bool(it.get("petrified", false)):
			continue
		var n: int = int(it.get("hex_n", 6)) - 1
		it["hex_n"] = n
		_log("var", "Hex %s" % n)
		if n <= 0:
			fired.append(int(it.get("uid", -1)))
	if fired.is_empty():
		return false
	if facing_index >= 0 and facing_index < wheel.size() and _undying(wheel[facing_index]):
		for uid in fired:
			var kept_hex: Dictionary = _find_item(int(uid))
			if kept_hex.is_empty():
				continue
			kept_hex["hex_n"] = 6
			kept_hex["spent"] = true
			kept_hex["keep_after"] = true
			_log("keep", str(kept_hex.get("name", "Hex")))
			_toss_item(int(uid), true)
		var lich_down: bool = false
		for _uid in fired:
			if facing_index < 0 or facing_index >= wheel.size():
				break
			if int(wheel[facing_index].get("hp", 0)) <= 0:
				break
			if await _lich_chip_defeat(facing_index):
				lich_down = true
				break
		if lich_down:
			_log("on_resolve", "undying")
			if sfx:
				sfx.play_event(&"defeat.use")
			await _begin_slay()
			return true
		return false
	for uid in fired:
		var hex: Dictionary = _find_item(int(uid))
		if hex.is_empty():
			continue
		hex["spent"] = true
		_toss_item(int(uid), false)
	_log("on_resolve", "defeat")
	if sfx:
		sfx.play_event(&"defeat.use")
	await _begin_slay()
	return true


func _step_rusts() -> void:
	var gone: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "rust":
			continue
		if bool(it.get("spent", false)):
			continue
		it["rust_n"] = int(it.get("rust_n", 3)) - 1
		it["rust_seen"] = true
		_log("var", "Rust %s" % it["rust_n"])
		if int(it.get("rust_n", 0)) <= 0:
			gone.append(int(it.get("uid", -1)))
	for uid in gone:
		_discard_from_hand(int(uid))
	if not gone.is_empty():
		_hotbar_sig = ""


func _step_marbles() -> void:
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "marble":
			continue
		if bool(it.get("spent", false)):
			continue
		it["marble_n"] = int(it.get("marble_n", 0)) + 1
		# Quiet counter bump — still stamp the cascade when the step fires.
		if cascade_ticker != null and cascade_ticker.active:
			var tex: Texture2D = _item_icon_tex(it)
			var ticket_i: int = cascade_ticker.push("marble", tex)
			if ticket_i >= 0:
				cascade_ticker.light(ticket_i)
				cascade_ticker.stamp(ticket_i)
		var card: Control = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("marble_grow"):
			card.marble_grow(int(it.get("marble_n", 0)))


func _apply_bag_marbles(it: Dictionary) -> void:
	_log("on_item_use", str(it.get("name", "Bag of Marbles")))
	it["spent"] = true
	var bag_from: Vector2 = _item_card_global(int(it.get("uid", -1)))
	await _count_item_use()
	_toss_item(int(it.get("uid", -1)), false)
	var blocked: bool = _gain_blocked_now()
	if blocked:
		_flash_banner(PLAYER_COPY.text("combat.cant_gain", "Can't Gain Item"))
		_log("on_item_use", "no Marbles")
		if sfx:
			sfx.play("error", -10.0)
		_sync_wheel_stats()
		return
	var made := 0
	var new_uids: Array = []
	while hotbar.size() < MARBLE_FILL:
		var tok: Dictionary = _make_item("marble")
		hotbar.append(tok)
		new_uids.append(int(tok.get("uid", -1)))
		made += 1
	if made > 0:
		_sort_hotbar()
		_log("on_draft", "gain %s Marbles" % made)
		if sfx:
			sfx.play_event(&"hand.gain", {"card_id": "marble"})
		_hotbar_sig = ""
		_sync_hotbar()
		var delay: float = 0.0
		for uid in new_uids:
			var card: Control = _hotbar_card_by_uid(int(uid))
			if card != null and card.has_method("marble_roll_in"):
				card.marble_roll_in(bag_from, delay)
				delay += 0.05
	_sync_wheel_stats()


func _item_is_chakram(it: Dictionary) -> bool:
	if str(it.get("card_id", "")) == "chakram":
		return true
	return str(_ops_of(it).get("kind", "")) == "chakram"


func _item_verb_muted(it: Dictionary) -> bool:
	if bool(it.get("spent", false)):
		return true
	if _item_stoned(it):
		return true
	return false


func _item_grants_block(it: Dictionary) -> bool:
	var kind: String = str(_ops_of(it).get("kind", ""))
	if kind == "shield_alt":
		return _shield_face(it) == "blk"
	if kind == "marble" or kind == "signpost":
		return true
	return kind.begins_with("blk")


func _item_deals_attack(it: Dictionary) -> bool:
	if _item_is_chakram(it):
		return bool(_chakram_halves(it).get("atk", false))
	var kind: String = str(_ops_of(it).get("kind", ""))
	if kind == "shield_alt":
		return _shield_face(it) == "atk"
	if kind == "sling" or str(it.get("card_id", "")) == "sling":
		return false
	if kind == "marble":
		return true
	if kind == "atk_zero" or kind == "atk_drop":
		return false
	if kind.begins_with("atk"):
		return true
	if kind == "choose":
		var opts: Variant = _ops_of(it).get("options", [])
		if typeof(opts) == TYPE_ARRAY:
			for ov in opts:
				if typeof(ov) == TYPE_DICTIONARY and (ov as Dictionary).has("atk"):
					return true
	return false


func _chakram_halves(self_it: Dictionary) -> Dictionary:
	# Scanning the hand calls _item_view / _item_deals_attack, and those call
	# back into this for Chakram (Sling, highest-Attack Block, Paci-Fist). Treat
	# Chakram as providing neither verb while the scan is already running.
	if _chakram_halves_busy:
		return {"blk": false, "atk": false}
	_chakram_halves_busy = true
	var uid: int = int(self_it.get("uid", -1))
	var has_blk := false
	var has_atk := false
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -2)) == uid:
			continue
		if _item_is_chakram(it):
			continue
		if _item_verb_muted(it):
			continue
		if not bool(_item_view(it).get("can_use", false)):
			continue
		if _item_grants_block(it):
			has_blk = true
		if _item_deals_attack(it):
			has_atk = true
	_chakram_halves_busy = false
	return {"blk": not has_blk, "atk": not has_atk}


func _apply_chakram(it: Dictionary) -> bool:
	var halves: Dictionary = _chakram_halves(it)
	var do_blk: bool = bool(halves.get("blk", false))
	var do_atk: bool = bool(halves.get("atk", false))
	if not do_blk and not do_atk:
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		return false
	_log("on_item_use", str(it.get("name", "Chakram")))
	if do_blk:
		_gain_blk(3)
		_log("blk", "+%s  →  %s" % [3, blk])
	if do_atk:
		var hit: int = _atk_with_head(3)
		last_item_atk = hit
		if await _deal_atk(hit):
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it.get("uid", -1)), false)
			return true
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [hit, wheel[facing_index]["hp"]])
	return false


func _apply_marble(it: Dictionary) -> bool:
	var n: int = int(it.get("marble_n", 0))
	var as_atk: bool = rng.randf() < 0.5
	var skip_fx: bool = OS.has_feature("editor") and logic_qa != null and bool(logic_qa.busy)
	var card: Control = _hotbar_card_by_uid(int(it.get("uid", -1)))
	if not skip_fx and card != null and card.has_method("play_marble"):
		await card.play_marble(as_atk)
		var hold_path: String = "res://assets/dungeon/anim/marble_red.png" if as_atk else "res://assets/dungeon/anim/marble_blue.png"
		var hold_tex: Texture2D = load(hold_path) as Texture2D if ResourceLoader.exists(hold_path) else _item_icon_tex(it)
		var from: Vector2 = _item_card_global(int(it.get("uid", -1)))
		var to: Vector2 = _item_fx_dest("atk") if as_atk else _hub_blk_pos()
		if from != Vector2.ZERO and to != Vector2.ZERO:
			await _fly_courier(hold_tex, from, to, 0.4)
	var call: String = "Attack" if as_atk else "Block"
	_flash_banner(call, "marble", _item_icon_tex(it))
	_log("on_item_use", str(it.get("name", "Marble")))
	if as_atk:
		var hit: int = _atk_with_head(n)
		last_item_atk = hit
		if await _deal_atk(hit):
			it["spent"] = true
			await _count_item_use()
			_toss_item(int(it.get("uid", -1)), false)
			return true
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [hit, wheel[facing_index]["hp"]])
		return false
	_gain_blk(maxi(0, n))
	_log("blk", "+%s  →  %s" % [maxi(0, n), blk])
	return false


func _apply_queen_eggs_on_spin() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	# Every living Queen lays one Egg, including the face. Then spinning her eats them.
	for i in range(wheel.size()):
		if str(wheel[i].get("card_id", "")) != "spider_queen":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		await _lay_spider_egg(i)
	_refresh()
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


func _lay_spider_egg(index: int) -> void:
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


func _apply_cultist_pacts_on_spin() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	var n: int = wheel.size()
	var seats: Array[int] = [facing_index]
	if n >= 2:
		seats.append((facing_index + 1) % n)
		seats.append((facing_index + n - 1) % n)
	var seen := {}
	for i in seats:
		if seen.has(i):
			continue
		seen[i] = true
		if i < 0 or i >= wheel.size():
			continue
		if str(wheel[i].get("card_id", "")) != "cultist":
			continue
		if _is_silenced(wheel[i]):
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		await _grant_blood_pact(i)
	_refresh()


func _grant_blood_pact(index: int) -> void:
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex("blood_pact")
	if tex == null:
		tex = tex_by_item.get("blood_pact", null)
	var from: Vector2 = Vector2.ZERO
	var to: Vector2 = Vector2.ZERO
	if wheel_view:
		from = wheel_view.slice_portrait_global(index)
	if hotbar_box:
		to = hotbar_box.global_position + hotbar_box.size * 0.5
	await _announce_slice(index, to if to != Vector2.ZERO else _hub_hp_pos())
	if tex != null and from != Vector2.ZERO:
		await _fly_courier(tex, from, to, 0.42)
	await _try_gain_item("blood_pact")


func _apply_juggernaut_on_spin() -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "juggernaut":
		return
	if int(m.get("hp", 0)) <= 0:
		return
	if _is_silenced(m):
		return
	await _juggernaut_hand_shield()


func _hotbar_empty_slot_global() -> Vector2:
	if _hotbar_park_overflow() and hotbar_overflow != null:
		var parked: Array = hotbar_overflow.get_children()
		if not parked.is_empty():
			var last_park: Control = parked[parked.size() - 1]
			return last_park.global_position + last_park.size * 0.5
		if hotbar_panel != null:
			var pr: Rect2 = hotbar_panel.get_global_rect()
			return Vector2(pr.position.x + pr.size.x * 0.5, pr.position.y - 64.0)
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


func _magicat_is_target(it: Dictionary) -> bool:
	if typeof(it) != TYPE_DICTIONARY:
		return false
	if _item_verb_muted(it):
		return false
	if _item_is_chakram(it):
		return true
	return _item_grants_block(it) or _item_deals_attack(it)


func _magicat_pool_uids() -> Array:
	var out: Array = []
	for it in hotbar:
		if not _magicat_is_target(it):
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			out.append(uid)
	return out


func _magicat_morph(it: Dictionary) -> void:
	var n: int = int(_item_view(it).get("n", 0))
	var keep_uid: int = int(it.get("uid", -1))
	var fresh: Dictionary = _make_item("marble")
	it.clear()
	for k in fresh.keys():
		it[k] = fresh[k]
	it["uid"] = keep_uid
	it["marble_n"] = n
	it["cats_eye"] = true


func _poison_dose(it: Dictionary) -> int:
	if it.has("poison_n"):
		return maxi(int(it.get("poison_n", 0)), 0)
	return maxi(int(_ops_of(it).get("n", 5)), 0)


func _scorpion_is_target(it: Dictionary) -> bool:
	if typeof(it) != TYPE_DICTIONARY or bool(it.get("spent", false)):
		return false
	if _item_is_chakram(it):
		return true
	return _item_grants_block(it) or _item_deals_attack(it)


func _scorpion_value(it: Dictionary) -> int:
	if _item_is_chakram(it):
		return 3
	return maxi(int(_item_view(it).get("n", 0)), 0)


func _scorpion_morph(it: Dictionary) -> void:
	var n: int = _scorpion_value(it)
	var keep_uid: int = int(it.get("uid", -1))
	var fresh: Dictionary = _make_item("poison_flask")
	it.clear()
	for k in fresh.keys():
		it[k] = fresh[k]
	it["uid"] = keep_uid
	it["poison_n"] = n
	var ops: Dictionary = it.get("ops", {})
	ops["kind"] = "mark_poison"
	ops["n"] = n
	it["ops"] = ops
	it["ability"] = "Mark a Neighbor with %d Poison." % n
	it["explainer"] = "Neighbor gets %d Poison" % n


func _apply_scorpion_on_spin() -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "scorpion":
		return
	if int(m.get("hp", 0)) <= 0 or _is_silenced(m):
		return
	var pool: Array = []
	for it in hotbar:
		if not _scorpion_is_target(it):
			continue
		var uid: int = int(it.get("uid", -1))
		if uid >= 0:
			pool.append(uid)
	if pool.is_empty():
		_log("on_spin", "Venom Sac — nothing")
		return
	var pick: int = int(pool[rng.randi() % pool.size()])
	_walker_busy = true
	_sync_buttons()
	var dest: Vector2 = _item_card_global(pick)
	if dest == Vector2.ZERO:
		dest = _hub_hp_pos()
	await _announce_slice(facing_index, dest)
	if wheel_view:
		wheel_view.aura_index = facing_index
	if sfx:
		sfx.play_event(&"mon.cleric_tax")
	if get_tree():
		await get_tree().create_timer(0.55).timeout
	if wheel_view:
		wheel_view.aura_index = -1
	if phase != "fighting":
		_walker_busy = false
		return
	var chosen: Dictionary = _find_item(pick)
	if chosen.is_empty() or not _scorpion_is_target(chosen):
		_walker_busy = false
		_refresh()
		return
	var shown: int = _scorpion_value(chosen)
	_scorpion_morph(chosen)
	_log("on_spin", "Venom Sac  →  Poison Flask %s" % shown)
	_hotbar_sig = ""
	_refresh()
	await _play_item_transform(pick)
	_sort_hotbar()
	_hotbar_sig = ""
	_walker_busy = false
	_refresh()


func _apply_magicat_on_spin() -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "magicat":
		return
	if int(m.get("hp", 0)) <= 0:
		return
	if _is_silenced(m):
		return
	var pool: Array = _magicat_pool_uids()
	var picks: Array = []
	while picks.size() < 2 and not pool.is_empty():
		var at: int = rng.randi() % pool.size()
		picks.append(int(pool[at]))
		pool.remove_at(at)
	_walker_busy = true
	_sync_buttons()
	var dest: Vector2 = _hub_hp_pos()
	if not picks.is_empty():
		dest = _item_card_global(int(picks[0]))
	await _announce_slice(facing_index, dest)
	if wheel_view:
		wheel_view.aura_index = facing_index
	if sfx:
		sfx.play_event(&"mon.cleric_tax")
	if get_tree():
		await get_tree().create_timer(0.55).timeout
	if wheel_view:
		wheel_view.aura_index = -1
	var from: Vector2 = Vector2.ZERO
	if wheel_view:
		from = wheel_view.slice_portrait_global(facing_index)
	var light: Texture2D = null
	if art != null:
		light = art.vfx.get("magic", art.vfx.get("spark", null))
	for uid in picks:
		if phase != "fighting":
			break
		var it: Dictionary = _find_item(int(uid))
		if it.is_empty() or not _magicat_is_target(it):
			continue
		var to: Vector2 = _item_card_global(int(uid))
		if to == Vector2.ZERO:
			to = dest
		if light != null and from != Vector2.ZERO:
			await _fly_courier(light, from, to, 0.34)
		_magicat_morph(it)
		_log("on_spin", "Cat's Eye  →  %s Marble" % int(it.get("marble_n", 0)))
		_hotbar_sig = ""
		_refresh()
		await _play_item_transform(int(uid))
	_sort_hotbar()
	_hotbar_sig = ""
	_walker_busy = false
	_refresh()


func _apply_poison_frog_on_spin() -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "poison_frog":
		return
	if int(m.get("hp", 0)) <= 0:
		return
	if _is_silenced(m):
		return
	_log_begin_monster(facing_index)
	_gain_player_poison(2)


func _poison_frog_on_hit(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "poison_frog":
		return
	if _is_silenced(m):
		return
	_log_begin_monster(index)
	_gain_player_poison(2)


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
	if _bleed_hold == 0 and bleed_pulse != null:
		await bleed_pulse.flush_queue()


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
		if _control_uid(c) == uid:
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
	return keep_blocked_this_fight


func _silence_key(s: Dictionary) -> String:
	var uid: int = int(s.get("seat_uid", -1))
	if uid >= 0:
		return "seat:%s" % uid
	return ""


func _mark_silenced(s: Dictionary, on: bool = true) -> void:
	s["silenced"] = on
	var key: String = _silence_key(s)
	if key == "":
		return
	if on:
		silenced[key] = true
	else:
		silenced.erase(key)


func _is_silenced(who) -> bool:
	if typeof(who) == TYPE_DICTIONARY:
		var s: Dictionary = who
		if bool(s.get("silenced", false)):
			return true
		var key: String = _silence_key(s)
		if key != "":
			return bool(silenced.get(key, false))
		return false
	if typeof(who) == TYPE_INT:
		var idx: int = int(who)
		if idx >= 0 and idx < wheel.size():
			return _is_silenced(wheel[idx])
		return bool(silenced.get("seat:%s" % idx, false))
	var key := str(who)
	if key.begins_with("seat:"):
		return bool(silenced.get(key, false))
	# Leftover card-id strings mean the facing copy only. Never every copy.
	if facing_index >= 0 and facing_index < wheel.size():
		var face: Dictionary = wheel[facing_index]
		if str(face.get("card_id", "")) == key:
			return _is_silenced(face)
	return false


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
	if not skip_twins:
		_eel_on_blk(n)
	return n


func _lantern_ability(n: int) -> String:
	return "Heal %d, then increase this number by 1. Keep this if you are still missing HP." % maxi(1, n)


func _lantern_explainer(n: int) -> String:
	var shown: int = maxi(1, n)
	return "(HEAL %d → %d) Keep if still missing HP" % [shown, shown + 1]


func _lantern_set_n(it: Dictionary, n: int) -> void:
	var shown: int = maxi(1, n)
	var live_ops: Variant = it.get("ops", {})
	if typeof(live_ops) == TYPE_DICTIONARY:
		(live_ops as Dictionary)["n"] = shown
	it["ability"] = _lantern_ability(shown)
	it["explainer"] = _lantern_explainer(shown)
	it["log_hint"] = "Heal %d, keep if still hurt" % shown


func _heal(n: int) -> int:
	var before: int = hp
	hp = mini(HP_MAX, hp + maxi(0, n))
	var gained: int = hp - before
	_log("hp", "heal +%s  now %s" % [gained, hp])
	if gained <= 0:
		return 0
	if wheel_view and wheel_view.has_method("play_hero"):
		wheel_view.play_hero("heal")
		if wheel_view.has_method("wait_hero_frame"):
			await wheel_view.wait_hero_frame("heal", 2)
	_player_play("heal")
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
		_note_hp_lost(before - hp)
	_log("hp", "bleed -%s  now %s" % [n, hp])
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


func _napalm_neighbor_seats() -> Array[int]:
	var out: Array[int] = []
	if facing_index < 0:
		return out
	var n: int = wheel.size()
	if n < 2:
		return out
	var seen := {}
	for off in [1, n - 1]:
		var j: int = (facing_index + off) % n
		if j == facing_index or seen.has(j):
			continue
		seen[j] = true
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out


func _napalm_set_monster(index: int) -> int:
	if index < 0 or index >= wheel.size():
		return 0
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return 0
	var before: int = int(m.get("hp", 0))
	if before <= 0:
		return 0
	if before <= 1:
		return 0
	if _undying(m):
		_log("var", "no HP loss")
		return 0
	m["hp"] = 1
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "slime_boss":
		m["atk"] = 1
	wheel[index] = m
	_log("hp", "%s  now 1" % m.get("name", "?"))
	if wheel_view:
		wheel_view.punch_hp(index)
	return before - 1


func _apply_napalm() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var face: int = facing_index
	var nbs: Array[int] = _napalm_neighbor_seats()
	var lost: int = _napalm_set_monster(face)
	if lost > 0:
		if wheel_view and wheel_view.has_method("play_burn"):
			await wheel_view.play_burn(face)
		_vindictive_note(face)
	for j in nbs:
		var n_lost: int = _napalm_set_monster(j)
		if n_lost <= 0:
			continue
		if wheel_view and wheel_view.has_method("play_burn"):
			await wheel_view.play_burn(j)
		_vindictive_note(j)
		if hp <= 0:
			return true
	var drop: int = maxi(0, hp - 1)
	if drop > 0:
		if await _bleed(drop):
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
		"shield_face": str(it.get("shield_face", "")),
	}


func _echo_face(it: Dictionary) -> Dictionary:
	if str(it.get("card_id", "")) != "echo_bell":
		return it
	var copy: Variant = it.get("echo_copy", {})
	if typeof(copy) == TYPE_DICTIONARY and not (copy as Dictionary).is_empty():
		return copy
	if typeof(last_item_copy) == TYPE_DICTIONARY and not last_item_copy.is_empty():
		return last_item_copy
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


func _clicked_item_counts_as_use(it: Dictionary) -> bool:
	# Countdown tokens tick on their own. Only a hotbar click is a use.
	return not _kind_always_unplayable(str(_ops_of(it).get("kind", "")))


func _after_item_resolved(it: Dictionary) -> void:
	if not it.is_empty():
		_beggar_note_use(int(it.get("uid", -1)))
	_beggar_hold = false
	_kick_beggar_fill()
	if it.is_empty():
		return
	if await _flush_vindictive():
		return
	if _clicked_item_counts_as_use(it):
		_remember_item_use(it)
	if not bool(it.get("spent", false)):
		return
	if phase != "fighting":
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	await _run_dead_sweep()
	if phase != "fighting":
		return
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if int(wheel[facing_index].get("hp", 0)) <= 0:
		return
	var hid: String = str(wheel[facing_index].get("card_id", ""))
	if hid == "harpy" and facing_index >= 0 and facing_index < wheel.size() and not _is_silenced(wheel[facing_index]) and _clicked_item_counts_as_use(it):
		await _harpy_poke()
	if hid == "bushido" and _clicked_item_counts_as_use(it):
		await _bushido_dance_swap(facing_index)
	if _pending_item_flee:
		_pending_item_flee = false
		if hp > 0 and phase == "fighting" and facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) > 0:
			_log("on_resolve", "flee")
			await _flee_spin()


func _harpy_poke() -> void:
	if phase != "fighting" or facing_index < 0:
		return
	if not _facing_can_act():
		return
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "harpy" or _is_silenced(m):
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
		if not bool(it.get("petrified", false)):
			continue
		var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("petrify_shatter"):
			await card.petrify_shatter()
		it["petrified"] = false
	_refresh()


func _item_stoned(it: Dictionary) -> bool:
	return bool(it.get("petrified", false)) or int(it.get("petrify_n", 0)) > 0


func _tick_gaze_petrify() -> void:
	for it in hotbar:
		var n: int = int(it.get("petrify_n", 0))
		if n <= 0:
			continue
		var left: int = n - 1
		it["petrify_n"] = left
		var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("petrify_tick"):
			await card.petrify_tick(left)
	_refresh()


func _petrify_fx_host() -> Node2D:
	## Line2D under a Control draws in the wrong space; keep beams on a top-level Node2D.
	var host := get_node_or_null("PetrifyFxHost") as Node2D
	if host != null:
		return host
	host = Node2D.new()
	host.name = "PetrifyFxHost"
	host.top_level = true
	host.z_index = 40
	host.z_as_relative = false
	add_child(host)
	return host


func _petrify_beam_from() -> Vector2:
	# Prefer the facing wheel portrait so beams read across the fight, not the sidebar stage.
	if wheel_view != null and facing_index >= 0 and facing_index < wheel.size():
		return wheel_view.slice_portrait_global(facing_index)
	if combat_stage != null and combat_stage.visible:
		return combat_stage.global_position + combat_stage.size * 0.5
	return Vector2.ZERO


func _petrify_beam(to_card: Vector2, linger: float = 0.22) -> Array:
	## Returns [beam, core] Line2Ds. linger keeps them visible after hit for QA / read.
	var from: Vector2 = _petrify_beam_from()
	if from == Vector2.ZERO:
		from = to_card + Vector2(0, -80)
	var host: Node2D = _petrify_fx_host()
	var beam := Line2D.new()
	beam.name = "PetrifyBeam"
	beam.z_index = 15
	beam.width = 6.0
	beam.default_color = Color("c9b9a8")
	beam.antialiased = false
	beam.add_point(from)
	beam.add_point(from)
	host.add_child(beam, true)
	var core := Line2D.new()
	core.name = "PetrifyBeamCore"
	core.z_index = 16
	core.width = 2.5
	core.default_color = Color.WHITE
	core.add_point(from)
	core.add_point(from)
	host.add_child(core, true)
	set_meta("qa_petrify_beams", _count_petrify_beams())
	var tw := create_tween()
	tw.tween_method(
		func(u: float) -> void:
			var p: Vector2 = from.lerp(to_card, u)
			beam.set_point_position(1, p)
			core.set_point_position(1, p),
		0.0,
		1.0,
		0.16
	)
	await tw.finished
	for i in 3:
		var dust := ColorRect.new()
		dust.color = Color("c9b9a8")
		dust.size = Vector2(4, 4)
		dust.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dust.z_index = 17
		host.add_child(dust)
		dust.global_position = to_card + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		var dt := create_tween()
		dt.tween_property(dust, "modulate:a", 0.0, 0.12)
		dt.finished.connect(dust.queue_free, CONNECT_ONE_SHOT)
	if linger > 0.0:
		await get_tree().create_timer(linger).timeout
	if is_instance_valid(beam):
		beam.queue_free()
	if is_instance_valid(core):
		core.queue_free()
	set_meta("qa_petrify_beams", _count_petrify_beams())
	return []


func _count_petrify_beams() -> int:
	var host := get_node_or_null("PetrifyFxHost")
	if host == null:
		return 0
	var n: int = 0
	# One per beam: skip the white core lines. Siblings get readable names
	# (PetrifyBeam2, PetrifyBeam3...) so every Hydra beam is counted.
	for c in host.get_children():
		var nm: String = str(c.name)
		if nm.begins_with("PetrifyBeam") and not nm.begins_with("PetrifyBeamCore"):
			n += 1
	return n


func _apply_basilisk_gaze() -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "basilisk":
		return false
	if int(m.get("hp", 0)) <= 0:
		return false
	if bool(m.get("gaze_done", false)):
		return false
	m["gaze_done"] = true
	wheel[facing_index] = m
	if _is_silenced(m):
		_log("on_spin", "Basilisk silenced")
		return false
	var cap: int = 0
	var targets: Array = []
	for i in hotbar.size():
		if (i + 1) % 2 == 0:
			hotbar[i]["petrify_n"] = 3
			targets.append(hotbar[i])
			cap += 1
	_log("on_spin", "Petrifying Gaze  %s items" % cap)
	# Sweep left→right across the hotbar. Creep finishes before the slash so pips read.
	for it in targets:
		var dest: Vector2 = _item_card_global(int(it.get("uid", -1)))
		await _petrify_beam(dest, 0.06)
		var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("set_petrified"):
			await card.set_petrified(true, false, 3, true)
	_refresh()
	if sfx:
		sfx.play_event(&"status.petrify")
	if facing_index >= 0 and cap > 0:
		await _announce_slice(facing_index, _item_card_global(int(hotbar[0].get("uid", -1))))
	_log("on_resolve", "Basilisk Flees")
	return await _flee_spin()


func _item_atk_score(it: Dictionary) -> int:
	if _item_stoned(it) or bool(it.get("spent", false)):
		return -1
	if _item_is_chakram(it):
		if bool(_chakram_halves(it).get("atk", false)):
			return _atk_with_head(3)
		return -1
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind == "shield_alt":
		if _shield_face(it) == "atk":
			return _atk_with_head(3)
		return -1
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
	if facing_index < 0 or facing_index >= wheel.size() or str(wheel[facing_index].get("card_id", "")) != "gargoyle" or _is_silenced(wheel[facing_index]):
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
	var dest: Vector2 = _item_card_global(int(pick.get("uid", -1)))
	# Linger so the harness (and the player) can read the beam before creep.
	await _petrify_beam(dest, 0.40)
	var card = _hotbar_card_by_uid(int(pick.get("uid", -1)))
	if card != null and card.has_method("set_petrified"):
		await card.set_petrified(true, false, 0, true)
	if facing_index >= 0 and facing_index < wheel.size():
		await _announce_slice(facing_index, dest)
	if sfx:
		sfx.play_event(&"status.petrify")
	_refresh()


func _hydra_live_n(it: Dictionary) -> int:
	if it.is_empty() or bool(it.get("spent", false)) or _item_stoned(it):
		return -1
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if kind == "egg_hurt":
		return int(ops.get("n", 2)) + _arrow_head_bonus()
	if kind == "marble":
		return -1
	if kind == "chakram":
		var halves: Dictionary = _chakram_halves(it)
		if not bool(halves.get("blk", false)) and not bool(halves.get("atk", false)):
			return -1
		return 3
	if kind == "choose":
		var deals := false
		var opts: Variant = ops.get("options", [])
		if typeof(opts) == TYPE_ARRAY:
			for ov in opts:
				if typeof(ov) != TYPE_DICTIONARY:
					continue
				var o: Dictionary = ov
				if o.has("atk") or o.has("blk"):
					deals = true
					break
		if not deals:
			return -1
		return int(_item_view(it).get("n", 0))
	if kind.begins_with("blk"):
		return int(_item_view(it).get("n", 0))
	if _kind_deals_atk(kind):
		var sc: int = _item_atk_score(it)
		if sc < 0:
			return int(_item_view(it).get("n", -1))
		return sc
	return -1


func _hydra_even_killer() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	if str(wheel[facing_index].get("card_id", "")) != "hydra" or _is_silenced(wheel[facing_index]):
		return
	var hits: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		var n: int = _hydra_live_n(it)
		if n >= 0 and n % 2 == 0:
			hits.append(it)
	if hits.is_empty():
		_log("on_spin", "hydra petrify none")
		return
	# Keep every beam until the volley ends so Hydra's multi-target read is visible.
	var host: Node2D = _petrify_fx_host()
	var kept: Array = []
	var from: Vector2 = _petrify_beam_from()
	for it in hits:
		it["petrified"] = true
		var dest: Vector2 = _item_card_global(int(it.get("uid", -1)))
		if from == Vector2.ZERO:
			from = dest + Vector2(0, -80)
		var beam := Line2D.new()
		beam.name = "PetrifyBeam"
		beam.z_index = 15
		beam.width = 6.0
		beam.default_color = Color("c9b9a8")
		beam.antialiased = false
		beam.add_point(from)
		beam.add_point(from)
		host.add_child(beam, true)
		var core := Line2D.new()
		core.name = "PetrifyBeamCore"
		core.z_index = 16
		core.width = 2.5
		core.default_color = Color.WHITE
		core.add_point(from)
		core.add_point(from)
		host.add_child(core, true)
		kept.append(beam)
		kept.append(core)
		set_meta("qa_petrify_beams", _count_petrify_beams())
		var tw := create_tween()
		tw.tween_method(
			func(u: float) -> void:
				var p: Vector2 = from.lerp(dest, u)
				beam.set_point_position(1, p)
				core.set_point_position(1, p),
			0.0,
			1.0,
			0.16
		)
		await tw.finished
		for di in 3:
			var dust := ColorRect.new()
			dust.color = Color("c9b9a8")
			dust.size = Vector2(4, 4)
			dust.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dust.z_index = 17
			host.add_child(dust)
			dust.global_position = dest + Vector2(randf_range(-8, 8), randf_range(-8, 8))
			var dt := create_tween()
			dt.tween_property(dust, "modulate:a", 0.0, 0.12)
			dt.finished.connect(dust.queue_free, CONNECT_ONE_SHOT)
		var card = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("set_petrified"):
			await card.set_petrified(true, false, 0, true)
		await get_tree().create_timer(0.12).timeout
	set_meta("qa_hydra_beams_ready", true)
	set_meta("qa_petrify_beams", _count_petrify_beams())
	# Hold the full fan so QA / the player can see every beam together.
	await get_tree().create_timer(0.55).timeout
	for n in kept:
		if is_instance_valid(n):
			n.queue_free()
	if has_meta("qa_hydra_beams_ready"):
		remove_meta("qa_hydra_beams_ready")
	set_meta("qa_petrify_beams", 0)
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var gain: int = 2 * hits.size()
	wheel[facing_index]["hydra_bonus"] = int(wheel[facing_index].get("hydra_bonus", 0)) + gain
	wheel[facing_index]["atk"] = _card_base_atk("hydra") + int(wheel[facing_index].get("hydra_bonus", 0))
	if wheel[facing_index].has("atk_innate"):
		wheel[facing_index]["atk_innate"] = int(wheel[facing_index]["atk"])
	_log("on_spin", "hydra petrify %s  +%s ATK  →  %s" % [hits.size(), gain, wheel[facing_index]["atk"]])
	if wheel_view != null and wheel_view.has_method("punch_atk"):
		wheel_view.punch_atk(facing_index)
	var first: Dictionary = hits[0]
	await _announce_slice(facing_index, _item_card_global(int(first.get("uid", -1))))
	if sfx:
		sfx.play_event(&"status.petrify")
	_refresh()


func _cube_ask_feed() -> void:
	if facing_index < 0 or facing_index >= wheel.size() or str(wheel[facing_index].get("card_id", "")) != "gelatinous_cube" or _is_silenced(wheel[facing_index]):
		return
	if hotbar.is_empty():
		_log("on_spin", "cube ate nothing")
		return
	var ids: Array = _hand_all_uids()
	if ids.is_empty():
		_log("on_spin", "cube ate nothing")
		return
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
	if str(pending_feed.get("kind", "")) == "hired_bribe":
		await _pay_hired_hand(uid)
		return
	if str(pending_feed.get("kind", "")) == "worm_hunger":
		await _feed_worm(uid)
		return
	if str(pending_feed.get("kind", "")) == "bell_spawn" or str(pending_feed.get("kind", "")) == "bell_defeat" or str(pending_feed.get("kind", "")) == "rust_spawn" or str(pending_feed.get("kind", "")) == "oligarch_gift" or str(pending_feed.get("kind", "")) == "forced_gain":
		_feed_bell_overlay(uid)
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
	_discard_from_hand(uid)
	_cube_line = ["Mmm. Thank you.", "Gone. Delicious.", "Thanks. I needed that."][rng.randi() % 3]
	_refresh()
	if seat >= 0:
		await _monster_walk_back(seat, "gelatinous_cube", home)
	else:
		_walker_busy = false
	_undo_arm()
	_refresh()


func _count_item_use() -> void:
	if _skip_item_use_count:
		return
	items_used_this_combat += 1
	beads_step = (beads_step % 4) + 1
	_log("var", "items this combat %s" % items_used_this_combat)
	_flip_alt_sais()
	_flip_shield_faces()
	_tick_tolls()
	if _toll_death_armed and not _bell_kill_this_use():
		if await _resolve_toll_death():
			return
	_amalgam_after_use()
	_sync_wheel_stats()
	_sync_intent_plate()


func _deal_atk(n: int) -> bool:
	var at: int = _sling_aim if _sling_aim >= 0 else facing_index
	return await _deal_atk_at(at, n)


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
	return 0


func _hand_pierce() -> bool:
	if _arrow_head_bonus() > 0:
		return true
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "rust":
			continue
		if bool(it.get("spent", false)):
			continue
		if int(it.get("rust_n", 0)) > 0:
			return true
	return false


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
	# Right = counter-clockwise = previous index. Left Bracer is clockwise (+1).
	var j: int = posmod(index - 1, n)
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


## Clockwise neighbor first, then the other side. The same seat is listed once.
func _prism_share_targets(index: int) -> Array:
	var n: int = wheel.size()
	var out: Array = []
	if n < 2 or index < 0 or index >= n:
		return out
	var seen := {}
	for off in [1, -1]:
		var j: int = posmod(index + int(off), n)
		if j == index or seen.has(j):
			continue
		seen[j] = true
		if str(wheel[j].get("kind", "")) != "monster":
			continue
		if int(wheel[j].get("hp", 0)) <= 0:
			continue
		out.append(wheel[j])
	return out


func _index_of_share(tok: int) -> int:
	if tok == 0:
		return -1
	for i in wheel.size():
		if typeof(wheel[i]) != TYPE_DICTIONARY:
			continue
		if int(wheel[i].get("_share_tok", 0)) == tok:
			return i
	return -1


func _tag_share(m: Dictionary) -> int:
	var tok: int = int(m.get("_share_tok", 0))
	if tok != 0:
		return tok
	_share_seq += 1
	m["_share_tok"] = _share_seq
	return _share_seq


func _clear_share_tag(tok: int) -> void:
	var i: int = _index_of_share(tok)
	if i >= 0:
		wheel[i].erase("_share_tok")


## Prism takes 0. Each living neighbor takes that Attack, clockwise first.
func _refract_from_prism(index: int, n: int, shares: Array) -> bool:
	var pname: String = str(wheel[index].get("name", "Prism"))
	last_atk_index = index
	last_atk_line = "0  →  %s HP %s" % [pname, wheel[index].get("hp", 0)]
	_log("atk", last_atk_line)
	if wheel_view:
		wheel_view.hit_feedback(index, 0, 0)
	var tags: Array[int] = []
	for share in shares:
		if typeof(share) != TYPE_DICTIONARY:
			continue
		tags.append(_tag_share(share))
	_begin_simul()
	for tok in tags:
		var j: int = _index_of_share(tok)
		if j < 0:
			continue
		if _living_id(j, "prism"):
			var jname: String = str(wheel[j].get("name", "Prism"))
			last_atk_index = -1
			last_atk_line = "0  →  %s" % jname
			_log("atk", last_atk_line)
			await _announce_slice(index, _slice_hp_pos(j))
			if wheel_view:
				wheel_view.hit_feedback(j, 0, 0)
			if sfx:
				sfx.play("glass", -8.0, 0.85)
			continue
		await _announce_slice(index, _slice_hp_pos(j))
		if await _deal_atk_at(j, n, false, false, true, true):
			_end_simul()
			for done in tags:
				_clear_share_tag(int(done))
			return true
		j = _index_of_share(tok)
		if j < 0:
			continue
		if int(wheel[j].get("hp", 0)) <= 0:
			await _maybe_slay_down(j)
			if phase != "fighting":
				_end_simul()
				for done2 in tags:
					_clear_share_tag(int(done2))
				last_atk_index = -1
				return true
	_end_simul()
	for tok2 in tags:
		_clear_share_tag(int(tok2))
	last_atk_index = -1
	return false


## Each Bodyguard once, to the end of that line.
func _plan_redirect(aim: int, n: int) -> Dictionary:
	if _living_id(aim, "prism") and not _prism_share_targets(aim).is_empty():
		return {"final": aim, "amount": n, "path": [aim], "fizzle": false, "moved": false}
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


func _deal_atk_at(index: int, n: int, skip_twins: bool = false, skip_redirect: bool = false, head_done: bool = false, from_refract: bool = false) -> bool:
	if _hero_swipe_armed:
		_hero_swipe_armed = false
		if wheel_view and wheel_view.has_method("play_hero"):
			wheel_view.play_hero("swipe")
			_player_play("attack")
			if wheel_view.has_method("wait_hero_frame"):
				await wheel_view.wait_hero_frame("swipe", 2)
	if not head_done:
		n = _atk_with_head(n)
		head_done = true
	last_item_atk = n
	if index < 0 or index >= wheel.size():
		return false
	if not from_refract and _living_id(index, "prism"):
		var shares: Array = _prism_share_targets(index)
		if not shares.is_empty():
			return await _refract_from_prism(index, n, shares)
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
	_poison_frog_on_hit(index)
	var hit_n: int = n
	var cut_chip: bool = false
	if str(m.get("card_id", "")) == "anvil" and not _is_silenced(m) and hit_n > 0:
		if hit_n > 1:
			cut_chip = true
		hit_n = 1
	var immune_goblin: bool = str(m.get("card_id", "")) == "goblin" and not _is_silenced(m)
	var immune_lich: bool = _undying(m)
	var immune: bool = immune_goblin or immune_lich
	last_atk_index = index
	if cut_chip:
		await _announce_slice(index, _slice_hp_pos(index))
	if immune or hit_n <= 0:
		if immune:
			_log("var", "no HP loss" if immune_lich else "no ATK dmg")
			await _announce_slice(index, _slice_hp_pos(index))
			if immune_lich:
				last_atk_line = "0  →  %s HP %s" % [m.get("name", "Lich"), m.get("hp", 0)]
			else:
				last_atk_line = "0  →  %s immune" % m.get("name", "Goblin")
		else:
			last_atk_line = "0  →  %s HP %s" % [m.get("name", "?"), m.get("hp", 0)]
			_log("atk", last_atk_line)
		if sfx:
			sfx.play("glass", -8.0, 0.85)
		if wheel_view:
			wheel_view.hit_feedback(index, 0, 0)
		_flash_hit_portrait(index)
		return false
	var before_hp: int = int(m.get("hp", 0))
	var before_atk: int = int(m.get("atk", 0))
	m["hp_pre_hit"] = before_hp
	m["hp"] = maxi(0, before_hp - hit_n)
	if before_hp > 0 and int(m["hp"]) <= 0:
		_note_death(m)
	m["hp_locked"] = true
	if str(m.get("card_id", "")) == "triclops" and int(m["hp"]) <= 0 and before_hp != 3:
		m["triclops_before"] = before_hp
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
	_flash_hit_portrait(index)
	if str(m.get("card_id", "")) == "needleback" and not _is_silenced(m) and before_hp > 0:
		if _watch_skip_thorns:
			pass
		elif _watch_thorns_seat >= 0:
			var thorn_at: int = _watch_thorns_seat
			await _announce_slice(index, _slice_hp_pos(thorn_at))
			_watch_skip_thorns = true
			var poked: bool = await _deal_atk_at(thorn_at, 2, false, false, true)
			_watch_skip_thorns = false
			if poked:
				return true
		else:
			await _announce_slice(index, _hub_hp_pos())
			if await _player_take_atk(2):
				return true
	if before_hp > int(m["hp"]):
		if await _martyr_after_hp_loss(index, before_hp, int(m["hp"])):
			return true
		if await _vindictive_after_hp_loss(index):
			return true
	if await _check_triclops_three(index):
		return true
	return false


func _vindictive_note(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "cowardly_king":
		return
	if _is_silenced(s):
		return
	_vindictive_queue.append(index)


func _vindictive_after_hp_loss(index: int) -> bool:
	_vindictive_note(index)
	if _item_hold or _vindictive_flushing:
		return false
	return await _flush_vindictive()


func _flush_vindictive() -> bool:
	if _vindictive_flushing:
		return false
	_vindictive_flushing = true
	_sync_wheel_stats()
	var died := false
	while not _vindictive_queue.is_empty() and hp > 0:
		var king: int = int(_vindictive_queue.pop_front())
		if king < 0 or king >= wheel.size():
			continue
		if str(wheel[king].get("card_id", "")) != "cowardly_king":
			continue
		if _is_silenced(wheel[king]):
			continue
		await _announce_slice(king)
		var j: int = _right_monster(king)
		if await _commanded_neighbor_attack(j):
			died = true
			break
	if died:
		_vindictive_queue.clear()
	_vindictive_flushing = false
	return died


func _commanded_neighbor_attack(j: int) -> bool:
	if j < 0 or j >= wheel.size():
		return false
	if str(wheel[j].get("kind", "")) != "monster":
		return false
	if int(wheel[j].get("hp", 0)) <= 0:
		return false
	var nm: Dictionary = wheel[j]
	await _announce_slice(j, _hub_hp_pos())
	if combat_stage:
		combat_stage.show_monster(str(nm.get("card_id", "")), int(nm.get("tier", 1)))
	if _blood_threshes(j):
		await _shark_attack_player(j)
		if hp <= 0:
			_player_down()
			return true
		return false
	var hits: int = _hit_count(j)
	for h in range(hits):
		if hp <= 0:
			break
		await _owner_attack(nm, h + 1, hits, j)
		await _after_self_deconstruct(j)
		if j >= 0 and j < wheel.size():
			nm = wheel[j]
		if hp <= 0:
			break
		if j >= 0 and j < wheel.size() and int(wheel[j].get("hp", 0)) <= 0:
			break
		if hits > 1 and h < hits - 1:
			await get_tree().create_timer(0.08).timeout
	if hp <= 0:
		_player_down()
		return true
	return false


func _chain_live() -> Array:
	var out: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != "ball_and_chain":
			continue
		if bool(it.get("spent", false)):
			continue
		if _item_stoned(it):
			continue
		out.append(it)
	return out


func _play_chain_cancel() -> bool:
	var copies: Array = _chain_live()
	if copies.is_empty():
		return false
	var show: Dictionary = copies[0]
	_flash_banner("Can't Flee")
	var tex: Texture2D = null
	if art != null:
		tex = art.item_tex("ball_and_chain")
	if tex == null:
		tex = tex_by_item.get("ball_and_chain", null)
	if ability_slash:
		await ability_slash.play({
			"title": str(show.get("name", "Ball & Chain")),
			"call": "Can't Flee",
			"tex": tex,
			"is_item": true,
			"card_id": "ball_and_chain",
		})
	for it in copies:
		var ops: Dictionary = {}
		var raw: Variant = it.get("ops", {})
		if typeof(raw) == TYPE_DICTIONARY and not (raw as Dictionary).is_empty():
			ops = (raw as Dictionary).duplicate(true)
		else:
			ops = {"kind": "atk", "n": 2}
		ops["kind"] = "atk"
		ops["n"] = int(ops.get("n", 2)) + 2
		it["ops"] = ops
	_log("on_resolve", "Can't Flee")
	if sfx:
		sfx.play("metal_latch", -8.0)
	_hotbar_sig = ""
	_refresh()
	for it in copies:
		var uid: int = int(it.get("uid", -1))
		if hotbar_box:
			for c in hotbar_box.get_children():
				if _control_uid(c) == uid and c.has_method("bounce"):
					c.bounce()
					break
	return true


func _sandbag_would_kill() -> bool:
	if hp <= 0 or phase != "fighting":
		return false
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) != "sandbag":
		return false
	if _is_silenced(m) or int(m.get("hp", 0)) <= 0:
		return false
	# Same number as Take. Block already gained counts. An unspent Double-Buckler does not. Ignores Healing Potion.
	return _incoming_hit() >= hp


func _sandbag_lose_atk() -> void:
	if facing_index < 0 or facing_index >= wheel.size():
		return
	var m: Dictionary = wheel[facing_index]
	m["sandbag_cut"] = int(m.get("sandbag_cut", 0)) + 1
	var shown: int = maxi(0, int(m.get("atk", 0)) - 1)
	m["atk"] = shown
	m["atk_innate"] = shown
	wheel[facing_index] = m
	_sync_wheel_stats()
	_log("on_spin", "Sandbag loses 1 Attack  →  %s" % int(wheel[facing_index].get("atk", 0)))
	if wheel_view:
		wheel_view.punch_atk(facing_index)


func _sandbag_after_spin() -> bool:
	if not _sandbag_would_kill():
		return false
	_sandbag_lose_atk()
	_refresh()
	if await _flee_spin():
		_undo_arm()
		return true
	# Ball and Chain stopped the Flee. The Attack loss stays. The fight stays open.
	_refresh()
	return false


func _flee_spin(_shuffle: bool = false) -> bool:
	if await _play_chain_cancel():
		_pending_item_flee = false
		return false
	phase = "slaying"
	pending_choice.clear()
	pending_mark.clear()
	pending_chaos.clear()
	pending_feed = {}
	_pending_item_flee = false
	_drink_hp_due = false
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
	await _run_dead_sweep()
	var hole_from: int = facing_index if facing_index >= 0 else 0
	if adventure:
		await _challenge_resolve_holes(hole_from)
	else:
		await _remove_crossbowed()
		await _slay_pending_ogres()
	_discard_spent_items()
	_bank_stone_wall()
	blk = 0
	_log("var", "BLK 0")
	facing_index = -1
	_sync_wheel_stats()
	phase = "ready"
	_walker_busy = false
	if _monsters_left() == 0:
		if await _try_release_bag():
			_refresh()
		else:
			_enter_dungeon_clear()
	elif sfx:
		sfx.set_combat_music(false)
	_refresh()
	if in_tutorial:
		call_deferred("_tutorial_after_fight")
		return true
	_flee_random_spin = true
	_challenge_force_spin = true
	call_deferred("_maybe_auto_spin")
	return true


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
		_note_hp_lost(incoming)
	if incoming == 0:
		_log("hp", "poke 0")
		_refresh_blk(false)
		if sfx:
			sfx.play("glass", -10.0)
	else:
		_log("hp", "poke -%s  now %s" % [incoming, hp])
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


func _living_monster_indices() -> Array[int]:
	var out: Array[int] = []
	for i in wheel.size():
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		out.append(i)
	return out


## Halfway around the living monsters. Empty corridors are not seats in this count.
## An odd living count has no opposite, so Pocket Watch cannot be used.
func _across_index(from: int) -> int:
	var living: Array[int] = _living_monster_indices()
	var n: int = living.size()
	if n < 2 or n % 2 != 0:
		return -1
	var pos: int = living.find(from)
	if pos < 0:
		return -1
	return int(living[(pos + (n >> 1)) % n])


func _fight_portrait_index() -> int:
	if _watch_portrait >= 0 and _watch_portrait < wheel.size():
		if str(wheel[_watch_portrait].get("kind", "")) == "monster":
			return _watch_portrait
	return facing_index


func _show_fight_portrait() -> void:
	if combat_stage == null:
		return
	var index: int = _fight_portrait_index()
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return
	if combat_stage.card_id == str(m.get("card_id", "")) and combat_stage.visible and index == facing_index and _watch_portrait < 0:
		_tune_combat_stage()
		return
	combat_stage.show_monster(str(m.get("card_id", "")), int(m.get("tier", 1)))
	_tune_combat_stage()


func _flash_hit_portrait(index: int) -> void:
	if combat_stage and combat_stage.visible and index == _fight_portrait_index():
		combat_stage.take_hit()
	if hypno_stage and hypno_stage.visible and index == _hypno_src and index != _fight_portrait_index():
		hypno_stage.take_hit()


func _neighbors_of(index: int) -> Array[int]:
	var out: Array[int] = []
	if index < 0:
		return out
	var n: int = wheel.size()
	if n < 2:
		return out
	var seen := {}
	for off in [n - 1, 1]:
		var j: int = (index + off) % n
		if seen.has(j) or j == index:
			continue
		seen[j] = true
		if str(wheel[j].get("kind", "")) == "monster":
			out.append(j)
	return out


func _cleave_targets() -> Array[int]:
	var pivot: int = _sling_aim if _sling_aim >= 0 else facing_index
	return _cleave_targets_from(pivot)


func _cleave_targets_from(pivot: int) -> Array[int]:
	var seen := {}
	var out: Array[int] = []
	if pivot >= 0:
		seen[pivot] = true
		out.append(pivot)
	for j in _neighbors_of(pivot):
		if seen.has(j):
			continue
		seen[j] = true
		out.append(j)
	return out


func _apply_cleave(n: int) -> bool:
	n = _atk_with_head(n)
	var targets: Array[int] = _cleave_targets()
	_begin_simul()
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
			_end_simul()
			return true
		_log("atk", last_atk_line)
		if landed >= 0:
			touched.append(landed)
	_end_simul()
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
	if kind == "hypnotize" or kind == "defeat_double_hp" or kind == "polymorph" or kind == "sling_any" or kind == "hook_swap":
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
		if int(wheel[index].get("hp", 0)) <= 0:
			return false
		return _across_index(index) >= 0
	if kind == "sling_any" or kind == "hook_swap":
		return int(wheel[index].get("hp", 0)) > 0
	if kind == "signpost":
		if index == facing_index:
			return false
		if not _neighbor_indices().has(index):
			return false
		return int(wheel[index].get("hp", 0)) > 0
	if kind == "polymorph":
		if index == facing_index:
			return false
		if not _neighbor_indices().has(index):
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
	return false


func _seat_uid_at(index: int) -> int:
	if index < 0 or index >= wheel.size():
		return -1
	return int(wheel[index].get("seat_uid", -1))


func _hook_seats_held(face_i: int, targ_i: int, face_uid: int, targ_uid: int) -> bool:
	## Both seats must still be the monsters the throw aimed at.
	## Index 5 is the left neighbour on a 6-seat wheel and is out of range on a 4-seat wheel.
	if face_uid < 0 or targ_uid < 0 or face_i < 0 or targ_i < 0 or face_i == targ_i:
		return false
	if face_i >= wheel.size() or targ_i >= wheel.size():
		return false
	if _seat_uid_at(face_i) != face_uid or _seat_uid_at(targ_i) != targ_uid:
		return false
	return str(wheel[face_i].get("kind", "")) == "monster" and str(wheel[targ_i].get("kind", "")) == "monster"


func _hook_fx_abort() -> void:
	if wheel_view != null:
		wheel_view.hide_portraits = []
	if hook_fx != null and hook_fx.has_method("retract"):
		await hook_fx.retract()


func _apply_mark(index: int) -> void:
	_walker_busy = true
	_sync_buttons()
	_arm_item_hold()
	await _apply_mark_inner(index)
	await _unlock_if_fighting()


func _apply_mark_inner(index: int) -> void:
	var kind: String = str(pending_mark.get("kind", ""))
	var atk_uid: int = int(pending_mark.get("atk_uid", -1))
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
	# Hook FX must play before the item banner — otherwise the rope is buried under the slash.
	var defer_announce: bool = kind == "hook_swap"
	if not defer_announce:
		## Signpost / Hypnotize then make a monster lunge. Finish the banner first.
		var overlap_ok: bool = kind != "signpost" and kind != "hypnotize"
		await _announce_item_use(it, _slice_from(index) if index >= 0 else _hub_hp_pos(), overlap_ok)
	var token: int = _undo_gen
	if kind == "defeat_double_hp":
		await _apply_scythe(index, it, token)
		return
	if kind == "hypnotize":
		await _apply_hypnotize(index, it)
		return
	if kind == "signpost":
		await _apply_signpost(index, it)
		return
	if kind == "sling_any":
		await _apply_sling(index, it, atk_uid)
		return
	if kind == "polymorph":
		await _apply_polymorph(index, it)
		return
	_bleed_begin()
	if kind == "hook_swap":
		var targ_i: int = index
		var targ_uid: int = _seat_uid_at(targ_i)
		var moves_snap: int = moves_left
		var dir: int = _hook_walk_dir(targ_i)
		if dir != 0:
			var guard: int = 0
			while facing_index != targ_i and guard < wheel.size():
				guard += 1
				if _undo_stale(token):
					moves_left = moves_snap
					await _bleed_end()
					return
				if _seat_uid_at(targ_i) != targ_uid:
					break
				if not await _shift_facing(dir, false):
					break
			moves_left = moves_snap
		if _undo_stale(token):
			moves_left = moves_snap
			await _bleed_end()
			return
		if facing_index != targ_i or _seat_uid_at(targ_i) != targ_uid:
			moves_left = moves_snap
			await _bleed_end()
			call_deferred("_refresh")
			return
		it["spent"] = true
		await _count_item_use()
		_toss_item(int(it["uid"]), false)
		_log("on_item_use", "hook %s" % str(wheel[facing_index].get("name", "?")))
		_sync_wheel_stats()
		if combat_stage and facing_index >= 0 and facing_index < wheel.size():
			combat_stage.show_monster(str(wheel[facing_index].get("card_id", "")), int(wheel[facing_index].get("tier", 1)))
			_tune_combat_stage()
		_draw_unseen_item()
		_refresh()
		if not hotbar.is_empty():
			var gained = hotbar[hotbar.size() - 1]
			var gained_card = _hotbar_card_by_uid(int(gained.get("uid", -1)))
			if gained_card != null and gained_card.has_method("play_transform"):
				gained_card.play_transform()
		await _announce_item_use(it, _slice_from(facing_index) if facing_index >= 0 else _hub_hp_pos())
		await _after_item_resolved(it)
		await _bleed_end()
		if _undo_stale(token):
			return
		_undo_wall()
		call_deferred("_refresh")
		return
	if kind == "mark_poison":
		var dose: int = _poison_dose(it)
		_add_monster_poison(index, dose)
		_log("on_item_use", "poisoned %s (+%s → %s)" % [wheel[index].get("name", "?"), dose, _poison_of(wheel[index])])
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
	_watch_portrait = -1
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
	_place_fight_art(true)


func _heal_monster(index: int, n: int) -> void:
	if index < 0 or index >= wheel.size() or n <= 0:
		return
	var m: Dictionary = wheel[index]
	if str(m.get("kind", "")) != "monster":
		return
	var cap: int = int(m.get("hp_max", m.get("hp", 0)))
	var before: int = int(m.get("hp", 0))
	m["hp"] = mini(cap, before + n)
	if int(m["hp"]) != before:
		m["hp_locked"] = true
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
	if _undying(m):
		_log("on_item_use", str(it["name"]))
		_log("on_resolve", "undying")
		if sfx:
			sfx.play("draw", -8.0)
		await _lich_keep_defeat_item(it)
		var lich_down: bool = await _lich_chip_defeat(index)
		if lich_down:
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
	var dest: int = _across_index(src)
	if dest < 0:
		_undo_abort()
		call_deferred("_refresh")
		return
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
	_watch_portrait = dest
	_show_hypno(src)
	_show_fight_portrait()
	_refresh_face()
	var watch: Texture2D = tex_by_item.get("pocketwatch", null)
	if art != null:
		var pix: Texture2D = art.item_tex("pocketwatch")
		if pix != null:
			watch = pix
	if hypno_stage:
		await hypno_stage.play_hypnotize(watch)
	await _watch_attack(src, dest, snap, hits, {})
	_watch_thorns_seat = -1
	_watch_portrait = -1
	_hide_hypno()
	if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) > 0:
		_show_faced_monster()
	_sync_wheel_stats()
	await _after_item_resolved(it)
	await _bleed_end()
	if hp <= 0:
		_undo_finish_item()
		return
	await _slay_dead_after_watch()
	_undo_finish_item()
	call_deferred("_refresh")


func _sling_is_loaded(it: Dictionary) -> bool:
	if pending_mark.is_empty():
		return false
	if str(pending_mark.get("kind", "")) != "sling_any":
		return false
	return int(pending_mark.get("uid", -1)) == int(it.get("uid", -1))


func _sling_attack_options(skip_uid: int) -> Array:
	var out: Array = []
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if int(it.get("uid", -1)) == skip_uid:
			continue
		if bool(it.get("spent", false)):
			continue
		if _item_stoned(it):
			continue
		if not _item_deals_attack(it):
			continue
		out.append({
			"id": "atk_%s" % int(it.get("uid", -1)),
			"label": _title_case(str(it.get("name", "?"))),
			"atk_uid": int(it.get("uid", -1)),
		})
	return out


func _apply_signpost(index: int, it: Dictionary) -> void:
	if index < 0 or index >= wheel.size():
		_undo_abort()
		call_deferred("_refresh")
		return
	_log("on_item_use", "signpost %s" % wheel[index].get("name", "?"))
	it["spent"] = true
	await _count_item_use()
	_toss_item(int(it.get("uid", -1)), false)
	_bleed_begin()
	await _neighbor_full_attack(index)
	_sync_wheel_stats()
	await _after_item_resolved(it)
	await _bleed_end()
	if hp <= 0:
		_player_down()
		return
	_undo_finish_item()
	call_deferred("_refresh")


func _await_slash_idle() -> void:
	if ability_slash == null or not ability_slash.is_busy():
		return
	while ability_slash != null and ability_slash.is_busy():
		await get_tree().process_frame


func _neighbor_full_attack(src: int) -> int:
	if src < 0 or src >= wheel.size():
		return 0
	await _await_slash_idle()
	var m: Dictionary = wheel[src]
	var pin_id: String = str(wheel[facing_index].get("card_id", "")) if facing_index >= 0 and facing_index < wheel.size() else ""
	var pin_tier: int = int(wheel[facing_index].get("tier", 1)) if facing_index >= 0 and facing_index < wheel.size() else 1
	if combat_stage:
		combat_stage.show_monster(str(m.get("card_id", "")), int(m.get("tier", 1)))
		_tune_combat_stage()
	var total: int = 0
	if str(m.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(m):
		for j in _damsel_neighbors(src):
			var nm: Dictionary = wheel[j]
			if combat_stage:
				combat_stage.show_monster(str(nm.get("card_id", "")), int(nm.get("tier", 1)))
			if _blood_threshes(j):
				total += await _shark_attack_player(j)
				if hp <= 0:
					break
				continue
			var hits: int = _hit_count(j)
			for h in range(hits):
				if hp <= 0:
					break
				if h > 0:
					await _announce_slice(j, _hub_hp_pos())
				total += await _owner_attack(nm, h + 1, hits, j)
				await _after_self_deconstruct(j)
				if j >= 0 and j < wheel.size():
					nm = wheel[j]
				if hp <= 0:
					break
				if j >= 0 and j < wheel.size() and int(wheel[j].get("hp", 0)) <= 0:
					break
				if hits > 1 and h < hits - 1:
					if sfx:
						sfx.play_event(&"mon.hornet_buzz")
					await get_tree().create_timer(0.08).timeout
			if hp <= 0:
				break
		if hp > 0:
			await _heal(3)
		await _slay_dead_after_watch()
	elif _blood_threshes(src):
		total = await _shark_attack_player(src)
	else:
		var hits2: int = _hit_count(src)
		for h2 in range(hits2):
			if hp <= 0:
				break
			if h2 > 0:
				await _announce_slice(src, _hub_hp_pos())
			if src < 0 or src >= wheel.size():
				break
			m = wheel[src]
			total += await _owner_attack(m, h2 + 1, hits2, src)
			await _after_self_deconstruct(src)
			if src >= 0 and src < wheel.size():
				m = wheel[src]
			if hp <= 0:
				break
			if src >= 0 and src < wheel.size() and int(wheel[src].get("hp", 0)) <= 0:
				break
			if hits2 > 1 and h2 < hits2 - 1:
				if sfx:
					sfx.play_event(&"mon.hornet_buzz")
				await get_tree().create_timer(0.08).timeout
	if src >= 0 and src < wheel.size() and int(wheel[src].get("hp", 0)) <= 0 and src != facing_index:
		await _maybe_slay_down(src)
	if combat_stage and facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) > 0:
		combat_stage.show_monster(pin_id if pin_id != "" else str(wheel[facing_index].get("card_id", "")), pin_tier)
		_tune_combat_stage()
	return total


func _apply_sling(aim: int, sling: Dictionary, atk_uid: int) -> void:
	var payload: Dictionary = _find_item(atk_uid)
	if payload.is_empty() or bool(payload.get("spent", false)) or not _item_deals_attack(payload):
		_log("on_item_use", "cannot")
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		call_deferred("_refresh")
		return
	_sling_aim = aim
	_log("on_item_use", "sling %s → %s" % [payload.get("name", "?"), wheel[aim].get("name", "?") if aim >= 0 and aim < wheel.size() else "?"])
	sling["spent"] = true
	await _count_item_use()
	_toss_item(int(sling.get("uid", -1)), false)
	_skip_item_use_count = true
	_bleed_begin()
	await _fire_sling_payload(payload)
	_skip_item_use_count = false
	_sling_aim = -1
	_sync_wheel_stats()
	var before_uids: Dictionary = {}
	for held in hotbar:
		if typeof(held) == TYPE_DICTIONARY:
			before_uids[int(held.get("uid", -1))] = true
	_draw_unseen_item()
	_refresh()
	for held in hotbar:
		if typeof(held) != TYPE_DICTIONARY:
			continue
		var drawn_uid: int = int(held.get("uid", -1))
		if before_uids.has(drawn_uid):
			continue
		var drawn_card = _hotbar_card_by_uid(drawn_uid)
		if drawn_card != null and drawn_card.has_method("play_transform"):
			drawn_card.play_transform()
		break
	await _after_item_resolved(sling)
	await _bleed_end()
	if hp <= 0:
		_player_down()
		return
	_undo_finish_item()
	call_deferred("_refresh")


func _fire_sling_payload(it: Dictionary) -> void:
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	_hero_swipe_armed = true
	if _item_is_chakram(it):
		var hit: int = _atk_with_head(3)
		last_item_atk = hit
		_log("on_item_use", str(it.get("name", "Chakram")))
		if await _deal_atk(hit):
			it["spent"] = true
			_toss_item(int(it.get("uid", -1)), false)
			return
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [hit, _sling_hp_now()])
		it["spent"] = true
		_toss_item(int(it.get("uid", -1)), false)
		_sync_wheel_stats()
		await _sling_slay_if_dead()
		return
	if kind == "marble":
		var n_m: int = int(it.get("marble_n", 0))
		var hit_m: int = _atk_with_head(n_m)
		last_item_atk = hit_m
		_log("on_item_use", str(it.get("name", "Marble")))
		if await _deal_atk(n_m):
			it["spent"] = true
			_toss_item(int(it.get("uid", -1)), false)
			return
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [hit_m, _sling_hp_now()])
		it["spent"] = true
		_toss_item(int(it.get("uid", -1)), false)
		_sync_wheel_stats()
		await _sling_slay_if_dead()
		return
	if kind == "choose":
		var n_k: int = 3
		var keep_k := false
		var copts: Variant = ops.get("options", [])
		if typeof(copts) == TYPE_ARRAY:
			for ov in copts:
				if typeof(ov) != TYPE_DICTIONARY:
					continue
				var o: Dictionary = ov
				if o.has("atk"):
					n_k = int(o.get("atk", 3))
					keep_k = bool(o.get("keep", false))
					if not keep_k:
						break
		last_item_atk = n_k
		_log("on_item_use", str(it.get("name", "?")))
		if await _deal_atk(n_k):
			it["spent"] = true
			it["keep_after"] = keep_k
			_toss_item(int(it.get("uid", -1)), keep_k)
			return
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n_k, _sling_hp_now()])
		it["spent"] = true
		it["keep_after"] = keep_k
		_toss_item(int(it.get("uid", -1)), keep_k)
		_sync_wheel_stats()
		await _sling_slay_if_dead()
		return
	if kind == "atk_neighbor" or kind == "mark_crossbow":
		var n_c: int = int(ops.get("n", 4))
		last_item_atk = n_c
		_log("on_item_use", str(it.get("name", "?")))
		if await _deal_atk(n_c):
			it["spent"] = true
			_toss_item(int(it.get("uid", -1)), false)
			return
		_log("atk", last_atk_line if last_atk_line != "" else "%s  →  enemy HP %s" % [n_c, _sling_hp_now()])
		it["spent"] = true
		_toss_item(int(it.get("uid", -1)), false)
		_sync_wheel_stats()
		await _sling_slay_if_dead()
		return
	await _apply_ops(it, ops, {})


func _sling_hp_now() -> int:
	var at: int = _sling_aim if _sling_aim >= 0 else facing_index
	if at < 0 or at >= wheel.size():
		return 0
	return int(wheel[at].get("hp", 0))


func _sling_slay_if_dead() -> void:
	var at: int = last_atk_index if last_atk_index >= 0 else (_sling_aim if _sling_aim >= 0 else facing_index)
	if at < 0 or at >= wheel.size():
		return
	if int(wheel[at].get("hp", 0)) > 0:
		return
	if _wick_waiting(at):
		return
	await _maybe_slay_down(at)


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
	if _blood_threshes(src):
		while dest >= 0 and dest < wheel.size() and int(wheel[dest].get("hp", 0)) > 0 and hp > 0:
			var before: int = int(wheel[dest].get("hp", 0))
			if hypno_stage:
				await hypno_stage.lunge()
			if await _deal_atk_at(dest, atk, false, false, true):
				await _after_self_deconstruct(src)
				return
			await _after_self_deconstruct(src)
			if dest >= 0 and dest < wheel.size() and int(wheel[dest].get("hp", 0)) < before:
				return
			return
		return
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
			await _after_self_deconstruct(src)
			return
		await _after_self_deconstruct(src)
		if src >= 0 and src < wheel.size() and int(wheel[src].get("hp", 0)) <= 0:
			return
		if hits > 1 and h < hits - 1 and get_tree():
			await get_tree().create_timer(0.08).timeout


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
	if _beggar_intro_running:
		return true
	if challenge_draft_ui != null and challenge_draft_ui.visible:
		return true
	return _walker_busy or (wheel_view != null and wheel_view.busy) or _hypno_src >= 0


func _kill_neighbor(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	if index == facing_index:
		return
	await _on_owner_defeated(index)
	if hp <= 0:
		return
	var pin: int = facing_index
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) == "death_bell":
		await _maybe_bell_defeat_tax(index)
	await _wick_on_defeated(index)
	if str(m.get("card_id", "")) == "mimic" and not adventure:
		await _grant_mimic_gift()
	_flash_screen(Color("e8c36a"), 0.32)
	if sfx:
		var nctx := {"tier": _tier_of(m), "monster_id": str(m.get("card_id", ""))}
		sfx.play_event(sfx.resolve(&"death", nctx), nctx)
	if wheel_view:
		await wheel_view.play_slay(index, true)
	if adventure:
		_challenge_vacate(index)
		_refresh()
		if not (phase == "fighting" and _hold_holes > 0):
			await _challenge_resolve_holes(index)
			if phase == "fighting":
				await _ensure_face_at_six()
		if not _flushing_poison_sides and facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
			if not _wick_waiting(facing_index):
				await _maybe_slay_down(facing_index)
		return
	if wheel_view:
		await wheel_view.collapse_slice(index, pin)
	if _install_laid_egg(index):
		mobs_defeated += 1
		_sync_wheel_stats()
		if wheel_view:
			_stamp_atk_variants()
			wheel_view.set_slices(wheel, facing_index, "none")
			await wheel_view.recenter_on(facing_index)
		_refresh()
		if facing_index >= 0 and facing_index < wheel.size() and int(wheel[facing_index].get("hp", 0)) <= 0:
			if not _wick_waiting(facing_index):
				await _maybe_slay_down(facing_index)
		return
	_log("on_remove_slice", str(m.get("name", "?")))
	wheel.remove_at(index)
	mobs_defeated += 1
	if index < pin:
		facing_index -= 1
	_reseat_slots()
	_sync_wheel_stats()
	if wheel_view:
		_stamp_atk_variants()
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
			await _on_owner_defeated(i)
			if hp <= 0:
				return
			if str(wheel[i].get("card_id", "")) == "death_bell":
				await _maybe_bell_defeat_tax(i)
			await _wick_on_defeated(i)
			if _install_laid_egg(i):
				mobs_defeated += 1
			else:
				_log("on_remove_slice", str(wheel[i]["name"]))
				wheel.remove_at(i)
				mobs_defeated += 1
				if i < facing_index:
					facing_index -= 1
		i -= 1
	_reseat_slots()


func _draw_unseen_item(force_over: bool = false) -> void:
	if adventure and item_pool.is_empty():
		_challenge_reshuffle_items()
	if item_pool.is_empty():
		return
	var id: String = ""
	if _latest_rig:
		id = _take_latest_queued(_latest_item_q, item_pool, "", false)
	if id == "":
		id = _take_card(item_pool, items_by_id, "", 0)
	if id == "" and adventure:
		_challenge_reshuffle_items()
		id = _take_card(item_pool, items_by_id, "", 0)
	if id == "":
		return
	var it: Dictionary = _make_item(id)
	if not force_over and adventure and _hand_full():
		_start_full_hand_replace(it)
		return
	hotbar.append(it)
	_sort_hotbar()
	_log("on_draft", "gain %s" % it.get("name", id))
	if sfx:
		sfx.play("open", -10.0)


func _grant_mimic_gift() -> void:
	## Louder tell: banner + coins + card pop so the Mimic payout reads clearly.
	var before_uids: Dictionary = {}
	for held in hotbar:
		if typeof(held) == TYPE_DICTIONARY:
			before_uids[int(held.get("uid", -1))] = true
	await _draw_unseen_item(true)
	_log("on_remove_slice", "Mimic gift")
	var gained: Dictionary = {}
	for held in hotbar:
		if typeof(held) != TYPE_DICTIONARY:
			continue
		if not before_uids.has(int(held.get("uid", -1))):
			gained = held
			break
	if gained.is_empty():
		return
	_flash_screen(Color("e8c36a"), 0.42)
	if sfx:
		sfx.play_event(&"hand.gain", {"card_id": str(gained.get("card_id", ""))})
		sfx.play_event(&"loot.coins")
		sfx.play("open", -6.0)
		sfx.play("bong", -10.0, 1.15)
	_refresh()
	var gained_card = _hotbar_card_by_uid(int(gained.get("uid", -1)))
	if gained_card != null:
		if gained_card.has_method("play_transform"):
			gained_card.play_transform()
		elif gained_card.has_method("bounce"):
			gained_card.bounce()
	if get_tree():
		await get_tree().create_timer(0.42).timeout
	if hotbar.size() > _forced_hand_cap():
		await _enforce_hand_cap()


func _try_potion() -> bool:
	for it in hotbar:
		if str(it.get("card_id", "")) != "healing_potion":
			continue
		if bool(it.get("spent", false)):
			continue
		it["spent"] = true
		it["keep_after"] = false
		_log_begin_item(it)
		_heal(3)
		_toss_item(int(it["uid"]), false)
		return true
	return false


func _buckler_half(m: Dictionary, fighting: bool) -> Dictionary:
	if not fighting:
		return {"n": 0, "even": false}
	var atk_n: int = int(m.get("atk", 0))
	if atk_n < 0 or atk_n % 2 != 0:
		return {"n": 0, "even": false}
	return {"n": int(atk_n / 2), "even": true}


func _preview_swing(m: Dictionary, left_blk: int, _allow_buckler: bool) -> Dictionary:
	var swing: Dictionary = _swing(m, left_blk)
	swing["used_buckler"] = false
	return swing


func _swing(m: Dictionary, block_left: int) -> Dictionary:
	var atk_n: int = int(m.get("atk", 0))
	var cid: String = str(m.get("card_id", ""))
	var pierce: bool = false
	if cid == "dragon" and not _is_silenced(m):
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
	if _blood_threshes(facing_index):
		return _shark_incoming()
	var left: int = blk
	var total: int = 0
	var buckler_ok: bool = true
	for _h in range(_hit_count(facing_index)):
		var swing: Dictionary = _preview_swing(m, left, buckler_ok)
		total += int(swing["dmg"])
		left = int(swing["blk"])
		if bool(swing.get("used_buckler", false)):
			buckler_ok = false
	return total


func _shark_incoming() -> int:
	if facing_index < 0 or facing_index >= wheel.size():
		return 0
	var m: Dictionary = wheel[facing_index]
	var left: int = blk
	var buckler_ok: bool = true
	var zeros: int = 0
	while zeros < 5:
		var swing: Dictionary = _preview_swing(m, left, buckler_ok)
		var dmg: int = int(swing["dmg"])
		left = int(swing["blk"])
		if bool(swing.get("used_buckler", false)):
			buckler_ok = false
		if dmg > 0:
			return dmg
		zeros += 1
	return 0


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
	if id == "shambling_mound":
		return maxi(0, int(wheel[index].get("hp", 0)))
	return 1


func _self_deconstructs(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "shambling_mound":
		return false
	if _is_silenced(s):
		return false
	if bool(s.get("swing_muted", false)):
		return false
	return int(s.get("hp", 0)) > 0


func _after_self_deconstruct(index: int) -> void:
	if not _self_deconstructs(index):
		await _martyr_noble_death(index)
		return
	await _chip_hp(index, 1)


## SP-24 Martyr (Noble Death): gift remaining HP to living neighbors (max grows).
func _martyr_gift_neighbors(index: int) -> int:
	if index < 0 or index >= wheel.size():
		return 0
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "martyr":
		return 0
	if _is_silenced(s) or bool(s.get("swing_muted", false)):
		return 0
	if bool(s.get("noble_death_done", false)):
		return 0
	var gift: int = SP_DALLAS.martyr_gift_after_loss(int(s.get("hp", 0)))
	s["noble_death_done"] = true
	wheel[index] = s
	if gift <= 0:
		return 0
	await _announce_slice(index, _hub_hp_pos())
	for j in _neighbors_of(index):
		if j < 0 or j >= wheel.size():
			continue
		var n: Dictionary = wheel[j]
		if int(n.get("hp", 0)) <= 0:
			continue
		n["hp"] = int(n.get("hp", 0)) + gift
		n["hp_max"] = maxi(int(n.get("hp_max", 0)), int(n["hp"]))
		n["hp_locked"] = true
		wheel[j] = n
	_log("on_resolve", "Martyr gives %s HP to its neighbors" % gift)
	_refresh()
	return gift


## Attack half: after Martyr Attacks, gift remaining HP and die.
func _martyr_noble_death(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "martyr":
		return
	if _is_silenced(s) or bool(s.get("swing_muted", false)):
		return
	if not bool(s.get("has_attacked", false)):
		return
	if bool(s.get("noble_death_done", false)):
		return
	var gift: int = await _martyr_gift_neighbors(index)
	var left: int = int(wheel[index].get("hp", 0)) if index < wheel.size() else 0
	if left > 0:
		## Skip re-entry into martyr HP-loss while we finish the self-kill.
		wheel[index]["noble_death_done"] = true
		await _chip_hp(index, left)
	elif gift <= 0 and left <= 0:
		pass


## SP-24: any HP loss kills Martyr; neighbors gain HP after that loss.
func _martyr_after_hp_loss(index: int, before: int, after: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	var s: Dictionary = wheel[index]
	if str(s.get("card_id", "")) != "martyr":
		return false
	if not SP_DALLAS.martyr_dies_on_hp_loss(
		before, after, _is_silenced(s) or bool(s.get("swing_muted", false)), bool(s.get("noble_death_done", false))
	):
		return false
	if after <= 0:
		## Lethal chip already dropped him; remaining HP is 0 so gift is 0.
		s["noble_death_done"] = true
		wheel[index] = s
		return false
	await _martyr_gift_neighbors(index)
	var left: int = int(wheel[index].get("hp", 0)) if index < wheel.size() else 0
	if left > 0:
		wheel[index]["noble_death_done"] = true
		## Direct zero so _chip_hp does not re-enter martyr death.
		var m: Dictionary = wheel[index]
		m["hp_pre_hit"] = left
		m["hp"] = 0
		_note_death(m)
		m["hp_locked"] = true
		wheel[index] = m
		if wheel_view:
			wheel_view.punch_hp(index)
	return true


func _blood_threshes(index: int) -> bool:
	if index < 0 or index >= wheel.size():
		return false
	if str(wheel[index].get("card_id", "")) != "shark":
		return false
	if _is_silenced(wheel[index]):
		return false
	if bool(wheel[index].get("swing_muted", false)):
		return false
	return true


func _shark_attack_player(index: int) -> int:
	var total: int = 0
	var zeros: int = 0
	while hp > 0 and index >= 0 and index < wheel.size() and int(wheel[index].get("hp", 0)) > 0:
		var m: Dictionary = wheel[index]
		if zeros > 0:
			await _announce_slice(index, _hub_hp_pos(), true)
		var incoming: int = await _owner_attack(m, zeros + 1, 0, index)
		total += incoming
		if incoming > 0:
			return total
		zeros += 1
		if zeros >= 5:
			await _shark_net_death(index)
			return total
		if sfx:
			sfx.play_event(&"mon.hornet_buzz")
		if get_tree():
			await get_tree().create_timer(0.04).timeout
	return total


func _shark_net_death(index: int) -> void:
	_cube_line = "Oh, so it's gonna be like that, huh? Wow. What a way to die."
	_refresh()
	if get_tree():
		await get_tree().create_timer(1.35).timeout
	if index >= 0 and index < wheel.size():
		wheel[index]["hp"] = 0
	_cube_line = ""


## SP-20 Stance Swap: after a counted item use while facing Bushido, slash then swap HP/Attack if he still lives.
func _bushido_dance_swap(index: int) -> void:
	if index < 0 or index >= wheel.size():
		return
	var m: Dictionary = wheel[index]
	if str(m.get("card_id", "")) != "bushido":
		return
	var hp_now: int = int(m.get("hp", 0))
	if not SP_DALLAS.bushido_should_swap(true, _is_silenced(m), hp_now):
		return
	_walker_busy = true
	_sync_buttons()
	await _announce_slice(index)
	if index < 0 or index >= wheel.size() or str(wheel[index].get("card_id", "")) != "bushido":
		_walker_busy = false
		_sync_buttons()
		return
	m = wheel[index]
	hp_now = int(m.get("hp", 0))
	if not SP_DALLAS.bushido_should_swap(true, _is_silenced(m), hp_now):
		_walker_busy = false
		_sync_buttons()
		return
	var pair: Dictionary = SP_DALLAS.bushido_swap_pair(hp_now, int(m.get("atk", 0)))
	m["hp"] = int(pair["hp"])
	m["atk"] = int(pair["atk"])
	m["hp_max"] = maxi(int(m.get("hp_max", 0)), int(m["hp"]))
	m["hp_locked"] = true
	m["atk_locked"] = true
	m["atk_innate"] = int(m["atk"])
	wheel[index] = m
	_log("on_resolve", "Bushido Stance Swap  →  HP %s  ATK %s" % [m["hp"], m["atk"]])
	if sfx:
		sfx.play("whoosh", -12.0, 1.1)
	if wheel_view:
		wheel_view.hit_feedback(index, 0, 0)
	_refresh()
	_walker_busy = false
	_sync_buttons()


func _apply_marble_stamp(card, it: Dictionary) -> void:
	if card == null or not card.has_method("set_bag_stamp"):
		return
	var mid: String = str(it.get("marble_monster", ""))
	if mid == "":
		card.set_bag_stamp(null)
		return
	var stamp: Texture2D = null
	if art != null and art.has_method("monster_still"):
		stamp = art.monster_still(mid)
	if stamp == null:
		stamp = tex_by_monster.get(mid, null)
	card.set_bag_stamp(stamp)


func _apply_bag_look(card, it: Dictionary) -> void:
	if card == null:
		return
	if str(it.get("card_id", "")) == "marble":
		_apply_marble_stamp(card, it)
		return
	if str(it.get("card_id", "")) != "bag_of_holding":
		if card.has_method("set_bag_stamp"):
			card.set_bag_stamp(null)
		return
	var filled: bool = int(it.get("bagged_hp", 0)) > 0
	var bag_id: String = "bag_of_holding_closed" if filled else "bag_of_holding"
	var bag_tex: Texture2D = null
	if art != null:
		bag_tex = art.item_tex(bag_id)
		if bag_tex == null:
			bag_tex = art.item_tex("bag_of_holding")
	if bag_tex == null:
		bag_tex = tex_by_item.get(bag_id, tex_by_item.get("bag_of_holding", null))
	if card.has_method("set_icon") and bag_tex != null:
		card.set_icon(bag_tex)
	if not card.has_method("set_bag_stamp"):
		return
	if not filled:
		card.set_bag_stamp(null)
		return
	var snap: Variant = it.get("bagged", {})
	var mid: String = ""
	if typeof(snap) == TYPE_DICTIONARY:
		mid = str((snap as Dictionary).get("card_id", ""))
	var stamp: Texture2D = null
	if art != null and mid != "" and art.has_method("monster_still"):
		stamp = art.monster_still(mid)
	if stamp == null:
		stamp = tex_by_monster.get(mid, null)
	card.set_bag_stamp(stamp)


func _apply_item_stone_look(card, it: Dictionary) -> void:
	if card == null or not card.has_method("set_petrified"):
		return
	var pn: int = int(it.get("petrify_n", 0))
	if _item_stoned(it):
		card.set_petrified(true, false, pn, false)
	else:
		card.set_petrified(false, false, 0, false)


func _fg(k: String, t: String = "", tint: String = "", border: String = "", sup: String = "", icon: String = "") -> Dictionary:
	return {"k": k, "t": t, "tint": tint, "border": border, "sup": sup, "id": icon}


## What the hotbar shows before a hover. One row of marks.
func _face_rows(it: Dictionary, view: Dictionary, depth: int = 0) -> Array:
	var id := str(it.get("card_id", ""))
	if id == "echo_bell" and depth < 2:
		var copied: Dictionary = _echo_face(it)
		if copied.is_empty() or str(copied.get("card_id", "")) == "" or str(copied.get("card_id", "")) == "echo_bell":
			return [[_fg("icon", "", "", "", "", "bagq")]]
		return _face_rows(copied, _item_view(copied), depth + 1)
	var n := str(view.get("number", ""))
	match id:
		"crossbow":
			return [[_fg("icon", "", "", "", "", "nw"), _fg("impact", n), _fg("icon", "", "", "", "", "ne")]]
		"double_axe":
			return [[_fg("impact", n), _fg("icon", "", "", "", "", "cleave")]]
		"longbow":
			return [[_fg("impact", n), _fg("icon", "", "", "", "", "far")]]
		"spiked_flail":
			return [[_fg("impact", n, "", "", "bleed")]]
		"ball_and_chain":
			return [[_fg("impact", n), _fg("icon", "", "", "", "", "noflee")]]
		"spider_egg":
			return [[_fg("impact", n, "", "self")]]
		"left_bracer":
			return [[_fg("shield", n), _fg("icon", "", "", "", "", "nw")]]
		"bracers":
			return [[_fg("shield", n), _fg("icon", "", "", "", "", "ne")]]
		"stone_wall":
			return [[_fg("shield", n), _fg("icon", "", "", "", "", "retain")]]
		"flying_saucer":
			return [[_fg("icon", "", "", "", "", "flee"), _fg("shield", n if n != "" else "5")]]
		"net":
			return [[_fg("impact", "−1–3", "blue")]]
		"throwing_knife":
			return [[_fg("impact", "3"), _fg("icon", "", "", "", "", "slash"), _fg("impact", "1"), _fg("icon", "", "", "", "", "hand")]]
		"arrow_head":
			return [[_fg("impact", "6"), _fg("heart", "−2")]]
		"ale_flagon":
			return [[_fg("heart", "3"), _fg("icon", "", "", "", "", "bag")]]
		"healing_potion":
			return [[_fg("skull"), _fg("icon", "", "", "", "", "east"), _fg("heart", "3")]]
		"cursed_scroll":
			return [[_fg("heart", "6"), _fg("icon", "", "", "", "", "bar"), _fg("icon", "", "", "", "", "spin"), _fg("heart", "−1")]]
		"grief_jar":
			return [[_fg("shield", n), _fg("icon", "", "", "", "", "bar"), _fg("icon", "", "", "", "", "spin"), _fg("heart", "−1")]]
		"signpost":
			return [[_fg("shield", "7"), _fg("icon", "", "", "", "", "nw"), _fg("icon", "", "", "", "", "ne"), _fg("impact", "", "", "self")]]
		"poison_flask":
			return [[_fg("drop", n if n != "" else str(_poison_dose(it)))]]
		"miasma":
			return [[_fg("drop", n if n != "" else "0")]]
		"fangs":
			var hit := _incoming_hit()
			var ehp := 0
			if facing_index >= 0 and facing_index < wheel.size():
				ehp = int(wheel[facing_index].get("hp", 0))
			return [[_fg("impact", str(hit), "", "self"), _fg("skull"), _fg("heart", str(ehp))]]
		"smoke_bomb":
			return [[_fg("icon", "", "", "", "", "spin"), _fg("icon", "", "", "", "", "bag")]]
		"mute_stone":
			return [[_fg("icon", "", "", "", "", "swap")]]
		"polymorph":
			return [[_fg("icon", "", "", "", "", "nw"), _fg("icon", "", "", "", "", "question"), _fg("icon", "", "", "", "", "ne")]]
		"da_boot", "sledgehammer", "last_match", "measuring_tape":
			return [[_fg("skull")]]
		"napalm":
			return [[_fg("heart", "=1")]]
		"rust":
			return [[_fg("shield", n if n != "" else "3"), _fg("icon", "", "", "", "", "ban")]]
		"quiet_bell":
			return [[_fg("icon", "", "", "", "", "ban")]]
		"hex", "toll":
			return [[_fg("skull", n)]]
		"marble":
			var mn := str(int(it.get("marble_n", 0)))
			return [[_fg("impact", mn), _fg("shield", mn)]]
		"recycler":
			if int(it.get("recycle_n", 5)) <= 1:
				return [[_fg("icon", "", "", "", "", "copy")]]
			return [[_fg("text", n if n != "" else str(int(it.get("recycle_n", 5))))]]
		"pocketwatch":
			return [[_fg("text", "Across")]]
		"grappling_hook":
			return [[_fg("text", "Move")]]
		"bag_of_marbles":
			return [[_fg("text", "Fill")]]
		"catapult":
			return [[_fg("text", "Eject")]]
		"bag_of_holding":
			if n != "" and n != "Bag" and n != "—":
				return [[_fg("text", n)]]
			return [[_fg("text", "Bag")]]
		"sling":
			return [[_fg("text", n if n != "" else "Any")]]
	if n == "—" or n == "-":
		return [[_fg("text", "—")]]
	var kind := str(view.get("kind", ""))
	if kind == "ATK":
		return [[_fg("impact", n)]]
	if kind == "BLK":
		return [[_fg("shield", n)]]
	if kind == "HEAL" or kind == "HP":
		return [[_fg("heart", n)]]
	if kind == "DEFEAT":
		if n.is_valid_int():
			return [[_fg("skull", n)]]
		return [[_fg("skull")]]
	if n != "":
		return [[_fg("text", n)]]
	return []


func _item_view(it: Dictionary) -> Dictionary:
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var fighting: bool = phase == "fighting" and facing_index >= 0 and facing_index < wheel.size()
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
		"hp_cost": "",
	}
	match kind:
		"blk":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 0))
			out["number"] = str(out["n"])
			out["note"] = ""
		"atk", "atk_flee_keep", "atk_move":
			out["n"] = int(ops.get("n", 0))
			if str(it.get("card_id", "")) == "arrow_head" or _is_arrow_head(it):
				out["n"] = 6
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
				out["kind"] = "BLK"
				out["number"] = "−1–3"
				out["n"] = 0
			else:
				out["n"] = 3
				out["number"] = "3"
			out["note"] = ""
		"shield_alt":
			var shield_atk: bool = _shield_face(it) == "atk"
			out["kind"] = "ATK" if shield_atk else "BLK"
			out["n"] = 3
			out["number"] = str(3 + (_arrow_head_bonus() if shield_atk else 0))
			out["note"] = ""
			out["can_use"] = fighting
		"atk_alt_24":
			var alt: int = int(it.get("alt_n", 0))
			out["n"] = alt if alt == 2 or alt == 4 else (2 if items_used_this_combat % 2 == 0 else 4)
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_from_hp":
			out["kind"] = "BLK"
			out["n"] = _missing_hp()
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and out["n"] > 0
		"blk_from_highest_atk":
			out["kind"] = "BLK"
			out["n"] = _highest_hand_atk()
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and out["n"] > 0
		"blk_half_atk":
			var half: Dictionary = _buckler_half(m, fighting)
			out["kind"] = "BLK"
			out["even"] = bool(half.get("even", false))
			out["n"] = int(half.get("n", 0))
			out["number"] = str(out["n"]) if bool(half.get("even", false)) else "—"
			out["note"] = ""
			out["can_use"] = fighting and bool(half.get("even", false))
		"heal_last_loss":
			out["kind"] = "HEAL"
			out["n"] = last_hp_lost
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_hp_lost > 0
		"pacemaker_use":
			out["kind"] = "HP"
			out["n"] = 2
			out["number"] = "−2"
			out["note"] = ""
			out["can_use"] = fighting
		"eject_draw":
			out["kind"] = "EJECT"
			out["number"] = "Eject"
			out["note"] = ""
			out["can_use"] = fighting and adventure and facing_index >= 0
		"polymorph":
			out["kind"] = "COPY"
			out["number"] = "Copy"
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("polymorph").is_empty()
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
		"orb":
			out["kind"] = "DEFEAT"
			out["number"] = "Defeat"
			out["note"] = ""
			out["can_use"] = fighting and (not _defeat_blocked(m)) and _incoming_hit() == 0
		"bag_hold":
			out["kind"] = "BAG"
			out["fill"] = Color("4a3d14")
			var cap: int = int(it.get("bagged_hp", 0))
			if cap > 0:
				out["n"] = cap
				out["number"] = str(cap)
				out["can_use"] = fighting and int(m.get("hp", 99)) < cap
			else:
				out["number"] = "Bag"
				out["can_use"] = fighting and int(m.get("hp", 99)) < hp
			out["note"] = ""
		"atk_7_hp":
			# Bloody Wraps: 1 base Attack + 1 per missing HP (full HP = 1).
			out["n"] = 1 + _missing_hp()
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
			out["can_use"] = fighting and (not _defeat_blocked(m)) and int(m.get("atk", 0)) >= 6
		"atk_last":
			out["n"] = last_mob_atk
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting and last_mob_atk > 0
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
		"blk_even_keep":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 1))
			out["number"] = str(out["n"])
			out["note"] = ""
		"blk_coin_keep":
			out["kind"] = "BLK"
			# Both results are even, so Hydra petrifies this card. The face shows both.
			out["n"] = 2
			out["number"] = "2/6"
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
			out["n"] = _poison_dose(it)
			out["number"] = str(out["n"])
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
			out["n"] = maxi(1, int(ops.get("n", 1)))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
			if str(it.get("card_id", "")) == "lantern":
				_lantern_set_n(it, int(out["n"]))
				out["tip"] = str(it.get("ability", ""))
		"move2_keep":
			out["kind"] = "MOVE"
			out["n"] = 2
			out["number"] = "2"
			out["note"] = ""
			out["can_use"] = fighting and _jar_can_move()
		"heal_swap_keep":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"blood_pact":
			out["kind"] = "HP"
			out["n"] = int(ops.get("n", 2))
			out["number"] = "−%s" % out["n"]
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
		"player_flee_keep":
			out["kind"] = "HP"
			out["number"] = "−1"
			out["note"] = ""
			out["fill"] = Color("4a3d14")
			out["can_use"] = fighting and hp > 0
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
		"heal_poison":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("heal", 5))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"heal":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("n", 2))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"heal_both_draw":
			out["kind"] = "HEAL"
			out["n"] = int(ops.get("heal", 3))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"napalm":
			out["kind"] = "HP"
			out["n"] = 1
			out["number"] = "=1"
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
		"toll":
			out["kind"] = "HP"
			out["n"] = int(it.get("toll_n", 6))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = false
		"miasma":
			out["kind"] = "MARK"
			out["n"] = _miasma_min_hp() if fighting else 0
			out["number"] = str(out["n"]) if fighting and int(out["n"]) > 0 else ""
			out["note"] = ""
			out["can_use"] = fighting and int(out["n"]) > 0
		"bag_marbles":
			out["kind"] = "SKIP"
			out["number"] = ""
			out["note"] = ""
			out["can_use"] = fighting
		"marble":
			out["kind"] = "ATK"
			out["n"] = int(it.get("marble_n", 0))
			out["number"] = "%s OR %s" % [out["n"], out["n"]]
			out["note"] = ""
			out["can_use"] = fighting
		"hex":
			out["kind"] = "DEFEAT"
			out["n"] = int(it.get("hex_n", 6))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = false
		"recycle_watch":
			out["kind"] = "SKIP"
			out["fill"] = Color("2f5a3a")
			out["n"] = int(it.get("recycle_n", 5))
			if int(out["n"]) <= 1:
				out["number"] = "↻"
			else:
				out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = false
		"rust_watch":
			out["kind"] = "SKIP"
			out["fill"] = Color("3a2a14")
			out["n"] = int(it.get("rust_n", 3))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = false
		"flee_then_blk":
			out["kind"] = "BLK"
			out["n"] = int(ops.get("n", 5))
			out["number"] = str(out["n"])
			out["note"] = ""
			out["can_use"] = fighting
		"chakram":
			var halves_v: Dictionary = _chakram_halves(it)
			var do_blk_v: bool = bool(halves_v.get("blk", false))
			var do_atk_v: bool = bool(halves_v.get("atk", false))
			if do_atk_v:
				out["kind"] = "ATK"
				out["n"] = _atk_with_head(3)
				out["number"] = str(out["n"])
			elif do_blk_v:
				out["kind"] = "BLK"
				out["n"] = 3
				out["number"] = "3"
			else:
				out["kind"] = "ATK"
				out["n"] = 0
				out["number"] = "—"
			out["note"] = ""
			out["can_use"] = fighting and (do_blk_v or do_atk_v)
		"signpost":
			out["kind"] = "BLK"
			out["n"] = 7
			out["number"] = "7"
			out["note"] = ""
			out["can_use"] = fighting and not _mark_targets("signpost").is_empty()
		"sling":
			out["kind"] = "ATK"
			out["number"] = PLAYER_COPY.text("status.sling_loaded", "Loaded") if _sling_is_loaded(it) else "Any"
			out["note"] = ""
			out["can_use"] = fighting and not _sling_attack_options(int(it.get("uid", -1))).is_empty()
		_:
			out["can_use"] = false
	if _kind_deals_atk(kind):
		var shown: String = str(out.get("number", ""))
		if shown.is_valid_int() and int(out.get("n", 0)) >= 0:
			out["number"] = str(int(out.get("n", 0)) + _arrow_head_bonus())
	if str(it.get("card_id", "")) == "arrow_head" or _is_arrow_head(it):
		out["kind"] = "ATK"
		out["n"] = 6
		out["number"] = "6"
		out["hp_cost"] = "−2"
	if str(it.get("card_id", "")) == "cursed_scroll":
		out["hp_cost"] = "−1"
	var authored: String = str(it.get("card_color", ""))
	if UxStyle.card_color_id(authored) != "auto":
		out["fill"] = UxStyle.card_color_fill(authored)
	else:
		out["fill"] = _utility_fill(kind, str(out.get("kind", "ATK")))
	out["rim"] = rim
	if it.get("spent", false):
		out["can_use"] = false
	if _item_stoned(it):
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
	if _challenge_loot_wait:
		out["can_use"] = not _item_is_curse(it)
	elif not pending_feed.is_empty():
		var feed_uids: Array = pending_feed.get("uids", [])
		out["can_use"] = feed_uids.has(int(it.get("uid", -1))) and not bool(it.get("spent", false))
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
	if in_tutorial:
		log_label.visible = false
		if log_btn:
			log_btn.visible = false
		_log_open = false
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


func _session(kind: String, msg: String, extra: Dictionary = {}) -> void:
	if session_log:
		session_log.push(kind, msg, extra)


func _log(kind: String, msg: String, highlight: Dictionary = {}) -> void:
	_session(kind, msg, highlight)
	if log_label == null:
		return
	if kind == "on_place":
		return
	if kind == "on_click" or kind == "on_draft" or kind == "on_bribe" or kind == "end":
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
	_log_flush()
	var s: Dictionary = wheel[index]
	var title: String = str(s.get("call_name", "")).strip_edges()
	if title == "":
		title = str(s.get("name", "?"))
	var hint: String = _log_hint_of(s)
	if hint == "":
		hint = _log_hint_of(monsters_by_id.get(str(s.get("card_id", "")), {}))
	var cid: String = str(s.get("card_id", ""))
	if cid == "commander":
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
	_log_flush()
	var id: String = str(it.get("card_id", ""))
	var cat: Dictionary = items_by_id.get(id, {})
	var hint: String = _log_hint_of(it)
	if hint == "":
		hint = _log_hint_of(cat)
	var view: Dictionary = _item_view(it)
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
		"ink": UxStyle.kind_hex(str(view.get("kind", "ATK"))),
		"highlight": hl,
	})


func _sort_hotbar() -> void:
	if hotbar.size() > _forced_hand_cap():
		_hotbar_sig = ""
		return
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
	_punch_hero(btn_spin, on and phase == "ready")
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
	if str(wheel[index].get("card_id", "")) == "fairy":
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
		if str(wheel[k].get("card_id", "")) == "fairy" and str(wheel[index].get("kind", "")) == "monster":
			var cur: Dictionary = p.get(index, {})
			cur["hp"] = int(cur.get("hp", 0)) - 1
			p[index] = cur
		if str(wheel[k].get("card_id", "")) == "commander" and str(wheel[index].get("kind", "")) == "monster":
			var cur2: Dictionary = p.get(index, {})
			cur2["atk"] = int(cur2.get("atk", 0)) - 2
			p[index] = cur2
	return p


func _loud_mark_prompt(kind: String) -> void:
	_sync_hub_cue()
	if sfx:
		sfx.play("question", -4.0)
		sfx.play("select", -10.0, 1.12)
	if wheel_view != null:
		_apply_preview(_preview_mark_aim(kind, -1))


func _preview_mark_aim(kind: String, hover: int) -> Dictionary:
	if kind == "sling_any":
		return _preview_sling_payload(hover)
	var p: Dictionary = {}
	var dmg: int = 0
	var it: Dictionary = {}
	if not pending_mark.is_empty():
		it = _find_item(int(pending_mark.get("uid", -1)))
	if kind == "atk_neighbor" or kind == "mark_crossbow":
		dmg = 4
		if not it.is_empty():
			dmg = int(_ops_of(it).get("n", dmg))
		dmg = _atk_with_head(dmg)
	for i in _mark_targets(kind):
		if str(wheel[i].get("card_id", "")) == "goblin" and (kind == "atk_neighbor" or kind == "mark_crossbow"):
			continue
		var slot: Dictionary = p.get(i, {})
		if dmg > 0:
			slot["hp"] = -dmg
			if int(wheel[i].get("hp", 0)) - dmg <= 0:
				slot["kill"] = true
		else:
			slot["mark"] = true
		if hover == i:
			slot["aim"] = true
		p[i] = slot
	return p


func _sling_payload_preview_n(payload: Dictionary) -> int:
	if payload.is_empty():
		return 0
	if _item_is_chakram(payload):
		if bool(_chakram_halves(payload).get("atk", false)):
			return _atk_with_head(3)
		return 0
	var view: Dictionary = _item_view(payload)
	var n: int = int(view.get("n", 0))
	if n <= 0:
		n = int(_ops_of(payload).get("n", 0))
	var pk: String = str(_ops_of(payload).get("kind", ""))
	if pk == "choose" and n <= 0:
		n = 3
	if n <= 0:
		return 0
	if pk == "choose" or _kind_deals_atk(pk) or pk == "marble":
		return _atk_with_head(n)
	return n


func _preview_sling_payload(hover: int) -> Dictionary:
	var p: Dictionary = {}
	var payload: Dictionary = _find_item(int(pending_mark.get("atk_uid", -1)))
	var dmg: int = _sling_payload_preview_n(payload)
	var pk: String = str(_ops_of(payload).get("kind", ""))
	var hits: Dictionary = {}
	if hover >= 0 and hover < wheel.size() and dmg > 0:
		var aimed: Array[int] = []
		if pk == "atk_cleave":
			aimed = _cleave_targets_from(hover)
		else:
			aimed.append(hover)
		for h in aimed:
			hits[h] = true
	for i in _mark_targets("sling_any"):
		var slot: Dictionary = p.get(i, {})
		if hits.has(i) and str(wheel[i].get("card_id", "")) != "goblin":
			var one: int = dmg
			if str(wheel[i].get("card_id", "")) == "anvil" and not _is_silenced(wheel[i]):
				one = mini(one, 1)
			slot["hp"] = -one
			if int(wheel[i].get("hp", 0)) - one <= 0:
				slot["kill"] = true
		else:
			slot["mark"] = true
		if hover == i:
			slot["aim"] = true
		p[i] = slot
	return p


func _kind_previews_facing_kill(kind: String) -> bool:
	## Neighbor / mark / opposite / cleave items must not ghost-kill the facing owner.
	if kind == "atk_neighbor" or kind == "mark_crossbow" or kind == "mark_poison":
		return false
	if kind == "hook_swap" or kind == "hypnotize" or kind == "polymorph" or kind == "signpost":
		return false
	if kind == "atk_opposite" or kind == "atk_cleave" or kind == "defeat_double_hp" or kind == "sling_any":
		return false
	if kind == "atk_move":
		return false
	return _kind_deals_atk(kind)


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
		"blk", "blk_from_hp", "blk_min_hp", "blk_neighbor", "blk_keep", "blk_siphon", "blk_from_atk", "blk_even_keep", "blk_from_highest_atk", "blk_half_atk":
			if bool(view.get("can_use", false)):
				var gain_n: int = maxi(0, n)
				if _twins_double_blk(gain_n):
					gain_n *= 2
				_ghost_blk = blk + gain_n
		"chakram":
			var halves_p: Dictionary = _chakram_halves(it)
			if bool(view.get("can_use", false)) and bool(halves_p.get("blk", false)):
				var cg: int = 3
				if _twins_double_blk(cg):
					cg *= 2
				_ghost_blk = blk + cg
			if bool(view.get("can_use", false)) and bool(halves_p.get("atk", false)) and str(wheel[facing_index].get("card_id", "")) != "goblin":
				var cdmg: int = _atk_with_head(3)
				var cprocs: int = 2 if _twins_double_atk(facing_index, cdmg) else 1
				var ctotal: int = 0
				for _cp in range(cprocs):
					var chit: int = cdmg
					if str(wheel[facing_index].get("card_id", "")) == "anvil" and not _is_silenced(wheel[facing_index]):
						chit = mini(chit, 1)
					ctotal += chit
				p[facing_index] = {"hp": -ctotal}
				if int(wheel[facing_index].get("hp", 0)) - ctotal <= 0:
					if str(wheel[facing_index].get("card_id", "")) != "wick" or _is_silenced(wheel[facing_index]):
						p[facing_index]["kill"] = true
				if str(wheel[facing_index].get("card_id", "")) == "slime_boss":
					p[facing_index]["atk"] = -ctotal
		"signpost":
			if bool(view.get("can_use", false)):
				var sg: int = 7
				if _twins_double_blk(sg):
					sg *= 2
				_ghost_blk = blk + sg
		"shield_alt":
			if bool(view.get("can_use", false)) and _shield_face(it) == "blk":
				var shg: int = 3
				if _twins_double_blk(shg):
					shg *= 2
				_ghost_blk = blk + shg
			elif bool(view.get("can_use", false)) and str(wheel[facing_index].get("card_id", "")) != "goblin":
				var sdmg: int = _atk_with_head(3)
				var sprocs: int = 2 if _twins_double_atk(facing_index, sdmg) else 1
				var stotal: int = 0
				for _sp in range(sprocs):
					var shit: int = sdmg
					if str(wheel[facing_index].get("card_id", "")) == "anvil" and not _is_silenced(wheel[facing_index]):
						shit = mini(shit, 1)
					stotal += shit
				p[facing_index] = {"hp": -stotal}
				if int(wheel[facing_index].get("hp", 0)) - stotal <= 0:
					if str(wheel[facing_index].get("card_id", "")) != "wick" or _is_silenced(wheel[facing_index]):
						p[facing_index]["kill"] = true
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
				var cn: int = _atk_with_head(int(view.get("n", 2)))
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
				var od: int = _atk_with_head(int(view.get("n", 4)))
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
		"defeat_hp", "defeat_atk", "fangs", "defeat_only_item", "bag_hold":
			if bool(view.get("can_use", false)):
				p[facing_index] = {"hp": -int(wheel[facing_index].get("hp", 0)), "kill": true}
		"defeat_double_hp":
			if bool(view.get("can_use", false)):
				for si in _mark_targets("defeat_double_hp"):
					p[si] = {"hp": -int(wheel[si].get("hp", 0)), "kill": true}
		"atk_neighbor", "mark_crossbow":
			if bool(view.get("can_use", false)):
				var nd: int = _atk_with_head(int(view.get("n", 4)))
				for ni in _mark_targets("atk_neighbor"):
					if str(wheel[ni].get("card_id", "")) == "goblin":
						continue
					var nslot: Dictionary = p.get(ni, {})
					nslot["hp"] = int(nslot.get("hp", 0)) - nd
					if int(wheel[ni].get("hp", 0)) + int(nslot.get("hp", 0)) <= 0:
						nslot["kill"] = true
					if str(wheel[ni].get("card_id", "")) == "slime_boss":
						nslot["atk"] = int(nslot.get("atk", 0)) - nd
					p[ni] = nslot
		"atk_zero", "atk_drop":
			if bool(view.get("can_use", false)) and not _atk_is_always(wheel[facing_index]):
				var curz: Dictionary = p.get(facing_index, {})
				var drop_n: int = int(wheel[facing_index].get("atk", 0)) if kind == "atk_zero" else mini(3, int(wheel[facing_index].get("atk", 0)))
				curz["atk"] = -drop_n if kind == "atk_zero" else -mini(int(view.get("n", 3)), int(wheel[facing_index].get("atk", 0)))
				p[facing_index] = curz
		"napalm":
			if bool(view.get("can_use", false)):
				_ghost_hp = 1
				var seats: Array[int] = []
				if facing_index >= 0:
					seats.append(facing_index)
				for j in _napalm_neighbor_seats():
					seats.append(j)
				for si in seats:
					if si < 0 or si >= wheel.size():
						continue
					if str(wheel[si].get("kind", "")) != "monster":
						continue
					var cur_hp: int = int(wheel[si].get("hp", 0))
					if cur_hp <= 1:
						continue
					var slot: Dictionary = p.get(si, {})
					slot["hp"] = 1 - cur_hp
					if str(wheel[si].get("card_id", "")) == "slime_boss":
						slot["atk"] = 1 - int(wheel[si].get("atk", 0))
					p[si] = slot
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
		if wheel_view.has_method("set_moves"):
			wheel_view.set_moves(moves_left, ADVENTURE_MOVES if _is_adventure_mode() else 0)
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
		["any monster", gold],
		["phoenix egg", gold],
		["phoenix", gold],
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
		"move",
		"bled", "bleeds", "bleeding", "bleed",
		"fleeing", "flees", "fled", "flee",
		"poisoned", "poisons", "poison",
		"any",
		"petrifies", "petrified", "petrify",
		"spinning", "spins", "spun", "spin",
		"random",
		"always",
		"swap",
		"loaded",
		"eject",
		"unplayable",
		"rust",
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
		if piece.strip_edges().to_lower() == "any":
			var after_m: String = t.substr(m.get_end()).strip_edges().to_lower()
			if not after_m.begins_with("monster") and not after_m.begins_with("enemy"):
				continue
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
	if low == "unplayable":
		return prefix + "Unplayable" + suffix
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
	if low == "keep" or low == "move" or low == "random" or low.begins_with("owner") or low.begins_with("neighbor"):
		return gold
	if low == "any":
		return gold
	if low.begins_with("flee") or low.begins_with("spin") or low == "spun":
		return gold
	if low.begins_with("poison"):
		return gold
	if low.begins_with("petrif"):
		return gold
	if low == "swap" or low.begins_with("swap"):
		return gold
	if low.begins_with("eject"):
		return gold
	if low == "unplayable":
		return UxStyle.UNPLAYABLE
	if low == "rust":
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
	var lead := ""
	if word == "Attack":
		lead = "[img=18x18]res://assets/ui/icons/atk_burst_18.png[/img] "
	if n == "":
		return "[b][color=%s]%s%s[/color][/b]" % [hex, lead, word]
	return "[b][color=%s]%s%s %s[/color][/b]" % [hex, lead, word, n]


func _kind_always_unplayable(kind: String) -> bool:
	return kind == "passive" or kind == "hex" or kind == "toll" or kind == "recycle_watch" or kind == "rust_watch"


func _strip_unplayable_lead(s: String) -> String:
	var t: String = s.strip_edges()
	var rx := RegEx.new()
	if rx.compile("^(?i)unplayable\\.?\\s*") != OK:
		return t
	return rx.sub(t, "", false).strip_edges()


func _value_is_unplayable_title(bb: String) -> bool:
	var rx := RegEx.new()
	var plain: String = bb
	if rx.compile("\\[[^\\]]+\\]") == OK:
		plain = rx.sub(plain, "", true)
	return plain.strip_edges().to_lower() == "unplayable"


func _item_rule(it: Dictionary) -> Dictionary:
	var view: Dictionary = _item_view(it)
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	var live: int = int(view.get("n", 0))
	if _kind_deals_atk(kind) and live >= 0:
		live = _atk_with_head(live)
	var fighting: bool = phase == "fighting" and facing_index >= 0 and facing_index < wheel.size()
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
	if kind == "heal" or kind == "heal_both_draw" or kind == "heal_kills" or kind == "heal_keep" or kind == "heal_swap_keep" or kind == "heal_full" or kind == "heal_poison" or kind == "napalm" or kind == "blood_pact":
		num_c = hp_c
	elif kind == "smoke" or kind == "hook_swap":
		num_c = gold
	var cream := num_c
	match kind:
		"blk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["body"] = "Gain 4 block."
		"shield_alt":
			var on_atk: bool = _shield_face(it) == "atk"
			var shown: int = _atk_with_head(3) if on_atk else 3
			if on_atk:
				out["value"] = _value_bb("Attack", str(shown), atk_c)
			else:
				out["value"] = _value_bb("Block", str(shown), blk_c)
			out["equation"] = "(%s) or (%s), then the other" % [_bb(atk_c, "Attack 3"), _bb(blk_c, "Block 3")]
			out["body"] = str(it.get("ability", "3 Attack or 3 Block. Alternates on Item Use"))
		"atk_alt_24":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s) then (%s) then (%s)…" % [_bb(atk_c, "2"), _bb(atk_c, "4"), _bb(atk_c, "2")]
			out["body"] = str(it.get("ability", "Flips 2 ↔ 4 after any Item is used. Keeps its number between fights."))
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
			elif spike_n:
				var spike_atk: int = _atk_with_head(2)
				out["value"] = "%s    %s" % [_value_bb("Attack", str(spike_atk), atk_c), _value_bb("Block", "2", blk_c)]
				out["equation"] = "(%s) or (%s)" % [_bb(atk_c, str(spike_atk)), _bb(blk_c, "2")]
				out["body"] = "Deal 2 attack, or gain 2 block."
			else:
				out["value"] = _value_bb("Attack", str(live if live > 0 else 3), atk_c)
				out["equation"] = "(%s) or (%s and %s)" % [_bb(atk_c, str(_atk_with_head(3))), _bb(atk_c, str(_atk_with_head(1))), _bb(gold, "Keep")]
				out["body"] = "Throw for 3 and lose it, or nick for 1 and keep it."
		"atk_move":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "Move → then (%s)" % _bb(atk_c, str(live))
			out["body"] = str(it.get("ability", "Move →, then Attack 3."))
		"atk", "atk_flee_keep":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			if _is_arrow_head(it) or str(it.get("card_id", "")) == "arrow_head":
				out["equation"] = "(%s) then Lose %s" % [_bb(atk_c, "6"), _bb(hp_c, "2 HP")]
			elif kind == "atk_flee_keep":
				out["equation"] = "(%s)  Keep + Flee if live" % _bb(atk_c, "ATK 2")
			elif str(it.get("card_id", "")) == "ball_and_chain":
				out["equation"] = "(%s) + (%s)" % [_bb(atk_c, "2"), _bb(atk_c, "+2 per cancelled Flee")]
			else:
				out["equation"] = "(%s)" % _bb(atk_c, str(live))
			out["body"] = str(it.get("ability", "Deal Attack."))
		"atk_if_enemy_atk_even":
			out["value"] = _value_bb("Attack", str(live if fighting else 4), atk_c)
			out["equation"] = "(%s) or (%s if %s)" % [_bb(cream, "2"), _bb(atk_c, "4"), _bb(gold, "Even ATK")]
			out["body"] = "Attack 2, or 4 if the enemy's attack is even."
		"blk_from_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s − %s)" % [_bb(cream, "max HP"), _bb(hp_c, "HP")]
			out["body"] = "Block equal to the HP you are missing."
			if fighting and live <= 0:
				out["warn"] = "Can't — you are not missing HP."
		"blk_from_highest_atk":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Highest Attack Item")
			out["body"] = "Gain Block equal to your highest Attack Item"
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no Attack item."
		"blk_half_atk":
			if bool(view.get("even", false)):
				out["value"] = _value_bb("Block", str(live), blk_c)
			else:
				out["value"] = _value_bb("Block", "—", blk_c)
			out["equation"] = "(%s ÷ 2)" % _bb(atk_c, "Enemy Attack")
			out["body"] = str(it.get("ability", "If enemy Attack is Even, this Blocks for half of it."))
			if fighting and not bool(view.get("even", false)):
				out["warn"] = "Can't — their Attack is odd."
			elif not fighting:
				out["warn"] = "Can't — you are not in a fight."
		"heal_last_loss":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s)" % _bb(hp_c, "Last HP lost")
			out["body"] = "Heal equal to the amount of HP you most recently lose."
			if fighting and last_hp_lost <= 0:
				out["warn"] = "Can't — you have not lost HP yet."
		"pacemaker_use":
			out["value"] = _value_bb("HP", "−2", hp_c)
			out["body"] = "When you lose exactly 2 HP, Heal 1. On Use, Lose 2 HP."
		"eject_draw":
			out["value"] = _value_bb("Eject", "", gold)
			out["body"] = "Eject your Enemy. Draw an Item."
			if fighting and not adventure:
				out["warn"] = "Can't — Challenge only."
		"polymorph":
			out["value"] = _value_bb("Copy", "", gold)
			out["body"] = "Turn your opponent into an exact copy of a Neighbor of your choice."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no Neighbor."
		"blk_min_hp":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(the lower of %s and %s)" % [_bb(hp_c, "Your HP"), _bb(hp_c, "Enemy HP")]
			out["body"] = "Block equal to whoever has less HP — you or the enemy."
		"defeat_hp":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s < %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			out["body"] = "Defeat an enemy with fewer HP than you (not equal). Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.boot", "Can't — this enemy has as much HP as you, or more.")
		"orb":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["body"] = str(it.get("ability", ""))
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
		"bag_hold":
			out["title"] = _title_case(str(it.get("name", "Bag of Holding")))
			out["body"] = str(it.get("ability", "Bag an enemy with less HP than you."))
			var cap_hp: int = int(it.get("bagged_hp", 0))
			if cap_hp > 0:
				out["value"] = _value_bb("Bag", str(cap_hp), hp_c)
				out["equation"] = "(%s < %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, str(cap_hp))]
			else:
				out["value"] = _value_bb("Bag", "", gold)
				out["equation"] = "(%s < %s)" % [_bb(hp_c, "Enemy HP"), _bb(hp_c, "Your HP")]
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.boot", "Can't — this enemy has as much HP as you, or more.")
		"atk_7_hp":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "1"), _bb(hp_c, "missing HP")]
			out["body"] = "1 Attack, plus 1 for each HP you are missing."
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
			out["body"] = "Get stronger. +1 Attack for each monster Defeated."
		"atk_hp_loss":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s × %s)" % [_bb(cream, "2"), _bb(hp_c, "Times you Bled")]
			out["body"] = "Gets stronger. +2 attack each time you lose any HP."
		"defeat_atk":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s ≥ %s)" % [_bb(atk_c, "Enemy ATK"), _bb(cream, "6")]
			out["body"] = "Defeat an enemy with 6 or more attack. Combat ends immediately."
			if fighting and _defeat_blocked(m if fighting else {}):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.sledge", "Can't — they don't hit hard enough.")
		"atk_last":
			out["value"] = _value_bb("Attack", str(live), atk_c)
			out["equation"] = "(%s)" % _bb(atk_c, "Last Spun ATK")
			out["body"] = "Attack equal to the Attack of the last monster you spun."
			if fighting and last_mob_atk <= 0:
				out["warn"] = "Can't — no last monster yet."
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
		"blk_even_keep":
			out["value"] = _value_bb("Block", str(live), blk_c)
			out["equation"] = "(%s). %s if Block is even" % [_bb(blk_c, "1"), _bb(gold, "Keep")]
			out["body"] = str(it.get("ability", "Block 1. If your Block is now Even, Keep this."))
		"blk_coin_keep":
			out["value"] = _value_bb("Block", "2/6", blk_c)
			out["equation"] = "50%% (%s) or (%s and %s). %s" % [_bb(blk_c, "2"), _bb(blk_c, "6"), _bb(hp_c, "Lose 2 HP"), _bb(gold, "Keep")]
			out["body"] = str(it.get("ability", "Gain 2 Block, or Gain 6 Block and Lose 2 HP. Keep."))
		"smoke":
			out["value"] = _value_bb("Reroll", "", var_c)
			out["body"] = "Abort this fight, spin again (not the same slice), and gain a random unseen item."
		"fangs":
			out["value"] = _value_bb("Defeat", "", var_c)
			out["equation"] = "(%s) then %s then %s" % [_bb(hp_c, "Take their ATK"), _bb(var_c, "Defeat"), _bb(hp_c, "Heal their HP")]
			out["body"] = "Take their hit (Block still works). They are Defeated. Then Heal equal to the HP they had."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
		"mark_poison":
			var poison_n: int = int(view.get("n", _poison_dose(it)))
			out["value"] = _value_bb("Poison", str(poison_n), gold)
			out["body"] = "Mark a Neighbor with %d Poison." % poison_n
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
			out["equation"] = "(%s) opposite if even count" % _bb(atk_c, "5")
			out["body"] = "Deal 5 attack to the owner across from you. Needs an even number of owners."
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — odd number of owners on the wheel."
		"heal_kills":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s + %s)" % [_bb(cream, "1"), _bb(var_c, "Defeat")]
			out["body"] = "Heal 1, plus 1 for each owner you have already Defeated."
		"heal_full":
			out["value"] = _value_bb("Heal", "6", hp_c)
			out["equation"] = "(%s)" % _bb(hp_c, "6")
			out["body"] = "Heal 6. On Spin, lose 1 HP."
		"napalm":
			out["value"] = _value_bb("HP", "1", hp_c)
			out["equation"] = "Bleed to (%s)" % _bb(hp_c, "1")
			out["body"] = str(it.get("ability", "Set the HP of the Enemy, its Neighbors, and yourself to 1 HP"))
		"magnet":
			out["value"] = _value_bb("Spin", str(view.get("number", "Off")), gold)
			out["equation"] = "(%s) or (%s) or (%s)" % [_bb(atk_c, "Highest ATK"), _bb(atk_c, "Lowest ATK"), _bb(gold, "Off")]
			out["body"] = str(it.get("ability", "The next Spin lands on the Highest or Lowest Attack monster, then this is discarded."))
		"hypnotize":
			out["value"] = _value_bb("Hypnotize", "", gold)
			out["body"] = str(it.get("ability", "Target any enemy. That enemy attacks the monster that is Across from them."))
			if fighting and not bool(view.get("can_use", false)):
				var living_n: int = _living_monster_indices().size()
				if living_n % 2 != 0:
					out["warn"] = "Can't — odd number of monsters."
				else:
					out["warn"] = "Can't — no monster across from them."
		"hook_swap":
			out["value"] = _value_bb("Move", "", gold)
			out["body"] = str(it.get("ability", "Move to Any Monster, then Draw 1 Item"))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — no living monster."
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
			var heal_shown: int = maxi(1, live)
			out["value"] = _value_bb("Heal", str(heal_shown), hp_c)
			out["equation"] = "(%s) then +1. %s if still missing HP" % [_bb(hp_c, str(heal_shown)), _bb(gold, "Keep")]
			out["body"] = _lantern_ability(heal_shown)
		"move2_keep":
			out["value"] = _value_bb("Move", "2", gold)
			out["equation"] = "(%s) one direction. %s" % [_bb(gold, "2"), _bb(gold, "Keep")]
			out["body"] = str(it.get("ability", "Move 2 in a random direction, and Keep this."))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — nowhere to move 2."
		"heal_swap_keep":
			out["value"] = _value_bb("Heal", "2", hp_c)
			out["equation"] = "(%s) then Move +1 seat" % _bb(hp_c, "2")
			out["body"] = "Heal 2. Whenever you Move, you Move an additional space in that direction."
		"blood_pact":
			out["value"] = _value_bb("HP", "−2", hp_c)
			out["body"] = "You and your Enemy lose 2 HP"
		"toll":
			out["value"] = _value_bb("Toll", str(int(it.get("toll_n", 6))), var_c)
			out["equation"] = "−1 / Item Use  Die at 0"
			out["body"] = str(it.get("ability", "Unplayable. On Item Use, decrease this by 1. When this reaches 0, Die."))
		"heal":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["body"] = str(it.get("ability", "Heal 2."))
		"heal_both_draw":
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["body"] = str(it.get("ability", "Heal yourself and the Enemy for 3 HP. Then draw an Item."))
		"heal_poison":
			var pois_n: int = int(_ops_of(it).get("poison", 2))
			out["value"] = _value_bb("Heal", str(live), hp_c)
			out["equation"] = "(%s) + Poison %s" % [_bb(hp_c, "5"), _bb(gold, str(pois_n))]
			out["body"] = str(it.get("ability", "Heal 5. Gain %s Poison." % pois_n))
		"miasma":
			out["value"] = _value_bb("Poison", "min HP", gold)
			out["equation"] = "Poison all = min HP"
			out["body"] = str(it.get("ability", "Apply Poison to all Monsters equal to the lowest HP on any Monster"))
		"bag_marbles":
			out["value"] = _value_bb("Marbles", "10", gold)
			out["equation"] = "Fill to 10 Marbles"
			out["body"] = str(it.get("ability", "Fill your inventory with Marbles"))
		"marble":
			var marble_n: int = int(it.get("marble_n", 0))
			out["value"] = "%s    %s" % [_value_bb("Attack", str(marble_n), atk_c), _value_bb("Block", str(marble_n), blk_c)]
			out["equation"] = "(N ATK or N BLK)"
			out["body"] = str(it.get("ability", "Gain 0 Atk or 0 Block randomly. On Spin, increase these numbers by 1"))
		"chakram":
			var halves_r: Dictionary = _chakram_halves(it)
			var bits: PackedStringArray = PackedStringArray()
			if bool(halves_r.get("blk", false)):
				bits.append(_value_bb("Block", "3", blk_c))
			if bool(halves_r.get("atk", false)):
				bits.append(_value_bb("Attack", str(_atk_with_head(3)), atk_c))
			if bits.is_empty():
				out["value"] = _value_bb("Unplayable", "", "#A8A29A")
				out["warn"] = "Can't — you already have a Block item and an Attack item."
			else:
				out["value"] = "    ".join(bits)
		"signpost":
			out["value"] = _value_bb("Block", "7", blk_c)
			out["equation"] = "(%s) then a Neighbor Attacks you" % _bb(blk_c, "7")
			out["body"] = str(it.get("ability", "Block 7, then choose a Neighbor to Attack you"))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = PLAYER_COPY.text("warn.neighbor", "Can't — no neighboring enemy.")
		"sling":
			if _sling_is_loaded(it):
				out["value"] = UxStyle.with_def_link(_value_bb(PLAYER_COPY.text("status.sling_loaded", "Loaded"), "", gold), "Loaded")
			else:
				out["value"] = _value_bb("Any", "", gold)
			out["body"] = str(it.get("ability", "Select an Attack. It can target Any monster. Draw 1 Item"))
			if fighting and not bool(view.get("can_use", false)):
				out["warn"] = "Can't — you need an Attack item."
		"hex":
			out["value"] = _value_bb("Defeat", str(int(it.get("hex_n", 6))), var_c)
			out["equation"] = "Defeat at Spin 0"
			out["body"] = str(it.get("ability", "Unplayable. Defeats the Monster 6 Spins from now."))
		"recycle_watch":
			var rec_n: int = int(it.get("recycle_n", 5))
			out["value"] = _value_bb("Discards", str(rec_n) if rec_n > 1 else "next", gold)
			out["equation"] = "(%s) then copy that Item" % _bb(gold, "5 Discards")
			out["body"] = str(it.get("ability", "Every 5th Item Discarded is copied into your Hand"))
		"rust_watch":
			out["value"] = _value_bb("Rust", str(int(it.get("rust_n", 3))), gold)
			out["equation"] = "Ignore Block. Discard after 3 Spins."
			out["body"] = str(it.get("ability", "Enemies ignore your Block for 3 Spins"))
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
		"player_flee_keep":
			out["value"] = _value_bb("Flee", "−1", hp_c)
			out["equation"] = "You Flee, then lose 1 HP. This stays."
			out["body"] = str(it.get("ability", "Flee. Lose 1 HP. Keep this."))
		"echo":
			out["value"] = ""
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
			out["body"] = "If you have no playable items that Attack, Defeat the enemy."
			if fighting and _defeat_blocked(m):
				out["warn"] = "Can't — this enemy cannot be Defeated."
			elif fighting and _hand_has_atk_item(int(it.get("uid", -1))):
				out["warn"] = "Can't — you are holding a playable Attack item."
		"chaos_reroll":
			out["value"] = _value_bb("Swap", "", var_c)
			out["body"] = "Choose 2 Items and Swap them."
			if fighting and _chaos_candidates(int(it.get("uid", -1))).is_empty():
				out["warn"] = "Can't — nothing to Swap."
		"skip_swing":
			out["value"] = _value_bb("Skip", "", var_c)
			out["body"] = "Skip their attack this fight. They still leave the wheel."
		"passive":
			out["value"] = ""
			out["body"] = str(it.get("ability", ""))
		_:
			out["value"] = str(view.get("kind", ""))
			out["body"] = str(it.get("ability", ""))
	if it.get("spent", false):
		out["warn"] = PLAYER_COPY.text("warn.spent", "Already used this fight.")
	if int(it.get("petrify_n", 0)) > 0:
		out["warn"] = "Petrify — Unplayable."
	elif bool(it.get("petrified", false)):
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
	var show_unp: bool = _kind_always_unplayable(kind) or kind == "echo" or _item_stoned(it)
	if show_unp:
		ab = _strip_unplayable_lead(ab)
	if ab != "" and ab != "---":
		out["body"] = _paint_explainer(ab, cream)
	var ex: String = str(it.get("explainer", ""))
	if ex != "" and ex != "---":
		out["equation"] = _paint_explainer(ex, cream)
	if show_unp and (_value_is_unplayable_title(str(out.get("value", ""))) or str(out.get("value", "")).strip_edges() == ""):
		if ex != "" and ex != "---":
			out["value"] = _paint_explainer(ex, cream)
			out["equation"] = ""
	return out


func _monster_rule(s: Dictionary) -> Dictionary:
	var id: String = str(s.get("card_id", ""))
	var atk_n: String = str(s.get("atk", 0))
	var hp_n: String = str(s.get("hp", 0))
	var atk_c := "#E07A7A"
	var hp_c := "#E8A0A0"
	var out := {
		"title": _title_case(str(s.get("name", "?"))),
		"value": "%s    %s" % [_value_bb("HP", hp_n, hp_c), _value_bb("Attack", atk_n, atk_c)],
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
	if _is_silenced(s):
		var sil: String = PLAYER_COPY.text("status.silenced", "Silenced")
		out["speech"] = ""
		out["equation"] = ""
		out["call_chip"] = sil
		out["reminder"] = ""
		out["hint"] = ""
		out["call"] = sil
		return out
	if (id == "gargoyle" or id == "hydra") and _shift_held:
		out["warn"] = "Petrify — becomes Unplayable until your next Spin."
	var hide_owner_math: bool = id == "golem" or id == "wizard"
	if hide_owner_math:
		out["reminder"] = ""
	if _shift_held:
		if reminder != "" and not hide_owner_math:
			out["equation"] = _paint_explainer(reminder, atk_c)
	elif call_n != "":
		out["call_chip"] = call_n
		out["equation"] = ""
	var speech: String = str(s.get("ability", "")).strip_edges()
	if (speech == "" or speech == "---") and _shift_held and not hide_owner_math:
		speech = str(s.get("explainer", "")).strip_edges()
	if speech == "" or speech == "---":
		speech = str(s.get("special_text", "")).strip_edges()
	if speech != "":
		out["speech"] = _rewrite_keywords(speech, true, "#E8C36A")
	return out


func keyword_monster_callout(id: String) -> Dictionary:
	if not monsters_by_id.has(id):
		return {}
	var card: Dictionary = monsters_by_id[id]
	var s := {
		"kind": "monster",
		"card_id": id,
		"name": _title_case(str(card.get("name", id))),
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"call_name": MONSTER_LINES.call_of(id, card),
		"reminder": MONSTER_LINES.reminder_of(id, card),
		"atk": _card_base_atk(id),
		"hp": _card_base_hp(id),
		"hp_max": _card_base_hp(id),
		"pack_tier": int(card.get("tier", 1)),
		"silenced": false,
	}
	var had_sil: bool = silenced.has(id)
	var held: bool = bool(silenced.get(id, false))
	silenced[id] = false
	var rule: Dictionary = _monster_rule(s)
	if had_sil:
		silenced[id] = held
	else:
		silenced.erase(id)
	rule["card_id"] = id
	rule["look"] = _monster_plate_look(s, rule)
	if art != null:
		rule["portrait"] = art.monster_still(id)
	return rule


func keyword_item_callout(id: String) -> Dictionary:
	if not items_by_id.has(id):
		return {}
	var card: Dictionary = items_by_id[id]
	var it := {
		"card_id": id,
		"name": str(card.get("name", id)),
		"ability": str(card.get("ability", "")),
		"explainer": str(card.get("explainer", "")),
		"ops": card.get("ops", {}),
		"pack_tier": int(card.get("tier", 1)),
		"card_color": str(card.get("card_color", "")),
		"spent": false,
	}
	var rule: Dictionary = _item_rule(it)
	rule["card_id"] = id
	rule["plate_kind"] = "item"
	rule["look"] = _item_look(it)
	if art != null:
		rule["portrait"] = art.item_tex(id)
	return rule


func _monster_plate_look(s: Dictionary, rule: Dictionary) -> Dictionary:
	var look: Dictionary = _monster_look(s)
	look["rank"] = PLAYER_COPY.tier_name(_tier_of(s))
	look["hp_n"] = str(s.get("hp", 0))
	look["atk_n"] = str(s.get("atk", 0))
	if wheel_view != null:
		look["stat_style"] = int(wheel_view.stat_style)
	if _shift_held:
		look["hint"] = ""
	else:
		look["hint"] = str(rule.get("hint", ""))
	var chip: String = str(rule.get("call_chip", "")).strip_edges()
	if chip != "":
		look["call_chip"] = chip
		var call_col := Color("c5cdd8")
		if wheel_view != null and wheel_view.has_method("ability_color_for"):
			call_col = wheel_view.ability_color_for(_special_id_of(s))
		look["call_color"] = call_col
		if wheel_view != null and wheel_view.has_method("medal_tex_for"):
			look["medal"] = wheel_view.medal_tex_for(str(s.get("card_id", "")))
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
	if not PlaytestUx.hover_inspect_allowed(phase):
		_idle_inspect()
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
		var mid := str(s.get("card_id", ""))
		var frames: Array = art.monster_portrait_frames(mid)
		if frames.is_empty():
			port = art.monster_still(mid)
		else:
			port = frames[0]
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


func _on_stat_style_changed(_style: int) -> void:
	_refresh_monster_plates()


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


func _log_block_rects() -> Array:
	var out: Array = []
	if log_label != null and log_label.visible and log_label.is_visible_in_tree():
		out.append(log_label.get_global_rect())
	if log_btn != null and log_btn.visible and log_btn.is_visible_in_tree():
		out.append(log_btn.get_global_rect())
	return out


func _place_fly(near: Control = null, at: Vector2 = Vector2.INF) -> void:
	if fly_tip == null or not fly_tip.visible:
		return
	fly_tip.reset_size()
	var sz: Vector2 = fly_tip.get_combined_minimum_size()
	sz.x = maxf(sz.x, 280.0)
	if bool(fly_tip.get("_pin_always")):
		sz.x = maxf(sz.x, 250.0)
	var anchor := Rect2()
	var prefer_right := true
	if near != null and is_instance_valid(near):
		anchor = near.get_global_rect()
		prefer_right = not _fly_goes_left(near)
	elif at.x < 100000.0:
		anchor = Rect2(at - Vector2(28, 28), Vector2(56, 56))
		if wheel_view != null and wheel_view.has_method("slice_avoid_global"):
			var best := -1
			var best_d := 100000.0
			var n: int = wheel.size()
			for i in n:
				var r: Rect2 = wheel_view.slice_avoid_global(i)
				var d: float = r.get_center().distance_to(at)
				if d < best_d:
					best_d = d
					best = i
			if best >= 0 and best_d < 80.0:
				anchor = wheel_view.slice_avoid_global(best)
	else:
		var mouse: Vector2 = get_global_mouse_position()
		anchor = Rect2(mouse, Vector2(12, 12))
	var gap := 12.0
	var right := Vector2(anchor.end.x + gap, anchor.position.y - 8.0)
	var left := Vector2(anchor.position.x - sz.x - gap, anchor.position.y - 8.0)
	var above := Vector2(anchor.position.x + (anchor.size.x - sz.x) * 0.5, anchor.position.y - sz.y - gap)
	var below := Vector2(anchor.position.x + (anchor.size.x - sz.x) * 0.5, anchor.end.y + gap)
	var candidates: Array = [right, left, above, below] if prefer_right else [left, right, above, below]
	if fly_tip.edit_kind == "monster":
		candidates = [above, below, right, left]
	if PlaytestUx.draft_tip_prefer_below() and challenge_draft_ui != null and challenge_draft_ui.visible and near != null and is_instance_valid(near) and challenge_draft_ui.is_ancestor_of(near):
		var box: Rect2 = challenge_draft_ui.get_global_rect()
		var under := Vector2(box.position.x + (box.size.x - sz.x) * 0.5, box.end.y + 10.0)
		var off_wheel := Vector2(box.position.x, box.end.y + 10.0)
		candidates = [under, off_wheel, below, left]
	var blocks: Array = [anchor]
	blocks.append_array(_log_block_rects())
	if challenge_draft_ui != null and challenge_draft_ui.visible and challenge_draft_ui.has_method("draft_cards"):
		for card in challenge_draft_ui.draft_cards():
			if card is Control:
				blocks.append((card as Control).get_global_rect())
	for other in [face_box, inspect, speech_box]:
		if other == null or other == fly_tip or not (other is Control):
			continue
		var oc: Control = other
		if not oc.visible or not oc.is_visible_in_tree():
			continue
		blocks.append(oc.get_global_rect())
	var pos: Vector2 = preload("res://scripts/ui/tooltip_clamp.gd").place(get_viewport_rect().size, sz, candidates, blocks)
	if challenge_draft_ui != null and challenge_draft_ui.visible and near != null and is_instance_valid(near) and challenge_draft_ui.is_ancestor_of(near):
		var tip_r := Rect2(pos, sz)
		var covers := false
		if challenge_draft_ui.has_method("draft_cards"):
			for card in challenge_draft_ui.draft_cards():
				if card is Control and tip_r.intersects((card as Control).get_global_rect()):
					covers = true
					break
		if covers:
			fly_tip.hide_plate()
			return
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
	if _cube_line != "":
		var cube_look := {}
		var cube_mon: Dictionary = {}
		if facing_index >= 0 and facing_index < wheel.size():
			cube_look = _monster_look(wheel[facing_index])
			cube_mon = wheel[facing_index]
		var mouth: Vector2 = Vector2.ZERO
		var talk_i: int = _speech_from_index if _speech_from_index >= 0 and _speech_from_index < wheel.size() else facing_index
		if talk_i >= 0 and talk_i < wheel.size():
			cube_look = _monster_look(wheel[talk_i])
			cube_mon = wheel[talk_i]
		if combat_stage != null and combat_stage.visible and talk_i == facing_index:
			mouth = combat_stage.mouth_global()
		elif wheel_view:
			if talk_i < 0:
				for i in range(wheel.size()):
					if str(wheel[i].get("card_id", "")) == "death_bell" or str(wheel[i].get("card_id", "")) == "oligarch":
						talk_i = i
						cube_look = _monster_look(wheel[i])
						cube_mon = wheel[i]
						break
			if talk_i >= 0:
				mouth = wheel_view.slice_portrait_global(talk_i)
		speech_box.present(mouth, _cube_line, cube_look, true)
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
	if _berserk_line != "":
		var rage_talk := {}
		var rage_mouth := Vector2.ZERO
		var ri: int = _berserk_talk_index
		if ri >= 0 and ri < wheel.size():
			rage_talk = wheel[ri]
			if wheel_view:
				rage_mouth = wheel_view.slice_portrait_global(ri)
			if ri == facing_index and combat_stage != null and combat_stage.visible:
				rage_mouth = combat_stage.mouth_global()
		if rage_mouth != Vector2.ZERO:
			speech_box.present(rage_mouth, _berserk_line, _monster_look(rage_talk))
			_maybe_speak_monster(_berserk_line, rage_talk)
			return
		speech_box.hide_speech()
		return
	speech_box.hide_speech()


func _maybe_speak_monster(text: String, mon: Dictionary) -> void:
	if sfx == null or text.strip_edges() == "":
		return
	var key: String = "%s|%s" % [str(mon.get("card_id", "")), text]
	if key == _spoken_key:
		return
	_spoken_key = key
	sfx.speak(&"monster", text, {"tier": _tier_of(mon) if not mon.is_empty() else 1, "monster_id": str(mon.get("card_id", ""))})


func _ability_avoid_rects() -> Array:
	var out: Array = []
	if face_box != null and face_box.visible:
		out.append(face_box.get_global_rect())
	if combat_stage != null and combat_stage.visible:
		out.append(combat_stage.get_global_rect())
	if dungeon_deck_ui != null and dungeon_deck_ui.visible:
		out.append(dungeon_deck_ui.get_global_rect())
	if btn_done != null and btn_done.visible:
		out.append(btn_done.get_global_rect())
	if btn_move_left != null and btn_move_left.visible:
		out.append(btn_move_left.get_global_rect())
	if btn_move_right != null and btn_move_right.visible:
		out.append(btn_move_right.get_global_rect())
	if intent_plate != null and intent_plate.visible:
		out.append(intent_plate.get_global_rect())
	if wheel_view != null and wheel_view.has_method("_heart_arc_global_rect"):
		out.append(wheel_view._heart_arc_global_rect())
	return out


## Map player_stage state names onto hub `play_hero` anims. Face-off / left stage is retired.
func _hub_anim_for_player(state: String) -> String:
	match state:
		"use":
			return "grab"
		"attack":
			return "swipe"
		"defeat":
			return "death"
		"heal", "hit", "block", "victory", "lowhp", "idle":
			return state
		"run":
			return "walkoff"
		_:
			return "idle"


func _player_play(state: String, loops: int = 1) -> void:
	# Combat Sprout stays in the wheel hub. Do not wake the left-stage Control.
	if player_stage != null:
		player_stage.hide_stage()
	if wheel_view == null or not wheel_view.has_method("play_hero"):
		return
	wheel_view.hub_hp = hp
	wheel_view.hub_hp_max = HP_MAX
	if not wheel_view.hub_sprout_on:
		_hub_set(false, 1.0, Color.WHITE, true)
	var anim: String = _hub_anim_for_player(state)
	# Dual call sites (play_hero then _player_play) must not restart the same one-shot.
	if str(wheel_view.hero_anim) == anim and wheel_view.has_method("_hero_is_loop") and not wheel_view._hero_is_loop(anim):
		return
	wheel_view.play_hero(anim, loops)


# Goblin and Bandit facing sheets: the solid body is 46 pixels tall.
# Sprout stays that tall in the same portrait fit the monster uses. He does not grow for Dragon or shrink for Fairy.
func _medium_monster_px(port: Vector2) -> float:
	var solid := 46.0
	var fit_w: float = maxf(1.0, port.x - 8.0)
	var fit_h: float = maxf(1.0, port.y - 12.0)
	var scale_n: float = minf(fit_h / solid, fit_w / solid)
	scale_n = floor(scale_n / 0.25) * 0.25
	scale_n = clampf(scale_n, 0.25, 4.0)
	return solid * scale_n


func _sprout_keeps_stage() -> bool:
	# Left-stage Sprout is retired; combat anims live in the hub.
	return false


func _fight_sprite_pad() -> int:
	if combat_stage == null:
		return 0
	combat_stage.size = Vector2(280, 240)
	combat_stage.custom_minimum_size = combat_stage.size
	if combat_stage.has_method("_place_sprite"):
		combat_stage._place_sprite()
	var sh: float = combat_stage.sprite_height() if combat_stage.has_method("sprite_height") else 0.0
	return int(round(sh / 3.0))


func _wheel_block_circle() -> Dictionary:
	if wheel_view == null:
		return {}
	var rad: float = minf(wheel_view.size.x, wheel_view.size.y) * 0.50
	return {
		"c": wheel_view.global_position + wheel_view.size * 0.5,
		"r": rad + 10.0,
	}


func _rect_hits_circle(rect: Rect2, c: Vector2, rad: float) -> bool:
	var nx: float = clampf(c.x, rect.position.x, rect.end.x)
	var ny: float = clampf(c.y, rect.position.y, rect.end.y)
	return c.distance_to(Vector2(nx, ny)) < rad


func _card_hits_log_or_bar(rect: Rect2) -> bool:
	if hotbar_panel != null and hotbar_panel.visible and rect.intersects(hotbar_panel.get_global_rect().grow(8.0)):
		return true
	if log_label != null and log_label.visible and rect.intersects(log_label.get_global_rect().grow(8.0)):
		return true
	return false


func _card_blocked(rect: Rect2) -> bool:
	var circ: Dictionary = _wheel_block_circle()
	if not circ.is_empty() and _rect_hits_circle(rect, circ["c"], float(circ["r"])):
		return true
	return _card_hits_log_or_bar(rect)


func _layout_floor_pair() -> void:
	# Retired face-off floor staging (left Sprout + FLOOR_Y pair). Portrait / callout
	# stay in the right stack from `_place_fight_art`; Sprout stays in the hub.
	_sprout_mode = "hub"
	_sprout_kill()
	if player_stage != null:
		player_stage.traveling = false
		player_stage.hide_stage()
	_hub_set(false, 1.0, Color.WHITE, true)


func _floor_pair_clear(_card_x: float, _card_top: float, _card_w: float, _card_h: float, _foot: Vector2, _rim_c: Vector2, _rim_r: float) -> bool:
	return true


func _sprout_x_for(center_x: float) -> float:
	if player_stage == null:
		return center_x
	return center_x - player_stage.size.x * 0.5


func _apply_sprout_floor() -> void:
	# Face-off left stage retired — keep player_stage dark.
	if player_stage != null:
		player_stage.traveling = false
		player_stage.hide_stage()
	_sprout_mode = "hub"


func _hold_sprout_on_floor() -> void:
	_apply_sprout_floor()


func _recenter_hotbar() -> void:
	if hotbar_wrap == null or hotbar_panel == null or wheel_view == null:
		return
	var parent_w: float = hotbar_wrap.size.x
	if parent_w < 32.0:
		return
	var panel_w: float = hotbar_panel.get_combined_minimum_size().x
	if panel_w < 8.0:
		panel_w = hotbar_panel.size.x
	if panel_w < 8.0:
		return
	var wheel_cx: float = wheel_view.get_global_rect().get_center().x
	var local_cx: float = wheel_cx - hotbar_wrap.global_position.x
	var left_m: float = clampf(local_cx - panel_w * 0.5, 0.0, maxf(0.0, parent_w - panel_w))
	var right_m: float = maxf(0.0, parent_w - panel_w - left_m)
	var next_l: int = int(round(left_m))
	var next_r: int = int(round(right_m))
	if hotbar_wrap.get_theme_constant("margin_left") == next_l and hotbar_wrap.get_theme_constant("margin_right") == next_r:
		return
	hotbar_wrap.add_theme_constant_override("margin_left", next_l)
	hotbar_wrap.add_theme_constant_override("margin_right", next_r)


func _sprout_kill() -> void:
	if _sprout_tw != null and is_instance_valid(_sprout_tw):
		_sprout_tw.kill()
	_sprout_tw = null


func _hub_set(flip: bool, sy: float, mod: Color, on: bool) -> void:
	if wheel_view == null:
		return
	# Parade overlay owns the hub hero; don't let fight enforcers re-show it.
	if wheel_view.hub_parade_hide:
		on = false
	wheel_view.hub_flip = flip
	wheel_view.hub_sy = sy
	wheel_view.hub_mod = mod
	wheel_view.hub_sprout_on = on
	wheel_view.queue_redraw()


func _sprout_begin_entrance() -> void:
	# Face-off retired (2026-10-26): no hub-exit / left run-on. Hub Sprout stays put.
	_sprout_stay_hub()


func _hub_darken(_t: float) -> void:
	pass


func _hub_fade_out(_a: float) -> void:
	pass


func _sprout_run_in() -> void:
	_sprout_stay_hub()


func _sprout_arrived() -> void:
	_sprout_stay_hub()


func _sprout_begin_exit() -> void:
	# Spin no longer walks Sprout off left — hub idle continues through the spin.
	_sprout_stay_hub()


func _sprout_hub_back() -> void:
	_sprout_stay_hub()


func _hub_from_black(_t: float) -> void:
	pass


func _sprout_hub_idle() -> void:
	_sprout_stay_hub()


func _sprout_snap() -> void:
	_sprout_stay_hub()


func _sprout_stay_hub() -> void:
	_sprout_kill()
	_sprout_mode = "hub"
	if player_stage != null:
		player_stage.traveling = false
		player_stage.face_left = false
		player_stage.modulate = Color.WHITE
		player_stage.hide_stage()
	_hub_set(false, 1.0, Color.WHITE, true)


func qa_pose_sprout(step: int) -> void:
	# Face-off poses retired. Hub idle / combat frames only.
	_sprout_stay_hub()
	if wheel_view == null:
		return
	match step:
		0, 1, 4:
			wheel_view.play_hero("idle", 1, true)
		2, 3:
			wheel_view.play_hero("grab", 1, true)
		_:
			wheel_view.play_hero("swipe", 1, true)


## Staging QA: seat monsters, fill the item bar, face one id, optional log panel.
func qa_staging_fight(monsters: Array, face_id: String, items: Array, log_open: bool = false) -> String:
	if playtest_intro != null:
		playtest_intro.close_intro()
	_mark_playtest_intro_seen()
	if playtest_hub != null:
		playtest_hub.close_hub()
	_close_playtest_teaser()
	if playtest_intro != null:
		playtest_intro.close_intro()
	_mark_playtest_intro_seen()
	if playtest_feedback != null and playtest_feedback.has_method("force_close"):
		playtest_feedback.force_close()
	if home_cabin != null:
		home_cabin.visible = false
	if overlay != null:
		overlay.visible = false
	if play_field != null:
		play_field.visible = true
	adventure = false
	in_tutorial = false
	wheel.clear()
	for mid in monsters:
		var id := str(mid)
		if monsters_by_id.has(id):
			wheel.append(_make_monster(id))
	if wheel.is_empty():
		return "no_monsters"
	hotbar.clear()
	for iid in items:
		var item_id := str(iid)
		if items_by_id.has(item_id):
			hotbar.append(_make_item(item_id))
	_hotbar_sig = ""
	var face := 0
	for i in wheel.size():
		if str(wheel[i].get("card_id", "")) == face_id:
			face = i
			break
	facing_index = face
	phase = "fighting"
	hp = 6
	blk = 2
	_sprout_stay_hub()
	_sync_wheel_stats()
	_show_fight_portrait()
	_refresh_face()
	_refresh()
	_layout_play_field()
	_log_open = log_open
	if log_btn != null:
		log_btn.visible = true
		log_btn.text = "Hide log" if log_open else "Log"
	_place_log_overlay()
	if log_label != null:
		log_label.visible = log_open
	_sprout_stay_hub()
	if wheel_view != null and wheel_view.has_method("play_hero"):
		wheel_view.hub_hp = hp
		wheel_view.hub_hp_max = HP_MAX
		wheel_view.play_hero("idle", 1, true)
	_sync_playtest_chrome()
	return "ok face=%s seats=%d items=%d" % [face_id, wheel.size(), hotbar.size()]


## Mid-spin pose: hub Sprout stays on (no left-stage return fade).
func qa_staging_spin_return() -> String:
	qa_staging_fight(["dire_wolf", "goblin", "ogre", "bandit"], "dire_wolf", ["spiked_flail", "bag_of_marbles"], false)
	_sprout_stay_hub()
	phase = "spinning"
	_fight_art_sig = ""
	if wheel_view != null:
		wheel_view.queue_redraw()
	_refresh()
	return "spin_return"


## Wheel is mid-spin. Portrait/gutter layout can wait; spin paints itself.
func _spin_holds_fight_art() -> bool:
	if phase == "spinning":
		return true
	if wheel_view != null and bool(wheel_view.spinning):
		return true
	return false


## Mark gutter layout dirty and schedule one deferred flush (idle), not a poll.
func _mark_fight_art_dirty() -> void:
	_fight_art_dirty = true
	_queue_fight_art_flush()


func _queue_fight_art_flush() -> void:
	if _fight_art_flush_queued:
		return
	_fight_art_flush_queued = true
	call_deferred("_flush_fight_art")


## Retry after the next process tick. Do NOT use call_deferred here: deferred
## callbacks drain in the same MessageQueue flush while get_process_frames() is
## unchanged, so same-frame early-out → mark dirty → deferred flush loops until
## segfault (Mac F5 boot after #136).
func _queue_fight_art_flush_next_frame() -> void:
	if _fight_art_flush_queued:
		return
	_fight_art_flush_queued = true
	var tree := get_tree()
	if tree == null:
		_fight_art_flush_queued = false
		return
	tree.process_frame.connect(_flush_fight_art, CONNECT_ONE_SHOT)


## Runs once after dirty is set. Mid-spin: keep dirty and retry next process
## frame (not call_deferred — #137). Land/`_layout_play_field` may still force.
func _flush_fight_art() -> void:
	_fight_art_flush_queued = false
	if not _fight_art_dirty:
		return
	if _spin_holds_fight_art():
		# Dirty stays set; do not drop the retry or land waits on a sync force.
		_queue_fight_art_flush_next_frame()
		return
	# Defense: a flush scheduled for this idle after a full place already ran
	# this process frame must wait for the next process tick — never re-enter
	# via call_deferred in the same MessageQueue drain.
	if Engine.get_process_frames() == _fight_art_frame:
		_queue_fight_art_flush_next_frame()
		return
	_place_fight_art(false)


## Lay out fight portrait / callout / slash park beside the wheel.
## Pass force=true for structural layout (resize) or an explicit seat reveal.
## During spin, ALL full work is deferred (force included) — #132 only skipped
## non-force, so `_layout_play_field` / resized still paid full gutter math and
## cascaded (spin_x5 spike d_place up to 24). Seat reveal runs after land.
## Not called from `_process` — dirty/deferred + structural callers only.
func _place_fight_art(force: bool = false) -> void:
	var _place_t0 := Time.get_ticks_usec()
	if wheel_view == null:
		FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, true)
		return
	# Spin path: defer every full layout, including force from resized/layout.
	if _spin_holds_fight_art():
		_fight_art_sig = ""
		_mark_fight_art_dirty()
		FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, true)
		return
	# One full place per process frame — play_field.resized → layout → place loops.
	var frame_i: int = Engine.get_process_frames()
	if frame_i == _fight_art_frame:
		if force or _fight_art_dirty:
			# Keep dirty + retry next process frame. call_deferred would re-enter
			# the same MessageQueue flush and ping-pong forever (F5 signal 11).
			_fight_art_dirty = true
			_queue_fight_art_flush_next_frame()
		FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, true)
		return
	if force or _fight_art_dirty:
		# Consume dirty. Do not blank `_fight_art_sig` here — unchanged wheel /
		# viewport / phase still early-out. Spin start and spin-hold clear sig
		# so land always pays one full place.
		_fight_art_dirty = false
	elif not force:
		# Non-force with no dirty: nothing structural asked for a place.
		FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, true)
		return
	if player_stage != null and player_stage.visible:
		player_stage.hide_stage()
	# Enforce hub Sprout before the geometry sig — mutating hub_sprout_on after
	# recording the sig made the next place (same land) pay a second full layout.
	if (phase == "fighting" or phase == "slaying") and facing_index >= 0 and not wheel_view.hub_sprout_on:
		_hub_set(false, 1.0, Color.WHITE, true)
	var wr_now: Rect2 = wheel_view.get_global_rect()
	var log_r := Rect2()
	if log_label != null and log_label.visible:
		log_r = log_label.get_global_rect()
	# Omit combat_stage.busy: lunge/attack toggles it, but the busy branch skips
	# size/pos work — keeping it in sig forced full gutter math every swing.
	# Plate rev replaces blanking `_fight_art_sig` on every `_refresh_face`.
	var sig := "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s" % [
		phase,
		facing_index,
		wr_now,
		get_viewport_rect().size,
		_choice_covering(),
		combat_stage != null and combat_stage.visible,
		face_box != null and face_box.visible,
		hypno_stage != null and hypno_stage.visible,
		log_r,
		hp,
		wheel_view.hub_sprout_on if wheel_view else true,
		_face_plate_rev,
	]
	if sig == _fight_art_sig:
		FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, true)
		return
	_fight_art_sig = sig
	_fight_art_frame = frame_i
	if _choice_covering():
		if face_box:
			face_box.hide_plate()
		if combat_stage and combat_stage.visible and not combat_stage.busy:
			combat_stage.hide_stage()
		if player_stage:
			player_stage.hide_stage()
	elif player_stage:
		player_stage.hide_stage()
	var wr: Rect2 = wr_now
	var stack_w := 280.0
	var log_left: float = get_viewport_rect().size.x - 8.0
	if log_label != null and log_label.visible and log_r.size.x > 0.0:
		log_left = minf(log_left, log_r.position.x - 8.0)
	stack_w = minf(stack_w, maxf(140.0, log_left - (wr.end.x + 16.0)))
	var sprite_h := 216.0
	var port_sz := Vector2(stack_w, sprite_h)
	# The portrait frame sits fully above the inspect plate. The body is scaled to that frame.
	var overlap := 0.0
	var plaque_h := 0.0
	if face_box != null and face_box.visible:
		# reset_size / min-size are Control thrash — only remeasure when the
		# plate content revision changed (show_rule / hide in `_refresh_face`).
		# `_refresh_face` warms this cache after show_rule so land skips a second measure.
		if _fight_art_plaque_rev != _face_plate_rev or _fight_art_plaque_h <= 0.0:
			face_box.reset_size()
			_fight_art_plaque_h = face_box.get_combined_minimum_size().y
			_fight_art_plaque_rev = _face_plate_rev
		plaque_h = _fight_art_plaque_h
	var room_h: float = maxf(96.0, wr.size.y - 24.0)
	if plaque_h + 96.0 > room_h:
		sprite_h = 96.0
	else:
		sprite_h = minf(sprite_h, room_h - plaque_h - 8.0)
	sprite_h = maxf(96.0, floor(sprite_h))
	port_sz = Vector2(stack_w, sprite_h)
	var hang: float = 0.0
	var show_portrait: bool = (phase == "fighting" or phase == "slaying") and facing_index >= 0 and not _choice_covering()
	if show_portrait or (combat_stage != null and combat_stage.visible):
		hang = maxf(0.0, port_sz.y - overlap)
	var total: float = hang + plaque_h
	var gap_side := 16.0
	var speech_room := 156.0
	var y: float = wr.end.y - total - 18.0
	y = maxf(y, wr.position.y + speech_room)
	if y + total > wr.end.y + 8.0:
		y = wr.position.y + maxf(8.0, wr.size.y - total)
	var stack_sz := Vector2(stack_w, maxf(total, 8.0))
	var prefer := Vector2(wr.end.x + gap_side, y)
	var flip := Vector2(wr.position.x - gap_side - stack_w, y)
	var blocks: Array = _log_block_rects()
	if wheel_view.has_method("slice_avoid_global") and facing_index >= 0:
		blocks.append(wheel_view.slice_avoid_global(facing_index))
	var stack_pos: Vector2 = preload("res://scripts/ui/tooltip_clamp.gd").place(get_viewport_rect().size, stack_sz, [prefer, flip, Vector2(prefer.x, wr.position.y), Vector2(flip.x, wr.position.y)], blocks)
	var on_left: bool = stack_pos.x < wr.get_center().x
	var right_x: float = stack_pos.x
	var left_x: float = wr.end.x + gap_side if on_left else wr.position.x - gap_side - stack_w
	var port_y: float = stack_pos.y
	y = stack_pos.y
	# Prefer the right gutter for monster idle + callout. Hub Sprout owns the center.
	if combat_stage != null and combat_stage.visible and (hypno_stage == null or not hypno_stage.visible):
		if on_left:
			right_x = prefer.x
			left_x = flip.x
			on_left = false
	if face_box != null and face_box.visible:
		face_box.size = Vector2(stack_w, plaque_h)
		face_box.global_position = Vector2(right_x, y + hang)
	if combat_stage != null and combat_stage.visible:
		if not combat_stage.busy:
			var view_sz: Vector2 = get_viewport_rect().size
			var stage_pos := Vector2(VIEW_FRAME.clamp_x(right_x, port_sz.x, view_sz), y)
			var stage_moved: bool = (
				combat_stage.size != port_sz
				or combat_stage.global_position != stage_pos
				or _fight_art_stage_sz != port_sz
				or _fight_art_stage_pos != stage_pos
			)
			if stage_moved:
				combat_stage.size = port_sz
				combat_stage.custom_minimum_size = port_sz
				combat_stage.global_position = stage_pos
				_fight_art_stage_sz = port_sz
				_fight_art_stage_pos = stage_pos
				if combat_stage.has_method("_place_sprite"):
					combat_stage._place_sprite()
			if face_box != null and face_box.visible:
				face_box.global_position = Vector2(right_x, y + port_sz.y + 12.0)
		if player_stage != null:
			player_stage.hide_stage()
	if hypno_stage != null and hypno_stage.visible:
		hypno_stage.size = port_sz
		hypno_stage.global_position = Vector2(left_x + (stack_w - port_sz.x) * 0.5, port_y)
		if hypno_box != null and hypno_box.visible:
			hypno_box.reset_size()
			var hsz: Vector2 = hypno_box.get_combined_minimum_size()
			hsz.x = stack_w
			hypno_box.size = hsz
			hypno_box.global_position = Vector2(left_x, port_y + port_sz.y + 8.0)
	if ability_slash != null and not ability_slash.visible:
		# Park gutter rect for item banners; monster cut-ins set full 1680×1040 in _show.
		if ability_slash.has_method("park_gutter"):
			ability_slash.park_gutter(Vector2(stack_w, port_sz.y + 72.0), Vector2(left_x, port_y))
		else:
			ability_slash.size = Vector2(stack_w, port_sz.y + 72.0)
			ability_slash.global_position = Vector2(left_x, port_y)
	if intent_plate != null and intent_plate.has_method("reanchor"):
		intent_plate.reanchor()
	FRAME_METRICS.note_place(Time.get_ticks_usec() - _place_t0, false)


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


func _sync_intent_plate() -> void:
	if intent_plate == null:
		return
	if intent_plate.visible:
		intent_plate.clear()
	var preview_on: bool = phase == "fighting" and facing_index >= 0 and _incoming_hit() > 0
	if wheel_view:
		wheel_view.hurt_preview = preview_on
		wheel_view.queue_redraw()
	if _hover_ghost_on:
		return
	if phase == "fighting" and facing_index >= 0:
		return
	# Resolve sets phase to slaying before _owner_attack -> fire(). Keep the
	# badges up so lit/spent/blocked can play; _play_ended/_play_leave clear.
	if phase == "slaying":
		return
	intent_plate.clear()


## One entry per incoming hit. n_raw is before Block. soaked = Block spends on that hit.
func _intent_hits() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if skip_swing_this_fight or facing_index < 0 or facing_index >= wheel.size():
		return out
	var m: Dictionary = wheel[facing_index]
	var face_id: String = str(m.get("card_id", ""))
	if face_id == "two_headed_serpent" and not _is_silenced(m):
		var left_blk: int = blk
		var buckler_ok: bool = true
		for j in _damsel_neighbors(facing_index):
			var nm: Dictionary = wheel[j]
			for _h in range(_hit_count(j)):
				var swing: Dictionary = _preview_swing(nm, left_blk, buckler_ok)
				var n_raw: int = int(nm.get("atk", 0))
				if bool(swing.get("used_buckler", false)):
					n_raw = int(n_raw / 2)
					buckler_ok = false
				var dmg: int = int(swing["dmg"])
				var pierce: bool = bool(swing.get("pierce", false))
				out.append({
					"n_raw": n_raw,
					"soaked": (not pierce) and dmg < n_raw,
					"pierce": pierce,
					"src_index": j,
					"poison": false,
					"loop": false,
					"chip": "",
				})
				left_blk = int(swing["blk"])
		return out
	if _blood_threshes(facing_index):
		# Shark: first swing's raw hit, then a loop chip (↻).
		var zeros: int = 0
		var probe_left: int = blk
		var probe_buck: bool = true
		var chosen: Dictionary = {}
		var chosen_raw: int = int(m.get("atk", 0))
		while zeros < 5:
			var sw: Dictionary = _preview_swing(m, probe_left, probe_buck)
			var raw: int = int(m.get("atk", 0))
			if bool(sw.get("used_buckler", false)):
				raw = int(raw / 2)
				probe_buck = false
			if chosen.is_empty() or int(sw["dmg"]) > 0:
				chosen = sw
				chosen_raw = raw
			if int(sw["dmg"]) > 0:
				break
			probe_left = int(sw["blk"])
			zeros += 1
		if chosen.is_empty():
			chosen = _preview_swing(m, blk, true)
			chosen_raw = int(m.get("atk", 0))
		out.append({
			"n_raw": chosen_raw,
			"soaked": (not bool(chosen.get("pierce", false))) and int(chosen["dmg"]) < chosen_raw,
			"pierce": bool(chosen.get("pierce", false)),
			"src_index": facing_index,
			"poison": false,
			"loop": false,
			"chip": "",
		})
		out.append({"n_raw": 0, "soaked": false, "pierce": false, "src_index": facing_index, "poison": false, "loop": true, "chip": ""})
		return out
	var left3: int = blk
	var buckler_ok3: bool = true
	for _h3 in range(_hit_count(facing_index)):
		var swing3: Dictionary = _preview_swing(m, left3, buckler_ok3)
		var n_raw3: int = int(m.get("atk", 0))
		if bool(swing3.get("used_buckler", false)):
			n_raw3 = int(n_raw3 / 2)
			buckler_ok3 = false
		var dmg3: int = int(swing3["dmg"])
		var pierce3: bool = bool(swing3.get("pierce", false))
		out.append({
			"n_raw": n_raw3,
			"soaked": (not pierce3) and dmg3 < n_raw3,
			"pierce": pierce3,
			"src_index": facing_index,
			"poison": false,
			"loop": false,
			"chip": "",
		})
		left3 = int(swing3["blk"])
	return out


func _punch_hero(b: Button, on: bool) -> void:
	if b == null:
		return
	b.pivot_offset = b.size * 0.5
	var tw := b.create_tween()
	tw.tween_property(b, "scale", Vector2(1.14, 1.14) if on else Vector2.ONE, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_done_hover(on: bool) -> void:
	_punch_hero(btn_done, on and phase == "fighting")
	if not on or phase != "fighting":
		_ghost_hp = -1
		_refresh_hearts()
		return
	if sfx:
		sfx.hover()
	_ghost_hp = maxi(0, hp - _incoming_hit())
	_refresh_hearts()


func _on_done_press(down: bool) -> void:
	if btn_done == null:
		return
	btn_done.pivot_offset = btn_done.size * 0.5
	var tw := btn_done.create_tween()
	tw.tween_property(btn_done, "scale", Vector2(0.9, 0.9) if down else Vector2.ONE, 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _refresh_hearts() -> void:
	if wheel_view:
		wheel_view.hub_poison = player_poison
		wheel_view.set_vitals(hp, HP_MAX, _ghost_hp, blk, _ghost_blk)
		if wheel_view.has_method("set_moves"):
			wheel_view.set_moves(moves_left, ADVENTURE_MOVES if _is_adventure_mode() else 0)
		if wheel_view.has_method("set_hub_pierce"):
			wheel_view.set_hub_pierce(_hand_pierce() and phase == "fighting")
	if hearts_box:
		hearts_box.visible = false
	if hearts_box == null:
		return
	var poison_from: int = maxi(0, hp - player_poison) if player_poison > 0 else -1
	var hi: int = 0
	for child in hearts_box.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		var live: bool = hi < hp
		var lost_soon: bool = _ghost_hp >= 0 and hi >= _ghost_hp and hi < hp
		var poison_soon: bool = poison_from >= 0 and hi >= poison_from and hi < hp
		if live:
			if lost_soon:
				tr.modulate = Color("e07a7a")
			elif poison_soon:
				tr.modulate = Color("6ebd6e")
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


func _shake_screen() -> void:
	if not _shaking:
		_shake_base = position
		_shaking = true
	if _screen_shake:
		_screen_shake.kill()
	var base: Vector2 = _shake_base
	position = base
	_screen_shake = create_tween()
	_screen_shake.tween_property(self, "position", base + Vector2(8, 2), 0.028)
	_screen_shake.tween_property(self, "position", base + Vector2(-7, -3), 0.028)
	_screen_shake.tween_property(self, "position", base + Vector2(5, 2), 0.028)
	_screen_shake.tween_property(self, "position", base, 0.04)
	_screen_shake.finished.connect(func() -> void:
		position = base
		_shaking = false
	, CONNECT_ONE_SHOT)


func _flash_screen(col: Color, a: float = 0.3) -> void:
	if fx_flash == null:
		return
	fx_flash.color = col
	fx_flash.modulate.a = a
	var tw := create_tween()
	tw.tween_property(fx_flash, "modulate:a", 0.0, 0.32)


func _number_is_atk(view: Dictionary, petrify_n: int) -> bool:
	if petrify_n > 0:
		return false
	if str(view.get("kind", "")) != "ATK":
		return false
	var num: String = str(view.get("number", "")).strip_edges()
	if num == "" or num == "—" or num == "-":
		return false
	return true


func _num_color(kind: String) -> Color:
	if kind == "BLK":
		return Color("6bb3d9")
	if kind == "ATK":
		return Color("e06c75")
	if kind == "HEAL" or kind == "HP":
		return Color("8fd18f") if kind == "HEAL" else Color("e8a0a0")
	if kind == "DEFEAT" or kind == "FANGS" or kind == "BAG":
		return Color("f0e6d8")
	if kind == "SKIP":
		return Color("e8c36a")
	return Color("f0e6d8")


func _kind_mark(kind: String) -> Texture2D:
	if kind == "ATK" and tex_atk != null:
		return tex_atk
	if kind == "BLK":
		return tex_shield
	if kind == "HEAL" or kind == "HP":
		return tex_heart
	if kind == "DEFEAT" or kind == "FANGS":
		if art != null and art.tile("skull") != null:
			return art.tile("skull")
		return tex_by_monster.get("skeleton", tex_heart)
	if kind == "BAG":
		return tex_heart
	if art != null and art.vfx.get("star", null) != null:
		return art.vfx["star"]
	return tex_sword


func _sync_hotbar_formulas() -> void:
	for c in _hotbar_all_cards():
		if not c.has_method("show_formula"):
			continue
		var it: Dictionary = _find_item(int(c.uid))
		if it.is_empty() and _challenge_loot_wait and not _challenge_pending_gain.is_empty() and int(c.uid) == int(_challenge_pending_gain.get("uid", -1)):
			it = _challenge_pending_gain
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
	if in_tutorial and _tut_show_deck and phase != "title" and phase != "victory" and phase != "defeat" and phase != "rest":
		return 176.0
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
		hearts_box.visible = false
	if tray != null and tray.visible:
		var tmin: Vector2 = tray.get_combined_minimum_size()
		tray.position = Vector2((sz.x - tmin.x) * 0.5, 6.0)
		tray.size = tmin
	var extra: float = _wheel_side_gutter()
	var top_need: float = trophy_h + 8.0
	if tray != null and tray.visible:
		top_need = maxf(top_need, tray.position.y + tray.size.y + 8.0)
	var side: float = minf(sz.x - extra, maxf(120.0, sz.y - top_need - 8.0))
	var x: float = (sz.x - side - extra) * 0.5
	var wheel_y: float = maxf(top_need, (sz.y - side) * 0.5)
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
		var show_deck: bool = (adventure or (in_tutorial and _tut_show_deck)) and phase != "title" and phase != "victory" and phase != "defeat" and phase != "rest"
		dungeon_deck_ui.visible = show_deck
		dungeon_deck_ui.size = Vector2(148, 168)
		dungeon_deck_ui.position = Vector2(x + side + 8.0, wheel_y)
		if not dungeon_deck_ui.is_busy():
			dungeon_deck_ui.set_count(challenge_deck.size())
		_sync_challenge_peek()
	if challenge_draft_ui != null and challenge_draft_ui.visible:
		challenge_draft_ui.scale = Vector2.ONE
		challenge_draft_ui.reset_size()
		var dmin: Vector2 = challenge_draft_ui.get_combined_minimum_size()
		var w: float = maxf(508.0, dmin.x)
		var h: float = dmin.y
		var deck_bottom: float = wheel_y
		if dungeon_deck_ui != null and dungeon_deck_ui.visible:
			deck_bottom = dungeon_deck_ui.position.y + dungeon_deck_ui.size.y + 24.0
		var room: float = maxf(96.0, sz.y - 8.0 - deck_bottom)
		var sc: float = 1.0
		if h > room:
			sc = clampf(room / h, 0.62, 1.0)
		challenge_draft_ui.size = Vector2(w, h)
		challenge_draft_ui.pivot_offset = Vector2.ZERO
		challenge_draft_ui.scale = Vector2(sc, sc)
		challenge_draft_ui.position = Vector2(x + side + 16.0, deck_bottom)
	if cue_label:
		cue_label.position = Vector2(12.0, minf(wheel_y + side + 4.0, sz.y - 36.0))
		cue_label.size = Vector2(maxf(sz.x - 24.0, 180.0), 36.0)
	if ability_slash:
		ability_slash.wheel_center = wheel_view.global_position + wheel_view.size * 0.5
	_sync_move_ui()
	_place_log_overlay()
	_recenter_hotbar()
	# Structural layout. Mid-spin this only dirties — full place waits for land.
	_place_fight_art(true)
	if wheel_view and wheel_view.has_method("set_ability_avoids"):
		wheel_view.set_ability_avoids(_ability_avoid_rects())
	_place_hub_cue()


func _set_cue(_t: String) -> void:
	if cue_label == null:
		return
	_cue_shown = ""
	cue_label.text = ""
	cue_label.visible = false


func _choice_covering() -> bool:
	return challenge_draft_ui != null and challenge_draft_ui.visible


func _refresh_face() -> void:
	if face_box == null:
		return
	var show_plate: bool = (phase == "fighting" or phase == "slaying") and facing_index >= 0 and facing_index < wheel.size() and not _choice_covering()
	if not show_plate:
		if face_box.visible:
			_face_plate_rev += 1
			_face_plate_content_sig = ""
			_fight_art_plaque_rev = -1
			_fight_art_plaque_h = 0.0
		face_box.hide_plate()
		var keep_anim: bool = combat_stage != null and combat_stage.busy and not _choice_covering()
		if combat_stage and not keep_anim and (phase != "slaying" and phase != "fighting" or facing_index < 0 or _choice_covering()):
			combat_stage.hide_stage()
			if player_stage:
				player_stage.hide_stage()
		if phase != "slaying" and phase != "fighting":
			_hide_hypno()
		_refresh_hypno_box()
		# Coalesce gutter place — do not sync-force (land was paying 2× full place).
		_mark_fight_art_dirty()
		return
	if combat_stage and not combat_stage.visible and not combat_stage.busy:
		_show_fight_portrait()
	var m: Dictionary = wheel[_fight_portrait_index()]
	var rule: Dictionary = _monster_rule(m)
	var face_look: Dictionary = _monster_plate_look(m, rule)
	face_look["stage_card"] = true
	face_look["slice"] = m
	face_look["stage_pad"] = _fight_sprite_pad()
	var title_s: String = str(rule["title"])
	var value_s: String = str(rule["value"])
	var eq_s: String = str(rule["equation"])
	var speech_s: String = str(rule.get("speech", ""))
	var warn_s: String = str(rule.get("warn", ""))
	var card_s: String = str(m.get("card_id", ""))
	var atk_s: String = str(m.get("atk", 0))
	var hp_s: String = str(m.get("hp", 0))
	var content_sig := "%s|%s|%s|%s|%s|%s|%s|%s|%s" % [
		card_s, title_s, value_s, eq_s, speech_s, warn_s, atk_s, hp_s, str(face_look.get("call_chip", "")),
	]
	var plate_changed: bool = content_sig != _face_plate_content_sig
	face_box.show_rule(title_s, value_s, eq_s, speech_s, warn_s, null, "monster", card_s, face_look)
	if plate_changed:
		_face_plate_content_sig = content_sig
		_face_plate_rev += 1
		# show_rule already reset_size — warm plaque cache so full place skips remeasure.
		_fight_art_plaque_h = maxf(face_box.get_combined_minimum_size().y, face_box.size.y)
		_fight_art_plaque_rev = _face_plate_rev
	if (atk_s != _face_atk_shown and _face_atk_shown != "") or (hp_s != _face_hp_shown and _face_hp_shown != ""):
		face_box.pivot_offset = face_box.size * 0.5
		var tw := create_tween()
		tw.tween_property(face_box, "scale", Vector2(1.06, 1.06), 0.08)
		tw.tween_property(face_box, "scale", Vector2.ONE, 0.12)
	_face_atk_shown = atk_s
	_face_hp_shown = hp_s
	_refresh_hypno_box()
	# Seat / plate reveal after spin: dirty + deferred flush (idle, before draw).
	# Sync `_place_fight_art(true)` here stacked with land's second `_refresh` and
	# cleared the gutter sig, so Mac spin_x5 paid two ~77 ms full places (~154 ms).
	_mark_fight_art_dirty()
	# Keep hub Sprout visible during fights (no left face-off entrance).
	if _sprout_mode != "hub" or (wheel_view != null and not wheel_view.hub_sprout_on):
		_sprout_stay_hub()


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
	var nid: String = _deck_card_id(challenge_deck[0])
	var nm: String = str(monsters_by_id.get(nid, {}).get("name", nid))
	var tex: Texture2D = null
	if art != null:
		tex = art.monster_still(nid)
	if str(_peek_slice.get("card_id", "")) != nid:
		if monsters_by_id.has(nid):
			_peek_slice = _make_monster(nid)
			_stamp_pack(_peek_slice, _pack_tier_for(nid, monsters_by_id, int(monsters_by_id.get(nid, {}).get("tier", 1))), "draft")
		else:
			_peek_slice = {}
	elif not _peek_slice.is_empty():
		_apply_formulas_to(_peek_slice)
	dungeon_deck_ui.set_peek(tex, nm, 0 if _peek_slice.is_empty() else _tier_of(_peek_slice))
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
	_on_monster_right_click(str(_peek_slice.get("card_id", "")))


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


func _triclops_seats() -> Array[int]:
	var n: int = hotbar.size()
	if n != 3 and n != 6 and n != 9:
		return []
	var out: Array[int] = []
	for i in wheel.size():
		var s: Dictionary = wheel[i]
		if str(s.get("kind", "")) != "monster":
			continue
		if str(s.get("card_id", "")) != "three_seeker":
			continue
		if int(s.get("hp", 0)) <= 0:
			continue
		if _is_silenced(s):
			continue
		out.append(i)
	return out


func _sync_triclops_glow() -> void:
	if wheel_view == null:
		return
	var seats: Array[int] = []
	if phase == "ready":
		seats = _triclops_seats()
	wheel_view.threat_indices = seats


func _triclops_sorry(index: int) -> void:
	if speech_box and wheel_view:
		speech_box.present(wheel_view.slice_portrait_global(index), "Sorry, this fight is mine now")
	if sfx:
		sfx.play("bong", -8.0, 0.9)
	if get_tree():
		await get_tree().create_timer(0.7).timeout


func _refresh() -> void:
	_sync_log_panel()
	_sync_wheel_stats()
	_sync_triclops_glow()
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
			if mk == "hypnotize":
				wheel[i]["across"] = _across_index(i)
			else:
				wheel[i]["across"] = -1
		## Keep neighbor aim ghosts on while picking (never the facing kill ghost).
		if mk == "atk_neighbor" or mk == "mark_crossbow" or mk == "mark_poison" or mk == "hook_swap" or mk == "polymorph" or mk == "signpost" or mk == "sling_any":
			_apply_preview(_preview_mark_aim(mk, _hover_slice))
	else:
		for i2 in wheel.size():
			wheel[i2]["markable"] = false
			wheel[i2]["across"] = -1
		if (phase == "draft" and draft_action == "seat") or phase == "devtest":
			mode = "place"
	_trapper_mark_newcomers()
	if wheel_view:
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, facing_index, mode)
		wheel_view.draft_glow = phase == "draft"
		wheel_view.closed_empties = in_tutorial and PlaytestUx.closed_empty_in_tutorial() and mode != "place"
		wheel_view.modulate = Color(0.42, 0.40, 0.38, 1.0) if _toss_pick_mode() else Color.WHITE
	_sync_loot_pips()
	if tut != null and tut.has_method("set_lift"):
		var slash_up: bool = ability_slash != null and ability_slash.visible
		tut.set_lift(in_tutorial and tut.visible and (_walker_busy or slash_up))

	_set_cue(_cue_text())
	_sync_hub_cue()
	_rebuild_tray()
	_sync_hotbar()
	_rebuild_choice()
	_sync_buttons()
	_sync_overlay()
	_sync_dev_panel()
	_beggar_drop_invalid_owners()
	_kick_beggar_intro()
	_kick_beggar_fill()
	if adventure:
		call_deferred("_layout_play_field")


func _cue_text() -> String:
	if not pending_feed.is_empty() and _cube_line != "":
		return _cube_line
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
			if _await_first_spin:
				return ""
			if _is_adventure_mode():
				return ""
			return PLAYER_COPY.text("cue.ready", "Spin — the nest turns.")
		"fighting":
			if not pending_feed.is_empty():
				if _cube_line != "":
					return _cube_line
				if str(pending_feed.get("kind", "")) == "upgrade":
					return "Pick an item. I will upgrade it."
				return "Feed the cube one of those items."
			if not pending_chaos.is_empty():
				var need_n: int = int(pending_chaos.get("need", 1))
				if need_n <= 1:
					return "Click the other item to reroll it."
				return "Click two other items to reroll them."
			if not pending_mark.is_empty():
				if str(pending_mark.get("kind", "")) == "hypnotize" or str(pending_mark.get("kind", "")) == "defeat_double_hp" or str(pending_mark.get("kind", "")) == "sling_any":
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


func _atk_variant(index: int) -> Dictionary:
	if _blood_threshes(index) or _self_deconstructs(index):
		return {"kind": "loop", "n": 1}
	var n: int = _hit_count(index)
	if n >= 2:
		return {"kind": "double", "n": n}
	return {"kind": "single", "n": n}


func _take_variant() -> Dictionary:
	var v := _atk_variant(facing_index)
	if facing_index < 0 or facing_index >= wheel.size():
		return v
	var m: Dictionary = wheel[facing_index]
	if str(m.get("card_id", "")) == "two_headed_serpent" and not _is_silenced(m):
		var sn: int = _intent_hits().size()
		v = {"kind": "double" if sn >= 2 else "single", "n": sn}
	return v


func _atk_front_px(kind: String, s: int) -> Vector2:
	var off: int = int(float(s) / 3.0)
	var dy: int = int(float(off) / 2.0)
	if kind == "triple":
		return Vector2(float(s) * 0.5, float(s) * 0.5 + float(dy * 2))
	if kind == "double":
		return Vector2(float(s) * 0.5, float(s) * 0.5 + float(dy))
	return Vector2(float(s) * 0.5, float(s) * 0.5)


func _stamp_atk_variants() -> void:
	for i in wheel.size():
		var v := _atk_variant(i)
		wheel[i]["atk_kind"] = str(v.get("kind", "single"))
		wheel[i]["atk_n"] = int(v.get("n", 1))
	if wheel_view:
		wheel_view.queue_redraw()


func _ensure_take_burst() -> TakeBurst:
	if _take_burst != null and is_instance_valid(_take_burst):
		return _take_burst as TakeBurst
	var burst := TakeBurst.new()
	burst.name = "TakeBurst"
	burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burst.clip_contents = false
	burst.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	burst.z_index = 2
	burst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_done.clip_contents = false
	btn_done.add_child(burst)
	_take_burst = burst
	return burst


func _capture_take_styles() -> void:
	if _take_style_ready or btn_done == null:
		return
	for state in ["normal", "hover", "pressed", "focus"]:
		_take_style_had[state] = btn_done.has_theme_stylebox_override(state)
		var live: StyleBox = btn_done.get_theme_stylebox(state)
		if live != null:
			_take_style_base[state] = live.duplicate()
	_take_style_ready = true


func _apply_take_margins(icon_w: float) -> void:
	_capture_take_styles()
	for state in ["normal", "hover", "pressed", "focus"]:
		var base: StyleBox = _take_style_base.get(state, null)
		if base == null:
			continue
		var dup: StyleBox = base.duplicate()
		dup.content_margin_right = dup.content_margin_left + 8.0 + icon_w
		btn_done.add_theme_stylebox_override(state, dup)


func _hide_take_burst() -> void:
	if _take_burst != null and is_instance_valid(_take_burst):
		_take_burst.visible = false
	if not _take_style_ready or btn_done == null:
		return
	for state in ["normal", "hover", "pressed", "focus"]:
		if bool(_take_style_had.get(state, false)):
			var orig: StyleBox = _take_style_base.get(state, null)
			if orig != null:
				btn_done.add_theme_stylebox_override(state, orig.duplicate())
		else:
			btn_done.remove_theme_stylebox_override(state)


func _show_take_burst(hit: int) -> void:
	var v := _take_variant()
	var kind: String = str(v.get("kind", "single"))
	var n: int = int(v.get("n", 1))
	var tex_kind := kind
	var pip := ""
	if kind != "loop" and n >= 3:
		tex_kind = "double"
		pip = "×%s" % n
	elif kind != "loop" and n >= 2:
		tex_kind = "double"
	elif kind != "loop":
		tex_kind = "single"
	var tex: Texture2D = _tex("res://assets/ui/icons/atk_burst_%s_s24_2x.png" % tex_kind)
	var burst := _ensure_take_burst()
	burst.visible = true
	burst.tex = tex
	burst.num_text = str(hit)
	burst.pip = pip
	burst.word = btn_done.text
	burst.front = _atk_front_px(tex_kind, 24) * 2.0
	burst.word_font = btn_done.get_theme_font("font")
	if burst.word_font == null:
		burst.word_font = ThemeDB.fallback_font
	if tex != null:
		_apply_take_margins(float(tex.get_width()))
	burst.queue_redraw()


class TakeBurst extends Control:
	var tex: Texture2D
	var num_text: String = ""
	var pip: String = ""
	var word: String = ""
	var front: Vector2 = Vector2.ZERO
	var word_font: Font

	func _draw() -> void:
		if tex == null:
			return
		var btn := get_parent() as Control
		var sz := size
		if btn != null:
			sz = btn.size
		var font: Font = word_font if word_font != null else ThemeDB.fallback_font
		var text_w := 0.0
		if font != null and word != "":
			text_w = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
		var icon_w := float(tex.get_width())
		var gap := 8.0
		var cx := sz.x * 0.5 - (text_w + gap + icon_w) * 0.5 + text_w + gap + front.x
		var cy := sz.y * 0.5
		var origin := Vector2(cx - front.x, cy - front.y)
		draw_texture(tex, origin, Color.WHITE)
		var num_font: Font = ThemeDB.fallback_font
		if num_font == null:
			num_font = font
		_draw_hit_num(num_font, Vector2(cx, cy), num_text)
		if pip != "" and font != null:
			UxStyle.draw_multi_tag(self, origin + Vector2(icon_w, 0.0), pip, font)

	func _draw_hit_num(font: Font, pos: Vector2, txt: String) -> void:
		if font == null or txt == "":
			return
		var fs := 22
		var tsz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var p := pos + Vector2(-tsz.x * 0.5, fs * 0.36)
		var ink := Color("100e0c")
		var col := Color("f0e6d8")
		for ox in [-2, 0, 2]:
			for oy in [-2, 0, 2]:
				if ox == 0 and oy == 0:
					continue
				draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
		draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _sync_buttons() -> void:
	var busy: bool = phase == "spinning" or phase == "slaying" or (phase == "draft" and draft_action == "busy") or _wheel_busy() or _adventure_busy
	var enemy_up: bool = phase == "fighting" and facing_index >= 0 and facing_index < wheel.size() and (int(wheel[facing_index].get("hp", 0)) > 0 or _wick_waiting(facing_index))
	btn_spin.disabled = busy or phase != "ready"
	if _beggar_pending_intro() or _beggar_intro_running:
		btn_spin.disabled = true
	if in_tutorial and tut != null and tut.wait != "spin" and tut.wait != "auto_spin":
		btn_spin.disabled = true
	var feed_kind: String = str(pending_feed.get("kind", "")) if not pending_feed.is_empty() else ""
	var feed_continue: bool = feed_kind == "worm_hunger" or feed_kind == "hired_bribe"
	btn_done.disabled = busy or not enemy_up or (not pending_feed.is_empty() and not feed_continue) or not pending_chaos.is_empty()
	btn_start.disabled = busy
	btn_place.visible = false
	btn_bribe.visible = false
	btn_spin.visible = phase == "ready" and (not adventure or _await_first_spin)
	btn_done.visible = enemy_up
	btn_spin.text = PLAYER_COPY.text("combat.spin", "Spin")
	btn_spin.icon = null
	btn_spin.custom_minimum_size = Vector2(260, 64)
	btn_spin.add_theme_font_size_override("font_size", 32)
	btn_spin.add_theme_color_override("font_color", Color("1c120c"))
	btn_spin.add_theme_color_override("font_hover_color", Color("100e0c"))
	btn_spin.add_theme_color_override("font_pressed_color", Color("4a0808"))
	btn_spin.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_spin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if btn_challenge_begin:
		btn_challenge_begin.visible = _is_long_drop() and phase == "draft" and draft_action == "challenge_begin"
		btn_challenge_begin.disabled = busy
	_sync_move_ui()
	if btn_undo:
		var undo_on: bool = _undo_in_scope() and (phase == "fighting" or phase == "ready" or phase == "slaying") and _undo_can_undo()
		btn_undo.visible = undo_on
		btn_undo.disabled = not undo_on
	if btn_redo:
		var redo_on: bool = _undo_in_scope() and (phase == "fighting" or phase == "ready" or phase == "slaying") and not busy and _undo_can_redo()
		btn_redo.visible = redo_on
		btn_redo.disabled = not redo_on
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
		var spin_ready: bool = tut != null and tut.wait == "spin" and phase == "ready" and not busy and facing_index < 0
		btn_spin.disabled = not spin_ready
		btn_spin.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_spin.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_spin.text = PLAYER_COPY.text("combat.spin", "Spin")
		btn_spin.icon = null
		btn_done.disabled = busy or not enemy_up or tut == null or (tut.wait != "done" and tut.wait != "choice")
	_hide_take_burst()
	if enemy_up:
		var hit: int = _incoming_hit()
		if hit > 0:
			var tmpl: String = PLAYER_COPY.text("combat.take_hit", "Take {n}")
			btn_done.text = tmpl.replace("{n}", "").strip_edges()
			btn_done.icon = null
			btn_done.custom_minimum_size = Vector2(260, 64)
			btn_done.add_theme_font_size_override("font_size", 32)
			btn_done.add_theme_color_override("font_color", Color("6a1212"))
			btn_done.add_theme_color_override("font_hover_color", Color("8a1818"))
			btn_done.add_theme_color_override("font_pressed_color", Color("4a0808"))
			btn_done.remove_theme_color_override("icon_normal_color")
			btn_done.remove_theme_color_override("icon_hover_color")
			_show_take_burst(hit)
		else:
			btn_done.text = PLAYER_COPY.text("combat.safe", "Safe")
			btn_done.icon = tex_shield
			btn_done.custom_minimum_size = Vector2(228, 56)
			btn_done.add_theme_font_size_override("font_size", 26)
			btn_done.add_theme_constant_override("icon_max_width", 28)
			btn_done.add_theme_color_override("font_color", Color("1c120c"))
			btn_done.add_theme_color_override("font_hover_color", Color("100e0c"))
			btn_done.remove_theme_color_override("icon_normal_color")
			btn_done.remove_theme_color_override("icon_hover_color")
		btn_done.scale = Vector2.ONE
		_sync_intent_plate()
	if btn_spin:
		btn_spin.scale = Vector2.ONE
	if feed_kind == "worm_hunger":
		btn_done.visible = true
		btn_done.disabled = busy
		btn_done.text = PLAYER_COPY.text("title.continue", "Continue")
		btn_done.icon = null
		_hide_take_burst()
	elif feed_kind == "hired_bribe":
		btn_done.visible = true
		btn_done.disabled = busy
		btn_done.text = "Decline"
		btn_done.icon = null
		_hide_take_burst()
	_stamp_atk_variants()


func _build_move_ui() -> void:
	move_box = Control.new()
	move_box.name = "MoveBox"
	move_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_box.z_index = 20
	move_box.visible = false
	add_child(move_box)
	move_count = Label.new()
	move_count.visible = false
	move_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_box.add_child(move_count)
	btn_move_left = MOVE_ARROW.new()
	btn_move_left.name = "MoveLeft"
	btn_move_left.pointing = -1
	btn_move_left.tooltip_text = PLAYER_COPY.text("combat.move_left", "◀ Move")
	btn_move_left.pressed.connect(_on_move_left)
	move_box.add_child(btn_move_left)
	btn_move_right = MOVE_ARROW.new()
	btn_move_right.name = "MoveRight"
	btn_move_right.pointing = 1
	btn_move_right.tooltip_text = PLAYER_COPY.text("combat.move_right", "Move ▶")
	btn_move_right.pressed.connect(_on_move_right)
	move_box.add_child(btn_move_right)
	move_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _move_count_text() -> String:
	if moves_left <= 0:
		return PLAYER_COPY.text("combat.moves_none", "No Moves")
	if moves_left == 1:
		return PLAYER_COPY.text("combat.moves_one", "1 Move")
	return PLAYER_COPY.fill("combat.moves_n", {"n": moves_left}, "%s Moves" % moves_left)


func _moves_window_open() -> bool:
	if not _is_adventure_mode() and not _tut_moves_on:
		return false
	if phase != "fighting" or facing_index < 0:
		return false
	if _move_busy or _walker_busy or _wheel_busy():
		return false
	if not pending_mark.is_empty() or not pending_feed.is_empty() or not pending_chaos.is_empty() or not pending_choice.is_empty():
		return false
	return true


func _hook_live_steps(target: int, dir: int) -> int:
	if target < 0 or target >= wheel.size():
		return -1
	if target == facing_index:
		return 0
	var steps: int = 0
	var i: int = facing_index
	while steps < wheel.size():
		var nxt: int = _live_neighbor_seat(i, dir)
		if nxt < 0:
			return -1
		steps += 1
		if nxt == target:
			return steps
		i = nxt
	return -1


func _hook_walk_dir(target: int) -> int:
	## -1 is Move-right (counter-clockwise), the same direction as Shuriken. 0 means already there.
	if target == facing_index:
		return 0
	var right_steps: int = _hook_live_steps(target, -1)
	var left_steps: int = _hook_live_steps(target, 1)
	if right_steps < 0 and left_steps < 0:
		return 0
	if left_steps < 0:
		return -1
	if right_steps < 0:
		return 1
	if right_steps <= left_steps:
		return -1
	return 1


func _live_neighbor_seat(from: int, dir: int) -> int:
	var n: int = wheel.size()
	if n <= 0 or from < 0:
		return -1
	var i: int = from
	for _step in n:
		i = (i + dir) % n
		if i < 0:
			i += n
		if i == from:
			return -1
		if str(wheel[i].get("kind", "")) != "monster":
			continue
		if int(wheel[i].get("hp", 0)) <= 0:
			continue
		return i
	return -1


func _can_move(dir: int) -> bool:
	if not _moves_window_open() or moves_left <= 0:
		return false
	var dest: int = _live_neighbor_seat(facing_index, dir)
	if dest < 0:
		return false
	if in_tutorial:
		if tut == null or tut.wait != "move":
			return false
		if str(wheel[dest].get("card_id", "")) != str(tut.force_id):
			return false
	return true


func _sync_move_ui() -> void:
	if move_box == null:
		return
	var show: bool = (_is_adventure_mode() or _tut_moves_on) and (phase == "fighting" or phase == "ready")
	move_box.visible = show
	if not show:
		return
	var tut_move: bool = in_tutorial and _tut_moves_on and tut != null and tut.wait == "move"
	if btn_move_left:
		btn_move_left.disabled = false if tut_move else (true if in_tutorial and _tut_moves_on else not _can_move(-1))
		btn_move_left.queue_redraw()
	if btn_move_right:
		btn_move_right.disabled = false if tut_move else (true if in_tutorial and _tut_moves_on else not _can_move(1))
		btn_move_right.queue_redraw()
	_place_move_arrows()
	if wheel_view and wheel_view.has_method("set_moves"):
		wheel_view.set_moves(moves_left, ADVENTURE_MOVES)


func _on_move_left() -> void:
	_try_move(1)


func _on_move_right() -> void:
	_try_move(-1)


func _apply_face_lock(leave_i: int, arrive_i: int) -> void:
	if leave_i >= 0 and leave_i < wheel.size() and typeof(wheel[leave_i]) == TYPE_DICTIONARY:
		wheel[leave_i]["spin_locked"] = false
	if arrive_i >= 0 and arrive_i < wheel.size() and typeof(wheel[arrive_i]) == TYPE_DICTIONARY:
		wheel[arrive_i]["spin_locked"] = true
	_sync_wheel_stats()


func _show_faced_monster() -> void:
	_show_fight_portrait()


func _place_move_arrows() -> void:
	if btn_move_left == null or btn_move_right == null or wheel_view == null:
		return
	var show: bool = (_is_adventure_mode() or _tut_moves_on) and (phase == "fighting" or phase == "ready")
	btn_move_left.visible = show
	btn_move_right.visible = show
	if not show:
		return
	var c: Vector2 = wheel_view.rim_global() if wheel_view.has_method("rim_global") else wheel_view.get_global_rect().get_center()
	var rad: float = wheel_view.rim_radius() if wheel_view.has_method("rim_radius") else wheel_view.size.x * 0.4
	btn_move_left.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn_move_right.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var local_c: Vector2 = btn_move_left.get_global_transform().affine_inverse() * c
	btn_move_left.set_guide(local_c, rad, moves_left, true)
	var local_r: Vector2 = btn_move_right.get_global_transform().affine_inverse() * c
	btn_move_right.set_guide(local_r, rad, moves_left, false)


func _sync_move_hint() -> void:
	if wheel_view == null:
		return
	var dir: int = 0
	if btn_move_left != null and btn_move_left.visible and not btn_move_left.disabled and btn_move_left.is_hovered():
		dir = 1
	elif btn_move_right != null and btn_move_right.visible and not btn_move_right.disabled and btn_move_right.is_hovered():
		dir = -1
	if wheel_view.move_hint_dir != dir:
		wheel_view.move_hint_dir = dir
		wheel_view.queue_redraw()


func _try_move(dir: int) -> void:
	if not _can_move(dir):
		if in_tutorial and tut != null and tut.visible:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_wait", "Hey — finish this first."))
		if sfx:
			sfx.play("error", -12.0)
		return
	_undo_begin()
	var token: int = _undo_gen
	_move_busy = true
	_sync_move_ui()
	if await _shift_facing(dir, true):
		if _undo_stale(token):
			_move_busy = false
			return
		_undo_commit()
		if in_tutorial and tut != null and tut.wait == "move":
			tut.advance()
			_tut_after_advance()
	else:
		if _undo_stale(token):
			_move_busy = false
			return
		_undo_commit()
	_move_busy = false
	_refresh()


## Two living seats in one direction. Does not look at Moves.
func _jar_two_ok(dir: int) -> bool:
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	var first: int = _live_neighbor_seat(facing_index, dir)
	if first < 0:
		return false
	return _live_neighbor_seat(first, dir) >= 0


func _jar_can_move() -> bool:
	return _jar_two_ok(1) or _jar_two_ok(-1)


func _jar_pick_dir() -> int:
	var left: bool = _jar_two_ok(1)
	var right: bool = _jar_two_ok(-1)
	if left and right:
		return 1 if randi_range(0, 1) == 0 else -1
	if left:
		return 1
	if right:
		return -1
	return 0


## Same walk as two arrow clicks, one direction, without spending Moves.
## Returns true when the jar is tapped and kept.
func _jar_slide_two(it: Dictionary) -> bool:
	var dir: int = _jar_pick_dir()
	if dir == 0:
		_log_begin_item(it)
		_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		return true
	var token: int = _undo_gen
	_move_busy = true
	_sync_move_ui()
	var first_ok: bool = await _shift_facing(dir, false)
	var second_ok: bool = false
	if first_ok and not _undo_stale(token):
		second_ok = await _shift_facing(dir, false)
	_move_busy = false
	if _undo_stale(token):
		return true
	if not first_ok or not second_ok:
		_log_begin_item(it)
		_log("on_item_use", "%s — cannot" % str(it.get("name", "?")))
		if sfx:
			sfx.play("error", -10.0)
		_undo_abort()
		_refresh()
		return true
	_log("on_item_use", str(it.get("name", "?")))
	_log("keep", str(it.get("name", "?")))
	it["spent"] = true
	it["keep_after"] = true
	await _count_item_use()
	_toss_item(int(it.get("uid", -1)), true)
	return true


## Walk to the next living monster. dir -1 is up-right (counter-clockwise). spend_move uses an adventure Move.
func _shift_facing(dir: int, spend_move: bool) -> bool:
	var dest: int = _live_neighbor_seat(facing_index, dir)
	if dest < 0:
		return false
	var leave: int = facing_index
	facing_index = dest
	_apply_face_lock(leave, dest)
	if spend_move:
		moves_left = maxi(0, moves_left - 1)
	_log("on_item_use", "Move %s" % str(wheel[dest].get("name", "?")))
	_show_faced_monster()
	if sfx:
		sfx.play("whoosh", -12.0, 1.1)
	if wheel_view:
		wheel_view.facing_index = dest
		await wheel_view.recenter_on(dest, 0.28)
	return true


func _sync_overlay() -> void:
	if _playtest_boot or (playtest_hub != null and playtest_hub.visible):
		overlay.visible = false
		if rope_exit:
			rope_exit.visible = false
		return
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
			if rope_exit.has_method("open_exit"):
				rope_exit.open_exit(dungeons_cleared, _rope_loot_rows())
			else:
				rope_exit.open_exit(dungeons_cleared)
			if rope_exit.has_method("apply_exit_mode"):
				var can_push := false
				var push_interrupt := false
				var chip := {}
				if _campaign_on and _campaign != null:
					can_push = CAMPAIGN_SHELL.can_push(_campaign.rules, _campaign.state)
					var pool := CAMPAIGN_SHELL.current_biome_id(_campaign.rules, _campaign.state)
					var quota: int = CAMPAIGN_SHELL.quota_of(_campaign.rules)
					var n: int = CAMPAIGN_SHELL.cabinet_count(_campaign.state, pool)
					var biome := CAMPAIGN_SHELL.biome_name(_campaign.rules, pool)
					var haul_ids: Array = []
					var haul_pools := {}
					for it in hotbar:
						if typeof(it) != TYPE_DICTIONARY:
							continue
						var hid := str(it.get("card_id", ""))
						if hid == "":
							continue
						haul_ids.append(hid)
						haul_pools[hid] = _campaign_pool_of_item(hid)
					var projected: int = CAMPAIGN_SHELL.project_cabinet_count(
						_campaign.state, pool, haul_ids, haul_pools
					)
					var next_name := ""
					if can_push:
						next_name = CAMPAIGN_SHELL.next_biome_name(_campaign.rules, _campaign.state)
					chip = {
						"biome": biome,
						"n": n,
						"quota": quota,
						"projected": projected,
						"show_proj": n < quota and projected >= quota,
						"next": next_name,
						"show_next": can_push and next_name != "",
					}
					push_interrupt = CAMPAIGN_SHELL.push_needs_nib(_campaign.rules, _campaign.state)
				var endless_run := _campaign_on and _campaign != null and bool(_campaign.state.get("run", {}).get("endless", false))
				rope_exit.apply_exit_mode(_campaign_on, can_push, push_interrupt, chip, endless_run)
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
		overlay_btn.visible = show_defeat
	if overlay_undo:
		overlay_undo.visible = _undo_can_undo() and phase == "defeat"
	if overlay_score:
		overlay_score.visible = adventure and phase == "defeat"
		if overlay_score.visible:
			overlay_score.text = PLAYER_COPY.fill("title.dungeons_cleared", {"n": dungeons_cleared}, "Dungeons cleared: %s" % dungeons_cleared)
	if phase == "defeat":
		overlay_title.text = PLAYER_COPY.text("title.lose", "Caught")
		overlay_btn.text = PLAYER_COPY.text("defeat.home", "Limp home")


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
			_on_monster_right_click(str(s.get("card_id", "")))
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
			hsb.content_margin_left = 4
			hsb.content_margin_right = 4
			hsb.content_margin_top = 4
			hsb.content_margin_bottom = 4
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
		var chain_n: int = int(_ops_of(it).get("n", 0)) if str(it.get("card_id", "")) == "ball_and_chain" else 0
		# marble_n is omitted so grow / swirl can play on the live card.
		sig.append("%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s" % [it.get("uid", 0), it.get("card_id", ""), echo_id, it.get("petrified", false), it.get("toll_n", 0), it.get("bagged_hp", 0), it.get("bagged_name", ""), chain_n, it.get("recycle_n", 0), it.get("cats_eye", false), 0, it.get("rust_n", 0), it.get("hex_n", 0)])
	var cap_n: int = CHALLENGE_HAND if adventure else 9999
	var seated_n: int = mini(hotbar.size(), cap_n)
	var empties: int = (cap_n - seated_n) if adventure else 0
	var pending_uid: int = int(_challenge_pending_gain.get("uid", 0)) if _challenge_loot_wait and not _challenge_pending_gain.is_empty() else 0
	var joined: String = ",".join(sig) + "|e%s|d%s|s%s|p%s" % [empties, 1 if _challenge_loot_wait else 0, seated_n, pending_uid]
	if joined != _hotbar_sig:
		_hotbar_sig = joined
		for c in hotbar_box.get_children():
			hotbar_box.remove_child(c)
			c.queue_free()
		_clear_hotbar_overflow()
		for i in range(seated_n):
			var it_seat: Dictionary = hotbar[i]
			if typeof(it_seat) != TYPE_DICTIONARY:
				continue
			var spawned: Control = _spawn_item_card(it_seat, true)
			if spawned:
				hotbar_box.add_child(spawned)
		if adventure:
			for _e in range(maxi(0, empties)):
				hotbar_box.add_child(_make_hot_empty())
		if hotbar_overflow != null:
			for j in range(seated_n, hotbar.size()):
				var it_wait: Dictionary = hotbar[j]
				if typeof(it_wait) != TYPE_DICTIONARY:
					continue
				var parked: Control = _spawn_item_card(it_wait, true)
				if parked:
					hotbar_overflow.add_child(parked)
			if pending_uid != 0:
				var pending_card: Control = _spawn_item_card(_challenge_pending_gain, false)
				if pending_card:
					hotbar_overflow.add_child(pending_card)
		_place_hotbar_overflow()
		call_deferred("_place_hotbar_overflow")
	for c in _hotbar_all_cards():
		var card = c
		if not card.has_method("set_live"):
			continue
		var it: Dictionary = _find_item(int(card.uid))
		if it.is_empty() and pending_uid != 0 and int(card.uid) == pending_uid:
			it = _challenge_pending_gain
		if it.is_empty():
			continue
		var waiting: bool = hotbar_overflow != null and card.get_parent() == hotbar_overflow
		var view: Dictionary = _item_view(it)
		var uid_n: int = int(it.get("uid", -1))
		var spent_n: bool = bool(it.get("spent", false))
		var feed_uids: Array = pending_feed.get("uids", []) if not pending_feed.is_empty() else []
		var is_snack: bool = feed_uids.has(uid_n)
		var in_fight: bool = phase == "fighting"
		var magnet_ready: bool = phase == "ready" and _is_magnet(it)
		var can_click: bool = false
		if _challenge_loot_wait:
			can_click = (not waiting) and (not _item_blocks_hand_tax(it))
		elif not pending_feed.is_empty():
			can_click = is_snack
		else:
			can_click = (in_fight or magnet_ready) and bool(view["can_use"]) and not spent_n and not _item_stoned(it)
		card.spent = spent_n
		card.set_palette(view["fill"], view["rim"], _tier_of(it))
		var shown_n: String = str(view["number"])
		var pn: int = int(it.get("petrify_n", 0))
		if pn > 0:
			shown_n = str(pn)
		card.set_live(shown_n, str(view["note"]), can_click)
		if card.has_method("set_choice_badge"):
			card.set_choice_badge(_choice_badge_text(it))
		if card.has_method("set_cabinet_badge"):
			var cid: String = str(it.get("card_id", ""))
			var fresh: bool = home_cabin != null and cid != "" and not home_cabin.is_swiped(cid) and not BucketRules.is_token(items_by_id.get(cid, {}))
			card.set_cabinet_badge(fresh, PLAYER_COPY.text("cabin.tip.new", "New!"), PLAYER_COPY.text("cabin.tip.seen", "Seen in {the_grumble}. Not home yet."))
		if card.has_method("set_beggar_mark"):
			card.set_beggar_mark(_beggar_marked(uid_n))
		if card.has_method("set_atk_pip"):
			card.set_atk_pip(_number_is_atk(view, pn))
		if card.has_method("set_hp_cost"):
			card.set_hp_cost(str(view.get("hp_cost", "")))
		if card.has_method("set_glyphs"):
			card.set_glyphs([] if pn > 0 else _face_rows(it, view))
		if card.has_method("set_danger"):
			card.set_danger(
			(str(it.get("card_id", "")) == "toll" and int(it.get("toll_n", 0)) == 1)
			or (str(it.get("card_id", "")) == "hex" and int(it.get("hex_n", 0)) == 1)
		)
		if card.has_method("set_num_color"):
			card.set_num_color(Color("9a9a9a") if pn > 0 else _num_color(str(view.get("kind", "ATK"))))
		if card.has_method("set_playable"):
			card.set_playable(can_click)
		if card.has_method("set_guarding"):
			card.set_guarding(false)
		_apply_item_stone_look(card, it)
		_apply_bag_look(card, it)
		var mag_on: bool = _is_magnet(it) and _magnet_mode_of(it) != "off"
		if card.has_method("set_aura"):
			var rec_ready: bool = str(it.get("card_id", "")) == "recycler" and int(it.get("recycle_n", 5)) <= 1
			var snack_aura: bool = is_snack and not _toss_pick_mode()
			card.set_aura(snack_aura or rec_ready or (mag_on and (phase == "fighting" or phase == "ready")))
		if card.has_method("set_toss_pick"):
			card.set_toss_pick(_toss_pick_mode() and can_click)
		if card.has_method("set_waiting_entry"):
			card.set_waiting_entry(waiting)
		if card.has_method("set_passive_icons"):
			card.set_passive_icons(null, null, false)
		_sync_card_pass5(card, it, can_click, in_fight)
	_sync_hotbar_formulas()


func _make_hot_empty() -> Control:
	return HOT_EMPTY.new()


func _hotbar_park_overflow() -> bool:
	if not adventure:
		return false
	if hotbar.size() > _forced_hand_cap():
		return true
	return _challenge_loot_wait and not _challenge_pending_gain.is_empty()


func _hotbar_all_cards() -> Array:
	var out: Array = []
	if hotbar_box != null:
		out.append_array(hotbar_box.get_children())
	if hotbar_overflow != null:
		out.append_array(hotbar_overflow.get_children())
	return out


func _clear_hotbar_overflow() -> void:
	if hotbar_overflow == null:
		return
	for c in hotbar_overflow.get_children():
		hotbar_overflow.remove_child(c)
		c.queue_free()


func _place_hotbar_overflow() -> void:
	if hotbar_overflow == null:
		return
	hotbar_overflow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var kids: Array = hotbar_overflow.get_children()
	if kids.is_empty():
		hotbar_overflow.queue_redraw()
		return
	var gap: float = 8.0
	var cw: float = 147.5
	var ch: float = 120.0
	var first: Control = kids[0] as Control
	if first != null:
		var sz: Vector2 = first.get_combined_minimum_size()
		if sz.x > 8.0:
			cw = sz.x
		if sz.y > 8.0:
			ch = sz.y
	var n: int = kids.size()
	var total: float = float(n) * cw + float(maxi(0, n - 1)) * gap
	var host_w: float = hotbar_overflow.size.x
	if host_w < 8.0 and hotbar_panel != null:
		host_w = hotbar_panel.size.x
	var start_x: float = (host_w - total) * 0.5
	var y: float = -ch - 16.0
	for i in range(n):
		var card: Control = kids[i] as Control
		if card == null:
			continue
		card.position = Vector2(start_x + float(i) * (cw + gap), y)
		if card.has_method("set_waiting_entry"):
			card.set_waiting_entry(false)
			card.set_waiting_entry(true)
	hotbar_overflow.queue_redraw()


func _draw_hotbar_overflow() -> void:
	if hotbar_overflow == null:
		return
	for c in hotbar_overflow.get_children():
		if not (c is Control):
			continue
		var card: Control = c
		var y: float = card.position.y + card.size.y + 4.0
		var x0: float = card.position.x
		var x_end: float = x0 + card.size.x
		var col := Color("c4a574", 0.72)
		var dash: float = 7.0
		var gap: float = 5.0
		var x: float = x0
		while x < x_end:
			var x1: float = minf(x + dash, x_end)
			hotbar_overflow.draw_line(Vector2(x, y), Vector2(x1, y), col, 2.0)
			x += dash + gap


func _item_icon_tex(it: Dictionary, show_id: String = "") -> Texture2D:
	var sid: String = show_id if show_id != "" else str(it.get("card_id", ""))
	if sid == "sai" or str(_ops_of(it).get("kind", "")) == "atk_alt_24":
		var pair: bool = int(it.get("alt_n", 2)) == 4
		var sai_path: String = "res://assets/dungeon/anim/sai_pair.png" if pair else "res://assets/dungeon/anim/sai_single.png"
		if ResourceLoader.exists(sai_path):
			return load(sai_path) as Texture2D
	if sid == "bag_of_holding" and int(it.get("bagged_hp", 0)) > 0:
		sid = "bag_of_holding_closed"
	if bool(it.get("cats_eye", false)):
		if art != null:
			var eye: Texture2D = art.item_tex("cats_eye_marble")
			if eye != null:
				return eye
		sid = "marble"
	var icon: Texture2D = tex_by_item.get(sid, tex_sword)
	if art != null:
		var pix: Texture2D = art.item_tex(sid)
		if pix != null:
			icon = pix
	return icon


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
	var icon: Texture2D = _item_icon_tex(it, show_id)
	var k: String = str(view.get("kind", "ATK"))
	var pn: int = int(it.get("petrify_n", 0))
	var shown_n: String = str(pn) if pn > 0 else str(view["number"])
	var num_col: Color = Color("9a9a9a") if pn > 0 else _num_color(k)
	card.setup(
		int(it.get("uid", 0)),
		str(it.get("card_id", "")),
		shown_n,
		icon,
		view["fill"],
		view["rim"],
		_title_case(show_name),
		num_col,
		k,
		_kind_mark(k)
	)
	if card.has_method("set_echo_mark") and str(it.get("card_id", "")) == "echo_bell" and art != null:
		card.set_echo_mark(art.item_tex("echo_bell"))
	_apply_bag_look(card, it)
	_apply_item_stone_look(card, it)
	if card.has_method("set_aura"):
		var rec_ready: bool = str(it.get("card_id", "")) == "recycler" and int(it.get("recycle_n", 5)) <= 1
		card.set_aura(rec_ready)
	if card.has_method("set_passive_icons"):
		card.set_passive_icons(null, null, false)
	card.set_palette(view["fill"], view["rim"], _tier_of(it))
	var rule: Dictionary = _item_rule(it)
	card.set_formula(str(rule.get("equation", "")))
	card.set_live(shown_n)
	if card.has_method("set_atk_pip"):
		card.set_atk_pip(_number_is_atk(view, pn))
	if card.has_method("set_hp_cost"):
		card.set_hp_cost(str(view.get("hp_cost", "")))
	card.show_formula(_shift_held)
	if card.has_method("set_glyphs"):
		card.set_glyphs([] if pn > 0 else _face_rows(it, view))
	if card.has_method("set_danger"):
		card.set_danger(
			(str(it.get("card_id", "")) == "toll" and int(it.get("toll_n", 0)) == 1)
			or (str(it.get("card_id", "")) == "hex" and int(it.get("hex_n", 0)) == 1)
		)
	card.hovered.connect(func() -> void:
		_on_item_hovered(it, card)
	)
	card.unhovered.connect(_on_item_unhovered)
	if _authoring() or PLAYTEST_FLAG.on():
		card.edit_wanted.connect(_on_item_right_click.bind(str(it.get("card_id", ""))))
	if usable:
		card.picked.connect(_use_item.bind(int(it.get("uid", 0))))
	return card


func _choice_badge_text(it: Dictionary) -> String:
	var ops: Dictionary = _ops_of(it)
	if str(ops.get("kind", "")) != "choose":
		return ""
	var opts: Variant = ops.get("options", [])
	if typeof(opts) != TYPE_ARRAY:
		return ""
	var bits: PackedStringArray = PackedStringArray()
	for ov in opts:
		if typeof(ov) != TYPE_DICTIONARY:
			continue
		var o: Dictionary = ov
		if o.has("atk"):
			bits.append(str(int(o["atk"])))
		elif o.has("atk_drop"):
			bits.append(str(int(o["atk_drop"])))
	if bits.size() < 2:
		return ""
	return " / ".join(bits)


func _on_item_hovered(it: Dictionary, card: Control = null) -> void:
	if _cabin_up():
		return
	_fly_card = card
	if sfx:
		sfx.hover()
	var rule: Dictionary = _item_rule(it)
	if card != null and card.has_method("set_formula") and card.has_method("show_formula"):
		card.set_formula(str(rule.get("equation", "")))
		card.show_formula(true)
	if fly_tip:
		fly_tip.show_rule(str(rule["title"]), str(rule["value"]), str(rule["equation"]), str(rule["body"]), str(rule["warn"]), null, "item", str(it.get("card_id", "")), _item_look(it))
		_place_fly(card)
	_apply_preview(_preview_from_item(it))
	_refresh_blk(false)
	_tutorial_on_item_hover()
	_queue_hover_preview(it, card)


func _on_item_unhovered() -> void:
	_fly_card = null
	_ghost_blk = -1
	_clear_hover_preview()
	_apply_preview({})
	_sync_hotbar_formulas()
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


func _tutorial_keeps_seat() -> bool:
	if not in_tutorial or _tut_bandit_seated:
		return false
	if facing_index < 0 or facing_index >= wheel.size():
		return false
	return str(wheel[facing_index].get("kind", "")) == "monster"


func _tutorial_replace_with_deck(index: int, id: String) -> void:
	_tut_bandit_seated = true
	_tut_show_deck = true
	if challenge_deck.is_empty():
		challenge_deck.append(id)
	if dungeon_deck_ui:
		dungeon_deck_ui.visible = true
		_layout_play_field()
		if not dungeon_deck_ui.is_busy():
			dungeon_deck_ui.set_count(challenge_deck.size())
		_sync_challenge_peek()
		if wheel_view and wheel_view.has_method("slice_portrait_global"):
			dungeon_deck_ui.entry_global = wheel_view.slice_portrait_global(index)
		await dungeon_deck_ui.play_draw()
	if not challenge_deck.is_empty():
		challenge_deck.pop_front()
	if dungeon_deck_ui and not dungeon_deck_ui.is_busy():
		dungeon_deck_ui.set_count(challenge_deck.size())
		_sync_challenge_peek()
	if wheel_view and wheel_view.has_method("rotate_index_to_top"):
		await wheel_view.rotate_index_to_top(index, 0.42)
	if ability_slash:
		var slash_tex: Texture2D = null
		if art != null:
			slash_tex = art.monster_still(id)
		await ability_slash.play({
			"title": _title_case(str(monsters_by_id.get(id, {}).get("name", id))),
			"call": MONSTER_LINES.call_of(id, monsters_by_id.get(id, {})),
			"tex": slash_tex,
			"is_item": false,
			"card_id": id,
		})
	if index < 0 or index >= wheel.size():
		_refresh()
		return
	var slot: String = str(wheel[index].get("slot", ""))
	var seated: Dictionary = _make_monster(id)
	seated["slot"] = slot
	wheel[index] = seated
	_sync_wheel_stats()
	if wheel_view:
		if wheel_view.slay_index == index and wheel_view.has_method("clear_slay"):
			wheel_view.clear_slay()
		_stamp_atk_variants()
		wheel_view.set_slices(wheel, -1, "none")
		wheel_view.pulse_arrive(index)
	if sfx:
		sfx.play("drop", -8.0)
		sfx.play("whoosh", -12.0, 0.9)
	_refresh()


func _tutorial_seat_cube_beside_bandit() -> void:
	if _index_of_monster("gelatinous_cube") >= 0:
		return
	var bandit_i: int = _index_of_monster("bandit")
	if bandit_i < 0:
		return
	var at: int = bandit_i + 1
	var seated: Dictionary = _make_monster("gelatinous_cube")
	if at < wheel.size() and str(wheel[at].get("kind", "")) == "empty":
		seated["slot"] = str(wheel[at].get("slot", ""))
		wheel[at] = seated
	else:
		wheel.insert(at, seated)
		_reseat_slots()
	_sync_wheel_stats()
	if wheel_view:
		wheel_view.set_slices(wheel, -1, "none")
	_refresh()


func _tutorial_begin_face() -> void:
	if _tut_face_busy or tut == null or tut.wait != "face":
		return
	if phase != "ready":
		return
	_tut_face_busy = true
	_tutorial_seat_cube_beside_bandit()
	_tut_moves_on = true
	moves_left = ADVENTURE_MOVES
	_howto_move_shown = true
	_sync_move_ui()
	await _on_spin()


func _tutorial_arm_finisher() -> void:
	if _tut_finisher_armed:
		return
	_tut_finisher_armed = true
	_tut_hold_slay = true
	var sai: Dictionary = _make_item("sai")
	sai["alt_n"] = 4
	hotbar.append(sai)
	_sort_hotbar()
	_refresh()


func _tutorial_offer_shuriken() -> void:
	if _tut_draft_busy or challenge_draft_ui == null:
		return
	_tut_draft_busy = true
	var shuriken: Dictionary = _make_item("shuriken")
	var decoy: Dictionary = _make_item("throwing_knife")
	var sub: String = "Bandit · %s" % PLAYER_COPY.tier_name(1)
	while in_tutorial and tut != null and tut.wait == "draft:shuriken":
		challenge_draft_ui.present("Loot", sub, _challenge_draft_card(shuriken), _challenge_draft_card(decoy), shuriken, decoy)
		_draft_final_item = true
		challenge_draft_ui.set_final_item(false)
		_sync_hub_cue()
		if challenge_draft_ui.get("_sub") != null:
			challenge_draft_ui._sub.visible = true
			challenge_draft_ui._sub.text = sub
		var uid: int = await challenge_draft_ui.chosen
		if uid == int(shuriken.get("uid", -1)):
			hotbar.append(shuriken.duplicate(true))
			_sort_hotbar()
			challenge_draft_ui.hide_draft()
			_refresh()
			tut.advance()
			_tut_after_advance()
			break
		if tut:
			tut.nudge(PLAYER_COPY.text("tutorial.nudge_item", "Click the highlighted thing — not that one."))
		if sfx:
			sfx.play("error", -12.0)
		challenge_draft_ui.hide_draft()
	_tut_draft_busy = false


func _tutorial_release_hold_slay() -> void:
	if phase == "fighting":
		await _run_dead_sweep()


func _tutorial_play_unlock() -> void:
	var entries: Array = _tutorial_unlock_entries()
	if entries.is_empty() or _bucket_reveal == null:
		return
	_unlock_screen = true
	_hide_board_for_unlock()
	await _bucket_reveal.play(0, entries)
	_unlock_screen = false
	if _ui_root:
		_ui_root.visible = true
	if dungeon_bg:
		dungeon_bg.visible = true


func _tutorial_unlock_entries() -> Array:
	var skip := {
		"wizard": true,
		"golem": true,
		"goblin": true,
		"bandit": true,
		"gelatinous_cube": true,
		"sai": true,
		"helmet": true,
		"da_boot": true,
		"knucklers": true,
		"shuriken": true,
	}
	var loot: Array = []
	var loot_extra: Array = []
	var foes: Array = []
	var foe_extra: Array = []
	for id in items_by_id.keys():
		if skip.has(str(id)):
			continue
		var card: Dictionary = items_by_id[id]
		if BucketRules.of_card(card) != 1:
			continue
		if str(card.get("status", "live")) == "retired" or str(card.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card) or BucketRules.is_always_starter(card):
			continue
		var loot_tex: Texture2D = tex_by_item.get(id, null)
		if loot_tex == null and art != null:
			loot_tex = art.item_tex(id)
		var entry: Dictionary = _bucket_entry(card, "Loot", loot_tex)
		if BucketRules.counts_for_mill(card):
			loot.append(entry)
		else:
			loot_extra.append(entry)
	for id2 in monsters_by_id.keys():
		if skip.has(str(id2)):
			continue
		var card2: Dictionary = monsters_by_id[id2]
		if BucketRules.of_card(card2) != 1:
			continue
		if str(card2.get("status", "live")) == "retired" or str(card2.get("status", "live")) == "hold":
			continue
		if BucketRules.is_token(card2):
			continue
		var entry2: Dictionary = _bucket_entry(card2, "Foe", tex_by_monster.get(id2, null))
		if BucketRules.counts_for_mill(card2):
			foes.append(entry2)
		else:
			foe_extra.append(entry2)
	var out: Array = []
	out.append_array(loot)
	out.append_array(loot_extra)
	out.append_array(foes)
	out.append_array(foe_extra)
	return out


func _start_tutorial() -> void:
	_hide_cabin_for_run()
	_tut_boot = true
	_tut_next_dungeon = false
	_tut_intro_step = {}
	_tut_d2_done = {}
	_tut_d2_focus = ""
	_tut_d2_busy = false
	_tut_d2_pending = ""
	_tut_inspected_tag = ""
	_upgraded_slices = []
	in_tutorial = true
	_tut_bandit_seated = false
	_tut_draft_busy = false
	_tut_finisher_armed = false
	_tut_hold_slay = false
	_tut_moves_on = false
	_tut_face_busy = false
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
	_tut_show_deck = true
	challenge_deck = ["bandit"]
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
	_open_home_cabin(true, "win", [], [])
	if home_cabin:
		home_cabin._arrive_skip = 2
	_refresh()


func _tut_finished() -> void:
	_tutorial_finish_async()


func _tutorial_finish_async() -> void:
	in_tutorial = false
	_tut_moves_on = false
	_tut_hold_slay = false
	if tut:
		tut.close()
	await _tutorial_play_unlock()
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
	if tut.wait == "draft:shuriken":
		_tutorial_offer_shuriken()
	elif tut.wait == "face":
		_tutorial_begin_face()
	elif tut.wait == "item:sai" and _tut_bandit_seated and tut.spoken().find("showing 4") >= 0:
		_tutorial_arm_finisher()
	var spots: Array = []
	var arrows: Array = []
	_tut_collect_spots(spots, arrows)
	tut.set_spots(spots, arrows)
	_tut_inspect_focused_item()


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


func _tut_inspect_focused_item() -> void:
	if tut == null or not in_tutorial:
		return
	var tag: String = str(tut.focus_tag)
	if tag != "item:helmet" and tag != "item:knucklers":
		return
	if tag == _tut_inspected_tag:
		return
	_tut_inspected_tag = tag
	var iid: String = tag.substr(5)
	var card: Control = _hotbar_card(iid)
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(it.get("card_id", "")) != iid:
			continue
		_on_item_hovered(it, card)
		return


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
		if wheel_view != null:
			_tut_add_rect(spots, wheel_view.focus_rect("hub_hp"))
		return
	if tag == "deck":
		_tut_add_control(spots, dungeon_deck_ui)
		var deck_seat: int = _index_of_monster("bandit") if _tut_bandit_seated else facing_index
		if deck_seat >= 0 and wheel_view != null and wheel_view.has_method("slice_rect"):
			_tut_add_rect(spots, wheel_view.slice_rect(deck_seat))
		return
	if tag == "draft":
		_tut_add_control(spots, challenge_draft_ui)
		return
	if tag == "move_arrow":
		if btn_move_left != null and btn_move_left.has_method("arc_global_rect"):
			_tut_add_rect(spots, btn_move_left.arc_global_rect())
		if wheel_view != null:
			_tut_add_rect(spots, wheel_view.focus_rect("moves"))
			var cube_i: int = _index_of_monster("gelatinous_cube")
			if cube_i >= 0:
				_tut_add_rect(spots, wheel_view.slice_rect(cube_i))
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
			return wheel_view
		"hotbar":
			return hotbar_box
		"spin":
			return btn_spin
		"deck":
			return dungeon_deck_ui
		"draft":
			return challenge_draft_ui
		"move_arrow":
			return btn_move_left
		"begin":
			return btn_challenge_begin
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


func _control_uid(c: Object) -> int:
	if c == null:
		return -1
	var v: Variant = c.get("uid")
	if typeof(v) != TYPE_INT:
		return -1
	return v


func _hotbar_card_by_uid(uid: int) -> Control:
	if uid < 0:
		return null
	for c in _hotbar_all_cards():
		if _control_uid(c) == uid:
			return c
	return null


func _apply_sai_static() -> void:
	if hotbar_box == null:
		return
	for it in hotbar:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if str(_ops_of(it).get("kind", "")) != "atk_alt_24":
			continue
		var card: Control = _hotbar_card_by_uid(int(it.get("uid", -1)))
		if card != null and card.has_method("set_sai_static"):
			card.set_sai_static(int(it.get("alt_n", 2)) == 4)


func _sync_card_pass5(card: Control, it: Dictionary, _can_click: bool, in_fight: bool) -> void:
	var cid: String = str(it.get("card_id", ""))
	var sai_busy: bool = card.has_method("sai_busy") and card.sai_busy()
	var marble_busy: bool = card.has_method("marble_busy") and card.marble_busy()
	if not sai_busy and not marble_busy and card.has_method("set_icon"):
		if cid == "sai" or str(_ops_of(it).get("kind", "")) == "atk_alt_24":
			if card.has_method("set_sai_static"):
				card.set_sai_static(int(it.get("alt_n", 2)) == 4)
			else:
				card.set_icon(_item_icon_tex(it))
		elif cid == "marble":
			pass
		else:
			card.set_icon(_item_icon_tex(it))
	if cid == "marble" and card.has_method("start_marble_idle") and not marble_busy:
		card.start_marble_idle(bool(it.get("cats_eye", false)))
	elif cid != "marble" and card.has_method("stop_marble_idle"):
		card.stop_marble_idle()
	if card.has_method("set_armed"):
		var sling_on: bool = cid == "sling" and _sling_is_loaded(it)
		var armed: bool = sling_on
		if in_fight and not bool(it.get("spent", false)):
			if cid == "pacemaker" or cid == "healing_potion":
				armed = true
			if cid == "danger_magnet" and _is_magnet(it) and _magnet_mode_of(it) != "off":
				armed = true
		var key: String = "status.sling_loaded" if sling_on else ""
		card.set_armed(armed, key)
	if card.has_method("set_no_effect") and not _hover_ghost_on:
		card.set_no_effect(false)


func _queue_hover_preview(it: Dictionary, card: Control) -> void:
	if _hover_preview_tw != null and is_instance_valid(_hover_preview_tw):
		_hover_preview_tw.kill()
	_hover_preview_tw = create_tween()
	_hover_preview_tw.tween_interval(0.08)
	_hover_preview_tw.tween_callback(func() -> void:
		if _fly_card != card:
			return
		_run_hover_preview(it, card)
	)


func _clear_hover_preview() -> void:
	if _hover_preview_tw != null and is_instance_valid(_hover_preview_tw):
		_hover_preview_tw.kill()
		_hover_preview_tw = null
	_hover_ghost_on = false
	if hotbar_box != null:
		for c in hotbar_box.get_children():
			if c.has_method("set_no_effect"):
				c.set_no_effect(false)
	if intent_plate != null:
		_sync_intent_plate()


func _run_hover_preview(it: Dictionary, card: Control) -> void:
	if phase != "fighting" or facing_index < 0 or facing_index >= wheel.size():
		return
	if card != null and not bool(_item_view(it).get("can_use", false)):
		return
	_hover_ghost_on = true
	var face: Dictionary = wheel[facing_index]
	var fid: String = str(face.get("card_id", ""))
	var silenced: bool = _is_silenced(face)
	var hits: Array = _intent_hits()
	var p: Dictionary = _preview_from_item(it)
	var view: Dictionary = _item_view(it)
	var ops: Dictionary = _ops_of(it)
	var kind: String = str(ops.get("kind", ""))
	if fid == "harpy" and not silenced:
		hits.append({
			"n_raw": int(face.get("atk", 0)),
			"soaked": false,
			"pierce": false,
			"src_index": facing_index,
			"poison": false,
			"loop": false,
			"chip": "plus",
			"ghost_plus": true,
			"ghost_mode": true,
		})
	if fid == "amalgam" and not silenced:
		for h in hits:
			if typeof(h) != TYPE_DICTIONARY:
				continue
			h["n_old"] = int(h.get("n_raw", 0))
			h["n_raw"] = int(h.get("n_raw", 0)) * 2
			h["ghost_mode"] = true
		var slot: Dictionary = p.get(facing_index, {})
		slot["hp"] = int(face.get("hp", 0))
		slot["atk"] = int(face.get("atk", 0))
		p[facing_index] = slot
	var is_net: bool = str(it.get("card_id", "")) == "net"
	if not is_net and kind == "choose":
		var opts: Variant = ops.get("options", [])
		if typeof(opts) == TYPE_ARRAY:
			for ov in opts:
				if typeof(ov) == TYPE_DICTIONARY and (ov as Dictionary).has("atk_drop"):
					is_net = true
					break
	if is_net:
		for h in hits:
			if typeof(h) != TYPE_DICTIONARY:
				continue
			var raw: int = int(h.get("n_raw", 0))
			h["n_old"] = raw
			h["range_lo"] = maxi(0, raw - 3)
			h["range_hi"] = maxi(0, raw - 1)
			h["ghost_mode"] = true
	var kill: bool = false
	var shield_atk_face: bool = kind == "shield_alt" and _shield_face(it) == "atk"
	if bool(view.get("can_use", false)) and (_kind_previews_facing_kill(kind) or shield_atk_face) and fid != "goblin":
		var dmg: int = _atk_with_head(3) if shield_atk_face else int(view.get("n", 0))
		if int(face.get("hp", 0)) > 0 and dmg >= int(face.get("hp", 0)):
			kill = true
	if kill:
		for h in hits:
			if typeof(h) != TYPE_DICTIONARY:
				continue
			h["kill_dim"] = true
			h["ghost_mode"] = true
		var kslot: Dictionary = p.get(facing_index, {})
		kslot["kill"] = true
		p[facing_index] = kslot
	## Neighbor items never dim the facing intent as a kill.
	if kind == "atk_neighbor" or kind == "mark_crossbow":
		if p.has(facing_index):
			p[facing_index].erase("kill")
			if int(p[facing_index].get("hp", 0)) >= 0:
				p.erase(facing_index)
	for h2 in hits:
		if typeof(h2) == TYPE_DICTIONARY:
			h2["ghost_mode"] = true
	if intent_plate:
		intent_plate.ghost(hits)
	_apply_preview(p)
	_refresh_blk(false)


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
	var release_hold: bool = id == "shuriken" and _tut_hold_slay
	tut.advance()
	_tut_after_advance()
	if release_hold:
		_tut_hold_slay = false
		call_deferred("_tutorial_release_hold_slay")


func _tutorial_combat_started() -> void:
	if not in_tutorial or tut == null:
		return
	if tut.wait != "spin" and tut.wait != "auto_spin" and tut.wait != "face":
		return
	if facing_index >= 0 and facing_index < wheel.size():
		tut.land = str(wheel[facing_index].get("card_id", ""))
	tut.advance()
	_tut_after_advance()


func _tut_branch_ok(br: String) -> bool:
	if br == "golem_waiting":
		return _index_of_monster("golem") >= 0
	if br == "goblin_waiting":
		return _index_of_monster("goblin") >= 0
	return false


func _tut_on_progress_key() -> void:
	if not in_tutorial or tut == null or not tut.visible or not tut.armed():
		return
	var w: String = tut.wait
	if w == "continue":
		_tut_on_continue()
		return
	if w == "spin" or w == "auto_spin":
		if phase == "ready" and facing_index < 0:
			await _on_spin()
		return
	if w == "done" or w == "choice":
		await _on_done()
		return
	if w.begins_with("item:"):
		var iid: String = w.substr(5)
		for it in hotbar:
			if typeof(it) != TYPE_DICTIONARY:
				continue
			if str(it.get("card_id", "")) != iid or bool(it.get("spent", false)):
				continue
			await _use_item(int(it.get("uid", -1)))
			return
		return
	if w == "move":
		if _can_move(1):
			await _try_move(1)
		elif _can_move(-1):
			await _try_move(-1)
		return
	if w == "hover" or w == "hover_shift" or w.begins_with("hover_slice"):
		if wheel_view != null:
			var hi: int = facing_index
			if hi < 0:
				hi = _index_of_monster("goblin")
			if hi < 0:
				hi = _index_of_monster("wizard")
			if hi >= 0:
				wheel_view.hover_index = hi
				_tutorial_on_slice_hover(hi)
				_tutorial_try_shift_inspect()
		return
	if w == "hover_item":
		_tutorial_on_item_hover()
		return
	if w.begins_with("draft:") and challenge_draft_ui != null and challenge_draft_ui.has_method("pick_card_id"):
		challenge_draft_ui.pick_card_id(w.substr(6))


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
	if tut.wait == "hover_shift" or tut.wait == "hover":
		if wheel_view != null and index >= 0:
			wheel_view.hover_index = index
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
	if tut.wait != "hover_shift" and tut.wait != "hover":
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
