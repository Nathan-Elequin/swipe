---
id: REQ-20261102-splash-narration-fit
status: open
priority: high
branch: cursor/splash-narration-fit-1cb6
base: playtest/latest
tip_sha: pending
created: 2026-11-02T15:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → campaign map → enter each tip biome (b1–b5); capture mid-hold on the biome-enter splash
---

# Biome splash narration fits inside the panel (3-line Cinder)

Cloud ship: Cinder Forge (`splash.biome.cinder_forge`) wrapped to 3 lines and the last line ("listening.") overflowed the narration bar border. Layout fix in `scripts/ui/biome_splash.gd` — wider wrap width (~1552), taller bar (236), even padding, cue stays bottom-right and clear of text. No player-facing copy changes. Nearest + ambient layering unchanged (ambient over art, under chrome). Cloud cannot F5 — Cherry drains this inbox.

## What to verify

- All five tip-biome splashes show narration fully inside the panel border with readable padding (not clipped, not past the inner/outer border).
- Cinder Forge 3-line wrap (or fewer after the wider label) still sits inside the bar.
- `click anytime` cue is visible bottom-right and not overlapped by narration.
- No word "Tier" anywhere on the splash.
- Ambient still over art / under chrome (spot-check; not the focus of this REQ).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | biome splash | map → Verdant enter; capture mid-hold | narration fully inside panel border with padding; no clipped/overflowing line; cue visible and not overlapped; no word Tier | 01-verdant.png |
| 02 | biome splash | map → Crystal enter; mid-hold | narration fully inside panel border with padding; no clipped/overflowing line; cue visible and not overlapped; no word Tier | 02-crystal.png |
| 03 | biome splash | map → Ashen enter; mid-hold | narration fully inside panel border with padding; no clipped/overflowing line; cue visible and not overlapped; no word Tier | 03-ashen.png |
| 04 | biome splash | map → Cinder enter; mid-hold | narration fully inside panel border with padding; no clipped/overflowing line (esp. final "listening."); cue visible and not overlapped; no word Tier | 04-cinder.png |
| 05 | biome splash | map → Shadow enter; mid-hold | narration fully inside panel border with padding; no clipped/overflowing line; cue visible and not overlapped; no word Tier | 05-shadow.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-splash-narration-fit/`
