# ANIM: Slash portrait (anime cut-in when a monster ability fires)

**Goal.** When a monster's ability fires, a diagonal slash panel snaps across the screen. The monster is shown animated very briefly with motion unique to its ability or character (e.g. Hornet Swarm buzzing in, Ogre roaring, Vampire hissing with a bleed flash), then the panel slashes out. One reusable system, with a per-monster frame set.

**Mockup:** `mockups/mock_slash_portrait_ogre.png` (stand-in: the existing 48px run2 Ogre frame at 6x; the final Ogre slash canvas is 64px at 4x).

## Hooks (real code)
- **Existing system to upgrade:** `scripts/ability_slash.gd`, a 252×200 left-gutter wipe with a static 112px portrait, the title and the call name. It has a queue (`play(payload)` → `_drain()` → `_show(payload)`). Main creates it at ~L1237 and positions it at ~L15003.
- **Callers:**
  - `main.gd::_announce_slice(index, to, fast)` (~L9280) is called from about 30 monster trigger sites. It already passes `tex = art.monster_still(id)`, `title`, `call` (from `call_name`) and `card_id`.
  - Items call `_announce_item_use` (`is_item = true`). Items keep the current small gutter style; the full cut-in is for monsters only.
- **Change:** in `_show`, if `not _is_item` and `art.monster_slash_frames(card_id)` is non-empty, run the **cut-in** path; otherwise fall back to today's gutter.
  - Keep the queue: cut-ins never overlap.
  - Use `payload.fast` (and Shift fast-forward through `Engine.time_scale`).
- **New art loader:** `dungeon_art.gd`. Add `monster_slash_frames(id) -> Array[Texture2D]` reading `assets/dungeon/anim/slash/<id>_slash_f*.png`.
- **Cascade ticker:** the ticker token for this trigger lights while the cut-in holds (`payload["ticket"]`).

## Layout (1680×1040)
- **Band:** a full-width parallelogram, top edge from (−40, 620) to (1720, 250) and bottom edge from (−40, 970) to (1720, 600). That is about 350px tall at a ~12° tilt.
  - Fill `#0a0706` at α0.92. Gold edge lines 6px (top) and 4px (bottom) in `gold #e8c36a`.
  - The background is dimmed by α0.47 black (mockup 2).
- **Speed lines:** 60–80 thin lines parallel to the band, scrolling in the slash direction (shader on the band, or `FX_RAYS` already used in `_draw_slash`).
- **Flash disc:** behind the portrait, coloured by the ability family:

  | Family | Colour |
  |---|---|
  | damage / rage | `danger` red |
  | heal | `heal` green |
  | poison | purple |
  | stone | grey |
  | flee | pale blue |
  | gain or steal item | gold |

- **Portrait:** native canvas 32 / 48 / 64 / 80 px, shown at **4x** (128 / 192 / 256 / 320 px). Centred at x ≈ 750, on the band centreline. Sizes vary freely by monster in the portrait; the wheel keeps sizes close.
- **Text:** right of the portrait at x ≈ 1000:
  - monster name: 34px `ink_on_dark`
  - call name: 44px `gold`
  - optional ability line: 20px `ink_body`
  - all with a 3px outline
  - Use the existing `title`/`call` from the payload. **No new words**, except Triclops's call name **Cut And Run** (from Jam).

## Timing (ms, 1x)

| Phase | Animation |
|---|---|
| Snap in | 0–120: the band slides from off-left along its own axis (`TRANS_EXPO` out); the portrait trails it by 40ms; the screen dims in 120 |
| Action | 120 → 120 + frames×70: per-monster 4–6 frames at 70ms each (280–420), then hold the last frame 120 |
| Slash out | 160: a white slash line cuts diagonally through the band (1 frame of pure white at α0.8), the band splits along the cut and the two halves fly apart ±60px with fade |
| Total | 4f ≈ 680ms; 6f ≈ 820ms |
| `fast` / Shift ×3 | ≈ 230–270ms |
| First cut-in for each monster id in a run | hold +250ms (track `_slash_seen: Dictionary` reset at run start). Later cut-ins use the normal hold. Items always keep the small gutter banner. |

## Nodes
```
AbilitySlash (Control, top_level, z 14, full-rect 1680×1040, IGNORE)   ← upgrade scripts/ability_slash.gd
 ├─ Dim (ColorRect)                                       [TW]
 ├─ Band (Polygon2D + ShaderMaterial slash_lines.gdshader) [shader: speed lines + split mask]
 ├─ Flash (Sprite2D radial, existing vfx/circle.png)      [TW]
 ├─ Portrait (AnimatedSprite2D, scale 4, NEAREST)         [PL per monster]
 ├─ Name (Label) / Call (Label) / Line (Label)            [TW]
 └─ Cut (Line2D, white)                                    [TW]
```
**Shader `slash_lines.gdshader`:** stripes along the band direction, scrolled with `TIME * speed`, plus a `split` uniform that masks the two halves for the slash-out.

