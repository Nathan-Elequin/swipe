---
id: REQ-20261117-callout-matches-wheel
status: open
priority: high
branch: cursor/callout-matches-wheel-ef97
tip_sha: f75505f6
created: 2026-11-17T05:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → fight with Juggernaut (then Ogre, Golem) on the wheel
---

# Callout idle matches wheel seat

Fight callout (`combat_stage` over the hover_panel stage card) now uses the same seat idle strip, strip-level framing, and 200ms timing as the wheel seat. No PNG art changes.

## What to verify

- With Juggernaut faced, the right-side callout idle matches the wheel seat: same frames, no size pump between frames, same foot line feel.
- Repeat for Ogre and Golem (and optionally Goblin).
- Callout does not bob on short strips; phase tracks the facing seat while that card is shown.
- Input must be godot-mcp injection only (`Viewport.push_input` / injected mouse and key events). No OS/computer-use control of Nathan's screen. No `_dev_*`, `preview_*`, Grant, DevChrome shortcuts, or forced poses.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | seat Juggernaut; spin to face it | wheel seat + callout same idle pose/framing at 1680×1040 | 01-juggernaut-wheel-and-callout.png |
| 02 | fight | seat Ogre; spin to face it | wheel seat + callout match | 02-ogre-wheel-and-callout.png |
| 03 | fight | seat Golem; spin to face it | wheel seat + callout match | 03-golem-wheel-and-callout.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Callout does not pump size frame-to-frame; framing aligns with the wheel seat.
- Log tip SHA, active textures (seat + callout), and `SceneTree.paused` in RESULT.md.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Input path was godot-mcp injection only.

## Outbox path

`playtest/repot/outbox/REQ-20261117-callout-matches-wheel/`
