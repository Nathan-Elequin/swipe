# Pass 5 — cloud report

Status: **needs local QA** (Cherry). Not merged.

Checkpoint: branch `anim/pass5-hotbar` from `origin/main` (`adc250d`). Pass 4 (`anim/pass4` / PR #74) was not touched.

## Gold boxes pending

None. `data/content-board.json` has no filled `review_note` this run.

## PixelLab

- Token present (length 36). `GET /v2/balance` 200: **1721 / 2000** generations.
- **Gens used this pass: 0.** Final pass 5 art was already on main. Did not overwrite.

Poison is green (Nathan 2026-10-21). No poison art in this pass.

## Files

- `shaders/rank_shimmer.gdshader` + `scripts/rank_shimmer.gd`
- `scripts/item_card.gd` — `play_sai`, `play_marble`, `marble_grow`, `marble_roll_in`, shimmer, sparkle, `set_armed`, `set_no_effect`
- `scripts/main.gd` — flip/undo/icon, marble use/grow/bag, hover rule table, hotbar sig omits `marble_n`
- `scripts/intent_badge.gd`, `scripts/intent_plate.gd`
- `scripts/draft_gate.gd`, `scripts/dungeon_deck.gd` — same shimmer shader
- `scripts/dev/shot_harness.gd` — pass 5 stems
- `assets/ui/anim/PLACEHOLDERS.md`, `assets/dungeon/anim/PLACEHOLDERS.md` — mark existing art final

No `data/player-copy.json`, `project.godot`, logs, or secrets.

## Shots for Cherry (`LOCAL-QA-PROMPT.md`)

`--shots=` stems, windowed 1680×1040. One Godot process at a time.

Sai (`design/visual/anim-qa/sai-twirl-split/`):
`01_split_120ms,02_split_240ms,03_split_360ms,04_merge,05_carryover,06_dungeon_reset,07_sai_6_seats`

Marble (`design/visual/anim-qa/marble-swirl/`):
`01_bag_fill,02_swirl_120ms,03_settle_300ms,04_courier_600ms,05_grow,06_marble_6_seats`

Shimmer (`design/visual/anim-qa/hotbar-shimmer/`):
`01_glint_0s,02_glint_1s,03_glint_3s,04_glint_6s,05_boot_sink,06_sling_loaded,07_shimmer_6_seats`

Hover (`design/visual/anim-qa/item-hover-preview/`):
`01_kobold_plus,02_net_range,03_amalgam,04_bushido,05_kill,06_unhover,07_hover_6_seats`

Also: `Engine.time_scale` 0.675 / Shift 2.025; text_audit 0 "Tier" / 0 "ATK"; 4–8 seats.

Cloud Godot is not on this VM. Do not claim visual QA from cloud.

## Deviations

- Merge uses reversed split frames (no merge asset).
- Shader clock is a uniform from `_process`, because shader `TIME` ignores `Engine.time_scale`.
- Hover is the phase 1 rule table only (no full sim).
- `sai_split` is still on the Task 5 reroll list; wired as-is.

## Questions

None for this pass. Poison colour already decided (green).