## Generic fallback
If a monster has no slash frames yet, use its existing still (`art.monster_still`) with a TW "punch-in": scale 3.6→4.0 and a 2px shake. **Wizard** and **Golem** have no ability and never call this.

## Per-monster portrait list (every monster with an ability)
Frame files: `assets/dungeon/anim/slash/<id>_slash_f0..fN.png`, plus a base `<id>_slash_base.png` (portrait close-up, a new base). Canvas = native px (shown at 4x).

| # | Monster (name · `id`) | Call name | Portrait action | Frames | Canvas |
|---|---|---|---|---|---|
| 1 | Goblin · `goblin` | Evasive | sidestep blur: leans away, a sword streak whiffs past, cheeky grin | 4 | 48×48 |
| 2 | Skeleton · `skeleton` | HP Echo | skull tilts, a ghost heart floats in from the left and clatters into the ribcage | 5 | 48×48 |
| 3 | Hornet Swarm · `hornet_swarm` | Double Strike | swarm buzzes in from off-panel, splits into two stinger clumps (Double Strike) | 5 | 48×48 |
| 4 | Lich · `lich` | Siphon | raises both hands; green wisps peel off to left and right | 4 | 64×64 |
| 5 | Ogre · `ogre` | Empath | roars at camera, club raised; spit and a red mirror-crack across its chest | 5 | 64×64 |
| 6 | Vampire · `vampire` | Bloodlust | hisses, fangs bared; a red bleed flash wipes across the eyes | 5 | 48×48 |
| 7 | Berserker · `berserker` | Outburst | Grandpa coin flips above; on heads, eyes ignite and hair flares | 5 | 48×48 |
| 8 | Dire Wolf · `dire_wolf` | Kill Shot | lunging snarl, eyes lock onto a heart icon | 4 | 48×48 |
| 9 | Bandit · `bandit` | Hoarder | eyes dart left-right, then a sly grin and a coin glint in the mask | 4 | 48×48 |
| 10 | Leech League · `leech_league` | Blood Rise | three leeches inch in a chain, the last one swells red | 5 | 48×48 |
| 11 | Wraith · `wraith` | Neighbor's Wrath | flickers, then a ghostly copy of a neighbouring weapon forms in its claw | 4 | 48×48 |
| 12 | Mimic · `mimic` | Treasure | lid snaps open, tongue lolls, gold coins spill out | 5 | 48×48 |
| 13 | Damsel In Distress · `two_headed_serpent` | Guarded by Monsters | damsel waves a hanky; two monster silhouettes loom behind her, then she blows a heart | 5 | 64×64 |
| 14 | Slime Boss · `slime_boss` | Body Slam | body-slam squash and stretch, numbers ripple in the goo | 4 | 64×64 |
| 15 | Spider Queen · `spider_queen` | Egg Layer | rears up, abdomen pulses, an egg plops out | 5 | 64×64 |
| 16 | Commander · `commander` | War Cry | raises a horn and blasts; banner snaps in the wind | 5 | 64×64 |
| 17 | Dragon · `dragon` | Firebreather | rears back, chest glows, a fire breath sweeps through a shield silhouette | 6 | 80×80 |
| 18 | Needleback · `needleback` | Spiky | curls and fires quills outward | 4 | 48×48 |
| 19 | Gelatinous Cube · `gelatinous_cube` | Devour Item | wobbles, two item silhouettes inside, a gulp | 5 | 64×64 |
| 20 | Gargoyle · `gargoyle` | Petrify | stone face cracks, eyes glow grey, gaze beam | 4 | 48×48 |
| 21 | Harpy · `harpy` | Impatient | impatient talon tap, then dive-screech toward camera | 5 | 48×48 |
| 22 | Kobold Trapper · `kobold_trapper` | Trap Card | snaps open a bear trap with a grin, a little click spark | 4 | 48×48 |
| 23 | Clockwork Knight · `clockwork_knight` | Disassemble | gears whir; at the end it bursts into two smaller silhouettes | 6 | 64×64 |
| 24 | Basilisk · `basilisk` | Petrifying Gaze | hood flares, eyes flash stone-grey, then it slithers off-panel | 5 | 64×64 |
| 25 | Twins · `hollow` | Doubly Troubled | the twins move in mirror; an even number splits into two | 4 | 48×48 |
| 26 | Beggar · `beggar` | Leftie | holds out a cup, eyes lock on the leftmost item | 4 | 48×48 |
| 27 | Wick · `wick` | Death Toll | flame gutters, wax drips twice | 4 | 48×48 |
| 28 | Anvil · `anvil` | Tough Blood | a hammer clangs off it with sparks; only a single chip falls | 4 | 48×48 |
| 29 | Bodyguard · `bodyguard` | Protector | shield-dash sideways, arms wide | 4 | 48×48 |
| 30 | Cowardly King · `cowardly_king` | Guards! | ducks behind his cape, points to the side, crown wobbles | 5 | 48×48 |
| 31 | Merchant · `merchant` | Fair Trade | tips a hat, a scale tips and a coin flips | 4 | 48×48 |
| 32 | Juggernaut · `juggernaut` | Blockhead | stomps, a shield thunks into view | 4 | 64×64 |
| 33 | Cleric · `cleric` | Health Insurance | heal glow from the palm, then a gloved hand plucks an item | 5 | 48×48 |
| 34 | Martyr · `martyr` | Noble Death | kneels, hands open, body glows and splits into two light streams | 5 | 48×48 |
| 35 | Prism · `prism` | Refract Damage | crystal rotates and a beam refracts into a rainbow fan | 4 | 48×48 |
| 36 | Plague Doctor · `plague_doctor` | Always Plague | censer swings and purple smoke rolls out; a padlock glint | 5 | 48×48 |
| 37 | Hired Hand · `hired_hand` | Bribe | catches a coin, turns and swings at the side | 4 | 48×48 |
| 38 | Hydra · `hydra` | Even Killer | heads snap out one by one, eyes flash grey | 6 | 80×80 |
| 39 | Zombie · `zombie` | Decay | lurches, flesh flakes off and items crumble in its hand | 4 | 48×48 |
| 40 | Triclops · `triclops` | Cut And Run | three eyes blink in sequence, then it bolts (Cut And Run) | 5 | 48×48 |
| 41 | Shambling Mound · `shambling_mound` | Self Deconstruct | heaves forward, moss clumps slough off with each step | 5 | 48×48 |
| 42 | Almighty Worm · `almighty_worm` | Hunger Pains | maw unfurls from the bottom of the panel and gulps | 6 | 80×80 |
| 43 | Cultist · `cultist` | Blood Pact | hood glows, a blood rune draws in the air | 4 | 48×48 |
| 44 | Bushido · `bushido` | Patient Disarm | half-draws the katana, then a fast iai slash | 5 | 48×48 |
| 45 | Shark · `shark` | Blood Thresh | fin circles, then a breach bite | 5 | 64×64 |
| 46 | Death Bell · `death_bell` | Toll Of The Dead | the bell swings and dongs; shockwave rings, a crack runs down | 6 | 64×64 |
| 47 | Phoenix Egg · `phoenix_egg` | Hatch | egg rattles, cracks glow, fire bursts out | 5 | 48×48 |
| 48 | Phoenix · `phoenix` | Rebirth | wings spread in flame, then collapse into ash and an egg | 5 | 64×64 |
| 49 | Amalgam · `amalgam` | Adaptation | splits into blobs that re-merge bigger | 5 | 64×64 |
| 50 | Fairy · `fairy` | Fairy Dust | flutter loop with sparkle rain | 4 | 32×32 |
| 51 | Eel · `eel` | Conductive | coils and a lightning arc crackles along its body | 4 | 48×48 |
| 52 | Druid · `druid` | Cultivator | staff raised, vines curl up and bloom | 5 | 48×48 |
| 53 | Mouse · `mouse` | Scurry | squeaks, ears flatten, scurries off | 4 | 32×32 |
| 54 | Magicat · `magicat` | Cat's Eye | wand flick, star sparkles, two marbles pop | 5 | 48×48 |
| 55 | Rust Bucket · `rust_bucket` | Rust | tips over, orange flakes pour out | 4 | 48×48 |
| 56 | Poison Frog · `poison_frog` | Toxic Skin | tongue flick, a purple drop flies | 4 | 32×32 |

