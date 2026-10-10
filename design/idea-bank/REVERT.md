# Revert this experiment

Branch: `experiment/ten-card-bank`  
Started from: `6f8e1ae964fcf4cb873f2dbca2d008c47e0c50a7` (`master`)  
Date: 2026-10-07

This pack adds ten mill cards and the idea bank under `design/idea-bank/`. It does not rewrite locked player-copy rows.

## Throw the whole pack out

Game files in this repo were not committed before this experiment, so `git checkout master` will not unwind it. Either tell chat to reverse the ten cards, or delete the files below and drop the ten ids from the JSON.

If you later commit this branch, then:

```
git checkout master
git branch -D experiment/ten-card-bank
```

## Files this pack added

- `design/idea-bank/` (this folder)
- `assets/dungeon/items/lantern.png` (+ `.import`)
- `assets/dungeon/items/mirror_shard.png`
- `assets/dungeon/items/caltrops.png`
- `assets/dungeon/items/echo_bell.png`
- `assets/dungeon/items/quiet_bell.png`
- `assets/dungeon/extra/gelatinous_cube.png`
- `assets/dungeon/extra/gargoyle.png`
- `assets/dungeon/extra/harpy.png`
- `assets/dungeon/extra/kobold_trapper.png`
- `assets/dungeon/extra/clockwork_knight.png`

## Files this pack edited

- `scripts/main.gd` — ITEM_OPS, MONSTER_SPECIAL, speech, formulas, ops, views
- `scripts/dungeon_art.gd` — stems / extra PNGs
- `data/catalog.json` — ten new rows
- `data/content-board.json` — ten new rows, status live
- `data/runtime.json` — ten ids in the dungeon pools
- `data/author-locks.json` — only if a Save rebuilt the ledger after these cards existed

## Ids to delete from JSON if you keep the branch

Items: `lantern`, `mirror_shard`, `caltrops`, `echo_bell`, `quiet_bell`  
Monsters: `gelatinous_cube`, `gargoyle`, `harpy`, `kobold_trapper`, `clockwork_knight`
