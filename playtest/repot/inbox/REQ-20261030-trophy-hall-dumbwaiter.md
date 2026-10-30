---
id: REQ-20261030-trophy-hall-dumbwaiter
status: open
priority: high
pr: 208
tip_sha: c6c4fd3fe025
branch: cursor/trophy-hall-dumbwaiter-b735
created: 2026-10-30T00:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → fresh save → cabin main → hall (right path); DEV fill_b1 / grant-all as listed
---

# Trophy Hall: cases, fixed pegs, dumbwaiter, zoom, unlock beat

Spec: design/trophy-hall/SCREEN-trophy-hall.md + ASSET-LIST.md. Strata column is cut and must not appear.

## Screenshots required
| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | fresh save | Verdant in progress; b2–b5 sheeted (hem+crest+padlock, b2 spires bumps); dumbwaiter left wall, stop 1 lit, 2–5 dark+padlock, car at 1; plaques 1st..5th; no strata, no olive case | 01-hall-fresh.png |
| 02 | hall | DEV fill_b1 | Verdant opened (door open, lamp lit, colour crest, 5 gold pips, n/12, PageBar 2 ticks); Crystal Cavern glacial, in progress; stops 1–2 lit, car at 2 | 02-hall-b1-opened.png |
| 03 | hall | click stop 2 | stepped ride; Crystal Cavern lamp flare + pulse; tray silhouette | 03-stop-click.png |
| 04 | hall | click lever, mid-tour | lever pulled frame; car between stops; ropes correct | 04-lever-tour.png |
| 05 | hall→map | after 03 press Space | Crystal Cavern stamp pulses | 05-map-node-pulse.png |
| 06 | hall zoom | click Verdant, hover claimed peg | 2x zoom, dim ~25%, amber frame, lore panel (brass corners, tail, journal, chip, no "Tier") | 06-zoom-claimed.png |
| 07a | hall zoom | hover seen peg | grey hatch, dashed placard + name, no journal | 07a-zoom-seen.png |
| 07b | hall zoom | hover unseen peg | black silhouette, blank placard, locked tip only | 07b-zoom-unseen.png |
| 08 | hall | Esc | overview identical to 02 | 08-zoom-out.png |
| 09a | hall | real extract bringing 5th Crystal Cavern unique | item mid-arc to its fixed peg | 09a-unlock-arc.png |
| 09b | hall | same, ~0.3 s later | door mid-swing, lamp on, crest grey | 09b-unlock-glass.png |
| 09c | hall | same, ~0.8 s later | crest colour; Ashen sheet sliding, padlock dropping; stop 3 lamp lit | 09c-unlock-sheet.png |
| 10 | hall | DEV grant all Verdant items | Complete: gilded crown + trim, placards gold on both pages, both ticks gold, twinkle | 10-complete.png |
| 11a | hall | wheel over a 2-page case | page 2 slid in (stepped), tick 2 amber, empty recesses on the last page | 11a-page-wheel.png |
| 11b | hall zoom | zoom a 2-page case, click the right chevron | chevrons/ticks clickable at 2x; arrow keys flip | 11b-page-zoom.png |
| 12 | hall | real extract whose item is on page 2 | case flips to page 2 before the arc lands | 12-bank-flip.png |

## Pass criteria
- All PNGs under playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/shots/ at 1680x1040.
- biome_cabinets_selftest green; no "Tier"/"Sunken Mire" on screen; pegs do not move between 01, 02 and 10.
- RESULT.md records tip SHA and the per-pool item/page counts from the build report.
- No pool is trimmed: every live item is reachable on some page.

## Outbox path
playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/
