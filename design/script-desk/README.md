# Script desk

One HTML page with every player-facing line on it, so Ctrl+F works. Save writes the JSON the game reads.

## Open it

From the repo: `tools\dev\open-script-desk.ps1`

That starts `tools/script-desk-server.py` on http://127.0.0.1:8765/ (if it is not already running) and opens Zen.

In the Godot editor, **Script** on the pause overlay and in Settings does the same.

## After Save

Stop Play, then F5. You do not need to tell Cursor. Later chats read `data/player-copy.json` (and lore, names, board, catalog when those changed).
