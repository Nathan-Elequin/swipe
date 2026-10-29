---
id: REQ-20261029-trophy-slots-fix
status: open
priority: high
pr: 182
tip_sha: 71aa010d
branch: cursor/trophy-slots-fix-fb86
created: 2026-10-29T17:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → cabin main → right SideDoor into trophy hall → DEV fill_b1 (and ideally a second biome filled via win / grant, or a save with 2+ biomes banked)
---

# Trophy Hall pedestal placement fix

Follow-up to [REQ-20261029-trophy-slots](REQ-20261029-trophy-slots.md) / PR #179. That pass wired per-biome idle + rim-light hover trophies (`BiomeCabinets.trophy_texture`, `trophy_<biome>.png` / `_hover.png`, 24×24×`case_scale`, Nearest). Local shots showed the Verdant wreath drawn on the case floor: overlapping the 6th pegboard shield and hanging past the painted case base onto the plinth/floor.

This fix seats the pedestal trophy fully inside the glass top (shared `CASE_GLASS` geometry for all five shapes), reserves that band so peg mounts never cover it, keeps empty cases empty, and leaves hover rim-light / Nearest / size unchanged. Does not touch stamps, peg gear, `case_*.png`, `trophy_mount*`, or player-facing copy.

**Sunken Mire (2nd case) under `fill_b1`:** DEV `fill_b1` only banks pool `b1` (Verdant). Peg shields still draw for every card in an unlocked pool (silhouette / seen / banked); trophy visibility is keyed to `_case_collected(pool) > 0`. So six pegs and no trophy on case 2 with only `fill_b1` is correct — not a wrong biome index. To verify a second filled trophy, bank another biome (DEV win / grant, or a Middle Progress save that already has 2+ pools collected).

## What to verify

- Filled Verdant case: wreath pedestal sits fully inside the glass — no peg shield covered, no hang below the case frame/base.
- Hover on a filled case swaps to the gold rim-light alt with no silhouette jitter.
- Cases with `collected == 0` stay empty glass (no trophy overlay), even when peg silhouettes are present.
- A second filled biome (when banked) shows its own trophy in the same top-of-glass seat.
- Trophy stays crisp Nearest at 24×24×`case_scale`.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | Middle Progress → hall → DEV `fill_b1` | Filled Verdant trophy fully inside glass; no peg slot covered; no hang past case base | 01-hall-trophy-inside-glass.png |
| 02 | hall | Hover the filled Verdant case | Rim-light hover trophy (gold edge), same seat, no jitter | 02-hall-trophy-hover.png |
| 03 | hall | Cases with 0 collected (Ashen / Cinder / Shadow, or locked) | Empty glass — no trophy sprite | 03-hall-empty-cases.png |
| 04 | hall | Second biome with collected > 0 (win cheat or multi-biome save) | That biome’s trophy seated correctly in its glass top | 04-hall-second-biome-trophy.png |

## Pass criteria

- All four PNGs under `playtest/repot/outbox/REQ-20261029-trophy-slots-fix/shots/` at 1680×1040 (godot-mcp preferred).
- `01` trophy is inside glass, clear of pegs and case base.
- `02` shows hover rim light at the same placement.
- `03` has empty glass with no trophy overlay.
- `04` shows a non-Verdant filled biome trophy in the same top-glass seat (or note if only one biome could be banked in that session).
- Tip SHA in RESULT.md is this PR’s tip at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261029-trophy-slots-fix/`
