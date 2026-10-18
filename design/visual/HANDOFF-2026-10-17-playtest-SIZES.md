# Oct 17 playtest art — size list

Stored scale: **4× nearest**, the same as the repo (`cat_sleep_f0.png` is 80×48 = 20×12 ×4; `journal_spread.png` is 1520×960 = 380×240 ×4). The stored size is the 4× shipped size.

| File | Native w×h | 4× shipped w×h | Stored |
|---|---|---|---|
| `assets/dungeon/home/props/cat_rub_f0.png` | 16×16 | 64×64 | 64×64 |
| `assets/dungeon/home/props/cat_rub_f1.png` | 16×16 | 64×64 | 64×64 |
| `assets/dungeon/home/props/cat_rub_f2.png` | 16×16 | 64×64 | 64×64 |
| `assets/dungeon/home/props/cat_rub_f3.png` | 16×16 | 64×64 | 64×64 |
| `assets/dungeon/home/overlays/journal_cover.png` | 380×240 | 1520×960 | 1520×960 |
| `assets/dungeon/home/overlays/journal_scribble.png` | 166×80 | 664×320 | 664×320 |
| `assets/dungeon/home/overlays/journal_photo_tape_a.png` | 120×72 | 480×288 | 480×288 |
| `assets/dungeon/home/overlays/journal_photo_tape_b.png` | 120×72 | 480×288 | 480×288 |

## Notes

- **Cat timing:** f0→f1→f2→f3 once at about 180 ms per frame (~5.56 fps, 720 ms total), then back to the `cat_sleep_f0/f1` loop. Pivot is top-left at loft (176, 196) native, the same as the sleep cat. Hide the sleep cat while the rub plays.
- **Cat registration:** the sleep cat is 20×12 native, but these frames are 16×16 as the handoff asks. The cat sits in rows 0–11, so its floor matches the sleep cat's floor (native y 208). Rows 12–15 are empty. At the same pivot, the head ends 4 px further left than the sleeping head. Use origin (180, 196) if the head should line up instead.
- **Cover:** same silhouette and origin as `journal_spread.png` (book x 3–373, y 5–237 native; teal ribbon tip below). Opaque leather inside the book; transparent outside, like the spread. Leather uses the spread's maroon ramp; lettering and tooling use oak `#c4a574`/`#5a3a24`/cream with a `#100e0c` outline.
- **Scribble:** ink `#1c120c` with a few `#5a3a24` faded specks; six lines, the last one short. No real letters.
- **Tape wells:** the photo window is transparent at native rect x 10–109, y 5–66 (100×62, about the aspect of a 1680×1040 shot). Draw the well **over** the screenshot so the tape overlaps the photo corners. Tape variant a has tan tape on all four corners; variant b has cream tape on two diagonal corners.
