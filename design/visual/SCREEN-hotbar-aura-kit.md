# SCREEN — Hotbar aura kit (Direction A)

Doop: https://doop.design/c/hxBhJPS8pX  
Locked by Nathan 2026-11-01. Viewport context 1680×1040; this is a hotbar component system, not a full screen.

## Intent
Uniform but distinctive markers: same gameplay function → same subconscious language; differentiate with color + pattern + source stamp. Spin owns all player-facing copy (designer tags only in mockups). Approved phrase: `Petrified while the Basilisk remains`.

## Roles (Direction A)
| Role | Hex | Pattern | Used for |
|---|---|---|---|
| READY | #F2A93B | Solid ring + Tween α pulse ~1.6s | Recycler@1, Magnet armed, Pacemaker/Potion armed |
| WARNING | #E8553E | Dashed ring, static | Rust hover, Decay partner, Gaze will-petrify, Beggar thin outline |
| CHOICE | #7CC8F0 | Double thin ring, no pulse | Merchant upgrade candidates, toss-pick |
| LINK | #8E72F2 | Violet border + TL diamond + chain between pair | Decay linked pair idle |
| UNPLAYABLE/USED/PETRIFY base | #8A8F96 | Grey desat + 8px diagonal hatch | Spent, unplayable, ALL petrify |
| Gargoyle source | #B9A58A | 34px BR stamp + segmented top band | Clears next Spin |
| Basilisk source | #9DB86E | 34px BR stamp + dotted scale rim | While Basilisk remains (NOT spin-clear) |
| Hex@1 | #5FD3A0 | Mint filled face | Good countdown — never red |
| Toll@1 | #C41E1E | Inverted crimson + wash | Only lethal cue |

Priority: Petrify/Unplayable > WARN > CHOICE > READY (one aura at a time).

## Basilisk Stone Gaze (rules lock + open edges)
- On dungeon enter: Gaze aura + Basilisk stamp on **random eligible** items (Decay-style; not spent), up to 3.
- Hover one gazed item → other gazed items get WARNING ("will petrify if used") — copy TBD Spin.
- Use one → other 2 Petrified (hatch+grey + B stamp + sub-tooltip locked phrase) until Basilisk Defeated / Slain / Escaped / Polymorphed. **Not** freed on Ejected/Catapult.
- Engineering: **separate state** from Gargoyle `petrified` (tip clears every Spin).
- Open (do not invent — leave TODOs / Spin): what counts as Use; <3 eligible; Quiet Bell; Ejected duration.

## Godot
- Rings: StyleBoxFlat expand / NinePatchRect dashed+double textures under `assets/ui/aura/`
- Pulse: Tween modulate.a on READY only
- Hatch: tiled 8px diagonal TextureRect + existing desat; petrify shader **gains** hatch (Nathan override)
- Stamps: Nearest filter PNG 34px BR (reuse bag-stamp slot)
- Shatter: existing petrify_shatter / particles — no blur
- Paths: `assets/ui/aura/…`, stamps `assets/ui/stamps/…`, theme notes in `themes/swipe_theme.tres` if needed
- Never show the word Tier to players.

## Out of scope this PR
Player copy strings (Spin). Dead-code cleanup (petrify_n, hunter_mark, bushido dummy, hydra callers) optional small follow-up.
