---
id: REQ-20261114-real-playthrough-qa
status: open
priority: urgent
tip_sha: 0de7b223
created: 2026-11-14T09:35:00Z
created_by: pixel
viewport: 1680x1040
---

# Real player playthrough QA (no dev hooks)

Nathan's real F5 playtest at tip 0de7b223 shows that most of the recent trophy, tooltip, music and flow work is missing or broken in what the player actually sees. Earlier drains passed because they used dev hooks and forced poses. **This pass must reproduce what a player sees.**

## Hard rules for this pass
- NO dev hooks: no `_dev_*`, no `_open_dev_test`, no forced `visible`/`modulate`, no `preview_*` calls, no direct `show_def`. Drive the game ONLY with simulated real mouse moves, hovers, clicks and key presses through the Godot MCP input tools, the way a player would.
- Start from a FRESH save. Back up Nathan's `user://` save first and restore it at the end, checking that the hashes match.
- Before anything else, record in RESULT.md: `git rev-parse HEAD`; the project path Godot actually has open; any build SHA label shown on screen; and whether the editor reported import errors (Output panel). Make sure the editor has finished reimporting first.
- At every step, save a full 1680x1040 frame. Also dump a short `state/<step>.txt` with: the current scene/room; visible top-level UI node paths with z and modulate; the active music stream path + volume_db + playing for every AudioStreamPlayer; and, on trophy steps, the texture resource path of each plinth/slab, backdrop, dais, placard and parchment tag actually drawn (`texture.resource_path`, or "none / StyleBoxFlat").
- Never fake a pass. If something doesn't happen for real input, mark it FAIL and describe what happened instead.
- For any animation, grab 3–5 real-time frames (no time freezing).

## Steps
| id | step | capture |
|----|------|---------|
| P01 | Launch, title screen → start new game | title frame; first frame in the cabin |
| P02 | First cabin arrival | entryway: is Nib physically there? Is there any prompt toward the map? Any dummy/debug text on screen? |
| P03 | Click the map, start the first run | map frame; music state on entering Verdant Hollow |
| P04 | First fight: hover keywords in an item card, a monster plate, any speech bubble | for each: frame before hover, cursor on the keyword word, card shown (or not). Note how a player could tell the word is hoverable. Note any cut-off or overflowing text and the card rect |
| P05 | First-sighting teach in the first fight | 3–5 real-time frames |
| P06 | Play/finish the first run (win or die by real play; use real input to speed up if you can) | key frames: end-of-run, return transition |
| P07 | Return to the cabin after run 1 | every frame of the return sequence in order: does an invisible Nib run the keys/door unlock? Which room do we land in? |
| P08 | Satchel unpack / item placement | 5+ real-time frames per item: is the slot lit BEFORE the item lands? Float, drift, land, poof, light order; which SFX play (log stream paths) |
| P09 | Trophy room as the player sees it | full frame + texture-path dump: are stone slabs/plinths, backdrop, dais, wooden signs, silhouettes the new art or the old? |
| P10 | Hover then click a claimed item and an unclaimed silhouette on the board | the parchment tag at the click? Does it hide on mouse-leave? |
| P11 | Switch boards (all 5) | 3–5 real-time frames per switch: does the board slide inside its own frame, or does the whole room/wall shift sideways? |
| P12 | Pull the lever → new biome splash (Crystal Cavern) | frames through and 5 seconds AFTER the splash: does the screen go fully black? Log every ColorRect/CanvasLayer with alpha>0.9 covering the screen, plus music state at each frame |
| P13 | From the cabin, click the map → enter Verdant Hollow (2nd run) | music state 0s, 1s, 3s, 6s after entering: does it cut back to cabin music? |
| P14 | All on-screen dummy/debug text seen anywhere (e.g. "B2 is now open") | a frame of each + the node path + script that set the text |
| P15 | Hotbar new-item star after run 1 | frame before and after first use |

## Outbox
`playtest/repot/outbox/REQ-20261114-real-playthrough-qa/` with `shots/`, `state/` and RESULT.md (one line per row: PASS/FAIL plus what really happened, in plain words). Restore the save. Commit only the outbox and push to playtest/latest. Never stash local edits; if any exist, commit them first as a WIP checkpoint.
