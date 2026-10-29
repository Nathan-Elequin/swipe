---
id: REQ-20261029-trophy-pegs-fit
status: open
priority: high
pr: 185
tip_sha: a74bf856
branch: cursor/trophy-pegs-fit-d9d7
created: 2026-10-29T18:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → cabin main → right SideDoor into trophy hall → DEV fill_b1 + bank b2 (Verdant + Sunken trophies; Ashen pegs). Also Middle Progress with all five cases full.
---

# Trophy Hall peg shields fit inside case glass

Follow-up to [REQ-20261029-trophy-slots-fix](REQ-20261029-trophy-slots-fix.md) / PR #182. That pass seated the pedestal trophy in the glass top and reserved a peg Clip below it. Local shots then showed the bottom peg shield (5th with a trophy, 6th without) hanging past the painted case base onto the floor planks — `CASE_GLASS` height 138 native included the accent/base band.

This fix shortens usable glass to 121 native (ends above the case base on `cabinets_wall.png`) and lays out peg mounts with an integer-pixel step that fits `PEG_FIT_MAX` (6) shields fully inside the Clip, with or without the trophy band. Trophy seat, hover rim-light, Nearest, art PNGs, copy, and mechanics stay unchanged.

## What to verify

- With trophy + max pegs (Verdant / Sunken after fill_b1 + bank b2): every peg shield sits fully inside the glass, above the case base — no overlap onto the base or floor.
- Without trophy (Ashen pegs at collected 0, or any empty-trophy column): the 6th peg is still inside the glass above the base.
- All five biome cases: same rule when Middle Progress has every case full.
- Pegs stay crisp Nearest at integer positions/scale; trophy stays in the top-of-glass seat (do not move it).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | Middle Progress → hall → DEV `fill_b1` + bank b2 | Verdant + Sunken trophies and Ashen pegs; every bottom peg inside its case base — no peg shield overlaps the case base or floor in any case | 01-hall-pegs-inside-base.png |
| 02 | hall | Middle Progress save with all five cases full | All five cases full; no peg shield overlaps the case base or floor in any case | 02-hall-all-five-full.png |
| 03 | hall | Crop / close of a filled column (Nearest check) | Peg shields crisp Nearest; no peg shield overlaps the case base or floor in any case | 03-hall-pegs-nearest-crop.png |

## Pass criteria

- All three PNGs under `playtest/repot/outbox/REQ-20261029-trophy-pegs-fit/shots/` at 1680×1040 (godot-mcp preferred; 03 may be a crop of the same frame).
- Expect lines above: no peg shield overlaps the case base or floor in any case.
- Trophy still seated in the glass top on filled cases.
- Tip SHA in RESULT.md is this PR’s tip at shoot time.
- Headless: `scripts/dev/biome_cabinets_selftest.gd` prints `BIOME_CABINETS_OK` (peg fit + above-base asserts).

## Outbox path

`playtest/repot/outbox/REQ-20261029-trophy-pegs-fit/`
