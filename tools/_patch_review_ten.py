import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")

PATCH = {
    "lantern": {
        "tier": 3,
        "ability": "Heal 2. Keep this if you are still missing HP.",
        "explainer": "(HEAL 2) then KEEP if HP < 6",
        "flow": "Click during a fight. Heal 2, cap 6. If HP is still below 6, keep the card. If you are already at 6, heal 0 and the card is used up. Counts as an item use.",
        "notes": "Breastplate keeps if you bled. This keeps if you are still hurt after the heal.",
        "ops": {"kind": "heal_keep", "n": 2},
    },
    "mirror_shard": {
        "tier": 2,
        "ability": "Gain Block equal to the last Block you gained.",
        "explainer": "(Last Block gained)",
        "flow": "Click during a fight. Gain Block equal to the last Block you gained this dungeon. If you have not gained Block yet this dungeon, the click does nothing and the card stays. Used up. Counts as an item use.",
        "notes": "Last Block is the amount from the last time you gained Block, not your current Block total.",
        "ops": {"kind": "blk_last"},
    },
    "net": {
        "tier": 1,
        "ability": "Reduce the facing owner's Attack by 1, 2, or 3.",
        "explainer": "(−1) or (−2) or (−3)",
        "flow": "Click during a fight, then click 1, 2, or 3. Facing Attack drops by that much after every other formula including Commander, floors at 0, then locks for the rest of this fight. Used up.",
        "notes": "Caltrops is retired. This is the milder version, last in calc.",
        "ops": {
            "kind": "choose",
            "options": [
                {"id": "drop1", "label": "−1 Attack", "atk_drop": 1},
                {"id": "drop2", "label": "−2 Attack", "atk_drop": 2},
                {"id": "drop3", "label": "−3 Attack", "atk_drop": 3},
            ],
        },
    },
    "echo_bell": {
        "tier": 3,
        "ability": "Becomes a copy of the last item you used.",
        "explainer": "(Copy last item)",
        "flow": "In hand this looks like the last item you used this dungeon (faint Echo icon). Click it to use that copy, then Echo is used up even if the original had Keep. If you have not used an item this dungeon, it is Unplayable.",
        "notes": "Updates when you use an item. Cube feed is not an item use. First fight of a run: Unplayable.",
        "ops": {"kind": "echo"},
    },
    "quiet_bell": {
        "tier": 2,
        "ability": "Remove the facing owner's unique ability.",
        "explainer": "(Printed ATK / HP)",
        "flow": "Click during a fight. That owner id loses its unique ability and formulas for the rest of this dungeon. They show printed ATK/HP like Golem. If they have no unique ability, the click does nothing and the card stays. Used up otherwise.",
        "notes": "Golem: cannot click. Bandit and other formulas fall back to the ATK/HP columns.",
        "ops": {"kind": "quiet"},
    },
    "caltrops": {"status": "retired"},
    "gelatinous_cube": {
        "ability": "I make you feed me one of two items.",
        "explainer": "Feed me one",
        "flow": "On spin, if you have 0 items, nothing. If 1, you must feed that one. If 2 or more, two random items are offered and you must feed one. The discard is not an item use. ATK/HP unchanged.",
        "notes": "Not an item use: no Kobold extra, no Echo update, no Harpy after the feed.",
    },
    "gargoyle": {
        "tier": 2,
        "ability": "I petrify your highest Attack item until you Spin again.",
        "explainer": "Petrify highest ATK",
        "flow": "After spin numbers, the highest Attack item in hand becomes Unplayable until the next Spin. Tie is random. No Attack items: nothing. Longbow and Spiked Shield count. Boot and Poison Flask do not. Smoke is a new Spin, so it clears. Attack still works. Cannot be Defeated unless Quiet Bell has silenced me.",
        "notes": "Petrify tooltip: Unplayable until your next Spin.",
    },
    "harpy": {
        "ability": "I attack you when we meet, and after each item you use.",
        "explainer": "Interrupt 1 swing",
        "flow": "On spin, one swing of my current Attack (Block works). After each item fully resolves, if I am still alive, one more swing. Ceases when you click Done or I am Defeated/Slain. Done still takes the normal hit. Not Attack = Block.",
        "notes": "One swing, fight stays open. If an item already killed me, no extra swing.",
        "atk_formula": "",
        "atk_base": 2,
        "hp_base": 6,
    },
    "kobold_trapper": {
        "tier": 2,
        "ability": "I attack an extra time for each item you use this fight.",
        "explainer": "(1 + items used)",
        "flow": "On Done, swing count is 1 plus items used this fight. Cube feed does not count. Block is spent per swing.",
        "notes": "0 items = 1 swing. 2 items = 3 swings.",
    },
    "clockwork_knight": {
        "ability": "If I live, I leave two Tier 2 owners in my place.",
        "explainer": "Two Tier 2 if I live",
        "flow": "If you do not Defeat or Slay me, I leave and two random Tier 2 owners sit immediately, even if that grows the wheel past 8. You are not in a new fight yet. Attack still uses owners left while I am on the wheel.",
        "notes": "Quiet Bell strips this: I leave like anyone else, no heirs.",
    },
}


