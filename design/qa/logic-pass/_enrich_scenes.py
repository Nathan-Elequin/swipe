# Add a readable "scene" to every Bucket 0 row (what you faced, what you clicked).
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
index = json.loads((ROOT / "index.json").read_text(encoding="utf-8"))
suite = json.loads((ROOT / "bucket0-suite.json").read_text(encoding="utf-8"))
cat = json.loads((ROOT.parents[2] / "data" / "catalog.json").read_text(encoding="utf-8"))

by_spec = {t["id"]: t for t in suite["tests"]}
mons = {c["id"]: c for c in cat["monsters"]}
items = {c["id"]: c for c in cat["items"]}

CHOOSE = {
    "throw": "picked ATK 3 and throw the Knife away",
    "nick": "picked ATK 1 and Keep the Knife",
    "drop1": "picked −1 Attack",
    "drop2": "picked −2 Attack",
    "drop3": "picked −3 Attack",
}


def item_name(i):
    return (items.get(i) or {}).get("name") or i


def mon_name(i):
    return (mons.get(i) or {}).get("name") or i


def mon_stats(i):
    m = mons.get(i) or {}
    atk = m.get("atk") or {}
    hp = m.get("hp") or {}
    return int(atk.get("base") or 0), int(hp.get("base") or 0)


def click_line(click, spec):
    op = click.get("op")
    if op == "use":
        return "clicked " + item_name(click.get("item", ""))
    if op == "choose":
        return CHOOSE.get(str(click.get("id", "")), "picked " + str(click.get("id", "")))
    if op == "mark":
        return "clicked " + mon_name(click.get("monster", "")) + " (the neighbor on the wheel)"
    if op == "done":
        return "clicked Done — take the hit"
    return str(op)


def scene_for(row):
    spec = by_spec.get(row["id"], {})
    face = spec.get("face") or next((c["id"] for c in row.get("cards", []) if c.get("kind") == "monster"), "")
    atk, hp = mon_stats(face) if face else (0, 0)
    you = int(spec.get("hp_before") or 6)
    hand = [item_name(i) for i in spec.get("items") or []]
    clicks = [click_line(c, spec) for c in spec.get("clicks") or []]
    if spec.get("kind") == "hub":
        clicks = ["started Challenge from the playtest hub"]
        face = ""
    return {
        "you_hp": you,
        "hand": hand,
        "face_id": face,
        "face_name": mon_name(face) if face else "",
        "face_atk": atk,
        "face_hp": hp,
        "clicks": clicks,
        "kind": spec.get("kind") or "fight",
    }


for row in index["rows"]:
    row["scene"] = scene_for(row)

(ROOT / "index.json").write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("scenes", sum(1 for r in index["rows"] if r.get("scene")))
