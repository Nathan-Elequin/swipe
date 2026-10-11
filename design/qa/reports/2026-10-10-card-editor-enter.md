# QA report — card editor Enter / Esc

## Feature

- Name / id: card editor Enter saves and closes; Esc closes without saving
- Spec it was built from: chat — right-click item/monster sheet shortcuts

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Edit card sheet opens from authoring | Opened `item:da_boot` | godot_exec `visible: true` | Pass |
| Esc | Closes without requiring Save | Esc → `content_ed.visible` false | `godot_game_time` report after Escape | Pass |
| Enter | Same as Save: write + close | Enter → editor closed | `godot_game_time` report after Enter | Pass |
| Locked text unchanged | No prose rewrite | Enter on an unchanged Boot sheet | No player-copy edits this change | Pass |
| No "Tier" | n/a editor | n/a | | Pass |
| Errors | None from this change | DAP debugger noise only | editor log | Pass |

## Bugs

None.

## Balance notes

n/a — editor chrome.

## Player-facing copy issues

None.

## What was fixed this loop

- Loop 1/3: `_input` on `content_editor.gd` so Enter/Esc work while a field is focused. Shift+Enter still makes a new line.

## Next agent: start here

1. Roster and Script editors still use Ctrl+S / Esc only — Nathan asked for the card sheet.
