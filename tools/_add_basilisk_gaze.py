"""Rename old Basilisk → Zombie / Decay. Insert new Basilisk Petrifying Gaze."""
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
TS = 1792430000.0
ABILITY = "The first time you Spin me, I Flee and Petrify your top row of Items for 3 Spins."
FLOW = (
    "First Spin only. If Quiet Bell is on, I am a plain 4 ATK / 4 HP and the first time is spent. "
    "Otherwise Petrify the first 5 hotbar items (all of them if you hold fewer) with overlay and grey 3, "
    "then Flee (random Spin, I stay on the wheel). The follow-up Spin ticks 3 → 2. "
    "If that Spin lands me again, I stay and fight; first time is already used. "
    "Each Spin ticks petrify counts; at 0 they are clickable during that Spin before Gargoyle / Hydra. "
    "Later landings are a 4 / 4 fight. Fight only for the gaze. Decay (Zombie) is the old Famine rule."
)
GAZE = {
    "id": "basilisk",
    "name": "Basilisk",
    "kind": "monster",
    "bucket": 7,
    "tier": 3,
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
    "call_name": "Petrifying Gaze",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "First Spin: Flee, petrify top row for 3 Spins",
    "reminder": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 7. Uses the old Basilisk sprite. Flee Shift line. Grey countdown on petrified items.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 4,
    "atk_formula": "",
    "hp_base": 4,
    "hp_formula": "",
    "contradiction_ids": [],
}


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def write(p: Path, data: dict) -> None:
    p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def to_zombie(old: dict) -> dict:
    z = dict(old)
    z["id"] = "zombie"
    z["name"] = "Zombie"
    z["call_name"] = "Decay"
    z["kind"] = "monster"
    z["locked_at"] = NOW
    z["author_lock"] = True
    z["review_note"] = ""
    z["status"] = "live"
    notes = str(z.get("notes", "") or z.get("exceptions", ""))
    extra = "Renamed from Basilisk. New zombie art. Decay is the old Famine rule."
    if extra not in notes:
        z["notes"] = (notes + " " + extra).strip() if notes else extra
    flags = z.get("flags") if isinstance(z.get("flags"), dict) else {}
    flags = dict(flags)
    flags["art"] = True
    flags["dev"] = True
    z["flags"] = flags
    return z


def to_cat_monster(b: dict, atk: int, hp: int) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b.get("flow", b.get("defined", "")), "exceptions": b.get("notes", b.get("exceptions", "")),
        "log_hint": b.get("log_hint", ""), "bucket": b.get("bucket", 0), "tier": b.get("tier", 1),
        "count": 1, "priority": int(b.get("priority", 3) or 3),
        "call_name": b.get("call_name", ""), "reminder": b.get("reminder", ""),
        "atk": {"base": atk}, "hp": {"base": hp},
        "notes": b.get("notes", b.get("exceptions", "")), "author_lock": True, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "poc": False, "rarity": b.get("rarity", "uncommon"),
        "review": b.get("review", "rough"), "review_note": "", "status": "live", "type": "M",
        "card_color": b.get("card_color", ""), "flags": b.get("flags", {}), "ops": b.get("ops", {}),
    }


def replace_or_add(rows: list, card: dict) -> None:
    cid = str(card.get("id"))
    for i, r in enumerate(rows):
        if str(r.get("id")) == cid:
            rows[i] = card
            return
    rows.append(card)


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")

    old_board = None
    for r in board["monsters"]:
        if str(r.get("id")) == "basilisk" and str(r.get("call_name", "")) == "Famine":
            old_board = r
            break
    if old_board is None:
        for r in board["monsters"]:
            if str(r.get("id")) == "basilisk" and str(r.get("name", "")) == "Basilisk":
                old_board = r
                break
    if old_board is None:
        raise SystemExit("old basilisk not found on board")

    zombie = to_zombie(old_board)
    replace_or_add(board["monsters"], zombie)
    replace_or_add(board["monsters"], GAZE)
    board["updated"] = NOW

    old_cat = None
    for r in cat["monsters"]:
        if str(r.get("id")) == "basilisk" and str(r.get("call_name", "")) == "Famine":
            old_cat = r
            break
    if old_cat is None:
        for r in cat["monsters"]:
            if str(r.get("id")) == "basilisk":
                old_cat = r
                break
    z_cat = to_cat_monster(zombie, 4, 5)
    if old_cat:
        z_cat["ability"] = old_cat.get("ability", z_cat["ability"])
        z_cat["explainer"] = old_cat.get("explainer", z_cat["explainer"])
        z_cat["defined"] = old_cat.get("defined", z_cat["defined"])
        z_cat["atk"] = old_cat.get("atk", {"base": 4})
        z_cat["hp"] = old_cat.get("hp", {"base": 5})
        z_cat["bucket"] = old_cat.get("bucket", 5)
        z_cat["tier"] = old_cat.get("tier", 2)
    replace_or_add(cat["monsters"], z_cat)
    replace_or_add(cat["monsters"], to_cat_monster(GAZE, 4, 4))

    mons = run.setdefault("monsters", [])
    if "zombie" not in mons:
        mons.append("zombie")
    if "basilisk" not in mons:
        mons.append("basilisk")

    rec.setdefault("cards", {})
    rec["cards"]["monster:zombie"] = TS
    rec["cards"]["monster:basilisk"] = TS
    rec["updated"] = f"{NOW}T00:50:00"
    cards = locks.setdefault("cards", {})
    cards["monster:zombie"] = {"fields": LOCK, "locked_at": NOW, "name": "Zombie"}
    cards["monster:basilisk"] = {"fields": LOCK, "locked_at": NOW, "name": "Basilisk"}
    locks["updated"] = NOW

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok basilisk gaze + zombie")


if __name__ == "__main__":
    main()
