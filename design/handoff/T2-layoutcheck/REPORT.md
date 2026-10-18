# T2-layoutcheck

## Status
PASS (code) / shots pending

## Checkpoint
`aa2bfd6` (branch base; this task had no spec checkpoint commit)

## Commits
- `0f35c04` T2-layoutcheck(1): compare scene nodes to layout JSON after a capture
- T2-layoutcheck(2): this report

## Files changed
- `scripts/dev/layout_check.gd`
- `scripts/dev/layout_check_selftest.gd`
- `scripts/dev/shot_harness.gd`
- `design/handoff/T2-layoutcheck/REPORT.md`

## Checks run + results
Headless self-test (no main scene, no `user://`):

```
Godot Engine v4.7.2.stable.official.ed1daf0bf
PASS pass checked=2 failures=[]
PASS rect_off checked=1 failures=["MapPanel:rect_off"]
PASS missing_node checked=1 failures=["RouteTitle0:missing_node"]
PASS z_off checked=1 failures=["MapPanel:z_off"]
PASS draw_rect_skip checked=1 failures=[]
PASS draw_rect_required checked=0 failures=["PortraitDbg:missing_node"]
PASS file_roundtrip checked=1 failures=0
DOT_NAME=Route_Classic
LAYOUT_CHECK_SELFTEST ok
EXIT=0
```

Command:

```
& "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --script res://scripts/dev/layout_check_selftest.gd
```

The autoload `mcp_game_bridge.gd` printed parse errors before the test lines. The script still finished and did not boot `main.gd`.

## Shots
None. No capture passes a layout id yet, so a shot run would not write `layout_check.json`.

## Audit
Not run. Output shape when a capture does pass an id: `design/audit-shots/cursor/layout_check.json` with `updated`, `layout`, `checked`, `failures[{id, reason, expected, actual}]`. Reasons: `missing_node`, `rect_off`, `z_off`.

## Verify (pending, windowed)
Do this only when Nathan is not in the Godot editor. It boots the game and uses `user://`.

```
& "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\Users\Natha\Documents\boss-rush-wt\T2-layoutcheck" -- --shots=15a_map_classic_selected
```

That command still will not fill `layout_check.json` until some `_capture` call passes a layout id, for example `"map-routes-classic-selected"`.

## Deviations
- Section 3.2 stores rects on `nodes`. The four files in `design/visual/layouts/` use `elements` and nested `children`. If `nodes` is absent, the checker walks `elements` so the file is not an empty pass.
- A missing layout file is reported as `missing_node` with `expected` set to the path.
- If two nodes share a name, the first one in tree order is the one compared.
- `z` is compared to `CanvasItem.z_index` exactly. Rects use `+/- 2` px.

## Layout ids that need node renames
Read-only. No scripts were renamed. A node counts as matching only when some script sets `name` to that exact id. Godot 4.7 stores a dot as an underscore (`Route.Classic` becomes `Route_Classic`), so a dotted id cannot match `node.name`.

**map-routes.layout.json** — `Scrim` already matches (`cabin_kit.gd`). These do not: `Sheet`, `HeroMarker`, `Route.Classic`, `Route.Classic.Name`, `Route.Classic.Mode`, `Route.Challenge`, `Route.Challenge.Name`, `Route.Challenge.Mode`, `Panel`, `Panel.Name`, `Panel.Mode`, `Panel.Rule`, `Panel.Body`, `Panel.Footer`, `Title`, `Legend`, `CloseX`, `Confirm`, `Confirm.Label`, `DevTag.QuickStart`, `DevTag.QuickStart.Label`. `map_overlay.gd` does `host.name = el_id` for `Route.Classic` and `Route.Challenge`; the live name is `Route_Classic` / `Route_Challenge`.

**map-routes-classic-selected.layout.json** — same list, without `Panel.Footer`.

**rope-exit.layout.json** — none match the rope screen. `Hero` is the cabin hero (`home_cabin.gd`), not the rope sprite. The rest have no name: `Background`, `Ladder.Hit`, `Hole.Hit`, `TitleBand`, `Sign`, `Sign.Title`, `Headline`, `Sub`, `Climb`, `Climb.Label`, `Climb.Consequence`, `Delve`, `Delve.Label`, `Delve.Consequence`, `Peek`, `Peek.Label`.

**rope-exit-sack-peek.layout.json** — `Scrim` matches. These do not: `SackPanel`, `Sack.Title`, `Sack.Count`, `Sack.Grid`, `Sack.Hint`, `Sack.Close`, `Sack.Close.Label`.

## Questions
- [Pixel] Dotted ids cannot be Godot node names (`.` becomes `_`). Should the layout ids drop the dots, or should a later wiring task set names with underscores and change the JSON ids to match?
- [Pixel] `rope-exit` id `Hero` collides with the cabin node named `Hero`. The rope sprite needs its own name.

## What Nathan should look at
Nothing in game. No acceptance PNGs.
