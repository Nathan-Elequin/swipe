---
id: REQ-20261117-title-picker-vignettes
status: open
priority: normal
tip_sha: 9154292096521a174fe8d459dbfb61c827aa1887
branch: cursor/title-picker-card-art-7b32
created: 2026-11-17T07:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: fresh save → intro → title → New Game → picker
---

# Title picker card vignettes

Adds the three batch2 card vignettes (Quick/Verdant, Deeper/Crystal, Big/Abyss) on the New Game picker cards. Splash stays as a dim deep background; vignette is 400×224 at card-local (20, 12). Cloud agent cannot F5; Cherry fulfills with godot-mcp.

## Rules (verbatim)

- **Drive the game only with godot-mcp injected input** (mouse move/click/keys through the MCP). **Never OS-level / computer-use control of Nathan's screen.**
- **Fresh save.** Real player path only: **no `_dev_*`, no `preview_*` hooks, no Grant, no DevChrome hotkeys, no forced poses or forced milestones.**

## What to verify

- Each picker card shows its vignette in the upper art well (above the fade / labels).
- Mapping: Quick → verdant vignette, Deeper → crystal, Big → abyss.
- Presenter, goal ring, title/biome/line labels, and Pick button are still readable; vignette does not cover labels.
- No "Tier" / "ATK" on screen.

## Screenshots required

| id | room | setup | expect | filename |
|---|---|---|---|---|
| 01 | picker | New Game, default focus Card_0 | three cards; each has a distinct vignette above the labels; Quick focused | 01-picker-vignettes.png |
| 02 | picker | hover / focus Card_1 (Deeper) | Deeper card rises 8 px with gold border; crystal vignette visible | 02-picker-deeper-hover.png |

## Pass criteria

- Every `expect` is readable from the PNG.
- No "Tier"/"ATK" text anywhere.
- No console errors.
- All rows shot at 1680×1040.

## Outbox path

`playtest/repot/outbox/REQ-20261117-title-picker-vignettes/`
