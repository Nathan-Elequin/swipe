---
id: REQ-20261028-clear-torch-parade
status: open
priority: high
pr: 173
tip_sha: a8f2abf5
branch: cursor/clear-torch-parade
base: playtest/latest
created: 2026-10-28T17:20:00-05:00
created_by: cursor
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress or a fresh Adventure/Challenge → clear the wheel (or a dev clear) so the rope exit is about to open
---

# Torch parade on dungeon clear

Before the rope exit opens, the hub plays a clear parade of about 2.7 seconds. No wax seal. Spin copy is unchanged.

## What to verify

- A burst plays on the wheel hub as the clear sting starts.
- Sprout cheers with `run_victory` (twice), facing right, not mirrored.
- Sprout hops right on `run_walkoff` (facing right, not mirrored) into the burrow mouth.
- A soil wipe travels left to right (`burrow_curtain`).
- Sprout arrives with a hop to the right (`hero_arrive`) and a short dust puff.
- The rope exit opens only after that parade. The wax seal is not part of it.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | the frame the dungeon clears, before the rope | gold/torch burst on the hub and the victory cheer, hero facing right | 01-burst-cheer.png |
| 02 | fight hub | during the hop | hero running right into the burrow mouth, not mirrored | 02-hop-burrow.png |
| 03 | fight hub | during the wipe | soil curtain moving left to right over the burrow | 03-soil-wipe.png |
| 04 | fight hub | just before the rope | arrive hop facing right, then the rope exit is the next screen | 04-arrive.png |

## Pass criteria

- All four PNGs under `playtest/repot/outbox/REQ-20261028-clear-torch-parade/shots/` at 1680×1040.
- `01` shows the hub burst and the cheer facing right.
- `02` shows the rightward hop into the burrow.
- `03` shows the soil wipe traveling left to right.
- `04` shows the arrive hop facing right. The rope exit is not open in `01`–`03`.
- No wax seal in any shot.

## Outbox path

`playtest/repot/outbox/REQ-20261028-clear-torch-parade/`
