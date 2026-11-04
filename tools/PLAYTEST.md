# Playtest sync (Mac / Godot)

Canonical tip for friends and Nathan’s F5 playtest: **`playtest/latest`**.

Godot does **not** auto-pull. The corner build stamp is the truth — it should match the SHA this script prints. A trailing `*` on the stamp means dirty local edits.

## Before every F5

From the swipe repo root (the same folder you open in Godot):

```bash
./tools/playtest-sync.sh
```

Then F5 that same Godot project. Do not switch project folders.

## What the script does

1. Fetches `origin/playtest/latest`
2. If your tree has local changes or untracked files, stashes them (including untracked) with a `playtest-sync …` message
3. Resets local `playtest/latest` to match `origin/playtest/latest`

Stashes are left for you — nothing is deleted. List them with `git stash list`.

## Tip smoke (headless, no F5)

Automated tutorial-rail regression (data + script invariants). Not a full play-agent.
Covers Brand New / Skip / draft / Goblin choice, Harpy→Dragon spine waits, Continue→auto_spin after kills, Arrow Head from start, and cabin-under-road / pool-1 reveal before arrive.

```bash
./tools/qa/run_tip_smoke.sh
```

Details: `tests/README.md`. CI: `.github/workflows/tip-smoke.yml` on PRs **and push** to `playtest/latest`.

## Itch upload (CI butler)

Friends page only: **`nathan-elequin/spinheritance-playtest`** channel **`html5`**. Never the public `nathan-elequin/swipe` page.

Workflow: `.github/workflows/playtest-itch.yml` (Godot **4.7.2**, preset **Web Playtest** → `build/web-playtest/`).

- **Default:** manual **Actions → Playtest itch → Run workflow** (does not run on every tip merge).
- **Secret (required for push):** repo secret named exactly **`BUTLER_API_KEY`** — create at [itch.io API keys](https://itch.io/user/settings/api-keys), add under GitHub → Settings → Secrets and variables → Actions. Do not commit it.
- **Optional auto on tip push:** set repo variable `PLAYTEST_ITCH_AUTO_ON_PUSH=true`.
- Full notes: `playtest/itch/CI.md`.
