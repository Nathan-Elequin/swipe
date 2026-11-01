import json
from pathlib import Path

d = json.loads(Path("data/playtest-ledger.json").read_text(encoding="utf-8"))
todo, f5, itch = [], [], []
for k, v in sorted(d["issues"].items(), key=lambda kv: int(kv[0]), reverse=True):
	card = (
		f'<a class="card" href="{v["url"]}">'
		f'<span class="num">#{k}</span> — {v["title"]}</a>'
	)
	st = v.get("status", "todo")
	if st == "todo":
		todo.append(card)
	elif st == "f5":
		f5.append(card)
	else:
		itch.append(card)


def col(cls: str, title: str, arr: list, empty: str) -> str:
	body = "".join(arr) if arr else f'<p class="empty">{empty}</p>'
	return (
		f'<section class="col {cls}"><h2>{title} '
		f'<span class="count">({len(arr)})</span></h2>{body}</section>'
	)


board = (
	'<div class="board">\n'
	+ col("todo", "Still broken in F5", todo, "None.")
	+ col("f5", "Ready in F5", f5, "Nothing in this checkout yet.")
	+ col("itch", "On itch.io", itch, "None new.")
	+ "\n</div>"
)
head = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Playtest tickets — F5 vs itch</title>
<style>
  :root {
    --bg: #1a1612;
    --ink: #f3e6c8;
    --muted: #b9a88a;
    --card: #241e18;
  }
  * { box-sizing: border-box; }
  body { margin: 0; font: 16px/1.4 Georgia, "Times New Roman", serif; background: var(--bg); color: var(--ink); }
  header { padding: 20px 24px 8px; }
  h1 { font-size: 22px; margin: 0 0 6px; }
  p { margin: 0; color: var(--muted); max-width: 52em; }
  .board { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; padding: 16px 24px 32px; align-items: start; }
  .col { background: var(--card); border-radius: 10px; min-height: 40vh; padding: 12px; }
  .col h2 { margin: 0 0 10px; font-size: 15px; }
  .col.todo h2 { color: #f0b4a8; }
  .col.f5 h2 { color: #b6e0c0; }
  .col.itch h2 { color: #b8c8ef; }
  .count { font-weight: normal; color: var(--muted); }
  a.card { display: block; text-decoration: none; color: inherit; background: #2c251e; border-left: 4px solid #888; border-radius: 6px; padding: 8px 10px; margin: 0 0 8px; }
  .todo a.card { border-left-color: #c56b5c; }
  .f5 a.card { border-left-color: #6fbf80; }
  .itch a.card { border-left-color: #7b93d6; }
  .num { font-weight: bold; }
  .empty { color: var(--muted); font-style: italic; padding: 8px; }
</style>
</head>
<body>
<header>
  <h1>Playtest tickets</h1>
  <p>Left: F5 still shows the old behavior. Middle: committed on <code>playtest/latest</code> — Stop Play, F5. Right: live on itch.io. Source: <code>data/playtest-ledger.json</code>.</p>
</header>
"""
Path("playtest/inbox-board.html").write_text(head + board + "\n</body>\n</html>\n", encoding="utf-8")
print("todo", len(todo), "f5", len(f5), "itch", len(itch))
