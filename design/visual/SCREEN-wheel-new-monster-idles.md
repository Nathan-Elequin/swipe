# SCREEN: wheel new-monster idles

Status: wiring fix (cloud 2026-11-06). Seats for new monsters must idle-animate from authored frames the same way Skeleton / Twins (`hollow`) / Leech League do.

## Root cause (verified on disk + code)

| Fact | Detail |
|------|--------|
| Loader path | `boss_wheel` seats use `DungeonArt.wheel_frames_all()` → `monster_wheel_frames()` → `_wheel_tex` loops at 200ms/frame when `frames.size() > 1`. |
| Established | `skeleton` / `leech_league` / `hollow` / `goblin` have `assets/dungeon/anim/wheel/<id>_wheel_idle_f0..f3.png` (often byte-identical to facing idle). Multi-frame → motion. |
| New monsters | `imp`, `quicksand_crab`, `huntsman`, `phantom`, `collector`, `glass_asp` have **no** `wheel_*_idle` pack. They **do** have distinct `facing/<id>_facing_idle_f0..f3.png` (4/4 distinct pixel buffers). |
| Bug | `wheel_frames_all()` fell back to **only** `facing_idle_f0` as a one-element array. `_wheel_tex` treats size==1 as frozen. |
| Not the bug | Missing registration in `MONSTER_PNG` (ids are present). Not a static cache of wrong textures. Not "frames too similar" for Imp/Crab/etc. (pairwise pixel deltas are large). |
| Anvil | Facing idle f0–f3 are **identical** (1/4 distinct). Authored motion lives in `anvil_wheel_idle_f0..f3` (4/4 distinct). Wheel path already preferred — Anvil was not this freeze. |

## Fix (this pass)

- `scripts/dungeon_art.gd`: `monster_wheel_frames` falls back to the full `_facing_strip` when wheel idle/breathe/base is missing or only a single still. `wheel_frames_all` last resort uses the full facing strip, never `[f0]` alone.
- No new PNG generation. No procedural wobble. No green Imp / rejected stills.
- Optional later (Pixel): install `wheel/<id>_wheel_idle_fN` crops for the new ids to match the old pack layout; not required for motion once facing strip is wired.

## Verify

1. `python3 tools/qa/check_wheel_new_monster_idles.py` exits 0.
2. With Godot: `godot --headless --path . --script res://scripts/dev/wheel_new_monster_idles_selftest.gd` exits 0.
3. F5 / repot: dungeon wheel with Imp + Quicksand Crab + an established neighbor; wait ≥0.4s without spinning — new seats change pose; mid-spin still freezes. Capture time-pair at 1680×1040 (`playtest/repot/inbox/REQ-20261106-wheel-new-monster-idles.md`).

## Out of scope

- Item hotbar icons / item idle
- Regenerating Imp / Crab / Glass Asp art
- Player copy, timings unrelated to seat idle, UI scale
