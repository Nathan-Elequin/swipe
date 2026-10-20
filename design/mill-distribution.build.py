# Regenerates design/mill-distribution.html from data/catalog.json.
import json
import html
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CAT = json.loads((ROOT / "data" / "catalog.json").read_text(encoding="utf-8"))
OUT = Path(__file__).with_name("mill-distribution.html")
CANVAS = ROOT / ".cursor" / "canvases" / "mill-distribution.html"

PAIR_EXTRA = {"bracers"}
STARTER_EXTRA = {"smoke_bomb"}
BUCKET_COL = {
    0: "#5d8a45",
    1: "#2f6f9f",
    2: "#6d4c9a",
    3: "#b8860b",
    4: "#b85c2a",
    5: "#8f3048",
    6: "#1f6f6a",
    7: "#4a5a8a",
    8: "#7a5a2a",
}
TYPE_NAME = {"A": "Attack", "D": "Defense", "C": "Cheese", "U": "Utility"}
TYPE_COL = {"A": "#c45c5c", "D": "#6bb3d9", "C": "#c89be0", "U": "#e8c36a"}


def parse_bucket(v):
    if v is None:
        return 0
    if isinstance(v, str):
        s = v.strip()
        if s.lower() == "token":
            return -1
        try:
            return int(float(s))
        except ValueError:
            return 0
    return int(v)


def family(card):
    col = str(card.get("card_color") or "").strip().lower()
    if col == "atk":
        return "A"
    if col in ("blk", "heal"):
        return "D"
    if col == "defeat":
        return "C"
    return "U"


def skip_mill(card):
    st = str(card.get("status") or "live")
    if st in ("retired", "hold"):
        return True
    if parse_bucket(card.get("bucket", 0)) < 0:
        return True
    cid = str(card.get("id") or "")
    if cid in STARTER_EXTRA or cid in PAIR_EXTRA:
        return True
    mode = str(card.get("mode_pool") or "all").strip().lower().replace(" ", "").replace("_", "-")
    if mode and mode != "all":
        return True
    return False


def extra_why(card):
    st = str(card.get("status") or "live")
    if st == "retired":
        return "retired"
    if st == "hold":
        return "hold"
    if parse_bucket(card.get("bucket", 0)) < 0:
        return "token"
    cid = str(card.get("id") or "")
    if cid in STARTER_EXTRA:
        return "smoke extra"
    if cid in PAIR_EXTRA:
        return "pair extra"
    mode = str(card.get("mode_pool") or "all").strip().lower().replace(" ", "").replace("_", "-")
    if mode and mode != "all":
        return f"{mode} only"
    if (card.get("flags") or {}).get("hide"):
        return "hidden"
    return ""


def want_n(b):
    return 10 if b == 0 else 5


def want_tiers(b):
    return {1: 5, 2: 3, 3: 2} if b == 0 else {1: 2, 2: 2, 3: 1}


def want_types(b):
    if b == 0:
        return {"A": 3, "D": 3, "C": 2, "U": 2}
    if b % 2 == 1:
        return {"A": 2, "D": 1, "C": 1, "U": 1}
    return {"A": 1, "D": 2, "C": 1, "U": 1}


def stat(card, key):
    blob = card.get(key) or {}
    if isinstance(blob, dict):
        return int(blob.get("base") or 0)
    if card.get(f"{key}_base") not in (None, ""):
        return int(card.get(f"{key}_base") or 0)
    return 0


def pack(card, kind):
    flags = card.get("flags") or {}
    return {
        "id": str(card.get("id") or ""),
        "name": str(card.get("name") or card.get("id") or "?"),
        "tier": max(1, min(3, int(card.get("tier") or 1))),
        "type": family(card) if kind == "item" else "",
        "hp": stat(card, "hp") if kind == "monster" else 0,
        "atk": stat(card, "atk") if kind == "monster" else 0,
        "status": str(card.get("status") or "live"),
        "ability": str(card.get("ability") or ""),
        "art": bool(flags.get("art")),
        "note": str(card.get("review_note") or ""),
        "bucket": parse_bucket(card.get("bucket", 0)),
    }


items = CAT.get("items") or []
monsters = CAT.get("monsters") or []
by = {b: {"items": [], "monsters": []} for b in range(9)}
extras = []
for card in items:
    if skip_mill(card):
        extras.append((pack(card, "item"), extra_why(card), "item"))
        continue
    b = parse_bucket(card.get("bucket", 0))
    if 0 <= b <= 8:
        by[b]["items"].append(pack(card, "item"))
    else:
        extras.append((pack(card, "item"), extra_why(card) or f"bucket {b}", "item"))
