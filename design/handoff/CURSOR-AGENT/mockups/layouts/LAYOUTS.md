# Full-8 wheel layout options (96px monsters), 2026-10-20
All four are 1680x1040 over wheel_ref.png (1680x1006; the bottom 34px is padded in floor colour). Every string is upright.
UI chrome comes from PixelLab (pl/clean/), Nearest only: banner and plate are 9-sliced at 4x, badges, chips and coins are at 3x, icons are at 2x inside chips.

| Option | Ability read speed | Clutter | 8-slot fit |
|---|---|---|---|
| A rim band | Fast: name, icon and call on every plate | Medium: 8 banners ring the wheel | Holds. The slice body is free. The 4 near-horizontal plates overhang the rim by about 30px, so they need about 40px clear around the wheel. |
| B compact chip | Slow at first (icon only), instant after learning. Hover or facing gives full text. | Lowest | Best. Tags are short, chips sit on the outward shoulder, and there is room left for the facing pop-out. |
| C upright in-slice | Fast: two lines in the slice | Highest: plate, sprite and stacked badges | Tight. The top slices' plates sit near the rim and the bottom ones just inside the hub ring. Long names (Clockwork Knight) will need a smaller font. |
| D side legend | Slowest: eye goes to the coin, then the legend | Wheel is cleanest, but the screen is busier | The wheel is trivially fine. It needs the left 420px, and the legend must re-sort or re-number after every collapse. |

Recommendation: B, with C-style text on the facing monster (its plate expands to name, icon and call). Add A's rim plates as an optional "show names" toggle if playtests show icon-learning friction.
