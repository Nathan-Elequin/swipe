---
id: REQ-20261106-batch2-art
status: open
priority: normal
branch: cursor/batch2-tip-catalog-ab5f
created: 2026-11-06T00:00:00-06:00
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Roster / dungeon so Shardplate, Love Potion, Tesla Coil, Swift Sneaks, Anvil appear (dev deck or seeded pool)
---

# Batch-2 art + catalog (shardplate, love_potion, tesla_coil, swift_sneaks, anvil)

Pixel-locked item stills; Anvil facing lock B duplicated to idle f0–f3; Anvil still reused. Catalog rows + ITEM_PNG wired. Combat ops stubbed (`flags.dev`) except jar→sneaks rename keeps live `move2_keep`. Anvil Steady Steel min-3 floor disabled so Headstrong stub does not leave the old tax live.

## What to verify

- Roster / inspect shows Shardplate, Love Potion, Tesla Coil, Swift Sneaks with locked art (Nearest, no blur).
- Swift Sneaks is shoes (not grease jar); id is `swift_sneaks` everywhere.
- Anvil still is the live anvil plate; fight facing uses 48×48 facing lock (same plate on idle f0–f3).
- Anvil inspect: 3 HP / 3 ATK, Call name Headstrong, ability Always +4/+4 while Facing.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | roster | Find Shardplate + Love Potion + Tesla Coil | Unique item art, readable names | 01-items-roster.png |
| 02 | roster | Find Swift Sneaks | Shoe art; Move 2 + Keep ability | 02-swift-sneaks-roster.png |
| 03 | roster | Find Anvil | 3/3, Headstrong | 03-anvil-roster.png |
| 04 | fight | Face Anvil | Facing idle uses locked 48×48 plate | 04-anvil-facing.png |

## Pass criteria

- All PNGs present; every `expect` readable.
- Wrong art, blurry filter, grease-jar art on Swift Sneaks, or Anvil still 9/4 Steady Steel = fail.

## Outbox path

`playtest/repot/outbox/REQ-20261106-batch2-art/`