for card in monsters:
    if skip_mill(card):
        extras.append((pack(card, "monster"), extra_why(card), "monster"))
        continue
    b = parse_bucket(card.get("bucket", 0))
    if 0 <= b <= 8:
        by[b]["monsters"].append(pack(card, "monster"))
    else:
        extras.append((pack(card, "monster"), extra_why(card) or f"bucket {b}", "monster"))

for b in range(9):
    by[b]["items"].sort(key=lambda c: (-c["tier"], c["type"], c["name"]))
    by[b]["monsters"].sort(key=lambda c: (-c["tier"], c["name"]))


def mix(cards, key, keys):
    out = {k: 0 for k in keys}
    for c in cards:
        v = c.get(key)
        if v in out:
            out[v] += 1
        elif key == "tier":
            out[max(1, min(3, int(v or 1)))] += 1
    return out


def chip(ok, have, want, label):
    cls = "ok" if have == want else ("over" if have > want else "under")
    return f'<span class="chip {cls}">{html.escape(label)} {have}/{want}</span>'


def card_html(c, kind):
    gold = " goldbox" if c.get("note") else ""
    art = "" if c.get("art") else " noart"
    todo = " todo" if c.get("status") != "live" else ""
    t = c["tier"]
    if kind == "item":
        fam = c["type"]
        meta = TYPE_NAME[fam]
        body = f'<span class="type {fam}">{html.escape(fam)}</span>'
    else:
        meta = f'{c["hp"]}/{c["atk"]}'
        body = f'<span class="stats">{c["hp"]} HP · {c["atk"]} ATK</span>'
    note = f'<div class="gold">{html.escape(c["note"])}</div>' if c.get("note") else ""
    return (
        f'<article class="card t{t}{gold}{art}{todo}" title="{html.escape(c["ability"])}">'
        f'<div class="row"><span class="name">{html.escape(c["name"])}</span>'
        f'<span class="tier">T{t}</span></div>'
        f'<div class="meta">{html.escape(meta)}{body}</div>{note}</article>'
    )


cols = []
problems = []
for b in range(9):
    want = want_n(b)
    wt = want_tiers(b)
    wy = want_types(b) if True else {}
    its = by[b]["items"]
    mons = by[b]["monsters"]
    ti = mix(its, "tier", (1, 2, 3))
    tm = mix(mons, "tier", (1, 2, 3))
    ty = mix(its, "type", ("A", "D", "C", "U"))
    last = b == 8
    count_bad = (len(its) != want or len(mons) != want) if not (last and len(its) <= want and len(mons) <= want and len(its) and len(mons)) else False
    # last-used bucket may be short, but not over. B8 is last used if any cards.
    if last:
        count_bad = len(its) > want or len(mons) > want or len(its) == 0 or len(mons) == 0
    else:
        count_bad = len(its) != want or len(mons) != want
    extra_type = "Attack" if b % 2 == 1 else "Defense"
    if b == 0:
        extra_type = "—"
    flags = []
    if count_bad:
        flags.append(f"{len(its)} items / {len(mons)} monsters (want {want}/{want})")
    for t in (1, 2, 3):
        if ti[t] != wt[t]:
            flags.append(f"items T{t} {ti[t]}/{wt[t]}")
        if tm[t] != wt[t]:
            flags.append(f"monsters T{t} {tm[t]}/{wt[t]}")
    if b >= 0:
        for k in ("A", "D", "C", "U"):
            if ty[k] != wy[k]:
                flags.append(f"{TYPE_NAME[k]} {ty[k]}/{wy[k]}")
    if flags:
        problems.append((b, flags))
    head_chips = (
        chip(len(its) == want, len(its), want, "I")
        + chip(len(mons) == want, len(mons), want, "M")
        + "".join(chip(ti[t] == wt[t], ti[t], wt[t], f"T{t}") for t in (1, 2, 3))
    )
    type_chips = "".join(chip(ty[k] == wy[k], ty[k], wy[k], k) for k in ("A", "D", "C", "U"))
    item_cards = "".join(card_html(c, "item") for c in its) or '<p class="empty">no items</p>'
    mon_cards = "".join(card_html(c, "monster") for c in mons) or '<p class="empty">no monsters</p>'
    bad_cls = " bad" if flags else " good"
    cols.append(
        f'<section class="col{bad_cls}" style="--b:{BUCKET_COL[b]}">'
        f'<header><div class="bn">{b}</div>'
        f'<div><div class="btitle">Bucket {b}</div>'
        f'<div class="sub">{"10/10 · 5/3/2 · 3A 3D 2C 2U" if b == 0 else f"5/5 · 2/2/1 · extra {extra_type}"}</div>'
        f'<div class="chips">{head_chips}</div>'
        f'<div class="chips">{type_chips}</div></div></header>'
        f'<h3>Items</h3><div class="stack">{item_cards}</div>'
        f'<h3>Monsters</h3><div class="stack">{mon_cards}</div></section>'
    )

