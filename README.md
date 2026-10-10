# Swipe

Steal the shiny. Fight who owned it.

A shrinking-wheel dungeon. Friends play the itch.io page. This repo is the source.

## Play

**Play:** https://nathan-elequin.itch.io/swipe

Source: https://github.com/Nathan-Elequin/swipe

## Open in Godot (editing)

1. Godot **4.7.2**
2. Import this folder
3. F5

Roster, Script, and Developer Test only show in the editor. They are hidden in the web build friends play.

## Export a web build

In Godot: **Project → Export → Web → Export Project** to `build/web/index.html`.

Or from a terminal (Godot 4.7.2 on PATH, export templates installed):

```
Godot_v4.7.2-stable_win64.exe --headless --path . --export-release Web build/web/index.html
```

Zip the `build/web` folder and replace the HTML file on the itch project.
