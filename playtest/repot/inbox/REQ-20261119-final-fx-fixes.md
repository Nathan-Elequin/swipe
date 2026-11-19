---
id: REQ-20261119-final-fx-fixes
status: open
priority: high
branch: cursor/fix-pixellab-final-fx-9624
created: 2026-11-19T15:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New (tutorial) and Middle Progress → Verdant fight. Fresh save. godot-mcp Viewport.push_input / injected keys only — never OS input.
---

# Fix PixelLab final FX — Take claw, tutorial glove/arrow, heal refill

Cloud ship of three real-player drains from REQ-20261118-pixellab-final-a / a2 / b. No Godot MCP on this agent — local Cursor must shoot on Cherry.

## What to verify

- On Take that removes HP: PixelLab claw/bite/thud overlay plays over the hub hero (not only the heart-break pip).
- Tutorial B03 (wheel spotlight): gold hole plus readable glove bob + arrowhead (`_arrows` non-empty).
- Heal (Victory Flask or any heal after damage): heart_refill strip lands on hub heart pips, readable for ≥ ~0.35s.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Fresh Middle Progress → take damage (burst 3–4 frames ~60ms apart) | claw/bite/thud overlay visible over Sprout/hub on Take; heart break may also show | 01-take-claw-f0.png … 01-take-claw-f3.png (and 01-take-claw.png = best frame) |
| 02 | tutorial | Brand New → B03 “GOOD news… enemies” (wheel focus) | gold hole on the wheel plus glove + arrowhead shaft readable | 02-tutorial-glove-arrow.png |
| 03 | combat | After damage, use a heal (Victory Flask / Lantern / etc.) | heart_refill frames on the hub pips, readable size/duration | 03-heal-refill.png |

## Pass criteria

- All rows shot at 1680×1040 from a real F5 player path (no `_dev_*`, Grant, DevChrome, seeded seating, or forced poses).
- Input: godot-mcp injected only.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261119-final-fx-fixes/`
