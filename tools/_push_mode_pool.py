import json
from pathlib import Path

root = Path(r"C:\Users\Natha\Documents\boss-rush")
labels = json.loads(Path(r"C:\Users\Natha\Downloads\mode-pool-labels.json").read_text(encoding="utf-8"))
board = json.loads((root / "data" / "content-board.json").read_text(encoding="utf-8"))
catalog = json.loads((root / "data" / "catalog.json").read_text(encoding="utf-8"))

def apply(arr, kind):
    table = labels.get("items" if kind == "item" else "monsters", {})
    n = 0
    for c in arr:
        cid = str(c.get("id", ""))
        if cid in table:
            c["mode_pool"] = table[cid]
            n += 1
    return n

print("board items", apply(board["items"], "item"))
print("board monsters", apply(board["monsters"], "monster"))
print("catalog items", apply(catalog["items"], "item"))
print("catalog monsters", apply(catalog["monsters"], "monster"))
(root / "data" / "content-board.json").write_text(json.dumps(board, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
(root / "data" / "catalog.json").write_text(json.dumps(catalog, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
print("ok")
