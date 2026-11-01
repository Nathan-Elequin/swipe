---
id: REQ-20261101-biome-enter-splash
status: open
priority: high
tip_sha: pending
branch: cursor/biome-enter-splash-cfe4
created: 2026-11-01T21:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → cabin map → enter Verdant Hollow (b1)
---

# Biome-enter story splash (placeholder Verdant)

Placeholder-art biome-enter splash on map→biome enter. Layout/FX/copy locked; painted art later. Music starts once at splash appear (`music_biome_dungeon`); old call removed from `_begin_campaign_delve`.

## What to verify

- Entering Verdant from the campaign map shows the splash (art 1680×832, Sprout at 500,432 ×5 Nearest, chrome biome/dungeon/delves, narration bar, leaf + `click anytime`).
- Click anytime (including mid-dissolve) dismisses; no dwell timer; fade out ~0.2s then wheel nests ~0.45s TRANS_BACK; input locked until nest settles.
- Audio log: exactly one `music_to` / `music_biome_dungeon` per map enter; skip and nest do not re-music.
- Crystal Cavern (or any biome without `splash.biome.<slug>`) skips splash but still dissolves + music + nest.
- Leaving a biome (Leave / push-home / loss): soft dissolve out only — no splash.
- Endless: no splash, no biome music change from this path.
- No "Tier" / "Click to continue" / invented words on the splash.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | biome splash | map → Verdant enter; capture mid-hold (before click) | Verdant splash: chrome, Sprout, narration, leaf cue | 01-verdant-splash.png |
| 02 | play field | after click + nest settle | wheel nested at rest; splash gone | 02-wheel-after-nest.png |

## Pass criteria

- Shots at 1680×1040.
- Each expect readable in the PNG.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261101-biome-enter-splash/`
