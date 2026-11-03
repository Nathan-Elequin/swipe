---
id: REQ-20261103-look-h-mode-overlay
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-03T10:55:00-06:00
machine: Cherry
tip_sha: cb9d8347
godot: F5 playtest
viewport: 1680x1040
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | fail | Cream 2-up panel + caret + scrim + CHOICE/X above Knife, but Look C in-chrome tags remain and target icons/labels wash out (white on cream) |
| 02 | fail | Cream 3-row panel + prompt + CHOICE/X on Net; row labels/pips unreadable; in-chrome −1–3 tags still on the seat |
| 03 | fail | Cream 3-row overlay on Magnet (not in-chrome tags); Highest/Lowest/Off labels unreadable in the PNG |
| 04 | pass | Sling: CHOICE on legal cards, cancel X on Sling, no mode panel |
| 05 | pass | Hired Hand: Take arc reads Decline; pay seats glow; no mode panel |
| 06 | pass | Crossbow: neighbor wheel glow, hand dim, cancel X on Crossbow, no mode panel |

## Blockers

None. Overlay fade tween stays at alpha 0 while frozen; shots were taken after forcing panel/scrim modulate to 1 (intended shown state).

## Shots

All PNGs under `shots/` using the filenames from the request table. Native 1680×1040.
