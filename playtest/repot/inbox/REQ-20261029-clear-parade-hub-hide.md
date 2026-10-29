---
id: REQ-20261029-clear-parade-hub-hide
status: open
priority: high
pr: 177
tip_sha: caeefa50
branch: playtest/latest
base: playtest/latest
created: 2026-10-29T03:55:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → clear the wheel so the parade plays. Optional: set clear_parade.freeze_at to 0.30 / 1.30 / 1.85 / 2.45 for shots 01–04; shot 05 is ~0.5 s after the parade returns (freeze_at unused).
---

# Clear parade hub hide + land dust

During the dungeon-clear torch parade, only the overlay parade Sprout should show. The hub Sprout (heart-pip hero from `_draw_hub_block`) and hub gear stay hidden for the whole parade, then restore. Land dust is readable under the arrive feet. No wax seal. Rope opens only after the parade, same as before.

`freeze_at` values for deterministic shots: **0.30**, **1.30**, **1.85**, **2.45** (01–04). Leave `freeze_at = -1` for normal play and for shot 05.

## What to verify

- From burst through arrive, no hub Sprout or hub gear is drawn under the overlay parade Sprout.
- Heart pips may remain (HP HUD). The hub hole is empty of the Sprout body in 02–04.
- Mound is hidden during burst/cheer; first visible at hop.
- Land dust under the arrive hero is readable on 04.
- After the parade, hub Sprout is restored and the rope exit is open (05).
- No wax seal. Nothing mirrored. Rope not open in 01–04.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | burst/cheer (t≈0.30) | gold/torch burst on the hub, ONE right-facing run_victory Sprout, no hub Sprout drawn under it, no mound yet, no rope, no wax seal | 01-burst-cheer.png |
| 02 | fight hub | hop (t≈1.30) | overlay Sprout hopping RIGHT (unmirrored) into the burrow mouth, hub hole EMPTY (hearts may remain), no rope | 02-hop-burrow.png |
| 03 | fight hub | wipe (t≈1.85) | soil curtain moving left→right over the burrow, hub hole empty, no rope | 03-soil-wipe.png |
| 04 | fight hub | arrive (t≈2.45) | arrive hop facing RIGHT on the rim with a readable land-dust puff under the feet, hub hole EMPTY, rope not open yet | 04-arrive.png |
| 05 | fight hub / rest | ~0.5 s after the parade | hub Sprout restored and rope exit open (confirms restore and unchanged rope timing) | 05-after-restore.png |

## Pass criteria

- All PNGs at 1680×1040 under `playtest/repot/outbox/REQ-20261029-clear-parade-hub-hide/shots/`.
- 01–04 show no hub Sprout under the overlay; 04 shows readable dust; 05 shows hub Sprout back.
- No wax seal in any shot. Rope not open in 01–04.

## Outbox path

`playtest/repot/outbox/REQ-20261029-clear-parade-hub-hide/`
