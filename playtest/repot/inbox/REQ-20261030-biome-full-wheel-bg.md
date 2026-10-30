---
id: REQ-20261030-biome-full-wheel-bg
status: open
priority: high
tip_sha: 340b2f77
branch: cursor/biome-full-wheel-bg-5c40
base: playtest/latest
created: 2026-10-30T18:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → Gatehouse / campaign map → start each biome delve (b1 Verdant Hollow, b2 Crystal Cavern, b3 Ashen Crypt, b4 Cinder Forge, b5 Shadow Abyss). Shoot the idle fight hub with the wheel visible.
---

# Full-art biome backgrounds behind the dungeon wheel

Nathan-approved 1680×1040 RGB plates under `assets/ui/biome_full/bg_wheel_b1.png`…`b5.png` paint behind the wheel. Loader prefers full-art (CanvasItemMaterial MIX @ alpha ~1.0); quiet tint strips at `assets/ui/biome_bg/bN.png` remain the ADD @ ~0.50 fallback. Opaque floor/wall/dais blit is skipped under a full-art plate so scenery reads. Wheel stays above (z=0). Quiet center under the wheel is OK.

## What to verify

- Each biome hall shows its full-art plate behind the wheel (not a washed ADD ghost).
- Plate colour / poster art is readable at the edges; quiet/darker center under the wheel is fine.
- Wheel faces and Sprout stay on top and readable.
- Mapping: b1 Verdant Hollow, b2 Crystal Cavern, b3 Ashen Crypt, b4 Cinder Forge, b5 Shadow Abyss.
- No player-facing "Tier" or "Sunken Mire" copy in these shots.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon hall | Verdant Hollow (b1) delve, idle fight hub, wheel visible | Full verdant poster art behind wheel; MIX (solid), not ADD-ghosted; quiet center under wheel OK | 01-verdant-full-bg.png |
| 02 | dungeon hall | Crystal Cavern (b2) delve, idle fight hub | Crystal full-art plate behind wheel; distinct from Verdant | 02-crystal-full-bg.png |
| 03 | dungeon hall | Ashen Crypt (b3) delve, idle fight hub | Ashen full-art plate behind wheel | 03-ashen-full-bg.png |
| 04 | dungeon hall | Cinder Forge (b4) delve, idle fight hub | Cinder/orange forge full-art behind wheel | 04-cinder-full-bg.png |
| 05 | dungeon hall | Shadow Abyss (b5) delve, idle fight hub | Shadow/indigo abyss full-art behind wheel | 05-shadow-full-bg.png |

## Pass criteria

- All five PNGs under `playtest/repot/outbox/REQ-20261030-biome-full-wheel-bg/shots/` at 1680×1040 (godot-mcp preferred).
- Each shot shows full-art scenery behind the wheel, not a faint ADD wash over tiled floor.
- Wheel remains readable on top in every shot.
- Tip SHA in RESULT.md is this PR’s tip (or `playtest/latest` after merge) at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261030-biome-full-wheel-bg/`
