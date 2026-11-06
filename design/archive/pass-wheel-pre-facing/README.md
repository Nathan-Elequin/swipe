# pass-wheel-pre-facing

Archive of wheel seat PNGs **before** the facing-derived seat pass (2026-11-05).

## Why

`SCREEN-wheel-seat-from-facing.md` replaces every live monster's wheel seat with a difficulty-sized crop of its fight facing art (Deadly 32 native, Weak/Tough 24 native). Old bases + breathe pairs are kept here so a revert is a copy back — do not delete.

## Contents

- `<id>_wheel_base.png` + `.import`
- `<id>_wheel_breathe_f0.png` / `f1.png` + `.import`
- `NEW-manifest-v2.json` / `NEW-NOTES-v2.md` — snapshot of the v2 build that replaced these
- `NOTES.md` — same as the v2 batch notes

## Restore

```bash
cp design/archive/pass-wheel-pre-facing/<id>_wheel_*.png assets/dungeon/anim/wheel/
# then restore matching .import files from this folder
```

Live path after the pass: `assets/dungeon/anim/wheel/<id>_wheel_base.png` plus `<id>_wheel_idle_fN.png` idle strips.
