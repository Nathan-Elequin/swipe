# PixelLab asset list: all ANIM specs

**Estimate rule:** about 1 gen per 4-frame animation (8f = 2, 5–6f = 2), plus about 1 gen per new base. Single icons batched into one sheet count as 1 gen.

**Import (all):** PNG, Nearest, no mipmaps, Lossless, palette-matched to `design/visual/tokens.json`. Paths are under `assets/`.

Assets marked [TW] or shader in the specs need **no** generation and are not listed.

## UI and item animation assets

| Spec | File | Native size | Frames | New base? | Prompt line | Gens |
|---|---|---|---|---|---|---|
| intent-plate | `ui/anim/intent_claw_idle.png` | 16×16 | 1 | yes | dark-red rounded claw badge, three bone-white claw rakes on top, empty centre for a number, 1px dark outline | 1 |
| intent-plate | `ui/anim/intent_claw_lit_f0-3.png` | 16×16 | 4 | no | same badge lighting up: rim brightens to cream, inner glow pulses | 1 |
| intent-plate | `ui/anim/intent_claw_burst_f0-3.png` | 24×24 | 4 | no | badge impact burst, cream and red shards radiating, fading | 1 |
| intent-plate | `ui/anim/intent_claw_flame_idle.png` | 16×16 | 1 | yes | claw badge variant with a fire rim (ignores Block) | 1 |
| intent-plate | `ui/anim/intent_claw_flame_burst_f0-3.png` | 24×24 | 4 | no | fire-rim badge burst, flames licking outward | 1 |
| intent-plate + hover | `ui/anim/intent_chip_{shield,drop,flee,plus}.png` | 8×8 ×4 | 1 | yes | sheet of 4 tiny chips: shield, purple drop, footprints, plus sign (the Shark loop reuses the wheel's ↻ tag, no art) | 1 |
| spin-cascade-ticker | `ui/anim/ticker_token_frame.png` | 12×12 | 1 | yes | round brass stamp ring, empty middle | 1 |
| spin-cascade-ticker | `ui/anim/ticker_token_stamp_f0-3.png` | 12×12 | 4 | no | stamp ring pressing down with an ink tick | 1 |
| spin-cascade-ticker | `ui/anim/ticker_ff.png` | 12×8 | 1 | yes | fast-forward double chevron, gold | 1 |
| aura-threads | `ui/anim/aura_glyph_{sword,wisp,drop,lock,shield}.png` | 8×8 ×5 | 1 | yes | sheet of 5 tiny glyphs: red sword, green wisp, purple drop, padlock, steel shield | 1 |
| poison-pop | `ui/anim/poison_badge_drip_f0-3.png` | 8×8 | 4 | no | existing poison drop icon dripping slowly (from tex_poison) | 1 |
| poison-pop | `ui/anim/poison_burst_f0-3.png` | 24×24 | 4 | no | purple-green poison bubble bursting with droplets | 1 |
| poison-pop | `ui/anim/heart_drip_f0-3.png` | 12×12 | 4 | no | small red heart draining into a drip | 1 |
| sai-twirl-split | `dungeon/anim/sai_single.png` | 24×24 | 1 | yes | single sai, matched to the current Sai icon, diagonal | 1 |
| sai-twirl-split | `dungeon/anim/sai_pair.png` | 24×24 | 1 | yes | two sais crossed in an X, same style | 1 |
| sai-twirl-split | `dungeon/anim/sai_split_f0-7.png` | 24×24 | 8 | no | one sai twirls then separates into the crossed pair (reverse = merge) | 2 |
| marble-swirl | `dungeon/anim/marble_idle_f0-3.png` | 24×24 | 4 | no | glass marble with a slow red/blue two-tone swirl | 1 |
| marble-swirl | `dungeon/anim/marble_swirl_f0-5.png` | 24×24 | 6 | no | fast swirl, colours blending | 2 |
| marble-swirl | `dungeon/anim/marble_{red,blue}.png` | 24×24 ×2 | 1 | yes | marble settled solid red / solid blue, highlight glint | 1 |
| marble-swirl | `dungeon/anim/marble_cat_idle_f0-3.png` | 24×24 | 4 | yes | cat's-eye marble (Magicat) with a slow celestial sparkle | 2 |
| grappling-hook | `dungeon/anim/hook_throw_f0-5.png` | 24×24 | 6 | no | grappling hook spinning out on a rope (base = current icon) | 2 |
| grappling-hook | `dungeon/anim/hook_taut.png` | 24×24 | 1 | yes | hook caught, prongs bitten in | 1 |
| grappling-hook | `dungeon/anim/rope_tile.png` | 4×8 | 1 | yes | tileable braided rope segment | 1 |
| petrify | `ui/anim/petrify_shatter_f0-4.png` | 30×30 | 5 | no | card-sized stone shell cracking and shattering into chunks | 2 |
| hotbar-shimmer | `ui/anim/deadly_sparkle_f0-3.png` | 8×8 | 4 | no | gold four-point sparkle twinkle | 1 |
| | **Subtotal** | | **76** | | | **30** |

## Slash portraits (`dungeon/anim/slash/<id>_slash_base.png` + `<id>_slash_f0..fN.png`)

Prompt pattern: *"close-up anime cut-in portrait of {monster}, 3/4 view, dramatic, 16px-base pixel art, dark outline; action: {action}"*.

| # | Monster · id | Canvas | Frames | Prompt (action) | Gens (base + anim) |
|---|---|---|---|---|---|
| 1 | Goblin · `goblin` | 48×48 | 4 | sidestep blur: leans away, a sword streak whiffs past, cheeky grin | 2 |
| 2 | Skeleton · `skeleton` | 48×48 | 5 | skull tilts, a ghost heart floats in from the left and clatters into the ribcage | 3 |
| 3 | Hornet Swarm · `hornet_swarm` | 48×48 | 5 | swarm buzzes in from off-panel, splits into two stinger clumps (Double Strike) | 3 |
| 4 | Lich · `lich` | 64×64 | 4 | raises both hands; green wisps peel off to left and right | 2 |
| 5 | Ogre · `ogre` | 64×64 | 5 | roars at camera, club raised; spit and a red mirror-crack across its chest | 3 |
| 6 | Vampire · `vampire` | 48×48 | 5 | hisses, fangs bared; a red bleed flash wipes across the eyes | 3 |
| 7 | Berserker · `berserker` | 48×48 | 5 | Grandpa coin flips above; on heads, eyes ignite and hair flares | 3 |
| 8 | Dire Wolf · `dire_wolf` | 48×48 | 4 | lunging snarl, eyes lock onto a heart icon | 2 |
| 9 | Bandit · `bandit` | 48×48 | 4 | eyes dart left-right, then a sly grin and a coin glint in the mask | 2 |
| 10 | Leech League · `leech_league` | 48×48 | 5 | three leeches inch in a chain, the last one swells red | 3 |
| 11 | Wraith · `wraith` | 48×48 | 4 | flickers, then a ghostly copy of a neighbouring weapon forms in its claw | 2 |
| 12 | Mimic · `mimic` | 48×48 | 5 | lid snaps open, tongue lolls, gold coins spill out | 3 |
| 13 | Damsel In Distress · `two_headed_serpent` | 64×64 | 5 | damsel waves a hanky; two monster silhouettes loom behind her, then she blows a heart | 3 |
| 14 | Slime Boss · `slime_boss` | 64×64 | 4 | body-slam squash and stretch, numbers ripple in the goo | 2 |
| 15 | Spider Queen · `spider_queen` | 64×64 | 5 | rears up, abdomen pulses, an egg plops out | 3 |
| 16 | Commander · `commander` | 64×64 | 5 | raises a horn and blasts; banner snaps in the wind | 3 |
| 17 | Dragon · `dragon` | 80×80 | 6 | rears back, chest glows, a fire breath sweeps through a shield silhouette | 3 |
| 18 | Needleback · `needleback` | 48×48 | 4 | curls and fires quills outward | 2 |
| 19 | Gelatinous Cube · `gelatinous_cube` | 64×64 | 5 | wobbles, two item silhouettes inside, a gulp | 3 |
| 20 | Gargoyle · `gargoyle` | 48×48 | 4 | stone face cracks, eyes glow grey, gaze beam | 2 |
| 21 | Harpy · `harpy` | 48×48 | 5 | impatient talon tap, then dive-screech toward camera | 3 |
| 22 | Kobold Trapper · `kobold_trapper` | 48×48 | 4 | snaps open a bear trap with a grin, a little click spark | 2 |
| 23 | Clockwork Knight · `clockwork_knight` | 64×64 | 6 | gears whir; at the end it bursts into two smaller silhouettes | 3 |
| 24 | Basilisk · `basilisk` | 64×64 | 5 | hood flares, eyes flash stone-grey, then it slithers off-panel | 3 |
| 25 | Twins · `hollow` | 48×48 | 4 | the twins move in mirror; an even number splits into two | 2 |
| 26 | Beggar · `beggar` | 48×48 | 4 | holds out a cup, eyes lock on the leftmost item | 2 |
| 27 | Wick · `wick` | 48×48 | 4 | flame gutters, wax drips twice | 2 |
| 28 | Anvil · `anvil` | 48×48 | 4 | a hammer clangs off it with sparks; only a single chip falls | 2 |
| 29 | Bodyguard · `bodyguard` | 48×48 | 4 | shield-dash sideways, arms wide | 2 |
| 30 | Cowardly King · `cowardly_king` | 48×48 | 5 | ducks behind his cape, points to the side, crown wobbles | 3 |
| 31 | Merchant · `merchant` | 48×48 | 4 | tips a hat, a scale tips and a coin flips | 2 |
| 32 | Juggernaut · `juggernaut` | 64×64 | 4 | stomps, a shield thunks into view | 2 |
| 33 | Cleric · `cleric` | 48×48 | 5 | heal glow from the palm, then a gloved hand plucks an item | 3 |
| 34 | Martyr · `martyr` | 48×48 | 5 | kneels, hands open, body glows and splits into two light streams | 3 |
| 35 | Prism · `prism` | 48×48 | 4 | crystal rotates and a beam refracts into a rainbow fan | 2 |
| 36 | Plague Doctor · `plague_doctor` | 48×48 | 5 | censer swings and purple smoke rolls out; a padlock glint | 3 |
| 37 | Hired Hand · `hired_hand` | 48×48 | 4 | catches a coin, turns and swings at the side | 2 |
| 38 | Hydra · `hydra` | 80×80 | 6 | heads snap out one by one, eyes flash grey | 3 |
| 39 | Zombie · `zombie` | 48×48 | 4 | lurches, flesh flakes off and items crumble in its hand | 2 |
| 40 | Triclops · `triclops` | 48×48 | 5 | three eyes blink in sequence, then it bolts (Cut And Run) | 3 |
| 41 | Shambling Mound · `shambling_mound` | 48×48 | 5 | heaves forward, moss clumps slough off with each step | 3 |
| 42 | Almighty Worm · `almighty_worm` | 80×80 | 6 | maw unfurls from the bottom of the panel and gulps | 3 |
| 43 | Cultist · `cultist` | 48×48 | 4 | hood glows, a blood rune draws in the air | 2 |
| 44 | Bushido · `bushido` | 48×48 | 5 | half-draws the katana, then a fast iai slash | 3 |
| 45 | Shark · `shark` | 64×64 | 5 | fin circles, then a breach bite | 3 |
| 46 | Death Bell · `death_bell` | 64×64 | 6 | the bell swings and dongs; shockwave rings, a crack runs down | 3 |
| 47 | Phoenix Egg · `phoenix_egg` | 48×48 | 5 | egg rattles, cracks glow, fire bursts out | 3 |
| 48 | Phoenix · `phoenix` | 64×64 | 5 | wings spread in flame, then collapse into ash and an egg | 3 |
| 49 | Amalgam · `amalgam` | 64×64 | 5 | splits into blobs that re-merge bigger | 3 |
| 50 | Fairy · `fairy` | 32×32 | 4 | flutter loop with sparkle rain | 2 |
| 51 | Eel · `eel` | 48×48 | 4 | coils and a lightning arc crackles along its body | 2 |
| 52 | Druid · `druid` | 48×48 | 5 | staff raised, vines curl up and bloom | 3 |
| 53 | Mouse · `mouse` | 32×32 | 4 | squeaks, ears flatten, scurries off | 2 |
| 54 | Magicat · `magicat` | 48×48 | 5 | wand flick, star sparkles, two marbles pop | 3 |
| 55 | Rust Bucket · `rust_bucket` | 48×48 | 4 | tips over, orange flakes pour out | 2 |
| 56 | Poison Frog · `poison_frog` | 32×32 | 4 | tongue flick, a purple drop flies | 2 |
| | **Subtotal (56 monsters)** | | **260** | | **143** |

## Totals

| Group | Assets | Frames | Est. gens |
|---|---|---|---|
| UI and item animations | 25 | 76 | 30 |
| Slash portraits | 56 bases + 56 anims | 260 + 56 bases | 143 |
| **All** | | **392** | **≈173** |

**Savings:** the 7 monsters with existing run2/run3 finals (Hornet Swarm, Dragon, Dire Wolf, Spider Queen, Goblin, Skeleton, Ogre) can use their current sprite as the PixelLab reference image, but they still need a close-up base. Budget about 10% for re-rolls → **≈190 gens**.

**Suggested order:**
1. intent-plate set
2. the sai and marble sets (Nathan's examples)
3. poison and petrify
4. slash portraits for the starter monsters: Goblin, Skeleton, Hornet Swarm, Lich, Mouse
5. Tough, then Deadly slash portraits
