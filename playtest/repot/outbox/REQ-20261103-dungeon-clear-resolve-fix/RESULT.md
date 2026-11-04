---
id: REQ-20261103-dungeon-clear-resolve-fix
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-04T00:50:00-06:00
machine: Cherry
tip_sha: a3ab886c5140
feature_sha: afacc323
godot: F5 playtest (godot-mcp)
viewport: 1680x1040
branch: playtest/latest
---

# Result

Shot on Cherry `playtest/latest` @ `a3ab886c` (contains dungeon-clear resolve fix `afacc323` / request stamp `54df8615`, plus later `playtest/latest` merge). Entry: F5 hub skip intro → Middle Progress → `_begin_campaign_delve(0)` → empty 6-seat wheel → `clear_parade.freeze_at`. Shots 01–07 held at 0.16 / 0.40 / 0.80 / 1.35 / 1.75 / 2.06 / 2.40. Shot 08 used `freeze_at = -1` and was captured after return with hub flags restored. Viewport PNGs 1680×1040 (native framebuffer 1550×960 nearest-scaled; editor game pane would not grow). No burrow mouth, curtain, mound, hero_arrive, land dust, burst, or embers in any frame.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Reverse accordion: wedges fanned to the bottom hinge, dungeon BG in the gaps, not a full opaque disc. One overlay Sprout; hub hole empty. Spin arrows/counter gone. No rope. |
| 02 | pass | Wheel gone (fold≈0.95). Gold aura bloom under Sprout at the hub. Dungeon BG fully visible. Victory pose. No burrow/mound/curtain. |
| 03 | pass | Right-facing `sprout_victory` (~96 px), arms up, no wheel/burst/embers. Same hub baseline as 04. |
| 04 | pass | Crouch squash on f0, feet on the same hub baseline as 03. |
| 05 | pass | Rising black dissolve with chunky teeth covering the lower band. Runtime `hero_y≈790` (lower third, f2); Sprout sits in the wipe so the PNG only peeks teal. `btn_spin` visible=false, modulate.a=0. Wipe progress≈0.48. No curtain. |
| 06 | pass | Mostly black; Rope Exit floor band under chunky dissolve teeth; Sprout entering from the top (`hero_y≈218`). No arrive pop-up, no land dust. Wipe continues upward vs 05. `visual_only=true`, `dungeons_cleared` still 0. |
| 07 | pass | One Sprout on the Rope Exit rug (land squash). Chamber at full alpha (`rope_a=1`). `ResolveInputLock` mouse_filter STOP. Pale glow in the right gate is rope-ladder art (`#354`), not a second overlay hero. Wipe progress=2. |
| 08 | pass | Rope Exit open (`phase=rest`, `rope_a=1`, `_clear_resolving=false`, `hub_parade_hide=false`). Live `-1` run left `dungeons_cleared=1` and **one** session_log `end dungeon 1` after seven freeze holds (those holds stayed `visual_only` / `cleared=0`). Clicks live after (parade node and lock gone). |

## Blockers

None. Checkout is origin `playtest/latest` `a3ab886c`, not detached `afacc323`. Embedded game window stayed 1550×960; files are 1680×1040 nearest from that framebuffer.

## Shots

All eight request filenames under `shots/` at 1680×1040.
