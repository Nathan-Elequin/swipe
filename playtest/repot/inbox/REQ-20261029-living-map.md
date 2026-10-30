---
id: REQ-20261029-living-map
status: done
priority: high
branch: playtest/latest
created: 2026-10-29T12:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / DEV Fill Verdant Hollow cabinet → cabin map
---

# REQ-20261029-living-map

**Screen:** Living map (seeded Deadly sprites on the held map)  
**Spec:** `design/living-map/SCREEN-living-map.md` · `design/living-map/ASSET-LIST.md`  
**Doop:** canvas `K5t2l_veMo` — idle `DoUVLCGSwy`, hover `9TaaNmV0Kc`, plate `w8wF4MIkv8`  
**Viewport:** 1680×1040 · Nearest · no new player-facing strings · never show "Tier"

## Outbox
`playtest/repot/outbox/REQ-20261029-living-map/shots/`

## Shots

| id | setup | expect | file |
|---|---|---|---|
| 01 | Fresh save → DEV "Fill the Verdant Hollow cabinet" → return to cabin → open map from cabin hotspot | Held map shows **no Gulpwyrm/Bogmother ink**. Verdant has 1 full-color Deadly sprite near the node, Sunken Mire has 2. Unmapped biomes have no sprites. | 01-open-map-cabin.png |
| 02 | Same, wait 3 s and take a second shot | Sprites are in different lane positions from 01 (patrol), with feet on the parchment, crisp Nearest pixels and no blur | 02-idle-patrol.png |
| 03 | Hover a Sunken Mire monster | Sprite lifted 14px at 64px. The tag shows the catalog name + gold DEADLY chip (parchment plank, hard shadow). The other monster keeps walking. | 03-hover-name.png |
| 04 | DEV "Fill every cabinet" → cabin → map | Every biome open. b2–b4 show 2 monsters each and b5 shows 3, each on its own lane with none overlapping. No Deadly repeats across the map. | 04-multi-monster.png |
| 05 | Start a Verdant run → in the dungeon press **M**, then M again | Same map, read-only: monsters live, stamp hover does nothing, M closes **back to the same fight with the run intact** (HP/wheel unchanged) | 05-m-in-dungeon.png |
| 06 | Start a delve (any stamp), and Push into the next biome | No "Deadly bosses are in this delve" / telegraph screen appears at any point. The delve opens straight into play. The deck's Deadlies match the sprites from the map (log `telegraph` vs `next_run.deals`). | 06-telegraph-gone.png |

## Pass
All six PNGs present. No text says "Tier". No new player-facing strings. `campaign_shell_selftest` green (seed_next_run 1/2/2/2/3 unique; arm_delve consumes seeded telegraph).

## Copy flags for Spin
Plate baked STUB lines unchanged ("Grandpa's Map of Mount Grumblegut", "START HERE", "here the map gets... hazy", etc.) — still need Spin/Jam finals. Do not rewrite in this pass.
