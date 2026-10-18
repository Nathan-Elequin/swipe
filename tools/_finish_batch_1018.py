# Upsert 2026-10-18 batch cards. Mutate named rows; dump JSON with key order preserved.
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
LOCK = [
    "name", "ability", "explainer", "flow", "notes", "ops", "rarity", "tier",
    "count", "priority", "atk_base", "hp_base", "atk_formula", "hp_formula",
    "call_name", "reminder", "card_color", "log_hint",
]
NOW = "2026-10-18"
TS = 1792470000.0
BASILISK_FLOW = (
    "First Spin only. If Quiet Bell is on, I am a plain 4 ATK / 4 HP and the first time is spent. "
    "Otherwise Petrify every even-numbered item in the full hand, counting from the first position "
    "(2nd, 4th, 6th, …), with overlay and grey 3, then Flee (random Spin, I stay on the wheel). "
    "The follow-up Spin ticks 3 → 2. If that Spin lands me again, I stay and fight; first time is already used. "
    "Each Spin ticks petrify counts; at 0 they are clickable during that Spin before Gargoyle / Hydra. "
    "Later landings are a 4 / 4 fight. Fight only for the gaze. Decay (Zombie) is the old Famine rule."
)


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def write(p: Path, data: dict) -> None:
    p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def find(rows: list, cid: str) -> dict | None:
    for r in rows:
        if str(r.get("id")) == cid:
            return r
    return None


def upsert(rows: list, row: dict) -> None:
    cid = str(row["id"])
    for i, r in enumerate(rows):
        if str(r.get("id")) == cid:
            rows[i] = row
            return
    rows.append(row)


def patch(row: dict, **kw) -> None:
    row.update(kw)


def board_item(**kw) -> dict:
    row = {
        "id": "",
        "name": "",
        "kind": "item",
        "bucket": 0,
        "tier": 2,
        "count": 1,
        "priority": 3,
        "rarity": "uncommon",
        "status": "live",
        "review": "rough",
        "review_note": "",
        "author_lock": True,
        "locked_at": NOW,
        "locked_fields": LOCK[:],
        "mode_pool": "all",
        "card_color": "",
        "call_name": "",
        "ability": "",
        "explainer": "",
        "log_hint": "",
        "reminder": "",
        "ops": {},
        "flow": "",
        "notes": "Needs art.",
        "flags": {"art": False, "dev": True, "hide": False},
        "atk_base": None,
        "atk_formula": "",
        "hp_base": None,
        "hp_formula": "",
        "contradiction_ids": [],
    }
    row.update(kw)
    return row


def board_mon(**kw) -> dict:
    row = board_item(**kw)
    row["kind"] = "monster"
    row.setdefault("atk_base", 0)
    row.setdefault("hp_base", 0)
    row["flags"] = kw.get("flags", {"art": False, "dev": True, "hide": False})
    return row


def to_cat_i(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b.get("flow", ""), "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": int(b.get("bucket") or 0), "tier": int(b.get("tier") or 1),
        "count": int(b.get("count") if b.get("count") is not None else 1),
        "priority": int(b.get("priority") or 3), "card_color": b.get("card_color", ""),
        "ops": b.get("ops", {}), "flags": b.get("flags", {}), "notes": b.get("notes", ""),
        "author_lock": True, "locked_at": NOW, "locked_fields": LOCK[:],
        "mode_pool": b.get("mode_pool", "all"), "poc": False, "rarity": b.get("rarity", "uncommon"),
        "reminder": b.get("reminder", ""), "review": "rough", "review_note": "",
        "status": "live", "type": "I", "call_name": b.get("call_name", ""),
    }


def to_cat_m(b: dict) -> dict:
    row = to_cat_i(b)
    row["type"] = "M"
    row["call_name"] = b.get("call_name", "")
    row["atk"] = {"base": int(b.get("atk_base") or 0)}
    row["hp"] = {"base": int(b.get("hp_base") or 0)}
    row["card_color"] = ""
    return row


