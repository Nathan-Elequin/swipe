---
id: REQ-20261030-trophy-hall-zoom-fix
status: open
priority: high
branch: playtest/latest
created: 2026-10-30T18:15:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → cabin main → hall (right path); DEV fill_b1 / grant / bank as listed
supersedes: REQ-20261029-trophy-pegs-fit
parent: REQ-20261030-trophy-hall-dumbwaiter
---

# Trophy Hall zoom fix + bank-flip retake + pegs-fit fold-in

Cloud fix for the black-frame hall zoom (`_open_hall_zoom` was clamping RoomHall toward absolute 0 while the hall sits at layout x=6720). Also hardens bank-flip pool targeting so a Crystal page-2 item (`spiked_flail`) flips Crystal, not Verdant. Fold in the still-open pegs-fit asks from REQ-20261029-trophy-pegs-fit.

Local Cursor on Cherry: F5 playtest, godot-mcp screenshots at 1680×1040. Do **not** freeze `Engine.time_scale` to catch mid-tween frames — await a timer / process frames partway through the live tween. After fill / grant / bank helpers, await at least one frame so shelves refresh before shooting.

## What to verify

- Clicking a trophy case zooms ~2× on that case in place; hall wallpaper / neighbors still readable; ZoomDim ~25%.
- Claimed / seen-hatched / unseen-silhouette pegs show the right lore panel (no "Tier").
- Page chevrons / ticks / arrow keys flip pages while zoomed.
- Esc / outside click zoom-out restores the exact pre-zoom hall overview.
- Banking `spiked_flail` (Crystal Cavern page 2) flips Crystal to page 2 before the arc — not Verdant.
- Lever tour mid-ride and 5th-unique unlock arc mid-flight are readable mid-tween.
- All-five-pools-full Middle Progress: every peg shield sits inside glass above the case base; pegs stay Nearest.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall zoom | Brand New → fill_b1 → click Verdant → hover a claimed peg (e.g. Net) | ~2× zoom on Verdant; hall still visible; dim ~25%; amber peg frame; lore panel (brass corners, journal, Claimed chip); no "Tier" | 01-zoom-claimed.png |
| 02 | hall zoom | Same zoom; hover a seen-only peg (hatched, not banked) | Grey hatch; dashed placard + name; no journal body | 02-zoom-seen-hatched.png |
| 03 | hall zoom | Same zoom; hover an unseen silhouette peg | Black silhouette; blank placard; locked tip only | 03-zoom-unseen-silhouette.png |
| 04 | hall zoom | Zoom a 2-page case; click right chevron (or ui_right) | Page 2 slid in at 2×; chevrons/ticks clickable; hall still framed | 04-zoom-page-chevron.png |
| 05 | hall | Esc / click outside to zoom out | Overview matches the pre-zoom hall (same fill state as before 01) | 05-zoom-out-matches.png |
| 06 | hall | Real extract / DEV bank of `spiked_flail` (Crystal page 2); shoot after flip, mid-arc | Crystal Cavern shows page 2 before/as the arc flies; not Verdant page 2 | 06-bank-flip-crystal-p2.png |
| 07 | hall | After stop 2 lit; click lever; await ~halfway through the ride tween (no time_scale freeze) | Lever pulled; car between stops; ropes correct | 07-lever-tour-mid.png |
| 08 | hall | Real extract bringing the 5th Crystal unique; await mid-flight of `_bank_fx_arc_to_mount` (no time_scale freeze) | Item sprite mid-arc toward its fixed Crystal peg | 08-unlock-arc-mid.png |
| 09 | hall | Middle Progress with all five pools full (or DEV grant-all biomes) | All five cases full; every peg shield inside glass above case bases — no hang onto base/floor | 09-all-five-pegs-inside.png |
| 10 | hall | Crop / close of one filled peg column from 09 (Nearest check) | Peg shields crisp Nearest at integer seats; still above the case base | 10-peg-nearest-crop.png |

## Capture notes for the drainer

- Mid-tween shots (07, 08): start the tween, `await` a short timer or several process frames (~40–50% of duration), then screenshot. Do not set `Engine.time_scale` to 0 / freeze.
- After `fill_b1`, grant-all, or bank helpers: await a frame (or until `_rebuild_shelves` finishes) before shooting so progress bars / pegs are current.
- 01–05 need a working `_open_hall_zoom` (hall must stay on-screen at 2×). If the frame is black, fail the row — do not crop as a substitute.

## Pass criteria

- All PNGs under `playtest/repot/outbox/REQ-20261030-trophy-hall-zoom-fix/shots/` at 1680×1040 (10 may be a crop).
- Headless `scripts/dev/biome_cabinets_selftest.gd` prints `BIOME_CABINETS_OK` (includes zoom-in-viewport + spiked_flail→b2 page asserts).
- No player-facing "Tier" on hall plaques / lore.
- RESULT.md records tip SHA and pass/fail per id.

## Outbox path

`playtest/repot/outbox/REQ-20261030-trophy-hall-zoom-fix/`
