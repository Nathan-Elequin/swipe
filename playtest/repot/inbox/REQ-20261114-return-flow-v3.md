---
id: REQ-20261114-return-flow-v3
status: open
priority: high
branch: cursor/return-flow-v3-fixes-8775
tip_sha: c738ff6b
created: 2026-11-14T10:45:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New (fresh save). Play a real Verdant Hollow run and EXTRACT with loot (rope Leave / win with items in hand). Do NOT die empty-handed as the only return — that path skips unpack and cannot reach claim / lever / Crystal Cavern splash rows. No Grant / Fill / Fresh / DevChrome cheats unless a row explicitly asks for Ctrl+Shift+D.
---

# Return flow v3 — pause, parchment, plinths, keys-beat Nib, unpack, DevChrome

Fixes from real-input QA of REQ-20261114-return-flow-v2 + music-devchrome (PR #519 / #518). Cloud cannot F5 — local Cherry shots required. Headless: `godot --headless --path . --script res://scripts/dev/return_flow_v2_selftest.gd` plus tip smoke.

## What to verify

- **SceneTree.paused:** After limp-home or extract return + Nib dialogs finish and the player can walk the cabin, `get_tree().paused == false`. Doors / map / board work without relying on PROCESS_ALWAYS alone.
- **Parchment tag:** Click an unclaimed board item (e.g. Fangs). Tag is ~280–340px wide, height fits the text (not a tall narrow strip). Text readable, dark brown, autowrap, beside the item, clamped on screen. Mouse-off the tag/slot **or** click the rug / elsewhere hides it (`vis` false), including while a dialog had left the tree paused.
- **Empty plinth slabs:** On the Verdant board, every silhouette sits on a visible dusty `plinth_empty` slab (WIRING Rect2(0,116,128,32)). Slabs read clearly vs the oak face (not hidden behind the face bg / not silhouette-tinted). Compare to `design/audit-shots/cursor/return-flow-v2/board-before-mock-vs-game.png` left/mock side.
- **Keys beat → entryway:** After first return trophy beat, visible Nib in **main** unlocks study→workshop→loft, says `nib.return.continue_mission`, then map pointer + pulse ring stay up. No leftover hall parchment on the entryway. Nib must not be `visible=false` in main after this beat.
- **Empty-handed vs with-loot:** Empty limp still skips satchel unpack (no fake haul) but trophy Nib lines still play. **With-loot extract** runs float → drift+SFX → land → poof+SFX → then slot lit (+ biome light). This REQ requires the with-loot path.
- **DevChrome:** Default hidden. **Ctrl+Shift+D** toggles branch tag / copy stamp / map cheats in playtest F5 (F11 is an alias; Windows editor may eat F11). BuildStamp SHA + Feedback stay. Leave the bottom-left playtest hint alone.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | Brand New → first cabin after welcome | Nib visible; map pointer/pulse; hall open; study locked; tree unpaused after dialog | 01-first-cabin-entryway.png |
| 02 | hall | **EXTRACT with loot** first return, mid unpack | satchel up; item in air or just landed; plinth still empty until after poof | 02-satchel-before-claim.png |
| 03 | hall | same return, after first item poof | claimed on `plinth_claimed` + gold ring; dusty slabs visible under remaining silhouettes | 03-claimed-on-plinth.png |
| 04 | hall | click unclaimed item (Fangs) | parchment ~300px wide, text fits, beside item; then mouse-off or rug click hides it | 04-parchment-tag.png |
| 05 | hall | board still after claim | empty plinth slabs clearly visible under silhouettes (not face-only dark) | 05-plinth-slabs-visible.png |
| 06 | main | after trophy + key unlock | Nib visible in entryway; continue_mission done; map pointer + pulse; no leftover parchment; `paused=false` | 06-post-unlock-map-pointer.png |
| 07 | combat or map | Ctrl+Shift+D once | DevChrome on (branch/copy or map cheats); default was off | 07-ctrl-shift-d-chrome.png |
| 08 | workshop/map | after unlock, optional | lever / Crystal Cavern path reachable without cheats (note if still locked by progress) | 08-post-unlock-progress.png |

## Pass criteria

- All rows at 1680×1040 in-game (godot-mcp or Game viewport grab). Note window chrome if different.
- Real mouse/keys only. **Must EXTRACT with loot** for 02–03 and to reach later progress rows.
- Tree unpaused once the player has cabin control after return dialogs.
- Parchment hides on mouse-off / click-away; never a full-height strip.
- Plinth slabs visible under every empty silhouette.
- No Tier/ATK in parchment. Playtest hint text unchanged.

## Outbox path

`playtest/repot/outbox/REQ-20261114-return-flow-v3/`
