---
id: REQ-20261119-hub-spin
status: open
priority: high
branch: cursor/hub-spin-center-29f8
tip_sha: d3423242
pr: 562
created: 2026-11-19T08:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → Adventure dungeon start (ready, hub Spin)
---

# Hub Spin — center button; wheel never moves

Round Spin initiate button sits on the wheel hub. Old placard Spin row is gone. Wheel and Take arc global rects stay identical from dungeon setup/ready through spinning, fighting, and after a kill.

## What to verify

- Fresh save, real player path from F5. Use **godot-mcp injected input only** (never OS mouse/keyboard).
- Viewport **1680×1040**.
- At dungeon start: round gold hub **Spin** centered on the wheel (covers Sprout/hearts). No wide placard under the wheel.
- Hover: pressed look (shadow shrinks, face drops ~2–3px, slightly darker).
- Click: squash + ring burst (`land_burst`) + click SFX; button fades out as the wheel spins.
- Wheel global rect identical across: dungeon start, hover, click/burst frames, mid-spin, landed.
- Take arc global rect identical across those same states (Safe → live Take on land).
- After the first spin, later fights auto-spin (no placard). If a later ready state needs a manual Spin, it is the same hub button.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon start | Adventure ready, hub Spin up | Round Spin on hub center; no placard row; Take dimmed Safe | 01-hub-spin-ready.png |
| 02 | hub hover | Inject hover on hub Spin | Pressed look (darker face, drop, smaller shadow) | 02-hub-spin-hover.png |
| 03a | click burst | Inject click; capture ~0ms | Squash / impact start | 03a-click-burst-0.png |
| 03b | click burst | ~60ms later | Ring burst visible | 03b-click-burst-60.png |
| 03c | click burst | ~120ms later | Burst / fade mid | 03c-click-burst-120.png |
| 03d | click burst | ~180ms later | Button mostly gone / spin starting | 03d-click-burst-180.png |
| 04 | mid-spin | Wheel spinning | No hub button; wheel rect matches 01 | 04-mid-spin.png |
| 05 | landed | Fight started, Take live | Wheel rect matches 01; Take arc seat matches fighting baseline | 05-landed.png |

## Pass criteria

- All rows at 1680×1040.
- Wheel rect identical across 01–05 (and burst frames).
- Take arc seat identical across ready Safe and landed Take (same global rect).
- Hub Spin center within 1px of wheel hub center in 01.
- No player-facing "Tier" or "ATK". No new words (label is existing Spin).

## Outbox path

`playtest/repot/outbox/REQ-20261119-hub-spin/`
