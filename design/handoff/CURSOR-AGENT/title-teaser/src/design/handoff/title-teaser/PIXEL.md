# Pixel — title teaser (read this first)

You own the look of the whole boot cinematic: ~12 seconds of silent motion, then a title still. Code already has timing, skip, music, and Click to continue. It will load your files from `assets/dungeon/title/` when they exist.

## Ignore F5

What Nathan saw in Play is a **programmer dummy**: combat 16×16 cards, the 24px wheel hero, the tiled fight hall, a cabin room stretched as a “hill.” That is not the art direction. Do not match it. Do not tidy it. Replace it.

## Locked story (do not contradict)

Sprout is a small goblin. Grandpa **Lucky / Bartleby Snatchwick** died **inside Mount Grumblegut**. He left everything; everything is still in the mountain. The teaser is Sprout taking those things back. Monsters of the mountain want them. He has to **use or throw some loot to keep the rest**.

Nib appears once, at the cabin door, lantern in hand, and **does not follow**. The rainy knock / will cutscene is a different scene (Brand New). Do not paint that knock here.

No text boxes, captions, or speech in the motion. The still is the first words: title (once named) + tagline **Use it, Lose it, or Lose your head**.

## What you decide vs what is locked

Locked:

- Silent story above
- Beat order and roughly 12s (code: 0–2 threshold, 2–5 grab, 5–8.5 spend, 8.5–11 swirl, 11–13 whiteout)
- Camera: side-scroll, then swirl to center
- Hero faces **right** (into the mountain). No `flip_h`
- Tagline copy
- Click to continue is code, not paint
- Hub buttons are a second page on top of the still (dim). Keep the still’s faces out of the hub hole (see SCREEN)

You decide:

- Composition of the still (must still read inheritance + spend-to-keep + mountain)
- How many hall tints / props, as long as strips tile on X
- Pose language, silhouettes, which loot is in the air on the still
- Lettering **after** NAME.md is one word: Snatchwick (recommended) / Swipe / Everything

## Viewport and scale

- Game: **1680×1040**, nearest, integer 4×
- Native for full-bleed paintings and looping worlds: **420×260**
- Shipped: **1680×1040**
- Do not draw at 1680. Draw 420×260, we 4× it
- Floor line for motion strips: native **y = 161** (62% of 260), so Sprout’s feet match code (`hero_y = viewport.y * 0.62`)
- Pivot for characters: **centre of the feet** on that floor line, same idea as `assets/dungeon/hero_run/layout.json`

## Beats (what must read, not how to paint)

### 1. Threshold · 0–2s

Night. Cabin on Kettle Hill. The run door into the mountain is the way **forward**. Sprout runs **in**. Nib stands left with a lantern and stays. Combat music starts (you do not supply audio).

Layers code will scroll: `hill_strip.png` (seamless X). Sprites: `sprout_run_*`, `nib_lantern_*`.

### 2. Grab · 2–5s

Dungeon hall, side-scroll. Grandpa’s things float **ahead** (right). Sprout catches pocketwatch, lantern, grimoire, healing potion. He **misses** lucky nickel and sledgehammer (they pass him). Monsters enter from **behind** (left): goblin, dire wolf, skeleton first.

Layers: `hall_strip.png` (or `hall_strip_b.png` if you supply a second tile). Sprites: items + monsters below.

### 3. Spend to keep · 5–8.5s

Chase tightens. Sprout **uses** the Boot into a monster, then the Helmet to live. Those two sprites **leave the screen** (they are spent). He keeps the caught loot. More monsters: ogre, hornet swarm, spider queen, dragon crowding in. Halls can change tint / strip B.

Read: he is throwing grandpa’s things away in order to get out with the others.

### 4. Swirl · 8.5–11s

Scroll stops. Sprout to centre. Remaining loot, monsters, and hall chips **orbit**. Bloom off the items he still holds. This is the greedy escape becoming a title card, not fight UI (no HP, no wheel, no hotbar).

### 5. Whiteout → still · 11s then hold

Sprites go to white (code can flash; a 3-frame bloom sheet helps). Then `title_still.png` full bleed. Code draws logo (if separate), tagline, Click to continue. Click: playtest hub overlay, art dimmed ~60%.

## Cast (draw these objects, not other cards)

Hero: **Sprout**, same goblin as `hero_run`, but **teaser-readable**. Not the wheel postage stamp.

Nib: lantern, planted, does not run.

Items, by job:

| Job | Ids (folder names) | What the object is |
|---|---|---|
| Caught and kept | `pocketwatch`, `lantern`, `grimoire`, `healing_potion` | watch, lamp, book, red bottle |
| Missed | `lucky_nickel`, `sledgehammer` | coin, hammer |
| Spent (gone) | `da_boot`, `helmet` | boot, helm |

Monsters, in order they crowd:

`goblin`, `dire_wolf`, `skeleton`, `ogre`, `hornet_swarm`, `spider_queen`, `dragon`

Each must read as **that** creature, unique vs the live card PNG. Close is fine. A recolor of the card file is not.

## Type on the still (code, not paint)

Until NAME.md is locked, **no English in the PNG**. After lock, either paint the name into the still **or** drop `logo.png`.

Code then adds, in ThemeDB fallback font, gold / cream:

- Title / logo: upper third
- Tagline: under the title
- Click to continue: lower ~80px, pulsing

Hub after click: centred button stack ≈ **720×520** in the middle of 1680×1040. Put the still’s faces and the main hero in the **upper 45% and the outer thirds**. Do not park the best silhouette dead-centre.

Rect guide (shipped px): [`design/visual/title-teaser/SCREEN-title-still.md`](../../visual/title-teaser/SCREEN-title-still.md)

## How code uses files

`scripts/title_teaser.gd` looks for:

- `res://assets/dungeon/title/title_still.png` — if missing, editor shows the dummy; **web playtest skips the whole teaser**
- `hill_strip.png`, `hall_strip.png`, `hall_strip_b.png` — seamless X, drawn full-bleed, pan right-to-left
- `logo.png` — optional, centred in the upper third
- `sprout_run_f0..f3.png`, `sprout_grab_f0..f3.png`, `sprout_throw_f0..f3.png`
- `nib_lantern_f0..f1.png`
- `item_<id>_f0.png` (and `_f1.png` if you want a bob)
- `mon_<id>_f0..f3.png`
- `bloom_f0..f2.png` optional

If a file is missing, code keeps the dummy for that layer only. Itch still waits on `title_still.png`.

Import: lossless, no mipmaps, Nearest. Return a one-page native + shipped size list.

## Do not

- Do not redraw live card PNGs in `assets/dungeon/items/` or `extra/`
- Do not letter until NAME.md is one word
- Do not put HP, the wheel, hotbar, or “Swipe” UI chrome in the motion
- Do not paint the rain / will knock
- Do not replace `music_combat.ogg`
- Do not match the F5 dummy
