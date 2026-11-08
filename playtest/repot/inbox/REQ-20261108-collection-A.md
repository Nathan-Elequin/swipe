---
id: REQ-20261108-collection-A
status: open
priority: high
tip_sha: a89a8693b9995fe0172875a27771edf3d276775b
branch: cursor/collection-a-state-9a87
created: 2026-11-08T04:30:00-06:00
created_by: collection-a-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress or Continue → finish a short Verdant Leave (or Progress Menu fixture if available)
---

# Collection Journey A — state projection + seen catalogue

Shared `CollectionJourney` projection + progress-menu **seen-not-banked** cells (PR1 of A MVP). No B ledger. Do not claim F5-ready for tip until Cherry sync.

## What to verify

- Progress Collection tab: an identity in cabin `seen` but not `swiped`/`banked` shows **recognized / not banked** state (placeholder Spin copy OK), distinct from gray **Not yet collected**.
- Newly banked this return still shows **New!** stagger then Collected.
- Banked items show Collected; missing never-seen stay missing.
- No persistent side ledger; cabin Visit still optional.
- Headless: `./tools/qa/run_collection_journey.sh` prints `COLLECTION_JOURNEY_OK`.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | progress Collection | Fixture or save with at least one seen-unbanked + one banked in b1 | Seen cell badge ≠ missing; banked = Collected | 01-catalogue-seen-vs-banked.png |
| 02 | progress Overview | Same return with ≥1 new banked | Summary + New! path truthful | 02-return-receipt-overview.png |
| 03 | progress Collection | Locked later area tab | Locked badge; no spoiler item names if already the rule | 03-area-locked.png |
| 04 | dungeon ready | Campaign run with 1+ unbanked held | Quiet strip shows banked X/5 + held new count; New! only on unbanked | 04-inrun-quiet-strip.png |
| 05 | progress Overview | Return that crosses 4→5 banked | Milestone gate line visible; Skip still durable | 05-milestone-gate.png |
| 06 | cabin hall | Progress → Visit Cabin after hall unlocked | Lands hall (not forced fireplace); focuses played biome case; no S7 bank replay | 06-cabin-optional-focus.png |

## Pass criteria

- All rows 1680×1040 (or note viewport).
- Pattern + text distinguish seen vs missing (not color alone).
- `RESULT.md` pass/fail per id.
- Do **not** mark this request done from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261108-collection-A/`

## Pasteable local drain prompt

```
Drain playtest/repot/inbox/REQ-20261108-collection-A.md on branch cursor/collection-a-state-9a87 (or playtest/latest after merge). Checkout tip, run ./tools/qa/run_collection_journey.sh, F5 Middle Progress / Continue, shoot the three catalogue/receipt rows into playtest/repot/outbox/REQ-20261108-collection-A/shots/, write RESULT.md, set inbox status done, commit+push [repot] fulfill REQ-20261108-collection-A.
```
