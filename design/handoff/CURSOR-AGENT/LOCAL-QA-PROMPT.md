# LOCAL QA prompt (paste into Cursor local on Cherry)

Fill in `<BRANCH>`, `<PR>` and `<SPEC NAMES>` first.

```text
You are doing LOCAL QA for Spinheritance PR <PR> (branch <BRANCH>) on Nathan's PC. Read design/handoff/CURSOR-AGENT/README.md (sections 4-6) and CLOUD-SETUP.md (Pitfalls) first.

Safety:
- Nathan's checkout C:\Users\Natha\Documents\boss-rush is on branch `movement` with UNCOMMITTED edits. Never checkout, stash, reset, commit or run Godot there. Never save scenes from an editor opened on it.
- Work in a worktree: `git -C C:\Users\Natha\Documents\boss-rush fetch origin` then `git -C C:\Users\Natha\Documents\boss-rush worktree add C:\Users\Natha\Documents\boss-rush-wt\qa-<BRANCH-SLUG> <BRANCH>` (or reuse it if it exists).
- godot-mcp attaches to whichever Godot editor is open. If the open editor is Nathan's (on the movement folder), do NOT use godot-mcp. Use the shot harness CLI below, or ask Nathan to close it and open the editor on the QA worktree.
- Never kill Godot processes you didn't start; Nathan may be playtesting. Run one Godot process at a time.
- Never print or commit secrets (.art-ping.env, PIXELLAB_API_TOKEN).

Steps:
1. Parse check: & "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path <worktree> --quit
   It must show no new SCRIPT ERROR or parse errors. The addons/godot_mcp errors are pre-existing.
2. Shots (windowed, 1680x1040; NOT --headless): & <godot> --path <worktree> -- --shots=<stems> --shots-out=res://design/visual/anim-qa/<spec>
   Do every item in each spec's QA section and in the pass's BUILD-ORDER QA list for <SPEC NAMES>. Add a 6-seat shot for every spec. Open and look at every PNG. Compare against the mockups (design/handoff/CURSOR-AGENT/mockups/...) and qa-reference/.
3. Speed: confirm Engine.time_scale is 0.675 during normal play and 2.025 while Shift is held in a cascade, and back to 0.675 on release. Use the harness logs ([cascade-ff] lines) or a print.
4. Seats: confirm nothing assumes 8 seats (4, 6 and 8 seats at minimum; for pass 6 also 5 and 7, with fit-table clearances logged ≥ 0).
5. Text audit (runs with the harness): 0 "Tier", 0 "ATK"/"atk". No player-copy changes in the diff (data/player-copy.json untouched unless Nathan asked).
6. Fix small bugs on <BRANCH>. Commit as `<pass-id>(n): local QA fixes`. Commit only your files: no project.godot, default_bus_layout.tres, .godot/, unrelated .import churn, logs, build/, .wrangler/, .art-ping.*.
7. Movement dry-run: origin/movement has unrelated history (no merge base), so do the file-level overlap check from README section 5 step 4: files changed vs origin/main that also exist on origin/movement with different content. Also confirm `git merge-tree --write-tree origin/main <BRANCH>` is clean. List the results in the PR.
8. Push, update the PR description (shots list, speed result, seat result, audit result, conflicts, questions for Nathan). If everything passes, merge the PR to main. Then run `git -C C:\Users\Natha\Documents\boss-rush fetch origin main:main` (this only updates local main; never touch movement) and remove the QA worktree.
Don't export or push to itch.
```
