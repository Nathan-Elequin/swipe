---
id: REQ-20261118-pixellab-final-a2
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-18T19:20:00-06:00
machine: Cherry
tip_sha: TBD
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; native Viewport PNG saves 1680x1040
---

# Result

Checkout `playtest/latest` at start `67d15f11` (PR **#557** / **#558** already merged here; on-screen BuildStamp `67d15f11*`). Input: godot-mcp `Viewport.push_input` mouse and `godot_input` keys (Space/Enter). No computer-use, `_dev_*`, Grant, DevChrome, seeded seating, or forced poses. Two real runs (Brand New tutorial ambush, then cabin map **START HERE** Verdant). Stopped before a 3rd/4th re-roll.

Fresh `user://` JSON wipe at start (backup `_repot_backup_20261118_pixellab_final_a2b`, SHA256 restored after Stop). Editor log errors empty this drain.

Combat log was opened by a click; several shots include the substring `ATK` in the log, not plate chrome.

| id | verdict | note |
|----|---------|------|
| 03 | fail | Take on Golem dropped HP 6→3. Burst `03-take-overlay-f4.png` (copied to `03-take-overlay.png`) shows hub **heart break** (split pink hearts). Claw/bite/thud overlay on Sprout is not readable. Native 1680×1040. |
| 04 | fail | No ice-blue clang / `hub_shield_crack`. Shield was in the tutorial hand but was not consumed before Skip left that fight. No `04-block-crack.png`. |
| 05 | fail | No Escape / Harpy leave this drain. No `05-escape.png`. |
| 06 | fail | No heal item used after damage. No `06-heal-refill.png`. |
| 07 | fail | `07-wheel-land.png` is the settled brass pointer on Golem after Spin. Tick-during-spin and land-burst frames were not caught (`_burst_spin2_*` is inspect overlay, not the burst). |
| 09 | fail | Throwing Knife entered targeting (`Used Throwing Knife - choose`) on `09-knife-strike.png`. Spin/arc frames from hotbar to monster were not caught. |
| 10 | fail | Knucklers never dealt in either run. No `10-knucklers.png`. |
| 11 | fail | Spiked Flail was in the tutorial hand, then Skip jumped to pool-reveal before a swing. Not used. No `11-flail.png`. |
| 12 | fail | The Boot was dealt (Verdant draft). Click opened a two-card picker (`12-boot.png`), not `da_boot_stomp` over a monster. |
| 13 | fail | Spinning Top never dealt. No `13-top.png`. |
| 14 | fail | Imp never seated. No `14-cutin-imp.png`. |
| 15 | fail | Glass Asp never seated. No `15-cutin-glass-asp.png`. |
| 16 | fail | Fungal Colony never seated in these two fights (it appears on the pool-reveal grid only). No `16-cutin-fungal.png`. |

## Blockers

- Two runs only. Cards never dealt: Knucklers, Spinning Top; Imp / Glass Asp / Fungal Colony never seated. Spiked Flail was dealt in run 1 and unused after Skip.
- Transient FX is a few hundred ms; Take heart-break was caught, claw overlay was not.
- Open combat log prints `ATK` on several shots.

## Shots

Canonical PNGs under `shots/` at 1680×1040: `03-take-overlay.png`, `07-wheel-land.png`, `09-knife-strike.png`, `12-boot.png`. Burst folders (`03-take-overlay-f*.png`, etc.) kept as evidence. Rows 04–06, 10–11, 13–16 have no table file.
