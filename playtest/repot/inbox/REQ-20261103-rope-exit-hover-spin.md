---
id: REQ-20261103-rope-exit-hover-spin
status: open
priority: normal
branch: cursor/rope-exit-hover-spin-23de
tip_sha: pending
created: 2026-11-03T22:35:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → clear a dungeon / reach Rope Exit rest
---

# Rope Exit Spin hover tips + campaign chip fill

Diegetic hatch/gate hotspots (option A) show Spin-locked hover parchment. Campaign top-right chips fill `{biome}` / `{n}` (no raw braces). Hover strings are Spin-locked — do not paraphrase.

## What to verify

- Hover hatch or rope coil → parchment tip **Head home** / **Bring home everything you're holding.**
- Hover gate → parchment tip **Push deeper** / **Keep your sack. Dungeon {n} is waiting.** with n = cleared+1.
- Click still climbs / delves immediately (no confirm modal). Title band `Dungeon {n} cleared!` unchanged. No Climb/Delve chrome planks.
- Campaign extract uses the same Head home / Push deeper hover strings (no Bank/Push plank chrome).
- Campaign top-right chips show real biome name + count (e.g. `Ashen Crypt cabinet` + `3/5`) — never literal `{biome}` or `{n}`. Adventure / non-campaign rest shows no campaign chips.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | after a clear; hover hatch | parchment shows Head home + body; hatch brightens | 01-climb-hover.png |
| 02 | rope exit | hover gate | parchment shows Push deeper + Dungeon {n}; gate brightens | 02-delve-hover.png |
| 03 | rope exit | idle adventure clear (no campaign) | title band only; no Climb/Delve planks; no `{biome}` / `{n}` chips | 03-idle-no-planks.png |
| 04 | rope exit | campaign extract rest | top-right chips filled (biome name + n/5), no braces | 04-campaign-chips-filled.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261103-rope-exit-hover-spin/`
