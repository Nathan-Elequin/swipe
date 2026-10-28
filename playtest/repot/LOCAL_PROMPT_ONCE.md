# Paste into local Cursor (Cherry or Mac Documents/swipe)

You are in the Spinheritance / swipe repo. Ignore my other ask for a moment if `playtest/repot/inbox/` has any `status: open` or `needs_fix` requests — fulfill those first per `.cursor/rules/playtest-repot.mdc` and `playtest/repot/SCHEMA.md`.

Right now prioritize:

`playtest/repot/inbox/REQ-20261028-cabin-flip-167.md`

Steps:
1. Sync to `playtest/latest` without destroying my WIP (stash dance / `tools/playtest-sync.sh` on Mac).
2. F5 the playtest build in the Godot already open (do not kill foreign Godot processes).
3. Take every screenshot listed in that request via **godot-mcp** in-game (viewport 1680×1040 if possible).
4. Write `playtest/repot/outbox/REQ-20261028-cabin-flip-167/RESULT.md` + PNGs under `shots/`.
5. Set inbox status to `done`. Commit + push to `playtest/latest` with `[repot] fulfill REQ-20261028-cabin-flip-167`.
6. Reply with tip SHA and pass/fail counts only.

Critical expect: hall is plate-only — no stacked case frames, labels, or “? pool locked”; no shelf arrows/gauge.
