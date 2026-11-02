---
id: REQ-20261102-splash-narration-fit
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-02T11:20:00-06:00
machine: Cherry
tip_sha: 60c5afe8
godot: F5 playtest (godot-mcp) — Stop Play, F5, skip intro, Middle Progress, cheat-unlock tips, biome-enter splash mid-hold
viewport: 1680x1040
---

# Result

Live path: F5 playtest hub → skip intro → Middle Progress → campaign map (all five tips unlocked) → biome-enter splash at full hold (alpha 1) per b1–b5. Viewport 1680×1040. Cinder wraps to **2 lines** after the wider label (request allowed 3 or fewer). Final “listening.” sits inside the bar. Cue is `click anytime` bottom-right. No word “Tier”.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant Hollow / Dungeon 1 / Delves: 3. 2-line narration inside bar (pad 64/48/64/82). Cue visible, no overlap. No Tier. `01-verdant.png` 1680×1040. |
| 02 | pass | Crystal Cavern / Dungeon 2. 2-line narration inside bar, same padding. Cue `click anytime` clear of text. No Tier. |
| 03 | pass | Ashen Crypt / Dungeon 3. 2-line narration inside bar. Cue visible bottom-right. No Tier. |
| 04 | pass | Cinder Forge / Dungeon 4 (overflow case). Wider wrap is 2 lines; “…already listening.” fully inside the bar with padding. Cue not overlapped. No Tier. |
| 05 | pass | Shadow Abyss / Dungeon 5. 2-line narration inside bar. Cue visible bottom-right. No Tier. |

## Blockers

None.

## Shots

- `shots/01-verdant.png`
- `shots/02-crystal.png`
- `shots/03-ashen.png`
- `shots/04-cinder.png`
- `shots/05-shadow.png`
