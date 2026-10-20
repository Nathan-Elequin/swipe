"""Build constructed fights for every live unique ability not already in Bucket 0."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent / "mill-suite.json"

COVERED_ITEMS = {
    "throwing_knife",
    "shield",
    "sai",
    "da_boot",
    "crossbow",
    "sledgehammer",
    "victory_flask",
    "quiet_bell",
    "net",
    "smoke_bomb",
}
COVERED_MONSTERS = {
    "wizard",
    "golem",
    "goblin",
    "dire_wolf",
    "bandit",
    "slime_boss",
    "dragon",
    "needleback",
}

SPRITE = {
    "shield": "assets/dungeon/items/shield.png",
    "helmet": "assets/dungeon/items/helmet.png",
    "breastplate": "assets/dungeon/items/breastplate.png",
    "medallion": "assets/dungeon/items/medallion.png",
    "da_boot": "assets/dungeon/items/boot.png",
    "bloody_gauntlets": "assets/dungeon/items/bloody_gauntlets.png",
    "bracers": "assets/dungeon/items/bracers.png",
    "left_bracer": "assets/dungeon/items/left_bracer.png",
    "grimoire": "assets/dungeon/items/grimoire.png",
    "pocketwatch": "assets/dungeon/items/watch.png",
    "throwing_knife": "assets/dungeon/items/throwing_knife.png",
    "spiked_flail": "assets/dungeon/items/spiked_flail.png",
    "sledgehammer": "assets/dungeon/items/sledgehammer.png",
    "double_axe": "assets/dungeon/items/double_axe.png",
    "victory_flask": "assets/dungeon/items/victory_flask.png",
    "grappling_hook": "assets/dungeon/items/grappling_hook.png",
    "grief_jar": "assets/dungeon/items/grief_jar.png",
    "longbow": "assets/dungeon/items/longbow.png",
    "lantern": "assets/dungeon/items/lantern.png",
    "mirror_shard": "assets/dungeon/items/mirror_shard.png",
    "echo_bell": "assets/dungeon/items/echo_bell.png",
    "quiet_bell": "assets/dungeon/items/quiet_bell.png",
    "iron_chain": "assets/dungeon/items/iron_chain.png",
    "counting_beads": "assets/dungeon/items/counting_beads.png",
    "measuring_tape": "assets/dungeon/items/measuring_tape.png",
    "last_match": "assets/dungeon/items/last_match.png",
    "mute_stone": "assets/dungeon/items/mute_stone.png",
    "sai": "assets/dungeon/items/sai.png",
    "fangs": "assets/dungeon/items/fangs.png",
    "knucklers": "assets/dungeon/items/knucklers.png",
    "crossbow": "assets/dungeon/items/crossbow.png",
    "spiked_shield": "assets/dungeon/items/spiked_shield.png",
    "cursed_scroll": "assets/dungeon/items/cursed_scroll.png",
    "arrow_head": "assets/dungeon/items/arrow_head.png",
    "danger_magnet": "assets/dungeon/items/danger_magnet.png",
    "shuriken": "assets/dungeon/items/shuriken.png",
    "miasma": "assets/dungeon/items/miasma.png",
    "bag_of_marbles": "assets/dungeon/items/bag_of_marbles.png",
    "hex": "assets/dungeon/items/hex.png",
    "ale_flagon": "assets/dungeon/items/ale_flagon.png",
    "napalm": "assets/dungeon/items/napalm.png",
    "lucky_nickel": "assets/dungeon/items/lucky_nickel.png",
    "double_buckler": "assets/dungeon/items/double_buckler.png",
    "jar_o_grease": "assets/dungeon/items/jar_o_grease.png",
    "pacemaker": "assets/dungeon/items/pacemaker.png",
    "catapult": "assets/dungeon/items/catapult.png",
    "polymorph": "assets/dungeon/items/polymorph.png",
    "stone_wall": "assets/dungeon/items/stone_wall.png",
    "blood_chalice": "assets/dungeon/items/blood_chalice.png",
    "chakram": "assets/dungeon/items/chakram.png",
    "signpost": "assets/dungeon/items/signpost.png",
    "sling": "assets/dungeon/items/sling.png",
    "bag_of_holding": "assets/dungeon/items/bag_of_holding.png",
    "ball_and_chain": "assets/dungeon/items/ball_and_chain.png",
    "recycler": "assets/dungeon/items/recycler.png",
    "smoke_bomb": "assets/dungeon/items/smoke_bomb.png",
    "goblin": "assets/dungeon/extra/goblin.png",
    "kobold_trapper": "assets/dungeon/extra/kobold_trapper.png",
    "leech_league": "assets/dungeon/extra/leech_league.png",
    "wick": "assets/dungeon/extra/wick.png",
    "needleback": "assets/dungeon/extra/needleback.png",
    "gelatinous_cube": "assets/dungeon/extra/gelatinous_cube.png",
    "anvil": "assets/dungeon/extra/anvil.png",
    "dire_wolf": "assets/dungeon/extra/dire_wolf.png",
    "basilisk": "assets/dungeon/extra/basilisk.png",
    "wizard": "assets/dungeon/extra/wizard.png",
    "cleric": "assets/dungeon/extra/cleric.png",
    "skeleton": "assets/dungeon/extra/skeleton.png",
    "lich": "assets/dungeon/extra/lich.png",
    "vampire": "assets/dungeon/extra/vampire.png",
    "berserker": "assets/dungeon/extra/berserker.png",
    "bandit": "assets/dungeon/extra/bandit.png",
    "commander": "assets/dungeon/extra/commander.png",
    "bodyguard": "assets/dungeon/extra/bodyguard.png",
    "juggernaut": "assets/dungeon/extra/juggernaut.png",
    "two_headed_serpent": "assets/dungeon/extra/damsel.png",
    "beggar": "assets/dungeon/extra/beggar.png",
    "cowardly_king": "assets/dungeon/extra/cowardly_king.png",
    "merchant": "assets/dungeon/extra/merchant.png",
    "harpy": "assets/dungeon/extra/harpy.png",
    "gargoyle": "assets/dungeon/extra/gargoyle.png",
    "clockwork_knight": "assets/dungeon/extra/clockwork_knight.png",
    "golem": "assets/dungeon/extra/golem.png",
    "ogre": "assets/dungeon/extra/ogre.png",
    "dragon": "assets/dungeon/extra/dragon.png",
    "slime_boss": "assets/dungeon/extra/slime_boss.png",
    "spider_queen": "assets/dungeon/extra/spider.png",
    "hollow": "assets/dungeon/extra/hollow.png",
    "martyr": "assets/dungeon/extra/martyr.png",
    "prism": "assets/dungeon/extra/prism.png",
    "plague_doctor": "assets/dungeon/extra/plague_doctor.png",
    "hired_hand": "assets/dungeon/extra/hired_hand.png",
    "hydra": "assets/dungeon/extra/hydra.png",
    "zombie": "assets/dungeon/extra/zombie.png",
    "three_seeker": "assets/dungeon/extra/triclops.png",
    "shambling_mound": "assets/dungeon/extra/shambling_mound.png",
    "almighty_worm": "assets/dungeon/extra/almighty_worm.png",
    "cultist": "assets/dungeon/extra/cultist.png",
    "bushido": "assets/dungeon/extra/bushido.png",
    "shark": "assets/dungeon/extra/shark.png",
    "death_bell": "assets/dungeon/extra/death_bell.png",
    "triclops": "assets/dungeon/extra/triclops_v2.png",
    "phoenix_egg": "assets/dungeon/extra/phoenix_egg.png",
    "amalgam": "assets/dungeon/extra/amalgam.png",
    "fairy": "assets/dungeon/extra/fairy.png",
    "eel": "assets/dungeon/extra/eel.png",
    "druid": "assets/dungeon/extra/druid.png",
    "mouse": "assets/dungeon/extra/mouse.png",
    "magicat": "assets/dungeon/extra/magicat.png",
    "rust_bucket": "assets/dungeon/extra/rust_bucket.png",
    "poison_frog": "assets/dungeon/extra/poison_frog.png",
}


def in_scope(c):
    st = str(c.get("status", "")).lower()
    hid = bool((c.get("flags") or {}).get("hide", False))
    cid = c.get("id", "")
    if cid == "smoke_bomb":
        return True
    if hid or st in ("retired", "hold", "todo"):
        return False
    return st == "live"


def token(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", (name or "").lower()).strip().split(" ")[0]


def item_test(c):
    cid = c["id"]
    name = c.get("name") or cid
    ability = (c.get("ability") or "").strip()
    ops = c.get("ops") or {}
    kind = str(ops.get("kind") or "")
    n = ops.get("n")
    needs_neighbor = any(
        w in (ability + " " + kind).lower()
        for w in ("neighbor", "opposite", "across", "cleave", "polymorph", "hook", "signpost")
    )
    monsters = ["golem", "wizard"] if needs_neighbor else ["golem"]
    face = "golem"
    items = [cid]
    hp_before = None
    clicks = [{"op": "use", "item": cid, "auto": True}]
    expected = {"log_has": [token(name)]}
    expected_text = ability or name

    if kind.startswith("blk"):
        expected["blk_min"] = 1
        expected_text = f"{ability} Using it vs Golem must raise Block above 0."
    elif kind.startswith("atk") and n:
        dmg = int(n)
        if dmg < 7:
            expected["face_hp"] = 7 - dmg
            expected_text = f"{ability} Golem 7 HP must drop by {dmg}."
    elif kind.startswith("heal"):
        hp_before = 3
        expected["hp_min"] = 4
        expected_text = f"{ability} You start at 3 HP. After the click you must be at 4 or more."
    elif kind.startswith("defeat"):
        if "atk" in kind:
            monsters = ["dragon"]
            face = "dragon"
            expected_text = f"{ability} Dragon has 6 Attack, so this must Defeat."
            expected = {"log_has": ["defeat"]}
        elif "hp" in kind:
            monsters = ["wizard"]
            face = "wizard"
            expected = {"log_has": ["defeat"]}
            expected_text = f"{ability} Wizard 2 HP < your 6, so this must Defeat."
    elif kind == "quiet":
        monsters = ["goblin"]
        face = "goblin"
        expected_text = f"{ability} Goblin must lose Evasive."
    elif cid == "hex":
        clicks = []
        expected_text = f"{ability} Unplayable. Must still be in hand after Spin."
        expected = {"spent": {cid: False}}
    elif cid == "double_buckler":
        clicks = []
        expected_text = f"{ability} Unplayable. Must still be in hand after Spin."
        expected = {"spent": {cid: False}}
    elif cid == "counting_beads":
        expected["face_hp"] = 6
        expected_text = f"{ability} First option should deal 1. Golem 7→6."
    elif cid == "napalm":
        expected["face_hp"] = 1
        expected["hp"] = 1
        expected_text = f"{ability} Golem and you both become 1 HP."
    elif cid == "arrow_head":
        expected["face_hp"] = 1
        expected["hp"] = 4
        expected_text = f"{ability} Golem 7→1, you lose 2 HP (6→4)."

    test = {
        "id": f"uniq-{cid}",
        "title": f"{name} unique ability",
        "verbs": ["unique"],
        "monsters": monsters,
        "items": items,
        "face": face,
        "expected_text": expected_text,
        "clicks": clicks,
        "expected": expected,
    }
    if hp_before is not None:
        test["hp_before"] = hp_before
    return test


def monster_test(c):
    cid = c["id"]
    name = c.get("name") or cid
    ability = (c.get("ability") or "").strip()
    call = (c.get("call_name") or "").strip()
    hp = int((c.get("hp") or {}).get("base") or 0)
    atk = c.get("atk") or {}
    atk_base = atk.get("base")
    ab_l = ability.lower()
    needs_neighbor = any(
        w in ab_l for w in ("neighbor", "left", "right", "across")
    )
    monsters = [cid, "wizard"] if needs_neighbor else [cid]
    items = ["shield"]
    clicks = []
    expected = {}
    expected_text = ability or f"{name} printed stats."
    if ability:
        expected["log_has"] = [token(call or name)]
        expected_text = (
            f"{ability} After Spin this special must show in the log or change a number. "
            "If nothing changed, the unique ability did not fire."
        )
    else:
        if atk_base not in (None, ""):
            expected["face_atk"] = int(atk_base)
        if hp:
            expected["face_hp"] = hp
        expected_text = f"No unique ability. Printed ATK {atk_base} HP {hp}."

    hit = any(
        w in ab_l
        for w in (
            "each time i take",
            "when you attack",
            "when i take",
            "when you lose hp",
            "atk damage",
        )
    )
    if hit and cid not in COVERED_MONSTERS:
        items = ["throwing_knife"]
        clicks = [
            {"op": "use", "item": "throwing_knife"},
            {"op": "choose", "id": "nick", "atk": 1, "keep": True},
        ]
        expected_text = (
            f"{ability} Knife ATK 1 must make the special fire (a log line or a number change)."
        )

    # Mouse flees if you have more HP
    if cid == "mouse":
        expected = {"log_has": ["flee"]}
        expected_text = f"{ability} You have 6 HP > Mouse 4. Spin must Flee."
        clicks = []
        items = ["shield"]
    if cid == "juggernaut":
        expected = {"log_has": ["shield"]}
        expected_text = f"{ability} Spin must grant a Shield."
        clicks = []
    if cid == "fairy":
        expected = {"hp_min": 6}
        expected_text = f"{ability} Spin heals you 2. You start at 4, must become 6."
    if cid == "eel":
        items = ["shield"]
        clicks = [{"op": "use", "item": "shield", "auto": True}]
        expected = {"log_has": [token(name)]}
        expected_text = f"{ability} Gaining 4 Block while facing Eel must deal Attack to Eel."
    if cid == "anvil":
        items = ["throwing_knife"]
        clicks = [
            {"op": "use", "item": "throwing_knife"},
            {"op": "choose", "id": "throw", "atk": 3, "keep": False},
        ]
        expected = {"face_hp": max(0, hp - 1)}
        expected_text = f"{ability} Knife throw 3 must only remove 1 HP (Anvil {hp}→{hp-1})."
    if cid == "triclops":
        items = ["throwing_knife"]
        clicks = [
            {"op": "use", "item": "throwing_knife"},
            {"op": "choose", "id": "nick", "atk": 1, "keep": True},
        ]
        expected_text = f"{ability} A 1-damage nick must not fully Defeat (would Flee or drop 2 HP instead)."
        expected = {"log_has": [token(name)]}

    test = {
        "id": f"uniq-{cid}",
        "title": f"{name} unique ability",
        "verbs": ["unique"],
        "monsters": monsters,
        "items": items,
        "face": cid,
        "expected_text": expected_text,
        "clicks": clicks,
        "expected": expected,
    }
    if cid == "fairy":
        test["hp_before"] = 4
    return test


def main():
    cat = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))
    tests = []
    for c in cat.get("items", []):
        if not in_scope(c) or c["id"] in COVERED_ITEMS:
            continue
        tests.append(item_test(c))
    for c in cat.get("monsters", []):
        if not in_scope(c) or c["id"] in COVERED_MONSTERS:
            continue
        tests.append(monster_test(c))
    payload = {"id": "mill-unique", "tests": tests, "sprites": SPRITE}
    OUT.write_text(json.dumps(payload, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    print("wrote", OUT.name, "tests", len(tests))


if __name__ == "__main__":
    main()
