#!/usr/bin/env python3
"""Source checks: combat Sprout stays in the hub; left face-off is disabled.

Runs without Godot so CI / cloud agents can verify the strip.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MAIN = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")


def _fail(msg: str) -> int:
    print(f"FAIL {msg}")
    return 1


def main() -> int:
    failed = 0

    if "func _sprout_stay_hub()" not in MAIN:
        failed += _fail("main.gd missing _sprout_stay_hub")

    # Entrance / exit must hard-disable to hub stay (no tween run-on).
    for name in ("_sprout_begin_entrance", "_sprout_begin_exit"):
        marker = f"func {name}() -> void:"
        i = MAIN.find(marker)
        if i < 0:
            failed += _fail(f"missing {name}")
            continue
        body = MAIN[i : i + 280]
        if "_sprout_stay_hub()" not in body:
            failed += _fail(f"{name} must call _sprout_stay_hub")
        if 'global_position = Vector2(-80.0' in body or 'play("run"' in body:
            failed += _fail(f"{name} still stages a left run-on")

    if "func _hub_anim_for_player" not in MAIN:
        failed += _fail("missing _hub_anim_for_player mapping")

    # _player_play must route to hub, not player_stage.play.
    p_i = MAIN.find("func _player_play(state: String")
    if p_i < 0:
        failed += _fail("missing _player_play")
    else:
        body = MAIN[p_i : p_i + 700]
        if "play_hero" not in body:
            failed += _fail("_player_play must call play_hero")
        if "player_stage.play(" in body:
            failed += _fail("_player_play must not drive player_stage.play")
        if "hide_stage()" not in body:
            failed += _fail("_player_play should keep player_stage hidden")

    # Live fight layout must not rebuild the retired FLOOR_Y face-off pair.
    place_i = MAIN.find("func _place_fight_art(force: bool = false) -> void:")
    if place_i < 0:
        place_i = MAIN.find("func _place_fight_art(")
    if place_i < 0:
        failed += _fail("missing _place_fight_art")
    else:
        # Until next top-level func after _place_fight_art
        nxt = MAIN.find("\nfunc ", place_i + 10)
        body = MAIN[place_i:nxt] if nxt > 0 else MAIN[place_i : place_i + 8000]
        if "_layout_floor_pair()" in body:
            failed += _fail("_place_fight_art must not call _layout_floor_pair")
        if "_apply_sprout_floor()" in body:
            failed += _fail("_place_fight_art must not place left-stage Sprout")

    keeps_i = MAIN.find("func _sprout_keeps_stage() -> bool:")
    if keeps_i < 0:
        failed += _fail("missing _sprout_keeps_stage")
    else:
        body = MAIN[keeps_i : keeps_i + 160]
        if "return false" not in body:
            failed += _fail("_sprout_keeps_stage must return false")

    wheel = (ROOT / "scripts" / "boss_wheel.gd").read_text(encoding="utf-8")
    if "_set_hero_heavy" not in wheel or "begin_heavy" not in wheel:
        failed += _fail("boss_wheel must mark hub combat FX as heavy (SP-30)")

    if failed:
        return 1
    print("HUB_SPROUT_NO_FACEOFF_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
