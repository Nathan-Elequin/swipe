# T6-tokens

## Status

PASS (code) / shots pending

## Checkpoint

`aa2bfd6db82a4c95faff550bd4bab3b88ccd1b48` on `task/T6-tokens` (branch start; no spec commit).

## Commits

- `f3c85414dbf3f113954e8190d83cb3e2cedb3fca` T6-tokens(1): snapshot the UI palette and type roles as they are
- `370a77bb201f6e8e618ef3b936ffda122cfac90b` T6-tokens(2): add the headless tokens generator
- `3ad97d7c9de71a7cef38f98e85ef14951e8bdd5a` T6-tokens(3): generate Tokens and the unused swipe theme
- T6-tokens(4): this report

## Files changed

- `design/visual/tokens.json`
- `tools/qa/gen_tokens.gd`
- `scripts/ui/tokens.gd`
- `themes/swipe_theme.tres`
- `design/handoff/T6-tokens/REPORT.md`

## Shots

None. No windowed Godot. Nathan is in the editor, and `user://` is shared.

## Audit

Not run. This branch does not change a screen.

## Checks run + results

- `godot --headless --path . --script res://tools/qa/gen_tokens.gd` twice. Exit 0 both times. Second run did not change the generated files.
- Printed `gen_tokens PASS colors=34 sizes=16` with `default_font` empty.
- Saved theme: `default_font_size` 16, Label/RichTextLabel ink `#f0e6d8`, Button outline 4, no font resource.
- `--script` also printed existing autoload parse errors for `mcp_game_bridge.gd` (editor class cache). The generator still finished and did not boot `main.gd`.

## Verify (pending, windowed)

Run only when Nathan is not in the Godot editor:

```
& "C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\Users\Natha\Documents\boss-rush-wt\T6-tokens"
```

There is no `--shots` list on this task. A boot only checks that the project still opens. `themes/swipe_theme.tres` is not the project theme, so the game should look the same as before this branch.

## Deviations

- Role names in `tokens.json` are labels on hexes already used in theme overrides. They are not a restyle. `_meta.status` is `as-is snapshot, pending Pixel G1`.
- `scenes/**` had no theme overrides. Paper fills on StyleBox backgrounds were left out.
- Outline width 1 is the unused default of `UxStyle.ink_on_paper`. Live widths are 2, 3, 4, and 6.
- `font` is `fallback` (D1). The theme leaves `default_font` unset so controls use `ThemeDB.fallback_font`.

## Follow-ups

Do not apply these in this branch. They would change what the player sees and need Nathan's G1 plus a shot run.

One line to add to `project.godot` under a new `[gui]` section:

```
theme/custom="res://themes/swipe_theme.tres"
```

Top 10 literal call sites to migrate (count of `add_theme_color_override` and `add_theme_font_size_override`):

1. `scripts/roster_editor.gd` — 52
2. `scripts/content_editor.gd` — 32
3. `scripts/script_editor.gd` — 31
4. `scripts/item_card.gd` — 27
5. `scripts/hover_panel.gd` — 22
6. `scripts/main.gd` — 21
7. `scripts/combat_log.gd` — 17
8. `scripts/dev_bucket_overlay.gd` — 16
9. `scripts/cabin/cabin_kit.gd` — 15
10. `scripts/bucket_reveal.gd` — 14

## Questions

None.

## Nathan should look at

No acceptance PNGs. Nothing on screen changed. G1 is when Pixel wants to change these tokens.
