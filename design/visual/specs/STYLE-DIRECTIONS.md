# Swipe art refresh: style directions (2026-10-11)

Status: **screenshot-checked against the 15 current shots (2026-10-11) · pending Jam review. Not for Nathan yet.**
Canvas: [Doop — Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX) · Mockups: `design/visual/mockups/`

All three are feasible in Godot 4.7 (gl_compatibility) at $0: NinePatchRect/StyleBoxTexture themes, Tween/AnimationPlayer, CanvasItem shaders for glow/tilt, CPUParticles2D, AnimatedSprite2D. All three use **16×16 art at 4×** (see PIXEL-SCALE.md).

## Recommendation: A · Torchlit Burrow + Layout 1 · Side Door
- It's closest to Jam's locked look (warm torch browns, gold loot, bronze/silver/gold rims, impish green only on Nib/player, 16 px) while every element gets redrawn.
- It fixes every draft-gate problem in the shots: dim overlay, Log collision, no Take button, the empty square.
- The dark ground keeps the lit-vs-empty alcove contrast and the "loot is the brightest object" beat.
- It's the cheapest to produce: CC0 16 px bases (0x72, Kenney Tiny Dungeon, Niji) can be recolored to this palette.

## A · Torchlit Burrow (recommended)
Mood: a thief's burrow lit by one torch. Mockup: `mockups/draft-gate-A-torchlit-burrow.png`
| Role | Hex |
|---|---|
| ground (soot) | #1A120E |
| panel (oak) | #3B2618 · inset #4A2F1F |
| frame edge | #7A4E2B · rivet #B8733A |
| text (parchment) | #E9D3A1 · secondary #A88C66 |
| **accent: loot gold (only bright accent)** | #FFD84A |
| rule / pips (torch amber) | #F09A34 |
| imp green (Nib/player only) | #7BC950 |
| ATK / monster red | #D5443B |
| BLK blue | #4FA3D9 |
| Weak / Tough / Deadly | #B8733A bronze / #C9CED6 silver / #FFD84A gold |
- Frame language: carved-oak 9-slice, 4 px iron rivets, parchment tags on twine, arch-top door, square corners. Glow only on loot.
- Type (OFL): [Pixelify Sans](https://fonts.google.com/specimen/Pixelify+Sans) display · [Silkscreen](https://fonts.google.com/specimen/Silkscreen) labels/numbers · [VT323](https://fonts.google.com/specimen/VT323) body.
- Motion: grab-and-run. 2-frame anticipation then snap (120 ms); loot bob/glow 1.2 s; door slam with 80 ms hit-stop and 6 px shake; coin sparkle on Take.
- Thief fantasy: torchlight on the loot, the monster's eyes glowing in the dark doorway, Nib peeking with a coin.
- Screenshot check: same warm field as today, so nothing in the ring loses contrast. Combat hit becomes an edge vignette plus hit-stop instead of a full red wash.

## B · Jeweler's Velvet (alt, bigger swing)
Mood: a jeweler's back room. Mockup: `mockups/draft-gate-B-jewelers-velvet.png`
ground #2B0F18 · tray #4A1A28 / #5C2233 · brass edge #C8923A · pearl text #F3EBDD · accent brass-gold #E8BE6A · emerald imp #2FBF71 · ruby ATK #E0413C · sapphire BLK #3D7BD9 · Weak #B8733A / Tough #D8D8E0 / Deadly #E8BE6A
- Frames: velvet-lined trays, 10 px rounded brass corners, price tags on string, cracked display case as the door.
- Type: [Jersey 10](https://fonts.google.com/specimen/Jersey+10) display · Silkscreen · VT323.
- Motion: floaty card tilt shader, shimmer sweep, numbers count up, back-out easing.
- Option: 32×32 @2× portraits (more detail, about 4× the art cost).
- Screenshot check: reads well, but it drops Jam's locked parchment/torch look and leans toward Balatro. Red ATK badges lose contrast on the red ground and need dark plates. Medium risk.

## C · Chalk-Map Heist (alt, light)
Mood: the heist plan, inked paper. Mockup: `mockups/draft-gate-C-chalk-map-heist.png`
paper #E8DDC5 · card #F4ECDA · ink #231D1A · graphite #6E6358 · accent gold leaf #E2B33C · stamp red #C8372D · imp green #5E9E43 · BLK #3B6FB0 · Weak #B8733A / Tough #9AA0A8 / Deadly #E2B33C
- Frames: torn paper cards, tape corners, ink stamps (THE DOOR / THE LOOT), wanted-poster monsters, 2 px UI ink lines.
- Type: Pixelify Sans · Silkscreen · VT323.
- Motion: stamp slams (1.3→1, 60 ms), paper flutter on Pass, ink splat on hit.
- Screenshot check: the light ground flattens the glow-on-loot beat and makes the combat stage read like a document. Good for title and menus; weak in the dungeon. Highest risk.
