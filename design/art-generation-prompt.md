# Original art generation prompt — Swipe / Boss Rush

Paste this whole file into an image model that can emit PNG and SVG. It already plays in Godot 4. The job is to **replace every borrowed sprite** (0x72 DungeonTileset II, Kenney packs, Jetrel, Shade, HomoHikka, Flare, Lucide) with original art that drops into the same filenames and sizes.

Do not invent new cards, screens, or UI chrome. Draw the objects named below. Matching the named object matters more than matching any existing pack’s style.

---

## 1. Who you are and what “done” means

You are the sole artist for a small mouse-driven dungeon game. One player. An eight-slice wheel of monsters. A hotbar of item cards. Pixel art, nearest-neighbor scale, dark hall, parchment UI.

**Done** means a complete original set: every item, every monster, the hall tiles, the UI plates and buttons, the HUD marks, the hit particles, the cursors, the tutorial speaker, and the app icon. No two cards share the same pixels. No photograph. No copy of Kenney / 0x72 / Lucide.

You may emit SVG where this spec says SVG, and PNG everywhere else.

---

## 2. Engine and how the picture is shown

- Engine: Godot 4.7. Viewport **1680×1040**. Clear color `#1a1714`.
- Stretch: `canvas_items`, aspect `expand`.
- Filter: **nearest neighbor**. No mipmaps. No bilinear. No drop shadow baked into sprites.
- Item card icon box: **52×52** px on a 118×162 card.
- Wheel portrait: about **50–70** px square, upright, no numbers on the sprite (Attack and HP sit beside it).
- Combat portrait: drawn into **112×124** on a 168×128 stage, slight idle bob, lunge 22 px.
- Walk / fly courier: **96×96**.
- Ability outburst: portrait **112×112** inside a 168×128 plate.
- Tutorial speaker face: **64×112** (taller than wide).
- Trophy plaque skull: **36×36**.
- Hub hearts: **13×12** source, drawn larger on the hub (max 6 hearts).
- Floor / wall tiles: drawn at **48×48** from a 16×16 (or 64×64) source.

Sprites must read at those on-screen sizes. A 16×16 with a 1 px outline and a clear silhouette is the right density. Do not fill the frame with noise.

---

## 3. Master technical spec (every PNG)

### Canvas and scale

Author at native pixel size, then ship a **4× nearest-neighbor** PNG (so 16×16 becomes 64×64). Godot will scale from there with nearest.

| Kind | Author pixels | Ship PNG | Notes |
|---|---|---|---|
| Item icon | 16×16 | **64×64** | Subject centered. 1 px dark outline. 1 px padding from edges. Transparent ground. |
| Small monster (goblin-scale) | 16×16 or 16×20 | **64×64** or **64×80** | Feet at bottom. Face readable at 52 px. |
| Standard monster | 16×28 | **64×112** | Same as 0x72 humanoids (16×28). |
| Large monster (ogre / dragon / golem) | 32×36 | **128×144** | Still pixel. Not a second art style. |
| Floor / wall / banner / door tile | 16×16 | **64×64** | Tileable where noted. |
| Column | 16×48 | **64×192** | Tall. |
| Crate | 16×24 | **64×96** | |
| Hub heart | 13×12 | **13×12** (no upscale) | Keep this odd size; the atlas already uses it. |
| Kenney-shaped long button | 190×49 up, 190×45 pressed | same | 9-slice. |
| Round button | 35×38 | same | |
| Panel (9-slice) | 100×100 | same | |
| Inset panel | 93×94 | same | |
| Cursor hand | 27×28 | same | Hotspot top-left-ish. |
| Cursor sword | 34×37 | same | |
| Cursor gauntlet | 30×30 | same | |
| VFX stamp | 256×256 (white on transparent) | same | Game tints these. |
| App icon | SVG 128×128 | `icon.svg` | |

Do **not** ship 1024×1024 photographs. Several current files are that size and must be replaced.

### File format

