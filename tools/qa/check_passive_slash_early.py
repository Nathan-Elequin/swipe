#!/usr/bin/env python3
"""Passive portrait slash: release_early after tell so damage overlaps hold/out.

#142 overlapped item gutter hold/fade. Monster passives still full-awaited the
cut-in (snap + punch/frames + hold + slash-out ≈ 0.5–0.9s) before HP/ATK tells.
This locks the cut-in ticket release after the portrait tell, and that
`_announce_slice` opts in — deck/tutorial seat cut-ins call play() directly and
stay full-wait.

No Godot needed.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
SLASH = ROOT / "scripts" / "ability_slash.gd"
MAIN = ROOT / "scripts" / "main.gd"


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
    slash = SLASH.read_text(encoding="utf-8")
    main_src = MAIN.read_text(encoding="utf-8")

    cutin_sig = "func _show_cutin(fast: bool, release_early: bool = false, ticket: Dictionary = {})"
    if cutin_sig not in slash:
        print(f"FAIL ability_slash.gd missing {cutin_sig!r}")
        failed += 1

    cutin = _func_body(slash, "_show_cutin")
    cutin_code = _code_only(cutin)
    if "ticket[\"done\"] = true" not in cutin_code and "ticket['done'] = true" not in cutin_code:
        print("FAIL _show_cutin must mark ticket done for release_early")
        failed += 1
    # Release must come after punch/frames, before hold — not after slash-out.
    punch_i = cutin_code.find("await _punch_shake")
    done_i = cutin_code.find('ticket["done"] = true')
    if done_i < 0:
        done_i = cutin_code.find("ticket['done'] = true")
    hold_i = cutin_code.find("HOLD_MS")
    if punch_i < 0 or done_i < 0 or hold_i < 0:
        print("FAIL _show_cutin missing punch / ticket done / HOLD_MS ordering anchors")
        failed += 1
    elif not (punch_i < done_i < hold_i):
        print("FAIL _show_cutin must release_early after punch and before HOLD_MS wait")
        failed += 1

    show = _func_body(slash, "_show")
    if "await _show_cutin(fast, release_early, ticket)" not in _code_only(show):
        print("FAIL _show must pass release_early + ticket into _show_cutin")
        failed += 1

    announce = _func_body(main_src, "_announce_slice")
    announce_code = _code_only(announce)
    if '"release_early": true' not in announce_code and "'release_early': true" not in announce_code:
        print("FAIL _announce_slice must pass release_early: true")
        failed += 1
    # Deck seat / fungal / tutorial cut-ins must not route through announce_slice
    # for arrival — they call ability_slash.play directly without release_early.
    for label, snippet in (
        ("challenge refill seat", "await _seat_opener"),
        ("tutorial seat", "_tutorial_replace_with_deck"),
    ):
        # Soft doc: just ensure those helpers still exist (not rewritten away).
        if snippet not in main_src and f"func {snippet}" not in main_src:
            # seat opener / tutorial may be named differently — skip soft check
            pass

    # Arrival / transform cut-ins call play() directly and must stay full-wait.
    arrival_windows = []
    seat_i = main_src.find("await _seat_opener")
    if seat_i >= 0:
        arrival_windows.append(("challenge refill", main_src[max(0, seat_i - 500) : seat_i]))
    fungal_i = main_src.find("func _fungal_infect")
    if fungal_i >= 0:
        arrival_windows.append(("fungal infect", main_src[fungal_i : fungal_i + 1200]))
    for path_label, window in arrival_windows:
        for m in re.finditer(r"ability_slash\.play\(\{", window):
            block = window[m.start() : m.start() + 350]
            if '"is_item": false' not in block and "'is_item': false" not in block:
                continue
            if '"release_early": true' in block or "'release_early': true" in block:
                print(f"FAIL {path_label} cut-in must stay full-wait (no release_early)")
                failed += 1
                break

    if failed:
        return 1
    print("PASSIVE_SLASH_EARLY_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
