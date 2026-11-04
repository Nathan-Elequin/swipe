# CI: Web Playtest → itch (butler)

GitHub Actions workflow: `.github/workflows/playtest-itch.yml`.

Exports Godot **Web Playtest** (`build/web-playtest/index.html`, `custom_features=playtest`) with **Godot 4.7.2**, then pushes with **butler** to the friends page only.

## Target (locked)

| | |
|---|---|
| itch project | `nathan-elequin/spinheritance-playtest` |
| channel | `html5` |
| URL | https://nathan-elequin.itch.io/spinheritance-playtest |

**Do not** push `nathan-elequin/swipe` (public page) from this workflow.

## Repo secret Nathan must add

1. Name (exact): **`BUTLER_API_KEY`**
2. Get a key: itch.io → Account settings → [API keys](https://itch.io/user/settings/api-keys) → generate a key with push access for the playtest game (or a full key you trust for this repo only).
3. Add it: GitHub → `Nathan-Elequin/swipe` → **Settings → Secrets and variables → Actions → New repository secret** → name `BUTLER_API_KEY`, paste the key.
4. Never commit the key. Never put it in the workflow YAML, docs, or chat logs on purpose.

Without the secret, the workflow still **exports** and uploads a `web-playtest-<sha>` artifact, then **fails the butler step clearly** so you know to add the secret and re-run.

## How to run (safe default)

**Manual only** — Actions → **Playtest itch** → **Run workflow**.

Optional input: **Export only — skip butler** (`skip_butler`) if you want the artifact without uploading.

## Optional: auto on tip push

The workflow listens to `push` on `playtest/latest`, but the job **does not run** unless you set a repository **variable**:

- Name: `PLAYTEST_ITCH_AUTO_ON_PUSH`
- Value: `true`

Settings → Secrets and variables → Actions → **Variables**. Leave unset (or anything other than `true`) to keep tip merges from spamming itch.

## Optional: environment approval

In the workflow YAML there is a commented `environment: itch-playtest`. Uncomment it and create that Environment with required reviewers if you want a human click before butler runs.

## Local equivalent

```bash
# Godot 4.7.2 on PATH / GODOT=
Godot --headless --path . --export-release "Web Playtest" build/web-playtest/index.html
butler push build/web-playtest nathan-elequin/spinheritance-playtest:html5
```

Also documented in `tools/PLAYTEST.md` and the repo `README.md`.
