---
id: REQ-20261114-music-devchrome
status: done
priority: high
tip_sha: e5b4a815
branch: cursor/music-devchrome-79f0
created: 2026-11-14T10:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Continue → cabin → Grandpa's map → Verdant Hollow
---

# Music cutback + hidden dev chrome

After a cabin visit, map→biome music must keep the biome intro→loop. Editor dummy chrome (branch tag, copy stamp, map cheats) stays hidden until F11. BuildStamp SHA and Feedback stay visible.

## What to verify

- Entering Verdant Hollow from the map after a cabin return keeps `music_verdant_hollow_intro` → `music_verdant_hollow_loop` at 1s / 3s / 6s (no cut back to `music_cabin`).
- Returning to the cabin starts cabin music once; walking rooms does not restart it.
- Default play: no `🧪 playtest/latest`, no `copy: swipe-player-copy-…` stamp, no map Grant/Fill/Fresh buttons.
- F11 shows those three; F11 again hides them. BuildStamp SHA + Feedback remain.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | cabin main | after first run limp/leave, before map | no branch tag, no copy stamp; BuildStamp + Feedback visible | 01-cabin-no-chrome.png |
| 02 | map | open Grandpa's map | no Grant 3 / Fill / Fresh cheat buttons | 02-map-no-cheats.png |
| 03 | verdant enter | Launch Verdant Hollow; dump music at 0s / 1s / 3s / 6s | verdant intro then loop; never music_cabin | 03-verdant-music.png |
| 04 | cabin | F11 once | branch tag + copy stamp visible; Feedback + BuildStamp still there | 04-f11-chrome-on.png |
| 05 | map | F11 on, open map | cheat buttons visible | 05-f11-map-cheats.png |

Also write `state/03-music.txt` with stream path + volume_db + playing for every Music-bus AudioStreamPlayer at 0/1/3/6s.

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Music state dump proves biome bed through +6s after map enter.
- Dev chrome absent by default; present only after F11.

## Outbox path

`playtest/repot/outbox/REQ-20261114-music-devchrome/`
