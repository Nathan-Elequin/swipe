---
name: Intro Teaser Title
overview: After the Feedback Tutorial, play a silent combat-themed chase that teaches “spend some loot to keep the rest,” whiteout into a Pixel title still with the new tagline, then Click to continue into the existing playtest hub. Pixel owns every new PNG; itch waits for their finals.
todos:
  - id: name-lock
    content: Lock the drawn title among Snatchwick (recommended), Swipe, or Everything; Pixel letters only after that pick
    status: completed
  - id: storyboard-packet
    content: Write Zen HTML storyboard + design/handoff/title-teaser TASK.md with ART-REQUEST sizes, beats, reuse vs new
    status: completed
  - id: teaser-player
    content: "Wire title_teaser.gd: first-boot unskippable, later skippable, combat music, reused hero/items/monsters, whiteout, Click to continue, hub as page two"
    status: completed
  - id: music-mock
    content: Play combat-through vs dip-on-still for Nathan to pick by ear
    status: completed
  - id: pixel-wire
    content: "After Pixel drops finals: register still/strips, uniqueness + PNG checks, no itch until then"
    status: completed
  - id: issue-62
    content: In the execute chat, fix Call name always visible on the wheel and ship playtest for that bug
    status: completed
isProject: false
---

# Intro teaser and title still

## What this is (and is not)

This is a **boot teaser**, not a replacement for the rain / will cutscene. Brand New still plays [`scripts/cabin/cutscene_player.gd`](scripts/cabin/cutscene_player.gd) intro panels after the hub.

Locked story we must not contradict (from [`data/player-copy.json`](data/player-copy.json)): a small goblin, Nib delivers the will of **Lucky / Bartleby Snatchwick**, everything is still **in the mountain**, Nib walks them to grandpa’s cabin.

The teaser’s silent story is the **greedy escape** you picked, rewritten around inheritance: he is taking grandpa’s things back; monsters of the mountain want them; he has to **use or throw some loot to get out with the rest**. No text boxes. The title card says the rule out loud.

## Boot order

```mermaid
flowchart LR
  boot[Itch or F5] --> tutorial[Feedback Tutorial if unseen]
  tutorial --> teaser[Teaser motion]
  teaser --> titleStill[Title still plus tagline]
  titleStill --> click[Click to continue]
  click --> hub[Playtest hub overlay]
  hub --> brandNew[Brand New]
  brandNew --> story[Existing will cutscene]
```

Hook: [`scripts/main.gd`](scripts/main.gd) `_playtest_intro_done()` currently goes straight to `_show_playtest_hub()`. Insert the teaser there. Returning visitors (intro already seen) still play the teaser at each boot, **skippable from the first frame**. First-ever play: teaser is **not skippable** until the title still is up.

Skip later: click or any key jumps to the **title still**, not past it. First time, leftover clicks from the tutorial get a short arm so they cannot eat the teaser.

## Title words (before Pixel draws lettering)

Current locked parchment: `{game_title}` = **Swipe**, old tagline “You just couldn't keep your grubby hands off their loot, could ya?” in [`data/player-copy.json`](data/player-copy.json) `title.sub` (author-locked). This chat is the override for the tagline.

**Tagline to stamp:** `Use it, Lose it, or Lose your head`  
Reuse existing `intro.next` for **Click to continue**. Do not invent other UI words. Jam still owns [`data/player-copy.json`](data/player-copy.json).

**Name — my recommendation: Snatchwick.** It is already in the will, it is unique on a title card, and it stops colliding with the verb swipe / Spin. The tagline carries the mechanic. Itch slugs (`swipe-playtest`) can stay until you say promote.

Pixel weighs in by lettering, not by a second form from me. Packet will ask them to pick among three for the drawn logo:

- **Snatchwick** (recommended)
- **Swipe** (keep the current name)
- **Everything** (Nib’s line: he left you everything; it is still in the mountain)

Do **not** paint title lettering until that pick is in. Storyboard the still as a picture first.

## Silent storyboard (proposed, duration not strict)

Aim ~12 seconds of motion, then hold the still until click. I will time it to a phrase of [`assets/audio/music_combat.ogg`](assets/audio/music_combat.ogg) after we hear a mock.

