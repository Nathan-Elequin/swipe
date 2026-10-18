# <task-id> — <one line goal>
Checkpoint: <sha>   Branch: task/<task-id>   Chat: fresh
## Read
- design/visual/SCREEN-<id>.md, design/visual/layouts/<id>*.layout.json, design/visual/sizes/<id>.sizes.json
## Do
1. … (numbered, each step = one commit `<task-id>(n): …`)
## Files you may touch
- scripts/cabin/map_overlay.gd, scripts/cabin/rope_exit.gd, *.import under assets/ui/map/
## Acceptance (must PASS)
- Shots: 15a_map_selected, 15b…, 18_rope_exit_belly1 — text_audit 0, layout_check 0 (±2 px)
## Do not (task-specific, on top of the rule file)
- …
## Resolved decisions
- route title: 1 line, font 40→20 (JSON is authoritative) — Pixel 2026-10-17
