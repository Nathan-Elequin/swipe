# QA — How to Play + wheel capsules + alcove colors

- Date: 2026-10-12
- Feature: Tutorial script parse, name capsules, Weak/Tough/Deadly alcoves
- Checklist: Tutorial Step + Copy/UI
- Godot MCP: down this turn (duplicate client, then reconnect failed). Evidence is a Godot `--script` parse plus a headless project boot.

## Setup

- `Godot_v4.7.2-stable_win64.exe --headless --path boss-rush --script res://tools/qa/check_tutorial_beats.gd`
- `Godot_v4.7.2-stable_win64.exe --headless --path boss-rush --quit-after 2`

## Results

| Check | Result | Evidence |
|---|---|---|
| Saturday script splits into playable beats | Pass | `TUT_BEATS 57` `TUT_OK` from check_tutorial_beats.gd |
| Required clicks exist (Spin, Sai, Helmet, Safe, Boot/Take 3, Shift-hover) | Pass | `TUT_WAITS` includes spin×2, item:sai, auto_spin, item:helmet, done, hover_shift, choice |
| Boot / Take 3 branches exist | Pass | `TUT_BOOT true` `TUT_TAKE true` |
| Helmet highlight stays on the Helmet card | Pass | `TUT_HELMET_FOCUS true` |
| Headless boot, no script parse errors | Pass | quit-after 2, no GDScript errors |
| Player screens never say Tier | Pass | fills use Weak/Tough/Deadly colors only; no new copy |
| Live How to Play click-through | Not run | Godot MCP not connected |
| Capsule alignment in a running fight | Not run | Godot MCP not connected |
| Alcove colors in a running fight | Not run | Godot MCP not connected |

## Notes

- Locked `tutorial.beat.01.body` was not rewritten. The engine now walks that script.
- Stage directions stay off the talk box.
- Locked beats 02–18 are unused while the Saturday script is present.

## Follow-up

Click How to Play after a script reload (stop Play, F5). Confirm Nib speaks one line at a time, Sai/Helmet/Boot land, and alcoves read copper / steel / ember.
