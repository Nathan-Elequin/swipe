## Pass 6: Wheel monsters (frameless sprites, compact name tag + top medallion, ability card, idles)
```text
Read design/visual/_COMMON.md and design/visual/ANIM-wheel-monsters.md, then implement on branch anim/pass6-wheel-monsters. Passes 1-5 are merged. Also re-read the "pass 6" notes in design/visual/ANIM-intent-plate.md and design/visual/ANIM-aura-threads.md and apply them in this pass.

Layout is "B3". Every rule must work for any seat count N = slices.size() from 4 to 8 (the wheel may go from 8 seats to 6). Nothing rotates with the slice and all text stays upright.

Scope (scripts/boss_wheel.gd unless noted):
1. Fit table:
   - Add _fit_table(n) -> Array[Vector2] of feet points, cached in _fit_cache[n] and cleared when slices.size() or a seated sprite size changes.
   - Per seat: search r = 0.40R..0.86R (3px steps) along the mid-angle and dy = -24..+24 (4px steps).
   - Maximise the minimum clearance of the block extents (sprite rect, badge row, tag rect, all relative to the feet, per the spec) to the slice's two edge rays, the hub (+6px) and the rim (-6px).
   - Break ties by closeness to 0.60R, then smallest |dy|.
   - If a clearance is still < 0, drop that seat's tag font to 13px and retry, then push_warning. Never scale the art.
2. _spoke(i): return feet (from the fit table), port = feet - (0, h/2) (sprite centre; keep its meaning for passes 1-5), hp = feet + (-(w/2+24), -20) (LEFT), atk = feet + (w/2+24, -20) (RIGHT), tag_rect, medal, sprite_rect.
   - Delete _clamp_to_rim for badges and all name_tilt / outer-band nameplate maths.
   - Keep plate_r = 48 for old callers.
3. _draw_slice_contents (draw order per seat):
   - Remove _draw_tier_plate.
   - Then _draw_wheel_sprite: floor shadow (0.9 x width x 16px, #0a0604 a0.47), 4px #100e0c outline, frame at an integer 4x with feet on the feet point.
   - Then _draw_name_tag.
   - Then the HP/ATK badges.
   - Re-centre rage fire, fled dust, aura glow, the kill X and the poison badge (top-right) on sprite_rect.
4. _draw_name_tag (replaces _draw_slice_title/_title_metrics), at 3x Nearest:
   - Tag: assets/ui/wheel/name_tag_topnotch.png (96x16) drawn as a 3-part horizontal stretch. Caps 0-4 and 92-96, fixed centre 33-63, stretch columns 10 and 80. Width max(40, ceil((name_px+30)/3)) native, even. Top at feet.y + 33.
   - Medallion: assets/ui/wheel/medallion_<icon>.png (20x20), centred on the tag top, centre 5 native rows above it. Its rim overlaps the feet by 12px: above the sprite, below the badges.
   - Name: 15px ink_on_dark with a 3px outline, centred at tag_top + 28, never transformed. Keep the duplicate-name and Commander "· used" rules.
   - Silenced: medallion a0.45.
5. _draw_atk_stat/_draw_heart_stat: radius 26 (punch +4), number 26px. HP heart LEFT, ATK star RIGHT on every seat. Move the ×2/↻/∞ multi-hit tag to atk + (20, 22) using the pass 1 shared helper. Update _atk_pos/_hp_pos and slice_avoid_global (sprite_rect, tag_rect, medallion, both badges).
6. Ability card: new scripts/ui/ability_card.gd.
   - Opens on medallion/tag hover and for the facing seat.
   - 9-slice plate, 72px tall. Line 1 is a 2x icon plus the call name, 16px, in _ability_icon_color ("Silenced" when silenced). Line 2 is the existing Shift-explainer text via PLAYER_COPY, 13px, max 2 lines at 300px.
   - Place it on the outward side of the tag, 12px gap, clamped to the viewport. Never over the right panel (flip inward instead).
   - Gold 3px ring on the hovered medallion.
   - It replaces the old Shift explainer plate. While an item is held, the pass 5 hover preview wins.
7. Medallion art: map each monster's ability-icon key (the 20 SVG keys main.gd already uses) to medallion_<key>.png.
8. scripts/bucket_reveal.gd (~L384-388): show HP before Attack. This is an ORDER CHANGE ONLY: move the hp bits.append block above the atk block. Keep the exact strings "Attack %s" and "HP %s", the call line first, and the existing separator unchanged.
9. Breathe:
   - Add set_wheel_frames({id:[f0,f1]}), fed by a new dungeon_art.gd monster_wheel_frames(id).
   - Frame = int(_glow_t/0.6 + i*0.37) % 2.
   - Fallback: a 4px bob on the same clock.
10. Facing pop-out (scripts/combat_stage.gd):
    - show_monster uses a new art.monster_facing_idle(id) (fallback monster_idle).
    - Integer 4x of the 48 or 64 canvas, 4–6 frames at 140ms, no sine bob when real frames exist.
11. Compatibility:
    - Intent plate wheel fallback → hub edge facing the slice (centre + dir*(hub_r+40)).
    - Aura threads attach at sp.feet and bow to 0.40R.

Art: PixelLab art isn't in yet. Generate placeholders at the exact final filenames:
- For every live monster (58: catalog.json monsters minus three_seeker):
  - assets/dungeon/anim/wheel/<id>_wheel_base.png (24 native tall; ≤24x28)
  - assets/dungeon/anim/wheel/<id>_wheel_breathe_f0.png and _f1.png (identical copies)
  - assets/dungeon/anim/facing/<id>_facing_idle_f0.png … _f3.png (48x48, or 64x64 for Deadly)
- Make the monster placeholders from the current still (art.monster_still source, e.g. assets/dungeon/extra/<id>.png, which is stored at 4x): downscale ÷4 to native, then nearest re-pixel to the target height.
- assets/ui/wheel/name_tag_topnotch.png: Pixel will attach the PixelLab tag. If it's missing, draw a 96x16 placeholder with a top notch.
- assets/ui/wheel/medallion_<key>.png for the 20 icon keys: a blank 18px coin with a 1px #1c1814 rim and the current SVG rasterised to 10px in the centre.
- Import with Nearest, no mipmaps, Lossless.
- List them all in assets/dungeon/anim/wheel/PLACEHOLDERS.md so PixelLab art can overwrite the files with no code change.

Rules:
- Never show "Tier"; rank is carried by the slice colour only.
- New strings go through PLAYER_COPY.text().
- Tweens and timers respect Engine.time_scale (Shift fast-forward).
- Don't change input bindings.
- No text is ever rotated.

QA with godot-mcp at 1680x1040, saving to design/visual/anim-qa/wheel-monsters/:
- 01_four.png: Commander, Merchant, Eel and Vampire seated with empties between, at the draft gate.
- 02_full8.png and 02b_full6.png: 8 and 6 seats filled. Crop each slice boundary and confirm:
  - no overlap between sprites, tags, medallions or badges
  - all text upright
  - HP heart left and ATK star right on every seat
  - each medallion above the feet and below the badges
  - compare with mockups/layouts/crest/layout_B3_top_medallion_8.png and _6.png (Pixel will attach them)
- 02c_n4.png, 02d_n5.png, 02e_n7.png: the same checks at 4, 5 and 7 seats. Log the fit-table clearances (all ≥ 0).
- 03_hover.png: hover a medallion; the card opens outward, clamped, off the right panel.
- 04/05: two shots 300ms apart showing a staggered breathe.
- 06_facing.png: spin onto Vampire; the 4x pop-out idle shows, its ability card opens, and the intent plate is anchored to the pop-out.
- 07_threads.png: Commander threads on the inner arc.
- 08_reveal.png: bucket_reveal detail line reads call, then "HP N", then "Attack N" (same words and separator as before).
Run scripts/dev/text_audit.gd.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
```
