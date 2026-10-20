"""Live mill + verb tags for the dense logic-QA suite."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CAT = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))

ART_ITEM = ROOT / "scripts" / "dungeon_art.gd"


def in_scope(c: dict) -> bool:
    st = str(c.get("status", "")).lower()
    hid = bool((c.get("flags") or {}).get("hide", False))
    cid = c.get("id", "")
    if cid == "smoke_bomb":
        return True
    if hid or st in ("retired", "hold", "todo"):
        return False
    return st == "live"


def _txt(c: dict) -> str:
    parts = [
        c.get("ability") or "",
        c.get("explainer") or "",
        c.get("flow") or "",
        c.get("notes") or "",
        c.get("call_name") or "",
        str((c.get("ops") or {}).get("kind") or ""),
    ]
    return " ".join(parts).lower()


def _has(blob: str, *needles: str) -> bool:
    return any(n in blob for n in needles)


def sprite_map() -> dict:
    text = (ROOT / "scripts" / "dungeon_art.gd").read_text(encoding="utf-8")
    out = {}
    for m in re.finditer(r'"([a-z0-9_]+)":\s*"res://(assets/dungeon/[^"]+)"', text):
        out[m.group(1)] = m.group(2)
    return out


SPRITES = sprite_map()


def tag_item(c: dict) -> dict:
    blob = _txt(c)
    ops = c.get("ops") or {}
    kind = str(ops.get("kind") or "")
    opts = ops.get("options") or []
    keep = "keep" in blob or any(bool(o.get("keep")) for o in opts if isinstance(o, dict))
    atk = kind.startswith("atk") or kind == "choose" or _has(blob, "atk ", "attack ")
    blk = kind.startswith("blk") or _has(blob, "block", "blk")
    heal = kind.startswith("heal") or "heal" in blob
    cheese = _has(blob, "defeat", "eject", "flee", "polymorph", "set hp", "hp to 1")
    target = _has(blob, "choose a", "pick a", "mark", "neighbor") and _has(
        blob, "monster", "enemy", "neighbor", "across"
    )
    unplayable = kind in ("passive",) or _has(blob, "unplayable")
    copy_last = _has(blob, "last item", "copy", "echo")
    hand_count = _has(blob, "item count", "items in", "cards in your", "hand")
    neighbor = _has(blob, "neighbor", "across", "opposite", "cleave")
    grant = _has(blob, "gain ", "grants", "put ", "add a")
    discard = _has(blob, "discard")
    return {
        "id": c["id"],
        "name": c.get("name") or c["id"],
        "ability": (c.get("ability") or "").strip(),
        "explainer": (c.get("explainer") or "").strip(),
        "kind": kind,
        "ops": ops,
        "atk": atk,
        "blk": blk,
        "heal": heal,
        "keep": keep,
        "cheese": cheese,
        "target": target or kind in ("mark", "crossbow", "hook_swap"),
        "unplayable": unplayable,
        "copy_last": copy_last,
        "hand_count": hand_count,
        "neighbor": neighbor,
        "grant": grant,
        "discard": discard,
        "n": ops.get("n"),
        "sprite": SPRITES.get(c["id"], ""),
        "bucket": int(c.get("bucket") or -1),
    }


def tag_monster(c: dict) -> dict:
    blob = _txt(c)
    hp = int((c.get("hp") or {}).get("base") or 0)
    atk = c.get("atk") or {}
    atk_base = atk.get("base")
    immune_atk = _has(blob, "cannot take attack", "no attack damage", "no atk damage", "evasive")
    pierce = _has(blob, "ignores block", "ignore block", "pierce")
    extra_swing = _has(blob, "twice", "attacks twice", "double hit", "extra swing")
    atk_eq_hp = _has(blob, "atk equal", "attack equal", "atk = hp", "atk equals")
    neighbor = _has(blob, "neighbor")
    on_spin = _has(blob, "when you spin", "when i am spun", "always", "on spin")
    on_done = _has(
        blob,
        "until i die",
        "i attack",
        "when you are done",
        "when you click done",
        "take the hit",
        "repeatedly",
    )
    on_hit = _has(blob, "when i take", "each time i take", "when you attack", "when you deal")
    on_you_hp = _has(blob, "when you lose hp", "when you bleed", "when you take")
    on_gain = _has(blob, "when you gain", "when you keep", "if you discard", "if you gain")
    flee = _has(blob, "flee")
    last = _has(blob, "last monster", "only monster", "last enemy")
    grant = _has(blob, "gain ", "grants", "give you", "put a")
    petrify = _has(blob, "petrify")
    silence = _has(blob, "silence")
    return {
        "id": c["id"],
        "name": c.get("name") or c["id"],
        "ability": (c.get("ability") or "").strip(),
        "explainer": (c.get("explainer") or "").strip(),
        "call_name": (c.get("call_name") or "").strip(),
        "hp": hp,
        "atk_base": None if atk_base in (None, "") else int(atk_base),
        "immune_atk": immune_atk,
        "pierce": pierce,
        "extra_swing": extra_swing,
        "atk_eq_hp": atk_eq_hp,
        "neighbor": neighbor,
        "on_spin": on_spin or bool((c.get("ability") or "").strip()),
        "on_done": on_done,
        "on_hit": on_hit,
        "on_you_hp": on_you_hp,
        "on_gain": on_gain,
        "flee": flee,
        "last": last,
        "grant": grant,
        "petrify": petrify,
        "silence": silence,
        "sprite": SPRITES.get(c["id"], ""),
        "bucket": int(c.get("bucket") or -1),
    }


# Cards the keyword pass gets wrong — last mill blocked list plus known verbs.
MONSTER_WHEN = {
    "shambling_mound": "on_done",
    "martyr": "on_done",
    "shark": "on_done",
    "druid": "on_done",
    "clockwork_knight": "on_done",
    "two_headed_serpent": "on_done",
    "ogre": "on_you_hp",
    "vampire": "on_you_hp",
    "lich": "neighbor",
    "commander": "neighbor",
    "wick": "neighbor",
    "bodyguard": "neighbor",
    "prism": "neighbor",
    "eel": "on_gain",
    "zombie": "on_gain",
    "hired_hand": "on_gain",
    "spider_queen": "on_spin",
    "juggernaut": "on_spin",
    "dire_wolf": "on_spin",
    "slime_boss": "on_hit",
    "needleback": "on_hit",
    "anvil": "on_hit",
    "goblin": "on_hit",
    "dragon": "on_done",
    "hornet_swarm": "on_done",
    "mouse": "on_spin",
    "basilisk": "on_spin",
    "hydra": "on_spin",
    "fairy": "on_spin",
    "bandit": "on_spin",
    "recycler": "discard",
}

ITEM_WHEN = {
    "hex": "unplayable",
    "double_buckler": "unplayable",
    "recycler": "discard",
    "crossbow": "target",
    "grappling_hook": "target",
    "signpost": "target",
    "throwing_knife": "choose",
    "counting_beads": "choose",
    "sai": "flip",
    "victory_flask": "on_defeat",
    "bag_of_holding": "hand_count",
    "echo_bell": "copy_last",
}


def items() -> list:
    return [tag_item(c) for c in CAT.get("items", []) if in_scope(c)]


def monsters() -> list:
    out = []
    for c in CAT.get("monsters", []):
        if not in_scope(c):
            continue
        t = tag_monster(c)
        when = MONSTER_WHEN.get(t["id"])
        if when == "on_done":
            t["on_done"] = True
        elif when == "on_you_hp":
            t["on_you_hp"] = True
        elif when == "neighbor":
            t["neighbor"] = True
        elif when == "on_gain":
            t["on_gain"] = True
        elif when == "on_hit":
            t["on_hit"] = True
        elif when == "on_spin":
            t["on_spin"] = True
        out.append(t)
    return out


def by_id(rows: list) -> dict:
    return {r["id"]: r for r in rows}


def card_ref(row: dict, kind: str) -> dict:
    return {
        "id": row["id"],
        "kind": kind,
        "name": row["name"],
        "ability": row.get("ability") or "",
        "sprite": row.get("sprite") or "",
    }
