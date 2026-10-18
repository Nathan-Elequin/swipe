# 05-playtest-pass — Oct 17 playtest
Checkpoint: origin/main   Branch: main   Chat: this
## Read
- `C:\Users\Natha\Downloads\Oct 17 at 10-07 PM.txt`
- `.cursor/rules/swipe-design-loop.mdc`
- `design/paper-fight/CURRENT.md`
## Do
1. Challenge click-to-spin + Undo until first fight action
2. Cabin/tutorial bugs and layout from the playtest
3. Map/door/rope copy, remove peek, trophy dump/fly
4. Journal/cat stubs + Pixel packet
5. Shot harness + text audit to zero; REPORT.md
## Files you may touch
- `scripts/**`, `scenes/**`, `data/player-copy.json` (named keys only; Nathan override), `data/author-locks.json` (keep flags), `design/cli-runs/05-playtest-pass/**`, `design/visual/HANDOFF-2026-10-17-playtest.md`, `design/paper-fight/**`
## Acceptance (must PASS)
- Text audit `failures: []` on the named 05 shots
## Do not
- Do not push. Do not restyle locked copy the playtest did not name. Do not overwrite PNG bytes.
## Resolved decisions
- Locked keys `tutorial.beat.01.body`, `tutorial.nudge_item`, `challenge.click_target`, `challenge.spin_confirm` are an override; keep `author_lock`
- Undo after click-to-spin only until the first fight action
- Folder is `05-playtest-pass` because `03` and `04` already exist on main
