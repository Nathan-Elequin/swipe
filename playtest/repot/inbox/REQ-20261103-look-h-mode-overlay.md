---
id: REQ-20261103-look-h-mode-overlay
status: done
priority: high
branch: cursor/look-h-mode-overlay-c13e
base: playtest/latest
created: 2026-11-03T07:45:00Z
tip_sha: df67162d
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → fight with Throwing Knife, Net, Danger Magnet, Sling, Crossbow, and Hired Hand when available
---

# Look H — cream mode overlay panel (combat selector)

Visual/UI only. Replaces Look C in-chrome tags with a cream overlay panel above the starter hotbar seat (Doop https://doop.design/c/8a-B18k4cY H1 `Kb2qpofDn2` / H2 `0KhSoe1IXV` LOCKED). Soft scrim, CHOICE aura + cancel X on starter, Knife 2-up / Net×3 rows / Magnet rows. No ItemCard clones over seats. Cancel via X / Esc / scrim.

## What to verify

- Throwing Knife second click: cream panel above Knife with two large targets (`ATK 3, discard` + red throw badge; `ATK 1, keep` + green return badge); caret at starter; scrim; CHOICE aura + top-right X; other seats dimmed; no in-chrome tags; no clone tiles.
- Net second click: three stacked rows (`-1` / `-2` / `-3 Attack`) with net icon + strength pips; same overlay rules.
- Magnet (same choose path): three rows with existing Highest / Lowest / Off strings; magnet icon; no invented prompt copy.
- Cancel: starter X, Esc, and click scrim each dismiss the panel and exit mode choose.
- Keys 1/2 (Knife) and 1/2/3 (Net/Magnet) pick the matching target.
- Sling / overfill toss: CHOICE on legal cards + cancel X; no mode panel.
- Hired Hand: Take arc Decline; no mode panel / Feedback pills.
- Crossbow wheel aim: wheel glow + dim hand + cancel; no mode panel.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Use Throwing Knife → mode open | Cream panel 2-up above Knife; badges; scrim; CHOICE+X; no tags/clones | 01-knife-look-h.png |
| 02 | fight | Use Net → mode open | Cream panel 3 rows; pips; scrim; CHOICE+X; no tags/clones | 02-net-look-h.png |
| 03 | fight | Use Danger Magnet → mode open | Three rows with existing magnet labels; overlay not tags | 03-magnet-look-h.png |
| 04 | fight | Use Sling → pick open | CHOICE on legal cards; cancel on Sling; no mode panel | 04-sling-hand-pick.png |
| 05 | fight | Hired Hand offer | Take arc = Decline; no mode panel | 05-hired-hand-decline.png |
| 06 | fight | Use Crossbow → aim | Wheel glow; hand dim; cancel on Crossbow; no mode panel | 06-crossbow-wheel.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- No ItemCard clones floating above the hotbar for Knife/Net/Magnet.
- No Look C cream tags inside the starter chrome for those modes.
- Cancel / dim / CHOICE / Decline / wheel aim still match locked mocks.

## Outbox path

`playtest/repot/outbox/REQ-20261103-look-h-mode-overlay/`
