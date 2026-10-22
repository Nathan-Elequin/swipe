# Task 4 — Pass 6 PixelLab art

Branch: `art/wheel-monsters` (worktree `C:\Users\Natha\Documents\boss-rush-wt\art-wheel-monsters`).
Scratch: `%USERPROFILE%\pl-runs\pass6-wheel` (outside the repo).

Needs `PIXELLAB_API_TOKEN` in the environment. This PC did not have it when Task 4 started.

```
set PL_RUN_DIR=%USERPROFILE%\pl-runs\pass6-wheel
set PL_BUDGET=40
py -3 design\handoff\CURSOR-AGENT\pass6\gen_wheel.py --batch lock
py -3 design\handoff\CURSOR-AGENT\pass6\gen_wheel.py --batch medallions
py -3 design\handoff\CURSOR-AGENT\pass6\gen_wheel.py --batch missing-bases
py -3 design\handoff\CURSOR-AGENT\pass6\gen_wheel.py --batch wheel --ids goblin,skeleton
# then remaining ids in 20s, then breathe, facing, install
```

`--batch all` is ~174–190 gens. Cap each run with `PL_BUDGET`. Floor ~200 remaining.
