# Cleanup test (Pixel, 20 Oct 2026)

Scripts: `common.py`, `title.py` (`python3 title.py` strict / `python3 title.py ext`), `sprout.py <raw> <48|64> [tag]`.

## Title (returns/title_still_v3_raw.jpg, 1312x816)
- Effective pixel: 3.14 x 3.13 src px per art pixel (grid ~418x261). Padded 2.3 px L/R by edge copy to 420:260, nothing cut.
- Per cell: palette-snap every src pixel (Lab), then mode of the inner 60% of the cell; 1,411 single-pixel specks removed (ext run).
- `_ext` (recommended): 64-colour game palette + 10 extra ramp colours: 7 purple/blue from the magicat, lich and spider queen PNGs, river blue #3e8ea8, and 2 glow browns #633f2b #8c5228 for the mouth halo. 73 colours used. Strict: 63 colours; purples (magicat, spider) go navy.
- Files: `title_still_v3_native_420x260[_ext].png`, `title_still_v3_clean_1680x1040[_ext].png`, `title_compare_raw_vs_clean.png`, `title_crop100_goblin_raw_ext_strict.png`, `title_crop100_items_raw_ext_strict.png` (raw | ext | strict; made before the 2 glow colours were added), `title_crop_mouth_glow_raw_vs_ext.png`.

## Sprout run (returns/sprout_run_raw.jpg = revised; v1 kept)
- Magenta keyed by hue (R-G>70 and B-G>70), so the JPEG fringe goes too. Frames split on the black divider columns.
- Generator grid ~8.35 src px (character ~59 art px tall). 48 build resamples at 10.5 src px per cell; 64 build at 7.84.
- Sprout sub-palette only (outline, gold eye, skin, cloak, scarf, sack ramps) plus #44702a for the far leg.
- Feet on the bottom row (row 47 / 63), centred on the upper-body centroid, so legs swing and the head stays put.
- Files: `sprout_run_f0..f3_native48.png`, `_x4.png`, `sprout_run_contact_x4.png`, `sprout_run_x4_8fps.gif`; same with `_64` and `_v1`; `sprout_compare_ingame24_vs_48_vs_64.png`; `sprout*_notes.txt`.