**Totals:** 56 monsters, 260 frames. Canvases: 32px ×3, 48px ×36, 64px ×14, 80px ×3.

## Assets
- Per-monster: 1 base portrait plus a 4–6f action → **56 bases + 56 animations**. Generation counts are in `ASSETS.md`.
- System art: none needed. Band, dim, cut and text are [TW] / shader; the flash reuses `assets/dungeon/vfx/circle.png`.
- Existing PixelLab finals usable as bases and references:
  - `run3/final`: `mon_hornet_swarm_*`, `mon_dragon_*`, `mon_dire_wolf_*`, `mon_spider_queen_*`, `mon_goblin_*`, `mon_skeleton_*`
  - `run2/final`: `mon_ogre_f0-3`
  - These are 32–64px movement loops. Re-pose them as close-up action frames on the canvases above.
- Palette: monster palettes as in their wheel sprite; flash colours from tokens.

## QA
1. Seat Ogre and take a hit: shots at 60ms (band entering), 300ms (mid action, compare with mockup 2) and 700ms (split out).
2. Hornet Swarm, Vampire and Commander: each plays its own frames. A monster without frames uses the fallback punch-in.
3. A cascade with 3 triggers: cut-ins queue and never overlap; the ticker tokens light in sync.
4. Hold Shift: each cut-in ≈ 250ms. The first Ogre cut-in of a run holds 250ms longer than the second.
5. Triclops shows **Cut And Run**. `text_audit` passes, with no "Tier".
