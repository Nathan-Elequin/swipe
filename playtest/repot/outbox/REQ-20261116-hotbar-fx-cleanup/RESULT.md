---
id: REQ-20261116-hotbar-fx-cleanup
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T17:05:00-06:00
machine: Cherry
tip_sha: ac22d09ea4917f5b3f8c818fa84c069934f1701d
godot: F5 playtest, Brand New, real mouse/Space, no debug_seed / debug_pose / Grant uniques
viewport_grab: 1550x960 window (logical layout 1680x1040)
on_screen_sha: ac22d09e*
---

# Result

Played Brand New on `playtest/latest` @ `ac22d09e`. Build stamp `ac22d09e*`. Music in the Verdant fight: `res://assets/audio/music_verdant_hollow_loop.ogg` (`music_state` dungeon).

Opening hotbar (drafted): Throwing Knife, Net, Breastplate (inspect: Rare), The Boot, Fangs, Victory Flask. No Revival Potion, no Danger Magnet.

| id | verdict | note |
|----|---------|------|
| 01 | pass | `01-no-flecks.png` — Breastplate is Rare; no `deadly_sparkle` / fleck nodes in the live tree and no orbiting sparkle dots on the plate. Rarity sweep is not readable because NewStar covers the plate (see 03). |
| 02 | fail | Revival Potion never appeared on Brand New. `02-armed-swirl.png` is the same mid-fight frame as 03 (Victory Flask Keep, not Revival). No quiet rim-only auto-fire swirl to judge. |
| 03 | fail | `03-new-star-fight.png` — `NewStar` exists, visible, texture `res://assets/ui/hud/new_star.png`, but `size` is 166×144 at pos (4,1) filling the whole plate, not 28×28 top-right. Item art reads as a stretched gold star. Six hotbar item_cards all had `star_vis=true`. |
| 04 | fail | Never claimed a unique on the trophy board (`swiped_n` 0 after limp-home). `04-star-cleared.png` is the same unclaimed fight frame. |

## Blockers

- NewStar layout: star fills the card, so rarity sweep / swirl / 28×28 placement cannot be judged as specified.
- Revival Potion is not in the Brand New opening kit; did not cheat it in.

## Shots

`playtest/repot/outbox/REQ-20261116-hotbar-fx-cleanup/shots/`
