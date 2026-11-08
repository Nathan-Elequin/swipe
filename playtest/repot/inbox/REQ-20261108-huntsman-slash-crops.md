---
id: REQ-20261108-huntsman-slash-crops
status: open
priority: high
pr:
tip_sha: pending
branch: playtest/latest
created: 2026-11-08T10:20:00Z
created_by: cloud-agent-slice-o
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → seat Huntsman; also face Shark / Mouse / Wraith for slash cut-ins
---

# Slice O — Huntsman Merchant-scale + Shark/Mouse/Wraith slash crops

Huntsman facing + new wheel pack nearest-enlarged to Merchant silhouette fill on 48×48 (Huntsman-only seat-size override). Shark / Mouse / Wraith slash plates re-cropped to 48×48 with margin and re-animed; no player-copy invent.

## What to verify

- Wheel Huntsman reads about as large as Merchant (same Weak/Tough 48n class, fuller silhouette — not the old tiny bowman).
- Fight facing Huntsman matches that larger fill.
- Shark / Mouse / Wraith slash cut-ins show full silhouette with a small transparent margin (not edge-flush / left-clipped).
- Mouse slash is 48×48 (not the old 32×32).
- Shark slash no longer uses the old 64×64 edge-flush set (f4 removed).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Seat Huntsman next to or near a Merchant if possible | Huntsman silhouette fill ≈ Merchant; 48n Weak class | 01-huntsman-wheel-vs-merchant.png |
| 02 | combat facing | Face Huntsman | Larger bowman fill on 48 facing | 02-huntsman-facing.png |
| 03 | slash cut-in | Trigger Shark Attack slash | 48 canvas; silhouette inset, not edge-cropped | 03-shark-slash.png |
| 04 | slash cut-in | Trigger Mouse Attack slash | 48 canvas; full mouse readable, not left-clipped 32 | 04-mouse-slash.png |
| 05 | slash cut-in | Trigger Wraith Attack slash | 48 canvas; silhouette inset | 05-wraith-slash.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- Shot 01 fails if Huntsman still looks ~half Merchant height.
- Shots 03–05 fail if opaque pixels hug the canvas edge on L/R/T.
- Do not mark this request `done` from cloud — local Cherry only.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261108-huntsman-slash-crops/`
