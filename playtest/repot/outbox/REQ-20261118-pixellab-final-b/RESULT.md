---
id: REQ-20261118-pixellab-final-b
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-18T19:20:00-06:00
machine: Cherry
tip_sha: TBD
requested_tip_sha: 557c2f73
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; native Viewport PNG saves 1680x1040
---

# Result

Checkout `playtest/latest` already contains `557c2f73` (PR **#558** merged). On-screen BuildStamp `67d15f11*`. Input: godot-mcp `Viewport.push_input` mouse and `godot_input` keys. No computer-use, `_dev_*`, Grant, DevChrome, or forced poses. Title screen was used only as the playtest hub (Brand New); emblems were checked on disk, not by opening a dedicated emblem view.

Fresh `user://` wipe (backup `_repot_backup_20261118_pixellab_final_a2b`, hashes restored after Stop). Editor log errors empty. Combat log on some fight shots includes `ATK`.

| id | verdict | note |
|----|---------|------|
| 01 | fail | `01-spin-land-burst.png` is the settled Golem face after Spin. Gold `land_burst` on the seat was not readable in the burst (`01-spin-land-burst-f*`). Pointer is on the seat. |
| 02 | fail | No heal after damage this path. No `02-heal-sparkle.png`. |
| 03 | fail | Arrow Head was in hand; click opened inspect (`03-arrow-flight.png`, `Attack 6` / ability `ATK`). No in-flight arrow sprite. |
| 04 | fail | Shuriken never dealt. No `04-shuriken.png`. |
| 05 | fail | No Measuring Tape / Last Match / Orb / other signature item used. Sledgehammer was in the draft row but not swung. No `05-defeat-signature.png`. |
| 06 | fail | No readable tan-tinted `defeat_poof` at a tossed card. No `06-card-toss-poof.png`. |
| 07 | fail | Net / Smoke / Bag / Saucer not used. No `07-utility-moment.png`. |
| 08 | fail | Exterior porch → cabin path captured (`08-iris-wipe.png` from `_burst_iris_4.png`; settled cabin `08-cabin-settled.png`). Optional iris ring overlay is not readable. |
| 09 | pass | Held map: Crystal Cavern is the pool-2 stamp (cloudy/locked art), Verdant Hollow gold, Sprout on Verdant, route dashes, START HERE (`09-crystal-stamp-map.png`). Native 1680×1040. |
| 10 | fail | Trophy hall not walked (D was injected while the tree was paused on Nib dialog). No `10-hall-candle-dust.png`. |
| 11 | fail | Tutorial gold hole around the wheel is visible (`11-tutorial-pointer.png`). Glove bob + arrowhead sprites were not readable (`_arrows` stayed 0; gold rect only). |
| 12 | skip | Endless is sealed on the fresh Brand New map (`ENDLESS - SEALED`). Not reachable on this path. No `12-endless-hud.png`. |

Extra (not in table): Verdant splash `00-cue-leaf-splash.png` shows the small green leaf on “click anytime”. Nib `AnimatedSprite2D` SpriteFrames on cabin include `cheer` and `shrug` (not played — no success/miss hook this path). Title emblems exist under `assets/ui/title/emblem/` (files on disk; title not opened for them).

## Blockers

- Random mill did not deal Shuriken / signature Cheese this run.
- Short FX (land burst, arrow flight, iris ring, glove) did not land in the 50 ms burst windows.
- Endless sealed on a fresh save.

## Shots

Table files that exist: `01-spin-land-burst.png`, `03-arrow-flight.png`, `08-iris-wipe.png`, `09-crystal-stamp-map.png`, `11-tutorial-pointer.png`. Burst extras kept under `shots/`.
