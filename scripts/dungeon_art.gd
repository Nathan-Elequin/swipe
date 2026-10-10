extends Node
## 0x72 atlas slices + Kenney UI/VFX. Extra CC0 item PNGs only where the atlas is the wrong object.

const ATLAS_PATH := "res://assets/dungeon/atlas.png"
const LIST_PATH := "res://assets/dungeon/tile_list.txt"

const MONSTER_STEM := {
	"wizard": "wizzard_m",
	"golem": "big_zombie",
	"goblin": "goblin",
	"skeleton": "skelet",
	"hornet_swarm": "imp",
	"lich": "necromancer",
	"ogre": "ogre",
	"berserker": "orc_warrior",
	"dire_wolf": "chort",
	"bandit": "masked_orc",
	"two_headed_serpent": "slug",
	"slime_boss": "swampy",
	"leech_league": "doc",
	"wraith": "angel",
	"mimic": "chest_mimic",
	"spider_queen": "ice_zombie",
	"commander": "orc_shaman",
	"dragon": "big_demon",
	"needleback": "wogol",
	"gelatinous_cube": "pumpkin_dude",
	"gargoyle": "knight_m",
	"harpy": "elf_f",
	"kobold_trapper": "lizard_m",
	"clockwork_knight": "dwarf_m",
	"basilisk": "lizard_f",
	"hollow": "tiny_zombie",
	"beggar": "dwarf_f",
	"wick": "wizzard_f",
	"anvil": "knight_f",
}

const ITEM_STEM := {
	"throwing_knife": "weapon_knife",
	"shield": "weapon_knight_sword",
	"sai": "weapon_duel_sword",
	"medallion": "flask_yellow",
	"helmet": "flask_blue",
	"da_boot": "weapon_spear",
	"bloody_gauntlets": "flask_red",
	"bracers": "weapon_baton_with_spikes",
	"knucklers": "weapon_hammer",
	"spiked_flail": "weapon_mace",
	"sledgehammer": "weapon_big_hammer",
	"grimoire": "weapon_green_magic_staff",
	"breastplate": "weapon_knight_sword",
	"smoke_bomb": "bomb_f0",
	"fangs": "weapon_cleaver",
	"poison_flask": "flask_green",
	"healing_potion": "flask_big_red",
	"crossbow": "weapon_bow",
	"pocketwatch": "weapon_golden_sword",
	"double_axe": "weapon_double_axe",
	"victory_flask": "flask_big_yellow",
	"grappling_hook": "weapon_spear",
	"spiked_shield": "weapon_knight_sword",
	"grief_jar": "flask_big_blue",
	"longbow": "weapon_bow_2",
	"lantern": "flask_big_green",
	"mirror_shard": "flask_blue",
	"caltrops": "weapon_throwing_axe",
	"net": "weapon_spear",
	"echo_bell": "flask_big_yellow",
	"quiet_bell": "flask_yellow",
	"iron_chain": "weapon_spear",
	"counting_beads": "flask_yellow",
	"measuring_tape": "weapon_golden_sword",
}