def patch_arr(arr, is_catalog=False):
    for c in arr:
        cid = str(c.get("id", ""))
        if cid not in PATCH:
            continue
        for k, v in PATCH[cid].items():
            if k == "flow" and is_catalog:
                c["defined"] = v
            elif k == "notes" and is_catalog:
                c["exceptions"] = v
            elif k == "atk_formula":
                if is_catalog:
                    atk = c.get("atk", {})
                    if isinstance(atk, dict):
                        atk.pop("formula", None)
                        c["atk"] = atk
                else:
                    c[k] = v
            elif k == "atk_base":
                if is_catalog:
                    atk = c.get("atk") if isinstance(c.get("atk"), dict) else {}
                    atk["base"] = v
                    c["atk"] = atk
                else:
                    c[k] = v
            elif k == "hp_base":
                if is_catalog:
                    hp = c.get("hp") if isinstance(c.get("hp"), dict) else {}
                    hp["base"] = v
                    c["hp"] = hp
                else:
                    c[k] = v
            else:
                c[k] = v
        if cid == "caltrops":
            c["status"] = "retired"
            flags = c.get("flags") if isinstance(c.get("flags"), dict) else {}
            flags["hide"] = True
            flags["dev"] = False
            c["flags"] = flags
        else:
            c["status"] = "live"


def run():
    board_p = ROOT / "data" / "content-board.json"
    cat_p = ROOT / "data" / "catalog.json"
    run_p = ROOT / "data" / "runtime.json"
    board = json.loads(board_p.read_text(encoding="utf-8"))
    cat = json.loads(cat_p.read_text(encoding="utf-8"))
    runtime = json.loads(run_p.read_text(encoding="utf-8"))
    patch_arr(board.get("items", []), False)
    patch_arr(board.get("monsters", []), False)
    patch_arr(cat.get("items", []), True)
    patch_arr(cat.get("monsters", []), True)
    items = [i for i in runtime.get("items", []) if i != "caltrops"]
    if "net" not in items:
        items.append("net")
    runtime["items"] = items
    # Ensure catalog has net if only board had it
    cat_ids = {str(c.get("id")) for c in cat.get("items", [])}
    if "net" not in cat_ids:
        for c in board.get("items", []):
            if str(c.get("id")) == "net":
                cat["items"].append(
                    {
                        "id": "net",
                        "name": "Net",
                        "type": "I",
                        "ability": c.get("ability", ""),
                        "explainer": c.get("explainer", ""),
                        "defined": c.get("flow", ""),
                        "exceptions": c.get("notes", ""),
                        "ops": c.get("ops", {}),
                        "rarity": "uncommon",
                        "tier": 1,
                        "count": 1,
                        "priority": 2,
                        "review": "refined",
                        "review_note": c.get("review_note", ""),
                        "flags": {"art": True, "dev": True, "hide": False},
                    }
                )
                break
    board_p.write_text(json.dumps(board, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    cat_p.write_text(json.dumps(cat, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    run_p.write_text(json.dumps(runtime, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    print("patched")


run()
