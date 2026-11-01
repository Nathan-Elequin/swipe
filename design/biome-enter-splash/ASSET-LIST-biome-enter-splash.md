# ASSET LIST: Biome-enter splash

Folder: `res://assets/ui/biome_splash/`
Import (every PNG here): **Filter = Nearest** (project default is fine if it's already Nearest; otherwise set `texture_filter = TEXTURE_FILTER_NEAREST` on the node), Mipmaps off, Compress = Lossless, Fix Alpha Border on.
Pixel scale: art is authored at **native 1680×832**. No runtime upscaling of the BG. Sprites (Sprout, leaf) scale by whole numbers only (×5, ×2).

## Naming

`<kind>_<biome-slug>[_<variant>].png`
- kind: `bg` (art region), `fx` (overlay), `cue`, `panel`
- biome-slug: `verdant`, `crystal`, `ashen`, `cinder`, `shadow` (first word of the campaign biome name, lowercase; the copy keys use the full slug, e.g. `verdant_hollow`)
- variant: `placeholder` while unpainted. When the painted file lands with the same name minus `_placeholder`, the code prefers it automatically.

Lookup rule in code: try `bg_<slug>.png` → fall back to `bg_<slug>_placeholder.png` → fall back to `res://assets/ui/biome_full/bg_wheel_<biome_id>.png` cropped (TextureRect cover, top-anchored).

## Pass 1: placeholder (wire now)

| File | Size | Source | Use |
|---|---|---|---|
| `assets/ui/biome_splash/bg_verdant_placeholder.png` | 1680×832 RGB | Top 832px crop of `assets/ui/biome_full/bg_wheel_b1.png` (tip). Box copy: `/workspace/biome-enter-splash/placeholder/bg_verdant_placeholder.png` | Art region BG |
| `assets/ui/biome_splash/cue_leaf_placeholder.png` | 12×12 RGBA | Pixel leaf from the Doop mock (#9cc45a / #5f8f3c / stem #7A4E2B). Box copy in `placeholder/` | Click cue, drawn ×2 |
| *(reuse, no copy)* `assets/dungeon/anim/player/sprout_idle_f0.png` | 64×64 | Existing wheel-centre hub Sprout ("New Sprout") | Hero, ×5 = 320×320 |
| *(code only)* vignette | 1680×832 | `GradientTexture2D` radial, center transparent → edge rgba(11,7,6,.7) | Art overlay |
| *(code only)* bottom fade | 1680×72 | `GradientTexture2D` linear vertical, rgba(11,7,6,0) → .85 | Art/bar seam |
| *(code only)* narration panel | 1680×208 | `StyleBoxFlat`: bg #1A120E, border_top 6 #7A4E2B; inner `StyleBoxFlat` bg #211610, border 4 #3B2618 | Bar |
| *(code only)* fireflies | | `CPUParticles2D`, 24 amount, 2×2 px #E8D36A, lifetime 4s, gravity 0, slow drift | Ambience (optional) |

Other biomes for pass 1: no splash unless `splash.biome.<slug>` exists (see SCREEN §1). Once a key exists and painted art doesn't, use the `bg_wheel_bN` crop fallback.

## Pass 2: painted (later, ChatGPT/Doop)

| File | Size | Notes |
|---|---|---|
| `bg_verdant.png` | 1680×832 | Painted scene. Path/clearing on the left third for Sprout at (500..820, 432..752); ground line ≈ y 744–752. **Monster hint = eyes only**, around (1200..1400, 430..650), e.g. glints in a hollow tree mouth. No bodies. Leave the top-left 330×150 calm (low detail) for the chrome. Bottom 72px darkens into the bar. |
| `fx_verdant_vignette.png` | 1680×832 RGBA | Optional painted vignette to replace the code gradient. |
| `panel_narration.png` | 9-slice source, 24px margins | Wood/leather frame matching the cabin UI. `StyleBoxTexture`. |
| `cue_leaf.png` | 12×12 | Final leaf (may be the same as the placeholder). |
| `bg_crystal.png`, `bg_ashen.png`, `bg_cinder.png`, `bg_shadow.png` | 1680×832 | Only after Spin writes `splash.biome.<slug>` for each biome. |

## Checks before merge

- [ ] Every PNG imports Nearest, mipmaps off (`.import` shows `filter=false` / project default Nearest).
- [ ] BG is exactly 1680×832. Sprout is drawn at an integer scale.
- [ ] No text baked into any art. All words come from player-copy keys.
- [ ] No Tier glyphs or pips in any asset.


## Copy keys (Spin)
- `splash.chrome.continue` = `click anytime` (leaf cue label; keep leaf)
