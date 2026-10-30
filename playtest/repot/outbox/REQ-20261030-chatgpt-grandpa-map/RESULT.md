---
id: REQ-20261030-chatgpt-grandpa-map
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-30T14:50:00-05:00
machine: Cherry
tip_sha: 597d256a
godot: F5 playtest (godot-mcp)
viewport: 1680x1040
---

# Result

F5 playtest hub → Brand New (`_playtest_brand_new`) → dismiss playtest intro → `_open_campaign_map`. Viewport 1680×1040. Tip `597d256a` on `playtest/latest`. Shots 03–04 after DEV fill-every-cabinet (`win`) + `mark_drawer_seen` so Shadow / Endless wax stamps exist.

| id | verdict | note |
|----|---------|------|
| 01 | pass | ChatGPT plate fills 1680×1040: title “Grandpa's Map of Mount Grumblegut”, zig-zag painted badges, hands on the bottom edge. Not the old Doop living-map plate. |
| 02 | fail | Verdant is the START pin (flag + green dot), not a WaxStamp. Hover shows “START HERE” over the green badge; no peel tween. Overlay still sits on the painted Verdant Hollow badge. |
| 03 | pass | After fill-all: Shadow WaxStamp peels (~12px / −16°) with “click to set off”. Hit centre 1020,798 on the painted purple eye badge (not floating left). |
| 04 | pass | Endless stamp at ENDLESS_AT 410,856 sits on the painted dark bottom-left seal (infinity wax over the printed circle), not empty parchment far left. |

## Blockers

None for capture. Row 02 fails the peel expect because `held_map.gd` uses `_add_start` for biome index 0.

## Shots

All four PNGs under `shots/` at 1680×1040.
