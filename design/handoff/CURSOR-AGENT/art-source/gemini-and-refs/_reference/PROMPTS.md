# Spinheritance prompt pack

Batch order: **Gemini** (§1 still, §3 sprites, §4 monsters) → **PixelLab** (§2 logo dot, §5 items). One chat per section; paste the preamble once at the top of each new chat.

## Style preamble (paste once per chat)

```
You are making game art for "Spinheritance", a dark-fantasy dungeon boss-rush game. Style "Crypt Classic": crisp retro pixel art like a 16-bit SNES/GBA game. Every art pixel is a perfectly square, hard-edged block of one flat colour, all on one consistent pixel grid. Characters have a 1-pixel near-black outline (#100e0c). Each material uses a 3-4 tone colour ramp, lit from the upper-left. No anti-aliasing, no blur, no gradients, no soft glow, no dithering noise, no painterly texture, no photorealism, no 3D render look. Torchlit gold is #FFD84A (light #fff3d6, shadow #b8733a/#7a4e2b). Use the attached palette swatch as the colour limit. Never draw any text, letters, numbers, signatures or watermarks. Match the attached in-game sprites' design exactly; you may add detail but not change the design.
```

Background convention for sprites (§3-§5): flat solid magenta `#FF00FF`, nothing else, so Pixel can key it out.

---

## §1 Title still v3 — `title_still.png` (Gemini, backup ChatGPT)

- Target native: **420×260** (shipped 1680×1040, 4× nearest). Opaque. 1 frame.
- Ask for a wide landscape image (16:10 if offered, else 16:9 and keep the edges unimportant). Big output is fine; Pixel downsamples.
- Attach refs (in this order): `08_title_still_v2_shipped.png`, `01_sprout_ingame_x8.png`, `02_sprout_ingame_run_grab_throw_x8.png`, `11_still_artifacts_ingame_x8.png`, `12_still_monsters_ingame_x6.png`, `05_grandpa_portrait_hat_x6.png`, `06_grandpa_sack_trunk_x8.png`, `07_palette_swatches.png`. (Gemini takes several images per message; if it caps you, drop 06 and 02 first.)
- Save as: `returns\title_still_v3_raw.png` (alternates `_a`, `_b`).

**Prompt**

```
Make the title screen illustration for Spinheritance, a wide landscape pixel-art painting at a native resolution of about 420x260 art pixels (each art pixel a big crisp square). Use image 1 (the current title art) for the overall layout and night palette, but redraw it as version 3 with the changes below.

Composition, "the Loot River": night. Mount Grumblegut fills the back, dark blue-grey under a starry sky. In its side a huge cave mouth with stone teeth glows torch-gold from inside. Out of the mouth a river of treasure pours down toward the lower left like a waterfall turning into a stream.

The treasure is NOT a messy pile. It is 8 big, clearly separate, readable hero artifacts riding the river, each 2-3 times larger than a coin, with a thin light stream of gold coins flowing behind them:
1 a gold pocketwatch on a chain, 2 a black iron lantern with a lit flame, 3 a red leather grimoire with a gold clasp, 4 a round red healing potion with a green cork, 5 a great double-bladed axe with red-steel blades, 6 a silver-and-gold chakram ring blade, 7 a gold blood chalice brimming red, 8 a big lucky nickel coin (silver rim, green emblem in the middle) leading the coin stream.
Match the designs in image 4 (left to right in the same order), just larger and more detailed.

The hero, Sprout, a small goblin, stands on a rock ledge in the upper-left third, leaning forward and reaching one green hand out toward the nearest artifact, mouth open in greedy delight. Sprout must be the SAME character as images 2 and 3: green skin, long pointed ears, big pointed nose, teal hooded cloak, red scarf/belt, burlap loot sack on the back, small and stocky. Draw Sprout at higher fidelity (about 48-64 art pixels tall) but keep that exact design and colours.

Monsters line both banks of the river, all facing RIGHT toward the mountain mouth and the loot, each with a big expressive face and attitude, distinct silhouettes, based on image 5: a sneering green goblin, a snarling grey dire wolf, a grinning skeleton with a dagger, a huge green ogre with a club on his shoulder, a buzzing hornet swarm, a purple spider queen with a gold crown, a wooden mimic chest with a tongue out, a grey stone gargoyle, a smug purple wizard-hat magicat, a blue poison frog puffing its throat, a crowned lich in grey robes. Vary their sizes; the ogre and spider queen are the biggest. From the right edge a giant red dragon claw reaches in, talons spread, grabbing at the treasure (claw and part of the arm only).

Grandpa is shown only by his objects, never as a living figure: his cream safari pith helmet with a red band tumbling in the river, his gold-framed portrait (image 6, same moustache and helmet) leaning on a rock by the bank, and his burlap sack (image 7) spilling coins.

Lower-left: a small translucent ghostly cabin on a hill, pale blue and see-through, with one warm window.

Layout rules: keep the centre of the image (the middle third, from about 25% to 75% down) calm and low-detail: dark river, coins, no faces there, because buttons appear over it later. Keep the top band (top 30%) mostly sky and mountain with clear space in the middle for a logo. Put Sprout and the strongest faces in the upper-left, the outer left and right thirds, and the lower corners.

No text, no letters, no UI, no border, no logo. Opaque background. Crisp hard pixels, 1px dark outlines on characters and artifacts, light from the upper-left, gold #FFD84A highlights.
```

