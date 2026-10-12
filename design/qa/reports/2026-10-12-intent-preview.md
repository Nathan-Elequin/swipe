# QA report — intent preview + loud value updates

## Feature

- Name / id: Intent preview and loud value updates
- Spec it was built from: Nathan chat 2026-10-12 (restore pre-Direction-A hover preview + punch on change). Paper Fight skipped — feel/animation restore, no new combat rule. Must-keep fight UX §10.

## Result

PASS WITH NOTES

Godot 4.7.2.stable headless dummy renderer on `cursor/intent-preview-loud-e85f` after `origin/main` `63feaec`. No godot-mcp stills. Evidence is `tools/qa` print lines. Existing RID leak warnings on quit are unchanged.

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Shield hover = click | Preview BLK 4, click BLK 4 | `SHIELD_PREVIEW blk=4` / `SHIELD_AFTER blk=4` | `check_intent_preview.gd` | Pass |
| Sai hover = click | Facing Wizard HP drops | `SAI_PREVIEW before=2 delta=-2 pred=0` / `SAI_AFTER hp=0` | `check_intent_preview.gd` | Pass |
| Lantern hover = click | HP 3 → 5 | `LANTERN_PREVIEW hp=5` / `LANTERN_AFTER hp=5` | `check_intent_preview.gd` | Pass |
| Goblin vs Sai | No ATK HP drop | `GOBLIN_PREVIEW row={ }` / `GOBLIN_AFTER hp=1` | `check_intent_preview.gd` | Pass |
| Leave hover | Passes 3 → 2 | `LEAVE_PREVIEW refusals=2` | `check_intent_preview.gd` | Pass |
| Take X hover | Hearts drop (Golem ATK 3, HP 6 → 3) | `DONE_PREVIEW hp=3 incoming would drop from 6` | `check_intent_preview.gd` | Pass |
| Existing QA | All `tools/qa/check_*.gd` still green | layers / boot / item_types / hand_use / fixes_v2 / face_text / action_buttons OK | this run, exit 0 | Pass |
| Attack vs Bleed | Sai is Attack; Goblin takes none | Goblin HP stayed 1; Wizard dropped | `GOBLIN_*` / `SAI_*` | Pass |
| Block vs Attack | Shield raises Block; Take X spends it | Shield 0→4; Done previewed heart loss | `SHIELD_*` / `DONE_*` | Pass |
| No Tier on player screens | Weak / Tough / Deadly | `GATE_OK threats=Weak,Tough,Deadly` | `check_fixes_v2.gd` | Pass |
| Hub / Must-keep | Knight + hearts + shield; no HP numeral | `hearts_visible=false`; hub still draws hearts + BLK | `check_action_buttons` / code | Pass |
| In-editor stills | 1680×1040 hover + punch | dummy renderer; no godot-mcp | none | Note |

## Bugs

None found in the headless preview==outcome loop.

## Balance notes

Wizard HP 2 vs Sai 2 (kill). Golem ATK 3 into 6 HP / 0 BLK → 3 HP. Shield +4 BLK. Lantern +2 HP from 3. Goblin ATK-immune. Leave 3→2.

## Player-facing copy issues

None. Leave still uses `door.pass` / `door.pass_one` / `door.pass_none`. Weak / Tough / Deadly unchanged.

## What was fixed this loop

- Loop 1/3: `_intent_mute` stub signature (`() -> Variant`) so Main compiles. Preview==outcome already passed on first run after that.
- Still left: in-editor hover stills need Godot Editor + godot-mcp. Knife first-option hover. Mark / chaos / passive first click has no number until the extra click.

## Next agent: start here

1. `godot --headless --path . -s tools/qa/check_intent_preview.gd` should print `INTENT_PREVIEW_OK`.
2. In Play: hover Shield (hub `0→4`), Sai (facing HP drop), Leave (pass pip), Take X (hearts). Click and watch the punch.
3. If godot-mcp is on, still the hover and the landing. Do not rewrite locked copy.
