"""Insert Triclops into board, catalog, runtime, locks."""
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
TS = 1792434000.0
ABILITY = "If you have 3, 6, or 9 Items, you Always Spin me next"
FLOW = (
    "On any Spin (mill random, Challenge click, Flee, Magnet, Smoke), if a living unsilenced "
    "Triclops is on the wheel and your hand has exactly 3, 6, or 9 items, land on a random "
    "living Triclops. Smoke’s skip loses. Quiet Bell: no steal. Tutorial forced Spin still wins. "
    "Glow those slices while you are ready to Spin. Challenge: if you clicked a non-Triclops, "
    "Triclops says “Sorry, this fight is mine now” then you fight them."
)
TRI = {
    "id": "triclops",
    "name": "Triclops",
    "kind": "monster",
    "bucket": 8,
    "tier": 1,
    "count": 1,
    "priority": 3,
    "rarity": "uncommon",
    "status": "live",
    "review": "rough",
    "review_note": "",
    "author_lock": True,
    "locked_at": NOW,
    "locked_fields": LOCK,
    "mode_pool": "all",
    "card_color": "",
    "call_name": "Triple Threat",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "3, 6, or 9 items: Always Spin me next",
    "reminder": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 8. Three-eyed cyclops. Challenge sorry line is authored.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 3,
    "atk_formula": "",
    "hp_base": 3,
    "hp_formula": "",
    "contradiction_ids": [],
}


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def upsert(rows: list, news: list) -> None:
    have = {str(r.get("id")) for r in rows}
    for n in news:
        if n["id"] not in have:
            rows.append(n)
            have.add(n["id"])
        else:
            for i, r in enumerate(rows):
                if str(r.get("id")) == n["id"]:
                    rows[i] = n
                    break


def to_cat(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": 1, "priority": 3,
        "call_name": b.get("call_name", ""), "reminder": b.get("reminder", ""),
        "atk": {"base": int(b.get("atk_base") or 0)},
        "hp": {"base": int(b.get("hp_base") or 0)},
        "notes": b.get("notes", ""), "author_lock": True, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "poc": False, "rarity": "uncommon",
        "review": "rough", "review_note": "", "status": "live", "type": "M",
        "card_color": "", "flags": b.get("flags", {}), "ops": {},
    }


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")
    upsert(board["monsters"], [TRI])
    board["updated"] = NOW
    upsert(cat["monsters"], [to_cat(TRI)])
    if "triclops" not in run["monsters"]:
        run["monsters"].append("triclops")
    rec.setdefault("cards", {})
    rec["cards"]["monster:triclops"] = TS
    rec["updated"] = f"{NOW}T01:00:00"
    cards = locks.setdefault("cards", {})
    cards["monster:triclops"] = {"fields": LOCK, "locked_at": NOW, "name": "Triclops"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok triclops")


if __name__ == "__main__":
    main()
