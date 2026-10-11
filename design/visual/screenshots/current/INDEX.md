# Current screenshots — 2026-10-11

All files are 1680×1040 PNG. Captured from Godot Editor Play via godot-mcp. Authoring chrome (Log, Developer Test, Roster, Script, copy stamp) is visible because this was an editor run.

| File | Phase | Player is doing | Inputs | Feedback they see / hear |
|---|---|---|---|---|
| `01-title.png` | title | Picking how to start | How to Play, Quick Start, Play, Adventure Mode. Editor also: Developer Test, Roster, Script. Escape opens Settings. | Title **Swipe**, Nib tagline, faint empty wheel behind a dark overlay. Copy stamp bottom-right. |
| `02-tutorial-first.png` | ready + How to Play page 0 | Reading Nib’s first line | **Next ›**. Skip exists on later UI. Wheel/hand are visible but the script is still talking. | Nib talk box over the wheel. Goblin, Golem, Wizard seated. Hand: Sai, Knucklers, Helmet, The Boot. Spin is dim. |
| `03-tutorial-mid.png` | ready + How to Play page 2 | Listening while the wheel is highlighted | **Next ›**. Spin still dim until the script asks for it. | Gold frame around the whole wheel. HP hearts top-left. Hub shows 6 HP / 0 BLK. Nib talks about the Merry Go’ Round. |
| `04-draft-ask.png` | draft / ask | Deciding whether to take the relic | Click the relic card to take it. **Leave it** (3 passes shown as pips). Empty alcoves are not seating yet. | Cue **Take it or leave it?** Quiet Bell in the gate (Skip). Starter monsters already on the wheel. Log overlaps the gate. |
| `05-draft-reveal.png` | draft / after slam | Seeing who owned the relic | Wait; seating has not started. Buttons are gone. | Cue **A monster approaches. Select their location.** Golem in the gate with HP/ATK plate. Quiet Bell already in hand. |
| `06-draft-placement.png` | draft / seat | Choosing an empty alcove | Click a **+** empty slice. Occupied slices refuse. | Four empty slices marked +. Dire Wolf plate in the gate (Kill Shot). Wheel seats stay lit. |
| `07-wheel-ready.png` | ready | About to spin | **Spin**. Click items to inspect (Shift / hover). Escape = Settings. | Full wheel of 8 monsters, hub 6 HP / 0 BLK, hand of 8. Name chips crowd and overlap (two Lich chips). |
| `08-wheel-spinning.png` | spinning | Waiting for the wheel to land | None that count; Spin is gone. | Wheel rotating. Hub still 6/0. Combat music / whoosh. Hand stays on screen. |
| `09-fight-hit.png` | fighting → slaying | Just pressed Done with no Block | Fight is resolving; no new click. | Red full-screen flash. Hub HP 6→1. Lightning from Wizard into the hub. Log: take 5. Chop SFX. |
| `10-fight-blocked.png` | slaying | Just pressed Done with Block up | Fight is resolving; no new click. | Blue **BLOCKED** burst on the Wizard. Hub BLK 15, HP still 6. Block SFX. Hand hidden. |
| `11-fight-slain.png` | fighting (slay FX) | Monster HP hit 0 | **Take 5** is the Done stand-in for this Wizard. | Red **SLAIN** X on the Wizard. Combat portrait still up. |
| `12-victory.png` | victory | Run over, they kept the pile | **Again** | Overlay **Successfully Swiped** / “Now I just need a place to store this stuff”. Wheel dimmed underneath. |
| `13-defeat.png` | defeat | Run over, they died | **Again** | Overlay **Defeated** / “Thievery never pays…”. Same dimmed wheel underneath. |
| `14-pause.png` | ready + Settings | Changing volume or starting over | Escape / **Resume**. Quit. Start over: How to Play, Quick Start, Play, New, Adventure Mode. Editor: Developer Test, Roster, Script. Sliders. | Settings card on the left. Wheel still fully visible (dim is weak). Inspect plate can stay up on the right. |
| `15-inspect.png` | ready | Reading a hand item | Hover / click another card. Spin. Escape. | Right plate: Knucklers, ATK 0, body copy. Wheel and hand stay live. |

## Hear (typical)

- Title / overlay buttons: click, book, door.
- Gate ask: creak, question. Take: latch, slam, whoosh. Leave: scratch.
- Spin: door open, whoosh, then land / bong.
- Hit: chop + error. Blocked: block_heavy + bong + glass. Slain: bong, whoosh, scratch.
- Defeat: error_big. Victory: confirm_big.
