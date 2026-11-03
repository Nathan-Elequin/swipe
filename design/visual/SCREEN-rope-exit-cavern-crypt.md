# SCREEN: Rope Exit cavern — Crypt Classic (replaces ChatGPT #320 plates)

Viewport 1680×1040. Art is Crypt Classic (Pillow): 1px `#100e0c` outline, ~44 colours, native 420×260 → 4× nearest.

## Plates
| file | size | notes |
|---|---|---|
| `assets/dungeon/home/overlays/rope_exit_cavern_bg.png` | 1680×1040 opaque | lived-in chamber; clear tally wall rect; green shaft; gate zone right |
| `rope_exit_hatch.png` | 256×256 RGBA | wooden hatch over shaft |
| `rope_exit_gate_frame.png` | 384×512 RGBA | posts+lintel; aperture transparent |
| Keep existing `rope_exit_gate_open.png` / `rope_exit_chains.png` / `rope_exit_socket_filled.png` OR hide until redrawn — prefer hide chains/open if they clash with painterly style; frame alone OK for v1 |

## Dynamic tallies
See `TALLY-SPEC.md`. Lifetime save field (Nathan lock). Wall rect native (92,82,56,44). At count≥50 show `tally/tally_bartleby_chalk.png` (or 4×) instead of strokes.

## Sit mounts (future Sprout stretch — do not animate now)
Crate top, bench, rope coil baked in BG; later may split to overlays.

## Copy
No new player-facing strings. Flag Spin if any reveal toast is wanted later.
