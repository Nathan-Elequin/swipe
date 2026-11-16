---
id: REQ-20261116-commitment-tiers-slice2
status: open
priority: high
branch: cursor/playtest-commitment-tiers-slice2-f23f
created: 2026-11-16T23:45:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub boot (editor). DevChrome on → Ctrl+Shift+4 to reset tier if needed, then restart / re-open hub path after intro.
---

# Commitment tiers slice 2 — picker + goal icon

UI slice after slice 1 logic. Cloud agent left Xvfb `get_image` plates under outbox; local Cherry should re-shoot on the real F5 path.

## What to verify

- After Nathan's intro (tier == 0), commitment picker appears before hub/teaser.
- Three equal cards (Quick / Deeper / Big), carrot + telemetry/save footers; no Recommended badge.
- Pick → card blip → gold flyer to top-left goal icon → hub continues.
- Goal icon stays top-left in cabin/runs (near play chip); hover shows goal / done tip.
- Pause → **Go deeper** when tier < BIG → upgrade picker dims lower tiers with ✓ Done.
- Editor DevChrome: Ctrl+Shift+4 resets tier so picker can be re-seen.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | boot | intro finished, tier 0 | three equal cards + carrot + notices | 01-picker-choose.png |
| 02 | cabin/run | tier deeper chosen | top-left goal chip + tooltip | 02-goal-icon-tooltip.png |
| 03 | pause | tier quick, open Go deeper | lower card dimmed/done; higher enabled | 03-picker-upgrade-go-deeper.png |
| 04 | pause | tier < BIG | Settings shows Go deeper entry | 04-pause-go-deeper.png |

## Pass criteria

- All rows at 1680×1040 (or note viewport).
- Cloud outbox already has Xvfb plates; replace with headed F5 shots if they differ.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261116-commitment-tiers-slice2/`
