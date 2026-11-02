---
id: REQ-20261102-biome-splash-pages
status: open
priority: high
branch: cursor/biome-splash-multipage-ff2d
base: playtest/latest
created: 2026-11-02T20:05:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → campaign map → enter each tip biome (b1–b5); on splash, capture page 1, click once for page 2, click again for page 3, then click to dismiss
---

# Biome splash multi-page narration (2–3 pages)

Cloud ship: biome-enter splash now shows Spin-locked page chains (`splash.biome.<slug>.p1/.p2/.p3`) for all five tip biomes. Same BG / ambient / chrome across pages. Soft text swap between pages; full dissolve only on enter/exit. Cue stays `click anytime`. Cloud cannot F5 — Cherry drains this inbox.

## What to verify

- Page 1 shows `.p1` for that biome; click advances to `.p2`, then `.p3`, then dismiss / play_out (music + dissolve-to-delve unchanged).
- Same painted BG and leaf cue (`click anytime`) across all three pages; no full splash dissolve between pages.
- No word "Tier" on the splash.
- Chrome biome / dungeon / delves wording unchanged.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | biome splash | Verdant enter; hold page 1 | p1 text readable; same BG; cue `click anytime` | 01-verdant-p1.png |
| 02 | biome splash | Verdant; click → page 2 | p2 text; same BG/chrome as 01 | 02-verdant-p2.png |
| 03 | biome splash | Verdant; click → page 3 | p3 text; same BG/chrome | 03-verdant-p3.png |
| 04 | biome splash | Crystal enter; page 1 | Crystal p1; cue visible | 04-crystal-p1.png |
| 05 | biome splash | Crystal page 2 | Crystal p2; same BG | 05-crystal-p2.png |
| 06 | biome splash | Ashen page 1 | Ashen p1 | 06-ashen-p1.png |
| 07 | biome splash | Cinder page 1 | Cinder p1 | 07-cinder-p1.png |
| 08 | biome splash | Shadow page 1 | Shadow p1 | 08-shadow-p1.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-biome-splash-pages/`
