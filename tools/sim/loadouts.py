"""Named T1/T2 loadouts and random hand samplers for the balance sim."""

from __future__ import annotations

import random
from typing import Optional

from catalog_load import SUPPORTED_OPS, items_by_id, live_items


def _specs(by_id: dict, ids: list[str]) -> list[dict]:
    out = []
    for i in ids:
        if i not in by_id:
            continue
        out.append(by_id[i])
    return out


def named_loadouts(catalog: dict) -> dict[str, list[dict]]:
    """Common early-game hands Nathan / friends actually see."""
    by = items_by_id(catalog)
    sets = {
        # Pool-1 teaching core (Adventure openers)
        "t1_teach_knife_shield_net_smoke": ["throwing_knife", "shield", "net", "smoke_bomb"],
        "t1_knife_shield_sai_net": ["throwing_knife", "shield", "sai", "net"],
        "t1_bracers_knife_shield_boot": ["bracers", "throwing_knife", "shield", "da_boot"],
        "t1_boot_net_shield_knife": ["da_boot", "net", "shield", "throwing_knife"],
        # T2 combat packages
        "t2_fangs_crossbow_helmet_medallion": ["fangs", "crossbow", "helmet", "medallion"],
        "t2_flail_breastplate_knife_shield": ["spiked_flail", "breastplate", "throwing_knife", "shield"],
        "t2_fangs_boot_shield_net": ["fangs", "da_boot", "shield", "net"],
        "t2_sledge_knife_net_potion": ["sledgehammer", "throwing_knife", "net", "healing_potion"],
        "t2_lantern_flail_breastplate_knife": ["lantern", "spiked_flail", "breastplate", "throwing_knife"],
        "t2_gauntlets_helmet_fangs_shield": ["bloody_gauntlets", "helmet", "fangs", "shield"],
        # Glass / cheese
        "cheese_boot_sledge_fangs_smoke": ["da_boot", "sledgehammer", "fangs", "smoke_bomb"],
        "block_wall_shield_breastplate_net_helmet": ["shield", "breastplate", "net", "helmet"],
    }
    return {name: _specs(by, ids) for name, ids in sets.items() if _specs(by, ids)}


def random_loadout(
    catalog: dict,
    rng: random.Random,
    tiers: tuple[int, ...] = (1, 2),
    size: int = 4,
    require_supported: bool = True,
    always_include: Optional[list[str]] = None,
) -> list[dict]:
    pool = []
    for it in live_items(catalog):
        if it["pool"] < 0:
            continue
        if it["tier"] not in tiers and it["id"] != "smoke_bomb":
            continue
        if require_supported and not it["supported"]:
            continue
        # Skip neighbor-only in duel sampling noise
        if it["kind"] in ("blk_neighbor", "atk_opposite", "atk_last", "hypnotize"):
            continue
        pool.append(it)
    always = always_include or []
    by = items_by_id(catalog)
    picked = []
    seen = set()
    for aid in always:
        if aid in by and aid not in seen:
            picked.append(by[aid])
            seen.add(aid)
    rng.shuffle(pool)
    for it in pool:
        if it["id"] in seen:
            continue
        picked.append(it)
        seen.add(it["id"])
        if len(picked) >= size:
            break
    return picked[:size]


def loadout_label(specs: list[dict]) -> str:
    return "+".join(s["id"] for s in specs)
