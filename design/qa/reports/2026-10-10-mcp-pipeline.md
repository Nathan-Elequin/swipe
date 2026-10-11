# QA report — MCP pipeline (title boot)

## Feature

- Name / id: godot-mcp install + always-on QA rule
- Spec it was built from: chat to install satelliteoflove godot-mcp for testing only, with `.cursor/rules/qa-verify.mdc` `alwaysApply: true`

## Result

PASS WITH NOTES

The editor addon and WebSocket bridge work. This Cursor chat still has no `godot_*` tools until Nathan enables **godot-mcp** in Cursor Settings → MCP. Shield / Goblin checklists were not run in this pass (setup proof only).

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Addon enabled | Godot MCP plugin on, port 6550 | `project.godot` `[editor_plugins]` + `[godot_mcp]`; TCP 127.0.0.1:6550 listening | `project.godot` editor_plugins / godot_mcp | Pass |
| Server reaches editor | `get_state` returns 4.7.2 + main.tscn | `godot_version` 4.7.2-stable, scene `res://scenes/main.tscn` | `design/qa/reports/evidence/2026-10-10-mcp-proof.json` `playing` | Pass |
| Launch game | `is_playing` true | true after `godot_editor_edit` run | same file `playing.structuredContent.is_playing` | Pass |
| Screenshot | Title screen visible | Swipe title, How to Play / Quick Start / Play / Adventure Mode / Developer Test | `design/qa/reports/evidence/2026-10-10-mcp-proof.png` | Pass |
| Key | Space injects | "Input sequence completed: 1 input(s) executed [key:Space] over 100ms" | proof.json `key` | Pass |
| Probe dump | Title phase, HP 6 | `phase: title`, `hp: 6`, empty wheel, not in tutorial | proof.json `exec` | Pass |
| Error log | No red errors | "No error messages (cursor 0)." | proof.json `log` | Pass |
| Cursor MCP in this chat | `godot_*` tools listed | none (GetDynamicTools pattern `godot` empty) | this chat | Fail (enable toggle) |
| Shield vs Goblin checklists | Full item + monster QA | not run | — | Fail (deferred) |

## Bugs

1. **Cursor has not enabled the project MCP server yet.** Repro: open Agent chat in this repo; no `godot_editor_read`. Likely: Cursor MCP approval for `.cursor/mcp.json`. Suggested fix: Nathan enables **godot-mcp**. Severity: blocks every agent from in-game QA until flipped.

## Balance notes

None. Title boot only.

## Player-facing copy issues

None in this pass. (Locked tutorial stage-direction leak is a different chat.)

## What was fixed this loop

- Loop 1: installed addon 4.1.11, enabled plugin, wrote `.cursor/mcp.json`, `qa-verify.mdc` always on, checklists, probe.
- Still left: enable Cursor MCP; run Shield + Goblin checklists through the tools in an Agent chat that can see `godot_*`.

## Next agent: start here

1. Confirm this chat has `godot_*` tools. If not, tell Nathan: Cursor Settings → MCP → enable **godot-mcp**, keep Godot Editor open on `C:\Users\Natha\Documents\boss-rush`.
2. Run `design/qa/CHECKLISTS.md` **New Item** for Shield and **New Monster** for Goblin via Developer Test; write `design/qa/reports/YYYY-MM-DD-shield-goblin.md`.
3. Do not edit scenes or scripts through godot-mcp. File edits only. Do not rewrite locked `player-copy.json`.
