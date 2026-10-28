# Playtest repot

Bridge between **cloud agents** (write code, cannot F5 / godot-mcp) and **local Cursor on Cherry** (has Godot + godot-mcp).

Nathan’s only manual step: send any message in local Cursor while this workspace is open. The always-on rule `.cursor/rules/playtest-repot.mdc` drains open requests.

## Flow

1. Cloud agent (or Pixel) ships a change → writes one request under `playtest/repot/inbox/`.
2. Local Cursor (any chat, any ask) sees open inbox items → claims → runs Godot shots → writes `playtest/repot/outbox/<id>/` → marks inbox `done`.
3. Pixel reviews outbox PNGs + `RESULT.md` → archives or opens a fix loop (new inbox request).

## Layout

```
playtest/repot/
  README.md                 # this file
  SCHEMA.md                 # request + result format
  inbox/                    # open / claimed / done (YAML frontmatter)
    REQ-<slug>.md
  outbox/
    REQ-<slug>/
      RESULT.md
      shots/*.png
  archive/                  # Pixel moves fulfilled requests here after review
```

## Status values (inbox frontmatter)

| status   | who sets it | meaning |
|----------|-------------|---------|
| `open`   | cloud / Pixel | waiting for local Godot shots |
| `claimed`| local Cursor | in progress on Cherry |
| `done`   | local Cursor | outbox filled; waiting for Pixel review |
| `needs_fix` | Pixel     | review failed; local should re-shoot (see notes) |

## Hard rules

- One request file = one verifiable ship (usually one PR).
- Screenshots are **in-game Godot MCP** of the running playtest surface — not the editor filesystem, not a mock. Prefer godot-mcp; `scripts/dev/shot_harness.gd` / `scripts/shot_cli.gd` is an OK fallback for scripted 1680×1040 captures. Never write repot shots into `design/audit-shots/cursor/` (harness overwrite zone) — outbox only under `playtest/repot/outbox/<id>/shots/`.
- **Local agents MUST commit + push** outbox `RESULT.md` + shots before leaving them untracked. `tools/playtest-sync.sh` uses `git stash push -u`, so untracked result PNGs get stashed away on the next sync.
- Commit + push fulfillment to `playtest/latest` (or the PR branch if the request says so) so Pixel can pull without asking Nathan to paste images.
- Do not invent player-facing copy. Do not change art bytes unless the request says so.
- Prefer the Godot already open; do not kill processes you did not start (`agent-runtime.mdc`).

See `SCHEMA.md` and `.cursor/rules/playtest-repot.mdc`.