**Fix-up replies** (same chat, one at a time, only if needed):
- `Keep everything, but make the 8 artifacts bigger and more separate; fewer loose coins.`
- `Keep everything, but make Sprout match image 2 exactly: teal hood, red scarf, sack on back, facing right.`
- `Keep everything, but turn every monster to face right and give each a stronger facial expression.`
- `Keep everything, but clear the middle of the picture: no faces between 25% and 75% height in the centre.`
- `Make it look more like true pixel art: bigger, flatter square pixels, no blur or gradients.`

**Backup (ChatGPT Images):** same refs (upload 08, 01, 11, 12, 05 at minimum), paste the preamble and the prompt in one message, add `Landscape aspect ratio.` at the end.

---

## §2 Logo i-dot wheel (PixelLab, backup Gemini)

Pixel keeps the hand-set "Spinheritance" letters from logo C (`09_logo_C_current_x4.png`), makes the roulette-looking **p** a plain gold p, and swaps in this wheel as the **dot of the i**. No AI lettering. Final `logo.png`: max 210×44 native (840×176 shipped), gold `#FFD84A` face, 1px `#100e0c` outline.

- Target native: **16×16** (Pixel trims to ~11–12 px to sit on the i). Transparent. 1 frame. Generate 3–4 takes.
- PixelLab: Create image (S–M), size 16×16 (or 32×32 if 16 looks mushy), *no background* on, outline "single color black", shading "medium", view "front". Upload `10_wheel_hub_ingame_screenshot.png` as the style/init image if the tool offers it, plus `07c_palette_strip_x16.png`.
- Refs (for Gemini backup): `10_wheel_hub_ingame_screenshot.png`, `09_logo_C_current_x4.png`, `07_palette_swatches.png`.
- Save as: `returns\logo_idot_wheel_raw_a.png` (`_b`, `_c`…).

**PixelLab description**
```
tiny round stone dungeon wheel seen from above, like a castle floor plan: a round grey stone hub in the centre, 4 short corridors running out to an outer stone ring, small dark arched doorways in the ring with tiny glowing yellow monster eyes inside, gold #FFD84A rim highlight on the upper-left, 1px near-black outline, crisp pixel art icon, no text
```
Negative (if the field exists): `roulette, casino, gambling wheel, red and black segments, numbers, coins, dice, pointer, text`

