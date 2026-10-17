# SCREEN: Rope exit (Grandpa's Emergency Exit) + Sack peek overlay

Mockups: `design/visual/mockups/rope-exit.png` (Climb hovered), `rope-exit-sack-peek.png` (overlay open).
Layouts: `design/visual/layouts/rope-exit.layout.json`, `rope-exit-sack-peek.layout.json`.
Source: `scripts/cabin/rope_exit.gd` (+ the sack peek overlay script). Background, ladder, hole, torch and hero art are unchanged.

## Rope exit
- **Title band**: ColorRect (0,32,1680,128) #100e0c at 60%, mouse IGNORE. Headline `rope.cleared` {n} (240,44,1200,56) 48->28, 1 line, cream #fff3d6. Sub `rope.sub` (240,104,1200,40) 32->20, 1 line, #e2d0b0.
- **Sign**: `assets/ui/rope/rope_sign_9.png` (new, text-free, 9-slice L24 T24 R24 B28) at (32,440,352,152). It covers the baked board, and the baked post stays visible below. Inner text rect (60,468,296,92): `rope.sign` 32->16, max 2 lines, ink. "Grandpa's Emergency Exit" fits on 1 line at 32 px. This replaces `rope_sign_notice.png` and the old free Label.
- **Climb home**: plank Button (32,712,360,144), z 20. Label `rope.climb` (52,730,320,44) 40->24, 1 line. Consequence `rope.climb_sub` (52,776,320,56) 28->16, 2 lines, #5a3a24. Action `_on_climb()`. The Ladder hotspot (384,0,160,904) runs the same action, and hovering either lights both (button hover + `rope_ladder_hover`).
- **Delve deeper**: plank Button (1012,712,360,144), the same size as Climb (equal weight). Label `rope.deeper`, consequence `rope.deeper_sub` {n}=cleared+1. The Hole hotspot (1000,856,384,160) does the same thing and hovering it lights `deeper_hole_hover` + the button hover.
- Both consequence lines are now always visible. Don't swap label text on hover anymore.
- **Peek in the sack**: smaller plank (624,716,240,64) above the goblin, label `rope.peek` 32->16. It opens the overlay.
- Plank states `btn_plank_{normal,hover,pressed,disabled}` (existing, 9-slice 16/16/16/20). Pointer cursor. Ink #3a2414 on face #d9c79c 8.7:1, hover face #f0e6d8 11.8:1.

## Sack peek overlay
- **Scrim** (0,0,1680,1040) #100e0c at **75%**, z 50, mouse STOP. Click or Esc closes it. While it's open, set the rope TitleBand, Headline, Sub, Sign, Climb, Delve and Peek to `visible=false` and move focus into the overlay. Restore them on close, so no rope text shows through.
- Panel `parchment_panel_9` (440,136,800,768), z 55. Title `sack.title` 48->24. Count `sack.new_count` {n} / `sack.none` 32->20, 2 lines. Grid 5x2 (cells 120x152) uses the existing item card renderer. Hint `sack.hint` 28->16, 2 lines. Close PrimaryButton (640,776,400,96) `sack.close`.
