---
id: REQ-20261108-collection-A
status: blocked
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T07:40:00-06:00
machine: Cherry
tip_sha: 59e8ca511259155995eef52b98b21850fbae027e
godot: windowed isolated process, Godot 4.7.2-stable, viewport 1680x1040, content_scale 1.0
---

# Result

Not accepted. The inbox stays `open`. This file is the evidence from one sandboxed run. It does not mark the slice F5-ready.

## Checkout

`git fetch origin playtest/latest` then `git rev-parse HEAD` and `git rev-parse origin/playtest/latest` were both `59e8ca511259155995eef52b98b21850fbae027e`. Ahead/behind was `0 0`. That commit message is `fix(buckler): a 0 Attack swing still counts as an Attack`.

`4a1696778624cdf2d78007294c63cf83683df8c7` (#477) and `f644a44ae0079e16adccc9de0e593ef3caf17a0b` (#476) are ancestors of that tip. Collection commits through #481 are in the history. No stash, reset, clean, or merge was used.

Uncommitted files were left in place. Collection scripts were clean. `data/catalog.json`, `data/content-board.json`, `data/author-locks.json`, and `data/recent-edits.json` were already dirty, mostly `1` versus `1.0` plus one Buckler explainer. The windowed process loaded that working tree.

## Save isolation

Live profile `C:\Users\Natha\AppData\Roaming\Godot\app_userdata\Spinheritance` was hashed before and after. These SHA-256 values did not change:

| file | sha256 |
|------|--------|
| audio.json | 721C8DAD7F21B29D7837A41A38664CEFB66FBC5E758DB82BBAE06707BCB49058 |
| bucket_progress.json | DF7EAFDCD8C36055BEE73B08B8226051B24BEBCFC1CED5BCBA5AB70B2197EF39 |
| campaign_save.json | 35D65C402B2A2F5E537049EE1605001E204C0CB8A756C86E36BD8492AD542094 |
| home_cabin.json | 14B48D2C4FD5CC471AEDD05D37672D1ED3D70EE3FE5CAFF1ED23C82E80F43365 |
| playtest_meta.json | BC9714F75CEB2F34E17ED409A16C54BEACC251404A770F84DD990B851727C2EA |

The Godot process used `APPDATA=C:\Users\Natha\AppData\Local\Temp\collection-a-sandbox`. `OS.get_user_data_dir()` was `C:/Users/Natha/AppData/Local/Temp/collection-a-sandbox/Godot/app_userdata/Spinheritance`. The driver quits unless that path contains `collection-a-sandbox`. Nathan's open editor was not played or stopped. A second Godot process took the screenshots.

## Headless script

`./tools/qa/run_collection_journey.sh` exited 2. Git bash rejected `set -o pipefail` because the script has CRLF (`pipefail\r`).

The same check, run directly, exited 0 and printed `COLLECTION_JOURNEY_OK`:

`Godot_v4.7.2-stable_win64_console.exe --headless --path <repo> --script res://scripts/dev/collection_journey_selftest.gd`

That process also used the sandbox `APPDATA`. Godot reported `4.7.2.stable.official.ed1daf0bf`.

## Numbered Journey A roster

`docs/collection-journey-a/OWNER-CONTRACT.md` is not in this checkout. There is no A01–A24 list to execute. Those 24 ids are **NOT RUN**. The 28 lines below are the selftest ids that actually printed. They are not a substitute for the missing 24.

| id | verdict | note |
|----|---------|------|
| quota_five | PASS | selftest |
| knife_is_b1 | PASS | selftest |
| status_unknown | PASS | selftest |
| status_seen_after_offer | PASS | selftest |
| status_carried | PASS | selftest |
| provisional_one | PASS | selftest |
| provisional_dup_collapses | PASS | selftest |
| held_qty_two | PASS | selftest |
| after_spend_one_still_provisional | PASS | selftest |
| after_last_spend_zero_provisional | PASS | selftest |
| seen_survives_spend | PASS | selftest |
| gate_banked_four | PASS | selftest |
| gate_not_open_on_carry | PASS | selftest |
| would_cross_on_bank | PASS | selftest |
| projected_five_if_banked | PASS | selftest |
| bank_added_knife | PASS | selftest |
| status_banked | PASS | selftest |
| catalogue_collected | PASS | selftest |
| catalogue_seen_not_banked | PASS | selftest |
| gate_next_crystal | PASS | selftest |
| milestone_gate_present | PASS | selftest |
| milestone_cabinet_full_at_roster | PASS | selftest |
| banked_repeat_status | PASS | selftest |
| banked_repeat_no_provisional | PASS | selftest |
| cabinet_full_fires | PASS | selftest |
| cabinet_full_not_on_quota_alone | PASS | selftest |
| quiet_has_quota | PASS | selftest |
| loss_keeps_seen | PASS | selftest |
| A01–A24 | NOT RUN | no approved id list in the checkout |

## Screenshots

Every PNG is 1680×1040 (`err=0`). Window size was 1680×1040. Viewport was 1680×1040. `content_scale_factor` was 1.0. Project stretch mode is `canvas_items` / `expand`. No second scale was applied.

Driver: `scripts/dev/collection_a_live_repot.gd`. Log: `live-stdout.log`.

| id | verdict | note |
|----|---------|------|
| 01 | PASS | Collection. Arrow Head, Right Bracer, Breastplate, and Crossbow read Collected. The Boot and Fangs read the placeholder recognized-not-banked line, which is not "Not yet collected". Count `4/15`. `01-catalogue-seen-vs-banked.png`. |
| 02 | PASS | Overview summary `New item types added: 1.` Totals `5/67` and Verdant `5/15`. The New! cell text was read in memory as `New!` before the overview was shown. This PNG is the overview, so the New! word is not on the frame. `02-return-receipt-overview.png`. |
| 03 | FAIL | Crystal Cavern tab reads `Crystal Cavern (Locked)`. The grid still shows that area's item names and icons (Bag Of Marbles, Bloody Wraps, Catapult, and the rest). `03-area-locked.png`. |
| 04 | FAIL | The strip node text was `[Spin copy: Verdant Hollow banked 4/5 · held new 1] · [Spin copy: banks home to open route]`. In the PNG the middle of that line is covered by a New! badge, so "held new" is not readable. `04-inrun-quiet-strip.png`. |
| 05 | FAIL | Before Skip, the overview labels included `[Spin copy: Route open — 4→5/5 banked. Next: Crystal Cavern]`. Skip left that text on the hidden overview and showed Next Goal. The PNG does not show the gate line. `05-milestone-gate.png`. |
| 06 | FAIL | Room is the trophy hall, not the fireplace. `bank_pending` was 0, so no bank ceremony replay. The centered lit case is Crystal Cavern, not the played Verdant case. `06-cabin-optional-focus.png`. |
| 07 | PASS | After a second `bank()` of Fangs added nothing, the receipt says no new item types and Fangs reads Collected. Verdant count `5/15`. The Boot stays recognized-not-banked. `07-reload-idempotent.png`. |
| 08 | PASS | Loss summary `Run ended in Verdant Hollow. No collection progress from this return.` Verdant stayed `4/15`. The Boot was not added to banked. `seen` for The Boot stayed true in memory. This PNG is the overview, not the Boot cell. `08-loss-seen-retained.png`. |

## Input and reload

| id | verdict | note |
|----|---------|------|
| keyboard | PASS | `ui_accept` on Next moved the menu to tab 1. `input-keyboard-next.png`. |
| mouse | PASS | Left press and release on Next at rect `(64, 960, 140, 40)` moved the menu to tab 1. `input-mouse-next.png`. |
| focus | PASS | `ui_focus_next` moved focus from one button to another. |
| back | FAIL | `ui_cancel` left the progress menu visible. It did not restore a caller. `input-focus-back.png`. |
| reload | FAIL | Campaign: banking Fangs once added it, banking it again added nothing, and a phantom bank id did not survive `load_all()`. Cabin: after ack, pending was `["da_boot"]`. `_load_save()` then returned an empty pending list, so that unacked id did not come back. |
| reduced_motion | NOT RUN | No `accessibility/general/reduce_motion`, `gui/common/reduce_motion`, or `display/window/reduce_motion` project setting. Stagger was not compared. |

## Copy audit

| key | in player-copy.json | what the run showed | final? |
|-----|---------------------|---------------------|--------|
| postrun.collection.item_seen | no | `[Spin copy: Recognized — not banked yet]` | No |
| run.collection.quiet_summary | no | `[Spin copy: Verdant Hollow banked 4/5 · held new 1]` | No |
| run.collection.quiet_summary_threshold | no | `[Spin copy: banks home to open route]` | No |
| postrun.collection.item_new | yes | New! | Yes, existing key |
| postrun.collection.item_collected | yes | Collected | Yes, existing key |
| postrun.collection.item_missing | yes | Not yet collected | Yes, existing key |
| postrun.collection.area_locked | yes | Locked | Yes, existing key |
| postrun.summary.success_new | yes | New item types added: 1. | Yes, existing key |
| postrun.summary.death | yes | Run ended in Verdant Hollow. No collection progress from this return. | Yes, existing key |
| cabin.tip.new | yes | New! | Yes, existing key |

## Baseline versus this run

No older build was shot, so nothing is labeled a pre-existing baseline. The fails above are fails of this run against the request.

## Blockers

The approved 24-case list is not in the checkout. `run_collection_journey.sh` does not run under Git bash until the CRLF on `pipefail` is fixed. Inbox status was left `open`.
