# Task 5 report — `cursor/art-rerolls-e5a9`

**Status:** PixelLab rerolls on a branch from `origin/main`. Needs Cherry local QA. Do not merge until QA passes. Nathan still picks Hornet Swarm and Almighty Worm slash.

**Checkpoint:** Task 5 (`art/rerolls`). Task 4 (`art/wheel-monsters`) still waits on the unmerged pass 6 PR (same PNG paths as the B4 placeholders). Task 6 remains paused.

**Base:** `origin/main` `adc250d`. Not stacked on `anim/pass4`, `anim/pass5-hotbar`, or `anim/pass6-wheel-monsters`.

## PixelLab

- Token present (`PIXELLAB_API_TOKEN` length 36). Never written to disk.
- `GET /v2/balance` before the batch: **1721 / 2000**.
- `PL_BUDGET=40`, floor ~200. Stopped at **24** gens (`calls.log` usage_gens, not the balance delta).
- Balance after: **1697 / 2000**.
- One contact sheet per batch review: `design/visual/anim-qa/rerolls/sheet_fx.png`, `sheet_hornet_old_vs_new.png`, `sheet_worm_old_vs_new.png`.

| Gens | What |
|---|---|
| 8 | bases: green drip, green bubble, hook_taut, 2× hornet slash, 2× worm slash, 1× worm body |
| 2 | extra worm slash (picked s71: circular maw + segmented body) |
| 8 | anims: stamp, claw, drip, burst, petrify, sai_split, hornet, worm |
| 4 | stamp/petrify last-frames |
| 2 | stamp/petrify anims toward last-frames (kept r4) |

Poison prompts used green `#7dba7d` / `#d8f0d0` / `#8cbc48`. Burst unique colours after cleanup: those greens plus outline; no purple.

## Commits

- `art-rerolls(1): green poison, weak FX, hornet/worm candidates`

## Files

Replaced on main (existing `.import` kept):

- `assets/ui/anim/ticker_token_stamp_f0-3.png` (12×12)
- `assets/ui/anim/intent_claw_burst_f0-3.png` (24×24)
- `assets/dungeon/anim/sai_split_f0-7.png` (24×24)

New at spec paths (hand-written `.import`, Nearest / lossless / no mipmaps):

- `assets/ui/anim/poison_badge_drip_f0-3.png` (8×8, green)
- `assets/ui/anim/poison_burst_f0-3.png` (24×24, green)
- `assets/ui/anim/petrify_shatter_f0-4.png` (30×30)
- `assets/dungeon/anim/hook_taut.png` (24×24)

Hornet / Worm stay off live slash until Nathan picks. Old run4 frames remain in `design/handoff/CURSOR-AGENT/art-source/run4/final/assets/dungeon/anim/slash/`. Candidates:

- `design/visual/anim-qa/rerolls/candidates/hornet_swarm_slash_*`
- `design/visual/anim-qa/rerolls/candidates/almighty_worm_slash_*`

`heart_drip` left alone.

Untouched: `data/player-copy.json`, `project.godot`, secrets, itch, pass 4/5/6 branches.

## Pass 4 overlap

`anim/pass4` already has purple poison drip/burst, petrify, and hook_taut at these same spec paths. When that PR merges, **keep this branch’s green poison** and the rerolled petrify / hook / stamp / claw / sai. Do not take pass 4’s purple drip/burst.

## Cherry shot list

No new harness stems. Paste `LOCAL-QA-PROMPT.md` with branch `cursor/art-rerolls-e5a9`. Cloud Godot is skipped (empty viewport / no GL).

Look at:

- `design/visual/anim-qa/rerolls/sheet_fx.png`
- `design/visual/anim-qa/rerolls/sheet_hornet_old_vs_new.png`
- `design/visual/anim-qa/rerolls/sheet_worm_old_vs_new.png`

In-game (windowed 1680×1040), confirm:

- poison badge drip and burst read **green**, not purple
- ticker stamp press, claw burst shards, petrify shatter, sai propeller→X, hook taut prongs
- `Engine.time_scale` 0.675 / Shift 2.025
- text audit 0 "Tier" / "ATK"

Hornet / Worm still use the still fallback until a pick is copied into `assets/dungeon/anim/slash/`.

## Movement dry-run

`origin/movement` has unrelated history (no merge base). File-level overlap vs `origin/main` (files this branch changes that also exist on `movement` with different content):

- `assets/ui/anim/intent_claw_burst_f0.png`
- `assets/ui/anim/intent_claw_burst_f1.png`
- `assets/ui/anim/intent_claw_burst_f2.png`
- `assets/ui/anim/intent_claw_burst_f3.png`

Do not checkout `movement`.

## Deviations

- Poison drip: PixelLab 32px anim was green but nearly identical at 8×8; 1px falling bead on f2/f3 is a small hand-fix after downsample (allowed for small issues).
- Stamp and petrify needed last-frame pairs (`stamp_r4`, `petrify_r4`) after weak first anims.
- Hornet seed 43 (init from the 96px body) fused again; seed 41 text-only kept.
- Worm seeds 51/57/61/73 read as snakes; s71 kept (lamprey maw + segmented body).
- `heart_drip` not rerolled (README: leave unless broken).

## Gold boxes pending

None filled (`review_note` empty on the board).

## Questions for Nathan

1. Hornet Swarm slash: old fused wasp vs new three-hornet swarm (`sheet_hornet_old_vs_new.png`). Only the pick goes into `assets/dungeon/anim/slash/`.
2. Almighty Worm slash: old maw-ring vs new sandworm (`sheet_worm_old_vs_new.png`). Same rule.

## What Nathan should look at

The three contact sheets, green poison in-game, and the two slash picks. Do not merge until Cherry QA.
