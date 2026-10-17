import json
from pathlib import Path

cat = json.loads(Path("data/catalog.json").read_text(encoding="utf-8"))
board = json.loads(Path("data/content-board.json").read_text(encoding="utf-8"))


def formulas(kind, cards):
    for c in cards:
        atk = c.get("atk", {})
        hp = c.get("hp", {})
        af = str(atk.get("formula", "")).strip() if isinstance(atk, dict) else ""
        hf = str(hp.get("formula", "")).strip() if isinstance(hp, dict) else ""
        if af or hf:
            print(f"{kind}:{c['id']:22} atk={af!r:60} hp={hf!r}")


print("=== CATALOG FORMULAS ===")
formulas("item", cat.get("items", []))
formulas("mon", cat.get("monsters", []))

print("\n=== BOARD ITEM NOTES / GOLD ===")
for c in board.get("items", []):
    notes = str(c.get("notes", "")).strip()
    rn = str(c.get("review_note", "")).strip()
    if not notes and not rn:
        continue
    print(c["id"], "status=", c.get("status"))
    print("  ability:", str(c.get("ability", ""))[:140])
    if notes:
        print("  notes:", notes[:220])
    if rn:
        print("  gold:", rn[:180].replace("\n", " | "))
    print()
