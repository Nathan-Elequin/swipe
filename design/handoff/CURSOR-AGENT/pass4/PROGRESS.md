# Pass 4 run notes (Cherry)
- wt: C:\Users\Natha\Documents\boss-rush-wt\anim-pass4 branch anim/pass4 off origin/main cce6346 (created)
- CLI: C:\Users\Natha\AppData\Local\cursor-agent\versions\2026.10.19-6bbf2c4 node.exe index.js (see run3/run11.ps1)
- prompt: run4pass/12-prompt.txt (verbatim Pass 4 block)
- Nathan's Godot PIDs at start (DO NOT KILL): 19768, 41820
- stage on Cherry: C:\Users\Natha\Documents\boss-rush-wt\pass4-stage (specs identical to main except CRLF -> reverted; art in stage\art; run12.ps1/run12fix.ps1)
- 01:20 CLI main run launched (powershell PID 50804). Logs design\cli-runs\12-anim-pass4\agent.log, exit.txt
- Art: all pass4 files real except poison_lock.png (6x6) -> placeholder. Plan: drop art after main run, then PROMPT-fix.md
- CLI switched worktree to branch anim/pass4-status-utility (prompt verbatim). Must fast-forward anim/pass4 to it later (git branch -f anim/pass4 ... after checkout back) before PR.
- Game poison = green (#7dba7d droplet, num #d8f0d0) vs art purple (#4a3a78/#7a6aa8, green accent #8cbc48 in burst) -> FLAG
- 01:48 CLI shooting QA (shots.log, shots2.log). Nathan playtesting via editor (game pid 35844, editor 41820)
- 02:09 resumed after interruption: fix run still alive (ps 16232, node 30624), shooting QA. PROMPT-fix.md vanished from wt dir (agent.log/err truncated at 02:07 too) -> restore from run4pass/PROMPT-fix.md before commit. Nathan's editor 41820 no longer running (not ours to touch).
- 02:22 fix run still going (shots-all2.log). no commit yet

Cloud (2026-10-21, this project owns `anim/pass4`):
- Kept `47fb804` anim-pass4(2) and `321aaf8` anim-pass4(3). Did not redo them. Merged `origin/main` for `.cursor/rules/art-handoff.mdc`.
- Poison colour: Nathan 2026-10-21 — green. Stated on PR #74; not asked again.
- PixelLab `poison_lock.png`: 3 charged gens (2×32px + 1×48px; one 24px 422 not charged). Balance before 1724. Picked seed 37 (green padlock), palette-snap, nearest down to 6×6. Contact: `poison-lock-contact.png` in this folder.
- Drip/burst still purple — Task 5 reroll. No visual QA from cloud.
