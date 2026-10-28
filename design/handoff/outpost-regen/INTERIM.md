# Interim PixelLab pack (v3)

**Status:** plumbing / F5 interim only.

Nathan locked a hybrid visual pipeline (2026-10-28):

- **Doop frames** are the fidelity north star (nearly shippable alone). Canvas: https://doop.design/c/K5t2l_veMo — frame D cabinets + map-in-hands frames.
- **PixelLab** is for individual sprites / reusable tiles woven *into* those designs — not a from-scratch redesign that ignores Doop.

This folder’s contact sheets + the PNGs installed under `assets/dungeon/home/mudroom/`, `assets/dungeon/home/cabinets/case_*`, and `assets/ui/map/held/` are **interim** so wall/Space → held-map wiring works on `playtest/latest`.

Do **not** treat PixelLab cases or room layers as final look. Keep Godot load paths stable so the next PR can swap textures to Doop-matched plates/crops without rewiring.
