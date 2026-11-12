# Pixel — Phantom Dark Matter, the stealth presentation

You are making the art and the small wiring that lets Phantom feel like a boss about hidden information. The rules are already in the game on `playtest/latest` (commit `0a17edd3` and the commits under it). Do not change those rules. Do not edit `data/player-copy.json`. Do not put the words Tier, ATK, or atk anywhere a player can read. Do not reuse another card's pixels. Crypt Classic: 1px `#100e0c` outline, light from the upper left, no anti-aliasing, nearest filter, lossless, no mipmaps. Palette: `design/handoff/CURSOR-AGENT/palette/`. Normal animation speed is 0.675. Shift fast-forward is 2.025. One contact sheet for the batch.

Read the shots in `design/phantom-shroud-pixel/shots/` before you draw.

## What the player already does

Phantom is 6 HP / 6 ATK. Call name stays **Dark Matter**. Ability, Nathan's words: "I Always Shroud my Neighbors and the Dungeon Deck. When I enter, I Shuffle the wheel."

Shroud, gold keyword capsule, same widget as Lifelink (`scripts/keyword_tip.gd`, definition in `scripts/ux_style.gd`): "Hidden until Defeated, or until you resolve combat while facing them."

On enter, Phantom's real slash plays. The wheel is covered while the monsters trade seats. The deck order does not change. After they land, only the two monsters in the seats directly beside Phantom stay hidden. The monster across from Phantom stays visible. Phantom stays visible unless a second Phantom is covering it. A Phantom can be covered. The shuffle is random, so Undo cannot put the old seats back.

A covered monster keeps every rule (HP, attack, Protector, Martyr, poison, auras). The player is supposed to track the numbers in their head.

- Wheel seat of a covered monster: no name, no portrait, no numbers. An apparition sits where the sprite would sit.
- Dungeon Deck: only the top card is covered. Same apparition, in the card window. Hover says `?`.
- Spin onto a covered monster: the real slash plays, the real callout plays (name, ability, animated portrait). Heart icon and a single attack icon stay, and the number inside each one is `?`. Looping and multi-attack (Shark, Hornet Swarm) must look like one ordinary attack icon. Poison and other changing stat marks stay off that plate.
- Take, while facing a covered monster: the normal cream Take arc and the normal damage burst, with `?` in the burst instead of the number. Not a gray word. Not the word "Safe".
- Clicking Take lifts the cover, then combat plays as usual. After that fight they stay visible even if they are still beside Phantom.
- A kill lifts the cover first, then the hit, then the death.
- Flee (Phoenix Egg and the rest): if they are still beside Phantom afterward, cover them again. If the spin left the facing elsewhere, they stay visible.
- Phantom's Defeat drops every cover that Phantom caused. Survivors just appear. No new enter slash. A second living Phantom keeps its own covers.
- Quiet Bell on Phantom lifts that Phantom's covers for the bell, then puts them back, except monsters already faced out of cover.
- Opening deal does not portrait every other monster. They are placed in their seats. A slash plays only when that monster's enter ability would have played one anyway.
- The old hotbar item veil is gone. Do not bring it back.

## Shots

1. `design/phantom-shroud-pixel/shots/01-facing-shroud-take-and-callout.jpg` — Cinder Forge, earlier in the pass. Facing seat is a dark circle. Take says "Take ?" with no burst. The right callout is a blank plate with three question marks. Deck top is a `?`. This is the problem, not the target. The code has since put the real monster on that callout, the heart and a single attack icon with `?` inside, and the normal Take burst with `?` inside. Your art replaces the circle and the deck smudge.
2. `design/phantom-shroud-pixel/shots/02-wheel-veils-during-spin.jpg` — earlier still. Three dark circles. The seat across from Phantom was wrongly covered in this shot. Current rule is only the two neighbors. Use it to see how small and off-center the placeholder circle is next to a real sprite (Phantom, Wick, Trapper).
3. `design/phantom-shroud-pixel/shots/03-normal-callout-take-and-keyword.jpg` — not a Phantom fight. This is the UI you are matching. Heart with a number, attack burst with a number, cream Take arc with the burst, gold keyword capsule (Lifelink) on Kiss of Death. Phantom's faced callout should feel like this plate, with `?` where the numbers are. Do not invent a new plate.

A live Crystal Cavern fight on 2026-11-12 (not saved as a file) showed the same placeholder: two neighbor seats as small dark circles with `?`, deck top a small `?` on card 4, Phantom visible, the other seats fully drawn. The facing monster in that moment was already revealed (Glass Asp, real 9 and 2, Take with a real 3).

## Starting assets

Draw these. Feet and pivot matter. The wheel sprite box is upright, feet at the bottom of the rect, same rect `_draw_wheel_sprite` uses. Weak/Tough seats are 48 native at 2x (96px). Deadly seats are 64 native at 2x (128px). The apparition has to sit in either box without a different drawing per tier. Prefer one 64×64 native, feet on the bottom row, displayed at 2x, scaled down into a 96px seat.

