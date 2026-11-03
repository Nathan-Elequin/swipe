---
id: REQ-20261103-climb-rope-ladder
status: open
priority: high
branch: cursor/climb-rope-ladder-c6a8
tip_sha: pending
created: 2026-11-03T23:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → clear a dungeon / reach rest so Rope Exit opens
---

# Climb return — rope ladder on skylight (Climb C lock)

Nathan lock 2026-11-03: Climb = **rope-looking ladder** centered on the Crypt Classic skylight (not wood-rung chrome). Hatch plate hidden so the open shaft + ladder read clean. Click leave = ladder **jiggle** → Sprout **dissolve** → quick **wipe UP** → `climb` signal. No `hero_climb_f0/f1` up-shaft loop. Delve gate / GatePortal untouched. Spin `rope.home*` strings unchanged.

## Plant (1680×1040)

- Ladder `overlays/rope_ladder_f*.png` 160×904 at **Rect2(741, -40, 160, 904)** — centered on hatch/skylight x = 821.
- Hatch `rope_exit_hatch.png` kept on disk at (693, -40) but **hidden**.
- Climb hits: Ladder.Hit `Rect2(721, 0, 200, 920)` + RopeCoil.Hit `Rect2(620, 820, 160, 140)`.

## What to verify

- Rope ladder visible down the green skylight shaft; centered (not cozy-left at x≈384).
- Hatch wood plate does **not** cover the skylight (open shaft + ladder).
- Hover ladder or rope coil → warm modulate / faster idle sway + Spin Climb tip (`rope.home` / `rope.home.sub`); hand cursor.
- Click Climb → ladder jiggles briefly → Sprout fades in place → dark wipe rises UP over the cavern → returns home. No frame-by-frame climb up the ladder.
- Delve gate + spiral portal unchanged; left sign flavor only; title chrome OK.
- No Tier in UI; no player-facing copy edits.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | clear → rest; idle | rope ladder centered in skylight shaft; hatch plate gone; gate OK | 01-idle-ladder.png |
| 02 | rope exit | hover ladder | warm/sway ladder + Climb parchment tip | 02-climb-hover.png |
| 03 | rope exit | click Climb mid-sequence if possible | jiggle and/or Sprout dissolving; no hero_climb loop up the shaft | 03-jiggle-dissolve.png |
| 04 | rope exit | after Climb click (wipe) | dark wipe covering from bottom upward, or surface after leave | 04-wipe-up.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261103-climb-rope-ladder/`
