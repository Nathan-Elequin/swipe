---
id: REQ-20261030-trophy-hall-dumbwaiter
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-30T12:45:00-05:00
machine: Cherry
tip_sha: df90655dfde8e35b89945bc61267ec7d10a7b663
godot: F5 playtest (godot-mcp)
viewport: 1680x1040
---

# Result

F5 playtest hub → Brand New (`_playtest_brand_new`) → grant rooms → `_snap_to("hall")`. Viewport 1680×1040. Tip `df90655d` on `playtest/latest`. Headless `biome_cabinets_selftest.gd` printed `BIOME_CABINETS_OK` (trophy PNG import warnings for b1/b3/b4/b5; asserts still green).

## Per-pool item + page counts (live `_group_cards_by_pool` / `page_count`)

| pool | items (`_live_pool`) | pages (10 slots) |
|------|----------------------|------------------|
| b1 Verdant Hollow | 12 | 2 |
| b2 Crystal Cavern | 11 | 2 |
| b3 Ashen Crypt | 13 | 2 |
| b4 Cinder Forge | 14 | 2 |
| b5 Shadow Abyss | 10 | 1 |

No pool is trimmed: every live item is on some page (12/11/13/14/10 → 2/2/2/2/1). Peg global positions for Verdant `Peg_*` were identical on 01, post-`fill_b1`, and after grant-all (e.g. `Peg_net` 328,272).

Visible labels: no "Sunken Mire", no "Tier" on hall plaques/lore, no strata column. Playtest chrome is Feedback / Developer Test only.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Fresh hall: Verdant 0/12 in progress, b2–b5 sheeted (spires + padlocks), dumbwaiter left with stop 1 lit / 2–5 dark+locks, plaques 1st–5th Depth. |
| 02 | fail | PNG was grabbed in the same exec as `fill_b1` before shelves refreshed; still 0/12 + "pool locked" toast. Opened Verdant + glacial Crystal is in 03 instead. |
| 03 | pass | After stop 2: Verdant opened 5/12 gold pips, Crystal Cavern unsheeted 0/11 in progress, stops 1–2, tray silhouette. |
| 04 | fail | Tour tween did not sample under freeze (`time_scale` 0.675); posed car/lever did not read as mid-ride vs 03. |
| 05 | pass | Held map: Crystal Cavern stamp in view (`NEW 0/5`, click to set off); Verdant 5/5 full. |
| 06 | pass | Claimed Net lore at 2×-ish crop: brass journal panel, "Wares of the 1st Depth", **Claimed**, no "Tier". (`_open_hall_zoom` parks `RoomHall.position` at 6720 and blacks the frame; this shot is the in-place crop.) |
| 07a | fail | Seen-hatch + dashed placard not isolated; later 12/12 left no seen-only Verdant peg. |
| 07b | fail | Unseen silhouette + blank placard not isolated (same zoom-off-screen bug). |
| 08 | fail | Zoom-out overview is the post-fill hall (5/12), not identical to stale 02. |
| 09a | fail | 5th Crystal unique arc (`medallion`) did not read mid-flight in the PNG. |
| 09b | pass | Crystal opened 5/11, door/lamp/crest on, Ashen unsheeted empty glass. |
| 09c | pass | End of unlock beat: stop 3 lit, Ashen sheet gone (slide already finished; not mid-drop). |
| 10 | pass | Verdant **12/12** gold placards; page 2 in the paired 11a frame shows empty recesses + both ticks. Overview page 1 (10-complete.png) after reset. |
| 11a | pass | Verdant page 2 slid in: Healing Potion + Sledgehammer, empty recesses, 12/12. |
| 11b | fail | Zoom + right chevron at 2× blacked out (`_open_hall_zoom`). |
| 12 | fail | `spiked_flail` is page 2 of Crystal but the PNG shows Verdant page 2, not the Crystal flip-before-arc. |

## Blockers

`TrophyCase` 2× zoom (`_open_hall_zoom`) tweens the hall room node (layout x=6720) toward 0 and leaves a black frame. Recapture used an in-place crop for 06 only.

## Shots

All listed PNGs under `shots/` at 1680×1040.
