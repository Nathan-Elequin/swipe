---
id: REQ-20261106-phantom-shroud-presentation
status: open
priority: high
branch: cursor/phantom-shroud-presentation-c9bb
base: playtest/latest
created: 2026-11-06
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → seeded fight with Phantom (Roster / pool so Phantom appears)
---

# Phantom Shroud presentation (full black curse veil)

Nathan F5 2026-11-06: enshrouded items must be completely unidentifiable — full black, curse look, shroud overlay, still obviously clickable/playable. Collector unchanged. No slash/portrait/SFX this PR.

## What to verify

- Using a non-Shrouded item while Phantom lives shrouds 1 other hotbar item and slides it to the end.
- Shrouded plates are solid black with ? / void wisps, curse rim, READY aura while clickable.
- No title, art, numbers, New! badge, or inspect identity leak while shrouded.
- Click a shrouded playable → reveal then Use (does not re-trigger Dark Matter). A Keep stays clean after that use.
- Click a shrouded Unplayable → reveal + discard.
- Defeat Phantom → shrouded items stay veiled at the end of the bar.
- Collector Bag / Discard−2 still behave as before.

## Screenshots required

| id | surface | setup | pass | filename |
|----|---------|-------|------|----------|
| 01 | fight | Face Phantom; Use a non-Shrouded item with ≥2 other hand items | Exactly 1 hotbar card is a full black curse/? veil at the end of the bar; READY ring if clickable | 01-phantom-shroud-veil.png |
| 02 | fight | Hover a shrouded card | Inspect title ??? / Curse; no real name, art, or numbers | 02-shroud-inspect.png |
| 03 | fight | Click shrouded playable | Reveals then Uses; Phantom does not shroud again from that Use | 03-shroud-reveal-use.png |
| 04 | fight | Defeat Phantom while a shroud remains | That card stays a curse veil at the end of the bar | 04-phantom-defeat-stays-shrouded.png |

## Outbox

`playtest/repot/outbox/REQ-20261106-phantom-shroud-presentation/`

## Gaps (honest)

- Cloud agent — no Godot F5. Local Cherry fulfills shots.
- Slash portraits / anims / SFX deferred (Nathan: less important).
