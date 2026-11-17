---
id: REQ-20261117-juggernaut-A
status: open
priority: high
pr: TBD
tip_sha: c78a64fe
branch: cursor/juggernaut-a-art-9a98
created: 2026-11-17T05:35:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: Fresh save → real player path into a run that seats Juggernaut → Spin to face him (godot-mcp injection only)
---

# Juggernaut A art swap (Shield Linebacker)

Nathan locked Juggernaut monster art A (Shield Linebacker) on Nov 16. Cloud replaced the 17 tip PNG paths under `assets/dungeon/` (extra, facing idle f0–f3, slash base+f0–f3, wheel base/idle/breathe). Same paths and sizes as tip / B. Art only — no stats, abilities, or copy changes. Existing `.import` kept. Cloud headless blit proof: `design/audit-shots/cursor/juggernaut-a/composite.png`. Cherry must capture **actual Godot MCP / F5 runtime** shots.

## Input rule (hard)

**Input = godot-mcp injection only** (injected mouse and key events or `Viewport.push_input`). Never use computer-use or OS-level control of Nathan's screen, mouse, or keyboard.

- No `_dev_*`, `preview_*`, Grant, DevChrome shortcuts, seeded saves, or forced poses.
- Start from a **fresh save**, then walk the **real player path** until Juggernaut is seated and you Spin to face him.
- If Juggernaut does not come up naturally, re-roll runs through the real flow and log how many attempts it took.

## What to log

- Tip SHA of this checkout
- Textures loaded for Juggernaut (wheel / facing / slash / extra paths)
- Music
- `SceneTree.paused`
- Dialogue keys in play

## Screenshots required

| id | setup | expect | filename |
|----|-------|--------|----------|
| 01 | Juggernaut seated on the wheel, idle, not spinning | Blond human, teal tunic, blue heater, feet on the seat, breathe animates | 01-juggernaut-wheel-idle.png |
| 02 | Hover or face him so the right-side callout shows | Same character, not cropped, plays the same idle as the wheel with no size pumping (#545) | 02-juggernaut-callout.png |
| 03 | His ability fires | Slash cut-in is the full-body shield bash, not chopped at the bottom | 03-juggernaut-slash.png |
| 04 | Any screen showing `extra/juggernaut.png` (bestiary or inspect) | Tall still matches A | 04-juggernaut-extra.png |

## Pass criteria

- All four rows shot at 1680×1040 (or note viewport).
- Reads as a human (blond, teal tunic, blue heater).
- Nothing is cut off at a frame edge.
- No B art (the previous Juggernaut sprite from #508/#510) anywhere.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261117-juggernaut-A/`
