---
id: REQ-20261103-dungeon-clear-resolve
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-03T17:55:00-06:00
machine: Cherry
tip_sha: 71d55e8130c5
feature_sha: 5311b4f0
godot: F5 playtest (godot-mcp)
viewport: 1680x1040
branch: playtest/latest
---

# Result

Shot on Cherry `playtest/latest` @ `71d55e81` (contains dungeon-clear resolve `5311b4f0` plus later rope-ladder merge `#354`). Entry: F5 hub skip intro → Middle Progress → `_begin_campaign_delve(0)` → empty wheel → `clear_parade.freeze_at`. Shots 01–07 held at 0.16 / 0.40 / 0.80 / 1.35 / 1.75 / 2.06 / 2.40. Shot 08 used `freeze_at = -1` and was captured ~0.5 s after return. Viewport PNGs 1680×1040. No burrow mouth, curtain, mound, hero_arrive, land dust, burst, or embers in any frame.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Overlay Sprout only, hub hole empty, dungeon BG in a thin 1-o'clock slit. Wheel still reads as a **full disc**, not wedges fanned to the bottom hinge. No rope. |
| 02 | pass | Wheel gone, gold aura at the hub, dungeon BG fully visible, Sprout on victory, no burrow/mound/curtain. Aura sits at hub center, not the bottom rim. |
| 03 | pass | Right-facing `sprout_victory`, ~96 px, no wheel/burst/embers. Same hub baseline as 04. |
| 04 | pass | Crouch squash on f0, feet on the same hub baseline as 03. |
| 05 | fail | Falling f2 in the lower third, **no** black dissolve rising from the bottom. Dungeon + Spin still fill the frame. No curtain. |
| 06 | pass | Mostly black; Rope Exit bottom band under chunky dissolve teeth; Sprout entering from the top. No arrive pop-up, no land dust. Wipe continues upward vs 05's missing cover. |
| 07 | pass | One Sprout on the Rope Exit rug squash/land spot; chamber at full alpha. Pale glow in the right gate is rope-ladder art on this tip (`#354`), not a second overlay hero. |
| 08 | pass | Rope Exit interactive (`phase=rest`, rope visible, modulate alpha 1, `hub_parade_hide=false`). Live `-1` run left `dungeons_cleared=1` and one `end dungeon 1` from that run. Earlier freeze holds at 2.06/2.40 also committed, so the session log has extra `end dungeon 1` rows from those holds. Clicks live after (`_clear_resolving=false`). |

## Blockers

None for capture. Two visual fails (01 fold shape, 05 missing wipe). Checkout is origin `playtest/latest` `71d55e81`, not detached `5311b4f0`.

## Shots

All eight request filenames under `shots/` at 1680×1040.
