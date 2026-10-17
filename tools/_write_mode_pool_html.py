import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
board = json.loads((root / "data" / "content-board.json").read_text(encoding="utf-8"))
cards = []
for kind, key in [("item", "items"), ("monster", "monsters")]:
    for c in board[key]:
        if str(c.get("status", "live")) in ("hold", "retired"):
            continue
        cid = c.get("id", "")
        mp = c.get("mode_pool", "all") or "all"
        if mp not in ("all", "adventure", "challenge"):
            mp = "all"
        cards.append({
            "kind": kind,
            "id": cid,
            "name": c.get("name", cid),
            "ability": c.get("ability", "") or "",
            "tier": int(c.get("tier") or 1),
            "bucket": c.get("bucket", 0),
            "mode": mp,
        })
payload = json.dumps(cards, ensure_ascii=False)
html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Mode labels</title>
<style>
  :root { --ink:#f0e6d8; --muted:#cbbba6; --bg:#120e0c; --panel:#1c1612; --gold:#e8c36a; --bronze:#c08050; --silver:#c5cdd8; }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--bg); color: var(--ink); font: 15px/1.4 "Iowan Old Style", Palatino, Georgia, serif; }
  header { position: sticky; top: 0; z-index: 8; background: #120e0cf2; padding: 18px 24px 14px; border-bottom: 1px solid #3a322c; }
  h1 { margin: 0 0 6px; font-size: 26px; }
  .lead { color: var(--muted); margin: 0 0 10px; max-width: 860px; }
  .bar { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
  button { font: inherit; color: inherit; cursor: pointer; }
  button.main { background: #2a1c14; border: 2px solid var(--gold); border-radius: 999px; padding: 6px 16px; }
  button.ghost { background: transparent; border: 1px solid #6b5344; border-radius: 999px; padding: 5px 12px; }
  .count { color: var(--gold); font-weight: 700; }
  .cols { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; padding: 16px 20px 40px; }
  @media (max-width: 980px) { .cols { grid-template-columns: 1fr; } }
  h2 { margin: 0 0 10px; font-size: 20px; }
  .card { border: 3px solid #6b5344; background: var(--panel); padding: 10px 12px 12px; margin: 0 0 10px; }
  .card.t1 { border-color: var(--bronze); }
  .card.t2 { border-color: var(--silver); }
  .card.t3 { border-color: var(--gold); }
  .top { display: flex; justify-content: space-between; gap: 8px; align-items: baseline; }
  .nm { font-weight: 700; font-size: 18px; }
  .meta { font-size: 12px; color: var(--muted); }
  .ab { margin: 6px 0 10px; color: #e6d8c6; min-height: 2.6em; }
  .btns { display: flex; gap: 6px; }
  .btns button { flex: 1; border-radius: 8px; border: 2px solid #6b5344; background: #241c18; padding: 6px 4px; font-size: 13px; }
  .btns button.on.all { border-color: #8dcb8d; background: #1a2a16; }
  .btns button.on.adventure { border-color: #6bb3d9; background: #142028; }
  .btns button.on.challenge { border-color: var(--gold); background: #2a1c08; }
</style>
</head>
<body>
<header>
  <h1>Which modes can this card show up in?</h1>
  <p class="lead">Click All, Adventure-Only, or Challenge-Only on every card. Smoke Bomb, Danger Magnet, and Clockwork Knight already start as Adventure-Only, matching the live bans. When you are done, download the file, then tell me it is in Downloads and I will write it into the game.</p>
  <div class="bar">
    <span class="count" id="progress"></span>
    <button class="ghost" id="onlyLeft">Show not-All only</button>
    <button class="ghost" id="showAll">Show all</button>
    <button class="main" id="download">Download labels</button>
  </div>
</header>
<div class="cols">
  <section>
    <h2>Items</h2>
    <div id="items"></div>
  </section>
  <section>
    <h2>Monsters</h2>
    <div id="mons"></div>
  </section>
</div>
<script>
const CARDS = """ + payload + """;
const KEY = "boss-rush-mode-pool-labels-v1";
const LABELS = {all:"All", adventure:"Adventure-Only", challenge:"Challenge-Only"};
let onlyLeft = false;
function load() {
  let saved = {};
  try { saved = JSON.parse(localStorage.getItem(KEY) || "{}"); } catch (e) { saved = {}; }
  for (const c of CARDS) {
    const k = c.kind + ":" + c.id;
    if (saved[k]) c.mode = saved[k];
  }
}
function save() {
  const out = {};
  for (const c of CARDS) out[c.kind + ":" + c.id] = c.mode;
  localStorage.setItem(KEY, JSON.stringify(out));
}
function render() {
  const items = document.getElementById("items");
  const mons = document.getElementById("mons");
  items.innerHTML = "";
  mons.innerHTML = "";
  let labeled = 0;
  for (const c of CARDS) {
    if (c.mode) labeled++;
    if (onlyLeft && c.mode === "all") continue;
    const el = document.createElement("article");
    el.className = "card t" + c.tier;
    el.innerHTML = '<div class="top"><div class="nm"></div><div class="meta"></div></div><div class="ab"></div><div class="btns"></div>';
    el.querySelector(".nm").textContent = c.name;
    el.querySelector(".meta").textContent = "T" + c.tier + " · bucket " + c.bucket;
    el.querySelector(".ab").textContent = c.ability || "(no ability text)";
    const btns = el.querySelector(".btns");
    for (const id of ["all","adventure","challenge"]) {
      const b = document.createElement("button");
      b.textContent = LABELS[id];
      b.className = id + (c.mode === id ? " on" : "");
      b.onclick = () => { c.mode = id; save(); render(); };
      btns.appendChild(b);
    }
    (c.kind === "item" ? items : mons).appendChild(el);
  }
  const adv = CARDS.filter(c => c.mode === "adventure").length;
  const ch = CARDS.filter(c => c.mode === "challenge").length;
  document.getElementById("progress").textContent = CARDS.length + " cards · " + adv + " Adventure-Only · " + ch + " Challenge-Only";
}
function download() {
  const items = {};
  const monsters = {};
  for (const c of CARDS) {
    (c.kind === "item" ? items : monsters)[c.id] = c.mode || "all";
  }
  const blob = new Blob([JSON.stringify({items, monsters}, null, 2)], {type:"application/json"});
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = "mode-pool-labels.json";
  a.click();
  URL.revokeObjectURL(a.href);
}
load();
save();
render();
document.getElementById("onlyLeft").onclick = () => { onlyLeft = true; render(); };
document.getElementById("showAll").onclick = () => { onlyLeft = false; render(); };
document.getElementById("download").onclick = download;
</script>
</body>
</html>
"""
out = root / "design" / "mode-pool-labels.html"
out.write_text(html, encoding="utf-8")
print("wrote", out, "cards", len(cards))