1. **Seat apparition**, 4 frames, loop. `assets/dungeon/vfx/shroud_apparition_f0.png` through `f3.png`. 64×64 native. It must read as "a monster is standing here and you cannot see who." Not an empty alcove, not a copy of Phantom, not a generic smoke blob that could be a hole in the wheel. Idle motion in the same family as a wheel monster's idle (a small bob is already in code; the frames can breathe). 1px outline. Dark matter, not photoreal fog.
2. **Deck cover**. Same character, cropped or redrawn for the deck window. The deck card is 32×44 native, drawn at 3x (96×132). The monster window on `card_front.png` is native rect (7, 7, 18, 17). File: `assets/ui/deck_shroud.png`, 32×44, or a window-only 18×17 if you want the card frame to stay. The top card's name and rank must not show through. Hover already says `?`.
3. **Mystery slash portrait**. When a covered monster who is not the one you are facing has to act, `scripts/main.gd` `_phantom_slash_mystery` calls `scripts/ability_slash.gd` `play()` with title `?` and a null texture. The cut-in shows portraits at 4x, max 256px, native canvases 32/48/64/80. Give `play()` your apparition still (frame 0 is fine, or a 4-frame hold). File can be the same `shroud_apparition_f0.png`. Do not use another monster's sprite.
4. **Uncover**, 4 frames, once. `assets/dungeon/vfx/shroud_uncover_f0.png` through `f3.png`. Same 64×64, same feet. Frame 0 matches the idle apparition. The last frame is gone (empty or a few sparks) so the real sprite can be underneath. Used when Take starts on a covered monster, when a killing blow is about to land, when Phantom dies, and when Quiet Bell lifts the covers. Survivors do not play an enter slash. The uncover is the only "they were here" motion.
5. **Cover-on**, 3 or 4 frames, once. `assets/dungeon/vfx/shroud_cover_f0.png` through the last frame. A visible monster becoming hidden (a later draw into a neighbor seat, a Flee that stops beside Phantom, the bell ending). Ends on the idle apparition.

Do not draw a new heart, a new attack burst, or a new Take button unless you look at shot 03 and the `?` the code stamps on those icons sits badly in the glyph. If it sits badly, say so and draw only a `?` glyph that matches the number's size and outline (`_draw_stat_number` in `scripts/boss_wheel.gd`, and `_draw_hit_num` in `scripts/ui/take_arc.gd`). The attack icon on a covered callout is forced to the single burst (`_draw_atk_variant(..., "single", ...)`). Do not draw the double or loop icon for this state.

## Where it gets wired

- Wheel placeholder is `scripts/boss_wheel.gd` `_draw_shroud_wedge(sprite_rect)`. It draws a circle and two rings and a `?` in the sprite rect when `slice.phantom_shroud` is true, then returns before the real sprite, name, heart, and attack. Replace that drawing with the apparition frames, feet on the bottom of `sprite_rect`, nearest, no mipmaps. Keep the early return so the name and numbers stay off the wheel.
- Deck placeholder is `scripts/dungeon_deck.gd` `_draw`, the block `if shroud_top and count > 0`. It paints a dark rect and a `?` over the top card. `set_shroud_top` is the switch. Main sets it from `_phantom_deck_cover` in `_sync_challenge_peek`.
- Mystery slash is `_phantom_slash_mystery` in `scripts/main.gd`. Pass the apparition texture instead of null.
- Facing callout stays the real monster: `_show_fight_portrait` and `_refresh_face`. Do not put the apparition on that plate. The `?` numbers are the early branches in `_draw_heart_stat` and `_draw_atk_stat` when `phantom_shroud` is set.
- Take `?` is `mystery_take` on `scripts/ui/take_arc.gd`, fed by `_sync_take_arc(..., mystery)` in `scripts/main.gd`.
- Cover state lives on the monster dict: `shroud_from` (which Phantom), `shroud_seen` (already faced, stays visible), `phantom_shroud` (the paint flag). `_phantom_veil_all` hides every seat during the shuffle, then paint keeps only neighbors. Do not move that logic. Only replace the drawing.

`.import` for every new PNG: filter Nearest, lossless, no mipmaps. `tools/qa/check_ui_pngs.py`.

## Go further

The list above is the floor. Hidden information is easy to make feel unfair and easy to make feel blank. Propose and, where you can draw it without a new rule, add whatever else this boss needs so the player can tell these apart:

- A seat that was never a monster, versus a seat with someone hiding in it.
- The moment the whole wheel is covered for the shuffle, versus the moment only the neighbors remain.
- A cover lifting because you chose to face them, versus a cover lifting because Phantom died, versus a cover lifting because of Quiet Bell.
- A card leaving the covered deck into a hidden neighbor seat, versus a card leaving into an open seat.
- Two Phantoms, one of them hidden beside the other.

Questions worth answering in your pass, with a recommendation and a frame or two, not a stall:

- Should the apparition have a face, a hood, or only cloth and sparks? It must not be readable as a specific monster.
- One drawing used at wheel size, deck size, and slash size, or three drawings that match?
- Does the shuffle want a full-wheel sheet (a dark wave around the rim) in addition to the per-seat frames?
- Should uncover play on the wheel only, or also as a one-frame flash on the callout the moment the real portrait appears?
- Is there a one-pixel tell that a hidden monster's numbers changed, or should a change be completely silent? Current code does not bounce the callout when a hidden number changes. Nathan wants the player to track the numbers. Do not add a tell unless you think the silence is unreadable, and if you do, describe it before you draw it.
- Audio is not this pass. If a moment is dead without a sound, name the moment and the feeling. Do not add audio files.

Ship a contact sheet, the PNGs at the paths above, the wiring that shows them in those three places (wheel, deck top, mystery slash), and a short note of what you added beyond the floor and what you left as a question for Nathan.
