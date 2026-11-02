#!/usr/bin/env python3
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

p = Path(__file__).with_name("_prs_closed.json")
raw = p.read_text(encoding="utf-8-sig")
prs = json.loads(raw)
cut = datetime.now(timezone.utc) - timedelta(days=60)
unmerged = []
for x in prs:
    if x.get("mergedAt"):
        continue
    closed = x.get("closedAt") or ""
    try:
        dt = datetime.fromisoformat(closed.replace("Z", "+00:00"))
    except ValueError:
        continue
    if dt < cut:
        continue
    unmerged.append(x)
lines = [f"closed-unmerged last 60d among last {len(prs)} closed PRs: {len(unmerged)}"]
for x in unmerged:
    lines.append(
        f"#{x['number']} {x['baseRefName']} <- {x['headRefName']} | {x['title']} | {x['closedAt']}"
    )
out = Path(__file__).with_name("_unmerged.txt")
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"wrote {out} n={len(unmerged)}")
