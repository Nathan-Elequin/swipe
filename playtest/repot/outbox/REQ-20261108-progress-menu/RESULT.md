# REQ-20261108 progress menu — shot labels

**Head at capture:** see branch tip after push.

## Labels (do not confuse)

| Prefix | Meaning |
|--------|---------|
| `FIXTURE-*` | Synthetic/example roster (small set). **Not** catalog acceptance. |
| `CATALOG-*` | Full catalog-driven acceptance stills (real `data/catalog.json` + `dungeon_art` Nearest icons). |

## Acceptance shots (CATALOG)

- `shots/CATALOG-01-collection-b1.png` — Collection tab, Verdant Hollow full roster + icons, area `collection: count/total`
- `shots/CATALOG-02-next-goal.png` — Next Goal with requirement + primary Start New Run (no redundant New Run)
- `shots/CATALOG-03-overview.png` — Overview with locked-area requirement lines
- `shots/CATALOG-04-death.png` — Death return still walks Collection
- `shots/CATALOG-05-tutorial.png` — Completed-tutorial summary only

## Fixture shots (example only)

- `shots/FIXTURE-01-win-collection.png`
- `shots/FIXTURE-02-next-goal.png`

## Flags for Spin

- Missing `postrun.collection.item_collected` (collected non-new detail left blank)
- Missing dedicated tutorial-Skip/decline summary (uses `success_none` + warning)
