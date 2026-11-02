---
id: REQ-20261102-decay-pip-size
status: open
priority: high
branch: cursor/decay-pip-overlay-c341
base: playtest/latest
created: 2026-11-02T05:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → delve → fight; Spin a Zombie so Decay lands on hotbar items (Spider Egg / Victory Flask preferred)
---

# Decay pip/chain stay tiny (no full-card purple blob)

Cloud layout fix only in `scripts/item_card.gd`: PanelContainer was stretching `decay_pip` / `decay_chain` TextureRects to the full card. They now parent to a plain full-rect `DecayOverlay` Control (`clip_contents=false`) so the TL diamond stays ~12×12 and the chain stays 24×12 half-off the partner edge. No PNG art changes; LINK ring elegance and zombie ban glyph untouched.

## What to verify

- After Zombie Decay on a linked pair: each affected item shows a tiny violet diamond in the top-left, not a purple plate over the icon.
- Item art (Spider Egg / Victory Flask / any Decay target) fully readable under the pip.
- Linked pair shows the small chain glyph mid-edge toward the partner (half off the plate), not stretched.
- Solo Decay (if shown): tiny TL pip only — still no full-card blob.
- Thin violet LINK ring from elegance pass still present; READY / WARN / CHOICE unchanged in spirit.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | Zombie Decay linked pair on hotbar, idle | tiny TL violet diamond + mid-edge chain; icons fully readable (no purple fill) | 01-decay-pip-tiny.png |
| 02 | fight hub | Close crop of one Decay item (Spider Egg or Victory Flask) | pip ~12px corner; art readable through; no card-sized blob | 02-decay-pip-closeup.png |

## Pass criteria

- Pip reads as a small corner diamond, not a full-card overlay.
- Chain is the small edge glyph, half off toward partner.
- No art file changes required for the pass.

## Outbox path

`playtest/repot/outbox/REQ-20261102-decay-pip-size/`

Cloud cannot F5/godot-mcp — local Cherry drain required.
