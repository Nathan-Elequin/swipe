---
id: REQ-20261029-biome-quiet-bg-fix
status: done
priority: high
branch: cursor/biome-quiet-bg-fix-94e8
base: playtest/latest
created: 2026-10-29T17:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → Gatehouse / campaign map → start Verdant (b1) delve. For shot 02, leave and start a Cinder (b4) delve (or call dungeon_bg.set_biome("b4") in the same hall). Confirm tint is readable at a glance vs black, and that 01 vs 02 clearly differ in hue.
---

# Fix: biome hall tint must be visible

PR #178 wired quiet biome strips, but opaque floor tiles covered the behind-tile draw and the PNGs were near-clear-dark, so Verdant and Cinder halls looked identical (edge means ~rgb 21,16,12 in both). Fix: re-bake brighter stepped glow strips; paint them with a TextureRect + CanvasItemMaterial ADD above the floor (wheel / Sprout / cards stay on higher-z nodes).

## What to verify

- Verdant (b1) hall shows a quiet but clearly green-tinted glow — readable at a glance vs black.
- Cinder (b4) hall reads warm orange, and **mean edge colour clearly differs from shot 01** (green-dominant vs red/orange-dominant).
- Wheel faces, Sprout, and item cards stay fully readable (not washed out).
- Sampling is Nearest — glow edges stay stepped/pixel, not blurred.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon hall | Verdant (b1) delve, idle fight hub | Quiet green/lime glow clearly visible in the hall (edges and mid-ring); not a flat black plate | 01-verdant-hall-tint.png |
| 02 | dungeon hall | Cinder (b4) delve (or set_biome("b4")) | Warm orange tint; **visibly different from 01** — left/right edge means red/orange-dominant, not matching Verdant green | 02-cinder-hall-tint.png |
| 03 | dungeon hall | Same as 01 with wheel + Sprout + item cards visible | Wheel faces, Sprout, and item cards remain readable; tint does not wash them out | 03-wheel-sprout-readable.png |
| 04 | dungeon hall | Close look at glow edge / dust pixels | Nearest sampling — no blur / soft mip; stepped glow | 04-nearest-edges.png |

## Pass criteria

- All four PNGs under `playtest/repot/outbox/REQ-20261029-biome-quiet-bg-fix/shots/` at 1680×1040 (godot-mcp preferred).
- 01 vs 02 edge colour must clearly differ (green channel dominant for Verdant; red/orange dominant for Cinder). Optional headless: `xvfb-run -a godot --path . --script res://tools/qa/check_biome_tint.gd`.
- 03 keeps wheel/Sprout/cards readable; 04 confirms Nearest.
- Tip SHA in RESULT.md is this PR’s tip (or `playtest/latest` after merge) at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261029-biome-quiet-bg-fix/`
