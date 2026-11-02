---
id: REQ-20261102-hotbar-item-card-layout
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-02T11:41:00-06:00
machine: Cherry
tip_sha: 97f03bb2
godot: F5 playtest (godot-mcp) — Stop Play, F5, skip intro, Middle Progress then qa_staging_fight idle 2×5 (no hover)
viewport: 1680x1040
branch: cursor/hotbar-item-card-layout-888f
---

# Result

Idle fight hotbar at 1680×1040 on `cursor/hotbar-item-card-layout-888f` (`97f03bb2`). Mouse warped to (16,16); no hover on target plates. Item sprites 58px; titles ~2px from plate top. Face host ~64px starting at y≈78. Nearest filter. No player-facing “Tier”.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Chakram title sits high and the sprite is the new 58px size, but the lower band is a thin dash, not a ~36px centered impact burst with a number. `01-weapon-chakram.png`. |
| 02 | pass | Left Bracer: shield-6 + direction arrow ~36px, row in the leftover band under the sprite, no clip. `New!` badge overlaps the bottom edge. |
| 03 | pass | The Boot: skull 36×36 at plate-relative y≈92 in the 78–148 lower band; visually centered. Title high. |
| 04 | pass | Fangs: burst / skull / heart (3 icons) fit, centered, no clip. Throwing Knife on the same row shows 4 icons. |
| 05 | pass | Full 2×5 at 1680×1040, no hover. Every plate shares title-high / bigger sprite / face-in-lower-band. Titles consistently high. Chakram’s empty face is the only content miss (see 01). |

## Blockers

None for capture. 01 fails the impact-glyph expect on idle Chakram with a single copy in hand.

## Shots

- `shots/01-weapon-chakram.png`
- `shots/02-block-bracer.png`
- `shots/03-skull-boot.png`
- `shots/04-multi-icon.png`
- `shots/05-full-hotbar.png`