- PNG, 8-bit RGBA, **transparent background**. No matte, no checker, no baked card frame, no ATK/HP numbers, no nameplate.
- Indexed PNG is fine if the palette is yours. Prefer RGBA.
- No JPEG. No lossy compression that smears pixels.
- Valid PNG header. Not a renamed JPEG. Godot rejects corrupt PNGs (`ERR_FILE_CORRUPT`).
- SVG: plain SVG 1.1, viewBox set, no embedded raster, no external fonts. Stroke + fill only. Lucide-like simplicity is fine; do not copy Lucide paths.

### Palette (lock this)

Work inside this dungeon ink. You may add 4–6 extra hues per sprite for the object (green glass, wet blood, rust) but the world stays brown-gold-parchment.

| Role | Hex |
|---|---|
| Void / clear | `#1a1714` |
| Floor dark | `#0a0807` |
| Ink on parchment | `#1c120c` |
| Body text | `#f0e6d8` / `#f4ede3` |
| Dim text | `#c9b9a8` / `#9a8b78` |
| Gold metal (tier 3 / deadly) | `#e8c36a` |
| Gold dim | `#c4a574` |
| Silver metal (tier 2 / tough) | `#c5cdd8` / `#8a96a8` |
| Bronze metal (tier 1 / weak) | `#c08050` |
| Outline | `#100e0c` / `#1a120e` |
| Attack card fill | `#5c2626` |
| Block card fill | `#1c3d52` |
| Heal card fill | `#243a22` |
| Defeat card fill | `#3a2450` |
| Utility card fill | `#4a3d14` |
| Smoke card fill | `#3a2a38` |
| Chaos card fill | `#3a1460` |
| Speech paper | `#f7ecda` |
| Blood | `#8a1818` |
| Bleed/purple | `#5c1a6a` |
| Block burst | `#5aa8e8` |

Pixel outlines: 1 px of `#100e0c` or `#1a120e`. No thick comic outlines. No glow.

### Style rules

- 16-bit dungeon pixel art. Side-or-three-quarter view for creatures (they stand in a circle, facing the player). Items are **icons of the object**, three-quarter or profile, not a photo of a product.
- One world. One light: warm from above-left. Recessed hall, not a bright overworld.
- Silhouette first. If you squint to 52 px and cannot name the object, redraw.
- No photoreal. No AI-photo texture. No painterly blur. No drop shadows under feet unless they are 2–3 px of the void color.
- No text on sprites except the app icon if you put a mark there (prefer no letters).
- **Uniqueness (hard):** every item id and every monster id must be a different picture. Not a recolor. Not a flip. Two drink vessels must be different shapes (flask vs goblet vs jar vs vial). Left Bracer and Right Bracer must be mirrored and still tell left from right. Echo Bell and Quiet Bell are two different bells. Chain is a chain, not a spear. Net is a net, not a spear. Hook is a hook.
- **Identity (hard):** the filename and the display name name the object. A torch for a chain is wrong. A flask for a helmet is wrong.

### Animation (monsters)

If you can emit frame strips, do this. If you only emit stills, one PNG per monster is enough (the game already falls back to a still for idle and run).

- Idle: **4 frames**, looping, ~6 fps. Breath / sway only.
- Run / lunge: **4 frames**, ~10 fps. Used on the 96×96 courier walk and the combat lunge.
- Optional hit: 1 frame (flash overlay is code).
- Mimic: 3-frame “open” is nice (chest → teeth). Not required.
- Fountain (hall): 3 frames.
- Chest (hall prop): 3-frame open.
- Tutorial speaker (Nib): 4 idle frames, unique face, **not** the Goblin.

Strip layout if you deliver a sheet: frames left to right, no padding, same frame size. Name `id_idle_0.png` … `id_idle_3.png` and `id_run_0.png` … `id_run_3.png`. Until the engine is wired for extra-PNG sequences, also ship `id.png` as frame 0.

---

## 4. Where files go (do not rename ids)

Internal **ids are frozen**. Display names can differ. The PNG basename should match the id, not the display name, except where the repo already uses a different filename (listed).

