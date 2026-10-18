# Pixel packet — Oct 17 playtest

Drop PNGs in the paths below. Native pixel size first, then 4× nearest-neighbor (same pipeline as the rest of the game). Transparent unless noted. No English on plaques except the journal cover. Return a one-page size list with the PNGs.

Palette: cabin oak `#3a2414` `#5a3a24` `#c4a574` `#fff3d6` `#100e0c`; ink `#1c120c`; cream `#fff3d6`. Do not redraw card art.

## 1. Cat belly-rub — loft click

| File | Native | Notes |
|---|---|---|
| `assets/dungeon/home/props/cat_rub_f0.png` | 16×16 | Start of rub, same registration as `cat_sleep_f0.png` |
| `assets/dungeon/home/props/cat_rub_f1.png` | 16×16 | Belly up / paws |
| `assets/dungeon/home/props/cat_rub_f2.png` | 16×16 | Purr peak |
| `assets/dungeon/home/props/cat_rub_f3.png` | 16×16 | Settling |

Loop f0–f3 once (~180 ms/frame), then return to `cat_sleep_f0/f1`. Pivot: top-left, same as sleep cat at loft (176, 196) native. Transparent. Code: click Cat hotspot in the loft.

## 2. Grandpa’s Journal cover

| File | Native | Notes |
|---|---|---|
| `assets/dungeon/home/overlays/journal_cover.png` | 380×240 | Closed book, front. **Draw the words “Grandpa’s Journal” in the art** (this once, because it is the cover). |

Opaque leather. Registration: same origin as `overlays/journal_spread.png`. Code shows this before the spread.

## 3. Unread scribble

| File | Native | Notes |
|---|---|---|
| `assets/dungeon/home/overlays/journal_scribble.png` | 166×80 | No words. Handwriting texture, same shape as a lore block. |

Transparent. Code: unmet monster/item lore well.

## 4. Scrapbook tape wells (intro replay)

| File | Native | Notes |
|---|---|---|
| `assets/dungeon/home/overlays/journal_photo_tape_a.png` | 120×72 | Empty well, tape corners, no photo |
| `assets/dungeon/home/overlays/journal_photo_tape_b.png` | 120×72 | Second well, slightly different tape |

Transparent. Code pastes intro screenshots into the wells. Bookmark tab **Memories** sits in front of the book. Button copy is not in the art.

## How code uses them

- Cat: `AnimatedSprite2D` on loft, overlay the sleep cat, play once, back to sleep.
- Cover: first page of the journal overlay.
- Scribble: `TextureRect` in the lore rect when unmet.
- Tape wells: third journal tab (replaces Will inside the book). Will stays on the desk.

## Size list to return

Native w×h for every file above, plus 4× shipped w×h.