**Gemini backup prompt** (after the preamble)
```
Draw ONE tiny icon: a round stone dungeon wheel seen from above, like a little castle floor plan, about 16x16 art pixels, shown very large with crisp square pixels. Round grey stone hub in the middle; 4 short dark corridors running outward to an outer ring of grey stone blocks; in that ring, small dark arched doorways with pairs of tiny glowing yellow eyes peeking out (monsters waiting). Thin gold #FFD84A highlight on the upper-left rim, darker stone on the lower-right, 1px near-black #100e0c outline. It must NOT look like a roulette wheel, casino wheel, prize wheel or clock: no red/black wedges, no numbers, no pointer, no spokes made of colour segments. Flat solid magenta #FF00FF background. No text. Image 1 shows the game's real stone wheel layout (hub in the centre, ring around it).
```

---

## §3 Sprout and Nib teaser sheets (Gemini, backup PixelLab)

One Gemini chat for all four. Attach `01_sprout_ingame_x8.png`, `02_sprout_ingame_run_grab_throw_x8.png`, `03_sprout_cabin_walk_x6.png`, `07_palette_swatches.png` once at the start (and `04` for Nib). Each block asks for one horizontal strip of equal cells.

Shared rules (already in each prompt): facing **right**, no flip; same size and colours in every frame; **feet on the bottom row of each cell, no empty rows below**; no shadow; magenta background; no text.

| Asset | Native per frame | Shipped | Frames | Layout | Save raw as | Final files (Pixel) |
|---|---|---|---|---|---|---|
| Sprout run | 48×48 | 192×192 | 4, loop ~70 ms | 1×4 strip | `returns\sprout_run_sheet_raw.png` | `sprout_run_f0..f3.png` |
| Sprout grab | 48×48 | 192×192 | 4, once | 1×4 strip | `returns\sprout_grab_sheet_raw.png` | `sprout_grab_f0..f3.png` |
| Sprout throw | 48×48 | 192×192 | 4, once | 1×4 strip | `returns\sprout_throw_sheet_raw.png` | `sprout_throw_f0..f3.png` |
| Nib lantern | 32×32 | 128×128 | 2, loop | 1×2 strip | `returns\nib_lantern_sheet_raw.png` | `nib_lantern_f0..f1.png` |

**3a Sprout run**
```
Sprite sheet: one horizontal strip of 4 equal square cells, each cell 48x48 art pixels, shown large with crisp square pixels. The character is Sprout, the goblin from images 1-3, drawn at higher fidelity but with the EXACT same design and colours: green skin, long pointed ears swept back, big pointed nose, yellow eye, teal hooded cloak, red scarf/belt, burlap loot sack bouncing on the back, small stocky body about 40 pixels tall. Side view facing RIGHT. A 4-frame running loop: f1 contact (front foot down), f2 passing (body lowest), f3 contact with the other foot, f4 passing high; ears and sack bounce one frame behind the body. Same size and same position in every cell; feet touch the very bottom row of each cell, no space under the feet, no ground shadow. Flat solid magenta #FF00FF background, no grid lines, no text.
```

**3b Sprout grab**
```
Same character, same sheet format (4 cells of 48x48, facing RIGHT, feet on the bottom row, magenta background). A one-shot grab: f1 reaches forward and up with one hand open toward something flying past at head height; f2 snatches it (hand closed on a small glinting gold object, eyes wide); f3 stuffs it over the shoulder into the sack on the back, grinning; f4 recovers to a ready running pose. Keep the cloak, scarf, sack and colours identical to images 1-3. No text.
```

**3c Sprout throw**
```
Same character, same sheet format (4 cells of 48x48, facing RIGHT, feet on the bottom row, magenta background). A one-shot backward throw while running away: f1 wind-up, twisting to look back over the shoulder with one arm cocked behind; f2 the arm whips back and releases (empty hand, motion blur NOT allowed, show it with pose only); f3 follow-through, body leaning forward, a cheeky grin; f4 recovers to the running pose. Do not draw the thrown object. Identical design and colours to images 1-3. No text.
```

**3d Nib with lantern** (attach `04_nib_ingame_and_lantern_x8.png`)
```
Sprite sheet: one horizontal strip of 2 equal cells, each 32x32 art pixels, crisp square pixels. The character is Nib from image 4: a small blue imp with little horns, pointed tail, a round monocle, and a mustard-yellow coat. Nib stands planted, facing RIGHT, holding up a small black iron lantern with a warm yellow flame in one hand, the same lantern as in image 4. f1 and f2 are an idle loop: in f2 the flame is a bit taller/brighter and Nib's tail flicks; body otherwise identical. Feet on the bottom row of each cell, no shadow, flat magenta #FF00FF background, no text.
```

