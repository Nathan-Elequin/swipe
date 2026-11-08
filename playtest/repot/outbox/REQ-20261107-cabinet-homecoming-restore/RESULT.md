---
id: REQ-20261107-cabinet-homecoming-restore
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-07T19:20:00-06:00
machine: Cherry
tip_sha: 4e56853d0c09c08548a8079e0b7f6e265c69a8ac
godot: windowed isolated profile, 1680x1040, Godot 4.7.2 stable
---

# Result

Live check ran in a child process whose `APPDATA` was `C:\Users\Natha\AppData\Local\Temp\homecoming-live-sandbox`. `OS.get_user_data_dir()` was `.../homecoming-live-sandbox/Godot/app_userdata/Spinheritance`. `--user-data-dir` does not redirect `user://` on this Windows build, so it was not used. Nathan's live save `~\AppData\Roaming\Godot\app_userdata\Spinheritance\home_cabin.json` stayed MD5 `9E272E789B767BF749DEA933F8EB2E98` before and after. The dirty `boss-rush` checkout was not switched or stashed.

Headless helpers (also sandboxed, live hash unchanged) are not this proof:

- `ceremony-selftest.log`: `HOMECOMING_CEREMONY_OK`, `PASS ASSERT SAFE.ack_save_noop_same_meta`, probe path under `homecoming-ceremony-sandbox`
- `banking-contract.log`: `BANKING_CONTRACT_OK`
- `cabin-nav.log`: `CABIN_NAV_LOCK_PROBE_OK`, probe path under `arc1-cabin-nav-sandbox`

Windowed driver: `scripts/dev/homecoming_live_repot.gd`. Log: `live-stdout.log` ends `LIVE_REPOT_DONE`, exit 0. Every shot line is `1680x1040 err=0`.

| id | verdict | note |
|----|---------|------|
| H1 | pass | Hotbar New badge and Nib line `See that 'New!' mark? We haven't brought one of those home yet...` (`shots/H1-new-mark.png`). Lesson flag set. |
| H2 | pass | Rope exit, Grandpa's Emergency Exit. Visible line matches `nib.lesson.extract_haul` in full (`shots/H2-extract-haul.png`). |
| H3 | pass | Heard `Let's give these a home.` Pan frames in `shots/H3-flight/` (6 PNGs). After mount, Verdant shows the new peg (`shots/H3-after-mount.png`). Pending empty. |
| H4 | pass | Same ceremony. Cues `cabin.item_whoosh`, `cabin.item_pop`, `cabin.shelf_chime`. SFX bus peak about -16.9 dB. `H3-sfx.wav` (958508 bytes). |
| H5 | pass | b1 count 4→5. Heard the threshold line, then Crystal Cavern stamp. `map_pieces` 1. `shots/H5-five-find-unlock.png`. |
| H5b | pass | b2 haul mounted. Pending empty. No `Five different finds` line. `shots/H5b-non-verdant-haul.png`. |
| H6 | pass | Duplicate swipe returned no new ids, pending stayed empty, ceremony did not start. |
| H7 | pass | Loss homecoming settled idle. Pending did not grow. No give-home line. `shots/H7-loss.png`. |
| H8 | pass | Heard `Back in one piece. Next time, let's bring something home for these shelves.` Banked 0→0, pending empty. `shots/H8-tutorial-return.png`. |
| H9 | pass | Mid-dialog save on disk was `bank_pending: ["sai"]` only. Reload resume did not replay the already-acked id. `shots/H9-reload-resume.png`. |
| H10 | pass | Push-block path heard `Five from the Verdant Hollow. Then we talk about going deeper.` No give-home, no threshold lesson, no new map piece. Item still mounted. `shots/H10-push-block.png`. |
| H11-dialog | pass | Escape left the ceremony busy and the line open. `hide_for_run` then dropped FX to 0. Pending stayed `["flying_saucer"]` across 20+ frames (no late ack). Re-entry cleared it once. Pan back to the front room worked. `shots/H11-dialog.png`. |
| H11-flight | pass | Cancel during flight: one FX node alive at Escape, zero after `hide_for_run`. Pending stayed `["healing_potion"]` until re-entry, then cleared once. `shots/H11-flight.png`. |
| H11-count | pass | On-screen label `+1  1/5`. Ack is already done before the loud count, so pending was empty at cancel and stayed empty. No second bank. `shots/H11-count.png`. |
| H11-cabinet | pass | Lamp flag true while the room was the hall. After cancel, FX 0, `map_pieces` 0→0, pending empty, no duplicate bank of the five ids. `shots/H11-cabinet-open.png`. |
| H12 | pass | With lesson flags already set, a later ready-phase and swipe did not repeat New, give-home, or five-finds. `shots/H12-no-repeat.png`. |

## Blockers

None for the live profile. Two notes, not blockers:

- Escape (`ui_cancel`) does not abort the ceremony. During the line it advances the dialog. During flight the cabin swallows it because the ceremony is busy. The cancel that releases FX and keeps pending is `hide_for_run` (same path as leaving the cabin). Re-entry was `show_menu("hall")`, which resumes the pending queue once.
- On the cabinet cancel, the stamp lines for Ashen Crypt were heard after the screenshot, and `map_pieces` stayed 0. The finished five-find path (H5, not cancelled) did stamp Crystal Cavern and left `map_pieces` at 1. The closed sheets in `H11-cabinet-open.png` are the frame at the lamp, with ceremony blobs on the second case, before those stamp lines.

## Shots

All PNGs under `shots/` at 1680×1040. Audio: `H3-sfx.wav`. Driver log: `live-stdout.log`.
