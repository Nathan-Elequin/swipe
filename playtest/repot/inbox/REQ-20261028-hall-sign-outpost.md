---
id: REQ-20261028-hall-sign-outpost
status: done
priority: medium
pr: 172
tip_sha: dc86ed13
branch: cursor/hall-sign-outpost-3173
base: playtest/latest
created: 2026-10-28T20:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue or Middle Progress → cabin main → right SideDoor into trophy hall
depends_on_copy: cabin.hall.sign_outpost (Spin PR #171 @ 1cff4fb7)
---

# Hall Outpost door plaque (backpack sign)

Replace the hidden study-book plaque above the hall right door with the Outpost backpack plaque, unhide it, and wire hover to Spin’s locked key `cabin.hall.sign_outpost` → “To the Outpost”.

## What shipped (code/art)

1. **Art**: `assets/dungeon/home/doors/door_sign_outpost.png` (72×56 RGBA) + `.import` (mipmaps off, Nearest via project default).
2. **Layout**: `rooms.hall` node `SignOutpost` (was `SignStudy`), file `doors/door_sign_outpost.png`, origin `[385,110]`, size `[18,14]`, hotspot `[383,108,22,18]`.
3. **Tags**: `cabin_room.gd` `_tag_for` → `"SignOutpost": "cabin.hall.sign_outpost"`.
4. **Unhide**: `room_hall.gd` `_hide_retired_chrome` no longer hides the right-door sign (still hides ShelfPrev / ShelfNext / Gauge).

Do **not** edit `data/player-copy.json` — Spin owns the string.

## Screenshots required

| id | expect | filename |
|----|--------|----------|
| 01 | hall right door shows backpack Outpost plaque (not study book; not hidden) | 01-hall-sign-outpost.png |
| 02 | hover plaque → tip “To the Outpost” (or key resolves once Spin copy lands) | 02-hall-sign-hover.png |

## Pass criteria

- Both PNGs under `playtest/repot/outbox/REQ-20261028-hall-sign-outpost/shots/` at 1680×1040 (godot-mcp preferred).
- `01` shows the wood plaque with backpack icon above the right (Outpost) door.
- `02` hover tip reads **To the Outpost** (key `cabin.hall.sign_outpost`).
- Tip SHA in RESULT.md is this PR’s tip (or `playtest/latest` after merge) at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261028-hall-sign-outpost/`
