# T4-pngcheck

## Status

PASS. Started from `aa2bfd6` on `task/T4-pngcheck`. No Pixel checkpoint commit existed for this task.

## Commits

- `e475e61` T4-pngcheck(1): add a checker for PNG imports and shipped sizes
- `645385c` T4-pngcheck(2): add an example PNG size list that matches two real files
- T4-pngcheck(3): this report and `design/audit-shots/cursor/png_check.json`

## Files changed

- `tools/qa/check_ui_pngs.py`
- `design/visual/sizes/_example.sizes.json`
- `design/audit-shots/cursor/png_check.json`
- `design/handoff/T4-pngcheck/REPORT.md`
- `design/handoff/.gdignore`

## Checks run + results

- `py -3 tools/qa/check_ui_pngs.py` — exit 0. Checked 988 PNGs that have a `.import` (`assets/ui` 25, `assets/dungeon` 963). Failures 0. Both size-list paths are inside that 988. JSON `updated` is `2026-10-17T22:07:19-05:00`.
- `py -3 tools/qa/check_ui_pngs.py --only "assets/ui/**"` — exit 0, checked 25, failures 0.
- `py -3 tools/qa/check_ui_pngs.py --only "assets/ui/map/route_dot_idle.png"` — exit 0, checked 1, failures 0.
- The full command was run again after the `--only` trials so `png_check.json` is the 988-file result.
- A throwaway parser check (not committed): a parent `texture_filter = 2` flags the child UI PNG; a child set to `1` (Nearest) does not; `compress/mode=2`, `mipmaps/generate=true`, and `flags/filter=true` each fail.

## Deviations

- `_example.sizes.json` is an object with `_schema` and `assets`, so the schema note can sit in the file. The checker also accepts a bare JSON array. It compares IHDR to `shipped` only. `native` is not checked. Both example `native` values are the measured file size, because these two PNGs had no separate 1× source in the task.
- No PNG bytes and no `.import` files were changed. The run found nothing to list.
- No Godot process. This check does not need one.

## Questions

None.

## What Nathan should look at

No failures. There is no first-20 list.