```
assets/dungeon/items/{id or mapped name}.png
assets/dungeon/extra/{id or mapped name}.png     # monsters
assets/dungeon/ui/{existing Kenney names}.png
assets/dungeon/vfx/{key}.png
assets/icons/{glyph}.svg                         # HUD marks
assets/icons/heart_full.png
assets/icons/heart_empty.png
icon.svg                                         # project icon
```

Mapped filenames that are **not** the id:

| id | File |
|---|---|
| `da_boot` | `items/boot.png` |
| `bloody_gauntlets` | `items/gauntlets.png` |
| `pocketwatch` | `items/watch.png` |
| `spider_queen` | `extra/spider.png` |
| `two_headed_serpent` | `extra/damsel.png` |
| `hollow` | `extra/hollow.png` (display name is Twins) |

Hall tiles currently live as named slices on `assets/dungeon/atlas.png` (512×512), plus `atlas_floor.png` (112×112) and `atlas_walls.png` (192×64). Prefer **separate 64×64 PNGs** named after the slice (`floor_1.png`, `wall_mid.png`, …). The producer will re-atlas or load extras. If you must ship one sheet, keep 16×16 cells, 1 px gap none, document the cell map.

---

## 5. Item icons — one original PNG each

Draw the **named object**. Ability text is flavor for pose and wear, not a second object in the icon.

Retired ids (`caltrops`, `dagger`, `helmet_hidden`, `bandana`) — skip unless you are filling leftover files.

| id | Display name | Draw this | Card job color (backdrop is code, not the PNG) |
|---|---|---|---|
| `throwing_knife` | Throwing Knife | Single throwing knife, point down-right. Not a sword. | attack red |
| `shield` | Shield | Heater or round shield. Face visible. | block blue |
| `sai` | Sai | Pair of sai / two prongs. Not a straight sword. | attack |
| `medallion` | Medallion | Worn medallion on a short chain. Jewelry, not a flask. | block |
| `helmet` | Helmet | Closed or nasal helmet. Not a bottle. | block |
| `da_boot` | The Boot | One sturdy leather boot. | defeat purple |
| `bloody_gauntlets` | Bloody Wraps | Hands / knuckle wraps with blood, not plate gauntlets if you can help it — wraps. | attack |
| `bracers` | Right Bracer | Right-arm bracer, opening on the left of the sprite. | block |
| `left_bracer` | Left Bracer | Left-arm bracer, mirrored composition. Must not be a recolor of Right Bracer. | block |
| `knucklers` | Knucklers | Brass knuckles. | attack |
| `spiked_flail` | Spiked Flail | Flail head with spikes + short chain. | attack |
| `sledgehammer` | Sledgehammer | Two-handed sledge, heavy head. | defeat |
| `grimoire` | Grimoire | Closed spellbook, clasp. | attack |
| `breastplate` | Breastplate | Torso plate. Not a shield. | block |
| `smoke_bomb` | Smoke Bomb | Round bomb, fuse, wisp of smoke. | smoke |
| `fangs` | Fangs | Two teeth / a fang charm. Not a cleaver. | defeat |
| `poison_flask` | Poison Flask | Small green vial, different silhouette from Healing Potion. | utility |
| `healing_potion` | Healing Potion | Red potion bottle (classic round flask). | heal |
| `crossbow` | Crossbow | Crossbow with prod. Not a longbow. | attack |
| `pocketwatch` | Pocketwatch | Open pocket watch, face readable as a clock at 16 px. | attack |
| `double_axe` | Double Axe | Double-bitted axe. | attack |
| `victory_flask` | Victory Flask | **Gold goblet / cup**, not a bottle. Must not be a recolor of Healing Potion. | heal |
| `grappling_hook` | Grappling Hook | Hook + rope coil. Not a spear. | utility |
| `spiked_shield` | Spiked Shield | Shield with spikes. Different from `shield`. | block |
| `grief_jar` | Grief Jar | Sealed jar / urn. Fourth vessel, not a flask. | block |
| `longbow` | Longbow | Unstrung or strung longbow. Not a crossbow. | attack |
| `lantern` | Lantern | Hooded lantern, warm glass. | heal |
| `mirror_shard` | Mirror Shard | Jagged mirror fragment, a glint. | block |
| `echo_bell` | Echo Bell | Hand bell. | chaos |
| `quiet_bell` | Quiet Bell | Different bell (muted / wrapped clapper). | utility |
| `net` | Net | Weighted throwing net. Not a spear. | utility |
| `iron_chain` | Chain | Length of iron chain. Not a torch or spear. | attack |
| `counting_beads` | Counting Beads | String of beads / prayer beads. | attack |
| `last_match` | Paci Fist | A fist / palm-strike charm (display name is Paci Fist; id stays `last_match`). Not a matchstick unless you put a fist around it. | defeat |
| `measuring_tape` | Scythe | **Scythe** (display name is Scythe; id stays `measuring_tape`). | defeat |
| `mute_stone` | Chaos Stone | Faceted chaotic gem / stone. | chaos |
| `cursed_scroll` | Cursed Scroll | Rolled or open cursed scroll. | heal |
| `spider_egg` | Spider Egg | Glossy egg, maybe a tiny spider mark. | egg (near-black card) |
| `arrow_head` | Arrow Head | Arrowhead / bodkin. | attack |
| `danger_magnet` | Danger Magnet | Horseshoe magnet, ominous. | utility |

