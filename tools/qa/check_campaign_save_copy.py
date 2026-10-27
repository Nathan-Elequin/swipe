#!/usr/bin/env python3
"""Guard: CampaignShell._copy_state must not hard-index after disk.get(key, default).

Godot Dictionary.get("map_pieces", []) returns [] when the key is absent, so
`typeof(...) == TYPE_ARRAY` passes, then disk["map_pieces"] crashes. Older
user://campaign_save.json files omit keys added later.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "scripts" / "campaign_shell.gd"


def _copy_state_body(text: str) -> str:
    m = re.search(r"func _copy_state\(disk: Dictionary\) -> void:\n(.*?)(?=\nfunc |\nstatic func |\Z)", text, re.S)
    if not m:
        raise SystemExit("FAIL: _copy_state not found in campaign_shell.gd")
    return m.group(1)


def main() -> int:
    text = SRC.read_text(encoding="utf-8")
    body = _copy_state_body(text)
    # Antipattern: typeof(disk.get("key", default)) then later disk["key"]
    antipattern = re.compile(
        r'typeof\(disk\.get\("(?P<key>[^"]+)",\s*[^)]+\)\)\s*==\s*TYPE_\w+\s*:\s*\n'
        r'\s*state\["(?P=key)"\]\s*=\s*\(disk\["(?P=key)"\]',
        re.M,
    )
    hits = list(antipattern.finditer(body))
    if hits:
        keys = ", ".join(h.group("key") for h in hits)
        print(f"FAIL: _copy_state hard-indexes after disk.get default for: {keys}")
        return 1
    for key in ("banked", "seen_deadly", "mudroom_loadout", "run"):
        if f'disk.has("{key}")' not in body:
            print(f"FAIL: _copy_state missing disk.has(\"{key}\") guard")
            return 1
    if 'disk.get("map_pieces"' not in body and 'disk.has("map_pieces")' not in body:
        print("FAIL: _copy_state does not read map_pieces safely")
        return 1
    # Simulate the load path Python-side (same shape as Cherry old save).
    old = {
        "banked": {"goblin": "b1"},
        "drawer_seen": True,
        "endless_unlocked": False,
        "run": {"active": False},
        "seen_deadly": ["dragon"],
        "won": False,
    }
    fresh = {
        "banked": {},
        "seen_deadly": [],
        "map_pieces": [],
        "endless_unlocked": False,
        "endless_best": 0,
        "won": False,
        "drawer_seen": False,
        "pencil_fresh": [],
        "mudroom_loadout": [],
        "run": {"active": False},
    }
    state = dict(fresh)
    if "banked" in old and isinstance(old["banked"], dict):
        state["banked"] = dict(old["banked"])
    if "seen_deadly" in old and isinstance(old["seen_deadly"], list):
        state["seen_deadly"] = list(old["seen_deadly"])
    state["map_pieces"] = list(old.get("map_pieces", []))
    state["pencil_fresh"] = list(old.get("pencil_fresh", []))
    if "mudroom_loadout" in old and isinstance(old["mudroom_loadout"], list):
        state["mudroom_loadout"] = list(old["mudroom_loadout"])
    state["endless_unlocked"] = bool(old.get("endless_unlocked", False))
    state["endless_best"] = max(0, int(old.get("endless_best", 0)))
    state["won"] = bool(old.get("won", False))
    state["drawer_seen"] = bool(old.get("drawer_seen", False))
    if "run" in old and isinstance(old["run"], dict):
        state["run"] = dict(old["run"])
    assert state["banked"]["goblin"] == "b1"
    assert state["map_pieces"] == []
    assert state["mudroom_loadout"] == []
    assert state["endless_best"] == 0
    assert state["seen_deadly"] == ["dragon"]

    new = {
        "banked": {"net": "b1"},
        "map_pieces": ["b2", "b3"],
        "mudroom_loadout": ["smoke_bomb", "boot"],
        "endless_best": 4,
        "run": {"active": False, "biome_index": 2},
    }
    state2 = dict(fresh)
    if "banked" in new and isinstance(new["banked"], dict):
        state2["banked"] = dict(new["banked"])
    state2["map_pieces"] = list(new.get("map_pieces", []))
    if "mudroom_loadout" in new and isinstance(new["mudroom_loadout"], list):
        state2["mudroom_loadout"] = list(new["mudroom_loadout"])
    state2["endless_best"] = max(0, int(new.get("endless_best", 0)))
    if "run" in new and isinstance(new["run"], dict):
        state2["run"] = dict(new["run"])
    assert state2["map_pieces"] == ["b2", "b3"]
    assert state2["mudroom_loadout"] == ["smoke_bomb", "boot"]
    assert state2["endless_best"] == 4
    assert state2["run"]["biome_index"] == 2

    print("OK: campaign save copy is resilient to missing keys")
    return 0


if __name__ == "__main__":
    sys.exit(main())
