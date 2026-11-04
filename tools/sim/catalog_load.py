"""Load live items/monsters from data/catalog.json for the balance sim."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
CATALOG_PATH = REPO_ROOT / "data" / "catalog.json"

# Monster specials the sim understands (id -> tag).
KNOWN_SPECIALS = {
    "goblin": "no_atk_dmg",
    "dragon": "pierce",
    "hornet_swarm": "double_hit",
    "harpy": "impatient",
    "shark": "blood_thresh",
}

# Item ops the combat model can execute.
SUPPORTED_OPS = {
    "blk",
    "atk",
    "choose",
    "defeat_hp",
    "fangs",
    "atk_hp_loss",
    "blk_keep",
    "heal_keep",
    "passive",
    "atk_7_hp",
    "blk_from_hp",
    "blk_min_hp",
    "atk_alt_24",
    "shield_alt",
    "defeat_atk",
    "heal",
    "smoke",
    "atk_neighbor",  # treated as facing ATK in single-monster duels
    "atk_cleave",  # facing only
    "atk_opposite",  # no-op in single duel (flagged)
    "blk_neighbor",  # 0 without neighbors
    "heal_kills",
    "flee_then_blk",
}


def _base_stat(node: Any, default: int = 0) -> int:
    if node is None:
        return default
    if isinstance(node, (int, float)):
        return int(node)
    if isinstance(node, dict):
        if "base" in node and node["base"] is not None:
            return int(node["base"])
    return default


def load_catalog(path: Path | None = None) -> dict:
    p = path or CATALOG_PATH
    with p.open(encoding="utf-8") as f:
        return json.load(f)


def player_hp_max(catalog: dict) -> int:
    player = catalog.get("player") or {}
    return int(player.get("hp_max") or player.get("hp_start") or 6)


def live_items(catalog: dict) -> list[dict]:
    out = []
    for it in catalog.get("items") or []:
        status = str(it.get("status") or "live")
        if status in ("retired", "hold"):
            continue
        ops = it.get("ops") if isinstance(it.get("ops"), dict) else {}
        kind = ops.get("kind")
        # Hardcoded engine ops that catalog left empty.
        if not kind:
            fallback = {
                "fangs": "fangs",
                "breastplate": "blk_keep",
                "smoke_bomb": "smoke",
                "healing_potion": "passive",
                "grimoire": "atk_last",
                "pocketwatch": "hypnotize",
            }.get(str(it.get("id")))
            if fallback:
                ops = dict(ops)
                ops["kind"] = fallback
                if fallback == "blk_keep":
                    ops.setdefault("n", 2)
                kind = fallback
        entry = {
            "id": str(it.get("id")),
            "name": str(it.get("name") or it.get("id")),
            "tier": int(it.get("tier") or 0),
            "pool": int(it.get("pool") or 0),
            "status": status,
            "ability": str(it.get("ability") or ""),
            "ops": ops,
            "kind": kind,
            "supported": bool(kind) and kind in SUPPORTED_OPS,
        }
        out.append(entry)
    return out


def live_monsters(catalog: dict) -> list[dict]:
    out = []
    for m in catalog.get("monsters") or []:
        status = str(m.get("status") or "live")
        if status in ("retired", "hold"):
            continue
        mid = str(m.get("id"))
        special = KNOWN_SPECIALS.get(mid)
        model = "full" if special else "stats_only"
        # Token / aside pools still included if live; mark them.
        pool = int(m.get("pool") or 0)
        if pool < 0:
            model = "token_" + model
        atk = _base_stat(m.get("atk"), 0)
        # Formula ATK monsters (catalog base may be 0 / null).
        if mid == "slime_boss":
            atk = _base_stat(m.get("hp"), 0)
            special = "atk_eq_hp"
            model = "simplified"
        elif mid == "dire_wolf":
            atk = 0  # set to player HP at swing time
            special = "kill_shot"
            model = "simplified"
        elif mid == "bandit":
            atk = 0  # +1 per live item at fight start
            special = "hoarder"
            model = "simplified"
        entry = {
            "id": mid,
            "name": str(m.get("name") or mid),
            "tier": int(m.get("tier") or 0),
            "pool": pool,
            "status": status,
            "hp": _base_stat(m.get("hp"), 1),
            "atk": atk,
            "ability": str(m.get("ability") or ""),
            "call_name": str(m.get("call_name") or ""),
            "special": special,
            "model": model,
        }
        out.append(entry)
    return out


def items_by_id(catalog: dict) -> dict[str, dict]:
    return {it["id"]: it for it in live_items(catalog)}


def monsters_by_id(catalog: dict) -> dict[str, dict]:
    return {m["id"]: m for m in live_monsters(catalog)}


def focus_monsters(catalog: dict) -> list[dict]:
    """Named cast from the task brief, plus a few common Pool-1 baselines."""
    want = [
        "shark",
        "harpy",
        "dragon",
        "golem",
        "goblin",
        "hornet_swarm",
        "ogre",
        "wizard",
        "needleback",
        "vampire",
        "dire_wolf",
        "slime_boss",
        "bandit",
        "mimic",
    ]
    by = monsters_by_id(catalog)
    out = []
    for wid in want:
        if wid in by:
            out.append(by[wid])
    return out