Also used as a mark on cards (not a separate card, but needs the same item PNG): `echo_bell` overlay 28×28. Petrify overlay is UI (`petrify_stone.png`), a grey stone over the icon.

---

## 6. Monster portraits — one original PNG each (plus frames if you can)

Creatures stand in a stone wheel. Three-quarter or front. Readable face. No attack/HP painted on.

| id | Display name | Draw this | Notes |
|---|---|---|---|
| `wizard` | Wizard | Human mage, hat or focus, not a recolor of Cleric. | Currently atlas `wizzard_m`. |
| `golem` | Golem | Stone or clay giant. Large frame OK. | Currently `big_zombie` stand-in. |
| `goblin` | Goblin | Goblin. Tutorial speaker must **not** reuse this. | 16×16 is fine. |
| `skeleton` | Skeleton | Skeleton. Trophy uses a skull **derived from or matching** this, 16×16 crop. | |
| `hornet_swarm` | Hornet Swarm | Cluster of hornets / wasps, not a lone imp. | |
| `lich` | Lich | Undead caster, distinct from Wizard. | |
| `ogre` | Ogre | Big brute. Large frame OK. | |
| `vampire` | Vampire | Vampire. Fangs optional; cape / pale face. | |
| `berserker` | Berserker | Rage warrior. Not the same as Bandit. | |
| `dire_wolf` | Dire Wolf | Wolf. Four legs. | |
| `bandit` | Bandit | Masked thief. | |
| `two_headed_serpent` | Damsel in Distress | Distressed person (file `damsel.png`). Not a snake unless you add a tiny serpent motif. The **card is this person**. | |
| `slime_boss` | Slime Boss | Large slime. | |
| `leech_league` | Leech League | Leech, or a pack of leeches. | |
| `wraith` | Wraith | Ghost / wraith. Translucent is OK if pixels stay chunky. | |
| `mimic` | Mimic | Chest with teeth. | |
| `spider_queen` | Spider Queen | Spider (file `spider.png`). | |
| `commander` | Commander | War leader. Distinct from Berserker and Bandit. | |
| `dragon` | Dragon | Dragon. Large frame OK. | |
| `needleback` | Needleback | Porcupine / quilled beast. | |
| `gelatinous_cube` | Gelatinous Cube | Cube of jelly, maybe a bone inside. | |
| `gargoyle` | Gargoyle | Stone winged grotesque. | |
| `harpy` | Harpy | Winged woman-bird. | |
| `kobold_trapper` | Kobold Trapper | Small lizard-person with a snare. | |
| `clockwork_knight` | Clockwork Knight | Armor with gears. | |
| `basilisk` | Basilisk | Lizard / cockatrice-basilisk. | |
| `hollow` | Twins | **Two** small figures. The card is twins. | |
| `beggar` | Beggar | Ragged person, bowl or palm. Unique vs Damsel. | |
| `wick` | Wick | Living candle / wick-person. | |
| `anvil` | Anvil | Living anvil, or a smith-creature fused to an anvil. The object “anvil” must be obvious. | |
| `bodyguard` | Bodyguard | Shield-bearer. Unique vs `shield` item. | |
| `cowardly_king` | Cowardly King | Crowned, fearful, royal robe. | |
| `merchant` | Merchant | Trader, satchel or scale. | |
| `juggernaut` | Juggernaut | Heavy armored bruiser. Unique vs Golem and Clockwork Knight. | Currently missing extra PNG. |
| `cleric` | Cleric | Holy healer. Unique vs Wizard. | Currently missing extra PNG. |

