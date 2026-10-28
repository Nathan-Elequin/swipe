---
id: REQ-20261028-hall-chrome-strip
status: open
priority: high
pr:
tip_sha:
branch: playtest/latest
created: 2026-10-28T20:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue or Middle Progress → cabin main → right SideDoor into trophy hall
parent: REQ-20261028-cabin-flip-167
---

# Hall trophy-case runtime chrome strip + EMPTY plate

Parent REQ-20261028-cabin-flip-167 failed shots 06/07. This ship:

1. **Code** (`scripts/home_cabin.gd`): no FitLabelBox item-name plaques, no yellow GateLine, hover ≠ inspect (mount highlight only; left-click → `inspect_wanted`).
2. **Art**: replace `assets/dungeon/home/rooms/cabinets_wall.png` with Doop `sSXqYUHvO2` EMPTY scrub (1680×1040 RGB) — five open empty cases, no baked titles / POOL LOCKED / fake icons / gate bars / X locks. Source also under `design/handoff/outpost-regen/doop-ship/SHIP-D-cabinets-wall-EMPTY.png`.

Still: no `case_*.png` reintroduction. Hit-only Case_* glass, scroll, slot icons, bank FX stay.

## What to verify

- Hall idle: FULL plate-clean — no baked biome titles / `?` / POOL LOCKED / X locks; **and** no runtime FitLabelBox plaques or yellow GateLine.
- Hover a shelved mount: mount texture highlight only; inspect panel stays closed.
- Left-click that mount: inspect opens.
- Right-click still opens playtest comment when playtest flag is on.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | Full hall idle, no hover/click | FULL plate-clean (no baked titles / POOL LOCKED / X); **no** FitLabelBox item-name plaques; **no** yellow GateLine; **no** inspect panel. Slot icons OK. | 01-hall-no-runtime-chrome.png |
| 02 | hall | Hover a shelved mount (e.g. Counting Beads in Verdant Hollow) | Mount highlight only; inspect closed — must **not** show Counting Beads (or any) inspect card | 02-hall-hover-no-inspect.png |
| 03 | hall | Left-click the same mount | Inspect opens for that card | 03-hall-click-inspect.png |

## Pass criteria

- All three PNGs under `playtest/repot/outbox/REQ-20261028-hall-chrome-strip/shots/` at 1680×1040 (godot-mcp preferred).
- `01` shows empty-glass Doop plate (no baked chrome) and no runtime name plaques / GateLine.
- `02` must not show an inspect card.
- `03` must show inspect open after left-click.
- Tip SHA in RESULT.md is this PR’s tip (or `playtest/latest` after merge) at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261028-hall-chrome-strip/`