ITEMS = [
    board_item(
        id="pacemaker", name="Pacemaker", tier=2, card_color="heal",
        ability="When you lose exactly 2 HP, Heal 1. On Use, Lose 2 HP.",
        explainer="(HEAL 1 on exact-2 loss) Use: Lose 2",
        log_hint="Use: Lose 2 HP. Exact-2 loss: Heal 1",
        ops={"kind": "pacemaker_use"},
        flow=(
            "While this is in your hand unspent, each time you lose exactly 2 HP in one event, Heal 1. "
            "Click during a fight: Lose 2 HP (that also Heals 1), then this is used up. Fight only."
        ),
    ),
    board_item(
        id="catapult", name="Catapult", tier=2, mode_pool="challenge",
        ability="Eject your Enemy. Draw an Item.",
        explainer="Eject them. Draw 1.",
        log_hint="Eject facing enemy, draw an Item",
        ops={"kind": "eject_draw"},
        notes="Challenge only. Needs art.",
        flow=(
            "Challenge only. Click during a fight. Used up. The facing enemy leaves with no loot and Wick does not chip. "
            "They go to the bottom of the dungeon deck with permanent HP/ATK/poison. The empty seat fills from the deck; "
            "that arrival still gives you an item. War Cry-style passives do not stay as a number."
        ),
    ),
    board_item(
        id="polymorph", name="Polymorph", tier=3,
        ability="Turn your opponent into an exact copy of a Neighbor of your choice.",
        explainer="Copy a Neighbor onto the enemy you face.",
        log_hint="Facing enemy becomes a copy of a chosen Neighbor",
        ops={"kind": "polymorph"},
        notes="Spell scroll depicting a fluffy sheep. Needs art.",
        flow=(
            "Click during a fight, then click a living Neighbor. Used up. The facing enemy becomes that Neighbor’s card "
            "(name, art, ability) with that Neighbor’s current HP, max HP, ATK minus Commander aura, and marked poison. "
            "Seat auras recalculate. No Neighbor: unplayable."
        ),
    ),
    board_item(
        id="stone_wall", name="Stone Wall", tier=3, card_color="blk",
        ability="Block 10. Retain leftover block from this combat.",
        explainer="(BLK 10) leftover stays for the next fight",
        log_hint="Block 10, leftover remains for the next fight",
        ops={"kind": "blk", "n": 10},
        flow="Click during a fight. Gain 10 Block. Used up. Leftover Block after this fight stays for the next fight only, then clears.",
    ),
    board_item(
        id="blood_chalice", name="Blood Chalice", tier=2, card_color="heal",
        ability="Heal equal to the amount of HP you most recently lose.",
        explainer="(HEAL = last HP lost)",
        log_hint="Heal equal to last HP lost",
        ops={"kind": "heal_last_loss"},
        flow="Click during a fight. Used up. Heal equal to the last HP-loss event this dungeon. If you have not lost HP yet, unplayable.",
    ),
]