1. **Threshold (0–2s).** Night hill / cabin door. Hero runs **into** the mountain. Combat bed starts. Nib holds a lantern and **does not follow** (cameo only; the knock scene stays owned by Brand New).
2. **Grab (2–5s).** Side-scroll through dungeon halls. Grandpa’s items float ahead. Hero catches some, misses some. Monsters enter from behind.
3. **Spend to keep (5–8.5s).** Hero **uses** an item into a monster (Boot / Block / potion-class) so he can keep running with the rest. The used sprite is gone. Chase tightens. Halls change.
4. **Swirl (8.5–11s).** Camera stops tracking; remaining loot, monsters, and hall fragments orbit. Bloom from the items he still holds.
5. **Whiteout → still.** Sprites bloom to white, then Pixel’s title illustration. Name, tagline, **Click to continue**. Click opens the current hub as a second overlay ([`scripts/playtest_hub.gd`](scripts/playtest_hub.gd)), art dimmed underneath.

Camera choice I am locking: **scroll, then swirl**. Hero art for motion: **reuse** [`assets/dungeon/hero_run/`](assets/dungeon/hero_run/) (the same 24px goblin they will play). The title still is where he gets the fully painted larger treatment.

Worlds: dungeon halls for the chase; cabin/hill only at the open and as a ghost in the still. New looping strips if the tiled hall ([`scripts/dungeon_bg.gd`](scripts/dungeon_bg.gd)) cannot read as “adventure” at teaser scale. Pixel invents a short wilderness/hill strip for beat 1 if needed. No fake overworld the game does not have.

Floaters: **live card sprites first** ([`scripts/dungeon_art.gd`](scripts/dungeon_art.gd) `ITEM_PNG` / monster idle+run). Pixel upgrades readable teaser floaters later; itch does not wait on that upgrade.

## Pixel vs agent

Cursor does not draw or replace PNG bytes ([`unique-art.mdc`](.cursor/rules/unique-art.mdc)).

**Pixel packet** (after you approve this plan), in `design/handoff/title-teaser/` plus a Zen HTML storyboard you can actually look at (`design/visual/title-teaser/storyboard.html`):

- Beat sheet with timing, camera, what is reused vs new
- ART-REQUEST rows: native size, 4x nearest, frames, loop, pivot, palette, path
- Title still: full-bleed for viewport **1680×1040** (native 420×260 unless Pixel wants letterbox). Picture must read inheritance + spend-to-keep + mountain, not just “goblin in a hallway.” Pixel proposes the composition after they see the board.
- Looping hall / hill strips if they say the tiled bg is not enough
- Logo lettering **after** the name pick
- Optional later: dedicated swirl floaters

**Agent** (can start as soon as the storyboard exists, using reused sprites):

- New `scripts/title_teaser.gd` (Control, process always, z above tutorial, below nothing we need to click through)
- Seen-flag: first boot unskippable until still; later boots skippable (same save style as `_playtest_intro_seen()`)
- Combat bed via [`scripts/audio_fx.gd`](scripts/audio_fx.gd) `music_to("combat")`; we mock hold-vs-crossfade on the still and you pick after hearing it
- Title overlay uses `title.overlay` / new tagline / `intro.next`
- Hub stays page two; Brand New still runs the will cutscene
- Local F5 throughout. **No `butler push` until Pixel’s final still (and any new strips) are wired.**

## Files we will touch (execute phase)

- [`scripts/main.gd`](scripts/main.gd) — boot hook after Feedback Tutorial
- [`scripts/playtest_hub.gd`](scripts/playtest_hub.gd) — become the post-title overlay
- New `scripts/title_teaser.gd`
- [`data/player-copy.json`](data/player-copy.json) + [`data/script-names.json`](data/script-names.json) — tagline; title if we rename
- [`data/author-locks.json`](data/author-locks.json) — keep locks, stamp the new tagline he authored here
- `design/handoff/title-teaser/TASK.md` + ART-REQUEST
- `design/visual/title-teaser/` storyboard HTML + later layout JSON for the still
- `.import` only after Pixel drops PNGs

Not this project: Paper Fight (no rule change). Not drawing placeholders-as-final.

## Parallel note (not the teaser)

[#62](https://github.com/Nathan-Elequin/swipe/issues/62) is a live playtest report (monster Call name should stay visible on the wheel). I will patch that in the execute chat unless you tell me to hold it; it does not wait on Pixel.
