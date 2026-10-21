# Restore animation passes 4–6

Status: **local QA pass** (Cherry). Branch `anim/restore-pass-4-6`.

## What this is

GitHub `main` had dropped mill passes 4–6 in [#83](https://github.com/Nathan-Elequin/swipe/pull/83). This branch puts them back on top of that commit, plus the pass-4 hook yank seat guard from draft [#84](https://github.com/Nathan-Elequin/swipe/pull/84).

## Commits

1. Revert merge #83 (restore pass 4–6 trees).
2. `hook_fx.yank` returns if either index is outside `slices.size()`.
3. Drop stacked duplicate `_hotbar_card_by_uid` / `_hide_fight_hover` in `scripts/main.gd` (headless parse error).
4. Cherry windowed QA shots.

## Parse

`--headless --path <worktree> --quit` after `--import`: no SCRIPT ERROR once the duplicate helpers were removed.

## Speed

`poison_ff_start time_scale=0.675` → held `2.025` → release `0.675`. Cascade restore lines stay at 0.675.

## Seats

6-seat shots: poison, petrify, hook (`neighbor=5`), aura, sai, marble, shimmer, hover. Pass 6 fit-table clearances for 4/5/6/7/8 seats all ≥ 0.

## Text audit

Harness exit 1 is the old hotbar `overflow_parent` / combat-log `enemy ATK` (Jam copy; not changed). 0 `"Tier"` in failure text. `data/player-copy.json` untouched.

## Flags (not merge-blockers)

1. Hydra logged `beams=2` (spec wants 3 even items → 3 beams). Same as #84.
2. Pass-6 fit warning `clearance < 0` showed on a 4-seat Hydra harness seat during petrify, not on the dedicated wheel-monster 4–8 shots.

## Movement dry-run

`git merge-tree --write-tree origin/main HEAD` is clean (`c4da089f…`).

`origin/movement` has no merge-base. File-level overlap vs `origin/main` with different blobs: `scripts/main.gd`, `scripts/dev/shot_harness.gd`, `scripts/dungeon_art.gd`, `assets/ui/anim/intent_claw_burst_f0.png`–`f3.png`. Nathan reconciles movement himself. Never checked out `movement`.

## Not committed

`project.godot`, `default_bus_layout.tres`, audio `.import` churn, harness `*.log`.
