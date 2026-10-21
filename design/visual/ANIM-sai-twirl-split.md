# ANIM: Sai twirl-split / merge (hotbar expression)

**Rule (final).** Sai flips 2 ↔ 4 after **any** item is used. It **keeps its number between fights** and resets to 2 at each new dungeon.
Jam copy: "Flips 2 ↔ 4 after any Item is used. Keeps its number between fights."
The code is already right: `alt_n` lives on the item and is reset only in `_prep_next_dungeon()` (~L2410).

**Look.**
- State 2 = **one sai**.
- State 4 = **a crossed pair of sais**.
- 2→4: the sai twirls and **splits** into the pair.
- 4→2: the pair twirls and **merges** back to one, ready for the 2-hit.

## Hooks (real code)
- `main.gd::_flip_alt_sais()` (~L8993) is called from `_count_item_use()` (~L11346). Record `old = it.alt_n` before the flip. After the flip, find the card (`_hotbar_card(id)` ~L16455, or the card bound to that uid) and call `card.play_sai(old, new)`.
- **Static state:** `item_card.setup()` / `set_icon(tex)` (~L345). Pick `sai_single` or `sai_pair` from `alt_n` on every `_sync_hotbar()`, so it is right after load or undo with no anim.
- **Number:** `item_card.set_live(number_text…)` already dissolves the number (`_dissolve` ~L673). Delay it 120ms, so the number changes at the moment of the split or merge.
- **Use:** Sai's own use (`_use_item` ~L6906) deals the current value. The toss happens first, then the flip applies to other Sai copies (two Sais are legal via Merchant).
- **Dungeon reset:** `_prep_next_dungeon()` sets `alt_n = 2`. The card simply shows `sai_single` with **2**. No animation.
- **Undo:** `_undo_play_fx` (~L6852) must call the static setter, not the anim.

## Layout
- The icon stays in the card's 48×48 icon box (`_icon`, item_card ~L134).
- Frames are 24×24 native shown at 2x (48px) to fit the box. Hotbar icons keep their current size.
- The twirl may overflow the box by 8px; set the card `clip_contents = false` during the anim.

## Timing (ms)

| Event | Animation |
|---|---|
| Split, 2→4 | 8 frames @ 45ms = 360: f0–3 twirl (one blade spinning), f4–7 the blade separates into the crossed pair. Number dissolve at 120. Card `bounce()` at 360. |
| Merge, 4→2 | the same frames reversed (360) |
| Simultaneous changes | if the Sai flips while the card is being used or tossed, skip the anim |

## Nodes
```
ItemCard
 └─ _icon (TextureRect)           ← static sai_single / sai_pair
 └─ SaiFx (AnimatedSprite2D, 2x, centred on _icon, hidden when idle)  [PL]
```
Play `SaiFx` and hide `_icon` while it runs, then swap the texture and show it again. No shader.

## Assets

| File (`assets/dungeon/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `sai_single.png` | 24×24 | 1 | [PL] base (match the current `assets/dungeon/items/` sai icon) |
| `sai_pair.png` | 24×24 | 1 | [PL] new base (two sais crossed) |
| `sai_split_f0-7.png` | 24×24 | 8 | [PL] (merge = reversed playback) |

## QA
1. Hand: Sai plus 2 others. Use one item. Shots at 120 / 240 / 360ms: twirl, splitting, pair with **4**.
2. Use another item: merge back to one, **2**.
3. Win the fight and start the next: Sai still a pair with 4 (carries over).
4. Delve deeper (`_prep_next_dungeon`): the card shows a single sai with 2, no animation.
5. Undo after the flip: static state with no anim.
