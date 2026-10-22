# tools/dev

Scripts for the steps that are the same every time. Agents call these instead of redoing the steps by hand (see `.cursor/rules/agent-runtime.mdc`). Windows PowerShell 5.1. Run them from inside the repo, for example `powershell -ExecutionPolicy Bypass -File tools/dev/load-pr.ps1 88`.

| Script | What it does | Exit codes |
|---|---|---|
| `load-pr.ps1 <pr-number\|branch>` | Fetches, then stashes uncommitted work as `wip-before-<branch>-<timestamp>`. Runs `checkout -B <branch>` tracking origin, then `git stash apply` (the stash is kept as a backup). Prints the branch and "Press F5". Refuses to run if the local branch has unpushed commits. | 0 ok, 1 error, 2 stash conflict (nothing discarded) |
| `back-to-main.ps1` | Does the same stash/apply dance, switching to `main` and running `pull --ff-only`. | 0 ok, 1 error, 2 stash conflict, 3 main couldn't fast-forward |
| `ready-prs.ps1` | Makes one `gh pr list --label ready-to-test` call. Prints nothing if there are none, otherwise one line per PR. | 0 ok, 1 gh failed |
| `godot-check.ps1 [path]` | Runs headless `--import` (retried once on a crash), then `--quit`, at BelowNormal priority. Prints `Godot: N errors` (real `SCRIPT ERROR` / `Parse Error` lines only). | 0 clean, 1 errors, 2 import crashed twice |
| `clean-import-churn.ps1` | Restores tracked `*.import` files whose only diff is the uid rewrite and/or LF/CRLF. Leaves new `.import` files and non-`.import` files alone. | 0 ok, 1 error |
| `install-hooks.ps1` | Runs `git config core.hooksPath tools/hooks` so `tools/hooks/pre-commit` runs on every commit. | 0 ok, 1 error |

## Pre-commit guard (`tools/hooks/pre-commit`)

It blocks a commit, with a one-line reason, when the staged changes:
- add `.art-ping.env`, `.art-ping.last`, or anything under `.wrangler/` or `build/`;
- add a literal token or key, such as `Bearer <long value>`, `PIXELLAB_API_TOKEN=<value>` or `ART_PING_KEY=<value>`;
- put a credential in `.cursor/mcp.json` that isn't a `${env:...}` reference;
- add player text containing the whole words `Tier`, `ATK` or `atk`. The hook checks:
  - in `data/player-copy.json`, `data/player-copy.additions.json` and `data/lore.json`, only the `text` / `entry` / `journal` / `body` / `title` / `engraving` values;
  - in `data/player-copy.csv`, only the text column.

  Code, keys and `where` notes are never checked.

The hook never prints the offending line. Never bypass it with `--no-verify`.
