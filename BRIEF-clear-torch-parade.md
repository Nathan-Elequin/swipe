# Brief: dungeon-clear "Torch parade" (LOCKED by Nathan, 2026-10-28)

> **Direction lock (Nathan, Oct 28):** Sprout hops RIGHT into the burrow, matching his pop-out hop RIGHT on the rope-exit screen. Wipe travels L→R (closes toward right on C, slides off screen-right on D). No wax seal.

## The lock
Dungeon clear = **torch parade**: a biome-tinted spark burst on the wheel hub, then Sprout cheers, hops off into a burrow-tunnel wipe, and lands on the between-dungeon (rope-exit) screen.
- **No wax seal in this beat.** The seal stays reserved for the 5-unique-biome-items moment, where it unlocks a map shortcut (see K5t2l_veMo frame G).
- Viewport 1680×1040. Style is Torchlit Burrow: torch amber #F09A34 is the one accent, gold #FFD84A for glow, dark earth woods, ink #1E120C outlines, hard 0-blur shadows, nearest filtering.
- Copy belongs to Spin. No text baked into any art. Banner, headline, sub, sign, and plank areas stay blank (rope.cleared, rope.sub, rope.sign, rope.climb/_sub, rope.deeper/_sub).
- Engine: Godot 4.7 GL Compatibility. UI toolkit only (AnimatedSprite2D, Tween, TextureRect, NinePatchRect). No shaders or particles. Respect combat_fx_budget gating (hub victory = priority 6).

## Storyboard
Doop canvas "Spinheritance — Clear & transition" (id 7y8H2Ag-sD): A burst · B cheer · C walk-off + wipe (mid) · D arrive.
PNGs: /workspace/fx-redesign/doop/{A_clear-burst,B_sprout-cheer,C_walkoff-burrow-wipe,D_arrive-rope-exit}.png

## Beat timing (suggested)
| t (s) | beat | notes |
|---|---|---|
| 0.00 | hit-stop 80 ms on last kill | |
| 0.00–0.56 | **burst** 8f @ 70 ms | replaces fx_flash #e8c36a + circle.png |
| 0.10–1.40 | **cheer** victory loop ×2 (~120 ms/f), embers drift | hold ~0.4 s after burst |
| 1.40–1.82 | **walk-off** hop toward screen-RIGHT, 6f @ 70 ms | wheel dims under him |
| 1.70–2.20 | **wipe close** soil curtain L→R, 8f @ 50 ms (or 0.5 s x-tween) | Sprout dives into floor burrow at screen-RIGHT |
| 2.20–2.26 | black hold 60 ms | |
| 2.26–2.56 | **wipe open** curtain keeps travelling off screen-RIGHT, 0.3 s | |
| 2.30–2.70 | **arrive** pop out of floor burrow, 1 hop, land on idle_loot mark (680,800) | copy fades in after landing, ~0.2 s |
Clear ≈ 1.4 s (target 1.2–1.6) · transition ≈ 1.3 s (target 1.0–1.4).
Code hook: `_enter_dungeon_clear()` must `await` celebration + walk-off before `phase="rest"` / `_sync_overlay()` → `rope_exit.open_exit()` (today it opens at once with a 0.3 s alpha fade).

## Biome tint (burst long rays stay amber; short rays, sparks, and embers take the biome wax)
| biome | wax |
|---|---|
| Verdant Hollow (b1) | #5f8f3c |
| Sunken Mire (b2) | #6e5a30 |
| Ashen Crypt (b3) | #7a463c |
| Cinder Forge (b4) | #d06828 |
| Shadow Abyss (b5) | #3c3488 |
| Endless | #2a2048 |
Cheapest route: author one neutral/greyscale burst plus embers and tint with `modulate` per biome. Hand-tinted ×6 is the fallback if modulate muddies the darks (Abyss/Endless).

## Asset list for PixelLab (NO seal)
| # | file(s) | native size | frames | role |
|---|---|---|---|---|
| 1 | `assets/dungeon/vfx/clear/clear_burst_f0..f7.png` | 256×256 (shown ×2 = 512) | 8 @ 70 ms | radial spark burst on hub centre (785,496): amber long rays, tint short rays and sparks, dashed inner ring pop f1–f2, glow stays within ~330 px |
| 2 | `assets/dungeon/vfx/clear/clear_embers_f0..f3.png` | 32×32 | 4 loop | 6–10 instances drifting up 40–80 px then fading; tintable |
| 3 | cheer: reuse `hero_run/run_victory_f0..3` (96) ×2 loops. Optional upgrade `sprout_cheer_f0..f5.png` | 96×96 (match hub scale/run3 style) | 6 | jump + fist pump on hub |
| 4 | `sprout_walkoff_hop_f0..f5.png` (or reuse `hero_run/run_walkoff_f0..3`, facing right, no mirror) | 96×96 | 6 @ 70 ms | 3 hops off hub toward screen-RIGHT (unmirrored), ending in a dive |
| 5 | `assets/dungeon/vfx/clear/burrow_mouth_f0..f2.png` | ~96×48 (×4 → 384×192) | 3 | floor burrow opening/close at screen-RIGHT that Sprout dives into |
| 6 | `assets/dungeon/vfx/clear/transition_wipe_f0..f7.png` **or** one `burrow_curtain.png` | 420×260 (×4 → 1680×1040), ragged stepped leading edge, soil + stones + roots | 8 @ 50 ms / 1 tweened | burrow tunnel wipe L→R, then continues off screen-RIGHT to open |
| 7 | `assets/dungeon/home/hero/hero_arrive_f0..f3.png` | 128×128 | 4 | pop out of floor burrow mound + land with dust (rope-exit scale) |
| 8 | `assets/dungeon/home/overlays/burrow_mound.png` (+ dust `land_dust_f0..f2` 32×16) | ~48×16 (×4) | 1 (+3) | exit mound near the Peek spot on rope exit |
| 9 | animate existing `hero_idle_loot_f0..f1` as AnimatedSprite2D | 128×128 | 2 loop | currently static |
Not in scope: `clear_seal_*`, `clear_banner_9` (banner art only if Spin wants a banner; area left blank).
Audio (not Pixel's): sting_clear / unused sting_victory, cab_seal_stamp NOT used here.

## Sources
Background plates in the mock come from repo `Nathan-Elequin/swipe@playtest/latest`: design/audit-shots/cursor/34f_victory.png (hub painted out) and assets/dungeon/home/overlays/rope_exit_bg.png. Sprite stand-ins: hero_run/run_victory, run_walkoff, home/hero/hero_cheer, hero_idle_loot, rope_ladder_f0, deeper_hole_*, torch_flame_f0. See also /workspace/fx-redesign/AUDIT.md.