**Backup (PixelLab, per frame):** Create image, 48×48 (Nib 32×32), no background, view "side", direction "east", upload `01_sprout_ingame_x8.png` as init/style image, description e.g. `small green goblin with teal hooded cloak, red scarf and burlap sack on back, running, facing right`. One generation per pose; name `returns\sprout_run_f0_raw.png` etc.

---

## §4 Monster run sheets (Gemini, backup ChatGPT Images)

One Gemini chat. Attach `14_teaser_monsters_ingame_x6.png` and `07_palette_swatches.png` once; for each monster also attach its single ref. Every sheet: 1×4 strip, 4-frame **run/chase loop**, facing **right** (chasing the hero), feet/lowest point on the bottom row of each cell, magenta background, no text. These must read as the same creature as the card art but be a new, more expressive drawing (not a recolour).

Template (paste the preamble once, then this with the bracketed bits filled from the table):
```
Sprite sheet: one horizontal strip of 4 equal square cells, each [SIZE]x[SIZE] art pixels, shown large with crisp square pixels. The monster is the [NAME] from the attached reference, redrawn bigger and more expressive but with the same design and colours: [LOOK]. Side view facing RIGHT, chasing something greedily. A 4-frame looping run cycle: [MOTION]. Big readable face with attitude: [ATTITUDE]. Same size and position in every cell, lowest point touching the bottom row of each cell, no ground shadow. Flat solid magenta #FF00FF background, no grid lines, no text.
```

| # | Monster | Ref | [SIZE] native / shipped | [LOOK] | [MOTION] | [ATTITUDE] | Save raw as | Final files |
|---|---|---|---|---|---|---|---|---|
| 4a | goblin | `40_mon_goblin_x16` | 32 / 128 | green goblin, huge pointed ears, yellow eyes, underbite fangs, brown loincloth | scrappy sprint, arms pumping | sneering, tongue out | `returns\mon_goblin_sheet_raw.png` | `mon_goblin_f0..f3.png` |
| 4b | dire wolf | `41_mon_dire_wolf_x16` | 32 / 128 | big grey wolf, dark grey back, pale muzzle, yellow eyes | 4-leg gallop, stretched then bunched | snarling, teeth bared, ears back | `returns\mon_dire_wolf_sheet_raw.png` | `mon_dire_wolf_f0..f3.png` |
| 4c | skeleton | `42_mon_skeleton_x8` | 32 / 128 | bone-white skeleton, cyan glowing eye sockets, small rusty dagger | clattering run, dagger raised, jaw flapping | wide manic grin | `returns\mon_skeleton_sheet_raw.png` | `mon_skeleton_f0..f3.png` |
| 4d | ogre | `43_mon_ogre_x8` | 48 / 192 | huge green ogre, brown loincloth, wooden club on shoulder | heavy lumbering stomp, belly bouncing | angry underbite, drool | `returns\mon_ogre_sheet_raw.png` | `mon_ogre_f0..f3.png` |
| 4e | hornet swarm | `44_mon_hornet_swarm_x16` | 32 / 128 | a tight cluster of 4-5 yellow-and-black hornets with stingers | swarm drifts forward, hornets swap places, wings flicker | furious tiny eyes, all stingers pointing right | `returns\mon_hornet_swarm_sheet_raw.png` | `mon_hornet_swarm_f0..f3.png` |
| 4f | spider queen | `45_mon_spider_queen_x16` | 48 / 192 | dark purple spider, red hourglass marks, small gold crown | 8-leg scuttle, legs alternate in pairs | regal and hungry, many red eyes, fangs | `returns\mon_spider_queen_sheet_raw.png` | `mon_spider_queen_f0..f3.png` |
| 4g | dragon | `51_mon_dragon_x8` | 64 / 256 | red-orange dragon, cream belly, horned head, wings | low lunging run, wings half open and flapping | furious, smoke curling from nostrils, jaws open | `returns\mon_dragon_sheet_raw.png` | `mon_dragon_f0..f3.png` |

