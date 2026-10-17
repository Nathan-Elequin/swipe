import json
from pathlib import Path

board = json.loads(Path("data/content-board.json").read_text(encoding="utf-8"))
cat = json.loads(Path("data/catalog.json").read_text(encoding="utf-8"))
citems = {c["id"]: c for c in cat.get("items", []) if isinstance(c, dict)}
cmons = {c["id"]: c for c in cat.get("monsters", []) if isinstance(c, dict)}
rows = []
for kind, key in (("item", "items"), ("monster", "monsters")):
    for c in board.get(key, []):
        if not isinstance(c, dict):
            continue
        note = str(c.get("review_note", "") or "").strip()
        if not note:
            continue
        cid = c.get("id")
        catc = citems.get(cid) if kind == "item" else cmons.get(cid)
        rows.append(
            {
                "kind": kind,
                "id": cid,
                "name": c.get("name"),
                "status": c.get("status"),
                "review": c.get("review"),
                "ability": str(c.get("ability", "") or ""),
                "tier": c.get("tier"),
                "note": note,
                "cat_ability": str(catc.get("ability", "") or "") if catc else "NO CAT",
                "cat_status": catc.get("status") if catc else None,
            }
        )
print("COUNT", len(rows))
for i, r in enumerate(rows, 1):
    print("=" * 60)
    print(
        f"{i}. {r['kind']}:{r['id']}  name={r['name']!r}  status={r['status']} review={r['review']} tier={r['tier']}"
    )
    print("ABILITY:", r["ability"])
    print("CAT ABILITY:", r["cat_ability"])
    print("NOTE:")
    print(r["note"])
