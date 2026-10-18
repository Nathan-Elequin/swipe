# T0-rules — report

## Status
PASS

## Commits
- `cc620a7` T0-rules(1): replace visual-handoff with the design loop rule
- `6320b52` T0-rules(2): add swipe-design-loop rule
- `970f187` T0-rules(3): add handoff folder template
- this commit: T0-rules(4): write the handoff report

## Files changed
- `.cursor/rules/visual-handoff.mdc` (deleted)
- `.cursor/rules/swipe-design-loop.mdc`
- `design/handoff/README.md`
- `design/handoff/.gdignore`
- `design/handoff/_template/TASK.md`
- `design/handoff/_template/REPORT.md`
- `design/handoff/T0-rules/REPORT.md`

## Checks run + results
- `data/content-board.json`: no non-empty `review_note`.
- Paths kept only if they exist: `design/visual/`, `design/visual/layouts/`, `design/handoff/`, `assets/`, `scripts/`, `scenes/`, `data/player-copy.json`.
- Paths in the §9 draft that are not in the repo: `tools/art/`, `scripts/ui/tokens.gd`, `themes/swipe_theme.tres`, `design/visual/tokens.json`. No `themes/` folder.
- `.cursor/rules/` after the swap: `author-lock.mdc`, `content-board.mdc`, `corrupt-png.mdc`, `paper-fight.mdc`, `swipe-design-loop.mdc`, `unique-art.mdc`. `alwaysApply: true` on the new rule. No `AGENTS.md` added.
- `git status`: untracked `design/cli-runs/T0-rules-*.txt/log` left unstaged. No `player-copy.json`, `project.godot`, or `default_bus_layout.tres` edits.
- Godot was not launched.

### Rule conflicts (not rewritten)
- `unique-art.mdc`: the agent finds or draws a card PNG. The new rule says do not overwrite PNG bytes.
- `corrupt-png.mdc`: the agent replaces a corrupt PNG with new pixels. The new rule says do not overwrite PNG bytes.
- `content-board.mdc`: a gold box is implemented the same turn, including art and Ability text. The new rule says `TASK.md` is the assignment, stay on its file list, and do not edit player-facing copy.
- `author-lock.mdc`: a gold-box note can replace locked player-facing fields. The new rule says no player-facing copy edits. Jam owns `data/player-copy.json`.
- `paper-fight.mdc`: gameplay questions go to Nathan in chat. The new rule puts two readings in `REPORT.md` and stops. Paper-fight also allows feel and animation in the same turn; the new rule stays on the task file list.

## Deviations
- §9 named `tools/art/**`, `scripts/ui/tokens.gd`, `res://themes/swipe_theme.tres`, and `design/visual/tokens.json`. Those paths are not in the repo, so the rule cites `design/visual/`, `scripts/**`, and `scenes/**` instead.
- The font line says a tokens file under `design/visual/` instead of `tokens.json`.
- Commit (1) only deleted `visual-handoff.mdc`. Adding the new rule in the same `git add` failed because the deleted path was still on the command, so the new file landed in commit (2).
- `_template/TASK.md` is the §6 template unchanged. It still names `design/visual/sizes/`, which is not in the repo.

## Questions
None.

## What Nathan should look at
No acceptance PNGs. Read `.cursor/rules/swipe-design-loop.mdc` and `design/handoff/README.md`.
