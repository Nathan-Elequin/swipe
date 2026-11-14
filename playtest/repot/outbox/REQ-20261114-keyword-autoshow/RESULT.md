---
id: REQ-20261114-keyword-autoshow
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T04:40:00-06:00
machine: Cherry
tip_sha: 02859d51518ecde6bacc6eee176b010c83583003
godot: F5 playtest, real mouse/keys (computer-use on Spinheritance DEBUG). No time freeze, no _dev_*, no preview_*, no show_def, no cheat buttons.
viewport_grab: framebuffer 1550x960; table PNGs nearest-upscaled to 1680x1040; natives kept as *-native.png
---

# Result

Checkout `playtest/latest` @ `02859d51`. On-screen BuildStamp `02859d51*` on every step (hub, intro, cabin, map, Verdant splash, fight). Brand New from a fresh save. `user://` backed up to `_repot_backup_20261114_keyword_autoshow` and restored (SHA256 match on all six JSON files).

| id | verdict | note |
|----|---------|------|
| 01 | pass | Brand New hotbar hover **The Boot**. One parchment **Defeated** at design rect `(815, 696, 296, 228)` beside the plate `(1123, 696, 280, 190)`. Full def readable (`content_h == size_h`, `scroll_active=false`, `visible_ratio=1`). Does not intersect the plate. Stays inside 1680×1040. No wheel overlap (card is over the hotbar). No “Tier” / “ATK” on the parchment. Shot: `01-hotbar-one-kw.png`. SHA `02859d51*`. |
| 02 | fail | Closest many-keyword hotbar item was **Poison Flask** (plate chips Neighbor + Poison). Autoshow stacked **only `poison`** — Neighbor is painted on the plate but is not in `KeywordDefs.ids()`, so it never becomes a card. Never found a Brand New opening/draft card with 3+ registered `kw:` ids. Shot: `02-hotbar-many-kw.png` (one Poison card, not a 3+ stack). SHA `02859d51*`. |
| 03 | fail | Real draft after Boot-Defeated Dire Wolf: **Sai / Throwing Knife**, “Pick one. Hover to read it.” Hovering Throwing Knife opened the inspect plate (`Attack 3` / Keep). KeywordStack stayed empty (`Keep` / `ATK` are not `url=kw:` ids). No parchment beside the draft plate. Shot: `03-draft-pick.png`. SHA `02859d51*`. |
| 04 | fail | Hover **Needleback** on the wheel. Inspect plate opened (Spiky / Attack text). Registered keyword stack empty — Attack is colored, not a `kw:` chip. Nothing besides the plate covered the wheel. Shot: `04-wheel-monster.png`. SHA `02859d51*`. |
| 05 | pass | No named boss on first Verdant Brand New wheel. Used high-tier **Dire Wolf** (Kill Shot, facing inspect after Spin). Autoshow **Always** parchment `(1328, 104, 296, 168)`, full text, on-screen, to the right of the wheel, not covering the wolf plate. No “Tier” / “ATK” on that card. Shot: `05-boss.png`. SHA `02859d51*`. |
| 06 | pass | First unseen registered keyword on Brand New: **Poison** on Poison Flask. `first_sight=true`, `_star.visible=true` (gold `new_star` on the card corner), card `(1168, 24, 296, 318)` inside 1680×1040. Shot: `06-first-sighting.png`. SHA `02859d51*`. |
| 07 | pass | Hovered combat-log line `Draft gain Poison Flask`. Log KeywordStack `src=log` ids `[poison]`. Poison parchment sat in the log column; full def readable; stays on screen. Leaving that line is what the player does next (not frozen). Shot: `07-log-line.png`. SHA `02859d51*`. |

## Extra (not in the REQ table)

- Eel / Hornet / Net inspect: Attack / Block colored on the plate, **no** parchment, because those words are not `[url=kw:…]`.
- Wizard on the wheel after the wolf died: empty ability plate, no stack.

## Blockers

- Play window framebuffer **1550×960**; table files nearest-scaled to 1680×1040. Natives: `*-native.png`.
- Brand New Verdant Hollow has no dungeon boss and no hotbar/draft card with 3+ registered keyword ids.

## Save restore

Backup `%APPDATA%\Godot\app_userdata\Spinheritance\_repot_backup_20261114_keyword_autoshow`. After Stop Play, SHA256 matched:

- home_cabin.json `7B5066D7418F6D8C386AFE39DDF24D0D0B56FF0552B21B6B644A88D9ADDEEE48`
- campaign_save.json `62612FCADF4E3826E83DF48869DE72D63572BB4D08A1D3D321D1F8FC7CBCB54C`
- bucket_progress.json `50FC018FB6625F2C6A9FDBBC3CE71FCD0B594994500AD1AD75968FACB471985A`
- playtest_meta.json `BC9714F75CEB2F34E17ED409A16C54BEACC251404A770F84DD990B851727C2EA`
- playtest_anon.json `DF3BC46BF4A5562020B5E2352B67567CC463F6DFB7CF5A080833460C80321219`
- audio.json `D2100D115DC8212063322704C7F435FE8BEA8F9061A15E1239BE5EB261CCC1C5`

## Shots

`playtest/repot/outbox/REQ-20261114-keyword-autoshow/shots/` — table filenames at 1680×1040; `*-native.png` is the 1550×960 grab.
