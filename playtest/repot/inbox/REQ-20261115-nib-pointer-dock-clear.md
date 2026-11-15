---
id: REQ-20261115-nib-pointer-dock-clear
status: open
priority: high
branch: cursor/nib-pointer-dock-clear-0667
created: 2026-11-15T00:55:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: cabin trophy hall via F5 playtest hub → Continue / Middle Progress with first-return / map pointer beats available
---

# Nib pointer dock + clear, trophy amb off, cog seat, padlock order

Cloud ship for Nathan's playtest pointer bugs (lever covered by dialogue, pointer lingering into keys and other rooms), plus trophy-room amb bed removal, rail cog pivot/seat, and locked-face padlock draw order. Headless `nib_pointer_selftest` is green; local F5 screenshots still needed.

## What to verify

- On `nib.board.first_light.2`, dialogue docks at the top and the pulse ring sits on the real floor lever (not inside the talk bar).
- After the hover-hint pointer line advances, arrow + ring are gone before the keys / "Found them! Behind the biscuits" beat.
- After the map-click pointer line, changing room (e.g. to trophy hall) leaves no leftover arrow/ring.
- Trophy hall has no rumbling amb bed over fire + music; one-shot `board.rumble` on the lever sequence still plays.
- Board side cogs spin in place on their painted sockets (no wide arc).
- Locked face (e.g. Ashen Crypt) shows the padlock on top of silhouettes.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | first-light beat on Verdant; line about the lever | talk bar docked top; ring on lever; lever visible | 01-lever-dock-top.png |
| 02 | hall → keys | advance past hover-hint into keys / biscuits line | no arrow or pulse ring on screen | 02-keys-no-pointer.png |
| 03 | main → hall | map-point line, then walk/pan to trophy hall | no leftover pointer over board slots | 03-room-change-clear.png |
| 04 | hall | locked face (Ashen or any locked) | padlock above silhouettes | 04-padlock-top.png |
| 05 | hall | slide board left/right | cogs rotate in sockets, no swing out | 05-cogs-seated.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261115-nib-pointer-dock-clear/`
