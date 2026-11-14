---
id: REQ-20261104-multi-hit-slash-once
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T20:00:00-06:00
machine: Cherry
tip_sha: pending
godot: n/a — request superseded
---

# Result

Nathan reversed #357 on 2026-11-13: multi-hit bursts (Hornet, Hydra heads, Shambling Mound, Threshing Shark retries) slash and play the ability oneshot on **every** swing again, including after Pacemaker / nested heals.

The original pass criteria (slash portrait on the first swing only) are no longer the intended look. No shots.

| id | verdict | note |
|----|---------|------|
| 01 | n/a | superseded |
| 02 | n/a | superseded |
| 03 | n/a | superseded |

## Blockers

None. Behavior restored in `scripts/main.gd` (`_announce_multi_swing`).
