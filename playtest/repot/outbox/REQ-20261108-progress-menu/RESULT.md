---
id: REQ-20261108-progress-menu
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-07T22:45:00-06:00
machine: Cherry
tip_sha: 00cc01ca
godot: editor play via godot-mcp, viewport 1680x1040
---

# Result

Isolated fixture in `user://` for the session. Nathan's `audio.json`, `bucket_progress.json`, `campaign_save.json`, `home_cabin.json`, and `playtest_meta.json` were copied aside first and restored after Stop. SHA-256 of each file matches the pre-run backup. Cabin writes during the run went to `%TEMP%\progress-menu-cabin-qa.json`, which was deleted. Source check: `py -3 tools/qa/check_progress_menu.py` printed `PROGRESS_MENU_OK` (93 passed, 0 failed) before the play session.

Every PNG below is 1680×1040 (`err=0`).

| id | verdict | note |
|----|---------|------|
| P1 | PASS | Public Leave with two new Verdant types. Flags were adventure, phase rest, not busy. Flow `overview:0 → collection:1 → collection:2 → next:2`. Summary `New item types added: 2.` Arrow Head state `New!`, area count `4/15`. `whoosh.wav` was playing on the next frame. Shots `P1-overview.png`, `P1-collection-stagger.png`, `P1-next-goal.png`. The empty grid slot in the stagger shot is the second new cell still at alpha 0; the flow reaches `collection:2` before Next Goal. An earlier boot attempt did not open the menu; this pass did. |
| P2 | PASS | Duplicates only. Menu opened, `new_ids` size 0, summary `Made it home. No new item types added.` `P2-duplicates.png`. |
| P3 | PASS | Public loss. Summary `Run ended in Verdant Hollow. No collection progress from this return.` Auto flow `overview:0 → collection:0 → next:0`. `P3-loss.png`. |
| GIVEUP | PASS | Public give-up uses the same loss summary. `P3b-give-up.png`. |
| P4 | PASS | Tutorial Yes-complete. Summary `Tutorial complete. Tutorial items don't count toward collection progress.` `P4-tutorial-complete.png`. |
| P4B | PASS | Tutorial skip. Summary `Tutorial skipped.` It is not the no-progress success line. `P4b-tutorial-skipped.png`. |
| P5 | PASS | Win whose played area is Crystal Cavern while Verdant is still the next quota. On the collection step the filter is `b2`, the count is `Crystal Cavern collection: 1/14`, and the tab reads `Crystal Cavern` with no Locked suffix. No "Five different finds" line. `P5-played-area.png`. An earlier shot (`P5-non-b1.png`) clicked Collection before the auto step and still showed Verdant; that setup was too early. |
| P6 | PASS | After Push had banked Verdant to 5 with `map_pieces` still empty, `_campaign_bank_from_hand(true)` stamped `b2` once (`pencil_fresh` was `["b2"]`). A second call did not mark the pencil again. Next Goal text includes `Ashen Crypt`, `Bring home 5 different item types from Crystal Cavern`, and the same-run route. `P6-requirement-met.png`. |
| P7 | PASS | Skip while 1 of 4 new ids was revealed. Each id acked once (`net`, `poison_flask`, `sai`, `shield`). Bank size stayed 10. Tab landed on Next Goal. `P7-skip-mid.png`. Two earlier skips fired after every cell had already landed, so they did not prove the mid-stagger case. |
| NEXT | PASS | Manual Next from Overview landed the new cell on Collection (`revealed` 1), then the second Next opened Next Goal. `P7b-manual-next.png`. |
| INPUT | PASS | `ui_accept` on Next opened Collection (tab 1). Cells are `FOCUS_ALL` (15). Focus neighbor is set and a focused cell's `ui_accept` filled the detail line `Right Bracer — Collected`. |
| MOUSE | PASS | Press and release at Visit Cabin `(1546, 980)` returned action `cabin`. The first attempt sent only the press, so it did not count. `INPUT-mouse-cabin.png`. |
| MISSING | PASS | Victory Flask has a name, state `Not yet collected`, and no texture. `MISSING-icon-name.png`. |
| TOTAL_LOCKED | PASS | `postrun.collection.total` is present. Overview reads `Item types collected: 0/67` plus Locked lines and bring-home requirements for Ashen Crypt, Cinder Forge, and Shadow Abyss. `OVERVIEW-total-locked.png`. |
| P8 | PASS | Visit Cabin returned action `cabin`, cabin became visible, the menu closed, `bank_pending` stayed empty. Closing the cabin left the menu closed. `P8-cabin.png`. |
| P9 | PASS | With only Verdant filled, buttons were `Start New Run` only. `can_start(0)` true, `can_start(1)` false, `can_start(2)` false. Route text: `Reach Ashen Crypt by starting in Verdant Hollow and continuing during the same run.` `P9-eligible-starts.png`. |
| P9B | PASS | Banking five Crystal Cavern types made `can_start(1)` true. |
| P10 | PASS | While the menu was open, campaign `write()` and cabin `_save()` went to the fixture and the temp cabin file. A phantom bank id did not survive `load_all()`. Sizes stayed 5 before reload, after reload, after resume with `progress_menu_handled_return`, and after a second `bank()` of the same id. Pending reloaded as one `arrow_head`. `P10-mid-menu-reload.png`. |
| P11 | PASS | Public Push opened the menu, summary `New item types added: 3.`, `map_pieces` stayed 0, and the five-finds celebration line was absent. `P11-push.png`. |
| P12 | PASS | Three already-banked Verdant ids were shown with no `New!` during the presentation. `P12-historical.png`. |
| NEST_B1 | PASS | After Start New Run, nest offset was `0`, phase `ready`, not busy, not paused, starter count 6. The deal queue was already empty because the arm had placed the wheel. `NEST-start-b1.png` shows the settled Verdant wheel and six hotbar items. |
| NEST_SHORTCUT | PASS | Fresh start at Crystal Cavern (`can_start(1)`). Nest `0`, phase `ready`, biome `b2`, hotbar 6, starter tiers `[1,1,2,2,1,3]`. `NEST-start-shortcut.png`. |
| AUDIO | PASS | `whoosh` is loaded and `whoosh.wav` played on Leave. The progress menu owns no `AudioStreamPlayer`. Music kept playing through the menu and both settled starts. Start itself played `confirm_big.wav`. |
| SOURCE | PASS | `PROGRESS_MENU_OK`, 93 passed, 0 failed. |

## Blockers

None. The game was stopped before the save restore.

## Shots

All PNGs under `shots/`. Names are in the table above. Viewport on every saved image is 1680×1040.
