---
id: REQ-20261104-tutorial-slice-c-combat
status: open
priority: high
pr: 377
tip_sha: e86e9ca1
branch: playtest/latest
created: 2026-11-04T18:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → road overlay → Yes (Nib tutorial)
---

# Tutorial Slice C — combat spine + live UI + Nib rewrite

Cloud agent cannot F5. Cherry: Brand New → Yes smoke on `playtest/latest` after this PR merges (or on the PR branch).

## What to verify

- Live campaign chrome from combat start (hotbar + Move arrows visible; arrows disabled until Move teach).
- Arrow Head already in hotbar (not mid-Harpy grant).
- Only the opening Spin is a player click; later Spins are Continue → auto-spin.
- T2 Fangs host is Shark (ATK 3 HP 6); Breastplate Block 2 → take 1 still teaches.
- After Harpy A: warn → auto-spin lands on Dragon → Move onto Harpy B → Shield only (no Knucklers) → Take 0 → Flail Dragon.
- Goblin: one of Breastplate / Shield / Boot, then Take (or Take alone) — no multi-item.
- Wheel collapse demo before late Harpies.
- Next/Continue clickable on Cute / Evasive / Harpy lines; no loot click-through behind “Down here's your loot.”
- Prose paint: “this one” not number-chromed; keywords Block/Flee/Evasive/Move/Keep/Facing/Immediately highlight.
- Mid-rails Skip still → reveal → arrive; cabin dummy still replays `_start_tutorial`.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road combat | Brand New → Yes → past B01 | Live hotbar + Move arrows visible; Arrow Head in bar | 01-live-chrome-arrow-head.png |
| 02 | road combat | After Wizard/Shield; Continue past Golem prompt | Auto-spin lands Golem (no player Spin) | 02-auto-spin-golem.png |
| 03 | road combat | After Goblin teach; Fangs host seated | Shark (or noted T2) on wheel with Fangs granted | 03-t2-shark-fangs.png |
| 04 | road combat | After wheel collapse; Harpy A dead; Hope Continue | Auto-spin on Dragon; Move highlight toward Harpy B | 04-harpy-dragon-move.png |
| 05 | road combat | On Harpy B after Move | Shield armed; no Knucklers; Take 0 path | 05-harpy-b-shield-only.png |
| 06 | road combat | B23 “Cute. Don't trust it.” | Next/Continue clickable; dialog on top | 06-continue-clickable.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Mid-Skip still reaches pool-1 reveal → intro_p5 arrive.

## Outbox path

`playtest/repot/outbox/REQ-20261104-tutorial-slice-c-combat/`
