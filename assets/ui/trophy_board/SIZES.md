# Trophy board UI: sizes, anchors, timing

Crypt Classic. Drawn at native size, shipped at **x4 nearest-neighbour** (no exceptions in this folder). PNG RGBA, Godot import Filter Off, Mipmaps Off. No text is baked into any file; plaque names and the "Start here" badge text are rendered in code.

| file | native | shipped | frames | notes |
|---|---|---|---|---|
| board_frame.png | 332x194 | 1328x776 | 1 | Transparent face window at native (12,22) 308x154. Plaque recess x103..228 y2..19. Cog sockets centred (6,58) and (325,58). Dot groove x127..205 y178..190. Feet rows 191..193. |
| board_trim_gold.png | 332x194 | 1328x776 | 1 | Gold-leaf overlay, same registration as the frame, transparent window. |
| rail_cog.png | 12x12 | 48x48 | 1 | 8 teeth, 4-fold symmetric (rotate 90 per slide). |
| face_bg_{verdant,crystal,ashen,cinder,shadow}.png | 308x154 | 1232x616 | 1 each | Opaque, fills the face viewport. |
| crest_{slug}.png | 24x24 | 96x96 | 1 each | |
| plaque_{slug}.png | 120x24 | 480x96 | 1 each | Flat brass centre x14..106 y6..18 for the code-drawn name (ink #1c120c). |
| padlock.png / padlock_hover.png | 40x48 | 160x192 | 1+1 | |
| light_off.png / light_on.png | 12x16 | 48x64 | 1+1 | |
| light_flash_f0..f3.png | 12x16 | 48x64 | 4 @ 16 fps | f3 = light_on. |
| lever_locked / lever_ready / lever_pulled.png | 16x32 | 64x128 | 1 each | Pivot hub at native (7.5,17.5). |
| lever_pull_f0..f4.png | 16x32 | 64x128 | 5 @ 12 fps | f0 up, f4 down (= lever_pulled). |
| lever_glow.png | 32x48 | 128x192 | 1 | 3 stepped alpha rings. Place at lever origin - (32,32) px. |
| arrow_{l,r}_{idle,hover,press}.png | 12x20 | 48x80 | 6 | Drawn separately per direction. |
| dot_{locked,idle,current,hover}.png | 8x8 | 32x32 | 4 | |
| dot_new_pip_f0..f1.png | 4x4 | 16x16 | 2 @ 2 fps | |
| slot_recess_dark / _lit.png | 32x32 | 128x128 | 2 | Semi-transparent so it sits on any backdrop. |
| slot_recess_dark_s / _lit_s.png | 20x20 | 80x80 | 2 | Compact mode. |
| aura_claimed_f0..f5.png | 32x32 | 128x128 | 6 @ 8 fps loop | Clear centre 16x16. Draw behind the sprite. |
| aura_claimed_s_f0..f5.png | 20x20 | 80x80 | 6 @ 8 fps loop | Clear centre 10x10. |
| twinkle_f0..f3.png | 8x8 | 32x32 | 4 @ 12 fps | Centre pixel (3,3). |
| satchel_idle.png | 48x40 | 192x160 | 1 | Mouth at native (24,5). |
| satchel_open_f0..f3.png | 48x40 | 192x160 | 4 @ 12 fps | f3 = open with gold glow. |
| satchel_close_f0..f2.png | 48x40 | 192x160 | 3 @ 12 fps | f2 = idle. |
| rise_glint_f0..f5.png | 24x24 | 96x96 | 6 @ 15 fps | Burst origin native (12,20). |
| poof_f0..f4.png | 24x24 | 96x96 | 5 @ 20 fps | f4 empty. |
| dust_fall_f0..f2.png | 4x4 | 16x16 | 3 @ 8 fps | |
| splash/portal_{crystal,ashen,cinder,shadow,endless}.png | 420x208 | 1680x832 | 1 each | Opaque. Bottom 40 native rows are darkened one step for the Nib bar. |
| splash/shortcut_{crystal,ashen,cinder,shadow}.png | 420x208 | 1680x832 | 1 each | Same. |

Map pieces (`assets/ui/map/trophy/`), x4:

| file | native | shipped | frames | notes |
|---|---|---|---|---|
| fog_{crystal,ashen,cinder,shadow}.png | 48x32 | 192x128 | 1 each | Lineless parchment fog. |
| fog_clear_f0..f5.png | 48x32 | 192x128 | 6 @ 10 fps | f0 = fog_crystal shape; f5 empty. |
| node_glow_f0..f3.png | 40x40 | 160x160 | 4 @ 6 fps loop | Centre under the 112x112 stamp. |
| start_pointer.png | 12x16 | 48x64 | 1 | Tip at native (5..6,14). |
| badge_start_here.png | 40x12 | 160x48 | 1 | Blank centre for map.badge.start_here. |
| path_dash.png | 6x2 | 24x8 | 1 | Line2D TILE texture (4 px dash, 2 px gap). |
