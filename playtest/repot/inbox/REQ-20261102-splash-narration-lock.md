---
id: REQ-20261102-splash-narration-lock
status: open
priority: high
branch: cursor/splash-narration-spin-lock-d7e5
base: playtest/latest
created: 2026-11-02T17:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → campaign map → enter each tip biome (b1–b5); capture mid-hold on the biome-enter splash
---

# Biome splash Spin narration lock (first-person)

Cloud ship: replace Mad Libs biome-enter narrations with Spin-locked first-person plain fiction for all five tip biomes. Exact keys `splash.biome.verdant_hollow|crystal_cavern|ashen_crypt|cinder_forge|shadow_abyss`. Chrome unchanged. Layout: narration bar **BAR_H 340**, **NARR_MAX_LINES 5**, wrap width 1552 — prefer fitting Spin’s full paragraphs over cutting words. Ambient VFX / painted BGs untouched. Cloud cannot F5 — Cherry drains this inbox.

## What to verify

- Each tip-biome splash shows the new Spin paragraph in full (readable, no clip at bottom of the narration panel).
- Cue `click anytime` stays bottom-right and clear of narration.
- No word "Tier" anywhere on the splash.
- Chrome biome / dungeon / delves lines unchanged in wording.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | biome splash | map → Verdant enter; capture mid-hold | full Spin paragraph readable inside narration panel; no bottom clip/overflow; cue visible; no Tier | 01-verdant.png |
| 02 | biome splash | map → Crystal enter; mid-hold | full Spin paragraph readable inside narration panel; no bottom clip/overflow; cue visible; no Tier | 02-crystal.png |
| 03 | biome splash | map → Ashen enter; mid-hold | full Spin paragraph readable inside narration panel; no bottom clip/overflow; cue visible; no Tier | 03-ashen.png |
| 04 | biome splash | map → Cinder enter; mid-hold | full Spin paragraph readable inside narration panel; no bottom clip/overflow; cue visible; no Tier | 04-cinder.png |
| 05 | biome splash | map → Shadow enter; mid-hold | full Spin paragraph readable inside narration panel; no bottom clip/overflow; cue visible; no Tier | 05-shadow.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-splash-narration-lock/`
