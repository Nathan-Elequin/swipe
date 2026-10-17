"""Apply gold-box official-field overwrites, then clear shipped notes."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
BOARD = ROOT / "data" / "content-board.json"
CATALOG = ROOT / "data" / "catalog.json"
RECENT = ROOT / "data" / "recent-edits.json"

FIELD_UPDATES = {
    "item:last_match": {
        "name": "Paci-Fist",
        "ability": "If you have zero items that deal Atk damage, Defeat the enemy.",
    },
    "item:mute_stone": {
        "ability": "Choose 2 Items and replace them with random Items of the same Tier.",
    },
    "monster:leech_league": {
        "ability": "On Spin, repeatedly Heals the Lowest HP Monster until it equals the HP of another Monster.",
        "explainer": "Lowest HP Monster +1 until tied with another",
        "status": "live",
    },
    "monster:hollow": {
        "ability": "Attack or Block values that are Even happen twice against me.",
    },
    "item:fangs": {"status": "live"},
    "monster:commander": {"status": "live"},
}

# Spider Queen stays filled — Paper Fight this turn.
CLEAR_NOTES = [
    "item:bloody_gauntlets",
    "item:left_bracer",
    "item:fangs",
    "item:lantern",
    "item:mirror_shard",
    "item:echo_bell",
    "item:quiet_bell",
    "item:net",
    "item:iron_chain",
    "item:counting_beads",
    "item:last_match",
    "item:mute_stone",
    "monster:ogre",
    "monster:berserker",
    "monster:two_headed_serpent",
    "monster:leech_league",
    "monster:commander",
    "monster:gelatinous_cube",
    "monster:gargoyle",
    "monster:harpy",
    "monster:kobold_trapper",
    "monster:clockwork_knight",
    "monster:basilisk",
    "monster:hollow",
    "monster:beggar",
    "monster:wick",
    "monster:anvil",
]


def _kind_id(key: str) -> tuple[str, str]:
    kind, cid = key.split(":", 1)
    return kind, cid


def _find(blob: dict, kind: str, cid: str) -> dict | None:
    arr_key = "items" if kind == "item" else "monsters"
    for row in blob.get(arr_key, []):
        if str(row.get("id", "")) == cid:
            return row
    return None


def patch_file(path: Path) -> list[str]:
    blob = json.loads(path.read_text(encoding="utf-8"))
    touched: list[str] = []
    for key, fields in FIELD_UPDATES.items():
        kind, cid = _kind_id(key)
        row = _find(blob, kind, cid)
        if row is None:
            print("MISSING", path.name, key)
            continue
        for fk, fv in fields.items():
            row[fk] = fv
        touched.append(key)
    for key in CLEAR_NOTES:
        kind, cid = _kind_id(key)
        row = _find(blob, kind, cid)
        if row is None:
            continue
        row["review_note"] = ""
        if str(row.get("status", "")) == "todo":
            row["status"] = "live"
        touched.append(key)
    path.write_text(json.dumps(blob, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    return sorted(set(touched))


def stamp_recent(keys: list[str]) -> None:
    blob = json.loads(RECENT.read_text(encoding="utf-8"))
    now = datetime.now(timezone.utc)
    cards = blob.setdefault("cards", {})
    for key in keys:
        cards[key] = now.timestamp()
    blob["updated"] = now.strftime("%Y-%m-%dT%H:%M:%S")
    RECENT.write_text(json.dumps(blob, indent="\t") + "\n", encoding="utf-8")


def main() -> None:
    a = patch_file(BOARD)
    b = patch_file(CATALOG)
    keys = sorted(set(a + b))
    stamp_recent(keys)
    print("patched", len(keys), "cards")
    for k in keys:
        print(" ", k)


if __name__ == "__main__":
    main()
