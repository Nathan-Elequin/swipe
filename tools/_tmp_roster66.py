import json
from pathlib import Path
board=json.loads(Path("data/content-board.json").read_text(encoding="utf-8"))
cards=board.get("cards") or board.get("items") or board
if isinstance(cards, dict):
    seq=[(k,v) for k,v in cards.items() if isinstance(v,dict)]
else:
    seq=[(c.get("id"),c) for c in cards if isinstance(c,dict)]
print("n", len(seq))
for cid,c in seq:
    st=str(c.get("status","live"))
    if st in ("hold","retired"):
        print("EXCL", cid, "|", c.get("name"), "|", st, "| pool=", c.get("pool"), "| bucket=", c.get("bucket"), "| kind=", c.get("kind") or c.get("card_kind") or c.get("type"))
# also danger_magnet specifically and cinder-ish pools
print("--- pool counts live items ---")
from collections import Counter
cnt=Counter(); excl_by_pool=Counter()
for cid,c in seq:
    kind=str(c.get("kind") or c.get("card_kind") or "")
    if kind and kind.lower() not in ("i","item","items",""):
        # skip monsters if tagged
        if "mon" in kind.lower() or kind.lower() in ("m","monster"):
            continue
    pool=str(c.get("pool") or "")
    st=str(c.get("status","live"))
    if pool:
        if st in ("hold","retired"):
            excl_by_pool[pool]+=1
        elif st=="live":
            cnt[pool]+=1
print("live", dict(cnt))
print("excl", dict(excl_by_pool))
