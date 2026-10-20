# cabin-wiring — REPORT

## Status
DONE

## Checkpoint
`cabin-wiring(0)` was already on the branch. Wired every listed unwired home PNG into cabin code (or documented why not). Headless import/quit clean for cabin scripts; PNG check 0 failures; text SELFTEST_OK; layout selftest ok; SHOT_CLI_OK with count 92 (was 78 + 14 new).

## Commits
1. `cabin-wiring(1): kit slider helper + hotspot hover setter`
2. `cabin-wiring(2): room/overlay wiring (doors hover, glow, flip, knobs, speech tail)`
3. `cabin-wiring(3): home_cabin doors/fx/drawer/dummy/seen/drop_sack`
4. `cabin-wiring(4): shot harness 67–80`
5. `cabin-wiring(5): REPORT`

## Files touched
- `scripts/cabin/cabin_kit.gd` — `apply_hslider`, `home_tex_style`, `play_tex_frames`
- `scripts/cabin/cabin_hotspot.gd` — `set_hover_tex`
- `scripts/settings_menu.gd` — apply slider chrome
- `scripts/cabin/cabin_dialog.gd` — `ui/speech_tail.png` under box toward bust
- `scripts/cabin/journal_overlay.gd` — page flip anim with `cabin.page_flip`
- `scripts/cabin/radio_overlay.gd` — `radio_knob_hover_f*` when hovered
- `scripts/cabin/rope_exit.gd` — deeper hole idle glow pulse; hide on hover
- `scripts/cabin/room_study.gd` — drawer ajar/new journal matching hovers
- `scripts/cabin/room_loft.gd` — trunk open matching hover
- `scripts/home_cabin.gd` — run/side door open, dust, coin, fly spark/trail, new burst, drawer rattle/open, dummy tilt, chair settle, item_seen_overlay, drop_sack debug, dust on `_bump`
- `scripts/dev/shot_harness.gd` — shots 67–80
- `design/cli-runs/07-cabin-wiring/REPORT.md`

## Dead assets (skipped on purpose)
- `props/gear_peg_empty.png` — placeholder; empty peg = hide piece
- Root `fire_glow.png` — superseded by `rooms/room_main_fire_glow.png`

## Interpretations
- **item_seen_overlay:** grey frame over the 16×16 recess when the mount is **seen but not owned** (`is_seen and not is_swiped`). Owned mounts keep the normal trophy art; unseen stays silhouette.
- **hero_drop_sack:** win/loss homecoming already uses `hero_sack_dump` / `hero_sack_shake`. Drop-sack is wired through `_set_hero_frame` (root + gear overlays), `debug_drop_sack`, and shot 77. Not swapped into the live dump/shake beat (would change the homecoming feel).
- **chair_settle:** frames are an empty rocking chair rocking; played after `_play_stand` when the empty chair appears.
- **new_burst:** plays on fresh mounts that are also `new_unseen` (pairs with `fx/new_tag`), additive, in addition to trophy_place_burst.
- **fly_spark / fly_trail:** child of each flying loot sprite during sack pops and `debug_win_fly`.
- **coin_f*:** one spinning coin toss during sack dump pops.
- **Run door open:** plays before `_leave_for_run` after map Go (~300 ms total).
- **Side door open:** brief flash (~120 ms) then existing pan.

## Shots
Added (parent runs windowed; not captured here):
`67_run_door_open_f2`, `68_side_door_open`, `69_drawer_rattle`, `70_drawer_open`, `71_dummy_tilt`, `72_radio_knob_hover`, `73_journal_page_flip`, `74_deeper_hole_glow`, `75_homecoming_fly_spark`, `76_new_burst`, `77_drop_sack`, `78_settings_sliders`, `79_dialog_speech_tail`, `80_trunk_open_hover`.

## Audit summary
| Check | Result |
|---|---|
| `--import` / `--quit` | no SCRIPT ERROR / Parse Error on cabin scripts |
| `check_ui_pngs.py` | failures 0 |
| `text_audit_selftest.gd` | SELFTEST_OK |
| `layout_check_selftest.gd` | LAYOUT_CHECK_SELFTEST ok |
| `check_shot_cli.gd` | SHOT_COUNT 92, SHOT_CLI_OK |

## Deviations
- Drop-sack not used in live win/loss homecoming (dump/shake already own that beat); available via debug/shot.
- Dust puff origin uses hero feet (`position + (16,30)` native) when `_bump` fires; locked-door bumps without a visible hero still use last hero position.
- Speech tail sits on the dialog box bottom edge under the bust (Nib); no separate hero-speaker path for the full talk bar.

## Questions
None blocking.

## What Nathan should look at
1. Leave for a run — run door open f0–f2 (Grumblegut on f2) then map transition.
2. Walk through an unlocked side door — brief open leaf, then pan.
3. Stuck drawer (pre-ending) — rattle frames; post-ending open — open frames then close-up.
4. Dummy click — tilt wobble before the ask.
5. Radio knobs — hover art; pause sliders — track/fill/grabber chrome.
6. Journal page turn — flip overlay with the existing cue.
7. Rope deeper hole — idle glow pulse; hover still swaps to hover art.
8. Win homecoming dump — dust on thud, spinning coin, fly spark/trail on loot.
9. Talk box — speech tail under the bust; seen-not-owned mounts — grey recess frame.
10. Stand from chair — empty chair settle frames.

## ART-REQUEST
None. All listed assets existed and fit; drop-sack live path is a code choice, not missing art.