MONSTERS = [
    board_mon(
        id="three_seeker", name="3-Seeker", bucket=8, tier=1, atk_base=3, hp_base=3,
        call_name="Triple Threat",
        ability="If you have 3, 6, or 9 Items, you Always Spin me next",
        explainer="If you have 3, 6, or 9 Items, you Always Spin me next",
        log_hint="3, 6, or 9 items: Always Spin me next",
        flags={"art": True, "dev": True, "hide": False},
        notes="Archived Triclops. Triple Threat. Uses the Triclops sprite.",
        flow=(
            "On any Spin (mill random, Challenge click, Flee, Magnet, Smoke), if a living unsilenced 3-Seeker is on the wheel "
            "and your hand has exactly 3, 6, or 9 items, land on a random living 3-Seeker. Smoke’s skip loses. Quiet Bell: no steal. "
            "Tutorial forced Spin still wins. Glow those slices while you are ready to Spin. Challenge: if you clicked a non-3-Seeker, "
            "3-Seeker says “Sorry, this fight is mine now” then you fight them."
        ),
    ),
    board_mon(
        id="triclops", name="Triclops", bucket=5, tier=2, atk_base=4, hp_base=7,
        call_name="",
        ability="If I have 3 HP, I am Defeated. If I would be Defeated in any other way, I instead lose 2 HP and Flee.",
        explainer="3 HP: Defeated. Else Defeat: −2 HP and Flee",
        log_hint="3 HP dies. Other Defeat: −2 and Flee",
        notes="Bucket 5. New Triclops. Needs new art. 3-Seeker keeps Triple Threat.",
        flow=(
            "If my HP is exactly 3, I am Defeated (loot). If something else would Defeat or Slay me (0 HP, Boot, Hex), "
            "I instead lose 2 HP from the HP I had before that Defeat and Flee. After that Flee, if I have 3 HP, I am Defeated. "
            "Quiet Bell turns this off."
        ),
    ),
    board_mon(
        id="phoenix_egg", name="Phoenix Egg", bucket=4, tier=3, atk_base=2, hp_base=2,
        call_name="Hatch",
        ability="When I am Defeated, I Flee and hatch into a Phoenix.",
        explainer="Defeated: Flee, become Phoenix",
        log_hint="Defeated: Flee, become Phoenix",
        notes="Bucket 4. Needs art. Hatches into Phoenix.",
        flow="When Defeated or Slain, Flee (if you are facing me) and this seat becomes Phoenix at 4 HP / 6 ATK. Quiet Bell turns this off.",
    ),
    board_mon(
        id="phoenix", name="Phoenix", bucket=0, tier=3, atk_base=6, hp_base=4, count=0,
        call_name="Rebirth",
        ability="If I am Defeated or Slain before I Attack, I Flee and turn into a Phoenix Egg.",
        explainer="Defeated or Slain before Attack: Flee, become Egg",
        log_hint="Before Attack: Flee, become Egg",
        flags={"art": False, "dev": True, "hide": True},
        notes="Token. Not drafted. Phoenix Egg creates it. Needs art.",
        flow=(
            "Token. If Defeated or Slain before I Attack, Flee (if you are facing me) and this seat becomes Phoenix Egg at 2 HP / 2 ATK. "
            "After I Attack, Defeat and Slay are real. Quiet Bell turns this off."
        ),
    ),
    board_mon(
        id="amalgam", name="Amalgam", bucket=6, tier=3, atk_base=5, hp_base=6,
        call_name="Adaptation",
        ability="After any Item you Use, double my remaining HP and ATK.",
        explainer="Each Use: remaining HP and ATK ×2",
        log_hint="Each Use: remaining HP and ATK ×2",
        notes="Bucket 6. Plasmoid science experiment, distinct from Gelatinous Cube. Needs art.",
        flow="While you face me and I am not silenced, after each Item Use, my current HP, max HP, and ATK each double.",
    ),
    board_mon(
        id="fairy", name="Fairy", bucket=3, tier=1, atk_base=3, hp_base=1,
        call_name="Fairy Dust",
        ability="I Heal you and my Neighbors for 2 HP.",
        explainer="On Spin: Heal you and Neighbors 2",
        log_hint="On Spin: Heal you and Neighbors 2",
        notes="Bucket 3. Needs art.",
        flow="On Spin onto me, if I am not silenced, Heal you 2 and Heal each Neighbor 2, then the fight happens. Quiet Bell turns this off.",
    ),
    board_mon(
        id="eel", name="Eel", bucket=0, tier=1, atk_base=6, hp_base=4,
        call_name="Conductive",
        ability="When facing me, I take Attack damage equal to Block you gain.",
        explainer="Facing: takes Attack = Block you Gain",
        log_hint="Facing: takes Attack = Block you Gain",
        notes="Tier 1. No numbered bucket named. Needs art.",
        flow="While you face me and I am not silenced, each time you Gain Block, I take that much Attack damage (Needleback and Harpy still apply). Quiet Bell turns this off.",
    ),
    board_mon(
        id="druid", name="Druid", bucket=3, tier=2, atk_base=7, hp_base=4,
        call_name="Cultivator",
        ability="If I Attack, I Heal you for double the HP I cause you to lose.",
        explainer="Attack: Heal you 2× HP lost, after death check",
        log_hint="Attack: Heal you 2× HP you lost",
        notes="Bucket 3. Needs art.",
        flow="When I Attack, death is checked first. If you still live, Heal twice the HP you actually lost from that Attack. Fully blocked: Heal 0. Quiet Bell turns this off.",
    ),
]


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")

    basilisk_b = find(board["monsters"], "basilisk")
    if basilisk_b:
        patch(basilisk_b, flow=BASILISK_FLOW)
    basilisk_c = find(cat["monsters"], "basilisk")
    if basilisk_c:
        patch(basilisk_c, defined=BASILISK_FLOW)

    ss_b = find(board["items"], "spiked_shield")
    if ss_b:
        patch(
            ss_b,
            ability="Gain Block equal to your highest Attack Item",
            explainer="(BLK = highest Attack Item)",
            flow="Click during a fight. Gain Block equal to the highest Attack number among items in your hand. Used up. Unplayable if no Attack item.",
            ops={"kind": "blk_from_highest_atk"},
            tier=2,
            log_hint="Block equal to highest Attack Item",
        )
    ss_c = find(cat["items"], "spiked_shield")
    if ss_c:
        patch(ss_c, tier=2, defined=ss_b["flow"] if ss_b else ss_c.get("defined", ""))

    sled_c = find(cat["items"], "sledgehammer")
    if sled_c:
        sled_c["usable_when"] = "enemy_atk >= 6"

    for row in ITEMS:
        upsert(board["items"], row)
        upsert(cat["items"], to_cat_i(row))
    for row in MONSTERS:
        upsert(board["monsters"], row)
        upsert(cat["monsters"], to_cat_m(row))

    cat.setdefault("keywords", {})
    cat["keywords"]["any"] = "select any Monster on the wheel"
    cat["keywords"]["eject"] = (
        "remove them from the dungeon immediately, placing them on the bottom of the Dungeon Deck"
    )

    board["updated"] = NOW

    for iid in ["pacemaker", "catapult", "polymorph", "stone_wall", "blood_chalice"]:
        if iid not in run["items"]:
            run["items"].append(iid)
    for mid in ["three_seeker", "phoenix_egg", "amalgam", "fairy", "eel", "druid"]:
        if mid not in run["monsters"]:
            run["monsters"].append(mid)
    # phoenix is a token; triclops stays in the pool as the new card

    rec.setdefault("cards", {})
    rec["updated"] = f"{NOW}T16:00:00"
    cards = locks.setdefault("cards", {})
    for row in ITEMS:
        key = f"item:{row['id']}"
        rec["cards"][key] = TS
        cards[key] = {"fields": LOCK[:], "locked_at": NOW, "name": row["name"]}
    for row in MONSTERS:
        key = f"monster:{row['id']}"
        rec["cards"][key] = TS
        cards[key] = {"fields": LOCK[:], "locked_at": NOW, "name": row["name"]}
    for extra_key, extra_name in [
        ("item:spiked_shield", "Spiked Shield"),
        ("item:sledgehammer", "Sledgehammer"),
        ("item:double_axe", "Great Axe"),
        ("item:jar_o_grease", "Jar O' Grease"),
        ("item:medallion", "Medallion"),
        ("monster:vampire", "Vampire"),
        ("monster:basilisk", "Basilisk"),
        ("monster:juggernaut", "Juggernaut"),
    ]:
        rec["cards"][extra_key] = TS
        if extra_key not in cards:
            cards[extra_key] = {"fields": LOCK[:], "locked_at": NOW, "name": extra_name}
        else:
            cards[extra_key]["locked_at"] = NOW
            cards[extra_key]["name"] = extra_name
    locks["updated"] = NOW

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok batch 1018", len(ITEMS), "items", len(MONSTERS), "monsters")


if __name__ == "__main__":
    main()
