# Cleanup-all grades (20 Oct 2026)

Pipeline: `assess.py` (uses `common.py`). Magenta keyed by hue, frames sliced, bottom-aligned, mode-per-cell downscale to the native size, snapped to the 64-colour game palette plus 10 extras, orphan specks removed, 1px #100e0c outline added where missing. `OVERVIEW_ingame_scale.png` = everything at 4x on the shipped hall strip, with the cleaned title below.

| Asset | Native / frames | Faces right | Grade | Fix or paste line |
|---|---|---|---|---|
| Sprout design sheet (00) | 4 views + coin pose at 48 | yes (side view) | Usable (it's the canonical reference, not shipped) | none |
| Title still v3 (01) | 420×260 | monsters yes | Re-prompt (hero only), then a hand fix on the glow | Attach `returns\sprout_design_raw.jpg`: `Replace the hero on the cliff with the character in this attached design sheet; keep everything else.` Hand fix: repaint the mouth halo as 2-3 dithered steps |
| Sprout run (02) | 48, 4 frames | yes | **Re-prompt** (old long-nose design) | New chat, folder 02 prompt + design sheet. Same chat: `Redraw this exact sheet with the character from the attached design sheet: same poses and 4 cells, facing right, feet on the bottom edge, magenta background.` |
| Sprout grab (03) | 48, 4 frames | yes | **Re-prompt** (old chibi design) | same line as 02 |
| Sprout throw (04) | 48, 4 frames | yes | **Re-prompt** (old design) | same line as 02 |
| Nib lantern (05) | 32, 2 frames (from 8 cells) | yes | Small hand fix | Used top-row cells 3-4 (lit lantern; frame 2 has a wink + tail flick). Optional: add the 2px monocle |
| Goblin (06) | 32, 4 frames | yes | Usable as-is | none; legs alternate |
| Dire wolf (07) | — | — | Not made | New design prompt in folder 07 |
| Skeleton (08) | 32, 4 frames | yes | Small hand fix | The dagger blurs or vanishes in f1-f3 at 32; redraw a 3px blade in each frame |
| Ogre (09) | 48, **3 frames** | yes (3/4) | **Re-prompt** | `Keep the design, but make exactly 4 frames in one row (add the missing passing frame), and don't draw any palette or colour swatches.` (Fallback: Pixel duplicates f1 as f3) |
| Hornet swarm (10) | 32, 4 frames | mixed | **Re-prompt** (yellow noise at 32) | `Redraw it with only 3 big hornets in a tight triangle, bold black-and-yellow stripes, big angry eyes, all stingers pointing right, so it still reads at 32x32 pixels; 4 frames in one row.` |
| Spider queen (11) | 48, 4 frames | yes | Usable as-is | none |
| Dragon (12) | 64, 4 frames | yes | Small hand fix | It's long and flat (~34 of 64 rows used), so it reads smaller than the ogre. Crop to the content height (64×~36); `_mon_draw_size` then scales it ×8. Or re-prompt: `Keep the design, but make the dragon taller and more compact, head and wings raised, so it fills a square cell.` |

## Consistency
- **Sprout is 3 different characters right now**: the design sheet (new plucky adventurer), the run (long-nose, long cape) and grab/throw (old squat chibi). The title hero is also the old one. All four need the re-prompt with the design sheet attached.
- The monsters (goblin, skeleton, ogre, spider, dragon) share one Gemini look and sit well together and with the title.
- Nib is blockier and lower-detail than the rest.
- The hornets break the set.
- Palette: 21-38 colours per asset after the snap. The extras in use are the dark purple `#2e2450` and the glow browns.