extra_html = []
for card, why, kind in extras:
    extra_html.append(
        f'<article class="card extra {kind}">'
        f'<div class="row"><span class="name">{html.escape(card["name"])}</span>'
        f'<span class="why">{html.escape(why)}</span></div></article>'
    )

prob_lis = []
for b, flags in problems:
    prob_lis.append(f"<li><strong>Bucket {b}</strong> — {html.escape('; '.join(flags))}</li>")

# Proposed drags (do not apply). B8 is overweight.
b8i = [c["name"] for c in by[8]["items"]]
b8m = [c["name"] for c in by[8]["monsters"]]
propose = [
    "Do not auto-move this. More than two mill cards would have to move, so Roster drag is the right tool.",
    "Bucket 8 should be 5 items and 5 monsters. It is the leftover pile plus the six shopping-list fills.",
    "Keep in 8 the cards that were designed for those holes: Ball & Chain (T1 Attack), Recycler (T2 Utility), Magicat (T1), Rust Bucket (T2), Poison Frog (T2).",
    "Walk the leftover T3 monsters out of 8 first: Damsel, Almighty Worm, Death Bell — only one T3 monster belongs in a later bucket.",
    "Walk extra Defense items out of 8: Mirror Shard, Pacemaker, Stone Wall. Even buckets want 2 Defense, not 3, and 8 still has no Cheese.",
    "Juggernaut’s bucket field is 1, notes still say Bucket 8. If you want him late, drag him to 8 after you pull a T1 monster out.",
    "Arrow Head’s gold box wants Bucket 1 as a simple Attack. Do not drag it until the Lose-2-HP questions are answered — inspect text is already the rework, live clicks are still the old pierce aura.",
]

