# Cutscene effects, tooltip clamp, badge clearance

No player-facing copy changed. `data/player-copy.json` was not edited.

Intro rain is a sprite child of the picture. A Control `clip_contents` flag does not clip sprites, and the rain sprite’s z-index was high enough to paint over the wooden frame and the dialog. The effect layer now clips its children, sits under the wooden frame and under the dialog, and stops at the top of the dialog bar. The same clip is on the combat portrait effect layer. Glints and the drip use that layer with z-index 0.

The text audit treats CPUParticles2D, GPUParticles2D, controls marked `fx`, and effect nodes named like `Fx` as overlap blockers. Blocker rects are cut to ancestor clip rects.

Combat tooltips (the fly inspect, the fight plaque, keyword tips, and the log hint) stay inside a 32px screen margin. They also stay off the log panel and off the hovered card or wheel slice. If the preferred side does not fit, the tip flips.

Wheel name badges keep the call-name line on `FitLabelBox.plan` when the badge is short on height. The last line sits 2px above the badge outline, counting the text stroke and the outline width.

## Files changed

- `scripts/cabin/cutscene_player.gd`
- `scripts/combat_stage.gd`
- `scripts/dev/text_audit.gd`
- `scripts/ui/tooltip_clamp.gd`
- `scripts/main.gd`
- `scripts/keyword_tip.gd`
- `scripts/combat_log.gd`
- `scripts/boss_wheel.gd`
- `scripts/dev/shot_harness.gd`

## Audit

`design/cli-runs/01-font-revert/text_audit.json` (2026-10-17 18:08) had `failures: []` and did not count particle or custom effect rects.

After, `design/cli-runs/02-fx-tooltips/text_audit.json` (2026-10-17 18:34) on intro panels 1–3, combat with the card tooltip and the monster plaque open (eight goblins, the facing one on the right beside the log), and the item hand:

`failures: []` (zero hits).

## Screenshots

- `design/cli-runs/02-fx-tooltips/13a_intro_panel1.png`
- `design/cli-runs/02-fx-tooltips/13b_intro_panel2.png`
- `design/cli-runs/02-fx-tooltips/13c_intro_panel3.png`
- `design/cli-runs/02-fx-tooltips/text_combat_tips.png`
- `design/cli-runs/02-fx-tooltips/text_item_hand.png`
