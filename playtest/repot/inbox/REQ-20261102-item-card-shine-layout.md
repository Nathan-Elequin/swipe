---
id: REQ-20261102-item-card-shine-layout
status: open
priority: high
branch: cursor/item-card-shine-layout-3f02
base: playtest/latest
tip_sha: TIP_SHA
created: 2026-11-02T17:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: Stop Play → open Documents/boss-rush in Godot → F5 → reach hub with several Brand New / freshly acquired items if possible + at least one idle card with effect icons (Counting Beads-like)
---

# Item card shine kill + idle layout retune

Cloud ship after Nathan rejected the hot Brand New / shiny glow on F5 (post-#297). Matte Brand New plates; idle title ~+50%; sprite nudged lower (size kept); effect icons ~+20% and vertically centered under the sprite. Aura kit and door-gate THE SHINY stay. No Take-arc / Spin changes. No player-facing copy.

## What to verify

- Brand New / freshly acquired hotbar cards (Sai / Knucklers / Scythe / Victory Flask style) have **no** pulsing amber/gold border, white/cyan haze, or outer shine ring. `New!` badge text may still show.
- Idle title (e.g. Counting Beads) reads ~50% larger than the post-#297 idle title.
- Item sprite size matches post-#297 (~58), but sits slightly lower — less empty gap above the effect icons.
- Idle effect icons are ~20% larger than post-#297 (~43px) and vertically centered between sprite bottom and card bottom (not stuck under the sprite).
- Decay LINK / READY / WARN / CHOICE auras still work when those states are active (not confused with Brand New shine).
- Nearest filter; no soft blur. No “Tier” / “ATK” / “atk” on the card face.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hub hotbar | Spin/ready hub with several Brand New / New! items if possible + idle cards | full hotbar 1680×1040; Brand New cards matte (no shine aura); layout readable | 01-hub-hotbar-full.png |
| 02 | hub hotbar | zoom / crop one idle card with effect icons (Counting Beads or similar) | title larger; sprite slightly lower; icons ~20% bigger and vertically centered under sprite | 02-idle-card-zoom.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Outbox written under `playtest/repot/outbox/REQ-20261102-item-card-shine-layout/`.

## Outbox path

`playtest/repot/outbox/REQ-20261102-item-card-shine-layout/`
