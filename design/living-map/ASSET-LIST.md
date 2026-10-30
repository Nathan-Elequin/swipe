# ASSET LIST: Living map

All PNGs: **RGBA, Filter Nearest, mipmaps off, Lossless (`compress/mode=0`)**, same as `assets/dungeon/anim/PLACEHOLDERS.md`. No generated art. Final art (if any) goes through PixelLab.

## 1. NEW: loom-free held map plate
| path | size | source | notes |
|---|---|---|---|
| `assets/ui/map/held/map_in_hands_living.png` | 1680×1040, RGB(A) | Doop frame `w8wF4MIkv8` @1x → https://doop.design/i/w8wF4MIkv8.png?scale=1 (box copy: `/workspace/living-map/LM_PLATE_map_in_hands_living@1x.png`) | The same art as `map_in_hands.png` (B-SHIP `oYWAbgs2oF`) with the two ink looming monsters (Gulpwyrm, Bogmother) **removed**. Set `held_map.gd HELD_PLATE` to it and keep `map_in_hands.png` as the fallback. |

The plate still bakes in the mid-campaign state (Verdant 5/5 FULL, Sunken NEW 3/5, three unmapped rings, Endless sealed) and the STUB copy lines. That's how the tip plate works today, so it isn't a change from this pass. A state-agnostic plate (parchment + hands + trail art only, with Godot drawing the stamps/labels) is the right next step. Flag it for a later pass.

## 2. EXISTING: Deadly monster sprites (no new art needed)
- Native 64×64 RGBA, 4 frames `facing_idle_f0..f3`, front-facing. Feet sit on the bottom rows (bbox y-max = 64 for nearly all), so `AnimatedSprite2D.offset = (0,-32)` with `centered=true` puts the foot on the node position.
- **Map scale:** idle **0.75** (48px). Hover **1.0** (64px, pixel-exact). With Nearest, the 0.75 downscale drops every 4th row/column. That's acceptable at this size and looked clean in the Doop mock. If any sprite loses a key feature (eyes, crown), the fallback is a hand-cleaned 48×48 `assets/ui/map/monsters/<id>_map_idle_f0..f3.png` (same 4 frames, PixelLab). Don't author these up front.
- SpriteFrames: 1 animation `idle`, 4 fps, loop. Build at runtime and don't add .tres files.

| id | display name (catalog `name`) | pool | frames | exist on tip |
|---|---|---|---|---|
| `vampire` | Vampire | 1 | `assets/dungeon/anim/facing/vampire_facing_idle_f0..f3.png` | yes |
| `slime_boss` | Slime Boss | 1 | `assets/dungeon/anim/facing/slime_boss_facing_idle_f0..f3.png` | yes |
| `dragon` | Dragon | 1 | `assets/dungeon/anim/facing/dragon_facing_idle_f0..f3.png` | yes |
| `commander` | Commander | 2 | `assets/dungeon/anim/facing/commander_facing_idle_f0..f3.png` | yes |
| `almighty_worm` | Almighty Worm | 2 | `assets/dungeon/anim/facing/almighty_worm_facing_idle_f0..f3.png` | yes |
| `amalgam` | Amalgam | 2 | `assets/dungeon/anim/facing/amalgam_facing_idle_f0..f3.png` | yes |
| `two_headed_serpent` | Damsel in Distress | 3 | `assets/dungeon/anim/facing/two_headed_serpent_facing_idle_f0..f3.png` | yes |
| `spider_queen` | Spider Queen | 3 | `assets/dungeon/anim/facing/spider_queen_facing_idle_f0..f3.png` | yes |
| `phoenix_egg` | Phoenix Egg | 3 | `assets/dungeon/anim/facing/phoenix_egg_facing_idle_f0..f3.png` | yes |
| `leech_league` | Leech League | 4 | `assets/dungeon/anim/facing/leech_league_facing_idle_f0..f3.png` | yes |
| `cowardly_king` | Petty King | 4 | `assets/dungeon/anim/facing/cowardly_king_facing_idle_f0..f3.png` | yes |
| `prism` | Prism | 4 | `assets/dungeon/anim/facing/prism_facing_idle_f0..f3.png` | yes |
| `clockwork_knight` | Clockwork Knight | 5 | `assets/dungeon/anim/facing/clockwork_knight_facing_idle_f0..f3.png` | yes |
| `basilisk` | Basilisk | 5 | `assets/dungeon/anim/facing/basilisk_facing_idle_f0..f3.png` | yes |
| `hydra` | Hydra | 5 | `assets/dungeon/anim/facing/hydra_facing_idle_f0..f3.png` | yes |
| `death_bell` | Death Bell | 5 | `assets/dungeon/anim/facing/death_bell_facing_idle_f0..f3.png` | yes |
| `phoenix` | Phoenix | -1 | `assets/dungeon/anim/facing/phoenix_facing_idle_f0..f3.png` | yes |

(The 17 tier-3 monsters are from `data/catalog.json` on tip `b86e95ee`. `phoenix` has pool −1, which is token-like, so `_campaign_card_ok` may filter it out of decks.)

## 3. Godot-drawn (no PNG)
| element | spec |
|---|---|
| Ground shadow | ColorRect 32×6 (hover 40×6), `Color("3a2414")` α .32 (hover .45), no blur, centred under the foot |
| Name tag plank | StyleBoxFlat bg `#EFE0B6`, border 3px `#1A120E`, corner 0, shadow `#1A120E` offset (0,4) size 0. Content margin 8/4. Name: KIT.fit_label INK, 18→12px |
| Deadly chip | StyleBoxFlat bg `UxStyle.metal(3)` (gold `#FFD84A`-ish), border 2px `#1A120E`. Text `PlayerCopy.tier_name(3).to_upper()` |
| Tag pointer | 12×6 ink triangle (Polygon2D or `draw_colored_polygon`) under the plank |

## 4. Mock-only uploads on Doop (reference, not for the repo)
Tip frames f0/f2 were fetched from raw.githubusercontent and uploaded to Doop for the mock:
slime_boss f0 https://doop.design/a/Y0mP2X-Qwz.png · f2 https://doop.design/a/GzN9AKhb5_.png
commander f0 https://doop.design/a/QeWIcLgm_V.png · f2 https://doop.design/a/01n_l5cK4U.png
almighty_worm f0 https://doop.design/a/92UZC5bKz7.png · f2 https://doop.design/a/k5jHi00Bp8.png
spider_queen f0 https://doop.design/a/3hGNy-5gvn.png · f2 https://doop.design/a/UaoMO7u0d2.png
two_headed_serpent f0 https://doop.design/a/OjePJ4HpCG.png · f2 https://doop.design/a/iP4hd0FUen.png

## 5. Mock exports (on the box)
`/workspace/living-map/LM_living_map_idle@1x.png` / `@2x.png`
`/workspace/living-map/LM_living_map_hover@1x.png` / `@2x.png`
`/workspace/living-map/LM_PLATE_map_in_hands_living@1x.png` / `@2x.png`
