---
id: REQ-20261114-nib-map-point-copy
status: open
priority: normal
branch: cursor/nib-map-point-copy-bd13
tip_sha: 04e8d168
created: 2026-11-14T10:15:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New → cabin first visit (entryway / main with map)
---

# Nib map-point + continue-mission copy

Wires final Jam/Nathan Nib lines `nib.first.map_point` and `nib.return.continue_mission` into player-copy, and makes `_point_map_after_first_speech` say the map-point line then re-show the map pointer. Continue-mission already prefers that key when present.

## What to verify

- First cabin visit after welcome: Nib says exactly "Welcome in! Your first run starts at the map, right over there." then the map pointer stays/reappears.
- First return after keys/room unlock: Nib says exactly "Found the keys, and every room's open! Now keep the mission going: bring home unique finds for the trophy cabinet. The map's waiting." and gestures at the map.
- No "Tier" / "ATK" in the lines. Copy text unchanged from the approved rows.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | Brand New → first cabin visit after welcome speech | dialog shows nib.first.map_point; map pointer on Grandpa's map | 01-first-map-point.png |
| 02 | main | first return after key unlock / rooms open | dialog shows nib.return.continue_mission; map pointer on map | 02-continue-mission.png |

## Pass criteria

- Both lines match player-copy.json verbatim (readable in shot or dialog log).
- Pointer visible on the map hotspot after each line.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261114-nib-map-point-copy/`
