# Title still — type and the hub hole

Viewport **1680×1040**. Painting native **420×260**, shipped 4× nearest.

Code draws type in ThemeDB fallback font. Pixel does not paint Click to continue. Pixel paints the name only after NAME.md is locked.

## Shipped rects (px)

Keep important faces **out** of the hub hole. Put Sprout / Nib / the mountain read in the upper 45% and the outer thirds.

- Full still: `(0, 0, 1680, 1040)`
- Logo / title: `(340, 80, 1000, 160)` — upper third, centred
- Tagline: `(260, 250, 1160, 80)` — `Use it, Lose it, or Lose your head`
- Click to continue: `(340, 920, 1000, 80)`
- Hub overlay after click (dim ~60%): centred stack ≈ `(480, 260, 720, 520)`

Native equivalents (divide by 4): logo `(85, 20, 250, 40)`, tagline `(65, 62.5, 290, 20)`, click `(85, 230, 250, 20)`, hub hole `(120, 65, 180, 130)`.

## Layers

1. `title_still.png` full bleed
2. `logo.png` if separate, in the title rect
3. Tagline (code)
4. Click to continue (code, pulses)
5. After click: hub buttons on top, still visible through the dim

## Do not

- Brand New / Middle Progress on this page
- New UI words
- “Tier” or “owner”
- English in the PNG before the name lock
