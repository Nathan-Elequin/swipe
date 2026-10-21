# Pass 6 report — `anim/pass6-wheel-monsters`

**Status:** code + placeholders on branch. Needs Cherry local QA. Do not merge until QA passes.

**Checkpoint:** Task 3 (code/anim, layout B4, placeholders first). Task 4 PixelLab art is a **separate branch** (`art/wheel-monsters`) — do not start it on this unmerged branch (same PNG paths). Start Task 4 after this PR is merged, or branch from this pass if Cherry is blocked.

**Base:** `origin/main` `adc250d` (PR #76 art-handoff). Not stacked on `anim/pass4` or `anim/pass5-hotbar`.

## PixelLab

- Token present (`PIXELLAB_API_TOKEN` length 36).
- `GET /v2/balance`: **1721 / 2000** generations (Tier 1).
- **Gens this pass: 0.** README splits pass 6 (placeholders) from pass 6 art (~174–190 gens). Cap held at 0.
- Remaining ~1721. Do not start Task 4 until this PR’s placeholders are the files PixelLab will overwrite.

## Commits

- `anim-pass6(1): B4 wheel layout, ability card, placeholders`

## Files

- `scripts/boss_wheel.gd` — fit table, B4 `_spoke`, frameless sprite + shadow, name tag, medallion, HP left / ATK right, ability cards, breathe
- `scripts/ui/ability_card.gd` — new 72px 9-slice plate
- `scripts/dungeon_art.gd` — `monster_wheel_frames`, `monster_facing_idle`, `wheel_frames_all`
- `scripts/combat_stage.gd` — facing idle 4x of 48/64, 140ms, no sine bob
- `scripts/intent_plate.gd` — hub-edge fallback `centre + dir*(hub_r+40)`
- `scripts/bucket_reveal.gd` — order only: call, then `HP %s`, then `Attack %s`
- `scripts/main.gd` — `set_wheel_frames` after portraits
- `scripts/dev/shot_harness.gd` — pass 6 stems
- `assets/dungeon/anim/wheel/` — 58× (base + breathe f0/f1) + `PLACEHOLDERS.md`
- `assets/dungeon/anim/facing/` — 58× f0..f3
- `assets/ui/wheel/name_tag.png` — copy of existing PixelLab `plate9.png` (32×32, 5px corners)
- `assets/ui/wheel/medallion_<key>.png` × 20 — placeholder coins + SVG glyph
- Matching `.import` (Nearest, lossless, no mipmaps)

Untouched: `data/player-copy.json`, `project.godot`, secrets, itch, pass 4/5 branches.

## Cherry shot list

`--shots=01_four,02_full8,02b_full6,02c_n4,02d_n5,02e_n7,03_hover,04_breathe_a,05_breathe_b,06_facing,07_threads,08_reveal --shots-out=res://design/visual/anim-qa/wheel-monsters`

Paste `LOCAL-QA-PROMPT.md` with branch `anim/pass6-wheel-monsters`.

| Stem | Check |
|---|---|
| `01_four` | Commander, Merchant, Eel, Vampire with empties, draft gate |
| `02_full8` / `02b_full6` | 8 and 6 seats; no overlap; text upright; HP left / ATK right; medallion in front of un-notched tag |
| `02c_n4` / `02d_n5` / `02e_n7` | same at 4/5/7; log `[pass6-fit] n=… clearances=…` all ≥ 0 |
| `03_hover` | card opens outward, clamped, not over x>1260 |
| `04_breathe_a` / `05_breathe_b` | 300ms apart, staggered frames |
| `06_facing` | Vampire 4x 48/64 idle; ability card; intent plate on pop-out |
| `07_threads` | Commander neighbor rays from `sp.feet` (pass 4 aura-thread code is **not on main**) |
| `08_reveal` | call, then `HP N`, then `Attack N` (same words / `   ·   `) |

Also: `Engine.time_scale` 0.675 / Shift 2.025; text audit 0 "Tier"/"ATK"; 6-seat already `02b_full6`.

Cloud Godot is skipped (empty viewport / no GL). Visual QA is Cherry only.

## Movement dry-run

`origin/movement` has unrelated history (no merge base). File-level overlap vs `origin/main` (files this branch changes that also exist on `movement` with different content):

- `scripts/main.gd`
- `scripts/dev/shot_harness.gd`
- `scripts/dungeon_art.gd`

`scripts/boss_wheel.gd`, `scripts/combat_stage.gd`, `scripts/intent_plate.gd`, `scripts/bucket_reveal.gd` also change vs main; list them in the PR if they exist on movement. Do not checkout `movement`.

## Deviations

- Placeholders, not PixelLab (Task 3). Wheel/facing from current stills ÷4 then nearest. Breathe f0/f1 identical.
- `name_tag.png` is the existing PixelLab plate9, not a new gen.
- Medallion glyphs are SVG nearest-10px, not PixelLab coins.
- Aura threads from pass 4 are not on `main`. Shot 07 uses Commander neighbor rays attached at `feet`.
- Pass 5 hover-preview is not on `main`. Ability card still suppresses while an item card is `_holding`.
- Fit search recomputes when `rot` snaps (0.05 rad) so spinning stays seat-correct; QA logs print when not spinning.

## Gold boxes pending

None filled (`review_note` empty on the board).

## Questions

None that would change this code. Task 4 budget (~174–190 gens from 1721) is for the art branch after merge.
