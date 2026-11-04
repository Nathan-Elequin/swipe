# Catalog consistency audit

- Generated: `2026-11-04T19:19:03Z`
- Git tip: `c61ea2e4`
- Tool: `tools/catalog_consistency_audit.py`

## Counts

- **items** — 72
- **monsters** — 63
- **item_png** — 70
- **monster_png** — 62
- **sfx_cues** — 360
- **sfx_card_lookup** — 133
- **player_copy_keys** — 753
- **player_copy_maybe_dead** — 227
- **gaps** — 246
- **fixed** — 0

## Auto-fixes applied on this branch

- Generated: `2026-11-04T19:18:51Z`
- Git tip at fix time: `c61ea2e4`
- flags.art=true catalog monster:bear_trap
- flags.art=true board monster:bear_trap
- flags.art=true catalog monster:two_headed_serpent
- flags.art=true board monster:two_headed_serpent

## Top gaps by severity (open)

1. **[critical]** `token_wrong_tier` — `monster:bear_trap`: Token (pool=-1.0) is live with tier=2.0; name='Bear Trap'. Tokens must not count as mill tier for drafts. _Design/code fix — see GitHub #358. Do not auto-change tier here._
2. **[high]** `code_id_missing_catalog` — `monster:fungal_colony`: main.gd references this id but catalog.json has no row. _Add catalog row or retire code path._
3. **[high]** `live_missing_art_registry` — `item:fairy_in_a_bottle`: Live item 'Fairy In A Bottle' has no ITEM_PNG/MONSTER_PNG entry; flags.art=False. _Pixel: register unique art (do not invent PNG here)._
4. **[low]** `orphan_png_on_disk` — `assets/dungeon/extra/spider.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
5. **[low]** `orphan_png_on_disk` — `assets/dungeon/extra/triclops.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
6. **[low]** `orphan_png_on_disk` — `assets/dungeon/extra/two_headed_serpent.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
7. **[low]** `orphan_png_on_disk` — `assets/dungeon/items/gauntlets.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
8. **[low]** `orphan_png_on_disk` — `assets/dungeon/items/spiked_shield_block.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
9. **[low]** `orphan_png_on_disk` — `assets/dungeon/items/watch.png`: PNG under items/extra not referenced in dungeon_art.gd. _Pixel: wire or retire file._
10. **[low]** `player_copy_maybe_dead_summary` — `count:227`: No literal/dynamic reference found for 227 keys. Sample: challenge.click_target, challenge.spin_confirm, pause.ambience, pause.ui, road.caption.A1.1, road.caption.A2.1, road.caption.A2.2, cabin.hot.run_door (+219 more). _Jam review before delete. Full list in gaps.csv (kind=player_copy_maybe_dead). Do not mass-delete._
11. **[low]** `sfx_ability_hold` — `monster:golem`: No ability lookup by design: no named ability oneshot (cues.py HOLD). _Leave until HOLD clears; do not invent audio._
12. **[low]** `sfx_ability_hold` — `monster:leech_league`: No ability lookup by design: HOLD until #347 Blood Rise / slash portrait. _Leave until HOLD clears; do not invent audio._
13. **[low]** `sfx_ability_hold` — `monster:wizard`: No ability lookup by design: no named ability oneshot (cues.py HOLD). _Leave until HOLD clears; do not invent audio._
14. **[info]** `art_registry_without_catalog` — `item:bag_of_holding_closed`: ITEM_PNG/MONSTER_PNG id not in catalog.json (res://assets/dungeon/items/bag_of_holding_closed.png). _Keep if alias/extra; else remove registry entry in a Pixel pass._
15. **[info]** `art_registry_without_catalog` — `item:cats_eye_marble`: ITEM_PNG/MONSTER_PNG id not in catalog.json (res://assets/dungeon/items/cats_eye_marble.png). _Keep if alias/extra; else remove registry entry in a Pixel pass._
16. **[info]** `sfx_lookup_alias` — `lookup:chaos_stone`: card_id lookup key is an alias/ops/legacy id, not a catalog row. _Keep unless code stops using it._
17. **[info]** `sfx_lookup_alias` — `lookup:fungal_colony`: card_id lookup key is an alias/ops/legacy id, not a catalog row. _Keep unless code stops using it._
18. **[info]** `sfx_lookup_alias` — `lookup:hook`: card_id lookup key is an alias/ops/legacy id, not a catalog row. _Keep unless code stops using it._
19. **[info]** `sfx_lookup_alias` — `lookup:magnet`: card_id lookup key is an alias/ops/legacy id, not a catalog row. _Keep unless code stops using it._

## TODOs (art / design / Reel — not auto-fixed)

- **monster:bear_trap** (`token_wrong_tier`): Design/code fix — see GitHub #358. Do not auto-change tier here.
- **monster:fungal_colony** (`code_id_missing_catalog`): Add catalog row or retire code path.
- **item:fairy_in_a_bottle** (`live_missing_art_registry`): Pixel: register unique art (do not invent PNG here).
- **assets/dungeon/extra/spider.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **assets/dungeon/extra/triclops.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **assets/dungeon/extra/two_headed_serpent.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **assets/dungeon/items/gauntlets.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **assets/dungeon/items/spiked_shield_block.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **assets/dungeon/items/watch.png** (`orphan_png_on_disk`): Pixel: wire or retire file.
- **monster:golem** (`sfx_ability_hold`): Leave until HOLD clears; do not invent audio.
- **monster:leech_league** (`sfx_ability_hold`): Leave until HOLD clears; do not invent audio.
- **monster:wizard** (`sfx_ability_hold`): Leave until HOLD clears; do not invent audio.

## Issue cross-links

- [#358](https://github.com/Nathan-Elequin/swipe/issues/358) — Bear Trap is a Token, not a Tier 2 mill monster (draft skip).
- [#348](https://github.com/Nathan-Elequin/swipe/issues/348) — Recycler SFX / countdown feel (map cue may already exist; feel still open).
- [#347](https://github.com/Nathan-Elequin/swipe/issues/347) — Leech League slash / HOLD on ability SFX.

## Full gap table

See `gaps.csv` in this folder (and `playtest/catalog-audit/gaps.csv`).

### Kind legend

| kind | meaning |
|---|---|
| live_missing_art_registry | Live card not in ITEM_PNG/MONSTER_PNG |
| art_flag_false_but_file_exists | flags.art false though PNG is wired |
| art_registry_without_catalog | PNG map id with no catalog row |
| orphan_png_on_disk | File under items/extra unused by dungeon_art.gd |
| token_wrong_tier | Token (pool&lt;0) carrying mill tier ≥2 |
| sfx_lookup_hole | Cue exists; card_id lookup missing |
| sfx_missing_*_cue | No cue for live card |
| sfx_ability_hold | Intentional skip (cues.py HOLD) |
| player_copy_maybe_dead | Key not found via literals/dynamic prefixes |
| code_id_missing_catalog | Hardcoded id without catalog row |

