# SCREEN: Rope exit (Grandpa's Emergency Exit) + Sack peek overlay

Mockups: `design/visual/mockups/rope-exit.png` (Climb hovered), `rope-exit-sack-peek.png` (overlay open).
Layouts: `design/visual/layouts/rope-exit.layout.json`, `rope-exit-sack-peek.layout.json`.
Source: `scripts/cabin/rope_exit.gd` (+ the sack peek overlay script).

## Art (cavern shell, 2026-11-02)

Full-screen background and prop plates live under `assets/dungeon/home/overlays/` (CabinKit `overlays/…` → `assets/dungeon/home/`). Nearest filter on every TextureRect / Sprite2D.

| Layer (bottom → top under chrome) | Path | Notes |
|---|---|---|
| Cavern BG | `overlays/rope_exit_cavern_bg.png` (1536×1024) | Full-rect, `STRETCH_KEEP_ASPECT_COVERED`. Legacy cozy `overlays/rope_exit_bg.png` kept on disk unused. |
| Home hatch | `overlays/rope_exit_hatch.png` | Over the green shaft hole (top-center). |
| Gate frame (locked) | `overlays/rope_exit_gate_frame.png` | Right-wall clear zone; 5 empty brass sockets baked in. |
| Gate chains (locked) | `overlays/rope_exit_chains.png` | X + padlock over the frame. Default on. |
| Gate open (reserved) | `overlays/rope_exit_gate_open.png` | Imported; hidden until an unlock flag exists. |
| Socket filled (reserved) | `overlays/rope_exit_socket_filled.png` | Single cyan gem icon. Imported for a follow-up; **socket-fill gameplay is deferred** — sockets stay empty art. |

Legacy cozy ladder / deeper-hole / torch flame sprites still load as nodes but stay `visible=false` so they do not clash with the painted chamber. Ladder and Hole **hit areas** plus Climb / Delve planks are unchanged.

Music: rest bed is already `music_between_dungeons` after dungeon clear (`audio_fx.gd`). Rope exit still cues `amb.rope_creak` as room SFX.

## Rope exit chrome
- **Title band**: ColorRect (0,32,1680,128) #100e0c at 60%, mouse IGNORE. Headline `rope.cleared` {n} (240,44,1200,56) 48->28, 1 line, cream #fff3d6. Sub `rope.sub` (240,104,1200,40) 32->20, 1 line, #e2d0b0.
- **Sign**: `assets/ui/rope/rope_sign_9.png` (text-free, 9-slice L24 T24 R24 B28) at (32,440,352,152). Inner text rect (60,468,296,92): `rope.sign` 32->16, max 2 lines, ink.
- **Climb home**: plank Button (32,712,360,144), z 20. Label `rope.climb` (52,730,320,44) 40->24, 1 line. Consequence `rope.climb_sub` (52,776,320,56) 28->16, 2 lines, #5a3a24. Action `_on_climb()`. The Ladder hotspot (384,0,160,904) runs the same action; hovering lights the Climb plank (legacy ladder hover art stays hidden on the cavern plate).
- **Delve deeper**: plank Button (1012,712,360,144), same size as Climb. Label `rope.deeper`, consequence `rope.deeper_sub` {n}=cleared+1. The Hole hotspot (1000,856,384,160) does the same; hovering lights the Delve plank (legacy hole hover art hidden).
- Both consequence lines are always visible. Don't swap label text on hover.
- **Peek in the sack**: smaller plank (624,716,240,64) above the goblin, label `rope.peek` 32->16. It opens the overlay.
- Plank states `btn_plank_{normal,hover,pressed,disabled}` (existing, 9-slice 16/16/16/20). Pointer cursor. Ink #3a2414 on face #d9c79c 8.7:1, hover face #f0e6d8 11.8:1.
- Hero / loot / Nib sit on the lit floor center; gate and hatch stay under chrome so Climb / Delve / title stay readable.

## Sack peek overlay
- **Scrim** (0,0,1680,1040) #100e0c at **75%**, z 50, mouse STOP. Click or Esc closes it. While it's open, set the rope TitleBand, Headline, Sub, Sign, Climb, Delve and Peek to `visible=false` and move focus into the overlay. Restore them on close, so no rope text shows through.
- Panel `parchment_panel_9` (440,136,800,768), z 55. Title `sack.title` 48->24. Count `sack.new_count` {n} / `sack.none` 32->20, 2 lines. Grid 5x2 (cells 120x152) uses the existing item card renderer. Hint `sack.hint` 28->16, 2 lines. Close PrimaryButton (640,776,400,96) `sack.close`.
