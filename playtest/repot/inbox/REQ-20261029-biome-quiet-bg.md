---
id: REQ-20261029-biome-quiet-bg
status: done
priority: high
branch: cursor/biome-quiet-bg-d206
base: playtest/latest
created: 2026-10-29T09:05:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → Gatehouse / campaign map → start Verdant (b1) delve. For shot 02, leave and start another biome (or cheat biome) so the tint changes. Locked look ref: biome-quiet/strips_all.png (Pixel approved).
---

# Quiet biome hall backdrops

Five 420×260 Nearest PNGs under `assets/ui/biome_bg/b1.png`…`b5.png` tint the dungeon hall after the `#0a0807` clear, full-rect, ~0.55–0.65 alpha, behind floor tiles. Soft stepped radial glow from tip wax colours; no props/text. Wired via `dungeon_bg.set_biome(id)` from campaign compose / current biome / cabin return. Null-safe if texture missing (endless has no PNG).

## What to verify

- Verdant (b1) hall shows a quiet green tint behind the floor tiles, not a flat black plate.
- Switching biome changes the tint colour (tan / red / orange / indigo).
- Wheel and Sprout stay readable on top of the tint.
- Sampling is Nearest — glow edges stay stepped/pixel, not blurred.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon hall | Verdant (b1) delve, idle fight hub | Quiet green/lime glow visible behind floor tiles at ~0.6 alpha; dark plate still reads; floor tiles on top | 01-verdant-hall-tint.png |
| 02 | dungeon hall | Switch biome (map pick or cheat) then enter hall | Tint colour changes to match the new biome (not still Verdant green) | 02-biome-switch-tint.png |
| 03 | dungeon hall | Same as 01 with wheel + Sprout visible | Wheel faces and Sprout remain readable; tint does not wash them out | 03-wheel-sprout-readable.png |
| 04 | dungeon hall | Close look at glow edge / dust pixels | Nearest sampling — no blur / soft mip; stepped glow and 1px dust | 04-nearest-no-blur.png |

## Pass criteria

- All four PNGs under `playtest/repot/outbox/REQ-20261029-biome-quiet-bg/shots/` at 1680×1040 (godot-mcp preferred).
- 01 shows Verdant tint behind floor; 02 shows a different biome tint; 03 keeps wheel/Sprout readable; 04 confirms Nearest.
- Tip SHA in RESULT.md is this PR’s tip (or `playtest/latest` after merge) at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261029-biome-quiet-bg/`
