# T3-midword

## Status

PASS (code) / shots pending

## Checkpoint

`aa2bfd6db82a4c95faff550bd4bab3b88ccd1b48`

## Commits

- `ec3ac6f` T3-midword(1): flag non-word-smart wrap and line breaks that fall inside a word.
- T3-midword(2): this report (the commit that adds this file).

## Files changed

- `scripts/dev/text_audit.gd`
- `scripts/dev/text_audit_selftest.gd`
- `scripts/dev/text_audit_selftest.gd.uid`
- `design/handoff/.gdignore`
- `design/handoff/T3-midword/REPORT.md`

## Checks run + results

Headless self-test (does not boot `main.gd`, does not touch `user://`). Exit 0.

```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

SPACE_WIDTHS hello=39.0 both=87.0 used=47.0
CASE wrap_mode path=WordMode mode=AUTOWRAP_WORD reasons=[wrap_mode:AUTOWRAP_WORD] ok=true
CASE mid_word path=SplitWord mode=AUTOWRAP_WORD_SMART reasons=[mid_word] ok=true
CASE ellipsis path=EllipsisWord mode=AUTOWRAP_WORD_SMART reasons=[] ok=true
CASE space_wrap path=SpaceWrap mode=AUTOWRAP_WORD_SMART reasons=[] ok=true
SPACE_LINES 2
SELFTEST_OK
```

Command:

```
& "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\Natha\Documents\boss-rush-wt\T3-midword" --quit-after 1 --script "res://scripts/dev/text_audit_selftest.gd"
```

## Shots

None. This branch has no `--shots` entry yet. No windowed Godot.

## Audit

No `text_audit.json` from a play session. New reason codes, same failure keys (`screen`, `path`, `reason`, `shot`, `kind`, `text`):

- `wrap_mode:AUTOWRAP_WORD` or `wrap_mode:AUTOWRAP_ARBITRARY` (mode is the suffix, same shape as `overlap:<path>`)
- `mid_word`

`AUTOWRAP_OFF` and `AUTOWRAP_WORD_SMART` are allowed. A word-smart line that is ellipsized on one visible line is not `mid_word`.

## Deviations

- A hard newline is a separator, same as a space or hyphen. The failure is a wrap whose characters on both sides are letters or digits.
- `FitLabelBox` is judged by its inner `Label`, because the audit already lists the box and skips that child.
- Headless `--import` rewrote `project.godot` and `default_bus_layout.tres`. Both were restored and not committed. New `.import` sidecars from that import were deleted.

## Questions

None.

## What Nathan should look at

No acceptance PNGs. Nothing to play for this task.

## Verify (pending, windowed)

Run only after Nathan is out of the Godot editor. This boots the game and writes `user://`.

```
& "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\Users\Natha\Documents\boss-rush-wt\T3-midword" -- --text-targets
```

Then read `design/cli-runs/02-fx-tooltips/text_audit.json`. Failures from this change use `wrap_mode:` and `mid_word` in `reason`.
