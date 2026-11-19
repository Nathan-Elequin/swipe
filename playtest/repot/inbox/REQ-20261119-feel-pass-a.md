---
id: REQ-20261119-feel-pass-a
status: open
priority: normal
branch: cursor/feel-pass-a-timing-9612
created: 2026-11-19T05:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → start a short Challenge or Adventure fight
---

# Feel pass A — spin kick, FX seat, stat count-up

Cloud ship of Feel pass A (timing / FX / spin / banners / stat count). No Godot MCP on this agent — local Cursor must shoot.

## What to verify

- Spin kicks immediately on click and eases out into the land (~1.2s).
- Seat rings at dungeon setup are quieter/smaller than the spin-land burst.
- Item strikes apply on the impact frame (numbers move while the strike anim finishes).
- Stat changes count up/down on the badge (no per-point heart/sword flights); finish within ~0.5s.
- FX (pointer land, land burst, take overlay) sit on their targets, not offset by the wheel.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Spin onto any living monster | wheel decelerates into the seat; land burst on the portrait; intent plate already present (no one-frame late pop) | 01-spin-land.png |
| 02 | combat | Use a strike item (Boot / Sledge / Knife) | impact FX on the callout; HP badge counts rather than flying hearts | 02-strike-count.png |
| 03 | dungeon setup | Watch seats fill (Challenge seat-in or Adventure open) | quiet seat rings (~smaller/dimmer), not the full spin land burst | 03-seat-rings.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable without guessing.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261119-feel-pass-a/`