**Backup (ChatGPT Images):** upload the same two refs, paste preamble + filled template, add `Make the background transparent` instead of the magenta line if it works.

---

## §5 Teaser item floaters (PixelLab, backup Retro Diffusion)

These fly across the hall during the chase. **24×24 native, 96×96 shipped**, transparent, centred, 1 frame each (`_f1` optional: same item with a small gold sparkle/glint for a 2-frame twinkle). They must read as the same object as the card art but be a fresh drawing, not a recolour. (The title still's artifacts in §1 are drawn larger; that's fine.)

PixelLab settings for all 8: Create image, size **24×24** (if the tool refuses, 32×32 and Pixel trims), *no background* on, outline "single color black", shading "medium", detail "high", view "side". Upload `13_teaser_items_ingame_x8.png` as the style image, and the single ref listed as the init image if offered. One generation each; keep the best of 2 if you have the credits.

| # | id | Ref | PixelLab description | Save raw as | Final file(s) |
|---|---|---|---|---|---|
| 5a | pocketwatch | `20_item_pocketwatch_x16` | `gold pocket watch with cream clock face and black hands, chain loop on top, glint upper-left` | `returns\item_pocketwatch_raw.png` | `item_pocketwatch_f0.png` (+`_f1`) |
| 5b | lantern | `21_item_lantern_x16` | `small black iron lantern with handle, warm orange flame inside glass` | `returns\item_lantern_raw.png` | `item_lantern_f0.png` (+`_f1`) |
| 5c | grimoire | `22_item_grimoire_x16` | `thick red leather spellbook with gold clasp and gold corner plates` | `returns\item_grimoire_raw.png` | `item_grimoire_f0.png` (+`_f1`) |
| 5d | healing_potion | `23_item_healing_potion_x16` | `round glass flask of bright red potion with green cork and white shine` | `returns\item_healing_potion_raw.png` | `item_healing_potion_f0.png` (+`_f1`) |
| 5e | lucky_nickel | `24_item_lucky_nickel_x16` | `big silver coin with a green emblem in the middle, slightly tilted` | `returns\item_lucky_nickel_raw.png` | `item_lucky_nickel_f0.png` (+`_f1`) |
| 5f | sledgehammer | `25_item_sledgehammer_x16` | `heavy sledgehammer with purple-grey steel head and wrapped wooden handle, diagonal` | `returns\item_sledgehammer_raw.png` | `item_sledgehammer_f0.png` (+`_f1`) |
| 5g | da_boot | `26_item_da_boot_x16` | `single purple leather boot with brown sole, side view, toe pointing right` | `returns\item_da_boot_raw.png` | `item_da_boot_f0.png` (+`_f1`) |
| 5h | helmet | `27_item_helmet_x16` | `round blue steel knight helmet with dark T-shaped visor slit` | `returns\item_helmet_raw.png` | `item_helmet_f0.png` (+`_f1`) |

Negative (if supported): `text, letters, background, blurry, anti-aliased, gradient, soft shadow`

**Backup (Retro Diffusion):** RD Pro, style `rd_pro__default`, 24×24, remove background on, palette input `07b_palette_1px_strip.png`, same descriptions. ~$0.18 each, so the free balance covers only a few; use it only for items PixelLab misses.

**Gemini last resort for items:** one sheet prompt: `Sprite sheet of 8 separate items in a 4x2 grid of 24x24-pixel cells, in this order: [the 8 descriptions above]. Same pixel scale for all, each centred in its cell, magenta #FF00FF background, no text.` Save as `returns\items_sheet_raw.png`.

---

## Not in this pack
- **Bloom** (`bloom_f0..f2`): skipped. `title_teaser.gd` never loads it; the whiteout is a code flash.
- **Hill/hall strips**: already shipped (v2), nothing requested.

