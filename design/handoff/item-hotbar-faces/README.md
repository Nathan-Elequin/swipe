# Item hotbar faces

24×24 Crypt Classic face glyphs for the item hotbar (shown at 24px) and offer cards (shown at 48px, nearest). Number labels sit centered on the icon with outline `#100e0c`, size 4.

## New faces → `assets/ui/icons/face/`

| File | Meaning |
| --- | --- |
| `nw.png` | Neighbor arrow up-left |
| `ne.png` | Neighbor arrow up-right |
| `east.png` | Arrow right |
| `far.png` | Arc pointing up |
| `cleave.png` | Curve covering left, front, and right |
| `spin.png` | Wheel with spokes |
| `retain.png` | Loop, no spokes |
| `hand.png` | Keep |
| `bag.png` | Closed bag, tiny sword mark |
| `flee.png` | Flee |
| `question.png` | Question mark (also `bagq`) |
| `slash.png` | Choice slash |
| `swap.png` | Two bags exchanging |

## Unchanged shared icons

- `assets/ui/hub/heart_full.png`
- `assets/ui/icons/atk_burst_single_s24_2x.png`
- `assets/icons/shield.svg`
- `assets/icons/skull.svg`
- `assets/icons/droplet.svg`
- `assets/icons/ban.svg`
- `assets/icons/copy.svg`

## Code

- Paths: `scripts/item_face.gd` → `_path_for` / `tex_for`
- Recipes: `scripts/main.gd` → `_face_rows` (do not invent or restyle here)
- Contact sheet: `CONTACT_faces_v1.png` (heart + burst + 13 faces)

Do not regenerate art. Do not load `assets/icons/face_*.svg`.
