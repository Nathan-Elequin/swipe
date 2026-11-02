---
id: REQ-20261102-stat-pip-kit
status: open
priority: high
branch: cursor/stat-pip-kit-296c
base: playtest/latest
created: 2026-11-02T05:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → Adventure fight with Lich on the wheel; also open a draft/offer with a Defeat item and a Block item on the hotbar.
---

# Nathan-greenlit stat pip kit (skull / block / undying)

Wire `assets/ui/icons/pips/pip_{skull,block,skull_hp}_s24_2x.png` (48×48, Nearest, no mipmaps). ItemFace SHIELD/SKULL → block/skull pips with no blue tint on pip paths. main.gd tex_shield + skeleton/bodyguard/juggernaut/breastplate (and matching ability badges) → pip PNGs; lich ability stays droplet.svg. boss_wheel lich HP uses cached pip_skull_hp (skull-heart hybrid), outline=false, number y −0.14. `_draw_stat_icon` fringe only when outline=true; hearts stay WHITE modulate. No bear-trap / Decay overlay work.

## What to verify

- Lich seat HP reads as a funny skull-heart hybrid (two lobes + cleft forehead, eyes low, number on forehead).
- No white square / fringe halo around Lich HP.
- HP delta flash / punch still visible on the Lich pip (modulate lerp).
- Defeat-item skulls (hotbar 24 + offer 48) are the rounder 3D bone pip, not the old flat SVG.
- Block faces are whitish-blue 3D pip, not the old blue-tinted shield.svg.
- Normal monster hearts and atk bursts look unchanged.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight wheel | Lich on a seat at HP 2 (hover the HP pip if needed) | skull-heart hybrid; number clear on forehead; no white square | 01-lich-hp-2.png |
| 02 | fight wheel | same Lich after damage or heal so hp_d ≠ 0 | pip still readable; flash/delta visible | 02-lich-hp-flash.png |
| 03 | hotbar / offer | Defeat item face (e.g. Fangs / Toll) at hotbar size | rounder 3D bone skull pip | 03-defeat-skull-hotbar.png |
| 04 | offer / draft | Block item face (Breastplate / Shield) | whitish-blue 3D block pip, not flat SVG | 04-block-pip-offer.png |
| 05 | fight wheel | any non-Lich monster HP + ATK | heart and atk burst unchanged vs tip before this PR | 05-heart-atk-unchanged.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-stat-pip-kit/`
