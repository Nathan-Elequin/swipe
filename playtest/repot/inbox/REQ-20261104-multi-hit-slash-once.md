---
id: REQ-20261104-multi-hit-slash-once
status: open
priority: high
pr: 0
tip_sha: aa2376b6
branch: cursor/multi-hit-slash-once-d872
created: 2026-11-04T19:20:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → fight Shambling Mound (or Hornet Swarm / Hydra with extra heads / Threshing Shark)
---

# Multi-hit ability slash once (#357)

Looping multi-hit ability bursts (Shambling Mound Self Deconstruct, Hornet ×2, Hydra heads, Threshing Shark Blood Thresh retries) should show the slash portrait on the **first** swing only. Later swings in that same burst still lunge / deal damage without replaying the cut-in.

## What to verify

- First hit of a multi-hit ability burst: slash portrait + call name once.
- Hits 2+ in that same burst: no second slash portrait overlay.
- Damsel / Commander-driven neighbor multi-hits that already announce once before the loop still do not re-slash per swing.
- Single-hit attacks are unchanged (no new slash invented for plain one-swing fights).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Middle Progress, face Shambling Mound with Block covering its ATK, press Done | First Self Deconstruct swing shows slash portrait; later swings continue without a new full slash cut-in | 01-mound-first-slash.png |
| 02 | combat | Same fight mid-burst (hit 3+) | No slash portrait covering the stage; lunges / HP chip still resolve | 02-mound-later-swings.png |
| 03 | combat | Face Threshing Shark with enough Block that first swings miss, Done | One Blood Thresh slash at the start of the retry burst; retries after that have no new slash | 03-shark-thresh-once.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261104-multi-hit-slash-once/`
