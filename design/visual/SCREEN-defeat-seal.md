# SCREEN: Defeat spotlight wax seal (B.S. attribution)

Build brief for the journal quote beat on defeat. Source: `scripts/ui/defeat_spotlight.gd`.
Art: existing cabin overlays only — no new PNGs, no Spin `defeat.journal.*` copy edits.

## Layout (inside QuoteBox)

- **AttribRow** — `HBoxContainer`, centered, separation **10**. Sits under the thin rule, centered under the quote.
- **Seal** — `Control`, `custom_minimum_size` **56×52**, pivot at center. Left child of AttribRow.
  - **SealIntact** — `TextureRect` fills Seal. `res://assets/dungeon/home/overlays/wax_seal.png`. `texture_filter = NEAREST`, `stretch_mode = KEEP_ASPECT_CENTERED`.
  - **SealBroken** — same fill. `res://assets/dungeon/home/overlays/wax_seal_broken.png`. Starts `modulate.a = 0`.
- **Attrib** — existing `— B.S.` Label (`defeat.journal.attrib`). Right of Seal. Do not rewrite Spin journal quote copy.

## Timing

1. Quote + monogram + **intact** seal fade in together (~2s quote fade/drift).
2. When the quote finishes drifting up: crossfade SealIntact `a` 1→0 and SealBroken `a` 0→1 over **~0.4s** in parallel; optional scale punch on Seal **1.0 → 1.08 → 1.0**.
3. Broken seal stays visible while **Limp home** / **Quick start** fade in. No Undo. No Tier / ATK in UI.

## Out of scope

- Quote text / journal keys.
- New seal art.
- Undo button.
- itch export.
