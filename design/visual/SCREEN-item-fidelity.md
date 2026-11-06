# SCREEN — Item fidelity redo (revision 2)

Nathan approved 2026-11-06. Art only. No gameplay, stats, or player-facing words.

Six live item icons were detailed 64×64 drawings. They are replaced with approved chunky pixel art that matches the established item grid (Poison flask, Orb, Healing potion, Grimoire, Blood chalice, Boot, Lantern): native 16×16, stored as exact nearest-neighbor 4× (64×64), transparent RGBA, Nearest sampling, no mipmaps.

Contact sheet (review reference only — not an in-game shot): `design/visual/item-fidelity/CONTACT-REVISION2-item-fidelity.png`. REDO columns are the approved set.

## Mapping (catalog id → live path)

| Catalog id | Display name | Live game path | Native16 archive | Approved 64 export archive |
|---|---|---|---|---|
| `venom_veins` | Venom Veins | `assets/dungeon/items/venom_veins.png` | `design/visual/item-fidelity/approved/native16/venom_veins_16.png` | `…/export64/venom_veins_64.png` |
| `kiss_of_death` | Kiss of Death | `assets/dungeon/items/kiss_of_death.png` | `…/kiss_of_death_16.png` | `…/kiss_of_death_64.png` |
| `shardplate` | Shardplate | `assets/dungeon/items/shardplate.png` | `…/shardplate_16.png` | `…/shardplate_64.png` |
| `swift_sneaks` | Swift Sneaks | `assets/dungeon/items/swift_sneaks.png` | `…/swift_sneaks_16.png` | `…/swift_sneaks_64.png` |
| `love_potion` | Love Potion | `assets/dungeon/items/love_potion.png` | `…/love_potion_16.png` | `…/love_potion_64.png` |
| `tesla_coil` | Tesla Coil | `assets/dungeon/items/tesla_coil.png` | `…/tesla_coil_16.png` | `…/tesla_coil_64.png` |

`swift_sneaks` is the Jar o' Grease replacement (id rename already on tip; path stays `swift_sneaks.png`).

Wired through `ITEM_PNG` in `scripts/dungeon_art.gd` → same six paths. Mill / draft / hotbar / fight / roster / inspect all load those paths. No alternate detailed64 copies remain under `assets/dungeon/items/` for these ids.

## Import / filter

- Sibling `.import` files left untouched (uid + compress/mode=0 lossless + `mipmaps/generate=false`).
- Project default `textures/canvas_textures/default_texture_filter=0` (Nearest). Item `TextureRect`s set Nearest in code where they override.

## Out of scope

Monsters Imp / Glass Asp / Anvil. `poison_flask` (reused Mark-3 art). Fairy bottle (parked). Unrelated older items. Mechanics and tip concurrent commits.

## Validation

```bash
python3 tools/qa/check_item_fidelity.py
python3 tools/qa/check_ui_pngs.py --only "assets/dungeon/items/{venom_veins,kiss_of_death,shardplate,swift_sneaks,love_potion,tesla_coil}.png"
```

`check_item_fidelity.py` asserts: each live PNG byte-matches its approved `_64`; each `_64` equals nearest-neighbor 4× of `_16`; each PNG is 16×16 or 64×64 RGBA with transparency; ITEM_PNG paths still point at the live files.

## Verification (in-game)

F5 playtest hub → Roster (and a fight/hotbar with these items seeded). Expect chunky pixel icons, sharp edges, no blur. Viewport 1680×1040. Repot: `playtest/repot/inbox/REQ-20261106-item-fidelity-redo.md`.
