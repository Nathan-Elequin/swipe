---
id: REQ-20261106-neighbor-who-rings
status: open
priority: high
pr:
tip_sha: 62e917b4
branch: playtest/latest
created: 2026-11-06T00:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → combat
---

# Gold who-ring on Boot/Net/Damsel/Knife seats

Nathan picked A (thin gold hoop). Overlay only — seat PNGs and seat sizes did not change. Weak/Tough 24px native seats use the 32×32 hoop (64px on screen). Deadly 32px native seats use the 40×40 hoop (80px on screen). Same ring for Boot, Net, Damsel neighbors, and Throwing Knife. No extra clicks, no copy, no “Tier” on screen.

## What to verify

- Hover Boot (or Throwing Knife) on a **Goblin / Hornet** fight: gold hoop around that 24px Weak seat. Hoop is larger than the seat, 1px ink outline, no blur.
- Hover Boot (or Throwing Knife) on a **Dragon / Lich / Slime Boss** fight: larger gold hoop around that 32px Deadly seat.
- Facing **Damsel In Distress**: hoop on Left and Right **neighbor** seats (not a new click). Damsel’s own seat is not ringed unless an item also targets her.
- Hover **Net**: hoop on the facing seat (Net still has no HP ghost numbers).
- After click-to-pick a markable seat (or after clicking Knife/Net, while the 1/2/3 or throw/nick row is up): hoop stays on that who-seat, still frame.
- Seat art and seat sizes match F5 from before this PR. No “Tier” label.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Fight a Weak/Tough 24px seat (Goblin or Hornet Swarm). Hover Boot or Throwing Knife. | Gold hoop on that **24px Weak/Tough** seat; seat sprite still 48px on screen | 01-ring-weak-24.png |
| 02 | combat | Fight a Deadly 32px seat (Dragon, Lich, or Slime Boss). Hover Boot or Throwing Knife. | **Larger** gold hoop on that **Deadly** seat; seat sprite still 64px on screen | 02-ring-deadly-32.png |
| 03 | combat | Fight Damsel In Distress with live neighbors. No item hover needed. | Hoops on Left and Right neighbor seats; Damsel herself has no hoop | 03-damsel-neighbors.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shot 01 must show a ring on a 24px Weak/Tough seat. Shot 02 must show a ring on a Deadly seat. Both readable without guessing.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Optional: `python3 tools/qa/check_who_rings.py` exits 0 (32 vs 40 native, hard alpha, lossless import).
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261106-neighbor-who-rings/`
