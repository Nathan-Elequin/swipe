# Cloud + local split workflow

| Step | Who / where | Does |
|---|---|---|
| A | **Cursor cloud project agent** (Linux VM cloning `Nathan-Elequin/swipe`) | PixelLab generation + cleanup, specs/docs, GDScript, placeholders and `.import` files. Pushes a branch and opens a PR. |
| B | **Cursor local on Cherry** (Nathan's Windows PC, Godot 4.7.2, godot-mcp) | Pastes `LOCAL-QA-PROMPT.md`. Runs the game windowed at 1680x1040 and takes the shots. Checks speed (0.675 / Shift 2.025), 6 seats and the text audit. Fixes small issues on the same branch. |
| C | Either | After B passes: movement dry-run note in the PR, then merge the PR to `main` (allowed per pass). On Cherry, `git fetch origin main:main`. |

One pass = one branch = one PR. Don't start pass N+1 code on top of an unmerged pass N unless you branch from pass N on purpose and say so in the PR.

## Cloud agent setup
- **Secret:** in the Cursor cloud project, add a secret named exactly `PIXELLAB_API_TOKEN`.
  - It is Nathan's PixelLab account (nathan.elequin@gmail.com); the key is on the pixellab.ai account page.
  - The toolkit reads it from the environment only. Never echo it, write it to `.env`, or commit it. `.env` is gitignored; `.env.example` stays blank.
- **Python deps** are for the art tools only, not the game: `pip install -r design/handoff/CURSOR-AGENT/pixellab/requirements.txt` (requests, pillow, numpy). `.cursor/environment.json` runs this as its `install` step.
- **PixelLab scratch:** `export PL_RUN_DIR=$HOME/pl-runs/<batch>`. Commit only finals at the spec paths + one contact sheet per batch (under `design/visual/` or the PR).
- **Godot on the cloud VM: skipped on purpose.**
  - The shot harness needs a real window: `--headless` gives an empty viewport (see `design/handoff/T1-shots-cli/REPORT.md`).
  - The project uses GL Compatibility; on Linux that would need xvfb + Mesa llvmpipe, which is untested here.
  - So visual QA happens on Cherry. A cloud agent *may* install Godot 4.7.2 Linux for a parse check: `godot --headless --path . --quit`, or `--script res://tools/qa/check_shot_cli.gd`. That is optional and not a substitute for step B.
  - `addons/godot_mcp` has pre-existing parse errors that show up in headless logs; ignore those.
- Don't commit `project.godot`, `default_bus_layout.tres`, `.godot/`, or `.import` churn on unrelated files if you ever run Godot.

## Local QA (step B)
Paste `LOCAL-QA-PROMPT.md` into Cursor local on Cherry, filling in the branch/PR. Godot: `C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`.

## Pitfalls a new agent will likely hit
1. **The design-loop rule contradicts this handoff.** `.cursor/rules/swipe-design-loop.mdc` says "do not draw PNGs, no merges, no pushes". For this handoff Nathan approved PixelLab art generation, push + PR, and a merge per pass after local QA (see the README). Copy and "Tier" rules still apply.
2. **Speed reset.** Anything that sets `Engine.time_scale = 1.0` breaks the game's normal 0.675. Restore to `ANIM_TIME_SCALE`; Shift is ×3 → 2.025. This has happened once already.
3. **8-seat assumptions.**
   - The wheel runs 4–8 seats, and a test branch uses 6. Index arrays by `slices.size()`.
   - Pass 4 already hit an out-of-bounds index 5 in `_apply_mark` via `hook_fx.throw`.
   - Re-validate seat indexes after `collapse_slice`.
4. **Pass 5 placeholders overwriting final art.** The BUILD-ORDER prompt says "create placeholders". The final pass 5 art is already on main, so don't overwrite it.
5. **Poison colour is undecided** (green game vs purple art). Don't recolour, and don't generate more poison art, until Nathan picks.
6. **Player copy.** You can't add or reword strings in `data/player-copy.json`. Use existing keys via `PLAYER_COPY.text()` and flag anything missing. "Silenced", "Loaded" and the Sling tooltip already exist as Jam strings.
7. **Hidden words.** The text audit flags "Tier", and must flag "ATK"/"atk". Debug labels and harness overlays count if they render in-game.
8. **`.import` files.**
   - New PNGs under `assets/` need a `.import` with `compress/mode=0` and `mipmaps/generate=false`. The filter comes from the project default (Nearest).
   - A cloud agent without Godot must hand-write them from an existing `.import` with a fresh `uid://` and a `dest_files` hash `<name>.png-<md5 of res path>`. This handoff did exactly that for the pass 5 art.
   - Godot rewrites them on the next import on Cherry, so expect small `.import` diffs during local QA and commit only the ones for your files.
9. **PNG bytes ownership.** Don't re-save or "optimise" existing art PNGs; it changes the bytes and the hashes. Only touch PNGs your task generates.
10. **`design/handoff/.gdignore`** makes Godot skip this folder (good: no imports for art-source). Don't move art-source PNGs into `assets/` except the finals the specs name.
11. **godot-mcp attaches to the open editor.** On Cherry that is usually Nathan's editor on the `movement` checkout, with uncommitted edits. Never let it run or save there. Use a worktree under `C:\Users\Natha\Documents\boss-rush-wt\` and an editor opened on that worktree, or use the shot harness CLI.
12. **Nathan may be playtesting.** Never kill Godot processes you didn't start. Run one Godot at a time. `user://home_cabin.json` is shared; the harness backs it up and restores it, but don't run two harnesses at once.
13. **Windows-only bits a cloud agent can't verify:**
    - the `C:\Users\Natha\...` paths in history docs and `PROGRESS.md`
    - PowerShell `run*.ps1` CLI scripts
    - `tools\request_art.cmd`
    - the art-ping webhook (`.art-ping.env`; not needed)
    - the editor-only `DevFlag.on()` / `OS.has_feature("editor")` paths
    - godot-mcp
    - anything visual: shots, the speed check, 6-seat layouts, B4 overlap checks

    Mark these "needs local QA" in the PR rather than claiming them.
14. **Line endings.** Cherry checks out CRLF. Keep `.gd` diffs minimal; don't reformat whole files (`main.gd` is ~15k lines and conflicts with `movement` easily).
15. **Golem and wizard have no PixelLab base yet.** Pass 6 wheel/facing art for 58 monsters needs them generated first. `three_seeker` is excluded.
16. **PixelLab quirks** (details in PIXELLAB-USAGE.md):
    - a bitforge style image must equal the output size
    - frame 0 of an animation is usually the input
    - small UI must be generated at 2–4x, then downsampled
    - bases can face left (mirror them)
    - the shared balance can drop from Nathan's own use
17. **Merge-tree on old git.** `git merge-tree --write-tree` needs git ≥ 2.38. Otherwise do a throwaway `git worktree add` + `git merge --no-commit --no-ff` and then `git merge --abort`. That is local only and never pushed.
18. **Reconstructed fix prompt.** The pass 4 fix prompt is a reconstruction. Treat it as intent, not as Nathan's exact words.
