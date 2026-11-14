---
id: REQ-20261114-keyword-tips-A-fix
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T03:20:00-06:00
machine: Cherry
tip_sha: 23bf38ac
godot: F5 playtest via godot-mcp
branch: playtest/latest
viewport: control 1680x1040; framebuffer 1550x960 resized nearest to 1680x1040
---

# Result

Evidence only. No game code or copy edits. Nathan’s `user://` JSON was copied to `_save_backup`, cabin `_persist_writes=false` during poses, then restored (all seven JSON SHA16s match). Play stopped before restore.

Keyword PNGs: every `assets/ui/keyword/*.png` has `dest_files` and a `.ctex` on disk. Runtime `load()` of `kw_spin`, `kw_flee`, `kw_across`/`_card`, `kw_poison`/`_card`, `kw_pip_ring`, `kw_card_seal`, `kw_chip_halo_9`, `new_star` returned real sizes (24/48/28/40/16). Editor log after rescan had no new import errors.

Crops: `get_global_rect()` in 1680×1040 space, pad 60 px, 2× Nearest. Each crop contains the full card. `ability_slash.visible` was false on every saved frame. Window would not grow past 1550×960; shots upscaled nearest. First pass had the playtest intro ColorRect covering the fight; intro was closed and fight rows 01–03 and 06–08 were re-shot.

Keep-out `_wheel()` returned BossWheel (`boss_wheel.gd` Control), not Main’s `wheel` Array. Pin: `show_def("spin")` while pinned on Flee left `_kind` as flee.

Teach 04a/04b/04c grabbed in real time from `preview_first_sighting("spin")` (halo.a / modulate.a / star.visible), not a forced `modulate.a`. Tweens ran during `godot_game_time` step.

F1 editor: opened, body of Any edited with ` (preview)` so live preview showed the extra word, then Revert (status `Reverted`, body restored). Did not click Save. `data/keyword-defs.json` unchanged.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Longbow plate + Across parchment with card icon, docked right of the plate above the hotbar. Card fully inside. Rect `(867, 698, 296, 168)`. |
| 02 | pass | Commander plate Ability with Flee chip + parchment and card icon. No slash. Card fully inside. Rect `(883, 818, 296, 198)`. |
| 03 | pass | Poison parchment on the side rail with card icon; monster plate hidden (`fly_vis=false`); pip ring node visible; keep-out miss. Rect `(1179.5, 346, 296, 318)`. |
| 04a | fail | Real-time grab at halo.a≥0.65 and card a=0, star hidden. Crop and that region of the full frame are near-black — parent `modulate.a=0` also hides TeachHalo, so the gold pulse is not visible. Rect `(1288, 433, 296, 168)`. |
| 04b | pass | Same teach, card fading in (a≈0.34) with `new_star` visible. Card fully inside. Rect `(1179.5, 367, 296, 168)`. |
| 04c | pass | Parchment fully open (a≈1) with Spin card icon and `new_star`. Card fully inside. Rect `(1179.5, 328, 296, 168)`. |
| 05 | pass | Tutorial B06 talk “Spin and fight whoever you land on.” + Spin parchment with card icon beside the talk box. Intro dimmed behind; talk + card readable. Rect `(1351, 422, 296, 168)`. |
| 06 | pass | 8 monsters + 7 items, Flee card over the hotbar, `intersects_keep_out` false, `_wheel()` is BossWheel. Same frame as 02 after intro skip. Rect `(883, 818, 296, 198)`. |
| 07 | pass | Combat log BBCode includes `kw_flee.png` / Poison / Spin chips; Flee parchment docked in the log column. Card fully inside. Rect `(24, 642, 296, 198)`. |
| 08 | pass | Pinned Flee (seal texture visible). `show_def("spin")` left `_kind` as flee. Card fully inside. Rect `(883, 818, 296, 198)`. |
| 09 | pass | F1 editor opens (23 ids, chip icons in the list). Edited Any body → live preview showed `(preview)`. Revert restored the original sentence. Did not Save. Preview rect `(721, 798, 296, 198)`. |

## Blockers

- Editor Play window max 1550×960; shots upscaled nearest to 1680×1040.
- 04a gold pulse is not visible while the card root alpha is 0.

## Shots

`playtest/repot/outbox/REQ-20261114-keyword-tips-A-fix/shots/` — table filenames are 2× padded card crops; `*-full.png` is the 1680×1040 context frame.
