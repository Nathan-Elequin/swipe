# Art TODO — leftovers

Unique sprites now live under `assets/dungeon/items/` and `assets/dungeon/extra/`, wired in `ITEM_PNG` / `MONSTER_PNG`. Struck rows were filled 2026-10-08.

| id | Need | Status |
|---|---|---|
| `sai` | Dual sai / prongs | Done — `items/sai.png` |
| `fangs` | Fang / tooth icon | Done — `items/fangs.png` |
| `crossbow` | Crossbow (not a bow) | Done — `items/crossbow.png` |
| `knucklers` | Brass knuckles | Done — `items/knucklers.png` |
| `hornet_swarm` | Insect / swarm | Done — `extra/hornet_swarm.png` |
| `dire_wolf` | Wolf | Done — `extra/dire_wolf.png` |
| `wraith` | Ghost / wraith | Done — Kenney Tiny Dungeon ghost `extra/wraith.png` |
| `leech_league` | Leech | Done — `extra/leech_league.png` |
| `needleback` | Porcupine | Done — `extra/needleback.png` |
| `spiked_shield` | Spiked shield | Done — `items/spiked_shield.png` |
| `grappling_hook` | Grappling hook | Done — `items/grappling_hook.png` |
| `iron_chain` | Chain (not spear/torch) | Done — `items/iron_chain.png` |
| `victory_flask` | Drink flask, not Healing Potion | Done — gold goblet `items/victory_flask.png` |
| Nib portrait | Unique impish fence | Tutorial still uses 0x72 `goblin` frames (shares the goblin owner look). |
| `music_combat.ogg` | Ironchest tension loop | itch name-your-price gate; combat uses Music-bus duck −2.5 dB on spin/fight instead. |

When a new card is added, follow `.cursor/rules/unique-art.mdc`: matching object, no duplicate pixels, register in `dungeon_art.gd`.
