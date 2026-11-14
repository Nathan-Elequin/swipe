---
id: REQ-20261114-ladder-wipe
status: open
priority: high
branch: cursor/ladder-wipe-homecoming-c308
tip_sha: b57f090e
created: 2026-11-14T05:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Continue (or Middle) → clear a dungeon → Rope Exit → click the rope ladder (Climb)
---

# Ladder climb → cabin exterior wipe (no flashes)

Nathan playtest: right after clicking the ladder, the upward wipe should go straight to the **empty** cabin exterior, then current Sprout walks in from the left. Three bugs were flashing during the transition; also cabin music must play through the return, and a first-return unique must not hear “Nothing new.”

## What to verify

1. **No Developer Test flash** — during the wipe and first exterior frames, the Developer Test / Play Latest / Roster strip must never appear.
2. **No horizontal wipe-in** — cabin exterior must not slide in from the right; it appears only through the upward wipe at x = 0.
3. **No old Sprout in the void** — before walk-in starts, Sprout is off-camera / hidden. Walk-in uses current `sprout_run` frames (not the old 128² `hero_walk_*` sheets).
4. **Music** — from climb through exterior, key-ring unlock, and first trophy unpack, the bed is cabin music (`music_cabin` / station bed). Not between_dungeons / old cave ambience.
5. **First return with 1 unique** — Nib takes the first-return unpack branch (not “Nothing new this time…”). Board still shows gold / sparkle / light for that unique.

## Screenshots required

Capture a **rapid strip** (≈8 frames across the wipe → empty exterior → Sprout entering), 1680×1040 each. Prefer godot-mcp burst or phone screen record frames.

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit → wipe | mid upward wipe | solid dark cover; no Developer Test; no dungeon HUD | 01-wipe-cover.png |
| 02 | exterior | first reveal frame | empty cabin exterior at rest (x=0); no Sprout yet; no horizontal slide | 02-empty-exterior.png |
| 03 | exterior | walk-in mid | current Sprout (sprout_run) entering from the left | 03-sprout-walk.png |
| 04 | hall / board | first return with ≥1 unique | unpack / first-look lines — not “Nothing new”; unique on board | 04-first-unpack.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Headless strip also at `design/audit-shots/cursor/ladder_wipe_strip.png` from `ladder_wipe_homecoming_selftest.gd`.

## Outbox path

`playtest/repot/outbox/REQ-20261114-ladder-wipe/`
