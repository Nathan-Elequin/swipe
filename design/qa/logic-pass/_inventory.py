import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
cat = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))


def in_scope(c):
    st = str(c.get("status", "")).lower()
    hid = bool((c.get("flags") or {}).get("hide", False))
    cid = c.get("id", "")
    if cid == "smoke_bomb":
        return True
    if hid or st in ("retired", "hold", "todo"):
        return False
    return st == "live"


items = [c for c in cat.get("items", []) if in_scope(c)]
mons = [c for c in cat.get("monsters", []) if in_scope(c)]
print("ITEMS", len(items))
for c in items:
    ops = c.get("ops") or {}
    atk = c.get("atk") or {}
    ab = (c.get("ability") or "").replace("\n", " ")
    print(
        "I",
        c.get("id"),
        "b" + str(int(c.get("bucket") or -1)),
        ops.get("kind") or "-",
        atk.get("formula") or "",
        ab[:120],
        sep="\t",
    )
print("MONSTERS", len(mons))
for c in mons:
    hp = (c.get("hp") or {}).get("base")
    atk = c.get("atk") or {}
    ab = (c.get("ability") or "").replace("\n", " ")
    print(
        "M",
        c.get("id"),
        "b" + str(int(c.get("bucket") or -1)),
        "HP" + str(hp),
        "ATK" + str(atk.get("base", "")),
        atk.get("formula") or "",
        c.get("call_name") or "",
        ab[:120],
        sep="\t",
    )