**Tutorial speaker (Nib)**  
Unique impish fence / guide. 4 idle frames. Taller portrait (author 16×28). Must not be Goblin, Beggar, or Merchant. Ship as `assets/dungeon/extra/nib.png` (producer will point the tutorial at it).

---

## 7. Hall tiles (replace the 0x72 atlas)

All 16×16 author / 64×64 ship unless noted. Same pixel world as the cards. Dark, desaturated. The game already multiplies tiles by a brown-grey modulate, so paint them a bit lighter than the void.

**Floors** (must tile on a 16×16 grid, 8 variants):  
`floor_1` … `floor_8`

**Walls:**  
`wall_top_left`, `wall_top_mid`, `wall_mid`

**Banners:**  
`wall_banner_red`, `wall_banner_yellow` (blue/green optional)

**Props:**  
`column` (16×48), `crate` (16×24), `skull` (16×16 — also trophy), `chest_full_open_anim_f0` plus f1 f2 if you animate.

**Torch / fountain flicker (3 frames):**  
`wall_fountain_mid_red_anim_f0` f1 f2

**Hearts (hub):**  
`ui_heart_full`, `ui_heart_empty` at **13×12**. Also replace `assets/icons/heart_full.png` and `heart_empty.png` with the same pixels. Optional `ui_heart_half`.

---

## 8. UI chrome (replace Kenney RPG UI)

Keep **exact pixel dimensions** so 9-slice margins in code still work.

**Long buttons** (190×49; pressed 190×45):  
`buttonLong_brown`, `buttonLong_brown_pressed`, `buttonLong_beige`, `buttonLong_beige_pressed`, `buttonLong_blue`, `buttonLong_blue_pressed`, `buttonLong_grey`, `buttonLong_grey_pressed`

9-slice margins the game uses: left/right **20**, top **10**, bottom **12**. Put the ornament in the corners; the center must be a flat stretch.

**Round buttons** 35×38: beige, blue, brown, grey.

**Panels** 100×100, 9-slice ~12–16 px corners:  
`panel_brown`, `panel_beige`, `panel_beigeLight`, `panel_blue`

**Inset panels** 93×94:  
`panelInset_brown`, `panelInset_beige`, `panelInset_beigeLight`, `panelInset_blue`

**Cursors:**  
`cursorHand_beige` (default), plus grey/blue variants; `cursorSword_gold` (used on the wheel), bronze, silver; `cursorGauntlet_*`.

**Petrify overlay:** `petrify_stone.png` 64×64 (author 16×16). Grey stone that can sit on top of an item icon.

**Bars** (optional — files exist, little code uses them today): 9×18 caps + 18×18 mids, colors red / green / blue / yellow / back, horizontal and vertical. Replace if you are wiping the Kenney folder.

Look: carved oak, parchment, gold leaf. Not sci-fi. Not candy. Pressed state is the same art inset 2–4 px.

---

## 9. VFX stamps (replace Kenney particles)

White (or light grey) on **transparent**. The game tints them.

Ship 256×256 PNG, subject in the middle, lots of empty alpha.

| Game key | Current file | Draw |
|---|---|---|
| `star` | `star_08.png` | Impact star / spark burst |
| `star2` | `star_04.png` | Smaller star |
| `spark` | `spark_05.png` | Sparks |
| `spark2` | `spark_06.png` | Sparks variant |
| `circle` | `circle_05.png` | Soft ring |
| `smoke` | `smoke_08.png` | Puff |
| `magic` | `magic_05.png` | Magic flare |
| `fire` | `fire_02.png` | Fire burst |
| `flame` | `flame_02.png` | Torch flame (also hall glow) |
| `dirt` | `dirt_01.png` | Dust |
| `twirl` | `twirl_03.png` | Swirl (block / hypnotize) |

