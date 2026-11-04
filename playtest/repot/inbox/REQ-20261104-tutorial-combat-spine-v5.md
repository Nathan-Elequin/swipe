---
id: REQ-20261104-tutorial-combat-spine-v5
status: open
priority: high
pr: pending
tip_sha: c28989c3
branch: playtest/latest
created: 2026-11-04T08:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → intro through road overlay → Yes
---

# Tutorial combat spine v5 (road Yes path)

Replaces tip `tutorial.line.001–071` with the v5 road-to-cabin combat curriculum (Golem Keep/Flail → Goblin Boot/Take → Fangs Golem #2 → Harpy A Arrow Head → Harpy B Shield/Knucklers → Dragon Flail → D2 free play with Commander). Road wrapper / Skip → reveal → arrive unchanged from PR1.

## What to verify

- Brand New Yes starts Nib rails on the ambush board (no cabin interrupt).
- No Nib VO blips during tutorial lines (text-only).
- Chrome Skip still lands pool-1 reveal → intro_p5 arrive → free cabin.
- O1 Skip still lands the same way.
- Cabin dummy still offers tip replay after arrive.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road/tutorial | Brand New → Yes → first Nib line (B01) | Nib talk box over road wheel; Skip chrome visible; no cabin yet | 01-b01-nib.png |
| 02 | road/tutorial | Advance to Golem #1 Breastplate beat (B15–B19) | Breastplate spotlight; Take 1 armed; Shield click nudges | 02-golem1-block.png |
| 03 | road/tutorial | After Goblin choice Boot path through Fangs (B32) | Full HP; Breastplate Kept; Flail live | 03-fangs-payoff.png |
| 04 | road/tutorial | Harpy B after Shield (B44) then Knucklers | Boot path one-shots OR Take path nicks then Boot finish | 04-harpy-b.png |
| 05 | road/tutorial | Dragon Flail kill (B49–B50) | Dragon dies to Flail; clear juice | 05-dragon-flail.png |
| 06 | cabin | Skip from mid-rails OR finish Yes → arrive | intro_p5 / exterior arrive then free cabin; dummy still clickable | 06-arrive-cabin.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261104-tutorial-combat-spine-v5/`
