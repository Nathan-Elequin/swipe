import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
index_path = HERE / "index.json"
suite = json.loads((HERE / "mill-suite.json").read_text(encoding="utf-8"))
idx = json.loads(index_path.read_text(encoding="utf-8"))
by = {r["id"]: r for r in idx.get("rows", [])}

batch_rows = {}
for p in sorted((HERE / "batches").glob("*.json")):
    data = json.loads(p.read_text(encoding="utf-8"))
    for r in data:
        batch_rows[r["id"]] = r

spec_by = {t["id"]: t for t in suite["tests"]}
sprites = suite.get("sprites", {})


def cards_of(spec):
    out = []
    for iid in spec.get("items") or []:
        out.append(
            {
                "id": iid,
                "kind": "item",
                "name": iid.replace("_", " ").title(),
                "ability": "",
                "sprite": sprites.get(iid, ""),
            }
        )
    for mid in spec.get("monsters") or []:
        out.append(
            {
                "id": mid,
                "kind": "monster",
                "name": mid.replace("_", " ").title(),
                "ability": "",
                "sprite": sprites.get(mid, ""),
            }
        )
    return out


for tid, spec in spec_by.items():
    b = batch_rows.get(tid, {})
    result = b.get("result") or b.get("column") or "queue"
    column = b.get("column") or result
    row = {
        "id": tid,
        "title": spec.get("title", tid),
        "verbs": spec.get("verbs", ["unique"]),
        "cards": cards_of(spec),
        "expected": spec.get("expected_text", ""),
        "observed": b.get("observed") or "",
        "mismatch": b.get("mismatch") or "",
        "log": b.get("log") or "",
        "result": result,
        "column": column,
        "ruling": {},
        "note": b.get("note") or "",
        "paper_fight": "",
        "scene": {
            "you_hp": spec.get("hp_before", 6),
            "hand": [iid.replace("_", " ").title() for iid in (spec.get("items") or [])],
            "face_id": spec.get("face", ""),
            "face_name": str(spec.get("face", "")).replace("_", " ").title(),
            "clicks": [
                "clicked " + str(c.get("item", c.get("op", "")))
                for c in (spec.get("clicks") or [])
                if isinstance(c, dict)
            ],
            "kind": "fight",
        },
    }
    by[tid] = row

idx["rows"] = list(by.values())
counts = {}
for r in idx["rows"]:
    c = r.get("column") or r.get("result") or "queue"
    counts[c] = counts.get(c, 0) + 1
idx["title"] = "Live mill unique abilities"
idx["counts"] = counts
index_path.write_text(json.dumps(idx, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("counts", counts, "rows", len(idx["rows"]))
print("fails", [r["id"] for r in idx["rows"] if r.get("column") == "fail"])
