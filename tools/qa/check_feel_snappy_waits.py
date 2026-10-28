#!/usr/bin/env python3
"""Feel waits A/C/D: land callout place, hit/block release_early, draft→spin.

Locks the post-#142/#143 snappy-wait pass without rewriting fight art:
  A — after spin land `_refresh`, one sync `_place_fight_art(true)` so the
      monster callout appears immediately; `_refresh_face` still coalesces.
  C — block stamp / hub sting / intent badge release_early so Take/hit
      feedback overlaps residual blood/burst hold.
  D — `_maybe_auto_spin` settles one process frame (no 0.15s dead timer).

No Godot needed.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
MAIN = ROOT / "scripts" / "main.gd"
WHEEL = ROOT / "scripts" / "boss_wheel.gd"
BADGE = ROOT / "scripts" / "intent_badge.gd"
PLATE = ROOT / "scripts" / "intent_plate.gd"
STAGE = ROOT / "scripts" / "combat_stage.gd"


def _func_body(text: str, name: str) -> str:
    parts = text.split(f"func {name}", 1)
    if len(parts) < 2:
        return ""
    body = parts[-1].split("\nfunc ", 1)[0]
    lines = body.splitlines()
    while lines and lines[-1].startswith("##"):
        lines.pop()
    while lines and lines[-1].strip() == "":
        lines.pop()
    return "\n".join(lines)


def _code_only(body: str) -> str:
    out = []
    for line in body.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        if " #" in line:
            line = line.split(" #", 1)[0]
        out.append(line)
    return "\n".join(out)


def main() -> int:
    failed = 0
    main_src = MAIN.read_text(encoding="utf-8")
    wheel = WHEEL.read_text(encoding="utf-8")
    badge = BADGE.read_text(encoding="utf-8")
    plate = PLATE.read_text(encoding="utf-8")
    stage = STAGE.read_text(encoding="utf-8")

    # --- A: land callout place ---
    spin = _code_only(_func_body(main_src, "_on_spin"))
    if "_place_fight_art(true)" not in spin:
        print("FAIL A: _on_spin must sync-place fight art once on land")
        failed += 1
    # Land place must sit after show_monster / the land _refresh, before abilities.
    show_i = spin.find("show_monster")
    place_i = spin.find("_place_fight_art(true)")
    bleed_i = spin.find("_bleed_begin()")
    refresh_i = spin.find("_refresh()", show_i) if show_i >= 0 else -1
    if min(show_i, refresh_i, place_i, bleed_i) < 0 or not (show_i < refresh_i < place_i < bleed_i):
        print("FAIL A: land place must run after show_monster+_refresh, before _bleed_begin")
        failed += 1
    # Coalesce path must remain (do not reintroduce sync force inside _refresh_face).
    face = _code_only(_func_body(main_src, "_refresh_face"))
    if "_place_fight_art(true)" in face:
        print("FAIL A: _refresh_face must not sync-force place (keep #141 coalesce)")
        failed += 1
    if "_mark_fight_art_dirty()" not in face:
        print("FAIL A: _refresh_face must still mark dirty for coalesce")
        failed += 1

    # --- C: hit/block release_early ---
    block_sig = "func play_block(index: int, release_early: bool = false)"
    if block_sig not in wheel:
        print(f"FAIL C: boss_wheel missing {block_sig!r}")
        failed += 1
    block_fn = _code_only(_func_body(wheel, "play_block"))
    if "release_early" not in block_fn or "0.20" not in block_fn:
        print("FAIL C: play_block must release_early after ~0.20s stamp snap")
        failed += 1
    sting_sig = "func play_hub_sting(kind: String, amount: int = 0, release_early: bool = false)"
    if sting_sig not in wheel:
        print(f"FAIL C: boss_wheel missing {sting_sig!r}")
        failed += 1
    blocked = _code_only(_func_body(main_src, "_play_attack_blocked"))
    if "play_block(facing_index, true)" not in blocked and "play_block(facing_index,true)" not in blocked:
        print("FAIL C: _play_attack_blocked must pass release_early to play_block")
        failed += 1
    owner = _code_only(_func_body(main_src, "_owner_attack"))
    if "intent_plate.fire(" not in owner or "true)" not in owner[owner.find("intent_plate.fire(") : owner.find("intent_plate.fire(") + 120]:
        print("FAIL C: _owner_attack must pass release_early to intent_plate.fire")
        failed += 1
    if "release_early: bool = false" not in badge or "_play_lit_snap" not in badge:
        print("FAIL C: intent_badge must support release_early lit snap")
        failed += 1
    if "release_early: bool = false" not in plate:
        print("FAIL C: intent_plate.fire must accept release_early")
        failed += 1
    # Blood/burst holds shortened (not rewritten into fight-art place).
    if "randf_range(0.22, 0.42)" not in stage and "randf_range(0.22,0.42)" not in stage:
        print("FAIL C: combat_stage blood life must be shortened for hit feel")
        failed += 1

    # --- D: draft → spin ---
    auto = _code_only(_func_body(main_src, "_maybe_auto_spin"))
    if "create_timer(0.15)" in auto:
        print("FAIL D: _maybe_auto_spin must not keep the 0.15s dead wait")
        failed += 1
    if "process_frame" not in auto:
        print("FAIL D: _maybe_auto_spin must settle one process_frame before Spin")
        failed += 1

    if failed:
        return 1
    print("FEEL_SNAPPY_WAITS_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
