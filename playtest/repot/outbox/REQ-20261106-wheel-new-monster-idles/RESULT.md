---
id: REQ-20261106-wheel-new-monster-idles
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-06T17:30:00-06:00
machine: Cherry
tip_sha: cdc0cda7d0a6e49a4a86b38a233614502f2a682f
branch_shot: playtest/latest
godot: F5 playtest (godot-mcp, editor already open)
viewport: 1680x1040
---

# Result

Shots are the running game viewport saved at native 1680×1040. The request named `cursor/wheel-new-monster-idles-9f05`. That branch was not checked out. Local gameplay and copy edits stayed in the worktree. The tested commit is `cdc0cda7d0a6e49a4a86b38a233614502f2a682f` on `playtest/latest`. The worktree was dirty (import churn and uncommitted data). These PNGs are not contact sheets.

Runtime proof is the live wheel: `_glow_t`, `spinning`, and `_wheel_tex()` resource paths sampled in the running game, plus the PNG pair. File checks are separate and do not stand in for motion.

| id | verdict | note |
|----|---------|------|
| 01 | pass | 1680×1040. Idle ring, not spinning, facing −1. Glow 0.0225. Imp `imp_facing_idle_f0`, Quicksand Crab `quicksand_crab_facing_idle_f0`, Skeleton `skeleton_wheel_idle_f0`. Seats not held. |
| 02 | pass | Same ring and camera, still not spinning. Glow 0.52875 (Δ 0.506 s, above 0.4 s). Not a 4-frame loop (loop is 0.8 s at 200 ms/frame). Imp f0→f2, Crab f0→f3, Skeleton f0→f3. PNG byte diff vs 01: 117911 bytes, including the Imp, Crab, and Skeleton regions. |
| 03 | skipped | Optional clip. The PNG pair already shows the pose change. |
| 04 | pass | `spin_to` mid-idle. At capture, spinning true, rotation 0.93 rad (was 0), glow 0.810. Every seat `_wheel_idle_held` and locked to its f0 texture. A later sample in the same spin (glow 1.069, rotation 6.54) stayed on those same f0 paths, so idle did not advance while the ring turned. |

## Runtime frame advance (same idle interval, not a file check)

All eight seats changed authored frame paths between 01 and 02:

- Imp f0 → f2
- Skeleton f0 → f3
- Quicksand Crab f0 → f3
- Huntsman f1 → f3
- Phantom f1 → f0
- Collector f1 → f0
- Glass Asp f2 → f0
- Anvil f2 → f1 (`anvil_wheel_idle`, not the facing strip)

Wheel texture filter was nearest. No procedural bob (`_breathe_bob` is off). During the spin, glow kept moving and every seat stayed on f0.

## File checks (not playback)

- `py -3 tools/qa/check_wheel_new_monster_idles.py` — exit 0. Distinct PNG buffers on disk for the new ids and the controls.
- `wheel_new_monster_idles_selftest.gd` — exit 0 (`failed=false`). This loads frames and checks the 200 ms index math. It does not run the wheel on screen. Godot printed resource-leak lines at process exit; the script still quit 0.

## Blockers

None.

## Shots

- `shots/01-idle-t0.png`
- `shots/02-idle-t06.png`
- `shots/04-spin-freeze.png`