const ITEM_PNG := {
	"shield": "res://assets/dungeon/items/shield.png",
	"helmet": "res://assets/dungeon/items/helmet.png",
	"breastplate": "res://assets/dungeon/items/breastplate.png",
	"medallion": "res://assets/dungeon/items/medallion.png",
	"da_boot": "res://assets/dungeon/items/boot.png",
	"bloody_gauntlets": "res://assets/dungeon/items/gauntlets.png",
	"bracers": "res://assets/dungeon/items/bracers.png",
	"grimoire": "res://assets/dungeon/items/grimoire.png",
	"pocketwatch": "res://assets/dungeon/items/watch.png",
	"healing_potion": "res://assets/dungeon/items/healing_potion.png",
	"poison_flask": "res://assets/dungeon/items/poison_flask.png",
	"smoke_bomb": "res://assets/dungeon/items/smoke_bomb.png",
	"throwing_knife": "res://assets/dungeon/items/throwing_knife.png",
	"spiked_flail": "res://assets/dungeon/items/spiked_flail.png",
	"sledgehammer": "res://assets/dungeon/items/sledgehammer.png",
	"double_axe": "res://assets/dungeon/items/double_axe.png",
	"victory_flask": "res://assets/dungeon/items/victory_flask.png",
	"grappling_hook": "res://assets/dungeon/items/grappling_hook.png",
	"grief_jar": "res://assets/dungeon/items/grief_jar.png",
	"longbow": "res://assets/dungeon/items/longbow.png",
	"lantern": "res://assets/dungeon/items/lantern.png",
	"mirror_shard": "res://assets/dungeon/items/mirror_shard.png",
	"caltrops": "res://assets/dungeon/items/caltrops.png",
	"net": "res://assets/dungeon/items/net.png",
	"echo_bell": "res://assets/dungeon/items/echo_bell.png",
	"quiet_bell": "res://assets/dungeon/items/quiet_bell.png",
	"iron_chain": "res://assets/dungeon/items/iron_chain.png",
	"counting_beads": "res://assets/dungeon/items/counting_beads.png",
	"measuring_tape": "res://assets/dungeon/items/measuring_tape.png",
	"last_match": "res://assets/dungeon/items/last_match.png",
	"mute_stone": "res://assets/dungeon/items/mute_stone.png",
	"sai": "res://assets/dungeon/items/sai.png",
	"fangs": "res://assets/dungeon/items/fangs.png",
	"knucklers": "res://assets/dungeon/items/knucklers.png",
	"crossbow": "res://assets/dungeon/items/crossbow.png",
	"spiked_shield": "res://assets/dungeon/items/spiked_shield.png",
	"cursed_scroll": "res://assets/dungeon/items/cursed_scroll.png",
}

const MONSTER_PNG := {
	"spider_queen": "res://assets/dungeon/extra/spider.png",
	"gelatinous_cube": "res://assets/dungeon/extra/gelatinous_cube.png",
	"gargoyle": "res://assets/dungeon/extra/gargoyle.png",
	"harpy": "res://assets/dungeon/extra/harpy.png",
	"kobold_trapper": "res://assets/dungeon/extra/kobold_trapper.png",
	"clockwork_knight": "res://assets/dungeon/extra/clockwork_knight.png",
	"hollow": "res://assets/dungeon/extra/hollow.png",
	"beggar": "res://assets/dungeon/extra/beggar.png",
	"wick": "res://assets/dungeon/extra/wick.png",
	"anvil": "res://assets/dungeon/extra/anvil.png",
	"basilisk": "res://assets/dungeon/extra/basilisk.png",
	"two_headed_serpent": "res://assets/dungeon/extra/two_headed_serpent.png",
	"wraith": "res://assets/dungeon/extra/wraith.png",
	"hornet_swarm": "res://assets/dungeon/extra/hornet_swarm.png",
	"dire_wolf": "res://assets/dungeon/extra/dire_wolf.png",
	"leech_league": "res://assets/dungeon/extra/leech_league.png",
	"needleback": "res://assets/dungeon/extra/needleback.png",
}

var atlas: Texture2D
var rects: Dictionary = {}
var vfx: Dictionary = {}
var ui: Dictionary = {}
var extra_items: Dictionary = {}
var extra_monsters: Dictionary = {}
var ready_ok: bool = false


func setup() -> void:
	atlas = load(ATLAS_PATH) as Texture2D
	_parse_list()
	_load_extras()
	ready_ok = atlas != null and not rects.is_empty()


