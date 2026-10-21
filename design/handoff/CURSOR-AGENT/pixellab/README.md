# PixelLab toolkit (sanitized from the run4 scripts)

All net-new art comes from the PixelLab API v2 (`https://api.pixellab.ai/v2`). The agent reviews one contact sheet per batch, does the grid and palette cleanup, and hand-draws only small fixes, or after two failed PixelLab tries.

## Setup
```bash
pip install -r design/handoff/CURSOR-AGENT/pixellab/requirements.txt
export PIXELLAB_API_TOKEN=...     # cloud: Cursor secret named PIXELLAB_API_TOKEN. Never write it to a file, log, or commit
export PL_RUN_DIR=$HOME/pl-runs/run5   # scratch dir OUTSIDE the repo (raw/, base/, work/, final/, showcase/, calls.log)
export PL_BUDGET=40                    # per-batch cap in generations, counted from calls.log
python3 -c "import sys; sys.path.insert(0,'design/handoff/CURSOR-AGENT/pixellab'); import lib; print(lib.bal())"   # free balance check
```
`pl.py` exits if the token is missing. The token is only ever sent as an `Authorization: Bearer` header. `calls.log` strips image base64 and never records headers.

## Files
| File | What it does |
|---|---|
| `paths.py` | env-configurable paths: `PL_RUN_DIR`, `PL_ART_SOURCE` (default `../art-source`), `PL_PALETTE` (default `../palette/spinheritance.hex`) |
| `pl.py` | auth, `b64()`, `balance()`, `save_images()` |
| `lib.py` | (was lib4) threaded `call()` with retries, background-job polling, a budget guard and calls.log; `pix()` = pixflux (palette `color_image`, optional `init_image`), `bitforge()` (style image), `anim()` = animate-with-text-v3 (first/last frame), `par()` parallel (keep 2–3 workers) |
| `common.py`, `clean.py`, `clean4.py` | palette snapping in Lab, `down(im,f)` mode downsample, `clean()` (islands, orphans, rebuilds the 1px `#100e0c` outline), `fit()`, `up()` |
| `procui.py` → `finui.py` | raw UI icon/anim outputs → `work/ui` → `final/assets/...` at native size |
| `pbase.py` → `pport.py` → `panim.py` → `finport.py` | monster full-body base → close-up crop → 4–6 frame cut-in anim → `final/assets/dungeon/anim/slash/` + `final/bases/` |
| `mons.py` | per-monster table `M[id] = (canvas, frames, action, desc, ref)` and `BASE` canvas sizes. Refs resolve into `art-source/run3/final`, `art-source/run4/refs` and `art-source/run2/final` |
| `sheet.py`, `showcase.py` | contact sheets and GIFs. Review one sheet per batch |
| `examples/u1.py, a1.py, u3.py, t_test.py` | the real run4 batch scripts (UI bases, UI anims, rerolls, a 1-gen test), useful as prompt and param references |
| `docs/openapi.json`, `docs/llms_now.txt` | PixelLab API reference snapshot (2026-10-20) |

The run4 working files (`raw/`, `base/`, `work/crop/`, `pchoice.json`, `pachoice.json`) are in `../art-source/run4/`. For a re-roll, copy the inputs you need (for example `work/crop/hornet_swarm.png`) into your `PL_RUN_DIR`.
