---
id: REQ-20261118-pixellab-final-a
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-18T18:35:00-06:00
machine: Cherry
tip_sha: 77ac403fb67a73b0058284d44248a5e331032fb3
requested_tip_sha: 3d0eb148
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; native Viewport PNG saves 1680x1040
---

# Result

Checkout `playtest/latest` @ `77ac403f` (PR **#557** already merged here; on-screen BuildStamp `2977a253*`). Input: godot-mcp `Viewport.push_input` mouse and `godot_input` keys (Space). No computer-use, `_dev_*`, Grant, DevChrome, seeded seating, or forced poses.

Fresh `user://` JSON wipe at start (backup `_repot_backup_20261118_pixellab_final_a`, restored after Stop). Path: Skip intro → living-trophy **Middle Progress** → map **START HERE** (Verdant) → real draft/fight.

Editor log: no texture-missing errors this drain (`get_log_messages` errors empty). Combat log (opened by a click) prints `ATK` on several shots — that is the log, not plate chrome.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Pixel spark + blood on Eel facing portrait during Sai 2-damage hit (`01-hit-light.png`). Not a Kenney star. Native 1680×1040. |
| 02 | pass | Eel **SLAIN** banner, body in smoke, gray soul-wisp rising off the facing plate (`02-kill-poof.png`). Seat X marks on slain slices. Native 1680×1040. |
| 03 | fail | Beggar Take shows hub **heart break** (split pink heart over Sprout) and log `HP take -2` (`03-take-overlay.png`). Claw/bite/thud overlay on the hero is not readable. |
| 04 | fail | Buckler applied (+4 Block) then a later Take spent Block, but no ice-blue clang / `hub_shield_crack` frame was caught. No `04-block-crack.png`. |
| 05 | fail | No Escape / Harpy / Escaped seat this run. No `05-escape.png`. |
| 06 | fail | Victory Flask fire + green heal beam (`06-heal-refill.png`). Heart-refill frame strip on the pips is not readable. |
| 07 | fail | Brass pointer sitting on Scorpion after Spin settled (`07-wheel-land.png`). Tick-during-spin and land-burst frames were not caught. |
| 08 | pass | Sledgehammer card flying over the wheel onto Eel (6 ATK, legal Defeat) plus SLAIN (`08-sledgehammer.png`). Native 1680×1040. |
| 09 | fail | Throwing Knife never in the live hand this Middle Progress deal. No `09-knife-strike.png`. |
| 10 | fail | Knucklers never dealt. No `10-knucklers.png`. |
| 11 | fail | Spiked Flail never dealt. No `11-flail.png`. |
| 12 | fail | The Boot never dealt. No `12-boot.png`. |
| 13 | fail | Spinning Top never dealt. No `13-top.png`. |
| 14 | fail | Imp never seated. No `14-cutin-imp.png`. |
| 15 | fail | Glass Asp never seated. No `15-cutin-glass-asp.png`. |
| 16 | fail | Fungal Colony seated on the wheel (idle plate visible) but its slash cut-in never played before the run ended. No `16-cutin-fungal.png`. Dragon Firebreather slash *did* play (not in the table). |

## Blockers

- Starter strike cards (Knife / Knucklers / Flail / Boot / Top) and Imp / Glass Asp were not in this mill deal. Fungal Colony appeared late; slash never triggered before death.
- Transient FX is ~few hundred ms; several Takes hit Dragon slash cut-in or resolved before a still showed clang/crack.
- Open combat log includes the substring `ATK` on shots 01/02/07/08.

## Shots

Table PNGs that exist are under `shots/` at 1680×1040: `01`, `02`, `03`, `06`, `07`, `08`. Rows 04–05 and 09–16 have no file.
