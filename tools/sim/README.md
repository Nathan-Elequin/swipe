# Offline balance Monte Carlo

Pure-data Python simulation of Spinheritance combat using `data/catalog.json`.
No Godot / no `main.gd` changes / no catalog number edits.

```bash
# from repo root
python3 tools/sim/balance_mc.py --trials 300 --seed 7 --out playtest/balance
```

| Output | Path |
|---|---|
| Markdown summary | `playtest/balance/REPORT.md` |
| Aggregate CSV | `playtest/balance/summary.csv` |
| Heatmap | `playtest/balance/heatmap.csv`, `heatmap_focus.md` |
| Review flags | `playtest/balance/outliers.md` |
| Assumptions | `tools/sim/ASSUMPTIONS.md` (copied into out dir) |

Flags are for **human design review**, not auto-nerfs.
