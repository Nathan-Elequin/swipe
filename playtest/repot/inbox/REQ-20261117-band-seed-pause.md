---
id: REQ-20261117-band-seed-pause
status: open
priority: high
tip_sha: 5c4fd32e899c7de7690c584120c08f1237619df8
branch: cursor/band-seed-pause-c389
created: 2026-11-17T18:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress; Escape Give up; die → Limp home
---

# Title floor band + fresh-run seed + stuck pause

Cloud PR fixes three QA findings: solid black `BackdropFloor` band under the title/picker, reused `next_run` seed after a fresh save, and `SceneTree.paused` stuck true after Give up / Limp home.

## What to verify

- Title and commitment picker fill floor art to the bottom at 1680×1040 (no solid black strip y=832–1040).
- Two independent fresh saves (wipe `user://` or Start over → New Game) write different `campaign_save.json` `next_run.seed` values unless an explicit test seed is set.
- After Give up from the pause menu, cabin/map input works and `SceneTree.paused == false`.
- After defeat → Limp home settles, `SceneTree.paused == false`.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | title | living trophy title after a save exists (or no-save title if that path is live) | bottom edge shows verdant floor art to y=1040; no solid black band; log tip SHA | 01-title-bottom.png |
| 02 | picker | New Game → commitment picker | bottom edge filled like title; log tip SHA | 02-picker-bottom.png |
| 03 | map | wipe `user://`, Brand New / Middle Progress → map; note `next_run.seed`; wipe again; second fresh save → map | two different seeds logged; both shots optional, seed lines required in RESULT | 03-seed-a.png |
| 04 | map | second fresh save seed (pair with 03) | seed ≠ first; log both seeds | 04-seed-b.png |
| 05 | cabin | in-run Escape → Give up → confirm → cabin settle | `SceneTree.paused=false`; doors/map clickable | 05-give-up-unpaused.png |
| 06 | cabin | die in Verdant → Limp home → idle | `SceneTree.paused=false` after settle | 06-limp-home-unpaused.png |

## Pass criteria

- All shots at 1680×1040 via godot-mcp injected input only (never OS mouse/keyboard).
- RESULT.md logs tip SHA, `next_run.seed`, and `SceneTree.paused` per row.
- Rows 01–02 show no solid black band; 03–04 different seeds; 05–06 paused=false.

## Outbox path

`playtest/repot/outbox/REQ-20261117-band-seed-pause/`
