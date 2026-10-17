# JAM-COPY — map + rope exit (DRAFTS for Jam; nothing here is in player-copy.json yet)

Cursor must not apply these. Code reads keys only. Until Jam approves, the fallback below is what shows.

| ID | Key | Current text | Proposed text | Where / why | Fallback until approved |
|---|---|---|---|---|---|
| J-01 | `map.route.gatehouse.mode` | Classic | **Adventure Mode** | Classic route tag line 2 + panel mode line. Matches Nathan's route names | shows "Classic" |
| J-02 | `map.route.long_drop.mode` | Adventure Mode | **Challenge Mode** | Challenge route tag + panel. Matches `title.adventure` = "Challenge Mode", the mode `_begin_adventure` starts | shows "Adventure Mode" (**misleading: approve J-01/J-02 together**) |
| J-03 | `map.go.named` (new) | (none) | **Off we go: {mode}** ({mode} = `map.route.<id>.mode`) | Confirm plank names the mode. Longest is "Off we go: Challenge Mode", 40 px, fits 1 line | `map.go` "Off we go" |

No new rope copy is needed. `rope.climb_sub` "Bring home everything you're holding." and `rope.deeper_sub` "Keep your sack. Belly {n} is waiting." are now always-on consequence lines (they fit at 24/26 px in 1 line, 2-line room reserved). `map.route.shortcut.mode` "Quick Start" is the dev tag label only.
