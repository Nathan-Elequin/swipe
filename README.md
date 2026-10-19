# Swipe

Steal the shiny. Fight who owned it.

A shrinking-wheel dungeon. Friends play the itch.io page. This repo is the source.

## Play

**Play (playtest):** https://nathan-elequin.itch.io/swipe-playtest

The public page https://nathan-elequin.itch.io/swipe is frozen. Do not push builds there.

Source: https://github.com/Nathan-Elequin/swipe

## Open in Godot (editing)

1. Godot **4.7.2**
2. Import this folder
3. F5

Roster, Script, and Developer Test only show in the editor. They are hidden in the web build friends play.

## Export the playtest web build

F5 in the editor is the playtest game. Friends play the playtest itch page.

Godot: **Project → Export → Web Playtest → Export Project** to `build/web-playtest/index.html`.

```
Godot_v4.7.2-stable_win64.exe --headless --path . --export-release "Web Playtest" build/web-playtest/index.html
```

After a playable fix, export and `butler push` in that same turn to `nathan-elequin/swipe-playtest` (channel `html5`). Do not wait. Do not push `nathan-elequin/swipe`. Worker setup: `tools/playtest-inbox/README.md`.
