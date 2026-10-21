
**UI pieces (made with PixelLab for the mockups; ship as-is or re-roll). Import at 3x Nearest:**

| File | Native | Notes |
|---|---|---|
| `assets/ui/wheel/name_tag_topnotch.png` | 96×16 | Stretch layout: caps 0–4 and 92–96 px, fixed centre 33–63 px holding the notch, stretch columns at 10 and 80 px. Mockup source: `mockups/layouts/crest/clean/tag_topnotch.png`. |
| `assets/ui/wheel/medallion_<icon>.png` | 20×20 | 18px coin, 1px `#1c1814` rim, glyph ≤10 native baked in at 1:1. Mockup sources: `clean/med18_{horn,scales,bolt,fang}.png`. |

**Medallion glyphs:**
- **Phase 1:** one medallion per existing ability-icon key. `main.gd` maps every monster to one of 20 SVG icons (sparkles, link, users, swords, layers, heart, droplet, ban, rotate, mountain, footprints, trending, shield, skull, copy, plus, wand, hammer, sword, palm).
  - That's 20 medallions at 4 per 64×64 PixelLab sheet: ≈5 gens, about 8 with re-rolls.
  - Placeholder: the current SVG rasterised to 10px, centred in a blank medallion.
- **Phase 2 (optional):** bespoke per-ability glyphs, like the mockups' horn, scales, bolt and fang.

## Compatibility with passes 1–5
- **Intent plate (pass 1):** anchor it to the `combat_stage` pop-out. If the stage is hidden, put it on the hub edge facing the slice (`centre + dir * (hub_r + 40)`). This spec supersedes the fallback line in `ANIM-intent-plate.md`. It doesn't depend on which side the ATK badge is on.
- **Aura threads (pass 4):** attach to `sp.feet`, and bow toward the hub (`r ≈ 0.40R`). On 6 or fewer seats the bow can stay at 0.40R.
- **Poison / petrify / hook / hover preview:**
  - Poison badges go at the sprite's top-right.
  - The hook's arc swap moves whole blocks.
  - `set_preview` deltas draw on the 52px badges.
  - The pass 5 hover preview must not open at the same time as the ability card. The item hover wins while an item is held.
- Everything uses the live `hp_global(i)` / `atk_global(i)` anchors, so nothing else depends on badge sides.

## QA (godot-mcp, 1680×1040)
1. **8 seats** (`02_full8.png`) and **6 seats** (`02b_full6.png`): crop each slice boundary. Check:
   - no overlap between neighbouring sprites, tags, medallions or badges
   - no text tilted or upside down on any seat
   - HP heart left and ATK star right everywhere
   - each medallion sits above the feet and below the badges
2. **4, 5 and 7 seats** (`02c_n4.png` … `02e_n7.png`): the same checks. Print the fit-table clearances to the log; all must be ≥ 0.
3. **Hover a medallion** (`03_hover.png`): the card opens on the outward side and is clamped. Spin onto a seat: its card shows while facing.
4. **Breathe:** two shots 300ms apart show different frames on different slices.
5. **Spin onto Vampire:** the pop-out is 4x of 48 or 64 with a 4–6f idle. The intent plate is on the pop-out.
6. **Draft reveal** (`bucket_reveal`): the detail line reads call, then `HP N`, then `Attack N`, with the same words and separator.
7. **`text_audit`:** no "Tier"; Silenced shows the exact Jam string.