func _parse_list() -> void:
	var f := FileAccess.open(LIST_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing tile list")
		return
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line == "":
			continue
		var p: PackedStringArray = line.split(" ")
		if p.size() < 5:
			continue
		rects[str(p[0])] = Rect2(float(p[1]), float(p[2]), float(p[3]), float(p[4]))


func _load_extras() -> void:
	vfx["star"] = _tex("res://assets/dungeon/vfx/star_08.png")
	vfx["star2"] = _tex("res://assets/dungeon/vfx/star_04.png")
	vfx["spark"] = _tex("res://assets/dungeon/vfx/spark_05.png")
	vfx["spark2"] = _tex("res://assets/dungeon/vfx/spark_06.png")
	vfx["circle"] = _tex("res://assets/dungeon/vfx/circle_05.png")
	vfx["smoke"] = _tex("res://assets/dungeon/vfx/smoke_08.png")
	vfx["magic"] = _tex("res://assets/dungeon/vfx/magic_05.png")
	vfx["fire"] = _tex("res://assets/dungeon/vfx/fire_02.png")
	vfx["flame"] = _tex("res://assets/dungeon/vfx/flame_02.png")
	vfx["dirt"] = _tex("res://assets/dungeon/vfx/dirt_01.png")
	vfx["twirl"] = _tex("res://assets/dungeon/vfx/twirl_03.png")
	ui["panel_brown"] = _tex("res://assets/dungeon/ui/panel_brown.png")
	ui["panel_beige"] = _tex("res://assets/dungeon/ui/panel_beige.png")
	ui["panel_inset"] = _tex("res://assets/dungeon/ui/panelInset_brown.png")
	ui["btn_brown"] = _tex("res://assets/dungeon/ui/buttonLong_brown.png")
	ui["btn_brown_down"] = _tex("res://assets/dungeon/ui/buttonLong_brown_pressed.png")
	ui["btn_beige"] = _tex("res://assets/dungeon/ui/buttonLong_beige.png")
	ui["btn_beige_down"] = _tex("res://assets/dungeon/ui/buttonLong_beige_pressed.png")
	ui["btn_blue"] = _tex("res://assets/dungeon/ui/buttonLong_blue.png")
	ui["btn_blue_down"] = _tex("res://assets/dungeon/ui/buttonLong_blue_pressed.png")
	ui["cursor_hand"] = _tex("res://assets/dungeon/ui/cursorHand_beige.png")
	for id in ITEM_PNG.keys():
		extra_items[str(id)] = _tex(str(ITEM_PNG[id]))
	for id2 in MONSTER_PNG.keys():
		extra_monsters[str(id2)] = _tex(str(MONSTER_PNG[id2]))


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func slice(name: String) -> AtlasTexture:
	if atlas == null or not rects.has(name):
		return null
	var at := AtlasTexture.new()
	at.atlas = atlas
	at.region = rects[name]
	at.filter_clip = true
	return at


func tile(name: String) -> Texture2D:
	return slice(name)


func frames(stem: String) -> Array:
	var out: Array = []
	for suffix in ["idle_anim", "anim", "run_anim", "open_anim"]:
		out = _seq(stem, suffix)
		if not out.is_empty():
			return out
	var one: AtlasTexture = slice(stem)
	if one != null:
		out.append(one)
	return out


func run_frames(stem: String) -> Array:
	var out: Array = _seq(stem, "run_anim")
	if out.is_empty():
		out = frames(stem)
	return out


func hit_frame(stem: String) -> Texture2D:
	var t: AtlasTexture = slice("%s_hit_anim_f0" % stem)
	if t != null:
		return t
	var idle: Array = frames(stem)
	if idle.is_empty():
		return null
	return idle[0]


func _seq(stem: String, suffix: String) -> Array:
	var out: Array = []
	for i in 8:
		var t: AtlasTexture = slice("%s_%s_f%d" % [stem, suffix, i])
		if t == null:
			break
		out.append(t)
	return out


func monster_stem(card_id: String) -> String:
	return str(MONSTER_STEM.get(card_id, ""))


func monster_idle(card_id: String) -> Array:
	if extra_monsters.has(card_id) and extra_monsters[card_id] != null:
		return [extra_monsters[card_id]]
	return frames(monster_stem(card_id))


func monster_run(card_id: String) -> Array:
	if extra_monsters.has(card_id) and extra_monsters[card_id] != null:
		return [extra_monsters[card_id]]
	return run_frames(monster_stem(card_id))


func monster_still(card_id: String) -> Texture2D:
	var idle: Array = monster_idle(card_id)
	if idle.is_empty():
		return null
	return idle[0]


func item_tex(card_id: String) -> Texture2D:
	if extra_items.has(card_id) and extra_items[card_id] != null:
		return extra_items[card_id]
	var name: String = str(ITEM_STEM.get(card_id, ""))
	if name == "":
		return null
	return slice(name)


func portraits() -> Dictionary:
	var d := {}
	for id in MONSTER_STEM.keys():
		var t: Texture2D = monster_still(str(id))
		if t != null:
			d[str(id)] = t
	return d
