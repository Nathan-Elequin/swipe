# -*- coding: utf-8 -*-
import json
from pathlib import Path

root = Path(r"C:\Users\Natha\Documents\boss-rush")
board = json.loads((root / "data" / "content-board.json").read_text(encoding="utf-8"))
locks = json.loads((root / "data" / "author-locks.json").read_text(encoding="utf-8"))

rows = []
for kind in ("items", "monsters"):
    for c in board.get(kind, []):
        rows.append({
            "kind": kind[:-1],
            "id": c.get("id"),
            "name": c.get("name"),
            "status": c.get("status"),
            "review": c.get("review"),
            "review_note": c.get("review_note"),
            "tier": c.get("tier"),
            "count": c.get("count"),
            "ability": c.get("ability"),
            "explainer": c.get("explainer"),
            "flow": c.get("flow"),
            "notes": c.get("notes"),
            "ops": c.get("ops"),
            "atk": c.get("atk"),
            "hp": c.get("hp"),
            "author_lock": c.get("author_lock"),
            "locked_fields": c.get("locked_fields"),
            "updated": c.get("updated"),
        })

out = root / "tools" / "_board_dump.json"
out.write_text(json.dumps({"cards": rows, "locks": locks}, indent=2, ensure_ascii=False), encoding="utf-8")
print("wrote", out, "cards", len(rows))
