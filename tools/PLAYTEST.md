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
