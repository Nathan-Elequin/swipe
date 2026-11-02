"""Write playtest/tier-lists/card-names.json from data/catalog.json."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
catalog = json.loads((root / "data" / "catalog.json").read_text(encoding="utf-8"))
out = {}
for key in ("items", "monsters", "cards"):
    rows = catalog.get(key, [])
    if not isinstance(rows, list):
        continue
    for row in rows:
        if not isinstance(row, dict):
            continue
        cid = str(row.get("id", "")).strip()
        if not cid:
            continue
        name = str(row.get("name", cid)).strip() or cid
        out[cid] = name
dest = root / "playtest" / "tier-lists" / "card-names.json"
dest.parent.mkdir(parents=True, exist_ok=True)
dest.write_text(json.dumps(out, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
print(dest, len(out))
