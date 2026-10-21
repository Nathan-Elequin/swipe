# Kickoff prompt (paste into the Cursor cloud project)

```text
You are taking over the remaining animation and art work for Spinheritance (repo Nathan-Elequin/swipe, Godot 4.7).
Read design/handoff/CURSOR-AGENT/README.md fully, then CLOUD-SETUP.md and PIXELLAB-USAGE.md. Everything you need is in the repo; you cannot reach Nathan's PC or Grok Bot's box.

Start at Task 1: finish pass 4 on the existing branch anim/pass4 (draft PR #74).
- Read pass4/PROGRESS.md and pass4/PROMPT-fix.RECONSTRUCTED.md.
- Fix the _apply_mark out-of-bounds error from hook_fx.throw, and make every pass 4 path seat-count agnostic (4-8 seats).
- Generate poison_lock.png with PixelLab (env PIXELLAB_API_TOKEN, a Cursor secret; check /v2/balance first, cap the batch).
- Put the poison colour question for Nathan at the top of the PR (green game vs purple art; don't recolour).
- Then mark the PR "needs local QA" with the exact shot list for LOCAL-QA-PROMPT.md. Visual QA, the 0.675/2.025 speed check and the 6-seat check run on Cherry. Don't claim them from the cloud.

Then continue the ordered task list (pass 5, pass 6, pass 6 art, rerolls): one branch + PR per pass, with a movement dry-run conflict note in each PR. Merge to main only after local QA passes.

Follow every rule in README §4: Crypt Classic pixel style, PixelLab for all net-new art, no player-copy edits, never "Tier"/"ATK", 0.675 speed, and never commit secrets, project.godot or logs.
```