html_doc = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Mill distribution</title>
<style>
  :root {{
    --ink: #f0e6d8;
    --muted: #cbbba6;
    --bg: #120e0c;
    --panel: #1c1612;
    --line: #6b5344;
  }}
  * {{ box-sizing: border-box; }}
  body {{ margin: 0; background: var(--bg); color: var(--ink); font: 15px/1.4 "Iowan Old Style", Palatino, Georgia, serif; }}
  h1 {{ font-size: 28px; margin: 0 0 6px; }}
  h2 {{ font-size: 18px; margin: 0 0 8px; }}
  h3 {{ font-size: 12px; letter-spacing: .08em; text-transform: uppercase; color: var(--muted); margin: 14px 0 6px; }}
  .wrap {{ padding: 22px 22px 48px; }}
  .verdict {{ max-width: 980px; background: #241810; border: 3px solid #c08050; padding: 16px 18px; margin-bottom: 16px; }}
  .verdict p {{ margin: 0 0 8px; color: var(--muted); }}
  .verdict ul {{ margin: 8px 0 0; padding-left: 18px; }}
  .how {{ color: #8dcb8d; margin: 0 0 16px; }}
  .board {{ display: flex; gap: 12px; overflow-x: auto; padding-bottom: 12px; }}
  .col {{ min-width: 232px; max-width: 260px; flex: 0 0 232px; background: var(--panel); border: 3px solid var(--b, var(--line)); padding: 10px; }}
  .col.bad {{ box-shadow: inset 0 0 0 2px #e07a7a; }}
  .col.good {{ box-shadow: inset 0 0 0 2px #5d8a45; }}
  .col header {{ display: flex; gap: 8px; align-items: flex-start; margin-bottom: 8px; }}
  .bn {{ width: 36px; height: 36px; background: var(--b); color: #fff; font: 700 20px/36px ui-sans-serif, sans-serif; text-align: center; }}
  .btitle {{ font-weight: 700; }}
  .sub {{ font-size: 12px; color: var(--muted); }}
  .chips {{ display: flex; flex-wrap: wrap; gap: 4px; margin-top: 4px; }}
  .chip {{ font: 700 11px/1 ui-sans-serif, sans-serif; padding: 3px 5px; border: 1px solid #6b5344; color: var(--muted); }}
  .chip.ok {{ border-color: #5d8a45; color: #b7e0a8; }}
  .chip.over {{ border-color: #e07a7a; color: #f0a0a0; background: #2a1614; }}
  .chip.under {{ border-color: #e8c36a; color: #ffe9a8; background: #2a1c08; }}
  .stack {{ display: flex; flex-direction: column; gap: 6px; }}
  .card {{ background: #14110f; border: 2px solid #4a3b32; padding: 6px 8px; }}
  .card.t3 {{ border-color: #e8c36a; }}
  .card.t2 {{ border-color: #6e7f96; }}
  .card.t1 {{ border-color: #c08050; }}
  .card.goldbox {{ outline: 2px solid #e8c36a; }}
  .card.noart {{ background-image: linear-gradient(135deg, transparent 0 70%, #5a3d32 70% 100%); }}
  .card.todo {{ opacity: .86; }}
  .row {{ display: flex; justify-content: space-between; gap: 8px; align-items: baseline; }}
  .name {{ font-weight: 700; }}
  .tier {{ font: 700 11px ui-sans-serif, sans-serif; color: var(--muted); }}
  .meta {{ font-size: 12px; color: var(--muted); display: flex; justify-content: space-between; gap: 8px; }}
  .type {{ font: 700 11px ui-sans-serif, sans-serif; }}
  .type.A {{ color: {TYPE_COL['A']}; }}
  .type.D {{ color: {TYPE_COL['D']}; }}
  .type.C {{ color: {TYPE_COL['C']}; }}
  .type.U {{ color: {TYPE_COL['U']}; }}
  .gold {{ margin-top: 4px; background: #e8c36a; color: #1c120c; font-size: 12px; padding: 4px 6px; }}
  .empty {{ color: #8a7a6a; font-style: italic; }}
  .extras {{ margin-top: 22px; max-width: 1100px; }}
  .extra-grid {{ display: flex; flex-wrap: wrap; gap: 8px; }}
  .card.extra {{ min-width: 180px; }}
  .why {{ font: 700 11px ui-sans-serif, sans-serif; color: #c4a574; }}
  .legend {{ display: flex; flex-wrap: wrap; gap: 12px; color: var(--muted); font-size: 13px; margin: 8px 0 18px; }}
  .legend span {{ display: inline-flex; align-items: center; gap: 6px; }}
  .sw {{ width: 12px; height: 12px; display: inline-block; border: 2px solid #4a3b32; }}
</style>
</head>
<body>
<div class="wrap">
  <h1>Live mill — drag in F6 Roster</h1>
  <p class="how">F6 Roster · drag a card into another column · Save. Token / Smoke / pair extras / mode-only / Hold / retired sit in the extras strip and do not fill the 10/5.</p>
  <section class="verdict">
    <h2>Not satisfied with Bucket 8 — the rest is close enough to judge by eye</h2>
    <p>Counts, tiers, and item types are the quota. Strength numbers are not. I would not change ATK/HP from this board. Cheese climb and “one tracker per bucket” still need your eyes, not a silent rewrite.</p>
    <ul>
      {''.join(f'<li>{html.escape(p)}</li>' for p in propose)}
    </ul>
    <h3>Quota misses</h3>
    <ul>{''.join(prob_lis) if prob_lis else '<li>None.</li>'}</ul>
  </section>
  <div class="legend">
    <span><i class="sw" style="border-color:#c08050"></i> T1</span>
    <span><i class="sw" style="border-color:#6e7f96"></i> T2</span>
    <span><i class="sw" style="border-color:#e8c36a"></i> T3</span>
    <span style="color:{TYPE_COL['A']}">A Attack</span>
    <span style="color:{TYPE_COL['D']}">D Defense (Block or Heal)</span>
    <span style="color:{TYPE_COL['C']}">C Cheese</span>
    <span style="color:{TYPE_COL['U']}">U Utility</span>
    <span>corner fold = missing art</span>
    <span>gold outline = gold box</span>
  </div>
  <div class="board">
    {''.join(cols)}
  </div>
  <section class="extras">
    <h2>Not counted toward 10 / 5</h2>
    <div class="extra-grid">{''.join(extra_html)}</div>
  </section>
</div>
</body>
</html>
"""

OUT.write_text(html_doc, encoding="utf-8")
CANVAS.parent.mkdir(parents=True, exist_ok=True)
CANVAS.write_text(html_doc, encoding="utf-8")
print(f"wrote {OUT}")
print(f"wrote {CANVAS}")
print("ITEMS", {b: [c["name"] for c in by[b]["items"]] for b in range(9)})
print("MONSTERS", {b: [c["name"] for c in by[b]["monsters"]] for b in range(9)})
print("PROBLEMS", problems)
print("EXTRAS", [(c["name"], w, k) for c, w, k in extras])
