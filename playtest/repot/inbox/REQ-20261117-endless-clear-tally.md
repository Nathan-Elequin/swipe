---
id: REQ-20261117-endless-clear-tally
status: open
priority: high
pr: 556
tip_sha: c7284c38
branch: cursor/endless-clear-tally-fly-5de5
base: playtest/latest
created: 2026-11-17T20:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress (or fresh save) → Endless → clear a dungeon (wheel empty) so the Endless clear tally plays
---

# Endless clear tally-and-fly

After the clear parade, Endless shows a ~2s tally: gold hub ring + heart pop → center `+1` stamp → curved fly into the top-right counter → title + centered Continue. Any click/key skips to the settled end state. Tweens run while paused.

## What to verify

- Fresh save (or Middle Progress) → real Endless clear path (not a mocked overlay alone).
- Counter still shows the **old** floor until `+1` lands, then ticks **once** to the new value (scale bump + gold flash).
- New best: best line glints; `endless.new_best` heard once.
- Title uses existing `endless.clear.title` copy; Continue is horizontally centered; title centered too.
- Skip-click mid-sequence jumps to end (title + Continue up, counter already new).
- Log tip SHA, counter before/after, sounds heard, and `SceneTree.paused` during the sequence.
- godot-mcp injected input only for the skip case and Continue; shots at 1680×1040.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | endless clear | ~t=0.3 after clear (ring/hearts + stamp window) | gold ring/heart pop and/or big gold `+1` near center; HUD still on old N | 01-t03-stamp.png |
| 02 | endless clear | ~t=0.9 mid-fly | `+1` on curved path toward top-right counter | 02-t09-fly.png |
| 03 | endless clear | ~t=1.3 just after land | counter shows new N; title starting or about to appear | 03-t13-land.png |
| 04 | endless clear | ~t=2.0 settled | title + Continue visible and centered; counter at new N | 04-t20-settled.png |
| 05 | endless clear | skip-click during stamp/fly | same settled end as 04 without waiting full 2s | 05-skip-settled.png |

## Pass criteria

- All five PNGs under `playtest/repot/outbox/REQ-20261117-endless-clear-tally/shots/` at 1680×1040.
- 01 shows old counter value; 03/04/05 show new value (exactly +1).
- Continue and title look centered (within a couple px of viewport mid).
- RESULT.md notes tip SHA, counter before/after, SFX heard (`endless.clear_ring`, `endless.plus_stamp`, `endless.plus_fly`, `endless.counter_tick`, optional `endless.new_best`, `ui.continue_appear`), and whether `SceneTree.paused` was true.

## Outbox path

`playtest/repot/outbox/REQ-20261117-endless-clear-tally/`