Unused leftovers you may replace or omit: `star_01`, `star_02`, `magic_01`, `smoke_06`, `trace_01`.

---

## 10. HUD glyphs — SVG

Simple 24×24 viewBox, 2 px stroke, round caps. Fill + stroke in `#c4a574` gold, except heart (`#c45c5c`) and ban (ink `#f0e6d8` on a slash). No Lucide path copies — original geometry.

These sit on the wheel as tiny marks and as fallbacks. They must read at ~18 px.

| File | Meaning |
|---|---|
| `heart.svg` | Player HP |
| `sword.svg` | Attack |
| `shield.svg` | Block |
| `plus.svg` | Empty alcove / add |
| `rotate.svg` | Spin / cycle |
| `ban.svg` | Forbidden / mute / pierce |
| `copy.svg` | Copy / echo |
| `swords.svg` | Double hit |
| `users.svg` | Group / neighbors |
| `link.svg` | Bond / chain / thorns |
| `sparkles.svg` | Magic / smoke / swarm |
| `droplet.svg` | Potion / siphon |
| `hammer.svg` | Heavy hit |
| `mountain.svg` | Heavy / stone |
| `wand.svg` | Caster |
| `skull.svg` | Death / trophy-ish |
| `footprints.svg` | Move / flee |
| `trending.svg` | Rising stat |
| `layers.svg` | Pack / items |
| `palm.svg` | Palm / fist |

`icon.svg` (project): 128×128. Dark `#1a1714` field, gold ring, four cardinal pips (the wheel). No letters required.

---

## 11. How to generate (batches)

Work in this order. After each batch, check uniqueness (no two PNGs share a pixel hash) and silhouette at 52 px.

1. **Art bible sheet** — one 256×256 master: floor, wall, gold rim, one item (Shield), one monster (Goblin), one button. Lock the look.
2. **All item PNGs** (live + todo rows in §5).
3. **All monster PNGs** (§6), including Nib, Juggernaut, Cleric.
4. **Hall tiles + hearts.**
5. **UI panels, buttons, cursors, petrify stone.**
6. **VFX.**
7. **SVG glyphs + app icon.**

For each PNG, think: object name, 16×16, 1 px outline, transparent, nearest 4× to ship size, no text.

Prompt pattern per asset (repeat):

> 16-bit pixel icon of [OBJECT] for a dark fantasy dungeon game. 16×16 pixels, then scaled 4× with nearest neighbor to [SHIP SIZE]. Transparent background. 1-pixel `#100e0c` outline. Centered. Warm light from above-left. Palette locked to dungeon brown, parchment, gold `#e8c36a`, bronze `#c08050`. No photorealism, no text, no card frame, no drop shadow. Distinct silhouette. [ONE UNIQUE DETAIL].

---

## 12. What not to do

- Do not copy 0x72, Kenney Tiny Dungeon, Kenney UI, Kenney particles, Jetrel, Lucide, or any CC0 pack you remember.
- Do not reuse one body with a hat swap for two monsters.
- Do not draw Victory Flask as Healing Potion in gold.
- Do not draw Chain / Net / Hook as a spear or torch.
- Do not put Attack, HP, or the display name on the sprite.
- Do not deliver 1024×1024, 512×512 item icons, or photos.
- Do not change ids or invent extra cards.
- Do not style-match “cute chibi” or “oil painting.” Pixel dungeon, readable, a little grim.

---

## 13. Return format

A zip (or folder) whose paths match §4. Plus a one-page manifest:

```
filename  author_px  ship_px  id  notes
```

Call out anything you skipped. If a display name and an id disagree, **id wins** for the filename; the picture still shows the display-name object (`measuring_tape` → scythe, `two_headed_serpent` → damsel, `last_match` → fist).
