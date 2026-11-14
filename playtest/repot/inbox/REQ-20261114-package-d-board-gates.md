---
id: REQ-20261114-package-d-board-gates
status: done
priority: high
tip_sha: 027132f2
branch: cursor/trophy-board-package-d-9a30
created: 2026-11-14T02:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → cabin trophy hall (right from fireplace)
---

# Package D — lever gate, portal sequence, map fog/known/startable

Cloud ship of campaign gates + BoardSequences. Uses final trophy art from tip (lever, padlock, map fog/glow, portal/shortcut splashes at ASSETS.md paths). Cannot F5 here — local Cherry shots needed.

## What to verify

- Five lights on a Verdant face → lever READY (glow), not spent.
- Pull lever → rumble → portal splash (crystal) → map fog clears on Crystal → Known stamp (no Start here) → bucket reveal.
- Push deeper at 5 lights before pull uses lever Nib line; after pull Push works.
- 100% Verdant → shortcut splash + dashed path + Start here on Crystal.
- Fresh map: Verdant startable; later biomes fogged; no cabinet / progress-menu chrome.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | Middle Progress, open trophy board on Verdant with ≥5 unique banked, lever unpulled | five lights lit; lever READY art (`lever_ready` + glow); padlock absent | 01-lever-ready.png |
| 02 | hall | pull the READY lever; wait through rumble into splash | portal splash art for Crystal (`trophy_board/splash/portal_crystal.png`); Nib portal lines | 02-portal-splash.png |
| 03 | map | after portal map beat | Crystal node Known (flat wax, no LaunchHit); fog still on Ashen+; Verdant still startable | 03-map-known-crystal.png |
| 04 | extract | in Verdant run with 5 lights banked, portal not yet opened; open extract | Push blocked; Nib lever line (`nib.push_block.lever`) | 04-push-block-lever.png |
| 05 | map | Verdant board 100% after shortcut ceremony | dashed path from Start banner to Crystal; Start here badge on Crystal; Crystal launchable | 05-shortcut-crystal.png |

## Pass criteria

- All rows 1680×1040.
- Lever / padlock / fog / splash / glow textures are the final tip art (not magenta placeholders).
- No Outpost door, cabinet cases, or progress-menu UI in frame.

## Outbox path

`playtest/repot/outbox/REQ-20261114-package-d-board-gates/`
