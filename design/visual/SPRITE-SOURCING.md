# Sprite sourcing — Direction A (35 items, 29 monsters)

Goal: a free (CC0) 16×16 base for every item and monster in `data/runtime.json`, recoloured to palette A. Anything without a usable base is listed separately for Nathan to decide on (Aseprite or PixelLab). Spend so far: $0.
**On hold:** Damsel in Distress art (Kenney Tiny Dungeon `tile_0099`, the princess, is the likely base when it's unblocked).

## Sources (all CC0 1.0: commercial use OK, no attribution required; we credit anyway in CREDITS.md)
| Code | Pack | Link | Format |
|---|---|---|---|
| **TD** | Kenney *Tiny Dungeon* 1.0 | [kenney.nl/assets/tiny-dungeon](https://kenney.nl/assets/tiny-dungeon) · [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | 16×16 colour tiles, `Tiles/tile_NNNN.png` (NNNN = index) |
| **1B** | Kenney *1-Bit Pack* | [kenney.nl/assets/1-bit-pack](https://kenney.nl/assets/1-bit-pack) · [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) | 16×16 single-colour shapes. `Tilesheet/colored-transparent_packed.png`, 49×22 grid, cited as **(col,row)**; crop `x=col*16, y=row*16` |
| **0x72** | 0x72 *16x16 DungeonTileset II* | [0x72.itch.io/dungeontileset-ii](https://0x72.itch.io/dungeontileset-ii) · CC0 (stated on the page) | backup only. Many figures are 16×28, so they need cropping to 16×16 |

Every TD and 1B index below was checked by eye against an enlarged, labelled sheet on 2026-10-11.

## Recolour rules for palette A (applies to every row)
1. **Outline:** 1 px soot `#1A120E` all round (1B shapes need it added; TD already has a dark outline, so swap it to soot).
2. **Three-step ramps only:**
   - metal: `#C9CED6` / `#7A4E2B` / `#3B2618`
   - wood and leather: `#B8733A` / `#7A4E2B` / `#3B2618`
   - cloth and flesh: `#E9D3A1` / `#A88C66` / `#4A2F1F`
3. **Accents:**
   - gold `#FFD84A` only on precious or "Deadly-looking" loot
   - ATK red `#D5443B` for blood and fire
   - BLK blue `#4FA3D9` for magic and ice
   - KO plum `#A866C9` for curses
   - imp green `#7BC950` is **reserved for Nib**, so poison and slime use `#4E8A3A` / `#2E5A28`
4. Light comes from the top-left: 1 px highlight on the upper-left edges, shade on the lower right.
5. Export at 1× (16×16) as `assets/sprites/items/item_<slug>.png` or `assets/sprites/monsters/<slug>/mon_<slug>_idle.png`. Godot scales them ×4 or ×8 with nearest filtering.

Effort tags: **R** = recolour only (~5 min) · **E** = recolour plus a small edit (~15–30 min).

## Items (35)
| Item (`runtime.json` id) | Base | Effort | Palette A notes |
|---|---|---|---|
| throwing_knife | TD `tile_0103` (dagger) | R | steel blade, wood grip, 1 px gold pommel |
| shield | TD `tile_0102` (round steel) | R | metal ramp, rivet-bronze boss |
| sai | 1B (35,5) (three-prong trident) | E | shorten the shaft to a 16 px dagger length; steel ramp, leather-wrapped grip |
| medallion | 1B (44,8) (pendant) | R | gold disc, BLK-blue gem, edge-brown cord |
| helmet | 1B (33,0) (open helm) | R | steel ramp, soot visor slit |
| da_boot | 1B (39,1) (boots) | R | leather ramp; add one gold buckle pixel |
| bloody_gauntlets | 1B (41,1) (gauntlets) | E | steel ramp, with ATK-red drips on the knuckles (3–4 px) |
| bracers | 1B (39,0) (bracer pair) | R | leather ramp with bronze bands |
| knucklers | 1B (41,0) (studded fists) | R | steel knuckle row on a parchment-ish hand |
| spiked_flail | 1B (38,8) (spiked ball on a handle) | E | add a 3-link chain between the handle and the ball; steel and wood |
| sledgehammer | TD `tile_0117` | R | steel head, wood handle |
| grimoire | 1B (45,5) (book) | E | plum `#A866C9` cover, gold clasp, 1 px parchment page edge |
| breastplate | 1B (37,1) (tunic/jerkin shape) | E | fill as a steel cuirass: metal ramp, centre ridge highlight |
| smoke_bomb | 1B (45,9) (bomb with fuse) | R | soot-grey body, torch-orange fuse spark, 2 px parchment smoke puff |
| fangs | 1B (33,12) (beast skull) | E | crop to the jaw and teeth only; parchment teeth, red gum line |
| poison_flask | TD `tile_0114` (green potion) | R | swap the liquid to poison green `#4E8A3A` (not Nib green) |
| healing_potion | TD `tile_0115` (red potion) | R | ATK-red liquid, parchment highlight |
| crossbow | 1B (37,5) | R | wood stock, steel limbs |
| pocketwatch | 1B (41,3) (gold coin) | E | add a crown knob and 2 hands; gold case, parchment face |
| double_axe | TD `tile_0118` | R | steel heads, wood haft |
| victory_flask | TD `tile_0113` (empty grey flask) | E | gold liquid `#FFD84A` with a torch-orange shade, 1 px sparkle |
| grappling_hook | 1B (44,5) (hooked pole) | E | cut the pole down to a short shank, add a coiled rope loop (parchment/dim) |
| spiked_shield | 1B (38,2) (studded round shield) | R | wood ramp with steel studs |
| grief_jar | 1B (34,13) (clay pot) | R | edge-brown clay, plum stopper |
| longbow | 1B (37,6) | R | wood ramp, parchment string |
| lantern | 1B (4,15) (lantern with flame) | R | bronze frame, torch/gold flame |
| mirror_shard | 1B (33,10) (faceted crystal) | E | recolour as glass: silver `#C9CED6` with a BLK-blue glint |
| net | 1B (2,15) (web) | R | parchment/dim rope mesh |
| counting_beads | 1B (43,7) (bead necklace) | R | alternate bronze and parchment beads |
| echo_bell | — | **from scratch** | see the Nathan list |
| quiet_bell | — | **from scratch** | see the Nathan list |
| iron_chain | — | **from scratch** | see the Nathan list |
| last_match | — | **from scratch** | see the Nathan list (1B (3,15) candle is only a weak reference) |
| measuring_tape | — | **from scratch** | see the Nathan list |
| mute_stone | — | **from scratch** | see the Nathan list |

29 items have a base; 6 are from scratch (35 total).

## Monsters (29)
| Monster | Base | Effort | Palette A notes |
|---|---|---|---|
| wizard | TD `tile_0084` | R | plum robe and hat, parchment beard |
| golem | 1B (30,6) (blocky stone figure) | R | stone ramp `#A88C66`/`#7A4E2B`/`#3B2618`, gold eye pixels |
| goblin | 1B (31,3) (big-eared goblin) | R | **not Nib green**: olive `#8A8A3A`/`#5A5A24` skin, leather vest |
| skeleton | 1B (29,6) | R | parchment bone, soot eye holes |
| hornet_swarm | 1B (31,5) (insect) | E | 3 copies at 8–10 px on one 16×16 tile; gold and soot stripes |
| lich | TD `tile_0111` (hooded bearded figure) | E | plum hood, add a 3 px gold crown, BLK-blue eye glow |
| ogre | TD `tile_0109` (cyclops) | R | dull flesh `#B8733A`, leather loincloth |
| berserker | TD `tile_0087` (horned viking) | R | red beard, steel helm |
| dire_wolf | 1B (31,7) (dog) | E | thicken the ruff, grey-brown fur, red eye |
| bandit | TD `tile_0112` (headband man) | R | soot mask over the lower face, leather |
| two_headed_serpent | 1B (28,8) (coiled snake) | E | add a second head, mirrored; poison-green / bronze scales |
| slime_boss | TD `tile_0108` (slime) | E | poison green `#4E8A3A`, add a 3 px gold crown |
| leech_league | — | **from scratch** | see the Nathan list |
| wraith | TD `tile_0121` (ghost) | R | parchment body at 80 %, BLK-blue eyes |
| mimic | TD `tile_0092` (chest with teeth) | R | wood ramp, gold trim, red tongue |
| spider_queen | TD `tile_0122` (spider) | E | soot and plum body, add a 3 px gold crown |
| commander | TD `tile_0096` (knight) | E | add a red plume and cape, gold trim |
| dragon | — | **from scratch** | boss; see the Nathan list |
| needleback | 1B (31,8) (shelled beast) | E | add 5–6 spines along the back; bronze and soot |
| gelatinous_cube | — | **from scratch** | see the Nathan list |
| gargoyle | 1B (27,2) (horned demon) | E | stone ramp, add folded wing stubs |
| harpy | — | **from scratch** | see the Nathan list |
| kobold_trapper | 1B (26,2) (small goblin) | E | rust-orange scales, add a rope coil |
| clockwork_knight | TD `tile_0096` (knight) | E | brass `#B8733A`/`#7A4E2B` armour, add a 3 px wind-up key on the back |
| basilisk | 1B (29,8) (toothy reptile) | R | olive-green scales, gold eye |
| hollow | 1B (24,8) (empty outline figure) | R | soot fill at 60 %, dim outline, no face |
| beggar | TD `tile_0085` (peasant) | E | patched rags (dim/edge), add a tin cup |
| wick | 1B (3,15) (candle) | E | add a face; parchment wax, torch-orange flame |
| anvil | TD `tile_0074` (anvil) | E | add an angry brow and eyes (soot); steel ramp |

Totals: 29 of 35 items and 25 of 29 monsters have a CC0 base (R or E). The other 10, plus Nib's final sheet, are on the from-scratch list.

## From scratch — Nathan to decide (Aseprite $19.99 or PixelLab)
| Asset | Why there's no base | Notes for whoever draws it |
|---|---|---|
| echo_bell | no bell in TD, 1B or 0x72 | gold bell + 2 parchment sound arcs |
| quiet_bell | same | the same bell in soot/dim, wrapped in cloth, with no arcs |
| iron_chain | no chain tile | 3–4 interlocked steel links, diagonal |
| last_match | only a candle exists | thin wood stick, torch-orange head, 2 px flame |
| measuring_tape | none | round bronze case, parchment tape tongue with tick marks |
| mute_stone | none | smooth soot-grey pebble, with a plum "hush" rune |
| leech_league | none | 2–3 soot-red leeches in a cluster |
| gelatinous_cube | none (TD slime is round) | translucent poison-green cube, with a bone or coin floating inside |
| harpy | only plain birds | bird body with a parchment face, bronze wings |
| dragon | 16 px bases are too weak for a boss | worth a 32×32 portrait for Inspect, plus a 16×16 seat sprite |
| Nib (final) | the draft sheet exists | 16×16 idle (4 frames) + smug + talk, plus a 32×32 portrait. Imp green stays exclusive to Nib |
| Damsel in Distress | **on hold** | — |

Rough effort: the 11 from-scratch assets (10 + Nib) are about 4–6 hours in Aseprite (or a PixelLab pass plus cleanup). The 54 R/E assets are about 8–10 hours of recolouring, and can be done in free tools ([Pixelorama](https://orama-interactive.itch.io/pixelorama) or [LibreSprite](https://libresprite.github.io/)).

## CREDITS.md lines (suggested)
- "Kenney Tiny Dungeon and 1-Bit Pack by Kenney (kenney.nl), CC0 1.0."
- "16x16 DungeonTileset II by 0x72, CC0." (only if used)
