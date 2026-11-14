---
id: REQ-20261114-keyword-tips-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T03:30:00-06:00
machine: Cherry
tip_sha: 0e6d5ad8
godot: F5 playtest via godot-mcp
branch: playtest/latest
viewport: control 1680x1040; framebuffer 1550x960 resized nearest to 1680x1040
---

# Result

Evidence only. No game code or copy edits. Nathan’s `user://` JSON was copied to `_repot_backup_20261114_keyword_tips_A`, cabin `_persist_writes=false` during poses, then restored (home_cabin + campaign_save hashes match).

Crops: keyword card `get_global_rect()`, pad 60 px in 1680×1040 space, 2× Nearest. Each crop opened before keep. Ability slash was not visible on saved frames. Play window would not grow past 1550×960.

Keyword chip/card PNG imports failed in this checkout (`kw_spin.png`, `kw_flee.png`, `kw_across_card.png`, `kw_poison_card.png`, `kw_pip_ring.png`, `kw_card_seal.png`, …). Chips often show the colored word only.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Longbow plate + Across parchment, docked right of the plate. Card fully inside crop. No card icon (missing `kw_across_card.png`). Rect `(867, 698, 296, 168)`. |
| 02 | pass | Commander plate Ability with Flee chip + parchment. No slash. Card fully inside. Missing chip/card icons. Rect `(883, 848, 296, 198)` then `(883, 818, 296, 198)`. |
| 03 | pass | Poison parchment on the side rail; monster plate hidden. Card fully inside. Pip hover ring texture missing (`kw_pip_ring.png`). Card did not paint while parented to `MarkTipLayer` (layer 90); posed `top_level` on Main to capture. Rect `(1252, 470, 296, 318)`. |
| 04 | fail | Spin parchment with `new_star` forced visible for the end frame. Tweens did not run (`modulate.a` stayed 0 until forced). Code `_pulse_then_open_star` waits one 0.45s interval, not three gold pulses. Rect `(1049, 842, 296, 168)`. |
| 05 | pass | Tutorial B06 talk “Spin and fight whoever you land on.” + Spin parchment under the talk box. Chip icon missing. Card fully inside. Rect `(1351, 439, 296, 168)`. |
| 06 | pass | 8 monsters + 7 items, Flee card over the hotbar, clear of the wheel. No slash. Card fully inside. Rect `(883, 818, 296, 198)`. |
| 07 | fail | Flee parchment in the left log column. Combat log rows themselves are not readable in the PNG (overlay not showing chips). Card fully inside. Rect `(24, 621, 296, 198)`. |
| 08 | fail | Pinned Flee parchment captured (seal texture missing). `show_def("spin")` while pinned changed `_kind` to spin — other hovers are not ignored. Card fully inside. Rect `(883, 818, 296, 198)`. |
| 09 | fail | F1 editor did not open. `keyword_defs_editor.gd` parse error: `KeywordDefs` is not declared (no preload). Did not click Save. |

## Blockers

- Editor Play window max 1550×960; shots upscaled nearest to 1680×1040.
- Keyword UI textures failed to load from `.godot/imported/*.ctex`.
- F1 defs editor script does not compile.
- `keyword_tip._wheel()` returns Main’s wheel **Array**, so keep-out rect is empty (runtime error: Array vs Node).

## Shots

`playtest/repot/outbox/REQ-20261114-keyword-tips-A/shots/` — table filenames are 2× padded card crops; `*-full.png` is the 1680×1040 context frame.
