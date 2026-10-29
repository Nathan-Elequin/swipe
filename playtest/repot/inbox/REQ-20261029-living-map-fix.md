---
id: REQ-20261029-living-map-fix
status: open
priority: high
pr: 184
tip_sha: abdd0724
branch: cursor/living-map-hover-name-7e62
created: 2026-10-29T17:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / DEV "Fill the Verdant Hollow cabinet" → cabin → open held map → hover a Sunken Mire Deadly
---

# Living map hover name readability fix

Follow-up to [REQ-20261029-living-map](REQ-20261029-living-map.md) / PR #180. Local repot scored 5 pass / 1 fail on shot `03-hover-name.png`: hover lifted the Sunken Deadly 14px and showed the gold **DEADLY** chip, but the catalog name (e.g. "Basilisk") did not read on the parchment — the cream plank blended into the map and/or collapsed.

**Root cause (code):** `MapMonster._build_tag` put a `FitLabelBox` inside `PanelContainer` → `HBoxContainer`. Container layout ignores `apply_rect` size, and without `grow_to_text` the name box's min size is 0×0, so only the plain-Label gold chip survived. Also `StyleBoxFlat.shadow_size` was `0`, so the hard-shadow offset never drew and the cream plank had no separation from the parchment.

**Fix:** `grow_to_text` on the name FitLabelBox (same pattern as cabin map tips / hall hover tags), darker ink `#1A120E`, brighter plank `#FFF6DE`, `shadow_size = 4` hard drop shadow, and `_place_tag` refits before measuring. Lift 14px, gold DEADLY via `player_copy.tier_name(3)`, other sprites still patrol, click still does nothing, M-peek / seed / telegraph-removed unchanged. No new art. Does not touch biome quiet bg or trophy hall. Does not rewrite Grandpa’s Map STUB plate copy.

## What to verify

- Hover a Sunken Mire Deadly: catalog name is clearly readable on the plank (at least as readable as the gold DEADLY chip).
- Gold **DEADLY** chip still shows (never the word "Tier").
- Sprite lifts ~14px; other Deadlies keep patrolling.
- Clicking the hovered monster still does nothing.
- No player-facing "Tier" anywhere on the tag.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | held map | DEV fill Verdant → open map → hover a Sunken Mire Deadly | Catalog name readable on cream plank + gold DEADLY chip; sprite lifted ~14px | 01-hover-name-readable.png |
| 02 | held map | Same hover, wait ~1–2 s (or second frame) | Second Sunken / other biome sprite still walking its lane while hover target is paused | 02-hover-other-still-walking.png |
| 03 | held map | Move off the monster | Tag gone; sprite back down; patrol resumes | 03-hover-exit.png |

## Pass criteria

- All three PNGs under `playtest/repot/outbox/REQ-20261029-living-map-fix/shots/` at 1680×1040 (godot-mcp preferred).
- `01` name text is readable without guessing; DEADLY chip present; no "Tier".
- `02` shows at least one non-hovered sprite mid-patrol (different foot position than a frozen idle).
- `03` confirms tag hides on exit.
- Tip SHA in RESULT.md is this PR’s tip at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261029-living-map-fix/`
